--------------------------------------------------------
--  DDL for Package Body GL_SEL_SEG_TURNOVER_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_SEL_SEG_TURNOVER_RPT_PKG" AS
-- $Header: glxssegb.pls 120.0.12000000.1 2007/10/23 16:28:37 sgudupat noship $
--=====================================================================
--=====================================================================
PROCEDURE gl_get_effective_num (p_ledger_id    IN  NUMBER
                               ,p_period_name  IN  VARCHAR2
                               ,x_per_eff_num  OUT NOCOPY NUMBER
                               ,x_errbuf       OUT NOCOPY VARCHAR2)
IS
  lc_ledger_obj_type  VARCHAR2(1);
  ln_single_ledger_id NUMBER;
BEGIN
  SELECT gl1.object_type_code
  INTO   lc_ledger_obj_type
  FROM   gl_ledgers gl1
  WHERE  gl1.ledger_id = p_ledger_id;

  IF (lc_ledger_obj_type = 'L') THEN
    ln_single_ledger_id := p_ledger_id;
  ELSE
    SELECT gl1.ledger_id
    INTO   ln_single_ledger_id
    FROM   gl_ledger_set_assignments glsa
          ,gl_ledgers                gl1
    WHERE  glsa.ledger_set_id   = p_ledger_id
    AND    gl1.ledger_id        = glsa.ledger_id
    AND    gl1.object_type_code = 'L'
    AND    ROWNUM               = 1;
  END IF;

  SELECT gps.effective_period_num
  INTO   x_per_eff_num
  FROM   gl_period_statuses gps
  WHERE  gps.period_name    = p_period_name
  AND    gps.ledger_id      = ln_single_ledger_id
  AND    gps.application_id = 101;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_errbuf := gl_message.get_message('GL_PLL_INVALID_PERIOD', 'Y'
                                      ,'PERIOD', p_period_name
                                      ,'LDGID', TO_CHAR(p_ledger_id));

  WHEN OTHERS THEN
    x_errbuf := SQLERRM;
END gl_get_effective_num;

--=====================================================================
--=====================================================================
FUNCTION int_doc_number(p_je_header_id IN NUMBER
                       ,p_je_line_num  IN NUMBER)
RETURN VARCHAR2
IS
  lc_doc_num VARCHAR2(100);
BEGIN
  BEGIN
    SELECT SUBSTR(aba.description,1,2)||'/'||
           SUBSTR(csh.statement_number,1,4)||'/'||
           SUBSTR(TO_CHAR(csl.line_number),1,4)
    INTO   lc_doc_num
    FROM   gl_import_references gir
          ,ce_statement_lines   csl
          ,ce_statement_headers csh
          ,ap_bank_accounts     aba
    WHERE  gir.je_header_id        = p_je_header_id
    AND    gir.je_line_num         = p_je_line_num
    AND    gir.reference_3         = csl.statement_line_id
    AND    csh.statement_header_id = csl.statement_header_id
    AND    csh.bank_account_id     = aba.bank_account_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    BEGIN
      SELECT ai.doc_sequence_value
      INTO   lc_doc_num
      FROM   gl_import_references gir
            ,ap_invoices          ai
      WHERE  gir.je_header_id = p_je_header_id
      AND    gir.je_line_num  = p_je_line_num
      AND    gir.reference_6  = 'AP Invoices'
      AND    gir.reference_2  = ai.invoice_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT TO_CHAR(gir.reference_4)
          INTO   lc_doc_num
          FROM   gl_import_references gir
          WHERE  gir.je_header_id = p_je_header_id
          AND    gir.je_line_num  = p_je_line_num
          AND    (gir.reference_6 IN ('INV','DM','DEP','CM','AP Payments','AP Reconciled Payments','CUSTOMER','DIALOG_HK')
              OR gir.reference_10 IN ('AR_CASH_RECEIPT_HISTORY','AR_RECEIVABLE_APPLICATIONS'));
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            lc_doc_num := NULL;
          WHEN TOO_MANY_ROWS THEN
            lc_doc_num := NULL;
        END;
      WHEN TOO_MANY_ROWS THEN
        lc_doc_num := NULL;
     END;
     WHEN TOO_MANY_ROWS THEN
       lc_doc_num := NULL;
     WHEN OTHERS THEN
       lc_doc_num := SQLERRM;
  END;
  RETURN(lc_doc_num);

END int_doc_number;

--=====================================================================
--=====================================================================
FUNCTION ctrl_segment_name(p_coa_id_in       IN NUMBER
                          ,p_ctrl_seg_num_in IN NUMBER)
RETURN VARCHAR2
IS
  lc_segment_name VARCHAR2(30);
