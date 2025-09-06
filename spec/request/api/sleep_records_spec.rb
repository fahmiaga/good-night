require "rails_helper"

RSpec.describe "Api::SleepRecords", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { "X-Current-User-Id" => user.id.to_s } }

  describe "POST /api/sleep_records" do
    it "creates a new sleep record" do
      post "/api/sleep_records", params: { sleep_record: { start_time: Time.current } }, headers: headers
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json).to include("id", "start_time")
      expect(json["end_time"]).to be_nil
    end

    it "fails if user already has active sleep record" do
      create(:sleep_record, user: user, end_time: nil)

      post "/api/sleep_records", params: { sleep_record: { start_time: Time.current } }, headers: headers
      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Already clocked in")
    end
  end

  describe "PATCH /api/sleep_records/:id/clock_out" do
    let!(:record) { create(:sleep_record, user: user, end_time: nil) }

    it "clocks out successfully" do
      patch "/api/sleep_records/#{record.id}/clock_out", headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include("end_time")
      expect(Time.parse(json["end_time"])).to be_within(1.second).of(Time.current)
    end

    it "fails if already clocked out" do
      record.update!(end_time: Time.current)

      patch "/api/sleep_records/#{record.id}/clock_out", headers: headers
      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Already clocked out")
    end
  end

  # describe "GET /api/sleep_records" do
  #   before do
  #     3.times do |i|
  #       SleepRecord.create!(
  #         user: user,
  #         start_time: 1.hour.ago + i.minutes,
  #         end_time: 30.minutes.from_now + i.minutes,
  #         duration_seconds: 30 * 60
  #       )
  #     end
  #   end

  #   it "returns a list of sleep records" do
  #     get "/api/sleep_records", headers: headers
  #     expect(response).to have_http_status(:ok)
  #     json = JSON.parse(response.body)
  #     expect(json.size).to eq(3)
  #     expect(json.first).to include("id", "start_time", "end_time", "duration_seconds")
  #   end
  # end
  describe "GET /api/sleep_records" do
    context "when current user exist" do
      before do
        # Create some sleep records for the user
        create_list(:sleep_record, 3, user: user, created_at: 3.days.ago)
        create_list(:sleep_record, 2, user: user, created_at: 2.days.ago)
      end

      it "returns a successful response" do
        get api_sleep_records_path, headers: headers
        expect(response).to have_http_status(:success)
      end

      it "returns sleep records for the current user" do
        get api_sleep_records_path, headers: headers

        json_response = JSON.parse(response.body)
        expect(json_response['records'].size).to eq(5)
      end

      it "returns records in descending order by created_at" do
        get api_sleep_records_path, headers: headers

        json_response = JSON.parse(response.body)
        records = json_response['records']

        # Check that records are in descending order
        timestamps = records.map { |r| Time.parse(r['created_at']) }
        expect(timestamps).to eq(timestamps.sort.reverse)
      end

      context "with pagination parameters" do
        before do
          create_list(:sleep_record, 60, user: user)
        end

        it "returns default number of records (50) when no per_page specified" do
          get api_sleep_records_path, headers: headers

          json_response = JSON.parse(response.body)
          expect(json_response['records'].size).to eq(50)
          expect(json_response['pagination']['has_more']).to be true
        end

        it "respects per_page parameter" do
          get api_sleep_records_path, params: { per_page: 10 }, headers: headers

          json_response = JSON.parse(response.body)
          expect(json_response['records'].size).to eq(10)
          expect(json_response['pagination']['per_page']).to eq(10)
        end

        it "caps per_page at 200" do
          get api_sleep_records_path, params: { per_page: 300 }, headers: headers

          json_response = JSON.parse(response.body)
          expect(json_response['pagination']['per_page']).to eq(200)
        end

        it "respects page parameter" do
          get api_sleep_records_path, params: { page: 2, per_page: 10 }, headers: headers

          json_response = JSON.parse(response.body)
          expect(json_response['pagination']['page']).to eq(2)
        end
      end

      it "does not return other users' sleep records" do
        other_user = create(:user)
        create_list(:sleep_record, 3, user: other_user)

        get api_sleep_records_path, headers: headers

        json_response = JSON.parse(response.body)
        expect(json_response['records'].size).to eq(5) # Only the current user's records
      end
    end
  end
end
