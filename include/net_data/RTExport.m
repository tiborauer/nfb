%%
dbstop if error
initialHeader = 0;

tcp = ImageTCPIPClass(5677);

data.watch = '/realtime/scratch/incoming';
data.watchportcommand = 'xterm -bg black -fg yellow -T "From scanner" -geometry 100x16+0+0 -e /realtime/apps/cburealtime/watchport_scanner.py &';
% data.watch = '/realtime/RTExport';
data.LastName = 'Phantom_06102015';
data.ID = 'MRTHODS';
tcp.setHeaderFromDICOM(data);

tcp.WaitForConnection;
% tcp.Quiet = true;
for n = 1-initialHeader:101
    fprintf('Scan #%03d\n',n);
    [hdr{n+initialHeader}, img{n+initialHeader}] = tcp.ReceiveScan;

    if n == 1
        t = tic;
        tcp.ResetClock; 
    elseif n > 1
        e(n-1) = toc(t);
    end
    
    if ~tcp.Open, break; end
end
tcp.Close;

%%
save run e hdr img
clear classes