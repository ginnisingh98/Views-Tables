--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RG_PLA_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RG_PLA_TRXS_PKG" AS
/* $Header: jai_cmn_rg_pla.plb 120.4 2007/08/07 07:46:46 vkaranam ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_cmn_rg_pla -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

14/07/2005   4485801 Brathod, File Version 117.1
             Issue: Inventory Convergence Uptake for R12 Initiative

28/12/2005   4892111 Hjujjuru, File Version 120.2
             Issue : In the insert into the  JAI_CMN_RG_PLA_TRXS , register_id
             was inserted as JAI_CMN_RG_PLA_TRXS_S1.nextval. This is errorring
             out.

             Fix : Created a cursor to retrieve the register_id value from the
             sequence and inserted the same into the JAI_CMN_RG_PLA_TRXS table

24/04/2007   Vijay Shankar for Bug# 6012570(5876390), Version:120.3 (115.7)
                    FP: Modified the code in get_trxn_type_and_id to return a transaction_id for Projects Billing

07/05/2007   Vkaranam for Bug# 6030615, Version:120.4
             Forward Porting the changes done in 115 bug 2942973(Interorg Transfer)
                    FP: Modified the code in get_trxn_type_and_id to return a transaction_id for Interorg Transfer.

*/

PROCEDURE insert_row(

  P_REGISTER_ID OUT NOCOPY JAI_CMN_RG_PLA_TRXS.register_id%TYPE,
  P_TR6_CHALLAN_NO                IN  JAI_CMN_RG_PLA_TRXS.tr6_challan_no%TYPE,
  P_TR6_CHALLAN_DATE              IN  JAI_CMN_RG_PLA_TRXS.tr6_challan_date%TYPE,
  P_CR_BASIC_ED                   IN  JAI_CMN_RG_PLA_TRXS.cr_basic_ed%TYPE,
  P_CR_ADDITIONAL_ED              IN  JAI_CMN_RG_PLA_TRXS.cr_additional_ed%TYPE,
  P_CR_OTHER_ED                   IN  JAI_CMN_RG_PLA_TRXS.cr_other_ed%TYPE,
  P_REF_DOCUMENT_ID               IN  JAI_CMN_RG_PLA_TRXS.ref_document_id%TYPE,
  P_REF_DOCUMENT_DATE             IN  JAI_CMN_RG_PLA_TRXS.ref_document_date%TYPE,
  P_DR_INVOICE_ID                 IN  JAI_CMN_RG_PLA_TRXS.DR_INVOICE_NO%TYPE,
  P_DR_INVOICE_DATE               IN  JAI_CMN_RG_PLA_TRXS.dr_invoice_date%TYPE,
  P_DR_BASIC_ED                   IN  JAI_CMN_RG_PLA_TRXS.dr_basic_ed%TYPE,
  P_DR_ADDITIONAL_ED              IN  JAI_CMN_RG_PLA_TRXS.dr_additional_ed%TYPE,
  P_DR_OTHER_ED                   IN  JAI_CMN_RG_PLA_TRXS.dr_other_ed%TYPE,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_PLA_TRXS.organization_id%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_PLA_TRXS.location_id%TYPE,
  P_BANK_BRANCH_ID                IN  JAI_CMN_RG_PLA_TRXS.bank_branch_id%TYPE,
  P_ENTRY_DATE                    IN  JAI_CMN_RG_PLA_TRXS.entry_date%TYPE,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_PLA_TRXS.inventory_item_id%TYPE,
  P_VENDOR_CUST_FLAG              IN  JAI_CMN_RG_PLA_TRXS.vendor_cust_flag%TYPE,
  P_VENDOR_ID                     IN  JAI_CMN_RG_PLA_TRXS.vendor_id%TYPE,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_PLA_TRXS.vendor_site_id%TYPE,
  P_EXCISE_INVOICE_NO             IN  JAI_CMN_RG_PLA_TRXS.excise_invoice_no%TYPE,
  P_REMARKS                       IN  JAI_CMN_RG_PLA_TRXS.remarks%TYPE,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_PLA_TRXS.transaction_date%TYPE,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_PLA_TRXS.charge_account_id%TYPE,
  -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
  P_OTHER_TAX_CREDIT              IN  JAI_CMN_RG_PLA_TRXS.other_tax_credit%TYPE,
  P_OTHER_TAX_DEBIT               IN  JAI_CMN_RG_PLA_TRXS.other_tax_debit%TYPE,
  p_transaction_type              IN  VARCHAR2,
  p_transaction_source            IN  VARCHAR2,
  p_called_from                   IN  VARCHAR2,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2,
  p_rounding_id                   IN  NUMBER default null -- Vijay Shankar for Bug#4103161
) IS

  ld_creation_date          DATE;
  ln_created_by             NUMBER(15);
  ld_last_update_date       DATE;
  ln_last_updated_by        NUMBER(15);
  ln_last_update_login      NUMBER(15);

  lv_last_register_id       NUMBER;
  ln_slno                   NUMBER(10) := 0;
  ln_transaction_id         NUMBER(10);
  lv_transaction_type       VARCHAR2(50);
  ln_opening_balance        NUMBER;
  ln_closing_balance        NUMBER;
  ln_tr_amount              NUMBER;

  ln_fin_year               NUMBER(4);
  lv_range                  JAI_CMN_RG_PLA_TRXS.range_no%TYPE;
  lv_division               JAI_CMN_RG_PLA_TRXS.division_no%TYPE;
  lv_master_flag            JAI_CMN_RG_PLA_TRXS.master_flag%TYPE;

  r_last_record             c_get_last_record%ROWTYPE;
  r_orgn_info               c_orgn_info%ROWTYPE;
  lv_message                VARCHAR2(200);

  ln_record_exist_cnt       NUMBER(4);

  lv_statement_id           VARCHAR2(5);

  -- added, Harshita for 4892111
  Cursor c_fetch_register_id IS
  select JAI_CMN_RG_PLA_TRXS_S1.nextval from dual ;

  ln_register_id jai_cmn_rg_pla_trxs.register_id%type ;
  -- ended, Harshita for 4892111

