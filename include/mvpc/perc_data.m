function [pdata pd] = perc_data(data, nb, p)
if nargin < 3
    p = mean(data(:,1:nb),2);
end
%h = waitbar(0, 'Percenting...');
s = warning('on', 'MATLAB:divideByZzero');
for i = 1:size(data, 1)
    pdata(i,:) = (data(i,:)-p(i))/p(i);
%    waitbar(i/size(data,1), h);
end
%close(h);
pd = p;
% fn = 'pd';
% while 1
%     if exist([fn '.mat'],'file')
%         fn = [fn '+'];
%     else
%         break;
%     end
% end
% fn = [fn '.mat'];
% save(fn, 'pd');
warning(s)