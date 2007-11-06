function pdata = loadData(week, p_home, p_away)

C_PassYds = 1/50;
C_RushYds = 1/25;
C_RecYds = 1/25;
C_PassTD = 6;
C_RushTD = 6;
C_RecTD = 6;
C_Int = -2;
C_FumL = -2;
C_FGShort = 3;
C_FGMed = 4;
C_FGLong = 5;

pdata.senarioProbabilities = zeros(length(p_home) * length(p_away), 1);
k = 1;
for m = 1:length(p_home)
    for n = 1:length(p_away)
        pdata.senarioProbabilities(k) = p_home(m) * p_away(n);
        k = k + 1;
    end
end
ns = length(pdata.senarioProbabilities);

[data, matchups] = loadDataFromFiles(week);

npos = zeros(6,1);
npos(1) = data.qb.num;
npos(2) = data.rb.num;
npos(3) = data.wr.num;
npos(4) = data.te.num;
npos(5) = data.k.num;
npos(6) = 32;

np = sum(npos);
perf = zeros(np, ns);

% Lookup data
k = 1;
for k = 1:length(senarios)
    
    for i = 1:length(npos)
        posname = positions{i};
        
        for j = 1:length(npos(i))
            
            [opp, home] = getOpponent(data.(posname).team(j), matchups);
            [rushYdsK, rushTDK, recYdsK, recTDK, passYdsK, passTDK, IntK, FumLK] = ...
                getDefStats(opp, data.def_rushing, data.def_receiving, data.def_passing);
                
            switch (posname)
                case 'qb'
                    perf(ptr+j,k) = C_PassYds * data.(posname).PassYds(j) * PassYdsK + ...
                                C_PassTD * data.(posname).PassTD(j) * PassTDK + ...
                                C_RushYds * data.(posname).RushYds(j) * RushYdsK + ...
                                C_RushTD * data.(posname).RushTD(j) * RushTDK + ...
                                C_Int * data.(posname).Int(j) * IntK;
                case {'wr','te'}
                    perf(ptr+j,k) = C_RecYds * data.(posname).RecYds(j) * RecYdsK + ...
                                C_RecTD * data.(posname).RecTD(j) * RecTDK + ...
                                C_FumL * data.(posname).FumL(j) * FumLK;
                case 'rb'
                    perf(ptr+j,k) = C_RecYds * data.(posname).RecYds(j) * RecYdsK + ...
                                C_RecTD * data.(posname).RecTD(j) * RecTDK + ...
                                C_RushYds * data.(posname).RushYds(j) * RushYdsK + ...
                                C_RushTD * data.(posname).RushTD(j) * RushTDK + ...
                                C_FumL * data.(posname).FumL(j) * FumLK;
                case 'k'
                    perf(ptr+j,k) = C_FGShort * data.(posname).FG19(j) + ...
                                C_FGShort * data.(posname).FG29(j) + ...
                                C_FGShort * data.(posname).FG39(j) + ...
                                C_FGMed * data.(posname).FG49(j) + ...
                                C_FGLong * data.(posname).FG50(j) + ...
                                C_XPM * data.(posname).XPM(j);
                case 'def'
                    perf(ptr+j,k) = -C_Int * data.def_passing.Int(j);
            end
        end
    end
end


function [opp, home] = getOpponent(team, matchups)

hometeams = matchups(:,1);
awayteams = matchups(:,2);

ind = find( strcmp(hometeams, team) );

if (~isempty(ind))
    home = true;
    opp = hometeams{ind};
    return;
end

ind = find( strcmp(awayteams, team) );

if (~isempty(ind))
    home = false;
    opp = awayteams(ind);
    return;
end

home = true;
opp = 'BYE';


function [rushYdsK, rushTDK, recYdsK, recTDK, passYdsK, passTDK, IntK, FumLK] = ...
    getDefStats(opp, def_rushing, def_receiving, def_passing)

rushind = find( strcmp(opp, def_rushing.Team) );
passind = find( strcmp(opp, def_receiving.Team) );
recind = find( strcmp(opp, def_passing.Team) );

PassYdsBar = mean(data.def_passing.PassYds);
PassTDBar = mean(data.def_passing.PassTD);
IntBar = mean(data.def_passing.Int);
RushYdsBar = mean(data.def_rushing.RushYds);
RushTDBar = mean(data.def_rushing.RushTD);
RecYdsBar = mean(data.def_receiving.RecYds);
RecTDBar = mean(data.def_receiving.RecTD);

rushYdsK = def_rushing.RushYds  rushTDK, recYdsK, recTDK, passYdsK, passTDK, IntK, FumLK



