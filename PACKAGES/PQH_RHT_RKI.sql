--------------------------------------------------------
--  DDL for Package PQH_RHT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RHT_RKI" AUTHID CURRENT_USER as
/* $Header: pqrhtrhi.pkh 120.0 2005/05/29 02:29:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_routing_history_id             in number
 ,p_approval_cd                    in varchar2
 ,p_comments                       in varchar2
 ,p_forwarded_by_assignment_id     in number
 ,p_forwarded_by_member_id         in number
 ,p_forwarded_by_position_id       in number
 ,p_forwarded_by_user_id           in number
 ,p_forwarded_by_role_id           in number
 ,p_forwarded_to_assignment_id     in number
 ,p_forwarded_to_member_id         in number
 ,p_forwarded_to_position_id       in number
 ,p_forwarded_to_user_id           in number
 ,p_forwarded_to_role_id           in number
 ,p_notification_date              in date
 ,p_pos_structure_version_id       in number
 ,p_routing_category_id            in number
 ,p_transaction_category_id        in number
 ,p_transaction_id                 in number
 ,p_user_action_cd                 in varchar2
 ,p_from_range_name                in varchar2
 ,p_to_range_name                  in varchar2
 ,p_list_range_name                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end pqh_rht_rki;

 

/
