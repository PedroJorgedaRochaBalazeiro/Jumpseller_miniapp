# app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  self.abstract_class = true
end