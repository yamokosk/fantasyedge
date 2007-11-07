function ProcessFiles(week)
% USAGE: ProcessFiles(week_number)
%   Cleans up the data scrapped from the Yahoo and FFToday websites. This
%   function assumes that data is saved off the current directory in the
%   following directory structure:
%       current_directory
%           |- data
%               |- wk9
%                   |- raw (Raw data scrapped from websites)
%               |- wk10
%                   |- raw (Raw data scrapped from websites)

% AUTHOR: J.D. Yamokoski
% DATE: 11/7/2007

% Create the processed directory
mkdir( fullfile(cd, 'data', ['wk' num2str(week)], ''), 'processed' );

% Now process the files
ProcessYahooFiles(week);
ProcessFFTodayFiles(week);