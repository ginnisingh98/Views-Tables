--------------------------------------------------------
--  DDL for Package Body BEN_HWF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_HWF_SHD" as
/* $Header: behwfrhi.pkb 120.0 2005/05/28 03:12:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_hwf_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_HRS_WKD_IN_PERD_FCTR_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_HRS_WKD_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_ELIG_HRS_WKD_PRTE_F');
  ElsIf (p_constraint_name = 'BEN_HRS_WORKED_IN_PERD_RT_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_HRS_WKD_IN_PERD_RT_F');
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
  (
  p_hrs_wkd_in_perd_fctr_id            in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		hrs_wkd_in_perd_fctr_id,
	name,
	business_group_id,
	hrs_src_cd,
	rndg_cd,
	rndg_rl,
	hrs_wkd_det_cd,
	hrs_wkd_det_rl,
	no_mn_hrs_wkd_flag,
	mx_hrs_num,
	no_mx_hrs_wkd_flag,
	once_r_cntug_cd,
	mn_hrs_num,
        hrs_alt_val_to_use_cd,
        pyrl_freq_cd,
        hrs_wkd_calc_rl,
        defined_balance_id,
        bnfts_bal_id,
	hwf_attribute_category,
	hwf_attribute1,
	hwf_attribute2,
	hwf_attribute3,
	hwf_attribute4,
	hwf_attribute5,
	hwf_attribute6,
	hwf_attribute7,
	hwf_attribute8,
	hwf_attribute9,
	hwf_attribute10,
	hwf_attribute11,
	hwf_attribute12,
	hwf_attribute13,
	hwf_attribute14,
	hwf_attribute15,
	hwf_attribute16,
	hwf_attribute17,
	hwf_attribute18,
	hwf_attribute19,
	hwf_attribute20,
	hwf_attribute21,
	hwf_attribute22,
	hwf_attribute23,
	hwf_attribute24,
	hwf_attribute25,
	hwf_attribute26,
	hwf_attribute27,
	hwf_attribute28,
	hwf_attribute29,
	hwf_attribute30,
	object_version_number
    from	ben_hrs_wkd_in_perd_fctr
    where	hrs_wkd_in_perd_fctr_id = p_hrs_wkd_in_perd_fctr_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_hrs_wkd_in_perd_fctr_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_hrs_wkd_in_perd_fctr_id = g_old_rec.hrs_wkd_in_perd_fctr_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_old_rec
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
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_hrs_wkd_in_perd_fctr_id            in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	hrs_wkd_in_perd_fctr_id,
	name,
	business_group_id,
	hrs_src_cd,
	rndg_cd,
	rndg_rl,
	hrs_wkd_det_cd,
	hrs_wkd_det_rl,
	no_mn_hrs_wkd_flag,
	mx_hrs_num,
	no_mx_hrs_wkd_flag,
	once_r_cntug_cd,
	mn_hrs_num,
        hrs_alt_val_to_use_cd,
        pyrl_freq_cd,
        hrs_wkd_calc_rl,
        defined_balance_id,
        bnfts_bal_id,
	hwf_attribute_category,
	hwf_attribute1,
	hwf_attribute2,
	hwf_attribute3,
	hwf_attribute4,
	hwf_attribute5,
	hwf_attribute6,
	hwf_attribute7,
	hwf_attribute8,
	hwf_attribute9,
	hwf_attribute10,
	hwf_attribute11,
	hwf_attribute12,
	hwf_attribute13,
	hwf_attribute14,
	hwf_attribute15,
	hwf_attribute16,
	hwf_attribute17,
	hwf_attribute18,
	hwf_attribute19,
	hwf_attribute20,
	hwf_attribute21,
	hwf_attribute22,
	hwf_attribute23,
	hwf_attribute24,
	hwf_attribute25,
	hwf_attribute26,
	hwf_attribute27,
	hwf_attribute28,
	hwf_attribute29,
	hwf_attribute30,
	object_version_number
    from	ben_hrs_wkd_in_perd_fctr
    where	hrs_wkd_in_perd_fctr_id = p_hrs_wkd_in_perd_fctr_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
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
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
    fnd_message.set_token('TABLE_NAME', 'ben_hrs_wkd_in_perd_fctr');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_hrs_wkd_in_perd_fctr_id       in number,
	p_name                          in varchar2,
	p_business_group_id             in number,
	p_hrs_src_cd                    in varchar2,
	p_rndg_cd                       in varchar2,
	p_rndg_rl                       in number,
	p_hrs_wkd_det_cd                in varchar2,
	p_hrs_wkd_det_rl                in number,
	p_no_mn_hrs_wkd_flag            in varchar2,
	p_mx_hrs_num                    in number,
	p_no_mx_hrs_wkd_flag            in varchar2,
	p_once_r_cntug_cd               in varchar2,
	p_mn_hrs_num                    in number,
        p_hrs_alt_val_to_use_cd         in varchar2,
        p_pyrl_freq_cd                  in varchar2,
        p_hrs_wkd_calc_rl               in number,
        p_defined_balance_id            in number,
        p_bnfts_bal_id                  in number,
	p_hwf_attribute_category        in varchar2,
	p_hwf_attribute1                in varchar2,
	p_hwf_attribute2                in varchar2,
	p_hwf_attribute3                in varchar2,
	p_hwf_attribute4                in varchar2,
	p_hwf_attribute5                in varchar2,
	p_hwf_attribute6                in varchar2,
	p_hwf_attribute7                in varchar2,
	p_hwf_attribute8                in varchar2,
	p_hwf_attribute9                in varchar2,
	p_hwf_attribute10               in varchar2,
	p_hwf_attribute11               in varchar2,
	p_hwf_attribute12               in varchar2,
	p_hwf_attribute13               in varchar2,
	p_hwf_attribute14               in varchar2,
	p_hwf_attribute15               in varchar2,
	p_hwf_attribute16               in varchar2,
	p_hwf_attribute17               in varchar2,
	p_hwf_attribute18               in varchar2,
	p_hwf_attribute19               in varchar2,
	p_hwf_attribute20               in varchar2,
	p_hwf_attribute21               in varchar2,
	p_hwf_attribute22               in varchar2,
	p_hwf_attribute23               in varchar2,
	p_hwf_attribute24               in varchar2,
	p_hwf_attribute25               in varchar2,
	p_hwf_attribute26               in varchar2,
	p_hwf_attribute27               in varchar2,
	p_hwf_attribute28               in varchar2,
	p_hwf_attribute29               in varchar2,
	p_hwf_attribute30               in varchar2,
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
  l_rec.hrs_wkd_in_perd_fctr_id          := p_hrs_wkd_in_perd_fctr_id;
  l_rec.name                             := p_name;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.hrs_src_cd                       := p_hrs_src_cd;
  l_rec.rndg_cd                          := p_rndg_cd;
  l_rec.rndg_rl                          := p_rndg_rl;
  l_rec.hrs_wkd_det_cd                   := p_hrs_wkd_det_cd;
  l_rec.hrs_wkd_det_rl                   := p_hrs_wkd_det_rl;
  l_rec.no_mn_hrs_wkd_flag               := p_no_mn_hrs_wkd_flag;
  l_rec.mx_hrs_num                       := p_mx_hrs_num;
  l_rec.no_mx_hrs_wkd_flag               := p_no_mx_hrs_wkd_flag;
  l_rec.once_r_cntug_cd                  := p_once_r_cntug_cd;
  l_rec.mn_hrs_num                       := p_mn_hrs_num;
  l_rec.hrs_alt_val_to_use_cd            := p_hrs_alt_val_to_use_cd;
  l_rec.pyrl_freq_cd                     := p_pyrl_freq_cd;
  l_rec.hrs_wkd_calc_rl                  := p_hrs_wkd_calc_rl;
  l_rec.defined_balance_id               := p_defined_balance_id;
  l_rec.bnfts_bal_id                     := p_bnfts_bal_id;
  l_rec.hwf_attribute_category           := p_hwf_attribute_category;
  l_rec.hwf_attribute1                   := p_hwf_attribute1;
  l_rec.hwf_attribute2                   := p_hwf_attribute2;
  l_rec.hwf_attribute3                   := p_hwf_attribute3;
  l_rec.hwf_attribute4                   := p_hwf_attribute4;
  l_rec.hwf_attribute5                   := p_hwf_attribute5;
  l_rec.hwf_attribute6                   := p_hwf_attribute6;
  l_rec.hwf_attribute7                   := p_hwf_attribute7;
  l_rec.hwf_attribute8                   := p_hwf_attribute8;
  l_rec.hwf_attribute9                   := p_hwf_attribute9;
  l_rec.hwf_attribute10                  := p_hwf_attribute10;
  l_rec.hwf_attribute11                  := p_hwf_attribute11;
  l_rec.hwf_attribute12                  := p_hwf_attribute12;
  l_rec.hwf_attribute13                  := p_hwf_attribute13;
  l_rec.hwf_attribute14                  := p_hwf_attribute14;
  l_rec.hwf_attribute15                  := p_hwf_attribute15;
  l_rec.hwf_attribute16                  := p_hwf_attribute16;
  l_rec.hwf_attribute17                  := p_hwf_attribute17;
  l_rec.hwf_attribute18                  := p_hwf_attribute18;
  l_rec.hwf_attribute19                  := p_hwf_attribute19;
  l_rec.hwf_attribute20                  := p_hwf_attribute20;
  l_rec.hwf_attribute21                  := p_hwf_attribute21;
  l_rec.hwf_attribute22                  := p_hwf_attribute22;
  l_rec.hwf_attribute23                  := p_hwf_attribute23;
  l_rec.hwf_attribute24                  := p_hwf_attribute24;
  l_rec.hwf_attribute25                  := p_hwf_attribute25;
  l_rec.hwf_attribute26                  := p_hwf_attribute26;
  l_rec.hwf_attribute27                  := p_hwf_attribute27;
  l_rec.hwf_attribute28                  := p_hwf_attribute28;
  l_rec.hwf_attribute29                  := p_hwf_attribute29;
  l_rec.hwf_attribute30                  := p_hwf_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_hwf_shd;

/