BEGIN

/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_cmn_rg_pla_trxs_pkg.sql
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     16/07/2002   Vijay Shankar for Bug# 3496408, Version:115.0
                    Table Handler coded for PLA table. Update_row of the package was just a skeleton that needs to be modified
                    whenever it is being used

2     03/01/2005   Vijay Shankar for Bug# 3940588, Version:115.1
                    Modified Insert and Update procedures to include p_other_tax_credit and p_other_tax_debit parameters for
                    Education Cess Enhancement

3     19/04/2005   Vijay Shankar for Bug# 4103161, Version:115.2
                    added a parameter ROUNDING_ID in insert and update procedures as part of RTV Rounding

                  * dependancy for later versions of this package *

Dependancy:
-----------
IN60105D2 + 3496408
IN60106   + 3940588 + 4103161

----------------------------------------------------------------------------------------------------------------------------*/


  lv_transaction_type   := p_transaction_type;

  lv_statement_id := '1';
  get_trxn_type_and_id(lv_transaction_type, p_transaction_source, ln_transaction_id);

  lv_statement_id := '2';
  ln_record_exist_cnt := get_trxn_entry_cnt(p_organization_id, p_location_id,
                                            p_inventory_item_id, p_ref_document_id, ln_transaction_id);

  IF ln_record_exist_cnt > 0 THEN
    p_process_status  := 'X';
    p_process_message := 'PLA Entry was already made for the transaction';
    GOTO end_of_processing;
  END IF;

  lv_statement_id := '3';
  ln_tr_amount := ( nvl(p_cr_basic_ed,0) + nvl(p_cr_additional_ed,0)+ nvl(p_cr_other_ed,0))
                        - ( nvl(p_dr_basic_ed,0) + nvl(p_dr_additional_ed,0)+ nvl(p_dr_other_ed,0));

  lv_statement_id := '4';
  OPEN c_orgn_info(p_organization_id, p_location_id);
  FETCH c_orgn_info INTO r_orgn_info;
  CLOSE c_orgn_info;

  lv_statement_id := '5';
  ln_fin_year         := jai_general_pkg.get_fin_year(p_organization_id);

  lv_statement_id := '6';
  lv_last_register_id := jai_general_pkg.get_last_record_of_rg
                    ('PLA', p_organization_id, p_location_id, p_inventory_item_id, ln_fin_year);

  IF lv_last_register_id IS NULL THEN
    IF r_orgn_info.ssi_unit_flag = jai_general_pkg.NO THEN
      -- this is not an Error Condition
      lv_message := 'PLA Register doesnt have sufficient balances';
      GOTO end_of_processing;
    ELSE
      ln_slno := 1;
    END IF;

  ELSE
    lv_statement_id := '7';
    OPEN c_get_last_record(lv_last_register_id);
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
      P_REGISTER_TYPE     => 'PLA',
      P_OPENING_BALANCE   => ln_opening_balance,
      P_PROCESS_STATUS    => p_process_status,
      P_PROCESS_MESSAGE   => p_process_message
  );

  ln_closing_balance := ln_opening_balance + ln_tr_amount;

  IF r_orgn_info.ssi_unit_flag = jai_general_pkg.NO THEN
    -- *** check whether the balances are enough
    IF ln_closing_balance < 0 THEN
      lv_message := 'PLA Register doesnt have sufficient balances';
      GOTO end_of_processing;
    END IF;
  END IF;

  ld_creation_date      := SYSDATE;
  ln_created_by         := FND_GLOBAL.user_id;
  ld_last_update_date   := SYSDATE;
  ln_last_updated_by    := ln_created_by;
  ln_last_update_login  := FND_GLOBAL.login_id;

  lv_statement_id := '9';
  lv_master_flag        := jai_general_pkg.get_orgn_master_flag(p_organization_id, p_location_id);

  lv_statement_id := '10';
  jai_general_pkg.get_range_division(p_vendor_id, p_vendor_site_id, lv_range, lv_division);

  -- added, Harshita for 4892111
  OPEN c_fetch_register_id ;
  FETCH c_fetch_register_id INTO ln_register_id ;
  CLOSE c_fetch_register_id ;
  -- ended, Harshita for 4892111

  INSERT INTO JAI_CMN_RG_PLA_TRXS(
    REGISTER_ID,
    FIN_YEAR,
    SLNO,
    TR6_CHALLAN_NO,
    TR6_CHALLAN_DATE,
    CR_BASIC_ED,
    CR_ADDITIONAL_ED,
    CR_OTHER_ED,
    TRANSACTION_SOURCE_NUM,
    REF_DOCUMENT_ID,
    REF_DOCUMENT_DATE,
    DR_INVOICE_NO,
    DR_INVOICE_DATE,
    DR_BASIC_ED,
    DR_ADDITIONAL_ED,
    DR_OTHER_ED,
    ORGANIZATION_ID,
    LOCATION_ID,
    BANK_BRANCH_ID,
    ENTRY_DATE,
    INVENTORY_ITEM_ID,
    VENDOR_CUST_FLAG,
    VENDOR_ID,
    VENDOR_SITE_ID,
    RANGE_NO,
    DIVISION_NO,
    EXCISE_INVOICE_NO,
    REMARKS,
    TRANSACTION_DATE,
    OPENING_BALANCE,
    CLOSING_BALANCE,
    CHARGE_ACCOUNT_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    POSTED_FLAG,
    MASTER_FLAG,
    BASIC_OPENING_BALANCE,
    BASIC_CLOSING_BALANCE,
    ADDITIONAL_OPENING_BALANCE,
    ADDITIONAL_CLOSING_BALANCE,
    OTHER_OPENING_BALANCE,
    OTHER_CLOSING_BALANCE,
    -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
    other_tax_credit,
    other_tax_debit,
    rounding_id
  ) VALUES (
    ln_register_id, --JAI_CMN_RG_PLA_TRXS_S1.nextval, Harshita for 4892111        --P_REGISTER_ID,
    ln_fin_year,                --P_FIN_YEAR,
    ln_slno,                    --P_SLNO,
    P_TR6_CHALLAN_NO,
    P_TR6_CHALLAN_DATE,
    P_CR_BASIC_ED,
    P_CR_ADDITIONAL_ED,
    P_CR_OTHER_ED,
    ln_transaction_id,          --P_TRANSACTION_ID,
    P_REF_DOCUMENT_ID,
    P_REF_DOCUMENT_DATE,
    P_DR_INVOICE_ID,
    P_DR_INVOICE_DATE,
    P_DR_BASIC_ED,
    P_DR_ADDITIONAL_ED,
    P_DR_OTHER_ED,
    P_ORGANIZATION_ID,
    P_LOCATION_ID,
    P_BANK_BRANCH_ID,
    P_ENTRY_DATE,
    P_INVENTORY_ITEM_ID,
    P_VENDOR_CUST_FLAG,
    P_VENDOR_ID,
    P_VENDOR_SITE_ID,
    lv_range,                   --P_RANGE_NO,
    lv_division,                --P_DIVISION_NO,
    P_EXCISE_INVOICE_NO,
    P_REMARKS,
    P_TRANSACTION_DATE,
    ln_opening_balance,         --P_OPENING_BALANCE,
    ln_closing_balance,         --P_CLOSING_BALANCE,
    P_CHARGE_ACCOUNT_ID,
    ld_creation_date,           --P_CREATION_DATE,
    ln_created_by,              --P_CREATED_BY,
    ld_last_update_date,        --P_LAST_UPDATE_DATE,
    ln_last_updated_by,         --P_LAST_UPDATED_BY,
    ln_last_update_login,       --P_LAST_UPDATE_LOGIN,
    'N',                        --P_POSTED_FLAG,
    lv_master_flag,             --P_MASTER_FLAG,
    NULL,                       --P_BASIC_OPENING_BALANCE,
    NULL,                       --P_BASIC_CLOSING_BALANCE,
    NULL,                       --P_ADDITIONAL_OPENING_BALANCE,
    NULL,                       --P_ADDITIONAL_CLOSING_BALANCE,
    NULL,                       --P_OTHER_OPENING_BALANCE,
    NULL,                       --P_OTHER_CLOSING_BALANCE
    -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
    p_other_tax_credit,
    p_other_tax_debit,
    p_rounding_id   -- Vijay Shankar for Bug#4103161
  ) RETURNING register_id INTO P_REGISTER_ID;

  lv_statement_id := '11';
  jai_cmn_rg_balances_pkg.update_row(
    p_organization_id   => p_organization_id,
    p_location_id       => p_location_id,
    p_register_type     => 'PLA',
    p_amount_to_be_added=> ln_tr_amount,
    p_simulate_flag     => p_simulate_flag,
    p_process_status    => p_process_status,
    p_process_message   => p_process_message
  );

  <<end_of_processing>>

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    p_process_status := 'E';
    p_process_message := 'PLA_PKG.insert_row->'||SQLERRM||', StmtId->'||lv_statement_id;
    FND_FILE.put_line( FND_FILE.log, p_process_message);

