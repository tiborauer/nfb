function [R W pl] = get_ROIs(tr)
w = str2num(tr.fb); w0 = find(w==0);

R = {tr.(['roi' num2str(find(w>0))])};
W = w(w > 0);

if any(w<0)
    R = horzcat(R, tr.(['roi' num2str(find(w<0))]));
    W = horzcat(W, w(w<0));
end

R = horzcat(R,  'Measured');
W = horzcat(W, NaN);
pl.ind1 = 1:numel(W);

for i = 1:numel(w0)
    R{end+1} = tr.(['roi' num2str(w0(i))]);
    W(end+1) = 0;
end

pl.leg = R; pl.leg{end+1} = 'Not Measured';
pl.ind2 = numel(pl.leg)-numel(pl.ind1):numel(pl.leg);
pl.col = pl_gen(w,{[0 0 0], [0 0 0], [0.5 0.5 0.5]});
pl.lsp = pl_gen(w,{'*' 'o', '*'});

pl.lsp = vertcat(pl.lsp, pl_gen(w,{'--' ':' '-'})); pl.col = vertcat(pl.col, pl.col);

col1 = pl.col; pl.col = {}; pl.col{1} = col1;
lsp1 = pl.lsp; pl.lsp = {}; pl.lsp{1} = lsp1;

if numel(unique(tr.m0)) == 2 % reverse trainig
    pl.col{2} = pl.col{1};
    pl.lsp{2} =vertcat(pl_gen(w,{'o','*', '*'}), pl_gen(w,{':' '--' '-'}));
end
end

function pl = pl_gen(w, patt)
w0 = find(w==0);
pl = {patt{1}};

if any(w<0)
    pl = horzcat(pl, patt{2});
end

pl = horzcat(pl, patt{3});

for i = 1:numel(w0)
    pl{end+1} = patt{i};
end

pl{end+1} = patt{3};
end