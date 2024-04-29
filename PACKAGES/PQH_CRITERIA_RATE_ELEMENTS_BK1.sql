--------------------------------------------------------
--  DDL for Package PQH_CRITERIA_RATE_ELEMENTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRITERIA_RATE_ELEMENTS_BK1" AUTHID CURRENT_USER as
/* $Header: pqcreapi.pkh 120.4 2006/04/21 15:18:07 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_criteria_rate_element_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_criteria_rate_element_b
 ( p_effective_date               in     date
  ,p_criteria_rate_defn_id        in     number
  ,p_element_type_id              in     number
  ,p_input_value_id               in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_criteria_rate_element_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_criteria_rate_element_a
 (
   p_effective_date               in     date
  ,p_criteria_rate_element_id     in     number
  ,p_criteria_rate_defn_id        in     number
  ,p_element_type_id              in     number
  ,p_input_value_id               in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_object_version_number        in     number
 );

end PQH_CRITERIA_RATE_ELEMENTS_BK1;

 

/
