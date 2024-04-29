--------------------------------------------------------
--  DDL for Package Body BEN_YRP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_YRP_SHD" as
/* $Header: beyrprhi.pkb 120.0 2005/05/28 12:44:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_yrp_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_YR_PERDS_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;

  ElsIf (p_constraint_name = 'BEN_ENRT_PERD_FK2') Then
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME','BEN_YR_PERD');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
--    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;

  ElsIf (p_constraint_name = 'BEN_YR_PERDS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
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
  p_yr_perd_id                         in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		yr_perd_id,
	perds_in_yr_num,
	perd_tm_uom_cd,
	perd_typ_cd,
	end_date,
	start_date,
	lmtn_yr_strt_dt,
	lmtn_yr_end_dt,
	business_group_id,
	yrp_attribute_category,
	yrp_attribute1,
	yrp_attribute2,
	yrp_attribute3,
	yrp_attribute4,
	yrp_attribute5,
	yrp_attribute6,
	yrp_attribute7,
	yrp_attribute8,
	yrp_attribute9,
	yrp_attribute10,
	yrp_attribute11,
	yrp_attribute12,
	yrp_attribute13,
	yrp_attribute14,
	yrp_attribute15,
	yrp_attribute16,
	yrp_attribute17,
	yrp_attribute18,
	yrp_attribute19,
	yrp_attribute20,
	yrp_attribute21,
	yrp_attribute22,
	yrp_attribute23,
	yrp_attribute24,
	yrp_attribute25,
	yrp_attribute26,
	yrp_attribute27,
	yrp_attribute28,
	yrp_attribute29,
	yrp_attribute30,
	object_version_number
    from	ben_yr_perd
    where	yr_perd_id = p_yr_perd_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_yr_perd_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_yr_perd_id = g_old_rec.yr_perd_id and
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
  p_yr_perd_id                         in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	yr_perd_id,
	perds_in_yr_num,
	perd_tm_uom_cd,
	perd_typ_cd,
	end_date,
	start_date,
	lmtn_yr_strt_dt,
	lmtn_yr_end_dt,
	business_group_id,
	yrp_attribute_category,
	yrp_attribute1,
	yrp_attribute2,
	yrp_attribute3,
	yrp_attribute4,
	yrp_attribute5,
	yrp_attribute6,
	yrp_attribute7,
	yrp_attribute8,
	yrp_attribute9,
	yrp_attribute10,
	yrp_attribute11,
	yrp_attribute12,
	yrp_attribute13,
	yrp_attribute14,
	yrp_attribute15,
	yrp_attribute16,
	yrp_attribute17,
	yrp_attribute18,
	yrp_attribute19,
	yrp_attribute20,
	yrp_attribute21,
	yrp_attribute22,
	yrp_attribute23,
	yrp_attribute24,
	yrp_attribute25,
	yrp_attribute26,
	yrp_attribute27,
	yrp_attribute28,
	yrp_attribute29,
	yrp_attribute30,
	object_version_number
    from	ben_yr_perd
    where	yr_perd_id = p_yr_perd_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_yr_perd');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_yr_perd_id                    in number,
	p_perds_in_yr_num               in number,
	p_perd_tm_uom_cd                in varchar2,
	p_perd_typ_cd                   in varchar2,
	p_end_date                      in date,
	p_start_date                    in date,
	p_lmtn_yr_strt_dt               in date,
	p_lmtn_yr_end_dt                in date,
	p_business_group_id             in number,
	p_yrp_attribute_category        in varchar2,
	p_yrp_attribute1                in varchar2,
	p_yrp_attribute2                in varchar2,
	p_yrp_attribute3                in varchar2,
	p_yrp_attribute4                in varchar2,
	p_yrp_attribute5                in varchar2,
	p_yrp_attribute6                in varchar2,
	p_yrp_attribute7                in varchar2,
	p_yrp_attribute8                in varchar2,
	p_yrp_attribute9                in varchar2,
	p_yrp_attribute10               in varchar2,
	p_yrp_attribute11               in varchar2,
	p_yrp_attribute12               in varchar2,
	p_yrp_attribute13               in varchar2,
	p_yrp_attribute14               in varchar2,
	p_yrp_attribute15               in varchar2,
	p_yrp_attribute16               in varchar2,
	p_yrp_attribute17               in varchar2,
	p_yrp_attribute18               in varchar2,
	p_yrp_attribute19               in varchar2,
	p_yrp_attribute20               in varchar2,
	p_yrp_attribute21               in varchar2,
	p_yrp_attribute22               in varchar2,
	p_yrp_attribute23               in varchar2,
	p_yrp_attribute24               in varchar2,
	p_yrp_attribute25               in varchar2,
	p_yrp_attribute26               in varchar2,
	p_yrp_attribute27               in varchar2,
	p_yrp_attribute28               in varchar2,
	p_yrp_attribute29               in varchar2,
	p_yrp_attribute30               in varchar2,
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
  l_rec.yr_perd_id                       := p_yr_perd_id;
  l_rec.perds_in_yr_num                  := p_perds_in_yr_num;
  l_rec.perd_tm_uom_cd                   := p_perd_tm_uom_cd;
  l_rec.perd_typ_cd                      := p_perd_typ_cd;
  l_rec.end_date                         := p_end_date;
  l_rec.start_date                       := p_start_date;
  l_rec.lmtn_yr_strt_dt                  := p_lmtn_yr_strt_dt;
  l_rec.lmtn_yr_end_dt                   := p_lmtn_yr_end_dt;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.yrp_attribute_category           := p_yrp_attribute_category;
  l_rec.yrp_attribute1                   := p_yrp_attribute1;
  l_rec.yrp_attribute2                   := p_yrp_attribute2;
  l_rec.yrp_attribute3                   := p_yrp_attribute3;
  l_rec.yrp_attribute4                   := p_yrp_attribute4;
  l_rec.yrp_attribute5                   := p_yrp_attribute5;
  l_rec.yrp_attribute6                   := p_yrp_attribute6;
  l_rec.yrp_attribute7                   := p_yrp_attribute7;
  l_rec.yrp_attribute8                   := p_yrp_attribute8;
  l_rec.yrp_attribute9                   := p_yrp_attribute9;
  l_rec.yrp_attribute10                  := p_yrp_attribute10;
  l_rec.yrp_attribute11                  := p_yrp_attribute11;
  l_rec.yrp_attribute12                  := p_yrp_attribute12;
  l_rec.yrp_attribute13                  := p_yrp_attribute13;
  l_rec.yrp_attribute14                  := p_yrp_attribute14;
  l_rec.yrp_attribute15                  := p_yrp_attribute15;
  l_rec.yrp_attribute16                  := p_yrp_attribute16;
  l_rec.yrp_attribute17                  := p_yrp_attribute17;
  l_rec.yrp_attribute18                  := p_yrp_attribute18;
  l_rec.yrp_attribute19                  := p_yrp_attribute19;
  l_rec.yrp_attribute20                  := p_yrp_attribute20;
  l_rec.yrp_attribute21                  := p_yrp_attribute21;
  l_rec.yrp_attribute22                  := p_yrp_attribute22;
  l_rec.yrp_attribute23                  := p_yrp_attribute23;
  l_rec.yrp_attribute24                  := p_yrp_attribute24;
  l_rec.yrp_attribute25                  := p_yrp_attribute25;
  l_rec.yrp_attribute26                  := p_yrp_attribute26;
  l_rec.yrp_attribute27                  := p_yrp_attribute27;
  l_rec.yrp_attribute28                  := p_yrp_attribute28;
  l_rec.yrp_attribute29                  := p_yrp_attribute29;
  l_rec.yrp_attribute30                  := p_yrp_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_yrp_shd;

/
