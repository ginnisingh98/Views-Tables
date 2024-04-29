--------------------------------------------------------
--  DDL for Package Body BEN_CTP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CTP_SHD" as
/* $Header: bectprhi.pkb 120.0 2005/05/28 01:26:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ctp_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_PTIP_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PTIP_PK') Then
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
   p_ptip_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	ptip_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	pgm_id,
        cmbn_ptip_id,
        cmbn_ptip_opt_id,
        acrs_ptip_cvg_id,
	pl_typ_id,
	coord_cvg_for_all_pls_flag,
	dpnt_dsgn_cd,
        dpnt_cvg_strt_dt_rl,
        dpnt_cvg_end_dt_rl,
        postelcn_edit_rl,
        rt_end_dt_rl,
        rt_strt_dt_rl,
        enrt_cvg_end_dt_rl,
        enrt_cvg_strt_dt_rl,
        rqd_perd_enrt_nenrt_rl,
        auto_enrt_mthd_rl,
        enrt_mthd_cd,
        enrt_cd,
        enrt_rl,
        dflt_enrt_cd,
        dflt_enrt_det_rl,
        drvbl_fctr_apls_rts_flag,
        drvbl_fctr_prtn_elig_flag,
        elig_apls_flag,
        prtn_elig_ovrid_alwd_flag,
        trk_inelig_per_flag,
        dpnt_cvg_strt_dt_cd,
        rt_end_dt_cd,
        rt_strt_dt_cd,
        enrt_cvg_end_dt_cd,
        enrt_cvg_strt_dt_cd,
        dpnt_cvg_end_dt_cd,
	crs_this_pl_typ_only_flag,
	ptip_stat_cd,
	mx_cvg_alwd_amt,
	mx_enrd_alwd_ovrid_num,
	mn_enrd_rqd_ovrid_num,
	no_mx_pl_typ_ovrid_flag,
	ordr_num,
	prvds_cr_flag,
	rqd_perd_enrt_nenrt_val,
	rqd_perd_enrt_nenrt_tm_uom,
	wvbl_flag,
        dpnt_adrs_rqd_flag,
        dpnt_cvg_no_ctfn_rqd_flag,
        dpnt_dob_rqd_flag,
        dpnt_legv_id_rqd_flag,
        susp_if_dpnt_ssn_nt_prv_cd,
        susp_if_dpnt_dob_nt_prv_cd,
        susp_if_dpnt_adr_nt_prv_cd,
        susp_if_ctfn_not_dpnt_flag,
        dpnt_ctfn_determine_cd,
	drvd_fctr_dpnt_cvg_flag,
	no_mn_pl_typ_overid_flag,
      sbj_to_sps_lf_ins_mx_flag,
      sbj_to_dpnt_lf_ins_mx_flag,
      use_to_sum_ee_lf_ins_flag,
      per_cvrd_cd,
      short_name,
      short_code,
            legislation_code,
            legislation_subgroup,
      vrfy_fmly_mmbr_cd,
      vrfy_fmly_mmbr_rl,
	ivr_ident,
        url_ref_name,
	rqd_enrt_perd_tco_cd,
	ctp_attribute_category,
	ctp_attribute1,
	ctp_attribute2,
	ctp_attribute3,
	ctp_attribute4,
	ctp_attribute5,
	ctp_attribute6,
	ctp_attribute7,
	ctp_attribute8,
	ctp_attribute9,
	ctp_attribute10,
	ctp_attribute11,
	ctp_attribute12,
	ctp_attribute13,
	ctp_attribute14,
	ctp_attribute15,
	ctp_attribute16,
	ctp_attribute17,
	ctp_attribute18,
	ctp_attribute19,
	ctp_attribute20,
	ctp_attribute21,
	ctp_attribute22,
	ctp_attribute23,
	ctp_attribute24,
	ctp_attribute25,
	ctp_attribute26,
	ctp_attribute27,
	ctp_attribute28,
	ctp_attribute29,
	ctp_attribute30,
	object_version_number
    from	ben_ptip_f
    where	ptip_id = p_ptip_id
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
      p_ptip_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_ptip_id = g_old_rec.ptip_id and
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
  l_parent_key_value5   number;
  --
  Cursor C_Sel1 Is
    select  t.pgm_id,
	    t.pl_typ_id,
            t.cmbn_ptip_id,
            t.cmbn_ptip_opt_id,
            t.acrs_ptip_cvg_id
    from    ben_ptip_f t
    where   t.ptip_id = p_base_key_value
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
                    l_parent_key_value5;
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
	 p_base_table_name	=> 'ben_ptip_f',
	 p_base_key_column	=> 'ptip_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ben_pgm_f',
	 p_parent_key_column1	=> 'pgm_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_parent_table_name2	=> 'ben_pl_typ_f',
	 p_parent_key_column2	=> 'pl_typ_id',
	 p_parent_key_value2	=> l_parent_key_value2,
	 p_parent_table_name3	=> 'ben_cmbn_ptip_f',
	 p_parent_key_column3	=> 'cmbn_ptip_id',
	 p_parent_key_value3	=> l_parent_key_value3,
	 p_parent_table_name4	=> 'ben_cmbn_ptip_opt_f',
	 p_parent_key_column4	=> 'cmbn_ptip_opt_id',
	 p_parent_key_value4	=> l_parent_key_value4,
         p_parent_table_name5   => 'ben_acrs_ptip_cvg_f',
         p_parent_key_column5   => 'acrs_ptip_cvg_id',
         p_parent_key_value5    => l_parent_key_value5,
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
	 p_base_table_name	=> 'ben_ptip_f',
	 p_base_key_column	=> 'ptip_id',
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
	(p_base_table_name	=> 'ben_ptip_f',
	 p_base_key_column	=> 'ptip_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_ptip_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.ptip_id	  = p_base_key_value
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
	 p_ptip_id	 in  number,
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
	ptip_id,
	effective_start_date,
	effective_end_date,
	coord_cvg_for_all_pls_flag,
	dpnt_dsgn_cd,
        dpnt_cvg_no_ctfn_rqd_flag,
        dpnt_cvg_strt_dt_cd,
        rt_end_dt_cd,
        rt_strt_dt_cd,
        enrt_cvg_end_dt_cd,
        enrt_cvg_strt_dt_cd,
        dpnt_cvg_strt_dt_rl,
        dpnt_cvg_end_dt_cd,
        dpnt_cvg_end_dt_rl,
        dpnt_adrs_rqd_flag,
        dpnt_legv_id_rqd_flag,
        susp_if_dpnt_ssn_nt_prv_cd,
        susp_if_dpnt_dob_nt_prv_cd,
        susp_if_dpnt_adr_nt_prv_cd,
        susp_if_ctfn_not_dpnt_flag,
        dpnt_ctfn_determine_cd,
        postelcn_edit_rl,
        rt_end_dt_rl,
        rt_strt_dt_rl,
        enrt_cvg_end_dt_rl,
        enrt_cvg_strt_dt_rl,
        rqd_perd_enrt_nenrt_rl,
        auto_enrt_mthd_rl,
        enrt_mthd_cd,
        enrt_cd,
        enrt_rl,
        dflt_enrt_cd,
        dflt_enrt_det_rl,
        drvbl_fctr_apls_rts_flag,
        drvbl_fctr_prtn_elig_flag,
        elig_apls_flag,
        prtn_elig_ovrid_alwd_flag,
        trk_inelig_per_flag,
        dpnt_dob_rqd_flag,
	crs_this_pl_typ_only_flag,
	ptip_stat_cd,
	mx_cvg_alwd_amt,
	mx_enrd_alwd_ovrid_num,
	mn_enrd_rqd_ovrid_num,
	no_mx_pl_typ_ovrid_flag,
	ordr_num,
	prvds_cr_flag,
	rqd_perd_enrt_nenrt_val,
	rqd_perd_enrt_nenrt_tm_uom,
	wvbl_flag,
	drvd_fctr_dpnt_cvg_flag,
	no_mn_pl_typ_overid_flag,
        sbj_to_sps_lf_ins_mx_flag,
        sbj_to_dpnt_lf_ins_mx_flag,
        use_to_sum_ee_lf_ins_flag,
        per_cvrd_cd,
        short_name,
        short_code,
                legislation_code,
                legislation_subgroup,
        vrfy_fmly_mmbr_cd,
        vrfy_fmly_mmbr_rl,
	ivr_ident,
        url_ref_name,
	rqd_enrt_perd_tco_cd,
	pgm_id,
	pl_typ_id,
        cmbn_ptip_id,
        cmbn_ptip_opt_id,
        acrs_ptip_cvg_id,
	business_group_id,
	ctp_attribute_category,
	ctp_attribute1,
	ctp_attribute2,
	ctp_attribute3,
	ctp_attribute4,
	ctp_attribute5,
	ctp_attribute6,
	ctp_attribute7,
	ctp_attribute8,
	ctp_attribute9,
	ctp_attribute10,
	ctp_attribute11,
	ctp_attribute12,
	ctp_attribute13,
	ctp_attribute14,
	ctp_attribute15,
	ctp_attribute16,
	ctp_attribute17,
	ctp_attribute18,
	ctp_attribute19,
	ctp_attribute20,
	ctp_attribute21,
	ctp_attribute22,
	ctp_attribute23,
	ctp_attribute24,
	ctp_attribute25,
	ctp_attribute26,
	ctp_attribute27,
	ctp_attribute28,
	ctp_attribute29,
	ctp_attribute30,
	object_version_number
    from    ben_ptip_f
    where   ptip_id         = p_ptip_id
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
                             p_argument       => 'ptip_id',
                             p_argument_value => p_ptip_id);
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
	 p_base_table_name	   => 'ben_ptip_f',
	 p_base_key_column	   => 'ptip_id',
	 p_base_key_value 	   => p_ptip_id,
	 p_parent_table_name1      => 'ben_pgm_f',
	 p_parent_key_column1      => 'pgm_id',
	 p_parent_key_value1       => g_old_rec.pgm_id,
	 p_parent_table_name2      => 'ben_pl_typ_f',
	 p_parent_key_column2      => 'pl_typ_id',
	 p_parent_key_value2       => g_old_rec.pl_typ_id,
	 p_parent_table_name3      => 'ben_cmbn_ptip_f',
	 p_parent_key_column3      => 'cmbn_ptip_id',
	 p_parent_key_value3       => g_old_rec.cmbn_ptip_id,
	 p_parent_table_name4      => 'ben_cmbn_ptip_opt_f',
	 p_parent_key_column4      => 'cmbn_ptip_opt_id',
	 p_parent_key_value4       => g_old_rec.cmbn_ptip_opt_id,
         p_parent_table_name5      => 'ben_acrs_ptip_cvg_f',
         p_parent_key_column5      => 'acrs_ptip_cvg_id',
         p_parent_key_value5       => g_old_rec.acrs_ptip_cvg_id,
--	 p_child_table_name1       => 'ben_wv_prtn_rsn_ptip_f',
--	 p_child_key_column1       => 'wv_prtn_rsn_ptip_id',
--	 p_child_table_name2       => 'ben_ler_chg_dpnt_cvg_f',
--	 p_child_key_column2       => 'ler_chg_dpnt_cvg_id',
--	 p_child_table_name3       => 'ben_acty_base_rt_f',
--	 p_child_key_column3       => 'acty_base_rt_id',
--	 p_child_table_name4       => 'ben_apld_dpnt_cvg_elig_prfl_f',
--	 p_child_key_column4       => 'apld_dpnt_cvg_elig_prfl_id',
--	 p_child_table_name5       => 'ben_ptip_dpnt_cvg_ctfn_f',
--	 p_child_key_column5       => 'ptip_dpnt_cvg_ctfn_id',
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
    fnd_message.set_token('TABLE_NAME', 'ben_ptip_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_ptip_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
        p_ptip_id                       in number,
        p_effective_start_date          in date,
        p_effective_end_date            in date,
        p_coord_cvg_for_all_pls_flag    in varchar2,
        p_dpnt_dsgn_cd                  in varchar2,
        p_dpnt_cvg_no_ctfn_rqd_flag     in varchar2,
        p_dpnt_cvg_strt_dt_cd           in varchar2,
        p_rt_end_dt_cd           in varchar2,
        p_rt_strt_dt_cd           in varchar2,
        p_enrt_cvg_end_dt_cd           in varchar2,
        p_enrt_cvg_strt_dt_cd           in varchar2,
        p_dpnt_cvg_strt_dt_rl           in number,
        p_dpnt_cvg_end_dt_cd            in varchar2,
        p_dpnt_cvg_end_dt_rl            in number,
        p_dpnt_adrs_rqd_flag            in varchar2,
        p_dpnt_legv_id_rqd_flag         in varchar2,
        p_susp_if_dpnt_ssn_nt_prv_cd    in  varchar2,
        p_susp_if_dpnt_dob_nt_prv_cd    in  varchar2,
        p_susp_if_dpnt_adr_nt_prv_cd    in  varchar2,
        p_susp_if_ctfn_not_dpnt_flag    in  varchar2,
        p_dpnt_ctfn_determine_cd        in  varchar2,
        p_postelcn_edit_rl              in number,
        p_rt_end_dt_rl              in number,
        p_rt_strt_dt_rl              in number,
        p_enrt_cvg_end_dt_rl              in number,
        p_enrt_cvg_strt_dt_rl              in number,
        p_rqd_perd_enrt_nenrt_rl              in number,
        p_auto_enrt_mthd_rl             in number,
        p_enrt_mthd_cd                  in varchar2,
        p_enrt_cd                       in varchar2,
        p_enrt_rl                       in number,
        p_dflt_enrt_cd                  in varchar2,
        p_dflt_enrt_det_rl              in number,
        p_drvbl_fctr_apls_rts_flag      in varchar2,
        p_drvbl_fctr_prtn_elig_flag     in varchar2,
        p_elig_apls_flag                in varchar2,
        p_prtn_elig_ovrid_alwd_flag     in varchar2,
        p_trk_inelig_per_flag           in varchar2,
        p_dpnt_dob_rqd_flag             in varchar2,
        p_crs_this_pl_typ_only_flag     in varchar2,
        p_ptip_stat_cd                  in varchar2,
        p_mx_cvg_alwd_amt               in number,
        p_mx_enrd_alwd_ovrid_num        in number,
        p_mn_enrd_rqd_ovrid_num         in number,
        p_no_mx_pl_typ_ovrid_flag       in varchar2,
        p_ordr_num                      in number,
        p_prvds_cr_flag                 in varchar2,
        p_rqd_perd_enrt_nenrt_val       in number,
        p_rqd_perd_enrt_nenrt_tm_uom    in varchar2,
        p_wvbl_flag                     in varchar2,
        p_drvd_fctr_dpnt_cvg_flag       in varchar2,
        p_no_mn_pl_typ_overid_flag      in varchar2,
        p_sbj_to_sps_lf_ins_mx_flag     in varchar2,
        p_sbj_to_dpnt_lf_ins_mx_flag    in varchar2,
        p_use_to_sum_ee_lf_ins_flag     in varchar2,
        p_per_cvrd_cd                   in varchar2,
        p_short_name                   in varchar2,
        p_short_code                   in varchar2,
                p_legislation_code                   in varchar2,
                p_legislation_subgroup                   in varchar2,
        p_vrfy_fmly_mmbr_cd             in varchar2,
        p_vrfy_fmly_mmbr_rl             in number,
        p_ivr_ident                     in varchar2,
        p_url_ref_name                  in varchar2,
        p_rqd_enrt_perd_tco_cd          in varchar2,
        p_pgm_id                        in number,
        p_pl_typ_id                     in number,
        p_cmbn_ptip_id                  in number,
        p_cmbn_ptip_opt_id              in number,
        p_acrs_ptip_cvg_id              in number,
        p_business_group_id             in number,
        p_ctp_attribute_category        in varchar2,
        p_ctp_attribute1                in varchar2,
        p_ctp_attribute2                in varchar2,
        p_ctp_attribute3                in varchar2,
        p_ctp_attribute4                in varchar2,
        p_ctp_attribute5                in varchar2,
        p_ctp_attribute6                in varchar2,
        p_ctp_attribute7                in varchar2,
        p_ctp_attribute8                in varchar2,
        p_ctp_attribute9                in varchar2,
        p_ctp_attribute10               in varchar2,
        p_ctp_attribute11               in varchar2,
        p_ctp_attribute12               in varchar2,
        p_ctp_attribute13               in varchar2,
        p_ctp_attribute14               in varchar2,
        p_ctp_attribute15               in varchar2,
        p_ctp_attribute16               in varchar2,
        p_ctp_attribute17               in varchar2,
        p_ctp_attribute18               in varchar2,
        p_ctp_attribute19               in varchar2,
        p_ctp_attribute20               in varchar2,
        p_ctp_attribute21               in varchar2,
        p_ctp_attribute22               in varchar2,
        p_ctp_attribute23               in varchar2,
        p_ctp_attribute24               in varchar2,
        p_ctp_attribute25               in varchar2,
        p_ctp_attribute26               in varchar2,
        p_ctp_attribute27               in varchar2,
        p_ctp_attribute28               in varchar2,
        p_ctp_attribute29               in varchar2,
        p_ctp_attribute30               in varchar2,
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
  l_rec.ptip_id                          := p_ptip_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.cmbn_ptip_id                     := p_cmbn_ptip_id;
  l_rec.cmbn_ptip_opt_id                 := p_cmbn_ptip_opt_id;
  l_rec.acrs_ptip_cvg_id                 := p_acrs_ptip_cvg_id;
  l_rec.pl_typ_id                        := p_pl_typ_id;
  l_rec.coord_cvg_for_all_pls_flag       := p_coord_cvg_for_all_pls_flag;
  l_rec.dpnt_dsgn_cd                     := p_dpnt_dsgn_cd;
  l_rec.dpnt_cvg_strt_dt_rl              := p_dpnt_cvg_strt_dt_rl;
  l_rec.dpnt_cvg_end_dt_rl               := p_dpnt_cvg_end_dt_rl;
  l_rec.postelcn_edit_rl                 := p_postelcn_edit_rl;
  l_rec.rt_end_dt_rl                     := p_rt_end_dt_rl;
  l_rec.rt_strt_dt_rl                    := p_rt_strt_dt_rl;
  l_rec.enrt_cvg_end_dt_rl               := p_enrt_cvg_end_dt_rl;
  l_rec.enrt_cvg_strt_dt_rl              := p_enrt_cvg_strt_dt_rl;
  l_rec.rqd_perd_enrt_nenrt_rl           := p_rqd_perd_enrt_nenrt_rl;
  l_rec.auto_enrt_mthd_rl                := p_auto_enrt_mthd_rl;
  l_rec.enrt_mthd_cd                     := p_enrt_mthd_cd;
  l_rec.enrt_cd                          := p_enrt_cd;
  l_rec.enrt_rl                          := p_enrt_rl;
  l_rec.dflt_enrt_cd                     := p_dflt_enrt_cd;
  l_rec.dflt_enrt_det_rl                 := p_dflt_enrt_det_rl;
  l_rec.drvbl_fctr_apls_rts_flag         := p_drvbl_fctr_apls_rts_flag;
  l_rec.drvbl_fctr_prtn_elig_flag        := p_drvbl_fctr_prtn_elig_flag;
  l_rec.elig_apls_flag                   := p_elig_apls_flag;
  l_rec.prtn_elig_ovrid_alwd_flag        := p_prtn_elig_ovrid_alwd_flag;
  l_rec.trk_inelig_per_flag              := p_trk_inelig_per_flag;
  l_rec.dpnt_cvg_strt_dt_cd              := p_dpnt_cvg_strt_dt_cd;
  l_rec.rt_end_dt_cd                     := p_rt_end_dt_cd;
  l_rec.rt_strt_dt_cd                    := p_rt_strt_dt_cd;
  l_rec.enrt_cvg_end_dt_cd               := p_enrt_cvg_end_dt_cd;
  l_rec.enrt_cvg_strt_dt_cd              := p_enrt_cvg_strt_dt_cd;
  l_rec.dpnt_cvg_end_dt_cd               := p_dpnt_cvg_end_dt_cd;
  l_rec.crs_this_pl_typ_only_flag        := p_crs_this_pl_typ_only_flag;
  l_rec.ptip_stat_cd                     := p_ptip_stat_cd;
  l_rec.mx_cvg_alwd_amt                  := p_mx_cvg_alwd_amt;
  l_rec.mx_enrd_alwd_ovrid_num           := p_mx_enrd_alwd_ovrid_num;
  l_rec.mn_enrd_rqd_ovrid_num            := p_mn_enrd_rqd_ovrid_num;
  l_rec.no_mx_pl_typ_ovrid_flag          := p_no_mx_pl_typ_ovrid_flag;
  l_rec.ordr_num                         := p_ordr_num;
  l_rec.prvds_cr_flag                    := p_prvds_cr_flag;
  l_rec.rqd_perd_enrt_nenrt_val          := p_rqd_perd_enrt_nenrt_val;
  l_rec.rqd_perd_enrt_nenrt_tm_uom       := p_rqd_perd_enrt_nenrt_tm_uom;
  l_rec.wvbl_flag                        := p_wvbl_flag;
  l_rec.dpnt_adrs_rqd_flag               := p_dpnt_adrs_rqd_flag;
  l_rec.dpnt_cvg_no_ctfn_rqd_flag        := p_dpnt_cvg_no_ctfn_rqd_flag;
  l_rec.dpnt_dob_rqd_flag                := p_dpnt_dob_rqd_flag;
  l_rec.dpnt_legv_id_rqd_flag            := p_dpnt_legv_id_rqd_flag;
  l_rec.susp_if_dpnt_ssn_nt_prv_cd       := p_susp_if_dpnt_ssn_nt_prv_cd;
  l_rec.susp_if_dpnt_dob_nt_prv_cd       := p_susp_if_dpnt_dob_nt_prv_cd;
  l_rec.susp_if_dpnt_adr_nt_prv_cd       := p_susp_if_dpnt_adr_nt_prv_cd;
  l_rec.susp_if_ctfn_not_dpnt_flag       := p_susp_if_ctfn_not_dpnt_flag;
  l_rec.dpnt_ctfn_determine_cd           := p_dpnt_ctfn_determine_cd;
  l_rec.drvd_fctr_dpnt_cvg_flag          := p_drvd_fctr_dpnt_cvg_flag;
  l_rec.no_mn_pl_typ_overid_flag         := p_no_mn_pl_typ_overid_flag;
  l_rec.sbj_to_sps_lf_ins_mx_flag      := p_sbj_to_sps_lf_ins_mx_flag;
  l_rec.sbj_to_dpnt_lf_ins_mx_flag     := p_sbj_to_dpnt_lf_ins_mx_flag;
  l_rec.use_to_sum_ee_lf_ins_flag        := p_use_to_sum_ee_lf_ins_flag;
  l_rec.per_cvrd_cd                      := p_per_cvrd_cd;
  l_rec.short_name                      := p_short_name;
  l_rec.short_code                      := p_short_code;
    l_rec.legislation_code                      := p_legislation_code;
    l_rec.legislation_subgroup                      := p_legislation_subgroup;
  l_rec.vrfy_fmly_mmbr_cd                := p_vrfy_fmly_mmbr_cd;
  l_rec.vrfy_fmly_mmbr_rl                := p_vrfy_fmly_mmbr_rl;
  l_rec.ivr_ident                        := p_ivr_ident;
  l_rec.url_ref_name                     := p_url_ref_name;
  l_rec.rqd_enrt_perd_tco_cd             := p_rqd_enrt_perd_tco_cd;
  l_rec.ctp_attribute_category           := p_ctp_attribute_category;
  l_rec.ctp_attribute1                   := p_ctp_attribute1;
  l_rec.ctp_attribute2                   := p_ctp_attribute2;
  l_rec.ctp_attribute3                   := p_ctp_attribute3;
  l_rec.ctp_attribute4                   := p_ctp_attribute4;
  l_rec.ctp_attribute5                   := p_ctp_attribute5;
  l_rec.ctp_attribute6                   := p_ctp_attribute6;
  l_rec.ctp_attribute7                   := p_ctp_attribute7;
  l_rec.ctp_attribute8                   := p_ctp_attribute8;
  l_rec.ctp_attribute9                   := p_ctp_attribute9;
  l_rec.ctp_attribute10                  := p_ctp_attribute10;
  l_rec.ctp_attribute11                  := p_ctp_attribute11;
  l_rec.ctp_attribute12                  := p_ctp_attribute12;
  l_rec.ctp_attribute13                  := p_ctp_attribute13;
  l_rec.ctp_attribute14                  := p_ctp_attribute14;
  l_rec.ctp_attribute15                  := p_ctp_attribute15;
  l_rec.ctp_attribute16                  := p_ctp_attribute16;
  l_rec.ctp_attribute17                  := p_ctp_attribute17;
  l_rec.ctp_attribute18                  := p_ctp_attribute18;
  l_rec.ctp_attribute19                  := p_ctp_attribute19;
  l_rec.ctp_attribute20                  := p_ctp_attribute20;
  l_rec.ctp_attribute21                  := p_ctp_attribute21;
  l_rec.ctp_attribute22                  := p_ctp_attribute22;
  l_rec.ctp_attribute23                  := p_ctp_attribute23;
  l_rec.ctp_attribute24                  := p_ctp_attribute24;
  l_rec.ctp_attribute25                  := p_ctp_attribute25;
  l_rec.ctp_attribute26                  := p_ctp_attribute26;
  l_rec.ctp_attribute27                  := p_ctp_attribute27;
  l_rec.ctp_attribute28                  := p_ctp_attribute28;
  l_rec.ctp_attribute29                  := p_ctp_attribute29;
  l_rec.ctp_attribute30                  := p_ctp_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_ctp_shd;

/
