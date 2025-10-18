import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  open() {
    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }

  confirm() {
    const peopleCount = document.getElementById("people-count").value
    console.log(`Split between ${peopleCount} people`)
    this.close()
  }
}
