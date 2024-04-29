--------------------------------------------------------
--  DDL for Package Body PER_BPR_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPR_DEL" as
/* $Header: pebprrhi.pkb 115.6 2002/12/02 14:33:23 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpr_del.';  -- Global package name
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
Procedure delete_dml(p_rec in per_bpr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the per_bf_payroll_runs row.
  --
  delete from per_bf_payroll_runs
  where payroll_run_id = p_rec.payroll_run_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_bpr_shd.constraint_error
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
Procedure pre_delete(p_rec in per_bpr_shd.g_rec_type) is
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
Procedure post_delete(p_rec in per_bpr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    per_bpr_rkd.after_delete
      (
      p_payroll_run_id
        => p_rec.payroll_run_id,
      p_payroll_id_o
      => per_bpr_shd.g_old_rec.payroll_id,
      p_business_group_id_o
      => per_bpr_shd.g_old_rec.business_group_id,
      p_payroll_identifier_o
      => per_bpr_shd.g_old_rec.payroll_identifier,
      p_period_start_date_o
      => per_bpr_shd.g_old_rec.period_start_date,
      p_period_end_date_o
      => per_bpr_shd.g_old_rec.period_end_date,
      p_processing_date_o
      => per_bpr_shd.g_old_rec.processing_date,
      p_object_version_number_o
      => per_bpr_shd.g_old_rec.object_version_number,
      p_bpr_attribute_category_o
      => per_bpr_shd.g_old_rec.bpr_attribute_category,
      p_bpr_attribute1_o
      => per_bpr_shd.g_old_rec.bpr_attribute1,
      p_bpr_attribute2_o
      => per_bpr_shd.g_old_rec.bpr_attribute2,
      p_bpr_attribute3_o
      => per_bpr_shd.g_old_rec.bpr_attribute3,
      p_bpr_attribute4_o
      => per_bpr_shd.g_old_rec.bpr_attribute4,
      p_bpr_attribute5_o
      => per_bpr_shd.g_old_rec.bpr_attribute5,
      p_bpr_attribute6_o
      => per_bpr_shd.g_old_rec.bpr_attribute6,
      p_bpr_attribute7_o
      => per_bpr_shd.g_old_rec.bpr_attribute7,
      p_bpr_attribute8_o
      => per_bpr_shd.g_old_rec.bpr_attribute8,
      p_bpr_attribute9_o
      => per_bpr_shd.g_old_rec.bpr_attribute9,
      p_bpr_attribute10_o
      => per_bpr_shd.g_old_rec.bpr_attribute10,
      p_bpr_attribute11_o
      => per_bpr_shd.g_old_rec.bpr_attribute11,
      p_bpr_attribute12_o
      => per_bpr_shd.g_old_rec.bpr_attribute12,
      p_bpr_attribute13_o
      => per_bpr_shd.g_old_rec.bpr_attribute13,
      p_bpr_attribute14_o
      => per_bpr_shd.g_old_rec.bpr_attribute14,
      p_bpr_attribute15_o
      => per_bpr_shd.g_old_rec.bpr_attribute15,
      p_bpr_attribute16_o
      => per_bpr_shd.g_old_rec.bpr_attribute16,
      p_bpr_attribute17_o
      => per_bpr_shd.g_old_rec.bpr_attribute17,
      p_bpr_attribute18_o
      => per_bpr_shd.g_old_rec.bpr_attribute18,
      p_bpr_attribute19_o
      => per_bpr_shd.g_old_rec.bpr_attribute19,
      p_bpr_attribute20_o
      => per_bpr_shd.g_old_rec.bpr_attribute20,
      p_bpr_attribute21_o
      => per_bpr_shd.g_old_rec.bpr_attribute21,
      p_bpr_attribute22_o
      => per_bpr_shd.g_old_rec.bpr_attribute22,
      p_bpr_attribute23_o
      => per_bpr_shd.g_old_rec.bpr_attribute23,
      p_bpr_attribute24_o
      => per_bpr_shd.g_old_rec.bpr_attribute24,
      p_bpr_attribute25_o
      => per_bpr_shd.g_old_rec.bpr_attribute25,
      p_bpr_attribute26_o
      => per_bpr_shd.g_old_rec.bpr_attribute26,
      p_bpr_attribute27_o
      => per_bpr_shd.g_old_rec.bpr_attribute27,
      p_bpr_attribute28_o
      => per_bpr_shd.g_old_rec.bpr_attribute28,
      p_bpr_attribute29_o
      => per_bpr_shd.g_old_rec.bpr_attribute29,
      p_bpr_attribute30_o
      => per_bpr_shd.g_old_rec.bpr_attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_BF_PAYROLL_RUNS'
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
  (
  p_rec	      in per_bpr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_bpr_shd.lck
    (
      p_rec.payroll_run_id,
       p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_bpr_bus.delete_validate(p_rec);
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
p_payroll_run_id                       in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  per_bpr_shd.g_rec_type;
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
  l_rec.payroll_run_id := p_payroll_run_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_bpr_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_bpr_del;

/
