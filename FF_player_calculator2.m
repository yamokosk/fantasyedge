clc; clear all; close all;
warning off

Nqb = 61;
scenarios = 9;

%notation is defined at end

% qb_data = [Nqb x 10]  PID, Team, Opp, G, Ypass, TDpass, Yrush, TDrush, I, FL

% def_data = [32 x 8]   TID, Yrush, TDrush, Ypass, TDpass, I, ITD, S
         
% nfl_data = mean(def_data(:,i))  [1 x 8]

% j = columns, i = rows, 

% for k = 1:scenarios
    for i = 1:Nqb
        for j = 1:10
            qb(i,k) = (1/50)*((def_data(qb_data(i,3), 4)/(nfl_data(1,4)))*qb_data(i,5))+
            6*((def_data(qb_data(i,3), 5)/(nfl_data(1,5)))*qb_data(i,6))+
            (1/20)*((def_data(qb_data(i,3), 2)/(nfl_data(1,2)))*qb_data(i,7))+
            6*((def_data(qb_data(i,3), 3)/(nfl_data(1,3)))*qb_data(i,8))-
            2*(((def_data(qb_data(i,3), 6)/(nfl_data(1,6)))*qb_data(i,9))+qb_data(i,10))
        end
    end
    
    
    
    
    
% Basic deterministic equation for QBs, does not funciton, but shows layout
% All calculations are supposed to deal with averages, but it depends on
% what the input data is

% NOTATION:
% PID = player ID
% Opp = opponent ID (= defense's team ID)
% I = interceptions
% ITD = interceptions for touchdowns
% FL = fumbles lost per game
% S = sacks per game

