--------------------------------------------------------
--  DDL for Package Body BEN_PGM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PGM_SHD" as
/* $Header: bepgmrhi.pkb 120.1 2005/12/09 05:02:29 nhunur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pgm_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_PGM_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PGM_F_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
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
   p_pgm_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	pgm_id,
	effective_start_date,
	effective_end_date,
	name,
	dpnt_adrs_rqd_flag,
	pgm_prvds_no_auto_enrt_flag,
	dpnt_dob_rqd_flag,
	pgm_prvds_no_dflt_enrt_flag,
	dpnt_dsgn_lvl_cd,
	dpnt_legv_id_rqd_flag,
	pgm_stat_cd,
	ivr_ident,
	pgm_typ_cd,
	elig_apls_flag,
	uses_all_asmts_for_rts_flag,
	url_ref_name,
	pgm_desc,
	prtn_elig_ovrid_alwd_flag,
	pgm_use_all_asnts_elig_flag,
	dpnt_dsgn_cd,
	mx_dpnt_pct_prtt_lf_amt,
	mx_sps_pct_prtt_lf_amt,
	coord_cvg_for_all_pls_flg,
        enrt_cvg_end_dt_cd,
        enrt_cvg_end_dt_rl,
	pgm_grp_cd,
	acty_ref_perd_cd,
	drvbl_fctr_dpnt_elig_flag,
	pgm_uom,
	enrt_info_rt_freq_cd,
	drvbl_fctr_prtn_elig_flag,
	drvbl_fctr_apls_rts_flag,
        alws_unrstrctd_enrt_flag,
        enrt_cd,
        enrt_mthd_cd,
        poe_lvl_cd,
        enrt_rl,
        auto_enrt_mthd_rl,
	dpnt_dsgn_no_ctfn_rqd_flag,
        rt_end_dt_cd,
        rt_end_dt_rl,
        rt_strt_dt_cd,
        rt_strt_dt_rl,
        enrt_cvg_strt_dt_cd,
        enrt_cvg_strt_dt_rl,
	dpnt_cvg_strt_dt_cd,
	dpnt_cvg_strt_dt_rl,
	dpnt_cvg_end_dt_rl,
	dpnt_cvg_end_dt_cd,
	trk_inelig_per_flag,
	business_group_id,
        per_cvrd_cd,
        vrfy_fmly_mmbr_rl,
        vrfy_fmly_mmbr_cd,
        short_name, /*FHR*/
        short_code, /*FHR*/
                legislation_code, /*FHR*/
                legislation_subgroup, /*FHR*/
        Dflt_pgm_flag,
        Use_prog_points_flag,
        Dflt_step_cd,
        Dflt_step_rl,
        Update_salary_cd,
        Use_multi_pay_rates_flag,
        dflt_element_type_id,
        Dflt_input_value_id,
        Use_scores_cd,
        Scores_calc_mthd_cd,
        Scores_calc_rl,
        gsp_allow_override_flag,
        use_variable_rates_flag,
        salary_calc_mthd_cd,
        salary_calc_mthd_rl,
        susp_if_dpnt_ssn_nt_prv_cd,
        susp_if_dpnt_dob_nt_prv_cd,
        susp_if_dpnt_adr_nt_prv_cd,
        susp_if_ctfn_not_dpnt_flag,
        dpnt_ctfn_determine_cd,
        pgm_attribute_category,
	pgm_attribute1,
	pgm_attribute2,
	pgm_attribute3,
	pgm_attribute4,
	pgm_attribute5,
	pgm_attribute6,
	pgm_attribute7,
	pgm_attribute8,
	pgm_attribute9,
	pgm_attribute10,
	pgm_attribute11,
	pgm_attribute12,
	pgm_attribute13,
	pgm_attribute14,
	pgm_attribute15,
	pgm_attribute16,
	pgm_attribute17,
	pgm_attribute18,
	pgm_attribute19,
	pgm_attribute20,
	pgm_attribute21,
	pgm_attribute22,
	pgm_attribute23,
	pgm_attribute24,
	pgm_attribute25,
	pgm_attribute26,
	pgm_attribute27,
	pgm_attribute28,
	pgm_attribute29,
	pgm_attribute30,
	object_version_number
    from	ben_pgm_f
    where	pgm_id = p_pgm_id
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
      p_pgm_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_pgm_id = g_old_rec.pgm_id and
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
  l_parent_key_value1	number;
  l_parent_key_value2	number;
  l_parent_key_value3	number;
  l_parent_key_value4	number;
  l_parent_key_value5	number;
  l_parent_key_value6	number;
  --
  Cursor C_Sel1 Is
    select  t.dpnt_cvg_strt_dt_rl,
	    t.dpnt_cvg_end_dt_rl,
            t.enrt_cvg_end_dt_rl,
            t.enrt_cvg_strt_dt_rl,
            t.rt_end_dt_rl,
            t.rt_strt_dt_rl
    from    ben_pgm_f t
    where   t.pgm_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1,
		    l_parent_key_value2,
		    l_parent_key_value3,
		    l_parent_key_value4,
		    l_parent_key_value5,
		    l_parent_key_value6;
  If C_Sel1%notfound then
    Close C_Sel1;
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_pgm_f',
	 p_base_key_column	=> 'pgm_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ff_formulas_f',
	 p_parent_key_column1	=> 'formula_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_parent_table_name2	=> 'ff_formulas_f',
	 p_parent_key_column2	=> 'formula_id',
	 p_parent_key_value2	=> l_parent_key_value2,
	 p_parent_table_name3	=> 'ff_formulas_f',
	 p_parent_key_column3	=> 'formula_id',
	 p_parent_key_value3	=> l_parent_key_value3,
	 p_parent_table_name4	=> 'ff_formulas_f',
	 p_parent_key_column4	=> 'formula_id',
	 p_parent_key_value4	=> l_parent_key_value4,
	 p_parent_table_name5	=> 'ff_formulas_f',
	 p_parent_key_column5	=> 'formula_id',
	 p_parent_key_value5	=> l_parent_key_value5,
	 p_parent_table_name6	=> 'ff_formulas_f',
	 p_parent_key_column6	=> 'formula_id',
	 p_parent_key_value6	=> l_parent_key_value6,
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
	 p_base_table_name	=> 'ben_pgm_f',
	 p_base_key_column	=> 'pgm_id',
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
	(p_base_table_name	=> 'ben_pgm_f',
	 p_base_key_column	=> 'pgm_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_pgm_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.pgm_id	  = p_base_key_value
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
	 p_pgm_id	 in  number,
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
	pgm_id,
	effective_start_date,
	effective_end_date,
	name,
	dpnt_adrs_rqd_flag,
	pgm_prvds_no_auto_enrt_flag,
	dpnt_dob_rqd_flag,
	pgm_prvds_no_dflt_enrt_flag,
	dpnt_legv_id_rqd_flag,
	dpnt_dsgn_lvl_cd,
	pgm_stat_cd,
	ivr_ident,
	pgm_typ_cd,
	elig_apls_flag,
	uses_all_asmts_for_rts_flag,
	url_ref_name,
	pgm_desc,
	prtn_elig_ovrid_alwd_flag,
	pgm_use_all_asnts_elig_flag,
	dpnt_dsgn_cd,
	mx_dpnt_pct_prtt_lf_amt,
	mx_sps_pct_prtt_lf_amt,
	acty_ref_perd_cd,
	coord_cvg_for_all_pls_flg,
        enrt_cvg_end_dt_cd,
        enrt_cvg_end_dt_rl,
	dpnt_cvg_end_dt_cd,
	dpnt_cvg_end_dt_rl,
	dpnt_cvg_strt_dt_cd,
	dpnt_cvg_strt_dt_rl,
	dpnt_dsgn_no_ctfn_rqd_flag,
	drvbl_fctr_dpnt_elig_flag,
	drvbl_fctr_prtn_elig_flag,
        enrt_cvg_strt_dt_cd,
        enrt_cvg_strt_dt_rl,
	enrt_info_rt_freq_cd,
        rt_strt_dt_cd,
        rt_strt_dt_rl,
        rt_end_dt_cd,
        rt_end_dt_rl,
	pgm_grp_cd,
	pgm_uom,
	drvbl_fctr_apls_rts_flag,
        alws_unrstrctd_enrt_flag,
        enrt_cd,
        enrt_mthd_cd,
        poe_lvl_cd,
        enrt_rl,
        auto_enrt_mthd_rl,
	trk_inelig_per_flag,
	business_group_id,
        per_cvrd_cd,
        vrfy_fmly_mmbr_rl,
        vrfy_fmly_mmbr_cd,
        short_name, /*FHR*/
        short_code, /*FHR*/
                legislation_code, /*FHR*/
                legislation_subgroup, /*FHR*/
        Dflt_pgm_flag,
        Use_prog_points_flag,
        Dflt_step_cd,
        Dflt_step_rl,
        Update_salary_cd,
        Use_multi_pay_rates_flag,
        dflt_element_type_id,
        Dflt_input_value_id,
        Use_scores_cd,
        Scores_calc_mthd_cd,
        Scores_calc_rl,
	gsp_allow_override_flag,
	use_variable_rates_flag,
	salary_calc_mthd_cd,
	salary_calc_mthd_rl,
        susp_if_dpnt_ssn_nt_prv_cd,
        susp_if_dpnt_dob_nt_prv_cd,
        susp_if_dpnt_adr_nt_prv_cd,
        susp_if_ctfn_not_dpnt_flag,
        dpnt_ctfn_determine_cd,
	pgm_attribute_category,
	pgm_attribute1,
	pgm_attribute2,
	pgm_attribute3,
	pgm_attribute4,
	pgm_attribute5,
	pgm_attribute6,
	pgm_attribute7,
	pgm_attribute8,
	pgm_attribute9,
	pgm_attribute10,
	pgm_attribute11,
	pgm_attribute12,
	pgm_attribute13,
	pgm_attribute14,
	pgm_attribute15,
	pgm_attribute16,
	pgm_attribute17,
	pgm_attribute18,
	pgm_attribute19,
	pgm_attribute20,
	pgm_attribute21,
	pgm_attribute22,
	pgm_attribute23,
	pgm_attribute24,
	pgm_attribute25,
	pgm_attribute26,
	pgm_attribute27,
	pgm_attribute28,
	pgm_attribute29,
	pgm_attribute30,
	object_version_number
    from    ben_pgm_f
    where   pgm_id         = p_pgm_id
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
                             p_argument       => 'pgm_id',
                             p_argument_value => p_pgm_id);
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
	 p_base_table_name	   => 'ben_pgm_f',
	 p_base_key_column	   => 'pgm_id',
	 p_base_key_value 	   => p_pgm_id,
	 p_parent_table_name1      => 'ff_formulas_f',
	 p_parent_key_column1      => 'formula_id',
	 p_parent_key_value1       => g_old_rec.dpnt_cvg_strt_dt_rl,
	 p_parent_table_name2      => 'ff_formulas_f',
	 p_parent_key_column2      => 'formula_id',
	 p_parent_key_value2       => g_old_rec.dpnt_cvg_end_dt_rl,
	 p_parent_table_name3      => 'ff_formulas_f',
	 p_parent_key_column3      => 'formula_id',
	 p_parent_key_value3       => g_old_rec.enrt_cvg_end_dt_rl,
	 p_parent_table_name4      => 'ff_formulas_f',
	 p_parent_key_column4      => 'formula_id',
	 p_parent_key_value4       => g_old_rec.enrt_cvg_strt_dt_rl,
	 p_parent_table_name5      => 'ff_formulas_f',
	 p_parent_key_column5      => 'formula_id',
	 p_parent_key_value5       => g_old_rec.rt_strt_dt_rl,
	 p_parent_table_name6      => 'ff_formulas_f',
	 p_parent_key_column6      => 'formula_id',
	 p_parent_key_value6       => g_old_rec.rt_end_dt_rl,
	 p_child_table_name1       => 'ben_ptip_f',
	 p_child_key_column1       => 'ptip_id',
	 p_child_table_name2       => 'ben_popl_enrt_typ_cycl_f',
	 p_child_key_column2       => 'popl_enrt_typ_cycl_id',
	 p_child_table_name3       => 'ben_plip_f',
	 p_child_key_column3       => 'plip_id',
	 p_child_table_name4       => 'ben_prtn_elig_f',
	 p_child_key_column4       => 'prtn_elig_id',
	 p_child_table_name5       => 'ben_elig_to_prte_rsn_f',
	 p_child_key_column5       => 'elig_to_prte_rsn_id',
	 p_child_table_name6       => 'ben_ler_chg_dpnt_cvg_f',
	 p_child_key_column6       => 'ler_chg_dpnt_cvg_id',
	 p_child_table_name7       => 'ben_popl_org_f',
	 p_child_key_column7       => 'popl_org_id',
	 p_child_table_name8       => 'ben_elig_per_f',
	 p_child_key_column8       => 'elig_per_id',
	 p_child_table_name9       => 'ben_acty_base_rt_f',
	 p_child_key_column9       => 'acty_base_rt_id',
	 p_child_table_name10       => 'ben_pgm_dpnt_cvg_ctfn_f',
	 p_child_key_column10       => 'pgm_dpnt_cvg_ctfn_id',
