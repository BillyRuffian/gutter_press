import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Handle Turbo navigation scroll behavior
    document.addEventListener('turbo:before-visit', this.handleBeforeVisit.bind(this))
    document.addEventListener('turbo:load', this.handlePageLoad.bind(this))
    document.addEventListener('turbo:before-cache', this.handleBeforeCache.bind(this))
  }

  disconnect() {
    document.removeEventListener('turbo:before-visit', this.handleBeforeVisit.bind(this))
    document.removeEventListener('turbo:load', this.handlePageLoad.bind(this))
    document.removeEventListener('turbo:before-cache', this.handleBeforeCache.bind(this))
  }

  handleBeforeVisit(event) {
    // Store current scroll position
    sessionStorage.setItem('scrollPosition', window.pageYOffset.toString())
  }

  handlePageLoad(event) {
    // Always scroll to top on new page loads (not back/forward navigation)
    if (!event.detail?.isPreview) {
      this.scrollToTop()
    }

    // Prevent layout shifts from images loading
    this.preventLayoutShifts()
  }

  handleBeforeCache(event) {
    // Clean up any scroll-related state before caching
    sessionStorage.removeItem('scrollPosition')
  }

  scrollToTop() {
    // Immediate scroll to top without animation to prevent flash
    window.scrollTo(0, 0)

    // Also set document scroll to ensure it's at top
    if (document.documentElement) {
      document.documentElement.scrollTop = 0
    }
    if (document.body) {
      document.body.scrollTop = 0
    }
  }

  preventLayoutShifts() {
    // Find hero sections that might cause layout shifts
    const heroSections = document.querySelectorAll('.hero-section')

    heroSections.forEach(hero => {
      const img = hero.querySelector('img')
      if (img && !img.complete) {
        // Set minimum height to prevent layout shift
        hero.style.minHeight = '60vh'

        // Remove min-height once image loads
        img.addEventListener('load', () => {
          hero.style.minHeight = ''
        }, { once: true })

        // Handle load error
        img.addEventListener('error', () => {
          hero.style.minHeight = ''
        }, { once: true })
      }
    })

    // Handle other potentially shifting elements
    const images = document.querySelectorAll('img:not([width]):not([height])')
    images.forEach(img => {
      if (!img.complete) {
        // Add loading class to prevent shifts
        img.classList.add('loading-image')

        img.addEventListener('load', () => {
          img.classList.remove('loading-image')
        }, { once: true })
      }
    })
  }
}