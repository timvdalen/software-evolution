
# Reads a Travis repo and tries to get information about it
class TravisReader
  
  # creating getters for those attributes
  attr_reader :slug, :uses_travis, :commits_passed, :commits_failed, :pr_passed, :pr_failed, :travis_id
  alias_method :uses_travis?, :uses_travis
  
  # the slug of the github repo
  def initialize(slug)
    begin
      # getting repository
      repository = Travis::Repository.find(slug) 
      @slug = slug  
      @uses_travis = true
      
      # initializing the counter
      @commits_passed = 0
      @commits_failed = 0
      # pull requests
      @pr_passed = 0
      @pr_failed = 0
      
      # getting values about the builds
      repository.each_build do |build|
        if build.pull_request? # this is a pull request
          @pr_passed += 1 if build.passed?
          @pr_failed += 1 if build.failed?
        else # commit
          @commits_passed += 1 if build.passed?
          @commits_failed += 1 if build.failed?
        end
      end
      
      @travis_id = repository.last_build.repository_id
      
    rescue
      # repository can not be found
      puts "ERROR: #{$!}"
      @uses_travis = false
    end
  end
  
  
end