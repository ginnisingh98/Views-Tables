--------------------------------------------------------
--  DDL for Package Body JAI_FBT_SETTLEMENT_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_FBT_SETTLEMENT_P" AS
--$Header: jainfbtset.plb 120.2 2008/06/04 02:28:20 jianliu noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     jai_fbt_settlement_p.pls                                          |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     To be called by the concurrent program for inserting the          |
--|      data into jai_fbt_settlement table and  ap interface tables      |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Insert_Fbt_Settlement                                  |
--|      PROCEDURE Insert_Interface_Table                                 |
--|      PROCEDURE Fbt_Settlement                                         |
--|                                                                       |
--| HISTORY                                                               |
--|     2007/10/18 Jason Liu     Created                                  |
--|                                                                       |
--+======================================================================*/

--==========================================================================
--  PROCEDURE NAME:
--
--    Insert_Fbt_Settlement                        Private
--
--  DESCRIPTION:
--
--    This procedure is to insert the data into jai_fbt_settlement
--
--  PARAMETERS:
--      In:  p_fbt_settlement jai_fbt_repository record type
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           18-OCT-2007   Jason Liu  created

PROCEDURE Insert_Fbt_Settlement
( p_fbt_settlement IN jai_fbt_settlement%ROWTYPE
)
IS
lv_procedure_name VARCHAR2(40):='Insert_Fbt_Settlement';
ln_dbg_level      NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level     NUMBER:=FND_LOG.LEVEL_PROCEDURE;

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level

  -- insert into jai_fbt_settlement
  INSERT INTO jai_fbt_settlement
              ( legal_entity_id
              , period_start_date
              , period_end_date
              , consolidated_amount
              , projected_amount
              , settlement_date
              , inv_supplier_id
              , inv_supplier_site_id
              , inv_ou_id
              , it_challan
              , return_generate_flag
              , creation_date
              , created_by
              , last_update_date
              , last_updated_by
              , last_update_login
              , deposit_date
              , bank_name
              , branch_name
              , settlement_id
              )
  VALUES      ( p_fbt_settlement.legal_entity_id
              , p_fbt_settlement.period_start_date
              , p_fbt_settlement.period_end_date
              , p_fbt_settlement.consolidated_amount
              , p_fbt_settlement.projected_amount
              , p_fbt_settlement.settlement_date
              , p_fbt_settlement.inv_supplier_id
              , p_fbt_settlement.inv_supplier_site_id
              , p_fbt_settlement.inv_ou_id
              , p_fbt_settlement.it_challan
              , p_fbt_settlement.return_generate_flag
              , p_fbt_settlement.creation_date
              , p_fbt_settlement.created_by
              , p_fbt_settlement.last_update_date
              , p_fbt_settlement.last_updated_by
              , p_fbt_settlement.last_update_login
              , p_fbt_settlement.deposit_date
              , p_fbt_settlement.bank_name
              , p_fbt_settlement.branch_name
              , p_fbt_settlement.settlement_id
              );

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
END Insert_Fbt_Settlement;

--==========================================================================
--  PROCEDURE NAME:
--
--    Insert_Interface_Table                        Private
--
--  DESCRIPTION:
--
--    This procedure is to ap_invoices_interface,
--    ap_invoice_lines_interface tables
--
--  PARAMETERS:
--      In:  p_inv_interface       inv_interface_rec_type record type
--           p_inv_lines_interface inv_lines_interface_rec_type record type
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           18-OCT-2007   Jason Liu  created

