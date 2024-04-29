--------------------------------------------------------
--  DDL for Package GHR_CMP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CMP_RKD" AUTHID CURRENT_USER as
/* $Header: ghcmprhi.pkh 120.0 2005/05/29 02:54:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_complaint_id                 in number
  ,p_complainant_person_id_o      in number
  ,p_business_group_id_o          in number
  ,p_docket_number_o              in varchar2
  ,p_stage_o                      in varchar2
  ,p_class_flag_o                 in varchar2
  ,p_mixed_flag_o                 in varchar2
  ,p_consolidated_flag_o          in varchar2
  ,p_remand_flag_o                in varchar2
  ,p_active_flag_o                in varchar2
  ,p_information_inquiry_o        in date
  ,p_pcom_init_o                  in date
  ,p_alleg_incident_o             in date
  ,p_alleg_discrim_org_id_o       in number
  ,p_rr_ltr_date_o                in date
  ,p_rr_ltr_recvd_o               in date
  ,p_pre_com_elec_o               in varchar2
  --,p_adr_offered_o              in varchar2
  ,p_class_agent_flag_o           in varchar2
  ,p_pre_com_desc_o               in varchar2
  ,p_counselor_asg_o              in date
  ,p_init_counselor_interview_o   in date
  ,p_anonymity_requested_o        in varchar2
  ,p_counsel_ext_ltr_o            in date
  ,p_traditional_counsel_outcom_o in varchar2
  ,p_final_interview_o            in date
  ,p_notice_rtf_recvd_o           in date
  ,p_precom_closed_o              in date
  ,p_precom_closure_nature_o      in varchar2
  ,p_counselor_rpt_sub_o          in date
  ,p_hr_office_org_id_o           in number
  ,p_eeo_office_org_id_o          in number
  ,p_serviced_org_id_o            in number
  ,p_formal_com_filed_o           in date
  ,p_ack_ltr_o                    in date
  ,p_clarification_ltr_date_o     in date
  ,p_clarification_response_rec_o in date
  ,p_forwarded_legal_review_o     in date
  ,p_returned_from_legal_o        in date
  ,p_letter_type_o                in varchar2
  ,p_letter_date_o                in date
  ,p_letter_recvd_o               in date
  ,p_investigation_source_o       in varchar2
  ,p_investigator_recvd_req_o     in date
  ,p_agency_investigator_req_o    in date
  ,p_investigator_asg_o           in date
  ,p_investigation_start_o        in date
  ,p_investigation_end_o          in date
  ,p_investigation_extended_o     in date
  ,p_invest_extension_desc_o      in varchar2
  ,p_agency_recvd_roi_o           in date
  ,p_comrep_recvd_roi_o           in date
  ,p_options_ltr_date_o           in date
  ,p_comrep_recvd_opt_ltr_o       in date
  ,p_comrep_opt_ltr_response_o    in varchar2
  ,p_resolution_offer_o           in date
  ,p_comrep_resol_offer_recvd_o   in date
  ,p_comrep_resol_offer_respons_o in date
  ,p_comrep_resol_offer_desc_o    in varchar2
  ,p_resol_offer_signed_o         in date
  ,p_resol_offer_desc_o           in varchar2
  ,p_hearing_source_o             in varchar2
  ,p_agency_notified_hearing_o    in date
  ,p_eeoc_hearing_docket_num_o    in varchar2
  ,p_hearing_complete_o           in date
  ,p_aj_merit_decision_date_o     in date
  ,p_agency_recvd_aj_merit_dec_o  in date
  ,p_aj_merit_decision_o          in varchar2
  ,p_aj_ca_decision_date_o        in date
  ,p_agency_recvd_aj_ca_dec_o     in date
  ,p_aj_ca_decision_o             in varchar2
  ,p_fad_requested_o              in date
  ,p_merit_fad_o                  in varchar2
  ,p_attorney_fees_fad_o          in varchar2
  ,p_comp_damages_fad_o           in varchar2
  ,p_non_compliance_fad_o         in varchar2
  ,p_fad_req_recvd_eeo_office_o   in date
  ,p_fad_req_forwd_to_agency_o    in date
  ,p_agency_recvd_request_o       in date
  ,p_fad_due_o                    in date
  ,p_fad_date_o                   in date
  ,p_fad_decision_o               in varchar2
  --,p_fad_final_action_closure_o   in varchar2
  ,p_fad_forwd_to_comrep_o        in date
  ,p_fad_recvd_by_comrep_o        in date
  ,p_fad_imp_ltr_forwd_to_org_o   in date
  ,p_fad_decision_forwd_legal_o   in date
  ,p_fad_decision_recvd_legal_o   in date
  ,p_fa_source_o                  in varchar2
  ,p_final_action_due_o           in date
  --,p_final_action_nature_of_clo_o  in varchar2
  ,p_final_act_forwd_comrep_o     in date
  ,p_final_act_recvd_comrep_o     in date
  ,p_final_action_decision_date_o in date
  ,p_final_action_decision_o      in varchar2
  ,p_fa_imp_ltr_forwd_to_org_o    in date
  ,p_fa_decision_forwd_legal_o    in date
  ,p_fa_decision_recvd_legal_o    in date
  ,p_civil_action_filed_o         in date
  ,p_agency_closure_confirmed_o   in date
  ,p_consolidated_complaint_id_o  in number
  ,p_consolidated_o               in date
  ,p_stage_of_consolidation_o     in varchar2
  ,p_comrep_notif_consolidation_o in date
  ,p_consolidation_desc_o         in varchar2
  ,p_complaint_closed_o           in date
  ,p_nature_of_closure_o          in varchar2
  ,p_complaint_closed_desc_o      in varchar2
  ,p_filed_formal_class_o         in date
  ,p_forwd_eeoc_o                 in date
  ,p_aj_cert_decision_date_o      in date
  ,p_aj_cert_decision_recvd_o     in date
  ,p_aj_cert_decision_o           in varchar2
  ,p_class_members_notified_o     in date
  ,p_number_of_complaintants_o    in number
  ,p_class_hearing_o              in date
  ,p_aj_dec_o                     in date
  ,p_agency_recvd_aj_dec_o        in date
  ,p_aj_decision_o                in varchar2
  ,p_object_version_number_o      in number
  ,p_agency_brief_eeoc_o          in date
  ,p_agency_notif_of_civil_acti_o in date
  ,p_fad_source_o                 in varchar2
  ,p_agency_files_forwarded_eeo_o in date
  ,p_hearing_req_o                in date
  ,p_agency_code_o                in varchar2
  ,p_audited_by_o                 in varchar2
  ,p_record_received_o            in date
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  );
--
end ghr_cmp_rkd;

 

/
