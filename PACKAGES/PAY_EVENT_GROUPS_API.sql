--------------------------------------------------------
--  DDL for Package PAY_EVENT_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_GROUPS_API" AUTHID CURRENT_USER as
/* $Header: pyevgapi.pkh 120.3 2005/10/24 01:00:46 adkumar noship $ */
/*#
 * This package contains APIs for Event Groups.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Event Groups
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_event_group >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an Event Group.
 *
 * Used in the Interpretation phase of the Payroll Events Model.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business group should exists.
 *
 * <p><b>Post Success</b><br>
 * The Event Group has been successfully created.
 *
 * <p><b>Post Failure</b><br>
 * If the event group type is not a recognisable value for the lookup type
 * EVENT_GROUP_TYPE, then raise error HR_xxxx_INVALID_EVENT_GROUP. Also if the
 * proration period type is not a recognisable value for the lookup type
 * PRORATION_PERIOD_TYPE, raise error HR_xxxx_INVALID_PERIOD_TYPE.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_event_group_name Event Group Name
 * @param p_event_group_type Taken from EVENT_GROUP_TYPE lookup
 * @param p_proration_type Taken from PRORATION_PERIOD_TYPE lookup.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_event_group_id Primary Key of the record.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the createdevent group. If p_validate is true, then the
 * value will be null.
 * @param p_time_definition_id Identifier for the time definition.
 * @rep:displayname Create Event Group
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_EVENT_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_event_group
(
   p_validate                       in     boolean default false
  ,p_effective_date                 in     date
  ,p_event_group_name               in varchar2
  ,p_event_group_type               in varchar2
  ,p_proration_type                 in varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_event_group_id                 out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_time_definition_id               in     number   default null
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_event_group >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an Event Group.
 *
 * Used in the Interpretation phase of the Payroll Events Model.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The event group to be updated should exists.
 *
 * <p><b>Post Success</b><br>
 * The Event Group has been successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * If the event group type is not a recognisable value for the lookup type
 * EVENT_GROUP_TYPE, then raise error HR_xxxx_INVALID_EVENT_GROUP. Also if the
 * proration period type is not a recognisable value for the lookup type
 * PRORATION_PERIOD_TYPE, raise error HR_xxxx_INVALID_PERIOD_TYPE.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_event_group_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * event group to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated event group. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_event_group_name Event Group Name
 * @param p_event_group_type Taken from EVENT_GROUP_TYPE lookup
 * @param p_proration_type Taken from PRORATION_PERIOD_TYPE lookup.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_time_definition_id Identifier for the time definition.
 * @rep:displayname Update Event Group
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_EVENT_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_event_group
(
   p_validate                     in     boolean default false
  ,p_effective_date               in     date
  ,p_event_group_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_event_group_name             in     varchar2  default hr_api.g_varchar2
  ,p_event_group_type             in     varchar2  default hr_api.g_varchar2
  ,p_proration_type               in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_time_definition_id             in     number    default hr_api.g_number
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_event_group >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an Event Group.
 *
 * Used in the Interpretation phase of the Payroll Events Model.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The event group to be deleted should exists.
 *
 * <p><b>Post Success</b><br>
 * The Event Group has been successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The Event Group will not be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_event_group_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * Event Group to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted Event Group. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Delete Event Group
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_EVENT_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_event_group
(
   p_validate                       in     boolean default false
  ,p_event_group_id                 in     number
  ,p_object_version_number          in number
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< lck_event_group >------------------------|
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
/*procedure lck_event_group
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
end pay_event_groups_api;

 

/
