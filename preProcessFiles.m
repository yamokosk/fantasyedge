function preProcessFiles(week)

positions = {'qb'; 'rb'; 'wr'; 'te'; 'k'; 'def'; 'def};
newheaders = {'First	Last    Team	Opp	Action	Price	Change	TD	Pass	Yds	Int	Rush	Yds	Rec	Yds	2-PT	Fum	Lost	AVG	PTS'; ...
    'First	Last	Team    Opp	Action	Price	Change	TD	Pass	Yds	Int	Rush	Yds	Rec	Yds	2-PT	Fum	Lost	AVG	PTS'; ...
    'First	Last	Team    Opp	Action	Price	Change	TD	Pass	Yds	Int Rush    Yds	Rec Yds	2-PT	Fum Lost	AVG	PTS'; ...
    'First	Last	Team    Opp	Action	Price	Change	TD	Pass	Yds	Int	Rush	Yds	Rec	Yds	2-PT	Fum	Lost	AVG	PTS'; ...
    'First	Last 	Team    Opp	Action	Price	Change	FG  FG19	FG29	FG39	FG49	FG50	PAM AVG	PTS'; ...
    'Team   Opp	Action	Price	Change	Sack	Int	Fum	TD	Safe	BlkKick	PtsAllow	AVG	PTS';...
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
    fname = [positions{n} '.yahoo'];

    % Open the raw data file and scan it all into a single string.. easier to
    % operate on in this form.
    fin = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'raw', fname) );
    fout = fopen( fullfile(cd, 'data', ['wk' num2str(week)], 'processed', fname), 'w');
    
    % Write a new file header
%     line = fgetl(fin);
%     fprintf(fout, '%s\n', newheaders{n});
    
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
    end
    fclose(fin);
    fclose(fout);
end