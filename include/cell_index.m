function i = cell_index(lines, str, nl, ni)
if nargin < 3
    nl = 1;
end
for i = nl:numel(lines)
    test = lines{i};
    if iscell(test) || (size(test,1) > 1)
        test = [];
        continue; 
    end
    if size(test,1) > size(test,2), test = test';  end
    if ~ischar(test), test = num2str(test); end
    test = strfind(test,str);
    if ~isempty(test) && ((nargin < 4) || ((nargin > 3) && any(test == ni))), break, end
end
if isempty(test)
    i = 0;
end
