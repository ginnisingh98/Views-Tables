--------------------------------------------------------
--  DDL for Package PSP_SALARY_CAPS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_SALARY_CAPS_BK1" AUTHID CURRENT_USER AS
/* $Header: PSPSCAIS.pls 120.2 2006/07/06 13:28:33 tbalacha noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_salary_cap_b >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_salary_cap_b
  ( p_funding_source_code    	in	varchar2
  , p_start_date             	in	date
  , p_end_date               	in	date
  , p_currency_code          	in	varchar2
  , p_annual_salary_cap      	in	number
  , p_seed_flag              	in	varchar2
   );

-- ----------------------------------------------------------------------------
-- |-------------------------< create_salary_cap_a >---------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE create_salary_cap_a
  ( p_salary_cap_id          	in	number
  , p_funding_source_code    	in	varchar2
  , p_start_date             	in	date
  , p_end_date               	in	date
  , p_currency_code          	in	varchar2
  , p_annual_salary_cap      	in	number
  , p_seed_flag              	in	varchar2
  );

END psp_salary_caps_bk1;

/
