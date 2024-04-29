--------------------------------------------------------
--  DDL for Package Body BEN_COP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COP_SHD" as
/* $Header: becoprhi.pkb 120.5 2007/12/04 10:59:29 bachakra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cop_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_OIPL_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_OIPL_PK') Then
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
   p_oipl_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	oipl_id,
	effective_start_date,
	effective_end_date,
	ivr_ident,
        url_ref_name,
	opt_id,
	business_group_id,
	pl_id,
	ordr_num,
	rqd_perd_enrt_nenrt_val,
	actl_prem_id,
	dflt_flag,
	mndtry_flag,
	oipl_stat_cd,
      pcp_dsgn_cd,
      pcp_dpnt_dsgn_cd,
	rqd_perd_enrt_nenrt_uom,
	elig_apls_flag,
	dflt_enrt_det_rl,
	trk_inelig_per_flag,
	drvbl_fctr_prtn_elig_flag,
	mndtry_rl,
	rqd_perd_enrt_nenrt_rl,
	dflt_enrt_cd,
	prtn_elig_ovrid_alwd_flag,
	drvbl_fctr_apls_rts_flag,
      per_cvrd_cd,
      postelcn_edit_rl,
      vrfy_fmly_mmbr_cd,
      vrfy_fmly_mmbr_rl,
      enrt_cd,
      enrt_rl,
      auto_enrt_flag,
      auto_enrt_mthd_rl,
      short_name,	/*FHR*/
      short_code,	/*FHR*/
            legislation_code,	/*FHR*/
            legislation_subgroup,	/*FHR*/
      hidden_flag,
      susp_if_ctfn_not_prvd_flag,
      ctfn_determine_cd,
	cop_attribute_category,
	cop_attribute1,
	cop_attribute2,
	cop_attribute3,
	cop_attribute4,
	cop_attribute5,
	cop_attribute6,
	cop_attribute7,
	cop_attribute8,
	cop_attribute9,
	cop_attribute10,
	cop_attribute11,
	cop_attribute12,
	cop_attribute13,
	cop_attribute14,
	cop_attribute15,
	cop_attribute16,
	cop_attribute17,
	cop_attribute18,
	cop_attribute19,
	cop_attribute20,
	cop_attribute21,
	cop_attribute22,
	cop_attribute23,
	cop_attribute24,
	cop_attribute25,
	cop_attribute26,
	cop_attribute27,
	cop_attribute28,
	cop_attribute29,
	cop_attribute30,
	object_version_number
    from	ben_oipl_f
    where	oipl_id = p_oipl_id
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
      p_oipl_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_oipl_id = g_old_rec.oipl_id and
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
  l_parent_key_value4	number;
  l_parent_key_value5	number;
  l_parent_key_value6	number;
  l_parent_key_value7	number;
  --
  Cursor C_Sel1 Is
    select  t.dflt_enrt_det_rl,
	    t.mndtry_rl,
            t.postelcn_edit_rl,
            t.vrfy_fmly_mmbr_rl,
	    t.actl_prem_id,
	    t.pl_id,
	    t.opt_id
    from    ben_oipl_f t
    where   t.oipl_id = p_base_key_value
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
		    l_parent_key_value7;
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
	 p_base_table_name	=> 'ben_oipl_f',
	 p_base_key_column	=> 'oipl_id',
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
	 p_parent_table_name5	=> 'ben_actl_prem_f',
	 p_parent_key_column5	=> 'actl_prem_id',
	 p_parent_key_value5	=> l_parent_key_value5,
	 p_parent_table_name6	=> 'ben_pl_f',
	 p_parent_key_column6	=> 'pl_id',
	 p_parent_key_value6	=> l_parent_key_value6,
	 p_parent_table_name7	=> 'ben_opt_f',
	 p_parent_key_column7	=> 'opt_id',
	 p_parent_key_value7	=> l_parent_key_value7,
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
	 p_base_table_name	=> 'ben_oipl_f',
	 p_base_key_column	=> 'oipl_id',
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
	(p_base_table_name	=> 'ben_oipl_f',
	 p_base_key_column	=> 'oipl_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_oipl_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.oipl_id	  = p_base_key_value
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
	 p_oipl_id	 in  number,
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
	oipl_id,
	effective_start_date,
	effective_end_date,
	ivr_ident,
        url_ref_name,
	opt_id,
	business_group_id,
	pl_id,
	ordr_num,
	rqd_perd_enrt_nenrt_val,
	dflt_flag,
	actl_prem_id,
	mndtry_flag,
	oipl_stat_cd,
      pcp_dsgn_cd,
      pcp_dpnt_dsgn_cd,
	rqd_perd_enrt_nenrt_uom,
	elig_apls_flag,
	dflt_enrt_det_rl,
	trk_inelig_per_flag,
	drvbl_fctr_prtn_elig_flag,
	mndtry_rl,
	rqd_perd_enrt_nenrt_rl,
	dflt_enrt_cd,
	prtn_elig_ovrid_alwd_flag,
	drvbl_fctr_apls_rts_flag,
      per_cvrd_cd,
      postelcn_edit_rl,
      vrfy_fmly_mmbr_cd,
      vrfy_fmly_mmbr_rl,
      enrt_cd,
      enrt_rl,
      auto_enrt_flag,
      auto_enrt_mthd_rl,
      short_name,	/*FHR*/
      short_code,	/*FHR*/
            legislation_code,	/*FHR*/
            legislation_subgroup,	/*FHR*/
      hidden_flag,
      susp_if_ctfn_not_prvd_flag,
      ctfn_determine_cd,
	cop_attribute_category,
	cop_attribute1,
	cop_attribute2,
	cop_attribute3,
	cop_attribute4,
	cop_attribute5,
	cop_attribute6,
	cop_attribute7,
	cop_attribute8,
	cop_attribute9,
	cop_attribute10,
	cop_attribute11,
	cop_attribute12,
	cop_attribute13,
	cop_attribute14,
	cop_attribute15,
	cop_attribute16,
	cop_attribute17,
	cop_attribute18,
	cop_attribute19,
	cop_attribute20,
	cop_attribute21,
	cop_attribute22,
	cop_attribute23,
	cop_attribute24,
	cop_attribute25,
	cop_attribute26,
	cop_attribute27,
	cop_attribute28,
	cop_attribute29,
	cop_attribute30,
	object_version_number
    from    ben_oipl_f
    where   oipl_id         = p_oipl_id
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
                             p_argument       => 'oipl_id',
                             p_argument_value => p_oipl_id);
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
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_oipl_f',
	 p_base_key_column	   => 'oipl_id',
	 p_base_key_value 	   => p_oipl_id,
	 p_parent_table_name1      => 'ff_formulas_f',
	 p_parent_key_column1      => 'formula_id',
	 p_parent_key_value1       => g_old_rec.dflt_enrt_det_rl,
	 p_parent_table_name2      => 'ff_formulas_f',
	 p_parent_key_column2      => 'formula_id',
	 p_parent_key_value2       => g_old_rec.mndtry_rl,
	 p_parent_table_name3      => 'ff_formulas_f',
	 p_parent_key_column3      => 'formula_id',
	 p_parent_key_value3       => g_old_rec.postelcn_edit_rl,
	 p_parent_table_name4      => 'ff_formulas_f',
	 p_parent_key_column4      => 'formula_id',
	 p_parent_key_value4       => g_old_rec.vrfy_fmly_mmbr_rl,
	 p_parent_table_name5      => 'ben_actl_prem_f',
	 p_parent_key_column5      => 'actl_prem_id',
	 p_parent_key_value5       => g_old_rec.actl_prem_id,
	 p_parent_table_name6      => 'ben_pl_f',
	 p_parent_key_column6      => 'pl_id',
	 p_parent_key_value6       => g_old_rec.pl_id,
	 p_parent_table_name7      => 'ben_opt_f',
	 p_parent_key_column7      => 'opt_id',
	 p_parent_key_value7       => g_old_rec.opt_id,
	 p_child_table_name1       => 'ben_elig_to_prte_rsn_f',
	 p_child_key_column1       => 'elig_to_prte_rsn_id',
	 p_child_table_name2       => 'ben_ler_chg_oipl_enrt_f',
	 p_child_key_column2       => 'ler_chg_oipl_enrt_id',
	 p_child_table_name3       => 'ben_prtn_elig_f',
	 p_child_key_column3       => 'prtn_elig_id',
	 p_child_table_name4       => 'ben_cvg_amt_calc_mthd_f',
	 p_child_key_column4       => 'cvg_amt_calc_mthd_id',
	 p_child_table_name5       => 'ben_acty_base_rt_f',
	 p_child_key_column5       => 'acty_base_rt_id',
         p_enforce_foreign_locking => false, --true, Bug 3014342
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'ben_oipl_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'ben_oipl_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
        p_oipl_id                       in number,
        p_effective_start_date          in date,
        p_effective_end_date            in date,
        p_ivr_ident                     in varchar2,
        p_url_ref_name                  in varchar2,
        p_opt_id                        in number,
        p_business_group_id             in number,
        p_pl_id                         in number,
        p_ordr_num                      in number,
        p_rqd_perd_enrt_nenrt_val                      in number,
        p_dflt_flag                     in varchar2,
        p_actl_prem_id                  in number,
        p_mndtry_flag                   in varchar2,
        p_oipl_stat_cd                  in varchar2,
        p_pcp_dsgn_cd                   in varchar2,
        p_pcp_dpnt_dsgn_cd              in varchar2,
        p_rqd_perd_enrt_nenrt_uom       in varchar2,
        p_elig_apls_flag                in varchar2,
        p_dflt_enrt_det_rl              in number,
        p_trk_inelig_per_flag           in varchar2,
        p_drvbl_fctr_prtn_elig_flag     in varchar2,
        p_mndtry_rl                     in number,
        p_rqd_perd_enrt_nenrt_rl        in number,
        p_dflt_enrt_cd                  in varchar2,
        p_prtn_elig_ovrid_alwd_flag     in varchar2,
        p_drvbl_fctr_apls_rts_flag      in varchar2,
        p_per_cvrd_cd                   in varchar2,
        p_postelcn_edit_rl              in number,
        p_vrfy_fmly_mmbr_cd             in varchar2,
        p_vrfy_fmly_mmbr_rl             in number,
        p_enrt_cd                       in varchar2,
        p_enrt_rl                       in number,
        p_auto_enrt_flag                in varchar2,
        p_auto_enrt_mthd_rl             in number,
        p_short_name			in varchar2,	--FHR
        p_short_code			in varchar2,	--FHR
                p_legislation_code			in varchar2,
                p_legislation_subgroup			in varchar2,
        p_hidden_flag			in varchar2,
        p_susp_if_ctfn_not_prvd_flag    in  varchar2  default 'Y',
        p_ctfn_determine_cd             in  varchar2  default null,
        p_cop_attribute_category        in varchar2,
        p_cop_attribute1                in varchar2,
        p_cop_attribute2                in varchar2,
        p_cop_attribute3                in varchar2,
        p_cop_attribute4                in varchar2,
        p_cop_attribute5                in varchar2,
        p_cop_attribute6                in varchar2,
        p_cop_attribute7                in varchar2,
        p_cop_attribute8                in varchar2,
        p_cop_attribute9                in varchar2,
        p_cop_attribute10               in varchar2,
        p_cop_attribute11               in varchar2,
        p_cop_attribute12               in varchar2,
        p_cop_attribute13               in varchar2,
        p_cop_attribute14               in varchar2,
        p_cop_attribute15               in varchar2,
        p_cop_attribute16               in varchar2,
        p_cop_attribute17               in varchar2,
        p_cop_attribute18               in varchar2,
        p_cop_attribute19               in varchar2,
        p_cop_attribute20               in varchar2,
        p_cop_attribute21               in varchar2,
        p_cop_attribute22               in varchar2,
        p_cop_attribute23               in varchar2,
        p_cop_attribute24               in varchar2,
        p_cop_attribute25               in varchar2,
        p_cop_attribute26               in varchar2,
        p_cop_attribute27               in varchar2,
        p_cop_attribute28               in varchar2,
        p_cop_attribute29               in varchar2,
        p_cop_attribute30               in varchar2,
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
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.ivr_ident                        := p_ivr_ident;
  l_rec.url_ref_name                     := p_url_ref_name;
  l_rec.opt_id                           := p_opt_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.ordr_num                         := p_ordr_num;
  l_rec.rqd_perd_enrt_nenrt_val          := p_rqd_perd_enrt_nenrt_val;
  l_rec.actl_prem_id                     := p_actl_prem_id;
  l_rec.dflt_flag                        := p_dflt_flag;
  l_rec.mndtry_flag                      := p_mndtry_flag;
  l_rec.oipl_stat_cd                     := p_oipl_stat_cd;
  l_rec.pcp_dsgn_cd                      := p_pcp_dsgn_cd;
  l_rec.pcp_dpnt_dsgn_cd                 := p_pcp_dpnt_dsgn_cd;
  l_rec.rqd_perd_enrt_nenrt_uom          := p_rqd_perd_enrt_nenrt_uom;
  l_rec.elig_apls_flag                   := p_elig_apls_flag;
  l_rec.dflt_enrt_det_rl                 := p_dflt_enrt_det_rl;
  l_rec.trk_inelig_per_flag              := p_trk_inelig_per_flag;
  l_rec.drvbl_fctr_prtn_elig_flag         := p_drvbl_fctr_prtn_elig_flag;
  l_rec.mndtry_rl                        := p_mndtry_rl;
  l_rec.rqd_perd_enrt_nenrt_rl           := p_rqd_perd_enrt_nenrt_rl;
  l_rec.dflt_enrt_cd                     := p_dflt_enrt_cd;
  l_rec.prtn_elig_ovrid_alwd_flag        := p_prtn_elig_ovrid_alwd_flag;
  l_rec.drvbl_fctr_apls_rts_flag          := p_drvbl_fctr_apls_rts_flag;
  l_rec.per_cvrd_cd                      := p_per_cvrd_cd;
  l_rec.postelcn_edit_rl                 := p_postelcn_edit_rl;
  l_rec.vrfy_fmly_mmbr_cd                := p_vrfy_fmly_mmbr_cd;
  l_rec.vrfy_fmly_mmbr_rl                := p_vrfy_fmly_mmbr_rl;
  l_rec.enrt_cd                          := p_enrt_cd;
  l_rec.enrt_rl                          := p_enrt_rl;
  l_rec.auto_enrt_flag                   := p_auto_enrt_flag;
  l_rec.auto_enrt_mthd_rl                := p_auto_enrt_mthd_rl;
  l_rec.short_name			 := p_short_name;		--FHR
  l_rec.short_code			 := p_short_code;		--FHR
    l_rec.legislation_code			 := p_legislation_code;
    l_rec.legislation_subgroup			 := p_legislation_subgroup;
  l_rec.hidden_flag			 := p_hidden_flag;
  l_rec.susp_if_ctfn_not_prvd_flag       :=  p_susp_if_ctfn_not_prvd_flag;
  l_rec.ctfn_determine_cd                :=  p_ctfn_determine_cd;
  l_rec.cop_attribute_category           := p_cop_attribute_category;
  l_rec.cop_attribute1                   := p_cop_attribute1;
  l_rec.cop_attribute2                   := p_cop_attribute2;
  l_rec.cop_attribute3                   := p_cop_attribute3;
  l_rec.cop_attribute4                   := p_cop_attribute4;
  l_rec.cop_attribute5                   := p_cop_attribute5;
  l_rec.cop_attribute6                   := p_cop_attribute6;
  l_rec.cop_attribute7                   := p_cop_attribute7;
  l_rec.cop_attribute8                   := p_cop_attribute8;
  l_rec.cop_attribute9                   := p_cop_attribute9;
  l_rec.cop_attribute10                  := p_cop_attribute10;
  l_rec.cop_attribute11                  := p_cop_attribute11;
  l_rec.cop_attribute12                  := p_cop_attribute12;
  l_rec.cop_attribute13                  := p_cop_attribute13;
  l_rec.cop_attribute14                  := p_cop_attribute14;
  l_rec.cop_attribute15                  := p_cop_attribute15;
  l_rec.cop_attribute16                  := p_cop_attribute16;
  l_rec.cop_attribute17                  := p_cop_attribute17;
  l_rec.cop_attribute18                  := p_cop_attribute18;
  l_rec.cop_attribute19                  := p_cop_attribute19;
  l_rec.cop_attribute20                  := p_cop_attribute20;
  l_rec.cop_attribute21                  := p_cop_attribute21;
  l_rec.cop_attribute22                  := p_cop_attribute22;
  l_rec.cop_attribute23                  := p_cop_attribute23;
  l_rec.cop_attribute24                  := p_cop_attribute24;
  l_rec.cop_attribute25                  := p_cop_attribute25;
  l_rec.cop_attribute26                  := p_cop_attribute26;
  l_rec.cop_attribute27                  := p_cop_attribute27;
  l_rec.cop_attribute28                  := p_cop_attribute28;
  l_rec.cop_attribute29                  := p_cop_attribute29;
  l_rec.cop_attribute30                  := p_cop_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_cop_shd;

/
