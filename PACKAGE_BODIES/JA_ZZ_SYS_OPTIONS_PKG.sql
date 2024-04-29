--------------------------------------------------------
--  DDL for Package Body JA_ZZ_SYS_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_ZZ_SYS_OPTIONS_PKG" AS
/* $Header: jazzsopb.pls 120.2 2005/10/30 01:48:16 appldev ship $ */


/* ===============================================================*
 | Fetches the value of Requisition Auto Accounting Flag          |
 * ===============================================================*/

        FUNCTION get_auto_accounting_flag
        (
	p_org_id IN NUMBER
	) RETURN    VARCHAR2 IS

        x_auto_acct_flag   po_system_parameters_all.global_attribute3%type;

        BEGIN

          BEGIN

            /* Y-Yes; N-No */
            Select global_attribute3
              Into   x_auto_acct_flag
              From   po_system_parameters_all
              Where  nvl(org_id,-99) = nvl(p_org_id,-99);
          Exception
            when others THEN
              x_auto_acct_flag := NULL;
          END;

          return(x_auto_acct_flag);

        END get_auto_accounting_flag;

/* ================================================================*
 | Fetches the value of Australian Requisition Import Flag         |
 * ================================================================*/

        FUNCTION get_po_import_req_flag
        (
	p_org_id IN NUMBER
	) RETURN    VARCHAR2 IS

        x_po_import_req_flag   po_system_parameters_all.global_attribute4%type;

        BEGIN

          BEGIN

            /* Y-Yes; N-No */
            Select global_attribute4
              Into   x_po_import_req_flag
              From   po_system_parameters_all
              Where  nvl(org_id,-99) = nvl(p_org_id,-99);
          Exception
            when others THEN
              x_po_import_req_flag := NULL;
          END;

          return(x_po_import_req_flag);

         END get_po_import_req_flag;


END JA_ZZ_SYS_OPTIONS_PKG;

/
