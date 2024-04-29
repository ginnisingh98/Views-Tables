--------------------------------------------------------
--  DDL for Package PAY_DATED_TABLES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DATED_TABLES_API" AUTHID CURRENT_USER as
/* $Header: pyptaapi.pkh 120.0 2005/05/29 07:55:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------<create_dated_table >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is used to create rows on pay_dated_tables table
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_table_name                   Yes  varchar2 Table Name
--   p_application_id               No   number   Application id for the table
--                                                name in p_table_name argument.
--   p_surrogate_key_name           Yes  varchar2 Has to be a column on the table.
--   p_start_date_name              Yes  varchar2 Has to be a column on the table
--                                                of data type date.
--   p_end_date_name                Yes  varchar2 Has to be a column on the table
--                                                of data type date.
--   p_business_group_id            No   number   Business Group of the Record.
--   p_legislation_code             No   varchar2 Legislation Code
--   p_dyn_trigger_type             No   varchar2 From lookup pay_dyn_trigger_types
--   p_dyn_trigger_package_name     No   varchar2 If package to hold trigger code, then name given
--   p_dyn_trig_pkg_generated       No   varchar2 A flag indicating this pkg exists
--
-- Out Parameters:
--   Name                                Type     Description
--   p_dated_table_id                    number   PK of record
--   p_object_version_number             number   OVN of record
--
-- Post Failure:
--   1) If the surrogate key name argument is not a column on the table specified
--      in the table name argument, raise error HR_xxxx_SURROGATE_KEY_NAME.
--   2) If the start date name argument is not a column of data type Date on the
--      table in the table name argument, raise error HR_xxxx_START_DATE_NAME.
--   3) If the end date name argument is not a column of data type Date on the
--      table in the table name argument, raise error HR_xxxx_END_DATE_NAME.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_dated_table
  (
   p_validate                       in     boolean default false
  ,p_table_name                     in     varchar2
  ,p_application_id                 in     number  default null
  ,p_surrogate_key_name             in     varchar2
  ,p_start_date_name                in     varchar2
  ,p_end_date_name                  in     varchar2
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_dated_table_id                    out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_dyn_trigger_type               in     varchar2 default null
  ,p_dyn_trigger_package_name       in     varchar2 default null
  ,p_dyn_trig_pkg_generated         in     varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------<update_dated_table >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is used to update rows on pay_dated_tables table
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_dated_table_id               Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_table_name                   No   varchar2 Table Name
--   p_application_id               No   number   Application id for the table
--                                                name in p_table_name argument.
--   p_surrogate_key_name           No   varchar2 Has to be a column on the table
--                                                name in p_table_name argument
--   p_start_date_name              No   varchar2 Has to be a column on the table
--                                                of data type date.
--   p_end_date_name                No   varchar2 Has to be a column on the table
--                                                of data type date.
--   p_business_group_id            No   number   Business Group of the Record.
--   p_legislation_code             No   varchar2 Legislation Code
--   p_dyn_trigger_type             No   varchar2 From lookup pay_dyn_trigger_type
--   p_dyn_trigger_package_name     No   varchar2 If package to hold trigger code, then name given
--   p_dyn_trig_pkg_generated       No   varchar2 Flag indicating pkg exists.
--
-- Out Parameters:
--   Name                                Type     Description
--   p_object_version_number             number   OVN of record
--
-- Post Failure:
--   1) If the surrogate key name argument is not a column on the table specified
--      in the table name argument, raise error HR_xxxx_SURROGATE_KEY_NAME.
--   2) If the start date name argument is not a column of data type Date on the
--      table in the table name argument, raise error HR_xxxx_START_DATE_NAME.
--   3) If the end date name argument is not a column of data type Date on the
--      table in the table name argument, raise error HR_xxxx_END_DATE_NAME.
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_dated_table
  (
   p_validate                       in     boolean default false
  ,p_dated_table_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_table_name                   in     varchar2  default hr_api.g_varchar2
  ,p_application_id               in     number    default hr_api.g_number
  ,p_surrogate_key_name           in     varchar2  default hr_api.g_varchar2
  ,p_start_date_name              in     varchar2  default hr_api.g_varchar2
  ,p_end_date_name                in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_dyn_trigger_type             in     varchar2  default hr_api.g_varchar2
  ,p_dyn_trigger_package_name     in     varchar2  default hr_api.g_varchar2
  ,p_dyn_trig_pkg_generated       in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_dated_table >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API deletes an existing row on pay_dated_tables table
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type      Description/Valid Values
--   p_validate                     Yes  boolean   Commit or Rollback.
--                                                 FALSE(default) or TRUE
--   p_dated_table_id               Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_dated_table
  (
   p_validate                       in     boolean default false
  ,p_dated_table_id                       in     number
  ,p_object_version_number                in     number
  );
end pay_dated_tables_api;

 

/
