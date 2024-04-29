--------------------------------------------------------
--  DDL for Package PQH_ROUTING_HISTORY_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_HISTORY_BK1" AUTHID CURRENT_USER as
/* $Header: pqrhtapi.pkh 120.0 2005/05/29 02:29:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_routing_history_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_routing_history_b
  (
   p_approval_cd                    in  varchar2
  ,p_comments                       in  varchar2
  ,p_forwarded_by_assignment_id     in  number
  ,p_forwarded_by_member_id         in  number
  ,p_forwarded_by_position_id       in  number
  ,p_forwarded_by_user_id           in  number
  ,p_forwarded_by_role_id           in  number
  ,p_forwarded_to_assignment_id     in  number
  ,p_forwarded_to_member_id         in  number
  ,p_forwarded_to_position_id       in  number
  ,p_forwarded_to_user_id           in  number
  ,p_forwarded_to_role_id           in  number
  ,p_notification_date              in  date
  ,p_pos_structure_version_id       in  number
  ,p_routing_category_id            in  number
  ,p_transaction_category_id        in  number
  ,p_transaction_id                 in  number
  ,p_user_action_cd                 in  varchar2
  ,p_from_range_name                in  varchar2
  ,p_to_range_name                  in  varchar2
  ,p_list_range_name                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_routing_history_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_routing_history_a
  (
   p_routing_history_id             in  number
  ,p_approval_cd                    in  varchar2
  ,p_comments                       in  varchar2
  ,p_forwarded_by_assignment_id     in  number
  ,p_forwarded_by_member_id         in  number
  ,p_forwarded_by_position_id       in  number
  ,p_forwarded_by_user_id           in  number
  ,p_forwarded_by_role_id           in  number
  ,p_forwarded_to_assignment_id     in  number
  ,p_forwarded_to_member_id         in  number
  ,p_forwarded_to_position_id       in  number
  ,p_forwarded_to_user_id           in  number
  ,p_forwarded_to_role_id           in  number
  ,p_notification_date              in  date
  ,p_pos_structure_version_id       in  number
  ,p_routing_category_id            in  number
  ,p_transaction_category_id        in  number
  ,p_transaction_id                 in  number
  ,p_user_action_cd                 in  varchar2
  ,p_object_version_number          in  number
  ,p_from_range_name                in  varchar2
  ,p_to_range_name                  in  varchar2
  ,p_list_range_name                in  varchar2
  ,p_effective_date                 in  date
  );
--
end pqh_routing_history_bk1;

 

/
