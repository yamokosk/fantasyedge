function WriteFFToExcel(wk)

% Load data
[pdata,ddata] = LoadFFData(wk);

% Calculate scenarios
scenarios = ProcessPlayerData(pdata,ddata);
scenarioMatrix = cell2mat( struct2cell( scenarios ) );

np = size(scenarioMatrix,1);    % Total number of players
nqb = length(pdata.qb.Name);    % Number of qb
nrb = length(pdata.rb.Name);    % Number of rb
nwr = length(pdata.wr.Name);    % Number of wr
nte = length(pdata.te.Name);    % Number of te
nk = length(pdata.k.Name);      % Number of k
ndef = length(pdata.def.Name);  % Number of def 
ns = size(scenarioMatrix,2);    % Number of scenarios
pk = repmat(1/ns,ns,1);         % Scenario probabilities
f = mean(scenarioMatrix, 2);    % Expected projected performance

% Cost of the players
cost = [pdata.qb.Price; pdata.rb.Price; pdata.wr.Price; pdata.te.Price; pdata.k.Price; pdata.def.Price];

% Guess
xguess = zeros(np, 1);

% Write to excel file
filename = ['ffdata_wk' num2str(wk) '.xls'];
xlswrite(filename, {'Vars', 'Cost', 'Coeff', 'Scenarios'});
xlswrite(filename, [xguess, cost, f, scenarioMatrix], 'A20');

% Now, in text, specify the ranges of each data group

