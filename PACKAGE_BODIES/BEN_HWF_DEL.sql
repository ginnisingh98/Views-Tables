--------------------------------------------------------
--  DDL for Package Body BEN_HWF_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_HWF_DEL" as
/* $Header: behwfrhi.pkb 120.0 2005/05/28 03:12:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_hwf_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ben_hwf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_hwf_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_hrs_wkd_in_perd_fctr row.
  --
  delete from ben_hrs_wkd_in_perd_fctr
  where hrs_wkd_in_perd_fctr_id = p_rec.hrs_wkd_in_perd_fctr_id;
  --
  ben_hwf_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_hwf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_hwf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_hwf_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_hwf_shd.g_rec_type) is
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
p_effective_date in date,p_rec in ben_hwf_shd.g_rec_type) is
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
    ben_hwf_rkd.after_delete
      (
  p_hrs_wkd_in_perd_fctr_id       =>p_rec.hrs_wkd_in_perd_fctr_id
 ,p_name_o                        =>ben_hwf_shd.g_old_rec.name
 ,p_business_group_id_o           =>ben_hwf_shd.g_old_rec.business_group_id
 ,p_hrs_src_cd_o                  =>ben_hwf_shd.g_old_rec.hrs_src_cd
 ,p_rndg_cd_o                     =>ben_hwf_shd.g_old_rec.rndg_cd
 ,p_rndg_rl_o                     =>ben_hwf_shd.g_old_rec.rndg_rl
 ,p_hrs_wkd_det_cd_o              =>ben_hwf_shd.g_old_rec.hrs_wkd_det_cd
 ,p_hrs_wkd_det_rl_o              =>ben_hwf_shd.g_old_rec.hrs_wkd_det_rl
 ,p_no_mn_hrs_wkd_flag_o          =>ben_hwf_shd.g_old_rec.no_mn_hrs_wkd_flag
 ,p_mx_hrs_num_o                  =>ben_hwf_shd.g_old_rec.mx_hrs_num
 ,p_no_mx_hrs_wkd_flag_o          =>ben_hwf_shd.g_old_rec.no_mx_hrs_wkd_flag
 ,p_once_r_cntug_cd_o             =>ben_hwf_shd.g_old_rec.once_r_cntug_cd
 ,p_mn_hrs_num_o                  =>ben_hwf_shd.g_old_rec.mn_hrs_num
 ,p_hrs_alt_val_to_use_cd_o       =>ben_hwf_shd.g_old_rec.hrs_alt_val_to_use_cd
 ,p_pyrl_freq_cd_o                =>ben_hwf_shd.g_old_rec.pyrl_freq_cd
 ,p_hrs_wkd_calc_rl_o             =>ben_hwf_shd.g_old_rec.hrs_wkd_calc_rl
 ,p_defined_balance_id_o          =>ben_hwf_shd.g_old_rec.defined_balance_id
 ,p_bnfts_bal_id_o                =>ben_hwf_shd.g_old_rec.bnfts_bal_id
 ,p_hwf_attribute_category_o      =>ben_hwf_shd.g_old_rec.hwf_attribute_category
 ,p_hwf_attribute1_o              =>ben_hwf_shd.g_old_rec.hwf_attribute1
 ,p_hwf_attribute2_o              =>ben_hwf_shd.g_old_rec.hwf_attribute2
 ,p_hwf_attribute3_o              =>ben_hwf_shd.g_old_rec.hwf_attribute3
 ,p_hwf_attribute4_o              =>ben_hwf_shd.g_old_rec.hwf_attribute4
 ,p_hwf_attribute5_o              =>ben_hwf_shd.g_old_rec.hwf_attribute5
 ,p_hwf_attribute6_o              =>ben_hwf_shd.g_old_rec.hwf_attribute6
 ,p_hwf_attribute7_o              =>ben_hwf_shd.g_old_rec.hwf_attribute7
 ,p_hwf_attribute8_o              =>ben_hwf_shd.g_old_rec.hwf_attribute8
 ,p_hwf_attribute9_o              =>ben_hwf_shd.g_old_rec.hwf_attribute9
 ,p_hwf_attribute10_o             =>ben_hwf_shd.g_old_rec.hwf_attribute10
 ,p_hwf_attribute11_o             =>ben_hwf_shd.g_old_rec.hwf_attribute11
 ,p_hwf_attribute12_o             =>ben_hwf_shd.g_old_rec.hwf_attribute12
 ,p_hwf_attribute13_o             =>ben_hwf_shd.g_old_rec.hwf_attribute13
 ,p_hwf_attribute14_o             =>ben_hwf_shd.g_old_rec.hwf_attribute14
 ,p_hwf_attribute15_o             =>ben_hwf_shd.g_old_rec.hwf_attribute15
 ,p_hwf_attribute16_o             =>ben_hwf_shd.g_old_rec.hwf_attribute16
 ,p_hwf_attribute17_o             =>ben_hwf_shd.g_old_rec.hwf_attribute17
 ,p_hwf_attribute18_o             =>ben_hwf_shd.g_old_rec.hwf_attribute18
 ,p_hwf_attribute19_o             =>ben_hwf_shd.g_old_rec.hwf_attribute19
 ,p_hwf_attribute20_o             =>ben_hwf_shd.g_old_rec.hwf_attribute20
 ,p_hwf_attribute21_o             =>ben_hwf_shd.g_old_rec.hwf_attribute21
 ,p_hwf_attribute22_o             =>ben_hwf_shd.g_old_rec.hwf_attribute22
 ,p_hwf_attribute23_o             =>ben_hwf_shd.g_old_rec.hwf_attribute23
 ,p_hwf_attribute24_o             =>ben_hwf_shd.g_old_rec.hwf_attribute24
 ,p_hwf_attribute25_o             =>ben_hwf_shd.g_old_rec.hwf_attribute25
 ,p_hwf_attribute26_o             =>ben_hwf_shd.g_old_rec.hwf_attribute26
 ,p_hwf_attribute27_o             =>ben_hwf_shd.g_old_rec.hwf_attribute27
 ,p_hwf_attribute28_o             =>ben_hwf_shd.g_old_rec.hwf_attribute28
 ,p_hwf_attribute29_o             =>ben_hwf_shd.g_old_rec.hwf_attribute29
 ,p_hwf_attribute30_o             =>ben_hwf_shd.g_old_rec.hwf_attribute30
 ,p_object_version_number_o       =>ben_hwf_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_hrs_wkd_in_perd_fctr'
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
  p_rec	      in ben_hwf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_hwf_shd.lck
	(
	p_rec.hrs_wkd_in_perd_fctr_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_hwf_bus.delete_validate(p_rec
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
  p_hrs_wkd_in_perd_fctr_id            in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_hwf_shd.g_rec_type;
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
  l_rec.hrs_wkd_in_perd_fctr_id:= p_hrs_wkd_in_perd_fctr_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_hwf_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_hwf_del;

/
