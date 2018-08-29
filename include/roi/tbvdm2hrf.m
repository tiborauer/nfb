function hrf = tbvdm2hrf(fname)
fid = fopen(fname,'r');
C = textscan(fid,'%f\t%f\t%f');
hrf = C{1};
fclose(fid);