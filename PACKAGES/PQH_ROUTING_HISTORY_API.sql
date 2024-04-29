--------------------------------------------------------
--  DDL for Package PQH_ROUTING_HISTORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_HISTORY_API" AUTHID CURRENT_USER as
/* $Header: pqrhtapi.pkh 120.0 2005/05/29 02:29:01 appldev noship $ */
--
--
TYPE t_rha_tab IS TABLE OF pqh_routing_hist_attribs%ROWTYPE
  INDEX BY BINARY_INTEGER;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_routing_history >------------------------|
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
--   p_approval_cd                  No   varchar2
--   p_comments                     No   varchar2
--   p_forwarded_by_assignment_id   No   number
--   p_forwarded_by_member_id       No   number
--   p_forwarded_by_position_id     No   number
--   p_forwarded_by_user_id         No   number
--   p_forwarded_by_role_id         No   number
--   p_forwarded_to_assignment_id   No   number
--   p_forwarded_to_member_id       No   number
--   p_forwarded_to_position_id     No   number
--   p_forwarded_to_user_id         No   number
--   p_forwarded_to_role_id         No   number
--   p_notification_date            Yes  date
--   p_pos_structure_version_id     No   number
--   p_routing_category_id          Yes  number
--   p_transaction_category_id      Yes  number
--   p_transaction_id               Yes  number
--   p_user_action_cd               Yes  varchar2
--   p_from_range_name              No   varchar2
--   p_to_range_name                No   varchar2
--   p_list_range_name              No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_routing_history_id           Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_routing_history
(
   p_validate                       in boolean    default false
  ,p_routing_history_id             out nocopy number
  ,p_approval_cd                    in  varchar2  default null
  ,p_comments                       in  varchar2  default null
  ,p_forwarded_by_assignment_id     in  number    default null
  ,p_forwarded_by_member_id         in  number    default null
  ,p_forwarded_by_position_id       in  number    default null
  ,p_forwarded_by_user_id           in  number    default null
  ,p_forwarded_by_role_id           in  number    default null
  ,p_forwarded_to_assignment_id     in  number    default null
  ,p_forwarded_to_member_id         in  number    default null
  ,p_forwarded_to_position_id       in  number    default null
  ,p_forwarded_to_user_id           in  number    default null
  ,p_forwarded_to_role_id           in  number    default null
  ,p_notification_date              in  date      default null
  ,p_pos_structure_version_id       in  number    default null
  ,p_routing_category_id            in  number    default null
  ,p_transaction_category_id        in  number    default null
  ,p_transaction_id                 in  number    default null
  ,p_user_action_cd                 in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_from_range_name                in  varchar2  default null
  ,p_to_range_name                  in  varchar2  default null
  ,p_list_range_name                in  varchar2  default null
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_routing_history >------------------------|
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
--   p_routing_history_id           Yes  number    PK of record
--   p_approval_cd                  No   varchar2
--   p_comments                     No   varchar2
--   p_forwarded_by_assignment_id   No   number
--   p_forwarded_by_member_id       No   number
--   p_forwarded_by_position_id     No   number
--   p_forwarded_by_user_id         No   number
--   p_forwarded_by_role_id         No   number
--   p_forwarded_to_assignment_id   No   number
--   p_forwarded_to_member_id       No   number
--   p_forwarded_to_position_id     No   number
--   p_forwarded_to_user_id         No   number
--   p_forwarded_to_role_id         No   number
--   p_notification_date            Yes  date
--   p_pos_structure_version_id     No   number
--   p_routing_category_id          Yes  number
--   p_transaction_category_id      Yes  number
--   p_transaction_id               Yes  number
--   p_user_action_cd               Yes  varchar2
--   p_from_range_name              No   varchar2
--   p_to_range_name                No   varchar2
--   p_list_range_name              No   varchar2
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
procedure update_routing_history
  (
   p_validate                       in boolean    default false
  ,p_routing_history_id             in  number
  ,p_approval_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_comments                       in  varchar2  default hr_api.g_varchar2
  ,p_forwarded_by_assignment_id     in  number    default hr_api.g_number
  ,p_forwarded_by_member_id         in  number    default hr_api.g_number
  ,p_forwarded_by_position_id       in  number    default hr_api.g_number
  ,p_forwarded_by_user_id           in  number    default hr_api.g_number
  ,p_forwarded_by_role_id           in  number    default hr_api.g_number
  ,p_forwarded_to_assignment_id     in  number    default hr_api.g_number
  ,p_forwarded_to_member_id         in  number    default hr_api.g_number
  ,p_forwarded_to_position_id       in  number    default hr_api.g_number
  ,p_forwarded_to_user_id           in  number    default hr_api.g_number
  ,p_forwarded_to_role_id           in  number    default hr_api.g_number
  ,p_notification_date              in  date      default hr_api.g_date
  ,p_pos_structure_version_id       in  number    default hr_api.g_number
  ,p_routing_category_id            in  number    default hr_api.g_number
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_transaction_id                 in  number    default hr_api.g_number
  ,p_user_action_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_from_range_name                in  varchar2  default hr_api.g_varchar2
  ,p_to_range_name                  in  varchar2  default hr_api.g_varchar2
  ,p_list_range_name                in  varchar2  default hr_api.g_varchar2
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_routing_history >------------------------|
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
--   p_routing_history_id           Yes  number    PK of record
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
procedure delete_routing_history
  (
   p_validate                       in boolean        default false
  ,p_routing_history_id             in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in date
  );
--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
procedure create_routing_history_bp
(
   p_validate                       in boolean    default false
  ,p_routing_history_id             out nocopy number
  ,p_approval_cd                    in  varchar2  default null
  ,p_comments                       in  varchar2  default null
  ,p_forwarded_by_assignment_id     in  number    default null
  ,p_forwarded_by_member_id         in  number    default null
  ,p_forwarded_by_position_id       in  number    default null
  ,p_forwarded_by_user_id           in  number    default null
  ,p_forwarded_by_role_id           in  number    default null
  ,p_forwarded_to_assignment_id     in  number    default null
  ,p_forwarded_to_member_id         in  number    default null
  ,p_forwarded_to_position_id       in  number    default null
  ,p_forwarded_to_user_id           in  number    default null
  ,p_forwarded_to_role_id           in  number    default null
  ,p_notification_date              in  date      default null
  ,p_pos_structure_version_id       in  number    default null
  ,p_routing_category_id            in  number    default null
  ,p_transaction_category_id        in  number    default null
  ,p_transaction_id                 in  number    default null
  ,p_user_action_cd                 in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_from_range_name                in  varchar2  default null
  ,p_to_range_name                  in  varchar2  default null
  ,p_list_range_name                in  varchar2  default null
  ,p_effective_date                 in  date
  ,p_rha_tab                        in t_rha_tab
 );


--
end pqh_routing_history_api;

 

/
