--------------------------------------------------------
--  DDL for Package Body PER_BPA_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPA_DEL" as
/* $Header: pebparhi.pkb 115.6 2002/12/02 13:36:46 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpa_del.';  -- Global package name
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
  (p_rec in per_bpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the per_bf_processed_assignments row.
  --
  delete from per_bf_processed_assignments
  where processed_assignment_id = p_rec.processed_assignment_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    per_bpa_shd.constraint_error
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
Procedure pre_delete(p_rec in per_bpa_shd.g_rec_type) is
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
Procedure post_delete(p_rec in per_bpa_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    per_bpa_rkd.after_delete
      (p_processed_assignment_id
        => p_rec.processed_assignment_id,
      p_payroll_run_id_o
      => per_bpa_shd.g_old_rec.payroll_run_id,
      p_assignment_id_o
      => per_bpa_shd.g_old_rec.assignment_id,
      p_object_version_number_o
      => per_bpa_shd.g_old_rec.object_version_number,
      p_bpa_attribute_category_o
      => per_bpa_shd.g_old_rec.bpa_attribute_category,
      p_bpa_attribute1_o
      => per_bpa_shd.g_old_rec.bpa_attribute1,
      p_bpa_attribute2_o
      => per_bpa_shd.g_old_rec.bpa_attribute2,
      p_bpa_attribute3_o
      => per_bpa_shd.g_old_rec.bpa_attribute3,
      p_bpa_attribute4_o
      => per_bpa_shd.g_old_rec.bpa_attribute4,
      p_bpa_attribute5_o
      => per_bpa_shd.g_old_rec.bpa_attribute5,
      p_bpa_attribute6_o
      => per_bpa_shd.g_old_rec.bpa_attribute6,
      p_bpa_attribute7_o
      => per_bpa_shd.g_old_rec.bpa_attribute7,
      p_bpa_attribute8_o
      => per_bpa_shd.g_old_rec.bpa_attribute8,
      p_bpa_attribute9_o
      => per_bpa_shd.g_old_rec.bpa_attribute9,
      p_bpa_attribute10_o
      => per_bpa_shd.g_old_rec.bpa_attribute10,
      p_bpa_attribute11_o
      => per_bpa_shd.g_old_rec.bpa_attribute11,
      p_bpa_attribute12_o
      => per_bpa_shd.g_old_rec.bpa_attribute12,
      p_bpa_attribute13_o
      => per_bpa_shd.g_old_rec.bpa_attribute13,
      p_bpa_attribute14_o
      => per_bpa_shd.g_old_rec.bpa_attribute14,
      p_bpa_attribute15_o
      => per_bpa_shd.g_old_rec.bpa_attribute15,
      p_bpa_attribute16_o
      => per_bpa_shd.g_old_rec.bpa_attribute16,
      p_bpa_attribute17_o
      => per_bpa_shd.g_old_rec.bpa_attribute17,
      p_bpa_attribute18_o
      => per_bpa_shd.g_old_rec.bpa_attribute18,
      p_bpa_attribute19_o
      => per_bpa_shd.g_old_rec.bpa_attribute19,
      p_bpa_attribute20_o
      => per_bpa_shd.g_old_rec.bpa_attribute20,
      p_bpa_attribute21_o
      => per_bpa_shd.g_old_rec.bpa_attribute21,
      p_bpa_attribute22_o
      => per_bpa_shd.g_old_rec.bpa_attribute22,
      p_bpa_attribute23_o
      => per_bpa_shd.g_old_rec.bpa_attribute23,
      p_bpa_attribute24_o
      => per_bpa_shd.g_old_rec.bpa_attribute24,
      p_bpa_attribute25_o
      => per_bpa_shd.g_old_rec.bpa_attribute25,
      p_bpa_attribute26_o
      => per_bpa_shd.g_old_rec.bpa_attribute26,
      p_bpa_attribute27_o
      => per_bpa_shd.g_old_rec.bpa_attribute27,
      p_bpa_attribute28_o
      => per_bpa_shd.g_old_rec.bpa_attribute28,
      p_bpa_attribute29_o
      => per_bpa_shd.g_old_rec.bpa_attribute29,
      p_bpa_attribute30_o
      => per_bpa_shd.g_old_rec.bpa_attribute30
      );
--
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_BF_PROCESSED_ASSIGNMENTS'
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
  (p_rec	      in per_bpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_bpa_shd.lck
    (p_rec.processed_assignment_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_bpa_bus.delete_validate(p_rec);
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
  (p_processed_assignment_id              in number
  ,p_object_version_number                in number
  ) is
--
  l_rec	  per_bpa_shd.g_rec_type;
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
  l_rec.processed_assignment_id := p_processed_assignment_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_bpa_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_bpa_del;

/
