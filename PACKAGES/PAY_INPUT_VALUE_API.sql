--------------------------------------------------------
--  DDL for Package PAY_INPUT_VALUE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_INPUT_VALUE_API" AUTHID CURRENT_USER as
/* $Header: pyivlapi.pkh 120.1 2005/10/02 02:31:57 aroussel $ */
/*#
 * This package contains input value APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Input Value
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_input_value >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to create an input value for an element type.
 *
 * The role of this process is to insert a fully validated row into the
 * pay_input_values_f table of HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element type specified by the in parameter p_element_type_id must
 * already exist. The lookup type specified by the in parameter p_lookup_type
 * must already exist. The formula specified by the in parameter p_formula_id
 * must already exist. The value set specified by the in parameter
 * p_value_set_id must already exist.
 *
 * <p><b>Post Success</b><br>
 * The input value will have been successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The input value will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_element_type_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID}
 * @param p_name {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_uom {@rep:casecolumn PAY_INPUT_VALUES_F.UOM}
 * @param p_lookup_type {@rep:casecolumn PAY_INPUT_VALUES_F.LOOKUP_TYPE}
 * @param p_formula_id {@rep:casecolumn PAY_INPUT_VALUES_F.FORMULA_ID}
 * @param p_value_set_id Identifier for the Value Set used for the validation
 * @param p_display_sequence {@rep:casecolumn
 * PAY_INPUT_VALUES_F.DISPLAY_SEQUENCE}
 * @param p_generate_db_items_flag {@rep:casecolumn
 * PAY_INPUT_VALUES_F.GENERATE_DB_ITEMS_FLAG}
 * @param p_hot_default_flag {@rep:casecolumn
 * PAY_INPUT_VALUES_F.HOT_DEFAULT_FLAG}
 * @param p_mandatory_flag {@rep:casecolumn PAY_INPUT_VALUES_F.MANDATORY_FLAG}
 * @param p_default_value {@rep:casecolumn PAY_INPUT_VALUES_F.DEFAULT_VALUE}
 * @param p_max_value {@rep:casecolumn PAY_INPUT_VALUES_F.MAX_VALUE}
 * @param p_min_value {@rep:casecolumn PAY_INPUT_VALUES_F.MIN_VALUE}
 * @param p_warning_or_error {@rep:casecolumn
 * PAY_INPUT_VALUES_F.WARNING_OR_ERROR}
 * @param p_input_value_id If p_validate is false, then this uniquely
 * identifies the input value created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created input value. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created input value. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created input value. If p_validate is true, then
 * set to null.
 * @param p_default_val_warning If set to true, then the default value is
 * outside the allowable range for this input value.
 * @param p_min_max_warning If set to true, then the min value is greater than
 * the max value for this input value.
 * @param p_pay_basis_warning If set to true, then a salary basis is linked to
 * this input value's element type.
 * @param p_formula_warning If set to true, then formula validation for this
 * input value's formula has failed.
 * @param p_assignment_id_warning If set to true, then this input value's
 * formula requires an ASSIGNMENT_ID input, which cannot be set at this level.
 * @param p_formula_message If formula validation fails, then set to a
 * user-defined error message for the formula, if one exists. Otherwise, set to
 * null
 * @rep:displayname Create Input Value for Element Type
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
procedure CREATE_INPUT_VALUE
  ( P_VALIDATE                in boolean  Default false
   ,P_EFFECTIVE_DATE          in date
   ,P_ELEMENT_TYPE_ID         in number
   ,P_NAME                    in varchar2
   ,P_UOM                     in varchar2
   ,P_LOOKUP_TYPE             in varchar2 Default Null
   ,P_FORMULA_ID              in number   Default Null
   ,P_VALUE_SET_ID            in number   Default Null
   ,P_DISPLAY_SEQUENCE        in number   Default Null
   ,P_GENERATE_DB_ITEMS_FLAG  in varchar2 Default 'N'
   ,P_HOT_DEFAULT_FLAG        in varchar2 Default 'N'
   ,P_MANDATORY_FLAG          in varchar2 Default 'N'
   ,P_DEFAULT_VALUE           in varchar2 Default Null
   ,P_MAX_VALUE               in varchar2 Default Null
   ,P_MIN_VALUE               in varchar2 Default Null
   ,P_WARNING_OR_ERROR        in varchar2 Default Null
   ,P_INPUT_VALUE_ID	      OUT NOCOPY number
   ,P_OBJECT_VERSION_NUMBER   OUT NOCOPY number
   ,P_EFFECTIVE_START_DATE    OUT NOCOPY date
   ,P_EFFECTIVE_END_DATE      OUT NOCOPY date
   ,P_DEFAULT_VAL_WARNING     OUT NOCOPY boolean
   ,P_MIN_MAX_WARNING         OUT NOCOPY boolean
   ,P_PAY_BASIS_WARNING       OUT NOCOPY boolean
   ,P_FORMULA_WARNING         OUT NOCOPY boolean
   ,P_ASSIGNMENT_ID_WARNING   OUT NOCOPY boolean
   ,P_FORMULA_MESSAGE         OUT NOCOPY varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_input_value >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to update an input value for an element type.
 *
 * The role of this process is to perform a validated, date-effective update of
 * an existing row in the pay_input_values_f table of the HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The input value as identified by the in parameter p_input_value_id and the
 * in out parameter p_object_version_number must already exist. The lookup type
 * specified by the in parameter p_lookup_type must already exist. The formula
 * specified by the in parameter p_formula_id must already exist. The value set
 * specified by the in parameter p_value_set_id must already exist.
 *
 * <p><b>Post Success</b><br>
 * The input value will have been successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The input value will not be updated and an error will be raised.
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
 * @param p_input_value_id {@rep:casecolumn PAY_INPUT_VALUES_F.INPUT_VALUE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * input value to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated input value. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_name {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_uom {@rep:casecolumn PAY_INPUT_VALUES_F.UOM}
 * @param p_lookup_type Lookup Type used for the valdiation
 * @param p_formula_id {@rep:casecolumn PAY_INPUT_VALUES_F.FORMULA_ID}
 * @param p_value_set_id Identifier for the Value Set used for the validation
 * @param p_display_sequence {@rep:casecolumn
 * PAY_INPUT_VALUES_F.DISPLAY_SEQUENCE}
 * @param p_generate_db_items_flag {@rep:casecolumn
 * PAY_INPUT_VALUES_F.GENERATE_DB_ITEMS_FLAG}
 * @param p_hot_default_flag {@rep:casecolumn
 * PAY_INPUT_VALUES_F.HOT_DEFAULT_FLAG}
 * @param p_mandatory_flag {@rep:casecolumn PAY_INPUT_VALUES_F.MANDATORY_FLAG}
 * @param p_default_value {@rep:casecolumn PAY_INPUT_VALUES_F.DEFAULT_VALUE}
 * @param p_max_value {@rep:casecolumn PAY_INPUT_VALUES_F.MAX_VALUE}
 * @param p_min_value {@rep:casecolumn PAY_INPUT_VALUES_F.MIN_VALUE}
 * @param p_warning_or_error {@rep:casecolumn
 * PAY_INPUT_VALUES_F.WARNING_OR_ERROR}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated input value row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated input value row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_default_val_warning If set to true, then the default value is
 * outside the allowable range for this input value.
 * @param p_min_max_warning If set to true, then the min value is greater than
 * the max value for this input value.
 * @param p_link_inp_val_warning If set to true, then either the default value,
 * lookup type, min value, max value or warning or error value has changed for
 * this input value.
 * @param p_pay_basis_warning If set to true, then this input value is used in
 * a salary basis for the element.
 * @param p_formula_warning If set to true, then formula validation for this
 * input value's default value has failed.
 * @param p_assignment_id_warning If set to true, then this input value's
 * formula requires an ASSIGNMENT_ID input, which cannot be set at this level.
 * @param p_formula_message If formula validation fails, then set to a
 * user-defined error message for the formula, if one exists. Otherwise, set to
 * null
 * @rep:displayname Update Input Value for Element Type
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
procedure UPDATE_INPUT_VALUE
  ( P_VALIDATE                     IN      boolean  Default false
   ,P_EFFECTIVE_DATE               IN      date
   ,P_DATETRACK_MODE	              IN      varchar2
   ,P_INPUT_VALUE_ID		           IN      number
   ,P_OBJECT_VERSION_NUMBER	   IN OUT NOCOPY  number
   ,P_NAME                         IN      varchar2 Default hr_api.g_varchar2
   ,P_UOM                          IN      varchar2 Default hr_api.g_varchar2
   ,P_LOOKUP_TYPE                  IN      varchar2 Default hr_api.g_varchar2
   ,P_FORMULA_ID                   IN      number   Default hr_api.g_number
   ,P_VALUE_SET_ID                 IN      number   Default hr_api.g_number
   ,P_DISPLAY_SEQUENCE             IN      number   Default hr_api.g_number
   ,P_GENERATE_DB_ITEMS_FLAG       IN      varchar2 Default hr_api.g_varchar2
   ,P_HOT_DEFAULT_FLAG             IN      varchar2 Default hr_api.g_varchar2
   ,P_MANDATORY_FLAG               IN      varchar2 Default hr_api.g_varchar2
   ,P_DEFAULT_VALUE                IN      varchar2 Default hr_api.g_varchar2
   ,P_MAX_VALUE                    IN      varchar2 Default hr_api.g_varchar2
   ,P_MIN_VALUE                    IN      varchar2 Default hr_api.g_varchar2
   ,P_WARNING_OR_ERROR             IN      varchar2 Default hr_api.g_varchar2
   ,P_EFFECTIVE_START_DATE	   OUT NOCOPY     date
   ,P_EFFECTIVE_END_DATE	   OUT NOCOPY     date
   ,P_DEFAULT_VAL_WARNING          OUT NOCOPY     boolean
   ,P_MIN_MAX_WARNING              OUT NOCOPY     boolean
   ,P_LINK_INP_VAL_WARNING         OUT NOCOPY     boolean
   ,P_PAY_BASIS_WARNING            OUT NOCOPY     boolean
   ,P_FORMULA_WARNING              OUT NOCOPY     boolean
   ,P_ASSIGNMENT_ID_WARNING        OUT NOCOPY     boolean
   ,P_FORMULA_MESSAGE              OUT NOCOPY     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_input_value >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to delete an input value for an element type.
 *
 * The role of this process is to perform a validated, date-effective delete of
 * an existing row from the pay_input_values_f table of the HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The input value as identified by the in parameter p_input_value_id and the
 * in out parameter p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The input value will have been successfully removed from the database.
 *
 * <p><b>Post Failure</b><br>
 * The input value will not be deleted and an error will be raised.
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
 * @param p_input_value_id {@rep:casecolumn PAY_INPUT_VALUES_F.INPUT_VALUE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * input value to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted input value. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted input value row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted input value row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_balance_feeds_warning If set to true, then balance feeds have been
 * deleted.
 * @rep:displayname Delete Input Value for Element Type
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
procedure DELETE_INPUT_VALUE
  (  P_VALIDATE                        IN     boolean default false
    ,P_EFFECTIVE_DATE                  IN     date
    ,P_DATETRACK_DELETE_MODE           IN     varchar2
    ,P_INPUT_VALUE_ID                  IN     number
    ,P_OBJECT_VERSION_NUMBER           IN OUT NOCOPY number
    ,P_EFFECTIVE_START_DATE            OUT NOCOPY    date
    ,P_EFFECTIVE_END_DATE              OUT NOCOPY    date
    ,P_BALANCE_FEEDS_WARNING           OUT NOCOPY    boolean
  );
--
end PAY_INPUT_VALUE_API;

 

/
