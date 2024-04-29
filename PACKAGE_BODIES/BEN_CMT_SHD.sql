--------------------------------------------------------
--  DDL for Package Body BEN_CMT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CMT_SHD" as
/* $Header: becmtrhi.pkb 115.14 2002/12/31 23:57:48 mmudigon ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cmt_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_CM_DLVRY_MTHD_TYP_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_CM_DLVRY_MTHD_TYP_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_CM_DLVRY_MED_TYP_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_CM_DLVRY_MED_TYP');
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
  p_cm_dlvry_mthd_typ_id               in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		cm_dlvry_mthd_typ_id,
	cm_dlvry_mthd_typ_cd,
	business_group_id,
	cm_typ_id,
	cmt_attribute1,
	cmt_attribute10,
	cmt_attribute11,
	cmt_attribute12,
	cmt_attribute13,
	cmt_attribute14,
	cmt_attribute15,
	cmt_attribute16,
	cmt_attribute17,
	cmt_attribute18,
	cmt_attribute19,
	cmt_attribute2,
	cmt_attribute20,
	cmt_attribute21,
	cmt_attribute22,
	cmt_attribute23,
	cmt_attribute24,
	cmt_attribute25,
	cmt_attribute26,
	cmt_attribute27,
	cmt_attribute28,
	cmt_attribute29,
	cmt_attribute3,
	cmt_attribute30,
	rqd_flag,
	cmt_attribute_category,
	cmt_attribute4,
	cmt_attribute5,
	cmt_attribute6,
	cmt_attribute7,
	cmt_attribute8,
	cmt_attribute9,
	dflt_flag,
	object_version_number
    from	ben_cm_dlvry_mthd_typ
    where	cm_dlvry_mthd_typ_id = p_cm_dlvry_mthd_typ_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_cm_dlvry_mthd_typ_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_cm_dlvry_mthd_typ_id = g_old_rec.cm_dlvry_mthd_typ_id and
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
  p_cm_dlvry_mthd_typ_id               in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	cm_dlvry_mthd_typ_id,
	cm_dlvry_mthd_typ_cd,
	business_group_id,
	cm_typ_id,
	cmt_attribute1,
	cmt_attribute10,
	cmt_attribute11,
	cmt_attribute12,
	cmt_attribute13,
	cmt_attribute14,
	cmt_attribute15,
	cmt_attribute16,
	cmt_attribute17,
	cmt_attribute18,
	cmt_attribute19,
	cmt_attribute2,
	cmt_attribute20,
	cmt_attribute21,
	cmt_attribute22,
	cmt_attribute23,
	cmt_attribute24,
	cmt_attribute25,
	cmt_attribute26,
	cmt_attribute27,
	cmt_attribute28,
	cmt_attribute29,
	cmt_attribute3,
	cmt_attribute30,
	rqd_flag,
	cmt_attribute_category,
	cmt_attribute4,
	cmt_attribute5,
	cmt_attribute6,
	cmt_attribute7,
	cmt_attribute8,
	cmt_attribute9,
	dflt_flag,
	object_version_number
    from	ben_cm_dlvry_mthd_typ
    where	cm_dlvry_mthd_typ_id = p_cm_dlvry_mthd_typ_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_cm_dlvry_mthd_typ');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_cm_dlvry_mthd_typ_id          in number,
	p_cm_dlvry_mthd_typ_cd          in varchar2,
	p_business_group_id             in number,
	p_cm_typ_id                     in number,
	p_cmt_attribute1                in varchar2,
	p_cmt_attribute10               in varchar2,
	p_cmt_attribute11               in varchar2,
	p_cmt_attribute12               in varchar2,
	p_cmt_attribute13               in varchar2,
	p_cmt_attribute14               in varchar2,
	p_cmt_attribute15               in varchar2,
	p_cmt_attribute16               in varchar2,
	p_cmt_attribute17               in varchar2,
	p_cmt_attribute18               in varchar2,
	p_cmt_attribute19               in varchar2,
	p_cmt_attribute2                in varchar2,
	p_cmt_attribute20               in varchar2,
	p_cmt_attribute21               in varchar2,
	p_cmt_attribute22               in varchar2,
	p_cmt_attribute23               in varchar2,
	p_cmt_attribute24               in varchar2,
	p_cmt_attribute25               in varchar2,
	p_cmt_attribute26               in varchar2,
	p_cmt_attribute27               in varchar2,
	p_cmt_attribute28               in varchar2,
	p_cmt_attribute29               in varchar2,
	p_cmt_attribute3                in varchar2,
	p_cmt_attribute30               in varchar2,
	p_rqd_flag                      in varchar2,
	p_cmt_attribute_category        in varchar2,
	p_cmt_attribute4                in varchar2,
	p_cmt_attribute5                in varchar2,
	p_cmt_attribute6                in varchar2,
	p_cmt_attribute7                in varchar2,
	p_cmt_attribute8                in varchar2,
	p_cmt_attribute9                in varchar2,
	p_dflt_flag                     in varchar2,
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
  l_rec.cm_dlvry_mthd_typ_id             := p_cm_dlvry_mthd_typ_id;
  l_rec.cm_dlvry_mthd_typ_cd             := p_cm_dlvry_mthd_typ_cd;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.cm_typ_id                        := p_cm_typ_id;
  l_rec.cmt_attribute1                   := p_cmt_attribute1;
  l_rec.cmt_attribute10                  := p_cmt_attribute10;
  l_rec.cmt_attribute11                  := p_cmt_attribute11;
  l_rec.cmt_attribute12                  := p_cmt_attribute12;
  l_rec.cmt_attribute13                  := p_cmt_attribute13;
  l_rec.cmt_attribute14                  := p_cmt_attribute14;
  l_rec.cmt_attribute15                  := p_cmt_attribute15;
  l_rec.cmt_attribute16                  := p_cmt_attribute16;
  l_rec.cmt_attribute17                  := p_cmt_attribute17;
  l_rec.cmt_attribute18                  := p_cmt_attribute18;
  l_rec.cmt_attribute19                  := p_cmt_attribute19;
  l_rec.cmt_attribute2                   := p_cmt_attribute2;
  l_rec.cmt_attribute20                  := p_cmt_attribute20;
  l_rec.cmt_attribute21                  := p_cmt_attribute21;
  l_rec.cmt_attribute22                  := p_cmt_attribute22;
  l_rec.cmt_attribute23                  := p_cmt_attribute23;
  l_rec.cmt_attribute24                  := p_cmt_attribute24;
  l_rec.cmt_attribute25                  := p_cmt_attribute25;
  l_rec.cmt_attribute26                  := p_cmt_attribute26;
  l_rec.cmt_attribute27                  := p_cmt_attribute27;
  l_rec.cmt_attribute28                  := p_cmt_attribute28;
  l_rec.cmt_attribute29                  := p_cmt_attribute29;
  l_rec.cmt_attribute3                   := p_cmt_attribute3;
  l_rec.cmt_attribute30                  := p_cmt_attribute30;
  l_rec.rqd_flag                         := p_rqd_flag;
  l_rec.cmt_attribute_category           := p_cmt_attribute_category;
  l_rec.cmt_attribute4                   := p_cmt_attribute4;
  l_rec.cmt_attribute5                   := p_cmt_attribute5;
  l_rec.cmt_attribute6                   := p_cmt_attribute6;
  l_rec.cmt_attribute7                   := p_cmt_attribute7;
  l_rec.cmt_attribute8                   := p_cmt_attribute8;
  l_rec.cmt_attribute9                   := p_cmt_attribute9;
  l_rec.dflt_flag                        := p_dflt_flag;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_cmt_shd;

/
