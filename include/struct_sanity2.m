function s_out = struct_sanity2(s_in, s_def, loc)
s_out = s_in;

if ~isstruct(s_def), return; end

if nargin < 3, loc = 'ROOT'; end

fields_in = fieldnames(s_in);
fields_def = fieldnames(s_def);

for field = 1:numel(fields_def)
    if isempty(find(strmatch(fields_def{field},fields_in,'exact'),1))
        fprintf('Missing: %s/%s\n',loc,fields_def{field});
        s_out.(fields_def{field}) = s_def.(fields_def{field});
    else
        if (numel(s_def.(fields_def{field})) > 1) || (numel(s_in.(fields_def{field})) > 1)
            if numel(s_def.(fields_def{field})) ~= numel(s_in.(fields_def{field}))
                fprintf('Mismatch: %s/%s\n',loc,fields_def{field});
            end
%             for i = 1:numel(s_def.(fields_def{field}))
%                 if numel(s_in.(fields_def{field})) < i
%                     s_out.(fields_def{field})(i) = s_def.(fields_def{field})(i);
%                 else
%                     if isstruct(s_def.(fields_def{field})(i))
%                         s_out.(fields_def{field})(i) = struct_sanity2(s_in.(fields_def{field})(i),s_def.(fields_def{field})(i));
%                     end
%                 end
%             end
        elseif isstruct(s_def.(fields_def{field}))
            try
            s_out.(fields_def{field}) = struct_sanity2(s_in.(fields_def{field}),s_def.(fields_def{field}),[loc '/' fields_def{field}]);
            catch err
                disp(err)
            end
        end
    end
end
end