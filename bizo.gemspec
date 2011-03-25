Gem::Specification.new do |spec|
  spec.name ="Bizo"
  spec.version = "0.0.4"
  spec.summary = "A simple wrapper around the Bizo API"
  spec.authors = ["Joshua Carver"]
  spec.email = "josh@bizo.com"
  spec.executables = []
  spec.has_rdoc = false
  spec.require_paths = ["lib"]
  spec.files = []
  spec.files += Dir.glob "lib/**/*"

  spec.add_dependency "oauth"
  spec.add_dependency "json"
end
