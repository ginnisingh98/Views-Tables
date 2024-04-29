--------------------------------------------------------
--  DDL for Package PAY_ITERATIVE_RULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ITERATIVE_RULES_API" AUTHID CURRENT_USER as
/* $Header: pyitrapi.pkh 120.2 2005/10/24 00:42:53 adkumar noship $ */
/*#
 * This package contains the Iterative Rules API.
 * @rep:scope public
 * @rep:product pay
 * @rep:displayname Iterative Rule
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_iterative_rule >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an iterative rule record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * Element Type with an Iterative formula attached.
 *
 * <p><b>Post Success</b><br>
 * The iterative rule will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the iterative rule and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_element_type_id {@rep:casecolumn
 * PAY_ITERATIVE_RULES_F.ELEMENT_TYPE_ID}
 * @param p_result_name Result Name
 * @param p_iterative_rule_type Iterative rule type
 * @param p_input_value_id {@rep:casecolumn
 * PAY_ITERATIVE_RULES_F.INPUT_VALUE_ID}
 * @param p_severity_level Severity Level.
 * @param p_business_group_id {@rep:casecolumn
 * PAY_ITERATIVE_RULES_F.BUSINESS_GROUP_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PAY_ITERATIVE_RULES_F.LEGISLATION_CODE}
 * @param p_iterative_rule_id If p_validate is false, this uniquely identifies
 * the Iterative Rule created. If p_validate is set to true, this parameter
 * will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created iterative rule. If p_validate is true, then
 * the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created iterative rule. If p_validate
 * is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created iterative rule. If p_validate is true,
 * then set to null.
 * @rep:displayname Create Iterative Rule
 * @rep:category BUSINESS_ENTITY PAY_ITERATIVE_RULE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_iterative_rule
(  p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_element_type_id                in     number
  ,p_result_name                    in     varchar2
  ,p_iterative_rule_type            in     varchar2
  ,p_input_value_id                 in     number   default null
  ,p_severity_level                 in     varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_iterative_rule_id                 out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_iterative_rule >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the iterative rule record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * Element Type with an Iterative formula attached.
 *
 * <p><b>Post Success</b><br>
 * The iterative rule will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the iterative rule and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_iterative_rule_id Primary Key for the iterative rule.
 * @param p_object_version_number Pass in the current version number of the
 * iterative rule to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated iterative rule. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_element_type_id {@rep:casecolumn
 * PAY_ITERATIVE_RULES_F.ELEMENT_TYPE_ID}
 * @param p_result_name Result Name
 * @param p_iterative_rule_type Iterative rule type
 * @param p_input_value_id {@rep:casecolumn
 * PAY_ITERATIVE_RULES_F.INPUT_VALUE_ID}
 * @param p_severity_level Severity Level.
 * @param p_business_group_id {@rep:casecolumn
 * PAY_ITERATIVE_RULES_F.BUSINESS_GROUP_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PAY_ITERATIVE_RULES_F.LEGISLATION_CODE}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated iterative rule row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated iterative rule row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Iterative Rule
 * @rep:category BUSINESS_ENTITY PAY_ITERATIVE_RULE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_iterative_rule
(  p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_iterative_rule_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_element_type_id              in     number    default hr_api.g_number
  ,p_result_name                  in     varchar2  default hr_api.g_varchar2
  ,p_iterative_rule_type          in     varchar2  default hr_api.g_varchar2
  ,p_input_value_id               in     number    default hr_api.g_number
  ,p_severity_level               in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_iterative_rule >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an iterative rule record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The iterative rule to be delete should exist.
 *
 * <p><b>Post Success</b><br>
 * The iterative rule will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the iterative rule and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_iterative_rule_id Primary Key for the iterative rule.
 * @param p_object_version_number Pass in the current version number of the
 * iterative rule to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted iterative rule. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted iterative rule row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted iterative rule row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Iterative Rule
 * @rep:category BUSINESS_ENTITY PAY_ITERATIVE_RULE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_iterative_rule
(  p_validate                         in     boolean  default false
  ,p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_iterative_rule_id                in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< lck_iterative_rule >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
/*procedure lck_iterative_rule
(
   p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_iterative_rule_id                in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
);
*/
--
end pay_iterative_rules_api;

 

/
