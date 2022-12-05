function [] = SCiBuT_makeFlickerVid(vid_dur,fps,pidim,cb_prop,num_cb,filename,do_plots)
% SCiBuT_makeFlickerVid(vid_dur,fps,pidim,cb_prop,num_cb,filename,do_plots)
%   Makes a flicker video for examining framerate accuracy and/or 
%   neural entrainment
%
%   INPUTS:
%     vid_dur       Duration of the video
%     fps           Frames per second
%     pidim         Pixel dimensions (width x height)
%     cb_prop       The proportion of the screen width the cigarette burn
%                   will cover (default = 0.05, 5%)
%     num_burns     The number of corners containing a cigarette burn from
%                   the top right, then proceeding counter-clockwise
%                   (default = 1, max = 4)
%     filename      The name of the video. Defaults to the
%                   video specifications
%     do_plots      Make plots for visualisation
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
if ~exist('vid_dur','var'); vid_dur = 30; end;
if ~exist('fps','var'); fps = 24; end;
if ~exist('pidim','var')
    pidim = get( 0, 'Screensize' );
    pidim = pidim(3:4);
end
if ~exist('cb_prop','var'); cb_prop = 0.05; end;
if ~exist('num_cb','var'); num_cb = 0; end;
if ~exist('filename','var')
    filename = sprintf('Flicker_%dFPS_%dw_%dh_%ds',...
        fps,pidim(1),pidim(2),vid_dur);
end
if ~exist('do_plots','var'); do_plots = 0; end;
if isempty(cb_prop) || cb_prop <= 0 || num_cb == 0
    do_cb = 0;
else
    do_cb = 1;
end

% flip dimensiosn for video
pidim = flip(pidim);

% preset cig burn
if do_cb == 1
    square_sz = floor(cb_prop*pidim(1));
    
    % make all four (just in case)
    cb_dims = [1,1,square_sz,square_sz;
        1,pidim(2)-square_sz,square_sz,pidim(2);
        pidim-square_sz,pidim;
        pidim(1)-square_sz,1,pidim(1),square_sz];
    cb_cols = zeros(4,1);
end

%% preset image
cur_im = zeros([pidim,3]);
cur_im = uint8(cur_im);
num_frames = fps*vid_dur;
cur_col = 255;

%% Start writing video 
v = VideoWriter(filename);
v.FrameRate = fps;
v.Quality = 100;
open(v);

%% Add frames
for cur_frame = 1:num_frames
    
    % Change background
    if cur_col==0
        cur_col=255;
    else
        cur_col=0;
    end
    
    %cur_col=128; % grey for debugging
    cur_im(:,:,:)=cur_col;
        
    % Add cigarette burn
    if do_cb == 1        
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
    end
    
    % Write to video
    writeVideo(v,uint8(cur_im));
    
    %% Do plots for visualisation and debugging
    if do_plots == 1
        image(cur_im);
        box off;
        axis off;
        set(gca,'XTickLabel','','YTickLabel','',...
            'Xtick',[],'Ytick',[]);
        pause(.001);        
    end
    
end

% close video
close(v);


