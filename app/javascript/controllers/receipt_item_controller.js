import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["splitModePanel", "button", "yourShare"]

  static values = {
    splitMode: String,
    selected: Boolean,
    price: Number
  }

  static classes = [
    "selectedReceiptItem",
    "unselectedReceiptItem",
    "commonUnselectedButton",
    "commonSelectedButton",
    "selectedMineButton",
    "selectedSharedButton",
    "unselectedMineButton",
    "unselectedSharedButton",
  ]

  connect() {
    this.#updateReceiptItemStyles()
    this.#displaySplitModePanel()
    this.#updateSplitModeButtonStyles()
    this.#updateYourShare()
  }

  toggleSelected() {
    this.selectedValue = !this.selectedValue
    this.#displaySplitModePanel()
    this.#updateReceiptItemStyles()
  }

  setSplitMode(event) {
    this.splitModeValue = event.params.splitMode
    this.#updateSplitModeButtonStyles()
    this.#updateYourShare()
  }

  // Private

  #displaySplitModePanel() {
    this.splitModePanelTarget.style.display = this.selectedValue ? "block" : "none"
  }

  #updateReceiptItemStyles() {
    if (this.selectedValue) {
      this.element.classList.remove(...this.unselectedReceiptItemClasses)
      this.element.classList.add(...this.selectedReceiptItemClasses)
    } else {
      this.element.classList.remove(...this.selectedReceiptItemClasses)
      this.element.classList.add(...this.unselectedReceiptItemClasses)
    }
  }

  #updateSplitModeButtonStyles() {
    this.buttonTargets.forEach(button => {
      if (this.#isSelected(button, this.splitModeValue)) {
        this.#styleSelected(button)
      } else {
        this.#styleUnselected(button)
      }
    })
  }

  #isSelected(button, selectedSplitMode) {
    return this.#splitModeFor(button) === selectedSplitMode
  }

  #styleSelected(button) {
    button.classList.remove(...this.commonUnselectedButtonClasses)
    button.classList.add(...this.commonSelectedButtonClasses)

    switch (this.#splitModeFor(button)) {
      case "mine":
        button.classList.remove(...this.unselectedMineButtonClasses)
        button.classList.add(...this.selectedMineButtonClasses)
        break
      case "shared":
        button.classList.remove(...this.unselectedSharedButtonClasses)
        button.classList.add(...this.selectedSharedButtonClasses)
        break
    }
  }

  #styleUnselected(button) {
    button.classList.remove(...this.commonSelectedButtonClasses)
    button.classList.add(...this.commonUnselectedButtonClasses)

    switch (this.#splitModeFor(button)) {
      case "mine":
        button.classList.remove(...this.selectedMineButtonClasses)
        button.classList.add(...this.unselectedMineButtonClasses)
        break
      case "shared":
        button.classList.remove(...this.selectedSharedButtonClasses)
        button.classList.add(...this.unselectedSharedButtonClasses)
        break
    }
  }

  #splitModeFor(button) {
    return button.innerText.toLowerCase().trim()
  }

  #updateYourShare() {
    const price = this.priceValue
    const splitMode = this.splitModeValue
    const yourShareElement = this.yourShareTarget

    let yourShare = 0.0
    switch (splitMode) {
      case "mine":
        yourShare = price
        break
      case "shared":
        yourShare = price / 2
        break
    }

    yourShareElement.textContent = `Your share: £${yourShare.toFixed(2)}`
  }

}