BEGIN
  BEGIN
    SELECT  fifseg.segment_name
    INTO    lc_segment_name
    FROM    fnd_id_flex_structures   fifs
           ,fnd_id_flex_segments     fifseg
    WHERE   fifs.id_flex_code       =  fifseg.id_flex_code
    AND     fifs.id_flex_num        =  fifseg.id_flex_num
    AND     fifs.application_id     =  fifseg.application_id
    AND     fifseg.id_flex_code     =  'GL#'
    AND     fifseg.id_flex_num      =  p_coa_id_in
    AND     fifseg.application_id   =  101
    AND     fifseg.segment_num      =  p_ctrl_seg_num_in;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      lc_segment_name := NULL;
    WHEN OTHERS THEN
      lc_segment_name := NULL;
  END;
  RETURN (lc_segment_name);
END ctrl_segment_name;

--=====================================================================
--=====================================================================
FUNCTION beforereport
RETURN BOOLEAN
IS
  lc_security_mode    VARCHAR2(1);
  lc_error_msg        VARCHAR2(200);
BEGIN

/*--*****************************************************
-- Obtain Period From and To Effective Numbers
--******************************************************/

  gl_get_effective_num(LEDGER_ID_PARAM,PERIOD_FROM_PARAM
                      ,GC_PER_EFF_FROM_NUM,lc_error_msg);

  IF lc_error_msg IS NOT NULL THEN
    Raise_application_error(-20002,SQLERRM);
  END IF;

  gl_get_effective_num(LEDGER_ID_PARAM,PERIOD_TO_PARAM
                      ,GC_PER_EFF_TO_NUM,lc_error_msg);

    IF lc_error_msg IS NOT NULL THEN
      Raise_application_error(-20002,SQLERRM);
    END IF;

--****************************************************
--Calculate Beginning and Period To Date column names
--****************************************************
/* default: if currency type is T of S (for all A/B/E balances) */
  GC_BEGIN_DR_SELECT  := 'SUM(DECODE(gps.effective_period_num, '||GC_PER_EFF_FROM_NUM||', NVL(gb.begin_balance_dr,0), 0))';
  GC_BEGIN_CR_SELECT  := 'SUM(DECODE(gps.effective_period_num, '||GC_PER_EFF_FROM_NUM||', NVL(gb.begin_balance_cr,0), 0))';
  GC_PERIOD_DR_SELECT := 'SUM(NVL(gb.period_net_dr,0))';
  GC_PERIOD_CR_SELECT := 'SUM(NVL(gb.period_net_cr,0))';

  IF (CURRENCY_TYPE_PARAM = 'E') THEN
  /* For Actual only - may pull from regular or BEQ columns */
    IF (BALANCE_TYPE_PARAM = 'A') THEN
      GC_BEGIN_DR_SELECT  := 'SUM(NVL(DECODE(gps.effective_period_num, '||GC_PER_EFF_FROM_NUM||', DECODE(gb.translated_flag,''R'',gb.begin_balance_dr,gb.begin_balance_dr_beq),0), 0))';
      GC_BEGIN_CR_SELECT  := 'SUM(NVL(DECODE(gps.effective_period_num, '||GC_PER_EFF_FROM_NUM||', DECODE(gb.translated_flag,''R'',gb.begin_balance_cr,gb.begin_balance_cr_beq),0), 0))';
      GC_PERIOD_DR_SELECT := 'SUM(NVL(DECODE(gb.translated_flag,''R'',gb.period_net_dr,gb.period_net_dr_beq),0))';
      GC_PERIOD_CR_SELECT := 'SUM(NVL(DECODE(gb.translated_flag,''R'',gb.period_net_cr,gb.period_net_cr_beq),0))';
    END IF;
  END IF;
  GC_NONZERO_WHERE := ' ( '||GC_PERIOD_DR_SELECT||' <> 0 OR '||GC_PERIOD_CR_SELECT||' <> 0)';

/*--*****************************************************
-- Identifying the BALANCE_TYPE_PARAM value
-- If A => Actual  (No filter)
--    B => Budget  (Filter data on Budget Name)
--    E => Encumbrance (Filter data on Encumbrance Type)
--******************************************************/

  IF (BALANCE_TYPE_PARAM = 'A') THEN
    GC_BALANCE_WHERE := ' 1 = 1 ';
  ELSIF (BALANCE_TYPE_PARAM = 'B') THEN
    GC_BALANCE_WHERE := ' gb.budget_version_id = '   || TO_CHAR(BUDGETNAME_ENCUMBRANCETYPE);
  ELSE
    GC_BALANCE_WHERE := ' gb.encumbrance_type_id = ' || TO_CHAR(BUDGETNAME_ENCUMBRANCETYPE);
  END IF;

/*--*****************************************************
-- Identifying the Resulting Currency value this is
-- based on CURRENCY_TYPE_PARAM value
-- If T => Total       (Ledger Currency)
--    E => Entered     (Entered Currency)
--    S => Statistical (Entered Currency)
--******************************************************/

  IF (CURRENCY_TYPE_PARAM = 'T') THEN
    GC_RESULTING_CURRENCY := ''''||LEDGER_CURRENCY_PARAM||'''';
  ELSE  /* E or S */
    GC_RESULTING_CURRENCY := ''''||ENTERED_CURRENCY_PARAM||'''';
  END IF;

