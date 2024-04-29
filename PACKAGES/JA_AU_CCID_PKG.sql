--------------------------------------------------------
--  DDL for Package JA_AU_CCID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_AU_CCID_PKG" AUTHID CURRENT_USER as
/* $Header: jaaupccs.pls 115.0 2003/01/08 23:34:28 thwon ship $ */

PROCEDURE JA_AU_AUTOACCOUNTING
          (x_org_id             IN
           mtl_material_transactions.organization_id%TYPE,
           x_subinv             IN
           mtl_material_transactions.subinventory_code%TYPE,
           x_item_id            IN
           mtl_material_transactions.inventory_item_id%TYPE,
           l_transaction_id     IN
           po_requisitions_interface.transaction_id%TYPE);


PROCEDURE JA_AU_GET_COA_SOB
          (x_org_id             IN
           org_organization_definitions.organization_id%TYPE,
           x_chart_of_accts_id  OUT
           org_organization_definitions.chart_of_accounts_id%TYPE,
           x_set_of_books_id    OUT
           org_organization_definitions.set_of_books_id%TYPE);


PROCEDURE JA_AU_GET_REPLN_EXP_ACCTS
          (x_org_id             IN
           org_organization_definitions.organization_id%TYPE,
           x_subinv             IN
           mtl_secondary_inventories.secondary_inventory_name%TYPE,
           x_item_id            IN
           mtl_system_items.inventory_item_id%TYPE,
           x_subinv_ccid        IN OUT
           mtl_secondary_inventories.expense_account%TYPE,
           x_item_ccid          IN OUT
           mtl_system_items.expense_account%TYPE);

FUNCTION JA_AU_GET_SEGMENT_VALUE
         (x_table_name          IN
          JA_AU_ACCT_DEFAULT_SEGS.table_name%TYPE,
          x_constant            IN
          JA_AU_ACCT_DEFAULT_SEGS.constant%TYPE,
          x_segment             IN
          JA_AU_ACCT_DEFAULT_SEGS.segment%TYPE,
          x_subinv_ccid         IN
          mtl_secondary_inventories.expense_account%TYPE,
          x_item_ccid           IN
          mtl_system_items.expense_account%TYPE)
RETURN gl_code_combinations.segment1%TYPE;

FUNCTION JA_AU_GET_VALUE
         (x_ccid                IN
          gl_code_combinations.code_combination_id%TYPE,
          x_segment     IN
          gl_code_combinations.segment1%TYPE)
RETURN gl_code_combinations.segment1%TYPE;

PROCEDURE JA_AU_UPDATE_MTLTRXACCT
          (x_transaction_id     IN
           mtl_transaction_accounts.transaction_id%TYPE,
           x_ccid       IN
           gl_code_combinations.code_combination_id%TYPE);



END JA_AU_CCID_PKG;

 

/
