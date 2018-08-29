function info = info_parser(str,n)
if nargin < 2, n = 1; end
info = {};
for i = n:numel(str)
    if ~isempty(str{i})
        ind = findstr(str{i},': ');
        info{end+1,1} = str{i}(1:ind(1)-1);
        info{end,2} = str{i}(ind(1)+2:end);
    end
end