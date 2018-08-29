function [ref nb] = reference_read(cfg, sw)
% sw - 0: Test(BrainVoyager) PRT; 1: Train(NFB)
switch sw
    case 0
        ref = read_BV(cfg)';
    case 1
        C = importdata(cfg.RefFile_Test)';
        ref = (C == 1)*2-1;
end
a = find(ref == 1);
nb = a(1)-1;
if cfg.ShiftRef > 0
    ref = [-ones(1,cfg.ShiftRef) ref(1:end-cfg.ShiftRef)];
end