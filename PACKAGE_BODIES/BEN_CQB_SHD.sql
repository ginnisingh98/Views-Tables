--------------------------------------------------------
--  DDL for Package Body BEN_CQB_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CQB_SHD" as
/* $Header: becqbrhi.pkb 115.7 2002/12/16 10:30:14 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cqb_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_CBR_QUALD_BNF_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_CBR_QUALD_BNF_DT3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_CBR_QUALD_BNF_DT4') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_CBR_QUALD_BNF_DT5') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
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
  p_cbr_quald_bnf_id                   in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		cbr_quald_bnf_id,
	quald_bnf_flag,
	cbr_elig_perd_strt_dt,
	cbr_elig_perd_end_dt,
	quald_bnf_person_id,
        pgm_id,
        ptip_id,
        pl_typ_id,
	cvrd_emp_person_id,
	cbr_inelg_rsn_cd,
	business_group_id,
	cqb_attribute_category,
	cqb_attribute1,
	cqb_attribute2,
	cqb_attribute3,
	cqb_attribute4,
	cqb_attribute5,
	cqb_attribute6,
	cqb_attribute7,
	cqb_attribute8,
	cqb_attribute9,
	cqb_attribute10,
	cqb_attribute11,
	cqb_attribute12,
	cqb_attribute13,
	cqb_attribute14,
	cqb_attribute15,
	cqb_attribute16,
	cqb_attribute17,
	cqb_attribute18,
	cqb_attribute19,
	cqb_attribute20,
	cqb_attribute21,
	cqb_attribute22,
	cqb_attribute23,
	cqb_attribute24,
	cqb_attribute25,
	cqb_attribute26,
	cqb_attribute27,
	cqb_attribute28,
	cqb_attribute29,
	cqb_attribute30,
	object_version_number
    from	ben_cbr_quald_bnf
    where	cbr_quald_bnf_id = p_cbr_quald_bnf_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_cbr_quald_bnf_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_cbr_quald_bnf_id = g_old_rec.cbr_quald_bnf_id and
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
  p_cbr_quald_bnf_id                   in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	cbr_quald_bnf_id,
	quald_bnf_flag,
	cbr_elig_perd_strt_dt,
	cbr_elig_perd_end_dt,
	quald_bnf_person_id,
        pgm_id,
        ptip_id,
        pl_typ_id,
	cvrd_emp_person_id,
	cbr_inelg_rsn_cd,
	business_group_id,
	cqb_attribute_category,
	cqb_attribute1,
	cqb_attribute2,
	cqb_attribute3,
	cqb_attribute4,
	cqb_attribute5,
	cqb_attribute6,
	cqb_attribute7,
	cqb_attribute8,
	cqb_attribute9,
	cqb_attribute10,
	cqb_attribute11,
	cqb_attribute12,
	cqb_attribute13,
	cqb_attribute14,
	cqb_attribute15,
	cqb_attribute16,
	cqb_attribute17,
	cqb_attribute18,
	cqb_attribute19,
	cqb_attribute20,
	cqb_attribute21,
	cqb_attribute22,
	cqb_attribute23,
	cqb_attribute24,
	cqb_attribute25,
	cqb_attribute26,
	cqb_attribute27,
	cqb_attribute28,
	cqb_attribute29,
	cqb_attribute30,
	object_version_number
    from	ben_cbr_quald_bnf
    where	cbr_quald_bnf_id = p_cbr_quald_bnf_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_cbr_quald_bnf');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_cbr_quald_bnf_id              in number,
	p_quald_bnf_flag                in varchar2,
	p_cbr_elig_perd_strt_dt         in date,
	p_cbr_elig_perd_end_dt          in date,
	p_quald_bnf_person_id           in number,
        p_pgm_id                        in number,
        p_ptip_id                       in number,
        p_pl_typ_id                     in number,
	p_cvrd_emp_person_id            in number,
	p_cbr_inelg_rsn_cd              in varchar2,
	p_business_group_id             in number,
	p_cqb_attribute_category        in varchar2,
	p_cqb_attribute1                in varchar2,
	p_cqb_attribute2                in varchar2,
	p_cqb_attribute3                in varchar2,
	p_cqb_attribute4                in varchar2,
	p_cqb_attribute5                in varchar2,
	p_cqb_attribute6                in varchar2,
	p_cqb_attribute7                in varchar2,
	p_cqb_attribute8                in varchar2,
	p_cqb_attribute9                in varchar2,
	p_cqb_attribute10               in varchar2,
	p_cqb_attribute11               in varchar2,
	p_cqb_attribute12               in varchar2,
	p_cqb_attribute13               in varchar2,
	p_cqb_attribute14               in varchar2,
	p_cqb_attribute15               in varchar2,
	p_cqb_attribute16               in varchar2,
	p_cqb_attribute17               in varchar2,
	p_cqb_attribute18               in varchar2,
	p_cqb_attribute19               in varchar2,
	p_cqb_attribute20               in varchar2,
	p_cqb_attribute21               in varchar2,
	p_cqb_attribute22               in varchar2,
	p_cqb_attribute23               in varchar2,
	p_cqb_attribute24               in varchar2,
	p_cqb_attribute25               in varchar2,
	p_cqb_attribute26               in varchar2,
	p_cqb_attribute27               in varchar2,
	p_cqb_attribute28               in varchar2,
	p_cqb_attribute29               in varchar2,
	p_cqb_attribute30               in varchar2,
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
  l_rec.cbr_quald_bnf_id                 := p_cbr_quald_bnf_id;
  l_rec.quald_bnf_flag                   := p_quald_bnf_flag;
  l_rec.cbr_elig_perd_strt_dt            := p_cbr_elig_perd_strt_dt;
  l_rec.cbr_elig_perd_end_dt             := p_cbr_elig_perd_end_dt;
  l_rec.quald_bnf_person_id              := p_quald_bnf_person_id;
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.ptip_id                          := p_ptip_id;
  l_rec.pl_typ_id                        := p_pl_typ_id;
  l_rec.cvrd_emp_person_id               := p_cvrd_emp_person_id;
  l_rec.cbr_inelg_rsn_cd                 := p_cbr_inelg_rsn_cd;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.cqb_attribute_category           := p_cqb_attribute_category;
  l_rec.cqb_attribute1                   := p_cqb_attribute1;
  l_rec.cqb_attribute2                   := p_cqb_attribute2;
  l_rec.cqb_attribute3                   := p_cqb_attribute3;
  l_rec.cqb_attribute4                   := p_cqb_attribute4;
  l_rec.cqb_attribute5                   := p_cqb_attribute5;
  l_rec.cqb_attribute6                   := p_cqb_attribute6;
  l_rec.cqb_attribute7                   := p_cqb_attribute7;
  l_rec.cqb_attribute8                   := p_cqb_attribute8;
  l_rec.cqb_attribute9                   := p_cqb_attribute9;
  l_rec.cqb_attribute10                  := p_cqb_attribute10;
  l_rec.cqb_attribute11                  := p_cqb_attribute11;
  l_rec.cqb_attribute12                  := p_cqb_attribute12;
  l_rec.cqb_attribute13                  := p_cqb_attribute13;
  l_rec.cqb_attribute14                  := p_cqb_attribute14;
  l_rec.cqb_attribute15                  := p_cqb_attribute15;
  l_rec.cqb_attribute16                  := p_cqb_attribute16;
  l_rec.cqb_attribute17                  := p_cqb_attribute17;
  l_rec.cqb_attribute18                  := p_cqb_attribute18;
  l_rec.cqb_attribute19                  := p_cqb_attribute19;
  l_rec.cqb_attribute20                  := p_cqb_attribute20;
  l_rec.cqb_attribute21                  := p_cqb_attribute21;
  l_rec.cqb_attribute22                  := p_cqb_attribute22;
  l_rec.cqb_attribute23                  := p_cqb_attribute23;
  l_rec.cqb_attribute24                  := p_cqb_attribute24;
  l_rec.cqb_attribute25                  := p_cqb_attribute25;
  l_rec.cqb_attribute26                  := p_cqb_attribute26;
  l_rec.cqb_attribute27                  := p_cqb_attribute27;
  l_rec.cqb_attribute28                  := p_cqb_attribute28;
  l_rec.cqb_attribute29                  := p_cqb_attribute29;
  l_rec.cqb_attribute30                  := p_cqb_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_cqb_shd;

/
