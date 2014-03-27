# This script takes as input a list containing the slug of github repositories
# and gives as output whether the repo's use Travis and if it does, the number of passed and failed builds

require 'travis'
require './travis_reader.rb'
require 'travis/client/session'

# getting the github repositories
# TODO: get the repo's from a file/database
github_repos = ["travis-ci/travis.rb", "StefvanSchuylenburg/software-evolution", "rails/rails"]

# setting up session
session = Travis::Client::Session.new
session.api_endpoint = "https://tue.travis-ci.org"

# getting Travis information for the github repos
github_repos.each do |repo|
  
  # TODO: for now just printing values, those should eventually be safed to somewhere
  reader = TravisReader.new(repo)
  puts "#{repo}: "
  puts "  uses travis?: #{reader.uses_travis?}"
  
  if reader.uses_travis?
    puts "  passed: #{reader.n_passed}"
    puts "  failed: #{reader.n_failed}"
  end
end  
