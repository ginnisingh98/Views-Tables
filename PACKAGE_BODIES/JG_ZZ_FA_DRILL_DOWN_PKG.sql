--------------------------------------------------------
--  DDL for Package Body JG_ZZ_FA_DRILL_DOWN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_FA_DRILL_DOWN_PKG" AS
/* $Header: jgzzfddb.pls 120.2 2005/08/25 23:24:36 cleyvaol ship $ */

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   is_JG_FA_drilldown                                                   --
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
--       p_je_head_id                                                     --
--       p_je_source                                                      --
--       p_je_category                                                    --
--                                                                        --
-- HISTORY:                                                               --
--    01/21/00     Santosh Vaze   Created                                 --
----------------------------------------------------------------------------
  FUNCTION is_JG_FA_drilldown (
		p_je_header_id		NUMBER
		,p_je_source		VARCHAR2
		,p_je_category		VARCHAR2 ) RETURN BOOLEAN IS

  l_FA_drilldown_flag	BOOLEAN;
  l_product_code        VARCHAR2(2);

  ------------------------------------------------------------
  -- Main function body.                                    --
  ------------------------------------------------------------
  BEGIN

  l_FA_drilldown_flag := FALSE;
  l_product_code := FND_PROFILE.VALUE('JGZZ_PRODUCT_CODE');
  IF l_product_code IS NOT NULL THEN
     IF  l_product_code = 'JL' THEN
         l_FA_drilldown_flag := jl_zz_fa_drill_down_pkg.is_JL_FA_drilldown(
                                          p_je_header_id,
                                          p_je_source,
                                          p_je_category);
     END IF;
  END IF;

  RETURN l_FA_drilldown_flag;

  EXCEPTION
    WHEN OTHERS THEN

      RETURN FALSE;

  END is_JG_FA_drilldown;

END jg_zz_fa_drill_down_pkg;

/
