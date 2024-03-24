% Calculate the residuals (differences between experimental and simulated single-pass gains)
residuals = SP_exp - SP_sim;

% Compute the merit function as the sum of squares of the residuals
meritValue = sum(residuals .^ 2);

% Display the merit value
disp(['Merit Value for 15 ms: ', num2str(meritValue)]);
