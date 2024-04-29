--------------------------------------------------------
--  DDL for Package PQH_DST_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DST_RKU" AUTHID CURRENT_USER as
/* $Header: pqdstrhi.pkh 120.0 2005/05/29 01:51:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_dflt_budget_set_id             in number
 ,p_dflt_budget_set_name           in varchar2
 ,p_business_group_id              in number
 ,p_object_version_number          in number
 ,p_dflt_budget_set_name_o         in varchar2
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in number
  );
--
end pqh_dst_rku;

 

/
