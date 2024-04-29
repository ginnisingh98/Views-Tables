--------------------------------------------------------
--  DDL for Package PQH_RHT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RHT_RKD" AUTHID CURRENT_USER as
/* $Header: pqrhtrhi.pkh 120.0 2005/05/29 02:29:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_routing_history_id             in number
 ,p_approval_cd_o                  in varchar2
 ,p_comments_o                     in varchar2
 ,p_forwarded_by_assignment_id_o   in number
 ,p_forwarded_by_member_id_o       in number
 ,p_forwarded_by_position_id_o     in number
 ,p_forwarded_by_user_id_o         in number
 ,p_forwarded_by_role_id_o         in number
 ,p_forwarded_to_assignment_id_o   in number
 ,p_forwarded_to_member_id_o       in number
 ,p_forwarded_to_position_id_o     in number
 ,p_forwarded_to_user_id_o         in number
 ,p_forwarded_to_role_id_o         in number
 ,p_notification_date_o            in date
 ,p_pos_structure_version_id_o     in number
 ,p_routing_category_id_o          in number
 ,p_transaction_category_id_o      in number
 ,p_transaction_id_o               in number
 ,p_user_action_cd_o               in varchar2
 ,p_from_range_name_o              in varchar2
 ,p_to_range_name_o                in varchar2
 ,p_list_range_name_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end pqh_rht_rkd;

 

/
