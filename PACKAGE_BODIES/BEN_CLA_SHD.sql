--------------------------------------------------------
--  DDL for Package Body BEN_CLA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLA_SHD" as
/* $Header: beclarhi.pkb 120.0 2005/05/28 01:03:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cla_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_CMB_AGE_LGH_OF_SVC_FCT_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_CMB_AGE_LGH_OF_SVC_FCT_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_CMB_AGE_LGH_OF_SVC_FCT_FK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_CMB_AGE_LGTH_OF_SVC_FCT_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_CMBN_AGE_LOS_RT_F_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_CMBN_AGE_LOS_RT_F');
  ElsIf (p_constraint_name = 'BEN_ELIG_CMBN_AGE_LOS_PRTE_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_ELIG_CMBN_AGE_LOS_PRTE_F');
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
  p_cmbn_age_los_fctr_id               in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		cmbn_age_los_fctr_id,
	business_group_id,
	los_fctr_id,
	age_fctr_id,
	cmbnd_min_val,
	cmbnd_max_val,
	ordr_num,
	cla_attribute_category,
	cla_attribute1,
	cla_attribute2,
	cla_attribute3,
	cla_attribute4,
	cla_attribute5,
	cla_attribute6,
	cla_attribute7,
	cla_attribute8,
	cla_attribute9,
	cla_attribute10,
	cla_attribute11,
	cla_attribute12,
	cla_attribute13,
	cla_attribute14,
	cla_attribute15,
	cla_attribute16,
	cla_attribute17,
	cla_attribute18,
	cla_attribute19,
	cla_attribute20,
	cla_attribute21,
	cla_attribute22,
	cla_attribute23,
	cla_attribute24,
	cla_attribute25,
	cla_attribute26,
	cla_attribute27,
	cla_attribute28,
	cla_attribute29,
	cla_attribute30,
	object_version_number,
	name
    from	ben_cmbn_age_los_fctr
    where	cmbn_age_los_fctr_id = p_cmbn_age_los_fctr_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_cmbn_age_los_fctr_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_cmbn_age_los_fctr_id = g_old_rec.cmbn_age_los_fctr_id and
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
  p_cmbn_age_los_fctr_id               in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	cmbn_age_los_fctr_id,
	business_group_id,
	los_fctr_id,
	age_fctr_id,
	cmbnd_min_val,
	cmbnd_max_val,
	ordr_num,
	cla_attribute_category,
	cla_attribute1,
	cla_attribute2,
	cla_attribute3,
	cla_attribute4,
	cla_attribute5,
	cla_attribute6,
	cla_attribute7,
	cla_attribute8,
	cla_attribute9,
	cla_attribute10,
	cla_attribute11,
	cla_attribute12,
	cla_attribute13,
	cla_attribute14,
	cla_attribute15,
	cla_attribute16,
	cla_attribute17,
	cla_attribute18,
	cla_attribute19,
	cla_attribute20,
	cla_attribute21,
	cla_attribute22,
	cla_attribute23,
	cla_attribute24,
	cla_attribute25,
	cla_attribute26,
	cla_attribute27,
	cla_attribute28,
	cla_attribute29,
	cla_attribute30,
	object_version_number,
	name
    from	ben_cmbn_age_los_fctr
    where	cmbn_age_los_fctr_id = p_cmbn_age_los_fctr_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_cmbn_age_los_fctr');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_cmbn_age_los_fctr_id          in number,
	p_business_group_id             in number,
	p_los_fctr_id                   in number,
	p_age_fctr_id                   in number,
	p_cmbnd_min_val                 in number,
	p_cmbnd_max_val                 in number,
	p_ordr_num                      in number,
	p_cla_attribute_category        in varchar2,
	p_cla_attribute1                in varchar2,
	p_cla_attribute2                in varchar2,
	p_cla_attribute3                in varchar2,
	p_cla_attribute4                in varchar2,
	p_cla_attribute5                in varchar2,
	p_cla_attribute6                in varchar2,
	p_cla_attribute7                in varchar2,
	p_cla_attribute8                in varchar2,
	p_cla_attribute9                in varchar2,
	p_cla_attribute10               in varchar2,
	p_cla_attribute11               in varchar2,
	p_cla_attribute12               in varchar2,
	p_cla_attribute13               in varchar2,
	p_cla_attribute14               in varchar2,
	p_cla_attribute15               in varchar2,
	p_cla_attribute16               in varchar2,
	p_cla_attribute17               in varchar2,
	p_cla_attribute18               in varchar2,
	p_cla_attribute19               in varchar2,
	p_cla_attribute20               in varchar2,
	p_cla_attribute21               in varchar2,
	p_cla_attribute22               in varchar2,
	p_cla_attribute23               in varchar2,
	p_cla_attribute24               in varchar2,
	p_cla_attribute25               in varchar2,
	p_cla_attribute26               in varchar2,
	p_cla_attribute27               in varchar2,
	p_cla_attribute28               in varchar2,
	p_cla_attribute29               in varchar2,
	p_cla_attribute30               in varchar2,
	p_object_version_number         in number,
	p_name                          in varchar2
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
  l_rec.cmbn_age_los_fctr_id             := p_cmbn_age_los_fctr_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.los_fctr_id                      := p_los_fctr_id;
  l_rec.age_fctr_id                      := p_age_fctr_id;
  l_rec.cmbnd_min_val                    := p_cmbnd_min_val;
  l_rec.cmbnd_max_val                    := p_cmbnd_max_val;
  l_rec.ordr_num                         := p_ordr_num;
  l_rec.cla_attribute_category           := p_cla_attribute_category;
  l_rec.cla_attribute1                   := p_cla_attribute1;
  l_rec.cla_attribute2                   := p_cla_attribute2;
  l_rec.cla_attribute3                   := p_cla_attribute3;
  l_rec.cla_attribute4                   := p_cla_attribute4;
  l_rec.cla_attribute5                   := p_cla_attribute5;
  l_rec.cla_attribute6                   := p_cla_attribute6;
  l_rec.cla_attribute7                   := p_cla_attribute7;
  l_rec.cla_attribute8                   := p_cla_attribute8;
  l_rec.cla_attribute9                   := p_cla_attribute9;
  l_rec.cla_attribute10                  := p_cla_attribute10;
  l_rec.cla_attribute11                  := p_cla_attribute11;
  l_rec.cla_attribute12                  := p_cla_attribute12;
  l_rec.cla_attribute13                  := p_cla_attribute13;
  l_rec.cla_attribute14                  := p_cla_attribute14;
  l_rec.cla_attribute15                  := p_cla_attribute15;
  l_rec.cla_attribute16                  := p_cla_attribute16;
  l_rec.cla_attribute17                  := p_cla_attribute17;
  l_rec.cla_attribute18                  := p_cla_attribute18;
  l_rec.cla_attribute19                  := p_cla_attribute19;
  l_rec.cla_attribute20                  := p_cla_attribute20;
  l_rec.cla_attribute21                  := p_cla_attribute21;
  l_rec.cla_attribute22                  := p_cla_attribute22;
  l_rec.cla_attribute23                  := p_cla_attribute23;
  l_rec.cla_attribute24                  := p_cla_attribute24;
  l_rec.cla_attribute25                  := p_cla_attribute25;
  l_rec.cla_attribute26                  := p_cla_attribute26;
  l_rec.cla_attribute27                  := p_cla_attribute27;
  l_rec.cla_attribute28                  := p_cla_attribute28;
  l_rec.cla_attribute29                  := p_cla_attribute29;
  l_rec.cla_attribute30                  := p_cla_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.name                             := p_name;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_cla_shd;

/
