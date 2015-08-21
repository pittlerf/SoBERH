# Small bash script to tar eigensystems in packages of configurations
#!/bin/bash

# Set the parameters
# Lattice name
ens=A40.24
hyp_smearing=062_058_3
add=

# Config range as line numbers from conf_lst.txt, DST is the usual distance
# between configs
BGN=81
END=109
DST=4

# get all configs in between range into one file
sed -n ${BGN},${END}p conf_list.txt > conf_range.txt

#naming stuff all between line 1 and 21
C1=$(sed -n 1p conf_range.txt)
C2=$(sed -n 29p conf_range.txt)
## Setting target path for archive and rsync destination
ARC=/hiskp2/helmes/eigsys_vault # tar locally and then rsync to juelich archive
HOST=judac.fz-juelich.de
SNC=/arch/hch02/hch026/helmes/eigensystems/${ens}
SRC=${ARC}/eigensys_${C1}-${DST}-${C2}.tar
## Now we want to tar everything in the range list into one specific tar archive
# source of the eigensystems
EIGS=/hiskp2/eigensystems/A40.24_L24_T48_beta190_mul0040_musig150_mudel190_kappa1632700/hyp_062_058_3/nev_120
echo "-C$EIGS" > file_list.txt
for n in $(cat conf_range.txt); do
  for t in {000..047}; do
    echo eigenvectors.$n.$t >> file_list.txt 
    echo eigenvalues.$n.$t >> file_list.txt 
    echo phases/phases.$n.$t >> file_list.txt
  done
done
tar cvf ${SRC} --wildcards --files-from file_list.txt

# Rsync eigensystem archive to destination
rsync  ${SRC} hch026@${HOST}:${SNC}
# Tidy up!
rm file_list.txt
rm conf_range.txt
