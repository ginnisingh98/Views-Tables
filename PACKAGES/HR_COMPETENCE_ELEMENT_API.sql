--------------------------------------------------------
--  DDL for Package HR_COMPETENCE_ELEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCE_ELEMENT_API" AUTHID CURRENT_USER as
/* $Header: pecelapi.pkh 120.2 2006/02/13 14:05:47 vbala noship $ */
/*#
 * This package contains Competence Element APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Competence Element
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_competence_element >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a competence element.
 *
 * A competence element is used to record an individual competence and an
 * evaluation rating. Either a competence level or a specific rating scale step
 * may be indicated as the evaluation rating.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * There are no prereqs for creating competence elements.
 *
 * <p><b>Restricted Usage Notes</b><br>
 * HR Foundation users can only use the following parameters: p_effective_date
 * p_type, p_validate p_business_group, p_competence_id, p_proficiency_level,
 * p_rating_level, p_person_id, p_effective_date_from, p_effective_date_to,
 * p_source_of_proficiency_level, p_certification_date, p_certification_method,
 * p_next_certification_date, p_comments, p_attribute_category, p_attribute1 -
 * 20, p_party_id.
 *
 * <p><b>Post Success</b><br>
 * Competence element is created.
 *
 * <p><b>Post Failure</b><br>
 * Competence element is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_competence_element_id If p_validate is false, uniquely identifies
 * the competence element created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created competence element. If p_validate is true,
 * then the value will be null.
 * @param p_type Type of competence element. Valid values are defined by
 * COMPETENCE_ELEMENT_TYPE lookup type.
 * @param p_business_group_id Business group in which the competence element is
 * created.
 * @param p_enterprise_id Identifies the enterprise organization for which the
 * competence element is defined.
 * @param p_competence_id Competence for the element.
 * @param p_proficiency_level_id Proficiency level for the competence.
 * @param p_high_proficiency_level_id The highest proficiency level that can be
 * achieved for the competence referenced by the element.
 * @param p_weighting_level_id Weighting level associated with the competence
 * referenced by the element.
 * @param p_rating_level_id Rating level associated with the competence
 * referenced by the element.
 * @param p_person_id Person for whom this competence element applies.
 * @param p_job_id Identifies job
 * @param p_valid_grade_id Identifies grade
 * @param p_position_id Identifies position
 * @param p_organization_id Identifies organization
 * @param p_parent_competence_element_id Identifies the parent competence
 * element. Parent competences must be of type ASSESSMENT GROUP and if a
 * competence element is to have a parent, it must have a type of
 * ASSESSMENT_COMPETENCE.
 * @param p_activity_version_id Activity version
 * @param p_assessment_id Identifies Assessment
 * @param p_assessment_type_id Identifies the assessment type
 * @param p_mandatory Indicates that the associated competence is essential for
 * the competence requirements. Valid values are defined by YES_NO lookup type.
 * @param p_effective_date_from The effective start date of this competence
 * element.
 * @param p_effective_date_to The effective end date of this competence
 * element.
 * @param p_group_competence_type Competence type for the group. Validated
 * values are defined in COMPETENCE_TYPE lookup type.
 * @param p_competence_type Competence type. Validated values are defined by
 * COMPETENCE_TYPE lookup type.
 * @param p_normal_elapse_duration The time needed for a competence of type
 * 'Path'.
 * @param p_normal_elapse_duration_unit Units of the duration. Valid values are
 * defined by ELAPSE_DURATION lookup type.
 * @param p_sequence_number Number to control the display sequence.
 * @param p_source_of_proficiency_level Source of proficiency level. Valid
 * values are defined by PROFICIENCY_SOURCE lookup type.
 * @param p_line_score The score related to an assessment.
 * @param p_certification_date Date on which the certification was obtained.
 * @param p_certification_method Method by which the certification is obtained.
 * Valid values are defined in CERTIFICATION_METHOD lookup type.
 * @param p_next_certification_date Date when the next certification is due.
 * @param p_comments Comment text.
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
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_object_id Identifier for a generic object that is linked with a
 * competence.
 * @param p_object_name Identifies the generic object that is linked with a
 * competence e.g. Project Resource.
 * @param p_party_id The party for whom the competence element applies.
 * @param p_qualification_type_id Identifies the qualification type
 * @param p_unit_standard_type Unit standard type.
 * @param p_status Indicates whether the competence has been achieved or is
 * still being worked towards.
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
 * @param p_achieved_date The date on which the 'Status' changes to 'Achieved'
 * @param p_appr_line_score The score related to an appraisal competency assessment.
 * @rep:displayname Create Competence Element
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
procedure create_competence_element
 (p_validate                     in     boolean         default false,
  p_competence_element_id        out nocopy number,
  p_object_version_number        out nocopy number,
  p_type                         in varchar2,
  p_business_group_id            in number           default null,
  p_enterprise_id                in number	     default null,
  p_competence_id                in number           default null,
  p_proficiency_level_id         in number           default null,
  p_high_proficiency_level_id    in number           default null,
  p_weighting_level_id           in number           default null,
  p_rating_level_id              in number           default null,
  p_person_id                    in number           default null,
  p_job_id                       in number           default null,
  p_valid_grade_id               in number	     default null,
  p_position_id                  in number           default null,
  p_organization_id              in number           default null,
  p_parent_competence_element_id in number           default null,
  p_activity_version_id          in number           default null,
  p_assessment_id                in number           default null,
  p_assessment_type_id           in number           default null,
  p_mandatory                    in varchar2         default null,
  p_effective_date_from          in date             default null,
  p_effective_date_to            in date             default null,
  p_group_competence_type        in varchar2         default null,
  p_competence_type              in varchar2         default null,
  p_normal_elapse_duration       in number           default null,
  p_normal_elapse_duration_unit  in varchar2         default null,
  p_sequence_number              in number           default null,
  p_source_of_proficiency_level  in varchar2         default null,
  p_line_score                   in number           default null,
  p_certification_date           in date             default null,
  p_certification_method         in varchar2         default null,
  p_next_certification_date      in date             default null,
  p_comments                     in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_effective_date		 in Date,
  p_object_id                    in number           default null,
  p_object_name                  in varchar2         default null,
  p_party_id                     in number           default null  -- HR/TCA merge
 ,p_qualification_type_id        in number           default null
 ,p_unit_standard_type           in varchar2         default null
 ,p_status                       in varchar2         default null
 ,p_information_category         in varchar2         default null
 ,p_information1                 in varchar2         default null
 ,p_information2                 in varchar2         default null
 ,p_information3                 in varchar2         default null
 ,p_information4                 in varchar2         default null
 ,p_information5                 in varchar2         default null
 ,p_information6                 in varchar2         default null
 ,p_information7                 in varchar2         default null
 ,p_information8                 in varchar2         default null
 ,p_information9                 in varchar2         default null
 ,p_information10                in varchar2         default null
 ,p_information11                in varchar2         default null
 ,p_information12                in varchar2         default null
 ,p_information13                in varchar2         default null
 ,p_information14                in varchar2         default null
 ,p_information15                in varchar2         default null
 ,p_information16                in varchar2         default null
 ,p_information17                in varchar2         default null
 ,p_information18                in varchar2         default null
 ,p_information19                in varchar2         default null
 ,p_information20                in varchar2         default null
 ,p_achieved_date                in date             default null
 ,p_appr_line_score              in number           default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_competence_element >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates competence element details.
 *
 * A competence element is used to record an individual competence and an
 * evaluation rating. Either a competence level or a specific rating scale step
 * may be indicated as the evaluation rating.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Competence element must exist.
 *
 * <p><b>Restricted Usage Notes</b><br>
 * HR Foundation users can only use the following parameters: p_effective_date,
 * p_competence_element_id, p_object_version_number, p_validate,
 * p_proficiency_level, p_rating_level, p_effective_date_from,
 * p_effective_date_to, p_source_of_proficiency_level, p_certification_date,
 * p_certification_method, p_next_certification_date, p_comments,
 * p_attribute_category, p_attribute1 - 20, p_party_id.
 *
 * <p><b>Post Success</b><br>
 * Competence element is updated.
 *
 * <p><b>Post Failure</b><br>
 * Competence element is not updated and an error is raised.
 * @param p_competence_element_id Identifies the competence element record to
 * be modified.
 * @param p_object_version_number Pass in the current version number of the
 * competence element to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated competence
 * element. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_proficiency_level_id Proficiency level for the competence.
 * @param p_high_proficiency_level_id The highest proficiency level that can be
 * achieved for the competence referenced by the element.
 * @param p_weighting_level_id Weighting level associated with the competence
 * referenced by the element.
 * @param p_rating_level_id The level associated with the competence referenced
 * by the element.
 * @param p_mandatory Indicates that the associated competence is essential for
 * the competence requirements. Valid values are defined by YES_NO lookup type.
 * @param p_effective_date_from The effective start date of this competence
 * element.
 * @param p_effective_date_to The effective end date of this competence
 * element.
 * @param p_group_competence_type Competence type for the group. Validated
 * values are defined in COMPETENCE_TYPE lookup type.
 * @param p_competence_type Competence type. Validated values are defined by
 * COMPETENCE_TYPE lookup type.
 * @param p_normal_elapse_duration The time needed for a competence of type
 * 'Path'.
 * @param p_normal_elapse_duration_unit Units of the duration. Valid values are
 * defined by ELAPSE_DURATION lookup type.
 * @param p_sequence_number Number to control the display sequence.
 * @param p_source_of_proficiency_level Source of proficiency level. Valid
 * values are defined by PROFICIENCY_SOURCE lookup type.
 * @param p_line_score The score related to an assessment.
 * @param p_certification_date The date on which the certification was
 * obtained.
 * @param p_certification_method Method by which the certification is obtained.
 * Valid values are defined in CERTIFICATION_METHOD lookup type.
 * @param p_next_certification_date Date when the next certification is due.
 * @param p_comments Comment text.
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
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_party_id The party for whom the competence element applies.
 * @param p_qualification_type_id Identifies the qualification type
 * @param p_unit_standard_type Unit standard type.
 * @param p_status Indicates whether the competence has been achieved or is
 * still being worked towards.
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
 * @param p_achieved_date The date on which the 'Status' changes to 'Achieved'
 * @param p_appr_line_score The score related to an appraisal competency assessment.
 * @rep:displayname Update Competence Element
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_competence_element
  (
  p_competence_element_id        in number,
  p_object_version_number        in out nocopy number,
  p_proficiency_level_id         in number           default hr_api.g_number,
  p_high_proficiency_level_id    in number           default hr_api.g_number,
  p_weighting_level_id           in number           default hr_api.g_number,
  p_rating_level_id              in number           default hr_api.g_number,
  p_mandatory           	 in varchar2         default hr_api.g_varchar2,
  p_effective_date_from          in date             default hr_api.g_date,
  p_effective_date_to            in date             default hr_api.g_date,
  p_group_competence_type        in varchar2         default hr_api.g_varchar2,
  p_competence_type              in varchar2         default hr_api.g_varchar2,
  p_normal_elapse_duration       in number           default hr_api.g_number,
  p_normal_elapse_duration_unit  in varchar2         default hr_api.g_varchar2,
  p_sequence_number              in number           default hr_api.g_number,
  p_source_of_proficiency_level  in varchar2         default hr_api.g_varchar2,
  p_line_score                   in number           default hr_api.g_number,
  p_certification_date           in date             default hr_api.g_date,
  p_certification_method         in varchar2         default hr_api.g_varchar2,
  p_next_certification_date      in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_effective_date		 in Date,
  p_validate                     in boolean          default false,
  p_party_id                     in number
 ,p_qualification_type_id        in number           default hr_api.g_number
 ,p_unit_standard_type           in varchar2         default hr_api.g_varchar2
 ,p_status                       in varchar2         default hr_api.g_varchar2
 ,p_information_category         in varchar2         default hr_api.g_varchar2
 ,p_information1                 in varchar2         default hr_api.g_varchar2
 ,p_information2                 in varchar2         default hr_api.g_varchar2
 ,p_information3                 in varchar2         default hr_api.g_varchar2
 ,p_information4                 in varchar2         default hr_api.g_varchar2
 ,p_information5                 in varchar2         default hr_api.g_varchar2
 ,p_information6                 in varchar2         default hr_api.g_varchar2
 ,p_information7                 in varchar2         default hr_api.g_varchar2
 ,p_information8                 in varchar2         default hr_api.g_varchar2
 ,p_information9                 in varchar2         default hr_api.g_varchar2
 ,p_information10                in varchar2         default hr_api.g_varchar2
 ,p_information11                in varchar2         default hr_api.g_varchar2
 ,p_information12                in varchar2         default hr_api.g_varchar2
 ,p_information13                in varchar2         default hr_api.g_varchar2
 ,p_information14                in varchar2         default hr_api.g_varchar2
 ,p_information15                in varchar2         default hr_api.g_varchar2
 ,p_information16                in varchar2         default hr_api.g_varchar2
 ,p_information17                in varchar2         default hr_api.g_varchar2
 ,p_information18                in varchar2         default hr_api.g_varchar2
 ,p_information19                in varchar2         default hr_api.g_varchar2
 ,p_information20                in varchar2         default hr_api.g_varchar2
 ,p_achieved_date                in date             default hr_api.g_date
 ,p_appr_line_score              in number           default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_competence_element >---------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_competence_element
  (
  p_competence_element_id        in number,
  p_object_version_number        in out nocopy number,
  p_proficiency_level_id         in number           default hr_api.g_number,
  p_high_proficiency_level_id    in number           default hr_api.g_number,
  p_weighting_level_id           in number           default hr_api.g_number,
  p_rating_level_id              in number           default hr_api.g_number,
  p_mandatory           	 in varchar2         default hr_api.g_varchar2,
  p_effective_date_from          in date             default hr_api.g_date,
  p_effective_date_to            in date             default hr_api.g_date,
  p_group_competence_type        in varchar2         default hr_api.g_varchar2,
  p_competence_type              in varchar2         default hr_api.g_varchar2,
  p_normal_elapse_duration       in number           default hr_api.g_number,
  p_normal_elapse_duration_unit  in varchar2         default hr_api.g_varchar2,
  p_sequence_number              in number           default hr_api.g_number,
  p_source_of_proficiency_level  in varchar2         default hr_api.g_varchar2,
  p_line_score                   in number           default hr_api.g_number,
  p_certification_date           in date             default hr_api.g_date,
  p_certification_method         in varchar2         default hr_api.g_varchar2,
  p_next_certification_date      in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_effective_date		 in Date,
  p_validate                     in boolean      default false
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_personal_comp_element >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API Updates a personal competence element.
 *
 * Use this API for updating the competence element of type PERSONAL. A
 * competence element is used to record an individual competence and an
 * evaluation rating. Either a competence level or a specific rating scale step
 * may be indicated as the evaluation rating.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * A valid competence element must already exist.
 *
 * <p><b>Post Success</b><br>
 * Competence element is updated.
 *
 * <p><b>Post Failure</b><br>
 * Does not update a competence element and an error is raised.
 * @param p_competence_element_id Identifies the competence element record to
 * be updated.
 * @param p_object_version_number Pass in the current version number of the
 * competence element to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated competence
 * element. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_proficiency_level_id The proficiency level for the competence
 * @param p_effective_date_from The effective start date of this competence
 * element.
 * @param p_effective_date_to The effective end date of this competence
 * element.
 * @param p_source_of_proficiency_level The source of the proficiency level.
 * @param p_certification_date The date on which the certification was
 * obtained.
 * @param p_certification_method The method by which the certification is
 * obtained.
 * @param p_next_certification_date The date for next certification
 * @param p_comments Comments Text
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
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_ins_ovn Identifies the object version number of the new record
 * created. This happens when an existing competence element is updated and a
 * new competence element is created ( for maintaining the date track of this
 * competence).
 * @param p_ins_comp_id Identifies the new competence record created. This
 * happens when an existing competence element is updated and a new competence
 * element is created ( for maintaining the date track of this competence).
 * @rep:displayname Update Personal Competence Element
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_personal_comp_element
  (
  p_competence_element_id        in number,
  p_object_version_number        in out nocopy number,
  p_proficiency_level_id         in number           default hr_api.g_number,
  p_effective_date_from          in date             default hr_api.g_date,
  p_effective_date_to            in date             default hr_api.g_date,
  p_source_of_proficiency_level  in varchar2         default hr_api.g_varchar2,
  p_certification_date           in date             default hr_api.g_date,
  p_certification_method         in varchar2         default hr_api.g_varchar2,
  p_next_certification_date      in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_effective_date		 in Date,
  p_validate                     in boolean          default false ,
  p_ins_ovn			 out nocopy number,
  p_ins_comp_id			 out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_competence_element >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a competence element.
 *
 * A competence element is used to record an individual competence and an
 * evaluation rating. Either a competence level or a specific rating scale step
 * may be indicated as the evaluation rating.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * A valid competence element must already exist.
 *
 * <p><b>Post Success</b><br>
 * Competence element is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Competence element is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_competence_element_id Identifies the competence element record to
 * delete.
 * @param p_object_version_number Current version number of the competence
 * element to be deleted.
 * @rep:displayname Delete Competence Element
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_competence_element
(p_validate                           in boolean default false,
 p_competence_element_id              in number,
 p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< maintain_student_comp_element >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API maintains the details of student competence element.
 *
 * A competence element is used to record an individual competence and an
 * evaluation rating. Either a competence level or a specific rating scale step
 * may be indicated as the evaluation rating.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * To modify competence element, an existing and valid competence element must
 * exist.
 *
 * <p><b>Post Success</b><br>
 * If p_validate is false and the competence element does not exist, then this
 * process creates the competence element. If the competence element already
 * exists and is a valid one, then the process updates it. If p_validate is
 * true then no records are created or updated.
 *
 * <p><b>Post Failure</b><br>
 * The competence element is not created or updated and an error is raised.
 * @param p_person_id Identifies the person record
 * @param p_competence_id Competence for this element.
 * @param p_proficiency_level_id Proficiency level for the competence.
 * @param p_business_group_id Business group in which the competence is
 * created.
 * @param p_effective_date_from The effective start date of this competence
 * element
 * @param p_effective_date_to The effective end date of this competence
 * element.
 * @param p_certification_date The date on which the certification was
 * obtained.
 * @param p_certification_method The method by which the certification is
 * obtained.
 * @param p_next_certification_date The date for next certification.
 * @param p_source_of_proficiency_level Source of proficiency level. Valid
 * values are defined by PROFICIENCY_SOURCE lookup type.
 * @param p_comments Comment text.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_competence_created Identifies the number of competence elements
 * created, updated or both. If a new competence element is created this is set
 * to 1. If an existing competence element is updated, then also this is set to
 * 1. If an existing competence element is updated and a new competence element
 * record is created then this is set to 2.
 * @rep:displayname Maintain Student Competence Element
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure maintain_student_comp_element
(p_person_id                          in number
,p_competence_id                      in number
,p_proficiency_level_id               in number
,p_business_group_id                  in number
,p_effective_date_from                in date
,p_effective_date_to                  in date
,p_certification_date                 in date
,p_certification_method               in varchar2
,p_next_certification_date            in date
,p_source_of_proficiency_level        in varchar2
,p_comments                           in varchar2
,p_effective_date                     in date
,p_validate                           in boolean          default false
,p_competence_created                 out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< copy_competencies >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API copies competence element.
 *
 * Use this API to copy an existing competence element details to a new
 * competence element.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Competence element to be copied from must exist.
 *
 * <p><b>Post Success</b><br>
 * If p_validate is false, then the competence elements are copied. If
 * p_validate is true then no competence elements are copied.
 *
 * <p><b>Post Failure</b><br>
 * Does not copy competencies and an error is raised.
 * @param p_activity_version_from Activity version from which the competence is
 * being copied.
 * @param p_activity_version_to Activity version to which the competence is
 * being copied.
 * @param p_competence_type Competence type to be copied, TRAINER or DELIVERY
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Copy Competence Elements
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure copy_competencies(p_activity_version_from number
                           ,p_activity_version_to number
			   ,p_competence_type	VARCHAR2 default null -- Bug 1868713
			   ,p_validate      in boolean          default false
			   );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_delivered_dates >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the competence element delivered dates.
 *
 * If p_validate is false then this procedure will update the competence
 * element with the latest of p_old_start_date and p_start_date, and the
 * earliest of p_old_end_date and p_end_date. If p_validate is true, then no
 * rows will be updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid competence element must already exist.
 *
 * <p><b>Post Success</b><br>
 * Delivered dates are updated.
 *
 * <p><b>Post Failure</b><br>
 * Does not update a delivered date and an error is raised.
 * @param p_activity_version_id The activity version for the competence
 * element.
 * @param p_old_start_date The existing start date of the competence element.
 * @param p_start_date The new start date for the competence element.
 * @param p_old_end_date The existing end date of the competence element.
 * @param p_end_date The new end date for the competence element.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Update Competence Element Delivered Dates
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_delivered_dates
        (p_activity_version_id                 in number,
        p_old_start_date                       in date,
        p_start_date                           in date,
        p_old_end_date                         in date,
        p_end_date                             in date,
        p_validate                             in boolean          default false
        );
--
end hr_competence_element_api;

 

/
