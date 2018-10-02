namespace :temp_events do
  desc 'Clean Temporary Events'
  # This task should run every 10 minutes on Heroku Scheduler addon
  task clean: :environment do
    Event.where(temporary: true).where('created_at < ?', Time.now).destroy_all
  end
end
