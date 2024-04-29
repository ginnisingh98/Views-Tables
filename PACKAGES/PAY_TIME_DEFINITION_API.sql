--------------------------------------------------------
--  DDL for Package PAY_TIME_DEFINITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TIME_DEFINITION_API" AUTHID CURRENT_USER as
/* $Header: pytdfapi.pkh 120.2 2006/07/13 13:28:18 pgongada noship $ */
/*#
 * This package is used to Create, Update and Delete the Time Definitions.
 * @rep:scope public
 * @rep:product pay
 * @rep:displayname Time Definitions
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_time_definition >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to Create Time Definitions.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll
 *
 * <p><b>Prerequisites</b><br>
 * The specified business group, legislation code should exist.
 *
 * <p><b>Post Success</b><br>
 * The Time Definition will be successfully created and all the out parameters
 * will be set.
 *
 * <p><b>Post Failure</b><br>
 * Time Definition will not be created and appropriate error message
 * will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date is used for business rule validation.
 * @param p_short_name Internal name for the Time Definition.
 * @param p_definition_name User name for the Time Definition.
 * @param p_period_type Represents the period type for Static and Point in time
 * definitions.
 * @param p_period_unit Represents the number of period units in Point in time
 * definitions.
 * @param p_day_adjustment When used in Point in Time Definitions represents
 * the number of days to adjust the date. It is Null for others.
 * @param p_dynamic_code Represents the Dynamic code.
 * @param p_business_group_id Business group for the Time Definitions.
 * @param p_legislation_code Legislation code for the seeded Time Definition.
 * @param p_definition_type Represents the type of Time Definition.
 * @param p_number_of_years Represents the number of years the Time Definition
 * spans.
 * @param p_start_date Represents the start date for the Time Definition.
 * @param p_period_time_definition_id Used only in Static Period time
 * definition. Represents the Point In Time Definition used in generating
 * the periods for static period Time Definition.
 * @param p_creator_id Represents the creator for the Time Definition.
 * @param p_creator_type Represents the creator type of the Time Definition.
 * @param p_time_definition_id If p_validate is false, this uniquely identifies
 * the Time Definition.If true, this will be set to NULL.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Time Definition. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Time Definition
 * @rep:category BUSINESS_ENTITY PAY_TIME_DEFINITION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_time_definition
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_short_name                    in     varchar2
  ,p_definition_name               in     varchar2
  ,p_period_type                   in     varchar2 default null
  ,p_period_unit                   in     varchar2 default null
  ,p_day_adjustment                in     varchar2 default null
  ,p_dynamic_code                  in     varchar2 default null
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_definition_type               in     varchar2 default 'P'
  ,p_number_of_years               in     number   default null
  ,p_start_date                    in     date     default null
  ,p_period_time_definition_id     in     number   default null
  ,p_creator_id                    in     number   default null
  ,p_creator_type                  in     varchar2 default null
  ,p_time_definition_id               out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_time_definition >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Time Definition.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Definition must exist.
 *
 * <p><b>Post Success</b><br>
 * The Time Definition will be successfully updated and the out parameters
 * will be set.
 *
 * <p><b>Post Failure</b><br>
 * The Time Definition will not be updated and appropriate error message
 * will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date is used for business rule validation.
 * @param p_time_definition_id Represents the Time Definition to be updated.
 * @param p_definition_name User name for the Time Definition.
 * @param p_period_type Represents the period type for Static and Point in time
 * definitions.
 * @param p_period_unit Represents the number of period units in Point in time
 * definitions.
 * @param p_day_adjustment When used in Point in Time Definitions represents
 * the number of days to adjust the date. It is Null for others.
 * @param p_dynamic_code Represents the Dynamic code.
 * @param p_number_of_years Represents the number of years the Time Definition
 * spans.
 * @param p_start_date Represents the start date for the Time Definition.
 * @param p_period_time_definition_id Used only in Static Period time
 * definition. Represents the Point In Time Definition used in generating
 * the periods for static period Time Definition.
 * @param p_creator_id Represents the creator for the Time Definition.
 * @param p_creator_type Represents the creator type of the Time Definition.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the updated Time Definition. If p_validate is true, then
 * the value will not change.
 * @rep:displayname Update Time Definitions
 * @rep:category BUSINESS_ENTITY PAY_TIME_DEFINITION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_time_definition
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_time_definition_id            in     number
  ,p_definition_name               in     varchar2  default hr_api.g_varchar2
  ,p_period_type                   in     varchar2  default hr_api.g_varchar2
  ,p_period_unit                   in     varchar2  default hr_api.g_varchar2
  ,p_day_adjustment                in     varchar2  default hr_api.g_varchar2
  ,p_dynamic_code                  in     varchar2  default hr_api.g_varchar2
  ,p_number_of_years               in     number    default hr_api.g_number
  ,p_start_date                    in     date      default hr_api.g_date
  ,p_period_time_definition_id     in     number    default hr_api.g_number
  ,p_creator_id                    in     number    default hr_api.g_number
  ,p_creator_type                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_time_definition >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Time Definition.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Definition must exist.
 *
 * <p><b>Post Success</b><br>
 * The Time Definition will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The Time Definition will not be deleted and appropriate error message
 * will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date id used for business rule validation.
 * @param p_time_definition_id Represents the Time Definition to be deleted.
 * @param p_object_version_number Represents the version number of the time
 * definition to be deleted.
 * @rep:displayname Delete Time Definitions
 * @rep:category BUSINESS_ENTITY PAY_TIME_DEFINITION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_time_definition
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_time_definition_id            in     number
  ,p_object_version_number         in     number
  );
--
end PAY_TIME_DEFINITION_API;

 

/
