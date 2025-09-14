import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "dateField", "dateInput"]

  connect() {
    this.toggleDateField()
  }

  toggle() {
    this.toggleDateField()
  }

  toggleDateField() {
    if (this.checkboxTarget.checked) {
      this.dateFieldTarget.style.display = ""

      // Set default published_at to now if empty
      if (!this.dateInputTarget.value) {
        const now = new Date()
        this.dateInputTarget.value = now.toISOString().slice(0, 16)
      }
    } else {
      this.dateFieldTarget.style.display = "none"
    }
  }
}
