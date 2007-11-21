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
names = [pdata.qb.Name; pdata.rb.Name; pdata.wr.Name; pdata.te.Name; pdata.k.Name; pdata.def.Name];

% Guess
xguess = zeros(np, 1);

% Write to excel file
filename = ['ffdata_wk' num2str(wk) '.xls'];

off = 12;
VarsRange = ['B' num2str(off) ':B' num2str(off+np-1)];
CostRange = ['C' num2str(off) ':C' num2str(off+np-1)];
CoeffRange = ['D' num2str(off) ':D' num2str(off+np-1)];
nqbRange = ['B' num2str(off) ':B' num2str(off+nqb-1)];
nrbRange = ['B' num2str(off+nqb) ':B' num2str(off+nqb+nrb-1)];
nwrRange = ['B' num2str(off+nqb+nrb) ':B' num2str(off+nqb+nrb+nwr-1)];
nteRange = ['B' num2str(off+nqb+nrb+nwr) ':B' num2str(off+nqb+nrb+nwr+nte-1)];
nkRange = ['B' num2str(off+nqb+nrb+nwr+nte) ':B' num2str(off+nqb+nrb+nwr+nte+nk-1)];
ndefRange = ['B' num2str(off+nqb+nrb+nwr+nte+nk) ':B' num2str(off+nqb+nrb+nwr+nte+nk+ndef-1)];
xlswrite(filename, {'VarsRange', off-1, 1, np, 1; 
                    'CostRange', off-1, 2, np, 1; 
                    'CoeffRange', off-1, 3, np, 1; 
                    'QB', off-1, 1, nqb, 1; ...
                    'RB', nqb+off-1, 1, nrb, 1; ...
                    'WR', nqb+nrb+off-1, 1, nwr, 1; ...
                    'TE', nqb+nrb+nwr+off-1, 1, nte, 1; ...
                    'K',  nqb+nrb+nwr+nte+off-1, 1, nk, 1; ...
                    'DEF', nqb+nrb+nwr+nte+nk+off-1, 1, ndef, 1}, 'Data', 'C1');
xlswrite(filename, {'Names', 'Vars', 'Cost', 'Coeff', 'Scenarios'}, 'Data', 'A11');
xlswrite(filename, names, 'Data', 'A12');
xlswrite(filename, [xguess, cost, f, scenarioMatrix], 'Data', 'B12');

% Now, in text, specify the ranges of each data group

