function rootPath=L3expRootPath()
% Return the path to the root fb (five band) directory
%
% This function must reside in the directory at the base of the fbCamera
% directory structure.  It is used to determine the location of various
% sub-directories.
% 
% Example:
%   fullfile(L3expRootPath,'data')

rootPath = which('L3expRootPath');

rootPath = fileparts(rootPath);

return