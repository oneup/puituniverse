# load config (should this be done per-default for all packs?)
$config_file = "backend/config"
$config = $config_file.yml

# initialize desired [graphics, sound, input, magic] handler. eg: gosu (desktop), hotruby(flash, web)
require "backend/output/#{$config['output']}"
