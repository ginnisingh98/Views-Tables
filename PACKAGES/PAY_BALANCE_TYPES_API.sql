--------------------------------------------------------
--  DDL for Package PAY_BALANCE_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_TYPES_API" AUTHID CURRENT_USER as
/* $Header: pybltapi.pkh 120.1 2005/10/02 02:46:06 aroussel $ */
/*#
 * This package contains Balance Type APIs.
 * @rep:scope public
 * @rep:product PAY
 * @rep:displayname Balance Type
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_bal_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to create a new Balance Type.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * If this balance type to be used only within a business group then a valid
 * business group should exist.
 *
 * <p><b>Post Success</b><br>
 * The balance type will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the balance
 * type is not created.
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
 * @param p_balance_name Name of the Balance.
 * @param p_balance_uom Unit of Measure of the Balance. Valid values are
 * defined by the 'UNITS' lookup type.
 * @param p_business_group_id Business group of the Balance.
 * @param p_legislation_code Legislation of the Balance.
 * @param p_currency_code Currency code.
 * @param p_assignment_remuneration_flag Indicates the balance is used for
 * assignment remuneration or for third party payments. (Default 'N')
 * @param p_comments Balance Type comment.
 * @param p_legislation_subgroup Identifies the legislation of the predefined
 * data for the element.
 * @param p_reporting_name User name for reporting purposes.
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
 * @param p_jurisdiction_level US specific. Indicates the jurisdiction level
 * that applies to the balance type, federal, state, county or city.
 * @param p_tax_type US specific. Tax type of the balance.
 * @param p_balance_category_id Balance Category id
 * @param p_base_balance_type_id Balance_Type_Id for base balance.
 * @param p_input_value_id Input_value_id for primary balance
 * @param p_balance_type_id Primary Key If p_validate is true then this will be
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created event procedure. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Balance Type
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_bal_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 Default hr_api.userenv_lang
  ,p_balance_name                  in     varchar2
  ,p_balance_uom                   in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2 default null
  ,p_currency_code                 in     varchar2 default null
  ,p_assignment_remuneration_flag  in     varchar2 default 'N'
  ,p_comments                      in     varchar2 default null
  ,p_legislation_subgroup          in     varchar2 default null
  ,p_reporting_name                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in	  varchar2 default null
  ,p_attribute2                    in	  varchar2 default null
  ,p_attribute3                    in	  varchar2 default null
  ,p_attribute4                    in	  varchar2 default null
  ,p_attribute5                    in	  varchar2 default null
  ,p_attribute6                    in	  varchar2 default null
  ,p_attribute7                    in	  varchar2 default null
  ,p_attribute8                    in	  varchar2 default null
  ,p_attribute9                    in	  varchar2 default null
  ,p_attribute10                   in	  varchar2 default null
  ,p_attribute11                   in	  varchar2 default null
  ,p_attribute12                   in	  varchar2 default null
  ,p_attribute13                   in	  varchar2 default null
  ,p_attribute14                   in	  varchar2 default null
  ,p_attribute15                   in	  varchar2 default null
  ,p_attribute16                   in	  varchar2 default null
  ,p_attribute17                   in	  varchar2 default null
  ,p_attribute18                   in	  varchar2 default null
  ,p_attribute19                   in	  varchar2 default null
  ,p_attribute20                   in	  varchar2 default null
  ,p_jurisdiction_level            in     number   default null
  ,p_tax_type                      in     varchar2 default null
  ,p_balance_category_id           in     number   default null
  ,p_base_balance_type_id          in     number   default null
  ,p_input_value_id                in     number   default null
  ,p_balance_type_id                  out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_bal_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to update Balance Type.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The balance type to be updated should exist.
 *
 * <p><b>Post Success</b><br>
 * The balance type will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the balance
 * type is not updated.
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
 * @param p_balance_type_id primary key.
 * @param p_object_version_number Pass in the current version number of the
 * balance type to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated balance type. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_balance_name name of the Balance.
 * @param p_balance_uom Unit of Measure of the Balance. Valid values are
 * defined by the 'UNITS' lookup type.
 * @param p_currency_code Currency code.
 * @param p_assignment_remuneration_flag Indicates the balance is used for
 * assignment remuneration or for third party payments. (Default 'N')
 * @param p_comments Blance type comment text.
 * @param p_reporting_name User name for reporting purposes.
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
 * @param p_balance_category_id Balance Category id
 * @param p_base_balance_type_id Balance_Type_Id for base balance.
 * @param p_input_value_id Input_value_id for primary balance
 * @param p_balance_name_warning this parameter will be set when balance_name
 * is updated.
 * @rep:displayname Update Balance Type
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_bal_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 Default hr_api.userenv_lang
  ,p_balance_type_id               in     number
  ,p_object_version_number         in out nocopy   number
  ,p_balance_name                  in     varchar2 default hr_api.g_varchar2
  ,p_balance_uom                   in     varchar2 default hr_api.g_varchar2
  ,p_currency_code                 in     varchar2 default hr_api.g_varchar2
  ,p_assignment_remuneration_flag  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_reporting_name                in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in	  varchar2 default hr_api.g_varchar2
  ,p_balance_category_id           in     number   default hr_api.g_number
  ,p_base_balance_type_id          in     number   default hr_api.g_number
  ,p_input_value_id                in     number   default hr_api.g_number
  ,p_balance_name_warning             out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_bal_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to delete Balance Type.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The balance type to be deleted should exist.
 *
 * <p><b>Post Success</b><br>
 * The balance type will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the balance
 * type is not deleted.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_balance_type_id primary key.
 * @param p_object_version_number Pass in the current version number of the
 * balance type to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted balance type. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Delete Balance Type
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_bal_type
  (p_validate                      in     boolean  default false
  ,p_balance_type_id               in     number
  ,p_object_version_number         in out nocopy   number
  );
--

end PAY_BALANCE_TYPES_API;

 

/
