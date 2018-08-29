classdef IniFile < dynamicprops
    properties
        FileName        
        isValid
        isModified
    end
    
    properties (Access = private)
        Header
        Variables
        Values
        Type
        Type0
        Comment
    end
    
    methods
        function obj = IniFile(varargin)
            obj.isValid = false;
            if ~nargin
                [fn p] = uigetfile('*','Please select a configuration file', [pwd '/']);
                obj.FileName = fullfile(p,fn);
            else
                if ~isempty(fileparts(varargin{1})) && exist(varargin{1},'file')
                    obj.FileName = varargin{1};
                else
                    if ~isempty(fileparts(varargin{1}))
                        fname = strrep(varargin{1},fileparts(varargin{1}),'');
                        fname = fname(2:end);
                    else
                        fname = varargin{1};
                    end
                    if exist(fullfile(pwd,fname),'file')
                        obj.FileName = fullfile(pwd,fname);
                    elseif ~isempty(which(fname))
                        obj.FileName = which(fname);
                    else
                        disp('ERROR! The specified configuration file not found. Aborting ...');
                        return;
                    end
                end
            end
            
            [fid,message] = fopen(obj.FileName);
            if ~isempty(message)
                disp('ERROR! The specified configuration file could not be opened. Aborting ...');
                return;
            end
            
            Lines = {};
            while ~feof(fid)
                Lines{end+1} = fgetl(fid);
            end
            fclose(fid);

            for i = 1:numel(Lines)
                if ~isempty(Lines{i}) && (Lines{i}(1) == '['), break; end
            end
            obj.Header = {Lines{1:i-1}};
            
            ns = 0; obj.Variables = {}; obj.Type = {}; obj.Comment = {}; C = '';
            for i = numel(obj.Header)+1:numel(Lines)
                if ~isempty(strfind(Lines{i},'%'))
                    if Lines{i}(1) == '%', C = Lines{i}; end
                end
                sep1 = strfind(Lines{i},'[');
                sep2 = strfind(Lines{i},']');
                if isempty(sep1)
                    continue;
                end
                if (sep1 == 1) % subset
                    ns = ns + 1;
                    obj.Variables{ns,1} = Lines{i}(sep1+1:sep2-1);
                end
                nv = 0;
                for j = 1:size(obj.Variables,2)
                    nv = nv + ~isempty(obj.Variables{ns,j});
                end
                nv = nv + 1;
                obj.Variables{ns,nv} = Lines{i}(1:sep1-1);
                obj.Type{ns,nv} = Lines{i}(sep1+1:sep2-1);
                switch obj.Type{ns,nv}
                    case 'n' % number
                        obj.Values{ns,nv} = str2num(Lines{i}(sep2+2:end));
                    case 'd' % date
                        obj.Values{ns,nv} = datestr(datenum(Lines{i}(sep2+2:end),31));
                    otherwise %'s' - string; 'e' - eval
                        obj.Values{ns,nv} = Lines{i}(sep2+2:end);
                end
                if ~isempty(C)
                    obj.Comment{ns,nv} = C;
                    C = '';
                end
            end
            for i = 1:size(obj.Variables,1)
                varname = lower(obj.Variables{i,1});
                val = struct;
                for j = 2:size(obj.Variables,2)
                    if ~isempty(obj.Variables{i,j})
                        if obj.Type{i,j} == 'e'
                            val.(obj.Variables{i,j}) = eval(obj.Values{i,j});
                        else
                            val.(obj.Variables{i,j}) = obj.Values{i,j};
                        end
                    end
                end
                obj.addprop(varname);
                obj.(varname) = val;
            end
            obj.isModified = false;
            obj.isValid = true;
        end
        
