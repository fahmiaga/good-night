# spec/requests/api/users_controller_spec.rb
require 'rails_helper'

RSpec.describe "Api::UsersController", type: :request do
  let!(:current_user) { User.create!(name: "Current User") }
  let!(:friend) { User.create!(name: "Friend") }
  let!(:other_user) { User.create!(name: "Other User") }
  let(:headers) { { "X-Current-User-Id" => current_user.id.to_s } }

  let!(:friend_records) do
    2.times.map do |i|
      SleepRecord.create!(
        user: friend,
        start_time: (i+1).hours.ago,
        end_time: i.hours.ago,
        duration_seconds: 3600
      )
    end
  end

  let!(:other_record) do
    SleepRecord.create!(
      user: other_user,
      start_time: 3.hours.ago,
      end_time: 2.hours.ago,
      duration_seconds: 3600
    )
  end

  before do
    current_user.active_follows.create!(followed: friend)
  end

  describe "POST /api/users/:id/follow" do
    it "creates a follow record" do
      new_user = User.create!(name: "New User")

      post "/api/users/#{new_user.id}/follow", headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["follower"]["id"]).to eq(current_user.id)
      expect(json["followed"]["id"]).to eq(new_user.id)
    end

    it "fails if already following" do
      post "/api/users/#{friend.id}/follow", headers: headers
      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json["error"]).to include("Follower has already been taken")
    end
  end

  describe "DELETE /api/users/:id/unfollow" do
    it "destroys a follow record" do
      delete "/api/users/#{friend.id}/unfollow", headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["followed"]["id"]).to eq(friend.id)
    end

    it "returns error if not following" do
      delete "/api/users/#{other_user.id}/unfollow", headers: headers
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Not following")
    end
  end

  describe "GET /api/users/:id" do
    it "returns sleep records of followings only" do
      get "/api/users/#{current_user.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      users = json["users"]
      expect(users.size).to eq(1)
      expect(users.first["id"]).to eq(friend.id)
      expect(users.first["records"].first["id"]).to eq(friend_records.first.id)
    end

    it "supports pagination" do
      get "/api/users/#{current_user.id}", headers: headers, params: { page: 1, per_page: 1 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["pagination"]["has_more"]).to be true
      expect(json["users"].first["records"].size).to eq(1)
    end
  end
end
