require 'sass'
require 'yaml'

module Cyborg
  class Importer < Sass::Importers::Filesystem

    def watched_file?(uri)
      !!(uri =~ /\.yml$/ &&
        uri.start_with?(root + File::SEPARATOR))
    end

    protected

    def extensions
      {'yml' => :scss}
    end

    def yaml?(name)
      File.extname(name) == '.yml'
    end

    private

    def _find(dir, name, options)
      return unless yaml? name

      full_filename, syntax = Sass::Util.destructure(find_real_file(dir, name, options))
      return unless full_filename && File.readable?(full_filename)

      yaml       = YAML.load(IO.read(full_filename))
      variables  = yaml.map { |key, value| "$#{key}: #{_convert_to_sass(value)};" }.join("\n")

      Sass::Engine.new(variables, options.merge(
          :filename => full_filename,
          :importer => self,
          :syntax   => :scss
      ))
    end

    def _convert_to_sass(item)
      if item.is_a? Array
        _make_list(item)
      elsif item.is_a? Hash
        _make_map(item)
      else
        item.to_s
      end
    end

    def _make_list(item)
      '(' + item.map { |i| _convert_to_sass(i) }.join(',') + ')'
    end

    def _make_map(item)
      '(' + item.map {|key, value| key.to_s + ':' + _convert_to_sass(value) }.join(',') + ')'
    end
  end

end

