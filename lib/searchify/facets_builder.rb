module Searchify
  class FacetsBuilder
    def self.build(model_class, arguments, prefix = nil)
      FacetsBuilder.new(model_class, arguments, prefix).build
    end
    
    def initialize(model_class, arguments, prefix = nil)
      @model_class = model_class
      @arguments = arguments
      @prefix = prefix
    end
    
    def build
      ([build_parent_facet] + column_facets + association_facets).flatten.compact
    end
    
    private
    
    def build_parent_facet
      @parent_facet = ParentFacet.new(@model_class, :all, :text, 'All Text') if @prefix.blank?
    end
    
    def column_facets
      column_names.map { |name| facet_from_column_name(name) }
    end
    
    def association_facets
      associations_hash.map do |association_name, arguments|
        facets_from_association(association_name, arguments)
      end
    end
    
    def column_names
      @arguments.reject { |a| a.kind_of? Hash }
    end
    
    def associations_hash
      if @arguments.last.kind_of? Hash
        @arguments.last
      else
        {}
      end
    end
    
    def facet_from_column_name(name)
      raise "No column found with the name '#{name}' for searchify." if column(name).nil?
      build_facet(name)
    end
    
    def facets_from_association(name, arguments)
      raise "No association found with the name '#{name}' for searchify." if association_reflection(name).nil?
      FacetsBuilder.build(association_reflection(name).klass, arguments, name)
    end
    
    def column(name)
      @model_class.columns.detect { |c| c.name.to_s == name.to_s }
    end
    
    def association_reflection(name)
      @model_class.reflect_on_association(name)
    end
    
    def build_facet(name)
      returning Facet.new(@model_class, name, :text, nil, @prefix) do |facet|
        @parent_facet.add_child(facet) if @parent_facet
      end
    end
  end
end
