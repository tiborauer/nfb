function nfb_train_plot(varargin)
meas = {'delay','PE','PSC'};
meas_label  = {'delay','PE','% signal change'};
gr = {'Control' 'Train'};
% sig = [4 15; 7 17];

fs = get(0,'ScreenSize');
while (fs(3) > fs(4))
    fs(3) = fs(3)/2;
end
fs(3) = fs(4)*4/3;

fini = varargin{1};
if ischar(fini)
    ini = IniFile(fini);
    if ~ini.isValid, return; end
else
    ini = fini;
end
task = get_tasks(ini.training);
sfx = strrep(strrep(ini.files.resfile,'results',''),'.mat','');

ind = cell_index(varargin,'vol');
if ind
    vol = varargin{ind+1};
    if strcmp(vol,'all')
        vol_list = 1:ini.volunteers.nvol;
    else
        vol_list = varargin{ind+1};
        for i = 1:numel(vol_list)
            for s = 1:ini.volunteers.nvol
                if strcmp(ini.volunteers.(['vol' num2str(s)]), vol_list{i})
                    vol_list{i} = s;
                end
            end
        end
        vol_list = cell2mat(vol_list);
    end
else
    vol = 'group';
end

ind = cell_index(varargin,'res');
if ind
    out = varargin{ind+1};
end
if ~exist('out','var')
    out = nfb_train_analyze2res(fini); 
%     out_t = out{1};
%     out{1} = out{2};
%     out{2} = out_t;
end

[R W pl] = get_ROIs(ini.training);
pl_ind{1} = pl.ind1; pl_ind{2} = pl.ind2; leg = pl.leg; col = pl.col; lsp = pl.lsp; clear pl;

nc = ini.volunteers.nvol-ini.volunteers.nTr; % # Control
tasks = unique(lower(ini.training.m1));
for s = 1:ini.volunteers.nvol
    for m = 1:size(out{1}{s},2)/numel(leg)
        for r = 1:numel(leg)
            for t = 1:numel(tasks)
                res{t}.(meas{1})(s,m,r) = out{t}{s}(1,(m-1)*numel(leg)+r);% - out{t}{s}(1,r);
                res{t}.(meas{2})(s,m,r) = out{t}{s}(2,(m-1)*numel(leg)+r);% - out{t}{s}(2,r);
                res{t}.(meas{3})(s,m,r) = out{t}{s}(4,(m-1)*numel(leg)+r);% - out{t}{s}(4,r);
            end
        end
    end
end

% training effect, Creates a text file (CSV) , calculates transfer effect

for r = 1:numel(leg)
    if strcmp(leg{r},'Measured'), break; end
end
ind_Meas = r;

oMeas = {'delay','PE','t','PSC'};
nMeas = 4;
head = 'Name';
for i = 1:numel(task)
    for r = 1:ind_Meas
        head = [head ';' task{i}(1) '_' leg{r}];
    end
end
head = [head '\n'];
resfile = ['meas_' oMeas{nMeas} '_C' num2str(nc) 'T' num2str(ini.volunteers.nTr) sfx '.csv'];
fid = fopen(resfile,'w');
fprintf(fid,head);
for s = 1:ini.volunteers.nvol
    fprintf(fid, '%s;', ini.volunteers.(['vol' num2str(s)]));
    for t = 1:numel(task)
        for r = 1:ind_Meas
            dat = out{t}{s}(nMeas,size(out{t}{s},2)-numel(leg)+r) - out{t}{s}(nMeas,r);
            fprintf(fid,'%6.4f;',dat);    
            if strcmp(leg{r},'Measured'), break; end
        end
    end
    fprintf(fid, '\n');
end
fclose(fid);

head = 'Name';
for i = 1:numel(task)
    for r = ind_Meas+1:numel(leg)
        head = [head ';' task{i}(1) '_' leg{r}];
    end
end
head = [head '\n'];
resfile = ['notmeas_'  oMeas{nMeas} '_C' num2str(nc) 'T' num2str(ini.volunteers.nTr) sfx '.csv'];
fid = fopen(resfile,'w');
fprintf(fid,head);
for s = 1:ini.volunteers.nvol
    fprintf(fid, '%s;', ini.volunteers.(['vol' num2str(s)]));
    for t = 1:numel(task)
        for r = ind_Meas+1:numel(leg)
            dat = out{t}{s}(nMeas,size(out{t}{s},2)-numel(leg)+r) - out{t}{s}(nMeas,r);
            fprintf(fid,'%6.4f;',dat);    
            if strcmp(leg{r},'Measured'), break; end
        end
    end
    fprintf(fid, '\n');
end
fclose(fid);

% Single-subject results
if ~strcmp(vol,'group')
    ss_dir = 'png_SS';
    if ~exist(fullfile(ini.directories.resdir,ss_dir),'dir'), mkdir(fullfile(ini.directories.resdir,ss_dir)); end
    
    for ind_s = 1:numel(vol_list)
        s = vol_list(ind_s);
        if s <= nc
            xl = [ 1 size(res{1}.(meas{1}),2) ];
            ip = 2;
        else
            xl = [ 1:size(res{1}.(meas{1}),2) ];
            ip = 2;
        end
        for m = [3] %:numel(meas)
            f = figure;
            
            h = clf(f); set(h,'Position',fs);
            
            for t = 1:numel(tasks)
                h = subplot(numel(tasks),1,t); set(h,'XLim',[-1 numel(xl)+1]); hold on;
                for i = 1:2 %size(res{t}.(meas{m}),3)
                    plot(0:xl(end)-1,squeeze(res{t}.(meas{m})(s,xl,i)),lsp{t}{ip,i},'Color',col{t}{ip,i},'LineWidth',2,'DisplayName',leg{i});
                end
                h = legend('show'); set(h,'Interpreter','none');
                set(h,'FontSize',6,'Location','EastOutside');
            end
            
            saveas(f,fullfile(ini.directories.resdir,ss_dir,[meas{m} '_' ini.volunteers.(['vol' num2str(s)]) '.png']));
            close(f);
        end
    end
