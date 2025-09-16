import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image"]

  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.handleScroll, { passive: true })
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }

  handleScroll() {
    if (!this.hasImageTarget) return

    const scrolled = window.pageYOffset
    const heroSection = this.element
    const heroRect = heroSection.getBoundingClientRect()
    
    // Only apply parallax when hero section is visible
    if (heroRect.bottom >= 0 && heroRect.top <= window.innerHeight) {
      // Parallax effect: image moves slower than scroll (depth effect)
      const parallaxSpeed = 0.5
      const yPos = scrolled * parallaxSpeed
      
      this.imageTarget.style.transform = `translate3d(0, ${yPos}px, 0)`
    }
  }
}
