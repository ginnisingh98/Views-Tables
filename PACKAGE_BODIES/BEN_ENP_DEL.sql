--------------------------------------------------------
--  DDL for Package Body BEN_ENP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENP_DEL" as
/* $Header: beenprhi.pkb 120.1.12000000.3 2007/05/13 22:36:53 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_enp_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ben_enp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_enp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_enrt_perd row.
  --
  delete from ben_enrt_perd
  where enrt_perd_id = p_rec.enrt_perd_id;
  --
  ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_enp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_enp_shd.g_rec_type) is
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
p_effective_date in date,p_rec in ben_enp_shd.g_rec_type) is
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
    ben_enp_rkd.after_delete
      (
  p_enrt_perd_id                  =>p_rec.enrt_perd_id
 ,p_business_group_id_o           =>ben_enp_shd.g_old_rec.business_group_id
 ,p_yr_perd_id_o                  =>ben_enp_shd.g_old_rec.yr_perd_id
 ,p_popl_enrt_typ_cycl_id_o       =>ben_enp_shd.g_old_rec.popl_enrt_typ_cycl_id
 ,p_end_dt_o                      =>ben_enp_shd.g_old_rec.end_dt
 ,p_strt_dt_o                     =>ben_enp_shd.g_old_rec.strt_dt
 ,p_asnd_lf_evt_dt_o              =>ben_enp_shd.g_old_rec.asnd_lf_evt_dt
 ,p_cls_enrt_dt_to_use_cd_o       =>ben_enp_shd.g_old_rec.cls_enrt_dt_to_use_cd
 ,p_dflt_enrt_dt_o                =>ben_enp_shd.g_old_rec.dflt_enrt_dt
 ,p_enrt_cvg_strt_dt_cd_o         =>ben_enp_shd.g_old_rec.enrt_cvg_strt_dt_cd
 ,p_rt_strt_dt_rl_o               =>ben_enp_shd.g_old_rec.rt_strt_dt_rl
 ,p_enrt_cvg_end_dt_cd_o          =>ben_enp_shd.g_old_rec.enrt_cvg_end_dt_cd
 ,p_enrt_cvg_strt_dt_rl_o         =>ben_enp_shd.g_old_rec.enrt_cvg_strt_dt_rl
 ,p_enrt_cvg_end_dt_rl_o          =>ben_enp_shd.g_old_rec.enrt_cvg_end_dt_rl
 ,p_procg_end_dt_o                =>ben_enp_shd.g_old_rec.procg_end_dt
 ,p_rt_strt_dt_cd_o               =>ben_enp_shd.g_old_rec.rt_strt_dt_cd
 ,p_rt_end_dt_cd_o                =>ben_enp_shd.g_old_rec.rt_end_dt_cd
 ,p_rt_end_dt_rl_o                =>ben_enp_shd.g_old_rec.rt_end_dt_rl
 ,p_bdgt_upd_strt_dt_o            =>ben_enp_shd.g_old_rec.bdgt_upd_strt_dt
 ,p_bdgt_upd_end_dt_o             =>ben_enp_shd.g_old_rec.bdgt_upd_end_dt
 ,p_ws_upd_strt_dt_o              =>ben_enp_shd.g_old_rec.ws_upd_strt_dt
 ,p_ws_upd_end_dt_o               =>ben_enp_shd.g_old_rec.ws_upd_end_dt
 ,p_dflt_ws_acc_cd_o              =>ben_enp_shd.g_old_rec.dflt_ws_acc_cd
 ,p_prsvr_bdgt_cd_o               =>ben_enp_shd.g_old_rec.prsvr_bdgt_cd
 ,p_uses_bdgt_flag_o              =>ben_enp_shd.g_old_rec.uses_bdgt_flag
 ,p_auto_distr_flag_o             =>ben_enp_shd.g_old_rec.auto_distr_flag
 ,p_hrchy_to_use_cd_o             =>ben_enp_shd.g_old_rec.hrchy_to_use_cd
 ,p_pos_structure_version_id_o       =>ben_enp_shd.g_old_rec.pos_structure_version_id
 ,p_emp_interview_type_cd_o       =>ben_enp_shd.g_old_rec.emp_interview_type_cd
 ,p_wthn_yr_perd_id_o             =>ben_enp_shd.g_old_rec.wthn_yr_perd_id
 ,p_ler_id_o                      =>ben_enp_shd.g_old_rec.ler_id
 ,p_perf_revw_strt_dt_o           =>ben_enp_shd.g_old_rec.perf_revw_strt_dt
 ,p_asg_updt_eff_date_o           =>ben_enp_shd.g_old_rec.asg_updt_eff_date
 ,p_enp_attribute_category_o      =>ben_enp_shd.g_old_rec.enp_attribute_category
 ,p_enp_attribute1_o              =>ben_enp_shd.g_old_rec.enp_attribute1
 ,p_enp_attribute2_o              =>ben_enp_shd.g_old_rec.enp_attribute2
 ,p_enp_attribute3_o              =>ben_enp_shd.g_old_rec.enp_attribute3
 ,p_enp_attribute4_o              =>ben_enp_shd.g_old_rec.enp_attribute4
 ,p_enp_attribute5_o              =>ben_enp_shd.g_old_rec.enp_attribute5
 ,p_enp_attribute6_o              =>ben_enp_shd.g_old_rec.enp_attribute6
 ,p_enp_attribute7_o              =>ben_enp_shd.g_old_rec.enp_attribute7
 ,p_enp_attribute8_o              =>ben_enp_shd.g_old_rec.enp_attribute8
 ,p_enp_attribute9_o              =>ben_enp_shd.g_old_rec.enp_attribute9
 ,p_enp_attribute10_o             =>ben_enp_shd.g_old_rec.enp_attribute10
 ,p_enp_attribute11_o             =>ben_enp_shd.g_old_rec.enp_attribute11
 ,p_enp_attribute12_o             =>ben_enp_shd.g_old_rec.enp_attribute12
 ,p_enp_attribute13_o             =>ben_enp_shd.g_old_rec.enp_attribute13
 ,p_enp_attribute14_o             =>ben_enp_shd.g_old_rec.enp_attribute14
 ,p_enp_attribute15_o             =>ben_enp_shd.g_old_rec.enp_attribute15
 ,p_enp_attribute16_o             =>ben_enp_shd.g_old_rec.enp_attribute16
 ,p_enp_attribute17_o             =>ben_enp_shd.g_old_rec.enp_attribute17
 ,p_enp_attribute18_o             =>ben_enp_shd.g_old_rec.enp_attribute18
 ,p_enp_attribute19_o             =>ben_enp_shd.g_old_rec.enp_attribute19
 ,p_enp_attribute20_o             =>ben_enp_shd.g_old_rec.enp_attribute20
 ,p_enp_attribute21_o             =>ben_enp_shd.g_old_rec.enp_attribute21
 ,p_enp_attribute22_o             =>ben_enp_shd.g_old_rec.enp_attribute22
 ,p_enp_attribute23_o             =>ben_enp_shd.g_old_rec.enp_attribute23
 ,p_enp_attribute24_o             =>ben_enp_shd.g_old_rec.enp_attribute24
 ,p_enp_attribute25_o             =>ben_enp_shd.g_old_rec.enp_attribute25
 ,p_enp_attribute26_o             =>ben_enp_shd.g_old_rec.enp_attribute26
 ,p_enp_attribute27_o             =>ben_enp_shd.g_old_rec.enp_attribute27
 ,p_enp_attribute28_o             =>ben_enp_shd.g_old_rec.enp_attribute28
 ,p_enp_attribute29_o             =>ben_enp_shd.g_old_rec.enp_attribute29
 ,p_enp_attribute30_o             =>ben_enp_shd.g_old_rec.enp_attribute30
 --,p_enrt_perd_det_ovrlp_bckdt_cd_o=>ben_enp_shd.g_old_rec.enrt_perd_det_ovrlp_bckdt_cd
 ,p_enrt_perd_det_ovrlp_cd_o      =>ben_enp_shd.g_old_rec.enrt_perd_det_ovrlp_bckdt_cd
 --cwb
 ,p_data_freeze_date_o             =>ben_enp_shd.g_old_rec.data_freeze_date
 ,p_Sal_chg_reason_cd_o            =>ben_enp_shd.g_old_rec.Sal_chg_reason_cd
 ,p_Approval_mode_cd_o             =>ben_enp_shd.g_old_rec.Approval_mode_cd
 ,p_hrchy_ame_trn_cd_o             =>ben_enp_shd.g_old_rec.hrchy_ame_trn_cd
 ,p_hrchy_rl_o                     =>ben_enp_shd.g_old_rec.hrchy_rl
 ,p_hrchy_ame_app_id_o             =>ben_enp_shd.g_old_rec.hrchy_ame_app_id
 --
 ,p_object_version_number_o       =>ben_enp_shd.g_old_rec.object_version_number
 ,p_reinstate_cd_o					=> ben_enp_shd.g_old_rec.reinstate_cd
 ,p_reinstate_ovrdn_cd_o			=>  ben_enp_shd.g_old_rec.reinstate_ovrdn_cd
 ,p_defer_deenrol_flag_o		  =>  ben_enp_shd.g_old_rec.defer_deenrol_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_enrt_perd'
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
  p_rec	      in ben_enp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_enp_shd.lck
	(
	p_rec.enrt_perd_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_enp_bus.delete_validate(p_rec
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
  p_enrt_perd_id                       in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_enp_shd.g_rec_type;
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
  l_rec.enrt_perd_id:= p_enrt_perd_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_enp_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_enp_del;

/
