--------------------------------------------------------
--  DDL for Package PQH_ROUTING_LIST_MEMBERS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_LIST_MEMBERS_BK3" AUTHID CURRENT_USER as
/* $Header: pqrlmapi.pkh 120.1 2005/10/02 02:27:30 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_routing_list_member_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_routing_list_member_b
  (
   p_routing_list_member_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_routing_list_member_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_routing_list_member_a
  (
   p_routing_list_member_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end PQH_ROUTING_LIST_MEMBERS_bk3;

 

/
