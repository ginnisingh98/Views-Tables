--------------------------------------------------------
--  DDL for Package JG_ZZ_SYS_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_SYS_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzzsops.pls 120.1 2002/11/01 15:47:23 asrivats ship $ */


/* =======================================================================*
 | Fetches the value of Profile JGZZ_EXTENDED_AWT_CALC                    |
 * =======================================================================*/

        FUNCTION get_extended_awt_calc_flag
        (
	p_org_id IN NUMBER
	) RETURN  VARCHAR2;


END JG_ZZ_SYS_OPTIONS_PKG;

 

/
