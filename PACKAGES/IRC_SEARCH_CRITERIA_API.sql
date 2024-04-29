--------------------------------------------------------
--  DDL for Package IRC_SEARCH_CRITERIA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_SEARCH_CRITERIA_API" AUTHID CURRENT_USER as
/* $Header: iriscapi.pkh 120.2 2008/02/21 14:24:29 viviswan noship $ */
/*#
 * This package contains APIs for work preferences, job searches and vacancy
 * criteria.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Search Criteria
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_saved_search >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API stores a saved job search for a candidate.
 *
 * The saved search may be used by the candidate to repeatedly search for jobs
 * with the same criteria.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist
 *
 * <p><b>Post Success</b><br>
 * The saved search will be created in the database
 *
 * <p><b>Post Failure</b><br>
 * The saved search will not be created in the database and an error will be
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_person_id Identifies the person for whom you create the saved job
 * search record.
 * @param p_search_name Name of saved search
 * @param p_location Free text location a person is interested in
 * @param p_distance_to_location Distance in miles the user is willing to
 * travel to work.
 * @param p_geocode_location Location for a geocode search
 * @param p_geocode_country Country for a geocode search
 * @param p_derived_location Exact derived locale to match on
 * @param p_location_id Identifies a location to match on
 * @param p_longitude Longitude for a geocode search
 * @param p_latitude Latitude for a geocode search
 * @param p_employee Indicates that the candidate is looking for an employee
 * job (Y or N)
 * @param p_contractor Indicates that the candidate is looking for a contract
 * job (Y or N)
 * @param p_employment_category Indicates whether the candidate is looking for
 * a full time or part time job (FULLTIME, PARTTIME or EITHER)
 * @param p_keywords Free text keywords for the search
 * @param p_travel_percentage Percentage of time a person is willing to spend
 * travelling. Valid values are defined by 'IRC_TRAVEL_PERCENTAGE' lookup type.
 * @param p_min_salary Minimum salary user is willing to accept.
 * @param p_salary_currency Salary currency
 * @param p_salary_period Salary period. Valid values are defined by
 * 'PAY_BASIS' lookup type.
 * @param p_match_competence Identifies if user wishes to match jobs against
 * the competencies he has entered (Y or N)
 * @param p_match_qualification Identifies if user wishes to match jobs against
 * the qualification he has entered (Y or N)
 * @param p_work_at_home Indicates how desirable it is to work at home. Valid
 * values are defined by 'IRC_WORK_AT_HOME' lookup type.
 * @param p_job_title Title of job the user wishes to be included in search.
 * @param p_department Reserved for future use
 * @param p_professional_area Professional area user wishes to work in. Valid
 * values are defined by 'IRC_PROFESSIONAL_AREA' lookup type.
 * @param p_use_for_matching Indicated whether a saved search is to be used for
 * job matching purposes (Y or N)
 * @param p_description Search Description
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_isc_information_category Developer Descriptive flexfield segment.
 * @param p_isc_information1 Developer Descriptive flexfield segment.
 * @param p_isc_information2 Developer Descriptive flexfield segment.
 * @param p_isc_information3 Developer Descriptive flexfield segment.
 * @param p_isc_information4 Developer Descriptive flexfield segment.
 * @param p_isc_information5 Developer Descriptive flexfield segment.
 * @param p_isc_information6 Developer Descriptive flexfield segment.
 * @param p_isc_information7 Developer Descriptive flexfield segment.
 * @param p_isc_information8 Developer Descriptive flexfield segment.
 * @param p_isc_information9 Developer Descriptive flexfield segment.
 * @param p_isc_information10 Developer Descriptive flexfield segment.
 * @param p_isc_information11 Developer Descriptive flexfield segment.
 * @param p_isc_information12 Developer Descriptive flexfield segment.
 * @param p_isc_information13 Developer Descriptive flexfield segment.
 * @param p_isc_information14 Developer Descriptive flexfield segment.
 * @param p_isc_information15 Developer Descriptive flexfield segment.
 * @param p_isc_information16 Developer Descriptive flexfield segment.
 * @param p_isc_information17 Developer Descriptive flexfield segment.
 * @param p_isc_information18 Developer Descriptive flexfield segment.
 * @param p_isc_information19 Developer Descriptive flexfield segment.
 * @param p_isc_information20 Developer Descriptive flexfield segment.
 * @param p_isc_information21 Developer Descriptive flexfield segment.
 * @param p_isc_information22 Developer Descriptive flexfield segment.
 * @param p_isc_information23 Developer Descriptive flexfield segment.
 * @param p_isc_information24 Developer Descriptive flexfield segment.
 * @param p_isc_information25 Developer Descriptive flexfield segment.
 * @param p_isc_information26 Developer Descriptive flexfield segment.
 * @param p_isc_information27 Developer Descriptive flexfield segment.
 * @param p_isc_information28 Developer Descriptive flexfield segment.
 * @param p_isc_information29 Developer Descriptive flexfield segment.
 * @param p_isc_information30 Developer Descriptive flexfield segment.
 * @param p_date_posted Indicates how old jobs may be to be included in the
 * search
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created saved search. If p_validate is true, then the
 * value will be null.
 * @param p_search_criteria_id If p_validate is false, then this uniquely
 * identifies the saved search created. If p_validate is true, then set to
 * null.
 * @rep:displayname Create Saved Search
 * @rep:category BUSINESS_ENTITY IRC_CANDIDATE_SAVED_SEARCH
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_saved_search
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_search_name                   in     varchar2
  ,p_location                      in     varchar2 default null
  ,p_distance_to_location          in     varchar2 default null
  ,p_geocode_location              in     varchar2 default null
  ,p_geocode_country               in     varchar2 default null
  ,p_derived_location              in     varchar2 default null
  ,p_location_id                   in     number   default null
  ,p_longitude                     in     number   default null
  ,p_latitude                      in     number   default null
  ,p_employee                      in     varchar2 default null
  ,p_contractor                    in     varchar2 default null
  ,p_employment_category           in     varchar2 default 'EITHER'
  ,p_keywords                      in     varchar2 default null
  ,p_travel_percentage             in     number   default null
  ,p_min_salary                    in     number   default null
  ,p_salary_currency               in     varchar2 default null
  ,p_salary_period                 in     varchar2 default null
  ,p_match_competence              in     varchar2 default 'N'
  ,p_match_qualification           in     varchar2 default 'N'
  ,p_work_at_home                  in     varchar2 default 'POSSIBLE'
  ,p_job_title                     in     varchar2 default null
  ,p_department                    in     varchar2 default null
  ,p_professional_area             in     varchar2 default null
  ,p_use_for_matching              in     varchar2 default 'N'
  ,p_description                   in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_isc_information_category      in     varchar2 default null
  ,p_isc_information1              in     varchar2 default null
  ,p_isc_information2              in     varchar2 default null
  ,p_isc_information3              in     varchar2 default null
  ,p_isc_information4              in     varchar2 default null
  ,p_isc_information5              in     varchar2 default null
  ,p_isc_information6              in     varchar2 default null
  ,p_isc_information7              in     varchar2 default null
  ,p_isc_information8              in     varchar2 default null
  ,p_isc_information9              in     varchar2 default null
  ,p_isc_information10             in     varchar2 default null
  ,p_isc_information11             in     varchar2 default null
  ,p_isc_information12             in     varchar2 default null
  ,p_isc_information13             in     varchar2 default null
  ,p_isc_information14             in     varchar2 default null
  ,p_isc_information15             in     varchar2 default null
  ,p_isc_information16             in     varchar2 default null
  ,p_isc_information17             in     varchar2 default null
  ,p_isc_information18             in     varchar2 default null
  ,p_isc_information19             in     varchar2 default null
  ,p_isc_information20             in     varchar2 default null
  ,p_isc_information21             in     varchar2 default null
  ,p_isc_information22             in     varchar2 default null
  ,p_isc_information23             in     varchar2 default null
  ,p_isc_information24             in     varchar2 default null
  ,p_isc_information25             in     varchar2 default null
  ,p_isc_information26             in     varchar2 default null
  ,p_isc_information27             in     varchar2 default null
  ,p_isc_information28             in     varchar2 default null
  ,p_isc_information29             in     varchar2 default null
  ,p_isc_information30             in     varchar2 default null
  ,p_date_posted                   in     varchar2 default null
  ,p_object_version_number           out nocopy number
  ,p_search_criteria_id              out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_saved_search >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a saved job search for a candidate.
 *
 * The saved search may be used by the candidate to repeatedly search for jobs
 * with the same criteria.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The saved search must exist in the database
 *
 * <p><b>Post Success</b><br>
 * The saved search criteria will be updated
 *
 * <p><b>Post Failure</b><br>
 * The saved search criteria will not be updated and error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_search_criteria_id Identifies the saved search to be updated
 * @param p_person_id Identifies the person for whom you update the saved
 * search record.
 * @param p_search_name Name of saved search
 * @param p_location Free text location a person is interested in
 * @param p_distance_to_location Distance in miles the user is willing to
 * travel to work.
 * @param p_geocode_location Location for a geocode search
 * @param p_geocode_country Country for a geocode search
 * @param p_derived_location Exact derived locale to match on
 * @param p_location_id Identifies a location to match on
 * @param p_longitude Longitude for a geocode search
 * @param p_latitude Latitude for a geocode search
 * @param p_employee Indicates that the candidate is looking for an employee
 * job (Y or N)
 * @param p_contractor Indicates that the candidate is looking for a contract
 * job (Y or N)
 * @param p_employment_category Indicates whether the candidate is looking for
 * a full time or part time job (FULLTIME, PARTTIME or EITHER)
 * @param p_keywords Free text keywords for the search
 * @param p_travel_percentage Percentage of time a person is willing to spend
 * travelling. Valid values are defined by 'IRC_TRAVEL_PERCENTAGE' lookup type.
 * @param p_min_salary Minimum salary user is willing to accept.
 * @param p_salary_currency Salary currency
 * @param p_salary_period Salary period. Valid values are defined by
 * 'PAY_BASIS' lookup type.
 * @param p_match_competence Identifies if user wishes to match jobs against
 * the competencies he has entered (Y or N)
 * @param p_match_qualification Identifies if user wishes to match jobs against
 * the qualification he has entered (Y or N)
 * @param p_work_at_home Indicates how desirable it is to work at home. Valid
 * values are defined by 'IRC_WORK_AT_HOME' lookup type.
 * @param p_job_title Title of job the user wishes to be included in search.
 * @param p_department Reserved for future use
 * @param p_professional_area Professional area user wishes to work in. Valid
 * values are defined by 'IRC_PROFESSIONAL_AREA' lookup type.
 * @param p_use_for_matching Indicated whether a saved search is to be used for
 * job matching purposes (Y or N)
 * @param p_description Search Description
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_isc_information_category Developer Descriptive flexfield segment.
 * @param p_isc_information1 Developer Descriptive flexfield segment.
 * @param p_isc_information2 Developer Descriptive flexfield segment.
 * @param p_isc_information3 Developer Descriptive flexfield segment.
 * @param p_isc_information4 Developer Descriptive flexfield segment.
 * @param p_isc_information5 Developer Descriptive flexfield segment.
 * @param p_isc_information6 Developer Descriptive flexfield segment.
 * @param p_isc_information7 Developer Descriptive flexfield segment.
 * @param p_isc_information8 Developer Descriptive flexfield segment.
 * @param p_isc_information9 Developer Descriptive flexfield segment.
 * @param p_isc_information10 Developer Descriptive flexfield segment.
 * @param p_isc_information11 Developer Descriptive flexfield segment.
 * @param p_isc_information12 Developer Descriptive flexfield segment.
 * @param p_isc_information13 Developer Descriptive flexfield segment.
 * @param p_isc_information14 Developer Descriptive flexfield segment.
 * @param p_isc_information15 Developer Descriptive flexfield segment.
 * @param p_isc_information16 Developer Descriptive flexfield segment.
 * @param p_isc_information17 Developer Descriptive flexfield segment.
 * @param p_isc_information18 Developer Descriptive flexfield segment.
 * @param p_isc_information19 Developer Descriptive flexfield segment.
 * @param p_isc_information20 Developer Descriptive flexfield segment.
 * @param p_isc_information21 Developer Descriptive flexfield segment.
 * @param p_isc_information22 Developer Descriptive flexfield segment.
 * @param p_isc_information23 Developer Descriptive flexfield segment.
 * @param p_isc_information24 Developer Descriptive flexfield segment.
 * @param p_isc_information25 Developer Descriptive flexfield segment.
 * @param p_isc_information26 Developer Descriptive flexfield segment.
 * @param p_isc_information27 Developer Descriptive flexfield segment.
 * @param p_isc_information28 Developer Descriptive flexfield segment.
 * @param p_isc_information29 Developer Descriptive flexfield segment.
 * @param p_isc_information30 Developer Descriptive flexfield segment.
 * @param p_date_posted Indicates how old jobs may be to be included in the
 * search
 * @param p_object_version_number Pass in the current version number of the
 * saved search to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated saved search. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Saved Search
 * @rep:category BUSINESS_ENTITY IRC_CANDIDATE_SAVED_SEARCH
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_saved_search
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_search_criteria_id            in     number
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_search_name                   in     varchar2 default hr_api.g_varchar2
  ,p_location                      in     varchar2 default hr_api.g_varchar2
  ,p_distance_to_location          in     varchar2 default hr_api.g_varchar2
  ,p_geocode_location              in     varchar2 default hr_api.g_varchar2
  ,p_geocode_country               in     varchar2 default hr_api.g_varchar2
  ,p_derived_location              in     varchar2 default hr_api.g_varchar2
  ,p_location_id                   in     number   default hr_api.g_number
  ,p_longitude                     in     number   default hr_api.g_number
  ,p_latitude                      in     number   default hr_api.g_number
  ,p_employee                      in     varchar2 default hr_api.g_varchar2
  ,p_contractor                    in     varchar2 default hr_api.g_varchar2
  ,p_employment_category           in     varchar2 default hr_api.g_varchar2
  ,p_keywords                      in     varchar2 default hr_api.g_varchar2
  ,p_travel_percentage             in     number   default hr_api.g_number
  ,p_min_salary                    in     number   default hr_api.g_number
  ,p_salary_currency               in     varchar2 default hr_api.g_varchar2
  ,p_salary_period                 in     varchar2 default hr_api.g_varchar2
  ,p_match_competence              in     varchar2 default hr_api.g_varchar2
  ,p_match_qualification           in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home                  in     varchar2 default hr_api.g_varchar2
  ,p_job_title                     in     varchar2 default hr_api.g_varchar2
  ,p_department                    in     varchar2 default hr_api.g_varchar2
  ,p_professional_area             in     varchar2 default hr_api.g_varchar2
  ,p_use_for_matching              in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_isc_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_isc_information1              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information2              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information3              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information4              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information5              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information6              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information7              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information8              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information9              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information10             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information11             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information12             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information13             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information14             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information15             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information16             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information17             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information18             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information19             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information20             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information21             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information22             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information23             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information24             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information25             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information26             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information27             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information28             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information29             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information30             in     varchar2 default hr_api.g_varchar2
  ,p_date_posted                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_saved_search >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a saved search.
 *
 * The saved search will no longer be available to the user for searching or
 * automatic job matching.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The saved search must exist in the database
 *
 * <p><b>Post Success</b><br>
 * The saved search will be deleted from the database
 *
 * <p><b>Post Failure</b><br>
 * The saved search will not be deleted and an error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_search_criteria_id Identifies the saved search to be deleted
 * @param p_object_version_number Current version number of the saved search to
 * be deleted.
 * @rep:displayname Delete Saved Search
 * @rep:category BUSINESS_ENTITY IRC_CANDIDATE_SAVED_SEARCH
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_saved_search
  (p_validate                      in     boolean  default false
  ,p_search_criteria_id            in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_vacancy_criteria >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates search criteria for a vacancy.
 *
 * The vacancy search criteria will be used for matching candidates to
 * vacancies.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The vacancy must exist
 *
 * <p><b>Post Success</b><br>
 * The vacancy search criteria will be created in the database
 *
 * <p><b>Post Failure</b><br>
 * The vacancy search criteria will not be created in the database and an error
 * will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_vacancy_id Identifies the vacancy that these criteria apply to
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_location Reserved for future use
 * @param p_employee Indicates that the vacancy is for an employee job (Y or N)
 * @param p_contractor Indicates that the vacancy is for a contract job (Y or
 * N)
 * @param p_employment_category Indicates whether the vacancy is for a full
 * time or part time job (FULLTIME, PARTTIME or EITHER)
 * @param p_keywords Reserved for future use
 * @param p_travel_percentage Percentage of time travelling that the vacancy
 * may involve. Valid values are defined by 'IRC_TRAVEL_PERCENTAGE' lookup
 * type.
 * @param p_min_salary Minimum salary for the vacancy
 * @param p_max_salary Maximum salary for the vacancy
 * @param p_salary_currency Salary Currency
 * @param p_salary_period Salary period. Valid values are defined by
 * 'PAY_BASIS' lookup type.
 * @param p_professional_area Professional area of the vacancy. Valid values
 * are defined by 'IRC_PROFESSIONAL_AREA' lookup type.
 * @param p_work_at_home Indicates how desirable it is to work at home. Valid
 * values are defined by 'IRC_WORK_AT_HOME' lookup type.
 * @param p_min_qual_level Minimum qualification level required for the
 * vacancy. Compared against the rank on PER_QUALIFICATION_TYPES
 * @param p_max_qual_level Maximum qualification level required for the
 * vacancy. Compared against the rank on PER_QUALIFICATION_TYPES
 * @param p_description Reserved for future use
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_isc_information_category Developer Descriptive flexfield segment.
 * @param p_isc_information1 Developer Descriptive flexfield segment.
 * @param p_isc_information2 Developer Descriptive flexfield segment.
 * @param p_isc_information3 Developer Descriptive flexfield segment.
 * @param p_isc_information4 Developer Descriptive flexfield segment.
 * @param p_isc_information5 Developer Descriptive flexfield segment.
 * @param p_isc_information6 Developer Descriptive flexfield segment.
 * @param p_isc_information7 Developer Descriptive flexfield segment.
 * @param p_isc_information8 Developer Descriptive flexfield segment.
 * @param p_isc_information9 Developer Descriptive flexfield segment.
 * @param p_isc_information10 Developer Descriptive flexfield segment.
 * @param p_isc_information11 Developer Descriptive flexfield segment.
 * @param p_isc_information12 Developer Descriptive flexfield segment.
 * @param p_isc_information13 Developer Descriptive flexfield segment.
 * @param p_isc_information14 Developer Descriptive flexfield segment.
 * @param p_isc_information15 Developer Descriptive flexfield segment.
 * @param p_isc_information16 Developer Descriptive flexfield segment.
 * @param p_isc_information17 Developer Descriptive flexfield segment.
 * @param p_isc_information18 Developer Descriptive flexfield segment.
 * @param p_isc_information19 Developer Descriptive flexfield segment.
 * @param p_isc_information20 Developer Descriptive flexfield segment.
 * @param p_isc_information21 Developer Descriptive flexfield segment.
 * @param p_isc_information22 Developer Descriptive flexfield segment.
 * @param p_isc_information23 Developer Descriptive flexfield segment.
 * @param p_isc_information24 Developer Descriptive flexfield segment.
 * @param p_isc_information25 Developer Descriptive flexfield segment.
 * @param p_isc_information26 Developer Descriptive flexfield segment.
 * @param p_isc_information27 Developer Descriptive flexfield segment.
 * @param p_isc_information28 Developer Descriptive flexfield segment.
 * @param p_isc_information29 Developer Descriptive flexfield segment.
 * @param p_isc_information30 Developer Descriptive flexfield segment.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created vacancy criteria. If p_validate is true, then
 * the value will be null.
 * @param p_search_criteria_id If p_validate is false, then this uniquely
 * identifies the vacancy criteria created. If p_validate is true, then set to
 * null.
 * @rep:displayname Create Vacancy Criteria
 * @rep:category BUSINESS_ENTITY PER_VACANCY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_vacancy_criteria
  (p_validate                      in     boolean  default false
  ,p_vacancy_id                    in     number
  ,p_effective_date                in     date
  ,p_location                      in     varchar2 default null
  ,p_employee                      in     varchar2 default null
  ,p_contractor                    in     varchar2 default null
  ,p_employment_category           in     varchar2 default null
  ,p_keywords                      in     varchar2 default null
  ,p_travel_percentage             in     number   default null
  ,p_min_salary                    in     number   default null
  ,p_max_salary                    in     number   default null
  ,p_salary_currency               in     varchar2 default null
  ,p_salary_period                 in     varchar2 default null
  ,p_professional_area             in     varchar2 default null
  ,p_work_at_home                  in     varchar2 default null
  ,p_min_qual_level                in     number   default null
  ,p_max_qual_level                in     number   default null
  ,p_description                   in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_isc_information_category      in     varchar2 default null
  ,p_isc_information1              in     varchar2 default null
  ,p_isc_information2              in     varchar2 default null
  ,p_isc_information3              in     varchar2 default null
  ,p_isc_information4              in     varchar2 default null
  ,p_isc_information5              in     varchar2 default null
  ,p_isc_information6              in     varchar2 default null
  ,p_isc_information7              in     varchar2 default null
  ,p_isc_information8              in     varchar2 default null
  ,p_isc_information9              in     varchar2 default null
  ,p_isc_information10             in     varchar2 default null
  ,p_isc_information11             in     varchar2 default null
  ,p_isc_information12             in     varchar2 default null
  ,p_isc_information13             in     varchar2 default null
  ,p_isc_information14             in     varchar2 default null
  ,p_isc_information15             in     varchar2 default null
  ,p_isc_information16             in     varchar2 default null
  ,p_isc_information17             in     varchar2 default null
  ,p_isc_information18             in     varchar2 default null
  ,p_isc_information19             in     varchar2 default null
  ,p_isc_information20             in     varchar2 default null
  ,p_isc_information21             in     varchar2 default null
  ,p_isc_information22             in     varchar2 default null
  ,p_isc_information23             in     varchar2 default null
  ,p_isc_information24             in     varchar2 default null
  ,p_isc_information25             in     varchar2 default null
  ,p_isc_information26             in     varchar2 default null
  ,p_isc_information27             in     varchar2 default null
  ,p_isc_information28             in     varchar2 default null
  ,p_isc_information29             in     varchar2 default null
  ,p_isc_information30             in     varchar2 default null
  ,p_object_version_number           out nocopy  number
  ,p_search_criteria_id              out nocopy  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_vacancy_criteria >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates search criteria for a vacancy.
 *
 * The vacancy search criteria will be used for matching candidates to
 * vacancies.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The vacancy search criteria must exist in the database
 *
 * <p><b>Post Success</b><br>
 * The vacancy criteria will be updated
 *
 * <p><b>Post Failure</b><br>
 * The vacancy criteria will not be updated and error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_search_criteria_id Identifies the vacancy criteria to be updated
 * @param p_vacancy_id Identifies the vacancy that these criteria apply to
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_location Reserved for future use
 * @param p_employee Indicates that the vacancy is for an employee job (Y or N)
 * @param p_contractor Indicates that the vacancy is for a contract job (Y or
 * N)
 * @param p_employment_category Indicates whether the vacancy is for a full
 * time or part time job (FULLTIME, PARTTIME or EITHER)
 * @param p_keywords Reserved for future use
 * @param p_travel_percentage Percentage of time travelling that the vacancy
 * may involve. Valid values are defined by 'IRC_TRAVEL_PERCENTAGE' lookup
 * type.
 * @param p_min_salary Minimum salary for the vacancy
 * @param p_max_salary Maximum salary for the vacancy
 * @param p_salary_currency Salary Currency
 * @param p_salary_period Salary period. Valid values are defined by
 * 'PAY_BASIS' lookup type.
 * @param p_professional_area Professional area of the vacancy. Valid values
 * are defined by 'IRC_PROFESSIONAL_AREA' lookup type.
 * @param p_work_at_home Indicates how desirable it is to work at home. Valid
 * values are defined by 'IRC_WORK_AT_HOME' lookup type.
 * @param p_min_qual_level Minimum qualification level required for the
 * vacancy. Compared against the rank on PER_QUALIFICATION_TYPES
 * @param p_max_qual_level Maximum qualification level required for the
 * vacancy. Compared against the rank on PER_QUALIFICATION_TYPES
 * @param p_description Reserved for future use
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_isc_information_category Developer Descriptive flexfield segment.
 * @param p_isc_information1 Developer Descriptive flexfield segment.
 * @param p_isc_information2 Developer Descriptive flexfield segment.
 * @param p_isc_information3 Developer Descriptive flexfield segment.
 * @param p_isc_information4 Developer Descriptive flexfield segment.
 * @param p_isc_information5 Developer Descriptive flexfield segment.
 * @param p_isc_information6 Developer Descriptive flexfield segment.
 * @param p_isc_information7 Developer Descriptive flexfield segment.
 * @param p_isc_information8 Developer Descriptive flexfield segment.
 * @param p_isc_information9 Developer Descriptive flexfield segment.
 * @param p_isc_information10 Developer Descriptive flexfield segment.
 * @param p_isc_information11 Developer Descriptive flexfield segment.
 * @param p_isc_information12 Developer Descriptive flexfield segment.
 * @param p_isc_information13 Developer Descriptive flexfield segment.
 * @param p_isc_information14 Developer Descriptive flexfield segment.
 * @param p_isc_information15 Developer Descriptive flexfield segment.
 * @param p_isc_information16 Developer Descriptive flexfield segment.
 * @param p_isc_information17 Developer Descriptive flexfield segment.
 * @param p_isc_information18 Developer Descriptive flexfield segment.
 * @param p_isc_information19 Developer Descriptive flexfield segment.
 * @param p_isc_information20 Developer Descriptive flexfield segment.
 * @param p_isc_information21 Developer Descriptive flexfield segment.
 * @param p_isc_information22 Developer Descriptive flexfield segment.
 * @param p_isc_information23 Developer Descriptive flexfield segment.
 * @param p_isc_information24 Developer Descriptive flexfield segment.
 * @param p_isc_information25 Developer Descriptive flexfield segment.
 * @param p_isc_information26 Developer Descriptive flexfield segment.
 * @param p_isc_information27 Developer Descriptive flexfield segment.
 * @param p_isc_information28 Developer Descriptive flexfield segment.
 * @param p_isc_information29 Developer Descriptive flexfield segment.
 * @param p_isc_information30 Developer Descriptive flexfield segment.
 * @param p_object_version_number Pass in the current version number of the
 * vacancy criteria to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated vacancy
 * criteria. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Vacancy Criteria
 * @rep:category BUSINESS_ENTITY PER_VACANCY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_vacancy_criteria
  (p_validate                      in     boolean  default false
  ,p_search_criteria_id            in     number
  ,p_vacancy_id                    in     number   default hr_api.g_number
  ,p_effective_date                in     date
  ,p_location                      in     varchar2 default hr_api.g_varchar2
  ,p_employee                      in     varchar2 default hr_api.g_varchar2
  ,p_contractor                    in     varchar2 default hr_api.g_varchar2
  ,p_employment_category           in     varchar2 default hr_api.g_varchar2
  ,p_keywords                      in     varchar2 default hr_api.g_varchar2
  ,p_travel_percentage             in     number   default hr_api.g_number
  ,p_min_salary                    in     number   default hr_api.g_number
  ,p_max_salary                    in     number   default hr_api.g_number
  ,p_salary_currency               in     varchar2 default hr_api.g_varchar2
  ,p_salary_period                 in     varchar2 default hr_api.g_varchar2
  ,p_professional_area             in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home                  in     varchar2 default hr_api.g_varchar2
  ,p_min_qual_level                in     number   default hr_api.g_number
  ,p_max_qual_level                in     number   default hr_api.g_number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_isc_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_isc_information1              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information2              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information3              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information4              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information5              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information6              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information7              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information8              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information9              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information10             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information11             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information12             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information13             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information14             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information15             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information16             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information17             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information18             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information19             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information20             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information21             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information22             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information23             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information24             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information25             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information26             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information27             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information28             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information29             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information30             in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_vacancy_criteria >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the vacancy search criteria.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The vacancy criteria must exist
 *
 * <p><b>Post Success</b><br>
 * The vacancy criteria will be deleted from the database
 *
 * <p><b>Post Failure</b><br>
 * Vacancy criteria will not be deleted from the database and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_search_criteria_id Identifies the vacancy search criteria to be
 * deleted
 * @param p_object_version_number Current version number of the vacancy
 * criteria to be deleted.
 * @rep:displayname Delete Vacancy Criteria
 * @rep:category BUSINESS_ENTITY PER_VACANCY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_vacancy_criteria
  (p_validate                      in     boolean  default false
  ,p_search_criteria_id            in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_work_choices >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates work preferences for a candidate.
 *
 * The work preferences for a candidate are used to indicate to a manager the
 * kind of vacancy that a candidate is looking for.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist
 *
 * <p><b>Post Success</b><br>
 * The work preferences will be created in the database
 *
 * <p><b>Post Failure</b><br>
 * The work preferences will not be created in the database and an error will
 * be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_person_id Identifies the person for whom you create the work
 * preferences record.
 * @param p_location Free text location a person is interested in
 * @param p_distance_to_location Distance in miles the user is willing to
 * travel to work.
 * @param p_geocode_location Location for a geocode search
 * @param p_geocode_country Country for a geocode search
 * @param p_derived_location Exact derived locale to match on
 * @param p_location_id Identifies a location to match on
 * @param p_longitude Longitude for a geocode search
 * @param p_latitude Latitude for a geocode search
 * @param p_employee Indicates that the candidate is looking for an employee
 * job (Y or N)
 * @param p_contractor Indicates that the candidate is looking for a contract
 * job (Y or N)
 * @param p_employment_category Indicates whether the candidate is looking for
 * a full time or part time job (FULLTIME, PARTTIME or EITHER)
 * @param p_keywords Free text keywords for the search
 * @param p_travel_percentage Percentage of time a person is willing to spend
 * travelling. Valid values are defined by 'IRC_TRAVEL_PERCENTAGE' lookup type.
 * @param p_min_salary Minimum salary user is willing to accept.
 * @param p_salary_currency Salary currency
 * @param p_salary_period Salary period. Valid values are defined by
 * 'PAY_BASIS' lookup type.
 * @param p_match_competence Identifies if user wishes to match jobs against
 * the competencies he has entered (Y or N)
 * @param p_match_qualification Identifies if user wishes to match jobs against
 * the qualification he has entered (Y or N)
 * @param p_work_at_home Indicates how desirable it is to work at home. Valid
 * values are defined by 'IRC_WORK_AT_HOME' lookup type.
 * @param p_job_title Title of job the user wishes to be included in search.
 * @param p_department Reserved for future use
 * @param p_professional_area Professional area user wishes to work in. Valid
 * values are defined by 'IRC_PROFESSIONAL_AREA' lookup type.
 * @param p_description Reserved for future use
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_isc_information_category Developer Descriptive flexfield segment.
 * @param p_isc_information1 Developer Descriptive flexfield segment.
 * @param p_isc_information2 Developer Descriptive flexfield segment.
 * @param p_isc_information3 Developer Descriptive flexfield segment.
 * @param p_isc_information4 Developer Descriptive flexfield segment.
 * @param p_isc_information5 Developer Descriptive flexfield segment.
 * @param p_isc_information6 Developer Descriptive flexfield segment.
 * @param p_isc_information7 Developer Descriptive flexfield segment.
 * @param p_isc_information8 Developer Descriptive flexfield segment.
 * @param p_isc_information9 Developer Descriptive flexfield segment.
 * @param p_isc_information10 Developer Descriptive flexfield segment.
 * @param p_isc_information11 Developer Descriptive flexfield segment.
 * @param p_isc_information12 Developer Descriptive flexfield segment.
 * @param p_isc_information13 Developer Descriptive flexfield segment.
 * @param p_isc_information14 Developer Descriptive flexfield segment.
 * @param p_isc_information15 Developer Descriptive flexfield segment.
 * @param p_isc_information16 Developer Descriptive flexfield segment.
 * @param p_isc_information17 Developer Descriptive flexfield segment.
 * @param p_isc_information18 Developer Descriptive flexfield segment.
 * @param p_isc_information19 Developer Descriptive flexfield segment.
 * @param p_isc_information20 Developer Descriptive flexfield segment.
 * @param p_isc_information21 Developer Descriptive flexfield segment.
 * @param p_isc_information22 Developer Descriptive flexfield segment.
 * @param p_isc_information23 Developer Descriptive flexfield segment.
 * @param p_isc_information24 Developer Descriptive flexfield segment.
 * @param p_isc_information25 Developer Descriptive flexfield segment.
 * @param p_isc_information26 Developer Descriptive flexfield segment.
 * @param p_isc_information27 Developer Descriptive flexfield segment.
 * @param p_isc_information28 Developer Descriptive flexfield segment.
 * @param p_isc_information29 Developer Descriptive flexfield segment.
 * @param p_isc_information30 Developer Descriptive flexfield segment.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created work preferences. If p_validate is true, then
 * the value will be null.
 * @param p_search_criteria_id If p_validate is false, then this uniquely
 * identifies the work preferences created. If p_validate is true, then set to
 * null.
 * @rep:displayname Create Work Preferences
 * @rep:category BUSINESS_ENTITY IRC_CANDIDATE_WORK_PREFERENCES
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_work_choices
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_location                      in     varchar2 default null
  ,p_distance_to_location          in     varchar2 default null
  ,p_geocode_location              in     varchar2 default null
  ,p_geocode_country               in     varchar2 default null
  ,p_derived_location              in     varchar2 default null
  ,p_location_id                   in     number   default null
  ,p_longitude                     in     number   default null
  ,p_latitude                      in     number   default null
  ,p_employee                      in     varchar2 default null
  ,p_contractor                    in     varchar2 default null
  ,p_employment_category           in     varchar2 default 'EITHER'
  ,p_keywords                      in     varchar2 default null
  ,p_travel_percentage             in     number   default null
  ,p_min_salary                    in     number   default null
  ,p_salary_currency               in     varchar2 default null
  ,p_salary_period                 in     varchar2 default null
  ,p_match_competence              in     varchar2 default 'N'
  ,p_match_qualification           in     varchar2 default 'N'
  ,p_work_at_home                  in     varchar2 default 'POSSIBLE'
  ,p_job_title                     in     varchar2 default null
  ,p_department                    in     varchar2 default null
  ,p_professional_area             in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_isc_information_category      in     varchar2 default null
  ,p_isc_information1              in     varchar2 default null
  ,p_isc_information2              in     varchar2 default null
  ,p_isc_information3              in     varchar2 default null
  ,p_isc_information4              in     varchar2 default null
  ,p_isc_information5              in     varchar2 default null
  ,p_isc_information6              in     varchar2 default null
  ,p_isc_information7              in     varchar2 default null
  ,p_isc_information8              in     varchar2 default null
  ,p_isc_information9              in     varchar2 default null
  ,p_isc_information10             in     varchar2 default null
  ,p_isc_information11             in     varchar2 default null
  ,p_isc_information12             in     varchar2 default null
  ,p_isc_information13             in     varchar2 default null
  ,p_isc_information14             in     varchar2 default null
  ,p_isc_information15             in     varchar2 default null
  ,p_isc_information16             in     varchar2 default null
  ,p_isc_information17             in     varchar2 default null
  ,p_isc_information18             in     varchar2 default null
  ,p_isc_information19             in     varchar2 default null
  ,p_isc_information20             in     varchar2 default null
  ,p_isc_information21             in     varchar2 default null
  ,p_isc_information22             in     varchar2 default null
  ,p_isc_information23             in     varchar2 default null
  ,p_isc_information24             in     varchar2 default null
  ,p_isc_information25             in     varchar2 default null
  ,p_isc_information26             in     varchar2 default null
  ,p_isc_information27             in     varchar2 default null
  ,p_isc_information28             in     varchar2 default null
  ,p_isc_information29             in     varchar2 default null
  ,p_isc_information30             in     varchar2 default null
  ,p_object_version_number           out nocopy number
  ,p_search_criteria_id              out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_work_choices >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates work preferences for a candidate.
 *
 * The work preferences for a candidate are used to indicate to a manager the
 * kind of vacancy that a candidate is looking for.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The work preferences must exist in the database
 *
 * <p><b>Post Success</b><br>
 * The work preferences will be updated
 *
 * <p><b>Post Failure</b><br>
 * The work preferences will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_search_criteria_id Identifies the work preferences to be updated
 * @param p_location Free text location a person is interested in
 * @param p_distance_to_location Distance in miles the user is willing to
 * travel to work.
 * @param p_geocode_location Location for a geocode search
 * @param p_geocode_country Country for a geocode search
 * @param p_derived_location Exact derived locale to match on
 * @param p_location_id Identifies a location to match on
 * @param p_longitude Longitude for a geocode search
 * @param p_latitude Latitude for a geocode search
 * @param p_employee Indicates that the candidate is looking for an employee
 * job (Y or N)
 * @param p_contractor Indicates that the candidate is looking for a contract
 * job (Y or N)
 * @param p_employment_category Indicates whether the candidate is looking for
 * a full time or part time job (FULLTIME, PARTTIME or EITHER)
 * @param p_keywords Free text keywords for the search
 * @param p_travel_percentage Percentage of time a person is willing to spend
 * travelling. Valid values are defined by 'IRC_TRAVEL_PERCENTAGE' lookup type.
 * @param p_min_salary Minimum salary user is willing to accept.
 * @param p_salary_currency Salary currency
 * @param p_salary_period Salary period. Valid values are defined by
 * 'PAY_BASIS' lookup type.
 * @param p_match_competence Identifies if user wishes to match jobs against
 * the competencies he has entered (Y or N)
 * @param p_match_qualification Identifies if user wishes to match jobs against
 * the qualification he has entered (Y or N)
 * @param p_work_at_home Indicates how desirable it is to work at home. Valid
 * values are defined by 'IRC_WORK_AT_HOME' lookup type.
 * @param p_job_title Title of job the user wishes to be included in search.
 * @param p_department Reserved for future use
 * @param p_professional_area Professional area user wishes to work in. Valid
 * values are defined by 'IRC_PROFESSIONAL_AREA' lookup type.
 * @param p_description Reserved for future use
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_isc_information_category Developer Descriptive flexfield segment.
 * @param p_isc_information1 Developer Descriptive flexfield segment.
 * @param p_isc_information2 Developer Descriptive flexfield segment.
 * @param p_isc_information3 Developer Descriptive flexfield segment.
 * @param p_isc_information4 Developer Descriptive flexfield segment.
 * @param p_isc_information5 Developer Descriptive flexfield segment.
 * @param p_isc_information6 Developer Descriptive flexfield segment.
 * @param p_isc_information7 Developer Descriptive flexfield segment.
 * @param p_isc_information8 Developer Descriptive flexfield segment.
 * @param p_isc_information9 Developer Descriptive flexfield segment.
 * @param p_isc_information10 Developer Descriptive flexfield segment.
 * @param p_isc_information11 Developer Descriptive flexfield segment.
 * @param p_isc_information12 Developer Descriptive flexfield segment.
 * @param p_isc_information13 Developer Descriptive flexfield segment.
 * @param p_isc_information14 Developer Descriptive flexfield segment.
 * @param p_isc_information15 Developer Descriptive flexfield segment.
 * @param p_isc_information16 Developer Descriptive flexfield segment.
 * @param p_isc_information17 Developer Descriptive flexfield segment.
 * @param p_isc_information18 Developer Descriptive flexfield segment.
 * @param p_isc_information19 Developer Descriptive flexfield segment.
 * @param p_isc_information20 Developer Descriptive flexfield segment.
 * @param p_isc_information21 Developer Descriptive flexfield segment.
 * @param p_isc_information22 Developer Descriptive flexfield segment.
 * @param p_isc_information23 Developer Descriptive flexfield segment.
 * @param p_isc_information24 Developer Descriptive flexfield segment.
 * @param p_isc_information25 Developer Descriptive flexfield segment.
 * @param p_isc_information26 Developer Descriptive flexfield segment.
 * @param p_isc_information27 Developer Descriptive flexfield segment.
 * @param p_isc_information28 Developer Descriptive flexfield segment.
 * @param p_isc_information29 Developer Descriptive flexfield segment.
 * @param p_isc_information30 Developer Descriptive flexfield segment.
 * @param p_object_version_number Pass in the current version number of the
 * work preferences to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated work
 * preferences. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Work Preferences
 * @rep:category BUSINESS_ENTITY IRC_CANDIDATE_WORK_PREFERENCES
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_work_choices
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_search_criteria_id            in     number
  ,p_location                      in     varchar2 default hr_api.g_varchar2
  ,p_distance_to_location          in     varchar2 default hr_api.g_varchar2
  ,p_geocode_location              in     varchar2 default hr_api.g_varchar2
  ,p_geocode_country               in     varchar2 default hr_api.g_varchar2
  ,p_derived_location              in     varchar2 default hr_api.g_varchar2
  ,p_location_id                   in     number   default hr_api.g_number
  ,p_longitude                     in     number   default hr_api.g_number
  ,p_latitude                      in     number   default hr_api.g_number
  ,p_employee                      in     varchar2 default hr_api.g_varchar2
  ,p_contractor                    in     varchar2 default hr_api.g_varchar2
  ,p_employment_category           in     varchar2 default hr_api.g_varchar2
  ,p_keywords                      in     varchar2 default hr_api.g_varchar2
  ,p_travel_percentage             in     number   default hr_api.g_number
  ,p_min_salary                    in     number   default hr_api.g_number
  ,p_salary_currency               in     varchar2 default hr_api.g_varchar2
  ,p_salary_period                 in     varchar2 default hr_api.g_varchar2
  ,p_match_competence              in     varchar2 default hr_api.g_varchar2
  ,p_match_qualification           in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home                  in     varchar2 default hr_api.g_varchar2
  ,p_job_title                     in     varchar2 default hr_api.g_varchar2
  ,p_department                    in     varchar2 default hr_api.g_varchar2
  ,p_professional_area             in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_isc_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_isc_information1              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information2              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information3              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information4              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information5              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information6              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information7              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information8              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information9              in     varchar2 default hr_api.g_varchar2
  ,p_isc_information10             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information11             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information12             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information13             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information14             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information15             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information16             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information17             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information18             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information19             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information20             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information21             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information22             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information23             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information24             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information25             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information26             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information27             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information28             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information29             in     varchar2 default hr_api.g_varchar2
  ,p_isc_information30             in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_work_choices >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a candidate's work preferences.
 *
 * The work preferences will no longer be available for the manager to view.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The work preferences must exist in the database
 *
 * <p><b>Post Success</b><br>
 * The work preferences will be deleted from the database
 *
 * <p><b>Post Failure</b><br>
 * The work preferences will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_search_criteria_id Identifies the work preferences to be deleted
 * @param p_object_version_number Current version number of the work
 * preferences to be deleted.
 * @rep:displayname Delete Work Preferences
 * @rep:category BUSINESS_ENTITY IRC_CANDIDATE_WORK_PREFERENCES
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_work_choices
  (p_validate                      in     boolean  default false
  ,p_search_criteria_id            in     number
  ,p_object_version_number         in     number
  );
--
end IRC_SEARCH_CRITERIA_API;

/
