--------------------------------------------------------
--  DDL for Package Body BEN_ELP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELP_UPD" as
/* $Header: beelprhi.pkb 120.5 2007/01/24 05:18:55 rgajula ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_elp_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
	(p_rec 			 in out nocopy ben_elp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
	  (p_base_table_name	=> 'ben_eligy_prfl_f',
	   p_base_key_column	=> 'eligy_prfl_id',
	   p_base_key_value	=> p_rec.eligy_prfl_id);
    --
    ben_elp_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_eligy_prfl_f Row
    --
    update  ben_eligy_prfl_f
    set
    eligy_prfl_id                   = p_rec.eligy_prfl_id,
    name                            = p_rec.name,
    description                     = p_rec.description,
    stat_cd                         = p_rec.stat_cd,
    asmt_to_use_cd                  = p_rec.asmt_to_use_cd,
    elig_enrld_plip_flag            = p_rec.elig_enrld_plip_flag,
    elig_cbr_quald_bnf_flag         = p_rec.elig_cbr_quald_bnf_flag,
    elig_enrld_ptip_flag            = p_rec.elig_enrld_ptip_flag,
    elig_dpnt_cvrd_plip_flag        = p_rec.elig_dpnt_cvrd_plip_flag,
    elig_dpnt_cvrd_ptip_flag        = p_rec.elig_dpnt_cvrd_ptip_flag,
    elig_dpnt_cvrd_pgm_flag         = p_rec.elig_dpnt_cvrd_pgm_flag,
    elig_job_flag                   = p_rec.elig_job_flag,
    elig_hrly_slrd_flag             = p_rec.elig_hrly_slrd_flag,
    elig_pstl_cd_flag               = p_rec.elig_pstl_cd_flag,
    elig_lbr_mmbr_flag              = p_rec.elig_lbr_mmbr_flag,
    elig_lgl_enty_flag              = p_rec.elig_lgl_enty_flag,
    elig_benfts_grp_flag            = p_rec.elig_benfts_grp_flag,
    elig_wk_loc_flag                = p_rec.elig_wk_loc_flag,
    elig_brgng_unit_flag            = p_rec.elig_brgng_unit_flag,
    elig_age_flag                   = p_rec.elig_age_flag,
    elig_los_flag                   = p_rec.elig_los_flag,
    elig_per_typ_flag               = p_rec.elig_per_typ_flag,
    elig_fl_tm_pt_tm_flag           = p_rec.elig_fl_tm_pt_tm_flag,
    elig_ee_stat_flag               = p_rec.elig_ee_stat_flag,
    elig_grd_flag                   = p_rec.elig_grd_flag,
    elig_pct_fl_tm_flag             = p_rec.elig_pct_fl_tm_flag,
    elig_asnt_set_flag              = p_rec.elig_asnt_set_flag,
    elig_hrs_wkd_flag               = p_rec.elig_hrs_wkd_flag,
    elig_comp_lvl_flag              = p_rec.elig_comp_lvl_flag,
    elig_org_unit_flag              = p_rec.elig_org_unit_flag,
    elig_loa_rsn_flag               = p_rec.elig_loa_rsn_flag,
    elig_pyrl_flag                  = p_rec.elig_pyrl_flag,
    elig_schedd_hrs_flag            = p_rec.elig_schedd_hrs_flag,
    elig_py_bss_flag                = p_rec.elig_py_bss_flag,
    eligy_prfl_rl_flag              = p_rec.eligy_prfl_rl_flag,
    elig_cmbn_age_los_flag          = p_rec.elig_cmbn_age_los_flag,
    cntng_prtn_elig_prfl_flag       = p_rec.cntng_prtn_elig_prfl_flag,
    elig_prtt_pl_flag               = p_rec.elig_prtt_pl_flag,
    elig_ppl_grp_flag               = p_rec.elig_ppl_grp_flag,
    elig_svc_area_flag              = p_rec.elig_svc_area_flag,
    elig_ptip_prte_flag             = p_rec.elig_ptip_prte_flag,
    elig_no_othr_cvg_flag           = p_rec.elig_no_othr_cvg_flag,
    elig_enrld_pl_flag              = p_rec.elig_enrld_pl_flag,
    elig_enrld_oipl_flag            = p_rec.elig_enrld_oipl_flag,
    elig_enrld_pgm_flag             = p_rec.elig_enrld_pgm_flag,
    elig_dpnt_cvrd_pl_flag          = p_rec.elig_dpnt_cvrd_pl_flag,
    elig_lvg_rsn_flag               = p_rec.elig_lvg_rsn_flag,
    elig_optd_mdcr_flag             = p_rec.elig_optd_mdcr_flag,
    elig_tbco_use_flag              = p_rec.elig_tbco_use_flag,
    elig_dpnt_othr_ptip_flag        = p_rec.elig_dpnt_othr_ptip_flag,
    business_group_id               = p_rec.business_group_id,
    elp_attribute_category          = p_rec.elp_attribute_category,
    elp_attribute1                  = p_rec.elp_attribute1,
    elp_attribute2                  = p_rec.elp_attribute2,
    elp_attribute3                  = p_rec.elp_attribute3,
    elp_attribute4                  = p_rec.elp_attribute4,
    elp_attribute5                  = p_rec.elp_attribute5,
    elp_attribute6                  = p_rec.elp_attribute6,
    elp_attribute7                  = p_rec.elp_attribute7,
    elp_attribute8                  = p_rec.elp_attribute8,
    elp_attribute9                  = p_rec.elp_attribute9,
    elp_attribute10                 = p_rec.elp_attribute10,
    elp_attribute11                 = p_rec.elp_attribute11,
    elp_attribute12                 = p_rec.elp_attribute12,
    elp_attribute13                 = p_rec.elp_attribute13,
    elp_attribute14                 = p_rec.elp_attribute14,
    elp_attribute15                 = p_rec.elp_attribute15,
    elp_attribute16                 = p_rec.elp_attribute16,
    elp_attribute17                 = p_rec.elp_attribute17,
    elp_attribute18                 = p_rec.elp_attribute18,
    elp_attribute19                 = p_rec.elp_attribute19,
    elp_attribute20                 = p_rec.elp_attribute20,
    elp_attribute21                 = p_rec.elp_attribute21,
    elp_attribute22                 = p_rec.elp_attribute22,
    elp_attribute23                 = p_rec.elp_attribute23,
    elp_attribute24                 = p_rec.elp_attribute24,
    elp_attribute25                 = p_rec.elp_attribute25,
    elp_attribute26                 = p_rec.elp_attribute26,
    elp_attribute27                 = p_rec.elp_attribute27,
    elp_attribute28                 = p_rec.elp_attribute28,
    elp_attribute29                 = p_rec.elp_attribute29,
    elp_attribute30                 = p_rec.elp_attribute30,
    elig_mrtl_sts_flag              = p_rec.elig_mrtl_sts_flag ,
    elig_gndr_flag                  = p_rec.elig_gndr_flag ,
    elig_dsblty_ctg_flag            = p_rec.elig_dsblty_ctg_flag ,
    elig_dsblty_rsn_flag            = p_rec.elig_dsblty_rsn_flag ,
    elig_dsblty_dgr_flag            = p_rec.elig_dsblty_dgr_flag,
    elig_suppl_role_flag            = p_rec.elig_suppl_role_flag,
    elig_qual_titl_flag             = p_rec.elig_qual_titl_flag,
    elig_pstn_flag                  = p_rec.elig_pstn_flag,
    elig_prbtn_perd_flag            = p_rec.elig_prbtn_perd_flag,
    elig_sp_clng_prg_pt_flag        = p_rec.elig_sp_clng_prg_pt_flag,
    bnft_cagr_prtn_cd               = p_rec.bnft_cagr_prtn_cd,
    elig_dsbld_flag       	    = p_rec.elig_dsbld_flag,
    elig_ttl_cvg_vol_flag 	    = p_rec.elig_ttl_cvg_vol_flag,
    elig_ttl_prtt_flag    	    = p_rec.elig_ttl_prtt_flag,
    elig_comptncy_flag    	    = p_rec.elig_comptncy_flag,
    elig_hlth_cvg_flag		    = p_rec.elig_hlth_cvg_flag,
    elig_anthr_pl_flag		    = p_rec.elig_anthr_pl_flag,
    elig_qua_in_gr_flag		    = p_rec.elig_qua_in_gr_flag,
    elig_perf_rtng_flag		    = p_rec.elig_perf_rtng_flag,
    elig_crit_values_flag           = p_rec.elig_crit_values_flag,  /* RBC */
    object_version_number           = p_rec.object_version_number
    where   eligy_prfl_id = p_rec.eligy_prfl_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_elp_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_elp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_elp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_elp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_elp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_elp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
	(p_rec 			 in out nocopy ben_elp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--	the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
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
Procedure dt_pre_update
	(p_rec 			 in out nocopy ben_elp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	         varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    ben_elp_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.eligy_prfl_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      ben_elp_del.delete_dml
        (p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => p_validation_start_date,
	 p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    ben_elp_ins.insert_dml
      (p_rec			=> p_rec,
       p_effective_date		=> p_effective_date,
       p_datetrack_mode		=> p_datetrack_mode,
       p_validation_start_date	=> p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
	(p_rec 			 in out nocopy ben_elp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec 		     => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
	(p_rec 			 in ben_elp_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    ben_elp_rku.after_update
      (p_eligy_prfl_id            =>p_rec.eligy_prfl_id
      ,p_effective_start_date     =>p_rec.effective_start_date
      ,p_effective_end_date       =>p_rec.effective_end_date
      ,p_name                     =>p_rec.name
      ,p_description              =>p_rec.description
      ,p_stat_cd                  =>p_rec.stat_cd
      ,p_asmt_to_use_cd           =>p_rec.asmt_to_use_cd
      ,p_elig_enrld_plip_flag     =>p_rec.elig_enrld_plip_flag
      ,p_elig_cbr_quald_bnf_flag  =>p_rec.elig_cbr_quald_bnf_flag
      ,p_elig_enrld_ptip_flag     =>p_rec.elig_enrld_ptip_flag
      ,p_elig_dpnt_cvrd_plip_flag =>p_rec.elig_dpnt_cvrd_plip_flag
      ,p_elig_dpnt_cvrd_ptip_flag =>p_rec.elig_dpnt_cvrd_ptip_flag
      ,p_elig_dpnt_cvrd_pgm_flag  =>p_rec.elig_dpnt_cvrd_pgm_flag
      ,p_elig_job_flag            =>p_rec.elig_job_flag
      ,p_elig_hrly_slrd_flag      =>p_rec.elig_hrly_slrd_flag
      ,p_elig_pstl_cd_flag        =>p_rec.elig_pstl_cd_flag
      ,p_elig_lbr_mmbr_flag       =>p_rec.elig_lbr_mmbr_flag
      ,p_elig_lgl_enty_flag       =>p_rec.elig_lgl_enty_flag
      ,p_elig_benfts_grp_flag     =>p_rec.elig_benfts_grp_flag
      ,p_elig_wk_loc_flag         =>p_rec.elig_wk_loc_flag
      ,p_elig_brgng_unit_flag     =>p_rec.elig_brgng_unit_flag
      ,p_elig_age_flag            =>p_rec.elig_age_flag
      ,p_elig_los_flag            =>p_rec.elig_los_flag
      ,p_elig_per_typ_flag        =>p_rec.elig_per_typ_flag
      ,p_elig_fl_tm_pt_tm_flag    =>p_rec.elig_fl_tm_pt_tm_flag
      ,p_elig_ee_stat_flag        =>p_rec.elig_ee_stat_flag
      ,p_elig_grd_flag            =>p_rec.elig_grd_flag
      ,p_elig_pct_fl_tm_flag      =>p_rec.elig_pct_fl_tm_flag
      ,p_elig_asnt_set_flag       =>p_rec.elig_asnt_set_flag
      ,p_elig_hrs_wkd_flag        =>p_rec.elig_hrs_wkd_flag
      ,p_elig_comp_lvl_flag       =>p_rec.elig_comp_lvl_flag
      ,p_elig_org_unit_flag       =>p_rec.elig_org_unit_flag
      ,p_elig_loa_rsn_flag        =>p_rec.elig_loa_rsn_flag
      ,p_elig_pyrl_flag           =>p_rec.elig_pyrl_flag
      ,p_elig_schedd_hrs_flag     =>p_rec.elig_schedd_hrs_flag
      ,p_elig_py_bss_flag         =>p_rec.elig_py_bss_flag
      ,p_eligy_prfl_rl_flag       =>p_rec.eligy_prfl_rl_flag
      ,p_elig_cmbn_age_los_flag   =>p_rec.elig_cmbn_age_los_flag
      ,p_cntng_prtn_elig_prfl_flag=>p_rec.cntng_prtn_elig_prfl_flag
      ,p_elig_prtt_pl_flag        =>p_rec.elig_prtt_pl_flag
      ,p_elig_ppl_grp_flag        =>p_rec.elig_ppl_grp_flag
      ,p_elig_svc_area_flag       =>p_rec.elig_svc_area_flag
      ,p_elig_ptip_prte_flag      =>p_rec.elig_ptip_prte_flag
      ,p_elig_no_othr_cvg_flag    =>p_rec.elig_no_othr_cvg_flag
      ,p_elig_enrld_pl_flag       =>p_rec.elig_enrld_pl_flag
      ,p_elig_enrld_oipl_flag     =>p_rec.elig_enrld_oipl_flag
      ,p_elig_enrld_pgm_flag      =>p_rec.elig_enrld_pgm_flag
      ,p_elig_dpnt_cvrd_pl_flag   =>p_rec.elig_dpnt_cvrd_pl_flag
      ,p_elig_lvg_rsn_flag        =>p_rec.elig_lvg_rsn_flag
      ,p_elig_optd_mdcr_flag      =>p_rec.elig_optd_mdcr_flag
      ,p_elig_tbco_use_flag       =>p_rec.elig_tbco_use_flag
      ,p_elig_dpnt_othr_ptip_flag =>p_rec.elig_dpnt_othr_ptip_flag
      ,p_business_group_id        =>p_rec.business_group_id
      ,p_elp_attribute_category   =>p_rec.elp_attribute_category
      ,p_elp_attribute1           =>p_rec.elp_attribute1
      ,p_elp_attribute2           =>p_rec.elp_attribute2
      ,p_elp_attribute3           =>p_rec.elp_attribute3
      ,p_elp_attribute4           =>p_rec.elp_attribute4
      ,p_elp_attribute5           =>p_rec.elp_attribute5
      ,p_elp_attribute6           =>p_rec.elp_attribute6
      ,p_elp_attribute7           =>p_rec.elp_attribute7
      ,p_elp_attribute8           =>p_rec.elp_attribute8
      ,p_elp_attribute9           =>p_rec.elp_attribute9
      ,p_elp_attribute10          =>p_rec.elp_attribute10
      ,p_elp_attribute11          =>p_rec.elp_attribute11
      ,p_elp_attribute12          =>p_rec.elp_attribute12
      ,p_elp_attribute13          =>p_rec.elp_attribute13
      ,p_elp_attribute14          =>p_rec.elp_attribute14
      ,p_elp_attribute15          =>p_rec.elp_attribute15
      ,p_elp_attribute16          =>p_rec.elp_attribute16
      ,p_elp_attribute17          =>p_rec.elp_attribute17
      ,p_elp_attribute18          =>p_rec.elp_attribute18
      ,p_elp_attribute19          =>p_rec.elp_attribute19
      ,p_elp_attribute20          =>p_rec.elp_attribute20
      ,p_elp_attribute21          =>p_rec.elp_attribute21
      ,p_elp_attribute22          =>p_rec.elp_attribute22
      ,p_elp_attribute23          =>p_rec.elp_attribute23
      ,p_elp_attribute24          =>p_rec.elp_attribute24
      ,p_elp_attribute25          =>p_rec.elp_attribute25
      ,p_elp_attribute26          =>p_rec.elp_attribute26
      ,p_elp_attribute27          =>p_rec.elp_attribute27
      ,p_elp_attribute28          =>p_rec.elp_attribute28
      ,p_elp_attribute29          =>p_rec.elp_attribute29
      ,p_elp_attribute30          =>p_rec.elp_attribute30
      ,p_elig_mrtl_sts_flag       =>p_rec.elig_mrtl_sts_flag
      ,p_elig_gndr_flag           =>p_rec.elig_gndr_flag
      ,p_elig_dsblty_ctg_flag     =>p_rec.elig_dsblty_ctg_flag
      ,p_elig_dsblty_rsn_flag     =>p_rec.elig_dsblty_rsn_flag
      ,p_elig_dsblty_dgr_flag     =>p_rec.elig_dsblty_dgr_flag
      ,p_elig_suppl_role_flag     =>p_rec.elig_suppl_role_flag
      ,p_elig_qual_titl_flag      =>p_rec.elig_qual_titl_flag
      ,p_elig_pstn_flag           =>p_rec.elig_pstn_flag
      ,p_elig_prbtn_perd_flag     =>p_rec.elig_prbtn_perd_flag
      ,p_elig_sp_clng_prg_pt_flag =>p_rec.elig_sp_clng_prg_pt_flag
      ,p_bnft_cagr_prtn_cd        =>p_rec.bnft_cagr_prtn_cd
      ,p_elig_dsbld_flag       	  =>p_rec.elig_dsbld_flag
      ,p_elig_ttl_cvg_vol_flag 	  =>p_rec.elig_ttl_cvg_vol_flag
      ,p_elig_ttl_prtt_flag    	  =>p_rec.elig_ttl_prtt_flag
      ,p_elig_comptncy_flag    	  =>p_rec.elig_comptncy_flag
      ,p_elig_hlth_cvg_flag	  =>p_rec.elig_hlth_cvg_flag
      ,p_elig_anthr_pl_flag	  =>p_rec.elig_anthr_pl_flag
      ,p_elig_qua_in_gr_flag	  =>p_rec.elig_qua_in_gr_flag
      ,p_elig_perf_rtng_flag	  =>p_rec.elig_perf_rtng_flag
      ,p_elig_crit_values_flag    =>p_rec.elig_crit_values_flag   /* RBC */
      ,p_object_version_number    =>p_rec.object_version_number
      ,p_effective_date           =>p_effective_date
      ,p_datetrack_mode           =>p_datetrack_mode
      ,p_validation_start_date    =>p_validation_start_date
      ,p_validation_end_date      =>p_validation_end_date
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
      ,p_elig_sp_clng_prg_pt_flag_o=>ben_elp_shd.g_old_rec.elig_sp_clng_prg_pt_flag
      ,p_bnft_cagr_prtn_cd_o      =>ben_elp_shd.g_old_rec.bnft_cagr_prtn_cd
      ,p_elig_dsbld_flag_o     	  =>ben_elp_shd.g_old_rec.elig_dsbld_flag
      ,p_elig_ttl_cvg_vol_flag_o  =>ben_elp_shd.g_old_rec.elig_ttl_cvg_vol_flag
      ,p_elig_ttl_prtt_flag_o  	  =>ben_elp_shd.g_old_rec.elig_ttl_prtt_flag
      ,p_elig_comptncy_flag_o  	  =>ben_elp_shd.g_old_rec.elig_comptncy_flag
      ,p_elig_hlth_cvg_flag_o	  =>ben_elp_shd.g_old_rec.elig_hlth_cvg_flag
      ,p_elig_anthr_pl_flag_o	  =>ben_elp_shd.g_old_rec.elig_anthr_pl_flag
      ,p_elig_qua_in_gr_flag_o	  =>ben_elp_shd.g_old_rec.elig_qua_in_gr_flag
      ,p_elig_perf_rtng_flag_o	  =>ben_elp_shd.g_old_rec.elig_perf_rtng_flag
      ,p_elig_crit_values_flag_o  =>ben_elp_shd.g_old_rec.elig_crit_values_flag   /* RBC */
      ,p_object_version_number_o  =>ben_elp_shd.g_old_rec.object_version_number );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_eligy_prfl_f'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ben_elp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    ben_elp_shd.g_old_rec.name;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    ben_elp_shd.g_old_rec.description;
  End If;
  If (p_rec.stat_cd = hr_api.g_varchar2) then
    p_rec.stat_cd :=
    ben_elp_shd.g_old_rec.stat_cd;
  End If;
  if (p_rec.elig_enrld_plip_flag = hr_api.g_varchar2) then
    p_rec.elig_enrld_plip_flag :=
    ben_elp_shd.g_old_rec.elig_enrld_plip_flag;
  End If;
  if (p_rec.elig_cbr_quald_bnf_flag = hr_api.g_varchar2) then
    p_rec.elig_cbr_quald_bnf_flag :=
    ben_elp_shd.g_old_rec.elig_cbr_quald_bnf_flag;
  End If;
  if (p_rec.elig_enrld_ptip_flag = hr_api.g_varchar2) then
    p_rec.elig_enrld_ptip_flag :=
    ben_elp_shd.g_old_rec.elig_enrld_ptip_flag;
  End If;
  if (p_rec.elig_dpnt_cvrd_plip_flag = hr_api.g_varchar2) then
    p_rec.elig_dpnt_cvrd_plip_flag :=
    ben_elp_shd.g_old_rec.elig_dpnt_cvrd_plip_flag;
  End If;
  if (p_rec.elig_dpnt_cvrd_ptip_flag = hr_api.g_varchar2) then
    p_rec.elig_dpnt_cvrd_ptip_flag :=
    ben_elp_shd.g_old_rec.elig_dpnt_cvrd_ptip_flag;
  End If;
  if (p_rec.elig_dpnt_cvrd_pgm_flag = hr_api.g_varchar2) then
    p_rec.elig_dpnt_cvrd_pgm_flag :=
    ben_elp_shd.g_old_rec.elig_dpnt_cvrd_pgm_flag;
  End If;
  if (p_rec.elig_job_flag = hr_api.g_varchar2) then
    p_rec.elig_job_flag :=
    ben_elp_shd.g_old_rec.elig_job_flag;
  End If;
  if (p_rec.elig_hrly_slrd_flag = hr_api.g_varchar2) then
    p_rec.elig_hrly_slrd_flag :=
    ben_elp_shd.g_old_rec.elig_hrly_slrd_flag;
  End If;
  if (p_rec.elig_pstl_cd_flag = hr_api.g_varchar2) then
    p_rec.elig_pstl_cd_flag :=
    ben_elp_shd.g_old_rec.elig_pstl_cd_flag;
  End If;
  if (p_rec.elig_lbr_mmbr_flag = hr_api.g_varchar2) then
    p_rec.elig_lbr_mmbr_flag :=
    ben_elp_shd.g_old_rec.elig_lbr_mmbr_flag;
  End If;
  if (p_rec.elig_lgl_enty_flag = hr_api.g_varchar2) then
    p_rec.elig_lgl_enty_flag :=
    ben_elp_shd.g_old_rec.elig_lgl_enty_flag;
  End If;
  if (p_rec.elig_benfts_grp_flag = hr_api.g_varchar2) then
    p_rec.elig_benfts_grp_flag :=
    ben_elp_shd.g_old_rec.elig_benfts_grp_flag;
  End If;
  if (p_rec.elig_wk_loc_flag = hr_api.g_varchar2) then
    p_rec.elig_wk_loc_flag :=
    ben_elp_shd.g_old_rec.elig_wk_loc_flag;
  End If;
  if (p_rec.elig_brgng_unit_flag = hr_api.g_varchar2) then
    p_rec.elig_brgng_unit_flag :=
    ben_elp_shd.g_old_rec.elig_brgng_unit_flag;
  End If;
  if (p_rec.elig_age_flag = hr_api.g_varchar2) then
    p_rec.elig_age_flag :=
    ben_elp_shd.g_old_rec.elig_age_flag;
  End If;
  if (p_rec.elig_los_flag = hr_api.g_varchar2) then
    p_rec.elig_los_flag :=
    ben_elp_shd.g_old_rec.elig_los_flag;
  End If;
  if (p_rec.elig_per_typ_flag = hr_api.g_varchar2) then
    p_rec.elig_per_typ_flag :=
    ben_elp_shd.g_old_rec.elig_per_typ_flag;
  End If;
  if (p_rec.elig_fl_tm_pt_tm_flag = hr_api.g_varchar2) then
    p_rec.elig_fl_tm_pt_tm_flag :=
    ben_elp_shd.g_old_rec.elig_fl_tm_pt_tm_flag;
  End If;
  if (p_rec.elig_ee_stat_flag = hr_api.g_varchar2) then
    p_rec.elig_ee_stat_flag :=
    ben_elp_shd.g_old_rec.elig_ee_stat_flag;
  End If;
  if (p_rec.elig_grd_flag = hr_api.g_varchar2) then
    p_rec.elig_grd_flag :=
    ben_elp_shd.g_old_rec.elig_grd_flag;
  End If;
  if (p_rec.elig_pct_fl_tm_flag = hr_api.g_varchar2) then
    p_rec.elig_pct_fl_tm_flag :=
    ben_elp_shd.g_old_rec.elig_pct_fl_tm_flag;
  End If;
  if (p_rec.elig_asnt_set_flag = hr_api.g_varchar2) then
    p_rec.elig_asnt_set_flag :=
    ben_elp_shd.g_old_rec.elig_asnt_set_flag;
  End If;
  if (p_rec.elig_hrs_wkd_flag = hr_api.g_varchar2) then
    p_rec.elig_hrs_wkd_flag :=
    ben_elp_shd.g_old_rec.elig_hrs_wkd_flag;
  End If;
  if (p_rec.elig_comp_lvl_flag = hr_api.g_varchar2) then
    p_rec.elig_comp_lvl_flag :=
    ben_elp_shd.g_old_rec.elig_comp_lvl_flag;
  End If;
  if (p_rec.elig_org_unit_flag = hr_api.g_varchar2) then
    p_rec.elig_org_unit_flag :=
    ben_elp_shd.g_old_rec.elig_org_unit_flag;
  End If;
  if (p_rec.elig_loa_rsn_flag = hr_api.g_varchar2) then
    p_rec.elig_loa_rsn_flag :=
    ben_elp_shd.g_old_rec.elig_loa_rsn_flag;
  End If;
  if (p_rec.elig_pyrl_flag = hr_api.g_varchar2) then
    p_rec.elig_pyrl_flag :=
    ben_elp_shd.g_old_rec.elig_pyrl_flag;
  End If;
  if (p_rec.elig_schedd_hrs_flag = hr_api.g_varchar2) then
    p_rec.elig_schedd_hrs_flag :=
    ben_elp_shd.g_old_rec.elig_schedd_hrs_flag;
  End If;
  if (p_rec.elig_py_bss_flag = hr_api.g_varchar2) then
    p_rec.elig_py_bss_flag :=
    ben_elp_shd.g_old_rec.elig_py_bss_flag;
  End If;
  if (p_rec.eligy_prfl_rl_flag = hr_api.g_varchar2) then
    p_rec.eligy_prfl_rl_flag :=
    ben_elp_shd.g_old_rec.eligy_prfl_rl_flag;
  End If;
  if (p_rec.elig_cmbn_age_los_flag = hr_api.g_varchar2) then
    p_rec.elig_cmbn_age_los_flag :=
    ben_elp_shd.g_old_rec.elig_cmbn_age_los_flag;
  End If;
  if (p_rec.cntng_prtn_elig_prfl_flag = hr_api.g_varchar2) then
    p_rec.cntng_prtn_elig_prfl_flag :=
    ben_elp_shd.g_old_rec.cntng_prtn_elig_prfl_flag;
  End If;
  if (p_rec.elig_prtt_pl_flag = hr_api.g_varchar2) then
    p_rec.elig_prtt_pl_flag :=
    ben_elp_shd.g_old_rec.elig_prtt_pl_flag;
  End If;
  if (p_rec.elig_ppl_grp_flag = hr_api.g_varchar2) then
    p_rec.elig_ppl_grp_flag :=
    ben_elp_shd.g_old_rec.elig_ppl_grp_flag;
  End If;
  if (p_rec.elig_svc_area_flag = hr_api.g_varchar2) then
    p_rec.elig_svc_area_flag :=
    ben_elp_shd.g_old_rec.elig_svc_area_flag;
  End If;
  if (p_rec.elig_ptip_prte_flag = hr_api.g_varchar2) then
    p_rec.elig_ptip_prte_flag :=
    ben_elp_shd.g_old_rec.elig_ptip_prte_flag;
  End If;
  if (p_rec.elig_no_othr_cvg_flag = hr_api.g_varchar2) then
    p_rec.elig_no_othr_cvg_flag :=
    ben_elp_shd.g_old_rec.elig_no_othr_cvg_flag;
  End If;
  if (p_rec.elig_enrld_pl_flag = hr_api.g_varchar2) then
    p_rec.elig_enrld_pl_flag :=
    ben_elp_shd.g_old_rec.elig_enrld_pl_flag;
  End If;
  if (p_rec.elig_enrld_oipl_flag = hr_api.g_varchar2) then
    p_rec.elig_enrld_oipl_flag :=
    ben_elp_shd.g_old_rec.elig_enrld_oipl_flag;
  End If;
  if (p_rec.elig_enrld_pgm_flag = hr_api.g_varchar2) then
    p_rec.elig_enrld_pgm_flag :=
    ben_elp_shd.g_old_rec.elig_enrld_pgm_flag;
  End If;
  if (p_rec.elig_dpnt_cvrd_pl_flag = hr_api.g_varchar2) then
    p_rec.elig_dpnt_cvrd_pl_flag :=
    ben_elp_shd.g_old_rec.elig_dpnt_cvrd_pl_flag;
  End If;
  if (p_rec.elig_lvg_rsn_flag = hr_api.g_varchar2) then
    p_rec.elig_lvg_rsn_flag :=
    ben_elp_shd.g_old_rec.elig_lvg_rsn_flag;
  End If;
  if (p_rec.elig_optd_mdcr_flag = hr_api.g_varchar2) then
    p_rec.elig_optd_mdcr_flag :=
    ben_elp_shd.g_old_rec.elig_optd_mdcr_flag;
  End If;
  if (p_rec.elig_tbco_use_flag = hr_api.g_varchar2) then
    p_rec.elig_tbco_use_flag :=
    ben_elp_shd.g_old_rec.elig_tbco_use_flag;
  End If;
  if (p_rec.elig_dpnt_othr_ptip_flag = hr_api.g_varchar2) then
    p_rec.elig_dpnt_othr_ptip_flag :=
    ben_elp_shd.g_old_rec.elig_dpnt_othr_ptip_flag;
  End If;
  If (p_rec.asmt_to_use_cd = hr_api.g_varchar2) then
    p_rec.asmt_to_use_cd :=
    ben_elp_shd.g_old_rec.asmt_to_use_cd;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_elp_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.elp_attribute_category = hr_api.g_varchar2) then
    p_rec.elp_attribute_category :=
    ben_elp_shd.g_old_rec.elp_attribute_category;
  End If;
  If (p_rec.elp_attribute1 = hr_api.g_varchar2) then
    p_rec.elp_attribute1 :=
    ben_elp_shd.g_old_rec.elp_attribute1;
  End If;
  If (p_rec.elp_attribute2 = hr_api.g_varchar2) then
    p_rec.elp_attribute2 :=
    ben_elp_shd.g_old_rec.elp_attribute2;
  End If;
  If (p_rec.elp_attribute3 = hr_api.g_varchar2) then
    p_rec.elp_attribute3 :=
    ben_elp_shd.g_old_rec.elp_attribute3;
  End If;
  If (p_rec.elp_attribute4 = hr_api.g_varchar2) then
    p_rec.elp_attribute4 :=
    ben_elp_shd.g_old_rec.elp_attribute4;
  End If;
  If (p_rec.elp_attribute5 = hr_api.g_varchar2) then
    p_rec.elp_attribute5 :=
    ben_elp_shd.g_old_rec.elp_attribute5;
  End If;
  If (p_rec.elp_attribute6 = hr_api.g_varchar2) then
    p_rec.elp_attribute6 :=
    ben_elp_shd.g_old_rec.elp_attribute6;
  End If;
  If (p_rec.elp_attribute7 = hr_api.g_varchar2) then
    p_rec.elp_attribute7 :=
    ben_elp_shd.g_old_rec.elp_attribute7;
  End If;
  If (p_rec.elp_attribute8 = hr_api.g_varchar2) then
    p_rec.elp_attribute8 :=
    ben_elp_shd.g_old_rec.elp_attribute8;
  End If;
  If (p_rec.elp_attribute9 = hr_api.g_varchar2) then
    p_rec.elp_attribute9 :=
    ben_elp_shd.g_old_rec.elp_attribute9;
  End If;
  If (p_rec.elp_attribute10 = hr_api.g_varchar2) then
    p_rec.elp_attribute10 :=
    ben_elp_shd.g_old_rec.elp_attribute10;
  End If;
  If (p_rec.elp_attribute11 = hr_api.g_varchar2) then
    p_rec.elp_attribute11 :=
    ben_elp_shd.g_old_rec.elp_attribute11;
  End If;
  If (p_rec.elp_attribute12 = hr_api.g_varchar2) then
    p_rec.elp_attribute12 :=
    ben_elp_shd.g_old_rec.elp_attribute12;
  End If;
  If (p_rec.elp_attribute13 = hr_api.g_varchar2) then
    p_rec.elp_attribute13 :=
    ben_elp_shd.g_old_rec.elp_attribute13;
  End If;
  If (p_rec.elp_attribute14 = hr_api.g_varchar2) then
    p_rec.elp_attribute14 :=
    ben_elp_shd.g_old_rec.elp_attribute14;
  End If;
  If (p_rec.elp_attribute15 = hr_api.g_varchar2) then
    p_rec.elp_attribute15 :=
    ben_elp_shd.g_old_rec.elp_attribute15;
  End If;
  If (p_rec.elp_attribute16 = hr_api.g_varchar2) then
    p_rec.elp_attribute16 :=
    ben_elp_shd.g_old_rec.elp_attribute16;
  End If;
  If (p_rec.elp_attribute17 = hr_api.g_varchar2) then
    p_rec.elp_attribute17 :=
    ben_elp_shd.g_old_rec.elp_attribute17;
  End If;
  If (p_rec.elp_attribute18 = hr_api.g_varchar2) then
    p_rec.elp_attribute18 :=
    ben_elp_shd.g_old_rec.elp_attribute18;
  End If;
  If (p_rec.elp_attribute19 = hr_api.g_varchar2) then
    p_rec.elp_attribute19 :=
    ben_elp_shd.g_old_rec.elp_attribute19;
  End If;
  If (p_rec.elp_attribute20 = hr_api.g_varchar2) then
    p_rec.elp_attribute20 :=
    ben_elp_shd.g_old_rec.elp_attribute20;
  End If;
  If (p_rec.elp_attribute21 = hr_api.g_varchar2) then
    p_rec.elp_attribute21 :=
    ben_elp_shd.g_old_rec.elp_attribute21;
  End If;
  If (p_rec.elp_attribute22 = hr_api.g_varchar2) then
    p_rec.elp_attribute22 :=
    ben_elp_shd.g_old_rec.elp_attribute22;
  End If;
  If (p_rec.elp_attribute23 = hr_api.g_varchar2) then
    p_rec.elp_attribute23 :=
    ben_elp_shd.g_old_rec.elp_attribute23;
  End If;
  If (p_rec.elp_attribute24 = hr_api.g_varchar2) then
    p_rec.elp_attribute24 :=
    ben_elp_shd.g_old_rec.elp_attribute24;
  End If;
  If (p_rec.elp_attribute25 = hr_api.g_varchar2) then
    p_rec.elp_attribute25 :=
    ben_elp_shd.g_old_rec.elp_attribute25;
  End If;
  If (p_rec.elp_attribute26 = hr_api.g_varchar2) then
    p_rec.elp_attribute26 :=
    ben_elp_shd.g_old_rec.elp_attribute26;
  End If;
  If (p_rec.elp_attribute27 = hr_api.g_varchar2) then
    p_rec.elp_attribute27 :=
    ben_elp_shd.g_old_rec.elp_attribute27;
  End If;
  If (p_rec.elp_attribute28 = hr_api.g_varchar2) then
    p_rec.elp_attribute28 :=
    ben_elp_shd.g_old_rec.elp_attribute28;
  End If;
  If (p_rec.elp_attribute29 = hr_api.g_varchar2) then
    p_rec.elp_attribute29 :=
    ben_elp_shd.g_old_rec.elp_attribute29;
  End If;
  If (p_rec.elp_attribute30 = hr_api.g_varchar2) then
    p_rec.elp_attribute30 :=
    ben_elp_shd.g_old_rec.elp_attribute30;
  End If;
  If (p_rec.elig_mrtl_sts_flag = hr_api.g_varchar2) then
    p_rec.elig_mrtl_sts_flag :=
    ben_elp_shd.g_old_rec.elig_mrtl_sts_flag;
  End If;
  If (p_rec.elig_gndr_flag = hr_api.g_varchar2) then
    p_rec.elig_gndr_flag :=
    ben_elp_shd.g_old_rec.elig_gndr_flag;
  End If;
  If (p_rec.elig_dsblty_ctg_flag = hr_api.g_varchar2) then
    p_rec.elig_dsblty_ctg_flag :=
    ben_elp_shd.g_old_rec.elig_dsblty_ctg_flag;
  End If;
  If (p_rec.elig_dsblty_rsn_flag = hr_api.g_varchar2) then
    p_rec.elig_dsblty_rsn_flag :=
    ben_elp_shd.g_old_rec.elig_dsblty_rsn_flag;
  End If;
  If (p_rec.elig_dsblty_dgr_flag = hr_api.g_varchar2) then
    p_rec.elig_dsblty_dgr_flag :=
    ben_elp_shd.g_old_rec.elig_dsblty_dgr_flag;
  End If;
  If (p_rec.elig_suppl_role_flag = hr_api.g_varchar2) then
    p_rec.elig_suppl_role_flag :=
    ben_elp_shd.g_old_rec.elig_suppl_role_flag;
  End If;
  If (p_rec.elig_qual_titl_flag = hr_api.g_varchar2) then
    p_rec.elig_qual_titl_flag :=
    ben_elp_shd.g_old_rec.elig_qual_titl_flag;
  End If;
  If (p_rec.elig_pstn_flag = hr_api.g_varchar2) then
    p_rec.elig_pstn_flag :=
    ben_elp_shd.g_old_rec.elig_pstn_flag;
  End If;
  If (p_rec.elig_prbtn_perd_flag = hr_api.g_varchar2) then
    p_rec.elig_prbtn_perd_flag :=
    ben_elp_shd.g_old_rec.elig_prbtn_perd_flag;
  End If;
  If (p_rec.elig_sp_clng_prg_pt_flag = hr_api.g_varchar2) then
    p_rec.elig_sp_clng_prg_pt_flag :=
    ben_elp_shd.g_old_rec.elig_sp_clng_prg_pt_flag;
  End If;
  If (p_rec.bnft_cagr_prtn_cd = hr_api.g_varchar2) then
    p_rec.bnft_cagr_prtn_cd :=
    ben_elp_shd.g_old_rec.bnft_cagr_prtn_cd;
  End If;
  If (p_rec.elig_dsbld_flag = hr_api.g_varchar2) then
    p_rec.elig_dsbld_flag :=
    ben_elp_shd.g_old_rec.elig_dsbld_flag;
  End If;
  If (p_rec.elig_ttl_cvg_vol_flag = hr_api.g_varchar2) then
    p_rec.elig_ttl_cvg_vol_flag :=
    ben_elp_shd.g_old_rec.elig_ttl_cvg_vol_flag;
  End If;
  If (p_rec.elig_ttl_prtt_flag = hr_api.g_varchar2) then
    p_rec.elig_ttl_prtt_flag :=
    ben_elp_shd.g_old_rec.elig_ttl_prtt_flag;
  End If;
  If (p_rec.elig_comptncy_flag = hr_api.g_varchar2) then
    p_rec.elig_comptncy_flag :=
    ben_elp_shd.g_old_rec.elig_comptncy_flag;
  End If;
  If (p_rec.elig_hlth_cvg_flag = hr_api.g_varchar2) then
    p_rec.elig_hlth_cvg_flag :=
    ben_elp_shd.g_old_rec.elig_hlth_cvg_flag;
  End If;
  If (p_rec.elig_anthr_pl_flag = hr_api.g_varchar2) then
    p_rec.elig_anthr_pl_flag :=
    ben_elp_shd.g_old_rec.elig_anthr_pl_flag;
  End If;
  If (p_rec.elig_qua_in_gr_flag = hr_api.g_varchar2) then
    p_rec.elig_qua_in_gr_flag :=
    ben_elp_shd.g_old_rec.elig_qua_in_gr_flag;
  End If;
  If (p_rec.elig_perf_rtng_flag = hr_api.g_varchar2) then
    p_rec.elig_perf_rtng_flag :=
    ben_elp_shd.g_old_rec.elig_perf_rtng_flag;
  End If;
  If (p_rec.elig_crit_values_flag = hr_api.g_varchar2) then
    p_rec.elig_crit_values_flag :=
    ben_elp_shd.g_old_rec.elig_crit_values_flag;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec			in out nocopy 	ben_elp_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  ) is
--
  l_proc			varchar2(72) := g_package||'upd';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  ben_elp_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_eligy_prfl_id	 => p_rec.eligy_prfl_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_elp_bus.update_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode  	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => p_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_eligy_prfl_id                in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_stat_cd                      in varchar2         default hr_api.g_varchar2,
  p_asmt_to_use_cd               in varchar2         default hr_api.g_varchar2,
  p_elig_enrld_plip_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_cbr_quald_bnf_flag      in varchar2         default hr_api.g_varchar2,
  p_elig_enrld_ptip_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_dpnt_cvrd_plip_flag     in varchar2         default hr_api.g_varchar2,
  p_elig_dpnt_cvrd_ptip_flag     in varchar2         default hr_api.g_varchar2,
  p_elig_dpnt_cvrd_pgm_flag      in varchar2         default hr_api.g_varchar2,
  p_elig_job_flag                in varchar2         default hr_api.g_varchar2,
  p_elig_hrly_slrd_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_pstl_cd_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_lbr_mmbr_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_lgl_enty_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_benfts_grp_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_wk_loc_flag             in varchar2         default hr_api.g_varchar2,
  p_elig_brgng_unit_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_age_flag                in varchar2         default hr_api.g_varchar2,
  p_elig_los_flag                in varchar2         default hr_api.g_varchar2,
  p_elig_per_typ_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_fl_tm_pt_tm_flag        in varchar2         default hr_api.g_varchar2,
  p_elig_ee_stat_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_grd_flag                in varchar2         default hr_api.g_varchar2,
  p_elig_pct_fl_tm_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_asnt_set_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_hrs_wkd_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_comp_lvl_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_org_unit_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_loa_rsn_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_pyrl_flag               in varchar2         default hr_api.g_varchar2,
  p_elig_schedd_hrs_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_py_bss_flag             in varchar2         default hr_api.g_varchar2,
  p_eligy_prfl_rl_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_cmbn_age_los_flag       in varchar2         default hr_api.g_varchar2,
  p_cntng_prtn_elig_prfl_flag    in varchar2         default hr_api.g_varchar2,
  p_elig_prtt_pl_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_ppl_grp_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_svc_area_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_ptip_prte_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_no_othr_cvg_flag        in varchar2         default hr_api.g_varchar2,
  p_elig_enrld_pl_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_enrld_oipl_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_enrld_pgm_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_dpnt_cvrd_pl_flag       in varchar2         default hr_api.g_varchar2,
  p_elig_lvg_rsn_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_optd_mdcr_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_tbco_use_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_dpnt_othr_ptip_flag     in varchar2         default hr_api.g_varchar2,
  p_business_group_id            in number           default hr_api.g_number,
  p_elp_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_elp_attribute1               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute2               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute3               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute4               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute5               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute6               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute7               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute8               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute9               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute10              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute11              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute12              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute13              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute14              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute15              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute16              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute17              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute18              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute19              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute20              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute21              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute22              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute23              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute24              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute25              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute26              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute27              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute28              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute29              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute30              in varchar2         default hr_api.g_varchar2,
  p_elig_mrtl_sts_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_gndr_flag               in varchar2         default hr_api.g_varchar2,
  p_elig_dsblty_ctg_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_dsblty_rsn_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_dsblty_dgr_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_suppl_role_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_qual_titl_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_pstn_flag               in varchar2         default hr_api.g_varchar2,
  p_elig_prbtn_perd_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_sp_clng_prg_pt_flag     in varchar2         default hr_api.g_varchar2,
  p_bnft_cagr_prtn_cd            in varchar2         default hr_api.g_varchar2,
  p_elig_dsbld_flag       	 in varchar2 	     default hr_api.g_varchar2,
  p_elig_ttl_cvg_vol_flag 	 in varchar2 	     default hr_api.g_varchar2,
  p_elig_ttl_prtt_flag    	 in varchar2 	     default hr_api.g_varchar2,
  p_elig_comptncy_flag    	 in varchar2 	     default hr_api.g_varchar2,
  p_elig_hlth_cvg_flag  	 in varchar2         default hr_api.g_varchar2,
  p_elig_anthr_pl_flag  	 in varchar2         default hr_api.g_varchar2,
  p_elig_qua_in_gr_flag		 in varchar2         default hr_api.g_varchar2,
  p_elig_perf_rtng_flag		 in varchar2         default hr_api.g_varchar2,
  p_elig_crit_values_flag        in varchar2         default hr_api.g_varchar2,   /* RBC */
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  ) is
--
  l_rec		ben_elp_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_elp_shd.convert_args
  (
  p_eligy_prfl_id,
  null,
  null,
  p_name,
  p_description,
  p_stat_cd,
  p_asmt_to_use_cd,
  p_elig_enrld_plip_flag,
  p_elig_cbr_quald_bnf_flag,
  p_elig_enrld_ptip_flag,
  p_elig_dpnt_cvrd_plip_flag,
  p_elig_dpnt_cvrd_ptip_flag,
  p_elig_dpnt_cvrd_pgm_flag,
  p_elig_job_flag,
  p_elig_hrly_slrd_flag,
  p_elig_pstl_cd_flag,
  p_elig_lbr_mmbr_flag,
  p_elig_lgl_enty_flag,
  p_elig_benfts_grp_flag,
  p_elig_wk_loc_flag,
  p_elig_brgng_unit_flag,
  p_elig_age_flag,
  p_elig_los_flag,
  p_elig_per_typ_flag,
  p_elig_fl_tm_pt_tm_flag,
  p_elig_ee_stat_flag,
  p_elig_grd_flag,
  p_elig_pct_fl_tm_flag,
  p_elig_asnt_set_flag,
  p_elig_hrs_wkd_flag,
  p_elig_comp_lvl_flag,
  p_elig_org_unit_flag,
  p_elig_loa_rsn_flag,
  p_elig_pyrl_flag,
  p_elig_schedd_hrs_flag,
  p_elig_py_bss_flag,
  p_eligy_prfl_rl_flag,
  p_elig_cmbn_age_los_flag,
  p_cntng_prtn_elig_prfl_flag,
  p_elig_prtt_pl_flag,
  p_elig_ppl_grp_flag,
  p_elig_svc_area_flag,
  p_elig_ptip_prte_flag,
  p_elig_no_othr_cvg_flag,
  p_elig_enrld_pl_flag,
  p_elig_enrld_oipl_flag,
  p_elig_enrld_pgm_flag,
  p_elig_dpnt_cvrd_pl_flag,
  p_elig_lvg_rsn_flag,
  p_elig_optd_mdcr_flag,
  p_elig_tbco_use_flag,
  p_elig_dpnt_othr_ptip_flag,
  p_business_group_id,
  p_elp_attribute_category,
  p_elp_attribute1,
  p_elp_attribute2,
  p_elp_attribute3,
  p_elp_attribute4,
  p_elp_attribute5,
  p_elp_attribute6,
  p_elp_attribute7,
  p_elp_attribute8,
  p_elp_attribute9,
  p_elp_attribute10,
  p_elp_attribute11,
  p_elp_attribute12,
  p_elp_attribute13,
  p_elp_attribute14,
  p_elp_attribute15,
  p_elp_attribute16,
  p_elp_attribute17,
  p_elp_attribute18,
  p_elp_attribute19,
  p_elp_attribute20,
  p_elp_attribute21,
  p_elp_attribute22,
  p_elp_attribute23,
  p_elp_attribute24,
  p_elp_attribute25,
  p_elp_attribute26,
  p_elp_attribute27,
  p_elp_attribute28,
  p_elp_attribute29,
  p_elp_attribute30,
  p_elig_mrtl_sts_flag,
  p_elig_gndr_flag,
  p_elig_dsblty_ctg_flag,
  p_elig_dsblty_rsn_flag,
  p_elig_dsblty_dgr_flag,
  p_elig_suppl_role_flag,
  p_elig_qual_titl_flag,
  p_elig_pstn_flag,
  p_elig_prbtn_perd_flag,
  p_elig_sp_clng_prg_pt_flag,
  p_bnft_cagr_prtn_cd,
  p_elig_dsbld_flag,
  p_elig_ttl_cvg_vol_flag,
  p_elig_ttl_prtt_flag,
  p_elig_comptncy_flag,
  p_elig_hlth_cvg_flag,
  p_elig_anthr_pl_flag,
  p_elig_qua_in_gr_flag,
  p_elig_perf_rtng_flag,
  p_elig_crit_values_flag,   /* RBC */
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_elp_upd;

/
