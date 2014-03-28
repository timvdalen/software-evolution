# This script takes as input a list containing the url of github repositories
# and gives as output whether the repo's use Travis and if it does, the number of passed and failed builds

require 'travis'
require './travis_reader.rb'
require 'travis/client/session'
require 'csv'

# Reading the input file
urls = CSV.read("./input.csv", {:headers => true})

# Getting the slug values
slugs = urls.map do |row|
  url = row[0]
  match = /https:\/\/github.com\/(.+)/.match(url)[1]
  puts match
  match
end

# setting up session
session = Travis::Client::Session.new
session.api_endpoint = "https://api.travis-ci.org"

#  getting Travis information about repo's that use Travis
travis_readers = slugs.map { |slug| TravisReader.new(slug) }
travis_enabled = travis_readers.select { |reader| reader.uses_travis? }

# writing to a CSV file
CSV.open("./output.csv", "wb") do |csv|
  csv << ["slug", "passed", "failed"]
  travis_enabled.each do |repo|
    csv << [repo.slug, repo.n_passed, repo.n_failed]
  end
end


