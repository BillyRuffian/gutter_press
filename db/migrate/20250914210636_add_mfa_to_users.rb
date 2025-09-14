class AddMfaToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :mfa_enabled, :boolean, default: false, null: false
    add_column :users, :mfa_secret, :string
    add_column :users, :backup_codes, :text # Encrypted JSON array of backup codes

    add_index :users, :mfa_enabled
  end
end
