function log_data = SCiBuT_addTriggers(datafile,cb_chan,on_thresh,time_thresh,prefix,trig_list)
% log_data = SCiBuT_addTriggers(datafile,cb_chan,on_thresh,time_thresh,prefix,trig_list)
%   Aligns data to video onsets defined by the cigarette burn.
%   New alignments are added as trigger times. Works best on EEG data that
%   is already segmented. 
%
%   INPUTS:
%     datafile      A letswave data file (.mat) that has an associated
%                   header file (.lw6) (string)
%     cb_chan       The name of the channel that contains the cigarette 
%                   burns (changes from high and low luminance) (string)
%     on_thresh     The proportion of change (increase) required to be
%                   considered a cigarette burn (numeric, 0-1)
%     time_thresh   The time threshold before and after the event trigger
%                   from which to search for the cigarette burn (seconds)
%     prefix        The prefix given to the new datafile with the cigarette
%                   burn onset times (string)
%     trig_list     The event codes that contain visual events (cell array)
%                 
%
%   Output:
%     log_data      A log of the original trigger times and the onset times
%                   derived from the cigarette burns
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

%% Debugging presets
%datafile = 'Part01_EB';
%cb_chan = 'VisRight';

%% check inputs
if ~exist('datafile','var'); datafile = input('Please enter the name of the file \n(Waiting for input...):\n'); end;
if ~exist('cb_chan','var'); cb_chan = input('Please enter the name of the sensor channel \n(Waiting for input...):\n'); end;
if ~exist('on_thresh','var')
    on_thresh = 0.15; 
    fprintf('Onset threshold set to default: %.2f\n',on_thresh);
end
if ~exist('time_thresh','var') 
    time_thresh = [0,5];
    fprintf('Time threshold set to default: %d to %d\n',...
        time_thresh(1),time_thresh(2));
end
if ~exist('prefix','var'); prefix = 'SCiBuT'; end;
if ~exist('trigger_list','var'); trig_list = []; end;

if strcmp(datafile(end-3:end),'.mat')==0
    datafile = [datafile,'.mat'];
end

if length(time_thresh)<2
    time_thresh = [0,time_thresh];
end

% Look for the file
if ~exist(datafile,'file')
    error('Cannot find the file or path. Check the file or folder.');
end
disp('Data file exists. That''s a good start.');

%% Load Letswave files
load(datafile,'-MAT'); % load data
load(strrep(datafile,'.mat','.lw6'),'-MAT');% load header

if ~exist('data','var') || ~exist('header','var') 
    error('Data and/or header are missing. Check letswave files');
end
disp('Data loaded and in good order.');

% Look for the cigarette burn channel
all_chan_labs = {header.chanlocs.labels};
chan_ind = strcmp(all_chan_labs,cb_chan);

if max(chan_ind)==0
    error('Cannot find the cigarette burn channel: %s',cb_chan);
end
disp('Cigarette burn channel found. We''re in business.');

% Get sample rate
Fs = 1/header.xstep;
samp_thresh = round(time_thresh(2)*Fs);

% Preset new evenet codes and latencies
temp.events = header.events;

% Get event information
num_events = length(header.events);
all_events = {header.events.code};
all_epochs = cellfun(@double,{header.events.epoch});
all_latencies = cellfun(@double,{header.events.latency});

% Select which triggers to examine
if isempty(trig_list)
    events2check = ones(1,num_events);
else
    events2check = zeros(1,num_events);
    for i=1:length(trig_list)
        events2check(strcmp(all_events,trig_list{i}))=1;
    end    
end

% Preset log file
log_data = cell(sum(events2check)+1,3);
log_data(1,:)={'Event_code','Trigger_time','Video_time'};
cur_pos = 2;

%% Check for cigarette burn onsets
disp('Looking for onsets...');
for e = 1:num_events
    
    if events2check(e)==1
        log_data(cur_pos,1)=all_events(e);
        cur_data = squeeze(data(all_epochs(e),chan_ind,:,:,:,:));
        cur_data = (cur_data-min(cur_data))/(max(cur_data)-min(cur_data));
        cur_latencies_secs = all_latencies(e);
        log_data(cur_pos,2)={cur_latencies_secs*1000};
        start_samp = floor((cur_latencies_secs+time_thresh(1))*Fs);
        end_samp = start_samp+samp_thresh;
        cur_onset_samp = find(cur_data(start_samp:end_samp)>on_thresh,1)+start_samp-2;
        
        if ~isempty(cur_onset_samp)
            temp.events(e).latency = cur_onset_samp/Fs;            
            temp.events(e).code = ['SCiBuT ',temp.events(e).code];
            log_data(cur_pos,3)={cur_onset_samp/Fs*1000};
        else            
            temp.events(e).latency = NaN;
        end
        
        cur_pos = cur_pos+1;
                
    end
    
end

% Append new event codes
temp.events = temp.events(cellfun(@isnan,{temp.events.latency})==0);
fprintf('%d new onset times found. \n',length(temp.events));
header.events = [header.events,temp.events];

% Get new file name
[p,n,e]=fileparts(datafile);
out_filename = fullfile(p,[prefix,' ',n,e]);

% Update header information
header.display_settings.xaxis_auto_chk = 1;
header.name = [prefix,' ',n];

% Save data
disp('Saving data...');
save(out_filename,'data');
save(strrep(out_filename,'.mat','.lw6'),'header');

% Save log file
disp('Saving log file...');
log_file = strrep(datafile,'.mat','_log.xls');
xlswrite(log_file,log_data);

disp('Finished!');
