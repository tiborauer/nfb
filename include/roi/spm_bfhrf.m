function X = spm_bfhrf(c, nsl, fsl, TR, p)
nsc = length(c);

U.name = {'Activation'};
[U.ons, U.dur] = conbool(c);
U.P.name = 'none';
U.P.h = 0;
U.P.i = 1;
U.dt = TR/nsl;

% U.pst   = [0:(nsc-1)]*nsl*U.dt - U.ons(1)*TR;			
% for j = 1:length(U.ons)
% 	w      = [0:(nsc-1)]*nsl*U.dt - U.ons(j)*TR;
% 	v      = find(w >= 0);
% 	U.pst(v) = w(v);
% end 

u = U.ons.^0;
% for q = 1:length(U.P)
% 	U.P(q).i = [1, ([1:U.P(q).h] + size(u,2))];
% 	for j = 1:U.P(q).h
% 		u = [u U.P(q).P.^j];
% 		str = sprintf('%sx%s^%d',U.name{1},U.P(q).name,j);
% 		U.name{end + 1} = str;
% 	end
% end 
u = spm_orth(u); 
ton       = round(U.ons*TR/U.dt) + 33;			% onsets
tof       = round(U.dur*TR/U.dt) + ton + 1;			% offset
sf        = sparse((nsc*nsl + 128),size(u,2));
ton       = max(ton,1);
tof       = max(tof,1);
for j = 1:length(ton)
	if numel(sf)>ton(j),
		sf(ton(j),:) = sf(ton(j),:) + u(j,:);
	end;
	if numel(sf)>tof(j),
		sf(tof(j),:) = sf(tof(j),:) - u(j,:);
	end;
end
sf        = cumsum(sf);					% integrate
sf        = sf(1:(nsc*nsl + 32),:);				% stimulus
U.u = sf;
if nargin == 5
    bf = spm_hrf(U.dt,p);
else
    bf = spm_hrf(U.dt);
end
X = spm_Volterra(U,bf); 
X = X((0:(nsc - 1))*nsl + fsl + 32,:);