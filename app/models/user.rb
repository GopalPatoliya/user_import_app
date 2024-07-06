require 'csv'

class User < ApplicationRecord
  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true

  # Class method to import users from CSV file
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      user = User.find_by(email: row["Email"])
      if user
        # Update existing user if found
        user.update(first_name: row["First Name"], last_name: row["Last Name"], contact: row["Contact"], gender: row["Gender"])
      else
        # Create new user if not found
        User.create(email: row["Email"], first_name: row["First Name"], last_name: row["Last Name"], contact: row["Contact"], gender: row["Gender"])
      end
    end
  rescue StandardError => e
    Rails.logger.error("CSV import failed: #{e.message}")
    raise
  end

  # Class method to search users based on criteria
  def self.search(search, gender)
    users = User.all
    users = users.where('first_name LIKE ? OR last_name LIKE ? OR email LIKE ? OR contact LIKE ?', 
                        "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%") if search.present?
    users = users.where(gender: gender) if gender.present?
    users
  end
end
