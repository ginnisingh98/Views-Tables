--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RG_23AC_II_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RG_23AC_II_PKG" AS
/* $Header: jai_cmn_rg_23p2.plb 120.7 2007/08/07 06:14:49 rchandan ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.1 jai_cmn_rg_23p2 -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

14-Jun-2005      rchandan for bug#4428980, Version 116.2
                        Modified the object to remove literals from DML statements and CURSORS.

14/07/2005   4485801 Brathod, File Version 117.1
             Issue: Inventory Convergence Uptake for R12 Initiative


01/11/2006  SACSETHI for bug 5228046, File version 120.3
            Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
            This bug has datamodel and spec changes.

24/04/2007   Vijay Shankar for Bug# 6012570(5876390), Version:120.5 (115.7)
                    FP: Modified the code in get_trxn_type_and_id to return a transaction_id for Projects Billing

08/05/2007   Arvind Goel - bug# 6030615 - version 120.6
                      added code to default the correct transsaction id based on the transaction types

01-08-2007  rchandan for bug#6030615 , Version 120.7
            Issue : Inter org Forward porting
*/

PROCEDURE insert_row(

  P_REGISTER_ID OUT NOCOPY JAI_CMN_RG_23AC_II_TRXS.register_id%TYPE,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_23AC_II_TRXS.inventory_item_id%TYPE,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_23AC_II_TRXS.organization_id%TYPE,
  P_RECEIPT_ID                    IN  JAI_CMN_RG_23AC_II_TRXS.RECEIPT_REF%TYPE,
  P_RECEIPT_DATE                  IN  JAI_CMN_RG_23AC_II_TRXS.receipt_date%TYPE,
  P_CR_BASIC_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.cr_basic_ed%TYPE,
  P_CR_ADDITIONAL_ED              IN  JAI_CMN_RG_23AC_II_TRXS.cr_additional_ed%TYPE,
  P_CR_ADDITIONAL_CVD             IN  JAI_CMN_RG_23AC_II_TRXS.cr_additional_cvd%TYPE DEFAULT NULL, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
  P_CR_OTHER_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.cr_other_ed%TYPE,
  P_DR_BASIC_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.dr_basic_ed%TYPE,
  P_DR_ADDITIONAL_ED              IN  JAI_CMN_RG_23AC_II_TRXS.dr_additional_ed%TYPE,
  P_DR_ADDITIONAL_CVD             IN  JAI_CMN_RG_23AC_II_TRXS.dr_additional_cvd%TYPE DEFAULT NULL, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
  P_DR_OTHER_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.dr_other_ed%TYPE,
  P_EXCISE_INVOICE_NO             IN  JAI_CMN_RG_23AC_II_TRXS.excise_invoice_no%TYPE,
  P_EXCISE_INVOICE_DATE           IN  JAI_CMN_RG_23AC_II_TRXS.excise_invoice_date%TYPE,
  P_REGISTER_TYPE                 IN  JAI_CMN_RG_23AC_II_TRXS.register_type%TYPE,
  P_REMARKS                       IN  JAI_CMN_RG_23AC_II_TRXS.remarks%TYPE,
  P_VENDOR_ID                     IN  JAI_CMN_RG_23AC_II_TRXS.vendor_id%TYPE,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_23AC_II_TRXS.vendor_site_id%TYPE,
  P_CUSTOMER_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.customer_id%TYPE,
  P_CUSTOMER_SITE_ID              IN  JAI_CMN_RG_23AC_II_TRXS.customer_site_id%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.location_id%TYPE,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_23AC_II_TRXS.transaction_date%TYPE,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_23AC_II_TRXS.charge_account_id%TYPE,
  P_REGISTER_ID_PART_I            IN  JAI_CMN_RG_23AC_II_TRXS.register_id_part_i%TYPE,
  P_REFERENCE_NUM                 IN  JAI_CMN_RG_23AC_II_TRXS.reference_num%TYPE,
  P_ROUNDING_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.rounding_id%TYPE,
  -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
  P_OTHER_TAX_CREDIT              IN  JAI_CMN_RG_23AC_II_TRXS.other_tax_credit%TYPE,
  P_OTHER_TAX_DEBIT               IN  JAI_CMN_RG_23AC_II_TRXS.other_tax_debit%TYPE,
  p_transaction_type              IN  VARCHAR2,
  P_TRANSACTION_SOURCE            IN  VARCHAR2,
  P_CALLED_FROM                   IN  VARCHAR2,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2,
  P_ADDITIONAL_CVD                IN  NUMBER DEFAULT NULL -- Harshita for bug 5096787
) IS

  ld_creation_date          DATE;
  ln_created_by             NUMBER(15);
  ld_last_update_date       DATE;
  ln_last_updated_by        NUMBER(15);
  ln_last_update_login      NUMBER(15);

  ln_last_register_id       NUMBER;
  ln_slno                   NUMBER(10) := 0;
  ln_transaction_id         NUMBER(10);
  lv_transaction_type       VARCHAR2(50);
  ln_opening_balance        NUMBER;
  ln_closing_balance        NUMBER;
  ln_tr_amount                 NUMBER;

  ln_fin_year               NUMBER(4);
  lv_range                  JAI_CMN_RG_23AC_II_TRXS.range_no%TYPE;
  lv_division               JAI_CMN_RG_23AC_II_TRXS.division_no%TYPE;
  lv_master_flag            JAI_CMN_RG_23AC_II_TRXS.master_flag%TYPE;
  ln_rounding_id            JAI_CMN_RG_23AC_II_TRXS.rounding_id%TYPE;

  r_last_record             c_get_last_record%ROWTYPE;

  ln_record_exist_cnt       NUMBER(4);
  lv_statement_id           VARCHAR2(5);

