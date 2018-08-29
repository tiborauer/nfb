function [out sanity] = nfb_reference(ini)

dt = 0.1; % temporal resolution

%% Read imput
if ischar(ini)
    ini = IniFile(ini);
end
inip = IniFile(ini.reference.ref_file);
ref_type = cell2mat(inip.getFields);
refstruct = inip.(ref_type);

ndt = ini.timing.TR/dt;
volumes = ini.timing.volumes;
timepoints = volumes*ndt;

%% Create vectors
switch ref_type
    case 'reference'
        cont = zeros(refstruct.ref_control,1);
        act = ones(refstruct.ref_act,1);
        active_vect = cont;
        if refstruct.ref_deact
            deact = ones(refstruct.ref_deact,1);
            deactive_vect = cont;
            for n = 1:refstruct.ref_cycles
                deactive_vect = vertcat(deactive_vect, act, cont, deact, cont);
            end
        else
            for n = 1:refstruct.ref_cycles
                active_vect = vertcat(active_vect, act, cont);
            end
            deactive_vect = zeros(numel(active_vect),1);
        end
        reference = active_vect - deactive_vect;
        
        % feedback
        fb_vect = nan(numel(reference),1);
        for fi = 1:numel(refstruct.fb_start)
            fb_length = refstruct.ref_act + refstruct.ref_control - refstruct.fb_start(fi) - (-refstruct.fb_stop(fi));
            dofirst = fi == numel(refstruct.fb_start);
            for n = 1:numel(reference)
                if (n > 1) && (reference(n-1) == 0)
                    if dofirst
                        dofirst = false;
                        fbstart = max(1,n - (refstruct.ref_act + refstruct.ref_control - refstruct.fb_start(fi)));
                        fb_vect(fbstart:(fbstart+fb_length-1)) = 1;
                    end
                    fbstart = n + refstruct.fb_start(fi);
                    fb_vect(fbstart:(fbstart+fb_length-1)) = 1;
                end
            end
        end
        if numel(fb_vect) > numel(reference)
            fb_vect(numel(reference)+1:numel(fb_vect)) = [];
        end
        
        % "real" vec
        active_real = imresize(active_vect,[numel(reference)*ndt 1],'nearest');
        deactive_real = imresize(deactive_vect,[numel(reference)*ndt 1],'nearest');
        fb_real = imresize(fb_vect,[numel(reference)*ndt 1],'nearest');
        
    case 'paradigm'
        EVs = refstruct.Conditions;
        
        pos = 0;
        for n = 1:size(refstruct.ConditionSequence)
            nEV = cell_index(EVs,refstruct.ConditionSequence{n});
            ref(pos+1:pos+refstruct.ConditionTimes(nEV)/dt,nEV) = 1;
            pos = pos + refstruct.ConditionTimes(nEV)/dt + refstruct.ISI(n)/dt;
        end
        if size(ref,1) < pos, ref(pos,1) = 0; end % fill last ISI
        if size(ref,1) < timepoints, ref(timepoints,1) = 0; end % fill remaining volumes
        
        % "real" vec
        active_real = ref(:,cell_index(EVs,'A'));
        deactive_real = ref(:,cell_index(EVs,'D'));
        fb_real = ref(:,cell_index(EVs,'FB'));
        ne_real = ref(:,cell_index(EVs,'NE'));
        
        resind = (0:((length(ref)/ndt) - 1))*ndt+1;
        active_vect = ref(resind,cell_index(EVs,'A'));
        deactive_vect = ref(resind,cell_index(EVs,'D'));        
        for i =  1:numel(resind)-1
            vect(i) = mean(ref(resind(i):resind(i)+ndt-1,cell_index(EVs,'FB')));
        end
%         vect(end+1) = mean(ref(resind(i+1):end,cell_index(EVs,'FB')));
%         fb_vect = circshift(ceil(vect'),[-1 0]);
%         fb_real = imresize(fb_vect,[numel(fb_real) 1],'nearest');
		fb_vect = ref(resind,cell_index(EVs,'FB'));        
        ne_vect = ref(resind,cell_index(EVs,'NE'));
        reference = active_vect - deactive_vect;
end

% sanity
sanity = numel(reference)-volumes;
% if sanity < 0
%     out.vec.fb = fb_vect;
%     return;
% end

% construct
% remove initial fb event required for analysis
if fb_real(1)
    i = 1;
    while fb_real(i)
        fb_real(i) = 0;
        i = i + 1;
    end
end
out.ref_GLM = refstruct.ref_GLM;
out.dt = dt;
out.vec.active = active_vect(1:volumes); out.vec.active(~out.vec.active) = nan;
out.vec.deactive = deactive_vect(1:volumes); out.vec.deactive(~out.vec.deactive) = nan;
out.vec.ne = ne_vect(1:volumes); out.vec.ne(~out.vec.ne) = nan;
out.vec.reference = reference(1:volumes);
out.vec.fb = fb_vect(1:volumes);
out.real.active = active_real(1:timepoints);
out.real.deactive = deactive_real(1:timepoints);
out.real.ne = ne_real(1:timepoints);
out.real.fb = fb_real(1:timepoints);

%% Create design
switch refstruct.ref_GLM
    case 'FIR'
        out.vec.norm = ~reference(1:volumes);
        order = 6;
%         bf = kron(eye(order),ones(round(32/order/dt),1));
        bf = spm_hrf(dt);
    case 'block'
        out.vec.norm = ones(volumes,1);
        bf = spm_hrf(dt);
end
out.real.norm = imresize(out.vec.norm,[volumes*ndt 1],'nearest');

%% Convolve
conditions = horzcat(active_real,deactive_real,fb_real); % order in DM: A D FB
for nEV = 1:size(conditions,2)
    U(nEV).name = EVs(nEV);
    U(nEV).u = sparse(vertcat(zeros(33,1),conditions(:,nEV)));
end

[out.X, Xn, Fc] = spm_Volterra(U,bf);
out.X = out.X((0:((length(conditions)/ndt) - 1))*ndt + 33,:);

% for i = 1:length(Fc)
%     out.X(:,Fc(i).i) = spm_orth(out.X(:,Fc(i).i));
% end
end