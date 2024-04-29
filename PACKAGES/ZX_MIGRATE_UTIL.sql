--------------------------------------------------------
--  DDL for Package ZX_MIGRATE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_MIGRATE_UTIL" AUTHID CURRENT_USER AS
/* $Header: zxmigrateutils.pls 120.5 2005/07/18 05:49:54 asengupt ship $ */

FUNCTION GET_TAX_REGIME (p_tax_type        IN  VARCHAR2,
                         p_org_id          IN  NUMBER) RETURN VARCHAR2;

FUNCTION GET_TAX (p_tax_name    IN  VARCHAR2 ,
                  p_tax_type    IN  VARCHAR2 ) RETURN VARCHAR2;

FUNCTION IS_INSTALLED(p_product_code IN Varchar2) RETURN VARCHAR2;


PROCEDURE ZX_UPDATE_LOOKUPS(P_UPGRADE_MODE IN VARCHAR2);

PROCEDURE ZX_ALTER_RATES_SEQUENCE;

FUNCTION GET_COUNTRY (p_org_id  IN  NUMBER) RETURN VARCHAR2;

FUNCTION GET_NEXT_SEQID(p_seq_name IN VARCHAR2) RETURN NUMBER;

end Zx_Migrate_Util;

 

/
