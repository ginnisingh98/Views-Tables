--------------------------------------------------------
--  DDL for Package HR_SA_PERIODS_OF_SERVICE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SA_PERIODS_OF_SERVICE_API" AUTHID CURRENT_USER as
/* $Header: pepdssai.pkh 120.1 2005/10/02 02:20:11 aroussel $ */
/*#
 * This package contains period of service APIs for Saudi Arabia.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Period of Service for Saudi Arabia
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_sa_pds_details >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a period of service for an employee in a Saudi Arabia
 * business group.
 *
 * The API calls the generic API update_pds_details, with parameters set as
 * appropriate for the Saudi person. As this API is effectively an alternative
 * to the API update_pds_details, see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API update_pds_details
 *
 * <p><b>Post Success</b><br>
 * The period of service record is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the period of service record and raises an error.
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
 * @param p_hijrah_termination_date Termination date according to the Hijrah
 * calendar.
 * @rep:displayname Update Period of Service for Saudi Arabia
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_sa_pds_details
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
  ,p_hijrah_termination_date       in varchar2     default hr_api.g_varchar2
   );
--
end hr_sa_periods_of_service_api;

 

/
