function [] = SCiBuT_example(datafile)
% SCiBuT_example(datafile)
%   Example for measuring framerates from datafile
%
%   INPUT:
%     datafile      Name of a text file produced by measuring frame changes
%                   with the SCiBuT toolbox
%
%   OUTPUT:         Prints summary data
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

if ~exist('datafile','var'); datafile = 'SCiBuT_TEST.txt'; end

% read the test data
data = SCiBuT_readArdData(datafile);

% preset data
all_periods = zeros(size(data,2)-1,1);
all_onsets = zeros(size(data,2)-1,1);
all_offsets = zeros(size(data,2)-1,1);
all_fps = zeros(size(data,2)-1,1);
min_fps = zeros(size(data,2)-1,1);
max_fps = zeros(size(data,2)-1,1);

% extract the frame changes
for i = 2:size(data,2)
    onsets = SCiBuT_getFrameChanges(data(:,i),[0.51,0.49]);
    cur_periods = diff(onsets(:,1));    
    all_periods(i-1)=median(cur_periods);
    all_onsets(i-1)=onsets(3,1);
    all_offsets(i-1)=onsets(end-3,1);    
end

first_onset = min(all_onsets);
last_onset = max(all_offsets);
    
% clean datafile based on first and last onset/offset
data = data(first_onset-10:last_onset+10,:);

% extract the frames per second
for i = 2:size(data,2)
    onsets = SCiBuT_getFrameChanges(data(:,i),[0.51,0.49]);
    cur_periods = diff(onsets(:,1));    
    cur_fps = 1./(cur_periods/1000);
    all_fps(i-1) = mean(cur_fps);
    max_fps(i-1) = max(cur_fps);
    min_fps(i-1) = min(cur_fps);
end


% order data according to slowest to fastest
[~,ind]=sort(all_fps,'descend');

% extract missing frames
bit_ts = SCiBuT_ts2bits(data(:,ind+1));
bit_ts_diff = diff(bit_ts(:,2));
missing_frame_ind = find(bit_ts_diff>1);
num_missing = length(missing_frame_ind);

% print important information
fprintf('Average framerate = %0.2f\n',max(all_fps));
fprintf('Minimum framerate = %0.2f\n',max(min_fps));
fprintf('Maximum framerate = %0.2f\n',max(max_fps));
fprintf('Number of missing frames = %d\n',num_missing);