--	 p_child_table_name10       => 'ben_elig_cvrd_dpnt_f',
--	 p_child_key_column10       => 'elig_cvrd_dpnt_id',
--         p_enforce_foreign_locking => true,  Bug 3198808
         p_enforce_foreign_locking => false,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);

 -- call again because DT_API.VALIDATE_DT_MODE can only
 -- accept a max of 10 parent or child tables
dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_pgm_f',
	 p_base_key_column	   => 'pgm_id',
	 p_base_key_value 	   => p_pgm_id,
	 p_child_table_name1       => 'ben_apld_dpnt_cvg_elig_prfl_f',
	 p_child_key_column1       => 'apld_dpnt_cvg_elig_prfl_id',
	 p_child_table_name2       => 'ben_popl_rptg_grp_f',
	 p_child_key_column2       => 'popl_rptg_grp_id',
	 p_child_table_name3       => 'ben_bnft_prvdr_pool_f',
	 p_child_key_column3       => 'bnft_prvdr_pool_id',
	 p_child_table_name4       => 'ben_drvbl_fctr_uom',
	 p_child_key_column4       => 'drvbl_fctr_uom_id',
         p_child_table_name5       => 'ben_elig_cbr_quald_bnf_f',
         p_child_key_column5       => 'elig_cbr_quald_bnf_id',
	 --p_child_table_name5       => 'ben_elig_per_elctbl_chc',
	 --p_child_key_column5       => 'elig_per_elctbl_chc_id',
	 --p_child_table_name6       => 'ben_popl_yr_perd',
	 --p_child_key_column6       => 'popl_yr_perd_id',
	 --p_child_table_name5       => 'ben_ler_chg_pgm_enrt_f',
	 --p_child_key_column5       => 'ler_chg_pgm_enrt_id',
