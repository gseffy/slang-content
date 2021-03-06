# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
# The Apache License is available at
# http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
# Workflow to test docker get_all_images operation.
#
# Inputs:
#   - host - Docker machine host
#   - port - Docker machine port
#   - username - Docker machine username
#   - password - Docker machine password
#   - image_name - Docker image name to inspect
#
# Results:
#   - SUCCESS - get_all_images performed successfully
#   - FAILURE - get_all_images finished with an error
#   - DOWNLOAD_FAILURE - prerequest error - could not download dockerimage
#   - VERIFY_FAILURE - fails ro verify downloaded images
#   - DELETE_FAILURE - fails to delete downloaded image
#   - MACHINE_IS_NOT_CLEAN - prerequest fails - machine is not clean
#
####################################################
namespace: io.cloudslang.docker.images

imports:
  images: io.cloudslang.docker.images
  strings: io.cloudslang.base.strings
  linux: io.cloudslang.base.os.linux
  maintenance: io.cloudslang.docker.maintenance


flow:
  name: test_inspect_image
  inputs:
    - host
    - port:
        required: false
    - username
    - password
    - image_name
  workflow:
    - clear_docker_host_prereqeust:
         do:
           maintenance.clear_docker_host:
             - docker_host: host
             - port:
                 required: false
             - docker_username: username
             - docker_password: password
         navigate:
           SUCCESS: pull_image
           FAILURE: MACHINE_IS_NOT_CLEAN

    - pull_image:
        do:
          images.pull_image:
            - host
            - port
            - username
            - password
            - image_name
        navigate:
          SUCCESS: inspect_image
          FAILURE: DOWNLOAD_FAILURE

    - inspect_image:
        do:
          images.inspect_image:
            - host
            - port
            - username
            - password
            - image_name
        publish:
            - standard_out
        navigate:
          SUCCESS: verify_output
          FAILURE: FAILURE

    - verify_output:
        do:
          strings.string_occurrence_counter:
            - string_in_which_to_search: standard_out
            - string_to_find: "'/hello'"
        navigate:
          SUCCESS: clear_after
          FAILURE: VERIFY_FAILURE

    - clear_after:
        do:
          images.clear_docker_images:
            - host
            - port
            - username
            - password
            - images: image_name
        navigate:
          SUCCESS: SUCCESS
          FAILURE: DELETE_FAILURE

  results:
    - SUCCESS
    - FAILURE
    - DOWNLOAD_FAILURE
    - VERIFY_FAILURE
    - DELETE_FAILURE
    - MACHINE_IS_NOT_CLEAN
    - FAIL_VALIDATE_SSH
    - FAIL_GET_ALL_IMAGES_BEFORE
