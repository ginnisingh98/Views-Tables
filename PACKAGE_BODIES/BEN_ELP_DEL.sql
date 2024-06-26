--------------------------------------------------------
--  DDL for Package Body BEN_ELP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELP_DEL" as
/* $Header: beelprhi.pkb 120.5 2007/01/24 05:18:55 rgajula ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_elp_del.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_elp_shd.g_rec_type,
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
    ben_elp_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from ben_eligy_prfl_f
    where       eligy_prfl_id = p_rec.eligy_prfl_id
    and	  effective_start_date = p_validation_start_date;
    --
    ben_elp_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    ben_elp_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from ben_eligy_prfl_f
    where        eligy_prfl_id = p_rec.eligy_prfl_id
    and	  effective_start_date >= p_validation_start_date;
    --
    ben_elp_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    ben_elp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
	(p_rec 			 in out nocopy ben_elp_shd.g_rec_type,
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
	(p_rec 			 in out nocopy ben_elp_shd.g_rec_type,
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
    p_rec.effective_start_date := ben_elp_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    ben_elp_shd.upd_effective_end_date
      (p_effective_date	        => p_effective_date,
       p_base_key_value	        => p_rec.eligy_prfl_id,
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
	(p_rec 			 in out nocopy ben_elp_shd.g_rec_type,
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
	(p_rec 			 in ben_elp_shd.g_rec_type,
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
    ben_elp_rkd.after_delete
      (p_eligy_prfl_id            =>p_rec.eligy_prfl_id
      ,p_datetrack_mode           =>p_datetrack_mode
      ,p_validation_start_date    =>p_validation_start_date
      ,p_validation_end_date      =>p_validation_end_date
      ,p_effective_start_date     =>p_rec.effective_start_date
      ,p_effective_end_date       =>p_rec.effective_end_date
      ,p_effective_start_date_o   =>ben_elp_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o     =>ben_elp_shd.g_old_rec.effective_end_date
      ,p_name_o                   =>ben_elp_shd.g_old_rec.name
      ,p_description_o            =>ben_elp_shd.g_old_rec.description
      ,p_stat_cd_o                =>ben_elp_shd.g_old_rec.stat_cd
      ,p_asmt_to_use_cd_o         =>ben_elp_shd.g_old_rec.asmt_to_use_cd
      ,p_elig_enrld_plip_flag_o   =>ben_elp_shd.g_old_rec.elig_enrld_plip_flag
      ,p_elig_cbr_quald_bnf_flag_o=>ben_elp_shd.g_old_rec.elig_cbr_quald_bnf_flag
      ,p_elig_enrld_ptip_flag_o   =>ben_elp_shd.g_old_rec.elig_enrld_ptip_flag
      ,p_elig_dpnt_cvrd_plip_flag_o=>ben_elp_shd.g_old_rec.elig_dpnt_cvrd_plip_flag
      ,p_elig_dpnt_cvrd_ptip_flag_o=>ben_elp_shd.g_old_rec.elig_dpnt_cvrd_ptip_flag
      ,p_elig_dpnt_cvrd_pgm_flag_o=>ben_elp_shd.g_old_rec.elig_dpnt_cvrd_pgm_flag
      ,p_elig_job_flag_o          =>ben_elp_shd.g_old_rec.elig_job_flag
      ,p_elig_hrly_slrd_flag_o    =>ben_elp_shd.g_old_rec.elig_hrly_slrd_flag
      ,p_elig_pstl_cd_flag_o      =>ben_elp_shd.g_old_rec.elig_pstl_cd_flag
      ,p_elig_lbr_mmbr_flag_o     =>ben_elp_shd.g_old_rec.elig_lbr_mmbr_flag
      ,p_elig_lgl_enty_flag_o     =>ben_elp_shd.g_old_rec.elig_lgl_enty_flag
      ,p_elig_benfts_grp_flag_o   =>ben_elp_shd.g_old_rec.elig_benfts_grp_flag
      ,p_elig_wk_loc_flag_o       =>ben_elp_shd.g_old_rec.elig_wk_loc_flag
      ,p_elig_brgng_unit_flag_o   =>ben_elp_shd.g_old_rec.elig_brgng_unit_flag
      ,p_elig_age_flag_o          =>ben_elp_shd.g_old_rec.elig_age_flag
      ,p_elig_los_flag_o          =>ben_elp_shd.g_old_rec.elig_los_flag
      ,p_elig_per_typ_flag_o      =>ben_elp_shd.g_old_rec.elig_per_typ_flag
      ,p_elig_fl_tm_pt_tm_flag_o  =>ben_elp_shd.g_old_rec.elig_fl_tm_pt_tm_flag
      ,p_elig_ee_stat_flag_o      =>ben_elp_shd.g_old_rec.elig_ee_stat_flag
      ,p_elig_grd_flag_o          =>ben_elp_shd.g_old_rec.elig_grd_flag
      ,p_elig_pct_fl_tm_flag_o    =>ben_elp_shd.g_old_rec.elig_pct_fl_tm_flag
      ,p_elig_asnt_set_flag_o     =>ben_elp_shd.g_old_rec.elig_asnt_set_flag
      ,p_elig_hrs_wkd_flag_o      =>ben_elp_shd.g_old_rec.elig_hrs_wkd_flag
      ,p_elig_comp_lvl_flag_o     =>ben_elp_shd.g_old_rec.elig_comp_lvl_flag
      ,p_elig_org_unit_flag_o     =>ben_elp_shd.g_old_rec.elig_org_unit_flag
      ,p_elig_loa_rsn_flag_o      =>ben_elp_shd.g_old_rec.elig_loa_rsn_flag
      ,p_elig_pyrl_flag_o         =>ben_elp_shd.g_old_rec.elig_pyrl_flag
      ,p_elig_schedd_hrs_flag_o   =>ben_elp_shd.g_old_rec.elig_schedd_hrs_flag
      ,p_elig_py_bss_flag_o       =>ben_elp_shd.g_old_rec.elig_py_bss_flag
      ,p_eligy_prfl_rl_flag_o     =>ben_elp_shd.g_old_rec.eligy_prfl_rl_flag
      ,p_elig_cmbn_age_los_flag_o =>ben_elp_shd.g_old_rec.elig_cmbn_age_los_flag
      ,p_cntng_prtn_elig_prfl_flag_o=>ben_elp_shd.g_old_rec.cntng_prtn_elig_prfl_flag
      ,p_elig_prtt_pl_flag_o      =>ben_elp_shd.g_old_rec.elig_prtt_pl_flag
      ,p_elig_ppl_grp_flag_o      =>ben_elp_shd.g_old_rec.elig_ppl_grp_flag
      ,p_elig_svc_area_flag_o     =>ben_elp_shd.g_old_rec.elig_svc_area_flag
      ,p_elig_ptip_prte_flag_o    =>ben_elp_shd.g_old_rec.elig_ptip_prte_flag
      ,p_elig_no_othr_cvg_flag_o  =>ben_elp_shd.g_old_rec.elig_no_othr_cvg_flag
      ,p_elig_enrld_pl_flag_o     =>ben_elp_shd.g_old_rec.elig_enrld_pl_flag
      ,p_elig_enrld_oipl_flag_o   =>ben_elp_shd.g_old_rec.elig_enrld_oipl_flag
      ,p_elig_enrld_pgm_flag_o    =>ben_elp_shd.g_old_rec.elig_enrld_pgm_flag
      ,p_elig_dpnt_cvrd_pl_flag_o =>ben_elp_shd.g_old_rec.elig_dpnt_cvrd_pl_flag
      ,p_elig_lvg_rsn_flag_o      =>ben_elp_shd.g_old_rec.elig_lvg_rsn_flag
      ,p_elig_optd_mdcr_flag_o    =>ben_elp_shd.g_old_rec.elig_optd_mdcr_flag
      ,p_elig_tbco_use_flag_o     =>ben_elp_shd.g_old_rec.elig_tbco_use_flag
      ,p_elig_dpnt_othr_ptip_flag_o =>ben_elp_shd.g_old_rec.elig_dpnt_othr_ptip_flag
      ,p_business_group_id_o      =>ben_elp_shd.g_old_rec.business_group_id
      ,p_elp_attribute_category_o =>ben_elp_shd.g_old_rec.elp_attribute_category
      ,p_elp_attribute1_o         =>ben_elp_shd.g_old_rec.elp_attribute1
      ,p_elp_attribute2_o         =>ben_elp_shd.g_old_rec.elp_attribute2
      ,p_elp_attribute3_o         =>ben_elp_shd.g_old_rec.elp_attribute3
      ,p_elp_attribute4_o         =>ben_elp_shd.g_old_rec.elp_attribute4
      ,p_elp_attribute5_o         =>ben_elp_shd.g_old_rec.elp_attribute5
      ,p_elp_attribute6_o         =>ben_elp_shd.g_old_rec.elp_attribute6
      ,p_elp_attribute7_o         =>ben_elp_shd.g_old_rec.elp_attribute7
      ,p_elp_attribute8_o         =>ben_elp_shd.g_old_rec.elp_attribute8
      ,p_elp_attribute9_o         =>ben_elp_shd.g_old_rec.elp_attribute9
      ,p_elp_attribute10_o        =>ben_elp_shd.g_old_rec.elp_attribute10
      ,p_elp_attribute11_o        =>ben_elp_shd.g_old_rec.elp_attribute11
      ,p_elp_attribute12_o        =>ben_elp_shd.g_old_rec.elp_attribute12
      ,p_elp_attribute13_o        =>ben_elp_shd.g_old_rec.elp_attribute13
      ,p_elp_attribute14_o        =>ben_elp_shd.g_old_rec.elp_attribute14
      ,p_elp_attribute15_o        =>ben_elp_shd.g_old_rec.elp_attribute15
      ,p_elp_attribute16_o        =>ben_elp_shd.g_old_rec.elp_attribute16
      ,p_elp_attribute17_o        =>ben_elp_shd.g_old_rec.elp_attribute17
      ,p_elp_attribute18_o        =>ben_elp_shd.g_old_rec.elp_attribute18
      ,p_elp_attribute19_o        =>ben_elp_shd.g_old_rec.elp_attribute19
      ,p_elp_attribute20_o        =>ben_elp_shd.g_old_rec.elp_attribute20
      ,p_elp_attribute21_o        =>ben_elp_shd.g_old_rec.elp_attribute21
      ,p_elp_attribute22_o        =>ben_elp_shd.g_old_rec.elp_attribute22
      ,p_elp_attribute23_o        =>ben_elp_shd.g_old_rec.elp_attribute23
      ,p_elp_attribute24_o        =>ben_elp_shd.g_old_rec.elp_attribute24
      ,p_elp_attribute25_o        =>ben_elp_shd.g_old_rec.elp_attribute25
      ,p_elp_attribute26_o        =>ben_elp_shd.g_old_rec.elp_attribute26
      ,p_elp_attribute27_o        =>ben_elp_shd.g_old_rec.elp_attribute27
      ,p_elp_attribute28_o        =>ben_elp_shd.g_old_rec.elp_attribute28
      ,p_elp_attribute29_o        =>ben_elp_shd.g_old_rec.elp_attribute29
      ,p_elp_attribute30_o        =>ben_elp_shd.g_old_rec.elp_attribute30
      ,p_elig_mrtl_sts_flag_o     =>ben_elp_shd.g_old_rec.elig_mrtl_sts_flag
      ,p_elig_gndr_flag_o         =>ben_elp_shd.g_old_rec.elig_gndr_flag
      ,p_elig_dsblty_ctg_flag_o   =>ben_elp_shd.g_old_rec.elig_dsblty_ctg_flag
      ,p_elig_dsblty_rsn_flag_o   =>ben_elp_shd.g_old_rec.elig_dsblty_rsn_flag
      ,p_elig_dsblty_dgr_flag_o   =>ben_elp_shd.g_old_rec.elig_dsblty_dgr_flag
      ,p_elig_suppl_role_flag_o   =>ben_elp_shd.g_old_rec.elig_suppl_role_flag
      ,p_elig_qual_titl_flag_o    =>ben_elp_shd.g_old_rec.elig_qual_titl_flag
      ,p_elig_pstn_flag_o         =>ben_elp_shd.g_old_rec.elig_pstn_flag
      ,p_elig_prbtn_perd_flag_o   =>ben_elp_shd.g_old_rec.elig_prbtn_perd_flag
      ,p_elig_sp_clng_prg_pt_flag_o =>ben_elp_shd.g_old_rec.elig_sp_clng_prg_pt_flag
      ,p_bnft_cagr_prtn_cd_o        =>ben_elp_shd.g_old_rec.bnft_cagr_prtn_cd
      ,p_elig_dsbld_flag_o        =>ben_elp_shd.g_old_rec.elig_dsbld_flag
      ,p_elig_ttl_cvg_vol_flag_o  =>ben_elp_shd.g_old_rec.elig_ttl_cvg_vol_flag
      ,p_elig_ttl_prtt_flag_o     =>ben_elp_shd.g_old_rec.elig_ttl_prtt_flag
      ,p_elig_comptncy_flag_o     =>ben_elp_shd.g_old_rec.elig_comptncy_flag
      ,p_elig_hlth_cvg_flag_o  	  =>ben_elp_shd.g_old_rec.elig_hlth_cvg_flag
      ,p_elig_anthr_pl_flag_o  	  =>ben_elp_shd.g_old_rec.elig_anthr_pl_flag
      ,p_elig_qua_in_gr_flag_o	  =>ben_elp_shd.g_old_rec.elig_qua_in_gr_flag
      ,p_elig_perf_rtng_flag_o	  =>ben_elp_shd.g_old_rec.elig_perf_rtng_flag
      ,p_elig_crit_values_flag_o  =>ben_elp_shd.g_old_rec.elig_crit_values_flag   /* RBC */
      ,p_object_version_number_o    =>ben_elp_shd.g_old_rec.object_version_number );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_eligy_prfl_f'
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
  p_rec			in out nocopy 	ben_elp_shd.g_rec_type,
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
  ben_elp_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_eligy_prfl_id	 => p_rec.eligy_prfl_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  ben_elp_bus.delete_validate
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
  p_eligy_prfl_id	  in 	 number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date	     out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date	  in     date,
  p_datetrack_mode  	  in     varchar2
  ) is
--
  l_rec		ben_elp_shd.g_rec_type;
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
  l_rec.eligy_prfl_id		:= p_eligy_prfl_id;
  l_rec.object_version_number 	:= p_object_version_number;
  --
  -- Having converted the arguments into the ben_elp_rec
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
end ben_elp_del;

/
