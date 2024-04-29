--------------------------------------------------------
--  DDL for Package Body JG_JGZZGLJRN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_JGZZGLJRN_XMLP_PKG" AS
/* $Header: JGZZGLJRNB.pls 120.2 2007/12/25 16:06:35 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_EXC_LE_ID NUMBER(15);
    L_ACCTG_CODE VARCHAR2(30);
    T_ERRORBUFFER VARCHAR2(132);
    L_START_DATE DATE;
    L_END_DATE DATE;
    L_LEDGER_TYPE VARCHAR2(100);
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    SELECT
      TO_CHAR(SYSDATE
             ,'YYYY-MM-DD') || 'T' || TO_CHAR(SYSDATE
             ,'HH24:MI:SS'),
      FND_DATE.CANONICAL_TO_DATE(P_START_DATE),
      FND_DATE.CANONICAL_TO_DATE(P_END_DATE)
    INTO REP_EXECUTION_DATE,L_START_DATE,L_END_DATE
    FROM
      DUAL;
    BEGIN
      SELECT
        NAME
      INTO DATA_ACCESS_SET_NAME
      FROM
        GL_ACCESS_SETS
      WHERE ACCESS_SET_ID = P_ACCESS_SET_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        T_ERRORBUFFER := GL_MESSAGE.GET_MESSAGE('GL_PLL_INVALID_DATA_ACCESS_SET'
                                               ,'Y'
                                               ,'DASID'
                                               ,TO_CHAR(P_ACCESS_SET_ID));
        /*SRW.MESSAGE('00'
                   ,T_ERRORBUFFER)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/--RAISE_APPLICATION_ERROR(-20101,null);
      WHEN OTHERS THEN
        T_ERRORBUFFER := SQLERRM;
        /*SRW.MESSAGE('00'
                   ,T_ERRORBUFFER)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/--RAISE_APPLICATION_ERROR(-20101,null);
    END;
    P_LEDGER_FROM := ' ';
    P_LEDGER_WHERE := ' ';
    IF P_LEDGER_ID IS NOT NULL THEN
      BEGIN
        SELECT
          OBJECT_TYPE_CODE
        INTO L_LEDGER_TYPE
        FROM
          GL_LEDGERS
        WHERE LEDGER_ID = P_LEDGER_ID;
      EXCEPTION
        WHEN OTHERS THEN
          T_ERRORBUFFER := SQLERRM;
          /*SRW.MESSAGE('00'
                     ,T_ERRORBUFFER)*/NULL;
          /*RAISE SRW.PROGRAM_ABORT*/--RAISE_APPLICATION_ERROR(-20101,null);
      END;
      IF (L_LEDGER_TYPE = 'S') THEN
        P_LEDGER_FROM := ', GL_LEDGER_SET_ASSIGNMENTS LS ';
        P_LEDGER_WHERE := ' AND LS.ledger_set_id = ' || TO_CHAR(P_LEDGER_ID) || ' AND ' || 'LGR.ledger_id = LS.ledger_id';
      ELSE
        P_LEDGER_FROM := '';
        P_LEDGER_WHERE := ' AND LGR.ledger_id = ' || TO_CHAR(P_LEDGER_ID);
      END IF;
    END IF;
    IF (P_PERIOD_FROM = P_PERIOD_TO) THEN
      PERIOD_WHERE := ' AND GLP.PERIOD_NAME = ''' || P_PERIOD_FROM || '''';
      IF (P_STATUS = 'P') THEN
        IF P_LEDGER_FROM IS NULL THEN
          P_PERIOD_INX_HINT := '  /*+ ORDERED
                                           USE_NL(CC)     INDEX (CC GL_CODE_COMBINATIONS_N2
                                                          INDEX (CC GL_CODE_COMBINATIONS_N3)
                                           USE_NL(GLP)    INDEX (GLP GL_PERIOD_SATTUSES_U3)
                                           USE_NL(GLL)    INDEX (GLL GL_JE_LINES_N1)
                                           USE_NL(GLH)    INDEX (GLH GL_JE_HEADERS_U1)
                                           USE_NL(GLB)    INDEX (GLB GL_JE_BATCHES_U1)
                                           USE_NL(FSV)    INDEX (FSV FUN_SEQ_VERSIONS_U1)
                                           USE_NL(DOCSEQ) INDEX (DOCSEQ FND_DOCUMENT_SEQUENCES_U1)
                                           USE_NL(SRC)    INDEX (SRC GL_JE_SOURCES_TL_U1)
                                           USE_NL(CAT)    INDEX (CAT GL_JE_CATEGORY_TL_U1)
                                           USE_NL(GLC)    INDEX (GLC GL_LEDGER_CONFIGURATIONS_U1)
                                           USE_NL(LOOK)   INDEX (LOOK FND_LOOKUP_VALUES_U1)
                                         */ ';
          P_FROM_CLAUSE := 'GL_CODE_COMBINATIONS CC,  GL_PERIOD_STATUSES GLP,
                                             GL_JE_LINES GLL, GL_JE_HEADERS GLH, GL_LEDGERS LGR,
                                             GL_LEDGER_CONFIGURATIONS glc, GL_JE_BATCHES GLBATCH,
                                             FUN_SEQ_VERSIONS FSV, FND_DOCUMENT_SEQUENCES DOCSEQ,
                                             GL_JE_SOURCES SRC, GL_JE_CATEGORIES CAT, GL_LOOKUPS LOOK ';
        ELSE
          P_PERIOD_INX_HINT := '  /*+ ORDERED
                                           USE_NL(CC)     INDEX (CC GL_CODE_COMBINATIONS_N2
                                                          INDEX (CC GL_CODE_COMBINATIONS_N3)
                                           USE_NL(GLP)    INDEX (GLP GL_PERIOD_SATTUSES_U3)
                                           USE_NL(GLL)    INDEX (GLL GL_JE_LINES_N1)
                                           USE_NL(GLH)    INDEX (GLH GL_JE_HEADERS_U1)
                                           USE_NL(GLB)    INDEX (GLB GL_JE_BATCHES_U1)
                                           USE_NL(FSV)    INDEX (FSV FUN_SEQ_VERSIONS_U1)
                                           USE_NL(DOCSEQ) INDEX (DOCSEQ FND_DOCUMENT_SEQUENCES_U1)
                                           USE_NL(SRC)    INDEX (SRC GL_JE_SOURCES_TL_U1)
                                           USE_NL(CAT)    INDEX (CAT GL_JE_CATEGORY_TL_U1)
                                           USE_NL(GLC)    INDEX (GLC GL_LEDGER_CONFIGURATIONS_U1)
                                           USE_NL(LOOK)   INDEX (LOOK FND_LOOKUP_VALUES_U1)
                                           USE_NL(LS)     INDEX(LS GL_LEDGER_SET_ASSIGNMENTS_N1)
                                         */ ';
          P_FROM_CLAUSE := 'GL_CODE_COMBINATIONS CC,  GL_PERIOD_STATUSES GLP,
                                             GL_JE_LINES GLL, GL_JE_HEADERS GLH, GL_LEDGERS LGR,
                                             GL_LEDGER_CONFIGURATIONS glc, GL_JE_BATCHES GLBATCH,
                                             FUN_SEQ_VERSIONS FSV, FND_DOCUMENT_SEQUENCES DOCSEQ,
                                             GL_JE_SOURCES SRC, GL_JE_CATEGORIES CAT, GL_LOOKUPS LOOK  ' || P_LEDGER_FROM;
        END IF;
      ELSIF ((P_STATUS = 'E') OR (P_STATUS = 'U')) THEN
        P_PERIOD_INX_HINT := '/*+ ORDERED */';
        P_FROM_CLAUSE := ' GL_JE_BATCHES GLBATCH, GL_JE_HEADERS GLH, GL_JE_LINES GLL,
                                            GL_CODE_COMBINATIONS CC,  GL_PERIOD_STATUSES GLP,
                                            GL_LEDGERS LGR, GL_LEDGER_CONFIGURATIONS glc,
                                            FUN_SEQ_VERSIONS FSV, FND_DOCUMENT_SEQUENCES DOCSEQ,
                                            GL_JE_SOURCES SRC, GL_JE_CATEGORIES CAT, GL_LOOKUPS LOOK ' || P_LEDGER_FROM;
      END IF;
    ELSE
      F_PERIOD_NUM := GET_EFF_PERIOD_NUM(P_ACCESS_SET_ID
                                        ,P_PERIOD_FROM);
      T_PERIOD_NUM := GET_EFF_PERIOD_NUM(P_ACCESS_SET_ID
                                        ,P_PERIOD_TO);
      PERIOD_WHERE := ' AND (GLP.EFFECTIVE_PERIOD_NUM BETWEEN ' || F_PERIOD_NUM || ' AND ' || T_PERIOD_NUM || ')';
      IF (P_STATUS = 'P') THEN
        IF P_LEDGER_FROM IS NULL THEN
          P_PERIOD_INX_HINT := ' /*+ ORDERED
                                           USE_NL(CC)     INDEX (CC GL_CODE_COMBINATIONS_N2
                                                          INDEX (CC GL_CODE_COMBINATIONS_N3)
                                           USE_NL(GLP)    INDEX (GLP GL_PERIOD_SATTUSES_U4)
                                           USE_NL(GLL)    INDEX (GLL GL_JE_LINES_N1)
                                           USE_NL(GLH)    INDEX (GLH GL_JE_HEADERS_U1)
                                           USE_NL(GLB)    INDEX (GLB GL_JE_BATCHES_U1)
                                           USE_NL(FSV)    INDEX (FSV FUN_SEQ_VERSIONS_U1)
                                           USE_NL(DOCSEQ) INDEX (DOCSEQ FND_DOCUMENT_SEQUENCES_U1)
                                           USE_NL(SRC)    INDEX (SRC GL_JE_SOURCES_TL_U1)
                                           USE_NL(CAT)    INDEX (CAT GL_JE_CATEGORY_TL_U1)
                                           USE_NL(GLC)    INDEX (GLC GL_LEDGER_CONFIGURATIONS_U1)
                                           USE_NL(LOOK)   INDEX (LOOK FND_LOOKUP_VALUES_U1)
                                         */ ';
          P_FROM_CLAUSE := 'GL_CODE_COMBINATIONS CC,  GL_PERIOD_STATUSES GLP,
                                             GL_JE_LINES GLL, GL_JE_HEADERS GLH, GL_LEDGERS LGR,
                                             GL_LEDGER_CONFIGURATIONS glc, GL_JE_BATCHES GLBATCH,
                                             FUN_SEQ_VERSIONS FSV, FND_DOCUMENT_SEQUENCES DOCSEQ,
                                             GL_JE_SOURCES SRC, GL_JE_CATEGORIES CAT, GL_LOOKUPS LOOK ';
        ELSE
          P_PERIOD_INX_HINT := '  /*+ ORDERED
                                           USE_NL(CC)     INDEX (CC GL_CODE_COMBINATIONS_N2
                                                          INDEX (CC GL_CODE_COMBINATIONS_N3)
                                           USE_NL(GLP)    INDEX (GLP GL_PERIOD_SATTUSES_U4)
                                           USE_NL(GLL)    INDEX (GLL GL_JE_LINES_N1)
                                           USE_NL(GLH)    INDEX (GLH GL_JE_HEADERS_U1)
                                           USE_NL(GLB)    INDEX (GLB GL_JE_BATCHES_U1)
                                           USE_NL(FSV)    INDEX (FSV FUN_SEQ_VERSIONS_U1)
                                           USE_NL(DOCSEQ) INDEX (DOCSEQ FND_DOCUMENT_SEQUENCES_U1)
                                           USE_NL(SRC)    INDEX (SRC GL_JE_SOURCES_TL_U1)
                                           USE_NL(CAT)    INDEX (CAT GL_JE_CATEGORY_TL_U1)
                                           USE_NL(GLC)    INDEX (GLC GL_LEDGER_CONFIGURATIONS_U1)
                                           USE_NL(LOOK)   INDEX (LOOK FND_LOOKUP_VALUES_U1)
                                           USE_NL(LS)     INDEX(LS GL_LEDGER_SET_ASSIGNMENTS_N1)
                                         */ ';
          P_FROM_CLAUSE := 'GL_CODE_COMBINATIONS CC,  GL_PERIOD_STATUSES GLP,
                                             GL_JE_LINES GLL, GL_JE_HEADERS GLH, GL_LEDGERS LGR,
                                             GL_LEDGER_CONFIGURATIONS glc, GL_JE_BATCHES GLBATCH,
                                             FUN_SEQ_VERSIONS FSV, FND_DOCUMENT_SEQUENCES DOCSEQ,
                                             GL_JE_SOURCES SRC, GL_JE_CATEGORIES CAT, GL_LOOKUPS LOOK ' || P_LEDGER_FROM;
        END IF;
      ELSIF ((P_STATUS = 'E') OR (P_STATUS = 'U')) THEN
        P_PERIOD_INX_HINT := '/*+ ORDERED */';
        P_FROM_CLAUSE := ' GL_JE_BATCHES GLBATCH, GL_JE_HEADERS GLH, GL_JE_LINES GLL,
                                            GL_CODE_COMBINATIONS CC,  GL_PERIOD_STATUSES GLP,
                                            GL_LEDGERS LGR, GL_LEDGER_CONFIGURATIONS glc,
                                            FUN_SEQ_VERSIONS FSV, FND_DOCUMENT_SEQUENCES DOCSEQ,
                                            GL_JE_SOURCES SRC, GL_JE_CATEGORIES CAT , GL_LOOKUPS LOOK ' || P_LEDGER_FROM;
      END IF;
    END IF;
    IF ((P_START_DATE IS NOT NULL) OR (P_END_DATE IS NOT NULL)) THEN
      IF (P_START_DATE = P_END_DATE) THEN
        P_DATE_WHERE := ' AND  GLH.Default_Effective_Date = ''' || L_END_DATE || '''';
      ELSIF ((P_START_DATE IS NOT NULL) AND (P_END_DATE IS NULL)) THEN
        P_DATE_WHERE := ' AND  GLH.Default_Effective_Date >= ''' || L_START_DATE || '''';
      ELSIF ((P_START_DATE IS NULL) AND (P_END_DATE IS NOT NULL)) THEN
        P_DATE_WHERE := ' AND  GLH.Default_Effective_Date <= ''' || L_END_DATE || '''';
      ELSE
        P_DATE_WHERE := ' AND  GLH.Default_Effective_Date BETWEEN ''' || L_START_DATE || ''' AND ''' || L_END_DATE || '''';
      END IF;
    END IF;
    DAS_WHERE := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(P_ACCESS_SET_ID
                                                               ,'R'
                                                               ,'LEDGER_COLUMN'
                                                               ,'LEDGER_ID'
                                                               ,'GLP'
                                                               ,'SEG_COLUMN'
                                                               ,NULL
                                                               ,'CC'
                                                               ,NULL);
    IF (DAS_WHERE IS NOT NULL) THEN
      DAS_WHERE := ' AND ' || DAS_WHERE;
    END IF;
    IF (P_STATUS = 'E') THEN
      P_POSTING_STATUS := ' AND ' || ' GLBATCH.STATUS IN ' || '(SELECT LOOKUP_CODE FROM GL_LOOKUPS ' || 'WHERE LOOKUP_TYPE = ''MJE_BATCH_STATUS'' ' || 'AND LOOKUP_CODE NOT IN (''S'', ''I'', ''U'', ''P'')) ';
      P_HEADER_POSTING_STATUS := ' AND GLH.JE_HEADER_ID = GLL.JE_HEADER_ID(+)
                                           AND GLL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID(+) ';
    ELSE
      P_POSTING_STATUS := 'AND GLBATCH.STATUS =  ''' || P_STATUS || '''';
      P_HEADER_POSTING_STATUS := 'AND GLH.JE_HEADER_ID = GLL.JE_HEADER_ID
                                            AND GLL.LEDGER_ID = LGR.ledger_id
                                            AND GLL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID';
    END IF;
    IF (P_BALANCE_TYPE IS NOT NULL) THEN
      P_BALANCE_TYPE_WHERE := ' AND GLH.ACTUAL_FLAG = ''' || P_BALANCE_TYPE || '''';
    END IF;
    IF P_SOURCE IS NOT NULL THEN
      P_SOURCE_WHERE := 'AND GLH.JE_SOURCE = ''' || P_SOURCE || '''';
    END IF;
    IF P_CATEGORY IS NOT NULL THEN
      P_CATEGORY_WHERE := 'AND GLH.JE_CATEGORY = ''' || P_CATEGORY || '''';
    END IF;
    IF P_BATCH_NAME IS NOT NULL THEN
      P_BATCH_WHERE := 'AND GLBATCH.NAME = ''' || P_BATCH_NAME || '''';
    END IF;
    P_DOC_SEQ_WHERE := ' ';
    IF ((P_DOC_SEQ_NAME IS NOT NULL) OR (P_START_DOC_VALUE IS NOT NULL) OR (P_END_DOC_VALUE IS NOT NULL)) THEN
      IF P_DOC_SEQ_NAME IS NOT NULL THEN
        P_DOC_SEQ_WHERE := ' AND GLH.DOC_SEQUENCE_ID = ' || P_DOC_SEQ_NAME;
      END IF;
      IF (P_START_DOC_VALUE IS NULL) AND (P_END_DOC_VALUE IS NOT NULL) THEN
        P_DOC_SEQ_WHERE := P_DOC_SEQ_WHERE || ' AND GLH.DOC_SEQUENCE_VALUE <= ''' || P_END_DOC_VALUE || '''';
      ELSIF (P_START_DOC_VALUE IS NOT NULL) AND (P_END_DOC_VALUE IS NULL) THEN
        P_DOC_SEQ_WHERE := P_DOC_SEQ_WHERE || ' AND GLH.DOC_SEQUENCE_VALUE >= ''' || P_START_DOC_VALUE || '''';
      ELSIF (P_START_DOC_VALUE IS NOT NULL) AND (P_END_DOC_VALUE IS NOT NULL) THEN
        P_DOC_SEQ_WHERE := P_DOC_SEQ_WHERE || ' AND GLH.DOC_SEQUENCE_VALUE BETWEEN ''' || P_START_DOC_VALUE || ''' AND ''' || P_END_DOC_VALUE || '''';
      END IF;
    END IF;
    GL_SECURITY_PKG.INIT_SEGVAL;
    SEG_SECURITY_WHERE := 'AND gl_security_pkg.validate_access(LGR.ledger_id, cc.code_combination_id) = ''TRUE'' ';
    IF (P_CURRENCY_CODE IS NOT NULL) THEN
      CURR_WHERE_JRNL := 'AND GLH.CURRENCY_CODE = ''' || P_CURRENCY_CODE || '''';
    ELSE
      CURR_WHERE_JRNL := 'AND GLH.Currency_Code <> ''STAT''';
    END IF;
    BEGIN
      /*SRW.REFERENCE(P_COA_ID)*/NULL;
      IF P_ACCT_FROM IS NOT NULL AND P_ACCT_TO IS NOT NULL THEN
        IF TEMP_ACCT_WHERE IS NOT NULL THEN
          ACCT_WHERE := 'AND ' || TEMP_ACCT_WHERE;
        END IF;
      END IF;
    EXCEPTION
      WHEN /*SRW.UNKNOWN_USER_EXIT*/OTHERS THEN
        /*SRW.MESSAGE(13
                   ,'FND FLEXSQL USER EXIT IS NOT KNOWN.')*/NULL;
        RAISE;
      /*WHEN SRW.USER_EXIT_FAILURE OTHERS THEN
        SRW.MESSAGE(14
                   ,'FND FLEXSQL USER EXIT FAILED.')*/NULL;
        RAISE;
      /*WHEN OTHERS THEN*/
        T_ERRORBUFFER := SQLERRM;
        /*SRW.MESSAGE('00'
                   ,T_ERRORBUFFER)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/--RAISE_APPLICATION_ERROR(-20101,null);
    END;
    CHART_OF_ACCOUNTS_ID := P_COA_ID;
    PERIOD_FROM_PARAM := P_PERIOD_FROM;
    PERIOD_TO_PARAM := P_PERIOD_TO;
    ACCT_FROM_PARAM := P_ACCT_FROM;
    ACCT_TO_PARAM := P_ACCT_TO;
    PAGE_NUM_FORMAT_PARAM := P_PAGE_NUM_FORMAT;
    PAGE_NUM_START_PARAM := P_FIRST_PAGE_NUM;
    USER_PARAM_1 := P_USER_PARAM_1;
    USER_PARAM_2 := P_USER_PARAM_2;
    USER_PARAM_3 := P_USER_PARAM_3;
    USER_PARAM_4 := P_USER_PARAM_4;
    USER_PARAM_5 := P_USER_PARAM_5;
    CURRENCY_PARAM := P_CURRENCY_CODE;
    START_DATE_PARAM := P_START_DATE;
    END_DATE_PARAM := P_END_DATE;
    SELECT
      MEANING
    INTO POSTING_STATUS_PARAM
    FROM
      GL_LOOKUPS
    WHERE LOOKUP_CODE = P_STATUS
      AND LOOKUP_TYPE = 'JOURNAL_REPORT_TYPE';
    IF P_BALANCE_TYPE IS NOT NULL THEN
      SELECT
        DESCRIPTION
      INTO BALANCE_TYPE_PARAM
      FROM
        GL_LOOKUPS
      WHERE LOOKUP_TYPE = 'BATCH_TYPE'
        AND LOOKUP_CODE = P_BALANCE_TYPE;
    END IF;
    IF P_SOURCE IS NOT NULL THEN
      SELECT
        USER_JE_SOURCE_NAME
      INTO JRNL_SOURCE_PARAM
      FROM
        GL_JE_SOURCES
      WHERE JE_SOURCE_NAME = P_SOURCE;
    END IF;
    IF P_CATEGORY IS NOT NULL THEN
      SELECT
        USER_JE_CATEGORY_NAME
      INTO JRNL_CATEGORY_PARAM
      FROM
        GL_JE_CATEGORIES
      WHERE JE_CATEGORY_NAME = P_CATEGORY;
    END IF;
    BATCH_NAME_PARAM := P_BATCH_NAME;
    IF P_DOC_SEQ_NAME IS NOT NULL THEN
      SELECT
        NAME
      INTO DOC_SEQ_NAME_PARAM
      FROM
        FND_DOCUMENT_SEQUENCES
      WHERE DOC_SEQUENCE_ID = P_DOC_SEQ_NAME;
    END IF;
    START_DOC_SEQ_NUM_PARAM := P_START_DOC_VALUE;
    END_DOC_SEQ_NUM_PARAM := P_END_DOC_VALUE;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION SECONDARY_TRACK_SEGMENT_DESCFO RETURN CHAR IS
  BEGIN
    RETURN NULL;
  END SECONDARY_TRACK_SEGMENT_DESCFO;

  FUNCTION LEGAL_ENTITY_NAMEFORMULA(LEGAL_ENTITY_ID IN NUMBER
                                   ,LEGAL_ENTITY_NAME IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(LEGAL_ENTITY_ID)*/NULL;
    IF (TEMP_LE_ID = LEGAL_ENTITY_ID) THEN
      RETURN (TEMP_LE_NAME);
    ELSIF LEGAL_ENTITY_ID IS NOT NULL THEN
      GET_LE_INFO(LEGAL_ENTITY_ID);
      RETURN (TEMP_LE_NAME);
    END IF;
    RETURN (LEGAL_ENTITY_NAME);
  END LEGAL_ENTITY_NAMEFORMULA;

  PROCEDURE GET_LE_INFO(V_LE_ID IN NUMBER) IS
    T_ERRORBUFFER VARCHAR2(132);
  BEGIN
    TEMP_LE_ID := V_LE_ID;
    SELECT
      NAME,
      LTRIM(ADDRESS_LINE_1),
      LTRIM(ADDRESS_LINE_2),
      LTRIM(ADDRESS_LINE_3),
      LTRIM(TOWN_OR_CITY),
      LTRIM(POSTAL_CODE),
      ACTIVITY_CODE,
      REGISTRATION_NUMBER
    INTO TEMP_LE_NAME,TEMP_ADDR1,TEMP_ADDR2,TEMP_ADDR3,TEMP_TOWN_CITY,TEMP_POSTAL_CODE,TEMP_SERVICE_TYPE,TEMP_TAX_PAYER_ID
    FROM
      XLE_FIRSTPARTY_INFORMATION_V
    WHERE LEGAL_ENTITY_ID = V_LE_ID;
  EXCEPTION
    WHEN OTHERS THEN
      T_ERRORBUFFER := SQLERRM;
      /*SRW.MESSAGE('00'
                 ,T_ERRORBUFFER)*/NULL;
  END GET_LE_INFO;

  FUNCTION LE_ADDRESS_LINE_1FORMULA(LEGAL_ENTITY_ID IN NUMBER
                                   ,LE_ADDRESS_LINE_1 IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(LEGAL_ENTITY_ID)*/NULL;
    IF (TEMP_LE_ID = LEGAL_ENTITY_ID) THEN
      RETURN (TEMP_ADDR1);
    ELSIF LEGAL_ENTITY_ID IS NOT NULL THEN
      GET_LE_INFO(LEGAL_ENTITY_ID);
      RETURN (TEMP_ADDR1);
    END IF;
    RETURN (LE_ADDRESS_LINE_1);
  END LE_ADDRESS_LINE_1FORMULA;

  FUNCTION LE_ADDRESS_LINE_2FORMULA(LEGAL_ENTITY_ID IN NUMBER
                                   ,LE_ADDRESS_LINE_2 IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(LEGAL_ENTITY_ID)*/NULL;
    IF (TEMP_LE_ID = LEGAL_ENTITY_ID) THEN
      RETURN (TEMP_ADDR2);
    ELSIF LEGAL_ENTITY_ID IS NOT NULL THEN
      GET_LE_INFO(LEGAL_ENTITY_ID);
      RETURN (TEMP_ADDR2);
    END IF;
    RETURN (LE_ADDRESS_LINE_2);
  END LE_ADDRESS_LINE_2FORMULA;

  FUNCTION LE_ADDRESS_LINE_3FORMULA(LEGAL_ENTITY_ID IN NUMBER
                                   ,LE_ADDRESS_LINE_3 IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(LEGAL_ENTITY_ID)*/NULL;
    IF (TEMP_LE_ID = LEGAL_ENTITY_ID) THEN
      RETURN (TEMP_ADDR3);
    ELSIF LEGAL_ENTITY_ID IS NOT NULL THEN
      GET_LE_INFO(LEGAL_ENTITY_ID);
      RETURN (TEMP_ADDR3);
    END IF;
    RETURN (LE_ADDRESS_LINE_3);
  END LE_ADDRESS_LINE_3FORMULA;

  FUNCTION LE_CITYFORMULA(LEGAL_ENTITY_ID IN NUMBER
                         ,LE_CITY IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(LEGAL_ENTITY_ID)*/NULL;
    IF (TEMP_LE_ID = LEGAL_ENTITY_ID) THEN
      RETURN (TEMP_TOWN_CITY);
    ELSIF LEGAL_ENTITY_ID IS NOT NULL THEN
      GET_LE_INFO(LEGAL_ENTITY_ID);
      RETURN (TEMP_TOWN_CITY);
    END IF;
    RETURN (LE_CITY);
  END LE_CITYFORMULA;

  FUNCTION LE_POSTAL_CODEFORMULA(LEGAL_ENTITY_ID IN NUMBER
                                ,LE_POSTAL_CODE IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(LEGAL_ENTITY_ID)*/NULL;
    IF (TEMP_LE_ID = LEGAL_ENTITY_ID) THEN
      RETURN (TEMP_POSTAL_CODE);
    ELSIF LEGAL_ENTITY_ID IS NOT NULL THEN
      GET_LE_INFO(LEGAL_ENTITY_ID);
      RETURN (TEMP_POSTAL_CODE);
    END IF;
    RETURN (LE_POSTAL_CODE);
  END LE_POSTAL_CODEFORMULA;

  FUNCTION LE_REGISTRATION_NUMBERFORMULA(LEGAL_ENTITY_ID IN NUMBER
                                        ,LE_REGISTRATION_NUMBER IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(LEGAL_ENTITY_ID)*/NULL;
    IF (TEMP_LE_ID = LEGAL_ENTITY_ID) THEN
      RETURN (TEMP_TAX_PAYER_ID);
    ELSIF LEGAL_ENTITY_ID IS NOT NULL THEN
      GET_LE_INFO(LEGAL_ENTITY_ID);
      RETURN (TEMP_TAX_PAYER_ID);
    END IF;
    RETURN (LE_REGISTRATION_NUMBER);
  END LE_REGISTRATION_NUMBERFORMULA;

  FUNCTION LE_ACTIVITY_CODEFORMULA(LEGAL_ENTITY_ID IN NUMBER
                                  ,LE_ACTIVITY_CODE IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(LEGAL_ENTITY_ID)*/NULL;
    IF (TEMP_LE_ID = LEGAL_ENTITY_ID) THEN
      RETURN (TEMP_SERVICE_TYPE);
    ELSIF LEGAL_ENTITY_ID IS NOT NULL THEN
      GET_LE_INFO(LEGAL_ENTITY_ID);
      RETURN (TEMP_SERVICE_TYPE);
    END IF;
    RETURN (LE_ACTIVITY_CODE);
  END LE_ACTIVITY_CODEFORMULA;

  FUNCTION GET_EFF_PERIOD_NUM(ACC_SET_ID IN NUMBER
                             ,PNAME IN VARCHAR2) RETURN NUMBER IS
    EPERNUM NUMBER;
  BEGIN
    SELECT
      PER.PERIOD_YEAR * 10000 + PER.PERIOD_NUM
    INTO EPERNUM
    FROM
      GL_ACCESS_SETS AC,
      GL_PERIODS PER
    WHERE AC.ACCESS_SET_ID = ACC_SET_ID
      AND PER.PERIOD_SET_NAME = AC.PERIOD_SET_NAME
      AND PER.PERIOD_NAME = PNAME;
    RETURN (EPERNUM);
  END GET_EFF_PERIOD_NUM;

  FUNCTION LEGAL_ENTITY_IDFORMULA(LEDGER_ID_V IN NUMBER
                                 ,ENVIRONMENT_CODE IN VARCHAR2
                                 ,CONFIGURATION_ID_V IN NUMBER
                                 ,BALANCING_SEGMENT_VALUE IN VARCHAR2) RETURN NUMBER IS
    L_LEGAL_ID NUMBER := 0;
  BEGIN
    /*SRW.REFERENCE(LEDGER_ID)*/NULL;
    /*SRW.REFERENCE(ENVIRONMENT_CODE)*/NULL;
    IF ((NVL(TEMP_LEDGER_ID
       ,0) = LEDGER_ID_V) AND (NVL(TEMP_ENVIRONMENT_CODE
       ,'X') = ENVIRONMENT_CODE)) THEN
      RETURN (TEMP_LEGAL_ENTITY_ID);
    ELSIF CONFIGURATION_ID_V IS NOT NULL THEN
      IF (ENVIRONMENT_CODE = 'EXCLUSIVE') THEN
        SELECT
          GLCD.OBJECT_ID
        INTO L_LEGAL_ID
        FROM
          GL_LEDGER_CONFIG_DETAILS GLCD
        WHERE GLCD.CONFIGURATION_ID = CONFIGURATION_ID_V
          AND GLCD.OBJECT_TYPE_CODE = 'LEGAL_ENTITY';
      ELSE
        SELECT
          GLNS.LEGAL_ENTITY_ID
        INTO L_LEGAL_ID
        FROM
          GL_LEDGER_NORM_SEG_VALS GLNS
        WHERE glns.ledger_id (+) = LEDGER_ID_V
          AND glns.segment_type_code (+) = 'B'
          AND glns.segment_value (+) = BALANCING_SEGMENT_VALUE
          AND NVL(status_code (+),
            'I') <> 'D';
      END IF;
      TEMP_LEGAL_ENTITY_ID := L_LEGAL_ID;
      TEMP_LEDGER_ID := LEDGER_ID_V;
      TEMP_ENVIRONMENT_CODE := ENVIRONMENT_CODE;
    END IF;
    RETURN (L_LEGAL_ID);
  END LEGAL_ENTITY_IDFORMULA;

  FUNCTION CF_LEDGER_NAMEFORMULA(LEDGER_NAME IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF (NVL(LEDGER_NAME_PARAM
       ,'X') <> LEDGER_NAME) THEN
      LEDGER_NAME_PARAM := LEDGER_NAME;
    END IF;
    RETURN (LEDGER_NAME_PARAM);
  END CF_LEDGER_NAMEFORMULA;

  FUNCTION DATA_ACCESS_SET_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN DATA_ACCESS_SET_NAME;
  END DATA_ACCESS_SET_NAME_P;

  FUNCTION CHART_OF_ACCOUNTS_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CHART_OF_ACCOUNTS_ID;
  END CHART_OF_ACCOUNTS_ID_P;

  FUNCTION DAS_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN DAS_WHERE;
  END DAS_WHERE_P;

  FUNCTION CURR_WHERE_JRNL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CURR_WHERE_JRNL;
  END CURR_WHERE_JRNL_P;

  FUNCTION PERIOD_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN PERIOD_WHERE;
  END PERIOD_WHERE_P;

  FUNCTION ACCT_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ACCT_WHERE;
  END ACCT_WHERE_P;

  FUNCTION SELECT_ACCOUNT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_ACCOUNT;
  END SELECT_ACCOUNT_P;

  FUNCTION SELECT_ACCT_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_ACCT_SEG;
  END SELECT_ACCT_SEG_P;

  FUNCTION SELECT_BAL_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_BAL_SEG;
  END SELECT_BAL_SEG_P;

  FUNCTION TEMP_ACCT_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TEMP_ACCT_WHERE;
  END TEMP_ACCT_WHERE_P;

  FUNCTION TEMP_LE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TEMP_LE_NAME;
  END TEMP_LE_NAME_P;

  FUNCTION TEMP_TAX_PAYER_ID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TEMP_TAX_PAYER_ID;
  END TEMP_TAX_PAYER_ID_P;

  FUNCTION TEMP_SERVICE_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TEMP_SERVICE_TYPE;
  END TEMP_SERVICE_TYPE_P;

  FUNCTION TEMP_ADDR1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TEMP_ADDR1;
  END TEMP_ADDR1_P;

  FUNCTION TEMP_ADDR2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TEMP_ADDR2;
  END TEMP_ADDR2_P;

  FUNCTION FP_START_DATE_P RETURN DATE IS
  BEGIN
    RETURN FP_START_DATE;
  END FP_START_DATE_P;

  FUNCTION TP_END_DATE_P RETURN DATE IS
  BEGIN
    RETURN TP_END_DATE;
  END TP_END_DATE_P;

  FUNCTION LE_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN LE_WHERE;
  END LE_WHERE_P;

  FUNCTION SELECT_IC_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_IC_SEG;
  END SELECT_IC_SEG_P;

  FUNCTION SELECT_MGT_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_MGT_SEG;
  END SELECT_MGT_SEG_P;

  FUNCTION SELECT_ST_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_ST_SEG;
  END SELECT_ST_SEG_P;

  FUNCTION SELECT_LE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_LE;
  END SELECT_LE_P;

  FUNCTION FROM_LNSV_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_LNSV;
  END FROM_LNSV_P;

  FUNCTION REP_EXECUTION_DATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REP_EXECUTION_DATE;
  END REP_EXECUTION_DATE_P;

  FUNCTION TEMP_ADDR3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TEMP_ADDR3;
  END TEMP_ADDR3_P;

  FUNCTION TEMP_TOWN_CITY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TEMP_TOWN_CITY;
  END TEMP_TOWN_CITY_P;

  FUNCTION TEMP_POSTAL_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TEMP_POSTAL_CODE;
  END TEMP_POSTAL_CODE_P;

  FUNCTION TEMP_LE_ID_P RETURN NUMBER IS
  BEGIN
    RETURN TEMP_LE_ID;
  END TEMP_LE_ID_P;

  FUNCTION START_DATE_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN START_DATE_PARAM;
  END START_DATE_PARAM_P;

  FUNCTION END_DATE_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN END_DATE_PARAM;
  END END_DATE_PARAM_P;

  FUNCTION SELECT_CC_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_CC_SEG;
  END SELECT_CC_SEG_P;

  FUNCTION PAGE_NUM_FORMAT_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN PAGE_NUM_FORMAT_PARAM;
  END PAGE_NUM_FORMAT_PARAM_P;

  FUNCTION CURRENCY_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CURRENCY_PARAM;
  END CURRENCY_PARAM_P;

  FUNCTION PERIOD_TO_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN PERIOD_TO_PARAM;
  END PERIOD_TO_PARAM_P;

  FUNCTION PERIOD_FROM_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN PERIOD_FROM_PARAM;
  END PERIOD_FROM_PARAM_P;

  FUNCTION ACCT_TO_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ACCT_TO_PARAM;
  END ACCT_TO_PARAM_P;

  FUNCTION ACCT_FROM_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ACCT_FROM_PARAM;
  END ACCT_FROM_PARAM_P;

  FUNCTION LEDGER_NAME_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN LEDGER_NAME_PARAM;
  END LEDGER_NAME_PARAM_P;

  FUNCTION F_PERIOD_NUM_P RETURN NUMBER IS
  BEGIN
    RETURN F_PERIOD_NUM;
  END F_PERIOD_NUM_P;

  FUNCTION T_PERIOD_NUM_P RETURN NUMBER IS
  BEGIN
    RETURN T_PERIOD_NUM;
  END T_PERIOD_NUM_P;

  FUNCTION BALANCE_TYPE_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN BALANCE_TYPE_PARAM;
  END BALANCE_TYPE_PARAM_P;

  FUNCTION PAGE_NUM_START_PARAM_P RETURN NUMBER IS
  BEGIN
    RETURN PAGE_NUM_START_PARAM;
  END PAGE_NUM_START_PARAM_P;

  FUNCTION USER_PARAM_1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN USER_PARAM_1;
  END USER_PARAM_1_P;

  FUNCTION USER_PARAM_2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN USER_PARAM_2;
  END USER_PARAM_2_P;

  FUNCTION USER_PARAM_3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN USER_PARAM_3;
  END USER_PARAM_3_P;

  FUNCTION USER_PARAM_4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN USER_PARAM_4;
  END USER_PARAM_4_P;

  FUNCTION USER_PARAM_5_P RETURN VARCHAR2 IS
  BEGIN
    RETURN USER_PARAM_5;
  END USER_PARAM_5_P;

  FUNCTION SELECT_DR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_DR;
  END SELECT_DR_P;

  FUNCTION SELECT_CR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_CR;
  END SELECT_CR_P;

  FUNCTION SELECT_BEGIN_BAL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_BEGIN_BAL;
  END SELECT_BEGIN_BAL_P;

  FUNCTION ACCT_SEG_VALUE_SET_ID_P RETURN NUMBER IS
  BEGIN
    RETURN ACCT_SEG_VALUE_SET_ID;
  END ACCT_SEG_VALUE_SET_ID_P;

  FUNCTION SEG_SECURITY_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SEG_SECURITY_WHERE;
  END SEG_SECURITY_WHERE_P;

  FUNCTION P_POSTING_STATUS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_POSTING_STATUS;
  END P_POSTING_STATUS_P;

  FUNCTION P_HEADER_POSTING_STATUS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_HEADER_POSTING_STATUS;
  END P_HEADER_POSTING_STATUS_P;

  FUNCTION P_BALANCE_TYPE_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_BALANCE_TYPE_WHERE;
  END P_BALANCE_TYPE_WHERE_P;

  FUNCTION P_SOURCE_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_SOURCE_WHERE;
  END P_SOURCE_WHERE_P;

  FUNCTION P_CATEGORY_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_CATEGORY_WHERE;
  END P_CATEGORY_WHERE_P;

  FUNCTION P_BATCH_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_BATCH_WHERE;
  END P_BATCH_WHERE_P;

  FUNCTION P_DOC_SEQ_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_DOC_SEQ_WHERE;
  END P_DOC_SEQ_WHERE_P;

  FUNCTION P_DATE_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_DATE_WHERE;
  END P_DATE_WHERE_P;

  FUNCTION P_LEDGER_FROM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_LEDGER_FROM;
  END P_LEDGER_FROM_P;

  FUNCTION P_LEDGER_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_LEDGER_WHERE;
  END P_LEDGER_WHERE_P;

  FUNCTION TEMP_ENVIRONMENT_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TEMP_ENVIRONMENT_CODE;
  END TEMP_ENVIRONMENT_CODE_P;

  FUNCTION TEMP_LEDGER_ID_P RETURN NUMBER IS
  BEGIN
    RETURN TEMP_LEDGER_ID;
  END TEMP_LEDGER_ID_P;

  FUNCTION TEMP_LEGAL_ENTITY_ID_P RETURN NUMBER IS
  BEGIN
    RETURN TEMP_LEGAL_ENTITY_ID;
  END TEMP_LEGAL_ENTITY_ID_P;

  FUNCTION JRNL_SOURCE_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN JRNL_SOURCE_PARAM;
  END JRNL_SOURCE_PARAM_P;

  FUNCTION JRNL_CATEGORY_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN JRNL_CATEGORY_PARAM;
  END JRNL_CATEGORY_PARAM_P;

  FUNCTION BATCH_NAME_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN BATCH_NAME_PARAM;
  END BATCH_NAME_PARAM_P;

  FUNCTION DOC_SEQ_NAME_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN DOC_SEQ_NAME_PARAM;
  END DOC_SEQ_NAME_PARAM_P;

  FUNCTION START_DOC_SEQ_NUM_PARAM_P RETURN NUMBER IS
  BEGIN
    RETURN START_DOC_SEQ_NUM_PARAM;
  END START_DOC_SEQ_NUM_PARAM_P;

  FUNCTION END_DOC_SEQ_NUM_PARAM_P RETURN NUMBER IS
  BEGIN
    RETURN END_DOC_SEQ_NUM_PARAM;
  END END_DOC_SEQ_NUM_PARAM_P;

  FUNCTION POSTING_STATUS_PARAM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN POSTING_STATUS_PARAM;
  END POSTING_STATUS_PARAM_P;

  FUNCTION P_PERIOD_INX_HINT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_PERIOD_INX_HINT;
  END P_PERIOD_INX_HINT_P;

  FUNCTION P_FROM_CLAUSE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_FROM_CLAUSE;
  END P_FROM_CLAUSE_P;

END JG_JGZZGLJRN_XMLP_PKG;



/