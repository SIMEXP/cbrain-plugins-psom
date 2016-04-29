
#
# CBRAIN Project
#
# Copyright (C) 2008-2012
# The Royal Institution for the Advancement of Learning
# McGill University
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

class CbrainTask::PsomPipelineTask < PortalTask

  Revision_info=CbrainFileRevision[__FILE__] #:nodoc:
 
  # Populates the progress bar by reading in the stdout
  def progress_info

    color="#AAAAAA"
    percentage=0
    message="Log not available."

    if self.cluster_stdout

      color="blue"
      percentage=0
      message="Execution not started."

      self.cluster_stdout.each_line do |line| 
        if /\([0-9]* run \/ [0-9]* fail \/ [0-9]* done \/ [0-9]* left\)/.match(line)
          run = /[0-9]* run/.match(line)[0].to_s.split[0].to_f 
          done = /\/ [0-9]* done/.match(line)[0].to_s.split[1].to_f
          failed = /\/ [0-9]* fail/.match(line)[0].to_s.split[1].to_f
          left = /\/ [0-9]* left/.match(line)[0].to_s.split[1].to_f
          percentage=100*(run+done+failed)/(run+done+failed+left)
          # set toolbar color 
          red=255*(failed)/(failed+done+run)
          blue=255*(run).to_f/(failed+done+run).to_f
          green=128*(done).to_f/(failed+done+run).to_f
          color="rgb(#{red.to_i},#{green.to_i},#{blue.to_i})"
          if percentage!= 100 && (
	       CbrainTask::COMPLETED_STATUS.include?(self.status) ||
	       CbrainTask::FAILED_STATUS.include?(self.status) ||
	       self.status == "Post Processing" ||
	       self.status == "Data Ready")
            color="red"
          end
          if percentage==100
	    color="green"
          end
          message="PSOM tasks: #{run.to_i} run / #{failed.to_i} fail / #{done.to_i} done / #{left.to_i} left"
        end
      end
    end 
    return [color,percentage,message,true]
  end
  
end
