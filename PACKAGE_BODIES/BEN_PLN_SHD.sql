--------------------------------------------------------
--  DDL for Package Body BEN_PLN_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLN_SHD" as
/* $Header: beplnrhi.pkb 120.8.12010000.2 2008/08/18 09:47:19 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_pln_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc     varchar2(72) := g_package||'return_api_dml_status';
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
  l_proc     varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_PL_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PL_F_PK') Then
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
  (p_effective_date        in date,
   p_pl_id        in number,
   p_object_version_number    in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  cursor c_sel1 is
    select
     pl_id
    ,effective_start_date
    ,effective_end_date
    ,name
    ,alws_qdro_flag
    ,alws_qmcso_flag
    ,alws_reimbmts_flag
    ,bnf_addl_instn_txt_alwd_flag
    ,bnf_adrs_rqd_flag
    ,bnf_cntngt_bnfs_alwd_flag
    ,bnf_ctfn_rqd_flag
    ,bnf_dob_rqd_flag
    ,bnf_dsge_mnr_ttee_rqd_flag
    ,bnf_incrmt_amt
    ,bnf_dflt_bnf_cd
    ,bnf_legv_id_rqd_flag
    ,bnf_may_dsgt_org_flag
    ,bnf_mn_dsgntbl_amt
    ,bnf_mn_dsgntbl_pct_val
    ,rqd_perd_enrt_nenrt_val
    ,ordr_num
    ,bnf_pct_incrmt_val
    ,bnf_pct_amt_alwd_cd
    ,bnf_qdro_rl_apls_flag
    ,dflt_to_asn_pndg_ctfn_cd
    ,dflt_to_asn_pndg_ctfn_rl
    ,drvbl_fctr_apls_rts_flag
    ,drvbl_fctr_prtn_elig_flag
    ,dpnt_dsgn_cd
    ,elig_apls_flag
    ,invk_dcln_prtn_pl_flag
    ,invk_flx_cr_pl_flag
    ,imptd_incm_calc_cd
    ,drvbl_dpnt_elig_flag
    ,trk_inelig_per_flag
    ,pl_cd
    ,auto_enrt_mthd_rl
    ,ivr_ident
    ,url_ref_name
    ,cmpr_clms_to_cvg_or_bal_cd
    ,cobra_pymt_due_dy_num
    ,dpnt_cvd_by_othr_apls_flag
    ,enrt_mthd_cd
    ,enrt_cd
    ,enrt_cvg_strt_dt_cd
    ,enrt_cvg_end_dt_cd
    ,frfs_aply_flag
    ,hc_pl_subj_hcfa_aprvl_flag
    ,hghly_cmpd_rl_apls_flag
    ,incptn_dt
    ,mn_cvg_rl
    ,mn_cvg_rqd_amt
    ,mn_opts_rqd_num
    ,mx_cvg_alwd_amt
    ,mx_cvg_rl
    ,mx_opts_alwd_num
    ,mx_cvg_wcfn_mlt_num
    ,mx_cvg_wcfn_amt
    ,mx_cvg_incr_alwd_amt
    ,mx_cvg_incr_wcf_alwd_amt
    ,mx_cvg_mlt_incr_num
    ,mx_cvg_mlt_incr_wcf_num
    ,mx_wtg_dt_to_use_cd
    ,mx_wtg_dt_to_use_rl
    ,mx_wtg_perd_prte_uom
    ,mx_wtg_perd_prte_val
    ,mx_wtg_perd_rl
    ,nip_dflt_enrt_cd
    ,nip_dflt_enrt_det_rl
    ,dpnt_adrs_rqd_flag
    ,dpnt_cvg_end_dt_cd
    ,dpnt_cvg_end_dt_rl
    ,dpnt_cvg_strt_dt_cd
    ,dpnt_cvg_strt_dt_rl
    ,dpnt_dob_rqd_flag
    ,dpnt_leg_id_rqd_flag
    ,dpnt_no_ctfn_rqd_flag
    ,no_mn_cvg_amt_apls_flag
    ,no_mn_cvg_incr_apls_flag
    ,no_mn_opts_num_apls_flag
    ,no_mx_cvg_amt_apls_flag
    ,no_mx_cvg_incr_apls_flag
    ,no_mx_opts_num_apls_flag
    ,nip_pl_uom
    ,rqd_perd_enrt_nenrt_uom
    ,nip_acty_ref_perd_cd
    ,nip_enrt_info_rt_freq_cd
    ,per_cvrd_cd
    ,enrt_cvg_end_dt_rl
    ,postelcn_edit_rl
    ,enrt_cvg_strt_dt_rl
    ,prort_prtl_yr_cvg_rstrn_cd
    ,prort_prtl_yr_cvg_rstrn_rl
    ,prtn_elig_ovrid_alwd_flag
    ,svgs_pl_flag
    ,subj_to_imptd_incm_typ_cd
    ,use_all_asnts_elig_flag
    ,use_all_asnts_for_rt_flag
    ,vstg_apls_flag
    ,wvbl_flag
    ,hc_svc_typ_cd
    ,pl_stat_cd
    ,prmry_fndg_mthd_cd
    ,rt_end_dt_cd
    ,rt_end_dt_rl
    ,rt_strt_dt_rl
    ,rt_strt_dt_cd
    ,bnf_dsgn_cd
    ,pl_typ_id
    ,business_group_id
    ,enrt_pl_opt_flag
    ,bnft_prvdr_pool_id
    ,may_enrl_pl_n_oipl_flag
    ,enrt_rl
    ,rqd_perd_enrt_nenrt_rl
    ,alws_unrstrctd_enrt_flag
    ,bnft_or_option_rstrctn_cd
    ,cvg_incr_r_decr_only_cd
    ,unsspnd_enrt_cd
    ,pln_attribute_category
    ,pln_attribute1
    ,pln_attribute2
    ,pln_attribute3
    ,pln_attribute4
    ,pln_attribute5
    ,pln_attribute6
    ,pln_attribute7
    ,pln_attribute8
    ,pln_attribute9
    ,pln_attribute10
    ,pln_attribute11
    ,pln_attribute12
    ,pln_attribute13
    ,pln_attribute14
    ,pln_attribute15
    ,pln_attribute16
    ,pln_attribute17
    ,pln_attribute18
    ,pln_attribute19
    ,pln_attribute20
    ,pln_attribute21
    ,pln_attribute22
    ,pln_attribute23
    ,pln_attribute24
    ,pln_attribute25
    ,pln_attribute26
    ,pln_attribute27
    ,pln_attribute28
    ,pln_attribute29
    ,pln_attribute30
    ,susp_if_ctfn_not_prvd_flag
    ,ctfn_determine_cd
    ,susp_if_dpnt_ssn_nt_prv_cd
    ,susp_if_dpnt_dob_nt_prv_cd
    ,susp_if_dpnt_adr_nt_prv_cd
    ,susp_if_ctfn_not_dpnt_flag
    ,susp_if_bnf_ssn_nt_prv_cd
    ,susp_if_bnf_dob_nt_prv_cd
    ,susp_if_bnf_adr_nt_prv_cd
    ,susp_if_ctfn_not_bnf_flag
    ,dpnt_ctfn_determine_cd
    ,bnf_ctfn_determine_cd
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date
    ,object_version_number
    ,actl_prem_id
    ,vrfy_fmly_mmbr_cd
    ,vrfy_fmly_mmbr_rl
    ,alws_tmpry_id_crd_flag
    ,nip_dflt_flag
    ,frfs_distr_mthd_cd
    ,frfs_distr_mthd_rl
    ,frfs_cntr_det_cd
    ,frfs_distr_det_cd
    ,cost_alloc_keyflex_1_id
    ,cost_alloc_keyflex_2_id
    ,post_to_gl_flag
    ,frfs_val_det_cd
    ,frfs_mx_cryfwd_val
    ,frfs_portion_det_cd
    ,bndry_perd_cd
    ,short_name
    ,short_code
    ,legislation_code
    ,legislation_subgroup
    ,group_pl_id
    ,mapping_table_name
    ,mapping_table_pk_id
    ,function_code
    ,pl_yr_not_applcbl_flag
    ,use_csd_rsd_prccng_cd
    from    ben_pl_f
    where    pl_id = p_pl_id
    and        p_effective_date
    between    effective_start_date and effective_end_date;
--
  l_proc    varchar2(72)    := g_package||'api_updating';
  l_fct_ret    boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_effective_date is null or
      p_pl_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_pl_id = g_old_rec.pl_id and
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
--
Procedure find_dt_del_modes
    (p_effective_date    in  date,
     p_base_key_value    in  number,
     p_zap            out nocopy boolean,
     p_delete        out nocopy boolean,
     p_future_change    out nocopy boolean,
     p_delete_next_change    out nocopy boolean) is
--
  l_proc         varchar2(72)     := g_package||'find_dt_del_modes';
--
  l_parent_key_value1    number;
  l_parent_key_value2    number;
  l_parent_key_value3    number;
  l_parent_key_value4    number;
  l_parent_key_value5    number;
  l_parent_key_value6    number;
  l_parent_key_value7    number;
  l_parent_key_value8    number;
  l_parent_key_value9    number;
  l_parent_key_value10    number;
  l_parent_key_value11    number;
  l_parent_key_value12    number;
  l_parent_key_value13    number;
  l_parent_key_value14    number;
  l_parent_key_value15    number;
  l_parent_key_value16    number;
  l_zap                    boolean;
  l_zap1                boolean;
  l_delete            boolean;
  l_delete1             boolean;
  l_future_change       boolean;
  l_future_change1      boolean;
  l_delete_next_change  boolean;
  l_delete_next_change1 boolean;
  --
  Cursor C_Sel1 Is
    select  t.dflt_to_asn_pndg_ctfn_rl,
            t.auto_enrt_mthd_rl,
            t.mn_cvg_rl,
            t.mx_cvg_rl,
            t.mx_wtg_dt_to_use_rl,
            t.nip_dflt_enrt_det_rl,
            t.dpnt_cvg_end_dt_rl,
            t.dpnt_cvg_strt_dt_rl,
            t.enrt_cvg_end_dt_rl,
            t.postelcn_edit_rl,
            t.enrt_cvg_strt_dt_rl,
            t.prort_prtl_yr_cvg_rstrn_rl,
            t.rt_end_dt_rl,
            t.rt_strt_dt_rl,
            t.pl_typ_id,
            t.actl_prem_id
    from    ben_pl_f t
    where   t.pl_id = p_base_key_value
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
    (p_effective_date      => p_effective_date,
     p_base_table_name     => 'ben_pl_f',
     p_base_key_column     => 'pl_id',
     p_base_key_value      => p_base_key_value,
     p_parent_table_name1  => 'ff_formulas_f',
     p_parent_key_column1  => 'formula_id',
     p_parent_key_value1   => l_parent_key_value1,
     p_parent_table_name2  => 'ff_formulas_f',
     p_parent_key_column2  => 'formula_id',
     p_parent_key_value2   => l_parent_key_value2,
     p_parent_table_name3  => 'ff_formulas_f',
     p_parent_key_column3  => 'formula_id',
     p_parent_key_value3   => l_parent_key_value3,
     p_parent_table_name4  => 'ff_formulas_f',
     p_parent_key_column4  => 'formula_id',
     p_parent_key_value4   => l_parent_key_value4,
     p_parent_table_name5  => 'ff_formulas_f',
     p_parent_key_column5  => 'formula_id',
     p_parent_key_value5   => l_parent_key_value5,
     p_parent_table_name6  => 'ff_formulas_f',
     p_parent_key_column6  => 'formula_id',
     p_parent_key_value6   => l_parent_key_value6,
     p_parent_table_name7  => 'ff_formulas_f',
     p_parent_key_column7  => 'formula_id',
     p_parent_key_value7   => l_parent_key_value7,
     p_parent_table_name8  => 'ff_formulas_f',
     p_parent_key_column8  => 'formula_id',
     p_parent_key_value8   => l_parent_key_value8,
     p_parent_table_name9  => 'ff_formulas_f',
     p_parent_key_column9  => 'formula_id',
     p_parent_key_value9   => l_parent_key_value9,
     p_parent_table_name10 => 'ff_formulas_f',
     p_parent_key_column10 => 'formula_id',
     p_parent_key_value10  => l_parent_key_value10,
     p_zap                 => l_zap,
     p_delete              => l_delete,
     p_future_change       => l_future_change,
     p_delete_next_change  => l_delete_next_change);
  --
  dt_api.find_dt_del_modes
    (p_effective_date      => p_effective_date,
     p_base_table_name     => 'ben_pl_f',
     p_base_key_column     => 'pl_id',
     p_base_key_value      => p_base_key_value,
     p_parent_table_name1  => 'ff_formulas_f',
     p_parent_key_column1  => 'formula_id',
     p_parent_key_value1   => l_parent_key_value11,
     p_parent_table_name2  => 'ff_formulas_f',
     p_parent_key_column2  => 'formula_id',
     p_parent_key_value2   => l_parent_key_value12,
     p_parent_table_name3  => 'ff_formulas_f',
     p_parent_key_column3  => 'formula_id',
     p_parent_key_value3   => l_parent_key_value13,
     p_parent_table_name4  => 'ff_formulas_f',
     p_parent_key_column4  => 'formula_id',
     p_parent_key_value4   => l_parent_key_value14,
     p_parent_table_name5  => 'ben_pl_typ_f',         -- Bug : 3658243 Corrected Arguments
     p_parent_key_column5  => 'pl_typ_id',
     p_parent_key_value5   => l_parent_key_value15,
--     p_parent_table_name6  => 'ben_pl_typ_f',
--     p_parent_key_column6  => 'pl_typ_id',
--     p_parent_key_value6   => l_parent_key_value16,
--     p_parent_table_name7    => 'ben_actl_prem_f',
--     p_parent_key_column7    => 'actl_prem_id',
--     p_parent_key_value7    => l_parent_key_value16,
     p_zap                 => l_zap1,
     p_delete              => l_delete1,
     p_future_change       => l_future_change1,
     p_delete_next_change  => l_delete_next_change1);
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
--
Procedure find_dt_upd_modes
    (p_effective_date    in  date,
     p_base_key_value    in  number,
     p_correction        out nocopy boolean,
     p_update        out nocopy boolean,
     p_update_override    out nocopy boolean,
     p_update_change_insert    out nocopy boolean) is
--
  l_proc     varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date       => p_effective_date,
     p_base_table_name      => 'ben_pl_f',
     p_base_key_column      => 'pl_id',
     p_base_key_value       => p_base_key_value,
     p_correction           => p_correction,
     p_update               => p_update,
     p_update_override      => p_update_override,
     p_update_change_insert => p_update_change_insert);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
--
Procedure upd_effective_end_date
    (p_effective_date        in date,
     p_base_key_value        in number,
     p_new_effective_end_date    in date,
     p_validation_start_date    in date,
     p_validation_end_date        in date,
         p_object_version_number       out nocopy number) is
--
  l_proc           varchar2(72) := g_package||'upd_effective_end_date';
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
    (p_base_table_name    => 'ben_pl_f',
     p_base_key_column    => 'pl_id',
     p_base_key_value     => p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_pl_f t
  set      t.effective_end_date      = p_new_effective_end_date,
      t.object_version_number = l_object_version_number
  where      t.pl_id      = p_base_key_value
  and      p_effective_date
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
--
Procedure lck
    (p_effective_date        in  date,
     p_datetrack_mode        in  varchar2,
     p_pl_id                 in  number,
     p_object_version_number in  number,
     p_validation_start_date out nocopy date,
     p_validation_end_date   out nocopy date) is
--
  l_proc                   varchar2(72) := g_package||'lck';
  l_validation_start_date  date;
  l_validation_end_date    date;
  l_validation_start_date1 date;
  l_validation_end_date1   date;
  l_validation_start_date2 date;
  l_validation_end_date2   date;
  l_object_invalid         exception;
  l_argument               varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  cursor c_sel1 is
    select
     pl_id
    ,effective_start_date
    ,effective_end_date
    ,name
    ,alws_qdro_flag
    ,alws_qmcso_flag
    ,alws_reimbmts_flag
    ,bnf_addl_instn_txt_alwd_flag
    ,bnf_adrs_rqd_flag
    ,bnf_cntngt_bnfs_alwd_flag
    ,bnf_ctfn_rqd_flag
    ,bnf_dob_rqd_flag
    ,bnf_dsge_mnr_ttee_rqd_flag
    ,bnf_incrmt_amt
    ,bnf_dflt_bnf_cd
    ,bnf_legv_id_rqd_flag
    ,bnf_may_dsgt_org_flag
    ,bnf_mn_dsgntbl_amt
    ,bnf_mn_dsgntbl_pct_val
    ,rqd_perd_enrt_nenrt_val
    ,ordr_num
    ,bnf_pct_incrmt_val
    ,bnf_pct_amt_alwd_cd
    ,bnf_qdro_rl_apls_flag
    ,dflt_to_asn_pndg_ctfn_cd
    ,dflt_to_asn_pndg_ctfn_rl
    ,drvbl_fctr_apls_rts_flag
    ,drvbl_fctr_prtn_elig_flag
    ,dpnt_dsgn_cd
    ,elig_apls_flag
    ,invk_dcln_prtn_pl_flag
    ,invk_flx_cr_pl_flag
    ,imptd_incm_calc_cd
    ,drvbl_dpnt_elig_flag
    ,trk_inelig_per_flag
    ,pl_cd
    ,auto_enrt_mthd_rl
    ,ivr_ident
    ,url_ref_name
    ,cmpr_clms_to_cvg_or_bal_cd
    ,cobra_pymt_due_dy_num
    ,dpnt_cvd_by_othr_apls_flag
    ,enrt_mthd_cd
    ,enrt_cd
    ,enrt_cvg_strt_dt_cd
    ,enrt_cvg_end_dt_cd
    ,frfs_aply_flag
    ,hc_pl_subj_hcfa_aprvl_flag
    ,hghly_cmpd_rl_apls_flag
    ,incptn_dt
    ,mn_cvg_rl
    ,mn_cvg_rqd_amt
    ,mn_opts_rqd_num
    ,mx_cvg_alwd_amt
    ,mx_cvg_rl
    ,mx_opts_alwd_num
    ,mx_cvg_wcfn_mlt_num
    ,mx_cvg_wcfn_amt
    ,mx_cvg_incr_alwd_amt
    ,mx_cvg_incr_wcf_alwd_amt
    ,mx_cvg_mlt_incr_num
    ,mx_cvg_mlt_incr_wcf_num
    ,mx_wtg_dt_to_use_cd
    ,mx_wtg_dt_to_use_rl
    ,mx_wtg_perd_prte_uom
    ,mx_wtg_perd_prte_val
    ,mx_wtg_perd_rl
    ,nip_dflt_enrt_cd
    ,nip_dflt_enrt_det_rl
    ,dpnt_adrs_rqd_flag
    ,dpnt_cvg_end_dt_cd
    ,dpnt_cvg_end_dt_rl
    ,dpnt_cvg_strt_dt_cd
    ,dpnt_cvg_strt_dt_rl
    ,dpnt_dob_rqd_flag
    ,dpnt_leg_id_rqd_flag
    ,dpnt_no_ctfn_rqd_flag
    ,no_mn_cvg_amt_apls_flag
    ,no_mn_cvg_incr_apls_flag
    ,no_mn_opts_num_apls_flag
    ,no_mx_cvg_amt_apls_flag
    ,no_mx_cvg_incr_apls_flag
    ,no_mx_opts_num_apls_flag
    ,nip_pl_uom
    ,rqd_perd_enrt_nenrt_uom
    ,nip_acty_ref_perd_cd
    ,nip_enrt_info_rt_freq_cd
    ,per_cvrd_cd
    ,enrt_cvg_end_dt_rl
    ,postelcn_edit_rl
    ,enrt_cvg_strt_dt_rl
    ,prort_prtl_yr_cvg_rstrn_cd
    ,prort_prtl_yr_cvg_rstrn_rl
    ,prtn_elig_ovrid_alwd_flag
    ,svgs_pl_flag
    ,subj_to_imptd_incm_typ_cd
    ,use_all_asnts_elig_flag
    ,use_all_asnts_for_rt_flag
    ,vstg_apls_flag
    ,wvbl_flag
    ,hc_svc_typ_cd
    ,pl_stat_cd
    ,prmry_fndg_mthd_cd
    ,rt_end_dt_cd
    ,rt_end_dt_rl
    ,rt_strt_dt_rl
    ,rt_strt_dt_cd
    ,bnf_dsgn_cd
    ,pl_typ_id
    ,business_group_id
    ,enrt_pl_opt_flag
    ,bnft_prvdr_pool_id
    ,may_enrl_pl_n_oipl_flag
    ,enrt_rl
    ,rqd_perd_enrt_nenrt_rl
    ,alws_unrstrctd_enrt_flag
    ,bnft_or_option_rstrctn_cd
    ,cvg_incr_r_decr_only_cd
    ,unsspnd_enrt_cd
    ,pln_attribute_category
    ,pln_attribute1
    ,pln_attribute2
    ,pln_attribute3
    ,pln_attribute4
    ,pln_attribute5
    ,pln_attribute6
    ,pln_attribute7
    ,pln_attribute8
    ,pln_attribute9
    ,pln_attribute10
    ,pln_attribute11
    ,pln_attribute12
    ,pln_attribute13
    ,pln_attribute14
    ,pln_attribute15
    ,pln_attribute16
    ,pln_attribute17
    ,pln_attribute18
    ,pln_attribute19
    ,pln_attribute20
    ,pln_attribute21
    ,pln_attribute22
    ,pln_attribute23
    ,pln_attribute24
    ,pln_attribute25
    ,pln_attribute26
    ,pln_attribute27
    ,pln_attribute28
    ,pln_attribute29
    ,pln_attribute30
    ,susp_if_ctfn_not_prvd_flag
    ,ctfn_determine_cd
    ,susp_if_dpnt_ssn_nt_prv_cd
    ,susp_if_dpnt_dob_nt_prv_cd
    ,susp_if_dpnt_adr_nt_prv_cd
    ,susp_if_ctfn_not_dpnt_flag
    ,susp_if_bnf_ssn_nt_prv_cd
    ,susp_if_bnf_dob_nt_prv_cd
    ,susp_if_bnf_adr_nt_prv_cd
    ,susp_if_ctfn_not_bnf_flag
    ,dpnt_ctfn_determine_cd
    ,bnf_ctfn_determine_cd
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date
    ,object_version_number
    ,actl_prem_id
    ,vrfy_fmly_mmbr_cd
    ,vrfy_fmly_mmbr_rl
    ,alws_tmpry_id_crd_flag
    ,nip_dflt_flag
    ,frfs_distr_mthd_cd
    ,frfs_distr_mthd_rl
    ,frfs_cntr_det_cd
    ,frfs_distr_det_cd
    ,cost_alloc_keyflex_1_id
    ,cost_alloc_keyflex_2_id
    ,post_to_gl_flag
    ,frfs_val_det_cd
    ,frfs_mx_cryfwd_val
    ,frfs_portion_det_cd
    ,bndry_perd_cd
    ,short_name
    ,short_code
    ,legislation_code
    ,legislation_subgroup
    ,group_pl_id
    ,mapping_table_name
    ,mapping_table_pk_id
    ,function_code
    ,pl_yr_not_applcbl_flag
    ,use_csd_rsd_prccng_cd
    from    ben_pl_f
    where   pl_id         = p_pl_id
    and        p_effective_date
    between effective_start_date and effective_end_date ;
  --  for update nowait;
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
                             p_argument       => 'pl_id',
                             p_argument_value => p_pl_id);
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
  hr_utility.set_location('no record found', 5);
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
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
    (p_effective_date          => p_effective_date,
     p_datetrack_mode          => p_datetrack_mode,
     p_base_table_name         => 'ben_pl_f',
     p_base_key_column         => 'pl_id',
     p_base_key_value          => p_pl_id,
     p_parent_table_name1      => 'ff_formulas_f',
     p_parent_key_column1      => 'formula_id',
     p_parent_key_value1       => g_old_rec.dflt_to_asn_pndg_ctfn_rl,
     p_parent_table_name2      => 'ff_formulas_f',
     p_parent_key_column2      => 'formula_id',
     p_parent_key_value2       => g_old_rec.auto_enrt_mthd_rl,
     p_parent_table_name3      => 'ff_formulas_f',
     p_parent_key_column3      => 'formula_id',
     p_parent_key_value3       => g_old_rec.mn_cvg_rl,
     p_parent_table_name4      => 'ff_formulas_f',
     p_parent_key_column4      => 'formula_id',
     p_parent_key_value4       => g_old_rec.mx_cvg_rl,
     p_parent_table_name5      => 'ff_formulas_f',
     p_parent_key_column5      => 'formula_id',
     p_parent_key_value5       => g_old_rec.mx_wtg_dt_to_use_rl,
     p_parent_table_name7      => 'ff_formulas_f',
     p_parent_key_column7      => 'formula_id',
     p_parent_key_value7       => g_old_rec.nip_dflt_enrt_det_rl,
     p_parent_table_name8      => 'ff_formulas_f',
     p_parent_key_column8      => 'formula_id',
     p_parent_key_value8       => g_old_rec.dpnt_cvg_end_dt_rl,
     p_parent_table_name9      => 'ff_formulas_f',
     p_parent_key_column9      => 'formula_id',
     p_parent_key_value9       => g_old_rec.dpnt_cvg_strt_dt_rl,
     p_parent_table_name10     => 'ff_formulas_f',
     p_parent_key_column10     => 'formula_id',
     p_parent_key_value10      => g_old_rec.enrt_cvg_end_dt_rl,
--   p_child_table_name1       => 'ben_pl_regy_bod_f',
--   p_child_key_column1       => 'pl_regy_bod_id',
--   p_child_table_name2       => 'ben_drvbl_fctr_uom',
--   p_child_key_column2       => 'drvbl_fctr_uom_id',
--   p_child_table_name3       => 'ben_oipl_f',
--   p_child_key_column3       => 'oipl_id',
--   p_child_table_name4       => 'ben_popl_enrt_typ_cycl_f',
--   p_child_key_column4       => 'popl_enrt_typ_cycl_id',
--   p_child_table_name5       => 'ben_vald_rlshp_for_reimb_f',
--   p_child_key_column5       => 'vald_rlshp_for_reimb_id',
--   p_child_table_name6       => 'ben_ler_chg_pl_nip_enrt_f',
--   p_child_key_column6       => 'ler_chg_pl_nip_enrt_id',
--   p_child_table_name7       => 'ben_pl_gd_or_svc_f',
--   p_child_key_column7       => 'pl_gd_or_svc_id',
--   p_child_table_name8       => 'ben_plip_f',
--   p_child_key_column8       => 'plip_id',
--   p_child_table_name9       => 'ben_dsgn_rqmt_f',
--   p_child_key_column9       => 'dsgn_rqmt_id',
--   p_child_table_name10      => 'ben_pl_regn_f',
--   p_child_key_column10      => 'pl_regn_id',
     p_enforce_foreign_locking => false , --true,
     p_validation_start_date   => l_validation_start_date,
      p_validation_end_date       => l_validation_end_date);
    --
    dt_api.validate_dt_mode
    (p_effective_date          => p_effective_date,
     p_datetrack_mode          => p_datetrack_mode,
     p_base_table_name         => 'ben_pl_f',
     p_base_key_column         => 'pl_id',
     p_base_key_value          => p_pl_id,
     p_parent_table_name1      => 'ff_formulas_f',
     p_parent_key_column1      => 'formula_id',
     p_parent_key_value1       => g_old_rec.postelcn_edit_rl,
     p_parent_table_name2      => 'ff_formulas_f',
     p_parent_key_column2      => 'formula_id',
     p_parent_key_value2       => g_old_rec.enrt_cvg_strt_dt_rl,
     p_parent_table_name3      => 'ff_formulas_f',
     p_parent_key_column3      => 'formula_id',
     p_parent_key_value3       => g_old_rec.prort_prtl_yr_cvg_rstrn_rl,
     p_parent_table_name4      => 'ff_formulas_f',
     p_parent_key_column4      => 'formula_id',
     p_parent_key_value4       => g_old_rec.rt_end_dt_rl,
     p_parent_table_name5      => 'ff_formulas_f',
     p_parent_key_column5      => 'formula_id',
     p_parent_key_value5       => g_old_rec.rt_strt_dt_rl,
     p_parent_table_name6      => 'ben_pl_typ_f',
     p_parent_key_column6      => 'pl_typ_id',
     p_parent_key_value6       => g_old_rec.pl_typ_id,
     p_parent_table_name7      => 'ben_bnft_prvdr_pool_f',
     p_parent_key_column7      => 'bnft_prvdr_pool_id',
     p_parent_key_value7       => g_old_rec.bnft_prvdr_pool_id,
     p_parent_table_name8      => 'ff_formulas_f',
     p_parent_key_column8      => 'formula_id',
     p_parent_key_value8       => g_old_rec.ENRT_RL,
--   p_child_table_name2       => 'ben_prtn_elig_f',
--   p_child_key_column2       => 'prtn_elig_id',
--   p_child_table_name3       => 'ben_cvg_amt_calc_mthd_f',
--   p_child_key_column3       => 'cvg_amt_calc_mthd_id',
--   p_child_table_name4       => 'ben_ler_chg_dpnt_cvg_f',
--   p_child_key_column4       => 'ler_chg_dpnt_cvg_id',
--   p_child_table_name5       => 'ben_popl_org_f',
--   p_child_key_column5       => 'popl_org_id',
--   p_child_table_name6       => 'ben_elig_per_f',
--   p_child_key_column6       => 'elig_per_id',
--   p_child_table_name7       => 'ben_elig_prtt_anthr_pl_prte_f',
--   p_child_key_column7       => 'elig_prtt_anthr_pl_prte_id',
--   p_child_table_name8       => 'ben_pl_r_oipl_asset_f',
--   p_child_key_column8       => 'pl_r_oipl_asset_id',
     p_enforce_foreign_locking => false , --true,
     p_validation_start_date   => l_validation_start_date1,
     p_validation_end_date     => l_validation_end_date1);
    --
    dt_api.validate_dt_mode
    (p_effective_date          => p_effective_date,
     p_datetrack_mode          => p_datetrack_mode,
     p_base_table_name         => 'ben_pl_f',
     p_base_key_column         => 'pl_id',
     p_base_key_value          => p_pl_id,
--   p_child_table_name1       => 'ben_acty_base_rt_f',
--   p_child_key_column1       => 'acty_base_rt_id',
--   p_child_table_name2       => 'ben_pl_dpnt_cvg_ctfn_f',
--   p_child_key_column2       => 'pl_dpnt_cvg_ctfn_id',
--   p_child_table_name3       => 'ben_pl_bnf_ctfn_f',
--   p_child_key_column3       => 'pl_bnf_ctfn_id',
--   p_child_table_name4       => 'ben_popl_rptg_grp_f',
--   p_child_key_column4       => 'popl_rptg_grp_id',
--   p_child_table_name5       => 'ben_prtt_reimbmt_rqst_f',
--   p_child_key_column5       => 'prtt_reimbmt_rqst_id',
--   p_child_table_name6       => 'ben_apld_dpnt_cvg_elig_prfl_f',
--   p_child_key_column6       => 'apld_dpnt_cvg_elig_prfl_id',
--   p_child_table_name7       => 'ben_prtt_enrt_rslt_f',
--   p_child_key_column7       => 'prtt_enrt_rslt_id',
--   p_child_table_name8       => 'ben_vrbl_rt_prfl_f',
--   p_child_key_column8       => 'vrbl_rt_prfl_id',
--   p_child_table_name9       => 'ben_wv_prtn_rsn_pl_f',
--   p_child_key_column9       => 'wv_prtn_rsn_pl_id',
     p_enforce_foreign_locking => false , --true,
     p_validation_start_date   => l_validation_start_date2,
     p_validation_end_date     => l_validation_end_date2);
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ben_pl_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_pl_f');
    fnd_message.raise_error;
End lck;
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
--
function convert_args
  (p_pl_id                         in number
  ,p_effective_start_date          in date
  ,p_effective_end_date            in date
  ,p_name                          in varchar2
  ,p_alws_qdro_flag                in varchar2
  ,p_alws_qmcso_flag               in varchar2
  ,p_alws_reimbmts_flag            in varchar2
  ,p_bnf_addl_instn_txt_alwd_flag  in varchar2
  ,p_bnf_adrs_rqd_flag             in varchar2
  ,p_bnf_cntngt_bnfs_alwd_flag     in varchar2
  ,p_bnf_ctfn_rqd_flag             in varchar2
  ,p_bnf_dob_rqd_flag              in varchar2
  ,p_bnf_dsge_mnr_ttee_rqd_flag    in varchar2
  ,p_bnf_incrmt_amt                in number
  ,p_bnf_dflt_bnf_cd               in varchar2
  ,p_bnf_legv_id_rqd_flag          in varchar2
  ,p_bnf_may_dsgt_org_flag         in varchar2
  ,p_bnf_mn_dsgntbl_amt            in number
  ,p_bnf_mn_dsgntbl_pct_val        in number
  ,p_rqd_perd_enrt_nenrt_val       in number
  ,p_ordr_num                      in number
  ,p_bnf_pct_incrmt_val            in number
  ,p_bnf_pct_amt_alwd_cd           in varchar2
  ,p_bnf_qdro_rl_apls_flag         in varchar2
  ,p_dflt_to_asn_pndg_ctfn_cd      in varchar2
  ,p_dflt_to_asn_pndg_ctfn_rl      in number
  ,p_drvbl_fctr_apls_rts_flag      in varchar2
  ,p_drvbl_fctr_prtn_elig_flag     in varchar2
  ,p_dpnt_dsgn_cd                  in varchar2
  ,p_elig_apls_flag                in varchar2
  ,p_invk_dcln_prtn_pl_flag        in varchar2
  ,p_invk_flx_cr_pl_flag           in varchar2
  ,p_imptd_incm_calc_cd            in varchar2
  ,p_drvbl_dpnt_elig_flag          in varchar2
  ,p_trk_inelig_per_flag           in varchar2
  ,p_pl_cd                         in varchar2
  ,p_auto_enrt_mthd_rl             in number
  ,p_ivr_ident                     in varchar2
  ,p_url_ref_name                  in varchar2
  ,p_cmpr_clms_to_cvg_or_bal_cd    in varchar2
  ,p_cobra_pymt_due_dy_num         in number
  ,p_dpnt_cvd_by_othr_apls_flag    in varchar2
  ,p_enrt_mthd_cd                  in varchar2
  ,p_enrt_cd                       in varchar2
  ,p_enrt_cvg_strt_dt_cd           in varchar2
  ,p_enrt_cvg_end_dt_cd            in varchar2
  ,p_frfs_aply_flag                in varchar2
  ,p_hc_pl_subj_hcfa_aprvl_flag    in varchar2
  ,p_hghly_cmpd_rl_apls_flag       in varchar2
  ,p_incptn_dt                     in date
  ,p_mn_cvg_rl                     in number
  ,p_mn_cvg_rqd_amt                in number
  ,p_mn_opts_rqd_num               in number
  ,p_mx_cvg_alwd_amt               in number
  ,p_mx_cvg_rl                     in number
  ,p_mx_opts_alwd_num              in number
  ,p_mx_cvg_wcfn_mlt_num           in number
  ,p_mx_cvg_wcfn_amt               in number
  ,p_mx_cvg_incr_alwd_amt          in number
  ,p_mx_cvg_incr_wcf_alwd_amt      in number
  ,p_mx_cvg_mlt_incr_num           in number
  ,p_mx_cvg_mlt_incr_wcf_num       in number
  ,p_mx_wtg_dt_to_use_cd           in varchar2
  ,p_mx_wtg_dt_to_use_rl           in number
  ,p_mx_wtg_perd_prte_uom          in varchar2
  ,p_mx_wtg_perd_prte_val          in number
  ,p_mx_wtg_perd_rl                in number
  ,p_nip_dflt_enrt_cd              in varchar2
  ,p_nip_dflt_enrt_det_rl          in number
  ,p_dpnt_adrs_rqd_flag            in varchar2
  ,p_dpnt_cvg_end_dt_cd            in varchar2
  ,p_dpnt_cvg_end_dt_rl            in number
  ,p_dpnt_cvg_strt_dt_cd           in varchar2
  ,p_dpnt_cvg_strt_dt_rl           in number
  ,p_dpnt_dob_rqd_flag             in varchar2
  ,p_dpnt_leg_id_rqd_flag          in varchar2
  ,p_dpnt_no_ctfn_rqd_flag         in varchar2
  ,p_no_mn_cvg_amt_apls_flag       in varchar2
  ,p_no_mn_cvg_incr_apls_flag      in varchar2
  ,p_no_mn_opts_num_apls_flag      in varchar2
  ,p_no_mx_cvg_amt_apls_flag       in varchar2
  ,p_no_mx_cvg_incr_apls_flag      in varchar2
  ,p_no_mx_opts_num_apls_flag      in varchar2
  ,p_nip_pl_uom                    in varchar2
  ,p_rqd_perd_enrt_nenrt_uom       in varchar2
  ,p_nip_acty_ref_perd_cd          in varchar2
  ,p_nip_enrt_info_rt_freq_cd      in varchar2
  ,p_per_cvrd_cd                   in varchar2
  ,p_enrt_cvg_end_dt_rl            in number
  ,p_postelcn_edit_rl              in number
  ,p_enrt_cvg_strt_dt_rl           in number
  ,p_prort_prtl_yr_cvg_rstrn_cd    in varchar2
  ,p_prort_prtl_yr_cvg_rstrn_rl    in number
  ,p_prtn_elig_ovrid_alwd_flag     in varchar2
  ,p_svgs_pl_flag                  in varchar2
  ,p_subj_to_imptd_incm_typ_cd     in varchar2
  ,p_use_all_asnts_elig_flag       in varchar2
  ,p_use_all_asnts_for_rt_flag     in varchar2
  ,p_vstg_apls_flag                in varchar2
  ,p_wvbl_flag                     in varchar2
  ,p_hc_svc_typ_cd                 in varchar2
  ,p_pl_stat_cd                    in varchar2
  ,p_prmry_fndg_mthd_cd            in varchar2
  ,p_rt_end_dt_cd                  in varchar2
  ,p_rt_end_dt_rl                  in number
  ,p_rt_strt_dt_rl                 in number
  ,p_rt_strt_dt_cd                 in varchar2
  ,p_bnf_dsgn_cd                   in varchar2
  ,p_pl_typ_id                     in number
  ,p_business_group_id             in number
  ,p_enrt_pl_opt_flag              in varchar2
  ,p_bnft_prvdr_pool_id            in number
  ,p_may_enrl_pl_n_oipl_flag       in varchar2
  ,p_enrt_rl                       in number
  ,p_rqd_perd_enrt_nenrt_rl        in number
  ,p_alws_unrstrctd_enrt_flag      in varchar2
  ,p_bnft_or_option_rstrctn_cd     in varchar2
  ,p_cvg_incr_r_decr_only_cd       in varchar2
  ,p_unsspnd_enrt_cd               in varchar2
  ,p_pln_attribute_category        in varchar2
  ,p_pln_attribute1                in varchar2
  ,p_pln_attribute2                in varchar2
  ,p_pln_attribute3                in varchar2
  ,p_pln_attribute4                in varchar2
  ,p_pln_attribute5                in varchar2
  ,p_pln_attribute6                in varchar2
  ,p_pln_attribute7                in varchar2
  ,p_pln_attribute8                in varchar2
  ,p_pln_attribute9                in varchar2
  ,p_pln_attribute10               in varchar2
  ,p_pln_attribute11               in varchar2
  ,p_pln_attribute12               in varchar2
  ,p_pln_attribute13               in varchar2
  ,p_pln_attribute14               in varchar2
  ,p_pln_attribute15               in varchar2
  ,p_pln_attribute16               in varchar2
  ,p_pln_attribute17               in varchar2
  ,p_pln_attribute18               in varchar2
  ,p_pln_attribute19               in varchar2
  ,p_pln_attribute20               in varchar2
  ,p_pln_attribute21               in varchar2
  ,p_pln_attribute22               in varchar2
  ,p_pln_attribute23               in varchar2
  ,p_pln_attribute24               in varchar2
  ,p_pln_attribute25               in varchar2
  ,p_pln_attribute26               in varchar2
  ,p_pln_attribute27               in varchar2
  ,p_pln_attribute28               in varchar2
  ,p_pln_attribute29               in varchar2
  ,p_pln_attribute30               in varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2
  ,p_ctfn_determine_cd              in  varchar2
  ,p_susp_if_dpnt_ssn_nt_prv_cd     in  varchar2
  ,p_susp_if_dpnt_dob_nt_prv_cd     in  varchar2
  ,p_susp_if_dpnt_adr_nt_prv_cd     in  varchar2
  ,p_susp_if_ctfn_not_dpnt_flag     in  varchar2
  ,p_susp_if_bnf_ssn_nt_prv_cd      in  varchar2
  ,p_susp_if_bnf_dob_nt_prv_cd      in  varchar2
  ,p_susp_if_bnf_adr_nt_prv_cd      in  varchar2
  ,p_susp_if_ctfn_not_bnf_flag      in  varchar2
  ,p_dpnt_ctfn_determine_cd         in  varchar2
  ,p_bnf_ctfn_determine_cd          in  varchar2
  ,p_object_version_number         in number
  ,p_actl_prem_id                  in number
  ,p_vrfy_fmly_mmbr_cd             in varchar2
  ,p_vrfy_fmly_mmbr_rl             in number
  ,p_alws_tmpry_id_crd_flag        in varchar2
  ,p_nip_dflt_flag                 in varchar2
  ,p_frfs_distr_mthd_cd            in  varchar2
  ,p_frfs_distr_mthd_rl            in  number
  ,p_frfs_cntr_det_cd              in  varchar2
  ,p_frfs_distr_det_cd             in  varchar2
  ,p_cost_alloc_keyflex_1_id       in  number
  ,p_cost_alloc_keyflex_2_id       in  number
  ,p_post_to_gl_flag               in  varchar2
  ,p_frfs_val_det_cd               in  varchar2
  ,p_frfs_mx_cryfwd_val            in  number
  ,p_frfs_portion_det_cd           in  varchar2
  ,p_bndry_perd_cd                 in  varchar2
  ,p_short_name		           in  varchar2
  ,p_short_code			   in  varchar2
  ,p_legislation_code		   in  varchar2
  ,p_legislation_subgroup	   in  varchar2
  ,p_group_pl_id		   in   number
  ,p_mapping_table_name            in  varchar2
  ,p_mapping_table_pk_id           in  number
  ,p_function_code                 in  varchar2
  ,p_pl_yr_not_applcbl_flag        in  varchar2
  ,p_use_csd_rsd_prccng_cd        in  varchar2

  )
    Return g_rec_type is
--
  l_rec      g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
    l_rec.pl_id                         := p_pl_id;
    l_rec.effective_start_date          := p_effective_start_date;
    l_rec.effective_end_date            := p_effective_end_date;
    l_rec.name                          := p_name;
    l_rec.alws_qdro_flag                := p_alws_qdro_flag;
    l_rec.alws_qmcso_flag               := p_alws_qmcso_flag;
    l_rec.alws_reimbmts_flag            := p_alws_reimbmts_flag;
    l_rec.bnf_addl_instn_txt_alwd_flag  := p_bnf_addl_instn_txt_alwd_flag;
    l_rec.bnf_adrs_rqd_flag             := p_bnf_adrs_rqd_flag;
    l_rec.bnf_cntngt_bnfs_alwd_flag     := p_bnf_cntngt_bnfs_alwd_flag;
    l_rec.bnf_ctfn_rqd_flag             := p_bnf_ctfn_rqd_flag;
    l_rec.bnf_dob_rqd_flag              := p_bnf_dob_rqd_flag;
    l_rec.bnf_dsge_mnr_ttee_rqd_flag    := p_bnf_dsge_mnr_ttee_rqd_flag;
    l_rec.bnf_incrmt_amt                := p_bnf_incrmt_amt;
    l_rec.bnf_dflt_bnf_cd               := p_bnf_dflt_bnf_cd;
    l_rec.bnf_legv_id_rqd_flag          := p_bnf_legv_id_rqd_flag;
    l_rec.bnf_may_dsgt_org_flag         := p_bnf_may_dsgt_org_flag;
    l_rec.bnf_mn_dsgntbl_amt            := p_bnf_mn_dsgntbl_amt;
    l_rec.bnf_mn_dsgntbl_pct_val        := p_bnf_mn_dsgntbl_pct_val;
    l_rec.rqd_perd_enrt_nenrt_val       := p_rqd_perd_enrt_nenrt_val;
    l_rec.ordr_num                      := p_ordr_num;
    l_rec.bnf_pct_incrmt_val            := p_bnf_pct_incrmt_val;
    l_rec.bnf_pct_amt_alwd_cd           := p_bnf_pct_amt_alwd_cd;
    l_rec.bnf_qdro_rl_apls_flag         := p_bnf_qdro_rl_apls_flag;
    l_rec.dflt_to_asn_pndg_ctfn_cd      := p_dflt_to_asn_pndg_ctfn_cd;
    l_rec.dflt_to_asn_pndg_ctfn_rl      := p_dflt_to_asn_pndg_ctfn_rl;
    l_rec.drvbl_fctr_apls_rts_flag      := p_drvbl_fctr_apls_rts_flag;
    l_rec.drvbl_fctr_prtn_elig_flag     := p_drvbl_fctr_prtn_elig_flag;
    l_rec.dpnt_dsgn_cd                  := p_dpnt_dsgn_cd;
    l_rec.elig_apls_flag                := p_elig_apls_flag;
    l_rec.invk_dcln_prtn_pl_flag        := p_invk_dcln_prtn_pl_flag;
    l_rec.invk_flx_cr_pl_flag           := p_invk_flx_cr_pl_flag;
    l_rec.imptd_incm_calc_cd            := p_imptd_incm_calc_cd;
    l_rec.drvbl_dpnt_elig_flag          := p_drvbl_dpnt_elig_flag;
    l_rec.trk_inelig_per_flag           := p_trk_inelig_per_flag;
    l_rec.pl_cd                         := p_pl_cd;
    l_rec.auto_enrt_mthd_rl             := p_auto_enrt_mthd_rl;
    l_rec.ivr_ident                     := p_ivr_ident;
    l_rec.url_ref_name                  := p_url_ref_name;
    l_rec.cmpr_clms_to_cvg_or_bal_cd    := p_cmpr_clms_to_cvg_or_bal_cd;
    l_rec.cobra_pymt_due_dy_num         := p_cobra_pymt_due_dy_num;
    l_rec.dpnt_cvd_by_othr_apls_flag    := p_dpnt_cvd_by_othr_apls_flag;
    l_rec.enrt_mthd_cd                  := p_enrt_mthd_cd;
    l_rec.enrt_cd                       := p_enrt_cd;
    l_rec.enrt_cvg_strt_dt_cd           := p_enrt_cvg_strt_dt_cd;
    l_rec.enrt_cvg_end_dt_cd            := p_enrt_cvg_end_dt_cd;
    l_rec.frfs_aply_flag                := p_frfs_aply_flag;
    l_rec.hc_pl_subj_hcfa_aprvl_flag    := p_hc_pl_subj_hcfa_aprvl_flag;
    l_rec.hghly_cmpd_rl_apls_flag       := p_hghly_cmpd_rl_apls_flag;
    l_rec.incptn_dt                     := p_incptn_dt;
    l_rec.mn_cvg_rl                     := p_mn_cvg_rl;
    l_rec.mn_cvg_rqd_amt                := p_mn_cvg_rqd_amt;
    l_rec.mn_opts_rqd_num               := p_mn_opts_rqd_num;
    l_rec.mx_cvg_alwd_amt               := p_mx_cvg_alwd_amt;
    l_rec.mx_cvg_rl                     := p_mx_cvg_rl;
    l_rec.mx_opts_alwd_num              := p_mx_opts_alwd_num;
    l_rec.mx_cvg_wcfn_mlt_num           := p_mx_cvg_wcfn_mlt_num;
    l_rec.mx_cvg_wcfn_amt               := p_mx_cvg_wcfn_amt;
    l_rec.mx_cvg_incr_alwd_amt          := p_mx_cvg_incr_alwd_amt;
    l_rec.mx_cvg_incr_wcf_alwd_amt      := p_mx_cvg_incr_wcf_alwd_amt;
    l_rec.mx_cvg_mlt_incr_num           := p_mx_cvg_mlt_incr_num;
    l_rec.mx_cvg_mlt_incr_wcf_num       := p_mx_cvg_mlt_incr_wcf_num;
    l_rec.mx_wtg_dt_to_use_cd           := p_mx_wtg_dt_to_use_cd;
    l_rec.mx_wtg_dt_to_use_rl           := p_mx_wtg_dt_to_use_rl;
    l_rec.mx_wtg_perd_prte_uom          := p_mx_wtg_perd_prte_uom;
    l_rec.mx_wtg_perd_prte_val          := p_mx_wtg_perd_prte_val;
    l_rec.mx_wtg_perd_rl                := p_mx_wtg_perd_rl;
    l_rec.nip_dflt_enrt_cd              := p_nip_dflt_enrt_cd;
    l_rec.nip_dflt_enrt_det_rl          := p_nip_dflt_enrt_det_rl;
    l_rec.dpnt_adrs_rqd_flag            := p_dpnt_adrs_rqd_flag;
    l_rec.dpnt_cvg_end_dt_cd            := p_dpnt_cvg_end_dt_cd;
    l_rec.dpnt_cvg_end_dt_rl            := p_dpnt_cvg_end_dt_rl;
    l_rec.dpnt_cvg_strt_dt_cd           := p_dpnt_cvg_strt_dt_cd;
    l_rec.dpnt_cvg_strt_dt_rl           := p_dpnt_cvg_strt_dt_rl;
    l_rec.dpnt_dob_rqd_flag             := p_dpnt_dob_rqd_flag;
    l_rec.dpnt_leg_id_rqd_flag          := p_dpnt_leg_id_rqd_flag;
    l_rec.dpnt_no_ctfn_rqd_flag         := p_dpnt_no_ctfn_rqd_flag;
    l_rec.no_mn_cvg_amt_apls_flag       := p_no_mn_cvg_amt_apls_flag;
    l_rec.no_mn_cvg_incr_apls_flag      := p_no_mn_cvg_incr_apls_flag;
    l_rec.no_mn_opts_num_apls_flag      := p_no_mn_opts_num_apls_flag;
    l_rec.no_mx_cvg_amt_apls_flag       := p_no_mx_cvg_amt_apls_flag;
    l_rec.no_mx_cvg_incr_apls_flag      := p_no_mx_cvg_incr_apls_flag;
    l_rec.no_mx_opts_num_apls_flag      := p_no_mx_opts_num_apls_flag;
    l_rec.nip_pl_uom                    := p_nip_pl_uom;
    l_rec.rqd_perd_enrt_nenrt_uom       := p_rqd_perd_enrt_nenrt_uom;
    l_rec.nip_acty_ref_perd_cd          := p_nip_acty_ref_perd_cd;
    l_rec.nip_enrt_info_rt_freq_cd      := p_nip_enrt_info_rt_freq_cd;
    l_rec.per_cvrd_cd                   := p_per_cvrd_cd;
    l_rec.enrt_cvg_end_dt_rl            := p_enrt_cvg_end_dt_rl;
    l_rec.postelcn_edit_rl              := p_postelcn_edit_rl;
    l_rec.enrt_cvg_strt_dt_rl           := p_enrt_cvg_strt_dt_rl;
    l_rec.prort_prtl_yr_cvg_rstrn_cd    := p_prort_prtl_yr_cvg_rstrn_cd;
    l_rec.prort_prtl_yr_cvg_rstrn_rl    := p_prort_prtl_yr_cvg_rstrn_rl;
    l_rec.prtn_elig_ovrid_alwd_flag     := p_prtn_elig_ovrid_alwd_flag;
    l_rec.svgs_pl_flag                  := p_svgs_pl_flag;
    l_rec.subj_to_imptd_incm_typ_cd     := p_subj_to_imptd_incm_typ_cd;
    l_rec.use_all_asnts_elig_flag       := p_use_all_asnts_elig_flag;
    l_rec.use_all_asnts_for_rt_flag     := p_use_all_asnts_for_rt_flag;
    l_rec.vstg_apls_flag                := p_vstg_apls_flag;
    l_rec.wvbl_flag                     := p_wvbl_flag;
    l_rec.hc_svc_typ_cd                 := p_hc_svc_typ_cd;
    l_rec.pl_stat_cd                    := p_pl_stat_cd;
    l_rec.prmry_fndg_mthd_cd            := p_prmry_fndg_mthd_cd;
    l_rec.rt_end_dt_cd                  := p_rt_end_dt_cd;
    l_rec.rt_end_dt_rl                  := p_rt_end_dt_rl;
    l_rec.rt_strt_dt_rl                 := p_rt_strt_dt_rl;
    l_rec.rt_strt_dt_cd                 := p_rt_strt_dt_cd;
    l_rec.bnf_dsgn_cd                   := p_bnf_dsgn_cd;
    l_rec.pl_typ_id                     := p_pl_typ_id;
    l_rec.business_group_id             := p_business_group_id;
    l_rec.enrt_pl_opt_flag              := p_enrt_pl_opt_flag;
    l_rec.bnft_prvdr_pool_id            := p_bnft_prvdr_pool_id;
    l_rec.MAY_ENRL_PL_N_OIPL_FLAG       := p_MAY_ENRL_PL_N_OIPL_FLAG;
    l_rec.ENRT_RL                       := p_ENRT_RL;
    l_rec.rqd_perd_enrt_nenrt_rl        := p_rqd_perd_enrt_nENRT_RL;
    l_rec.ALWS_UNRSTRCTD_ENRT_FLAG      := p_ALWS_UNRSTRCTD_ENRT_FLAG;
    l_rec.BNFT_OR_OPTION_RSTRCTN_CD     := p_BNFT_OR_OPTION_RSTRCTN_CD;
    l_rec.CVG_INCR_R_DECR_ONLY_CD       := p_CVG_INCR_R_DECR_ONLY_CD;
    l_rec.unsspnd_enrt_cd               := p_unsspnd_enrt_cd;
    l_rec.pln_attribute_category        := p_pln_attribute_category;
    l_rec.pln_attribute1                := p_pln_attribute1;
    l_rec.pln_attribute2                := p_pln_attribute2;
    l_rec.pln_attribute3                := p_pln_attribute3;
    l_rec.pln_attribute4                := p_pln_attribute4;
    l_rec.pln_attribute5                := p_pln_attribute5;
    l_rec.pln_attribute6                := p_pln_attribute6;
    l_rec.pln_attribute7                := p_pln_attribute7;
    l_rec.pln_attribute8                := p_pln_attribute8;
    l_rec.pln_attribute9                := p_pln_attribute9;
    l_rec.pln_attribute10               := p_pln_attribute10;
    l_rec.pln_attribute11               := p_pln_attribute11;
    l_rec.pln_attribute12               := p_pln_attribute12;
    l_rec.pln_attribute13               := p_pln_attribute13;
    l_rec.pln_attribute14               := p_pln_attribute14;
    l_rec.pln_attribute15               := p_pln_attribute15;
    l_rec.pln_attribute16               := p_pln_attribute16;
    l_rec.pln_attribute17               := p_pln_attribute17;
    l_rec.pln_attribute18               := p_pln_attribute18;
    l_rec.pln_attribute19               := p_pln_attribute19;
    l_rec.pln_attribute20               := p_pln_attribute20;
    l_rec.pln_attribute21               := p_pln_attribute21;
    l_rec.pln_attribute22               := p_pln_attribute22;
    l_rec.pln_attribute23               := p_pln_attribute23;
    l_rec.pln_attribute24               := p_pln_attribute24;
    l_rec.pln_attribute25               := p_pln_attribute25;
    l_rec.pln_attribute26               := p_pln_attribute26;
    l_rec.pln_attribute27               := p_pln_attribute27;
    l_rec.pln_attribute28               := p_pln_attribute28;
    l_rec.pln_attribute29               := p_pln_attribute29;
    l_rec.pln_attribute30               := p_pln_attribute30;
    l_rec.susp_if_ctfn_not_prvd_flag    := p_susp_if_ctfn_not_prvd_flag;
    l_rec.ctfn_determine_cd             := p_ctfn_determine_cd ;
    l_rec.susp_if_dpnt_ssn_nt_prv_cd    := p_susp_if_dpnt_ssn_nt_prv_cd;
    l_rec.susp_if_dpnt_dob_nt_prv_cd    := p_susp_if_dpnt_dob_nt_prv_cd ;
    l_rec.susp_if_dpnt_adr_nt_prv_cd    := p_susp_if_dpnt_adr_nt_prv_cd ;
    l_rec.susp_if_ctfn_not_dpnt_flag    := p_susp_if_ctfn_not_dpnt_flag;
    l_rec.susp_if_bnf_ssn_nt_prv_cd     := p_susp_if_bnf_ssn_nt_prv_cd;
    l_rec.susp_if_bnf_dob_nt_prv_cd     := p_susp_if_bnf_dob_nt_prv_cd ;
    l_rec.susp_if_bnf_adr_nt_prv_cd     := p_susp_if_bnf_adr_nt_prv_cd ;
    l_rec.susp_if_ctfn_not_bnf_flag     := p_susp_if_ctfn_not_bnf_flag ;
    l_rec.dpnt_ctfn_determine_cd        := p_dpnt_ctfn_determine_cd ;
    l_rec.bnf_ctfn_determine_cd         := p_bnf_ctfn_determine_cd ;
    l_rec.object_version_number         := p_object_version_number;
    l_rec.actl_prem_id                  := p_actl_prem_id;
    l_rec.vrfy_fmly_mmbr_cd             := p_vrfy_fmly_mmbr_cd;
    l_rec.vrfy_fmly_mmbr_rl             := p_vrfy_fmly_mmbr_rl;
    l_rec.alws_tmpry_id_crd_flag        := p_alws_tmpry_id_crd_flag;
    l_rec.nip_dflt_flag                 := p_nip_dflt_flag;
    l_rec.frfs_distr_mthd_cd            :=  p_frfs_distr_mthd_cd;
    l_rec.frfs_distr_mthd_rl            :=  p_frfs_distr_mthd_rl;
    l_rec.frfs_cntr_det_cd              :=  p_frfs_cntr_det_cd;
    l_rec.frfs_distr_det_cd             :=  p_frfs_distr_det_cd ;
    l_rec.cost_alloc_keyflex_1_id       :=  p_cost_alloc_keyflex_1_id;
    l_rec.cost_alloc_keyflex_2_id       :=  p_cost_alloc_keyflex_2_id;
    l_rec.post_to_gl_flag               :=  p_post_to_gl_flag ;
    l_rec.frfs_val_det_cd               :=  p_frfs_val_det_cd ;
    l_rec.frfs_mx_cryfwd_val            :=  p_frfs_mx_cryfwd_val  ;
    l_rec.frfs_portion_det_cd           :=  p_frfs_portion_det_cd ;
    l_rec.bndry_perd_cd                 :=  p_bndry_perd_cd;
    l_rec.short_name                    :=  p_short_name;
    l_rec.short_code                    :=  p_short_code;
    l_rec.legislation_code              :=  p_legislation_code;
    l_rec.legislation_subgroup          :=  p_legislation_subgroup;
    l_rec.group_pl_id                   :=  p_group_pl_id;
    l_rec.mapping_table_name            :=  p_mapping_table_name;
    l_rec.mapping_table_pk_id           :=  p_mapping_table_pk_id;
    l_rec.function_code                 :=  p_function_code;
    l_rec.pl_yr_not_applcbl_flag        :=  p_pl_yr_not_applcbl_flag;
    l_rec.use_csd_rsd_prccng_cd         :=  p_use_csd_rsd_prccng_cd;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_pln_shd;

/
