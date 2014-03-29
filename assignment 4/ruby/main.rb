# This script takes as input a list containing the url of github repositories
# and gives as output whether the repo's use Travis and if it does, the number of passed and failed builds

require 'travis'
require './travis_reader.rb'
require 'travis/client/session'
require 'csv'

# reading arguments to find input and output file location
input = "./" + ARGV[0] # first we expect the input file location
output = "./" + ARGV[1] # then we expect the output file location

# Reading the input file
urls = CSV.read(input, {:headers => true})

# Getting the slug values
slugs = urls.map do |row|
  url = row[0]
  /https:\/\/github.com\/(.+)/.match(url)[1]
end

# setting up session
session = Travis::Client::Session.new
session.api_endpoint = "https://tue.travis-ci.org"

#  getting Travis information about repo's that use Travis
travis_readers = slugs.map do |slug| 
  puts "Analyzing #{slug}"
  TravisReader.new(slug)
end
travis_enabled = travis_readers.select { |reader| reader.uses_travis? }

# writing to a CSV file
CSV.open(output, "wb") do |csv|
  csv << ["slug", "travis id" "commits passed", "commits failed", "pr passed", "pr failed"]
  travis_enabled.each do |repo|
    puts "Writing #{repo.slug}"
    csv << [repo.slug, repo.travis_id, repo.commits_passed, repo.commits_failed, repo.pr_passed, repo.pr_failed]
  end
end


