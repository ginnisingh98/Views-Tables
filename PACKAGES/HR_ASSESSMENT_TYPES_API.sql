--------------------------------------------------------
--  DDL for Package HR_ASSESSMENT_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSESSMENT_TYPES_API" AUTHID CURRENT_USER as
/* $Header: peastapi.pkh 120.2 2006/02/09 07:43:16 sansingh noship $ */
/*#
 * This package contains APIs relating to assessment types.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assessment Type
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_assessment_type >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new assessment type.
 *
 * An assessment type is used to define the set of competences that should be
 * evaluated in any given assessment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Business group must exist for which assessment type is being created.
 *
 * <p><b>Post Success</b><br>
 * Assessment type is created.
 *
 * <p><b>Post Failure</b><br>
 * Assessment type is not created and an error is raised.
 * @param p_assessment_type_id If p_validate is false, uniquely identifies the
 * assessment type created. If p_validate is true, set to null.
 * @param p_name Name of the assessment type.
 * @param p_business_group_id Business group in which assessment type is
 * created.
 * @param p_description Description of the assessment type.
 * @param p_rating_scale_id Identifies the rating scale. This is mandatory if
 * the assessment classification is PERFORMANCE or BOTH.
 * @param p_weighting_scale_id Identifies the rating scale of type WEIGHTING
 * @param p_rating_scale_comment Comment text for the rating scale. If the
 * rating scale is null, this has to be null.
 * @param p_weighting_scale_comment Comment text for the weighting scale. If
 * weighting scale is null, then this has to null.
 * @param p_assessment_classification Type of assessment. Valid values are
 * defined by 'ASSESSMENT_CLASSIFICATION' lookup type.
 * @param p_display_assessment_comments Indicates whether the comments item
 * should be displayed on the questionnaire. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_date_from Date when the assessment type is available for use.
 * @param p_date_to Date when the assessment type becomes unavailable for use.
 * @param p_comments Comment text.
 * @param p_instructions General instructions to be displayed on assessment.
 * @param p_weighting_classification Indicates whether the weighing value
 * applies to the proficiency level or performance rating. Valid values are
 * defined in ASSESSMENT_CLASSIFICATION lookup type. If the assessment
 * classification is Both, and there is a weighting scale, this states whether
 * to apply the weighting scale to the performance or proficient value.
 * @param p_line_score_formula Formula to calculate the score for each
 * assessment line. Valid values are defined by 'ASSESSMENT_LINE_FORMULA'
 * lookup type.
 * @param p_total_score_formula Formula to calculate total score. Valid values
 * are defined by 'ASSESSMENT_TOTAL_FORMULA' lookup type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assessment type. If p_validate is true, then
 * the value will be null.
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
 * @param p_type  newly added column for supporting Objective templates also
 * Valid values are defined in lookup ASSESSMENT_TYPE
 * @param p_line_score_formula_id  newly added column for storing fast formula id for
 * calculating  line_score
 * @param p_default_job_competencies newly added column , the column indicated whether
 * the competency assessment template should default a person's job competencies or not
 * @param p_available_flag indicates whether the template is published or unpublished
 * Valid values are defined against lookup TEMPLATE_AVAILABILITY_FLAG
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Assessment Type
 * @rep:category BUSINESS_ENTITY PER_ASSESSMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_assessment_type
 (p_assessment_type_id           out nocopy    number,
  p_name                         in     varchar2,
  p_business_group_id            in     number,
  p_description                  in     varchar2         default null,
  p_rating_scale_id              in     number           default null,
  p_weighting_scale_id           in     number           default null,
  p_rating_scale_comment         in     varchar2         default null,
  p_weighting_scale_comment      in     varchar2         default null,
  p_assessment_classification    in     varchar2,
  p_display_assessment_comments  in     varchar2         default 'Y',
  p_date_from                    in     date,
  p_date_to                      in     date,
  p_comments                     in     varchar2         default null,
  p_instructions                 in     varchar2         default null,
  p_weighting_classification     in     varchar2         default null,
  p_line_score_formula           in     varchar2         default null,
  p_total_score_formula          in     varchar2         default null,
  p_object_version_number        out nocopy    number,
  p_attribute_category           in 	varchar2         default null,
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
  p_type                         in	varchar2,
  p_line_score_formula_id        in	number		default null,
  p_default_job_competencies     in	varchar2	default null,
  p_available_flag		 in	varchar2	default null,
  p_validate                     in     boolean		default false,
  p_effective_date               in     date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_assessment_type >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates assessment type.
 *
 * An assessment type is used to define the set of competences that should be
 * evaluated in any given assessment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid assessment type must exist.
 *
 * <p><b>Post Success</b><br>
 * Assessment type is updated.
 *
 * <p><b>Post Failure</b><br>
 * Assessment type remains unchanged and an error is raised.
 * @param p_assessment_type_id Identifies the assessment type record to be
 * updated.
 * @param p_name Name of the assessment type.
 * @param p_description Description of the assessment type.
 * @param p_rating_scale_id The rating scale used in the assessment template.
 * This is mandatory if the assessment classification is PERFORMANCE or BOTH.
 * @param p_weighting_scale_id Identifies the rating scale of type WEIGHTING
 * @param p_rating_scale_comment Comment text about the rating scale. If the
 * rating scale is null, this has to be null.
 * @param p_weighting_scale_comment Comment text about the weighting scale. If
 * weighting scale is null, then this has to be null.
 * @param p_assessment_classification Type of assessment. Valid values are
 * defined by 'ASSESSMENT_CLASSIFICATION' lookup type.
 * @param p_display_assessment_comments Indicates whether the comments item
 * should be displayed on the questionnaire. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_date_from Date when the assessment type is available for use.
 * @param p_date_to Date when the assessment type becomes unavailable for use.
 * @param p_comments Comment text.
 * @param p_instructions General instructions to be displayed on assessment.
 * @param p_weighting_classification Indicates whether the weighing value
 * applies to the proficiency level or performance rating. Valid values are
 * defined in ASSESSMENT_CLASSIFICATION lookup type. If the assessment
 * classification is Both, and there is a weighting scale, this states whether
 * to apply the weighting scale to the performance or proficient value.
 * @param p_line_score_formula Formula to calculate the score for each
 * assessment line. Valid values are defined by 'ASSESSMENT_LINE_FORMULA'
 * lookup type.
 * @param p_total_score_formula Formula to calculate total score. Valid values
 * are defined by 'ASSESSMENT_TOTAL_FORMULA' lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * assessment type to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated assessment type.
 * If p_validate is true will be set to the same value which was passed in.
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
 * @param p_type  newly added column for supporting Objective templates also
 * Valid values are defined in lookup ASSESSMENT_TYPE
 * @param p_line_score_formula_id  newly added column for storing fast formula id for
 * calculating  line_score
 * @param p_default_job_competencies newly added column , the column indicated whether
 * the competency assessment template should default a person's job competencies or not
 * @param p_available_flag indicates whether the template is published or unpublished
 * Valid values are defined against lookup TEMPLATE_AVAILABILITY_FLAG
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Assessment Type
 * @rep:category BUSINESS_ENTITY PER_ASSESSMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_assessment_type
 (p_assessment_type_id           in number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_rating_scale_id              in number           default hr_api.g_number,
  p_weighting_scale_id           in number           default hr_api.g_number,
  p_rating_scale_comment         in varchar2         default hr_api.g_varchar2,
  p_weighting_scale_comment      in varchar2         default hr_api.g_varchar2,
  p_assessment_classification    in varchar2         default hr_api.g_varchar2,
  p_display_assessment_comments  in varchar2         default hr_api.g_varchar2,
  p_date_from                    in date             default hr_api.g_date,
  p_date_to                      in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_instructions                 in varchar2         default hr_api.g_varchar2,
  p_weighting_classification     in varchar2         default hr_api.g_varchar2,
  p_line_score_formula           in varchar2         default hr_api.g_varchar2,
  p_total_score_formula          in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
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
  p_type                         in varchar2	     default hr_api.g_varchar2,
  p_line_score_formula_id        in number	    default  hr_api.g_number,
  p_default_job_competencies     in varchar2	    default hr_api.g_varchar2,
  p_available_flag		 in varchar2	    default hr_api.g_varchar2,
  p_validate                     in boolean        default false,
  p_effective_date               in date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_assessment_type >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes assessment type.
 *
 * An assessment type is used to define the set of competences which should be
 * evaluated in any given assessment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid assessment type must exist.
 *
 * <p><b>Post Success</b><br>
 * Assessment type is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Assessment type is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assessment_type_id Assessment type to be deleted. If p_validate is
 * false, uniquely identifies the assessment type to be deleted. If p_validate
 * is true, set to null.
 * @param p_object_version_number Current version number of the assessment type
 * to be deleted.
 * @rep:displayname Delete Assessment Type
 * @rep:category BUSINESS_ENTITY PER_ASSESSMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_assessment_type
(p_validate                           in boolean default false,
 p_assessment_type_id                 in number,
 p_object_version_number              in number
);
--
end hr_assessment_types_api;

 

/
