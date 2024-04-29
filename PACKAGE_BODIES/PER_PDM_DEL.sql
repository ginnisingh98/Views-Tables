--------------------------------------------------------
--  DDL for Package Body PER_PDM_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PDM_DEL" as
/* $Header: pepdmrhi.pkb 115.8 2002/12/09 14:33:06 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pdm_del.';  -- Global package name
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
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in per_pdm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Delete the per_person_dlvry_methods row.
  --
  delete from per_person_dlvry_methods
  where delivery_method_id = p_rec.delivery_method_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_pdm_shd.constraint_error
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
Procedure pre_delete(p_rec in per_pdm_shd.g_rec_type) is
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in per_pdm_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    per_pdm_rkd.after_delete
      (
  p_delivery_method_id            =>p_rec.delivery_method_id
 ,p_date_start_o                  =>per_pdm_shd.g_old_rec.date_start
 ,p_date_end_o                    =>per_pdm_shd.g_old_rec.date_end
 ,p_person_id_o                   =>per_pdm_shd.g_old_rec.person_id
 ,p_comm_dlvry_method_o           =>per_pdm_shd.g_old_rec.comm_dlvry_method
 ,p_preferred_flag_o              =>per_pdm_shd.g_old_rec.preferred_flag
 ,p_object_version_number_o       =>per_pdm_shd.g_old_rec.object_version_number
 ,p_request_id_o                  =>per_pdm_shd.g_old_rec.request_id
 ,p_program_update_date_o         =>per_pdm_shd.g_old_rec.program_update_date
 ,p_program_application_id_o      =>per_pdm_shd.g_old_rec.program_application_id
 ,p_program_id_o                  =>per_pdm_shd.g_old_rec.program_id
 ,p_attribute_category_o          =>per_pdm_shd.g_old_rec.attribute_category
 ,p_attribute1_o                  =>per_pdm_shd.g_old_rec.attribute1
 ,p_attribute2_o                  =>per_pdm_shd.g_old_rec.attribute2
 ,p_attribute3_o                  =>per_pdm_shd.g_old_rec.attribute3
 ,p_attribute4_o                  =>per_pdm_shd.g_old_rec.attribute4
 ,p_attribute5_o                  =>per_pdm_shd.g_old_rec.attribute5
 ,p_attribute6_o                  =>per_pdm_shd.g_old_rec.attribute6
 ,p_attribute7_o                  =>per_pdm_shd.g_old_rec.attribute7
 ,p_attribute8_o                  =>per_pdm_shd.g_old_rec.attribute8
 ,p_attribute9_o                  =>per_pdm_shd.g_old_rec.attribute9
 ,p_attribute10_o                 =>per_pdm_shd.g_old_rec.attribute10
 ,p_attribute11_o                 =>per_pdm_shd.g_old_rec.attribute11
 ,p_attribute12_o                 =>per_pdm_shd.g_old_rec.attribute12
 ,p_attribute13_o                 =>per_pdm_shd.g_old_rec.attribute13
 ,p_attribute14_o                 =>per_pdm_shd.g_old_rec.attribute14
 ,p_attribute15_o                 =>per_pdm_shd.g_old_rec.attribute15
 ,p_attribute16_o                 =>per_pdm_shd.g_old_rec.attribute16
 ,p_attribute17_o                 =>per_pdm_shd.g_old_rec.attribute17
 ,p_attribute18_o                 =>per_pdm_shd.g_old_rec.attribute18
 ,p_attribute19_o                 =>per_pdm_shd.g_old_rec.attribute19
 ,p_attribute20_o                 =>per_pdm_shd.g_old_rec.attribute20
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PERSON_DLVRY_METHODS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	      in per_pdm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_pdm_shd.lck
	(
	p_rec.delivery_method_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  per_pdm_bus.delete_validate(p_rec);
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
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_delivery_method_id                 in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  per_pdm_shd.g_rec_type;
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
  l_rec.delivery_method_id:= p_delivery_method_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_pdm_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_pdm_del;

/
