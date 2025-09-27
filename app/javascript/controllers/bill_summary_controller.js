import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["total", "yours", "theirs"]
  static values = { total: Number }

  connect() {
    // Store reference to this controller for other controllers to access
    this.element.stimulus = this
    this.updateSummary()
  }

  disconnect() {
    delete this.element.stimulus
  }

  updateSummary() {
    // Calculate totals from all receipt items on the page
    const items = document.querySelectorAll('div[data-price][data-selected]')
    let yoursTotal = 0

    items.forEach(item => {
      if (item.dataset.selected === 'true') {
        yoursTotal += parseFloat(item.dataset.price)
      }
    })

    const theirsTotal = this.totalValue - yoursTotal

    this.yoursTarget.textContent = `£${yoursTotal.toFixed(2)}`
    this.theirsTarget.textContent = `£${theirsTotal.toFixed(2)}`
  }
}