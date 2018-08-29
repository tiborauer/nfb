% host='172.31.120.11'; % login01
% host='172.31.17.98'; % ws
% host='172.31.25.2'; % rtpc2
host='172.31.25.14'; % stim14
port = 5678;
udp=pnet('udpsocket',port);

pnet(udp,'write',10);
pnet(udp,'writepacket',host,port);

pnet(udp,'close')