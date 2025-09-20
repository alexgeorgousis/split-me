import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["ingredientsContainer", "template"]

  connect() {
    this.bindRemoveButtons()
  }

  addIngredient() {
    const template = this.templateTarget
    const container = this.ingredientsContainerTarget

    // Clone the template
    const newIngredient = template.cloneNode(true)

    // Remove the template class and make it visible
    newIngredient.classList.remove("ingredient-template")
    newIngredient.style.display = "block"

    // Find the next available index by counting existing ingredients
    const existingIngredients = container.querySelectorAll(".ingredient-row:not(.ingredient-template)")
    const index = existingIngredients.length

    // Update the field names to use the new index
    const inputs = newIngredient.querySelectorAll("input, select")

    inputs.forEach(input => {
      if (input.name) {
        input.name = input.name.replace(/\[new_ingredient\]/, `[${index}]`)
      }
      if (input.id) {
        input.id = input.id.replace(/_new_ingredient_/, `_${index}_`)
      }
    })

    // Clear values
    inputs.forEach(input => {
      if (input.type !== "hidden") {
        input.value = ""
      }
    })

    // Set quantity default
    const quantityInput = newIngredient.querySelector("input[type='number']")
    if (quantityInput) {
      quantityInput.value = "1"
    }

    // Append to container
    container.appendChild(newIngredient)

    // Bind remove button for new ingredient
    this.bindRemoveButtons()
  }

  removeIngredient(event) {
    const ingredientRow = event.target.closest(".ingredient-row")
    const destroyField = ingredientRow.querySelector("input[name*='_destroy']")

    if (destroyField && ingredientRow.dataset.persisted === "true") {
      // Mark for destruction if it's a persisted record
      destroyField.value = "1"
      ingredientRow.style.display = "none"
    } else {
      // Remove from DOM if it's a new record
      ingredientRow.remove()
    }
  }

  bindRemoveButtons() {
    const removeButtons = this.element.querySelectorAll(".remove-ingredient")
    removeButtons.forEach(button => {
      button.removeEventListener("click", this.removeIngredient.bind(this))
      button.addEventListener("click", this.removeIngredient.bind(this))
    })
  }
}