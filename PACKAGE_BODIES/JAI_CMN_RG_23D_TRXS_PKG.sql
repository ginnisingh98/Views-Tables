--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RG_23D_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RG_23D_TRXS_PKG" AS
/* $Header: jai_cmn_rg_23d.plb 120.3.12010000.2 2009/06/16 14:01:43 nprashar ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_cmn_rg_23d -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

01-NOV-2006  version 120.2  SACSETHI for bug 5228046
	             Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
		     This bug has datamodel and spec changes.

*/

PROCEDURE insert_row(
    P_REGISTER_ID OUT NOCOPY JAI_CMN_RG_23D_TRXS.register_id%TYPE,
    P_ORGANIZATION_ID               IN  JAI_CMN_RG_23D_TRXS.organization_id%TYPE,
    P_LOCATION_ID                   IN  JAI_CMN_RG_23D_TRXS.location_id%TYPE,
    P_TRANSACTION_TYPE              IN  JAI_CMN_RG_23D_TRXS.transaction_type%TYPE,
    P_RECEIPT_ID                    IN  JAI_CMN_RG_23D_TRXS.RECEIPT_REF%TYPE,
    P_QUANTITY_RECEIVED             IN  JAI_CMN_RG_23D_TRXS.quantity_received%TYPE,
    P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_23D_TRXS.inventory_item_id%TYPE,
    P_SUBINVENTORY                  IN  JAI_CMN_RG_23D_TRXS.subinventory%TYPE,
    P_REFERENCE_LINE_ID             IN  JAI_CMN_RG_23D_TRXS.reference_line_id%TYPE,
    P_TRANSACTION_UOM_CODE          IN  JAI_CMN_RG_23D_TRXS.transaction_uom_code%TYPE,
    P_CUSTOMER_ID                   IN  JAI_CMN_RG_23D_TRXS.customer_id%TYPE,
    P_BILL_TO_SITE_ID               IN  JAI_CMN_RG_23D_TRXS.bill_to_site_id%TYPE,
    P_SHIP_TO_SITE_ID               IN  JAI_CMN_RG_23D_TRXS.ship_to_site_id%TYPE,
    P_QUANTITY_ISSUED               IN  JAI_CMN_RG_23D_TRXS.quantity_issued%TYPE,
    P_REGISTER_CODE                 IN  JAI_CMN_RG_23D_TRXS.register_code%TYPE,
    P_RELEASED_DATE                 IN  JAI_CMN_RG_23D_TRXS.released_date%TYPE,
    P_COMM_INVOICE_NO               IN  JAI_CMN_RG_23D_TRXS.comm_invoice_no%TYPE,
    P_COMM_INVOICE_DATE             IN  JAI_CMN_RG_23D_TRXS.comm_invoice_date%TYPE,
    P_RECEIPT_BOE_NUM               IN  JAI_CMN_RG_23D_TRXS.receipt_boe_num%TYPE,
    P_OTH_RECEIPT_ID                IN  JAI_CMN_RG_23D_TRXS.OTH_RECEIPT_ID_REF%TYPE,
    P_OTH_RECEIPT_DATE              IN  JAI_CMN_RG_23D_TRXS.oth_receipt_date%TYPE,
    P_OTH_RECEIPT_QUANTITY          IN  JAI_CMN_RG_23D_TRXS.oth_receipt_quantity%TYPE,
    P_REMARKS                       IN  JAI_CMN_RG_23D_TRXS.remarks%TYPE,
    P_QTY_TO_ADJUST                 IN  JAI_CMN_RG_23D_TRXS.qty_to_adjust%TYPE,
    P_RATE_PER_UNIT                 IN  JAI_CMN_RG_23D_TRXS.rate_per_unit%TYPE,
    P_EXCISE_DUTY_RATE              IN  JAI_CMN_RG_23D_TRXS.excise_duty_rate%TYPE,
    P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_23D_TRXS.charge_account_id%TYPE,
    P_DUTY_AMOUNT                   IN  JAI_CMN_RG_23D_TRXS.duty_amount%TYPE,
    P_RECEIPT_DATE                  IN  JAI_CMN_RG_23D_TRXS.receipt_date%TYPE,
    P_GOODS_ISSUE_ID                IN  JAI_CMN_RG_23D_TRXS.goods_issue_id%TYPE,
    P_GOODS_ISSUE_DATE              IN  JAI_CMN_RG_23D_TRXS.goods_issue_date%TYPE,
    P_GOODS_ISSUE_QUANTITY          IN  JAI_CMN_RG_23D_TRXS.goods_issue_quantity%TYPE,
    P_TRANSACTION_DATE              IN  JAI_CMN_RG_23D_TRXS.transaction_date%TYPE,
    P_BASIC_ED                      IN  JAI_CMN_RG_23D_TRXS.basic_ed%TYPE,
    P_ADDITIONAL_ED                 IN  JAI_CMN_RG_23D_TRXS.additional_ed%TYPE,
    P_ADDITIONAL_CVD                IN  JAI_CMN_RG_23D_TRXS.additional_cvd%TYPE DEFAULT NULL, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
    P_OTHER_ED                      IN  JAI_CMN_RG_23D_TRXS.other_ed%TYPE,
    P_CVD                           IN  JAI_CMN_RG_23D_TRXS.cvd%TYPE,
    P_VENDOR_ID                     IN  JAI_CMN_RG_23D_TRXS.vendor_id%TYPE,
    P_VENDOR_SITE_ID                IN  JAI_CMN_RG_23D_TRXS.vendor_site_id%TYPE,
    P_RECEIPT_NUM                   IN  JAI_CMN_RG_23D_TRXS.receipt_num%TYPE,
    P_ATTRIBUTE1                    IN  JAI_CMN_RG_23D_TRXS.attribute1%TYPE,
    P_ATTRIBUTE2                    IN  JAI_CMN_RG_23D_TRXS.attribute2%TYPE,
    P_ATTRIBUTE3                    IN  JAI_CMN_RG_23D_TRXS.attribute3%TYPE,
    P_ATTRIBUTE4                    IN  JAI_CMN_RG_23D_TRXS.attribute4%TYPE,
    P_ATTRIBUTE5                    IN  JAI_CMN_RG_23D_TRXS.attribute5%TYPE,
    P_CONSIGNEE                     IN  JAI_CMN_RG_23D_TRXS.consignee%TYPE,
    P_MANUFACTURER_NAME             IN  JAI_CMN_RG_23D_TRXS.manufacturer_name%TYPE,
    P_MANUFACTURER_ADDRESS          IN  JAI_CMN_RG_23D_TRXS.manufacturer_address%TYPE,
    P_MANUFACTURER_RATE_AMT_PER_UN  IN  JAI_CMN_RG_23D_TRXS.manufacturer_rate_amt_per_unit%TYPE,
    P_QTY_RECEIVED_FROM_MANUFACTUR  IN  JAI_CMN_RG_23D_TRXS.qty_received_from_manufacturer%TYPE,
    P_TOT_AMT_PAID_TO_MANUFACTURER  IN  JAI_CMN_RG_23D_TRXS.tot_amt_paid_to_manufacturer%TYPE,
    -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
    P_OTHER_TAX_CREDIT              IN  JAI_CMN_RG_23D_TRXS.other_tax_credit%TYPE,
    P_OTHER_TAX_DEBIT               IN  JAI_CMN_RG_23D_TRXS.other_tax_debit%TYPE,
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

  ln_last_register_id       NUMBER;
  ln_slno                   NUMBER(10) := 0;
  ln_fin_year               JAI_CMN_RG_23D_TRXS.fin_year%TYPE;
  ln_transaction_id         NUMBER(10);
  lv_transaction_type       JAI_RCV_TRANSACTIONS.transaction_type%TYPE;

  ln_quantity               NUMBER;
  ln_qty_to_adjust          NUMBER;
  ln_quantity_issued        NUMBER;

  ln_opening_balance_qty    NUMBER;
  ln_closing_balance_qty    NUMBER;
  lv_primary_uom_code       MTL_SYSTEM_ITEMS.primary_uom_code%TYPE;

  vTransToPrimaryUOMConv    NUMBER;

  r_last_record             c_get_last_record%ROWTYPE;

  ln_record_exist_cnt       NUMBER(4);

  lv_statement_id           VARCHAR2(5);

BEGIN

/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_cmn_rg_23d_trxs_pkg.sql
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     16/07/2004   Vijay Shankar for Bug# 3496408, Version:115.0
                    Table handler Package for JAI_CMN_RG_23D_TRXS table

2     03/01/2005   Vijay Shankar for Bug# 3940588, Version:115.1
                    Modified Insert and Update procedures to include p_other_tax_credit and p_other_tax_debit parameters for
                    Education Cess Enhancement

Dependancy:
-----------
IN60105D2 + 3496408
IN60106   + 3940588

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

  lv_transaction_type   := p_transaction_type;

  lv_statement_id := '3';
  get_trxn_type_and_id(lv_transaction_type, p_transaction_source, ln_transaction_id);

  lv_statement_id := '4';
  ln_record_exist_cnt := get_trxn_entry_cnt(p_organization_id, p_location_id, p_inventory_item_id,
                                            p_receipt_id, ln_transaction_id);
  IF ln_record_exist_cnt > 0 THEN
    p_process_status  := 'X';
    p_process_message := 'RG23D Entry was already made for the transaction';
    GOTO end_of_processing;
  END IF;

  lv_statement_id := '5';
  vTransToPrimaryUOMConv := jai_general_pkg.trxn_to_primary_conv_rate
                              (p_transaction_uom_code, lv_primary_uom_code, p_inventory_item_id);

  ln_quantity         := p_quantity_received * vTransToPrimaryUOMConv;
  ln_qty_to_adjust    := p_qty_to_adjust * vTransToPrimaryUOMConv;
  ln_quantity_issued  := p_quantity_issued * vTransToPrimaryUOMConv;

  lv_statement_id := '6';
  ln_last_register_id := jai_general_pkg.get_last_record_of_rg
                          ('RG23D', p_organization_id, p_location_id, p_inventory_item_id, ln_fin_year);

  lv_statement_id := '7';
  OPEN c_get_last_record(ln_last_register_id);
  FETCH c_get_last_record INTO r_last_record;
  CLOSE c_get_last_record;

  ln_slno := nvl(r_last_record.slno, 0) + 1;
  ln_opening_balance_qty := nvl(r_last_record.closing_balance_qty, 0);
  ln_closing_balance_qty := ln_opening_balance_qty + ln_quantity;

  lv_statement_id := '8';
  INSERT INTO JAI_CMN_RG_23D_TRXS(
    REGISTER_ID,
    ORGANIZATION_ID,
    LOCATION_ID,
    SLNO,
    FIN_YEAR,
    TRANSACTION_TYPE,
    RECEIPT_REF,
    QUANTITY_RECEIVED,
    INVENTORY_ITEM_ID,
    SUBINVENTORY,
    REFERENCE_LINE_ID,
    PRIMARY_UOM_CODE,
    TRANSACTION_UOM_CODE,
    CUSTOMER_ID,
    BILL_TO_SITE_ID,
    SHIP_TO_SITE_ID,
    QUANTITY_ISSUED,
    REGISTER_CODE,
    RELEASED_DATE,
    COMM_INVOICE_NO,
    COMM_INVOICE_DATE,
    RECEIPT_BOE_NUM,
    OTH_RECEIPT_ID_REF,
    OTH_RECEIPT_DATE,
    OTH_RECEIPT_QUANTITY,
    REMARKS,
    QTY_TO_ADJUST,
    RATE_PER_UNIT,
    EXCISE_DUTY_RATE,
    CHARGE_ACCOUNT_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    DUTY_AMOUNT,
    TRANSACTION_SOURCE_NUM,
    RECEIPT_DATE,
    GOODS_ISSUE_ID,
    GOODS_ISSUE_DATE,
    GOODS_ISSUE_QUANTITY,
    TRANSACTION_DATE,
    OPENING_BALANCE_QTY,
    CLOSING_BALANCE_QTY,
    BASIC_ED,
    ADDITIONAL_ED,
    ADDITIONAL_CVD,
    OTHER_ED,
    CVD,
    VENDOR_ID,
    VENDOR_SITE_ID,
    RECEIPT_NUM,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    CONSIGNEE,
    MANUFACTURER_NAME,
    MANUFACTURER_ADDRESS,
    MANUFACTURER_RATE_AMT_PER_UNIT,
    QTY_RECEIVED_FROM_MANUFACTURER,
    TOT_AMT_PAID_TO_MANUFACTURER,
    -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
    other_tax_credit,
    other_tax_debit
  ) VALUES (
    JAI_CMN_RG_23D_TRXS_S.nextval,
    P_ORGANIZATION_ID,
    P_LOCATION_ID,
    ln_slno,            --
    ln_fin_year,        --
    lv_transaction_type,    --
    P_RECEIPT_ID,
    ln_quantity,      -- P_QUANTITY_RECEIVED,
    P_INVENTORY_ITEM_ID,
    P_SUBINVENTORY,
    P_REFERENCE_LINE_ID,
    lv_primary_uom_code,      ---
    P_TRANSACTION_UOM_CODE,
    P_CUSTOMER_ID,
    P_BILL_TO_SITE_ID,
    P_SHIP_TO_SITE_ID,
    ln_quantity_issued,   -- P_QUANTITY_ISSUED,
    P_REGISTER_CODE,
    P_RELEASED_DATE,
    P_COMM_INVOICE_NO,
    P_COMM_INVOICE_DATE,
    P_RECEIPT_BOE_NUM,
    P_OTH_RECEIPT_ID,
    P_OTH_RECEIPT_DATE,
    P_OTH_RECEIPT_QUANTITY,
    P_REMARKS,
    ln_qty_to_adjust,     -- P_QTY_TO_ADJUST,
    P_RATE_PER_UNIT,
    P_EXCISE_DUTY_RATE,
    P_CHARGE_ACCOUNT_ID,
    ld_creation_date,     --
    ln_created_by,      --
    ld_last_update_date,    --
    ln_last_update_login,   --
    ln_last_updated_by,   ---
    P_DUTY_AMOUNT,
    ln_transaction_id,      -- P_TRANSACTION_ID,
    P_RECEIPT_DATE,
    P_GOODS_ISSUE_ID,
    P_GOODS_ISSUE_DATE,
    P_GOODS_ISSUE_QUANTITY,
    P_TRANSACTION_DATE,
    ln_opening_balance_qty,   --P_OPENING_BALANCE_QTY,
    ln_closing_balance_qty,     --P_CLOSING_BALANCE_QTY,
    P_BASIC_ED,
    P_ADDITIONAL_ED,
    P_ADDITIONAL_CVD,
    P_OTHER_ED,
    P_CVD,
    P_VENDOR_ID,
    P_VENDOR_SITE_ID,
    P_RECEIPT_NUM,
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_CONSIGNEE,
    P_MANUFACTURER_NAME,
    P_MANUFACTURER_ADDRESS,
    P_MANUFACTURER_RATE_AMT_PER_UN,
    P_QTY_RECEIVED_FROM_MANUFACTUR,
    P_TOT_AMT_PAID_TO_MANUFACTURER,
    -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
    p_other_tax_credit,
    p_other_tax_debit
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
    p_process_message := 'RG23_D_PKG.insert_row->'||SQLERRM||', StmtId->'||lv_statement_id;
    FND_FILE.put_line( FND_FILE.log, p_process_message);

END insert_row;

PROCEDURE update_row(

  P_REGISTER_ID                   IN  JAI_CMN_RG_23D_TRXS.register_id%TYPE                                    DEFAULT NULL,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_23D_TRXS.organization_id%TYPE                                DEFAULT NULL,
  P_LOCATION_ID                   IN  JAI_CMN_RG_23D_TRXS.location_id%TYPE                                    DEFAULT NULL,
  P_SLNO                          IN  JAI_CMN_RG_23D_TRXS.slno%TYPE                                           DEFAULT NULL,
  P_FIN_YEAR                      IN  JAI_CMN_RG_23D_TRXS.fin_year%TYPE                                       DEFAULT NULL,
  P_TRANSACTION_TYPE              IN  JAI_CMN_RG_23D_TRXS.transaction_type%TYPE                               DEFAULT NULL,
  P_RECEIPT_ID                    IN  JAI_CMN_RG_23D_TRXS.RECEIPT_REF%TYPE                                     DEFAULT NULL,
  P_QUANTITY_RECEIVED             IN  JAI_CMN_RG_23D_TRXS.quantity_received%TYPE                              DEFAULT NULL,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_23D_TRXS.inventory_item_id%TYPE                              DEFAULT NULL,
  P_SUBINVENTORY                  IN  JAI_CMN_RG_23D_TRXS.subinventory%TYPE                                   DEFAULT NULL,
  P_REFERENCE_LINE_ID             IN  JAI_CMN_RG_23D_TRXS.reference_line_id%TYPE                              DEFAULT NULL,
  P_PRIMARY_UOM_CODE              IN  JAI_CMN_RG_23D_TRXS.primary_uom_code%TYPE                               DEFAULT NULL,
  P_TRANSACTION_UOM_CODE          IN  JAI_CMN_RG_23D_TRXS.transaction_uom_code%TYPE                           DEFAULT NULL,
  P_CUSTOMER_ID                   IN  JAI_CMN_RG_23D_TRXS.customer_id%TYPE                                    DEFAULT NULL,
  P_BILL_TO_SITE_ID               IN  JAI_CMN_RG_23D_TRXS.bill_to_site_id%TYPE                                DEFAULT NULL,
  P_SHIP_TO_SITE_ID               IN  JAI_CMN_RG_23D_TRXS.ship_to_site_id%TYPE                                DEFAULT NULL,
  P_QUANTITY_ISSUED               IN  JAI_CMN_RG_23D_TRXS.quantity_issued%TYPE                                DEFAULT NULL,
  P_REGISTER_CODE                 IN  JAI_CMN_RG_23D_TRXS.register_code%TYPE                                  DEFAULT NULL,
  P_RELEASED_DATE                 IN  JAI_CMN_RG_23D_TRXS.released_date%TYPE                                  DEFAULT NULL,
  P_COMM_INVOICE_NO               IN  JAI_CMN_RG_23D_TRXS.comm_invoice_no%TYPE                                DEFAULT NULL,
  P_COMM_INVOICE_DATE             IN  JAI_CMN_RG_23D_TRXS.comm_invoice_date%TYPE                              DEFAULT NULL,
  P_RECEIPT_BOE_NUM               IN  JAI_CMN_RG_23D_TRXS.receipt_boe_num%TYPE                                DEFAULT NULL,
  P_OTH_RECEIPT_ID                IN  JAI_CMN_RG_23D_TRXS.OTH_RECEIPT_ID_REF%TYPE                                 DEFAULT NULL,
  P_OTH_RECEIPT_DATE              IN  JAI_CMN_RG_23D_TRXS.oth_receipt_date%TYPE                               DEFAULT NULL,
  P_OTH_RECEIPT_QUANTITY          IN  JAI_CMN_RG_23D_TRXS.oth_receipt_quantity%TYPE                           DEFAULT NULL,
  P_REMARKS                       IN  JAI_CMN_RG_23D_TRXS.remarks%TYPE                                        DEFAULT NULL,
  P_QTY_TO_ADJUST                 IN  JAI_CMN_RG_23D_TRXS.qty_to_adjust%TYPE                                  DEFAULT NULL,
  P_RATE_PER_UNIT                 IN  JAI_CMN_RG_23D_TRXS.rate_per_unit%TYPE                                  DEFAULT NULL,
  P_EXCISE_DUTY_RATE              IN  JAI_CMN_RG_23D_TRXS.excise_duty_rate%TYPE                               DEFAULT NULL,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_23D_TRXS.charge_account_id%TYPE                              DEFAULT NULL,
  P_DUTY_AMOUNT                   IN  JAI_CMN_RG_23D_TRXS.duty_amount%TYPE                                    DEFAULT NULL,
  P_TRANSACTION_ID                IN  JAI_CMN_RG_23D_TRXS.TRANSACTION_SOURCE_NUM%TYPE                                 DEFAULT NULL,
  P_RECEIPT_DATE                  IN  JAI_CMN_RG_23D_TRXS.receipt_date%TYPE                                   DEFAULT NULL,
  P_GOODS_ISSUE_ID                IN  JAI_CMN_RG_23D_TRXS.goods_issue_id%TYPE                                 DEFAULT NULL,
  P_GOODS_ISSUE_DATE              IN  JAI_CMN_RG_23D_TRXS.goods_issue_date%TYPE                               DEFAULT NULL,
  P_GOODS_ISSUE_QUANTITY          IN  JAI_CMN_RG_23D_TRXS.goods_issue_quantity%TYPE                           DEFAULT NULL,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_23D_TRXS.transaction_date%TYPE                               DEFAULT NULL,
  P_OPENING_BALANCE_QTY           IN  JAI_CMN_RG_23D_TRXS.opening_balance_qty%TYPE                            DEFAULT NULL,
  P_CLOSING_BALANCE_QTY           IN  JAI_CMN_RG_23D_TRXS.closing_balance_qty%TYPE                            DEFAULT NULL,
  P_BASIC_ED                      IN  JAI_CMN_RG_23D_TRXS.basic_ed%TYPE                                       DEFAULT NULL,
  P_ADDITIONAL_ED                 IN  JAI_CMN_RG_23D_TRXS.additional_ed%TYPE                                  DEFAULT NULL,
  P_ADDITIONAL_CVD                IN  JAI_CMN_RG_23D_TRXS.additional_cvd%TYPE                                 DEFAULT NULL, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
  P_OTHER_ED                      IN  JAI_CMN_RG_23D_TRXS.other_ed%TYPE                                       DEFAULT NULL,
  P_CVD                           IN  JAI_CMN_RG_23D_TRXS.cvd%TYPE                                            DEFAULT NULL,
  P_VENDOR_ID                     IN  JAI_CMN_RG_23D_TRXS.vendor_id%TYPE                                      DEFAULT NULL,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_23D_TRXS.vendor_site_id%TYPE                                 DEFAULT NULL,
  P_RECEIPT_NUM                   IN  JAI_CMN_RG_23D_TRXS.receipt_num%TYPE                                    DEFAULT NULL,
  P_ATTRIBUTE1                    IN  JAI_CMN_RG_23D_TRXS.attribute1%TYPE                                     DEFAULT NULL,
  P_ATTRIBUTE2                    IN  JAI_CMN_RG_23D_TRXS.attribute2%TYPE                                     DEFAULT NULL,
  P_ATTRIBUTE3                    IN  JAI_CMN_RG_23D_TRXS.attribute3%TYPE                                     DEFAULT NULL,
  P_ATTRIBUTE4                    IN  JAI_CMN_RG_23D_TRXS.attribute4%TYPE                                     DEFAULT NULL,
  P_ATTRIBUTE5                    IN  JAI_CMN_RG_23D_TRXS.attribute5%TYPE                                     DEFAULT NULL,
  P_CONSIGNEE                     IN  JAI_CMN_RG_23D_TRXS.consignee%TYPE                                      DEFAULT NULL,
  P_MANUFACTURER_NAME             IN  JAI_CMN_RG_23D_TRXS.manufacturer_name%TYPE                              DEFAULT NULL,
  P_MANUFACTURER_ADDRESS          IN  JAI_CMN_RG_23D_TRXS.manufacturer_address%TYPE                           DEFAULT NULL,
  P_MANUFACTURER_RATE_AMT_PER_UN  IN  JAI_CMN_RG_23D_TRXS.manufacturer_rate_amt_per_unit%TYPE                 DEFAULT NULL,
  P_QTY_RECEIVED_FROM_MANUFACTUR  IN  JAI_CMN_RG_23D_TRXS.qty_received_from_manufacturer%TYPE                 DEFAULT NULL,
  P_TOT_AMT_PAID_TO_MANUFACTURER  IN  JAI_CMN_RG_23D_TRXS.tot_amt_paid_to_manufacturer%TYPE                   DEFAULT NULL,
  -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
  P_OTHER_TAX_CREDIT              IN  JAI_CMN_RG_23D_TRXS.other_tax_credit%TYPE                               DEFAULT NULL,
  P_OTHER_TAX_DEBIT               IN  JAI_CMN_RG_23D_TRXS.other_tax_debit%TYPE                                DEFAULT NULL,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
) IS
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_23d_trxs_pkg.update_row'; /* Added by Ramananda for bug#4407165 */
BEGIN

  UPDATE JAI_CMN_RG_23D_TRXS SET
    REGISTER_ID                   = nvl(P_REGISTER_ID, REGISTER_ID),
    ORGANIZATION_ID               = nvl(P_ORGANIZATION_ID, ORGANIZATION_ID),
    LOCATION_ID                   = nvl(P_LOCATION_ID, LOCATION_ID),
    SLNO                          = nvl(P_SLNO, SLNO),
    FIN_YEAR                      = nvl(P_FIN_YEAR, FIN_YEAR),
    TRANSACTION_TYPE              = nvl(P_TRANSACTION_TYPE, TRANSACTION_TYPE),
    RECEIPT_REF                    = nvl(P_RECEIPT_ID, RECEIPT_REF),
    QUANTITY_RECEIVED             = nvl(P_QUANTITY_RECEIVED, QUANTITY_RECEIVED),
    INVENTORY_ITEM_ID             = nvl(P_INVENTORY_ITEM_ID, INVENTORY_ITEM_ID),
    SUBINVENTORY                  = nvl(P_SUBINVENTORY, SUBINVENTORY),
    REFERENCE_LINE_ID             = nvl(P_REFERENCE_LINE_ID, REFERENCE_LINE_ID),
    PRIMARY_UOM_CODE              = nvl(P_PRIMARY_UOM_CODE, PRIMARY_UOM_CODE),
    TRANSACTION_UOM_CODE          = nvl(P_TRANSACTION_UOM_CODE, TRANSACTION_UOM_CODE),
    CUSTOMER_ID                   = nvl(P_CUSTOMER_ID, CUSTOMER_ID),
    BILL_TO_SITE_ID               = nvl(P_BILL_TO_SITE_ID, BILL_TO_SITE_ID),
    SHIP_TO_SITE_ID               = nvl(P_SHIP_TO_SITE_ID, SHIP_TO_SITE_ID),
    QUANTITY_ISSUED               = nvl(P_QUANTITY_ISSUED, QUANTITY_ISSUED),
    REGISTER_CODE                 = nvl(P_REGISTER_CODE, REGISTER_CODE),
    RELEASED_DATE                 = nvl(P_RELEASED_DATE, RELEASED_DATE),
    COMM_INVOICE_NO               = nvl(P_COMM_INVOICE_NO, COMM_INVOICE_NO),
    COMM_INVOICE_DATE             = nvl(P_COMM_INVOICE_DATE, COMM_INVOICE_DATE),
    RECEIPT_BOE_NUM               = nvl(P_RECEIPT_BOE_NUM, RECEIPT_BOE_NUM),
    OTH_RECEIPT_ID_REF                = nvl(P_OTH_RECEIPT_ID, OTH_RECEIPT_ID_REF),
    OTH_RECEIPT_DATE              = nvl(P_OTH_RECEIPT_DATE, OTH_RECEIPT_DATE),
    OTH_RECEIPT_QUANTITY          = nvl(P_OTH_RECEIPT_QUANTITY, OTH_RECEIPT_QUANTITY),
    REMARKS                       = nvl(P_REMARKS, REMARKS),
    QTY_TO_ADJUST                 = nvl(P_QTY_TO_ADJUST, QTY_TO_ADJUST),
    RATE_PER_UNIT                 = nvl(P_RATE_PER_UNIT, RATE_PER_UNIT),
    EXCISE_DUTY_RATE              = nvl(P_EXCISE_DUTY_RATE, EXCISE_DUTY_RATE),
    CHARGE_ACCOUNT_ID             = nvl(P_CHARGE_ACCOUNT_ID, CHARGE_ACCOUNT_ID),
    DUTY_AMOUNT                   = nvl(P_DUTY_AMOUNT, DUTY_AMOUNT),
    TRANSACTION_SOURCE_NUM                = nvl(P_TRANSACTION_ID, TRANSACTION_SOURCE_NUM),
    RECEIPT_DATE                  = nvl(P_RECEIPT_DATE, RECEIPT_DATE),
    GOODS_ISSUE_ID                = nvl(P_GOODS_ISSUE_ID, GOODS_ISSUE_ID),
    GOODS_ISSUE_DATE              = nvl(P_GOODS_ISSUE_DATE, GOODS_ISSUE_DATE),
    GOODS_ISSUE_QUANTITY          = nvl(P_GOODS_ISSUE_QUANTITY, GOODS_ISSUE_QUANTITY),
    TRANSACTION_DATE              = nvl(P_TRANSACTION_DATE, TRANSACTION_DATE),
    OPENING_BALANCE_QTY           = nvl(P_OPENING_BALANCE_QTY, OPENING_BALANCE_QTY),
    CLOSING_BALANCE_QTY           = nvl(P_CLOSING_BALANCE_QTY, CLOSING_BALANCE_QTY),
    BASIC_ED                      = nvl(P_BASIC_ED, BASIC_ED),
    ADDITIONAL_ED                 = nvl(P_ADDITIONAL_ED, ADDITIONAL_ED),
    ADDITIONAL_CVD                = nvl(P_ADDITIONAL_CVD,ADDITIONAL_CVD),
    OTHER_ED                      = nvl(P_OTHER_ED, OTHER_ED),
    CVD                           = nvl(P_CVD, CVD),
    VENDOR_ID                     = nvl(P_VENDOR_ID, VENDOR_ID),
    VENDOR_SITE_ID                = nvl(P_VENDOR_SITE_ID, VENDOR_SITE_ID),
    RECEIPT_NUM                   = nvl(P_RECEIPT_NUM, RECEIPT_NUM),
    ATTRIBUTE1                    = nvl(P_ATTRIBUTE1, ATTRIBUTE1),
    ATTRIBUTE2                    = nvl(P_ATTRIBUTE2, ATTRIBUTE2),
    ATTRIBUTE3                    = nvl(P_ATTRIBUTE3, ATTRIBUTE3),
    ATTRIBUTE4                    = nvl(P_ATTRIBUTE4, ATTRIBUTE4),
    ATTRIBUTE5                    = nvl(P_ATTRIBUTE5, ATTRIBUTE5),
    CONSIGNEE                     = nvl(P_CONSIGNEE, CONSIGNEE),
    MANUFACTURER_NAME             = nvl(P_MANUFACTURER_NAME, MANUFACTURER_NAME),
    MANUFACTURER_ADDRESS          = nvl(P_MANUFACTURER_ADDRESS, MANUFACTURER_ADDRESS),
    MANUFACTURER_RATE_AMT_PER_UNIT= nvl(P_MANUFACTURER_RATE_AMT_PER_UN, MANUFACTURER_RATE_AMT_PER_UNIT),
    QTY_RECEIVED_FROM_MANUFACTURER= nvl(P_QTY_RECEIVED_FROM_MANUFACTUR, QTY_RECEIVED_FROM_MANUFACTURER),
    TOT_AMT_PAID_TO_MANUFACTURER  = nvl(P_TOT_AMT_PAID_TO_MANUFACTURER, TOT_AMT_PAID_TO_MANUFACTURER),
    -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
    other_tax_credit              = nvl(p_other_tax_credit, other_tax_credit),
    other_tax_debit               = nvl(p_other_tax_debit, other_tax_debit)
  WHERE register_id = p_register_id;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END update_row;

PROCEDURE update_qty_to_adjust(
  p_register_id       IN  NUMBER,
  p_quantity          IN  NUMBER,
  P_SIMULATE_FLAG     IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
) IS

BEGIN
  -- QTY_TO_ADJUST is a column which will be only INSERTED with a value for RECEIVE transaction and will be reduced
  -- whenever a -ve Quantity Transaction or RTV Happens for Shipment Line
  -- p_quantity can be +ve incase of regular RTV and +ve CORRECTion of RTV. -ve During Deliver to Non Trading
  UPDATE JAI_CMN_RG_23D_TRXS
  SET qty_to_adjust = nvl(qty_to_adjust, 0) - p_quantity,
    last_update_date= SYSDATE
  WHERE register_id = p_register_id;

END update_qty_to_adjust;

PROCEDURE update_payment_details(
  p_register_id       IN  NUMBER,
  p_charge_account_id IN  NUMBER
) IS

BEGIN

  UPDATE JAI_CMN_RG_23D_TRXS
  SET charge_account_id = p_charge_account_id,
    last_update_date= SYSDATE
  WHERE register_id = p_register_id;

END update_payment_details;


FUNCTION get_trxn_entry_cnt(
  p_organization_id   IN NUMBER,
  p_location_id     IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_receipt_id    IN VARCHAR2,
  p_transaction_id IN NUMBER
) RETURN NUMBER IS

  ln_record_exist_cnt       NUMBER(4);
  CURSOR c_record_exist IS
    SELECT count(1)
    FROM JAI_CMN_RG_23D_TRXS
    WHERE organization_id = p_organization_id
    AND location_id = p_location_id
    AND inventory_item_id = p_inventory_item_id
    AND receipt_ref = p_receipt_id
    AND TRANSACTION_SOURCE_NUM = p_transaction_id;

BEGIN

  OPEN c_record_exist;
  FETCH c_record_exist INTO ln_record_exist_cnt;
  CLOSE c_record_exist;

  IF ln_record_exist_cnt > 0 THEN
    FND_FILE.put_line( FND_FILE.log, '23D Duplicate Chk:'||ln_record_exist_cnt
      ||', PARAMS: Orgn>'||p_organization_id||', Loc>'||p_location_id
      ||', Item>'||p_inventory_item_id
      ||', TrxId>'||p_receipt_id||', type>'||p_transaction_id
    );
  END IF;

  RETURN ln_record_exist_cnt;

END get_trxn_entry_cnt;


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
 /* following two elsifs added - bug# 6030615 - interorg transfer*/
  ELSIF p_transaction_type IN ('I','R') and p_transaction_source='Direct Org Transfer' then
    p_transaction_id    := 3;
  ELSIF p_transaction_type IN ('I','R') and p_transaction_source='Intransit Shipment' then
     p_transaction_id    := 21;
  ELSE
    p_transaction_id := 20;
    p_transaction_type := 'MISC';
  END IF;

END get_trxn_type_and_id;

PROCEDURE make_entry
(p_org_id       IN NUMBER,
 p_location_id      IN NUMBER,
 p_trans_type       IN VARCHAR2,
 p_item_id      IN NUMBER,
 p_subinv_code      IN VARCHAR2,
 p_pr_uom_code      IN VARCHAR2,
 p_trans_uom_code   IN VARCHAR2,
 p_oth_receipt_id   IN NUMBER,
 p_oth_receipt_date     IN DATE,
 p_oth_receipt_qty  IN NUMBER,
 p_transaction_id   IN NUMBER,
 p_goods_issue_id   IN NUMBER,
 p_goods_issue_date     IN DATE,
 p_goods_issue_qty  IN NUMBER,
 p_trans_date       IN DATE,
 p_creation_date    IN DATE,
 p_created_by       IN NUMBER,
 p_last_update_date IN DATE,
 p_last_update_login    IN NUMBER,
 p_last_updated_by  IN NUMBER)
 IS

 /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_23d_trxs_pkg.make_entry';

 v_reg_id       Number;
 v_fin_year     Number;
 v_slno         Number;
 v_closing_bal_qty  Number  :=0;
 v_opening_bal_qty  Number  :=0;

 Cursor get_regid_cur IS
 SELECT JAI_CMN_RG_23D_TRXS_S.nextval
 FROM dual;

 CURSOR fin_year_CUR is
 SELECT max(fin_year) fin_year
 FROM JAI_CMN_FIN_YEARS
 WHERE organization_id = p_org_id
 AND fin_active_flag = 'Y';

 CURSOR SLNO_BAL_CUR(v_fin_year NUMBER) is
 SELECT slno,NVL(closing_balance_qty, 0)
 FROM JAI_CMN_RG_23D_TRXS
 WHERE organization_id = p_org_id
  AND location_id = p_location_id
  AND fin_year = v_fin_year
  and inventory_item_id = p_item_id --ashish 12/nov/2002;
  AND slno = (SELECT max(slno)
  FROM JAI_CMN_RG_23D_TRXS
  WHERE organization_id = p_org_id
   AND location_id = p_location_id
   AND fin_year = v_fin_year
   and inventory_item_id = p_item_id);  --ashish 12/nov/2002;

   v_issue_qty number; --ashish for bug # 2659989

 Begin
 /*-------------------------------------------------------------------------------------------------------------------------
 S.No  Date(DD/MM/YY) Author and Details of Changes
 ----  -------------- -----------------------------
 1    11/11/02       asshukla for  bug # 2659989.
                     As observed by VPRABAKA
                     the sno which is unique for a oraganization , location , fin year and inventory item was gettin duplicated
                     as there was no check on the inventory item id. the code is added for the selection of the slno.
                     From now on the serial no will be generated itemwise.

                     Also closing balance was increasinf even if the transaction type was issue which is wrong,
                     It has been corrected by adding an if condition and making the quantity negative in case
                     the transaction type is issue.Added a variable v_issue_qty for the same.

 --------------------------------------------------------------------------------------------------------------------------*/


    OPEN  get_regid_cur;
    FETCH get_regid_cur INTO v_reg_id;
    CLOSE get_regid_cur;

    OPEN  fin_year_CUR;
    FETCH fin_year_CUR INTO v_fin_year;
    CLOSE fin_year_CUR;

    OPEN  slno_bal_cur(v_fin_year);
    FETCH slno_bal_cur INTO v_slno, v_closing_bal_qty;
    CLOSE slno_bal_cur;

    if p_trans_type in ('I','IA') then  --ashish bug # 2659989 Added the IA condition for bug 8303258 by nprashar
        v_issue_qty := -p_goods_issue_qty;
    else
        v_issue_qty := p_goods_issue_qty;
    end if;

    IF v_slno IS NULL THEN
        v_slno := 0 ;
        v_opening_bal_qty := 0;
    ELSE
        v_opening_bal_qty := v_closing_bal_qty;
    END IF;

    v_closing_bal_qty := v_opening_bal_qty + NVL(p_oth_receipt_qty, v_issue_qty);
    v_slno := v_slno + 1;

    INSERT INTO JAI_CMN_RG_23D_TRXS
           (register_id,
        organization_id,
        location_id,
        slno,
        fin_year,
        transaction_type,
        inventory_item_id,
        subinventory,
        primary_uom_code,
        transaction_uom_code,
        OTH_RECEIPT_ID_REF,
        oth_receipt_date,
        oth_receipt_quantity,
        TRANSACTION_SOURCE_NUM,
        goods_issue_id,
        goods_issue_date,
        goods_issue_quantity,
        transaction_date,
        opening_balance_qty,
        closing_balance_qty,
        creation_date,
        created_by,
        last_update_date,
        last_update_login,
        last_updated_by)
    VALUES
           (v_reg_id,
        p_org_id,
        p_location_id,
        v_slno,
        v_fin_year,
        p_trans_type,
        p_item_id,
        p_subinv_code,
        p_pr_uom_code,
        p_trans_uom_code,
        p_oth_receipt_id,
        p_oth_receipt_date,
        p_oth_receipt_qty,
        p_transaction_id,
        p_goods_issue_id,
        p_goods_issue_date,
        v_issue_qty,
        p_trans_date,
        v_opening_bal_qty,
        v_closing_bal_qty,
        p_creation_date,
        p_created_by,
        p_last_update_date,
        p_last_update_login,
        p_last_updated_by);

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;


End make_entry;

--# ==================================================================================
--# FILENAME
--#
--#
--# DESCRIPTION
--#    Procedure to calculate opening and closing Qty balnaces
--#
--# ==================================================================================
PROCEDURE calculate_qty_balances
(p_org_id IN NUMBER,
 p_fin_year IN NUMBER,
 p_mode VARCHAR2,
 qty NUMBER,
 v_opening_Qty IN OUT NOCOPY NUMBER,
 v_closing_qty IN OUT NOCOPY NUMBER,
 p_inventory_item_id Number) IS

/* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_23d_trxs_pkg.calculate_qty_balances';

   v_previous_serial_no     number;
   v_serial_no          number;
   v_rg_balance             number;
   v_inventory_item_id      Number;
   err_msg              Varchar2(200);

   v_fin_year           Number;
   v_exists                   Number := 0;
   cnt                Number;

 Cursor C_Item_id Is
  Select b.Inventory_Item_Id
    From Ic_Item_Mst a, Mtl_System_Items b
   Where a.Item_no = b.segment1
     And a.Item_Id = p_INVENTORY_ITEM_ID
     And ( b.organization_Id   = p_org_id
        or b.organization_Id   = 0 ) ;

-- start added by K V UDAY KUMAR on 10-MAY-2001, to pick slno from previous year in
-- case of change in fin_year transactions

  Cursor prior_slno_cur(v_inventory_item_id Number) IS
  select NVL(MAX(slno),0), NVL(MAX(slno),0) + 1  from JAI_CMN_RG_23D_TRXS
  WHERE organization_id = p_org_id
  and inventory_item_id = v_inventory_item_id
  and fin_year = p_fin_year - 1;
-- end

 Cursor serial_no_cur(v_inventory_item_id Number) IS
     SELECT NVL(MAX(slno),0) , NVL(MAX(slno),0) + 1
     FROM JAI_CMN_RG_23D_TRXS
     WHERE organization_id = p_org_id and
    --    location_id   = p_location_id and
     inventory_item_id = v_inventory_item_id
       and fin_year = p_fin_year ;

  CURSOR balance_cur(p_previous_serial_no IN NUMBER,v_inventory_item_id Number,x_fin_year Number) IS
    SELECT NVL(opening_balance_qty,0),NVL(closing_balance_qty,0)
    FROM JAI_CMN_RG_23D_TRXS
    WHERE organization_id = p_org_id and
          --location_id = p_location_id and
          slno  = p_previous_serial_no and
          inventory_item_id = v_inventory_item_id and
          fin_year = x_fin_year;



BEGIN

   Open C_Item_id;
   fetch C_Item_id into v_inventory_item_id;
   close C_Item_id;

-- shifted below cursor in the (if cnt > 0) by K V UDAY KUMAR on 10-may-2001
/*     OPEN  serial_no_cur(v_inventory_item_id);
     FETCH  serial_no_cur  INTO v_previous_serial_no, v_serial_no;
     CLOSE  serial_no_cur;   */

-- added below code on 10-may-2001 by K V UDAY KUMAR
         select count(*) into cnt from JAI_CMN_RG_23D_TRXS
         WHERE organization_id = p_org_id
           and inventory_item_id = v_inventory_item_id
           and fin_year = p_fin_year;

       if cnt > 0 then

         OPEN serial_no_cur(v_inventory_item_id);
             FETCH serial_no_cur INTO v_previous_serial_no, v_serial_no;
                        v_exists := 1;
             CLOSE serial_no_cur;
         else
            OPEN prior_slno_cur(v_inventory_item_id);
            FETCH prior_slno_cur INTO v_previous_serial_no, v_serial_no;
            v_exists := 0;
                  CLOSE prior_slno_cur;
         end if;

            if v_exists = 1 then
                     v_fin_year := p_fin_year;
                  elsif v_exists = 0 then
                     v_fin_year  := p_fin_year - 1;
                  end if;
-- end here.

   IF NVL(v_previous_serial_no,0) = 0   THEN
     v_previous_serial_no := 0;
     v_serial_no := 1;
   END IF;

   IF NVL(v_previous_serial_no,0) > 0  THEN

             OPEN  balance_cur(v_previous_serial_no,v_inventory_item_id,v_fin_year);
             FETCH balance_cur INTO v_opening_qty, v_closing_qty;
             CLOSE balance_cur;

     v_opening_qty := v_closing_qty;

     IF p_mode = 'I' then
       v_closing_qty := v_closing_qty - qty;
     ELSIF p_mode = 'R' then
       v_closing_qty := v_closing_qty + qty;
     END IF;

   ELSE
     v_opening_qty := 0;
     IF p_mode = 'I' then
       v_closing_qty := nvl(v_closing_qty,0) - qty;
     ELSIF p_mode = 'R' then
       v_closing_qty := Nvl(v_closing_qty,0) + qty;
     END IF;
  END IF;


/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END calculate_qty_balances;

procedure upd_receipt_qty_matched(p_receipt_id in number,p_quantity_applied in number,p_qty_to_adjust Number) is
begin
     update JAI_CMN_RG_23D_TRXS
     set qty_to_adjust= nvl(qty_to_adjust,0) - nvl(p_quantity_applied,0)
     where register_id=p_receipt_id;
END upd_receipt_qty_matched;

END JAI_CMN_RG_23D_TRXS_PKG;

/
