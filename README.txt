This folder contains the analysis pipeline for the manuscript "Are they calling my name? Attention capture is reflected in the neural tracking of attended and ignored speech" (under review, link will be added upon publication).

The corresponding dataset can be found in the OpenNeuro repository 10.18112/openneuro.ds003516.v1.1.0.

To replicate the analysis, folow these steps

1) Download all scripts into one folder.
2) Download the BIDS dataset from 10.18112/openneuro.ds003516.v1.1.0 into a folder that is on the same level as the folder containing the scripts. 
3) Download EEGLAB v13.6.5b and add the respective path within bjh_main_00_BIDS.m. 
4) Download the EEGLAB plugins ICLabel1.2.5, TBT2.5.0, and Viewprops1.5.4 into the plugin folder of EEGLAB v13.6.5b.
4) Within bjh_main_00_BIDS.m specify the name of the folder in which you downloaded the data (BIDS_dataset_folder).
5) Run bjh_main_00_BIDS.m from within the folder containing all scripts. As a result, a folder called analysis will be created on the same level as the data and script folder in which intermediate data and figures will be stored (the intermediate data will amount to 50 GB).

Within bjh_main_00_BIDS.m you can specify the string variable run_mode. Initially, it is set to "reproduce". This will use the ICA decomposed data and reject the components which we identified as artefactual. If you want to run the ICA anew and select artfectual components yourself, you have to change run_mode to "new".

If there are any remaining questions do not hesitate to contact me at bjoern.holtze[at]uol.de.