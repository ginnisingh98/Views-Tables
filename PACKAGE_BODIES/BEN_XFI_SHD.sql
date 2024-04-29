--------------------------------------------------------
--  DDL for Package Body BEN_XFI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XFI_SHD" as
/* $Header: bexfirhi.pkb 120.0 2005/05/28 12:33:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xfi_shd.';  -- Global package name
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
  cursor c1 is
    select xdf.name
      from ben_ext_dfn xdf
    where xdf.ext_file_id = g_old_rec.ext_file_id;

  l_name varchar2(100);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_EXT_FILE_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_FILE_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_RCD_IN_FILE_FK1') Then
    fnd_message.set_name('BEN', 'BEN_92485_XRF_EXISTS2');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_DFN_FK2') Then
    open c1;
    fetch c1 into l_name;
    close c1;
    fnd_message.set_name('BEN', 'BEN_92484_XDF_EXISTS');
    fnd_message.set_token('EXT_NAME', l_name);
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
  (
  p_ext_file_id                        in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
        ext_file_id,
	name,
	xml_tag_name,
	business_group_id,
	legislation_code,
	xfi_attribute_category,
	xfi_attribute1,
	xfi_attribute2,
	xfi_attribute3,
	xfi_attribute4,
	xfi_attribute5,
	xfi_attribute6,
	xfi_attribute7,
	xfi_attribute8,
	xfi_attribute9,
	xfi_attribute10,
	xfi_attribute11,
	xfi_attribute12,
	xfi_attribute13,
	xfi_attribute14,
	xfi_attribute15,
	xfi_attribute16,
	xfi_attribute17,
	xfi_attribute18,
	xfi_attribute19,
	xfi_attribute20,
	xfi_attribute21,
	xfi_attribute22,
	xfi_attribute23,
	xfi_attribute24,
	xfi_attribute25,
	xfi_attribute26,
	xfi_attribute27,
	xfi_attribute28,
	xfi_attribute29,
	xfi_attribute30,
        ext_rcd_in_file_id      ,
        ext_data_elmt_in_rcd_id1,
        ext_data_elmt_in_rcd_id2,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by ,
	object_version_number
    from	ben_ext_file
    where	ext_file_id = p_ext_file_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_ext_file_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_ext_file_id = g_old_rec.ext_file_id and
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
  p_ext_file_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	ext_file_id,
	name,
	xml_tag_name,
	business_group_id,
	legislation_code,
	xfi_attribute_category,
	xfi_attribute1,
	xfi_attribute2,
	xfi_attribute3,
	xfi_attribute4,
	xfi_attribute5,
	xfi_attribute6,
	xfi_attribute7,
	xfi_attribute8,
	xfi_attribute9,
	xfi_attribute10,
	xfi_attribute11,
	xfi_attribute12,
	xfi_attribute13,
	xfi_attribute14,
	xfi_attribute15,
	xfi_attribute16,
	xfi_attribute17,
	xfi_attribute18,
	xfi_attribute19,
	xfi_attribute20,
	xfi_attribute21,
	xfi_attribute22,
	xfi_attribute23,
	xfi_attribute24,
	xfi_attribute25,
	xfi_attribute26,
	xfi_attribute27,
	xfi_attribute28,
	xfi_attribute29,
	xfi_attribute30,
        ext_rcd_in_file_id ,
        ext_data_elmt_in_rcd_id1 ,
        ext_data_elmt_in_rcd_id2 ,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by ,
	object_version_number
    from	ben_ext_file
    where	ext_file_id = p_ext_file_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_ext_file');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_ext_file_id                   in number,
	p_name                          in varchar2,
	p_xml_tag_name                  in varchar2,
	p_business_group_id             in number,
	p_legislation_code              in varchar2,
	p_xfi_attribute_category        in varchar2,
	p_xfi_attribute1                in varchar2,
	p_xfi_attribute2                in varchar2,
	p_xfi_attribute3                in varchar2,
	p_xfi_attribute4                in varchar2,
	p_xfi_attribute5                in varchar2,
	p_xfi_attribute6                in varchar2,
	p_xfi_attribute7                in varchar2,
	p_xfi_attribute8                in varchar2,
	p_xfi_attribute9                in varchar2,
	p_xfi_attribute10               in varchar2,
	p_xfi_attribute11               in varchar2,
	p_xfi_attribute12               in varchar2,
	p_xfi_attribute13               in varchar2,
	p_xfi_attribute14               in varchar2,
	p_xfi_attribute15               in varchar2,
	p_xfi_attribute16               in varchar2,
	p_xfi_attribute17               in varchar2,
	p_xfi_attribute18               in varchar2,
	p_xfi_attribute19               in varchar2,
	p_xfi_attribute20               in varchar2,
	p_xfi_attribute21               in varchar2,
	p_xfi_attribute22               in varchar2,
	p_xfi_attribute23               in varchar2,
	p_xfi_attribute24               in varchar2,
	p_xfi_attribute25               in varchar2,
	p_xfi_attribute26               in varchar2,
	p_xfi_attribute27               in varchar2,
	p_xfi_attribute28               in varchar2,
	p_xfi_attribute29               in varchar2,
	p_xfi_attribute30               in varchar2,
        p_ext_rcd_in_file_id            in number       ,
        p_ext_data_elmt_in_rcd_id1      in number       ,
        p_ext_data_elmt_in_rcd_id2      in number       ,
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
  l_rec.ext_file_id                      := p_ext_file_id;
  l_rec.name                             := p_name;
  l_rec.xml_tag_name                     := p_xml_tag_name;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.xfi_attribute_category           := p_xfi_attribute_category;
  l_rec.xfi_attribute1                   := p_xfi_attribute1;
  l_rec.xfi_attribute2                   := p_xfi_attribute2;
  l_rec.xfi_attribute3                   := p_xfi_attribute3;
  l_rec.xfi_attribute4                   := p_xfi_attribute4;
  l_rec.xfi_attribute5                   := p_xfi_attribute5;
  l_rec.xfi_attribute6                   := p_xfi_attribute6;
  l_rec.xfi_attribute7                   := p_xfi_attribute7;
  l_rec.xfi_attribute8                   := p_xfi_attribute8;
  l_rec.xfi_attribute9                   := p_xfi_attribute9;
  l_rec.xfi_attribute10                  := p_xfi_attribute10;
  l_rec.xfi_attribute11                  := p_xfi_attribute11;
  l_rec.xfi_attribute12                  := p_xfi_attribute12;
  l_rec.xfi_attribute13                  := p_xfi_attribute13;
  l_rec.xfi_attribute14                  := p_xfi_attribute14;
  l_rec.xfi_attribute15                  := p_xfi_attribute15;
  l_rec.xfi_attribute16                  := p_xfi_attribute16;
  l_rec.xfi_attribute17                  := p_xfi_attribute17;
  l_rec.xfi_attribute18                  := p_xfi_attribute18;
  l_rec.xfi_attribute19                  := p_xfi_attribute19;
  l_rec.xfi_attribute20                  := p_xfi_attribute20;
  l_rec.xfi_attribute21                  := p_xfi_attribute21;
  l_rec.xfi_attribute22                  := p_xfi_attribute22;
  l_rec.xfi_attribute23                  := p_xfi_attribute23;
  l_rec.xfi_attribute24                  := p_xfi_attribute24;
  l_rec.xfi_attribute25                  := p_xfi_attribute25;
  l_rec.xfi_attribute26                  := p_xfi_attribute26;
  l_rec.xfi_attribute27                  := p_xfi_attribute27;
  l_rec.xfi_attribute28                  := p_xfi_attribute28;
  l_rec.xfi_attribute29                  := p_xfi_attribute29;
  l_rec.xfi_attribute30                  := p_xfi_attribute30;
  l_rec.ext_rcd_in_file_id               := p_ext_rcd_in_file_id;
  l_rec.ext_data_elmt_in_rcd_id1         := p_ext_data_elmt_in_rcd_id1 ;
  l_rec.ext_data_elmt_in_rcd_id2         := p_ext_data_elmt_in_rcd_id2 ;
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
end ben_xfi_shd;

/
