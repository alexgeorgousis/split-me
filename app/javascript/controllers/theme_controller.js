import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.updateIcon()
  }

  toggle() {
    const html = document.documentElement
    const isDark = html.classList.contains('dark')

    if (isDark) {
      html.classList.remove('dark')
      localStorage.theme = 'light'
    } else {
      html.classList.add('dark')
      localStorage.theme = 'dark'
    }

    this.updateIcon()
  }

  updateIcon() {
    const isDark = document.documentElement.classList.contains('dark')
    const sunIcon = this.element.querySelector('[data-theme-target="sun"]')
    const moonIcon = this.element.querySelector('[data-theme-target="moon"]')

    if (isDark) {
      sunIcon.classList.remove('hidden')
      moonIcon.classList.add('hidden')
    } else {
      sunIcon.classList.add('hidden')
      moonIcon.classList.remove('hidden')
    }
  }
}
