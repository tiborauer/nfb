function result = nfb_dataread(result, rtconfig, targ_data, bg_data, n)

global params;

result.ts(n,3) = targ_data;
if bg_data
    result.ts(n,4) = bg_data;
end
% low-pass filter
if rtconfig.preprocess.lp_filter && (n > 2)
    result.ts(n,5) = (result.ts(n-2,3)*1 + ...
        result.ts(n-1,3)*2 + result.ts(n,3)*3) / 6;
    if ~isempty(rtconfig.data.bg_roi)
        result.ts(n,6) = (result.ts(n-2,4)*1 + ...
            result.ts(n-1,4)*2 + result.ts(n,4)*3) / 6;
    end
else
    result.ts(n,5) = result.ts(n,3);
    result.ts(n,6) = result.ts(n,4);
end

if n == 1
	% for the first block the first scan will be considered as base
	result.internal.PSC = zeros(1,1+logical(bg_data));
    result.internal.base = NaN; %result.ts(1,5);
	result.internal.bgbase = NaN; %result.ts(1,6);
end


%% Normalization
if params.reference.norm_stop
    % Collect data
    if rtconfig.preprocess.moco_yn
        moco = params.reference.moco_par(params.reference.norm_start:params.reference.norm_stop,:);
        moco = moco - repmat(mean(moco),[size(moco,1),1]);
    else
        moco = [];
    end
    X = horzcat(params.reference.X(params.reference.norm_start:params.reference.norm_stop,:),...
        moco);
    Y = result.ts(params.reference.norm_start:params.reference.norm_stop,5);
    if bg_data
        Y = horzcat(Y,result.ts(params.reference.norm_start:params.reference.norm_stop,6));
    end
    
    % which EV
    ref = sum(params.reference.vec.reference(params.reference.norm_start:params.reference.norm_stop));
    ref = ref/(abs(ref));
    ref = (-ref+3)/2;
    
    % Perform
    nEV = size(params.reference.X,2)-1; % Fb is not included
    X = horzcat(X, ones(size(X,1),1));
    warning('off','MATLAB:rankDeficientMatrix');
    beta = X\Y;
    warning('on','MATLAB:rankDeficientMatrix');
%     predSignal=X(:,1:nEV)*beta(1:nEV,:);
    predSignal=X(:,ref)*beta(ref,:);
    predAll=X(:,1:end-1)*beta(1:end-1,:);
    base = Y-predAll;
    mbase = mean(base);
    
    
    c = zeros(1,nEV);
%     c(3) = -1; % vs. NE
    c(ref) = 1;
    
    beta = (beta(1:nEV,:)'*c')';    
    result.internal.PSC = beta./abs(beta).*(range(predSignal)./mbase*100);
    result.internal.base = mbase(1);
    if bg_data
        result.internal.bgbase = mbase(2);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Test only %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     result.internal.PSC = [params.reference.norm_start/50-2 0];
end

if (n < rtconfig.timing.volumes) && params.reference.vec.fb(n+1) && isfield (result.internal,'PSC')
    result.ts(n,7) = result.internal.PSC(1); ind = 7;
    if bg_data
        result.ts(n,8) = result.internal.PSC(2);
        result.ts(n,9) = result.internal.PSC(1)-result.internal.PSC(2);
        ind = 9;
    end
    
    % parameters of breakpoints
    eval(struct_extract(rtconfig.feedback))
    global MAX_POS MAX_NEG;    
    if method == 2
        result.ts(n,10)= slope_fun(result.ts(n,ind), 21, MAX_NEG, MAX_POS, break_low, break_high, sl_middle, sl_extremity);
    else
        result.ts(n,10)= slope_fun(result.ts(n,ind), 21, MAX_NEG, MAX_POS);
    end
end