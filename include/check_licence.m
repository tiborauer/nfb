function out = check_licence(func)
for i = 1:numel(func)
    out(i) = 0;
    try
        eval(func{i});
    catch em
        switch em.identifier
            case 'MATLAB:license:checkouterror'
                out(i) = 1;
        end
    end
end