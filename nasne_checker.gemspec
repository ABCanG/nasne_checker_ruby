# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nasne_checker/version'

Gem::Specification.new do |spec|
  spec.name          = 'nasne_checker'
  spec.version       = NasneChecker::VERSION
  spec.authors       = ['ABCanG']
  spec.email         = ['abcang1015@gmail.com']

  spec.summary       = 'A tool to check resavation on nasne and post to slack.'
  spec.description   = 'A tool to check resavation on nasne and post to slack.'
  spec.homepage      = 'https://github.com/ABCanG/nasne_checker_ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 0.9.2'
  spec.add_dependency 'faraday_middleware-multi_json', '~> 0.0.6'
  spec.add_dependency 'parse-cron', '~> 0.1.4'
  spec.add_dependency 'slack-poster', '~> 2.2.0'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
