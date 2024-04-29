--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_CLAIMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_CLAIMS_API" AUTHID CURRENT_USER as
/* $Header: ghcclapi.pkh 120.1 2005/10/02 01:57:22 aroussel $ */
/*#
 * This package contains the procedures for creating, updating and deleting GHR
 * Complaint Tracking Complaint Claim records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Complaint Claim
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_compl_claim >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Complaints Tracking Complaint Claim record.
 *
 * This API creates a child Claim record in table ghr_compl_claims for an
 * existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Complaint record must exist in ghr_complaints2.
 *
 * <p><b>Post Success</b><br>
 * The API creates the Claim record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Claim record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_complaint_id Uniquely identifies the Parent Complaint record.
 * @param p_claim Complaint Claim Description. Valid values are defined by
 * 'GHR_US_COMPLAINT_CLAIM' lookup type.
 * @param p_incident_date {@rep:casecolumn GHR_COMPL_CLAIMS.INCIDENT_DATE}
 * @param p_phase Claim Phase. Valid values are defined by 'GHR_US_CLAIM_PHASE'
 * lookup type.
 * @param p_mixed_flag {@rep:casecolumn GHR_COMPL_CLAIMS.MIXED_FLAG}
 * @param p_claim_source {@rep:casecolumn GHR_COMPL_CLAIMS.CLAIM_SOURCE}
 * @param p_agency_acceptance Claim Agency Accept or Dismiss. Valid values are
 * defined by 'GHR_US_ACCEPT_DISMISS' lookup type.
 * @param p_aj_acceptance Claim Administrative Judge (AJ) Accept or Dismiss.
 * Valid values are defined by 'GHR_US_ACCEPT_DISMISS' lookup type.
 * @param p_agency_appeal {@rep:casecolumn GHR_COMPL_CLAIMS.AGENCY_APPEAL}
 * @param p_compl_claim_id If p_validate is false, then this uniquely
 * identifies the Claim created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Claim. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Complaint Claim
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_compl_claim
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_complaint_id                   in     number
  ,p_claim                          in     varchar2 default null
  ,p_incident_date                  in     date     default null
  ,p_phase                          in     varchar2 default null
  ,p_mixed_flag                     in     varchar2 default null
  ,p_claim_source                   in     varchar2 default null
  ,p_agency_acceptance              in     varchar2 default null
  ,p_aj_acceptance                  in     varchar2 default null
  ,p_agency_appeal                  in     varchar2 default null
  ,p_compl_claim_id                   out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_compl_claim >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Complaint Tracking Complaint Claim records.
 *
 * This API updates a child Claim record in table ghr_compl_claims for an
 * existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Complaint record must exist in ghr_complaints2.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Claim record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Claim record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_compl_claim_id Uniquely identifies the Claim record to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * Claim to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated Claim. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_complaint_id Uniquely identifies the Parent Complaint record.
 * @param p_claim Complaint Claim Description. Valid values are defined by
 * 'GHR_US_COMPLAINT_CLAIM' lookup type.
 * @param p_incident_date {@rep:casecolumn GHR_COMPL_CLAIMS.INCIDENT_DATE}
 * @param p_phase Claim Phase. Valid values are defined by 'GHR_US_CLAIM_PHASE'
 * lookup type.
 * @param p_mixed_flag {@rep:casecolumn GHR_COMPL_CLAIMS.MIXED_FLAG}
 * @param p_claim_source {@rep:casecolumn GHR_COMPL_CLAIMS.CLAIM_SOURCE}
 * @param p_agency_acceptance Claim Agency Accept or Dismiss. Valid values are
 * defined by 'GHR_US_ACCEPT_DISMISS' lookup type.
 * @param p_aj_acceptance Claim Administrative Judge (AJ) Accept or Dismiss.
 * Valid values are defined by 'GHR_US_ACCEPT_DISMISS' lookup type.
 * @param p_agency_appeal {@rep:casecolumn GHR_COMPL_CLAIMS.AGENCY_APPEAL}
 * @rep:displayname Update Complaint Claim
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_compl_claim
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_compl_claim_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_complaint_id                 in     number    default hr_api.g_number
  ,p_claim                        in     varchar2  default hr_api.g_varchar2
  ,p_incident_date                in     date      default hr_api.g_date
  ,p_phase                        in     varchar2  default hr_api.g_varchar2
  ,p_mixed_flag                   in     varchar2  default hr_api.g_varchar2
  ,p_claim_source                 in     varchar2  default hr_api.g_varchar2
  ,p_agency_acceptance            in     varchar2  default hr_api.g_varchar2
  ,p_aj_acceptance                in     varchar2  default hr_api.g_varchar2
  ,p_agency_appeal                in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_compl_claim >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Complaints Tracking Complaint Claim record.
 *
 * This API deletes a child Claim record from table ghr_compl_claims for an
 * existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Claim record specified must exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the Claim record from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Claim record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_compl_claim_id Uniquely identifies the Claim record to be deleted.
 * @param p_object_version_number Current version number of the Claim to be
 * deleted.
 * @rep:displayname Delete Complaint Claim
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_compl_claim
  (p_validate                      in     boolean  default false
  ,p_compl_claim_id                in     number
  ,p_object_version_number         in     number
  );

end ghr_complaint_claims_api;

 

/
