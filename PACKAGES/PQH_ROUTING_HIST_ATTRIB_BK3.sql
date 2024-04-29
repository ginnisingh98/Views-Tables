--------------------------------------------------------
--  DDL for Package PQH_ROUTING_HIST_ATTRIB_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_HIST_ATTRIB_BK3" AUTHID CURRENT_USER as
/* $Header: pqrhaapi.pkh 120.0 2005/05/29 02:28:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_routing_hist_attrib_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_routing_hist_attrib_b
  (
   p_routing_hist_attrib_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_routing_hist_attrib_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_routing_hist_attrib_a
  (
   p_routing_hist_attrib_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_routing_hist_attrib_bk3;

 

/
