--------------------------------------------------------
--  DDL for Package PQH_BUDGET_ELEMENTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_ELEMENTS_BK1" AUTHID CURRENT_USER as
/* $Header: pqbelapi.pkh 120.1 2005/10/02 02:25:41 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_budget_element_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_budget_element_b
  (
   p_budget_set_id                  in  number
  ,p_element_type_id                in  number
  ,p_distribution_percentage        in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_budget_element_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_budget_element_a
  (
   p_budget_element_id              in  number
  ,p_budget_set_id                  in  number
  ,p_element_type_id                in  number
  ,p_distribution_percentage        in  number
  ,p_object_version_number          in  number
  );
--
end pqh_budget_elements_bk1;

 

/
