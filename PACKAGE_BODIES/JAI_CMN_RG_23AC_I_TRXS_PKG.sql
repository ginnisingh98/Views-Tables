--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RG_23AC_I_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RG_23AC_I_TRXS_PKG" AS
/* $Header: jai_cmn_rg_23p1.plb 120.4.12010000.3 2010/04/28 12:43:07 vkaranam ship $ */


PROCEDURE insert_row(

  P_REGISTER_ID OUT NOCOPY JAI_CMN_RG_23AC_I_TRXS.register_id%TYPE,
  -- P_FIN_YEAR                      IN  JAI_CMN_RG_23AC_I_TRXS.fin_year%TYPE,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_23AC_I_TRXS.inventory_item_id%TYPE,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_23AC_I_TRXS.organization_id%TYPE,
  P_QUANTITY_RECEIVED             IN  JAI_CMN_RG_23AC_I_TRXS.quantity_received%TYPE,
  P_RECEIPT_ID                    IN  JAI_CMN_RG_23AC_I_TRXS.RECEIPT_REF%TYPE,
  P_TRANSACTION_TYPE              IN  JAI_CMN_RG_23AC_I_TRXS.transaction_type%TYPE,
  P_RECEIPT_DATE                  IN  JAI_CMN_RG_23AC_I_TRXS.receipt_date%TYPE,
  P_PO_HEADER_ID                  IN  JAI_CMN_RG_23AC_I_TRXS.po_header_id%TYPE,
  P_PO_HEADER_DATE                IN  JAI_CMN_RG_23AC_I_TRXS.po_header_date%TYPE,
  P_PO_LINE_ID                    IN  JAI_CMN_RG_23AC_I_TRXS.po_line_id%TYPE,
  P_PO_LINE_LOCATION_ID           IN  JAI_CMN_RG_23AC_I_TRXS.po_line_location_id%TYPE,
  P_VENDOR_ID                     IN  JAI_CMN_RG_23AC_I_TRXS.vendor_id%TYPE,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_23AC_I_TRXS.vendor_site_id%TYPE,
  P_CUSTOMER_ID                   IN  JAI_CMN_RG_23AC_I_TRXS.customer_id%TYPE,
  P_CUSTOMER_SITE_ID              IN  JAI_CMN_RG_23AC_I_TRXS.customer_site_id%TYPE,
  P_GOODS_ISSUE_ID                IN  JAI_CMN_RG_23AC_I_TRXS.GOODS_ISSUE_ID_REF%TYPE,
  P_GOODS_ISSUE_DATE              IN  JAI_CMN_RG_23AC_I_TRXS.goods_issue_date%TYPE,
  P_GOODS_ISSUE_QUANTITY          IN  JAI_CMN_RG_23AC_I_TRXS.goods_issue_quantity%TYPE,
  P_SALES_INVOICE_ID              IN  JAI_CMN_RG_23AC_I_TRXS.SALES_INVOICE_NO%TYPE,
  P_SALES_INVOICE_DATE            IN  JAI_CMN_RG_23AC_I_TRXS.sales_invoice_date%TYPE,
  P_SALES_INVOICE_QUANTITY        IN  JAI_CMN_RG_23AC_I_TRXS.sales_invoice_quantity%TYPE,
  P_EXCISE_INVOICE_ID             IN  JAI_CMN_RG_23AC_I_TRXS.EXCISE_INVOICE_NO%TYPE,
  P_EXCISE_INVOICE_DATE           IN  JAI_CMN_RG_23AC_I_TRXS.excise_invoice_date%TYPE,
  P_OTH_RECEIPT_QUANTITY          IN  JAI_CMN_RG_23AC_I_TRXS.oth_receipt_quantity%TYPE,
  P_OTH_RECEIPT_ID                IN  JAI_CMN_RG_23AC_I_TRXS.OTH_RECEIPT_ID_REF%TYPE,
  P_OTH_RECEIPT_DATE              IN  JAI_CMN_RG_23AC_I_TRXS.oth_receipt_date%TYPE,
  P_REGISTER_TYPE                 IN  JAI_CMN_RG_23AC_I_TRXS.register_type%TYPE,
  P_IDENTIFICATION_NO             IN  JAI_CMN_RG_23AC_I_TRXS.identification_no%TYPE,
  P_IDENTIFICATION_MARK           IN  JAI_CMN_RG_23AC_I_TRXS.identification_mark%TYPE,
  P_BRAND_NAME                    IN  JAI_CMN_RG_23AC_I_TRXS.brand_name%TYPE,
  P_DATE_OF_VERIFICATION          IN  JAI_CMN_RG_23AC_I_TRXS.date_of_verification%TYPE,
  P_DATE_OF_INSTALLATION          IN  JAI_CMN_RG_23AC_I_TRXS.date_of_installation%TYPE,
  P_DATE_OF_COMMISSION            IN  JAI_CMN_RG_23AC_I_TRXS.date_of_commission%TYPE,
  P_REGISER_ID_PART_II            IN  JAI_CMN_RG_23AC_I_TRXS.REGISTER_ID_PART_II%TYPE,
  P_PLACE_OF_INSTALL              IN  JAI_CMN_RG_23AC_I_TRXS.place_of_install%TYPE,
  P_REMARKS                       IN  JAI_CMN_RG_23AC_I_TRXS.remarks%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_23AC_I_TRXS.location_id%TYPE,
  P_TRANSACTION_UOM_CODE          IN  JAI_CMN_RG_23AC_I_TRXS.transaction_uom_code%TYPE,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_23AC_I_TRXS.transaction_date%TYPE,
  P_BASIC_ED                      IN  JAI_CMN_RG_23AC_I_TRXS.basic_ed%TYPE,
  P_ADDITIONAL_ED                 IN  JAI_CMN_RG_23AC_I_TRXS.additional_ed%TYPE,
  P_ADDITIONAL_CVD                IN  JAI_CMN_RG_23AC_I_TRXS.additional_cvd%TYPE DEFAULT NULL, /* Bug 5228046 added by sacsethi   */
  P_OTHER_ED                      IN  JAI_CMN_RG_23AC_I_TRXS.other_ed%TYPE,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_23AC_I_TRXS.charge_account_id%TYPE,
  P_TRANSACTION_SOURCE            IN  VARCHAR2,
  P_CALLED_FROM                   IN  VARCHAR2,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
) IS

  ld_creation_date          DATE;
  ln_created_by             NUMBER(15);
  ld_last_update_date       DATE;
  ln_last_updated_by        NUMBER(15);
  ln_last_update_login      NUMBER(15);

  lv_last_register_id       NUMBER;
  ln_slno                   NUMBER(10) := 0;
  ln_transaction_id         NUMBER(10);
  lv_transaction_type       JAI_RCV_TRANSACTIONS.transaction_type%TYPE;
  ln_quantity               NUMBER;
  ln_opening_balance_qty    NUMBER;
  ln_closing_balance_qty    NUMBER;
  lv_primary_uom_code       MTL_SYSTEM_ITEMS.primary_uom_code%TYPE;
  vTransToPrimaryUOMConv    NUMBER;

  ln_fin_year               NUMBER(4);
  lv_range                  JAI_CMN_RG_23AC_I_TRXS.range_no%TYPE;
  lv_division               JAI_CMN_RG_23AC_I_TRXS.division_no%TYPE;
  lv_master_flag            JAI_CMN_RG_23AC_I_TRXS.master_flag%TYPE;

  r_last_record             c_get_last_record%ROWTYPE;

  ln_record_exist_cnt       NUMBER(4);
  lv_statement_id           VARCHAR2(5);

