--------------------------------------------------------
--  DDL for Package HR_COMPETENCES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCES_API" AUTHID CURRENT_USER as
/* $Header: pecpnapi.pkh 120.1 2005/11/28 03:21:27 dsaxby noship $ */
/*#
 * This package contains competences APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Competence
*/
--
-- Package variable
--
g_ignore_df varchar2(1) := 'N';
--
-- ----------------------------------------------------------------------------
-- |------------------------< <create_competence> >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API creates a competence.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The competence will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The competence will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_business_group_id {@rep:casecolumn
 * PER_COMPETENCES.BUSINESS_GROUP_ID}
 * @param p_description {@rep:casecolumn PER_COMPETENCES.DESCRIPTION}
 * @param p_competence_alias Competence alias
 * @param p_date_from {@rep:casecolumn PER_COMPETENCES.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PER_COMPETENCES.DATE_TO}
 * @param p_behavioural_indicator {@rep:casecolumn
 * PER_COMPETENCES.BEHAVIOURAL_INDICATOR}
 * @param p_certification_required Certification Requried, 'Yes' or 'No'. Valid
 * values are defined by 'YES_NO' lookup type
 * @param p_evaluation_method Evaluation Method. Valid values are defined by
 * 'COMPETENCE_EVAL_TYPE' lookup type.
 * @param p_renewal_period_frequency {@rep:casecolumn
 * PER_COMPETENCES.RENEWAL_PERIOD_FREQUENCY}
 * @param p_renewal_period_units Renewal period units. Valid values are defined
 * by 'FREQUENCY' lookup type.
 * @param p_rating_scale_id {@rep:casecolumn PER_COMPETENCES.RATING_SCALE_ID}
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
 * @param p_segment1 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT1}
 * @param p_segment2 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT2}
 * @param p_segment3 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT3}
 * @param p_segment4 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT4}
 * @param p_segment5 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT5}
 * @param p_segment6 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT6}
 * @param p_segment7 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT7}
 * @param p_segment8 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT8}
 * @param p_segment9 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT9}
 * @param p_segment10 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT10}
 * @param p_segment11 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT11}
 * @param p_segment12 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT12}
 * @param p_segment13 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT13}
 * @param p_segment14 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT14}
 * @param p_segment15 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT15}
 * @param p_segment16 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT16}
 * @param p_segment17 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT17}
 * @param p_segment18 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT18}
 * @param p_segment19 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT19}
 * @param p_segment20 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT20}
 * @param p_segment21 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT21}
 * @param p_segment22 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT22}
 * @param p_segment23 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT23}
 * @param p_segment24 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT24}
 * @param p_segment25 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT25}
 * @param p_segment26 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT26}
 * @param p_segment27 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT27}
 * @param p_segment28 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT28}
 * @param p_segment29 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT29}
 * @param p_segment30 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT30}
 * @param p_concat_segments Concatenated competence name
 * @param p_competence_id If p_validate is false, uniquely identifies the
 * competence created. If p_validate is true, set to null.
 * @param p_competence_definition_id If p_competence_definition_id is NULL, the
 * API creates a record in PER_COMPETENCE_DEFINITIONS and pass the
 * competence_definition_id. When the p_competence_definition_id is not NULL,
 * the API will be set to the same value which was passed in if p_validate is
 * false. If p_validate is true then will be set to the same value which was
 * passed in.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created competence. If p_validate is true, then the
 * value will be null.
 * @param p_name If p_validate is false, then this set competence name derive
 * from p_segment parameters or p_conct_segments parameter. If p_validate is
 * true, then set to null.
 * @param p_competence_cluster HR-XML Board specified field for competencies.
 * This determines whether the competence is a unit standard competence or
 * Normal competence.
 * @param p_unit_standard_id Unique registered Number / Code for the Unit
 * Standard.
 * @param p_credit_type Credits attached to the Unit Standard.
 * @param p_credits An indication of the value of the Unit Standard.
 * @param p_level_type Unit Standard Level type.
 * @param p_level_number Unit Standard Level. These level take into account the
 * depth of how the knowledge, skills, and values in a specific sub-field have
 * been advanced learning.
 * @param p_field Field of Learning applies to the specific Industry / Sector
 * for the Unit Standard.
 * @param p_sub_field Sub-field of the Unit Standard.
 * @param p_provider A unique code that identifies the Provider of the Unit
 * Standard. Trading Quality Assurance Organizations allocate these codes to
 * providers when they register with them.
 * @param p_qa_organization A code that identifies the Trading qualify
 * Assurance Organization that the provider is registered with.
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
 * @rep:displayname Create a Competence
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_competence
 (p_validate                     in     boolean  	default false,
  p_effective_date               in     date,
  p_language_code                in     varchar2 default hr_api.userenv_lang ,
  p_business_group_id            in 	number           default null,
  p_description                  in  	varchar2         default null,
  p_competence_alias             in     varchar2         default null,
  p_date_from                    in     date,
  p_date_to                      in     date 		 default null,
  p_behavioural_indicator        in 	varchar2         default null,
  p_certification_required       in 	varchar2         default 'N',
  p_evaluation_method            in 	varchar2         default null,
  p_renewal_period_frequency     in 	number           default null,
  p_renewal_period_units         in 	varchar2         default null,
  p_rating_scale_id              in     number		 default null,
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
  p_segment1			 in	varchar2	 default null,
  p_segment2			 in     varchar2         default null,
  p_segment3                     in     varchar2         default null,
  p_segment4                     in     varchar2         default null,
  p_segment5                     in     varchar2         default null,
  p_segment6                     in     varchar2         default null,
  p_segment7                     in     varchar2         default null,
  p_segment8                     in     varchar2         default null,
  p_segment9                     in     varchar2         default null,
  p_segment10                    in     varchar2         default null,
  p_segment11                    in     varchar2         default null,
  p_segment12                    in     varchar2         default null,
  p_segment13                    in     varchar2         default null,
  p_segment14                    in     varchar2         default null,
  p_segment15                    in     varchar2         default null,
  p_segment16                    in     varchar2         default null,
  p_segment17                    in     varchar2         default null,
  p_segment18                    in     varchar2         default null,
  p_segment19                    in     varchar2         default null,
  p_segment20                    in     varchar2         default null,
  p_segment21                    in     varchar2         default null,
  p_segment22                    in     varchar2         default null,
  p_segment23                    in     varchar2         default null,
  p_segment24                    in     varchar2         default null,
  p_segment25                    in     varchar2         default null,
  p_segment26                    in     varchar2         default null,
  p_segment27                    in     varchar2         default null,
  p_segment28                    in     varchar2         default null,
  p_segment29                    in     varchar2         default null,
  p_segment30                    in     varchar2         default null,
  p_concat_segments              in     varchar2         default null,
  p_competence_id                out nocopy    number,
  p_competence_definition_id     in out nocopy number,
  -- p_competence_definition_id     out number,
  p_object_version_number        out nocopy    number,
  p_name                         out nocopy    varchar2
 ,p_competence_cluster            in varchar2        default null
 ,p_unit_standard_id              in varchar2        default null
 ,p_credit_type                   in varchar2        default null
 ,p_credits                       in number          default null
 ,p_level_type                    in varchar2        default null
 ,p_level_number                  in number          default null
 ,p_field                         in varchar2        default null
 ,p_sub_field                     in varchar2        default null
 ,p_provider                      in varchar2        default null
 ,p_qa_organization               in varchar2        default null
 ,p_information_category          in varchar2        default null
 ,p_information1                  in varchar2        default null
 ,p_information2                  in varchar2        default null
 ,p_information3                  in varchar2        default null
 ,p_information4                  in varchar2        default null
 ,p_information5                  in varchar2        default null
 ,p_information6                  in varchar2        default null
 ,p_information7                  in varchar2        default null
 ,p_information8                  in varchar2        default null
 ,p_information9                  in varchar2        default null
 ,p_information10                 in varchar2        default null
 ,p_information11                 in varchar2        default null
 ,p_information12                 in varchar2        default null
 ,p_information13                 in varchar2        default null
 ,p_information14                 in varchar2        default null
 ,p_information15                 in varchar2        default null
 ,p_information16                 in varchar2        default null
 ,p_information17                 in varchar2        default null
 ,p_information18                 in varchar2        default null
 ,p_information19                 in varchar2        default null
 ,p_information20                 in varchar2        default null
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< <update_competence> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API updates the competence.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The competence must exist.
 *
 * <p><b>Post Success</b><br>
 * The competence will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The competence will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_competence_id {@rep:casecolumn PER_COMPETENCES.COMPETENCE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * competence to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated competence. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_name If p_validate is false, then this set competence name derive
 * from p_segment parameters or p_conct_segments parameter. If p_validate is
 * true, then set to null.
 * @param p_description {@rep:casecolumn PER_COMPETENCES.DESCRIPTION}
 * @param p_date_from {@rep:casecolumn PER_COMPETENCES.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PER_COMPETENCES.DATE_TO}
 * @param p_behavioural_indicator {@rep:casecolumn
 * PER_COMPETENCES.BEHAVIOURAL_INDICATOR}
 * @param p_certification_required Certification Requried, 'Yes' or 'No'. Valid
 * values are defined by 'YES_NO' lookup type
 * @param p_evaluation_method Evaluation Method. Valid values are defined by
 * 'COMPETENCE_EVAL_TYPE' lookup type.
 * @param p_renewal_period_frequency {@rep:casecolumn
 * PER_COMPETENCES.RENEWAL_PERIOD_FREQUENCY}
 * @param p_renewal_period_units Renewal period units. Valid values are defined
 * by 'FREQUENCY' lookup type.
 * @param p_rating_scale_id {@rep:casecolumn PER_COMPETENCES.RATING_SCALE_ID}
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
 * @param p_competence_alias Competence alias
 * @param p_segment1 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT1}
 * @param p_segment2 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT2}
 * @param p_segment3 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT3}
 * @param p_segment4 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT4}
 * @param p_segment5 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT5}
 * @param p_segment6 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT6}
 * @param p_segment7 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT7}
 * @param p_segment8 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT8}
 * @param p_segment9 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT9}
 * @param p_segment10 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT10}
 * @param p_segment11 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT11}
 * @param p_segment12 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT12}
 * @param p_segment13 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT13}
 * @param p_segment14 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT14}
 * @param p_segment15 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT15}
 * @param p_segment16 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT16}
 * @param p_segment17 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT17}
 * @param p_segment18 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT18}
 * @param p_segment19 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT19}
 * @param p_segment20 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT20}
 * @param p_segment21 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT21}
 * @param p_segment22 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT22}
 * @param p_segment23 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT23}
 * @param p_segment24 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT24}
 * @param p_segment25 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT25}
 * @param p_segment26 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT26}
 * @param p_segment27 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT27}
 * @param p_segment28 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT28}
 * @param p_segment29 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT29}
 * @param p_segment30 {@rep:casecolumn PER_COMPETENCE_DEFINITIONS.SEGMENT30}
 * @param p_concat_segments Concatenated competence name
 * @param p_competence_definition_id Unique identifier of the competence
 * definition to update.
 * @param p_competence_cluster HR-XML Board specified field for competencies.
 * This determines whether the competence is a unit standard competence or
 * Normal competence.
 * @param p_unit_standard_id Unique registered Number / Code for the Unit
 * Standard.
 * @param p_credit_type Credits attached to the Unit Standard.
 * @param p_credits An indication of the value of the Unit Standard.
 * @param p_level_type Unit Standard Level type.
 * @param p_level_number Unit Standard Level. These level take into account the
 * depth of how the knowledge, skills, and values in a specific sub-field have
 * been advanced learning.
 * @param p_field Field of Learning applies to the specific Industry / Sector
 * for the Unit Standard.
 * @param p_sub_field Sub-field of the Unit Standard.
 * @param p_provider A unique code that identifies the Provider of the Unit
 * Standard. Trading Quality Assurance Organizations allocate these codes to
 * providers when they register with them.
 * @param p_qa_organization A code that identifies the Trading qualify
 * Assurance Organization that the provider is registered with.
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
 * @rep:displayname Update a Competence
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
procedure update_competence
 (p_validate                     in boolean          default false,
  p_effective_date               in date,
  p_competence_id                in number,
  p_object_version_number        in out nocopy number,
  p_language_code                 in     varchar2 default hr_api.userenv_lang ,
  p_name                         out nocopy varchar2 ,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_date_from                    in date	     default hr_api.g_date,
  p_date_to                      in date	     default hr_api.g_date,
  p_behavioural_indicator        in varchar2         default hr_api.g_varchar2,
  p_certification_required       in varchar2         default hr_api.g_varchar2,
  p_evaluation_method            in varchar2         default hr_api.g_varchar2,
  p_renewal_period_frequency     in number           default hr_api.g_number,
  p_renewal_period_units         in varchar2         default hr_api.g_varchar2,
  p_rating_scale_id              in number	     default hr_api.g_number,
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
  p_competence_alias             in varchar2         default hr_api.g_varchar2,
  p_segment1                     in varchar2         default hr_api.g_varchar2,
  p_segment2                     in varchar2         default hr_api.g_varchar2,
  p_segment3                     in varchar2         default hr_api.g_varchar2,
  p_segment4                     in varchar2         default hr_api.g_varchar2,
  p_segment5                     in varchar2         default hr_api.g_varchar2,
  p_segment6                     in varchar2         default hr_api.g_varchar2,
  p_segment7                     in varchar2         default hr_api.g_varchar2,
  p_segment8                     in varchar2         default hr_api.g_varchar2,
  p_segment9                     in varchar2         default hr_api.g_varchar2,
  p_segment10                    in varchar2         default hr_api.g_varchar2,
  p_segment11                    in varchar2         default hr_api.g_varchar2,
  p_segment12                    in varchar2         default hr_api.g_varchar2,
  p_segment13                    in varchar2         default hr_api.g_varchar2,
  p_segment14                    in varchar2         default hr_api.g_varchar2,
  p_segment15                    in varchar2         default hr_api.g_varchar2,
  p_segment16                    in varchar2         default hr_api.g_varchar2,
  p_segment17                    in varchar2         default hr_api.g_varchar2,
  p_segment18                    in varchar2         default hr_api.g_varchar2,
  p_segment19                    in varchar2         default hr_api.g_varchar2,
  p_segment20                    in varchar2         default hr_api.g_varchar2,
  p_segment21                    in varchar2         default hr_api.g_varchar2,
  p_segment22                    in varchar2         default hr_api.g_varchar2,
  p_segment23                    in varchar2         default hr_api.g_varchar2,
  p_segment24                    in varchar2         default hr_api.g_varchar2,
  p_segment25                    in varchar2         default hr_api.g_varchar2,
  p_segment26                    in varchar2         default hr_api.g_varchar2,
  p_segment27                    in varchar2         default hr_api.g_varchar2,
  p_segment28                    in varchar2         default hr_api.g_varchar2,
  p_segment29                    in varchar2         default hr_api.g_varchar2,
  p_segment30                    in varchar2         default hr_api.g_varchar2,
  p_concat_segments              in varchar2         default hr_api.g_varchar2,
  p_competence_definition_id     in out nocopy number
 ,p_competence_cluster           in varchar2         default hr_api.g_varchar2
 ,p_unit_standard_id             in varchar2         default hr_api.g_varchar2
 ,p_credit_type                  in varchar2         default hr_api.g_varchar2
 ,p_credits                      in number           default hr_api.g_number
 ,p_level_type                   in varchar2         default hr_api.g_varchar2
 ,p_level_number                 in number           default hr_api.g_number
 ,p_field                        in varchar2         default hr_api.g_varchar2
 ,p_sub_field                    in varchar2         default hr_api.g_varchar2
 ,p_provider                     in varchar2         default hr_api.g_varchar2
 ,p_qa_organization              in varchar2         default hr_api.g_varchar2
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
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< <delete_competence> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API deletes the competence.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The competence must exist.
 *
 * <p><b>Post Success</b><br>
 * The competence will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The competence will not be deleted and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_competence_id {@rep:casecolumn PER_COMPETENCES.COMPETENCE_ID}
 * @param p_object_version_number Current version number of the competence to
 * be deleted.
 * @rep:displayname Delete a Competence
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_competence
(p_validate                           in boolean default false,
 p_competence_id                      in number,
 p_object_version_number              in number
);
--
-- ----------------------------------------------------------------------------
-- |-------------------< <create_or_update_competence> >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API creates a competence if the name does not exist and updates the
 * competence if the name already exists.
 *
 * This API is used for skills vendor integration.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The competence will have been created or updated.
 *
 * <p><b>Post Failure</b><br>
 * The competence will not be created or updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_category Category name
 * @param p_name Competence name
 * @param p_date_from {@rep:casecolumn PER_COMPETENCES.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PER_COMPETENCES.DATE_TO}
 * @param p_description {@rep:casecolumn PER_COMPETENCES.DESCRIPTION}
 * @param p_competence_alias Competence alias
 * @param p_behavioural_indicator {@rep:casecolumn
 * PER_COMPETENCES.BEHAVIOURAL_INDICATOR}
 * @param p_certification_required Certification Requried, 'Yes' or 'No'. Valid
 * values are defined by 'YES_NO' lookup type
 * @param p_evaluation_method Evaluation Method. Valid values are defined by
 * 'COMPETENCE_EVAL_TYPE' lookup type.
 * @param p_renewal_period_frequency {@rep:casecolumn
 * PER_COMPETENCES.RENEWAL_PERIOD_FREQUENCY}
 * @param p_renewal_period_units Renewal period units. Valid values are defined
 * by 'FREQUENCY' lookup type.
 * @param p_rating_scale_name Rating scale name
 * @param p_translated_language If the name parameter is translated, this is
 * the language code for the name
 * @param p_source_category_name This is the category name with the source
 * language code
 * @param p_source_competence_name This is the competence name with the source
 * language code
 * @rep:displayname Create or Update a Competence
 * @rep:category BUSINESS_ENTITY PER_COMPETENCE
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_or_update_competence
 (p_validate                     in     boolean      default false
 ,p_effective_date               in     date         default trunc(sysdate)
 ,p_language_code                in     varchar2     default hr_api.userenv_lang
 ,p_category                     in     varchar2     default null
 ,p_name                         in     varchar2     default null
 ,p_date_from                    in     date         default trunc(sysdate)
 ,p_date_to                      in     date         default null
 ,p_description                  in     varchar2     default null
 ,p_competence_alias             in     varchar2     default null
 ,p_behavioural_indicator        in     varchar2     default null
 ,p_certification_required       in     varchar2     default null
 ,p_evaluation_method            in     varchar2     default null
 ,p_renewal_period_frequency     in     number       default null
 ,p_renewal_period_units         in     varchar2     default null
 ,p_rating_scale_name            in     varchar2     default null
 ,p_translated_language          in     varchar2     default null
 ,p_source_category_name         in     varchar2     default null
 ,p_source_competence_name       in     varchar2     default null
  );
--
end hr_competences_api;

 

/
