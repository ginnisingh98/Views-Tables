--------------------------------------------------------
--  DDL for Package PQH_DST_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DST_RKI" AUTHID CURRENT_USER as
/* $Header: pqdstrhi.pkh 120.0 2005/05/29 01:51:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_dflt_budget_set_id             in number
 ,p_dflt_budget_set_name           in varchar2
 ,p_business_group_id              in number
 ,p_object_version_number          in number
  );
end pqh_dst_rki;

 

/
