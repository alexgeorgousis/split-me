import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submitUpdates() {
    const receiptItems = document.querySelectorAll('[data-controller="receipt-item"]')
    const updates = []

    receiptItems.forEach(item => {
      const itemId = item.dataset.receiptItemId
      const selected = item.dataset.selected === "true"
      const splitMode = item.dataset.splitMode

      updates.push({
        id: itemId,
        selected: selected,
        split_mode: splitMode
      })
    })

    this.sendBatchUpdate(updates)
  }

  sendBatchUpdate(updates) {
    const orderId = window.location.pathname.match(/\/orders\/(\d+)/)[1]
    const url = `/orders/${orderId}/batch_update_receipt_items`

    const formData = new FormData()
    formData.append('updates', JSON.stringify(updates))

    fetch(url, {
      method: 'PATCH',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => {
      if (response.ok) {
        window.location.reload()
      } else {
        console.error('Failed to update receipt items')
      }
    })
    .catch(error => {
      console.error('Error updating receipt items:', error)
    })
  }
}