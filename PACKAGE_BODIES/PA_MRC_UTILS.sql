--------------------------------------------------------
--  DDL for Package Body PA_MRC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MRC_UTILS" AS
/* $Header: PAMRCTRB.pls 120.3 2005/08/26 11:29:45 skannoji noship $ */

-- ========================================================================
-- PROCEDURE EnableMRCTriggers
-- ========================================================================
--
-- Values for p_Calling_Mode
--  1.  ENABLE
--  2.  ENABLE_DISABLE
--  3.  DISABLE

/* Stubbed out the package for bug 4553804 and MRC
   migration to SLA project */

PROCEDURE  EnableMRCTriggers(  p_Calling_Mode           IN     VARCHAR2
                             , X_err_code               IN OUT NOCOPY NUMBER
                             , X_err_stage              IN OUT NOCOPY VARCHAR2 ) IS



  -- c1 INTEGER ; Stubbing out
  -- c2 INTEGER ; Stubbing out
  -- stm  VARCHAR2(4000); Stubbing out
  -- l_enable_check  VARCHAR2(100) := ' disable ';  Stubbing out

BEGIN

  NULL;

EXCEPTION
    WHEN  OTHERS  THEN
      RAISE;

end ;

end;

/
