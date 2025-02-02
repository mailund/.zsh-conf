# Aliases #######################################

## Alias for displaying dot files in iTerm
alias idot="dot -Tpng -Gbgcolor=black -Nfontcolor=white -Nfontsize=26 -Efontcolor=white -Efontsize=26 -Ncolor=white -Ecolor=white | imgcat"
alias wdot="dot -Tpng -Gbgcolor=black -Nfontcolor=white -Nfontsize=26 -Efontcolor=white -Efontsize=26 -Ncolor=white -Ecolor=white | open -f -a Preview"

# Alias for ssh'ing into the building box on EC2
alias buildbox="ssh -i ~/.ssh/mailunds_building_box.pem ubuntu@ec2-52-49-70-204.eu-west-1.compute.amazonaws.com"

