--------------------------------------------------------
--  DDL for Package Body BEN_PDT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PDT_DEL" as
/* $Header: bepdtrhi.pkb 115.0 2003/10/30 09:33 rpillay noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pdt_del.';  -- Global package name
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
  (p_rec in ben_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the ben_pymt_check_det row.
  --
  delete from ben_pymt_check_det
  where pymt_check_det_id = p_rec.pymt_check_det_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    ben_pdt_shd.constraint_error
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
Procedure pre_delete(p_rec in ben_pdt_shd.g_rec_type) is
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
Procedure post_delete(p_rec in ben_pdt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_pdt_rkd.after_delete
      (p_pymt_check_det_id
      => p_rec.pymt_check_det_id
      ,p_person_id_o
      => ben_pdt_shd.g_old_rec.person_id
      ,p_business_group_id_o
      => ben_pdt_shd.g_old_rec.business_group_id
      ,p_check_num_o
      => ben_pdt_shd.g_old_rec.check_num
      ,p_pymt_dt_o
      => ben_pdt_shd.g_old_rec.pymt_dt
      ,p_pymt_amt_o
      => ben_pdt_shd.g_old_rec.pymt_amt
      ,p_pdt_attribute_category_o
      => ben_pdt_shd.g_old_rec.pdt_attribute_category
      ,p_pdt_attribute1_o
      => ben_pdt_shd.g_old_rec.pdt_attribute1
      ,p_pdt_attribute2_o
      => ben_pdt_shd.g_old_rec.pdt_attribute2
      ,p_pdt_attribute3_o
      => ben_pdt_shd.g_old_rec.pdt_attribute3
      ,p_pdt_attribute4_o
      => ben_pdt_shd.g_old_rec.pdt_attribute4
      ,p_pdt_attribute5_o
      => ben_pdt_shd.g_old_rec.pdt_attribute5
      ,p_pdt_attribute6_o
      => ben_pdt_shd.g_old_rec.pdt_attribute6
      ,p_pdt_attribute7_o
      => ben_pdt_shd.g_old_rec.pdt_attribute7
      ,p_pdt_attribute8_o
      => ben_pdt_shd.g_old_rec.pdt_attribute8
      ,p_pdt_attribute9_o
      => ben_pdt_shd.g_old_rec.pdt_attribute9
      ,p_pdt_attribute10_o
      => ben_pdt_shd.g_old_rec.pdt_attribute10
      ,p_pdt_attribute11_o
      => ben_pdt_shd.g_old_rec.pdt_attribute11
      ,p_pdt_attribute12_o
      => ben_pdt_shd.g_old_rec.pdt_attribute12
      ,p_pdt_attribute13_o
      => ben_pdt_shd.g_old_rec.pdt_attribute13
      ,p_pdt_attribute14_o
      => ben_pdt_shd.g_old_rec.pdt_attribute14
      ,p_pdt_attribute15_o
      => ben_pdt_shd.g_old_rec.pdt_attribute15
      ,p_pdt_attribute16_o
      => ben_pdt_shd.g_old_rec.pdt_attribute16
      ,p_pdt_attribute17_o
      => ben_pdt_shd.g_old_rec.pdt_attribute17
      ,p_pdt_attribute18_o
      => ben_pdt_shd.g_old_rec.pdt_attribute18
      ,p_pdt_attribute19_o
      => ben_pdt_shd.g_old_rec.pdt_attribute19
      ,p_pdt_attribute20_o
      => ben_pdt_shd.g_old_rec.pdt_attribute20
      ,p_pdt_attribute21_o
      => ben_pdt_shd.g_old_rec.pdt_attribute21
      ,p_pdt_attribute22_o
      => ben_pdt_shd.g_old_rec.pdt_attribute22
      ,p_pdt_attribute23_o
      => ben_pdt_shd.g_old_rec.pdt_attribute23
      ,p_pdt_attribute24_o
      => ben_pdt_shd.g_old_rec.pdt_attribute24
      ,p_pdt_attribute25_o
      => ben_pdt_shd.g_old_rec.pdt_attribute25
      ,p_pdt_attribute26_o
      => ben_pdt_shd.g_old_rec.pdt_attribute26
      ,p_pdt_attribute27_o
      => ben_pdt_shd.g_old_rec.pdt_attribute27
      ,p_pdt_attribute28_o
      => ben_pdt_shd.g_old_rec.pdt_attribute28
      ,p_pdt_attribute29_o
      => ben_pdt_shd.g_old_rec.pdt_attribute29
      ,p_pdt_attribute30_o
      => ben_pdt_shd.g_old_rec.pdt_attribute30
      ,p_object_version_number_o
      => ben_pdt_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_PYMT_CHECK_DET'
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
  (p_rec              in ben_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_pdt_shd.lck
    (p_rec.pymt_check_det_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ben_pdt_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  ben_pdt_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ben_pdt_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ben_pdt_del.post_delete(p_rec);
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
  (p_pymt_check_det_id                    in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   ben_pdt_shd.g_rec_type;
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
  l_rec.pymt_check_det_id := p_pymt_check_det_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_pdt_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ben_pdt_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_pdt_del;

/
