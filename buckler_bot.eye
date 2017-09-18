require 'socket'
require 'timeout'

USER = 'deploy'.freeze
BUCKLER_APP_DIR = '/home/deploy/buckler_bot/current'.freeze

Eye.app :buckler_bot do
  stop_on_delete true
  trigger :flapping, times: 10, within: 1.minute

  group 'elixir_release' do
    env 'TELEGRAM_TOKEN' => TELEGRAM_TOKEN
    chain action: :restart, grace: 30.seconds

    stdall '/tmp/trash.log'

    %w[8080 8081].each do |port|
      process "buckler_bot-#{port}" do
        pid_file "tmp/buckler_bot_#{port}.pid"
        daemonize true

        start_command "/bin/su - #{USER} -c \"cd #{BUCKLER_APP_DIR}/rel/buckler_bot/bin && PORT=#{port} DB_NAME=buckler TELEGRAM_TOKEN=#{TELEGRAM_TOKEN} REPLACE_OS_VARS=true NODENAME=master_node_#{port} ./buckler_bot foreground\""

        stop_signals [:QUIT, 3.seconds, :KILL]

        restart_command "/bin/su - #{USER} -c \"cd #{BUCKLER_APP_DIR}/rel/buckler_bot/bin && PORT=#{port} DB_NAME=buckler TELEGRAM_TOKEN=#{TELEGRAM_TOKEN} REPLACE_OS_VARS=true NODENAME=master_node_#{port} ./buckler_bot stop\""

        restart_grace 10.seconds
      end
    end
  end
end
