ActiveRecord::Acts::Tree::ClassMethods.module_eval do
  def acts_as_tree(options = {})
    configuration = { :foreign_key => "parent_id", :order => nil, :counter_cache => nil, :conditions => nil }
    configuration.update(options) if options.is_a?(Hash)

    belongs_to :parent, :class_name => name, :foreign_key => configuration[:foreign_key], :counter_cache => configuration[:counter_cache], :conditions => configuration[:conditions]
    has_many :children, :class_name => name, :foreign_key => configuration[:foreign_key], :order => configuration[:order], :dependent => :destroy, :conditions => configuration[:conditions]

    class_eval <<-EOV
      include ActiveRecord::Acts::Tree::InstanceMethods

      def self.roots
        find(:all, :conditions => "#{configuration[:foreign_key]} IS NULL", :order => #{configuration[:order].nil? ? "nil" : %Q{"#{configuration[:order]}"}})
      end

      def self.root
        find(:first, :conditions => "#{configuration[:foreign_key]} IS NULL", :order => #{configuration[:order].nil? ? "nil" : %Q{"#{configuration[:order]}"}})
      end
    EOV
  end
end