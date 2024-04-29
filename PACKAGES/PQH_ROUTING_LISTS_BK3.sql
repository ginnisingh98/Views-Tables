--------------------------------------------------------
--  DDL for Package PQH_ROUTING_LISTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_LISTS_BK3" AUTHID CURRENT_USER as
/* $Header: pqrltapi.pkh 120.1 2005/10/02 02:27:40 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_routing_list_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_routing_list_b
  (
   p_routing_list_id                in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_routing_list_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_routing_list_a
  (
   p_routing_list_id                in  number
  ,p_object_version_number          in  number
  );
--
end PQH_ROUTING_LISTS_bk3;

 

/
