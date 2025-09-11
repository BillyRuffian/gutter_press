require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |driver_options|
    driver_options.add_argument('--headless')
    driver_options.add_argument('--no-sandbox')
    driver_options.add_argument('--disable-dev-shm-usage')
    driver_options.add_argument('--disable-gpu')
    driver_options.add_argument('--disable-web-security')
    driver_options.add_argument('--disable-extensions')
    driver_options.add_argument('--window-size=1400,1400')
    driver_options.add_argument("--user-data-dir=#{Dir.tmpdir}/chrome_test_#{Process.pid}_#{SecureRandom.hex(8)}")
  end
end
