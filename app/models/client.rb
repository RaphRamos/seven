class Client < ApplicationRecord
  has_paper_trail
  has_many :events

  validates :name, length: { minimum: 5 }, presence: true
  validates :email, length: { minimum: 5 }, presence: true
  # validates :location, length: { minimum: 3 }, presence: true
  validates :phone, length: { minimum: 6 }, presence: true

  scope :with_name, ->(name) { where('name ilike ?', "%#{name}%") }
  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? "desc" : "asc"
    case sort_option.to_s
    when /^name/
      order("clients.name #{direction}")
    when /^email/
      order("clients.email #{direction}")
    when /^created_at/
      order("clients.created_at #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def notes
    events&.map do |e|
      "Date: #{e.start.strftime('%v')}</br>#{e.notes&.gsub(/\n/, '</br>')}</br></br>"
    end.join('</br>').html_safe
  end

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [:with_name, :sorted_by]
  )

  def self.options_for_sorted_by
    [['Created At', 'created_at_desc']]
  end
end
