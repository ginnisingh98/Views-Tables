--------------------------------------------------------
--  DDL for Package PQH_RATE_ELEMENT_RELATIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RATE_ELEMENT_RELATIONS_BK1" AUTHID CURRENT_USER as
/* $Header: pqrerapi.pkh 120.2 2005/11/30 15:00:33 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_rate_element_relation_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rate_element_relation_b
 (
   p_effective_date               in     date
  ,p_criteria_rate_element_id     in     number
  ,p_relation_type_cd             in     varchar2
  ,p_rel_element_type_id          in     number
  ,p_rel_input_value_id           in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  );


--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_rate_element_relation_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rate_element_relation_a
 (
   p_effective_date               in     date
  ,p_rate_element_relation_id     in     number
  ,p_criteria_rate_element_id     in     number
  ,p_relation_type_cd             in     varchar2
  ,p_rel_element_type_id          in     number
  ,p_rel_input_value_id           in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_object_version_number        in     number
  );


end PQH_rate_element_relations_BK1;

 

/
