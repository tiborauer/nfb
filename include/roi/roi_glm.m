function out = roi_glm(varargin)
% nEV: number of EV to convolve
% plot: 0 - no plot; 1 - plot;
% fit: 0 - no fit; 1 - delay; 2 - full fit;
% data: 0 - no bg; 1 - bg;
nEV = cell_index(varargin,'nEV');
if nEV, nEV = varargin{nEV+1}; end
tr = cell_index(varargin,'TR');
if tr, tr = varargin{tr+1}; end
pl = cell_index(varargin,'plot');
if pl, pl = varargin{pl+1}; end
hf = cell_index(varargin,'fit');
if hf, hf = varargin{hf+1}; end
bg = cell_index(varargin,'bg');
if bg, bg = varargin{bg+1}; end

titlestr='';
if ischar(varargin{1})
    load(isInDB(varargin{1}));
    data = result.ts(:,3);
    tr = str2double(result.info{2,cell_index({result.info{:,1}},'TR')});
    if bg, data = data - result.ts(:,4); end
    titlestr=basename(fileparts(varargin{1})); titlestr=strrep(titlestr,'ROI_','');
else
    data = varargin{1};
    if ~tr
        warning('No TR is provided! TR = 2s is assumed');
        tr = 2;    
    end
end
data(1) = data(2);
if ischar(varargin{2})
    des = ref2des(isInDB(varargin{2}));
else
    des = varargin{2};
end
switch size(des,2)
    case 1
        nEVSig = 1;
        c = 1;
    otherwise
        nEVSig = 2;
        c = zeros(size(des,2),1);
        c(1:2) = [1 -1];
end

% Temporal filtering
% estimate length of the paradigm's repeating unit from the data
f_low = 1 / (1.1*nfb_parest(des)*tr);
% cut-off frequency for lp filter is determined by TR
f_high = 1 / (2*tr);
base = mean(data);
data = mpi_BandPassFilterTimeSeries(data, tr, f_low, f_high) + base;
if size(data,1) < size(data,2), data = data';  end
switch hf
    case -1 % no convolution
        hrf = des;
        out.stat.delay = NaN;
    case 0 % no fit
        for i = 1:nEV
            des(:,i) = spm_bfhrf(des(:,i), 28, 14, 2);
        end
        hrf = des;
        out.stat.delay = 6;
    case 1 % delay fit
        D_DELAY = 3;
        r_delay = 6-D_DELAY:6+D_DELAY;
        s = [];
        for i = r_delay
            for i = 1:nEV
                des(:,i) = spm_bfhrf(des(:,i), 28, 14, 2);
            end
            hrf = des;
            X=[hrf ones(numel(hrf),1)];

            b=X\data;
            s(end+1) = norm(data-X*b);
        end
        out.stat.delay = r_delay(s==min(s));
        for i = 1:nEV
            des(:,i) = spm_bfhrf(des(:,i), 28, 14, 2);
        end
        hrf = des;
    case 2 % full fit
        [hrf, out.stat.r, out.stat.p] = hrf_fit(data,des); % TODO: take nEV into account
        out.stat.delay = mean(out.stat.p(:,1));
end

X=[hrf ones(size(hrf,1),1)];
Y = data;

beta=X\Y;
predSig=X(:,1:nEVSig).*repmat(beta(1:nEVSig,:)',[size(X,1),1]);
predAll=X(:,1:end-1)*beta(1:end-1,:);
base = Y-predAll;
predAll=X*beta;
res = Y-predAll;
se = std(res)/sqrt(numel(Y)-1-numel(beta));

if pl
    figure('Name',titlestr);
    subplot(2,1,1);
    plot(data,'LineWidth',2);
    hold on
    plot(predSig,'r','LineWidth',2);
    plot(res,'k','LineWidth',2);
    hold off
    subplot(2,1,2); 
    hold on;
    plot(predAll,'r','LineWidth',2);
    plot(base,'k','LineWidth',2);
    hold off
end

if ~nEV
    nEV = size(des,2);
end

out.plot.data = data;
out.plot.pred = predSig;
out.plot.base = base;
out.plot.res = res;
out.stat.beta = beta(1:nEV);
out.stat.b0 = beta;
out.stat.con = beta(1:nEV)'*c(1:nEV);
out.stat.se = se;
out.stat.t = out.stat.con/se;
out.stat.CNR = range(predSig)/std(res);
out.stat.tSNR = mean(data)/std(res);
out.stat.PSC = out.stat.beta(1:nEVSig)./abs(out.stat.beta(1:nEVSig)).*(range(predSig)'/mean(base)*100);
out.stat.ePSC = out.stat.beta/beta(end)*100;
end