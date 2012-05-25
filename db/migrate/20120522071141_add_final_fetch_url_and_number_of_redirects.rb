class AddFinalFetchUrlAndNumberOfRedirects < ActiveRecord::Migration
  def change
    add_column :contents, :final_url, :string
    add_column :contents, :num_redirects, :integer, :default => 0
  end
end
