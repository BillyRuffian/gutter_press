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
    // Critical iPhone video attributes - must be set programmatically
    video.setAttribute('playsinline', 'true')
    video.setAttribute('webkit-playsinline', 'true')
    video.setAttribute('controls', 'controls')
    video.setAttribute('preload', 'metadata')

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
    // iPhone Safari requires specific handling
    video.addEventListener('loadstart', () => {
      // Force iPhone to show video properly
      video.style.backgroundColor = '#000'
      video.style.minHeight = '200px'
    })

    video.addEventListener('loadedmetadata', () => {
      // Ensure proper iPhone video rendering
      if (video.videoWidth > 0 && video.videoHeight > 0) {
        video.style.aspectRatio = `${video.videoWidth} / ${video.videoHeight}`
        video.style.minHeight = 'auto'
      }
    })

    video.addEventListener('canplay', () => {
      // Final iPhone compatibility check
      video.style.visibility = 'visible'
      video.style.opacity = '1'
    })

    // iPhone video error recovery
    video.addEventListener('error', (e) => {
      console.warn('iPhone video error:', e)
      if (video.error) {
        console.warn('Error code:', video.error.code, 'Message:', video.error.message)
        // Try to recover by reloading
        setTimeout(() => {
          video.load()
        }, 1000)
      }
    })

    // Ensure iPhone shows controls properly
    video.addEventListener('click', () => {
      if (!video.controls) {
        video.setAttribute('controls', 'controls')
      }
    })
  }

  isIPhone() {
    return /iPhone|iPod/.test(navigator.userAgent) && !window.MSStream
  }
}