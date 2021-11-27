# Archery_EMG_processing
utilize staging file to automatic processing sEMG data

This code are seperate in two part

The first step is to pre processing EMG data
1. band pass filting
2. retifiy data
3. linear envelop processing (low pass filting)

The second part is to utilize staging file to capture specific frame, and staging file is maked by Manual interpretation

Due to sEMG data missing, therefore we need to double check sEMG data from specific muscle group individually

That is why I using branching command to find complete information
