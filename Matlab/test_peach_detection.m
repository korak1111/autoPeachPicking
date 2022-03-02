% setenv('TCL_LIBRARY', 'C:\Users\cyrus\AppData\Local\Programs\Python\Python39\tcl\tcl8.6')
% setenv('TK_LIBRARY', 'C:\Users\cyrus\AppData\Local\Programs\Python\Python39\tcl\tk8.6')
% 
% py.importlib.import_module('tkinter')


% if count(py.sys.path,'') == 0
%     insert(py.sys.path,int32(0),'');
% end

% 
% % mod = py.importlib.import_module('peachDetector');
% 
% % py.reload(mod)
% % py.importlib.reload(mod);
% 
% result = py.peachDetector.predict()
% py.importlib.import_module('numpy')
% py.importlib.import_module('torch')
% py.importlib.import_module('cv2')

pyrunfile('peachDetector.py')

% 
% % python executable: /Users/Julia/miniconda3/bin/python


