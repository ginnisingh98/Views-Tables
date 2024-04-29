--------------------------------------------------------
--  DDL for Package Body BEN_AGF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_AGF_SHD" as
/* $Header: beagfrhi.pkb 120.0 2005/05/28 00:23:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_agf_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_AGE_FCTR_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_AGE_FCTR_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_AGE_RT_F_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_AGE_RT_F');
  ElsIf (p_constraint_name = 'BEN_CMBN_AGE_LOS_FCTR_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_CMBN_AGE_LOS_FCTR');
  ElsIf (p_constraint_name = 'BEN_ELIG_AGE_CVG_F_FK3') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_ELIG_AGE_CVG_F');
  ElsIf (p_constraint_name = 'BEN_ELIG_AGE_PRTE_F_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_ELIG_AGE_PRTE_F');
  ElsIf (p_constraint_name = 'BEN_VSTG_AGE_RQMT_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_VSTG_AGE_RQMT_FK1');
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
  (
  p_age_fctr_id                        in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		age_fctr_id,
	name,
	mx_age_num,
	mn_age_num,
	age_uom,
	no_mn_age_flag,
	no_mx_age_flag,
        age_to_use_cd,
	age_det_cd,
	age_det_rl,
	rndg_cd,
	rndg_rl,
	age_calc_rl,
	business_group_id,
	agf_attribute_category,
	agf_attribute1,
	agf_attribute2,
	agf_attribute3,
	agf_attribute4,
	agf_attribute5,
	agf_attribute6,
	agf_attribute7,
	agf_attribute8,
	agf_attribute9,
	agf_attribute10,
	agf_attribute11,
	agf_attribute12,
	agf_attribute13,
	agf_attribute14,
	agf_attribute15,
	agf_attribute16,
	agf_attribute17,
	agf_attribute18,
	agf_attribute19,
	agf_attribute20,
	agf_attribute21,
	agf_attribute22,
	agf_attribute23,
	agf_attribute24,
	agf_attribute25,
	agf_attribute26,
	agf_attribute27,
	agf_attribute28,
	agf_attribute29,
	agf_attribute30,
	object_version_number
    from	ben_age_fctr
    where	age_fctr_id = p_age_fctr_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_age_fctr_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_age_fctr_id = g_old_rec.age_fctr_id and
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
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_age_fctr_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	age_fctr_id,
	name,
	mx_age_num,
	mn_age_num,
	age_uom,
	no_mn_age_flag,
	no_mx_age_flag,
        age_to_use_cd,
	age_det_cd,
	age_det_rl,
	rndg_cd,
	rndg_rl,
	age_calc_rl,
	business_group_id,
	agf_attribute_category,
	agf_attribute1,
	agf_attribute2,
	agf_attribute3,
	agf_attribute4,
	agf_attribute5,
	agf_attribute6,
	agf_attribute7,
	agf_attribute8,
	agf_attribute9,
	agf_attribute10,
	agf_attribute11,
	agf_attribute12,
	agf_attribute13,
	agf_attribute14,
	agf_attribute15,
	agf_attribute16,
	agf_attribute17,
	agf_attribute18,
	agf_attribute19,
	agf_attribute20,
	agf_attribute21,
	agf_attribute22,
	agf_attribute23,
	agf_attribute24,
	agf_attribute25,
	agf_attribute26,
	agf_attribute27,
	agf_attribute28,
	agf_attribute29,
	agf_attribute30,
	object_version_number
    from	ben_age_fctr
    where	age_fctr_id = p_age_fctr_id
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
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'ben_age_fctr');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_age_fctr_id                   in number,
	p_name                          in varchar2,
	p_mx_age_num                    in number,
	p_mn_age_num                    in number,
	p_age_uom                       in varchar2,
	p_no_mn_age_flag                in varchar2,
	p_no_mx_age_flag                in varchar2,
        p_age_to_use_cd                 in varchar2,
	p_age_det_cd                    in varchar2,
	p_age_det_rl                    in number,
	p_rndg_cd                       in varchar2,
	p_rndg_rl                       in number,
	p_age_calc_rl                   in number,
	p_business_group_id             in number,
	p_agf_attribute_category        in varchar2,
	p_agf_attribute1                in varchar2,
	p_agf_attribute2                in varchar2,
	p_agf_attribute3                in varchar2,
	p_agf_attribute4                in varchar2,
	p_agf_attribute5                in varchar2,
	p_agf_attribute6                in varchar2,
	p_agf_attribute7                in varchar2,
	p_agf_attribute8                in varchar2,
	p_agf_attribute9                in varchar2,
	p_agf_attribute10               in varchar2,
	p_agf_attribute11               in varchar2,
	p_agf_attribute12               in varchar2,
	p_agf_attribute13               in varchar2,
	p_agf_attribute14               in varchar2,
	p_agf_attribute15               in varchar2,
	p_agf_attribute16               in varchar2,
	p_agf_attribute17               in varchar2,
	p_agf_attribute18               in varchar2,
	p_agf_attribute19               in varchar2,
	p_agf_attribute20               in varchar2,
	p_agf_attribute21               in varchar2,
	p_agf_attribute22               in varchar2,
	p_agf_attribute23               in varchar2,
	p_agf_attribute24               in varchar2,
	p_agf_attribute25               in varchar2,
	p_agf_attribute26               in varchar2,
	p_agf_attribute27               in varchar2,
	p_agf_attribute28               in varchar2,
	p_agf_attribute29               in varchar2,
	p_agf_attribute30               in varchar2,
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
  l_rec.age_fctr_id                      := p_age_fctr_id;
  l_rec.name                             := p_name;
  l_rec.mx_age_num                       := p_mx_age_num;
  l_rec.mn_age_num                       := p_mn_age_num;
  l_rec.age_uom                          := p_age_uom;
  l_rec.no_mn_age_flag                   := p_no_mn_age_flag;
  l_rec.no_mx_age_flag                   := p_no_mx_age_flag;
  l_rec.age_to_use_cd                    := p_age_to_use_cd;
  l_rec.age_det_cd                       := p_age_det_cd;
  l_rec.age_det_rl                       := p_age_det_rl;
  l_rec.rndg_cd                          := p_rndg_cd;
  l_rec.rndg_rl                          := p_rndg_rl;
  l_rec.age_calc_rl                      := p_age_calc_rl;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.agf_attribute_category           := p_agf_attribute_category;
  l_rec.agf_attribute1                   := p_agf_attribute1;
  l_rec.agf_attribute2                   := p_agf_attribute2;
  l_rec.agf_attribute3                   := p_agf_attribute3;
  l_rec.agf_attribute4                   := p_agf_attribute4;
  l_rec.agf_attribute5                   := p_agf_attribute5;
  l_rec.agf_attribute6                   := p_agf_attribute6;
  l_rec.agf_attribute7                   := p_agf_attribute7;
  l_rec.agf_attribute8                   := p_agf_attribute8;
  l_rec.agf_attribute9                   := p_agf_attribute9;
  l_rec.agf_attribute10                  := p_agf_attribute10;
  l_rec.agf_attribute11                  := p_agf_attribute11;
  l_rec.agf_attribute12                  := p_agf_attribute12;
  l_rec.agf_attribute13                  := p_agf_attribute13;
  l_rec.agf_attribute14                  := p_agf_attribute14;
  l_rec.agf_attribute15                  := p_agf_attribute15;
  l_rec.agf_attribute16                  := p_agf_attribute16;
  l_rec.agf_attribute17                  := p_agf_attribute17;
  l_rec.agf_attribute18                  := p_agf_attribute18;
  l_rec.agf_attribute19                  := p_agf_attribute19;
  l_rec.agf_attribute20                  := p_agf_attribute20;
  l_rec.agf_attribute21                  := p_agf_attribute21;
  l_rec.agf_attribute22                  := p_agf_attribute22;
  l_rec.agf_attribute23                  := p_agf_attribute23;
  l_rec.agf_attribute24                  := p_agf_attribute24;
  l_rec.agf_attribute25                  := p_agf_attribute25;
  l_rec.agf_attribute26                  := p_agf_attribute26;
  l_rec.agf_attribute27                  := p_agf_attribute27;
  l_rec.agf_attribute28                  := p_agf_attribute28;
  l_rec.agf_attribute29                  := p_agf_attribute29;
  l_rec.agf_attribute30                  := p_agf_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_agf_shd;

/
