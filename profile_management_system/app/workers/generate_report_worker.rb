class GenerateReportWorker
  include Sidekiq::Worker

  def perform()
    # Do something

    no_of_users_yesterday = User.where("Date(created_at) = ?", Date.yesterday).count
    puts "#{no_of_users_yesterday}"

    file = File.open("daily_report_of_users.txt", "a")
    file.puts "Number of users created on #{Date.yesterday} : #{no_of_users_yesterday} " 
    file.close

=begin
    no_of_signups_today = Rails.cache.read(Date.today.to_s)
	    if no_of_signups_today
	    	Rails.cache.write(Date.today.to_s, no_of_signups_today + 1)
	    else
			Rails.cache.write(Date.today.to_s,1)
		end
=end
	end
end

#Sidekiq::Cron::Job.create(name: 'Generate report every day', cron: '59 12 * * *', class: 'GenerateReportWorker' )
