--------------------------------------------------------
--  DDL for Package GHR_COMPLAINANT_APPEALS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINANT_APPEALS_API" AUTHID CURRENT_USER as
/* $Header: ghccaapi.pkh 120.1 2005/10/02 01:57:18 aroussel $ */
/*#
 * This package contains the procedures for creating, updating and deleting GHR
 * Complaints Tracking Complainant Appeal records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Complainant Appeal
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_complainant_appeal >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Complaints Tracking Complainant Appeal records.
 *
 * This API creates a child Complainant Appeal record in table
 * ghr_compl_appeals for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Complaint record must exist in ghr_complaints2.
 *
 * <p><b>Post Success</b><br>
 * The API creates the Complainant Appeal record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Complainant Appeal record and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_complaint_id Uniquely identifies the Parent Complaint record.
 * @param p_appeal_date {@rep:casecolumn GHR_COMPL_APPEALS.APPEAL_DATE}
 * @param p_appealed_to Complainant Appealed To Organization. Valid values are
 * defined by 'GHR_US_APPEAL_TO' lookup type.
 * @param p_reason_for_appeal Complainant Reason for Appeal. Valid values are
 * defined by 'GHR_US_APPEAL_REASON' lookup type.
 * @param p_source_decision_date {@rep:casecolumn
 * GHR_COMPL_APPEALS.SOURCE_DECISION_DATE}
 * @param p_docket_num {@rep:casecolumn GHR_COMPL_APPEALS.DOCKET_NUM}
 * @param p_org_notified_of_appeal {@rep:casecolumn
 * GHR_COMPL_APPEALS.ORG_NOTIFIED_OF_APPEAL}
 * @param p_agency_recvd_req_for_files {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGENCY_RECVD_REQ_FOR_FILES}
 * @param p_files_due {@rep:casecolumn GHR_COMPL_APPEALS.FILES_DUE}
 * @param p_files_forwd {@rep:casecolumn GHR_COMPL_APPEALS.FILES_FORWD}
 * @param p_agcy_recvd_appellant_brief {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGCY_RECVD_APPELLANT_BRIEF}
 * @param p_agency_brief_due {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGENCY_BRIEF_DUE}
 * @param p_appellant_brief_forwd_org {@rep:casecolumn
 * GHR_COMPL_APPEALS.APPELLANT_BRIEF_FORWD_ORG}
 * @param p_org_forwd_brief_to_agency {@rep:casecolumn
 * GHR_COMPL_APPEALS.ORG_FORWD_BRIEF_TO_AGENCY}
 * @param p_agency_brief_forwd {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGENCY_BRIEF_FORWD}
 * @param p_decision_date {@rep:casecolumn GHR_COMPL_APPEALS.DECISION_DATE}
 * @param p_dec_recvd_by_agency {@rep:casecolumn
 * GHR_COMPL_APPEALS.DEC_RECVD_BY_AGENCY}
 * @param p_decision Complainant Appeal Decision. Valid values are defined by
 * 'GHR_US_APPEAL_DECISION or GHR_US_MSPB_DECISION' lookup type.
 * @param p_dec_forwd_to_org {@rep:casecolumn
 * GHR_COMPL_APPEALS.DEC_FORWD_TO_ORG}
 * @param p_agency_rfr_suspense {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGENCY_RFR_SUSPENSE}
 * @param p_request_for_rfr {@rep:casecolumn GHR_COMPL_APPEALS.REQUEST_FOR_RFR}
 * @param p_rfr_docket_num {@rep:casecolumn GHR_COMPL_APPEALS.RFR_DOCKET_NUM}
 * @param p_rfr_requested_by Complainant Appeal Request For Reconsideration
 * (RFR) Requested by. Valid values are defined by 'GHR_US_REQUESTOR' lookup
 * type.
 * @param p_agency_rfr_due {@rep:casecolumn GHR_COMPL_APPEALS.AGENCY_RFR_DUE}
 * @param p_rfr_forwd_to_org {@rep:casecolumn
 * GHR_COMPL_APPEALS.RFR_FORWD_TO_ORG}
 * @param p_org_forwd_rfr_to_agency {@rep:casecolumn
 * GHR_COMPL_APPEALS.ORG_FORWD_RFR_TO_AGENCY}
 * @param p_agency_forwd_rfr_ofo {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGENCY_FORWD_RFR_OFO}
 * @param p_rfr_decision Complainant Appeal Request For Reconsideration (RFR)
 * Decision. Valid values are defined by 'GHR_US_OFO_RFR_DECISION' lookup type.
 * @param p_rfr_decision_date {@rep:casecolumn
 * GHR_COMPL_APPEALS.RFR_DECISION_DATE}
 * @param p_agency_recvd_rfr_dec {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGENCY_RECVD_RFR_DEC}
 * @param p_rfr_decision_forwd_to_org {@rep:casecolumn
 * GHR_COMPL_APPEALS.RFR_DECISION_FORWD_TO_ORG}
 * @param p_compl_appeal_id If p_validate is false, then this uniquely
 * identifies the Complainant Appeal created. If p_validate is true, then set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Complainant Appeal. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Complainant Appeal
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_complainant_appeal
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_complaint_id                   in     number
  ,p_appeal_date                    in     date     default null
  ,p_appealed_to                    in     varchar2 default null
  ,p_reason_for_appeal              in     varchar2 default null
  ,p_source_decision_date           in     date     default null
  ,p_docket_num                     in     varchar2 default null
  ,p_org_notified_of_appeal         in     date     default null
  ,p_agency_recvd_req_for_files     in     date     default null
  ,p_files_due                      in     date     default null
  ,p_files_forwd                    in     date     default null
  ,p_agcy_recvd_appellant_brief     in     date     default null
  ,p_agency_brief_due               in     date     default null
  ,p_appellant_brief_forwd_org      in     date     default null
  ,p_org_forwd_brief_to_agency      in     date     default null
  ,p_agency_brief_forwd             in     date     default null
  ,p_decision_date                  in     date     default null
  ,p_dec_recvd_by_agency            in     date     default null
  ,p_decision                       in     varchar2 default null
  ,p_dec_forwd_to_org               in     date     default null
  ,p_agency_rfr_suspense            in     date     default null
  ,p_request_for_rfr                in     date     default null
  ,p_rfr_docket_num                 in     varchar2 default null
  ,p_rfr_requested_by               in     varchar2 default null
  ,p_agency_rfr_due                 in     date     default null
  ,p_rfr_forwd_to_org               in     date     default null
  ,p_org_forwd_rfr_to_agency        in     date     default null
  ,p_agency_forwd_rfr_ofo           in     date     default null
  ,p_rfr_decision                   in     varchar2 default null
  ,p_rfr_decision_date              in     date     default null
  ,p_agency_recvd_rfr_dec           in     date     default null
  ,p_rfr_decision_forwd_to_org      in     date     default null
  ,p_compl_appeal_id                out nocopy    number
  ,p_object_version_number          out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_complainant_appeal >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Complaints Tracking Complainant Appeal records.
 *
 * This API updates a child Complainant Appeal record in table
 * ghr_compl_appeals for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Complaint record must exist in ghr_complaints2.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Complainant Appeal record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Complainant Appeal record and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_compl_appeal_id Uniquely identifies the Complainant Appeal record
 * to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * Complainant Appeal to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated Complainant
 * Appeal. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_complaint_id Unique key of the Parent Complaint record.
 * @param p_appeal_date {@rep:casecolumn GHR_COMPL_APPEALS.APPEAL_DATE}
 * @param p_appealed_to Complainant Appealed To Organization. Valid values are
 * defined by 'GHR_US_APPEAL_TO' lookup type.
 * @param p_reason_for_appeal Complainant Reason for Appeal. Valid values are
 * defined by 'GHR_US_APPEAL_REASON' lookup type.
 * @param p_source_decision_date {@rep:casecolumn
 * GHR_COMPL_APPEALS.SOURCE_DECISION_DATE}
 * @param p_docket_num {@rep:casecolumn GHR_COMPL_APPEALS.DOCKET_NUM}
 * @param p_org_notified_of_appeal {@rep:casecolumn
 * GHR_COMPL_APPEALS.ORG_NOTIFIED_OF_APPEAL}
 * @param p_agency_recvd_req_for_files {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGENCY_RECVD_REQ_FOR_FILES}
 * @param p_files_due {@rep:casecolumn GHR_COMPL_APPEALS.FILES_DUE}
 * @param p_files_forwd {@rep:casecolumn GHR_COMPL_APPEALS.FILES_FORWD}
 * @param p_agcy_recvd_appellant_brief {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGCY_RECVD_APPELLANT_BRIEF}
 * @param p_agency_brief_due {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGENCY_BRIEF_DUE}
 * @param p_appellant_brief_forwd_org {@rep:casecolumn
 * GHR_COMPL_APPEALS.APPELLANT_BRIEF_FORWD_ORG}
 * @param p_org_forwd_brief_to_agency {@rep:casecolumn
 * GHR_COMPL_APPEALS.ORG_FORWD_BRIEF_TO_AGENCY}
 * @param p_agency_brief_forwd {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGENCY_BRIEF_FORWD}
 * @param p_decision_date {@rep:casecolumn GHR_COMPL_APPEALS.DECISION_DATE}
 * @param p_dec_recvd_by_agency {@rep:casecolumn
 * GHR_COMPL_APPEALS.DEC_RECVD_BY_AGENCY}
 * @param p_decision Complainant Appeal Decision. Valid values are defined by
 * 'GHR_US_APPEAL_DECISION or GHR_US_MSPB_DECISION' lookup type.
 * @param p_dec_forwd_to_org {@rep:casecolumn
 * GHR_COMPL_APPEALS.DEC_FORWD_TO_ORG}
 * @param p_agency_rfr_suspense {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGENCY_RFR_SUSPENSE}
 * @param p_request_for_rfr {@rep:casecolumn GHR_COMPL_APPEALS.REQUEST_FOR_RFR}
 * @param p_rfr_docket_num {@rep:casecolumn GHR_COMPL_APPEALS.RFR_DOCKET_NUM}
 * @param p_rfr_requested_by Complainant Appeal Request For Reconsideration
 * (RFR) Requested by. Valid values are defined by 'GHR_US_REQUESTOR' lookup
 * type.
 * @param p_agency_rfr_due {@rep:casecolumn GHR_COMPL_APPEALS.AGENCY_RFR_DUE}
 * @param p_rfr_forwd_to_org {@rep:casecolumn
 * GHR_COMPL_APPEALS.RFR_FORWD_TO_ORG}
 * @param p_org_forwd_rfr_to_agency {@rep:casecolumn
 * GHR_COMPL_APPEALS.ORG_FORWD_RFR_TO_AGENCY}
 * @param p_agency_forwd_rfr_ofo {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGENCY_FORWD_RFR_OFO}
 * @param p_rfr_decision Complainant Appeal Request For Reconsideration (RFR)
 * Decision. Valid values are defined by 'GHR_US_OFO_RFR_DECISION' lookup type.
 * @param p_rfr_decision_date {@rep:casecolumn
 * GHR_COMPL_APPEALS.RFR_DECISION_DATE}
 * @param p_agency_recvd_rfr_dec {@rep:casecolumn
 * GHR_COMPL_APPEALS.AGENCY_RECVD_RFR_DEC}
 * @param p_rfr_decision_forwd_to_org {@rep:casecolumn
 * GHR_COMPL_APPEALS.RFR_DECISION_FORWD_TO_ORG}
 * @rep:displayname Update Complainant Appeal
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_complainant_appeal
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_compl_appeal_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_complaint_id                 in     number   default hr_api.g_number
  ,p_appeal_date                  in     date     default hr_api.g_date
  ,p_appealed_to                  in     varchar2 default hr_api.g_varchar2
  ,p_reason_for_appeal            in     varchar2 default hr_api.g_varchar2
  ,p_source_decision_date         in     date     default hr_api.g_date
  ,p_docket_num                   in     varchar2 default hr_api.g_varchar2
  ,p_org_notified_of_appeal       in     date     default hr_api.g_date
  ,p_agency_recvd_req_for_files   in     date     default hr_api.g_date
  ,p_files_due                    in     date     default hr_api.g_date
  ,p_files_forwd                  in     date     default hr_api.g_date
  ,p_agcy_recvd_appellant_brief   in     date     default hr_api.g_date
  ,p_agency_brief_due             in     date     default hr_api.g_date
  ,p_appellant_brief_forwd_org    in     date     default hr_api.g_date
  ,p_org_forwd_brief_to_agency    in     date     default hr_api.g_date
  ,p_agency_brief_forwd           in     date     default hr_api.g_date
  ,p_decision_date                in     date     default hr_api.g_date
  ,p_dec_recvd_by_agency          in     date     default hr_api.g_date
  ,p_decision                     in     varchar2 default hr_api.g_varchar2
  ,p_dec_forwd_to_org             in     date     default hr_api.g_date
  ,p_agency_rfr_suspense          in     date     default hr_api.g_date
  ,p_request_for_rfr              in     date     default hr_api.g_date
  ,p_rfr_docket_num               in     varchar2 default hr_api.g_varchar2
  ,p_rfr_requested_by             in     varchar2 default hr_api.g_varchar2
  ,p_agency_rfr_due               in     date     default hr_api.g_date
  ,p_rfr_forwd_to_org             in     date     default hr_api.g_date
  ,p_org_forwd_rfr_to_agency      in     date     default hr_api.g_date
  ,p_agency_forwd_rfr_ofo         in     date     default hr_api.g_date
  ,p_rfr_decision                 in     varchar2 default hr_api.g_varchar2
  ,p_rfr_decision_date            in     date     default hr_api.g_date
  ,p_agency_recvd_rfr_dec         in     date     default hr_api.g_date
  ,p_rfr_decision_forwd_to_org    in     date     default hr_api.g_date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_complainant_appeal >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes Complaints Tracking Complainant Appeal records.
 *
 * This API deletes a child Complainant Appeal record from table
 * ghr_compl_appeals for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The API deletes the Complainant Appeal record from the database.
 *
 * <p><b>Post Success</b><br>
 * The complainant's appeal record is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Complainant Appeal record and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_compl_appeal_id Uniquely identifies the Complaint Appeal record to
 * be deleted.
 * @param p_object_version_number Current version number of the Complainant
 * Appeal to be deleted.
 * @rep:displayname Delete Complainant Appeal
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_complainant_appeal
  (p_validate                      in     boolean  default false
  ,p_compl_appeal_id               in     number
  ,p_object_version_number         in     number
  );
end ghr_complainant_appeals_api;

 

/