BEGIN

/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_cmn_rg_23ac_ii_pkg.sql
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     16/07/2004   Vijay Shankar for Bug# 3496408, Version:115.0
                    Table handler Package for JAI_CMN_RG_23AC_II_TRXS table

2     03/01/2005   Vijay Shankar for Bug# 3940588, Version:115.1
                    Modified Insert and Update procedures to include p_other_tax_credit and p_other_tax_debit parameters for
                    Education Cess Enhancement

Dependancy:
-----------
IN60105D2 + 3496408
IN60106   + 3940588

----------------------------------------------------------------------------------------------------------------------------*/

/* IMPORTANT NOTE:
  For Receiving Transactions: In case of CGIN Claim a value is received for JAI_CMN_RG_23AC_II_TRXS.REFERENCE_NUM column
    that will be used for Duplicate Checking.
    Incase of RECEIVE transaction value received for 1st 50% Claim is '1st Claim'. During 2nd 50% Claim value received is '2nd Claim'
    If 2nd Claim is happening from RTV transaction then TRANSACTION_ID of RTV is received as the value for REFERENCE_NUM
    In all Other transactions value received for REFERENCE_NUM column is NULL
*/

  ld_creation_date      := SYSDATE;
  ln_created_by         := FND_GLOBAL.user_id;
  ld_last_update_date   := SYSDATE;
  ln_last_updated_by    := ln_created_by;
  ln_last_update_login  := FND_GLOBAL.login_id;

  lv_statement_id := '1';
  ln_fin_year           := jai_general_pkg.get_fin_year(p_organization_id);
  lv_statement_id := '2';
  lv_master_flag        := jai_general_pkg.get_orgn_master_flag(p_organization_id, p_location_id);

  lv_transaction_type   := p_transaction_type;
  lv_statement_id := '3';
  get_trxn_type_and_id(lv_transaction_type, p_transaction_source, ln_transaction_id);

  lv_statement_id := '4';
  ln_record_exist_cnt := get_trxn_entry_cnt(p_register_type, p_organization_id, p_location_id, p_inventory_item_id,
                                            p_receipt_id, ln_transaction_id, p_reference_num);

  IF ln_record_exist_cnt > 0 THEN
    p_process_status  := 'X';
    p_process_message := 'RG23 Part II Entry was already made for the transaction';
    GOTO end_of_processing;
  END IF;

  lv_statement_id := '5';
  jai_general_pkg.get_range_division(p_vendor_id, p_vendor_site_id, lv_range, lv_division);



  -- Date 01/11/2006 Bug 5228046 added by SACSETHI

  ln_tr_amount := ( nvl(p_cr_basic_ed,0) + nvl(p_cr_additional_ed,0)+ nvl(p_cr_other_ed,0)  +  nvl(p_cr_additional_cvd,0) )
                        - ( nvl(p_dr_basic_ed,0) + nvl(p_dr_additional_ed,0)+ nvl(p_dr_other_ed,0)+ nvl(p_dr_additional_cvd,0) );

  lv_statement_id := '6';
  ln_last_register_id := jai_general_pkg.get_last_record_of_rg
                    ('RG23'||p_register_type||'_2', p_organization_id, p_location_id, p_inventory_item_id, ln_fin_year);

  IF ln_last_register_id IS NULL THEN
    ln_slno := 1;
  ELSE
    lv_statement_id := '7';
    OPEN c_get_last_record(ln_last_register_id);
    FETCH c_get_last_record INTO r_last_record;
    CLOSE c_get_last_record;

    IF r_last_record.fin_year = ln_fin_year THEN
      ln_slno := nvl(r_last_record.slno, 0) + 1;
    -- Start the serial number again in the new financial year
    ELSE
      ln_slno := 1;
    END IF;
  END IF;

  lv_statement_id := '8';
  jai_cmn_rg_balances_pkg.get_balance(
      P_ORGANIZATION_ID   => p_organization_id,
      P_LOCATION_ID       => p_location_id,
      P_REGISTER_TYPE     => p_register_type,
      P_OPENING_BALANCE   => ln_opening_balance,
      P_PROCESS_STATUS    => p_process_status,
      P_PROCESS_MESSAGE   => p_process_message
  );

  ln_closing_balance := ln_opening_balance + ln_tr_amount;

  IF p_rounding_id IS NOT NULL THEN
    ln_rounding_id := p_rounding_id;
  END IF;

  lv_statement_id := '9';
  INSERT INTO JAI_CMN_RG_23AC_II_TRXS(
    REGISTER_ID,
    FIN_YEAR,
    SLNO,
    TRANSACTION_SOURCE_NUM,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    RECEIPT_REF,
    RECEIPT_DATE,
    RANGE_NO,
    DIVISION_NO,
    CR_BASIC_ED,
    CR_ADDITIONAL_ED,
    CR_ADDITIONAL_CVD, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
    CR_OTHER_ED,
    DR_BASIC_ED,
    DR_ADDITIONAL_ED,
    DR_ADDITIONAL_CVD, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
    DR_OTHER_ED,
    EXCISE_INVOICE_NO,
    EXCISE_INVOICE_DATE,
    REGISTER_TYPE,
    REMARKS,
    VENDOR_ID,
    VENDOR_SITE_ID,
    CUSTOMER_ID,
    CUSTOMER_SITE_ID,
    LOCATION_ID,
    TRANSACTION_DATE,
    OPENING_BALANCE,
    CLOSING_BALANCE,
    CHARGE_ACCOUNT_ID,
    REGISTER_ID_PART_I,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    POSTED_FLAG,
    MASTER_FLAG,
    REFERENCE_NUM,
    ROUNDING_ID,
    -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
    other_tax_credit,
    other_tax_debit
  ) VALUES (
    JAI_CMN_RG_23AC_II_TRXS_S.nextval,   -- P_REGISTER_ID,
    ln_fin_year,          --P_FIN_YEAR,
    ln_slno,              --P_SLNO,
    ln_transaction_id,    --P_TRANSACTION_ID,
    P_INVENTORY_ITEM_ID,
    P_ORGANIZATION_ID,
    P_RECEIPT_ID,
    P_RECEIPT_DATE,
    lv_range,             --P_RANGE_NO,
    lv_division,          --P_DIVISION_NO,
    P_CR_BASIC_ED,
    P_CR_ADDITIONAL_ED,
    P_CR_ADDITIONAL_CVD, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
    P_CR_OTHER_ED,
    P_DR_BASIC_ED,
    P_DR_ADDITIONAL_ED,
    P_DR_ADDITIONAL_CVD, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
    P_DR_OTHER_ED,
    P_EXCISE_INVOICE_NO,
    P_EXCISE_INVOICE_DATE,
    P_REGISTER_TYPE,
    P_REMARKS,
    P_VENDOR_ID,
    P_VENDOR_SITE_ID,
    P_CUSTOMER_ID,
    P_CUSTOMER_SITE_ID,
    P_LOCATION_ID,
    P_TRANSACTION_DATE,
    ln_opening_balance,   --P_OPENING_BALANCE,
    ln_closing_balance,   --P_CLOSING_BALANCE,
    P_CHARGE_ACCOUNT_ID,
    P_REGISTER_ID_PART_I,
    ld_creation_date,     --P_CREATION_DATE,
    ln_created_by,        --P_CREATED_BY,
    ld_last_update_date,  --P_LAST_UPDATE_DATE,
    ln_last_updated_by,   --P_LAST_UPDATED_BY,
    ln_last_update_login, --P_LAST_UPDATE_LOGIN,
    'N',
    lv_master_flag,       --P_MASTER_FLAG,
    P_REFERENCE_NUM,
    ln_rounding_id,       --P_ROUNDING_ID
    -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
    p_other_tax_credit,
    p_other_tax_debit
  ) RETURNING register_id INTO P_REGISTER_ID;

  lv_statement_id := '10';
  jai_cmn_rg_balances_pkg.update_row(
    p_organization_id   => p_organization_id,
    p_location_id       => p_location_id,
    p_register_type     => p_register_type,
    p_amount_to_be_added=> ln_tr_amount,
    p_simulate_flag     => p_simulate_flag,
    p_process_status    => p_process_status,
    p_process_message   => p_process_message
  );
  --jai_general_pkg.update_rg_balances(p_organization_id, p_location_id, p_register_type,
  --      ln_tr_amount, 'RECEIVING', 'RG23_II_PKG.insert_row');

  <<end_of_processing>>

  NULL;
  --IF p_process_message IS NOT NULL THEN
  --  p_process_status  := 'E';
  --  RETURN;
  --END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_process_status := 'E';
    p_process_message := 'RG23_PART_II_PKG.insert_row->'||SQLERRM||', StmtId->'||lv_statement_id;
    FND_FILE.put_line( FND_FILE.log, p_process_message);

