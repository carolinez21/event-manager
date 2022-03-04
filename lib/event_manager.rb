require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  phone_number.gsub!(/\D/,"")
  if phone_number.length == 11 && phone_number[0] == '1'
    phone_number[1..10]
  elsif phone_number.length == 10
    phone_number
  else
    '0000000000'
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def store_hours_days(date, hours, days)
  hours << Time.strptime(date, "%m/%d/%y %k:%M").hour
  days << Date::DAYNAMES[Date.strptime(date, "%m/%d/%y").wday]
end

def find_most_frequent(hours, days)
  puts("The peak registration hours are: #{hours.group_by { |hour| hours.count(hour) }.max.last.uniq.join(", ")}")

  puts("The peak registration days are: #{days.group_by { |day| days.count(day) }.max.last.uniq.join(", ")}")
end

puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

hours = []
days = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  # zipcode = clean_zipcode(row[:zipcode])

  # phone_number = clean_phone_number(row[:homephone])

  # legislators = legislators_by_zipcode(zipcode)

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id, form_letter)

  # puts "#{name} #{phone_number}"

  store_hours_days(row[:regdate], hours, days)
end

find_most_frequent(hours, days)
