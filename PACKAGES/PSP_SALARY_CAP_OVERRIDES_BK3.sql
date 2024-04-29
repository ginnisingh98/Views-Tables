--------------------------------------------------------
--  DDL for Package PSP_SALARY_CAP_OVERRIDES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_SALARY_CAP_OVERRIDES_BK3" AUTHID CURRENT_USER AS
/* $Header: PSPSOAIS.pls 120.2 2006/07/06 13:27:59 tbalacha noship $ */

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_salary_cap_override_b >-------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_salary_cap_override_b
  ( p_salary_cap_override_id    	in	number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_salary_cap_override_a >-------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_salary_cap_override_a
  ( p_salary_cap_override_id    	in	number
  );
END psp_salary_cap_overrides_bk3;


/
