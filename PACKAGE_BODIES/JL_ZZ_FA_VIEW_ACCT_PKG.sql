--------------------------------------------------------
--  DDL for Package Body JL_ZZ_FA_VIEW_ACCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_FA_VIEW_ACCT_PKG" AS
/* $Header: jlzzfvab.pls 120.0 2005/06/09 23:19:07 appradha ship $ */

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   is_JL_FA_view_acct                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to set the view accounting  option from FA to GL inquiry     --
--   menu for inlfation adjustment .                            --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 120.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--                                                                        --
-- HISTORY:                                                               --
--    06/09/05     Amit Pradhan   Created                                 --
----------------------------------------------------------------------------
FUNCTION is_JL_FA_view_acct
		RETURN BOOLEAN IS

  l_FA_view_acct_flag BOOLEAN;
  l_dummy	NUMBER;
  l_country_code   VARCHAR2(2);

BEGIN

  l_FA_view_acct_flag := FALSE;
  l_country_code := fnd_profile.value('JGZZ_COUNTRY_CODE');
  IF l_country_code IN ('CO') THEN
    l_FA_view_acct_flag := TRUE;
  ELSE
    l_FA_view_acct_flag := FALSE;
  END IF;

  RETURN ( l_FA_view_acct_flag );

  EXCEPTION
    WHEN OTHERS THEN

      RETURN FALSE;

END is_JL_FA_view_acct;

END jl_zz_fa_view_acct_pkg;

/
