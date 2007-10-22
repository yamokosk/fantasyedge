function [x, fopt] = solveLP(playerData)

% Need to load the following:
%   pk - senario probabilities
%   fk - f(x,wk)
%   np - number of players
%   nqb, nrb, nwr, nte, nk, ndef - number of players from each position
%   c - cost of the players
playerData = loadData(week);
np = playerData.numPlayers;
nqb = playerData.numQB;
nrb = playerData.numRB;
nwr = playerData.numWR;
nte = playerData.numTE;
nk = playerData.numK;
ndef = playerData.numDEF;
pk = playerData.senarioProbabilities;
ns = length(pk);
 
Aeq = [ones(1,nqb), zeros(1,nrb), zeros(1,nwr), zeros(1,nte), zeros(1,nk), zeros(1,ndef); ...
       zeros(1,nqb), ones(1,nrb), zeros(1,nwr), zeros(1,nte), zeros(1,nk), zeros(1,ndef); ...
       zeros(1,nqb), zeros(1,nrb), ones(1,nwr), zeros(1,nte), zeros(1,nk), zeros(1,ndef); ...
       zeros(1,nqb), zeros(1,nrb), zeros(1,nwr), ones(1,nte), zeros(1,nk), zeros(1,ndef); ...
       zeros(1,nqb), zeros(1,nrb), zeros(1,nwr), zeros(1,nte), ones(1,nk), zeros(1,ndef); ...
       zeros(1,nqb), zeros(1,nrb), zeros(1,nwr), zeros(1,nte), zeros(1,nk), ones(1,ndef)];
beq = [1; 2; 2; 1; 1; 1] % Total number of players allowed for each position
A = c'; % Cost of the players
b = 100; % Salary cap limit

% Optimization options
opts = optimget('bintprog');
opts = optimset(opts, 'Display', 'iter');

[xopt, fopt] = bintprog(f,A,b,Aeq,Beq,zeros(np,1),opts);

    function f = costfun(xj)
        fk = playerData.performance' * xj;
        f = minCVaR(xj,pk,fk,0.85);
    end
end


function [fopt,yopt] = minCVaR(xj,pk,fk,alpha)
    ns = length(pk);
    lb = zeros(ns+1,1); lb(1) = -inf; 
    ub = inf(ns+1,1);
    A = [ones(ns,1); eye(ns)];
    [yopt, fopt] = linprog(@CVaR,-A,-fk,[],[],lb,ub,zeros(ns+1,1));
    
    function c = CVaR(yj, alpha)
        zeta = yj(1);
        zk = yj(2:end);
        c = zeta + inv(1-alpha)*(pk'*zk);
    end
end