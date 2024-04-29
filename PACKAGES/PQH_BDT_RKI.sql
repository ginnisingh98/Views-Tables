--------------------------------------------------------
--  DDL for Package PQH_BDT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDT_RKI" AUTHID CURRENT_USER as
/* $Header: pqbdtrhi.pkh 120.0 2005/05/29 01:28:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_budget_detail_id               in number
 ,p_organization_id                in number
 ,p_job_id                         in number
 ,p_position_id                    in number
 ,p_grade_id                       in number
 ,p_budget_version_id              in number
 ,p_budget_unit1_percent           in number
 ,p_budget_unit1_value_type_cd              in varchar2
 ,p_budget_unit1_value             in number
 ,p_budget_unit1_available          in number
 ,p_budget_unit2_percent           in number
 ,p_budget_unit2_value_type_cd              in varchar2
 ,p_budget_unit2_value             in number
 ,p_budget_unit2_available          in number
 ,p_budget_unit3_percent           in number
 ,p_budget_unit3_value_type_cd              in varchar2
 ,p_budget_unit3_value             in number
 ,p_budget_unit3_available          in number
 ,p_gl_status                               in varchar2
 ,p_object_version_number          in number
  );
end pqh_bdt_rki;

 

/
