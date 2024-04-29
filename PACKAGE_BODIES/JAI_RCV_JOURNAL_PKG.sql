--------------------------------------------------------
--  DDL for Package Body JAI_RCV_JOURNAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_JOURNAL_PKG" AS
/* $Header: jai_rcv_jrnl.plb 120.4 2006/05/26 11:52:04 lgopalsa ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_rcv_jrnl -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

13-Jun-2005  4428980  File Version: 116.3
                      Ramananda for bug#4428980. Removal of SQL LITERALs is done
--------------------------------------------------------------------------------------*/

PROCEDURE insert_row(

  P_ORGANIZATION_ID               IN  NUMBER,
  P_ORGANIZATION_CODE             IN  JAI_RCV_JOURNAL_ENTRIES.organization_code%TYPE,
  P_RECEIPT_NUM                   IN  JAI_RCV_JOURNAL_ENTRIES.receipt_num%TYPE,
  P_TRANSACTION_ID                IN  JAI_RCV_JOURNAL_ENTRIES.transaction_id%TYPE,
  P_TRANSACTION_DATE              IN  JAI_RCV_JOURNAL_ENTRIES.transaction_date%TYPE,
  P_SHIPMENT_LINE_ID              IN  JAI_RCV_JOURNAL_ENTRIES.shipment_line_id%TYPE,
  P_ACCT_TYPE                     IN  JAI_RCV_JOURNAL_ENTRIES.acct_type%TYPE,
  P_ACCT_NATURE                   IN  JAI_RCV_JOURNAL_ENTRIES.acct_nature%TYPE,
  P_SOURCE_NAME                   IN  JAI_RCV_JOURNAL_ENTRIES.source_name%TYPE,
  P_CATEGORY_NAME                 IN  JAI_RCV_JOURNAL_ENTRIES.category_name%TYPE,
  P_CODE_COMBINATION_ID           IN  JAI_RCV_JOURNAL_ENTRIES.code_combination_id%TYPE,
  P_ENTERED_DR                    IN  JAI_RCV_JOURNAL_ENTRIES.entered_dr%TYPE,
  P_ENTERED_CR                    IN  JAI_RCV_JOURNAL_ENTRIES.entered_cr%TYPE,
  P_TRANSACTION_TYPE              IN  JAI_RCV_JOURNAL_ENTRIES.transaction_type%TYPE,
  P_PERIOD_NAME                   IN  JAI_RCV_JOURNAL_ENTRIES.period_name%TYPE,
  P_CURRENCY_CODE                 IN  JAI_RCV_JOURNAL_ENTRIES.currency_code%TYPE,
  P_CURRENCY_CONVERSION_TYPE      IN  JAI_RCV_JOURNAL_ENTRIES.currency_conversion_type%TYPE,
  P_CURRENCY_CONVERSION_DATE      IN  JAI_RCV_JOURNAL_ENTRIES.currency_conversion_date%TYPE,
  P_CURRENCY_CONVERSION_RATE      IN  JAI_RCV_JOURNAL_ENTRIES.currency_conversion_rate%TYPE,
  P_SIMULATE_FLAG                 IN  VARCHAR2, --File.Sql.35 Cbabu   DEFAULT 'N',
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2,
  /* two parameters added by Vijay Shankar for Bug#4250236(4245089). VAT Implementation */
  p_reference_name              in        varchar2 ,
  p_reference_id                in        number
) IS

  ld_creation_date    DATE;
  ln_created_by       NUMBER;
  ln_last_update_login JAI_RCV_JOURNAL_ENTRIES.LAST_UPDATE_LOGIN%TYPE ;

  lv_period_name      JAI_RCV_JOURNAL_ENTRIES.period_name%TYPE;
  lv_organization_code  ORG_ORGANIZATION_DEFINITIONS.organization_code%TYPE;

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed org_organization_definitions from the cursor c_period_name
   * and passed set_of_books_id to the cursor. Also removed
   * gl_sets_of_books and included gl_ledgers.
   */

  CURSOR c_period_name(cp_set_of_books_id IN NUMBER, cp_transaction_date IN DATE) IS
    SELECT gd.period_name
    FROM gl_ledgers gle, gl_periods gd
    WHERE gle.ledger_id = cp_set_of_books_id
    AND   gd.period_set_name = gle.period_set_name
    AND   cp_transaction_date BETWEEN gd.start_date and gd.end_date
    AND   gd.adjustment_period_flag = 'N';

  lv_statement_id       VARCHAR2(5);

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Defined variable for implementing caching logic.
   */
  l_func_curr_det     jai_plsql_cache_pkg.func_curr_details;
  ln_set_of_books_id  NUMBER;

