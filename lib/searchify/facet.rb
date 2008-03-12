module Searchify
  class Facet
    attr_accessor :model_class, :name, :display_name, :type
    
    def initialize(model_class, name, type = :text, display_name = nil)
      @name = name.to_s
      @display_name = display_name
      @type = type
      @model_class = model_class
    end
    
    def display_name
      @display_name || name.titleize
    end
    
    def all?
      @name == 'all'
    end
    
    def conditions(value)
      ["#{@model_class.table_name}.#{name} LIKE ?", value]
    end
  end
end
