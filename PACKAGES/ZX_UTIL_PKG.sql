--------------------------------------------------------
--  DDL for Package ZX_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: zxutils.pls 120.1 2006/10/11 23:39:14 akaran noship $ */

TYPE t_zx_lookups_table IS TABLE OF VARCHAR2(80)
      INDEX BY BINARY_INTEGER;

pg_zx_lookups_rec t_zx_lookups_table;

FUNCTION get_lookup_meaning (p_lookup_type  IN VARCHAR2,
                             p_lookup_code  IN VARCHAR2)
         RETURN VARCHAR2;

PROCEDURE copy_accounts(p_tax_account_entity_code  IN VARCHAR2,
                        p_tax_account_entity_id    IN NUMBER);

END ZX_UTIL_PKG;

 

/
