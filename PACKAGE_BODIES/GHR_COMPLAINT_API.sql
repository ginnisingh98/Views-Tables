--------------------------------------------------------
--  DDL for Package Body GHR_COMPLAINT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPLAINT_API" as
/* $Header: ghcmpapi.pkb 120.0 2005/05/29 02:53:39 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_complaint_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_complaint >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_complaint
  (p_validate                       in     boolean
  ,p_effective_date                 in     date
  ,p_complainant_person_id          in     number
  ,p_business_group_id              in     number
  ,p_docket_number                  in     varchar2
  ,p_stage                          in     varchar2
  ,p_class_flag                     in     varchar2
  ,p_mixed_flag                     in     varchar2
  ,p_consolidated_flag              in     varchar2
  ,p_remand_flag                    in     varchar2
  ,p_active_flag                    in     varchar2
  ,p_information_inquiry            in     date
  ,p_pcom_init                      in     date
  ,p_alleg_incident                 in     date
  ,p_alleg_discrim_org_id           in     number
  ,p_rr_ltr_date                    in     date
  ,p_rr_ltr_recvd                   in     date
  ,p_pre_com_elec                   in     varchar2
  --,p_adr_offered                    in     varchar2
  ,p_class_agent_flag               in     varchar2
  ,p_pre_com_desc                   in     varchar2
  ,p_counselor_asg                  in     date
  ,p_init_counselor_interview       in     date
  ,p_anonymity_requested            in     varchar2
  ,p_counsel_ext_ltr                in     date
  ,p_traditional_counsel_outcome    in     varchar2
  ,p_final_interview                in     date
  ,p_notice_rtf_recvd               in     date
  ,p_precom_closed                  in     date
  ,p_precom_closure_nature          in     varchar2
  ,p_counselor_rpt_sub              in     date
  ,p_hr_office_org_id               in     number
  ,p_eeo_office_org_id              in     number
  ,p_serviced_org_id                in     number
  ,p_formal_com_filed               in     date
  ,p_ack_ltr                        in     date
  ,p_clarification_ltr_date         in     date
  ,p_clarification_response_recvd   in     date
  ,p_forwarded_legal_review         in     date
  ,p_returned_from_legal            in     date
  ,p_letter_type                    in     varchar2
  ,p_letter_date                    in     date
  ,p_letter_recvd                   in     date
  ,p_investigation_source           in     varchar2
  ,p_investigator_recvd_req         in     date
  ,p_agency_investigator_req        in     date
  ,p_investigator_asg               in     date
  ,p_investigation_start            in     date
  ,p_investigation_end              in     date
  ,p_investigation_extended         in     date
  ,p_invest_extension_desc          in     varchar2
  ,p_agency_recvd_roi               in     date
  ,p_comrep_recvd_roi               in     date
  ,p_options_ltr_date               in     date
  ,p_comrep_recvd_opt_ltr           in     date
  ,p_comrep_opt_ltr_response        in     varchar2
  ,p_resolution_offer               in     date
  ,p_comrep_resol_offer_recvd       in     date
  ,p_comrep_resol_offer_response    in     date
  ,p_comrep_resol_offer_desc        in     varchar2
  ,p_resol_offer_signed             in     date
  ,p_resol_offer_desc               in     varchar2
  ,p_hearing_source                 in     varchar2
  ,p_agency_notified_hearing        in     date
  ,p_eeoc_hearing_docket_num        in     varchar2
  ,p_hearing_complete               in     date
  ,p_aj_merit_decision_date         in     date
  ,p_agency_recvd_aj_merit_dec      in     date
  ,p_aj_merit_decision              in     varchar2
  ,p_aj_ca_decision_date            in     date
  ,p_agency_recvd_aj_ca_dec         in     date
  ,p_aj_ca_decision                 in     varchar2
  ,p_fad_requested                  in     date
  ,p_merit_fad                      in     varchar2
  ,p_attorney_fees_fad              in     varchar2
  ,p_comp_damages_fad               in     varchar2
  ,p_non_compliance_fad             in     varchar2
  ,p_fad_req_recvd_eeo_office       in     date
  ,p_fad_req_forwd_to_agency        in     date
  ,p_agency_recvd_request           in     date
  ,p_fad_due                        in     date
  ,p_fad_date                       in     date
  ,p_fad_decision                   in     varchar2
  --,p_fad_final_action_closure       in     varchar2
  ,p_fad_forwd_to_comrep            in     date
  ,p_fad_recvd_by_comrep            in     date
  ,p_fad_imp_ltr_forwd_to_org       in     date
  ,p_fad_decision_forwd_legal       in     date
  ,p_fad_decision_recvd_legal       in     date
  ,p_fa_source                      in     varchar2
  ,p_final_action_due               in     date
  --,p_final_action_nature_of_closu   in     varchar2
  ,p_final_act_forwd_comrep         in     date
  ,p_final_act_recvd_comrep         in     date
  ,p_final_action_decision_date     in     date
  ,p_final_action_decision          in     varchar2
  ,p_fa_imp_ltr_forwd_to_org        in     date
  ,p_fa_decision_forwd_legal        in     date
  ,p_fa_decision_recvd_legal        in     date
  ,p_civil_action_filed             in     date
  ,p_agency_closure_confirmed       in     date
  ,p_consolidated_complaint_id      in     number
  ,p_consolidated                   in     date
  ,p_stage_of_consolidation         in     varchar2
  ,p_comrep_notif_consolidation     in     date
  ,p_consolidation_desc             in     varchar2
  ,p_complaint_closed               in     date
  ,p_nature_of_closure              in     varchar2
  ,p_complaint_closed_desc          in     varchar2
  ,p_filed_formal_class             in     date
  ,p_forwd_eeoc                     in     date
  ,p_aj_cert_decision_date          in     date
  ,p_aj_cert_decision_recvd         in     date
  ,p_aj_cert_decision               in     varchar2
  ,p_class_members_notified         in     date
  ,p_number_of_complaintants        in     number
  ,p_class_hearing                  in     date
  ,p_aj_dec                         in     date
  ,p_agency_recvd_aj_dec            in     date
  ,p_aj_decision                    in     varchar2
  ,p_agency_brief_eeoc              in     date
  ,p_agency_notif_of_civil_action   in     date
  ,p_fad_source                     in     varchar2
  ,p_agency_files_forwarded_eeoc    in     date
  ,p_hearing_req                    in     date
  ,p_agency_code                    in     varchar2
  ,p_audited_by                     in     varchar2
  ,p_record_received                in     date
  ,p_attribute_category             in     varchar2
  ,p_attribute1                     in     varchar2
  ,p_attribute2                     in     varchar2
  ,p_attribute3                     in     varchar2
  ,p_attribute4                     in     varchar2
  ,p_attribute5                     in     varchar2
  ,p_attribute6                     in     varchar2
  ,p_attribute7                     in     varchar2
  ,p_attribute8                     in     varchar2
  ,p_attribute9                     in     varchar2
  ,p_attribute10                    in     varchar2
  ,p_attribute11                    in     varchar2
  ,p_attribute12                    in     varchar2
  ,p_attribute13                    in     varchar2
  ,p_attribute14                    in     varchar2
  ,p_attribute15                    in     varchar2
  ,p_attribute16                    in     varchar2
  ,p_attribute17                    in     varchar2
  ,p_attribute18                    in     varchar2
  ,p_attribute19                    in     varchar2
  ,p_attribute20                    in     varchar2
  ,p_attribute21                    in     varchar2
  ,p_attribute22                    in     varchar2
  ,p_attribute23                    in     varchar2
  ,p_attribute24                    in     varchar2
  ,p_attribute25                    in     varchar2
  ,p_attribute26                    in     varchar2
  ,p_attribute27                    in     varchar2
  ,p_attribute28                    in     varchar2
  ,p_attribute29                    in     varchar2
  ,p_attribute30                    in     varchar2
  ,p_complaint_id                      out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'create_complaint';
  l_complaint_id          ghr_complaints2.complaint_id%TYPE;
  l_object_version_number ghr_complaints2.object_version_number%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_complaint;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    GHR_COMPLAINT_BK_1.create_complaint_b
  (p_effective_date                 => trunc(p_effective_date)
  ,p_business_group_id              => p_business_group_id
  ,p_complainant_person_id          => p_complainant_person_id
  ,p_docket_number                  => p_docket_number
  ,p_stage                          => p_stage
  ,p_class_flag                     => p_class_flag
  ,p_mixed_flag                     => p_mixed_flag
  ,p_consolidated_flag              => p_consolidated_flag
  ,p_remand_flag                    => p_remand_flag
  ,p_active_flag                    => p_active_flag
  ,p_information_inquiry            => p_information_inquiry
  ,p_pcom_init                      => p_pcom_init
  ,p_alleg_incident                 => p_alleg_incident
  ,p_alleg_discrim_org_id           => p_alleg_discrim_org_id
  ,p_rr_ltr_date                    => p_rr_ltr_date
  ,p_rr_ltr_recvd                   => p_rr_ltr_recvd
  ,p_pre_com_elec                   => p_pre_com_elec
  --,p_adr_offered                    => p_adr_offered
  ,p_class_agent_flag               => p_class_agent_flag
  ,p_pre_com_desc                   => p_pre_com_desc
  ,p_counselor_asg                  => p_counselor_asg
  ,p_init_counselor_interview       => p_init_counselor_interview
  ,p_anonymity_requested            => p_anonymity_requested
  ,p_counsel_ext_ltr                => p_counsel_ext_ltr
  ,p_traditional_counsel_outcome    => p_traditional_counsel_outcome
  ,p_final_interview                => p_final_interview
  ,p_notice_rtf_recvd               => p_notice_rtf_recvd
  ,p_precom_closed                  => p_precom_closed
  ,p_precom_closure_nature          => p_precom_closure_nature
  ,p_counselor_rpt_sub              => p_counselor_rpt_sub
  ,p_hr_office_org_id               => p_hr_office_org_id
  ,p_eeo_office_org_id              => p_eeo_office_org_id
  ,p_serviced_org_id                => p_serviced_org_id
  ,p_formal_com_filed               => p_formal_com_filed
  ,p_ack_ltr                        => p_ack_ltr
  ,p_clarification_ltr_date         => p_clarification_ltr_date
  ,p_clarification_response_recvd   => p_clarification_response_recvd
  ,p_forwarded_legal_review         => p_forwarded_legal_review
  ,p_returned_from_legal            => p_returned_from_legal
  ,p_letter_type                    => p_letter_type
  ,p_letter_date                    => p_letter_date
  ,p_letter_recvd                   => p_letter_recvd
  ,p_investigation_source           => p_investigation_source
  ,p_investigator_recvd_req         => p_investigator_recvd_req
  ,p_agency_investigator_req        => p_agency_investigator_req
  ,p_investigator_asg               => p_investigator_asg
  ,p_investigation_start            => p_investigation_start
  ,p_investigation_end              => p_investigation_end
  ,p_investigation_extended         => p_investigation_extended
  ,p_invest_extension_desc          => p_invest_extension_desc
  ,p_agency_recvd_roi               => p_agency_recvd_roi
  ,p_comrep_recvd_roi               => p_comrep_recvd_roi
  ,p_options_ltr_date               => p_options_ltr_date
  ,p_comrep_recvd_opt_ltr           => p_comrep_recvd_opt_ltr
  ,p_comrep_opt_ltr_response        => p_comrep_opt_ltr_response
  ,p_resolution_offer               => p_resolution_offer
  ,p_comrep_resol_offer_recvd       => p_comrep_resol_offer_recvd
  ,p_comrep_resol_offer_response    => p_comrep_resol_offer_response
  ,p_comrep_resol_offer_desc        => p_comrep_resol_offer_desc
  ,p_resol_offer_signed             => p_resol_offer_signed
  ,p_resol_offer_desc               => p_resol_offer_desc
  ,p_hearing_source                 => p_hearing_source
  ,p_agency_notified_hearing        => p_agency_notified_hearing
  ,p_eeoc_hearing_docket_num        => p_eeoc_hearing_docket_num
  ,p_hearing_complete               => p_hearing_complete
  ,p_aj_merit_decision_date         => p_aj_merit_decision_date
  ,p_agency_recvd_aj_merit_dec      => p_agency_recvd_aj_merit_dec
  ,p_aj_merit_decision              => p_aj_merit_decision
  ,p_aj_ca_decision_date            => p_aj_ca_decision_date
  ,p_agency_recvd_aj_ca_dec         => p_agency_recvd_aj_ca_dec
  ,p_aj_ca_decision                 => p_aj_ca_decision
  ,p_fad_requested                  => p_fad_requested
  ,p_merit_fad                      => p_merit_fad
  ,p_attorney_fees_fad              => p_attorney_fees_fad
  ,p_comp_damages_fad               => p_comp_damages_fad
  ,p_non_compliance_fad             => p_non_compliance_fad
  ,p_fad_req_recvd_eeo_office       => p_fad_req_recvd_eeo_office
  ,p_fad_req_forwd_to_agency        => p_fad_req_forwd_to_agency
  ,p_agency_recvd_request           => p_agency_recvd_request
  ,p_fad_due                        => p_fad_due
  ,p_fad_date                       => p_fad_date
  ,p_fad_decision                   => p_fad_decision
  --,p_fad_final_action_closure       => p_fad_final_action_closure
  ,p_fad_forwd_to_comrep            => p_fad_forwd_to_comrep
  ,p_fad_recvd_by_comrep            => p_fad_recvd_by_comrep
  ,p_fad_imp_ltr_forwd_to_org       => p_fad_imp_ltr_forwd_to_org
  ,p_fad_decision_forwd_legal       => p_fad_decision_forwd_legal
  ,p_fad_decision_recvd_legal       => p_fad_decision_recvd_legal
  ,p_fa_source                      => p_fa_source
  ,p_final_action_due               => p_final_action_due
  --,p_final_action_nature_of_closu   => p_final_action_nature_of_closu
  ,p_final_act_forwd_comrep         => p_final_act_forwd_comrep
  ,p_final_act_recvd_comrep         => p_final_act_recvd_comrep
  ,p_final_action_decision_date     => p_final_action_decision_date
  ,p_final_action_decision          => p_final_action_decision
  ,p_fa_imp_ltr_forwd_to_org        => p_fa_imp_ltr_forwd_to_org
  ,p_fa_decision_forwd_legal        => p_fa_decision_forwd_legal
  ,p_fa_decision_recvd_legal        => p_fa_decision_recvd_legal
  ,p_civil_action_filed             => p_civil_action_filed
  ,p_agency_closure_confirmed       => p_agency_closure_confirmed
  ,p_consolidated_complaint_id      => p_consolidated_complaint_id
  ,p_consolidated                   => p_consolidated
  ,p_stage_of_consolidation         => p_stage_of_consolidation
  ,p_comrep_notif_consolidation     => p_comrep_notif_consolidation
  ,p_consolidation_desc             => p_consolidation_desc
  ,p_complaint_closed               => p_complaint_closed
  ,p_nature_of_closure              => p_nature_of_closure
  ,p_complaint_closed_desc          => p_complaint_closed_desc
  ,p_filed_formal_class             => p_filed_formal_class
  ,p_forwd_eeoc                     => p_forwd_eeoc
  ,p_aj_cert_decision_date          => p_aj_cert_decision_date
  ,p_aj_cert_decision_recvd         => p_aj_cert_decision_recvd
  ,p_aj_cert_decision               => p_aj_cert_decision
  ,p_class_members_notified         => p_class_members_notified
  ,p_number_of_complaintants        => p_number_of_complaintants
  ,p_class_hearing                  => p_class_hearing
  ,p_aj_dec                         => p_aj_dec
  ,p_agency_recvd_aj_dec            => p_agency_recvd_aj_dec
  ,p_aj_decision                    => p_aj_decision
  ,p_agency_brief_eeoc              => p_agency_brief_eeoc
  ,p_agency_notif_of_civil_action   => p_agency_notif_of_civil_action
  ,p_fad_source                     => p_fad_source
  ,p_agency_files_forwarded_eeoc    => p_agency_files_forwarded_eeoc
  ,p_hearing_req                    => p_hearing_req
  ,p_agency_code                    => p_agency_code
  ,p_audited_by                     => p_audited_by
  ,p_record_received                => p_record_received
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  ,p_attribute21                    => p_attribute21
  ,p_attribute22                    => p_attribute22
  ,p_attribute23                    => p_attribute23
  ,p_attribute24                    => p_attribute24
  ,p_attribute25                    => p_attribute25
  ,p_attribute26                    => p_attribute26
  ,p_attribute27                    => p_attribute27
  ,p_attribute28                    => p_attribute28
  ,p_attribute29                    => p_attribute29
  ,p_attribute30                    => p_attribute30
    );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'Create_Complaint'
          ,p_hook_type   => 'BP'
          );
    end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --

  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  ghr_cmp_ins.ins
  (p_effective_date                  =>  p_effective_date
  ,p_complainant_person_id           =>  p_complainant_person_id
  ,p_business_group_id               =>  p_business_group_id
  ,p_docket_number                   =>  p_docket_number
  ,p_stage                           =>  p_stage
  ,p_class_flag                      =>  p_class_flag
  ,p_mixed_flag                      =>  p_mixed_flag
  ,p_consolidated_flag               =>  p_consolidated_flag
  ,p_remand_flag                     =>  p_remand_flag
  ,p_active_flag                     =>  p_active_flag
  ,p_information_inquiry             =>  p_information_inquiry
  ,p_pcom_init                       =>  p_pcom_init
  ,p_alleg_incident                  =>  p_alleg_incident
  ,p_alleg_discrim_org_id            =>  p_alleg_discrim_org_id
  ,p_rr_ltr_date                     =>  p_rr_ltr_date
  ,p_rr_ltr_recvd                    =>  p_rr_ltr_recvd
  ,p_pre_com_elec                    =>  p_pre_com_elec
  --,p_adr_offered                     =>  p_adr_offered
  ,p_class_agent_flag                =>  p_class_agent_flag
  ,p_pre_com_desc                    =>  p_pre_com_desc
  ,p_counselor_asg                   =>  p_counselor_asg
  ,p_init_counselor_interview        =>  p_init_counselor_interview
  ,p_anonymity_requested             =>  p_anonymity_requested
  ,p_counsel_ext_ltr                 =>  p_counsel_ext_ltr
  ,p_traditional_counsel_outcome     =>  p_traditional_counsel_outcome
  ,p_final_interview                 =>  p_final_interview
  ,p_notice_rtf_recvd                =>  p_notice_rtf_recvd
  ,p_precom_closed                   =>  p_precom_closed
  ,p_precom_closure_nature           =>  p_precom_closure_nature
  ,p_counselor_rpt_sub               =>  p_counselor_rpt_sub
  ,p_hr_office_org_id                =>  p_hr_office_org_id
  ,p_eeo_office_org_id               =>  p_eeo_office_org_id
  ,p_serviced_org_id                 =>  p_serviced_org_id
  ,p_formal_com_filed                =>  p_formal_com_filed
  ,p_ack_ltr                         =>  p_ack_ltr
  ,p_clarification_ltr_date          =>  p_clarification_ltr_date
  ,p_clarification_response_recvd    =>  p_clarification_response_recvd
  ,p_forwarded_legal_review          =>  p_forwarded_legal_review
  ,p_returned_from_legal             =>  p_returned_from_legal
  ,p_letter_type                     =>  p_letter_type
  ,p_letter_date                     =>  p_letter_date
  ,p_letter_recvd                    =>  p_letter_recvd
  ,p_investigation_source            =>  p_investigation_source
  ,p_investigator_recvd_req          =>  p_investigator_recvd_req
  ,p_agency_investigator_req         =>  p_agency_investigator_req
  ,p_investigator_asg                =>  p_investigator_asg
  ,p_investigation_start             =>  p_investigation_start
  ,p_investigation_end               =>  p_investigation_end
  ,p_investigation_extended          =>  p_investigation_extended
  ,p_invest_extension_desc           =>  p_invest_extension_desc
  ,p_agency_recvd_roi                =>  p_agency_recvd_roi
  ,p_comrep_recvd_roi                =>  p_comrep_recvd_roi
  ,p_options_ltr_date                =>  p_options_ltr_date
  ,p_comrep_recvd_opt_ltr            =>  p_comrep_recvd_opt_ltr
  ,p_comrep_opt_ltr_response         =>  p_comrep_opt_ltr_response
  ,p_resolution_offer                =>  p_resolution_offer
  ,p_comrep_resol_offer_recvd        =>  p_comrep_resol_offer_recvd
  ,p_comrep_resol_offer_response     =>  p_comrep_resol_offer_response
  ,p_comrep_resol_offer_desc         =>  p_comrep_resol_offer_desc
  ,p_resol_offer_signed              =>  p_resol_offer_signed
  ,p_resol_offer_desc                =>  p_resol_offer_desc
  ,p_hearing_source                  =>  p_hearing_source
  ,p_agency_notified_hearing         =>  p_agency_notified_hearing
  ,p_eeoc_hearing_docket_num         =>  p_eeoc_hearing_docket_num
  ,p_hearing_complete                =>  p_hearing_complete
  ,p_aj_merit_decision_date          =>  p_aj_merit_decision_date
  ,p_agency_recvd_aj_merit_dec       =>  p_agency_recvd_aj_merit_dec
  ,p_aj_merit_decision               =>  p_aj_merit_decision
  ,p_aj_ca_decision_date             =>  p_aj_ca_decision_date
  ,p_agency_recvd_aj_ca_dec          =>  p_agency_recvd_aj_ca_dec
  ,p_aj_ca_decision                  =>  p_aj_ca_decision
  ,p_fad_requested                   =>  p_fad_requested
  ,p_merit_fad                       =>  p_merit_fad
  ,p_attorney_fees_fad               =>  p_attorney_fees_fad
  ,p_comp_damages_fad                =>  p_comp_damages_fad
  ,p_non_compliance_fad              =>  p_non_compliance_fad
  ,p_fad_req_recvd_eeo_office        =>  p_fad_req_recvd_eeo_office
  ,p_fad_req_forwd_to_agency         =>  p_fad_req_forwd_to_agency
  ,p_agency_recvd_request            =>  p_agency_recvd_request
  ,p_fad_due                         =>  p_fad_due
  ,p_fad_date                        =>  p_fad_date
  ,p_fad_decision                    =>  p_fad_decision
  --,p_fad_final_action_closure        =>  p_fad_final_action_closure
  ,p_fad_forwd_to_comrep             =>  p_fad_forwd_to_comrep
  ,p_fad_recvd_by_comrep             =>  p_fad_recvd_by_comrep
  ,p_fad_imp_ltr_forwd_to_org        =>  p_fad_imp_ltr_forwd_to_org
  ,p_fad_decision_forwd_legal        =>  p_fad_decision_forwd_legal
  ,p_fad_decision_recvd_legal        =>  p_fad_decision_recvd_legal
  ,p_fa_source                       =>  p_fa_source
  ,p_final_action_due                =>  p_final_action_due
  --,p_final_action_nature_of_closu    =>  p_final_action_nature_of_closu
  ,p_final_act_forwd_comrep          =>  p_final_act_forwd_comrep
  ,p_final_act_recvd_comrep          =>  p_final_act_recvd_comrep
  ,p_final_action_decision_date      =>  p_final_action_decision_date
  ,p_final_action_decision           =>  p_final_action_decision
  ,p_fa_imp_ltr_forwd_to_org         =>  p_fa_imp_ltr_forwd_to_org
  ,p_fa_decision_forwd_legal         =>  p_fa_decision_forwd_legal
  ,p_fa_decision_recvd_legal         =>  p_fa_decision_recvd_legal
  ,p_civil_action_filed              =>  p_civil_action_filed
  ,p_agency_closure_confirmed        =>  p_agency_closure_confirmed
  ,p_consolidated_complaint_id       =>  p_consolidated_complaint_id
  ,p_consolidated                    =>  p_consolidated
  ,p_stage_of_consolidation          =>  p_stage_of_consolidation
  ,p_comrep_notif_consolidation      =>  p_comrep_notif_consolidation
  ,p_consolidation_desc              =>  p_consolidation_desc
  ,p_complaint_closed                =>  p_complaint_closed
  ,p_nature_of_closure               =>  p_nature_of_closure
  ,p_complaint_closed_desc           =>  p_complaint_closed_desc
  ,p_filed_formal_class              =>  p_filed_formal_class
  ,p_forwd_eeoc                      =>  p_forwd_eeoc
  ,p_aj_cert_decision_date           =>  p_aj_cert_decision_date
  ,p_aj_cert_decision_recvd          =>  p_aj_cert_decision_recvd
  ,p_aj_cert_decision                =>  p_aj_cert_decision
  ,p_class_members_notified          =>  p_class_members_notified
  ,p_number_of_complaintants         =>  p_number_of_complaintants
  ,p_class_hearing                   =>  p_class_hearing
  ,p_aj_dec                          =>  p_aj_dec
  ,p_agency_recvd_aj_dec             =>  p_agency_recvd_aj_dec
  ,p_aj_decision                     =>  p_aj_decision
  ,p_agency_brief_eeoc               =>  p_agency_brief_eeoc
  ,p_agency_notif_of_civil_action    =>  p_agency_notif_of_civil_action
  ,p_fad_source                      =>  p_fad_source
  ,p_agency_files_forwarded_eeoc     =>  p_agency_files_forwarded_eeoc
  ,p_hearing_req                     =>  p_hearing_req
  ,p_agency_code                     =>  p_agency_code
  ,p_audited_by                      =>  p_audited_by
  ,p_record_received                 =>  p_record_received
  ,p_attribute_category              =>  p_attribute_category
  ,p_attribute1                      =>  p_attribute1
  ,p_attribute2                      =>  p_attribute2
  ,p_attribute3                      =>  p_attribute3
  ,p_attribute4                      =>  p_attribute4
  ,p_attribute5                      =>  p_attribute5
  ,p_attribute6                      =>  p_attribute6
  ,p_attribute7                      =>  p_attribute7
  ,p_attribute8                      =>  p_attribute8
  ,p_attribute9                      =>  p_attribute9
  ,p_attribute10                     =>  p_attribute10
  ,p_attribute11                     =>  p_attribute11
  ,p_attribute12                     =>  p_attribute12
  ,p_attribute13                     =>  p_attribute13
  ,p_attribute14                     =>  p_attribute14
  ,p_attribute15                     =>  p_attribute15
  ,p_attribute16                     =>  p_attribute16
  ,p_attribute17                     =>  p_attribute17
  ,p_attribute18                     =>  p_attribute18
  ,p_attribute19                     =>  p_attribute19
  ,p_attribute20                     =>  p_attribute20
  ,p_attribute21                     =>  p_attribute21
  ,p_attribute22                     =>  p_attribute22
  ,p_attribute23                     =>  p_attribute23
  ,p_attribute24                     =>  p_attribute24
  ,p_attribute25                     =>  p_attribute25
  ,p_attribute26                     =>  p_attribute26
  ,p_attribute27                     =>  p_attribute27
  ,p_attribute28                     =>  p_attribute28
  ,p_attribute29                     =>  p_attribute29
  ,p_attribute30                     =>  p_attribute30
  ,p_complaint_id                    =>  l_complaint_id
  ,p_object_version_number           =>  l_object_version_number
  );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    GHR_COMPLAINT_BK_1.create_complaint_a
  (p_effective_date                 => trunc(p_effective_date)
  ,p_business_group_id              => p_business_group_id
  ,p_complainant_person_id          => p_complainant_person_id
  ,p_docket_number                  => p_docket_number
  ,p_stage                          => p_stage
  ,p_class_flag                     => p_class_flag
  ,p_mixed_flag                     => p_mixed_flag
  ,p_consolidated_flag              => p_consolidated_flag
  ,p_remand_flag                    => p_remand_flag
  ,p_active_flag                    => p_active_flag
  ,p_information_inquiry            => p_information_inquiry
  ,p_pcom_init                      => p_pcom_init
  ,p_alleg_incident                 => p_alleg_incident
  ,p_alleg_discrim_org_id           => p_alleg_discrim_org_id
  ,p_rr_ltr_date                    => p_rr_ltr_date
  ,p_rr_ltr_recvd                   => p_rr_ltr_recvd
  ,p_pre_com_elec                   => p_pre_com_elec
  --,p_adr_offered                    => p_adr_offered
  ,p_class_agent_flag               => p_class_agent_flag
  ,p_pre_com_desc                   => p_pre_com_desc
  ,p_counselor_asg                  => p_counselor_asg
  ,p_init_counselor_interview       => p_init_counselor_interview
  ,p_anonymity_requested            => p_anonymity_requested
  ,p_counsel_ext_ltr                => p_counsel_ext_ltr
  ,p_traditional_counsel_outcome    => p_traditional_counsel_outcome
  ,p_final_interview                => p_final_interview
  ,p_notice_rtf_recvd               => p_notice_rtf_recvd
  ,p_precom_closed                  => p_precom_closed
  ,p_precom_closure_nature          => p_precom_closure_nature
  ,p_counselor_rpt_sub              => p_counselor_rpt_sub
  ,p_hr_office_org_id               => p_hr_office_org_id
  ,p_eeo_office_org_id              => p_eeo_office_org_id
  ,p_serviced_org_id                => p_serviced_org_id
  ,p_formal_com_filed               => p_formal_com_filed
  ,p_ack_ltr                        => p_ack_ltr
  ,p_clarification_ltr_date         => p_clarification_ltr_date
  ,p_clarification_response_recvd   => p_clarification_response_recvd
  ,p_forwarded_legal_review         => p_forwarded_legal_review
  ,p_returned_from_legal            => p_returned_from_legal
  ,p_letter_type                    => p_letter_type
  ,p_letter_date                    => p_letter_date
  ,p_letter_recvd                   => p_letter_recvd
  ,p_investigation_source           => p_investigation_source
  ,p_investigator_recvd_req         => p_investigator_recvd_req
  ,p_agency_investigator_req        => p_agency_investigator_req
  ,p_investigator_asg               => p_investigator_asg
  ,p_investigation_start            => p_investigation_start
  ,p_investigation_end              => p_investigation_end
  ,p_investigation_extended         => p_investigation_extended
  ,p_invest_extension_desc          => p_invest_extension_desc
  ,p_agency_recvd_roi               => p_agency_recvd_roi
  ,p_comrep_recvd_roi               => p_comrep_recvd_roi
  ,p_options_ltr_date               => p_options_ltr_date
  ,p_comrep_recvd_opt_ltr           => p_comrep_recvd_opt_ltr
  ,p_comrep_opt_ltr_response        => p_comrep_opt_ltr_response
  ,p_resolution_offer               => p_resolution_offer
  ,p_comrep_resol_offer_recvd       => p_comrep_resol_offer_recvd
  ,p_comrep_resol_offer_response    => p_comrep_resol_offer_response
  ,p_comrep_resol_offer_desc        => p_comrep_resol_offer_desc
  ,p_resol_offer_signed             => p_resol_offer_signed
  ,p_resol_offer_desc               => p_resol_offer_desc
  ,p_hearing_source                 => p_hearing_source
  ,p_agency_notified_hearing        => p_agency_notified_hearing
  ,p_eeoc_hearing_docket_num        => p_eeoc_hearing_docket_num
  ,p_hearing_complete               => p_hearing_complete
  ,p_aj_merit_decision_date         => p_aj_merit_decision_date
  ,p_agency_recvd_aj_merit_dec      => p_agency_recvd_aj_merit_dec
  ,p_aj_merit_decision              => p_aj_merit_decision
  ,p_aj_ca_decision_date            => p_aj_ca_decision_date
  ,p_agency_recvd_aj_ca_dec         => p_agency_recvd_aj_ca_dec
  ,p_aj_ca_decision                 => p_aj_ca_decision
  ,p_fad_requested                  => p_fad_requested
  ,p_merit_fad                      => p_merit_fad
  ,p_attorney_fees_fad              => p_attorney_fees_fad
  ,p_comp_damages_fad               => p_comp_damages_fad
  ,p_non_compliance_fad             => p_non_compliance_fad
  ,p_fad_req_recvd_eeo_office       => p_fad_req_recvd_eeo_office
  ,p_fad_req_forwd_to_agency        => p_fad_req_forwd_to_agency
  ,p_agency_recvd_request           => p_agency_recvd_request
  ,p_fad_due                        => p_fad_due
  ,p_fad_date                       => p_fad_date
  ,p_fad_decision                   => p_fad_decision
  --,p_fad_final_action_closure       => p_fad_final_action_closure
  ,p_fad_forwd_to_comrep            => p_fad_forwd_to_comrep
  ,p_fad_recvd_by_comrep            => p_fad_recvd_by_comrep
  ,p_fad_imp_ltr_forwd_to_org       => p_fad_imp_ltr_forwd_to_org
  ,p_fad_decision_forwd_legal       => p_fad_decision_forwd_legal
  ,p_fad_decision_recvd_legal       => p_fad_decision_recvd_legal
  ,p_fa_source                      => p_fa_source
  ,p_final_action_due               => p_final_action_due
  --,p_final_action_nature_of_closu   => p_final_action_nature_of_closu
  ,p_final_act_forwd_comrep         => p_final_act_forwd_comrep
  ,p_final_act_recvd_comrep         => p_final_act_recvd_comrep
  ,p_final_action_decision_date     => p_final_action_decision_date
  ,p_final_action_decision          => p_final_action_decision
  ,p_fa_imp_ltr_forwd_to_org        => p_fa_imp_ltr_forwd_to_org
  ,p_fa_decision_forwd_legal        => p_fa_decision_forwd_legal
  ,p_fa_decision_recvd_legal        => p_fa_decision_recvd_legal
  ,p_civil_action_filed             => p_civil_action_filed
  ,p_agency_closure_confirmed       => p_agency_closure_confirmed
  ,p_consolidated_complaint_id      => p_consolidated_complaint_id
  ,p_consolidated                   => p_consolidated
  ,p_stage_of_consolidation         => p_stage_of_consolidation
  ,p_comrep_notif_consolidation     => p_comrep_notif_consolidation
  ,p_consolidation_desc             => p_consolidation_desc
  ,p_complaint_closed               => p_complaint_closed
  ,p_nature_of_closure              => p_nature_of_closure
  ,p_complaint_closed_desc          => p_complaint_closed_desc
  ,p_filed_formal_class             => p_filed_formal_class
  ,p_forwd_eeoc                     => p_forwd_eeoc
  ,p_aj_cert_decision_date          => p_aj_cert_decision_date
  ,p_aj_cert_decision_recvd         => p_aj_cert_decision_recvd
  ,p_aj_cert_decision               => p_aj_cert_decision
  ,p_class_members_notified         => p_class_members_notified
  ,p_number_of_complaintants        => p_number_of_complaintants
  ,p_class_hearing                  => p_class_hearing
  ,p_aj_dec                         => p_aj_dec
  ,p_agency_recvd_aj_dec            => p_agency_recvd_aj_dec
  ,p_aj_decision                    => p_aj_decision
  ,p_agency_brief_eeoc              => p_agency_brief_eeoc
  ,p_agency_notif_of_civil_action   => p_agency_notif_of_civil_action
  ,p_fad_source                     => p_fad_source
  ,p_agency_files_forwarded_eeoc    => p_agency_files_forwarded_eeoc
  ,p_hearing_req                    => p_hearing_req
  ,p_agency_code                    => p_agency_code
  ,p_audited_by                     => p_audited_by
  ,p_record_received                => p_record_received
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  ,p_attribute21                    => p_attribute21
  ,p_attribute22                    => p_attribute22
  ,p_attribute23                    => p_attribute23
  ,p_attribute24                    => p_attribute24
  ,p_attribute25                    => p_attribute25
  ,p_attribute26                    => p_attribute26
  ,p_attribute27                    => p_attribute27
  ,p_attribute28                    => p_attribute28
  ,p_attribute29                    => p_attribute29
  ,p_attribute30                    => p_attribute30
  ,p_complaint_id                   => l_complaint_id
  ,p_object_version_number          => l_object_version_number
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'Create_Complaint'
          ,p_hook_type   => 'AP'
          );
    end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_complaint_id           := l_complaint_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_complaint;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_complaint_id           := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_complaint;
    -- RESET In/Out Params and SET Out Params
    p_complaint_id           := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_complaint;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_complaint >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_complaint
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_complaint_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_complainant_person_id        in     number
  ,p_business_group_id            in     number
  ,p_docket_number                in     varchar2
  ,p_stage                        in     varchar2
  ,p_class_flag                   in     varchar2
  ,p_mixed_flag                   in     varchar2
  ,p_consolidated_flag            in     varchar2
  ,p_remand_flag                  in     varchar2
  ,p_active_flag                  in     varchar2
  ,p_information_inquiry          in     date
  ,p_pcom_init                    in     date
  ,p_alleg_incident               in     date
  ,p_alleg_discrim_org_id         in     number
  ,p_rr_ltr_date                  in     date
  ,p_rr_ltr_recvd                 in     date
  ,p_pre_com_elec                 in     varchar2
  --,p_adr_offered                  in     varchar2
  ,p_class_agent_flag             in     varchar2
  ,p_pre_com_desc                 in     varchar2
  ,p_counselor_asg                in     date
  ,p_init_counselor_interview     in     date
  ,p_anonymity_requested          in     varchar2
  ,p_counsel_ext_ltr              in     date
  ,p_traditional_counsel_outcome  in     varchar2
  ,p_final_interview              in     date
  ,p_notice_rtf_recvd             in     date
  ,p_precom_closed                in     date
  ,p_precom_closure_nature        in     varchar2
  ,p_counselor_rpt_sub            in     date
  ,p_hr_office_org_id             in     number
  ,p_eeo_office_org_id            in     number
  ,p_serviced_org_id              in     number
  ,p_formal_com_filed             in     date
  ,p_ack_ltr                      in     date
  ,p_clarification_ltr_date       in     date
  ,p_clarification_response_recvd in     date
  ,p_forwarded_legal_review       in     date
  ,p_returned_from_legal          in     date
  ,p_letter_type                  in     varchar2
  ,p_letter_date                  in     date
  ,p_letter_recvd                 in     date
  ,p_investigation_source         in     varchar2
  ,p_investigator_recvd_req       in     date
  ,p_agency_investigator_req      in     date
  ,p_investigator_asg             in     date
  ,p_investigation_start          in     date
  ,p_investigation_end            in     date
  ,p_investigation_extended       in     date
  ,p_invest_extension_desc        in     varchar2
  ,p_agency_recvd_roi             in     date
  ,p_comrep_recvd_roi             in     date
  ,p_options_ltr_date             in     date
  ,p_comrep_recvd_opt_ltr         in     date
  ,p_comrep_opt_ltr_response      in     varchar2
  ,p_resolution_offer             in     date
  ,p_comrep_resol_offer_recvd     in     date
  ,p_comrep_resol_offer_response  in     date
  ,p_comrep_resol_offer_desc      in     varchar2
  ,p_resol_offer_signed           in     date
  ,p_resol_offer_desc             in     varchar2
  ,p_hearing_source               in     varchar2
  ,p_agency_notified_hearing      in     date
  ,p_eeoc_hearing_docket_num      in     varchar2
  ,p_hearing_complete             in     date
  ,p_aj_merit_decision_date       in     date
  ,p_agency_recvd_aj_merit_dec    in     date
  ,p_aj_merit_decision            in     varchar2
  ,p_aj_ca_decision_date          in     date
  ,p_agency_recvd_aj_ca_dec       in     date
  ,p_aj_ca_decision               in     varchar2
  ,p_fad_requested                in     date
  ,p_merit_fad                    in     varchar2
  ,p_attorney_fees_fad            in     varchar2
  ,p_comp_damages_fad             in     varchar2
  ,p_non_compliance_fad           in     varchar2
  ,p_fad_req_recvd_eeo_office     in     date
  ,p_fad_req_forwd_to_agency      in     date
  ,p_agency_recvd_request         in     date
  ,p_fad_due                      in     date
  ,p_fad_date                     in     date
  ,p_fad_decision                 in     varchar2
  --,p_fad_final_action_closure     in     varchar2
  ,p_fad_forwd_to_comrep          in     date
  ,p_fad_recvd_by_comrep          in     date
  ,p_fad_imp_ltr_forwd_to_org     in     date
  ,p_fad_decision_forwd_legal     in     date
  ,p_fad_decision_recvd_legal     in     date
  ,p_fa_source                    in     varchar2
  ,p_final_action_due             in     date
  --,p_final_action_nature_of_closu in     varchar2
  ,p_final_act_forwd_comrep       in     date
  ,p_final_act_recvd_comrep       in     date
  ,p_final_action_decision_date   in     date
  ,p_final_action_decision        in     varchar2
  ,p_fa_imp_ltr_forwd_to_org      in     date
  ,p_fa_decision_forwd_legal      in     date
  ,p_fa_decision_recvd_legal      in     date
  ,p_civil_action_filed           in     date
  ,p_agency_closure_confirmed     in     date
  ,p_consolidated_complaint_id    in     number
  ,p_consolidated                 in     date
  ,p_stage_of_consolidation       in     varchar2
  ,p_comrep_notif_consolidation   in     date
  ,p_consolidation_desc           in     varchar2
  ,p_complaint_closed             in     date
  ,p_nature_of_closure            in     varchar2
  ,p_complaint_closed_desc        in     varchar2
  ,p_filed_formal_class           in     date
  ,p_forwd_eeoc                   in     date
  ,p_aj_cert_decision_date        in     date
  ,p_aj_cert_decision_recvd       in     date
  ,p_aj_cert_decision             in     varchar2
  ,p_class_members_notified       in     date
  ,p_number_of_complaintants      in     number
  ,p_class_hearing                in     date
  ,p_aj_dec                       in     date
  ,p_agency_recvd_aj_dec          in     date
  ,p_aj_decision                  in     varchar2
  ,p_agency_brief_eeoc            in     date
  ,p_agency_notif_of_civil_action in     date
  ,p_fad_source                   in     varchar2
  ,p_agency_files_forwarded_eeoc  in     date
  ,p_hearing_req                  in     date
  ,p_agency_code                  in     varchar2
  ,p_audited_by                   in     varchar2
  ,p_record_received              in     date
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_attribute21                  in     varchar2
  ,p_attribute22                  in     varchar2
  ,p_attribute23                  in     varchar2
  ,p_attribute24                  in     varchar2
  ,p_attribute25                  in     varchar2
  ,p_attribute26                  in     varchar2
  ,p_attribute27                  in     varchar2
  ,p_attribute28                  in     varchar2
  ,p_attribute29                  in     varchar2
  ,p_attribute30                  in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'create_complaint';
  l_object_version_number ghr_complaints2.object_version_number%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_complaint;
  hr_utility.set_location(l_proc, 20);
  l_object_version_number  := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    GHR_COMPLAINT_BK_2.update_complaint_b
  (p_effective_date                 => trunc(p_effective_date)
  ,p_business_group_id              => p_business_group_id
  ,p_complaint_id                   => p_complaint_id
  ,p_object_version_number          => p_object_version_number
  ,p_complainant_person_id          => p_complainant_person_id
  ,p_docket_number                  => p_docket_number
  ,p_stage                          => p_stage
  ,p_class_flag                     => p_class_flag
  ,p_mixed_flag                     => p_mixed_flag
  ,p_consolidated_flag              => p_consolidated_flag
  ,p_remand_flag                    => p_remand_flag
  ,p_active_flag                    => p_active_flag
  ,p_information_inquiry            => p_information_inquiry
  ,p_pcom_init                      => p_pcom_init
  ,p_alleg_incident                 => p_alleg_incident
  ,p_alleg_discrim_org_id           => p_alleg_discrim_org_id
  ,p_rr_ltr_date                    => p_rr_ltr_date
  ,p_rr_ltr_recvd                   => p_rr_ltr_recvd
  ,p_pre_com_elec                   => p_pre_com_elec
  --,p_adr_offered                    => p_adr_offered
  ,p_class_agent_flag               => p_class_agent_flag
  ,p_pre_com_desc                   => p_pre_com_desc
  ,p_counselor_asg                  => p_counselor_asg
  ,p_init_counselor_interview       => p_init_counselor_interview
  ,p_anonymity_requested            => p_anonymity_requested
  ,p_counsel_ext_ltr                => p_counsel_ext_ltr
  ,p_traditional_counsel_outcome    => p_traditional_counsel_outcome
  ,p_final_interview                => p_final_interview
  ,p_notice_rtf_recvd               => p_notice_rtf_recvd
  ,p_precom_closed                  => p_precom_closed
  ,p_precom_closure_nature          => p_precom_closure_nature
  ,p_counselor_rpt_sub              => p_counselor_rpt_sub
  ,p_hr_office_org_id               => p_hr_office_org_id
  ,p_eeo_office_org_id              => p_eeo_office_org_id
  ,p_serviced_org_id                => p_serviced_org_id
  ,p_formal_com_filed               => p_formal_com_filed
  ,p_ack_ltr                        => p_ack_ltr
  ,p_clarification_ltr_date         => p_clarification_ltr_date
  ,p_clarification_response_recvd   => p_clarification_response_recvd
  ,p_forwarded_legal_review         => p_forwarded_legal_review
  ,p_returned_from_legal            => p_returned_from_legal
  ,p_letter_type                    => p_letter_type
  ,p_letter_date                    => p_letter_date
  ,p_letter_recvd                   => p_letter_recvd
  ,p_investigation_source           => p_investigation_source
  ,p_investigator_recvd_req         => p_investigator_recvd_req
  ,p_agency_investigator_req        => p_agency_investigator_req
  ,p_investigator_asg               => p_investigator_asg
  ,p_investigation_start            => p_investigation_start
  ,p_investigation_end              => p_investigation_end
  ,p_investigation_extended         => p_investigation_extended
  ,p_invest_extension_desc          => p_invest_extension_desc
  ,p_agency_recvd_roi               => p_agency_recvd_roi
  ,p_comrep_recvd_roi               => p_comrep_recvd_roi
  ,p_options_ltr_date               => p_options_ltr_date
  ,p_comrep_recvd_opt_ltr           => p_comrep_recvd_opt_ltr
  ,p_comrep_opt_ltr_response        => p_comrep_opt_ltr_response
  ,p_resolution_offer               => p_resolution_offer
  ,p_comrep_resol_offer_recvd       => p_comrep_resol_offer_recvd
  ,p_comrep_resol_offer_response    => p_comrep_resol_offer_response
  ,p_comrep_resol_offer_desc        => p_comrep_resol_offer_desc
  ,p_resol_offer_signed             => p_resol_offer_signed
  ,p_resol_offer_desc               => p_resol_offer_desc
  ,p_hearing_source                 => p_hearing_source
  ,p_agency_notified_hearing        => p_agency_notified_hearing
  ,p_eeoc_hearing_docket_num        => p_eeoc_hearing_docket_num
  ,p_hearing_complete               => p_hearing_complete
  ,p_aj_merit_decision_date         => p_aj_merit_decision_date
  ,p_agency_recvd_aj_merit_dec      => p_agency_recvd_aj_merit_dec
  ,p_aj_merit_decision              => p_aj_merit_decision
  ,p_aj_ca_decision_date            => p_aj_ca_decision_date
  ,p_agency_recvd_aj_ca_dec         => p_agency_recvd_aj_ca_dec
  ,p_aj_ca_decision                 => p_aj_ca_decision
  ,p_fad_requested                  => p_fad_requested
  ,p_merit_fad                      => p_merit_fad
  ,p_attorney_fees_fad              => p_attorney_fees_fad
  ,p_comp_damages_fad               => p_comp_damages_fad
  ,p_non_compliance_fad             => p_non_compliance_fad
  ,p_fad_req_recvd_eeo_office       => p_fad_req_recvd_eeo_office
  ,p_fad_req_forwd_to_agency        => p_fad_req_forwd_to_agency
  ,p_agency_recvd_request           => p_agency_recvd_request
  ,p_fad_due                        => p_fad_due
  ,p_fad_date                       => p_fad_date
  ,p_fad_decision                   => p_fad_decision
  --,p_fad_final_action_closure       => p_fad_final_action_closure
  ,p_fad_forwd_to_comrep            => p_fad_forwd_to_comrep
  ,p_fad_recvd_by_comrep            => p_fad_recvd_by_comrep
  ,p_fad_imp_ltr_forwd_to_org       => p_fad_imp_ltr_forwd_to_org
  ,p_fad_decision_forwd_legal       => p_fad_decision_forwd_legal
  ,p_fad_decision_recvd_legal       => p_fad_decision_recvd_legal
  ,p_fa_source                      => p_fa_source
  ,p_final_action_due               => p_final_action_due
  --,p_final_action_nature_of_closu   => p_final_action_nature_of_closu
  ,p_final_act_forwd_comrep         => p_final_act_forwd_comrep
  ,p_final_act_recvd_comrep         => p_final_act_recvd_comrep
  ,p_final_action_decision_date     => p_final_action_decision_date
  ,p_final_action_decision          => p_final_action_decision
  ,p_fa_imp_ltr_forwd_to_org        => p_fa_imp_ltr_forwd_to_org
  ,p_fa_decision_forwd_legal        => p_fa_decision_forwd_legal
  ,p_fa_decision_recvd_legal        => p_fa_decision_recvd_legal
  ,p_civil_action_filed             => p_civil_action_filed
  ,p_agency_closure_confirmed       => p_agency_closure_confirmed
  ,p_consolidated_complaint_id      => p_consolidated_complaint_id
  ,p_consolidated                   => p_consolidated
  ,p_stage_of_consolidation         => p_stage_of_consolidation
  ,p_comrep_notif_consolidation     => p_comrep_notif_consolidation
  ,p_consolidation_desc             => p_consolidation_desc
  ,p_complaint_closed               => p_complaint_closed
  ,p_nature_of_closure              => p_nature_of_closure
  ,p_complaint_closed_desc          => p_complaint_closed_desc
  ,p_filed_formal_class             => p_filed_formal_class
  ,p_forwd_eeoc                     => p_forwd_eeoc
  ,p_aj_cert_decision_date          => p_aj_cert_decision_date
  ,p_aj_cert_decision_recvd         => p_aj_cert_decision_recvd
  ,p_aj_cert_decision               => p_aj_cert_decision
  ,p_class_members_notified         => p_class_members_notified
  ,p_number_of_complaintants        => p_number_of_complaintants
  ,p_class_hearing                  => p_class_hearing
  ,p_aj_dec                         => p_aj_dec
  ,p_agency_recvd_aj_dec            => p_agency_recvd_aj_dec
  ,p_aj_decision                    => p_aj_decision
  ,p_agency_brief_eeoc              => p_agency_brief_eeoc
  ,p_agency_notif_of_civil_action   => p_agency_notif_of_civil_action
  ,p_fad_source                     => p_fad_source
  ,p_agency_files_forwarded_eeoc    => p_agency_files_forwarded_eeoc
  ,p_hearing_req                    => p_hearing_req
  ,p_agency_code                    => p_agency_code
  ,p_audited_by                     => p_audited_by
  ,p_record_received                => p_record_received
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  ,p_attribute21                    => p_attribute21
  ,p_attribute22                    => p_attribute22
  ,p_attribute23                    => p_attribute23
  ,p_attribute24                    => p_attribute24
  ,p_attribute25                    => p_attribute25
  ,p_attribute26                    => p_attribute26
  ,p_attribute27                    => p_attribute27
  ,p_attribute28                    => p_attribute28
  ,p_attribute29                    => p_attribute29
  ,p_attribute30                    => p_attribute30
    );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'Update_Complaint'
          ,p_hook_type   => 'BP'
          );
    end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  -- Store the original ovn in case we rollback when p_validate is true
  --
  l_object_version_number  := p_object_version_number;

  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  ghr_cmp_upd.upd
  (p_effective_date                  =>  p_effective_date
  ,p_complaint_id                    =>  p_complaint_id
  ,p_object_version_number           =>  l_object_version_number
  ,p_complainant_person_id           =>  p_complainant_person_id
  ,p_business_group_id               =>  p_business_group_id
  ,p_docket_number                   =>  p_docket_number
  ,p_stage                           =>  p_stage
  ,p_class_flag                      =>  p_class_flag
  ,p_mixed_flag                      =>  p_mixed_flag
  ,p_consolidated_flag               =>  p_consolidated_flag
  ,p_remand_flag                     =>  p_remand_flag
  ,p_active_flag                     =>  p_active_flag
  ,p_information_inquiry             =>  p_information_inquiry
  ,p_pcom_init                       =>  p_pcom_init
  ,p_alleg_incident                  =>  p_alleg_incident
  ,p_alleg_discrim_org_id            =>  p_alleg_discrim_org_id
  ,p_rr_ltr_date                     =>  p_rr_ltr_date
  ,p_rr_ltr_recvd                    =>  p_rr_ltr_recvd
  ,p_pre_com_elec                    =>  p_pre_com_elec
  --,p_adr_offered                     =>  p_adr_offered
  ,p_class_agent_flag                =>  p_class_agent_flag
  ,p_pre_com_desc                    =>  p_pre_com_desc
  ,p_counselor_asg                   =>  p_counselor_asg
  ,p_init_counselor_interview        =>  p_init_counselor_interview
  ,p_anonymity_requested             =>  p_anonymity_requested
  ,p_counsel_ext_ltr                 =>  p_counsel_ext_ltr
  ,p_traditional_counsel_outcome     =>  p_traditional_counsel_outcome
  ,p_final_interview                 =>  p_final_interview
  ,p_notice_rtf_recvd                =>  p_notice_rtf_recvd
  ,p_precom_closed                   =>  p_precom_closed
  ,p_precom_closure_nature           =>  p_precom_closure_nature
  ,p_counselor_rpt_sub               =>  p_counselor_rpt_sub
  ,p_hr_office_org_id                =>  p_hr_office_org_id
  ,p_eeo_office_org_id               =>  p_eeo_office_org_id
  ,p_serviced_org_id                 =>  p_serviced_org_id
  ,p_formal_com_filed                =>  p_formal_com_filed
  ,p_ack_ltr                         =>  p_ack_ltr
  ,p_clarification_ltr_date          =>  p_clarification_ltr_date
  ,p_clarification_response_recvd    =>  p_clarification_response_recvd
  ,p_forwarded_legal_review          =>  p_forwarded_legal_review
  ,p_returned_from_legal             =>  p_returned_from_legal
  ,p_letter_type                     =>  p_letter_type
  ,p_letter_date                     =>  p_letter_date
  ,p_letter_recvd                    =>  p_letter_recvd
  ,p_investigation_source            =>  p_investigation_source
  ,p_investigator_recvd_req          =>  p_investigator_recvd_req
  ,p_agency_investigator_req         =>  p_agency_investigator_req
  ,p_investigator_asg                =>  p_investigator_asg
  ,p_investigation_start             =>  p_investigation_start
  ,p_investigation_end               =>  p_investigation_end
  ,p_investigation_extended          =>  p_investigation_extended
  ,p_invest_extension_desc           =>  p_invest_extension_desc
  ,p_agency_recvd_roi                =>  p_agency_recvd_roi
  ,p_comrep_recvd_roi                =>  p_comrep_recvd_roi
  ,p_options_ltr_date                =>  p_options_ltr_date
  ,p_comrep_recvd_opt_ltr            =>  p_comrep_recvd_opt_ltr
  ,p_comrep_opt_ltr_response         =>  p_comrep_opt_ltr_response
  ,p_resolution_offer                =>  p_resolution_offer
  ,p_comrep_resol_offer_recvd        =>  p_comrep_resol_offer_recvd
  ,p_comrep_resol_offer_response     =>  p_comrep_resol_offer_response
  ,p_comrep_resol_offer_desc         =>  p_comrep_resol_offer_desc
  ,p_resol_offer_signed              =>  p_resol_offer_signed
  ,p_resol_offer_desc                =>  p_resol_offer_desc
  ,p_hearing_source                  =>  p_hearing_source
  ,p_agency_notified_hearing         =>  p_agency_notified_hearing
  ,p_eeoc_hearing_docket_num         =>  p_eeoc_hearing_docket_num
  ,p_hearing_complete                =>  p_hearing_complete
  ,p_aj_merit_decision_date          =>  p_aj_merit_decision_date
  ,p_agency_recvd_aj_merit_dec       =>  p_agency_recvd_aj_merit_dec
  ,p_aj_merit_decision               =>  p_aj_merit_decision
  ,p_aj_ca_decision_date             =>  p_aj_ca_decision_date
  ,p_agency_recvd_aj_ca_dec          =>  p_agency_recvd_aj_ca_dec
  ,p_aj_ca_decision                  =>  p_aj_ca_decision
  ,p_fad_requested                   =>  p_fad_requested
  ,p_merit_fad                       =>  p_merit_fad
  ,p_attorney_fees_fad               =>  p_attorney_fees_fad
  ,p_comp_damages_fad                =>  p_comp_damages_fad
  ,p_non_compliance_fad              =>  p_non_compliance_fad
  ,p_fad_req_recvd_eeo_office        =>  p_fad_req_recvd_eeo_office
  ,p_fad_req_forwd_to_agency         =>  p_fad_req_forwd_to_agency
  ,p_agency_recvd_request            =>  p_agency_recvd_request
  ,p_fad_due                         =>  p_fad_due
  ,p_fad_date                        =>  p_fad_date
  ,p_fad_decision                    =>  p_fad_decision
  --,p_fad_final_action_closure        =>  p_fad_final_action_closure
  ,p_fad_forwd_to_comrep             =>  p_fad_forwd_to_comrep
  ,p_fad_recvd_by_comrep             =>  p_fad_recvd_by_comrep
  ,p_fad_imp_ltr_forwd_to_org        =>  p_fad_imp_ltr_forwd_to_org
  ,p_fad_decision_forwd_legal        =>  p_fad_decision_forwd_legal
  ,p_fad_decision_recvd_legal        =>  p_fad_decision_recvd_legal
  ,p_fa_source                       =>  p_fa_source
  ,p_final_action_due                =>  p_final_action_due
  --,p_final_action_nature_of_closu    =>  p_final_action_nature_of_closu
  ,p_final_act_forwd_comrep          =>  p_final_act_forwd_comrep
  ,p_final_act_recvd_comrep          =>  p_final_act_recvd_comrep
  ,p_final_action_decision_date      =>  p_final_action_decision_date
  ,p_final_action_decision           =>  p_final_action_decision
  ,p_fa_imp_ltr_forwd_to_org         =>  p_fa_imp_ltr_forwd_to_org
  ,p_fa_decision_forwd_legal         =>  p_fa_decision_forwd_legal
  ,p_fa_decision_recvd_legal         =>  p_fa_decision_recvd_legal
  ,p_civil_action_filed              =>  p_civil_action_filed
  ,p_agency_closure_confirmed        =>  p_agency_closure_confirmed
  ,p_consolidated_complaint_id       =>  p_consolidated_complaint_id
  ,p_consolidated                    =>  p_consolidated
  ,p_stage_of_consolidation          =>  p_stage_of_consolidation
  ,p_comrep_notif_consolidation      =>  p_comrep_notif_consolidation
  ,p_consolidation_desc              =>  p_consolidation_desc
  ,p_complaint_closed                =>  p_complaint_closed
  ,p_nature_of_closure               =>  p_nature_of_closure
  ,p_complaint_closed_desc           =>  p_complaint_closed_desc
  ,p_filed_formal_class              =>  p_filed_formal_class
  ,p_forwd_eeoc                      =>  p_forwd_eeoc
  ,p_aj_cert_decision_date           =>  p_aj_cert_decision_date
  ,p_aj_cert_decision_recvd          =>  p_aj_cert_decision_recvd
  ,p_aj_cert_decision                =>  p_aj_cert_decision
  ,p_class_members_notified          =>  p_class_members_notified
  ,p_number_of_complaintants         =>  p_number_of_complaintants
  ,p_class_hearing                   =>  p_class_hearing
  ,p_aj_dec                          =>  p_aj_dec
  ,p_agency_recvd_aj_dec             =>  p_agency_recvd_aj_dec
  ,p_aj_decision                     =>  p_aj_decision
  ,p_agency_brief_eeoc               =>  p_agency_brief_eeoc
  ,p_agency_notif_of_civil_action    =>  p_agency_notif_of_civil_action
  ,p_fad_source                      =>  p_fad_source
  ,p_agency_files_forwarded_eeoc     =>  p_agency_files_forwarded_eeoc
  ,p_hearing_req                     =>  p_hearing_req
  ,p_agency_code                     =>  p_agency_code
  ,p_audited_by                      =>  p_audited_by
  ,p_record_received                 =>  p_record_received
  ,p_attribute_category              =>  p_attribute_category
  ,p_attribute1                      =>  p_attribute1
  ,p_attribute2                      =>  p_attribute2
  ,p_attribute3                      =>  p_attribute3
  ,p_attribute4                      =>  p_attribute4
  ,p_attribute5                      =>  p_attribute5
  ,p_attribute6                      =>  p_attribute6
  ,p_attribute7                      =>  p_attribute7
  ,p_attribute8                      =>  p_attribute8
  ,p_attribute9                      =>  p_attribute9
  ,p_attribute10                     =>  p_attribute10
  ,p_attribute11                     =>  p_attribute11
  ,p_attribute12                     =>  p_attribute12
  ,p_attribute13                     =>  p_attribute13
  ,p_attribute14                     =>  p_attribute14
  ,p_attribute15                     =>  p_attribute15
  ,p_attribute16                     =>  p_attribute16
  ,p_attribute17                     =>  p_attribute17
  ,p_attribute18                     =>  p_attribute18
  ,p_attribute19                     =>  p_attribute19
  ,p_attribute20                     =>  p_attribute20
  ,p_attribute21                     =>  p_attribute21
  ,p_attribute22                     =>  p_attribute22
  ,p_attribute23                     =>  p_attribute23
  ,p_attribute24                     =>  p_attribute24
  ,p_attribute25                     =>  p_attribute25
  ,p_attribute26                     =>  p_attribute26
  ,p_attribute27                     =>  p_attribute27
  ,p_attribute28                     =>  p_attribute28
  ,p_attribute29                     =>  p_attribute29
  ,p_attribute30                     =>  p_attribute30
  );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    GHR_COMPLAINT_BK_2.update_complaint_a
  (p_effective_date                 => trunc(p_effective_date)
  ,p_business_group_id              => p_business_group_id
  ,p_complaint_id                   => p_complaint_id
  ,p_object_version_number          => p_object_version_number
  ,p_complainant_person_id          => p_complainant_person_id
  ,p_docket_number                  => p_docket_number
  ,p_stage                          => p_stage
  ,p_class_flag                     => p_class_flag
  ,p_mixed_flag                     => p_mixed_flag
  ,p_consolidated_flag              => p_consolidated_flag
  ,p_remand_flag                    => p_remand_flag
  ,p_active_flag                    => p_active_flag
  ,p_information_inquiry            => p_information_inquiry
  ,p_pcom_init                      => p_pcom_init
  ,p_alleg_incident                 => p_alleg_incident
  ,p_alleg_discrim_org_id           => p_alleg_discrim_org_id
  ,p_rr_ltr_date                    => p_rr_ltr_date
  ,p_rr_ltr_recvd                   => p_rr_ltr_recvd
  ,p_pre_com_elec                   => p_pre_com_elec
  --,p_adr_offered                    => p_adr_offered
  ,p_class_agent_flag               => p_class_agent_flag
  ,p_pre_com_desc                   => p_pre_com_desc
  ,p_counselor_asg                  => p_counselor_asg
  ,p_init_counselor_interview       => p_init_counselor_interview
  ,p_anonymity_requested            => p_anonymity_requested
  ,p_counsel_ext_ltr                => p_counsel_ext_ltr
  ,p_traditional_counsel_outcome    => p_traditional_counsel_outcome
  ,p_final_interview                => p_final_interview
  ,p_notice_rtf_recvd               => p_notice_rtf_recvd
  ,p_precom_closed                  => p_precom_closed
  ,p_precom_closure_nature          => p_precom_closure_nature
  ,p_counselor_rpt_sub              => p_counselor_rpt_sub
  ,p_hr_office_org_id               => p_hr_office_org_id
  ,p_eeo_office_org_id              => p_eeo_office_org_id
  ,p_serviced_org_id                => p_serviced_org_id
  ,p_formal_com_filed               => p_formal_com_filed
  ,p_ack_ltr                        => p_ack_ltr
  ,p_clarification_ltr_date         => p_clarification_ltr_date
  ,p_clarification_response_recvd   => p_clarification_response_recvd
  ,p_forwarded_legal_review         => p_forwarded_legal_review
  ,p_returned_from_legal            => p_returned_from_legal
  ,p_letter_type                    => p_letter_type
  ,p_letter_date                    => p_letter_date
  ,p_letter_recvd                   => p_letter_recvd
  ,p_investigation_source           => p_investigation_source
  ,p_investigator_recvd_req         => p_investigator_recvd_req
  ,p_agency_investigator_req        => p_agency_investigator_req
  ,p_investigator_asg               => p_investigator_asg
  ,p_investigation_start            => p_investigation_start
  ,p_investigation_end              => p_investigation_end
  ,p_investigation_extended         => p_investigation_extended
  ,p_invest_extension_desc          => p_invest_extension_desc
  ,p_agency_recvd_roi               => p_agency_recvd_roi
  ,p_comrep_recvd_roi               => p_comrep_recvd_roi
  ,p_options_ltr_date               => p_options_ltr_date
  ,p_comrep_recvd_opt_ltr           => p_comrep_recvd_opt_ltr
  ,p_comrep_opt_ltr_response        => p_comrep_opt_ltr_response
  ,p_resolution_offer               => p_resolution_offer
  ,p_comrep_resol_offer_recvd       => p_comrep_resol_offer_recvd
  ,p_comrep_resol_offer_response    => p_comrep_resol_offer_response
  ,p_comrep_resol_offer_desc        => p_comrep_resol_offer_desc
  ,p_resol_offer_signed             => p_resol_offer_signed
  ,p_resol_offer_desc               => p_resol_offer_desc
  ,p_hearing_source                 => p_hearing_source
  ,p_agency_notified_hearing        => p_agency_notified_hearing
  ,p_eeoc_hearing_docket_num        => p_eeoc_hearing_docket_num
  ,p_hearing_complete               => p_hearing_complete
  ,p_aj_merit_decision_date         => p_aj_merit_decision_date
  ,p_agency_recvd_aj_merit_dec      => p_agency_recvd_aj_merit_dec
  ,p_aj_merit_decision              => p_aj_merit_decision
  ,p_aj_ca_decision_date            => p_aj_ca_decision_date
  ,p_agency_recvd_aj_ca_dec         => p_agency_recvd_aj_ca_dec
  ,p_aj_ca_decision                 => p_aj_ca_decision
  ,p_fad_requested                  => p_fad_requested
  ,p_merit_fad                      => p_merit_fad
  ,p_attorney_fees_fad              => p_attorney_fees_fad
  ,p_comp_damages_fad               => p_comp_damages_fad
  ,p_non_compliance_fad             => p_non_compliance_fad
  ,p_fad_req_recvd_eeo_office       => p_fad_req_recvd_eeo_office
  ,p_fad_req_forwd_to_agency        => p_fad_req_forwd_to_agency
  ,p_agency_recvd_request           => p_agency_recvd_request
  ,p_fad_due                        => p_fad_due
  ,p_fad_date                       => p_fad_date
  ,p_fad_decision                   => p_fad_decision
  --,p_fad_final_action_closure       => p_fad_final_action_closure
  ,p_fad_forwd_to_comrep            => p_fad_forwd_to_comrep
  ,p_fad_recvd_by_comrep            => p_fad_recvd_by_comrep
  ,p_fad_imp_ltr_forwd_to_org       => p_fad_imp_ltr_forwd_to_org
  ,p_fad_decision_forwd_legal       => p_fad_decision_forwd_legal
  ,p_fad_decision_recvd_legal       => p_fad_decision_recvd_legal
  ,p_fa_source                      => p_fa_source
  ,p_final_action_due               => p_final_action_due
  --,p_final_action_nature_of_closu   => p_final_action_nature_of_closu
  ,p_final_act_forwd_comrep         => p_final_act_forwd_comrep
  ,p_final_act_recvd_comrep         => p_final_act_recvd_comrep
  ,p_final_action_decision_date     => p_final_action_decision_date
  ,p_final_action_decision          => p_final_action_decision
  ,p_fa_imp_ltr_forwd_to_org        => p_fa_imp_ltr_forwd_to_org
  ,p_fa_decision_forwd_legal        => p_fa_decision_forwd_legal
  ,p_fa_decision_recvd_legal        => p_fa_decision_recvd_legal
  ,p_civil_action_filed             => p_civil_action_filed
  ,p_agency_closure_confirmed       => p_agency_closure_confirmed
  ,p_consolidated_complaint_id      => p_consolidated_complaint_id
  ,p_consolidated                   => p_consolidated
  ,p_stage_of_consolidation         => p_stage_of_consolidation
  ,p_comrep_notif_consolidation     => p_comrep_notif_consolidation
  ,p_consolidation_desc             => p_consolidation_desc
  ,p_complaint_closed               => p_complaint_closed
  ,p_nature_of_closure              => p_nature_of_closure
  ,p_complaint_closed_desc          => p_complaint_closed_desc
  ,p_filed_formal_class             => p_filed_formal_class
  ,p_forwd_eeoc                     => p_forwd_eeoc
  ,p_aj_cert_decision_date          => p_aj_cert_decision_date
  ,p_aj_cert_decision_recvd         => p_aj_cert_decision_recvd
  ,p_aj_cert_decision               => p_aj_cert_decision
  ,p_class_members_notified         => p_class_members_notified
  ,p_number_of_complaintants        => p_number_of_complaintants
  ,p_class_hearing                  => p_class_hearing
  ,p_aj_dec                         => p_aj_dec
  ,p_agency_recvd_aj_dec            => p_agency_recvd_aj_dec
  ,p_aj_decision                    => p_aj_decision
  ,p_agency_brief_eeoc              => p_agency_brief_eeoc
  ,p_agency_notif_of_civil_action   => p_agency_notif_of_civil_action
  ,p_fad_source                     => p_fad_source
  ,p_agency_files_forwarded_eeoc    => p_agency_files_forwarded_eeoc
  ,p_hearing_req                    => p_hearing_req
  ,p_agency_code                    => p_agency_code
  ,p_audited_by                     => p_audited_by
  ,p_record_received                => p_record_received
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  ,p_attribute21                    => p_attribute21
  ,p_attribute22                    => p_attribute22
  ,p_attribute23                    => p_attribute23
  ,p_attribute24                    => p_attribute24
  ,p_attribute25                    => p_attribute25
  ,p_attribute26                    => p_attribute26
  ,p_attribute27                    => p_attribute27
  ,p_attribute28                    => p_attribute28
  ,p_attribute29                    => p_attribute29
  ,p_attribute30                    => p_attribute30
    );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'Update_Complaint'
          ,p_hook_type   => 'AP'
          );
    end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_complaint;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    l_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_complaint;
    --RESET In/Out Params and SET Out Params
    l_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_complaint;

end ghr_complaint_api;

/
