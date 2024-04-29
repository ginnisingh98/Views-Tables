--------------------------------------------------------
--  DDL for Package Body JL_ZZ_FA_DRILL_DOWN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_FA_DRILL_DOWN_PKG" AS
/* $Header: jlzzfddb.pls 120.5 2006/04/04 20:32:45 svaze ship $ */

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   is_JL_FA_drilldown                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to set the drill down option in the GL inquiry     --
--   menu for inlfation adjustment categories.                            --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--       p_je_head_id   -                                                 --
--       p_je_source    -                                                 --
--       p_je_category  -                                                 --
--                                                                        --
-- HISTORY:                                                               --
--    01/21/00     Santosh Vaze   Created                                 --
--    03-Oct-2005  Cuau Leyva BUG 4650081.Profile for country is replaced --
--                            by call to JG Shared pkg.                   --
--                                                                        --
--                                                                        --
----------------------------------------------------------------------------
FUNCTION is_JL_FA_drilldown (
		p_je_header_id		NUMBER
		,p_je_source		VARCHAR2
		,p_je_category		VARCHAR2 ) RETURN BOOLEAN IS

/* Bug 5136047:
   In R12 due to SLA uptake, core FA no longer allows "GL journal entry source"
   to be entered using Book Controls window.
   "GL journal entry source" is set at the application level in SLA.
   Though, gl_je_source value is available in fa_book_controls
   for books upgraded from R11i, the source of truth is always as follows.
   The "GL journal entry source" will be derived from JE_SOURCE_NAME from
   XLA_SUBLEDGERS for application_id = 140.
   Hence, there is no need to look at fa_book_controls for books upgraded
   from R1i.
*/

  CURSOR fab_c ( c_jeh_id 		NUMBER,
	     c_je_source	VARCHAR2,
	     c_je_category	VARCHAR2) IS
    SELECT 140
      FROM DUAL
     WHERE EXISTS ( SELECT 1
      		      FROM fa_book_controls bc,
			   gl_je_headers jeh,
                           xla_subledgers xs
     		     WHERE jeh.je_header_id = c_jeh_id
		       AND bc.set_of_books_id = jeh.ledger_id
       		       AND xs.je_source_name = c_je_source
                       AND xs.application_id = 140
       		       AND bc.book_class = 'TAX'
       		       AND bc.global_attribute1 = 'Y'
       		       AND c_je_category IN (
				 bc.GLOBAL_ATTRIBUTE6
 			 	,bc.GLOBAL_ATTRIBUTE7
 			 	,bc.GLOBAL_ATTRIBUTE8
 			 	,bc.GLOBAL_ATTRIBUTE9
 			 	,bc.GLOBAL_ATTRIBUTE10
 			 	,bc.GLOBAL_ATTRIBUTE11
 			 	,bc.GLOBAL_ATTRIBUTE12
 			 	,bc.GLOBAL_ATTRIBUTE14
 			 	,bc.GLOBAL_ATTRIBUTE15
 			 	,bc.GLOBAL_ATTRIBUTE16
 			 	,bc.GLOBAL_ATTRIBUTE17
 			 	,bc.GLOBAL_ATTRIBUTE18 )
		 );

  l_FA_drilldown_flag	BOOLEAN;
  l_dummy	NUMBER;
  l_country_code   VARCHAR2(2);

BEGIN

  l_FA_drilldown_flag := FALSE;
  -------------------------------------------------------------------------
  -- BUG 4650081. Profile for country is replaced by call to JG Shared pkg.
  -------------------------------------------------------------------------
  l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY;

  IF l_country_code IN ('CO') THEN
     OPEN fab_c ( p_je_header_id, p_je_source, p_je_category);
     FETCH fab_c INTO l_dummy;

     IF fab_c%FOUND THEN
        l_FA_drilldown_flag := TRUE;
     ELSE
        l_FA_drilldown_flag := FALSE;
     END IF;

     CLOSE fab_c;

  END IF;
  RETURN ( l_FA_drilldown_flag );

  EXCEPTION
    WHEN OTHERS THEN

      RETURN FALSE;

END is_JL_FA_drilldown;

END jl_zz_fa_drill_down_pkg;

/
