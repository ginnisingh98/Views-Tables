--------------------------------------------------------
--  DDL for Package PSP_SALARY_CAP_OVERRIDES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_SALARY_CAP_OVERRIDES_BK2" AUTHID CURRENT_USER AS
/* $Header: PSPSOAIS.pls 120.2 2006/07/06 13:27:59 tbalacha noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< update_salary_cap_override_b >-------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE update_salary_cap_override_b
  ( p_salary_cap_override_id	in	number
  , p_funding_source_code    	in	varchar2
  , p_project_id             	in	number
  , p_start_date             	in	date
  , p_end_date               	in	date
  , p_currency_code          	in	varchar2
  , p_annual_salary_cap      	in	number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_salary_cap_override_a >-------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE update_salary_cap_override_a
  ( p_salary_cap_override_id	in	number
  , p_funding_source_code    	in	varchar2
  , p_project_id             	in	number
  , p_start_date             	in	date
  , p_end_date               	in	date
  , p_currency_code          	in	varchar2
  , p_annual_salary_cap      	in	number
  );
END psp_salary_cap_overrides_bk2;

/