BEGIN

/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_cmn_rg_23ac_i_trxs_pkg.sql
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     16/07/2002   Vijay Shankar for Bug# 3496408, Version:115.0
                    Table handler Package for JAI_CMN_RG_23AC_I_TRXS table

2.    08/06/2005   Version 116.1
                   Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		               as required for CASE COMPLAINCE.

3.    14/07/2005   Brathod for bug#4485801, Version 117.1
                   Inventory Convergence Uptake

4.    19/05/2005   Ramananda for Bug#4516650, Version 120.2
                   Problem
                   -------
                   The problem is coming in case of customers, migrated from 11.0.3 to 11.5.
                   At the time of claiming the cenvat for receipts of RMIN Items, which are migrated.
                   The system is giving error message - "RG23 Part I Entry was already made for the transaction"

                   Fix
                   ---
                   As in 11.0.3, entry in the RG23_I is made at the time of Receipt Creation.
                   So for Migrated receipts, entry is already present in RG23_I.
                   So Commented the Call to get_trxn_entry_cnt in jai_cmn_rg_23ac_i_trxs_pkg.insert_row

5.    31/10/2006  SACSETHI for bug 5228046, File version 120.3
                  Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
                  This bug has datamodel and spec changes.

6     06/04/2010  Bug 9550254
 	              The opening balance for the RG23 Part I has been derived from the previous
                  financial year closing balance, if no entries found for the current year.
