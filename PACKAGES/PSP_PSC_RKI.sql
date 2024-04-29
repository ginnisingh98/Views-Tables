--------------------------------------------------------
--  DDL for Package PSP_PSC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PSC_RKI" AUTHID CURRENT_USER as
/* $Header: PSPSCRHS.pls 120.0 2005/11/20 23:55 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_salary_cap_id                in number
  ,p_funding_source_code          in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_currency_code                in varchar2
  ,p_annual_salary_cap            in number
  ,p_object_version_number        in number
  ,p_seed_flag                    in varchar2
  );
end psp_psc_rki;

 

/
