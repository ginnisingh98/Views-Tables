--------------------------------------------------------
--  DDL for Package PQH_ROUTING_HISTORY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_HISTORY_BK3" AUTHID CURRENT_USER as
/* $Header: pqrhtapi.pkh 120.0 2005/05/29 02:29:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_routing_history_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_routing_history_b
  (
   p_routing_history_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_routing_history_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_routing_history_a
  (
   p_routing_history_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_routing_history_bk3;

 

/
