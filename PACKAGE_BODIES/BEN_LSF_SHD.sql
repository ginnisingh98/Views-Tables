--------------------------------------------------------
--  DDL for Package Body BEN_LSF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LSF_SHD" as
/* $Header: belsfrhi.pkb 120.0 2005/05/28 03:37:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_lsf_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_LOS_FCTR_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_LOS_FCTR_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_LOSE_RT_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_LOS_RT_F');
  ElsIf (p_constraint_name = 'BEN_CMB_AGE_LGH_OF_SVC_FCT_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_CMBN_AGE_LGTH_OF_SVC_FCTR');
  ElsIf (p_constraint_name = 'BEN_ELIG_LOS_PRTE_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_ELIG_LOS_PRTE_F');
  ElsIf (p_constraint_name = 'BEN_VSTG_LOS_RQMT_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_VSTG_LOS_RQMT');
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
  p_los_fctr_id                        in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		los_fctr_id,
	name,
	business_group_id,
	los_det_cd,
	los_det_rl,
	mn_los_num,
	mx_los_num,
	no_mx_los_num_apls_flag,
	no_mn_los_num_apls_flag,
	rndg_cd,
	rndg_rl,
	los_dt_to_use_cd,
	los_dt_to_use_rl,
	los_uom,
        los_calc_rl,
        los_alt_val_to_use_cd,
	lsf_attribute_category,
	lsf_attribute1,
	lsf_attribute2,
	lsf_attribute3,
	lsf_attribute4,
	lsf_attribute5,
	lsf_attribute6,
	lsf_attribute7,
	lsf_attribute8,
	lsf_attribute9,
	lsf_attribute10,
	lsf_attribute11,
	lsf_attribute12,
	lsf_attribute13,
	lsf_attribute14,
	lsf_attribute15,
	lsf_attribute16,
	lsf_attribute17,
	lsf_attribute18,
	lsf_attribute19,
	lsf_attribute20,
	lsf_attribute21,
	lsf_attribute22,
	lsf_attribute23,
	lsf_attribute24,
	lsf_attribute25,
	lsf_attribute26,
	lsf_attribute27,
	lsf_attribute28,
	lsf_attribute29,
	lsf_attribute30,
	object_version_number,
	use_overid_svc_dt_flag
    from	ben_los_fctr
    where	los_fctr_id = p_los_fctr_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_los_fctr_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_los_fctr_id = g_old_rec.los_fctr_id and
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
  p_los_fctr_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	los_fctr_id,
	name,
	business_group_id,
	los_det_cd,
	los_det_rl,
	mn_los_num,
	mx_los_num,
	no_mx_los_num_apls_flag,
	no_mn_los_num_apls_flag,
	rndg_cd,
	rndg_rl,
	los_dt_to_use_cd,
	los_dt_to_use_rl,
	los_uom,
        los_calc_rl,
        los_alt_val_to_use_cd,
	lsf_attribute_category,
	lsf_attribute1,
	lsf_attribute2,
	lsf_attribute3,
	lsf_attribute4,
	lsf_attribute5,
	lsf_attribute6,
	lsf_attribute7,
	lsf_attribute8,
	lsf_attribute9,
	lsf_attribute10,
	lsf_attribute11,
	lsf_attribute12,
	lsf_attribute13,
	lsf_attribute14,
	lsf_attribute15,
	lsf_attribute16,
	lsf_attribute17,
	lsf_attribute18,
	lsf_attribute19,
	lsf_attribute20,
	lsf_attribute21,
	lsf_attribute22,
	lsf_attribute23,
	lsf_attribute24,
	lsf_attribute25,
	lsf_attribute26,
	lsf_attribute27,
	lsf_attribute28,
	lsf_attribute29,
	lsf_attribute30,
	object_version_number,
	use_overid_svc_dt_flag
    from	ben_los_fctr
    where	los_fctr_id = p_los_fctr_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_los_fctr');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_los_fctr_id                   in number,
	p_name                          in varchar2,
	p_business_group_id             in number,
	p_los_det_cd                    in varchar2,
	p_los_det_rl                    in number,
	p_mn_los_num                    in number,
	p_mx_los_num                    in number,
	p_no_mx_los_num_apls_flag       in varchar2,
	p_no_mn_los_num_apls_flag       in varchar2,
	p_rndg_cd                       in varchar2,
	p_rndg_rl                       in number,
	p_los_dt_to_use_cd              in varchar2,
	p_los_dt_to_use_rl              in number,
	p_los_uom                       in varchar2,
        p_los_calc_rl                   in number,
        p_los_alt_val_to_use_cd         in varchar2,
	p_lsf_attribute_category        in varchar2,
	p_lsf_attribute1                in varchar2,
	p_lsf_attribute2                in varchar2,
	p_lsf_attribute3                in varchar2,
	p_lsf_attribute4                in varchar2,
	p_lsf_attribute5                in varchar2,
	p_lsf_attribute6                in varchar2,
	p_lsf_attribute7                in varchar2,
	p_lsf_attribute8                in varchar2,
	p_lsf_attribute9                in varchar2,
	p_lsf_attribute10               in varchar2,
	p_lsf_attribute11               in varchar2,
	p_lsf_attribute12               in varchar2,
	p_lsf_attribute13               in varchar2,
	p_lsf_attribute14               in varchar2,
	p_lsf_attribute15               in varchar2,
	p_lsf_attribute16               in varchar2,
	p_lsf_attribute17               in varchar2,
	p_lsf_attribute18               in varchar2,
	p_lsf_attribute19               in varchar2,
	p_lsf_attribute20               in varchar2,
	p_lsf_attribute21               in varchar2,
	p_lsf_attribute22               in varchar2,
	p_lsf_attribute23               in varchar2,
	p_lsf_attribute24               in varchar2,
	p_lsf_attribute25               in varchar2,
	p_lsf_attribute26               in varchar2,
	p_lsf_attribute27               in varchar2,
	p_lsf_attribute28               in varchar2,
	p_lsf_attribute29               in varchar2,
	p_lsf_attribute30               in varchar2,
	p_object_version_number         in number,
	p_use_overid_svc_dt_flag        in varchar2
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
  l_rec.los_fctr_id                      := p_los_fctr_id;
  l_rec.name                             := p_name;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.los_det_cd                       := p_los_det_cd;
  l_rec.los_det_rl                       := p_los_det_rl;
  l_rec.mn_los_num                       := p_mn_los_num;
  l_rec.mx_los_num                       := p_mx_los_num;
  l_rec.no_mx_los_num_apls_flag          := p_no_mx_los_num_apls_flag;
  l_rec.no_mn_los_num_apls_flag          := p_no_mn_los_num_apls_flag;
  l_rec.rndg_cd                          := p_rndg_cd;
  l_rec.rndg_rl                          := p_rndg_rl;
  l_rec.los_dt_to_use_cd                 := p_los_dt_to_use_cd;
  l_rec.los_dt_to_use_rl                 := p_los_dt_to_use_rl;
  l_rec.los_uom                          := p_los_uom;
  l_rec.los_calc_rl                      := p_los_calc_rl;
  l_rec.los_alt_val_to_use_cd            := p_los_alt_val_to_use_cd;
  l_rec.lsf_attribute_category           := p_lsf_attribute_category;
  l_rec.lsf_attribute1                   := p_lsf_attribute1;
  l_rec.lsf_attribute2                   := p_lsf_attribute2;
  l_rec.lsf_attribute3                   := p_lsf_attribute3;
  l_rec.lsf_attribute4                   := p_lsf_attribute4;
  l_rec.lsf_attribute5                   := p_lsf_attribute5;
  l_rec.lsf_attribute6                   := p_lsf_attribute6;
  l_rec.lsf_attribute7                   := p_lsf_attribute7;
  l_rec.lsf_attribute8                   := p_lsf_attribute8;
  l_rec.lsf_attribute9                   := p_lsf_attribute9;
  l_rec.lsf_attribute10                  := p_lsf_attribute10;
  l_rec.lsf_attribute11                  := p_lsf_attribute11;
  l_rec.lsf_attribute12                  := p_lsf_attribute12;
  l_rec.lsf_attribute13                  := p_lsf_attribute13;
  l_rec.lsf_attribute14                  := p_lsf_attribute14;
  l_rec.lsf_attribute15                  := p_lsf_attribute15;
  l_rec.lsf_attribute16                  := p_lsf_attribute16;
  l_rec.lsf_attribute17                  := p_lsf_attribute17;
  l_rec.lsf_attribute18                  := p_lsf_attribute18;
  l_rec.lsf_attribute19                  := p_lsf_attribute19;
  l_rec.lsf_attribute20                  := p_lsf_attribute20;
  l_rec.lsf_attribute21                  := p_lsf_attribute21;
  l_rec.lsf_attribute22                  := p_lsf_attribute22;
  l_rec.lsf_attribute23                  := p_lsf_attribute23;
  l_rec.lsf_attribute24                  := p_lsf_attribute24;
  l_rec.lsf_attribute25                  := p_lsf_attribute25;
  l_rec.lsf_attribute26                  := p_lsf_attribute26;
  l_rec.lsf_attribute27                  := p_lsf_attribute27;
  l_rec.lsf_attribute28                  := p_lsf_attribute28;
  l_rec.lsf_attribute29                  := p_lsf_attribute29;
  l_rec.lsf_attribute30                  := p_lsf_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.use_overid_svc_dt_flag           := p_use_overid_svc_dt_flag;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_lsf_shd;

/
