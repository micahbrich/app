module FlashHelper
  def display_flash
    flashes = ""
    [:notice, :error].each do |name|
      flashes += "<p class='flash #{name}'>#{flash[name]}</p>" if flash[name]
    end
    return flashes
  end
end