function PrintTeamStats(y,pdata,week,alpha,f,pk,scenarioMatrix)

[np,ns] = size(scenarioMatrix);    % Total number of players
nqb = length(pdata.qb.Name);    % Number of qb
nrb = length(pdata.rb.Name);    % Number of rb
nwr = length(pdata.wr.Name);    % Number of wr
nte = length(pdata.te.Name);    % Number of te
nk = length(pdata.k.Name);      % Number of k
offset = [0; -nqb; -nqb; -nqb-nrb; -nqb-nrb; -nqb-nrb; -nqb-nrb-nwr; -nqb-nrb-nwr-nte; -nqb-nrb-nwr-nte-nk];

% Get actual player results
pdata = CalcFuturePts(pdata, week);
w_bar = scenarioMatrix*pk;
c = [pdata.qb.Price; pdata.rb.Price; pdata.wr.Price; pdata.te.Price; pdata.k.Price; pdata.def.Price];
w_actual = [pdata.qb.Actual; pdata.rb.Actual; pdata.wr.Actual; pdata.te.Actual; pdata.k.Actual; pdata.def.Actual];

% Pull out variables from y
VaR = y(1);
zk = y(2:ns+1);
x = y(ns+2:end);

% Calculate team stats
CVaR = VaR + inv(1-alpha)*pk'*zk;
ffp = w_bar' * x;
cost = c'*x;
ind = find(x == 1);
ptr = ind + offset;
ffa = sum(w_actual(ind));

fprintf('\nOptimal fantasy team.\n');
fprintf('QB \t%s \t%3.2f\t%3.2f\t$%4.2f\n', pdata.qb.Name{ptr(1)}, w_bar(ind(1)), pdata.qb.Actual(ptr(1)), pdata.qb.Price(ptr(1)) );
fprintf('RB1\t%s \t%3.2f\t%3.2f\t$%4.2f\n', pdata.rb.Name{ptr(2)}, w_bar(ind(2)), pdata.rb.Actual(ptr(2)), pdata.rb.Price(ptr(2)) );
fprintf('RB2\t%s \t%3.2f\t%3.2f\t$%4.2f\n', pdata.rb.Name{ptr(3)}, w_bar(ind(3)), pdata.rb.Actual(ptr(3)), pdata.rb.Price(ptr(3)) );
fprintf('WR1\t%s \t%3.2f\t%3.2f\t$%4.2f\n', pdata.wr.Name{ptr(4)}, w_bar(ind(4)), pdata.wr.Actual(ptr(4)), pdata.wr.Price(ptr(4)) );
fprintf('WR2\t%s \t%3.2f\t%3.2f\t$%4.2f\n', pdata.wr.Name{ptr(5)}, w_bar(ind(5)), pdata.wr.Actual(ptr(5)), pdata.wr.Price(ptr(5)) );
fprintf('WR3\t%s \t%3.2f\t%3.2f\t$%4.2f\n', pdata.wr.Name{ptr(6)}, w_bar(ind(6)), pdata.wr.Actual(ptr(6)), pdata.wr.Price(ptr(6)) );
fprintf('TE \t%s \t%3.2f\t%3.2f\t$%4.2f\n', pdata.te.Name{ptr(7)}, w_bar(ind(7)), pdata.te.Actual(ptr(7)), pdata.te.Price(ptr(7)) );
fprintf('K\t%s   \t%3.2f\t%3.2f\t$%4.2f\n', pdata.k.Name{ptr(8)}, w_bar(ind(8)), pdata.k.Actual(ptr(8)), pdata.k.Price(ptr(8)) );
fprintf('DEF\t%s \t\t%3.2f\t%3.2f\t$%4.2f\n', pdata.def.Name{ptr(9)}, w_bar(ind(9)), pdata.def.Actual(ptr(9)), pdata.def.Price(ptr(9)) );
fprintf('---------------------------------------------------\n');
fprintf('TOT\t\t\t\t%3.1f\t%3.2f\t$%4.2f\n', ffp, ffa, cost);
fprintf('\nVaR \t%g\t(%.0f)\n', VaR, alpha*100);
fprintf('CVaR\t%g\t(%.0f)\n', CVaR, alpha*100);
fprintf('\nFopt\t%f\n', f*y);
fprintf('\nAllocation\n');
fprintf('QB\t%.2f\n', pdata.qb.Price(ptr(1))/cost);
fprintf('RB\t%.2f\n', ( pdata.rb.Price(ptr(2)) + pdata.rb.Price(ptr(3)) )/cost);
fprintf('WR\t%.2f\n', ( pdata.wr.Price(ptr(4)) + pdata.wr.Price(ptr(5)) + pdata.wr.Price(ptr(6)) )/cost);
fprintf('TE\t%.2f\n', ( pdata.te.Price(ptr(7)) )/cost);
fprintf('K \t%.2f\n', ( pdata.k.Price(ptr(8)) )/cost);
fprintf('DEF\t%.2f\n', ( pdata.def.Price(ptr(9)) )/cost);
%fprintf('Zk: %3.1f\n', zk);