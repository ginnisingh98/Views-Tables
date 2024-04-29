--------------------------------------------------------
--  DDL for Package Body BEN_EPR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPR_SHD" as
/* $Header: beeprrhi.pkb 115.5 2002/12/09 12:52:58 lakrish ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_epr_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_ENRT_PREM_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ENRT_PREM_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ENRT_PREM_FK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ENRT_PREM_PK') Then
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
  (  p_enrt_prem_id                       in number,
     p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	enrt_prem_id,
	val,
	uom,
	elig_per_elctbl_chc_id,
	enrt_bnft_id,
	actl_prem_id,
	business_group_id,
	epr_attribute_category,
	epr_attribute1,
	epr_attribute2,
	epr_attribute3,
	epr_attribute4,
	epr_attribute5,
	epr_attribute6,
	epr_attribute7,
	epr_attribute8,
	epr_attribute9,
	epr_attribute10,
	epr_attribute11,
	epr_attribute12,
	epr_attribute13,
	epr_attribute14,
	epr_attribute15,
	epr_attribute16,
	epr_attribute17,
	epr_attribute18,
	epr_attribute19,
	epr_attribute20,
	epr_attribute21,
	epr_attribute22,
	epr_attribute23,
	epr_attribute24,
	epr_attribute25,
	epr_attribute26,
	epr_attribute27,
	epr_attribute28,
	epr_attribute29,
	epr_attribute30,
	object_version_number,
	request_id,
	program_application_id,
	program_id,
	program_update_date
    from	ben_enrt_prem
    where	enrt_prem_id = p_enrt_prem_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_enrt_prem_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_enrt_prem_id = g_old_rec.enrt_prem_id and
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
  p_enrt_prem_id                       in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	enrt_prem_id,
	val,
	uom,
	elig_per_elctbl_chc_id,
	enrt_bnft_id,
	actl_prem_id,
	business_group_id,
	epr_attribute_category,
	epr_attribute1,
	epr_attribute2,
	epr_attribute3,
	epr_attribute4,
	epr_attribute5,
	epr_attribute6,
	epr_attribute7,
	epr_attribute8,
	epr_attribute9,
	epr_attribute10,
	epr_attribute11,
	epr_attribute12,
	epr_attribute13,
	epr_attribute14,
	epr_attribute15,
	epr_attribute16,
	epr_attribute17,
	epr_attribute18,
	epr_attribute19,
	epr_attribute20,
	epr_attribute21,
	epr_attribute22,
	epr_attribute23,
	epr_attribute24,
	epr_attribute25,
	epr_attribute26,
	epr_attribute27,
	epr_attribute28,
	epr_attribute29,
	epr_attribute30,
	object_version_number,
	request_id,
	program_application_id,
	program_id,
	program_update_date
    from	ben_enrt_prem
    where	enrt_prem_id = p_enrt_prem_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_enrt_prem');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_enrt_prem_id                  in number,
	p_val                           in number,
	p_uom                           in varchar2,
	p_elig_per_elctbl_chc_id        in number,
	p_enrt_bnft_id                  in number,
	p_actl_prem_id                  in number,
	p_business_group_id             in number,
	p_epr_attribute_category        in varchar2,
	p_epr_attribute1                in varchar2,
	p_epr_attribute2                in varchar2,
	p_epr_attribute3                in varchar2,
	p_epr_attribute4                in varchar2,
	p_epr_attribute5                in varchar2,
	p_epr_attribute6                in varchar2,
	p_epr_attribute7                in varchar2,
	p_epr_attribute8                in varchar2,
	p_epr_attribute9                in varchar2,
	p_epr_attribute10               in varchar2,
	p_epr_attribute11               in varchar2,
	p_epr_attribute12               in varchar2,
	p_epr_attribute13               in varchar2,
	p_epr_attribute14               in varchar2,
	p_epr_attribute15               in varchar2,
	p_epr_attribute16               in varchar2,
	p_epr_attribute17               in varchar2,
	p_epr_attribute18               in varchar2,
	p_epr_attribute19               in varchar2,
	p_epr_attribute20               in varchar2,
	p_epr_attribute21               in varchar2,
	p_epr_attribute22               in varchar2,
	p_epr_attribute23               in varchar2,
	p_epr_attribute24               in varchar2,
	p_epr_attribute25               in varchar2,
	p_epr_attribute26               in varchar2,
	p_epr_attribute27               in varchar2,
	p_epr_attribute28               in varchar2,
	p_epr_attribute29               in varchar2,
	p_epr_attribute30               in varchar2,
	p_object_version_number         in number,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date
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
  l_rec.enrt_prem_id                     := p_enrt_prem_id;
  l_rec.val                              := p_val;
  l_rec.uom                              := p_uom;
  l_rec.elig_per_elctbl_chc_id           := p_elig_per_elctbl_chc_id;
  l_rec.enrt_bnft_id                     := p_enrt_bnft_id;
  l_rec.actl_prem_id                     := p_actl_prem_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.epr_attribute_category           := p_epr_attribute_category;
  l_rec.epr_attribute1                   := p_epr_attribute1;
  l_rec.epr_attribute2                   := p_epr_attribute2;
  l_rec.epr_attribute3                   := p_epr_attribute3;
  l_rec.epr_attribute4                   := p_epr_attribute4;
  l_rec.epr_attribute5                   := p_epr_attribute5;
  l_rec.epr_attribute6                   := p_epr_attribute6;
  l_rec.epr_attribute7                   := p_epr_attribute7;
  l_rec.epr_attribute8                   := p_epr_attribute8;
  l_rec.epr_attribute9                   := p_epr_attribute9;
  l_rec.epr_attribute10                  := p_epr_attribute10;
  l_rec.epr_attribute11                  := p_epr_attribute11;
  l_rec.epr_attribute12                  := p_epr_attribute12;
  l_rec.epr_attribute13                  := p_epr_attribute13;
  l_rec.epr_attribute14                  := p_epr_attribute14;
  l_rec.epr_attribute15                  := p_epr_attribute15;
  l_rec.epr_attribute16                  := p_epr_attribute16;
  l_rec.epr_attribute17                  := p_epr_attribute17;
  l_rec.epr_attribute18                  := p_epr_attribute18;
  l_rec.epr_attribute19                  := p_epr_attribute19;
  l_rec.epr_attribute20                  := p_epr_attribute20;
  l_rec.epr_attribute21                  := p_epr_attribute21;
  l_rec.epr_attribute22                  := p_epr_attribute22;
  l_rec.epr_attribute23                  := p_epr_attribute23;
  l_rec.epr_attribute24                  := p_epr_attribute24;
  l_rec.epr_attribute25                  := p_epr_attribute25;
  l_rec.epr_attribute26                  := p_epr_attribute26;
  l_rec.epr_attribute27                  := p_epr_attribute27;
  l_rec.epr_attribute28                  := p_epr_attribute28;
  l_rec.epr_attribute29                  := p_epr_attribute29;
  l_rec.epr_attribute30                  := p_epr_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_epr_shd;

/
