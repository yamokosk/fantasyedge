function pdata = loadData(week, p_home, p_away)

cpassYds = 1/50;
crushYds = 1/25;
crecYds = 1/25;
cpassTD = 6;
crushTD = 6;
crecTD = 6;
cint = -2;
cfum = -2;

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

nqb = data.qb.num;
nrb = data.rb.num;
nwr = data.wr.num;
nte = data.te.num;
nk = data.k.num;
ndef = 32;

np = nqb + nrb + nwr + nte + nk + ndef;
perf = zeros(np, ns);

PassYdsBar = mean(data.def_passing.PassYds);
PassTDBar = mean(data.def_passing.PassTD);
IntBar = mean(data.def_passing.Int);
RushYdsBar = mean(data.def_rushing.RushYds);
RushTDBar = mean(data.def_rushing.RushTD);
RecYdsBar = mean(data.def_receiving.RecYds);
RecTDBar = mean(data.def_receiving.RecTD);

k = 1;
for m = 1:length(p_home)
    for n = 1:length(p_away)
        ptr = 1;
        % QB performance
        perf(1:ptr+nqb,k) = C_PassYds * (data.qb.PassYds) .* (data.def_passing.PassYds / PassYdsBar) + ...
                                          cpassTD * passTDij * passTDk / passTDBar + ...
                                          crushYds * rushYdsij * rushYdsk / rushYdsBar + ...
                                          crushTD * rushTDij * rushTDk / rushTDBar + ...
                                          cint * intij * intk / intBar;
        
        % RB performance
        ptr = ptr + nqb + 1;
        perf(ptr:ptr+nrb,k) = crushYds * rushYdsij * rushYdsk / rushYdsBar + ...
                                          crushTD * rushTDij * rushTDk / rushTDBar + ...
                                          crecYds * recYdsij * recYdsk / recYdsBar + ...
                                          crecTD * recTDij * recTDk / recTDBar + ...
                                          cfum * fumBar;
        
        % WR performance
        ptr = ptr + nrb + 1;
        perf(ptr:ptr+nwr,k) = crushYds * rushYdsij * rushYdsk / rushYdsBar + ...
                                          crushTD * rushTDij * rushTDk / rushTDBar + ...
                                          crecYds * recYdsij * recYdsk / recYdsBar + ...
                                          crecTD * recTDij * recTDk / recTDBar + ...
                                          cfum * fumBar;
       
        % TE performance
        ptr = ptr + nwr + 1;
        perf(ptr:ptr+nte,k) = crushYds * rushYdsij * rushYdsk / rushYdsBar + ...
                                          crushTD * rushTDij * rushTDk / rushTDBar + ...
                                          crecYds * recYdsij * recYdsk / recYdsBar + ...
                                          crecTD * recTDij * recTDk / recTDBar + ...
                                          cfum * fumBar;
        
        % K performance
        ptr = ptr + nte + 1;
        perf(ptr:ptr+nk,k) = crushYds * rushYdsij * rushYdsk / rushYdsBar + ...
                                          crushTD * rushTDij * rushTDk / rushTDBar + ...
                                          crecYds * recYdsij * recYdsk / recYdsBar + ...
                                          crecTD * recTDij * recTDk / recTDBar + ...
                                          cfum * fumBar;
        
        % DEF performance
        ptr = ptr + nk + 1;
        perf(ptr:ptr+ndef,k) = crushYds * rushYdsij * rushYdsk / rushYdsBar + ...
                                          crushTD * rushTDij * rushTDk / rushTDBar + ...
                                          crecYds * recYdsij * recYdsk / recYdsBar + ...
                                          crecTD * recTDij * recTDk / recTDBar + ...
                                          cfum * fumBar;
        
        k = k + 1;
    end
end

playerData.numQB = data(1).num;
playerData.numRB = data(2).num;
playerData.numWR = data(3).num;
playerData.numTE = data(4).num;
playerData.numK = data(5).num;
playerData.numDEF = data(6).num;

playerData.numPlayers = playerData.numQB + playerData.numRB + playerData.numWR + playerData.numTE + playerData.numK + playerData.numDEF;

playerData.performance = zeros(playerData.numPlayers, ns);


