
function hdr = read_packet(con)

HDRLEN = 68;

data = pnet(con,'read', 1, 'int8' ,'intel','noblock');
if isempty(data)
    hdr = [];
    return;
end
data(2:4) = pnet(con,'read', 3, 'int8');
hdr.length = double(typecast(data,'int32'));
[ hdr.code, err ] = readval(con, 'int16', 0 );
[ hdr.source, err ] = readval(con, 'int16', err );
[ hdr.dest, err ] = readval(con, 'int16', err );
[ hdr.messageID, err ] = readval(con, 'int16', err );
[ hdr.replyToMessageID, err ] = readval(con, 'int16', err );
[ blank, err ] = readval(con, 'int16', err );
[ hdr.messageTime, err ] = readval(con, 'int32', err );
[ hdr.ushLine, err ] = readval(con, 'int16', err );
[ hdr.ushAcquisition, err ] = readval(con, 'int16', err );
[ hdr.ushSlice, err ] = readval(con, 'int16', err );
[ hdr.ushPartition, err ] = readval(con, 'int16', err );
[ hdr.ushEcho, err ] = readval(con, 'int16', err );
[ hdr.ushPhase, err ] = readval(con, 'int16', err );
[ hdr.ushRepetition, err ] = readval(con, 'int16', err );
[ hdr.ushSet, err ] = readval(con, 'int16', err );
[ hdr.ushSeg, err ] = readval(con, 'int16', err );
[ hdr.ushIda, err ] = readval(con, 'int16', err );
[ hdr.ushIdb, err ] = readval(con, 'int16', err );
[ hdr.ushIdc, err ] = readval(con, 'int16', err );
[ hdr.ushIdd, err ] = readval(con, 'int16', err );
[ hdr.ushIde, err ] = readval(con, 'int16', err );
[ hdr.datatype, err ] = readval(con, 'int16', err );
for i=1:8
    [ hdr.dim(i), err ] = readval(con, 'int16', err );
end
[ blank, err ] = readval(con, 'int16', err );

if err == 1
    hdr = [];
    return;
end

dtype='char';
if hdr.datatype == 0
    if hdr.length > HDRLEN
        hdr.data = pnet(con,'read', hdr.length-HDRLEN, dtype );
        if (isempty(hdr.data)), err=1; end;
    else
        err=1;
    end
else
    switch hdr.datatype
        case 4
            dtype='int16';
        case 8
            dtype='int32';
        case 16
            dtype='single';
    end
    dims=hdr.dim(2:hdr.dim(1)+1);
    data = pnet(con,'read', prod(dims), dtype, 'intel' );
    if (isempty(data))
        err=1;
    else
        if (length(dims)>1)
            hdr.data = reshape(data, dims);
        else
            hdr.data = data;
        end
    end;
end
if err ==1
    hdr = [];
end

end

function [ val, err ] = readval( con, type, err)
val=0;
if err == 0
    val = pnet(con,'read', 1, type, 'intel');
    if (isempty(val)), err=1; end;
    val = double(val);
end
end