--------------------------------------------------------
--  DDL for Package PQH_BUDGET_ELEMENTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_ELEMENTS_BK3" AUTHID CURRENT_USER as
/* $Header: pqbelapi.pkh 120.1 2005/10/02 02:25:41 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_element_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_element_b
  (
   p_budget_element_id              in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_element_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_element_a
  (
   p_budget_element_id              in  number
  ,p_object_version_number          in  number
  );
--
end pqh_budget_elements_bk3;

 

/
