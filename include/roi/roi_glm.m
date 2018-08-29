function out = roi_glm(varargin)
% plot: 0 - no plot; 1 - plot;
% fit: 0 - no fit; 1 - delay; 2 - full fit;
% data: 0 - no bg; 1 - bg;
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
nEV = size(des,2);
switch nEV
    case 1
        c = 1;
    otherwise
        c = zeros(nEV,1);
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
            hrf(:,i) = spm_bfhrf(des(:,i), 22, 1, 2);
        end
        out.stat.delay = 6;
    case 1 % delay fit
        D_DELAY = 3;
        r_delay = 6-D_DELAY:6+D_DELAY;
        s = [];
        for i = r_delay
            hrf = spm_bfhrf(des, 22, 1, 2, i);
            X=[hrf ones(numel(hrf),1)];

            b=X\data;
            s(end+1) = norm(data-X*b);
        end
        out.stat.delay = r_delay(s==min(s));
        hrf = spm_bfhrf(des, 22, 1, 2, out.stat.delay);
    case 2 % full fit
        [hrf out.stat.r out.stat.p] = hrf_fit(data,des);
        out.stat.delay = mean(out.stat.p(:,1));
end

X=[hrf ones(size(hrf,1),1)];

b=X\data;
pred=X(:,1:nEV)*b(1:nEV);
predEV=X(:,1:nEV).*repmat(b(1:nEV)',[size(X,1),1]);
base = data-pred;
pred=X*b;
res = data-pred;
se = std(data)/sqrt(numel(data)-1-numel(b));

if pl
    figure('Name',titlestr);
    subplot(2,1,1);
    plot(data,'LineWidth',2)
    hold on
    plot(pred,'r','LineWidth',2)
    plot(base,'k','LineWidth',2)
    hold off
    subplot(2,1,2);
    plot(res,'k','LineWidth',2)
end

out.plot.data = data;
out.plot.pred = pred;
out.plot.base = base;
out.plot.res = res;
out.stat.beta = b(1:nEV);
out.stat.b0 = b(end);
out.stat.con = b(1:nEV)'*c;
out.stat.se = se;
out.stat.t = b(1)/se;
out.stat.CNR = range(pred)/std(res);
out.stat.tSNR = mean(data)/std(res);
out.stat.PSC = out.stat.beta./abs(out.stat.beta).*(range(predEV)'/mean(base)*100);
out.stat.ePSC = out.stat.beta/b(end)*100;
end