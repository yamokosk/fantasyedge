function ProcessFFTodayFiles(week)
% Function to process data scrapped from FFToday websites

% AUTHOR: J.D. Yamokoski
% DATE: 11/7/2007

positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def'};

% Load abbreviation data from a text file located in the data directory
fid = fopen( fullfile(cd, 'data', 'FullTeamName2Abbrev.data') );
nameLookup = textscan(fid, '%s %s', 'delimiter', '\t\n', 'multipledelimsasone', 1);
fclose(fid);

% For all the players...
for n = 1:length(positions)
    fname = ['defV' positions{n} '.fftoday'];

    % Open the raw data file and scan it all into a single string.. easier to
    % operate on in this form.
    fin = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'raw', fname) );
    fout = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'processed', fname), 'w');
    
    % Write a new file header
    header = fgetl(fin);
    fprintf(fout, '%s\n', header);
    
    while (~feof(fin))
        % Get a line of text from the input file..
        line = fgetl(fin);
        
        % Replace the long team name with its abbreviation
        for m=1:length(nameLookup{1})
            line = regexprep(line, nameLookup{1}(m), nameLookup{2}(m));
        end

        % Need to replace stuff like this:
        %   1. Cin vs. WR to Cin
        line = regexprep(line, '\s+\d+\.\s+', '');
        line = regexprep(line, '\s+vs.\s+\w+', '');

        % Lastly write the new line to the out file
        fprintf(fout, '%s\n', line);
    end
    fclose(fin);
    fclose(fout);
end