inputs: with inputs; free.mkShell {
buildInputs = with free; [

  cointop                   # crypto tracker
#Mstonks                    # stocks tracker - in Arch Repos only, atm

];
#}

];

}
