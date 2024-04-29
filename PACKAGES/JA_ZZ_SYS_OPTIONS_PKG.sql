--------------------------------------------------------
--  DDL for Package JA_ZZ_SYS_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_ZZ_SYS_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: jazzsops.pls 120.2 2005/10/30 01:48:17 appldev ship $ */


/* =======================================================================*
 | Fetches the value of Profile JA_AU_PO_AUTO_ACCT                        |
 * =======================================================================*/

        FUNCTION get_auto_accounting_flag
        (
	p_org_id IN NUMBER
	) RETURN  VARCHAR2;

/* =======================================================================*
 | Fetches the value of Profile JA_AU_PO_IMP_REQ_FLAG                     |
 * =======================================================================*/

        FUNCTION get_po_import_req_flag
        (
	p_org_id IN NUMBER
	) RETURN  VARCHAR2;


END JA_ZZ_SYS_OPTIONS_PKG;

/
