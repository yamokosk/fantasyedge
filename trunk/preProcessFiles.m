function preProcessFiles(week)

positions = {'matchup'; 'def_rushing'; 'def_passing'; 'def_receiving'; 'qb'; 'rb'; 'wr'; 'te'; 'k'};
newheaders = {'Sunday, October 14  	Time (EST)  	Tickets  	Network  	Channel  	HD Channel  	Home  	Away  	Westwood One'; ...
    'Team  	  	Games  	 	Rush  	 	RushYds  	 	RushAvg  	 	RushPG  	 	RushYPG  	 	RushTD  	 	Rush1stD  	 	RushLng'; ...
    'Team  	  	Games  	 	AttPG  	 	CompPG  	 	Pct  	 	PassYds  	 	PassYPG  	 	PassTD  	 	Int  	 	Pass1stD  	 	Sack  	 	SackYdsL  	 	SackLng'; ...
    'Team  	  	Games  	 	Rec  	 	RecYds  	 	RecPG  	 	RecYPG  	 	RecTD  	 	Rec1stD  	 	RecLng'; ...
    'First Last  	Team  	Games  	  	QBRat  	PassComp  	PassAtt  	Pct  	PassYds  	PassYPG  	PassYPA  	PassTD  	Int  	 	Rush  	RushYds  	RushYPG  	RushAvg  	RushTD  	 	Sack  	SackYds  	 	Fum  	FumL'; ...
    'First Last  	Team  	Games  	  	Rush  	RushYds  	RushYPG  	RushAvg  	RushTD  	 	Rec  	RecYds  	RecYPG  	RecAvg  	Lng  	YAC  	1stD  	RecTD  	 	Fum  	FumL'; ...
    'First Last  	Team  	Games  	  	Rec  	RecYds  	RecYPG  	RecAvg  	RecLng  	YAC  	Rec1stD  	RecTD  	 	KR  	KRYds  	KRAvg  	KRLong  	KRTD  	 	PR  	PRYds  	PRAvg  	PRLong  	PRTD  	 	Fum  	FumL'; ...
    'First Last  	Team  	Games  	  	Rec  	RecYds  	RecYPG  	RecAvg  	RecLng  	YAC  	Rec1stD  	RecTD  	 	Rush  	RushYds  	RushYPG  	RushAvg  	RushTD  	 	Fum  	FumL'; ...
    'First Last  	Team  	Games  	  	FG19  	FG29  	FG39  	FG49  	FG50  	FGM  	FGA  	Pct  	Lng  	 	XPM  	XPA  	Pct  	 	Pts'};
% Load abbreviation data from a text file located in the data directory
fid = fopen( fullfile(cd, 'data', 'FullTeamName2Abbrev.data') );
nameLookup = textscan(fid, '%s %s', 'delimiter', '\t\n', 'multipledelimsasone', 1);
fclose(fid);

% For all the positions...
for n = 1:length(positions)
    fname = [positions{n} '_week_' num2str(week) '.data'];

    % Open the raw data file and scan it all into a single string.. easier to
    % operate on in this form.
    fin = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'raw', fname) );
    fout = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'processed', fname), 'W');
    
    % Write a new file header
    line = fgetl(fin);
    fprintf(fout, '%s\n', newheaders{n});
    
    while (~feof(fin))
        % Get a line of text from the input file..
        line = fgetl(fin);
       
        % Then for each team name in the data file, replace it with its
        % abbreviation.
        for n = 1:length(nameLookup{1,1})
            line = regexprep(line, nameLookup{1,1}(n), nameLookup{1,2}(n));
        end
    
        % Also replace anything else that is "nasty" before writing this to a
        % new file..
        
        % The Marion Barber III fix
        line = regexprep(line, 'Marion(\s*)Barber(\s*)III', 'Marion Barber');
    
        % Lastly write the new line to the out file
        fprintf(fout, '%s\n', line);
    end
    fclose(fin);
    fclose(fout);
end