--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_ADRS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_ADRS_API" AUTHID CURRENT_USER as
/* $Header: ghcadapi.pkh 120.1 2005/10/02 01:57:04 aroussel $ */
/*#
 * This package contains the procedures for creating, updating, and deleting
 * GHR Complaints Tracking Alternate Dispute Resolution (ADR) records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Complaint Tracking Alternate Dispute Resolution
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_compl_adr >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Complaints Tracking Alternate Dispute Resolution record.
 *
 * This API creates a child Alternate Dispute Resolution record in table
 * ghr_compl_adrs for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Complaint record must exist in ghr_complaints2.
 *
 * <p><b>Post Success</b><br>
 * The API creates an Alternate Dispute Resolution record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Alternate Dispute Resolution record and an error
 * is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_complaint_id Uniquely identifies the Parent Complaint record.
 * @param p_stage Alternate Dispute Resolution Stage. Valid values are defined
 * by 'GHR_US_STAGE' lookup type.
 * @param p_start_date {@rep:casecolumn GHR_COMPL_ADRS.START_DATE}
 * @param p_end_date {@rep:casecolumn GHR_COMPL_ADRS.END_DATE}
 * @param p_adr_resource Alternate Dispute Resolution Resource. Valid values
 * are defined by 'GHR_US_ADR_RESOURCE' lookup type.
 * @param p_technique Alternate Dispute Resolution Technique. Valid values are
 * defined by 'GHR_US_ADR_TECHNIQUE' lookup type.
 * @param p_outcome Alternate Dispute Resolution Outcome. Valid values are
 * defined by 'GHR_US_ADR_OUTCOME' lookup type.
 * @param p_adr_offered Alternate Dispute Resolution Offered to Complainant.
 * Valid values are defined by 'GHR_US_ADR_OFFERED' lookup type.
 * @param p_date_accepted {@rep:casecolumn GHR_COMPL_ADRS.DATE_ACCEPTED}
 * @param p_compl_adr_id If p_validate is false, then this uniquely identifies
 * the Alternate Dispute Resolution created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Alternate Dispute Resolution. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Alternate Dispute Resolution
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_compl_adr
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_complaint_id                   in     number
  ,p_stage                          in     varchar2 default null
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_adr_resource                   in     varchar2 default null
  ,p_technique                      in     varchar2 default null
  ,p_outcome                        in     varchar2 default null
  ,p_adr_offered                    in     varchar2 default null
  ,p_date_accepted                  in     date     default null
  ,p_compl_adr_id                      out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_compl_adr >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Complaints Tracking Alternate Dispute Resolution record.
 *
 * This API updates a child Alternate Dispute Resolution record in table
 * ghr_compl_adrs for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Complaint record must exist in ghr_complaints2.
 *
 * <p><b>Post Success</b><br>
 * The API Updates an Alternate Dispute Resolution record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Alternate Dispute Resolution record and an error
 * is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_compl_adr_id Uniquely identifies the Alternate Dispute Resolution
 * record to be updated.
 * @param p_complaint_id Uniquely identifies the Parent Complaint record.
 * @param p_stage Alternate Dispute Resolution Stage. Valid values are defined
 * by 'GHR_US_STAGE' lookup type.
 * @param p_start_date {@rep:casecolumn GHR_COMPL_ADRS.START_DATE}
 * @param p_end_date {@rep:casecolumn GHR_COMPL_ADRS.END_DATE}
 * @param p_adr_resource Alternate Dispute Resolution Resource. Valid values
 * are defined by 'GHR_US_ADR_RESOURCE' lookup type.
 * @param p_technique Alternate Dispute Resolution Technique. Valid values are
 * defined by 'GHR_US_ADR_TECHNIQUE' lookup type.
 * @param p_outcome Alternate Dispute Resolution Outcome. Valid values are
 * defined by 'GHR_US_ADR_OUTCOME' lookup type.
 * @param p_adr_offered Alternate Dispute Resolution Offered to Complainant.
 * Valid values are defined by 'GHR_US_ADR_OFFERED' lookup type.
 * @param p_date_accepted {@rep:casecolumn GHR_COMPL_ADRS.DATE_ACCEPTED}
 * @param p_object_version_number Pass in the current version number of the
 * Alternate Dispute Resolution to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Alternate Dispute Resolution. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Update Alternate Dispute Resolution
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_compl_adr
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_compl_adr_id                 in     number
  ,p_complaint_id                 in     number    default hr_api.g_number
  ,p_stage                        in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_adr_resource                 in     varchar2  default hr_api.g_varchar2
  ,p_technique                    in     varchar2  default hr_api.g_varchar2
  ,p_outcome                      in     varchar2  default hr_api.g_varchar2
  ,p_adr_offered                  in     varchar2  default hr_api.g_varchar2
  ,p_date_accepted                in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
   );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_compl_adr >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Complaints Tracking Alternate Dispute Resolution record.
 *
 * This API deletes a child Alternate Dispute Resolution record from table
 * ghr_compl_adrs for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Alternate Dispute Resolution record specified must exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the Alternate Dispute Resolution record from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Alternate Dispute Resolution record and an error
 * is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_compl_adr_id Uniquely identifies the Alternate Dispute Resolution
 * record to be deleted.
 * @param p_object_version_number Current version number of the Alternate
 * Dispute Resolution to be deleted.
 * @rep:displayname Delete Alternate Dispute Resolution
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_compl_adr
  (p_validate                      in     boolean  default false
  ,p_compl_adr_id                  in     number
  ,p_object_version_number         in     number
  );

end ghr_complaint_adrs_api;

 

/
