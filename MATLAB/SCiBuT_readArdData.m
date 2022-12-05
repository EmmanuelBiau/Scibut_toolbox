function out = SCiBuT_readArdData(filename,outfile)
% SCiBuT_readArdData(filename,outfile)
%   Creates timeseries from Arduino data.
%
%   INPUTS:
%     filename      Name of the file (including path and extension)
%                   containing the data
%     outfile       Name of the file (including path and extension)
%                   containing the timeseries. 
%
%   OUTPUT:
%     out           The first column contains a time vector. All other
%                   columns contain the sensor readings
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
if ~exist('filename','var') 
    error('No filename provided');
end

% read in data
data = importdata(filename);
reset_n = 2^8*2^8;
%data = data.data;
data(:,1) = data(:,1)+1;

t_start = find(data(:,1)>0,1,'first');
data = data(t_start:end,1:end-1);
t = data(:,1);

diff_t = diff(t);
reset_ind = find(diff_t<1);

for i = 1:length(reset_ind)
   t(reset_ind(i):end)=t(reset_ind(i):end)+reset_n;
end

out = ones(max(t),length(data(1,:)));
out(1:end,1)=[1:max(t)]';

for i = 1:length(t)-1
    cur_start = t(i);
    cur_end = t(i+1)-1;        
    out(cur_start:cur_end,2:end)=repmat(data(i,2:end),cur_end-cur_start+1,1);        
end

if exist('outfile','var')
    xlswrite(outfile,num2cell(out));
end