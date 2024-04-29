--------------------------------------------------------
--  DDL for Package Body BEN_RVC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RVC_SHD" as
/* $Header: bervcrhi.pkb 115.2 2002/12/11 11:18:06 hnarayan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_rvc_shd.';  -- Global package name
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
  ElsIf (p_constraint_name = 'BEN_prv_ctfn_prvdd_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_prv_ctfn_prvdd_FK3') Then
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
  p_prtt_rt_val_ctfn_prvdd_id                 in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	prtt_rt_val_ctfn_prvdd_id,
	enrt_ctfn_typ_cd,
        enrt_ctfn_rqd_flag ,
        enrt_ctfn_recd_dt ,
        enrt_ctfn_dnd_dt ,
	prtt_rt_val_id,
	business_group_id,
	rvc_attribute_category,
	rvc_attribute1,
	rvc_attribute2,
	rvc_attribute3,
	rvc_attribute4,
	rvc_attribute5,
	rvc_attribute6,
	rvc_attribute7,
	rvc_attribute8,
	rvc_attribute9,
	rvc_attribute10,
	rvc_attribute11,
	rvc_attribute12,
	rvc_attribute13,
	rvc_attribute14,
	rvc_attribute15,
	rvc_attribute16,
	rvc_attribute17,
	rvc_attribute18,
	rvc_attribute19,
	rvc_attribute20,
	rvc_attribute21,
	rvc_attribute22,
	rvc_attribute23,
	rvc_attribute24,
	rvc_attribute25,
	rvc_attribute26,
	rvc_attribute27,
	rvc_attribute28,
	rvc_attribute29,
	rvc_attribute30,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_prtt_rt_val_ctfn_prvdd
    where	prtt_rt_val_ctfn_prvdd_id = p_prtt_rt_val_ctfn_prvdd_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_prtt_rt_val_ctfn_prvdd_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_prtt_rt_val_ctfn_prvdd_id = g_old_rec.prtt_rt_val_ctfn_prvdd_id and
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
  p_prtt_rt_val_ctfn_prvdd_id                 in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	prtt_rt_val_ctfn_prvdd_id,
	enrt_ctfn_typ_cd,
        enrt_ctfn_rqd_flag ,
        enrt_ctfn_recd_dt ,
        enrt_ctfn_dnd_dt ,
	prtt_rt_val_id,
	business_group_id,
	rvc_attribute_category,
	rvc_attribute1,
	rvc_attribute2,
	rvc_attribute3,
	rvc_attribute4,
	rvc_attribute5,
	rvc_attribute6,
	rvc_attribute7,
	rvc_attribute8,
	rvc_attribute9,
	rvc_attribute10,
	rvc_attribute11,
	rvc_attribute12,
	rvc_attribute13,
	rvc_attribute14,
	rvc_attribute15,
	rvc_attribute16,
	rvc_attribute17,
	rvc_attribute18,
	rvc_attribute19,
	rvc_attribute20,
	rvc_attribute21,
	rvc_attribute22,
	rvc_attribute23,
	rvc_attribute24,
	rvc_attribute25,
	rvc_attribute26,
	rvc_attribute27,
	rvc_attribute28,
	rvc_attribute29,
	rvc_attribute30,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_prtt_rt_val_ctfn_prvdd
    where	prtt_rt_val_ctfn_prvdd_id = p_prtt_rt_val_ctfn_prvdd_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_prtt_rt_val_ctfn_prvdd');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_prtt_rt_val_ctfn_prvdd_id            in number,
	p_enrt_ctfn_typ_cd              in varchar2,
        p_enrt_ctfn_rqd_flag            in  varchar2,
        p_enrt_ctfn_recd_dt             in  date,
        p_enrt_ctfn_dnd_dt              in  date,
	p_prtt_rt_val_id        in number,
	p_business_group_id             in number,
	p_rvc_attribute_category        in varchar2,
	p_rvc_attribute1                in varchar2,
	p_rvc_attribute2                in varchar2,
	p_rvc_attribute3                in varchar2,
	p_rvc_attribute4                in varchar2,
	p_rvc_attribute5                in varchar2,
	p_rvc_attribute6                in varchar2,
	p_rvc_attribute7                in varchar2,
	p_rvc_attribute8                in varchar2,
	p_rvc_attribute9                in varchar2,
	p_rvc_attribute10               in varchar2,
	p_rvc_attribute11               in varchar2,
	p_rvc_attribute12               in varchar2,
	p_rvc_attribute13               in varchar2,
	p_rvc_attribute14               in varchar2,
	p_rvc_attribute15               in varchar2,
	p_rvc_attribute16               in varchar2,
	p_rvc_attribute17               in varchar2,
	p_rvc_attribute18               in varchar2,
	p_rvc_attribute19               in varchar2,
	p_rvc_attribute20               in varchar2,
	p_rvc_attribute21               in varchar2,
	p_rvc_attribute22               in varchar2,
	p_rvc_attribute23               in varchar2,
	p_rvc_attribute24               in varchar2,
	p_rvc_attribute25               in varchar2,
	p_rvc_attribute26               in varchar2,
	p_rvc_attribute27               in varchar2,
	p_rvc_attribute28               in varchar2,
	p_rvc_attribute29               in varchar2,
	p_rvc_attribute30               in varchar2,
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
  l_rec.prtt_rt_val_ctfn_prvdd_id        := p_prtt_rt_val_ctfn_prvdd_id;
  l_rec.enrt_ctfn_typ_cd                 := p_enrt_ctfn_typ_cd;
  l_rec.enrt_ctfn_rqd_flag               := p_enrt_ctfn_rqd_flag;
  l_rec.enrt_ctfn_recd_dt                := p_enrt_ctfn_recd_dt;
  l_rec.enrt_ctfn_dnd_dt                 := p_enrt_ctfn_dnd_dt;
  l_rec.prtt_rt_val_id                   := p_prtt_rt_val_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.rvc_attribute_category           := p_rvc_attribute_category;
  l_rec.rvc_attribute1                   := p_rvc_attribute1;
  l_rec.rvc_attribute2                   := p_rvc_attribute2;
  l_rec.rvc_attribute3                   := p_rvc_attribute3;
  l_rec.rvc_attribute4                   := p_rvc_attribute4;
  l_rec.rvc_attribute5                   := p_rvc_attribute5;
  l_rec.rvc_attribute6                   := p_rvc_attribute6;
  l_rec.rvc_attribute7                   := p_rvc_attribute7;
  l_rec.rvc_attribute8                   := p_rvc_attribute8;
  l_rec.rvc_attribute9                   := p_rvc_attribute9;
  l_rec.rvc_attribute10                  := p_rvc_attribute10;
  l_rec.rvc_attribute11                  := p_rvc_attribute11;
  l_rec.rvc_attribute12                  := p_rvc_attribute12;
  l_rec.rvc_attribute13                  := p_rvc_attribute13;
  l_rec.rvc_attribute14                  := p_rvc_attribute14;
  l_rec.rvc_attribute15                  := p_rvc_attribute15;
  l_rec.rvc_attribute16                  := p_rvc_attribute16;
  l_rec.rvc_attribute17                  := p_rvc_attribute17;
  l_rec.rvc_attribute18                  := p_rvc_attribute18;
  l_rec.rvc_attribute19                  := p_rvc_attribute19;
  l_rec.rvc_attribute20                  := p_rvc_attribute20;
  l_rec.rvc_attribute21                  := p_rvc_attribute21;
  l_rec.rvc_attribute22                  := p_rvc_attribute22;
  l_rec.rvc_attribute23                  := p_rvc_attribute23;
  l_rec.rvc_attribute24                  := p_rvc_attribute24;
  l_rec.rvc_attribute25                  := p_rvc_attribute25;
  l_rec.rvc_attribute26                  := p_rvc_attribute26;
  l_rec.rvc_attribute27                  := p_rvc_attribute27;
  l_rec.rvc_attribute28                  := p_rvc_attribute28;
  l_rec.rvc_attribute29                  := p_rvc_attribute29;
  l_rec.rvc_attribute30                  := p_rvc_attribute30;
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
end ben_rvc_shd;

/
