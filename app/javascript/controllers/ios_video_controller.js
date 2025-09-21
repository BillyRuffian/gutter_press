// iPhone/iOS Video Compatibility Enhancements
// Stimulus controller for handling iOS video playback issues

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const video = this.element.querySelector('video')
    if (video) {
      this.setupiPhoneVideoCompatibility(video)
    }
  }

  setupiPhoneVideoCompatibility(video) {
    // Essential iPhone video attributes - set programmatically for reliability
    video.setAttribute('playsinline', '')
    video.setAttribute('webkit-playsinline', '')
    video.setAttribute('controls', 'controls')
    video.setAttribute('preload', 'metadata')
    video.setAttribute('x-webkit-airplay', 'allow')

    // iPhone requires muted attribute for some video loading scenarios
    if (this.isIPhone()) {
      video.setAttribute('muted', 'muted')
    }

    // iPhone-specific styling
    video.style.width = '100%'
    video.style.height = 'auto'
    video.style.display = 'block'
    video.style.outline = 'none'

    if (this.isIPhone()) {
      this.applyiPhoneSpecificFixes(video)
    }
  }

  applyiPhoneSpecificFixes(video) {
    // iPhone Safari requires specific handling for proper display
    video.addEventListener('loadstart', () => {
      video.style.backgroundColor = '#000'
      video.style.minHeight = '200px'
    })

    video.addEventListener('loadedmetadata', () => {
      // Set proper aspect ratio once metadata loads
      if (video.videoWidth > 0 && video.videoHeight > 0) {
        video.style.aspectRatio = `${video.videoWidth} / ${video.videoHeight}`
        video.style.minHeight = 'auto'
      }
    })

    video.addEventListener('canplay', () => {
      // Ensure video is visible and ready for iPhone
      video.style.visibility = 'visible'
      video.style.opacity = '1'

      // iPhone sometimes needs a nudge to show controls
      if (!video.controls) {
        video.setAttribute('controls', 'controls')
      }
    })

    // iPhone video error recovery - reload on failure
    video.addEventListener('error', () => {
      setTimeout(() => {
        video.load()
      }, 1000)
    })

    // Handle iPhone video interaction requirements  
    video.addEventListener('click', (e) => {
      // Ensure controls are visible on click
      if (!video.controls) {
        video.setAttribute('controls', 'controls')
      }

      // Try to play if video is paused (iPhone sometimes needs this)
      if (video.paused && video.readyState >= 3) {
        video.play().catch(() => {
          // Silently handle play promise rejection
        })
      }
    })

    // Force load the video for iPhone
    setTimeout(() => {
      video.load()
    }, 100)
  }

  isIPhone() {
    return /iPhone|iPod/.test(navigator.userAgent) && !window.MSStream
  }
}