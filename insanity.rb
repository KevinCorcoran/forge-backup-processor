backup = "2014-10-14_000005"

module_dirs = `ls -1 #{backup}`.split.select { |x|
  File.directory? "#{backup}/#{x}"
}
puts "Found #{module_dirs.count} module_dirs"

unique_modules = []
module_names_with_multiple_versions = []

module_dirs.each { |module_dir|
	stop_index = module_dir.index /[0-9]+\.[0-9]+\.[0-9]+/

	if stop_index
		# multiple versions

    stop_index = stop_index - 2 # take off the version entirely
    #puts "stop index is #{stop_index}"

    mod = module_dir[0..stop_index]
    module_names_with_multiple_versions << mod

  else
		# only one version
		unique_modules << module_dir
  end
}

module_names_with_multiple_versions.uniq.each { |module_name|
  versions = module_dirs.select { |mod|
    mod.start_with? "#{module_name}-"
  }

  all_versions = []

  if versions.size == 1
    all_versions << versions.first
  else

    versions.each { |version|

      result = /[0-9]+\.[0-9]+\.[0-9]+/.match(version)[0].split(".")
      # puts "found version: #{major}.#{minor}.#{micro}"
      #puts "found result: #{result.inspect}"

      is_beta = version.match(/rc[0-9]$/) or version.end_with? "beta"

      found_version = {:major => result[0].to_i,
                       :minor => result[1].to_i,
                       :micro => result[2].to_i,
                       :beta => is_beta,
                       :orig => version}

      #puts "found version #{found_version}"

      all_versions << found_version

    }
  end

  chosen_version = nil
  if all_versions.size == 1
    chosen_version = all_versions.first
  else

    all_versions.sort! { |a,b|
      if a[:beta] and not b[:beta]
        -1
      elsif b[:beta] and not a[:beta]
        1
      elsif a[:major] > b[:major]
        -1
      elsif a[:major] < b[:major]
        1
      else
        if a[:minor] > b[:minor]
          -1
        elsif a[:minor] < b[:minor]
          1
        else
          if a[:micro] > b[:micro]
            -1
          elsif a[:micro] < b[:micro]
            1
          else
            if all_versions.size == 1
              0
            else
              # whatever, just pick one, it shouldn't matter
              0
            end
          end
        end
      end
    }

    chosen_version = all_versions.first[:orig]
  end

  unless chosen_version
    puts "failed to choose version for module #{module_name}"
    exit -1
  end

  puts "For module #{module_name}, found all versions: #{all_versions} and chose #{chosen_version}"

  unique_modules << chosen_version
}

# puts "here is a recent version of every module:"
# puts unique_modules

puts "found #{unique_modules.count} unique modules"

unique_modules.each { |m|
  `cp -R #{backup}/#{m} unique-modules`
}