PROCEDURE Insert_Interface_Table
( p_inv_interface       IN inv_interface_rec_type
, p_inv_lines_interface IN inv_lines_interface_rec_type
)
IS
lv_procedure_name VARCHAR2(40):='Insert_Interface_Table';
ln_dbg_level      NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level     NUMBER:=FND_LOG.LEVEL_PROCEDURE;

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level

  -- insert into ap_invoices_interface
  INSERT INTO ap_invoices_interface
              ( invoice_id
              , invoice_num
              , invoice_date
              , vendor_id
              , vendor_site_id
              , invoice_amount
              , invoice_currency_code
              , accts_pay_code_combination_id
              , source
              , org_id
              , legal_entity_id
              , payment_method_lookup_code
              , created_by
              , creation_date
              , last_updated_by
              , last_update_date
              , last_update_login
              )
  VALUES      ( p_inv_interface.invoice_id
              , p_inv_interface.invoice_num
              , p_inv_interface.invoice_date
              , p_inv_interface.vendor_id
              , p_inv_interface.vendor_site_id
              , p_inv_interface.invoice_amount
              , p_inv_interface.invoice_currency_code
              , p_inv_interface.accts_pay_ccid
              , p_inv_interface.source
              , p_inv_interface.org_id
              , p_inv_interface.legal_entity_id
              , p_inv_interface.payment_method_lookup_code
              , p_inv_interface.created_by
              , p_inv_interface.creation_date
              , p_inv_interface.last_updated_by
              , p_inv_interface.last_update_date
              , p_inv_interface.last_update_login
              );

  -- insert into ap_invoice_lines_interface
  INSERT INTO ap_invoice_lines_interface
              ( invoice_id
              , invoice_line_id
              , line_number
              , line_type_lookup_code
              , amount
              , accounting_date
              , description
              , dist_code_combination_id
              , org_id
              , created_by
              , creation_date
              , last_updated_by
              , last_update_date
              , last_update_login
              )
  VALUES      ( p_inv_lines_interface.invoice_id
              , p_inv_lines_interface.invoice_line_id
              , p_inv_lines_interface.line_number
              , p_inv_lines_interface.line_type_lookup_code
              , p_inv_lines_interface.amount
              , p_inv_lines_interface.accounting_date
              , p_inv_lines_interface.description
              , p_inv_lines_interface.dist_code_combination_id
              , p_inv_lines_interface.org_id
              , p_inv_lines_interface.created_by
              , p_inv_lines_interface.creation_date
              , p_inv_lines_interface.last_updated_by
              , p_inv_lines_interface.last_update_date
              , p_inv_lines_interface.last_update_login
              );
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
END Insert_Interface_Table;

--==========================================================================
--  PROCEDURE NAME:
--
--    Fbt_Settlement                        Public
--
--  DESCRIPTION:
--
--    This is the main procedure which will be called by the concurrent
--    program  for inserting the data into jai_fbt_settlement table and
--    ap interface tables
--
--  PARAMETERS:
--      In:  pn_legal_entity_id  Identifier of legal entity
--           pv_start_date       Identifier of period start date
--           pv_end_date         Identifier of period end date
--           pn_projected_amount Identifier of projected FBT amount
--           pn_supplier_id      Identifier of supplier id
--           pn_supplier_site_id Identifier of supplier site id
--
--      Out: pv_errbuf           Returns the error if concurrent program
--                               does not execute completely
--           pv_retcode          Returns success or failure
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           18-OCT-2007   Jason Liu  created
--           04-Jun-2008   Jia Li   Modified for bug#7146038
--                Issue: Running settlement for different legal entity with one Period,
--                       the invoice number in AP interface was the same.
--                Fixed: Modified invoice number to 'FBT/Invoice/legal_entity_id/end_date'

PROCEDURE Fbt_Settlement
( pv_errbuf           OUT NOCOPY VARCHAR2
, pv_retcode          OUT NOCOPY VARCHAR2
, pn_legal_entity_id  IN  jai_fbt_settlement.legal_entity_id%TYPE
, pv_start_date       IN  VARCHAR2
, pv_end_date         IN  VARCHAR2
, pn_projected_amount IN  jai_fbt_settlement.Projected_Amount%TYPE
, pn_supplier_id      IN  jai_fbt_settlement.inv_supplier_id%TYPE
, pn_supplier_site_id IN jai_fbt_settlement.inv_supplier_site_id%TYPE
)
IS
lv_start_date           VARCHAR2(30);
lv_end_date             VARCHAR2(30);
ld_start_date           DATE;
ld_end_date             DATE;
lv_jan                  VARCHAR2(2);
lv_return_generate_flag VARCHAR2(1);
ln_org_id               NUMBER;
lv_settled_flag         VARCHAR2(1);
ln_settlement_id        NUMBER;
ln_consolidated_amount  NUMBER;
ln_invoice_amout        NUMBER;
fbt_settlement_rec      jai_fbt_settlement%ROWTYPE;
ln_invoice_id           ap_invoices_interface.invoice_id%TYPE;
ln_invoice_num          ap_invoices_interface.invoice_num%TYPE;
lv_currency_code        ap_invoices_interface.invoice_currency_code%TYPE;
ln_accts_pay_ccid       ap_invoices_interface.accts_pay_code_combination_id%TYPE;
lv_payment_method_code  ap_invoices_interface.payment_method_lookup_code%TYPE;
ln_invoice_line_id      ap_invoice_lines_interface.invoice_line_id%TYPE;
inv_interface_rec       inv_interface_rec_type;
inv_lines_interface_rec inv_lines_interface_rec_type;
ln_user_id              NUMBER := fnd_global.user_id;
ln_login_id             NUMBER := fnd_global.login_id;
ln_precision            NUMBER;
lv_procedure_name       VARCHAR2(40):='Fbt_Settlement';
ln_dbg_level            NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level           NUMBER:=FND_LOG.LEVEL_PROCEDURE;

