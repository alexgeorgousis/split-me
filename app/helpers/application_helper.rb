module ApplicationHelper
  def icon(name, css_class: nil)
    file_path = Rails.root.join("app", "assets", "images", "#{name}.svg")
    return unless File.exist?(file_path)

    svg = File.read(file_path)

    if css_class
      svg = svg.sub(/<svg/, "<svg class=\"#{css_class}\"")
    end

    svg.html_safe
  end
end