BEGIN

/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_rcv_journal_pkg.sql
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     16/07/2002   Vijay Shankar for Bug# 3496408, Version:115.0
                    Table Handler coded for JAI_RCV_JOURNAL_ENTRIES table. Update_row of the package was just a skeleton that needs to be modified
                    whenever it is being used

2     10/11/2004   Vijay Shankar for Bug#4003518, Version:115.1
                    Modified the INSERT_ROW definition to DEFAULT 'N' for p_simulate_flag parameter. without this, its not a
                    problem in Oracle8i, however it is problem in 9i and thus the bugfix

3     19/03/2005   Vijay Shankar for Bug#4250236(4245089). FileVersion: 115.2
                    added two more parameters in insert_row procedure as part of VAT Implementation
4     28/11/2005   Hjujjuru for the bug 4762433 File version 120.3
                    added the who columns in the insert of jai_rcv_journals.
                    Dependencies Due to this bug:-
                    None
Dependencies
 IN60106 + 4245089
----------------------------------------------------------------------------------------------------------------------------*/

  ld_creation_date    := SYSDATE;
  ln_created_by       := FND_GLOBAL.user_id;
  ln_last_update_login :=  fnd_global.login_id; -- added, Harshita for Bug 4762433

  lv_statement_id := '1';
  IF p_period_name IS NULL OR p_organization_code IS NULL THEN
   /* Bug 5243532. Added by Lakshmi Gopalsami
    * Implemented caching logic for getting organization_code
    */
   l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                              (p_org_id  =>  p_organization_id);
   lv_organization_code  := l_func_curr_det.organization_code;
   ln_set_of_books_id    := l_func_curr_det.ledger_id;
   /* Bug 5243532. Added by Lakshmi Gopalsami
    * Passes ln_set_of_books_id instead of p_transaction_id
    */
    OPEN c_period_name(ln_set_of_books_id, trunc(p_transaction_date));
    FETCH c_period_name INTO lv_period_name;
    CLOSE c_period_name;
  END IF;

  lv_statement_id := '1.1';
  IF p_period_name IS NOT NULL THEN
    lv_period_name := p_period_name;
  END IF;
  IF p_organization_code IS NOT NULL THEN
    lv_organization_code := p_organization_code;
  END IF;

  lv_statement_id := '2';
  INSERT INTO JAI_RCV_JOURNAL_ENTRIES(JOURNAL_ENTRY_ID,
    ORGANIZATION_CODE,
    RECEIPT_NUM,
    TRANSACTION_ID,
    CREATION_DATE,
    TRANSACTION_DATE,
    SHIPMENT_LINE_ID,
    ACCT_TYPE,
    ACCT_NATURE,
    SOURCE_NAME,
    CATEGORY_NAME,
    CODE_COMBINATION_ID,
    ENTERED_DR,
    ENTERED_CR,
    TRANSACTION_TYPE,
    PERIOD_NAME,
    CREATED_BY,
    CURRENCY_CODE,
    CURRENCY_CONVERSION_TYPE,
    CURRENCY_CONVERSION_DATE,
    CURRENCY_CONVERSION_RATE,
    -- DUMMY_FLAG,
    /* following two parameters added by Vijay Shankar for Bug#4250236(JOURNAL_ENTRY_ID,4245089). VAT Implementation */
    reference_name,
    reference_id,
    -- following 3 parameters added by Harshita for Bug 4762433
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) VALUES (JAI_RCV_JOURNAL_ENTRIES_S.nextval,
    lv_organization_code,   -- P_ORGANIZATION_CODE,
    P_RECEIPT_NUM,
    P_TRANSACTION_ID,
    ld_creation_date,
    P_TRANSACTION_DATE,
    P_SHIPMENT_LINE_ID,
    P_ACCT_TYPE,
    P_ACCT_NATURE,
    P_SOURCE_NAME,
    P_CATEGORY_NAME,
    P_CODE_COMBINATION_ID,
    P_ENTERED_DR,
    P_ENTERED_CR,
    P_TRANSACTION_TYPE,
    lv_period_name,
    ln_created_by,
    P_CURRENCY_CODE,
    P_CURRENCY_CONVERSION_TYPE,
    P_CURRENCY_CONVERSION_DATE,
    P_CURRENCY_CONVERSION_RATE,
    -- p_simulate_flag,
    p_reference_name,
    p_reference_id,
    ln_created_by,  -- Harshita for Bug 4762433
    ld_creation_date , -- Harshita for Bug 4762433
    ln_last_update_login -- Harshita for Bug 4762433
  );