CURSOR cummulative_tax_cur IS
SELECT SUM(fbt_tax_amount) + SUM(fbt_surcharge_amount)
         + SUM(fbt_edu_cess_amount) + SUM(fbt_sh_cess_amount)
FROM jai_fbt_repository
WHERE legal_entity_id = pn_legal_entity_id
  AND period_start_date = ld_start_date
  AND period_end_date = ld_end_date;

-- Check if settled for this period
CURSOR check_settled IS
SELECT 1
FROM dual
WHERE EXISTS( SELECT 1
              FROM jai_fbt_settlement
              WHERE legal_entity_id = pn_legal_entity_id
              AND period_start_date = ld_start_date
              AND period_end_date = ld_end_date);

CURSOR po_vendors_cur IS
SELECT
  pvsa.org_id
, pvsa.accts_pay_code_combination_id
, pvsa.payment_method_lookup_code
FROM po_vendor_sites_all pvsa
WHERE pvsa.vendor_site_id = pn_supplier_site_id;

CURSOR currency_code_cur IS
SELECT
  gsob.currency_code
FROM
  gl_sets_of_books   gsob
, xle_fp_ou_ledger_v xfolv
WHERE gsob.set_of_books_id = xfolv.ledger_id
  AND xfolv.legal_entity_id = pn_legal_entity_id;

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level

  lv_start_date    := pv_start_date;
  lv_end_date      := pv_end_date;
  -- change from VARCHAR2 to DATE type
  ld_start_date    := TO_DATE(lv_start_date, GV_DATE_MASK);
  ld_end_date      := TO_DATE(lv_end_date, GV_DATE_MASK);

  OPEN check_settled;
  FETCH check_settled
  INTO lv_settled_flag;
  CLOSE check_settled;

  IF(NVL(lv_settled_flag, 0) = 1) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Already run the settlement for this period.');
  ELSE
    -- get the precision
    SELECT
      NVL(fc.precision, 2)
    INTO
      ln_precision
    FROM
      gl_sets_of_books gsob
    , fnd_currencies   fc
    WHERE gsob.set_of_books_id = fnd_profile.VALUE('GL_SET_OF_BKS_ID')
      AND gsob.currency_code = fc.currency_code;

    SELECT
      TO_CHAR(ld_start_date,'MM')
    INTO
      lv_jan
    FROM
      dual;
    -- get the return_generate_flag
    IF (lv_jan = '01')
    THEN
      lv_return_generate_flag := 'Y';
    ELSE
      lv_return_generate_flag := 'N';
    END IF; -- ((TO_CHAR(lv_constant_date,'MM')) = '01')

    -- get the consolidated_amount
    OPEN cummulative_tax_cur;
    FETCH cummulative_tax_cur
    INTO ln_consolidated_amount;
    CLOSE cummulative_tax_cur;

    -- get the org id, accts_pay_code_combination_id, payment_method_lookup_code
    OPEN po_vendors_cur;
    FETCH po_vendors_cur
    INTO
      ln_org_id
    , ln_accts_pay_ccid
    , lv_payment_method_code;
    CLOSE po_vendors_cur;

    -- get the settlement id
    SELECT jai_fbt_settlement_s.NEXTVAL
    INTO ln_settlement_id
    FROM dual;

    -- insert the data into the table jai_fbt_settlement
    fbt_settlement_rec.legal_entity_id      := pn_legal_entity_id;
    fbt_settlement_rec.period_start_date    := ld_start_date;
    fbt_settlement_rec.period_end_date      := ld_end_date;
    fbt_settlement_rec.consolidated_amount  := NVL(ln_consolidated_amount, 0);
    IF (lv_jan = '01')
    THEN
      fbt_settlement_rec.projected_amount   := ROUND(NVL(pn_projected_amount, 0), ln_precision);
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Projected FBT Amount will be considered only for the period commencing from 01-JAN.');
    END IF; -- (lv_jan = '01')
    fbt_settlement_rec.settlement_date      := SYSDATE;
    fbt_settlement_rec.inv_supplier_id      := pn_supplier_id;
    fbt_settlement_rec.inv_supplier_site_id := pn_supplier_site_id;
    fbt_settlement_rec.inv_ou_id            := ln_org_id;
    fbt_settlement_rec.it_challan           := NULL;
    fbt_settlement_rec.return_generate_flag := lv_return_generate_flag;
    fbt_settlement_rec.creation_date        := SYSDATE;
    fbt_settlement_rec.created_by           := ln_user_id;
    fbt_settlement_rec.last_update_date     := SYSDATE;
    fbt_settlement_rec.last_updated_by      := ln_user_id;
    fbt_settlement_rec.last_update_login    := ln_login_id;
    fbt_settlement_rec.settlement_id        := ln_settlement_id;

    Insert_Fbt_Settlement(fbt_settlement_rec);

    -- update all the transactions in the jai_fbt_repository
    -- with the settlement_id created above

    UPDATE jai_fbt_repository
    SET settlement_id = ln_settlement_id
    WHERE legal_entity_id = pn_legal_entity_id
      AND period_start_date = ld_start_date
      AND period_end_date = ld_end_date;

    -- insert the data into the table ap_invoices_interface and
    -- ap_invoice_lines_interface
    -- get invoice id
    SELECT ap_invoices_interface_s.nextval
    INTO ln_invoice_id
    FROM dual;

    -- get invoice num
