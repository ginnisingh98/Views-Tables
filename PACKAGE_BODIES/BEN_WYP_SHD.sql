--------------------------------------------------------
--  DDL for Package Body BEN_WYP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_WYP_SHD" as
/* $Header: bewyprhi.pkb 115.12 2003/01/01 00:03:22 mmudigon ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_wyp_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc    varchar2(72) := g_package||'return_api_dml_status';
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
  l_proc    varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_WTHN_YR_PERD_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_WTHN_YR_PERD_PK') Then
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
  p_wthn_yr_perd_id                    in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
        wthn_yr_perd_id,
    strt_day,
    end_day,
    strt_mo,
    end_mo,
        tm_uom,
    yr_perd_id,
    business_group_id,
    wyp_attribute_category,
    wyp_attribute1,
    wyp_attribute2,
    wyp_attribute3,
    wyp_attribute4,
    wyp_attribute5,
    wyp_attribute6,
    wyp_attribute7,
    wyp_attribute8,
    wyp_attribute9,
    wyp_attribute10,
    wyp_attribute11,
    wyp_attribute12,
    wyp_attribute13,
    wyp_attribute14,
    wyp_attribute15,
    wyp_attribute16,
    wyp_attribute17,
    wyp_attribute18,
    wyp_attribute19,
    wyp_attribute20,
    wyp_attribute21,
    wyp_attribute22,
    wyp_attribute23,
    wyp_attribute24,
    wyp_attribute25,
    wyp_attribute26,
    wyp_attribute27,
    wyp_attribute28,
    wyp_attribute29,
    wyp_attribute30,
    object_version_number
    from    ben_wthn_yr_perd
    where   wthn_yr_perd_id = p_wthn_yr_perd_id;
--
  l_proc    varchar2(72)    := g_package||'api_updating';
  l_fct_ret boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
    p_wthn_yr_perd_id is null and
    p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
    p_wthn_yr_perd_id = g_old_rec.wthn_yr_perd_id and
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
  p_wthn_yr_perd_id                    in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select  wthn_yr_perd_id,
    strt_day,
    end_day,
    strt_mo,
    end_mo,
        tm_uom,
    yr_perd_id,
    business_group_id,
    wyp_attribute_category,
    wyp_attribute1,
    wyp_attribute2,
    wyp_attribute3,
    wyp_attribute4,
    wyp_attribute5,
    wyp_attribute6,
    wyp_attribute7,
    wyp_attribute8,
    wyp_attribute9,
    wyp_attribute10,
    wyp_attribute11,
    wyp_attribute12,
    wyp_attribute13,
    wyp_attribute14,
    wyp_attribute15,
    wyp_attribute16,
    wyp_attribute17,
    wyp_attribute18,
    wyp_attribute19,
    wyp_attribute20,
    wyp_attribute21,
    wyp_attribute22,
    wyp_attribute23,
    wyp_attribute24,
    wyp_attribute25,
    wyp_attribute26,
    wyp_attribute27,
    wyp_attribute28,
    wyp_attribute29,
    wyp_attribute30,
    object_version_number
    from    ben_wthn_yr_perd
    where   wthn_yr_perd_id = p_wthn_yr_perd_id
    for update nowait;
--
  l_proc    varchar2(72) := g_package||'lck';
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_wthn_yr_perd');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
    (
    p_wthn_yr_perd_id               in number,
    p_strt_day                      in number,
    p_end_day                       in number,
    p_strt_mo                       in number,
    p_end_mo                        in number,
        p_tm_uom                        in varchar2,
    p_yr_perd_id                    in number,
    p_business_group_id             in number,
    p_wyp_attribute_category        in varchar2,
    p_wyp_attribute1                in varchar2,
    p_wyp_attribute2                in varchar2,
    p_wyp_attribute3                in varchar2,
    p_wyp_attribute4                in varchar2,
    p_wyp_attribute5                in varchar2,
    p_wyp_attribute6                in varchar2,
    p_wyp_attribute7                in varchar2,
    p_wyp_attribute8                in varchar2,
    p_wyp_attribute9                in varchar2,
    p_wyp_attribute10               in varchar2,
    p_wyp_attribute11               in varchar2,
    p_wyp_attribute12               in varchar2,
    p_wyp_attribute13               in varchar2,
    p_wyp_attribute14               in varchar2,
    p_wyp_attribute15               in varchar2,
    p_wyp_attribute16               in varchar2,
    p_wyp_attribute17               in varchar2,
    p_wyp_attribute18               in varchar2,
    p_wyp_attribute19               in varchar2,
    p_wyp_attribute20               in varchar2,
    p_wyp_attribute21               in varchar2,
    p_wyp_attribute22               in varchar2,
    p_wyp_attribute23               in varchar2,
    p_wyp_attribute24               in varchar2,
    p_wyp_attribute25               in varchar2,
    p_wyp_attribute26               in varchar2,
    p_wyp_attribute27               in varchar2,
    p_wyp_attribute28               in varchar2,
    p_wyp_attribute29               in varchar2,
    p_wyp_attribute30               in varchar2,
    p_object_version_number         in number
    )
    Return g_rec_type is
--
  l_rec   g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.wthn_yr_perd_id                  := p_wthn_yr_perd_id;
  l_rec.strt_day                         := p_strt_day;
  l_rec.end_day                          := p_end_day;
  l_rec.strt_mo                          := p_strt_mo;
  l_rec.end_mo                           := p_end_mo;
  l_rec.tm_uom                           := p_tm_uom;
  l_rec.yr_perd_id                       := p_yr_perd_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.wyp_attribute_category           := p_wyp_attribute_category;
  l_rec.wyp_attribute1                   := p_wyp_attribute1;
  l_rec.wyp_attribute2                   := p_wyp_attribute2;
  l_rec.wyp_attribute3                   := p_wyp_attribute3;
  l_rec.wyp_attribute4                   := p_wyp_attribute4;
  l_rec.wyp_attribute5                   := p_wyp_attribute5;
  l_rec.wyp_attribute6                   := p_wyp_attribute6;
  l_rec.wyp_attribute7                   := p_wyp_attribute7;
  l_rec.wyp_attribute8                   := p_wyp_attribute8;
  l_rec.wyp_attribute9                   := p_wyp_attribute9;
  l_rec.wyp_attribute10                  := p_wyp_attribute10;
  l_rec.wyp_attribute11                  := p_wyp_attribute11;
  l_rec.wyp_attribute12                  := p_wyp_attribute12;
  l_rec.wyp_attribute13                  := p_wyp_attribute13;
  l_rec.wyp_attribute14                  := p_wyp_attribute14;
  l_rec.wyp_attribute15                  := p_wyp_attribute15;
  l_rec.wyp_attribute16                  := p_wyp_attribute16;
  l_rec.wyp_attribute17                  := p_wyp_attribute17;
  l_rec.wyp_attribute18                  := p_wyp_attribute18;
  l_rec.wyp_attribute19                  := p_wyp_attribute19;
  l_rec.wyp_attribute20                  := p_wyp_attribute20;
  l_rec.wyp_attribute21                  := p_wyp_attribute21;
  l_rec.wyp_attribute22                  := p_wyp_attribute22;
  l_rec.wyp_attribute23                  := p_wyp_attribute23;
  l_rec.wyp_attribute24                  := p_wyp_attribute24;
  l_rec.wyp_attribute25                  := p_wyp_attribute25;
  l_rec.wyp_attribute26                  := p_wyp_attribute26;
  l_rec.wyp_attribute27                  := p_wyp_attribute27;
  l_rec.wyp_attribute28                  := p_wyp_attribute28;
  l_rec.wyp_attribute29                  := p_wyp_attribute29;
  l_rec.wyp_attribute30                  := p_wyp_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_wyp_shd;

/
