class AddCommentToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :admin_comment, :string
  end
end
