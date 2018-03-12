require 'rake/testtask'

task default: :test

Rake::TestTask.new do |t|
  t.test_files = Dir.glob("#{__dir__}/test/test_*.rb").reject{|x| x.match('test_helper.rb')}
  t.warning = false
end
