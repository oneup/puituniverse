class String
  def yml
    YAML::load_file "#{self}.yml"
  end
end

class Resources
  def self.init window
    @@window = window
    @@images = {}
    @@gfx = {}
  end

  def self.load_gfx name
    name = resourceify name
    return @@gfx[name] if @@gfx[name]

    #try if it's an animation
    begin
      @@gfx[name] = Animation.new name
    rescue
      return @@gfx[name] = self.load_image("#{name}.png")
    end
  end

  def self.load_image name
    name = resourceify name
    @@images[name] ||= Gosu::Image.new(@@window, name, true)
  end
  
  def self.resourceify name
    # => running puit olympics
    # ./shared/jack/foo.png
    # level/bar.png
    # olympics/level/bar.png
    if name.starts_with? './' # relative to PuitUniverse root url
      name
    elsif name.starts_with? $game_name # game name was specified, but could have been ommited
      name
    else
      "#{$game_name}/#{name}" # per default search in game name folder
    end
  end
end


# sweet "filesystem is part of our object tree" system:
#
# root = res("")
# already_loaded_yaml = root.core.core # core/core.yml
# already_parsed_image = root.shared.jack.jump # shared/jack/jump.ong
# => root.shared.jack.jump.draw(0,0,1) # W00T!!!
#
#file_mapping = {
#  :yml => 'YAML::load',
#  :png => 'Resources.load_image'
#}
#
#def resource full_path
#  if is_folder? full_path
#    return ResourceFolder.new full_path
#  else
#    file_mapping.each do |file_extension, load_command|
#      return eval("#{load_command}(full_path)", if full_path.ends_with(file_extension.to_s)
#    end
#
#    raise "no mime mapping found for resource #{name}"
#  end
#end
#   
#
#class ResourceFolder
#  def init full_path
#    @dir = Dir.new full_path
#    @nodes = {}
#    @full_paths = {}
#    dir.each do |entry|
#       # jack/run.png is accessible over jack.run
#      node_name = resource.rpslit(".", 2).first
#      @nodes[node_name] = nil
#      resource_full_path = full_path+"/"+entry
#      
#      class.send :eval, "attr_accessor :%s" % node_name
#      eval("@%s = resource(resource_full_path)" % node_name)
#    end
#  end
#end