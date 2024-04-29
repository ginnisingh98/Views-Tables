--------------------------------------------------------
--  DDL for Package BEN_POPUP_MESSAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POPUP_MESSAGE_API" AUTHID CURRENT_USER as
/* $Header: bepumapi.pkh 120.0 2005/05/28 11:26:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_popup_message >------------------------|
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
--   p_pop_name                     No   varchar2
--   p_formula_id                   No   number
--   p_function_name                No   varchar2
--   p_block_name                   No   varchar2
--   p_field_name                   No   varchar2
--   p_event_name                   No   varchar2
--   p_message                      No   varchar2
--   p_message_type                 No   varchar2
--   p_business_group_id            No   number    Business Group of Record
--   p_start_date                   No   date
--   p_end_date                     No   date
--   p_no_formula_flag              No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_pop_up_messages_id           Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_popup_message
(
   p_validate                       in boolean    default false
  ,p_pop_up_messages_id             out nocopy number
  ,p_pop_name                       in  varchar2  default null
  ,p_formula_id                     in  number    default null
  ,p_function_name                  in  varchar2  default null
  ,p_block_name                     in  varchar2  default null
  ,p_field_name                     in  varchar2  default null
  ,p_event_name                     in  varchar2  default null
  ,p_message                        in  varchar2  default null
  ,p_message_type                   in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_start_date                     in  date      default null
  ,p_end_date                       in  date      default null
  ,p_no_formula_flag                in  varchar2  default null
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_popup_message >------------------------|
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
--   p_pop_up_messages_id           Yes  number    PK of record
--   p_pop_name                     No   varchar2
--   p_formula_id                   No   number
--   p_function_name                No   varchar2
--   p_block_name                   No   varchar2
--   p_field_name                   No   varchar2
--   p_event_name                   No   varchar2
--   p_message                      No   varchar2
--   p_message_type                 No   varchar2
--   p_business_group_id            No   number    Business Group of Record
--   p_start_date                   No   date
--   p_end_date                     No   date
--   p_no_formula_flag              No   varchar2
--   p_effective_date          Yes  date       Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_popup_message
  (
   p_validate                       in boolean    default false
  ,p_pop_up_messages_id             in  number
  ,p_pop_name                       in  varchar2  default hr_api.g_varchar2
  ,p_formula_id                     in  number    default hr_api.g_number
  ,p_function_name                  in  varchar2  default hr_api.g_varchar2
  ,p_block_name                     in  varchar2  default hr_api.g_varchar2
  ,p_field_name                     in  varchar2  default hr_api.g_varchar2
  ,p_event_name                     in  varchar2  default hr_api.g_varchar2
  ,p_message                        in  varchar2  default hr_api.g_varchar2
  ,p_message_type                   in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_start_date                     in  date      default hr_api.g_date
  ,p_end_date                       in  date      default hr_api.g_date
  ,p_no_formula_flag                in  varchar2  default hr_api.g_varchar2
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_popup_message >------------------------|
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
--   p_pop_up_messages_id           Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_popup_message
  (
   p_validate                       in boolean        default false
  ,p_pop_up_messages_id             in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
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
--   p_pop_up_messages_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_pop_up_messages_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_popup_message_api;

 

/
