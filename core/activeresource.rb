file_mapping = {
  :yml => 'YAML::load',
  :png => 'Resources.load_image'
}

def resource_by_mime_type full_path
  if is_folder? full_path
    return ResourceFolder.new full_path
  else
    file_mapping.each do |file_extension, load_command|
      return eval("#{load_command}(full_path)", if full_path.ends_with(file_extension.to_s)
    end

    raise "no mime mapping found for resource #{name}"
  end
end
   

class ResourceFolder
  def init full_path
    @dir = Dir.new full_path
    @nodes = {}
    @full_paths = {}
    dir.each do |entry|
       # jack/run.png is accessible over jack.run
      node_name = resource.rpslit(".", 2).first
      @nodes[node_name] = nil
      resource_full_path = full_path+"/"+entry
      
      class.send :eval, "attr_accessor :%s" % node_name
      eval("@%s = resource_by_mime_type(resource_full_path)" % node_name)
    end
  end
end