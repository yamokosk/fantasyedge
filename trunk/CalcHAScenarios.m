function s = CalcHAScenarios(week)

[pdata,ddata] = LoadFFData(week);

positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def' };
sc = [0.15 0.1; 0.15 0; 0.15 -0.1; 0.05 0.1; 0.05 0; 0.05 -0.1; -0.05 0.1; -0.05 0; -0.05 -0.1];
ns = size(sc, 1); % Number of scenarios

% For each position..
for n = 1:length(positions)
    % NFL average FF pts allowed for this position
    NFLAvg = mean(ddata.(positions{n}).FFPtsPG);

    % Number of players in this position
    np = length(pdata.(positions{n}).Name);
    
    % Initialize output data structure
    proj = zeros(np, ns);
    % For each player..
    for p = 1:np
        % Lookup opponent pts allowed
        opp_index = find( strcmp(pdata.(positions{n}).Opp(p), ddata.(positions{n}).Team) );
        if ( isempty(opp_index) )
            error('Could not find an opponent for %s', pdata.(positions{n}).Opp(p));
        end
        posPtsAvg = pdata.(positions{n}).AVG(p);
        isHome = pdata.(positions{n}).Home(p);
        defPtsAllowed = ddata.(positions{n}).FFPtsPG(opp_index);
        
        % For each scenario..
        for s = 1:ns
            if (isHome)
                proj(p,s) = (1+sc(s,1))*(1-sc(s,2))*posPtsAvg*(defPtsAllowed/NFLAvg);
            else
                proj(p,s) = (1-sc(s,1))*(1+sc(s,2))*posPtsAvg*(defPtsAllowed/NFLAvg);
            end
        end
    end
    scenarios.(positions{n}) = proj;
end
s = cell2mat( struct2cell( scenarios ) );
% binary integer programming problem optimization
%bintprog(f,A,b)
    