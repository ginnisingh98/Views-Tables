--------------------------------------------------------
--  DDL for Package Body BEN_VPF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_VPF_INS" as
/* $Header: bevpfrhi.pkb 120.1.12010000.1 2008/07/29 13:07:55 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_vpf_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
	(p_rec 			 in out nocopy ben_vpf_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   ben_vrbl_rt_prfl_f t
    where  t.vrbl_rt_prfl_id       = p_rec.vrbl_rt_prfl_id
    and    t.effective_start_date =
             ben_vpf_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc		varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_vrbl_rt_prfl_f.created_by%TYPE;
  l_creation_date       ben_vrbl_rt_prfl_f.creation_date%TYPE;
  l_last_update_date   	ben_vrbl_rt_prfl_f.last_update_date%TYPE;
  l_last_updated_by     ben_vrbl_rt_prfl_f.last_updated_by%TYPE;
  l_last_update_login   ben_vrbl_rt_prfl_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name => 'ben_vrbl_rt_prfl_f',
	 p_base_key_column => 'vrbl_rt_prfl_id',
	 p_base_key_value  => p_rec.vrbl_rt_prfl_id);
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> 'INSERT') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
  ben_vpf_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_vrbl_rt_prfl_f
  --
  insert into ben_vrbl_rt_prfl_f
  (	vrbl_rt_prfl_id,
	effective_start_date,
	effective_end_date,
	pl_typ_opt_typ_id,
	pl_id,
	oipl_id,
        comp_lvl_fctr_id,
	business_group_id,
	acty_typ_cd,
	rt_typ_cd,
	bnft_rt_typ_cd,
	tx_typ_cd,
	vrbl_rt_trtmt_cd,
	acty_ref_perd_cd,
	mlt_cd,
	incrmnt_elcn_val,
	dflt_elcn_val,
	mx_elcn_val,
	mn_elcn_val,
        lwr_lmt_val,
        lwr_lmt_calc_rl,
        upr_lmt_val,
        upr_lmt_calc_rl,
        ultmt_upr_lmt,
        ultmt_lwr_lmt,
        ultmt_upr_lmt_calc_rl,
        ultmt_lwr_lmt_calc_rl,
        ann_mn_elcn_val,
        ann_mx_elcn_val,
	val,
	name,
	no_mn_elcn_val_dfnd_flag,
	no_mx_elcn_val_dfnd_flag,
        alwys_sum_all_cvg_flag,
        alwys_cnt_all_prtts_flag,
	val_calc_rl,
	vrbl_rt_prfl_stat_cd,
        vrbl_usg_cd,
        asmt_to_use_cd,
        rndg_cd,
        rndg_rl,
        rt_hrly_slrd_flag,
        rt_pstl_cd_flag,
        rt_lbr_mmbr_flag,
        rt_lgl_enty_flag,
        rt_benfts_grp_flag,
        rt_wk_loc_flag,
        rt_brgng_unit_flag,
        rt_age_flag,
        rt_los_flag,
        rt_per_typ_flag,
        rt_fl_tm_pt_tm_flag,
        rt_ee_stat_flag,
        rt_grd_flag,
        rt_pct_fl_tm_flag,
        rt_asnt_set_flag,
        rt_hrs_wkd_flag,
        rt_comp_lvl_flag,
        rt_org_unit_flag,
        rt_loa_rsn_flag,
        rt_pyrl_flag,
        rt_schedd_hrs_flag,
        rt_py_bss_flag,
        rt_prfl_rl_flag,
        rt_cmbn_age_los_flag,
        rt_prtt_pl_flag,
        rt_svc_area_flag,
        rt_ppl_grp_flag,
        rt_dsbld_flag,
        rt_hlth_cvg_flag,
        rt_poe_flag,
        rt_ttl_cvg_vol_flag,
        rt_ttl_prtt_flag,
        rt_gndr_flag,
        rt_tbco_use_flag,
	vpf_attribute_category,
	vpf_attribute1,
	vpf_attribute2,
	vpf_attribute3,
	vpf_attribute4,
	vpf_attribute5,
	vpf_attribute6,
	vpf_attribute7,
	vpf_attribute8,
	vpf_attribute9,
	vpf_attribute10,
	vpf_attribute11,
	vpf_attribute12,
	vpf_attribute13,
	vpf_attribute14,
	vpf_attribute15,
	vpf_attribute16,
	vpf_attribute17,
	vpf_attribute18,
	vpf_attribute19,
	vpf_attribute20,
	vpf_attribute21,
	vpf_attribute22,
	vpf_attribute23,
	vpf_attribute24,
	vpf_attribute25,
	vpf_attribute26,
	vpf_attribute27,
	vpf_attribute28,
	vpf_attribute29,
	vpf_attribute30,
	object_version_number,
   	created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login,
   	rt_cntng_prtn_prfl_flag,
	rt_cbr_quald_bnf_flag  ,
	rt_optd_mdcr_flag      ,
	rt_lvg_rsn_flag        ,
	rt_pstn_flag           ,
	rt_comptncy_flag       ,
	rt_job_flag            ,
	rt_qual_titl_flag      ,
	rt_dpnt_cvrd_pl_flag   ,
	rt_dpnt_cvrd_plip_flag ,
	rt_dpnt_cvrd_ptip_flag ,
	rt_dpnt_cvrd_pgm_flag  ,
	rt_enrld_oipl_flag     ,
	rt_enrld_pl_flag       ,
	rt_enrld_plip_flag     ,
	rt_enrld_ptip_flag     ,
	rt_enrld_pgm_flag      ,
	rt_prtt_anthr_pl_flag  ,
	rt_othr_ptip_flag      ,
	rt_no_othr_cvg_flag    ,
	rt_dpnt_othr_ptip_flag ,
	rt_qua_in_gr_flag,
        rt_perf_rtng_flag,
        rt_elig_prfl_flag
  )
  Values
  (	p_rec.vrbl_rt_prfl_id,
	p_rec.effective_start_date,
	p_rec.effective_end_date,
	p_rec.pl_typ_opt_typ_id,
	p_rec.pl_id,
	p_rec.oipl_id,
        p_rec.comp_lvl_fctr_id,
	p_rec.business_group_id,
	p_rec.acty_typ_cd,
	p_rec.rt_typ_cd,
	p_rec.bnft_rt_typ_cd,
	p_rec.tx_typ_cd,
	p_rec.vrbl_rt_trtmt_cd,
	p_rec.acty_ref_perd_cd,
	p_rec.mlt_cd,
	p_rec.incrmnt_elcn_val,
	p_rec.dflt_elcn_val,
	p_rec.mx_elcn_val,
	p_rec.mn_elcn_val,
        p_rec.lwr_lmt_val,
        p_rec.lwr_lmt_calc_rl,
        p_rec.upr_lmt_val,
        p_rec.upr_lmt_calc_rl,
        p_rec.ultmt_upr_lmt,
        p_rec.ultmt_lwr_lmt,
        p_rec.ultmt_upr_lmt_calc_rl,
        p_rec.ultmt_lwr_lmt_calc_rl,
        p_rec.ann_mn_elcn_val,
        p_rec.ann_mx_elcn_val,
	p_rec.val,
	p_rec.name,
	p_rec.no_mn_elcn_val_dfnd_flag,
	p_rec.no_mx_elcn_val_dfnd_flag,
        p_rec.alwys_sum_all_cvg_flag,
        p_rec.alwys_cnt_all_prtts_flag,
	p_rec.val_calc_rl,
	p_rec.vrbl_rt_prfl_stat_cd,
        p_rec.vrbl_usg_cd,
        p_rec.asmt_to_use_cd,
        p_rec.rndg_cd,
        p_rec.rndg_rl,
        p_rec.rt_hrly_slrd_flag,
        p_rec.rt_pstl_cd_flag,
        p_rec.rt_lbr_mmbr_flag,
        p_rec.rt_lgl_enty_flag,
        p_rec.rt_benfts_grp_flag,
        p_rec.rt_wk_loc_flag,
        p_rec.rt_brgng_unit_flag,
        p_rec.rt_age_flag,
        p_rec.rt_los_flag,
        p_rec.rt_per_typ_flag,
        p_rec.rt_fl_tm_pt_tm_flag,
        p_rec.rt_ee_stat_flag,
        p_rec.rt_grd_flag,
        p_rec.rt_pct_fl_tm_flag,
        p_rec.rt_asnt_set_flag,
        p_rec.rt_hrs_wkd_flag,
        p_rec.rt_comp_lvl_flag,
        p_rec.rt_org_unit_flag,
        p_rec.rt_loa_rsn_flag,
        p_rec.rt_pyrl_flag,
        p_rec.rt_schedd_hrs_flag,
        p_rec.rt_py_bss_flag,
        p_rec.rt_prfl_rl_flag,
        p_rec.rt_cmbn_age_los_flag,
        p_rec.rt_prtt_pl_flag,
        p_rec.rt_svc_area_flag,
        p_rec.rt_ppl_grp_flag,
        p_rec.rt_dsbld_flag,
        p_rec.rt_hlth_cvg_flag,
        p_rec.rt_poe_flag,
        p_rec.rt_ttl_cvg_vol_flag,
        p_rec.rt_ttl_prtt_flag,
        p_rec.rt_gndr_flag,
        p_rec.rt_tbco_use_flag,
	p_rec.vpf_attribute_category,
	p_rec.vpf_attribute1,
	p_rec.vpf_attribute2,
	p_rec.vpf_attribute3,
	p_rec.vpf_attribute4,
	p_rec.vpf_attribute5,
	p_rec.vpf_attribute6,
	p_rec.vpf_attribute7,
	p_rec.vpf_attribute8,
	p_rec.vpf_attribute9,
	p_rec.vpf_attribute10,
	p_rec.vpf_attribute11,
	p_rec.vpf_attribute12,
	p_rec.vpf_attribute13,
	p_rec.vpf_attribute14,
	p_rec.vpf_attribute15,
	p_rec.vpf_attribute16,
	p_rec.vpf_attribute17,
	p_rec.vpf_attribute18,
	p_rec.vpf_attribute19,
	p_rec.vpf_attribute20,
	p_rec.vpf_attribute21,
	p_rec.vpf_attribute22,
	p_rec.vpf_attribute23,
	p_rec.vpf_attribute24,
	p_rec.vpf_attribute25,
	p_rec.vpf_attribute26,
	p_rec.vpf_attribute27,
	p_rec.vpf_attribute28,
	p_rec.vpf_attribute29,
	p_rec.vpf_attribute30,
	p_rec.object_version_number,
	l_created_by,
   	l_creation_date,
   	l_last_update_date,
   	l_last_updated_by,
   	l_last_update_login,
   	p_rec.rt_cntng_prtn_prfl_flag,
	p_rec.rt_cbr_quald_bnf_flag,
	p_rec.rt_optd_mdcr_flag ,
	p_rec.rt_lvg_rsn_flag ,
	p_rec.rt_pstn_flag  ,
	p_rec.rt_comptncy_flag  ,
	p_rec.rt_job_flag      ,
	p_rec.rt_qual_titl_flag ,
	p_rec.rt_dpnt_cvrd_pl_flag ,
	p_rec.rt_dpnt_cvrd_plip_flag ,
	p_rec.rt_dpnt_cvrd_ptip_flag ,
	p_rec.rt_dpnt_cvrd_pgm_flag ,
	p_rec.rt_enrld_oipl_flag   ,
	p_rec.rt_enrld_pl_flag     ,
	p_rec.rt_enrld_plip_flag   ,
	p_rec.rt_enrld_ptip_flag   ,
	p_rec.rt_enrld_pgm_flag     ,
	p_rec.rt_prtt_anthr_pl_flag ,
	p_rec.rt_othr_ptip_flag    ,
	p_rec.rt_no_othr_cvg_flag  ,
	p_rec.rt_dpnt_othr_ptip_flag,
	p_rec.rt_qua_in_gr_flag,
        p_rec.rt_perf_rtng_flag,
        p_rec.rt_elig_prfl_flag);
  --
  ben_vpf_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
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
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_vpf_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_insert_dml(p_rec			=> p_rec,
		p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
	(p_rec  			in out nocopy ben_vpf_shd.g_rec_type,
	 p_effective_date		in date,
	 p_datetrack_mode		in varchar2,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  select ben_vrbl_rt_prfl_f_s.nextval into p_rec.vrbl_rt_prfl_id from dual;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
	(p_rec 			 in ben_vpf_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
  --
  l_proc	varchar2(72) := g_package||'post_insert';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_vpf_rki.after_insert
      (p_vrbl_rt_prfl_id               =>p_rec.vrbl_rt_prfl_id
      ,p_effective_start_date          =>p_rec.effective_start_date
      ,p_effective_end_date            =>p_rec.effective_end_date
      ,p_pl_typ_opt_typ_id             =>p_rec.pl_typ_opt_typ_id
      ,p_pl_id                         =>p_rec.pl_id
      ,p_oipl_id                       =>p_rec.oipl_id
      ,p_comp_lvl_fctr_id              =>p_rec.comp_lvl_fctr_id
      ,p_business_group_id             =>p_rec.business_group_id
      ,p_acty_typ_cd                   =>p_rec.acty_typ_cd
      ,p_rt_typ_cd                     =>p_rec.rt_typ_cd
      ,p_bnft_rt_typ_cd                =>p_rec.bnft_rt_typ_cd
      ,p_tx_typ_cd                     =>p_rec.tx_typ_cd
      ,p_vrbl_rt_trtmt_cd              =>p_rec.vrbl_rt_trtmt_cd
      ,p_acty_ref_perd_cd              =>p_rec.acty_ref_perd_cd
      ,p_mlt_cd                        =>p_rec.mlt_cd
      ,p_incrmnt_elcn_val              =>p_rec.incrmnt_elcn_val
      ,p_dflt_elcn_val                 =>p_rec.dflt_elcn_val
      ,p_mx_elcn_val                   =>p_rec.mx_elcn_val
      ,p_mn_elcn_val                   =>p_rec.mn_elcn_val
      ,p_lwr_lmt_val                   =>p_rec.lwr_lmt_val
      ,p_lwr_lmt_calc_rl               =>p_rec.lwr_lmt_calc_rl
      ,p_upr_lmt_val                   =>p_rec.upr_lmt_val
      ,p_upr_lmt_calc_rl               =>p_rec.upr_lmt_calc_rl
      ,p_ultmt_upr_lmt                 =>p_rec.ultmt_upr_lmt
      ,p_ultmt_lwr_lmt                 =>p_rec.ultmt_lwr_lmt
      ,p_ultmt_upr_lmt_calc_rl         =>p_rec.ultmt_upr_lmt_calc_rl
      ,p_ultmt_lwr_lmt_calc_rl         =>p_rec.ultmt_lwr_lmt_calc_rl
      ,p_ann_mn_elcn_val               =>p_rec.ann_mn_elcn_val
      ,p_ann_mx_elcn_val               =>p_rec.ann_mx_elcn_val
      ,p_val                           =>p_rec.val
      ,p_name                          =>p_rec.name
      ,p_no_mn_elcn_val_dfnd_flag      =>p_rec.no_mn_elcn_val_dfnd_flag
      ,p_no_mx_elcn_val_dfnd_flag      =>p_rec.no_mx_elcn_val_dfnd_flag
      ,p_alwys_sum_all_cvg_flag        =>p_rec.alwys_sum_all_cvg_flag
      ,p_alwys_cnt_all_prtts_flag      =>p_rec.alwys_cnt_all_prtts_flag
      ,p_val_calc_rl                   =>p_rec.val_calc_rl
      ,p_vrbl_rt_prfl_stat_cd          =>p_rec.vrbl_rt_prfl_stat_cd
      ,p_vrbl_usg_cd                   =>p_rec.vrbl_usg_cd
      ,p_asmt_to_use_cd                =>p_rec.asmt_to_use_cd
      ,p_rndg_cd                       =>p_rec.rndg_cd
      ,p_rndg_rl                       =>p_rec.rndg_rl
      ,p_rt_hrly_slrd_flag             =>p_rec.rt_hrly_slrd_flag
      ,p_rt_pstl_cd_flag               =>p_rec.rt_pstl_cd_flag
      ,p_rt_lbr_mmbr_flag              =>p_rec.rt_lbr_mmbr_flag
      ,p_rt_lgl_enty_flag              =>p_rec.rt_lgl_enty_flag
      ,p_rt_benfts_grp_flag            =>p_rec.rt_benfts_grp_flag
      ,p_rt_wk_loc_flag                =>p_rec.rt_wk_loc_flag
      ,p_rt_brgng_unit_flag            =>p_rec.rt_brgng_unit_flag
      ,p_rt_age_flag                   =>p_rec.rt_age_flag
      ,p_rt_los_flag                   =>p_rec.rt_los_flag
      ,p_rt_per_typ_flag               =>p_rec.rt_per_typ_flag
      ,p_rt_fl_tm_pt_tm_flag           =>p_rec.rt_fl_tm_pt_tm_flag
      ,p_rt_ee_stat_flag               =>p_rec.rt_ee_stat_flag
      ,p_rt_grd_flag                   =>p_rec.rt_grd_flag
      ,p_rt_pct_fl_tm_flag             =>p_rec.rt_pct_fl_tm_flag
      ,p_rt_asnt_set_flag              =>p_rec.rt_asnt_set_flag
      ,p_rt_hrs_wkd_flag               =>p_rec.rt_hrs_wkd_flag
      ,p_rt_comp_lvl_flag              =>p_rec.rt_comp_lvl_flag
      ,p_rt_org_unit_flag              =>p_rec.rt_org_unit_flag
      ,p_rt_loa_rsn_flag               =>p_rec.rt_loa_rsn_flag
      ,p_rt_pyrl_flag                  =>p_rec.rt_pyrl_flag
      ,p_rt_schedd_hrs_flag            =>p_rec.rt_schedd_hrs_flag
      ,p_rt_py_bss_flag                =>p_rec.rt_py_bss_flag
      ,p_rt_prfl_rl_flag               =>p_rec.rt_prfl_rl_flag
      ,p_rt_cmbn_age_los_flag          =>p_rec.rt_cmbn_age_los_flag
      ,p_rt_prtt_pl_flag               =>p_rec.rt_prtt_pl_flag
      ,p_rt_svc_area_flag              =>p_rec.rt_svc_area_flag
      ,p_rt_ppl_grp_flag               =>p_rec.rt_ppl_grp_flag
      ,p_rt_dsbld_flag                 =>p_rec.rt_dsbld_flag
      ,p_rt_hlth_cvg_flag              =>p_rec.rt_hlth_cvg_flag
      ,p_rt_poe_flag                   =>p_rec.rt_poe_flag
      ,p_rt_ttl_cvg_vol_flag           =>p_rec.rt_ttl_cvg_vol_flag
      ,p_rt_ttl_prtt_flag              =>p_rec.rt_ttl_prtt_flag
      ,p_rt_gndr_flag                  =>p_rec.rt_gndr_flag
      ,p_rt_tbco_use_flag              =>p_rec.rt_tbco_use_flag
      ,p_vpf_attribute_category        =>p_rec.vpf_attribute_category
      ,p_vpf_attribute1                =>p_rec.vpf_attribute1
      ,p_vpf_attribute2                =>p_rec.vpf_attribute2
      ,p_vpf_attribute3                =>p_rec.vpf_attribute3
      ,p_vpf_attribute4                =>p_rec.vpf_attribute4
      ,p_vpf_attribute5                =>p_rec.vpf_attribute5
      ,p_vpf_attribute6                =>p_rec.vpf_attribute6
      ,p_vpf_attribute7                =>p_rec.vpf_attribute7
      ,p_vpf_attribute8                =>p_rec.vpf_attribute8
      ,p_vpf_attribute9                =>p_rec.vpf_attribute9
      ,p_vpf_attribute10               =>p_rec.vpf_attribute10
      ,p_vpf_attribute11               =>p_rec.vpf_attribute11
      ,p_vpf_attribute12               =>p_rec.vpf_attribute12
      ,p_vpf_attribute13               =>p_rec.vpf_attribute13
      ,p_vpf_attribute14               =>p_rec.vpf_attribute14
      ,p_vpf_attribute15               =>p_rec.vpf_attribute15
      ,p_vpf_attribute16               =>p_rec.vpf_attribute16
      ,p_vpf_attribute17               =>p_rec.vpf_attribute17
      ,p_vpf_attribute18               =>p_rec.vpf_attribute18
      ,p_vpf_attribute19               =>p_rec.vpf_attribute19
      ,p_vpf_attribute20               =>p_rec.vpf_attribute20
      ,p_vpf_attribute21               =>p_rec.vpf_attribute21
      ,p_vpf_attribute22               =>p_rec.vpf_attribute22
      ,p_vpf_attribute23               =>p_rec.vpf_attribute23
      ,p_vpf_attribute24               =>p_rec.vpf_attribute24
      ,p_vpf_attribute25               =>p_rec.vpf_attribute25
      ,p_vpf_attribute26               =>p_rec.vpf_attribute26
      ,p_vpf_attribute27               =>p_rec.vpf_attribute27
      ,p_vpf_attribute28               =>p_rec.vpf_attribute28
      ,p_vpf_attribute29               =>p_rec.vpf_attribute29
      ,p_vpf_attribute30               =>p_rec.vpf_attribute30
      ,p_object_version_number         =>p_rec.object_version_number
      ,p_effective_date                =>p_effective_date
      ,p_validation_start_date         =>p_validation_start_date
      ,p_validation_end_date           =>p_validation_end_date
      ,p_rt_cntng_prtn_prfl_flag       =>p_rec.rt_cntng_prtn_prfl_flag
      ,p_rt_cbr_quald_bnf_flag         =>p_rec.rt_cbr_quald_bnf_flag
      ,p_rt_optd_mdcr_flag             =>p_rec.rt_optd_mdcr_flag
      ,p_rt_lvg_rsn_flag               =>p_rec.rt_lvg_rsn_flag
      ,p_rt_pstn_flag                  =>p_rec.rt_pstn_flag
      ,p_rt_comptncy_flag              =>p_rec.rt_comptncy_flag
      ,p_rt_job_flag                   =>p_rec.rt_job_flag
      ,p_rt_qual_titl_flag             =>p_rec.rt_qual_titl_flag
      ,p_rt_dpnt_cvrd_pl_flag          =>p_rec.rt_dpnt_cvrd_pl_flag
      ,p_rt_dpnt_cvrd_plip_flag        =>p_rec.rt_dpnt_cvrd_plip_flag
      ,p_rt_dpnt_cvrd_ptip_flag        =>p_rec.rt_dpnt_cvrd_ptip_flag
      ,p_rt_dpnt_cvrd_pgm_flag         =>p_rec.rt_dpnt_cvrd_pgm_flag
      ,p_rt_enrld_oipl_flag            =>p_rec.rt_enrld_oipl_flag
      ,p_rt_enrld_pl_flag              =>p_rec.rt_enrld_pl_flag
      ,p_rt_enrld_plip_flag            =>p_rec.rt_enrld_plip_flag
      ,p_rt_enrld_ptip_flag            =>p_rec.rt_enrld_ptip_flag
      ,p_rt_enrld_pgm_flag             =>p_rec.rt_enrld_pgm_flag
      ,p_rt_prtt_anthr_pl_flag         =>p_rec.rt_prtt_anthr_pl_flag
      ,p_rt_othr_ptip_flag             =>p_rec.rt_othr_ptip_flag
      ,p_rt_no_othr_cvg_flag           =>p_rec.rt_no_othr_cvg_flag
      ,p_rt_dpnt_othr_ptip_flag        =>p_rec.rt_dpnt_othr_ptip_flag
      ,p_rt_qua_in_gr_flag    	       =>p_rec.rt_qua_in_gr_flag
      ,p_rt_perf_rtng_flag 	       =>p_rec.rt_perf_rtng_flag
      ,p_rt_elig_prfl_flag 	       =>p_rec.rt_elig_prfl_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_vrbl_rt_prfl_f'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--   be manipulated.
--
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_rec	 		 in  ben_vpf_shd.g_rec_type,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_vrbl_rt_prfl_f',
	 p_base_key_column	   => 'vrbl_rt_prfl_id',
	 p_base_key_value 	   => p_rec.vrbl_rt_prfl_id,
	 p_parent_table_name1      => 'ben_oipl_f',
	 p_parent_key_column1      => 'oipl_id',
	 p_parent_key_value1       => p_rec.oipl_id,
	 p_parent_table_name2      => 'ben_pl_f',
	 p_parent_key_column2      => 'pl_id',
	 p_parent_key_value2       => p_rec.pl_id,
         p_enforce_foreign_locking => true,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec		   in out nocopy ben_vpf_shd.g_rec_type,
  p_effective_date in     date
  ) is
--
  l_proc			varchar2(72) := g_package||'ins';
  l_datetrack_mode		varchar2(30) := 'INSERT';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  ins_lck
	(p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_rec	 		 => p_rec,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting insert validate operations
  --
  ben_vpf_bus.insert_validate
	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert
 	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Insert the row
  --
  insert_dml
 	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting post-insert operation
  --
  post_insert
 	(p_rec			 => p_rec,
	 p_effective_date	 => p_effective_date,
	 p_datetrack_mode	 => l_datetrack_mode,
	 p_validation_start_date => l_validation_start_date,
	 p_validation_end_date	 => l_validation_end_date);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_vrbl_rt_prfl_id              out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_pl_typ_opt_typ_id            in number           default null,
  p_pl_id                        in number           default null,
  p_oipl_id                      in number           default null,
  p_comp_lvl_fctr_id             in number           default null,
  p_business_group_id            in number,
  p_acty_typ_cd                  in varchar2,
  p_rt_typ_cd                    in varchar2         default null,
  p_bnft_rt_typ_cd               in varchar2         default null,
  p_tx_typ_cd                    in varchar2,
  p_vrbl_rt_trtmt_cd             in varchar2,
  p_acty_ref_perd_cd             in varchar2,
  p_mlt_cd                       in varchar2,
  p_incrmnt_elcn_val             in number           default null,
  p_dflt_elcn_val                in number           default null,
  p_mx_elcn_val                  in number           default null,
  p_mn_elcn_val                  in number           default null,
  p_lwr_lmt_val                  in number           default null,
  p_lwr_lmt_calc_rl              in number           default null,
  p_upr_lmt_val                  in number           default null,
  p_upr_lmt_calc_rl              in number           default null,
  p_ultmt_upr_lmt                in number           default null,
  p_ultmt_lwr_lmt                in number           default null,
  p_ultmt_upr_lmt_calc_rl        in number           default null,
  p_ultmt_lwr_lmt_calc_rl        in number           default null,
  p_ann_mn_elcn_val              in number           default null,
  p_ann_mx_elcn_val              in number           default null,
  p_val                          in number           default null,
  p_name                         in varchar2,
  p_no_mn_elcn_val_dfnd_flag     in varchar2,
  p_no_mx_elcn_val_dfnd_flag     in varchar2,
  p_alwys_sum_all_cvg_flag       in varchar2,
  p_alwys_cnt_all_prtts_flag     in varchar2,
  p_val_calc_rl                  in number           default null,
  p_vrbl_rt_prfl_stat_cd         in varchar2         default null,
  p_vrbl_usg_cd                  in varchar2         default null,
  p_asmt_to_use_cd               in varchar2         default null,
  p_rndg_cd                      in varchar2         default null,
  p_rndg_rl                      in number           default null,
  p_rt_hrly_slrd_flag            in varchar2         default null,
  p_rt_pstl_cd_flag              in varchar2         default null,
  p_rt_lbr_mmbr_flag             in varchar2         default null,
  p_rt_lgl_enty_flag             in varchar2         default null,
  p_rt_benfts_grp_flag           in varchar2         default null,
  p_rt_wk_loc_flag               in varchar2         default null,
  p_rt_brgng_unit_flag           in varchar2         default null,
  p_rt_age_flag                  in varchar2         default null,
  p_rt_los_flag                  in varchar2         default null,
  p_rt_per_typ_flag              in varchar2         default null,
  p_rt_fl_tm_pt_tm_flag          in varchar2         default null,
  p_rt_ee_stat_flag              in varchar2         default null,
  p_rt_grd_flag                  in varchar2         default null,
  p_rt_pct_fl_tm_flag            in varchar2         default null,
  p_rt_asnt_set_flag             in varchar2         default null,
  p_rt_hrs_wkd_flag              in varchar2         default null,
  p_rt_comp_lvl_flag             in varchar2         default null,
  p_rt_org_unit_flag             in varchar2         default null,
  p_rt_loa_rsn_flag              in varchar2         default null,
  p_rt_pyrl_flag                 in varchar2         default null,
  p_rt_schedd_hrs_flag           in varchar2         default null,
  p_rt_py_bss_flag               in varchar2         default null,
  p_rt_prfl_rl_flag              in varchar2         default null,
  p_rt_cmbn_age_los_flag         in varchar2         default null,
  p_rt_prtt_pl_flag              in varchar2         default null,
  p_rt_svc_area_flag             in varchar2         default null,
  p_rt_ppl_grp_flag              in varchar2         default null,
  p_rt_dsbld_flag                in varchar2         default null,
  p_rt_hlth_cvg_flag             in varchar2         default null,
  p_rt_poe_flag                  in varchar2         default null,
  p_rt_ttl_cvg_vol_flag          in varchar2         default null,
  p_rt_ttl_prtt_flag             in varchar2         default null,
  p_rt_gndr_flag                 in varchar2         default null,
  p_rt_tbco_use_flag             in varchar2         default null,
  p_vpf_attribute_category       in varchar2         default null,
  p_vpf_attribute1               in varchar2         default null,
  p_vpf_attribute2               in varchar2         default null,
  p_vpf_attribute3               in varchar2         default null,
  p_vpf_attribute4               in varchar2         default null,
  p_vpf_attribute5               in varchar2         default null,
  p_vpf_attribute6               in varchar2         default null,
  p_vpf_attribute7               in varchar2         default null,
  p_vpf_attribute8               in varchar2         default null,
  p_vpf_attribute9               in varchar2         default null,
  p_vpf_attribute10              in varchar2         default null,
  p_vpf_attribute11              in varchar2         default null,
  p_vpf_attribute12              in varchar2         default null,
  p_vpf_attribute13              in varchar2         default null,
  p_vpf_attribute14              in varchar2         default null,
  p_vpf_attribute15              in varchar2         default null,
  p_vpf_attribute16              in varchar2         default null,
  p_vpf_attribute17              in varchar2         default null,
  p_vpf_attribute18              in varchar2         default null,
  p_vpf_attribute19              in varchar2         default null,
  p_vpf_attribute20              in varchar2         default null,
  p_vpf_attribute21              in varchar2         default null,
  p_vpf_attribute22              in varchar2         default null,
  p_vpf_attribute23              in varchar2         default null,
  p_vpf_attribute24              in varchar2         default null,
  p_vpf_attribute25              in varchar2         default null,
  p_vpf_attribute26              in varchar2         default null,
  p_vpf_attribute27              in varchar2         default null,
  p_vpf_attribute28              in varchar2         default null,
  p_vpf_attribute29              in varchar2         default null,
  p_vpf_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date ,
  p_rt_cntng_prtn_prfl_flag	 in varchar2         default null,
  p_rt_cbr_quald_bnf_flag  	 in varchar2         default null,
  p_rt_optd_mdcr_flag      	 in varchar2         default null,
  p_rt_lvg_rsn_flag        	 in varchar2         default null,
  p_rt_pstn_flag           	 in varchar2         default null,
  p_rt_comptncy_flag       	 in varchar2         default null,
  p_rt_job_flag            	 in varchar2         default null,
  p_rt_qual_titl_flag      	 in varchar2         default null,
  p_rt_dpnt_cvrd_pl_flag   	 in varchar2         default null,
  p_rt_dpnt_cvrd_plip_flag 	 in varchar2         default null,
  p_rt_dpnt_cvrd_ptip_flag 	 in varchar2         default null,
  p_rt_dpnt_cvrd_pgm_flag  	 in varchar2         default null,
  p_rt_enrld_oipl_flag     	 in varchar2         default null,
  p_rt_enrld_pl_flag       	 in varchar2         default null,
  p_rt_enrld_plip_flag     	 in varchar2         default null,
  p_rt_enrld_ptip_flag     	 in varchar2         default null,
  p_rt_enrld_pgm_flag      	 in varchar2         default null,
  p_rt_prtt_anthr_pl_flag  	 in varchar2         default null,
  p_rt_othr_ptip_flag      	 in varchar2         default null,
  p_rt_no_othr_cvg_flag    	 in varchar2         default null,
  p_rt_dpnt_othr_ptip_flag 	 in varchar2         default null,
  p_rt_qua_in_gr_flag            in varchar2  	     default null,
  p_rt_perf_rtng_flag 	         in varchar2  	     default null,
  p_rt_elig_prfl_flag 	         in varchar2  	     default null
  ) is

--
  l_rec		ben_vpf_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_vpf_shd.convert_args
  (
  null,
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
  null ,
  p_rt_cntng_prtn_prfl_flag,
  p_rt_cbr_quald_bnf_flag,
  p_rt_optd_mdcr_flag,
  p_rt_lvg_rsn_flag  ,
  p_rt_pstn_flag     ,
  p_rt_comptncy_flag ,
  p_rt_job_flag      ,
  p_rt_qual_titl_flag ,
  p_rt_dpnt_cvrd_pl_flag  ,
  p_rt_dpnt_cvrd_plip_flag ,
  p_rt_dpnt_cvrd_ptip_flag ,
  p_rt_dpnt_cvrd_pgm_flag  ,
  p_rt_enrld_oipl_flag     ,
  p_rt_enrld_pl_flag       ,
  p_rt_enrld_plip_flag     ,
  p_rt_enrld_ptip_flag     ,
  p_rt_enrld_pgm_flag      ,
  p_rt_prtt_anthr_pl_flag  ,
  p_rt_othr_ptip_flag      ,
  p_rt_no_othr_cvg_flag    ,
  p_rt_dpnt_othr_ptip_flag ,
  p_rt_qua_in_gr_flag,
  p_rt_perf_rtng_flag,
  p_rt_elig_prfl_flag);
  --
  -- Having converted the arguments into the ben_vpf_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_vrbl_rt_prfl_id        	:= l_rec.vrbl_rt_prfl_id;
  p_effective_start_date  	:= l_rec.effective_start_date;
  p_effective_end_date    	:= l_rec.effective_end_date;
  p_object_version_number 	:= l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_vpf_ins;

/
