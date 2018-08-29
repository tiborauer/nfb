% host='172.31.120.11'; % login01
% host='172.31.17.98'; % ws
% host='172.31.25.2'; % rtpc2
host='172.31.25.18'; % stim14
port = 5678;
udp=pnet('udpsocket',port);

for i = 1:5
    pnet(udp,'write',i*4);
    pnet(udp,'writepacket',host,port);
end
pnet(udp,'close')