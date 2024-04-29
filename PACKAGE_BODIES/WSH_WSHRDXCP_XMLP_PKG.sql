--------------------------------------------------------
--  DDL for Package Body WSH_WSHRDXCP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_WSHRDXCP_XMLP_PKG" AS
/* $Header: WSHRDXCPB.pls 120.3.12010000.3 2009/10/07 14:38:43 gbhargav ship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  C_DATE_FORMAT varchar2(20);
  BEGIN
     BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      C_DATE_FORMAT := 'DD-MON-YY';
      CP_CREATION_DATE_FROM := to_char(P_CREATION_DATE_FROM,C_DATE_FORMAT);
      CP_CREATION_DATE_TO := to_char(P_CREATION_DATE_TO,C_DATE_FORMAT);
      CP_LAST_UPDATE_DATE_FROM := to_char(P_LAST_UPDATE_DATE_FROM,C_DATE_FORMAT);
      CP_LAST_UPDATE_DATE_TO := to_char(P_LAST_UPDATE_DATE_TO,C_DATE_FORMAT);
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed FND SRWINIT.')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    DECLARE
      P_ORG_ID_CHAR VARCHAR2(100) := TO_CHAR(P_ORG_ID);
    BEGIN
      /*SRW.USER_EXIT('FND PUTPROFILE NAME="' || 'MFG_ORGANIZATION_ID' || '" FIELD="' || P_ORG_ID_CHAR || '"')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(020
                   ,'Failed in before report trigger, setting org profile ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Before Report: LocatorFlex')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Before Report: ItemFlex')*/NULL;
    END;
    DECLARE
      CURSOR WAREHOUSE_NAME IS
        SELECT
          NAME
        FROM
          HR_ORGANIZATION_UNITS
        WHERE ORGANIZATION_ID = P_ORG_ID;
    BEGIN
      OPEN WAREHOUSE_NAME;
      FETCH WAREHOUSE_NAME
       INTO CP_WAREHOUSE_NAME;
      CLOSE WAREHOUSE_NAME;
      CP_EXCEPTION_LOCATION_NAME := WSH_UTIL_CORE.GET_LOCATION_DESCRIPTION(P_EXCEPTION_LOCATION_ID
                                                                          ,'NEW UI CODE');
      CP_SHIP_FROM_LOCATION_NAME := WSH_UTIL_CORE.GET_LOCATION_DESCRIPTION(P_LOGGED_LOCATION_ID
                                                                          ,'NEW UI CODE');
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

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

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    L_DEL_LINES_CONT VARCHAR2(10000);
    L_DEL_LINES_CONT_TEMP VARCHAR2(5000); --Bug 8800213
  BEGIN
    BEGIN
      P_BATCHES := '  ';
      P_WSH_PICKING_BATCHES_TABLE := ' ';
      P_WE_WPB_OUTER_JOIN := ' ';
      P_HINT_1 := ' ';
      IF (P_MOVE_ORDER_LOW IS NOT NULL OR P_MOVE_ORDER_HIGH IS NOT NULL) THEN
        P_WSH_PICKING_BATCHES_TABLE := ' wsh_picking_batches wpb, ';
        P_WE_WPB_OUTER_JOIN := ' and  wpb.batch_id   =  we.batch_id ';
        P_HINT_1 := '/*+leading(wpb)*/ ';
        IF (P_MOVE_ORDER_LOW IS NOT NULL AND P_MOVE_ORDER_HIGH IS NOT NULL) THEN
          IF (P_MOVE_ORDER_LOW < P_MOVE_ORDER_HIGH) THEN
            P_BATCHES := ' and wpb.name between :p_move_order_low and :p_move_order_high ';
          ELSIF (P_MOVE_ORDER_LOW = P_MOVE_ORDER_HIGH) THEN
            P_BATCHES := ' and wpb.name = :p_move_order_low ';
          END IF;
        ELSIF P_MOVE_ORDER_LOW IS NULL THEN
          P_BATCHES := ' and wpb.name <= :p_move_order_high ';
        ELSE
          P_BATCHES := ' and wpb.name >= :p_move_order_low ';
        END IF;
      END IF;
    END;
    P_REQUEST := ' ';
    P_EXCEPTION := ' ';
    P_LOGGING_ENTITY_LOCATION := ' ';
    P_TRIP := '  ';
    P_DELIVERY := ' ';
    P_SEVERITY_STATUS := ' ';
    P_CREATION_UPDATE_DATE := ' ';
    IF (P_REQUEST_ID IS NOT NULL and P_REQUEST_ID <> -99 ) THEN      --Bug 8800213 added P_REQUEST_ID != -99
      P_REQUEST := ' and we.request_id = :p_request_id ';
    END IF;
    IF (P_EXCEPTION_NAME IS NOT NULL) THEN
      P_EXCEPTION := ' and we.exception_name = :p_exception_name ';
    END IF;
    IF (P_LOGGING_ENTITY IS NOT NULL) THEN
      P_LOGGING_ENTITY_LOCATION := ' and we.logging_entity = :p_logging_entity ';
    END IF;
    IF (P_LOGGED_LOCATION_ID IS NOT NULL) THEN
      P_LOGGING_ENTITY_LOCATION := P_LOGGING_ENTITY_LOCATION || ' and we.logged_at_location_id = :p_logged_location_id ';
    END IF;
    IF (P_EXCEPTION_LOCATION_ID IS NOT NULL) THEN
      P_LOGGING_ENTITY_LOCATION := P_LOGGING_ENTITY_LOCATION || ' and we.exception_location_id = :p_exception_location_id ';
    END IF;

    IF (P_REQUEST_ID IS NULL) THEN --bug 8800213 check trip only when P_REQUEST_ID is null
      IF (P_TRIP_ID_LOW IS NOT NULL) THEN
         P_TRIP := ' and nvl(we.trip_id, -1) >= decode(:p_request_id, null, :p_trip_id_low, nvl(we.trip_id, -1)) ';
      END IF;

      IF (P_TRIP_ID_HIGH IS NOT NULL) THEN
        P_TRIP := P_TRIP || ' and nvl(we.trip_id, -1) <= decode(:p_request_id, null, :p_trip_id_high, nvl(we.trip_id, -1)) ';
      END IF;
    END IF;

    IF (P_REQUEST_ID IS NULL) THEN
      IF (P_DELIVERY_ID_LOW IS NOT NULL) THEN
        P_DELIVERY := ' and we.delivery_id >= :p_delivery_id_low ';
      END IF;
      IF (P_DELIVERY_ID_HIGH IS NOT NULL) THEN
        P_DELIVERY := P_DELIVERY || ' and we.delivery_id <= :p_delivery_id_high ';
      END IF;
    END IF;
    IF (P_SEVERITY IS NOT NULL) THEN
      P_SEVERITY_STATUS := ' and we.severity = :p_severity ';
    END IF;
    IF (P_STATUS IS NOT NULL) THEN
      P_SEVERITY_STATUS := P_SEVERITY_STATUS || ' and we.status = :p_status ';
    END IF;
    IF (P_CREATION_DATE_FROM IS NOT NULL) THEN
      P_CREATION_UPDATE_DATE := ' and we.creation_date >= :p_creation_date_from ';
    END IF;
    IF (P_CREATION_DATE_TO IS NOT NULL) THEN
      P_CREATION_UPDATE_DATE := P_CREATION_UPDATE_DATE || ' and we.creation_date - ( 86399/86400 ) <= :p_creation_date_to ';
    END IF;
    IF (P_LAST_UPDATE_DATE_FROM IS NOT NULL) THEN
      P_CREATION_UPDATE_DATE := P_CREATION_UPDATE_DATE || ' and we.last_update_date >= :p_last_update_date_from ';
    END IF;
    IF (P_LAST_UPDATE_DATE_TO IS NOT NULL) THEN
      P_CREATION_UPDATE_DATE := P_CREATION_UPDATE_DATE || ' and we.last_update_date - ( 86399/86400 ) <= :p_last_update_date_to ';
    END IF;
    L_DEL_LINES_CONT := '';
    IF ((P_DELIVERY_ID_LOW IS NOT NULL OR P_DELIVERY_ID_HIGH IS NOT NULL) AND
         (P_MOVE_ORDER_LOW IS NULL AND P_MOVE_ORDER_HIGH IS NULL)) THEN    --Bug 8800213 Don't populate L_DEL_LINES_CONT for Pick release online and concurrent
    --{
         L_DEL_LINES_CONT_TEMP := 'UNION select
         --Bug 8800213 :Adding the hint to improve performance
         /*+ leading(wda)*/
         EXCEPTION_ID         --Bug 8800213 indented all columns to left to reduce the dynamic string length
         ,LOGGED_AT_LOCATION_ID
         ,LE.MEANING LOGGING_ENTITY_MEANING
         ,EXCEPTION_NAME
         ,EXCEPTION_LOCATION_ID
         ,MESSAGE
         ,SEV.MEANING SEVERITY_MEANING
         ,MANUALLY_LOGGED
         ,STA.MEANING STATUS_MEANING
         ,we.TRIP_ID
         ,TRIP_NAME
         ,we.TRIP_STOP_ID
         ,we.DELIVERY_ID
         ,DELIVERY_NAME
         ,we.DELIVERY_DETAIL_ID
         ,we.DELIVERY_ASSIGNMENT_ID
         ,we.CONTAINER_NAME
         ,' || P_ITEM_FLEXSQL ||' C_ITEM_FLEXDAT --bug 8800213 placed P_ITEM_FLEXSQL outside string so that its values is appended
         ,we.INVENTORY_ITEM_ID
         ,we.LOT_NUMBER
         -- HW OPM Convergence Project. Commented Sublot
         -- ,we.SUBLOT_NUMBER
         ,we.REVISION
         ,we.SERIAL_NUMBER
         ,UNIT_OF_MEASURE
         ,UNIT_OF_MEASURE2
         ,QUANTITY
         ,QUANTITY2
         ,we.SUBINVENTORY
         ,we.LOCATOR_ID
         ,'|| P_LOCATOR_FLEXSQL  ||' C_LOCATOR_FLEXDAT --bug 8800213 placed  P_LOCATOR_FLEXSQL outside string so that its values is appended
         ,ARRIVAL_DATE
         ,DEPARTURE_DATE
         ,ERROR_MESSAGE
         ,we.CREATION_DATE
         ,we.REQUEST_ID
         ,WND.NAME DEL_NAME
         ,WT.NAME TRP_NAME
	 --Bug 8800213 added following columns as main query has these columns.
	 ,NULL F_Item_FlexVal
	 ,WSH_WSHRDXCP_XMLP_PKG.c_exception_locationformula(EXCEPTION_LOCATION_ID) C_Exception_Location
	 ,WSH_WSHRDXCP_XMLP_PKG.c_logged_locationformula(LOGGED_AT_LOCATION_ID) C_Logged_Location
	 ,NULL F_locator_Flexval
	 ,WSH_WSHRDXCP_XMLP_PKG.cf_container_nameformula(we.CONTAINER_NAME, we.DELIVERY_DETAIL_ID) CF_container_name
	 ,WSH_WSHRDXCP_XMLP_PKG.cf_delivery_nameformula(we.DELIVERY_DETAIL_ID, WND.NAME) CF_delivery_name
	 ,WSH_WSHRDXCP_XMLP_PKG.CP_delivery_detail_id_p CP_delivery_detail_id
         from
               wsh_exceptions we,
               mtl_system_items sys,
               mtl_item_locations loc, ' || P_WSH_PICKING_BATCHES_TABLE || ' wsh_lookups sta,
               wsh_lookups sev,
               wsh_lookups le,
               WSH_NEW_DELIVERIES WND,
               WSH_TRIPS WT,
               WSH_TRIP_STOPS WTS,
               WSH_DELIVERY_DETAILS WDD,
               WSH_DELIVERY_ASSIGNMENTS_V WDA  --Bug 8800213
         where
               sta.lookup_type = ''EXCEPTION_STATUS''
               and sta.lookup_code = we.status
               and sev.lookup_type IN ( ''EXCEPTION_SEVERITY'',''EXCEPTION_BEHAVIOR'')
               and sev.lookup_code = we.severity
               and le.lookup_type = ''LOGGING_ENTITY''
               and le.lookup_code = logging_entity
               and sys.organization_id(+) = we.exception_location_id
               and sys.inventory_item_id(+) = we.inventory_item_id
               and loc.inventory_location_id(+) = we.locator_id
               and loc.organization_id(+) = we.exception_location_id ' || P_WE_WPB_OUTER_JOIN || ' and (we.exception_name IS NULL OR we.exception_name not like ''WSH_IB%'')
               and we.DELIVERY_ID = WND.DELIVERY_ID (+)
               and we.TRIP_ID = WT.TRIP_ID (+)
               and we.TRIP_STOP_ID = WTS.STOP_ID (+)
               and we.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID (+)
               and  ( WND.SHIPMENT_DIRECTION is null or WND.SHIPMENT_DIRECTION IN (''O'', ''IO'') )      --Bug# 3748009
               and  ( WND.DELIVERY_TYPE is null or WND.DELIVERY_TYPE = ''STANDARD'') -- R12 MDC changes
               and  ( WT.SHIPMENTS_TYPE_FLAG is null or WT.SHIPMENTS_TYPE_FLAG IN (''O'', ''M'')   )     --Bug# 3748009
               and  ( WTS.SHIPMENTS_TYPE_FLAG is null or WTS.SHIPMENTS_TYPE_FLAG  IN (''O'', ''M'')  )   --Bug# 3748009
               and  ( WDD.LINE_DIRECTION is null or WDD.LINE_DIRECTION IN (''O'', ''IO'')  )   ';

	 --Bug 8800213 : Adding the common part of the unions, to the main string.
	 L_DEL_LINES_CONT := L_DEL_LINES_CONT||L_DEL_LINES_CONT_TEMP;

	 L_DEL_LINES_CONT := L_DEL_LINES_CONT || P_BATCHES;
	 /*L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' and (
				      we.exception_id IN (
				      SELECT we1.exception_id
				      FROM   wsh_exceptions we1, wsh_delivery_assignments_v wda
				      WHERE  we1.delivery_detail_id = wda.delivery_detail_id ';
	  IF P_DELIVERY_ID_LOW IS NOT NULL THEN
	      L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' AND wda.delivery_id >= :p_delivery_id_low ';
	  END IF;
	  IF P_DELIVERY_ID_HIGH IS NOT NULL THEN
	      L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' AND wda.delivery_id <= :p_delivery_id_high ';
	  END IF;
	  L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' AND    wda.delivery_id IS NOT NULL
				      AND    we1.status <> ''CLOSED''
				      )
				      OR we.exception_id IN (
				      SELECT we1.exception_id
				      FROM   wsh_exceptions we1, wsh_delivery_assignments_v wda, wsh_delivery_details wdd1
				      WHERE  we1.delivery_detail_id = wdd1.delivery_detail_id --LPN Synch Up.added delivery_detail_id instead of container_name..samanna
				      AND    wdd1.container_flag = ''Y''
				      AND    wdd1.delivery_detail_id = wda.delivery_detail_id ';
	  IF P_DELIVERY_ID_LOW IS NOT NULL THEN
	      L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' AND wda.delivery_id >= :p_delivery_id_low ';
	  END IF;
	  IF P_DELIVERY_ID_HIGH IS NOT NULL THEN
	      L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' AND wda.delivery_id <= :p_delivery_id_high ';
	  END IF;
	  L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' AND    wda.delivery_id IS NOT NULL
				      AND    we1.status <> ''CLOSED''
				      ) )';*/

	  --Bug 8800213 commented above code and rebuild the queries to seperate out delivery details and container query
	  L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' ';

	  IF P_DELIVERY_ID_LOW IS NOT NULL THEN
	       L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' AND wda.delivery_id >= :p_delivery_id_low ';
          END IF;

	  IF P_DELIVERY_ID_HIGH IS NOT NULL THEN
	      L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' AND wda.delivery_id <= :p_delivery_id_high ';
	  END IF;
       	  --Bug 8310786:The following part of query ensures that only exceptions logged against delivery details are selected.
	  L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' AND    wda.delivery_id IS NOT NULL
	            AND we.delivery_detail_id = wda.delivery_detail_id
		    AND    we.status <> ''CLOSED''    ';

	  --Bug 8310786: Adding the common part of the unions, to the main string.
	  L_DEL_LINES_CONT := L_DEL_LINES_CONT||L_DEL_LINES_CONT_TEMP;
	  --Bug# 3726195
	  l_DEL_LINES_CONT := L_DEL_LINES_CONT || P_BATCHES;

	  L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' ';

	  IF  P_DELIVERY_ID_LOW IS NOT NULL THEN
	      L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' AND wda.delivery_id >= :p_delivery_id_low ';
	  END IF;

          IF P_DELIVERY_ID_HIGH IS NOT NULL THEN
	     L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' AND wda.delivery_id <= :p_delivery_id_high ';
          END IF;

          --Bug 8310786: The following part of query ensures that only exceptions logged against containers are selected.
	  L_DEL_LINES_CONT := L_DEL_LINES_CONT || ' AND    wda.delivery_id IS NOT NULL
	    AND wdd.delivery_detail_id = wda.delivery_detail_id
	    AND wdd.container_flag     = ''Y''
	    AND we.container_name      = wdd.container_name
	    AND    we.status <> ''CLOSED''    ';

	  P_DEL_LINES_CONT := L_DEL_LINES_CONT;
    --}
    END IF;
    IF P_SORT_BY = '1' THEN
      P_ORDER_BY := ' order by we.exception_name ';
    END IF;
    IF P_SORT_BY = '2' THEN
      P_ORDER_BY := ' order by we.severity, we.trip_name, we.delivery_name ';
    END IF;
    IF P_SORT_BY = '3' THEN
      P_ORDER_BY := ' order by we.severity, we.delivery_name, we.trip_name ';
    END IF;
    IF P_SORT_BY = '4' THEN
      P_ORDER_BY := ' order by we.status, we.trip_name, we.delivery_name ';
    END IF;
    IF P_SORT_BY = '5' THEN
      P_ORDER_BY := ' order by we.status, we.delivery_name, we.trip_name ';
    END IF;
    IF P_SORT_BY = '6' THEN
      P_ORDER_BY := ' order by we.trip_name, we.delivery_name ';
    END IF;
    IF P_SORT_BY = '7' THEN
      P_ORDER_BY := ' order by we.delivery_name, we.trip_name ';
    END IF;
    IF P_SORT_BY = '8' THEN
      P_ORDER_BY := ' order by we.creation_date, we.trip_name, we.delivery_name ';
    END IF;
    IF P_SORT_BY = '9' THEN
      P_ORDER_BY := ' order by we.creation_date, we.delivery_name, we.trip_name ';
    END IF;
    IF P_SORT_BY = '10' THEN
      P_ORDER_BY := ' order by we.logging_entity ';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_LOGGED_LOCATIONFORMULA(LOGGED_AT_LOCATION_ID IN NUMBER) RETURN CHAR IS
    L_LOGGED_LOCATION VARCHAR2(121);
  BEGIN
    IF LOGGED_AT_LOCATION_ID IS NOT NULL THEN
      L_LOGGED_LOCATION := WSH_UTIL_CORE.GET_LOCATION_DESCRIPTION(LOGGED_AT_LOCATION_ID
                                                                 ,'NEW UI CODE');
      RETURN (L_LOGGED_LOCATION);
    ELSE
      RETURN (NULL);
    END IF;
  END C_LOGGED_LOCATIONFORMULA;

  FUNCTION C_EXCEPTION_LOCATIONFORMULA(EXCEPTION_LOCATION_ID IN NUMBER) RETURN CHAR IS
    L_EXCEPTION_LOCATION VARCHAR2(121);
  BEGIN
    IF EXCEPTION_LOCATION_ID IS NOT NULL THEN
      L_EXCEPTION_LOCATION := WSH_UTIL_CORE.GET_LOCATION_DESCRIPTION(EXCEPTION_LOCATION_ID
                                                                    ,'NEW UI CODE');
      RETURN (L_EXCEPTION_LOCATION);
    ELSE
      RETURN (NULL);
    END IF;
  END C_EXCEPTION_LOCATIONFORMULA;

  FUNCTION CF_CONTAINER_NAMEFORMULA(CONTAINER_NAME IN VARCHAR2
                                   ,DELIVERY_DETAIL_ID IN NUMBER) RETURN VARCHAR2 IS
    CURSOR C_NAME(X_DETAIL_ID IN NUMBER) IS
      SELECT
        CONTAINER_NAME,
        CONTAINER_FLAG
      FROM
        WSH_DELIVERY_DETAILS WDD
      WHERE WDD.DELIVERY_DETAIL_ID = X_DETAIL_ID;
    L_INFO C_NAME%ROWTYPE;
  BEGIN
    IF CONTAINER_NAME IS NOT NULL THEN
      CP_DELIVERY_DETAIL_ID := DELIVERY_DETAIL_ID;
      RETURN CONTAINER_NAME;
    END IF;
    IF DELIVERY_DETAIL_ID IS NULL THEN
      CP_DELIVERY_DETAIL_ID := NULL;
      RETURN NULL;
    END IF;
    OPEN C_NAME(DELIVERY_DETAIL_ID);
    FETCH C_NAME
     INTO L_INFO;
    CLOSE C_NAME;
    IF L_INFO.CONTAINER_FLAG = 'Y' THEN
      CP_DELIVERY_DETAIL_ID := NULL;
    ELSE
      CP_DELIVERY_DETAIL_ID := DELIVERY_DETAIL_ID;
    END IF;
    RETURN L_INFO.CONTAINER_NAME;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_NAME%ISOPEN THEN
        CLOSE C_NAME;
      END IF;
      CP_DELIVERY_DETAIL_ID := DELIVERY_DETAIL_ID;
      RETURN CONTAINER_NAME;
  END CF_CONTAINER_NAMEFORMULA;

  FUNCTION CF_DELIVERY_NAMEFORMULA(DELIVERY_DETAIL_ID IN NUMBER
                                  ,DEL_NAME IN VARCHAR2) RETURN CHAR IS
    L_DELIVERY VARCHAR2(30);
    CURSOR C_DELIVERY(P_DELIVERY_DETAIL_ID IN NUMBER) IS
      SELECT
        NAME
      FROM
        WSH_NEW_DELIVERIES WND,
        WSH_DELIVERY_DETAILS WDD,
        WSH_DELIVERY_ASSIGNMENTS_V WDA
      WHERE WDD.DELIVERY_DETAIL_ID = P_DELIVERY_DETAIL_ID
        AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
        AND WDA.DELIVERY_ID = WND.DELIVERY_ID
        AND WND.DELIVERY_TYPE = 'STANDARD';
  BEGIN
    IF DELIVERY_DETAIL_ID IS NOT NULL AND DEL_NAME IS NULL THEN
      OPEN C_DELIVERY(DELIVERY_DETAIL_ID);
      FETCH C_DELIVERY
       INTO L_DELIVERY;
      CLOSE C_DELIVERY;
    ELSE
      L_DELIVERY := DEL_NAME;
    END IF;
    RETURN (L_DELIVERY);
  END CF_DELIVERY_NAMEFORMULA;

  FUNCTION CP_DELIVERY_DETAIL_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_DELIVERY_DETAIL_ID;
  END CP_DELIVERY_DETAIL_ID_P;

  FUNCTION CP_EXCEPTION_LOCATION_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_EXCEPTION_LOCATION_NAME;
  END CP_EXCEPTION_LOCATION_NAME_P;

  FUNCTION CP_SHIP_FROM_LOCATION_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_FROM_LOCATION_NAME;
  END CP_SHIP_FROM_LOCATION_NAME_P;

  FUNCTION CP_WAREHOUSE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_WAREHOUSE_NAME;
  END CP_WAREHOUSE_NAME_P;

END WSH_WSHRDXCP_XMLP_PKG;


/
