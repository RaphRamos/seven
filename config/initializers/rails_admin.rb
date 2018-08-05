RailsAdmin.config do |config|
  config.excluded_models = ['ActiveStorage::Blob', 'ActiveStorage::Attachment', 'Admin']
  config.main_app_name = ["Seven Migration", "- BackOffice"]
  config.total_columns_width = 2000

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :admin
  end
  config.current_user_method(&:current_admin)

  config.label_methods << :desc # Default is [:name, :title]
  config.label_methods << :id

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  config.audit_with :paper_trail, 'Admin', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  # PAPER_TRAIL_AUDIT_MODEL = ['Client', 'Appointment', 'Agent', 'EventType', 'Event', 'Payment']
  # config.actions do
  #   history_index do
  #     only PAPER_TRAIL_AUDIT_MODEL
  #   end
  #   history_show do
  #     only PAPER_TRAIL_AUDIT_MODEL
  #   end
  # end

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  config.show_gravatar = false

  config.model 'Client' do
    exclude_fields :events
  end

  config.model 'Timetable' do
    list do
      include_fields :id, :agent, :dow, :start_time, :end_time, :activated, :timetable_event_types, :event_types
      field :dow do
        pretty_value do
          value&.split(',')&.map { |v| Timetable.dow_to_string(v) }&.join(', ')
        end
      end
    end
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    # export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
