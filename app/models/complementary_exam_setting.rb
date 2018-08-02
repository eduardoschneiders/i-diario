class ComplementaryExamSetting < ActiveRecord::Base
  acts_as_copy_target

  audited
  has_associated_audits

  include Audit

  validates :description, presence: true
  validates :initials, presence: true
  validates :affected_score, presence: true
  validates :calculation_type, presence: true
  validates :grade_ids, presence: true
  validates :maximum_score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 1000 }
  validates :number_of_decimal_places, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3 }
  validate :uniqueness_of_calculation_type_by_grade


  scope :by_description, lambda { |description| where("unaccent(complementary_exam_settings.description) ILIKE unaccent('%#{description}%')") }
  scope :by_initials, lambda { |initials| where("unaccent(complementary_exam_settings.initials) ILIKE unaccent('%#{initials}%')") }
  scope :by_affected_score, lambda { |affected_score| where(affected_score: affected_score) }
  scope :by_calculation_type, lambda { |calculation_type| where(calculation_type: calculation_type) }
  scope :by_grade_id, lambda { |grade_id| where_exists(:grades, id: grade_id) }
  scope :ordered, -> { order(:description) }

  has_enumeration_for :affected_score, with: AffectedScoreTypes, create_helpers: true
  has_enumeration_for :calculation_type, with: CalculationTypes, create_helpers: true

  has_and_belongs_to_many :grades

  def to_s
    description
  end

  private

  def uniqueness_of_calculation_type_by_grade
    return true unless [CalculationTypes::SUBSTITUTION, CalculationTypes::SUBSTITUTION_IF_GREATER].include?(calculation_type)
    return true unless affected_score
    return true unless grades
    return true unless ComplementaryExamSetting.where.not(id: id)
                  .by_calculation_type([CalculationTypes::SUBSTITUTION, CalculationTypes::SUBSTITUTION_IF_GREATER])
                  .by_affected_score(affected_score)
                  .by_grade_id(grades.map(&:id))
                  .exists?

    errors.add(:base, :uniqueness_of_calculation_type_by_grade)
  end
end
