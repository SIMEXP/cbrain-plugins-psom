
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

class CbrainTask::PsomPipelineTask < ClusterTask

  Revision_info=CbrainFileRevision[__FILE__] #:nodoc:
  
  # Overrides stdout_cluster_filename to look for PIPE_history.txt in
  # Niak's output in case stdout file is not here (which happens on
  # some clusters whe task is not finished).
  def stdout_cluster_filename(run_number=nil)
    stdout_file_name = super(run_number)
    return stdout_file_name if File.exists?(stdout_file_name)
    return File.join(self.full_cluster_workdir,"results-directory","logs","PIPE_history.txt")
  end

end
