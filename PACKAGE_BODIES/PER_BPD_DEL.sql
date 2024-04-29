--------------------------------------------------------
--  DDL for Package Body PER_BPD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPD_DEL" as
/* $Header: pebpdrhi.pkb 115.6 2002/12/02 13:52:43 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpd_del.';  -- Global package name
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
Procedure delete_dml(p_rec in per_bpd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the per_bf_payment_details row.
  --
  delete from per_bf_payment_details
  where payment_detail_id = p_rec.payment_detail_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_bpd_shd.constraint_error
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
Procedure pre_delete(p_rec in per_bpd_shd.g_rec_type) is
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
Procedure post_delete(p_rec in per_bpd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    per_bpd_rkd.after_delete
      (
      p_payment_detail_id
        => p_rec.payment_detail_id,
      p_processed_assignment_id_o
      => per_bpd_shd.g_old_rec.processed_assignment_id,
      p_personal_payment_method_id_o
      => per_bpd_shd.g_old_rec.personal_payment_method_id,
      p_business_group_id_o
      => per_bpd_shd.g_old_rec.business_group_id,
      p_check_number_o
      => per_bpd_shd.g_old_rec.check_number,
      p_payment_date_o
      => per_bpd_shd.g_old_rec.payment_date,
      p_amount_o
      => per_bpd_shd.g_old_rec.amount,
      p_check_type_o
      => per_bpd_shd.g_old_rec.check_type,
      p_object_version_number_o
      => per_bpd_shd.g_old_rec.object_version_number,
      p_bpd_attribute_category_o
      => per_bpd_shd.g_old_rec.bpd_attribute_category,
      p_bpd_attribute1_o
      => per_bpd_shd.g_old_rec.bpd_attribute1,
      p_bpd_attribute2_o
      => per_bpd_shd.g_old_rec.bpd_attribute2,
      p_bpd_attribute3_o
      => per_bpd_shd.g_old_rec.bpd_attribute3,
      p_bpd_attribute4_o
      => per_bpd_shd.g_old_rec.bpd_attribute4,
      p_bpd_attribute5_o
      => per_bpd_shd.g_old_rec.bpd_attribute5,
      p_bpd_attribute6_o
      => per_bpd_shd.g_old_rec.bpd_attribute6,
      p_bpd_attribute7_o
      => per_bpd_shd.g_old_rec.bpd_attribute7,
      p_bpd_attribute8_o
      => per_bpd_shd.g_old_rec.bpd_attribute8,
      p_bpd_attribute9_o
      => per_bpd_shd.g_old_rec.bpd_attribute9,
      p_bpd_attribute10_o
      => per_bpd_shd.g_old_rec.bpd_attribute10,
      p_bpd_attribute11_o
      => per_bpd_shd.g_old_rec.bpd_attribute11,
      p_bpd_attribute12_o
      => per_bpd_shd.g_old_rec.bpd_attribute12,
      p_bpd_attribute13_o
      => per_bpd_shd.g_old_rec.bpd_attribute13,
      p_bpd_attribute14_o
      => per_bpd_shd.g_old_rec.bpd_attribute14,
      p_bpd_attribute15_o
      => per_bpd_shd.g_old_rec.bpd_attribute15,
      p_bpd_attribute16_o
      => per_bpd_shd.g_old_rec.bpd_attribute16,
      p_bpd_attribute17_o
      => per_bpd_shd.g_old_rec.bpd_attribute17,
      p_bpd_attribute18_o
      => per_bpd_shd.g_old_rec.bpd_attribute18,
      p_bpd_attribute19_o
      => per_bpd_shd.g_old_rec.bpd_attribute19,
      p_bpd_attribute20_o
      => per_bpd_shd.g_old_rec.bpd_attribute20,
      p_bpd_attribute21_o
      => per_bpd_shd.g_old_rec.bpd_attribute21,
      p_bpd_attribute22_o
      => per_bpd_shd.g_old_rec.bpd_attribute22,
      p_bpd_attribute23_o
      => per_bpd_shd.g_old_rec.bpd_attribute23,
      p_bpd_attribute24_o
      => per_bpd_shd.g_old_rec.bpd_attribute24,
      p_bpd_attribute25_o
      => per_bpd_shd.g_old_rec.bpd_attribute25,
      p_bpd_attribute26_o
      => per_bpd_shd.g_old_rec.bpd_attribute26,
      p_bpd_attribute27_o
      => per_bpd_shd.g_old_rec.bpd_attribute27,
      p_bpd_attribute28_o
      => per_bpd_shd.g_old_rec.bpd_attribute28,
      p_bpd_attribute29_o
      => per_bpd_shd.g_old_rec.bpd_attribute29,
      p_bpd_attribute30_o
      => per_bpd_shd.g_old_rec.bpd_attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_BF_PAYMENT_DETAILS'
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
  p_rec	      in per_bpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_bpd_shd.lck
    (
      p_rec.payment_detail_id,
       p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_bpd_bus.delete_validate(p_rec);
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
p_payment_detail_id                    in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  per_bpd_shd.g_rec_type;
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
  l_rec.payment_detail_id := p_payment_detail_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_bpd_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_bpd_del;

/
