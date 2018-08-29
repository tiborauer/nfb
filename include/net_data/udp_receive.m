port = 5678;
udp=pnet('udpsocket',port);

while 1, len = pnet(udp,'readpacket'); if len, break; end; end
data = pnet(udp,'read',1,'double');

pnet(udp,'close')

%%
sock=pnet('tcpsocket',2100);
if(sock==-1), error('Specified TCP port is not possible to use now.'); end
pnet(sock,'setreadtimeout',Inf);
con=pnet(sock,'tcplisten');
