# python-pkgs-build-lambda

### Building large python packages for AWS Lambda

This repo contains a `build.sh` script that's intended to be run in an Amazon
Linux docker container, and build numpy, pandas, and scipy for use in AWS
Lambda. For more info about how the script works, and how to use it, see this
[blog post on deploying sklearn to Lambda](https://serverlesscode.com/post/scikitlearn-with-amazon-linux-container/).

There was an older version of this repo, now archived in the
[ec2-build-process](https://github.com/ryansb/sklearn-build-lambda/tree/ec2-build-process)
branch, used an EC2 instance to perform the build process and an Ansible
playbook to execute the build. That version still works, but the new dockerized
version doesn't require you to launch a remote instance.

To build the zipfile, pull the Amazon Linux image and run the build script in
it.

```
$ docker pull amazonlinux:latest
$ docker run -v $(pwd):/outputs -it amazonlinux:latest  /bin/bash /outputs/build.sh
```

That will make a file called `venv.zip` in the local directory that's around
67 MB.

Once you run this, you'll have a zipfile containing scipy, pandas, and numpy, to use them add your handler file to the zip, and add the `lib`
directory so it can be used for shared libs. The minimum viable scipy handler
would thus look like:

```
import os
import ctypes

for d, _, files in os.walk('lib'):
    for f in files:
        if f.endswith('.a'):
            continue
        ctypes.cdll.LoadLibrary(os.path.join(d, f))

import scipy

def handler(event, context):
    # do scipy stuff here
    return {'yay': 'done'}

```

## Extra Packages

To add extra packages to the build, create a `requirements.txt` file alongside
the `build.sh` in this repo. All packages listed there will be installed in
addition to `scipy`, `pandas`, `numpy`, and related dependencies.

## Changes Made

This script was edited to allow us to import our private repos such as [amper-core](https://github.com/ampertech/amper-core). This repository must include `private_key.txt` file including a ssh private key, and here is info on how to [generate a ssh-key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#generating-a-new-ssh-key) and how to [add it to you github profile](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/). The corresponding private_key should be placed in the private_key.txt file where it will be used by docker to access our private repo.

Also the `build.sh` script was updated to use python 3.6 and install git so that we can install packages in requirements.txt.

## Sizing and Future Work

With just compression and stripped binaries, the full sklearn stack weighs in
at 65 MB, and could probably be reduced further by:

1. Pre-compiling all .pyc files and deleting their source
2. Removing test files
3. Removing documentation

For my purposes, 39 MB is sufficiently small, if you have any improvements to
share pull requests or issues are welcome.

Completed optimizations 2 and 3 above by following this [link](https://gist.github.com/CarstVaartjes/77dbe8249d171e592bd17847f7009272#file-fb_prophet_chalice-py-L39). Tried optimization 1 but packages broke down.

## License

This project is MIT Licensed, for license info on the numpy, scipy, and sklearn
packages see their respective sites. Full text of the MIT license is in
LICENSE.txt.

## Created Deployment Packages

1. **venv-3-1-18.zip** - package for state-gen lambda function in covfefe
2. **venv-4-23-18.zip** - package for auto tuner (no longer used)
3. **venv-5-32-18.zip** - package for cycles-gen lambda function in covfefe
