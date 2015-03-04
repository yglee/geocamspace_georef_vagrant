#!/bin/sh

# make a fresh git checkout in a folder that will be shared with the VM
if [ ! -d geoRef ]; then
  git clone --recursive https://babelfish.arc.nasa.gov/git/geocam_space
  (cd geoRef && git submodule foreach git checkout master)
fi

vagrant up  # create VM. download xgds_base.box if needed.
vagrant provision  # first pass to fix hostname problem
vagrant reload  # reload so fix takes effect
vagrant provision  # finish provisioning

# copy user's ~/.gitconfig script into VM for convenience
if [ -f $HOME/.gitconfig -a ! -f build/git-config-copied ]; then
  vagrant ssh-config > build/vagrant-ssh-config
  scp -F build/vagrant-ssh-config $HOME/.gitconfig default: && touch build/git-config-copied
fi

set +o verbose
echo unless there were errors you should have a working geoRef instance.
echo point your browser at http://10.0.3.18/
