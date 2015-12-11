
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

# NOTE: This is a working template generated from a descriptor:
# [Schema]         http://github.com/boutiques/boutiques-schema
# [Schema version] 0.2
# [Tool]           Niak_fmri_preprocess
# [Version]        0.13.4
# See the CbrainTask Programmer Guide (CBRAIN Wiki) for a more complete picture
# of how CbrainTasks are constructed.

# Portal-side CbrainTask subclass to launch NiakFmriPreprocess
class CbrainTask::NiakFmriPreprocess < PortalTask

  Revision_info=CbrainFileRevision[__FILE__] #:nodoc:

  # Default values for some (all?) of NiakFmriPreprocess's parameters. Those values
  # reflect the defaults taken by the tool's developer; feel free to change
  # them to match your platform's requirements.
  def self.default_launch_args #:nodoc:
    {
      :'folder_out'                           => "results-directory",
      :'psom_max_queued'                      => 4,
      :'opt_slice_timing_type_scanner'        => "Bruker",
      :'opt_slice_timing_type_acquisition'    => "interleaved ascending",
      :'opt_slice_timing_delay_in_tr'         => 0,
      :'opt_resample_vol_voxel_size'          => 10,
      :'opt_t1_preprocess_nu_correct_arg'     => "-distance 75",
      :'opt_time_filter_hp'                   => 0.01,
      :'opt_time_filter_lp'                   => "Inf",
      :'opt_regress_confounds_flag_gsc'       => "true",
      :'opt_regress_confounds_flag_scrubbing' => "true",
      :'opt_regress_confounds_thre_fd'        => "0.5",
      :'opt_smooth_vol_fwhm'                  => 6,
    }
  end

  # Callback called just before the task's form is rendered. At this point,
  # the task's params hash contains at least the default list of input
  # userfiles under the key :interface_userfile_ids. 
  def before_form #:nodoc:
    # Resolve interface_userfile_ids to actual userfile objects
    files = Userfile.find_all_by_id(self.params[:interface_userfile_ids])

    # At least one file is required.
    cb_error "Error: this task requires at least one input file" if files.empty?

    ""
  end

  # Callback called just after the task's form has been submitted by the user.
  # At this point, all the task's params will be filled. This is where most
  # validations happens.
  def after_form #:nodoc:
    params = self.params

    # Sanitize every input parameter according to their expected type

    # Required parameters
    sanitize_param(:'folder_out',                           :string)
    sanitize_param(:'psom_max_queued',                      :number)
    sanitize_param(:'opt_slice_timing_type_scanner',        :string)
    sanitize_param(:'opt_slice_timing_type_acquisition',    :string)
    sanitize_param(:'opt_slice_timing_delay_in_tr',         :number)
    sanitize_param(:'opt_resample_vol_voxel_size',          :number)
    sanitize_param(:'opt_t1_preprocess_nu_correct_arg',     :string)
    sanitize_param(:'opt_time_filter_hp',                   :number)
    sanitize_param(:'opt_time_filter_lp',                   :string)
    sanitize_param(:'opt_regress_confounds_flag_gsc',       :string)
    sanitize_param(:'opt_regress_confounds_flag_scrubbing', :string)
    sanitize_param(:'opt_regress_confounds_thre_fd',        :number)
    sanitize_param(:'opt_smooth_vol_fwhm',                  :number)

    # Optional parameters
    sanitize_param(:'extra_args',                           :string) unless params[:'extra_args'].nil?

    ""
  end

  # Final set of tasks to be launched based on this task's parameters. Only
  # useful if the parameters set for this task represent a set of tasks
  # instead of just one.
  def final_task_list #:nodoc:
    # Create a list of tasks out of the default input file list
    # (interface_userfile_ids), each file going into parameter 'file_in'
    self.params[:interface_userfile_ids].map do |id|
      task = self.dup

      # Set and sanitize the one file parameter for each id
      task.params[:'file_in'] = id
      task.sanitize_param(:'file_in', :file)

      task.description ||= ''
      task.description  += " file_in: #{Userfile.find(id).name}"
      task.description.strip!
      task
    end
  end

  # Task parameters to leave untouched by the edit task mechanism. Usually
  # for parameters added in after_form or final_task_list, as those wouldn't
  # be present on the form and thus lost when the task is edited.
  def untouchable_params_attributes #:nodoc:
    # Output parameters will be present after the task has run and need to be
    # preserved.
    {
      :'folder_out' => true,
    }
  end

  # Generic helper methods

  # Ensure that the parameter +name+ is not null and matches a generic tool
  # parameter +type+ (:file, :numeric, :string or :flag) before converting the
  # parameter's value to the corresponding Ruby type (if appropriate).
  # For example, sanitize_param(:deviation, :numeric) would validate that
  # self.params[:deviation] is a number and then convert it to a Ruby Float or
  # Integer.
  #
  # Available +options+:
  # [file_type] Userfile type to validate a parameter of +type+ :file against.
  #
  # If the parameter's value is an array, every value in the array is checked
  # and expected to match +type+.
  #
  # Raises an exception for task parameter +name+ if the parameter's value
  # is not adequate.
  def sanitize_param(name, type, options = {})
    # Taken userfile names. An error will be raised if two input files have the
    # same name.
    @taken_files ||= Set.new

    # Fetch the parameter and convert to an Enumerable if required
    values = self.params[name] rescue nil
    values = [values] unless values.is_a?(Enumerable)

    # Validate and convert each value
    values.map! do |value|
      case type
      # Try to convert to integer and then float. Cant? then its not a number.
      when :number
        if (number = Integer(value) rescue Float(value) rescue nil)
          value = number
        elsif value.blank?
          params_errors.add(name, ": value missing")
        else
          params_errors.add(name, ": not a number (#{value})")
        end

      # Nothing special required for strings, bar for symbols being acceptable strings.
      when :string
        value = value.to_s if value.is_a?(Symbol)
        params_errors.add(name, " not a string (#{value})") unless value.is_a?(String)

      # Try to match against various common representation of true and false
      when :flag
        if value.is_a?(String)
          value = true  if value =~ /^(true|t|yes|y|on|1)$/i
          value = false if value =~ /^(false|f|no|n|off|0|)$/i
        end

        if ! [ true, false ].include?(value)
          params_errors.add(name, ": not true or false (#{value})")
        end

      # Make sure the file ID is valid, accessible, not already used and
      # of the correct type.
      when :file
        unless (id = Integer(value) rescue nil)
          params_errors.add(name, ": invalid or missing userfile (ID #{value})")
          next value
        end

        unless (file = Userfile.find_accessible_by_user(value, self.user))
          params_errors.add(name, ": cannot find userfile (ID #{value})")
          next value
        end

        if @taken_files.include?(file.name)
          params_errors.add(name, ": file name already in use (#{file.name})")
        else
          @taken_files.add(file.name)
        end

        if type = options[:file_type]
          type = type.constantize unless type.is_a?(Class)
          params_errors.add(name, ": incorrect userfile type (#{file.name})") if
            type && ! file.is_a?(type)
        end
      end

      value
    end

    # Store the value back
    self.params[name] = values.first unless self.params[name].is_a?(Enumerable)
  end

end
