function str = struct_extract(st1, st2pf)
if nargin == 1
    st2pf = '';
else
    st2pf = [st2pf '.'];
end
str = '';
fields = fieldnames(st1);
for i = 1:numel(fields)
    stval = st1.(fields{i});
    if isempty(stval)
        val = [fields{i} '=[];'];        
    elseif ischar(stval)
        val = [fields{i} '=''' stval ''';'];
    elseif iscell(stval) % no solution
        val = [fields{i} '=''not supported'';'];        
    elseif numel(stval)-1
        val = '';
        for x = 1:size(stval,1)
            for y = 1:size(stval,2)
                val = [val fields{i} '(' num2str(x) ',' num2str(y) ')=' num2str(stval(x,y)) ';'];
            end
        end
    elseif isstruct(stval) % no solution
        val = [fields{i} '=''not supported'';'];        
    else % single number
        val = [fields{i} '=' num2str(stval) ';'];
    end
    if islogical(stval)
       val = [val st2pf fields{i} '=logical(' fields{i} ');'];
    end
    str = [str st2pf val];
end