module Kinksync
  #
  # Class that represents a duple of files with *absolute* path which
  # can be synced
  #
  class File2Sync
    #
    # Configures a File2Sync class
    #
    # @param file [String] local or cloud file to sync
    #
    def initialize(file)
      raise Error::InvalidSyncFile unless File.exist?(file)
      @file = file
      @twin_file = twin_file(file)
    end

    #
    # Sync a file, copying origin over destination
    #
    # @return file or nil if file is already synced
    #
    def sync
      if File.exist?(@twin_file) && FileUtils.identical?(@file, @twin_file)
        nil
      else
        origin = newer
        destination = twin_file(origin)
        FileUtils.mkdir_p(File.dirname(@twin_file))
        FileUtils.cp(origin, destination)
        @file
      end
    end

    private

    #
    # Return newer file
    #
    def newer
      FileUtils.uptodate?(@file, [@twin_file]) ? @file : @twin_file
    end

    #
    # Gets twin file of file provided
    #
    # @param file [String] file to get twin from
    #
    def twin_file(file)
      if in_cloud? file
        file.sub(Kinksync.configuration.cloud_path, '')
      else
        Kinksync.configuration.cloud_path + file
      end
    end

    #
    # Decides whether a file is in cloud or local location
    #
    # @param file [String]
    #
    def in_cloud?(file)
      File.dirname(file).start_with?(Kinksync.configuration.cloud_path)
    end
  end
end
