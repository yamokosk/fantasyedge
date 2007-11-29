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
    hist.(positions{n}) = zeros(np,1);
    for p = 1:np
        name = p10.(positions{n}).Name{p};
        %obs = 9;
		obs = 1;
		obsvec = [];
        for wk = 9:-1:1
            allNames = phist{wk}.(positions{n}).Name;
            nind = find( strcmp(name, allNames) );
            if ~isempty(nind)
                val = phist{wk}.(positions{n}).FFPts(nind(1));
                %hist.(positions{n})(p,obs) = val;
				obsvec[obs] = val;
                obs = obs + 1;
            end
			hist.(positions{n})(p) = std(obsvec);
        end
    end
end