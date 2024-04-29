--------------------------------------------------------
--  DDL for Package Body BEN_DRR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DRR_SHD" as
/* $Header: bedrrrhi.pkb 120.0 2005/05/28 01:40:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_drr_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_DSGN_RQMT_RLSHP_TYP_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
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
  p_dsgn_rqmt_rlshp_typ_id             in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		dsgn_rqmt_rlshp_typ_id,
	rlshp_typ_cd,
	dsgn_rqmt_id,
	business_group_id,
	drr_attribute_category,
	drr_attribute1,
	drr_attribute2,
	drr_attribute3,
	drr_attribute4,
	drr_attribute5,
	drr_attribute6,
	drr_attribute7,
	drr_attribute8,
	drr_attribute9,
	drr_attribute10,
	drr_attribute11,
	drr_attribute12,
	drr_attribute13,
	drr_attribute14,
	drr_attribute15,
	drr_attribute16,
	drr_attribute17,
	drr_attribute18,
	drr_attribute19,
	drr_attribute20,
	drr_attribute21,
	drr_attribute22,
	drr_attribute23,
	drr_attribute24,
	drr_attribute25,
	drr_attribute26,
	drr_attribute27,
	drr_attribute28,
	drr_attribute29,
	drr_attribute30,
	object_version_number
    from	ben_dsgn_rqmt_rlshp_typ
    where	dsgn_rqmt_rlshp_typ_id = p_dsgn_rqmt_rlshp_typ_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_dsgn_rqmt_rlshp_typ_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_dsgn_rqmt_rlshp_typ_id = g_old_rec.dsgn_rqmt_rlshp_typ_id and
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
  p_dsgn_rqmt_rlshp_typ_id             in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	dsgn_rqmt_rlshp_typ_id,
	rlshp_typ_cd,
	dsgn_rqmt_id,
	business_group_id,
	drr_attribute_category,
	drr_attribute1,
	drr_attribute2,
	drr_attribute3,
	drr_attribute4,
	drr_attribute5,
	drr_attribute6,
	drr_attribute7,
	drr_attribute8,
	drr_attribute9,
	drr_attribute10,
	drr_attribute11,
	drr_attribute12,
	drr_attribute13,
	drr_attribute14,
	drr_attribute15,
	drr_attribute16,
	drr_attribute17,
	drr_attribute18,
	drr_attribute19,
	drr_attribute20,
	drr_attribute21,
	drr_attribute22,
	drr_attribute23,
	drr_attribute24,
	drr_attribute25,
	drr_attribute26,
	drr_attribute27,
	drr_attribute28,
	drr_attribute29,
	drr_attribute30,
	object_version_number
    from	ben_dsgn_rqmt_rlshp_typ
    where	dsgn_rqmt_rlshp_typ_id = p_dsgn_rqmt_rlshp_typ_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_dsgn_rqmt_rlshp_typ');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_dsgn_rqmt_rlshp_typ_id        in number,
	p_rlshp_typ_cd                  in varchar2,
	p_dsgn_rqmt_id                  in number,
	p_business_group_id             in number,
	p_drr_attribute_category        in varchar2,
	p_drr_attribute1                in varchar2,
	p_drr_attribute2                in varchar2,
	p_drr_attribute3                in varchar2,
	p_drr_attribute4                in varchar2,
	p_drr_attribute5                in varchar2,
	p_drr_attribute6                in varchar2,
	p_drr_attribute7                in varchar2,
	p_drr_attribute8                in varchar2,
	p_drr_attribute9                in varchar2,
	p_drr_attribute10               in varchar2,
	p_drr_attribute11               in varchar2,
	p_drr_attribute12               in varchar2,
	p_drr_attribute13               in varchar2,
	p_drr_attribute14               in varchar2,
	p_drr_attribute15               in varchar2,
	p_drr_attribute16               in varchar2,
	p_drr_attribute17               in varchar2,
	p_drr_attribute18               in varchar2,
	p_drr_attribute19               in varchar2,
	p_drr_attribute20               in varchar2,
	p_drr_attribute21               in varchar2,
	p_drr_attribute22               in varchar2,
	p_drr_attribute23               in varchar2,
	p_drr_attribute24               in varchar2,
	p_drr_attribute25               in varchar2,
	p_drr_attribute26               in varchar2,
	p_drr_attribute27               in varchar2,
	p_drr_attribute28               in varchar2,
	p_drr_attribute29               in varchar2,
	p_drr_attribute30               in varchar2,
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
  l_rec.dsgn_rqmt_rlshp_typ_id           := p_dsgn_rqmt_rlshp_typ_id;
  l_rec.rlshp_typ_cd                     := p_rlshp_typ_cd;
  l_rec.dsgn_rqmt_id                     := p_dsgn_rqmt_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.drr_attribute_category           := p_drr_attribute_category;
  l_rec.drr_attribute1                   := p_drr_attribute1;
  l_rec.drr_attribute2                   := p_drr_attribute2;
  l_rec.drr_attribute3                   := p_drr_attribute3;
  l_rec.drr_attribute4                   := p_drr_attribute4;
  l_rec.drr_attribute5                   := p_drr_attribute5;
  l_rec.drr_attribute6                   := p_drr_attribute6;
  l_rec.drr_attribute7                   := p_drr_attribute7;
  l_rec.drr_attribute8                   := p_drr_attribute8;
  l_rec.drr_attribute9                   := p_drr_attribute9;
  l_rec.drr_attribute10                  := p_drr_attribute10;
  l_rec.drr_attribute11                  := p_drr_attribute11;
  l_rec.drr_attribute12                  := p_drr_attribute12;
  l_rec.drr_attribute13                  := p_drr_attribute13;
  l_rec.drr_attribute14                  := p_drr_attribute14;
  l_rec.drr_attribute15                  := p_drr_attribute15;
  l_rec.drr_attribute16                  := p_drr_attribute16;
  l_rec.drr_attribute17                  := p_drr_attribute17;
  l_rec.drr_attribute18                  := p_drr_attribute18;
  l_rec.drr_attribute19                  := p_drr_attribute19;
  l_rec.drr_attribute20                  := p_drr_attribute20;
  l_rec.drr_attribute21                  := p_drr_attribute21;
  l_rec.drr_attribute22                  := p_drr_attribute22;
  l_rec.drr_attribute23                  := p_drr_attribute23;
  l_rec.drr_attribute24                  := p_drr_attribute24;
  l_rec.drr_attribute25                  := p_drr_attribute25;
  l_rec.drr_attribute26                  := p_drr_attribute26;
  l_rec.drr_attribute27                  := p_drr_attribute27;
  l_rec.drr_attribute28                  := p_drr_attribute28;
  l_rec.drr_attribute29                  := p_drr_attribute29;
  l_rec.drr_attribute30                  := p_drr_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_drr_shd;

/
