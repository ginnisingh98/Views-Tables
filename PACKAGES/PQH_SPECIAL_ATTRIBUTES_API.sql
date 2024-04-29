--------------------------------------------------------
--  DDL for Package PQH_SPECIAL_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SPECIAL_ATTRIBUTES_API" AUTHID CURRENT_USER as
/* $Header: pqsatapi.pkh 120.0 2005/05/29 02:40:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_special_attribute >------------------------|
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
--   p_txn_category_attribute_id    Yes  number    Descriptive Flexfield
--   p_attribute_type_cd            No   varchar2  Descriptive Flexfield
--   p_key_attribute_type           No   varchar2  Descriptive Flexfield
--   p_enable_flag                  Yes  varchar2
--   p_flex_code                    No   varchar2
--   p_ddf_column_name              No   varchar2
--   p_ddf_value_column_name        No   varchar2
--   p_context                      Yes  varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_special_attribute_id         Yes  number    Descriptive Flexfield
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_special_attribute
(
   p_validate                       in boolean    default false
  ,p_special_attribute_id           out nocopy number
  ,p_txn_category_attribute_id      in  number    default null
  ,p_attribute_type_cd              in  varchar2  default null
  ,p_key_attribute_type              in  varchar2  default null
  ,p_enable_flag              in  varchar2  default null
  ,p_flex_code                      in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_ddf_column_name                in  varchar2  default null
  ,p_ddf_value_column_name          in  varchar2  default null
  ,p_context                        in  varchar2  default null
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_special_attribute >------------------------|
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
--   p_special_attribute_id         Yes  number    Descriptive Flexfield
--   p_txn_category_attribute_id    Yes  number    Descriptive Flexfield
--   p_attribute_type_cd            No   varchar2  Descriptive Flexfield
--   p_key_attribute_type           No   varchar2  Descriptive Flexfield
--   p_enable_flag                  Yes  varchar2
--   p_flex_code                    No   varchar2
--   p_ddf_column_name              No   varchar2
--   p_ddf_value_column_name        No   varchar2
--   p_context                      Yes  varchar2
--   p_effective_date          Yes  date       Session Date.
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
procedure update_special_attribute
  (
   p_validate                       in boolean    default false
  ,p_special_attribute_id           in  number
  ,p_txn_category_attribute_id      in  number    default hr_api.g_number
  ,p_attribute_type_cd              in  varchar2  default hr_api.g_varchar2
  ,p_key_attribute_type              in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag              in  varchar2  default hr_api.g_varchar2
  ,p_flex_code                      in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_ddf_column_name                in  varchar2  default hr_api.g_varchar2
  ,p_ddf_value_column_name          in  varchar2  default hr_api.g_varchar2
  ,p_context                        in  varchar2  default hr_api.g_varchar2
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_special_attribute >------------------------|
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
--   p_special_attribute_id         Yes  number    Descriptive Flexfield
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
procedure delete_special_attribute
  (
   p_validate                       in boolean        default false
  ,p_special_attribute_id           in  number
  ,p_object_version_number          in number
  ,p_effective_date            in date
  );
--

--















end pqh_special_attributes_api;

 

/
