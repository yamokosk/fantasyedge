function [data,matchups] = loadData(week)

% Formats and filenames
in(1).format = '';
in(1).filename = ['qb_week_' num2str(week) '.data'];
in(2).format = '%s %s %s %f %*f %f %*f %*f %f %*f %f %*f %*f %*f %*f %*f %f %*f %f';
in(2).filename = ['rb_week_' num2str(week) '.data'];
in(3).format = '';
in(3).filename = ['wr_week_' num2str(week) '.data'];
in(4).format = '';
in(4).filename = ['te_week_' num2str(week) '.data'];
in(5).format = '';
in(5).filename = ['k_week_' num2str(week) '.data'];
in(6).format = '';
in(6).filename = ['def_passing_week_' num2str(week) '.data'];
in(7).format = '%s %s %f %*f %f %*f %*f %f %*f %*f';
in(7).filename = ['def_receiving_week_' num2str(week) '.data'];
in(8).format = '%s %s %f %*f %f %*f %*f %*f %f %*f %*f';
in(8).filename = ['def_rushing_week_' num2str(week) '.data'];

data = [];
for n = 1:length(in)
    fid = fopen( in(n).filename );
    
    if ( ~strcmp(in(n).format, '') )
        data(n).rawdata = textscan(fid, in(n).format, 'multipleDelimsAsOne', 1, ...
                                                     'headerLines', 1);
    end
    fclose(fid);
end


% Matchup data
fid = fopen(['schedule_week_' num2str(week+1) '.data']);
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