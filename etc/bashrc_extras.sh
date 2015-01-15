
######################################################################
# puppet will get append this code section to the default .bashrc of
# user 'vagrant' in the vagrant-managed VM.

# 'ls' is a pain to type in dvorak
alias e=ls

# set up environment for xgds_mvp development
if [ -f $HOME/xgds_mvp/sourceme.sh ]; then
  source $HOME/xgds_mvp/sourceme.sh
fi
