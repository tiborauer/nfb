function nfb_featref(study, vol, tr)
TrDIR = sprintf('Z:\\siemens\\%s\\vol_%d\\results\\RealTimeData',study,vol);
d = dir(TrDIR);
isfound = false;
for i = 3:numel(d)
    if strfind(d(i).name,sprintf('tr%d_out',tr))
        isfound = true;
        break;
    end
end
if ~isfound, error(sprintf('%d. training not found in %s',tr, TrDIR)); end

TrDIR = fullfile(TrDIR,d(i).name);

rtconfig = IniFile(fullfile(TrDIR,'rtconfig.txt'));
ref = nfb_reference(rtconfig.reference);
vec = ref.vec;

act = vec.active_vector;
act(isnan(act)) = 0;
act = horzcat(act, zeros(1,5));
dlmwrite('featref_think',act,'\n')

act_fb = horzcat(zeros(1,5), act);
act_fb = act_fb(1:185);
dlmwrite('featref_think-fb',act_fb,'\n')

cont = horzcat(zeros(1,10), act);
cont(11:15) = 1;
cont = cont(1:185);
dlmwrite('featref_count',cont,'\n')

cont_fb = horzcat(zeros(1,5), cont);
cont_fb = cont_fb(1:185);
dlmwrite('featref_count-fb',cont_fb,'\n')
