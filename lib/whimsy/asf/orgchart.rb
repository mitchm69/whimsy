##
# Part of the whimsy/ASF module of classes that provide simple access to ASF
# data.
module ASF # :nodoc:

  ##
  # Reads and provides access to the
  # <tt>officers/personnel-duties/ROLENAME.yaml</tt> files.
  class OrgChart
    @@duties = {}
    @@desc = {}

    # the file names used to be the same as the role ids, however
    # these were changed in order to fix public links using the shorter names
    @@aliases = {
      'vp-marketing' => 'vp-marketingandpublicity',
      'infra-admin' => 'infrastructureadministrator',
    }

    # parse any changed YAML role files.
    def self.load
      @@source ||= ASF::SVN['personnel-duties']
      Dir[File.join(@@source, '*.txt')].each do |file|
        name = file[/.*\/(.*?)\.txt/, 1]
        next if @@duties[name] and @@duties[name]['mtime'] > File.mtime(file).to_f
        data = Hash[*File.read(file).split(/^\[(.*)\]\n/)[1..-1].map(&:strip)]
        next unless data['info']
        data['info'] = YAML.safe_load(data['info'])
        name = @@aliases[name] || name
        # fix up data items available from elsewhere
        if name =~ %r{^vp-(.+)$} or name =~ %r{^(security)$}
          post = $1
          begin
            data['info']['id'] = ASF::Committee[post].chairs.map {|a| a[:id]}
          rescue
            begin
              data['info']['id'] = ASF::Committee.officers.select{|o| o.name == post}.first.chairs.map {|a| a[:id]}
            rescue
              Wunderbar.info "Cannot find chair for #{name}"
            end
          end
        else
          tmp = ASF::Committee.officers.select{|o| o.name == name}.first
          if tmp
            data['info']['id'] = tmp.chairs.map {|a| a[:id]}
          else
            Wunderbar.info "Cannot find chair for #{name}"
          end
        end
        data['mtime'] = File.mtime(file).to_f
        @@duties[name] = data
      end

      file = File.join(@@source, 'README')
      unless @@desc['mtime'] and @@desc['mtime'] > File.mtime(file).to_f
        data = Hash[*File.read(file).split(/^\[(.*)\]\n/)[1..-1].map(&:strip)]
        if data['info']
          data = YAML.safe_load(data['info'])
          data['mtime'] = File.mtime(file).to_f
          @@desc = data
        end
      end

      @@duties
    end

    ##
    # Access data from a specific role
    # :yield: Hash with ['info'] -> hash of info fields; plus any other [sections]
    def self.[](name)
      self.load
      @@duties[name]
    end

    ##
    # Access descriptions of the <tt>['info']</tt> section fields
    def self.desc
      self.load
      @@desc
    end
  end
end
