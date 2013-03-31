require 'digest/sha1'


# A sensor reading from a player's device.
class NetReading < ActiveRecord::Base
  # The player who uploaded this reading.
  belongs_to :player
  validates :player, presence: true

  # Cryptographically secure hash of the sensor reading.
  validates :digest, presence: true, length: 1..64, uniqueness: true

  # The sensor reading, encoded as a JSON string.
  validates :json_data, presence: true, length: 1..64.kilobytes

  # :nodoc: update digest whenever new_json_data is set
  def json_data=(new_json_data)
    super
    self.digest = Digest::SHA1.hexdigest new_json_data
  end
end
