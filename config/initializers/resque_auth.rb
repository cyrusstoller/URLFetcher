Resque::Server.use(Rack::Auth::Basic) do |user, password|
  user == ENV["ADMIN_USER"] && password == ENV["ADMIN_PASSWORD"]
end