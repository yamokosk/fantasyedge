function [xopt, ff] = SolveStochastic(lambda, beta, pdata, ddata)
% Variables to tune optimization
%   lambda - Risk measure. 1 - Very risky, 0 - No risk
%   beta - percentile

maxTime = 120;

% DO NOT MODIFY BELOW THIS LINE
% -------------------------------------------------------------------------

% Load player data
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

% Player names (for conveinence)
names = [pdata.qb.Name; pdata.rb.Name; pdata.wr.Name; pdata.te.Name; pdata.k.Name; pdata.def.Name];

% Expected performance
w_bar = mean(scenarioMatrix, 2);

% Player cost
c = [pdata.qb.Price; pdata.rb.Price; pdata.wr.Price; pdata.te.Price; pdata.k.Price; pdata.def.Price];

% Prob = mipAssign(c, A, bL, bU, yL, yU, y0, Name,...
%                   setupFile, nProblem, ...
%                   IntVars, VarWeight, KNAPSACK, fIP, xIP, ...
%                   fLowBnd, x_min, x_max, f_opt, x_opt);
%   INPUT (One parameter c must always be given)
%  
%   f:         The vector f in f'x in the objective function
%   A:         The linear constraint matrix
%   bL:        The lower bounds for the linear constraints
%   bU:        The upper bounds for the linear constraints
%   yL:        Lower bounds on x
%   yU:        Upper bounds on x
%  
%              bL, bU, yL, yU must either be empty or of full length
%  
%   y0:        Starting point x (may be empty)
%   Name       The name of the problem (string)
%   setupFile  The (unique) name as a TOMLAB Init File. If nonempty mipAssign
%              will create a executable m-file with this name and the given
%              problem defined as the first problem in this file.
%              See mip_prob.m, the TOMLAB predefined MIP Init File.
%              If empty, no Init File is created.
%   nProblem   Number of problems to predefine in the setupFile
%              Not used if setupFile is empty.
%              If empty assumed to be one. Then text are included in the
%              setupFile on how to create additional problems.
%   IntVars    The set of integer variables. Can be given in one of two ways:
%  
%               1) a vector of indices, e.g. [1 2 5].  If [], no integer variables
%  
%               2) a 0-1 vector of length <= n=length(x) where nonzero elements
%                  indicate integer variables
%  
%   VarWeight  Weight for each variable in the variable selection phase.
%              A lower value gives higher priority. Setting
%              Prob.MIP.VarWeight = f; for knapsack problems improve convergence.
%   KNAPSACK   True if a knapsack problem is to be solved,
%              then a knapsack heuristic is used.
%   fIP        An upper bound on the IP value wanted. Makes it possible to
%              cut branches and avoid node computations.
%   xIP        The x-values giving the fIP value.
%   --------------------------------------------------------------------------
%   fLowBnd    A lower bound on the function value at optimum. Default -1E300
%              A good estimate is not critical. Use [] if not known at all.
%              Only used if running some nonlinear TOMLAB solvers with line search
%   x_min      Lower bounds on each x-variable, used for plotting
%   x_max      Upper bounds on each x-variable, used for plotting
%   f_opt      Optimal function value(s), if known (Stationary points)
%   x_opt      The x-values corresponding to the given f_opt, if known.
%              If only one f_opt, give x_opt as a 1 by n vector
%              If several f_opt values, give x_opt as a length(f_opt) x n matrix
%              If adding one extra column n+1 in x_opt,
%              0 indicates min, 1 saddle (nonlinear problems), 2 indicates max.
%              x_opt and f_opt is used in printouts and plots.
% Lower and upper bounds
yL = [-inf, zeros(1,ns), zeros(1,np)]';
yU = [inf, inf * ones(1,ns), ones(1,np)]';
% In equality constraints bL <= A*y <= bU
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

% IntVars
M = [0; zeros(9,1); ones(np,1)];
IntVars = find( M == 1 );

% Cost function coefficients
f = [lambda-1,  (lambda-1)*inv(1-beta)*pk', lambda*w_bar'];
Prob = mipAssign(-1*f, A, bL, bU, yL, yU, [], 'FFLineUp',...
    [], [], ...
    IntVars, [], 0, [], []);
Prob.MaxCPU = maxTime;
Prob.optParam.IterPrint = 0;
Result = mipSolve(Prob);
xopt = Result.x_k;
ff = w_bar' * xopt(11:end);
% fprintf('Solution found in %f seconds.\n', stop);
% fprintf('\nVaR(%.1f): %g\n', beta*100, Result.x_k(1));
% fprintf('\nZs: [%f, %f, ... , %f, %f]\n', Result.x_k(2), Result.x_k(3), Result.x_k(9), Result.x_k(10));
% fprintf('\nFopt: %g\n', Result.f_k);
% fprintf('\nOptimal fantasy team.\n');
% % for n = 1:length(ind)
% %     fprintf('\t%s\n', names{ind(n)});
% % end
% fprintf('\tQB: %s\n', pdata.qb.Name{ind(1)});
% fprintf('\tRB: %s, %s\n', pdata.rb.Name{ind(2)-nqb}, pdata.rb.Name{ind(3)-nqb});
% fprintf('\tWR: %s, %s, %s\n', pdata.wr.Name{ind(4)-nqb-nrb}, pdata.wr.Name{ind(5)-nqb-nrb}, pdata.wr.Name{ind(6)-nqb-nrb});
% fprintf('\tTE: %s\n', pdata.te.Name{ind(7)-nqb-nrb-nwr});
% fprintf('\tK: %s\n', pdata.k.Name{ind(8)-nqb-nrb-nwr-nte});
% fprintf('\tDEF: %s\n', pdata.def.Name{ind(9)-nqb-nrb-nwr-nte-nk});
% fprintf('\t---------\n');
% fprintf('\tPts: %g\tCost: %g\n\n', w_bar'*xopt, c'*xopt);