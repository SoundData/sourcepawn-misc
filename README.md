sourcepawn-misc
===============

On Windows:
Take the key from the Groupme, load it into Pageant and connect to the server ip `104.236.52.206`. When asked who you want to login as, type `steam`. PuTTY should automatically authenticate you.

On Mac:
Start ssh-agent by running `eval "$(ssh-agent -s)"` followed by `ssh-add /path/to/rsa/key/keyfile.ppk`. Then ssh into the server by running `ssh steam@104.236.52.206`. ssh should automatically authenticate you with the key.


Updating the server
-------------------
`cd` to the git directory containing the files:
`cd ~/sourcemod-misc-stuff/sourcepawn-misc`
Update the repo:
`git pull`
Rebuild the plugins:
`cd $SCRIPTINGDIR`
`./build_plugin.sh`
Restart the server:
`cd $TF2SERVERDIR`
`./start_server.sh`
