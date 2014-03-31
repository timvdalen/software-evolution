# This script takes as input a list containing the url of github repositories
# and gives as output whether the repo's use Travis and if it does, the number of passed and failed builds

require 'travis'
require './travis_reader.rb' # the location of the Ruby file containing the TravisReader class
require 'travis/client/session'
require 'csv'


# Writes the content of reader to csv
def write(csv, reader)
  csv << [reader.slug, reader.travis_id, reader.commits_passed, reader.commits_failed, 
    reader.pr_passed, reader.pr_failed]
end

# reading arguments to find input and output file location
input = "./" + ARGV[0] # first we expect the input file location
output = "./" + ARGV[1] # then we expect the output file location

# Reading the input file
urls = CSV.read(input, {:headers => true})
  
# Getting the slug values
slugs = urls.map do |row|
  url = row["url"]
  match = /https:\/\/api.github.com\/repos\/(.+)/.match(url)[1]
end

# setting up session
client = Travis::Client.new
client.session.api_endpoint = "https://tue.travis-ci.org"

# immediately writing to the output file
CSV.open(output, "w") do |csv|
  csv << ["slug", "travis id", "commits passed", "commits failed", "pr passed", "pr failed"]
    
  # looping over all repositories
  slugs.each do |slug|
    puts "Analyzing #{slug}"
    reader = TravisReader.new(slug, client)
    # write it to the csv file, if it uses travis
    write(csv, reader) if reader.uses_travis?
  end
end




