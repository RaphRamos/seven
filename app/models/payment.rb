class Payment < ApplicationRecord
  has_paper_trail

  enum status: { 'Not Paid': 0, 'Waiting': 1, 'Paid': 2, 'Failed': 3, 'Waived': 4 }

  belongs_to :client
  belongs_to :event
end
