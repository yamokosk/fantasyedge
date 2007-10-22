function preProcessFiles(week)

fname = 'def_rushing_week_5.data';
fid = fopen(fname);
scan = textscan(fid, '%s', 'whitespace', '');
fclose(fid);
rawstr = cell2mat(scan{1});

fid = fopen('FullTeamName2Abbrev.data');
nameLookup = textscan(fid, '%s %s', 'delimiter', '\t\n', 'multipledelimsasone', 1);
fclose(fid);

for n = 1:32
    rawstr = regexprep(rawstr, nameLookup{1,1}(n), nameLookup{1,2}(n));
end


fid = fopen('def_rushing_week_5p.data','W');
fprintf(fid, '%s', rawstr);
fclose(fid);