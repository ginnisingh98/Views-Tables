--------------------------------------------------------
--  DDL for Package Body BEN_BFT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BFT_SHD" as
/* $Header: bebftrhi.pkb 115.23 2003/08/18 05:05:29 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bft_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_BENEFIT_ACTIONS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_BENEFIT_ACTIONS_DT9') then
    ben_utility.child_exists_error(p_table_name => 'BEN_BENEFIT_ACTIONS');
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
  p_benefit_action_id                  in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	benefit_action_id,
	process_date,
	uneai_effective_date,
	mode_cd,
	derivable_factors_flag,
	close_uneai_flag,
	validate_flag,
	person_id,
	person_type_id,
	pgm_id,
	business_group_id,
	pl_id,
	popl_enrt_typ_cycl_id,
	no_programs_flag,
	no_plans_flag,
	comp_selection_rl,
	person_selection_rl,
	ler_id,
	organization_id,
	benfts_grp_id,
	location_id,
	pstl_zip_rng_id,
	rptg_grp_id,
	pl_typ_id,
	opt_id,
	eligy_prfl_id,
	vrbl_rt_prfl_id,
	legal_entity_id,
	payroll_id,
	debug_messages_flag,
  cm_trgr_typ_cd,
  cm_typ_id,
  age_fctr_id,
  min_age,
  max_age,
  los_fctr_id,
  min_los,
  max_los,
  cmbn_age_los_fctr_id,
  min_cmbn,
  max_cmbn,
  date_from,
  elig_enrol_cd,
  actn_typ_id,
  use_fctr_to_sel_flag,
  los_det_to_use_cd,
  audit_log_flag,
  lmt_prpnip_by_org_flag,
  lf_evt_ocrd_dt,
  ptnl_ler_for_per_stat_cd,
	bft_attribute_category,
	bft_attribute1,
	bft_attribute3,
	bft_attribute4,
	bft_attribute5,
	bft_attribute6,
	bft_attribute7,
	bft_attribute8,
	bft_attribute9,
	bft_attribute10,
	bft_attribute11,
	bft_attribute12,
	bft_attribute13,
	bft_attribute14,
	bft_attribute15,
	bft_attribute16,
	bft_attribute17,
	bft_attribute18,
	bft_attribute19,
	bft_attribute20,
	bft_attribute21,
	bft_attribute22,
	bft_attribute23,
	bft_attribute24,
	bft_attribute25,
	bft_attribute26,
	bft_attribute27,
	bft_attribute28,
	bft_attribute29,
	bft_attribute30,
  request_id,
  program_application_id,
  program_id,
  program_update_date,
	object_version_number,
	enrt_perd_id,
	inelg_action_cd,
	org_hierarchy_id,
	org_starting_node_id,
	grade_ladder_id,
	asg_events_to_all_sel_dt,
	rate_id,
	per_sel_dt_cd,
	per_sel_freq_cd,
	per_sel_dt_from,
	per_sel_dt_to,
	year_from,
	year_to,
	cagr_id,
	qual_type,
	qual_status,
	concat_segs,
  grant_price_val
  from	ben_benefit_actions
    where	benefit_action_id = p_benefit_action_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_benefit_action_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_benefit_action_id = g_old_rec.benefit_action_id and
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
  p_benefit_action_id                  in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	benefit_action_id,
	process_date,
	uneai_effective_date,
	mode_cd,
	derivable_factors_flag,
	close_uneai_flag,
	validate_flag,
	person_id,
	person_type_id,
	pgm_id,
	business_group_id,
	pl_id,
	popl_enrt_typ_cycl_id,
	no_programs_flag,
	no_plans_flag,
	comp_selection_rl,
	person_selection_rl,
	ler_id,
	organization_id,
	benfts_grp_id,
	location_id,
	pstl_zip_rng_id,
	rptg_grp_id,
	pl_typ_id,
	opt_id,
	eligy_prfl_id,
	vrbl_rt_prfl_id,
	legal_entity_id,
	payroll_id,
	debug_messages_flag,
  cm_trgr_typ_cd,
  cm_typ_id,
  age_fctr_id,
  min_age,
  max_age,
  los_fctr_id,
  min_los,
  max_los,
  cmbn_age_los_fctr_id,
  min_cmbn,
  max_cmbn,
  date_from,
  elig_enrol_cd,
  actn_typ_id,
  use_fctr_to_sel_flag,
  los_det_to_use_cd,
  audit_log_flag,
  lmt_prpnip_by_org_flag,
  lf_evt_ocrd_dt,
  ptnl_ler_for_per_stat_cd,
	bft_attribute_category,
	bft_attribute1,
	bft_attribute3,
	bft_attribute4,
	bft_attribute5,
	bft_attribute6,
	bft_attribute7,
	bft_attribute8,
	bft_attribute9,
	bft_attribute10,
	bft_attribute11,
	bft_attribute12,
	bft_attribute13,
	bft_attribute14,
	bft_attribute15,
	bft_attribute16,
	bft_attribute17,
	bft_attribute18,
	bft_attribute19,
	bft_attribute20,
	bft_attribute21,
	bft_attribute22,
	bft_attribute23,
	bft_attribute24,
	bft_attribute25,
	bft_attribute26,
	bft_attribute27,
	bft_attribute28,
	bft_attribute29,
	bft_attribute30,
  request_id,
  program_application_id,
  program_id,
  program_update_date,
	object_version_number,
	enrt_perd_id,
	inelg_action_cd,
	org_hierarchy_id,
	org_starting_node_id,
	grade_ladder_id,
	asg_events_to_all_sel_dt,
	rate_id,
	per_sel_dt_cd,
	per_sel_freq_cd,
	per_sel_dt_from,
	per_sel_dt_to,
	year_from,
	year_to,
	cagr_id,
	qual_type,
	qual_status,
	concat_segs,
  grant_price_val
    from	ben_benefit_actions
    where	benefit_action_id = p_benefit_action_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_benefit_actions');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_benefit_action_id             in number,
	p_process_date                  in date,
	p_uneai_effective_date          in date,
	p_mode_cd                       in varchar2,
	p_derivable_factors_flag        in varchar2,
	p_close_uneai_flag              in varchar2,
	p_validate_flag                 in varchar2,
	p_person_id                     in number,
	p_person_type_id                in number,
	p_pgm_id                        in number,
	p_business_group_id             in number,
	p_pl_id                         in number,
	p_popl_enrt_typ_cycl_id         in number,
	p_no_programs_flag              in varchar2,
	p_no_plans_flag                 in varchar2,
	p_comp_selection_rl             in number,
	p_person_selection_rl           in number,
	p_ler_id                        in number,
	p_organization_id               in number,
	p_benfts_grp_id                 in number,
	p_location_id                   in number,
	p_pstl_zip_rng_id               in number,
	p_rptg_grp_id                   in number,
	p_pl_typ_id                     in number,
	p_opt_id                        in number,
	p_eligy_prfl_id                 in number,
	p_vrbl_rt_prfl_id               in number,
	p_legal_entity_id               in number,
	p_payroll_id                    in number,
	p_debug_messages_flag           in varchar2,
  p_cm_trgr_typ_cd                in varchar2,
  p_cm_typ_id                     in number,
  p_age_fctr_id                   in number,
  p_min_age                       in number,
  p_max_age                       in number,
  p_los_fctr_id                   in number,
  p_min_los                       in number,
  p_max_los                       in number,
  p_cmbn_age_los_fctr_id          in number,
  p_min_cmbn                      in number,
  p_max_cmbn                      in number,
  p_date_from                     in date,
  p_elig_enrol_cd                 in varchar2,
  p_actn_typ_id                   in number,
  p_use_fctr_to_sel_flag          in varchar2,
  p_los_det_to_use_cd             in varchar2,
  p_audit_log_flag                in varchar2,
  p_lmt_prpnip_by_org_flag        in varchar2,
  p_lf_evt_ocrd_dt                in date,
  p_ptnl_ler_for_per_stat_cd      in varchar2,
	p_bft_attribute_category        in varchar2,
	p_bft_attribute1                in varchar2,
	p_bft_attribute3                in varchar2,
	p_bft_attribute4                in varchar2,
	p_bft_attribute5                in varchar2,
	p_bft_attribute6                in varchar2,
	p_bft_attribute7                in varchar2,
	p_bft_attribute8                in varchar2,
	p_bft_attribute9                in varchar2,
	p_bft_attribute10               in varchar2,
	p_bft_attribute11               in varchar2,
	p_bft_attribute12               in varchar2,
	p_bft_attribute13               in varchar2,
	p_bft_attribute14               in varchar2,
	p_bft_attribute15               in varchar2,
	p_bft_attribute16               in varchar2,
	p_bft_attribute17               in varchar2,
	p_bft_attribute18               in varchar2,
	p_bft_attribute19               in varchar2,
	p_bft_attribute20               in varchar2,
	p_bft_attribute21               in varchar2,
	p_bft_attribute22               in varchar2,
	p_bft_attribute23               in varchar2,
	p_bft_attribute24               in varchar2,
	p_bft_attribute25               in varchar2,
	p_bft_attribute26               in varchar2,
	p_bft_attribute27               in varchar2,
	p_bft_attribute28               in varchar2,
	p_bft_attribute29               in varchar2,
	p_bft_attribute30               in varchar2,
  p_request_id                    in number,
  p_program_application_id        in number,
  p_program_id                    in number,
  p_program_update_date           in date,
	p_object_version_number         in number,
	p_enrt_perd_id                  in number,
	p_inelg_action_cd               in varchar2,
	p_org_hierarchy_id               in number ,
	p_org_starting_node_id               in number,
	p_grade_ladder_id               in number,
	p_asg_events_to_all_sel_dt               in varchar2,
	p_rate_id               in number,
	p_per_sel_dt_cd               in varchar2,
	p_per_sel_freq_cd               in varchar2,
	p_per_sel_dt_from               in date,
	p_per_sel_dt_to               in date,
	p_year_from               in number,
	p_year_to               in number,
	p_cagr_id               in number,
	p_qual_type               in number,
	p_qual_status               in varchar2,
	p_concat_segs               in varchar2,
  p_grant_price_val               in number
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
  l_rec.benefit_action_id                := p_benefit_action_id;
  l_rec.process_date                     := p_process_date;
  l_rec.uneai_effective_date             := p_uneai_effective_date;
  l_rec.mode_cd                          := p_mode_cd;
  l_rec.derivable_factors_flag           := p_derivable_factors_flag;
  l_rec.close_uneai_flag                 := p_close_uneai_flag;
  l_rec.validate_flag                    := p_validate_flag;
  l_rec.person_id                        := p_person_id;
  l_rec.person_type_id                   := p_person_type_id;
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.popl_enrt_typ_cycl_id            := p_popl_enrt_typ_cycl_id;
  l_rec.no_programs_flag                 := p_no_programs_flag;
  l_rec.no_plans_flag                    := p_no_plans_flag;
  l_rec.comp_selection_rl                := p_comp_selection_rl;
  l_rec.person_selection_rl              := p_person_selection_rl;
  l_rec.ler_id                           := p_ler_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.benfts_grp_id                    := p_benfts_grp_id;
  l_rec.location_id                      := p_location_id;
  l_rec.pstl_zip_rng_id                  := p_pstl_zip_rng_id;
  l_rec.rptg_grp_id                      := p_rptg_grp_id;
  l_rec.pl_typ_id                        := p_pl_typ_id;
  l_rec.opt_id                           := p_opt_id;
  l_rec.eligy_prfl_id                    := p_eligy_prfl_id;
  l_rec.vrbl_rt_prfl_id                  := p_vrbl_rt_prfl_id;
  l_rec.legal_entity_id                  := p_legal_entity_id;
  l_rec.payroll_id                       := p_payroll_id;
  l_rec.debug_messages_flag              := p_debug_messages_flag;
  l_rec.cm_trgr_typ_cd                   := p_cm_trgr_typ_cd;
  l_rec.cm_typ_id                        := p_cm_typ_id;
  l_rec.age_fctr_id                      := p_age_fctr_id;
  l_rec.min_age                          := p_min_age;
  l_rec.max_age                          := p_max_age;
  l_rec.los_fctr_id                      := p_los_fctr_id;
  l_rec.min_los                          := p_min_los;
  l_rec.max_los                          := p_max_los;
  l_rec.cmbn_age_los_fctr_id             := p_cmbn_age_los_fctr_id;
  l_rec.min_cmbn                         := p_min_cmbn;
  l_rec.max_cmbn                         := p_max_cmbn;
  l_rec.date_from                        := p_date_from;
  l_rec.elig_enrol_cd                    := p_elig_enrol_cd;
  l_rec.actn_typ_id                      := p_actn_typ_id;
  l_rec.use_fctr_to_sel_flag             := p_use_fctr_to_sel_flag;
  l_rec.los_det_to_use_cd                := p_los_det_to_use_cd;
  l_rec.audit_log_flag                   := p_audit_log_flag;
  l_rec.lmt_prpnip_by_org_flag           := p_lmt_prpnip_by_org_flag;
  l_rec.lf_evt_ocrd_dt                   := p_lf_evt_ocrd_dt;
  l_rec.ptnl_ler_for_per_stat_cd         := p_ptnl_ler_for_per_stat_cd;
  l_rec.bft_attribute_category           := p_bft_attribute_category;
  l_rec.bft_attribute1                   := p_bft_attribute1;
  l_rec.bft_attribute3                   := p_bft_attribute3;
  l_rec.bft_attribute4                   := p_bft_attribute4;
  l_rec.bft_attribute5                   := p_bft_attribute5;
  l_rec.bft_attribute6                   := p_bft_attribute6;
  l_rec.bft_attribute7                   := p_bft_attribute7;
  l_rec.bft_attribute8                   := p_bft_attribute8;
  l_rec.bft_attribute9                   := p_bft_attribute9;
  l_rec.bft_attribute10                  := p_bft_attribute10;
  l_rec.bft_attribute11                  := p_bft_attribute11;
  l_rec.bft_attribute12                  := p_bft_attribute12;
  l_rec.bft_attribute13                  := p_bft_attribute13;
  l_rec.bft_attribute14                  := p_bft_attribute14;
  l_rec.bft_attribute15                  := p_bft_attribute15;
  l_rec.bft_attribute16                  := p_bft_attribute16;
  l_rec.bft_attribute17                  := p_bft_attribute17;
  l_rec.bft_attribute18                  := p_bft_attribute18;
  l_rec.bft_attribute19                  := p_bft_attribute19;
  l_rec.bft_attribute20                  := p_bft_attribute20;
  l_rec.bft_attribute21                  := p_bft_attribute21;
  l_rec.bft_attribute22                  := p_bft_attribute22;
  l_rec.bft_attribute23                  := p_bft_attribute23;
  l_rec.bft_attribute24                  := p_bft_attribute24;
  l_rec.bft_attribute25                  := p_bft_attribute25;
  l_rec.bft_attribute26                  := p_bft_attribute26;
  l_rec.bft_attribute27                  := p_bft_attribute27;
  l_rec.bft_attribute28                  := p_bft_attribute28;
  l_rec.bft_attribute29                  := p_bft_attribute29;
  l_rec.bft_attribute30                  := p_bft_attribute30;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.enrt_perd_id                     := p_enrt_perd_id;
  l_rec.inelg_action_cd                  := p_inelg_action_cd;
  l_rec.org_hierarchy_id                  := p_org_hierarchy_id;
  l_rec.org_starting_node_id                  := p_org_starting_node_id;
  l_rec.grade_ladder_id                  := p_grade_ladder_id;
  l_rec.asg_events_to_all_sel_dt                  := p_asg_events_to_all_sel_dt;
  l_rec.rate_id                  := p_rate_id;
  l_rec.per_sel_dt_cd                  := p_per_sel_dt_cd;
  l_rec.per_sel_freq_cd                  := p_per_sel_freq_cd;
  l_rec.per_sel_dt_from                  := p_per_sel_dt_from;
  l_rec.per_sel_dt_to                  := p_per_sel_dt_to;
  l_rec.year_from                  := p_year_from;
  l_rec.year_to                  := p_year_to;
  l_rec.cagr_id                  := p_cagr_id;
  l_rec.qual_type                  := p_qual_type;
  l_rec.qual_status                  := p_qual_status;
  l_rec.concat_segs                  := p_concat_segs;
  l_rec.grant_price_val                  := p_grant_price_val;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_bft_shd;

/