EXCEPTION
  WHEN OTHERS THEN
    p_process_status := 'E';
    p_process_message := 'RCV_JOURNALS_PKG.insert_row->'||SQLERRM||', StmtId->'||lv_statement_id;
    FND_FILE.put_line( FND_FILE.log, p_process_message);

END insert_row;

PROCEDURE update_row(

  P_ORGANIZATION_CODE             IN  JAI_RCV_JOURNAL_ENTRIES.organization_code%TYPE                        DEFAULT NULL,
  P_RECEIPT_NUM                   IN  JAI_RCV_JOURNAL_ENTRIES.receipt_num%TYPE                              DEFAULT NULL,
  P_TRANSACTION_ID                IN  JAI_RCV_JOURNAL_ENTRIES.transaction_id%TYPE                           DEFAULT NULL,
  P_CREATION_DATE                 IN  JAI_RCV_JOURNAL_ENTRIES.creation_date%TYPE                            DEFAULT NULL,
  P_TRANSACTION_DATE              IN  JAI_RCV_JOURNAL_ENTRIES.transaction_date%TYPE                         DEFAULT NULL,
  P_SHIPMENT_LINE_ID              IN  JAI_RCV_JOURNAL_ENTRIES.shipment_line_id%TYPE                         DEFAULT NULL,
  P_ACCT_TYPE                     IN  JAI_RCV_JOURNAL_ENTRIES.acct_type%TYPE                                DEFAULT NULL,
  P_ACCT_NATURE                   IN  JAI_RCV_JOURNAL_ENTRIES.acct_nature%TYPE                              DEFAULT NULL,
  P_SOURCE_NAME                   IN  JAI_RCV_JOURNAL_ENTRIES.source_name%TYPE                              DEFAULT NULL,
  P_CATEGORY_NAME                 IN  JAI_RCV_JOURNAL_ENTRIES.category_name%TYPE                            DEFAULT NULL,
  P_CODE_COMBINATION_ID           IN  JAI_RCV_JOURNAL_ENTRIES.code_combination_id%TYPE                      DEFAULT NULL,
  P_ENTERED_DR                    IN  JAI_RCV_JOURNAL_ENTRIES.entered_dr%TYPE                               DEFAULT NULL,
  P_ENTERED_CR                    IN  JAI_RCV_JOURNAL_ENTRIES.entered_cr%TYPE                               DEFAULT NULL,
  P_TRANSACTION_TYPE              IN  JAI_RCV_JOURNAL_ENTRIES.transaction_type%TYPE                         DEFAULT NULL,
  P_PERIOD_NAME                   IN  JAI_RCV_JOURNAL_ENTRIES.period_name%TYPE                              DEFAULT NULL,
  P_CREATED_BY                    IN  JAI_RCV_JOURNAL_ENTRIES.created_by%TYPE                               DEFAULT NULL,
  P_CURRENCY_CODE                 IN  JAI_RCV_JOURNAL_ENTRIES.currency_code%TYPE                            DEFAULT NULL,
  P_CURRENCY_CONVERSION_TYPE      IN  JAI_RCV_JOURNAL_ENTRIES.currency_conversion_type%TYPE                 DEFAULT NULL,
  P_CURRENCY_CONVERSION_DATE      IN  JAI_RCV_JOURNAL_ENTRIES.currency_conversion_date%TYPE                 DEFAULT NULL,
  P_CURRENCY_CONVERSION_RATE      IN  JAI_RCV_JOURNAL_ENTRIES.currency_conversion_rate%TYPE                 DEFAULT NULL
) IS
BEGIN

  UPDATE JAI_RCV_JOURNAL_ENTRIES SET
    ORGANIZATION_CODE             = nvl(P_ORGANIZATION_CODE, ORGANIZATION_CODE),
    RECEIPT_NUM                   = nvl(P_RECEIPT_NUM, RECEIPT_NUM),
    TRANSACTION_ID                = nvl(P_TRANSACTION_ID, TRANSACTION_ID),
    CREATION_DATE                 = nvl(P_CREATION_DATE, CREATION_DATE),
    TRANSACTION_DATE              = nvl(P_TRANSACTION_DATE, TRANSACTION_DATE),
    SHIPMENT_LINE_ID              = nvl(P_SHIPMENT_LINE_ID, SHIPMENT_LINE_ID),
    ACCT_TYPE                     = nvl(P_ACCT_TYPE, ACCT_TYPE),
    ACCT_NATURE                   = nvl(P_ACCT_NATURE, ACCT_NATURE),
    SOURCE_NAME                   = nvl(P_SOURCE_NAME, SOURCE_NAME),
    CATEGORY_NAME                 = nvl(P_CATEGORY_NAME, CATEGORY_NAME),
    CODE_COMBINATION_ID           = nvl(P_CODE_COMBINATION_ID, CODE_COMBINATION_ID),
    ENTERED_DR                    = nvl(P_ENTERED_DR, ENTERED_DR),
    ENTERED_CR                    = nvl(P_ENTERED_CR, ENTERED_CR),
    TRANSACTION_TYPE              = nvl(P_TRANSACTION_TYPE, TRANSACTION_TYPE),
    PERIOD_NAME                   = nvl(P_PERIOD_NAME, PERIOD_NAME),
    CREATED_BY                    = nvl(P_CREATED_BY, CREATED_BY),
    CURRENCY_CODE                 = nvl(P_CURRENCY_CODE, CURRENCY_CODE),
    CURRENCY_CONVERSION_TYPE      = nvl(P_CURRENCY_CONVERSION_TYPE, CURRENCY_CONVERSION_TYPE),
    CURRENCY_CONVERSION_DATE      = nvl(P_CURRENCY_CONVERSION_DATE, CURRENCY_CONVERSION_DATE),
    CURRENCY_CONVERSION_RATE      = nvl(P_CURRENCY_CONVERSION_RATE, CURRENCY_CONVERSION_RATE)
  WHERE transaction_id = p_transaction_id;

