# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en
require 'common'
require 'uuid'

require 'lims/core/resource'

module Lims::Core
    module Uuids
      # Bind a uuid (as a String) to a Resource (a key and a model)
      # The key is a FixNum to find the corresponding resource in the store
      # and the model is the real class of the object (or at least something allowing to find it)
      class UuidResource
        include Resource
        attribute :key, Fixnum, :writer => :private, :initializable => true
        attribute :model_class, Class, :writer => :private, :initializable => true
        attribute :uuid, String, :writer => :private, :initializable => true

        Generator = UUID.new
        Form = [8, 4, 4, 4, 12]
        Length = Form.inject { |m, n| m+n }
        ValidationRegexp = /#{Form.map { |n| "[0-9a-f]{#{n}}" }.join('-')}/i
        SplitRegexp = /#{Form.map { |n| "([0-9a-f]{#{n}})"}.join('')}/


          def key
            # Hack to get the id after the object being save
            @key.is_a?(Proc) ? @key.call : @key
          end
        def self.valid?(uuid)
          !!(uuid =~ ValidationRegexp)
        end

        def self.generate_uuid()
          Generator.generate
        end

        # Pack a string representation of an uuid to a char(16)
        def self.pack(to_pack)
          [compact(to_pack)].pack("H*")
        end

        def self.unpack(packed)
          expand(packed.unpack("H*").first)
        end

        # Convert the string representation of an Uuid to a bignum
        # @param [String] s
        # @return [Bignum]
        def self.string_to_bignum(s)
          compact(s).to_i(16)
        end

        # Convert a bignum to a string representation 
        # @param [Bignum] b
        # @return [String]
        def self.bignum_to_string(b)
          l = Form.inject { |m, n| m+n }
          expand("%0.*x" % [l,b])
        end

        def self.expand(s)
          match = SplitRegexp.match(s)
          match.captures.join('-')
        end

        def self.compact(s)
          s.tr('-', '')
        end

        def build_resource(attributes)
          model_class.new(attributes)
        end
        protected :build_resource

        def uuid
          @uuid ||= UuidResource.generate_uuid
        end
      end
    end
end

