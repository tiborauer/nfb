function mvpc_check(fn)

load(fn);
cfg = mvpc.cfg;
model = mvpc.model;

figure('Name','Traning Plot Window','NumberTitle','off');
if strcmp(cfg.Method, 'NN')
    h = plotyy(model.training_record.epoch,model.training_record.perf,...
        model.training_record.epoch,model.training_record.gradient,'semilogy');
    set(get(h(1),'Ylabel'),'String','Performance')
    set(get(h(2),'Ylabel'),'String','Gradient')
    xlabel('Epoch');
elseif strcmp(cfg.Method, 'SVM')
    h = axes;
    hold on;
    plot(model.a/max(model.a),'r','DisplayName','a (normalized)');
    plot(model.index/max(model.index),'g','DisplayName','index (normalized)');
    plot(model.alpha/max(model.alpha),'b','DisplayName','alpha (normalized)');
    hold off;
    legend(h,'show');
end