function resout = nfb_train_analyze2res(fini,is2write)
mhead={'','delay';'','beta';'','t';'','PSC'};
if ischar(fini)
    ini = IniFile(fini);
    if ~ini.isValid, return; end
else
    ini = fini;
end
if exist(fullfile(ini.directories.resdir,ini.files.resfile),'file')
    load(fullfile(ini.directories.resdir,ini.files.resfile));
else
    error('Results file not found!');
end
% if exist('res_fb','var'), res = res_fb; end
% [meas res] = nfb_train_select(fini);

s = 2; v = 5; t = 4;
tasks = unique(lower(ini.training.m1));
switch numel(tasks)
    case 1
        m_task = 1;
    case 2
        m_task = [-1 1];
end
nTr = numel(findstr(ini.training.m1,upper(tasks(1))));
[R, W] = get_ROIs(ini.training);
indMeas = find(isnan(W)); indCalc = find(~isnan(W));
for t = 1:numel(tasks)
    for s = 1:size(meas,1)
        out{s} = res{s,1,t};
        out{s}(:,end-2) = m_task(t)*out{s}(:,indCalc)*W(indCalc)';
        out{s}(:,end+1) = m_task(t)*(out{s}(:,end-1) - out{s}(:,end));
        for v = ini.series.base_st+1:ini.series.base_st+ini.training.nm            
            if v > size(meas,2), break; end
            for tr = 1:nTr
                if  ~isempty(meas{s,v,tr+(t-1)*nTr})
                    out{s}(:,end+1:end+numel(R)) = res{s,v,tr+(t-1)*nTr};
                    out{s}(:,end-2) = m_task(t)*res{s,v,tr+(t-1)*nTr}(:,indCalc)*W(indCalc)';
                    out{s}(:,end+1) = m_task(t)*(out{s}(:,end-1) - out{s}(:,end));
                else
                    out{s}(:,end+1:end+numel(R)) = NaN;
                    out{s}(:,end-2) = NaN;
                    out{s}(:,end+1) = NaN;
                end
            end
        end
        for vv = v+1:size(meas,2)
            if ~isempty(meas{s,vv,1})
                out{s}(:,end+1:end+numel(R)) = res{s,vv,t};
                out{s}(:,end-2) = m_task(t)*res{s,vv,t}(:,indCalc)*W(indCalc)';
                out{s}(:,end+1) = m_task(t)*(out{s}(:,end-1) - out{s}(:,end));
            else
                out{s}(:,end+1:end+numel(R)) = NaN;
                out{s}(:,end-2) = NaN;
                out{s}(:,end+1) = NaN;
            end
        end
    end
    resout{t} = out;
end

% if (nargin > 1) && is2write
%     w = str2num(ini.training.fb); w0 = find(w==0);
%     R = {ini.training.(['roi' num2str(find(w>0))]) ini.training.(['roi' num2str(find(w<0))])};
%     R{3} = [R{1} '-' R{2}];
%     for i = 1:numel(w0)
%         R{end+1} = ini.training.(['roi' num2str(w0(i))]);
%     end
%     R{6} = [R{4} '-' R{5}];
%     head = ['\t\t' sprintf('%8s',R{1}) '\t' sprintf('%8s',R{2}) '\t' sprintf('%8s',R{3}) ...
%         '\t' sprintf('%8s',R{4}) '\t' sprintf('%8s',R{5}) '\t' sprintf('%8s',R{6})];
%     
%     if ispc, xls = fullfile(ini.directories.resdir, 'Overview.xls'); end
%     for i = 1:numel(tasks)
%         f(i) = fopen(fullfile(ini.directories.resdir, ['Overview_' tasks(i) '.dat']), 'w');
%         fprintf(f(i), '\t');
%         for n = 1:size(out{1},2)/6
%             fprintf(f(i), head);
%         end;
%         fprintf(f(i), '\n');
%     end
%     
%     for s = 1:numel(out)
%         form = '%s\t%s';
%         for fi = 1:size(out{s},2)/6
%             form = [form '\t\t% 8.4f\t% 8.4f\t% 8.4f\t% 8.4f\t% 8.4f\t% 8.4f'];
%         end;
%         form = [form '\n'];
%         
%         c2w = mhead; c2w{1,1} = meas{s,1,1}(1:end-10);
%         for i = 1:numel(tasks)
%             for c = 1:size(resout{i}{s},2), for r = 1:4, c2w{r,2+c} = resout{i}{s}(r,c); end; end
%             if ispc, xlswrite(xls,c2w,['Results_' tasks(i)],['A' num2str(3+(s-1)*4)]); end
%             for row=1:4
%                 fprintf(f(i), form, c2w{row,:});
%             end
%             fprintf(f(i), '\n');
%         end
%     end
%     
%     for i = 1:numel(tasks)
%         fclose(f(i));
%     end
% end