% Define the input powers (in Watts)
Ip_W_array = [7.81, 3699.22, 4714.84, 6375.00, 8289.06, 9285.16, 10222.66, 11218.75, 12214.84, 13113.28, 14109.38, 15105.47];

% Define a constant end time (in seconds)
endTime = 15e-3;

% Initialize arrays to store the calculated steady-state gains
SSGains = zeros(1, length(Ip_W_array));
SSGainsPreCurve = zeros(1, length(Ip_W_array));

% Loop through each input power, compute the gain with new constants, and store it
for i = 1:length(Ip_W_array)
    SSGains(i) = SSGainvsEndTimeandIpNewConstants(Ip_W_array(i), endTime);
    SSGainsPreCurve(i) = SSGainvsEndTimeandIp(Ip_W_array(i), endTime);  % Call the original function
end

% Experimental gains provided
experimentalGain = [0.15695, 0.36433, 0.45558, 0.64403, 0.82906, 1.00532, 1.09950, 1.35764, 1.65112, 1.91578, 2.34224, 2.67910];

% Calculate MSE for pre-curve and post-curve
MSE_PreCurve = mean((SSGainsPreCurve - experimentalGain).^2);
MSE_PostCurve = mean((SSGains - experimentalGain).^2);

% Calculate the percentage improvement in MSE
Improvement_Percent = ((MSE_PreCurve - MSE_PostCurve) / MSE_PreCurve) * 100;

% Display the MSE and improvement
fprintf('MSE Pre-Curve Fitting: %.4f\n', MSE_PreCurve);
fprintf('MSE Post-Curve Fitting: %.4f\n', MSE_PostCurve);
fprintf('Improvement in MSE: %.2f%%\n', Improvement_Percent);

% Plot the input powers against the calculated steady-state gains and experimental gains
figure; % Creates a new figure window
plot(Ip_W_array, SSGains, '-o', 'DisplayName', 'Simulated Gains (Post-Curve Fitting)'); % Plots the gains with updated constants with markers
hold on; % Hold on to plot multiple datasets on the same graph
plot(Ip_W_array, SSGainsPreCurve, '-s', 'DisplayName', 'Simulated Gains (Pre-Curve Fitting)'); % Plots the original simulated gains with different markers
plot(Ip_W_array, experimentalGain, '-x', 'DisplayName', 'Experimental Gains'); % Plots the experimental gains
xlabel('Input Power (Watts)'); % Label the x-axis
ylabel('Gain'); % Label the y-axis
title('Comparison of Experimental and Simulated Gains'); % Give the plot a title
legend show; % Show the legend to distinguish plots
grid on; % Turn on the grid for easier visualization
