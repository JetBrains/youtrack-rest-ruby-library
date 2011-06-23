require "rubygems"
require "rake"
require "rake/gempackagetask"

spec = Gem::Specification.new do |s|
  s.name = "youtrack_api"
  s.version = "0.0.1"
  s.author = "Anna Zhdan"
  s.email = "anna.zhdan@gmail.com"
  s.homepage = "https://github.com/anna239/youtrack-rest-ruby-library"
  s.platform = Gem::Platform::RUBY
  s.summary = "Ruby wrapper around YpuTrack REST api"
  s.files = FileList["{bin,lib}/**/*"].to_a
  s.extra_rdoc_files = ["README"]
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end