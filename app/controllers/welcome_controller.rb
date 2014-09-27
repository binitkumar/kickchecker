class WelcomeController < ApplicationController
  def index
    @agent = Mechanize.new
    @page = @agent.get("http://kik.com/u/#{params[:name]}")

    content = @page.content

    puts content
    if Nokogiri::HTML(content).text.gsub("\t","").gsub("\n","").match("USERNAME:#{params[:name]}")
      render json: {isValid: true}
    else
      render json: {isValid: false}
    end
  end
end
