# Pagy Configuration
# See https://ddnexus.github.io/pagy/docs/how-to#global-configuration

# Instance variables
# See https://ddnexus.github.io/pagy/docs/api/pagy#instance-variables
Pagy::DEFAULT[:limit] = 20        # items per page
Pagy::DEFAULT[:size]  = 9         # nav bar links

# Other Variables
# See https://ddnexus.github.io/pagy/docs/api/pagy#other-variables
# Pagy::DEFAULT[:page_param] = :page    # default

# Rails
# Enable the metadata extra if you want to add the pagination metadata to your responses
# Pagy::DEFAULT[:metadata] = [:scaffold_url, :count, :page, :limit, :pages, :last, :next, :prev]

# Bootstrap 5 Extras
# Uncomment to configure the bootstrap nav helper
# See https://ddnexus.github.io/pagy/docs/extras/bootstrap
require 'pagy/extras/bootstrap'
Pagy::DEFAULT[:bootstrap_nav_class] = 'pagination justify-content-center'

# Array extra: Enable pagy_array for paginating arrays
require 'pagy/extras/array'

# Trim extra: Remove the page=1 param from links
require 'pagy/extras/trim'

# Overflow extra: Allow for easy handling of overflowing pages
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :last_page
