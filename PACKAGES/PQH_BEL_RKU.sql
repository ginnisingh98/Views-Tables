--------------------------------------------------------
--  DDL for Package PQH_BEL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BEL_RKU" AUTHID CURRENT_USER as
/* $Header: pqbelrhi.pkh 120.0 2005/05/29 01:29:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_budget_element_id              in number
 ,p_budget_set_id                  in number
 ,p_element_type_id                in number
 ,p_distribution_percentage        in number
 ,p_object_version_number          in number
 ,p_budget_set_id_o                in number
 ,p_element_type_id_o              in number
 ,p_distribution_percentage_o      in number
 ,p_object_version_number_o        in number
  );
--
end pqh_bel_rku;

 

/
