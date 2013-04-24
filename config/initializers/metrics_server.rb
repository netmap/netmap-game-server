require 'json'

key_path = Rails.root.join '..', 'keys', 'metrics.json'
if File.exist? key_path
  # The keys repository is cloned next to the application.
  json = JSON.parse File.read(key_path)
  app_id = json['app']['id']
  app_secret = json['app']['secret']
else
  # Use the development keys by default.
  app_id = 123456789
  app_secret = 'DevelopmentSecret-_-00'
end

if app_id == 123456789
  metrics_server = 'http://localhost:9300'
else
  metrics_server = 'http://netmap-data.pwnb.us.'
end

# Allow env variables to override all the settings.
app_id = ENV['METRICS_APP_ID'] if ENV['METRICS_APP_ID']
app_secret = ENV['METRICS_APP_SECRET'] if ENV['METRICS_APP_SECRET']
metrics_server = ENV['METRICS_URL'] if ENV['METRICS_URL']

require 'openssl'

class MetricsServer
  def self.user_token(user_id)
    binary_hmac = OpenSSL::HMAC.digest 'sha256', app_secret,
                                       "#{app_id}.#{user_id}"
    hmac = [binary_hmac].pack('m').strip.gsub('=', '').gsub('+', '-').
                         gsub('/', '_')
    "#{app_id}.#{user_id}.#{hmac}"
  end
end

MetricsServer.define_singleton_method :url do
  metrics_server
end

MetricsServer.define_singleton_method :app_id do
  app_id
end

MetricsServer.define_singleton_method :app_secret do
  app_secret
end
