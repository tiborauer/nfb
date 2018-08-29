function res = roi_glm_batch(ini,vol,tr,hf)
if nargin < 4, hf = 1; end
ini = IniFile(ini);
if ~ini.isValid, error; end
d = isInDB(fullfile(ini.directories.traindir,['vol_' num2str(vol)],[tr '_out']));
R = get_ROIs(ini.training);
for i = 1:numel(R)
	rtini = IniFile(fullfile(d,'rtconfig.txt'));
	switch rtini.reference.ref_type
		case 'block'
			out = roi_glm(fullfile(d,['ROI_' R{i}],'results.mat'),fullfile(d,'reference.txt'),'fit',hf,'bg',~isempty(ini.training.roibg));
			res{1}(1,i) = out.stat.delay;
			res{1}(2,i) = out.stat.beta;
			res{1}(3,i) = out.stat.t;
			res{1}(4,i) = out.stat.ePSC;
		case 'opcond'
            ref = nfb_reference(rtini);
			vec = ref.vec;
            vec.active(isnan(vec.active)) = 0; vec.active(end+1:rtini.timing.volumes) = 0;
            vec.deactive(isnan(vec.deactive)) = 1; vec.deactive(end+1:rtini.timing.volumes) = 0;
            vec.deactive(vec.active==1) = 0;
            vec.deactive(vec.fb_vect==1) = 0;
            vec.fb_vect(end+1:rtini.timing.volumes) = 0;
            X = horzcat(vec.active', vec.deactive');
			out = roi_glm(fullfile(d,['ROI_' R{i}],'results.mat'),X,'fit',hf,'bg',~isempty(ini.training.roibg));
			res{1}(1,i) = out.stat.delay;
			res{1}(2,i) = out.stat.beta;
			res{1}(3,i) = out.stat.t;
			res{1}(4,i) = out.stat.ePSC;

            X = horzcat(vec.fb_vect, vec.deactive');
			out = roi_glm(fullfile(d,['ROI_' R{i}],'results.mat'),X,'fit',hf,'bg',~isempty(ini.training.roibg));
			res{2}(1,i) = out.stat.delay;
			res{2}(2,i) = out.stat.beta;
			res{2}(3,i) = out.stat.t;
			res{2}(4,i) = out.stat.ePSC;
	end
end