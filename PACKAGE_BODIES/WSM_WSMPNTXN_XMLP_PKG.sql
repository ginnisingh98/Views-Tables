--------------------------------------------------------
--  DDL for Package Body WSM_WSMPNTXN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_WSMPNTXN_XMLP_PKG" AS
/* $Header: WSMPNTXNB.pls 120.0 2007/12/24 14:54:21 krreddy noship $ */
  FUNCTION QR_PTXN_JOBREFCURDS RETURN number IS
    PTXN_JOB PTXN_JOB_TYPE;
  BEGIN
   -- OPEN PTXN_JOB    FOR
     SELECT
          WDJ.WIP_ENTITY_ID
      BULK COLLECT INTO G_WIP_ENTITY_ID_PL_TBL
        FROM
          WIP_DISCRETE_JOBS WDJ,
          WIP_ENTITIES WE
        WHERE WDJ.ORGANIZATION_ID = P_ORGANIZATION_ID
          AND WDJ.ORGANIZATION_ID = WE.ORGANIZATION_ID
          AND WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
          AND WE.ENTITY_TYPE = 5
          AND WDJ.WIP_ENTITY_ID in (
          SELECT
            WIP_ENTITY_ID
          FROM
            WSM_LOT_MOVE_TXN_INTERFACE
          WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
            AND STATUS <> 4
          UNION ALL
          SELECT
            WIP_ENTITY_ID
          FROM
            WIP_MOVE_TXN_INTERFACE
          WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
          UNION ALL
          SELECT
            WIP_ENTITY_ID
          FROM
            WIP_COST_TXN_INTERFACE
          WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
          UNION ALL
          SELECT
            TRANSACTION_SOURCE_ID
          FROM
            MTL_MATERIAL_TRANSACTIONS_TEMP
          WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
            AND TRANSACTION_SOURCE_TYPE_ID = 5
          UNION ALL
          SELECT
            TRANSACTION_SOURCE_ID
          FROM
            MTL_MATERIAL_TRANSACTIONS
          WHERE COSTED_FLAG in ( 'N' , 'E' )
            AND TRANSACTION_SOURCE_TYPE_ID = 5
            AND ORGANIZATION_ID = P_ORGANIZATION_ID
          UNION ALL
          SELECT
            WIP_ENTITY_ID
          FROM
            WIP_OPERATION_YIELDS
          WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
            AND STATUS in ( 1 , 3 )
          UNION ALL
          SELECT
            SJ.WIP_ENTITY_ID
          FROM
            WSM_SM_STARTING_JOBS SJ,
            WSM_SPLIT_MERGE_TRANSACTIONS WMT
          WHERE SJ.TRANSACTION_ID = WMT.TRANSACTION_ID
            AND ( WMT.STATUS <> 4
          OR NVL(WMT.COSTED
             ,1) <> 4 )
          UNION ALL
          SELECT
            RJ.WIP_ENTITY_ID
          FROM
            WSM_SM_RESULTING_JOBS RJ,
            WSM_SPLIT_MERGE_TRANSACTIONS WMT
          WHERE RJ.TRANSACTION_ID = WMT.TRANSACTION_ID
            AND ( WMT.STATUS <> 4
          OR NVL(WMT.COSTED
             ,1) <> 4 )
          UNION ALL
          SELECT
            PD.WIP_ENTITY_ID
          FROM
            PO_RELEASES_ALL PR,
            PO_HEADERS_ALL PH,
            PO_DISTRIBUTIONS_ALL PD,
            PO_LINE_LOCATIONS_ALL PL
          WHERE PD.DESTINATION_ORGANIZATION_ID = P_ORGANIZATION_ID
            AND PD.PO_LINE_ID is not null
            AND PD.LINE_LOCATION_ID is not null
            AND PH.PO_HEADER_ID = PD.PO_HEADER_ID
            AND PL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
            AND pr.po_release_id (+) = PD.PO_RELEASE_ID
            AND NVL(PR.CANCEL_FLAG
             ,'N') = 'N'
            AND ( PL.QUANTITY_RECEIVED < ( PL.QUANTITY - PL.QUANTITY_CANCELLED ) )
          UNION ALL
          SELECT
            PRL.WIP_ENTITY_ID
          FROM
            PO_REQUISITION_LINES_ALL PRL
          WHERE PRL.DESTINATION_ORGANIZATION_ID = P_ORGANIZATION_ID
            AND NVL(PRL.CANCEL_FLAG
             ,'N') = 'N'
            AND PRL.LINE_LOCATION_ID is null
          UNION ALL
          SELECT
            PRI.WIP_ENTITY_ID
          FROM
            PO_REQUISITIONS_INTERFACE_ALL PRI
          WHERE PRI.DESTINATION_ORGANIZATION_ID = P_ORGANIZATION_ID );
    RETURN 1;
  END QR_PTXN_JOBREFCURDS;

  /*FUNCTION QR_PTXN_CTREFCURDS(WIP_ENTITY_ID_1 IN NUMBER) RETURN number IS
    JOB_PTXN_CT PTXN_CT_TYPE;
    L_COUNT NUMBER := 0;
    L_CTMP NUMBER := 0;
  BEGIN

    BEGIN

      SELECT
        1
      INTO L_COUNT
      FROM
        DUAL
      WHERE exists (
        SELECT
          1
        FROM
          WIP_MOVE_TXN_INTERFACE
        WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
          AND WIP_ENTITY_ID = WIP_ENTITY_ID_1
        UNION ALL
        SELECT
          1
        FROM
          WSM_LOT_MOVE_TXN_INTERFACE
        WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
          AND WIP_ENTITY_ID = WIP_ENTITY_ID_1
          AND STATUS <> 4 );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_COUNT := 0;
      WHEN TOO_MANY_ROWS THEN
        L_COUNT := 1;
    END;
    IF L_COUNT = 1 THEN
      INSERT INTO WSM_PEND_TXN_REP_TMP
      VALUES   (WIP_ENTITY_ID_1
        ,'Pending Move Transactions');
    END IF;
    BEGIN
      SELECT
        1
      INTO L_COUNT
      FROM
        DUAL
      WHERE exists (
        SELECT
          1
        FROM
          WIP_COST_TXN_INTERFACE
        WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
          AND WIP_ENTITY_ID = WIP_ENTITY_ID_1 );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_COUNT := 0;
      WHEN TOO_MANY_ROWS THEN
        L_COUNT := 1;
    END;
    IF L_COUNT = 1 THEN
      INSERT INTO WSM_PEND_TXN_REP_TMP
      VALUES   (WIP_ENTITY_ID_1
        ,'Pending Resource Transactions');
    END IF;
    BEGIN
      SELECT
        1
      INTO L_COUNT
      FROM
        DUAL
      WHERE exists (
        SELECT
          1
        FROM
          MTL_MATERIAL_TRANSACTIONS_TEMP
        WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
          AND TRANSACTION_SOURCE_ID = WIP_ENTITY_ID_1
          AND TRANSACTION_SOURCE_TYPE_ID = 5 );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_COUNT := 0;
      WHEN TOO_MANY_ROWS THEN
        L_COUNT := 1;
    END;
    IF L_COUNT = 1 THEN
      INSERT INTO WSM_PEND_TXN_REP_TMP
      VALUES   (WIP_ENTITY_ID_1
        ,'Pending Material Transactions');
    END IF;
    BEGIN
      SELECT
        1
      INTO L_COUNT
      FROM
        DUAL
      WHERE exists (
        SELECT
          1
        FROM
          MTL_MATERIAL_TRANSACTIONS
        WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
          AND TRANSACTION_SOURCE_ID = WIP_ENTITY_ID_1
          AND COSTED_FLAG IN ( 'N' , 'E' )
          AND TRANSACTION_SOURCE_TYPE_ID = 5 );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_COUNT := 0;
      WHEN TOO_MANY_ROWS THEN
        L_COUNT := 1;
    END;
    IF L_COUNT = 1 THEN
      INSERT INTO WSM_PEND_TXN_REP_TMP
      VALUES   (WIP_ENTITY_ID_1
        ,'Uncosted Material Transactions');
    END IF;
    BEGIN
      SELECT
        1
      INTO L_COUNT
      FROM
        DUAL
      WHERE exists (
        SELECT
          1
        FROM
          WIP_OPERATION_YIELDS
        WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
          AND WIP_ENTITY_ID = WIP_ENTITY_ID_1
          AND STATUS in ( 1 , 3 ) );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_COUNT := 0;
      WHEN TOO_MANY_ROWS THEN
        L_COUNT := 1;
    END;
    IF L_COUNT = 1 THEN
      INSERT INTO WSM_PEND_TXN_REP_TMP
      VALUES   (WIP_ENTITY_ID_1
        ,'Pending Operation Yield');
    END IF;
    BEGIN
      SELECT
        1
      INTO L_COUNT
      FROM
        DUAL
      WHERE exists (
        SELECT
          1
        FROM
          WSM_SM_STARTING_JOBS SJ,
          WSM_SPLIT_MERGE_TRANSACTIONS WMT
        WHERE SJ.WIP_ENTITY_ID = WIP_ENTITY_ID_1
          AND SJ.TRANSACTION_ID = WMT.TRANSACTION_ID
          AND WMT.ORGANIZATION_ID = P_ORGANIZATION_ID
          AND WMT.STATUS <> 4
        UNION
        SELECT
          1
        FROM
          WSM_SM_RESULTING_JOBS RJ,
          WSM_SPLIT_MERGE_TRANSACTIONS WMT
        WHERE RJ.WIP_ENTITY_ID = WIP_ENTITY_ID_1
          AND RJ.TRANSACTION_ID = WMT.TRANSACTION_ID
          AND WMT.ORGANIZATION_ID = P_ORGANIZATION_ID
          AND WMT.STATUS <> 4 );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_COUNT := 0;
      WHEN TOO_MANY_ROWS THEN
        L_COUNT := 1;
    END;
    IF L_COUNT = 1 THEN
      INSERT INTO WSM_PEND_TXN_REP_TMP
      VALUES   (WIP_ENTITY_ID_1
        ,'Pending WIP Lot Transactions');
    END IF;
    BEGIN
      SELECT
        1
      INTO L_COUNT
      FROM
        DUAL
      WHERE exists (
        SELECT
          1
        FROM
          WSM_SM_STARTING_JOBS SJ,
          WSM_SPLIT_MERGE_TRANSACTIONS WMT
        WHERE SJ.WIP_ENTITY_ID = WIP_ENTITY_ID_1
          AND SJ.TRANSACTION_ID = WMT.TRANSACTION_ID
          AND WMT.ORGANIZATION_ID = P_ORGANIZATION_ID
          AND NVL(WMT.COSTED
           ,1) <> 4
        UNION
        SELECT
          1
        FROM
          WSM_SM_RESULTING_JOBS RJ,
          WSM_SPLIT_MERGE_TRANSACTIONS WMT
        WHERE RJ.WIP_ENTITY_ID = WIP_ENTITY_ID_1
          AND RJ.TRANSACTION_ID = WMT.TRANSACTION_ID
          AND WMT.ORGANIZATION_ID = P_ORGANIZATION_ID
          AND NVL(WMT.COSTED
           ,1) <> 4 );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_COUNT := 0;
      WHEN TOO_MANY_ROWS THEN
        L_COUNT := 1;
    END;
    IF L_COUNT = 1 THEN
      INSERT INTO WSM_PEND_TXN_REP_TMP
      VALUES   (WIP_ENTITY_ID_1
        ,'Uncosted WIP Lot Transactions ');
    END IF;
    BEGIN
      SELECT
        1
      INTO L_COUNT
      FROM
        DUAL
      WHERE exists (
        SELECT
          1
        FROM
          PO_RELEASES_ALL PR,
          PO_HEADERS_ALL PH,
          PO_DISTRIBUTIONS_ALL PD,
          PO_LINE_LOCATIONS_ALL PL
        WHERE PD.DESTINATION_ORGANIZATION_ID = P_ORGANIZATION_ID
          AND PD.WIP_ENTITY_ID = WIP_ENTITY_ID_1
          AND PD.PO_LINE_ID is not null
          AND PD.LINE_LOCATION_ID is not null
          AND PL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
          AND PH.PO_HEADER_ID = PD.PO_HEADER_ID
          AND PL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
          AND pr.po_release_id (+) = PD.PO_RELEASE_ID
          AND NVL(PR.CANCEL_FLAG
           ,'N') = 'N'
          AND ( PL.QUANTITY_RECEIVED < ( PL.QUANTITY - PL.QUANTITY_CANCELLED ) ) )
      OR exists (
        SELECT
          1
        FROM
          PO_REQUISITION_LINES_ALL PRL
        WHERE PRL.DESTINATION_ORGANIZATION_ID = P_ORGANIZATION_ID
          AND PRL.WIP_ENTITY_ID = WIP_ENTITY_ID_1
          AND NVL(PRL.CANCEL_FLAG
           ,'N') = 'N'
          AND PRL.LINE_LOCATION_ID is null )
      OR exists (
        SELECT
          1
        FROM
          PO_REQUISITIONS_INTERFACE_ALL PRI
        WHERE PRI.DESTINATION_ORGANIZATION_ID = P_ORGANIZATION_ID
          AND PRI.WIP_ENTITY_ID = WIP_ENTITY_ID_1 );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_COUNT := 0;
      WHEN TOO_MANY_ROWS THEN
        L_COUNT := 1;
    END;
    IF L_COUNT = 1 THEN
      INSERT INTO WSM_PEND_TXN_REP_TMP
      VALUES   (WIP_ENTITY_ID_1
        ,'Pending PO Requisitions');
    END IF;
    \*OPEN JOB_PTXN_CT
    FOR SELECT
          *
        FROM
          WSM_PEND_TXN_REP_TMP
        WHERE WIP_ENTITY_ID = WIP_ENTITY_ID_1;*\
        \*SELECT wip_entity_id , ptxn_table
        BULK COLLECT INTO G_WSM_PEND_TXN_REP_PL_TBL
        FROM  WSM_PEND_TXN_REP_TMP
        WHERE WIP_ENTITY_ID = WIP_ENTITY_ID_1;*\
   commit;
    RETURN (1);
  END QR_PTXN_CTREFCURDS;*/

  FUNCTION CF_EXCLUDE_RESERVEFORMULA RETURN CHAR IS
  BEGIN
    IF (P_EXCLUDE_RESERVED_JOBS = 1) THEN
      RETURN ('and not exists (select 1 from WIP_RESERVATIONS_V wrv where wrv.wip_entity_id = wdj.wip_entity_id)');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END CF_EXCLUDE_RESERVEFORMULA;

  FUNCTION CF_EXCLUDE_UNCOMPFORMULA RETURN CHAR IS
  BEGIN
    IF (P_EXCLUDE_UNCOMPLETE_JOBS = 1) THEN
      RETURN ('and wdj.status_type in (4,5,14,15)');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END CF_EXCLUDE_UNCOMPFORMULA;

  FUNCTION CF_ORG_CODEFORMULA RETURN CHAR IS
    ORG_NAME VARCHAR2(240);
  BEGIN
    SELECT
      ORGANIZATION_NAME
    INTO ORG_NAME
    FROM
      ORG_ORGANIZATION_DEFINITIONS
    WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;
    RETURN (ORG_NAME);
  END CF_ORG_CODEFORMULA;

  FUNCTION CF_JOB_TYPEFORMULA RETURN CHAR IS
    ENTITY_TYPE VARCHAR2(80);
  BEGIN
    SELECT
      MEANING
    INTO ENTITY_TYPE
    FROM
      MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'WIP_ENTITY'
      AND LOOKUP_CODE = P_ENTITY_TYPE;
    RETURN (ENTITY_TYPE);
  END CF_JOB_TYPEFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF (P_FROM_CLASS IS NOT NULL) THEN
      IF (P_TO_CLASS IS NOT NULL) THEN
        P_CLASS_RANGE := 'and wdj.class_code between
                                                         :p_from_class and :p_to_class';
      ELSE
        P_CLASS_RANGE := 'and wdj.class_code >= :p_from_class';
      END IF;
    ELSE
      IF (P_TO_CLASS IS NOT NULL) THEN
        P_CLASS_RANGE := 'and wdj.class_code <= :p_to_class';
      ELSE
        P_CLASS_RANGE := '   ';
      END IF;
    END IF;
    IF (P_ACCT_CLASS_TYPE IS NULL) THEN
      P_CLASS_TYPE := '   ';
    ELSE
      P_CLASS_TYPE := 'and wac.class_type = to_char(:P_ACCT_CLASS_TYPE)';
    END IF;
    IF (P_FROM_COMPLETE_DATE IS NOT NULL) THEN
      IF (P_TO_COMPLETE_DATE IS NOT NULL) THEN
        P_DATE_COMPLETE := 'and trunc(wdj.date_completed) between to_date(to_char(:p_from_complete_date,''YYYY/MM/DD'')
                           		                    ,''YYYY/MM/DD'') and to_date(to_char(:p_to_complete_date,''YYYY/MM/DD''),''YYYY/MM/DD'')';
      ELSE
        P_DATE_COMPLETE := 'and trunc(wdj.date_completed) >= to_date(to_char(:p_from_complete_date,''YYYY/MM/DD'')
                           		                    ,''YYYY/MM/DD'')';
      END IF;
    ELSE
      IF (P_TO_COMPLETE_DATE IS NOT NULL) THEN
        P_DATE_COMPLETE := 'and trunc(wdj.date_completed) <= to_date(to_char(:p_to_complete_date,''YYYY/MM/DD'')
                           		                    ,''YYYY/MM/DD'')';
      ELSE
        P_DATE_COMPLETE := '   ';
      END IF;
    END IF;
    IF (P_FROM_JOB IS NOT NULL) THEN
      IF (P_TO_JOB IS NOT NULL) THEN
        P_JOB_NAME := 'and we.wip_entity_name between :p_from_job and :p_to_job';
      ELSE
        P_JOB_NAME := 'and we.wip_entity_name >= :p_from_job';
      END IF;
    ELSE
      IF (P_TO_JOB IS NOT NULL) THEN
        P_JOB_NAME := 'and we.wip_entity_name <= :p_to_job';
      ELSE
        P_JOB_NAME := '   ';
      END IF;
    END IF;
    IF (P_FROM_RELEASE_DATE IS NOT NULL) THEN
      IF (P_TO_RELEASE_DATE IS NOT NULL) THEN
        P_RELEASE_DATE := 'and trunc(wdj.date_released) between to_date(to_char(:p_from_release_date,''YYYY/MM/DD'')
                          		                 ,''YYYY/MM/DD'') and to_date(to_char(:p_to_release_date,''YYYY/MM/DD'')
                          		                 ,''YYYY/MM/DD'')';
      ELSE
        P_RELEASE_DATE := 'and trunc(wdj.date_released) >= to_date(to_char(:p_from_release_date,''YYYY/MM/DD'')
                          		 		,''YYYY/MM/DD'')';
      END IF;
    ELSE
      IF (P_TO_RELEASE_DATE IS NOT NULL) THEN
        P_RELEASE_DATE := 'and trunc(wdj.date_released) <= to_date(to_char(:p_to_release_date,''YYYY/MM/DD'')
                          		 		,''YYYY/MM/DD'')';
      ELSE
        P_RELEASE_DATE := '   ';
      END IF;
    END IF;
    IF (P_FROM_START_DATE IS NOT NULL) THEN
      IF (P_TO_START_DATE IS NOT NULL) THEN
        P_START_DATE := 'and trunc(wdj.scheduled_start_date) between to_date(to_char(:p_from_start_date,''YYYY/MM/DD'')
                        		                 ,''YYYY/MM/DD'') and to_date(to_char(:p_to_start_date,''YYYY/MM/DD''),''YYYY/MM/DD'')';
      ELSE
        P_START_DATE := 'and trunc(wdj.scheduled_start_date) >= to_date(to_char(:p_from_start_date,''YYYY/MM/DD'')
                        		                 ,''YYYY/MM/DD'')';
      END IF;
    ELSE
      IF (P_TO_START_DATE IS NOT NULL) THEN
        P_START_DATE := 'and trunc(wdj.scheduled_start_date) <= to_date(to_char(:p_to_start_date,''YYYY/MM/DD'')
                        		                 ,''YYYY/MM/DD'')';
      ELSE
        P_START_DATE := '   ';
      END IF;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION P_DATE_COMPLETEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_DATE_COMPLETEVALIDTRIGGER;

  FUNCTION CF_TIMEZONEFORMULA RETURN CHAR IS
  BEGIN
    RETURN FND_TIMEZONES.GET_NAME(FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE);
  END CF_TIMEZONEFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

END WSM_WSMPNTXN_XMLP_PKG;



/
