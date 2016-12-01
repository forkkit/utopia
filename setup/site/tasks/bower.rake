
namespace :bower do
	desc 'Load the .bowerrc file and setup the environment for other tasks.'
	task :bowerrc do
		require 'json'
		require 'pathname'
		
		root = Pathname.new(__dir__).dirname
		
		bowerrc_path = root + ".bowerrc"
		bowerrc = JSON.load(File.read(bowerrc_path))
		
		@bower_package_root = root + bowerrc['directory']
		@bower_install_root = root + bowerrc['public']
	end
	
	desc 'Update the bower packages and link into the public directory.'
	task :update => :bowerrc do
		require 'fileutils'
		require 'utopia/path'
		
		#sh %W{bower update}
		
		@bower_package_root.children.select(&:directory?).collect(&:basename).each do |package_directory|
			install_path = @bower_install_root + package_directory
			package_path = @bower_package_root + package_directory
			dist_path = package_path + 'dist'
			
			FileUtils::Verbose.rm_rf install_path
			FileUtils::Verbose.mkpath(install_path.dirname)
			
			# If a package has a dist directory, we only symlink that... otherwise we have to do the entire package, and hope that bower's ignore was setup correctly:
			if File.exist? dist_path
				link_path = Utopia::Path.shortest_path(dist_path, install_path)
			else
				link_path = Utopia::Path.shortest_path(package_path, install_path)
			end
			
			FileUtils::Verbose.ln_s link_path, install_path
		end
	end
end
