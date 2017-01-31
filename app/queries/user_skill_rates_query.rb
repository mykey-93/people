class UserSkillRatesQuery
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def results_by_categories
    user_skill_rates.group_by do |skill|
      skill.category
    end.sort_by{ |key, _| key }.to_h
  end

  def results_for_category(category)
    user_skill_rates.where(skill_categories: {name: category})
  end

  private

  def user_skill_rates
    UserSkillRate.joins(
      skill: :skill_category
    ).select(
      select_fields
    ).where(user_id: user.id).order('skills.name')
  end

  def select_fields
    "
      user_skill_rates.*,
      skills.name as name,
      skills.description as description,
      skills.rate_type as rate_type,
      skill_categories.name as category
    "
  end
end
