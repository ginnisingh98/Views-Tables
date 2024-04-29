--------------------------------------------------------
--  DDL for Package Body GHR_CMP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CMP_SHD" as
/* $Header: ghcmprhi.pkb 120.0 2005/05/29 02:54:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_cmp_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'GHR_COMPLAINTS2_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_complaint_id                         in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       complaint_id
      ,complainant_person_id
      ,business_group_id
      ,docket_number
      ,stage
      ,class_flag
      ,mixed_flag
      ,consolidated_flag
      ,remand_flag
      ,active_flag
      ,information_inquiry
      ,pcom_init
      ,alleg_incident
      ,alleg_discrim_org_id
      ,rr_ltr_date
      ,rr_ltr_recvd
      ,pre_com_elec
      --,adr_offered
      ,class_agent_flag
      ,pre_com_desc
      ,counselor_asg
      ,init_counselor_interview
      ,anonymity_requested
      ,counsel_ext_ltr
      ,traditional_counsel_outcome
      ,final_interview
      ,notice_rtf_recvd
      ,precom_closed
      ,precom_closure_nature
      ,counselor_rpt_sub
      ,hr_office_org_id
      ,eeo_office_org_id
      ,serviced_org_id
      ,formal_com_filed
      ,ack_ltr
      ,clarification_ltr_date
      ,clarification_response_recvd
      ,forwarded_legal_review
      ,returned_from_legal
      ,letter_type
      ,letter_date
      ,letter_recvd
      ,investigation_source
      ,investigator_recvd_req
      ,agency_investigator_req
      ,investigator_asg
      ,investigation_start
      ,investigation_end
      ,investigation_extended
      ,invest_extension_desc
      ,agency_recvd_roi
      ,comrep_recvd_roi
      ,options_ltr_date
      ,comrep_recvd_opt_ltr
      ,comrep_opt_ltr_response
      ,resolution_offer
      ,comrep_resol_offer_recvd
      ,comrep_resol_offer_response
      ,comrep_resol_offer_desc
      ,resol_offer_signed
      ,resol_offer_desc
      ,hearing_source
      ,agency_notified_hearing
      ,eeoc_hearing_docket_num
      ,hearing_complete
      ,aj_merit_decision_date
      ,agency_recvd_aj_merit_dec
      ,aj_merit_decision
      ,aj_ca_decision_date
      ,agency_recvd_aj_ca_dec
      ,aj_ca_decision
      ,fad_requested
      ,merit_fad
      ,attorney_fees_fad
      ,comp_damages_fad
      ,non_compliance_fad
      ,fad_req_recvd_eeo_office
      ,fad_req_forwd_to_agency
      ,agency_recvd_request
      ,fad_due
      ,fad_date
      ,fad_decision
      --,fad_final_action_closure
      ,fad_forwd_to_comrep
      ,fad_recvd_by_comrep
      ,fad_imp_ltr_forwd_to_org
      ,fad_decision_forwd_legal
      ,fad_decision_recvd_legal
      ,fa_source
      ,final_action_due
      --,final_action_nature_of_closure
      ,final_act_forwd_comrep
      ,final_act_recvd_comrep
      ,final_action_decision_date
      ,final_action_decision
      ,fa_imp_ltr_forwd_to_org
      ,fa_decision_forwd_legal
      ,fa_decision_recvd_legal
      ,civil_action_filed
      ,agency_closure_confirmed
      ,consolidated_complaint_id
      ,consolidated
      ,stage_of_consolidation
      ,comrep_notif_consolidation
      ,consolidation_desc
      ,complaint_closed
      ,nature_of_closure
      ,complaint_closed_desc
      ,filed_formal_class
      ,forwd_eeoc
      ,aj_cert_decision_date
      ,aj_cert_decision_recvd
      ,aj_cert_decision
      ,class_members_notified
      ,number_of_complaintants
      ,class_hearing
      ,aj_dec
      ,agency_recvd_aj_dec
      ,aj_decision
      ,object_version_number
      ,agency_brief_eeoc
      ,agency_notif_of_civil_action
      ,fad_source
      ,agency_files_forwarded_eeoc
      ,hearing_req
      ,agency_code
      ,audited_by
      ,record_received
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
    from        ghr_complaints2
    where       complaint_id = p_complaint_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_complaint_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_complaint_id
        = ghr_cmp_shd.g_old_rec.complaint_id and
        p_object_version_number
        = ghr_cmp_shd.g_old_rec.object_version_number
       ) Then
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
      Fetch C_Sel1 Into ghr_cmp_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> ghr_cmp_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_complaint_id                         in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       complaint_id
      ,complainant_person_id
      ,business_group_id
      ,docket_number
      ,stage
      ,class_flag
      ,mixed_flag
      ,consolidated_flag
      ,remand_flag
      ,active_flag
      ,information_inquiry
      ,pcom_init
      ,alleg_incident
      ,alleg_discrim_org_id
      ,rr_ltr_date
      ,rr_ltr_recvd
      ,pre_com_elec
      --,adr_offered
      ,class_agent_flag
      ,pre_com_desc
      ,counselor_asg
      ,init_counselor_interview
      ,anonymity_requested
      ,counsel_ext_ltr
      ,traditional_counsel_outcome
      ,final_interview
      ,notice_rtf_recvd
      ,precom_closed
      ,precom_closure_nature
      ,counselor_rpt_sub
      ,hr_office_org_id
      ,eeo_office_org_id
      ,serviced_org_id
      ,formal_com_filed
      ,ack_ltr
      ,clarification_ltr_date
      ,clarification_response_recvd
      ,forwarded_legal_review
      ,returned_from_legal
      ,letter_type
      ,letter_date
      ,letter_recvd
      ,investigation_source
      ,investigator_recvd_req
      ,agency_investigator_req
      ,investigator_asg
      ,investigation_start
      ,investigation_end
      ,investigation_extended
      ,invest_extension_desc
      ,agency_recvd_roi
      ,comrep_recvd_roi
      ,options_ltr_date
      ,comrep_recvd_opt_ltr
      ,comrep_opt_ltr_response
      ,resolution_offer
      ,comrep_resol_offer_recvd
      ,comrep_resol_offer_response
      ,comrep_resol_offer_desc
      ,resol_offer_signed
      ,resol_offer_desc
      ,hearing_source
      ,agency_notified_hearing
      ,eeoc_hearing_docket_num
      ,hearing_complete
      ,aj_merit_decision_date
      ,agency_recvd_aj_merit_dec
      ,aj_merit_decision
      ,aj_ca_decision_date
      ,agency_recvd_aj_ca_dec
      ,aj_ca_decision
      ,fad_requested
      ,merit_fad
      ,attorney_fees_fad
      ,comp_damages_fad
      ,non_compliance_fad
      ,fad_req_recvd_eeo_office
      ,fad_req_forwd_to_agency
      ,agency_recvd_request
      ,fad_due
      ,fad_date
      ,fad_decision
      --,fad_final_action_closure
      ,fad_forwd_to_comrep
      ,fad_recvd_by_comrep
      ,fad_imp_ltr_forwd_to_org
      ,fad_decision_forwd_legal
      ,fad_decision_recvd_legal
      ,fa_source
      ,final_action_due
      --,final_action_nature_of_closure
      ,final_act_forwd_comrep
      ,final_act_recvd_comrep
      ,final_action_decision_date
      ,final_action_decision
      ,fa_imp_ltr_forwd_to_org
      ,fa_decision_forwd_legal
      ,fa_decision_recvd_legal
      ,civil_action_filed
      ,agency_closure_confirmed
      ,consolidated_complaint_id
      ,consolidated
      ,stage_of_consolidation
      ,comrep_notif_consolidation
      ,consolidation_desc
      ,complaint_closed
      ,nature_of_closure
      ,complaint_closed_desc
      ,filed_formal_class
      ,forwd_eeoc
      ,aj_cert_decision_date
      ,aj_cert_decision_recvd
      ,aj_cert_decision
      ,class_members_notified
      ,number_of_complaintants
      ,class_hearing
      ,aj_dec
      ,agency_recvd_aj_dec
      ,aj_decision
      ,object_version_number
      ,agency_brief_eeoc
      ,agency_notif_of_civil_action
      ,fad_source
      ,agency_files_forwarded_eeoc
      ,hearing_req
      ,agency_code
      ,audited_by
      ,record_received
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
    from        ghr_complaints2
    where       complaint_id = p_complaint_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'COMPLAINT_ID'
    ,p_argument_value     => p_complaint_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ghr_cmp_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> ghr_cmp_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ghr_complaints2');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_complaint_id                   in number
  ,p_complainant_person_id          in number
  ,p_business_group_id              in number
  ,p_docket_number                  in varchar2
  ,p_stage                          in varchar2
  ,p_class_flag                     in varchar2
  ,p_mixed_flag                     in varchar2
  ,p_consolidated_flag              in varchar2
  ,p_remand_flag                    in varchar2
  ,p_active_flag                    in varchar2
  ,p_information_inquiry            in date
  ,p_pcom_init                      in date
  ,p_alleg_incident                 in date
  ,p_alleg_discrim_org_id           in number
  ,p_rr_ltr_date                    in date
  ,p_rr_ltr_recvd                   in date
  ,p_pre_com_elec                   in varchar2
  --,p_adr_offered                    in varchar2
  ,p_class_agent_flag               in varchar2
  ,p_pre_com_desc                   in varchar2
  ,p_counselor_asg                  in date
  ,p_init_counselor_interview       in date
  ,p_anonymity_requested            in varchar2
  ,p_counsel_ext_ltr                in date
  ,p_traditional_counsel_outcome    in varchar2
  ,p_final_interview                in date
  ,p_notice_rtf_recvd               in date
  ,p_precom_closed                  in date
  ,p_precom_closure_nature          in varchar2
  ,p_counselor_rpt_sub              in date
  ,p_hr_office_org_id               in number
  ,p_eeo_office_org_id              in number
  ,p_serviced_org_id                in number
  ,p_formal_com_filed               in date
  ,p_ack_ltr                        in date
  ,p_clarification_ltr_date         in date
  ,p_clarification_response_recvd   in date
  ,p_forwarded_legal_review         in date
  ,p_returned_from_legal            in date
  ,p_letter_type                    in varchar2
  ,p_letter_date                    in date
  ,p_letter_recvd                   in date
  ,p_investigation_source           in varchar2
  ,p_investigator_recvd_req         in date
  ,p_agency_investigator_req        in date
  ,p_investigator_asg               in date
  ,p_investigation_start            in date
  ,p_investigation_end              in date
  ,p_investigation_extended         in date
  ,p_invest_extension_desc          in varchar2
  ,p_agency_recvd_roi               in date
  ,p_comrep_recvd_roi               in date
  ,p_options_ltr_date               in date
  ,p_comrep_recvd_opt_ltr           in date
  ,p_comrep_opt_ltr_response        in varchar2
  ,p_resolution_offer               in date
  ,p_comrep_resol_offer_recvd       in date
  ,p_comrep_resol_offer_response    in date
  ,p_comrep_resol_offer_desc        in varchar2
  ,p_resol_offer_signed             in date
  ,p_resol_offer_desc               in varchar2
  ,p_hearing_source                 in varchar2
  ,p_agency_notified_hearing        in date
  ,p_eeoc_hearing_docket_num        in varchar2
  ,p_hearing_complete               in date
  ,p_aj_merit_decision_date         in date
  ,p_agency_recvd_aj_merit_dec      in date
  ,p_aj_merit_decision              in varchar2
  ,p_aj_ca_decision_date            in date
  ,p_agency_recvd_aj_ca_dec         in date
  ,p_aj_ca_decision                 in varchar2
  ,p_fad_requested                  in date
  ,p_merit_fad                      in varchar2
  ,p_attorney_fees_fad              in varchar2
  ,p_comp_damages_fad               in varchar2
  ,p_non_compliance_fad             in varchar2
  ,p_fad_req_recvd_eeo_office       in date
  ,p_fad_req_forwd_to_agency        in date
  ,p_agency_recvd_request           in date
  ,p_fad_due                        in date
  ,p_fad_date                       in date
  ,p_fad_decision                   in varchar2
  --,p_fad_final_action_closure       in varchar2
  ,p_fad_forwd_to_comrep            in date
  ,p_fad_recvd_by_comrep            in date
  ,p_fad_imp_ltr_forwd_to_org       in date
  ,p_fad_decision_forwd_legal       in date
  ,p_fad_decision_recvd_legal       in date
  ,p_fa_source                      in varchar2
  ,p_final_action_due               in date
  --,p_final_action_nature_of_closu   in varchar2
  ,p_final_act_forwd_comrep         in date
  ,p_final_act_recvd_comrep         in date
  ,p_final_action_decision_date     in date
  ,p_final_action_decision          in varchar2
  ,p_fa_imp_ltr_forwd_to_org        in date
  ,p_fa_decision_forwd_legal        in date
  ,p_fa_decision_recvd_legal        in date
  ,p_civil_action_filed             in date
  ,p_agency_closure_confirmed       in date
  ,p_consolidated_complaint_id      in number
  ,p_consolidated                   in date
  ,p_stage_of_consolidation         in varchar2
  ,p_comrep_notif_consolidation     in date
  ,p_consolidation_desc             in varchar2
  ,p_complaint_closed               in date
  ,p_nature_of_closure              in varchar2
  ,p_complaint_closed_desc          in varchar2
  ,p_filed_formal_class             in date
  ,p_forwd_eeoc                     in date
  ,p_aj_cert_decision_date          in date
  ,p_aj_cert_decision_recvd         in date
  ,p_aj_cert_decision               in varchar2
  ,p_class_members_notified         in date
  ,p_number_of_complaintants        in number
  ,p_class_hearing                  in date
  ,p_aj_dec                         in date
  ,p_agency_recvd_aj_dec            in date
  ,p_aj_decision                    in varchar2
  ,p_object_version_number          in number
  ,p_agency_brief_eeoc              in date
  ,p_agency_notif_of_civil_action   in date
  ,p_fad_source                     in varchar2
  ,p_agency_files_forwarded_eeoc    in date
  ,p_hearing_req                    in date
  ,p_agency_code                    in varchar2
  ,p_audited_by                     in varchar2
  ,p_record_received                in date
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_attribute21                    in varchar2
  ,p_attribute22                    in varchar2
  ,p_attribute23                    in varchar2
  ,p_attribute24                    in varchar2
  ,p_attribute25                    in varchar2
  ,p_attribute26                    in varchar2
  ,p_attribute27                    in varchar2
  ,p_attribute28                    in varchar2
  ,p_attribute29                    in varchar2
  ,p_attribute30                    in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.complaint_id                     := p_complaint_id;
  l_rec.complainant_person_id            := p_complainant_person_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.docket_number                    := p_docket_number;
  l_rec.stage                            := p_stage;
  l_rec.class_flag                       := p_class_flag;
  l_rec.mixed_flag                       := p_mixed_flag;
  l_rec.consolidated_flag                := p_consolidated_flag;
  l_rec.remand_flag                      := p_remand_flag;
  l_rec.active_flag                      := p_active_flag;
  l_rec.information_inquiry              := p_information_inquiry;
  l_rec.pcom_init                        := p_pcom_init;
  l_rec.alleg_incident                   := p_alleg_incident;
  l_rec.alleg_discrim_org_id             := p_alleg_discrim_org_id;
  l_rec.rr_ltr_date                      := p_rr_ltr_date;
  l_rec.rr_ltr_recvd                     := p_rr_ltr_recvd;
  l_rec.pre_com_elec                     := p_pre_com_elec;
  --l_rec.adr_offered                      := p_adr_offered;
  l_rec.class_agent_flag                 := p_class_agent_flag;
  l_rec.pre_com_desc                     := p_pre_com_desc;
  l_rec.counselor_asg                    := p_counselor_asg;
  l_rec.init_counselor_interview         := p_init_counselor_interview;
  l_rec.anonymity_requested              := p_anonymity_requested;
  l_rec.counsel_ext_ltr                  := p_counsel_ext_ltr;
  l_rec.traditional_counsel_outcome      := p_traditional_counsel_outcome;
  l_rec.final_interview                  := p_final_interview;
  l_rec.notice_rtf_recvd                 := p_notice_rtf_recvd;
  l_rec.precom_closed                    := p_precom_closed;
  l_rec.precom_closure_nature            := p_precom_closure_nature;
  l_rec.counselor_rpt_sub                := p_counselor_rpt_sub;
  l_rec.hr_office_org_id                 := p_hr_office_org_id;
  l_rec.eeo_office_org_id                := p_eeo_office_org_id;
  l_rec.serviced_org_id                  := p_serviced_org_id;
  l_rec.formal_com_filed                 := p_formal_com_filed;
  l_rec.ack_ltr                          := p_ack_ltr;
  l_rec.clarification_ltr_date           := p_clarification_ltr_date;
  l_rec.clarification_response_recvd     := p_clarification_response_recvd;
  l_rec.forwarded_legal_review           := p_forwarded_legal_review;
  l_rec.returned_from_legal              := p_returned_from_legal;
  l_rec.letter_type                      := p_letter_type;
  l_rec.letter_date                      := p_letter_date;
  l_rec.letter_recvd                     := p_letter_recvd;
  l_rec.investigation_source             := p_investigation_source;
  l_rec.investigator_recvd_req           := p_investigator_recvd_req;
  l_rec.agency_investigator_req          := p_agency_investigator_req;
  l_rec.investigator_asg                 := p_investigator_asg;
  l_rec.investigation_start              := p_investigation_start;
  l_rec.investigation_end                := p_investigation_end;
  l_rec.investigation_extended           := p_investigation_extended;
  l_rec.invest_extension_desc            := p_invest_extension_desc;
  l_rec.agency_recvd_roi                 := p_agency_recvd_roi;
  l_rec.comrep_recvd_roi                 := p_comrep_recvd_roi;
  l_rec.options_ltr_date                 := p_options_ltr_date;
  l_rec.comrep_recvd_opt_ltr             := p_comrep_recvd_opt_ltr;
  l_rec.comrep_opt_ltr_response          := p_comrep_opt_ltr_response;
  l_rec.resolution_offer                 := p_resolution_offer;
  l_rec.comrep_resol_offer_recvd         := p_comrep_resol_offer_recvd;
  l_rec.comrep_resol_offer_response      := p_comrep_resol_offer_response;
  l_rec.comrep_resol_offer_desc          := p_comrep_resol_offer_desc;
  l_rec.resol_offer_signed               := p_resol_offer_signed;
  l_rec.resol_offer_desc                 := p_resol_offer_desc;
  l_rec.hearing_source                   := p_hearing_source;
  l_rec.agency_notified_hearing          := p_agency_notified_hearing;
  l_rec.eeoc_hearing_docket_num          := p_eeoc_hearing_docket_num;
  l_rec.hearing_complete                 := p_hearing_complete;
  l_rec.aj_merit_decision_date           := p_aj_merit_decision_date;
  l_rec.agency_recvd_aj_merit_dec        := p_agency_recvd_aj_merit_dec;
  l_rec.aj_merit_decision                := p_aj_merit_decision;
  l_rec.aj_ca_decision_date              := p_aj_ca_decision_date;
  l_rec.agency_recvd_aj_ca_dec           := p_agency_recvd_aj_ca_dec;
  l_rec.aj_ca_decision                   := p_aj_ca_decision;
  l_rec.fad_requested                    := p_fad_requested;
  l_rec.merit_fad                        := p_merit_fad;
  l_rec.attorney_fees_fad                := p_attorney_fees_fad;
  l_rec.comp_damages_fad                 := p_comp_damages_fad;
  l_rec.non_compliance_fad               := p_non_compliance_fad;
  l_rec.fad_req_recvd_eeo_office         := p_fad_req_recvd_eeo_office;
  l_rec.fad_req_forwd_to_agency          := p_fad_req_forwd_to_agency;
  l_rec.agency_recvd_request             := p_agency_recvd_request;
  l_rec.fad_due                          := p_fad_due;
  l_rec.fad_date                         := p_fad_date;
  l_rec.fad_decision                     := p_fad_decision;
  --l_rec.fad_final_action_closure         := p_fad_final_action_closure;
  l_rec.fad_forwd_to_comrep              := p_fad_forwd_to_comrep;
  l_rec.fad_recvd_by_comrep              := p_fad_recvd_by_comrep;
  l_rec.fad_imp_ltr_forwd_to_org         := p_fad_imp_ltr_forwd_to_org;
  l_rec.fad_decision_forwd_legal         := p_fad_decision_forwd_legal;
  l_rec.fad_decision_recvd_legal         := p_fad_decision_recvd_legal;
  l_rec.fa_source                        := p_fa_source;
  l_rec.final_action_due                 := p_final_action_due;
  --l_rec.final_action_nature_of_closure   := p_final_action_nature_of_closu;
  l_rec.final_act_forwd_comrep           := p_final_act_forwd_comrep;
  l_rec.final_act_recvd_comrep           := p_final_act_recvd_comrep;
  l_rec.final_action_decision_date       := p_final_action_decision_date;
  l_rec.final_action_decision            := p_final_action_decision;
  l_rec.fa_imp_ltr_forwd_to_org          := p_fa_imp_ltr_forwd_to_org;
  l_rec.fa_decision_forwd_legal          := p_fa_decision_forwd_legal;
  l_rec.fa_decision_recvd_legal          := p_fa_decision_recvd_legal;
  l_rec.civil_action_filed               := p_civil_action_filed;
  l_rec.agency_closure_confirmed         := p_agency_closure_confirmed;
  l_rec.consolidated_complaint_id        := p_consolidated_complaint_id;
  l_rec.consolidated                     := p_consolidated;
  l_rec.stage_of_consolidation           := p_stage_of_consolidation;
  l_rec.comrep_notif_consolidation       := p_comrep_notif_consolidation;
  l_rec.consolidation_desc               := p_consolidation_desc;
  l_rec.complaint_closed                 := p_complaint_closed;
  l_rec.nature_of_closure                := p_nature_of_closure;
  l_rec.complaint_closed_desc            := p_complaint_closed_desc;
  l_rec.filed_formal_class               := p_filed_formal_class;
  l_rec.forwd_eeoc                       := p_forwd_eeoc;
  l_rec.aj_cert_decision_date            := p_aj_cert_decision_date;
  l_rec.aj_cert_decision_recvd           := p_aj_cert_decision_recvd;
  l_rec.aj_cert_decision                 := p_aj_cert_decision;
  l_rec.class_members_notified           := p_class_members_notified;
  l_rec.number_of_complaintants          := p_number_of_complaintants;
  l_rec.class_hearing                    := p_class_hearing;
  l_rec.aj_dec                           := p_aj_dec;
  l_rec.agency_recvd_aj_dec              := p_agency_recvd_aj_dec;
  l_rec.aj_decision                      := p_aj_decision;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.agency_brief_eeoc                := p_agency_brief_eeoc;
  l_rec.agency_notif_of_civil_action     := p_agency_notif_of_civil_action;
  l_rec.fad_source                       := p_fad_source;
  l_rec.agency_files_forwarded_eeoc      := p_agency_files_forwarded_eeoc;
  l_rec.hearing_req                      := p_hearing_req;
  l_rec.agency_code                      := p_agency_code;
  l_rec.audited_by                       := p_audited_by;
  l_rec.record_received                  := p_record_received;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.attribute21                      := p_attribute21;
  l_rec.attribute22                      := p_attribute22;
  l_rec.attribute23                      := p_attribute23;
  l_rec.attribute24                      := p_attribute24;
  l_rec.attribute25                      := p_attribute25;
  l_rec.attribute26                      := p_attribute26;
  l_rec.attribute27                      := p_attribute27;
  l_rec.attribute28                      := p_attribute28;
  l_rec.attribute29                      := p_attribute29;
  l_rec.attribute30                      := p_attribute30;

  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ghr_cmp_shd;

/
