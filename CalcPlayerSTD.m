function FFPstd = CalcPlayerSTD(week,outofsample)

phist = []; uptoweek = week;
if (outofsample)
    uptoweek = week - 1;
end

for n = 1:uptoweek
    phist{n} = LoadIPData(n);
end

[pdata, ddata] = LoadFFData(week);
hist = [];
positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def' };
for n = 1:length(positions)
    np = length(pdata.(positions{n}).Name);
    hist.(positions{n}) = zeros(np,1);
    for p = 1:np
        name = pdata.(positions{n}).Name{p};
		obs = 1;
		obsvec = [];
        for wk = 1:uptoweek
            allNames = phist{wk}.(positions{n}).Name;
            nind = find( strcmp(name, allNames) );
            if ~isempty(nind)
                val = phist{wk}.(positions{n}).FFPts(nind(1));
                nom = phist{wk}.(positions{n}).Name(nind(1));
                %hist.(positions{n})(p,obs) = val;
				obsvec(obs) = val;
                obs = obs + 1;
            end
        end
        val = std(obsvec);
        if (~isnan(val))
            FFPstd.(positions{n})(p) = val;
        else
            FFPstd.(positions{n})(p) = 0.0;
        end
    end
end
