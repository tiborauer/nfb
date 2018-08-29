function out = nfb_train_analyze2res_loc(fini,is2write)
mhead={'','delay';'','beta';'','t';'','PSC'};
if ischar(fini)
    ini = IniFile(fini);
    if ~ini.isValid, return; end
else
    ini = fini;
end
resfile = strrep(fullfile(ini.directories.resdir,ini.files.resfile),'.mat','_loc.mat');
if exist(resfile,'file')
    load(resfile);
else
    error('Results file not found!');
end

for s = 1:size(meas,1)
    out{s} = [];
    for v = 1:size(res,2)
        out{s}(:,end+1:end+5) = res{s,v};
        out{s}(:,end-2) = out{s}(:,end-4) - out{s}(:,end-3);
        out{s}(:,end+1) = out{s}(:,end-1) - out{s}(:,end);
    end
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