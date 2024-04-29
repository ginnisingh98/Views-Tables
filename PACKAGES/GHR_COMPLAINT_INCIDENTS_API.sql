--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_INCIDENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_INCIDENTS_API" AUTHID CURRENT_USER as
/* $Header: ghcinapi.pkh 120.1 2005/10/02 01:57:31 aroussel $ */
/*#
 * This package contains the procedures for creating, updating and deleting GHR
 * Complaints Tracking Complaint Incident records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Complaint Incident
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_compl_incident >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Complaint Tracking Complaint Incident record.
 *
 * This API creates a child Incident record in table ghr_compl_incidents for an
 * existing parent Claim.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Claim record must exist in ghr_compl_claims.
 *
 * <p><b>Post Success</b><br>
 * The API creates the Incident record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not Create the Incident record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_compl_claim_id Uniquely identifies the Parent Claim record.
 * @param p_incident_date {@rep:casecolumn GHR_COMPL_INCIDENTS.INCIDENT_DATE}
 * @param p_description {@rep:casecolumn GHR_COMPL_INCIDENTS.DESCRIPTION}
 * @param p_date_amended {@rep:casecolumn GHR_COMPL_INCIDENTS.DATE_AMENDED}
 * @param p_date_acknowledged {@rep:casecolumn
 * GHR_COMPL_INCIDENTS.DATE_ACKNOWLEDGED}
 * @param p_compl_incident_id If p_validate is false, then this uniquely
 * identifies the Incident created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Incident. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Complaint Incident
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_compl_incident
  (p_validate                     in boolean  default false
  ,p_effective_date               in date
  ,p_compl_claim_id               in number
  ,p_incident_date                in date     default null
  ,p_description                  in varchar2 default null
  ,p_date_amended                 in date     default null
  ,p_date_acknowledged            in date     default null
  ,p_compl_incident_id            out nocopy number
  ,p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_compl_incident >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Complaint Tracking Complaint Incident record.
 *
 * This API updates a child Incident record in table ghr_compl_incidents for an
 * existing parent Claim.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Claim record must exist in ghr_compl_claims.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Incident record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Incident record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_compl_incident_id Uniquely identifies the Incident record being
 * updated.
 * @param p_compl_claim_id Uniquely identifies the Parent Claim record.
 * @param p_incident_date {@rep:casecolumn GHR_COMPL_INCIDENTS.INCIDENT_DATE}
 * @param p_description {@rep:casecolumn GHR_COMPL_INCIDENTS.DESCRIPTION}
 * @param p_date_amended {@rep:casecolumn GHR_COMPL_INCIDENTS.DATE_AMENDED}
 * @param p_date_acknowledged {@rep:casecolumn
 * GHR_COMPL_INCIDENTS.DATE_ACKNOWLEDGED}
 * @param p_object_version_number Pass in the current version number of the
 * Incident to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated Incident. If p_validate is
 * true will be set to the same value which was passed in.
 * @rep:displayname Update Complaint Incident
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_compl_incident
  (p_validate                     in boolean  default false
  ,p_effective_date               in date
  ,p_compl_incident_id            in number
  ,p_compl_claim_id               in number   default hr_api.g_number
  ,p_incident_date                in date     default hr_api.g_date
  ,p_description                  in varchar2 default hr_api.g_varchar2
  ,p_date_amended                 in date     default hr_api.g_date
  ,p_date_acknowledged            in date     default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_compl_incident >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Complaint Tracking Complaint Incident record.
 *
 * This API deletes a child Incident record in table ghr_compl_incidents for an
 * existing parent Claim.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Incident record specified must exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the Incident record from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Incident record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_compl_incident_id Uniquely identifies the Incident record being
 * deleted.
 * @param p_object_version_number Current version number of the Incident to be
 * deleted.
 * @rep:displayname Delete Complaint Incident
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_compl_incident
  (p_validate                     in boolean  default false
  ,p_compl_incident_id            in number
  ,p_object_version_number        in number
  );
--
end ghr_complaint_incidents_api;

 

/
