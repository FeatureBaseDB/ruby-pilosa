require 'rake/testtask'

Rake::TestTask.new(:test) do |t| 
  t.libs << "test"
  t.libs << "lib"
end

task :generate do
  sh "protoc", "--proto_path=etc", "--ruby_out=lib/pilosa/proto", "etc/public.proto"
end

task :default => :test
