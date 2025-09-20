desc "Run all CI checks locally"
task :ci do
  puts "🔍 Running all CI checks..."

  puts "\n1. 🔒 Security scan (Ruby dependencies)"
  system("bin/brakeman --no-pager") || abort("❌ Brakeman security scan failed")

  puts "\n2. 🔒 Security scan (JS dependencies)"
  system("bin/importmap audit") || abort("❌ Importmap audit failed")

  puts "\n3. 🎨 Linting code style"
  system("bin/rubocop") || abort("❌ RuboCop linting failed")

  puts "\n4. 🧪 Running tests"
  system("bin/rails db:test:prepare") || abort("❌ Test database setup failed")
  system("bin/rails test") || abort("❌ Unit/integration tests failed")
  system("bin/rails test:system") || abort("❌ System tests failed")

  puts "\n✅ All CI checks passed!"
end
