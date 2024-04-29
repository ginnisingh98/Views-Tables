--------------------------------------------------------
--  DDL for Package PQH_BEL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BEL_RKI" AUTHID CURRENT_USER as
/* $Header: pqbelrhi.pkh 120.0 2005/05/29 01:29:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_budget_element_id              in number
 ,p_budget_set_id                  in number
 ,p_element_type_id                in number
 ,p_distribution_percentage        in number
 ,p_object_version_number          in number
  );
end pqh_bel_rki;

 

/
