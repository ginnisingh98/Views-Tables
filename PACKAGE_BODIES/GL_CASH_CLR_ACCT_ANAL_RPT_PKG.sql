--------------------------------------------------------
--  DDL for Package Body GL_CASH_CLR_ACCT_ANAL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CASH_CLR_ACCT_ANAL_RPT_PKG" AS
/* $Header: glxccaab.pls 120.1.12010000.2 2010/01/29 10:00:46 skotakar ship $ */

--
-- PUBLIC FUNCTIONS
--

  FUNCTION before_report RETURN BOOLEAN IS
  BEGIN
    -- Set the security context of subledger application
    XLA_SECURITY_PKG.SET_SECURITY_CONTEXT(200);

    -- Build the where clause based on database security
    gc_access_where:= GL_ACCESS_SET_SECURITY_PKG.get_security_clause
                     (data_access_set_id_param,
                      'R',
                      'LEDGER_COLUMN',
                      'LEDGER_ID',
                      'gb',
                      'SEG_COLUMN',
                       NULL,
                      'gcc',
                       NULL);
    IF gc_access_where is NULL THEN
      gc_access_where:= '1 = 1';
    END IF;

    -- Get the effective period numbers
    SELECT MAX(CASE gps.period_name
                    WHEN period_from_param THEN gps.effective_period_num END)
          ,MAX(CASE gps.period_name
                    WHEN period_to_param THEN gps.effective_period_num END)
    INTO   gn_effective_period_num_from
          ,gn_effective_period_num_to
    FROM   gl_period_statuses gps
    WHERE gps.ledger_id = ledger_id_param
    AND   gps.application_id = 200
    AND   gps.period_name IN (period_from_param, period_to_param);

    -- Build the AP uncleared query based on the value of rept_type_param
    IF rept_type_param = 'DETAIL' THEN
      gc_ap_uncleared_query:=
        'SELECT
                aca.check_number    doc_num
               ,gjl.effective_date  line_effective_date
               ,gjh.description     jrnl_desc
               ,xal.accounted_dr    jrnl_line_dr
               ,xal.accounted_cr    jrnl_line_cr
         FROM
                gl_je_lines               gjl
               ,gl_import_references      gir
               ,gl_je_headers             gjh
               ,xla_ae_lines              xal
               ,xla_ae_headers            xah
               ,xla_transaction_entities  xte
               ,ap_checks_all             aca
               ,gl_period_statuses        gps
         WHERE
             gjl.ledger_id = :ledger_id_param
         AND gjl.code_combination_id = :ccid
         AND gps.ledger_id = gjl.ledger_id
         AND gjl.period_name = gps.period_name
         AND gps.effective_period_num
             BETWEEN :gn_effective_period_num_from
                 AND :gn_effective_period_num_to
         AND gps.application_id = 200
         AND gjl.status = ''P''
         AND gjh.je_header_id = gjl.je_header_id
         AND gjh.je_source = ''Payables''
         AND gir.je_header_id = gjh.je_header_id
         AND gir.je_line_num = gjl.je_line_num
         AND gir.gl_sl_link_id = xal.gl_sl_link_id
         AND gir.gl_sl_link_table = xal.gl_sl_link_table
         AND xal.application_id = 200
         AND xah.ae_header_id = xal.ae_header_id
         AND xah.application_id = xal.application_id
         AND xte.entity_id = xah.entity_id
         AND xte.application_id = xah.application_id
         AND aca.check_id = xte.source_id_int_1
         AND aca.status_lookup_code NOT IN (''CLEARED'',''RECONCILED'')
         ORDER BY doc_num';

    ELSIF rept_type_param = 'SUMMARY' THEN
      gc_ap_uncleared_query:=
       'SELECT
               NVL(SUM(NVL(xal.accounted_dr,0)),0) jrnl_line_dr
              ,NVL(SUM(NVL(xal.accounted_cr,0)),0) jrnl_line_cr
        FROM
               gl_je_lines                   gjl
              ,gl_import_references          gir
              ,gl_je_headers                 gjh
              ,xla_ae_lines                  xal
              ,xla_ae_headers                xah
              ,xla_transaction_entities      xte
              ,ap_checks_all                 aca
              ,gl_period_statuses            gps
        WHERE
            gjl.ledger_id = :ledger_id_param
        AND gjl.code_combination_id = :ccid
        AND gps.ledger_id = gjl.ledger_id
        AND gjl.period_name = gps.period_name
        AND gps.effective_period_num
            BETWEEN :gn_effective_period_num_from
                AND :gn_effective_period_num_to
        AND gps.application_id = 200
        AND gjl.status = ''P''
        AND gjh.je_header_id = gjl.je_header_id
        AND gjh.je_source = ''Payables''
        AND gir.je_header_id = gjh.je_header_id
        AND gir.je_line_num = gjl.je_line_num
        AND gir.gl_sl_link_id = xal.gl_sl_link_id
        AND gir.gl_sl_link_table = xal.gl_sl_link_table
        AND xal.application_id = 200
        AND xah.ae_header_id = xal.ae_header_id
        AND xah.application_id = xal.application_id
        AND xte.entity_id = xah.entity_id
        AND xte.application_id = xah.application_id
        AND aca.check_id = xte.source_id_int_1
        AND aca.status_lookup_code NOT IN (''CLEARED'',''RECONCILED'')';
    END IF;

    -- Build the GL Uncleared query based on the value of rept_type_param
    IF rept_type_param = 'DETAIL' THEN
      gc_gl_uncleared_query:=
        'SELECT
                 gjb.name               batch_name
                ,gjl.effective_date     line_effective_date
                ,gjh.name               jrnl_name
                ,gjl.accounted_dr       jrnl_line_dr
                ,gjl.accounted_cr       jrnl_line_cr
         FROM
                 gl_je_lines            gjl
                ,gl_je_headers          gjh
                ,gl_je_batches          gjb
                ,gl_period_statuses     gps
         WHERE
                gjl.ledger_id = :ledger_id_param
         AND    gjl.code_combination_id = :ccid
         AND    gps.ledger_id = gjl.ledger_id
         AND    gjl.period_name = gps.period_name
         AND    gps.effective_period_num
                BETWEEN :gn_effective_period_num_from
                    AND :gn_effective_period_num_to
         AND    gjl.status            =''P''
         AND    gjb.je_batch_id       = gjh.je_batch_id
         AND    gjh.je_header_id      = gjl.je_header_id
         AND    UPPER(gjh.je_source)  = ''MANUAL''
         AND    gjl.gl_sl_link_id IS NULL
         AND    gps.application_id = 200
         /*Added this code to pick only unreconciled transactions in Cash Management*/
         --As part of bug 9166199
         AND     NOT EXISTS (SELECT ''X''
                            FROM   ce_statement_reconcils_all csra
                            WHERE  csra.je_header_id =  gjh.je_header_id
                            AND    csra.reference_id = gjl.je_line_num
                            AND    csra.status_flag = ''M''
                            AND    csra.current_record_flag = ''Y''
                            AND    csra.REFERENCE_TYPE = ''JE_LINE''
                            )
         ORDER BY
                  batch_name
                 ,jrnl_name';

    ELSIF rept_type_param = 'SUMMARY' THEN
      gc_gl_uncleared_query:=
        'SELECT
                NVL(SUM(NVL(gjl.accounted_dr,0)),0) jrnl_line_dr
               ,NVL(SUM(NVL(gjl.accounted_cr,0)),0) jrnl_line_cr
         FROM
                gl_je_lines            gjl
               ,gl_je_headers          gjh
               ,gl_je_batches          gjb
               ,gl_period_statuses     gps
         WHERE
               gjl.ledger_id = :ledger_id_param
         AND   gjl.code_combination_id = :ccid
         AND   gps.ledger_id = gjl.ledger_id
         AND   gjl.period_name = gps.period_name
         AND   gps.effective_period_num
               BETWEEN :gn_effective_period_num_from
                   AND :gn_effective_period_num_to
         AND   gps.application_id = 200
         AND   gjl.status            =''P''
         AND   gjb.je_batch_id       = gjh.je_batch_id
         AND   gjh.je_header_id      = gjl.je_header_id
         AND   UPPER(gjh.je_source)  = ''MANUAL''
         AND   gps.application_id = 200
         AND   gjl.gl_sl_link_id IS NULL
         /*Added this code to pick only unreconciled transactions in Cash Management*/
         --As part of bug 9166199
         AND     NOT EXISTS (SELECT ''X''
                            FROM   ce_statement_reconcils_all csra
                            WHERE  csra.je_header_id =  gjh.je_header_id
                            AND    csra.reference_id = gjl.je_line_num
                            AND    csra.status_flag = ''M''
                            AND    csra.current_record_flag = ''Y''
                            AND    csra.REFERENCE_TYPE = ''JE_LINE''
                            )'  ;
    END IF;

    -- Build the AP Cleared query based on the value of rept_type_param
    IF rept_type_param = 'DETAIL' THEN
      gc_ap_cleared_query:=
        'SELECT
                aca.check_number    doc_num
               ,gjl.effective_date  line_effective_date
               ,gjh.description     jrnl_desc
               ,xal.accounted_dr    jrnl_line_dr
               ,xal.accounted_cr    jrnl_line_cr
         FROM
                gl_je_lines                   gjl
               ,gl_import_references          gir
               ,gl_je_headers                 gjh
               ,xla_ae_lines                  xal
               ,xla_ae_headers                xah
               ,xla_transaction_entities      xte
               ,ap_checks_all                 aca
               ,gl_period_statuses            gps
         WHERE
               gjl.ledger_id = :ledger_id_param
         AND   gjl.code_combination_id = :ccid
         AND   gps.ledger_id = gjl.ledger_id
         AND   gjl.period_name = gps.period_name
         AND   gps.effective_period_num
               BETWEEN :gn_effective_period_num_from
                   AND :gn_effective_period_num_to
         AND   gps.application_id = 200
         AND   gjl.status = ''P''
         AND   gjh.je_header_id = gjl.je_header_id
         AND   gjh.je_source = ''Payables''
         AND   gir.je_header_id = gjh.je_header_id
         AND   gir.je_line_num = gjl.je_line_num
         AND   gir.gl_sl_link_id = xal.gl_sl_link_id
         AND   gir.gl_sl_link_table = xal.gl_sl_link_table
         AND   xal.application_id = 200
         AND   xah.ae_header_id = xal.ae_header_id
         AND   xah.application_id = xal.application_id
         AND   xte.entity_id = xah.entity_id
         AND   xte.application_id = xah.application_id
         AND   aca.check_id = xte.source_id_int_1
         AND   aca.status_lookup_code IN (''CLEARED'',''RECONCILED'')
         ORDER BY doc_num';

    ELSIF rept_type_param = 'SUMMARY' THEN
      gc_ap_cleared_query:=
        'SELECT
                NVL(SUM(NVL(xal.accounted_dr,0)),0) jrnl_line_dr
               ,NVL(SUM(NVL(xal.accounted_cr,0)),0) jrnl_line_cr
         FROM
               gl_je_lines                   gjl
              ,gl_import_references          gir
              ,gl_je_headers                 gjh
              ,xla_ae_lines                  xal
              ,xla_ae_headers                xah
              ,xla_transaction_entities      xte
              ,ap_checks_all                 aca
              ,gl_period_statuses            gps
        WHERE
              gjl.ledger_id = :ledger_id_param
         AND  gjl.code_combination_id = :ccid
         AND  gps.ledger_id = gjl.ledger_id
         AND  gjl.period_name = gps.period_name
         AND  gps.effective_period_num
              BETWEEN :gn_effective_period_num_from
                  AND :gn_effective_period_num_to
         AND  gps.application_id = 200
         AND  gjl.status = ''P''
         AND  gjh.je_header_id = gjl.je_header_id
         AND  gjh.je_source = ''Payables''
         AND  gir.je_header_id = gjh.je_header_id
         AND  gir.je_line_num = gjl.je_line_num
         AND  gir.gl_sl_link_id = xal.gl_sl_link_id
         AND  gir.gl_sl_link_table = xal.gl_sl_link_table
         AND  xal.application_id = 200
         AND  xah.ae_header_id = xal.ae_header_id
         AND  xah.application_id = xal.application_id
         AND  xte.entity_id = xah.entity_id
         AND  xte.application_id = xah.application_id
         AND  aca.check_id = xte.source_id_int_1
         AND  aca.status_lookup_code IN (''CLEARED'',''RECONCILED'')';
    END IF;

    RETURN (true);
  END before_Report;

  FUNCTION access_set_name RETURN VARCHAR2 IS
    lc_access_set_name VARCHAR2(50);

    CURSOR get_access_set_name IS
      SELECT gas.name data_access_set_name
      FROM   gl_access_sets gas
      WHERE  gas.access_set_id = data_access_set_id_param;
  BEGIN
    OPEN get_access_set_name;
    FETCH get_access_set_name INTO lc_access_set_name;
    CLOSE get_access_set_name;

    RETURN lc_access_set_name;
  END access_set_name;

  FUNCTION ledger_name RETURN VARCHAR2 IS
    lc_ledger_name VARCHAR2(50);

    CURSOR get_ledger_name IS
      SELECT gll.name ledger_name
      FROM   gl_ledgers gll
      WHERE  gll.ledger_id = ledger_id_param;
  BEGIN
    OPEN get_ledger_name;
    FETCH get_ledger_name INTO lc_ledger_name;
    CLOSE get_ledger_name;

    RETURN lc_ledger_name;
  END ledger_name;

END GL_CASH_CLR_ACCT_ANAL_RPT_PKG;

/
