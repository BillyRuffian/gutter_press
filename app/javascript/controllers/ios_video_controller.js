// iPhone/iOS Video Compatibility Enhancements
// Stimulus controller for handling iOS video playback issues

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video"]

  connect() {
    this.videoTargets.forEach(video => {
      this.setupiOSCompatibility(video)
    })
  }

  setupiOSCompatibility(video) {
    // Ensure playsinline is set for iOS
    video.setAttribute('playsinline', 'true')
    video.setAttribute('webkit-playsinline', 'true')

    // Handle iOS autoplay restrictions
    if (this.isIOS()) {
      this.setupiOSPlayback(video)
    }

    // Add error handling for iOS video loading issues
    video.addEventListener('error', this.handleVideoError.bind(this))

    // Handle load events to ensure proper iOS rendering
    video.addEventListener('loadedmetadata', this.handleVideoLoaded.bind(this))

    // iOS sometimes needs a manual trigger to show controls properly
    video.addEventListener('canplay', () => {
      if (this.isIOS() && !video.controls) {
        video.controls = true
      }
    })
  }

  setupiOSPlayback(video) {
    // iOS requires user interaction for video to play
    // Add a play button overlay for better UX
    const playButton = this.createPlayButton()

    // Insert play button before video
    video.parentNode.insertBefore(playButton, video)

    // Hide native poster and show our custom overlay
    video.addEventListener('loadstart', () => {
      if (video.poster) {
        playButton.style.backgroundImage = `url(${video.poster})`
      }
    })

    // Handle play button click
    playButton.addEventListener('click', (e) => {
      e.preventDefault()
      video.play().then(() => {
        playButton.style.display = 'none'
        video.controls = true
      }).catch(error => {
        console.warn('iOS video playback failed:', error)
      })
    })

    // Hide play button when video plays
    video.addEventListener('play', () => {
      playButton.style.display = 'none'
    })

    // Show play button when video ends or is paused
    video.addEventListener('ended', () => {
      playButton.style.display = 'flex'
    })
  }

  createPlayButton() {
    const button = document.createElement('div')
    button.className = 'ios-video-play-button'
    button.innerHTML = `
      <svg width="50" height="50" viewBox="0 0 50 50" fill="white">
        <circle cx="25" cy="25" r="25" fill="rgba(0,0,0,0.7)"/>
        <polygon points="20,15 20,35 35,25" fill="white"/>
      </svg>
    `

    // Style the play button
    Object.assign(button.style, {
      position: 'absolute',
      top: '50%',
      left: '50%',
      transform: 'translate(-50%, -50%)',
      cursor: 'pointer',
      zIndex: '10',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      borderRadius: '8px',
      backgroundSize: 'cover',
      backgroundPosition: 'center',
      width: '100%',
      height: '100%',
      minHeight: '200px'
    })

    return button
  }

  handleVideoError(event) {
    const video = event.target
    console.error('Video error on iOS:', {
      error: video.error,
      src: video.currentSrc,
      networkState: video.networkState,
      readyState: video.readyState
    })

    // Try to reload the video on iOS
    if (this.isIOS() && video.error && video.error.code === 4) {
      setTimeout(() => {
        video.load()
      }, 1000)
    }
  }

  handleVideoLoaded(event) {
    const video = event.target

    // Ensure iOS shows the video properly
    if (this.isIOS()) {
      // Force a repaint on iOS
      video.style.display = 'none'
      video.offsetHeight // Trigger reflow
      video.style.display = 'block'
    }
  }

  isIOS() {
    return /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream
  }
}