class DraftSkillsController < ApplicationController
  skip_before_filter :authenticate_admin!
  before_filter :authenticate_for_skills!
  expose(:draft_skill) { fetch_draft_skill }
  expose(:grouped_draft_skills_by_status) { grouped_draft_skills_by_status }
  expose(:skill) { draft_skill.skill }
  expose(:skill_categories) { SkillCategory.all }

  def show; end

  def edit; end

  def update
    # TODO add validation in draft_skill model to not allow requester to accept r cancel(?) request
    # TODO: we have to change a way of passing draft_status, when there is an error template reload and status is displayed incorrectly
    respond_to do |format|
      if DraftSkills::Update.new(draft_skill, draft_skill_params).call
        format.html { redirect_to draft_skill, notice: 'Request was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: draft_skill.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def draft_skill_params
    @draft_skill_params ||= begin
      params.require(:draft_skill).permit(:reviewer_explanation, :draft_status).merge(
        'reviewer_id' => current_user.id
      )
    end
  end

  def fetch_draft_skill
    DraftSkillDecorator.new(DraftSkill.find(params[:id]))
  end

  def grouped_draft_skills_by_status
    DraftSkillDecorator.decorate_collection(
      DraftSkill.since_last_30_days
    ).group_by(&:draft_status)
  end
end
