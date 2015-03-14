#
# Copyright 2015, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'etc'


module PoiseApplication
  # Utility methods for PoiseApplication.
  #
  # @api public
  # @since 5.0.0
  module Utils
    # Methods are also available as module-level methods as well as a mixin.
    extend self

    # Common segments to ignore
    COMMON_SEGMENTS = %w{var www current etc}.inject({}) {|memo, seg| memo[seg] = true; memo }

    # Parse the service name from the path. Look at the last component of the
    # path, ignoring some common names.
    #
    # @param path [String] Path to parse.
    # @return [String]
    # @example
    #   attribute(:service_name, kind_of: String, default: lazy { PoiseApplication::Utils.parse_service_name(path) })
    def parse_service_name(path)
      parts = ::File.split(path).reverse!
      # Find the last segment not in common segments, fall back to the last segment.
      parts.find {|seg| !COMMON_SEGMENTS[seg] } || parts.first
    end

    # Try to find the primary group name for a given user.
    #
    # @param user [String, Integer] User to check, if given as an integer this
    #   is used as a UID, otherwise it is the username.
    # @return [String]
    # @example
    #   attribute(:group, kind_of: [String, Integer], default: lazy { PoiseApplication::Utils.primary_group_for(user) })
    def primary_group_for(user)
       # Force a reload in case any users were created earlier in the run.
      Etc.endpwent
      user = if user.is_a?(Integer)
        Etc.getpwuid(user)
      else
        Etc.etcpwnam(user.to_s)
      end
      Etc.getgrgid(user.gid).name
    rescue ArgumentError
      # One of the get* calls exploded. ¯\_(ツ)_/¯
      user.to_s
    end
  end
end