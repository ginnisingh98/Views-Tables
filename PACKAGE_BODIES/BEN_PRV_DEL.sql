--------------------------------------------------------
--  DDL for Package Body BEN_PRV_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRV_DEL" as
/* $Header: beprvrhi.pkb 120.0.12000000.3 2007/07/01 19:16:05 mmudigon noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_prv_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ben_prv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_prv_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_prtt_rt_val row.
  --
  delete from ben_prtt_rt_val
  where prtt_rt_val_id = p_rec.prtt_rt_val_id;
  --
  ben_prv_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_prv_shd.g_api_dml := false;   -- Unset the api dml status
    ben_prv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_prv_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_prv_shd.g_rec_type) is
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
Procedure post_delete(p_rec in ben_prv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    ben_prv_rkd.after_delete
      (
  p_prtt_rt_val_id                =>p_rec.prtt_rt_val_id
 ,p_rt_strt_dt_o                  =>ben_prv_shd.g_old_rec.rt_strt_dt
 ,p_rt_end_dt_o                   =>ben_prv_shd.g_old_rec.rt_end_dt
 ,p_rt_typ_cd_o                   =>ben_prv_shd.g_old_rec.rt_typ_cd
 ,p_tx_typ_cd_o                   =>ben_prv_shd.g_old_rec.tx_typ_cd
 ,p_ordr_num_o			  =>ben_prv_shd.g_old_rec.ordr_num
 ,p_acty_typ_cd_o                 =>ben_prv_shd.g_old_rec.acty_typ_cd
 ,p_mlt_cd_o                      =>ben_prv_shd.g_old_rec.mlt_cd
 ,p_acty_ref_perd_cd_o            =>ben_prv_shd.g_old_rec.acty_ref_perd_cd
 ,p_rt_val_o                      =>ben_prv_shd.g_old_rec.rt_val
 ,p_ann_rt_val_o                  =>ben_prv_shd.g_old_rec.ann_rt_val
 ,p_cmcd_rt_val_o                 =>ben_prv_shd.g_old_rec.cmcd_rt_val
 ,p_cmcd_ref_perd_cd_o            =>ben_prv_shd.g_old_rec.cmcd_ref_perd_cd
 ,p_bnft_rt_typ_cd_o              =>ben_prv_shd.g_old_rec.bnft_rt_typ_cd
 ,p_dsply_on_enrt_flag_o          =>ben_prv_shd.g_old_rec.dsply_on_enrt_flag
 ,p_rt_ovridn_flag_o              =>ben_prv_shd.g_old_rec.rt_ovridn_flag
 ,p_rt_ovridn_thru_dt_o           =>ben_prv_shd.g_old_rec.rt_ovridn_thru_dt
 ,p_elctns_made_dt_o              =>ben_prv_shd.g_old_rec.elctns_made_dt
 ,p_prtt_rt_val_stat_cd_o         =>ben_prv_shd.g_old_rec.prtt_rt_val_stat_cd
 ,p_prtt_enrt_rslt_id_o           =>ben_prv_shd.g_old_rec.prtt_enrt_rslt_id
 ,p_cvg_amt_calc_mthd_id_o        =>ben_prv_shd.g_old_rec.cvg_amt_calc_mthd_id
 ,p_actl_prem_id_o                =>ben_prv_shd.g_old_rec.actl_prem_id
 ,p_comp_lvl_fctr_id_o            =>ben_prv_shd.g_old_rec.comp_lvl_fctr_id
 ,p_element_entry_value_id_o      =>ben_prv_shd.g_old_rec.element_entry_value_id
 ,p_per_in_ler_id_o               =>ben_prv_shd.g_old_rec.per_in_ler_id
 ,p_ended_per_in_ler_id_o         =>ben_prv_shd.g_old_rec.ended_per_in_ler_id
 ,p_acty_base_rt_id_o             =>ben_prv_shd.g_old_rec.acty_base_rt_id
 ,p_prtt_reimbmt_rqst_id_o        =>ben_prv_shd.g_old_rec.prtt_reimbmt_rqst_id
 ,p_prtt_rmt_aprvd_fr_pymt_id_o   =>ben_prv_shd.g_old_rec.prtt_rmt_aprvd_fr_pymt_id
 ,p_pp_in_yr_used_num_o           =>ben_prv_shd.g_old_rec.pp_in_yr_used_num
 ,p_business_group_id_o           =>ben_prv_shd.g_old_rec.business_group_id
 ,p_prv_attribute_category_o      =>ben_prv_shd.g_old_rec.prv_attribute_category
 ,p_prv_attribute1_o              =>ben_prv_shd.g_old_rec.prv_attribute1
 ,p_prv_attribute2_o              =>ben_prv_shd.g_old_rec.prv_attribute2
 ,p_prv_attribute3_o              =>ben_prv_shd.g_old_rec.prv_attribute3
 ,p_prv_attribute4_o              =>ben_prv_shd.g_old_rec.prv_attribute4
 ,p_prv_attribute5_o              =>ben_prv_shd.g_old_rec.prv_attribute5
 ,p_prv_attribute6_o              =>ben_prv_shd.g_old_rec.prv_attribute6
 ,p_prv_attribute7_o              =>ben_prv_shd.g_old_rec.prv_attribute7
 ,p_prv_attribute8_o              =>ben_prv_shd.g_old_rec.prv_attribute8
 ,p_prv_attribute9_o              =>ben_prv_shd.g_old_rec.prv_attribute9
 ,p_prv_attribute10_o             =>ben_prv_shd.g_old_rec.prv_attribute10
 ,p_prv_attribute11_o             =>ben_prv_shd.g_old_rec.prv_attribute11
 ,p_prv_attribute12_o             =>ben_prv_shd.g_old_rec.prv_attribute12
 ,p_prv_attribute13_o             =>ben_prv_shd.g_old_rec.prv_attribute13
 ,p_prv_attribute14_o             =>ben_prv_shd.g_old_rec.prv_attribute14
 ,p_prv_attribute15_o             =>ben_prv_shd.g_old_rec.prv_attribute15
 ,p_prv_attribute16_o             =>ben_prv_shd.g_old_rec.prv_attribute16
 ,p_prv_attribute17_o             =>ben_prv_shd.g_old_rec.prv_attribute17
 ,p_prv_attribute18_o             =>ben_prv_shd.g_old_rec.prv_attribute18
 ,p_prv_attribute19_o             =>ben_prv_shd.g_old_rec.prv_attribute19
 ,p_prv_attribute20_o             =>ben_prv_shd.g_old_rec.prv_attribute20
 ,p_prv_attribute21_o             =>ben_prv_shd.g_old_rec.prv_attribute21
 ,p_prv_attribute22_o             =>ben_prv_shd.g_old_rec.prv_attribute22
 ,p_prv_attribute23_o             =>ben_prv_shd.g_old_rec.prv_attribute23
 ,p_prv_attribute24_o             =>ben_prv_shd.g_old_rec.prv_attribute24
 ,p_prv_attribute25_o             =>ben_prv_shd.g_old_rec.prv_attribute25
 ,p_prv_attribute26_o             =>ben_prv_shd.g_old_rec.prv_attribute26
 ,p_prv_attribute27_o             =>ben_prv_shd.g_old_rec.prv_attribute27
 ,p_prv_attribute28_o             =>ben_prv_shd.g_old_rec.prv_attribute28
 ,p_prv_attribute29_o             =>ben_prv_shd.g_old_rec.prv_attribute29
 ,p_prv_attribute30_o             =>ben_prv_shd.g_old_rec.prv_attribute30
 ,p_pk_id_table_name_o            =>ben_prv_shd.g_old_rec.pk_id_table_name
 ,p_pk_id_o                       =>ben_prv_shd.g_old_rec.pk_id
 ,p_object_version_number_o       =>ben_prv_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_prtt_rt_val'
        ,p_hook_type   => 'AD');
      --
  end;
  --
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
  p_rec	      in ben_prv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_prv_shd.lck
	(
	p_rec.prtt_rt_val_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_prv_bus.delete_validate(p_rec);
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
  p_prtt_rt_val_id                     in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_prv_shd.g_rec_type;
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
  l_rec.prtt_rt_val_id:= p_prtt_rt_val_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_prv_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_prv_del;

/
