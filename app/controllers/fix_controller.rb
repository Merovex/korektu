class FixController < ApplicationController
	protect_from_forgery except: :create_github_issue
	def create_github_issue
		require 'octokit'
	    require 'awesome_print'
		# TYPO , SYNTAX , IDEA, IMPLAUSIBLE, CONFUSION , DULL

	    repo_name = 'postal-marine-series.verki'
	    repo_name = 'Konspiro'
	    user_name = 'Merovex'

	    format = (params[:pbk] == 'on') ? 'pbk' : 'mobi'

	    issue = {
	      # params: params,
	      title: "#{params[:kind]} in #{params[:book]} at #{format[0]}.#{params[:location]}",
	      labels: [
	        params[:kind].downcase
	      ]
	    }
	    labels = [params[:kind].downcase, 'reader']
	    name = (params[:name] != '') ? params[:name] : 'Anonymous'
	    reported_by = "Reported by: #{name} (#{params[:email]})".gsub('()',"")

		human = check_recaptcha()

	    text =<<-EOT
## Contributor
* #{reported_by}

## Metadata
* Book: #{params[:book]}
* Edition: #{params[:edition]}
* #{format}. #{params[:location]}

## Description

#{params[:text].gsub(/^#/, '###')}
EOT

		if human
		    github = Octokit::Client.new(:access_token => ENV['github_secret'])
		    repo = "#{user_name}/#{params[:repo]}"
		    res = github.create_issue(repo, issue[:title], text, {labels: labels})
		end
	    redirect_to "http://dausha.net/korektu/thanks?b=#{params[:book]}"
	    # ap res
	end
	private
		def check_recaptcha
			recaptcha_url = "https://www.google.com/recaptcha/api/siteverify"
			secret_key = ENV['recaptcha_secret']
			response = params["g-recaptcha-response"]

			data = "-d \"secret=#{secret_key}&response=#{response}\""

			status = `curl --request POST #{data} #{recaptcha_url}`
			hash = JSON.parse(status)
			hash["success"] == true ? true : false
			# raise "Recaptcha! #{pass} #{status.inspect}"
		end
end
