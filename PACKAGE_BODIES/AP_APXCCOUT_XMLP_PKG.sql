--------------------------------------------------------
--  DDL for Package Body AP_APXCCOUT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXCCOUT_XMLP_PKG" AS
/* $Header: APXCCOUT_SUMMARYB.pls 120.0 2007/12/28 11:10:52 vjaganat noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      INIT_FAILURE EXCEPTION;
    BEGIN
      IF ((P_BUCKET1 > P_BUCKET2) OR (P_BUCKET1 > P_BUCKET3)) THEN
        NULL;
        RAISE INIT_FAILURE;
      ELSIF ((P_BUCKET2 > P_BUCKET3)) THEN
        NULL;
        RAISE INIT_FAILURE;
      END IF;
      IF (P_OPERATION_TYPE = 'CC_DETAIL_REPORT') THEN

        NULL;
      ELSIF (P_OPERATION_TYPE = 'CC_SUMMARY_REPORT') THEN

        NULL;
      ELSIF (P_OPERATION_TYPE = 'CC_AGING_REPORT') THEN

        NULL;
      ELSIF (P_OPERATION_TYPE = 'CC_INACT_EMPL_REPORT') THEN

       NULL;
      END IF;
      IF (P_BUCKET1 IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('SQLAP'
                            ,'OIE_CC_BUCKET1_NAME');
        FND_MESSAGE.SET_TOKEN('BUCKET1'
                             ,P_BUCKET1);
        CP_BUCKET1_NAME := FND_MESSAGE.GET;
        NULL;
      END IF;
      IF (P_BUCKET2 IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('SQLAP'
                            ,'OIE_CC_BUCKET2_NAME');
        FND_MESSAGE.SET_TOKEN('BUCKET1'
                             ,P_BUCKET1 + 1);
        FND_MESSAGE.SET_TOKEN('BUCKET2'
                             ,P_BUCKET2);
        CP_BUCKET2_NAME := FND_MESSAGE.GET;
        NULL;
      END IF;
      IF (P_BUCKET3 IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('SQLAP'
                            ,'OIE_CC_BUCKET3_NAME');
        FND_MESSAGE.SET_TOKEN('BUCKET2'
                             ,P_BUCKET2 + 1);
        FND_MESSAGE.SET_TOKEN('BUCKET3'
                             ,P_BUCKET3);
        CP_BUCKET3_NAME := FND_MESSAGE.GET;
        NULL;
        FND_MESSAGE.SET_NAME('SQLAP'
                            ,'OIE_CC_BUCKET4_NAME');
        FND_MESSAGE.SET_TOKEN('BUCKET4'
                             ,P_BUCKET3 + 1);
        CP_BUCKET4_NAME := FND_MESSAGE.GET;
        NULL;
      END IF;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

      IF (GETCOMPANYNAME <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;

      IF (GETBASECURRDATA <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;

      IF (GETNLSSTRINGS <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;

      IF (GETCARDPROGRAMNAME <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_MIN_AMOUNT IS NOT NULL) THEN
        LP_MIN_AMT_WHERE := 'and cct1.billed_amount >= ' || P_MIN_AMOUNT || ' ';
      ELSE
        LP_MIN_AMT_WHERE := ' ';
      END IF;

      IF (P_OPERATION_TYPE in ('CC_DETAIL_REPORT','CC_SUMMARY_REPORT','CC_INACT_EMPL_REPORT')) THEN
        IF (P_STATUS = 'C') THEN
          LP_SELECT_EMP := 'emp.employee_id ';
          LP_SELECT_EMP_NAME := 'emp.full_name ';
          LP_SELECT_SUP := 'emp.supervisor_id ';
          LP_GROUP_BY := ' group by emp.employee_id, emp.supervisor_id';
        ELSE
          LP_SELECT_EMP := 'perf.person_id   ';
          LP_SELECT_EMP_NAME := 'perf.full_name ';
          LP_SELECT_SUP := 'pera.supervisor_id ';
          LP_GROUP_BY := ' group by perf.person_id, pera.supervisor_id';
        END IF;
        IF (P_STATUS in ('C','B')) THEN
          LP_EMPLOYEE_STATUS := ' ''Active'' ';
        ELSE
          LP_EMPLOYEE_STATUS := ' ''Inactive'' ';
        END IF;
        IF (P_STATUS = 'C') THEN
          LP_EMPLOYEE_FROM := ', per_employees_current_x emp';
        ELSIF (P_STATUS = 'B') THEN
          LP_EMPLOYEE_FROM := ', per_people_f perf
                              			      ,	per_assignments_f pera';
        ELSIF (P_STATUS = 'T') THEN
          LP_EMPLOYEE_FROM := ', per_people_f perf
                              			      ,	per_assignments_f pera
                                                            , per_assignment_status_types peras';
        ELSE
	  LP_EMPLOYEE_FROM := ' ';
        END IF;
        IF (P_STATUS = 'C') THEN
          LP_EMPLOYEE_WHERE := ' and ac.employee_id = emp.employee_id';
        ELSIF (P_STATUS = 'T') THEN
          LP_EMPLOYEE_WHERE := ' and ac.employee_id = perf.person_id
                               			and perf.business_group_id+0 = (select business_group_id from financials_system_parameters fsp
                                                               where perf.business_group_id = fsp.business_group_id)
                               			and perf.person_id = pera.person_id
                                                       and pera.assignment_status_type_id = peras.assignment_status_type_id
                               			and peras.per_system_status in (''TERM_ASSIGN'', ''SUSP_ASSIGN'')
                               			and pera.primary_flag = ''Y''
                                                       and pera.assignment_type in (''E'',''C'')
                               			and perf.employee_number is not null
                               			and trunc(sysdate) between perf.effective_start_date and perf.effective_end_date
                                    			and trunc(sysdate) between pera.effective_start_date and pera.effective_end_date';
        ELSIF (P_STATUS = 'B') THEN
          LP_EMPLOYEE_WHERE := 'and ac.employee_id = perf.person_id
                               			and perf.person_id = pera.person_id
                               			and pera.assignment_type = ''E''
                               			and pera.primary_flag = ''Y''
                               			and perf.employee_number is not null
                               			and trunc(sysdate) between perf.effective_start_date and perf.effective_end_date
                                    			and trunc(sysdate) between pera.effective_start_date and pera.effective_end_date
                               			and trunc(sysdate) < perf.effective_end_date
                               			and trunc(sysdate) < pera.effective_end_date';
        ELSE
	 LP_EMPLOYEE_WHERE := ' ';
        END IF;
      END IF;
      IF (P_EMPLOYEE IS NOT NULL) THEN
        IF (P_INCLUDE_DIRECTS = 'Y') THEN
          LP_EMP_MGR := '  and (ac.employee_id in (select distinct employee_id
                        				       from per_employees_x emp1	-- Bug 3176205: Changed HR view to include all employees(inactive also) and exclude contingent workers.
                        					where emp1.supervisor_id = ' || P_EMPLOYEE || ')
                        			    OR  ac.employee_id = ' || P_EMPLOYEE || ') ';
          LP_EMP_MGR1 := ' and (ac.employee_id in (select distinct person_id
                         					from per_assignments_f pera1
                         					where pera1.supervisor_id = ' || P_EMPLOYEE || ' and pera1.assignment_type in (''E'',''C'') )
                         				OR ac.employee_id = ' || P_EMPLOYEE || ') ';
        ELSIF (P_INCLUDE_DIRECTS = 'N') THEN
          LP_EMP_MGR := ' and ac.employee_id = ' || P_EMPLOYEE || ' ';
          LP_EMP_MGR1 := ' and ac.employee_id = ' || P_EMPLOYEE || ' ';
        END IF;
      ELSE
	  LP_EMP_MGR := ' ';
	  LP_EMP_MGR1 := ' ';
      END IF;
      IF (P_OPERATION_TYPE = 'CC_INACT_EMPL_REPORT') THEN
        LP_INACTIVE_WHERE := 'and inactive_emp_wf_item_key is null';
      ELSE
        LP_INACTIVE_WHERE := ' ';
      END IF;

      RETURN (TRUE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN NULL;
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
    V_MIN_BUCKET NUMBER;
    V_MAX_BUCKET NUMBER;
    V_DUNNING_NUMBER NUMBER;
    V_ERRNUM NUMBER;
    V_ERRMSG VARCHAR2(300);
    V_SEND_NOTIFICATIONS VARCHAR2(20);
    V_ESC_LEVEL NUMBER;
    V_GRACE_DAYS NUMBER;
  BEGIN

    IF (P_SEND_NOTIFICATIONS = 'Y' AND P_OPERATION_TYPE = 'CC_DETAIL_REPORT' AND P_EMPLOYEE IS NULL AND P_STATUS <> 'T') THEN
      SENDUNSUBMITTED;
      SENDMGRUNAPPROVED;
      SENDDISPUTED;
    END IF;
    IF (P_SEND_NOTIFICATIONS <> 'N' AND P_OPERATION_TYPE = 'CC_AGING_REPORT') THEN
      V_SEND_NOTIFICATIONS := P_SEND_NOTIFICATIONS;
      V_ESC_LEVEL := P_ESC_LEVEL;
      V_GRACE_DAYS := P_GRACE_DAYS;

      IF (P_BUCKET1 IS NOT NULL AND P_EMPLOYEE IS NULL) THEN
        V_MIN_BUCKET := 0;
        V_MAX_BUCKET := P_BUCKET1;
        V_DUNNING_NUMBER := 1;
        SEND1DUNNINGNOTIFICATIONS(V_MIN_BUCKET
                                 ,V_MAX_BUCKET
                                 ,V_DUNNING_NUMBER
                                 ,V_SEND_NOTIFICATIONS
                                 ,V_ESC_LEVEL
                                 ,V_GRACE_DAYS);

      END IF;
      IF (P_BUCKET2 IS NOT NULL AND P_EMPLOYEE IS NULL) THEN

        V_MIN_BUCKET := P_BUCKET1 + 1;
        V_MAX_BUCKET := P_BUCKET2;
        V_DUNNING_NUMBER := 2;
        SEND1DUNNINGNOTIFICATIONS(V_MIN_BUCKET
                                 ,V_MAX_BUCKET
                                 ,V_DUNNING_NUMBER
                                 ,V_SEND_NOTIFICATIONS
                                 ,V_ESC_LEVEL
                                 ,V_GRACE_DAYS);

      END IF;
      IF (P_BUCKET3 IS NOT NULL AND P_EMPLOYEE IS NULL) THEN

        V_MIN_BUCKET := P_BUCKET2 + 1;
        V_MAX_BUCKET := P_BUCKET3;
        V_DUNNING_NUMBER := 3;
        SEND1DUNNINGNOTIFICATIONS(V_MIN_BUCKET
                                 ,V_MAX_BUCKET
                                 ,V_DUNNING_NUMBER
                                 ,V_SEND_NOTIFICATIONS
                                 ,V_ESC_LEVEL
                                 ,V_GRACE_DAYS);
        V_MIN_BUCKET := P_BUCKET3 + 1;
        V_MAX_BUCKET := 1000000;
        V_DUNNING_NUMBER := 4;
        SEND1DUNNINGNOTIFICATIONS(V_MIN_BUCKET
                                 ,V_MAX_BUCKET
                                 ,V_DUNNING_NUMBER
                                 ,V_SEND_NOTIFICATIONS
                                 ,V_ESC_LEVEL
                                 ,V_GRACE_DAYS);

      END IF;
    END IF;
    IF (P_OPERATION_TYPE = 'CC_INACT_EMPL_REPORT') THEN

      AP_WEB_START_INACT_PRO(P_CARD_PROGRAM_ID
                            ,P_BILLED_START_DATE
                            ,P_BILLED_END_DATE
                            ,V_ERRNUM
                            ,V_ERRMSG);
    END IF;

    RETURN TRUE;
    RETURN NULL;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20101,null);
  END AFTERREPORT;

  FUNCTION GETNLSSTRINGS RETURN BOOLEAN IS
  BEGIN
    SELECT
      LY.MEANING,
      LN.MEANING,
      LA.DISPLAYED_FIELD,
      LM.DISPLAYED_FIELD,
      LP.DISPLAYED_FIELD,
      LD.DISPLAYED_FIELD,
      LR.DISPLAYED_FIELD
    INTO CP_NLS_YES,CP_NLS_NO,CP_NLS_ALL,CP_NLS_DISPUTED,CP_NLS_MGR_UNAPPROVED,CP_NLS_AP_UNAPPROVED,CP_NLS_REJECTED
    FROM
      FND_LOOKUPS LY,
      FND_LOOKUPS LN,
      AP_LOOKUP_CODES LA,
      AP_LOOKUP_CODES LM,
      AP_LOOKUP_CODES LP,
      AP_LOOKUP_CODES LD,
      AP_LOOKUP_CODES LR
    WHERE LY.LOOKUP_TYPE = 'YES_NO'
      AND LY.LOOKUP_CODE = 'Y'
      AND LN.LOOKUP_TYPE = 'YES_NO'
      AND LN.LOOKUP_CODE = 'N'
      AND LA.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND LA.LOOKUP_CODE = 'ALL'
      AND LD.LOOKUP_TYPE = 'CC_STATUS'
      AND LD.LOOKUP_CODE = 'DISPUTED'
      AND LM.LOOKUP_TYPE = 'EXPENSE REPORT STATUS'
      AND LM.LOOKUP_CODE = 'PENDMGR'
      AND LP.LOOKUP_TYPE = 'EXPENSE REPORT STATUS'
      AND LP.LOOKUP_CODE = 'MGRAPPR'
      AND LR.LOOKUP_TYPE = 'EXPENSE REPORT STATUS'
      AND LR.LOOKUP_CODE = 'REJECTED';
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     NULL;
    WHEN OTHERS THEN
      RETURN (FALSE);
      RETURN NULL;
  END GETNLSSTRINGS;

  FUNCTION CF_REPORT_NUMFORMULA(C_REPORT_HEADER_ID IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_REPNUM VARCHAR2(50);
    BEGIN
      IF (C_REPORT_HEADER_ID = -1) THEN
        RETURN '';
      END IF;
      FND_PROFILE.GET('AP_WEB_REPNUM_PREFIX'
                     ,L_REPNUM);
      L_REPNUM := L_REPNUM || TO_CHAR(C_REPORT_HEADER_ID);
      RETURN L_REPNUM;
    END;
    RETURN NULL;
  END CF_REPORT_NUMFORMULA;

  FUNCTION GETCOMPANYNAME RETURN BOOLEAN IS
  BEGIN
    SELECT
      NAME,
      CHART_OF_ACCOUNTS_ID
    INTO CP_COMPANY_NAME_HEADER,CP_CHART_OF_ACCOUNTS_ID
    FROM
      GL_SETS_OF_BOOKS G,
      AP_SYSTEM_PARAMETERS A
    WHERE G.SET_OF_BOOKS_ID = A.SET_OF_BOOKS_ID;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GETCOMPANYNAME;

  FUNCTION CF_STATUSFORMULA(C_STATUS IN VARCHAR2
                           ,C_BILLED_AMOUNT IN NUMBER) RETURN VARCHAR2 IS
    V_DISPLAY_STATUS VARCHAR2(80);
  BEGIN
    IF (C_STATUS = 'UNUSED') THEN
      CP_UNSUBMITTED := CP_UNSUBMITTED + C_BILLED_AMOUNT;
    END IF;
    IF (C_STATUS = 'PENDMGR') THEN
      CP_MGR_UNAPPROVED := CP_MGR_UNAPPROVED + C_BILLED_AMOUNT;
    END IF;
    IF (C_STATUS = 'MGRAPPR') THEN
      CP_AP_UNAPPROVED := CP_AP_UNAPPROVED + C_BILLED_AMOUNT;
    END IF;
    IF (C_STATUS = 'DISPUTED') THEN
      CP_DISPUTED := CP_DISPUTED + C_BILLED_AMOUNT;
    END IF;
    IF (C_STATUS = 'REJECTED') THEN
      CP_REJECTED := CP_REJECTED + C_BILLED_AMOUNT;
    END IF;
    IF (C_STATUS = 'EMPAPPR') THEN
      CP_EMP_APPR := CP_EMP_APPR + C_BILLED_AMOUNT;
    END IF;
    IF (C_STATUS = 'ERROR') THEN
      CP_ERROR := CP_ERROR + C_BILLED_AMOUNT;
    END IF;
    IF (C_STATUS = 'WITHDRAWN') THEN
      CP_WITHDRAWN := CP_WITHDRAWN + C_BILLED_AMOUNT;
    END IF;
    IF (C_STATUS = 'INVOICED') THEN
      CP_INVOICED := CP_INVOICED + C_BILLED_AMOUNT;
    END IF;
    IF (C_STATUS in ('SAVED','INPROGRESS')) THEN
      CP_SAVED := CP_SAVED + C_BILLED_AMOUNT;
    END IF;
    IF (C_STATUS = 'RETURNED') THEN
      CP_RETURNED := CP_RETURNED + C_BILLED_AMOUNT;
    END IF;
    IF (C_STATUS = 'RESOLUTN') THEN
      CP_RESOLUTN := CP_RESOLUTN + C_BILLED_AMOUNT;
    END IF;
    IF (C_STATUS in ('EMPAPPR','ERROR','INVOICED','WITHDRAWN','RESOLUTN','RETURNED','MGRAPPR','PENDMGR','REJECTED','SAVED','INPROGRESS','UNUSED')) THEN
      BEGIN
        SELECT
          ALC.DISPLAYED_FIELD
        INTO V_DISPLAY_STATUS
        FROM
          AP_LOOKUP_CODES ALC
        WHERE ALC.LOOKUP_TYPE = 'EXPENSE REPORT STATUS'
          AND ALC.LOOKUP_CODE = C_STATUS;
        RETURN V_DISPLAY_STATUS;
      END;
    ELSIF (C_STATUS in ('DISPUTED')) THEN
      BEGIN
        SELECT
          ALC.DISPLAYED_FIELD
        INTO V_DISPLAY_STATUS
        FROM
          AP_LOOKUP_CODES ALC
        WHERE ALC.LOOKUP_TYPE = 'SSE_CCARD_TRXN_CATEGORY'
          AND ALC.LOOKUP_CODE = C_STATUS;
        RETURN V_DISPLAY_STATUS;
      END;
    END IF;
    RETURN 'Unknown1';
  END CF_STATUSFORMULA;

  FUNCTION CF_CP_CURRENCY_CODEFORMULA(C_CP_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF (C_CP_CURRENCY_CODE IS NOT NULL) THEN
      RETURN C_CP_CURRENCY_CODE;
    ELSE
      RETURN C_BASE_CURRENCY_CODE;
    END IF;
    RETURN NULL;
  END CF_CP_CURRENCY_CODEFORMULA;

  FUNCTION CF_EMP_CURRENCY_CODEFORMULA(C_EMP_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF (C_EMP_CURRENCY_CODE IS NOT NULL) THEN
      RETURN C_EMP_CURRENCY_CODE;
    ELSE
      RETURN C_BASE_CURRENCY_CODE;
    END IF;
    RETURN NULL;
  END CF_EMP_CURRENCY_CODEFORMULA;

  FUNCTION GETBASECURRDATA RETURN BOOLEAN IS
  BEGIN
    SELECT
      P.BASE_CURRENCY_CODE,
      C.PRECISION,
      C.MINIMUM_ACCOUNTABLE_UNIT,
      C.DESCRIPTION
    INTO C_BASE_CURRENCY_CODE,C_BASE_PRECISION,C_BASE_MIN_ACCT_UNIT,C_BASE_DESCRIPTION
    FROM
      AP_SYSTEM_PARAMETERS P,
      FND_CURRENCIES_VL C
    WHERE P.BASE_CURRENCY_CODE = C.CURRENCY_CODE;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GETBASECURRDATA;

  PROCEDURE SENDUNSUBMITTED IS
    V_EMPLOYEE_ID AP_CARDS.EMPLOYEE_ID%TYPE;
    V_BILLED_AMOUNT AP_CREDIT_CARD_TRXNS.BILLED_AMOUNT%TYPE;
    V_BILLED_CURRENCY_CODE AP_CREDIT_CARD_TRXNS.BILLED_CURRENCY_CODE%TYPE;
    V_CARD_PROGRAM_NAME AP_CARD_PROGRAMS.CARD_PROGRAM_NAME%TYPE;
    V_SAVED_CHARGE_TYPE VARCHAR2(20);
    V_UNSUBMITTED_CHARGE_TYPE VARCHAR2(20) := 'UNUSED';
    CURSOR UNSUBMITTEDCHARGES IS
      SELECT
        EMPLOYEE_ID,
        SUM(BILLED_AMOUNT),
        BILLED_CURRENCY_CODE
      FROM
        (   SELECT
            AC.EMPLOYEE_ID,
            CCT.BILLED_AMOUNT,
            CCT.BILLED_CURRENCY_CODE,
            CCT.TRX_ID
          FROM
            AP_CREDIT_CARD_TRXNS CCT,
            AP_CARDS_ALL AC
          WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
            AND CCT.VALIDATE_CODE = 'Y'
            AND CCT.PAYMENT_FLAG <> 'Y'
            AND NVL(CCT.CATEGORY
             ,'BUSINESS') <> 'DEACTIVATED'
            AND ( NVL(CCT.EXPENSED_AMOUNT
             ,0) = 0
          OR ( CCT.EXPENSED_AMOUNT <> 0
            AND CCT.CATEGORY = 'PERSONAL'
            AND AP_WEB_OA_ACTIVE_PKG.GETINCLUDENOTIFICATION(CCT.CATEGORY
                                                     ,CCT.TRX_ID) = 'TRUE' ) )
            AND NVL(CCT.CATEGORY
             ,'BUSINESS') not in ( 'DISPUTED' , 'MATCHED' , 'CREDIT' )
            AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
            AND AC.CARD_ID = CCT.CARD_ID
            AND NVL(CCT.BILLED_DATE
             ,CCT.POSTED_DATE) between NVL(P_BILLED_START_DATE
             ,NVL(CCT.BILLED_DATE
                ,CCT.POSTED_DATE) - 1)
            AND NVL(P_BILLED_END_DATE
             ,NVL(CCT.BILLED_DATE
                ,CCT.POSTED_DATE) + 1)
            AND CCT.BILLED_AMOUNT > DECODE(P_MIN_AMOUNT
                ,NULL
                ,-999999999999
                ,P_MIN_AMOUNT)
            AND AC.EMPLOYEE_ID in (
            SELECT
              DISTINCT
              EMPLOYEE_ID
            FROM
              PER_EMPLOYEES_X
            WHERE SUPERVISOR_ID = P_EMPLOYEE )
            AND P_INCLUDE_DIRECTS = 'Y'
          UNION ALL
          SELECT
            AC.EMPLOYEE_ID,
            CCT.BILLED_AMOUNT,
            CCT.BILLED_CURRENCY_CODE,
            CCT.TRX_ID
          FROM
            AP_CREDIT_CARD_TRXNS CCT,
            AP_CARDS_ALL AC
          WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
            AND CCT.VALIDATE_CODE = 'Y'
            AND CCT.PAYMENT_FLAG <> 'Y'
            AND NVL(CCT.CATEGORY
             ,'BUSINESS') <> 'DEACTIVATED'
            AND ( NVL(CCT.EXPENSED_AMOUNT
             ,0) = 0
          OR ( CCT.EXPENSED_AMOUNT <> 0
            AND CCT.CATEGORY = 'PERSONAL'
            AND AP_WEB_OA_ACTIVE_PKG.GETINCLUDENOTIFICATION(CCT.CATEGORY
                                                     ,CCT.TRX_ID) = 'TRUE' ) )
            AND NVL(CCT.CATEGORY
             ,'BUSINESS') not in ( 'DISPUTED' , 'MATCHED' , 'CREDIT' )
            AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
            AND AC.CARD_ID = CCT.CARD_ID
            AND NVL(CCT.BILLED_DATE
             ,CCT.POSTED_DATE) between NVL(P_BILLED_START_DATE
             ,NVL(CCT.BILLED_DATE
                ,CCT.POSTED_DATE) - 1)
            AND NVL(P_BILLED_END_DATE
             ,NVL(CCT.BILLED_DATE
                ,CCT.POSTED_DATE) + 1)
            AND CCT.BILLED_AMOUNT > DECODE(P_MIN_AMOUNT
                ,NULL
                ,-999999999999
                ,P_MIN_AMOUNT)
            AND AC.EMPLOYEE_ID = P_EMPLOYEE
            AND P_INCLUDE_DIRECTS = 'N'
          UNION ALL
          SELECT
            AC.EMPLOYEE_ID,
            CCT.BILLED_AMOUNT,
            CCT.BILLED_CURRENCY_CODE,
            CCT.TRX_ID
          FROM
            AP_CREDIT_CARD_TRXNS CCT,
            AP_CARDS_ALL AC
          WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
            AND CCT.VALIDATE_CODE = 'Y'
            AND CCT.PAYMENT_FLAG <> 'Y'
            AND NVL(CCT.CATEGORY
             ,'BUSINESS') <> 'DEACTIVATED'
            AND ( NVL(CCT.EXPENSED_AMOUNT
             ,0) = 0
          OR ( CCT.EXPENSED_AMOUNT <> 0
            AND CCT.CATEGORY = 'PERSONAL'
            AND AP_WEB_OA_ACTIVE_PKG.GETINCLUDENOTIFICATION(CCT.CATEGORY
                                                     ,CCT.TRX_ID) = 'TRUE' ) )
            AND NVL(CCT.CATEGORY
             ,'BUSINESS') not in ( 'DISPUTED' , 'MATCHED' , 'CREDIT' )
            AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
            AND AC.CARD_ID = CCT.CARD_ID
            AND NVL(CCT.BILLED_DATE
             ,CCT.POSTED_DATE) between NVL(P_BILLED_START_DATE
             ,NVL(CCT.BILLED_DATE
                ,CCT.POSTED_DATE) - 1)
            AND NVL(P_BILLED_END_DATE
             ,NVL(CCT.BILLED_DATE
                ,CCT.POSTED_DATE) + 1)
            AND CCT.BILLED_AMOUNT > DECODE(P_MIN_AMOUNT
                ,NULL
                ,-999999999999
                ,P_MIN_AMOUNT)
            AND P_EMPLOYEE is null
          UNION ALL
          SELECT
            DISTINCT
            AC.EMPLOYEE_ID,
            CCT.BILLED_AMOUNT,
            CCT.BILLED_CURRENCY_CODE,
            CCT.TRX_ID
          FROM
            AP_CREDIT_CARD_TRXNS CCT,
            AP_CARDS_ALL AC,
            AP_EXPENSE_REPORT_HEADERS ERH
          WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
            AND CCT.VALIDATE_CODE = 'Y'
            AND CCT.PAYMENT_FLAG <> 'Y'
            AND CCT.EXPENSED_AMOUNT <> 0
            AND NVL(CCT.CATEGORY
             ,'BUSINESS') not in ( 'DISPUTED' , 'MATCHED' , 'CREDIT' , 'PERSONAL' , 'DEACTIVATED' )
            AND ERH.REPORT_HEADER_ID = CCT.REPORT_HEADER_ID
            AND ERH.EMPLOYEE_ID = AC.EMPLOYEE_ID
            AND NVL(ERH.VOUCHNO
             ,0) = 0
            AND AP_WEB_OA_ACTIVE_PKG.GETREPORTSTATUSCODE(ERH.SOURCE
                                                  ,ERH.WORKFLOW_APPROVED_FLAG
                                                  ,ERH.REPORT_HEADER_ID) in ( 'EMPAPPR' , 'RESOLUTN' , 'RETURNED' , 'REJECTED' , 'WITHDRAWN' , 'SAVED' , 'INPROGRESS' )
            AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
            AND AC.CARD_ID = CCT.CARD_ID
            AND NVL(CCT.BILLED_DATE
             ,CCT.POSTED_DATE) between NVL(P_BILLED_START_DATE
             ,NVL(CCT.BILLED_DATE
                ,CCT.POSTED_DATE) - 1)
            AND NVL(P_BILLED_END_DATE
             ,NVL(CCT.BILLED_DATE
                ,CCT.POSTED_DATE) + 1)
            AND CCT.BILLED_AMOUNT > DECODE(P_MIN_AMOUNT
                ,NULL
                ,-999999999999
                ,P_MIN_AMOUNT)
            AND AC.EMPLOYEE_ID in (
            SELECT
              DISTINCT
              EMPLOYEE_ID
            FROM
              PER_EMPLOYEES_X
            WHERE SUPERVISOR_ID = P_EMPLOYEE )
            AND P_INCLUDE_DIRECTS = 'Y'
          UNION ALL
          SELECT
            DISTINCT
            AC.EMPLOYEE_ID,
            CCT.BILLED_AMOUNT,
            CCT.BILLED_CURRENCY_CODE,
            CCT.TRX_ID
          FROM
            AP_CREDIT_CARD_TRXNS CCT,
            AP_CARDS_ALL AC,
            AP_EXPENSE_REPORT_HEADERS ERH
          WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
            AND CCT.VALIDATE_CODE = 'Y'
            AND CCT.PAYMENT_FLAG <> 'Y'
            AND CCT.EXPENSED_AMOUNT <> 0
            AND NVL(CCT.CATEGORY
             ,'BUSINESS') not in ( 'DISPUTED' , 'MATCHED' , 'CREDIT' , 'PERSONAL' , 'DEACTIVATED' )
            AND ERH.REPORT_HEADER_ID = CCT.REPORT_HEADER_ID
            AND ERH.EMPLOYEE_ID = AC.EMPLOYEE_ID
            AND AP_WEB_OA_ACTIVE_PKG.GETREPORTSTATUSCODE(ERH.SOURCE
                                                  ,ERH.WORKFLOW_APPROVED_FLAG
                                                  ,ERH.REPORT_HEADER_ID) in ( 'EMPAPPR' , 'RESOLUTN' , 'RETURNED' , 'REJECTED' , 'WITHDRAWN' , 'SAVED' , 'INPROGRESS' )
            AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
            AND AC.CARD_ID = CCT.CARD_ID
            AND NVL(CCT.BILLED_DATE
             ,CCT.POSTED_DATE) between NVL(P_BILLED_START_DATE
             ,NVL(CCT.BILLED_DATE
                ,CCT.POSTED_DATE) - 1)
            AND NVL(P_BILLED_END_DATE
             ,NVL(CCT.BILLED_DATE
                ,CCT.POSTED_DATE) + 1)
            AND CCT.BILLED_AMOUNT > DECODE(P_MIN_AMOUNT
                ,NULL
                ,-999999999999
                ,P_MIN_AMOUNT)
            AND AC.EMPLOYEE_ID = P_EMPLOYEE
            AND P_INCLUDE_DIRECTS = 'N'
          UNION ALL
          SELECT
            DISTINCT
            AC.EMPLOYEE_ID,
            CCT.BILLED_AMOUNT,
            CCT.BILLED_CURRENCY_CODE,
            CCT.TRX_ID
          FROM
            AP_CREDIT_CARD_TRXNS CCT,
            AP_CARDS_ALL AC,
            AP_EXPENSE_REPORT_LINES ERL,
            AP_EXPENSE_REPORT_HEADERS ERH
          WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
            AND CCT.VALIDATE_CODE = 'Y'
            AND CCT.PAYMENT_FLAG <> 'Y'
            AND CCT.EXPENSED_AMOUNT <> 0
            AND NVL(CCT.CATEGORY
             ,'BUSINESS') not in ( 'DISPUTED' , 'MATCHED' , 'CREDIT' , 'DEACTIVATED' )
            AND ERL.CREDIT_CARD_TRX_ID = CCT.TRX_ID
            AND ERH.REPORT_HEADER_ID = ERL.REPORT_HEADER_ID
            AND NVL(ERH.VOUCHNO
             ,0) = 0
            AND AP_WEB_OA_ACTIVE_PKG.GETREPORTSTATUSCODE(ERH.SOURCE
                                                  ,ERH.WORKFLOW_APPROVED_FLAG
                                                  ,ERH.REPORT_HEADER_ID) in ( 'EMPAPPR' , 'RESOLUTN' , 'RETURNED' , 'REJECTED' , 'WITHDRAWN' , 'SAVED' , 'INPROGRESS' )
            AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
            AND AC.CARD_ID = CCT.CARD_ID
            AND NVL(CCT.BILLED_DATE
             ,CCT.POSTED_DATE) between NVL(P_BILLED_START_DATE
             ,NVL(CCT.BILLED_DATE
                ,CCT.POSTED_DATE) - 1)
            AND NVL(P_BILLED_END_DATE
             ,NVL(CCT.BILLED_DATE
                ,CCT.POSTED_DATE) + 1)
            AND CCT.BILLED_AMOUNT > DECODE(P_MIN_AMOUNT
                ,NULL
                ,-999999999999
                ,P_MIN_AMOUNT)
            AND P_EMPLOYEE is null )
      GROUP BY
        EMPLOYEE_ID,
        BILLED_CURRENCY_CODE;
  BEGIN
    SELECT
      CARD_PROGRAM_NAME
    INTO V_CARD_PROGRAM_NAME
    FROM
      AP_CARD_PROGRAMS
    WHERE CARD_PROGRAM_ID = P_CARD_PROGRAM_ID;
    OPEN UNSUBMITTEDCHARGES;
    LOOP
      FETCH UNSUBMITTEDCHARGES
       INTO V_EMPLOYEE_ID,V_BILLED_AMOUNT,V_BILLED_CURRENCY_CODE;
      EXIT WHEN UNSUBMITTEDCHARGES%NOTFOUND;
      AP_WEB_CREDIT_CARD_WF.SENDUNSUBMITTEDCHARGESNOTE(V_EMPLOYEE_ID
                                                      ,V_BILLED_AMOUNT
                                                      ,V_BILLED_CURRENCY_CODE
                                                      ,V_CARD_PROGRAM_NAME
                                                      ,TO_CHAR(P_BILLED_START_DATE)
                                                      ,TO_CHAR(P_BILLED_END_DATE)
                                                      ,V_UNSUBMITTED_CHARGE_TYPE);
    END LOOP;
    CLOSE UNSUBMITTEDCHARGES;
  EXCEPTION
    WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20101,null);
  END SENDUNSUBMITTED;

  PROCEDURE SENDMGRUNAPPROVED IS
    V_REPORT_HEADER_ID AP_EXPENSE_REPORT_HEADERS.REPORT_HEADER_ID%TYPE;
    V_CURRENT_APPROVER AP_EXPENSE_REPORT_HEADERS.EXPENSE_CURRENT_APPROVER_ID%TYPE;
    CURSOR UNAPPROVEDCHARGES IS
      SELECT
        DISTINCT
        ERH.REPORT_HEADER_ID,
        ERH.EXPENSE_CURRENT_APPROVER_ID
      FROM
        AP_CREDIT_CARD_TRXNS CCT,
        AP_EXPENSE_REPORT_LINES ERL,
        AP_EXPENSE_REPORT_HEADERS ERH
      WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
        AND CCT.VALIDATE_CODE = 'Y'
        AND CCT.PAYMENT_FLAG <> 'Y'
        AND CCT.EXPENSED_AMOUNT <> 0
        AND NVL(CCT.CATEGORY
         ,'BUSINESS') not in ( 'DISPUTED' , 'MATCHED' , 'CREDIT' , 'DEACTIVATED' )
        AND ERL.CREDIT_CARD_TRX_ID = CCT.TRX_ID
        AND ERH.REPORT_HEADER_ID = ERL.REPORT_HEADER_ID
        AND NVL(ERH.VOUCHNO
         ,0) = 0
        AND ( ERH.SOURCE = 'WebExpense'
        AND ERH.WORKFLOW_APPROVED_FLAG is null
      OR ERH.WORKFLOW_APPROVED_FLAG = 'P' )
        AND NVL(CCT.BILLED_DATE
         ,CCT.POSTED_DATE) between NVL(P_BILLED_START_DATE
         ,NVL(CCT.BILLED_DATE
            ,CCT.POSTED_DATE) - 1)
        AND NVL(P_BILLED_END_DATE
         ,NVL(CCT.BILLED_DATE
            ,CCT.POSTED_DATE) + 1)
        AND CCT.BILLED_AMOUNT > DECODE(P_MIN_AMOUNT
            ,NULL
            ,-999999999999
            ,P_MIN_AMOUNT)
        AND ERH.EMPLOYEE_ID in (
        SELECT
          DISTINCT
          EMPLOYEE_ID
        FROM
          PER_EMPLOYEES_X
        WHERE SUPERVISOR_ID = P_EMPLOYEE )
        AND P_INCLUDE_DIRECTS = 'Y'
        AND ERH.EXPENSE_CURRENT_APPROVER_ID is not null
      GROUP BY
        ERH.REPORT_HEADER_ID,
        ERH.EXPENSE_CURRENT_APPROVER_ID
      UNION ALL
      SELECT
        DISTINCT
        ERH.REPORT_HEADER_ID,
        ERH.EXPENSE_CURRENT_APPROVER_ID
      FROM
        AP_CREDIT_CARD_TRXNS CCT,
        AP_EXPENSE_REPORT_LINES ERL,
        AP_EXPENSE_REPORT_HEADERS ERH
      WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
        AND CCT.VALIDATE_CODE = 'Y'
        AND CCT.PAYMENT_FLAG <> 'Y'
        AND CCT.EXPENSED_AMOUNT <> 0
        AND NVL(CCT.CATEGORY
         ,'BUSINESS') not in ( 'DISPUTED' , 'MATCHED' , 'CREDIT' , 'DEACTIVATED' )
        AND ERL.CREDIT_CARD_TRX_ID = CCT.TRX_ID
        AND ERH.REPORT_HEADER_ID = ERL.REPORT_HEADER_ID
        AND ( ERH.SOURCE = 'WebExpense'
        AND ERH.WORKFLOW_APPROVED_FLAG is null
      OR ERH.WORKFLOW_APPROVED_FLAG = 'P' )
        AND NVL(CCT.BILLED_DATE
         ,CCT.POSTED_DATE) between NVL(P_BILLED_START_DATE
         ,NVL(CCT.BILLED_DATE
            ,CCT.POSTED_DATE) - 1)
        AND NVL(P_BILLED_END_DATE
         ,NVL(CCT.BILLED_DATE
            ,CCT.POSTED_DATE) + 1)
        AND CCT.BILLED_AMOUNT > DECODE(P_MIN_AMOUNT
            ,NULL
            ,-999999999999
            ,P_MIN_AMOUNT)
        AND ERH.EMPLOYEE_ID = P_EMPLOYEE
        AND P_INCLUDE_DIRECTS = 'N'
        AND ERH.EXPENSE_CURRENT_APPROVER_ID is not null
      GROUP BY
        ERH.REPORT_HEADER_ID,
        ERH.EXPENSE_CURRENT_APPROVER_ID
      UNION ALL
      SELECT
        DISTINCT
        ERH.REPORT_HEADER_ID,
        ERH.EXPENSE_CURRENT_APPROVER_ID
      FROM
        AP_CREDIT_CARD_TRXNS CCT,
        AP_EXPENSE_REPORT_LINES ERL,
        AP_EXPENSE_REPORT_HEADERS ERH
      WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
        AND CCT.VALIDATE_CODE = 'Y'
        AND CCT.PAYMENT_FLAG <> 'Y'
        AND CCT.EXPENSED_AMOUNT <> 0
        AND NVL(CCT.CATEGORY
         ,'BUSINESS') not in ( 'DISPUTED' , 'MATCHED' , 'CREDIT' , 'DEACTIVATED' )
        AND ERL.CREDIT_CARD_TRX_ID = CCT.TRX_ID
        AND ERH.REPORT_HEADER_ID = ERL.REPORT_HEADER_ID
        AND NVL(ERH.VOUCHNO
         ,0) = 0
        AND ( ERH.SOURCE = 'WebExpense'
        AND ERH.WORKFLOW_APPROVED_FLAG is null
      OR ERH.WORKFLOW_APPROVED_FLAG = 'P' )
        AND NVL(CCT.BILLED_DATE
         ,CCT.POSTED_DATE) between NVL(P_BILLED_START_DATE
         ,NVL(CCT.BILLED_DATE
            ,CCT.POSTED_DATE) - 1)
        AND NVL(P_BILLED_END_DATE
         ,NVL(CCT.BILLED_DATE
            ,CCT.POSTED_DATE) + 1)
        AND CCT.BILLED_AMOUNT > DECODE(P_MIN_AMOUNT
            ,NULL
            ,-999999999999
            ,P_MIN_AMOUNT)
        AND P_EMPLOYEE is null
        AND ERH.EXPENSE_CURRENT_APPROVER_ID is not null
      GROUP BY
        ERH.REPORT_HEADER_ID,
        ERH.EXPENSE_CURRENT_APPROVER_ID;
  BEGIN
    OPEN UNAPPROVEDCHARGES;
    LOOP
      FETCH UNAPPROVEDCHARGES
       INTO V_REPORT_HEADER_ID,V_CURRENT_APPROVER;
      EXIT WHEN UNAPPROVEDCHARGES%NOTFOUND;
       AP_WEB_CREDIT_CARD_WF.SENDUNAPPROVEDEXPREPORTNOTE(V_REPORT_HEADER_ID
                                                       ,V_CURRENT_APPROVER);
    END LOOP;
    CLOSE UNAPPROVEDCHARGES;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20101,null);
  END SENDMGRUNAPPROVED;

  PROCEDURE SENDDISPUTED IS
    V_EMPLOYEE_ID AP_CARDS.EMPLOYEE_ID%TYPE;
    CURSOR DISPUTEDCHARGES IS
      SELECT
        AC.EMPLOYEE_ID
      FROM
        AP_CREDIT_CARD_TRXNS CCT,
        AP_CARDS_ALL AC
      WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
        AND CCT.VALIDATE_CODE = 'Y'
        AND CCT.PAYMENT_FLAG <> 'Y'
        AND NVL(CCT.EXPENSED_AMOUNT
         ,0) = 0
        AND NVL(CCT.CATEGORY
         ,'BUSINESS') = 'DISPUTED'
        AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
        AND AC.CARD_ID = CCT.CARD_ID
        AND NVL(CCT.BILLED_DATE
         ,CCT.POSTED_DATE) between NVL(P_BILLED_START_DATE
         ,NVL(CCT.BILLED_DATE
            ,CCT.POSTED_DATE) - 1)
        AND NVL(P_BILLED_END_DATE
         ,NVL(CCT.BILLED_DATE
            ,CCT.POSTED_DATE) + 1)
        AND CCT.BILLED_AMOUNT > P_MIN_AMOUNT
      GROUP BY
        EMPLOYEE_ID;
  BEGIN
    OPEN DISPUTEDCHARGES;
    LOOP
      FETCH DISPUTEDCHARGES
       INTO V_EMPLOYEE_ID;
      EXIT WHEN DISPUTEDCHARGES%NOTFOUND;
      AP_WEB_CREDIT_CARD_WF.SENDDISPUTEDCHARGESNOTE(V_EMPLOYEE_ID
                                                   ,P_CARD_PROGRAM_ID
                                                   ,P_BILLED_START_DATE
                                                   ,P_BILLED_END_DATE
                                                   ,P_MIN_AMOUNT);
    END LOOP;
    CLOSE DISPUTEDCHARGES;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20101,null);
  END SENDDISPUTED;

  FUNCTION GETCARDPROGRAMNAME RETURN BOOLEAN IS
  BEGIN
    SELECT
      CARD_PROGRAM_NAME
    INTO CP_CARD_PROGRAM_NAME
    FROM
      AP_CARD_PROGRAMS_ALL CP
    WHERE CP.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GETCARDPROGRAMNAME;

  FUNCTION CF_SUPERVISOR_NAMEFORMULA(SUPERVISOR_ID1 IN NUMBER) RETURN CHAR IS
    L_SUPERVISOR_ID NUMBER;
    L_SUPERVISOR_NAME VARCHAR2(240);
  BEGIN
    SELECT
      FULL_NAME
    INTO L_SUPERVISOR_NAME
    FROM
      PER_EMPLOYEES_X
    WHERE EMPLOYEE_ID = SUPERVISOR_ID1;
     CP_SUPERVISOR_NAME := L_SUPERVISOR_NAME;
    RETURN (CP_SUPERVISOR_NAME);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CF_SUPERVISOR_NAMEFORMULA;

  FUNCTION CF_AGING_BUCKETSFORMULA(AGE_POSTED_DATE IN DATE
                                  ,AGING_AMOUNT IN NUMBER) RETURN CHAR IS
    L_BUCKET_SUM1 NUMBER := 0;
    L_BUCKET_SUM2 NUMBER := 0;
    L_BUCKET_SUM3 NUMBER := 0;
    L_BUCKET_SUM4 NUMBER := 0;
  BEGIN
    CP_BUCKET1 := 0;
    CP_BUCKET2 := 0;
    CP_BUCKET3 := 0;
    CP_BUCKET4 := 0;
    IF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN 0 AND P_BUCKET1) THEN
      CP_BUCKET1 := AGING_AMOUNT;
    ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN P_BUCKET1 + 1 AND P_BUCKET2) THEN
      CP_BUCKET2 := AGING_AMOUNT;
    ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN P_BUCKET2 + 1 AND P_BUCKET3) THEN
      CP_BUCKET3 := AGING_AMOUNT;
    ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) > P_BUCKET3) THEN
      CP_BUCKET4 := AGING_AMOUNT;
    END IF;
    RETURN NULL;
  END CF_AGING_BUCKETSFORMULA;

  FUNCTION CF_AGING_SUP_NAMEFORMULA(AGE_SUPERVISOR_ID IN NUMBER) RETURN CHAR IS
    L_SUPERVISOR_NAME VARCHAR2(240);
  BEGIN
    SELECT
      FULL_NAME
    INTO L_SUPERVISOR_NAME
    FROM
      PER_EMPLOYEES_X
    WHERE EMPLOYEE_ID = AGE_SUPERVISOR_ID;
    CP_AGE_SUP_NAME := L_SUPERVISOR_NAME;
    RETURN (NULL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CF_AGING_SUP_NAMEFORMULA;

  FUNCTION CF_AGE_AMP_NAMEFORMULA(AGE_EMPLOYEE_ID IN NUMBER
                                 ,AGE_EMP_STATUS IN VARCHAR2) RETURN CHAR IS
    L_EMPLOYEE_NAME VARCHAR2(240);
  BEGIN
     SELECT
      FULL_NAME
    INTO L_EMPLOYEE_NAME
    FROM
      PER_EMPLOYEES_X
    WHERE EMPLOYEE_ID = AGE_EMPLOYEE_ID;
    CP_AGE_EMP_NAME := L_EMPLOYEE_NAME || '/' || AGE_EMP_STATUS;
    RETURN NULL;
  END CF_AGE_AMP_NAMEFORMULA;

  FUNCTION CF_EMP_NAME_SUMMFORMULA(EMPLOYEE_ID1 IN NUMBER) RETURN CHAR IS
    L_EMP_NAME VARCHAR2(240);
  BEGIN
    SELECT
      FULL_NAME
    INTO L_EMP_NAME
    FROM
      PER_EMPLOYEES_X
    WHERE EMPLOYEE_ID = EMPLOYEE_ID1;
    CP_EMP_NAME_SUMM := L_EMP_NAME;
    RETURN NULL;
  END CF_EMP_NAME_SUMMFORMULA;

  FUNCTION CF_PENDING_AMOUNTSFORMULA(AGING_REPORT_STATUS_CODE IN VARCHAR2
                                    ,AGE_POSTED_DATE IN DATE
                                    ,AGING_AMOUNT IN NUMBER) RETURN CHAR IS
  BEGIN
    CP_EMP_PEND_BUCKET1 := 0;
    CP_EMP_PEND_BUCKET2 := 0;
    CP_EMP_PEND_BUCKET3 := 0;
    CP_EMP_PEND_BUCKET4 := 0;
    CP_MGR_PEND_BUCKET1 := 0;
    CP_MGR_PEND_BUCKET2 := 0;
    CP_MGR_PEND_BUCKET3 := 0;
    CP_MGR_PEND_BUCKET4 := 0;
    CP_APPR_PEND_BUCKET1 := 0;
    CP_APPR_PEND_BUCKET2 := 0;
    CP_APPR_PEND_BUCKET3 := 0;
    CP_APPR_PEND_BUCKET4 := 0;
    CP_SYS_PEND_BUCKET1 := 0;
    CP_SYS_PEND_BUCKET2 := 0;
    CP_SYS_PEND_BUCKET3 := 0;
    CP_SYS_PEND_BUCKET4 := 0;
    CP_EMP_PENDING := 0;
    CP_MGR_PENDING := 0;
    CP_APPR_PENDING := 0;
    BEGIN
      IF (AGING_REPORT_STATUS_CODE in ('SAVED','INPROGRESS','EMPAPPR','REJECTED','RESOLUTN','RETURNED','UNUSED','WITHDRAWN','DISPUTED')) THEN
        IF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN 0 AND P_BUCKET1) THEN
          CP_EMP_PEND_BUCKET1 := AGING_AMOUNT;
        ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN P_BUCKET1 + 1 AND P_BUCKET2) THEN
          CP_EMP_PEND_BUCKET2 := AGING_AMOUNT;
        ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN P_BUCKET2 + 1 AND P_BUCKET3) THEN
          CP_EMP_PEND_BUCKET3 := AGING_AMOUNT;
        ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) >= P_BUCKET3 + 1) THEN
          CP_EMP_PEND_BUCKET4 := AGING_AMOUNT;
        END IF;
        CP_EMP_PENDING := CP_EMP_PEND_BUCKET1 + CP_EMP_PEND_BUCKET2 + CP_EMP_PEND_BUCKET3 + CP_EMP_PEND_BUCKET4;
      ELSIF (AGING_REPORT_STATUS_CODE in ('PENDMGR')) THEN
        IF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN 0 AND P_BUCKET1) THEN
          CP_MGR_PEND_BUCKET1 := AGING_AMOUNT;
        ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN P_BUCKET1 + 1 AND P_BUCKET2) THEN
          CP_MGR_PEND_BUCKET2 := AGING_AMOUNT;
        ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN P_BUCKET2 + 1 AND P_BUCKET3) THEN
          CP_MGR_PEND_BUCKET3 := AGING_AMOUNT;
        ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) >= P_BUCKET3 + 1) THEN
          CP_MGR_PEND_BUCKET4 := AGING_AMOUNT;
        END IF;
        CP_MGR_PENDING := CP_MGR_PEND_BUCKET1 + CP_MGR_PEND_BUCKET2 + CP_MGR_PEND_BUCKET3 + CP_MGR_PEND_BUCKET4;
      ELSIF (AGING_REPORT_STATUS_CODE in ('MGRAPPR','INVOICED')) THEN
        IF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN 0 AND P_BUCKET1) THEN
          CP_APPR_PEND_BUCKET1 := AGING_AMOUNT;
        ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN P_BUCKET1 + 1 AND P_BUCKET2) THEN
          CP_APPR_PEND_BUCKET2 := AGING_AMOUNT;
        ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN P_BUCKET2 + 1 AND P_BUCKET3) THEN
          CP_APPR_PEND_BUCKET3 := AGING_AMOUNT;
        ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) >= P_BUCKET3 + 1) THEN
          CP_APPR_PEND_BUCKET4 := AGING_AMOUNT;
        END IF;
        CP_APPR_PENDING := CP_APPR_PEND_BUCKET1 + CP_APPR_PEND_BUCKET2 + CP_APPR_PEND_BUCKET3 + CP_APPR_PEND_BUCKET4;
      ELSIF (AGING_REPORT_STATUS_CODE in ('ERROR')) THEN
        IF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN 0 AND P_BUCKET1) THEN
          CP_SYS_PEND_BUCKET1 := AGING_AMOUNT;
        ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN P_BUCKET1 + 1 AND P_BUCKET2) THEN
          CP_SYS_PEND_BUCKET2 := AGING_AMOUNT;
        ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) BETWEEN P_BUCKET2 + 1 AND P_BUCKET3) THEN
          CP_SYS_PEND_BUCKET3 := AGING_AMOUNT;
        ELSIF ((TRUNC(SYSDATE) - AGE_POSTED_DATE) >= P_BUCKET3 + 1) THEN
          CP_SYS_PEND_BUCKET4 := AGING_AMOUNT;
        END IF;
        CP_SYS_PENDING := CP_SYS_PEND_BUCKET1 + CP_SYS_PEND_BUCKET2 + CP_SYS_PEND_BUCKET3 + CP_SYS_PEND_BUCKET4;
      END IF;
      CP_BUCKET1 := CP_EMP_PEND_BUCKET1 + CP_MGR_PEND_BUCKET1 + CP_APPR_PEND_BUCKET1 + CP_SYS_PEND_BUCKET1;
      CP_BUCKET2 := CP_EMP_PEND_BUCKET2 + CP_MGR_PEND_BUCKET2 + CP_APPR_PEND_BUCKET2 + CP_SYS_PEND_BUCKET2;
      CP_BUCKET3 := CP_EMP_PEND_BUCKET3 + CP_MGR_PEND_BUCKET3 + CP_APPR_PEND_BUCKET3 + CP_SYS_PEND_BUCKET3;
      CP_BUCKET4 := CP_EMP_PEND_BUCKET4 + CP_MGR_PEND_BUCKET4 + CP_APPR_PEND_BUCKET4 + CP_SYS_PEND_BUCKET4;
    END;
    RETURN NULL;
  END CF_PENDING_AMOUNTSFORMULA;

  FUNCTION CF_AGE_SUP_PEND_BUCKLET1FORMUL(CS_SUP_BUCKET1 IN NUMBER
                                         ,CS_SUP_BUCKET2 IN NUMBER
                                         ,CS_SUP_BUCKET3 IN NUMBER
                                         ,CS_SUP_BUCKET4 IN NUMBER) RETURN CHAR IS
  BEGIN
    CP_SUP_PEND_BUCKET1 := NVL(CS_SUP_BUCKET1
                              ,0);
    CP_SUP_PEND_BUCKET2 := NVL(CS_SUP_BUCKET2
                              ,0);
    CP_SUP_PEND_BUCKET3 := NVL(CS_SUP_BUCKET3
                              ,0);
    CP_SUP_PEND_BUCKET4 := NVL(CS_SUP_BUCKET4
                              ,0);
    RETURN NULL;
  END CF_AGE_SUP_PEND_BUCKLET1FORMUL;

  PROCEDURE SEND1DUNNINGNOTIFICATIONS(P_IN_MIN_BUCKET IN NUMBER
                                     ,P_IN_MAX_BUCKET IN NUMBER
                                     ,P_IN_DUNNING_NUMBER IN NUMBER
                                     ,P_IN_SEND_NOTIFICATIONS IN VARCHAR2
                                     ,P_IN_ESC_LEVEL IN NUMBER
                                     ,P_IN_GRACE_DAYS IN NUMBER) IS
    V_EMPLOYEE_ID PER_PEOPLE_F.PERSON_ID%TYPE;
    V_CARD_PROGRAM_ID AP_CREDIT_CARD_TRXNS.CARD_PROGRAM_ID%TYPE;
    V_MIN_BUCKET NUMBER;
    V_MAX_BUCKET NUMBER;
    V_BILLED_AMOUNT AP_CREDIT_CARD_TRXNS.BILLED_AMOUNT%TYPE;
    V_BILLED_CURRENCY_CODE AP_CREDIT_CARD_TRXNS.BILLED_CURRENCY_CODE%TYPE;
    V_DUNNING_NUMBER NUMBER;
    V_SEND_NOTIFICATIONS VARCHAR2(20);
    V_ESC_LEVEL NUMBER;
    V_GRACE_DAYS NUMBER;
    TYPE L_MANAGERIDLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    L_MANAGER_IDLIST L_MANAGERIDLIST;
    L_COUNTER NUMBER := 1;
    L_MANAGER_ID NUMBER;
    L_MANAGER_NOTIFIED VARCHAR2(1) := 'N';
    L_TEMP_EMPLOYEE_ID NUMBER := 0;
    L_ORIG_MANAGER_ID NUMBER := 0;
    L_NEXT_MANAGER_ID NUMBER := 0;
    L_JOB_LEVEL NUMBER := 0;
    L_NEXT_MGR_JOB_LEVEL NUMBER := 0;
    I NUMBER := 1;
    CURSOR SEND1DUNNINGNOTIFICATIONS IS
      SELECT
        EMPLOYEE_ID,
        SUM(BILLED_AMOUNT),
        BILLED_CURRENCY_CODE
      FROM
        (   SELECT
            DISTINCT
            AC.EMPLOYEE_ID,
            CCT.BILLED_AMOUNT,
            CCT.BILLED_CURRENCY_CODE,
            CCT.TRX_ID
          FROM
            AP_CREDIT_CARD_TRXNS CCT,
            AP_CARDS AC,
            AP_CARD_PROGRAMS CP,
            AP_EXPENSE_REPORT_LINES ERL,
            AP_EXPENSE_REPORT_HEADERS ERH
          WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
            AND CCT.VALIDATE_CODE = 'Y'
            AND CCT.PAYMENT_FLAG <> 'Y'
            AND NVL(CCT.CATEGORY
             ,'BUSINESS') NOT IN ( 'DEACTIVATED' , 'MATCHED' , 'CREDIT' )
            AND erl.credit_card_trx_id (+) = CCT.TRX_ID
            AND erh.report_header_id (+) = ERL.REPORT_HEADER_ID
            AND NVL(ERH.VOUCHNO
             ,0) = 0
            AND NVL(AP_WEB_OA_ACTIVE_PKG.GETREPORTSTATUSCODE(ERH.SOURCE
                                                      ,ERH.WORKFLOW_APPROVED_FLAG
                                                      ,ERH.REPORT_HEADER_ID)
             ,'UNUSED') in ( 'UNUSED' , 'SAVED' , 'INPROGRESS' , 'EMPAPPR' , 'REJECTED' , 'RESOLUTN' , 'WITHDRAWN' , 'RETURNED' )
            AND AP_WEB_OA_ACTIVE_PKG.GETINCLUDENOTIFICATION(CCT.CATEGORY
                                                     ,CCT.TRX_ID) = 'TRUE'
            AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
            AND AC.CARD_ID = CCT.CARD_ID
            AND CP.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
            AND ( AC.EMPLOYEE_ID in (
            SELECT
              DISTINCT
              EMPLOYEE_ID
            FROM
              PER_EMPLOYEES_X EMP1
            WHERE EMP1.SUPERVISOR_ID = P_EMPLOYEE )
          OR AC.EMPLOYEE_ID = P_EMPLOYEE )
            AND ( TRUNC(SYSDATE) - ( CCT.POSTED_DATE + DECODE(CCT.CATEGORY
                ,'DISPUTED'
                ,NVL(P_IN_GRACE_DAYS
                   ,0)
                ,0) ) between P_IN_MIN_BUCKET
            AND P_IN_MAX_BUCKET )
            AND CCT.BILLED_AMOUNT > DECODE(P_MIN_AMOUNT
                ,NULL
                ,-999999999999
                ,P_MIN_AMOUNT)
            AND P_INCLUDE_DIRECTS = 'Y'
            AND exists (
            SELECT
              1
            FROM
              AP_EXPENSE_REPORT_HEADERS_ALL ERH2
            WHERE ERH2.REPORT_HEADER_ID = CCT.REPORT_HEADER_ID
            OR ( CCT.REPORT_HEADER_ID is null
              AND NVL(CCT.EXPENSED_AMOUNT
               ,0) = 0 )
              AND ROWNUM = 1 )
          UNION ALL
          SELECT
            DISTINCT
            AC.EMPLOYEE_ID,
            CCT.BILLED_AMOUNT,
            CCT.BILLED_CURRENCY_CODE,
            CCT.TRX_ID
          FROM
            AP_CREDIT_CARD_TRXNS CCT,
            AP_CARDS AC,
            AP_CARD_PROGRAMS CP,
            AP_EXPENSE_REPORT_LINES ERL,
            AP_EXPENSE_REPORT_HEADERS ERH
          WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
            AND CCT.VALIDATE_CODE = 'Y'
            AND CCT.PAYMENT_FLAG <> 'Y'
            AND NVL(CCT.CATEGORY
             ,'BUSINESS') NOT IN ( 'DEACTIVATED' , 'MATCHED' , 'CREDIT' )
            AND erl.credit_card_trx_id (+) = CCT.TRX_ID
            AND NVL(AP_WEB_OA_ACTIVE_PKG.GETREPORTSTATUSCODE(ERH.SOURCE
                                                      ,ERH.WORKFLOW_APPROVED_FLAG
                                                      ,ERH.REPORT_HEADER_ID)
             ,'UNUSED') in ( 'UNUSED' , 'SAVED' , 'INPROGRESS' , 'EMPAPPR' , 'REJECTED' , 'RESOLUTN' , 'WITHDRAWN' , 'RETURNED' )
            AND AP_WEB_OA_ACTIVE_PKG.GETINCLUDENOTIFICATION(CCT.CATEGORY
                                                     ,CCT.TRX_ID) = 'TRUE'
            AND erh.report_header_id (+) = ERL.REPORT_HEADER_ID
            AND NVL(ERH.VOUCHNO
             ,0) = 0
            AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
            AND AC.CARD_ID = CCT.CARD_ID
            AND CP.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
            AND ( TRUNC(SYSDATE) - ( CCT.POSTED_DATE + DECODE(CCT.CATEGORY
                ,'DISPUTED'
                ,NVL(P_IN_GRACE_DAYS
                   ,0)
                ,0) ) between P_IN_MIN_BUCKET
            AND P_IN_MAX_BUCKET )
            AND CCT.BILLED_AMOUNT > DECODE(P_MIN_AMOUNT
                ,NULL
                ,-999999999999
                ,P_MIN_AMOUNT)
            AND AC.EMPLOYEE_ID = P_EMPLOYEE
            AND P_INCLUDE_DIRECTS = 'N'
            AND exists (
            SELECT
              1
            FROM
              AP_EXPENSE_REPORT_HEADERS_ALL ERH2
            WHERE ERH2.REPORT_HEADER_ID = CCT.REPORT_HEADER_ID
            OR ( CCT.REPORT_HEADER_ID is null
              AND NVL(CCT.EXPENSED_AMOUNT
               ,0) = 0 )
              AND ROWNUM = 1 )
          UNION ALL
          SELECT
            DISTINCT
            AC.EMPLOYEE_ID,
            CCT.BILLED_AMOUNT,
            CCT.BILLED_CURRENCY_CODE,
            CCT.TRX_ID
          FROM
            AP_CREDIT_CARD_TRXNS CCT,
            AP_CARDS AC,
            AP_CARD_PROGRAMS CP,
            AP_EXPENSE_REPORT_LINES ERL,
            AP_EXPENSE_REPORT_HEADERS ERH
          WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
            AND CCT.VALIDATE_CODE = 'Y'
            AND CCT.PAYMENT_FLAG <> 'Y'
            AND NVL(CCT.CATEGORY
             ,'BUSINESS') NOT IN ( 'DEACTIVATED' , 'MATCHED' , 'CREDIT' )
            AND erl.credit_card_trx_id (+) = CCT.TRX_ID
            AND erh.report_header_id (+) = ERL.REPORT_HEADER_ID
            AND NVL(ERH.VOUCHNO
             ,0) = 0
            AND NVL(AP_WEB_OA_ACTIVE_PKG.GETREPORTSTATUSCODE(ERH.SOURCE
                                                      ,ERH.WORKFLOW_APPROVED_FLAG
                                                      ,ERH.REPORT_HEADER_ID)
             ,'UNUSED') in ( 'UNUSED' , 'SAVED' , 'INPROGRESS' , 'EMPAPPR' , 'REJECTED' , 'RESOLUTN' , 'WITHDRAWN' , 'RETURNED' )
            AND AP_WEB_OA_ACTIVE_PKG.GETINCLUDENOTIFICATION(CCT.CATEGORY
                                                     ,CCT.TRX_ID) = 'TRUE'
            AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
            AND AC.CARD_ID = CCT.CARD_ID
            AND CP.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
            AND ( TRUNC(SYSDATE) - ( CCT.POSTED_DATE + DECODE(CCT.CATEGORY
                ,'DISPUTED'
                ,NVL(P_IN_GRACE_DAYS
                   ,0)
                ,0) ) between P_IN_MIN_BUCKET
            AND P_IN_MAX_BUCKET )
            AND CCT.BILLED_AMOUNT > DECODE(P_MIN_AMOUNT
                ,NULL
                ,-999999999999
                ,P_MIN_AMOUNT)
            AND P_EMPLOYEE is null
            AND exists (
            SELECT
              1
            FROM
              AP_EXPENSE_REPORT_HEADERS_ALL ERH2
            WHERE ERH2.REPORT_HEADER_ID = CCT.REPORT_HEADER_ID
            OR ( CCT.REPORT_HEADER_ID is null
              AND NVL(CCT.EXPENSED_AMOUNT
               ,0) = 0 )
              AND ROWNUM = 1 ) )
      GROUP BY
        EMPLOYEE_ID,
        BILLED_CURRENCY_CODE;
  BEGIN
    V_MIN_BUCKET := P_IN_MIN_BUCKET;
    V_MAX_BUCKET := P_IN_MAX_BUCKET;
    V_CARD_PROGRAM_ID := P_CARD_PROGRAM_ID;
    V_DUNNING_NUMBER := P_IN_DUNNING_NUMBER;
    V_SEND_NOTIFICATIONS := P_IN_SEND_NOTIFICATIONS;
    V_ESC_LEVEL := P_IN_ESC_LEVEL;
    V_GRACE_DAYS := P_IN_GRACE_DAYS;

    OPEN SEND1DUNNINGNOTIFICATIONS;
    LOOP
      FETCH SEND1DUNNINGNOTIFICATIONS
       INTO V_EMPLOYEE_ID,V_BILLED_AMOUNT,V_BILLED_CURRENCY_CODE;
      EXIT WHEN SEND1DUNNINGNOTIFICATIONS%NOTFOUND;
      L_MANAGER_NOTIFIED := 'N';

      IF V_EMPLOYEE_ID IS NOT NULL THEN
        AP_WEB_EXPENSE_WF.GETMANAGER(V_EMPLOYEE_ID
                                    ,L_MANAGER_ID);
        IF P_SEND_NOTIFICATIONS = 'ES' THEN
          L_TEMP_EMPLOYEE_ID := V_EMPLOYEE_ID;
          L_ORIG_MANAGER_ID := L_MANAGER_ID;
          L_NEXT_MANAGER_ID := L_MANAGER_ID;
          L_JOB_LEVEL := 0;
          I := 1;
          WHILE I <= V_DUNNING_NUMBER LOOP

            AP_WEB_EXPENSE_WF.GETJOBLEVELANDSUPERVISOR(L_MANAGER_ID
                                                      ,L_JOB_LEVEL);
            IF L_JOB_LEVEL < NVL(P_ESC_LEVEL
               ,999999999) THEN
              AP_WEB_EXPENSE_WF.GETMANAGER(L_TEMP_EMPLOYEE_ID
                                          ,L_MANAGER_ID);
              IF (L_MANAGER_ID IS NULL) THEN
                L_MANAGER_ID := L_TEMP_EMPLOYEE_ID;
                EXIT;
              END IF;
              AP_WEB_EXPENSE_WF.GETJOBLEVELANDSUPERVISOR(L_MANAGER_ID
                                                        ,L_JOB_LEVEL);
              AP_WEB_EXPENSE_WF.GETMANAGER(L_MANAGER_ID
                                          ,L_NEXT_MANAGER_ID);
              IF (L_NEXT_MANAGER_ID IS NOT NULL) THEN
                AP_WEB_EXPENSE_WF.GETJOBLEVELANDSUPERVISOR(L_NEXT_MANAGER_ID
                                                          ,L_NEXT_MGR_JOB_LEVEL);
                IF (L_NEXT_MGR_JOB_LEVEL > NVL(P_ESC_LEVEL
                   ,999999999)) THEN
                  L_TEMP_EMPLOYEE_ID := L_MANAGER_ID;
                  EXIT;
                END IF;
              ELSE
                L_NEXT_MANAGER_ID := L_MANAGER_ID;
              END IF;
            END IF;
            L_TEMP_EMPLOYEE_ID := L_MANAGER_ID;
            I := I + 1;
          END LOOP;
          IF L_JOB_LEVEL = 0 AND P_ESC_LEVEL IS NOT NULL THEN
            L_MANAGER_ID := L_NEXT_MANAGER_ID;
            L_TEMP_EMPLOYEE_ID := L_MANAGER_ID;
          END IF;
        END IF;
        FOR i IN 1 .. (L_COUNTER - 1) LOOP
          IF L_MANAGER_ID = L_MANAGER_IDLIST(I) THEN
            L_MANAGER_NOTIFIED := 'Y';
          END IF;
        END LOOP;
         AP_WEB_CREDIT_CARD_WF.SENDDUNNINGNOTIFICATIONS(V_EMPLOYEE_ID
                                                      ,V_CARD_PROGRAM_ID
                                                      ,V_BILLED_AMOUNT
                                                      ,V_BILLED_CURRENCY_CODE
                                                      ,V_MIN_BUCKET
                                                      ,V_MAX_BUCKET
                                                      ,V_DUNNING_NUMBER
                                                      ,V_SEND_NOTIFICATIONS
                                                      ,V_ESC_LEVEL
                                                      ,V_GRACE_DAYS
                                                      ,L_MANAGER_NOTIFIED);
        L_MANAGER_IDLIST(L_COUNTER) := L_MANAGER_ID;
        L_COUNTER := L_COUNTER + 1;
      END IF;
    END LOOP;
    CLOSE SEND1DUNNINGNOTIFICATIONS;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20101,null);
  END SEND1DUNNINGNOTIFICATIONS;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION CF_MASKED_CARD_NUMBERFORMULA(C_CARD_NUMBER IN VARCHAR2) RETURN CHAR IS
  BEGIN
    CP_MASKED_CARD_NUMBER := C_CARD_NUMBER;
    RETURN NULL;
  END CF_MASKED_CARD_NUMBERFORMULA;

  PROCEDURE AP_WEB_START_INACT_PRO(P_CARD_PROGRAM_ID IN NUMBER
                                  ,P_CC_BILLED_START_DATE IN DATE
                                  ,P_CC_BILLED_END_DATE IN DATE
                                  ,P_ERRNUM OUT NOCOPY NUMBER
                                  ,P_ERRMSG OUT NOCOPY VARCHAR2) IS
    L_CC_BILLED_START_DATE DATE;
    L_CC_BILLED_END_DATE DATE;
    L_BILLED_DATE DATE;
    L_WF_ITEM_KEY VARCHAR2(100);
    L_WF_ITEM_TYPE VARCHAR2(100) := 'APCCARD';
    L_TOTAL_AMT_POSTED NUMBER;
    CURSOR C_PREPARER_NOTIFIED(P_CARD_PROGRAM_ID IN NUMBER,P_CC_BILLED_START_DATE IN DATE,P_CC_BILLED_END_DATE IN DATE) IS
      SELECT
        CCT.CARD_PROGRAM_ID CARD_PROGRAM_ID,
        AC.EMPLOYEE_ID INACT_EMPLOYEE_ID,
        CCT.BILLED_CURRENCY_CODE BILLED_CURRENCY_CODE,
        SUM(CCT.BILLED_AMOUNT) TOTAL_AMT_POSTED
      FROM
        AP_CREDIT_CARD_TRXNS CCT,
        AP_CARDS_ALL AC
      WHERE AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
        AND AC.CARD_ID = CCT.CARD_ID
        AND CCT.TRX_ID in (
        SELECT
          CCT.TRX_ID
        FROM
          AP_CREDIT_CARD_TRXNS CCT,
          AP_CARDS_ALL AC,
          AP_CARD_PROGRAMS_ALL CP,
          PER_PEOPLE_F PERF,
          PER_ASSIGNMENTS_F PERA,
          PER_ASSIGNMENT_STATUS_TYPES PERAS
        WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
          AND CCT.PAYMENT_FLAG <> 'Y'
          AND NVL(CCT.CATEGORY
           ,'BUSINESS') <> 'DEACTIVATED'
          AND NVL(CCT.EXPENSED_AMOUNT
           ,0) = 0
          AND CCT.VALIDATE_CODE = 'Y'
          AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
          AND AC.CARD_ID = CCT.CARD_ID
          AND CP.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
          AND AC.EMPLOYEE_ID = PERF.PERSON_ID
          AND PERF.PERSON_ID = PERA.PERSON_ID
          AND PERA.ASSIGNMENT_STATUS_TYPE_ID = PERAS.ASSIGNMENT_STATUS_TYPE_ID
          AND PERA.PRIMARY_FLAG = 'Y'
          AND PERA.ASSIGNMENT_TYPE = 'E'
          AND PER_SYSTEM_STATUS in ( 'TERM_ASSIGN' , 'SUSP_ASSIGN' )
          AND TRUNC(SYSDATE) between PERF.EFFECTIVE_START_DATE
          AND PERF.EFFECTIVE_END_DATE
          AND TRUNC(SYSDATE) between PERA.EFFECTIVE_START_DATE
          AND PERA.EFFECTIVE_END_DATE
          AND TRUNC(NVL(CCT.BILLED_DATE
                 ,CCT.POSTED_DATE)) between NVL(P_CC_BILLED_START_DATE
           ,(NVL(CCT.BILLED_DATE
              ,CCT.POSTED_DATE) - 1))
          AND NVL(P_CC_BILLED_END_DATE
           ,(NVL(CCT.BILLED_DATE
              ,CCT.POSTED_DATE) + 1))
          AND CCT.INACTIVE_EMP_WF_ITEM_KEY IS NULL
          AND CCT.REPORT_HEADER_ID IS NULL
        UNION ALL
        SELECT
          CCT.TRX_ID
        FROM
          AP_CREDIT_CARD_TRXNS CCT,
          AP_CARDS_ALL AC,
          AP_CARD_PROGRAMS_ALL CP,
          PER_PEOPLE_F PERF,
          PER_ASSIGNMENTS_F PERA,
          PER_ASSIGNMENT_STATUS_TYPES PERAS,
          AP_EXPENSE_REPORT_HEADERS ERH
        WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
          AND CCT.PAYMENT_FLAG <> 'Y'
          AND CCT.EXPENSED_AMOUNT <> 0
          AND CCT.VALIDATE_CODE = 'Y'
          AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
          AND AC.CARD_ID = CCT.CARD_ID
          AND CP.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
          AND AC.EMPLOYEE_ID = PERF.PERSON_ID
          AND PERF.PERSON_ID = PERA.PERSON_ID
          AND PERA.ASSIGNMENT_STATUS_TYPE_ID = PERAS.ASSIGNMENT_STATUS_TYPE_ID
          AND PERA.PRIMARY_FLAG = 'Y'
          AND PERA.ASSIGNMENT_TYPE = 'E'
          AND PER_SYSTEM_STATUS in ( 'TERM_ASSIGN' , 'SUSP_ASSIGN' )
          AND TRUNC(SYSDATE) between PERF.EFFECTIVE_START_DATE
          AND PERF.EFFECTIVE_END_DATE
          AND TRUNC(SYSDATE) between PERA.EFFECTIVE_START_DATE
          AND PERA.EFFECTIVE_END_DATE
          AND CCT.REPORT_HEADER_ID = erh.report_header_id (+)
          AND AP_WEB_OA_ACTIVE_PKG.GETREPORTSTATUSCODE(ERH.SOURCE
                                                ,ERH.WORKFLOW_APPROVED_FLAG
                                                ,ERH.REPORT_HEADER_ID) in ( 'EMPAPPR' , 'RESOLUTN' , 'RETURNED' , 'REJECTED' , 'WITHDRAWN' , 'SAVED' , 'INPROGRESS' )
          AND TRUNC(NVL(CCT.BILLED_DATE
                 ,CCT.POSTED_DATE)) between NVL(P_CC_BILLED_START_DATE
           ,(NVL(CCT.BILLED_DATE
              ,CCT.POSTED_DATE) - 1))
          AND NVL(P_CC_BILLED_END_DATE
           ,(NVL(CCT.BILLED_DATE
              ,CCT.POSTED_DATE) + 1))
          AND CCT.INACTIVE_EMP_WF_ITEM_KEY IS NULL )
        AND NVL(CCT.CATEGORY
         ,'BUSINESS') <> 'DEACTIVATED'
      GROUP BY
        CCT.CARD_PROGRAM_ID,
        AC.EMPLOYEE_ID,
        CCT.BILLED_CURRENCY_CODE;
    R_PREPARER_NOTIFIED C_PREPARER_NOTIFIED%ROWTYPE;
    CURSOR C_CCTRX_UPDATE(P_CARD_PROGRAM_ID IN NUMBER,P_INACT_EMPLOYEE_ID IN NUMBER,P_CC_BILLED_START_DATE IN DATE,P_CC_BILLED_END_DATE IN DATE) IS
      SELECT
        DISTINCT
        CCT.TRX_ID
      FROM
        AP_CREDIT_CARD_TRXNS CCT,
        AP_CARDS_ALL AC,
        AP_CARD_PROGRAMS_ALL CP,
        PER_PEOPLE_F PERF,
        PER_ASSIGNMENTS_F PERA,
        PER_ASSIGNMENT_STATUS_TYPES PERAS
      WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
        AND CCT.PAYMENT_FLAG <> 'Y'
        AND NVL(CCT.EXPENSED_AMOUNT
         ,0) = 0
        AND CCT.VALIDATE_CODE = 'Y'
        AND NVL(CCT.CATEGORY
         ,'BUSINESS') <> 'DEACTIVATED'
        AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
        AND AC.CARD_ID = CCT.CARD_ID
        AND CP.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
        AND AC.EMPLOYEE_ID = P_INACT_EMPLOYEE_ID
        AND PERF.PERSON_ID = AC.EMPLOYEE_ID
        AND PERA.PERSON_ID = PERF.PERSON_ID
        AND PERA.ASSIGNMENT_STATUS_TYPE_ID = PERAS.ASSIGNMENT_STATUS_TYPE_ID
        AND PERA.PRIMARY_FLAG = 'Y'
        AND PERA.ASSIGNMENT_TYPE = 'E'
        AND PER_SYSTEM_STATUS in ( 'TERM_ASSIGN' , 'SUSP_ASSIGN' )
        AND TRUNC(SYSDATE) between PERF.EFFECTIVE_START_DATE
        AND PERF.EFFECTIVE_END_DATE
        AND TRUNC(SYSDATE) between PERA.EFFECTIVE_START_DATE
        AND PERA.EFFECTIVE_END_DATE
        AND NVL(CCT.BILLED_DATE
         ,CCT.POSTED_DATE) between NVL(P_CC_BILLED_START_DATE
         ,(NVL(CCT.BILLED_DATE
            ,CCT.POSTED_DATE) - 1))
        AND NVL(P_CC_BILLED_END_DATE
         ,(NVL(CCT.BILLED_DATE
            ,CCT.POSTED_DATE) + 1))
        AND CCT.INACTIVE_EMP_WF_ITEM_KEY IS NULL
      UNION
      SELECT
        DISTINCT
        CCT.TRX_ID
      FROM
        AP_CREDIT_CARD_TRXNS CCT,
        AP_CARDS_ALL AC,
        AP_CARD_PROGRAMS_ALL CP,
        PER_PEOPLE_F PERF,
        PER_ASSIGNMENTS_F PERA,
        PER_ASSIGNMENT_STATUS_TYPES PERAS,
        AP_EXPENSE_REPORT_HEADERS ERH
      WHERE CCT.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
        AND CCT.PAYMENT_FLAG <> 'Y'
        AND CCT.EXPENSED_AMOUNT <> 0
        AND CCT.VALIDATE_CODE = 'Y'
        AND AC.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
        AND AC.CARD_ID = CCT.CARD_ID
        AND CP.CARD_PROGRAM_ID = CCT.CARD_PROGRAM_ID
        AND AC.EMPLOYEE_ID = P_INACT_EMPLOYEE_ID
        AND PERF.PERSON_ID = AC.EMPLOYEE_ID
        AND PERA.PERSON_ID = PERF.PERSON_ID
        AND PERA.ASSIGNMENT_STATUS_TYPE_ID = PERAS.ASSIGNMENT_STATUS_TYPE_ID
        AND PERA.PRIMARY_FLAG = 'Y'
        AND PERA.ASSIGNMENT_TYPE = 'E'
        AND PER_SYSTEM_STATUS in ( 'TERM_ASSIGN' , 'SUSP_ASSIGN' )
        AND TRUNC(SYSDATE) between PERF.EFFECTIVE_START_DATE
        AND PERF.EFFECTIVE_END_DATE
        AND TRUNC(SYSDATE) between PERA.EFFECTIVE_START_DATE
        AND PERA.EFFECTIVE_END_DATE
        AND CCT.REPORT_HEADER_ID = erh.report_header_id (+)
        AND NVL(CCT.CATEGORY
         ,'BUSINESS') <> 'DEACTIVATED'
        AND AP_WEB_OA_ACTIVE_PKG.GETREPORTSTATUSCODE(ERH.SOURCE
                                              ,ERH.WORKFLOW_APPROVED_FLAG
                                              ,ERH.REPORT_HEADER_ID) in ( 'EMPAPPR' , 'RESOLUTN' , 'RETURNED' , 'REJECTED' , 'WITHDRAWN' , 'SAVED' , 'INPROGRESS' )
        AND NVL(CCT.BILLED_DATE
         ,CCT.POSTED_DATE) between NVL(P_CC_BILLED_START_DATE
         ,(NVL(CCT.BILLED_DATE
            ,CCT.POSTED_DATE) - 1))
        AND NVL(P_CC_BILLED_END_DATE
         ,(NVL(CCT.BILLED_DATE
            ,CCT.POSTED_DATE) + 1))
        AND CCT.INACTIVE_EMP_WF_ITEM_KEY IS NULL;
    R_CCTRX_UPDATE C_CCTRX_UPDATE%ROWTYPE;
  BEGIN
    L_CC_BILLED_START_DATE := P_CC_BILLED_START_DATE;
    L_CC_BILLED_END_DATE := P_CC_BILLED_END_DATE;
    OPEN C_PREPARER_NOTIFIED(P_CARD_PROGRAM_ID,P_CC_BILLED_START_DATE,P_CC_BILLED_END_DATE);
    LOOP
      FETCH C_PREPARER_NOTIFIED
       INTO R_PREPARER_NOTIFIED;
      EXIT WHEN C_PREPARER_NOTIFIED%NOTFOUND;
      BEGIN
        SELECT
          TO_CHAR(AP_CCARD_NOTIFICATION_ID_S.NEXTVAL)
        INTO L_WF_ITEM_KEY
        FROM
          SYS.DUAL;
      END;
      AP_WEB_INACTIVE_EMP_WF_PKG.START_INACTIVE_EMP_PROCESS(R_PREPARER_NOTIFIED.CARD_PROGRAM_ID
                                                           ,R_PREPARER_NOTIFIED.INACT_EMPLOYEE_ID
                                                           ,R_PREPARER_NOTIFIED.BILLED_CURRENCY_CODE
                                                           ,R_PREPARER_NOTIFIED.TOTAL_AMT_POSTED
                                                           ,L_CC_BILLED_START_DATE
                                                           ,L_CC_BILLED_END_DATE
                                                           ,L_WF_ITEM_TYPE
                                                           ,L_WF_ITEM_KEY);
      OPEN C_CCTRX_UPDATE(R_PREPARER_NOTIFIED.CARD_PROGRAM_ID,R_PREPARER_NOTIFIED.INACT_EMPLOYEE_ID,L_CC_BILLED_START_DATE,L_CC_BILLED_END_DATE);
      LOOP
        FETCH C_CCTRX_UPDATE
         INTO R_CCTRX_UPDATE;
        EXIT WHEN C_CCTRX_UPDATE%NOTFOUND;
        UPDATE
          AP_CREDIT_CARD_TRXNS
        SET
          INACTIVE_EMP_WF_ITEM_KEY = L_WF_ITEM_KEY
        WHERE TRX_ID = R_CCTRX_UPDATE.TRX_ID;
      END LOOP;
      COMMIT;
      CLOSE C_CCTRX_UPDATE;
    END LOOP;
    CLOSE C_PREPARER_NOTIFIED;
  EXCEPTION
    WHEN OTHERS THEN
      P_ERRNUM := TO_NUMBER(SQLCODE);
      P_ERRMSG := SQLERRM;
  END AP_WEB_START_INACT_PRO;

  FUNCTION CP_UNSUBMITTED_P RETURN NUMBER IS
  BEGIN
    RETURN CP_UNSUBMITTED;
  END CP_UNSUBMITTED_P;

  FUNCTION CP_REJECTED_P RETURN NUMBER IS
  BEGIN
    RETURN CP_REJECTED;
  END CP_REJECTED_P;

  FUNCTION CP_WITHDRAWN_P RETURN NUMBER IS
  BEGIN
    RETURN CP_WITHDRAWN;
  END CP_WITHDRAWN_P;

  FUNCTION CP_SAVED_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SAVED;
  END CP_SAVED_P;

  FUNCTION CP_RETURNED_P RETURN NUMBER IS
  BEGIN
    RETURN CP_RETURNED;
  END CP_RETURNED_P;

  FUNCTION CP_RESOLUTN_P RETURN NUMBER IS
  BEGIN
    RETURN CP_RESOLUTN;
  END CP_RESOLUTN_P;

  FUNCTION CP_INVOICED_P RETURN NUMBER IS
  BEGIN
    RETURN CP_INVOICED;
  END CP_INVOICED_P;

  FUNCTION CP_ERROR_P RETURN NUMBER IS
  BEGIN
    RETURN CP_ERROR;
  END CP_ERROR_P;

  FUNCTION CP_EMP_APPR_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EMP_APPR;
  END CP_EMP_APPR_P;

  FUNCTION CP_MGR_UNAPPROVED_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MGR_UNAPPROVED;
  END CP_MGR_UNAPPROVED_P;

  FUNCTION CP_AP_UNAPPROVED_P RETURN NUMBER IS
  BEGIN
    RETURN CP_AP_UNAPPROVED;
  END CP_AP_UNAPPROVED_P;

  FUNCTION CP_DISPUTED_P RETURN NUMBER IS
  BEGIN
    RETURN CP_DISPUTED;
  END CP_DISPUTED_P;

  FUNCTION CP_MASKED_CARD_NUMBER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_MASKED_CARD_NUMBER;
  END CP_MASKED_CARD_NUMBER_P;

  FUNCTION CP_SUPERVISOR_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SUPERVISOR_NAME;
  END CP_SUPERVISOR_NAME_P;

  FUNCTION CP_EMP_NAME_SUMM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_EMP_NAME_SUMM;
  END CP_EMP_NAME_SUMM_P;

  FUNCTION CP_AGE_SUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_AGE_SUP_NAME;
  END CP_AGE_SUP_NAME_P;

  FUNCTION CP_SUP_PEND_BUCKET1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SUP_PEND_BUCKET1;
  END CP_SUP_PEND_BUCKET1_P;

  FUNCTION CP_SUP_PEND_BUCKET2_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SUP_PEND_BUCKET2;
  END CP_SUP_PEND_BUCKET2_P;

  FUNCTION CP_SUP_PEND_BUCKET3_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SUP_PEND_BUCKET3;
  END CP_SUP_PEND_BUCKET3_P;

  FUNCTION CP_SUP_PEND_BUCKET4_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SUP_PEND_BUCKET4;
  END CP_SUP_PEND_BUCKET4_P;

  FUNCTION CP_AGE_EMP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_AGE_EMP_NAME;
  END CP_AGE_EMP_NAME_P;

  FUNCTION CP_APPR_PEND_BUCKET1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_APPR_PEND_BUCKET1;
  END CP_APPR_PEND_BUCKET1_P;

  FUNCTION CP_APPR_PEND_BUCKET3_P RETURN NUMBER IS
  BEGIN
    RETURN CP_APPR_PEND_BUCKET3;
  END CP_APPR_PEND_BUCKET3_P;

  FUNCTION CP_APPR_PEND_BUCKET4_P RETURN NUMBER IS
  BEGIN
    RETURN CP_APPR_PEND_BUCKET4;
  END CP_APPR_PEND_BUCKET4_P;

  FUNCTION CP_APPR_PEND_BUCKET2_P RETURN NUMBER IS
  BEGIN
    RETURN CP_APPR_PEND_BUCKET2;
  END CP_APPR_PEND_BUCKET2_P;

  FUNCTION CP_EMP_PEND_BUCKET1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EMP_PEND_BUCKET1;
  END CP_EMP_PEND_BUCKET1_P;

  FUNCTION CP_EMP_PEND_BUCKET2_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EMP_PEND_BUCKET2;
  END CP_EMP_PEND_BUCKET2_P;

  FUNCTION CP_EMP_PEND_BUCKET3_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EMP_PEND_BUCKET3;
  END CP_EMP_PEND_BUCKET3_P;

  FUNCTION CP_EMP_PEND_BUCKET4_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EMP_PEND_BUCKET4;
  END CP_EMP_PEND_BUCKET4_P;

  FUNCTION CP_SYS_PEND_BUCKET2_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SYS_PEND_BUCKET2;
  END CP_SYS_PEND_BUCKET2_P;

  FUNCTION CP_SYS_PEND_BUCKET3_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SYS_PEND_BUCKET3;
  END CP_SYS_PEND_BUCKET3_P;

  FUNCTION CP_SYS_PEND_BUCKET4_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SYS_PEND_BUCKET4;
  END CP_SYS_PEND_BUCKET4_P;

  FUNCTION CP_SYS_PEND_BUCKET1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SYS_PEND_BUCKET1;
  END CP_SYS_PEND_BUCKET1_P;

  FUNCTION CP_MGR_PEND_BUCKET1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MGR_PEND_BUCKET1;
  END CP_MGR_PEND_BUCKET1_P;

  FUNCTION CP_MGR_PEND_BUCKET2_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MGR_PEND_BUCKET2;
  END CP_MGR_PEND_BUCKET2_P;

  FUNCTION CP_MGR_PEND_BUCKET3_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MGR_PEND_BUCKET3;
  END CP_MGR_PEND_BUCKET3_P;

  FUNCTION CP_MGR_PEND_BUCKET4_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MGR_PEND_BUCKET4;
  END CP_MGR_PEND_BUCKET4_P;

  FUNCTION CP_BUCKET1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_BUCKET1;
  END CP_BUCKET1_P;

  FUNCTION CP_BUCKET2_P RETURN NUMBER IS
  BEGIN
    RETURN CP_BUCKET2;
  END CP_BUCKET2_P;

  FUNCTION CP_BUCKET3_P RETURN NUMBER IS
  BEGIN
    RETURN CP_BUCKET3;
  END CP_BUCKET3_P;

  FUNCTION CP_BUCKET4_P RETURN NUMBER IS
  BEGIN
    RETURN CP_BUCKET4;
  END CP_BUCKET4_P;

  FUNCTION CP_EMP_PENDING_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EMP_PENDING;
  END CP_EMP_PENDING_P;

  FUNCTION CP_SYS_PENDING_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SYS_PENDING;
  END CP_SYS_PENDING_P;

  FUNCTION CP_MGR_PENDING_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MGR_PENDING;
  END CP_MGR_PENDING_P;

  FUNCTION CP_APPR_PENDING_P RETURN NUMBER IS
  BEGIN
    RETURN CP_APPR_PENDING;
  END CP_APPR_PENDING_P;

  FUNCTION CP_NLS_YES_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_YES;
  END CP_NLS_YES_P;

  FUNCTION CP_NLS_NO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_NO;
  END CP_NLS_NO_P;

  FUNCTION CP_NLS_ALL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_ALL;
  END CP_NLS_ALL_P;

  FUNCTION CP_NLS_NO_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_NO_DATA_FOUND;
  END CP_NLS_NO_DATA_FOUND_P;

  FUNCTION CP_NLS_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_END_OF_REPORT;
  END CP_NLS_END_OF_REPORT_P;

  FUNCTION CP_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_COMPANY_NAME_HEADER;
  END CP_COMPANY_NAME_HEADER_P;

  FUNCTION CP_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_CHART_OF_ACCOUNTS_ID;
  END CP_CHART_OF_ACCOUNTS_ID_P;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_CURRENCY_CODE;
  END C_BASE_CURRENCY_CODE_P;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_DESCRIPTION;
  END C_BASE_DESCRIPTION_P;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_MIN_ACCT_UNIT;
  END C_BASE_MIN_ACCT_UNIT_P;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_PRECISION;
  END C_BASE_PRECISION_P;

  FUNCTION CP_NLS_UNSUBMITTED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_UNSUBMITTED;
  END CP_NLS_UNSUBMITTED_P;

  FUNCTION CP_NLS_MGR_UNAPPROVED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_MGR_UNAPPROVED;
  END CP_NLS_MGR_UNAPPROVED_P;

  FUNCTION CP_NLS_AP_UNAPPROVED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_AP_UNAPPROVED;
  END CP_NLS_AP_UNAPPROVED_P;

  FUNCTION CP_NLS_DISPUTED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_DISPUTED;
  END CP_NLS_DISPUTED_P;

  FUNCTION CP_CARD_PROGRAM_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CARD_PROGRAM_NAME;
  END CP_CARD_PROGRAM_NAME_P;

  FUNCTION CP_1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_1;
  END CP_1_P;

  FUNCTION CP_REPORT_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REPORT_TITLE;
  END CP_REPORT_TITLE_P;

  FUNCTION CP_BUCKET1_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BUCKET1_NAME;
  END CP_BUCKET1_NAME_P;

  FUNCTION CP_BUCKET2_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BUCKET2_NAME;
  END CP_BUCKET2_NAME_P;

  FUNCTION CP_BUCKET3_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BUCKET3_NAME;
  END CP_BUCKET3_NAME_P;

  FUNCTION CP_BUCKET4_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BUCKET4_NAME;
  END CP_BUCKET4_NAME_P;

  FUNCTION CP_NLS_REJECTED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_REJECTED;
  END CP_NLS_REJECTED_P;

FUNCTION Q_agingFilter RETURN BOOLEAN  IS
BEGIN
IF(P_OPERATION_TYPE = 'CC_DETAIL_REPORT' OR P_OPERATION_TYPE = 'CC_SUMMARY_REPORT' OR P_OPERATION_TYPE = 'CC_INACT_EMPL_REPORT') THEN
	RETURN(FALSE);
END IF;
END;

FUNCTION Q_TRANS_SUMMFilter RETURN BOOLEAN  IS
BEGIN
IF(P_OPERATION_TYPE = 'CC_DETAIL_REPORT' OR P_OPERATION_TYPE = 'CC_AGING_REPORT' OR P_OPERATION_TYPE = 'CC_INACT_EMPL_REPORT') THEN
	RETURN(FALSE);
END IF;
END;

FUNCTION Q_TRXNFilter RETURN BOOLEAN  IS
BEGIN
IF(P_OPERATION_TYPE = 'CC_SUMMARY_REPORT' OR P_OPERATION_TYPE = 'CC_AGING_REPORT' ) THEN
	RETURN(FALSE);
END IF;
END;
END AP_APXCCOUT_XMLP_PKG;



/
