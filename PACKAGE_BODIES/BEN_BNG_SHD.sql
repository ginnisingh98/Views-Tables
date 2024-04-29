--------------------------------------------------------
--  DDL for Package Body BEN_BNG_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BNG_SHD" as
/* $Header: bebngrhi.pkb 120.0.12010000.2 2008/08/05 14:08:45 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bng_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_BENFTS_GRP_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_BENFTS_GRP_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_BNFTS_GRP_UK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_BENEFIT_ACTIONS_FK3') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_BENEFIT_ACTIONS');
  ElsIf (p_constraint_name = 'BEN_BENFTS_GRP_RT_F_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_BENFTS_GRP_RT_F');
  ElsIf (p_constraint_name = 'BEN_BENFTS_GRP_PRTE_F_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_BENFTS_GRP_PRTE_F');
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
  p_benfts_grp_id                      in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		benfts_grp_id,
	business_group_id,
	name,
	bng_desc,
	bng_attribute_category,
	bng_attribute1,
	bng_attribute2,
	bng_attribute3,
	bng_attribute4,
	bng_attribute5,
	bng_attribute6,
	bng_attribute7,
	bng_attribute8,
	bng_attribute9,
	bng_attribute10,
	bng_attribute11,
	bng_attribute12,
	bng_attribute13,
	bng_attribute14,
	bng_attribute15,
	bng_attribute16,
	bng_attribute17,
	bng_attribute18,
	bng_attribute19,
	bng_attribute20,
	bng_attribute21,
	bng_attribute22,
	bng_attribute23,
	bng_attribute24,
	bng_attribute25,
	bng_attribute26,
	bng_attribute27,
	bng_attribute28,
	bng_attribute29,
	bng_attribute30,
	object_version_number
    from	ben_benfts_grp
    where	benfts_grp_id = p_benfts_grp_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_benfts_grp_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_benfts_grp_id = g_old_rec.benfts_grp_id and
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
  p_benfts_grp_id                      in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	benfts_grp_id,
	business_group_id,
	name,
	bng_desc,
	bng_attribute_category,
	bng_attribute1,
	bng_attribute2,
	bng_attribute3,
	bng_attribute4,
	bng_attribute5,
	bng_attribute6,
	bng_attribute7,
	bng_attribute8,
	bng_attribute9,
	bng_attribute10,
	bng_attribute11,
	bng_attribute12,
	bng_attribute13,
	bng_attribute14,
	bng_attribute15,
	bng_attribute16,
	bng_attribute17,
	bng_attribute18,
	bng_attribute19,
	bng_attribute20,
	bng_attribute21,
	bng_attribute22,
	bng_attribute23,
	bng_attribute24,
	bng_attribute25,
	bng_attribute26,
	bng_attribute27,
	bng_attribute28,
	bng_attribute29,
	bng_attribute30,
	object_version_number
    from	ben_benfts_grp
    where	benfts_grp_id = p_benfts_grp_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_benfts_grp');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_benfts_grp_id                 in number,
	p_business_group_id             in number,
	p_name                          in varchar2,
	p_bng_desc                      in varchar2,
	p_bng_attribute_category        in varchar2,
	p_bng_attribute1                in varchar2,
	p_bng_attribute2                in varchar2,
	p_bng_attribute3                in varchar2,
	p_bng_attribute4                in varchar2,
	p_bng_attribute5                in varchar2,
	p_bng_attribute6                in varchar2,
	p_bng_attribute7                in varchar2,
	p_bng_attribute8                in varchar2,
	p_bng_attribute9                in varchar2,
	p_bng_attribute10               in varchar2,
	p_bng_attribute11               in varchar2,
	p_bng_attribute12               in varchar2,
	p_bng_attribute13               in varchar2,
	p_bng_attribute14               in varchar2,
	p_bng_attribute15               in varchar2,
	p_bng_attribute16               in varchar2,
	p_bng_attribute17               in varchar2,
	p_bng_attribute18               in varchar2,
	p_bng_attribute19               in varchar2,
	p_bng_attribute20               in varchar2,
	p_bng_attribute21               in varchar2,
	p_bng_attribute22               in varchar2,
	p_bng_attribute23               in varchar2,
	p_bng_attribute24               in varchar2,
	p_bng_attribute25               in varchar2,
	p_bng_attribute26               in varchar2,
	p_bng_attribute27               in varchar2,
	p_bng_attribute28               in varchar2,
	p_bng_attribute29               in varchar2,
	p_bng_attribute30               in varchar2,
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
  l_rec.benfts_grp_id                    := p_benfts_grp_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.name                             := p_name;
  l_rec.bng_desc                         := p_bng_desc;
  l_rec.bng_attribute_category           := p_bng_attribute_category;
  l_rec.bng_attribute1                   := p_bng_attribute1;
  l_rec.bng_attribute2                   := p_bng_attribute2;
  l_rec.bng_attribute3                   := p_bng_attribute3;
  l_rec.bng_attribute4                   := p_bng_attribute4;
  l_rec.bng_attribute5                   := p_bng_attribute5;
  l_rec.bng_attribute6                   := p_bng_attribute6;
  l_rec.bng_attribute7                   := p_bng_attribute7;
  l_rec.bng_attribute8                   := p_bng_attribute8;
  l_rec.bng_attribute9                   := p_bng_attribute9;
  l_rec.bng_attribute10                  := p_bng_attribute10;
  l_rec.bng_attribute11                  := p_bng_attribute11;
  l_rec.bng_attribute12                  := p_bng_attribute12;
  l_rec.bng_attribute13                  := p_bng_attribute13;
  l_rec.bng_attribute14                  := p_bng_attribute14;
  l_rec.bng_attribute15                  := p_bng_attribute15;
  l_rec.bng_attribute16                  := p_bng_attribute16;
  l_rec.bng_attribute17                  := p_bng_attribute17;
  l_rec.bng_attribute18                  := p_bng_attribute18;
  l_rec.bng_attribute19                  := p_bng_attribute19;
  l_rec.bng_attribute20                  := p_bng_attribute20;
  l_rec.bng_attribute21                  := p_bng_attribute21;
  l_rec.bng_attribute22                  := p_bng_attribute22;
  l_rec.bng_attribute23                  := p_bng_attribute23;
  l_rec.bng_attribute24                  := p_bng_attribute24;
  l_rec.bng_attribute25                  := p_bng_attribute25;
  l_rec.bng_attribute26                  := p_bng_attribute26;
  l_rec.bng_attribute27                  := p_bng_attribute27;
  l_rec.bng_attribute28                  := p_bng_attribute28;
  l_rec.bng_attribute29                  := p_bng_attribute29;
  l_rec.bng_attribute30                  := p_bng_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_bng_shd;

/
