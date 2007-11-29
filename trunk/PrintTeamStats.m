function PrintTeamStats(y,pdata,pndata,alpha,pk,smatrix)

np = size(scenarioMatrix,1);    % Total number of players
nqb = length(pdata.qb.Name);    % Number of qb
nrb = length(pdata.rb.Name);    % Number of rb
nwr = length(pdata.wr.Name);    % Number of wr
nte = length(pdata.te.Name);    % Number of te
nk = length(pdata.k.Name);      % Number of k
ndef = length(pdata.def.Name);  % Number of def 

% Get actual player results
pdata = CalcFuturePts(pdata, pndata);

% Pull out variables from y
VaR = y(1);
zk = y(2:ns+1);
x = y(ns+2:end);

% Calculate team stats
CVaR = VaR + inv(1-alpha)*pk'*zk;
ffa = w_actual' * x;
ffp = w_bar' * x;

ind = find(x == 1);
fprintf('\nVaR(%.1f): %g\n', beta*100, Result.x_k(1));
fprintf('\nZs: [%f, %f, ... , %f, %f]\n', Result.x_k(2), Result.x_k(3), Result.x_k(9), Result.x_k(10));
fprintf('\nFopt: %g\n', Result.f_k);
fprintf('\nOptimal fantasy team.\n');
fprintf('QB : %s - %3.1f (%f3.1), $%4.2f\n', pdata.qb.Name{ind(1)}, w_bar(ind(1)), pdata.qb.Actual(ind(1)), pdata.qb.Price(ind(1)));
fprintf('RB1: %s - %3.1f (%f3.1), $%4.2f\n', pdata.rb.Name{ind(2)}, w_bar(ind(2)), pdata.qb.Actual(ind(2)), pdata.qb.Price(ind(2)));
fprintf('RB2: %s - %3.1f (%f3.1), $%4.2f\n', pdata.rb.Name{ind(3)}, w_bar(ind(3)), pdata.qb.Actual(ind(3)), pdata.qb.Price(ind(3)));
fprintf('WR1: %s - %3.1f (%f3.1), $%4.2f\n', pdata.wr.Name{ind(4)}, w_bar(ind(4)), pdata.qb.Actual(ind(4)), pdata.qb.Price(ind(4)));
fprintf('WR2: %s - %3.1f (%f3.1), $%4.2f\n', pdata.wr.Name{ind(5)}, w_bar(ind(5)), pdata.qb.Actual(ind(5)), pdata.qb.Price(ind(5)));
fprintf('WR3: %s - %3.1f (%f3.1), $%4.2f\n', pdata.wr.Name{ind(6)}, w_bar(ind(6)), pdata.qb.Actual(ind(6)), pdata.qb.Price(ind(6)));
fprintf('TE : %s - %3.1f (%f3.1), $%4.2f\n', pdata.te.Name{ind(7)}, w_bar(ind(7)), pdata.qb.Actual(ind(7)), pdata.qb.Price(ind(7)));
fprintf('K  : %s - %3.1f (%f3.1), $%4.2f\n', pdata.k.Name{ind(8)}, w_bar(ind(8)), pdata.qb.Actual(ind(8)), pdata.qb.Price(ind(8)));
fprintf('DEF: %s - %3.1f (%f3.1), $%4.2f\n', pdata.def.Name{ind(9)}, w_bar(ind(9)), pdata.qb.Actual(ind(9)), pdata.qb.Price(ind(9)));
fprintf('---------------------------------------------------\n');
fprintf('RB1: %s (%f,%f,%f), %s (%f)\n', pdata.rb.Name{ind(2)-nqb}, pdata.rb.Name{ind(3)-nqb});
fprintf('WR: %s (%f), %s (%f), %s\n', pdata.wr.Name{ind(4)-nqb-nrb}, pdata.wr.Name{ind(5)-nqb-nrb}, pdata.wr.Name{ind(6)-nqb-nrb});
fprintf('TE: %s\n', pdata.te.Name{ind(7)-nqb-nrb-nwr});
fprintf('K: %s\n', pdata.k.Name{ind(8)-nqb-nrb-nwr-nte});
fprintf('DEF: %s\n', pdata.def.Name{ind(9)-nqb-nrb-nwr-nte-nk});
% fprintf('\t---------\n');
fprintf('\tPts: %g\tCost: %g\n\n', w_bar'*xopt, c'*xopt);
