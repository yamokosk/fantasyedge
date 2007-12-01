function old = CalcFuturePts(old, week)

positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def' };
ip = LoadIPData(week);
for n = 1:length(positions)
    np = length(old.(positions{n}).Name);
    old.(positions{n}).Actual = zeros(np,1);
    for p = 1:np
        nind = find( strcmp(old.(positions{n}).Name{p}, ip.(positions{n}).Name) );
        if ~isempty(nind)
            old.(positions{n}).Actual(p,1) = ip.(positions{n}).FFPts(nind(1),1);
        else
            old.(positions{n}).Actual(p,1) = NaN;
        end
    end
end