END update_row;

/*------------------------------------------------------------------------------------------------------------*/
PROCEDURE create_subledger_entry
(
  p_transaction_id number,
  p_organization_id number,
  p_currency_code varchar2,
  p_credit_amount number,
  p_debit_amount number,
  p_cc_id number,
  p_created_by number,
  p_accounting_date date default null,
  p_currency_conversion_date date default null,
  p_currency_conversion_type varchar2 default null,
  p_currency_conversion_rate number default null
 )IS

  v_last_update_login          number;
  v_creation_date              date;
  v_created_by                 number;
  v_last_update_date           date;
  v_last_updated_by            number;
  v_set_of_books_id            number;
  v_accounting_date            date;
  v_sysdate                    DATE; --  := SYSDATE;  File.Sql.35 by Brathod
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_rcv_journal_pkg.create_subledger_entry';

  Cursor sub_cur IS
    SELECT actual_flag,
           je_source_name,
           je_category_name,
           period_name,
           chart_of_accounts_id,
           functional_currency_code,
           je_batch_name,
           je_batch_description,
           je_header_name,
           je_line_description,
           reference1,
           reference2,
           reference3,
           reference4,
           source_doc_quantity
      FROM rcv_receiving_sub_ledger
     WHERE rcv_transaction_id = p_transaction_id
       AND rownum = 1;

  CURSOR rcv_cur IS
    SELECT source_document_code,
           shipment_line_id,
           po_line_location_id,
           requisition_line_id
      FROM rcv_transactions
     WHERE transaction_id = p_transaction_id;

  v_rcv_rec      rcv_cur % ROWTYPE;

  CURSOR ship_rec IS
    SELECT item_id
      FROM rcv_shipment_lines
     WHERE shipment_line_id = v_rcv_rec.shipment_line_id;

  v_sub_rec      sub_cur % ROWTYPE;
  v_item_id      rcv_shipment_lines.item_id % type;
  v_unit_price   number;
  v_amount       number;

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Defined variable for implementing caching logic.
   */
  l_func_curr_det     jai_plsql_cache_pkg.func_curr_details;

