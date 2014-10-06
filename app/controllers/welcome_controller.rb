class WelcomeController < ApplicationController
  def index
    @agent = Mechanize.new
    @agent.user_agent = 'Linux Mozilla'
    usernames = params[:name]

    verification_status = Array.new
    threads = Array.new
    i = 0
    usernames.split(",").each do |username|
      prev_status = VerifiedName.find_by_username(username)
      i += 1
      if prev_status.nil?
        thread = Thread.new(i) do |i|
          status_hash = get_hash(username)
          verification_status.push status_hash
        end
        threads.push thread

      else
        verification_status.push(name:username,isValid: prev_status.status)
      end
    end
    threads.each {|t| t.join}        
    render json: verification_status
  end
  
  def get_hash(username)
    status = loop_check(10, username)

    VerifiedName.create(username: username, status: status)

    if status == true
      return {name:username,isValid: true}
    else
      return {name:username,isValid: false}
    end
  end

  def loop_check(loop_count, username)
    loop_count.times do 
      return true if verify_name(username) == true
    end
    return false
  end
 
  def verify_name(name)
    begin
      if name != ''

        url = "http://kik.com/u/#{name}"
        @page = @agent.get(url)
        content = @page.content

        if Nokogiri::HTML(content).text.gsub("\t","").gsub("\n","").match("USERNAME:#{params[:name]}")
          return true
        elsif Nokogiri::HTML(content).text.gsub("\t","").gsub("\n","").match("http\:\/\/kik.com\/profile\/notfound.php")
          return false
        else
          return "Invalid"
        end
      else
        return "Invalid"
      end
    rescue => exp
      sleep 1
      return verify_name name
    end
  end
end
