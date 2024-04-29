--------------------------------------------------------
--  DDL for Package PSP_SALARY_CAPS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_SALARY_CAPS_BK3" AUTHID CURRENT_USER AS
/* $Header: PSPSCAIS.pls 120.2 2006/07/06 13:28:33 tbalacha noship $ */

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_salary_cap_b >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_salary_cap_b
  ( p_salary_cap_id    	in	number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_salary_cap_a >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_salary_cap_a
  ( p_salary_cap_id    	in	number
  );
END psp_salary_caps_bk3;


/
