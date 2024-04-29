--------------------------------------------------------
--  DDL for Package HR_FR_PERIODS_OF_SERVICE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FR_PERIODS_OF_SERVICE_API" AUTHID CURRENT_USER as
/* $Header: pepdsfri.pkh 120.1 2005/10/02 02:20:00 aroussel $ */
/*#
 * This package contains a period of service API for France.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Periods of Service for France
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_fr_pds_details >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the periods of service details for an employee for France.
 *
 * This API is an alternative API to the generic update_pds_details, see
 * generic update_pds_details for further details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The periods of service API is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API will not update the period of service record and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_period_of_service_id Period of service that is being terminated.
 * @param p_termination_accepted_person Person who accepted this termination.
 * @param p_accepted_termination_date Date when the termination of employment
 * was accepted
 * @param p_object_version_number Pass in the current version number of the
 * period of service to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated period of
 * service. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_comments Comment text.
 * @param p_leaving_reason Termination Reason. Valid values are defined by the
 * LEAV_REAS lookup type.
 * @param p_notified_termination_date Date when the termination was notified.
 * @param p_projected_termination_date Projected termination date.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
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
 * @param p_starting_reason Starting reason. Valid values exist in the
 * 'FR_STARTING_REASON' lookup type.
 * @param p_ending_reason Ending reason. Valid values exist in the
 * 'FR_ENDING_REASON' lookup type.
 * @param p_qualification_level Qualification level. Valid values exist in the
 * 'FR_LEVEL_OF_WORKER' lookup type.
 * @param p_type_work Type of work. Valid values exist in the
 * 'FR_TYPE_OF_WORKER' lookup type.
 * @param p_employee_status Employee status. Valid values exist in the
 * 'FR_EMPLOYEE_STATUS' lookup type.
 * @param p_affiliated_alsace_moselle Affiliated Alsace Moselle DSS (Y/N)
 * @param p_relationship_md Relationship with managing director. Valid values
 * exist in the 'CONTACT' lookup type.
 * @param p_final_payment_schedule Final payment schedule. Valid values exist
 * in the 'FR_FINAL_PAYMENT_TYPES' lookup type.
 * @param p_social_plan Covered By Social Plan (Y/N)
 * @rep:displayname Update Period of Service for France
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_fr_pds_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_termination_accepted_person   in     number   default hr_api.g_number
  ,p_accepted_termination_date     in     date     default hr_api.g_date
  ,p_object_version_number         in out nocopy number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_notified_termination_date     in     date     default hr_api.g_date
  ,p_projected_termination_date    in     date     default hr_api.g_date
  ,p_attribute_category            in varchar2     default hr_api.g_varchar2
  ,p_attribute1                    in varchar2     default hr_api.g_varchar2
  ,p_attribute2                    in varchar2     default hr_api.g_varchar2
  ,p_attribute3                    in varchar2     default hr_api.g_varchar2
  ,p_attribute4                    in varchar2     default hr_api.g_varchar2
  ,p_attribute5                    in varchar2     default hr_api.g_varchar2
  ,p_attribute6                    in varchar2     default hr_api.g_varchar2
  ,p_attribute7                    in varchar2     default hr_api.g_varchar2
  ,p_attribute8                    in varchar2     default hr_api.g_varchar2
  ,p_attribute9                    in varchar2     default hr_api.g_varchar2
  ,p_attribute10                   in varchar2     default hr_api.g_varchar2
  ,p_attribute11                   in varchar2     default hr_api.g_varchar2
  ,p_attribute12                   in varchar2     default hr_api.g_varchar2
  ,p_attribute13                   in varchar2     default hr_api.g_varchar2
  ,p_attribute14                   in varchar2     default hr_api.g_varchar2
  ,p_attribute15                   in varchar2     default hr_api.g_varchar2
  ,p_attribute16                   in varchar2     default hr_api.g_varchar2
  ,p_attribute17                   in varchar2     default hr_api.g_varchar2
  ,p_attribute18                   in varchar2     default hr_api.g_varchar2
  ,p_attribute19                   in varchar2     default hr_api.g_varchar2
  ,p_attribute20                   in varchar2     default hr_api.g_varchar2
  ,p_starting_reason               in varchar2     default hr_api.g_varchar2
  ,p_ending_reason                 in varchar2     default hr_api.g_varchar2
  ,p_qualification_level           in varchar2     default hr_api.g_varchar2
  ,p_type_work                     in varchar2     default hr_api.g_varchar2
  ,p_employee_status               in varchar2     default hr_api.g_varchar2
  ,p_affiliated_alsace_moselle     in varchar2     default hr_api.g_varchar2
  ,p_relationship_MD               in varchar2     default hr_api.g_varchar2
  ,p_final_payment_schedule        in varchar2     default hr_api.g_varchar2
  ,p_social_plan                   in varchar2     default hr_api.g_varchar2
  );
--
end hr_fr_periods_of_service_api;

 

/
