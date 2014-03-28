
# Reads a Travis repo and tries to get information about it
class TravisReader
  
  # creating getters for those attributes
  attr_reader :slug, :uses_travis, :n_passed, :n_failed
  alias_method :uses_travis?, :uses_travis
  
  # the slug of the github repo
  def initialize(slug)
    begin
      # getting repository
      repository = Travis::Repository.find(slug) 
      @slug = slug  
      @uses_travis = true
      
      # initializing the counter
      @n_passed = 0
      @n_failed = 0
      
      # getting values about the builds
      repository.each_build do |build|
        @n_passed += 1 if build.passed?
        @n_failed += 1 if build.failed?
      end
      
      # clear caches to remove build information from the memory
      Travis.clear_cache
      client.clear_cache
      
    rescue
      # repository can not be found
      @uses_travis = false
    end
  end
  
  
end