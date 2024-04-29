--------------------------------------------------------
--  DDL for Package Body BEN_CCM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CCM_SHD" as
/* $Header: beccmrhi.pkb 120.5 2006/03/22 02:53:46 rgajula noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ccm_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_CVG_AMT_CALC_MTHD_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_CVG_AMT_CALC_MTHD_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_CVG_AMT_CALC_MTHD_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
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
   p_cvg_amt_calc_mthd_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	cvg_amt_calc_mthd_id,
	effective_start_date,
	effective_end_date,
	name,
	incrmt_val,
	mx_val,
	mn_val,
	no_mx_val_dfnd_flag,
	no_mn_val_dfnd_flag,
	rndg_cd,
	rndg_rl,
        lwr_lmt_val,
        lwr_lmt_calc_rl,
        upr_lmt_val,
        upr_lmt_calc_rl,
	val,
	val_ovrid_alwd_flag,
	val_calc_rl,
	uom,
	nnmntry_uom,
	bndry_perd_cd,
	bnft_typ_cd,
	cvg_mlt_cd,
	rt_typ_cd,
        dflt_val,
        entr_val_at_enrt_flag,
        dflt_flag,
	comp_lvl_fctr_id,
	oipl_id,
	pl_id,
	plip_id,
	business_group_id,
	ccm_attribute_category,
	ccm_attribute1,
	ccm_attribute2,
	ccm_attribute3,
	ccm_attribute4,
	ccm_attribute5,
	ccm_attribute6,
	ccm_attribute7,
	ccm_attribute8,
	ccm_attribute9,
	ccm_attribute10,
	ccm_attribute11,
	ccm_attribute12,
	ccm_attribute13,
	ccm_attribute14,
	ccm_attribute15,
	ccm_attribute16,
	ccm_attribute17,
	ccm_attribute18,
	ccm_attribute19,
	ccm_attribute20,
	ccm_attribute21,
	ccm_attribute22,
	ccm_attribute23,
	ccm_attribute24,
	ccm_attribute25,
	ccm_attribute26,
	ccm_attribute27,
	ccm_attribute28,
	ccm_attribute29,
	ccm_attribute30,
	object_version_number
    from	ben_cvg_amt_calc_mthd_f
    where	cvg_amt_calc_mthd_id = p_cvg_amt_calc_mthd_id
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
      p_cvg_amt_calc_mthd_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cvg_amt_calc_mthd_id = g_old_rec.cvg_amt_calc_mthd_id and
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
	    t.pl_id,
            t.plip_id
    from    ben_cvg_amt_calc_mthd_f t
    where   t.cvg_amt_calc_mthd_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1,
		    l_parent_key_value2,
                    l_parent_key_value3;
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
	 p_base_table_name	=> 'ben_cvg_amt_calc_mthd_f',
	 p_base_key_column	=> 'cvg_amt_calc_mthd_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ben_oipl_f',
	 p_parent_key_column1	=> 'oipl_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_parent_table_name2	=> 'ben_pl_f',
	 p_parent_key_column2	=> 'pl_id',
	 p_parent_key_value2	=> l_parent_key_value2,
	 p_parent_table_name3	=> 'ben_plip_f',
	 p_parent_key_column3	=> 'plip_id',
	 p_parent_key_value3	=> l_parent_key_value3,
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
	 p_base_table_name	=> 'ben_cvg_amt_calc_mthd_f',
	 p_base_key_column	=> 'cvg_amt_calc_mthd_id',
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
	(p_base_table_name	=> 'ben_cvg_amt_calc_mthd_f',
	 p_base_key_column	=> 'cvg_amt_calc_mthd_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_cvg_amt_calc_mthd_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.cvg_amt_calc_mthd_id	  = p_base_key_value
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
	 p_cvg_amt_calc_mthd_id	 in  number,
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
	cvg_amt_calc_mthd_id,
	effective_start_date,
	effective_end_date,
	name,
	incrmt_val,
	mx_val,
	mn_val,
	no_mx_val_dfnd_flag,
	no_mn_val_dfnd_flag,
	rndg_cd,
	rndg_rl,
        lwr_lmt_val,
        lwr_lmt_calc_rl,
        upr_lmt_val,
        upr_lmt_calc_rl,
	val,
	val_ovrid_alwd_flag,
	val_calc_rl,
	uom,
	nnmntry_uom,
	bndry_perd_cd,
	bnft_typ_cd,
	cvg_mlt_cd,
	rt_typ_cd,
        dflt_val,
        entr_val_at_enrt_flag,
        dflt_flag,
	comp_lvl_fctr_id,
	oipl_id,
	pl_id,
	plip_id,
	business_group_id,
	ccm_attribute_category,
	ccm_attribute1,
	ccm_attribute2,
	ccm_attribute3,
	ccm_attribute4,
	ccm_attribute5,
	ccm_attribute6,
	ccm_attribute7,
	ccm_attribute8,
	ccm_attribute9,
	ccm_attribute10,
	ccm_attribute11,
	ccm_attribute12,
	ccm_attribute13,
	ccm_attribute14,
	ccm_attribute15,
	ccm_attribute16,
	ccm_attribute17,
	ccm_attribute18,
	ccm_attribute19,
	ccm_attribute20,
	ccm_attribute21,
	ccm_attribute22,
	ccm_attribute23,
	ccm_attribute24,
	ccm_attribute25,
	ccm_attribute26,
	ccm_attribute27,
	ccm_attribute28,
	ccm_attribute29,
	ccm_attribute30,
	object_version_number
    from    ben_cvg_amt_calc_mthd_f
    where   cvg_amt_calc_mthd_id         = p_cvg_amt_calc_mthd_id
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
                             p_argument       => 'cvg_amt_calc_mthd_id',
                             p_argument_value => p_cvg_amt_calc_mthd_id);
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
	 p_base_table_name	   => 'ben_cvg_amt_calc_mthd_f',
	 p_base_key_column	   => 'cvg_amt_calc_mthd_id',
	 p_base_key_value 	   => p_cvg_amt_calc_mthd_id,
	 p_parent_table_name1      => 'ben_oipl_f',
	 p_parent_key_column1      => 'oipl_id',
	 p_parent_key_value1       => g_old_rec.oipl_id,
	 p_parent_table_name2      => 'ben_pl_f',
	 p_parent_key_column2      => 'pl_id',
	 p_parent_key_value2       => g_old_rec.pl_id,
	 p_parent_table_name3      => 'ben_plip_f',
	 p_parent_key_column3      => 'plip_id',
	 p_parent_key_value3       => g_old_rec.plip_id,
	 p_child_table_name1       => 'ben_bnft_vrbl_rt_f',
	 p_child_key_column1       => 'bnft_vrbl_rt_id',
	 p_child_table_name2       => 'ben_bnft_vrbl_rt_rl_f',
	 p_child_key_column2       => 'bnft_vrbl_rt_rl_id',
	 p_child_table_name3       => 'ben_bnft_vrbl_rt_rl_f',
	 p_child_key_column3       => 'cvg_amt_calc_mthd_id',
	 p_child_table_name4       => 'ben_bnft_vrbl_rt_rl_f',
	 p_child_key_column4       => 'formula_id',
         p_enforce_foreign_locking => true,
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_cvg_amt_calc_mthd_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'ben_cvg_amt_calc_mthd_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_cvg_amt_calc_mthd_id          in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_name                          in varchar2,
	p_incrmt_val                    in number,
	p_mx_val                        in number,
	p_mn_val                        in number,
	p_no_mx_val_dfnd_flag           in varchar2,
	p_no_mn_val_dfnd_flag           in varchar2,
	p_rndg_cd                       in varchar2,
	p_rndg_rl                       in number,
        p_lwr_lmt_val                   in number,
        p_lwr_lmt_calc_rl               in number,
        p_upr_lmt_val                   in number,
        p_upr_lmt_calc_rl               in number,
	p_val                           in number,
	p_val_ovrid_alwd_flag           in varchar2,
	p_val_calc_rl                   in number,
	p_uom                           in varchar2,
	p_nnmntry_uom                   in varchar2,
	p_bndry_perd_cd                 in varchar2,
	p_bnft_typ_cd                   in varchar2,
	p_cvg_mlt_cd                    in varchar2,
	p_rt_typ_cd                     in varchar2,
        p_dflt_val                      in number,
        p_entr_val_at_enrt_flag         in varchar2,
        p_dflt_flag                     in varchar2,
	p_comp_lvl_fctr_id              in number,
	p_oipl_id                       in number,
	p_pl_id                         in number,
	p_plip_id                       in number,
	p_business_group_id             in number,
	p_ccm_attribute_category        in varchar2,
	p_ccm_attribute1                in varchar2,
	p_ccm_attribute2                in varchar2,
	p_ccm_attribute3                in varchar2,
	p_ccm_attribute4                in varchar2,
	p_ccm_attribute5                in varchar2,
	p_ccm_attribute6                in varchar2,
	p_ccm_attribute7                in varchar2,
	p_ccm_attribute8                in varchar2,
	p_ccm_attribute9                in varchar2,
	p_ccm_attribute10               in varchar2,
	p_ccm_attribute11               in varchar2,
	p_ccm_attribute12               in varchar2,
	p_ccm_attribute13               in varchar2,
	p_ccm_attribute14               in varchar2,
	p_ccm_attribute15               in varchar2,
	p_ccm_attribute16               in varchar2,
	p_ccm_attribute17               in varchar2,
	p_ccm_attribute18               in varchar2,
	p_ccm_attribute19               in varchar2,
	p_ccm_attribute20               in varchar2,
	p_ccm_attribute21               in varchar2,
	p_ccm_attribute22               in varchar2,
	p_ccm_attribute23               in varchar2,
	p_ccm_attribute24               in varchar2,
	p_ccm_attribute25               in varchar2,
	p_ccm_attribute26               in varchar2,
	p_ccm_attribute27               in varchar2,
	p_ccm_attribute28               in varchar2,
	p_ccm_attribute29               in varchar2,
	p_ccm_attribute30               in varchar2,
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
  l_rec.cvg_amt_calc_mthd_id             := p_cvg_amt_calc_mthd_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.name                             := p_name;
  l_rec.incrmt_val                       := p_incrmt_val;
  l_rec.mx_val                           := p_mx_val;
  l_rec.mn_val                           := p_mn_val;
  l_rec.no_mx_val_dfnd_flag              := p_no_mx_val_dfnd_flag;
  l_rec.no_mn_val_dfnd_flag              := p_no_mn_val_dfnd_flag;
  l_rec.rndg_cd                          := p_rndg_cd;
  l_rec.rndg_rl                          := p_rndg_rl;
  l_rec.lwr_lmt_val                      := p_lwr_lmt_val;
  l_rec.upr_lmt_calc_rl                  := p_upr_lmt_calc_rl;
  l_rec.upr_lmt_val                      := p_upr_lmt_val;
  l_rec.lwr_lmt_calc_rl                  := p_lwr_lmt_calc_rl;
  l_rec.val                              := p_val;
  l_rec.val_ovrid_alwd_flag              := p_val_ovrid_alwd_flag;
  l_rec.val_calc_rl                      := p_val_calc_rl;
  l_rec.uom                              := p_uom;
  l_rec.nnmntry_uom                      := p_nnmntry_uom;
  l_rec.bndry_perd_cd                    := p_bndry_perd_cd;
  l_rec.bnft_typ_cd                      := p_bnft_typ_cd;
  l_rec.cvg_mlt_cd                       := p_cvg_mlt_cd;
  l_rec.rt_typ_cd                        := p_rt_typ_cd;
  l_rec.dflt_val                         := p_dflt_val;
  l_rec.entr_val_at_enrt_flag            := p_entr_val_at_enrt_flag;
  l_rec.dflt_flag                        := p_dflt_flag;
  l_rec.comp_lvl_fctr_id                 := p_comp_lvl_fctr_id;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.plip_id                          := p_plip_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.ccm_attribute_category           := p_ccm_attribute_category;
  l_rec.ccm_attribute1                   := p_ccm_attribute1;
  l_rec.ccm_attribute2                   := p_ccm_attribute2;
  l_rec.ccm_attribute3                   := p_ccm_attribute3;
  l_rec.ccm_attribute4                   := p_ccm_attribute4;
  l_rec.ccm_attribute5                   := p_ccm_attribute5;
  l_rec.ccm_attribute6                   := p_ccm_attribute6;
  l_rec.ccm_attribute7                   := p_ccm_attribute7;
  l_rec.ccm_attribute8                   := p_ccm_attribute8;
  l_rec.ccm_attribute9                   := p_ccm_attribute9;
  l_rec.ccm_attribute10                  := p_ccm_attribute10;
  l_rec.ccm_attribute11                  := p_ccm_attribute11;
  l_rec.ccm_attribute12                  := p_ccm_attribute12;
  l_rec.ccm_attribute13                  := p_ccm_attribute13;
  l_rec.ccm_attribute14                  := p_ccm_attribute14;
  l_rec.ccm_attribute15                  := p_ccm_attribute15;
  l_rec.ccm_attribute16                  := p_ccm_attribute16;
  l_rec.ccm_attribute17                  := p_ccm_attribute17;
  l_rec.ccm_attribute18                  := p_ccm_attribute18;
  l_rec.ccm_attribute19                  := p_ccm_attribute19;
  l_rec.ccm_attribute20                  := p_ccm_attribute20;
  l_rec.ccm_attribute21                  := p_ccm_attribute21;
  l_rec.ccm_attribute22                  := p_ccm_attribute22;
  l_rec.ccm_attribute23                  := p_ccm_attribute23;
  l_rec.ccm_attribute24                  := p_ccm_attribute24;
  l_rec.ccm_attribute25                  := p_ccm_attribute25;
  l_rec.ccm_attribute26                  := p_ccm_attribute26;
  l_rec.ccm_attribute27                  := p_ccm_attribute27;
  l_rec.ccm_attribute28                  := p_ccm_attribute28;
  l_rec.ccm_attribute29                  := p_ccm_attribute29;
  l_rec.ccm_attribute30                  := p_ccm_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_ccm_shd;

/
