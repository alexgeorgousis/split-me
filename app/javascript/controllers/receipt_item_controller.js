import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    // Let the form submit normally - Turbo will handle the response
    // and update the summary when the frame is replaced
  }

  connect() {
    // Update summary when this item connects/reconnects after Turbo updates
    this.updateSummaryAfterLoad()
  }

  updateSummaryAfterLoad() {
    // Update the summary based on all items currently on the page
    setTimeout(() => {
      const summaryController = document.querySelector('[data-controller*="bill-summary"]')
      if (summaryController && summaryController.stimulus) {
        summaryController.stimulus.updateSummary()
      }
    }, 0)
  }
}