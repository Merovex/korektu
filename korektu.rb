class Korektu < Sinatra::Base
  require 'octokit'
  require "json"

  set :public_folder => "public", :static => true

  get "/" do
    redirect ENV['noget_url']
  end
  post "/" do
    if (ishuman?() and trusted_origin_url?())
        format = (params[:pbk] == 'on') ? 'pbk' : 'mobi'
        title  = "#{params[:label]} in #{params[:book]} at #{format[0]}.#{params[:location]}"
        name   = (params[:name] != '')  ? params[:name] : 'Anonymous'
        email  = "(#{params[:email]})".gsub('()','')
        text   =<<-EOT
## Contributor
* Reported by: #{name} #{email}

## Metadata
* Book: #{params[:book]}
* Edition: #{params[:edition]}
* #{format}. #{params[:location]}

## Description

#{params[:text].gsub(/^#/, '###')}
EOT
        github = Octokit::Client.new(:access_token => ENV['github_secret'])
        res    = github.create_issue(params[:repo], title, text, {labels: [params[:label].downcase, 'reader']})
        redirect "#{ENV['thanks_url']}?b=#{params[:book]}"
    else
      puts "Deviant!"
      redirect "#{ENV['thanks_url']}?b=#{params[:book]}&d=true"
    end
  end
  def trusted_origin_url?()
    http_origin = request.env['HTTP_ORIGIN'].sub("http://","").sub("https://","").sub(":4000","")
    good = ENV['origin_url'].split(';').include?(http_origin)
    puts "Trusted? #{good} (#{ENV['origin_url'].split(';').inspect}) (#{request.env['HTTP_ORIGIN']})"
    return good
  end
  def ishuman?
      secret_key    = ENV['recaptcha_secret']
      return true if secret_key.nil? # You didn't set up Recaptcha, you get what you get.
      return true

      recaptcha_url = "https://www.google.com/recaptcha/api/siteverify"
      data          = "-d \"secret=#{secret_key}&response=#{params["g-recaptcha-response"]}\""
      status        = `curl --request POST #{data} #{recaptcha_url}`
      hash          = JSON.parse(status)
      hash["success"] == true ? true : false
  end
end
