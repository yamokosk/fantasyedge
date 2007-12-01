function yopt = SolveStochastic(lambda, alpha, week, pk, scenarioMatrix)
% Variables to tune optimization
%   lambda - Risk measure. 1 - Very risky, 0 - No risk
%   alpha - percentile

maxTime = 60*60;
beta = alpha;
% DO NOT MODIFY BELOW THIS LINE
% -------------------------------------------------------------------------

% Load player data
%scenarios = ProcessPlayerData(pdata,ddata);
%scenarioMatrix = cell2mat( struct2cell( scenarios ) );
pdata = LoadFFData(week);
[np,ns] = size(scenarioMatrix);    % Total number of players and scenarios
nqb = length(pdata.qb.Name);    % Number of qb
nrb = length(pdata.rb.Name);    % Number of rb
nwr = length(pdata.wr.Name);    % Number of wr
nte = length(pdata.te.Name);    % Number of te
nk = length(pdata.k.Name);      % Number of k
ndef = length(pdata.def.Name);  % Number of def 

% Scenario probabilities
% pk = inv(ns) * ones(ns,1);  % All equally probable
% a = 0.6180339887;
% z = [(ns-1):-1:0]';
% pk = (1-a)*a.^z;
% pk = pk ./ sum(pk);        % Exponentially forgetting

% Player names (for conveinence)
names = [pdata.qb.Name; pdata.rb.Name; pdata.wr.Name; pdata.te.Name; pdata.k.Name; pdata.def.Name];

% Expected performance
w_bar = scenarioMatrix*pk; %[pdata.qb.AVG; pdata.rb.AVG; pdata.wr.AVG; pdata.te.AVG; pdata.k.AVG; pdata.def.AVG];

% Player cost
c = [pdata.qb.Price; pdata.rb.Price; pdata.wr.Price; pdata.te.Price; pdata.k.Price; pdata.def.Price];

% Prob = mipAssign(c, A, bL, bU, yL, yU, y0, Name,...
%                   setupFile, nProblem, ...
% CVaR in cost function
yL = [-inf, zeros(1,ns), zeros(1,np)]';
yU = [inf, inf * ones(1,ns), ones(1,np)]';

bL = [0, 1, 2, 3, 1, 1, 1, zeros(1,ns)]';
bU = [100, 1, 2, 3, 1, 1, 1, inf*ones(1,ns)]';

A = [0, zeros(1,ns), c'; ... % Player cost
     0, zeros(1,ns), ones(1,nqb),  zeros(1,nrb), zeros(1,nwr), zeros(1,nte), zeros(1,nk), zeros(1,ndef); ...
     0, zeros(1,ns), zeros(1,nqb), ones(1,nrb),  zeros(1,nwr), zeros(1,nte), zeros(1,nk), zeros(1,ndef); ...
     0, zeros(1,ns), zeros(1,nqb), zeros(1,nrb), ones(1,nwr),  zeros(1,nte), zeros(1,nk), zeros(1,ndef); ...
     0, zeros(1,ns), zeros(1,nqb), zeros(1,nrb), zeros(1,nwr), ones(1,nte),  zeros(1,nk), zeros(1,ndef); ...
     0, zeros(1,ns), zeros(1,nqb), zeros(1,nrb), zeros(1,nwr), zeros(1,nte), ones(1,nk),  zeros(1,ndef); ...
     0, zeros(1,ns), zeros(1,nqb), zeros(1,nrb), zeros(1,nwr), zeros(1,nte), zeros(1,nk), ones(1,ndef); ...
     ones(ns,1), eye(ns,ns), scenarioMatrix']; % CVaR zk constraints

f = [lambda-1,  (lambda-1)*inv(1-alpha)*pk', lambda*w_bar'];

% CVaR as constraint
% CL = -inf; CU = -110; 
% yL = [-inf, -inf*ones(1,ns), zeros(1,np)]';
% yU = [inf, inf * ones(1,ns), ones(1,np)]';
% 
% bL = [0, 1, 2, 3, 1, 1, 1, zeros(1,ns), zeros(1,ns), CL]';
% bU = [100, 1, 2, 3, 1, 1, 1, inf*ones(1,ns), inf*ones(1,ns), CU]';
% 
% A = [0, zeros(1,ns), c'; ... % Player cost
%      0, zeros(1,ns), ones(1,nqb),  zeros(1,nrb), zeros(1,nwr), zeros(1,nte), zeros(1,nk), zeros(1,ndef); ...
%      0, zeros(1,ns), zeros(1,nqb), ones(1,nrb),  zeros(1,nwr), zeros(1,nte), zeros(1,nk), zeros(1,ndef); ...
%      0, zeros(1,ns), zeros(1,nqb), zeros(1,nrb), ones(1,nwr),  zeros(1,nte), zeros(1,nk), zeros(1,ndef); ...
%      0, zeros(1,ns), zeros(1,nqb), zeros(1,nrb), zeros(1,nwr), ones(1,nte),  zeros(1,nk), zeros(1,ndef); ...
%      0, zeros(1,ns), zeros(1,nqb), zeros(1,nrb), zeros(1,nwr), zeros(1,nte), ones(1,nk),  zeros(1,ndef); ...
%      0, zeros(1,ns), zeros(1,nqb), zeros(1,nrb), zeros(1,nwr), zeros(1,nte), zeros(1,nk), ones(1,ndef); ...
%      ones(ns,1), eye(ns,ns), scenarioMatrix'; ...
%      zeros(ns,1), eye(ns,ns), zeros(ns,np); ...
%      1, inv(1-alpha)*pk', zeros(1,np)]; % CVaR zk constraints
% 
% f = [0,  zeros(1,ns), -w_bar'];

% IntVars
M = [0, zeros(1,ns), ones(1,np)]';
IntVars = find( M == 1 );

% Cost function coefficients
Prob = mipAssign(-f, A, bL, bU, yL, yU, [], 'FFLineUp',...
    [], [], ...
    IntVars, [], 0, [], []);
Prob.MaxCPU = maxTime;
Prob.optParam.IterPrint = 0;
Prob.optParam.MaxIter = 1000*length(f);
Result = mipSolve(Prob);
yopt = Result.x_k;

if (Result.ExitFlag == 0)
    PrintTeamStats(yopt,pdata,week,alpha,f,pk,scenarioMatrix)
else
    fprintf('Solution not found. Reason: %d\n', Result.ExitFlag);
end