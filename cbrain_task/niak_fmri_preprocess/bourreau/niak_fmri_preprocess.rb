
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

# Bourreau-side CbrainTask subclass to launch NiakFmriPreprocess
class CbrainTask::NiakFmriPreprocess < ClusterTask

  Revision_info=CbrainFileRevision[__FILE__] #:nodoc:

  # Descriptor-based tasks are, by default, easily restartable and recoverable
  include RestartableTask
  include RecoverableTask


  # Task properties are special boolean properties of your task, returned as a
  # hash table. Used by CBRAIN code to control
  # default elements. Advanced feature. The defaults
  # for all properties are 'false' so that subclass
  # only have to explicitely set the special properties
  # that they want 'true' (since nil is also false). The list of available
  # properties is defined in class CbrainTask.
  def self.properties #:nodoc:
    # The can_submit_new_tasks property allows a task to submit new tasks.
    # To submit a new task, a task has to create a JSON file called
    # new-task-*.json at the root of its working directory. Here is an example of
    # JSON content for this file:
    # {
    #   "tool-class": "CbrainTask::TestTool",
    #   "description": "A task running TestTool",
    #   "parameters": {
    #     "important_number": "123",
    #     "dummy_paramet4er": "432"
    #    }
    # }
    # The corresponding JSON schema is maintained in method
    # validate_json_string of class BourreauWorker. 
    super.merge :can_submit_new_tasks => true
  end

  # Setup the cluster's environment to execute NiakFmriPreprocess; create the relevant
  # directories, prepare symlinks to input files, set environment variables,
  # etc. Returns true if the task was correctly set up.
  def setup #:nodoc:
    params = self.params

    # An error occured. Log +message+ and return false immediately.
    retn  = Proc.new { |r| return r }
    error = lambda do |message|
      self.addlog(message)
      retn.(false)
    end

    # Resolve all input userfiles IDs to their Userfile instances and set the
    # results data provider if missing.
    resolve_file_parameter(:'file_in', error)

    # And make them all available to NiakFmriPreprocess
    make_available(params[:'file_in'], '.')

    true
  end

  # The set of shell commands to run on the cluster to execute NiakFmriPreprocess.
  # Any output on stdout or stderr will be captured and logged for information
  # or debugging purposes.
  # Note that this function also generates the list of output filenames
  # in params.
  def cluster_commands #:nodoc:
    params = self.params

    # NiakFmriPreprocess's command line and output file names is constructed from a
    # set of key-value pairs (keys) which are substituted in the command line
    # and output templates. For example, if we have { '[1]' => '5' } for keys,
    # a command line such as "foo [1] -e [1]" would turn into "foo 5 -e 5".

    # Substitution keys for input parameters
    keys = {
      '[FILE_IN]'                              => params[:'file_in'],
      '[FOLDER_OUT]'                           => params[:'folder_out'],
      '[OPT_PSOM_MAX_QUEUED]'                  => params[:'psom_max_queued'],
      '[OPT_SLICE_TIMING_TYPE_SCANNER]'        => params[:'opt_slice_timing_type_scanner'],
      '[OPT_SLICE_TIMING_TYPE_ACQUISITION]'    => params[:'opt_slice_timing_type_acquisition'],
      '[OPT_SLICE_TIMING_DELAY_IN_TR]'         => params[:'opt_slice_timing_delay_in_tr'],
      '[OPT_RESAMPLE_VOL_VOXEL_SIZE]'          => params[:'opt_resample_vol_voxel_size'],
      '[OPT_T1_PREPROCESS_NU_CORRECT_ARG]'     => params[:'opt_t1_preprocess_nu_correct_arg'],
      '[OPT_TIME_FILTER_HP]'                   => params[:'opt_time_filter_hp'],
      '[OPT_TIME_FILTER_LP]'                   => params[:'opt_time_filter_lp'],
      '[OPT_REGRESS_CONFOUNDS_FLAG_GSC]'       => params[:'opt_regress_confounds_flag_gsc'],
      '[OPT_REGRESS_CONFOUNDS_FLAG_SCRUBBING]' => params[:'opt_regress_confounds_flag_scrubbing'],
      '[OPT_REGRESS_CONFOUNDS_THRE_FD]'        => params[:'opt_regress_confounds_thre_fd'],
      '[OPT_SMOOTH_VOL_FWHM]'                  => params[:'opt_smooth_vol_fwhm'],
      '[EXTRA_ARGS]'                           => params[:'extra_args'],
    }

    # Input/output command-line flags used with keys in command-line
    # substitution.
    flags = {
      '[FILE_IN]'                              => '--file_in',
      '[FOLDER_OUT]'                           => '--folder_out',
      '[OPT_PSOM_MAX_QUEUED]'                  => '--opt-psom-max_queued',
      '[OPT_SLICE_TIMING_TYPE_SCANNER]'        => '--opt-slice_timing-type_scanner',
      '[OPT_SLICE_TIMING_TYPE_ACQUISITION]'    => '--opt-slice_timing-type_acquisition',
      '[OPT_SLICE_TIMING_DELAY_IN_TR]'         => '--opt-slice_timing-delay_in_tr',
      '[OPT_RESAMPLE_VOL_VOXEL_SIZE]'          => '--opt-resample_vol-voxel_size',
      '[OPT_T1_PREPROCESS_NU_CORRECT_ARG]'     => '--opt-t1_preprocess-nu_correct-arg',
      '[OPT_TIME_FILTER_HP]'                   => '--opt-time_filter-hp',
      '[OPT_TIME_FILTER_LP]'                   => '--opt-time_filter-lp',
      '[OPT_REGRESS_CONFOUNDS_FLAG_GSC]'       => '--opt-regress_confounds-flag_gsc',
      '[OPT_REGRESS_CONFOUNDS_FLAG_SCRUBBING]' => '--opt-regress_confounds-flag_scrubbing',
      '[OPT_REGRESS_CONFOUNDS_THRE_FD]'        => '--opt-regress_confounds-thre_fd',
      '[OPT_SMOOTH_VOL_FWHM]'                  => '--opt-smooth_vol-fwhm',
    }

    # Generate output filenames
    params.merge!({
      :'folder_out' => apply_template('[FOLDER_OUT]', keys),
    })

    # Generate the final command-line to run NiakFmriPreprocess
    [ apply_template(<<-'CMD', keys, flags: flags) ]
      /home/niak/util/bin/niak_cmd.py [FILE_IN] [FOLDER_OUT] [OPT_PSOM_MAX_QUEUED] [OPT_SLICE_TIMING_TYPE_SCANNER] [OPT_SLICE_TIMING_TYPE_ACQUISITION] [OPT_SLICE_TIMING_DELAY_IN_TR] [OPT_RESAMPLE_VOL_VOXEL_SIZE] [OPT_T1_PREPROCESS_NU_CORRECT_ARG] [OPT_TIME_FILTER_HP] [OPT_TIME_FILTER_LP] [OPT_REGRESS_CONFOUNDS_FLAG_GSC] [OPT_REGRESS_CONFOUNDS_FLAG_SCRUBBING] [OPT_REGRESS_CONFOUNDS_THRE_FD] [OPT_SMOOTH_VOL_FWHM] [EXTRA_ARGS]
    CMD
  end

  # Called after the task is done, this method saves NiakFmriPreprocess's output files
  # to the Bourreau's cache and registers them into CBRAIN for later retrieval.
  # Returns true on success.
  def save_results #:nodoc:
    # Additional checks to see if NiakFmriPreprocess succeeded would belong here.

    # No matter how many errors occur, we need to save as many output
    # files as possible and carry the error state to the end.
    params    = self.params
    succeeded = true

    # Extract out the output files parameters from params. They will be re-added
    # once their existence is validated and their registration into CBRAIN is
    # complete.
    outputs = params.extract!(*[
      :'folder_out',
    ])

    # Make sure that every required output +path+ actually exists
    # (or that its +glob+ matches something).
    ensure_exists = lambda do |path|
      return if File.exists?(path)
      self.addlog("Missing output file #{path}")
      succeeded &&= false
    end
    ensure_matches = lambda do |glob|
      return unless Dir.glob(glob).empty?
      self.addlog("No output files matching #{glob}")
      succeeded &&= false
    end

    ensure_exists.(outputs[:'folder_out'])

    # Save (and register) all generated files to the results data provider
    outputs.each do |param, paths|
      paths = [paths] unless paths.is_a?(Enumerable)
      paths.each do |path|
        next unless path.present? && File.exists?(path)

        self.addlog("Saving result file #{path}")
        name = File.basename(path)

        output = safe_userfile_find_or_new((
          File.directory?(path) ? FileCollection : Userfile.suggested_file_type(name)
        ), :name => name)
        unless output.save
          self.addlog("Failed to save file #{path}")
          succeeded &&= false
          next
        end

        output.cache_copy_from_local_file(path)
        params[param] ||= []
        params[param]  << output.id
        self.addlog("Saved result file #{path}")

        # As all output files were generated from a single input file,
        # the outputs can all be made children of the one parent input file.
        parent = params[:'file_in']
        output.move_to_child_of(parent)
        self.addlog_to_userfiles_these_created_these([parent], [output])
      end
    end

    succeeded
  end

  # Generic helper methods

  # Make a given set of userfiles +files+ available to NiakFmriPreprocess at
  # +directory+. Simple variation on +ClusterTask+::+make_available+
  # to allow +files+ to be an Enumerable of files to make available under
  # +directory+.
  def make_available(files, directory)
    files = [files] unless files.is_a?(Enumerable)
    files.compact.each { |file| super(file, directory + '/') }
  end

  # Resolve/replace input userfiles IDs for parameter +param+
  # to their Userfile instances, calling +failed+ if a file cannot be resolved.
  # Also try and set the results data provider if its missing.
  def resolve_file_parameter(param, failed)
    value = params[param]
    return if value.nil?

    files = (value.is_a?(Enumerable) ? value : [value]).map do |file|
      file = Userfile.find_by_id(file) unless file.is_a?(Userfile)
      failed.("Could not find file with ID #{file}") unless file
      file
    end

    params[param] = value.is_a?(Enumerable) ? files : files.first
    self.results_data_provider_id ||= files.first.data_provider_id rescue nil
  end

  # Apply substitution keys +keys+ to +template+ in order to format a
  # command-line or output file name.
  # Substitute each value in +keys+ in +template+, prepended by the
  # corresponding flag in +flags+ (if available) and stripped of the
  # endings in +strip+:
  #   apply_template('f [1]', { '[1]' => 5 })
  #     => 'f 5'
  #
  #   apply_template('f [1]', { '[1]' => 5 },
  #     flags: { '[1]' => '-z' }
  #   ) => 'f -z 5'
  #
  #   apply_template('f [1]', { '[1]' => '5.z' },
  #     flags: { '[1]' => '-z' },
  #     strip: [ '.z' ]
  #   ) => 'f -z 5'
  def apply_template(template, keys, flags: {}, strip: [])
    keys.inject(template) do |template, (key, value)|
      flag = flags[key]
      next template.gsub(key, flag) if flag && value == true

      value = (value.is_a?(Enumerable) ? value.dup : [value])
        .reject(&:nil?)
        .map do |v|
          v = v.name if v.is_a?(Userfile)
          v = v.dup  if v.is_a?(String)

          strip.find do |e|
            v.sub!(/#{Regexp.quote(e)}$/, '')
          end if v.is_a?(String)

          v.to_s.bash_escape
        end
        .join(' ')

      template.gsub(key, flag && value.present? ? "#{flag} #{value}" : value)
    end
  end

end
