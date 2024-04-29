--------------------------------------------------------
--  DDL for Package PQH_ROUTING_LISTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_LISTS_BK2" AUTHID CURRENT_USER as
/* $Header: pqrltapi.pkh 120.1 2005/10/02 02:27:40 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_routing_list_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_routing_list_b
  (
   p_routing_list_id                in  number
  ,p_routing_list_name              in  varchar2
  ,p_enable_flag	            in  varchar2
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_routing_list_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_routing_list_a
  (
   p_routing_list_id                in  number
  ,p_routing_list_name              in  varchar2
  ,p_enable_flag	            in  varchar2
  ,p_object_version_number          in  number
  );
--
end PQH_ROUTING_LISTS_bk2;

 

/
