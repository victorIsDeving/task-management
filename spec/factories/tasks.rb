FactoryBot.define do
  factory :task do
    title { "MyString" }
    descriprion { "MyText" }
    project { nil }
    assignee { nil }
    priority { "MyString" }
    status { "MyString" }
    due_date { "2025-08-02 16:48:23" }
  end
end
