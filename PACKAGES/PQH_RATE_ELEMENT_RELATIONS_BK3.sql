--------------------------------------------------------
--  DDL for Package PQH_RATE_ELEMENT_RELATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RATE_ELEMENT_RELATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqrerapi.pkh 120.2 2005/11/30 15:00:33 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rate_element_relation_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rate_element_relation_b
 ( p_effective_date                in     date
  ,p_rate_element_relation_id     in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rate_element_relation_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rate_element_relation_a
 ( p_effective_date                in     date
  ,p_rate_element_relation_id     in     number
  ,p_object_version_number         in     number
  );


end PQH_rate_element_relations_BK3;

 

/
