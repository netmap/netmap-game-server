json.array!(@sections) do |section|
  json.extract! section, :name, :number
  json.url manual_section_url(section[:name])
end