END insert_row;

PROCEDURE update_row(

  P_REGISTER_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.register_id%TYPE                              DEFAULT NULL,
  P_FIN_YEAR                      IN  JAI_CMN_RG_23AC_II_TRXS.fin_year%TYPE                                 DEFAULT NULL,
  P_SLNO                          IN  JAI_CMN_RG_23AC_II_TRXS.slno%TYPE                                     DEFAULT NULL,
  P_TRANSACTION_ID                IN  JAI_CMN_RG_23AC_II_TRXS.TRANSACTION_SOURCE_NUM%TYPE                   DEFAULT NULL,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_23AC_II_TRXS.inventory_item_id%TYPE                        DEFAULT NULL,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_23AC_II_TRXS.organization_id%TYPE                          DEFAULT NULL,
  P_RECEIPT_ID                    IN  JAI_CMN_RG_23AC_II_TRXS.RECEIPT_REF%TYPE                              DEFAULT NULL,
  P_RECEIPT_DATE                  IN  JAI_CMN_RG_23AC_II_TRXS.receipt_date%TYPE                             DEFAULT NULL,
  P_RANGE_NO                      IN  JAI_CMN_RG_23AC_II_TRXS.range_no%TYPE                                 DEFAULT NULL,
  P_DIVISION_NO                   IN  JAI_CMN_RG_23AC_II_TRXS.division_no%TYPE                              DEFAULT NULL,
  P_CR_BASIC_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.cr_basic_ed%TYPE                              DEFAULT NULL,
  P_CR_ADDITIONAL_ED              IN  JAI_CMN_RG_23AC_II_TRXS.cr_additional_ed%TYPE                         DEFAULT NULL,
  P_CR_ADDITIONAL_CVD             IN  JAI_CMN_RG_23AC_II_TRXS.cr_additional_cvd%TYPE                        DEFAULT NULL,  -- Date 01/11/2006 Bug 5228046 added by SACSETHI
  P_CR_OTHER_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.cr_other_ed%TYPE                              DEFAULT NULL,
  P_DR_BASIC_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.dr_basic_ed%TYPE                              DEFAULT NULL,
  P_DR_ADDITIONAL_ED              IN  JAI_CMN_RG_23AC_II_TRXS.dr_additional_ed%TYPE                         DEFAULT NULL,
  P_DR_ADDITIONAL_CVD             IN  JAI_CMN_RG_23AC_II_TRXS.cr_additional_cvd%TYPE                        DEFAULT NULL,  -- Date 01/11/2006 Bug 5228046 added by SACSETHI
  P_DR_OTHER_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.dr_other_ed%TYPE                              DEFAULT NULL,
  P_EXCISE_INVOICE_NO             IN  JAI_CMN_RG_23AC_II_TRXS.excise_invoice_no%TYPE                        DEFAULT NULL,
  P_EXCISE_INVOICE_DATE           IN  JAI_CMN_RG_23AC_II_TRXS.excise_invoice_date%TYPE                      DEFAULT NULL,
  P_REGISTER_TYPE                 IN  JAI_CMN_RG_23AC_II_TRXS.register_type%TYPE                            DEFAULT NULL,
  P_REMARKS                       IN  JAI_CMN_RG_23AC_II_TRXS.remarks%TYPE                                  DEFAULT NULL,
  P_VENDOR_ID                     IN  JAI_CMN_RG_23AC_II_TRXS.vendor_id%TYPE                                DEFAULT NULL,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_23AC_II_TRXS.vendor_site_id%TYPE                           DEFAULT NULL,
  P_CUSTOMER_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.customer_id%TYPE                              DEFAULT NULL,
  P_CUSTOMER_SITE_ID              IN  JAI_CMN_RG_23AC_II_TRXS.customer_site_id%TYPE                         DEFAULT NULL,
  P_LOCATION_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.location_id%TYPE                              DEFAULT NULL,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_23AC_II_TRXS.transaction_date%TYPE                         DEFAULT NULL,
  P_OPENING_BALANCE               IN  JAI_CMN_RG_23AC_II_TRXS.opening_balance%TYPE                          DEFAULT NULL,
  P_CLOSING_BALANCE               IN  JAI_CMN_RG_23AC_II_TRXS.closing_balance%TYPE                          DEFAULT NULL,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_23AC_II_TRXS.charge_account_id%TYPE                        DEFAULT NULL,
  P_REGISTER_ID_PART_I            IN  JAI_CMN_RG_23AC_II_TRXS.register_id_part_i%TYPE                       DEFAULT NULL,
  P_POSTED_FLAG                   IN  JAI_CMN_RG_23AC_II_TRXS.posted_flag%TYPE                              DEFAULT NULL,
  P_MASTER_FLAG                   IN  JAI_CMN_RG_23AC_II_TRXS.master_flag%TYPE                              DEFAULT NULL,
  P_REFERENCE_NUM                 IN  JAI_CMN_RG_23AC_II_TRXS.reference_num%TYPE                            DEFAULT NULL,
  P_ROUNDING_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.rounding_id%TYPE                              DEFAULT NULL,
  -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
  P_OTHER_TAX_CREDIT              IN  JAI_CMN_RG_23AC_II_TRXS.other_tax_credit%TYPE                         DEFAULT NULL,
  P_OTHER_TAX_DEBIT               IN  JAI_CMN_RG_23AC_II_TRXS.other_tax_debit%TYPE                          DEFAULT NULL,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2,
  P_ADDITIONAL_CVD                IN  NUMBER DEFAULT NULL -- Harshita for bug 5096787
) IS
BEGIN

  UPDATE JAI_CMN_RG_23AC_II_TRXS SET
    REGISTER_ID                   = nvl(P_REGISTER_ID, REGISTER_ID),
    FIN_YEAR                      = nvl(P_FIN_YEAR, FIN_YEAR),
    SLNO                          = nvl(P_SLNO, SLNO),
    TRANSACTION_SOURCE_NUM                = nvl(P_TRANSACTION_ID, TRANSACTION_SOURCE_NUM),
    INVENTORY_ITEM_ID             = nvl(P_INVENTORY_ITEM_ID, INVENTORY_ITEM_ID),
    ORGANIZATION_ID               = nvl(P_ORGANIZATION_ID, ORGANIZATION_ID),
    RECEIPT_REF                    = nvl(P_RECEIPT_ID, RECEIPT_REF),
    RECEIPT_DATE                  = nvl(P_RECEIPT_DATE, RECEIPT_DATE),
    RANGE_NO                      = nvl(P_RANGE_NO, RANGE_NO),
    DIVISION_NO                   = nvl(P_DIVISION_NO, DIVISION_NO),
    CR_BASIC_ED                   = nvl(P_CR_BASIC_ED, CR_BASIC_ED),
    CR_ADDITIONAL_ED              = nvl(P_CR_ADDITIONAL_ED, CR_ADDITIONAL_ED),
    CR_ADDITIONAL_CVD             = nvl(P_CR_ADDITIONAL_CVD, CR_ADDITIONAL_CVD), -- Date 01/11/2006 Bug 5228046 added by SACSETHI
    CR_OTHER_ED                   = nvl(P_CR_OTHER_ED, CR_OTHER_ED),
    DR_BASIC_ED                   = nvl(P_DR_BASIC_ED, DR_BASIC_ED),
    DR_ADDITIONAL_ED              = nvl(P_DR_ADDITIONAL_ED, DR_ADDITIONAL_ED),
    DR_ADDITIONAL_CVD             = nvl(P_DR_ADDITIONAL_CVD, DR_ADDITIONAL_CVD), -- Date 01/11/2006 Bug 5228046 added by SACSETHI
    DR_OTHER_ED                   = nvl(P_DR_OTHER_ED, DR_OTHER_ED),
    EXCISE_INVOICE_NO             = nvl(P_EXCISE_INVOICE_NO, EXCISE_INVOICE_NO),
    EXCISE_INVOICE_DATE           = nvl(P_EXCISE_INVOICE_DATE, EXCISE_INVOICE_DATE),
    REGISTER_TYPE                 = nvl(P_REGISTER_TYPE, REGISTER_TYPE),
    REMARKS                       = nvl(P_REMARKS, REMARKS),
    VENDOR_ID                     = nvl(P_VENDOR_ID, VENDOR_ID),
    VENDOR_SITE_ID                = nvl(P_VENDOR_SITE_ID, VENDOR_SITE_ID),
    CUSTOMER_ID                   = nvl(P_CUSTOMER_ID, CUSTOMER_ID),
    CUSTOMER_SITE_ID              = nvl(P_CUSTOMER_SITE_ID, CUSTOMER_SITE_ID),
    LOCATION_ID                   = nvl(P_LOCATION_ID, LOCATION_ID),
    TRANSACTION_DATE              = nvl(P_TRANSACTION_DATE, TRANSACTION_DATE),
    OPENING_BALANCE               = nvl(P_OPENING_BALANCE, OPENING_BALANCE),
    CLOSING_BALANCE               = nvl(P_CLOSING_BALANCE, CLOSING_BALANCE),
    CHARGE_ACCOUNT_ID             = nvl(P_CHARGE_ACCOUNT_ID, CHARGE_ACCOUNT_ID),
    REGISTER_ID_PART_I            = nvl(P_REGISTER_ID_PART_I, REGISTER_ID_PART_I),
    LAST_UPDATE_DATE              = sysdate,
    LAST_UPDATED_BY               = fnd_global.user_id,
    LAST_UPDATE_LOGIN             = fnd_global.login_id,
    POSTED_FLAG                   = nvl(P_POSTED_FLAG, POSTED_FLAG),
    MASTER_FLAG                   = nvl(P_MASTER_FLAG, MASTER_FLAG),
    REFERENCE_NUM                 = nvl(P_REFERENCE_NUM, REFERENCE_NUM),
    ROUNDING_ID                   = nvl(P_ROUNDING_ID, ROUNDING_ID),
    -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
    OTHER_TAX_CREDIT              = nvl(P_OTHER_TAX_CREDIT, OTHER_TAX_CREDIT),
    OTHER_TAX_debit              = nvl(P_OTHER_TAX_debit, OTHER_TAX_debit)
  WHERE register_id = p_register_id;

