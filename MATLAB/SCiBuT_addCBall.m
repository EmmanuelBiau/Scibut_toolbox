function [] = SCiBuT_addCBall()
% SCiBuT_addCBall()
%   Add cigarette burn markers to all video files within a folder. Only
%   supports extensions: .mp4, .mov, .avi
%
%   Schultz Cigarette Burn Toolbox (SCiBuT; Schultz, Biau, & Kotz, 2019)
%
%   2019-04-15 benjamin.glenn.schultz@gmail.com
%   Copyright (c) 2019, Benjamin Schultz, Maastricht University.

%   This script is described in more detail in the publication:
%   Schultz, B. G., Biau, E., Kotz, S. A. (submitted to Nature Methods). 
%   An open-source toolbox for measuring dynamic video framerates and 
%   synchronizing video stimuli with neural and behavioral responses.
%   
%   The SCiBuT is distributed in the hope that it will be useful but
%   WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with the SCiBuT; if not, write to the Free Software
%   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
%   02110-1301 USA
% 
%   See the file "COPYING" for the text of the license.

% select directory
stim_dir = uigetdir;
all_files = dir(stim_dir);
all_files = {all_files([all_files.isdir]==0).name};

% preset marker dimensions
num_cb = 2;
cb_prop = 0.05;

% get all videos
all_ext = {'.mp4','.avi','.mov'};

for i = 1:length(all_files)
   
    [~,filename,ext]=fileparts(all_files{i});
    if max(strcmp(ext,all_ext))
        video_file = fullfile(stim_dir,all_files{i});
        out_file = fullfile(stim_dir,['SCiBuT_',all_files{i}]);
        SCiBuT_addCB(video_file,out_file,cb_prop,num_cb);
    end
    
end


