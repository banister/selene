require 'rake/clean'

$dlext = Config::CONFIG['DLEXT']

CLEAN.include("**/*.#{$dlext}", "**/*.o")
CLOBBER.include("**/*~", "**/*#*", "**/*.log")

task :default => [:texplay]

TEXPLAY = "/home/john/ruby/myextensions/texplay2"
desc "update selene's version of texplay"
task :texplay => ["lib/texplay.rb", "lib/texplay-contrib.rb", "lib/ctexplay.#{$dlext}"] do
    puts "...done!"
end

file "lib/texplay.rb" => "#{TEXPLAY}/texplay.rb" do |t|
    cp t.prerequisites.first, t.name, :verbose => true
end

file "lib/texplay-contrib.rb" => "#{TEXPLAY}/texplay-contrib.rb" do |t|
    cp t.prerequisites.first, t.name, :verbose => true
end

file "lib/ctexplay.#{$dlext}" => "#{TEXPLAY}/ctexplay.#{$dlext}" do |t|
    cp t.prerequisites.first, t.name, :verbose => true
end
