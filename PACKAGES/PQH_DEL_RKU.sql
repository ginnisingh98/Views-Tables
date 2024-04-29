--------------------------------------------------------
--  DDL for Package PQH_DEL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DEL_RKU" AUTHID CURRENT_USER as
/* $Header: pqdelrhi.pkh 120.0 2005/05/29 01:47:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_dflt_budget_element_id         in number
 ,p_dflt_budget_set_id             in number
 ,p_element_type_id                in number
 ,p_dflt_dist_percentage           in number
 ,p_object_version_number          in number
 ,p_dflt_budget_set_id_o           in number
 ,p_element_type_id_o              in number
 ,p_dflt_dist_percentage_o         in number
 ,p_object_version_number_o        in number
  );
--
end pqh_del_rku;

 

/
