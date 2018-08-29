function test
clear global params
global params;
UNIT = 0.8;

Screen('Preference', 'Verbosity', 1);
%Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','SyncTestSettings',0.005,50,0.1,5);
[params.w, params.r] = Screen(0,'OpenWindow',[],[0 0 1024 768]);
params.col=BlackIndex(params.w);
params.bg=WhiteIndex(params.w);
SetMouse(params.r(RectRight)/2,params.r(RectBottom));

[params.fb.obj.img, params.fb.scale] = load_images(fullfile(fileparts(mfilename('fullpath')),'Pics'),params.r,{2});
fields = fieldnames(params.fb.obj.img);
params.fb.obj.img = params.fb.obj.img.(fields{2}){1};
x0 = params.r(RectRight)/2-size(params.fb.obj.img,2)/2;
y0 = params.r(RectBottom)/2-size(params.fb.obj.img,1)/2;
params.fb.range = 20;
params.fb.obj.Unit = UNIT;
params.fb.obj.Window = params.w;
params.fb.obj.WindowRect = [x0+53*params.fb.scale y0+13*params.fb.scale x0+160*params.fb.scale y0+1350*params.fb.scale];
params.fb.obj = FeedbackVertDualData(params.fb.obj,params.fb.range,5);

i= 10;
for i = -20:1:20
    params.fb.obj.Goal = i;
    params.fb.obj = params.fb.obj.SetValue(i);
    WaitSecs(0.5);
end
% imwrite(Screen('GetImage', params.w),'Thermo.png','png');

KbWait;
Destroy;