require "test_helper"

class MealsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meal = meals(:pasta)
    @tomato = ingredients(:tomato)
    @onion = ingredients(:onion)
    @cheese = ingredients(:cheese)
  end

  test "should get index" do
    get meals_url
    assert_response :success
  end

  test "should get new" do
    get new_meal_url
    assert_response :success
  end

  test "should create meal" do
    assert_difference("Meal.count") do
      post meals_url, params: { meal: { name: @meal.name } }
    end

    assert_redirected_to meal_url(Meal.last)
  end

  test "should show meal" do
    get meal_url(@meal)
    assert_response :success
  end

  test "should get edit" do
    get edit_meal_url(@meal)
    assert_response :success
  end

  test "should update meal" do
    patch meal_url(@meal), params: { meal: { name: @meal.name } }
    assert_redirected_to meal_url(@meal)
  end

  test "should update meal with ingredients" do
    @meal.meal_ingredients.destroy_all

    assert_difference("MealIngredient.count", 2) do
      patch meal_url(@meal), params: {
        meal: {
          name: "Updated Pasta",
          meal_ingredients_attributes: {
            "0" => {
              ingredient_id: @onion.id,
              quantity: 2
            },
            "1" => {
              ingredient_id: @cheese.id,
              quantity: 1
            }
          }
        }
      }
    end

    assert_redirected_to meal_url(@meal)
    @meal.reload
    assert_equal "Updated Pasta", @meal.name
    assert_equal 2, @meal.meal_ingredients.count
    assert_includes @meal.ingredients, @onion
    assert_includes @meal.ingredients, @cheese
  end

  test "should update meal and remove existing ingredients" do
    @meal.meal_ingredients.destroy_all
    meal_ingredient = @meal.meal_ingredients.create!(ingredient: @onion, quantity: 1)

    assert_difference("MealIngredient.count", -1) do
      patch meal_url(@meal), params: {
        meal: {
          name: @meal.name,
          meal_ingredients_attributes: {
            "0" => {
              id: meal_ingredient.id,
              ingredient_id: meal_ingredient.ingredient_id,
              quantity: meal_ingredient.quantity,
              _destroy: "1"
            }
          }
        }
      }
    end

    assert_redirected_to meal_url(@meal)
    @meal.reload
    assert_equal 0, @meal.meal_ingredients.count
  end

  test "should destroy meal" do
    assert_difference("Meal.count", -1) do
      delete meal_url(@meal)
    end

    assert_redirected_to meals_url
  end
end
