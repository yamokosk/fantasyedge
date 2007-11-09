clc; clear all; close all;
warning off



%player columns (5):  player, H/A, opp, FP, P
%def columns (7):  team, qb, rb, wr, te, k, def

Nqb = length(qb_data(:,1));
Nrb = length(rb_data(:,1));
Nwr = length(wr_data(:,1));
Nte = length(te_data(:,1));
Nk = length(k_data(:,1));
Ndef = length(def_data(:,1));
Nsc = 9;

nflVqb = mean(def_data(:,2));
nflVrb = mean(def_data(:,3));
nflVwr = mean(def_data(:,4));
nflVte = mean(def_data(:,5));
nflVk = mean(def_data(:,6));
nflVdef = mean(def_data(:,7));

sc = [0.15 0.1; 0.15 0; 0.15 -0.1; 0.05 0.1; 0.05 0; 0.05 -0.1; -0.05 0.1; -0.05 0; -0.05 -0.1];

% j = columns (scenarios), i = rows (players), k = defense row in def_data

for i = 1:Nqb
    k =  %find the corresponding defense to the player's opponent and give the row location
    for j = 1:9
        if qb_data(i,2) == 1
            qb(i,j) = (1+sc(1,j))*(1-sc(2,j))*qb_data(i,4)*(def_data(k,2)/nflVqb);
        else
            qb(i,j) = (1-sc(1,j))*(1+sc(2,j))*qb_data(i,4)*(def_data(k,2)/nflVqb);
        end
    end
end




% binary integer programming problem optimization
bintprog(f,A,b)
    