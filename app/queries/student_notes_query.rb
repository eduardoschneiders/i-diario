class StudentNotesQuery
  def initialize(student, discipline, classroom, start_at, end_at)
    @student = student
    @discipline = discipline
    @classroom = classroom
    @start_at = start_at.to_date
    @end_at = end_at.to_date
  end

  def daily_note_students
    DailyNoteStudent.by_student_id(student)
                    .by_discipline_id(discipline)
                    .by_classroom_id(classroom)
                    .by_test_date_between(start_at, end_at)
  end

  def recovery_diary_records
    RecoveryDiaryRecord.by_student_id(student)
                       .by_discipline_id(discipline)
                       .by_classroom_id(classroom)
                       .joins(:avaliation_recovery_diary_record)
                       .merge(AvaliationRecoveryDiaryRecord.by_test_date_between(start_at, end_at))
                       .where.not(daily_note_students.exists)
  end

  private

  attr_accessor :student, :discipline, :classroom, :start_at, :end_at
end
