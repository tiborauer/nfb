function des = ref2des(fname)
fid = fopen(fname,'r');
C = textscan(fid,'%f');
fclose(fid);
des = mod(C{1},11);