--    SELECT 'FBT/Invoice/' || TO_CHAR(ld_end_date)
    SELECT 'FBT/Invoice/'||pn_legal_entity_id||'/'|| TO_CHAR(ld_end_date)  -- Modified by jia for bug#7146038 on 2008/06/04
    INTO ln_invoice_num
    FROM dual;

    -- get currency code
    OPEN currency_code_cur;
    FETCH currency_code_cur
    INTO lv_currency_code;
    CLOSE currency_code_cur;

    IF (lv_jan = '01')
    THEN
      ln_invoice_amout := ln_consolidated_amount + NVL(pn_projected_amount, 0);
    ELSE
      ln_invoice_amout := ln_consolidated_amount;
    END IF; --(lv_jan = '01')
    ln_invoice_amout := ROUND(ln_invoice_amout, ln_precision);
    inv_interface_rec.invoice_id                 := ln_invoice_id;
    inv_interface_rec.invoice_num                := ln_invoice_num;
    inv_interface_rec.invoice_date               := SYSDATE;
    inv_interface_rec.vendor_id                  := pn_supplier_id;
    inv_interface_rec.vendor_site_id             := pn_supplier_site_id;
    inv_interface_rec.invoice_amount             := ln_invoice_amout;
    inv_interface_rec.invoice_currency_code      := lv_currency_code;
    inv_interface_rec.accts_pay_ccid             := ln_accts_pay_ccid;
    inv_interface_rec.source                     := 'FBT';
    inv_interface_rec.org_id                     := ln_org_id;
    inv_interface_rec.legal_entity_id            := pn_legal_entity_id;
    inv_interface_rec.payment_method_lookup_code := lv_payment_method_code;
    inv_interface_rec.creation_date              := SYSDATE;
    inv_interface_rec.created_by                 := ln_user_id;
    inv_interface_rec.last_update_date           := SYSDATE;
    inv_interface_rec.last_updated_by            := ln_user_id;
    inv_interface_rec.last_update_login          := ln_login_id;

    -- ap_invoice_lines_interface
    -- get invoice line id
    SELECT ap_invoice_lines_interface_s.nextval
    INTO ln_invoice_line_id
    FROM dual;

    inv_lines_interface_rec.invoice_id               := ln_invoice_id;
    inv_lines_interface_rec.invoice_line_id          := ln_invoice_line_id;
    inv_lines_interface_rec.line_number              := 1;
    inv_lines_interface_rec.line_type_lookup_code    := 'ITEM';
    inv_lines_interface_rec.amount                   := ln_invoice_amout;
    inv_lines_interface_rec.accounting_date          := SYSDATE;
    inv_lines_interface_rec.description              := 'Invoice for FBT Payment';
    inv_lines_interface_rec.dist_code_combination_id := ln_accts_pay_ccid;
    inv_lines_interface_rec.org_id                   := ln_org_id;
    inv_lines_interface_rec.creation_date            := SYSDATE;
    inv_lines_interface_rec.created_by               := ln_user_id;
    inv_lines_interface_rec.last_update_date         := SYSDATE;
    inv_lines_interface_rec.last_updated_by          := ln_user_id;
    inv_lines_interface_rec.last_update_login        := ln_login_id;

    Insert_Interface_Table( inv_interface_rec
                          , inv_lines_interface_rec
                          );
  END IF; --(NVL(lv_settled_flag, 0) = 1)

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
END Fbt_Settlement;

END JAI_FBT_SETTLEMENT_P;

/
