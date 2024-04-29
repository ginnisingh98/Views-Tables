--------------------------------------------------------
--  DDL for Package PQH_RCT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RCT_RKI" AUTHID CURRENT_USER as
/* $Header: pqrctrhi.pkh 120.0 2005/05/29 02:25:48 appldev noship $ */
--
-- ---------------------------------------------------------------------------+
-- |-----------------------------< after_insert >-----------------------------|
-- ---------------------------------------------------------------------------+
procedure after_insert
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
  );
end pqh_rct_rki;

 

/
