function updatedTable = MeritVal(sheetData, endTime, variedVarName, variedVarValue)
    % Calls SimulatedGain with some of the parameters it received and returns the result
    meritValue = SimulatedGain(endTime, variedVarName, variedVarValue);

    if height(sheetData) == height(meritValue)
        % Append the new column to the existing table
        newColumnName = 'SimulatedData'; % Change this to your desired column name
        % Ensure that meritValue is a table if it isn't already
        if ~istable(meritValue)
            meritValue = table(meritValue, 'VariableNames', {newColumnName});
        end
        updatedTable = [sheetData, meritValue];
    else
        error('The sizes of the existing table and the new column do not match.');
    end

    % Assuming columns 4 and 6 exist, calculate the squared differences
    % Column 4 - existing data, Column 6 - new simulated data
    % Ensure columns are properly referenced; adjust indices/names as necessary
    squaredDifferences = (updatedTable.(4) - updatedTable.(6)).^2;
    
    % Add the new column to the table
    updatedTable.SquaredDifferences = squaredDifferences; % Add this as the new 7th column
end
