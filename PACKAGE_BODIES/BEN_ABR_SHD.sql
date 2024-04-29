--------------------------------------------------------
--  DDL for Package Body BEN_ABR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ABR_SHD" as
/* $Header: beabrrhi.pkb 120.18 2008/05/15 10:36:51 krupani ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_abr_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_ACTY_BASE_RT_FK4') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ACTY_BASE_RT_F_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ENRT_RT_DT1') Then
    ben_utility.child_exists_error(p_table_name =>
                                   'BEN_ENRT_RT');
  ElsIf (p_constraint_name = 'BEN_PRTT_RT_VAL_DT5') Then
    ben_utility.child_exists_error(p_table_name =>
                                   'BEN_PRTT_RT_VAL');

  ElsIf (p_constraint_name = 'BEN_OIPL_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_OIPLIP_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;


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
   p_acty_base_rt_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	acty_base_rt_id,
	effective_start_date,
	effective_end_date,
	ordr_num,
	acty_typ_cd,
	sub_acty_typ_cd,
        name,
	rt_typ_cd,
        bnft_rt_typ_cd,
	tx_typ_cd,
	use_to_calc_net_flx_cr_flag,
	asn_on_enrt_flag,
	abv_mx_elcn_val_alwd_flag,
	blw_mn_elcn_alwd_flag,
        dsply_on_enrt_flag,
	parnt_chld_cd,
	use_calc_acty_bs_rt_flag,
	uses_ded_sched_flag,
	uses_varbl_rt_flag,
	vstg_sched_apls_flag,
	rt_mlt_cd,
	proc_each_pp_dflt_flag,
	prdct_flx_cr_when_elig_flag,
	no_std_rt_used_flag,
	rcrrg_cd,
	mn_elcn_val,
	mx_elcn_val,
        lwr_lmt_val,
        lwr_lmt_calc_rl,
        upr_lmt_val,
        upr_lmt_calc_rl,
        ptd_comp_lvl_fctr_id,
        clm_comp_lvl_fctr_id,
        entr_ann_val_flag,
        ann_mn_elcn_val,
        ann_mx_elcn_val,
        wsh_rl_dy_mo_num,
	uses_pymt_sched_flag,
	nnmntry_uom,
	val,
	incrmt_elcn_val,
	rndg_cd,
	val_ovrid_alwd_flag,
	prtl_mo_det_mthd_cd,
	acty_base_rt_stat_cd,
	procg_src_cd,
	dflt_val,
        dflt_flag,
	frgn_erg_ded_typ_cd,
	frgn_erg_ded_name,
	frgn_erg_ded_ident,
	no_mx_elcn_val_dfnd_flag,
	prtl_mo_det_mthd_rl,
	entr_val_at_enrt_flag,
	prtl_mo_eff_dt_det_rl,
	rndg_rl,
	val_calc_rl,
	no_mn_elcn_val_dfnd_flag,
	prtl_mo_eff_dt_det_cd,
        only_one_bal_typ_alwd_flag,
        rt_usg_cd,
        prort_mn_ann_elcn_val_cd,
        prort_mn_ann_elcn_val_rl,
        prort_mx_ann_elcn_val_cd,
        prort_mx_ann_elcn_val_rl,
        one_ann_pymt_cd,
        det_pl_ytd_cntrs_cd,
        asmt_to_use_cd,
        ele_rqd_flag,
        subj_to_imptd_incm_flag,
	element_type_id,
	input_value_id,
	input_va_calc_rl,
        comp_lvl_fctr_id,
        parnt_acty_base_rt_id,
	pgm_id,
	pl_id,
	oipl_id,
        opt_id,
        oiplip_id,
	plip_id,
	ptip_id,
	cmbn_plip_id,
	cmbn_ptip_id,
	cmbn_ptip_opt_id,
	vstg_for_acty_rt_id,
        actl_prem_id,
        ALWS_CHG_CD ,
        ele_entry_val_cd ,
        TTL_COMP_LVL_FCTR_ID ,
        COST_ALLOCATION_KEYFLEX_ID,
        pay_rate_grade_rule_id ,
        rate_periodization_cd,
        rate_periodization_rl,
	mn_mx_elcn_rl,
	mapping_table_name,
        mapping_table_pk_id,
	business_group_id,
        context_pgm_id,
        context_pl_id ,
        context_opt_id,
	element_det_rl,
        currency_det_cd ,
	abr_attribute_category,
	abr_attribute1,
	abr_attribute2,
	abr_attribute3,
	abr_attribute4,
	abr_attribute5,
	abr_attribute6,
	abr_attribute7,
	abr_attribute8,
	abr_attribute9,
	abr_attribute10,
	abr_attribute11,
	abr_attribute12,
	abr_attribute13,
	abr_attribute14,
	abr_attribute15,
	abr_attribute16,
	abr_attribute17,
	abr_attribute18,
	abr_attribute19,
	abr_attribute20,
	abr_attribute21,
	abr_attribute22,
	abr_attribute23,
	abr_attribute24,
	abr_attribute25,
	abr_attribute26,
	abr_attribute27,
	abr_attribute28,
	abr_attribute29,
	abr_attribute30,
	abr_seq_num,
	object_version_number
    from	ben_acty_base_rt_f
    where	acty_base_rt_id = p_acty_base_rt_id
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
      p_acty_base_rt_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_acty_base_rt_id = g_old_rec.acty_base_rt_id and
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
  l_parent_key_value7	number;
  l_parent_key_value8	number;
  l_parent_key_value9	number;
  l_parent_key_value10	number;
  l_parent_key_value11	number;
  l_parent_key_value12	number;
  l_parent_key_value13  number;
  l_parent_key_value14  number;
  l_parent_key_value15  number;
  l_parent_key_value16  number;
  --
  l_zap                 boolean;
  l_zap1                boolean;
  l_delete              boolean;
  l_delete1             boolean;
  l_future_change       boolean;
  l_future_change1      boolean;
  l_delete_next_change  boolean;
  l_delete_next_change1 boolean;
  --
  Cursor C_Sel1 Is
    select  t.prtl_mo_det_mthd_rl,
	    t.prtl_mo_eff_dt_det_rl,
	    t.rndg_rl,
	    t.val_calc_rl,
	    t.vstg_for_acty_rt_id,
	    t.pgm_id,
	    t.ptip_id,
	    t.oipl_id,
	    t.plip_id,
	    t.pl_id,
            t.parnt_acty_base_rt_id,
            t.lwr_lmt_calc_rl,
            t.upr_lmt_calc_rl,
            t.oiplip_id,
            t.actl_prem_id,
            t.opt_id
    from    ben_acty_base_rt_f t
    where   t.acty_base_rt_id = p_base_key_value
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
		    l_parent_key_value6,
		    l_parent_key_value7,
		    l_parent_key_value8,
		    l_parent_key_value9,
		    l_parent_key_value10,
                    l_parent_key_value11,
                    l_parent_key_value12,
                    l_parent_key_value13,
                    l_parent_key_value14,
                    l_parent_key_value15,
                    l_parent_key_value16;
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
	 p_base_table_name	=> 'ben_acty_base_rt_f',
	 p_base_key_column	=> 'acty_base_rt_id',
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
	 p_parent_table_name5	=> 'ben_vstg_for_acty_rt_f',
	 p_parent_key_column5	=> 'vstg_for_acty_rt_id',
	 p_parent_key_value5	=> l_parent_key_value5,
	 p_parent_table_name6	=> 'ben_pgm_f',
	 p_parent_key_column6	=> 'pgm_id',
	 p_parent_key_value6	=> l_parent_key_value6,
	 p_parent_table_name7	=> 'ben_ptip_f',
	 p_parent_key_column7	=> 'ptip_id',
	 p_parent_key_value7	=> l_parent_key_value7,
	 p_parent_table_name8	=> 'ben_oipl_f',
	 p_parent_key_column8	=> 'oipl_id',
	 p_parent_key_value8	=> l_parent_key_value8,
	 p_parent_table_name9   => 'ben_plip_f',
	 p_parent_key_column9  	=> 'plip_id',
	 p_parent_key_value9    => l_parent_key_value9 ,
	 p_zap			=> l_zap,
	 p_delete		=> l_delete,
	 p_future_change	=> l_future_change,
	 p_delete_next_change	=> l_delete_next_change);
  --
    dt_api.find_dt_del_modes
	(p_effective_date       =>   p_effective_date,
	 p_base_table_name	=> 'ben_acty_base_rt_f',
	 p_base_key_column	=> 'acty_base_rt_id',
	 p_base_key_value       => p_base_key_value,
	 p_parent_table_name1	=> 'ben_pl_f',
	 p_parent_key_column1	=> 'pl_id',
	 p_parent_key_value1	=> l_parent_key_value10,
	 p_parent_table_name2	=> 'ben_acty_base_rt_f',
	 p_parent_key_column2	=> 'acty_base_rt_id',
	 p_parent_key_value2	=> l_parent_key_value11,
         p_parent_table_name3   => 'ff_formulas_f',
         p_parent_key_column3   => 'formula_id',
         p_parent_key_value3    => l_parent_key_value12,
         p_parent_table_name4   => 'ff_formulas_f',
         p_parent_key_column4   => 'formula_id',
         p_parent_key_value4    => l_parent_key_value13,
         p_parent_table_name5   => 'ben_oiplip_f',
         p_parent_key_column5   => 'oiplip_id',
         p_parent_key_value5    => l_parent_key_value14,
         p_parent_table_name6   => 'ben_actl_prem_f',
         p_parent_key_column6   => 'actl_prem_id',
         p_parent_key_value6    => l_parent_key_value15,
         p_parent_table_name7   => 'ben_opt_f',
         p_parent_key_column7   => 'opt_id',
         p_parent_key_value7    => l_parent_key_value16 ,
	 p_zap			=> l_zap1,
	 p_delete      	        => l_delete1,
	 p_future_change        => l_future_change1,
	 p_delete_next_change	=> l_delete_next_change1);
  --
 --
  if l_zap and l_zap1 then
    --
    p_zap := true;
    --
  else
    --
    p_zap := false;
    --
  end if;
  --
  if l_delete and l_delete1 then
    --
    p_delete := true;
    --
  else
    --
    p_delete := false;
    --
  end if;
  --
  if l_future_change and l_future_change1 then
    --
    p_future_change := true;
    --
  else
    --
    p_future_change := false;
    --
  end if;
  --
  if l_delete_next_change and l_delete_next_change1 then
    --
    p_delete_next_change := true;
    --
  else
    --
    p_delete_next_change := false;
    --
  end if;
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
	 p_base_table_name	=> 'ben_acty_base_rt_f',
	 p_base_key_column	=> 'acty_base_rt_id',
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
	(p_base_table_name	=> 'ben_acty_base_rt_f',
	 p_base_key_column	=> 'acty_base_rt_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_acty_base_rt_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.acty_base_rt_id	  = p_base_key_value
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
	 p_acty_base_rt_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
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
	acty_base_rt_id,
	effective_start_date,
	effective_end_date,
	ordr_num,
	acty_typ_cd,
	sub_acty_typ_cd,
        name,
	rt_typ_cd,
        bnft_rt_typ_cd,
	tx_typ_cd,
	use_to_calc_net_flx_cr_flag,
	asn_on_enrt_flag,
	abv_mx_elcn_val_alwd_flag,
	blw_mn_elcn_alwd_flag,
        dsply_on_enrt_flag,
	parnt_chld_cd,
	use_calc_acty_bs_rt_flag,
	uses_ded_sched_flag,
	uses_varbl_rt_flag,
	vstg_sched_apls_flag,
	rt_mlt_cd,
	proc_each_pp_dflt_flag,
	prdct_flx_cr_when_elig_flag,
	no_std_rt_used_flag,
	rcrrg_cd,
	mn_elcn_val,
	mx_elcn_val,
        lwr_lmt_val,
        lwr_lmt_calc_rl,
        upr_lmt_val,
        upr_lmt_calc_rl,
        ptd_comp_lvl_fctr_id,
        clm_comp_lvl_fctr_id,
        entr_ann_val_flag,
        ann_mn_elcn_val,
        ann_mx_elcn_val,
        wsh_rl_dy_mo_num,
	uses_pymt_sched_flag,
	nnmntry_uom,
	val,
	incrmt_elcn_val,
	rndg_cd,
	val_ovrid_alwd_flag,
	prtl_mo_det_mthd_cd,
	acty_base_rt_stat_cd,
	procg_src_cd,
	dflt_val,
        dflt_flag,
	frgn_erg_ded_typ_cd,
	frgn_erg_ded_name,
	frgn_erg_ded_ident,
	no_mx_elcn_val_dfnd_flag,
	prtl_mo_det_mthd_rl,
	entr_val_at_enrt_flag,
	prtl_mo_eff_dt_det_rl,
	rndg_rl,
	val_calc_rl,
	no_mn_elcn_val_dfnd_flag,
	prtl_mo_eff_dt_det_cd,
        only_one_bal_typ_alwd_flag,
        rt_usg_cd,
        prort_mn_ann_elcn_val_cd,
        prort_mn_ann_elcn_val_rl,
        prort_mx_ann_elcn_val_cd,
        prort_mx_ann_elcn_val_rl,
        one_ann_pymt_cd,
        det_pl_ytd_cntrs_cd,
        asmt_to_use_cd,
        ele_rqd_flag,
        subj_to_imptd_incm_flag,
	element_type_id,
	input_value_id,
	input_va_calc_rl,
        comp_lvl_fctr_id,
        parnt_acty_base_rt_id,
	pgm_id,
	pl_id,
	oipl_id,
        opt_id,
        oiplip_id,
	plip_id,
	ptip_id,
	cmbn_plip_id,
	cmbn_ptip_id,
	cmbn_ptip_opt_id,
	vstg_for_acty_rt_id,
        actl_prem_id,
        TTL_COMP_LVL_FCTR_ID ,
        COST_ALLOCATION_KEYFLEX_ID,
        ALWS_CHG_CD ,
        ele_entry_val_cd ,
        rate_periodization_cd,
        rate_periodization_rl,
        pay_rate_grade_rule_id ,
	mn_mx_elcn_rl,
	mapping_table_name,
	mapping_table_pk_id,
	business_group_id,
        context_pgm_id ,
        context_pl_id  ,
        context_opt_id ,
	element_det_rl,
        currency_det_cd,
	abr_attribute_category,
	abr_attribute1,
	abr_attribute2,
	abr_attribute3,
	abr_attribute4,
	abr_attribute5,
	abr_attribute6,
	abr_attribute7,
	abr_attribute8,
	abr_attribute9,
	abr_attribute10,
	abr_attribute11,
	abr_attribute12,
	abr_attribute13,
	abr_attribute14,
	abr_attribute15,
	abr_attribute16,
	abr_attribute17,
	abr_attribute18,
	abr_attribute19,
	abr_attribute20,
	abr_attribute21,
	abr_attribute22,
	abr_attribute23,
	abr_attribute24,
	abr_attribute25,
	abr_attribute26,
	abr_attribute27,
	abr_attribute28,
	abr_attribute29,
	abr_attribute30,
	abr_seq_num,
	object_version_number
    from    ben_acty_base_rt_f
    where   acty_base_rt_id         = p_acty_base_rt_id
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
                             p_argument       => 'acty_base_rt_id',
                             p_argument_value => p_acty_base_rt_id);
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
	 p_base_table_name	   => 'ben_acty_base_rt_f',
	 p_base_key_column	   => 'acty_base_rt_id',
	 p_base_key_value 	   => p_acty_base_rt_id,
	 p_parent_table_name1      => 'ff_formulas_f',
	 p_parent_key_column1      => 'formula_id',
	 p_parent_key_value1       => g_old_rec.prtl_mo_det_mthd_rl,
         p_parent_table_name2      => 'ff_formulas_f',
         p_parent_key_column2      => 'formula_id',
         p_parent_key_value2       => g_old_rec.prtl_mo_eff_dt_det_rl,
         p_parent_table_name3      => 'ff_formulas_f',
         p_parent_key_column3      => 'formula_id',
         p_parent_key_value3       => g_old_rec.rndg_rl,
         p_parent_table_name4      => 'ff_formulas_f',
         p_parent_key_column4      => 'formula_id',
         p_parent_key_value4       => g_old_rec.val_calc_rl,
         p_parent_table_name5      => 'ben_vstg_for_acty_rt_f',
         p_parent_key_column5      => 'vstg_for_acty_rt_id',
         p_parent_key_value5       => g_old_rec.vstg_for_acty_rt_id,
         p_parent_table_name6      => 'ben_pgm_f',
         p_parent_key_column6      => 'pgm_id',
         p_parent_key_value6       => g_old_rec.pgm_id,
         p_parent_table_name7      => 'ben_ptip_f',
         p_parent_key_column7      => 'ptip_id',
         p_parent_key_value7       => g_old_rec.ptip_id,
         p_parent_table_name8      => 'ben_oipl_f',
         p_parent_key_column8      => 'oipl_id',
         p_parent_key_value8       => g_old_rec.oipl_id,
         p_parent_table_name9      => 'ben_plip_f',
         p_parent_key_column9      => 'plip_id',
         p_parent_key_value9       => g_old_rec.plip_id,
         p_child_table_name1       => 'ben_acty_rt_ded_sched_f',
         p_child_key_column1       => 'acty_rt_ded_sched_id',
         p_child_table_name2       => 'ben_acty_rt_pymt_sched_f',
         p_child_key_column2       => 'acty_rt_pymt_sched_id',
         p_child_table_name3       => 'ben_vrbl_rt_rl_f',
         p_child_key_column3       => 'vrbl_rt_rl_id',
         p_child_table_name4       => 'ben_acty_vrbl_rt_f',
         p_child_key_column4       => 'acty_vrbl_rt_id',
         p_child_table_name5       => 'ben_comp_lvl_acty_rt_f',
         p_child_key_column5       => 'comp_lvl_acty_rt_id',
--         p_enforce_foreign_locking => true,  Bug 3198808
         p_enforce_foreign_locking => false,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
    --
     dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_acty_base_rt_f',
	 p_base_key_column	   => 'acty_base_rt_id',
	 p_base_key_value 	   => p_acty_base_rt_id,
	 p_parent_table_name1      => 'ben_cmbn_ptip_f',
	 p_parent_key_column1      => 'cmbn_ptip_id',
	 p_parent_key_value1       => g_old_rec.cmbn_ptip_id,
         p_parent_table_name2      => 'ben_pl_f',
         p_parent_key_column2      => 'pl_id',
         p_parent_key_value2       => g_old_rec.pl_id,
         p_parent_table_name3      => 'ben_cmbn_ptip_opt_f',
         p_parent_key_column3      => 'cmbn_ptip_opt_id',
         p_parent_key_value3       => g_old_rec.cmbn_ptip_opt_id,
         p_parent_table_name4      => 'ben_acty_base_rt_f',
         p_parent_key_column4      => 'acty_base_rt_id',
         p_parent_key_value4       => g_old_rec.parnt_acty_base_rt_id,
         p_parent_table_name5      => 'ff_formulas_f',
         p_parent_key_column5      => 'formula_id',
         p_parent_key_value5       => g_old_rec.lwr_lmt_calc_rl,
         p_parent_table_name6      => 'ff_formulas_f',
         p_parent_key_column6      => 'formula_id',
         p_parent_key_value6       => g_old_rec.upr_lmt_calc_rl,
	 p_parent_table_name7      => 'ben_cmbn_plip_f',
	 p_parent_key_column7      => 'cmbn_plip_id',
	 p_parent_key_value7       => g_old_rec.cmbn_plip_id,
         p_parent_table_name8      => 'ben_oiplip_f',
         p_parent_key_column8      => 'oiplip_id',
         p_parent_key_value8       => g_old_rec.oiplip_id,
         p_parent_table_name9      => 'ben_actl_prem_f',
         p_parent_key_column9      => 'actl_prem_id',
         p_parent_key_value9       => g_old_rec.actl_prem_id,
         p_parent_table_name10     => 'pay_grade_rules_f',
         p_parent_key_column10     => 'grade_rule_id',
         p_parent_key_value10      => g_old_rec.pay_rate_grade_rule_id,
--         p_enforce_foreign_locking => true,  Bug 3198808
         p_enforce_foreign_locking => false,
	 p_validation_start_date   => l_validation_start_date1,
 	 p_validation_end_date	   => l_validation_end_date1);
     --
     dt_api.validate_dt_mode
        (p_effective_date          => p_effective_date,
         p_datetrack_mode          => p_datetrack_mode,
         p_base_table_name         => 'ben_acty_base_rt_f',
         p_base_key_column         => 'acty_base_rt_id',
         p_base_key_value          => p_acty_base_rt_id,
         p_parent_table_name1      => 'ben_opt_f',
         p_parent_key_column1      => 'opt_id',
         p_parent_key_value1       => g_old_rec.opt_id,
--         p_enforce_foreign_locking => true,  Bug 3198808
         p_enforce_foreign_locking => false,
         p_validation_start_date   => l_validation_start_date1,
         p_validation_end_date     => l_validation_end_date1
        );
   --
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
  if l_validation_start_date > l_validation_start_date1 then
    --
    p_validation_start_date := l_validation_start_date;
  else
    --
    p_validation_start_date := l_validation_start_date1;
    --
  end if;
  --
  if l_validation_end_date > l_validation_end_date1 then
    --
    p_validation_end_date := l_validation_end_date;
  else
    --
    p_validation_end_date := l_validation_end_date1;
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ben_acty_base_rt_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_acty_base_rt_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
        p_acty_base_rt_id               in number,
        p_effective_start_date          in date,
        p_effective_end_date            in date,
        p_ordr_num			in number,
        p_acty_typ_cd                   in varchar2,
        p_sub_acty_typ_cd               in varchar2,
        p_name                          in varchar2,
        p_rt_typ_cd                     in varchar2,
        p_bnft_rt_typ_cd                in varchar2,
        p_tx_typ_cd                     in varchar2,
        p_use_to_calc_net_flx_cr_flag   in varchar2,
        p_asn_on_enrt_flag              in varchar2,
        p_abv_mx_elcn_val_alwd_flag     in varchar2,
        p_blw_mn_elcn_alwd_flag         in varchar2,
        p_dsply_on_enrt_flag            in varchar2,
        p_parnt_chld_cd                 in varchar2,
        p_use_calc_acty_bs_rt_flag      in varchar2,
        p_uses_ded_sched_flag           in varchar2,
        p_uses_varbl_rt_flag            in varchar2,
        p_vstg_sched_apls_flag          in varchar2,
        p_rt_mlt_cd                     in varchar2,
        p_proc_each_pp_dflt_flag        in varchar2,
        p_prdct_flx_cr_when_elig_flag   in varchar2,
        p_no_std_rt_used_flag           in varchar2,
        p_rcrrg_cd                      in varchar2,
        p_mn_elcn_val                   in number,
        p_mx_elcn_val                   in number,
        p_lwr_lmt_val                   in number,
        p_lwr_lmt_calc_rl               in number,
        p_upr_lmt_val                   in number,
        p_upr_lmt_calc_rl               in number,
        p_ptd_comp_lvl_fctr_id          in number,
        p_clm_comp_lvl_fctr_id          in number,
        p_entr_ann_val_flag             in varchar2,
        p_ann_mn_elcn_val               in number,
        p_ann_mx_elcn_val               in number,
        p_wsh_rl_dy_mo_num              in number,
        p_uses_pymt_sched_flag          in varchar2,
        p_nnmntry_uom                   in varchar2,
        p_val                           in number,
        p_incrmt_elcn_val               in number,
        p_rndg_cd                       in varchar2,
        p_val_ovrid_alwd_flag           in varchar2,
        p_prtl_mo_det_mthd_cd           in varchar2,
        p_acty_base_rt_stat_cd          in varchar2,
        p_procg_src_cd                  in varchar2,
        p_dflt_val                      in number,
        p_dflt_flag                     in varchar2,
        p_frgn_erg_ded_typ_cd           in varchar2,
        p_frgn_erg_ded_name             in varchar2,
        p_frgn_erg_ded_ident            in varchar2,
        p_no_mx_elcn_val_dfnd_flag      in varchar2,
        p_prtl_mo_det_mthd_rl           in number,
        p_entr_val_at_enrt_flag         in varchar2,
        p_prtl_mo_eff_dt_det_rl         in number,
        p_rndg_rl                       in number,
        p_val_calc_rl                   in number,
        p_no_mn_elcn_val_dfnd_flag      in varchar2,
        p_prtl_mo_eff_dt_det_cd         in varchar2,
        p_only_one_bal_typ_alwd_flag    in varchar2,
        p_rt_usg_cd                     in varchar2,
        p_prort_mn_ann_elcn_val_cd      in varchar2,
        p_prort_mn_ann_elcn_val_rl      in number,
        p_prort_mx_ann_elcn_val_cd      in varchar2,
        p_prort_mx_ann_elcn_val_rl      in number,
        p_one_ann_pymt_cd               in varchar2,
        p_det_pl_ytd_cntrs_cd           in varchar2,
        p_asmt_to_use_cd                in varchar2,
        p_ele_rqd_flag                  in varchar2,
        p_subj_to_imptd_incm_flag       in varchar2,
        p_element_type_id               in number,
        p_input_value_id                in number,
        p_input_va_calc_rl             in number,
        p_comp_lvl_fctr_id              in number,
        p_parnt_acty_base_rt_id         in number,
        p_pgm_id                        in number,
        p_pl_id                         in number,
        p_oipl_id                       in number,
        p_opt_id                        in number,
        p_oiplip_id                     in number,
        p_plip_id                       in number,
        p_ptip_id                       in number,
        p_cmbn_plip_id                  in number,
        p_cmbn_ptip_id                  in number,
        p_cmbn_ptip_opt_id              in number,
        p_vstg_for_acty_rt_id           in number,
        p_actl_prem_id                  in number,
        p_TTL_COMP_LVL_FCTR_ID          in  number,
        p_COST_ALLOCATION_KEYFLEX_ID    in  number,
        p_ALWS_CHG_CD                   in  varchar2,
        p_ele_entry_val_cd              in  varchar2,
        p_pay_rate_grade_rule_id        in  number,
        p_rate_periodization_cd         in  varchar2,
        p_rate_periodization_rl         in  number,
	p_mn_mx_elcn_rl 	        in number,
	p_mapping_table_name            in varchar2,
        p_mapping_table_pk_id           in number,
        p_business_group_id             in number,
        p_context_pgm_id                in number,
        p_context_pl_id                 in number,
        p_context_opt_id                in number,
	p_element_det_rl                in number,
        p_currency_det_cd               in varchar2,
	p_abr_attribute_category        in varchar2,
        p_abr_attribute1                in varchar2,
        p_abr_attribute2                in varchar2,
        p_abr_attribute3                in varchar2,
        p_abr_attribute4                in varchar2,
        p_abr_attribute5                in varchar2,
        p_abr_attribute6                in varchar2,
        p_abr_attribute7                in varchar2,
        p_abr_attribute8                in varchar2,
        p_abr_attribute9                in varchar2,
        p_abr_attribute10               in varchar2,
        p_abr_attribute11               in varchar2,
        p_abr_attribute12               in varchar2,
        p_abr_attribute13               in varchar2,
        p_abr_attribute14               in varchar2,
        p_abr_attribute15               in varchar2,
        p_abr_attribute16               in varchar2,
        p_abr_attribute17               in varchar2,
        p_abr_attribute18               in varchar2,
        p_abr_attribute19               in varchar2,
        p_abr_attribute20               in varchar2,
        p_abr_attribute21               in varchar2,
        p_abr_attribute22               in varchar2,
        p_abr_attribute23               in varchar2,
        p_abr_attribute24               in varchar2,
        p_abr_attribute25               in varchar2,
        p_abr_attribute26               in varchar2,
        p_abr_attribute27               in varchar2,
        p_abr_attribute28               in varchar2,
        p_abr_attribute29               in varchar2,
        p_abr_attribute30               in varchar2,
	p_abr_seq_num                   in number,
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
  hr_utility.set_location('total rate before '||p_TTL_COMP_LVL_FCTR_ID, 99);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.acty_base_rt_id                  := p_acty_base_rt_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.ordr_num			 := p_ordr_num;
  l_rec.acty_typ_cd                      := p_acty_typ_cd;
  l_rec.sub_acty_typ_cd                  := p_sub_acty_typ_cd;
  l_rec.element_type_id                  := p_element_type_id;
  l_rec.input_value_id                   := p_input_value_id;
  l_rec.input_va_calc_rl                 := p_input_va_calc_rl;
  l_rec.comp_lvl_fctr_id                 := p_comp_lvl_fctr_id;
  l_rec.parnt_acty_base_rt_id            := p_parnt_acty_base_rt_id;
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.opt_id                           := p_opt_id;
  l_rec.oiplip_id                        := p_oiplip_id;
  l_rec.plip_id                          := p_plip_id;
  l_rec.ptip_id                          := p_ptip_id;
  l_rec.cmbn_ptip_opt_id                 := p_cmbn_ptip_opt_id;
  l_rec.vstg_for_acty_rt_id              := p_vstg_for_acty_rt_id;
  l_rec.actl_prem_id                     := p_actl_prem_id;
  l_rec.TTL_COMP_LVL_FCTR_ID             :=  p_TTL_COMP_LVL_FCTR_ID;
  l_rec.COST_ALLOCATION_KEYFLEX_ID       :=  p_COST_ALLOCATION_KEYFLEX_ID;
  l_rec.ALWS_CHG_CD                      :=  p_ALWS_CHG_CD;
  l_rec.ele_entry_val_cd                 :=  p_ele_entry_val_cd;
  l_rec.rt_typ_cd                        := p_rt_typ_cd;
  l_rec.bnft_rt_typ_cd                   := p_bnft_rt_typ_cd;
  l_rec.tx_typ_cd                        := p_tx_typ_cd;
  l_rec.use_to_calc_net_flx_cr_flag      := p_use_to_calc_net_flx_cr_flag;
  l_rec.asn_on_enrt_flag                 := p_asn_on_enrt_flag;
  l_rec.abv_mx_elcn_val_alwd_flag        := p_abv_mx_elcn_val_alwd_flag;
  l_rec.blw_mn_elcn_alwd_flag            := p_blw_mn_elcn_alwd_flag;
  l_rec.dsply_on_enrt_flag               := p_dsply_on_enrt_flag;
  l_rec.parnt_chld_cd                    := p_parnt_chld_cd;
  l_rec.use_calc_acty_bs_rt_flag         := p_use_calc_acty_bs_rt_flag;
  l_rec.uses_ded_sched_flag              := p_uses_ded_sched_flag;
  l_rec.uses_varbl_rt_flag               := p_uses_varbl_rt_flag;
  l_rec.vstg_sched_apls_flag             := p_vstg_sched_apls_flag;
  l_rec.rt_mlt_cd                        := p_rt_mlt_cd;
  l_rec.proc_each_pp_dflt_flag           := p_proc_each_pp_dflt_flag;
  l_rec.prdct_flx_cr_when_elig_flag      := p_prdct_flx_cr_when_elig_flag;
  l_rec.no_std_rt_used_flag              := p_no_std_rt_used_flag;
  l_rec.rcrrg_cd                         := p_rcrrg_cd;
  l_rec.mn_elcn_val                      := p_mn_elcn_val;
  l_rec.mx_elcn_val                      := p_mx_elcn_val;
  l_rec.lwr_lmt_val                      := p_lwr_lmt_val;
  l_rec.lwr_lmt_calc_rl                  := p_lwr_lmt_calc_rl;
  l_rec.upr_lmt_val                      := p_upr_lmt_val;
  l_rec.upr_lmt_calc_rl                  := p_upr_lmt_calc_rl;
  l_rec.ptd_comp_lvl_fctr_id             := p_ptd_comp_lvl_fctr_id;
  l_rec.clm_comp_lvl_fctr_id             := p_clm_comp_lvl_fctr_id;
  l_rec.entr_ann_val_flag                := p_entr_ann_val_flag;
  l_rec.ann_mn_elcn_val                  := p_ann_mn_elcn_val;
  l_rec.ann_mx_elcn_val                  := p_ann_mx_elcn_val;
  l_rec.wsh_rl_dy_mo_num                 := p_wsh_rl_dy_mo_num;
  l_rec.uses_pymt_sched_flag             := p_uses_pymt_sched_flag;
  l_rec.nnmntry_uom                      := p_nnmntry_uom;
  l_rec.val                              := p_val;
  l_rec.incrmt_elcn_val                  := p_incrmt_elcn_val;
  l_rec.rndg_cd                          := p_rndg_cd;
  l_rec.val_ovrid_alwd_flag              := p_val_ovrid_alwd_flag;
  l_rec.prtl_mo_det_mthd_cd              := p_prtl_mo_det_mthd_cd;
  l_rec.acty_base_rt_stat_cd             := p_acty_base_rt_stat_cd;
  l_rec.procg_src_cd                     := p_procg_src_cd;
  l_rec.dflt_val                         := p_dflt_val;
  l_rec.dflt_flag                        := p_dflt_flag;
  l_rec.frgn_erg_ded_typ_cd              := p_frgn_erg_ded_typ_cd;
  l_rec.frgn_erg_ded_name                := p_frgn_erg_ded_name;
  l_rec.frgn_erg_ded_ident               := p_frgn_erg_ded_ident;
  l_rec.no_mx_elcn_val_dfnd_flag         := p_no_mx_elcn_val_dfnd_flag;
  l_rec.cmbn_plip_id                     := p_cmbn_plip_id;
  l_rec.cmbn_ptip_id                     := p_cmbn_ptip_id;
  l_rec.prtl_mo_det_mthd_rl              := p_prtl_mo_det_mthd_rl;
  l_rec.entr_val_at_enrt_flag            := p_entr_val_at_enrt_flag;
  l_rec.prtl_mo_eff_dt_det_rl            := p_prtl_mo_eff_dt_det_rl;
  l_rec.rndg_rl                          := p_rndg_rl;
  l_rec.val_calc_rl                      := p_val_calc_rl;
  l_rec.no_mn_elcn_val_dfnd_flag         := p_no_mn_elcn_val_dfnd_flag;
  l_rec.prtl_mo_eff_dt_det_cd            := p_prtl_mo_eff_dt_det_cd;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.only_one_bal_typ_alwd_flag       := p_only_one_bal_typ_alwd_flag;
  l_rec.rt_usg_cd                        := p_rt_usg_cd;
  l_rec.prort_mn_ann_elcn_val_cd         := p_prort_mn_ann_elcn_val_cd;
  l_rec.prort_mn_ann_elcn_val_rl         := p_prort_mn_ann_elcn_val_rl;
  l_rec.prort_mx_ann_elcn_val_cd         := p_prort_mx_ann_elcn_val_cd;
  l_rec.prort_mx_ann_elcn_val_rl         := p_prort_mx_ann_elcn_val_rl;
  l_rec.one_ann_pymt_cd                  := p_one_ann_pymt_cd;
  l_rec.det_pl_ytd_cntrs_cd              := p_det_pl_ytd_cntrs_cd;
  l_rec.asmt_to_use_cd                   := p_asmt_to_use_cd;
  l_rec.ele_rqd_flag                     := p_ele_rqd_flag;
  l_rec.subj_to_imptd_incm_flag          := p_subj_to_imptd_incm_flag;
  l_rec.name                             := p_name;
  l_rec.pay_rate_grade_rule_id           := p_pay_rate_grade_rule_id  ;
  l_rec.rate_periodization_cd            := p_rate_periodization_cd ;
  l_rec.rate_periodization_rl            := p_rate_periodization_rl ;
  l_rec.mn_mx_elcn_rl                    := p_mn_mx_elcn_rl ;
  l_rec.mapping_table_name               := p_mapping_table_name;
  l_rec.mapping_table_pk_id              := p_mapping_table_pk_id;
  l_rec.context_pgm_id                   := p_context_pgm_id;
  l_rec.context_pl_id                    := p_context_pl_id;
  l_rec.context_opt_id                   := p_context_opt_id;
  l_rec.element_det_rl                   := p_element_det_rl;
  l_rec.currency_det_cd                  := p_currency_det_cd;
  l_rec.abr_attribute_category           := p_abr_attribute_category;
  l_rec.abr_attribute1                   := p_abr_attribute1;
  l_rec.abr_attribute2                   := p_abr_attribute2;
  l_rec.abr_attribute3                   := p_abr_attribute3;
  l_rec.abr_attribute4                   := p_abr_attribute4;
  l_rec.abr_attribute5                   := p_abr_attribute5;
  l_rec.abr_attribute6                   := p_abr_attribute6;
  l_rec.abr_attribute7                   := p_abr_attribute7;
  l_rec.abr_attribute8                   := p_abr_attribute8;
  l_rec.abr_attribute9                   := p_abr_attribute9;
  l_rec.abr_attribute10                  := p_abr_attribute10;
  l_rec.abr_attribute11                  := p_abr_attribute11;
  l_rec.abr_attribute12                  := p_abr_attribute12;
  l_rec.abr_attribute13                  := p_abr_attribute13;
  l_rec.abr_attribute14                  := p_abr_attribute14;
  l_rec.abr_attribute15                  := p_abr_attribute15;
  l_rec.abr_attribute16                  := p_abr_attribute16;
  l_rec.abr_attribute17                  := p_abr_attribute17;
  l_rec.abr_attribute18                  := p_abr_attribute18;
  l_rec.abr_attribute19                  := p_abr_attribute19;
  l_rec.abr_attribute20                  := p_abr_attribute20;
  l_rec.abr_attribute21                  := p_abr_attribute21;
  l_rec.abr_attribute22                  := p_abr_attribute22;
  l_rec.abr_attribute23                  := p_abr_attribute23;
  l_rec.abr_attribute24                  := p_abr_attribute24;
  l_rec.abr_attribute25                  := p_abr_attribute25;
  l_rec.abr_attribute26                  := p_abr_attribute26;
  l_rec.abr_attribute27                  := p_abr_attribute27;
  l_rec.abr_attribute28                  := p_abr_attribute28;
  l_rec.abr_attribute29                  := p_abr_attribute29;
  l_rec.abr_attribute30                  := p_abr_attribute30;
  l_rec.abr_seq_num                      := p_abr_seq_num;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location('total rate before '||l_rec.TTL_COMP_LVL_FCTR_ID, 99);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_abr_shd;

/
