require "rails_helper"

describe "Budget Groups" do
  let(:budget) { create(:budget, slug: "budget_slug") }
  let!(:group) { create(:budget_group, slug: "group_slug", budget: budget) }

  context "Load" do
    scenario "finds group using budget slug and group slug" do
      visit budget_group_path("budget_slug", "group_slug")
      expect(page).to have_content "Select an option"
    end

    scenario "finds group using budget id and group id" do
      visit budget_group_path(budget, group)
      expect(page).to have_content "Select an option"
    end

    scenario "raises an error if budget slug is not found" do
      expect do
        visit budget_group_path("wrong_budget", group)
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if budget id is not found" do
      expect do
        visit budget_group_path(0, group)
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if group slug is not found" do
      expect do
        visit budget_group_path(budget, "wrong_group")
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if group id is not found" do
      expect do
        visit budget_group_path(budget, 0)
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context "Show" do
    scenario "Headings are sorted by name" do
      last_heading = create(:budget_heading, group: group, name: "BBB")
      first_heading = create(:budget_heading, group: group, name: "AAA")

      visit budget_group_path(budget, group)

      expect(first_heading.name).to appear_before(last_heading.name)
    end

    scenario "Links to investment filters", :js do
      create(:budget_heading, group: group, name: "Southwest")
      budget.update!(phase: "finished")

      visit budget_group_path(budget, group)

      click_link "See unfeasible investments"

      expect(page).to have_css "h3", exact_text: "Unfeasible investments"
      expect(page).to have_link "Southwest"
      expect(page).not_to have_link "See unfeasible investments"

      click_link "See investments not selected for balloting phase"

      expect(page).to have_css "h3", exact_text: "Investments not selected for balloting phase"
      expect(page).to have_link "Southwest"
      expect(page).not_to have_link "See investments not selected for balloting phase unfeasible investments"
    end
  end
end
