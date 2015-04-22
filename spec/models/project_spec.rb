require 'spec_helper'

describe Project do
  subject { build(:project) }

  it { should have_many :memberships }
  it { should be_valid }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).case_insensitive }

  describe "pm" do
    let(:actual_membership) { build(:membership, starts_at: 1.week.ago, ends_at: 1.week.from_now) }
    let(:old_membership) { build(:membership, starts_at: 2.weeks.ago, ends_at: 1.week.ago) }
    let(:future_membership) { build(:membership, starts_at: 1.week.from_now, ends_at: 2.weeks.from_now) }

    before do
      allow(Membership).to receive(:with_role).and_return([actual_membership, old_membership, future_membership])
    end

    its(:pm) { should eq(actual_membership.user) }
    its(:pm) { should_not eq(old_membership.user) }
    its(:pm) { should_not eq(future_membership.user) }
  end

  describe "#set_initials" do
    let(:project_camel_case) { create(:project, name: 'BolshoeSpasibo') }
    let(:project) { create(:project, name: 'Blyuz') }
    let(:project_multiword) { create(:project, name: 'BolshoeSpasiboHarosho') }

    context "camel case name" do
      it "sets initials of a project" do
        expect(project_camel_case.initials).to eq 'BS'
      end
    end

    context "1 word name" do
      it "sets initials of a project" do
        expect(project.initials).to eq 'B'
      end
    end

    context "multiword name with spaces" do
      it "sets initials of a project" do
        expect(project_multiword.initials).to eq 'BS'
      end
    end
  end

  describe "#set_colour" do
    let(:project) { create(:project) }
    it "sets random colour in hex format" do
      expect(project.colour).to match(/#[a-f0-9]{6}/)
    end
  end
end
