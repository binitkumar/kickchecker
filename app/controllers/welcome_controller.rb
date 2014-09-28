class WelcomeController < ApplicationController
  def index
    username = params[:name]

    status = verify_name(username)

    if status == true
      render json: {isValid: true}
    elsif status == "Invalid"
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
