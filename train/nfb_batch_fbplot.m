v = 2; m = 5; t = 4;
for v = 1:size(meas,1)
    for m = 1:size(meas,2)
        for t = 1:size(meas,3)
            if ~isempty(meas{v,m,t})
%                 f = figure(1); clf;
%                 plot(fb0{v,m,t}); hold on; plot(fb{v,m,t},'r') 
%                 saveas(f,[meas{v,m,t} '.tif']);
                
            end
        end
    end
end