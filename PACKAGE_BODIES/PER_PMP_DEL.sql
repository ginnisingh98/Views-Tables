--------------------------------------------------------
--  DDL for Package Body PER_PMP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PMP_DEL" as
/* $Header: pepmprhi.pkb 120.8.12010000.4 2010/01/27 15:51:33 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pmp_del.';  -- Global package name
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
  (p_rec in per_pmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the per_perf_mgmt_plans row.
  --
  delete from per_perf_mgmt_plans
  where plan_id = p_rec.plan_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    per_pmp_shd.constraint_error
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
Procedure pre_delete(p_rec in per_pmp_shd.g_rec_type) is
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
Procedure post_delete(p_rec in per_pmp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pmp_rkd.after_delete
      (p_plan_id
      => p_rec.plan_id
      ,p_object_version_number_o
      => per_pmp_shd.g_old_rec.object_version_number
      ,p_plan_name_o
      => per_pmp_shd.g_old_rec.plan_name
      ,p_administrator_person_id_o
      => per_pmp_shd.g_old_rec.administrator_person_id
      ,p_previous_plan_id_o
      => per_pmp_shd.g_old_rec.previous_plan_id
      ,p_start_date_o
      => per_pmp_shd.g_old_rec.start_date
      ,p_end_date_o
      => per_pmp_shd.g_old_rec.end_date
      ,p_status_code_o
      => per_pmp_shd.g_old_rec.status_code
      ,p_hierarchy_type_code_o
      => per_pmp_shd.g_old_rec.hierarchy_type_code
      ,p_supervisor_id_o
      => per_pmp_shd.g_old_rec.supervisor_id
      ,p_supervisor_assignment_id_o
      => per_pmp_shd.g_old_rec.supervisor_assignment_id
      ,p_organization_structure_id_o
      => per_pmp_shd.g_old_rec.organization_structure_id
      ,p_org_structure_version_id_o
      => per_pmp_shd.g_old_rec.org_structure_version_id
      ,p_top_organization_id_o
      => per_pmp_shd.g_old_rec.top_organization_id
      ,p_position_structure_id_o
      => per_pmp_shd.g_old_rec.position_structure_id
      ,p_pos_structure_version_id_o
      => per_pmp_shd.g_old_rec.pos_structure_version_id
      ,p_top_position_id_o
      => per_pmp_shd.g_old_rec.top_position_id
      ,p_hierarchy_levels_o
      => per_pmp_shd.g_old_rec.hierarchy_levels
      ,p_automatic_enrollment_flag_o
      => per_pmp_shd.g_old_rec.automatic_enrollment_flag
      ,p_assignment_types_code_o
      => per_pmp_shd.g_old_rec.assignment_types_code
      ,p_primary_asg_only_flag_o
      => per_pmp_shd.g_old_rec.primary_asg_only_flag
      ,p_include_obj_setting_flag_o
      => per_pmp_shd.g_old_rec.include_obj_setting_flag
      ,p_obj_setting_start_date_o
      => per_pmp_shd.g_old_rec.obj_setting_start_date
      ,p_obj_setting_deadline_o
      => per_pmp_shd.g_old_rec.obj_setting_deadline
      ,p_obj_set_outside_period_fla_o
      => per_pmp_shd.g_old_rec.obj_set_outside_period_flag
      ,p_method_code_o
      => per_pmp_shd.g_old_rec.method_code
      ,p_notify_population_flag_o
      => per_pmp_shd.g_old_rec.notify_population_flag
      ,p_automatic_allocation_flag_o
      => per_pmp_shd.g_old_rec.automatic_allocation_flag
      ,p_copy_past_objectives_flag_o
      => per_pmp_shd.g_old_rec.copy_past_objectives_flag
      ,p_sharing_alignment_task_fla_o
      => per_pmp_shd.g_old_rec.sharing_alignment_task_flag
      ,p_include_appraisals_flag_o
      => per_pmp_shd.g_old_rec.include_appraisals_flag
      ,p_change_sc_status_flag_o
      => per_pmp_shd.g_old_rec.change_sc_status_flag
      ,p_attribute_category_o
      => per_pmp_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => per_pmp_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => per_pmp_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => per_pmp_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => per_pmp_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => per_pmp_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => per_pmp_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => per_pmp_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => per_pmp_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => per_pmp_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => per_pmp_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => per_pmp_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => per_pmp_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => per_pmp_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => per_pmp_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => per_pmp_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => per_pmp_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => per_pmp_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => per_pmp_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => per_pmp_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => per_pmp_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => per_pmp_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => per_pmp_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => per_pmp_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => per_pmp_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => per_pmp_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => per_pmp_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => per_pmp_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => per_pmp_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => per_pmp_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => per_pmp_shd.g_old_rec.attribute30
    ,p_update_library_objectives_o
      => per_pmp_shd.g_old_rec.update_library_objectives  --  8740021 bug fix
       ,p_automatic_approval_flag_o
      => per_pmp_shd.g_old_rec.automatic_approval_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PERF_MGMT_PLANS'
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
  (p_rec              in per_pmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_pmp_shd.lck
    (p_rec.plan_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_pmp_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  per_pmp_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_pmp_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_pmp_del.post_delete(p_rec);
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
  (p_plan_id                              in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   per_pmp_shd.g_rec_type;
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
  l_rec.plan_id := p_plan_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_pmp_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_pmp_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_pmp_del;

/
