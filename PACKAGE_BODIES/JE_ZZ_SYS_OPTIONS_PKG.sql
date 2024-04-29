--------------------------------------------------------
--  DDL for Package Body JE_ZZ_SYS_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_ZZ_SYS_OPTIONS_PKG" AS
/* $Header: jezzsopb.pls 120.1.12010000.2 2008/08/04 12:28:13 vgadde ship $ */


/* ==========================================================*
 | Fetches the value of JENL : Payment Separation            |
 * ==========================================================*/

        FUNCTION get_nl_pymt_separation
        (
	p_org_id IN NUMBER
	) RETURN    VARCHAR2 IS

        x_pymt_sepr   ap_system_parameters_all.global_attribute1%type;

        BEGIN
        /* Y = Yes , N = No  */
          BEGIN
            Select global_attribute1
              Into   x_pymt_sepr
              From   ap_system_parameters_all
              Where  nvl(org_id,-99) = nvl(p_org_id,-99);
          Exception
            when others THEN
              x_pymt_sepr := NULL;
          END;

          return(x_pymt_sepr);

        END get_nl_pymt_separation;

/* ==============================================================*
 | Fetches the value of JEIT : Exemption Limit Tax Tag           |
 * ==============================================================*/

        FUNCTION get_it_exempt_tax
        (
	p_org_id IN NUMBER
	) RETURN    VARCHAR2 IS

        x_exempt_ttag  ap_system_parameters_all.global_attribute1%type;

        BEGIN

          BEGIN

            Select global_attribute1
              Into  x_exempt_ttag
              From  ap_system_parameters_all
              Where  nvl(org_id,-99) = nvl(p_org_id,-99);
          Exception
            when others THEN
              x_exempt_ttag := NULL;
          END;

          return(x_exempt_ttag);

       END get_it_exempt_tax;


END JE_ZZ_SYS_OPTIONS_PKG;

/
