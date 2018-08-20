class Client < ApplicationRecord
  has_paper_trail
  has_many :events

  validates :name, length: { minimum: 5 }, presence: true
  validates :email, length: { minimum: 5 }, presence: true
  validates :location, length: { minimum: 3 }, presence: true
  validates :phone, length: { minimum: 6 }, presence: true

  def notes
    events&.map do |e|
      "Date: #{e.start.strftime('%v')}</br>#{e.notes.gsub(/\n/, '</br>')}</br></br>"
    end.join('</br>').html_safe
  end
end
