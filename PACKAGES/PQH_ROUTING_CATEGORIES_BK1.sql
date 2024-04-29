--------------------------------------------------------
--  DDL for Package PQH_ROUTING_CATEGORIES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_CATEGORIES_BK1" AUTHID CURRENT_USER as
/* $Header: pqrctapi.pkh 120.1 2005/10/02 02:27:11 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ROUTING_CATEGORY_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ROUTING_CATEGORY_b
  (
   p_transaction_category_id        in  number
  ,p_enable_flag                    in  varchar2
  ,p_default_flag                    in  varchar2
  ,p_delete_flag                    in  varchar2
  ,p_effective_date                 in  date
  ,p_routing_list_id                in  number
  ,p_position_structure_id          in  number
  ,p_override_position_id           in  number
  ,p_override_assignment_id         in  number
  ,p_override_role_id             in  number
  ,p_override_user_id             in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ROUTING_CATEGORY_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ROUTING_CATEGORY_a
  (
   p_routing_category_id            in  number
  ,p_transaction_category_id        in  number
  ,p_enable_flag                    in  varchar2
  ,p_default_flag                    in  varchar2
  ,p_delete_flag                    in  varchar2
  ,p_routing_list_id                in  number
  ,p_position_structure_id          in  number
  ,p_override_position_id           in  number
  ,p_override_assignment_id         in  number
  ,p_override_role_id             in  number
  ,p_override_user_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_ROUTING_CATEGORIES_bk1;

 

/
