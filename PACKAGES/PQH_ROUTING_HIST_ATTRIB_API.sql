--------------------------------------------------------
--  DDL for Package PQH_ROUTING_HIST_ATTRIB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_HIST_ATTRIB_API" AUTHID CURRENT_USER as
/* $Header: pqrhaapi.pkh 120.0 2005/05/29 02:28:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_routing_hist_attrib >------------------------|
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
--   p_routing_history_id           Yes  number
--   p_attribute_id                 Yes  number    Descriptive Flexfield
--   p_from_char                    No   varchar2
--   p_from_date                    No   date
--   p_from_number                  No   number
--   p_to_char                      No   varchar2
--   p_to_date                      No   date
--   p_to_number                    No   number
--   p_range_type_cd                No   varchar2
--   p_value_date                   No   date
--   p_value_number                 No   number
--   p_value_char                   No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_routing_hist_attrib_id       Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_routing_hist_attrib
(
   p_validate                       in boolean    default false
  ,p_routing_hist_attrib_id         out nocopy number
  ,p_routing_history_id             in  number    default null
  ,p_attribute_id                   in  number    default null
  ,p_from_char                      in  varchar2  default null
  ,p_from_date                      in  date      default null
  ,p_from_number                    in  number    default null
  ,p_to_char                        in  varchar2  default null
  ,p_to_date                        in  date      default null
  ,p_to_number                      in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_range_type_cd                  in  varchar2  default null
  ,p_value_date                     in  date      default null
  ,p_value_number                   in  number    default null
  ,p_value_char                     in  varchar2  default null
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_routing_hist_attrib >------------------------|
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
--   p_routing_hist_attrib_id       Yes  number    PK of record
--   p_routing_history_id           Yes  number
--   p_attribute_id                 Yes  number    Descriptive Flexfield
--   p_from_char                    No   varchar2
--   p_from_date                    No   date
--   p_from_number                  No   number
--   p_to_char                      No   varchar2
--   p_to_date                      No   date
--   p_to_number                    No   number
--   p_range_type_cd                No   varchar2
--   p_value_date                   No   date
--   p_value_number                 No   number
--   p_value_char                   No   varchar2
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
procedure update_routing_hist_attrib
  (
   p_validate                       in boolean    default false
  ,p_routing_hist_attrib_id         in  number
  ,p_routing_history_id             in  number    default hr_api.g_number
  ,p_attribute_id                   in  number    default hr_api.g_number
  ,p_from_char                      in  varchar2  default hr_api.g_varchar2
  ,p_from_date                      in  date      default hr_api.g_date
  ,p_from_number                    in  number    default hr_api.g_number
  ,p_to_char                        in  varchar2  default hr_api.g_varchar2
  ,p_to_date                        in  date      default hr_api.g_date
  ,p_to_number                      in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_range_type_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_value_date                     in  date      default hr_api.g_date
  ,p_value_number                   in  number    default hr_api.g_number
  ,p_value_char                     in  varchar2  default hr_api.g_varchar2
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_routing_hist_attrib >------------------------|
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
--   p_routing_hist_attrib_id       Yes  number    PK of record
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
procedure delete_routing_hist_attrib
  (
   p_validate                       in boolean        default false
  ,p_routing_hist_attrib_id         in  number
  ,p_object_version_number          in number
  ,p_effective_date            in date
  );
--
--
--
end pqh_routing_hist_attrib_api;

 

/