%         function delete(obj)
%             if obj.isValid, obj.Close; end
%         end
        
        function e = Close(obj,fn)
            obj = obj.Check(true);
            istow = false;
            if (nargin > 1) && ~strcmp(obj.FileName,fn)
                obj.FileName = fn;
                istow = true;
            end
            if obj.isModified || istow
                fprintf('Modification is to be writen...');
                
                Lines = obj.Header;
                for i = 1:size(obj.Variables,1)
                    Lines{end+1} = sprintf('[%s]',upper(obj.Variables{i,1}));
                    for j = 2:size(obj.Variables,2)
                        if ~isempty(obj.Variables{i,j})
                            if  (size(obj.Comment,1) >= i) && (size(obj.Comment,2) >= j) && ~isempty(obj.Comment{i,j})
                                Lines{end+1} = sprintf('%s',obj.Comment{i,j});
                            end
                            Lines{end+1} = sprintf('%s[%s]=%s',obj.Variables{i,j},obj.Type{i,j},num2str(obj.Values{i,j}));
                        end
                    end
                    Lines{end+1} = '';
                end
                
                [fid,message] = fopen(obj.FileName, 'w');
                if ~isempty(message)
                    error('The specified configuration file could not be opened. Aborting ...');
                end
                for i = 1:numel(Lines)-2
                    fprintf(fid, '%s\n', Lines{i});
                end
                fprintf(fid, '%s', Lines{end-1});
                fclose(fid);
                
                fprintf('Done\n');
                e = 1;
                obj.isModified = false;
            end
        end
        
        function str = getComment(obj,vStruct,vName)
            ns = cell_index({obj.Variables{:,1}},upper(vStruct));
            if ns % existing Struct
                nv = cell_index({obj.Variables{ns,:}},vName);
                if nv
                    str = obj.Comment{ns,nv};
                    if ~isempty(str), str = strrep(str,'% ',''); end
                end
            end
            if ~ns || ~nv
                fprintf('ERROR! No variable %s within struct %s exists in configuration %s!\n',...
                    vName, vStruct, obj.FileName);
            end
        end
        
        function str = getType(obj,vStruct,vName)
            ns = cell_index({obj.Variables{:,1}},upper(vStruct));
            if ns % existing Struct
                nv = cell_index({obj.Variables{ns,:}},vName);
                if nv
                    str = obj.Type{ns,nv};
                    if ~isempty(str), str = strrep(str,'% ',''); end
                end
            end
            if ~ns || ~nv
                fprintf('ERROR! No variable %s within struct %s exists in configuration %s!\n',...
                    vName, vStruct, obj.FileName);
            end
        end
        
        function obj = AddVariable(obj,vStruct,nv,vName,vType,vVal,vComm)
            out = 0;
            ns = cell_index({obj.Variables{:,1}},upper(vStruct));
            if ns % existing Struct
                if ~nv
                    for j = 1:size(obj.Variables,2)
                        nv = nv + ~isempty(obj.Variables{ns,j});
                    end
                end
                nv = nv + 1;
                obj.Variables = cell_insert(obj.Variables,vName,[ns nv]);
                obj.Type = cell_insert(obj.Type,vType,[ns nv]);
                obj.Values = cell_insert(obj.Values,vVal,[ns nv]);
                if nargin < 7 || isempty(vComm)
                    vComm = '';
                else
                    vComm = sprintf('%% %s',vComm);
                end
                obj.Comment = cell_insert(obj.Comment,vComm,[ns nv]);
                if vType == 'e'
                    obj.(vStruct).(vName) = eval(vVal);
                else
                    obj.(vStruct).(vName) = vVal;
                end
            else
                fprintf('ERROR! No struct %s exists in configuration %s!\n',vStruct, obj.FileName);
                out = 1;
            end
            obj.isModified = ~logical(out);
        end
        
        function obj = RemoveVariable(obj,vStruct,vName)
            out = 0;
            ns = cell_index({obj.Variables{:,1}},upper(vStruct));
            if ns % existing Struct
                nv = cell_index({obj.Variables{ns,:}},vName);
                if nv
                    obj.Variables = cell_remove(obj.Variables,[ns nv]);
                    obj.Type = cell_remove(obj.Type,[ns nv]);
                    obj.Values = cell_remove(obj.Values,[ns nv]);
                    obj.Comment = cell_remove(obj.Comment,[ns nv]);
                    obj.(vStruct) = rmfield(obj.(vStruct),vName);
                end
            end
            if ~ns || ~nv
                fprintf('ERROR! No variable %s within struct %s exists in configuration %s!\n',...
                    vName, vStruct, obj.FileName);
                out = 1;
            end
            obj.isModified = ~logical(out);
        end
        
        function obj = ExcludeVariable(obj,vStruct,vName)
            ns = cell_index({obj.Variables{:,1}},upper(vStruct));
            if ns % existing Struct
                nv = cell_index({obj.Variables{ns,:}},vName);
                if nv
                    obj.Type0{ns, nv} = obj.Type{ns, nv};
                    obj.Type{ns, nv} = '0';
                end
            end
            if ~ns || ~nv
                fprintf('ERROR! No variable %s within struct %s exists in configuration %s!',...
                    vName, vStruct, obj.FileName);
            end
        end
        
        function obj = IncludeVariable(obj,vStruct,vName)
            ns = cell_index({obj.Variables{:,1}},upper(vStruct));
            if ns % existing Struct
                nv = cell_index({obj.Variables{ns,:}},vName);
                if nv, obj.Type{ns, nv} = obj.Type0{ns, nv}; end
            end
            if ~ns || ~nv
                fprintf('ERROR! No variable %s within struct %s exists in configuration %s!',...
                    vName, vStruct, obj.FileName);
            end
        end
        
        function out = getFields(obj)
            snames = fieldnames(obj);
            for i = 1:numel(snames)
                isf(i) = isstruct(obj.(snames{i}));
            end
            out = snames(isf);
        end
        
        function obj = Sanity(obj,ini_def)
            obj_def = IniFile(ini_def);
            s_in = obj.getFields;
            s_def = obj_def.getFields; % must be identical with s_in
            
            for s = 1:numel(s_in)
                v_in = fieldnames(obj.(s_in{s}));
                v_def = fieldnames(obj_def.(s_in{s}));
                nv = numel(v_in);
                for v = 1:numel(v_def)
                    if isempty(find(strmatch(v_def{v},v_in),1))
                        fprintf('%s - %s is missing! - Added.\n',upper(s_in{s}),v_def{v});
                        nv = nv + 1;
                        obj.AddVariable(s_in{s},...
                            nv-(numel(v_def)-v+1)+1,...
                            v_def{v},...
                            obj_def.getType(s_in{s},v_def{v}),...
                            obj_def.(s_in{s}).(v_def{v}),...
                            obj_def.getComment(s_in{s},v_def{v}));
                    end
                end
            end
        end
    end
    
    methods (Access = private)
        function obj = Check(obj,corr)
            snames = obj.getFields;
            for ns = 1:numel(snames)
                vnames = fieldnames(obj.(snames{ns}));
                for nv = 1:min(numel(vnames),size(obj.Variables,2)-1)
                    nc = cell_index({obj.Variables{:,1}},upper(snames{ns}));
                    if (nv+1 > size(obj.Variables,2)) || isempty(obj.Variables{nc,nv+1}), continue; end
                    old = obj.Values{nc,nv+1};                    
                    new = obj.(snames{ns}).(obj.Variables{nc,nv+1});                        
                    switch obj.Type{nc,nv+1}
                        case 'e' % eval
                            if iscell(new) % 1D cell with strings
                                newstr = '{ ';
                                if iscolumn(new), sep = ';'; else sep = ' '; end
                                for i = 1:numel(new)
                                    newstr = [newstr '''' new{i} '''' sep];
                                end
                                newstr = [newstr ' }'];
                                new = newstr;
                                if ~strcmp(old,new)
                                    obj.isModified = true;
                                end
                            else % matrix up to 2-D
                                new = mat2str(new);
                                if ~strcmp(old,new)
                                    obj.isModified = true;
                                end
                            end
                        case 'n' % number
                            if old ~= new
                                obj.isModified = true;
                            end
                        case 'd' % date
                            if datenum(old) ~= datenum(new)
                                obj.isModified = true;
                            end
                        case 's' % string
                            if ~strcmp(old,new)
                                obj.isModified = true;
                            end
                        otherwise % '0' no check
                            continue;
                    end
                    if corr, obj.Values{nc,nv+1} = new; end
                end
            end
        end
    end
end