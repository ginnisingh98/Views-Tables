--------------------------------------------------------
--  DDL for Package Body BEN_PIL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PIL_SHD" as
/* $Header: bepilrhi.pkb 120.3 2006/09/26 10:56:35 bmanyam noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pil_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_PER_IN_LER_PK') Then
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
  p_per_in_ler_id                      in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		per_in_ler_id,
	per_in_ler_stat_cd,
	prvs_stat_cd,
	lf_evt_ocrd_dt,
        trgr_table_pk_id, --ABSE changes
	procd_dt,
	strtd_dt,
	voidd_dt,
	bckt_dt,
	clsd_dt,
	ntfn_dt,
	ptnl_ler_for_per_id,
	bckt_per_in_ler_id,
	ler_id,
	person_id,
	business_group_id,
        ASSIGNMENT_ID,
        WS_MGR_ID,
        GROUP_PL_ID,
        MGR_OVRID_PERSON_ID,
        MGR_OVRID_DT,
	pil_attribute_category,
	pil_attribute1,
	pil_attribute2,
	pil_attribute3,
	pil_attribute4,
	pil_attribute5,
	pil_attribute6,
	pil_attribute7,
	pil_attribute8,
	pil_attribute9,
	pil_attribute10,
	pil_attribute11,
	pil_attribute12,
	pil_attribute13,
	pil_attribute14,
	pil_attribute15,
	pil_attribute16,
	pil_attribute17,
	pil_attribute18,
	pil_attribute19,
	pil_attribute20,
	pil_attribute21,
	pil_attribute22,
	pil_attribute23,
	pil_attribute24,
	pil_attribute25,
	pil_attribute26,
	pil_attribute27,
	pil_attribute28,
	pil_attribute29,
	pil_attribute30,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_per_in_ler
    where	per_in_ler_id = p_per_in_ler_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_per_in_ler_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_per_in_ler_id = g_old_rec.per_in_ler_id and
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
  p_per_in_ler_id                      in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	per_in_ler_id,
	per_in_ler_stat_cd,
	prvs_stat_cd      ,
	lf_evt_ocrd_dt,
        trgr_table_pk_id, --ABSE change
	procd_dt,
	strtd_dt,
	voidd_dt,
	bckt_dt,
	clsd_dt,
	ntfn_dt,
	ptnl_ler_for_per_id,
	bckt_per_in_ler_id,
	ler_id,
	person_id,
	business_group_id,
        ASSIGNMENT_ID,
        WS_MGR_ID,
        GROUP_PL_ID,
        MGR_OVRID_PERSON_ID,
        MGR_OVRID_DT,
	pil_attribute_category,
	pil_attribute1,
	pil_attribute2,
	pil_attribute3,
	pil_attribute4,
	pil_attribute5,
	pil_attribute6,
	pil_attribute7,
	pil_attribute8,
	pil_attribute9,
	pil_attribute10,
	pil_attribute11,
	pil_attribute12,
	pil_attribute13,
	pil_attribute14,
	pil_attribute15,
	pil_attribute16,
	pil_attribute17,
	pil_attribute18,
	pil_attribute19,
	pil_attribute20,
	pil_attribute21,
	pil_attribute22,
	pil_attribute23,
	pil_attribute24,
	pil_attribute25,
	pil_attribute26,
	pil_attribute27,
	pil_attribute28,
	pil_attribute29,
	pil_attribute30,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_per_in_ler
    where	per_in_ler_id = p_per_in_ler_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_per_in_ler');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_per_in_ler_id                 in number,
	p_per_in_ler_stat_cd            in varchar2,
	p_prvs_stat_cd                  in varchar2,
	p_lf_evt_ocrd_dt                in date,
        p_trgr_table_pk_id              in number, --ABSE change
	p_procd_dt                      in date,
	p_strtd_dt                      in date,
	p_voidd_dt                      in date,
	p_bckt_dt                       in date,
	p_clsd_dt                       in date,
	p_ntfn_dt                       in date,
	p_ptnl_ler_for_per_id           in number,
	p_bckt_per_in_ler_id            in number,
	p_ler_id                        in number,
	p_person_id                     in number,
	p_business_group_id             in number,
        p_ASSIGNMENT_ID                 in  number,
        p_WS_MGR_ID                     in  number,
        p_GROUP_PL_ID                   in  number,
        p_MGR_OVRID_PERSON_ID           in  number,
        p_MGR_OVRID_DT                  in  date,
	p_pil_attribute_category        in varchar2,
	p_pil_attribute1                in varchar2,
	p_pil_attribute2                in varchar2,
	p_pil_attribute3                in varchar2,
	p_pil_attribute4                in varchar2,
	p_pil_attribute5                in varchar2,
	p_pil_attribute6                in varchar2,
	p_pil_attribute7                in varchar2,
	p_pil_attribute8                in varchar2,
	p_pil_attribute9                in varchar2,
	p_pil_attribute10               in varchar2,
	p_pil_attribute11               in varchar2,
	p_pil_attribute12               in varchar2,
	p_pil_attribute13               in varchar2,
	p_pil_attribute14               in varchar2,
	p_pil_attribute15               in varchar2,
	p_pil_attribute16               in varchar2,
	p_pil_attribute17               in varchar2,
	p_pil_attribute18               in varchar2,
	p_pil_attribute19               in varchar2,
	p_pil_attribute20               in varchar2,
	p_pil_attribute21               in varchar2,
	p_pil_attribute22               in varchar2,
	p_pil_attribute23               in varchar2,
	p_pil_attribute24               in varchar2,
	p_pil_attribute25               in varchar2,
	p_pil_attribute26               in varchar2,
	p_pil_attribute27               in varchar2,
	p_pil_attribute28               in varchar2,
	p_pil_attribute29               in varchar2,
	p_pil_attribute30               in varchar2,
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
  l_rec.per_in_ler_id                    := p_per_in_ler_id;
  l_rec.per_in_ler_stat_cd               := p_per_in_ler_stat_cd;
  l_rec.prvs_stat_cd                     := p_prvs_stat_cd;
  l_rec.lf_evt_ocrd_dt                   := p_lf_evt_ocrd_dt;
  l_rec.trgr_table_pk_id                 := p_trgr_table_pk_id;
  l_rec.procd_dt                         := p_procd_dt;
  l_rec.strtd_dt                         := p_strtd_dt;
  l_rec.voidd_dt                         := p_voidd_dt;
  l_rec.bckt_dt                          := p_bckt_dt;
  l_rec.clsd_dt                          := p_clsd_dt;
  l_rec.ntfn_dt                          := p_ntfn_dt;
  l_rec.ptnl_ler_for_per_id              := p_ptnl_ler_for_per_id;
  l_rec.bckt_per_in_ler_id               := p_bckt_per_in_ler_id;
  l_rec.ler_id                           := p_ler_id;
  l_rec.person_id                        := p_person_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.ASSIGNMENT_ID                  := p_ASSIGNMENT_ID;
  l_rec.WS_MGR_ID                      := p_WS_MGR_ID;
  l_rec.GROUP_PL_ID                    := p_GROUP_PL_ID;
  l_rec.MGR_OVRID_PERSON_ID            := p_MGR_OVRID_PERSON_ID;
  l_rec.MGR_OVRID_DT                   := p_MGR_OVRID_DT;
  l_rec.pil_attribute_category           := p_pil_attribute_category;
  l_rec.pil_attribute1                   := p_pil_attribute1;
  l_rec.pil_attribute2                   := p_pil_attribute2;
  l_rec.pil_attribute3                   := p_pil_attribute3;
  l_rec.pil_attribute4                   := p_pil_attribute4;
  l_rec.pil_attribute5                   := p_pil_attribute5;
  l_rec.pil_attribute6                   := p_pil_attribute6;
  l_rec.pil_attribute7                   := p_pil_attribute7;
  l_rec.pil_attribute8                   := p_pil_attribute8;
  l_rec.pil_attribute9                   := p_pil_attribute9;
  l_rec.pil_attribute10                  := p_pil_attribute10;
  l_rec.pil_attribute11                  := p_pil_attribute11;
  l_rec.pil_attribute12                  := p_pil_attribute12;
  l_rec.pil_attribute13                  := p_pil_attribute13;
  l_rec.pil_attribute14                  := p_pil_attribute14;
  l_rec.pil_attribute15                  := p_pil_attribute15;
  l_rec.pil_attribute16                  := p_pil_attribute16;
  l_rec.pil_attribute17                  := p_pil_attribute17;
  l_rec.pil_attribute18                  := p_pil_attribute18;
  l_rec.pil_attribute19                  := p_pil_attribute19;
  l_rec.pil_attribute20                  := p_pil_attribute20;
  l_rec.pil_attribute21                  := p_pil_attribute21;
  l_rec.pil_attribute22                  := p_pil_attribute22;
  l_rec.pil_attribute23                  := p_pil_attribute23;
  l_rec.pil_attribute24                  := p_pil_attribute24;
  l_rec.pil_attribute25                  := p_pil_attribute25;
  l_rec.pil_attribute26                  := p_pil_attribute26;
  l_rec.pil_attribute27                  := p_pil_attribute27;
  l_rec.pil_attribute28                  := p_pil_attribute28;
  l_rec.pil_attribute29                  := p_pil_attribute29;
  l_rec.pil_attribute30                  := p_pil_attribute30;
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
end ben_pil_shd;

/
