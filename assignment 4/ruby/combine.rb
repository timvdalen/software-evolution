# A small script to combine all the data we produced into one csv file
# We assume that the data is found in the data folder under filtered_query.csv, buildinfo.csv and rdata.csv
# saves the data to final_data.csv (in the data folder)

require 'csv'

# getting the .csv files
settings = {:headers => true}
ghtorrent_data = CSV.read("../data/filtered_query.csv", settings)
buildinfo = CSV.read("../data/buildinfo.csv", settings)
r_data = CSV.read("../data/rdata.csv", settings)
output_location = "../data/final_data.csv"

# constant used for when there is no value available
NA = "NA"

# Gets the slug based on an url
def get_slug (url)
  match = /https:\/\/api.github.com\/repos\/(.+)/.match(url)[1]
end

# creating the csv data
data = ghtorrent_data.map do |row|
  
  # getting data from ghtorrent_data
  gHTorrent_id = row["id"]
  slug = get_slug(row["url"])
  n_contributors = row["contributors"]
  n_changes = row["changes_last_month"]
  age = row["age_days"]
  language = row["language"]
  
  # travis data
  # the row from the buildinfo (or nil when there is no such row)
  travis = buildinfo.select{|row1| row1["slug"] == slug}.sample
    
  if travis # project is found on travis
    travis_id = travis["travis id"]
    commits_passed = travis["commits passed"]
    commits_failed = travis["commits failed"]
    pr_passed = travis["pr passed"]
    pr_failed = travis["pr failed"]
        
    # R data
    # we assume there is R data when there is travis data 
    r = r_data.select{|row1| row1["slug"] == slug}.sample 
      
    p_chi = r["p of ct"].to_s
    residuals_chi = Array.new
    for i in 1..4
      residuals_chi[i] = r["residual #{i}"].to_s
    end
    measure_odds = r["measure of or"].to_s
    p_odds = r["p of or"].to_s
      
    # an array containing the data
    [gHTorrent_id, travis_id, slug, n_contributors, n_changes, age, language, commits_passed, commits_failed, pr_passed, pr_failed, p_chi, 
      residuals_chi[1], residuals_chi[2], residuals_chi[3], residuals_chi[4], measure_odds, p_odds]
      
  else # there is no Travis data for this project
    # leave the travis data as "NA"
    [gHTorrent_id, NA, slug, n_contributors, n_changes, age, language, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA]
  end
   
end

# writing to the output file
CSV.open(output_location, "w") do |csv|
  csv << ["GHTorrent id", "Travis CI id", "Repository name", "contributors", "changes last month", "age in days", "Programming language", "commits passed",
    "commits failed", "pull requests passed", "pull request failed", "p-value chi-squared test", "residual commits passed", "residual commits failed",
    "residual pull requests passed", "residual pull requests failed", "odds ratio", "p-value odds ratio"]
  data.each do |array|
    csv << array
  end
end

