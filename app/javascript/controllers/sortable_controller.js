import { Controller } from "@hotwired/stimulus"
import { Sortable } from "sortablejs"

// Connects to data-controller="sortable"
export default class extends Controller {
  static targets = ["list"]
  static values = {
    url: String,
    handle: String
  }

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      animation: 150,
      handle: this.handleValue || '.drag-handle',
      onEnd: this.onEnd.bind(this)
    })
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }

  onEnd(event) {
    // Get new order
    const items = Array.from(this.listTarget.querySelectorAll('[data-id]'))
    const positions = {}

    items.forEach((item, index) => {
      const itemId = item.dataset.id
      positions[itemId] = index + 1
    })

    // Send AJAX request to update order
    fetch(this.urlValue, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ item_positions: positions })
    })
      .then(response => response.json())
      .then(data => {
        if (data.status !== 'success') {
          console.error('Failed to reorder items')
          this.showError()
        } else {
          this.showSuccess()
        }
      })
      .catch(error => {
        console.error('Error reordering items:', error)
        this.showError()
      })
  }

  showSuccess() {
    // Update position numbers in the UI
    const items = Array.from(this.listTarget.querySelectorAll('[data-id]'))
    items.forEach((item, index) => {
      const positionCell = item.querySelector('.position-number')
      if (positionCell) {
        positionCell.textContent = index + 1
      }
      item.dataset.position = index + 1
    })
  }

  showError() {
    // Show error message and reload to reset order
    alert('Failed to reorder items. The page will reload.')
    location.reload()
  }
}