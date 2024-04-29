--------------------------------------------------------
--  DDL for Package PQH_DEL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DEL_RKI" AUTHID CURRENT_USER as
/* $Header: pqdelrhi.pkh 120.0 2005/05/29 01:47:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_dflt_budget_element_id         in number
 ,p_dflt_budget_set_id             in number
 ,p_element_type_id                in number
 ,p_dflt_dist_percentage           in number
 ,p_object_version_number          in number
  );
end pqh_del_rki;

 

/
