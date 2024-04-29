--------------------------------------------------------
--  DDL for Package JG_ZZ_VAT_ALLOC_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_VAT_ALLOC_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: jgzzvars.pls 120.1 2006/06/23 12:24:00 brathod ship $*/
/* CHANGE HISTORY ------------------------------------------------------------------------------------------
DATE            AUTHOR       VERSION       BUG NO.         DESCRIPTION
(DD/MM/YYYY)    (UID)
------------------------------------------------------------------------------------------------------------
23/6/2006       BRATHOD      120.1         5166688         Modified the signature of INSERT_ROW procedure in
                                                           to return rowid to caller of API by adding out
                                                           parameter in the call. Refer bug# 5166688 for details
-----------------------------------------------------------------------------------------------------------*/
  procedure insert_row
            ( x_record                          jg_zz_vat_alloc_rules%rowtype
            , x_allocation_rule_id  out nocopy  jg_zz_vat_alloc_rules.allocation_rule_id%type
            , x_row_id              out nocopy  rowid
            );
  procedure lock_row
            ( x_row_id                          rowid
            , x_record                          jg_zz_vat_alloc_rules%rowtype
            );
  procedure update_row
            ( x_record                           jg_zz_vat_alloc_rules%rowtype
            );
  procedure delete_row
            ( x_allocation_rule_id               jg_zz_vat_alloc_rules.allocation_rule_id%type
            );

end jg_zz_vat_alloc_rules_pkg;

 

/
