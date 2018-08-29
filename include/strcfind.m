function o = strcfind(str,c)
o = false;
for i = 1:numel(c)
    o = o | ~isempty(strfind(str,c{i}));
end
end