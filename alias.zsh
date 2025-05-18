# Aliases #######################################

## Alias for displaying dot files inline
alias idot="dot -Tpng -Gbgcolor=black -Nfontcolor=white -Nfontsize=26 -Efontcolor=white -Efontsize=26 -Ncolor=white -Ecolor=white | imgcat"

# Alias for ssh'ing into the building box on EC2
alias buildbox="ssh -i ~/.ssh/mailunds_building_box.pem ubuntu@ec2-52-49-70-204.eu-west-1.compute.amazonaws.com"
alias gpubox="ssh -i ~/.ssh/mailunds_building_box.pem ubuntu@ec2-108-128-166-157.eu-west-1.compute.amazonaws.com"
alias biggpubox="ssh -i ~/.ssh/mailunds_building_box.pem ubuntu@ec2-18-200-110-124.eu-west-1.compute.amazonaws.com"
