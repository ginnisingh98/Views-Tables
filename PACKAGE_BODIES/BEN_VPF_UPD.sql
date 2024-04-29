--------------------------------------------------------
--  DDL for Package Body BEN_VPF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_VPF_UPD" as
/* $Header: bevpfrhi.pkb 120.1.12010000.1 2008/07/29 13:07:55 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_vpf_upd.';  -- Global package name
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
	(p_rec 			 in out nocopy ben_vpf_shd.g_rec_type,
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
	  (p_base_table_name	=> 'ben_vrbl_rt_prfl_f',
	   p_base_key_column	=> 'vrbl_rt_prfl_id',
	   p_base_key_value	=> p_rec.vrbl_rt_prfl_id);
    --
    ben_vpf_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_vrbl_rt_prfl_f Row
    --
    update  ben_vrbl_rt_prfl_f
    set
        vrbl_rt_prfl_id                 = p_rec.vrbl_rt_prfl_id,
    pl_typ_opt_typ_id               = p_rec.pl_typ_opt_typ_id,
    pl_id                           = p_rec.pl_id,
    oipl_id                         = p_rec.oipl_id,
    comp_lvl_fctr_id                = p_rec.comp_lvl_fctr_id,
    business_group_id               = p_rec.business_group_id,
    acty_typ_cd                     = p_rec.acty_typ_cd,
    rt_typ_cd                       = p_rec.rt_typ_cd,
    bnft_rt_typ_cd                  = p_rec.bnft_rt_typ_cd,
    tx_typ_cd                       = p_rec.tx_typ_cd,
    vrbl_rt_trtmt_cd                = p_rec.vrbl_rt_trtmt_cd,
    acty_ref_perd_cd                = p_rec.acty_ref_perd_cd,
    mlt_cd                          = p_rec.mlt_cd,
    incrmnt_elcn_val                = p_rec.incrmnt_elcn_val,
    dflt_elcn_val                   = p_rec.dflt_elcn_val,
    mx_elcn_val                     = p_rec.mx_elcn_val,
    mn_elcn_val                     = p_rec.mn_elcn_val,
    lwr_lmt_val                     = p_rec.lwr_lmt_val,
    lwr_lmt_calc_rl                 = p_rec.lwr_lmt_calc_rl,
    upr_lmt_val                     = p_rec.upr_lmt_val,
    upr_lmt_calc_rl                 = p_rec.upr_lmt_calc_rl,
    ultmt_upr_lmt                   = p_rec.ultmt_upr_lmt,
    ultmt_lwr_lmt                   = p_rec.ultmt_lwr_lmt,
    ultmt_upr_lmt_calc_rl           = p_rec.ultmt_upr_lmt_calc_rl,
    ultmt_lwr_lmt_calc_rl           = p_rec.ultmt_lwr_lmt_calc_rl,
    ann_mn_elcn_val                 = p_rec.ann_mn_elcn_val,
    ann_mx_elcn_val                 = p_rec.ann_mx_elcn_val,
    val                             = p_rec.val,
    name                            = p_rec.name,
    no_mn_elcn_val_dfnd_flag        = p_rec.no_mn_elcn_val_dfnd_flag,
    no_mx_elcn_val_dfnd_flag        = p_rec.no_mx_elcn_val_dfnd_flag,
    alwys_sum_all_cvg_flag          = p_rec.alwys_sum_all_cvg_flag,
    alwys_cnt_all_prtts_flag        = p_rec.alwys_cnt_all_prtts_flag,
    val_calc_rl                     = p_rec.val_calc_rl,
    vrbl_rt_prfl_stat_cd            = p_rec.vrbl_rt_prfl_stat_cd,
    vrbl_usg_cd                     = p_rec.vrbl_usg_cd,
    asmt_to_use_cd                  = p_rec.asmt_to_use_cd,
    rndg_cd                         = p_rec.rndg_cd,
    rndg_rl                         = p_rec.rndg_rl,
    rt_hrly_slrd_flag               = p_rec.rt_hrly_slrd_flag,
    rt_pstl_cd_flag                 = p_rec.rt_pstl_cd_flag,
    rt_lbr_mmbr_flag                = p_rec.rt_lbr_mmbr_flag,
    rt_lgl_enty_flag                = p_rec.rt_lgl_enty_flag,
    rt_benfts_grp_flag              = p_rec.rt_benfts_grp_flag,
    rt_wk_loc_flag                  = p_rec.rt_wk_loc_flag,
    rt_brgng_unit_flag              = p_rec.rt_brgng_unit_flag,
    rt_age_flag                     = p_rec.rt_age_flag,
    rt_los_flag                     = p_rec.rt_los_flag,
    rt_per_typ_flag                 = p_rec.rt_per_typ_flag,
    rt_fl_tm_pt_tm_flag             = p_rec.rt_fl_tm_pt_tm_flag,
    rt_ee_stat_flag                 = p_rec.rt_ee_stat_flag,
    rt_grd_flag                     = p_rec.rt_grd_flag,
    rt_pct_fl_tm_flag               = p_rec.rt_pct_fl_tm_flag,
    rt_asnt_set_flag                = p_rec.rt_asnt_set_flag,
    rt_hrs_wkd_flag                 = p_rec.rt_hrs_wkd_flag,
    rt_comp_lvl_flag                = p_rec.rt_comp_lvl_flag,
    rt_org_unit_flag                = p_rec.rt_org_unit_flag,
    rt_loa_rsn_flag                 = p_rec.rt_loa_rsn_flag,
    rt_pyrl_flag                    = p_rec.rt_pyrl_flag,
    rt_schedd_hrs_flag              = p_rec.rt_schedd_hrs_flag,
    rt_py_bss_flag                  = p_rec.rt_py_bss_flag,
    rt_prfl_rl_flag                 = p_rec.rt_prfl_rl_flag,
    rt_cmbn_age_los_flag            = p_rec.rt_cmbn_age_los_flag,
    rt_prtt_pl_flag                 = p_rec.rt_prtt_pl_flag,
    rt_svc_area_flag                = p_rec.rt_svc_area_flag,
    rt_ppl_grp_flag                 = p_rec.rt_ppl_grp_flag,
    rt_dsbld_flag                   = p_rec.rt_dsbld_flag,
    rt_hlth_cvg_flag                = p_rec.rt_hlth_cvg_flag,
    rt_poe_flag                     = p_rec.rt_poe_flag,
    rt_ttl_cvg_vol_flag             = p_rec.rt_ttl_cvg_vol_flag,
    rt_ttl_prtt_flag                = p_rec.rt_ttl_prtt_flag,
    rt_gndr_flag                    = p_rec.rt_gndr_flag,
    rt_tbco_use_flag                = p_rec.rt_tbco_use_flag,
    vpf_attribute_category          = p_rec.vpf_attribute_category,
    vpf_attribute1                  = p_rec.vpf_attribute1,
    vpf_attribute2                  = p_rec.vpf_attribute2,
    vpf_attribute3                  = p_rec.vpf_attribute3,
    vpf_attribute4                  = p_rec.vpf_attribute4,
    vpf_attribute5                  = p_rec.vpf_attribute5,
    vpf_attribute6                  = p_rec.vpf_attribute6,
    vpf_attribute7                  = p_rec.vpf_attribute7,
    vpf_attribute8                  = p_rec.vpf_attribute8,
    vpf_attribute9                  = p_rec.vpf_attribute9,
    vpf_attribute10                 = p_rec.vpf_attribute10,
    vpf_attribute11                 = p_rec.vpf_attribute11,
    vpf_attribute12                 = p_rec.vpf_attribute12,
    vpf_attribute13                 = p_rec.vpf_attribute13,
    vpf_attribute14                 = p_rec.vpf_attribute14,
    vpf_attribute15                 = p_rec.vpf_attribute15,
    vpf_attribute16                 = p_rec.vpf_attribute16,
    vpf_attribute17                 = p_rec.vpf_attribute17,
    vpf_attribute18                 = p_rec.vpf_attribute18,
    vpf_attribute19                 = p_rec.vpf_attribute19,
    vpf_attribute20                 = p_rec.vpf_attribute20,
    vpf_attribute21                 = p_rec.vpf_attribute21,
    vpf_attribute22                 = p_rec.vpf_attribute22,
    vpf_attribute23                 = p_rec.vpf_attribute23,
    vpf_attribute24                 = p_rec.vpf_attribute24,
    vpf_attribute25                 = p_rec.vpf_attribute25,
    vpf_attribute26                 = p_rec.vpf_attribute26,
    vpf_attribute27                 = p_rec.vpf_attribute27,
    vpf_attribute28                 = p_rec.vpf_attribute28,
    vpf_attribute29                 = p_rec.vpf_attribute29,
    vpf_attribute30                 = p_rec.vpf_attribute30,
    object_version_number           = p_rec.object_version_number,
    rt_cntng_prtn_prfl_flag         = p_rec.rt_cntng_prtn_prfl_flag,
    rt_cbr_quald_bnf_flag           = p_rec.rt_cbr_quald_bnf_flag,
    rt_optd_mdcr_flag               = p_rec.rt_optd_mdcr_flag,
    rt_lvg_rsn_flag                 = p_rec.rt_lvg_rsn_flag,
    rt_pstn_flag                    = p_rec.rt_pstn_flag ,
    rt_comptncy_flag                = p_rec.rt_comptncy_flag ,
    rt_job_flag                     = p_rec.rt_job_flag  ,
    rt_qual_titl_flag               = p_rec.rt_qual_titl_flag,
    rt_dpnt_cvrd_pl_flag            = p_rec.rt_dpnt_cvrd_pl_flag ,
    rt_dpnt_cvrd_plip_flag          = p_rec.rt_dpnt_cvrd_plip_flag ,
    rt_dpnt_cvrd_ptip_flag          = p_rec.rt_dpnt_cvrd_ptip_flag ,
    rt_dpnt_cvrd_pgm_flag           = p_rec.rt_dpnt_cvrd_pgm_flag,
    rt_enrld_oipl_flag              = p_rec.rt_enrld_oipl_flag,
    rt_enrld_pl_flag                = p_rec.rt_enrld_pl_flag  ,
    rt_enrld_plip_flag              = p_rec.rt_enrld_plip_flag,
    rt_enrld_ptip_flag              = p_rec.rt_enrld_ptip_flag,
    rt_enrld_pgm_flag               = p_rec.rt_enrld_pgm_flag ,
    rt_prtt_anthr_pl_flag           = p_rec.rt_prtt_anthr_pl_flag,
    rt_othr_ptip_flag               = p_rec.rt_othr_ptip_flag  ,
    rt_no_othr_cvg_flag             = p_rec.rt_no_othr_cvg_flag,
    rt_dpnt_othr_ptip_flag          = p_rec.rt_dpnt_othr_ptip_flag,
    rt_qua_in_gr_flag    	    = p_rec.rt_qua_in_gr_flag ,
    rt_perf_rtng_flag 	    	    = p_rec.rt_perf_rtng_flag,
    rt_elig_prfl_flag    	    = p_rec.rt_elig_prfl_flag
    where   vrbl_rt_prfl_id 	    = p_rec.vrbl_rt_prfl_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_vpf_shd.g_api_dml := false;   -- Unset the api dml status
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
    ben_vpf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_vpf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_vpf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_vpf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_vpf_shd.g_api_dml := false;   -- Unset the api dml status
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
	(p_rec 			 in out nocopy ben_vpf_shd.g_rec_type,
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
	(p_rec 			 in out nocopy ben_vpf_shd.g_rec_type,
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
    ben_vpf_shd.upd_effective_end_date
     (p_effective_date	       => p_effective_date,
      p_base_key_value	       => p_rec.vrbl_rt_prfl_id,
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
      ben_vpf_del.delete_dml
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
    ben_vpf_ins.insert_dml
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
	(p_rec 			 in out nocopy ben_vpf_shd.g_rec_type,
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
	(p_rec 			 in ben_vpf_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
  --
  l_proc	varchar2(72) := g_package||'post_update';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    ben_vpf_rku.after_update
      (p_vrbl_rt_prfl_id           =>p_rec.vrbl_rt_prfl_id
      ,p_effective_start_date      =>p_rec.effective_start_date
      ,p_effective_end_date        =>p_rec.effective_end_date
      ,p_pl_typ_opt_typ_id         =>p_rec.pl_typ_opt_typ_id
      ,p_pl_id                     =>p_rec.pl_id
      ,p_oipl_id                   =>p_rec.oipl_id
      ,p_comp_lvl_fctr_id          =>p_rec.comp_lvl_fctr_id
      ,p_business_group_id         =>p_rec.business_group_id
      ,p_acty_typ_cd               =>p_rec.acty_typ_cd
      ,p_rt_typ_cd                 =>p_rec.rt_typ_cd
      ,p_bnft_rt_typ_cd            =>p_rec.bnft_rt_typ_cd
      ,p_tx_typ_cd                 =>p_rec.tx_typ_cd
      ,p_vrbl_rt_trtmt_cd          =>p_rec.vrbl_rt_trtmt_cd
      ,p_acty_ref_perd_cd          =>p_rec.acty_ref_perd_cd
      ,p_mlt_cd                    =>p_rec.mlt_cd
      ,p_incrmnt_elcn_val          =>p_rec.incrmnt_elcn_val
      ,p_dflt_elcn_val             =>p_rec.dflt_elcn_val
      ,p_mx_elcn_val               =>p_rec.mx_elcn_val
      ,p_mn_elcn_val               =>p_rec.mn_elcn_val
      ,p_lwr_lmt_val               =>p_rec.lwr_lmt_val
      ,p_lwr_lmt_calc_rl           =>p_rec.lwr_lmt_calc_rl
      ,p_upr_lmt_val               =>p_rec.upr_lmt_val
      ,p_upr_lmt_calc_rl           =>p_rec.upr_lmt_calc_rl
      ,p_ultmt_upr_lmt             =>p_rec.ultmt_upr_lmt
      ,p_ultmt_lwr_lmt             =>p_rec.ultmt_lwr_lmt
      ,p_ultmt_upr_lmt_calc_rl     =>p_rec.ultmt_upr_lmt_calc_rl
      ,p_ultmt_lwr_lmt_calc_rl     =>p_rec.ultmt_lwr_lmt_calc_rl
      ,p_ann_mn_elcn_val           =>p_rec.ann_mn_elcn_val
      ,p_ann_mx_elcn_val           =>p_rec.ann_mx_elcn_val
      ,p_val                       =>p_rec.val
      ,p_name                      =>p_rec.name
      ,p_no_mn_elcn_val_dfnd_flag  =>p_rec.no_mn_elcn_val_dfnd_flag
      ,p_no_mx_elcn_val_dfnd_flag  =>p_rec.no_mx_elcn_val_dfnd_flag
      ,p_alwys_sum_all_cvg_flag    =>p_rec.alwys_sum_all_cvg_flag
      ,p_alwys_cnt_all_prtts_flag  =>p_rec.alwys_cnt_all_prtts_flag
      ,p_val_calc_rl               =>p_rec.val_calc_rl
      ,p_vrbl_rt_prfl_stat_cd      =>p_rec.vrbl_rt_prfl_stat_cd
      ,p_vrbl_usg_cd               =>p_rec.vrbl_usg_cd
      ,p_asmt_to_use_cd            =>p_rec.asmt_to_use_cd
      ,p_rndg_cd                   =>p_rec.rndg_cd
      ,p_rndg_rl                   =>p_rec.rndg_rl
      ,p_rt_hrly_slrd_flag         =>p_rec.rt_hrly_slrd_flag
      ,p_rt_pstl_cd_flag           =>p_rec.rt_pstl_cd_flag
      ,p_rt_lbr_mmbr_flag          =>p_rec.rt_lbr_mmbr_flag
      ,p_rt_lgl_enty_flag          =>p_rec.rt_lgl_enty_flag
      ,p_rt_benfts_grp_flag        =>p_rec.rt_benfts_grp_flag
      ,p_rt_wk_loc_flag            =>p_rec.rt_wk_loc_flag
      ,p_rt_brgng_unit_flag        =>p_rec.rt_brgng_unit_flag
      ,p_rt_age_flag               =>p_rec.rt_age_flag
      ,p_rt_los_flag               =>p_rec.rt_los_flag
      ,p_rt_per_typ_flag           =>p_rec.rt_per_typ_flag
      ,p_rt_fl_tm_pt_tm_flag       =>p_rec.rt_fl_tm_pt_tm_flag
      ,p_rt_ee_stat_flag           =>p_rec.rt_ee_stat_flag
      ,p_rt_grd_flag               =>p_rec.rt_grd_flag
      ,p_rt_pct_fl_tm_flag         =>p_rec.rt_pct_fl_tm_flag
      ,p_rt_asnt_set_flag          =>p_rec.rt_asnt_set_flag
      ,p_rt_hrs_wkd_flag           =>p_rec.rt_hrs_wkd_flag
      ,p_rt_comp_lvl_flag          =>p_rec.rt_comp_lvl_flag
      ,p_rt_org_unit_flag          =>p_rec.rt_org_unit_flag
      ,p_rt_loa_rsn_flag           =>p_rec.rt_loa_rsn_flag
      ,p_rt_pyrl_flag              =>p_rec.rt_pyrl_flag
      ,p_rt_schedd_hrs_flag        =>p_rec.rt_schedd_hrs_flag
      ,p_rt_py_bss_flag            =>p_rec.rt_py_bss_flag
      ,p_rt_prfl_rl_flag           =>p_rec.rt_prfl_rl_flag
      ,p_rt_cmbn_age_los_flag      =>p_rec.rt_cmbn_age_los_flag
      ,p_rt_prtt_pl_flag           =>p_rec.rt_prtt_pl_flag
      ,p_rt_svc_area_flag          =>p_rec.rt_svc_area_flag
      ,p_rt_ppl_grp_flag           =>p_rec.rt_ppl_grp_flag
      ,p_rt_dsbld_flag             =>p_rec.rt_dsbld_flag
      ,p_rt_hlth_cvg_flag          =>p_rec.rt_hlth_cvg_flag
      ,p_rt_poe_flag               =>p_rec.rt_poe_flag
      ,p_rt_ttl_cvg_vol_flag       =>p_rec.rt_ttl_cvg_vol_flag
      ,p_rt_ttl_prtt_flag          =>p_rec.rt_ttl_prtt_flag
      ,p_rt_gndr_flag              =>p_rec.rt_gndr_flag
      ,p_rt_tbco_use_flag          =>p_rec.rt_tbco_use_flag
      ,p_vpf_attribute_category    =>p_rec.vpf_attribute_category
      ,p_vpf_attribute1            =>p_rec.vpf_attribute1
      ,p_vpf_attribute2            =>p_rec.vpf_attribute2
      ,p_vpf_attribute3            =>p_rec.vpf_attribute3
      ,p_vpf_attribute4            =>p_rec.vpf_attribute4
      ,p_vpf_attribute5            =>p_rec.vpf_attribute5
      ,p_vpf_attribute6            =>p_rec.vpf_attribute6
      ,p_vpf_attribute7            =>p_rec.vpf_attribute7
      ,p_vpf_attribute8            =>p_rec.vpf_attribute8
      ,p_vpf_attribute9            =>p_rec.vpf_attribute9
      ,p_vpf_attribute10           =>p_rec.vpf_attribute10
      ,p_vpf_attribute11           =>p_rec.vpf_attribute11
      ,p_vpf_attribute12           =>p_rec.vpf_attribute12
      ,p_vpf_attribute13           =>p_rec.vpf_attribute13
      ,p_vpf_attribute14           =>p_rec.vpf_attribute14
      ,p_vpf_attribute15           =>p_rec.vpf_attribute15
      ,p_vpf_attribute16           =>p_rec.vpf_attribute16
      ,p_vpf_attribute17           =>p_rec.vpf_attribute17
      ,p_vpf_attribute18           =>p_rec.vpf_attribute18
      ,p_vpf_attribute19           =>p_rec.vpf_attribute19
      ,p_vpf_attribute20           =>p_rec.vpf_attribute20
      ,p_vpf_attribute21           =>p_rec.vpf_attribute21
      ,p_vpf_attribute22           =>p_rec.vpf_attribute22
      ,p_vpf_attribute23           =>p_rec.vpf_attribute23
      ,p_vpf_attribute24           =>p_rec.vpf_attribute24
      ,p_vpf_attribute25           =>p_rec.vpf_attribute25
      ,p_vpf_attribute26           =>p_rec.vpf_attribute26
      ,p_vpf_attribute27           =>p_rec.vpf_attribute27
      ,p_vpf_attribute28           =>p_rec.vpf_attribute28
      ,p_vpf_attribute29           =>p_rec.vpf_attribute29
      ,p_vpf_attribute30           =>p_rec.vpf_attribute30
      ,p_object_version_number     =>p_rec.object_version_number
      ,p_effective_date            =>p_effective_date
      ,p_datetrack_mode            =>p_datetrack_mode
      ,p_validation_start_date     =>p_validation_start_date
      ,p_validation_end_date       =>p_validation_end_date
      ,p_rt_cntng_prtn_prfl_flag   =>p_rec.rt_cntng_prtn_prfl_flag
      ,p_rt_cbr_quald_bnf_flag     =>p_rec.rt_cbr_quald_bnf_flag
      ,p_rt_optd_mdcr_flag         =>p_rec.rt_optd_mdcr_flag
      ,p_rt_lvg_rsn_flag           =>p_rec.rt_lvg_rsn_flag
      ,p_rt_pstn_flag              =>p_rec.rt_pstn_flag
      ,p_rt_comptncy_flag          =>p_rec.rt_comptncy_flag
      ,p_rt_job_flag               =>p_rec.rt_job_flag
      ,p_rt_qual_titl_flag         =>p_rec.rt_qual_titl_flag
      ,p_rt_dpnt_cvrd_pl_flag      =>p_rec.rt_dpnt_cvrd_pl_flag
      ,p_rt_dpnt_cvrd_plip_flag    =>p_rec.rt_dpnt_cvrd_plip_flag
      ,p_rt_dpnt_cvrd_ptip_flag    =>p_rec.rt_dpnt_cvrd_ptip_flag
      ,p_rt_dpnt_cvrd_pgm_flag     =>p_rec.rt_dpnt_cvrd_pgm_flag
      ,p_rt_enrld_oipl_flag        =>p_rec.rt_enrld_oipl_flag
      ,p_rt_enrld_pl_flag          =>p_rec.rt_enrld_pl_flag
      ,p_rt_enrld_plip_flag        =>p_rec.rt_enrld_plip_flag
      ,p_rt_enrld_ptip_flag        =>p_rec.rt_enrld_ptip_flag
      ,p_rt_enrld_pgm_flag         =>p_rec.rt_enrld_pgm_flag
      ,p_rt_prtt_anthr_pl_flag     =>p_rec.rt_prtt_anthr_pl_flag
      ,p_rt_othr_ptip_flag         =>p_rec.rt_othr_ptip_flag
      ,p_rt_no_othr_cvg_flag       =>p_rec.rt_no_othr_cvg_flag
      ,p_rt_dpnt_othr_ptip_flag    =>p_rec.rt_dpnt_othr_ptip_flag
      ,p_rt_qua_in_gr_flag    	   =>p_rec.rt_qua_in_gr_flag
      ,p_rt_perf_rtng_flag 	   =>p_rec.rt_perf_rtng_flag
      ,p_rt_elig_prfl_flag 	   =>p_rec.rt_elig_prfl_flag
      ,p_effective_start_date_o    =>ben_vpf_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o      =>ben_vpf_shd.g_old_rec.effective_end_date
      ,p_pl_typ_opt_typ_id_o       =>ben_vpf_shd.g_old_rec.pl_typ_opt_typ_id
      ,p_pl_id_o                   =>ben_vpf_shd.g_old_rec.pl_id
      ,p_oipl_id_o                 =>ben_vpf_shd.g_old_rec.oipl_id
      ,p_comp_lvl_fctr_id_o        =>ben_vpf_shd.g_old_rec.comp_lvl_fctr_id
      ,p_business_group_id_o       =>ben_vpf_shd.g_old_rec.business_group_id
      ,p_acty_typ_cd_o             =>ben_vpf_shd.g_old_rec.acty_typ_cd
      ,p_rt_typ_cd_o               =>ben_vpf_shd.g_old_rec.rt_typ_cd
      ,p_bnft_rt_typ_cd_o          =>ben_vpf_shd.g_old_rec.bnft_rt_typ_cd
      ,p_tx_typ_cd_o               =>ben_vpf_shd.g_old_rec.tx_typ_cd
      ,p_vrbl_rt_trtmt_cd_o        =>ben_vpf_shd.g_old_rec.vrbl_rt_trtmt_cd
      ,p_acty_ref_perd_cd_o        =>ben_vpf_shd.g_old_rec.acty_ref_perd_cd
      ,p_mlt_cd_o                  =>ben_vpf_shd.g_old_rec.mlt_cd
      ,p_incrmnt_elcn_val_o        =>ben_vpf_shd.g_old_rec.incrmnt_elcn_val
      ,p_dflt_elcn_val_o           =>ben_vpf_shd.g_old_rec.dflt_elcn_val
      ,p_mx_elcn_val_o             =>ben_vpf_shd.g_old_rec.mx_elcn_val
      ,p_mn_elcn_val_o             =>ben_vpf_shd.g_old_rec.mn_elcn_val
      ,p_lwr_lmt_val_o             =>ben_vpf_shd.g_old_rec.lwr_lmt_val
      ,p_lwr_lmt_calc_rl_o         =>ben_vpf_shd.g_old_rec.lwr_lmt_calc_rl
      ,p_upr_lmt_val_o             =>ben_vpf_shd.g_old_rec.upr_lmt_val
      ,p_upr_lmt_calc_rl_o         =>ben_vpf_shd.g_old_rec.upr_lmt_calc_rl
      ,p_ultmt_upr_lmt_o           =>ben_vpf_shd.g_old_rec.ultmt_upr_lmt
      ,p_ultmt_lwr_lmt_calc_rl_o   =>ben_vpf_shd.g_old_rec.ultmt_lwr_lmt_calc_rl
      ,p_ultmt_upr_lmt_calc_rl_o   =>ben_vpf_shd.g_old_rec.ultmt_upr_lmt_calc_rl
      ,p_ultmt_lwr_lmt_o           =>ben_vpf_shd.g_old_rec.ultmt_lwr_lmt
      ,p_ann_mn_elcn_val_o         =>ben_vpf_shd.g_old_rec.ann_mn_elcn_val
      ,p_ann_mx_elcn_val_o         =>ben_vpf_shd.g_old_rec.ann_mx_elcn_val
      ,p_val_o                     =>ben_vpf_shd.g_old_rec.val
      ,p_name_o                    =>ben_vpf_shd.g_old_rec.name
      ,p_no_mn_elcn_val_dfnd_flag_o =>ben_vpf_shd.g_old_rec.no_mn_elcn_val_dfnd_flag
      ,p_no_mx_elcn_val_dfnd_flag_o =>ben_vpf_shd.g_old_rec.no_mx_elcn_val_dfnd_flag
      ,p_alwys_sum_all_cvg_flag_o   =>ben_vpf_shd.g_old_rec.alwys_sum_all_cvg_flag
      ,p_alwys_cnt_all_prtts_flag_o =>ben_vpf_shd.g_old_rec.alwys_cnt_all_prtts_flag
      ,p_val_calc_rl_o             =>ben_vpf_shd.g_old_rec.val_calc_rl
      ,p_vrbl_rt_prfl_stat_cd_o    =>ben_vpf_shd.g_old_rec.vrbl_rt_prfl_stat_cd
      ,p_vrbl_usg_cd_o             =>ben_vpf_shd.g_old_rec.vrbl_usg_cd
      ,p_asmt_to_use_cd_o          =>ben_vpf_shd.g_old_rec.asmt_to_use_cd
      ,p_rndg_cd_o                 =>ben_vpf_shd.g_old_rec.rndg_cd
      ,p_rndg_rl_o                 =>ben_vpf_shd.g_old_rec.rndg_rl
      ,p_rt_hrly_slrd_flag_o       =>ben_vpf_shd.g_old_rec.rt_hrly_slrd_flag
      ,p_rt_pstl_cd_flag_o         =>ben_vpf_shd.g_old_rec.rt_pstl_cd_flag
      ,p_rt_lbr_mmbr_flag_o        =>ben_vpf_shd.g_old_rec.rt_lbr_mmbr_flag
      ,p_rt_lgl_enty_flag_o        =>ben_vpf_shd.g_old_rec.rt_lgl_enty_flag
      ,p_rt_benfts_grp_flag_o      =>ben_vpf_shd.g_old_rec.rt_benfts_grp_flag
      ,p_rt_wk_loc_flag_o          =>ben_vpf_shd.g_old_rec.rt_wk_loc_flag
      ,p_rt_brgng_unit_flag_o      =>ben_vpf_shd.g_old_rec.rt_brgng_unit_flag
      ,p_rt_age_flag_o             =>ben_vpf_shd.g_old_rec.rt_age_flag
      ,p_rt_los_flag_o             =>ben_vpf_shd.g_old_rec.rt_los_flag
      ,p_rt_per_typ_flag_o         =>ben_vpf_shd.g_old_rec.rt_per_typ_flag
      ,p_rt_fl_tm_pt_tm_flag_o     =>ben_vpf_shd.g_old_rec.rt_fl_tm_pt_tm_flag
      ,p_rt_ee_stat_flag_o         =>ben_vpf_shd.g_old_rec.rt_ee_stat_flag
      ,p_rt_grd_flag_o             =>ben_vpf_shd.g_old_rec.rt_grd_flag
      ,p_rt_pct_fl_tm_flag_o       =>ben_vpf_shd.g_old_rec.rt_pct_fl_tm_flag
      ,p_rt_asnt_set_flag_o        =>ben_vpf_shd.g_old_rec.rt_asnt_set_flag
      ,p_rt_hrs_wkd_flag_o         =>ben_vpf_shd.g_old_rec.rt_hrs_wkd_flag
      ,p_rt_comp_lvl_flag_o        =>ben_vpf_shd.g_old_rec.rt_comp_lvl_flag
      ,p_rt_org_unit_flag_o        =>ben_vpf_shd.g_old_rec.rt_org_unit_flag
      ,p_rt_loa_rsn_flag_o         =>ben_vpf_shd.g_old_rec.rt_loa_rsn_flag
      ,p_rt_pyrl_flag_o            =>ben_vpf_shd.g_old_rec.rt_pyrl_flag
      ,p_rt_schedd_hrs_flag_o      =>ben_vpf_shd.g_old_rec.rt_schedd_hrs_flag
      ,p_rt_py_bss_flag_o          =>ben_vpf_shd.g_old_rec.rt_py_bss_flag
      ,p_rt_prfl_rl_flag_o         =>ben_vpf_shd.g_old_rec.rt_prfl_rl_flag
      ,p_rt_cmbn_age_los_flag_o    =>ben_vpf_shd.g_old_rec.rt_cmbn_age_los_flag
      ,p_rt_prtt_pl_flag_o         =>ben_vpf_shd.g_old_rec.rt_prtt_pl_flag
      ,p_rt_svc_area_flag_o        =>ben_vpf_shd.g_old_rec.rt_svc_area_flag
      ,p_rt_ppl_grp_flag_o         =>ben_vpf_shd.g_old_rec.rt_ppl_grp_flag
      ,p_rt_dsbld_flag_o           =>ben_vpf_shd.g_old_rec.rt_dsbld_flag
      ,p_rt_hlth_cvg_flag_o        =>ben_vpf_shd.g_old_rec.rt_hlth_cvg_flag
      ,p_rt_poe_flag_o             =>ben_vpf_shd.g_old_rec.rt_poe_flag
      ,p_rt_ttl_cvg_vol_flag_o     =>ben_vpf_shd.g_old_rec.rt_ttl_cvg_vol_flag
      ,p_rt_ttl_prtt_flag_o        =>ben_vpf_shd.g_old_rec.rt_ttl_prtt_flag
      ,p_rt_gndr_flag_o            =>ben_vpf_shd.g_old_rec.rt_gndr_flag
      ,p_rt_tbco_use_flag_o        =>ben_vpf_shd.g_old_rec.rt_tbco_use_flag
      ,p_vpf_attribute_category_o  =>ben_vpf_shd.g_old_rec.vpf_attribute_category
      ,p_vpf_attribute1_o          =>ben_vpf_shd.g_old_rec.vpf_attribute1
      ,p_vpf_attribute2_o          =>ben_vpf_shd.g_old_rec.vpf_attribute2
      ,p_vpf_attribute3_o          =>ben_vpf_shd.g_old_rec.vpf_attribute3
      ,p_vpf_attribute4_o          =>ben_vpf_shd.g_old_rec.vpf_attribute4
      ,p_vpf_attribute5_o          =>ben_vpf_shd.g_old_rec.vpf_attribute5
      ,p_vpf_attribute6_o          =>ben_vpf_shd.g_old_rec.vpf_attribute6
      ,p_vpf_attribute7_o          =>ben_vpf_shd.g_old_rec.vpf_attribute7
      ,p_vpf_attribute8_o          =>ben_vpf_shd.g_old_rec.vpf_attribute8
      ,p_vpf_attribute9_o          =>ben_vpf_shd.g_old_rec.vpf_attribute9
      ,p_vpf_attribute10_o         =>ben_vpf_shd.g_old_rec.vpf_attribute10
      ,p_vpf_attribute11_o         =>ben_vpf_shd.g_old_rec.vpf_attribute11
      ,p_vpf_attribute12_o         =>ben_vpf_shd.g_old_rec.vpf_attribute12
      ,p_vpf_attribute13_o         =>ben_vpf_shd.g_old_rec.vpf_attribute13
      ,p_vpf_attribute14_o         =>ben_vpf_shd.g_old_rec.vpf_attribute14
      ,p_vpf_attribute15_o         =>ben_vpf_shd.g_old_rec.vpf_attribute15
      ,p_vpf_attribute16_o         =>ben_vpf_shd.g_old_rec.vpf_attribute16
      ,p_vpf_attribute17_o         =>ben_vpf_shd.g_old_rec.vpf_attribute17
      ,p_vpf_attribute18_o         =>ben_vpf_shd.g_old_rec.vpf_attribute18
      ,p_vpf_attribute19_o         =>ben_vpf_shd.g_old_rec.vpf_attribute19
      ,p_vpf_attribute20_o         =>ben_vpf_shd.g_old_rec.vpf_attribute20
      ,p_vpf_attribute21_o         =>ben_vpf_shd.g_old_rec.vpf_attribute21
      ,p_vpf_attribute22_o         =>ben_vpf_shd.g_old_rec.vpf_attribute22
      ,p_vpf_attribute23_o         =>ben_vpf_shd.g_old_rec.vpf_attribute23
      ,p_vpf_attribute24_o         =>ben_vpf_shd.g_old_rec.vpf_attribute24
      ,p_vpf_attribute25_o         =>ben_vpf_shd.g_old_rec.vpf_attribute25
      ,p_vpf_attribute26_o         =>ben_vpf_shd.g_old_rec.vpf_attribute26
      ,p_vpf_attribute27_o         =>ben_vpf_shd.g_old_rec.vpf_attribute27
      ,p_vpf_attribute28_o         =>ben_vpf_shd.g_old_rec.vpf_attribute28
      ,p_vpf_attribute29_o         =>ben_vpf_shd.g_old_rec.vpf_attribute29
      ,p_vpf_attribute30_o         =>ben_vpf_shd.g_old_rec.vpf_attribute30
      ,p_object_version_number_o   =>ben_vpf_shd.g_old_rec.object_version_number
      ,p_rt_cntng_prtn_prfl_flag_o =>ben_vpf_shd.g_old_rec.rt_cntng_prtn_prfl_flag
      ,p_rt_cbr_quald_bnf_flag_o   =>ben_vpf_shd.g_old_rec.rt_cbr_quald_bnf_flag
      ,p_rt_optd_mdcr_flag_o       =>ben_vpf_shd.g_old_rec.rt_optd_mdcr_flag
      ,p_rt_lvg_rsn_flag_o         =>ben_vpf_shd.g_old_rec.rt_lvg_rsn_flag
      ,p_rt_pstn_flag_o            =>ben_vpf_shd.g_old_rec.rt_pstn_flag
      ,p_rt_comptncy_flag_o        =>ben_vpf_shd.g_old_rec.rt_comptncy_flag
      ,p_rt_job_flag_o             =>ben_vpf_shd.g_old_rec.rt_job_flag
      ,p_rt_qual_titl_flag_o       =>ben_vpf_shd.g_old_rec.rt_qual_titl_flag
      ,p_rt_dpnt_cvrd_pl_flag_o    =>ben_vpf_shd.g_old_rec.rt_dpnt_cvrd_pl_flag
      ,p_rt_dpnt_cvrd_plip_flag_o  =>ben_vpf_shd.g_old_rec.rt_dpnt_cvrd_plip_flag
      ,p_rt_dpnt_cvrd_ptip_flag_o  =>ben_vpf_shd.g_old_rec.rt_dpnt_cvrd_ptip_flag
      ,p_rt_dpnt_cvrd_pgm_flag_o   =>ben_vpf_shd.g_old_rec.rt_dpnt_cvrd_pgm_flag
      ,p_rt_enrld_oipl_flag_o      =>ben_vpf_shd.g_old_rec.rt_enrld_oipl_flag
      ,p_rt_enrld_pl_flag_o        =>ben_vpf_shd.g_old_rec.rt_enrld_pl_flag
      ,p_rt_enrld_plip_flag_o      =>ben_vpf_shd.g_old_rec.rt_enrld_plip_flag
      ,p_rt_enrld_ptip_flag_o      =>ben_vpf_shd.g_old_rec.rt_enrld_ptip_flag
      ,p_rt_enrld_pgm_flag_o       =>ben_vpf_shd.g_old_rec.rt_enrld_pgm_flag
      ,p_rt_prtt_anthr_pl_flag_o   =>ben_vpf_shd.g_old_rec.rt_prtt_anthr_pl_flag
      ,p_rt_othr_ptip_flag_o       =>ben_vpf_shd.g_old_rec.rt_othr_ptip_flag
      ,p_rt_no_othr_cvg_flag_o     =>ben_vpf_shd.g_old_rec.rt_no_othr_cvg_flag
      ,p_rt_dpnt_othr_ptip_flag_o  =>ben_vpf_shd.g_old_rec.rt_dpnt_othr_ptip_flag
      ,p_rt_qua_in_gr_flag_o   	   =>ben_vpf_shd.g_old_rec.rt_qua_in_gr_flag
      ,p_rt_perf_rtng_flag_o 	   =>ben_vpf_shd.g_old_rec.rt_perf_rtng_flag
      ,p_rt_elig_prfl_flag_o 	   =>ben_vpf_shd.g_old_rec.rt_elig_prfl_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_vrbl_rt_prfl_f'
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
Procedure convert_defs(p_rec in out nocopy ben_vpf_shd.g_rec_type) is
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
  If (p_rec.pl_typ_opt_typ_id = hr_api.g_number) then
    p_rec.pl_typ_opt_typ_id :=
    ben_vpf_shd.g_old_rec.pl_typ_opt_typ_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_vpf_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.oipl_id = hr_api.g_number) then
    p_rec.oipl_id :=
    ben_vpf_shd.g_old_rec.oipl_id;
  End If;
  If (p_rec.comp_lvl_fctr_id = hr_api.g_number) then
    p_rec.comp_lvl_fctr_id :=
    ben_vpf_shd.g_old_rec.comp_lvl_fctr_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_vpf_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.acty_typ_cd = hr_api.g_varchar2) then
    p_rec.acty_typ_cd :=
    ben_vpf_shd.g_old_rec.acty_typ_cd;
  End If;
  If (p_rec.rt_typ_cd = hr_api.g_varchar2) then
    p_rec.rt_typ_cd :=
    ben_vpf_shd.g_old_rec.rt_typ_cd;
  End If;
  If (p_rec.bnft_rt_typ_cd = hr_api.g_varchar2) then
    p_rec.bnft_rt_typ_cd :=
    ben_vpf_shd.g_old_rec.bnft_rt_typ_cd;
  End If;
  If (p_rec.tx_typ_cd = hr_api.g_varchar2) then
    p_rec.tx_typ_cd :=
    ben_vpf_shd.g_old_rec.tx_typ_cd;
  End If;
  If (p_rec.vrbl_rt_trtmt_cd = hr_api.g_varchar2) then
    p_rec.vrbl_rt_trtmt_cd :=
    ben_vpf_shd.g_old_rec.vrbl_rt_trtmt_cd;
  End If;
  If (p_rec.acty_ref_perd_cd = hr_api.g_varchar2) then
    p_rec.acty_ref_perd_cd :=
    ben_vpf_shd.g_old_rec.acty_ref_perd_cd;
  End If;
  If (p_rec.mlt_cd = hr_api.g_varchar2) then
    p_rec.mlt_cd :=
    ben_vpf_shd.g_old_rec.mlt_cd;
  End If;
  If (p_rec.incrmnt_elcn_val = hr_api.g_number) then
    p_rec.incrmnt_elcn_val :=
    ben_vpf_shd.g_old_rec.incrmnt_elcn_val;
  End If;
  If (p_rec.dflt_elcn_val = hr_api.g_number) then
    p_rec.dflt_elcn_val :=
    ben_vpf_shd.g_old_rec.dflt_elcn_val;
  End If;
  If (p_rec.mx_elcn_val = hr_api.g_number) then
    p_rec.mx_elcn_val :=
    ben_vpf_shd.g_old_rec.mx_elcn_val;
  End If;
  If (p_rec.mn_elcn_val = hr_api.g_number) then
    p_rec.mn_elcn_val :=
    ben_vpf_shd.g_old_rec.mn_elcn_val;
  End If;
  If (p_rec.lwr_lmt_val = hr_api.g_number) then
    p_rec.lwr_lmt_val :=
    ben_vpf_shd.g_old_rec.lwr_lmt_val;
  End If;
  If (p_rec.lwr_lmt_calc_rl = hr_api.g_number) then
    p_rec.lwr_lmt_calc_rl :=
    ben_vpf_shd.g_old_rec.lwr_lmt_calc_rl;
  End If;
  If (p_rec.upr_lmt_val = hr_api.g_number) then
    p_rec.upr_lmt_val :=
    ben_vpf_shd.g_old_rec.upr_lmt_val;
  End If;
  If (p_rec.upr_lmt_calc_rl = hr_api.g_number) then
    p_rec.upr_lmt_calc_rl :=
    ben_vpf_shd.g_old_rec.upr_lmt_calc_rl;
  End If;
  If (p_rec.ultmt_upr_lmt = hr_api.g_number) then
    p_rec.ultmt_upr_lmt :=
    ben_vpf_shd.g_old_rec.ultmt_upr_lmt;
  End If;

  If (p_rec.ultmt_upr_lmt_calc_rl  = hr_api.g_number) then
    p_rec.ultmt_upr_lmt_calc_rl  :=
    ben_vpf_shd.g_old_rec.ultmt_upr_lmt_calc_rl;
  End If;

  If (p_rec.ultmt_lwr_lmt = hr_api.g_number) then
    p_rec.ultmt_lwr_lmt :=
    ben_vpf_shd.g_old_rec.ultmt_lwr_lmt;
  End If;

  If (p_rec.ultmt_lwr_lmt_calc_rl = hr_api.g_number) then
    p_rec.ultmt_lwr_lmt_calc_rl :=
    ben_vpf_shd.g_old_rec.ultmt_lwr_lmt_calc_rl;
  End If;

  If (p_rec.ann_mn_elcn_val = hr_api.g_number) then
    p_rec.ann_mn_elcn_val :=
    ben_vpf_shd.g_old_rec.ann_mn_elcn_val;
  End If;
  If (p_rec.ann_mx_elcn_val = hr_api.g_number) then
    p_rec.ann_mx_elcn_val :=
    ben_vpf_shd.g_old_rec.ann_mx_elcn_val;
  End If;
  If (p_rec.val = hr_api.g_number) then
    p_rec.val :=
    ben_vpf_shd.g_old_rec.val;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    ben_vpf_shd.g_old_rec.name;
  End If;
  If (p_rec.no_mn_elcn_val_dfnd_flag = hr_api.g_varchar2) then
    p_rec.no_mn_elcn_val_dfnd_flag :=
    ben_vpf_shd.g_old_rec.no_mn_elcn_val_dfnd_flag;
  End If;
  If (p_rec.no_mx_elcn_val_dfnd_flag = hr_api.g_varchar2) then
    p_rec.no_mx_elcn_val_dfnd_flag :=
    ben_vpf_shd.g_old_rec.no_mx_elcn_val_dfnd_flag;
  End If;
  If (p_rec.alwys_sum_all_cvg_flag = hr_api.g_varchar2) then
    p_rec.alwys_sum_all_cvg_flag :=
    ben_vpf_shd.g_old_rec.alwys_sum_all_cvg_flag;
  End If;
  If (p_rec.alwys_cnt_all_prtts_flag = hr_api.g_varchar2) then
    p_rec.alwys_cnt_all_prtts_flag :=
    ben_vpf_shd.g_old_rec.alwys_cnt_all_prtts_flag;
  End If;
  If (p_rec.val_calc_rl = hr_api.g_number) then
    p_rec.val_calc_rl :=
    ben_vpf_shd.g_old_rec.val_calc_rl;
  End If;
  If (p_rec.vrbl_rt_prfl_stat_cd = hr_api.g_varchar2) then
    p_rec.vrbl_rt_prfl_stat_cd :=
    ben_vpf_shd.g_old_rec.vrbl_rt_prfl_stat_cd;
  End If;
  If (p_rec.vrbl_usg_cd = hr_api.g_varchar2) then
    p_rec.vrbl_usg_cd :=
    ben_vpf_shd.g_old_rec.vrbl_usg_cd;
  End If;
  If (p_rec.asmt_to_use_cd = hr_api.g_varchar2) then
    p_rec.asmt_to_use_cd :=
    ben_vpf_shd.g_old_rec.asmt_to_use_cd;
  End If;
  If (p_rec.rndg_cd = hr_api.g_varchar2) then
    p_rec.rndg_cd :=
    ben_vpf_shd.g_old_rec.rndg_cd;
  End If;
  If (p_rec.rndg_rl = hr_api.g_number) then
    p_rec.rndg_rl :=
    ben_vpf_shd.g_old_rec.rndg_rl;
  End If;
  if (p_rec.rt_hrly_slrd_flag = hr_api.g_varchar2) then
    p_rec.rt_hrly_slrd_flag :=
    ben_vpf_shd.g_old_rec.rt_hrly_slrd_flag;
  end if;
  if (p_rec.rt_pstl_cd_flag = hr_api.g_varchar2) then
    p_rec.rt_pstl_cd_flag :=
    ben_vpf_shd.g_old_rec.rt_pstl_cd_flag;
  end if;
  if (p_rec.rt_lbr_mmbr_flag = hr_api.g_varchar2) then
    p_rec.rt_lbr_mmbr_flag :=
    ben_vpf_shd.g_old_rec.rt_lbr_mmbr_flag;
  end if;
  if (p_rec.rt_lgl_enty_flag = hr_api.g_varchar2) then
    p_rec.rt_lgl_enty_flag :=
    ben_vpf_shd.g_old_rec.rt_lgl_enty_flag;
  end if;
  if (p_rec.rt_benfts_grp_flag = hr_api.g_varchar2) then
    p_rec.rt_benfts_grp_flag :=
    ben_vpf_shd.g_old_rec.rt_benfts_grp_flag;
  end if;
  if (p_rec.rt_wk_loc_flag = hr_api.g_varchar2) then
    p_rec.rt_wk_loc_flag :=
    ben_vpf_shd.g_old_rec.rt_wk_loc_flag;
  end if;
  if (p_rec.rt_brgng_unit_flag = hr_api.g_varchar2) then
    p_rec.rt_brgng_unit_flag :=
    ben_vpf_shd.g_old_rec.rt_brgng_unit_flag;
  end if;
  if (p_rec.rt_age_flag = hr_api.g_varchar2) then
    p_rec.rt_age_flag :=
    ben_vpf_shd.g_old_rec.rt_age_flag;
  end if;
  if (p_rec.rt_los_flag = hr_api.g_varchar2) then
    p_rec.rt_los_flag :=
    ben_vpf_shd.g_old_rec.rt_los_flag;
  end if;
  if (p_rec.rt_per_typ_flag = hr_api.g_varchar2) then
    p_rec.rt_per_typ_flag :=
    ben_vpf_shd.g_old_rec.rt_per_typ_flag;
  end if;
  if (p_rec.rt_fl_tm_pt_tm_flag = hr_api.g_varchar2) then
    p_rec.rt_fl_tm_pt_tm_flag :=
    ben_vpf_shd.g_old_rec.rt_fl_tm_pt_tm_flag;
  end if;
  if (p_rec.rt_ee_stat_flag = hr_api.g_varchar2) then
    p_rec.rt_ee_stat_flag :=
    ben_vpf_shd.g_old_rec.rt_ee_stat_flag;
  end if;
  if (p_rec.rt_grd_flag = hr_api.g_varchar2) then
    p_rec.rt_grd_flag :=
    ben_vpf_shd.g_old_rec.rt_grd_flag;
  end if;
  if (p_rec.rt_pct_fl_tm_flag = hr_api.g_varchar2) then
    p_rec.rt_pct_fl_tm_flag :=
    ben_vpf_shd.g_old_rec.rt_pct_fl_tm_flag;
  end if;
  if (p_rec.rt_asnt_set_flag = hr_api.g_varchar2) then
    p_rec.rt_asnt_set_flag :=
    ben_vpf_shd.g_old_rec.rt_asnt_set_flag;
  end if;
  if (p_rec.rt_hrs_wkd_flag = hr_api.g_varchar2) then
    p_rec.rt_hrs_wkd_flag :=
    ben_vpf_shd.g_old_rec.rt_hrs_wkd_flag;
  end if;
  if (p_rec.rt_comp_lvl_flag = hr_api.g_varchar2) then
    p_rec.rt_comp_lvl_flag :=
    ben_vpf_shd.g_old_rec.rt_comp_lvl_flag;
  end if;
  if (p_rec.rt_org_unit_flag = hr_api.g_varchar2) then
    p_rec.rt_org_unit_flag :=
    ben_vpf_shd.g_old_rec.rt_org_unit_flag;
  end if;
  if (p_rec.rt_loa_rsn_flag = hr_api.g_varchar2) then
    p_rec.rt_loa_rsn_flag :=
    ben_vpf_shd.g_old_rec.rt_loa_rsn_flag;
  end if;
  if (p_rec.rt_pyrl_flag = hr_api.g_varchar2) then
    p_rec.rt_pyrl_flag :=
    ben_vpf_shd.g_old_rec.rt_pyrl_flag;
  end if;
  if (p_rec.rt_schedd_hrs_flag = hr_api.g_varchar2) then
    p_rec.rt_schedd_hrs_flag :=
    ben_vpf_shd.g_old_rec.rt_schedd_hrs_flag;
  end if;
  if (p_rec.rt_py_bss_flag = hr_api.g_varchar2) then
    p_rec.rt_py_bss_flag :=
    ben_vpf_shd.g_old_rec.rt_py_bss_flag;
  end if;
  if (p_rec.rt_prfl_rl_flag = hr_api.g_varchar2) then
    p_rec.rt_prfl_rl_flag :=
    ben_vpf_shd.g_old_rec.rt_prfl_rl_flag;
  end if;
  if (p_rec.rt_cmbn_age_los_flag = hr_api.g_varchar2) then
    p_rec.rt_cmbn_age_los_flag :=
    ben_vpf_shd.g_old_rec.rt_cmbn_age_los_flag;
  end if;
  if (p_rec.rt_prtt_pl_flag = hr_api.g_varchar2) then
    p_rec.rt_prtt_pl_flag :=
    ben_vpf_shd.g_old_rec.rt_prtt_pl_flag;
  end if;
  if (p_rec.rt_svc_area_flag = hr_api.g_varchar2) then
    p_rec.rt_svc_area_flag :=
    ben_vpf_shd.g_old_rec.rt_svc_area_flag;
  end if;
  if (p_rec.rt_ppl_grp_flag = hr_api.g_varchar2) then
    p_rec.rt_ppl_grp_flag :=
    ben_vpf_shd.g_old_rec.rt_ppl_grp_flag;
  end if;
  if (p_rec.rt_dsbld_flag = hr_api.g_varchar2) then
    p_rec.rt_dsbld_flag :=
    ben_vpf_shd.g_old_rec.rt_dsbld_flag;
  end if;
  if (p_rec.rt_hlth_cvg_flag = hr_api.g_varchar2) then
    p_rec.rt_hlth_cvg_flag :=
    ben_vpf_shd.g_old_rec.rt_hlth_cvg_flag;
  end if;
  if (p_rec.rt_poe_flag = hr_api.g_varchar2) then
    p_rec.rt_poe_flag :=
    ben_vpf_shd.g_old_rec.rt_poe_flag;
  end if;
  if (p_rec.rt_ttl_cvg_vol_flag = hr_api.g_varchar2) then
    p_rec.rt_ttl_cvg_vol_flag :=
    ben_vpf_shd.g_old_rec.rt_ttl_cvg_vol_flag;
  end if;
  if (p_rec.rt_ttl_prtt_flag = hr_api.g_varchar2) then
    p_rec.rt_ttl_prtt_flag :=
    ben_vpf_shd.g_old_rec.rt_ttl_prtt_flag;
  end if;
  if (p_rec.rt_gndr_flag = hr_api.g_varchar2) then
    p_rec.rt_gndr_flag :=
    ben_vpf_shd.g_old_rec.rt_gndr_flag;
  end if;
  if (p_rec.rt_tbco_use_flag = hr_api.g_varchar2) then
    p_rec.rt_tbco_use_flag :=
    ben_vpf_shd.g_old_rec.rt_tbco_use_flag;
  end if;
  If (p_rec.vpf_attribute_category = hr_api.g_varchar2) then
    p_rec.vpf_attribute_category :=
    ben_vpf_shd.g_old_rec.vpf_attribute_category;
  End If;
  If (p_rec.vpf_attribute1 = hr_api.g_varchar2) then
    p_rec.vpf_attribute1 :=
    ben_vpf_shd.g_old_rec.vpf_attribute1;
  End If;
  If (p_rec.vpf_attribute2 = hr_api.g_varchar2) then
    p_rec.vpf_attribute2 :=
    ben_vpf_shd.g_old_rec.vpf_attribute2;
  End If;
  If (p_rec.vpf_attribute3 = hr_api.g_varchar2) then
    p_rec.vpf_attribute3 :=
    ben_vpf_shd.g_old_rec.vpf_attribute3;
  End If;
  If (p_rec.vpf_attribute4 = hr_api.g_varchar2) then
    p_rec.vpf_attribute4 :=
    ben_vpf_shd.g_old_rec.vpf_attribute4;
  End If;
  If (p_rec.vpf_attribute5 = hr_api.g_varchar2) then
    p_rec.vpf_attribute5 :=
    ben_vpf_shd.g_old_rec.vpf_attribute5;
  End If;
  If (p_rec.vpf_attribute6 = hr_api.g_varchar2) then
    p_rec.vpf_attribute6 :=
    ben_vpf_shd.g_old_rec.vpf_attribute6;
  End If;
  If (p_rec.vpf_attribute7 = hr_api.g_varchar2) then
    p_rec.vpf_attribute7 :=
    ben_vpf_shd.g_old_rec.vpf_attribute7;
  End If;
  If (p_rec.vpf_attribute8 = hr_api.g_varchar2) then
    p_rec.vpf_attribute8 :=
    ben_vpf_shd.g_old_rec.vpf_attribute8;
  End If;
  If (p_rec.vpf_attribute9 = hr_api.g_varchar2) then
    p_rec.vpf_attribute9 :=
    ben_vpf_shd.g_old_rec.vpf_attribute9;
  End If;
  If (p_rec.vpf_attribute10 = hr_api.g_varchar2) then
    p_rec.vpf_attribute10 :=
    ben_vpf_shd.g_old_rec.vpf_attribute10;
  End If;
  If (p_rec.vpf_attribute11 = hr_api.g_varchar2) then
    p_rec.vpf_attribute11 :=
    ben_vpf_shd.g_old_rec.vpf_attribute11;
  End If;
  If (p_rec.vpf_attribute12 = hr_api.g_varchar2) then
    p_rec.vpf_attribute12 :=
    ben_vpf_shd.g_old_rec.vpf_attribute12;
  End If;
  If (p_rec.vpf_attribute13 = hr_api.g_varchar2) then
    p_rec.vpf_attribute13 :=
    ben_vpf_shd.g_old_rec.vpf_attribute13;
  End If;
  If (p_rec.vpf_attribute14 = hr_api.g_varchar2) then
    p_rec.vpf_attribute14 :=
    ben_vpf_shd.g_old_rec.vpf_attribute14;
  End If;
  If (p_rec.vpf_attribute15 = hr_api.g_varchar2) then
    p_rec.vpf_attribute15 :=
    ben_vpf_shd.g_old_rec.vpf_attribute15;
  End If;
  If (p_rec.vpf_attribute16 = hr_api.g_varchar2) then
    p_rec.vpf_attribute16 :=
    ben_vpf_shd.g_old_rec.vpf_attribute16;
  End If;
  If (p_rec.vpf_attribute17 = hr_api.g_varchar2) then
    p_rec.vpf_attribute17 :=
    ben_vpf_shd.g_old_rec.vpf_attribute17;
  End If;
  If (p_rec.vpf_attribute18 = hr_api.g_varchar2) then
    p_rec.vpf_attribute18 :=
    ben_vpf_shd.g_old_rec.vpf_attribute18;
  End If;
  If (p_rec.vpf_attribute19 = hr_api.g_varchar2) then
    p_rec.vpf_attribute19 :=
    ben_vpf_shd.g_old_rec.vpf_attribute19;
  End If;
  If (p_rec.vpf_attribute20 = hr_api.g_varchar2) then
    p_rec.vpf_attribute20 :=
    ben_vpf_shd.g_old_rec.vpf_attribute20;
  End If;
  If (p_rec.vpf_attribute21 = hr_api.g_varchar2) then
    p_rec.vpf_attribute21 :=
    ben_vpf_shd.g_old_rec.vpf_attribute21;
  End If;
  If (p_rec.vpf_attribute22 = hr_api.g_varchar2) then
    p_rec.vpf_attribute22 :=
    ben_vpf_shd.g_old_rec.vpf_attribute22;
  End If;
  If (p_rec.vpf_attribute23 = hr_api.g_varchar2) then
    p_rec.vpf_attribute23 :=
    ben_vpf_shd.g_old_rec.vpf_attribute23;
  End If;
  If (p_rec.vpf_attribute24 = hr_api.g_varchar2) then
    p_rec.vpf_attribute24 :=
    ben_vpf_shd.g_old_rec.vpf_attribute24;
  End If;
  If (p_rec.vpf_attribute25 = hr_api.g_varchar2) then
    p_rec.vpf_attribute25 :=
    ben_vpf_shd.g_old_rec.vpf_attribute25;
  End If;
  If (p_rec.vpf_attribute26 = hr_api.g_varchar2) then
    p_rec.vpf_attribute26 :=
    ben_vpf_shd.g_old_rec.vpf_attribute26;
  End If;
  If (p_rec.vpf_attribute27 = hr_api.g_varchar2) then
    p_rec.vpf_attribute27 :=
    ben_vpf_shd.g_old_rec.vpf_attribute27;
  End If;
  If (p_rec.vpf_attribute28 = hr_api.g_varchar2) then
    p_rec.vpf_attribute28 :=
    ben_vpf_shd.g_old_rec.vpf_attribute28;
  End If;
  If (p_rec.vpf_attribute29 = hr_api.g_varchar2) then
    p_rec.vpf_attribute29 :=
    ben_vpf_shd.g_old_rec.vpf_attribute29;
  End If;
  If (p_rec.vpf_attribute30 = hr_api.g_varchar2) then
    p_rec.vpf_attribute30 :=
    ben_vpf_shd.g_old_rec.vpf_attribute30;
  End If;
  If (p_rec.rt_cntng_prtn_prfl_flag   =  hr_api.g_varchar2) then
      p_rec.rt_cntng_prtn_prfl_flag :=
      ben_vpf_shd.g_old_rec.rt_cntng_prtn_prfl_flag;
  End If;
  If (p_rec.rt_cbr_quald_bnf_flag     =  hr_api.g_varchar2) then
      p_rec.rt_cbr_quald_bnf_flag :=
      ben_vpf_shd.g_old_rec.rt_cbr_quald_bnf_flag;
  End If;
  If (p_rec.rt_optd_mdcr_flag         =  hr_api.g_varchar2 ) then
      p_rec.rt_optd_mdcr_flag :=
      ben_vpf_shd.g_old_rec.rt_optd_mdcr_flag;
  End If;
  If (p_rec.rt_lvg_rsn_flag           =  hr_api.g_varchar2) then
      p_rec.rt_lvg_rsn_flag :=
      ben_vpf_shd.g_old_rec.rt_lvg_rsn_flag;
  End If;
  If (p_rec.rt_pstn_flag              =  hr_api.g_varchar2) then
      p_rec.rt_pstn_flag :=
      ben_vpf_shd.g_old_rec.rt_pstn_flag;
  End If;
  If (p_rec.rt_comptncy_flag          =  hr_api.g_varchar2) then
      p_rec.rt_comptncy_flag :=
      ben_vpf_shd.g_old_rec.rt_comptncy_flag;
  End If;
  If (p_rec.rt_job_flag               =  hr_api.g_varchar2) then
      p_rec.rt_job_flag :=
      ben_vpf_shd.g_old_rec.rt_job_flag;
  End If;
  If (p_rec.rt_qual_titl_flag         =  hr_api.g_varchar2 ) then
      p_rec.rt_qual_titl_flag :=
      ben_vpf_shd.g_old_rec.rt_qual_titl_flag;
  End If;
  If (p_rec.rt_dpnt_cvrd_pl_flag      =  hr_api.g_varchar2) then
      p_rec.rt_dpnt_cvrd_pl_flag :=
      ben_vpf_shd.g_old_rec.rt_dpnt_cvrd_pl_flag;
  End If;
  If (p_rec.rt_dpnt_cvrd_plip_flag    =  hr_api.g_varchar2) then
      p_rec.rt_dpnt_cvrd_plip_flag :=
      ben_vpf_shd.g_old_rec.rt_dpnt_cvrd_plip_flag;
  End If;
  If (p_rec.rt_dpnt_cvrd_ptip_flag    =  hr_api.g_varchar2 ) then
      p_rec.rt_dpnt_cvrd_ptip_flag :=
      ben_vpf_shd.g_old_rec.rt_dpnt_cvrd_ptip_flag;
  End If;
  If (p_rec.rt_dpnt_cvrd_pgm_flag     =  hr_api.g_varchar2) then
      p_rec.rt_dpnt_cvrd_pgm_flag :=
      ben_vpf_shd.g_old_rec.rt_dpnt_cvrd_pgm_flag;
  End If;
  If (p_rec.rt_enrld_oipl_flag        =  hr_api.g_varchar2) then
      p_rec.rt_enrld_oipl_flag :=
      ben_vpf_shd.g_old_rec.rt_enrld_oipl_flag;
  End If;
  If (p_rec.rt_enrld_pl_flag          =  hr_api.g_varchar2 ) then
      p_rec.rt_enrld_pl_flag :=
      ben_vpf_shd.g_old_rec.rt_enrld_pl_flag;
  End If;
  If (p_rec.rt_enrld_plip_flag        =  hr_api.g_varchar2 ) then
      p_rec.rt_enrld_plip_flag :=
      ben_vpf_shd.g_old_rec.rt_enrld_plip_flag;
  End If;
  If (p_rec.rt_enrld_ptip_flag        =  hr_api.g_varchar2 ) then
      p_rec.rt_enrld_ptip_flag :=
      ben_vpf_shd.g_old_rec.rt_enrld_ptip_flag;
  End If;
  If (p_rec.rt_enrld_pgm_flag         =  hr_api.g_varchar2 ) then
      p_rec.rt_enrld_pgm_flag :=
      ben_vpf_shd.g_old_rec.rt_enrld_pgm_flag;
  End If;
  If (p_rec.rt_prtt_anthr_pl_flag     =  hr_api.g_varchar2 ) then
      p_rec.rt_prtt_anthr_pl_flag :=
      ben_vpf_shd.g_old_rec.rt_prtt_anthr_pl_flag;
  End If;
  If (p_rec.rt_othr_ptip_flag         =  hr_api.g_varchar2 ) then
      p_rec.rt_othr_ptip_flag :=
      ben_vpf_shd.g_old_rec.rt_othr_ptip_flag;
  End If;
  If (p_rec.rt_no_othr_cvg_flag       =  hr_api.g_varchar2 ) then
      p_rec.rt_no_othr_cvg_flag :=
      ben_vpf_shd.g_old_rec.rt_no_othr_cvg_flag;
  End If;
  If (p_rec.rt_dpnt_othr_ptip_flag    =  hr_api.g_varchar2 ) then
      p_rec.rt_dpnt_othr_ptip_flag :=
      ben_vpf_shd.g_old_rec.rt_dpnt_othr_ptip_flag;
  End If;
  If (p_rec.rt_qua_in_gr_flag    =  hr_api.g_varchar2 ) then
        p_rec.rt_qua_in_gr_flag :=
        ben_vpf_shd.g_old_rec.rt_qua_in_gr_flag;
  End If;
  If (p_rec.rt_perf_rtng_flag    =  hr_api.g_varchar2 ) then
          p_rec.rt_perf_rtng_flag :=
          ben_vpf_shd.g_old_rec.rt_perf_rtng_flag;
  End If;
  --
  If (p_rec.rt_elig_prfl_flag    =  hr_api.g_varchar2 ) then
          p_rec.rt_elig_prfl_flag :=
          ben_vpf_shd.g_old_rec.rt_elig_prfl_flag;
  End If;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec			in out nocopy 	ben_vpf_shd.g_rec_type,
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
  ben_vpf_shd.lck
	(p_effective_date	 => p_effective_date,
      	 p_datetrack_mode	 => p_datetrack_mode,
      	 p_vrbl_rt_prfl_id	 => p_rec.vrbl_rt_prfl_id,
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
  ben_vpf_bus.update_validate
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
  p_vrbl_rt_prfl_id              in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_pl_typ_opt_typ_id            in number           default hr_api.g_number,
  p_pl_id                        in number           default hr_api.g_number,
  p_oipl_id                      in number           default hr_api.g_number,
  p_comp_lvl_fctr_id             in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_acty_typ_cd                  in varchar2         default hr_api.g_varchar2,
  p_rt_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_bnft_rt_typ_cd               in varchar2         default hr_api.g_varchar2,
  p_tx_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_vrbl_rt_trtmt_cd             in varchar2         default hr_api.g_varchar2,
  p_acty_ref_perd_cd             in varchar2         default hr_api.g_varchar2,
  p_mlt_cd                       in varchar2         default hr_api.g_varchar2,
  p_incrmnt_elcn_val             in number           default hr_api.g_number,
  p_dflt_elcn_val                in number           default hr_api.g_number,
  p_mx_elcn_val                  in number           default hr_api.g_number,
  p_mn_elcn_val                  in number           default hr_api.g_number,
  p_lwr_lmt_val                  in number           default hr_api.g_number,
  p_lwr_lmt_calc_rl              in number           default hr_api.g_number,
  p_upr_lmt_val                  in number           default hr_api.g_number,
  p_upr_lmt_calc_rl              in number           default hr_api.g_number,
  p_ultmt_upr_lmt                in number           default hr_api.g_number,
  p_ultmt_lwr_lmt                in number           default hr_api.g_number,
  p_ultmt_upr_lmt_calc_rl        in number           default hr_api.g_number,
  p_ultmt_lwr_lmt_calc_rl        in number           default hr_api.g_number,
  p_ann_mn_elcn_val              in number           default hr_api.g_number,
  p_ann_mx_elcn_val              in number           default hr_api.g_number,
  p_val                          in number           default hr_api.g_number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_no_mn_elcn_val_dfnd_flag     in varchar2         default hr_api.g_varchar2,
  p_no_mx_elcn_val_dfnd_flag     in varchar2         default hr_api.g_varchar2,
  p_alwys_sum_all_cvg_flag       in varchar2         default hr_api.g_varchar2,
  p_alwys_cnt_all_prtts_flag     in varchar2         default hr_api.g_varchar2,
  p_val_calc_rl                  in number           default hr_api.g_number,
  p_vrbl_rt_prfl_stat_cd         in varchar2         default hr_api.g_varchar2,
  p_vrbl_usg_cd                  in varchar2         default hr_api.g_varchar2,
  p_asmt_to_use_cd               in varchar2         default hr_api.g_varchar2,
  p_rndg_cd                      in varchar2         default hr_api.g_varchar2,
  p_rndg_rl                      in number           default hr_api.g_number,
  p_rt_hrly_slrd_flag            in varchar2         default hr_api.g_varchar2,
  p_rt_pstl_cd_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_lbr_mmbr_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_lgl_enty_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_benfts_grp_flag           in varchar2         default hr_api.g_varchar2,
  p_rt_wk_loc_flag               in varchar2         default hr_api.g_varchar2,
  p_rt_brgng_unit_flag           in varchar2         default hr_api.g_varchar2,
  p_rt_age_flag                  in varchar2         default hr_api.g_varchar2,
  p_rt_los_flag                  in varchar2         default hr_api.g_varchar2,
  p_rt_per_typ_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_fl_tm_pt_tm_flag          in varchar2         default hr_api.g_varchar2,
  p_rt_ee_stat_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_grd_flag                  in varchar2         default hr_api.g_varchar2,
  p_rt_pct_fl_tm_flag            in varchar2         default hr_api.g_varchar2,
  p_rt_asnt_set_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_hrs_wkd_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_comp_lvl_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_org_unit_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_loa_rsn_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_pyrl_flag                 in varchar2         default hr_api.g_varchar2,
  p_rt_schedd_hrs_flag           in varchar2         default hr_api.g_varchar2,
  p_rt_py_bss_flag               in varchar2         default hr_api.g_varchar2,
  p_rt_prfl_rl_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_cmbn_age_los_flag         in varchar2         default hr_api.g_varchar2,
  p_rt_prtt_pl_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_svc_area_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_ppl_grp_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_dsbld_flag                in varchar2         default hr_api.g_varchar2,
  p_rt_hlth_cvg_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_poe_flag                  in varchar2         default hr_api.g_varchar2,
  p_rt_ttl_cvg_vol_flag          in varchar2         default hr_api.g_varchar2,
  p_rt_ttl_prtt_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_gndr_flag                 in varchar2         default hr_api.g_varchar2,
  p_rt_tbco_use_flag             in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute1               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute2               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute3               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute4               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute5               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute6               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute7               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute8               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute9               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute10              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute11              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute12              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute13              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute14              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute15              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute16              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute17              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute18              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute19              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute20              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute21              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute22              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute23              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute24              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute25              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute26              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute27              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute28              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute29              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2 ,
  p_rt_cntng_prtn_prfl_flag	 in varchar2         default hr_api.g_varchar2,
  p_rt_cbr_quald_bnf_flag  	 in varchar2         default hr_api.g_varchar2,
  p_rt_optd_mdcr_flag      	 in varchar2         default hr_api.g_varchar2,
  p_rt_lvg_rsn_flag        	 in varchar2         default hr_api.g_varchar2,
  p_rt_pstn_flag           	 in varchar2         default hr_api.g_varchar2,
  p_rt_comptncy_flag       	 in varchar2         default hr_api.g_varchar2,
  p_rt_job_flag            	 in varchar2         default hr_api.g_varchar2,
  p_rt_qual_titl_flag      	 in varchar2         default hr_api.g_varchar2,
  p_rt_dpnt_cvrd_pl_flag   	 in varchar2         default hr_api.g_varchar2,
  p_rt_dpnt_cvrd_plip_flag 	 in varchar2         default hr_api.g_varchar2,
  p_rt_dpnt_cvrd_ptip_flag 	 in varchar2         default hr_api.g_varchar2,
  p_rt_dpnt_cvrd_pgm_flag  	 in varchar2         default hr_api.g_varchar2,
  p_rt_enrld_oipl_flag     	 in varchar2         default hr_api.g_varchar2,
  p_rt_enrld_pl_flag       	 in varchar2         default hr_api.g_varchar2,
  p_rt_enrld_plip_flag     	 in varchar2         default hr_api.g_varchar2,
  p_rt_enrld_ptip_flag     	 in varchar2         default hr_api.g_varchar2,
  p_rt_enrld_pgm_flag      	 in varchar2         default hr_api.g_varchar2,
  p_rt_prtt_anthr_pl_flag  	 in varchar2         default hr_api.g_varchar2,
  p_rt_othr_ptip_flag      	 in varchar2         default hr_api.g_varchar2,
  p_rt_no_othr_cvg_flag    	 in varchar2         default hr_api.g_varchar2,
  p_rt_dpnt_othr_ptip_flag 	 in varchar2         default hr_api.g_varchar2,
  p_rt_qua_in_gr_flag            in varchar2         default hr_api.g_varchar2,
  p_rt_perf_rtng_flag 	         in varchar2         default hr_api.g_varchar2,
  p_rt_elig_prfl_flag 	         in varchar2         default hr_api.g_varchar2
  ) is
--
  l_rec		ben_vpf_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_vpf_shd.convert_args
  (
  p_vrbl_rt_prfl_id,
  null,
  null,
  p_pl_typ_opt_typ_id,
  p_pl_id,
  p_oipl_id,
  p_comp_lvl_fctr_id,
  p_business_group_id,
  p_acty_typ_cd,
  p_rt_typ_cd,
  p_bnft_rt_typ_cd,
  p_tx_typ_cd,
  p_vrbl_rt_trtmt_cd,
  p_acty_ref_perd_cd,
  p_mlt_cd,
  p_incrmnt_elcn_val,
  p_dflt_elcn_val,
  p_mx_elcn_val,
  p_mn_elcn_val,
  p_lwr_lmt_val,
  p_lwr_lmt_calc_rl,
  p_upr_lmt_val,
  p_upr_lmt_calc_rl,
  p_ultmt_upr_lmt,
  p_ultmt_lwr_lmt,
  p_ultmt_upr_lmt_calc_rl,
  p_ultmt_lwr_lmt_calc_rl,
  p_ann_mn_elcn_val,
  p_ann_mx_elcn_val,
  p_val,
  p_name,
  p_no_mn_elcn_val_dfnd_flag,
  p_no_mx_elcn_val_dfnd_flag,
  p_alwys_sum_all_cvg_flag,
  p_alwys_cnt_all_prtts_flag,
  p_val_calc_rl,
  p_vrbl_rt_prfl_stat_cd,
  p_vrbl_usg_cd,
  p_asmt_to_use_cd,
  p_rndg_cd,
  p_rndg_rl,
  p_rt_hrly_slrd_flag,
  p_rt_pstl_cd_flag,
  p_rt_lbr_mmbr_flag,
  p_rt_lgl_enty_flag,
  p_rt_benfts_grp_flag,
  p_rt_wk_loc_flag,
  p_rt_brgng_unit_flag,
  p_rt_age_flag,
  p_rt_los_flag,
  p_rt_per_typ_flag,
  p_rt_fl_tm_pt_tm_flag,
  p_rt_ee_stat_flag,
  p_rt_grd_flag,
  p_rt_pct_fl_tm_flag,
  p_rt_asnt_set_flag,
  p_rt_hrs_wkd_flag,
  p_rt_comp_lvl_flag,
  p_rt_org_unit_flag,
  p_rt_loa_rsn_flag,
  p_rt_pyrl_flag,
  p_rt_schedd_hrs_flag,
  p_rt_py_bss_flag,
  p_rt_prfl_rl_flag,
  p_rt_cmbn_age_los_flag,
  p_rt_prtt_pl_flag,
  p_rt_svc_area_flag,
  p_rt_ppl_grp_flag,
  p_rt_dsbld_flag,
  p_rt_hlth_cvg_flag,
  p_rt_poe_flag,
  p_rt_ttl_cvg_vol_flag,
  p_rt_ttl_prtt_flag,
  p_rt_gndr_flag,
  p_rt_tbco_use_flag,
  p_vpf_attribute_category,
  p_vpf_attribute1,
  p_vpf_attribute2,
  p_vpf_attribute3,
  p_vpf_attribute4,
  p_vpf_attribute5,
  p_vpf_attribute6,
  p_vpf_attribute7,
  p_vpf_attribute8,
  p_vpf_attribute9,
  p_vpf_attribute10,
  p_vpf_attribute11,
  p_vpf_attribute12,
  p_vpf_attribute13,
  p_vpf_attribute14,
  p_vpf_attribute15,
  p_vpf_attribute16,
  p_vpf_attribute17,
  p_vpf_attribute18,
  p_vpf_attribute19,
  p_vpf_attribute20,
  p_vpf_attribute21,
  p_vpf_attribute22,
  p_vpf_attribute23,
  p_vpf_attribute24,
  p_vpf_attribute25,
  p_vpf_attribute26,
  p_vpf_attribute27,
  p_vpf_attribute28,
  p_vpf_attribute29,
  p_vpf_attribute30,
  p_object_version_number,
  p_rt_cntng_prtn_prfl_flag,
  p_rt_cbr_quald_bnf_flag,
  p_rt_optd_mdcr_flag,
  p_rt_lvg_rsn_flag,
  p_rt_pstn_flag,
  p_rt_comptncy_flag,
  p_rt_job_flag,
  p_rt_qual_titl_flag,
  p_rt_dpnt_cvrd_pl_flag ,
  p_rt_dpnt_cvrd_plip_flag,
  p_rt_dpnt_cvrd_ptip_flag,
  p_rt_dpnt_cvrd_pgm_flag,
  p_rt_enrld_oipl_flag,
  p_rt_enrld_pl_flag,
  p_rt_enrld_plip_flag,
  p_rt_enrld_ptip_flag,
  p_rt_enrld_pgm_flag,
  p_rt_prtt_anthr_pl_flag,
  p_rt_othr_ptip_flag,
  p_rt_no_othr_cvg_flag,
  p_rt_dpnt_othr_ptip_flag,
  p_rt_qua_in_gr_flag,
  p_rt_perf_rtng_flag,
  p_rt_elig_prfl_flag
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
end ben_vpf_upd;

/
