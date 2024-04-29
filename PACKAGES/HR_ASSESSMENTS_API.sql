--------------------------------------------------------
--  DDL for Package HR_ASSESSMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSESSMENTS_API" AUTHID CURRENT_USER as
/* $Header: peasnapi.pkh 120.1 2005/10/02 02:11:35 aroussel $ */
/*#
 * This package contains APIs that maintain assessments.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assessment
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_assessment >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new assessment.
 *
 * The assessment may hold the overall assessment score that is a sum of the
 * scores on each of the constituent assessment elements.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Assessment type must exist.
 *
 * <p><b>Post Success</b><br>
 * Assessment is created.
 *
 * <p><b>Post Failure</b><br>
 * Assessment is not created and an error is raised.
 * @param p_assessment_id If p_validate is false, then this uniquely identifies
 * the assessment created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assessment. If p_validate is true, then the
 * value will be null.
 * @param p_assessment_type_id Identifies the assessment type.
 * @param p_business_group_id Business group for which the assessment is
 * created.
 * @param p_person_id Identifies the person.
 * @param p_assessment_group_id Identifies the assessment group.
 * @param p_assessment_period_start_date Start date of the period to which the
 * assessment applies. This is mandatory if end date is not null.
 * @param p_assessment_period_end_date End date of the period to which the
 * competence assessment applies
 * @param p_assessment_date The date of the competence assessment.
 * @param p_assessor_person_id Person who is performing this assessment.
 * @param p_appraisal_id Identifies the appraisal.
 * @param p_group_date The date the group was created.
 * @param p_group_initiator_id Person who created the 360 degree assessment.
 * @param p_comments Comment text.
 * @param p_total_score Overall score derived from the sum of the individual
 * assessment line scores
 * @param p_status Status of the competence assessment. Valid values are
 * defined by the APPRAISAL_ASSESSMENT_STATUS lookup type.
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
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Assessment
 * @rep:category BUSINESS_ENTITY PER_ASSESSMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_assessment
 (
  p_assessment_id                out nocopy number,
  p_assessment_type_id           in		number,
  p_business_group_id            in		number,
  p_person_id                    in		number,
  p_assessment_group_id          in		number           default null,
  p_assessment_period_start_date in		date             default null,
  p_assessment_period_end_date   in		date             default null,
  p_assessment_date              in		date,
  p_assessor_person_id           in		number,
  p_appraisal_id                 in		number           default null,
  p_group_date                   in		date             default null,
  p_group_initiator_id           in		number           default null,
  p_comments                     in		varchar2         default null,
  p_total_score                  in		number           default null,
  p_status                       in		varchar2         default null,
  p_attribute_category           in		varchar2         default null,
  p_attribute1                   in 	varchar2         default null,
  p_attribute2                   in 	varchar2         default null,
  p_attribute3                   in 	varchar2         default null,
  p_attribute4                   in 	varchar2         default null,
  p_attribute5                   in 	varchar2         default null,
  p_attribute6                   in 	varchar2         default null,
  p_attribute7                   in 	varchar2         default null,
  p_attribute8                   in 	varchar2         default null,
  p_attribute9                   in 	varchar2         default null,
  p_attribute10                  in 	varchar2         default null,
  p_attribute11                  in 	varchar2         default null,
  p_attribute12                  in 	varchar2         default null,
  p_attribute13                  in 	varchar2         default null,
  p_attribute14                  in 	varchar2         default null,
  p_attribute15                  in 	varchar2         default null,
  p_attribute16                  in 	varchar2         default null,
  p_attribute17                  in 	varchar2         default null,
  p_attribute18                  in 	varchar2         default null,
  p_attribute19                  in 	varchar2         default null,
  p_attribute20                  in 	varchar2         default null,
  p_object_version_number        out nocopy    number,
  p_validate                     in     boolean   default false,
  p_effective_date               in     date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_assessment >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an assessment.
 *
 * The assessment may hold the overall assessment score which is a sum of the
 * scores on each of the constituent assessment elements.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid assessment must exist.
 *
 * <p><b>Post Success</b><br>
 * Assessment is updated.
 *
 * <p><b>Post Failure</b><br>
 * Assessment remains unchanged, and an error is raised.
 * @param p_assessment_id Identifies the assessment record to be updated.
 * @param p_assessment_type_id Identifies the assessment type.
 * @param p_assessment_group_id Identifies the assessment group.
 * @param p_assessment_period_start_date Start date of the period to which the
 * assessment applies. This is mandatory if end date is not null.
 * @param p_assessment_period_end_date End date of the period to which the
 * competence assessment applies
 * @param p_assessment_date The date of the competence assessment.
 * @param p_comments Comment text.
 * @param p_total_score Overall score derived from the sum of the individual
 * assessment line scores
 * @param p_status Status of the competence assessment. Valid values are
 * defined by the APPRAISAL_ASSESSMENT_STATUS lookup type.
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
 * @param p_object_version_number Pass in the current version number of the
 * assessment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assessment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Assessment
 * @rep:category BUSINESS_ENTITY PER_ASSESSMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_assessment
 (
  p_assessment_id                in number,
  p_assessment_type_id           in number           default hr_api.g_number,
  p_assessment_group_id          in number           default hr_api.g_number,
  p_assessment_period_start_date in date             default hr_api.g_date,
  p_assessment_period_end_date   in date             default hr_api.g_date,
  p_assessment_date              in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_total_score                  in number           default hr_api.g_number,
  p_status                       in varchar2         default hr_api.g_varchar2,
  --
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
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean      default false,
  p_effective_date               in date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_assessment >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an assessment.
 *
 * The assessment may hold the overall assessment score which is a sum of the
 * scores on each of the constituent assessment elements.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid assessment must exist.
 *
 * <p><b>Post Success</b><br>
 * Assessment is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Assessment is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assessment_id Assessment to be deleted. If p_validate is false,
 * uniquely identifies the assessment to be deleted. If p_validate is true, set
 * to null.
 * @param p_object_version_number Current version number of the assessment to
 * be deleted
 * @rep:displayname Delete Assessment
 * @rep:category BUSINESS_ENTITY PER_ASSESSMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_assessment
(p_validate                           in boolean default false,
 p_assessment_id                 in number,
 p_object_version_number         in number
);
--
end hr_assessments_api;

 

/
