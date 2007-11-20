function [xopt, fopt] = solveLP(wk)

[pdata,ddata] = LoadFFData(wk);
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

% Generate a random fantasy team
rqb = randint(1,1,[1, nqb]);
rrb = randint(2,1,[nqb, nqb+nrb]);
rwr = randint(3,1,[nqb+nrb, nqb+nrb+nwr]);
rte = randint(1,1,[nqb+nrb+nwr, nqb+nrb+nwr+nte]);
rk = randint(1,1,[nqb+nrb+nwr+nte, nqb+nrb+nwr+nte+nk]);
rdef = randint(1,1,[nqb+nrb+nwr+nte+nk, nqb+nrb+nwr+nte+nk+ndef]);
xguess = zeros(np,1);
xguess([rqb; rrb; rwr; rte; rk; rdef],1) = 1.0;
fprintf('Random fantasy team.\n');
fprintf('\tQB: %s\n', pdata.qb.Name{rqb});
fprintf('\tRB: %s, %s\n', pdata.rb.Name{rrb(1)-nqb}, pdata.rb.Name{rrb(2)-nqb});
fprintf('\tWR: %s, %s, %s\n', pdata.wr.Name{rwr(1)-nqb-nrb}, pdata.wr.Name{rwr(2)-nqb-nrb}, pdata.wr.Name{rwr(3)-nqb-nrb});
fprintf('\tTE: %s\n', pdata.te.Name{rte-nqb-nrb-nwr});
fprintf('\tK: %s\n', pdata.k.Name{rk-nqb-nrb-nwr-nte});
fprintf('\tDEF: %s\n', pdata.def.Name{rdef-nqb-nrb-nwr-nte-nk});
fprintf('\t---------\n');
fprintf('\tE(Proj): %g\tCost: %g\n\n', f'*xguess, A*xguess);

% Compute optimal team
% Optimization options
opts = optimset('bintprog');
opts = optimset(opts, 'Display', 'iter');
[xopt, fopt] = bintprog(-f,A,b,Aeq,beq,xguess,opts);
ind = find(xopt == 1);

fprintf('Optimal fantasy team.\n');
fprintf('\tQB: %s (%f)\n', pdata.qb.Name{ind(1)}, f(ind(1)));
fprintf('\tRB: %s (%f), %s (%f)\n', pdata.rb.Name{ind(2)-nqb}, f(ind(2)), pdata.rb.Name{ind(3)-nqb}, f(ind(3)));
fprintf('\tWR: %s (%f), %s (%f), %s (%f)\n', pdata.wr.Name{ind(4)-nqb-nrb}, f(ind(4)), pdata.wr.Name{ind(5)-nqb-nrb}, f(ind(5)), pdata.wr.Name{ind(6)-nqb-nrb}, f(ind(6)));
fprintf('\tTE: %s (%f)\n', pdata.te.Name{ind(7)-nqb-nrb-nwr}, f(ind(7)));
fprintf('\tK: %s (%f)\n', pdata.k.Name{ind(8)-nqb-nrb-nwr-nte}, f(ind(8)));
fprintf('\tDEF: %s (%f)\n', pdata.def.Name{ind(9)-nqb-nrb-nwr-nte-nk}, f(ind(9)));
fprintf('\t---------\n');
fprintf('\tE(Proj): %g\tCost: %g\n\n', f'*xopt, A*xopt);
end


% minCVaR
%   xj  -   
% function [fopt,yopt] = minCVaR(xj,pk,fk,alpha)
%     ns = length(pk);
%     lb = zeros(ns+1,1); lb(1) = -inf; 
%     ub = inf(ns+1,1);
%     A = [ones(ns,1); eye(ns)];
%     [yopt, fopt] = linprog(@CVaR,-A,-fk,[],[],lb,ub,zeros(ns+1,1));
%     
%     function c = CVaR(yj, alpha)
%         zeta = yj(1);
%         zk = yj(2:end);
%         c = zeta + inv(1-alpha)*(pk'*zk);
%     end
% end