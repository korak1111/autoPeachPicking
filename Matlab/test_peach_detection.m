if count(py.sys.path,'') == 0
    insert(py.sys.path,int32(0),'');
end

% mod = py.importlib.import_module('peachDetector');

% py.reload(mod)
% py.importlib.reload(mod);

result = py.peachDetector.detect()

% python executable: /Users/Julia/miniconda3/bin/python
