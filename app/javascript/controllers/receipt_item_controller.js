import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  toggleSelection() {
    const currentSelected = this.element.dataset.selected === "true"
    const newSelected = !currentSelected

    this.element.dataset.selected = newSelected
    this.updateSelectionUI(newSelected)
    this.updateSplitPanel()
  }

  setSplitMode(event) {
    const splitMode = event.currentTarget.dataset.splitMode
    this.element.dataset.splitMode = splitMode
    this.updateSplitModeUI(splitMode)
    this.updateShareAmount()
  }

  updateSelectionUI(selected) {
    if (selected) {
      this.element.classList.remove("border-gray-300", "bg-gray-50")
      this.element.classList.add("border-blue-400", "bg-blue-50")

      const checkbox = this.element.querySelector(".w-5.h-5")
      if (checkbox) {
        checkbox.className = "w-5 h-5 bg-blue-600 border-2 border-blue-600 rounded flex items-center justify-center"
        checkbox.innerHTML = `
          <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
          </svg>
        `
      }
    } else {
      this.element.classList.remove("border-blue-400", "bg-blue-50")
      this.element.classList.add("border-gray-300", "bg-gray-50")

      const checkbox = this.element.querySelector(".w-5.h-5")
      if (checkbox) {
        checkbox.className = "w-5 h-5 border-2 border-gray-400 rounded"
        checkbox.innerHTML = ""
      }
    }
  }

  updateSplitPanel() {
    const selected = this.element.dataset.selected === "true"
    const splitPanel = this.element.querySelector('.border-t')

    if (splitPanel) {
      splitPanel.style.display = selected ? "block" : "none"
    }
  }

  updateSplitModeUI(splitMode) {
    const buttons = this.element.querySelectorAll('[data-split-mode]')

    buttons.forEach(button => {
      const buttonMode = button.dataset.splitMode

      if (buttonMode === splitMode) {
        button.classList.remove("border-gray-300", "bg-white", "text-gray-700", "hover:border-green-400", "hover:bg-green-50", "hover:border-yellow-400", "hover:bg-yellow-50")

        if (splitMode === "mine") {
          button.classList.add("border-green-600", "bg-green-600", "text-white")
        } else if (splitMode === "shared") {
          button.classList.add("border-yellow-500", "bg-yellow-500", "text-white")
        }
      } else {
        button.classList.remove("border-green-600", "bg-green-600", "border-yellow-500", "bg-yellow-500", "text-white")
        button.classList.add("border-gray-300", "bg-white", "text-gray-700")

        if (buttonMode === "mine") {
          button.classList.add("hover:border-green-400", "hover:bg-green-50")
        } else if (buttonMode === "shared") {
          button.classList.add("hover:border-yellow-400", "hover:bg-yellow-50")
        }
      }
    })
  }

  updateShareAmount() {
    const price = parseFloat(this.element.querySelector('[class*="Price:"]').textContent.replace('Price: £', ''))
    const splitMode = this.element.dataset.splitMode
    const shareElement = this.element.querySelector('[class*="Your share:"]')

    let myShare = 0
    if (splitMode === "mine") {
      myShare = price
    } else if (splitMode === "shared") {
      myShare = price / 2
    }

    if (shareElement) {
      shareElement.textContent = `Your share: £${myShare.toFixed(2)}`
    }
  }
}