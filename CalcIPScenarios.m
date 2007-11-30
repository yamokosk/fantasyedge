function s = CalcIPScenarios(week)

phist = [];
for n = 1:week-1
    phist{n} = LoadIPData(n);
end

pdata = LoadFFData(week);
hist = [];
positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def' };
for n = 1:length(positions)
    np = length(pdata.(positions{n}).Name);
    hist.(positions{n}) = zeros(np,week-1);
    
    % For each player...
    for p = 1:np
        name = pdata.(positions{n}).Name{p};
        observation = week-1;
        
        % For each week, going backwards
		for wk = week-1:-1:1
            allNames = phist{wk}.(positions{n}).Name;
            nind = find( strcmp(name, allNames) ); % Find player in this week
            if ~isempty(nind)
                % If we found the player's data, he played that week so
                % record the data as an observation.
                hist.(positions{n})(p,observation) = phist{wk}.(positions{n}).FFPts(nind(1));
                observation = observation - 1;
            end
        end
    end
end

s = cell2mat( struct2cell( hist ) );