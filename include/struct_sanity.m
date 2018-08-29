function s_out = struct_sanity(s_in, s_def)
s_out = s_in;
fields_in = fieldnames(s_in);
fields_def = fieldnames(s_def);

for field = 1:numel(fields_def)
    if isempty(find(strmatch(fields_def{field},fields_in),1))
        disp(fields_def{field});
        s_out.(fields_def{field}) = s_def.(fields_def{field});
    else
        if isstruct(s_def.(fields_def{field})) 
            s_out.(fields_def{field}) = struct_sanity(s_in.(fields_def{field}),s_def.(fields_def{field})); 
        end
    end
end
