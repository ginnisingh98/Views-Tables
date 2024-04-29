--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_API" AUTHID CURRENT_USER as
/* $Header: ghcmpapi.pkh 120.2 2006/01/11 10:26:12 jmhyer noship $ */
/*#
 * This package contains the procedures for creating and updating GHR
 * Complaints Tracking Complaint records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Complaint
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_complaint >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Complaints Tracking Complaint record.
 *
 * This API creates a Complaint record for a person or class action in table
 * ghr_complaints2.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group and persons must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The API creates a Complaint record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Complaint record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_complainant_person_id Uniquely identifies the Complainant Person.
 * @param p_business_group_id Uniquely identifies the Business Group.
 * @param p_docket_number {@rep:casecolumn GHR_COMPLAINTS2.DOCKET_NUMBER}
 * @param p_stage Complaint Stage. Valid values are defined by
 * 'GHR_US_HEADER_STAGE' lookup type.
 * @param p_class_flag {@rep:casecolumn GHR_COMPLAINTS2.CLASS_FLAG}
 * @param p_mixed_flag {@rep:casecolumn GHR_COMPLAINTS2.MIXED_FLAG}
 * @param p_consolidated_flag {@rep:casecolumn
 * GHR_COMPLAINTS2.CONSOLIDATED_FLAG}
 * @param p_remand_flag {@rep:casecolumn GHR_COMPLAINTS2.REMAND_FLAG}
 * @param p_active_flag {@rep:casecolumn GHR_COMPLAINTS2.ACTIVE_FLAG}
 * @param p_information_inquiry {@rep:casecolumn
 * GHR_COMPLAINTS2.INFORMATION_INQUIRY}
 * @param p_pcom_init {@rep:casecolumn GHR_COMPLAINTS2.PCOM_INIT}
 * @param p_alleg_incident {@rep:casecolumn GHR_COMPLAINTS2.ALLEG_INCIDENT}
 * @param p_rr_ltr_date {@rep:casecolumn GHR_COMPLAINTS2.RR_LTR_DATE}
 * @param p_rr_ltr_recvd {@rep:casecolumn GHR_COMPLAINTS2.RR_LTR_RECVD}
 * @param p_pre_com_elec Complaint Pre-Complaint Election. Valid values are
 * defined by 'GHR_US_PRE_COMP_ELECTION' lookup type.
 * @param p_class_agent_flag {@rep:casecolumn GHR_COMPLAINTS2.CLASS_AGENT_FLAG}
 * @param p_pre_com_desc {@rep:casecolumn GHR_COMPLAINTS2.PRE_COM_DESC}
 * @param p_counselor_asg {@rep:casecolumn GHR_COMPLAINTS2.COUNSELOR_ASG}
 * @param p_init_counselor_interview {@rep:casecolumn
 * GHR_COMPLAINTS2.INIT_COUNSELOR_INTERVIEW}
 * @param p_anonymity_requested {@rep:casecolumn
 * GHR_COMPLAINTS2.ANONYMITY_REQUESTED}
 * @param p_counsel_ext_ltr {@rep:casecolumn GHR_COMPLAINTS2.COUNSEL_EXT_LTR}
 * @param p_traditional_counsel_outcome Complaint Traditional Counseling
 * Outcome. Valid values are defined by 'GHR_US_COUNSEL_OUTCOME' lookup type.
 * @param p_final_interview {@rep:casecolumn GHR_COMPLAINTS2.FINAL_INTERVIEW}
 * @param p_notice_rtf_recvd {@rep:casecolumn GHR_COMPLAINTS2.NOTICE_RTF_RECVD}
 * @param p_precom_closed {@rep:casecolumn GHR_COMPLAINTS2.PRECOM_CLOSED}
 * @param p_precom_closure_nature Complaint Pre-Complaint Nature of Closure.
 * Valid values are defined by 'GHR_US_NATURE_OF_CLOSURE' lookup type.
 * @param p_counselor_rpt_sub {@rep:casecolumn
 * GHR_COMPLAINTS2.COUNSELOR_RPT_SUB}
 * @param p_formal_com_filed {@rep:casecolumn GHR_COMPLAINTS2.FORMAL_COM_FILED}
 * @param p_ack_ltr {@rep:casecolumn GHR_COMPLAINTS2.ACK_LTR}
 * @param p_clarification_ltr_date {@rep:casecolumn
 * GHR_COMPLAINTS2.CLARIFICATION_LTR_DATE}
 * @param p_clarification_response_recvd {@rep:casecolumn
 * GHR_COMPLAINTS2.CLARIFICATION_RESPONSE_RECVD}
 * @param p_forwarded_legal_review {@rep:casecolumn
 * GHR_COMPLAINTS2.FORWARDED_LEGAL_REVIEW}
 * @param p_returned_from_legal {@rep:casecolumn
 * GHR_COMPLAINTS2.RETURNED_FROM_LEGAL}
 * @param p_letter_type Complaint Letter Type. Valid values are defined by
 * 'GHR_US_LETTER_TYPE' lookup type.
 * @param p_letter_date {@rep:casecolumn GHR_COMPLAINTS2.LETTER_DATE}
 * @param p_letter_recvd {@rep:casecolumn GHR_COMPLAINTS2.LETTER_RECVD}
 * @param p_investigation_source Complaint Investigation Source. Valid values
 * are defined by 'GHR_US_COMPLAINT_SOURCE' lookup type.
 * @param p_investigator_recvd_req {@rep:casecolumn
 * GHR_COMPLAINTS2.INVESTIGATOR_RECVD_REQ}
 * @param p_agency_investigator_req {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_INVESTIGATOR_REQ}
 * @param p_investigator_asg {@rep:casecolumn GHR_COMPLAINTS2.INVESTIGATOR_ASG}
 * @param p_investigation_start {@rep:casecolumn
 * GHR_COMPLAINTS2.INVESTIGATION_START}
 * @param p_investigation_end {@rep:casecolumn
 * GHR_COMPLAINTS2.INVESTIGATION_END}
 * @param p_investigation_extended {@rep:casecolumn
 * GHR_COMPLAINTS2.INVESTIGATION_EXTENDED}
 * @param p_invest_extension_desc Complaint Investigation Extension
 * Description. Valid values are defined by 'GHR_US_EXTENSION_DESC' lookup
 * type.
 * @param p_agency_recvd_roi {@rep:casecolumn GHR_COMPLAINTS2.AGENCY_RECVD_ROI}
 * @param p_comrep_recvd_roi {@rep:casecolumn GHR_COMPLAINTS2.COMREP_RECVD_ROI}
 * @param p_options_ltr_date {@rep:casecolumn GHR_COMPLAINTS2.OPTIONS_LTR_DATE}
 * @param p_comrep_recvd_opt_ltr {@rep:casecolumn
 * GHR_COMPLAINTS2.COMREP_RECVD_OPT_LTR}
 * @param p_comrep_opt_ltr_response Complaint Complainant Representative
 * Options Letter Response. Valid values are defined by
 * 'GHR_US_OPTIONS_RESPONSE' lookup type.
 * @param p_resolution_offer {@rep:casecolumn GHR_COMPLAINTS2.RESOLUTION_OFFER}
 * @param p_comrep_resol_offer_recvd {@rep:casecolumn
 * GHR_COMPLAINTS2.COMREP_RESOL_OFFER_RECVD}
 * @param p_comrep_resol_offer_response {@rep:casecolumn
 * GHR_COMPLAINTS2.COMREP_RESOL_OFFER_RESPONSE}
 * @param p_comrep_resol_offer_desc Complaint Complainant Representative
 * Resolution Offer Description. Valid values are defined by
 * 'GHR_US_RESOLUTION_RESP' lookup type.
 * @param p_resol_offer_signed {@rep:casecolumn
 * GHR_COMPLAINTS2.RESOL_OFFER_SIGNED}
 * @param p_resol_offer_desc {@rep:casecolumn GHR_COMPLAINTS2.RESOL_OFFER_DESC}
 * @param p_hearing_source Complaint Hearing Source. Valid values are defined
 * by 'GHR_US_COMPLAINT_SOURCE' lookup type.
 * @param p_agency_notified_hearing {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_NOTIFIED_HEARING}
 * @param p_eeoc_hearing_docket_num {@rep:casecolumn
 * GHR_COMPLAINTS2.EEOC_HEARING_DOCKET_NUM}
 * @param p_hearing_complete {@rep:casecolumn GHR_COMPLAINTS2.HEARING_COMPLETE}
 * @param p_aj_merit_decision_date {@rep:casecolumn
 * GHR_COMPLAINTS2.AJ_MERIT_DECISION_DATE}
 * @param p_agency_recvd_aj_merit_dec {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_RECVD_AJ_MERIT_DEC}
 * @param p_aj_merit_decision Complaint Administrative Judge (AJ) Merit
 * Decision. Valid values are defined by 'GHR_US_MERIT_DECISION' lookup type.
 * @param p_aj_ca_decision_date {@rep:casecolumn
 * GHR_COMPLAINTS2.AJ_CA_DECISION_DATE}
 * @param p_agency_recvd_aj_ca_dec {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_RECVD_AJ_CA_DEC}
 * @param p_aj_ca_decision Complaint Administrative Judge (AJ) Corrective
 * Action Decision. Valid values are defined by 'GHR_US_AJ_CERT_DECISION'
 * lookup type.
 * @param p_fad_requested {@rep:casecolumn GHR_COMPLAINTS2.FAD_REQUESTED}
 * @param p_merit_fad {@rep:casecolumn GHR_COMPLAINTS2.MERIT_FAD}
 * @param p_attorney_fees_fad {@rep:casecolumn
 * GHR_COMPLAINTS2.ATTORNEY_FEES_FAD}
 * @param p_comp_damages_fad {@rep:casecolumn GHR_COMPLAINTS2.COMP_DAMAGES_FAD}
 * @param p_non_compliance_fad {@rep:casecolumn
 * GHR_COMPLAINTS2.NON_COMPLIANCE_FAD}
 * @param p_fad_req_recvd_eeo_office {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_REQ_RECVD_EEO_OFFICE}
 * @param p_fad_req_forwd_to_agency {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_REQ_FORWD_TO_AGENCY}
 * @param p_agency_recvd_request {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_RECVD_REQUEST}
 * @param p_fad_due {@rep:casecolumn GHR_COMPLAINTS2.FAD_DUE}
 * @param p_fad_date {@rep:casecolumn GHR_COMPLAINTS2.FAD_DECISION}
 * @param p_fad_decision Complaint Final Agency Decision (FAD). Valid values
 * are defined by 'GHR_US_FAD_DECISION' lookup type.
 * @param p_fad_forwd_to_comrep {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_FORWD_TO_COMREP}
 * @param p_fad_recvd_by_comrep {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_RECVD_BY_COMREP}
 * @param p_fad_imp_ltr_forwd_to_org {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_IMP_LTR_FORWD_TO_ORG}
 * @param p_fad_decision_forwd_legal {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_DECISION_FORWD_LEGAL}
 * @param p_fad_decision_recvd_legal {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_DECISION_RECVD_LEGAL}
 * @param p_fa_source Complaint Final Action Source. Valid values are defined
 * by 'GHR_US_COMPLAINT_SOURCE' lookup type.
 * @param p_final_action_due {@rep:casecolumn GHR_COMPLAINTS2.FINAL_ACTION_DUE}
 * @param p_final_act_forwd_comrep {@rep:casecolumn
 * GHR_COMPLAINTS2.FINAL_ACT_FORWD_COMREP}
 * @param p_final_act_recvd_comrep {@rep:casecolumn
 * GHR_COMPLAINTS2.FINAL_ACT_RECVD_COMREP}
 * @param p_final_action_decision_date {@rep:casecolumn
 * GHR_COMPLAINTS2.FINAL_ACTION_DECISION_DATE}
 * @param p_final_action_decision Complaint Final Action Decision (FAD). Valid
 * values are defined by 'GHR_US_FAA_DECISION' lookup type.
 * @param p_fa_imp_ltr_forwd_to_org {@rep:casecolumn
 * GHR_COMPLAINTS2.FA_IMP_LTR_FORWD_TO_ORG}
 * @param p_fa_decision_forwd_legal {@rep:casecolumn
 * GHR_COMPLAINTS2.FA_DECISION_FORWD_LEGAL}
 * @param p_fa_decision_recvd_legal {@rep:casecolumn
 * GHR_COMPLAINTS2.FA_DECISION_RECVD_LEGAL}
 * @param p_civil_action_filed {@rep:casecolumn
 * GHR_COMPLAINTS2.CIVIL_ACTION_FILED}
 * @param p_agency_closure_confirmed {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_CLOSURE_CONFIRMED}
 * @param p_consolidated_complaint_id {@rep:casecolumn
 * GHR_COMPLAINTS2.CONSOLIDATED_COMPLAINT_ID}
 * @param p_consolidated {@rep:casecolumn GHR_COMPLAINTS2.CONSOLIDATED}
 * @param p_stage_of_consolidation Complaint Stage of Consolidation. Valid
 * values are defined by 'GHR_US_COMP_CONSOLIDATE_STAGE' lookup type.
 * @param p_comrep_notif_consolidation {@rep:casecolumn
 * GHR_COMPLAINTS2.COMREP_NOTIF_CONSOLIDATION}
 * @param p_consolidation_desc {@rep:casecolumn
 * GHR_COMPLAINTS2.CONSOLIDATION_DESC}
 * @param p_complaint_closed {@rep:casecolumn GHR_COMPLAINTS2.COMPLAINT_CLOSED}
 * @param p_nature_of_closure Complaint Nature of Closure. Valid values are
 * defined by 'GHR_US_NATURE_OF_CLOSURE_2' lookup type.
 * @param p_complaint_closed_desc {@rep:casecolumn
 * GHR_COMPLAINTS2.COMPLAINT_CLOSED_DESC}
 * @param p_filed_formal_class {@rep:casecolumn
 * GHR_COMPLAINTS2.FILED_FORMAL_CLASS}
 * @param p_forwd_eeoc {@rep:casecolumn GHR_COMPLAINTS2.FORWD_EEOC}
 * @param p_aj_cert_decision_date {@rep:casecolumn
 * GHR_COMPLAINTS2.AJ_CERT_DECISION_DATE}
 * @param p_aj_cert_decision_recvd {@rep:casecolumn
 * GHR_COMPLAINTS2.AJ_CERT_DECISION_RECVD}
 * @param p_aj_cert_decision Complaint Administrative Judge (AJ) Certified
 * Decision. Valid values are defined by 'GHR_US_AJ_CERT_DECISION' lookup type.
 * @param p_class_members_notified {@rep:casecolumn
 * GHR_COMPLAINTS2.CLASS_MEMBERS_NOTIFIED}
 * @param p_number_of_complaintants {@rep:casecolumn
 * GHR_COMPLAINTS2.NUMBER_OF_COMPLAINTANTS}
 * @param p_class_hearing {@rep:casecolumn GHR_COMPLAINTS2.CLASS_HEARING}
 * @param p_aj_dec {@rep:casecolumn GHR_COMPLAINTS2.AJ_DEC}
 * @param p_agency_recvd_aj_dec {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_RECVD_AJ_DEC}
 * @param p_aj_decision Complaint Administrative Judge (AJ) Decision. Valid
 * values are defined by 'GHR_US_AJ_REC_DECISION' lookup type.
 * @param p_agency_brief_eeoc {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_BRIEF_EEOC}
 * @param p_agency_notif_of_civil_action {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_NOTIF_OF_CIVIL_ACTION}
 * @param p_fad_source Complaint Final Agency Decision (FAD) Source. Valid
 * values are defined by 'GHR_US_COMPLAINT_SOURCE' lookup type.
 * @param p_agency_files_forwarded_eeoc {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_FILES_FORWARDED_EEOC}
 * @param p_hearing_req {@rep:casecolumn GHR_COMPLAINTS2.HEARING_REQ}
 * @param p_agency_code Complaint Two Character Agency Code. Valid values are
 * defined by 'GHR_US_AGENCY_CODE_2' lookup type.
 * @param p_complaint_id If p_validate is false, then this uniquely identifies
 * the Complaint created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Complaint. If p_validate is true, then the
 * value will be null.
 * @param p_audited_by {@rep:casecolumn GHR_COMPLAINTS2.AUDITED_BY}
 * @param p_eeo_office_org_id {@rep:casecolumn
 * GHR_COMPLAINTS2.EEO_OFFICE_ORG_ID}
 * @param p_hr_office_org_id {@rep:casecolumn
 * GHR_COMPLAINTS2.HR_OFFICE_ORG_ID}
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_serviced_org_id {@rep:casecolumn
 * GHR_COMPLAINTS2.SERVICED_ORG_ID}
 * @param p_alleg_discrim_org_id {@rep:casecolumn
 * GHR_COMPLAINTS2.ALLEG_DISCRIM_ORG_ID}
 * @param p_record_received {@rep:casecolumn
 * GHR_COMPLAINTS2.RECORD_RECEIVED}
 * @rep:displayname Create Complaint
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_complaint
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_complainant_person_id          in     number   default null
  ,p_business_group_id              in     number   default null
  ,p_docket_number                  in     varchar2 default null
  ,p_stage                          in     varchar2 default null
  ,p_class_flag                     in     varchar2 default null
  ,p_mixed_flag                     in     varchar2 default null
  ,p_consolidated_flag              in     varchar2 default null
  ,p_remand_flag                    in     varchar2 default null
  ,p_active_flag                    in     varchar2 default null
  ,p_information_inquiry            in     date     default null
  ,p_pcom_init                      in     date     default null
  ,p_alleg_incident                 in     date     default null
  ,p_alleg_discrim_org_id           in     number   default null
  ,p_rr_ltr_date                    in     date     default null
  ,p_rr_ltr_recvd                   in     date     default null
  ,p_pre_com_elec                   in     varchar2 default null
  --,p_adr_offered                    in     varchar2 default null
  ,p_class_agent_flag               in     varchar2 default null
  ,p_pre_com_desc                   in     varchar2 default null
  ,p_counselor_asg                  in     date     default null
  ,p_init_counselor_interview       in     date     default null
  ,p_anonymity_requested            in     varchar2 default null
  ,p_counsel_ext_ltr                in     date     default null
  ,p_traditional_counsel_outcome    in     varchar2 default null
  ,p_final_interview                in     date     default null
  ,p_notice_rtf_recvd               in     date     default null
  ,p_precom_closed                  in     date     default null
  ,p_precom_closure_nature          in     varchar2 default null
  ,p_counselor_rpt_sub              in     date     default null
  ,p_hr_office_org_id               in     number   default null
  ,p_eeo_office_org_id              in     number   default null
  ,p_serviced_org_id                in     number   default null
  ,p_formal_com_filed               in     date     default null
  ,p_ack_ltr                        in     date     default null
  ,p_clarification_ltr_date         in     date     default null
  ,p_clarification_response_recvd   in     date     default null
  ,p_forwarded_legal_review         in     date     default null
  ,p_returned_from_legal            in     date     default null
  ,p_letter_type                    in     varchar2 default null
  ,p_letter_date                    in     date     default null
  ,p_letter_recvd                   in     date     default null
  ,p_investigation_source           in     varchar2 default null
  ,p_investigator_recvd_req         in     date     default null
  ,p_agency_investigator_req        in     date     default null
  ,p_investigator_asg               in     date     default null
  ,p_investigation_start            in     date     default null
  ,p_investigation_end              in     date     default null
  ,p_investigation_extended         in     date     default null
  ,p_invest_extension_desc          in     varchar2 default null
  ,p_agency_recvd_roi               in     date     default null
  ,p_comrep_recvd_roi               in     date     default null
  ,p_options_ltr_date               in     date     default null
  ,p_comrep_recvd_opt_ltr           in     date     default null
  ,p_comrep_opt_ltr_response        in     varchar2 default null
  ,p_resolution_offer               in     date     default null
  ,p_comrep_resol_offer_recvd       in     date     default null
  ,p_comrep_resol_offer_response    in     date     default null
  ,p_comrep_resol_offer_desc        in     varchar2 default null
  ,p_resol_offer_signed             in     date     default null
  ,p_resol_offer_desc               in     varchar2 default null
  ,p_hearing_source                 in     varchar2 default null
  ,p_agency_notified_hearing        in     date     default null
  ,p_eeoc_hearing_docket_num        in     varchar2 default null
  ,p_hearing_complete               in     date     default null
  ,p_aj_merit_decision_date         in     date     default null
  ,p_agency_recvd_aj_merit_dec      in     date     default null
  ,p_aj_merit_decision              in     varchar2 default null
  ,p_aj_ca_decision_date            in     date     default null
  ,p_agency_recvd_aj_ca_dec         in     date     default null
  ,p_aj_ca_decision                 in     varchar2 default null
  ,p_fad_requested                  in     date     default null
  ,p_merit_fad                      in     varchar2 default null
  ,p_attorney_fees_fad              in     varchar2 default null
  ,p_comp_damages_fad               in     varchar2 default null
  ,p_non_compliance_fad             in     varchar2 default null
  ,p_fad_req_recvd_eeo_office       in     date     default null
  ,p_fad_req_forwd_to_agency        in     date     default null
  ,p_agency_recvd_request           in     date     default null
  ,p_fad_due                        in     date     default null
  ,p_fad_date                       in     date     default null
  ,p_fad_decision                   in     varchar2 default null
  --,p_fad_final_action_closure       in     varchar2 default null
  ,p_fad_forwd_to_comrep            in     date     default null
  ,p_fad_recvd_by_comrep            in     date     default null
  ,p_fad_imp_ltr_forwd_to_org       in     date     default null
  ,p_fad_decision_forwd_legal       in     date     default null
  ,p_fad_decision_recvd_legal       in     date     default null
  ,p_fa_source                      in     varchar2 default null
  ,p_final_action_due               in     date     default null
  --,p_final_action_nature_of_closu   in     varchar2 default null
  ,p_final_act_forwd_comrep         in     date     default null
  ,p_final_act_recvd_comrep         in     date     default null
  ,p_final_action_decision_date     in     date     default null
  ,p_final_action_decision          in    varchar2  default null
  ,p_fa_imp_ltr_forwd_to_org        in     date     default null
  ,p_fa_decision_forwd_legal        in     date     default null
  ,p_fa_decision_recvd_legal        in     date     default null
  ,p_civil_action_filed             in     date     default null
  ,p_agency_closure_confirmed       in     date     default null
  ,p_consolidated_complaint_id      in     number   default null
  ,p_consolidated                   in     date     default null
  ,p_stage_of_consolidation         in     varchar2 default null
  ,p_comrep_notif_consolidation     in     date     default null
  ,p_consolidation_desc             in     varchar2 default null
  ,p_complaint_closed               in     date     default null
  ,p_nature_of_closure              in     varchar2 default null
  ,p_complaint_closed_desc          in     varchar2 default null
  ,p_filed_formal_class             in     date     default null
  ,p_forwd_eeoc                     in     date     default null
  ,p_aj_cert_decision_date          in     date     default null
  ,p_aj_cert_decision_recvd         in     date     default null
  ,p_aj_cert_decision               in     varchar2 default null
  ,p_class_members_notified         in     date     default null
  ,p_number_of_complaintants        in     number   default null
  ,p_class_hearing                  in     date     default null
  ,p_aj_dec                         in     date     default null
  ,p_agency_recvd_aj_dec            in     date     default null
  ,p_aj_decision                    in     varchar2 default null
  ,p_agency_brief_eeoc              in     date     default null
  ,p_agency_notif_of_civil_action   in     date     default null
  ,p_fad_source                     in     varchar2 default null
  ,p_agency_files_forwarded_eeoc    in     date     default null
  ,p_hearing_req                    in     date     default null
  ,p_agency_code                    in     varchar2 default null
  ,p_audited_by                     in     varchar2 default null
  ,p_record_received                in     date     default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_complaint_id                      out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_complaint >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Complaints Tracking Complaint record.
 *
 * This API updates a Complaint record for a person or class action in table
 * ghr_complaints2.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group and persons must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Complaint record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Complaint record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_complaint_id Uniquely identifies the Complaint record to be
 * updated.
 * @param p_object_version_number Pass in the current version number of the
 * Complaint to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated Complaint. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_complainant_person_id Uniquely identifies the Complaint Person to
 * be updated.
 * @param p_business_group_id Uniquely identifies the Business Group.
 * @param p_docket_number {@rep:casecolumn GHR_COMPLAINTS2.DOCKET_NUMBER}
 * @param p_stage Complaint Stage. Valid values are defined by
 * 'GHR_US_HEADER_STAGE' lookup type.
 * @param p_class_flag {@rep:casecolumn GHR_COMPLAINTS2.CLASS_FLAG}
 * @param p_mixed_flag {@rep:casecolumn GHR_COMPLAINTS2.MIXED_FLAG}
 * @param p_consolidated_flag {@rep:casecolumn
 * GHR_COMPLAINTS2.CONSOLIDATED_FLAG}
 * @param p_remand_flag {@rep:casecolumn GHR_COMPLAINTS2.REMAND_FLAG}
 * @param p_active_flag {@rep:casecolumn GHR_COMPLAINTS2.ACTIVE_FLAG}
 * @param p_information_inquiry {@rep:casecolumn
 * GHR_COMPLAINTS2.INFORMATION_INQUIRY}
 * @param p_pcom_init {@rep:casecolumn GHR_COMPLAINTS2.PCOM_INIT}
 * @param p_alleg_incident {@rep:casecolumn GHR_COMPLAINTS2.ALLEG_INCIDENT}
 * @param p_rr_ltr_date {@rep:casecolumn GHR_COMPLAINTS2.RR_LTR_DATE}
 * @param p_rr_ltr_recvd {@rep:casecolumn GHR_COMPLAINTS2.RR_LTR_RECVD}
 * @param p_pre_com_elec Complaint Pre-Complaint Election. Valid values are
 * defined by 'GHR_US_PRE_COMP_ELECTION' lookup type.
 * @param p_class_agent_flag {@rep:casecolumn GHR_COMPLAINTS2.CLASS_AGENT_FLAG}
 * @param p_pre_com_desc {@rep:casecolumn GHR_COMPLAINTS2.PRE_COM_DESC}
 * @param p_counselor_asg {@rep:casecolumn GHR_COMPLAINTS2.COUNSELOR_ASG}
 * @param p_init_counselor_interview {@rep:casecolumn
 * GHR_COMPLAINTS2.INIT_COUNSELOR_INTERVIEW}
 * @param p_anonymity_requested {@rep:casecolumn
 * GHR_COMPLAINTS2.ANONYMITY_REQUESTED}
 * @param p_counsel_ext_ltr {@rep:casecolumn GHR_COMPLAINTS2.COUNSEL_EXT_LTR}
 * @param p_traditional_counsel_outcome Complaint Traditional Counseling
 * Outcome. Valid values are defined by 'GHR_US_COUNSEL_OUTCOME' lookup type.
 * @param p_final_interview {@rep:casecolumn GHR_COMPLAINTS2.FINAL_INTERVIEW}
 * @param p_notice_rtf_recvd {@rep:casecolumn GHR_COMPLAINTS2.NOTICE_RTF_RECVD}
 * @param p_precom_closed {@rep:casecolumn GHR_COMPLAINTS2.PRECOM_CLOSED}
 * @param p_precom_closure_nature Complaint Pre-Complaint Nature of Closure.
 * Valid values are defined by 'GHR_US_NATURE_OF_CLOSURE' lookup type.
 * @param p_counselor_rpt_sub {@rep:casecolumn
 * GHR_COMPLAINTS2.COUNSELOR_RPT_SUB}
 * @param p_formal_com_filed {@rep:casecolumn GHR_COMPLAINTS2.FORMAL_COM_FILED}
 * @param p_ack_ltr {@rep:casecolumn GHR_COMPLAINTS2.ACK_LTR}
 * @param p_clarification_ltr_date {@rep:casecolumn
 * GHR_COMPLAINTS2.CLARIFICATION_LTR_DATE}
 * @param p_clarification_response_recvd {@rep:casecolumn
 * GHR_COMPLAINTS2.CLARIFICATION_RESPONSE_RECVD}
 * @param p_forwarded_legal_review {@rep:casecolumn
 * GHR_COMPLAINTS2.FORWARDED_LEGAL_REVIEW}
 * @param p_returned_from_legal {@rep:casecolumn
 * GHR_COMPLAINTS2.RETURNED_FROM_LEGAL}
 * @param p_letter_type Complaint Letter Type. Valid values are defined by
 * 'GHR_US_LETTER_TYPE' lookup type.
 * @param p_letter_date {@rep:casecolumn GHR_COMPLAINTS2.LETTER_DATE}
 * @param p_letter_recvd {@rep:casecolumn GHR_COMPLAINTS2.LETTER_RECVD}
 * @param p_investigation_source Complaint Investigation Source. Valid values
 * are defined by 'GHR_US_COMPLAINT_SOURCE' lookup type.
 * @param p_investigator_recvd_req {@rep:casecolumn
 * GHR_COMPLAINTS2.INVESTIGATOR_RECVD_REQ}
 * @param p_agency_investigator_req {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_INVESTIGATOR_REQ}
 * @param p_investigator_asg {@rep:casecolumn GHR_COMPLAINTS2.INVESTIGATOR_ASG}
 * @param p_investigation_start {@rep:casecolumn
 * GHR_COMPLAINTS2.INVESTIGATION_START}
 * @param p_investigation_end {@rep:casecolumn
 * GHR_COMPLAINTS2.INVESTIGATION_END}
 * @param p_investigation_extended {@rep:casecolumn
 * GHR_COMPLAINTS2.INVESTIGATION_EXTENDED}
 * @param p_invest_extension_desc Complaint Investigation Extension
 * Description. Valid values are defined by 'GHR_US_EXTENSION_DESC' lookup
 * type.
 * @param p_agency_recvd_roi {@rep:casecolumn GHR_COMPLAINTS2.AGENCY_RECVD_ROI}
 * @param p_comrep_recvd_roi {@rep:casecolumn GHR_COMPLAINTS2.COMREP_RECVD_ROI}
 * @param p_options_ltr_date {@rep:casecolumn GHR_COMPLAINTS2.OPTIONS_LTR_DATE}
 * @param p_comrep_recvd_opt_ltr {@rep:casecolumn
 * GHR_COMPLAINTS2.COMREP_RECVD_OPT_LTR}
 * @param p_comrep_opt_ltr_response Complaint Complainant Representative
 * Options Letter Response. Valid values are defined by
 * 'GHR_US_OPTIONS_RESPONSE' lookup type.
 * @param p_resolution_offer {@rep:casecolumn GHR_COMPLAINTS2.RESOLUTION_OFFER}
 * @param p_comrep_resol_offer_recvd {@rep:casecolumn
 * GHR_COMPLAINTS2.COMREP_RESOL_OFFER_RECVD}
 * @param p_comrep_resol_offer_response {@rep:casecolumn
 * GHR_COMPLAINTS2.COMREP_RESOL_OFFER_RESPONSE}
 * @param p_comrep_resol_offer_desc Complaint Complainant Representative
 * Resolution Offer Description. Valid values are defined by
 * 'GHR_US_RESOLUTION_RESP' lookup type.
 * @param p_resol_offer_signed {@rep:casecolumn
 * GHR_COMPLAINTS2.RESOL_OFFER_SIGNED}
 * @param p_resol_offer_desc {@rep:casecolumn GHR_COMPLAINTS2.RESOL_OFFER_DESC}
 * @param p_hearing_source Complaint Hearing Source. Valid values are defined
 * by 'GHR_US_COMPLAINT_SOURCE' lookup type.
 * @param p_agency_notified_hearing {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_NOTIFIED_HEARING}
 * @param p_eeoc_hearing_docket_num {@rep:casecolumn
 * GHR_COMPLAINTS2.EEOC_HEARING_DOCKET_NUM}
 * @param p_hearing_complete {@rep:casecolumn GHR_COMPLAINTS2.HEARING_REQ}
 * @param p_aj_merit_decision_date {@rep:casecolumn
 * GHR_COMPLAINTS2.AJ_MERIT_DECISION_DATE}
 * @param p_agency_recvd_aj_merit_dec {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_RECVD_AJ_MERIT_DEC}
 * @param p_aj_merit_decision Complaint Administrative Judge (AJ) Merit
 * Decision. Valid values are defined by 'GHR_US_MERIT_DECISION' lookup type.
 * @param p_aj_ca_decision_date {@rep:casecolumn
 * GHR_COMPLAINTS2.AJ_CA_DECISION_DATE}
 * @param p_agency_recvd_aj_ca_dec {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_RECVD_AJ_CA_DEC}
 * @param p_aj_ca_decision Complaint Administrative Judge (AJ) Corrective
 * Action Decision. Valid values are defined by 'GHR_US_AJ_CERT_DECISION'
 * lookup type.
 * @param p_fad_requested {@rep:casecolumn GHR_COMPLAINTS2.FAD_REQUESTED}
 * @param p_merit_fad {@rep:casecolumn GHR_COMPLAINTS2.MERIT_FAD}
 * @param p_attorney_fees_fad {@rep:casecolumn
 * GHR_COMPLAINTS2.ATTORNEY_FEES_FAD}
 * @param p_comp_damages_fad {@rep:casecolumn GHR_COMPLAINTS2.COMP_DAMAGES_FAD}
 * @param p_non_compliance_fad {@rep:casecolumn
 * GHR_COMPLAINTS2.NON_COMPLIANCE_FAD}
 * @param p_fad_req_recvd_eeo_office {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_REQ_RECVD_EEO_OFFICE}
 * @param p_fad_req_forwd_to_agency {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_REQ_FORWD_TO_AGENCY}
 * @param p_agency_recvd_request {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_RECVD_REQUEST}
 * @param p_fad_due {@rep:casecolumn GHR_COMPLAINTS2.FAD_DUE}
 * @param p_fad_date {@rep:casecolumn GHR_COMPLAINTS2.FAD_DATE}
 * @param p_fad_decision Complaint Final Agency Decision (FAD). Valid values
 * are defined by 'GHR_US_FAD_DECISION' lookup type.
 * @param p_fad_forwd_to_comrep {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_FORWD_TO_COMREP}
 * @param p_fad_recvd_by_comrep {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_RECVD_BY_COMREP}
 * @param p_fad_imp_ltr_forwd_to_org {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_IMP_LTR_FORWD_TO_ORG}
 * @param p_fad_decision_forwd_legal {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_DECISION_FORWD_LEGAL}
 * @param p_fad_decision_recvd_legal {@rep:casecolumn
 * GHR_COMPLAINTS2.FAD_DECISION_RECVD_LEGAL}
 * @param p_fa_source Complaint Final Action Source. Valid values are defined
 * by 'GHR_US_COMPLAINT_SOURCE' lookup type.
 * @param p_final_action_due {@rep:casecolumn GHR_COMPLAINTS2.FINAL_ACTION_DUE}
 * @param p_final_act_forwd_comrep {@rep:casecolumn
 * GHR_COMPLAINTS2.FINAL_ACT_FORWD_COMREP}
 * @param p_final_act_recvd_comrep {@rep:casecolumn
 * GHR_COMPLAINTS2.FINAL_ACT_RECVD_COMREP}
 * @param p_final_action_decision_date {@rep:casecolumn
 * GHR_COMPLAINTS2.FINAL_ACTION_DECISION_DATE}
 * @param p_final_action_decision Complaint Final Action Decision (FAD). Valid
 * values are defined by 'GHR_US_FAA_DECISION' lookup type.
 * @param p_fa_imp_ltr_forwd_to_org {@rep:casecolumn
 * GHR_COMPLAINTS2.FA_IMP_LTR_FORWD_TO_ORG}
 * @param p_fa_decision_forwd_legal {@rep:casecolumn
 * GHR_COMPLAINTS2.FA_DECISION_FORWD_LEGAL}
 * @param p_fa_decision_recvd_legal {@rep:casecolumn
 * GHR_COMPLAINTS2.FA_DECISION_RECVD_LEGAL}
 * @param p_civil_action_filed {@rep:casecolumn
 * GHR_COMPLAINTS2.CIVIL_ACTION_FILED}
 * @param p_agency_closure_confirmed {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_CLOSURE_CONFIRMED}
 * @param p_consolidated_complaint_id {@rep:casecolumn
 * GHR_COMPLAINTS2.CONSOLIDATED_COMPLAINT_ID}
 * @param p_consolidated {@rep:casecolumn GHR_COMPLAINTS2.CONSOLIDATED}
 * @param p_stage_of_consolidation Complaint Stage of Consolidation. Valid
 * values are defined by 'GHR_US_COMP_CONSOLIDATE_STAGE' lookup type.
 * @param p_comrep_notif_consolidation {@rep:casecolumn
 * GHR_COMPLAINTS2.COMREP_NOTIF_CONSOLIDATION}
 * @param p_consolidation_desc {@rep:casecolumn
 * GHR_COMPLAINTS2.CONSOLIDATION_DESC}
 * @param p_complaint_closed {@rep:casecolumn GHR_COMPLAINTS2.COMPLAINT_CLOSED}
 * @param p_nature_of_closure Complaint Nature of Closure. Valid values are
 * defined by 'GHR_US_NATURE_OF_CLOSURE_2' lookup type.
 * @param p_complaint_closed_desc {@rep:casecolumn
 * GHR_COMPLAINTS2.COMPLAINT_CLOSED_DESC}
 * @param p_filed_formal_class {@rep:casecolumn
 * GHR_COMPLAINTS2.FILED_FORMAL_CLASS}
 * @param p_forwd_eeoc {@rep:casecolumn GHR_COMPLAINTS2.FORWD_EEOC}
 * @param p_aj_cert_decision_date {@rep:casecolumn
 * GHR_COMPLAINTS2.AJ_CERT_DECISION_DATE}
 * @param p_aj_cert_decision_recvd {@rep:casecolumn
 * GHR_COMPLAINTS2.AJ_CERT_DECISION_RECVD}
 * @param p_aj_cert_decision Complaint Administrative Judge (AJ) Certified
 * Decision. Valid values are defined by 'GHR_US_AJ_CERT_DECISION' lookup type.
 * @param p_class_members_notified {@rep:casecolumn
 * GHR_COMPLAINTS2.CLASS_MEMBERS_NOTIFIED}
 * @param p_number_of_complaintants {@rep:casecolumn
 * GHR_COMPLAINTS2.NUMBER_OF_COMPLAINTANTS}
 * @param p_class_hearing {@rep:casecolumn GHR_COMPLAINTS2.CLASS_HEARING}
 * @param p_aj_dec {@rep:casecolumn GHR_COMPLAINTS2.AJ_DEC}
 * @param p_agency_recvd_aj_dec {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_RECVD_AJ_DEC}
 * @param p_aj_decision Complaint Administrative Judge (AJ) Decision. Valid
 * values are defined by 'GHR_US_AJ_REC_DECISION' lookup type.
 * @param p_agency_brief_eeoc {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_BRIEF_EEOC}
 * @param p_agency_notif_of_civil_action {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_NOTIF_OF_CIVIL_ACTION}
 * @param p_fad_source Complaint Final Agency Decision (FAD) Source. Valid
 * values are defined by 'GHR_US_COMPLAINT_SOURCE' lookup type.
 * @param p_agency_files_forwarded_eeoc {@rep:casecolumn
 * GHR_COMPLAINTS2.AGENCY_FILES_FORWARDED_EEOC}
 * @param p_hearing_req {@rep:casecolumn GHR_COMPLAINTS2.HEARING_REQ}
 * @param p_agency_code Complaint Two Character Agency Code. Valid values are
 * defined by 'GHR_US_AGENCY_CODE_2' lookup type.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_record_received {@rep:casecolumn
 * GHR_COMPLAINTS2.RECORD_RECEIVED}
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_alleg_discrim_org_id {@rep:casecolumn
 * GHR_COMPLAINTS2.ALLEG_DISCRIM_ORG_ID}
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_hr_office_org_id {@rep:casecolumn
 * GHR_COMPLAINTS2.HR_OFFICE_ORG_ID}
 * @param p_audited_by {@rep:casecolumn
 * GHR_COMPLAINTS2.AUDITED_BY}
 * @param p_eeo_office_org_id {@rep:casecolumn
 * GHR_COMPLAINTS2.EEO_OFFICE_ORG_ID}
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_serviced_org_id {@rep:casecolumn
 * GHR_COMPLAINTS2.SERVICED_ORG_ID}
 * @rep:displayname Update Complaint
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_complaint
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_complaint_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_complainant_person_id        in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_docket_number                in     varchar2  default hr_api.g_varchar2
  ,p_stage                        in     varchar2  default hr_api.g_varchar2
  ,p_class_flag                   in     varchar2  default hr_api.g_varchar2
  ,p_mixed_flag                   in     varchar2  default hr_api.g_varchar2
  ,p_consolidated_flag            in     varchar2  default hr_api.g_varchar2
  ,p_remand_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_active_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_information_inquiry          in     date      default hr_api.g_date
  ,p_pcom_init                    in     date      default hr_api.g_date
  ,p_alleg_incident               in     date      default hr_api.g_date
  ,p_alleg_discrim_org_id         in     number    default hr_api.g_number
  ,p_rr_ltr_date                  in     date      default hr_api.g_date
  ,p_rr_ltr_recvd                 in     date      default hr_api.g_date
  ,p_pre_com_elec                 in     varchar2  default hr_api.g_varchar2
  --,p_adr_offered                  in     varchar2  default hr_api.g_varchar2
  ,p_class_agent_flag             in     varchar2  default hr_api.g_varchar2
  ,p_pre_com_desc                 in     varchar2  default hr_api.g_varchar2
  ,p_counselor_asg                in     date      default hr_api.g_date
  ,p_init_counselor_interview     in     date      default hr_api.g_date
  ,p_anonymity_requested          in     varchar2  default hr_api.g_varchar2
  ,p_counsel_ext_ltr              in     date      default hr_api.g_date
  ,p_traditional_counsel_outcome  in     varchar2  default hr_api.g_varchar2
  ,p_final_interview              in     date      default hr_api.g_date
  ,p_notice_rtf_recvd             in     date      default hr_api.g_date
  ,p_precom_closed                in     date      default hr_api.g_date
  ,p_precom_closure_nature        in     varchar2  default hr_api.g_varchar2
  ,p_counselor_rpt_sub            in     date      default hr_api.g_date
  ,p_hr_office_org_id             in     number    default hr_api.g_number
  ,p_eeo_office_org_id            in     number    default hr_api.g_number
  ,p_serviced_org_id              in     number    default hr_api.g_number
  ,p_formal_com_filed             in     date      default hr_api.g_date
  ,p_ack_ltr                      in     date      default hr_api.g_date
  ,p_clarification_ltr_date       in     date      default hr_api.g_date
  ,p_clarification_response_recvd in     date      default hr_api.g_date
  ,p_forwarded_legal_review       in     date      default hr_api.g_date
  ,p_returned_from_legal          in     date      default hr_api.g_date
  ,p_letter_type                  in     varchar2  default hr_api.g_varchar2
  ,p_letter_date                  in     date      default hr_api.g_date
  ,p_letter_recvd                 in     date      default hr_api.g_date
  ,p_investigation_source         in     varchar2  default hr_api.g_varchar2
  ,p_investigator_recvd_req       in     date      default hr_api.g_date
  ,p_agency_investigator_req      in     date      default hr_api.g_date
  ,p_investigator_asg             in     date      default hr_api.g_date
  ,p_investigation_start          in     date      default hr_api.g_date
  ,p_investigation_end            in     date      default hr_api.g_date
  ,p_investigation_extended       in     date      default hr_api.g_date
  ,p_invest_extension_desc        in     varchar2  default hr_api.g_varchar2
  ,p_agency_recvd_roi             in     date      default hr_api.g_date
  ,p_comrep_recvd_roi             in     date      default hr_api.g_date
  ,p_options_ltr_date             in     date      default hr_api.g_date
  ,p_comrep_recvd_opt_ltr         in     date      default hr_api.g_date
  ,p_comrep_opt_ltr_response      in     varchar2  default hr_api.g_varchar2
  ,p_resolution_offer             in     date      default hr_api.g_date
  ,p_comrep_resol_offer_recvd     in     date      default hr_api.g_date
  ,p_comrep_resol_offer_response  in     date      default hr_api.g_date
  ,p_comrep_resol_offer_desc      in     varchar2  default hr_api.g_varchar2
  ,p_resol_offer_signed           in     date      default hr_api.g_date
  ,p_resol_offer_desc             in     varchar2  default hr_api.g_varchar2
  ,p_hearing_source               in     varchar2  default hr_api.g_varchar2
  ,p_agency_notified_hearing      in     date      default hr_api.g_date
  ,p_eeoc_hearing_docket_num      in     varchar2  default hr_api.g_varchar2
  ,p_hearing_complete             in     date      default hr_api.g_date
  ,p_aj_merit_decision_date       in     date      default hr_api.g_date
  ,p_agency_recvd_aj_merit_dec    in     date      default hr_api.g_date
  ,p_aj_merit_decision            in     varchar2  default hr_api.g_varchar2
  ,p_aj_ca_decision_date          in     date      default hr_api.g_date
  ,p_agency_recvd_aj_ca_dec       in     date      default hr_api.g_date
  ,p_aj_ca_decision               in     varchar2  default hr_api.g_varchar2
  ,p_fad_requested                in     date      default hr_api.g_date
  ,p_merit_fad                    in     varchar2  default hr_api.g_varchar2
  ,p_attorney_fees_fad            in     varchar2  default hr_api.g_varchar2
  ,p_comp_damages_fad             in     varchar2  default hr_api.g_varchar2
  ,p_non_compliance_fad           in     varchar2  default hr_api.g_varchar2
  ,p_fad_req_recvd_eeo_office     in     date      default hr_api.g_date
  ,p_fad_req_forwd_to_agency      in     date      default hr_api.g_date
  ,p_agency_recvd_request         in     date      default hr_api.g_date
  ,p_fad_due                      in     date      default hr_api.g_date
  ,p_fad_date                     in     date      default hr_api.g_date
  ,p_fad_decision                 in     varchar2  default hr_api.g_varchar2
  --,p_fad_final_action_closure     in     varchar2  default hr_api.g_varchar2
  ,p_fad_forwd_to_comrep          in     date      default hr_api.g_date
  ,p_fad_recvd_by_comrep          in     date      default hr_api.g_date
  ,p_fad_imp_ltr_forwd_to_org     in     date      default hr_api.g_date
  ,p_fad_decision_forwd_legal     in     date      default hr_api.g_date
  ,p_fad_decision_recvd_legal     in     date      default hr_api.g_date
  ,p_fa_source                    in     varchar2  default hr_api.g_varchar2
  ,p_final_action_due             in     date      default hr_api.g_date
  --,p_final_action_nature_of_closu in     varchar2  default hr_api.g_varchar2
  ,p_final_act_forwd_comrep       in     date      default hr_api.g_date
  ,p_final_act_recvd_comrep       in     date      default hr_api.g_date
  ,p_final_action_decision_date   in     date      default hr_api.g_date
  ,p_final_action_decision        in     varchar2  default hr_api.g_varchar2
  ,p_fa_imp_ltr_forwd_to_org      in     date      default hr_api.g_date
  ,p_fa_decision_forwd_legal      in     date      default hr_api.g_date
  ,p_fa_decision_recvd_legal      in     date      default hr_api.g_date
  ,p_civil_action_filed           in     date      default hr_api.g_date
  ,p_agency_closure_confirmed     in     date      default hr_api.g_date
  ,p_consolidated_complaint_id    in     number    default hr_api.g_number
  ,p_consolidated                 in     date      default hr_api.g_date
  ,p_stage_of_consolidation       in     varchar2  default hr_api.g_varchar2
  ,p_comrep_notif_consolidation   in     date      default hr_api.g_date
  ,p_consolidation_desc           in     varchar2  default hr_api.g_varchar2
  ,p_complaint_closed             in     date      default hr_api.g_date
  ,p_nature_of_closure            in     varchar2  default hr_api.g_varchar2
  ,p_complaint_closed_desc        in     varchar2  default hr_api.g_varchar2
  ,p_filed_formal_class           in     date      default hr_api.g_date
  ,p_forwd_eeoc                   in     date      default hr_api.g_date
  ,p_aj_cert_decision_date        in     date      default hr_api.g_date
  ,p_aj_cert_decision_recvd       in     date      default hr_api.g_date
  ,p_aj_cert_decision             in     varchar2  default hr_api.g_varchar2
  ,p_class_members_notified       in     date      default hr_api.g_date
  ,p_number_of_complaintants      in     number    default hr_api.g_number
  ,p_class_hearing                in     date      default hr_api.g_date
  ,p_aj_dec                       in     date      default hr_api.g_date
  ,p_agency_recvd_aj_dec          in     date      default hr_api.g_date
  ,p_aj_decision                  in     varchar2  default hr_api.g_varchar2
  ,p_agency_brief_eeoc            in     date      default hr_api.g_date
  ,p_agency_notif_of_civil_action in     date      default hr_api.g_date
  ,p_fad_source                   in     varchar2  default hr_api.g_varchar2
  ,p_agency_files_forwarded_eeoc  in     date      default hr_api.g_date
  ,p_hearing_req                  in     date      default hr_api.g_date
  ,p_agency_code                  in     varchar2  default hr_api.g_varchar2
  ,p_audited_by                   in     varchar2  default hr_api.g_varchar2
  ,p_record_received              in     date      default hr_api.g_date
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  );

--
end ghr_complaint_api;

 

/
