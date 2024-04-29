--------------------------------------------------------
--  DDL for Package Body IGI_IGIPCBAP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGIPCBAP_XMLP_PKG" AS
/* $Header: IGIPCBAPB.pls 120.0.12010000.1 2008/07/29 08:59:00 appldev ship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    IF P_RUN_AOL = 'Y' THEN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    END IF;
    GET_PREVIOUS_YEAR;
    IF P_DEBUG_SWITCH = 'Y' THEN
      /*SRW.MESSAGE(100
                 ,' Completed GET_PREVIOUS_YEAR')*/NULL;
    END IF;
    GET_CURRENT_YEAR;
    IF P_DEBUG_SWITCH = 'Y' THEN
      /*SRW.MESSAGE(101
                 ,'Completed GET_CURRENT_YEAR ')*/NULL;
    END IF;
    FIND_INVOICE;
    IF P_DEBUG_SWITCH = 'Y' THEN
      /*SRW.MESSAGE(102
                 ,'Completed FIND_INVOICE')*/NULL;
    END IF;
    FIND_CLOSING_BALANCE;
    IF P_DEBUG_SWITCH = 'Y' THEN
      /*SRW.MESSAGE(103
                 ,'Completed FIND_CLOSING_BALANCE')*/NULL;
    END IF;
    INSERT_INTERFACE;
    IF P_DEBUG_SWITCH = 'Y' THEN
      /*SRW.MESSAGE(104
                 ,'Completed INSERT_INTERFACE ')*/NULL;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    SELECT
      GP.END_DATE,
      GSOB.CURRENCY_CODE
    INTO LP_END_DATE,LP_CURRENCY_CODE
    FROM
      GL_PERIODS GP,
      GL_SETS_OF_BOOKS GSOB
    WHERE GSOB.SET_OF_BOOKS_ID = P_SOB_ID
      AND GSOB.PERIOD_SET_NAME = GP.PERIOD_SET_NAME
      AND GP.PERIOD_NAME = P_TO_PERIOD;
    IF P_FROM_PERIOD IS NOT NULL THEN
      SELECT
        GP.START_DATE
      INTO LP_START_DATE
      FROM
        GL_PERIODS GP,
        GL_SETS_OF_BOOKS GSOB
      WHERE GSOB.SET_OF_BOOKS_ID = P_SOB_ID
        AND GSOB.PERIOD_SET_NAME = GP.PERIOD_SET_NAME
        AND GP.PERIOD_NAME = P_FROM_PERIOD;
    ELSE
      SELECT
        GP.START_DATE
      INTO LP_START_DATE
      FROM
        GL_PERIODS GP,
        GL_SETS_OF_BOOKS GSOB
      WHERE GSOB.SET_OF_BOOKS_ID = P_SOB_ID
        AND GSOB.PERIOD_SET_NAME = GP.PERIOD_SET_NAME
        AND GP.PERIOD_NUM = 1
        AND GP.PERIOD_TYPE = GSOB.ACCOUNTED_PERIOD_TYPE
        AND GP.PERIOD_YEAR = (
        SELECT
          G.PERIOD_YEAR
        FROM
          GL_PERIODS G,
          GL_SETS_OF_BOOKS GS
        WHERE GS.SET_OF_BOOKS_ID = P_SOB_ID
          AND GS.PERIOD_SET_NAME = G.PERIOD_SET_NAME
          AND G.PERIOD_NAME = P_TO_PERIOD );
    END IF;
    SELECT
      TO_CHAR(TO_DATE('3112'
                     ,' DDMM')
             ,'DD-MON-') || TO_CHAR(ADD_MONTHS(TO_DATE(LP_END_DATE
                                ,'DD-MON-RRRR')
                        ,-12)
             ,'RRRR')
    INTO LP_LAST_DAY
    FROM
      SYS.DUAL;
    LP_YEAR := TO_CHAR(TO_DATE(LP_LAST_DAY
                              ,'DD-MON-RRRR')
                      ,'RRRR');
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    ROLLBACK;
    IF P_DEBUG_SWITCH = 'Y' THEN
      /*SRW.MESSAGE(110
                 ,'Report has completed')*/NULL;
    END IF;
    IF P_RUN_AOL = 'Y' THEN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END IF;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_SOB_NAMEFORMULA RETURN CHAR IS
    L_NAME GL_SETS_OF_BOOKS.NAME%TYPE;
  BEGIN
    SELECT
      NAME
    INTO L_NAME
    FROM
      GL_SETS_OF_BOOKS
    WHERE SET_OF_BOOKS_ID = P_SOB_ID;
    RETURN (L_NAME);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      /*SRW.MESSAGE(200
                 ,'ERROR: Set of Books was not found!')*/NULL;
  END CF_SOB_NAMEFORMULA;

  FUNCTION CF_NO_DATAFORMULA(INVOICE_NUM IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF INVOICE_NUM IS NOT NULL THEN
      CP_NO_DATA_FOUND := 'Y';
    END IF;
    RETURN (0);
  END CF_NO_DATAFORMULA;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION BETWEENPAGE RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BETWEENPAGE;

  FUNCTION P_SOB_IDVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_SOB_IDVALIDTRIGGER;

  FUNCTION CP_NO_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NO_DATA_FOUND;
  END CP_NO_DATA_FOUND_P;

  PROCEDURE FIND_CLOSING_BALANCE IS
    L_SEGMENT VARCHAR2(25);
    L_INSERT VARCHAR2(5000);
  BEGIN
    L_SEGMENT := P_ACCT_SEGMENT;
    L_INSERT := 'INSERT INTO IGI_CBR_AP_RECONCILE(
                		ACCOUNT_NUM
                	, 	INVOICE_AMOUNT
                	, 	ORG_ID
                	, 	TYPE)
                	SELECT	gcc.' || L_SEGMENT || '  account
                	, 	SUM(idv.amount * (air.remainder) /
                			DECODE(	ai.invoice_currency_code,
                				asp.base_currency_code,
                				DECODE(	ai.invoice_amount, 0, 1, ai.invoice_amount),
                					DECODE(ai.base_amount, 0, 1, ai.base_amount)) )  invoice_amount
                	, 	ai.org_id
                	, 	''UB'' Type
                	FROM	AP_INVOICES_ALL 	 AI
                	, 	PO_VENDORS 		 PV
                	, 	IGI_CBR_AP_INV_RECONCILE AIR
                	, 	IGI_CBR_AP_INV_DIST_V	 IDV
                	, 	AP_SYSTEM_PARAMETERS_ALL ASP
                	, 	GL_CODE_COMBINATIONS	 GCC
                	WHERE	ai.set_of_books_id	= ' || P_SOB_ID || '
                	AND	ai.invoice_id		= idv.invoice_id
                	AND	ai.invoice_id		= air.invoice_id
                	AND	ai.vendor_id		= pv.vendor_id
                	AND	asp.set_of_books_id	= ai.set_of_books_id
                	AND	NVL(ai.org_id, -1)	= NVL(asp.org_id, -1)
                	AND	gcc.code_combination_id	= idv.dist_code_combination_id
                	AND	gcc.enabled_flag	= ''Y''
                	AND	air.status		= ''P''
                	AND	gcc.' || L_SEGMENT || ' BETWEEN ''' || P_FROM_SEGMENT || ''' AND ''' || P_TO_SEGMENT || '''
                	GROUP BY
                		gcc.' || L_SEGMENT || '
                	,	ai.org_id';
    EXECUTE IMMEDIATE
      L_INSERT;
  END FIND_CLOSING_BALANCE;

  PROCEDURE FIND_INVOICE IS
    L_SEGMENT VARCHAR2(25);
    L_INSERT VARCHAR2(5000);
  BEGIN
    L_SEGMENT := P_ACCT_SEGMENT;
    L_INSERT := 'INSERT INTO IGI_CBR_AP_RECONCILE(
                		ACCOUNT_NUM
                	, 	DOC_SEQ_NUM
                	, 	INVOICE_NUM
                	, 	VENDOR_NUM
                	, 	VENDOR_NAME
                	, 	INVOICE_DATE
                	, 	ORG_ID
                	, 	INVOICE_AMOUNT)
                	SELECT	gcc.' || L_SEGMENT || ' 	account
                	, 	ai.doc_sequence_value	doc_sec_num
                	, 	ai.invoice_num
                	, 	pv.segment1
                	, 	pv.vendor_name
                	, 	ai.invoice_date
                	, 	ai.org_id
                	, 	(idv.amount * air.remainder) /
                			DECODE(	ai.invoice_currency_code,
                				asp.base_currency_code,
                				DECODE(	ai.invoice_amount, 0, 1, ai.invoice_amount),
                				DECODE(	ai.base_amount, 0, 1, ai.base_amount) ) invoice_amount
                	FROM	AP_INVOICES_ALL 	 ai
                	, 	IGI_CBR_AP_INV_DIST_V 	 idv
                	, 	IGI_CBR_AP_INV_RECONCILE air
                	, 	PO_VENDORS 		 pv
                	, 	AP_SYSTEM_PARAMETERS_ALL asp
                	, 	GL_CODE_COMBINATIONS 	 gcc
                	WHERE	ai.set_of_books_id	= ' || P_SOB_ID || '
                	AND	ai.invoice_id		= idv.invoice_id
                	AND	ai.invoice_id		= air.invoice_id
                	AND	idv.invoice_id		= air.invoice_id
                	AND	pv.vendor_id 		= ai.vendor_id
                	AND	asp.set_of_books_id	= ai.set_of_books_id
                	AND	gcc.code_combination_id	= idv.dist_code_combination_id
                	AND	gcc.enabled_flag	= ''Y''
                	AND	air.status		= ''C''
                	AND	gcc.' || L_SEGMENT || ' BETWEEN ''' || P_FROM_SEGMENT || ''' AND ''' || P_TO_SEGMENT || '''
                	AND	NVL(ai.org_id, -1)	= NVL(asp.org_id, -1)
                	AND	NVL(ai.org_id, -1)	= NVL(air.org_id, -1)';
    EXECUTE IMMEDIATE
      L_INSERT;
  END FIND_INVOICE;

  PROCEDURE GET_PREVIOUS_YEAR IS
    L_SEGMENT VARCHAR2(25);
    L_INSERT VARCHAR2(5000);
  BEGIN
    L_SEGMENT := P_ACCT_SEGMENT;
    L_INSERT := 'INSERT INTO IGI_CBR_AP_INV_RECONCILE(
                			INVOICE_ID
                		, 	REMAINDER
                		, 	ORG_ID
                		, 	STATUS)
                       SELECT AI.invoice_id
                       , (NVL(ai.invoice_amount ,0) - SUM(NVL(aip.amount, 0)) )
                       , AI.org_id
                       , ''P''
                	FROM   AP_INVOICES_ALL          AI,
                       	       AP_INVOICE_PAYMENTS_ALL  AIP
                   	WHERE  AI.INVOICE_ID            = AIP.INVOICE_ID (+)
                	AND    AI.PAYMENT_STATUS_FLAG   = ''N''
                	AND EXISTS ( SELECT ''Y''
                             FROM   XLA_AE_HEADERS               AEH1,
                                    AP_INVOICE_DISTRIBUTIONS_ALL AID
                             WHERE  AI.INVOICE_ID            = AID.INVOICE_ID
                             AND    AEH1.LEDGER_ID           = ' || P_SOB_ID || '
                             AND    NVL(AEH1.GL_TRANSFER_STATUS_CODE, ''N'') = ''Y''
                             AND    to_char(AEH1.ACCOUNTING_DATE, ''RRRR'') = ' || LP_YEAR || '
                             AND    AEH1.APPLICATION_ID      = 200
                             AND    AID.ACCOUNTING_EVENT_ID  = AEH1.EVENT_ID
                             AND    AID.SET_OF_BOOKS_ID      = AEH1.LEDGER_ID)
                	GROUP BY ai.invoice_id,ai.org_id,ai.invoice_amount
                	HAVING (NVL(ai.invoice_amount, 0) - SUM(NVL(aip.amount, 0))) <> 0
                	UNION
                 	SELECT AI.invoice_id
                        , (NVL(ai.invoice_amount ,0) - SUM(NVL(aip.amount, 0)) )
                     	, AI.org_id
                        , ''P''
                 	FROM   AP_INVOICES_ALL          AI,
                               AP_INVOICE_PAYMENTS_ALL  AIP
                 	WHERE  AI.INVOICE_ID            = AIP.INVOICE_ID
                        AND    AI.PAYMENT_STATUS_FLAG   = ''P''
                        AND EXISTS (SELECT ''Y''
                             FROM   XLA_AE_HEADERS               AEH1
                             WHERE  AEH1.LEDGER_ID           = ' || P_SOB_ID || '
                             AND    NVL(AEH1.GL_TRANSFER_STATUS_CODE, ''N'') = ''Y''
                             AND    to_char(AEH1.ACCOUNTING_DATE, ''RRRR'') = ' || LP_YEAR || '
                             AND    AEH1.APPLICATION_ID      = 200
                             AND    AIP.ACCOUNTING_EVENT_ID  = AEH1.EVENT_ID
                             AND    AIP.SET_OF_BOOKS_ID      = AEH1.LEDGER_ID)
                        AND NOT EXISTS ( SELECT ''Y''
                             FROM   XLA_AE_HEADERS               AEH2
                             WHERE  AEH2.LEDGER_ID           = ' || P_CASH_SOB_ID || '
                             AND    NVL(AEH2.GL_TRANSFER_STATUS_CODE, ''N'') = ''Y''
                             AND    to_char(AEH2.ACCOUNTING_DATE, ''RRRR'') = ' || LP_YEAR || '
                             AND    AEH2.APPLICATION_ID      = 200
                             AND    AIP.ACCOUNTING_EVENT_ID  = AEH2.EVENT_ID
                           )

                	GROUP BY ai.invoice_id,ai.org_id,ai.invoice_amount
                	HAVING (NVL(ai.invoice_amount, 0) - SUM(NVL(aip.amount, 0))) <> 0';
    EXECUTE IMMEDIATE
      L_INSERT;
  END GET_PREVIOUS_YEAR;

  PROCEDURE GET_CURRENT_YEAR IS
    L_SEGMENT VARCHAR2(25);
    L_INSERT VARCHAR2(5000);
  BEGIN
    L_SEGMENT := P_ACCT_SEGMENT;
    L_INSERT := 'INSERT INTO IGI_CBR_AP_INV_RECONCILE(
                			INVOICE_ID
                		, 	REMAINDER
                		, 	ORG_ID
                		, 	STATUS)

                	SELECT
                	AI.invoice_id
                       , (NVL(ai.invoice_amount ,0) - SUM(NVL(aip.amount, 0)) )
                       , AI.org_id
                       , ''C''
                	FROM   AP_INVOICES_ALL          AI,
                       		AP_INVOICE_PAYMENTS_ALL  AIP
                	WHERE  AI.INVOICE_ID            = AIP.INVOICE_ID (+)
                	AND    AI.PAYMENT_STATUS_FLAG   = ''N''
                	AND EXISTS ( SELECT ''Y''
                             FROM   XLA_AE_HEADERS               AEH1,
                                    AP_INVOICE_DISTRIBUTIONS_ALL AID
                             WHERE  AI.INVOICE_ID            = AID.INVOICE_ID
                             AND    AEH1.LEDGER_ID           = ' || P_SOB_ID || '
                             AND    NVL(AEH1.GL_TRANSFER_STATUS_CODE, ''N'') = ''Y''
                             AND    AEH1.ACCOUNTING_DATE BETWEEN ''' || LP_START_DATE || ''' AND ''' || LP_END_DATE || '''
                             AND    AEH1.APPLICATION_ID      = 200
                             AND    AID.ACCOUNTING_EVENT_ID  = AEH1.EVENT_ID
                             AND    AID.SET_OF_BOOKS_ID      = AEH1.LEDGER_ID )
                	GROUP BY ai.invoice_id,ai.org_id,ai.invoice_amount
                	HAVING (NVL(ai.invoice_amount, 0) - SUM(NVL(aip.amount, 0))) <> 0
                 UNION
                	SELECT AI.invoice_id
                       , (NVL(ai.invoice_amount ,0) - SUM(NVL(aip.amount, 0)) )
                       , AI.org_id
                       , ''C''
                 	FROM   AP_INVOICES_ALL          AI,
                       		AP_INVOICE_PAYMENTS_ALL  AIP
                 	WHERE  AI.INVOICE_ID            = AIP.INVOICE_ID
                 	AND    AI.PAYMENT_STATUS_FLAG   = ''P''
                 	AND EXISTS (SELECT ''Y''
                             FROM   XLA_AE_HEADERS               AEH1
                             WHERE  AEH1.LEDGER_ID           = ' || P_SOB_ID || '
                             AND    NVL(AEH1.GL_TRANSFER_STATUS_CODE, ''N'') = ''Y''
                             AND    AEH1.ACCOUNTING_DATE BETWEEN ''' || LP_START_DATE || ''' AND ''' || LP_END_DATE || '''
                             AND    AEH1.APPLICATION_ID      = 200
                             AND    AIP.ACCOUNTING_EVENT_ID  = AEH1.EVENT_ID
                             AND    AIP.SET_OF_BOOKS_ID      = AEH1.LEDGER_ID)
                 	AND NOT EXISTS ( SELECT ''Y''
                             FROM   XLA_AE_HEADERS               AEH2
                             WHERE  AEH2.LEDGER_ID           =  ' || P_CASH_SOB_ID || '
                             AND    NVL(AEH2.GL_TRANSFER_STATUS_CODE, ''N'') = ''Y''
                             AND    AEH2.ACCOUNTING_DATE BETWEEN ''' || LP_START_DATE || ''' AND ''' || LP_END_DATE || '''
                             AND    AEH2.APPLICATION_ID      = 200
                             AND    AIP.ACCOUNTING_EVENT_ID  = AEH2.EVENT_ID
                           )

                	GROUP BY ai.invoice_id,ai.org_id,ai.invoice_amount
                	HAVING (NVL(ai.invoice_amount, 0) - SUM(NVL(aip.amount, 0))) <> 0';
    EXECUTE IMMEDIATE
      L_INSERT;
  END GET_CURRENT_YEAR;

  PROCEDURE INSERT_INTERFACE IS
    L_SEGMENT VARCHAR2(25);
    L_INSERT VARCHAR2(5000);
  BEGIN
    L_SEGMENT := P_ACCT_SEGMENT;
    L_INSERT := 'INSERT INTO IGI_CBR_AP_INTERFACE(
                		  ORG_ID
                		, ORGANIZATION
                		, ACCOUNT_NUM
                		, DOC_SEQ_NUM
                		, INVOICE_NUM
                		, VENDOR_NUM
                		, INVOICE_DATE
                		, OPENING_VAR
                		, AMOUNT)
                	SELECT	  car.org_id
                		, SUBSTR(hr.name, 1, 30) Organization
                		, car.account_num
                		, car.doc_seq_num
                		, car.invoice_num
                		, car.vendor_num
                		, DECODE(car.type, ''UB'', to_date(''' || LP_LAST_DAY || ''', ''DD-MON-RRRR''), car.invoice_date) invoice_date
                		, DECODE(car.type, ''UB'', car.invoice_amount) opening_var
                		, DECODE(car.type, null, car.invoice_amount) amount
                	FROM	  IGI_CBR_AP_RECONCILE car
                		, HR_OPERATING_UNITS hr
                	WHERE	  NVL(car.org_id, -1) = NVL(hr.organization_id , -1)';
    EXECUTE IMMEDIATE
      L_INSERT;
  END INSERT_INTERFACE;

END IGI_IGIPCBAP_XMLP_PKG;

/
