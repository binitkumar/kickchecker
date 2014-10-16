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
      logger.fatal "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
      logger.fatal "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
      logger.fatal "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
      logger.fatal "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
      logger.fatal prev_status.inspect
      i += 1
      if prev_status.nil? || prev_status.status == false
        status_hash = get_hash(username)
        verification_status.push status_hash
      else
        verification_status.push(name:username,isValid: prev_status.status)
      end
    end
    render json: verification_status
  end

  def entries
    @entries = VerifiedName.all.order(:updated_at).paginate(:page => params[:page], :per_page=> 10)
  end
  def update_status
    entry = VerifiedName.find_by_username(params['kik-username'.to_sym])
    if params[:isValid] == 'INVALID'
      entry.update_attribute(:status, false) if entry
    else
      entry.update_attribute(:status, true) if entry
    end
    redirect_to action: :update_entry
  end

  def delete_entry
    entry = VerifiedName.find_by_username(params['kik-username'.to_sym])
    entry.destroy if entry
    redirect_to action: :update_entry
  end
  
  def get_hash(username)
    status = loop_check(10, username)
    
    entry = VerifiedName.first_or_create(username: username)
    entry.update_attribute(:status, status)
    
    logger.fatal "#########################################################"
    logger.fatal "#########################################################"
    logger.fatal "#########################################################"
    logger.fatal "#########################################################"
    logger.fatal entry.inspect
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
