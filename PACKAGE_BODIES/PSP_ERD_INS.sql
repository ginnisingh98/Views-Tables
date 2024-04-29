--------------------------------------------------------
--  DDL for Package Body PSP_ERD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ERD_INS" as
/* $Header: PSPEDRHB.pls 120.2 2006/01/25 01:49 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_erd_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_effort_report_detail_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_effort_report_detail_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  psp_erd_ins.g_effort_report_detail_id_i := p_effort_report_detail_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec in out nocopy psp_erd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: psp_eff_report_details
  --
  insert into psp_eff_report_details
      (effort_report_detail_id
      ,effort_report_id
      ,object_version_number
      ,assignment_id
      ,assignment_number
      ,gl_sum_criteria_segment_name
      ,gl_segment1
      ,gl_segment2
      ,gl_segment3
      ,gl_segment4
      ,gl_segment5
      ,gl_segment6
      ,gl_segment7
      ,gl_segment8
      ,gl_segment9
      ,gl_segment10
      ,gl_segment11
      ,gl_segment12
      ,gl_segment13
      ,gl_segment14
      ,gl_segment15
      ,gl_segment16
      ,gl_segment17
      ,gl_segment18
      ,gl_segment19
      ,gl_segment20
      ,gl_segment21
      ,gl_segment22
      ,gl_segment23
      ,gl_segment24
      ,gl_segment25
      ,gl_segment26
      ,gl_segment27
      ,gl_segment28
      ,gl_segment29
      ,gl_segment30
      ,project_id
      ,project_number
      ,project_name
      ,expenditure_organization_id
      ,exp_org_name
      ,expenditure_type
      ,task_id
      ,task_number
      ,task_name
      ,award_id
      ,award_number
      ,award_short_name
      ,actual_salary_amt
      ,payroll_percent
      ,proposed_salary_amt
      ,proposed_effort_percent
      ,committed_cost_share
      ,schedule_start_date
      ,schedule_end_date
      ,ame_transaction_id
      ,investigator_name
      ,investigator_person_id
      ,investigator_org_name
      ,investigator_primary_org_id
      ,value1
      ,value2
      ,value3
      ,value4
      ,value5
      ,value6
      ,value7
      ,value8
      ,value9
      ,value10
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,grouping_category
      )
  Values
    (p_rec.effort_report_detail_id
    ,p_rec.effort_report_id
    ,p_rec.object_version_number
    ,p_rec.assignment_id
    ,p_rec.assignment_number
    ,p_rec.gl_sum_criteria_segment_name
    ,p_rec.gl_segment1
    ,p_rec.gl_segment2
    ,p_rec.gl_segment3
    ,p_rec.gl_segment4
    ,p_rec.gl_segment5
    ,p_rec.gl_segment6
    ,p_rec.gl_segment7
    ,p_rec.gl_segment8
    ,p_rec.gl_segment9
    ,p_rec.gl_segment10
    ,p_rec.gl_segment11
    ,p_rec.gl_segment12
    ,p_rec.gl_segment13
    ,p_rec.gl_segment14
    ,p_rec.gl_segment15
    ,p_rec.gl_segment16
    ,p_rec.gl_segment17
    ,p_rec.gl_segment18
    ,p_rec.gl_segment19
    ,p_rec.gl_segment20
    ,p_rec.gl_segment21
    ,p_rec.gl_segment22
    ,p_rec.gl_segment23
    ,p_rec.gl_segment24
    ,p_rec.gl_segment25
    ,p_rec.gl_segment26
    ,p_rec.gl_segment27
    ,p_rec.gl_segment28
    ,p_rec.gl_segment29
    ,p_rec.gl_segment30
    ,p_rec.project_id
    ,p_rec.project_number
    ,p_rec.project_name
    ,p_rec.expenditure_organization_id
    ,p_rec.exp_org_name
    ,p_rec.expenditure_type
    ,p_rec.task_id
    ,p_rec.task_number
    ,p_rec.task_name
    ,p_rec.award_id
    ,p_rec.award_number
    ,p_rec.award_short_name
    ,p_rec.actual_salary_amt
    ,p_rec.payroll_percent
    ,p_rec.proposed_salary_amt
    ,p_rec.proposed_effort_percent
    ,p_rec.committed_cost_share
    ,p_rec.schedule_start_date
    ,p_rec.schedule_end_date
    ,p_rec.ame_transaction_id
    ,p_rec.investigator_name
    ,p_rec.investigator_person_id
    ,p_rec.investigator_org_name
    ,p_rec.investigator_primary_org_id
    ,p_rec.value1
    ,p_rec.value2
    ,p_rec.value3
    ,p_rec.value4
    ,p_rec.value5
    ,p_rec.value6
    ,p_rec.value7
    ,p_rec.value8
    ,p_rec.value9
    ,p_rec.value10
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.grouping_category
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    psp_erd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    psp_erd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    psp_erd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec  in out nocopy psp_erd_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select psp_eff_report_details_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from psp_eff_report_details
     where effort_report_detail_id =
             psp_erd_ins.g_effort_report_detail_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (psp_erd_ins.g_effort_report_detail_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','psp_eff_report_details');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.effort_report_detail_id :=
      psp_erd_ins.g_effort_report_detail_id_i;
    psp_erd_ins.g_effort_report_detail_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.effort_report_detail_id;
    Close C_Sel1;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_rec                          in psp_erd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    psp_erd_rki.after_insert
      (p_effort_report_detail_id
      => p_rec.effort_report_detail_id
      ,p_effort_report_id
      => p_rec.effort_report_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_assignment_number
      => p_rec.assignment_number
      ,p_gl_sum_criteria_segment_name
      => p_rec.gl_sum_criteria_segment_name
      ,p_gl_segment1
      => p_rec.gl_segment1
      ,p_gl_segment2
      => p_rec.gl_segment2
      ,p_gl_segment3
      => p_rec.gl_segment3
      ,p_gl_segment4
      => p_rec.gl_segment4
      ,p_gl_segment5
      => p_rec.gl_segment5
      ,p_gl_segment6
      => p_rec.gl_segment6
      ,p_gl_segment7
      => p_rec.gl_segment7
      ,p_gl_segment8
      => p_rec.gl_segment8
      ,p_gl_segment9
      => p_rec.gl_segment9
      ,p_gl_segment10
      => p_rec.gl_segment10
      ,p_gl_segment11
      => p_rec.gl_segment11
      ,p_gl_segment12
      => p_rec.gl_segment12
      ,p_gl_segment13
      => p_rec.gl_segment13
      ,p_gl_segment14
      => p_rec.gl_segment14
      ,p_gl_segment15
      => p_rec.gl_segment15
      ,p_gl_segment16
      => p_rec.gl_segment16
      ,p_gl_segment17
      => p_rec.gl_segment17
      ,p_gl_segment18
      => p_rec.gl_segment18
      ,p_gl_segment19
      => p_rec.gl_segment19
      ,p_gl_segment20
      => p_rec.gl_segment20
      ,p_gl_segment21
      => p_rec.gl_segment21
      ,p_gl_segment22
      => p_rec.gl_segment22
      ,p_gl_segment23
      => p_rec.gl_segment23
      ,p_gl_segment24
      => p_rec.gl_segment24
      ,p_gl_segment25
      => p_rec.gl_segment25
      ,p_gl_segment26
      => p_rec.gl_segment26
      ,p_gl_segment27
      => p_rec.gl_segment27
      ,p_gl_segment28
      => p_rec.gl_segment28
      ,p_gl_segment29
      => p_rec.gl_segment29
      ,p_gl_segment30
      => p_rec.gl_segment30
      ,p_project_id
      => p_rec.project_id
      ,p_project_number
      => p_rec.project_number
      ,p_project_name
      => p_rec.project_name
      ,p_expenditure_organization_id
      => p_rec.expenditure_organization_id
      ,p_exp_org_name
      => p_rec.exp_org_name
      ,p_expenditure_type
      => p_rec.expenditure_type
      ,p_task_id
      => p_rec.task_id
      ,p_task_number
      => p_rec.task_number
      ,p_task_name
      => p_rec.task_name
      ,p_award_id
      => p_rec.award_id
      ,p_award_number
      => p_rec.award_number
      ,p_award_short_name
      => p_rec.award_short_name
      ,p_actual_salary_amt
      => p_rec.actual_salary_amt
      ,p_payroll_percent
      => p_rec.payroll_percent
      ,p_proposed_salary_amt
      => p_rec.proposed_salary_amt
      ,p_proposed_effort_percent
      => p_rec.proposed_effort_percent
      ,p_committed_cost_share
      => p_rec.committed_cost_share
      ,p_schedule_start_date
      => p_rec.schedule_start_date
      ,p_schedule_end_date
      => p_rec.schedule_end_date
      ,p_ame_transaction_id
      => p_rec.ame_transaction_id
      ,p_investigator_name
      => p_rec.investigator_name
      ,p_investigator_person_id
      => p_rec.investigator_person_id
      ,p_investigator_org_name
      => p_rec.investigator_org_name
      ,p_investigator_primary_org_id
      => p_rec.investigator_primary_org_id
      ,p_value1
      => p_rec.value1
      ,p_value2
      => p_rec.value2
      ,p_value3
      => p_rec.value3
      ,p_value4
      => p_rec.value4
      ,p_value5
      => p_rec.value5
      ,p_value6
      => p_rec.value6
      ,p_value7
      => p_rec.value7
      ,p_value8
      => p_rec.value8
      ,p_value9
      => p_rec.value9
      ,p_value10
      => p_rec.value10
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_grouping_category
      => p_rec.grouping_category
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PSP_EFF_REPORT_DETAILS'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec                          in out nocopy psp_erd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  psp_erd_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  psp_erd_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  psp_erd_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  psp_erd_ins.post_insert
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effort_report_id               in     number
  ,p_actual_salary_amt              in     number
  ,p_payroll_percent                in     number
  ,p_assignment_id                  in     number   default null
  ,p_assignment_number              in     varchar2 default null
  ,p_gl_sum_criteria_segment_name   in     varchar2 default null
  ,p_gl_segment1                    in     varchar2 default null
  ,p_gl_segment2                    in     varchar2 default null
  ,p_gl_segment3                    in     varchar2 default null
  ,p_gl_segment4                    in     varchar2 default null
  ,p_gl_segment5                    in     varchar2 default null
  ,p_gl_segment6                    in     varchar2 default null
  ,p_gl_segment7                    in     varchar2 default null
  ,p_gl_segment8                    in     varchar2 default null
  ,p_gl_segment9                    in     varchar2 default null
  ,p_gl_segment10                   in     varchar2 default null
  ,p_gl_segment11                   in     varchar2 default null
  ,p_gl_segment12                   in     varchar2 default null
  ,p_gl_segment13                   in     varchar2 default null
  ,p_gl_segment14                   in     varchar2 default null
  ,p_gl_segment15                   in     varchar2 default null
  ,p_gl_segment16                   in     varchar2 default null
  ,p_gl_segment17                   in     varchar2 default null
  ,p_gl_segment18                   in     varchar2 default null
  ,p_gl_segment19                   in     varchar2 default null
  ,p_gl_segment20                   in     varchar2 default null
  ,p_gl_segment21                   in     varchar2 default null
  ,p_gl_segment22                   in     varchar2 default null
  ,p_gl_segment23                   in     varchar2 default null
  ,p_gl_segment24                   in     varchar2 default null
  ,p_gl_segment25                   in     varchar2 default null
  ,p_gl_segment26                   in     varchar2 default null
  ,p_gl_segment27                   in     varchar2 default null
  ,p_gl_segment28                   in     varchar2 default null
  ,p_gl_segment29                   in     varchar2 default null
  ,p_gl_segment30                   in     varchar2 default null
  ,p_project_id                     in     number   default null
  ,p_project_number                 in     varchar2 default null
  ,p_project_name                   in     varchar2 default null
  ,p_expenditure_organization_id    in     number   default null
  ,p_exp_org_name                   in     varchar2 default null
  ,p_expenditure_type               in     varchar2 default null
  ,p_task_id                        in     number   default null
  ,p_task_number                    in     varchar2 default null
  ,p_task_name                      in     varchar2 default null
  ,p_award_id                       in     number   default null
  ,p_award_number                   in     varchar2 default null
  ,p_award_short_name               in     varchar2 default null
  ,p_proposed_salary_amt            in     number   default null
  ,p_proposed_effort_percent        in     number   default null
  ,p_committed_cost_share           in     number   default null
  ,p_schedule_start_date            in     date     default null
  ,p_schedule_end_date              in     date     default null
  ,p_ame_transaction_id             in     varchar2 default null
  ,p_investigator_name              in     varchar2 default null
  ,p_investigator_person_id         in     number   default null
  ,p_investigator_org_name          in     varchar2 default null
  ,p_investigator_primary_org_id    in     number   default null
  ,p_value1                         in     number   default null
  ,p_value2                         in     number   default null
  ,p_value3                         in     number   default null
  ,p_value4                         in     number   default null
  ,p_value5                         in     number   default null
  ,p_value6                         in     number   default null
  ,p_value7                         in     number   default null
  ,p_value8                         in     number   default null
  ,p_value9                         in     number   default null
  ,p_value10                        in     number   default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_grouping_category              in     varchar2 default null
  ,p_effort_report_detail_id           out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   psp_erd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  psp_erd_shd.convert_args
    (null
    ,p_effort_report_id
    ,null
    ,p_assignment_id
    ,p_assignment_number
    ,p_gl_sum_criteria_segment_name
    ,p_gl_segment1
    ,p_gl_segment2
    ,p_gl_segment3
    ,p_gl_segment4
    ,p_gl_segment5
    ,p_gl_segment6
    ,p_gl_segment7
    ,p_gl_segment8
    ,p_gl_segment9
    ,p_gl_segment10
    ,p_gl_segment11
    ,p_gl_segment12
    ,p_gl_segment13
    ,p_gl_segment14
    ,p_gl_segment15
    ,p_gl_segment16
    ,p_gl_segment17
    ,p_gl_segment18
    ,p_gl_segment19
    ,p_gl_segment20
    ,p_gl_segment21
    ,p_gl_segment22
    ,p_gl_segment23
    ,p_gl_segment24
    ,p_gl_segment25
    ,p_gl_segment26
    ,p_gl_segment27
    ,p_gl_segment28
    ,p_gl_segment29
    ,p_gl_segment30
    ,p_project_id
    ,p_project_number
    ,p_project_name
    ,p_expenditure_organization_id
    ,p_exp_org_name
    ,p_expenditure_type
    ,p_task_id
    ,p_task_number
    ,p_task_name
    ,p_award_id
    ,p_award_number
    ,p_award_short_name
    ,p_actual_salary_amt
    ,p_payroll_percent
    ,p_proposed_salary_amt
    ,p_proposed_effort_percent
    ,p_committed_cost_share
    ,p_schedule_start_date
    ,p_schedule_end_date
    ,p_ame_transaction_id
    ,p_investigator_name
    ,p_investigator_person_id
    ,p_investigator_org_name
    ,p_investigator_primary_org_id
    ,p_value1
    ,p_value2
    ,p_value3
    ,p_value4
    ,p_value5
    ,p_value6
    ,p_value7
    ,p_value8
    ,p_value9
    ,p_value10
    ,p_attribute1
    ,p_attribute2
    ,p_attribute3
    ,p_attribute4
    ,p_attribute5
    ,p_attribute6
    ,p_attribute7
    ,p_attribute8
    ,p_attribute9
    ,p_attribute10
    ,p_grouping_category
    );
  --
  -- Having converted the arguments into the psp_erd_rec
  -- plsql record structure we call the corresponding record business process.
  --
  psp_erd_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_effort_report_detail_id := l_rec.effort_report_detail_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end psp_erd_ins;

/
