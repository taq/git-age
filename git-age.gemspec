require_relative 'lib/git/age/version'

Gem::Specification.new do |spec|
  spec.name          = "git-age"
  spec.version       = Git::Age::VERSION
  spec.authors       = ["Eustaquio Rangel"]
  spec.email         = ["taq@eustaquiorangel.com"]

  spec.summary       = %q{Create a CSV file with line year and month from your Git repository}
  spec.description   = %q{Check all the repository files lines dates and group it by year and month, allowing check how old code is still in use}
  spec.homepage      = "https://github.com/taq/git-age"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/taq/git-age"
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables << "git-age"
  spec.require_paths = ["lib"]

  spec.signing_key = '/home/taq/.gemcert/gem-private_key.pem'
  spec.cert_chain   = ['gem-public_cert.pem']
end
