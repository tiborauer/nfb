% Server interface for TCP/IP
% Version 1.0
%
% DESCRIPTION
%   Public properties
%       Quiet                               Indicator showing whether logging to the command window disabled (default=true)
%       Open (read-only)                    Indicator showing whether  there an open connection
%       BytesAvailable                      Number of bytes available for reading
%       Clock                               Built-in timer (requires manual start via method ResetClock)%       
%       TimeOut                             Time out (in seconds) for data reception
%   Methods
%       obj = TCPIPClass(port, [switches])  Constructor
%           port        Port number to open for the client
%           switches
%               'quiet' Switches logging off
%       delete                              Destructor (Makes sure connections are closed)
%       WaitForConnection                   Waits until conection with the client is established
%       CloseConnection                     Closes conection with the client
%       Close                               Closes server (and connnection)
%       dat = ReadData(n,dtype,[swiches])   Read a certain number of typed data
%           n           Number of data to be read
%           dtype       Type of the of data to be read (see pnet(con,'read',...) for reference)
%           switches    See pnet(con,'read',...) for reference
%       ReadBytesToBuffer                   Read all available data as 'uint8' into Buffer
%       ResetClock                          (Re)start timer
%       Log                                 Logs in command window with time stamp
%           If the timer is not set, then the timestamp is date and time
%           If the timer is set, then the timestamp is the time (in seconds) spent since ResetClock
%
% DEVELOPMENT ONLY
%   Protected properties
%       Socket          Handle to socket
%       Connection      Handle to connection
%       ClientIP        IP of the client
%       ClientPort      Port of the client
%       Buffer          Buffer to read data by bytes in buffered mode (unit8)
%   Private properties
%       iClock          Handle to MATLAB's tic-toc
%
% REQUIREMENTS
%   TCP/UDP/IP Toolbox 2.0.6 
%       by Peter Rydesäter (Peter@Rydesater.se)
%       Download: http://uk.mathworks.com/matlabcentral/fileexchange/345-tcp-udp-ip-toolbox-2-0-6
%_______________________________________________________________________
% Copyright (C) 2015 MRC CBSU Cambridge
%
% Tibor Auer: tibor.auer@mrc-cbu.cam.ac.uk
%_______________________________________________________________________

classdef TCPIPClass < handle
    properties
        Quiet = false
    end
    properties (SetAccess=private)
        Open = false
    end
    properties (Access=protected)
        Socket
        
        Connection
        ClientIP
        ClientPort

        Buffer
    end
    properties (Access=private)
        iClock = []
    end
    properties (Dependent = true)
        TimeOut
    end
    properties (Dependent = true, SetAccess=private)
        BytesAvailable
        Clock
    end
    
    methods
        function obj = TCPIPClass(port,varargin)
            if nargin > 1
                if any(strcmp(varargin,'quiet')), obj.Quiet = true; end
            end
            
            obj.Socket = pnet('tcpsocket',port);
            if obj.Socket == -1
                obj.Log(sprintf('ERROR: Specified TCP port %d cannot be opened!',port));
                return
            end
            host = char(java.net.InetAddress.getLocalHost.toString); [~,host] = strtok(host,'/'); host = host(2:end);
            obj.Log(sprintf('Server %s starts at %d',host,port));
        end
        
        function delete(obj)
            obj.Close;
        end
        
        function WaitForConnection(obj)
            obj.Log('Connecting to host...');
            obj.Connection = pnet(obj.Socket,'tcplisten');
            if obj.Connection == -1
                obj.Log('ERROR: No connection detected!');
                return
            end
            [ip,obj.ClientPort]=pnet(obj.Connection,'gethost'); obj.ClientIP = sprintf('%d.%d.%d.%d',ip);
            obj.Log(sprintf('Connection from host:%s port:%d',obj.ClientIP,obj.ClientPort));
            obj.Open = true;
%             obj.TimeOut = 0.1;
        end
        
        function CloseConnection(obj)
            if ~isempty(obj.Connection)
                try
                    pnet(obj.Connection,'status'); 
                catch
                    obj.Log(sprintf('WARNING: Connection from host:%s port:%d is already closed!',obj.ClientIP,obj.ClientPort));    
                    return
                end
                pnet(obj.Connection,'close'); 
                obj.Log(sprintf('Connection from host:%s port:%d closed',obj.ClientIP,obj.ClientPort));
                obj.Open = false;
            end
        end
        
        function Close(obj)
            obj.CloseConnection;
            try
                pnet(obj.Socket,'status');
            catch
                obj.Log('WARNING: Server already closed!');
                return
            end
            pnet(obj.Socket,'close');
            obj.Log('Server closed');
        end
        
        function set.TimeOut(obj,val)
            pnet(obj.Connection,'setreadtimeout',val);
            obj.Log(sprintf('Timeout for host:%s port:%d set to 2.3fs',obj.ClientIP,obj.ClientPort,val));
        end
        
        function dat = ReadData(obj,n,dtype,varargin)
            dat = [];
            if n, dat = pnet(obj.Connection,'read',n,dtype,varargin{:}); end
        end
        
        function val = get.BytesAvailable(obj)
            val = numel(pnet(obj.Connection,'read','uint8','view','noblock'));
        end
        
        function ReadBytesToBuffer(obj)
            while obj.BytesAvailable
                obj.Buffer = [obj.Buffer obj.ReadData(obj.BytesAvailable,'uint8')];
            end
            obj.Log(sprintf('%d Bytes received',numel(obj.Buffer)));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UTILS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function val = get.Clock(obj)
            if ~isempty(obj.iClock)
                val = toc(obj.iClock);
            else
                val = [];
            end
        end
        
        function ResetClock(obj)
            obj.iClock = tic;
        end
        
        function Log(obj,msg)
            if ~obj.Quiet || ~isempty(strfind(msg,'ERROR')) || ~isempty(strfind(msg,'WARNING'))
                if ~isempty(obj.iClock)
                    fprintf('[%2.3f] %s\n', obj.Clock, msg);
                else
                    fprintf('[%s] %s\n', datestr(now), msg);                    
                end
            end
        end
    end
end