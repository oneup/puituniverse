# load config (should this be done per-default for all packs?)
$config_file = "backend/config"
$config = $config_file.yml

# initialize desired output handler (graphics, sound, input, magick, ...)
require "backend/output/#{$config['output']}"
