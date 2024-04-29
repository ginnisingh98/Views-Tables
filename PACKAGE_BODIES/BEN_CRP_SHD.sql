--------------------------------------------------------
--  DDL for Package Body BEN_CRP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CRP_SHD" as
/* $Header: becrprhi.pkb 115.4 2002/12/16 11:04:00 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_crp_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_CBR_PER_IN_LER_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_CBR_PER_IN_LER_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
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
  p_cbr_per_in_ler_id                  in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		cbr_per_in_ler_id,
	init_evt_flag,
	cnt_num,
	per_in_ler_id,
	cbr_quald_bnf_id,
	prvs_elig_perd_end_dt,
	business_group_id,
	crp_attribute_category,
	crp_attribute1,
	crp_attribute2,
	crp_attribute3,
	crp_attribute4,
	crp_attribute5,
	crp_attribute6,
	crp_attribute7,
	crp_attribute8,
	crp_attribute9,
	crp_attribute10,
	crp_attribute11,
	crp_attribute12,
	crp_attribute13,
	crp_attribute14,
	crp_attribute15,
	crp_attribute16,
	crp_attribute17,
	crp_attribute18,
	crp_attribute19,
	crp_attribute20,
	crp_attribute21,
	crp_attribute22,
	crp_attribute23,
	crp_attribute24,
	crp_attribute25,
	crp_attribute26,
	crp_attribute27,
	crp_attribute28,
	crp_attribute29,
	crp_attribute30,
	object_version_number
    from	ben_cbr_per_in_ler
    where	cbr_per_in_ler_id = p_cbr_per_in_ler_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_cbr_per_in_ler_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_cbr_per_in_ler_id = g_old_rec.cbr_per_in_ler_id and
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
  p_cbr_per_in_ler_id                  in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	cbr_per_in_ler_id,
	init_evt_flag,
	cnt_num,
	per_in_ler_id,
	cbr_quald_bnf_id,
	prvs_elig_perd_end_dt,
	business_group_id,
	crp_attribute_category,
	crp_attribute1,
	crp_attribute2,
	crp_attribute3,
	crp_attribute4,
	crp_attribute5,
	crp_attribute6,
	crp_attribute7,
	crp_attribute8,
	crp_attribute9,
	crp_attribute10,
	crp_attribute11,
	crp_attribute12,
	crp_attribute13,
	crp_attribute14,
	crp_attribute15,
	crp_attribute16,
	crp_attribute17,
	crp_attribute18,
	crp_attribute19,
	crp_attribute20,
	crp_attribute21,
	crp_attribute22,
	crp_attribute23,
	crp_attribute24,
	crp_attribute25,
	crp_attribute26,
	crp_attribute27,
	crp_attribute28,
	crp_attribute29,
	crp_attribute30,
	object_version_number
    from	ben_cbr_per_in_ler
    where	cbr_per_in_ler_id = p_cbr_per_in_ler_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_cbr_per_in_ler');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_cbr_per_in_ler_id             in number,
	p_init_evt_flag                 in varchar2,
	p_cnt_num                       in number,
	p_per_in_ler_id                 in number,
	p_cbr_quald_bnf_id              in number,
	p_prvs_elig_perd_end_dt         in date,
	p_business_group_id             in number,
	p_crp_attribute_category        in varchar2,
	p_crp_attribute1                in varchar2,
	p_crp_attribute2                in varchar2,
	p_crp_attribute3                in varchar2,
	p_crp_attribute4                in varchar2,
	p_crp_attribute5                in varchar2,
	p_crp_attribute6                in varchar2,
	p_crp_attribute7                in varchar2,
	p_crp_attribute8                in varchar2,
	p_crp_attribute9                in varchar2,
	p_crp_attribute10               in varchar2,
	p_crp_attribute11               in varchar2,
	p_crp_attribute12               in varchar2,
	p_crp_attribute13               in varchar2,
	p_crp_attribute14               in varchar2,
	p_crp_attribute15               in varchar2,
	p_crp_attribute16               in varchar2,
	p_crp_attribute17               in varchar2,
	p_crp_attribute18               in varchar2,
	p_crp_attribute19               in varchar2,
	p_crp_attribute20               in varchar2,
	p_crp_attribute21               in varchar2,
	p_crp_attribute22               in varchar2,
	p_crp_attribute23               in varchar2,
	p_crp_attribute24               in varchar2,
	p_crp_attribute25               in varchar2,
	p_crp_attribute26               in varchar2,
	p_crp_attribute27               in varchar2,
	p_crp_attribute28               in varchar2,
	p_crp_attribute29               in varchar2,
	p_crp_attribute30               in varchar2,
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
  l_rec.cbr_per_in_ler_id                := p_cbr_per_in_ler_id;
  l_rec.init_evt_flag                    := p_init_evt_flag;
  l_rec.cnt_num                          := p_cnt_num;
  l_rec.per_in_ler_id                    := p_per_in_ler_id;
  l_rec.cbr_quald_bnf_id                 := p_cbr_quald_bnf_id;
  l_rec.prvs_elig_perd_end_dt            := p_prvs_elig_perd_end_dt;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.crp_attribute_category           := p_crp_attribute_category;
  l_rec.crp_attribute1                   := p_crp_attribute1;
  l_rec.crp_attribute2                   := p_crp_attribute2;
  l_rec.crp_attribute3                   := p_crp_attribute3;
  l_rec.crp_attribute4                   := p_crp_attribute4;
  l_rec.crp_attribute5                   := p_crp_attribute5;
  l_rec.crp_attribute6                   := p_crp_attribute6;
  l_rec.crp_attribute7                   := p_crp_attribute7;
  l_rec.crp_attribute8                   := p_crp_attribute8;
  l_rec.crp_attribute9                   := p_crp_attribute9;
  l_rec.crp_attribute10                  := p_crp_attribute10;
  l_rec.crp_attribute11                  := p_crp_attribute11;
  l_rec.crp_attribute12                  := p_crp_attribute12;
  l_rec.crp_attribute13                  := p_crp_attribute13;
  l_rec.crp_attribute14                  := p_crp_attribute14;
  l_rec.crp_attribute15                  := p_crp_attribute15;
  l_rec.crp_attribute16                  := p_crp_attribute16;
  l_rec.crp_attribute17                  := p_crp_attribute17;
  l_rec.crp_attribute18                  := p_crp_attribute18;
  l_rec.crp_attribute19                  := p_crp_attribute19;
  l_rec.crp_attribute20                  := p_crp_attribute20;
  l_rec.crp_attribute21                  := p_crp_attribute21;
  l_rec.crp_attribute22                  := p_crp_attribute22;
  l_rec.crp_attribute23                  := p_crp_attribute23;
  l_rec.crp_attribute24                  := p_crp_attribute24;
  l_rec.crp_attribute25                  := p_crp_attribute25;
  l_rec.crp_attribute26                  := p_crp_attribute26;
  l_rec.crp_attribute27                  := p_crp_attribute27;
  l_rec.crp_attribute28                  := p_crp_attribute28;
  l_rec.crp_attribute29                  := p_crp_attribute29;
  l_rec.crp_attribute30                  := p_crp_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_crp_shd;

/
