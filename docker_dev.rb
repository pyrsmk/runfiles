VERSION_PATH = "docker/dev/.version"

def image_name
  return "" if !File.exists?(VERSION_PATH)
  "#{docker_dev_image_name}:#{File.read(VERSION_PATH).chomp}"
end

def container_name
  `docker ps -q --filter ancestor=#{image_name}`.chomp
end

def uid
  `id -u`.chomp
end

def gid
  `id -g`.chomp
end

task :docker_dev_build do
  if !File.exists?(VERSION_PATH)
    call :docker_dev_image_update
    return
  end
  if !system("docker image inspect #{image_name} >/dev/null")
    shell "docker build -t #{image_name} docker"
  end
end

task :docker_dev_image_update do
  call :docker_dev_stop
  old_version = File.read(VERSION_PATH).chomp if File.exists?(VERSION_PATH)
  File.write(VERSION_PATH, SecureRandom.hex)
  begin
    shell "docker build -t #{image_name} docker"
  rescue
    return if old_version.nil?
    puts
    puts "The image build failed: rollback to the previous version.".colorize(:red)
    File.write(VERSION_PATH, old_version)
  end
end

task :docker_dev_start, "Start the dev container." do
  if container_name == ""
    call :docker_dev_build
    shell docker_dev_start_command
    puts
  end
end

task :docker_dev_stop, "Stop the dev container." do
  if container_name != ""
    puts
    puts "Stopping the container...".colorize(:yellow)
    `docker stop #{container_name}`
  end
end

task :docker_dev_fix_rights, "Fix rights issues." do
  puts
  message = "Please enter your sudo password if requested. It is to fix permissions\n" + \
            "on files modified from the docker container."
  puts message.colorize(:yellow)
  `sudo chown -R #{uid}:#{gid} .`
end
