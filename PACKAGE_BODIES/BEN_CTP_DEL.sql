--------------------------------------------------------
--  DDL for Package Body BEN_CTP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CTP_DEL" as
/* $Header: bectprhi.pkb 120.0 2005/05/28 01:26:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ctp_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   3) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   4) To raise any errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
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
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
	(p_rec 			 in out nocopy ben_ctp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    ben_ctp_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from ben_ptip_f
    where       ptip_id = p_rec.ptip_id
    and	  effective_start_date = p_validation_start_date;
    --
    ben_ctp_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    ben_ctp_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from ben_ptip_f
    where        ptip_id = p_rec.ptip_id
    and	  effective_start_date >= p_validation_start_date;
    --
    ben_ctp_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    ben_ctp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
	(p_rec 			 in out nocopy ben_ctp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Prerequisites:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
	(p_rec 			 in out nocopy ben_ctp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> 'ZAP') then
    --
    p_rec.effective_start_date := ben_ctp_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    ben_ctp_shd.upd_effective_end_date
      (p_effective_date	        => p_effective_date,
       p_base_key_value	        => p_rec.ptip_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date,
       p_object_version_number  => p_rec.object_version_number);
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End dt_pre_delete;
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
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
	(p_rec 			 in out nocopy ben_ctp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_delete
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
	(p_rec 			 in ben_ctp_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    ben_ctp_rkd.after_delete
      (
  p_ptip_id                       =>p_rec.ptip_id
 ,p_datetrack_mode                =>p_datetrack_mode
 ,p_validation_start_date         =>p_validation_start_date
 ,p_validation_end_date           =>p_validation_end_date
 ,p_effective_start_date          =>p_rec.effective_start_date
 ,p_effective_end_date            =>p_rec.effective_end_date
 ,p_effective_start_date_o        =>ben_ctp_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o          =>ben_ctp_shd.g_old_rec.effective_end_date
 ,p_coord_cvg_for_all_pls_flag_o  =>ben_ctp_shd.g_old_rec.coord_cvg_for_all_pls_flag
 ,p_dpnt_dsgn_cd_o                =>ben_ctp_shd.g_old_rec.dpnt_dsgn_cd
 ,p_dpnt_cvg_strt_dt_rl_o         =>ben_ctp_shd.g_old_rec.dpnt_cvg_strt_dt_rl
 ,p_dpnt_cvg_end_dt_rl_o          =>ben_ctp_shd.g_old_rec.dpnt_cvg_end_dt_rl
 ,p_postelcn_edit_rl_o            =>ben_ctp_shd.g_old_rec.postelcn_edit_rl
 ,p_rt_end_dt_rl_o                =>ben_ctp_shd.g_old_rec.rt_end_dt_rl
 ,p_rt_strt_dt_rl_o               =>ben_ctp_shd.g_old_rec.rt_strt_dt_rl
 ,p_enrt_cvg_end_dt_rl_o          =>ben_ctp_shd.g_old_rec.enrt_cvg_end_dt_rl
 ,p_enrt_cvg_strt_dt_rl_o         =>ben_ctp_shd.g_old_rec.enrt_cvg_strt_dt_rl
 ,p_rqd_perd_enrt_nenrt_rl_o      =>ben_ctp_shd.g_old_rec.rqd_perd_enrt_nenrt_rl
 ,p_auto_enrt_mthd_rl_o           =>ben_ctp_shd.g_old_rec.auto_enrt_mthd_rl
 ,p_enrt_mthd_cd_o                =>ben_ctp_shd.g_old_rec.enrt_mthd_cd
 ,p_enrt_cd_o                     =>ben_ctp_shd.g_old_rec.enrt_cd
 ,p_enrt_rl_o                     =>ben_ctp_shd.g_old_rec.enrt_rl
 ,p_dflt_enrt_cd_o                =>ben_ctp_shd.g_old_rec.dflt_enrt_cd
 ,p_dflt_enrt_det_rl_o            =>ben_ctp_shd.g_old_rec.dflt_enrt_det_rl
 ,p_drvbl_fctr_apls_rts_flag_o    =>ben_ctp_shd.g_old_rec.drvbl_fctr_apls_rts_flag
 ,p_drvbl_fctr_prtn_elig_flag_o   =>ben_ctp_shd.g_old_rec.drvbl_fctr_prtn_elig_flag
 ,p_elig_apls_flag_o              =>ben_ctp_shd.g_old_rec.elig_apls_flag
 ,p_prtn_elig_ovrid_alwd_flag_o   =>ben_ctp_shd.g_old_rec.prtn_elig_ovrid_alwd_flag
 ,p_trk_inelig_per_flag_o         =>ben_ctp_shd.g_old_rec.trk_inelig_per_flag
 ,p_dpnt_cvg_strt_dt_cd_o         =>ben_ctp_shd.g_old_rec.dpnt_cvg_strt_dt_cd
 ,p_rt_end_dt_cd_o                =>ben_ctp_shd.g_old_rec.rt_end_dt_cd
 ,p_rt_strt_dt_cd_o               =>ben_ctp_shd.g_old_rec.rt_strt_dt_cd
 ,p_enrt_cvg_end_dt_cd_o          =>ben_ctp_shd.g_old_rec.enrt_cvg_end_dt_cd
 ,p_enrt_cvg_strt_dt_cd_o         =>ben_ctp_shd.g_old_rec.enrt_cvg_strt_dt_cd
 ,p_dpnt_cvg_end_dt_cd_o          =>ben_ctp_shd.g_old_rec.dpnt_cvg_end_dt_cd
 ,p_crs_this_pl_typ_only_flag_o   =>ben_ctp_shd.g_old_rec.crs_this_pl_typ_only_flag
 ,p_ptip_stat_cd_o                =>ben_ctp_shd.g_old_rec.ptip_stat_cd
 ,p_mx_cvg_alwd_amt_o             =>ben_ctp_shd.g_old_rec.mx_cvg_alwd_amt
 ,p_mx_enrd_alwd_ovrid_num_o      =>ben_ctp_shd.g_old_rec.mx_enrd_alwd_ovrid_num
 ,p_mn_enrd_rqd_ovrid_num_o       =>ben_ctp_shd.g_old_rec.mn_enrd_rqd_ovrid_num
 ,p_no_mx_pl_typ_ovrid_flag_o     =>ben_ctp_shd.g_old_rec.no_mx_pl_typ_ovrid_flag
 ,p_ordr_num_o                    =>ben_ctp_shd.g_old_rec.ordr_num
 ,p_prvds_cr_flag_o               =>ben_ctp_shd.g_old_rec.prvds_cr_flag
 ,p_rqd_perd_enrt_nenrt_val_o     =>ben_ctp_shd.g_old_rec.rqd_perd_enrt_nenrt_val
 ,p_rqd_perd_enrt_nenrt_tm_uom_o  =>ben_ctp_shd.g_old_rec.rqd_perd_enrt_nenrt_tm_uom
 ,p_wvbl_flag_o                   =>ben_ctp_shd.g_old_rec.wvbl_flag
 ,p_dpnt_adrs_rqd_flag_o          =>ben_ctp_shd.g_old_rec.dpnt_adrs_rqd_flag
 ,p_dpnt_cvg_no_ctfn_rqd_flag_o   =>ben_ctp_shd.g_old_rec.dpnt_cvg_no_ctfn_rqd_flag
 ,p_dpnt_dob_rqd_flag_o           =>ben_ctp_shd.g_old_rec.dpnt_dob_rqd_flag
 ,p_dpnt_legv_id_rqd_flag_o       =>ben_ctp_shd.g_old_rec.dpnt_legv_id_rqd_flag
 ,p_susp_if_dpnt_ssn_nt_prv_cd_o  =>ben_pln_shd.g_old_rec.susp_if_dpnt_ssn_nt_prv_cd
 ,p_susp_if_dpnt_dob_nt_prv_cd_o  =>ben_pln_shd.g_old_rec.susp_if_dpnt_dob_nt_prv_cd
 ,p_susp_if_dpnt_adr_nt_prv_cd_o  =>ben_pln_shd.g_old_rec.susp_if_dpnt_adr_nt_prv_cd
 ,p_susp_if_ctfn_not_dpnt_flag_o  =>ben_pln_shd.g_old_rec.susp_if_ctfn_not_dpnt_flag
 ,p_dpnt_ctfn_determine_cd_o      =>ben_pln_shd.g_old_rec.dpnt_ctfn_determine_cd
 ,p_drvd_fctr_dpnt_cvg_flag_o     =>ben_ctp_shd.g_old_rec.drvd_fctr_dpnt_cvg_flag
 ,p_no_mn_pl_typ_overid_flag_o    =>ben_ctp_shd.g_old_rec.no_mn_pl_typ_overid_flag
 ,p_sbj_to_sps_lf_ins_mx_flag_o =>ben_ctp_shd.g_old_rec.sbj_to_sps_lf_ins_mx_flag
 ,p_sbj_to_dpnt_lf_ins_mx_flag_o =>ben_ctp_shd.g_old_rec.sbj_to_dpnt_lf_ins_mx_flag
 ,p_use_to_sum_ee_lf_ins_flag_o   =>ben_ctp_shd.g_old_rec.use_to_sum_ee_lf_ins_flag
 ,p_per_cvrd_cd_o                 =>ben_ctp_shd.g_old_rec.per_cvrd_cd
 ,p_short_name_o                 =>ben_ctp_shd.g_old_rec.short_name
 ,p_short_code_o                 =>ben_ctp_shd.g_old_rec.short_code
  ,p_legislation_code_o                 =>ben_ctp_shd.g_old_rec.legislation_code
  ,p_legislation_subgroup_o                 =>ben_ctp_shd.g_old_rec.legislation_subgroup
 ,p_vrfy_fmly_mmbr_cd_o           =>ben_ctp_shd.g_old_rec.vrfy_fmly_mmbr_cd
 ,p_vrfy_fmly_mmbr_rl_o           =>ben_ctp_shd.g_old_rec.vrfy_fmly_mmbr_rl
 ,p_ivr_ident_o                   =>ben_ctp_shd.g_old_rec.ivr_ident
 ,p_url_ref_name_o                =>ben_ctp_shd.g_old_rec.url_ref_name
 ,p_rqd_enrt_perd_tco_cd_o        =>ben_ctp_shd.g_old_rec.rqd_enrt_perd_tco_cd
 ,p_pgm_id_o                      =>ben_ctp_shd.g_old_rec.pgm_id
 ,p_pl_typ_id_o                   =>ben_ctp_shd.g_old_rec.pl_typ_id
 ,p_cmbn_ptip_id_o                =>ben_ctp_shd.g_old_rec.cmbn_ptip_id
 ,p_cmbn_ptip_opt_id_o            =>ben_ctp_shd.g_old_rec.cmbn_ptip_opt_id
 ,p_acrs_ptip_cvg_id_o            =>ben_ctp_shd.g_old_rec.acrs_ptip_cvg_id
 ,p_business_group_id_o           =>ben_ctp_shd.g_old_rec.business_group_id
 ,p_ctp_attribute_category_o      =>ben_ctp_shd.g_old_rec.ctp_attribute_category
 ,p_ctp_attribute1_o              =>ben_ctp_shd.g_old_rec.ctp_attribute1
 ,p_ctp_attribute2_o              =>ben_ctp_shd.g_old_rec.ctp_attribute2
 ,p_ctp_attribute3_o              =>ben_ctp_shd.g_old_rec.ctp_attribute3
 ,p_ctp_attribute4_o              =>ben_ctp_shd.g_old_rec.ctp_attribute4
 ,p_ctp_attribute5_o              =>ben_ctp_shd.g_old_rec.ctp_attribute5
 ,p_ctp_attribute6_o              =>ben_ctp_shd.g_old_rec.ctp_attribute6
 ,p_ctp_attribute7_o              =>ben_ctp_shd.g_old_rec.ctp_attribute7
 ,p_ctp_attribute8_o              =>ben_ctp_shd.g_old_rec.ctp_attribute8
 ,p_ctp_attribute9_o              =>ben_ctp_shd.g_old_rec.ctp_attribute9
 ,p_ctp_attribute10_o             =>ben_ctp_shd.g_old_rec.ctp_attribute10
 ,p_ctp_attribute11_o             =>ben_ctp_shd.g_old_rec.ctp_attribute11
 ,p_ctp_attribute12_o             =>ben_ctp_shd.g_old_rec.ctp_attribute12
 ,p_ctp_attribute13_o             =>ben_ctp_shd.g_old_rec.ctp_attribute13
 ,p_ctp_attribute14_o             =>ben_ctp_shd.g_old_rec.ctp_attribute14
 ,p_ctp_attribute15_o             =>ben_ctp_shd.g_old_rec.ctp_attribute15
 ,p_ctp_attribute16_o             =>ben_ctp_shd.g_old_rec.ctp_attribute16
 ,p_ctp_attribute17_o             =>ben_ctp_shd.g_old_rec.ctp_attribute17
 ,p_ctp_attribute18_o             =>ben_ctp_shd.g_old_rec.ctp_attribute18
 ,p_ctp_attribute19_o             =>ben_ctp_shd.g_old_rec.ctp_attribute19
 ,p_ctp_attribute20_o             =>ben_ctp_shd.g_old_rec.ctp_attribute20
 ,p_ctp_attribute21_o             =>ben_ctp_shd.g_old_rec.ctp_attribute21
 ,p_ctp_attribute22_o             =>ben_ctp_shd.g_old_rec.ctp_attribute22
 ,p_ctp_attribute23_o             =>ben_ctp_shd.g_old_rec.ctp_attribute23
 ,p_ctp_attribute24_o             =>ben_ctp_shd.g_old_rec.ctp_attribute24
 ,p_ctp_attribute25_o             =>ben_ctp_shd.g_old_rec.ctp_attribute25
 ,p_ctp_attribute26_o             =>ben_ctp_shd.g_old_rec.ctp_attribute26
 ,p_ctp_attribute27_o             =>ben_ctp_shd.g_old_rec.ctp_attribute27
 ,p_ctp_attribute28_o             =>ben_ctp_shd.g_old_rec.ctp_attribute28
 ,p_ctp_attribute29_o             =>ben_ctp_shd.g_old_rec.ctp_attribute29
 ,p_ctp_attribute30_o             =>ben_ctp_shd.g_old_rec.ctp_attribute30
 ,p_object_version_number_o       =>ben_ctp_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ptip_f'
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
  p_rec			in out nocopy 	ben_ctp_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  ) is
--
  l_proc			varchar2(72) := g_package||'del';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to delete.
  --
  ben_ctp_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_ptip_id	 => p_rec.ptip_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  ben_ctp_bus.delete_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  post_delete
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_ptip_id	  in 	 number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date	     out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date	  in     date,
  p_datetrack_mode  	  in     varchar2
  ) is
--
  l_rec		ben_ctp_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.ptip_id		:= p_ptip_id;
  l_rec.object_version_number 	:= p_object_version_number;
  --
  -- Having converted the arguments into the ben_ctp_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode);
  --
  -- Set the out arguments
  --
  p_object_version_number := l_rec.object_version_number;
  p_effective_start_date  := l_rec.effective_start_date;
  p_effective_end_date    := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_ctp_del;

/
