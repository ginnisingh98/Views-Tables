--------------------------------------------------------
--  DDL for Package Body JG_ZZ_SYS_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_SYS_OPTIONS_PKG" AS
/* $Header: jgzzsopb.pls 120.2 2003/04/18 21:05:20 thwon ship $ */


/* =======================================================================*
 | Fetches the value of Profile JGZZ_EXTENDED_AWT_CALC                    |
 * =======================================================================*/

        FUNCTION get_extended_awt_calc_flag
        (
	p_org_id IN NUMBER
	) RETURN    VARCHAR2 IS

        x_ext_awt_flag   ap_system_parameters_all.global_attribute6%type;

        BEGIN

          BEGIN

            /* Y-Yes; N-No */
            Select global_attribute6
              Into   x_ext_awt_flag
              From   ap_system_parameters_all
              Where  nvl(org_id,-99) = nvl(p_org_id,-99);
          Exception
            when others THEN
              x_ext_awt_flag := NULL;
          END;

        END get_extended_awt_calc_flag;

END JG_ZZ_SYS_OPTIONS_PKG;

/
