--------------------------------------------------------
--  DDL for Package Body JG_ZZ_FA_VIEW_ACCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_FA_VIEW_ACCT_PKG" AS
/* $Header: jgzzfvab.pls 120.1 2005/06/10 16:35:34 appradha ship $ */

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   is_JG_FA_view_acct                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to branch program flow to region specific          --
--   functions which will further set the drill down option in the GL     --
--   inquiry menu for inflation adjustment categories.                    --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--                                                                        --
-- HISTORY:                                                               --
--    01/21/00     Amit Pradhan   Created                                 --
----------------------------------------------------------------------------
  FUNCTION is_JG_FA_view_acct
		RETURN BOOLEAN IS

  l_FA_view_acct_flag	BOOLEAN;

  ------------------------------------------------------------
  -- Main function body.                                    --
  ------------------------------------------------------------
  BEGIN

  l_FA_view_acct_flag := FALSE;

         l_FA_view_acct_flag := jl_zz_fa_view_acct_pkg.is_JL_FA_view_acct;

  RETURN l_FA_view_acct_flag;

  EXCEPTION
    WHEN OTHERS THEN

      RETURN FALSE;

  END is_JG_FA_view_acct;

END jg_zz_fa_view_acct_pkg;

/
