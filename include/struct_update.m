function st2 = struct_update(varargin)
st2 = varargin{1};
fields = fieldnames(st2);
for i = 1:nargin-1
    st2.(fields{i}) = varargin{i+1};
end
