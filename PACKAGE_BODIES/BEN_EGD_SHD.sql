--------------------------------------------------------
--  DDL for Package Body BEN_EGD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EGD_SHD" as
/* $Header: beegdrhi.pkb 120.0.12010000.2 2008/08/05 14:24:02 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_egd_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_ELIG_DPNT_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_DPNT_PK') Then
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
  p_elig_dpnt_id                       in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		elig_dpnt_id,
	create_dt,
	elig_strt_dt,
	elig_thru_dt,
	ovrdn_flag,
	ovrdn_thru_dt,
	inelg_rsn_cd,
	dpnt_inelig_flag,
	elig_per_elctbl_chc_id,
	per_in_ler_id,
	elig_per_id,
	elig_per_opt_id,
	elig_cvrd_dpnt_id,
	dpnt_person_id,
	business_group_id,
	egd_attribute_category,
	egd_attribute1,
	egd_attribute2,
	egd_attribute3,
	egd_attribute4,
	egd_attribute5,
	egd_attribute6,
	egd_attribute7,
	egd_attribute8,
	egd_attribute9,
	egd_attribute10,
	egd_attribute11,
	egd_attribute12,
	egd_attribute13,
	egd_attribute14,
	egd_attribute15,
	egd_attribute16,
	egd_attribute17,
	egd_attribute18,
	egd_attribute19,
	egd_attribute20,
	egd_attribute21,
	egd_attribute22,
	egd_attribute23,
	egd_attribute24,
	egd_attribute25,
	egd_attribute26,
	egd_attribute27,
	egd_attribute28,
	egd_attribute29,
	egd_attribute30,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_elig_dpnt
    where	elig_dpnt_id = p_elig_dpnt_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_elig_dpnt_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_elig_dpnt_id = g_old_rec.elig_dpnt_id and
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
  p_elig_dpnt_id                       in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	elig_dpnt_id,
	create_dt,
	elig_strt_dt,
	elig_thru_dt,
	ovrdn_flag,
	ovrdn_thru_dt,
	inelg_rsn_cd,
	dpnt_inelig_flag,
	elig_per_elctbl_chc_id,
	per_in_ler_id,
	elig_per_id,
	elig_per_opt_id,
	elig_cvrd_dpnt_id,
	dpnt_person_id,
	business_group_id,
	egd_attribute_category,
	egd_attribute1,
	egd_attribute2,
	egd_attribute3,
	egd_attribute4,
	egd_attribute5,
	egd_attribute6,
	egd_attribute7,
	egd_attribute8,
	egd_attribute9,
	egd_attribute10,
	egd_attribute11,
	egd_attribute12,
	egd_attribute13,
	egd_attribute14,
	egd_attribute15,
	egd_attribute16,
	egd_attribute17,
	egd_attribute18,
	egd_attribute19,
	egd_attribute20,
	egd_attribute21,
	egd_attribute22,
	egd_attribute23,
	egd_attribute24,
	egd_attribute25,
	egd_attribute26,
	egd_attribute27,
	egd_attribute28,
	egd_attribute29,
	egd_attribute30,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_elig_dpnt
    where	elig_dpnt_id = p_elig_dpnt_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_elig_dpnt');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_elig_dpnt_id                  in number,
	p_create_dt                     in date,
	p_elig_strt_dt                  in date,
	p_elig_thru_dt                  in date,
	p_ovrdn_flag                    in varchar2,
	p_ovrdn_thru_dt                 in date,
	p_inelg_rsn_cd                  in varchar2,
	p_dpnt_inelig_flag              in varchar2,
	p_elig_per_elctbl_chc_id        in number,
	p_per_in_ler_id                 in number,
	p_elig_per_id                   in number,
	p_elig_per_opt_id               in number,
	p_elig_cvrd_dpnt_id             in number,
	p_dpnt_person_id                in number,
	p_business_group_id             in number,
	p_egd_attribute_category        in varchar2,
	p_egd_attribute1                in varchar2,
	p_egd_attribute2                in varchar2,
	p_egd_attribute3                in varchar2,
	p_egd_attribute4                in varchar2,
	p_egd_attribute5                in varchar2,
	p_egd_attribute6                in varchar2,
	p_egd_attribute7                in varchar2,
	p_egd_attribute8                in varchar2,
	p_egd_attribute9                in varchar2,
	p_egd_attribute10               in varchar2,
	p_egd_attribute11               in varchar2,
	p_egd_attribute12               in varchar2,
	p_egd_attribute13               in varchar2,
	p_egd_attribute14               in varchar2,
	p_egd_attribute15               in varchar2,
	p_egd_attribute16               in varchar2,
	p_egd_attribute17               in varchar2,
	p_egd_attribute18               in varchar2,
	p_egd_attribute19               in varchar2,
	p_egd_attribute20               in varchar2,
	p_egd_attribute21               in varchar2,
	p_egd_attribute22               in varchar2,
	p_egd_attribute23               in varchar2,
	p_egd_attribute24               in varchar2,
	p_egd_attribute25               in varchar2,
	p_egd_attribute26               in varchar2,
	p_egd_attribute27               in varchar2,
	p_egd_attribute28               in varchar2,
	p_egd_attribute29               in varchar2,
	p_egd_attribute30               in varchar2,
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
  l_rec.elig_dpnt_id                     := p_elig_dpnt_id;
  l_rec.create_dt                        := p_create_dt;
  l_rec.elig_strt_dt                     := p_elig_strt_dt;
  l_rec.elig_thru_dt                     := p_elig_thru_dt;
  l_rec.ovrdn_flag                       := p_ovrdn_flag;
  l_rec.ovrdn_thru_dt                    := p_ovrdn_thru_dt;
  l_rec.inelg_rsn_cd                     := p_inelg_rsn_cd;
  l_rec.dpnt_inelig_flag                 := p_dpnt_inelig_flag;
  l_rec.elig_per_elctbl_chc_id           := p_elig_per_elctbl_chc_id;
  l_rec.per_in_ler_id                    := p_per_in_ler_id;
  l_rec.elig_per_id                      := p_elig_per_id;
  l_rec.elig_per_opt_id                  := p_elig_per_opt_id;
  l_rec.elig_cvrd_dpnt_id                := p_elig_cvrd_dpnt_id;
  l_rec.dpnt_person_id                   := p_dpnt_person_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.egd_attribute_category           := p_egd_attribute_category;
  l_rec.egd_attribute1                   := p_egd_attribute1;
  l_rec.egd_attribute2                   := p_egd_attribute2;
  l_rec.egd_attribute3                   := p_egd_attribute3;
  l_rec.egd_attribute4                   := p_egd_attribute4;
  l_rec.egd_attribute5                   := p_egd_attribute5;
  l_rec.egd_attribute6                   := p_egd_attribute6;
  l_rec.egd_attribute7                   := p_egd_attribute7;
  l_rec.egd_attribute8                   := p_egd_attribute8;
  l_rec.egd_attribute9                   := p_egd_attribute9;
  l_rec.egd_attribute10                  := p_egd_attribute10;
  l_rec.egd_attribute11                  := p_egd_attribute11;
  l_rec.egd_attribute12                  := p_egd_attribute12;
  l_rec.egd_attribute13                  := p_egd_attribute13;
  l_rec.egd_attribute14                  := p_egd_attribute14;
  l_rec.egd_attribute15                  := p_egd_attribute15;
  l_rec.egd_attribute16                  := p_egd_attribute16;
  l_rec.egd_attribute17                  := p_egd_attribute17;
  l_rec.egd_attribute18                  := p_egd_attribute18;
  l_rec.egd_attribute19                  := p_egd_attribute19;
  l_rec.egd_attribute20                  := p_egd_attribute20;
  l_rec.egd_attribute21                  := p_egd_attribute21;
  l_rec.egd_attribute22                  := p_egd_attribute22;
  l_rec.egd_attribute23                  := p_egd_attribute23;
  l_rec.egd_attribute24                  := p_egd_attribute24;
  l_rec.egd_attribute25                  := p_egd_attribute25;
  l_rec.egd_attribute26                  := p_egd_attribute26;
  l_rec.egd_attribute27                  := p_egd_attribute27;
  l_rec.egd_attribute28                  := p_egd_attribute28;
  l_rec.egd_attribute29                  := p_egd_attribute29;
  l_rec.egd_attribute30                  := p_egd_attribute30;
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
end ben_egd_shd;

/
