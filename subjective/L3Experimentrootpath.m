function rootpath=L3Experimentrootpath()
%% L3EXPERIMENTROOTPATH Returns the path to the experiment L^3 directory
%
% This function must reside in the main directory for the subjective
% experiment.
%
% This helps with loading and saving files.
%
% Copyright Steven Lansel, 2010

rootpath=which('L3Experimentrootpath');

[rootpath,fName,ext]=fileparts(rootpath);

return
