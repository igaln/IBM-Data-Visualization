# Convert csv files to JSON for parsin
# IBM Dava Viz Project
# by Igal Nassima


require "rubygems"
require 'csv'
require 'json'


module GetAddressRaw
  @totalHash = Hash.new
  CSV.foreach("JSONS/Oracle/Oracle_sysomos-content-2013-03-14.csv") do |row|
      puts row[0]
      @tempDest = Array.new
      currentRow = row[5]
      if(currentRow)
        currentRow.split.each do |word|
          if word.match(/^@/) 
            word = word.gsub(/[:,."@]/, '') 
            @tempDest.push(word)
          end
        @totalHash[row[0]] = @tempDest
        end
      #puts @totalHash
     end
  end


  def self.getUserLoc(twitterId)
    File.open("JSONS/Oracle/datamapped.json","w") do |f|
      f.write(@totalHash.to_json)
    end
    return "done"
  end

end

puts "Status: " + GetAddressRaw.getUserLoc("Desktop")