7.   27-apr-2010 bug#9466919
                 issue :quantity in rg registers are not in sync with the inventory.
                 fix:
                 added the rounding precision of 5 to the quantity fields while inserting.
----------------------------------------------------------------------------------------------------------------------------*/

  ld_creation_date      := SYSDATE;
  ln_created_by         := FND_GLOBAL.user_id;
  ld_last_update_date   := SYSDATE;
  ln_last_updated_by    := ln_created_by;
  ln_last_update_login  := FND_GLOBAL.login_id;

  lv_statement_id := '1';
  ln_fin_year           := jai_general_pkg.get_fin_year(p_organization_id);
  lv_statement_id := '2';
  lv_primary_uom_code   := jai_general_pkg.get_primary_uom_code(p_organization_id, p_inventory_item_id);
  lv_statement_id := '3';
  lv_master_flag        := jai_general_pkg.get_orgn_master_flag(p_organization_id, p_location_id);

  lv_transaction_type   := p_transaction_type;
  lv_statement_id := '4';
  get_trxn_type_and_id(lv_transaction_type, p_transaction_source, ln_transaction_id);

  lv_statement_id := '5';

  /*ln_record_exist_cnt := get_trxn_entry_cnt(p_register_type, p_organization_id, p_location_id,
                                            p_inventory_item_id, p_receipt_id, ln_transaction_id);
  IF ln_record_exist_cnt > 0 THEN
    p_process_status  := 'X';
    p_process_message := 'RG23 Part I Entry was already made for the transaction';
    GOTO end_of_processing;
  END IF; */
	--commented by Ramananda for Bug#4516650

  lv_statement_id := '6';
  jai_general_pkg.get_range_division(p_vendor_id, p_vendor_site_id, lv_range, lv_division);

  lv_statement_id := '7';
  vTransToPrimaryUOMConv := jai_general_pkg.trxn_to_primary_conv_rate
                              (p_transaction_uom_code, lv_primary_uom_code, p_inventory_item_id);

  ln_quantity := nvl(p_quantity_received, 0) * vTransToPrimaryUOMConv;

  lv_statement_id := '8';
  lv_last_register_id := jai_general_pkg.get_last_record_of_rg
                    ('RG23'||p_register_type||'_1', p_organization_id, p_location_id, p_inventory_item_id, ln_fin_year);

  lv_statement_id := '9';
  /*Bug 9550254 - Start*/
  /*
  OPEN c_get_last_record(lv_last_register_id);
  FETCH c_get_last_record INTO r_last_record;
  CLOSE c_get_last_record;
  */
  ln_opening_balance_qty := jai_om_rg_pkg.ja_in_rg23i_balance(p_organization_id,p_location_id,p_inventory_item_id,
                                                              ln_fin_year,p_register_type,ln_slno);
  ln_slno := nvl(ln_slno, 0) + 1;

  /*Commenting the below statements as they are calculated above using jai_om_rg_pkg.ja_in_rg23i_balance*/
  -- ln_slno := nvl(r_last_record.slno, 0) + 1;
  -- ln_opening_balance_qty := nvl(r_last_record.closing_balance_qty, 0);
  /*Bug 9550254 - End*/
  ln_closing_balance_qty := ln_opening_balance_qty + ln_quantity;

  lv_statement_id := '10';
  INSERT INTO JAI_CMN_RG_23AC_I_TRXS(
    REGISTER_ID,
    FIN_YEAR,
    SLNO,
    TRANSACTION_SOURCE_NUM,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    QUANTITY_RECEIVED,
    RECEIPT_REF,
    TRANSACTION_TYPE,
    RECEIPT_DATE,
    RANGE_NO,
    DIVISION_NO,
    PO_HEADER_ID,
    PO_HEADER_DATE,
    PO_LINE_ID,
    PO_LINE_LOCATION_ID,
    VENDOR_ID,
    VENDOR_SITE_ID,
    CUSTOMER_ID,
    CUSTOMER_SITE_ID,
    GOODS_ISSUE_ID_REF,
    GOODS_ISSUE_DATE,
    GOODS_ISSUE_QUANTITY,
    SALES_INVOICE_NO,
    SALES_INVOICE_DATE,
    SALES_INVOICE_QUANTITY,
    EXCISE_INVOICE_NO,
    EXCISE_INVOICE_DATE,
    OTH_RECEIPT_QUANTITY,
    OTH_RECEIPT_ID_REF,
    OTH_RECEIPT_DATE,
    REGISTER_TYPE,
    IDENTIFICATION_NO,
    IDENTIFICATION_MARK,
    BRAND_NAME,
    DATE_OF_VERIFICATION,
    DATE_OF_INSTALLATION,
    DATE_OF_COMMISSION,
    REGISTER_ID_PART_II,
    PLACE_OF_INSTALL,
    REMARKS,
    LOCATION_ID,
    PRIMARY_UOM_CODE,
    TRANSACTION_UOM_CODE,
    TRANSACTION_DATE,
    BASIC_ED,
    ADDITIONAL_ED,
    ADDITIONAL_CVD, -- Bug 5228046 added by sacsethi
    OTHER_ED,
    OPENING_BALANCE_QTY,
    CLOSING_BALANCE_QTY,
    CHARGE_ACCOUNT_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    POSTED_FLAG,
    MASTER_FLAG
  ) VALUES (
    JAI_CMN_RG_23AC_I_TRXS_S.nextval,
    ln_fin_year,
    ln_slno,
    ln_transaction_id,
    P_INVENTORY_ITEM_ID,
    P_ORGANIZATION_ID,
   round( P_QUANTITY_RECEIVED,5),
    P_RECEIPT_ID,
    lv_transaction_type,
    P_RECEIPT_DATE,
    lv_range,
    lv_division,
    P_PO_HEADER_ID,
    P_PO_HEADER_DATE,
    P_PO_LINE_ID,
    P_PO_LINE_LOCATION_ID,
    P_VENDOR_ID,
    P_VENDOR_SITE_ID,
    P_CUSTOMER_ID,
    P_CUSTOMER_SITE_ID,
    P_GOODS_ISSUE_ID,
    P_GOODS_ISSUE_DATE,
    round(  P_GOODS_ISSUE_QUANTITY,5),
    P_SALES_INVOICE_ID,
    P_SALES_INVOICE_DATE,
    round(  P_SALES_INVOICE_QUANTITY,5),
    P_EXCISE_INVOICE_ID,
    P_EXCISE_INVOICE_DATE,
   round( P_OTH_RECEIPT_QUANTITY,5),
    P_OTH_RECEIPT_ID,
    P_OTH_RECEIPT_DATE,
    P_REGISTER_TYPE,
    P_IDENTIFICATION_NO,
    P_IDENTIFICATION_MARK,
    P_BRAND_NAME,
    P_DATE_OF_VERIFICATION,
    P_DATE_OF_INSTALLATION,
    P_DATE_OF_COMMISSION,
    P_REGISER_ID_PART_II,
    P_PLACE_OF_INSTALL,
    P_REMARKS,
    P_LOCATION_ID,
    lv_primary_uom_code,
    P_TRANSACTION_UOM_CODE,
    P_TRANSACTION_DATE,
    P_BASIC_ED,
    P_ADDITIONAL_ED,
    P_ADDITIONAL_CVD, -- Bug 5228046 added by sacsethi
    P_OTHER_ED,
    round(  ln_opening_balance_qty,5),
    round(  ln_closing_balance_qty,5),
    P_CHARGE_ACCOUNT_ID,
    ld_creation_date,
    ln_created_by,
    ld_last_update_date,
    ln_last_updated_by,
    ln_last_update_login,
    'N',
    lv_master_flag

  ) RETURNING register_id INTO P_REGISTER_ID;

  <<end_of_processing>>

  NULL;
  --IF p_process_message IS NOT NULL THEN
  --  p_process_status  := 'E';
  --  RETURN;
  --END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_process_status := 'E';
    p_process_message := 'RG23_PART_I_PKG.insert_row->'||SQLERRM||', StmtId->'||lv_statement_id;
    FND_FILE.put_line( FND_FILE.log, p_process_message);

