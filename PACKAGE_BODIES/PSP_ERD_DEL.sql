--------------------------------------------------------
--  DDL for Package Body PSP_ERD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ERD_DEL" as
/* $Header: PSPEDRHB.pls 120.2 2006/01/25 01:49 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_erd_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
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
Procedure delete_dml
  (p_rec in psp_erd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the psp_eff_report_details row.
  --
  delete from psp_eff_report_details
  where effort_report_detail_id = p_rec.effort_report_detail_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    psp_erd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in psp_erd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in psp_erd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    psp_erd_rkd.after_delete
      (p_effort_report_detail_id
      => p_rec.effort_report_detail_id
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
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in psp_erd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  psp_erd_shd.lck
    (p_rec.effort_report_detail_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  psp_erd_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  psp_erd_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  psp_erd_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  psp_erd_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_effort_report_detail_id              in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   psp_erd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.effort_report_detail_id := p_effort_report_detail_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the psp_erd_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  psp_erd_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end psp_erd_del;

/
