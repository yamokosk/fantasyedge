clear;

outofsample = false;
lambda = linspace(0,1,10);
week = 10;
alpha = 0.1;
method = 'PlayerHistExp';

% DO NOT MODIFY BELOW THIS LINE
% -------------------------------------------------------------------------
p = LoadFFData(week);
p = CalcFuturePts(p,week);

% Actual player performance
wa = [p.qb.Actual; p.rb.Actual; p.wr.Actual; p.te.Actual; p.k.Actual; p.def.Actual];

% Storage of a lot of stuff
CVaR = zeros(size(lambda));
fp = zeros(size(lambda));
fa = zeros(size(lambda));
VaR = zeros(size(lambda));

% Method
s = [];
p = [];
ns = 0; np = 0;
switch (method)
    case 'ExpHist'
        s = CalcHistoryScenarios(week,outofsample);
        [np,ns] = size(s);
        a = 0.6180339887;
        z = [ns:-1:0]';
        p = (1-a)*a.^z; p = p ./ sum(p);
    case 'LinearHist'
        s = CalcHistoryScenarios(week,outofsample);
        [np,ns] = size(s);
        p = linspace(0,1,ns)';
        p = p ./ sum(p);
    case 'StepHist'
        s = CalcHistoryScenarios(week,outofsample);
        [np,ns] = size(s);
        val = -1;
        for n = 1:ns
            if rem(n,2)
                val = val + 1;
            end
            p(n,1) = val;
        end
        p = p ./ sum(p);
    case 'Norm'
        pstd = CalcPlayerSTD(week,outofsample);
        s = CalcNormScenarios(week,pstd,500);
        [np,ns] = size(s);
        p = (1/ns)*ones(ns,1);
    case 'Poisson'
        ppoisson = CalcPlayerPoisson(week,outofsample);
        s = CalcPoissScenarios(week,ppoisson,500);
        [np,ns] = size(s);
        p = (1/ns)*ones(ns,1);
    case 'HomeAway'
        

for n = 1:length(lvec)
    lambda = lvec(n);
    yopt = SolveStochastic(0.2, 0.1, 10, pl, shist);
    VaR(n) = -yopt(1);
    CVaR(n) = -(VaR(n) + inv(1-alpha)*pk'*yopt(2:10));
    fp(n) = ff;
    fa(n) = wa' * yopt(11:end);
    fprintf('Completed %d of %d', n, length(lvec));
end

% plot(fp,fa,'*')
% xlabel('FF Points - Predicted')
% ylabel('FF Points - Actual')
% figure(2)
% plot(-CVaR(1:9), fp)
% plot(-CVaR(1:9), fp(1:9))
% plot(-CVaR(1:9), fp(1:9),'*')
% xlabel('CVaR'); ylabel('FF Points - Predicted');
% fp(1:9)
% CVaR(1:9)
% figure(3)
% plot(lvec,fa)
% xlabel('Lambda'); ylabel('FF Points - Actual')
% figure(4)
% plot(lvec(1:9),-CVaR(1:9))
% xlabel('Lambda'); ylabel('CVaR');
% figure(5)
% plot(lvec, fp)
% xlabel('Lambda'); ylabel('FF Points - Actual');
% xlabel('Lambda'); ylabel('FF Points - Predicted');