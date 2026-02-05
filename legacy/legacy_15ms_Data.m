% DEPRECATED - This file is retained for historical reference only.
% It has been superseded by the modular code in src/.
% Do not use this file for new work.
% See legacy/README.md for details on what changed and why.
%
% Assumes your data starts from row 2 if row 1 has headers
data = readtable('Pump_Data.xlsx', 'Sheet', '15ms_Pump_Data');

% Correcting the column names to match the modified Excel file's headers
IP_exp_kW = data.PumpPower_kW_;
IP_exp_W = data.PumpPower_W_;
DP_exp = data.Double_PassGain;
SP_exp = data.Single_PassGain;
SP_sim = data.SimulatedSingle_PassGain;
