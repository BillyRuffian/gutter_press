import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "form", "input"]

  connect() {
    console.log("SearchToggle controller connected successfully!")
  }

  toggle(event) {
    console.log("Toggle button clicked!")
    event.preventDefault()

    if (this.hasFormTarget && this.hasButtonTarget) {
      if (this.formTarget.classList.contains("d-none")) {
        this.show()
      } else {
        this.hide()
      }
    } else {
      console.error("Missing targets - button:", this.hasButtonTarget, "form:", this.hasFormTarget)
    }
  }

  show() {
    console.log("Showing search form")
    if (this.hasFormTarget && this.hasButtonTarget && this.hasInputTarget) {
      this.formTarget.classList.remove("d-none")
      this.buttonTarget.classList.add("d-none")

      // Focus after a brief delay to ensure the form is visible
      setTimeout(() => {
        this.inputTarget.focus()
      }, 100)

      // Add click outside listener to close search
      this.outsideClickListener = (event) => {
        if (!this.element.contains(event.target)) {
          this.hide()
        }
      }
      document.addEventListener('click', this.outsideClickListener)
    }
  }



  hide() {
    console.log("Hiding search form")
    if (this.hasFormTarget && this.hasButtonTarget && this.hasInputTarget) {
      this.formTarget.classList.add("d-none")
      this.buttonTarget.classList.remove("d-none")
      this.inputTarget.value = ""

      // Remove click outside listener
      if (this.outsideClickListener) {
        document.removeEventListener('click', this.outsideClickListener)
        this.outsideClickListener = null
      }
    }
  }

  disconnect() {
    // Clean up listener when controller is removed
    if (this.outsideClickListener) {
      document.removeEventListener('click', this.outsideClickListener)
    }
  }
}