/*--*****************************************************
-- Identifying the GC_TRANSLATE_WHERE value
-- If E => Entered   (Query filter will be Translated_flag IS NULL or 'R')
--    T => Total       (Query filter will be Translated_flag IS NULL)
--    S => Statistical (Query filter will be Translated_flag IS NULL)
--******************************************************/

  IF (CURRENCY_TYPE_PARAM = 'E') THEN
    GC_TRANSLATE_WHERE := ' (gb.translated_flag = ''R'' OR gb.translated_flag IS NULL ) ';
  ELSE  /* T or S */
    GC_TRANSLATE_WHERE := ' gb.translated_flag IS NULL ';
  END IF;

/*--*****************************************************
-- Obtain the Data Access Security Clause
--******************************************************/

  GC_DAS_BAL_WHERE := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(ACCESS_SET_ID_PARAM
                                                                    ,'R'
                                                                    ,'LEDGER_COLUMN'
                                                                    ,'LEDGER_ID'
                                                                    ,'gb'
                                                                    ,'SEG_COLUMN'
                                                                    ,NULL
                                                                    ,'gcc'
                                                                    ,NULL);
  IF (GC_DAS_BAL_WHERE IS NULL) THEN
    GC_DAS_BAL_WHERE := ' 1 = 1 ';
  END IF;

  GC_DAS_JE_WHERE := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(ACCESS_SET_ID_PARAM
                                                                    ,'R'
                                                                    ,'LEDGER_COLUMN'
                                                                    ,'LEDGER_ID'
                                                                    ,'gjh'
                                                                    ,'SEG_COLUMN'
                                                                    ,NULL
                                                                    ,'gcc'
                                                                    ,NULL);
  IF (GC_DAS_JE_WHERE IS NULL) THEN
    GC_DAS_JE_WHERE := ' 1 = 1 ';
  END IF;

/*--*****************************************************
-- Segment Security enhancement to secure the balance
-- of begin and end balance. By calling gl_security_pkg,
-- the main query will only return rows that users have
-- the valid segment value access
--******************************************************/

  BEGIN
    FND_PROFILE.GET('GL_STD_ANALYSIS_REPORT_BALANCE_SECURITY', lc_security_mode);
  EXCEPTION
    WHEN OTHERS THEN
      lc_security_mode := 'N';
  END;

  IF( NVL(lc_security_mode,'N') = 'Y') THEN
    GL_SECURITY_PKG.INIT_SEGVAL;
    GC_SECURITY_WHERE := ' GL_SECURITY_PKG.VALIDATE_ACCESS(' || LEDGER_ID_PARAM ||', gcc.code_combination_id) = ''TRUE'' ';
  ELSE
    GC_SECURITY_WHERE := ' 1 = 1 ';
  END IF;

/*--*****************************************************
-- Obtain the Currency Code filter based on
-- Currency Type parameter
-- If CURRENCY_TYPE_PARAM is
--  'S' => Statistical Currency data is selected
--  'T' => All Currencies data is selected except STAT
--  'E' => Entered Currency data is selected
           (through Entered Currency parameter)
--******************************************************/

  IF (CURRENCY_TYPE_PARAM = 'S') THEN
    GC_CURRENCY_WHERE := '(   gjh.currency_code = ''STAT''' ||' OR gjl.stat_amount IS NOT NULL)';
  ELSIF (CURRENCY_TYPE_PARAM = 'T') THEN
    GC_CURRENCY_WHERE := 'gjh.currency_code != ''STAT''';
  ELSE /* currency type 'E' */
    GC_CURRENCY_WHERE := 'gjh.currency_code = ''' || ENTERED_CURRENCY_PARAM || '''';
  END IF;

/*--*****************************************************
-- Internal Document Number to be displayed or not
--******************************************************/

  IF PRINT_INTERNAL_DOC_NUM_PARAM = 'Y' THEN
    GC_INT_DOC_NUM := 'GL_SEL_SEG_TURNOVER_RPT_PKG.int_doc_number(gjl.je_header_id, gjl.je_line_num)';
  ELSE
    GC_INT_DOC_NUM := 'NULL';
  END IF;

/*--*****************************************************
-- Used to obtain the Segment Names (Owner and Subordinate)
--******************************************************/
  gc_additional_segment_name1 := ctrl_segment_name(COA_ID_PARAM, ADDITIONAL_SEGMENT_NUM1_PARAM);
  gc_additional_segment_name2 := ctrl_segment_name(COA_ID_PARAM, ADDITIONAL_SEGMENT_NUM2_PARAM);

/*--*****************************************************
-- Used to obtain the Data Access Set Name
--******************************************************/

  SELECT gas.name
  INTO   gc_data_access_set_name
  FROM   gl_access_sets  gas
  WHERE  gas.access_set_id  = ACCESS_SET_ID_PARAM;

  RETURN(TRUE);
END beforereport;

END GL_SEL_SEG_TURNOVER_RPT_PKG;

/
