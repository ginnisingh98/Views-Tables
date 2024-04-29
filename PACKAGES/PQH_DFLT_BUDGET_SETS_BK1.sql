--------------------------------------------------------
--  DDL for Package PQH_DFLT_BUDGET_SETS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DFLT_BUDGET_SETS_BK1" AUTHID CURRENT_USER as
/* $Header: pqdstapi.pkh 120.1 2005/10/02 02:26:48 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_dflt_budget_set_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_dflt_budget_set_b
  (
   p_dflt_budget_set_name           in  varchar2
  ,p_business_group_id              in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_dflt_budget_set_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_dflt_budget_set_a
  (
   p_dflt_budget_set_id             in  number
  ,p_dflt_budget_set_name           in  varchar2
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  );
--
end pqh_dflt_budget_sets_bk1;

 

/
