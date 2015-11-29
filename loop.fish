#!/usr/bin/fish
while true;
    read -l CONT
    if (echo $CONT)
        mix run -e 'TP.ref'
    else
        exit
    end
end
