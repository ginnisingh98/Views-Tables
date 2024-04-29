--------------------------------------------------------
--  DDL for Package Body IGI_IGIGCBGD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGIGCBGD_XMLP_PKG" AS
/* $Header: IGIGCBGDB.pls 120.0.12010000.1 2008/07/29 08:58:13 appldev ship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    IF LP_FROM_PERIOD IS NOT NULL THEN
      SELECT
        EFFECTIVE_PERIOD_NUM
      INTO CP_EFFECTIVE_PERIOD_FROM
      FROM
        GL_PERIOD_STATUSES
      WHERE APPLICATION_ID = 101
        AND SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID
        AND PERIOD_NAME = LP_FROM_PERIOD;
    ELSE
      SELECT
        MIN(EFFECTIVE_PERIOD_NUM)
      INTO CP_EFFECTIVE_PERIOD_FROM
      FROM
        GL_PERIOD_STATUSES
      WHERE APPLICATION_ID = 101
        AND SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID;
    END IF;
    IF P_TO_PERIOD IS NOT NULL THEN
      SELECT
        EFFECTIVE_PERIOD_NUM
      INTO CP_EFFECTIVE_PERIOD_TO
      FROM
        GL_PERIOD_STATUSES
      WHERE APPLICATION_ID = 101
        AND SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID
        AND PERIOD_NAME = P_TO_PERIOD;
    ELSE
      SELECT
        MAX(EFFECTIVE_PERIOD_NUM)
      INTO CP_EFFECTIVE_PERIOD_TO
      FROM
        GL_PERIOD_STATUSES
      WHERE APPLICATION_ID = 101
        AND SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    DELETE FROM IGI_CBR_GL_INTERFACE;
    COMMIT;
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    LP_FROM_PERIOD := P_FROM_PERIOD;
    IF P_FROM_PERIOD IS NULL THEN
      SELECT
        GP.PERIOD_NAME
      INTO P_FROM_PERIOD
      FROM
        GL_PERIODS GP,
        GL_SETS_OF_BOOKS GSOB
      WHERE GSOB.SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID
        AND GSOB.PERIOD_SET_NAME = GP.PERIOD_SET_NAME
        AND GP.PERIOD_TYPE = GSOB.ACCOUNTED_PERIOD_TYPE
        AND GP.PERIOD_NUM = 1
        AND GP.PERIOD_YEAR = (
        SELECT
          G.PERIOD_YEAR
        FROM
          GL_PERIODS G,
          GL_SETS_OF_BOOKS GS
        WHERE GS.SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID
          AND GS.PERIOD_SET_NAME = G.PERIOD_SET_NAME
          AND G.PERIOD_NAME = P_TO_PERIOD );
    END IF;
    SELECT
      DISTINCT
      GP.PERIOD_NUM,
      GP.PERIOD_YEAR
    INTO LP_FROM_PERIOD_NUM,LP_FROM_PERIOD_YEAR
    FROM
      GL_PERIODS GP,
      GL_SETS_OF_BOOKS GS
    WHERE GP.PERIOD_NAME = P_FROM_PERIOD
      AND GP.PERIOD_SET_NAME = GS.PERIOD_SET_NAME
      AND GS.SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID;
    SELECT
      GP.PERIOD_NUM,
      GP.PERIOD_YEAR
    INTO LP_TO_PERIOD_NUM,LP_TO_PERIOD_YEAR
    FROM
      GL_PERIODS GP,
      GL_SETS_OF_BOOKS GSOB
    WHERE GP.PERIOD_SET_NAME = GSOB.PERIOD_SET_NAME
      AND GSOB.SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID
      AND GP.PERIOD_NAME = P_TO_PERIOD;
    SELECT
      NAME,
      CURRENCY_CODE
    INTO LP_LEDGER_NAME,LP_CURRENCY_CODE
    FROM
      GL_SETS_OF_BOOKS
    WHERE SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID;
    SELECT
      NAME
    INTO LP_CASH_SOB_NAME
    FROM
      GL_SETS_OF_BOOKS
    WHERE SET_OF_BOOKS_ID = P_CASH_SOB_ID;
    SELECT
      count(*)
    INTO LP_UNPOSTED_JOURNALS
    FROM
      GL_JE_HEADERS GJH,
      GL_JE_BATCHES GJB
    WHERE GJH.LEDGER_ID = P_CASH_SOB_ID
      AND GJH.JE_BATCH_ID = GJB.JE_BATCH_ID
      AND GJB.STATUS <> 'P';
    SELECT_INTO_TABLE;
    COMMIT;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION CP_EFFECTIVE_PERIOD_FROM_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EFFECTIVE_PERIOD_FROM;
  END CP_EFFECTIVE_PERIOD_FROM_P;

  FUNCTION CP_EFFECTIVE_PERIOD_TO_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EFFECTIVE_PERIOD_TO;
  END CP_EFFECTIVE_PERIOD_TO_P;

  PROCEDURE SELECT_INTO_TABLE IS
    L_SEGMENT VARCHAR2(25);
    L_INSERT VARCHAR2(5000);
  BEGIN
    L_SEGMENT := P_ACCT_SEGMENT;
    L_INSERT := ' INSERT INTO igi_cbr_gl_interface
                       ( BATCH_ID, LEDGER_ID, STATUS,  -- bug 6315298
                         ACCOUNT,
                         DOC_SEQ_NUM,
                         NAME,
                         JE_SOURCE,
                         DESCRIPTION,
                         EFFECTIVE_DATE,
                         AMOUNT
                        )
                 SELECT
                        distinct gjb.je_batch_id, gjh.ledger_id, gjb.status,   -- bug 6315298
                        gcc.' || L_SEGMENT || ' Account
                 ,	nvl(gjl.subledger_doc_sequence_value, gjh.doc_sequence_value) Document_Sequence_Number
                 ,	gjh.name Document_Sequence_Name
                 ,	gjh.je_source Journal_Source
                 ,	gjl.description Description
                 ,	gjl.effective_date Effective_Date
                 ,	(nvl(gjl.accounted_dr,0) - nvl(gjl.accounted_cr,0)) Amount
                 FROM  	gl_period_statuses gls
                -- ,     	igi_com_gl_batches_copy_v jgb   -- bug 6315298
                 ,   gl_je_batches gjb , gl_lookups l            -- bug 6315298
                 ,     	gl_code_combinations gcc
                 ,	gl_je_headers gjh
                 ,	gl_je_lines gjl
                 WHERE  gjb.je_batch_id = gjh.je_batch_id
                 and    l.lookup_type = ''BATCH_TYPE''   -- bug 6315298
                 and     l.lookup_code = gjb.actual_flag  -- bug 6315298
                 AND    gjh.je_header_id = gjl.je_header_id
                 AND    gjh.actual_flag = ''A''
                 AND	gjh.je_source like replace(''' || P_JE_SOURCE || ''', ''ALL'', ''%'')
                 AND    gjh.je_source not in (''Payables'',''Receivables'',''Purchasing'')
                 AND    gjh.je_source not in ( select arc_je_source_name
                                               from igi_ar_system_options_all
                                               where arc_je_source_name is not null)
                 AND	gjl.period_name = gls.period_name
                 AND	gjl.ledger_id = gls.set_of_books_id
                 AND	gls.application_id = 101
                 AND	gjl.ledger_id = ' || P_SET_OF_BOOKS_ID || '   -- replaced set_of_books_id to ledger_id for bug 6315298
                 AND	gjl.code_combination_id = gcc.code_combination_id
                 AND    gcc.' || L_SEGMENT || ' between ''' || P_FROM_ACCOUNT || ''' and ''' || P_TO_ACCOUNT || '''
                 AND    to_number(gls.period_year||lpad(gls.period_num,2,0)) between to_number(' || LP_FROM_PERIOD_YEAR || '||(lpad(' || LP_FROM_PERIOD_NUM || ',2,0))) and to_number(' || LP_TO_PERIOD_YEAR || '||(lpad(' || LP_TO_PERIOD_NUM || ',2,0)))
                 AND 	gcc.account_type in (''A'', ''O'', ''L'')
                 and gjb.status = ''P''    -- bug 6315298
                  UNION ALL
                   SELECT
                        distinct gjb.je_batch_id, gjh.ledger_id, gjb.status,    -- bug 6315298
                        gcc.' || L_SEGMENT || ' Account
                   ,	nvl(gjl.subledger_doc_sequence_value, gjh.doc_sequence_value) Document_Sequence_Number
                   ,	gjh.name Document_Sequence_Name
                   ,	gjh.je_source Journal_Source
                   ,	gjl.description Description
                   ,	gjl.effective_date Effective_Date
                   ,	(nvl(gjl.accounted_dr,0) - nvl(gjl.accounted_cr,0)) Amount
                   FROM gl_period_statuses gls
                  -- ,	igi_com_gl_batches_copy_v jgb   -- bug 6315298
                 , gl_je_batches gjb, gl_lookups l      -- bug 6315298
                   ,	gl_code_combinations gcc
                   ,	gl_je_headers gjh
                   ,	gl_je_lines gjl
                   WHERE gjb.je_batch_id = gjh.je_batch_id
                   and    l.lookup_type = ''BATCH_TYPE''    -- bug 6315298
                   and     l.lookup_code = gjb.actual_flag  and gjb.status = ''P'' -- bug 6315298
                   AND	 gjh.je_header_id = gjl.je_header_id
                   AND   gjh.actual_flag = ''A''
                   AND	 gjh.je_source like replace(''' || P_JE_SOURCE || ''', ''ALL'', ''%'')
                   AND    gjh.je_source not in (''Payables'',''Receivables'',''Purchasing'')
                   AND    gjh.je_source not in ( select arc_je_source_name
                                               from igi_ar_system_options_all
                                               where arc_je_source_name is not null)
                   AND	 gjl.period_name = gls.period_name
                   AND	 gjl.ledger_id = gls.set_of_books_id
                   AND	 gls.application_id = 101
                   AND	 gjl.ledger_id = ' || P_SET_OF_BOOKS_ID || '        -- bug 6315298
                   AND	 gjl.code_combination_id = gcc.code_combination_id
                   AND   gcc.' || L_SEGMENT || ' between ''' || P_FROM_ACCOUNT || ''' and ''' || P_TO_ACCOUNT || '''
                   AND   to_number(gls.period_year||lpad(gls.period_num,2,0)) between to_number(' || LP_FROM_PERIOD_YEAR || '||(lpad(' || LP_FROM_PERIOD_NUM || ',2,0))) and to_number(' || LP_TO_PERIOD_YEAR || '||(lpad(' || LP_TO_PERIOD_NUM || ',2,0)))
                   AND	 gls.period_year = ' || LP_TO_PERIOD_YEAR || '
                   AND	 gcc.account_type not in (''A'', ''O'', ''L'')';
    EXECUTE IMMEDIATE
      L_INSERT;
  END SELECT_INTO_TABLE;

END IGI_IGIGCBGD_XMLP_PKG;

/
