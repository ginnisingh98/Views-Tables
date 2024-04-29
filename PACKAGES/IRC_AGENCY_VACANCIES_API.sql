--------------------------------------------------------
--  DDL for Package IRC_AGENCY_VACANCIES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_AGENCY_VACANCIES_API" AUTHID CURRENT_USER as
/* $Header: iriavapi.pkh 120.2 2008/02/21 14:08:33 viviswan noship $ */
/*#
 * This package contains agency vacancy APIs.
 * @rep:scope public
 * @rep:product IRC
 * @rep:displayname Agency Vacancy
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_agency_vacancy >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 *
 * This API associates an agency with a vacancy.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The agency and the vacancy must both exist.
 *
 * <p><b>Post Success</b><br>
 * The agency is associated with the vacancy.
 *
 * <p><b>Post Failure</b><br>
 * The agency will not be associated with the vacancy and an error will be
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_agency_id Identifies the agency.
 * @param p_vacancy_id Identifies the vacancy.
 * @param p_start_date The date from which the agency may see that they are
 * associated with the vacancy.
 * @param p_end_date The last date on which the agency may see that they are
 * associated with the vacancy.
 * @param p_max_allowed_applicants The maximum number of applicants the agency
 * is allowed to submit for the vacancy.
 * @param p_manage_applicants_allowed Indicates whether or not the agency can
 * manage the vacancy (Y or N).
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
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created association. If p_validate is true, then the
 * value will be null.
 * @param p_agency_vacancy_id If p_validate is false, then this uniquely
 * identifies the association of the agency with the vacancy. If p_validate is
 * true, then this is set to null.
 * @rep:displayname Create Agency Vacancy
 * @rep:category BUSINESS_ENTITY IRC_AGENCY
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_agency_vacancy
  (p_validate                       in boolean  default false
  ,p_agency_id                      in number
  ,p_vacancy_id                     in number
  ,p_start_date                     in date     default null
  ,p_end_date                       in date     default null
  ,p_max_allowed_applicants         in number   default null
  ,p_manage_applicants_allowed      in varchar2 default 'N'
  ,p_attribute_category             in varchar2 default null
  ,p_attribute1                     in varchar2 default null
  ,p_attribute2                     in varchar2 default null
  ,p_attribute3                     in varchar2 default null
  ,p_attribute4                     in varchar2 default null
  ,p_attribute5                     in varchar2 default null
  ,p_attribute6                     in varchar2 default null
  ,p_attribute7                     in varchar2 default null
  ,p_attribute8                     in varchar2 default null
  ,p_attribute9                     in varchar2 default null
  ,p_attribute10                    in varchar2 default null
  ,p_attribute11                    in varchar2 default null
  ,p_attribute12                    in varchar2 default null
  ,p_attribute13                    in varchar2 default null
  ,p_attribute14                    in varchar2 default null
  ,p_attribute15                    in varchar2 default null
  ,p_attribute16                    in varchar2 default null
  ,p_attribute17                    in varchar2 default null
  ,p_attribute18                    in varchar2 default null
  ,p_attribute19                    in varchar2 default null
  ,p_attribute20                    in varchar2 default null
  ,p_attribute21                    in varchar2 default null
  ,p_attribute22                    in varchar2 default null
  ,p_attribute23                    in varchar2 default null
  ,p_attribute24                    in varchar2 default null
  ,p_attribute25                    in varchar2 default null
  ,p_attribute26                    in varchar2 default null
  ,p_attribute27                    in varchar2 default null
  ,p_attribute28                    in varchar2 default null
  ,p_attribute29                    in varchar2 default null
  ,p_attribute30                    in varchar2 default null
  ,p_object_version_number          out nocopy  number
  ,p_agency_vacancy_id              out nocopy  number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_agency_vacancy >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 *
 * This API updates the association of an agency with a vacancy.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The association must exist.
 *
 * <p><b>Post Success</b><br>
 * The association details will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The association details will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_agency_vacancy_id Identifies the association of the agency and
 * vacancy to be updated.
 * @param p_agency_id Identifies the agency.
 * @param p_vacancy_id Identifies the vacancy.
 * @param p_start_date The date from which the agency may see that they are
 * associated with the vacancy.
 * @param p_end_date The last date on which the agency may see that they are
 * associated with the vacancy.
 * @param p_max_allowed_applicants The maximum number of applicants the agency
 * is allowed to submit for the vacancy.
 * @param p_manage_applicants_allowed Indicates whether or not the agency can
 * manage the vacancy (Y or N).
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
 * @param p_object_version_number Pass in the current version number of the
 * association to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated association. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Agency Vacancy
 * @rep:category BUSINESS_ENTITY IRC_AGENCY
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_agency_vacancy
  (p_validate                       in boolean  default false
  ,p_agency_vacancy_id              in number
  ,p_agency_id                      in number
  ,p_vacancy_id                     in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_max_allowed_applicants         in number   default hr_api.g_number
  ,p_manage_applicants_allowed      in varchar2 default 'N'
  ,p_attribute_category             in varchar2 default hr_api.g_varchar2
  ,p_attribute1                     in varchar2 default hr_api.g_varchar2
  ,p_attribute2                     in varchar2 default hr_api.g_varchar2
  ,p_attribute3                     in varchar2 default hr_api.g_varchar2
  ,p_attribute4                     in varchar2 default hr_api.g_varchar2
  ,p_attribute5                     in varchar2 default hr_api.g_varchar2
  ,p_attribute6                     in varchar2 default hr_api.g_varchar2
  ,p_attribute7                     in varchar2 default hr_api.g_varchar2
  ,p_attribute8                     in varchar2 default hr_api.g_varchar2
  ,p_attribute9                     in varchar2 default hr_api.g_varchar2
  ,p_attribute10                    in varchar2 default hr_api.g_varchar2
  ,p_attribute11                    in varchar2 default hr_api.g_varchar2
  ,p_attribute12                    in varchar2 default hr_api.g_varchar2
  ,p_attribute13                    in varchar2 default hr_api.g_varchar2
  ,p_attribute14                    in varchar2 default hr_api.g_varchar2
  ,p_attribute15                    in varchar2 default hr_api.g_varchar2
  ,p_attribute16                    in varchar2 default hr_api.g_varchar2
  ,p_attribute17                    in varchar2 default hr_api.g_varchar2
  ,p_attribute18                    in varchar2 default hr_api.g_varchar2
  ,p_attribute19                    in varchar2 default hr_api.g_varchar2
  ,p_attribute20                    in varchar2 default hr_api.g_varchar2
  ,p_attribute21                    in varchar2 default hr_api.g_varchar2
  ,p_attribute22                    in varchar2 default hr_api.g_varchar2
  ,p_attribute23                    in varchar2 default hr_api.g_varchar2
  ,p_attribute24                    in varchar2 default hr_api.g_varchar2
  ,p_attribute25                    in varchar2 default hr_api.g_varchar2
  ,p_attribute26                    in varchar2 default hr_api.g_varchar2
  ,p_attribute27                    in varchar2 default hr_api.g_varchar2
  ,p_attribute28                    in varchar2 default hr_api.g_varchar2
  ,p_attribute29                    in varchar2 default hr_api.g_varchar2
  ,p_attribute30                    in varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy  number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_agency_vacancy >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 *
 * This API removes the association of an agency with a vacancy.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The association must exist.
 *
 * <p><b>Post Success</b><br>
 * The association will be removed.
 *
 * <p><b>Post Failure</b><br>
 * The association will not be removed and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_agency_vacancy_id Identifies the association of the agency and
 * vacancy to be updated.
 * @param p_object_version_number Current version number of the association to
 * be deleted
 * @rep:displayname Delete Agency Vacancy
 * @rep:category BUSINESS_ENTITY IRC_AGENCY
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure delete_agency_vacancy
  (p_validate                       in boolean  default false
  ,p_agency_vacancy_id              in number
  ,p_object_version_number          in number
  );
end IRC_AGENCY_VACANCIES_API;

/
