--------------------------------------------------------
--  DDL for Package Body BEN_APR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_APR_SHD" as
/* $Header: beaprrhi.pkb 120.0 2005/05/28 00:26:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_apr_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_ACTL_PREM_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ACTL_PREM_FK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ACTL_PREM_F_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
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
   p_actl_prem_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	actl_prem_id,
	effective_start_date,
	effective_end_date,
	name,
	acty_ref_perd_cd,
	uom,
	rt_typ_cd,
	bnft_rt_typ_cd,
	val,
	mlt_cd,
	prdct_cd,
	rndg_cd,
	rndg_rl,
        val_calc_rl,
	prem_asnmt_cd,
	prem_asnmt_lvl_cd,
	actl_prem_typ_cd,
	prem_pyr_cd,
	cr_lkbk_val,
	cr_lkbk_uom,
	cr_lkbk_crnt_py_only_flag,
	prsptv_r_rtsptv_cd,
	upr_lmt_val,
	upr_lmt_calc_rl,
	lwr_lmt_val,
	lwr_lmt_calc_rl,
	cost_allocation_keyflex_id,
	organization_id,
	oipl_id,
	pl_id,
	comp_lvl_fctr_id,
	business_group_id,
        prtl_mo_det_mthd_cd,
        prtl_mo_det_mthd_rl,
        wsh_rl_dy_mo_num,
        vrbl_rt_add_on_calc_rl,
	apr_attribute_category,
	apr_attribute1,
	apr_attribute2,
	apr_attribute3,
	apr_attribute4,
	apr_attribute5,
	apr_attribute6,
	apr_attribute7,
	apr_attribute8,
	apr_attribute9,
	apr_attribute10,
	apr_attribute11,
	apr_attribute12,
	apr_attribute13,
	apr_attribute14,
	apr_attribute15,
	apr_attribute16,
	apr_attribute17,
	apr_attribute18,
	apr_attribute19,
	apr_attribute20,
	apr_attribute21,
	apr_attribute22,
	apr_attribute23,
	apr_attribute24,
	apr_attribute25,
	apr_attribute26,
	apr_attribute27,
	apr_attribute28,
	apr_attribute29,
	apr_attribute30,
	object_version_number
    from	ben_actl_prem_f
    where	actl_prem_id = p_actl_prem_id
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
      p_actl_prem_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_actl_prem_id = g_old_rec.actl_prem_id and
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
  --
  Cursor C_Sel1 Is
    select  t.comp_lvl_fctr_id
    from    ben_actl_prem_f t
    where   t.actl_prem_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1;
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
	 p_base_table_name	=> 'ben_actl_prem_f',
	 p_base_key_column	=> 'actl_prem_id',
	 p_base_key_value	=> p_base_key_value,
--	 p_parent_table_name1	=> 'ben_comp_lvl_fctr',
--	 p_parent_key_column1	=> 'comp_lvl_fctr_id',
--	 p_parent_key_value1	=> l_parent_key_value1,
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
	 p_base_table_name	=> 'ben_actl_prem_f',
	 p_base_key_column	=> 'actl_prem_id',
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
	(p_base_table_name	=> 'ben_actl_prem_f',
	 p_base_key_column	=> 'actl_prem_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_actl_prem_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.actl_prem_id	  = p_base_key_value
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
	 p_actl_prem_id	 in  number,
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
	actl_prem_id,
	effective_start_date,
	effective_end_date,
	name,
	acty_ref_perd_cd,
	uom,
	rt_typ_cd,
	bnft_rt_typ_cd,
	val,
	mlt_cd,
	prdct_cd,
	rndg_cd,
	rndg_rl,
        val_calc_rl,
	prem_asnmt_cd,
	prem_asnmt_lvl_cd,
	actl_prem_typ_cd,
	prem_pyr_cd,
	cr_lkbk_val,
	cr_lkbk_uom,
	cr_lkbk_crnt_py_only_flag,
	prsptv_r_rtsptv_cd,
	upr_lmt_val,
	upr_lmt_calc_rl,
	lwr_lmt_val,
	lwr_lmt_calc_rl,
	cost_allocation_keyflex_id,
	organization_id,
	oipl_id,
	pl_id,
	comp_lvl_fctr_id,
	business_group_id,
        prtl_mo_det_mthd_cd,
        prtl_mo_det_mthd_rl,
        wsh_rl_dy_mo_num,
        vrbl_rt_add_on_calc_rl,
	apr_attribute_category,
	apr_attribute1,
	apr_attribute2,
	apr_attribute3,
	apr_attribute4,
	apr_attribute5,
	apr_attribute6,
	apr_attribute7,
	apr_attribute8,
	apr_attribute9,
	apr_attribute10,
	apr_attribute11,
	apr_attribute12,
	apr_attribute13,
	apr_attribute14,
	apr_attribute15,
	apr_attribute16,
	apr_attribute17,
	apr_attribute18,
	apr_attribute19,
	apr_attribute20,
	apr_attribute21,
	apr_attribute22,
	apr_attribute23,
	apr_attribute24,
	apr_attribute25,
	apr_attribute26,
	apr_attribute27,
	apr_attribute28,
	apr_attribute29,
	apr_attribute30,
	object_version_number
    from    ben_actl_prem_f
    where   actl_prem_id         = p_actl_prem_id
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
                             p_argument       => 'actl_prem_id',
                             p_argument_value => p_actl_prem_id);
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
	 p_base_table_name	   => 'ben_actl_prem_f',
	 p_base_key_column	   => 'actl_prem_id',
	 p_base_key_value 	   => p_actl_prem_id,
--	 p_parent_table_name1      => 'ben_comp_lvl_fctr',
--	 p_parent_key_column1      => 'comp_lvl_fctr_id',
--	 p_parent_key_value1       => g_old_rec.comp_lvl_fctr_id,
	 p_child_table_name1       => 'ben_oipl_f',
	 p_child_key_column1       => 'oipl_id',
	 p_child_table_name2       => 'ben_actl_prem_vrbl_rt_f',
	 p_child_key_column2       => 'actl_prem_vrbl_rt_id',
	 p_child_table_name3       => 'ben_prtt_prem_f',
	 p_child_key_column3       => 'prtt_prem_id',
--	 p_child_table_name4       => 'ben_actl_prem_vrbl_rt_rl_f',
--	 p_child_key_column4       => 'actl_prem_vrbl_rt_rl_id',
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
    fnd_message.set_token('TABLE_NAME', 'ben_actl_prem_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_actl_prem_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_actl_prem_id                  in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_name                          in varchar2,
	p_acty_ref_perd_cd              in varchar2,
	p_uom                           in varchar2,
	p_rt_typ_cd                     in varchar2,
	p_bnft_rt_typ_cd                in varchar2,
	p_val                           in number,
	p_mlt_cd                        in varchar2,
	p_prdct_cd                      in varchar2,
	p_rndg_cd                       in varchar2,
	p_rndg_rl                       in number,
        p_val_calc_rl                   in number,
        p_prem_asnmt_cd                 in varchar2,
        p_prem_asnmt_lvl_cd             in varchar2,
        p_actl_prem_typ_cd              in varchar2,
        p_prem_pyr_cd                   in varchar2,
        p_cr_lkbk_val                   in number,
        p_cr_lkbk_uom                   in varchar2,
        p_cr_lkbk_crnt_py_only_flag     in varchar2,
        p_prsptv_r_rtsptv_cd            in varchar2,
        p_upr_lmt_val                   in number,
        p_upr_lmt_calc_rl               in number,
        p_lwr_lmt_val                   in number,
        p_lwr_lmt_calc_rl               in number,
        p_cost_allocation_keyflex_id    in number,
	p_organization_id               in number,
        p_oipl_id                       in number,
        p_pl_id                         in number,
	p_comp_lvl_fctr_id              in number,
	p_business_group_id             in number,
        p_prtl_mo_det_mthd_cd           in varchar2,
        p_prtl_mo_det_mthd_rl           in number,
        p_wsh_rl_dy_mo_num              in number,
        p_vrbl_rt_add_on_calc_rl        in number,
	p_apr_attribute_category        in varchar2,
	p_apr_attribute1                in varchar2,
	p_apr_attribute2                in varchar2,
	p_apr_attribute3                in varchar2,
	p_apr_attribute4                in varchar2,
	p_apr_attribute5                in varchar2,
	p_apr_attribute6                in varchar2,
	p_apr_attribute7                in varchar2,
	p_apr_attribute8                in varchar2,
	p_apr_attribute9                in varchar2,
	p_apr_attribute10               in varchar2,
	p_apr_attribute11               in varchar2,
	p_apr_attribute12               in varchar2,
	p_apr_attribute13               in varchar2,
	p_apr_attribute14               in varchar2,
	p_apr_attribute15               in varchar2,
	p_apr_attribute16               in varchar2,
	p_apr_attribute17               in varchar2,
	p_apr_attribute18               in varchar2,
	p_apr_attribute19               in varchar2,
	p_apr_attribute20               in varchar2,
	p_apr_attribute21               in varchar2,
	p_apr_attribute22               in varchar2,
	p_apr_attribute23               in varchar2,
	p_apr_attribute24               in varchar2,
	p_apr_attribute25               in varchar2,
	p_apr_attribute26               in varchar2,
	p_apr_attribute27               in varchar2,
	p_apr_attribute28               in varchar2,
	p_apr_attribute29               in varchar2,
	p_apr_attribute30               in varchar2,
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
  l_rec.actl_prem_id                     := p_actl_prem_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.name                             := p_name;
  l_rec.acty_ref_perd_cd                 := p_acty_ref_perd_cd;
  l_rec.uom                              := p_uom;
  l_rec.rt_typ_cd                        := p_rt_typ_cd;
  l_rec.bnft_rt_typ_cd                   := p_bnft_rt_typ_cd;
  l_rec.val                              := p_val;
  l_rec.mlt_cd                           := p_mlt_cd;
  l_rec.prdct_cd                         := p_prdct_cd;
  l_rec.rndg_cd                          := p_rndg_cd;
  l_rec.rndg_rl                          := p_rndg_rl;
  l_rec.val_calc_rl                      := p_val_calc_rl;
  l_rec.prem_asnmt_cd                    := p_prem_asnmt_cd;
  l_rec.prem_asnmt_lvl_cd                := p_prem_asnmt_lvl_cd;
  l_rec.actl_prem_typ_cd                 := p_actl_prem_typ_cd;
  l_rec.prem_pyr_cd                      := p_prem_pyr_cd;
  l_rec.cr_lkbk_val                    := p_cr_lkbk_val;
  l_rec.cr_lkbk_uom                      := p_cr_lkbk_uom;
  l_rec.cr_lkbk_crnt_py_only_flag        := p_cr_lkbk_crnt_py_only_flag;
  l_rec.prsptv_r_rtsptv_cd               := p_prsptv_r_rtsptv_cd;
  l_rec.upr_lmt_val                      := p_upr_lmt_val;
  l_rec.upr_lmt_calc_rl                  := p_upr_lmt_calc_rl;
  l_rec.lwr_lmt_val                      := p_lwr_lmt_val;
  l_rec.lwr_lmt_calc_rl                  := p_lwr_lmt_calc_rl;
  l_rec.cost_allocation_keyflex_id       := p_cost_allocation_keyflex_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.comp_lvl_fctr_id                 := p_comp_lvl_fctr_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.prtl_mo_det_mthd_cd              := p_prtl_mo_det_mthd_cd;
  l_rec.prtl_mo_det_mthd_rl              := p_prtl_mo_det_mthd_rl;
  l_rec.wsh_rl_dy_mo_num                 := p_wsh_rl_dy_mo_num;
  l_rec.vrbl_rt_add_on_calc_rl           := p_vrbl_rt_add_on_calc_rl;
  l_rec.apr_attribute_category           := p_apr_attribute_category;
  l_rec.apr_attribute1                   := p_apr_attribute1;
  l_rec.apr_attribute2                   := p_apr_attribute2;
  l_rec.apr_attribute3                   := p_apr_attribute3;
  l_rec.apr_attribute4                   := p_apr_attribute4;
  l_rec.apr_attribute5                   := p_apr_attribute5;
  l_rec.apr_attribute6                   := p_apr_attribute6;
  l_rec.apr_attribute7                   := p_apr_attribute7;
  l_rec.apr_attribute8                   := p_apr_attribute8;
  l_rec.apr_attribute9                   := p_apr_attribute9;
  l_rec.apr_attribute10                  := p_apr_attribute10;
  l_rec.apr_attribute11                  := p_apr_attribute11;
  l_rec.apr_attribute12                  := p_apr_attribute12;
  l_rec.apr_attribute13                  := p_apr_attribute13;
  l_rec.apr_attribute14                  := p_apr_attribute14;
  l_rec.apr_attribute15                  := p_apr_attribute15;
  l_rec.apr_attribute16                  := p_apr_attribute16;
  l_rec.apr_attribute17                  := p_apr_attribute17;
  l_rec.apr_attribute18                  := p_apr_attribute18;
  l_rec.apr_attribute19                  := p_apr_attribute19;
  l_rec.apr_attribute20                  := p_apr_attribute20;
  l_rec.apr_attribute21                  := p_apr_attribute21;
  l_rec.apr_attribute22                  := p_apr_attribute22;
  l_rec.apr_attribute23                  := p_apr_attribute23;
  l_rec.apr_attribute24                  := p_apr_attribute24;
  l_rec.apr_attribute25                  := p_apr_attribute25;
  l_rec.apr_attribute26                  := p_apr_attribute26;
  l_rec.apr_attribute27                  := p_apr_attribute27;
  l_rec.apr_attribute28                  := p_apr_attribute28;
  l_rec.apr_attribute29                  := p_apr_attribute29;
  l_rec.apr_attribute30                  := p_apr_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_apr_shd;

/
