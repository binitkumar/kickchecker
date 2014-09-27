class WelcomeController < ApplicationController
  def index
    if verify_name 
      render json: {isValid: true}
    else
      render json: {isValid: false}
    end
  end

  def verify_name
    @agent = Mechanize.new
    @page = @agent.get("http://kik.com/u/#{params[:name]}")

    content = @page.content
    
    if Nokogiri::HTML(content).text.gsub("\t","").gsub("\n","").match("USERNAME:#{params[:name]}")
      return true
    elsif Nokogiri::HTML(content).text.gsub("\t","").gsub("\n","").match("http\:\/\/kik.com\/profile\/notfound.php")
      return false
    else
      sleep 1
      return verify_name
    end
  end
end
