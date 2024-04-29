--------------------------------------------------------
--  DDL for Package IRC_VARIABLE_COMP_ELEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VARIABLE_COMP_ELEMENT_API" AUTHID CURRENT_USER as
/* $Header: irvceapi.pkh 120.2 2008/02/21 14:39:44 viviswan noship $ */
/*#
 * This package contains APIs for variable compensation elements for a vacancy.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Variable Compensation Element
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_variable_compensation >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a variable compensation element for a vacancy.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The vacancy must already exist
 *
 * <p><b>Post Success</b><br>
 * The variable compensation element will be created for the vacancy
 *
 * <p><b>Post Failure</b><br>
 * The variable compensation element will not be created for the vacancy and an
 * error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_vacancy_id Identifies the vacancy that the variable compensation
 * element is for
 * @param p_variable_comp_lookup The type of variable compensation element.
 * Valid values are defined by 'IRC_VARIABLE_COMP_ELEMENT' lookup type.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created variable compensation element. If p_validate
 * is true, then the value will be null.
 * @rep:displayname Create Variable Compensation
 * @rep:category BUSINESS_ENTITY PER_VACANCY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_VARIABLE_COMPENSATION
  (p_validate               in     boolean  default false
  ,p_vacancy_id             in	   number
  ,p_variable_comp_lookup   in     varchar2
  ,p_effective_date         in     date
  ,p_object_version_number    out nocopy  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_variable_compensation >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a variable compensation element for a vacancy.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The variable compensation element must already exist
 *
 * <p><b>Post Success</b><br>
 * The variable compensation element will be deleted from the database
 *
 * <p><b>Post Failure</b><br>
 * The variable compensation element will not be deleted from the database and
 * an error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_vacancy_id Identifies the vacancy for which we are deleting a
 * variable compensation element
 * @param p_variable_comp_lookup Identifies the variable compensation element
 * type for which we are deleting a variable compensation element. Valid values
 * are defined by 'IRC_VARIABLE_COMP_ELEMENT' lookup type.
 * @param p_object_version_number Current version number of the variable
 * consideration element to be deleted.
 * @rep:displayname Delete Variable Compensation
 * @rep:category BUSINESS_ENTITY PER_VACANCY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_VARIABLE_COMPENSATION
  (p_validate                  in   boolean  default false
  ,p_vacancy_id                in   number
  ,p_variable_comp_lookup      in   varchar2
  ,p_object_version_number     in   number
  );
--
end IRC_VARIABLE_COMP_ELEMENT_API;

/
