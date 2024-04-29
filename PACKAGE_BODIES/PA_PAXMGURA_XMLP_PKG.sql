--------------------------------------------------------
--  DDL for Package Body PA_PAXMGURA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXMGURA_XMLP_PKG" AS
/* $Header: PAXMGURAB.pls 120.0.12010000.2 2008/12/12 11:20:17 dbudhwar ship $ */
 DATE1 DATE;

  DATE2 DATE;

  DATE3 DATE;

FUNCTION FINAL_BUCKET4FORMULA(EVENT_INVOICED_AMOUNT IN NUMBER,COST_WORK_AMOUNT IN NUMBER,BUCKET1 IN NUMBER,BUCKET2 IN NUMBER,BUCKET3 IN NUMBER,BUCKET4 IN NUMBER) RETURN NUMBER IS
BEGIN
  RETURN  CALC_BUCKET4(EVENT_INVOICED_AMOUNT,COST_WORK_AMOUNT,BUCKET1,BUCKET2,BUCKET3,BUCKET4);
END;
FUNCTION FINAL_BUCKET3FORMULA(EVENT_INVOICED_AMOUNT IN NUMBER,COST_WORK_AMOUNT IN NUMBER,BUCKET1 IN NUMBER,BUCKET2 IN NUMBER,BUCKET3 IN NUMBER,BUCKET4 IN NUMBER) RETURN NUMBER IS
BEGIN
  RETURN  CALC_BUCKET3(EVENT_INVOICED_AMOUNT,COST_WORK_AMOUNT,BUCKET1,BUCKET2,BUCKET3,BUCKET4);
END;
FUNCTION FINAL_BUCKET2FORMULA(EVENT_INVOICED_AMOUNT IN NUMBER,COST_WORK_AMOUNT IN NUMBER,BUCKET1 IN NUMBER,BUCKET2 IN NUMBER,BUCKET3 IN NUMBER,BUCKET4 IN NUMBER) RETURN NUMBER IS
BEGIN
  RETURN  CALC_BUCKET2(EVENT_INVOICED_AMOUNT,COST_WORK_AMOUNT,BUCKET1,BUCKET2,BUCKET3,BUCKET4);
END;
FUNCTION FINAL_BUCKET1FORMULA(EVENT_INVOICED_AMOUNT IN NUMBER,COST_WORK_AMOUNT IN NUMBER,BUCKET1 IN NUMBER,BUCKET2 IN NUMBER,BUCKET3 IN NUMBER,BUCKET4 IN NUMBER,INVOICE_REDUCTION IN NUMBER,RETENTION IN NUMBER) RETURN NUMBER IS
BEGIN
  RETURN  CALC_BUCKET1(EVENT_INVOICED_AMOUNT,COST_WORK_AMOUNT,BUCKET1,BUCKET2,BUCKET3,BUCKET4,INVOICE_REDUCTION,RETENTION);
END;
FUNCTION TOTALFORMULA(EVENT_INVOICED_AMOUNT IN NUMBER,COST_WORK_AMOUNT IN NUMBER,BUCKET1 IN NUMBER,BUCKET2 IN NUMBER,BUCKET3 IN NUMBER,BUCKET4 IN NUMBER,INVOICE_REDUCTION IN NUMBER,RETENTION IN NUMBER) RETURN NUMBER IS
BEGIN
  RETURN  CALC_TOTAL_BUCKETS(EVENT_INVOICED_AMOUNT,COST_WORK_AMOUNT,BUCKET1,BUCKET2,BUCKET3,BUCKET4,INVOICE_REDUCTION,RETENTION);
END;

