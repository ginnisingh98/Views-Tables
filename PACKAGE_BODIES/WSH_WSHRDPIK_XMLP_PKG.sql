--------------------------------------------------------
--  DDL for Package Body WSH_WSHRDPIK_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_WSHRDPIK_XMLP_PKG" AS
/* $Header: WSHRDPIKB.pls 120.2.12010000.3 2010/04/19 09:43:09 anvarshn ship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    CURSOR MAP_YES_NO(T IN VARCHAR2) IS
      SELECT
        MEANING
      FROM
        OE_LOOKUPS
      WHERE LOOKUP_CODE = T
        AND LOOKUP_TYPE = 'YES_NO'
        AND TRUNC(SYSDATE) BETWEEN NVL(START_DATE_ACTIVE
         ,TRUNC(SYSDATE))
        AND NVL(END_DATE_ACTIVE
         ,TRUNC(SYSDATE));
    CURSOR STRUCT_NUM(FLEX_CODE IN VARCHAR2) IS
      SELECT
        ID_FLEX_NUM
      FROM
        FND_ID_FLEX_STRUCTURES
      WHERE ID_FLEX_CODE = FLEX_CODE;
    CLAUSE VARCHAR2(300);
    VALUE VARCHAR2(300);
    STRUCT_NUMBER NUMBER;
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1000
                   ,'Failed in After Form trigger')*/NULL;
        RETURN (FALSE);
    END;
    IF (P_MOVE_ORDER_LOW IS NOT NULL AND P_MOVE_ORDER_HIGH IS NOT NULL) THEN
      IF (P_MOVE_ORDER_LOW = P_MOVE_ORDER_HIGH) THEN
        LP_MO_CLAUSE := 'and mtrh.request_number = :p_move_order_high';
      ELSE
        LP_MO_CLAUSE := 'and mtrh.request_number between :p_move_order_low and :p_move_order_high';
      END IF;
    ELSIF (P_MOVE_ORDER_LOW IS NULL AND P_MOVE_ORDER_HIGH IS NOT NULL) THEN
      LP_MO_CLAUSE := 'and mtrh.request_number <= :p_move_order_high';
    ELSIF (P_MOVE_ORDER_LOW IS NOT NULL AND P_MOVE_ORDER_HIGH IS NULL) THEN
      LP_MO_CLAUSE := 'and mtrh.request_number >= :p_move_order_low';
    END IF;
    IF P_ITEM_DISPLAY = 'D' THEN
      LP_ITEM_DISPLAY_VALUE := 'decode(wdd.inventory_item_id,NULL,wdd.item_description, msitl.description)';
    ELSE
      LP_ITEM_DISPLAY_VALUE := 'to_char(wdd.inventory_item_id)';
    END IF;
    IF (P_PICK_SLIP_NUM_LOW IS NOT NULL AND P_PICK_SLIP_NUM_HIGH IS NOT NULL) THEN
      IF (P_PICK_SLIP_NUM_LOW = P_PICK_SLIP_NUM_HIGH) THEN
        LP_PICK_SLIP_NUM := 'and wpsv.pick_slip_number = :p_pick_slip_num_high';
        LP_PICK_SLIP_NUM_MMT := 'and mmt.pick_slip_number = :p_pick_slip_num_high';
        LP_PICK_SLIP_NUM_MTRL := 'and mtrl.pick_slip_number = :p_pick_slip_num_high';
      ELSE
        LP_PICK_SLIP_NUM := 'and (wpsv.pick_slip_number between :p_pick_slip_num_low and :p_pick_slip_num_high)';
        LP_PICK_SLIP_NUM_MMT := 'and (mmt.pick_slip_number between :p_pick_slip_num_low and :p_pick_slip_num_high)';
        LP_PICK_SLIP_NUM_MTRL := 'and (mtrl.pick_slip_number between :p_pick_slip_num_low and :p_pick_slip_num_high)';
      END IF;
    ELSIF (P_PICK_SLIP_NUM_LOW IS NULL AND P_PICK_SLIP_NUM_HIGH IS NOT NULL) THEN
      LP_PICK_SLIP_NUM := 'and wpsv.pick_slip_number <= :p_pick_slip_num_high';
      LP_PICK_SLIP_NUM_MMT := 'and mmt.pick_slip_number <= :p_pick_slip_num_high';
      LP_PICK_SLIP_NUM_MTRL := 'and mtrl.pick_slip_number <= :p_pick_slip_num_high';
    ELSIF (P_PICK_SLIP_NUM_LOW IS NOT NULL AND P_PICK_SLIP_NUM_HIGH IS NULL) THEN
      LP_PICK_SLIP_NUM := 'and wpsv.pick_slip_number >= :p_pick_slip_num_low';
      LP_PICK_SLIP_NUM_MMT := 'and mmt.pick_slip_number >= :p_pick_slip_num_low';
      LP_PICK_SLIP_NUM_MTRL := 'and mtrl.pick_slip_number >= :p_pick_slip_num_low';
    END IF;
    IF (P_ORDER_NUM_HIGH IS NOT NULL AND P_ORDER_NUM_LOW IS NOT NULL) THEN
      IF (P_ORDER_NUM_HIGH = P_ORDER_NUM_LOW) THEN
        LP_ORDER_NUM := ' and wdd.source_header_number = :p_order_num_low';
      ELSE --Bug9508781
        LP_ORDER_NUM := ' and wdd.source_header_number >= :p_order_num_low and wdd.source_header_number <=  :p_order_num_high';
      END IF;
    ELSIF (P_ORDER_NUM_LOW IS NOT NULL) THEN
      LP_ORDER_NUM := ' and wdd.source_header_number >= :p_order_num_low';
    ELSIF (P_ORDER_NUM_HIGH IS NOT NULL) THEN
      LP_ORDER_NUM := ' and wdd.source_header_number <=  :p_order_num_high ';
    END IF;
    IF P_ORDER_TYPE_ID IS NOT NULL THEN
      LP_ORDER_TYPE := ' AND  wdd.source_header_type_id  = :p_order_type_id ';
    END IF;
    IF LP_DETAIL_DATE_HIGH IS NOT NULL THEN
      LP_DETAIL_DATE_HIGH := LP_DETAIL_DATE_HIGH + (86399 / 86400);
    END IF;
    IF (P_DETAIL_DATE_LOW IS NOT NULL AND LP_DETAIL_DATE_HIGH IS NOT NULL) THEN
      LP_DETAIL_DATE_MMT := 'and (mmt.transaction_date between :p_detail_date_low and :lp_detail_date_high)';
      LP_DETAIL_DATE_MTRL := 'and (mtrl.pick_slip_date between :p_detail_date_low and :lp_detail_date_high)';
      LP_DETAIL_DATE_UNPICK := 'and (wpsv.creation_date between :p_detail_date_low and :lp_detail_date_high)';
    ELSIF (P_DETAIL_DATE_LOW IS NULL AND LP_DETAIL_DATE_HIGH IS NOT NULL) THEN
      LP_DETAIL_DATE_MMT := 'and mmt.transaction_date <= :lp_detail_date_high';
      LP_DETAIL_DATE_MTRL := 'and mtrl.pick_slip_date <= :lp_detail_date_high';
      LP_DETAIL_DATE_UNPICK := 'and wpsv.creation_date <= :lp_detail_date_high';
    ELSIF (P_DETAIL_DATE_LOW IS NOT NULL AND P_DETAIL_DATE_HIGH IS NULL) THEN
      LP_DETAIL_DATE_MMT := 'and mmt.transaction_date >= :p_detail_date_low';
      LP_DETAIL_DATE_MTRL := 'and mtrl.pick_slip_date >= :p_detail_date_low';
      LP_DETAIL_DATE_UNPICK := 'and wpsv.creation_date >= :p_detail_date_low';
    END IF;
    IF (P_CUSTOMER_ID IS NOT NULL) THEN
      LP_CUSTOMER_ID := 'and wdd.customer_id = :p_customer_id';
    END IF;
    IF (P_FREIGHT_CODE IS NOT NULL) THEN
      LP_SHIP_METHOD_CODE := 'and wdd.ship_method_code = :p_freight_code';
    END IF;
    LP_PICK_STATUS := ' ';
    LP_PICK_STATUS_UNPICK := ' ';
    IF P_PICK_STATUS <> 'A' THEN
      IF P_PICK_STATUS = 'U' THEN
        P_PICK_STATUS_VALUE := 'UNPICKED';
        LP_PICK_STATUS := 'and 1 <> 1';
      ELSIF P_PICK_STATUS = 'P' THEN
        P_PICK_STATUS_VALUE := 'PICKED';
        LP_PICK_STATUS_UNPICK := 'and 1 <> 1';
      END IF;
    END IF;
    IF P_ORGANIZATION_ID IS NOT NULL THEN
      LP_WAREHOUSE_CLAUSE := 'AND mtrl.organization_id = :p_organization_id';
    END IF;
    IF P_PRINTER_NAME = '-1' THEN
      LP_PRINTER_NAME := 'and wpsv.subinventory_code not in
                                     ( Select subinventory from wsh_report_printers wrp
                                       where wrp.level_type_id = :P_LEVEL_TYPE_ID1
                                       and   wrp.enabled_flag = :P_ENABLED_FLAG
                                       and   wrp.CONCURRENT_PROGRAM_ID =  (
                                                 select concurrent_program_id from
                                                 fnd_concurrent_programs_vl
                                                 where concurrent_program_name = :P_CONCURRENT_PROGRAM_NAME
                                                 and application_id = :P_APPLICATION_ID
                                                 and rownum = 1 )
                                       and wrp.organization_id = wdd.organization_id  )
                                    and wdd.organization_id  not in
                                     ( Select wrp.level_value_id from wsh_report_printers wrp
                                       where  wrp.level_type_id = :P_LEVEL_TYPE_ID2
                                       and wrp.enabled_flag = :P_ENABLED_FLAG
                                       and   wrp.CONCURRENT_PROGRAM_ID =  (
                                                 select concurrent_program_id from
                                                 fnd_concurrent_programs_vl
                                                 where concurrent_program_name = :P_CONCURRENT_PROGRAM_NAME
                                                 and application_id = :P_APPLICATION_ID
                                                 and rownum = 1 ) )  ';
    ELSIF P_PRINTER_NAME IS NOT NULL THEN
      LP_PRINTER_NAME := 'and  ( wpsv.subinventory_code  in
                                      ( Select wrp.subinventory from wsh_report_printers wrp
                                       where wrp.level_type_id = :P_LEVEL_TYPE_ID1
                                       and   wrp.enabled_flag = :P_ENABLED_FLAG
                                       and   wrp.CONCURRENT_PROGRAM_ID = (
                                                 select concurrent_program_id from
                                                 fnd_concurrent_programs_vl
                                                 where concurrent_program_name = :P_CONCURRENT_PROGRAM_NAME
                                                 and application_id = :P_APPLICATION_ID
                                                 and rownum = 1 )
                                        and wrp.organization_id = wdd.organization_id
                                        and wrp.printer_name =  :p_printer_name  )
                                   or (wdd.organization_id   in
                                        ( Select wrp.level_value_id from wsh_report_printers wrp
                                          where wrp.level_type_id = :P_LEVEL_TYPE_ID2
                                          and wrp.enabled_flag = :P_ENABLED_FLAG
                                          and   wrp.printer_name = :p_printer_name
                                          and   wrp.CONCURRENT_PROGRAM_ID = (
                                                 select concurrent_program_id from
                                                 fnd_concurrent_programs_vl
                                                 where concurrent_program_name = :P_CONCURRENT_PROGRAM_NAME
                                                 and application_id = :P_APPLICATION_ID
                                                 and rownum = 1 )  )
                                        and wpsv.subinventory_code not in
                                            ( select wrp.subinventory
                                              from wsh_Report_printers wrp
                                              where wrp.level_type_id = :P_LEVEL_TYPE_ID1
                                              and   wrp.enabled_flag = :P_ENABLED_FLAG
                                              and   wrp.CONCURRENT_PROGRAM_ID =(
                                                       select concurrent_program_id from
                                                       fnd_concurrent_programs_vl
                                                       where concurrent_program_name = :P_CONCURRENT_PROGRAM_NAME
                                                       and application_id = :P_APPLICATION_ID
                                                       and rownum = 1 )
                                              and  wrp.organization_id = wdd.organization_id  )))' ; --bug 9278128
    END IF;
    OPEN MAP_YES_NO('Y');
    FETCH MAP_YES_NO
     INTO LP_YES;
    CLOSE MAP_YES_NO;
    OPEN MAP_YES_NO('N');
    FETCH MAP_YES_NO
     INTO LP_NO;
    CLOSE MAP_YES_NO;
    OPEN STRUCT_NUM(P_ITEM_FLEX_CODE);
    FETCH STRUCT_NUM
     INTO STRUCT_NUMBER;
    CLOSE STRUCT_NUM;
    LP_STRUCTURE_NUM := STRUCT_NUMBER;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF MAP_YES_NO%ISOPEN THEN
        CLOSE MAP_YES_NO;
      END IF;
      RETURN FALSE;
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in SRWEXIT')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
	LP_DETAIL_DATE_HIGH := P_DETAIL_DATE_HIGH;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed FND SRWINIT.')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION F_LOT_QUANTITYFORMULA(DELIVERY_DETAIL_ID3 IN NUMBER
                                ,LOT_TXN_ID IN NUMBER
                                ,LOT_NUMBER1 IN VARCHAR2) RETURN NUMBER IS
    LOT_QTY NUMBER := NULL;
  BEGIN
    IF DELIVERY_DETAIL_ID3 = -99 THEN
      BEGIN
        SELECT
          SUM(ABS(TRANSACTION_QUANTITY))
        INTO LOT_QTY
        FROM
          MTL_TRANSACTION_LOT_NUMBERS
        WHERE TRANSACTION_ID = LOT_TXN_ID
          AND LOT_NUMBER = LOT_NUMBER1
        GROUP BY
          TRANSACTION_ID,
          LOT_NUMBER;
        RETURN (LOT_QTY);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN
            SELECT
              SUM(ABS(TRANSACTION_QUANTITY))
            INTO LOT_QTY
            FROM
              MTL_TRANSACTION_LOTS_TEMP
            WHERE TRANSACTION_TEMP_ID = LOT_TXN_ID
              AND LOT_NUMBER = LOT_NUMBER1
            GROUP BY
              TRANSACTION_TEMP_ID,
              LOT_NUMBER;
            RETURN (LOT_QTY);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              BEGIN
                SELECT
                  SUM(ABS(TRANSACTION_QUANTITY))
                INTO LOT_QTY
                FROM
                  MTL_MATERIAL_TRANSACTIONS_TEMP
                WHERE TRANSACTION_TEMP_ID = LOT_TXN_ID
                  AND ( REVISION IS NOT NULL
                OR LOCATOR_ID IS NOT NULL )
                GROUP BY
                  TRANSACTION_TEMP_ID;
                RETURN (LOT_QTY);
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  RETURN (NULL);
              END;
          END;
      END;
    ELSE
      SELECT
        REQUESTED_QUANTITY
      INTO LOT_QTY
      FROM
        WSH_DELIVERY_DETAILS
      WHERE DELIVERY_DETAIL_ID = DELIVERY_DETAIL_ID3;
    END IF;
    RETURN LOT_QTY;
  END F_LOT_QUANTITYFORMULA;

  FUNCTION G_TRANSACTION_TEMP_IDGROUPFILT(ORGANIZATION_ID IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    IF WSH_UTIL_VALIDATE.CHECK_WMS_ORG(ORGANIZATION_ID) = 'Y' THEN
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;
  END G_TRANSACTION_TEMP_IDGROUPFILT;

  FUNCTION F_FROM_LOCATIONFORMULA(FROM_LOCATOR_ID IN NUMBER
                                 ,ORGANIZATION_ID IN NUMBER) RETURN CHAR IS
    NAME VARCHAR(2000) := NULL;
    RESULT BOOLEAN := TRUE;
  BEGIN
    IF FROM_LOCATOR_ID IS NULL THEN
      RETURN '';
    END IF;
    RESULT := FND_FLEX_KEYVAL.VALIDATE_CCID(APPL_SHORT_NAME => 'INV'
                                           ,KEY_FLEX_CODE => P_LOCATOR_FLEX_CODE
                                           ,STRUCTURE_NUMBER => LP_STRUCTURE_NUM
                                           ,COMBINATION_ID => FROM_LOCATOR_ID
                                           ,DATA_SET => ORGANIZATION_ID);
    IF RESULT THEN
      NAME := FND_FLEX_KEYVAL.CONCATENATED_VALUES;
    END IF;
    RETURN NAME;
  END F_FROM_LOCATIONFORMULA;

  FUNCTION F_ITEM_DESCRIPTIONFORMULA(ITEM_INFO IN VARCHAR2
                                    ,INVENTORY_ITEM_ID IN NUMBER
                                    ,ORGANIZATION_ID IN NUMBER
                                    ,ITEM_DESCRIPTION IN VARCHAR2) RETURN CHAR IS
    NAME VARCHAR(2000) := NULL;
  BEGIN
    IF P_ITEM_DISPLAY = 'D' THEN
      RETURN ITEM_INFO;
    END IF;
    IF P_ITEM_DISPLAY = 'F' THEN
      NAME := WSH_UTIL_CORE.GET_ITEM_NAME(INVENTORY_ITEM_ID
                                         ,ORGANIZATION_ID
                                         ,P_ITEM_FLEX_CODE
                                         ,LP_STRUCTURE_NUM);
      RETURN NAME;
    ELSE
      NAME := WSH_UTIL_CORE.GET_ITEM_NAME(INVENTORY_ITEM_ID
                                         ,ORGANIZATION_ID
                                         ,P_ITEM_FLEX_CODE
                                         ,LP_STRUCTURE_NUM);
      RETURN NAME || '     ' || ITEM_DESCRIPTION;
    END IF;
  END F_ITEM_DESCRIPTIONFORMULA;

  FUNCTION F_REQUESTED_QUANTITYFORMULA(SOURCE_HEADER_ID1 IN NUMBER
                                      ,SOURCE_LINE_ID1 IN NUMBER
                                      ,MOVE_ORDER_LINE_ID1 IN NUMBER) RETURN NUMBER IS
    REQ_QTY NUMBER;
  BEGIN
    SELECT
      SUM(REQUESTED_QUANTITY)
    INTO REQ_QTY
    FROM
      WSH_DELIVERY_DETAILS
    WHERE SOURCE_HEADER_ID = SOURCE_HEADER_ID1
      AND SOURCE_LINE_ID = SOURCE_LINE_ID1
      AND MOVE_ORDER_LINE_ID = MOVE_ORDER_LINE_ID1
      AND NVL(LINE_DIRECTION
       ,'O') IN ( 'O' , 'IO' )
      AND CONTAINER_FLAG in ( 'Y' , 'N' );
    RETURN (REQ_QTY);
  END F_REQUESTED_QUANTITYFORMULA;

  FUNCTION F_SHIPPED_QUANTITYFORMULA RETURN NUMBER IS
    SHP_QTY NUMBER := NULL;
  BEGIN
    RETURN (SHP_QTY);
  END F_SHIPPED_QUANTITYFORMULA;

  FUNCTION F_TO_LOCATIONFORMULA(TO_LOCATOR_ID IN NUMBER
                               ,ORGANIZATION_ID IN NUMBER) RETURN CHAR IS
    NAME VARCHAR(2000) := NULL;
    RESULT BOOLEAN := TRUE;
  BEGIN
    IF TO_LOCATOR_ID IS NULL THEN
      RETURN '';
    END IF;
    RESULT := FND_FLEX_KEYVAL.VALIDATE_CCID(APPL_SHORT_NAME => 'INV'
                                           ,KEY_FLEX_CODE => P_LOCATOR_FLEX_CODE
                                           ,STRUCTURE_NUMBER => LP_STRUCTURE_NUM
                                           ,COMBINATION_ID => TO_LOCATOR_ID
                                           ,DATA_SET => ORGANIZATION_ID);
    IF RESULT THEN
      NAME := FND_FLEX_KEYVAL.CONCATENATED_VALUES;
    END IF;
    RETURN NAME;
  END F_TO_LOCATIONFORMULA;

  FUNCTION CF_REVISIONFORMULA(TRANSACTION_ID1 IN NUMBER) RETURN CHAR IS
    REVISION MTL_ITEM_REVISIONS.REVISION%TYPE;
  BEGIN
    REVISION := ' ';
    BEGIN
      SELECT
        REVISION
      INTO REVISION
      FROM
        MTL_MATERIAL_TRANSACTIONS_TEMP
      WHERE TRANSACTION_TEMP_ID = TRANSACTION_ID1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT
            REVISION
          INTO REVISION
          FROM
            MTL_MATERIAL_TRANSACTIONS
          WHERE TRANSACTION_ID = TRANSACTION_ID1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            REVISION := ' ';
        END;
    END;
    RETURN (REVISION);
  END CF_REVISIONFORMULA;

  FUNCTION CF_TRIP_IDFORMULA(DELIVERY_ID1 IN NUMBER
                            ,INITIAL_PICKUP_LOCATION_ID IN NUMBER) RETURN NUMBER IS
    CURSOR C_GET_TRIP_NAME IS
      SELECT
        WT.TRIP_ID,
        WT.NAME
      FROM
        WSH_TRIPS WT,
        WSH_TRIP_STOPS WTS,
        WSH_DELIVERY_LEGS WDL
      WHERE WDL.DELIVERY_ID = DELIVERY_ID1
        AND WTS.STOP_LOCATION_ID = INITIAL_PICKUP_LOCATION_ID
        AND WTS.STOP_ID = WDL.PICK_UP_STOP_ID
        AND WTS.TRIP_ID = WT.TRIP_ID;
  BEGIN
    IF DELIVERY_ID1 IS NULL THEN
      CP_TRIP_NAME := NULL;
      RETURN NULL;
    ELSE
      IF DELIVERY_ID1 = CP_CACHE_DELIVERY_ID THEN
        CP_TRIP_NAME := CP_CACHE_TRIP_NAME;
        RETURN CP_CACHE_TRIP_ID;
      ELSE
        OPEN C_GET_TRIP_NAME;
        FETCH C_GET_TRIP_NAME
         INTO CP_CACHE_TRIP_ID,CP_CACHE_TRIP_NAME;
        IF C_GET_TRIP_NAME%NOTFOUND THEN
          CLOSE C_GET_TRIP_NAME;
          RAISE NO_DATA_FOUND;
        END IF;
        CLOSE C_GET_TRIP_NAME;
        CP_CACHE_DELIVERY_ID := DELIVERY_ID1;
        CP_TRIP_NAME := CP_CACHE_TRIP_NAME;
        RETURN CP_CACHE_TRIP_ID;
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      IF C_GET_TRIP_NAME%ISOPEN THEN
        CLOSE C_GET_TRIP_NAME;
      END IF;
      RETURN NULL;
  END CF_TRIP_IDFORMULA;

  FUNCTION CF_CUSTOMER_NAMEFORMULA(CUSTOMER_FLAG IN VARCHAR2
                                  ,SOURCE_HEADER_ID IN NUMBER) RETURN CHAR IS
    CURSOR CUSTOMER_NAME(O_ID IN NUMBER) IS
      SELECT
        SUBSTRB(PARTY.PARTY_NAME
               ,1
               ,50) CUSTOMER_NAME
      FROM
        HZ_PARTIES PARTY,
        HZ_CUST_ACCOUNTS CUST_ACCT,
        OE_ORDER_HEADERS_ALL OH
      WHERE CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
        AND OH.HEADER_ID = O_ID
        AND CUST_ACCT.CUST_ACCOUNT_ID = OH.SOLD_TO_ORG_ID;
    NAME HZ_PARTIES.PARTY_NAME%TYPE := ' ';
  BEGIN
    IF CUSTOMER_FLAG = 'Y' THEN
      OPEN CUSTOMER_NAME(SOURCE_HEADER_ID);
      FETCH CUSTOMER_NAME
       INTO NAME;
      CLOSE CUSTOMER_NAME;
    END IF;
    RETURN NAME;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ' ';
  END CF_CUSTOMER_NAMEFORMULA;

  FUNCTION CF_CUSTOMERFORMULA(CUSTOMER_FLAG IN VARCHAR2
                             ,SOURCE_HEADER_ID IN NUMBER) RETURN CHAR IS
    CURSOR CUSTOMER_NAME(O_ID IN NUMBER) IS
      SELECT
        SUBSTRB(PARTY.PARTY_NAME
               ,1
               ,50) CUSTOMER_NAME
      FROM
        HZ_PARTIES PARTY,
        HZ_CUST_ACCOUNTS CUST_ACCT,
        OE_ORDER_HEADERS_ALL OH
      WHERE CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
        AND OH.HEADER_ID = O_ID
        AND CUST_ACCT.CUST_ACCOUNT_ID = OH.SOLD_TO_ORG_ID;
    NAME HZ_PARTIES.PARTY_NAME%TYPE := ' ';
  BEGIN
    IF CUSTOMER_FLAG = 'Y' THEN
      OPEN CUSTOMER_NAME(SOURCE_HEADER_ID);
      FETCH CUSTOMER_NAME
       INTO NAME;
      CLOSE CUSTOMER_NAME;
    END IF;
    RETURN NAME;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ' ';
  END CF_CUSTOMERFORMULA;

  FUNCTION CF_ORDER_NUMBERFORMULA(ORDER_NUMBER_FLAG IN VARCHAR2
                                 ,SOURCE_HEADER_NUMBER IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF ORDER_NUMBER_FLAG = 'Y' THEN
      RETURN SOURCE_HEADER_NUMBER;
    ELSE
      RETURN NULL;
    END IF;
  END CF_ORDER_NUMBERFORMULA;

  FUNCTION CF_TRIP_STOP_ADDRESS1FORMULA(TRIP_STOP_FLAG IN VARCHAR2
                                       ,DELIVERY_FLAG IN VARCHAR2
                                       ,CF_DELIVERY_ID IN NUMBER
                                       ,PICK_SLIP_NUMBER IN NUMBER) RETURN CHAR IS
    CURSOR TRIP_STOP_FROM_DLVY(P_DELIVERY_ID IN NUMBER) IS
      SELECT
        LOC.ADDRESS1,
        LOC.ADDRESS2,
        LOC.ADDRESS3,
        LOC.ADDRESS4,
        LOC.CITY || DECODE(LOC.CITY
              ,NULL
              ,''
              ,', ') || NVL(LOC.STATE
           ,LOC.PROVINCE) || DECODE(LOC.POSTAL_CODE
              ,NULL
              ,''
              ,' ' || LOC.POSTAL_CODE) || DECODE(NVL(LOC.STATE
                  ,NVL(LOC.PROVINCE
                     ,LOC.POSTAL_CODE))
              ,NULL
              ,''
              ,', ') || LOC.COUNTRY
      FROM
        WSH_TRIP_STOPS WTS,
        WSH_DELIVERY_LEGS WDL,
        WSH_LOCATIONS LOC
      WHERE WDL.DELIVERY_ID = P_DELIVERY_ID
        AND WDL.PICK_UP_STOP_ID = WTS.STOP_ID
        AND WTS.STOP_LOCATION_ID = LOC.WSH_LOCATION_ID;
    CURSOR TRIP_STOP_FROM_PS(X_PS_NUMBER IN NUMBER) IS
      SELECT
        LOC.ADDRESS1,
        LOC.ADDRESS2,
        LOC.ADDRESS3,
        LOC.ADDRESS4,
        LOC.CITY || DECODE(LOC.CITY
              ,NULL
              ,''
              ,', ') || NVL(LOC.STATE
           ,LOC.PROVINCE) || DECODE(LOC.POSTAL_CODE
              ,NULL
              ,''
              ,' ' || LOC.POSTAL_CODE) || DECODE(NVL(LOC.STATE
                  ,NVL(LOC.PROVINCE
                     ,LOC.POSTAL_CODE))
              ,NULL
              ,''
              ,', ') || LOC.COUNTRY
      FROM
        WSH_TRIP_STOPS WTS,
        WSH_DELIVERY_LEGS WDL,
        WSH_DELIVERY_ASSIGNMENTS_V WDA,
        WSH_DELIVERY_DETAILS WDD,
        MTL_MATERIAL_TRANSACTIONS_TEMP MMTT,
        WSH_LOCATIONS LOC
      WHERE MMTT.PICK_SLIP_NUMBER = X_PS_NUMBER
        AND MMTT.MOVE_ORDER_LINE_ID = WDD.MOVE_ORDER_LINE_ID
        AND MMTT.PICK_SLIP_NUMBER IS NOT NULL
        AND ABS(NVL(MMTT.TRANSACTION_QUANTITY
             ,0)) > 0
        AND WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
        AND WDA.DELIVERY_ID = WDL.DELIVERY_ID
        AND WDL.PICK_UP_STOP_ID = WTS.STOP_ID
        AND WTS.STOP_LOCATION_ID = LOC.WSH_LOCATION_ID
        AND NVL(WDD.LINE_DIRECTION
         ,'O') IN ( 'O' , 'IO' )
        AND WDD.CONTAINER_FLAG IN ( 'N' , 'Y' )
      UNION ALL
      SELECT
        LOC.ADDRESS1,
        LOC.ADDRESS2,
        LOC.ADDRESS3,
        LOC.ADDRESS4,
        LOC.CITY || DECODE(LOC.CITY
              ,NULL
              ,''
              ,', ') || NVL(LOC.STATE
           ,LOC.PROVINCE) || DECODE(LOC.POSTAL_CODE
              ,NULL
              ,''
              ,' ' || LOC.POSTAL_CODE) || DECODE(NVL(LOC.STATE
                  ,NVL(LOC.PROVINCE
                     ,LOC.POSTAL_CODE))
              ,NULL
              ,''
              ,', ') || LOC.COUNTRY
      FROM
        WSH_TRIP_STOPS WTS,
        WSH_DELIVERY_LEGS WDL,
        WSH_DELIVERY_ASSIGNMENTS_V WDA,
        WSH_DELIVERY_DETAILS WDD,
        MTL_MATERIAL_TRANSACTIONS MMT,
        WSH_LOCATIONS LOC
      WHERE MMT.PICK_SLIP_NUMBER = X_PS_NUMBER
        AND MMT.MOVE_ORDER_LINE_ID = WDD.MOVE_ORDER_LINE_ID
        AND MMT.PICK_SLIP_NUMBER IS NOT NULL
        AND NVL(MMT.TRANSACTION_QUANTITY
         ,0) < 0
        AND WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
        AND WDA.DELIVERY_ID = WDL.DELIVERY_ID
        AND WDL.PICK_UP_STOP_ID = WTS.STOP_ID
        AND WTS.STOP_LOCATION_ID = LOC.WSH_LOCATION_ID
        AND NVL(WDD.LINE_DIRECTION
         ,'O') IN ( 'O' , 'IO' )
        AND WDD.CONTAINER_FLAG IN ( 'N' , 'Y' )
      UNION ALL
      SELECT
        LOC.ADDRESS1,
        LOC.ADDRESS2,
        LOC.ADDRESS3,
        LOC.ADDRESS4,
        LOC.CITY || DECODE(LOC.CITY
              ,NULL
              ,''
              ,', ') || NVL(LOC.STATE
           ,LOC.PROVINCE) || DECODE(LOC.POSTAL_CODE
              ,NULL
              ,''
              ,' ' || LOC.POSTAL_CODE) || DECODE(NVL(LOC.STATE
                  ,NVL(LOC.PROVINCE
                     ,LOC.POSTAL_CODE))
              ,NULL
              ,''
              ,', ') || LOC.COUNTRY
      FROM
        WSH_TRIP_STOPS WTS,
        WSH_DELIVERY_LEGS WDL,
        WSH_DELIVERY_ASSIGNMENTS_V WDA,
        WSH_DELIVERY_DETAILS WDD,
        MTL_TXN_REQUEST_LINES MTRL,
        WSH_LOCATIONS LOC
      WHERE MTRL.PICK_SLIP_NUMBER = X_PS_NUMBER
        AND MTRL.LINE_ID = WDD.MOVE_ORDER_LINE_ID
        AND MTRL.PICK_SLIP_NUMBER IS NOT NULL
        AND WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
        AND WDA.DELIVERY_ID = WDL.DELIVERY_ID
        AND WDL.PICK_UP_STOP_ID = WTS.STOP_ID
        AND WTS.STOP_LOCATION_ID = LOC.WSH_LOCATION_ID
        AND NVL(WDD.LINE_DIRECTION
         ,'O') IN ( 'O' , 'IO' )
        AND WDD.CONTAINER_FLAG IN ( 'N' , 'Y' );
    ADDR1 VARCHAR2(240) := ' ';
    ADDR2 VARCHAR2(240) := ' ';
    ADDR3 VARCHAR2(240) := ' ';
    ADDR4 VARCHAR2(240) := ' ';
    ADDR5 VARCHAR2(300) := ' ';
  BEGIN
    /*SRW.REFERENCE(TS_ADDR1)*/NULL;
    /*SRW.REFERENCE(TS_ADDR2)*/NULL;
    /*SRW.REFERENCE(TS_ADDR3)*/NULL;
    /*SRW.REFERENCE(TS_ADDR4)*/NULL;
    /*SRW.REFERENCE(TS_ADDR5)*/NULL;
    IF TRIP_STOP_FLAG = 'Y' THEN
      IF DELIVERY_FLAG = 'Y' THEN
        OPEN TRIP_STOP_FROM_DLVY(CF_DELIVERY_ID);
        FETCH TRIP_STOP_FROM_DLVY
         INTO ADDR1,ADDR2,ADDR3,ADDR4,ADDR5;
        CLOSE TRIP_STOP_FROM_DLVY;
      ELSE
        OPEN TRIP_STOP_FROM_PS(PICK_SLIP_NUMBER);
        FETCH TRIP_STOP_FROM_PS
         INTO ADDR1,ADDR2,ADDR3,ADDR4,ADDR5;
        CLOSE TRIP_STOP_FROM_PS;
      END IF;
      TS_ADDR1 := ADDR1;
      IF (ADDR2 IS NOT NULL) THEN
        TS_ADDR2 := ADDR2;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NOT NULL) THEN
        TS_ADDR2 := ADDR3;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NULL AND ADDR4 IS NOT NULL) THEN
        TS_ADDR2 := ADDR4;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NULL AND ADDR4 IS NULL) THEN
        TS_ADDR2 := ADDR5;
      ELSE
        TS_ADDR2 := ' ';
      END IF;
      IF (ADDR2 IS NOT NULL AND ADDR3 IS NOT NULL) THEN
        TS_ADDR3 := ADDR3;
      ELSIF (ADDR2 IS NOT NULL AND ADDR3 IS NULL AND ADDR4 IS NOT NULL) THEN
        TS_ADDR3 := ADDR4;
      ELSIF (ADDR2 IS NOT NULL AND ADDR3 IS NULL AND ADDR4 IS NULL) THEN
        TS_ADDR3 := ADDR5;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NOT NULL AND ADDR4 IS NOT NULL) THEN
        TS_ADDR3 := ADDR4;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NOT NULL AND ADDR4 IS NULL) THEN
        TS_ADDR3 := ADDR5;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NULL AND ADDR4 IS NOT NULL) THEN
        TS_ADDR3 := ADDR5;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NULL AND ADDR4 IS NULL) THEN
        TS_ADDR3 := ' ';
      END IF;
      IF (ADDR2 IS NOT NULL AND ADDR3 IS NOT NULL AND ADDR4 IS NOT NULL) THEN
        TS_ADDR4 := ADDR4;
      ELSIF (ADDR2 IS NOT NULL AND ADDR3 IS NULL AND ADDR4 IS NULL) THEN
        TS_ADDR4 := ' ';
      ELSIF (ADDR2 IS NOT NULL AND ADDR3 IS NULL AND ADDR4 IS NOT NULL) THEN
        TS_ADDR4 := ADDR5;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NOT NULL AND ADDR4 IS NOT NULL) THEN
        TS_ADDR4 := ADDR5;
      ELSIF (ADDR2 IS NOT NULL AND ADDR3 IS NOT NULL AND ADDR4 IS NULL) THEN
        TS_ADDR4 := ADDR5;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NOT NULL AND ADDR4 IS NULL) THEN
        TS_ADDR4 := ' ';
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NULL AND ADDR4 IS NOT NULL) THEN
        TS_ADDR4 := ' ';
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NULL AND ADDR4 IS NULL) THEN
        TS_ADDR4 := ' ';
      END IF;
      IF ((ADDR2 IS NULL) OR (ADDR3 IS NULL) OR (ADDR4 IS NULL)) THEN
        TS_ADDR5 := ' ';
      ELSE
        TS_ADDR5 := ADDR5;
      END IF;
    END IF;
    RETURN ' ';
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ' ';
  END CF_TRIP_STOP_ADDRESS1FORMULA;

  FUNCTION CF_DELIVERYFORMULA(DELIVERY_FLAG IN VARCHAR2
                             ,DELIVERY_NAME IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF DELIVERY_FLAG = 'Y' THEN
      RETURN DELIVERY_NAME;
    ELSE
      RETURN ' ';
    END IF;
  END CF_DELIVERYFORMULA;

  FUNCTION CF_REQUISITION_NUMBERFORMULA(SOURCE_HEADER_ID IN NUMBER) RETURN CHAR IS
    CURSOR REQUISITION(X_ORDER_HEADER IN NUMBER) IS
      SELECT
        ORIG_SYS_DOCUMENT_REF
      FROM
        OE_ORDER_HEADERS_ALL
      WHERE HEADER_ID = X_ORDER_HEADER
        AND SOURCE_DOCUMENT_TYPE_ID = 10;
    REQN_NUMBER OE_ORDER_HEADERS_ALL.ORIG_SYS_DOCUMENT_REF%TYPE := ' ';
  BEGIN
    OPEN REQUISITION(SOURCE_HEADER_ID);
    FETCH REQUISITION
     INTO REQN_NUMBER;
    CLOSE REQUISITION;
    RETURN REQN_NUMBER;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ' ';
  END CF_REQUISITION_NUMBERFORMULA;

  FUNCTION CF_SUBINVENTORYFORMULA(SUBINVENTORY_FLAG IN VARCHAR2
                                 ,FROM_SUBINVENTORY IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF SUBINVENTORY_FLAG = 'Y' THEN
      RETURN FROM_SUBINVENTORY;
    ELSE
      RETURN ' ';
    END IF;
  END CF_SUBINVENTORYFORMULA;

  FUNCTION CF_SHIPMENT_PRIORITYFORMULA(SHIPMENT_PRIORITY_FLAG IN VARCHAR2
                                      ,PRIORITY IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(SHIPMENT_PRIORITY_FLAG)*/NULL;
    IF SHIPMENT_PRIORITY_FLAG = 'Y' THEN
      RETURN PRIORITY;
    ELSE
      RETURN ' ';
    END IF;
  END CF_SHIPMENT_PRIORITYFORMULA;

  FUNCTION CF_SHIP_TO_ADDRESSFORMULA(SHIP_TO_FLAG IN VARCHAR2
                                    ,PICK_SLIP_NUMBER IN NUMBER) RETURN CHAR IS
    CURSOR SHIP_TO(X_PS_NUM IN NUMBER) IS
      SELECT
        LOC.ADDRESS1,
        LOC.ADDRESS2,
        LOC.ADDRESS3,
        LOC.ADDRESS4,
        LOC.CITY || DECODE(LOC.CITY
              ,NULL
              ,''
              ,', ') || NVL(LOC.STATE
           ,LOC.PROVINCE) || DECODE(LOC.POSTAL_CODE
              ,NULL
              ,''
              ,' ' || LOC.POSTAL_CODE) || DECODE(NVL(LOC.STATE
                  ,NVL(LOC.PROVINCE
                     ,LOC.POSTAL_CODE))
              ,NULL
              ,''
              ,', ') || LOC.COUNTRY
      FROM
        WSH_LOCATIONS LOC
      WHERE LOC.WSH_LOCATION_ID = (
        SELECT
          WDD.SHIP_TO_LOCATION_ID
        FROM
          WSH_DELIVERY_DETAILS WDD,
          WSH_PICK_SLIP_V WPSV
        WHERE WPSV.PICK_SLIP_NUMBER = X_PS_NUM
          AND WPSV.MOVE_ORDER_LINE_ID = WDD.MOVE_ORDER_LINE_ID
          AND ROWNUM = 1 );
    ADDR1 VARCHAR2(240) := ' ';
    ADDR2 VARCHAR2(240) := ' ';
    ADDR3 VARCHAR2(240) := ' ';
    ADDR4 VARCHAR2(240) := ' ';
    ADDR5 VARCHAR2(300) := ' ';
  BEGIN
    /*SRW.REFERENCE(ST_ADDR1)*/NULL;
    /*SRW.REFERENCE(ST_ADDR2)*/NULL;
    /*SRW.REFERENCE(ST_ADDR3)*/NULL;
    /*SRW.REFERENCE(ST_ADDR4)*/NULL;
    /*SRW.REFERENCE(ST_ADDR5)*/NULL;
    IF SHIP_TO_FLAG = 'Y' THEN
      OPEN SHIP_TO(PICK_SLIP_NUMBER);
      FETCH SHIP_TO
       INTO ADDR1,ADDR2,ADDR3,ADDR4,ADDR5;
      CLOSE SHIP_TO;
      ST_ADDR1 := ADDR1;
      IF (ADDR2 IS NOT NULL) THEN
        ST_ADDR2 := ADDR2;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NOT NULL) THEN
        ST_ADDR2 := ADDR3;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NULL AND ADDR4 IS NOT NULL) THEN
        ST_ADDR2 := ADDR4;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NULL AND ADDR4 IS NULL) THEN
        ST_ADDR2 := ADDR5;
      ELSE
        ST_ADDR2 := ' ';
      END IF;
      IF (ADDR2 IS NOT NULL AND ADDR3 IS NOT NULL) THEN
        ST_ADDR3 := ADDR3;
      ELSIF (ADDR2 IS NOT NULL AND ADDR3 IS NULL AND ADDR4 IS NOT NULL) THEN
        ST_ADDR3 := ADDR4;
      ELSIF (ADDR2 IS NOT NULL AND ADDR3 IS NULL AND ADDR4 IS NULL) THEN
        ST_ADDR3 := ADDR5;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NOT NULL AND ADDR4 IS NOT NULL) THEN
        ST_ADDR3 := ADDR4;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NOT NULL AND ADDR4 IS NULL) THEN
        ST_ADDR3 := ADDR5;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NULL AND ADDR4 IS NOT NULL) THEN
        ST_ADDR3 := ADDR5;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NULL AND ADDR4 IS NULL) THEN
        ST_ADDR3 := ' ';
      END IF;
      IF (ADDR2 IS NOT NULL AND ADDR3 IS NOT NULL AND ADDR4 IS NOT NULL) THEN
        ST_ADDR4 := ADDR4;
      ELSIF (ADDR2 IS NOT NULL AND ADDR3 IS NULL AND ADDR4 IS NULL) THEN
        ST_ADDR4 := ' ';
      ELSIF (ADDR2 IS NOT NULL AND ADDR3 IS NULL AND ADDR4 IS NOT NULL) THEN
        ST_ADDR4 := ADDR5;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NOT NULL AND ADDR4 IS NOT NULL) THEN
        ST_ADDR4 := ADDR5;
      ELSIF (ADDR2 IS NOT NULL AND ADDR3 IS NOT NULL AND ADDR4 IS NULL) THEN
        ST_ADDR4 := ADDR5;
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NOT NULL AND ADDR4 IS NULL) THEN
        ST_ADDR4 := ' ';
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NULL AND ADDR4 IS NOT NULL) THEN
        ST_ADDR4 := ' ';
      ELSIF (ADDR2 IS NULL AND ADDR3 IS NULL AND ADDR4 IS NULL) THEN
        ST_ADDR4 := ' ';
      END IF;
      IF ((ADDR2 IS NULL) OR (ADDR3 IS NULL) OR (ADDR4 IS NULL)) THEN
        ST_ADDR5 := ' ';
      ELSE
        ST_ADDR5 := ADDR5;
      END IF;
    END IF;
    RETURN ' ';
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
  END CF_SHIP_TO_ADDRESSFORMULA;

  FUNCTION CF_CARRIERFORMULA(CARRIER_FLAG IN VARCHAR2
                            ,CARRIER IN VARCHAR2) RETURN CHAR IS
  BEGIN
    DECLARE
      L_MEANING FND_LOOKUP_VALUES_VL.MEANING%TYPE;
      CURSOR SHP_MTHD(X_CARRIER IN VARCHAR) IS
        SELECT
          MEANING
        FROM
          FND_LOOKUP_VALUES_VL
        WHERE LOOKUP_CODE = X_CARRIER
          AND LOOKUP_TYPE = 'SHIP_METHOD'
          AND VIEW_APPLICATION_ID = 3;
    BEGIN
      IF CARRIER_FLAG = 'Y' THEN
        OPEN SHP_MTHD(CARRIER);
        FETCH SHP_MTHD
         INTO L_MEANING;
        CLOSE SHP_MTHD;
        RETURN L_MEANING;
      ELSE
        RETURN ' ';
      END IF;
    END;
  END CF_CARRIERFORMULA;

  FUNCTION CF_TEMPFORMULA(SHIPMENT_PRIORITY_FLAG IN VARCHAR2
                         ,PRIORITY IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF SHIPMENT_PRIORITY_FLAG = 'Y' THEN
      RETURN PRIORITY;
    ELSE
      RETURN ' ';
    END IF;
  END CF_TEMPFORMULA;

  FUNCTION CF_DELIVERY_IDFORMULA(DELIVERY_FLAG IN VARCHAR2
                                ,DELIVERY_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF DELIVERY_FLAG = 'Y' THEN
      RETURN (DELIVERY_ID);
    ELSE
      RETURN -1;
    END IF;
  END CF_DELIVERY_IDFORMULA;

  FUNCTION CF_WAREHOUSEFORMULA(ORGANIZATION_ID1 IN NUMBER) RETURN CHAR IS
    CURSOR WAREHOUSE_NAME IS
      SELECT
        NAME
      FROM
        HR_ORGANIZATION_UNITS
      WHERE ORGANIZATION_ID = ORGANIZATION_ID1;
    CURSOR WAREHOUSE_CODE IS
      SELECT
        ORGANIZATION_CODE
      FROM
        MTL_PARAMETERS
      WHERE ORGANIZATION_ID = ORGANIZATION_ID1;
  BEGIN
    OPEN WAREHOUSE_NAME;
    FETCH WAREHOUSE_NAME
     INTO CP_WAREHOUSE_NAME;
    CLOSE WAREHOUSE_NAME;
    OPEN WAREHOUSE_CODE;
    FETCH WAREHOUSE_CODE
     INTO CP_WAREHOUSE_CODE;
    CLOSE WAREHOUSE_CODE;
    RETURN ' ';
  EXCEPTION
    WHEN OTHERS THEN
      IF WAREHOUSE_NAME%ISOPEN THEN
        CLOSE WAREHOUSE_NAME;
      END IF;
      IF WAREHOUSE_CODE%ISOPEN THEN
        CLOSE WAREHOUSE_CODE;
      END IF;
      RETURN ' ';
  END CF_WAREHOUSEFORMULA;

  FUNCTION CF_TRIP_CHRFORMULA(CF_TRIP_ID IN NUMBER) RETURN CHAR IS
  BEGIN
    RETURN (TO_CHAR(CF_TRIP_ID));
  END CF_TRIP_CHRFORMULA;

  FUNCTION CF_FREIGHT_TERMS_NAMEFORMULA(FREIGHT_TERMS IN VARCHAR2
                                       ,SOURCE_CODE IN VARCHAR2) RETURN CHAR IS
    L_FREIGHT_TERMS VARCHAR2(80);
    CURSOR L_GET_FREIGHT_TERMS IS
      SELECT
        FV.FREIGHT_TERMS
      FROM
        OE_FRGHT_TERMS_ACTIVE_V FV
      WHERE FV.FREIGHT_TERMS_CODE = FREIGHT_TERMS;
  BEGIN
    IF SOURCE_CODE = 'OE' THEN
      IF FREIGHT_TERMS IS NOT NULL THEN
        OPEN L_GET_FREIGHT_TERMS;
        FETCH L_GET_FREIGHT_TERMS
         INTO L_FREIGHT_TERMS;
        CLOSE L_GET_FREIGHT_TERMS;
      ELSE
        L_FREIGHT_TERMS := NULL;
      END IF;
    ELSIF SOURCE_CODE = 'OKE' THEN
      L_FREIGHT_TERMS := NULL;
    END IF;
    RETURN (L_FREIGHT_TERMS);
  EXCEPTION
    WHEN OTHERS THEN
      IF L_GET_FREIGHT_TERMS%ISOPEN THEN
        CLOSE L_GET_FREIGHT_TERMS;
      END IF;
      RAISE;
  END CF_FREIGHT_TERMS_NAMEFORMULA;

  FUNCTION CP_WAREHOUSE_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_WAREHOUSE_CODE;
  END CP_WAREHOUSE_CODE_P;

  FUNCTION CP_WAREHOUSE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_WAREHOUSE_NAME;
  END CP_WAREHOUSE_NAME_P;

  FUNCTION ST_ADDR1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ST_ADDR1;
  END ST_ADDR1_P;

  FUNCTION TS_ADDR3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TS_ADDR3;
  END TS_ADDR3_P;

  FUNCTION TS_ADDR4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TS_ADDR4;
  END TS_ADDR4_P;

  FUNCTION TS_ADDR5_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TS_ADDR5;
  END TS_ADDR5_P;

  FUNCTION TS_ADDR1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TS_ADDR1;
  END TS_ADDR1_P;

  FUNCTION TS_ADDR2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TS_ADDR2;
  END TS_ADDR2_P;

  FUNCTION ST_ADDR4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ST_ADDR4;
  END ST_ADDR4_P;

  FUNCTION ST_ADDR5_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ST_ADDR5;
  END ST_ADDR5_P;

  FUNCTION ST_ADDR2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ST_ADDR2;
  END ST_ADDR2_P;

  FUNCTION ST_ADDR3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ST_ADDR3;
  END ST_ADDR3_P;

  FUNCTION CP_TRIP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_TRIP_NAME;
  END CP_TRIP_NAME_P;

  FUNCTION CP_CACHE_DELIVERY_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_CACHE_DELIVERY_ID;
  END CP_CACHE_DELIVERY_ID_P;

  FUNCTION CP_CACHE_TRIP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CACHE_TRIP_NAME;
  END CP_CACHE_TRIP_NAME_P;

  FUNCTION CP_CACHE_TRIP_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_CACHE_TRIP_ID;
  END CP_CACHE_TRIP_ID_P;

  FUNCTION GET_DELIMITER(APPLICATION_SHORT_NAME IN VARCHAR2
                        ,KEY_FLEX_CODE IN VARCHAR2
                        ,STRUCTURE_NUMBER IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := FND_FLEX_EXT.GET_DELIMITER(:APPLICATION_SHORT_NAME, :KEY_FLEX_CODE, :STRUCTURE_NUMBER); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPLICATION_SHORT_NAME);
    STPROC.BIND_I(KEY_FLEX_CODE);
    STPROC.BIND_I(STRUCTURE_NUMBER);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
X0 := FND_FLEX_EXT.GET_DELIMITER(APPLICATION_SHORT_NAME, KEY_FLEX_CODE, STRUCTURE_NUMBER);
    RETURN X0;
  END GET_DELIMITER;

  FUNCTION GET_CCID(APPLICATION_SHORT_NAME IN VARCHAR2
                   ,KEY_FLEX_CODE IN VARCHAR2
                   ,STRUCTURE_NUMBER IN NUMBER
                   ,VALIDATION_DATE IN VARCHAR2
                   ,CONCATENATED_SEGMENTS IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    /*STPROC.INIT('begin :X0 := FND_FLEX_EXT.GET_CCID(:APPLICATION_SHORT_NAME, :KEY_FLEX_CODE, :STRUCTURE_NUMBER, :VALIDATION_DATE, :CONCATENATED_SEGMENTS); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPLICATION_SHORT_NAME);
    STPROC.BIND_I(KEY_FLEX_CODE);
    STPROC.BIND_I(STRUCTURE_NUMBER);
    STPROC.BIND_I(VALIDATION_DATE);
    STPROC.BIND_I(CONCATENATED_SEGMENTS);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    X0 := FND_FLEX_EXT.GET_CCID(APPLICATION_SHORT_NAME, KEY_FLEX_CODE, STRUCTURE_NUMBER, VALIDATION_DATE, CONCATENATED_SEGMENTS);
    RETURN X0;
  END GET_CCID;

  FUNCTION GET_SEGS(APPLICATION_SHORT_NAME IN VARCHAR2
                   ,KEY_FLEX_CODE IN VARCHAR2
                   ,STRUCTURE_NUMBER IN NUMBER
                   ,COMBINATION_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
/*    STPROC.INIT('begin :X0 := FND_FLEX_EXT.GET_SEGS(:APPLICATION_SHORT_NAME, :KEY_FLEX_CODE, :STRUCTURE_NUMBER, :COMBINATION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPLICATION_SHORT_NAME);
    STPROC.BIND_I(KEY_FLEX_CODE);
    STPROC.BIND_I(STRUCTURE_NUMBER);
    STPROC.BIND_I(COMBINATION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
   X0 := FND_FLEX_EXT.GET_SEGS(APPLICATION_SHORT_NAME, KEY_FLEX_CODE, STRUCTURE_NUMBER, COMBINATION_ID);
    RETURN X0;
  END GET_SEGS;
  function B_task_idFt(organization_id varchar2) return varchar2 is
begin
  if WSH_UTIL_VALIDATE.Check_Wms_Org(organization_id)='Y' then
    return ('TRUE');
  else
    return ('FALSE');
  end if;
 end;

END WSH_WSHRDPIK_XMLP_PKG;


/
