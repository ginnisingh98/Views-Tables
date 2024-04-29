--------------------------------------------------------
--  DDL for Package Body BEN_CPP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPP_SHD" as
/* $Header: becpprhi.pkb 120.0 2005/05/28 01:16:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cpp_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_PLIP_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PLIP_PK') Then
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
   p_plip_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	plip_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	pgm_id,
	pl_id,
	cmbn_plip_id,
	dflt_flag,
	plip_stat_cd,
	dflt_enrt_cd,
	dflt_enrt_det_rl,
	ordr_num,
        alws_unrstrctd_enrt_flag,
        auto_enrt_mthd_rl,
        enrt_cd,
        enrt_mthd_cd,
        enrt_rl,
	ivr_ident,
        url_ref_name,
        enrt_cvg_strt_dt_cd,
        enrt_cvg_strt_dt_rl,
        enrt_cvg_end_dt_cd,
        enrt_cvg_end_dt_rl,
        rt_strt_dt_cd,
        rt_strt_dt_rl,
        rt_end_dt_cd,
        rt_end_dt_rl,
        drvbl_fctr_apls_rts_flag,
        drvbl_fctr_prtn_elig_flag,
        elig_apls_flag,
        prtn_elig_ovrid_alwd_flag,
        trk_inelig_per_flag,
        postelcn_edit_rl,
 	dflt_to_asn_pndg_ctfn_cd,
        dflt_to_asn_pndg_ctfn_rl,
        mn_cvg_amt,
        mn_cvg_rl,
        mx_cvg_alwd_amt,
	mx_cvg_incr_alwd_amt,
	mx_cvg_incr_wcf_alwd_amt,
	mx_cvg_mlt_incr_num,
	mx_cvg_mlt_incr_wcf_num,
	mx_cvg_rl,
	mx_cvg_wcfn_amt,
	mx_cvg_wcfn_mlt_num,
	no_mn_cvg_amt_apls_flag,
	no_mn_cvg_incr_apls_flag,
	no_mx_cvg_amt_apls_flag,
	no_mx_cvg_incr_apls_flag,
	unsspnd_enrt_cd,
	prort_prtl_yr_cvg_rstrn_cd,
	prort_prtl_yr_cvg_rstrn_rl,
        cvg_incr_r_decr_only_cd,
        bnft_or_option_rstrctn_cd,
        per_cvrd_cd,
        short_name,
        short_code,
                legislation_code,
                legislation_subgroup,
        vrfy_fmly_mmbr_rl,
        vrfy_fmly_mmbr_cd,
        use_csd_rsd_prccng_cd,
	cpp_attribute_category,
	cpp_attribute1,
	cpp_attribute2,
	cpp_attribute3,
	cpp_attribute4,
	cpp_attribute5,
	cpp_attribute6,
	cpp_attribute7,
	cpp_attribute8,
	cpp_attribute9,
	cpp_attribute10,
	cpp_attribute11,
	cpp_attribute12,
	cpp_attribute13,
	cpp_attribute14,
	cpp_attribute15,
	cpp_attribute16,
	cpp_attribute17,
	cpp_attribute18,
	cpp_attribute19,
	cpp_attribute20,
	cpp_attribute21,
	cpp_attribute22,
	cpp_attribute23,
	cpp_attribute24,
	cpp_attribute25,
	cpp_attribute26,
	cpp_attribute27,
	cpp_attribute28,
	cpp_attribute29,
	cpp_attribute30,
	object_version_number
    from	ben_plip_f
    where	plip_id = p_plip_id
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
      p_plip_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_plip_id = g_old_rec.plip_id and
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
  --
  Cursor C_Sel1 Is
    select  t.dflt_enrt_det_rl,
	    t.pl_id,
	    t.pgm_id,
	    t.cmbn_plip_id
    from    ben_plip_f t
    where   t.plip_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1,
		    l_parent_key_value2,
		    l_parent_key_value3,
		    l_parent_key_value4;
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
	 p_base_table_name	=> 'ben_plip_f',
	 p_base_key_column	=> 'plip_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ff_formulas_f',
	 p_parent_key_column1	=> 'formula_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_parent_table_name2	=> 'ben_pl_f',
	 p_parent_key_column2	=> 'pl_id',
	 p_parent_key_value2	=> l_parent_key_value2,
	 p_parent_table_name3	=> 'ben_pgm_f',
	 p_parent_key_column3	=> 'pgm_id',
	 p_parent_key_value3	=> l_parent_key_value3,
	 p_parent_table_name4	=> 'ben_cmbn_plip_f',
	 p_parent_key_column4	=> 'cmbn_plip_id',
	 p_parent_key_value4	=> l_parent_key_value4,
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
	 p_base_table_name	=> 'ben_plip_f',
	 p_base_key_column	=> 'plip_id',
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
	(p_base_table_name	=> 'ben_plip_f',
	 p_base_key_column	=> 'plip_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_plip_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.plip_id	  = p_base_key_value
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
	 p_plip_id	 in  number,
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
	plip_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	pgm_id,
	pl_id,
	cmbn_plip_id,
	dflt_flag,
	plip_stat_cd,
	dflt_enrt_cd,
	dflt_enrt_det_rl,
	ordr_num,
        alws_unrstrctd_enrt_flag,
        auto_enrt_mthd_rl,
        enrt_cd,
        enrt_mthd_cd,
        enrt_rl,
	ivr_ident,
        url_ref_name,
        enrt_cvg_strt_dt_cd,
        enrt_cvg_strt_dt_rl,
        enrt_cvg_end_dt_cd,
        enrt_cvg_end_dt_rl,
        rt_strt_dt_cd,
        rt_strt_dt_rl,
        rt_end_dt_cd,
        rt_end_dt_rl,
        drvbl_fctr_apls_rts_flag,
        drvbl_fctr_prtn_elig_flag,
        elig_apls_flag,
        prtn_elig_ovrid_alwd_flag,
        trk_inelig_per_flag,
        postelcn_edit_rl,
 	dflt_to_asn_pndg_ctfn_cd,
        dflt_to_asn_pndg_ctfn_rl,
        mn_cvg_amt,
        mn_cvg_rl,
        mx_cvg_alwd_amt,
	mx_cvg_incr_alwd_amt,
	mx_cvg_incr_wcf_alwd_amt,
	mx_cvg_mlt_incr_num,
	mx_cvg_mlt_incr_wcf_num,
	mx_cvg_rl,
	mx_cvg_wcfn_amt,
	mx_cvg_wcfn_mlt_num,
	no_mn_cvg_amt_apls_flag,
	no_mn_cvg_incr_apls_flag,
	no_mx_cvg_amt_apls_flag,
	no_mx_cvg_incr_apls_flag,
	unsspnd_enrt_cd,
	prort_prtl_yr_cvg_rstrn_cd,
	prort_prtl_yr_cvg_rstrn_rl,
        cvg_incr_r_decr_only_cd,
        bnft_or_option_rstrctn_cd,
        per_cvrd_cd,
        short_name,
        short_code,
                legislation_code,
                legislation_subgroup,
        vrfy_fmly_mmbr_rl,
        vrfy_fmly_mmbr_cd,
        use_csd_rsd_prccng_cd,
        cpp_attribute_category,
	cpp_attribute1,
	cpp_attribute2,
	cpp_attribute3,
	cpp_attribute4,
	cpp_attribute5,
	cpp_attribute6,
	cpp_attribute7,
	cpp_attribute8,
	cpp_attribute9,
	cpp_attribute10,
	cpp_attribute11,
	cpp_attribute12,
	cpp_attribute13,
	cpp_attribute14,
	cpp_attribute15,
	cpp_attribute16,
	cpp_attribute17,
	cpp_attribute18,
	cpp_attribute19,
	cpp_attribute20,
	cpp_attribute21,
	cpp_attribute22,
	cpp_attribute23,
	cpp_attribute24,
	cpp_attribute25,
	cpp_attribute26,
	cpp_attribute27,
	cpp_attribute28,
	cpp_attribute29,
	cpp_attribute30,
	object_version_number
    from    ben_plip_f
    where   plip_id         = p_plip_id
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
                             p_argument       => 'plip_id',
                             p_argument_value => p_plip_id);
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
	 p_base_table_name	   => 'ben_plip_f',
	 p_base_key_column	   => 'plip_id',
	 p_base_key_value 	   => p_plip_id,
	 p_parent_table_name1      => 'ff_formulas_f',
	 p_parent_key_column1      => 'formula_id',
	 p_parent_key_value1       => g_old_rec.dflt_enrt_det_rl,
	 p_parent_table_name2      => 'ben_pl_f',
	 p_parent_key_column2      => 'pl_id',
	 p_parent_key_value2       => g_old_rec.pl_id,
	 p_parent_table_name3      => 'ben_pgm_f',
	 p_parent_key_column3      => 'pgm_id',
	 p_parent_key_value3       => g_old_rec.pgm_id,
	 p_parent_table_name4      => 'ben_cmbn_plip_f',
	 p_parent_key_column4      => 'cmbn_plip_id',
	 p_parent_key_value4       => g_old_rec.cmbn_plip_id,
	 p_child_table_name1       => 'ben_acty_base_rt_f',
	 p_child_key_column1       => 'acty_base_rt_id',
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
    fnd_message.set_token('TABLE_NAME', 'ben_plip_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_plip_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_plip_id                       in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_business_group_id             in number,
	p_pgm_id                        in number,
	p_pl_id                         in number,
	p_cmbn_plip_id                  in number,
	p_dflt_flag                     in varchar2,
	p_plip_stat_cd                  in varchar2,
	p_dflt_enrt_cd                  in varchar2,
	p_dflt_enrt_det_rl              in number,
	p_ordr_num                      in number,
        p_alws_unrstrctd_enrt_flag      in varchar2,
        p_auto_enrt_mthd_rl             in number,
        p_enrt_cd                       in varchar2,
        p_enrt_mthd_cd                  in varchar2,
        p_enrt_rl                       in number,
	p_ivr_ident                     in varchar2,
        p_url_ref_name                  in varchar2,
        p_enrt_cvg_strt_dt_cd           in varchar2,
        p_enrt_cvg_strt_dt_rl           in number,
        p_enrt_cvg_end_dt_cd            in varchar2,
        p_enrt_cvg_end_dt_rl            in number,
        p_rt_strt_dt_cd                 in varchar2,
        p_rt_strt_dt_rl                 in number,
        p_rt_end_dt_cd                  in varchar2,
        p_rt_end_dt_rl                  in number,
        p_drvbl_fctr_apls_rts_flag      in varchar2,
        p_drvbl_fctr_prtn_elig_flag     in varchar2,
        p_elig_apls_flag                in varchar2,
        p_prtn_elig_ovrid_alwd_flag     in varchar2,
        p_trk_inelig_per_flag           in varchar2,
        p_postelcn_edit_rl              in number,
        p_dflt_to_asn_pndg_ctfn_cd      in varchar2,
        p_dflt_to_asn_pndg_ctfn_rl      in number,
        p_mn_cvg_amt                    in number,
        p_mn_cvg_rl                     in number,
        p_mx_cvg_alwd_amt               in number,
        p_mx_cvg_incr_alwd_amt          in number,
        p_mx_cvg_incr_wcf_alwd_amt      in number,
        p_mx_cvg_mlt_incr_num           in number,
        p_mx_cvg_mlt_incr_wcf_num       in number,
        p_mx_cvg_rl                     in number,
        p_mx_cvg_wcfn_amt               in number,
        p_mx_cvg_wcfn_mlt_num           in number,
        p_no_mn_cvg_amt_apls_flag       in varchar2,
        p_no_mn_cvg_incr_apls_flag      in varchar2,
        p_no_mx_cvg_amt_apls_flag       in varchar2,
        p_no_mx_cvg_incr_apls_flag      in varchar2,
        p_unsspnd_enrt_cd               in varchar2,
        p_prort_prtl_yr_cvg_rstrn_cd    in varchar2,
        p_prort_prtl_yr_cvg_rstrn_rl    in number,
        p_cvg_incr_r_decr_only_cd       in varchar2,
        p_bnft_or_option_rstrctn_cd     in varchar2,
        p_per_cvrd_cd                   in varchar2,
        p_short_name                   in varchar2,
        p_short_code                   in varchar2,
                p_legislation_code                   in varchar2,
                p_legislation_subgroup                   in varchar2,
        P_vrfy_fmly_mmbr_rl             in number,
        P_vrfy_fmly_mmbr_cd             in varchar2,
        P_use_csd_rsd_prccng_cd         in varchar2,
        p_cpp_attribute_category        in varchar2,
	p_cpp_attribute1                in varchar2,
	p_cpp_attribute2                in varchar2,
	p_cpp_attribute3                in varchar2,
	p_cpp_attribute4                in varchar2,
	p_cpp_attribute5                in varchar2,
	p_cpp_attribute6                in varchar2,
	p_cpp_attribute7                in varchar2,
	p_cpp_attribute8                in varchar2,
	p_cpp_attribute9                in varchar2,
	p_cpp_attribute10               in varchar2,
	p_cpp_attribute11               in varchar2,
	p_cpp_attribute12               in varchar2,
	p_cpp_attribute13               in varchar2,
	p_cpp_attribute14               in varchar2,
	p_cpp_attribute15               in varchar2,
	p_cpp_attribute16               in varchar2,
	p_cpp_attribute17               in varchar2,
	p_cpp_attribute18               in varchar2,
	p_cpp_attribute19               in varchar2,
	p_cpp_attribute20               in varchar2,
	p_cpp_attribute21               in varchar2,
	p_cpp_attribute22               in varchar2,
	p_cpp_attribute23               in varchar2,
	p_cpp_attribute24               in varchar2,
	p_cpp_attribute25               in varchar2,
	p_cpp_attribute26               in varchar2,
	p_cpp_attribute27               in varchar2,
	p_cpp_attribute28               in varchar2,
	p_cpp_attribute29               in varchar2,
	p_cpp_attribute30               in varchar2,
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
  l_rec.plip_id                          := p_plip_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.cmbn_plip_id                     := p_cmbn_plip_id;
  l_rec.dflt_flag                        := p_dflt_flag;
  l_rec.plip_stat_cd                     := p_plip_stat_cd;
  l_rec.dflt_enrt_cd                     := p_dflt_enrt_cd;
  l_rec.dflt_enrt_det_rl                 := p_dflt_enrt_det_rl;
  l_rec.ordr_num                         := p_ordr_num;
  l_rec.alws_unrstrctd_enrt_flag         := p_alws_unrstrctd_enrt_flag;
  l_rec.auto_enrt_mthd_rl                := p_auto_enrt_mthd_rl;
  l_rec.enrt_cd                          := p_enrt_cd;
  l_rec.enrt_mthd_cd                     := p_enrt_mthd_cd;
  l_rec.enrt_rl                          := p_enrt_rl;
  l_rec.ivr_ident                        := p_ivr_ident;
  l_rec.url_ref_name                     := p_url_ref_name;
  l_rec.enrt_cvg_strt_dt_cd              := p_enrt_cvg_strt_dt_cd;
  l_rec.enrt_cvg_strt_dt_rl              := p_enrt_cvg_strt_dt_rl;
  l_rec.enrt_cvg_end_dt_cd               := p_enrt_cvg_end_dt_cd;
  l_rec.enrt_cvg_end_dt_rl               := p_enrt_cvg_end_dt_rl;
  l_rec.rt_strt_dt_cd                    := p_rt_strt_dt_cd;
  l_rec.rt_strt_dt_rl                    := p_rt_strt_dt_rl;
  l_rec.rt_end_dt_cd                     := p_rt_end_dt_cd;
  l_rec.rt_end_dt_rl                     := p_rt_end_dt_rl;
  l_rec.drvbl_fctr_apls_rts_flag         := p_drvbl_fctr_apls_rts_flag;
  l_rec.drvbl_fctr_prtn_elig_flag        := p_drvbl_fctr_prtn_elig_flag;
  l_rec.elig_apls_flag                   := p_elig_apls_flag;
  l_rec.prtn_elig_ovrid_alwd_flag        := p_prtn_elig_ovrid_alwd_flag;
  l_rec.trk_inelig_per_flag              := p_trk_inelig_per_flag;
  l_rec.postelcn_edit_rl                 := p_postelcn_edit_rl;
  l_rec.dflt_to_asn_pndg_ctfn_cd         := p_dflt_to_asn_pndg_ctfn_cd;
  l_rec.dflt_to_asn_pndg_ctfn_rl         := p_dflt_to_asn_pndg_ctfn_rl;
  l_rec.mn_cvg_amt			 := p_mn_cvg_amt;
  l_rec.mn_cvg_rl			 := p_mn_cvg_rl;
  l_rec.mx_cvg_alwd_amt			 := p_mx_cvg_alwd_amt;
  l_rec.mx_cvg_incr_alwd_amt 		 := p_mx_cvg_incr_alwd_amt;
  l_rec.mx_cvg_incr_wcf_alwd_amt	 := p_mx_cvg_incr_wcf_alwd_amt;
  l_rec.mx_cvg_mlt_incr_num		 := p_mx_cvg_mlt_incr_num;
  l_rec.mx_cvg_mlt_incr_wcf_num		 := p_mx_cvg_mlt_incr_wcf_num;
  l_rec.mx_cvg_rl  			 := p_mx_cvg_rl;
  l_rec.mx_cvg_wcfn_amt 		 := p_mx_cvg_wcfn_amt;
  l_rec.mx_cvg_wcfn_mlt_num		 := p_mx_cvg_wcfn_mlt_num;
  l_rec.no_mn_cvg_amt_apls_flag		 := p_no_mn_cvg_amt_apls_flag;
  l_rec.no_mn_cvg_incr_apls_flag	 := p_no_mn_cvg_incr_apls_flag;
  l_rec.no_mx_cvg_amt_apls_flag		 := p_no_mx_cvg_amt_apls_flag;
  l_rec.no_mx_cvg_incr_apls_flag	 := p_no_mx_cvg_incr_apls_flag;
  l_rec.unsspnd_enrt_cd 	         := p_unsspnd_enrt_cd;
  l_rec.prort_prtl_yr_cvg_rstrn_cd       := p_prort_prtl_yr_cvg_rstrn_cd;
  l_rec.prort_prtl_yr_cvg_rstrn_rl       := p_prort_prtl_yr_cvg_rstrn_rl;
  l_rec.cvg_incr_r_decr_only_cd          := p_cvg_incr_r_decr_only_cd;
  l_rec.bnft_or_option_rstrctn_cd        := p_bnft_or_option_rstrctn_cd;
  l_rec.per_cvrd_cd                      := p_per_cvrd_cd ;
  l_rec.short_name                      := p_short_name ;
  l_rec.short_code                      := p_short_code ;
    l_rec.legislation_code                      := p_legislation_code ;
    l_rec.legislation_subgroup                      := p_legislation_subgroup ;
  l_rec.vrfy_fmly_mmbr_rl                := P_vrfy_fmly_mmbr_rl ;
  l_rec.vrfy_fmly_mmbr_cd                := P_vrfy_fmly_mmbr_cd ;
  l_rec.use_csd_rsd_prccng_cd            := P_use_csd_rsd_prccng_cd ;
  l_rec.cpp_attribute_category           := p_cpp_attribute_category;
  l_rec.cpp_attribute1                   := p_cpp_attribute1;
  l_rec.cpp_attribute2                   := p_cpp_attribute2;
  l_rec.cpp_attribute3                   := p_cpp_attribute3;
  l_rec.cpp_attribute4                   := p_cpp_attribute4;
  l_rec.cpp_attribute5                   := p_cpp_attribute5;
  l_rec.cpp_attribute6                   := p_cpp_attribute6;
  l_rec.cpp_attribute7                   := p_cpp_attribute7;
  l_rec.cpp_attribute8                   := p_cpp_attribute8;
  l_rec.cpp_attribute9                   := p_cpp_attribute9;
  l_rec.cpp_attribute10                  := p_cpp_attribute10;
  l_rec.cpp_attribute11                  := p_cpp_attribute11;
  l_rec.cpp_attribute12                  := p_cpp_attribute12;
  l_rec.cpp_attribute13                  := p_cpp_attribute13;
  l_rec.cpp_attribute14                  := p_cpp_attribute14;
  l_rec.cpp_attribute15                  := p_cpp_attribute15;
  l_rec.cpp_attribute16                  := p_cpp_attribute16;
  l_rec.cpp_attribute17                  := p_cpp_attribute17;
  l_rec.cpp_attribute18                  := p_cpp_attribute18;
  l_rec.cpp_attribute19                  := p_cpp_attribute19;
  l_rec.cpp_attribute20                  := p_cpp_attribute20;
  l_rec.cpp_attribute21                  := p_cpp_attribute21;
  l_rec.cpp_attribute22                  := p_cpp_attribute22;
  l_rec.cpp_attribute23                  := p_cpp_attribute23;
  l_rec.cpp_attribute24                  := p_cpp_attribute24;
  l_rec.cpp_attribute25                  := p_cpp_attribute25;
  l_rec.cpp_attribute26                  := p_cpp_attribute26;
  l_rec.cpp_attribute27                  := p_cpp_attribute27;
  l_rec.cpp_attribute28                  := p_cpp_attribute28;
  l_rec.cpp_attribute29                  := p_cpp_attribute29;
  l_rec.cpp_attribute30                  := p_cpp_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_cpp_shd;

/
