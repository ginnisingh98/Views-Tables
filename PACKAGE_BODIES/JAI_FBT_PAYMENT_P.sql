--------------------------------------------------------
--  DDL for Package Body JAI_FBT_PAYMENT_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_FBT_PAYMENT_P" AS
--$Header: jainfbtpay.plb 120.0.12010000.1 2008/11/27 07:10:32 huhuliu noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     jainfbtpay.plb                                                     |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     To be called by the concurrent program for inserting the          |
--|      data into jai_fbt_payment table and  ap interface tables         |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Insert_Fbt_Payment                                     |
--|      PROCEDURE Insert_Interface_Table                                 |
--|      PROCEDURE Fbt_Payment                                            |
--|                                                                       |
--| HISTORY                                                               |
--|     2008/10/21 Eric Ma       Created                                  |
--+======================================================================*/

--==========================================================================
--  PROCEDURE NAME:
--
--    Insert_Fbt_Payment                        Private
--
--  DESCRIPTION:
--
--    This procedure is to insert the data into jai_fbt_payment
--
--  PARAMETERS:
--      In:  p_fbt_payment jai_fbt_repository record type
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           18-OCT-2007   Eric Ma  created

PROCEDURE Insert_Fbt_Payment
( p_fbt_payment IN jai_fbt_payment%ROWTYPE
)
IS
lv_procedure_name VARCHAR2(40):='Insert_Fbt_Payment';
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

  -- insert into jai_fbt_payment
  INSERT INTO jai_fbt_payment
              ( fbt_payment_id
              , legal_entity_id
              , fbt_year
              , status_date
              , invoice_reference
              , invoice_date
              , inv_supplier_id
              , inv_supplier_site_id
              , inv_ou_id
              , creation_date
              , created_by
              , last_update_date
              , last_updated_by
              , last_update_login
              , deposit_date
              , bank_name
              , branch_name
              , it_challan
              , bsr_code
              , fbt_tax_amount
              , fbt_surcharge_amount
              , fbt_edu_cess_amount
              , fbt_sh_cess_amount
              )

  VALUES      ( p_fbt_payment.fbt_payment_id
              , p_fbt_payment.legal_entity_id
              , p_fbt_payment.fbt_year
              , p_fbt_payment.status_date
              , p_fbt_payment.invoice_reference
              , p_fbt_payment.invoice_date
              , p_fbt_payment.inv_supplier_id
              , p_fbt_payment.inv_supplier_site_id
              , p_fbt_payment.inv_ou_id
              , p_fbt_payment.creation_date
              , p_fbt_payment.created_by
              , p_fbt_payment.last_update_date
              , p_fbt_payment.last_updated_by
              , p_fbt_payment.last_update_login
              , p_fbt_payment.deposit_date
              , p_fbt_payment.bank_name
              , p_fbt_payment.branch_name
              , p_fbt_payment.it_challan
              , p_fbt_payment.bsr_code
              , p_fbt_payment.fbt_tax_amount
              , p_fbt_payment.fbt_surcharge_amount
              , p_fbt_payment.fbt_edu_cess_amount
              , p_fbt_payment.fbt_sh_cess_amount
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
END Insert_Fbt_Payment;

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
--           18-OCT-2007   Eric Ma  created

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
--    Fbt_Payment                        Public
--
--  DESCRIPTION:
--
--    This is the main procedure which will be called by the concurrent
--    program  for inserting the data into jai_fbt_payment table and
--    ap interface tables
--
--  PARAMETERS:
--     In:   pn_legal_entity_id        Identifier of legal entity
--           pn_fbt_year               Fbt year
--           pn_fbt_amount             Total fbt tax amount
--           pn_supplier_id            Identifier of supplier
--           pn_supplier_site_id       Identifier of supplier site
--           pn_ou_id                  Identifier of Operating unit
--           pn_fbt_tax_amount         The amount of fbt tax
--           pn_fbt_surcharge_amount   The amount of surcharge tax
--           pn_fbt_edu_cess_amount    The amount of edu cess tax
--           pn_fbt_sh_cess_amount     The amount of sh cess tax
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
--           21-OCT-2008   Eric Ma  created

PROCEDURE Fbt_Payment
( pv_errbuf                OUT NOCOPY VARCHAR2
, pv_retcode               OUT NOCOPY VARCHAR2
, pn_legal_entity_id       IN  jai_fbt_payment.legal_entity_id%TYPE
, pn_fbt_year              IN  jai_fbt_payment.fbt_year%TYPE
, pn_fbt_amount            IN  NUMBER
, pn_supplier_id           IN  jai_fbt_payment.inv_supplier_id%TYPE
, pn_supplier_site_id      IN  jai_fbt_payment.inv_supplier_site_id%TYPE
, pn_ou_id                 IN  jai_fbt_payment.inv_ou_id%TYPE
, pn_fbt_tax_amount        IN  jai_fbt_payment.fbt_tax_amount%TYPE
, pn_fbt_surcharge_amount  IN  jai_fbt_payment.fbt_surcharge_amount%TYPE
, pn_fbt_edu_cess_amount   IN  jai_fbt_payment.fbt_edu_cess_amount%TYPE
, pn_fbt_sh_cess_amount    IN  jai_fbt_payment.fbt_sh_cess_amount%TYPE
, pv_status_date           IN  VARCHAR2
)
IS
--ln_org_id               NUMBER;
ln_invoice_amout        NUMBER;
fbt_payment_rec         jai_fbt_payment%ROWTYPE;
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
lv_date_mask            VARCHAR2(11) :='YYYY-MON-DD';
pn_invoice_number_seq   NUMBER;
ld_invoice_date         DATE :=SYSDATE;
ld_status_date          DATE :=TRUNC(FND_DATE.DISPLAYDT_TO_DATE(pv_status_date));
ln_fbt_payment_id       NUMBER;

lv_procedure_name       VARCHAR2(40):='Fbt_Payment';
ln_dbg_level            NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level           NUMBER:=FND_LOG.LEVEL_PROCEDURE;

CURSOR po_vendors_cur IS
SELECT
--  pvsa.org_id,
  pvsa.accts_pay_code_combination_id
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


--modified by eric for R12.1  21-Oct-2008,begin
-----------------------------------------------------------------------------------
/*
CURSOR currency_code_cur
IS
SELECT
  gsob.currency_code
FROM
  gl_sets_of_books   gsob
WHERE gsob.set_of_books_id IN
      ( SELECT
          org_information3 --set of book id
        FROM
          hr_organization_information b
        WHERE b.org_information2 = pn_legal_entity_id --LEGAL ENTITY ID
          AND b.ORG_INFORMATION_CONTEXT='Operating Unit Information'
       );
*/
-----------------------------------------------------------------------------------
--modified by eric for R12.1  21-Oct-2008,end

ln_fbt_acct_ccid ap_invoice_lines_interface.dist_code_combination_id%TYPE;

CURSOR get_fbt_account_ccid_cur
IS
SELECT fbt_account_ccid
  FROM JAI_FBT_SETUP_HEADERS
 WHERE legal_entity_id = pn_legal_entity_id
   and fbt_year        = pn_fbt_year;

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --l_proc_level>=l_dbg_level

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

  -- get invoice_id for ap_invoices_interface,ap_invoice_lines_interface
  -- and JAI_FBT_PAYMENT
  SELECT
    ap_invoices_interface_s.nextval
  INTO
    ln_invoice_id
  FROM dual;

  -- get the payment id
  SELECT jai_fbt_payment_s.NEXTVAL
  INTO ln_fbt_payment_id
  FROM dual;

  -- get the org id, accts_pay_code_combination_id, payment_method_lookup_code
  OPEN po_vendors_cur;
  FETCH po_vendors_cur
  INTO
  --  ln_org_id,
  ln_accts_pay_ccid
  , lv_payment_method_code;
  CLOSE po_vendors_cur;

  --add lock on the jai_fbt_payment table
  UPDATE
    jai_fbt_payment
  SET
    invoice_date = invoice_date
  WHERE TRUNC(invoice_date)  = TRUNC(invoice_date)
    AND legal_entity_id      = pn_legal_entity_id;

  -- get the sequence number for invoice number
  SELECT
    COUNT(fbt_payment_id)+1
  INTO
    pn_invoice_number_seq
  FROM
    jai_fbt_payment
  WHERE TRUNC(invoice_date) = TRUNC(ld_invoice_date)
    AND legal_entity_id     = pn_legal_entity_id;

  SELECT 'FBT/Invoice/'||pn_legal_entity_id||'/'|| TO_CHAR(ld_invoice_date,lv_date_mask)||'/'|| pn_invoice_number_seq
  INTO ln_invoice_num
  FROM dual;

  -- insert the data into the table jai_fbt_payment
  fbt_payment_rec.fbt_payment_id       := ln_fbt_payment_id;
  fbt_payment_rec.legal_entity_id      := pn_legal_entity_id;
  fbt_payment_rec.fbt_year             := pn_fbt_year;
  fbt_payment_rec.status_date          := ld_status_date;

  fbt_payment_rec.invoice_reference    := ln_invoice_num;
  fbt_payment_rec.invoice_date         := ld_invoice_date;
  fbt_payment_rec.inv_supplier_id      := pn_supplier_id;
  fbt_payment_rec.inv_supplier_site_id := pn_supplier_site_id;
  fbt_payment_rec.inv_ou_id            := pn_ou_id;

  fbt_payment_rec.FBT_TAX_AMOUNT       := pn_fbt_tax_amount       ;
  fbt_payment_rec.FBT_SURCHARGE_AMOUNT := pn_fbt_surcharge_amount ;
  fbt_payment_rec.FBT_EDU_CESS_AMOUNT  := pn_fbt_edu_cess_amount  ;
  fbt_payment_rec.FBT_SH_CESS_AMOUNT   := pn_fbt_sh_cess_amount   ;

  --leave the below 5 fileds blank in the insert action
  --fbt_payment_rec.it_challan           := NULL;
  --fbt_payment_rec.bank_name            := NULL;
  --fbt_payment_rec.branch_name          := NULL;
  --fbt_payment_rec.deposit_date         := '';
  --fbt_payment_rec.bsr_code             := NULL;
  ------------------------------------------------------------------

  fbt_payment_rec.creation_date        := SYSDATE;
  fbt_payment_rec.created_by           := ln_user_id;
  fbt_payment_rec.last_update_date     := SYSDATE;
  fbt_payment_rec.last_updated_by      := ln_user_id;
  fbt_payment_rec.last_update_login    := ln_login_id;

  Insert_Fbt_Payment(fbt_payment_rec);

  -- get currency code
   OPEN currency_code_cur;
  FETCH currency_code_cur
   INTO lv_currency_code;
  CLOSE currency_code_cur;

  ln_invoice_amout := ROUND(pn_fbt_amount, ln_precision);

  inv_interface_rec.invoice_id                 := ln_invoice_id;
  inv_interface_rec.invoice_num                := ln_invoice_num;
  inv_interface_rec.invoice_date               := ld_invoice_date;
  inv_interface_rec.vendor_id                  := pn_supplier_id;
  inv_interface_rec.vendor_site_id             := pn_supplier_site_id;
  inv_interface_rec.invoice_amount             := ln_invoice_amout;
  inv_interface_rec.invoice_currency_code      := lv_currency_code;
  inv_interface_rec.accts_pay_ccid             := ln_accts_pay_ccid;
  inv_interface_rec.source                     := 'FBT';
  --Replace the searched result with input parameter
  --Modified by Eric Ma for FBT 12.1  on 2008-11-18
  --inv_interface_rec.org_id                   := ln_org_id;
  inv_interface_rec.org_id                     := pn_ou_id;
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

  --added by eric ma for bug 7325833 on 18-Aug-2008,begin
  -----------------------------------------------------------------------------------
  OPEN   get_fbt_account_ccid_cur;
  FETCH  get_fbt_account_ccid_cur
   INTO  ln_fbt_acct_ccid;
  CLOSE  get_fbt_account_ccid_cur;
  -----------------------------------------------------------------------------------
  --added by eric ma for bug 7325833 on 18-Aug-2008,end

  inv_lines_interface_rec.invoice_id               := ln_invoice_id;
  inv_lines_interface_rec.invoice_line_id          := ln_invoice_line_id;
  inv_lines_interface_rec.line_number              := 1;
  inv_lines_interface_rec.line_type_lookup_code    := 'ITEM';
  inv_lines_interface_rec.amount                   := ln_invoice_amout;
  inv_lines_interface_rec.accounting_date          := SYSDATE;
  inv_lines_interface_rec.description              := 'Invoice for FBT Payment';
  --added by eric ma for bug 7325833 on 18-Aug-2008,begin
  -----------------------------------------------------------------------------------
  --inv_lines_interface_rec.dist_code_combination_id := ln_accts_pay_ccid;
  inv_lines_interface_rec.dist_code_combination_id :=ln_fbt_acct_ccid;
  -----------------------------------------------------------------------------------
  --added by eric ma for bug 7325833 on 18-Aug-2008,end

  --Replace the searched result with input parameter
  --Modified by Eric Ma for FBT 12.1  on 2008-11-18
  --inv_lines_interface_rec.org_id                 := ln_org_id;
  inv_interface_rec.org_id                         := pn_ou_id;
  inv_lines_interface_rec.creation_date            := SYSDATE;
  inv_lines_interface_rec.created_by               := ln_user_id;
  inv_lines_interface_rec.last_update_date         := SYSDATE;
  inv_lines_interface_rec.last_updated_by          := ln_user_id;
  inv_lines_interface_rec.last_update_login        := ln_login_id;

  Insert_Interface_Table( inv_interface_rec
                          , inv_lines_interface_rec
                          );

  COMMIT;
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
    pv_retcode    :=2;
    pv_errbuf  := Sqlerrm;
    ROLLBACK;
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
END Fbt_Payment;

END JAI_FBT_PAYMENT_P;

/