END insert_row;

PROCEDURE update_row(

  P_REGISTER_ID                   IN  JAI_CMN_RG_PLA_TRXS.register_id%TYPE                                       DEFAULT NULL,
  P_FIN_YEAR                      IN  JAI_CMN_RG_PLA_TRXS.fin_year%TYPE                                          DEFAULT NULL,
  P_SLNO                          IN  JAI_CMN_RG_PLA_TRXS.slno%TYPE                                              DEFAULT NULL,
  P_TR6_CHALLAN_NO                IN  JAI_CMN_RG_PLA_TRXS.tr6_challan_no%TYPE                                    DEFAULT NULL,
  P_TR6_CHALLAN_DATE              IN  JAI_CMN_RG_PLA_TRXS.tr6_challan_date%TYPE                                  DEFAULT NULL,
  P_CR_BASIC_ED                   IN  JAI_CMN_RG_PLA_TRXS.cr_basic_ed%TYPE                                       DEFAULT NULL,
  P_CR_ADDITIONAL_ED              IN  JAI_CMN_RG_PLA_TRXS.cr_additional_ed%TYPE                                  DEFAULT NULL,
  P_CR_OTHER_ED                   IN  JAI_CMN_RG_PLA_TRXS.cr_other_ed%TYPE                                       DEFAULT NULL,
  P_TRANSACTION_ID                IN  JAI_CMN_RG_PLA_TRXS.TRANSACTION_SOURCE_NUM%TYPE                                    DEFAULT NULL,
  P_REF_DOCUMENT_ID               IN  JAI_CMN_RG_PLA_TRXS.ref_document_id%TYPE                                   DEFAULT NULL,
  P_REF_DOCUMENT_DATE             IN  JAI_CMN_RG_PLA_TRXS.ref_document_date%TYPE                                 DEFAULT NULL,
  P_DR_INVOICE_ID                 IN  JAI_CMN_RG_PLA_TRXS.DR_INVOICE_NO%TYPE                                     DEFAULT NULL,
  P_DR_INVOICE_DATE               IN  JAI_CMN_RG_PLA_TRXS.dr_invoice_date%TYPE                                   DEFAULT NULL,
  P_DR_BASIC_ED                   IN  JAI_CMN_RG_PLA_TRXS.dr_basic_ed%TYPE                                       DEFAULT NULL,
  P_DR_ADDITIONAL_ED              IN  JAI_CMN_RG_PLA_TRXS.dr_additional_ed%TYPE                                  DEFAULT NULL,
  P_DR_OTHER_ED                   IN  JAI_CMN_RG_PLA_TRXS.dr_other_ed%TYPE                                       DEFAULT NULL,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_PLA_TRXS.organization_id%TYPE                                   DEFAULT NULL,
  P_LOCATION_ID                   IN  JAI_CMN_RG_PLA_TRXS.location_id%TYPE                                       DEFAULT NULL,
  P_BANK_BRANCH_ID                IN  JAI_CMN_RG_PLA_TRXS.bank_branch_id%TYPE                                    DEFAULT NULL,
  P_ENTRY_DATE                    IN  JAI_CMN_RG_PLA_TRXS.entry_date%TYPE                                        DEFAULT NULL,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_PLA_TRXS.inventory_item_id%TYPE                                 DEFAULT NULL,
  P_VENDOR_CUST_FLAG              IN  JAI_CMN_RG_PLA_TRXS.vendor_cust_flag%TYPE                                  DEFAULT NULL,
  P_VENDOR_ID                     IN  JAI_CMN_RG_PLA_TRXS.vendor_id%TYPE                                         DEFAULT NULL,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_PLA_TRXS.vendor_site_id%TYPE                                    DEFAULT NULL,
  P_RANGE_NO                      IN  JAI_CMN_RG_PLA_TRXS.range_no%TYPE                                          DEFAULT NULL,
  P_DIVISION_NO                   IN  JAI_CMN_RG_PLA_TRXS.division_no%TYPE                                       DEFAULT NULL,
  P_EXCISE_INVOICE_NO             IN  JAI_CMN_RG_PLA_TRXS.excise_invoice_no%TYPE                                 DEFAULT NULL,
  P_REMARKS                       IN  JAI_CMN_RG_PLA_TRXS.remarks%TYPE                                           DEFAULT NULL,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_PLA_TRXS.transaction_date%TYPE                                  DEFAULT NULL,
  P_OPENING_BALANCE               IN  JAI_CMN_RG_PLA_TRXS.opening_balance%TYPE                                   DEFAULT NULL,
  P_CLOSING_BALANCE               IN  JAI_CMN_RG_PLA_TRXS.closing_balance%TYPE                                   DEFAULT NULL,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_PLA_TRXS.charge_account_id%TYPE                                 DEFAULT NULL,
  P_POSTED_FLAG                   IN  JAI_CMN_RG_PLA_TRXS.posted_flag%TYPE                                       DEFAULT NULL,
  P_MASTER_FLAG                   IN  JAI_CMN_RG_PLA_TRXS.master_flag%TYPE                                       DEFAULT NULL,
  -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
  P_OTHER_TAX_CREDIT              IN  JAI_CMN_RG_PLA_TRXS.other_tax_credit%TYPE                                  DEFAULT NULL,
  P_OTHER_TAX_DEBIT               IN  JAI_CMN_RG_PLA_TRXS.other_tax_debit%TYPE                                   DEFAULT NULL,
  p_rounding_id                   IN  NUMBER default null -- Vijay Shankar for Bug#4103161
) IS

