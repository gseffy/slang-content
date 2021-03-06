#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
# Retrieves a list of all the dangling Docker images.
#
# Inputs:
#   - docker_options - optional - options for the docker environment - from the construct: docker [OPTIONS] COMMAND [arg...]
#   - host - Docker machine host
#   - port - optional - SSH port
#   - username - Docker machine username
#   - password - Docker machine password
#   - privateKeyFile - optional - path to the private key file
#   - arguments - optional - arguments to pass to the command
#   - characterSet - optional - character encoding used for input stream encoding from target machine - Valid: SJIS, EUC-JP, UTF-8
#   - pty - optional - whether to use PTY - Valid: true, false
#   - timeout - optional - time in milliseconds to wait for command to complete - Default: 30000000
#   - closeSession - optional - if false SSH session will be cached for future calls during the life of the flow, if true the SSH session used will be closed; Valid: true, false
#   - agent_forwarding - optional - whether to forward the user authentication agent
# Outputs:
#   - dangling_image_list - list of names of dangling Docker images
# Results:
#   - SUCCESS
#   - FAILURE
####################################################

namespace: io.cloudslang.docker.images

imports:
  ssh: io.cloudslang.base.remote_command_execution.ssh

flow:
  name: get_dangling_images
  inputs:
    - docker_options:
        required: false
    - docker_options_expression:
        default: docker_options + ' ' if bool(docker_options) else ''
        overridable: false
    - host
    - port:
        required: false
    - username
    - password:
        required: false
    - privateKeyFile:
         required: false
    - command:
        default: >
          "docker " + docker_options_expression + "images -f \"dangling=true\""
        overridable: false
    - arguments:
        required: false
    - characterSet:
        required: false
    - pty:
        required: false
    - timeout:
        default: "'30000000'"
        required: false
    - closeSession:
        required: false
        required: false
    - agentForwarding:
        required: false

  workflow:
    - get_images:
        do:
          ssh.ssh_flow:
            - host
            - port:
                required: false
            - username
            - password:
                required: false
            - privateKeyFile:
                required: false
            - command
            - arguments:
                required: false
            - characterSet:
                required: false
            - pty:
                required: false
            - timeout:
                required: false
            - closeSession:
                required: false
            - agentForwarding:
                required: false
        publish:
          - dangling_image_list: >
              ' '.join(map(lambda line : line.split()[0] + ':' + line.split()[1], filter(lambda line : line != '', returnResult.split('\n')[1:])))

  outputs:
    - dangling_image_list
