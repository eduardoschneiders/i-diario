class StandardizeLessonPlansContents < ActiveRecord::Migration
  def change
    rename_column :lesson_plans, :contents, :old_contents
    LessonPlan.all.each do |lesson_plan|
      lesson_plan.contents = lesson_plan.old_contents.split(/\s*[,;]\s* | [\r\n]+ /x).reject(&:empty?).map{|v| Content.find_or_create_by!(description: v)}
      lesson_plan.save!
    end
  end
end
