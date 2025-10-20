import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Detect initial color scheme
    this.detectColorScheme()
    
    // Listen for system color scheme changes
    this.mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    this.mediaQuery.addEventListener('change', this.handleColorSchemeChange.bind(this))
  }

  disconnect() {
    if (this.mediaQuery) {
      this.mediaQuery.removeEventListener('change', this.handleColorSchemeChange.bind(this))
    }
  }

  detectColorScheme() {
    const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    this.applyColorScheme(isDark)
  }

  handleColorSchemeChange(event) {
    this.applyColorScheme(event.matches)
  }

  applyColorScheme(isDark) {
    // Update data attribute for potential JavaScript-based styling
    document.documentElement.setAttribute('data-color-scheme', isDark ? 'dark' : 'light')
    
    // Update meta theme-color dynamically
    const themeColorMeta = document.querySelector('meta[name="theme-color"]:not([media])')
    if (themeColorMeta) {
      themeColorMeta.setAttribute('content', isDark ? '#1a1a1a' : '#ffffff')
    }
    
    // Dispatch custom event for other components that might need to know
    document.dispatchEvent(new CustomEvent('colorSchemeChange', { 
      detail: { isDark } 
    }))
  }
}
