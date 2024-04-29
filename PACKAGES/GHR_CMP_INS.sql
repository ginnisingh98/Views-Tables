--------------------------------------------------------
--  DDL for Package GHR_CMP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CMP_INS" AUTHID CURRENT_USER as
/* $Header: ghcmprhi.pkh 120.0 2005/05/29 02:54:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) The controlling validation process insert_validate is executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   3) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   4) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy ghr_cmp_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
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
  ,p_alleg_discrim_org_id           in     number default null
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
  ,p_final_action_decision          in     varchar2  default null
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
end ghr_cmp_ins;

 

/
