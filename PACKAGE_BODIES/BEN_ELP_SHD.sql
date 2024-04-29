--------------------------------------------------------
--  DDL for Package Body BEN_ELP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELP_SHD" as
/* $Header: beelprhi.pkb 120.5 2007/01/24 05:18:55 rgajula ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_elp_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_ELIGY_PRFL_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIGY_PRFL_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIGY_PRFL_UK1') Then
   /*
    fnd_message.set_name('BEN', 'BEN_52347_NAME_NOT_UNIQUE');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
   */  -- Commented as part of bug 3134750
    fnd_message.set_name('BEN', 'BEN_91009_NAME_NOT_UNIQUE');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
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
   p_eligy_prfl_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	eligy_prfl_id,
	effective_start_date,
	effective_end_date,
	name,
	description,
	stat_cd,
	asmt_to_use_cd,
        elig_enrld_plip_flag,
        elig_cbr_quald_bnf_flag,
        elig_enrld_ptip_flag,
        elig_dpnt_cvrd_plip_flag,
        elig_dpnt_cvrd_ptip_flag,
        elig_dpnt_cvrd_pgm_flag,
        elig_job_flag,
        elig_hrly_slrd_flag,
        elig_pstl_cd_flag,
        elig_lbr_mmbr_flag,
        elig_lgl_enty_flag,
        elig_benfts_grp_flag,
        elig_wk_loc_flag,
        elig_brgng_unit_flag,
        elig_age_flag,
        elig_los_flag,
        elig_per_typ_flag,
        elig_fl_tm_pt_tm_flag,
        elig_ee_stat_flag,
        elig_grd_flag,
        elig_pct_fl_tm_flag,
        elig_asnt_set_flag,
        elig_hrs_wkd_flag,
        elig_comp_lvl_flag,
        elig_org_unit_flag,
        elig_loa_rsn_flag,
        elig_pyrl_flag,
        elig_schedd_hrs_flag,
        elig_py_bss_flag,
        eligy_prfl_rl_flag,
        elig_cmbn_age_los_flag,
        cntng_prtn_elig_prfl_flag,
        elig_prtt_pl_flag,
        elig_ppl_grp_flag,
        elig_svc_area_flag,
        elig_ptip_prte_flag,
        elig_no_othr_cvg_flag,
        elig_enrld_pl_flag,
        elig_enrld_oipl_flag,
        elig_enrld_pgm_flag,
        elig_dpnt_cvrd_pl_flag,
        elig_lvg_rsn_flag,
        elig_optd_mdcr_flag,
        elig_tbco_use_flag,
        elig_dpnt_othr_ptip_flag,
	business_group_id,
	elp_attribute_category,
	elp_attribute1,
	elp_attribute2,
	elp_attribute3,
	elp_attribute4,
	elp_attribute5,
	elp_attribute6,
	elp_attribute7,
	elp_attribute8,
	elp_attribute9,
	elp_attribute10,
	elp_attribute11,
	elp_attribute12,
	elp_attribute13,
	elp_attribute14,
	elp_attribute15,
	elp_attribute16,
	elp_attribute17,
	elp_attribute18,
	elp_attribute19,
	elp_attribute20,
	elp_attribute21,
	elp_attribute22,
	elp_attribute23,
	elp_attribute24,
	elp_attribute25,
	elp_attribute26,
	elp_attribute27,
	elp_attribute28,
	elp_attribute29,
	elp_attribute30,
        elig_mrtl_sts_flag,
        elig_gndr_flag,
        elig_dsblty_ctg_flag,
        elig_dsblty_rsn_flag,
        elig_dsblty_dgr_flag,
        elig_suppl_role_flag,
        elig_qual_titl_flag,
        elig_pstn_flag,
        elig_prbtn_perd_flag,
        elig_sp_clng_prg_pt_flag,
        bnft_cagr_prtn_cd,
        elig_dsbld_flag,
        elig_ttl_cvg_vol_flag,
        elig_ttl_prtt_flag,
        elig_comptncy_flag,
        elig_hlth_cvg_flag,
        elig_anthr_pl_flag,
        elig_qua_in_gr_flag,
        elig_perf_rtng_flag,
        elig_crit_values_flag,    /* RBC */
	object_version_number
    from	ben_eligy_prfl_f
    where	eligy_prfl_id = p_eligy_prfl_id
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
      p_eligy_prfl_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_eligy_prfl_id = g_old_rec.eligy_prfl_id and
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
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
  --
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_eligy_prfl_f',
	 p_base_key_column	=> 'eligy_prfl_id',
	 p_base_key_value	=> p_base_key_value,
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
	 p_base_table_name	=> 'ben_eligy_prfl_f',
	 p_base_key_column	=> 'eligy_prfl_id',
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
	(p_base_table_name	=> 'ben_eligy_prfl_f',
	 p_base_key_column	=> 'eligy_prfl_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_eligy_prfl_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.eligy_prfl_id	  = p_base_key_value
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
	 p_eligy_prfl_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_object_invalid 	  exception;
  l_argument		  varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
	eligy_prfl_id,
	effective_start_date,
	effective_end_date,
	name,
	description,
	stat_cd,
	asmt_to_use_cd,
        elig_enrld_plip_flag,
        elig_cbr_quald_bnf_flag,
        elig_enrld_ptip_flag,
        elig_dpnt_cvrd_plip_flag,
        elig_dpnt_cvrd_ptip_flag,
        elig_dpnt_cvrd_pgm_flag,
        elig_job_flag,
        elig_hrly_slrd_flag,
        elig_pstl_cd_flag,
        elig_lbr_mmbr_flag,
        elig_lgl_enty_flag,
        elig_benfts_grp_flag,
        elig_wk_loc_flag,
        elig_brgng_unit_flag,
        elig_age_flag,
        elig_los_flag,
        elig_per_typ_flag,
        elig_fl_tm_pt_tm_flag,
        elig_ee_stat_flag,
        elig_grd_flag,
        elig_pct_fl_tm_flag,
        elig_asnt_set_flag,
        elig_hrs_wkd_flag,
        elig_comp_lvl_flag,
        elig_org_unit_flag,
        elig_loa_rsn_flag,
        elig_pyrl_flag,
        elig_schedd_hrs_flag,
        elig_py_bss_flag,
        eligy_prfl_rl_flag,
        elig_cmbn_age_los_flag,
        cntng_prtn_elig_prfl_flag,
        elig_prtt_pl_flag,
        elig_ppl_grp_flag,
        elig_svc_area_flag,
        elig_ptip_prte_flag,
        elig_no_othr_cvg_flag,
        elig_enrld_pl_flag,
        elig_enrld_oipl_flag,
        elig_enrld_pgm_flag,
        elig_dpnt_cvrd_pl_flag,
        elig_lvg_rsn_flag,
        elig_optd_mdcr_flag,
        elig_tbco_use_flag,
        elig_dpnt_othr_ptip_flag,
	business_group_id,
	elp_attribute_category,
	elp_attribute1,
	elp_attribute2,
	elp_attribute3,
	elp_attribute4,
	elp_attribute5,
	elp_attribute6,
	elp_attribute7,
	elp_attribute8,
	elp_attribute9,
	elp_attribute10,
	elp_attribute11,
	elp_attribute12,
	elp_attribute13,
	elp_attribute14,
	elp_attribute15,
	elp_attribute16,
	elp_attribute17,
	elp_attribute18,
	elp_attribute19,
	elp_attribute20,
	elp_attribute21,
	elp_attribute22,
	elp_attribute23,
	elp_attribute24,
	elp_attribute25,
	elp_attribute26,
	elp_attribute27,
	elp_attribute28,
	elp_attribute29,
	elp_attribute30,
        elig_mrtl_sts_flag,
        elig_gndr_flag,
        elig_dsblty_ctg_flag,
        elig_dsblty_rsn_flag,
        elig_dsblty_dgr_flag,
        elig_suppl_role_flag,
        elig_qual_titl_flag,
        elig_pstn_flag,
        elig_prbtn_perd_flag,
        elig_sp_clng_prg_pt_flag,
        bnft_cagr_prtn_cd,
	elig_dsbld_flag,
	elig_ttl_cvg_vol_flag,
	elig_ttl_prtt_flag,
	elig_comptncy_flag,
	elig_hlth_cvg_flag,
	elig_anthr_pl_flag,
	elig_qua_in_gr_flag,
	elig_perf_rtng_flag,
        elig_crit_values_flag,   /* RBC */
	object_version_number
    from    ben_eligy_prfl_f
    where   eligy_prfl_id         = p_eligy_prfl_id
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
                             p_argument       => 'eligy_prfl_id',
                             p_argument_value => p_eligy_prfl_id);
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
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
    hr_utility.set_location(l_proc, 15);
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_eligy_prfl_f',
	 p_base_key_column	   => 'eligy_prfl_id',
	 p_base_key_value 	   => p_eligy_prfl_id,
	 p_child_table_name1       => 'ben_cntng_prtn_elig_prfl_f',
	 p_child_key_column1       => 'cntng_prtn_elig_prfl_id',
       p_enforce_foreign_locking => true,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ben_eligy_prfl_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_eligy_prfl_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_eligy_prfl_id                 in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_name                          in varchar2,
	p_description                   in varchar2,
	p_stat_cd                       in varchar2,
	p_asmt_to_use_cd                in varchar2,
        p_elig_enrld_plip_flag          in varchar2,
        p_elig_cbr_quald_bnf_flag       in varchar2,
        p_elig_enrld_ptip_flag          in varchar2,
        p_elig_dpnt_cvrd_plip_flag      in varchar2,
        p_elig_dpnt_cvrd_ptip_flag      in varchar2,
        p_elig_dpnt_cvrd_pgm_flag       in varchar2,
        p_elig_job_flag                 in varchar2,
        p_elig_hrly_slrd_flag           in varchar2,
        p_elig_pstl_cd_flag             in varchar2,
        p_elig_lbr_mmbr_flag            in varchar2,
        p_elig_lgl_enty_flag            in varchar2,
        p_elig_benfts_grp_flag          in varchar2,
        p_elig_wk_loc_flag              in varchar2,
        p_elig_brgng_unit_flag          in varchar2,
        p_elig_age_flag                 in varchar2,
        p_elig_los_flag                 in varchar2,
        p_elig_per_typ_flag             in varchar2,
        p_elig_fl_tm_pt_tm_flag         in varchar2,
        p_elig_ee_stat_flag             in varchar2,
        p_elig_grd_flag                 in varchar2,
        p_elig_pct_fl_tm_flag           in varchar2,
        p_elig_asnt_set_flag            in varchar2,
        p_elig_hrs_wkd_flag             in varchar2,
        p_elig_comp_lvl_flag            in varchar2,
        p_elig_org_unit_flag            in varchar2,
        p_elig_loa_rsn_flag             in varchar2,
        p_elig_pyrl_flag                in varchar2,
        p_elig_schedd_hrs_flag          in varchar2,
        p_elig_py_bss_flag              in varchar2,
        p_eligy_prfl_rl_flag            in varchar2,
        p_elig_cmbn_age_los_flag        in varchar2,
        p_cntng_prtn_elig_prfl_flag     in varchar2,
        p_elig_prtt_pl_flag             in varchar2,
        p_elig_ppl_grp_flag             in varchar2,
        p_elig_svc_area_flag            in varchar2,
        p_elig_ptip_prte_flag           in varchar2,
        p_elig_no_othr_cvg_flag         in varchar2,
        p_elig_enrld_pl_flag            in varchar2,
        p_elig_enrld_oipl_flag          in varchar2,
        p_elig_enrld_pgm_flag           in varchar2,
        p_elig_dpnt_cvrd_pl_flag        in varchar2,
        p_elig_lvg_rsn_flag             in varchar2,
        p_elig_optd_mdcr_flag           in varchar2,
        p_elig_tbco_use_flag            in varchar2,
        p_elig_dpnt_othr_ptip_flag      in varchar2,
	p_business_group_id             in number,
	p_elp_attribute_category        in varchar2,
	p_elp_attribute1                in varchar2,
	p_elp_attribute2                in varchar2,
	p_elp_attribute3                in varchar2,
	p_elp_attribute4                in varchar2,
	p_elp_attribute5                in varchar2,
	p_elp_attribute6                in varchar2,
	p_elp_attribute7                in varchar2,
	p_elp_attribute8                in varchar2,
	p_elp_attribute9                in varchar2,
	p_elp_attribute10               in varchar2,
	p_elp_attribute11               in varchar2,
	p_elp_attribute12               in varchar2,
	p_elp_attribute13               in varchar2,
	p_elp_attribute14               in varchar2,
	p_elp_attribute15               in varchar2,
	p_elp_attribute16               in varchar2,
	p_elp_attribute17               in varchar2,
	p_elp_attribute18               in varchar2,
	p_elp_attribute19               in varchar2,
	p_elp_attribute20               in varchar2,
	p_elp_attribute21               in varchar2,
	p_elp_attribute22               in varchar2,
	p_elp_attribute23               in varchar2,
	p_elp_attribute24               in varchar2,
	p_elp_attribute25               in varchar2,
	p_elp_attribute26               in varchar2,
	p_elp_attribute27               in varchar2,
	p_elp_attribute28               in varchar2,
	p_elp_attribute29               in varchar2,
	p_elp_attribute30               in varchar2,
        p_elig_mrtl_sts_flag            in varchar2,
        p_elig_gndr_flag                in varchar2,
        p_elig_dsblty_ctg_flag          in varchar2,
        p_elig_dsblty_rsn_flag          in varchar2,
        p_elig_dsblty_dgr_flag          in varchar2,
        p_elig_suppl_role_flag          in varchar2,
        p_elig_qual_titl_flag           in varchar2,
        p_elig_pstn_flag                in varchar2,
        p_elig_prbtn_perd_flag          in varchar2,
        p_elig_sp_clng_prg_pt_flag      in varchar2,
        p_bnft_cagr_prtn_cd             in varchar2,
	p_elig_dsbld_flag               in varchar2,
	p_elig_ttl_cvg_vol_flag         in varchar2,
	p_elig_ttl_prtt_flag            in varchar2,
	p_elig_comptncy_flag            in varchar2,
	p_elig_hlth_cvg_flag		in varchar2,
	p_elig_anthr_pl_flag		in varchar2,
	p_elig_qua_in_gr_flag		in varchar2,
	p_elig_perf_rtng_flag		in varchar2,
        p_elig_crit_values_flag         in varchar2,   /* RBC */
	p_object_version_number         in number
	)
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
  l_rec.eligy_prfl_id                    := p_eligy_prfl_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.name                             := p_name;
  l_rec.description                      := p_description;
  l_rec.stat_cd                          := p_stat_cd;
  l_rec.asmt_to_use_cd                   := p_asmt_to_use_cd;
  l_rec.elig_enrld_plip_flag             := p_elig_enrld_plip_flag;
  l_rec.elig_cbr_quald_bnf_flag          := p_elig_cbr_quald_bnf_flag;
  l_rec.elig_enrld_ptip_flag             := p_elig_enrld_ptip_flag;
  l_rec.elig_dpnt_cvrd_plip_flag         := p_elig_dpnt_cvrd_plip_flag;
  l_rec.elig_dpnt_cvrd_ptip_flag         := p_elig_dpnt_cvrd_ptip_flag;
  l_rec.elig_dpnt_cvrd_pgm_flag          := p_elig_dpnt_cvrd_pgm_flag;
  l_rec.elig_job_flag                    := p_elig_job_flag;
  l_rec.elig_hrly_slrd_flag              := p_elig_hrly_slrd_flag;
  l_rec.elig_pstl_cd_flag                := p_elig_pstl_cd_flag;
  l_rec.elig_lbr_mmbr_flag               := p_elig_lbr_mmbr_flag;
  l_rec.elig_lgl_enty_flag               := p_elig_lgl_enty_flag;
  l_rec.elig_benfts_grp_flag             := p_elig_benfts_grp_flag;
  l_rec.elig_wk_loc_flag                 := p_elig_wk_loc_flag;
  l_rec.elig_brgng_unit_flag             := p_elig_brgng_unit_flag;
  l_rec.elig_age_flag                    := p_elig_age_flag;
  l_rec.elig_los_flag                    := p_elig_los_flag;
  l_rec.elig_per_typ_flag                := p_elig_per_typ_flag;
  l_rec.elig_fl_tm_pt_tm_flag            := p_elig_fl_tm_pt_tm_flag;
  l_rec.elig_ee_stat_flag                := p_elig_ee_stat_flag;
  l_rec.elig_grd_flag                    := p_elig_grd_flag;
  l_rec.elig_pct_fl_tm_flag              := p_elig_pct_fl_tm_flag;
  l_rec.elig_asnt_set_flag               := p_elig_asnt_set_flag;
  l_rec.elig_hrs_wkd_flag                := p_elig_hrs_wkd_flag;
  l_rec.elig_comp_lvl_flag               := p_elig_comp_lvl_flag;
  l_rec.elig_org_unit_flag               := p_elig_org_unit_flag;
  l_rec.elig_loa_rsn_flag                := p_elig_loa_rsn_flag;
  l_rec.elig_pyrl_flag                   := p_elig_pyrl_flag;
  l_rec.elig_schedd_hrs_flag             := p_elig_schedd_hrs_flag;
  l_rec.elig_py_bss_flag                 := p_elig_py_bss_flag;
  l_rec.eligy_prfl_rl_flag               := p_eligy_prfl_rl_flag;
  l_rec.elig_cmbn_age_los_flag           := p_elig_cmbn_age_los_flag;
  l_rec.cntng_prtn_elig_prfl_flag        := p_cntng_prtn_elig_prfl_flag;
  l_rec.elig_prtt_pl_flag                := p_elig_prtt_pl_flag;
  l_rec.elig_ppl_grp_flag                := p_elig_ppl_grp_flag;
  l_rec.elig_svc_area_flag               := p_elig_svc_area_flag;
  l_rec.elig_ptip_prte_flag              := p_elig_ptip_prte_flag;
  l_rec.elig_no_othr_cvg_flag            := p_elig_no_othr_cvg_flag;
  l_rec.elig_enrld_pl_flag               := p_elig_enrld_pl_flag;
  l_rec.elig_enrld_oipl_flag             := p_elig_enrld_oipl_flag;
  l_rec.elig_enrld_pgm_flag              := p_elig_enrld_pgm_flag;
  l_rec.elig_dpnt_cvrd_pl_flag           := p_elig_dpnt_cvrd_pl_flag;
  l_rec.elig_lvg_rsn_flag                := p_elig_lvg_rsn_flag;
  l_rec.elig_optd_mdcr_flag              := p_elig_optd_mdcr_flag;
  l_rec.elig_tbco_use_flag               := p_elig_tbco_use_flag;
  l_rec.elig_dpnt_othr_ptip_flag         := p_elig_dpnt_othr_ptip_flag;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.elp_attribute_category           := p_elp_attribute_category;
  l_rec.elp_attribute1                   := p_elp_attribute1;
  l_rec.elp_attribute2                   := p_elp_attribute2;
  l_rec.elp_attribute3                   := p_elp_attribute3;
  l_rec.elp_attribute4                   := p_elp_attribute4;
  l_rec.elp_attribute5                   := p_elp_attribute5;
  l_rec.elp_attribute6                   := p_elp_attribute6;
  l_rec.elp_attribute7                   := p_elp_attribute7;
  l_rec.elp_attribute8                   := p_elp_attribute8;
  l_rec.elp_attribute9                   := p_elp_attribute9;
  l_rec.elp_attribute10                  := p_elp_attribute10;
  l_rec.elp_attribute11                  := p_elp_attribute11;
  l_rec.elp_attribute12                  := p_elp_attribute12;
  l_rec.elp_attribute13                  := p_elp_attribute13;
  l_rec.elp_attribute14                  := p_elp_attribute14;
  l_rec.elp_attribute15                  := p_elp_attribute15;
  l_rec.elp_attribute16                  := p_elp_attribute16;
  l_rec.elp_attribute17                  := p_elp_attribute17;
  l_rec.elp_attribute18                  := p_elp_attribute18;
  l_rec.elp_attribute19                  := p_elp_attribute19;
  l_rec.elp_attribute20                  := p_elp_attribute20;
  l_rec.elp_attribute21                  := p_elp_attribute21;
  l_rec.elp_attribute22                  := p_elp_attribute22;
  l_rec.elp_attribute23                  := p_elp_attribute23;
  l_rec.elp_attribute24                  := p_elp_attribute24;
  l_rec.elp_attribute25                  := p_elp_attribute25;
  l_rec.elp_attribute26                  := p_elp_attribute26;
  l_rec.elp_attribute27                  := p_elp_attribute27;
  l_rec.elp_attribute28                  := p_elp_attribute28;
  l_rec.elp_attribute29                  := p_elp_attribute29;
  l_rec.elp_attribute30                  := p_elp_attribute30;
  l_rec.elig_mrtl_sts_flag               := p_elig_mrtl_sts_flag ;
  l_rec.elig_gndr_flag                   := p_elig_gndr_flag  ;
  l_rec.elig_dsblty_ctg_flag             := p_elig_dsblty_ctg_flag  ;
  l_rec.elig_dsblty_rsn_flag             := p_elig_dsblty_rsn_flag  ;
  l_rec.elig_dsblty_dgr_flag             := p_elig_dsblty_dgr_flag ;
  l_rec.elig_suppl_role_flag             := p_elig_suppl_role_flag ;
  l_rec.elig_qual_titl_flag              := p_elig_qual_titl_flag ;
  l_rec.elig_pstn_flag                   := p_elig_pstn_flag   ;
  l_rec.elig_prbtn_perd_flag             := p_elig_prbtn_perd_flag ;
  l_rec.elig_sp_clng_prg_pt_flag         := p_elig_sp_clng_prg_pt_flag ;
  l_rec.bnft_cagr_prtn_cd                := p_bnft_cagr_prtn_cd;
  l_rec.elig_dsbld_flag             	 := p_elig_dsbld_flag;
  l_rec.elig_ttl_cvg_vol_flag       	 := p_elig_ttl_cvg_vol_flag;
  l_rec.elig_ttl_prtt_flag          	 := p_elig_ttl_prtt_flag;
  l_rec.elig_comptncy_flag          	 := p_elig_comptncy_flag;
  l_rec.elig_hlth_cvg_flag		 := p_elig_hlth_cvg_flag;
  l_rec.elig_anthr_pl_flag		 := p_elig_anthr_pl_flag;
  l_rec.elig_qua_in_gr_flag		 := p_elig_qua_in_gr_flag;
  l_rec.elig_perf_rtng_flag		 := p_elig_perf_rtng_flag;
  l_rec.elig_crit_values_flag            := p_elig_crit_values_flag;      /* RBC */
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_elp_shd;

/
