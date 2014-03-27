
# Reads a Travis repo and tries to get information about it
class TravisReader
  
  # the slug of the github repo
  def initialize(repoID)
    begin
      # getting repository
      repository = Travis::Repository.find(repoID)   
      @uses_travis = true
      
      # getting values about the builds
      builds = repository.builds
      @n_passed = builds.count{ |b| b.passed?}
      @n_failed = builds.count{ |b| b.failed?}
      
    rescue
      # repository can not be found
      @uses_travis = false
    end
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