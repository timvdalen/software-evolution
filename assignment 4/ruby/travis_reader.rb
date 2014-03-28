
# Reads a Travis repo and tries to get information about it
class TravisReader
  
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
  
  # the identifier of the Repository
  def slug
    return @slug
  end
  
  # Determines whether the Repository uses Travis.
  def uses_travis?
    return @uses_travis
  end
  
  # The number of passed builds
  def n_passed
    return @n_passed
  end
  
  # The number of failed builds
  def n_failed
    return @n_failed
  end
  
  
end