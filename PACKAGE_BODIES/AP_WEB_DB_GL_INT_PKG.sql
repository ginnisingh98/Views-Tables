--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_GL_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_GL_INT_PKG" AS
/* $Header: apwdbglb.pls 120.1 2005/10/02 20:12:12 albowicz noship $ */

--
-- set_aff_validation_org_context
-- Author: kwidjaja
-- Purpose: To provide a wrapper procedure for setting the accounting flexfield
--          validation context based on the org ID.
--
-- Input: p_org_id
--
-- Output: N/A
--
PROCEDURE set_aff_validation_org_context(
        p_org_id IN NUMBER
) IS

BEGIN
  -- Call GL API and pass in Org ID
  -- The following call is not available in 11.5 code line, only 12.0 (R12)
  -- This API needs to be called in R12 and above.
  GL_GLOBAL.set_aff_validation('OU', p_org_id);
  NULL;
END set_aff_validation_org_context;

END AP_WEB_DB_GL_INT_PKG;

/
