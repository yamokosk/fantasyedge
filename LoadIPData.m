function pdata = LoadIPData(week)
% USAGE: [pdata, ddata] = LoadFFData(week_number)
%   Loads fantasy data into Matlab from the processed files. Make sure 
%   that the data files for the week have been processed by
%   calling ProcessFiles(week_number) first.

% AUTHOR: J.D. Yamokoski
% DATE: 11/7/2007
% MODIFIED: 11/20/2007

positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def' };
datadir = [cd '/data/wk' num2str(week) '/processed'];
pdata = []; ddata = [];

% Get player data
playermask = {'Name', '%s'; 'FFPts', '%f'};
for n = 1:length(positions)
    fname = [positions{n} '.fftoday'];
    pdata.(positions{n}) = ParseFile( fullfile(datadir, fname), playermask );
end