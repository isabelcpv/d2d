% conf = arClusterConfig([name])
% 
% arClusterConfig creates a struct containing configs and infos for writting
% the moab file

function conf = arClusterConfig(name)
datum = datestr(now,30);
conf = struct;

if ~exist('name','var') || ~ischar(name)
    name = '';
else
    name = [name,'_'];
end

checksum = arAddToCheckSum(randn);
h = typecast(checksum.digest,'uint8');
checkstr = dec2hex(h)';
checkstr = checkstr(1,1:6); % keep it short
conf.name = [name,datum,'_',checkstr];

conf.matlab_release = 'R2018a';

conf.file_ar_workspace = [conf.name,'_ar.mat'];
conf.file_matlab = ['m_',conf.name,'.m']; % prevent starting with a digit
conf.file_matlab_results = ['m_',conf.name,'_results.m']; % prevent starting with a digit
conf.file_moab = [conf.name,'.moab'];
conf.file_startup = [conf.name,'.sh'];

conf.d2dpath = fileparts(which('arInit.m'));


conf.n_inNode = 5; % default, can be overwritten (I guess that the optimal number depends on how many conditions are in the model and how many cores are available on a node)
conf.n_calls = 10; % default, can be overwritten, coincides with the number of nodes

conf.arg1 = '1234'; % placeholder for arguments/variables passed to the matlab file


conf.pwd = pwd;
conf.save_path = [pwd,filesep,conf.name,'_results'];

    if ~isfolder(conf.save_path)
        mkdir(conf.save_path);
    end



