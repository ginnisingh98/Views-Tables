--------------------------------------------------------
--  DDL for Package Body BEN_VPF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_VPF_SHD" as
/* $Header: bevpfrhi.pkb 120.1.12010000.1 2008/07/29 13:07:55 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_vpf_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_VRBL_RT_PRFL_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_VRBL_RT_PRFL_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date		in date,
   p_vrbl_rt_prfl_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	vrbl_rt_prfl_id,
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
	rt_cntng_prtn_prfl_flag,
	rt_cbr_quald_bnf_flag,
	rt_optd_mdcr_flag,
	rt_lvg_rsn_flag,
	rt_pstn_flag ,
	rt_comptncy_flag ,
	rt_job_flag  ,
	rt_qual_titl_flag ,
	rt_dpnt_cvrd_pl_flag,
	rt_dpnt_cvrd_plip_flag ,
	rt_dpnt_cvrd_ptip_flag,
	rt_dpnt_cvrd_pgm_flag,
	rt_enrld_oipl_flag ,
	rt_enrld_pl_flag ,
	rt_enrld_plip_flag  ,
	rt_enrld_ptip_flag ,
	rt_enrld_pgm_flag  ,
	rt_prtt_anthr_pl_flag ,
	rt_othr_ptip_flag  ,
	rt_no_othr_cvg_flag ,
	rt_dpnt_othr_ptip_flag,
	rt_qua_in_gr_flag,
	rt_perf_rtng_flag,
	rt_elig_prfl_flag
    from	ben_vrbl_rt_prfl_f
    where	vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
    and		p_effective_date
    between	effective_start_date and effective_end_date;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_effective_date is null or
      p_vrbl_rt_prfl_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_vrbl_rt_prfl_id = g_old_rec.vrbl_rt_prfl_id and
        p_object_version_number = g_old_rec.object_version_number) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row
      --
      Open C_Sel1;
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_zap		 out nocopy boolean,
	 p_delete	 out nocopy boolean,
	 p_future_change out nocopy boolean,
	 p_delete_next_change out nocopy boolean) is
--
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
--
  l_parent_key_value1	number;
  l_parent_key_value2	number;
  l_parent_key_value3	number;
  --
  Cursor C_Sel1 Is
    select  t.oipl_id,
	    t.pl_typ_opt_typ_id,
	    t.pl_id
    from    ben_vrbl_rt_prfl_f t
    where   t.vrbl_rt_prfl_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1,
		    l_parent_key_value3,
		    l_parent_key_value2;
  If C_Sel1%notfound then
    Close C_Sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_vrbl_rt_prfl_f',
	 p_base_key_column	=> 'vrbl_rt_prfl_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ben_oipl_f',
	 p_parent_key_column1	=> 'oipl_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_parent_table_name2	=> 'ben_pl_f',
	 p_parent_key_column2	=> 'pl_id',
	 p_parent_key_value2	=> l_parent_key_value2,
	 p_zap			=> p_zap,
	 p_delete		=> p_delete,
	 p_future_change	=> p_future_change,
	 p_delete_next_change	=> p_delete_next_change);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_correction	 out nocopy boolean,
	 p_update	 out nocopy boolean,
	 p_update_override out nocopy boolean,
	 p_update_change_insert out nocopy boolean) is
--
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_vrbl_rt_prfl_f',
	 p_base_key_column	=> 'vrbl_rt_prfl_id',
	 p_base_key_value	=> p_base_key_value,
	 p_correction		=> p_correction,
	 p_update		=> p_update,
	 p_update_override	=> p_update_override,
	 p_update_change_insert	=> p_update_change_insert);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
	(p_effective_date		in date,
	 p_base_key_value		in number,
	 p_new_effective_end_date	in date,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date,
         p_object_version_number       out nocopy number) is
--
  l_proc 		  varchar2(72) := g_package||'upd_effective_end_date';
  l_object_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
	(p_base_table_name	=> 'ben_vrbl_rt_prfl_f',
	 p_base_key_column	=> 'vrbl_rt_prfl_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_vrbl_rt_prfl_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.vrbl_rt_prfl_id	  = p_base_key_value
  and	  p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_vrbl_rt_prfl_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date  date;
  l_validation_end_date	   date;
  l_validation_start_date1 date;
  l_validation_end_date1   date;
  l_validation_start_date2 date;
  l_validation_end_date2   date;
  l_object_invalid 	  exception;
  l_argument		  varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
	vrbl_rt_prfl_id,
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
	object_version_number ,
	rt_cntng_prtn_prfl_flag,
	rt_cbr_quald_bnf_flag,
	rt_optd_mdcr_flag,
	rt_lvg_rsn_flag,
	rt_pstn_flag ,
	rt_comptncy_flag ,
	rt_job_flag  ,
	rt_qual_titl_flag ,
	rt_dpnt_cvrd_pl_flag,
	rt_dpnt_cvrd_plip_flag ,
	rt_dpnt_cvrd_ptip_flag,
	rt_dpnt_cvrd_pgm_flag,
	rt_enrld_oipl_flag ,
	rt_enrld_pl_flag ,
	rt_enrld_plip_flag  ,
	rt_enrld_ptip_flag ,
	rt_enrld_pgm_flag  ,
	rt_prtt_anthr_pl_flag ,
	rt_othr_ptip_flag  ,
	rt_no_othr_cvg_flag ,
	rt_dpnt_othr_ptip_flag,
	rt_qua_in_gr_flag,
	rt_perf_rtng_flag,
	rt_elig_prfl_flag
    from    ben_vrbl_rt_prfl_f
    where   vrbl_rt_prfl_id         = p_vrbl_rt_prfl_id
    and	    p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  --
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'vrbl_rt_prfl_id',
                             p_argument_value => p_vrbl_rt_prfl_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
    hr_utility.set_location(l_proc, 15);
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_vrbl_rt_prfl_f',
	 p_base_key_column	   => 'vrbl_rt_prfl_id',
	 p_base_key_value 	   => p_vrbl_rt_prfl_id,
	 p_parent_table_name1      => 'ben_oipl_f',
	 p_parent_key_column1      => 'oipl_id',
	 p_parent_key_value1       => g_old_rec.oipl_id,
	 p_parent_table_name2      => 'ben_pl_f',
	 p_parent_key_column2      => 'pl_id',
	 p_parent_key_value2       => g_old_rec.pl_id,
         p_child_table_name1       => 'ben_age_rt_f',
         p_child_key_column1       => 'age_rt_id',
         p_child_table_name2       => 'ben_benfts_grp_rt_f',
         p_child_key_column2       => 'benfts_grp_rt_id',
         p_child_table_name3       => 'ben_loa_rsn_rt_f',
         p_child_key_column3       => 'loa_rsn_rt_id',
         p_child_table_name4       => 'ben_los_rt_f',
         p_child_key_column4       => 'los_rt_id',
         p_child_table_name5       => 'ben_tbco_use_rt_f',
         p_child_key_column5       => 'tbco_use_rt_id',
         p_child_table_name6       => 'ben_pct_fl_tm_rt_f',
         p_child_key_column6       => 'pct_fl_tm_rt_id',
         p_child_table_name7       => 'ben_vrbl_rt_prfl_rl_f',
         p_child_key_column7       => 'vrbl_rt_prfl_rl_id',
         p_child_table_name8       => 'ben_wk_loc_rt_f',
         p_child_key_column8       => 'wk_loc_rt_id',
         p_child_table_name9       => 'ben_org_unit_rt_f',
         p_child_key_column9       => 'org_unit_rt_id',
         p_child_table_name10      => 'ben_comp_lvl_rt_f',
         p_child_key_column10      => 'comp_lvl_rt_id',
--         p_enforce_foreign_locking => true, For Bug 3188818
        p_enforce_foreign_locking => false,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
    --

    dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_vrbl_rt_prfl_f',
	 p_base_key_column	   => 'vrbl_rt_prfl_id',
	 p_base_key_value 	   => p_vrbl_rt_prfl_id,
	 p_parent_table_name1      => 'ben_oipl_f',
	 p_parent_key_column1      => 'oipl_id',
	 p_parent_key_value1       => g_old_rec.oipl_id,
	 p_parent_table_name2      => 'ben_pl_f',
	 p_parent_key_column2      => 'pl_id',
	 p_parent_key_value2       => g_old_rec.pl_id,
	 p_child_table_name1       => 'ben_hrs_wkd_in_perd_rt_f',
	 p_child_key_column1       => 'hrs_wkd_in_perd_rt_id',
	 p_child_table_name2       => 'ben_grade_rt_f',
	 p_child_key_column2       => 'grade_rt_id',
	 p_child_table_name3       => 'ben_actl_prem_vrbl_rt_f',
	 p_child_key_column3       => 'actl_prem_vrbl_rt_id',
	 p_child_table_name4       => 'ben_bnft_vrbl_rt_f',
	 p_child_key_column4       => 'bnft_vrbl_rt_id',
	 p_child_table_name5       => 'ben_fl_tm_pt_tm_rt_f',
	 p_child_key_column5       => 'fl_tm_pt_tm_rt_id',
	 p_child_table_name6       => 'ben_lgl_enty_rt_f',
	 p_child_key_column6       => 'lgl_enty_rt_id',
	 p_child_table_name7       => 'ben_lbr_mmbr_rt_f',
	 p_child_key_column7       => 'lbr_mmbr_rt_id',
	 p_child_table_name8       => 'ben_svc_area_rt_f',
	 p_child_key_column8       => 'svc_area_rt_id',
	 p_child_table_name9       => 'ben_py_bss_rt_f',
	 p_child_key_column9       => 'py_bss_rt_id',
	 p_child_table_name10      => 'ben_pyrl_rt_f',
	 p_child_key_column10      => 'pyrl_rt_id',
--         p_enforce_foreign_locking => true, For Bug 3188818
        p_enforce_foreign_locking => false,
	 p_validation_start_date   => l_validation_start_date1,
 	 p_validation_end_date	   => l_validation_end_date1);
    --
    dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_vrbl_rt_prfl_f',
	 p_base_key_column	   => 'vrbl_rt_prfl_id',
	 p_base_key_value 	   => p_vrbl_rt_prfl_id,
	 p_parent_table_name1      => 'ben_oipl_f',
	 p_parent_key_column1      => 'oipl_id',
	 p_parent_key_value1       => g_old_rec.oipl_id,
	 p_parent_table_name2      => 'ben_pl_f',
	 p_parent_key_column2      => 'pl_id',
	 p_parent_key_value2       => g_old_rec.pl_id,
	 p_child_table_name1       => 'ben_pstl_zip_rt_f',
	 p_child_key_column1       => 'pstl_zip_rt_id',
	 p_child_table_name2       => 'ben_per_typ_rt_f',
	 p_child_key_column2       => 'per_typ_rt_id',
	 p_child_table_name3       => 'ben_hrly_slrd_rt_f',
	 p_child_key_column3       => 'hrly_slrd_rt_id',
	 p_child_table_name4       => 'ben_gndr_rt_f',
	 p_child_key_column4       => 'gndr_rt_id',
	 p_child_table_name5       => 'ben_cmbn_age_los_rt_f',
	 p_child_key_column5       => 'cmbn_age_los_rt_id',
	 p_child_table_name6       => 'ben_brgng_unit_rt_f',
	 p_child_key_column6       => 'brgng_unit_rt_id',
	 p_child_table_name7       => 'ben_asnt_set_rt_f',
	 p_child_key_column7       => 'asnt_set_rt_id',
	 p_child_table_name8       => 'ben_acty_vrbl_rt_f',
	 p_child_key_column8       => 'acty_vrbl_rt_id',
	 p_child_table_name9       => 'ben_ppl_grp_rt_f',
	 p_child_key_column9       => 'ppl_grp_rt_id',
	 p_child_table_name10      => 'ben_qual_titl_rt_f',
	 p_child_key_column10      => 'qual_titl_rt_id',
--         p_enforce_foreign_locking => true, For Bug 3188818
        p_enforce_foreign_locking => false,
	 p_validation_start_date   => l_validation_start_date2,
 	 p_validation_end_date	   => l_validation_end_date2);



      dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_vrbl_rt_prfl_f',
	 p_base_key_column	   => 'vrbl_rt_prfl_id',
	 p_base_key_value 	   => p_vrbl_rt_prfl_id,
	 p_parent_table_name1      => 'ben_oipl_f',
	 p_parent_key_column1      => 'oipl_id',
	 p_parent_key_value1       => g_old_rec.oipl_id,
	 p_parent_table_name2      => 'ben_pl_f',
	 p_parent_key_column2      => 'pl_id',
	 p_parent_key_value2       => g_old_rec.pl_id,
	 p_child_table_name1       => 'ben_cbr_quald_bnf_rt_f',
	 p_child_key_column1       => 'cbr_quald_bnf_rt_id',
	 p_child_table_name2       => 'ben_cntng_prtn_prfl_rt_f',
	 p_child_key_column2       => 'cntng_prtn_prfl_rt_id',
	 p_child_table_name3       => 'ben_comptncy_rt_f',
	 p_child_key_column3       => 'comptncy_rt_id',
	 p_child_table_name4       => 'ben_job_rt_f',
	 p_child_key_column4       => 'job_rt_id',
	 p_child_table_name5       => 'ben_lvg_rsn_rt_f',
	 p_child_key_column5       => 'lvg_rsn_rt_id',
	 p_child_table_name6       => 'ben_optd_mdcr_rt_f',
	 p_child_key_column6       => 'optd_mdcr_rt_id',
	 p_child_table_name7       => 'ben_pstn_rt_f',
	 p_child_key_column7       => 'pstn_rt_id',
	 p_child_table_name8       => 'ben_dpnt_cvrd_othr_pgm_rt_f',
	 p_child_key_column8       => 'dpnt_cvrd_othr_pgm_rt_id',
	 p_child_table_name9       => 'ben_dpnt_cvrd_othr_pl_rt_f',
	 p_child_key_column9       => 'dpnt_cvrd_othr_pl_rt_id',
	 p_child_table_name10      => 'ben_dpnt_cvrd_othr_ptip_rt_f',
	 p_child_key_column10      => 'dpnt_cvrd_othr_ptip_rt_id',
--         p_enforce_foreign_locking => true, For Bug 3188818
        p_enforce_foreign_locking => false,
	 p_validation_start_date   => l_validation_start_date2,
 	 p_validation_end_date	   => l_validation_end_date2);

      dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_vrbl_rt_prfl_f',
	 p_base_key_column	   => 'vrbl_rt_prfl_id',
	 p_base_key_value 	   => p_vrbl_rt_prfl_id,
	 p_parent_table_name1      => 'ben_oipl_f',
	 p_parent_key_column1      => 'oipl_id',
	 p_parent_key_value1       => g_old_rec.oipl_id,
	 p_parent_table_name2      => 'ben_pl_f',
	 p_parent_key_column2      => 'pl_id',
	 p_parent_key_value2       => g_old_rec.pl_id,
	 p_child_table_name1       => 'ben_dpnt_cvrd_plip_rt_f',
	 p_child_key_column1       => 'dpnt_cvrd_plip_rt_id',
	 p_child_table_name2       => 'ben_dpnt_othr_ptip_rt_f',
	 p_child_key_column2       => 'dpnt_othr_ptip_rt_id',
	 p_child_table_name3       => 'ben_enrld_anthr_oipl_rt_f',
	 p_child_key_column3       => 'enrld_anthr_oipl_rt_id',
	 p_child_table_name4       => 'ben_enrld_anthr_pgm_rt_f',
	 p_child_key_column4       => 'enrld_anthr_pgm_rt_id',
	 p_child_table_name5       => 'ben_enrld_anthr_plip_rt_f',
	 p_child_key_column5       => 'enrld_anthr_plip_rt_id',
	 p_child_table_name6       => 'ben_enrld_anthr_pl_rt_f',
	 p_child_key_column6       => 'enrld_anthr_pl_rt_id',
	 p_child_table_name7       => 'ben_enrld_anthr_ptip_rt_f',
	 p_child_key_column7       => 'enrld_anthr_ptip_rt_id',
	 p_child_table_name8       => 'ben_no_othr_cvg_rt_f',
	 p_child_key_column8       => 'no_othr_cvg_rt_id',
	 p_child_table_name9       => 'ben_othr_ptip_rt_f',
	 p_child_key_column9       => 'othr_ptip_rt_id',
	 p_child_table_name10      => 'ben_prtt_anthr_pl_rt_f',
	 p_child_key_column10      => 'prtt_anthr_pl_rt_id',
--         p_enforce_foreign_locking => true, For Bug 3188818
        p_enforce_foreign_locking => false,
	 p_validation_start_date   => l_validation_start_date2,
 	 p_validation_end_date	   => l_validation_end_date2);


       dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_vrbl_rt_prfl_f',
	 p_base_key_column	   => 'vrbl_rt_prfl_id',
	 p_base_key_value 	   => p_vrbl_rt_prfl_id,
	 p_parent_table_name1      => 'ben_oipl_f',
	 p_parent_key_column1      => 'oipl_id',
	 p_parent_key_value1       => g_old_rec.oipl_id,
	 p_parent_table_name2      => 'ben_pl_f',
	 p_parent_key_column2      => 'pl_id',
	 p_parent_key_value2       => g_old_rec.pl_id,
	 p_child_table_name1       => 'ben_qua_in_gr_rt_f',
	 p_child_key_column1       => 'qua_in_gr_rt_id',
	 p_child_table_name2       => 'ben_perf_rtng_rt_f',
	 p_child_key_column2       => 'perf_rtng_rt_id' ,
--         p_enforce_foreign_locking => true, For Bug 3188818
        p_enforce_foreign_locking => false,
	 p_validation_start_date   => l_validation_start_date2,
 	 p_validation_end_date	   => l_validation_end_date2);
    --
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  if l_validation_start_date > l_validation_start_date1 then
    --
    if l_validation_start_date2 > l_validation_start_date then
      --
      p_validation_start_date := l_validation_start_date2;
      --
    else
      --
      p_validation_start_date := l_validation_start_date;
      --
    end if;
    --
  else
    --
    if l_validation_start_date2 > l_validation_start_date1 then
      --
      p_validation_start_date := l_validation_start_date2;
      --
    else
      --
      p_validation_start_date := l_validation_start_date1;
      --
    end if;
    --
  end if;
  --
  if l_validation_end_date > l_validation_end_date1 then
    --
    if l_validation_end_date2 > l_validation_end_date then
      --
      p_validation_end_date := l_validation_end_date2;
      --
    else
      --
      p_validation_end_date := l_validation_end_date;
      --
    end if;
    --
  else
    --
    if l_validation_end_date2 > l_validation_end_date1 then
      --
      p_validation_end_date := l_validation_end_date2;
      --
    else
      --
      p_validation_end_date := l_validation_end_date1;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'ben_vrbl_rt_prfl_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'ben_vrbl_rt_prfl_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_vrbl_rt_prfl_id               in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_pl_typ_opt_typ_id             in number,
	p_pl_id                         in number,
	p_oipl_id                       in number,
        p_comp_lvl_fctr_id              in number,
	p_business_group_id             in number,
	p_acty_typ_cd                   in varchar2,
	p_rt_typ_cd                     in varchar2,
	p_bnft_rt_typ_cd                in varchar2,
	p_tx_typ_cd                     in varchar2,
	p_vrbl_rt_trtmt_cd              in varchar2,
	p_acty_ref_perd_cd              in varchar2,
	p_mlt_cd                        in varchar2,
	p_incrmnt_elcn_val              in number,
	p_dflt_elcn_val                 in number,
	p_mx_elcn_val                   in number,
	p_mn_elcn_val                   in number,
        p_lwr_lmt_val                   in number,
        p_lwr_lmt_calc_rl               in number,
        p_upr_lmt_val                   in number,
        p_upr_lmt_calc_rl               in number,
        p_ultmt_upr_lmt                 in number,
        p_ultmt_lwr_lmt                 in number,
        p_ultmt_upr_lmt_calc_rl         in number,
        p_ultmt_lwr_lmt_calc_rl         in number,
        p_ann_mn_elcn_val               in number,
        p_ann_mx_elcn_val               in number,
	p_val                           in number,
	p_name                          in varchar2,
	p_no_mn_elcn_val_dfnd_flag      in varchar2,
	p_no_mx_elcn_val_dfnd_flag      in varchar2,
        p_alwys_sum_all_cvg_flag        in varchar2,
        p_alwys_cnt_all_prtts_flag      in varchar2,
	p_val_calc_rl                   in number,
	p_vrbl_rt_prfl_stat_cd          in varchar2,
        p_vrbl_usg_cd                   in varchar2,
        p_asmt_to_use_cd                in varchar2,
        p_rndg_cd                       in varchar2,
        p_rndg_rl                       in number,
        p_rt_hrly_slrd_flag             in varchar2,
        p_rt_pstl_cd_flag               in varchar2,
        p_rt_lbr_mmbr_flag              in varchar2,
        p_rt_lgl_enty_flag              in varchar2,
        p_rt_benfts_grp_flag            in varchar2,
        p_rt_wk_loc_flag                in varchar2,
        p_rt_brgng_unit_flag            in varchar2,
        p_rt_age_flag                   in varchar2,
        p_rt_los_flag                   in varchar2,
        p_rt_per_typ_flag               in varchar2,
        p_rt_fl_tm_pt_tm_flag           in varchar2,
        p_rt_ee_stat_flag               in varchar2,
        p_rt_grd_flag                   in varchar2,
        p_rt_pct_fl_tm_flag             in varchar2,
        p_rt_asnt_set_flag              in varchar2,
        p_rt_hrs_wkd_flag               in varchar2,
        p_rt_comp_lvl_flag              in varchar2,
        p_rt_org_unit_flag              in varchar2,
        p_rt_loa_rsn_flag               in varchar2,
        p_rt_pyrl_flag                  in varchar2,
        p_rt_schedd_hrs_flag            in varchar2,
        p_rt_py_bss_flag                in varchar2,
        p_rt_prfl_rl_flag               in varchar2,
        p_rt_cmbn_age_los_flag          in varchar2,
        p_rt_prtt_pl_flag               in varchar2,
        p_rt_svc_area_flag              in varchar2,
        p_rt_ppl_grp_flag               in varchar2,
        p_rt_dsbld_flag                 in varchar2,
        p_rt_hlth_cvg_flag              in varchar2,
        p_rt_poe_flag                   in varchar2,
        p_rt_ttl_cvg_vol_flag           in varchar2,
        p_rt_ttl_prtt_flag              in varchar2,
        p_rt_gndr_flag                  in varchar2,
        p_rt_tbco_use_flag              in varchar2,
	p_vpf_attribute_category        in varchar2,
	p_vpf_attribute1                in varchar2,
	p_vpf_attribute2                in varchar2,
	p_vpf_attribute3                in varchar2,
	p_vpf_attribute4                in varchar2,
	p_vpf_attribute5                in varchar2,
	p_vpf_attribute6                in varchar2,
	p_vpf_attribute7                in varchar2,
	p_vpf_attribute8                in varchar2,
	p_vpf_attribute9                in varchar2,
	p_vpf_attribute10               in varchar2,
	p_vpf_attribute11               in varchar2,
	p_vpf_attribute12               in varchar2,
	p_vpf_attribute13               in varchar2,
	p_vpf_attribute14               in varchar2,
	p_vpf_attribute15               in varchar2,
	p_vpf_attribute16               in varchar2,
	p_vpf_attribute17               in varchar2,
	p_vpf_attribute18               in varchar2,
	p_vpf_attribute19               in varchar2,
	p_vpf_attribute20               in varchar2,
	p_vpf_attribute21               in varchar2,
	p_vpf_attribute22               in varchar2,
	p_vpf_attribute23               in varchar2,
	p_vpf_attribute24               in varchar2,
	p_vpf_attribute25               in varchar2,
	p_vpf_attribute26               in varchar2,
	p_vpf_attribute27               in varchar2,
	p_vpf_attribute28               in varchar2,
	p_vpf_attribute29               in varchar2,
	p_vpf_attribute30               in varchar2,
	p_object_version_number         in number,
	p_rt_cntng_prtn_prfl_flag	in varchar2,
	p_rt_cbr_quald_bnf_flag  	in varchar2,
	p_rt_optd_mdcr_flag      	in varchar2,
	p_rt_lvg_rsn_flag        	in varchar2,
	p_rt_pstn_flag           	in varchar2,
	p_rt_comptncy_flag       	in varchar2,
	p_rt_job_flag            	in varchar2,
	p_rt_qual_titl_flag      	in varchar2,
	p_rt_dpnt_cvrd_pl_flag   	in varchar2,
	p_rt_dpnt_cvrd_plip_flag 	in varchar2,
	p_rt_dpnt_cvrd_ptip_flag 	in varchar2,
	p_rt_dpnt_cvrd_pgm_flag  	in varchar2,
	p_rt_enrld_oipl_flag     	in varchar2,
	p_rt_enrld_pl_flag       	in varchar2,
	p_rt_enrld_plip_flag     	in varchar2,
	p_rt_enrld_ptip_flag     	in varchar2,
	p_rt_enrld_pgm_flag      	in varchar2,
	p_rt_prtt_anthr_pl_flag  	in varchar2,
	p_rt_othr_ptip_flag      	in varchar2,
	p_rt_no_othr_cvg_flag    	in varchar2,
	p_rt_dpnt_othr_ptip_flag 	in varchar2,
	p_rt_qua_in_gr_flag    	    	in varchar2,
        p_rt_perf_rtng_flag    	    	in varchar2,
        p_rt_elig_prfl_flag    	    	in varchar2)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.vrbl_rt_prfl_id                  := p_vrbl_rt_prfl_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.pl_typ_opt_typ_id                := p_pl_typ_opt_typ_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.comp_lvl_fctr_id                 := p_comp_lvl_fctr_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.acty_typ_cd                      := p_acty_typ_cd;
  l_rec.rt_typ_cd                        := p_rt_typ_cd;
  l_rec.bnft_rt_typ_cd                   := p_bnft_rt_typ_cd;
  l_rec.tx_typ_cd                        := p_tx_typ_cd;
  l_rec.vrbl_rt_trtmt_cd                 := p_vrbl_rt_trtmt_cd;
  l_rec.acty_ref_perd_cd                 := p_acty_ref_perd_cd;
  l_rec.mlt_cd                           := p_mlt_cd;
  l_rec.incrmnt_elcn_val                 := p_incrmnt_elcn_val;
  l_rec.dflt_elcn_val                    := p_dflt_elcn_val;
  l_rec.mx_elcn_val                      := p_mx_elcn_val;
  l_rec.mn_elcn_val                      := p_mn_elcn_val;
  l_rec.lwr_lmt_val                      := p_lwr_lmt_val;
  l_rec.lwr_lmt_calc_rl                  := p_lwr_lmt_calc_rl;
  l_rec.upr_lmt_val                      := p_upr_lmt_val;
  l_rec.upr_lmt_calc_rl                  := p_upr_lmt_calc_rl;
  l_rec.ultmt_upr_lmt                    := p_ultmt_upr_lmt;
  l_rec.ultmt_lwr_lmt                    := p_ultmt_lwr_lmt;
  l_rec.ultmt_upr_lmt_calc_rl            := p_ultmt_upr_lmt_calc_rl;
  l_rec.ultmt_lwr_lmt_calc_rl            := p_ultmt_lwr_lmt_calc_rl;
  l_rec.ann_mn_elcn_val                  := p_ann_mn_elcn_val;
  l_rec.ann_mx_elcn_val                  := p_ann_mx_elcn_val;
  l_rec.val                              := p_val;
  l_rec.name                             := p_name;
  l_rec.no_mn_elcn_val_dfnd_flag         := p_no_mn_elcn_val_dfnd_flag;
  l_rec.no_mx_elcn_val_dfnd_flag         := p_no_mx_elcn_val_dfnd_flag;
  l_rec.alwys_sum_all_cvg_flag           := p_alwys_sum_all_cvg_flag;
  l_rec.alwys_cnt_all_prtts_flag         := p_alwys_cnt_all_prtts_flag;
  l_rec.val_calc_rl                      := p_val_calc_rl;
  l_rec.vrbl_rt_prfl_stat_cd             := p_vrbl_rt_prfl_stat_cd;
  l_rec.vrbl_usg_cd                      := p_vrbl_usg_cd;
  l_rec.asmt_to_use_cd                   := p_asmt_to_use_cd;
  l_rec.rndg_cd                          := p_rndg_cd;
  l_rec.rndg_rl                          := p_rndg_rl;
  l_rec.rt_hrly_slrd_flag                := p_rt_hrly_slrd_flag;
  l_rec.rt_pstl_cd_flag                  := p_rt_pstl_cd_flag;
  l_rec.rt_lbr_mmbr_flag                 := p_rt_lbr_mmbr_flag;
  l_rec.rt_lgl_enty_flag                 := p_rt_lgl_enty_flag;
  l_rec.rt_benfts_grp_flag               := p_rt_benfts_grp_flag;
  l_rec.rt_wk_loc_flag                   := p_rt_wk_loc_flag;
  l_rec.rt_brgng_unit_flag               := p_rt_brgng_unit_flag;
  l_rec.rt_age_flag                      := p_rt_age_flag;
  l_rec.rt_los_flag                      := p_rt_los_flag;
  l_rec.rt_per_typ_flag                  := p_rt_per_typ_flag;
  l_rec.rt_fl_tm_pt_tm_flag              := p_rt_fl_tm_pt_tm_flag;
  l_rec.rt_ee_stat_flag                  := p_rt_ee_stat_flag;
  l_rec.rt_grd_flag                      := p_rt_grd_flag;
  l_rec.rt_pct_fl_tm_flag                := p_rt_pct_fl_tm_flag;
  l_rec.rt_asnt_set_flag                 := p_rt_asnt_set_flag;
  l_rec.rt_hrs_wkd_flag                  := p_rt_hrs_wkd_flag;
  l_rec.rt_comp_lvl_flag                 := p_rt_comp_lvl_flag;
  l_rec.rt_org_unit_flag                 := p_rt_org_unit_flag;
  l_rec.rt_loa_rsn_flag                  := p_rt_loa_rsn_flag;
  l_rec.rt_pyrl_flag                     := p_rt_pyrl_flag;
  l_rec.rt_schedd_hrs_flag               := p_rt_schedd_hrs_flag;
  l_rec.rt_py_bss_flag                   := p_rt_py_bss_flag;
  l_rec.rt_prfl_rl_flag                  := p_rt_prfl_rl_flag;
  l_rec.rt_cmbn_age_los_flag             := p_rt_cmbn_age_los_flag;
  l_rec.rt_prtt_pl_flag                  := p_rt_prtt_pl_flag;
  l_rec.rt_svc_area_flag                 := p_rt_svc_area_flag;
  l_rec.rt_ppl_grp_flag                  := p_rt_ppl_grp_flag;
  l_rec.rt_dsbld_flag                    := p_rt_dsbld_flag;
  l_rec.rt_hlth_cvg_flag                 := p_rt_hlth_cvg_flag;
  l_rec.rt_poe_flag                      := p_rt_poe_flag;
  l_rec.rt_ttl_cvg_vol_flag              := p_rt_ttl_cvg_vol_flag;
  l_rec.rt_ttl_prtt_flag                 := p_rt_ttl_prtt_flag;
  l_rec.rt_gndr_flag                     := p_rt_gndr_flag;
  l_rec.rt_tbco_use_flag                 := p_rt_tbco_use_flag;
  l_rec.vpf_attribute_category           := p_vpf_attribute_category;
  l_rec.vpf_attribute1                   := p_vpf_attribute1;
  l_rec.vpf_attribute2                   := p_vpf_attribute2;
  l_rec.vpf_attribute3                   := p_vpf_attribute3;
  l_rec.vpf_attribute4                   := p_vpf_attribute4;
  l_rec.vpf_attribute5                   := p_vpf_attribute5;
  l_rec.vpf_attribute6                   := p_vpf_attribute6;
  l_rec.vpf_attribute7                   := p_vpf_attribute7;
  l_rec.vpf_attribute8                   := p_vpf_attribute8;
  l_rec.vpf_attribute9                   := p_vpf_attribute9;
  l_rec.vpf_attribute10                  := p_vpf_attribute10;
  l_rec.vpf_attribute11                  := p_vpf_attribute11;
  l_rec.vpf_attribute12                  := p_vpf_attribute12;
  l_rec.vpf_attribute13                  := p_vpf_attribute13;
  l_rec.vpf_attribute14                  := p_vpf_attribute14;
  l_rec.vpf_attribute15                  := p_vpf_attribute15;
  l_rec.vpf_attribute16                  := p_vpf_attribute16;
  l_rec.vpf_attribute17                  := p_vpf_attribute17;
  l_rec.vpf_attribute18                  := p_vpf_attribute18;
  l_rec.vpf_attribute19                  := p_vpf_attribute19;
  l_rec.vpf_attribute20                  := p_vpf_attribute20;
  l_rec.vpf_attribute21                  := p_vpf_attribute21;
  l_rec.vpf_attribute22                  := p_vpf_attribute22;
  l_rec.vpf_attribute23                  := p_vpf_attribute23;
  l_rec.vpf_attribute24                  := p_vpf_attribute24;
  l_rec.vpf_attribute25                  := p_vpf_attribute25;
  l_rec.vpf_attribute26                  := p_vpf_attribute26;
  l_rec.vpf_attribute27                  := p_vpf_attribute27;
  l_rec.vpf_attribute28                  := p_vpf_attribute28;
  l_rec.vpf_attribute29                  := p_vpf_attribute29;
  l_rec.vpf_attribute30                  := p_vpf_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.rt_cntng_prtn_prfl_flag		 := p_rt_cntng_prtn_prfl_flag;
  l_rec.rt_cbr_quald_bnf_flag  		 := p_rt_cbr_quald_bnf_flag;
  l_rec.rt_optd_mdcr_flag      		 := p_rt_optd_mdcr_flag;
  l_rec.rt_lvg_rsn_flag        		 := p_rt_lvg_rsn_flag;
  l_rec.rt_pstn_flag           		 := p_rt_pstn_flag;
  l_rec.rt_comptncy_flag       		 := p_rt_comptncy_flag ;
  l_rec.rt_job_flag            		 := p_rt_job_flag;
  l_rec.rt_qual_titl_flag      		 := p_rt_qual_titl_flag ;
  l_rec.rt_dpnt_cvrd_pl_flag   		 := p_rt_dpnt_cvrd_pl_flag;
  l_rec.rt_dpnt_cvrd_plip_flag 		 := p_rt_dpnt_cvrd_plip_flag ;
  l_rec.rt_dpnt_cvrd_ptip_flag 		 := p_rt_dpnt_cvrd_ptip_flag ;
  l_rec.rt_dpnt_cvrd_pgm_flag  		 := p_rt_dpnt_cvrd_pgm_flag;
  l_rec.rt_enrld_oipl_flag     		 := p_rt_enrld_oipl_flag ;
  l_rec.rt_enrld_pl_flag       		 := p_rt_enrld_pl_flag  ;
  l_rec.rt_enrld_plip_flag     		 := p_rt_enrld_plip_flag ;
  l_rec.rt_enrld_ptip_flag     		 := p_rt_enrld_ptip_flag ;
  l_rec.rt_enrld_pgm_flag      		 := p_rt_enrld_pgm_flag  ;
  l_rec.rt_prtt_anthr_pl_flag  		 := p_rt_prtt_anthr_pl_flag ;
  l_rec.rt_othr_ptip_flag      		 := p_rt_othr_ptip_flag  ;
  l_rec.rt_no_othr_cvg_flag    		 := p_rt_no_othr_cvg_flag;
  l_rec.rt_dpnt_othr_ptip_flag 		 := p_rt_dpnt_othr_ptip_flag ;
  l_rec.rt_qua_in_gr_flag 		 := p_rt_qua_in_gr_flag;
  l_rec.rt_perf_rtng_flag 		 := p_rt_perf_rtng_flag;
  l_rec.rt_elig_prfl_flag 		 := p_rt_elig_prfl_flag;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_vpf_shd;

/