end

% Group results, needs all complete pre-, train and post- data. 
if strcmp(vol,'group')
    gr_dir = ['png_C' num2str(nc) 'T' num2str(ini.volunteers.nTr) sfx];
    if ~exist(fullfile(ini.directories.resdir,gr_dir),'dir'), mkdir(fullfile(ini.directories.resdir,gr_dir)); end
    
    for i = meas
        for t = 1:numel(tasks)
            pl{1}.(i{:}).(['ss' num2str(t)]) = res{t}.(i{:})(1:nc,1:end,:);
            pl{1}.(i{:}).(['m' num2str(t)]) = squeeze(mean(res{t}.(i{:})(1:nc,1:end,:), 1))/sqrt(nc);
			pl{1}.(i{:}).(['s' num2str(t)]) = squeeze(std(res{t}.(i{:})(1:nc,1:end,:), 1))/sqrt(nc);
            
            pl{2}.(i{:}).(['ss' num2str(t)]) = res{t}.(i{:})(nc+1:end,:,:);
			pl{2}.(i{:}).(['m' num2str(t)]) = squeeze(mean(res{t}.(i{:})(nc+1:end,:,:), 1))/sqrt(size(res{t}.(i{:})(nc+1:end,1:2,:),1));
            pl{2}.(i{:}).(['s' num2str(t)]) = squeeze(std(res{t}.(i{:})(nc+1:end,:,:), 1))/sqrt(size(res{t}.(i{:})(nc+1:end,1:2,:),1));
        end
    end
    for m = [3]%:numel(meas)
        for d = [0 1]
            f = figure;
            h = clf(f); set(h,'Position',fs);
            for ip = 2;%1:numel(gr)
                toplot = pl{ip}.(meas{m});
                %dw = floor(size(toplot.m1,2)/2);
                for t = 1:numel(tasks)                    
                    h = subplot(numel(tasks),2,t); set(h,'XLim',[-1, size(toplot.(['m' num2str(t)]),1)]); hold on;
                    set(h,'FontName','Calibri','FontSize',12, 'FontWeight','bold');
                    set(h,'XTick',[0:5:size(toplot.(['m' num2str(t)]),1)-1]);
                    xlabel('Training Runs'); ylabel(meas_label{m}); 
                    title(task{t},'FontName','Calibri','FontSize',20, 'FontWeight','bold');
                    % for i = pl_ind{d+1}
                        % plot(0:size(toplot.(['m' num2str(t)]),1)-1,toplot.(['m' num2str(t)])(:,i),lsp{t}{ip,i},'Color',col{t}{ip,i},'LineWidth',2,'DisplayName',leg{i});
                    % end
                    h1(t) = h; yl1(t,:) = get(h,'YLim');
                    %                 h = legend('show');
                    %                 set(h,'FontSize',6,'Location','EastOutside');
                    
                    h = subplot(numel(tasks),2,t+numel(tasks)); set(h,'XLim',[-1, size(toplot.(['m' num2str(t)]),1)]); hold on;
                    set(h,'FontName','Calibri','FontSize',12, 'FontWeight','bold'); 
                    xlabel('Time / Run');  ylabel(meas_label{m}); 
                    plot(0:size(toplot.(['m' num2str(t)]),1)-1,toplot.(['ss' num2str(t)])(:,:,pl_ind{d+1}(end)),'LineWidth',2);
                    h2(t) = h; yl2(t,:) = get(h,'YLim');
                    if ip == 2
                        ind = find(toplot.(['m' num2str(t)])(:,pl_ind{d+1}(end))==max(toplot.(['m' num2str(t)])(:,pl_ind{d+1}(end))));
%                         plot([sig(d+1,t) sig(d+1,t)],[-10 10],lsp{t}{ip,(d+1)*3},'Color',col{t}{ip,(d+1)*3},'LineWidth',1.5);
%                         plot([ind-1 ind-1],[-10 10],lsp{t}{ip,(d+1)*3},'Color',col{t}{ip,(d+1)*3},'LineWidth',1.5);
                        set(h,'YLim',yl2(t,:));
                    end
                    %                 h = legend('show');
                    %                 set(h,'FontSize',6,'Location','EastOutside');
                end
            end
            yl1v(1)=min(yl1(:,1)); yl1v(2)=max(yl1(:,2));
            yl2v(1)=min(yl2(:,1)); yl2v(2)=max(yl2(:,2));
            for t = 1:numel(tasks)
                set(h1(t),'YLim',yl1v);
                set(h2(t),'YLim',yl2v);
            end
            if d, pfx = 'not'; else pfx = ''; end
            saveas(f,fullfile(ini.directories.resdir,gr_dir,[pfx 'meas_' meas{m} '_' strrep(strrep(ini.files.resfile,'results_',''),'.mat','.eps')]));
            saveas(f,fullfile(ini.directories.resdir,gr_dir,[pfx 'meas_' meas{m} '_' strrep(strrep(ini.files.resfile,'results_',''),'.mat','.fig')]));
            saveas(f,fullfile(ini.directories.resdir,gr_dir,[pfx 'meas_' meas{m} '_' strrep(strrep(ini.files.resfile,'results_',''),'.mat','.png')]));
            close(f);
        end
    end
end