module EnvVariableHelper
  RSpec.configure do |config|
    config.include self
  end

  def with_env_var(name, value)
    value_bofre, ENV[name] = ENV[name], value
    yield
    ENV[name] = value_bofre
  end
end


