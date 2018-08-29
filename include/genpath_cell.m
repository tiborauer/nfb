function c = genpath_cell(d)
str = genpath(d);
if isunix
    sel = ':';
else
    sel = ';';
end
ind = [0 find(str == sel)];
for i = 1:numel(ind)-1
    c{i} = str(ind(i)+1:ind(i+1)-1);
end
