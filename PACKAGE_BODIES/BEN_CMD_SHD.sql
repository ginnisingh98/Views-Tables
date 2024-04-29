--------------------------------------------------------
--  DDL for Package Body BEN_CMD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CMD_SHD" as
/* $Header: becmdrhi.pkb 115.7 2002/12/31 23:57:12 mmudigon ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cmd_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_CM_DLVRY_MED_TYP_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_CM_DLVRY_MED_TYP_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_CM_DLVRY_MED_TYP_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
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
  p_cm_dlvry_med_typ_id                in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		cm_dlvry_med_typ_id,
	cm_dlvry_med_typ_cd,
	cm_dlvry_mthd_typ_id,
	rqd_flag,
	dflt_flag,
	business_group_id,
	cmd_attribute_category,
	cmd_attribute1,
	cmd_attribute2,
	cmd_attribute3,
	cmd_attribute4,
	cmd_attribute5,
	cmd_attribute6,
	cmd_attribute7,
	cmd_attribute8,
	cmd_attribute9,
	cmd_attribute10,
	cmd_attribute11,
	cmd_attribute12,
	cmd_attribute13,
	cmd_attribute14,
	cmd_attribute15,
	cmd_attribute16,
	cmd_attribute17,
	cmd_attribute18,
	cmd_attribute19,
	cmd_attribute20,
	cmd_attribute21,
	cmd_attribute22,
	cmd_attribute23,
	cmd_attribute24,
	cmd_attribute25,
	cmd_attribute26,
	cmd_attribute27,
	cmd_attribute28,
	cmd_attribute29,
	cmd_attribute30,
	object_version_number
    from	ben_cm_dlvry_med_typ
    where	cm_dlvry_med_typ_id = p_cm_dlvry_med_typ_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_cm_dlvry_med_typ_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_cm_dlvry_med_typ_id = g_old_rec.cm_dlvry_med_typ_id and
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
  p_cm_dlvry_med_typ_id                in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	cm_dlvry_med_typ_id,
	cm_dlvry_med_typ_cd,
	cm_dlvry_mthd_typ_id,
	rqd_flag,
	dflt_flag,
	business_group_id,
	cmd_attribute_category,
	cmd_attribute1,
	cmd_attribute2,
	cmd_attribute3,
	cmd_attribute4,
	cmd_attribute5,
	cmd_attribute6,
	cmd_attribute7,
	cmd_attribute8,
	cmd_attribute9,
	cmd_attribute10,
	cmd_attribute11,
	cmd_attribute12,
	cmd_attribute13,
	cmd_attribute14,
	cmd_attribute15,
	cmd_attribute16,
	cmd_attribute17,
	cmd_attribute18,
	cmd_attribute19,
	cmd_attribute20,
	cmd_attribute21,
	cmd_attribute22,
	cmd_attribute23,
	cmd_attribute24,
	cmd_attribute25,
	cmd_attribute26,
	cmd_attribute27,
	cmd_attribute28,
	cmd_attribute29,
	cmd_attribute30,
	object_version_number
    from	ben_cm_dlvry_med_typ
    where	cm_dlvry_med_typ_id = p_cm_dlvry_med_typ_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_cm_dlvry_med_typ');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_cm_dlvry_med_typ_id           in number,
	p_cm_dlvry_med_typ_cd           in varchar2,
	p_cm_dlvry_mthd_typ_id          in number,
	p_rqd_flag                      in varchar2,
	p_dflt_flag                     in varchar2,
	p_business_group_id             in number,
	p_cmd_attribute_category        in varchar2,
	p_cmd_attribute1                in varchar2,
	p_cmd_attribute2                in varchar2,
	p_cmd_attribute3                in varchar2,
	p_cmd_attribute4                in varchar2,
	p_cmd_attribute5                in varchar2,
	p_cmd_attribute6                in varchar2,
	p_cmd_attribute7                in varchar2,
	p_cmd_attribute8                in varchar2,
	p_cmd_attribute9                in varchar2,
	p_cmd_attribute10               in varchar2,
	p_cmd_attribute11               in varchar2,
	p_cmd_attribute12               in varchar2,
	p_cmd_attribute13               in varchar2,
	p_cmd_attribute14               in varchar2,
	p_cmd_attribute15               in varchar2,
	p_cmd_attribute16               in varchar2,
	p_cmd_attribute17               in varchar2,
	p_cmd_attribute18               in varchar2,
	p_cmd_attribute19               in varchar2,
	p_cmd_attribute20               in varchar2,
	p_cmd_attribute21               in varchar2,
	p_cmd_attribute22               in varchar2,
	p_cmd_attribute23               in varchar2,
	p_cmd_attribute24               in varchar2,
	p_cmd_attribute25               in varchar2,
	p_cmd_attribute26               in varchar2,
	p_cmd_attribute27               in varchar2,
	p_cmd_attribute28               in varchar2,
	p_cmd_attribute29               in varchar2,
	p_cmd_attribute30               in varchar2,
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
  l_rec.cm_dlvry_med_typ_id              := p_cm_dlvry_med_typ_id;
  l_rec.cm_dlvry_med_typ_cd              := p_cm_dlvry_med_typ_cd;
  l_rec.cm_dlvry_mthd_typ_id             := p_cm_dlvry_mthd_typ_id;
  l_rec.rqd_flag                         := p_rqd_flag;
  l_rec.dflt_flag                        := p_dflt_flag;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.cmd_attribute_category           := p_cmd_attribute_category;
  l_rec.cmd_attribute1                   := p_cmd_attribute1;
  l_rec.cmd_attribute2                   := p_cmd_attribute2;
  l_rec.cmd_attribute3                   := p_cmd_attribute3;
  l_rec.cmd_attribute4                   := p_cmd_attribute4;
  l_rec.cmd_attribute5                   := p_cmd_attribute5;
  l_rec.cmd_attribute6                   := p_cmd_attribute6;
  l_rec.cmd_attribute7                   := p_cmd_attribute7;
  l_rec.cmd_attribute8                   := p_cmd_attribute8;
  l_rec.cmd_attribute9                   := p_cmd_attribute9;
  l_rec.cmd_attribute10                  := p_cmd_attribute10;
  l_rec.cmd_attribute11                  := p_cmd_attribute11;
  l_rec.cmd_attribute12                  := p_cmd_attribute12;
  l_rec.cmd_attribute13                  := p_cmd_attribute13;
  l_rec.cmd_attribute14                  := p_cmd_attribute14;
  l_rec.cmd_attribute15                  := p_cmd_attribute15;
  l_rec.cmd_attribute16                  := p_cmd_attribute16;
  l_rec.cmd_attribute17                  := p_cmd_attribute17;
  l_rec.cmd_attribute18                  := p_cmd_attribute18;
  l_rec.cmd_attribute19                  := p_cmd_attribute19;
  l_rec.cmd_attribute20                  := p_cmd_attribute20;
  l_rec.cmd_attribute21                  := p_cmd_attribute21;
  l_rec.cmd_attribute22                  := p_cmd_attribute22;
  l_rec.cmd_attribute23                  := p_cmd_attribute23;
  l_rec.cmd_attribute24                  := p_cmd_attribute24;
  l_rec.cmd_attribute25                  := p_cmd_attribute25;
  l_rec.cmd_attribute26                  := p_cmd_attribute26;
  l_rec.cmd_attribute27                  := p_cmd_attribute27;
  l_rec.cmd_attribute28                  := p_cmd_attribute28;
  l_rec.cmd_attribute29                  := p_cmd_attribute29;
  l_rec.cmd_attribute30                  := p_cmd_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_cmd_shd;

/
