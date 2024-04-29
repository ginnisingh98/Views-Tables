--------------------------------------------------------
--  DDL for Package PAY_LINK_INPUT_VALUES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_LINK_INPUT_VALUES_API" AUTHID CURRENT_USER as
/* $Header: pylivapi.pkh 120.1 2005/10/02 02:32:02 aroussel $ */
/*#
 * This package contains link input value APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Link Input Value
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_liv_internal >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This Business Support Process is used to create a new link input value
-- as of effective date.
-- A Link Input Value will be created whenever an Element Link is created
-- or a New Input Value is created (with an existing Element Link).
--
-- Prerequisites:
-- An Element Link must be set up for a valid Element with Input Values.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Y    date     Effective start date for the
--                                                link input value.
--   p_element_link_id              Y    number   Element Link Value Identifier
--   p_input_value_id               Y    number   Input Value Identifier
--   p_costed_flag                  Y    varchar2 Indicates whether an Input
--                                                Value is costed.
--   p_default_value                     varchar2 Default for the Input Value
--                                                on Entry.
--   p_max_value                         varchar2 Maximum value allowed on
--                                                Entry.
--   p_min_value                         varchar2 Minimum value allowed on
--                                                Entry.
--   p_warning_or_error                  varchar2 Indicates whether a warning or
--                                                error message is generated if
--                                                the input value is not valid
--                                                for formula validation.
--
-- Post Success:
--   When the Link Input Value is created the following OUT parameters are set.
--
--   Name                           Type     Description
--   p_link_input_value_id          number   Primary Key
--                                           If p_validate is true then this
--                                           will be set to null.
--   p_effective_start_date         date     Effective Start Date
--                                           If p_validate is true then this
--                                           will be set to null.
--   p_effective_end_date           date     Effective End Date
--                                           If p_validate is true then this
--                                           will be set to null.
--   p_object_version_number        date     Object Version Number
--                                           If p_validate is true then this
--                                           will be set to null.
--   p_pay_basis_warning            boolean  Will be True, if the Input Value
--                                           is a Pay Basis for the Element.
--
-- Post Failure:
-- Error Messages are raised if any business rule is violated and the link
-- input value is not created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--
procedure CREATE_LIV_INTERNAL
  (p_effective_date             in   date
  ,p_element_link_id            in   number
  ,p_input_value_id             in   number
  ,p_costed_flag                in   varchar2
  ,p_default_value              in   varchar2   default null
  ,p_max_value                  in   varchar2   default null
  ,p_min_value                  in   varchar2   default null
  ,p_warning_or_error           in   varchar2   default null
  ,p_link_input_value_id        out  nocopy number
  ,p_effective_start_date       out  nocopy date
  ,p_effective_end_date         out  nocopy date
  ,p_object_version_number      out  nocopy number
  ,p_pay_basis_warning          out  nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_link_input_values >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to update an input value for an element link.
 *
 * The role of this process is to perform a validated, date-effective update of
 * an existing row in the pay_link_input_values_f table of the HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The link input value as identified by the in parameter p_link_input_value_id
 * and the in out parameter p_object_version_id must already exist.
 *
 * <p><b>Post Success</b><br>
 * The link input value will have been successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The link input value will not be updated and an error will be raised.
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
 * @param p_link_input_value_id {@rep:casecolumn
 * PAY_LINK_INPUT_VALUES_F.LINK_INPUT_VALUE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * link input value to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated link input
 * value. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_costed_flag {@rep:casecolumn PAY_LINK_INPUT_VALUES_F.COSTED_FLAG}
 * @param p_default_value {@rep:casecolumn
 * PAY_LINK_INPUT_VALUES_F.DEFAULT_VALUE}
 * @param p_max_value {@rep:casecolumn PAY_LINK_INPUT_VALUES_F.MAX_VALUE}
 * @param p_min_value {@rep:casecolumn PAY_LINK_INPUT_VALUES_F.MIN_VALUE}
 * @param p_warning_or_error {@rep:casecolumn
 * PAY_LINK_INPUT_VALUES_F.WARNING_OR_ERROR}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated link input value row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated link input value row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_pay_basis_warning If set to true, then this input value is used in
 * a salary basis for the element.
 * @param p_default_range_warning If set to true, then the default value is
 * outside the allowable range for this input value.
 * @param p_default_formula_warning If set to true, then formula validation for
 * this input value's default value has failed.
 * @param p_assignment_id_warning If set to true, then this input value's
 * formula requires an ASSIGNMENT_ID input, which cannot be set at this level.
 * @param p_formula_message If formula validation fails, then set to a
 * user-defined error message for the formula, if one exists. Otherwise, set to
 * null
 * @rep:displayname Update Input Value for Element Link
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT_LINK
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_LINK_INPUT_VALUES
  (p_validate                   in      boolean    default false
  ,p_effective_date             in      date
  ,p_datetrack_update_mode      in      varchar2
  ,p_link_input_value_id        in      number
  ,p_object_version_number      in out  nocopy number
  ,p_costed_flag                in      varchar2   default hr_api.g_varchar2
  ,p_default_value              in      varchar2   default hr_api.g_varchar2
  ,p_max_value                  in      varchar2   default hr_api.g_varchar2
  ,p_min_value                  in      varchar2   default hr_api.g_varchar2
  ,p_warning_or_error           in      varchar2   default hr_api.g_varchar2
  ,p_effective_start_date       out     nocopy date
  ,p_effective_end_date         out     nocopy date
  ,p_pay_basis_warning          out     nocopy boolean
  ,p_default_range_warning      out     nocopy boolean
  ,p_default_formula_warning    out     nocopy boolean
  ,p_assignment_id_warning      out     nocopy boolean
  ,p_formula_message            out     nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_link_input_values >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an input value for an element link.
 *
 * The role of this process is to perform a validated, date-effective delete of
 * an existing row from the pay_link_input_values_f table of the HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The link input value as identified by the in parameter p_link_input_value_id
 * and the in out parameter p_object_version_id must already exist.
 *
 * <p><b>Post Success</b><br>
 * The link input value will have been successfully removed from the database.
 *
 * <p><b>Post Failure</b><br>
 * The link input value will not be deleted and an error will be raised.
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
 * @param p_link_input_value_id {@rep:casecolumn
 * PAY_LINK_INPUT_VALUES_F.LINK_INPUT_VALUE_ID}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted link input value row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted link input value row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_object_version_number Pass in the current version number of the
 * link input value to be deleted. When the API completes if p_validate is
 * false, will be set to the new version number of the deleted link input
 * value. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Delete Input Value for Element Link
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT_LINK
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_LINK_INPUT_VALUES
  (p_validate                   in      boolean    default false
  ,p_effective_date             in      date
  ,p_datetrack_delete_mode      in      varchar2
  ,p_link_input_value_id        in      number
  ,p_effective_start_date       out     nocopy date
  ,p_effective_end_date         out     nocopy date
  ,p_object_version_number      in out  nocopy number
  );
--

end PAY_LINK_INPUT_VALUES_API;

 

/
