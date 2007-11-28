function data = LoadData(week)
% USAGE: data = LoadData(week_number)
%   Make sure that the data files for the week have been processed by
%   calling ProcessFiles(week_number) first.
positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def_rushing'; 'def_passing'; 'def_receiving'; };
datadir = [cd '/data/wk' num2str(week) '/processed'];
defaultmask = {'First', '%s'; 'Last', '%s'; 'Team', '%s'; 'Games', '%f'};

% QB
n = 1;
mask = [defaultmask; {'PassYds', '%f'; 'PassTD', '%f'; 'RushYds', '%f'; 'RushTD', '%f'; 'Int', '%f'}];
fname = [positions{n} '_week_' num2str(week) '.data'];
data.(positions{n}) = loadFFFile( fullfile(datadir, fname), mask );

% RB
n = 2;
mask = [defaultmask; {'RushYds', '%f'; 'RushTD', '%f'; 'RecYds', '%f'; 'RecTD', '%f'; 'FumL', '%f'}];
fname = [positions{n} '_week_' num2str(week) '.data'];
data.(positions{n}) = loadFFFile( fullfile(datadir, fname), mask );

% WR
n = 3;
mask = [defaultmask; {'RecYds', '%f'; 'RecTD', '%f'; 'FumL', '%f'}];
fname = [positions{n} '_week_' num2str(week) '.data'];
data.(positions{n}) = loadFFFile( fullfile(datadir, fname), mask );

% TE
n = 4;
mask = [defaultmask; {'RecYds', '%f'; 'RecTD', '%f'; 'FumL', '%f'}];
fname = [positions{n} '_week_' num2str(week) '.data'];
data.(positions{n}) = loadFFFile( fullfile(datadir, fname), mask );

% K
n = 5;
mask = [defaultmask; {'FG19', '%f'; 'FG29', '%f'; 'FG39', '%f'; 'FG49', '%f'; 'FG50', '%f'; 'XPM', '%f'}];
fname = [positions{n} '_week_' num2str(week) '.data'];
data.(positions{n}) = loadFFFile( fullfile(datadir, fname), mask );

% def_rushing
n = 6;
mask = {'Team', '%s'; 'Games', '%f'; 'RushYds', '%f'; 'RushTD', '%f'};
fname = [positions{n} '_week_' num2str(week) '.data'];
data.(positions{n}) = loadFFFile( fullfile(datadir, fname), mask );

% def_passing
n = 7;
mask = {'Team', '%s'; 'Games', '%f'; 'PassYds', '%f'; 'PassTD', '%f'; 'Int', '%f'};
fname = [positions{n} '_week_' num2str(week) '.data'];
data.(positions{n}) = loadFFFile( fullfile(datadir, fname), mask );

% def_receiving
n = 8;
mask = {'Team', '%s'; 'Games', '%f'; 'RecYds', '%f'; 'RecTD', '%f'};
fname = [positions{n} '_week_' num2str(week) '.data'];
data.(positions{n}) = loadFFFile( fullfile(datadir, fname), mask );

    
% Matchup data
fid = fopen( fullfile(datadir, ['matchup_week_' num2str(week) '.data']) );
expr = '(?<away>\w+)\s+@\s+(?<home>\w+)';
matchups = {};
while 1
    tline = fgetl(fid);
    if ~ischar(tline) break; end
    
    [tokens, game] = regexp(tline, expr, 'tokens', 'names');
    
    if ~isempty(tokens)
        matchups = [matchups; {game.home, game.away}];
    end
end
