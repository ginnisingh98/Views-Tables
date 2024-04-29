--------------------------------------------------------
--  DDL for Package Body BEN_XCR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XCR_SHD" as
/* $Header: bexcrrhi.pkb 120.0 2005/05/28 12:25:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xcr_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_EXT_CRIT_PRFL_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_CRIT_PRFL_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_CRIT_TYP_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_EXT_CRIT_TYP');
  ElsIf (p_constraint_name = 'BEN_EXT_DFN_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_EXT_DFN');
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
  p_ext_crit_prfl_id                   in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	ext_crit_prfl_id,
	name,
	business_group_id,
	legislation_code,
	xcr_attribute_category,
	xcr_attribute1,
	xcr_attribute2,
	xcr_attribute3,
	xcr_attribute4,
	xcr_attribute5,
	xcr_attribute6,
	xcr_attribute7,
	xcr_attribute8,
	xcr_attribute9,
	xcr_attribute10,
	xcr_attribute11,
	xcr_attribute12,
	xcr_attribute13,
	xcr_attribute14,
	xcr_attribute15,
	xcr_attribute16,
	xcr_attribute17,
	xcr_attribute18,
	xcr_attribute19,
	xcr_attribute20,
	xcr_attribute21,
	xcr_attribute22,
	xcr_attribute23,
	xcr_attribute24,
	xcr_attribute25,
	xcr_attribute26,
	xcr_attribute27,
	xcr_attribute28,
	xcr_attribute29,
	xcr_attribute30,
	ext_global_flag,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by ,
	object_version_number
    from	ben_ext_crit_prfl
    where	ext_crit_prfl_id = p_ext_crit_prfl_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_ext_crit_prfl_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_ext_crit_prfl_id = g_old_rec.ext_crit_prfl_id and
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
  p_ext_crit_prfl_id                   in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
    	ext_crit_prfl_id,
	name,
	business_group_id,
	legislation_code,
	xcr_attribute_category,
	xcr_attribute1,
	xcr_attribute2,
	xcr_attribute3,
	xcr_attribute4,
	xcr_attribute5,
	xcr_attribute6,
	xcr_attribute7,
	xcr_attribute8,
	xcr_attribute9,
	xcr_attribute10,
	xcr_attribute11,
	xcr_attribute12,
	xcr_attribute13,
	xcr_attribute14,
	xcr_attribute15,
	xcr_attribute16,
	xcr_attribute17,
	xcr_attribute18,
	xcr_attribute19,
	xcr_attribute20,
	xcr_attribute21,
	xcr_attribute22,
	xcr_attribute23,
	xcr_attribute24,
	xcr_attribute25,
	xcr_attribute26,
	xcr_attribute27,
	xcr_attribute28,
	xcr_attribute29,
	xcr_attribute30,
	ext_global_flag,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by ,
	object_version_number
    from	ben_ext_crit_prfl
    where	ext_crit_prfl_id = p_ext_crit_prfl_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_ext_crit_prfl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_ext_crit_prfl_id              in number,
	p_name                          in varchar2,
	p_business_group_id             in number,
        p_legislation_code              in varchar2,
	p_xcr_attribute_category        in varchar2,
	p_xcr_attribute1                in varchar2,
	p_xcr_attribute2                in varchar2,
	p_xcr_attribute3                in varchar2,
	p_xcr_attribute4                in varchar2,
	p_xcr_attribute5                in varchar2,
	p_xcr_attribute6                in varchar2,
	p_xcr_attribute7                in varchar2,
	p_xcr_attribute8                in varchar2,
	p_xcr_attribute9                in varchar2,
	p_xcr_attribute10               in varchar2,
	p_xcr_attribute11               in varchar2,
	p_xcr_attribute12               in varchar2,
	p_xcr_attribute13               in varchar2,
	p_xcr_attribute14               in varchar2,
	p_xcr_attribute15               in varchar2,
	p_xcr_attribute16               in varchar2,
	p_xcr_attribute17               in varchar2,
	p_xcr_attribute18               in varchar2,
	p_xcr_attribute19               in varchar2,
	p_xcr_attribute20               in varchar2,
	p_xcr_attribute21               in varchar2,
	p_xcr_attribute22               in varchar2,
	p_xcr_attribute23               in varchar2,
	p_xcr_attribute24               in varchar2,
	p_xcr_attribute25               in varchar2,
	p_xcr_attribute26               in varchar2,
	p_xcr_attribute27               in varchar2,
	p_xcr_attribute28               in varchar2,
	p_xcr_attribute29               in varchar2,
	p_xcr_attribute30               in varchar2,
	p_ext_global_flag               in varchar2,
        p_last_update_date              in date,
        p_creation_date                 in date,
        p_last_updated_by               in number,
        p_last_update_login             in number,
        p_created_by                    in number,
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
  l_rec.ext_crit_prfl_id                 := p_ext_crit_prfl_id;
  l_rec.name                             := p_name;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.xcr_attribute_category           := p_xcr_attribute_category;
  l_rec.xcr_attribute1                   := p_xcr_attribute1;
  l_rec.xcr_attribute2                   := p_xcr_attribute2;
  l_rec.xcr_attribute3                   := p_xcr_attribute3;
  l_rec.xcr_attribute4                   := p_xcr_attribute4;
  l_rec.xcr_attribute5                   := p_xcr_attribute5;
  l_rec.xcr_attribute6                   := p_xcr_attribute6;
  l_rec.xcr_attribute7                   := p_xcr_attribute7;
  l_rec.xcr_attribute8                   := p_xcr_attribute8;
  l_rec.xcr_attribute9                   := p_xcr_attribute9;
  l_rec.xcr_attribute10                  := p_xcr_attribute10;
  l_rec.xcr_attribute11                  := p_xcr_attribute11;
  l_rec.xcr_attribute12                  := p_xcr_attribute12;
  l_rec.xcr_attribute13                  := p_xcr_attribute13;
  l_rec.xcr_attribute14                  := p_xcr_attribute14;
  l_rec.xcr_attribute15                  := p_xcr_attribute15;
  l_rec.xcr_attribute16                  := p_xcr_attribute16;
  l_rec.xcr_attribute17                  := p_xcr_attribute17;
  l_rec.xcr_attribute18                  := p_xcr_attribute18;
  l_rec.xcr_attribute19                  := p_xcr_attribute19;
  l_rec.xcr_attribute20                  := p_xcr_attribute20;
  l_rec.xcr_attribute21                  := p_xcr_attribute21;
  l_rec.xcr_attribute22                  := p_xcr_attribute22;
  l_rec.xcr_attribute23                  := p_xcr_attribute23;
  l_rec.xcr_attribute24                  := p_xcr_attribute24;
  l_rec.xcr_attribute25                  := p_xcr_attribute25;
  l_rec.xcr_attribute26                  := p_xcr_attribute26;
  l_rec.xcr_attribute27                  := p_xcr_attribute27;
  l_rec.xcr_attribute28                  := p_xcr_attribute28;
  l_rec.xcr_attribute29                  := p_xcr_attribute29;
  l_rec.xcr_attribute30                  := p_xcr_attribute30;
  l_rec.ext_global_flag                  := p_ext_global_flag;
  l_rec.last_update_date                 := p_last_update_date;
  l_rec.creation_date                    := p_creation_date;
  l_rec.last_updated_by                  := p_last_updated_by;
  l_rec.last_update_login                := p_last_update_login;
  l_rec.created_by                       := p_created_by;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_xcr_shd;

/
