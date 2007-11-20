function [xopt, fopt] = SolveWithPI(wk)

% Load player data
pdata = LoadFFData(wk);
pdata = CalcFuturePts(pdata,LoadFFData(wk+1));

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
opts = optimset('bintprog');
opts = optimset(opts, 'Display', 'iter');
[xopt, fopt] = bintprog(-f,A,b,Aeq,beq,zeros(np,1),opts);
ind = find(xopt == 1);

fprintf('\nOptimal fantasy team.\n');
fprintf('\tQB: %s\n', pdata.qb.Name{ind(1)});
fprintf('\tRB: %s, %s\n', pdata.rb.Name{ind(2)-nqb}, pdata.rb.Name{ind(3)-nqb});
fprintf('\tWR: %s, %s, %s\n', pdata.wr.Name{ind(4)-nqb-nrb}, pdata.wr.Name{ind(5)-nqb-nrb}, pdata.wr.Name{ind(6)-nqb-nrb});
fprintf('\tTE: %s\n', pdata.te.Name{ind(7)-nqb-nrb-nwr});
fprintf('\tK: %s\n', pdata.k.Name{ind(8)-nqb-nrb-nwr-nte});
fprintf('\tDEF: %s\n', pdata.def.Name{ind(9)-nqb-nrb-nwr-nte-nk});
fprintf('\t---------\n');
fprintf('\tPts: %g\tCost: %g\n\n', f'*xopt, A*xopt);