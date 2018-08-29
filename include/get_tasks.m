function task = get_tasks(tr)
for t = 1:numel(unique(tr.m0))
    task{t} = tr.(['task' num2str(t)]);
end