BEGIN
  v_sysdate := sysdate;  --File.Sql.35 by Brathod
  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed set_rec cursor and implemented caching logic.
   */
  l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                              (p_org_id  =>  p_organization_id);
  v_set_of_books_id    := l_func_curr_det.ledger_id;

  OPEN sub_cur;
    FETCH sub_cur INTO v_sub_rec;
  CLOSE sub_cur;

  IF v_sub_rec.je_source_name IS NOT NULL
  THEN

    OPEN rcv_cur;
      FETCH rcv_cur INTO v_rcv_rec;
    CLOSE rcv_cur;

    OPEN ship_rec;
      FETCH ship_rec INTO v_item_id;
    CLOSE ship_rec;

    IF v_rcv_rec.source_document_code = 'PO'
    THEN
      For price_rec IN (SELECT price_override
                          FROM po_line_locations_all
                         WHERE line_location_id = v_rcv_rec.po_line_location_id)
      LOOP
        v_unit_price := price_rec.price_override;
      END LOOP;
    ELSIF v_rcv_rec.source_document_code = 'INVENTORY'
    THEN
      For price_rec IN (SELECT list_price_per_unit price
                          FROM mtl_system_items
                         WHERE inventory_item_id = v_item_id
                           AND organization_id = p_organization_id)
      LOOP
        v_unit_price := price_rec.price;
      END LOOP;
    ELSIF v_rcv_rec.source_document_code = 'REQ'
    THEN
      For price_rec IN (SELECT unit_price
                          FROM po_requisition_lines_all
                         WHERE requisition_line_id = v_rcv_rec.requisition_line_id)
      LOOP
        v_unit_price := price_rec.unit_price;
      END LOOP;
    END IF;

    v_amount := NVL(p_credit_amount, p_debit_amount);

    IF v_amount is NOT NULL and v_unit_price <> 0 -- Added by Ramakrishna to overcome zero divide
    THEN
       v_amount := v_amount / v_unit_price;
    END IF;

    IF p_accounting_date is null
    THEN
      v_accounting_date := v_sysdate;
    ELSE
      v_accounting_date := p_accounting_date;
    END IF;

    IF NVL(p_credit_amount, 0) <> 0 OR
       NVL(p_debit_amount, 0) <> 0
    THEN
      INSERT into JAI_RCV_SUBLED_ENTRIES
             (SUBLED_ENTRY_ID,rcv_transaction_id,
              set_of_books_id,
              je_source_name,
              je_category_name,
              accounting_date,
              currency_code,
              date_created_in_gl,
              entered_cr,
              entered_dr,
              transaction_date,
              code_combination_id,
              currency_conversion_date,
              user_currency_conversion_type,
              currency_conversion_rate,
              actual_flag,
              period_name,
              chart_of_accounts_id,
              functional_currency_code,
              je_batch_name,
              je_batch_description,
              je_header_name,
              je_line_description,
              reference1,
              reference2,
              reference3,
              reference4,
              source_doc_quantity,
              created_by,
              creation_date,
              last_update_date,
              last_updated_by,
              last_update_login,
              from_type,
        PROGRAM_LOGIN_ID)
      VALUES ( JAI_RCV_SUBLED_ENTRIES_S.nextval, p_transaction_id,
              v_set_of_books_id,
              v_sub_rec.je_source_name,
              v_sub_rec.je_category_name,
              v_accounting_date,
              p_currency_code,
              v_sysdate,
              p_credit_amount,
              p_debit_amount,
              v_accounting_date,
              p_cc_id,
              p_currency_conversion_date,
              p_currency_conversion_type,
              p_currency_conversion_rate,
              v_sub_rec.actual_flag,
              v_sub_rec.period_name,
              v_sub_rec.chart_of_accounts_id,
              v_sub_rec.functional_currency_code,
              v_sub_rec.je_batch_name,
              v_sub_rec.je_batch_description,
              v_sub_rec.je_header_name,
              v_sub_rec.je_line_description,
              v_sub_rec.reference1,
              v_sub_rec.reference2,
              v_sub_rec.reference3,
              v_sub_rec.reference4,
              v_amount,
              p_created_by,
              v_sysdate,
              v_sysdate,
              p_created_by,
              p_created_by,
              'L',
        fnd_profile.value('PROG_APPL_ID'));
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END create_subledger_entry;

END jai_rcv_journal_pkg;

/
