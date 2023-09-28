#!/bin/bash

# User input or some other dynamic data
dynamic_part=""

# Some conditional logic to decide the final directory
if [ "$dynamic_part" == "cst" ]; then
    dir_to_go="./../$dynamic_part"
else
    dir_to_go="~/dropbox/1f.ἡἔρις,κ/1.ontology/"
fi

# Now, we use eval and echo to dynamically generate the directory path
cd $(eval echo $dir_to_go)
jb build git2