/* Added by Ramananda for bug#4407165 */
lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_pla_trxs_pkg.update_row';

BEGIN

  UPDATE JAI_CMN_RG_PLA_TRXS SET
    REGISTER_ID                   = nvl(P_REGISTER_ID, REGISTER_ID),
    FIN_YEAR                      = nvl(P_FIN_YEAR, FIN_YEAR),
    SLNO                          = nvl(P_SLNO, SLNO),
    TR6_CHALLAN_NO                = nvl(P_TR6_CHALLAN_NO, TR6_CHALLAN_NO),
    TR6_CHALLAN_DATE              = nvl(P_TR6_CHALLAN_DATE, TR6_CHALLAN_DATE),
    CR_BASIC_ED                   = nvl(P_CR_BASIC_ED, CR_BASIC_ED),
    CR_ADDITIONAL_ED              = nvl(P_CR_ADDITIONAL_ED, CR_ADDITIONAL_ED),
    CR_OTHER_ED                   = nvl(P_CR_OTHER_ED, CR_OTHER_ED),
    TRANSACTION_SOURCE_NUM                = nvl(P_TRANSACTION_ID, TRANSACTION_SOURCE_NUM),
    REF_DOCUMENT_ID               = nvl(P_REF_DOCUMENT_ID, REF_DOCUMENT_ID),
    REF_DOCUMENT_DATE             = nvl(P_REF_DOCUMENT_DATE, REF_DOCUMENT_DATE),
    DR_INVOICE_NO                 = nvl(P_DR_INVOICE_ID, DR_INVOICE_NO),
    DR_INVOICE_DATE               = nvl(P_DR_INVOICE_DATE, DR_INVOICE_DATE),
    DR_BASIC_ED                   = nvl(P_DR_BASIC_ED, DR_BASIC_ED),
    DR_ADDITIONAL_ED              = nvl(P_DR_ADDITIONAL_ED, DR_ADDITIONAL_ED),
    DR_OTHER_ED                   = nvl(P_DR_OTHER_ED, DR_OTHER_ED),
    ORGANIZATION_ID               = nvl(P_ORGANIZATION_ID, ORGANIZATION_ID),
    LOCATION_ID                   = nvl(P_LOCATION_ID, LOCATION_ID),
    BANK_BRANCH_ID                = nvl(P_BANK_BRANCH_ID, BANK_BRANCH_ID),
    ENTRY_DATE                    = nvl(P_ENTRY_DATE, ENTRY_DATE),
    INVENTORY_ITEM_ID             = nvl(P_INVENTORY_ITEM_ID, INVENTORY_ITEM_ID),
    VENDOR_CUST_FLAG              = nvl(P_VENDOR_CUST_FLAG, VENDOR_CUST_FLAG),
    VENDOR_ID                     = nvl(P_VENDOR_ID, VENDOR_ID),
    VENDOR_SITE_ID                = nvl(P_VENDOR_SITE_ID, VENDOR_SITE_ID),
    RANGE_NO                      = nvl(P_RANGE_NO, RANGE_NO),
    DIVISION_NO                   = nvl(P_DIVISION_NO, DIVISION_NO),
    EXCISE_INVOICE_NO             = nvl(P_EXCISE_INVOICE_NO, EXCISE_INVOICE_NO),
    REMARKS                       = nvl(P_REMARKS, REMARKS),
    TRANSACTION_DATE              = nvl(P_TRANSACTION_DATE, TRANSACTION_DATE),
    OPENING_BALANCE               = nvl(P_OPENING_BALANCE, OPENING_BALANCE),
    CLOSING_BALANCE               = nvl(P_CLOSING_BALANCE, CLOSING_BALANCE),
    CHARGE_ACCOUNT_ID             = nvl(P_CHARGE_ACCOUNT_ID, CHARGE_ACCOUNT_ID),
    LAST_UPDATE_DATE              = sysdate,
    LAST_UPDATED_BY               = fnd_global.user_id,
    LAST_UPDATE_LOGIN             = fnd_global.login_id,
    POSTED_FLAG                   = nvl(P_POSTED_FLAG, POSTED_FLAG),
    MASTER_FLAG                   = nvl(P_MASTER_FLAG, MASTER_FLAG),
    -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
    OTHER_TAX_CREDIT              = nvl(P_OTHER_TAX_CREDIT, OTHER_TAX_CREDIT),
    OTHER_TAX_debit               = nvl(P_OTHER_TAX_debit, OTHER_TAX_debit),
    rounding_id                   = nvl(p_rounding_id, rounding_id) -- Vijay Shankar for Bug#4103161
  WHERE register_id = p_register_id;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END update_row;

