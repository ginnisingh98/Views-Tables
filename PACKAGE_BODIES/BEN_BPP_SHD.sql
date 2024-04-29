--------------------------------------------------------
--  DDL for Package Body BEN_BPP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BPP_SHD" as
/* $Header: bebpprhi.pkb 115.13 2002/12/22 20:25:09 pabodla ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bpp_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_BNFT_PRVDR_POOL_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_BNFT_PRVDR_POOL_PK') Then
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
   p_bnft_prvdr_pool_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	bnft_prvdr_pool_id,
	effective_start_date,
	effective_end_date,
	name,
	pgm_pool_flag,
	excs_alwys_fftd_flag,
	use_for_pgm_pool_flag,
	pct_rndg_cd,
	pct_rndg_rl,
	val_rndg_cd,
	val_rndg_rl,
	dflt_excs_trtmt_cd,
	dflt_excs_trtmt_rl,
	rlovr_rstrcn_cd,
	no_mn_dstrbl_pct_flag,
	no_mn_dstrbl_val_flag,
	no_mx_dstrbl_pct_flag,
	no_mx_dstrbl_val_flag,
        auto_alct_excs_flag,
        alws_ngtv_crs_flag ,
        uses_net_crs_mthd_flag,
        mx_dfcit_pct_pool_crs_num ,
        mx_dfcit_pct_comp_num ,
        comp_lvl_fctr_id,
	mn_dstrbl_pct_num,
	mn_dstrbl_val,
	mx_dstrbl_pct_num,
	mx_dstrbl_val,
	excs_trtmt_cd,
	ptip_id,
	plip_id,
	pgm_id,
	oiplip_id,
	cmbn_plip_id,
	cmbn_ptip_id,
	cmbn_ptip_opt_id,
	business_group_id,
	bpp_attribute_category,
	bpp_attribute1,
	bpp_attribute2,
	bpp_attribute3,
	bpp_attribute4,
	bpp_attribute5,
	bpp_attribute6,
	bpp_attribute7,
	bpp_attribute8,
	bpp_attribute9,
	bpp_attribute10,
	bpp_attribute11,
	bpp_attribute12,
	bpp_attribute13,
	bpp_attribute14,
	bpp_attribute15,
	bpp_attribute16,
	bpp_attribute17,
	bpp_attribute18,
	bpp_attribute19,
	bpp_attribute20,
	bpp_attribute21,
	bpp_attribute22,
	bpp_attribute23,
	bpp_attribute24,
	bpp_attribute25,
	bpp_attribute26,
	bpp_attribute27,
	bpp_attribute28,
	bpp_attribute29,
	bpp_attribute30,
	object_version_number
    from	ben_bnft_prvdr_pool_f
    where	bnft_prvdr_pool_id = p_bnft_prvdr_pool_id
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
      p_bnft_prvdr_pool_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_bnft_prvdr_pool_id = g_old_rec.bnft_prvdr_pool_id and
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
  --
  Cursor C_Sel1 Is
    select  t.pgm_id,
	    t.plip_id,
	    t.ptip_id,
	    t.cmbn_plip_id,
	    t.cmbn_ptip_id,
	    t.cmbn_ptip_opt_id,
            t.oiplip_id
    from    ben_bnft_prvdr_pool_f t
    where   t.bnft_prvdr_pool_id = p_base_key_value
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
	 p_base_table_name	=> 'ben_bnft_prvdr_pool_f',
	 p_base_key_column	=> 'bnft_prvdr_pool_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ben_pgm_f',
	 p_parent_key_column1	=> 'pgm_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_parent_table_name2	=> 'ben_plip_f',
	 p_parent_key_column2	=> 'plip_id',
	 p_parent_key_value2	=> l_parent_key_value2,
	 p_parent_table_name3	=> 'ben_ptip_f',
	 p_parent_key_column3	=> 'ptip_id',
	 p_parent_key_value3	=> l_parent_key_value3,
	 p_parent_table_name4	=> 'ben_cmbn_plip_f',
	 p_parent_key_column4	=> 'cmbn_plip_id',
	 p_parent_key_value4	=> l_parent_key_value4,
	 p_parent_table_name5	=> 'ben_cmbn_ptip_f',
	 p_parent_key_column5	=> 'cmbn_ptip_id',
	 p_parent_key_value5	=> l_parent_key_value5,
	 p_parent_table_name6	=> 'ben_cmbn_ptip_opt_f',
	 p_parent_key_column6	=> 'cmbn_ptip_opt_id',
	 p_parent_key_value6	=> l_parent_key_value6,
	 p_parent_table_name7	=> 'ben_oiplip_f',
	 p_parent_key_column7	=> 'oiplip_id',
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
	 p_base_table_name	=> 'ben_bnft_prvdr_pool_f',
	 p_base_key_column	=> 'bnft_prvdr_pool_id',
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
	(p_base_table_name	=> 'ben_bnft_prvdr_pool_f',
	 p_base_key_column	=> 'bnft_prvdr_pool_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_bnft_prvdr_pool_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.bnft_prvdr_pool_id	  = p_base_key_value
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
	 p_bnft_prvdr_pool_id	 in  number,
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
	bnft_prvdr_pool_id,
	effective_start_date,
	effective_end_date,
	name,
	pgm_pool_flag,
	excs_alwys_fftd_flag,
	use_for_pgm_pool_flag,
	pct_rndg_cd,
	pct_rndg_rl,
	val_rndg_cd,
	val_rndg_rl,
	dflt_excs_trtmt_cd,
	dflt_excs_trtmt_rl,
	rlovr_rstrcn_cd,
	no_mn_dstrbl_pct_flag,
	no_mn_dstrbl_val_flag,
	no_mx_dstrbl_pct_flag,
	no_mx_dstrbl_val_flag,
        auto_alct_excs_flag,
        alws_ngtv_crs_flag ,
        uses_net_crs_mthd_flag ,
        mx_dfcit_pct_pool_crs_num,
        mx_dfcit_pct_comp_num,
        comp_lvl_fctr_id,
	mn_dstrbl_pct_num,
	mn_dstrbl_val,
	mx_dstrbl_pct_num,
	mx_dstrbl_val,
	excs_trtmt_cd,
	ptip_id,
	plip_id,
	pgm_id,
	oiplip_id,
	cmbn_plip_id,
	cmbn_ptip_id,
	cmbn_ptip_opt_id,
	business_group_id,
	bpp_attribute_category,
	bpp_attribute1,
	bpp_attribute2,
	bpp_attribute3,
	bpp_attribute4,
	bpp_attribute5,
	bpp_attribute6,
	bpp_attribute7,
	bpp_attribute8,
	bpp_attribute9,
	bpp_attribute10,
	bpp_attribute11,
	bpp_attribute12,
	bpp_attribute13,
	bpp_attribute14,
	bpp_attribute15,
	bpp_attribute16,
	bpp_attribute17,
	bpp_attribute18,
	bpp_attribute19,
	bpp_attribute20,
	bpp_attribute21,
	bpp_attribute22,
	bpp_attribute23,
	bpp_attribute24,
	bpp_attribute25,
	bpp_attribute26,
	bpp_attribute27,
	bpp_attribute28,
	bpp_attribute29,
	bpp_attribute30,
	object_version_number
    from    ben_bnft_prvdr_pool_f
    where   bnft_prvdr_pool_id         = p_bnft_prvdr_pool_id
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
                             p_argument       => 'bnft_prvdr_pool_id',
                             p_argument_value => p_bnft_prvdr_pool_id);
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
	 p_base_table_name	   => 'ben_bnft_prvdr_pool_f',
	 p_base_key_column	   => 'bnft_prvdr_pool_id',
	 p_base_key_value 	   => p_bnft_prvdr_pool_id,
	 p_parent_table_name1      => 'ben_pgm_f',
	 p_parent_key_column1      => 'pgm_id',
	 p_parent_key_value1       => g_old_rec.pgm_id,
	 p_parent_table_name2      => 'ben_plip_f',
	 p_parent_key_column2      => 'plip_id',
	 p_parent_key_value2       => g_old_rec.plip_id,
	 p_parent_table_name3      => 'ben_ptip_f',
	 p_parent_key_column3      => 'ptip_id',
	 p_parent_key_value3       => g_old_rec.ptip_id,
	 p_parent_table_name4      => 'ben_cmbn_plip_f',
	 p_parent_key_column4      => 'cmbn_plip_id',
	 p_parent_key_value4       => g_old_rec.cmbn_plip_id,
	 p_parent_table_name5      => 'ben_cmbn_ptip_f',
	 p_parent_key_column5      => 'cmbn_ptip_id',
	 p_parent_key_value5       => g_old_rec.cmbn_ptip_id,
	 p_parent_table_name6      => 'ben_cmbn_ptip_opt_f',
	 p_parent_key_column6      => 'cmbn_ptip_opt_id',
	 p_parent_key_value6       => g_old_rec.cmbn_ptip_opt_id,
	 p_parent_table_name7      => 'ben_oiplip_f',
	 p_parent_key_column7      => 'oiplip_id',
	 p_parent_key_value7       => g_old_rec.oiplip_id,
	 p_child_table_name1       => 'ben_aplcn_to_bnft_pool_f',
	 p_child_key_column1       => 'aplcn_to_bnft_pool_id',
	 p_child_table_name2       => 'ben_bnft_pool_rlovr_rqmt_f',
	 p_child_key_column2       => 'bnft_pool_rlovr_rqmt_id',
	 p_child_table_name3       => 'ben_bnft_prvdd_ldgr_f',
	 p_child_key_column3       => 'bnft_prvdd_ldgr_id',
         p_enforce_foreign_locking => false, -- true,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);

 	 -- bug fix 2666119 - changed p_enforce_foreign_locking from true
 	 -- to false, to avoid locking problems. child row exists check
 	 -- is present in dt_delete_validate
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
    fnd_message.set_token('TABLE_NAME', 'ben_bnft_prvdr_pool_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_bnft_prvdr_pool_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_bnft_prvdr_pool_id            in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_name                          in varchar2,
	p_pgm_pool_flag                 in varchar2,
	p_excs_alwys_fftd_flag          in varchar2,
	p_use_for_pgm_pool_flag         in varchar2,
	p_pct_rndg_cd                   in varchar2,
	p_pct_rndg_rl                   in number,
	p_val_rndg_cd                   in varchar2,
	p_val_rndg_rl                   in number,
	p_dflt_excs_trtmt_cd            in varchar2,
	p_dflt_excs_trtmt_rl            in number,
	p_rlovr_rstrcn_cd               in varchar2,
	p_no_mn_dstrbl_pct_flag         in varchar2,
	p_no_mn_dstrbl_val_flag         in varchar2,
	p_no_mx_dstrbl_pct_flag         in varchar2,
	p_no_mx_dstrbl_val_flag         in varchar2,
        p_auto_alct_excs_flag           in varchar2,
        p_alws_ngtv_crs_flag            in varchar2,
        p_uses_net_crs_mthd_flag        in varchar2,
        p_mx_dfcit_pct_pool_crs_num     in number,
        p_mx_dfcit_pct_comp_num          in number,
        p_comp_lvl_fctr_id              in number,
	p_mn_dstrbl_pct_num             in number,
	p_mn_dstrbl_val                 in number,
	p_mx_dstrbl_pct_num             in number,
	p_mx_dstrbl_val                 in number,
	p_excs_trtmt_cd                 in varchar2,
	p_ptip_id                       in number,
	p_plip_id                       in number,
	p_pgm_id                        in number,
	p_oiplip_id                     in number,
	p_cmbn_plip_id                  in number,
	p_cmbn_ptip_id                  in number,
	p_cmbn_ptip_opt_id              in number,
	p_business_group_id             in number,
	p_bpp_attribute_category        in varchar2,
	p_bpp_attribute1                in varchar2,
	p_bpp_attribute2                in varchar2,
	p_bpp_attribute3                in varchar2,
	p_bpp_attribute4                in varchar2,
	p_bpp_attribute5                in varchar2,
	p_bpp_attribute6                in varchar2,
	p_bpp_attribute7                in varchar2,
	p_bpp_attribute8                in varchar2,
	p_bpp_attribute9                in varchar2,
	p_bpp_attribute10               in varchar2,
	p_bpp_attribute11               in varchar2,
	p_bpp_attribute12               in varchar2,
	p_bpp_attribute13               in varchar2,
	p_bpp_attribute14               in varchar2,
	p_bpp_attribute15               in varchar2,
	p_bpp_attribute16               in varchar2,
	p_bpp_attribute17               in varchar2,
	p_bpp_attribute18               in varchar2,
	p_bpp_attribute19               in varchar2,
	p_bpp_attribute20               in varchar2,
	p_bpp_attribute21               in varchar2,
	p_bpp_attribute22               in varchar2,
	p_bpp_attribute23               in varchar2,
	p_bpp_attribute24               in varchar2,
	p_bpp_attribute25               in varchar2,
	p_bpp_attribute26               in varchar2,
	p_bpp_attribute27               in varchar2,
	p_bpp_attribute28               in varchar2,
	p_bpp_attribute29               in varchar2,
	p_bpp_attribute30               in varchar2,
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
  l_rec.bnft_prvdr_pool_id               := p_bnft_prvdr_pool_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.name                             := p_name;
  l_rec.pgm_pool_flag                    := p_pgm_pool_flag;
  l_rec.excs_alwys_fftd_flag             := p_excs_alwys_fftd_flag;
  l_rec.use_for_pgm_pool_flag            := p_use_for_pgm_pool_flag;
  l_rec.pct_rndg_cd                      := p_pct_rndg_cd;
  l_rec.pct_rndg_rl                      := p_pct_rndg_rl;
  l_rec.val_rndg_cd                      := p_val_rndg_cd;
  l_rec.val_rndg_rl                      := p_val_rndg_rl;
  l_rec.dflt_excs_trtmt_cd               := p_dflt_excs_trtmt_cd;
  l_rec.dflt_excs_trtmt_rl               := p_dflt_excs_trtmt_rl;
  l_rec.rlovr_rstrcn_cd                  := p_rlovr_rstrcn_cd;
  l_rec.no_mn_dstrbl_pct_flag            := p_no_mn_dstrbl_pct_flag;
  l_rec.no_mn_dstrbl_val_flag            := p_no_mn_dstrbl_val_flag;
  l_rec.no_mx_dstrbl_pct_flag            := p_no_mx_dstrbl_pct_flag;
  l_rec.no_mx_dstrbl_val_flag            := p_no_mx_dstrbl_val_flag;
  l_rec.auto_alct_excs_flag              := p_auto_alct_excs_flag;
  l_rec.alws_ngtv_crs_flag               := p_alws_ngtv_crs_flag ;
  l_rec.uses_net_crs_mthd_flag           := p_uses_net_crs_mthd_flag ;
  l_rec.mx_dfcit_pct_pool_crs_num        := p_mx_dfcit_pct_pool_crs_num ;
  l_rec.mx_dfcit_pct_comp_num             := p_mx_dfcit_pct_comp_num ;
  l_rec.comp_lvl_fctr_id                 := p_comp_lvl_fctr_id ;
  l_rec.mn_dstrbl_pct_num                := p_mn_dstrbl_pct_num;
  l_rec.mn_dstrbl_val                    := p_mn_dstrbl_val;
  l_rec.mx_dstrbl_pct_num                := p_mx_dstrbl_pct_num;
  l_rec.mx_dstrbl_val                    := p_mx_dstrbl_val;
  l_rec.excs_trtmt_cd                    := p_excs_trtmt_cd;
  l_rec.ptip_id                          := p_ptip_id;
  l_rec.plip_id                          := p_plip_id;
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.oiplip_id                        := p_oiplip_id;
  l_rec.cmbn_plip_id                     := p_cmbn_plip_id;
  l_rec.cmbn_ptip_id                     := p_cmbn_ptip_id;
  l_rec.cmbn_ptip_opt_id                 := p_cmbn_ptip_opt_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.bpp_attribute_category           := p_bpp_attribute_category;
  l_rec.bpp_attribute1                   := p_bpp_attribute1;
  l_rec.bpp_attribute2                   := p_bpp_attribute2;
  l_rec.bpp_attribute3                   := p_bpp_attribute3;
  l_rec.bpp_attribute4                   := p_bpp_attribute4;
  l_rec.bpp_attribute5                   := p_bpp_attribute5;
  l_rec.bpp_attribute6                   := p_bpp_attribute6;
  l_rec.bpp_attribute7                   := p_bpp_attribute7;
  l_rec.bpp_attribute8                   := p_bpp_attribute8;
  l_rec.bpp_attribute9                   := p_bpp_attribute9;
  l_rec.bpp_attribute10                  := p_bpp_attribute10;
  l_rec.bpp_attribute11                  := p_bpp_attribute11;
  l_rec.bpp_attribute12                  := p_bpp_attribute12;
  l_rec.bpp_attribute13                  := p_bpp_attribute13;
  l_rec.bpp_attribute14                  := p_bpp_attribute14;
  l_rec.bpp_attribute15                  := p_bpp_attribute15;
  l_rec.bpp_attribute16                  := p_bpp_attribute16;
  l_rec.bpp_attribute17                  := p_bpp_attribute17;
  l_rec.bpp_attribute18                  := p_bpp_attribute18;
  l_rec.bpp_attribute19                  := p_bpp_attribute19;
  l_rec.bpp_attribute20                  := p_bpp_attribute20;
  l_rec.bpp_attribute21                  := p_bpp_attribute21;
  l_rec.bpp_attribute22                  := p_bpp_attribute22;
  l_rec.bpp_attribute23                  := p_bpp_attribute23;
  l_rec.bpp_attribute24                  := p_bpp_attribute24;
  l_rec.bpp_attribute25                  := p_bpp_attribute25;
  l_rec.bpp_attribute26                  := p_bpp_attribute26;
  l_rec.bpp_attribute27                  := p_bpp_attribute27;
  l_rec.bpp_attribute28                  := p_bpp_attribute28;
  l_rec.bpp_attribute29                  := p_bpp_attribute29;
  l_rec.bpp_attribute30                  := p_bpp_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_bpp_shd;

/
