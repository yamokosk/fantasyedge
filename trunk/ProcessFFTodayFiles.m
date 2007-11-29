function ProcessFFTodayFiles(week)
% Function to process data scrapped from FFToday websites

% AUTHOR: J.D. Yamokoski
% DATE: 11/7/2007

positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def'};

% Load abbreviation data from a text file located in the data directory
fid = fopen( fullfile(cd, 'data', 'FullTeamName2Abbrev.data') );
nameLookup = textscan(fid, '%s %s', 'delimiter', '\t\n', 'multipledelimsasone', 1);
fclose(fid);

% For all the players... vs. def
for n = 1:length(positions)
    fname = ['defV' positions{n} '.fftoday'];

    % Open the raw data file and scan it all into a single string.. easier to
    % operate on in this form.
    fin = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'raw', fname) );
    if (fin > 0)
        fout = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'processed', fname), 'w');

        % Fix the file header
        header = FixHeader(fgetl(fin));
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
end

% For all the FFToday player data...
for n = 1:length(positions)
    fname = [positions{n} '.fftoday'];

    % Open the raw data file and scan it all into a single string.. easier to
    % operate on in this form.
    fin = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'raw', fname) );
    if (fin > 0)
        fout = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'processed', fname), 'w');

        % Fix the file header
        header = FixPlayerHeader(fgetl(fin), positions{n});
        fprintf(fout, '%s\n', header);

        while (~feof(fin))
            % Get a line of text from the input file..
            line = fgetl(fin);

            switch (positions{n})
                case 'def'
                    % Replace the long team name with its abbreviation
                    for m=1:length(nameLookup{1})
                        line = regexprep(line, nameLookup{1}(m), nameLookup{2}(m));
                        line = regexprep(line, '\s+\d+\.\s+', '');
                    end
                otherwise
                    % Replace the long team name with its abbreviation
                    line = FixPlayerName(line);
            end
            
            % Lastly write the new line to the out file
            fprintf(fout, '%s\n', line);
        end
        fclose(fin);
        fclose(fout);
    end
end


function header = FixHeader(header)
header = regexprep(header, '\/', 'P');

function header = FixPlayerHeader(header, pos)
switch (pos)
    case 'qb'
        header = 'Name	Team	G	GS	Comp	Att	PassYard	PassTD	INT	Att	RushYard	PassTD	FFPts	FFPtsPG';
    case 'rb'
        header = 'Name	Team	G	GS	Att	RushYard	RushTD	Target	Rec	RecYard	RecTD	FFPts	FFPtsPG';
    case 'wr'
        header = 'Name 	Team	G	GS	Target	Rec	RecYard	RecTD	FFPts	FFPtsPG';
    case 'te'
        header = 'Name 	Team	G	GS	Target	Rec	RecYard	RecTD	FFPts	FFPtsPG';
    case 'k'
        header = 'Name	Team	G	FGM	FGA	FG%	EPM	EPA	FFPts	FFPtsPG';
    case 'def'
        header = 'Name	G	Sack	FR	INT	DefTD	PA	PaYdPG	RuYdPG	Safety	KickTD	FFPts	FFPtsPG';
end
        
function line = FixPlayerName(line)
% Special cases
spcases = {'St.Smith', 'Steve Smith'; ...
           'Ch.Johnson', 'Chad Johnson'; ...
           'Ro.Williams', 'Roy Williams'; ...
           'Re.Williams', 'Reggie Williams'; ...
           'Ca.Johnson', 'Calvin Johnson'; ...
           'Ja.Jones', 'James Jones'; ...
           'Sa.Moss', 'Santana Moss'; ...
           'Ma.Jones', 'Mark Jones'; ...
           'Ma.Clayton', 'Mark Clayton'; ...
           'Ad.Peterson', 'Adrian Peterson'; ...
           'St.Jackson', 'Steven Jackson'; ...
           'M.Jones-Drew', 'Maurice Jones-Drew'};
[nr,nc] = size(spcases);
for n = 1:nr
    ind = strfind(line, spcases{n,2});
    if ( ~isempty( ind ) ) 
        line = [spcases{n,1}, line(ind+length(spcases{n,2}):end)]; 
        return; 
    end
end

% Trouble names
%   Ted Ginn Jr.
if ( ~isempty( strfind(line, 'Ted Ginn Jr.') ) ) line = regexprep(line, 'Ted Ginn Jr.', 'Ted Ginn'); end

% First pull out name
% Match NN. = [0-9]+\.
expr = '[0-9]+\.\s+(?<firstI>[A-Z])';
%m = regexp(line, expr, 'match');
[t1, n1] = regexp(line, expr, 'tokens', 'names');
expr = '(?<LastN>\w+)\s+(?<TeamAbbrev>([A-Z]{3}|[A-Z]{2}))';%(?<firstI>[A-Z,a-z]+\.)\s+(?<lastN>\w+)|(?<firstI>\w+)\s\(';
%m = regexp(line, expr, 'match');
[t2, n2] = regexp(line, expr, 'tokens', 'names');

ind = strfind(line, n2(1).TeamAbbrev);
line = [n1(1).firstI '.' n2(1).LastN '   ' line(ind:end) ];

%fprintf('%s\n', [names1(1).firstI '. ' names2(1).LastN]);