END insert_row;

PROCEDURE update_row(

  P_REGISTER_ID                   IN  JAI_CMN_RG_23AC_I_TRXS.register_id%TYPE                               DEFAULT NULL,
  P_QUANTITY_RECEIVED             IN  JAI_CMN_RG_23AC_I_TRXS.quantity_received%TYPE                         DEFAULT NULL,
  P_RECEIPT_ID                    IN  JAI_CMN_RG_23AC_I_TRXS.RECEIPT_REF%TYPE                               DEFAULT NULL,
  P_TRANSACTION_TYPE              IN  JAI_CMN_RG_23AC_I_TRXS.transaction_type%TYPE                          DEFAULT NULL,
  P_RECEIPT_DATE                  IN  JAI_CMN_RG_23AC_I_TRXS.receipt_date%TYPE                              DEFAULT NULL,
  P_RANGE_NO                      IN  JAI_CMN_RG_23AC_I_TRXS.range_no%TYPE                                  DEFAULT NULL,
  P_DIVISION_NO                   IN  JAI_CMN_RG_23AC_I_TRXS.division_no%TYPE                               DEFAULT NULL,
  P_PO_HEADER_ID                  IN  JAI_CMN_RG_23AC_I_TRXS.po_header_id%TYPE                              DEFAULT NULL,
  P_PO_HEADER_DATE                IN  JAI_CMN_RG_23AC_I_TRXS.po_header_date%TYPE                            DEFAULT NULL,
  P_PO_LINE_ID                    IN  JAI_CMN_RG_23AC_I_TRXS.po_line_id%TYPE                                DEFAULT NULL,
  P_PO_LINE_LOCATION_ID           IN  JAI_CMN_RG_23AC_I_TRXS.po_line_location_id%TYPE                       DEFAULT NULL,
  P_VENDOR_ID                     IN  JAI_CMN_RG_23AC_I_TRXS.vendor_id%TYPE                                 DEFAULT NULL,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_23AC_I_TRXS.vendor_site_id%TYPE                            DEFAULT NULL,
  P_CUSTOMER_ID                   IN  JAI_CMN_RG_23AC_I_TRXS.customer_id%TYPE                               DEFAULT NULL,
  P_CUSTOMER_SITE_ID              IN  JAI_CMN_RG_23AC_I_TRXS.customer_site_id%TYPE                          DEFAULT NULL,
  P_GOODS_ISSUE_ID                IN  JAI_CMN_RG_23AC_I_TRXS.GOODS_ISSUE_ID_REF%TYPE                        DEFAULT NULL,
  P_GOODS_ISSUE_DATE              IN  JAI_CMN_RG_23AC_I_TRXS.goods_issue_date%TYPE                          DEFAULT NULL,
  P_GOODS_ISSUE_QUANTITY          IN  JAI_CMN_RG_23AC_I_TRXS.goods_issue_quantity%TYPE                      DEFAULT NULL,
  P_SALES_INVOICE_ID              IN  JAI_CMN_RG_23AC_I_TRXS.SALES_INVOICE_NO%TYPE                          DEFAULT NULL,
  P_SALES_INVOICE_DATE            IN  JAI_CMN_RG_23AC_I_TRXS.sales_invoice_date%TYPE                        DEFAULT NULL,
  P_SALES_INVOICE_QUANTITY        IN  JAI_CMN_RG_23AC_I_TRXS.sales_invoice_quantity%TYPE                    DEFAULT NULL,
  P_EXCISE_INVOICE_ID             IN  JAI_CMN_RG_23AC_I_TRXS.EXCISE_INVOICE_NO%TYPE                         DEFAULT NULL,
  P_EXCISE_INVOICE_DATE           IN  JAI_CMN_RG_23AC_I_TRXS.excise_invoice_date%TYPE                       DEFAULT NULL,
  P_OTH_RECEIPT_QUANTITY          IN  JAI_CMN_RG_23AC_I_TRXS.oth_receipt_quantity%TYPE                      DEFAULT NULL,
  P_OTH_RECEIPT_ID                IN  JAI_CMN_RG_23AC_I_TRXS.OTH_RECEIPT_ID_REF%TYPE                        DEFAULT NULL,
  P_OTH_RECEIPT_DATE              IN  JAI_CMN_RG_23AC_I_TRXS.oth_receipt_date%TYPE                          DEFAULT NULL,
  P_REGISTER_TYPE                 IN  JAI_CMN_RG_23AC_I_TRXS.register_type%TYPE                             DEFAULT NULL,
  P_IDENTIFICATION_NO             IN  JAI_CMN_RG_23AC_I_TRXS.identification_no%TYPE                         DEFAULT NULL,
  P_IDENTIFICATION_MARK           IN  JAI_CMN_RG_23AC_I_TRXS.identification_mark%TYPE                       DEFAULT NULL,
  P_BRAND_NAME                    IN  JAI_CMN_RG_23AC_I_TRXS.brand_name%TYPE                                DEFAULT NULL,
  P_DATE_OF_VERIFICATION          IN  JAI_CMN_RG_23AC_I_TRXS.date_of_verification%TYPE                      DEFAULT NULL,
  P_DATE_OF_INSTALLATION          IN  JAI_CMN_RG_23AC_I_TRXS.date_of_installation%TYPE                      DEFAULT NULL,
  P_DATE_OF_COMMISSION            IN  JAI_CMN_RG_23AC_I_TRXS.date_of_commission%TYPE                        DEFAULT NULL,
  P_REGISER_ID_PART_II            IN  JAI_CMN_RG_23AC_I_TRXS.REGISTER_ID_PART_II%TYPE                       DEFAULT NULL,
  P_PLACE_OF_INSTALL              IN  JAI_CMN_RG_23AC_I_TRXS.place_of_install%TYPE                          DEFAULT NULL,
  P_REMARKS                       IN  JAI_CMN_RG_23AC_I_TRXS.remarks%TYPE                                   DEFAULT NULL,
  P_BASIC_ED                      IN  JAI_CMN_RG_23AC_I_TRXS.basic_ed%TYPE                                  DEFAULT NULL,
  P_ADDITIONAL_ED                 IN  JAI_CMN_RG_23AC_I_TRXS.additional_ed%TYPE                             DEFAULT NULL,
  P_ADDITIONAL_CVD                IN  JAI_CMN_RG_23AC_I_TRXS.additional_cvd%TYPE                                 DEFAULT NULL, -- Bug 5228046 added by sacsethi
  P_OTHER_ED                      IN  JAI_CMN_RG_23AC_I_TRXS.other_ed%TYPE                                  DEFAULT NULL,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_23AC_I_TRXS.charge_account_id%TYPE                         DEFAULT NULL,
  P_POSTED_FLAG                   IN  JAI_CMN_RG_23AC_I_TRXS.posted_flag%TYPE                               DEFAULT NULL,
  P_MASTER_FLAG                   IN  JAI_CMN_RG_23AC_I_TRXS.master_flag%TYPE                               DEFAULT NULL,
  P_TRANSACTION_SOURCE            IN  VARCHAR2,
  P_CALLED_FROM                   IN  VARCHAR2,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
) IS

  ld_last_update_date       DATE;
  ln_last_updated_by        NUMBER(15);
  ln_last_update_login      NUMBER(15);

  ln_slno                   NUMBER(10) := 0;
  ln_opening_balance_qty    NUMBER;
  ln_closing_balance_qty    NUMBER;

