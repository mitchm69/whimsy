#
# Process email as it is received
#

YYYYMM = ARGV.shift # Override for merging mails later
if YYYYMM
  raise ArgumentError.new("Invalid yyyymm override #{YYYYMM}") unless YYYYMM =~ /\A20[23]\d(0\d|1[012])\z/
  $stderr.puts "Overriding YYYYMM: #{YYYYMM}"
end

Dir.chdir File.dirname(File.expand_path(__FILE__))

require_relative 'models/mailbox'

# read and parse email
STDIN.binmode
email = STDIN.read
hash = Message.hash(email)

fail = nil
begin
  headers = Message.parse(email)
rescue => e
  fail = e
  headers = {
    exception: e.to_s,
    backtrace: e.backtrace[0],
    message: 'See procmail.log for full details'
  }
end

# construct message
month = YYYYMM || Time.now.strftime('%Y%m')
mailbox = Mailbox.new(month)
message = Message.new(mailbox, hash, headers, email)

# write message to disk
File.umask(0002)
message.write_headers
message.write_email

# Now fail if there was an error
if fail
  require 'time'
  $stderr.puts "WARNING: #{Time.now.utc.iso8601}: error processing email with hash: #{hash}"
  raise fail
end
