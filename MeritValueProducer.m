function updatedTable = MeritVal(sheetData, endTime, variedVarName, variedVarValue)
    % Calls SimulatedGain with some of the parameters it received and returns the result
    meritValue = SimulatedGain(endTime, variedVarName, variedVarValue);

    if height(sheetData) == height(meritValue)
        % Append the new column to the existing table
        newColumnName = 'simulatedData'; % Change this to your desired column name
        % Ensure that meritValue is a table if it isn't already
        if ~istable(meritValue)
            meritValue = table(meritValue, 'VariableNames', {newColumnName});
        end
        updatedTable = [sheetData, meritValue];
    else
        error('The sizes of the existing table and the new column do not match.');
    end

    

end