END update_row;

PROCEDURE update_payment_details(
  p_register_id         IN  NUMBER,
  p_register_id_part_i  IN  NUMBER,
  p_charge_account_id   IN  NUMBER
) IS

BEGIN

  UPDATE JAI_CMN_RG_23AC_II_TRXS
  SET
    register_id_part_i  = p_register_id_part_i,
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
  p_transaction_id    IN NUMBER,
  p_reference_num     IN VARCHAR2
) RETURN NUMBER IS

  ln_record_exist_cnt       NUMBER(4);
  CURSOR c_record_exist IS
    SELECT  count(1)
    FROM    JAI_CMN_RG_23AC_II_TRXS
    WHERE   organization_id = p_organization_id
    AND     location_id = p_location_id
    AND     inventory_item_id = p_inventory_item_id
    AND     register_type = p_register_type
    AND     receipt_ref = p_receipt_id
    AND     TRANSACTION_SOURCE_NUM = p_transaction_id
    AND     ((p_reference_num IS NULL AND reference_num IS NULL) OR reference_num = p_reference_num);

BEGIN

  OPEN c_record_exist;
  FETCH c_record_exist INTO ln_record_exist_cnt;
  CLOSE c_record_exist;

  IF ln_record_exist_cnt > 0 THEN
    FND_FILE.put_line( FND_FILE.log, '23Part2 Duplicate Chk:'||ln_record_exist_cnt
      ||', PARAMS: Orgn>'||p_organization_id||', Loc>'||p_location_id
      ||', Item>'||p_inventory_item_id||', Reg>'||p_register_type
      ||', TrxId>'||p_receipt_id||', type>'||p_transaction_id||', ref>'||p_reference_num
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
  ELSIF p_transaction_type = jai_constants.service_src_distribute_in THEN
    p_transaction_id    := 151;
    p_transaction_type  := jai_constants.service_src_distribute_in;
  ELSIF p_transaction_type = jai_constants.service_src_distribute_out THEN
    p_transaction_id    := 152;
    p_transaction_type  := jai_constants.service_src_distribute_out ;
  -- Added by Brathod, for Inv.Convergence
  ELSIF p_transaction_source = 'OPM_OSP' AND p_transaction_type = 'I' THEN
    p_transaction_id := 201;
  ELSIF p_transaction_source = 'OPM_OSP' AND p_transaction_type = 'R' THEN
    p_transaction_id := 202;

  /* cbabu for bug# 6012570 (5876390). Projects Billing implementation */
  ELSIF p_transaction_type = 'DRAFT_INVOICE' and p_transaction_source = 'DRAFT_INVOICE_RELEASE' then
    p_transaction_id    := 30;
    p_transaction_type := 'PROJECTS-BILLING';

  /* following two elsifs added by Arvind Goel - bug# 6030615 - interorg transfer*/
  ELSIF p_transaction_type='INTERORG_XFER' and p_transaction_source='Direct Org Transfer' then
     p_transaction_id    := 3;
  ELSIF p_transaction_type='INTERORG_XFER' and p_transaction_source='Intransit Shipment' then
     p_transaction_id    := 21;

  ELSE
    p_transaction_id := 20;
    p_transaction_type := 'MISC';
  END IF;

END get_trxn_type_and_id;

PROCEDURE generate_component_balances
(
        errbuf VARCHAR2,
        retcode VARCHAR2
) IS

    CURSOR FETCH_REGISTER_DETAILS IS
    SELECT
        A.ORGANIZATION_ID,
        A.LOCATION_ID ,
        A.INVENTORY_ITEM_ID,
        A.FIN_YEAR,
        A.REGISTER_ID,
        A.SLNO,
        A.REGISTER_TYPE,
        A.CR_BASIC_ED,
        A.CR_ADDITIONAL_ED,
        A.CR_OTHER_ED,
        A.DR_BASIC_ED,
        A.DR_ADDITIONAL_ED,
        A.DR_OTHER_ED,
        A.CREATION_DATE,
        A.CREATED_BY,
        A.LAST_UPDATE_DATE,
        A.LAST_UPDATED_BY,
        A.LAST_UPDATE_LOGIN,
        A.TRANSACTION_DATE
    FROM JAI_CMN_RG_23AC_II_TRXS A
    WHERE NOT EXISTS (  SELECT '1'
                        FROM   JAI_CMN_RG_COMP_DTLS B
                        WHERE  B.REGISTER_ID = A.REGISTER_ID)
    ORDER BY ORGANIZATION_ID,LOCATION_ID,REGISTER_ID;
    --Variable Declarations starts here.......
    V_BASIC_OPENING_BALANCE         NUMBER;
    V_ADDITIONAL_OPENING_BALANCE    NUMBER;
    V_OTHER_OPENING_BALANCE         NUMBER;
    V_BASIC_OPENING_BALANCE_A       NUMBER :=0;
    V_ADDITIONAL_OPENING_BALANCE_A  NUMBER :=0;
    V_OTHER_OPENING_BALANCE_A       NUMBER :=0;
    V_BASIC_OPENING_BALANCE_C       NUMBER:=0;
    V_ADDITIONAL_OPENING_BALANCE_C  NUMBER:=0;
    V_OTHER_OPENING_BALANCE_C       NUMBER:=0;
    V_BASIC_CLOSING_BALANCE         NUMBER;
    V_ADDITIONAL_CLOSING_BALANCE    NUMBER;
    V_OTHER_CLOSING_BALANCE         NUMBER;
    V_COUNT NUMBER;
    v_commit_count                  number:=0;
    --Variable Declarations Ends here..........
    --For UTL File..
    v_myfilehandle    UTL_FILE.FILE_TYPE; -- This is for File handling
    v_utl_location    VARCHAR2(512);
    v_debug_flag      VARCHAR2(1); -- := 'N' File.Sql.35 by Brathod
    lv_name           VARCHAR2(30); --rchandan for bug#4428980
    --Ends here......
BEGIN --B1
  /*------------------------------------------------------------------------------------------
     FILENAME: jai_cmn_rg_23ac_ii_pkg.generate_component_balances.sql
     CHANGE HISTORY:

      1.  2002/07/28   Nagaraj.s - For Enh#2371031
                       This Procedure is Created for Textile Industry specifically wherin individual
                       balances of Excise components are to be maintained.
                       In case of  data not existing in Excise Component Balances for an combination of
                       Organization/Location, this will inserts data into JAI_CMN_RG_COMP_BALS
                       and JAI_CMN_RG_COMP_DTLS tables and if data exists, then it will insert data
                       into JAI_CMN_RG_COMP_DTLS and updates JAI_CMN_RG_COMP_BALS table.

  -----------------------------------------------------------------------------------------------
*/
  v_debug_flag := 'N';

  IF v_debug_flag ='Y' THEN
  BEGIN
     lv_name := 'utl_file_dir';--rchandan for bug#4428980
     SELECT DECODE(SUBSTR (value,1,INSTR(value,',') -1),NULL,
     Value,SUBSTR (value,1,INSTR(value,',') -1))
     INTO v_utl_location
     FROM v$parameter
     WHERE name = lv_name;--rchandan for bug#4428980
   EXCEPTION
      WHEN OTHERS THEN
      v_debug_flag:='N';
   END;

   v_myfilehandle := UTL_FILE.FOPEN(v_utl_location,'componentbalances.log','A');

   UTL_FILE.PUT_LINE(v_myfilehandle,'************************Start************************************');
   UTL_FILE.PUT_LINE(v_myfilehandle,'The Time Stamp this Entry is Created is ' ||TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'));
  END IF;

  FOR CUR_REC IN FETCH_REGISTER_DETAILS
  LOOP  --L1
  IF V_DEBUG_FLAG='Y' THEN
   UTL_FILE.PUT_LINE(v_myfilehandle,'After Loop starts' ||'The Organization id is ' || CUR_REC.ORGANIZATION_ID);
   UTL_FILE.PUT_LINE(v_myfilehandle,'After Loop starts' ||'The Location id is ' || CUR_REC.LOCATION_ID);
   UTL_FILE.PUT_LINE(v_myfilehandle,'After Loop starts' ||'The Register id is ' || CUR_REC.REGISTER_ID);
  END IF;

    BEGIN
      SELECT NVL(BASIC_RG23A_BALANCE,0),
             NVL(ADDITIONAL_RG23A_BALANCE,0),
             NVL(OTHER_RG23A_BALANCE,0),
             NVL(BASIC_RG23C_BALANCE,0),
             NVL(ADDITIONAL_RG23C_BALANCE,0),
             NVL(OTHER_RG23C_BALANCE,0)
       INTO  V_BASIC_OPENING_BALANCE_A,
             V_ADDITIONAL_OPENING_BALANCE_A,
             V_OTHER_OPENING_BALANCE_A,
             V_BASIC_OPENING_BALANCE_C,
             V_ADDITIONAL_OPENING_BALANCE_C,
             V_OTHER_OPENING_BALANCE_C
       FROM  JAI_CMN_RG_COMP_BALS
       WHERE ORGANIZATION_ID= CUR_REC.ORGANIZATION_ID AND
             LOCATION_ID= CUR_REC.LOCATION_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       V_BASIC_OPENING_BALANCE_A := 0;
       V_ADDITIONAL_OPENING_BALANCE_A := 0;
       V_OTHER_OPENING_BALANCE_A := 0;
       V_BASIC_OPENING_BALANCE_C := 0;
       V_ADDITIONAL_OPENING_BALANCE_C := 0;
       V_OTHER_OPENING_BALANCE_C := 0;

       IF V_DEBUG_FLAG='Y' THEN
        UTL_FILE.PUT_LINE(v_myfilehandle,'Inside NDF' ||'The Organization id is ' || CUR_REC.ORGANIZATION_ID);
        UTL_FILE.PUT_LINE(v_myfilehandle,'Inside NDF' ||'The Location  id is ' || CUR_REC.LOCATION_ID);
       END IF;
       --DBMS_OUTPUT.PUT_LINE('Before Insert');
                    --If the combination of Organization and Location do not exist then
                    INSERT INTO JAI_CMN_RG_COMP_BALS
                    (COMPONENT_BALANCE_ID,
                    ORGANIZATION_ID,
                    LOCATION_ID,
                    BASIC_RG23A_BALANCE,
                    ADDITIONAL_RG23A_BALANCE,
                    OTHER_RG23A_BALANCE,
                    BASIC_RG23C_BALANCE,
                    ADDITIONAL_RG23C_BALANCE,
                    OTHER_RG23C_BALANCE,
                    BASIC_PLA_BALANCE,
                    ADDITIONAL_PLA_BALANCE,
                    OTHER_PLA_BALANCE,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN
                    )
                    VALUES
                    ( JAI_CMN_RG_COMP_BALS_S.nextval,
                    CUR_REC.ORGANIZATION_ID,
                    CUR_REC.LOCATION_ID,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    TRUNC(SYSDATE),
                    CUR_REC.CREATED_BY,
                    TRUNC(SYSDATE),
                    CUR_REC.LAST_UPDATED_BY,
                    CUR_REC.LAST_UPDATE_LOGIN
                    );
    END;
    IF CUR_REC.REGISTER_TYPE ='A' THEN
        V_BASIC_OPENING_BALANCE:= NVL(V_BASIC_OPENING_BALANCE_A, 0);
        V_ADDITIONAL_OPENING_BALANCE := NVL(V_ADDITIONAL_OPENING_BALANCE_A, 0);
        V_OTHER_OPENING_BALANCE := NVL(V_OTHER_OPENING_BALANCE_A, 0);
    ELSIF CUR_REC.REGISTER_TYPE ='C' THEN
        V_BASIC_OPENING_BALANCE:= NVL(V_BASIC_OPENING_BALANCE_C, 0);
        V_ADDITIONAL_OPENING_BALANCE := NVL(V_ADDITIONAL_OPENING_BALANCE_C, 0);
        V_OTHER_OPENING_BALANCE := NVL(V_OTHER_OPENING_BALANCE_C, 0);
    ELSE
      RAISE_APPLICATION_ERROR(-20001,'The Register Type Cannot be other than A or C');
    END IF;
    --Calculation of present Lines Opening Balance and Closing Balances..........
    BEGIN
      V_BASIC_CLOSING_BALANCE       := V_BASIC_OPENING_BALANCE + NVL(CUR_REC.CR_BASIC_ED,0) - NVL(CUR_REC.DR_BASIC_ED,0);
      V_ADDITIONAL_CLOSING_BALANCE  := V_ADDITIONAL_OPENING_BALANCE + NVL(CUR_REC.CR_ADDITIONAL_ED,0) - NVL(CUR_REC.DR_ADDITIONAL_ED,0);
      V_OTHER_CLOSING_BALANCE       := V_OTHER_OPENING_BALANCE + NVL(CUR_REC.CR_OTHER_ED,0) - NVL(CUR_REC.DR_OTHER_ED,0);
    END;

    IF V_DEBUG_FLAG='Y' THEN
     UTL_FILE.PUT_LINE(v_myfilehandle,'Before Insert into Details table' ||'The Organization id is ' || CUR_REC.ORGANIZATION_ID);
     UTL_FILE.PUT_LINE(v_myfilehandle,'Before Insert into Details table' ||'The Location  id is ' || CUR_REC.LOCATION_ID);
     UTL_FILE.PUT_LINE(v_myfilehandle,'Before Insert into Details table' ||'The Register  id is ' || CUR_REC.REGISTER_ID);
     UTL_FILE.PUT_LINE(v_myfilehandle,'Before Insert into Details table' ||'The V_BASIC_OPENING_BALANCE is ' || V_BASIC_OPENING_BALANCE);
     UTL_FILE.PUT_LINE(v_myfilehandle,'Before Insert into Details table' ||'The V_BASIC_CLOSING_BALANCE is ' || V_BASIC_CLOSING_BALANCE);
    END IF;

    INSERT INTO JAI_CMN_RG_COMP_DTLS
            (EXCISE_COMP_DTL_ID,
            ORGANIZATION_ID,
            LOCATION_ID,
            INVENTORY_ITEM_ID,
            FIN_YEAR ,
            REGISTER_ID,
            SLNO,
            REGISTER_TYPE,
            BASIC_OPENING_BALANCE,
            ADDITIONAL_OPENING_BALANCE,
            OTHER_OPENING_BALANCE,
            CR_BASIC_ED,
            CR_ADDITIONAL_ED ,
            CR_OTHER_ED,
            DR_BASIC_ED,
            DR_ADDITIONAL_ED,
            DR_OTHER_ED,
            BASIC_CLOSING_BALANCE,
            ADDITIONAL_CLOSING_BALANCE,
            OTHER_CLOSING_BALANCE,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            TRANSACTION_DATE,
            LAST_UPDATE_LOGIN
            )
            VALUES
            ( JAI_CMN_RG_COMP_DTLS_S.nextval,
            CUR_REC.ORGANIZATION_ID,
            CUR_REC.LOCATION_ID,
            CUR_REC.INVENTORY_ITEM_ID,
            CUR_REC.FIN_YEAR,
            CUR_REC.REGISTER_ID,
            CUR_REC.SLNO,
            CUR_REC.REGISTER_TYPE,
            V_BASIC_OPENING_BALANCE,
            V_ADDITIONAL_OPENING_BALANCE,
            V_OTHER_OPENING_BALANCE,
            CUR_REC.CR_BASIC_ED,
            CUR_REC.CR_ADDITIONAL_ED,
            CUR_REC.CR_OTHER_ED,
            CUR_REC.DR_BASIC_ED,
            CUR_REC.DR_ADDITIONAL_ED,
            CUR_REC.DR_OTHER_ED,
            V_BASIC_CLOSING_BALANCE,
            V_ADDITIONAL_CLOSING_BALANCE,
            V_OTHER_CLOSING_BALANCE,
            TRUNC(SYSDATE),
            CUR_REC.CREATED_BY,
            TRUNC(SYSDATE),
            CUR_REC.LAST_UPDATED_BY,
            CUR_REC.TRANSACTION_DATE,
            CUR_REC.LAST_UPDATE_LOGIN
            );
            --To Update Register Balances.................
            IF CUR_REC.REGISTER_TYPE = 'A' THEN
            UPDATE JAI_CMN_RG_COMP_BALS
            SET
            BASIC_RG23A_BALANCE      = V_BASIC_CLOSING_BALANCE,
            ADDITIONAL_RG23A_BALANCE = V_ADDITIONAL_CLOSING_BALANCE,
            OTHER_RG23A_BALANCE      = V_OTHER_CLOSING_BALANCE,
            LAST_UPDATE_DATE         = TRUNC(SYSDATE),
            LAST_UPDATED_BY          = CUR_REC.LAST_UPDATED_BY
            WHERE ORGANIZATION_ID    = CUR_REC.ORGANIZATION_ID AND
            LOCATION_ID              = CUR_REC.LOCATION_ID;
            ELSIF CUR_REC.REGISTER_TYPE = 'C' THEN
            UPDATE JAI_CMN_RG_COMP_BALS
            SET
            BASIC_RG23C_BALANCE      = V_BASIC_CLOSING_BALANCE,
            ADDITIONAL_RG23C_BALANCE = V_ADDITIONAL_CLOSING_BALANCE,
            OTHER_RG23C_BALANCE      = V_OTHER_CLOSING_BALANCE,
            LAST_UPDATE_DATE         = TRUNC(SYSDATE),
            LAST_UPDATED_BY          = CUR_REC.LAST_UPDATED_BY
            WHERE ORGANIZATION_ID    = CUR_REC.ORGANIZATION_ID AND
            LOCATION_ID              = CUR_REC.LOCATION_ID;
            END IF;
           --Updation Ends here.....................................
           --COMMIT;
           IF V_DEBUG_FLAG='Y' THEN
           UTL_FILE.PUT_LINE(v_myfilehandle,'Before Insert into Details table' ||'The Location  id is ' || CUR_REC.LOCATION_ID);
           END IF;
           if v_commit_count = 100 then
             commit;
             v_commit_count := 0;
           else
             v_commit_count := v_commit_count + 1;
           end if;
    END LOOP;  --L1
    commit;
    IF V_DEBUG_FLAG='Y' THEN
     UTL_FILE.FCLOSE(v_myfilehandle);
    END IF;
EXCEPTION --Ex1
    WHEN OTHERS THEN
      rollback;
END generate_component_balances; --E1

END jai_cmn_rg_23ac_ii_pkg;

/