PROCEDURE update_payment_details(
  p_register_id         IN  NUMBER,
  p_charge_account_id   IN  NUMBER
) IS

BEGIN

  UPDATE JAI_CMN_RG_PLA_TRXS
  SET charge_account_id = p_charge_account_id,
    last_update_date= SYSDATE
  WHERE register_id = p_register_id;

END update_payment_details;

FUNCTION get_trxn_entry_cnt(
  p_organization_id   IN NUMBER,
  p_location_id     IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_ref_document_id    IN NUMBER,
  p_transaction_id IN NUMBER
) RETURN NUMBER IS

  ln_record_exist_cnt       NUMBER(4);
  CURSOR c_record_exist IS
    SELECT count(1)
    FROM JAI_CMN_RG_PLA_TRXS
    WHERE organization_id = p_organization_id
    AND location_id = p_location_id
    AND inventory_item_id = p_inventory_item_id
    AND ref_document_id = p_ref_document_id
    AND transaction_source_num = p_transaction_id;

BEGIN

  OPEN c_record_exist;
  FETCH c_record_exist INTO ln_record_exist_cnt;
  CLOSE c_record_exist;

  IF ln_record_exist_cnt > 0 THEN
    FND_FILE.put_line( FND_FILE.log, 'PLA Duplicate Chk:'||ln_record_exist_cnt
      ||', PARAMS: Orgn>'||p_organization_id||', Loc>'||p_location_id
      ||', Item>'||p_inventory_item_id
      ||', TrxId>'||p_ref_document_id||', type>'||p_transaction_id
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
    p_transaction_id := 19;
    p_transaction_type := 'RTV';
  ELSIF p_transaction_type = jai_constants.service_src_distribute_in THEN
    p_transaction_id    := 151;
    p_transaction_type  := jai_constants.service_src_distribute_in;
  ELSIF p_transaction_type = jai_constants.service_src_distribute_out THEN
    p_transaction_id    := 152;
    p_transaction_type  := jai_constants.service_src_distribute_out ;
  -- Added by Brathod, for Inv.Convergence
  ELSIF p_transaction_source  = 'OPM_OSP' AND p_transaction_type ='I' THEN
    p_transaction_type  := 201;
  ELSIF p_transaction_source  = 'OPM_OSP' AND p_transaction_type ='R' THEN
    p_transaction_type  := 202;

  /* cbabu for bug# 6012570 (5876390). Projects Billing implementation */
  ELSIF p_transaction_type = 'DRAFT_INVOICE' and p_transaction_source = 'DRAFT_INVOICE_RELEASE' then
    p_transaction_id    := 30;
    p_transaction_type := 'PROJECTS-BILLING';
  /*added by vkaranam for bug 6030615 */
 --start
 ELSIF p_transaction_type='INTERORG_XFER' and p_transaction_source='Direct Org Transfer' then
     p_transaction_id    := 3;
 ELSIF p_transaction_type='INTERORG_XFER' and p_transaction_source='Intransit Shipment' then
    p_transaction_id    := 21;
 --end 6030615

  ELSE
    p_transaction_id := 20;
    p_transaction_type := 'MISC';
  END IF;

END get_trxn_type_and_id;

PROCEDURE generate_component_balances
    (
        errbuf VARCHAR2,
        retcode VARCHAR2
    )
IS
    CURSOR FETCH_REGISTER_DETAILS IS
    SELECT
        A.ORGANIZATION_ID,
        A.LOCATION_ID ,
        A.INVENTORY_ITEM_ID,
        A.FIN_YEAR,
        A.REGISTER_ID,
        A.SLNO,
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
        A.TRANSACTION_DATE,
        A.LAST_UPDATE_LOGIN
    FROM JAI_CMN_RG_PLA_TRXS A
    WHERE NOT EXISTS (  SELECT '1'
                        FROM   JAI_CMN_RG_PLA_CMP_DTLS B
                        WHERE  B.REGISTER_ID = A.REGISTER_ID
                        AND    B.SLNO        = A.SLNO)
    ORDER BY REGISTER_ID,SLNO;

    --Variable Declarations starts here.......
    V_BASIC_OPENING_BALANCE         NUMBER :=0;
    V_ADDITIONAL_OPENING_BALANCE    NUMBER :=0;
    V_OTHER_OPENING_BALANCE         NUMBER :=0;
    V_BASIC_CLOSING_BALANCE         NUMBER;
    V_ADDITIONAL_CLOSING_BALANCE    NUMBER;
    V_OTHER_CLOSING_BALANCE         NUMBER;
    V_COUNT NUMBER;

    v_commit_count                  NUMBER:=0;
    --Variable Declarations Ends here..........


BEGIN --B1

/*------------------------------------------------------------------------------------------
     FILENAME: jai_cmn_rg_pla_trxs_pkg.generate_component_balances.sql
     CHANGE HISTORY:

    1.  2002/07/28   Nagaraj.s - For Enh#2371031
                     This Procedure is Created for Textile Industry specifically wherin individual
                     balances of Excise components are to be maintained.
                     In case of  data not existing in Excise Component Balances for an combination of
                     Organization/Location, this will inserts data into JAI_CMN_RG_COMP_BALS
                     and JAI_CMN_RG_PLA_CMP_DTLS tables and if data exists, then it will insert data
                     into JAI_CMN_RG_PLA_CMP_DTLS and updates JAI_CMN_RG_COMP_BALS table.

-----------------------------------------------------------------------------------------------
*/


  FOR CUR_REC IN FETCH_REGISTER_DETAILS
  LOOP  --L1
    BEGIN
      SELECT NVL(BASIC_PLA_BALANCE,0),
             NVL(ADDITIONAL_PLA_BALANCE,0),
             NVL(OTHER_PLA_BALANCE,0)
       INTO  V_BASIC_OPENING_BALANCE,
             V_ADDITIONAL_OPENING_BALANCE,
             V_OTHER_OPENING_BALANCE
       FROM  JAI_CMN_RG_COMP_BALS
       WHERE ORGANIZATION_ID= CUR_REC.ORGANIZATION_ID AND
             LOCATION_ID= CUR_REC.LOCATION_ID;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
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

                    V_BASIC_OPENING_BALANCE := 0;
                    V_ADDITIONAL_OPENING_BALANCE := 0;
                    V_OTHER_OPENING_BALANCE := 0;

    END;


    --Calculation of present Lines Closing Balances..........
    BEGIN
      V_BASIC_CLOSING_BALANCE       := V_BASIC_OPENING_BALANCE + NVL(CUR_REC.CR_BASIC_ED,0) - NVL(CUR_REC.DR_BASIC_ED,0);
      V_ADDITIONAL_CLOSING_BALANCE  := V_ADDITIONAL_OPENING_BALANCE + NVL(CUR_REC.CR_ADDITIONAL_ED,0) - NVL(CUR_REC.DR_ADDITIONAL_ED,0);
      V_OTHER_CLOSING_BALANCE       := V_OTHER_OPENING_BALANCE + NVL(CUR_REC.CR_OTHER_ED,0) - NVL(CUR_REC.DR_OTHER_ED,0);
    END;


    INSERT INTO JAI_CMN_RG_PLA_CMP_DTLS
            (
            ORGANIZATION_ID,
            LOCATION_ID,
            INVENTORY_ITEM_ID,
            FIN_YEAR,
            REGISTER_ID,
            SLNO ,
            BASIC_OPENING_BALANCE,
            ADDITIONAL_OPENING_BALANCE,
            OTHER_OPENING_BALANCE,
            CR_BASIC_ED,
            CR_ADDITIONAL_ED,
            CR_OTHER_ED ,
            DR_BASIC_ED,
            DR_ADDITIONAL_ED ,
            DR_OTHER_ED,
            BASIC_CLOSING_BALANCE,
            ADDITIONAL_CLOSING_BALANCE,
            OTHER_CLOSING_BALANCE,
            CREATION_DATE ,
            CREATED_BY ,
            LAST_UPDATE_DATE ,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            TRANSACTION_DATE
            )
            VALUES
            (
            CUR_REC.ORGANIZATION_ID,
            CUR_REC.LOCATION_ID,
            CUR_REC.INVENTORY_ITEM_ID,
            CUR_REC.FIN_YEAR,
            CUR_REC.REGISTER_ID,
            CUR_REC.SLNO,
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
            CUR_REC.LAST_UPDATE_LOGIN,
            CUR_REC.TRANSACTION_DATE
            );

            --To Update Register Balances.................
            UPDATE JAI_CMN_RG_COMP_BALS
            SET
            BASIC_PLA_BALANCE        = V_BASIC_CLOSING_BALANCE,
            ADDITIONAL_PLA_BALANCE   = V_ADDITIONAL_CLOSING_BALANCE,
            OTHER_PLA_BALANCE        = V_OTHER_CLOSING_BALANCE,
            LAST_UPDATE_DATE         = TRUNC(SYSDATE),
            LAST_UPDATED_BY          = CUR_REC.LAST_UPDATED_BY
            WHERE ORGANIZATION_ID    = CUR_REC.ORGANIZATION_ID AND
            LOCATION_ID              = CUR_REC.LOCATION_ID;
             --Updation Ends here.....................................
           -- COMMIT;
           IF v_commit_count = 100 THEN
             COMMIT;
             v_commit_count := 0;
           ELSE
             v_commit_count := v_commit_count + 1;
           END IF;
    END LOOP;  --L1

    COMMIT;

EXCEPTION --Ex1
    WHEN OTHERS THEN
      ROLLBACK;
END generate_component_balances; --E1


END jai_cmn_rg_pla_trxs_pkg;

/
