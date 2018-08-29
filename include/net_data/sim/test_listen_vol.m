clear
sock=pnet('tcpsocket',2100);
if(sock==-1), error('Specified TCP port is not possible to use now.'); end
pnet(sock,'setreadtimeout',Inf);

con=pnet(sock,'tcplisten');
if( con~=-1 )
    [ip,port]=pnet(con,'gethost');
    disp(sprintf('Connection from host:%d.%d.%d.%d port: %d\n',ip,port))
    pnet(con,'setreadtimeout',Inf);  % Wait forever for data

    n = 0;
    tic
    timeout = 20;
    while toc < timeout
        hdr = read_packet( con );
        if ~isempty(hdr)
            switch hdr.code
                case 10
                    if ~exist('vols','var')
                        vols = hdr.data;
                        hdr0.dat = hdr.data;
                        disp('First scan.');
                        timeout = 10;
                        tic
                    else
                        toc
                        vols(:,:,:,end+1) = hdr.data;
                    end
                case 8
                    mat = hdr.data';
                    d(:,4) = sum(mat(:,1:3),2);
                    m = ones(3,4); m(1:2,:) = -1;
                    hdr0.mat = vertcat((mat-d).*m,[0 0 0 1]);
                otherwise
                    continue;
            end
        end
        n = n + 1;
    end
    pnet(con,'close');
end
pnet(sock,'close');