BEGIN

  ld_last_update_date   := SYSDATE;
  ln_last_updated_by    := FND_GLOBAL.user_id;
  ln_last_update_login  := FND_GLOBAL.login_id;

  UPDATE JAI_CMN_RG_23AC_I_TRXS SET
    QUANTITY_RECEIVED             = nvl(round(P_QUANTITY_RECEIVED,5), QUANTITY_RECEIVED),
    RECEIPT_REF                    = nvl(P_RECEIPT_ID, RECEIPT_REF),
    TRANSACTION_TYPE              = nvl(P_TRANSACTION_TYPE, TRANSACTION_TYPE),
    RECEIPT_DATE                  = nvl(P_RECEIPT_DATE, RECEIPT_DATE),
    RANGE_NO                      = nvl(P_RANGE_NO, RANGE_NO),
    DIVISION_NO                   = nvl(P_DIVISION_NO, DIVISION_NO),
    PO_HEADER_ID                  = nvl(P_PO_HEADER_ID, PO_HEADER_ID),
    PO_HEADER_DATE                = nvl(P_PO_HEADER_DATE, PO_HEADER_DATE),
    PO_LINE_ID                    = nvl(P_PO_LINE_ID, PO_LINE_ID),
    PO_LINE_LOCATION_ID           = nvl(P_PO_LINE_LOCATION_ID, PO_LINE_LOCATION_ID),
    VENDOR_ID                     = nvl(P_VENDOR_ID, VENDOR_ID),
    VENDOR_SITE_ID                = nvl(P_VENDOR_SITE_ID, VENDOR_SITE_ID),
    CUSTOMER_ID                   = nvl(P_CUSTOMER_ID, CUSTOMER_ID),
    CUSTOMER_SITE_ID              = nvl(P_CUSTOMER_SITE_ID, CUSTOMER_SITE_ID),
    GOODS_ISSUE_ID_REF                = nvl(P_GOODS_ISSUE_ID, GOODS_ISSUE_ID_REF),
    GOODS_ISSUE_DATE              = nvl(P_GOODS_ISSUE_DATE, GOODS_ISSUE_DATE),
    GOODS_ISSUE_QUANTITY          = nvl(round(P_GOODS_ISSUE_QUANTITY,5), GOODS_ISSUE_QUANTITY),
    SALES_INVOICE_NO              = nvl(P_SALES_INVOICE_ID, SALES_INVOICE_NO),
    SALES_INVOICE_DATE            = nvl(P_SALES_INVOICE_DATE, SALES_INVOICE_DATE),
    SALES_INVOICE_QUANTITY        = nvl(round(P_SALES_INVOICE_QUANTITY,5), SALES_INVOICE_QUANTITY),
    EXCISE_INVOICE_NO             = nvl(P_EXCISE_INVOICE_ID, EXCISE_INVOICE_NO),
    EXCISE_INVOICE_DATE           = nvl(P_EXCISE_INVOICE_DATE, EXCISE_INVOICE_DATE),
    OTH_RECEIPT_QUANTITY          = nvl(round(P_OTH_RECEIPT_QUANTITY,5), OTH_RECEIPT_QUANTITY),
    OTH_RECEIPT_ID_REF                = nvl(P_OTH_RECEIPT_ID, OTH_RECEIPT_ID_REF),
    OTH_RECEIPT_DATE              = nvl(P_OTH_RECEIPT_DATE, OTH_RECEIPT_DATE),
    REGISTER_TYPE                 = nvl(P_REGISTER_TYPE, REGISTER_TYPE),
    IDENTIFICATION_NO             = nvl(P_IDENTIFICATION_NO, IDENTIFICATION_NO),
    IDENTIFICATION_MARK           = nvl(P_IDENTIFICATION_MARK, IDENTIFICATION_MARK),
    BRAND_NAME                    = nvl(P_BRAND_NAME, BRAND_NAME),
    DATE_OF_VERIFICATION          = nvl(P_DATE_OF_VERIFICATION, DATE_OF_VERIFICATION),
    DATE_OF_INSTALLATION          = nvl(P_DATE_OF_INSTALLATION, DATE_OF_INSTALLATION),
    DATE_OF_COMMISSION            = nvl(P_DATE_OF_COMMISSION, DATE_OF_COMMISSION),
    REGISTER_ID_PART_II            = nvl(P_REGISER_ID_PART_II, REGISTER_ID_PART_II),
    PLACE_OF_INSTALL              = nvl(P_PLACE_OF_INSTALL, PLACE_OF_INSTALL),
    REMARKS                       = nvl(P_REMARKS, REMARKS),
    BASIC_ED                      = nvl(P_BASIC_ED, BASIC_ED),
    ADDITIONAL_ED                 = nvl(P_ADDITIONAL_ED, ADDITIONAL_ED),
    ADDITIONAL_CVD                = nvl(P_ADDITIONAL_CVD, ADDITIONAL_CVD), --Bug 5228046 added by sacsethi
    OTHER_ED                      = nvl(P_OTHER_ED, OTHER_ED),
    OPENING_BALANCE_QTY           = round(ln_opening_balance_qty,5),
    CLOSING_BALANCE_QTY           = round(ln_closing_balance_qty,5),
    CHARGE_ACCOUNT_ID             = nvl(P_CHARGE_ACCOUNT_ID, CHARGE_ACCOUNT_ID),
    LAST_UPDATE_DATE              = ld_last_update_date,
    LAST_UPDATED_BY               = ln_last_updated_by,
    LAST_UPDATE_LOGIN             = ln_last_update_login,
    POSTED_FLAG                   = nvl(P_POSTED_FLAG, POSTED_FLAG),
    MASTER_FLAG                   = nvl(P_MASTER_FLAG, MASTER_FLAG)
  WHERE register_id = p_register_id;

