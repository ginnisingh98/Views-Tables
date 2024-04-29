--------------------------------------------------------
--  DDL for Package Body IGI_IGIIARPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGIIARPS_XMLP_PKG" AS
/* $Header: IGIIARPSB.pls 120.0.12010000.2 2008/08/14 13:24:26 sharoy ship $ */
  FUNCTION CF_PERIODNAMEFORMULA RETURN NUMBER IS
  BEGIN
    SELECT
      PERIOD_NAME
    INTO CP_PERIOD_NAME
    FROM
      FA_DEPRN_PERIODS
    WHERE PERIOD_COUNTER = P_PERIOD_COUNTER
      AND BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;
    RETURN (1);
  END CF_PERIODNAMEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    INSERT_INFO_VAR := do_insertformula();

select SUBSTR(argument1,INSTR(argument1,'=',1)+1,LENGTH(argument1)),
SUBSTR(argument2,INSTR(argument2,'=',1)+1,LENGTH(argument2)),
SUBSTR(argument3,INSTR(argument3,'=',1)+1,LENGTH(argument3))

into P_BOOK_TYPE_CODE,P_REVALUATION_ID,P_PERIOD_COUNTER
from FND_CONCURRENT_REQUESTS
where request_id=P_CONC_REQUEST_ID;


SELECT accounting_flex_structure
INTO  accounting_Flex_structure
FROM   fa_book_controls
WHERE  book_Type_code = p_book_type_code;

    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION MINOR_CATEGORYFORMULA RETURN VARCHAR2 IS
    MINOR_CAT VARCHAR2(15);
  BEGIN
    RETURN ('abcd');
  END MINOR_CATEGORYFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    ROLLBACK;
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_CALC_COMPANY_NAMEFORMULA(COMPANY_NAME IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    P_BOOK := P_BOOK_TYPE_CODE;
    RP_COMPANY_NAME := COMPANY_NAME;
    RETURN 1;
  END CF_CALC_COMPANY_NAMEFORMULA;

  FUNCTION CF_CURR_CODEFORMULA RETURN NUMBER IS
    L_CURR_CODE VARCHAR2(20);
  BEGIN
    SELECT
      A.CURRENCY_CODE
    INTO L_CURR_CODE
    FROM
      GL_SETS_OF_BOOKS A,
      FA_BOOK_CONTROLS B
    WHERE A.SET_OF_BOOKS_ID = B.SET_OF_BOOKS_ID
      AND B.BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;
    CP_CURR_CODE := L_CURR_CODE;
    RETURN (1);
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(100
                 ,'Failed. Currency code not defined')*/NULL;
      /*SRW.MESSAGE(100
                 ,' No is ' || SQLERRM)*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      RETURN (1);
  END CF_CURR_CODEFORMULA;

  FUNCTION CF_REPORT_NAMEFORMULA RETURN NUMBER IS
    L_REPORT_NAME VARCHAR2(240);
  BEGIN
    SELECT
      CP.USER_CONCURRENT_PROGRAM_NAME
    INTO L_REPORT_NAME
    FROM
      FND_CONCURRENT_PROGRAMS_TL CP,
      FND_CONCURRENT_REQUESTS CR
    WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
      AND CP.LANGUAGE = USERENV('LANG')
      AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
      AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
      l_report_name:= substr(l_report_name,1,instr(l_report_name,' (XML)'));
    RP_REPORT_NAME := L_REPORT_NAME;
    RETURN (1);
  EXCEPTION
    WHEN OTHERS THEN
      RP_REPORT_NAME := 'Inflation Accounting Asset Revaluation Preview Summary Report:';
      /*SRW.MESSAGE(98
                 ,'report name is ' || RP_REPORT_NAME)*/NULL;
      RETURN (1);
  END CF_REPORT_NAMEFORMULA;

  FUNCTION CF_PERIOD_NAMEFORMULA RETURN NUMBER IS
  BEGIN
    SELECT
      PERIOD_NAME
    INTO CP_PERIOD_NAME
    FROM
      FA_DEPRN_PERIODS
    WHERE PERIOD_COUNTER = P_PERIOD_COUNTER
      AND BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;
    SELECT
      CT.FISCAL_YEAR_NAME FISCAL_YEAR_NAME
    INTO P_FISCAL_YEAR
    FROM
      FA_BOOK_CONTROLS BC,
      FA_CALENDAR_TYPES CT
    WHERE BC.BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
      AND BC.DEPRN_CALENDAR = CT.CALENDAR_TYPE;
    RETURN (1);
  END CF_PERIOD_NAMEFORMULA;

  FUNCTION CF_REP_TOLERANCEFORMULA(S_REP_B_REVAL_COST IN NUMBER
                                  ,S_REP_A_REVAL_COST IN NUMBER) RETURN VARCHAR2 IS
    TOL_VAL VARCHAR2(4);
    GAP NUMBER;
  BEGIN
    IF CF_TOLERANCE_LEVEL IS NOT NULL AND S_REP_B_REVAL_COST <> 0 THEN
      GAP := ABS(((NVL(S_REP_A_REVAL_COST
                    ,0) - NVL(S_REP_B_REVAL_COST
                    ,0)) / NVL(S_REP_B_REVAL_COST
                    ,0)) * 100);
      IF GAP >= CF_TOLERANCE_LEVEL THEN
        TOL_VAL := '***';
      ELSE
        TOL_VAL := '  ';
      END IF;
    END IF;
    RETURN (TOL_VAL);
  END CF_REP_TOLERANCEFORMULA;

  FUNCTION CALC_TOLERANCE_LEVELFORMULA RETURN NUMBER IS
  BEGIN
    FND_PROFILE.GET('IGI_IAC_REVAL_TOLERANCE',CF_TOLERANCE_LEVEL);
    RETURN 1;
  END CALC_TOLERANCE_LEVELFORMULA;

  FUNCTION CF_CO_TOLERANCEFORMULA(S_CO_B_REVAL_COST IN NUMBER
                                 ,S_CO_A_REVAL_COST IN NUMBER) RETURN CHAR IS
    TOL_VAL VARCHAR2(4);
    GAP NUMBER;
  BEGIN
    IF CF_TOLERANCE_LEVEL IS NOT NULL AND S_CO_B_REVAL_COST <> 0 THEN
      GAP := ABS(((NVL(S_CO_A_REVAL_COST
                    ,0) - NVL(S_CO_B_REVAL_COST
                    ,0)) / NVL(S_CO_B_REVAL_COST
                    ,0)) * 100);
      IF GAP >= CF_TOLERANCE_LEVEL THEN
        TOL_VAL := '***';
      ELSE
        TOL_VAL := '  ';
      END IF;
    END IF;
    RETURN (TOL_VAL);
  END CF_CO_TOLERANCEFORMULA;

  FUNCTION CF_MC_TOLERANCEFORMULA(S_MC_B_REVAL_COST IN NUMBER
                                 ,S_MC_A_REVAL_COST IN NUMBER) RETURN CHAR IS
    TOL_VAL VARCHAR2(4);
    GAP NUMBER;
  BEGIN
    IF CF_TOLERANCE_LEVEL IS NOT NULL AND S_MC_B_REVAL_COST <> 0 THEN
      GAP := ABS(((NVL(S_MC_A_REVAL_COST
                    ,0) - NVL(S_MC_B_REVAL_COST
                    ,0)) / NVL(S_MC_B_REVAL_COST
                    ,0)) * 100);
      IF GAP >= CF_TOLERANCE_LEVEL THEN
        TOL_VAL := '***';
      ELSE
        TOL_VAL := '  ';
      END IF;
    END IF;
    RETURN (TOL_VAL);
  END CF_MC_TOLERANCEFORMULA;

  FUNCTION CF_CAT_TOLERANCEFORMULA(S_CAT_B_REVAL_COST IN NUMBER
                                  ,S_CAT_A_REVAL_COST IN NUMBER) RETURN CHAR IS
    TOL_VAL VARCHAR2(4);
    GAP NUMBER;
  BEGIN
    IF CF_TOLERANCE_LEVEL IS NOT NULL AND S_CAT_B_REVAL_COST <> 0 THEN
      GAP := ABS(((NVL(S_CAT_A_REVAL_COST
                    ,0) - NVL(S_CAT_B_REVAL_COST
                    ,0)) / NVL(S_CAT_B_REVAL_COST
                    ,0)) * 100);
      IF GAP >= CF_TOLERANCE_LEVEL THEN
        TOL_VAL := '***';
      ELSE
        TOL_VAL := '  ';
      END IF;
    END IF;
    RETURN (TOL_VAL);
  END CF_CAT_TOLERANCEFORMULA;

  FUNCTION CF_CC_TOLERANCEFORMULA(S_CC_B_REVAL_COST IN NUMBER
                                 ,S_CC_A_REVAL_COST IN NUMBER) RETURN CHAR IS
    TOL_VAL VARCHAR2(4);
    GAP NUMBER;
  BEGIN
    CF_B_REVAL_COST := S_CC_B_REVAL_COST;
    CF_A_REVAL_COST := S_CC_A_REVAL_COST;
    IF CF_TOLERANCE_LEVEL IS NOT NULL AND CF_B_REVAL_COST <> 0 THEN
      GAP := ABS(((NVL(CF_A_REVAL_COST
                    ,0) - NVL(CF_B_REVAL_COST
                    ,0)) / NVL(CF_B_REVAL_COST
                    ,0)) * 100);
      IF GAP >= CF_TOLERANCE_LEVEL THEN
        TOL_VAL := '***';
      ELSE
        TOL_VAL := '  ';
      END IF;
    END IF;
    RETURN (TOL_VAL);
  END CF_CC_TOLERANCEFORMULA;

  FUNCTION CF_CALC_PLACEHOLDERSFORMULA RETURN NUMBER IS
    TOL_VAL VARCHAR2(4);
    GAP NUMBER;
  BEGIN
    RETURN 1;
  END CF_CALC_PLACEHOLDERSFORMULA;

  FUNCTION CF_MAJOR_CATFORMULA(MAJOR_CATEGORY IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    CP_MAJOR_CATEGORY := MAJOR_CATEGORY;
    RETURN 1;
  END CF_MAJOR_CATFORMULA;

  PROCEDURE INSERT_INFO IS
    L_SOURCE_TYPE_CODE VARCHAR2(50);
    L_AMOUNT1 VARCHAR2(200);
    L_AMOUNT2 VARCHAR2(200);
    L_AMOUNT3 VARCHAR2(200);
    L_SQL VARCHAR2(15000);
    IDX NUMBER;
    L_ASSET_ID NUMBER;
    L_DIST_CCID NUMBER;
    L_SOURCE VARCHAR2(30);
    L_AMOUNT NUMBER;
    L_DATA_SOURCE VARCHAR2(30);
    L_DISPLAY_ORDER NUMBER;
  BEGIN
--    delete from igi_iac_balances_report;

    FOR idx IN 1..5 LOOP
      IF (idx = 1) THEN
         l_source_type_code := 'COST';
         l_amount1 := 'nvl(dd.cost,0)';
         l_amount2 := 'nvl(idb.adjustment_cost,0)+nvl(dd.cost,0)';
         l_amount3 := 'nvl(idb.adjustment_cost,0)+nvl(dd.cost,0)';
      ELSIF (idx = 2) THEN
         l_source_type_code := 'REVAL_RSV';
         l_amount1 := 0;
         l_amount2 := 'nvl(idb.reval_reserve_net,0)';
         l_amount3 := 'nvl(idb.reval_reserve_net,0)';
     ELSIF (idx = 3) THEN
         l_source_type_code := 'OP_EXPENSE';
         l_amount1 := 0;
         l_amount2 := '(-1)*nvl(idb.operating_acct_net,0)';
         l_amount3 := '(-1)*nvl(idb.operating_acct_net,0)';
     ELSIF (idx = 4) THEN
         l_source_type_code := 'DEP_RSV';
         l_amount1 := 'dd.deprn_reserve';
         l_Amount2 := 'nvl(idb.deprn_reserve+deprn_reserve_backlog,0)+  nvl(dd.deprn_reserve,0)';
         l_Amount3 := 'nvl(idb.deprn_reserve+deprn_reserve_backlog,0)+  nvl(dd.deprn_reserve,0)';
     ELSE
         l_source_type_code := 'BACKLOG';
         l_amount1 := 0;
         l_amount2 := 'nvl(idb.deprn_reserve_backlog,0)';
         l_amount3 := 'nvl(idb.deprn_reserve_backlog,0)';
     END IF;

   -- define the insert statement

    l_sql := 'INSERT INTO igi_iac_balances_report(
                 asset_id,
       distribution_ccid,
       source_type_code,
       amount,
       data_source,
       display_order )
       SELECT ad.asset_id
                 ,dh.code_combination_id distribution_ccid
                 ,'''||l_source_type_code||''' source_type_code
                 ,'||l_amount1||' amount
                 ,''Before'' data_source
                 ,''1'' display_order
           FROM fa_deprn_detail dd,
                fa_books bk,
                gl_code_combinations cc,
                fa_additions ad,
                fa_distribution_history dh,
                fa_categories fc,
                igi_iac_reval_asset_rules irar,
                igi_iac_reval_categories irc
     WHERE irc.revaluation_id = '||p_revaluation_id||
     ' AND irar.asset_id = bk.asset_id
     AND irar.revaluation_id = irc.revaluation_id
     AND irar.category_id = irc.category_id
     AND irc.select_category = ''Y''
     AND irar.selected_for_reval_flag = ''Y''
     AND irar.book_type_code = '''||p_book_type_code||'''
     AND bk.book_type_code = irar.book_type_code
     AND bk.asset_id = ad.asset_id
     AND dd.period_counter = (SELECT MAX(period_counter)
                              FROM fa_deprn_summary ds
	                          WHERE ds.asset_id =bk.asset_id
	                          AND ds.book_type_code= '''||p_book_type_code||'''
	                          AND ds.period_counter<= '||p_period_counter||')
     AND EXISTS (SELECT MAX(ith.adjustment_id)
                 FROM igi_iac_transaction_headers ith
                 WHERE   ith.asset_id = bk.asset_id
                 AND ith.book_type_code = '''||p_book_type_code||'''
                 AND ith.adjustment_status NOT IN (''PREVIEW'',''OBSOLETE''))
     AND bk.date_ineffective IS NULL
     AND dh.book_type_code = bk.book_type_code
     AND dd.asset_id= bk.asset_id
     AND dh.asset_id = dd.asset_id
     AND dh.distribution_id = dd.distribution_id
     AND dh.transaction_header_id_out IS NULL
     AND dh.code_combination_id = cc.code_combination_id
     AND fc.category_id=ad.asset_category_id
     AND bk.asset_id NOT IN
            (SELECT asset_id
             FROM igi_iac_asset_balances
             WHERE book_type_code = bk.book_type_code
             AND asset_id = bk.asset_id)
     AND bk.asset_id NOT IN (SELECT asset_id
                             FROM igi_iac_exceptions
                             WHERE revaluation_id = irc.revaluation_id)
     UNION
     SELECT ad.asset_id
      ,dh.code_combination_id distribution_ccid
      ,'''||l_source_type_code||''' source_type_code
      ,'||l_amount2||' amount
      ,''Before'' data_source
      ,''1'' display_order
     FROM igi_iac_det_balances idb,
        fa_deprn_detail dd,
        fa_books bk,
        gl_code_combinations cc,
        fa_additions ad,
        fa_categories fc,
        fa_distribution_history dh ,
        igi_iac_reval_asset_rules irar,
        igi_iac_reval_categories irc
     WHERE irc.revaluation_id = '||p_revaluation_id||'
      AND irar.asset_id = bk.asset_id
     AND irar.selected_for_reval_flag = ''Y''
     AND irar.revaluation_id = irc.revaluation_id
     AND irar.category_id = irc.category_id
     AND irc.select_category = ''Y''
     AND irar.book_type_code = '''||p_book_type_code||'''
     AND bk.book_type_code = irar.book_type_code
     AND bk.asset_id = ad.asset_id
     AND dd.asset_id=bk.asset_id
     AND dd.period_counter =(SELECT max(period_counter)
                           FROM fa_deprn_summary ds
		                   WHERE ds.asset_id =bk.asset_id
                           AND ds.book_type_code='''||p_book_type_code||'''
                           AND ds.period_counter<='||p_period_counter||')
     AND idb.adjustment_id =(SELECT max(ith.adjustment_id)
                           FROM igi_iac_transaction_headers ith
               	           WHERE ith.asset_id = bk.asset_id
                           AND ith.book_type_code ='''||p_book_type_code||'''
                           AND ith.adjustment_status NOT IN (''PREVIEW'', ''OBSOLETE''))
     AND bk.date_ineffective IS NULL
     AND dh.book_type_code = bk.book_type_code
     AND dh.asset_id = dd.asset_id
     AND dh.distribution_id = dd.distribution_id
     AND dh.transaction_header_id_out is NULL
     AND dh.distribution_id = idb.distribution_id
     AND dh.asset_id = idb.asset_id
     AND dh.book_type_code = idb.book_type_code
     AND dh.code_combination_id = cc.code_combination_id
     AND fc.category_id= ad.asset_category_id
     AND bk.asset_id NOT IN (SELECT asset_id
                             FROM igi_iac_exceptions
                             WHERE revaluation_id = irc.revaluation_id)
     UNION
     SELECT ad.asset_id
           ,dh.code_combination_id distribution_ccid
           ,'''||l_source_type_code||''' source_type_code
           ,'||l_amount3||' amount
           ,''After'' data_source
           ,''2'' display_order
     FROM igi_iac_det_balances idb,
          fa_deprn_detail dd,
          fa_books bk,
          gl_code_combinations cc,
          fa_additions ad,
          fa_categories fc,
          fa_distribution_history dh,
          igi_iac_reval_asset_rules irar,
          igi_iac_reval_categories irc
     WHERE irc.revaluation_id = '||p_revaluation_id||'
     and irar.asset_id = bk.asset_id
     and irar.selected_for_reval_flag = ''Y''
     AND irar.revaluation_id = irc.revaluation_id
     AND irar.category_id = irc.category_id
     AND irc.select_category = ''Y''
     and irar.book_type_code = '''||p_book_type_code||'''
     and bk.book_type_code= irar.book_type_code
     and bk.asset_id = ad.asset_id
     and idb.adjustment_id=(select max(ith.adjustment_id)
                       from igi_iac_transaction_headers ith
                       where ith.asset_id = bk.asset_id
                       and ith.book_type_code ='''||p_book_type_code||'''
                       and ith.period_counter <='||p_period_counter||'
                       and ith.adjustment_status=''PREVIEW'')
     and dd.period_counter=(select max(period_counter)
                       from fa_deprn_summary ds
                       where ds.asset_id =bk.asset_id
                       and ds.book_type_code='''||p_book_type_code||'''
                       and ds.period_counter<='||p_period_counter||')
     and bk.date_ineffective is NULL
     and dh.book_type_code = bk.book_type_code
     and dh.asset_id = dd.asset_id
     and dd.asset_id=bk.asset_id
     and dh.distribution_id = dd.distribution_id
     and dh.transaction_header_id_out is NULL
     and dh.distribution_id = idb.distribution_id
     and dh.code_combination_id = cc.code_combination_id
     and fc.category_id=ad.asset_category_id
     AND bk.asset_id NOT IN (SELECT asset_id
                             FROM igi_iac_exceptions
                             WHERE revaluation_id = irc.revaluation_id)
     ';

  --   srw.message(999,l_sql);

     execute immediate l_sql;
    END LOOP;

  END INSERT_INFO;

  FUNCTION DO_INSERTFORMULA RETURN NUMBER IS
  BEGIN
    INSERT_INFO;
    RETURN (1);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END DO_INSERTFORMULA;

  FUNCTION B_REVALUED_COSTFORMULA(BALANCE_TYPE IN VARCHAR2
                                 ,REVALUED_COST IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER;
  BEGIN
    IF (BALANCE_TYPE = 'Before') THEN
      L_NUM := REVALUED_COST;
    END IF;
    RETURN (L_NUM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END B_REVALUED_COSTFORMULA;

  FUNCTION A_REVALUED_COSTFORMULA(BALANCE_TYPE IN VARCHAR2
                                 ,REVALUED_COST IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER;
  BEGIN
    IF (BALANCE_TYPE = 'After') THEN
      L_NUM := REVALUED_COST;
    END IF;
    RETURN (L_NUM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END A_REVALUED_COSTFORMULA;

  FUNCTION B_REVAL_RESERVEFORMULA(BALANCE_TYPE IN VARCHAR2
                                 ,REVALUATION_RESERVE IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER;
  BEGIN
    IF (BALANCE_TYPE = 'Before') THEN
      L_NUM := REVALUATION_RESERVE;
    END IF;
    RETURN (L_NUM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END B_REVAL_RESERVEFORMULA;

  FUNCTION A_REVAL_RESERVEFORMULA(BALANCE_TYPE IN VARCHAR2
                                 ,REVALUATION_RESERVE IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER;
  BEGIN
    IF (BALANCE_TYPE = 'After') THEN
      L_NUM := REVALUATION_RESERVE;
    END IF;
    RETURN (L_NUM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END A_REVAL_RESERVEFORMULA;

  FUNCTION B_OPERATING_ACCTFORMULA(BALANCE_TYPE IN VARCHAR2
                                  ,OPERATING_ACCT IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER;
  BEGIN
    IF (BALANCE_TYPE = 'Before') THEN
      L_NUM := OPERATING_ACCT;
    END IF;
    RETURN (L_NUM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END B_OPERATING_ACCTFORMULA;

  FUNCTION A_OPERATING_ACCTFORMULA(BALANCE_TYPE IN VARCHAR2
                                  ,OPERATING_ACCT IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER;
  BEGIN
    IF (BALANCE_TYPE = 'After') THEN
      L_NUM := OPERATING_ACCT;
    END IF;
    RETURN (L_NUM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END A_OPERATING_ACCTFORMULA;

  FUNCTION B_ACC_DEPRNFORMULA(BALANCE_TYPE IN VARCHAR2
                             ,ACCUMULATED_DEPRECIATION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER;
  BEGIN
    IF (BALANCE_TYPE = 'Before') THEN
      L_NUM := ACCUMULATED_DEPRECIATION;
    END IF;
    RETURN (L_NUM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END B_ACC_DEPRNFORMULA;

  FUNCTION A_ACC_DEPRNFORMULA(BALANCE_TYPE IN VARCHAR2
                             ,ACCUMULATED_DEPRECIATION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER;
  BEGIN
    IF (BALANCE_TYPE = 'After') THEN
      L_NUM := ACCUMULATED_DEPRECIATION;
    END IF;
    RETURN (L_NUM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END A_ACC_DEPRNFORMULA;

  FUNCTION B_ACC_BLOGFORMULA(BALANCE_TYPE IN VARCHAR2
                            ,ACCUMULATED_BACKLOG IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER;
  BEGIN
    IF (BALANCE_TYPE = 'Before') THEN
      L_NUM := ACCUMULATED_BACKLOG;
    END IF;
    RETURN (L_NUM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END B_ACC_BLOGFORMULA;

  FUNCTION A_ACC_BLOGFORMULA(BALANCE_TYPE IN VARCHAR2
                            ,ACCUMULATED_BACKLOG IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER;
  BEGIN
    IF (BALANCE_TYPE = 'After') THEN
      L_NUM := ACCUMULATED_BACKLOG;
    END IF;
    RETURN (L_NUM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END A_ACC_BLOGFORMULA;

  FUNCTION ACCOUNTING_FLEX_STRUCTURE_P RETURN NUMBER IS
  BEGIN
    RETURN ACCOUNTING_FLEX_STRUCTURE;
  END ACCOUNTING_FLEX_STRUCTURE_P;

  FUNCTION CP_REP_FORMAT_DIFF_P RETURN NUMBER IS
  BEGIN
    RETURN CP_REP_FORMAT_DIFF;
  END CP_REP_FORMAT_DIFF_P;

  FUNCTION CP_CO_FORMAT_DIFF_P RETURN NUMBER IS
  BEGIN
    RETURN CP_CO_FORMAT_DIFF;
  END CP_CO_FORMAT_DIFF_P;

  FUNCTION CP_MC_FORMAT_DIFF_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MC_FORMAT_DIFF;
  END CP_MC_FORMAT_DIFF_P;

  FUNCTION F_MINOR_CATEGORY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN F_MINOR_CATEGORY;
  END F_MINOR_CATEGORY_P;

  FUNCTION CP_MAJOR_CATEGORY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_MAJOR_CATEGORY;
  END CP_MAJOR_CATEGORY_P;

  FUNCTION CP_CAT_FORMAT_DIFF_P RETURN NUMBER IS
  BEGIN
    RETURN CP_CAT_FORMAT_DIFF;
  END CP_CAT_FORMAT_DIFF_P;

  FUNCTION CP_COST_ACCT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_COST_ACCT;
  END CP_COST_ACCT_P;

  FUNCTION CP_REVAL_RES_ACCT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REVAL_RES_ACCT;
  END CP_REVAL_RES_ACCT_P;

  FUNCTION CP_ACC_DEPRN_ACCT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ACC_DEPRN_ACCT;
  END CP_ACC_DEPRN_ACCT_P;

  FUNCTION CP_OPERATING_ACCT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_OPERATING_ACCT;
  END CP_OPERATING_ACCT_P;

  FUNCTION CP_BACKLOG_ACCT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BACKLOG_ACCT;
  END CP_BACKLOG_ACCT_P;

  FUNCTION CP_CC_FORMAT_DIFF_P RETURN NUMBER IS
  BEGIN
    RETURN CP_CC_FORMAT_DIFF;
  END CP_CC_FORMAT_DIFF_P;

  FUNCTION CP_A_FORMAT_DIFF_P RETURN NUMBER IS
  BEGIN
    RETURN CP_A_FORMAT_DIFF;
  END CP_A_FORMAT_DIFF_P;

  FUNCTION F_REVAL_RESERVE_DIFF_P RETURN NUMBER IS
  BEGIN
    RETURN F_REVAL_RESERVE_DIFF;
  END F_REVAL_RESERVE_DIFF_P;

  FUNCTION F_REVAL_COST_DIFF_P RETURN NUMBER IS
  BEGIN
    RETURN F_REVAL_COST_DIFF;
  END F_REVAL_COST_DIFF_P;

  FUNCTION F_OPERATING_ACCT_DIFF_P RETURN NUMBER IS
  BEGIN
    RETURN F_OPERATING_ACCT_DIFF;
  END F_OPERATING_ACCT_DIFF_P;

  FUNCTION F_ACC_DEPRN_DIFF_P RETURN NUMBER IS
  BEGIN
    RETURN F_ACC_DEPRN_DIFF;
  END F_ACC_DEPRN_DIFF_P;

  FUNCTION F_ACC_BACKLOG_DIFF_P RETURN NUMBER IS
  BEGIN
    RETURN F_ACC_BACKLOG_DIFF;
  END F_ACC_BACKLOG_DIFF_P;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION CP_PERIOD_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PERIOD_NAME;
  END CP_PERIOD_NAME_P;

  FUNCTION P_FISCAL_YEAR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_FISCAL_YEAR;
  END P_FISCAL_YEAR_P;

  FUNCTION P_BOOK_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_BOOK;
  END P_BOOK_P;

  FUNCTION CP_CURR_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CURR_CODE;
  END CP_CURR_CODE_P;

  FUNCTION CP_ACCOUNT_SEGMENT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ACCOUNT_SEGMENT;
  END CP_ACCOUNT_SEGMENT_P;


function CF_calc_acct_valueFormula( asset_category_id in number,cp_account_segment in VARCHAR2) return Number is

  oper_exp number(15);
  bk_rsv  number(15);
  asset_cost number(15);
  deprn_rsv number(15);
  reval_rsv number(15);
  sql_stmt varchar2(500);
begin


   Select asset_cost_acct,deprn_reserve_acct into
    cp_cost_acct,cp_acc_deprn_acct
    from  fa_category_books
    where book_type_code = p_book_type_code and
    category_id = asset_category_id;

  cp_cost_acct := '('||cp_cost_acct||')';



  select operating_expense_ccid,backlog_deprn_rsv_ccid,reval_rsv_ccid
   into  oper_exp, bk_rsv,reval_rsv
   from igi_iac_category_books where
   book_type_code = p_book_type_code and
   category_id = asset_category_id;


   execute immediate('select ' || cp_account_segment ||'  from  gl_code_combinations cc where
              chart_of_accounts_id= ' || accounting_flex_structure || ' and
	      code_combination_id = '|| oper_exp) into
              cp_operating_acct;

   execute immediate('select ' || cp_account_segment ||'  from  gl_code_combinations cc where
              chart_of_accounts_id= ' || accounting_flex_structure || ' and
	      code_combination_id = '|| bk_rsv) into
              cp_backlog_acct;


   execute immediate('select ' || cp_account_segment ||'  from  gl_code_combinations cc where
              chart_of_accounts_id= ' || accounting_flex_structure || ' and
	      code_combination_id = '|| reval_rsv) into
              cp_reval_res_acct;

        cp_reval_res_acct := '('||cp_reval_res_acct||')';
        cp_operating_acct := '(' || cp_operating_acct ||')';
	cp_acc_deprn_acct := '(' || cp_acc_deprn_acct || '+' || cp_backlog_acct || ')';
	cp_backlog_acct := '('||cp_backlog_acct||')';


  return 1;
end;
END IGI_IGIIARPS_XMLP_PKG;

/
