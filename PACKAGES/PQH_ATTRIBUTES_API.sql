--------------------------------------------------------
--  DDL for Package PQH_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ATTRIBUTES_API" AUTHID CURRENT_USER as
/* $Header: pqattapi.pkh 120.0 2005/05/29 01:26:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ATTRIBUTE >------------------------|
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
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_attribute_name               Yes  varchar2  Descriptive Flexfield
--   p_master_attribute_id          No   number    Descriptive Flexfield
--   p_master_table_route_id        Yes  number
--   p_column_name                  Yes  varchar2
--   p_column_type                  Yes  varchar2
--   p_enable_flag                  No   varchar2
--   p_width                        Yes  number
--   p_effective_date           Yes  date      Session Date.
--   p_region_itemname                in varchar2
--   p_attribute_itemname             in varchar2
--   p_decode_function_name           in varchar2
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_attribute_id                 Yes  number    Descriptive Flexfield
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_ATTRIBUTE
(
   p_validate                       in boolean    default false
  ,p_attribute_id                   out nocopy number
  ,p_attribute_name                 in  varchar2  default null
  ,p_master_attribute_id            in  number    default null
  ,p_master_table_route_id          in  number    default null
  ,p_column_name                    in  varchar2  default null
  ,p_column_type                    in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default null
  ,p_width                          in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ,p_region_itemname                in varchar2   default null
  ,p_attribute_itemname             in varchar2   default null
  ,p_decode_function_name           in varchar2   default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_ATTRIBUTE >------------------------|
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
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_attribute_id                 Yes  number    Descriptive Flexfield
--   p_attribute_name               Yes  varchar2  Descriptive Flexfield
--   p_master_attribute_id          No   number    Descriptive Flexfield
--   p_master_table_route_id        Yes  number
--   p_column_name                  Yes  varchar2
--   p_column_type                  Yes  varchar2
--   p_enable_flag                  No   varchar2
--   p_width                        Yes  number
--   p_effective_date          Yes  date       Session Date.
--   p_region_itemname                in varchar2
--   p_attribute_itemname             in varchar2
--   p_decode_function_name           in varchar2
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_ATTRIBUTE
  (
   p_validate                       in boolean    default false
  ,p_attribute_id                   in  number
  ,p_attribute_name                 in  varchar2  default hr_api.g_varchar2
  ,p_master_attribute_id            in  number    default hr_api.g_number
  ,p_master_table_route_id          in  number    default hr_api.g_number
  ,p_column_name                    in  varchar2  default hr_api.g_varchar2
  ,p_column_type                    in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_width                          in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ,p_region_itemname                in varchar2   default hr_api.g_varchar2
  ,p_attribute_itemname             in varchar2   default hr_api.g_varchar2
  ,p_decode_function_name           in varchar2   default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ATTRIBUTE >------------------------|
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
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_attribute_id                 Yes  number    Descriptive Flexfield
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_ATTRIBUTE
  (
   p_validate                       in boolean        default false
  ,p_attribute_id                   in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  );
--
--
end pqh_ATTRIBUTES_api;

 

/
