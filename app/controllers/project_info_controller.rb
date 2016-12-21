class ProjectInfoController < ApplicationController
  expose(:project_infos) { list_all_projects }
  expose(:project_info) { show_project_info project_params }

  def show; end

  def index; end

  private

  def list_all_projects
    Apiguru::ListProjects.new.call
  end

  def show_project_info(name)
    Apiguru::ShowProjectInfo.new(name).call
  end

  def project_params
    params.permit(:name)
  end
end
