function ProcessFFTodayFiles(week)

positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def'};
posheaders = {'First	Last    Team	Opp	Action	Price	Change	TD	Pass	Yds	Int	Rush	Yds	Rec	Yds	2-PT	Fum	Lost	AVG	PTS'; ...
    'First	Last	Team    Opp	Action	Price	Change	TD	Pass	Yds	Int	Rush	Yds	Rec	Yds	2-PT	Fum	Lost	AVG	PTS'; ...
    'First	Last	Team    Opp	Action	Price	Change	TD	Pass	Yds	Int Rush    Yds	Rec Yds	2-PT	Fum Lost	AVG	PTS'; ...
    'First	Last	Team    Opp	Action	Price	Change	TD	Pass	Yds	Int	Rush	Yds	Rec	Yds	2-PT	Fum	Lost	AVG	PTS'; ...
    'First	Last 	Team    Opp	Action	Price	Change	FG  FG19	FG29	FG39	FG49	FG50	PAM AVG	PTS'; ...
    'Team   Opp	Action	Price	Change	Sack	Int	Fum	TD	Safe	BlkKick	PtsAllow	AVG	PTS'};

% Load abbreviation data from a text file located in the data directory
fid = fopen( fullfile(cd, 'data', 'FullTeamName2Abbrev.data') );
nameLookup = textscan(fid, '%s %s', 'delimiter', '\t\n', 'multipledelimsasone', 1);
fclose(fid);

% For all the players...
for n = 1:length(positions)
    fname = [positions{n} '.yahoo'];

    % Open the raw data file and scan it all into a single string.. easier to
    % operate on in this form.
    fin = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'raw', fname) );
    fout = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'processed', fname), 'w');
    
    % Write a new file header
    line = fgetl(fin);
    fprintf(fout, '%s\n', line);
    
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
            % If this is a defense we need to replace its name
            for m=1:length(nameLookup{1})
                line = regexprep(line, nameLookup{1}(m), nameLookup{2}(m));
            end
            
            % Also need to strip out the $ signs
            line = regexprep(line, '\$', '');
            
            % Replace '[ BUY ]' with a 1 or 0 for home or away
            bHomeGame = false;
            if (isempty(findstr(line, '@')))
                bHomeGame = true;
            end
             
            line = regexprep(line, '\@', '');
            line = regexprep(line, '\[\s+BUY\s+\]', '');
            bIsHome = true;
            % In the yahoo files we need to replace stuff like:
            %   Detroit (Det - DEF) with Detroit
            %   P. Manning (Ind - QB) with P.Manning
            %expr = '(?<first>\w+)\s+(?<last>\w+)|(?<last>\w+),\s+(?<first>\w+)';
            playerexpr = '(?<firstI>[A-Z,a-z]\.)\s+(?<lastN>\w+)|(?<firstI>\w+)\s\(';
            [tokens, names] = regexp(line, playerexpr, 'tokens', 'names');
            
            % Now find the ')'
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