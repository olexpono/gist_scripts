#! /usr/bin/env ruby
#
# Squarespace Theme -> Grunt Toolbox Converter
# Team Olex / Copyright 2013
#
# Usage
#
#   rb sqsp_convert.rb [folder_name]
#
# Converts [folder_name] into a Grunt.js-enabled dir which can
# deploy to Squarespace, create different versions of the same
# Squarespace theme based on config variables, create different
# layouts for creating i18n versions of layouts in Squarespace.
#
# Creates a backup named ./folder_name_backup
# Converts folder_name into the form:
#
# folder_name/theme/
#               - Similar contents as a normal Squarespace theme
#               - template.conf
#            /build-[target]/
#               - Result of a build process, a "rendered"
#                 Squarespace theme as it is deployed to SQSP
#            /Gruntfile.coffee
#               - Configuration and variables for the site(s)
#            /locales/
#               - JSON files with strings for i18n (if used).
#            /node_modules/
#            /package.json
#            /README.md
#
require 'fileutils'

def warn(question = "Are you sure?",
         positive_message = "Continuing",
         negative_message = "Skipped")
  print question
  print " (y/[no]): "
  input = STDIN.gets.rstrip
  if input == "y" or input == "Y"
    puts positive_message
    return true
  else
    puts negative_message
    return false
  end
end

def prompt(*args)
  print(*args)
  STDIN.gets.rstrip
end

def convert_dir_in_place(dirname)
  FileUtils.cd "#{dirname}"
  FileUtils.mkdir "theme"

  return unless warn("      The next step removes git history, \
\n      It should still be available in #{dirname}_backup. \
\n      Are you sure you want to convert #{dirname}?",
    "Converting.",
    "Skipping: #{dirname}")
  FileUtils.remove_dir(".git", true)

  Dir.glob("**") do |filename|
    if filename.index("theme") != 0
      puts "Moving #{filename} to theme/#{filename}"

      if File.directory? filename
        FileUtils.mkdir "theme/#{filename}"
      else
        FileUtils.mv(filename,
                     "theme/#{filename}",
                     :force => true)
      end
    end
  end

  projectname = prompt "Squarespace subdomain for #{dirname}: "
  puts "Staging subdomain assumed to be #{projectname}staging"
  package_json = <<PACKAGEJSON
{
  "name": "#{projectname}",
  "sqspSubdomain": "#{projectname}",
  "sqspStagingSubdomain": "#{projectname}staging",
  "version": "0.0.1",
  "private": true,
  "devDependencies": {
    "grunt": "0.4.x",
    "grunt-sqsp": "latest"
  },
  "engines": {
    "node": "latest"
  }
}
PACKAGEJSON
  File.open("package.json", "w") do |file|
    puts "Writing package.json"
    file.write(package_json)
  end

  grunt_coffee = <<GRUNT
module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"

    sqsp:
      options:
        navigations:
          mainNav:
            title: "Navigation"
            # international: true
          footerNav:
            title: "Footer Navigation"
        buildDir: 'build'
        themeDir: 'theme'

        # Defaults
        #
        # defaultLocale: 'en'
        # locales:
        #   en:
        #     name: "Default"
        #   jp:
        #     name: "Japan"
        # layoutName: 'default' # == default
        # regionFilename: 'site' # == default
        # deployMessage: 'sqsp-autobuild'
      staging:
        options:
          buildDir: 'build-staging'
          staging: true
          domain: '<%= pkg.sqspStagingSubdomain %>'
          remote: 'https://<%= pkg.sqspStagingSubdomain %>.dev.squarespace.com/template.git'
      prod:
        options:
          buildDir: 'build-prod'
          domain: '<%= pkg.sqspSubdomain %>'
          remote: 'https://<%= pkg.sqspSubdomain %>.dev.squarespace.com/template.git'

  grunt.loadNpmTasks('grunt-sqsp')

  grunt.registerTask("stage", ["sqsp:staging:build", "sqsp:staging:deploy"])
  grunt.registerTask("default", "stage")
GRUNT
  File.open("Gruntfile.coffee", "w") do |file|
    puts "Writing Gruntfile.coffee"
    file.write(grunt_coffee)
  end

  File.open("README.md", "w") do |file|
    puts "Writing README.md"
    file.write("# #{projectname.slice(0).upcase + projectname.slice(1,7326)} Squarespace Theme")
  end

  puts "All done. The next step should be a git init!"
end

ARGV.each do |dirname|
  unless File.exist? dirname
    puts "No such directory: " + dirname
  end

  unless File.exist? "#{dirname}/template.conf"
    next unless warn("      No template.conf found. This script is designed \
\n      for Squarespace themes, which typically have one. \
\n        Are you sure you want to convert #{dirname}?",
          "Continuing",
          "Skipping: #{dirname}")
  end

  puts "Backing Up #{dirname} to #{dirname}_backup."
  FileUtils.cp_r dirname, "#{dirname}_backup"
  puts "Converting: " + dirname
  convert_dir_in_place dirname
end
