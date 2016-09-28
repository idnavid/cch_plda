cat ~/Downloads/SwitchBoard2/Phase2/DVD1/doc/callinfo.tbl | cut -d ',' -f 1,3,4 | head -n 2000 > data/trn_list
cat ~/Downloads/SwitchBoard2/Phase2/DVD1/doc/callinfo.tbl | cut -d ',' -f 1,3,4 | tail -n 500 > data/tst_list
