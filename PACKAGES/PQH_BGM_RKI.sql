--------------------------------------------------------
--  DDL for Package PQH_BGM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BGM_RKI" AUTHID CURRENT_USER as
/* $Header: pqbgmrhi.pkh 120.0 2005/05/29 01:30:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_budget_gl_flex_map_id          in number
 ,p_budget_id                      in number
 ,p_gl_account_segment             in varchar2
 ,p_payroll_cost_segment           in varchar2
 ,p_object_version_number          in number
  );
end pqh_bgm_rki;

 

/
