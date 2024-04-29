--------------------------------------------------------
--  DDL for Package PAY_TIME_DEF_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TIME_DEF_USAGE_API" AUTHID CURRENT_USER as
/* $Header: pytduapi.pkh 120.2 2006/07/13 13:34:18 pgongada noship $ */
/*#
 * This package is used to Create and Delete Time Definition Usages.
 * @rep:scope public
 * @rep:product pay
 * @rep:displayname Time Definition Usages.
*/
-- ----------------------------------------------------------------------------
-- |--------------------------< create_time_def_usage >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Time Definition Usage.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Definition should already exist.
 *
 * <p><b>Post Success</b><br>
 * The Time Definition Usage will be successfully created and the out
 * parameters will be set.
 *
 * <p><b>Post Failure</b><br>
 * The Time Definition will not be crated and the appropriate error
 * message will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date is used for business rule validation.
 * @param p_time_definition_id Identifies the Time Definition.
 * @param p_usage_type Represents the Usage type for the Time Definition.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Time Definition Usage. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Time Definition Usages.
 * @rep:category BUSINESS_ENTITY PAY_TIME_DEFINITION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_time_def_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_time_definition_id            in     number
  ,p_Usage_type                    in     varchar2
  ,p_object_version_number            out nocopy number
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_time_def_Usage >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes Time Definition Usages.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Definition Usage should already exist.
 *
 * <p><b>Post Success</b><br>
 * The Time Definition Usage will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The Time Definition Usage will not be deleted and appropriate error message
 * will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date used for business rule validation.
 * @param p_time_definition_id Identifies the Time Definition.
 * @param p_usage_type Represents the Usage type for the Time Definition.
 * @param p_object_version_number Represents the version number of
 * Time Definition Usage.
 * @rep:displayname Delete Time Definition Usage.
 * @rep:category BUSINESS_ENTITY PAY_TIME_DEFINITION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_time_def_Usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_time_definition_id            in     number
  ,p_Usage_type                    in     varchar2
  ,p_object_version_number         in     number
  );
--
end PAY_TIME_DEF_Usage_API;

 

/
