--------------------------------------------------------
--  DDL for Package Body PSP_ERD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ERD_UPD" as
/* $Header: PSPEDRHB.pls 120.2 2006/01/25 01:49 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_erd_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy psp_erd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the psp_eff_report_details Row
  --
  update psp_eff_report_details
    set
     effort_report_detail_id         = p_rec.effort_report_detail_id
    ,effort_report_id                = p_rec.effort_report_id
    ,object_version_number           = p_rec.object_version_number
    ,assignment_id                   = p_rec.assignment_id
    ,assignment_number               = p_rec.assignment_number
    ,gl_sum_criteria_segment_name    = p_rec.gl_sum_criteria_segment_name
    ,gl_segment1                     = p_rec.gl_segment1
    ,gl_segment2                     = p_rec.gl_segment2
    ,gl_segment3                     = p_rec.gl_segment3
    ,gl_segment4                     = p_rec.gl_segment4
    ,gl_segment5                     = p_rec.gl_segment5
    ,gl_segment6                     = p_rec.gl_segment6
    ,gl_segment7                     = p_rec.gl_segment7
    ,gl_segment8                     = p_rec.gl_segment8
    ,gl_segment9                     = p_rec.gl_segment9
    ,gl_segment10                    = p_rec.gl_segment10
    ,gl_segment11                    = p_rec.gl_segment11
    ,gl_segment12                    = p_rec.gl_segment12
    ,gl_segment13                    = p_rec.gl_segment13
    ,gl_segment14                    = p_rec.gl_segment14
    ,gl_segment15                    = p_rec.gl_segment15
    ,gl_segment16                    = p_rec.gl_segment16
    ,gl_segment17                    = p_rec.gl_segment17
    ,gl_segment18                    = p_rec.gl_segment18
    ,gl_segment19                    = p_rec.gl_segment19
    ,gl_segment20                    = p_rec.gl_segment20
    ,gl_segment21                    = p_rec.gl_segment21
    ,gl_segment22                    = p_rec.gl_segment22
    ,gl_segment23                    = p_rec.gl_segment23
    ,gl_segment24                    = p_rec.gl_segment24
    ,gl_segment25                    = p_rec.gl_segment25
    ,gl_segment26                    = p_rec.gl_segment26
    ,gl_segment27                    = p_rec.gl_segment27
    ,gl_segment28                    = p_rec.gl_segment28
    ,gl_segment29                    = p_rec.gl_segment29
    ,gl_segment30                    = p_rec.gl_segment30
    ,project_id                      = p_rec.project_id
    ,project_number                  = p_rec.project_number
    ,project_name                    = p_rec.project_name
    ,expenditure_organization_id     = p_rec.expenditure_organization_id
    ,exp_org_name                    = p_rec.exp_org_name
    ,expenditure_type                = p_rec.expenditure_type
    ,task_id                         = p_rec.task_id
    ,task_number                     = p_rec.task_number
    ,task_name                       = p_rec.task_name
    ,award_id                        = p_rec.award_id
    ,award_number                    = p_rec.award_number
    ,award_short_name                = p_rec.award_short_name
    ,actual_salary_amt               = p_rec.actual_salary_amt
    ,payroll_percent                 = p_rec.payroll_percent
    ,proposed_salary_amt             = p_rec.proposed_salary_amt
    ,proposed_effort_percent         = p_rec.proposed_effort_percent
    ,committed_cost_share            = p_rec.committed_cost_share
    ,schedule_start_date             = p_rec.schedule_start_date
    ,schedule_end_date               = p_rec.schedule_end_date
    ,ame_transaction_id              = p_rec.ame_transaction_id
    ,investigator_name               = p_rec.investigator_name
    ,investigator_person_id          = p_rec.investigator_person_id
    ,investigator_org_name           = p_rec.investigator_org_name
    ,investigator_primary_org_id     = p_rec.investigator_primary_org_id
    ,value1                          = p_rec.value1
    ,value2                          = p_rec.value2
    ,value3                          = p_rec.value3
    ,value4                          = p_rec.value4
    ,value5                          = p_rec.value5
    ,value6                          = p_rec.value6
    ,value7                          = p_rec.value7
    ,value8                          = p_rec.value8
    ,value9                          = p_rec.value9
    ,value10                         = p_rec.value10
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,grouping_category               = p_rec.grouping_category
    where effort_report_detail_id = p_rec.effort_report_detail_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
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
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in psp_erd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_rec                          in psp_erd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    psp_erd_rku.after_update
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
      ,p_effort_report_id_o
      => psp_erd_shd.g_old_rec.effort_report_id
      ,p_object_version_number_o
      => psp_erd_shd.g_old_rec.object_version_number
      ,p_assignment_id_o
      => psp_erd_shd.g_old_rec.assignment_id
      ,p_assignment_number_o
      => psp_erd_shd.g_old_rec.assignment_number
      ,p_gl_sum_criteria_segment_na_o
      => psp_erd_shd.g_old_rec.gl_sum_criteria_segment_name
      ,p_gl_segment1_o
      => psp_erd_shd.g_old_rec.gl_segment1
      ,p_gl_segment2_o
      => psp_erd_shd.g_old_rec.gl_segment2
      ,p_gl_segment3_o
      => psp_erd_shd.g_old_rec.gl_segment3
      ,p_gl_segment4_o
      => psp_erd_shd.g_old_rec.gl_segment4
      ,p_gl_segment5_o
      => psp_erd_shd.g_old_rec.gl_segment5
      ,p_gl_segment6_o
      => psp_erd_shd.g_old_rec.gl_segment6
      ,p_gl_segment7_o
      => psp_erd_shd.g_old_rec.gl_segment7
      ,p_gl_segment8_o
      => psp_erd_shd.g_old_rec.gl_segment8
      ,p_gl_segment9_o
      => psp_erd_shd.g_old_rec.gl_segment9
      ,p_gl_segment10_o
      => psp_erd_shd.g_old_rec.gl_segment10
      ,p_gl_segment11_o
      => psp_erd_shd.g_old_rec.gl_segment11
      ,p_gl_segment12_o
      => psp_erd_shd.g_old_rec.gl_segment12
      ,p_gl_segment13_o
      => psp_erd_shd.g_old_rec.gl_segment13
      ,p_gl_segment14_o
      => psp_erd_shd.g_old_rec.gl_segment14
      ,p_gl_segment15_o
      => psp_erd_shd.g_old_rec.gl_segment15
      ,p_gl_segment16_o
      => psp_erd_shd.g_old_rec.gl_segment16
      ,p_gl_segment17_o
      => psp_erd_shd.g_old_rec.gl_segment17
      ,p_gl_segment18_o
      => psp_erd_shd.g_old_rec.gl_segment18
      ,p_gl_segment19_o
      => psp_erd_shd.g_old_rec.gl_segment19
      ,p_gl_segment20_o
      => psp_erd_shd.g_old_rec.gl_segment20
      ,p_gl_segment21_o
      => psp_erd_shd.g_old_rec.gl_segment21
      ,p_gl_segment22_o
      => psp_erd_shd.g_old_rec.gl_segment22
      ,p_gl_segment23_o
      => psp_erd_shd.g_old_rec.gl_segment23
      ,p_gl_segment24_o
      => psp_erd_shd.g_old_rec.gl_segment24
      ,p_gl_segment25_o
      => psp_erd_shd.g_old_rec.gl_segment25
      ,p_gl_segment26_o
      => psp_erd_shd.g_old_rec.gl_segment26
      ,p_gl_segment27_o
      => psp_erd_shd.g_old_rec.gl_segment27
      ,p_gl_segment28_o
      => psp_erd_shd.g_old_rec.gl_segment28
      ,p_gl_segment29_o
      => psp_erd_shd.g_old_rec.gl_segment29
      ,p_gl_segment30_o
      => psp_erd_shd.g_old_rec.gl_segment30
      ,p_project_id_o
      => psp_erd_shd.g_old_rec.project_id
      ,p_project_number_o
      => psp_erd_shd.g_old_rec.project_number
      ,p_project_name_o
      => psp_erd_shd.g_old_rec.project_name
      ,p_expenditure_organization_i_o
      => psp_erd_shd.g_old_rec.expenditure_organization_id
      ,p_exp_org_name_o
      => psp_erd_shd.g_old_rec.exp_org_name
      ,p_expenditure_type_o
      => psp_erd_shd.g_old_rec.expenditure_type
      ,p_task_id_o
      => psp_erd_shd.g_old_rec.task_id
      ,p_task_number_o
      => psp_erd_shd.g_old_rec.task_number
      ,p_task_name_o
      => psp_erd_shd.g_old_rec.task_name
      ,p_award_id_o
      => psp_erd_shd.g_old_rec.award_id
      ,p_award_number_o
      => psp_erd_shd.g_old_rec.award_number
      ,p_award_short_name_o
      => psp_erd_shd.g_old_rec.award_short_name
      ,p_actual_salary_amt_o
      => psp_erd_shd.g_old_rec.actual_salary_amt
      ,p_payroll_percent_o
      => psp_erd_shd.g_old_rec.payroll_percent
      ,p_proposed_salary_amt_o
      => psp_erd_shd.g_old_rec.proposed_salary_amt
      ,p_proposed_effort_percent_o
      => psp_erd_shd.g_old_rec.proposed_effort_percent
      ,p_committed_cost_share_o
      => psp_erd_shd.g_old_rec.committed_cost_share
      ,p_schedule_start_date_o
      => psp_erd_shd.g_old_rec.schedule_start_date
      ,p_schedule_end_date_o
      => psp_erd_shd.g_old_rec.schedule_end_date
      ,p_ame_transaction_id_o
      => psp_erd_shd.g_old_rec.ame_transaction_id
      ,p_investigator_name_o
      => psp_erd_shd.g_old_rec.investigator_name
      ,p_investigator_person_id_o
      => psp_erd_shd.g_old_rec.investigator_person_id
      ,p_investigator_org_name_o
      => psp_erd_shd.g_old_rec.investigator_org_name
      ,p_investigator_primary_org_i_o
      => psp_erd_shd.g_old_rec.investigator_primary_org_id
      ,p_value1_o
      => psp_erd_shd.g_old_rec.value1
      ,p_value2_o
      => psp_erd_shd.g_old_rec.value2
      ,p_value3_o
      => psp_erd_shd.g_old_rec.value3
      ,p_value4_o
      => psp_erd_shd.g_old_rec.value4
      ,p_value5_o
      => psp_erd_shd.g_old_rec.value5
      ,p_value6_o
      => psp_erd_shd.g_old_rec.value6
      ,p_value7_o
      => psp_erd_shd.g_old_rec.value7
      ,p_value8_o
      => psp_erd_shd.g_old_rec.value8
      ,p_value9_o
      => psp_erd_shd.g_old_rec.value9
      ,p_value10_o
      => psp_erd_shd.g_old_rec.value10
      ,p_attribute1_o
      => psp_erd_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => psp_erd_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => psp_erd_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => psp_erd_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => psp_erd_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => psp_erd_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => psp_erd_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => psp_erd_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => psp_erd_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => psp_erd_shd.g_old_rec.attribute10
      ,p_grouping_category_o
      => psp_erd_shd.g_old_rec.grouping_category
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PSP_EFF_REPORT_DETAILS'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy psp_erd_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.effort_report_id = hr_api.g_number) then
    p_rec.effort_report_id :=
    psp_erd_shd.g_old_rec.effort_report_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    psp_erd_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.assignment_number = hr_api.g_varchar2) then
    p_rec.assignment_number :=
    psp_erd_shd.g_old_rec.assignment_number;
  End If;
  If (p_rec.gl_sum_criteria_segment_name = hr_api.g_varchar2) then
    p_rec.gl_sum_criteria_segment_name :=
    psp_erd_shd.g_old_rec.gl_sum_criteria_segment_name;
  End If;
  If (p_rec.gl_segment1 = hr_api.g_varchar2) then
    p_rec.gl_segment1 :=
    psp_erd_shd.g_old_rec.gl_segment1;
  End If;
  If (p_rec.gl_segment2 = hr_api.g_varchar2) then
    p_rec.gl_segment2 :=
    psp_erd_shd.g_old_rec.gl_segment2;
  End If;
  If (p_rec.gl_segment3 = hr_api.g_varchar2) then
    p_rec.gl_segment3 :=
    psp_erd_shd.g_old_rec.gl_segment3;
  End If;
  If (p_rec.gl_segment4 = hr_api.g_varchar2) then
    p_rec.gl_segment4 :=
    psp_erd_shd.g_old_rec.gl_segment4;
  End If;
  If (p_rec.gl_segment5 = hr_api.g_varchar2) then
    p_rec.gl_segment5 :=
    psp_erd_shd.g_old_rec.gl_segment5;
  End If;
  If (p_rec.gl_segment6 = hr_api.g_varchar2) then
    p_rec.gl_segment6 :=
    psp_erd_shd.g_old_rec.gl_segment6;
  End If;
  If (p_rec.gl_segment7 = hr_api.g_varchar2) then
    p_rec.gl_segment7 :=
    psp_erd_shd.g_old_rec.gl_segment7;
  End If;
  If (p_rec.gl_segment8 = hr_api.g_varchar2) then
    p_rec.gl_segment8 :=
    psp_erd_shd.g_old_rec.gl_segment8;
  End If;
  If (p_rec.gl_segment9 = hr_api.g_varchar2) then
    p_rec.gl_segment9 :=
    psp_erd_shd.g_old_rec.gl_segment9;
  End If;
  If (p_rec.gl_segment10 = hr_api.g_varchar2) then
    p_rec.gl_segment10 :=
    psp_erd_shd.g_old_rec.gl_segment10;
  End If;
  If (p_rec.gl_segment11 = hr_api.g_varchar2) then
    p_rec.gl_segment11 :=
    psp_erd_shd.g_old_rec.gl_segment11;
  End If;
  If (p_rec.gl_segment12 = hr_api.g_varchar2) then
    p_rec.gl_segment12 :=
    psp_erd_shd.g_old_rec.gl_segment12;
  End If;
  If (p_rec.gl_segment13 = hr_api.g_varchar2) then
    p_rec.gl_segment13 :=
    psp_erd_shd.g_old_rec.gl_segment13;
  End If;
  If (p_rec.gl_segment14 = hr_api.g_varchar2) then
    p_rec.gl_segment14 :=
    psp_erd_shd.g_old_rec.gl_segment14;
  End If;
  If (p_rec.gl_segment15 = hr_api.g_varchar2) then
    p_rec.gl_segment15 :=
    psp_erd_shd.g_old_rec.gl_segment15;
  End If;
  If (p_rec.gl_segment16 = hr_api.g_varchar2) then
    p_rec.gl_segment16 :=
    psp_erd_shd.g_old_rec.gl_segment16;
  End If;
  If (p_rec.gl_segment17 = hr_api.g_varchar2) then
    p_rec.gl_segment17 :=
    psp_erd_shd.g_old_rec.gl_segment17;
  End If;
  If (p_rec.gl_segment18 = hr_api.g_varchar2) then
    p_rec.gl_segment18 :=
    psp_erd_shd.g_old_rec.gl_segment18;
  End If;
  If (p_rec.gl_segment19 = hr_api.g_varchar2) then
    p_rec.gl_segment19 :=
    psp_erd_shd.g_old_rec.gl_segment19;
  End If;
  If (p_rec.gl_segment20 = hr_api.g_varchar2) then
    p_rec.gl_segment20 :=
    psp_erd_shd.g_old_rec.gl_segment20;
  End If;
  If (p_rec.gl_segment21 = hr_api.g_varchar2) then
    p_rec.gl_segment21 :=
    psp_erd_shd.g_old_rec.gl_segment21;
  End If;
  If (p_rec.gl_segment22 = hr_api.g_varchar2) then
    p_rec.gl_segment22 :=
    psp_erd_shd.g_old_rec.gl_segment22;
  End If;
  If (p_rec.gl_segment23 = hr_api.g_varchar2) then
    p_rec.gl_segment23 :=
    psp_erd_shd.g_old_rec.gl_segment23;
  End If;
  If (p_rec.gl_segment24 = hr_api.g_varchar2) then
    p_rec.gl_segment24 :=
    psp_erd_shd.g_old_rec.gl_segment24;
  End If;
  If (p_rec.gl_segment25 = hr_api.g_varchar2) then
    p_rec.gl_segment25 :=
    psp_erd_shd.g_old_rec.gl_segment25;
  End If;
  If (p_rec.gl_segment26 = hr_api.g_varchar2) then
    p_rec.gl_segment26 :=
    psp_erd_shd.g_old_rec.gl_segment26;
  End If;
  If (p_rec.gl_segment27 = hr_api.g_varchar2) then
    p_rec.gl_segment27 :=
    psp_erd_shd.g_old_rec.gl_segment27;
  End If;
  If (p_rec.gl_segment28 = hr_api.g_varchar2) then
    p_rec.gl_segment28 :=
    psp_erd_shd.g_old_rec.gl_segment28;
  End If;
  If (p_rec.gl_segment29 = hr_api.g_varchar2) then
    p_rec.gl_segment29 :=
    psp_erd_shd.g_old_rec.gl_segment29;
  End If;
  If (p_rec.gl_segment30 = hr_api.g_varchar2) then
    p_rec.gl_segment30 :=
    psp_erd_shd.g_old_rec.gl_segment30;
  End If;
  If (p_rec.project_id = hr_api.g_number) then
    p_rec.project_id :=
    psp_erd_shd.g_old_rec.project_id;
  End If;
  If (p_rec.project_number = hr_api.g_varchar2) then
    p_rec.project_number :=
    psp_erd_shd.g_old_rec.project_number;
  End If;
  If (p_rec.project_name = hr_api.g_varchar2) then
    p_rec.project_name :=
    psp_erd_shd.g_old_rec.project_name;
  End If;
  If (p_rec.expenditure_organization_id = hr_api.g_number) then
    p_rec.expenditure_organization_id :=
    psp_erd_shd.g_old_rec.expenditure_organization_id;
  End If;
  If (p_rec.exp_org_name = hr_api.g_varchar2) then
    p_rec.exp_org_name :=
    psp_erd_shd.g_old_rec.exp_org_name;
  End If;
  If (p_rec.expenditure_type = hr_api.g_varchar2) then
    p_rec.expenditure_type :=
    psp_erd_shd.g_old_rec.expenditure_type;
  End If;
  If (p_rec.task_id = hr_api.g_number) then
    p_rec.task_id :=
    psp_erd_shd.g_old_rec.task_id;
  End If;
  If (p_rec.task_number = hr_api.g_varchar2) then
    p_rec.task_number :=
    psp_erd_shd.g_old_rec.task_number;
  End If;
  If (p_rec.task_name = hr_api.g_varchar2) then
    p_rec.task_name :=
    psp_erd_shd.g_old_rec.task_name;
  End If;
  If (p_rec.award_id = hr_api.g_number) then
    p_rec.award_id :=
    psp_erd_shd.g_old_rec.award_id;
  End If;
  If (p_rec.award_number = hr_api.g_varchar2) then
    p_rec.award_number :=
    psp_erd_shd.g_old_rec.award_number;
  End If;
  If (p_rec.award_short_name = hr_api.g_varchar2) then
    p_rec.award_short_name :=
    psp_erd_shd.g_old_rec.award_short_name;
  End If;
  If (p_rec.actual_salary_amt = hr_api.g_number) then
    p_rec.actual_salary_amt :=
    psp_erd_shd.g_old_rec.actual_salary_amt;
  End If;
  If (p_rec.payroll_percent = hr_api.g_number) then
    p_rec.payroll_percent :=
    psp_erd_shd.g_old_rec.payroll_percent;
  End If;
  If (p_rec.proposed_salary_amt = hr_api.g_number) then
    p_rec.proposed_salary_amt :=
    psp_erd_shd.g_old_rec.proposed_salary_amt;
  End If;
  If (p_rec.proposed_effort_percent = hr_api.g_number) then
    p_rec.proposed_effort_percent :=
    psp_erd_shd.g_old_rec.proposed_effort_percent;
  End If;
  If (p_rec.committed_cost_share = hr_api.g_number) then
    p_rec.committed_cost_share :=
    psp_erd_shd.g_old_rec.committed_cost_share;
  End If;
  If (p_rec.schedule_start_date = hr_api.g_date) then
    p_rec.schedule_start_date :=
    psp_erd_shd.g_old_rec.schedule_start_date;
  End If;
  If (p_rec.schedule_end_date = hr_api.g_date) then
    p_rec.schedule_end_date :=
    psp_erd_shd.g_old_rec.schedule_end_date;
  End If;
  If (p_rec.ame_transaction_id = hr_api.g_varchar2) then
    p_rec.ame_transaction_id :=
    psp_erd_shd.g_old_rec.ame_transaction_id;
  End If;
  If (p_rec.investigator_name = hr_api.g_varchar2) then
    p_rec.investigator_name :=
    psp_erd_shd.g_old_rec.investigator_name;
  End If;
  If (p_rec.investigator_person_id = hr_api.g_number) then
    p_rec.investigator_person_id :=
    psp_erd_shd.g_old_rec.investigator_person_id;
  End If;
  If (p_rec.investigator_org_name = hr_api.g_varchar2) then
    p_rec.investigator_org_name :=
    psp_erd_shd.g_old_rec.investigator_org_name;
  End If;
  If (p_rec.investigator_primary_org_id = hr_api.g_number) then
    p_rec.investigator_primary_org_id :=
    psp_erd_shd.g_old_rec.investigator_primary_org_id;
  End If;
  If (p_rec.value1 = hr_api.g_number) then
    p_rec.value1 :=
    psp_erd_shd.g_old_rec.value1;
  End If;
  If (p_rec.value2 = hr_api.g_number) then
    p_rec.value2 :=
    psp_erd_shd.g_old_rec.value2;
  End If;
  If (p_rec.value3 = hr_api.g_number) then
    p_rec.value3 :=
    psp_erd_shd.g_old_rec.value3;
  End If;
  If (p_rec.value4 = hr_api.g_number) then
    p_rec.value4 :=
    psp_erd_shd.g_old_rec.value4;
  End If;
  If (p_rec.value5 = hr_api.g_number) then
    p_rec.value5 :=
    psp_erd_shd.g_old_rec.value5;
  End If;
  If (p_rec.value6 = hr_api.g_number) then
    p_rec.value6 :=
    psp_erd_shd.g_old_rec.value6;
  End If;
  If (p_rec.value7 = hr_api.g_number) then
    p_rec.value7 :=
    psp_erd_shd.g_old_rec.value7;
  End If;
  If (p_rec.value8 = hr_api.g_number) then
    p_rec.value8 :=
    psp_erd_shd.g_old_rec.value8;
  End If;
  If (p_rec.value9 = hr_api.g_number) then
    p_rec.value9 :=
    psp_erd_shd.g_old_rec.value9;
  End If;
  If (p_rec.value10 = hr_api.g_number) then
    p_rec.value10 :=
    psp_erd_shd.g_old_rec.value10;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    psp_erd_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    psp_erd_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    psp_erd_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    psp_erd_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    psp_erd_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    psp_erd_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    psp_erd_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    psp_erd_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    psp_erd_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    psp_erd_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.grouping_category = hr_api.g_varchar2) then
    p_rec.grouping_category :=
    psp_erd_shd.g_old_rec.grouping_category;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy psp_erd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  psp_erd_shd.lck
    (p_rec.effort_report_detail_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  psp_erd_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  psp_erd_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  psp_erd_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  psp_erd_upd.post_update
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effort_report_detail_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_effort_report_id             in     number    default hr_api.g_number
  ,p_actual_salary_amt            in     number    default hr_api.g_number
  ,p_payroll_percent              in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_assignment_number            in     varchar2  default hr_api.g_varchar2
  ,p_gl_sum_criteria_segment_name in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment1                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment2                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment3                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment4                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment5                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment6                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment7                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment8                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment9                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment10                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment11                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment12                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment13                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment14                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment15                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment16                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment17                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment18                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment19                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment20                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment21                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment22                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment23                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment24                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment25                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment26                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment27                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment28                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment29                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment30                 in     varchar2  default hr_api.g_varchar2
  ,p_project_id                   in     number    default hr_api.g_number
  ,p_project_number               in     varchar2  default hr_api.g_varchar2
  ,p_project_name                 in     varchar2  default hr_api.g_varchar2
  ,p_expenditure_organization_id  in     number    default hr_api.g_number
  ,p_exp_org_name                 in     varchar2  default hr_api.g_varchar2
  ,p_expenditure_type             in     varchar2  default hr_api.g_varchar2
  ,p_task_id                      in     number    default hr_api.g_number
  ,p_task_number                  in     varchar2  default hr_api.g_varchar2
  ,p_task_name                    in     varchar2  default hr_api.g_varchar2
  ,p_award_id                     in     number    default hr_api.g_number
  ,p_award_number                 in     varchar2  default hr_api.g_varchar2
  ,p_award_short_name             in     varchar2  default hr_api.g_varchar2
  ,p_proposed_salary_amt          in     number    default hr_api.g_number
  ,p_proposed_effort_percent      in     number    default hr_api.g_number
  ,p_committed_cost_share         in     number    default hr_api.g_number
  ,p_schedule_start_date          in     date      default hr_api.g_date
  ,p_schedule_end_date            in     date      default hr_api.g_date
  ,p_ame_transaction_id           in     varchar2  default hr_api.g_varchar2
  ,p_investigator_name            in     varchar2  default hr_api.g_varchar2
  ,p_investigator_person_id       in     number    default hr_api.g_number
  ,p_investigator_org_name        in     varchar2  default hr_api.g_varchar2
  ,p_investigator_primary_org_id  in     number    default hr_api.g_number
  ,p_value1                       in     number    default hr_api.g_number
  ,p_value2                       in     number    default hr_api.g_number
  ,p_value3                       in     number    default hr_api.g_number
  ,p_value4                       in     number    default hr_api.g_number
  ,p_value5                       in     number    default hr_api.g_number
  ,p_value6                       in     number    default hr_api.g_number
  ,p_value7                       in     number    default hr_api.g_number
  ,p_value8                       in     number    default hr_api.g_number
  ,p_value9                       in     number    default hr_api.g_number
  ,p_value10                      in     number    default hr_api.g_number
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_grouping_category            in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   psp_erd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  psp_erd_shd.convert_args
  (p_effort_report_detail_id
  ,p_effort_report_id
  ,p_object_version_number
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
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  psp_erd_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end psp_erd_upd;

/
