--------------------------------------------------------
--  DDL for Package GHR_COMPLAINTS_CA_HEADERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINTS_CA_HEADERS_API" AUTHID CURRENT_USER as
/* $Header: ghcahapi.pkh 120.1 2005/10/02 01:57:09 aroussel $ */
/*#
 * This package contains the procedures for creating, updating, and deleting
 * GHR Complaint Tracking, Corrective Action Header records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Complaint Corrective Action Header
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_ca_header >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Complaint Tracking Corrective Action Header records.
 *
 * This API creates a child Corrective Action Header record in table
 * ghr_compl_ca_headers for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Complaint record must exist in ghr_complaints2.
 *
 * <p><b>Post Success</b><br>
 * The API Creates the Corrective Action Header record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Corrective Action Header record and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_complaint_id Unique key of the Parent Complaint record.
 * @param p_ca_source Complaint Corrective Action Header, Corrective Action
 * Source. Valid values are defined by 'GHR_US_COMPLAINT_SOURCE' lookup type.
 * @param p_last_compliance_report {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.LAST_COMPLIANCE_REPORT}
 * @param p_compliance_closed {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.COMPLIANCE_CLOSED}
 * @param p_compl_docket_number {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.COMPL_DOCKET_NUMBER}
 * @param p_appeal_docket_number {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.APPEAL_DOCKET_NUMBER}
 * @param p_pfe_docket_number {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.PFE_DOCKET_NUMBER}
 * @param p_pfe_received {@rep:casecolumn GHR_COMPL_CA_HEADERS.PFE_RECEIVED}
 * @param p_agency_brief_pfe_due {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.AGENCY_BRIEF_PFE_DUE}
 * @param p_agency_brief_pfe_date {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.AGENCY_BRIEF_PFE_DATE}
 * @param p_decision_pfe_date {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.DECISION_PFE_DATE}
 * @param p_decision_pfe {@rep:casecolumn GHR_COMPL_CA_HEADERS.DECISION_PFE}
 * @param p_agency_recvd_pfe_decision {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.AGENCY_RECVD_PFE_DECISION}
 * @param p_agency_pfe_brief_forwd {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.AGENCY_PFE_BRIEF_FORWD}
 * @param p_agency_notified_noncom {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.AGENCY_NOTIFIED_NONCOM}
 * @param p_comrep_noncom_req Complaint Corrective Action Header, Complainant
 * Representative Request. Valid values are defined by 'GHR_US_REQUEST' lookup
 * type.
 * @param p_eeo_off_req_data_from_org {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.EEO_OFF_REQ_DATA_FROM_ORG}
 * @param p_org_forwd_data_to_eeo_off {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.ORG_FORWD_DATA_TO_EEO_OFF}
 * @param p_dec_implemented {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.DEC_IMPLEMENTED}
 * @param p_complaint_reinstated {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.COMPLAINT_REINSTATED}
 * @param p_stage_complaint_reinstated Complaint Corrective Action Header,
 * Stage Complaint Reinstated. Valid values are defined by 'GHR_US_STAGE'
 * lookup type.
 * @param p_compl_ca_header_id If p_validate is false, then this uniquely
 * identifies the Corrective Action Header created. If p_validate is true, then
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Corrective Action Header. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Corrective Action Header
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ca_header
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_complaint_id                   in     number   default null
  ,p_ca_source                      in     varchar2 default null
  ,p_last_compliance_report         in     date     default null
  ,p_compliance_closed              in	   date     default null
  ,p_compl_docket_number            in	   varchar2 default null
  ,p_appeal_docket_number           in	   varchar2 default null
  ,p_pfe_docket_number              in	   varchar2 default null
  ,p_pfe_received                   in     date     default null
  ,p_agency_brief_pfe_due           in	   date     default null
  ,p_agency_brief_pfe_date          in	   date     default null
  ,p_decision_pfe_date              in	   date     default null
  ,p_decision_pfe                   in	   varchar2 default null
  ,p_agency_recvd_pfe_decision      in 	   date     default null
  ,p_agency_pfe_brief_forwd         in	   date     default null
  ,p_agency_notified_noncom         in	   date     default null
  ,p_comrep_noncom_req              in	   varchar2 default null
  ,p_eeo_off_req_data_from_org      in	   date     default null
  ,p_org_forwd_data_to_eeo_off      in	   date     default null
  ,p_dec_implemented                in	   date     default null
  ,p_complaint_reinstated           in	   date     default null
  ,p_stage_complaint_reinstated     in	   varchar2 default null
  ,p_compl_ca_header_id             out nocopy    number
  ,p_object_version_number          out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_ca_header >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Complaint Tracking, Corrective Action Header records.
 *
 * This API updates a child Corrective Action Header record in table
 * ghr_compl_ca_headers for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Complaint record must exist in ghr_complaints2.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Corrective Action Header record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Corrective Action Header record and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_compl_ca_header_id Uniquely identifies the Parent Corrective Action
 * Header record.
 * @param p_object_version_number Pass in the current version number of the
 * Corrective Action Header to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated Corrective
 * Action Header. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_complaint_id Uniquely identifies the Parent Complaint record.
 * @param p_ca_source Complaint Corrective Action Header, Corrective Action
 * Source. Valid values are defined by 'GHR_US_COMPLAINT_SOURCE' lookup type.
 * @param p_last_compliance_report {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.LAST_COMPLIANCE_REPORT}
 * @param p_compliance_closed {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.COMPLIANCE_CLOSED}
 * @param p_compl_docket_number {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.COMPL_DOCKET_NUMBER}
 * @param p_appeal_docket_number {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.APPEAL_DOCKET_NUMBER}
 * @param p_pfe_docket_number {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.PFE_DOCKET_NUMBER}
 * @param p_pfe_received {@rep:casecolumn GHR_COMPL_CA_HEADERS.PFE_RECEIVED}
 * @param p_agency_brief_pfe_due {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.AGENCY_BRIEF_PFE_DUE}
 * @param p_agency_brief_pfe_date {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.AGENCY_BRIEF_PFE_DATE}
 * @param p_decision_pfe_date {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.DECISION_PFE_DATE}
 * @param p_decision_pfe {@rep:casecolumn GHR_COMPL_CA_HEADERS.DECISION_PFE}
 * @param p_agency_recvd_pfe_decision {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.AGENCY_RECVD_PFE_DECISION}
 * @param p_agency_pfe_brief_forwd {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.AGENCY_PFE_BRIEF_FORWD}
 * @param p_agency_notified_noncom {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.AGENCY_NOTIFIED_NONCOM}
 * @param p_comrep_noncom_req Complaint Corrective Action Header, Complainant
 * Representative Request. Valid values are defined by 'GHR_US_REQUEST' lookup
 * type.
 * @param p_eeo_off_req_data_from_org {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.EEO_OFF_REQ_DATA_FROM_ORG}
 * @param p_org_forwd_data_to_eeo_off {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.ORG_FORWD_DATA_TO_EEO_OFF}
 * @param p_dec_implemented {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.DEC_IMPLEMENTED}
 * @param p_complaint_reinstated {@rep:casecolumn
 * GHR_COMPL_CA_HEADERS.COMPLAINT_REINSTATED}
 * @param p_stage_complaint_reinstated Complaint Corrective Action Header,
 * Stage Complaint Reinstated. Valid values are defined by 'GHR_US_STAGE'
 * lookup type.
 * @rep:displayname Update Corrective Action Header
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_ca_header
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_compl_ca_header_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_complaint_id                 in     number    default hr_api.g_number
  ,p_ca_source                    in     varchar2  default hr_api.g_varchar2
  ,p_last_compliance_report       in     date      default hr_api.g_date
  ,p_compliance_closed            in     date      default hr_api.g_date
  ,p_compl_docket_number          in     varchar2  default hr_api.g_varchar2
  ,p_appeal_docket_number         in     varchar2  default hr_api.g_varchar2
  ,p_pfe_docket_number            in     varchar2  default hr_api.g_varchar2
  ,p_pfe_received                 in     date      default hr_api.g_date
  ,p_agency_brief_pfe_due         in     date      default hr_api.g_date
  ,p_agency_brief_pfe_date        in     date      default hr_api.g_date
  ,p_decision_pfe_date            in     date      default hr_api.g_date
  ,p_decision_pfe                 in     varchar2  default hr_api.g_varchar2
  ,p_agency_recvd_pfe_decision    in     date      default hr_api.g_date
  ,p_agency_pfe_brief_forwd       in     date      default hr_api.g_date
  ,p_agency_notified_noncom       in     date      default hr_api.g_date
  ,p_comrep_noncom_req            in     varchar2  default hr_api.g_varchar2
  ,p_eeo_off_req_data_from_org    in     date      default hr_api.g_date
  ,p_org_forwd_data_to_eeo_off    in     date      default hr_api.g_date
  ,p_dec_implemented              in     date      default hr_api.g_date
  ,p_complaint_reinstated         in     date      default hr_api.g_date
  ,p_stage_complaint_reinstated   in     varchar2  default hr_api.g_varchar2
 );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_ca_header >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes Complaint Tracking Corrective Action Header records.
 *
 * This API deletes a child Corrective Action Header record from table
 * ghr_compl_ca_headers for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Corrective Action Header record specified must exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the Corrective Action Header record from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Corrective Action Header record and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_compl_ca_header_id Uniquely identifies the Corrective Action Header
 * record to be deleted.
 * @param p_object_version_number Current version number of the Corrective
 * Action Header to be deleted.
 * @rep:displayname Delete Corrective Action Header
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_ca_header
  (p_validate                      in     boolean  default false
  ,p_compl_ca_header_id            in     number
  ,p_object_version_number         in     number
  );

end ghr_complaints_ca_headers_api;

 

/
