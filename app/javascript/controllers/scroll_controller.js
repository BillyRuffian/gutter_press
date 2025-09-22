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
    // Store current scroll position with the current URL
    const currentUrl = window.location.href
    sessionStorage.setItem(`scrollPosition_${currentUrl}`, window.pageYOffset.toString())
  }

  handlePageLoad(event) {
    // Check if this is a back/forward navigation by looking for stored scroll position
    const currentUrl = window.location.href
    const storedPosition = sessionStorage.getItem(`scrollPosition_${currentUrl}`)
    
    if (storedPosition && !event.detail?.isPreview) {
      // This is likely a back navigation, restore scroll position
      // Use requestAnimationFrame to ensure DOM is ready
      requestAnimationFrame(() => {
        window.scrollTo(0, parseInt(storedPosition))
      })
    } else if (!event.detail?.isPreview) {
      // This is a new page visit, scroll to top
      this.scrollToTop()
    }

    // Prevent layout shifts from images loading
    this.preventLayoutShifts()
  }

  handleBeforeCache(event) {
    // Keep scroll position in storage for potential back navigation
    // Clean up old scroll positions to prevent memory leaks (keep last 10)
    this.cleanupOldScrollPositions()
  }

  cleanupOldScrollPositions() {
    const scrollKeys = []
    for (let i = 0; i < sessionStorage.length; i++) {
      const key = sessionStorage.key(i)
      if (key && key.startsWith('scrollPosition_')) {
        scrollKeys.push(key)
      }
    }
    
    // Remove oldest entries if we have more than 10
    if (scrollKeys.length > 10) {
      scrollKeys.slice(0, scrollKeys.length - 10).forEach(key => {
        sessionStorage.removeItem(key)
      })
    }
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
    // For hero sections, let's not interfere with their layout at all
    // The scroll jumping was the main issue, which we've fixed with scrollToTop()
    
    // Only handle non-hero images that might cause layout shifts
    const images = document.querySelectorAll('img:not([width]):not([height]):not(.hero-bg)')
    images.forEach(img => {
      if (!img.complete) {
        // Add loading class to prevent shifts for regular images
        img.classList.add('loading-image')

        img.addEventListener('load', () => {
          img.classList.remove('loading-image')
        }, { once: true })
      }
    })
  }
}