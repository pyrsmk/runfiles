# Runfiles

A set of useful Runfile recipes aimed to be used with [Run](https://github.com/pyrsmk/run).

## How to use

Add the interesting file in your Runfile with:

```rb
require_remote "some_file.rb"
```

## Runfiles

### docker_dev

This recipe adds docker development container management with the following tasks:

- `console`: opens a shell session inside the container
- `docker_dev_start`: starts the container if not yet started; this task runs `docker_dev_build` automatically
- `docker_dev_stop`: stops the container if not stopped
- `docker_dev_fix_rights`: fix owner permissions in the current directory recursively (useful when your commands are run by root in your container, which is often the case)
- `docker_dev_build`: builds the image if it does not exist yet, or rebuilds it when called manually; on rebuild it updates the `docker/dev/.version` which will force the rebuild any person in the team

To use theses tasks, you need to define two functions in your Runfile:

- `docker_dev_image_name`: returns the name you want for your image; the current version of the image will be appended to that name and the full image name will be available from `image_name` function
- `docker_dev_start_command`: returns the command to use to start the container

For example:

```rb
def docker_dev_image_name
  "namespace/project"
end

def docker_dev_start_command
  shell "docker run -d -p 4000:4000 -v #{Dir.pwd}:/app -t #{image_name}"
end
```

You can also access the computed docker container name from `container_name` function. It is needed by several commands like `docker exec`.

As seen above, the advised folder hierarchy should be as follow:

```
|
-- docker/
  |
  -- dev/: the files for the development Dockerfile
    |
    -- .version: the version of the current dev image
  |
  -- prod/: the files for the production Dockerfile
  |
  -- Dockerfile: the development Dockerfile
|
-- Dockerfile: tThe production Dockerfile
```