FUNCTION BEFOREPFORM RETURN BOOLEAN IS
    XX NUMBER;
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    ROLLBACK;
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    NDF VARCHAR2(80);
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    P_ORG_ID := ORG_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.USER_EXIT('FND GETPROFILE
                  NAME="PA_RULE_BASED_OPTIMIZER"
                  FIELD=":p_rule_optimizer"
                  PRINT_ERROR="N"')*/NULL;
    P_DEBUG_MODE := FND_PROFILE.VALUE('PA_DEBUG_MODE');

/* Added for bug 7115658 */
IF proj is null THEN
IF from_project_number is null then
  begin
	select min(p.segment1) into from_project_number
	from pa_projects_all p, pa_project_types_all pt
	where p.project_type = pt.project_type
	and pt.project_type_class_code = 'CONTRACT';
  exception
	when no_data_found then
		null;
	when others then
		/*srw.message(2,'From Project Number ' || sqlerrm)*/ null;
    raise_application_error(-20101,null);/*srw.program_abort;*/null;
  end;
END IF;


IF to_project_number is null then
  begin
	select max(p.segment1) into to_project_number
	from pa_projects_all p, pa_project_types_all pt
	where p.project_type = pt.project_type
	and pt.project_type_class_code = 'CONTRACT';
  exception
	when no_data_found then
		null;
	when others then
	 /*	srw.message(2,'to Project Number ' || sqlerrm) */ null;
    raise_application_error(-20101,null);/*srw.program_abort;*/null;
  end;
END IF;
END IF;
/* End of code for bug 7115658 */


    SELECT_DATES;
    POPULATE;
    IF NOT GET_COMPANY_NAME THEN
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    GET_COLUMN_HEADINGS;
    BEGIN
      SELECT
        SUBSTR(MEANING,5,13)
      INTO NDF
      FROM
        PA_LOOKUPS
      WHERE LOOKUP_CODE = 'NO_DATA_FOUND'
        AND LOOKUP_TYPE = 'MESSAGE';
      C_NO_DATA_FOUND := NDF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        C_NO_DATA_FOUND := 'No Data Found';
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_CURRENCY_CODEFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (PA_MULTI_CURRENCY.GET_ACCT_CURRENCY_CODE);
  END CF_CURRENCY_CODEFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

/*  PROCEDURE UPDATE_EIS IS
    DATE1 VARCHAR2(9);
    DATE2 VARCHAR2(9);
    DATE3 VARCHAR2(9);
  BEGIN
    SELECT
      ( NVL(DATE_FROM
         ,SYSDATE) - BUCKET_SIZE1 ),
      ( NVL(DATE_FROM
         ,SYSDATE) - ( BUCKET_SIZE2 + BUCKET_SIZE1 ) ),
      ( NVL(DATE_FROM
         ,SYSDATE) - ( BUCKET_SIZE3 + BUCKET_SIZE2 + BUCKET_SIZE1 ) )
    INTO DATE1,DATE2,DATE3
    FROM
      SYS.DUAL;
    UPDATE
      PA_UNBILLED_REC_REPORTING TU
    SET
      (EI_BUCKET1,EI_BUCKET2,EI_BUCKET3,EI_BUCKET4) = (SELECT
        NVL(TU.EI_BUCKET1
           ,0) + NVL(SUM(DECODE(LEAST(DECODE(AGE
                                   ,'GL_DATE'
                                   ,PDI1.GL_DATE
                                   ,PDI1.PA_DATE)
                            ,DATE1)
                      ,DATE1
                      ,DECODE(PDI1.RELEASED_DATE
                            ,NULL
                            ,PDII.PROJFUNC_BILL_AMOUNT
                            ,0)
                      ,0))
           ,0),
        NVL(TU.EI_BUCKET2
           ,0) + NVL(SUM(DECODE(LEAST(DECODE(AGE
                                   ,'GL_DATE'
                                   ,PDI1.GL_DATE
                                   ,PDI1.PA_DATE)
                            ,TO_DATE(DATE1
                                   ,'YYYY/MM/DD') - 1)
                      ,DECODE(AGE
                            ,'GL_DATE'
                            ,PDI1.GL_DATE
                            ,PDI1.PA_DATE)
                      ,DECODE(LEAST(DECODE(AGE
                                         ,'GL_DATE'
                                         ,PDI1.GL_DATE
                                         ,PDI1.PA_DATE)
                                  ,DATE2)
                            ,DATE2
                            ,DECODE(PDI1.RELEASED_DATE
                                  ,NULL
                                  ,PDII.PROJFUNC_BILL_AMOUNT
                                  ,0)
                            ,0)
                      ,0))
           ,0),
        NVL(TU.EI_BUCKET3
           ,0) + NVL(SUM(DECODE(LEAST(DECODE(AGE
                                   ,'GL_DATE'
                                   ,PDI1.GL_DATE
                                   ,PDI1.PA_DATE)
                            ,TO_DATE(DATE2
                                   ,'YYYY/MM/DD') - 1)
                      ,DECODE(AGE
                            ,'GL_DATE'
                            ,PDI1.GL_DATE
                            ,PDI1.PA_DATE)
                      ,DECODE(LEAST(DECODE(AGE
                                         ,'GL_DATE'
                                         ,PDI.GL_DATE
                                         ,PDI1.PA_DATE)
                                  ,DATE3)
                            ,DATE3
                            ,DECODE(PDI1.RELEASED_DATE
                                  ,NULL
                                  ,PDII.PROJFUNC_BILL_AMOUNT
                                  ,0)
                            ,0)
                      ,0))
           ,0),
        NVL(TU.EI_BUCKET4
           ,0) + NVL(SUM(DECODE(LEAST(DECODE(AGE
                                   ,'GL_DATE'
                                   ,PDI1.GL_DATE
                                   ,PDI1.PA_DATE)
                            ,TO_DATE(DATE3
                                   ,'YYYY/MM/DD') - 1)
                      ,DECODE(AGE
                            ,'GL_DATE'
                            ,PDI1.GL_DATE
                            ,PDI1.PA_DATE)
                      ,DECODE(PDI1.RELEASED_DATE
                            ,NULL
                            ,PDII.PROJFUNC_BILL_AMOUNT
                            ,0)
                      ,0))
           ,0)
      FROM
        PA_PROJECTS P,
        PA_PROJECT_PLAYERS PL,
        PA_DRAFT_INVOICES PDI,
        PA_DRAFT_INVOICES PDI1,
        PA_DRAFT_INVOICE_ITEMS PDII
      WHERE P.CARRYING_OUT_ORGANIZATION_ID between NVL(NULL
         ,0)
        AND NVL(NULL
         ,999999999999999)
        AND P.PROJECT_ID between NVL(PROJ
         ,0)
        AND NVL(PROJ
         ,999999999999999)
        AND PL.PROJECT_ROLE_TYPE = 'PROJECT MANAGER'
        AND NVL(NULL
         ,SYSDATE) between PL.START_DATE_ACTIVE
        AND NVL(PL.END_DATE_ACTIVE
         ,NVL(NULL
            ,SYSDATE + 1))
        AND PL.PERSON_ID between NVL(NULL
         ,0)
        AND NVL(NULL
         ,999999999999999)
        AND P.PROJECT_ID = PL.PROJECT_ID
        AND PDI.PROJECT_ID = P.PROJECT_ID
        AND PDI1.PROJECT_ID = PDI.PROJECT_ID
        AND PDI1.DRAFT_INVOICE_NUM_CREDITED is not null
        AND PDI1.DRAFT_INVOICE_NUM_CREDITED = PDI.DRAFT_INVOICE_NUM
        AND PDII.PROJECT_ID = PDI1.PROJECT_ID
        AND PDII.DRAFT_INVOICE_NUM = PDI1.DRAFT_INVOICE_NUM
        AND PDII.DRAFT_INVOICE_NUM = PDI1.DRAFT_INVOICE_NUM
        AND DECODE(AGE
            ,'GL_DATE'
            ,PDI.GL_DATE
            ,PDI.PA_DATE) <= NVL(DATE_FROM
         ,SYSDATE)
        AND TU.PROJECT_ID = P.PROJECT_ID);
  END UPDATE_EIS; */

  FUNCTION G_PROJECTGROUPFILTER(FINAL_BUCKET1 IN NUMBER
                               ,FINAL_BUCKET2 IN NUMBER
                               ,FINAL_BUCKET3 IN NUMBER
                               ,FINAL_BUCKET4 IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    IF (FINAL_BUCKET1 = 0 AND FINAL_BUCKET2 = 0 AND FINAL_BUCKET3 = 0 AND FINAL_BUCKET4 = 0) THEN
      RETURN (FALSE);
    ELSE
      RETURN (TRUE);
    END IF;
  END G_PROJECTGROUPFILTER;

  FUNCTION C_COLHEAD1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COLHEAD1;
  END C_COLHEAD1_P;

  FUNCTION C_COLHEAD2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COLHEAD2;
  END C_COLHEAD2_P;

  FUNCTION C_COLHEAD3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COLHEAD3;
  END C_COLHEAD3_P;

  FUNCTION C_COLHEAD4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COLHEAD4;
  END C_COLHEAD4_P;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;

  FUNCTION C_NO_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NO_DATA_FOUND;
  END C_NO_DATA_FOUND_P;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN IS
    L_NAME HR_ORGANIZATION_UNITS.NAME%TYPE;
  BEGIN
    SELECT
      GL.NAME
    INTO L_NAME
    FROM
      GL_SETS_OF_BOOKS GL,
      PA_IMPLEMENTATIONS PI
    WHERE GL.SET_OF_BOOKS_ID = PI.SET_OF_BOOKS_ID;
    C_COMPANY_NAME_HEADER := L_NAME;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COMPANY_NAME;

  PROCEDURE GET_COLUMN_HEADINGS IS
    COLHEAD1 VARCHAR2(15);
    COLHEAD2 VARCHAR2(15);
    COLHEAD3 VARCHAR2(15);
    COLHEAD4 VARCHAR2(15);
  BEGIN
    SELECT
      LPAD('0-' || TO_CHAR(BUCKET_SIZE1) || ' days'
          ,14),
      LPAD(TO_CHAR(BUCKET_SIZE1 + 1) || '-' || TO_CHAR(BUCKET_SIZE1 + BUCKET_SIZE2) || ' days'
          ,14),
      LPAD(TO_CHAR(BUCKET_SIZE1 + BUCKET_SIZE2 + 1) || '-' || TO_CHAR(BUCKET_SIZE1 + BUCKET_SIZE2 + BUCKET_SIZE3) || ' days'
          ,14),
      LPAD(TO_CHAR(BUCKET_SIZE1 + BUCKET_SIZE2 + BUCKET_SIZE3 + 1) || '+ days'
          ,14)
    INTO COLHEAD1,COLHEAD2,COLHEAD3,COLHEAD4
    FROM
      SYS.DUAL;
    C_COLHEAD1 := COLHEAD1;
    C_COLHEAD2 := COLHEAD2;
    C_COLHEAD3 := COLHEAD3;
    C_COLHEAD4 := COLHEAD4;
  END GET_COLUMN_HEADINGS;

  PROCEDURE SELECT_DATES IS
  BEGIN
    SELECT
      ( NVL(DATE_FROM
         ,SYSDATE) - BUCKET_SIZE1 ),
      ( NVL(DATE_FROM
         ,SYSDATE) - ( BUCKET_SIZE2 + BUCKET_SIZE1 ) ),
      ( NVL(DATE_FROM
         ,SYSDATE) - ( BUCKET_SIZE3 + BUCKET_SIZE2 + BUCKET_SIZE1 ) )
    INTO DATE1,DATE2,DATE3
    FROM
      SYS.DUAL;
  END SELECT_DATES;

  PROCEDURE INSERT_EIS IS
    CURSOR C1 IS
      SELECT
        DISTINCT
        P.PROJECT_ID
      FROM
        PA_PROJECTS P,
        PA_PROJECT_PLAYERS PL
      WHERE P.CARRYING_OUT_ORGANIZATION_ID BETWEEN NVL(P_ORG_ID
         ,0)
        AND NVL(P_ORG_ID
         ,999999999999999)
        AND P.PROJECT_ID BETWEEN NVL(PROJ
         ,0)
        AND NVL(PROJ
         ,999999999999999)
        AND PL.PROJECT_ROLE_TYPE = 'PROJECT MANAGER'
        AND NVL(DATE_FROM
         ,SYSDATE) BETWEEN PL.START_DATE_ACTIVE
        AND NVL(PL.END_DATE_ACTIVE
         ,NVL(DATE_FROM
            ,SYSDATE + 1))
        AND PL.PERSON_ID BETWEEN NVL(PROJECT_MANAGER_ID
         ,0)
        AND NVL(PROJECT_MANAGER_ID
         ,999999999999999)
        AND P.PROJECT_ID = PL.PROJECT_ID;
  BEGIN
    FOR c1rec IN C1 LOOP
      INSERT INTO PA_UNBILLED_REC_REPORTING
        (PROJECT_ID
        ,EI_BUCKET1
        ,EI_BUCKET2
        ,EI_BUCKET3
        ,EI_BUCKET4)
        SELECT
          T.PROJECT_ID,
          SUM(DECODE(LEAST(DECODE(AGE
                                 ,'EXPENDITURE_ITEM_DATE'
                                 ,PAI.EXPENDITURE_ITEM_DATE
                                 ,'GL_DATE'
                                 ,PDR.GL_DATE
                                 ,PDR.PA_DATE)
                          ,DATE1)
                    ,DATE1
                    ,DECODE(PCR.PROJFUNC_BILL_AMOUNT
                          ,PCR.AMOUNT
                          ,DECODE(PDI.RELEASED_DATE
                                ,NULL
                                ,PCR.AMOUNT
                                ,0)
                          ,PCR.AMOUNT)
                    ,0)),
          SUM(DECODE(LEAST(DECODE(AGE
                                 ,'EXPENDITURE_ITEM_DATE'
                                 ,PAI.EXPENDITURE_ITEM_DATE
                                 ,'GL_DATE'
                                 ,PDR.GL_DATE
                                 ,PDR.PA_DATE)
                          ,DATE1 - 1)
                    ,DECODE(AGE
                          ,'EXPENDITURE_ITEM_DATE'
                          ,PAI.EXPENDITURE_ITEM_DATE
                          ,'GL_DATE'
                          ,PDR.GL_DATE
                          ,PDR.PA_DATE)
                    ,DECODE(LEAST(DECODE(AGE
                                       ,'EXPENDITURE_ITEM_DATE'
                                       ,PAI.EXPENDITURE_ITEM_DATE
                                       ,'GL_DATE'
                                       ,PDR.GL_DATE
                                       ,PDR.PA_DATE)
                                ,DATE2)
                          ,DATE2
                          ,DECODE(PCR.PROJFUNC_BILL_AMOUNT
                                ,PCR.AMOUNT
                                ,DECODE(PDI.RELEASED_DATE
                                      ,NULL
                                      ,PCR.AMOUNT
                                      ,0)
                                ,PCR.AMOUNT)
                          ,0)
                    ,0)),
          SUM(DECODE(LEAST(DECODE(AGE
                                 ,'EXPENDITURE_ITEM_DATE'
                                 ,PAI.EXPENDITURE_ITEM_DATE
                                 ,'GL_DATE'
                                 ,PDR.GL_DATE
                                 ,PDR.PA_DATE)
                          ,DATE2 - 1)
                    ,DECODE(AGE
                          ,'EXPENDITURE_ITEM_DATE'
                          ,PAI.EXPENDITURE_ITEM_DATE
                          ,'GL_DATE'
                          ,PDR.GL_DATE
                          ,PDR.PA_DATE)
                    ,DECODE(LEAST(DECODE(AGE
                                       ,'EXPENDITURE_ITEM_DATE'
                                       ,PAI.EXPENDITURE_ITEM_DATE
                                       ,'GL_DATE'
                                       ,PDR.GL_DATE
                                       ,PDR.PA_DATE)
                                ,DATE3)
                          ,DATE3
                          ,DECODE(PCR.PROJFUNC_BILL_AMOUNT
                                ,PCR.AMOUNT
                                ,DECODE(PDI.RELEASED_DATE
                                      ,NULL
                                      ,PCR.AMOUNT
                                      ,0)
                                ,PCR.AMOUNT)
                          ,0)
                    ,0)),
          SUM(DECODE(LEAST(DECODE(AGE
                                 ,'EXPENDITURE_ITEM_DATE'
                                 ,PAI.EXPENDITURE_ITEM_DATE
                                 ,'GL_DATE'
                                 ,PDR.GL_DATE
                                 ,PDR.PA_DATE)
                          ,DATE3 - 1)
                    ,DECODE(AGE
                          ,'EXPENDITURE_ITEM_DATE'
                          ,PAI.EXPENDITURE_ITEM_DATE
                          ,'GL_DATE'
                          ,PDR.GL_DATE
                          ,PDR.PA_DATE)
                    ,DECODE(PCR.PROJFUNC_BILL_AMOUNT
                          ,PCR.AMOUNT
                          ,DECODE(PDI.RELEASED_DATE
                                ,NULL
                                ,PCR.AMOUNT
                                ,0)
                          ,PCR.AMOUNT)
                    ,0))
        FROM
          PA_TASKS T,
          PA_EXPENDITURE_ITEMS_ALL PAI,
          PA_CUST_REV_DIST_LINES PCR,
          PA_DRAFT_INVOICES PDI,
          PA_DRAFT_REVENUES PDR
        WHERE T.PROJECT_ID = C1REC.PROJECT_ID
          AND PDR.PROJECT_ID = C1REC.PROJECT_ID
          AND T.TASK_ID = PAI.TASK_ID
          AND PAI.EXPENDITURE_ITEM_ID = PCR.EXPENDITURE_ITEM_ID
          AND PCR.PROJECT_ID = PDR.PROJECT_ID
          AND PCR.DRAFT_REVENUE_NUM = PDR.DRAFT_REVENUE_NUM
          AND PDR.RELEASED_DATE IS NOT NULL
          AND PCR.DRAFT_INVOICE_NUM = pdi.draft_invoice_num (+)
          AND PCR.PROJECT_ID = pdi.project_id (+)
          AND PCR.FUNCTION_CODE not in ( 'LRB' , 'LRL' , 'URB' , 'URL' )
          AND DECODE(AGE
              ,'EXPENDITURE_ITEM_DATE'
              ,PAI.EXPENDITURE_ITEM_DATE
              ,'GL_DATE'
              ,PDR.GL_DATE
              ,PDR.PA_DATE) <= NVL(DATE_FROM
           ,SYSDATE)
        GROUP BY
          T.PROJECT_ID;
    END LOOP;
  END INSERT_EIS;

/*  PROCEDURE INSERT_EVENTS IS
  BEGIN
    INSERT INTO PA_UNBILLED_REC_REPORTING
      (PROJECT_ID
      ,EVENT_BUCKET1
      ,EVENT_BUCKET2
      ,EVENT_BUCKET3
      ,EVENT_BUCKET4)
      SELECT
        P.PROJECT_ID,
        SUM(DECODE(LEAST(DECODE(AGE
                               ,'EXPENDITURE_ITEM_DATE'
                               ,PE.COMPLETION_DATE
                               ,'GL_DATE'
                               ,PDR.GL_DATE
                               ,PDR.PA_DATE)
                        ,DATE1)
                  ,DATE1
                  ,NVL(PCR.AMOUNT
                     ,0)
                  ,0)),
        SUM(DECODE(LEAST(DECODE(AGE
                               ,'EXPENDITURE_ITEM_DATE'
                               ,PE.COMPLETION_DATE
                               ,'GL_DATE'
                               ,PDR.GL_DATE
                               ,PDR.PA_DATE)
                        ,DATE1 - 1)
                  ,DECODE(AGE
                        ,'EXPENDITURE_ITEM_DATE'
                        ,PE.COMPLETION_DATE
                        ,'GL_DATE'
                        ,PDR.GL_DATE
                        ,PDR.PA_DATE)
                  ,DECODE(LEAST(DECODE(AGE
                                     ,'EXPENDITURE_ITEM_DATE'
                                     ,PE.COMPLETION_DATE
                                     ,'GL_DATE'
                                     ,PDR.GL_DATE
                                     ,PDR.PA_DATE)
                              ,DATE2)
                        ,DATE2
                        ,NVL(PCR.AMOUNT
                           ,0)
                        ,0)
                  ,0)),
        SUM(DECODE(LEAST(DECODE(AGE
                               ,'EXPENDITURE_ITEM_DATE'
                               ,PE.COMPLETION_DATE
                               ,'GL_DATE'
                               ,PDR.GL_DATE
                               ,PDR.PA_DATE)
                        ,DATE2 - 1)
                  ,DECODE(AGE
                        ,'EXPENDITURE_ITEM_DATE'
                        ,PE.COMPLETION_DATE
                        ,'GL_DATE'
                        ,PDR.GL_DATE
                        ,PDR.PA_DATE)
                  ,DECODE(LEAST(DECODE(AGE
                                     ,'EXPENDITURE_ITEM_DATE'
                                     ,PE.COMPLETION_DATE
                                     ,'GL_DATE'
                                     ,PDR.GL_DATE
                                     ,PDR.PA_DATE)
                              ,DATE3)
                        ,DATE3
                        ,NVL(PCR.AMOUNT
                           ,0)
                        ,0)
                  ,0)),
        SUM(DECODE(LEAST(DECODE(AGE
                               ,'EXPENDITURE_ITEM_DATE'
                               ,PE.COMPLETION_DATE
                               ,'GL_DATE'
                               ,PDR.GL_DATE
                               ,PDR.PA_DATE)
                        ,DATE3 - 1)
                  ,DECODE(AGE
                        ,'EXPENDITURE_ITEM_DATE'
                        ,PE.COMPLETION_DATE
                        ,'GL_DATE'
                        ,PDR.GL_DATE
                        ,PDR.PA_DATE)
                  ,NVL(PCR.AMOUNT
                     ,0)
                  ,0))
      FROM
        PA_PROJECTS P,
        PA_PROJECT_PLAYERS PL,
        PA_EVENTS PE,
        PA_EVENT_TYPES PET,
        PA_DRAFT_REVENUES PDR,
        PA_CUST_EVENT_REV_DIST_LINES PCR
      WHERE P.CARRYING_OUT_ORGANIZATION_ID between NVL(P_ORG_ID
         ,0)
        AND NVL(P_ORG_ID
         ,999999999999999)
        AND P.PROJECT_ID between NVL(PROJ
         ,0)
        AND NVL(PROJ
         ,999999999999999)
        AND PL.PROJECT_ROLE_TYPE = 'PROJECT MANAGER'
        AND NVL(DATE_FROM
         ,SYSDATE) between PL.START_DATE_ACTIVE
        AND NVL(PL.END_DATE_ACTIVE
         ,NVL(DATE_FROM
            ,SYSDATE + 1))
        AND PL.PERSON_ID between NVL(PROJECT_MANAGER_ID
         ,0)
        AND NVL(PROJECT_MANAGER_ID
         ,999999999999999)
        AND P.PROJECT_ID = PL.PROJECT_ID
        AND PE.REVENUE_DISTRIBUTED_FLAG || '' = 'Y'
        AND PE.PROJECT_ID = P.PROJECT_ID
        AND PCR.PROJECT_ID = PDR.PROJECT_ID
        AND PCR.DRAFT_REVENUE_NUM = PDR.DRAFT_REVENUE_NUM
        AND PDR.RELEASED_DATE IS NOT NULL
        AND NOT EXISTS (
        SELECT
          'x'
        FROM
          PA_DRAFT_INVOICES PDI
        WHERE PCR.PROJECT_ID = PDI.PROJECT_ID
          AND PCR.DRAFT_INVOICE_NUM = PDI.DRAFT_INVOICE_NUM
          AND PDI.RELEASED_DATE IS NOT NULL )
        AND PE.EVENT_TYPE = PET.EVENT_TYPE
        AND PET.EVENT_TYPE_CLASSIFICATION || '' in ( 'WRITE ON' , 'MANUAL' , 'AUTOMATIC' )
        AND PE.REVENUE_AMOUNT is not null
        AND PE.PROJECT_ID = PCR.PROJECT_ID
        AND NVL(PE.TASK_ID
         ,-1) = NVL(PCR.TASK_ID
         ,-1)
        AND PE.EVENT_NUM = PCR.EVENT_NUM
        AND not exists (
        SELECT
          'x'
        FROM
          PA_UNBILLED_REC_REPORTING T1
        WHERE T1.PROJECT_ID = P.PROJECT_ID )
        AND DECODE(AGE
            ,'EXPENDITURE_ITEM_DATE'
            ,PE.COMPLETION_DATE
            ,'GL_DATE'
            ,PDR.GL_DATE
            ,PDR.PA_DATE) <= NVL(DATE_FROM
         ,SYSDATE)
      GROUP BY
        P.PROJECT_ID;
  END INSERT_EVENTS;*/

  PROCEDURE UPDATE_EVENTS IS
  BEGIN
    UPDATE
      PA_UNBILLED_REC_REPORTING TU
    SET
      (EVENT_BUCKET1,EVENT_BUCKET2,EVENT_BUCKET3,EVENT_BUCKET4) = (SELECT
        SUM(DECODE(LEAST(DECODE(AGE
                               ,'EXPENDITURE_ITEM_DATE'
                               ,PE.COMPLETION_DATE
                               ,'GL_DATE'
                               ,PDR.GL_DATE
                               ,PDR.PA_DATE)
                        ,DATE1)
                  ,DATE1
                  ,NVL(PCR.AMOUNT
                     ,0)
                  ,0)),
        SUM(DECODE(LEAST(DECODE(AGE
                               ,'EXPENDITURE_ITEM_DATE'
                               ,PE.COMPLETION_DATE
                               ,'GL_DATE'
                               ,PDR.GL_DATE
                               ,PDR.PA_DATE)
                        ,DATE1 - 1)
                  ,DECODE(AGE
                        ,'EXPENDITURE_ITEM_DATE'
                        ,PE.COMPLETION_DATE
                        ,'GL_DATE'
                        ,PDR.GL_DATE
                        ,PDR.PA_DATE)
                  ,DECODE(LEAST(DECODE(AGE
                                     ,'EXPENDITURE_ITEM_DATE'
                                     ,PE.COMPLETION_DATE
                                     ,'GL_DATE'
                                     ,PDR.GL_DATE
                                     ,PDR.PA_DATE)
                              ,DATE2)
                        ,DATE2
                        ,NVL(PCR.AMOUNT
                           ,0)
                        ,0)
                  ,0)),
        SUM(DECODE(LEAST(DECODE(AGE
                               ,'EXPENDITURE_ITEM_DATE'
                               ,PE.COMPLETION_DATE
                               ,'GL_DATE'
                               ,PDR.GL_DATE
                               ,PDR.PA_DATE)
                        ,DATE2 - 1)
                  ,DECODE(AGE
                        ,'EXPENDITURE_ITEM_DATE'
                        ,PE.COMPLETION_DATE
                        ,'GL_DATE'
                        ,PDR.GL_DATE
                        ,PDR.PA_DATE)
                  ,DECODE(LEAST(DECODE(AGE
                                     ,'EXPENDITURE_ITEM_DATE'
                                     ,PE.COMPLETION_DATE
                                     ,'GL_DATE'
                                     ,PDR.GL_DATE
                                     ,PDR.PA_DATE)
                              ,DATE3)
                        ,DATE3
                        ,NVL(PCR.AMOUNT
                           ,0)
                        ,0)
                  ,0)),
        SUM(DECODE(LEAST(DECODE(AGE
                               ,'EXPENDITURE_ITEM_DATE'
                               ,PE.COMPLETION_DATE
                               ,'GL_DATE'
                               ,PDR.GL_DATE
                               ,PDR.PA_DATE)
                        ,DATE3 - 1)
                  ,DECODE(AGE
                        ,'EXPENDITURE_ITEM_DATE'
                        ,PE.COMPLETION_DATE
                        ,'GL_DATE'
                        ,PDR.GL_DATE
                        ,PDR.PA_DATE)
                  ,NVL(PCR.AMOUNT
                     ,0)
                  ,0))
      FROM
        PA_PROJECTS P,
        PA_PROJECT_PLAYERS PL,
        PA_EVENTS PE,
        PA_EVENT_TYPES PET,
        PA_DRAFT_REVENUES PDR,
        PA_CUST_EVENT_REV_DIST_LINES PCR
      WHERE P.CARRYING_OUT_ORGANIZATION_ID between NVL(P_ORG_ID
         ,0)
        AND NVL(P_ORG_ID
         ,999999999999999)
        AND P.PROJECT_ID between NVL(PROJ
         ,0)
        AND NVL(PROJ
         ,999999999999999)
        AND PL.PROJECT_ROLE_TYPE = 'PROJECT MANAGER'
        AND NVL(DATE_FROM
         ,SYSDATE) between PL.START_DATE_ACTIVE
        AND NVL(PL.END_DATE_ACTIVE
         ,NVL(DATE_FROM
            ,SYSDATE + 1))
        AND PL.PERSON_ID between NVL(PROJECT_MANAGER_ID
         ,0)
        AND NVL(PROJECT_MANAGER_ID
         ,999999999999999)
        AND P.PROJECT_ID = PL.PROJECT_ID
        AND PE.REVENUE_DISTRIBUTED_FLAG || '' = 'Y'
        AND PE.PROJECT_ID = P.PROJECT_ID
        AND PCR.PROJECT_ID = PDR.PROJECT_ID
        AND PCR.DRAFT_REVENUE_NUM = PDR.DRAFT_REVENUE_NUM
        AND PDR.RELEASED_DATE IS NOT NULL
        AND DECODE(AGE
            ,'EXPENDITURE_ITEM_DATE'
            ,PE.COMPLETION_DATE
            ,'GL_DATE'
            ,PDR.GL_DATE
            ,PDR.PA_DATE) <= NVL(DATE_FROM
         ,SYSDATE)
        AND NOT EXISTS (
        SELECT
          'x'
        FROM
          PA_DRAFT_INVOICES PDI
        WHERE PCR.PROJECT_ID = PDI.PROJECT_ID
          AND PCR.DRAFT_INVOICE_NUM = PDI.DRAFT_INVOICE_NUM
          AND PDI.RELEASED_DATE IS NOT NULL )
        AND PE.EVENT_TYPE = PET.EVENT_TYPE
        AND PET.EVENT_TYPE_CLASSIFICATION in ( 'WRITE ON' , 'MANUAL' , 'AUTOMATIC' , 'WRITE OFF' )
        AND PE.REVENUE_AMOUNT is not null
        AND PE.PROJECT_ID = PCR.PROJECT_ID
        AND NVL(PE.TASK_ID
         ,-1) = NVL(PCR.TASK_ID
         ,-1)
        AND PE.EVENT_NUM = PCR.EVENT_NUM
        AND P.PROJECT_ID = TU.PROJECT_ID);
  END UPDATE_EVENTS;

  PROCEDURE UPDATE_FOR_CONCESSION IS
    L_COUNT NUMBER;
  BEGIN
    SELECT
      count(*)
    INTO L_COUNT
    FROM
      DUAL
    WHERE EXISTS (
      SELECT
        1
      FROM
        PA_PROJECTS P,
        PA_PROJECT_PLAYERS PL,
        PA_DRAFT_INVOICES PDI,
        PA_DRAFT_INVOICE_ITEMS PDII
      WHERE P.CARRYING_OUT_ORGANIZATION_ID between NVL(P_ORG_ID
         ,0)
        AND NVL(P_ORG_ID
         ,999999999999999)
        AND P.PROJECT_ID between NVL(PROJ
         ,0)
        AND NVL(PROJ
         ,999999999999999)
        AND PL.PROJECT_ROLE_TYPE = 'PROJECT MANAGER'
        AND NVL(DATE_FROM
         ,SYSDATE) between PL.START_DATE_ACTIVE
        AND NVL(PL.END_DATE_ACTIVE
         ,NVL(DATE_FROM
            ,SYSDATE + 1))
        AND PL.PERSON_ID between NVL(PROJECT_MANAGER_ID
         ,0)
        AND NVL(PROJECT_MANAGER_ID
         ,999999999999999)
        AND P.PROJECT_ID = PL.PROJECT_ID
        AND PDI.PROJECT_ID = P.PROJECT_ID
        AND PDII.PROJECT_ID = PDI.PROJECT_ID
        AND PDI.DRAFT_INVOICE_NUM = PDII.DRAFT_INVOICE_NUM
        AND PDI.RELEASED_DATE is NOT NULL
        AND DECODE(AGE
            ,'EXPENDITURE_ITEM_DATE'
            ,PDI.INVOICE_DATE
            ,'GL_DATE'
            ,PDI.GL_DATE
            ,PDI.PA_DATE) <= NVL(DATE_FROM
         ,SYSDATE)
        AND PDI.CONCESSION_FLAG = 'Y'
        AND PDII.INVOICE_LINE_TYPE <> 'RETENTION' );
    IF L_COUNT = 0 THEN
      NULL;
    ELSE
      UPDATE
        PA_UNBILLED_REC_REPORTING TU
      SET
        (EVENT_BUCKET1,EVENT_BUCKET2,EVENT_BUCKET3,EVENT_BUCKET4) = (SELECT
          NVL(EVENT_BUCKET1
             ,0) + SUM(DECODE(LEAST(DECODE(AGE
                                 ,'EXPENDITURE_ITEM_DATE'
                                 ,PDI.INVOICE_DATE
                                 ,'GL_DATE'
                                 ,PDI.GL_DATE
                                 ,PDI.PA_DATE)
                          ,DATE1)
                    ,DATE1
                    ,NVL(PDII.PROJFUNC_BILL_AMOUNT
                       ,0)
                    ,0)) * - 1,
          NVL(EVENT_BUCKET2
             ,0) + SUM(DECODE(LEAST(DECODE(AGE
                                 ,'EXPENDITURE_ITEM_DATE'
                                 ,PDI.INVOICE_DATE
                                 ,'GL_DATE'
                                 ,PDI.GL_DATE
                                 ,PDI.PA_DATE)
                          ,DATE1 - 1)
                    ,DECODE(AGE
                          ,'EXPENDITURE_ITEM_DATE'
                          ,PDI.INVOICE_DATE
                          ,'GL_DATE'
                          ,PDI.GL_DATE
                          ,PDI.PA_DATE)
                    ,DECODE(LEAST(DECODE(AGE
                                       ,'EXPENDITURE_ITEM_DATE'
                                       ,PDI.INVOICE_DATE
                                       ,'GL_DATE'
                                       ,PDI.GL_DATE
                                       ,PDI.PA_DATE)
                                ,DATE2)
                          ,DATE2
                          ,NVL(PDII.PROJFUNC_BILL_AMOUNT
                             ,0)
                          ,0)
                    ,0)) * - 1,
          NVL(EVENT_BUCKET3
             ,0) + SUM(DECODE(LEAST(DECODE(AGE
                                 ,'EXPENDITURE_ITEM_DATE'
                                 ,PDI.INVOICE_DATE
                                 ,'GL_DATE'
                                 ,PDI.GL_DATE
                                 ,PDI.PA_DATE)
                          ,DATE2 - 1)
                    ,DECODE(AGE
                          ,'EXPENDITURE_ITEM_DATE'
                          ,PDI.INVOICE_DATE
                          ,'GL_DATE'
                          ,PDI.GL_DATE
                          ,PDI.PA_DATE)
                    ,DECODE(LEAST(DECODE(AGE
                                       ,'EXPENDITURE_ITEM_DATE'
                                       ,PDI.INVOICE_DATE
                                       ,'GL_DATE'
                                       ,PDI.GL_DATE
                                       ,PDI.PA_DATE)
                                ,DATE3)
                          ,DATE3
                          ,NVL(PDII.PROJFUNC_BILL_AMOUNT
                             ,0)
                          ,0)
                    ,0)) * - 1,
          NVL(EVENT_BUCKET4
             ,0) + SUM(DECODE(LEAST(DECODE(AGE
                                 ,'EXPENDITURE_ITEM_DATE'
                                 ,PDI.INVOICE_DATE
                                 ,'GL_DATE'
                                 ,PDI.GL_DATE
                                 ,PDI.PA_DATE)
                          ,DATE3 - 1)
                    ,DECODE(AGE
                          ,'EXPENDITURE_ITEM_DATE'
                          ,PDI.INVOICE_DATE
                          ,'GL_DATE'
                          ,PDI.GL_DATE
                          ,PDI.PA_DATE)
                    ,NVL(PDII.PROJFUNC_BILL_AMOUNT
                       ,0)
                    ,0)) * - 1
        FROM
          PA_PROJECTS P,
          PA_PROJECT_PLAYERS PL,
          PA_DRAFT_INVOICES PDI,
          PA_DRAFT_INVOICE_ITEMS PDII
        WHERE P.CARRYING_OUT_ORGANIZATION_ID between NVL(P_ORG_ID
           ,0)
          AND NVL(P_ORG_ID
           ,999999999999999)
          AND P.PROJECT_ID between NVL(PROJ
           ,0)
          AND NVL(PROJ
           ,999999999999999)
          AND PL.PROJECT_ROLE_TYPE = 'PROJECT MANAGER'
          AND NVL(DATE_FROM
           ,SYSDATE) between PL.START_DATE_ACTIVE
          AND NVL(PL.END_DATE_ACTIVE
           ,NVL(DATE_FROM
              ,SYSDATE + 1))
          AND PL.PERSON_ID between NVL(PROJECT_MANAGER_ID
           ,0)
          AND NVL(PROJECT_MANAGER_ID
           ,999999999999999)
          AND P.PROJECT_ID = PL.PROJECT_ID
          AND PDI.PROJECT_ID = P.PROJECT_ID
          AND PDII.PROJECT_ID = PDI.PROJECT_ID
          AND PDI.DRAFT_INVOICE_NUM = PDII.DRAFT_INVOICE_NUM
          AND PDI.RELEASED_DATE is NOT NULL
          AND DECODE(AGE
              ,'EXPENDITURE_ITEM_DATE'
              ,PDI.INVOICE_DATE
              ,'GL_DATE'
              ,PDI.GL_DATE
              ,PDI.PA_DATE) <= NVL(DATE_FROM
           ,SYSDATE)
          AND PDI.CONCESSION_FLAG = 'Y'
          AND PDII.INVOICE_LINE_TYPE <> 'RETENTION'
          AND P.PROJECT_ID = TU.PROJECT_ID);
    END IF;
  END UPDATE_FOR_CONCESSION;

  PROCEDURE UPDATE_INVOICE_EVENTS IS
  BEGIN
    UPDATE
      PA_UNBILLED_REC_REPORTING TU
    SET
      EVENT_INV_AMOUNT = (SELECT
        SUM(TO_NUMBER(DECODE(PET.EVENT_TYPE_CLASSIFICATION
                            ,'WRITE OFF'
                            ,TO_CHAR(NVL(PE.REVENUE_AMOUNT
                                       ,0))
                            ,TO_CHAR(NVL(PDII.PROJFUNC_BILL_AMOUNT
                                       ,0)))))
      FROM
        PA_PROJECTS P,
        PA_PROJECT_PLAYERS PL,
        PA_EVENT_TYPES PET,
        PA_EVENTS PE,
        PA_DRAFT_INVOICES PDI,
        PA_DRAFT_INVOICE_ITEMS PDII
      WHERE PDI.RELEASED_DATE IS NOT NULL
        AND PDI.PROJECT_ID = PDII.PROJECT_ID
        AND PDI.PROJECT_ID = P.PROJECT_ID
        AND PDI.DRAFT_INVOICE_NUM = PDII.DRAFT_INVOICE_NUM
        AND PDII.PROJECT_ID = PE.PROJECT_ID
        AND PDI.CANCELED_FLAG is null
        AND PDI.CANCEL_CREDIT_MEMO_FLAG is null
        AND NVL(PDII.EVENT_TASK_ID
         ,-1) = NVL(PE.TASK_ID
         ,-1)
        AND PDII.EVENT_NUM = PE.EVENT_NUM
        AND P.CARRYING_OUT_ORGANIZATION_ID between NVL(P_ORG_ID
         ,0)
        AND NVL(P_ORG_ID
         ,999999999999999)
        AND P.PROJECT_ID between NVL(PROJ
         ,0)
        AND NVL(PROJ
         ,999999999999999)
        AND PL.PROJECT_ROLE_TYPE = 'PROJECT MANAGER'
        AND NVL(DATE_FROM
         ,SYSDATE) between PL.START_DATE_ACTIVE
        AND NVL(PL.END_DATE_ACTIVE
         ,NVL(DATE_FROM
            ,SYSDATE + 1))
        AND PL.PERSON_ID between NVL(PROJECT_MANAGER_ID
         ,0)
        AND NVL(PROJECT_MANAGER_ID
         ,999999999999999)
        AND P.PROJECT_ID = PL.PROJECT_ID
        AND PE.EVENT_TYPE = PET.EVENT_TYPE
        AND PET.EVENT_TYPE_CLASSIFICATION || '' in ( 'WRITE OFF' , 'SCHEDULED PAYMENTS' , 'MANUAL' , 'DEFERRED REVENUE' , 'AUTOMATIC' )
        AND P.PROJECT_ID = PE.PROJECT_ID
        AND ( ( PET.EVENT_TYPE_CLASSIFICATION || '' in ( 'SCHEDULED PAYMENTS' , 'MANUAL' , 'DEFERRED REVENUE' , 'AUTOMATIC' )
        AND EXISTS (
        SELECT
          'event accepted'
        FROM
          PA_DRAFT_INVOICES PDI,
          PA_DRAFT_INVOICE_ITEMS PDII
        WHERE PDI.RELEASED_DATE IS NOT NULL
          AND PDI.PROJECT_ID = PDII.PROJECT_ID
          AND PDI.PROJECT_ID = P.PROJECT_ID
          AND PDI.DRAFT_INVOICE_NUM = PDII.DRAFT_INVOICE_NUM
          AND PDII.PROJECT_ID = PE.PROJECT_ID
          AND PDI.CANCELED_FLAG is null
          AND PDI.CANCEL_CREDIT_MEMO_FLAG is null
          AND NVL(PDII.EVENT_TASK_ID
           ,-1) = NVL(PE.TASK_ID
           ,-1)
          AND PDII.EVENT_NUM = PE.EVENT_NUM ) )
      OR ( PET.EVENT_TYPE_CLASSIFICATION || '' = 'WRITE OFF' )
        AND EXISTS (
        SELECT
          'event accepted'
        FROM
          PA_DRAFT_REVENUES PDR,
          PA_DRAFT_INVOICES PDI,
          PA_CUST_EVENT_REV_DIST_LINES PCR
        WHERE PDR.RELEASED_DATE IS NOT NULL
          AND PDR.PROJECT_ID = PCR.PROJECT_ID
          AND PCR.DRAFT_INVOICE_NUM = pdi.draft_invoice_num (+)
          AND PCR.PROJECT_ID = pdi.project_id (+)
          AND DECODE(PDI.RELEASED_DATE
              ,NULL
              ,1
              ,0) = 1
          AND PDR.PROJECT_ID = P.PROJECT_ID
          AND PDR.DRAFT_REVENUE_NUM = PCR.DRAFT_REVENUE_NUM
          AND PCR.PROJECT_ID = PE.PROJECT_ID
          AND NVL(PCR.TASK_ID
           ,-1) = NVL(PE.TASK_ID
           ,-1)
          AND PCR.EVENT_NUM = PE.EVENT_NUM ) )
        AND P.PROJECT_ID = TU.PROJECT_ID
        AND PE.COMPLETION_DATE <= NVL(DATE_FROM
         ,SYSDATE));
  END UPDATE_INVOICE_EVENTS;

  PROCEDURE UPDATE_INVOICE_REDUCTION IS
  BEGIN
    UPDATE
      PA_UNBILLED_REC_REPORTING TU
    SET
      COST_WORK_AMOUNT = (SELECT
        SUM(PCR.PROJFUNC_BILL_AMOUNT)
      FROM
        PA_PROJECTS P,
        PA_PROJECT_PLAYERS PL,
        PA_CUST_REV_DIST_LINES PCR,
        PA_DRAFT_INVOICES PDI
      WHERE P.CARRYING_OUT_ORGANIZATION_ID between NVL(P_ORG_ID
         ,0)
        AND NVL(P_ORG_ID
         ,999999999999999)
        AND P.PROJECT_ID between NVL(PROJ
         ,0)
        AND NVL(PROJ
         ,999999999999999)
        AND PL.PROJECT_ROLE_TYPE = 'PROJECT MANAGER'
        AND NVL(DATE_FROM
         ,SYSDATE) between PL.START_DATE_ACTIVE
        AND NVL(PL.END_DATE_ACTIVE
         ,NVL(DATE_FROM
            ,SYSDATE + 1))
        AND PL.PERSON_ID between NVL(PROJECT_MANAGER_ID
         ,0)
        AND NVL(PROJECT_MANAGER_ID
         ,999999999999999)
        AND P.PROJECT_ID = PL.PROJECT_ID
        AND P.PROJECT_ID = PDI.PROJECT_ID
        AND PCR.PROJECT_ID = PDI.PROJECT_ID
        AND PCR.DRAFT_INVOICE_NUM = PDI.DRAFT_INVOICE_NUM
        AND PDI.RELEASED_DATE IS NOT NULL
        AND PCR.PROJFUNC_BILL_AMOUNT <> PCR.AMOUNT
        AND P.PROJECT_ID = TU.PROJECT_ID);
  END UPDATE_INVOICE_REDUCTION;

  PROCEDURE UPDATE_RETENTION IS
  BEGIN
    UPDATE
      PA_UNBILLED_REC_REPORTING TU
    SET
      INVOICE_REDUCTION = (SELECT
        SUM(PE.PROJFUNC_BILL_AMOUNT)
      FROM
        PA_PROJECTS P,
        PA_PROJECT_PLAYERS PL,
        PA_EVENT_TYPES PET,
        PA_EVENTS PE
      WHERE P.CARRYING_OUT_ORGANIZATION_ID between NVL(P_ORG_ID
         ,0)
        AND NVL(P_ORG_ID
         ,999999999999999)
        AND P.PROJECT_ID between NVL(PROJ
         ,0)
        AND NVL(PROJ
         ,999999999999999)
        AND PL.PROJECT_ROLE_TYPE = 'PROJECT MANAGER'
        AND NVL(DATE_FROM
         ,SYSDATE) between PL.START_DATE_ACTIVE
        AND NVL(PL.END_DATE_ACTIVE
         ,NVL(DATE_FROM
            ,SYSDATE + 1))
        AND PL.PERSON_ID between NVL(PROJECT_MANAGER_ID
         ,0)
        AND NVL(PROJECT_MANAGER_ID
         ,999999999999999)
        AND P.PROJECT_ID = PL.PROJECT_ID
        AND P.PROJECT_ID = PE.PROJECT_ID
        AND PE.EVENT_TYPE = PET.EVENT_TYPE
        AND PET.EVENT_TYPE_CLASSIFICATION || '' = 'INVOICE REDUCTION'
        AND ( PE.PROJECT_ID , NVL(PE.TASK_ID
         ,-1) , PE.EVENT_NUM ) in (
        SELECT
          PDII.PROJECT_ID,
          NVL(PDII.EVENT_TASK_ID
             ,-1),
          PDII.EVENT_NUM
        FROM
          PA_DRAFT_INVOICES PDI,
          PA_DRAFT_INVOICE_ITEMS PDII
        WHERE PDI.RELEASED_DATE IS NOT NULL
          AND PDI.PROJECT_ID = PDII.PROJECT_ID
          AND PDI.PROJECT_ID = P.PROJECT_ID
          AND PDI.CANCELED_FLAG is null
          AND PDI.CANCEL_CREDIT_MEMO_FLAG is null
          AND PDI.DRAFT_INVOICE_NUM = PDII.DRAFT_INVOICE_NUM )
        AND P.PROJECT_ID = TU.PROJECT_ID
        AND PE.COMPLETION_DATE <= NVL(DATE_FROM
         ,SYSDATE));
  END UPDATE_RETENTION;

  FUNCTION CALC_BUCKET1(EVENT_INVOICED_AMOUNT IN NUMBER,COST_WORK_AMOUNT IN NUMBER,BUCKET1 IN NUMBER,BUCKET2 IN NUMBER,BUCKET3 IN NUMBER,BUCKET4 IN NUMBER,INVOICE_REDUCTION IN NUMBER,RETENTION IN NUMBER) RETURN NUMBER IS
    SUB_AMOUNT NUMBER := EVENT_INVOICED_AMOUNT + COST_WORK_AMOUNT;
    TEMP_BUCKET1 NUMBER;
    FINAL_BUCKET1 NUMBER;
  BEGIN
    SELECT
      BUCKET1 - DECODE(SIGN(DECODE(SIGN(DECODE(SIGN(SUB_AMOUNT - BUCKET4)
                                    ,-1
                                    ,0
                                    ,SUB_AMOUNT - BUCKET4) - BUCKET3)
                        ,-1
                        ,0
                        ,DECODE(SIGN(SUB_AMOUNT - BUCKET4)
                              ,-1
                              ,0
                              ,SUB_AMOUNT - BUCKET4) - BUCKET3) - BUCKET2)
            ,-1
            ,0
            ,DECODE(SIGN(DECODE(SIGN(SUB_AMOUNT - BUCKET4)
                              ,-1
                              ,0
                              ,SUB_AMOUNT - BUCKET4) - BUCKET3)
                  ,-1
                  ,0
                  ,DECODE(SIGN(SUB_AMOUNT - BUCKET4)
                        ,-1
                        ,0
                        ,SUB_AMOUNT - BUCKET4) - BUCKET3) - BUCKET2)
    INTO TEMP_BUCKET1
    FROM
      SYS.DUAL;
    FINAL_BUCKET1 := TEMP_BUCKET1 + INVOICE_REDUCTION + RETENTION;
    RETURN FINAL_BUCKET1;
  END CALC_BUCKET1;

  FUNCTION CALC_BUCKET2(EVENT_INVOICED_AMOUNT IN NUMBER,COST_WORK_AMOUNT IN NUMBER,BUCKET1 IN NUMBER,BUCKET2 IN NUMBER,BUCKET3 IN NUMBER,BUCKET4 IN NUMBER) RETURN NUMBER IS
  SUB_AMOUNT NUMBER := EVENT_INVOICED_AMOUNT + COST_WORK_AMOUNT;
    FINAL_BUCKET2 NUMBER;
  BEGIN
    SELECT
      DECODE(SIGN(BUCKET2 - DECODE(SIGN(DECODE(SIGN(SUB_AMOUNT - BUCKET4)
                                    ,-1
                                    ,0
                                    ,SUB_AMOUNT - BUCKET4) - BUCKET3)
                        ,-1
                        ,0
                        ,DECODE(SIGN(SUB_AMOUNT - BUCKET4)
                              ,-1
                              ,0
                              ,SUB_AMOUNT - BUCKET4) - BUCKET3))
            ,-1
            ,0
            ,BUCKET2 - DECODE(SIGN(DECODE(SIGN(SUB_AMOUNT - BUCKET4)
                              ,-1
                              ,0
                              ,SUB_AMOUNT - BUCKET4) - BUCKET3)
                  ,-1
                  ,0
                  ,DECODE(SIGN(SUB_AMOUNT - BUCKET4)
                        ,-1
                        ,0
                        ,SUB_AMOUNT - BUCKET4) - BUCKET3))
    INTO FINAL_BUCKET2
    FROM
      SYS.DUAL;
    RETURN FINAL_BUCKET2;
  END CALC_BUCKET2;

  FUNCTION CALC_BUCKET3(EVENT_INVOICED_AMOUNT IN NUMBER,COST_WORK_AMOUNT IN NUMBER,BUCKET1 IN NUMBER,BUCKET2 IN NUMBER,BUCKET3 IN NUMBER,BUCKET4 IN NUMBER) RETURN NUMBER IS
  SUB_AMOUNT NUMBER := EVENT_INVOICED_AMOUNT + COST_WORK_AMOUNT;
    FINAL_BUCKET3 NUMBER;
  BEGIN
    SELECT
      DECODE(SIGN(BUCKET3 - DECODE(SIGN(SUB_AMOUNT - BUCKET4)
                        ,-1
                        ,0
                        ,SUB_AMOUNT - BUCKET4))
            ,-1
            ,0
            ,BUCKET3 - DECODE(SIGN(SUB_AMOUNT - BUCKET4)
                  ,-1
                  ,0
                  ,SUB_AMOUNT - BUCKET4))
    INTO FINAL_BUCKET3
    FROM
      DUAL;
    RETURN FINAL_BUCKET3;
  END CALC_BUCKET3;

  FUNCTION CALC_BUCKET4(EVENT_INVOICED_AMOUNT IN NUMBER,COST_WORK_AMOUNT IN NUMBER,BUCKET1 IN NUMBER,BUCKET2 IN NUMBER,BUCKET3 IN NUMBER,BUCKET4 IN NUMBER) RETURN NUMBER IS
  SUB_AMOUNT NUMBER := EVENT_INVOICED_AMOUNT + COST_WORK_AMOUNT;
    FINAL_BUCKET4 NUMBER;
  BEGIN
    SELECT
      DECODE(SIGN(BUCKET4 - SUB_AMOUNT)
            ,-1
            ,0
            ,BUCKET4 - SUB_AMOUNT)
    INTO FINAL_BUCKET4
    FROM
      DUAL;
    RETURN FINAL_BUCKET4;
  END CALC_BUCKET4;

  FUNCTION CALC_TOTAL_BUCKETS(EVENT_INVOICED_AMOUNT IN NUMBER,COST_WORK_AMOUNT IN NUMBER,BUCKET1 IN NUMBER,BUCKET2 IN NUMBER,BUCKET3 IN NUMBER,BUCKET4 IN NUMBER,INVOICE_REDUCTION IN NUMBER,RETENTION IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN CALC_BUCKET1(EVENT_INVOICED_AMOUNT,COST_WORK_AMOUNT,BUCKET1,BUCKET2,BUCKET3,BUCKET4,INVOICE_REDUCTION,RETENTION) +
    CALC_BUCKET2(EVENT_INVOICED_AMOUNT,COST_WORK_AMOUNT,BUCKET1,BUCKET2,BUCKET3,BUCKET4) +
    CALC_BUCKET3(EVENT_INVOICED_AMOUNT,COST_WORK_AMOUNT,BUCKET1,BUCKET2,BUCKET3,BUCKET4) + CALC_BUCKET4(EVENT_INVOICED_AMOUNT,COST_WORK_AMOUNT,BUCKET1,BUCKET2,BUCKET3,BUCKET4);
  END CALC_TOTAL_BUCKETS;

  PROCEDURE INIT_PA_UNBILLED_REC_REPORTING IS
    CURSOR C IS
      SELECT
        PROJECT_ID
      FROM
        PA_PROJECTS
      WHERE PROJECT_ID between NVL(PROJ
         ,0)
        AND NVL(PROJ
         ,999999999999999);
  BEGIN
    INSERT INTO PA_UNBILLED_REC_REPORTING
      (PROJECT_ID)
      SELECT
        P.PROJECT_ID
      FROM
        PA_PROJECTS P
      WHERE P.PROJECT_ID between NVL(PROJ
         ,0)
        AND NVL(PROJ
         ,999999999999999)
        AND not exists (
        SELECT
          'xyz'
        FROM
          PA_UNBILLED_REC_REPORTING TU
        WHERE TU.PROJECT_ID = P.PROJECT_ID );
  END INIT_PA_UNBILLED_REC_REPORTING;

  PROCEDURE POPULATE IS
  BEGIN
    SELECT_DATES;
    INSERT_EIS;
    INIT_PA_UNBILLED_REC_REPORTING;
    UPDATE_EVENTS;
    UPDATE_FOR_CONCESSION;
    UPDATE_INVOICE_EVENTS;
    UPDATE_INVOICE_REDUCTION;
    UPDATE_RETENTION;
  END POPULATE;
END PA_PAXMGURA_XMLP_PKG ;



/
