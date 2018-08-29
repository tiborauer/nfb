function fo = isInDB(fi,pr)
where={''
    'results/RealTimeData'
    'tbv'
    'results/tbv'
    };
if ispc, where = strrep(where,'/','\'); end
if nargin > 1, where = vertcat(where{pr}, where); end
ind = findstr(fi, 'vol') + 8;
for i = 1:numel(where)
    fo = fullfile(fi(1:ind-1),where{i},fi(ind:end));
    if exist(fo), break; end
end

if ~exist(fo), fo = ''; end
end
