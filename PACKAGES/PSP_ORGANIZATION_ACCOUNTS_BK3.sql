--------------------------------------------------------
--  DDL for Package PSP_ORGANIZATION_ACCOUNTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ORGANIZATION_ACCOUNTS_BK3" AUTHID CURRENT_USER AS
/* $Header: PSPOAAIS.pls 120.2 2006/07/06 13:26:34 tbalacha noship $ */

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_organization_account_b >-------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_organization_account_b
  ( p_organization_account_id    	in	number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_organization_account_a >-------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_organization_account_a
  ( p_organization_account_id    	in	number
  );
END psp_organization_accounts_bk3;


/
