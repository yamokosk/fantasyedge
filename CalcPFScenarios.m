function s = CalcPFScenarios(week,ns)

FFPstd = CalcPlayerSTD(week);

% rndscenarioMatrix:
% This file just calculates the random scenarios for the week of interest,
% junk2 finds the standard deviation for that week

%ns = 20;
[pdata, ddata] = LoadFFData(week);
positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def' };
%Coefficient of variation of Def allowed for each position wr = qb = te
defV_CV = [0.70; 0.65; 0.70; 0.70; 0.63; 0.54];
% NFL average FF pts allowed for this position
for n = 1:length(positions)
    % NFL average FF pts allowed for this position
    defVpos_nfl = mean(ddata.(positions{n}).FFPtsPG);
    % Number of defenses (=32)
    np = length(ddata.(positions{n}).Team);
    % Initialize output data structure
    bob = 1;
    for p = 1:np
    defVpos_avg = ddata.(positions{n}).FFPtsPG(p);
    defVpos_ravg = normrnd(defVpos_avg, defV_CV(n)*defVpos_avg, 1, ns);
%     def_rndsc(p,:,n) = defVpos_ravg./defVpos_nfl;
    %def_rndsc.(positions{n})(p,:) = defVpos_ravg./defVpos_nfl;
    def_rndsc.(positions{n})(p,:) = defVpos_ravg - defVpos_nfl;
    end
end

%Need to run junk2 first!!!
for n = 1:length(positions)
    np = length(pdata.(positions{n}).Name);
    bob = 1;
    for p = 1:np
        pavg = pdata.(positions{n}).AVG(p);
        pstd = FFPstd.(positions{n})(p);
    	p_rndsc = normrnd(pavg, pstd, 1, ns);
         % Lookup opponent pts allowed
        opp_index = find( strcmp(pdata.(positions{n}).Opp(p), ddata.(positions{n}).Team) );
        if ( isempty(opp_index) )
            error('Could not find an opponent for %s', pdata.(positions(n)).Opp(p));
        end
        %FFp_rndsc.(positions{n})(p,:) = p_rndsc.*def_rndsc.(positions{n})(opp_index,:);
        FFp_rndsc.(positions{n})(p,:) = p_rndsc + def_rndsc.(positions{n})(opp_index,:);
    end
end

s = cell2mat( struct2cell( FFp_rndsc ) );
s(find(isnan(s))) = 0;