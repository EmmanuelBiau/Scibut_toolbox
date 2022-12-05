function [] = SCiBuT_addCB(video_file,out_file,cb_prop,num_cb)
% SCiBu_addCigBurn(videoName,stim_dir,out_dir,cb_prop,comp_type)
%   Adds cigarette burns to the corner(s) of the input video
%
%   INPUTS:
%     video_file    The video file to which the cigarette burns will be
%                   added in the extreme corner(s)
%     out_file      The name of the file to which the video will be written
%     cb_prop       The proportion of the screen the cigarette burn will
%                   cover (default = 0.05, 5%)
%     num_cb        The number of corners containing a cigarette burn from
%                   the Top right, then proceeding counter-clockwise
%                   (default = 1, max = 4)
%
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
if ~exist('video_file','var'); video_file = input('Please enter the name of the video \n(Waiting for input...):\n'); end;
[stim_dir,vid_name,vid_ext] = fileparts(video_file);
if isempty(vid_ext)
    disp('Video extension not provided. Searching for file...');
    file_list = dir(fullfile(stim_dir,[vid_name,'*']));
    file_list = {file_list.name};
    if isempty(file_list)
        error('Cannot find a video file: %s',video_file);
    else
        [~,vid_name,vid_ext] = fileparts(file_list{1});
        fprintf('Video found: %s\n',file_list{1});
    end    
end
video_file = fullfile(stim_dir,[vid_name,vid_ext]);
if ~exist('out_file','var'); out_file = fullfile(stim_dir,['SCiBuT_',vid_name,vid_ext]); end;
[out_dir,out_name,out_vid_ext] = fileparts(out_file);
if isempty(out_vid_ext)
    out_vid_ext = vid_ext;
end
out_file = fullfile(out_dir,[out_name,out_vid_ext]);
if ~exist('cb_prop','var'); cb_prop = 0.05; end;
if ~exist('num_cb','var'); num_cb = 1; end;
do_plots = 1;

% catch if cb_prop is not a proportion
while cb_prop>1
    warning('Proportion too large for the burn size: %d',cb_prop);
    cb_prop = cb_prop/10; % make sure it is a proportion
    warning('Rescaling to a proportion: %d',cb_prop);    
end

%% Load video
v = VideoReader(video_file);

% get current frame size
pidim = [v.Height,v.Width];

% preset cig burn
square_sz = floor(cb_prop*pidim(1));

% make all four positions (just in case)
cb_dims = [1,1,square_sz,square_sz;
    1,pidim(2)-square_sz,square_sz,pidim(2);
    pidim-square_sz,pidim;
    pidim(1)-square_sz,1,pidim(1),square_sz];
cb_cols = ones(4,1)*255;

%% Write the new video
out_v = VideoWriter(out_file);

Fps = v.FrameRate;
out_v.FrameRate = Fps;
out_v.Quality = 100;

% write to video
open(out_v);
cur_frame = 1;

while hasFrame(v)
    
    % get frame
    cur_im = readFrame(v);
        
    % Add cigarette burn
    if cur_frame==1
        for i = 1:num_cb
            cur_im(cb_dims(i,1):cb_dims(i,3),cb_dims(i,2):cb_dims(i,4),:)=cb_cols(i);
        end        
    end
    
    for i = 1:num_cb
        cur_bits = 2^(i-1);
        if mod(cur_frame,cur_bits)==0
            if cb_cols(i)==0
                cb_cols(i) = 255;
            elseif cb_cols(i)==255
                cb_cols(i) = 0;
            end
            
        end
        cur_im(cb_dims(i,1):cb_dims(i,3),cb_dims(i,2):cb_dims(i,4),:)=cb_cols(i);
    end
    
    % write to video
    writeVideo(out_v,cur_im);
    
    %% Do plots for visualisation and debugging
    if do_plots == 1
        pause(.001);
        image(cur_im);
        box off;
        axis off;
        set(gca,...
            'XTickLabel','',...
            'YTickLabel','',...
            'Xtick',[],'Ytick',[])
    end
    
    cur_frame = cur_frame+1;

end

% close all videos
close(out_v);



