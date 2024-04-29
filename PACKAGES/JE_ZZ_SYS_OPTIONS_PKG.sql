--------------------------------------------------------
--  DDL for Package JE_ZZ_SYS_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_ZZ_SYS_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: jezzsops.pls 120.1.12010000.2 2008/08/04 12:28:24 vgadde ship $ */


/* =======================================================================*
 | Fetches the value of Profile JENL_PAYMENT_SEPARATION                   |
 * =======================================================================*/

        FUNCTION get_nl_pymt_separation
        (
	p_org_id IN NUMBER
	) RETURN  VARCHAR2;

/* =======================================================================*
 | Fetches the value of Profile JEIT_EXEMPT_TAX_TAG                       |
 * =======================================================================*/

       FUNCTION get_it_exempt_tax
        (
	p_org_id IN NUMBER
	) RETURN  VARCHAR2;


END JE_ZZ_SYS_OPTIONS_PKG;

/
