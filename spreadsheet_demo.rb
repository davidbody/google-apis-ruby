require 'googleauth'
require "google_drive"

spreadsheet_name = "demo"
service_account_credentials = "credentials/Iowa Ruby Brigade demo-1e080adb1e34.json"

ENV["GOOGLE_APPLICATION_CREDENTIALS"] = File.expand_path(service_account_credentials, File.dirname(__FILE__))

scopes = ["https://www.googleapis.com/auth/drive", "https://spreadsheets.google.com/feeds/"]
credentials = Google::Auth.get_application_default(scopes)
credentials.fetch_access_token!
access_token = credentials.access_token

drive_session = GoogleDrive.login_with_oauth(access_token)

spreadsheet = drive_session.spreadsheet_by_title(spreadsheet_name)
raise "Spreadsheet #{spreadsheet_name} not found" unless spreadsheet

worksheet = spreadsheet.worksheets.first

attrs = worksheet.rows.first.map(&:to_sym)

worksheet.rows.drop(1).each do |row|
  model_attrs = attrs.zip(row).to_h
  puts model_attrs
end
