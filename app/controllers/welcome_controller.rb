class WelcomeController < ApplicationController
  def index
    username = params[:name]

    if verify_name(username) == true
      render json: {isValid: true}
    elsif varify_name == "Invalid"
      render json: {notice: "Invalid paramter"}
    else
      render json: {isValid: false}
    end
  end

  def verify_name(name)
    begin
      if name != ''
        @agent = Mechanize.new
        url = "http://kik.com/u/#{name}"
       
        @page = @agent.get(url)

        content = @page.content
        puts "----------------------------------" 
        puts url
        puts "----------------------------------" 
        puts content.inspect
        puts "----------------------------------" 
        puts "----------------------------------" 
        if Nokogiri::HTML(content).text.gsub("\t","").gsub("\n","").match("USERNAME:#{params[:name]}")
          return true
        elsif Nokogiri::HTML(content).text.gsub("\t","").gsub("\n","").match("http\:\/\/kik.com\/profile\/notfound.php")
          return false
        else
          sleep 1
          return verify_name
        end
      else
        return "Invalid"
      end
    rescue => exp
      sleep 1
      return verify_name
    end
  end
end
