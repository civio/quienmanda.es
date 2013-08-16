class Entity < ActiveRecord::Base
  extend Enumerize
  enumerize :priority, in: {:high => 1, :medium => 2, :low => 3}

  mount_uploader :avatar, AvatarUploader

  has_many :entity_photo_associations, dependent: :delete_all
  has_many :related_photos, through: :entity_photo_associations, source: :photo

  has_many :relations_as_source, foreign_key: :source_id, class_name: Relation, inverse_of: :source
  has_many :relations_as_target, foreign_key: :target_id, class_name: Relation, inverse_of: :target

  acts_as_url :short_or_long_name, url_attribute: :slug, only_when_blank: true, sync_url:  true
  def to_param
    slug
  end

  validates :name, presence: true, uniqueness: true
  validates :priority, presence: true
  validates :description, length: { maximum: 90 }

  scope :published, -> { where(published: true) }
  scope :people, -> { where(person: true) }
  scope :organizations, -> { where(person: false) }

  # Returns the short name if present, the long one otherwise
  def short_or_long_name
    (short_name.nil? || short_name.blank?) ? name : short_name
  end

  # Returns all the relations an entity is involved in.
  #   This is cleaner than prefetching relations_as_source, adding to relations_as_source...
  def relations
    Relation.where('source_id = ? or target_id = ?', self, self)
  end
end
