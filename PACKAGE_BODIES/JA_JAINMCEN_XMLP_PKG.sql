--------------------------------------------------------
--  DDL for Package Body JA_JAINMCEN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAINMCEN_XMLP_PKG" AS
/* $Header: JAINMCENB.pls 120.1 2007/12/25 16:22:38 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR C_PROGRAM_ID(P_REQUEST_ID IN NUMBER) IS
      SELECT
        CONCURRENT_PROGRAM_ID,
        NVL(ENABLE_TRACE
           ,'N')
      FROM
        FND_CONCURRENT_REQUESTS
      WHERE REQUEST_ID = P_REQUEST_ID;
    CURSOR GET_AUDSID IS
      SELECT
        A.SID,
        A.SERIAL#,
        B.SPID
      FROM
        V$SESSION A,
        V$PROCESS B
      WHERE AUDSID = USERENV('SESSIONID')
        AND A.PADDR = B.ADDR;
    CURSOR GET_DBNAME IS
      SELECT
        NAME
      FROM
        V$DATABASE;
    V_ENABLE_TRACE FND_CONCURRENT_PROGRAMS.ENABLE_TRACE%TYPE;
    V_PROGRAM_ID FND_CONCURRENT_PROGRAMS.CONCURRENT_PROGRAM_ID%TYPE;
    AUDSID NUMBER := USERENV('SESSIONID');
    SID NUMBER;
    SERIAL NUMBER;
    SPID VARCHAR2(9);
    NAME1 VARCHAR2(25);
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.MESSAGE(1275
               ,'Report Version is 120.4 Last modified date is 23/11/2006')*/NULL;
    BEGIN
      OPEN C_PROGRAM_ID(P_CONC_REQUEST_ID);
      FETCH C_PROGRAM_ID
       INTO V_PROGRAM_ID,V_ENABLE_TRACE;
      CLOSE C_PROGRAM_ID;
      /*SRW.MESSAGE(1275
                 ,'v_program_id -> ' || V_PROGRAM_ID || ', v_enable_trace -> ' || V_ENABLE_TRACE || ', request_id -> ' || P_CONC_REQUEST_ID)*/NULL;
      IF V_ENABLE_TRACE = 'Y' THEN
        OPEN GET_AUDSID;
        FETCH GET_AUDSID
         INTO SID,SERIAL,SPID;
        CLOSE GET_AUDSID;
        OPEN GET_DBNAME;
        FETCH GET_DBNAME
         INTO NAME1;
        CLOSE GET_DBNAME;
        /*SRW.MESSAGE(1275
                   ,'TraceFile Name = ' || LOWER(NAME1) || '_ora_' || SPID || '.trc')*/NULL;
        EXECUTE IMMEDIATE
          'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1275
                   ,'Error during enabling the trace. ErrCode -> ' || SQLCODE || ', ErrMesg -> ' || SQLERRM)*/NULL;
    END;
    IF P_REGISTER_TYPE = 'A' THEN
      CP_REPORT_TITLE := 'Monthly Return Under Rule 7 Of The Cenvat Credit Rules, 2002 Inputs';
    ELSIF P_REGISTER_TYPE = 'C' THEN
      CP_REPORT_TITLE := 'Monthly Return Under Rule 7 Of The Cenvat Credit Rules, 2002 Capital Goods';
    END IF;
    FOR org_rec IN (SELECT
                      NAME
                    FROM
                      HR_ALL_ORGANIZATION_UNITS
                    WHERE ORGANIZATION_ID = P_ORGANIZATION_ID) LOOP
      P_ORGANIZATION_NAME := ORG_REC.NAME;
    END LOOP;
    FOR loc_rec IN (SELECT
                      DESCRIPTION,
                      ADDRESS_LINE_1,
                      ADDRESS_LINE_2,
                      ADDRESS_LINE_3
                    FROM
                      HR_LOCATIONS
                    WHERE LOCATION_ID = P_LOCATION_ID) LOOP
      P_DESCRIPTION := LOC_REC.DESCRIPTION;
      P_ADDRESS_LINE_1 := LOC_REC.ADDRESS_LINE_1;
      P_ADDRESS_LINE_2 := LOC_REC.ADDRESS_LINE_2;
      P_ADDRESS_LINE_3 := LOC_REC.ADDRESS_LINE_3;
    END LOOP;
    FOR ec_rec IN (SELECT
                     EC_CODE,
                     EXCISE_DUTY_COMM,
                     EXCISE_DUTY_RANGE,
                     EXCISE_DUTY_DIVISION,
                     EXCISE_DUTY_CIRCLE
                   FROM
                     JAI_CMN_INVENTORY_ORGS
                   WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                     AND LOCATION_ID = P_LOCATION_ID) LOOP
      P_EC_CODE := EC_REC.EC_CODE;
      P_COLLECT := EC_REC.EXCISE_DUTY_COMM;
      P_RANGE := EC_REC.EXCISE_DUTY_RANGE;
      P_DIVISION := EC_REC.EXCISE_DUTY_DIVISION;
      P_CIRCLE := EC_REC.EXCISE_DUTY_CIRCLE;
    END LOOP;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_ASSESSABLE_VALUEFORMULA(RECEIPT_ID IN VARCHAR2
                                     ,EXCISE_INVOICE_NO IN VARCHAR2
                                     ,EXCISE_INVOICE_DATE IN DATE
                                     ,ORGANIZATION_ID IN NUMBER
                                     ,LOCATION_ID IN NUMBER) RETURN NUMBER IS
    CURSOR CUR_SOB_ID(CP_ORGANIZATION_ID IN RCV_TRANSACTIONS.ORGANIZATION_ID%TYPE) IS
      SELECT
        SET_OF_BOOKS_ID
      FROM
        ORG_ORGANIZATION_DEFINITIONS
      WHERE ORGANIZATION_ID = CP_ORGANIZATION_ID
        AND ROWNUM = 1;
    CURSOR CUR_RECEIPT_LINE_AMOUNT(CP_TRANSACTION_ID IN RCV_TRANSACTIONS.TRANSACTION_ID%TYPE) IS
      SELECT
        A.QTY_RECEIVED * B.PO_UNIT_PRICE
      FROM
        JAI_RCV_LINES A,
        RCV_TRANSACTIONS B
      WHERE A.TRANSACTION_ID = B.TRANSACTION_ID;
    V_SOB_ID ORG_ORGANIZATION_DEFINITIONS.SET_OF_BOOKS_ID%TYPE;
    V_PO_FUNC_CONV NUMBER;
    VAMT1 NUMBER := 0;
    LN_TOT_ASSESSABLE_VAL NUMBER := 0;
  BEGIN
    IF RECEIPT_ID IS NOT NULL THEN
      FOR c1 IN (SELECT
                   RTL.TAX_AMOUNT,
                   RTL.TAX_RATE TR,
                   RT.SHIPMENT_LINE_ID,
                   RTL.TAX_TYPE,
                   RT.ORGANIZATION_ID ORGANIZATION_ID,
                   RT.CURRENCY_CONVERSION_TYPE,
                   RT.CURRENCY_CONVERSION_RATE,
                   RT.CURRENCY_CONVERSION_DATE,
                   RT.CURRENCY_CODE CCODE,
                   JTC.ADHOC_FLAG
                 FROM
                   JAI_CMN_RG_23AC_II_TRXS RG23,
                   RCV_TRANSACTIONS RT,
                   JAI_RCV_LINE_TAXES RTL,
                   JAI_CMN_TAXES_ALL JTC
                 WHERE RG23.EXCISE_INVOICE_NO = cf_assessable_valueformula.EXCISE_INVOICE_NO
                   AND RG23.EXCISE_INVOICE_DATE = cf_assessable_valueformula.EXCISE_INVOICE_DATE
                   AND RG23.ORGANIZATION_ID = cf_assessable_valueformula.ORGANIZATION_ID
                   AND RG23.LOCATION_ID = cf_assessable_valueformula.LOCATION_ID
                   AND RG23.REGISTER_TYPE = P_REGISTER_TYPE
                   AND TRUNC(RG23.CREATION_DATE) BETWEEN NVL(P_TRN_FROM_DATE
                    ,TRUNC(RG23.CREATION_DATE))
                   AND NVL(P_TRN_TO_DATE
                    ,TRUNC(SYSDATE))
                   AND RT.TRANSACTION_ID = TO_NUMBER(RG23.RECEIPT_REF)
                   AND JTC.TAX_ID = RTL.TAX_ID
                   AND RT.SHIPMENT_LINE_ID = RTL.SHIPMENT_LINE_ID
                   AND NVL(RTL.TAX_AMOUNT
                    ,0) <> 0
                   AND NVL(RTL.MODVAT_FLAG
                    ,'N') = 'Y'
                   AND RTL.TAX_TYPE IN ( LV_TAX_TYPE_EXCISE , LV_TAX_TYPE_EXC_ADDITIONAL , LV_TAX_TYPE_EXC_OTHER , LV_TAX_TYPE_CVD , LV_TAX_TYPE_ADDITIONAL_CVD )
                   AND NVL(JTC.MOD_CR_PERCENTAGE
                    ,0) <> 0) LOOP
        OPEN CUR_SOB_ID(CP_ORGANIZATION_ID => C1.ORGANIZATION_ID);
        FETCH CUR_SOB_ID
         INTO V_SOB_ID;
        CLOSE CUR_SOB_ID;
        VAMT1 := 0;
        /*SRW.MESSAGE(998
                   ,'start 1 cf_assesablevalue formula v_sob_id = ' || V_SOB_ID || ' c1.currency_conversion_date = ' || C1.CURRENCY_CONVERSION_DATE || ' c1.currency_conversion_type = ' || C1.CURRENCY_CONVERSION_TYPE ||
		   ' c1.currency_conversion_rate = ' || C1.CURRENCY_CONVERSION_RATE)*/NULL;
        V_PO_FUNC_CONV := JAI_CMN_UTILS_PKG.CURRENCY_CONVERSION(V_SOB_ID
                                                               ,C1.CCODE
                                                               ,C1.CURRENCY_CONVERSION_DATE
                                                               ,C1.CURRENCY_CONVERSION_TYPE
                                                               ,C1.CURRENCY_CONVERSION_RATE);
        /*SRW.MESSAGE(997
                   ,'v_po_func_conv = ' || V_PO_FUNC_CONV)*/NULL;
        IF C1.TR <> 0 THEN
          VAMT1 := (C1.TAX_AMOUNT * V_PO_FUNC_CONV * 100) / C1.TR;
        ELSE
          OPEN CUR_RECEIPT_LINE_AMOUNT(CP_TRANSACTION_ID => TO_NUMBER(RECEIPT_ID));
          FETCH CUR_RECEIPT_LINE_AMOUNT
           INTO VAMT1;
          CLOSE CUR_RECEIPT_LINE_AMOUNT;
          VAMT1 := VAMT1 * NVL(V_PO_FUNC_CONV
                      ,1);
          /*SRW.MESSAGE(997
                     ,'Adhoc Excise tax is attached to->' || RECEIPT_ID)*/NULL;
        END IF;
        LN_TOT_ASSESSABLE_VAL := LN_TOT_ASSESSABLE_VAL + VAMT1;
      END LOOP;
    END IF;
    RETURN (LN_TOT_ASSESSABLE_VAL);
  END CF_ASSESSABLE_VALUEFORMULA;

  FUNCTION CF_DOCUMENT_TYPEFORMULA(VENDOR_ID IN NUMBER
                                  ,RECEIPT_ID IN VARCHAR2
                                  ,DOCUMENT_TYPE IN VARCHAR2) RETURN CHAR IS
    CURSOR COUNT_EXCISE_TAXES(CP_RECEIPT_ID IN JAI_CMN_RG_23AC_II_TRXS.RECEIPT_REF%TYPE) IS
      SELECT
        COUNT(1)
      FROM
        JAI_RCV_LINE_TAXES JRL,
        RCV_TRANSACTIONS RCVT
      WHERE RCVT.TRANSACTION_ID = TO_NUMBER(CP_RECEIPT_ID)
        AND RCVT.TRANSACTION_TYPE = LV_RCV_TRANSACTION_TYPE
        AND RCVT.SHIPMENT_LINE_ID = JRL.SHIPMENT_LINE_ID
        AND UPPER(JRL.TAX_TYPE) LIKE UPPER(LV_TAX_TYPE_EXCISE);
    CURSOR COUNT_CVD_TAXES(CP_RECEIPT_ID IN JAI_CMN_RG_23AC_II_TRXS.RECEIPT_REF%TYPE) IS
      SELECT
        COUNT(1)
      FROM
        JAI_RCV_LINE_TAXES JRL,
        RCV_TRANSACTIONS RCVT
      WHERE RCVT.TRANSACTION_ID = TO_NUMBER(CP_RECEIPT_ID)
        AND RCVT.TRANSACTION_TYPE = LV_RCV_TRANSACTION_TYPE
        AND RCVT.SHIPMENT_LINE_ID = JRL.SHIPMENT_LINE_ID
        AND UPPER(JRL.TAX_TYPE) LIKE LV_TAX_TYPE_CVD;
    V_COUNT_EXCISE_TAXES NUMBER;
    V_COUNT_CVD_TAXES NUMBER;
  BEGIN
    IF VENDOR_ID IS NULL OR VENDOR_ID < 0 THEN
      OPEN COUNT_EXCISE_TAXES(CP_RECEIPT_ID => RECEIPT_ID);
      FETCH COUNT_EXCISE_TAXES
       INTO V_COUNT_EXCISE_TAXES;
      CLOSE COUNT_EXCISE_TAXES;
      OPEN COUNT_CVD_TAXES(CP_RECEIPT_ID => RECEIPT_ID);
      FETCH COUNT_CVD_TAXES
       INTO V_COUNT_CVD_TAXES;
      CLOSE COUNT_CVD_TAXES;
      IF V_COUNT_EXCISE_TAXES > 0 THEN
        RETURN 'Invoice';
      ELSIF V_COUNT_CVD_TAXES > 0 THEN
        RETURN 'BOE';
      ELSE
        RETURN NULL;
      END IF;
    ELSE
      RETURN DOCUMENT_TYPE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(1275
                 ,'Unable to fetch document_type in case of an Internal Sales Order' || SQLERRM)*/NULL;
      RETURN NULL;
  END CF_DOCUMENT_TYPEFORMULA;

  FUNCTION CF_EC_CODEFORMULA(VENDOR_ID IN NUMBER
                            ,VENDOR_SITE_ID IN NUMBER
                            ,RECEIPT_ID IN VARCHAR2
                            ,EC_CODE IN VARCHAR2) RETURN CHAR IS
    CURSOR INT_ORDER_CUR(CP_RECEIPT_ID IN JAI_CMN_RG_23AC_II_TRXS.RECEIPT_REF%TYPE,CP_RECEIPT_SOURCE_CODE IN RCV_SHIPMENT_HEADERS.RECEIPT_SOURCE_CODE%TYPE) IS
      SELECT
        DISTINCT
        JU.EC_CODE
      FROM
        RCV_TRANSACTIONS RCVT,
        RCV_SHIPMENT_HEADERS RCVSH,
        JAI_CMN_INVENTORY_ORGS JU
      WHERE RCVT.TRANSACTION_ID = CP_RECEIPT_ID
        AND RCVT.TRANSACTION_TYPE = LV_RCV_TRANSACTION_TYPE
        AND RCVT.SHIPMENT_HEADER_ID = RCVSH.SHIPMENT_HEADER_ID
        AND RCVSH.RECEIPT_SOURCE_CODE = CP_RECEIPT_SOURCE_CODE
        AND RCVSH.ORGANIZATION_ID = JU.ORGANIZATION_ID;
    CURSOR C_FETCH_ECCODE_FOR_ISO IS
      SELECT
        JHRU.EC_CODE
      FROM
        JAI_CMN_INVENTORY_ORGS JHRU
      WHERE ORGANIZATION_ID = ABS(VENDOR_ID)
        AND LOCATION_ID = ABS(VENDOR_SITE_ID);
    V_EC_CODE JAI_CMN_INVENTORY_ORGS.EC_CODE%TYPE;
  BEGIN
    IF VENDOR_ID IS NULL THEN
      OPEN INT_ORDER_CUR(CP_RECEIPT_ID => RECEIPT_ID,CP_RECEIPT_SOURCE_CODE => 'INTERNAL ORDER');
      FETCH INT_ORDER_CUR
       INTO V_EC_CODE;
      CLOSE INT_ORDER_CUR;
      RETURN V_EC_CODE;
    ELSIF VENDOR_ID < 0 THEN
      OPEN C_FETCH_ECCODE_FOR_ISO;
      FETCH C_FETCH_ECCODE_FOR_ISO
       INTO V_EC_CODE;
      CLOSE C_FETCH_ECCODE_FOR_ISO;
      RETURN V_EC_CODE;
    ELSE
      RETURN EC_CODE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(1275
                 ,'Unable to fetch ec_code in case of an Internal Order')*/NULL;
      RETURN NULL;
  END CF_EC_CODEFORMULA;

  FUNCTION CF_VENDOR_NAMEFORMULA(VENDOR_ID IN NUMBER
                                ,VENDOR_SITE_ID IN NUMBER
                                ,RECEIPT_ID IN VARCHAR2) RETURN CHAR IS
    CURSOR INT_ORDER_CUR(P_RECEIPT_ID IN VARCHAR2,CP_RECEIPT_SOURCE_CODE IN RCV_SHIPMENT_HEADERS.RECEIPT_SOURCE_CODE%TYPE) IS
      SELECT
        HRU.NAME
      FROM
        RCV_TRANSACTIONS RCVT,
        RCV_SHIPMENT_HEADERS RCVSH,
        HR_ORGANIZATION_UNITS HRU
      WHERE RCVT.TRANSACTION_ID = P_RECEIPT_ID
        AND RCVT.TRANSACTION_TYPE = LV_RCV_TRANSACTION_TYPE
        AND RCVT.SHIPMENT_HEADER_ID = RCVSH.SHIPMENT_HEADER_ID
        AND RCVSH.RECEIPT_SOURCE_CODE = CP_RECEIPT_SOURCE_CODE
        AND RCVSH.ORGANIZATION_ID = HRU.ORGANIZATION_ID;
    CURSOR C_VENDOR_NAME_FOR_ISO IS
      SELECT
        HRU.NAME
      FROM
        JAI_CMN_INVENTORY_ORGS JHRU,
        HR_ALL_ORGANIZATION_UNITS HRU
      WHERE JHRU.ORGANIZATION_ID = ABS(VENDOR_ID)
        AND JHRU.LOCATION_ID = ABS(VENDOR_SITE_ID)
        AND HRU.ORGANIZATION_ID = JHRU.ORGANIZATION_ID;
    CURSOR CUR_GET_VENDOR_NAME(CP_VENDOR_ID IN JAI_CMN_RG_23AC_II_TRXS.VENDOR_ID%TYPE) IS
      SELECT
        POV.VENDOR_NAME
      FROM
        JAI_CMN_RG_23AC_II_TRXS RG23,
        PO_VENDORS POV
      WHERE RG23.VENDOR_ID = POV.VENDOR_ID
        AND RG23.VENDOR_ID = CP_VENDOR_ID;
    V_VENDOR_NAME HR_ORGANIZATION_UNITS.NAME%TYPE;
  BEGIN
    IF VENDOR_ID IS NULL THEN
      OPEN INT_ORDER_CUR(RECEIPT_ID,'INTERNAL ORDER');
      FETCH INT_ORDER_CUR
       INTO V_VENDOR_NAME;
      CLOSE INT_ORDER_CUR;
    ELSIF VENDOR_ID < 0 THEN
      OPEN C_VENDOR_NAME_FOR_ISO;
      FETCH C_VENDOR_NAME_FOR_ISO
       INTO V_VENDOR_NAME;
      CLOSE C_VENDOR_NAME_FOR_ISO;
    ELSE
      OPEN CUR_GET_VENDOR_NAME(CP_VENDOR_ID => VENDOR_ID);
      FETCH CUR_GET_VENDOR_NAME
       INTO V_VENDOR_NAME;
    END IF;
    RETURN V_VENDOR_NAME;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(1275
                 ,'Unable to fetch vendor_name in case of an Internal Order' || SQLERRM)*/NULL;
      RETURN NULL;
  END CF_VENDOR_NAMEFORMULA;

  FUNCTION CF_VENDOR_TYPEFORMULA(VENDOR_ID IN NUMBER
                                ,VENDOR_SITE_ID IN NUMBER
                                ,RECEIPT_ID IN VARCHAR2
                                ,VENDOR_TYPE IN VARCHAR2) RETURN CHAR IS
    CURSOR FOR_INT_SALES_ORDER(P_RECEIPT_ID IN VARCHAR2,CP_RECEIPT_SOURCE_CODE IN RCV_SHIPMENT_HEADERS.RECEIPT_SOURCE_CODE%TYPE) IS
      SELECT
        DECODE('Y'
              ,JHRU.MANUFACTURING
              ,'Manufacturing'
              ,JHRU.TRADING
              ,'Dealer')
      FROM
        JAI_CMN_INVENTORY_ORGS JHRU,
        RCV_TRANSACTIONS RCVT,
        RCV_SHIPMENT_HEADERS RCVSH
      WHERE RCVT.TRANSACTION_ID = P_RECEIPT_ID
        AND RCVT.TRANSACTION_TYPE = LV_RCV_TRANSACTION_TYPE
        AND RCVT.SHIPMENT_HEADER_ID = RCVSH.SHIPMENT_HEADER_ID
        AND RCVSH.RECEIPT_SOURCE_CODE = CP_RECEIPT_SOURCE_CODE
        AND RCVSH.ORGANIZATION_ID = JHRU.ORGANIZATION_ID;
    CURSOR C_FETCH_VENDORTYPE_FOR_ISO IS
      SELECT
        DECODE('Y'
              ,JHRU.MANUFACTURING
              ,'Manufacturing'
              ,JHRU.TRADING
              ,'Dealer')
      FROM
        JAI_CMN_INVENTORY_ORGS JHRU
      WHERE ORGANIZATION_ID = ABS(VENDOR_ID)
        AND LOCATION_ID = ABS(VENDOR_SITE_ID);
    V_VENDOR_TYPE VARCHAR2(80);
  BEGIN
    IF VENDOR_ID IS NULL THEN
      OPEN FOR_INT_SALES_ORDER(RECEIPT_ID,'INTERNAL ORDER');
      FETCH FOR_INT_SALES_ORDER
       INTO V_VENDOR_TYPE;
      CLOSE FOR_INT_SALES_ORDER;
      RETURN V_VENDOR_TYPE;
    ELSIF VENDOR_ID < 0 THEN
      OPEN C_FETCH_VENDORTYPE_FOR_ISO;
      FETCH C_FETCH_VENDORTYPE_FOR_ISO
       INTO V_VENDOR_TYPE;
      CLOSE C_FETCH_VENDORTYPE_FOR_ISO;
      RETURN V_VENDOR_TYPE;
    ELSE
      RETURN VENDOR_TYPE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(1275
                 ,'Unable to fetch vendor_type in case of an Internal Sales Order' || SQLERRM)*/NULL;
      RETURN NULL;
  END CF_VENDOR_TYPEFORMULA;

  FUNCTION CF_QTYFORMULA(RECEIPT_ID IN VARCHAR2
                        ,REGISTER_ID IN NUMBER) RETURN NUMBER IS
    V_QTY NUMBER := 0;
    LN_RECEIVE_TRX_ID NUMBER;
    CURSOR C_TRX_DTL(P_TRANSACTION_ID IN NUMBER) IS
      SELECT
        TRANSACTION_TYPE,
        TRANSACTION_ID,
        SHIPMENT_LINE_ID
      FROM
        RCV_TRANSACTIONS
      WHERE TRANSACTION_ID = P_TRANSACTION_ID;
    R_TRX_DTL C_TRX_DTL%ROWTYPE;
  BEGIN
    IF RECEIPT_ID IS NOT NULL THEN
      OPEN C_TRX_DTL(RECEIPT_ID);
      FETCH C_TRX_DTL
       INTO R_TRX_DTL;
      CLOSE C_TRX_DTL;
      IF R_TRX_DTL.TRANSACTION_TYPE = 'RECEIVE' THEN
        LN_RECEIVE_TRX_ID := TO_NUMBER(RECEIPT_ID);
      ELSE
        LN_RECEIVE_TRX_ID := JAI_RCV_TRX_PROCESSING_PKG.GET_ANCESTOR_ID(P_TRANSACTION_ID => R_TRX_DTL.TRANSACTION_ID
                                                                       ,P_SHIPMENT_LINE_ID => R_TRX_DTL.SHIPMENT_LINE_ID
                                                                       ,P_REQUIRED_TRX_TYPE => 'RECEIVE');
      END IF;
      FOR qty_rec IN (SELECT
                        PRIMARY_QUANTITY
                      FROM
                        RCV_TRANSACTIONS
                      WHERE TRANSACTION_ID = LN_RECEIVE_TRX_ID
                      OR ( TRANSACTION_TYPE = LV_CRCT_TRANSACTION
                        AND PARENT_TRANSACTION_ID = LN_RECEIVE_TRX_ID )) LOOP
        V_QTY := V_QTY + QTY_REC.PRIMARY_QUANTITY;
      END LOOP;
    ELSE
      FOR qty_rec IN (SELECT
                        ( CLOSING_BALANCE_QTY - OPENING_BALANCE_QTY ) QTY
                      FROM
                        JAI_CMN_RG_23AC_I_TRXS
                      WHERE REGISTER_ID_PART_II = CF_QTYFORMULA.REGISTER_ID) LOOP
        V_QTY := QTY_REC.QTY;
      END LOOP;
    END IF;
    RETURN (V_QTY);
  END CF_QTYFORMULA;

  FUNCTION CF_POP_COUNTFORMULA RETURN NUMBER IS
  BEGIN
    CP_QUERY_COUNT := CP_QUERY_COUNT + 1;
    RETURN (CP_QUERY_COUNT);
  END CF_POP_COUNTFORMULA;

  FUNCTION CF_ROUNDED_CENVAT_AMTFORMULA(EXCISE_INVOICE_NO IN VARCHAR2
                                       ,EXCISE_INVOICE_DATE IN DATE
                                       ,CENVAT IN NUMBER) RETURN NUMBER IS
    CURSOR C_CHK_PARENT_INCLUDED(P_REGISTER_ID IN NUMBER) IS
      SELECT
        COUNT(1)
      FROM
        JAI_CMN_RG_23AC_II_TRXS A
      WHERE A.ORGANIZATION_ID = P_ORGANIZATION_ID
        AND A.LOCATION_ID = P_LOCATION_ID
        AND REGISTER_TYPE = P_REGISTER_TYPE
        AND A.INVENTORY_ITEM_ID <> 0
        AND REGISTER_ID = P_REGISTER_ID
        AND TRUNC(A.CREATION_DATE) BETWEEN NVL(P_TRN_FROM_DATE
         ,TRUNC(A.CREATION_DATE))
        AND NVL(P_TRN_TO_DATE
         ,TRUNC(SYSDATE));
    CURSOR CUR_SH_EDU_CESS_RND_AMT(CP_REG_ID IN NUMBER) IS
      SELECT
        NVL(SUM(CREDIT)
           ,0) - NVL(SUM(DEBIT)
           ,0)
      FROM
        JAI_CMN_RG_OTHERS
      WHERE SOURCE_REGISTER_ID = CP_REG_ID
        AND SOURCE_TYPE = 1
        AND TAX_TYPE IN ( 'EXCISE_SH_EDU_CESS' , 'CVD_SH_EDU_CESS' );
    CURSOR CUR_EDU_CESS_RND_AMT(CP_REG_ID IN NUMBER) IS
      SELECT
        NVL(SUM(CREDIT)
           ,0) - NVL(SUM(DEBIT)
           ,0)
      FROM
        JAI_CMN_RG_OTHERS
      WHERE SOURCE_REGISTER_ID = CP_REG_ID
        AND SOURCE_TYPE = 1
        AND TAX_TYPE IN ( LV_TAX_TYPE_EXC_EDU_CESS , LV_TAX_TYPE_CVD_EDU_CESS );
    V_ROUND_AMOUNT JAI_CMN_RG_23AC_II_TRXS.CR_BASIC_ED%TYPE := 0;
    V_RND_ENTRY_CNT NUMBER;
    V_PARENT_REGISTER_ID NUMBER;
    V_PARENT_INCLUDED_CNT NUMBER;
    V_TOT_CENVAT_ROUND_AMOUNT NUMBER := 0;
    LV_TOT_SED_ROUND_AMT NUMBER := 0;
    LV_TOT_ADDL_ROUND_AMT NUMBER := 0;
    LV_TOT_EDU_ROUND_AMT NUMBER := 0;
    LV_EDU_ROUND_AMT NUMBER := 0;
    LV_TOT_ADDLCVD_ROUND_AMT NUMBER := 0;
    LV_SH_TOT_EDU_ROUND_AMT NUMBER;
    LV_SH_EDU_ROUND_AMT NUMBER;
  BEGIN
    LV_SH_TOT_EDU_ROUND_AMT := 0;
    LV_SH_EDU_ROUND_AMT := 0;
    FOR rnd_rec IN (SELECT
                      REGISTER_ID,
                      NVL(CR_BASIC_ED
                         ,0) - NVL(DR_BASIC_ED
                         ,0) CENVAT_AMT,
                      NVL(CR_OTHER_ED
                         ,0) - NVL(DR_OTHER_ED
                         ,0) SED_AMT,
                      NVL(CR_ADDITIONAL_ED
                         ,0) - NVL(DR_ADDITIONAL_ED
                         ,0) ADDL_AMT,
                      NVL(CR_ADDITIONAL_CVD
                         ,0) - NVL(DR_ADDITIONAL_CVD
                         ,0) ADDLCVD_AMT
                    FROM
                      JAI_CMN_RG_23AC_II_TRXS
                    WHERE EXCISE_INVOICE_NO = cf_rounded_cenvat_amtformula.EXCISE_INVOICE_NO
                      AND EXCISE_INVOICE_DATE = cf_rounded_cenvat_amtformula.EXCISE_INVOICE_DATE
                      AND INVENTORY_ITEM_ID = 0
                      AND TRANSACTION_SOURCE_NUM = 18
                      AND REGISTER_TYPE = P_REGISTER_TYPE) LOOP
      V_PARENT_INCLUDED_CNT := 0;
      V_PARENT_REGISTER_ID := JAI_RCV_RND_PKG.GET_PARENT_REGISTER_ID(RND_REC.REGISTER_ID);
      OPEN C_CHK_PARENT_INCLUDED(V_PARENT_REGISTER_ID);
      FETCH C_CHK_PARENT_INCLUDED
       INTO V_PARENT_INCLUDED_CNT;
      CLOSE C_CHK_PARENT_INCLUDED;
      IF V_PARENT_INCLUDED_CNT > 0 THEN
        V_TOT_CENVAT_ROUND_AMOUNT := V_TOT_CENVAT_ROUND_AMOUNT + RND_REC.CENVAT_AMT;
        LV_TOT_SED_ROUND_AMT := LV_TOT_SED_ROUND_AMT + RND_REC.SED_AMT;
        LV_TOT_ADDL_ROUND_AMT := LV_TOT_ADDL_ROUND_AMT + RND_REC.ADDL_AMT;
        LV_TOT_ADDLCVD_ROUND_AMT := LV_TOT_ADDLCVD_ROUND_AMT + RND_REC.ADDLCVD_AMT;
        OPEN CUR_EDU_CESS_RND_AMT(RND_REC.REGISTER_ID);
        FETCH CUR_EDU_CESS_RND_AMT
         INTO LV_EDU_ROUND_AMT;
        CLOSE CUR_EDU_CESS_RND_AMT;
        LV_TOT_EDU_ROUND_AMT := LV_TOT_EDU_ROUND_AMT + LV_EDU_ROUND_AMT;
        OPEN CUR_SH_EDU_CESS_RND_AMT(RND_REC.REGISTER_ID);
        FETCH CUR_SH_EDU_CESS_RND_AMT
         INTO LV_SH_EDU_ROUND_AMT;
        CLOSE CUR_SH_EDU_CESS_RND_AMT;
        LV_SH_TOT_EDU_ROUND_AMT := LV_SH_TOT_EDU_ROUND_AMT + LV_SH_EDU_ROUND_AMT;
      END IF;
      /*SRW.MESSAGE('1000'
                 ,'MCEN Rounding Amount for Excise In No: ' || EXCISE_INVOICE_NO || ' is = ' || V_TOT_CENVAT_ROUND_AMOUNT || ' Edu : ' || LV_TOT_EDU_ROUND_AMT || ' SED : ' || LV_TOT_SED_ROUND_AMT || ' Addl : ' || LV_TOT_ADDL_ROUND_AMT)*/NULL;
    END LOOP;
    CP_SED := LV_TOT_SED_ROUND_AMT;
    CP_ADDL := LV_TOT_ADDL_ROUND_AMT;
    CP_EDU := LV_TOT_EDU_ROUND_AMT;
    CP_ADDLCVD := LV_TOT_ADDLCVD_ROUND_AMT;
    CP_SH_EDU := LV_TOT_EDU_ROUND_AMT;
    RETURN (CENVAT + V_TOT_CENVAT_ROUND_AMOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('1001'
                 ,'Error In Rounding Calc')*/NULL;
      RETURN 0;
  END CF_ROUNDED_CENVAT_AMTFORMULA;

  FUNCTION CF_EDUCATION_CESSFORMULA(EXCISE_INVOICE_NO2 IN VARCHAR2
                                   ,EXCISE_INVOICE_DATE2 IN DATE
                                   ,REGISTER_ID IN NUMBER) RETURN NUMBER IS
    LN_EDUCATION_CESS NUMBER := 0;
    LV_SOURCE_REGISTER_TYPE JAI_CMN_RG_OTHERS.SOURCE_REGISTER%TYPE;
    CURSOR CUR_EDUCATION_CESS IS
      SELECT
        SUM(NVL(CREDIT
               ,DEBIT))
      FROM
        JAI_CMN_RG_OTHERS
      WHERE SOURCE_REGISTER_ID IN (
        SELECT
          RG23.REGISTER_ID
        FROM
          JAI_CMN_RG_23AC_II_TRXS RG23,
          JAI_CMN_VENDOR_SITES VSITE,
          MTL_SYSTEM_ITEMS MSI,
          JAI_INV_ITM_SETUPS JA_MSI
        WHERE RG23.REGISTER_TYPE = P_REGISTER_TYPE
          AND RG23.OPENING_BALANCE < RG23.CLOSING_BALANCE
          AND RG23.ORGANIZATION_ID = P_ORGANIZATION_ID
          AND RG23.LOCATION_ID = P_LOCATION_ID
          AND RG23.VENDOR_ID = vsite.vendor_id (+)
          AND RG23.VENDOR_SITE_ID = vsite.vendor_site_id (+)
          AND RG23.ORGANIZATION_ID = MSI.ORGANIZATION_ID
          AND RG23.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
          AND RG23.ORGANIZATION_ID = JA_MSI.ORGANIZATION_ID
          AND RG23.INVENTORY_ITEM_ID = JA_MSI.INVENTORY_ITEM_ID
          AND TRUNC(RG23.CREATION_DATE) BETWEEN NVL(P_TRN_FROM_DATE
           ,TRUNC(RG23.CREATION_DATE))
          AND NVL(P_TRN_TO_DATE
           ,TRUNC(SYSDATE))
          AND NVL(RG23.INVENTORY_ITEM_ID
           ,-1) <> 0
          AND NVL(RG23.ROUNDING_ID
           ,9999) <> - 1
          AND RG23.EXCISE_INVOICE_NO = EXCISE_INVOICE_NO2
          AND RG23.EXCISE_INVOICE_DATE = EXCISE_INVOICE_DATE2 )
        AND SOURCE_REGISTER = LV_SOURCE_REGISTER_TYPE
        AND TAX_TYPE IN ( LV_TAX_TYPE_EXC_EDU_CESS , LV_TAX_TYPE_CVD_EDU_CESS );
  BEGIN
    IF P_REGISTER_TYPE = 'A' THEN
      LV_SOURCE_REGISTER_TYPE := 'RG23A_P2';
    ELSIF P_REGISTER_TYPE = 'C' THEN
      LV_SOURCE_REGISTER_TYPE := 'RG23C_P2';
    END IF;
    IF REGISTER_ID IS NOT NULL THEN
      OPEN CUR_EDUCATION_CESS;
      FETCH CUR_EDUCATION_CESS
       INTO LN_EDUCATION_CESS;
      CLOSE CUR_EDUCATION_CESS;
    END IF;
    /*SRW.MESSAGE('1000'
               ,'Edu cess:' || LN_EDUCATION_CESS || ' Rnd Cess:' || CP_EDU)*/NULL;
    RETURN (NVL(LN_EDUCATION_CESS
              ,0) + NVL(CP_EDU
              ,0));
  END CF_EDUCATION_CESSFORMULA;

  FUNCTION CF_SEDFORMULA(SED IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(SED
              ,0) + NVL(CP_SED
              ,0));
  END CF_SEDFORMULA;

  FUNCTION CF_ADDLFORMULA(ADDITIONAL_DUTY IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(ADDITIONAL_DUTY
              ,0) + NVL(CP_ADDL
              ,0));
  END CF_ADDLFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_ADDLCVDFORMULA(ADDITIONAL_CVD IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(ADDITIONAL_CVD
              ,0) + NVL(CP_ADDLCVD
              ,0));
  END CF_ADDLCVDFORMULA;

  FUNCTION CF_SH_EDUCATION_CESSFORMULA(EXCISE_INVOICE_NO IN VARCHAR2
                                      ,EXCISE_INVOICE_DATE IN DATE
                                      ,REGISTER_ID IN NUMBER) RETURN NUMBER IS
    LN_SH_EDUCATION_CESS NUMBER := 0;
    CURSOR CUR_SH_EDUCATION_CESS IS
      SELECT
        SUM(NVL(CREDIT
               ,-DEBIT))
      FROM
        JAI_CMN_RG_OTHERS
      WHERE SOURCE_REGISTER_ID IN (
        SELECT
          REGISTER_ID
        FROM
          JAI_CMN_RG_23AC_II_TRXS
        WHERE EXCISE_INVOICE_NO = cf_sh_education_cessformula.EXCISE_INVOICE_NO
          AND EXCISE_INVOICE_DATE = cf_sh_education_cessformula.EXCISE_INVOICE_DATE
          AND REGISTER_TYPE = P_REGISTER_TYPE
          AND ORGANIZATION_ID = P_ORGANIZATION_ID
          AND LOCATION_ID = P_LOCATION_ID
          AND TRUNC(CREATION_DATE) BETWEEN NVL(P_TRN_FROM_DATE
           ,TRUNC(CREATION_DATE))
          AND NVL(P_TRN_TO_DATE
           ,TRUNC(SYSDATE)) )
        AND SOURCE_REGISTER = DECODE(P_REGISTER_TYPE
            ,'A'
            ,'RG23A_P2'
            ,'C'
            ,'RG23C_P2')
        AND TAX_TYPE IN ( 'EXCISE_SH_EDU_CESS' , 'CVD_SH_EDU_CESS' );
  BEGIN
    IF REGISTER_ID IS NOT NULL THEN
      OPEN CUR_SH_EDUCATION_CESS;
      FETCH CUR_SH_EDUCATION_CESS
       INTO LN_SH_EDUCATION_CESS;
      CLOSE CUR_SH_EDUCATION_CESS;
    END IF;
    /*SRW.MESSAGE('1000'
               ,'SH Edu cess:' || LN_SH_EDUCATION_CESS || ' Rnd Cess:' || CP_SH_EDU)*/NULL;
    RETURN (NVL(LN_SH_EDUCATION_CESS
              ,0) + NVL(CP_SH_EDU
              ,0));
  END CF_SH_EDUCATION_CESSFORMULA;

  FUNCTION CP_SH_EDU_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SH_EDU;
  END CP_SH_EDU_P;

  FUNCTION CP_EDU_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EDU;
  END CP_EDU_P;

  FUNCTION CP_ADDLCVD_P RETURN NUMBER IS
  BEGIN
    RETURN CP_ADDLCVD;
  END CP_ADDLCVD_P;

  FUNCTION CP_ADDL_P RETURN NUMBER IS
  BEGIN
    RETURN CP_ADDL;
  END CP_ADDL_P;

  FUNCTION CP_SED_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SED;
  END CP_SED_P;

  FUNCTION CP_REPORT_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REPORT_TITLE;
  END CP_REPORT_TITLE_P;

  FUNCTION CP_QUERY_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN CP_QUERY_COUNT;
  END CP_QUERY_COUNT_P;

END JA_JAINMCEN_XMLP_PKG;




/
