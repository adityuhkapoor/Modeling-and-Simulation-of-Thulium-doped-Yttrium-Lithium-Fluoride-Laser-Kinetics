function simulatedGains = SimulatedGain(endTime, variedVarName, variedVarValue)
    if nargin > 1 % Check if more than two input arguments are passed
    end
    % Array of PumpPower_W_ values
    pumpPowers = [7.81, 3699.22, 4714.84, 6375.00, 8289.06, 9285.16, 10222.66, 11218.75, 12214.84, 13113.28, 14109.38, 15105.47];
    
    % Array to store the simulated Single_PassGain values
    simulatedGains = zeros(length(pumpPowers), 1);
    
    % Loop over each PumpPower_W_ value
    for i = 1:length(pumpPowers)
        % Call your simulation function
        if nargin > 1
            simulatedGains(i) = SSGainvsEndTimeandIp(pumpPowers(i), endTime, variedVarName, variedVarValue);
        elseif nargin == 1
            simulatedGains(i) = SSGainvsEndTimeandIp(pumpPowers(i), endTime);

    end
    
    % Return the array of simulated gains
    % No need for a separate return statement as the variable is returned automatically
end
