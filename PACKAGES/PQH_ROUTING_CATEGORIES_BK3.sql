--------------------------------------------------------
--  DDL for Package PQH_ROUTING_CATEGORIES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_CATEGORIES_BK3" AUTHID CURRENT_USER as
/* $Header: pqrctapi.pkh 120.1 2005/10/02 02:27:11 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ROUTING_CATEGORY_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ROUTING_CATEGORY_b
  (
   p_routing_category_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ROUTING_CATEGORY_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ROUTING_CATEGORY_a
  (
   p_routing_category_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_ROUTING_CATEGORIES_bk3;

 

/
