function ct = FeedBack(varargin)Create(varargin);global params;OK = true;try    % init    ct{1,1} = 'Time';    ct{1,2} = 'Scan';    ct{1,3} = 'Ref';    ct{1,4} = 'Feedback';    draw_text('Ready',150,1);        % wait for the first pulse    if ~params.pulse.emul        while ~getvalue(params.pulse.io)        end    else        KbWait;            end    pt0 = GetSecs;     pt = pt0;    n = 0;    draw_text('Count',60,1);    text_on = true;    while (n < numel(params.ref))        ptt = GetSecs - pt;        if ~n || (params.pulse.emul && (ptt >= params.TR)) || (~params.pulse.emul && (ptt >= params.pulse.wait) && getvalue(params.pulse.io))            pt = GetSecs;            n = n + 1;            newscan = true;        else            newscan = false;        end        % Feedback        [X,Y,btn] = GetMouse;        if params.fb.emul            fb = ceil((params.r(RectBottom)-Y)/params.r(RectBottom)*params.fb.range);            fb = 0; % max(0,fb);        else            if exist(params.file.roi,'file')                rfid = fopen(params.file.roi, 'r');                nfb = fscanf(rfid, '%d %d');                fclose(rfid);                if numel(nfb)                    fb = nfb(2);                else                    fb = 0;                end            else                fb = 0;            end        end                if newscan            ct{n+1,1} = pt-pt0;            ct{n+1,2} = n;            ct{n+1,3} = params.ref(n);            ct{n+1,4} = fb;            if n > (params.nbase + 1)                if params.ref(n)-params.ref(n-1)                    draw_text(params.com.txt{params.ref(n)+2},60,1);                    text_on = true;                else                    params.fb.obj = params.fb.obj.SetValue(fb*params.fb_vect(n));                end            end        end        if text_on && (GetSecs-pt) >= params.com.wait            params.fb.obj = params.fb.obj.SetValue(fb*params.fb_vect(n));            text_on = false;        end        if any(btn), break; end    end    write_result(params.file.logfid,ct);    catch ME    OK = false;    Destroy(ME);endif OK, Destroy; end