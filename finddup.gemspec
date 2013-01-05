Gem::Specification.new do |s|
  s.name = 'finddup'
  s.author = 'Juha-Jarmo Heinonen'
  s.email = 'o@sorsacode.com'
  s.version = File.read('VERSION')
  s.date = Time.now
  s.homepage = 'http://github.com/jammi/finddup/'
  s.summary = "A simple recursive duplicate file finder"
  s.description = File.read('README.txt').split("\n\n")[0].strip
  require 'rake'
  s.files = FileList[
    'lib/**/*',
    'bin/*',
    'README.txt',
    'LICENSE.txt',
    'VERSION'
  ].to_a
  s.files.reject! { |fn| fn.start_with? "." }
  s.files.reject! { |fn| fn.end_with? ".rbc" }
  s.executables = [ 'finddup' ]
  s.required_ruby_version = '>= 1.9.1'
end
