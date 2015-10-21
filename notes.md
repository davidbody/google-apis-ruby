# Using Google Apps from Ruby

Iowa Ruby Brigade - October 20, 2015

## Introductions and Overview

### Julie Kent - founder of College Recruit U, LLC (among other things)
### David W. Body - software developer (among other things)

### Background

We recently developed ColegeRecruitU.com, which is an application that helps high school students research and apply to colleges by making the process fun, easy, and social.

Julie will tell us more about CollegeRecruitU and demo the app in a few minutes.

#### Startup development

Initial goal is to get a minimum viable product in production so we can get feedback from real users. And we want to do this quickly and cheaply.

* Do the simplest thing that can work
* Don't build anything you don't need

What about an admin interface?

Normally this requires

* Admin UI (views, routes, controllers and associated unit and UA tests)
* Admin role (which means introducing roles if they don't already exist)

Is there something simpler that could work, at least temporarily?

* Hard code values in Ruby code (e.g. StudentProfilesHelper)
* Simple Ruby scripts / Rails console
* Google spreadsheet and a Rake task.

College data is maintained in a Google spreadsheet. A Rake task is used to update the colleges in the database, including storing logos and photos in Amazon S3.

I'll walk through how to read a Google spreadsheet from Ruby after Julie tells us about College Recruit U. By the way, Julie (in addition to all the research, product validation, focus groups, app design, marketing, etc.) did about half the programming for this app herself.

## College Recruit U - Julie

## How to read a Google spreadsheet from Ruby

- What gem / library should we use?
- How do we authenticate? Most examples assume OAuth2, which is not ideal for our use case.

Look at Google developers documentation.

[https://developers.google.com/products/](https://developers.google.com/products/)

Explore.

What does Google have on Github?

[https://github.com/google](https://github.com/google)

[https://github.com/google/google-api-ruby-client](https://github.com/google/google-api-ruby-client) looks promising, but it's another dead end.

After much searching and downloading and running example code, I found

[https://github.com/gimite/google-drive-ruby](https://github.com/gimite/google-drive-ruby)

This does exactly what we want, but the documentation assumes an OAuth2 authentication flow.

<hr />
Aside:

OAuth2 web flow

![OAuth2 web flow](https://developers.google.com/accounts/images/webflow.png)
<hr />

After more searching, including looking at libraries for Java, Python, and JavaScript, I found an example app that did exactly what I wanted to do: read a Google spreadsheet using non-OAuth authentication. The only problem is that it was a Node.js app.

Actually, the dynamic nature of JavaScript made it pretty easy to reverse engineer how the authentication worked by monkey patching the `request` module.

[Don't show source code until Q&A]

## Demo of what finally worked

### Create spreadsheet in Google Drive

### Create a Google developer project

[https://console.developers.google.com/project](https://console.developers.google.com/project)

### Enable the Drive API

### Create a service account

Save the account credentials JSON file.

### Share the Google sheet with the service account email

### Ruby code (spreadsheet_demo.rb)

```ruby
require 'googleauth'
require "google_drive"

spreadsheet_name = "demo"
service_account_credentials = ""

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
```

Generates hashes that are compatible with ActiveRecord.

### Run the code!

## Other applications

* User acceptance tests (Merchants example)
* Generate reports into Google docs
* Other things?

## Pros and Cons

* Pros
  - Easy (once you know how!)
  - Cloud-based sharing, including permissions (no emailing of spreadsheets)
* Cons
  - Data validation doesn't happen until the Rake task is run
    * Requires expert user (like Julie)
    * To be safe, run Rake task against a local database before running it against production
  - Sheets aren't in version control, but generated code can be
