require_relative 'lib/peatio/ndc/version'

Gem::Specification.new do |spec|
  spec.name          = "peatio-ndc"
  spec.version       = Peatio::Ndc::VERSION
  spec.authors       = ["Md Tanvir Rahaman"]
  spec.email         = ["tanvirtex@gmail.com"]

  spec.summary       = %q{Peatio Blockchain Gem for NDC Wallet.}
  spec.description   = %q{Peatio Blockchain Plugin for easy integration of NDC Wallet Blockchain platform.}
  spec.homepage      = "https://ndcwallet.pro."
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ndcwallet/peatio-ndc"
  spec.metadata["changelog_uri"] = "https://github.com/ndcwallet/peatio-ndc/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 5.2.3"
  spec.add_dependency "better-faraday", "~> 1.0.5"
  spec.add_dependency "faraday", "= 0.15.4"
  spec.add_dependency "memoist", "~> 0.16.0"
  spec.add_dependency "peatio", "~> 2.4"
  spec.add_dependency 'net-http-persistent', '~> 3.0.1'

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "irb"
  spec.add_development_dependency "mocha", "~> 1.8"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop-github"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock", "~> 3.5"
end
