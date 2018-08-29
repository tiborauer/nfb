function reg = read_BV(cfg)

d = dir(fullfile(cfg.RefDir_Train,'*.fmr'));
fn = fullfile(cfg.RefDir_Train,d(1).name);
[nVol, TR] = read_fmr(fn);

d = dir(fullfile(cfg.RefDir_Train,'*.prt'));
fn = fullfile(cfg.RefDir_Train,d(1).name);
reg = read_prt(fn, nVol, TR);

d = dir(fullfile(cfg.RefDir_Train,'*.ctr'));
fn = fullfile(cfg.RefDir_Train,d(1).name);
con = read_ctr(fn);
reg = reg'*con';
end

function [nVol, TR] = read_fmr(fn)
fid = fopen(fn,'r');
lines = textscan(fid, '%s %s');
nVol =  str2double(lines{2}{cell_index(lines{1}, 'NrOfVolumes')});
TR = str2double(lines{2}{cell_index(lines{1}, 'TR')});
fclose(fid);
end

function reg = read_prt(fn, nVol, TR)
lines = read_file(fn);

lit = cell_index(lines, 'NrOf');
reg_nr = str2double(lines{lit}(end));
for i = 1:reg_nr
    for j = lit:numel(lines)
        if isempty(lines{j})
            ind_reg(i) = j+2;
            lit = j+2;
            break;
        end
    end
end


retime = logical(cell_index(lines, 'msec'));

ta = [];
for i = 1:numel(ind_reg)
    nr_lines = str2double(lines{ind_reg(i)});
    for j = 1:nr_lines
        t =str2num(lines{ind_reg(i)+j});
        ta(end+1,:) = t;
        reg(i,t(1):t(2)) = 1;
    end
end

if retime
    l = nVol*TR;
    for i = 1:size(reg,1)
        regt(i,:) = spline(1:l, reg(i,1:l), 1:TR:l);
    end
    reg = regt;
end
end

function con = read_ctr(fn)
lines = read_file(fn);
c = importdata(fn,' ',cell_index(lines,'ContrastVectors'));
cons = c.data;
c = importdata(fn,' ',cell_index(lines,'InitialSelectionState'));
sel = logical(c.data);
con = cons(sel,:);
end