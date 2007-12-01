function [xopt, fopt, pdata] = SolveWithPI(wk, pdata)

% Load player data
pdata = CalcFuturePts(pdata,wk);

% Cost function coefficients
f = [pdata.qb.Actual; pdata.rb.Actual; pdata.wr.Actual; pdata.te.Actual; pdata.k.Actual; pdata.def.Actual];

% Some easy to use variables
np = length(f);                 % Total number of players
nqb = length(pdata.qb.Name);    % Number of qb
nrb = length(pdata.rb.Name);    % Number of rb
nwr = length(pdata.wr.Name);    % Number of wr
nte = length(pdata.te.Name);    % Number of te
nk = length(pdata.k.Name);      % Number of k
ndef = length(pdata.def.Name);  % Number of def 

% Create equality contraints - sum of players from each position must be
% equal to beq
%   Aeq * x = beq
Aeq = [ones(1,nqb), zeros(1,nrb), zeros(1,nwr), zeros(1,nte), zeros(1,nk), zeros(1,ndef); ...
       zeros(1,nqb), ones(1,nrb), zeros(1,nwr), zeros(1,nte), zeros(1,nk), zeros(1,ndef); ...
       zeros(1,nqb), zeros(1,nrb), ones(1,nwr), zeros(1,nte), zeros(1,nk), zeros(1,ndef); ...
       zeros(1,nqb), zeros(1,nrb), zeros(1,nwr), ones(1,nte), zeros(1,nk), zeros(1,ndef); ...
       zeros(1,nqb), zeros(1,nrb), zeros(1,nwr), zeros(1,nte), ones(1,nk), zeros(1,ndef); ...
       zeros(1,nqb), zeros(1,nrb), zeros(1,nwr), zeros(1,nte), zeros(1,nk), ones(1,ndef)];
beq = [1; 2; 3; 1; 1; 1]; % Total number of players allowed for each position

% Create inequality contraints - sum of players cost must be less than 100
A = [pdata.qb.Price; pdata.rb.Price; pdata.wr.Price; pdata.te.Price; pdata.k.Price; pdata.def.Price]';     % Cost of the players
b = 100;    % Salary cap limit

% Compute optimal team
% Optimization options
% opts = optimset(@bintprog);
% opts = optimset(opts, 'Display', 'iter');
[xopt, fopt] = bintprog(-f,A,b,Aeq,beq,zeros(np,1));%,opts);
ind = find(xopt == 1);
offset = [0; -nqb; -nqb; -nqb-nrb; -nqb-nrb; -nqb-nrb; -nqb-nrb-nwr; -nqb-nrb-nwr-nte; -nqb-nrb-nwr-nte-nk];
ptr = ind + offset;
cost = A*xopt;

fprintf('\nOptimal fantasy team.\n');
fprintf('QB \t%s \t%3.2f\t$%4.2f\n', pdata.qb.Name{ptr(1)}, pdata.qb.Actual(ptr(1)), pdata.qb.Price(ptr(1)) );
fprintf('RB1\t%s \t%3.2f\t$%4.2f\n', pdata.rb.Name{ptr(2)}, pdata.rb.Actual(ptr(2)), pdata.rb.Price(ptr(2)) );
fprintf('RB2\t%s \t%3.2f\t$%4.2f\n', pdata.rb.Name{ptr(3)}, pdata.rb.Actual(ptr(3)), pdata.rb.Price(ptr(3)) );
fprintf('WR1\t%s \t%3.2f\t$%4.2f\n', pdata.wr.Name{ptr(4)}, pdata.wr.Actual(ptr(4)), pdata.wr.Price(ptr(4)) );
fprintf('WR2\t%s \t%3.2f\t$%4.2f\n', pdata.wr.Name{ptr(5)}, pdata.wr.Actual(ptr(5)), pdata.wr.Price(ptr(5)) );
fprintf('WR3\t%s \t%3.2f\t$%4.2f\n', pdata.wr.Name{ptr(6)}, pdata.wr.Actual(ptr(6)), pdata.wr.Price(ptr(6)) );
fprintf('TE \t%s \t%3.2f$%4.2f\n', pdata.te.Name{ptr(7)}, pdata.te.Actual(ptr(7)), pdata.te.Price(ptr(7)) );
fprintf('K\t%s   \t%3.2f\t$%4.2f\n', pdata.k.Name{ptr(8)}, pdata.k.Actual(ptr(8)), pdata.k.Price(ptr(8)) );
fprintf('DEF\t%s \t\t%3.2f\t$%4.2f\n', pdata.def.Name{ptr(9)}, pdata.def.Actual(ptr(9)), pdata.def.Price(ptr(9)) );
fprintf('---------------------------------------------------\n');
fprintf('TOT\t\t\t\t%3.1f\t$%4.2f\n', -fopt, cost);