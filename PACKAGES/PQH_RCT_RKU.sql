--------------------------------------------------------
--  DDL for Package PQH_RCT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RCT_RKU" AUTHID CURRENT_USER as
/* $Header: pqrctrhi.pkh 120.0 2005/05/29 02:25:48 appldev noship $ */
--
-- ---------------------------------------------------------------------------+
-- |----------------------------< after_update >------------------------------|
-- ---------------------------------------------------------------------------+
procedure after_update
  (
  p_routing_category_id            in number
 ,p_transaction_category_id        in number
 ,p_enable_flag                    in varchar2
 ,p_default_flag                   in varchar2
 ,p_delete_flag                    in varchar2
 ,p_routing_list_id                in number
 ,p_position_structure_id          in number
 ,p_override_position_id           in number
 ,p_override_assignment_id         in number
 ,p_override_role_id             in number
 ,p_override_user_id             in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_transaction_category_id_o      in number
 ,p_enable_flag_o                   in varchar2
 ,p_default_flag_o                  in varchar2
 ,p_delete_flag_o                    in varchar2
 ,p_routing_list_id_o              in number
 ,p_position_structure_id_o        in number
 ,p_override_position_id_o         in number
 ,p_override_assignment_id_o       in number
 ,p_override_role_id_o           in number
 ,p_override_user_id_o           in number
 ,p_object_version_number_o        in number
  );
end pqh_rct_rku;

 

/
