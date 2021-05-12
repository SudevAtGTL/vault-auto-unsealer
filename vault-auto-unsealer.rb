# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

puts "Starting vault-auto-unsealer."

Signal.trap("TERM") do
  exit
end

if ENV["VAULT_ADDR"].nil?
  abort "Environment variable VAULT_ADDR must be set to the address of the Vault server, e.g. http://127.0.0.1:8200"
else
  puts "Using Vault instance at: #{ENV["VAULT_ADDR"]}"
end

require "vault"

unseal_key = ENV["UNSEAL_KEY"]

if unseal_key.nil? || unseal_key == ""
  abort "Environment variable UNSEAL_KEY must be set to the decrypted Vault unseal key."
end

puts "Entering main control loop. Vault will be checked every 30 seconds and unsealed if it is found sealed."

loop do
  if Vault.sys.seal_status.sealed?
    Vault.sys.unseal(unseal_key)

    puts "Vault has been unsealed."
  end

  sleep 30
end