--         p_enforce_foreign_locking => true,  Bug 3198808
         p_enforce_foreign_locking => false,
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
    fnd_message.set_token('TABLE_NAME', 'ben_pgm_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_pgm_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
        p_pgm_id                        in number,
        p_effective_start_date          in date,
        p_effective_end_date            in date,
        p_name                          in varchar2,
        p_dpnt_adrs_rqd_flag            in varchar2,
        p_pgm_prvds_no_auto_enrt_flag   in varchar2,
        p_dpnt_dob_rqd_flag             in varchar2,
        p_pgm_prvds_no_dflt_enrt_flag   in varchar2,
        p_dpnt_legv_id_rqd_flag         in varchar2,
        p_dpnt_dsgn_lvl_cd              in varchar2,
        p_pgm_stat_cd                   in varchar2,
        p_ivr_ident                     in varchar2,
        p_pgm_typ_cd                    in varchar2,
        p_elig_apls_flag                in varchar2,
        p_uses_all_asmts_for_rts_flag   in varchar2,
        p_url_ref_name                  in varchar2,
        p_pgm_desc                      in varchar2,
        p_prtn_elig_ovrid_alwd_flag     in varchar2,
        p_pgm_use_all_asnts_elig_flag   in varchar2,
        p_dpnt_dsgn_cd                  in varchar2,
        p_mx_dpnt_pct_prtt_lf_amt       in number,
        p_mx_sps_pct_prtt_lf_amt        in number,
        p_acty_ref_perd_cd              in varchar2,
        p_coord_cvg_for_all_pls_flg     in varchar2,
        p_enrt_cvg_end_dt_cd            in varchar2,
        p_enrt_cvg_end_dt_rl            in number,
        p_dpnt_cvg_end_dt_cd            in varchar2,
        p_dpnt_cvg_end_dt_rl            in number,
        p_dpnt_cvg_strt_dt_cd           in varchar2,
        p_dpnt_cvg_strt_dt_rl           in number,
        p_dpnt_dsgn_no_ctfn_rqd_flag    in varchar2,
        p_drvbl_fctr_dpnt_elig_flag     in varchar2,
        p_drvbl_fctr_prtn_elig_flag     in varchar2,
        p_enrt_cvg_strt_dt_cd           in varchar2,
        p_enrt_cvg_strt_dt_rl           in number,
        p_enrt_info_rt_freq_cd          in varchar2,
        p_rt_strt_dt_cd                 in varchar2,
        p_rt_strt_dt_rl                 in number,
        p_rt_end_dt_cd                  in varchar2,
        p_rt_end_dt_rl                  in number,
        p_pgm_grp_cd                    in varchar2,
        p_pgm_uom                       in varchar2,
        p_drvbl_fctr_apls_rts_flag      in varchar2,
        p_alws_unrstrctd_enrt_flag      in varchar2,
        p_enrt_cd                       in varchar2,
        p_enrt_mthd_cd                  in varchar2,
        p_poe_lvl_cd                    in varchar2,
        p_enrt_rl                       in number,
        p_auto_enrt_mthd_rl             in number,
        p_trk_inelig_per_flag           in varchar2,
        p_business_group_id             in number,
        p_per_cvrd_cd                   in varchar2,
        P_vrfy_fmly_mmbr_rl             in number,
        P_vrfy_fmly_mmbr_cd             in varchar2,
        p_short_name			in varchar2,  --FHR
        p_short_code			in varchar2,  --FHR
                p_legislation_code			in varchar2,
                p_legislation_subgroup			in varchar2,
        p_Dflt_pgm_flag                  in  Varchar2,
        p_Use_prog_points_flag           in  Varchar2,
        p_Dflt_step_cd                   in  Varchar2,
        p_Dflt_step_rl                   in  number,
        p_Update_salary_cd               in  Varchar2,
        p_Use_multi_pay_rates_flag       in  Varchar2,
        p_dflt_element_type_id           in  number,
        p_Dflt_input_value_id            in  number,
        p_Use_scores_cd                  in  Varchar2,
        p_Scores_calc_mthd_cd            in  Varchar2,
        p_Scores_calc_rl                 in  number,
        p_gsp_allow_override_flag        in varchar2,
        p_use_variable_rates_flag        in varchar2,
        p_salary_calc_mthd_cd        in varchar2,
        p_salary_calc_mthd_rl        in number,
        p_susp_if_dpnt_ssn_nt_prv_cd    in  varchar2  ,
        p_susp_if_dpnt_dob_nt_prv_cd    in  varchar2  ,
        p_susp_if_dpnt_adr_nt_prv_cd    in  varchar2  ,
        p_susp_if_ctfn_not_dpnt_flag    in  varchar2  ,
        p_dpnt_ctfn_determine_cd        in  varchar2  ,
        p_pgm_attribute_category        in varchar2,
        p_pgm_attribute1                in varchar2,
        p_pgm_attribute2                in varchar2,
        p_pgm_attribute3                in varchar2,
        p_pgm_attribute4                in varchar2,
        p_pgm_attribute5                in varchar2,
        p_pgm_attribute6                in varchar2,
        p_pgm_attribute7                in varchar2,
        p_pgm_attribute8                in varchar2,
        p_pgm_attribute9                in varchar2,
        p_pgm_attribute10               in varchar2,
        p_pgm_attribute11               in varchar2,
        p_pgm_attribute12               in varchar2,
        p_pgm_attribute13               in varchar2,
        p_pgm_attribute14               in varchar2,
        p_pgm_attribute15               in varchar2,
        p_pgm_attribute16               in varchar2,
        p_pgm_attribute17               in varchar2,
        p_pgm_attribute18               in varchar2,
        p_pgm_attribute19               in varchar2,
        p_pgm_attribute20               in varchar2,
        p_pgm_attribute21               in varchar2,
        p_pgm_attribute22               in varchar2,
        p_pgm_attribute23               in varchar2,
        p_pgm_attribute24               in varchar2,
        p_pgm_attribute25               in varchar2,
        p_pgm_attribute26               in varchar2,
        p_pgm_attribute27               in varchar2,
        p_pgm_attribute28               in varchar2,
        p_pgm_attribute29               in varchar2,
        p_pgm_attribute30               in varchar2,
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
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.name                             := p_name;
  l_rec.dpnt_adrs_rqd_flag               := p_dpnt_adrs_rqd_flag;
  l_rec.pgm_prvds_no_auto_enrt_flag      := p_pgm_prvds_no_auto_enrt_flag;
  l_rec.dpnt_dob_rqd_flag                := p_dpnt_dob_rqd_flag;
  l_rec.pgm_prvds_no_dflt_enrt_flag      := p_pgm_prvds_no_dflt_enrt_flag;
  l_rec.dpnt_dsgn_lvl_cd                 := p_dpnt_dsgn_lvl_cd;
  l_rec.dpnt_legv_id_rqd_flag            := p_dpnt_legv_id_rqd_flag;
  l_rec.pgm_stat_cd                      := p_pgm_stat_cd;
  l_rec.ivr_ident                        := p_ivr_ident;
  l_rec.pgm_typ_cd                       := p_pgm_typ_cd;
  l_rec.elig_apls_flag                   := p_elig_apls_flag;
  l_rec.uses_all_asmts_for_rts_flag      := p_uses_all_asmts_for_rts_flag;
  l_rec.url_ref_name                     := p_url_ref_name;
  l_rec.pgm_desc                         := p_pgm_desc;
  l_rec.prtn_elig_ovrid_alwd_flag        := p_prtn_elig_ovrid_alwd_flag;
  l_rec.pgm_use_all_asnts_elig_flag      := p_pgm_use_all_asnts_elig_flag;
  l_rec.dpnt_dsgn_cd                     := p_dpnt_dsgn_cd;
  l_rec.mx_dpnt_pct_prtt_lf_amt          := p_mx_dpnt_pct_prtt_lf_amt;
  l_rec.mx_sps_pct_prtt_lf_amt           := p_mx_sps_pct_prtt_lf_amt;
  l_rec.coord_cvg_for_all_pls_flg        := p_coord_cvg_for_all_pls_flg;
  l_rec.enrt_cvg_end_dt_cd               := p_enrt_cvg_end_dt_cd;
  l_rec.enrt_cvg_end_dt_rl               := p_enrt_cvg_end_dt_rl;
  l_rec.pgm_grp_cd                       := p_pgm_grp_cd;
  l_rec.acty_ref_perd_cd                 := p_acty_ref_perd_cd;
  l_rec.drvbl_fctr_dpnt_elig_flag        := p_drvbl_fctr_dpnt_elig_flag;
  l_rec.pgm_uom                          := p_pgm_uom;
  l_rec.enrt_info_rt_freq_cd             := p_enrt_info_rt_freq_cd;
  l_rec.drvbl_fctr_prtn_elig_flag        := p_drvbl_fctr_prtn_elig_flag;
  l_rec.drvbl_fctr_apls_rts_flag         := p_drvbl_fctr_apls_rts_flag;
  l_rec.alws_unrstrctd_enrt_flag         := p_alws_unrstrctd_enrt_flag;
  l_rec.enrt_cd                          := p_enrt_cd;
  l_rec.enrt_mthd_cd                     := p_enrt_mthd_cd;
  l_rec.poe_lvl_cd                       := p_poe_lvl_cd;
  l_rec.enrt_rl                          := p_enrt_rl;
  l_rec.auto_enrt_mthd_rl                := p_auto_enrt_mthd_rl;
  l_rec.dpnt_dsgn_no_ctfn_rqd_flag       := p_dpnt_dsgn_no_ctfn_rqd_flag;
  l_rec.rt_end_dt_cd                     := p_rt_end_dt_cd;
  l_rec.rt_end_dt_rl                     := p_rt_end_dt_rl;
  l_rec.rt_strt_dt_cd                    := p_rt_strt_dt_cd;
  l_rec.rt_strt_dt_rl                    := p_rt_strt_dt_rl;
  l_rec.enrt_cvg_strt_dt_cd              := p_enrt_cvg_strt_dt_cd;
  l_rec.enrt_cvg_strt_dt_rl              := p_enrt_cvg_strt_dt_rl;
  l_rec.dpnt_cvg_strt_dt_cd              := p_dpnt_cvg_strt_dt_cd;
  l_rec.dpnt_cvg_strt_dt_rl              := p_dpnt_cvg_strt_dt_rl;
  l_rec.dpnt_cvg_end_dt_rl               := p_dpnt_cvg_end_dt_rl;
  l_rec.dpnt_cvg_end_dt_cd               := p_dpnt_cvg_end_dt_cd;
  l_rec.trk_inelig_per_flag              := p_trk_inelig_per_flag;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.per_cvrd_cd                      := p_per_cvrd_cd ;
  l_rec.vrfy_fmly_mmbr_rl                := P_vrfy_fmly_mmbr_rl ;
  l_rec.vrfy_fmly_mmbr_cd                := P_vrfy_fmly_mmbr_cd ;
  l_rec.short_name  			 := p_short_name;		--FHR
  l_rec.short_code  			 := p_short_code;		--FHR
    l_rec.legislation_code  			 := p_legislation_code;
    l_rec.legislation_subgroup  			 := p_legislation_subgroup;
  l_rec.Dflt_pgm_flag                    := p_Dflt_pgm_flag ;
  l_rec.Use_prog_points_flag             := p_Use_prog_points_flag ;
  l_rec.Dflt_step_cd                     := p_Dflt_step_cd ;
  l_rec.Dflt_step_rl                     := p_Dflt_step_rl ;
  l_rec.Update_salary_cd                 := p_Update_salary_cd ;
  l_rec.Use_multi_pay_rates_flag          := p_Use_multi_pay_rates_flag ;
  l_rec.dflt_element_type_id             := p_dflt_element_type_id ;
  l_rec.Dflt_input_value_id              := p_Dflt_input_value_id ;
  l_rec.Use_scores_cd                    := p_Use_scores_cd ;
  l_rec.Scores_calc_mthd_cd              := p_Scores_calc_mthd_cd ;
  l_rec.Scores_calc_rl                   := p_Scores_calc_rl ;
  l_rec.gsp_allow_override_flag           := p_gsp_allow_override_flag;
  l_rec.use_variable_rates_flag           := p_use_variable_rates_flag;
  l_rec.salary_calc_mthd_cd           := p_salary_calc_mthd_cd;
  l_rec.salary_calc_mthd_rl           := p_salary_calc_mthd_rl;
  l_rec.susp_if_dpnt_ssn_nt_prv_cd     :=  p_susp_if_dpnt_ssn_nt_prv_cd;
  l_rec.susp_if_dpnt_dob_nt_prv_cd     :=  p_susp_if_dpnt_dob_nt_prv_cd;
  l_rec.susp_if_dpnt_adr_nt_prv_cd     :=  p_susp_if_dpnt_adr_nt_prv_cd;
  l_rec.susp_if_ctfn_not_dpnt_flag     :=  p_susp_if_ctfn_not_dpnt_flag;
  l_rec.dpnt_ctfn_determine_cd         :=  p_dpnt_ctfn_determine_cd;
  l_rec.pgm_attribute_category           := p_pgm_attribute_category;
  l_rec.pgm_attribute1                   := p_pgm_attribute1;
  l_rec.pgm_attribute2                   := p_pgm_attribute2;
  l_rec.pgm_attribute3                   := p_pgm_attribute3;
  l_rec.pgm_attribute4                   := p_pgm_attribute4;
  l_rec.pgm_attribute5                   := p_pgm_attribute5;
  l_rec.pgm_attribute6                   := p_pgm_attribute6;
  l_rec.pgm_attribute7                   := p_pgm_attribute7;
  l_rec.pgm_attribute8                   := p_pgm_attribute8;
  l_rec.pgm_attribute9                   := p_pgm_attribute9;
  l_rec.pgm_attribute10                  := p_pgm_attribute10;
  l_rec.pgm_attribute11                  := p_pgm_attribute11;
  l_rec.pgm_attribute12                  := p_pgm_attribute12;
  l_rec.pgm_attribute13                  := p_pgm_attribute13;
  l_rec.pgm_attribute14                  := p_pgm_attribute14;
  l_rec.pgm_attribute15                  := p_pgm_attribute15;
  l_rec.pgm_attribute16                  := p_pgm_attribute16;
  l_rec.pgm_attribute17                  := p_pgm_attribute17;
  l_rec.pgm_attribute18                  := p_pgm_attribute18;
  l_rec.pgm_attribute19                  := p_pgm_attribute19;
  l_rec.pgm_attribute20                  := p_pgm_attribute20;
  l_rec.pgm_attribute21                  := p_pgm_attribute21;
  l_rec.pgm_attribute22                  := p_pgm_attribute22;
  l_rec.pgm_attribute23                  := p_pgm_attribute23;
  l_rec.pgm_attribute24                  := p_pgm_attribute24;
  l_rec.pgm_attribute25                  := p_pgm_attribute25;
  l_rec.pgm_attribute26                  := p_pgm_attribute26;
  l_rec.pgm_attribute27                  := p_pgm_attribute27;
  l_rec.pgm_attribute28                  := p_pgm_attribute28;
  l_rec.pgm_attribute29                  := p_pgm_attribute29;
  l_rec.pgm_attribute30                  := p_pgm_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_pgm_shd;

/
