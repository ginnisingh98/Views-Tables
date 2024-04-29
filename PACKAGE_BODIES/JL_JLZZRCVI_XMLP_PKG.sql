--------------------------------------------------------
--  DDL for Package Body JL_JLZZRCVI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLZZRCVI_XMLP_PKG" AS
/* $Header: JLZZRCVIB.pls 120.1 2007/12/25 16:55:08 dwkrishn noship $ */
  FUNCTION REPORT_NAMEFORMULA(COMPANY_NAME IN VARCHAR2) RETURN VARCHAR2 IS
    L_REPORT_NAME VARCHAR2(240);
  BEGIN
    RP_COMPANY_NAME := COMPANY_NAME;
    SELECT
      CP.USER_CONCURRENT_PROGRAM_NAME
    INTO L_REPORT_NAME
    FROM
      FND_CONCURRENT_PROGRAMS_VL CP,
      FND_CONCURRENT_REQUESTS CR
    WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
      AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
      AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
      L_REPORT_NAME := substr(L_REPORT_NAME,1,instr(L_REPORT_NAME,' (XML)'));
    RP_REPORT_NAME := L_REPORT_NAME;
    RETURN (L_REPORT_NAME);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RP_REPORT_NAME := NULL;
      RETURN (NULL);
  END REPORT_NAMEFORMULA;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.MESSAGE(999
               ,'Start of Copy and Void Program')*/NULL;
    DECLARE
      CURSOR C_MASTER_TRX(X_COUNTRY_CODE IN VARCHAR2) IS
        SELECT
          RP.CUSTOMER_TRX_ID,
          RP.TRX_DATE,
          RP.TERM_DUE_DATE,
          RP.GD_GL_DATE,
          RP.BATCH_SOURCE_ID,
          RP.CUST_TRX_TYPE_ID,
          RP.ACTIVITY_FLAG,
          RP.POSTED_FLAG,
          RP.CTT_CLASS,
          RP.COMPLETE_FLAG,
          RP.GLOBAL_ATTRIBUTE_CATEGORY,
          RP.GLOBAL_ATTRIBUTE20,
          RP.DOC_SEQUENCE_VALUE DOC_SEQ_NUM
        FROM
          RA_CUSTOMER_TRX_PARTIAL_V RP
        WHERE RP.BATCH_SOURCE_ID = P_IN_BATCH_SOURCE_ID
          AND RP.CUST_TRX_TYPE_ID = NVL(P_IN_CUST_TRX_TYPE_ID
           ,RP.CUST_TRX_TYPE_ID)
          AND ( ( P_IN_NUMBER_TYPE = 'DOC_NUM'
          AND RP.DOC_SEQUENCE_VALUE between P_IN_NUMBER_LOW
          AND P_IN_NUMBER_HIGH )
        OR ( P_IN_NUMBER_TYPE = 'TRX_NUM'
          AND RP.TRX_NUMBER between P_IN_NUMBER_LOW
          AND P_IN_NUMBER_HIGH ) )
          AND RP.GLOBAL_ATTRIBUTE_CATEGORY = DECODE(X_COUNTRY_CODE
              ,'CL'
              ,'JL.CL.ARXTWMAI.TGW_HEADER'
              ,'AR'
              ,'JL.AR.ARXTWMAI.TGW_HEADER'
              ,'CO'
              ,'JL.CO.ARXTWMAI.TGW_HEADER'
              ,NULL)
        UNION
        SELECT
          RP.CUSTOMER_TRX_ID,
          RP.TRX_DATE,
          RP.TERM_DUE_DATE,
          RP.GD_GL_DATE,
          RP.BATCH_SOURCE_ID,
          RP.CUST_TRX_TYPE_ID,
          RP.ACTIVITY_FLAG,
          RP.POSTED_FLAG,
          RP.CTT_CLASS,
          RP.COMPLETE_FLAG,
          RP.GLOBAL_ATTRIBUTE_CATEGORY,
          RP.GLOBAL_ATTRIBUTE20,
          RP.DOC_SEQUENCE_VALUE DOC_SEQ_NUM
        FROM
          RA_CUSTOMER_TRX_PARTIAL_V RP
        WHERE RP.BATCH_SOURCE_ID = P_IN_BATCH_SOURCE_ID
          AND RP.CUST_TRX_TYPE_ID = NVL(P_IN_CUST_TRX_TYPE_ID
           ,RP.CUST_TRX_TYPE_ID)
          AND ( ( P_IN_NUMBER_TYPE = 'DOC_NUM'
          AND RP.DOC_SEQUENCE_VALUE between P_IN_NUMBER_LOW
          AND P_IN_NUMBER_HIGH )
        OR ( P_IN_NUMBER_TYPE = 'TRX_NUM'
          AND RP.TRX_NUMBER between P_IN_NUMBER_LOW
          AND P_IN_NUMBER_HIGH ) )
          AND ( RP.GLOBAL_ATTRIBUTE_CATEGORY IS NULL
        OR RP.GLOBAL_ATTRIBUTE_CATEGORY = DECODE(X_COUNTRY_CODE
              ,'CL'
              ,'JL.CL.ARXTWMAI.TGW_HEADER'
              ,'AR'
              ,'JL.AR.ARXTWMAI.TGW_HEADER'
              ,'CO'
              ,'JL.CO.ARXTWMAI.TGW_HEADER'
              ,NULL) )
          AND RP.GLOBAL_ATTRIBUTE20 IS NULL
        ORDER BY
          13;
      SETUP_FAILURE EXCEPTION;
      PREVIEW_REPORT EXCEPTION;
      L_MAX_WAIT_TIME NUMBER := 0;
      L_CUSTOMER_TRX_ID NUMBER;
      L_TRX_NUMBER_OUT VARCHAR2(20);
      L_TRX_DATE DATE;
      L_TERM_DUE_DATE DATE;
      L_GL_DATE DATE;
      L_BATCH_SOURCE_ID NUMBER;
      L_CUST_TRX_TYPE_ID NUMBER;
      L_ACTIVITY_FLAG VARCHAR2(1);
      L_POSTED_FLAG VARCHAR2(1);
      L_CTT_CLASS VARCHAR2(20);
      L_COMPLETE_FLAG VARCHAR2(1);
      L_GDF_CATEGORY VARCHAR2(30);
      L_GDF_ATTRIBUTE20 VARCHAR2(1);
      L_DOC_SEQ_NUM NUMBER;
      L_REQUEST_ID NUMBER;
      L_LAST_UPDATED_BY NUMBER;
      L_LAST_UPDATE_LOGIN NUMBER;
      L_CONC_LOGIN_ID NUMBER;
      L_LOGIN_ID NUMBER;
      L_DYNAMIC_WHERE VARCHAR2(2000);
      L_PHASE VARCHAR2(30);
      L_STATUS VARCHAR2(30);
      L_DEV_PHASE VARCHAR2(30);
      L_DEV_STATUS VARCHAR2(30);
      L_MESSAGE VARCHAR2(240);
      L_LOC VARCHAR2(30) := 'Before Report Trigger';
      L_ROW_NUM NUMBER;
      L_VERSION NUMBER := 1.0;
      L_RETURN_STATUS VARCHAR2(1);
      L_MSG_COUNT NUMBER;
      L_MSG_DATA VARCHAR2(1000);
      L_ORG_ID NUMBER;
    BEGIN
      L_ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID;
      P_COUNTRY_CODE := JG_ZZ_SHARED_PKG.GET_COUNTRY(L_ORG_ID
                                                    ,NULL);
      IF P_DEBUG_SWITCH = 'Y' THEN
        /*SRW.MESSAGE('999'
                   ,'Country Code = ' || P_COUNTRY_CODE)*/NULL;
      END IF;
      IF (GET_HEADER_INFO <> TRUE) THEN
        /*SRW.MESSAGE(999
                   ,'Failed to Get Header Information')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
      /*SRW.MESSAGE(999
                 ,'Checking Setup...')*/NULL;
      IF (CHECK_SETUP(P_IN_BATCH_SOURCE_ID
                 ,P_COUNTRY_CODE) <> TRUE) THEN
        /*SRW.MESSAGE(999
                   ,'One or more setup failure is found')*/NULL;
        FND_MESSAGE.SET_NAME('JL'
                            ,'JL_ZZ_AR_CVI_ERROR_HEADER');
        CP_SETUP_ERROR_TITLE := FND_MESSAGE.GET;
        RAISE SETUP_FAILURE;
      END IF;
      IF P_DEBUG_SWITCH = 'Y' THEN

