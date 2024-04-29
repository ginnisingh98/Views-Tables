--------------------------------------------------------
--  DDL for Package GHR_CMP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CMP_SHD" AUTHID CURRENT_USER as
/* $Header: ghcmprhi.pkh 120.0 2005/05/29 02:54:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (complaint_id                    number(15)
  ,complainant_person_id           number(15)
  ,business_group_id               number(15)
  ,docket_number                   varchar2(50)
  ,stage                           varchar2(30)       -- Increased length
  ,class_flag                      varchar2(9)       -- Increased length
  ,mixed_flag                      varchar2(9)       -- Increased length
  ,consolidated_flag               varchar2(9)       -- Increased length
  ,remand_flag                     varchar2(9)       -- Increased length
  ,active_flag                     varchar2(9)       -- Increased length
  ,information_inquiry             date
  ,pcom_init                       date
  ,alleg_incident                  date
  ,alleg_discrim_org_id            number(15)
  ,rr_ltr_date                     date
  ,rr_ltr_recvd                    date
  ,pre_com_elec                    varchar2(30)       -- Increased length
  --,adr_offered                     varchar2(9)       -- Increased length
  ,class_agent_flag                varchar2(9)       -- Increased length
  ,pre_com_desc                    varchar2(500)
  ,counselor_asg                   date
  ,init_counselor_interview        date
  ,anonymity_requested             varchar2(9)       -- Increased length
  ,counsel_ext_ltr                 date
  ,traditional_counsel_outcome     varchar2(30)       -- Increased length
  ,final_interview                 date
  ,notice_rtf_recvd                date
  ,precom_closed                   date
  ,precom_closure_nature           varchar2(30)       -- Increased length
  ,counselor_rpt_sub               date
  ,hr_office_org_id                number(15)
  ,eeo_office_org_id               number(15)
  ,serviced_org_id                 number(15)
  ,formal_com_filed                date
  ,ack_ltr                         date
  ,clarification_ltr_date          date
  ,clarification_response_recvd    date
  ,forwarded_legal_review          date
  ,returned_from_legal             date
  ,letter_type                     varchar2(30)
  ,letter_date                     date
  ,letter_recvd                    date
  ,investigation_source            varchar2(30)
  ,investigator_recvd_req          date
  ,agency_investigator_req         date
  ,investigator_asg                date
  ,investigation_start             date
  ,investigation_end               date
  ,investigation_extended          date
  ,invest_extension_desc           varchar2(500)
  ,agency_recvd_roi                date
  ,comrep_recvd_roi                date
  ,options_ltr_date                date
  ,comrep_recvd_opt_ltr            date
  ,comrep_opt_ltr_response         varchar2(30)       -- Increased length
  ,resolution_offer                date
  ,comrep_resol_offer_recvd        date
  ,comrep_resol_offer_response     date
  ,comrep_resol_offer_desc         varchar2(30)
  ,resol_offer_signed              date
  ,resol_offer_desc                varchar2(2000)
  ,hearing_source                  varchar2(30)       -- Increased length
  ,agency_notified_hearing         date
  ,eeoc_hearing_docket_num         varchar2(50)
  ,hearing_complete                date
  ,aj_merit_decision_date          date
  ,agency_recvd_aj_merit_dec       date
  ,aj_merit_decision               varchar2(30)       -- Increased length
  ,aj_ca_decision_date             date
  ,agency_recvd_aj_ca_dec          date
  ,aj_ca_decision                  varchar2(30)       -- Increased length
  ,fad_requested                   date
  ,merit_fad                       varchar2(9)       -- Increased length
  ,attorney_fees_fad               varchar2(9)       -- Increased length
  ,comp_damages_fad                varchar2(9)       -- Increased length
  ,non_compliance_fad              varchar2(9)       -- Increased length
  ,fad_req_recvd_eeo_office        date
  ,fad_req_forwd_to_agency         date
  ,agency_recvd_request            date
  ,fad_due                         date
  ,fad_date                        date
  ,fad_decision                    varchar2(30)       -- Increased length
  --,fad_final_action_closure        varchar2(30)       -- Increased length
  ,fad_forwd_to_comrep             date
  ,fad_recvd_by_comrep             date
  ,fad_imp_ltr_forwd_to_org        date
  ,fad_decision_forwd_legal        date
  ,fad_decision_recvd_legal        date
  ,fa_source                       varchar2(30)       -- Increased length
  ,final_action_due                date
  --,final_action_nature_of_closure  varchar2(30)      -- Increased length
  ,final_act_forwd_comrep          date
  ,final_act_recvd_comrep          date
  ,final_action_decision_date      date
  ,final_action_decision           varchar2(30)       -- Increased length
  ,fa_imp_ltr_forwd_to_org         date
  ,fa_decision_forwd_legal         date
  ,fa_decision_recvd_legal         date
  ,civil_action_filed              date
  ,agency_closure_confirmed        date
  ,consolidated_complaint_id       number(15)
  ,consolidated                    date
  ,stage_of_consolidation          varchar2(30)       -- Increased length
  ,comrep_notif_consolidation      date
  ,consolidation_desc              varchar2(500)
  ,complaint_closed                date
  ,nature_of_closure               varchar2(30)
  ,complaint_closed_desc           varchar2(2000)
  ,filed_formal_class              date
  ,forwd_eeoc                      date
  ,aj_cert_decision_date           date
  ,aj_cert_decision_recvd          date
  ,aj_cert_decision                varchar2(30)       -- Increased length
  ,class_members_notified          date
  ,number_of_complaintants         number(9)
  ,class_hearing                   date
  ,aj_dec                          date
  ,agency_recvd_aj_dec             date
  ,aj_decision                     varchar2(30)
  ,object_version_number           number(15)
  ,agency_brief_eeoc               date
  ,agency_notif_of_civil_action    date
  ,fad_source                      varchar2(30)       -- Increased length
  ,agency_files_forwarded_eeoc     date
  ,hearing_req                     date
  ,agency_code                     varchar2(4)
  ,audited_by                      varchar2(30)
  ,record_received                 date
  ,attribute_category              varchar2(30)
  ,attribute1                      varchar2(150)
  ,attribute2                      varchar2(150)
  ,attribute3                      varchar2(150)
  ,attribute4                      varchar2(150)
  ,attribute5                      varchar2(150)
  ,attribute6                      varchar2(150)
  ,attribute7                      varchar2(150)
  ,attribute8                      varchar2(150)
  ,attribute9                      varchar2(150)
  ,attribute10                     varchar2(150)
  ,attribute11                     varchar2(150)
  ,attribute12                     varchar2(150)
  ,attribute13                     varchar2(150)
  ,attribute14                     varchar2(150)
  ,attribute15                     varchar2(150)
  ,attribute16                     varchar2(150)
  ,attribute17                     varchar2(150)
  ,attribute18                     varchar2(150)
  ,attribute19                     varchar2(150)
  ,attribute20                     varchar2(150)
  ,attribute21                     varchar2(150)
  ,attribute22                     varchar2(150)
  ,attribute23                     varchar2(150)
  ,attribute24                     varchar2(150)
  ,attribute25                     varchar2(150)
  ,attribute26                     varchar2(150)
  ,attribute27                     varchar2(150)
  ,attribute28                     varchar2(150)
  ,attribute29                     varchar2(150)
  ,attribute30                     varchar2(150)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Prerequisites:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which corresponds with a constraint error.
--
-- In Parameter:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
--  {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the
--   current row from the database for the specified primary key
--   provided that the primary key exists and is valid and does not
--   already match the current g_old_rec. The function will always return
--   a TRUE value if the g_old_rec is populated with the current row.
--   A FALSE value will be returned if all of the primary key arguments
--   are null.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec
--   is current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (p_complaint_id                         in     number
  ,p_object_version_number                in     number
  )      Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from
--   the server to be available to the api.
--
-- Prerequisites:
--   When attempting to call the lock the object version number (if defined)
--   is mandatory.
--
-- In Parameters:
--   The arguments to the Lck process are the primary key(s) which uniquely
--   identify the row and the object version number of row.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   For each primary key and the object version number arguments add a
--   call to hr_api.mandatory_arg_error procedure to ensure that these
--   argument values are not null.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (p_complaint_id                         in     number
  ,p_object_version_number                in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute parameters into the record
--   structure parameter g_rec_type.
--
-- Prerequisites:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Parameters:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function.  Any possible
--   errors within this function will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
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
  Return g_rec_type;
--
end ghr_cmp_shd;

 

/
