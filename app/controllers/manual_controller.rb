# Shows the Game Guide.
class ManualController < ApplicationController
  # GET /manual.json
  def index
    @sections = self.class.sections
    respond_to do |format|
      format.json  # index.json.jbuilder
      format.html  # index.html.erb
    end
  end

  # GET /manual/starting
  def show
    @section = self.class.sections_by_name[params[:name]]

    action_name = "#{'%02d' % @section[:number]}_#{@section[:name]}"
    render :action => action_name
  end

  # The manual's sections, indexed by their name.
  #
  # @return {Hash<String, Hash<Symbol, String>>} the manual sections, indexed
  #     by their names
  def self.sections_by_name
    @sections_by_name ||= sections.index_by { |s| s[:name] }
  end

  # The sections of the manual.
  #
  # @return {Array<Hash<Symbol, String>>} the manual sections, sorted by their
  #     number
  def self.sections
    @sections ||= sections!
  end

  # Builds a fresh index of the manual sections.
  #
  # @return {Array<Hash<Symbol, String>>} the manual sections, sorted by their
  #     number
  def self.sections!
    files = Dir.glob Rails.root.join('app', 'views', 'manual', '*.md').to_s
    files.map! do |f|
      view_name = File.basename(f).sub!(/\.html\.md$/, '')
      section, name = *view_name.split('_', 2)
      { number: section.to_i, name: name }
    end
    files.sort_by! { |f| f[:section] }
  end
end