END update_row;

PROCEDURE update_payment_details(
  p_register_id         IN  NUMBER,
  p_register_id_part_ii IN  NUMBER,
  p_charge_account_id   IN  NUMBER
) IS

BEGIN

  UPDATE JAI_CMN_RG_23AC_I_TRXS
  SET
    REGISTER_ID_PART_II  = p_register_id_part_ii,
    charge_account_id   = p_charge_account_id,
    last_update_date    = SYSDATE
  WHERE register_id = p_register_id;

END update_payment_details;

FUNCTION get_trxn_entry_cnt(
  p_register_type     IN VARCHAR2,
  p_organization_id   IN NUMBER,
  p_location_id       IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_receipt_id        IN VARCHAR2,
  p_transaction_id    IN NUMBER
) RETURN NUMBER IS

  ln_record_exist_cnt       NUMBER(4);
  CURSOR c_record_exist IS
    SELECT count(1)
    FROM JAI_CMN_RG_23AC_I_TRXS
    WHERE organization_id = p_organization_id
    AND location_id = p_location_id
    AND inventory_item_id = p_inventory_item_id
    AND register_type = p_register_type
    AND receipt_ref = p_receipt_id
    AND TRANSACTION_SOURCE_NUM = p_transaction_id;

BEGIN

  OPEN c_record_exist;
  FETCH c_record_exist INTO ln_record_exist_cnt;
  CLOSE c_record_exist;

  IF ln_record_exist_cnt > 0 THEN
    FND_FILE.put_line( FND_FILE.log, '23Part1 Duplicate Chk:'||ln_record_exist_cnt
      ||', PARAMS: Orgn>'||p_organization_id||', Loc>'||p_location_id
      ||', Item>'||p_inventory_item_id||', Reg>'||p_register_type
      ||', TrxId>'||p_receipt_id||', type>'||p_transaction_id
    );
  END IF;

  RETURN ln_record_exist_cnt;