NULL;
      END IF;
      /*SRW.MESSAGE(999
                 ,'Checking Setup Done')*/NULL;
      IF NVL(P_IN_PREVIEW_REPORT
         ,'Y') = 'Y' THEN
        RAISE PREVIEW_REPORT;
      END IF;
      IF P_DEBUG_SWITCH = 'Y' THEN
        /*SRW.MESSAGE(999
                   ,'Opening cursor c_master_trx...')*/NULL;
      END IF;
      OPEN C_MASTER_TRX(P_COUNTRY_CODE);
      LOOP
        FETCH C_MASTER_TRX
         INTO L_CUSTOMER_TRX_ID,L_TRX_DATE,L_TERM_DUE_DATE,L_GL_DATE,L_BATCH_SOURCE_ID,L_CUST_TRX_TYPE_ID,L_ACTIVITY_FLAG,L_POSTED_FLAG,L_CTT_CLASS,L_COMPLETE_FLAG,L_GDF_CATEGORY,L_GDF_ATTRIBUTE20,L_DOC_SEQ_NUM;
        EXIT WHEN C_MASTER_TRX%NOTFOUND;
        IF P_DEBUG_SWITCH = 'Y' THEN
         NULL;
        END IF;
        L_ROW_NUM := C_MASTER_TRX%ROWCOUNT;
        IF P_DEBUG_SWITCH = 'Y' THEN
          /*SRW.MESSAGE('999'
                     ,'l_row_num = ' || TO_CHAR(L_ROW_NUM))*/NULL;
        END IF;
        IF (CHECK_TRANSACTIONS(L_ACTIVITY_FLAG
                          ,L_POSTED_FLAG
                          ,L_CTT_CLASS
                          ,L_COMPLETE_FLAG
                          ,L_GDF_CATEGORY
                          ,L_GDF_ATTRIBUTE20
                          ,L_ROW_NUM) = TRUE) THEN
          /*SRW.MESSAGE(999
                     ,'Incomplete Invoice')*/NULL;
          AR_TRANSACTION_GRP.INCOMPLETE_TRANSACTION(P_API_VERSION => L_VERSION
                                                   ,P_COMMIT => 'T'
                                                   ,P_INIT_MSG_LIST => 'T'
                                                   ,P_VALIDATION_LEVEL => 100
                                                   ,P_CUSTOMER_TRX_ID => L_CUSTOMER_TRX_ID
                                                   ,X_RETURN_STATUS => L_RETURN_STATUS
                                                   ,X_MSG_COUNT => L_MSG_COUNT
                                                   ,X_MSG_DATA => L_MSG_DATA);
          IF L_RETURN_STATUS = 'S' THEN
            /*SRW.MESSAGE(999
                       ,'Checking Invoice Done')*/NULL;
            L_REQUEST_ID := FND_REQUEST.SUBMIT_REQUEST('AR'
                                                      ,'ARXREC'
                                                      ,NULL
                                                      ,FND_DATE.DATE_TO_CANONICAL(SYSDATE)
                                                      ,FALSE
                                                      ,'Y'
                                                      ,CHR(0)
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,''
                                                      ,'');
            IF L_REQUEST_ID = 0 THEN
              /*SRW.MESSAGE(900
                         ,'Failed to get request_id for Recurring Invoice Program')*/NULL;
              /*SRW.MESSAGE(900
                         ,FND_MESSAGE.GET)*/NULL;
              /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
            END IF;
            IF (INSERT_RECUR_INTERIM(L_REQUEST_ID
                                ,L_CUSTOMER_TRX_ID
                                ,L_TRX_DATE
                                ,L_TERM_DUE_DATE
                                ,L_GL_DATE
                                ,L_BATCH_SOURCE_ID
                                ,L_TRX_NUMBER_OUT) <> TRUE) THEN
              /*SRW.MESSAGE('999'
                         ,'insert_recur_interim <- ' || L_LOC)*/NULL;
              /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
            END IF;
            COMMIT;
            /*SRW.MESSAGE('999'
                       ,'Waiting for Recurring Invoice Program completion ...')*/NULL;
            IF (FND_CONCURRENT.WAIT_FOR_REQUEST(L_REQUEST_ID
                                           ,5
                                           ,L_MAX_WAIT_TIME
                                           ,L_PHASE
                                           ,L_STATUS
                                           ,L_DEV_PHASE
                                           ,L_DEV_STATUS
                                           ,L_MESSAGE) = TRUE) THEN
              IF L_DEV_PHASE = 'COMPLETE' THEN
                /*SRW.MESSAGE('999'
                           ,'Recurring Invoice Program completed')*/NULL;
                IF L_DEV_STATUS = 'ERROR' THEN
                  /*SRW.MESSAGE('999'
                             ,'Copy failed')*/NULL;
                  IF (UPDATE_ORIGINAL_TRX(P_COUNTRY_CODE
                                     ,L_CUSTOMER_TRX_ID
                                     ,L_TRX_NUMBER_OUT
                                     ,'E') <> TRUE) THEN
                    /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
                  END IF;
                ELSE
                  /*SRW.MESSAGE('999'
                             ,'Copy Succeeded')*/NULL;
                  IF (UPDATE_ORIGINAL_TRX(P_COUNTRY_CODE
                                     ,L_CUSTOMER_TRX_ID
                                     ,L_TRX_NUMBER_OUT
                                     ,'P') <> TRUE) THEN
                    /*SRW.MESSAGE('999'
                               ,'update_original_trx <- ' || L_LOC)*/NULL;
                    /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
                  END IF;
                  IF P_IN_CUST_TRX_TYPE_ID IS NOT NULL THEN
                    L_DYNAMIC_WHERE := L_DYNAMIC_WHERE || ' or rctpv.global_attribute19 = ' || TO_CHAR(L_CUST_TRX_TYPE_ID);
                  END IF;
                END IF;
              END IF;
            END IF;
            /*SRW.MESSAGE(999
                       ,'Completing Invoice')*/NULL;
            AR_TRANSACTION_GRP.COMPLETE_TRANSACTION(P_API_VERSION => L_VERSION
                                                   ,P_COMMIT => 'T'
                                                   ,P_INIT_MSG_LIST => 'T'
                                                   ,P_VALIDATION_LEVEL => 100
                                                   ,P_CUSTOMER_TRX_ID => L_CUSTOMER_TRX_ID
                                                   ,X_RETURN_STATUS => L_RETURN_STATUS
                                                   ,X_MSG_COUNT => L_MSG_COUNT
                                                   ,X_MSG_DATA => L_MSG_DATA);
          END IF;
        ELSE
          IF P_DEBUG_SWITCH = 'Y' THEN
            NULL;
          END IF;
          IF NVL(L_GDF_ATTRIBUTE20
             ,'E') in ('E','R') THEN
            IF (UPDATE_ORIGINAL_TRX(P_COUNTRY_CODE
                               ,L_CUSTOMER_TRX_ID
                               ,L_TRX_NUMBER_OUT
                               ,'E') <> TRUE) THEN
              /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
            END IF;
          ELSIF L_GDF_ATTRIBUTE20 in ('I','P') THEN
            NULL;
          END IF;
        END IF;
        L_CUSTOMER_TRX_ID := '';
        L_TRX_DATE := '';
        L_TERM_DUE_DATE := '';
        L_GL_DATE := '';
        L_BATCH_SOURCE_ID := '';
        L_TRX_NUMBER_OUT := '';
        L_REQUEST_ID := '';
        L_CUST_TRX_TYPE_ID := '';
      END LOOP;
      IF P_DEBUG_SWITCH = 'Y' THEN
        /*SRW.MESSAGE(999
                   ,'Cursor c_master_trx closed')*/NULL;
      END IF;
      if L_DYNAMIC_WHERE is not null then
      P_DYNAMIC_WHERE_TRX_TYPE := L_DYNAMIC_WHERE;
      else
      P_DYNAMIC_WHERE_TRX_TYPE :=' ';
      end if;
    EXCEPTION
      WHEN SETUP_FAILURE THEN
        NULL;
      WHEN PREVIEW_REPORT THEN
        NULL;
      WHEN OTHERS THEN
        IF (SQLCODE < 0) THEN
          /*SRW.MESSAGE('999'
                     ,SQLERRM)*/NULL;
        END IF;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    IF (CHECK_ORIG_INV_NOT_FOUND(P_IN_NUMBER_HIGH)) = TRUE THEN
      /*SRW.MESSAGE('999'
                 ,'The highest document number is adjusted')*/NULL;
      FND_MESSAGE.SET_NAME('JL'
                          ,'JL_ZZ_AR_CVI_DOC_NUM_HIGH');
      FND_MESSAGE.SET_TOKEN('PARAM_DOC_NUM_HIGH'
                           ,P_IN_NUMBER_HIGH
                           ,FALSE);
      FND_MESSAGE.SET_TOKEN('EXISTING_DOC_NUM_HIGH'
                           ,CP_ORIG_INV_NOT_FOUND_MESG
                           ,FALSE);
      CP_ORIG_INV_NOT_FOUND_MESG := FND_MESSAGE.GET;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION SUB_TITLEFORMULA RETURN VARCHAR2 IS
  BEGIN
    RP_SUB_TITLE := ' ';
    RETURN (' ');
  END SUB_TITLEFORMULA;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION CHECK_AUTO_TRX_NUM(P_BATCH_SOURCE_ID IN NUMBER) RETURN BOOLEAN IS
    L_DUMMY VARCHAR2(1);
    L_LOC VARCHAR2(30) := 'CHECK_AUTO_TRX_NUM';
  BEGIN
    IF P_DEBUG_SWITCH = 'Y' THEN
      /*SRW.MESSAGE('999'
                 ,'Batch Source Id = ' || TO_CHAR(P_BATCH_SOURCE_ID) || ' <- ' || L_LOC)*/NULL;
    END IF;
    SELECT
      'Y'
    INTO L_DUMMY
    FROM
      RA_BATCH_SOURCES
    WHERE BATCH_SOURCE_ID = P_BATCH_SOURCE_ID
      AND AUTO_TRX_NUMBERING_FLAG = 'Y';
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF P_DEBUG_SWITCH = 'Y' THEN
        /*SRW.MESSAGE('999'
                   ,'Automatic Trx Numbering is not enabled' || '<-' || L_LOC)*/NULL;
      END IF;
      CP_AUTO_TRX_NUM_FLAG := 'N';
      FND_MESSAGE.SET_NAME('JL'
                          ,'JL_ZZ_AR_AUTO_TRX_NUM_DISABLED');
      CP_AUTO_TRX_NUM_MESG := FND_MESSAGE.GET;
      RETURN (FALSE);
    WHEN OTHERS THEN
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      RETURN (FALSE);
  END CHECK_AUTO_TRX_NUM;
  FUNCTION CHECK_TRANSACTIONS(P_ACTIVITY_FLAG IN VARCHAR2
                             ,P_POSTED_FLAG IN VARCHAR2
                             ,P_CTT_CLASS IN VARCHAR2
                             ,P_COMPLETE_FLAG IN VARCHAR2
                             ,P_GDF_CATEGORY IN VARCHAR2
                             ,P_GDF_ATTRIBUTE20 IN VARCHAR2
                             ,P_ROW_NUM IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    IF P_ACTIVITY_FLAG = 'Y' THEN
      RETURN (FALSE);
    ELSIF P_POSTED_FLAG = 'Y' THEN
      RETURN (FALSE);
    ELSIF P_CTT_CLASS <> 'INV' THEN
      RETURN (FALSE);
    ELSIF P_COMPLETE_FLAG = 'N' THEN
      RETURN (FALSE);
    ELSIF P_GDF_CATEGORY in ('JL.CL.ARXTWMAI.TGW_HEADER','JL.AR.ARXTWMAI.TGW_HEADER','JL.CO.ARXTWMAI.TGW_HEADER') THEN
      IF P_GDF_ATTRIBUTE20 in ('P','I','W') THEN
        IF P_GDF_ATTRIBUTE20 = 'W' THEN
          /*SRW.SET_MAXROW('Q_MAIN'
                        ,P_ROW_NUM)*/NULL;
        END IF;
        RETURN (FALSE);
      ELSIF P_GDF_ATTRIBUTE20 = 'E' THEN
        RETURN (TRUE);
      ELSIF P_GDF_ATTRIBUTE20 IS NULL THEN
        RETURN (TRUE);
      END IF;
    ELSE
      RETURN (TRUE);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END CHECK_TRANSACTIONS;
  FUNCTION UPDATE_ORIGINAL_TRX(P_COUNTRY_CODE IN VARCHAR2
                              ,P_CUSTOMER_TRX_ID IN NUMBER
                              ,P_NEW_TRX_NUMBER IN VARCHAR2
                              ,P_COPY_TRX_STATUS IN VARCHAR2) RETURN BOOLEAN IS
    CURSOR C_ORIG_TRX_FOR_UPDATE IS
      SELECT
        CT.CUSTOMER_TRX_ID,
        CT.CUST_TRX_TYPE_ID
      FROM
        RA_CUSTOMER_TRX CT
      WHERE CT.CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;
    CURSOR C_ORIG_TRX_GL_DIST_FOR_UPDATE IS
      SELECT
        CTGLD.CUSTOMER_TRX_ID
      FROM
        RA_CUST_TRX_LINE_GL_DIST CTGLD
      WHERE CTGLD.CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
      FOR UPDATE OF GL_DATE NOWAIT;
    INVALID_COUNTRY EXCEPTION;
    L_VOID_TRX_TYPE_ID NUMBER;
    L_CUSTOMER_TRX_ID NUMBER;
    L_ORIG_CUST_TRX_TYPE_ID NUMBER;
    L_GDF_CATEGORY VARCHAR2(30);
    L_GL_DIST_CUST_TRX_ID NUMBER;
    L_USER_ID NUMBER;
    L_CONC_LOGIN_ID NUMBER;
    L_LOGIN_ID NUMBER;
    L_PROG_APPL_ID NUMBER;
    L_CONC_PROG_ID NUMBER;
    L_TRX_REC RA_CUSTOMER_TRX%ROWTYPE;
  BEGIN
    L_USER_ID := FND_PROFILE.VALUE('USER_ID');
    L_CONC_LOGIN_ID := FND_PROFILE.VALUE('CONC_LOGIN_ID');
    L_LOGIN_ID := FND_PROFILE.VALUE('LOGIN_ID');
    L_PROG_APPL_ID := FND_PROFILE.VALUE('PROG_APPL_ID');
    L_CONC_PROG_ID := FND_PROFILE.VALUE('CONC_PROGRAM_ID');
    IF P_COUNTRY_CODE = 'CL' THEN
      SELECT
        CUST_TRX_TYPE_ID
      INTO L_VOID_TRX_TYPE_ID
      FROM
        RA_CUST_TRX_TYPES
      WHERE GLOBAL_ATTRIBUTE_CATEGORY = 'JL.CL.RAXSUCTT.CUST_TRX_TYPES'
        AND GLOBAL_ATTRIBUTE6 = 'Y';
      L_GDF_CATEGORY := 'JL.CL.ARXTWMAI.TGW_HEADER';
    ELSIF P_COUNTRY_CODE = 'AR' THEN
      SELECT
        CUST_TRX_TYPE_ID
      INTO L_VOID_TRX_TYPE_ID
      FROM
        RA_CUST_TRX_TYPES
      WHERE GLOBAL_ATTRIBUTE_CATEGORY = 'JL.AR.RAXSUCTT.CUST_TRX_TYPES'
        AND GLOBAL_ATTRIBUTE6 = 'Y';
      L_GDF_CATEGORY := 'JL.AR.ARXTWMAI.TGW_HEADER';
    ELSIF P_COUNTRY_CODE = 'CO' THEN
      SELECT
        CUST_TRX_TYPE_ID
      INTO L_VOID_TRX_TYPE_ID
      FROM
        RA_CUST_TRX_TYPES
      WHERE GLOBAL_ATTRIBUTE_CATEGORY = 'JL.CO.RAXSUCTT.CUST_TRX_TYPES'
        AND GLOBAL_ATTRIBUTE6 = 'Y';
      L_GDF_CATEGORY := 'JL.CO.ARXTWMAI.TGW_HEADER';
    ELSE
      RAISE INVALID_COUNTRY;
    END IF;
    OPEN C_ORIG_TRX_FOR_UPDATE;
    LOOP
      FETCH C_ORIG_TRX_FOR_UPDATE
       INTO L_CUSTOMER_TRX_ID,L_ORIG_CUST_TRX_TYPE_ID;
      EXIT WHEN C_ORIG_TRX_FOR_UPDATE%NOTFOUND;
      IF P_COPY_TRX_STATUS = 'P' THEN
        ARP_CT_PKG.LOCK_FETCH_P(L_TRX_REC
                               ,L_CUSTOMER_TRX_ID);
        L_TRX_REC.CUST_TRX_TYPE_ID := L_VOID_TRX_TYPE_ID;
        L_TRX_REC.COMMENTS := P_NEW_TRX_NUMBER || ':' || P_IN_VOID_REASON;
        L_TRX_REC.GLOBAL_ATTRIBUTE_CATEGORY := L_GDF_CATEGORY;
        L_TRX_REC.GLOBAL_ATTRIBUTE20 := P_COPY_TRX_STATUS;
        L_TRX_REC.GLOBAL_ATTRIBUTE19 := L_ORIG_CUST_TRX_TYPE_ID;
        L_TRX_REC.RELATED_CUSTOMER_TRX_ID := '';
        L_TRX_REC.LAST_UPDATED_BY := L_USER_ID;
        L_TRX_REC.LAST_UPDATE_DATE := SYSDATE;
        L_TRX_REC.LAST_UPDATE_LOGIN := NVL(L_CONC_LOGIN_ID
                                          ,L_LOGIN_ID);
        L_TRX_REC.PROGRAM_APPLICATION_ID := L_PROG_APPL_ID;
        L_TRX_REC.PROGRAM_ID := L_CONC_PROG_ID;
        L_TRX_REC.PROGRAM_UPDATE_DATE := SYSDATE;
        ARP_CT_PKG.UPDATE_P(L_TRX_REC
                           ,L_CUSTOMER_TRX_ID);
        /*SRW.MESSAGE('999'
                   ,'The original invoice is successfully voided')*/NULL;
        IF P_DEBUG_SWITCH = 'Y' THEN
         NULL;
        END IF;
        OPEN C_ORIG_TRX_GL_DIST_FOR_UPDATE;
        LOOP
          FETCH C_ORIG_TRX_GL_DIST_FOR_UPDATE
           INTO L_GL_DIST_CUST_TRX_ID;
          EXIT WHEN C_ORIG_TRX_GL_DIST_FOR_UPDATE%NOTFOUND;
          UPDATE
            RA_CUST_TRX_LINE_GL_DIST
          SET
            GL_DATE = NULL
          WHERE  CURRENT OF C_ORIG_TRX_GL_DIST_FOR_UPDATE;
          IF P_DEBUG_SWITCH = 'Y' THEN
            /*SRW.MESSAGE('999'
                       ,'Updated GL Distributions:' || ' l_gl_dist_cust_trx_id = ' || TO_CHAR(L_GL_DIST_CUST_TRX_ID))*/NULL;
          END IF;
        END LOOP;
        CLOSE C_ORIG_TRX_GL_DIST_FOR_UPDATE;
        /*SRW.MESSAGE('999'
                   ,'GL date is successfully set to NULL for all gl distributions of the original invoice ')*/NULL;
      ELSE
        ARP_CT_PKG.LOCK_FETCH_P(L_TRX_REC
                               ,L_CUSTOMER_TRX_ID);
        L_TRX_REC.GLOBAL_ATTRIBUTE_CATEGORY := L_GDF_CATEGORY;
        L_TRX_REC.GLOBAL_ATTRIBUTE20 := P_COPY_TRX_STATUS;
        L_TRX_REC.LAST_UPDATED_BY := L_USER_ID;
        L_TRX_REC.LAST_UPDATE_DATE := SYSDATE;
        L_TRX_REC.LAST_UPDATE_LOGIN := NVL(L_CONC_LOGIN_ID
                                          ,L_LOGIN_ID);
        L_TRX_REC.PROGRAM_APPLICATION_ID := L_PROG_APPL_ID;
        L_TRX_REC.PROGRAM_ID := L_CONC_PROG_ID;
        L_TRX_REC.PROGRAM_UPDATE_DATE := SYSDATE;
        ARP_CT_PKG.UPDATE_P(L_TRX_REC
                           ,L_CUSTOMER_TRX_ID);
        /*SRW.MESSAGE('999'
                   ,'The original invoice is updated with copy status')*/NULL;
      END IF;
    END LOOP;
    CLOSE C_ORIG_TRX_FOR_UPDATE;
    RETURN (TRUE);
  EXCEPTION
    WHEN INVALID_COUNTRY THEN
      /*SRW.MESSAGE(999
                 ,'Invalid Country Code: update_original_trx <- beforerep')*/NULL;
      RETURN (FALSE);
    WHEN OTHERS THEN
      IF (SQLCODE = -54) THEN
        /*SRW.MESSAGE('999'
                   ,'Transaction with CUSTOMER_TRX_ID: ' || TO_CHAR(P_CUSTOMER_TRX_ID) || ' is locked.')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
      /*SRW.MESSAGE(999
                 ,'update_original_trx <- beforerep')*/NULL;
      RETURN (FALSE);
  END UPDATE_ORIGINAL_TRX;
  FUNCTION CHECK_SETUP(P_BATCH_SOURCE_ID IN NUMBER
                      ,P_COUNTRY_CODE IN VARCHAR2) RETURN BOOLEAN IS
    L_ERROR_CNT NUMBER := 0;
    L_LOC VARCHAR2(30) := 'CHECK_SETUP';
  BEGIN
    IF P_DEBUG_SWITCH = 'Y' THEN
      /*SRW.MESSAGE('999'
                 ,'Batch Source Id = ' || TO_CHAR(P_BATCH_SOURCE_ID) || ' <- ' || L_LOC)*/NULL;
    END IF;
    IF (CHECK_AUTO_TRX_NUM(P_BATCH_SOURCE_ID) <> TRUE) THEN
      L_ERROR_CNT := L_ERROR_CNT + 1;
    END IF;
    IF P_DEBUG_SWITCH = 'Y' THEN
      /*SRW.MESSAGE('999'
                 ,'Country Code = ' || P_COUNTRY_CODE || ' <- ' || L_LOC)*/NULL;
    END IF;
    IF (CHECK_VOID_TRX_TYPE(P_COUNTRY_CODE) <> TRUE) THEN
      L_ERROR_CNT := L_ERROR_CNT + 1;
    END IF;
    CP_ERROR_COUNT := L_ERROR_CNT;
    IF L_ERROR_CNT <> 0 THEN
      RETURN (FALSE);
    ELSE
      RETURN (TRUE);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      RETURN (FALSE);
  END CHECK_SETUP;
  FUNCTION CHECK_VOID_TRX_TYPE(P_COUNTRY_CODE IN VARCHAR2) RETURN BOOLEAN IS
    L_CUST_TRX_TYPE_ID NUMBER;
    L_OPEN_AR VARCHAR2(1);
    L_POST_TO_GL VARCHAR2(1);
    L_LOC VARCHAR2(30) := 'CHECK_VOID_TRX_TYPE';
  BEGIN
    IF P_DEBUG_SWITCH = 'Y' THEN
      /*SRW.MESSAGE('999'
                 ,'Country Code = ' || P_COUNTRY_CODE || ' <- ' || L_LOC)*/NULL;
    END IF;
    IF P_COUNTRY_CODE = 'CL' THEN
      SELECT
        CUST_TRX_TYPE_ID,
        ACCOUNTING_AFFECT_FLAG,
        POST_TO_GL
      INTO L_CUST_TRX_TYPE_ID,L_OPEN_AR,L_POST_TO_GL
      FROM
        RA_CUST_TRX_TYPES
      WHERE GLOBAL_ATTRIBUTE_CATEGORY = 'JL.CL.RAXSUCTT.CUST_TRX_TYPES'
        AND GLOBAL_ATTRIBUTE6 = 'Y';
    ELSIF P_COUNTRY_CODE = 'AR' THEN
      SELECT
        CUST_TRX_TYPE_ID,
        ACCOUNTING_AFFECT_FLAG,
        POST_TO_GL
      INTO L_CUST_TRX_TYPE_ID,L_OPEN_AR,L_POST_TO_GL
      FROM
        RA_CUST_TRX_TYPES
      WHERE GLOBAL_ATTRIBUTE_CATEGORY = 'JL.AR.RAXSUCTT.CUST_TRX_TYPES'
        AND GLOBAL_ATTRIBUTE6 = 'Y';
    ELSIF P_COUNTRY_CODE = 'CO' THEN
      SELECT
        CUST_TRX_TYPE_ID,
        ACCOUNTING_AFFECT_FLAG,
        POST_TO_GL
      INTO L_CUST_TRX_TYPE_ID,L_OPEN_AR,L_POST_TO_GL
      FROM
        RA_CUST_TRX_TYPES
      WHERE GLOBAL_ATTRIBUTE_CATEGORY = 'JL.CO.RAXSUCTT.CUST_TRX_TYPES'
        AND GLOBAL_ATTRIBUTE6 = 'Y';
    ELSE
      /*SRW.MESSAGE('999'
                 ,P_COUNTRY_CODE)*/NULL;
      /*SRW.MESSAGE('999'
                 ,'Country must be CL or AR or CO' || '<-' || L_LOC)*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    IF L_OPEN_AR = 'N' AND L_POST_TO_GL = 'N' THEN
      RETURN (TRUE);
    ELSE
      CP_VOID_TYPE_NO_NO_FLAG := 'N';
      FND_MESSAGE.SET_NAME('JL'
                          ,'JL_ZZ_AR_VOID_TRX_TYPE_ARGL');
      CP_VOID_TYPE_NO_NO_MESG := FND_MESSAGE.GET;
      RETURN (FALSE);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF P_DEBUG_SWITCH = 'Y' THEN
        /*SRW.MESSAGE('999'
                   ,'No Void Transaction Type found' || '<-' || L_LOC)*/NULL;
      END IF;
      CP_VOID_TYPE_EXIST_FLAG := 'N';
      FND_MESSAGE.SET_NAME('JL'
                          ,'JL_ZZ_AR_NO_VOID_TRX_TYPE');
      CP_VOID_TYPE_EXIST_MESG := FND_MESSAGE.GET;
      RETURN (FALSE);
    WHEN TOO_MANY_ROWS THEN
      IF P_DEBUG_SWITCH = 'Y' THEN
        /*SRW.MESSAGE('999'
                   ,'Void Transaction Type is not unique' || '<-' || L_LOC)*/NULL;
      END IF;
      CP_VOID_TYPE_UNIQ_FLAG := 'N';
      FND_MESSAGE.SET_NAME('JL'
                          ,'JL_ZZ_AR_VOID_TRX_TYPE_DUP');
      CP_VOID_TYPE_UNIQ_MESG := FND_MESSAGE.GET;
      RETURN (FALSE);
    WHEN OTHERS THEN
      IF P_DEBUG_SWITCH = 'Y' THEN
        /*SRW.MESSAGE('999'
                   ,'Fatal Error found' || ' <- ' || L_LOC)*/NULL;
      END IF;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      RETURN (FALSE);
  END CHECK_VOID_TRX_TYPE;
  FUNCTION INSERT_RECUR_INTERIM(P_REQUEST_ID IN NUMBER
                               ,P_CUSTOMER_TRX_ID IN NUMBER
                               ,P_TRX_DATE IN DATE
                               ,P_TERM_DUE_DATE IN DATE
                               ,P_GL_DATE IN DATE
                               ,P_BATCH_SOURCE_ID IN NUMBER
                               ,P_NEW_TRX_NUMBER OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
    L_LOC VARCHAR2(30) := 'INSERT_RECUR_INTERIM';
  BEGIN
    JL_AR_RECUR_PKG.INSERT_INTERIM(P_CUSTOMER_TRX_ID
                                  ,P_TRX_DATE
                                  ,P_TERM_DUE_DATE
                                  ,P_GL_DATE
                                  ,NULL
                                  ,P_REQUEST_ID
                                  ,NULL
                                  ,NULL
                                  ,P_BATCH_SOURCE_ID
                                  ,P_NEW_TRX_NUMBER);
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE < 0) THEN
        /*SRW.MESSAGE('999'
                   ,SQLERRM || L_LOC)*/NULL;
      END IF;
      RETURN (FALSE);
  END INSERT_RECUR_INTERIM;
  FUNCTION CHECK_ORIG_INV_NOT_FOUND(P_NUMBER_HIGH IN VARCHAR2) RETURN BOOLEAN IS
    L_MAX_DOC_SEQ_NUM NUMBER;
    L_MAX_TRX_NUM VARCHAR2(20);
  BEGIN
    IF P_IN_NUMBER_TYPE = 'DOC_NUM' THEN
      SELECT
        MAX(DOC_SEQUENCE_VALUE)
      INTO L_MAX_DOC_SEQ_NUM
      FROM
        RA_CUSTOMER_TRX_ALL
      WHERE DOC_SEQUENCE_VALUE <= TO_NUMBER(P_NUMBER_HIGH);
      IF L_MAX_DOC_SEQ_NUM < P_NUMBER_HIGH THEN
        CP_ORIG_INV_NOT_FOUND_MESG := L_MAX_DOC_SEQ_NUM;
        RETURN (TRUE);
      ELSE
        RETURN (FALSE);
      END IF;
    ELSIF P_IN_NUMBER_TYPE = 'TRX_NUM' THEN
      SELECT
        MAX(TRX_NUMBER)
      INTO L_MAX_TRX_NUM
      FROM
        RA_CUSTOMER_TRX_ALL
      WHERE TRX_NUMBER <= P_NUMBER_HIGH;
      IF L_MAX_TRX_NUM < P_NUMBER_HIGH THEN
        CP_ORIG_INV_NOT_FOUND_MESG := L_MAX_TRX_NUM;
        RETURN (TRUE);
      ELSE
        RETURN (FALSE);
      END IF;
    ELSE
      RETURN (FALSE);
    END IF;
    RETURN NULL;
  END CHECK_ORIG_INV_NOT_FOUND;
  FUNCTION GET_HEADER_INFO RETURN BOOLEAN IS
    L_BATCH_SOURCE_NAME VARCHAR2(50);
    L_NUMBER_TYPE VARCHAR2(80);
  BEGIN
    SELECT
      NAME
    INTO L_BATCH_SOURCE_NAME
    FROM
      RA_BATCH_SOURCES
    WHERE BATCH_SOURCE_ID = P_IN_BATCH_SOURCE_ID;
    RP_BATCH_SOURCE_NAME := L_BATCH_SOURCE_NAME;
    SELECT
      MEANING
    INTO L_NUMBER_TYPE
    FROM
      FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'JLZZ_CVI_NUMBER_TYPE'
      AND LOOKUP_CODE = P_IN_NUMBER_TYPE;
    RP_NUMBER_TYPE := L_NUMBER_TYPE;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_HEADER_INFO;
  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;
  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;
  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SUB_TITLE;
  END RP_SUB_TITLE_P;
  FUNCTION CP_AUTO_TRX_NUM_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_AUTO_TRX_NUM_FLAG;
  END CP_AUTO_TRX_NUM_FLAG_P;
  FUNCTION CP_DOC_SEQ_NUM_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DOC_SEQ_NUM_FLAG;
  END CP_DOC_SEQ_NUM_FLAG_P;
  FUNCTION CP_VOID_TYPE_EXIST_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_VOID_TYPE_EXIST_FLAG;
  END CP_VOID_TYPE_EXIST_FLAG_P;
  FUNCTION CP_VOID_TYPE_UNIQ_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_VOID_TYPE_UNIQ_FLAG;
  END CP_VOID_TYPE_UNIQ_FLAG_P;
  FUNCTION CP_VOID_TYPE_NO_NO_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_VOID_TYPE_NO_NO_FLAG;
  END CP_VOID_TYPE_NO_NO_FLAG_P;
  FUNCTION CP_AUTO_TRX_NUM_MESG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_AUTO_TRX_NUM_MESG;
  END CP_AUTO_TRX_NUM_MESG_P;
  FUNCTION CP_DOC_SEQ_NUM_MESG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DOC_SEQ_NUM_MESG;
  END CP_DOC_SEQ_NUM_MESG_P;
  FUNCTION CP_VOID_TYPE_EXIST_MESG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_VOID_TYPE_EXIST_MESG;
  END CP_VOID_TYPE_EXIST_MESG_P;
  FUNCTION CP_VOID_TYPE_UNIQ_MESG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_VOID_TYPE_UNIQ_MESG;
  END CP_VOID_TYPE_UNIQ_MESG_P;
  FUNCTION CP_VOID_TYPE_NO_NO_MESG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_VOID_TYPE_NO_NO_MESG;
  END CP_VOID_TYPE_NO_NO_MESG_P;
  FUNCTION CP_SETUP_ERROR_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SETUP_ERROR_TITLE;
  END CP_SETUP_ERROR_TITLE_P;
  FUNCTION CP_ERROR_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN CP_ERROR_COUNT;
  END CP_ERROR_COUNT_P;
  FUNCTION CP_ORIG_INV_NOT_FOUND_MESG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ORIG_INV_NOT_FOUND_MESG;
  END CP_ORIG_INV_NOT_FOUND_MESG_P;
  FUNCTION RP_BATCH_SOURCE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_BATCH_SOURCE_NAME;
  END RP_BATCH_SOURCE_NAME_P;
  FUNCTION RP_NUMBER_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_NUMBER_TYPE;
  END RP_NUMBER_TYPE_P;
END JL_JLZZRCVI_XMLP_PKG;



/
