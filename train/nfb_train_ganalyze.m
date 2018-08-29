function nfb_train_ganalyze(fini)
meas = {'beta'};
ma = [2 3];
col = {'k-', 'k--'};
if ischar(fini)
    ini = IniFile(fini);
    if ~ini.isValid, return; end
else
    ini = fini;
end

out = nfb_train_analyze2res(fini);
w = str2num(ini.training.fb); w0 = find(w==0);
leg = {ini.training.(['roi' num2str(find(w>0))]) ini.training.(['roi' num2str(find(w<0))]) 'Measured'};
for i = 1:numel(w0)
    leg{end+1} = ini.training.(['roi' num2str(w0(i))]);
end
leg{end+1} = 'Not Measured';

nc = ini.volunteers.nvol-ini.volunteers.nTr; % # Control
tasks = unique(lower(ini.training.m1));
for s = 1:ini.volunteers.nvol
    for m = 1:size(out{1}{s},2)/6
        for r = 1:numel(leg)
            for t = 1:numel(tasks)
                for mp = 1:numel(meas)
                    res{t}.(meas{mp})(s,m,r) = out{t}{s}(ma(mp),(m-1)*6+r) - out{t}{s}(ma(mp),r);
                end
            end
        end
    end
end

th = 0.05/ini.volunteers.nTr;
for t = 1:numel(tasks)
    figure(t)
    a = axes; hold on; set(a,'XTick',[]); set(a,'YTick',[]); ylim([0 ini.volunteers.nTr]);
    for mp = 1:numel(meas)
        meas2c = [res{t}.(meas{mp})(1:nc,end,3)];
        meas2a = [res{t}.(meas{mp})(nc+1:end,:,3)];
        max_meas2a = max(mean(meas2a));
        
        for m = 1:size(meas2a, 2)
            if mean(meas2a(:,m)) == max_meas2a
                h = plot(a,[m-1 m-1], ylim,strrep(col{mp},'k','r'));
                set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
                set(a,'XTick',unique(sort([m-1 get(a,'XTick')])));
            end
            for s = 1:size(meas2a, 1)
                [h p(s,m)] = ttest(meas2c,meas2a(s,m));
                p(s,m) = p(s,m) + (meas2a(s,m) < mean(meas2c));
            end
        end
        p = p <= th;
        p = sum(p,1);
        plot(a,0:numel(p)-1,p,col{mp},'DisplayName',meas{mp});
        
        imax = find(p==max(p))-1;
        h = plot([imax(1) imax(1)], [0 max(p)],col{mp});
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
        set(a,'XTick',unique(sort([imax(1) get(a,'XTick')])));
        h = plot([0 imax(1)], [max(p) max(p)],col{mp});
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
        set(a,'YTick',unique(sort([max(p) get(a,'YTick')])));
        
        clear p;
    end
    legend show
end

% for s = 1:size(p, 1)
%     np(s) = 0;
%     for i1 = 1:size(p, 2)
%         if p(s,i1) && ~np(s)
%             np(s) = i1;
%             for i2 = i1+1:size(p,2)-2
%                 if ~p(s,i2) && ~p(s,i2+1) && ~p(s,i2+2)
%                     np(s) = 0;
%                 end
%             end
%         end
%     end
% end