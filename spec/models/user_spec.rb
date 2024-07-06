require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_attributes) { { first_name: "John", last_name: "Doe", email: "john.doe@example.com", contact: "1234567890", gender: "Male" } }
  let(:invalid_attributes) { { first_name: nil, last_name: nil, email: "invalid_email", contact: nil, gender: nil } }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(User.new(valid_attributes)).to be_valid
    end

    it 'is not valid without a first_name' do
      expect(User.new(valid_attributes.except(:first_name))).to_not be_valid
    end

    it 'is not valid without a last_name' do
      expect(User.new(valid_attributes.except(:last_name))).to_not be_valid
    end

    it 'is not valid without a valid email' do
      expect(User.new(valid_attributes.except(:email))).to_not be_valid
      expect(User.new(valid_attributes.merge(email: "invalid"))).to_not be_valid
    end

    it 'is not valid with a duplicate email' do
      User.create!(valid_attributes)
      expect(User.new(valid_attributes)).to_not be_valid
    end
  end

  describe '.import' do
    let(:file_path) { Rails.root.join('spec/fixtures/users.csv') }
    let(:file) { fixture_file_upload(file_path, 'text/csv') }

    it 'imports users from a CSV file' do
      expect { User.import(file) }.to change { User.count }.by(2)
    end

    it 'updates existing users if email matches' do
      User.create!(valid_attributes)
      expect { User.import(file) }.to change { User.find_by(email: valid_attributes[:email]).first_name }.from("John").to("Jane")
    end

    it 'logs and raises an error if import fails' do
      allow(CSV).to receive(:foreach).and_raise(StandardError.new("Test error"))
      expect(Rails.logger).to receive(:error).with("CSV import failed: Test error")
      expect { User.import(file) }.to raise_error(StandardError, "Test error")
    end
  end

  describe '.search' do
    let!(:user1) { User.create!(first_name: "John", last_name: "Doe", email: "john.doe@example.com", contact: "1234567890", gender: "Male") }
    let!(:user2) { User.create!(first_name: "Jane", last_name: "Smith", email: "jane.smith@example.com", contact: "0987654321", gender: "Female") }

    it 'returns users matching the search term' do
      expect(User.search("John", nil)).to include(user1)
      expect(User.search("John", nil)).to_not include(user2)
    end

    it 'returns users matching the gender' do
      expect(User.search(nil, "Female")).to include(user2)
      expect(User.search(nil, "Female")).to_not include(user1)
    end

    it 'returns users matching both search term and gender' do
      expect(User.search("Jane", "Female")).to include(user2)
      expect(User.search("Jane", "Female")).to_not include(user1)
    end
  end
end
