--------------------------------------------------------
--  DDL for Package PQH_BDGT_CMMTMNT_ELMNTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_CMMTMNT_ELMNTS_BK2" AUTHID CURRENT_USER as
/* $Header: pqbceapi.pkh 120.1 2005/10/02 02:25:33 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_bdgt_cmmtmnt_elmnt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_bdgt_cmmtmnt_elmnt_b
  (
   p_bdgt_cmmtmnt_elmnt_id          in  number
  ,p_budget_id                      in  number
  ,p_actual_commitment_type         in  varchar2
  ,p_element_type_id                in  number
  ,p_salary_basis_flag              in  varchar2
  ,p_element_input_value_id         in  number
  ,p_balance_type_id                in  number
  ,p_frequency_input_value_id       in  number
  ,p_formula_id                     in  number
  ,p_dflt_elmnt_frequency           in  varchar2
  ,p_overhead_percentage            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_bdgt_cmmtmnt_elmnt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_bdgt_cmmtmnt_elmnt_a
  (
   p_bdgt_cmmtmnt_elmnt_id          in  number
  ,p_budget_id                      in  number
  ,p_actual_commitment_type         in  varchar2
  ,p_element_type_id                in  number
  ,p_salary_basis_flag              in  varchar2
  ,p_element_input_value_id         in  number
  ,p_balance_type_id                in  number
  ,p_frequency_input_value_id       in  number
  ,p_formula_id                     in  number
  ,p_dflt_elmnt_frequency           in  varchar2
  ,p_overhead_percentage            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_bdgt_cmmtmnt_elmnts_bk2;

 

/
