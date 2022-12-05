function out = SCiBuT_getFrameChanges(data,cb_thresh)
% SCiBuT_getFrameChanges(data,cb_thresh)
%   Extracts frame onset and offset times.
%
%   INPUTS:
%     data          Time series data of the frame changes. Expects range
%                   normalized data between 0 and 1. Will normalize if
%                   range is not normalized.
%     cb_thresh     The upper and lower threshold for frame changes (black
%                   to white and white to black)
%   OUTPUT:
%     out           List of indices above and below the threshold. The
%                   first column contains the indices and the second column
%                   indicates if the data were above (1) or below (0) the
%                   threshold at each index.
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
if ~exist('cb_thresh','var'); cb_thresh = [0.55,0.45]; end;
if length(cb_thresh)<2; cb_thresh = [cb_thresh,cb_thresh]; end;

% range normalize data
if max(data)>1 || min(data)<1
   data = (data-min(data))/(max(data)-min(data));
end

% preset output
out = ones(floor(length(data)/10),2)*NaN;

%% Find onsets and offsets
% find first onsets and offsets
cur_pos = 1;
prev_offset = find(data(1:end)<cb_thresh(1),1);
if prev_offset>1
    cur_offset = prev_offset;
    while (data(cur_offset-1)>data(cur_offset)) && cur_offset>1 
        cur_offset = cur_offset-1;
    end
    out(cur_pos,:)=[cur_offset+1,0];
    cur_pos = cur_pos+1;
end
    
cur_onset = find(data(prev_offset:end)>cb_thresh(1),1)+prev_offset;

%% Find all onsets and offsets until the end of the timeseries
while ~isempty(cur_onset)
    
    cur_onset_temp = cur_onset;
    
    while cur_onset>1 && (data(cur_onset-1)<data(cur_onset))
        cur_onset = cur_onset-1;
    end
        
    out(cur_pos,:)=[cur_onset+2,1];
    cur_pos = cur_pos+1;
    
    prev_offset = find(data(cur_onset_temp+1:end)<cb_thresh(2),1)+cur_onset_temp+2;
    
    if prev_offset>length(data)
        break;
    end
    
    cur_offset = prev_offset;
    
    if isempty(cur_offset)
        %cur_offset=NaN;
        break; % leave loop
    end
    
    while cur_onset_temp>1  && (data(cur_offset-1)>data(cur_offset))
        cur_offset = cur_offset-1;
    end
        
    out(cur_pos,:)=[cur_offset+1,0];
        
    cur_onset = find(data(prev_offset:end)>cb_thresh(1),1)+prev_offset;
    
    cur_pos = cur_pos+1;
    
end

% remove empty datapoints
out = out(~isnan(out(:,1)),:);