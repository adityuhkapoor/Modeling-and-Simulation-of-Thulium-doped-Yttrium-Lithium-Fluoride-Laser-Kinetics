function efficientMeritValueCalcArray = MeritValCalcArray(x)
    % Assuming x is an array with three elements [a, b, c]
    variedVarValue = x(1); % Use the first element for the original purpose
    pumpPowers = [7.81, 3699.22, 4714.84, 6375.00, 8289.06, 9285.16, 10222.66, 11218.75, 12214.84, 13113.28, 14109.38, 15105.47];
    experimentalGain = [0.15695, 0.36433, 0.45558, 0.64403, 0.82906, 1.00532, 1.09950, 1.35764, 1.65112, 1.91578, 2.34224, 2.67910];
    simulatedGains = [];
    differenceGains = [];
    squareDifferenceGains = [];
    sumOfSquares = 0;

    for i = 1:length(pumpPowers)
        % Assuming SSGainvsEndTimeandIp is another function you have
        gain = SSGainvsEndTimeandIp(pumpPowers(i), 15e-3, 'tau2', variedVarValue); % Now uses x(1)
        simulatedGains = [simulatedGains, gain]; % Append the result to simulatedGains
    end
    
    for j = 1:length(experimentalGain)
        difference = experimentalGain(j) - simulatedGains(j);
        differenceGains = [differenceGains, difference];
    end

    for k = 1:length(differenceGains)
        squareDifference = differenceGains(k) * differenceGains(k);
        squareDifferenceGains = [squareDifferenceGains, squareDifference];
        sumOfSquares = sumOfSquares + squareDifference;
    end

    efficientMeritValueCalcArray = sumOfSquares;
end
