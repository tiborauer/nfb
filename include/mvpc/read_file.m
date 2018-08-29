function lines = read_file(fn)
fid = fopen(fn, 'r');
nl = 0;
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    nl = nl + 1;
    lines{nl} = tline;
end
fclose(fid);
