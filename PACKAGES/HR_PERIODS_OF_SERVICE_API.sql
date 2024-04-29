--------------------------------------------------------
--  DDL for Package HR_PERIODS_OF_SERVICE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERIODS_OF_SERVICE_API" AUTHID CURRENT_USER as
/* $Header: pepdsapi.pkh 120.7 2007/04/19 06:04:29 pdkundu noship $ */
/*#
 * This package contains Period of Service APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Periods of Service
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_pds_details >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates period of service information for an employee.
 *
 * Typically, this API is used to update the flexfields associated with periods
 * of service.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee must exist in the relevant business group on the effective
 * date.
 *
 * <p><b>Post Success</b><br>
 * The period of service record is updated successfully.
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
 * @param p_actual_termination_date Actual termination date.
 * @param p_last_standard_process_date Last standard process date.
 * @param p_final_process_date Final process date.
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
 * @param p_pds_information_category This context value determines which
 * flexfield structure to use with the developer descriptive flexfield
 * segments.
 * @param p_pds_information1 Developer Descriptive flexfield segment.
 * @param p_pds_information2 Developer Descriptive flexfield segment.
 * @param p_pds_information3 Developer Descriptive flexfield segment.
 * @param p_pds_information4 Developer Descriptive flexfield segment.
 * @param p_pds_information5 Developer Descriptive flexfield segment.
 * @param p_pds_information6 Developer Descriptive flexfield segment.
 * @param p_pds_information7 Developer Descriptive flexfield segment.
 * @param p_pds_information8 Developer Descriptive flexfield segment.
 * @param p_pds_information9 Developer Descriptive flexfield segment.
 * @param p_pds_information10 Developer Descriptive flexfield segment.
 * @param p_pds_information11 Developer Descriptive flexfield segment.
 * @param p_pds_information12 Developer Descriptive flexfield segment.
 * @param p_pds_information13 Developer Descriptive flexfield segment.
 * @param p_pds_information14 Developer Descriptive flexfield segment.
 * @param p_pds_information15 Developer Descriptive flexfield segment.
 * @param p_pds_information16 Developer Descriptive flexfield segment.
 * @param p_pds_information17 Developer Descriptive flexfield segment.
 * @param p_pds_information18 Developer Descriptive flexfield segment.
 * @param p_pds_information19 Developer Descriptive flexfield segment.
 * @param p_pds_information20 Developer Descriptive flexfield segment.
 * @param p_pds_information21 Developer Descriptive flexfield segment.
 * @param p_pds_information22 Developer Descriptive flexfield segment.
 * @param p_pds_information23 Developer Descriptive flexfield segment.
 * @param p_pds_information24 Developer Descriptive flexfield segment.
 * @param p_pds_information25 Developer Descriptive flexfield segment.
 * @param p_pds_information26 Developer Descriptive flexfield segment.
 * @param p_pds_information27 Developer Descriptive flexfield segment.
 * @param p_pds_information28 Developer Descriptive flexfield segment.
 * @param p_pds_information29 Developer Descriptive flexfield segment.
 * @param p_pds_information30 Developer Descriptive flexfield segment.
 * @param p_org_now_no_manager_warning Warning flag to indicate the
 * organization not having a manager scenario.
 * @param p_asg_future_changes_warning Warning flag to indicate that
 * futrure changes exist.
 * @param p_entries_changed_warning Warning flag to indicate that
 * entries have changed as a result of the action.
 * @rep:displayname Update Period of Service
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_pds_details
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
  ,p_actual_termination_date       in     date     default hr_api.g_date
  ,p_last_standard_process_date    in     date     default hr_api.g_date
  ,p_final_process_date            in     date     default hr_api.g_date
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
  ,p_pds_information_category      in varchar2     default hr_api.g_varchar2
  ,p_pds_information1              in varchar2     default hr_api.g_varchar2
  ,p_pds_information2              in varchar2     default hr_api.g_varchar2
  ,p_pds_information3              in varchar2     default hr_api.g_varchar2
  ,p_pds_information4              in varchar2     default hr_api.g_varchar2
  ,p_pds_information5              in varchar2     default hr_api.g_varchar2
  ,p_pds_information6              in varchar2     default hr_api.g_varchar2
  ,p_pds_information7              in varchar2     default hr_api.g_varchar2
  ,p_pds_information8              in varchar2     default hr_api.g_varchar2
  ,p_pds_information9              in varchar2     default hr_api.g_varchar2
  ,p_pds_information10             in varchar2     default hr_api.g_varchar2
  ,p_pds_information11             in varchar2     default hr_api.g_varchar2
  ,p_pds_information12             in varchar2     default hr_api.g_varchar2
  ,p_pds_information13             in varchar2     default hr_api.g_varchar2
  ,p_pds_information14             in varchar2     default hr_api.g_varchar2
  ,p_pds_information15             in varchar2     default hr_api.g_varchar2
  ,p_pds_information16             in varchar2     default hr_api.g_varchar2
  ,p_pds_information17             in varchar2     default hr_api.g_varchar2
  ,p_pds_information18             in varchar2     default hr_api.g_varchar2
  ,p_pds_information19             in varchar2     default hr_api.g_varchar2
  ,p_pds_information20             in varchar2     default hr_api.g_varchar2
  ,p_pds_information21             in varchar2     default hr_api.g_varchar2
  ,p_pds_information22             in varchar2     default hr_api.g_varchar2
  ,p_pds_information23             in varchar2     default hr_api.g_varchar2
  ,p_pds_information24             in varchar2     default hr_api.g_varchar2
  ,p_pds_information25             in varchar2     default hr_api.g_varchar2
  ,p_pds_information26             in varchar2     default hr_api.g_varchar2
  ,p_pds_information27             in varchar2     default hr_api.g_varchar2
  ,p_pds_information28             in varchar2     default hr_api.g_varchar2
  ,p_pds_information29             in varchar2     default hr_api.g_varchar2
  ,p_pds_information30             in varchar2     default hr_api.g_varchar2
--
-- 115.9 (START)
--
  ,p_org_now_no_manager_warning    OUT NOCOPY      BOOLEAN
  ,p_asg_future_changes_warning    OUT NOCOPY      BOOLEAN
  ,p_entries_changed_warning       OUT NOCOPY      VARCHAR2
--
-- 115.9 (END)
--
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_pds_details (overloaded) >------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:   This procedure has been overloaded. Please use the new
--                version for all future work.
--
-- {End Of Comments}
--
procedure update_pds_details
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
  ,p_actual_termination_date       in     date     default hr_api.g_date
  ,p_last_standard_process_date    in     date     default hr_api.g_date
  ,p_final_process_date            in     date     default hr_api.g_date
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
  ,p_pds_information_category      in varchar2     default hr_api.g_varchar2
  ,p_pds_information1              in varchar2     default hr_api.g_varchar2
  ,p_pds_information2              in varchar2     default hr_api.g_varchar2
  ,p_pds_information3              in varchar2     default hr_api.g_varchar2
  ,p_pds_information4              in varchar2     default hr_api.g_varchar2
  ,p_pds_information5              in varchar2     default hr_api.g_varchar2
  ,p_pds_information6              in varchar2     default hr_api.g_varchar2
  ,p_pds_information7              in varchar2     default hr_api.g_varchar2
  ,p_pds_information8              in varchar2     default hr_api.g_varchar2
  ,p_pds_information9              in varchar2     default hr_api.g_varchar2
  ,p_pds_information10             in varchar2     default hr_api.g_varchar2
  ,p_pds_information11             in varchar2     default hr_api.g_varchar2
  ,p_pds_information12             in varchar2     default hr_api.g_varchar2
  ,p_pds_information13             in varchar2     default hr_api.g_varchar2
  ,p_pds_information14             in varchar2     default hr_api.g_varchar2
  ,p_pds_information15             in varchar2     default hr_api.g_varchar2
  ,p_pds_information16             in varchar2     default hr_api.g_varchar2
  ,p_pds_information17             in varchar2     default hr_api.g_varchar2
  ,p_pds_information18             in varchar2     default hr_api.g_varchar2
  ,p_pds_information19             in varchar2     default hr_api.g_varchar2
  ,p_pds_information20             in varchar2     default hr_api.g_varchar2
  ,p_pds_information21             in varchar2     default hr_api.g_varchar2
  ,p_pds_information22             in varchar2     default hr_api.g_varchar2
  ,p_pds_information23             in varchar2     default hr_api.g_varchar2
  ,p_pds_information24             in varchar2     default hr_api.g_varchar2
  ,p_pds_information25             in varchar2     default hr_api.g_varchar2
  ,p_pds_information26             in varchar2     default hr_api.g_varchar2
  ,p_pds_information27             in varchar2     default hr_api.g_varchar2
  ,p_pds_information28             in varchar2     default hr_api.g_varchar2
  ,p_pds_information29             in varchar2     default hr_api.g_varchar2
  ,p_pds_information30             in varchar2     default hr_api.g_varchar2
   );
--
-- 115.7 (START)
--
-- ----------------------------------------------------------------------------
-- |--------------------------< MOVE_TERM_ASSIGNMENTS >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:   This procedure keeps assignment children and the TERM_ASSIGN
--                record in sync with any allowable change in FPD. It also
--                validates that the change does not adversely impact any of
--                the child records.
--
-- Prerequisites: None
--
--
-- In Parameters:
--   Name                       Reqd Type     Description
--   P_PERIOD_OF_SERVICE_ID     Yes  NUMBER   PDS Identifier
--   P_OLD_FINAL_PROCESS_DATE   Yes  DATE     Old FPD
--   P_NEW_FINAL_PROCESS_DATE   Yes  DATE     New FPD
--
-- Out Parameters:
--   Name                          Type     Description
--   P_ORG_NOW_NO_MANAGER_WARNING  BOOLEAN  Org now no manager flag
--   P_ASG_FUTURE_CHANGES_WARNING  BOOLEAN  Future Assignment changes flag
--   P_ENTRIES_CHANGED_WARNING     VARCHAR2 Element entries changed flag
--
-- Post Success:
--   The TERM_ASSIGN assignment record and its children will be in sync with
--   the Final Process Date on the Period Of Service associated with that
--   assignment.
--
--   Name                           Type     Description
--   -                              -        -
-- Post Failure:
--   An exception will be raised depending on the nature of failure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure move_term_assignments
  (p_period_of_service_id   in number
  ,p_old_final_process_date in date
  ,p_new_final_process_date in date
--
-- 115.9 (START)
--
  ,p_org_now_no_manager_warning OUT NOCOPY BOOLEAN
  ,p_asg_future_changes_warning OUT NOCOPY BOOLEAN
  ,p_entries_changed_warning    OUT NOCOPY VARCHAR2
--
-- 115.9 (END)
--
  );
--
-- 115.7 (END)
--
end hr_periods_of_service_api;

/
