function out = SCiBuT_ts2bits(data,cb_thresh)
% SCiBuT_SCiBuT_ts2bits(data)
%   Turns frame onsets and offsets into bits
%
%   INPUT:
%     data          A matrix containing timeseries. The data will be range
%                   normalized if the value is outside the range of 0 to 1.
%     cb_thresh     The upper threshold for frame changes (black
%                   to white or white to black)                   
%
%   OUTPUT:
%     out           The first column contains the onset times and the
%                   second column contains the bits. Use "cumsum" to get
%                   the continuous increase then "diff" to find bit
%                   inceases greater than 1 (i.e., missing frames).
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

%% Check inputs
if ~exist('data','var') 
    error('No timeseries data provided');
end
if ~exist('cb_thresh','var'); cb_thresh = 0.5; end

%% Turn data into 8bit timeseries
num_data = uint8(ones(size(data)));
for i = 1:length(data(1,:))
    cur_data = data(:,i);
    
    % range normalize data
    if max(cur_data)>1 || min(cur_data)<1
        cur_data = (cur_data-min(cur_data))/(max(cur_data)-min(cur_data));
    end
    
    % check framerate
    
    % turn into logical based on threshold
    cur_data = cur_data>cb_thresh(1);    
    num_data(:,i)=cur_data(:);
end

%% Remove data containing no changes
cur_ind = sum(num_data(1:end-1,:)==num_data(2:end,:),2)~=length(data(1,:));
t = 1:length(num_data(:,1));
num_data = num_data([0;cur_ind(:)]==1,:);
t = t([0;cur_ind(:)]==1);

%% Turn data to binary
num_data = flip(num_data,2);
bin_data = zeros(length(num_data),1);
for i = 1:length(bin_data)
    cur_bin = num2str(num_data(i,:));
    bin_data(i,1)= bin2dec(cur_bin)+1;
end

out = [t(:),bin_data];

% look for imprecise stamps
frame_diff = diff(out(:,1));
cur_med = median(frame_diff);
clean_ind = ones(length(out),1);

for i = 2:length(out)
   if diff(out(i-1:i))<cur_med/4;
       clean_ind(i-1)=0;
   end
end

% remove them
out = out(clean_ind==1,:);

% get max to start counter
cur_max = max(out(:,2));
max_ind = find(out(:,2)==max(out(:,2)));
for i = 1:length(max_ind)
   out(max_ind(i)+1:end,2)=out(max_ind(i)+1:end,2)+cur_max;
end








