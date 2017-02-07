module Skills
  class ChangeRequester
    attr_reader :skill, :params, :user, :draft_skill, :type

    def initialize(skill:, params:, user:)
      @skill = skill
      @params = params
      @user = user
    end

    def request(type:)
      @type = type
      validate_type
      request_change
    end

    def draft_skill
      draft_skill_creator.draft_skill
    end

    private

    def request_change
      skill.assign_attributes(params)
      if skill_and_draft_skill_valid?
        draft_skill_creator.save!
      else
        collect_and_set_errors
        false
      end
    end

    def skill_and_draft_skill_valid?
      skill.skip_ref_name_validation = true
      skill_validity = skill.valid?
      draft_skill_validity = draft_skill_creator.valid?
      if skill_validity && draft_skill_validity
        skill.set_ref_name!
        skill.skip_ref_name_validation = false
        skill.valid?
      else
        false
      end
    end

    def draft_skill_creator
      @draft_skill_creator ||= ::DraftSkills::Create.new(
        params: params,
        type: type,
        user: user,
        skill: skill
      )
    end

    def collect_and_set_errors
      explanation_error = draft_skill_creator.errors[:requester_explanation]
      if explanation_error.present?
        skill.errors[:requester_explanation] << explanation_error.first
      end
    end

    def validate_type
      unless DraftSkill::TYPES.include? type
        raise "You can select only two types of request: #{DraftSkill::TYPES}"
      end
    end
  end
end
