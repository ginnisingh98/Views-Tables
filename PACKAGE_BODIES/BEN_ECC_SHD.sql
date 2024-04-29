--------------------------------------------------------
--  DDL for Package Body BEN_ECC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ECC_SHD" as
/* $Header: beeccrhi.pkb 120.0 2005/05/28 01:49:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ecc_shd.';  -- Global package name
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
  If (p_constraint_name = 'AVCON_BEN_E_RQD_F_000') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELCTBL_CHC_CTFN_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELCTBL_CHC_CTFN_FK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
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
  p_elctbl_chc_ctfn_id                 in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		elctbl_chc_ctfn_id,
	enrt_ctfn_typ_cd,
	rqd_flag,
	elig_per_elctbl_chc_id,
	enrt_bnft_id,
	business_group_id,
	ecc_attribute_category,
	ecc_attribute1,
	ecc_attribute2,
	ecc_attribute3,
	ecc_attribute4,
	ecc_attribute5,
	ecc_attribute6,
	ecc_attribute7,
	ecc_attribute8,
	ecc_attribute9,
	ecc_attribute10,
	ecc_attribute11,
	ecc_attribute12,
	ecc_attribute13,
	ecc_attribute14,
	ecc_attribute15,
	ecc_attribute16,
	ecc_attribute17,
	ecc_attribute18,
	ecc_attribute19,
	ecc_attribute20,
	ecc_attribute21,
	ecc_attribute22,
	ecc_attribute23,
	ecc_attribute24,
	ecc_attribute25,
	ecc_attribute26,
	ecc_attribute27,
	ecc_attribute28,
	ecc_attribute29,
	ecc_attribute30,
        susp_if_ctfn_not_prvd_flag,
        ctfn_determine_cd,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_elctbl_chc_ctfn
    where	elctbl_chc_ctfn_id = p_elctbl_chc_ctfn_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_elctbl_chc_ctfn_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_elctbl_chc_ctfn_id = g_old_rec.elctbl_chc_ctfn_id and
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
  p_elctbl_chc_ctfn_id                 in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	elctbl_chc_ctfn_id,
	enrt_ctfn_typ_cd,
	rqd_flag,
	elig_per_elctbl_chc_id,
	enrt_bnft_id,
	business_group_id,
	ecc_attribute_category,
	ecc_attribute1,
	ecc_attribute2,
	ecc_attribute3,
	ecc_attribute4,
	ecc_attribute5,
	ecc_attribute6,
	ecc_attribute7,
	ecc_attribute8,
	ecc_attribute9,
	ecc_attribute10,
	ecc_attribute11,
	ecc_attribute12,
	ecc_attribute13,
	ecc_attribute14,
	ecc_attribute15,
	ecc_attribute16,
	ecc_attribute17,
	ecc_attribute18,
	ecc_attribute19,
	ecc_attribute20,
	ecc_attribute21,
	ecc_attribute22,
	ecc_attribute23,
	ecc_attribute24,
	ecc_attribute25,
	ecc_attribute26,
	ecc_attribute27,
	ecc_attribute28,
	ecc_attribute29,
	ecc_attribute30,
        susp_if_ctfn_not_prvd_flag,
        ctfn_determine_cd,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_elctbl_chc_ctfn
    where	elctbl_chc_ctfn_id = p_elctbl_chc_ctfn_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_elctbl_chc_ctfn');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_elctbl_chc_ctfn_id            in number,
	p_enrt_ctfn_typ_cd              in varchar2,
	p_rqd_flag                      in varchar2,
	p_elig_per_elctbl_chc_id        in number,
	p_enrt_bnft_id                  in number,
	p_business_group_id             in number,
	p_ecc_attribute_category        in varchar2,
	p_ecc_attribute1                in varchar2,
	p_ecc_attribute2                in varchar2,
	p_ecc_attribute3                in varchar2,
	p_ecc_attribute4                in varchar2,
	p_ecc_attribute5                in varchar2,
	p_ecc_attribute6                in varchar2,
	p_ecc_attribute7                in varchar2,
	p_ecc_attribute8                in varchar2,
	p_ecc_attribute9                in varchar2,
	p_ecc_attribute10               in varchar2,
	p_ecc_attribute11               in varchar2,
	p_ecc_attribute12               in varchar2,
	p_ecc_attribute13               in varchar2,
	p_ecc_attribute14               in varchar2,
	p_ecc_attribute15               in varchar2,
	p_ecc_attribute16               in varchar2,
	p_ecc_attribute17               in varchar2,
	p_ecc_attribute18               in varchar2,
	p_ecc_attribute19               in varchar2,
	p_ecc_attribute20               in varchar2,
	p_ecc_attribute21               in varchar2,
	p_ecc_attribute22               in varchar2,
	p_ecc_attribute23               in varchar2,
	p_ecc_attribute24               in varchar2,
	p_ecc_attribute25               in varchar2,
	p_ecc_attribute26               in varchar2,
	p_ecc_attribute27               in varchar2,
	p_ecc_attribute28               in varchar2,
	p_ecc_attribute29               in varchar2,
	p_ecc_attribute30               in varchar2,
        p_susp_if_ctfn_not_prvd_flag    in varchar2,
        p_ctfn_determine_cd             in varchar2,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
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
  l_rec.elctbl_chc_ctfn_id               := p_elctbl_chc_ctfn_id;
  l_rec.enrt_ctfn_typ_cd                 := p_enrt_ctfn_typ_cd;
  l_rec.rqd_flag                         := p_rqd_flag;
  l_rec.elig_per_elctbl_chc_id           := p_elig_per_elctbl_chc_id;
  l_rec.enrt_bnft_id                     := p_enrt_bnft_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.ecc_attribute_category           := p_ecc_attribute_category;
  l_rec.ecc_attribute1                   := p_ecc_attribute1;
  l_rec.ecc_attribute2                   := p_ecc_attribute2;
  l_rec.ecc_attribute3                   := p_ecc_attribute3;
  l_rec.ecc_attribute4                   := p_ecc_attribute4;
  l_rec.ecc_attribute5                   := p_ecc_attribute5;
  l_rec.ecc_attribute6                   := p_ecc_attribute6;
  l_rec.ecc_attribute7                   := p_ecc_attribute7;
  l_rec.ecc_attribute8                   := p_ecc_attribute8;
  l_rec.ecc_attribute9                   := p_ecc_attribute9;
  l_rec.ecc_attribute10                  := p_ecc_attribute10;
  l_rec.ecc_attribute11                  := p_ecc_attribute11;
  l_rec.ecc_attribute12                  := p_ecc_attribute12;
  l_rec.ecc_attribute13                  := p_ecc_attribute13;
  l_rec.ecc_attribute14                  := p_ecc_attribute14;
  l_rec.ecc_attribute15                  := p_ecc_attribute15;
  l_rec.ecc_attribute16                  := p_ecc_attribute16;
  l_rec.ecc_attribute17                  := p_ecc_attribute17;
  l_rec.ecc_attribute18                  := p_ecc_attribute18;
  l_rec.ecc_attribute19                  := p_ecc_attribute19;
  l_rec.ecc_attribute20                  := p_ecc_attribute20;
  l_rec.ecc_attribute21                  := p_ecc_attribute21;
  l_rec.ecc_attribute22                  := p_ecc_attribute22;
  l_rec.ecc_attribute23                  := p_ecc_attribute23;
  l_rec.ecc_attribute24                  := p_ecc_attribute24;
  l_rec.ecc_attribute25                  := p_ecc_attribute25;
  l_rec.ecc_attribute26                  := p_ecc_attribute26;
  l_rec.ecc_attribute27                  := p_ecc_attribute27;
  l_rec.ecc_attribute28                  := p_ecc_attribute28;
  l_rec.ecc_attribute29                  := p_ecc_attribute29;
  l_rec.ecc_attribute30                  := p_ecc_attribute30;
  l_rec.susp_if_ctfn_not_prvd_flag       := nvl(p_susp_if_ctfn_not_prvd_flag,'Y');
  l_rec.ctfn_determine_cd                := p_ctfn_determine_cd;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_ecc_shd;

/
