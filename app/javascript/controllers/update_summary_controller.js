import { Controller } from "@hotwired/stimulus"

// TODO: rename to summary controller

export default class extends Controller {
  static targets = ["receiptItem"]
  static values = {
    receiptItems: Array
  }

  submitUpdates() {
    const updates = []

    this.receiptItemsValue.forEach(item => {
      updates.push({
        id: item.id,
        selected: item.selected,
        split_mode: item.splitMode
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
