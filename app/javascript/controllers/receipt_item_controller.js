import { Controller } from "@hotwired/stimulus"

const COMMON_UNSELECTED_BUTTON_CLASSES = [
  "border-gray-300", "dark:border-gray-600", // border
  "bg-white", "dark:bg-gray-800", // background
  "text-gray-700", "dark:text-gray-300", // text
]

const UNSELECTED_MINE_BUTTON_CLASSES = [
  "hover:border-green-400", "hover:bg-green-50", "dark:hover:bg-green-900/20"

]

const SELECTED_MINE_BUTTON_CLASSES = [
  "border-green-600", "bg-green-600", "text-white"
]

const UNSELECTED_SHARED_BUTTON_CLASSES = [
  "hover:border-yellow-400", "hover:bg-yellow-50", "dark:hover:bg-yellow-900/20"
]

const SELECTED_SHARED_BUTTON_CLASSES = [
  "border-yellow-600", "bg-yellow-600", "text-white"
]

const UNSELECTED_REMOVE_BUTTON_CLASSES = [
  "hover:border-red-400", "hover:bg-red-50", "dark:hover:bg-red-900/20"
]

const SELECTED_REMOVE_BUTTON_CLASSES = [
  "border-red-600", "bg-red-600", "text-white"
]

export default class extends Controller {
  static targets = ["splitModePanel", "button"]

  static values = {
    selected: Boolean,
    splitMode: String
  }

  connect() {
    // TODO: can i just call toggleSelected here?
    this.#updateReceiptItemStyles()
    this.#displaySplitModePanel()

    this.setSplitMode({ params: { splitMode: this.splitModeValue } })
  }

  toggleSelected() {
    this.selectedValue = !this.selectedValue
    this.#displaySplitModePanel()
    this.#updateReceiptItemStyles()
  }

  setSplitMode(event) {
    this.#updateSplitModeButtons(event.params.splitMode)
    this.#updateShareAmount()
  }

  // Private

  #displaySplitModePanel() {
    this.splitModePanelTarget.style.display = this.selectedValue ? "block" : "none"
  }

  #updateReceiptItemStyles() {
    if (this.selectedValue) {
      // TODO: move these classes to consts
      this.element.classList.remove("border-gray-300", "dark:border-gray-600", "bg-gray-50", "dark:bg-gray-800")
      this.element.classList.add("border-blue-400", "dark:border-blue-600", "bg-blue-50", "dark:bg-blue-900/20")
    } else {
      this.element.classList.add("border-blue-400", "dark:border-blue-600", "bg-blue-50", "dark:bg-blue-900/20")
      this.element.classList.add("border-gray-300", "dark:border-gray-600", "bg-gray-50", "dark:bg-gray-800")
    }
  }

  #updateSplitModeButtons(selectedSplitMode) {
    this.buttonTargets.forEach(button => {
      if (this.#isSelected(button, selectedSplitMode)) {
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
    button.classList.remove(...COMMON_UNSELECTED_BUTTON_CLASSES)

    switch (this.#splitModeFor(button)) {
      case "mine":
        button.classList.remove(...UNSELECTED_MINE_BUTTON_CLASSES)
        button.classList.add(...SELECTED_MINE_BUTTON_CLASSES)
        break
      case "shared":
        button.classList.remove(...UNSELECTED_SHARED_BUTTON_CLASSES)
        button.classList.add(...SELECTED_SHARED_BUTTON_CLASSES)
        break
      case "remove":
        button.classList.remove(...UNSELECTED_REMOVE_BUTTON_CLASSES)
        button.classList.add(...SELECTED_REMOVE_BUTTON_CLASSES)
        break
    }
  }

  #styleUnselected(button) {
    button.classList.remove("border-green-600", "bg-green-600", "border-yellow-500", "bg-yellow-500", "border-red-600", "bg-red-600", "text-white")
    button.classList.add(...COMMON_UNSELECTED_BUTTON_CLASSES)

    const splitMode = this.#splitModeFor(button)
    if (splitMode === "mine") {
      button.classList.add(...UNSELECTED_MINE_BUTTON_CLASSES)
    } else if (splitMode === "shared") {
      button.classList.add(...UNSELECTED_SHARED_BUTTON_CLASSES)
    } else if (splitMode === "remove") {
      button.classList.add(...UNSELECTED_REMOVE_BUTTON_CLASSES)
    }
  }

  #splitModeFor(button) {
    return button.innerText.toLowerCase().trim()
  }

  #updateShareAmount() {
    // const price = parseFloat(this.element.querySelector('[class*="Price:"]').textContent.replace('Price: £', ''))
    // const splitMode = this.element.dataset.splitMode
    // const shareElement = this.element.querySelector('[class*="Your share:"]')
    //
    // let myShare = 0
    // if (splitMode === "mine") {
    //   myShare = price
    // } else if (splitMode === "shared") {
    //   myShare = price / 2
    // }
    //
    // if (shareElement) {
    //   shareElement.textContent = `Your share: £${myShare.toFixed(2)}`
    // }
  }

}
