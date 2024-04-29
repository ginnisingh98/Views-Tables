--------------------------------------------------------
--  DDL for Package Body BEN_GOS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_GOS_SHD" as
/* $Header: begosrhi.pkb 120.0 2005/05/28 03:08:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_gos_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_GD_OR_SVC_TYP_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_GD_OR_SVC_TYP_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_GD_OR_SVC_TYP_UK1') Then
    fnd_message.set_name('BEN', 'BEN_91009_NAME_NOT_UNIQUE');
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
  p_gd_or_svc_typ_id                   in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		gd_or_svc_typ_id,
	business_group_id,
	name,
	typ_cd,
	description,
	gos_attribute_category,
	gos_attribute1,
	gos_attribute2,
	gos_attribute3,
	gos_attribute4,
	gos_attribute5,
	gos_attribute6,
	gos_attribute7,
	gos_attribute8,
	gos_attribute9,
	gos_attribute10,
	gos_attribute11,
	gos_attribute12,
	gos_attribute13,
	gos_attribute14,
	gos_attribute15,
	gos_attribute16,
	gos_attribute17,
	gos_attribute18,
	gos_attribute19,
	gos_attribute20,
	gos_attribute21,
	gos_attribute22,
	gos_attribute23,
	gos_attribute24,
	gos_attribute25,
	gos_attribute26,
	gos_attribute27,
	gos_attribute28,
	gos_attribute29,
	gos_attribute30,
	object_version_number
    from	ben_gd_or_svc_typ
    where	gd_or_svc_typ_id = p_gd_or_svc_typ_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_gd_or_svc_typ_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_gd_or_svc_typ_id = g_old_rec.gd_or_svc_typ_id and
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
  p_gd_or_svc_typ_id                   in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	gd_or_svc_typ_id,
	business_group_id,
	name,
	typ_cd,
	description,
	gos_attribute_category,
	gos_attribute1,
	gos_attribute2,
	gos_attribute3,
	gos_attribute4,
	gos_attribute5,
	gos_attribute6,
	gos_attribute7,
	gos_attribute8,
	gos_attribute9,
	gos_attribute10,
	gos_attribute11,
	gos_attribute12,
	gos_attribute13,
	gos_attribute14,
	gos_attribute15,
	gos_attribute16,
	gos_attribute17,
	gos_attribute18,
	gos_attribute19,
	gos_attribute20,
	gos_attribute21,
	gos_attribute22,
	gos_attribute23,
	gos_attribute24,
	gos_attribute25,
	gos_attribute26,
	gos_attribute27,
	gos_attribute28,
	gos_attribute29,
	gos_attribute30,
	object_version_number
    from	ben_gd_or_svc_typ
    where	gd_or_svc_typ_id = p_gd_or_svc_typ_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_gd_or_svc_typ');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_gd_or_svc_typ_id              in number,
	p_business_group_id             in number,
	p_name                          in varchar2,
	p_typ_cd                        in varchar2,
	p_description                   in varchar2,
	p_gos_attribute_category        in varchar2,
	p_gos_attribute1                in varchar2,
	p_gos_attribute2                in varchar2,
	p_gos_attribute3                in varchar2,
	p_gos_attribute4                in varchar2,
	p_gos_attribute5                in varchar2,
	p_gos_attribute6                in varchar2,
	p_gos_attribute7                in varchar2,
	p_gos_attribute8                in varchar2,
	p_gos_attribute9                in varchar2,
	p_gos_attribute10               in varchar2,
	p_gos_attribute11               in varchar2,
	p_gos_attribute12               in varchar2,
	p_gos_attribute13               in varchar2,
	p_gos_attribute14               in varchar2,
	p_gos_attribute15               in varchar2,
	p_gos_attribute16               in varchar2,
	p_gos_attribute17               in varchar2,
	p_gos_attribute18               in varchar2,
	p_gos_attribute19               in varchar2,
	p_gos_attribute20               in varchar2,
	p_gos_attribute21               in varchar2,
	p_gos_attribute22               in varchar2,
	p_gos_attribute23               in varchar2,
	p_gos_attribute24               in varchar2,
	p_gos_attribute25               in varchar2,
	p_gos_attribute26               in varchar2,
	p_gos_attribute27               in varchar2,
	p_gos_attribute28               in varchar2,
	p_gos_attribute29               in varchar2,
	p_gos_attribute30               in varchar2,
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
  l_rec.gd_or_svc_typ_id                 := p_gd_or_svc_typ_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.name                             := p_name;
  l_rec.typ_cd                           := p_typ_cd;
  l_rec.description                      := p_description;
  l_rec.gos_attribute_category           := p_gos_attribute_category;
  l_rec.gos_attribute1                   := p_gos_attribute1;
  l_rec.gos_attribute2                   := p_gos_attribute2;
  l_rec.gos_attribute3                   := p_gos_attribute3;
  l_rec.gos_attribute4                   := p_gos_attribute4;
  l_rec.gos_attribute5                   := p_gos_attribute5;
  l_rec.gos_attribute6                   := p_gos_attribute6;
  l_rec.gos_attribute7                   := p_gos_attribute7;
  l_rec.gos_attribute8                   := p_gos_attribute8;
  l_rec.gos_attribute9                   := p_gos_attribute9;
  l_rec.gos_attribute10                  := p_gos_attribute10;
  l_rec.gos_attribute11                  := p_gos_attribute11;
  l_rec.gos_attribute12                  := p_gos_attribute12;
  l_rec.gos_attribute13                  := p_gos_attribute13;
  l_rec.gos_attribute14                  := p_gos_attribute14;
  l_rec.gos_attribute15                  := p_gos_attribute15;
  l_rec.gos_attribute16                  := p_gos_attribute16;
  l_rec.gos_attribute17                  := p_gos_attribute17;
  l_rec.gos_attribute18                  := p_gos_attribute18;
  l_rec.gos_attribute19                  := p_gos_attribute19;
  l_rec.gos_attribute20                  := p_gos_attribute20;
  l_rec.gos_attribute21                  := p_gos_attribute21;
  l_rec.gos_attribute22                  := p_gos_attribute22;
  l_rec.gos_attribute23                  := p_gos_attribute23;
  l_rec.gos_attribute24                  := p_gos_attribute24;
  l_rec.gos_attribute25                  := p_gos_attribute25;
  l_rec.gos_attribute26                  := p_gos_attribute26;
  l_rec.gos_attribute27                  := p_gos_attribute27;
  l_rec.gos_attribute28                  := p_gos_attribute28;
  l_rec.gos_attribute29                  := p_gos_attribute29;
  l_rec.gos_attribute30                  := p_gos_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_gos_shd;

/
