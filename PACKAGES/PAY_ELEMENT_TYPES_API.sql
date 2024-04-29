--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TYPES_API" AUTHID CURRENT_USER as
/* $Header: pyetpapi.pkh 120.2.12010000.2 2008/08/06 07:12:24 ubhat ship $ */
/*#
 * This package contains element type APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Element Type
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_element_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to create a new element type as of the effective date.
 *
 * The role of this process is to insert a fully validated row into the
 * pay_element_types_f table of the HR schema along with any default input
 * values required by the element type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element classification must already exist.
 *
 * <p><b>Post Success</b><br>
 * The element type will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The element type will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_classification_id {@rep:casecolumn
 * PAY_ELEMENT_CLASSIFICATIONS.CLASSIFICATION_ID}
 * @param p_element_name {@rep:casecolumn PAY_ELEMENT_TYPES_F.ELEMENT_NAME}
 * @param p_input_currency_code {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.INPUT_CURRENCY_CODE}
 * @param p_output_currency_code {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.OUTPUT_CURRENCY_CODE}
 * @param p_multiple_entries_allowed_fla {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.MULTIPLE_ENTRIES_ALLOWED_FLAG}
 * @param p_processing_type {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.PROCESSING_TYPE}
 * @param p_business_group_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.BUSINESS_GROUP_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.LEGISLATION_CODE}
 * @param p_formula_id {@rep:casecolumn PAY_ELEMENT_TYPES_F.FORMULA_ID}
 * @param p_benefit_classification_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.BENEFIT_CLASSIFICATION_ID}
 * @param p_additional_entry_allowed_fla {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ADDITIONAL_ENTRY_ALLOWED_FLAG}
 * @param p_adjustment_only_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ADJUSTMENT_ONLY_FLAG}
 * @param p_closed_for_entry_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.CLOSED_FOR_ENTRY_FLAG}
 * @param p_reporting_name {@rep:casecolumn PAY_ELEMENT_TYPES_F.REPORTING_NAME}
 * @param p_description {@rep:casecolumn PAY_ELEMENT_TYPES_F.DESCRIPTION}
 * @param p_indirect_only_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.INDIRECT_ONLY_FLAG}
 * @param p_multiply_value_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.MULTIPLY_VALUE_FLAG}
 * @param p_post_termination_rule {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.POST_TERMINATION_RULE}
 * @param p_process_in_run_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.PROCESS_IN_RUN_FLAG}
 * @param p_processing_priority {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.PROCESSING_PRIORITY}
 * @param p_standard_link_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.STANDARD_LINK_FLAG}
 * @param p_comments Element type comment text.
 * @param p_third_party_pay_only_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.THIRD_PARTY_PAY_ONLY_FLAG}
 * @param p_iterative_flag {@rep:casecolumn PAY_ELEMENT_TYPES_F.ITERATIVE_FLAG}
 * @param p_iterative_formula_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ITERATIVE_FORMULA_ID}
 * @param p_iterative_priority {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ITERATIVE_PRIORITY}
 * @param p_creator_type {@rep:casecolumn PAY_ELEMENT_TYPES_F.CREATOR_TYPE}
 * @param p_retro_summ_ele_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.RETRO_SUMM_ELE_ID}
 * @param p_grossup_flag {@rep:casecolumn PAY_ELEMENT_TYPES_F.GROSSUP_FLAG}
 * @param p_process_mode {@rep:casecolumn PAY_ELEMENT_TYPES_F.PROCESS_MODE}
 * @param p_advance_indicator {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ADVANCE_INDICATOR}
 * @param p_advance_payable {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ADVANCE_PAYABLE}
 * @param p_advance_deduction {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ADVANCE_DEDUCTION}
 * @param p_process_advance_entry {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.PROCESS_ADVANCE_ENTRY}
 * @param p_proration_group_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.PRORATION_GROUP_ID}
 * @param p_proration_formula_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.PRORATION_FORMULA_ID}
 * @param p_recalc_event_group_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.RECALC_EVENT_GROUP_ID}
 * @param p_legislation_subgroup {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.LEGISLATION_SUBGROUP}
 * @param p_qualifying_age {@rep:casecolumn PAY_ELEMENT_TYPES_F.QUALIFYING_AGE}
 * @param p_qualifying_length_of_service {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.QUALIFYING_LENGTH_OF_SERVICE}
 * @param p_qualifying_units {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.QUALIFYING_UNITS}
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
 * @param p_element_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_element_information1 Developer Descriptive flexfield segment.
 * @param p_element_information2 Developer Descriptive flexfield segment.
 * @param p_element_information3 Developer Descriptive flexfield segment.
 * @param p_element_information4 Developer Descriptive flexfield segment.
 * @param p_element_information5 Developer Descriptive flexfield segment.
 * @param p_element_information6 Developer Descriptive flexfield segment.
 * @param p_element_information7 Developer Descriptive flexfield segment.
 * @param p_element_information8 Developer Descriptive flexfield segment.
 * @param p_element_information9 Developer Descriptive flexfield segment.
 * @param p_element_information10 Developer Descriptive flexfield segment.
 * @param p_element_information11 Developer Descriptive flexfield segment.
 * @param p_element_information12 Developer Descriptive flexfield segment.
 * @param p_element_information13 Developer Descriptive flexfield segment.
 * @param p_element_information14 Developer Descriptive flexfield segment.
 * @param p_element_information15 Developer Descriptive flexfield segment.
 * @param p_element_information16 Developer Descriptive flexfield segment.
 * @param p_element_information17 Developer Descriptive flexfield segment.
 * @param p_element_information18 Developer Descriptive flexfield segment.
 * @param p_element_information19 Developer Descriptive flexfield segment.
 * @param p_element_information20 Developer Descriptive flexfield segment.
 * @param p_default_uom Unit of measure to be used for all default input
 * values.
 * @param p_once_each_period_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ONCE_EACH_PERIOD_FLAG}
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_time_definition_type Specifies the time definition type.
 * @param p_time_definition_id   Specifies the time definition.
 * @param p_element_type_id If p_validate is false, uniquely identifies the
 * element type created. If p_validate is true, set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created element type. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created element type. If p_validate is true, then
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created element type. If p_validate is true, then the
 * value will be null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created element type comment
 * record. If p_validate is true or no comment text was provided, then will be
 * null.
 * @param p_processing_priority_warning If set to true, then the processing
 * priority is not in range for the element classification.
 * @rep:displayname Create Element Type
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_ELEMENT_TYPE
  (p_validate                        in  boolean  default false
  ,p_effective_date                  in  date
  ,p_classification_id               in  number
  ,p_element_name                    in  varchar2
  ,p_input_currency_code             in  varchar2
  ,p_output_currency_code            in  varchar2
  ,p_multiple_entries_allowed_fla    in  varchar2
  ,p_processing_type                 in  varchar2
  ,p_business_group_id               in  number   default null
  ,p_legislation_code                in  varchar2 default null
  ,p_formula_id                      in  number   default null
  ,p_benefit_classification_id       in  number   default null
  ,p_additional_entry_allowed_fla    in  varchar2 default 'N'
  ,p_adjustment_only_flag            in  varchar2 default 'N'
  ,p_closed_for_entry_flag           in  varchar2 default 'N'
  ,p_reporting_name                  in  varchar2 default null
  ,p_description                     in  varchar2 default null
  ,p_indirect_only_flag              in  varchar2 default 'N'
  ,p_multiply_value_flag             in  varchar2 default 'N'
  ,p_post_termination_rule           in  varchar2 default 'L'
  ,p_process_in_run_flag             in  varchar2 default 'Y'
  ,p_processing_priority             in  number   default null
  ,p_standard_link_flag              in  varchar2 default 'N'
  ,p_comments                        in  varchar2 default null
  ,p_third_party_pay_only_flag       in	 varchar2 default null
  ,p_iterative_flag                  in	 varchar2 default null
  ,p_iterative_formula_id            in	 number	  default null
  ,p_iterative_priority              in	 number	  default null
  ,p_creator_type                    in	 varchar2 default null
  ,p_retro_summ_ele_id               in  number   default null
  ,p_grossup_flag                    in	 varchar2 default null
  ,p_process_mode                    in	 varchar2 default null
  ,p_advance_indicator               in	 varchar2 default null
  ,p_advance_payable                 in	 varchar2 default null
  ,p_advance_deduction               in	 varchar2 default null
  ,p_process_advance_entry           in	 varchar2 default null
  ,p_proration_group_id              in	 number	  default null
  ,p_proration_formula_id            in	 number	  default null
  ,p_recalc_event_group_id 	     in  number	  default null
  ,p_legislation_subgroup            in  varchar2 default null
  ,p_qualifying_age                  in  number   default null
  ,p_qualifying_length_of_service    in  number   default null
  ,p_qualifying_units                in  varchar2 default null
  ,p_attribute_category              in  varchar2 default null
  ,p_attribute1                      in	 varchar2 default null
  ,p_attribute2                      in	 varchar2 default null
  ,p_attribute3                      in	 varchar2 default null
  ,p_attribute4                      in	 varchar2 default null
  ,p_attribute5                      in	 varchar2 default null
  ,p_attribute6                      in	 varchar2 default null
  ,p_attribute7                      in	 varchar2 default null
  ,p_attribute8                      in	 varchar2 default null
  ,p_attribute9                      in	 varchar2 default null
  ,p_attribute10                     in	 varchar2 default null
  ,p_attribute11                     in	 varchar2 default null
  ,p_attribute12                     in	 varchar2 default null
  ,p_attribute13                     in	 varchar2 default null
  ,p_attribute14                     in	 varchar2 default null
  ,p_attribute15                     in	 varchar2 default null
  ,p_attribute16                     in	 varchar2 default null
  ,p_attribute17                     in	 varchar2 default null
  ,p_attribute18                     in	 varchar2 default null
  ,p_attribute19                     in	 varchar2 default null
  ,p_attribute20                     in	 varchar2 default null
  ,p_element_information_category    in	 varchar2 default null
  ,p_element_information1            in	 varchar2 default null
  ,p_element_information2            in	 varchar2 default null
  ,p_element_information3            in	 varchar2 default null
  ,p_element_information4            in	 varchar2 default null
  ,p_element_information5            in	 varchar2 default null
  ,p_element_information6            in	 varchar2 default null
  ,p_element_information7            in	 varchar2 default null
  ,p_element_information8            in	 varchar2 default null
  ,p_element_information9            in	 varchar2 default null
  ,p_element_information10           in	 varchar2 default null
  ,p_element_information11           in	 varchar2 default null
  ,p_element_information12           in	 varchar2 default null
  ,p_element_information13           in	 varchar2 default null
  ,p_element_information14           in	 varchar2 default null
  ,p_element_information15           in	 varchar2 default null
  ,p_element_information16           in	 varchar2 default null
  ,p_element_information17           in	 varchar2 default null
  ,p_element_information18           in	 varchar2 default null
  ,p_element_information19           in	 varchar2 default null
  ,p_element_information20           in	 varchar2 default null
  ,p_default_uom		     in  varchar2 default null
  ,p_once_each_period_flag           in  varchar2 default 'N'
  ,p_language_code                   in  varchar2 default hr_api.userenv_lang
  ,p_time_definition_type	     in  varchar2 default null
  ,p_time_definition_id		     in  number   default null
  ,p_advance_element_type_id         in  number   default null
  ,p_deduction_element_type_id       in  number   default null
  ,p_element_type_id                 out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_object_version_number           out nocopy number
  ,p_comment_id			     out nocopy number
  ,p_processing_priority_warning     out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_element_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to update an element type as of the effective date.
 *
 * The role of this process is to perform a validated, date-effective update of
 * an existing row in the pay_element_types_f table of the HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element type specified by the in parameter p_element_type_id and the in
 * out parameter p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The element type will have been successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The element type will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_element_type_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * element type to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated element type. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_formula_id {@rep:casecolumn PAY_ELEMENT_TYPES_F.FORMULA_ID}
 * @param p_benefit_classification_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.BENEFIT_CLASSIFICATION_ID}
 * @param p_additional_entry_allowed_fla {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ADDITIONAL_ENTRY_ALLOWED_FLAG}
 * @param p_adjustment_only_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ADJUSTMENT_ONLY_FLAG}
 * @param p_closed_for_entry_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.CLOSED_FOR_ENTRY_FLAG}
 * @param p_element_name {@rep:casecolumn PAY_ELEMENT_TYPES_F.ELEMENT_NAME}
 * @param p_reporting_name {@rep:casecolumn PAY_ELEMENT_TYPES_F.REPORTING_NAME}
 * @param p_description {@rep:casecolumn PAY_ELEMENT_TYPES_F.DESCRIPTION}
 * @param p_indirect_only_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.INDIRECT_ONLY_FLAG}
 * @param p_multiple_entries_allowed_fla {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.MULTIPLE_ENTRIES_ALLOWED_FLAG}
 * @param p_multiply_value_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.MULTIPLY_VALUE_FLAG}
 * @param p_post_termination_rule {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.POST_TERMINATION_RULE}
 * @param p_process_in_run_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.PROCESS_IN_RUN_FLAG}
 * @param p_processing_priority {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.PROCESSING_PRIORITY}
 * @param p_standard_link_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.STANDARD_LINK_FLAG}
 * @param p_comments Element type comment text.
 * @param p_third_party_pay_only_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.THIRD_PARTY_PAY_ONLY_FLAG}
 * @param p_iterative_flag {@rep:casecolumn PAY_ELEMENT_TYPES_F.ITERATIVE_FLAG}
 * @param p_iterative_formula_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ITERATIVE_FORMULA_ID}
 * @param p_iterative_priority {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ITERATIVE_PRIORITY}
 * @param p_creator_type {@rep:casecolumn PAY_ELEMENT_TYPES_F.CREATOR_TYPE}
 * @param p_retro_summ_ele_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.RETRO_SUMM_ELE_ID}
 * @param p_grossup_flag {@rep:casecolumn PAY_ELEMENT_TYPES_F.GROSSUP_FLAG}
 * @param p_process_mode {@rep:casecolumn PAY_ELEMENT_TYPES_F.PROCESS_MODE}
 * @param p_advance_indicator {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ADVANCE_INDICATOR}
 * @param p_advance_payable {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ADVANCE_PAYABLE}
 * @param p_advance_deduction {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ADVANCE_DEDUCTION}
 * @param p_process_advance_entry {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.PROCESS_ADVANCE_ENTRY}
 * @param p_proration_group_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.PRORATION_GROUP_ID}
 * @param p_proration_formula_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.PRORATION_FORMULA_ID}
 * @param p_recalc_event_group_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.RECALC_EVENT_GROUP_ID}
 * @param p_qualifying_age {@rep:casecolumn PAY_ELEMENT_TYPES_F.QUALIFYING_AGE}
 * @param p_qualifying_length_of_service {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.QUALIFYING_LENGTH_OF_SERVICE}
 * @param p_qualifying_units {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.QUALIFYING_UNITS}
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
 * @param p_element_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_element_information1 Developer Descriptive flexfield segment.
 * @param p_element_information2 Developer Descriptive flexfield segment.
 * @param p_element_information3 Developer Descriptive flexfield segment.
 * @param p_element_information4 Developer Descriptive flexfield segment.
 * @param p_element_information5 Developer Descriptive flexfield segment.
 * @param p_element_information6 Developer Descriptive flexfield segment.
 * @param p_element_information7 Developer Descriptive flexfield segment.
 * @param p_element_information8 Developer Descriptive flexfield segment.
 * @param p_element_information9 Developer Descriptive flexfield segment.
 * @param p_element_information10 Developer Descriptive flexfield segment.
 * @param p_element_information11 Developer Descriptive flexfield segment.
 * @param p_element_information12 Developer Descriptive flexfield segment.
 * @param p_element_information13 Developer Descriptive flexfield segment.
 * @param p_element_information14 Developer Descriptive flexfield segment.
 * @param p_element_information15 Developer Descriptive flexfield segment.
 * @param p_element_information16 Developer Descriptive flexfield segment.
 * @param p_element_information17 Developer Descriptive flexfield segment.
 * @param p_element_information18 Developer Descriptive flexfield segment.
 * @param p_element_information19 Developer Descriptive flexfield segment.
 * @param p_element_information20 Developer Descriptive flexfield segment.
 * @param p_once_each_period_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ONCE_EACH_PERIOD_FLAG}
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_time_definition_type Specifies the time definition type.
 * @param p_time_definition_id   Specifies the time definition.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated element type row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated element type row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_comment_id If p_validate is false and new or existing comment text
 * exists, then will be set to the identifier of the element type comment
 * record. If p_validate is true or no comment text exists, then will be null.
 * @param p_processing_priority_warning If set to true, then the processing
 * priority is not in range for the element classification.
 * @param p_element_name_warning If set to true, then the source language for
 * the translated element record is different from p_language_code when the
 * element name is changed.
 * @param p_element_name_change_warning If set to true, then the element name
 * has changed.
 * @rep:displayname Update Element Type
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_ELEMENT_TYPE
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_datetrack_update_mode	     in     varchar2
  ,p_element_type_id        	     in     number
  ,p_object_version_number  	     in out nocopy number
  ,p_formula_id                      in     number   default hr_api.g_number
  ,p_benefit_classification_id       in     number   default hr_api.g_number
  ,p_additional_entry_allowed_fla    in     varchar2 default hr_api.g_varchar2
  ,p_adjustment_only_flag            in     varchar2 default hr_api.g_varchar2
  ,p_closed_for_entry_flag           in     varchar2 default hr_api.g_varchar2
  ,p_element_name                    in	    varchar2 default hr_api.g_varchar2
  ,p_reporting_name                  in     varchar2 default hr_api.g_varchar2
  ,p_description                     in     varchar2 default hr_api.g_varchar2
  ,p_indirect_only_flag              in     varchar2 default hr_api.g_varchar2
  ,p_multiple_entries_allowed_fla    in     varchar2 default hr_api.g_varchar2
  ,p_multiply_value_flag             in     varchar2 default hr_api.g_varchar2
  ,p_post_termination_rule           in     varchar2 default hr_api.g_varchar2
  ,p_process_in_run_flag             in     varchar2 default hr_api.g_varchar2
  ,p_processing_priority             in     number   default hr_api.g_number
  ,p_standard_link_flag              in     varchar2 default hr_api.g_varchar2
  ,p_comments                        in     varchar2 default hr_api.g_varchar2
  ,p_third_party_pay_only_flag       in	    varchar2 default hr_api.g_varchar2
  ,p_iterative_flag                  in	    varchar2 default hr_api.g_varchar2
  ,p_iterative_formula_id            in	    number   default hr_api.g_number
  ,p_iterative_priority              in	    number   default hr_api.g_number
  ,p_creator_type                    in	    varchar2 default hr_api.g_varchar2
  ,p_retro_summ_ele_id               in     number   default hr_api.g_number
  ,p_grossup_flag                    in	    varchar2 default hr_api.g_varchar2
  ,p_process_mode                    in	    varchar2 default hr_api.g_varchar2
  ,p_advance_indicator               in	    varchar2 default hr_api.g_varchar2
  ,p_advance_payable                 in	    varchar2 default hr_api.g_varchar2
  ,p_advance_deduction               in	    varchar2 default hr_api.g_varchar2
  ,p_process_advance_entry           in	    varchar2 default hr_api.g_varchar2
  ,p_proration_group_id              in	    number   default hr_api.g_number
  ,p_proration_formula_id            in	    number   default hr_api.g_number
  ,p_recalc_event_group_id 	     in	    number   default hr_api.g_number
  ,p_qualifying_age                  in     number   default hr_api.g_number
  ,p_qualifying_length_of_service    in     number   default hr_api.g_number
  ,p_qualifying_units                in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category              in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute2                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute3                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute4                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute5                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute6                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute7                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute8                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute9                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute10                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute11                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute12                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute13                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute14                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute15                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute16                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute17                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute18                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute19                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute20                     in	    varchar2 default hr_api.g_varchar2
  ,p_element_information_category    in	    varchar2 default hr_api.g_varchar2
  ,p_element_information1            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information2            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information3            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information4            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information5            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information6            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information7            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information8            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information9            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information10           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information11           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information12           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information13           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information14           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information15           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information16           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information17           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information18           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information19           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information20           in	    varchar2 default hr_api.g_varchar2
  ,p_once_each_period_flag           in     varchar2 default hr_api.g_varchar2
  ,p_language_code                   in     varchar2 default hr_api.userenv_lang
  ,p_time_definition_type	     in     varchar2 default hr_api.g_varchar2
  ,p_time_definition_id		     in     number   default hr_api.g_number
  ,p_advance_element_type_id	     in     number   default hr_api.g_number
  ,p_deduction_element_type_id	     in     number   default hr_api.g_number
  ,p_effective_start_date               out nocopy date
  ,p_effective_end_date                 out nocopy date
  ,p_comment_id                         out nocopy number
  ,p_processing_priority_warning        out nocopy boolean
  ,p_element_name_warning               out nocopy boolean
  ,p_element_name_change_warning        out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_element_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to delete a new element type as of the effective date.
 *
 * The role of this process is to perform a validated, date-effective delete of
 * an existing row in the pay_element_type_usages_f table of the HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element type specified by the in parameter p_element_type_id and the in
 * out parameter p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The element type will have been successfully removed from the database.
 *
 * <p><b>Post Failure</b><br>
 * The element type will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_element_type_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * element type to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted element type. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted element type row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted element name row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_balance_feeds_warning If set to true, then balance feeds have been
 * deleted.
 * @param p_processing_rules_warning If set to true, then processing rules have
 * not been affected for delete_next_change operations.
 * @rep:displayname Delete Element Type
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_ELEMENT_TYPE
  (p_validate                        in     boolean default false
  ,p_effective_date                  in     date
  ,p_datetrack_delete_mode           in     varchar2
  ,p_element_type_id                 in     number
  ,p_object_version_number           in out nocopy number
  ,p_effective_start_date               out nocopy date
  ,p_effective_end_date                 out nocopy date
  ,p_balance_feeds_warning	        out nocopy boolean
  ,p_processing_rules_warning  	        out nocopy boolean
  );

end PAY_ELEMENT_TYPES_api;

/
