--------------------------------------------------------
--  DDL for Package PQH_BUDGET_DETAILS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_DETAILS_BK2" AUTHID CURRENT_USER as
/* $Header: pqbdtapi.pkh 120.1 2005/10/02 02:25:37 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_budget_detail_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_budget_detail_b
  (
   p_budget_detail_id               in  number
  ,p_organization_id                in  number
  ,p_job_id                         in  number
  ,p_position_id                    in  number
  ,p_grade_id                       in  number
  ,p_budget_version_id              in  number
  ,p_budget_unit1_percent           in  number
  ,p_budget_unit1_value_type_cd              in  varchar2
  ,p_budget_unit1_value             in  number
  ,p_budget_unit1_available          in  number
  ,p_budget_unit2_percent           in  number
  ,p_budget_unit2_value_type_cd              in  varchar2
  ,p_budget_unit2_value             in  number
  ,p_budget_unit2_available          in  number
  ,p_budget_unit3_percent           in  number
  ,p_budget_unit3_value_type_cd              in  varchar2
  ,p_budget_unit3_value             in  number
  ,p_budget_unit3_available          in  number
  ,p_gl_status                               in  varchar2
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_budget_detail_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_budget_detail_a
  (
   p_budget_detail_id               in  number
  ,p_organization_id                in  number
  ,p_job_id                         in  number
  ,p_position_id                    in  number
  ,p_grade_id                       in  number
  ,p_budget_version_id              in  number
  ,p_budget_unit1_percent           in  number
  ,p_budget_unit1_value_type_cd              in  varchar2
  ,p_budget_unit1_value             in  number
  ,p_budget_unit1_available          in  number
  ,p_budget_unit2_percent           in  number
  ,p_budget_unit2_value_type_cd              in  varchar2
  ,p_budget_unit2_value             in  number
  ,p_budget_unit2_available          in  number
  ,p_budget_unit3_percent           in  number
  ,p_budget_unit3_value_type_cd              in  varchar2
  ,p_budget_unit3_value             in  number
  ,p_budget_unit3_available          in  number
  ,p_gl_status                               in  varchar2
  ,p_object_version_number          in  number
  );
--
end pqh_budget_details_bk2;

 

/
