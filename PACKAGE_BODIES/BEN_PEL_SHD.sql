--------------------------------------------------------
--  DDL for Package Body BEN_PEL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEL_SHD" as
/* $Header: bepelrhi.pkb 120.3.12000000.2 2007/05/13 23:02:25 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pel_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_PIL_ELCTBL_CHC_POPL_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PIL_ELCTBL_CHC_POPL_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PIL_ELCTBL_CHC_POPL_PK') Then
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
  p_pil_elctbl_chc_popl_id             in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
    pil_elctbl_chc_popl_id,
    dflt_enrt_dt,
    dflt_asnd_dt,
    elcns_made_dt,
    cls_enrt_dt_to_use_cd,
    enrt_typ_cycl_cd,
    enrt_perd_end_dt,
    enrt_perd_strt_dt,
    procg_end_dt,
    pil_elctbl_popl_stat_cd,
    acty_ref_perd_cd,
    uom,
    comments,
    mgr_ovrid_dt,
    ws_mgr_id,
    mgr_ovrid_person_id,
    assignment_id,
        --cwb
        bdgt_acc_cd,
        pop_cd,
        bdgt_due_dt,
        bdgt_export_flag,
        bdgt_iss_dt,
        bdgt_stat_cd,
        ws_acc_cd,
        ws_due_dt,
        ws_export_flag,
        ws_iss_dt,
        ws_stat_cd,
        --cwb
        reinstate_cd,
        reinstate_ovrdn_cd,
    auto_asnd_dt,
        cbr_elig_perd_strt_dt,
        cbr_elig_perd_end_dt,
    lee_rsn_id,
    enrt_perd_id,
    per_in_ler_id,
    pgm_id,
    pl_id,
    business_group_id,
    pel_attribute_category,
    pel_attribute1,
    pel_attribute2,
    pel_attribute3,
    pel_attribute4,
    pel_attribute5,
    pel_attribute6,
    pel_attribute7,
    pel_attribute8,
    pel_attribute9,
    pel_attribute10,
    pel_attribute11,
    pel_attribute12,
    pel_attribute13,
    pel_attribute14,
    pel_attribute15,
    pel_attribute16,
    pel_attribute17,
    pel_attribute18,
    pel_attribute19,
    pel_attribute20,
    pel_attribute21,
    pel_attribute22,
    pel_attribute23,
    pel_attribute24,
    pel_attribute25,
    pel_attribute26,
    pel_attribute27,
    pel_attribute28,
    pel_attribute29,
    pel_attribute30,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    object_version_number,
    defer_deenrol_flag,
    deenrol_made_dt
    from    ben_pil_elctbl_chc_popl
    where   pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id;
--
  l_proc    varchar2(72)    := g_package||'api_updating';
  l_fct_ret boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
    p_pil_elctbl_chc_popl_id is null and
    p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
    p_pil_elctbl_chc_popl_id = g_old_rec.pil_elctbl_chc_popl_id and
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
  p_pil_elctbl_chc_popl_id             in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select  pil_elctbl_chc_popl_id,
    dflt_enrt_dt,
    dflt_asnd_dt,
    elcns_made_dt,
    cls_enrt_dt_to_use_cd,
    enrt_typ_cycl_cd,
    enrt_perd_end_dt,
    enrt_perd_strt_dt,
    procg_end_dt,
    pil_elctbl_popl_stat_cd,
    acty_ref_perd_cd,
    uom,
    comments,
    mgr_ovrid_dt,
    ws_mgr_id,
    mgr_ovrid_person_id,
    assignment_id,
        --cwb
        bdgt_acc_cd,
        pop_cd,
        bdgt_due_dt,
        bdgt_export_flag,
        bdgt_iss_dt,
        bdgt_stat_cd,
        ws_acc_cd,
        ws_due_dt,
        ws_export_flag,
        ws_iss_dt,
        ws_stat_cd,
        --cwb
        reinstate_cd,
        reinstate_ovrdn_cd,
    auto_asnd_dt,
        cbr_elig_perd_strt_dt,
        cbr_elig_perd_end_dt,
    lee_rsn_id,
    enrt_perd_id,
    per_in_ler_id,
    pgm_id,
    pl_id,
    business_group_id,
    pel_attribute_category,
    pel_attribute1,
    pel_attribute2,
    pel_attribute3,
    pel_attribute4,
    pel_attribute5,
    pel_attribute6,
    pel_attribute7,
    pel_attribute8,
    pel_attribute9,
    pel_attribute10,
    pel_attribute11,
    pel_attribute12,
    pel_attribute13,
    pel_attribute14,
    pel_attribute15,
    pel_attribute16,
    pel_attribute17,
    pel_attribute18,
    pel_attribute19,
    pel_attribute20,
    pel_attribute21,
    pel_attribute22,
    pel_attribute23,
    pel_attribute24,
    pel_attribute25,
    pel_attribute26,
    pel_attribute27,
    pel_attribute28,
    pel_attribute29,
    pel_attribute30,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    object_version_number,
    defer_deenrol_flag,
    deenrol_made_dt
    from    ben_pil_elctbl_chc_popl
    where   pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_pil_elctbl_chc_popl');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
    (
    p_pil_elctbl_chc_popl_id        in number,
    p_dflt_enrt_dt                  in date,
    p_dflt_asnd_dt                  in date,
    p_elcns_made_dt                 in date,
    p_cls_enrt_dt_to_use_cd         in varchar2,
    p_enrt_typ_cycl_cd              in varchar2,
    p_enrt_perd_end_dt              in date,
    p_enrt_perd_strt_dt             in date,
    p_procg_end_dt                  in date,
    p_pil_elctbl_popl_stat_cd       in varchar2,
    p_acty_ref_perd_cd              in varchar2,
    p_uom                           in varchar2,
    p_comments                           in varchar2,
    p_mgr_ovrid_dt                           in date,
    p_ws_mgr_id                           in number,
    p_mgr_ovrid_person_id                           in number,
    p_assignment_id                           in number,
        --cwb
        p_bdgt_acc_cd                   in varchar2,
        p_pop_cd                        in varchar2,
        p_bdgt_due_dt                   in date,
        p_bdgt_export_flag              in varchar2,
        p_bdgt_iss_dt                   in date,
        p_bdgt_stat_cd                  in varchar2,
        p_ws_acc_cd                     in varchar2,
        p_ws_due_dt                     in date,
        p_ws_export_flag                in varchar2,
        p_ws_iss_dt                     in date,
        p_ws_stat_cd                    in varchar2,
        --cwb
        p_reinstate_cd                  in varchar2,
        p_reinstate_ovrdn_cd            in varchar2,
    p_auto_asnd_dt                  in date,
        p_cbr_elig_perd_strt_dt         in date,
        p_cbr_elig_perd_end_dt          in date,
    p_lee_rsn_id                    in number,
    p_enrt_perd_id                  in number,
    p_per_in_ler_id                 in number,
    p_pgm_id                        in number,
    p_pl_id                         in number,
    p_business_group_id             in number,
    p_pel_attribute_category        in varchar2,
    p_pel_attribute1                in varchar2,
    p_pel_attribute2                in varchar2,
    p_pel_attribute3                in varchar2,
    p_pel_attribute4                in varchar2,
    p_pel_attribute5                in varchar2,
    p_pel_attribute6                in varchar2,
    p_pel_attribute7                in varchar2,
    p_pel_attribute8                in varchar2,
    p_pel_attribute9                in varchar2,
    p_pel_attribute10               in varchar2,
    p_pel_attribute11               in varchar2,
    p_pel_attribute12               in varchar2,
    p_pel_attribute13               in varchar2,
    p_pel_attribute14               in varchar2,
    p_pel_attribute15               in varchar2,
    p_pel_attribute16               in varchar2,
    p_pel_attribute17               in varchar2,
    p_pel_attribute18               in varchar2,
    p_pel_attribute19               in varchar2,
    p_pel_attribute20               in varchar2,
    p_pel_attribute21               in varchar2,
    p_pel_attribute22               in varchar2,
    p_pel_attribute23               in varchar2,
    p_pel_attribute24               in varchar2,
    p_pel_attribute25               in varchar2,
    p_pel_attribute26               in varchar2,
    p_pel_attribute27               in varchar2,
    p_pel_attribute28               in varchar2,
    p_pel_attribute29               in varchar2,
    p_pel_attribute30               in varchar2,
    p_request_id                    in number,
    p_program_application_id        in number,
    p_program_id                    in number,
    p_program_update_date           in date,
    p_object_version_number         in number,
    p_defer_deenrol_flag            in varchar2,
    p_deenrol_made_dt               in date
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
  l_rec.pil_elctbl_chc_popl_id           := p_pil_elctbl_chc_popl_id;
  l_rec.dflt_enrt_dt                     := p_dflt_enrt_dt;
  l_rec.dflt_asnd_dt                     := p_dflt_asnd_dt;
  l_rec.elcns_made_dt                    := p_elcns_made_dt;
  l_rec.cls_enrt_dt_to_use_cd            := p_cls_enrt_dt_to_use_cd;
  l_rec.enrt_typ_cycl_cd                 := p_enrt_typ_cycl_cd;
  l_rec.enrt_perd_end_dt                 := p_enrt_perd_end_dt;
  l_rec.enrt_perd_strt_dt                := p_enrt_perd_strt_dt;
  l_rec.procg_end_dt                     := p_procg_end_dt;
  l_rec.pil_elctbl_popl_stat_cd          := p_pil_elctbl_popl_stat_cd;
  l_rec.acty_ref_perd_cd                 := p_acty_ref_perd_cd;
  l_rec.uom                              := p_uom;
  l_rec.comments                              := p_comments;
  l_rec.mgr_ovrid_dt                              := p_mgr_ovrid_dt;
  l_rec.ws_mgr_id                              := p_ws_mgr_id;
  l_rec.mgr_ovrid_person_id                              := p_mgr_ovrid_person_id;
  l_rec.assignment_id                              := p_assignment_id;
  --cwb
  l_rec.bdgt_acc_cd                      := p_bdgt_acc_cd;
  l_rec.pop_cd                           := p_pop_cd;
  l_rec.bdgt_due_dt                      := p_bdgt_due_dt;
  l_rec.bdgt_export_flag                 := p_bdgt_export_flag;
  l_rec.bdgt_iss_dt                      := p_bdgt_iss_dt;
  l_rec.bdgt_stat_cd                     := p_bdgt_stat_cd;
  l_rec.ws_acc_cd                        := p_ws_acc_cd;
  l_rec.ws_due_dt                        := p_ws_due_dt;
  l_rec.ws_export_flag                   := p_ws_export_flag;
  l_rec.ws_iss_dt                        := p_ws_iss_dt;
  l_rec.ws_stat_cd                       := p_ws_stat_cd;
  --cwb
  l_rec.reinstate_cd                     := p_reinstate_cd;
  l_rec.reinstate_ovrdn_cd               := p_reinstate_ovrdn_cd;
  l_rec.auto_asnd_dt                     := p_auto_asnd_dt;
  l_rec.cbr_elig_perd_strt_dt            := p_cbr_elig_perd_strt_dt;
  l_rec.cbr_elig_perd_end_dt             := p_cbr_elig_perd_end_dt;
  l_rec.lee_rsn_id                       := p_lee_rsn_id;
  l_rec.enrt_perd_id                     := p_enrt_perd_id;
  l_rec.per_in_ler_id                    := p_per_in_ler_id;
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.pel_attribute_category           := p_pel_attribute_category;
  l_rec.pel_attribute1                   := p_pel_attribute1;
  l_rec.pel_attribute2                   := p_pel_attribute2;
  l_rec.pel_attribute3                   := p_pel_attribute3;
  l_rec.pel_attribute4                   := p_pel_attribute4;
  l_rec.pel_attribute5                   := p_pel_attribute5;
  l_rec.pel_attribute6                   := p_pel_attribute6;
  l_rec.pel_attribute7                   := p_pel_attribute7;
  l_rec.pel_attribute8                   := p_pel_attribute8;
  l_rec.pel_attribute9                   := p_pel_attribute9;
  l_rec.pel_attribute10                  := p_pel_attribute10;
  l_rec.pel_attribute11                  := p_pel_attribute11;
  l_rec.pel_attribute12                  := p_pel_attribute12;
  l_rec.pel_attribute13                  := p_pel_attribute13;
  l_rec.pel_attribute14                  := p_pel_attribute14;
  l_rec.pel_attribute15                  := p_pel_attribute15;
  l_rec.pel_attribute16                  := p_pel_attribute16;
  l_rec.pel_attribute17                  := p_pel_attribute17;
  l_rec.pel_attribute18                  := p_pel_attribute18;
  l_rec.pel_attribute19                  := p_pel_attribute19;
  l_rec.pel_attribute20                  := p_pel_attribute20;
  l_rec.pel_attribute21                  := p_pel_attribute21;
  l_rec.pel_attribute22                  := p_pel_attribute22;
  l_rec.pel_attribute23                  := p_pel_attribute23;
  l_rec.pel_attribute24                  := p_pel_attribute24;
  l_rec.pel_attribute25                  := p_pel_attribute25;
  l_rec.pel_attribute26                  := p_pel_attribute26;
  l_rec.pel_attribute27                  := p_pel_attribute27;
  l_rec.pel_attribute28                  := p_pel_attribute28;
  l_rec.pel_attribute29                  := p_pel_attribute29;
  l_rec.pel_attribute30                  := p_pel_attribute30;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.defer_deenrol_flag               := p_defer_deenrol_flag;
  l_rec.deenrol_made_dt                  := p_deenrol_made_dt;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_pel_shd;

/
