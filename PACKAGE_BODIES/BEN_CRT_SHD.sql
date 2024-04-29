--------------------------------------------------------
--  DDL for Package Body BEN_CRT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CRT_SHD" as
/* $Header: becrtrhi.pkb 115.11 2004/06/22 07:52:16 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_crt_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_CRT_ORDR_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_CRT_ORDR_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_CRT_ORDR_CVRD_PER_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_CRT_ORDR_CVRD_PER');
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
  p_crt_ordr_id                        in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		crt_ordr_id,
	crt_ordr_typ_cd,
	apls_perd_endg_dt,
	apls_perd_strtg_dt,
	crt_ident,
	description,
	detd_qlfd_ordr_dt,
	issue_dt,
	qdro_amt,
	qdro_dstr_mthd_cd,
	qdro_pct,
	rcvd_dt,
	uom,
	crt_issng,
	pl_id,
	person_id,
	business_group_id,
	crt_attribute_category,
	crt_attribute1,
	crt_attribute2,
	crt_attribute3,
	crt_attribute4,
	crt_attribute5,
	crt_attribute6,
	crt_attribute7,
	crt_attribute8,
	crt_attribute9,
	crt_attribute10,
	crt_attribute11,
	crt_attribute12,
	crt_attribute13,
	crt_attribute14,
	crt_attribute15,
	crt_attribute16,
	crt_attribute17,
	crt_attribute18,
	crt_attribute19,
	crt_attribute20,
	crt_attribute21,
	crt_attribute22,
	crt_attribute23,
	crt_attribute24,
	crt_attribute25,
	crt_attribute26,
	crt_attribute27,
	crt_attribute28,
	crt_attribute29,
	crt_attribute30,
	object_version_number,
	qdro_num_pymt_val,
	qdro_per_perd_cd,
	pl_typ_id
    from	ben_crt_ordr
    where	crt_ordr_id = p_crt_ordr_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_crt_ordr_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_crt_ordr_id = g_old_rec.crt_ordr_id and
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
        fnd_message.set_name('BEN', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('BEN', 'HR_7155_OBJECT_INVALID');
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
  p_crt_ordr_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	crt_ordr_id,
	crt_ordr_typ_cd,
	apls_perd_endg_dt,
	apls_perd_strtg_dt,
	crt_ident,
	description,
	detd_qlfd_ordr_dt,
	issue_dt,
	qdro_amt,
	qdro_dstr_mthd_cd,
	qdro_pct,
	rcvd_dt,
	uom,
	crt_issng,
	pl_id,
	person_id,
	business_group_id,
	crt_attribute_category,
	crt_attribute1,
	crt_attribute2,
	crt_attribute3,
	crt_attribute4,
	crt_attribute5,
	crt_attribute6,
	crt_attribute7,
	crt_attribute8,
	crt_attribute9,
	crt_attribute10,
	crt_attribute11,
	crt_attribute12,
	crt_attribute13,
	crt_attribute14,
	crt_attribute15,
	crt_attribute16,
	crt_attribute17,
	crt_attribute18,
	crt_attribute19,
	crt_attribute20,
	crt_attribute21,
	crt_attribute22,
	crt_attribute23,
	crt_attribute24,
	crt_attribute25,
	crt_attribute26,
	crt_attribute27,
	crt_attribute28,
	crt_attribute29,
	crt_attribute30,
	object_version_number,
	qdro_num_pymt_val,
	qdro_per_perd_cd,
	pl_typ_id
    from	ben_crt_ordr
    where	crt_ordr_id = p_crt_ordr_id
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
    fnd_message.set_name('BEN', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('BEN', 'HR_7155_OBJECT_INVALID');
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
    fnd_message.set_name('BEN', 'HR_7165_OBJECT_LOCKED');
   fnd_message.set_token('TABLE_NAME', 'ben_crt_ordr');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_crt_ordr_id                   in number,
	p_crt_ordr_typ_cd               in varchar2,
	p_apls_perd_endg_dt             in date,
	p_apls_perd_strtg_dt            in date,
	p_crt_ident                     in varchar2,
	p_description                   in varchar2,
	p_detd_qlfd_ordr_dt             in date,
	p_issue_dt                      in date,
	p_qdro_amt                      in number,
	p_qdro_dstr_mthd_cd             in varchar2,
	p_qdro_pct                      in number,
	p_rcvd_dt                       in date,
	p_uom                           in varchar2,
	p_crt_issng                     in varchar2,
	p_pl_id                         in number,
	p_person_id                     in number,
	p_business_group_id             in number,
	p_crt_attribute_category        in varchar2,
	p_crt_attribute1                in varchar2,
	p_crt_attribute2                in varchar2,
	p_crt_attribute3                in varchar2,
	p_crt_attribute4                in varchar2,
	p_crt_attribute5                in varchar2,
	p_crt_attribute6                in varchar2,
	p_crt_attribute7                in varchar2,
	p_crt_attribute8                in varchar2,
	p_crt_attribute9                in varchar2,
	p_crt_attribute10               in varchar2,
	p_crt_attribute11               in varchar2,
	p_crt_attribute12               in varchar2,
	p_crt_attribute13               in varchar2,
	p_crt_attribute14               in varchar2,
	p_crt_attribute15               in varchar2,
	p_crt_attribute16               in varchar2,
	p_crt_attribute17               in varchar2,
	p_crt_attribute18               in varchar2,
	p_crt_attribute19               in varchar2,
	p_crt_attribute20               in varchar2,
	p_crt_attribute21               in varchar2,
	p_crt_attribute22               in varchar2,
	p_crt_attribute23               in varchar2,
	p_crt_attribute24               in varchar2,
	p_crt_attribute25               in varchar2,
	p_crt_attribute26               in varchar2,
	p_crt_attribute27               in varchar2,
	p_crt_attribute28               in varchar2,
	p_crt_attribute29               in varchar2,
	p_crt_attribute30               in varchar2,
	p_object_version_number         in number,
	p_qdro_num_pymt_val             in number,
	p_qdro_per_perd_cd              in varchar2,
	p_pl_typ_id                     in number
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
  l_rec.crt_ordr_id                      := p_crt_ordr_id;
  l_rec.crt_ordr_typ_cd                  := p_crt_ordr_typ_cd;
  l_rec.apls_perd_endg_dt                := p_apls_perd_endg_dt;
  l_rec.apls_perd_strtg_dt               := p_apls_perd_strtg_dt;
  l_rec.crt_ident                        := p_crt_ident;
  l_rec.description                      := p_description;
  l_rec.detd_qlfd_ordr_dt                := p_detd_qlfd_ordr_dt;
  l_rec.issue_dt                         := p_issue_dt;
  l_rec.qdro_amt                         := p_qdro_amt;
  l_rec.qdro_dstr_mthd_cd                := p_qdro_dstr_mthd_cd;
  l_rec.qdro_pct                         := p_qdro_pct;
  l_rec.rcvd_dt                          := p_rcvd_dt;
  l_rec.uom                              := p_uom;
  l_rec.crt_issng                        := p_crt_issng;
  l_rec.pl_id                            := p_pl_id;
  l_rec.person_id                        := p_person_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.crt_attribute_category           := p_crt_attribute_category;
  l_rec.crt_attribute1                   := p_crt_attribute1;
  l_rec.crt_attribute2                   := p_crt_attribute2;
  l_rec.crt_attribute3                   := p_crt_attribute3;
  l_rec.crt_attribute4                   := p_crt_attribute4;
  l_rec.crt_attribute5                   := p_crt_attribute5;
  l_rec.crt_attribute6                   := p_crt_attribute6;
  l_rec.crt_attribute7                   := p_crt_attribute7;
  l_rec.crt_attribute8                   := p_crt_attribute8;
  l_rec.crt_attribute9                   := p_crt_attribute9;
  l_rec.crt_attribute10                  := p_crt_attribute10;
  l_rec.crt_attribute11                  := p_crt_attribute11;
  l_rec.crt_attribute12                  := p_crt_attribute12;
  l_rec.crt_attribute13                  := p_crt_attribute13;
  l_rec.crt_attribute14                  := p_crt_attribute14;
  l_rec.crt_attribute15                  := p_crt_attribute15;
  l_rec.crt_attribute16                  := p_crt_attribute16;
  l_rec.crt_attribute17                  := p_crt_attribute17;
  l_rec.crt_attribute18                  := p_crt_attribute18;
  l_rec.crt_attribute19                  := p_crt_attribute19;
  l_rec.crt_attribute20                  := p_crt_attribute20;
  l_rec.crt_attribute21                  := p_crt_attribute21;
  l_rec.crt_attribute22                  := p_crt_attribute22;
  l_rec.crt_attribute23                  := p_crt_attribute23;
  l_rec.crt_attribute24                  := p_crt_attribute24;
  l_rec.crt_attribute25                  := p_crt_attribute25;
  l_rec.crt_attribute26                  := p_crt_attribute26;
  l_rec.crt_attribute27                  := p_crt_attribute27;
  l_rec.crt_attribute28                  := p_crt_attribute28;
  l_rec.crt_attribute29                  := p_crt_attribute29;
  l_rec.crt_attribute30                  := p_crt_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.qdro_num_pymt_val                := p_qdro_num_pymt_val;
  l_rec.qdro_per_perd_cd                 := p_qdro_per_perd_cd;
  l_rec.pl_typ_id                        := p_pl_typ_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_crt_shd;

/
