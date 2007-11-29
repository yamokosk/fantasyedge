clear;

lvec = linspace(0,1,10);

[p10,d10] = LoadFFData(10);
[xPI, fPI, p10] = SolveWithPI(10, p10);

% Cost function coefficients
wa = [p10.qb.Actual; p10.rb.Actual; p10.wr.Actual; p10.te.Actual; p10.k.Actual; p10.def.Actual];

% Storage of a lot of stuff
CVaR = zeros(size(lvec));
fp = zeros(size(lvec));
fa = zeros(size(lvec));
VaR = zeros(size(lvec));
beta = 0.9;
pk = (1/9)*ones(9,1);

for n = 1:length(lvec)
    lambda = lvec(n);
    [yopt, ff] = SolveStochastic(lambda, beta, p10, d10);
    VaR(n) = -yopt(1);
    CVaR(n) = -(VaR(n) + inv(1-beta)*pk'*yopt(2:10));
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