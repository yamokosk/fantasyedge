% Calculates player data up to and including week 10
FFPstd = CalcPlayerSTD2(10);

% rndscenarioMatrix:
% This file just calculates the random scenarios for the week of interest,
% junk2 finds the standard deviation for that week

% I want to load the player averages for up to week 10, which is labled
% present in week 11
[pdata, ddata] = LoadFFData(11);
positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def' };
%Coefficient of variation of Def allowed for each position wr = qb = te
defV_CV = [0.70; 0.65; 0.70; 0.70; 0.63; 0.54];
% NFL average FF pts allowed for this position
for n = 1:length(positions)
    % NFL average FF pts allowed for this position
    defVpos_nfl = mean(ddata.(positions{n}).FFPtsPG);
    % Number of defenses (=32)
    nd = length(ddata.(positions{n}).Team);
    for d = 1:nd
    defVpos_avg = ddata.(positions{n}).FFPtsPG(d);
    defVpos_adj.(positions{n})(d) = defVpos_avg - defVpos_nfl;
    defVpos_std.(positions{n})(d) = defV_CV(n)*defVpos_avg;
    end
    np = length(pdata.(positions{n}).Name);
    for p = 1:np
        pavg = pdata.(positions{n}).AVG(p);
        pstd = FFPstd.(positions{n})(p);
        % Lookup opponent pts allowed
        opp_index = find( strcmp(pdata.(positions{n}).Opp(p), ddata.(positions{n}).Team) );
        if ( isempty(opp_index) )
            error('Could not find an opponent for %s', pdata.(positions(n)).Opp(p));
        end
        pd_matchup_avg.(positions{n})(p) = pavg + defVpos_adj.(positions{n})(opp_index);
        pd_matchup_std.(positions{n})(p) = sqrt(pstd^2+(defVpos_std.(positions{n})(opp_index))^2);
    end
end

% pd_avg = cell2mat( struct2cell( pd_matchup_avg ) );
% pd_std = cell2mat( struct2cell( pd_matchup_std ) );
% pd_avg(find(isnan(pd_avg))) = 0;
% pd_std(find(isnan(pd_std))) = 0;