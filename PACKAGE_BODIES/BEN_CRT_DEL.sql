--------------------------------------------------------
--  DDL for Package Body BEN_CRT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CRT_DEL" as
/* $Header: becrtrhi.pkb 115.11 2004/06/22 07:52:16 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_crt_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ben_crt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_crt_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_crt_ordr row.
  --
  delete from ben_crt_ordr
  where crt_ordr_id = p_rec.crt_ordr_id;
  --
  ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
    ben_crt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_crt_shd.g_rec_type) is
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
Procedure post_delete(
p_effective_date in date,p_rec in ben_crt_shd.g_rec_type) is
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
    ben_crt_rkd.after_delete
      (
  p_crt_ordr_id                   =>p_rec.crt_ordr_id
 ,p_crt_ordr_typ_cd_o             =>ben_crt_shd.g_old_rec.crt_ordr_typ_cd
 ,p_apls_perd_endg_dt_o           =>ben_crt_shd.g_old_rec.apls_perd_endg_dt
 ,p_apls_perd_strtg_dt_o          =>ben_crt_shd.g_old_rec.apls_perd_strtg_dt
 ,p_crt_ident_o                   =>ben_crt_shd.g_old_rec.crt_ident
 ,p_description_o                 =>ben_crt_shd.g_old_rec.description
 ,p_detd_qlfd_ordr_dt_o           =>ben_crt_shd.g_old_rec.detd_qlfd_ordr_dt
 ,p_issue_dt_o                    =>ben_crt_shd.g_old_rec.issue_dt
 ,p_qdro_amt_o                    =>ben_crt_shd.g_old_rec.qdro_amt
 ,p_qdro_dstr_mthd_cd_o           =>ben_crt_shd.g_old_rec.qdro_dstr_mthd_cd
 ,p_qdro_pct_o                    =>ben_crt_shd.g_old_rec.qdro_pct
 ,p_rcvd_dt_o                     =>ben_crt_shd.g_old_rec.rcvd_dt
 ,p_uom_o                         =>ben_crt_shd.g_old_rec.uom
 ,p_crt_issng_o                   =>ben_crt_shd.g_old_rec.crt_issng
 ,p_pl_id_o                       =>ben_crt_shd.g_old_rec.pl_id
 ,p_person_id_o                   =>ben_crt_shd.g_old_rec.person_id
 ,p_business_group_id_o           =>ben_crt_shd.g_old_rec.business_group_id
 ,p_crt_attribute_category_o      =>ben_crt_shd.g_old_rec.crt_attribute_category
 ,p_crt_attribute1_o              =>ben_crt_shd.g_old_rec.crt_attribute1
 ,p_crt_attribute2_o              =>ben_crt_shd.g_old_rec.crt_attribute2
 ,p_crt_attribute3_o              =>ben_crt_shd.g_old_rec.crt_attribute3
 ,p_crt_attribute4_o              =>ben_crt_shd.g_old_rec.crt_attribute4
 ,p_crt_attribute5_o              =>ben_crt_shd.g_old_rec.crt_attribute5
 ,p_crt_attribute6_o              =>ben_crt_shd.g_old_rec.crt_attribute6
 ,p_crt_attribute7_o              =>ben_crt_shd.g_old_rec.crt_attribute7
 ,p_crt_attribute8_o              =>ben_crt_shd.g_old_rec.crt_attribute8
 ,p_crt_attribute9_o              =>ben_crt_shd.g_old_rec.crt_attribute9
 ,p_crt_attribute10_o             =>ben_crt_shd.g_old_rec.crt_attribute10
 ,p_crt_attribute11_o             =>ben_crt_shd.g_old_rec.crt_attribute11
 ,p_crt_attribute12_o             =>ben_crt_shd.g_old_rec.crt_attribute12
 ,p_crt_attribute13_o             =>ben_crt_shd.g_old_rec.crt_attribute13
 ,p_crt_attribute14_o             =>ben_crt_shd.g_old_rec.crt_attribute14
 ,p_crt_attribute15_o             =>ben_crt_shd.g_old_rec.crt_attribute15
 ,p_crt_attribute16_o             =>ben_crt_shd.g_old_rec.crt_attribute16
 ,p_crt_attribute17_o             =>ben_crt_shd.g_old_rec.crt_attribute17
 ,p_crt_attribute18_o             =>ben_crt_shd.g_old_rec.crt_attribute18
 ,p_crt_attribute19_o             =>ben_crt_shd.g_old_rec.crt_attribute19
 ,p_crt_attribute20_o             =>ben_crt_shd.g_old_rec.crt_attribute20
 ,p_crt_attribute21_o             =>ben_crt_shd.g_old_rec.crt_attribute21
 ,p_crt_attribute22_o             =>ben_crt_shd.g_old_rec.crt_attribute22
 ,p_crt_attribute23_o             =>ben_crt_shd.g_old_rec.crt_attribute23
 ,p_crt_attribute24_o             =>ben_crt_shd.g_old_rec.crt_attribute24
 ,p_crt_attribute25_o             =>ben_crt_shd.g_old_rec.crt_attribute25
 ,p_crt_attribute26_o             =>ben_crt_shd.g_old_rec.crt_attribute26
 ,p_crt_attribute27_o             =>ben_crt_shd.g_old_rec.crt_attribute27
 ,p_crt_attribute28_o             =>ben_crt_shd.g_old_rec.crt_attribute28
 ,p_crt_attribute29_o             =>ben_crt_shd.g_old_rec.crt_attribute29
 ,p_crt_attribute30_o             =>ben_crt_shd.g_old_rec.crt_attribute30
 ,p_object_version_number_o       =>ben_crt_shd.g_old_rec.object_version_number
 ,p_qdro_num_pymt_val_o           =>ben_crt_shd.g_old_rec.qdro_num_pymt_val
 ,p_qdro_per_perd_cd_o            =>ben_crt_shd.g_old_rec.qdro_per_perd_cd
 ,p_pl_typ_id_o                   =>ben_crt_shd.g_old_rec.pl_typ_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_crt_ordr'
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
  p_effective_date in date,
  p_rec	      in ben_crt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_crt_shd.lck
	(
	p_rec.crt_ordr_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_crt_bus.delete_validate(p_rec
  ,p_effective_date);
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
  post_delete(
p_effective_date,p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_crt_ordr_id                        in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_crt_shd.g_rec_type;
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
  l_rec.crt_ordr_id:= p_crt_ordr_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_crt_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_crt_del;

/
