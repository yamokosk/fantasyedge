function ProcessYahooFiles(week)
% Function to process data scrapped from Yahoo websites

% AUTHOR: J.D. Yamokoski
% DATE: 11/7/2007

positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def'};

% Load abbreviation data from a text file located in the data directory
fid = fopen( fullfile(cd, 'data', 'FullTeamName2Abbrev.data') );
nameLookup = textscan(fid, '%s %s', 'delimiter', '\t\n', 'multipledelimsasone', 1);
fclose(fid);

% For each of the position files...
for n = 1:length(positions)
    fname = [positions{n} '.yahoo'];

    % Get some file pointers
    fin = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'raw', fname) );
    fout = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'processed', fname), 'w');
    
    % Fix the header
    header = fgetl(fin);
    header = regexprep(header, 'Name\s+Opp\s+Action', 'Name	Home	Opp');
    fprintf(fout, '%s\n', header);
    
    while (~feof(fin))
        % Get a line of text from the input file..
        line = fgetl(fin);
        
        % Look for any of the following.. NA, IR, O, Bye after the player's
        % name. If it exists then skip that player
        bContinue = true;
        expr = {'[A-Z]\w*NA', '[A-Z]\w*O', '[A-Z]\w*IR', '\s*Bye\s*'};
        for n = 1:length(expr)
            str = regexp(line, expr{n});
            if ~isempty(str)
                bContinue = false;
                break;
            end
        end
        
        if (bContinue)
            % Replace the long team name with its Yahoo abbreviation
            for m=1:length(nameLookup{1})
                line = regexprep(line, nameLookup{1}(m), nameLookup{2}(m));
            end
            
            % Determine if the player is home or away (look for the @)
            bHomeGame = false;
            if (isempty(findstr(line, '@')))
                bHomeGame = true;
            end
            
            % Strip out $, @, and [ BUY ]
            line = regexprep(line, '\$', '');
            line = regexprep(line, '\@', '');
            line = regexprep(line, '\[\s+BUY\s+\]', '');
            
            % Replace stuff like:
            %   Detroit (Det - DEF) with Detroit
            %   P. Manning (Ind - QB) with P.Manning
            expr = '(?<firstI>[A-Z,a-z]\.)\s+(?<lastN>\w+)|(?<firstI>\w+)\s\(';
            [tokens, names] = regexp(line, expr, 'tokens', 'names');
            
            % Find the ')'
            loc = findstr(line, ')');
            
            if (~isempty(loc))
                newname = [names(1).firstI names(1).lastN];
                % Lastly write the new line to the out file
                fprintf(fout, '%s\t%d\t%s\n', newname, bHomeGame, line(loc+1:end));
            end
        end
    end
    fclose(fin);
    fclose(fout);
end