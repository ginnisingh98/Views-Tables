--------------------------------------------------------
--  DDL for Package PSP_PSO_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PSO_RKD" AUTHID CURRENT_USER as
/* $Header: PSPSORHS.pls 120.0 2005/11/20 23:56 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_salary_cap_override_id       in number
  ,p_funding_source_code_o        in varchar2
  ,p_project_id_o                 in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_currency_code_o              in varchar2
  ,p_annual_salary_cap_o          in number
  ,p_object_version_number_o      in number
  );
--
end psp_pso_rkd;

 

/
