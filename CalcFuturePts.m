function old = CalcFuturePts(old, new)

positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def' };
for n = 1:length(positions)
    np = length(old.(positions{n}).Name);
    old.(positions{n}).Actual = zeros(np,1);
    for p = 1:np
        nind = find( strcmp(old.(positions{n}).Name{p}, new.(positions{n}).Name) );
        if ~isempty(nind)
            old.(positions{n}).Actual(p,1) = new.(positions{n}).PTS(nind,1) - old.(positions{n}).PTS(p,1);
        end 
    end
end