END get_trxn_entry_cnt;

----------------------- Get transaction id -------------------------------------------
PROCEDURE get_trxn_type_and_id(
  p_transaction_type    IN OUT NOCOPY VARCHAR2,
  p_transaction_source  IN      VARCHAR2,
  p_transaction_id OUT NOCOPY NUMBER
) IS

BEGIN

  IF p_transaction_type = 'RECEIVE' AND p_transaction_source = 'RMA' THEN
    p_transaction_id := 18;
    p_transaction_type := 'CR';
  ELSIF p_transaction_type = 'RECEIVE' THEN
    p_transaction_id := 18;
    p_transaction_type := 'R';
  ELSIF p_transaction_type = 'RETURN TO RECEIVING' THEN
    p_transaction_id := 18;
    p_transaction_type := 'R';
  ELSIF p_transaction_type = 'DELIVER' THEN
    p_transaction_id := 18;
    p_transaction_type := 'R';
  ELSIF p_transaction_type = 'RETURN TO VENDOR' THEN
    p_transaction_id := 18;
    p_transaction_type := 'RTV';
  -- Added by Brathod, for Inv.Convergence
  ELSIF p_transaction_source = 'OPM_OSP' THEN
    IF p_transaction_type = 'R' THEN
      p_transaction_id := 202;
    ELSIF p_transaction_type = 'I' THEN
      p_transaction_id := 201;
    END IF;
  ELSE
    p_transaction_id := 20;
    p_transaction_type := 'MISC';
  END IF;

END get_trxn_type_and_id;

END jai_cmn_rg_23ac_i_trxs_pkg;

/
