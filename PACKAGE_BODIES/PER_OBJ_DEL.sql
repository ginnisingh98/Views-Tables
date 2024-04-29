--------------------------------------------------------
--  DDL for Package Body PER_OBJ_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_OBJ_DEL" as
/* $Header: peobjrhi.pkb 120.16.12010000.4 2008/11/05 05:52:10 rvagvala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_obj_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To delete the specified row from the schema using the primary key in
--      the predicates.
--   2) To trap any constraint violations that may have occurred.
--   3) To raise any other errors.
--
-- Pre Conditions:
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
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in per_obj_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Delete the per_objectives row.
  --
  delete from per_objectives
  where objective_id = p_rec.objective_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_obj_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in per_obj_shd.g_rec_type) is
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
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Pre Conditions:
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in per_obj_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_delete.
  begin
    per_obj_rkd.after_delete
      (
       p_objective_id                  => p_rec.objective_id,
       p_name_o                        => per_obj_shd.g_old_rec.name,
       p_target_date_o                 => per_obj_shd.g_old_rec.target_date,
       p_start_date_o                  => per_obj_shd.g_old_rec.start_date,
       p_business_group_id_o           => per_obj_shd.g_old_rec.business_group_id,
       p_object_version_number_o       => per_obj_shd.g_old_rec.object_version_number,
       p_owning_person_id_o            => per_obj_shd.g_old_rec.owning_person_id,
       p_achievement_date_o            => per_obj_shd.g_old_rec.achievement_date,
       p_detail_o                      => per_obj_shd.g_old_rec.detail,
       p_comments_o                    => per_obj_shd.g_old_rec.comments,
       p_success_criteria_o            => per_obj_shd.g_old_rec.success_criteria,
       p_appraisal_id_o                => per_obj_shd.g_old_rec.appraisal_id,
       p_attribute_category_o          => per_obj_shd.g_old_rec.attribute_category,
       p_attribute1_o                  => per_obj_shd.g_old_rec.attribute1,
       p_attribute2_o                  => per_obj_shd.g_old_rec.attribute2,
       p_attribute3_o                  => per_obj_shd.g_old_rec.attribute3,
       p_attribute4_o                  => per_obj_shd.g_old_rec.attribute4,
       p_attribute5_o                  => per_obj_shd.g_old_rec.attribute5,
       p_attribute6_o                  => per_obj_shd.g_old_rec.attribute6,
       p_attribute7_o                  => per_obj_shd.g_old_rec.attribute7,
       p_attribute8_o                  => per_obj_shd.g_old_rec.attribute8,
       p_attribute9_o                  => per_obj_shd.g_old_rec.attribute9,
       p_attribute10_o                 => per_obj_shd.g_old_rec.attribute10,
       p_attribute11_o                 => per_obj_shd.g_old_rec.attribute11,
       p_attribute12_o                 => per_obj_shd.g_old_rec.attribute12,
       p_attribute13_o                 => per_obj_shd.g_old_rec.attribute13,
       p_attribute14_o                 => per_obj_shd.g_old_rec.attribute14,
       p_attribute15_o                 => per_obj_shd.g_old_rec.attribute15,
       p_attribute16_o                 => per_obj_shd.g_old_rec.attribute16,
       p_attribute17_o                 => per_obj_shd.g_old_rec.attribute17,
       p_attribute18_o                 => per_obj_shd.g_old_rec.attribute18,
       p_attribute19_o                 => per_obj_shd.g_old_rec.attribute19,
       p_attribute20_o                 => per_obj_shd.g_old_rec.attribute20,

       p_attribute21_o                 => per_obj_shd.g_old_rec.attribute21,
       p_attribute22_o                 => per_obj_shd.g_old_rec.attribute22,
       p_attribute23_o                 => per_obj_shd.g_old_rec.attribute23,
       p_attribute24_o                 => per_obj_shd.g_old_rec.attribute24,
       p_attribute25_o                 => per_obj_shd.g_old_rec.attribute25,
       p_attribute26_o                 => per_obj_shd.g_old_rec.attribute26,
       p_attribute27_o                 => per_obj_shd.g_old_rec.attribute27,
       p_attribute28_o                 => per_obj_shd.g_old_rec.attribute28,
       p_attribute29_o                 => per_obj_shd.g_old_rec.attribute29,
       p_attribute30_o                 => per_obj_shd.g_old_rec.attribute30,


       p_scorecard_id_o	  	        => per_obj_shd.g_old_rec.scorecard_id,
       p_copied_from_library_id_o	=> per_obj_shd.g_old_rec.copied_from_library_id,
       p_copied_from_objective_id_o	=> per_obj_shd.g_old_rec.copied_from_objective_id,
       p_aligned_with_objective_id_o	=> per_obj_shd.g_old_rec.aligned_with_objective_id,

       p_next_review_date_o		=> per_obj_shd.g_old_rec.next_review_date,
       p_group_code_o			=> per_obj_shd.g_old_rec.group_code,
       p_priority_code_o		=> per_obj_shd.g_old_rec.priority_code,
       p_appraise_flag_o		=> per_obj_shd.g_old_rec.appraise_flag,
       p_verified_flag_o		=> per_obj_shd.g_old_rec.verified_flag,

       p_target_value_o			=> per_obj_shd.g_old_rec.target_value,
       p_actual_value_o			=> per_obj_shd.g_old_rec.actual_value,
       p_weighting_percent_o		=> per_obj_shd.g_old_rec.weighting_percent,
       p_complete_percent_o		=> per_obj_shd.g_old_rec.complete_percent,
       p_uom_code_o			=> per_obj_shd.g_old_rec.uom_code,

       p_measurement_style_code_o	=> per_obj_shd.g_old_rec.measurement_style_code,
       p_measure_name_o			=> per_obj_shd.g_old_rec.measure_name,
       p_measure_type_code_o		=> per_obj_shd.g_old_rec.measure_type_code,
       p_measure_comments_o 		=> per_obj_shd.g_old_rec.measure_comments ,
       p_sharing_access_code_o		=> per_obj_shd.g_old_rec.sharing_access_code


      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_OBJECTIVES'
        ,p_hook_type   => 'AD'
        );
  end;
  -- End of API User Hook for post_delete.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	      in per_obj_shd.g_rec_type,
  p_validate  in boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_per_obj;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  per_obj_shd.lck
	(
	p_rec.objective_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  per_obj_bus.delete_validate(p_rec);
  --
        hr_multi_message.end_validation_set;
  --

  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec);
  --
        hr_multi_message.end_validation_set;
  --
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_per_obj;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_objective_id                       in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  per_obj_shd.g_rec_type;
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
  l_rec.objective_id:= p_objective_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_obj_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_obj_del;

/
