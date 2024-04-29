--------------------------------------------------------
--  DDL for Package Body BEN_XRC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XRC_SHD" as
/* $Header: bexrcrhi.pkb 120.0 2005/05/28 12:37:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xrc_shd.';  -- Global package name
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
   select xfi.name
   from ben_ext_file xfi,
        ben_ext_rcd_in_file xrf
   where xrf.ext_rcd_id = g_old_rec.ext_rcd_id
   and  xrf.ext_file_id = xfi.ext_file_id;

  l_name ben_ext_file.name%type ;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_EXT_RCD_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_RCD_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_DATA_ELMT_IN_RCD_FK2') Then
    fnd_message.set_name('BEN', 'BEN_92482_XER_EXISTS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_RSLT_DTL_FK3') Then
    fnd_message.set_name('BEN', 'BEN_92483_XRD_EXISTS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_RCD_IN_FILE_FK2') Then
    open c1;
    fetch c1 into l_name;
    close c1;
    fnd_message.set_name('BEN', 'BEN_92481_XRF_EXISTS');
    fnd_message.set_token('FILE_NAME', l_name);
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
  p_ext_rcd_id                         in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		ext_rcd_id,
	name,
	xml_tag_name,
	rcd_type_cd,
	low_lvl_cd,
	business_group_id,
	legislation_code,
	xrc_attribute_category,
	xrc_attribute1,
	xrc_attribute2,
	xrc_attribute3,
	xrc_attribute4,
	xrc_attribute5,
	xrc_attribute6,
	xrc_attribute7,
	xrc_attribute8,
	xrc_attribute9,
	xrc_attribute10,
	xrc_attribute11,
	xrc_attribute12,
	xrc_attribute13,
	xrc_attribute14,
	xrc_attribute15,
	xrc_attribute16,
	xrc_attribute17,
	xrc_attribute18,
	xrc_attribute19,
	xrc_attribute20,
	xrc_attribute21,
	xrc_attribute22,
	xrc_attribute23,
	xrc_attribute24,
	xrc_attribute25,
	xrc_attribute26,
	xrc_attribute27,
	xrc_attribute28,
	xrc_attribute29,
	xrc_attribute30,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by ,
	object_version_number
    from	ben_ext_rcd
    where	ext_rcd_id = p_ext_rcd_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_ext_rcd_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_ext_rcd_id = g_old_rec.ext_rcd_id and
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
  p_ext_rcd_id                         in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	ext_rcd_id,
	name,
	xml_tag_name,
	rcd_type_cd,
	low_lvl_cd,
	business_group_id,
	legislation_code,
	xrc_attribute_category,
	xrc_attribute1,
	xrc_attribute2,
	xrc_attribute3,
	xrc_attribute4,
	xrc_attribute5,
	xrc_attribute6,
	xrc_attribute7,
	xrc_attribute8,
	xrc_attribute9,
	xrc_attribute10,
	xrc_attribute11,
	xrc_attribute12,
	xrc_attribute13,
	xrc_attribute14,
	xrc_attribute15,
	xrc_attribute16,
	xrc_attribute17,
	xrc_attribute18,
	xrc_attribute19,
	xrc_attribute20,
	xrc_attribute21,
	xrc_attribute22,
	xrc_attribute23,
	xrc_attribute24,
	xrc_attribute25,
	xrc_attribute26,
	xrc_attribute27,
	xrc_attribute28,
	xrc_attribute29,
	xrc_attribute30,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by ,
	object_version_number
    from	ben_ext_rcd
    where	ext_rcd_id = p_ext_rcd_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_ext_rcd');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_ext_rcd_id                    in number,
	p_name                          in varchar2,
	p_xml_tag_name                  in varchar2,
	p_rcd_type_cd                   in varchar2,
	p_low_lvl_cd                    in varchar2,
	p_business_group_id             in number,
	p_legislation_code              in varchar2,
	p_xrc_attribute_category        in varchar2,
	p_xrc_attribute1                in varchar2,
	p_xrc_attribute2                in varchar2,
	p_xrc_attribute3                in varchar2,
	p_xrc_attribute4                in varchar2,
	p_xrc_attribute5                in varchar2,
	p_xrc_attribute6                in varchar2,
	p_xrc_attribute7                in varchar2,
	p_xrc_attribute8                in varchar2,
	p_xrc_attribute9                in varchar2,
	p_xrc_attribute10               in varchar2,
	p_xrc_attribute11               in varchar2,
	p_xrc_attribute12               in varchar2,
	p_xrc_attribute13               in varchar2,
	p_xrc_attribute14               in varchar2,
	p_xrc_attribute15               in varchar2,
	p_xrc_attribute16               in varchar2,
	p_xrc_attribute17               in varchar2,
	p_xrc_attribute18               in varchar2,
	p_xrc_attribute19               in varchar2,
	p_xrc_attribute20               in varchar2,
	p_xrc_attribute21               in varchar2,
	p_xrc_attribute22               in varchar2,
	p_xrc_attribute23               in varchar2,
	p_xrc_attribute24               in varchar2,
	p_xrc_attribute25               in varchar2,
	p_xrc_attribute26               in varchar2,
	p_xrc_attribute27               in varchar2,
	p_xrc_attribute28               in varchar2,
	p_xrc_attribute29               in varchar2,
	p_xrc_attribute30               in varchar2,
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
  l_rec.ext_rcd_id                       := p_ext_rcd_id;
  l_rec.name                             := p_name;
  l_rec.xml_tag_name                     := p_xml_tag_name;
  l_rec.rcd_type_cd                      := p_rcd_type_cd;
  l_rec.low_lvl_cd                       := p_low_lvl_cd;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.xrc_attribute_category           := p_xrc_attribute_category;
  l_rec.xrc_attribute1                   := p_xrc_attribute1;
  l_rec.xrc_attribute2                   := p_xrc_attribute2;
  l_rec.xrc_attribute3                   := p_xrc_attribute3;
  l_rec.xrc_attribute4                   := p_xrc_attribute4;
  l_rec.xrc_attribute5                   := p_xrc_attribute5;
  l_rec.xrc_attribute6                   := p_xrc_attribute6;
  l_rec.xrc_attribute7                   := p_xrc_attribute7;
  l_rec.xrc_attribute8                   := p_xrc_attribute8;
  l_rec.xrc_attribute9                   := p_xrc_attribute9;
  l_rec.xrc_attribute10                  := p_xrc_attribute10;
  l_rec.xrc_attribute11                  := p_xrc_attribute11;
  l_rec.xrc_attribute12                  := p_xrc_attribute12;
  l_rec.xrc_attribute13                  := p_xrc_attribute13;
  l_rec.xrc_attribute14                  := p_xrc_attribute14;
  l_rec.xrc_attribute15                  := p_xrc_attribute15;
  l_rec.xrc_attribute16                  := p_xrc_attribute16;
  l_rec.xrc_attribute17                  := p_xrc_attribute17;
  l_rec.xrc_attribute18                  := p_xrc_attribute18;
  l_rec.xrc_attribute19                  := p_xrc_attribute19;
  l_rec.xrc_attribute20                  := p_xrc_attribute20;
  l_rec.xrc_attribute21                  := p_xrc_attribute21;
  l_rec.xrc_attribute22                  := p_xrc_attribute22;
  l_rec.xrc_attribute23                  := p_xrc_attribute23;
  l_rec.xrc_attribute24                  := p_xrc_attribute24;
  l_rec.xrc_attribute25                  := p_xrc_attribute25;
  l_rec.xrc_attribute26                  := p_xrc_attribute26;
  l_rec.xrc_attribute27                  := p_xrc_attribute27;
  l_rec.xrc_attribute28                  := p_xrc_attribute28;
  l_rec.xrc_attribute29                  := p_xrc_attribute29;
  l_rec.xrc_attribute30                  := p_xrc_attribute30;
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
end ben_xrc_shd;

/
