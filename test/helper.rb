require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
require 'test/unit'

# Load JAVA env variables
begin
  ENV['JAVA_HOME'] ||= `readlink -f /usr/bin/java | sed "s:/jre/bin/java::"`.strip
  architecture = `dpkg --print-architecture`.strip
  ENV['LD_LIBRARY_PATH'] = "#{ENV['LD_LIBRARY_PATH']}:#{ENV['JAVA_HOME']}/jre/lib/#{architecture}:#{ENV['JAVA_HOME']}/jre/lib/#{architecture}/client"
rescue
  puts "JAVA_HOME has not been set automatically because it's not Debian here."
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'beardley'
