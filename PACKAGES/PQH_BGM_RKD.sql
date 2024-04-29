--------------------------------------------------------
--  DDL for Package PQH_BGM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BGM_RKD" AUTHID CURRENT_USER as
/* $Header: pqbgmrhi.pkh 120.0 2005/05/29 01:30:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_budget_gl_flex_map_id          in number
 ,p_budget_id_o                    in number
 ,p_gl_account_segment_o           in varchar2
 ,p_payroll_cost_segment_o         in varchar2
 ,p_object_version_number_o        in number
  );
--
end pqh_bgm_rkd;

 

/