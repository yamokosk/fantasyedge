clear;
phist = [];
for n = 1:9
    phist{n} = LoadIPData(n);
end

p10 = LoadFFData(10);
hist = [];
positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def' };
for n = 1:length(positions)
    np = length(p10.(positions{n}).Name);
    hist.(positions{n}) = zeros(np,9);
    for p = 1:np
        name = p10.(positions{n}).Name{p};
        for wk = 1:9
            allNames = phist{wk}.(positions{n}).Name;
            nind = find( strcmp(name, allNames) );
            if ~isempty(nind)
                val = phist{wk}.(positions{n}).FFPts(nind(1));
                hist.(positions{n})(p,wk) = val;
            end
        end
    end
end