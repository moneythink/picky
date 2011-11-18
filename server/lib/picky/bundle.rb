module Picky
  # A Bundle is a number of indexes
  # per [index, category] combination.
  #
  # At most, there are three indexes:
  # * *core* index (always used)
  # * *weights* index (always used)
  # * *similarity* index (used with similarity)
  #
  # In Picky, indexing is separated from the index
  # handling itself through a parallel structure.
  #
  # Both use methods provided by this base class, but
  # have very different goals:
  #
  # * *Indexing*::*Bundle*::*Base* is just concerned with creating index
  #   files / redis entries and providing helper functions to e.g. check
  #   the indexes.
  #
  # * *Index*::*Bundle*::*Base* is concerned with loading these index files into
  #   memory / redis and looking up search data as fast as possible.
  #
  class Bundle

    attr_reader :name,
                :category,
                :backend

    attr_accessor :inverted,
                  :weights,
                  :similarity,
                  :configuration,

                  :backend_inverted,
                  :backend_weights,
                  :backend_similarity,
                  :backend_configuration,

                  :weights_strategy,
                  :partial_strategy,
                  :similarity_strategy

    delegate :[], :[]=,        :to => :configuration
    delegate :index_directory, :to => :category

    def initialize name, category, backend, weights_strategy, partial_strategy, similarity_strategy, options = {}
      @name     = name
      @category = category

      # TODO Tidy up a bit.
      #
      @key_format = options[:key_format]

      @weights_strategy    = weights_strategy
      @partial_strategy    = partial_strategy
      @similarity_strategy = similarity_strategy

      reset_backend backend
    end
    def identifier
      "#{category.identifier}:#{name}"
    end

    # Resets the backend with the given one instantly.
    #
    # TODO Redesign such that the backend is only
    #      generated lazily.
    #      And reset using backend = nil.
    #
    def reset_backend backend
      # Extract specific indexes from backend.
      #
      # TODO Clean up all related.
      #
      @backend_inverted      = backend.create_inverted      self
      @backend_weights       = backend.create_weights       self
      @backend_similarity    = backend.create_similarity    self
      @backend_configuration = backend.create_configuration self

      # Initial indexes.
      #
      # Note that if the weights strategy doesn't need to be saved,
      # the strategy itself pretends to be an index.
      #
      @inverted      = @backend_inverted.initial
      @weights       = @weights_strategy.saved?? @backend_weights.initial : @weights_strategy
      @similarity    = @backend_similarity.initial
      @configuration = @backend_configuration.initial

      @realtime_mapping = {} # id -> ary of syms.  TODO Always instantiate? d
    end

    # "Empties" the index(es) by getting a new empty
    # internal backend instance.
    #
    def empty
      empty_inverted
      empty_weights
      empty_similarity
      empty_configuration
    end
    def empty_inverted
      @inverted = @backend_inverted.empty
    end
    def empty_weights
      # TODO THINK about this. Perhaps the strategies should implement the backend methods?
      #
      @weights = @weights_strategy.saved?? @backend_weights.empty : @weights_strategy
    end
    def empty_similarity
      @similarity = @backend_similarity.empty
    end
    def empty_configuration
      @configuration = @backend_configuration.empty
    end

    # Get a list of similar texts.
    #
    # Note: Does not return itself.
    #
    def similar text
      code = similarity_strategy.encoded text
      similar_codes = code && @similarity[code]
      similar_codes.delete text if similar_codes
      similar_codes || []
    end

    # If a key format is set, use it, else delegate to the category.
    #
    def key_format
      @key_format || @category.key_format
    end

    # Path and partial filename of a specific subindex.
    #
    # Subindexes are:
    #  * inverted index
    #  * weights index
    #  * partial index
    #  * similarity index
    #
    # Returns just the part without subindex type,
    # if none given.
    #
    def index_path type = nil
      ::File.join index_directory, "#{category.name}_#{name}#{ "_#{type}" if type }"
    end

    # Delete all index files.
    #
    def delete
      @backend_inverted.delete       if @backend_inverted.respond_to? :delete
      # TODO THINK about this. Perhaps the strategies should implement the backend methods?
      #
      @backend_weights.delete        if @backend_weights.respond_to?(:delete) && @weights_strategy.saved?
      @backend_similarity.delete     if @backend_similarity.respond_to? :delete
      @backend_configuration.delete  if @backend_configuration.respond_to? :delete
    end

    def to_s
      "#{self.class}(#{identifier})"
    end

  end
end