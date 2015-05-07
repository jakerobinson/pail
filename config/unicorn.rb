# set path to app that will be used to configure unicorn,
# note the trailing slash in this example

worker_processes 2

timeout 30

# Specify path to socket unicorn listens to,
# we will use this in our nginx.conf later
listen "/tmp/pail.sock", :backlog => 64

# Set process id path
pid "/tmp/pail.pid"

# Set log file paths
stderr_path "/var/log/pail.err"
stdout_path "/var/log/pail.log"
