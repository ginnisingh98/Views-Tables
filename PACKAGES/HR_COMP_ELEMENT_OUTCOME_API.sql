--------------------------------------------------------
--  DDL for Package HR_COMP_ELEMENT_OUTCOME_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMP_ELEMENT_OUTCOME_API" AUTHID CURRENT_USER as
/* $Header: peceoapi.pkh 120.1 2005/10/02 02:13 aroussel $ */
/*#
 * This package contains competence element outcome APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Competence Element Outcome
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_element_outcome >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates competence element outcome.
 *
 * Competence element outcome holds outcomes achieved towards a given
 * competency.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Competence element and competence outcome must exist.
 *
 * <p><b>Post Success</b><br>
 * Competence element outcome is created.
 *
 * <p><b>Post Failure</b><br>
 * Competence element outcome is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_competence_element_id Identifies the competence element.
 * @param p_outcome_id Identifies the competence outcome.
 * @param p_date_from Date from which this competence element outcome is
 * active.
 * @param p_date_to Date until which this competence element outcome is active.
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_comp_element_outcome_id If p_validate is false, then this uniquely
 * identifies the competence element outcome created. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created element outcome. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Competence Element Outcome
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_element_outcome
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_competence_element_id         in     number
  ,p_outcome_id                    in     number
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
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
  ,p_information_category          in     varchar2 default null
  ,p_information1                  in     varchar2 default null
  ,p_information2                  in     varchar2 default null
  ,p_information3                  in     varchar2 default null
  ,p_information4                  in     varchar2 default null
  ,p_information5                  in     varchar2 default null
  ,p_information6                  in     varchar2 default null
  ,p_information7                  in     varchar2 default null
  ,p_information8                  in     varchar2 default null
  ,p_information9                  in     varchar2 default null
  ,p_information10                 in     varchar2 default null
  ,p_information11                 in     varchar2 default null
  ,p_information12                 in     varchar2 default null
  ,p_information13                 in     varchar2 default null
  ,p_information14                 in     varchar2 default null
  ,p_information15                 in     varchar2 default null
  ,p_information16                 in     varchar2 default null
  ,p_information17                 in     varchar2 default null
  ,p_information18                 in     varchar2 default null
  ,p_information19                 in     varchar2 default null
  ,p_information20                 in     varchar2 default null
  ,p_comp_element_outcome_id          out nocopy number
  ,p_object_version_number            out nocopy number
 ) ;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_element_outcome >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates competence element outcome.
 *
 * Competence element outcome holds outcomes achieved towards a given
 * Competency.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The competence element outcome must exist.
 *
 * <p><b>Post Success</b><br>
 * Competence element outcome is updated.
 *
 * <p><b>Post Failure</b><br>
 * Competence element outcome is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_comp_element_outcome_id Identifies the competence element outcome
 * to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * element outcome to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated element outcome.
 * If p_validate is true will be set to the same value which was passed in
 * @param p_competence_element_id Identifies the competence element.
 * @param p_outcome_id Identifies the competence outcome.
 * @param p_date_from Date from which this competence element outcome is
 * active.
 * @param p_date_to Date until which this competence element outcome is active.
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @rep:displayname Update Competence Element Outcome
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_element_outcome
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_comp_element_outcome_id       in     number
  ,p_object_version_number         in out nocopy number
  ,p_competence_element_id         in     number   default hr_api.g_number
  ,p_outcome_id                    in     number   default hr_api.g_number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
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
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ) ;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_element_outcome >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes competence element outcome.
 *
 * Competence element outcome holds outcomes achieved towards a given
 * Competency.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Competence element outcome must exist.
 *
 * <p><b>Post Success</b><br>
 * Competence element outcome is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Competence element outcome is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_comp_element_outcome_id Identifies the record of the competence
 * element outcome to be deleted.
 * @param p_object_version_number Current version number of the element outcome
 * to be deleted.
 * @rep:displayname Delete Competence Element Outcome
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_element_outcome
  (p_validate                      in     boolean
  ,p_comp_element_outcome_id       in     number
  ,p_object_version_number         in out nocopy number
  );

--
end hr_comp_element_outcome_api;

 

/
