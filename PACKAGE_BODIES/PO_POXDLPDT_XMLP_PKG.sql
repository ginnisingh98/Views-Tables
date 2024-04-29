--------------------------------------------------------
--  DDL for Package Body PO_POXDLPDT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXDLPDT_XMLP_PKG" AS
/* $Header: POXDLPDTB.pls 120.1 2007/12/25 10:56:37 krreddy noship $ */
  FUNCTION GET_P_STRUCT_NUM RETURN BOOLEAN IS
    L_P_STRUCT_NUM NUMBER;
  BEGIN
    SELECT
      STRUCTURE_ID
    INTO L_P_STRUCT_NUM
    FROM
      MTL_DEFAULT_SETS_VIEW
    WHERE FUNCTIONAL_AREA_ID = 2;
    P_STRUCT_NUM := L_P_STRUCT_NUM;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);

  END GET_P_STRUCT_NUM;

  FUNCTION BUYER_PREPARERFORMULA(RRP_TRANSACTION_TYPE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN BOILER_PLATE_BUYER(RRP_TRANSACTION_TYPE);
  END BUYER_PREPARERFORMULA;

  FUNCTION DIRECT_RECEIVING_CHECK(RRP_FROM_INTERFACE IN VARCHAR2
                                 ,RRP_TRANSACTION_ID IN NUMBER) RETURN BOOLEAN IS
    L_USER_ENTERED_FLAG RCV_TRANSACTIONS.USER_ENTERED_FLAG%TYPE;
    L_PARENT_TRANSACTION_ID RCV_TRANSACTIONS.PARENT_TRANSACTION_ID%TYPE;
    L_TRANSACTION_ID RCV_TRANSACTIONS.TRANSACTION_ID%TYPE;
    L_AUTO_TRANSACT_CODE RCV_TRANSACTIONS_INTERFACE.AUTO_TRANSACT_CODE%TYPE;
    L_TRANSACTION_TYPE RCV_TRANSACTIONS_INTERFACE.TRANSACTION_TYPE%TYPE;
  BEGIN
    IF (RRP_FROM_INTERFACE = 'N') THEN
      BEGIN
        SELECT
          TRANSACTION_TYPE
        INTO L_TRANSACTION_TYPE
        FROM
          RCV_TRANSACTIONS
        WHERE TRANSACTION_ID = RRP_TRANSACTION_ID;
        IF (L_TRANSACTION_TYPE = 'DELIVER') THEN
          RETURN FALSE;
        ELSE
          RETURN TRUE;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN TRUE;

        WHEN OTHERS THEN
          RETURN TRUE;

      END;
    ELSE
      BEGIN
        SELECT
          AUTO_TRANSACT_CODE,
          TRANSACTION_TYPE
        INTO L_AUTO_TRANSACT_CODE,L_TRANSACTION_TYPE
        FROM
          RCV_TRANSACTIONS_INTERFACE
        WHERE INTERFACE_TRANSACTION_ID = RRP_TRANSACTION_ID;
        BEGIN
          IF (L_AUTO_TRANSACT_CODE = 'DELIVER') THEN
            RETURN FALSE;
          ELSIF L_AUTO_TRANSACT_CODE IS NULL THEN
            IF (L_TRANSACTION_TYPE = 'DELIVER') THEN
              RETURN FALSE;
            ELSE
              RETURN TRUE;
            END IF;
          END IF;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          RETURN TRUE;

      END;
    END IF;
    RETURN NULL;
  END DIRECT_RECEIVING_CHECK;

  FUNCTION BLIND_RECEIVING_CHECK(RRP_ORGANIZATION_ID IN NUMBER) RETURN BOOLEAN IS
    L_BLIND_RECEIVING_FLAG RCV_PARAMETERS.BLIND_RECEIVING_FLAG%TYPE;
  BEGIN
    SELECT
      BLIND_RECEIVING_FLAG
    INTO L_BLIND_RECEIVING_FLAG
    FROM
      RCV_PARAMETERS
    WHERE ORGANIZATION_ID = RRP_ORGANIZATION_ID;
    IF (L_BLIND_RECEIVING_FLAG = 'Y') THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN TRUE;

  END BLIND_RECEIVING_CHECK;

  FUNCTION BOILER_PLATE_DOC_TYPE(RRP_TRANSACTION_TYPE IN VARCHAR2) RETURN CHARACTER IS
    L_TRANSACTION_TYPE VARCHAR2(20);
    L_DISPLAYED_FIELD PO_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
  BEGIN
    L_TRANSACTION_TYPE := RRP_TRANSACTION_TYPE;
    IF (L_TRANSACTION_TYPE = 'IN TRANSIT') THEN
      BEGIN
        SELECT
          DISPLAYED_FIELD
        INTO L_DISPLAYED_FIELD
        FROM
          PO_LOOKUP_CODES
        WHERE LOOKUP_TYPE = 'POXDLPDT TRANSLATE'
          AND LOOKUP_CODE = 'TYPE';
        RETURN (L_DISPLAYED_FIELD);
      END;
    ELSE
      BEGIN
        SELECT
          DISPLAYED_FIELD
        INTO L_DISPLAYED_FIELD
        FROM
          PO_LOOKUP_CODES
        WHERE LOOKUP_TYPE = 'POXDLPDT TRANSLATE'
          AND LOOKUP_CODE = 'DOCUMENT TYPE';
        RETURN (L_DISPLAYED_FIELD);
      END;
    END IF;
    RETURN NULL;
  END BOILER_PLATE_DOC_TYPE;

  FUNCTION BOILER_PLATE_DOC_NUM(RRP_TRANSACTION_TYPE IN VARCHAR2) RETURN CHARACTER IS
    L_TRANSACTION_TYPE VARCHAR2(20);
    L_DISPLAYED_FIELD PO_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
  BEGIN
    L_TRANSACTION_TYPE := RRP_TRANSACTION_TYPE;
    IF (L_TRANSACTION_TYPE = 'IN TRANSIT') THEN
      BEGIN
        SELECT
          DISPLAYED_FIELD
        INTO L_DISPLAYED_FIELD
        FROM
          PO_LOOKUP_CODES
        WHERE LOOKUP_TYPE = 'POXDLPDT TRANSLATE'
          AND LOOKUP_CODE = 'SHIPMENT NUMBER';
        RETURN (L_DISPLAYED_FIELD);
      END;
    ELSE
      BEGIN
        SELECT
          DISPLAYED_FIELD
        INTO L_DISPLAYED_FIELD
        FROM
          PO_LOOKUP_CODES
        WHERE LOOKUP_TYPE = 'POXDLPDT TRANSLATE'
          AND LOOKUP_CODE = 'DOCUMENT NUMBER';
        RETURN (L_DISPLAYED_FIELD);
      END;
    END IF;
    RETURN NULL;
  END BOILER_PLATE_DOC_NUM;

  FUNCTION BOILER_PLATE_BUYER(RRP_TRANSACTION_TYPE IN VARCHAR2) RETURN CHARACTER IS
    L_TRANSACTION_TYPE VARCHAR2(20);
    L_DISPLAYED_FIELD PO_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
  BEGIN
    L_TRANSACTION_TYPE := RRP_TRANSACTION_TYPE;
    IF (L_TRANSACTION_TYPE = 'PO') THEN
      BEGIN
        SELECT
          DISPLAYED_FIELD
        INTO L_DISPLAYED_FIELD
        FROM
          PO_LOOKUP_CODES
        WHERE LOOKUP_TYPE = 'POXDLPDT TRANSLATE'
          AND LOOKUP_CODE = 'BUYER';
        RETURN (L_DISPLAYED_FIELD);
      END;
    ELSIF (L_TRANSACTION_TYPE = 'REQ') THEN
      BEGIN
        SELECT
          DISPLAYED_FIELD
        INTO L_DISPLAYED_FIELD
        FROM
          PO_LOOKUP_CODES
        WHERE LOOKUP_TYPE = 'POXDLPDT TRANSLATE'
          AND LOOKUP_CODE = 'PREPARER';
        RETURN (L_DISPLAYED_FIELD);
      END;
    ELSE
      RETURN ('');
    END IF;
    RETURN NULL;
  END BOILER_PLATE_BUYER;

  FUNCTION DOC_TYPE_BOILERPLATEFORMULA(RRP_TRANSACTION_TYPE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN BOILER_PLATE_DOC_TYPE(RRP_TRANSACTION_TYPE);
  END DOC_TYPE_BOILERPLATEFORMULA;

  FUNCTION DOC_NUM_BOILER_PLATEFORMULA(RRP_TRANSACTION_TYPE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN BOILER_PLATE_DOC_NUM(RRP_TRANSACTION_TYPE);
  END DOC_NUM_BOILER_PLATEFORMULA;

  FUNCTION DELIVERY_CHECK(RRP_FROM_INTERFACE IN VARCHAR2
                         ,RRP_TRANSACTION_ID IN NUMBER) RETURN BOOLEAN IS
    L_TRANSACTION_TYPE RCV_TRANSACTIONS.TRANSACTION_TYPE%TYPE;
    L_TRANSACTION_ID RCV_TRANSACTIONS.TRANSACTION_ID%TYPE;
    L_AUTO_TRANSACT_CODE RCV_TRANSACTIONS_INTERFACE.AUTO_TRANSACT_CODE%TYPE;
  BEGIN
    IF (RRP_FROM_INTERFACE = 'N') THEN
      BEGIN
        SELECT
          TRANSACTION_TYPE
        INTO L_TRANSACTION_TYPE
        FROM
          RCV_TRANSACTIONS
        WHERE TRANSACTION_ID = RRP_TRANSACTION_ID;
        IF (L_TRANSACTION_TYPE = 'DELIVER') THEN
          RETURN FALSE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          RETURN TRUE;

      END;
    ELSE
      BEGIN
        SELECT
          AUTO_TRANSACT_CODE
        INTO L_AUTO_TRANSACT_CODE
        FROM
          RCV_TRANSACTIONS_INTERFACE
        WHERE INTERFACE_TRANSACTION_ID = RRP_TRANSACTION_ID;
        BEGIN
          IF (L_AUTO_TRANSACT_CODE = 'DELIVER') THEN
            RETURN FALSE;
          ELSIF L_AUTO_TRANSACT_CODE IS NULL THEN
            IF (L_TRANSACTION_TYPE = 'DELIVER') THEN
              RETURN FALSE;
            ELSE
              RETURN TRUE;
            END IF;
          END IF;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          RETURN TRUE;

      END;
    END IF;
    RETURN NULL;
  END DELIVERY_CHECK;

  FUNCTION CHILD_DIRECT_RECEIVING_CHECK(RRP_FROM_INTERFACE IN VARCHAR2
                                       ,RRP_TRANSACTION_ID IN NUMBER) RETURN BOOLEAN IS
    L_USER_ENTERED_FLAG RCV_TRANSACTIONS.USER_ENTERED_FLAG%TYPE;
    L_PARENT_TRANSACTION_ID RCV_TRANSACTIONS.PARENT_TRANSACTION_ID%TYPE;
    L_TRANSACTION_TYPE RCV_TRANSACTIONS.TRANSACTION_TYPE%TYPE;
    L_AUTO_TRANSACT_CODE RCV_TRANSACTIONS_INTERFACE.AUTO_TRANSACT_CODE%TYPE;
  BEGIN
    IF (RRP_FROM_INTERFACE = 'N') THEN
      BEGIN
        SELECT
          USER_ENTERED_FLAG,
          TRANSACTION_TYPE
        INTO L_USER_ENTERED_FLAG,L_TRANSACTION_TYPE
        FROM
          RCV_TRANSACTIONS
        WHERE PARENT_TRANSACTION_ID = RRP_TRANSACTION_ID;
        IF (L_TRANSACTION_TYPE <> 'DELIVER') THEN
          RETURN TRUE;
        ELSIF (L_USER_ENTERED_FLAG = 'Y') THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          RETURN TRUE;

        WHEN NO_DATA_FOUND THEN
          RETURN TRUE;

        WHEN OTHERS THEN
          RETURN TRUE;

      END;
    ELSE
      RETURN TRUE;
    END IF;
    RETURN NULL;
  END CHILD_DIRECT_RECEIVING_CHECK;

  FUNCTION G_RECEIPTSGROUPFILTER(RRP_TRANSACTION_ID IN NUMBER
                                ,RRP_FROM_INTERFACE IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN CHILD_DIRECT_RECEIVING_CHECK(RRP_FROM_INTERFACE
                                       ,RRP_TRANSACTION_ID);
    RETURN (TRUE);
  END G_RECEIPTSGROUPFILTER;

  FUNCTION C_UNION_UPPER_UPPERFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF (P_WIP_STATUS = 'I') THEN
      RETURN ('SELECT WE.WIP_ENTITY_NAME                 Work_Order
             ,       to_char(null)                                    Line
             ,      WRO.DATE_REQUIRED                  Date_Required
             ,      SUM(NVL(WRO.QUANTITY_ISSUED,0))                Quantity_Issued
             ,      SUM(NVL(WRO.REQUIRED_QUANTITY,0))           Quantity_Required
             ,       NVL(MOQ2.TRANSACTION_QUANTITY,0)        Quantity_On_Hand
             ,      ''D''                                                                                                    Processing_Mode');
    END IF;
    RETURN NULL;
  END C_UNION_UPPER_UPPERFORMULA;

  FUNCTION C_UNION_LOWER_UPPERFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF (P_WIP_STATUS = 'I') THEN
      RETURN ('SELECT WE.WIP_ENTITY_NAME                 Work_Order
             ,      WL.LINE_CODE                         Line
             ,      WRO.DATE_REQUIRED                  Date_Required
             ,      SUM(WRO.QUANTITY_ISSUED)                Quantity_Issued
             ,      SUM((LEAST(BCD.NEXT_SEQ_NUM + WRS.PROCESSING_WORK_DAYS,BCD1.NEXT_SEQ_NUM + MSI.POSTPROCESSING_LEAD_TIME)
                       - GREATEST(BCD.NEXT_SEQ_NUM,BCD1.NEXT_SEQ_NUM))
                       * WRO.QUANTITY_PER_ASSEMBLY * WRS.DAILY_PRODUCTION_RATE )
             /* this is raw quantity required */
                     +    -1 *  SUM(WRO.QUANTITY_ISSUED -
                        GREATEST((BCD1.NEXT_SEQ_NUM-BCD.NEXT_SEQ_NUM),0)
                    *WRO.QUANTITY_PER_ASSEMBLY * WRS.DAILY_PRODUCTION_RATE)
             /* this is the quantity ahead behind after taking care of the negative sign as quantity ahead behind
             will always be calulated as negative*/
                                                         Quantity_Required
             ,      NVL(MOQ2.TRANSACTION_QUANTITY,0)         Quantity_On_Hand
             ,      ''R''                                      Processing_Mode');
    END IF;
    RETURN NULL;
  END C_UNION_LOWER_UPPERFORMULA;

  FUNCTION C_UNION_LOWER_LOWERFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF (P_WIP_STATUS = 'I') THEN
      RETURN ('FROM MTL_ONHAND_QUANTITIES MOQ2
             ,      WIP_ENTITIES WE
             ,      WIP_REQUIREMENT_OPERATIONS WRO
             ,      WIP_REPETITIVE_SCHEDULES  WRS
             ,      BOM_CALENDAR_DATES BCD
             ,      BOM_CALENDAR_DATES BCD1
             ,      WIP_LINES WL
             ,      MTL_PARAMETERS MP
             ,      MTL_SYSTEM_ITEMS MSI
             WHERE  WRS.STATUS_TYPE IN (1,3,4,6)
             AND    WE.WIP_ENTITY_ID = WRS.WIP_ENTITY_ID
             AND    WE.ORGANIZATION_ID = WRS.ORGANIZATION_ID
             AND    MP.ORGANIZATION_ID =  WRS.ORGANIZATION_ID
             AND    BCD1.CALENDAR_CODE = MP.CALENDAR_CODE
             AND    BCD1.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
             AND    BCD1.CALENDAR_DATE = to_char(sysdate,''DD-MON-RR'')
             AND    NVL(MSI.ORGANIZATION_ID,MP.ORGANIZATION_ID)= MP.ORGANIZATION_ID
             AND    WRO.WIP_ENTITY_ID = WRS.WIP_ENTITY_ID
             AND    WRO.REPETITIVE_SCHEDULE_ID = WRS.REPETITIVE_SCHEDULE_ID
             AND    WRO.ORGANIZATION_ID = WRS.ORGANIZATION_ID
             AND    WRO.WIP_SUPPLY_TYPE <> 6
             AND    WRO.REQUIRED_QUANTITY > 0
             AND    MOQ2.ORGANIZATION_ID (+) =  WRO.ORGANIZATION_ID
             AND    MOQ2.INVENTORY_ITEM_ID (+) = WRO.INVENTORY_ITEM_ID
             AND     WL.LINE_ID = WRS.LINE_ID
             AND     WL.ORGANIZATION_ID = WRS.ORGANIZATION_ID
             AND    BCD.CALENDAR_CODE = MP.CALENDAR_CODE
             AND    BCD.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
             AND    BCD.CALENDAR_DATE = WRO.DATE_REQUIRED
             AND    (BCD.NEXT_SEQ_NUM < BCD1.NEXT_SEQ_NUM + MSI.POSTPROCESSING_LEAD_TIME)
             AND    ((BCD.NEXT_SEQ_NUM + WRS.PROCESSING_WORK_DAYS ) > BCD1.NEXT_SEQ_NUM)
             AND    NVL(MSI.ORGANIZATION_ID,MP.ORGANIZATION_ID)= MP.ORGANIZATION_ID
             AND    MSI.INVENTORY_ITEM_ID = WRO.INVENTORY_ITEM_ID
             GROUP BY WL.LINE_CODE
             ,      WL.DESCRIPTION
             ,      WE.WIP_ENTITY_NAME
             ,      WE.DESCRIPTION
             ,      NVL(WRO.SUPPLY_SUBINVENTORY,'' '')
             --,      MOQ2.SUBINVENTORY_CODE
             --,      MOQ2.LOCATOR_ID
             --,      DECODE(MOQ2.SUBINVENTORY_CODE,NVL(WRO.SUPPLY_SUBINVENTORY,''-1''),
             --,       DECODE(NVL(MOQ2.LOCATOR_ID,-1),NVL(WRO.SUPPLY_LOCATOR_ID,-1),1,0),0)
             ,      NVL(MOQ2.TRANSACTION_QUANTITY,0)
             ,      WRO.DATE_REQUIRED
             ,      WRS.ORGANIZATION_ID
             ,        wro.inventory_item_id
             HAVING (SUM((LEAST(BCD.NEXT_SEQ_NUM + WRS.PROCESSING_WORK_DAYS,
                                           BCD1.NEXT_SEQ_NUM + MSI.POSTPROCESSING_LEAD_TIME)
                                           - GREATEST(BCD.NEXT_SEQ_NUM, BCD1.NEXT_SEQ_NUM ))
                                           * WRO.QUANTITY_PER_ASSEMBLY * WRS.DAILY_PRODUCTION_RATE )
                                          + SUM(GREATEST((BCD1.NEXT_SEQ_NUM-BCD.NEXT_SEQ_NUM),0)
                                            *WRO.QUANTITY_PER_ASSEMBLY * WRS.DAILY_PRODUCTION_RATE)
                                          - SUM(WRO.QUANTITY_ISSUED)) > 0');
    END IF;
    RETURN NULL;
  END C_UNION_LOWER_LOWERFORMULA;

  FUNCTION C_UNION_UPPER_LOWERFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF (P_WIP_STATUS = 'I') THEN
      RETURN ('FROM MTL_ONHAND_QUANTITIES MOQ2
             ,      WIP_ENTITIES WE
             ,      WIP_REQUIREMENT_OPERATIONS WRO
             ,      WIP_DISCRETE_JOBS WDJ
             WHERE  WDJ.STATUS_TYPE IN (1,3,4,6)
             AND    WE.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
             AND    WE.ORGANIZATION_ID = WDJ.ORGANIZATION_ID
             AND    WRO.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
             AND    WRO.ORGANIZATION_ID = WDJ.ORGANIZATION_ID
             AND    WRO.WIP_SUPPLY_TYPE <> 6
             AND    WRO.REQUIRED_QUANTITY > 0
             AND    MOQ2.ORGANIZATION_ID(+) = WRO.ORGANIZATION_ID
             AND    MOQ2.INVENTORY_ITEM_ID(+) = WRO.INVENTORY_ITEM_ID
             GROUP BY WE.WIP_ENTITY_NAME
             ,      WRO.DATE_REQUIRED
             ,      WDJ.ORGANIZATION_ID
             ,      WRO.INVENTORY_ITEM_ID
             ,      WE.DESCRIPTION
             ,      NVL(WDJ.PRIMARY_ITEM_ID,-1)
             ,      WDJ.SCHEDULED_START_DATE
             ,      WDJ.START_QUANTITY
             ,      WDJ.SCHEDULED_COMPLETION_DATE
             ,      WRO.SUPPLY_SUBINVENTORY
             ,      NVL(MOQ2.TRANSACTION_QUANTITY,0)
             --,      WRO.QUANTITY_ISSUED
             --,      WRO.REQUIRED_QUANTITY
             --,      WRO.REQUIRED_QUANTITY - WRO.QUANTITY_ISSUED
             --,      MOQ2.SUBINVENTORY_CODE
             --,      MOQ2.LOCATOR_ID
             --,      DECODE(MOQ2.SUBINVENTORY_CODE,NVL(WRO.SUPPLY_SUBINVENTORY,''-1'')
             --,      DECODE(NVL(MOQ2.LOCATOR_ID,-1),NVL(WRO.SUPPLY_LOCATOR_ID,-1),1,0),0)
             HAVING SUM(NVL(WRO.REQUIRED_QUANTITY,0)) - SUM(NVL(WRO.QUANTITY_ISSUED,0)) > 0');
    END IF;
    RETURN NULL;
  END C_UNION_UPPER_LOWERFORMULA;

  FUNCTION WIP_SELECT_DISTFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF (P_WIP_STATUS = 'I') THEN
      RETURN (',         we.wip_entity_name          job_or_schedule
             ,        wl.line_code               line
             ,        wn.operation_seq_num   op_seq
             ,        bd.department_code      department');
    END IF;
    RETURN NULL;
  END WIP_SELECT_DISTFORMULA;

  FUNCTION WIP_FROM_DISTFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF (P_WIP_STATUS = 'I') THEN
      RETURN ('wip_lines wl,
             wip_entities we,
             bom_departments bd,
             wip_operation_resources wr,
             wip_operations wn,
             wip_operations wo,');
    END IF;
    RETURN NULL;
  END WIP_FROM_DISTFORMULA;

  FUNCTION WIP_WHERE_DISTFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF (P_WIP_STATUS = 'I') THEN
      RETURN ('AND      wo.wip_entity_id = rdp.wip_entity_id
                and wo.organization_id = rdp.organization_id
                and nvl(wo.repetitive_schedule_id, -1) = nvl(rdp.wip_repetitive_schedule_id, -1)
                and wo.operation_seq_num = rdp.wip_operation_seq_num
                and wl.line_id (+)  = rdp.wip_line_id
                and wr.wip_entity_id = rdp.wip_entity_id
                and wr.organization_id = rdp.organization_id
                and nvl(wr.repetitive_schedule_id, -1) = nvl(rdp.wip_repetitive_schedule_id, -1)
                and wr.operation_seq_num = rdp.wip_operation_seq_num
                and wr.resource_seq_num = rdp.wip_resource_seq_num
                and wn.wip_entity_id = rdp.wip_entity_id
                and wn.organization_id = rdp.organization_id
                and nvl(wn.repetitive_schedule_id, -1) = nvl(rdp.wip_repetitive_schedule_id, -1)
                and wn.operation_seq_num =
                        decode(wr.autocharge_type,
                                  4, nvl(wo.next_operation_seq_num, wo.operation_seq_num),
                                  wo.operation_seq_num)
                and bd.department_id = wn.department_id
                and we.wip_entity_id = rdp.wip_entity_id
                and we.organization_id = rdp.organization_id');
    END IF;
    RETURN NULL;
  END WIP_WHERE_DISTFORMULA;

  FUNCTION WIP_WHERE_DIST_INTERFACEFORMUL RETURN VARCHAR2 IS
  BEGIN
    IF (P_WIP_STATUS = 'I') THEN
      RETURN ('AND     wo.wip_entity_id = rdp.wip_entity_id
                and wo.organization_id = rct.to_organization_id
                and nvl(wo.repetitive_schedule_id, -1) = nvl(rdp.wip_repetitive_schedule_id, -1)
                and wo.operation_seq_num = rdp.wip_operation_seq_num
                and wl.line_id = rdp.wip_line_id
                and wr.wip_entity_id = rdp.wip_entity_id
                and wr.organization_id = rct.to_organization_id
                and nvl(wr.repetitive_schedule_id, -1) = nvl(rdp.wip_repetitive_schedule_id, -1)
                and wr.operation_seq_num = rdp.wip_operation_seq_num
                and wr.resource_seq_num = rdp.wip_resource_seq_num
                and wn.wip_entity_id = rdp.wip_entity_id
                and wn.organization_id = rct.to_organization_id
                and nvl(wn.repetitive_schedule_id, -1) = nvl(rdp.wip_repetitive_schedule_id, -1)
                and wn.operation_seq_num =
                        decode(wr.autocharge_type,
                                  4, nvl(wo.next_operation_seq_num, wo.operation_seq_num),
                                  wo.operation_seq_num)
                and bd.department_id = wn.department_id
                and we.wip_entity_id = rdp.wip_entity_id
                and we.organization_id = rct.to_organization_id');
    END IF;
    RETURN NULL;
  END WIP_WHERE_DIST_INTERFACEFORMUL;

  FUNCTION C_SET_RT_NUMFORMULA(COUNT_DISTRIBUTIONS IN NUMBER
                              ,RRP_TRANSACTION_ID IN NUMBER
                              ,RRP_FROM_INTERFACE IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF (COUNT_DISTRIBUTIONS >= 0) THEN
      IF (CHILD_DIRECT_RECEIVING_CHECK(RRP_FROM_INTERFACE
                                  ,RRP_TRANSACTION_ID)) THEN
        C_NUM_RTS_PRINTED := C_NUM_RTS_PRINTED + 1;
      END IF;
    END IF;
    RETURN 1;
  END C_SET_RT_NUMFORMULA;

  FUNCTION QUANTITY_RECEIVED_fn(RRP_FROM_INTERFACE IN VARCHAR2
                            ,RRP_TRANSACTION_ID IN NUMBER
                            ,PARENT_PRIMARY_QUANTITY IN NUMBER
                            ,C_SUM_CORRECTED_QTY IN NUMBER
                            ,QUANTITY_RECEIVED IN NUMBER
                            ,RRP_SHIPMENT_LINE_ID IN NUMBER
                            ,RECEIPT_UNIT_OF_MEASURE IN VARCHAR2
                            ,ITEM_ID IN NUMBER) RETURN NUMBER IS
    QTY NUMBER;
    QTY_IN_RCT_UOM NUMBER;
    L_TRANSACTION_TYPE RCV_TRANSACTIONS.TRANSACTION_TYPE%TYPE;
    L_UOM RCV_SHIPMENT_LINES.UNIT_OF_MEASURE%TYPE;
  BEGIN
    IF (RRP_FROM_INTERFACE = 'N') THEN
      SELECT
        TRANSACTION_TYPE
      INTO L_TRANSACTION_TYPE
      FROM
        RCV_TRANSACTIONS
      WHERE TRANSACTION_ID = RRP_TRANSACTION_ID;
    ELSE
      SELECT
        TRANSACTION_TYPE
      INTO L_TRANSACTION_TYPE
      FROM
        RCV_TRANSACTIONS_INTERFACE
      WHERE INTERFACE_TRANSACTION_ID = RRP_TRANSACTION_ID;
    END IF;
    IF L_TRANSACTION_TYPE <> 'DELIVER' THEN
      QTY := PARENT_PRIMARY_QUANTITY + NVL(C_SUM_CORRECTED_QTY
                ,0);
      QTY_IN_RCT_UOM := ((QTY * QUANTITY_RECEIVED) / (PARENT_PRIMARY_QUANTITY));
      RETURN (ROUND(QTY_IN_RCT_UOM
                  ,P_QTY_PRECISION));
    ELSE
      SELECT
        QUANTITY_RECEIVED,
        UNIT_OF_MEASURE
      INTO QTY,L_UOM
      FROM
        RCV_SHIPMENT_LINES
      WHERE SHIPMENT_LINE_ID = RRP_SHIPMENT_LINE_ID;
      QTY := QTY * PO_UOM_S.PO_UOM_CONVERT(L_UOM
                                    ,RECEIPT_UNIT_OF_MEASURE
                                    ,ITEM_ID);
      RETURN (ROUND(QTY
                  ,P_QTY_PRECISION));
    END IF;
  END QUANTITY_RECEIVED_fn;

  FUNCTION SUM_CORRECT_RTV(C_QTY_CORRECTED IN NUMBER
                          ,C_SUM_CORRECT_RTV_QTY IN NUMBER) RETURN NUMBER IS
    TOTAL NUMBER;
  BEGIN
    TOTAL := C_QTY_CORRECTED + C_SUM_CORRECT_RTV_QTY;
    RETURN (TOTAL);
  END SUM_CORRECT_RTV;

  PROCEDURE GET_PRECISION(ID IN NUMBER) IS
  BEGIN
    IF ID = 0 THEN
      NULL;
    ELSE
      IF ID = 1 THEN
        NULL;
      ELSE
        IF ID = 3 THEN
          NULL;
        ELSE
          IF ID = 4 THEN
            NULL;
          ELSE
            IF ID = 5 THEN
              NULL;
            ELSE
              IF ID = 6 THEN
                NULL;
              ELSE
                IF ID = 7 THEN
                  NULL;
                ELSE
                  IF ID = 8 THEN
                    NULL;
                  ELSE
                    IF ID = 9 THEN
                      NULL;
                    ELSE
                      IF ID = 10 THEN
                        NULL;
                      ELSE
                        IF ID = 11 THEN
                          NULL;
                        ELSE
                          IF ID = 12 THEN
                            NULL;
                          ELSE
                            IF ID = 13 THEN
                              NULL;
                            ELSE
                              NULL;
                            END IF;
                          END IF;
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  END GET_PRECISION;

  FUNCTION C_QUANTITY_REMAINING_PRINTFORM(QUANTITY_REMAINING IN NUMBER
                                         ,SOURCE_UNIT_OF_MEASURE IN VARCHAR2
                                         ,RECEIPT_UNIT_OF_MEASURE IN VARCHAR2
                                         ,ITEM_ID IN NUMBER
                                         ,RRP_ORGANIZATION_ID IN NUMBER) RETURN NUMBER IS
    CONVERTED_QTY NUMBER;
  BEGIN
    IF (BLIND_RECEIVING_CHECK(RRP_ORGANIZATION_ID) = TRUE) THEN
      CONVERTED_QTY := QUANTITY_REMAINING * PO_UOM_S.PO_UOM_CONVERT(SOURCE_UNIT_OF_MEASURE
                                              ,RECEIPT_UNIT_OF_MEASURE
                                              ,NVL(ITEM_ID
                                                 ,0));
      RETURN (ROUND(CONVERTED_QTY
                  ,P_QTY_PRECISION));
    ELSE
      RETURN (TO_NUMBER(''));
    END IF;
    RETURN NULL;
  END C_QUANTITY_REMAINING_PRINTFORM;

  FUNCTION QUANTITY_DELIVERED(PARENT_PRIMARY_QUANTITY IN NUMBER
                             ,C_SUM_CORRECTED_QTY IN NUMBER) RETURN NUMBER IS
    QTY NUMBER;
    QTY_IN_RCT_UOM NUMBER;
  BEGIN
    QTY := PARENT_PRIMARY_QUANTITY + NVL(C_SUM_CORRECTED_QTY
              ,0);
    RETURN (ROUND(QTY
                ,P_QTY_PRECISION));
  END QUANTITY_DELIVERED;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    EXECUTE IMMEDIATE
      'Alter session set sql_trace FALSE';
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION ITEM_NOTEFORMULA(ITEM_NOTE_DATATYPE_ID IN NUMBER
                           ,ITEM_NOTE_MEDIA_ID IN NUMBER) RETURN CHAR IS
    SHORT_NOTE VARCHAR2(2000);
    LONG_NOTE LONG;
  BEGIN
    IF ITEM_NOTE_DATATYPE_ID = 1 THEN
      SELECT
        SHORT_TEXT
      INTO SHORT_NOTE
      FROM
        FND_DOCUMENTS_SHORT_TEXT
      WHERE MEDIA_ID = ITEM_NOTE_MEDIA_ID;
      RETURN SHORT_NOTE;
    ELSIF ITEM_NOTE_DATATYPE_ID = 2 THEN
      SELECT
        LONG_TEXT
      INTO LONG_NOTE
      FROM
        FND_DOCUMENTS_LONG_TEXT
      WHERE MEDIA_ID = ITEM_NOTE_MEDIA_ID;
      RETURN LONG_NOTE;
    ELSE
      RETURN 'Attachment is not a Text format';
    END IF;
  END ITEM_NOTEFORMULA;

  FUNCTION LONG_NOTE1FORMULA(LONG_NOTE_DATATYPE_ID IN NUMBER
                            ,LONG_NOTE_MEDIA_ID IN NUMBER) RETURN CHAR IS
    SHORT_NOTE VARCHAR2(2000);
    LONG_NOTE LONG;
  BEGIN
    IF LONG_NOTE_DATATYPE_ID = 1 THEN
      SELECT
        SHORT_TEXT
      INTO SHORT_NOTE
      FROM
        FND_DOCUMENTS_SHORT_TEXT
      WHERE MEDIA_ID = LONG_NOTE_MEDIA_ID;
      RETURN SHORT_NOTE;
    ELSIF LONG_NOTE_DATATYPE_ID = 2 THEN
      SELECT
        LONG_TEXT
      INTO LONG_NOTE
      FROM
        FND_DOCUMENTS_LONG_TEXT
      WHERE MEDIA_ID = LONG_NOTE_MEDIA_ID;
      RETURN LONG_NOTE;
    ELSE
      RETURN 'Attachment is not a Text format';
    END IF;
  END LONG_NOTE1FORMULA;

  FUNCTION LONG_NOTE2FORMULA(TRX_NOTE_DATATYPE_ID IN NUMBER
                            ,TRX_NOTE_MEDIA_ID IN NUMBER) RETURN CHAR IS
    SHORT_NOTE VARCHAR2(2000);
    LONG_NOTE LONG;
  BEGIN
    IF TRX_NOTE_DATATYPE_ID = 1 THEN
      SELECT
        SHORT_TEXT
      INTO SHORT_NOTE
      FROM
        FND_DOCUMENTS_SHORT_TEXT
      WHERE MEDIA_ID = TRX_NOTE_MEDIA_ID;
      RETURN SHORT_NOTE;
    ELSIF TRX_NOTE_DATATYPE_ID = 2 THEN
      SELECT
        LONG_TEXT
      INTO LONG_NOTE
      FROM
        FND_DOCUMENTS_LONG_TEXT
      WHERE MEDIA_ID = TRX_NOTE_MEDIA_ID;
      RETURN LONG_NOTE;
    ELSE
      RETURN 'Attachment is not a Text format';
    END IF;
  END LONG_NOTE2FORMULA;

  FUNCTION PO_HEADER_LONG_NOTEFORMULA(PO_HEADER_NOTE_DATATYPE_ID IN NUMBER
                                     ,PO_HEADER_NOTE_MEDIA_ID IN NUMBER) RETURN CHAR IS
    SHORT_NOTE VARCHAR2(2000);
    LONG_NOTE LONG;
  BEGIN
    IF PO_HEADER_NOTE_DATATYPE_ID = 1 THEN
      SELECT
        SHORT_TEXT
      INTO SHORT_NOTE
      FROM
        FND_DOCUMENTS_SHORT_TEXT
      WHERE MEDIA_ID = PO_HEADER_NOTE_MEDIA_ID;
      RETURN SHORT_NOTE;
    ELSIF PO_HEADER_NOTE_DATATYPE_ID = 2 THEN
      SELECT
        LONG_TEXT
      INTO LONG_NOTE
      FROM
        FND_DOCUMENTS_LONG_TEXT
      WHERE MEDIA_ID = PO_HEADER_NOTE_MEDIA_ID;
      RETURN LONG_NOTE;
    ELSE
      RETURN 'Attachment is not a Text format';
    END IF;
  END PO_HEADER_LONG_NOTEFORMULA;

  FUNCTION PO_LINE_LONG_NOTEFORMULA(PO_LINE_NOTE_DATATYPE_ID IN NUMBER
                                   ,PO_LINE_NOTE_MEDIA_ID IN NUMBER) RETURN CHAR IS
    SHORT_NOTE VARCHAR2(2000);
    LONG_NOTE LONG;
  BEGIN
    IF PO_LINE_NOTE_DATATYPE_ID = 1 THEN
      SELECT
        SHORT_TEXT
      INTO SHORT_NOTE
      FROM
        FND_DOCUMENTS_SHORT_TEXT
      WHERE MEDIA_ID = PO_LINE_NOTE_MEDIA_ID;
      RETURN SHORT_NOTE;
    ELSIF PO_LINE_NOTE_DATATYPE_ID = 2 THEN
      SELECT
        LONG_TEXT
      INTO LONG_NOTE
      FROM
        FND_DOCUMENTS_LONG_TEXT
      WHERE MEDIA_ID = PO_LINE_NOTE_MEDIA_ID;
      RETURN LONG_NOTE;
    ELSE
      RETURN 'Attachment is not a Text format';
    END IF;
  END PO_LINE_LONG_NOTEFORMULA;

  FUNCTION REQ_HEADER_LONG_NOTEFORMULA(REQ_HEADER_NOTE_DATATYPE_ID IN NUMBER
                                      ,REQ_HEADER_NOTE_MEDIA_ID IN NUMBER) RETURN CHAR IS
    SHORT_NOTE VARCHAR2(2000);
    LONG_NOTE LONG;
  BEGIN
    IF REQ_HEADER_NOTE_DATATYPE_ID = 1 THEN
      SELECT
        SHORT_TEXT
      INTO SHORT_NOTE
      FROM
        FND_DOCUMENTS_SHORT_TEXT
      WHERE MEDIA_ID = REQ_HEADER_NOTE_MEDIA_ID;
      RETURN SHORT_NOTE;
    ELSIF REQ_HEADER_NOTE_DATATYPE_ID = 2 THEN
      SELECT
        LONG_TEXT
      INTO LONG_NOTE
      FROM
        FND_DOCUMENTS_LONG_TEXT
      WHERE MEDIA_ID = REQ_HEADER_NOTE_MEDIA_ID;
      RETURN LONG_NOTE;
    ELSE
      RETURN 'Attachment is not a Text format';
    END IF;
  END REQ_HEADER_LONG_NOTEFORMULA;

  FUNCTION REQ_LINE_LONG_NOTEFORMULA(REQ_LINE_NOTE_DATATYPE_ID IN NUMBER
                                    ,REQ_LINE_NOTE_MEDIA_ID IN NUMBER) RETURN CHAR IS
    SHORT_NOTE VARCHAR2(2000);
    LONG_NOTE LONG;
  BEGIN
    IF REQ_LINE_NOTE_DATATYPE_ID = 1 THEN
      SELECT
        SHORT_TEXT
      INTO SHORT_NOTE
      FROM
        FND_DOCUMENTS_SHORT_TEXT
      WHERE MEDIA_ID = REQ_LINE_NOTE_MEDIA_ID;
      RETURN SHORT_NOTE;
    ELSIF REQ_LINE_NOTE_DATATYPE_ID = 2 THEN
      SELECT
        LONG_TEXT
      INTO LONG_NOTE
      FROM
        FND_DOCUMENTS_LONG_TEXT
      WHERE MEDIA_ID = REQ_LINE_NOTE_MEDIA_ID;
      RETURN LONG_NOTE;
    ELSE
      RETURN 'Attachment is not a Text format';
    END IF;
  END REQ_LINE_LONG_NOTEFORMULA;

  FUNCTION PO_LINE_LOCATION_LONG_NOTEFORM(SHIPMENT_NOTE_DATATYPE_ID IN NUMBER
                                         ,SHIPMENT_NOTE_MEDIA_ID IN NUMBER) RETURN CHAR IS
    SHORT_NOTE VARCHAR2(2000);
    LONG_NOTE LONG;
  BEGIN
    IF SHIPMENT_NOTE_DATATYPE_ID = 1 THEN
      SELECT
        SHORT_TEXT
      INTO SHORT_NOTE
      FROM
        FND_DOCUMENTS_SHORT_TEXT
      WHERE MEDIA_ID = SHIPMENT_NOTE_MEDIA_ID;
      RETURN SHORT_NOTE;
    ELSIF SHIPMENT_NOTE_DATATYPE_ID = 2 THEN
      SELECT
        LONG_TEXT
      INTO LONG_NOTE
      FROM
        FND_DOCUMENTS_LONG_TEXT
      WHERE MEDIA_ID = SHIPMENT_NOTE_MEDIA_ID;
      RETURN LONG_NOTE;
    ELSE
      RETURN 'Attachment is not a Text format';
    END IF;
  END PO_LINE_LOCATION_LONG_NOTEFORM;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_ORG_DISPLAYED ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_NAME%TYPE;
      NUMBERING_TYPE VARCHAR2(40);
      l_INDUSTRY varchar2(100);
      l_boolean boolean;
      l_ORACLE_SCHEMA varchar2(100);
    BEGIN
      IF (P_GROUP_ID IS NOT NULL) THEN
        P_WHERE_GROUP_ID := 'rrp.group_id = :P_group_id ';
      ELSE
        P_WHERE_GROUP_ID := '1=1';
      END IF;
      IF (P_SHIP_TO_LOCATION IS NOT NULL) THEN
        P_WHERE_SHIP_TO_LOCATION := 'rrp.receipt_location = :P_ship_to_location ';
      ELSE
        P_WHERE_SHIP_TO_LOCATION := '1=1';
      END IF;
      IF (P_DELIVERY_LOCATION IS NOT NULL) THEN
        P_WHERE_DELIVER_TO_LOCATION := 'rrp.deliver_to_location = :P_delivery_location ';
      ELSE
        P_WHERE_DELIVER_TO_LOCATION := '1=1';
      END IF;
      IF (P_ORG_ID IS NOT NULL) THEN
        P_WHERE_ORG_ID := 'rrp.organization_id = :P_org_id ';
      ELSE
        P_WHERE_ORG_ID := '1=1';
      END IF;
      IF (P_GROUP_ID IS NOT NULL) THEN
        P_WHERE_GROUP_ID := 'rrp.group_id = :P_group_id';
      ELSE
        P_WHERE_GROUP_ID := '1=1';
      END IF;
      BEGIN
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        IF (P_ORG_ID IS NOT NULL) THEN
          BEGIN
            SELECT
              ORGANIZATION_NAME
            INTO L_ORG_DISPLAYED
            FROM
              ORG_ORGANIZATION_DEFINITIONS
            WHERE ORGANIZATION_ID = P_ORG_ID;
            P_ORG_DISPLAYED := L_ORG_DISPLAYED;
          END;
        ELSE
          BEGIN
            P_ORG_DISPLAYED := '';
          END;
        END IF;
        IF (P_OPERATING_UNIT_ID IS NOT NULL) THEN
          PO_MOAC_UTILS_PVT.SET_POLICY_CONTEXT('S'
                                      ,P_OPERATING_UNIT_ID);
          P_OPERATING_UNIT_DISPLAYED := PO_MOAC_UTILS_PVT.GET_OU_NAME(P_OPERATING_UNIT_ID);
        END IF;
        SELECT
          DISTINCT
          MANUAL_RECEIPT_NUM_TYPE
        INTO NUMBERING_TYPE
        FROM
          RCV_RECEIVING_PARAMETERS_V
        WHERE ORGANIZATION_ID = P_ORG_ID;
        IF (P_RECEIPT_NUM_FROM IS NOT NULL) AND (P_RECEIPT_NUM_TO IS NOT NULL) AND (P_RECEIPT_NUM_FROM = P_RECEIPT_NUM_TO) THEN
          P_WHERE_RECEIPT_NUM_FROM := 'rrp.receipt_num =  :P_receipt_num_from ';
          P_WHERE_RECEIPT_NUM_TO := 'rrp.receipt_num = :P_receipt_num_to ';
        ELSE
          IF (P_RECEIPT_NUM_FROM IS NOT NULL) THEN
            IF (NUMBERING_TYPE = 'ALPHANUMERIC') THEN
              P_WHERE_RECEIPT_NUM_FROM := 'rrp.receipt_num >=  :P_receipt_num_from ';
            ELSE
              P_WHERE_RECEIPT_NUM_FROM := 'decode(rtrim(rrp.receipt_num, ''0123456789''), NULL, to_number(rrp.receipt_num), -1) >= ' || ' decode(rtrim(:P_receipt_num_from ,''0123456789''), NULL, to_number(:P_receipt_num_from ), -1) ';
            END IF;
          ELSE
            P_WHERE_RECEIPT_NUM_FROM := '1=1';
          END IF;
          IF (P_RECEIPT_NUM_TO IS NOT NULL) THEN
            IF (NUMBERING_TYPE = 'ALPHANUMERIC') THEN
              P_WHERE_RECEIPT_NUM_TO := 'rrp.receipt_num <= :P_receipt_num_to ';
            ELSE
              P_WHERE_RECEIPT_NUM_TO := 'decode(rtrim(rrp.receipt_num, ''0123456789''), NULL, to_number(rrp.receipt_num), -1) <= ' || ' decode(rtrim(:P_receipt_num_to , ''0123456789''), NULL, to_number(:P_receipt_num_to ), -1) ';
            END IF;
          ELSE
            P_WHERE_RECEIPT_NUM_TO := '1=1';
          END IF;
        END IF;
        IF (NUMBERING_TYPE = 'ALPHANUMERIC') THEN
          P_ORDERBY := 'order by rrp.item_id, rrp.receipt_num';
        ELSE
          P_ORDERBY := 'order by rrp.item_id, decode(rtrim(rrp.receipt_num, ''0123456789''), NULL, to_number(rrp.receipt_num), rrp.receipt_num)';
        END IF;
      END;
      BEGIN
        IF (GET_P_STRUCT_NUM <> TRUE) THEN
          NULL;
        END IF;
        l_boolean:= fnd_installation.GET_APP_INFO('INV',P_INV_STATUS,l_INDUSTRY,l_ORACLE_SCHEMA);
        l_boolean:= fnd_installation.GET_APP_INFO('WIP',P_WIP_STATUS,l_INDUSTRY,l_ORACLE_SCHEMA);
        IF (P_WIP_STATUS = 'I') THEN
        l_boolean:= fnd_installation.GET_APP_INFO('BOM',P_WIP_STATUS,l_INDUSTRY,l_ORACLE_SCHEMA);
        END IF;
        IF (P_INV_STATUS = 'I') THEN
        Null;
        ELSE
          P_FLEX_LOCATOR := 'TO_CHAR(NULL)';
        END IF;
        IF (P_WIP_STATUS = 'I') THEN
          P_WIP_SELECT_DIST := ' we.wip_entity_name job_or_schedule
                                                           , wl.line_code line
                                                           , wn.operation_seq_num op_seq
                                                           , bd.department_code department ';
          P_WIP_FROM_DIST := 'wip_lines wl,
                                                       wip_entities we,
                                                       bom_departments bd,
                                                       wip_operation_resources wr,
                                                       wip_operations wn,
                                                       wip_operations wo, ';
          P_WIP_WHERE_DIST := 'AND wo.wip_entity_id = rdp.wip_entity_id
                                                        and wo.organization_id = rdp.organization_id
                                  			  and nvl(wo.repetitive_schedule_id, -1) = nvl(rdp.wip_repetitive_schedule_id, -1)
                                			  and wo.operation_seq_num = rdp.wip_operation_seq_num
                                			  and wl.line_id (+) = rdp.wip_line_id
                              		          and wr.wip_entity_id = rdp.wip_entity_id
                                			  and wr.organization_id = rdp.organization_id
                                			  and nvl(wr.repetitive_schedule_id, -1) = nvl(rdp.wip_repetitive_schedule_id, -1)
                                			  and wr.operation_seq_num = rdp.wip_operation_seq_num
                                			  and wr.resource_seq_num = rdp.wip_resource_seq_num
                                			  and wn.wip_entity_id = rdp.wip_entity_id
                                			  and wn.organization_id = rdp.organization_id
                                			  and nvl(wn.repetitive_schedule_id, -1) = nvl(rdp.wip_repetitive_schedule_id, -1)
                               			  and wn.operation_seq_num = decode(wr.autocharge_type, 4,
                                                            nvl(wo.next_operation_seq_num, wo.operation_seq_num), wo.operation_seq_num)
                               			  and bd.department_id = wn.department_id
                                			  and we.wip_entity_id = rdp.wip_entity_id
                                			  and we.organization_id = rdp.organization_id ';
          P_UNION_UPPER_UPPER := 'SELECT WE.WIP_ENTITY_NAME                 Work_Order
                                 ,       to_char(null)                                    Line
                                 ,      WRO.DATE_REQUIRED                  Date_Required
                                 ,      SUM(NVL(WRO.QUANTITY_ISSUED,0))                Quantity_Issued
                                 ,      SUM(NVL(WRO.REQUIRED_QUANTITY,0))           Quantity_Required
                                 ,      ''D''                ';
          P_UNION_UPPER_LOWER := 'FROM WIP_ENTITIES WE
                                 ,      WIP_REQUIREMENT_OPERATIONS WRO
                                 ,      WIP_DISCRETE_JOBS WDJ
                                 WHERE  WDJ.STATUS_TYPE IN (1,3,4,6)
                                 AND    WE.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
                                 AND    WE.ORGANIZATION_ID = WDJ.ORGANIZATION_ID
                                 AND    WRO.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
                                 AND    WRO.ORGANIZATION_ID = WDJ.ORGANIZATION_ID
                                 AND    WRO.WIP_SUPPLY_TYPE <> 6
                                 AND    WRO.REQUIRED_QUANTITY > 0
                                 GROUP BY WE.WIP_ENTITY_NAME
                                 ,      WRO.DATE_REQUIRED
                                 ,      WDJ.ORGANIZATION_ID
                                 ,      WRO.INVENTORY_ITEM_ID
                                 ,      WE.DESCRIPTION
                                 ,      NVL(WDJ.PRIMARY_ITEM_ID,-1)
                                 ,      WDJ.SCHEDULED_START_DATE
                                 ,      WDJ.START_QUANTITY
                                 ,      WDJ.SCHEDULED_COMPLETION_DATE
                                 ,      WRO.SUPPLY_SUBINVENTORY
                                 ,      WRO.QUANTITY_ISSUED
                                 ,      WRO.REQUIRED_QUANTITY
                                 ,      WRO.REQUIRED_QUANTITY - WRO.QUANTITY_ISSUED
                                 HAVING SUM(NVL(WRO.REQUIRED_QUANTITY,0)) - SUM(NVL(WRO.QUANTITY_ISSUED,0)) > 0';
          P_UNION_LOWER_UPPER := 'SELECT WE.WIP_ENTITY_NAME                 Work_Order
                                 ,      WL.LINE_CODE                         Line
                                 ,      WRO.DATE_REQUIRED                  Date_Required
                                 ,      SUM(WRO.QUANTITY_ISSUED)                Quantity_Issued
                                 ,      SUM((LEAST(BCD.NEXT_SEQ_NUM + WRS.PROCESSING_WORK_DAYS,BCD1.NEXT_SEQ_NUM + MSI.POSTPROCESSING_LEAD_TIME)
                                           - GREATEST(BCD.NEXT_SEQ_NUM,BCD1.NEXT_SEQ_NUM))
                                           * WRO.QUANTITY_PER_ASSEMBLY * WRS.DAILY_PRODUCTION_RATE )
                                 /* this is raw quantity required */
                                         +    -1 *  SUM(WRO.QUANTITY_ISSUED -
                                            GREATEST((BCD1.NEXT_SEQ_NUM-BCD.NEXT_SEQ_NUM),0)
                                        *WRO.QUANTITY_PER_ASSEMBLY * WRS.DAILY_PRODUCTION_RATE)
                                 /* this is the quantity ahead behind after taking care of the negative sign as quantity ahead behind
                                 will always be calulated as negative*/
                                                                             Quantity_Required
                                 ,      ''R''                                      Processing_Mode';
          P_UNION_LOWER_LOWER := 'FROM WIP_ENTITIES WE
                                 ,      WIP_REQUIREMENT_OPERATIONS WRO
                                 ,      WIP_REPETITIVE_SCHEDULES  WRS
                                 ,      BOM_CALENDAR_DATES BCD
                                 ,      BOM_CALENDAR_DATES BCD1
                                 ,      WIP_LINES WL
                                 ,      MTL_PARAMETERS MP
                                 ,      MTL_SYSTEM_ITEMS MSI
                                 WHERE  WRS.STATUS_TYPE IN (1,3,4,6)
                                 AND    WE.WIP_ENTITY_ID = WRS.WIP_ENTITY_ID
                                 AND    WE.ORGANIZATION_ID = WRS.ORGANIZATION_ID
                                 AND    MP.ORGANIZATION_ID =  WRS.ORGANIZATION_ID
                                 AND    BCD1.CALENDAR_CODE = MP.CALENDAR_CODE
                                 AND    BCD1.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
                                 AND    BCD1.CALENDAR_DATE = to_char(sysdate,''DD-MON-RR'')
                                 AND    NVL(MSI.ORGANIZATION_ID,MP.ORGANIZATION_ID)= MP.ORGANIZATION_ID
                                 AND    WRO.WIP_ENTITY_ID = WRS.WIP_ENTITY_ID
                                 AND    WRO.REPETITIVE_SCHEDULE_ID = WRS.REPETITIVE_SCHEDULE_ID
                                 AND    WRO.ORGANIZATION_ID = WRS.ORGANIZATION_ID
                                 AND    WRO.WIP_SUPPLY_TYPE <> 6
                                 AND    WRO.REQUIRED_QUANTITY > 0
                                 AND     WL.LINE_ID = WRS.LINE_ID
                                 AND     WL.ORGANIZATION_ID = WRS.ORGANIZATION_ID
                                 AND    BCD.CALENDAR_CODE = MP.CALENDAR_CODE
                                 AND    BCD.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
                                 AND    BCD.CALENDAR_DATE = WRO.DATE_REQUIRED
                                 AND    (BCD.NEXT_SEQ_NUM < BCD1.NEXT_SEQ_NUM + MSI.POSTPROCESSING_LEAD_TIME)
                                 AND    ((BCD.NEXT_SEQ_NUM + WRS.PROCESSING_WORK_DAYS ) > BCD1.NEXT_SEQ_NUM)
                                 AND    NVL(MSI.ORGANIZATION_ID,MP.ORGANIZATION_ID)= MP.ORGANIZATION_ID
                                 AND    MSI.INVENTORY_ITEM_ID = WRO.INVENTORY_ITEM_ID
                                 GROUP BY WL.LINE_CODE
                                 ,      WL.DESCRIPTION
                                 ,      WE.WIP_ENTITY_NAME
                                 ,      WE.DESCRIPTION
                                 ,      NVL(WRO.SUPPLY_SUBINVENTORY,'' '')
                                 ,      WRO.DATE_REQUIRED
                                 ,      WRS.ORGANIZATION_ID
                                 ,        wro.inventory_item_id
                                 HAVING (SUM((LEAST(BCD.NEXT_SEQ_NUM + WRS.PROCESSING_WORK_DAYS,
                                                               BCD1.NEXT_SEQ_NUM + MSI.POSTPROCESSING_LEAD_TIME)
                                                               - GREATEST(BCD.NEXT_SEQ_NUM, BCD1.NEXT_SEQ_NUM ))
                                                               * WRO.QUANTITY_PER_ASSEMBLY * WRS.DAILY_PRODUCTION_RATE )
                                                              + SUM(GREATEST((BCD1.NEXT_SEQ_NUM-BCD.NEXT_SEQ_NUM),0)
                                                                *WRO.QUANTITY_PER_ASSEMBLY * WRS.DAILY_PRODUCTION_RATE)
                                                              - SUM(WRO.QUANTITY_ISSUED)) > 0';
        END IF;
        BUILD_QRECEIPTS;
        BUILD_QDISTRIBUTIONS;
      END;
      RETURN (TRUE);
    END;
  END AFTERPFORM;

  PROCEDURE BUILD_QRECEIPTS IS
  BEGIN
    IF (P_RECEIPT_SOURCE_TYPE = 'Supplier') THEN
    from_lexical:= 'rcv_receipts_print_po rrp';
    and_lexical:= 'AND nvl(msi.organization_id,rrp.org_id) = rrp.org_id';

    ELSIF (P_RECEIPT_SOURCE_TYPE = 'Internal Order') THEN
     from_lexical:= 'rcv_receipts_print_req rrp';
    and_lexical:= 'AND nvl(msi.organization_id,rrp.org_id) = rrp.org_id';

    ELSIF (P_RECEIPT_SOURCE_TYPE = 'Inventory') THEN
     from_lexical:= 'rcv_receipts_print_inv rrp';
    and_lexical:= 'AND nvl(msi.organization_id,rrp.organization_id) = rrp.organization_id';

    ELSIF (P_RECEIPT_SOURCE_TYPE = 'Customer') THEN
     from_lexical:= 'rcv_receipts_print_rma rrp';
    and_lexical:= 'AND nvl(msi.organization_id,rrp.org_id) = rrp.org_id';

    ELSE
    from_lexical:= 'rcv_receipts_print rrp';
    and_lexical:= 'AND nvl(msi.organization_id,rrp.organization_id) = rrp.organization_id';

    END IF;
  END BUILD_QRECEIPTS;

  PROCEDURE BUILD_QDISTRIBUTIONS IS
  BEGIN
    IF (P_RECEIPT_SOURCE_TYPE = 'Supplier') THEN
   from_lexical_1:='rcv_distributions_print_po';
    ELSIF (P_RECEIPT_SOURCE_TYPE = 'Internal Order') THEN
      from_lexical_1:='rcv_distributions_print_req';
    ELSIF (P_RECEIPT_SOURCE_TYPE = 'Inventory') THEN
    from_lexical_1:='rcv_distributions_print_inv';
    ELSIF (P_RECEIPT_SOURCE_TYPE = 'Customer') THEN
    from_lexical_1:='rcv_distributions_print_rma';
    ELSE
   from_lexical_1:='rcv_distributions_print';
    END IF;
  END BUILD_QDISTRIBUTIONS;

  FUNCTION ROUNDED_QTY_ISSUEDFORMULA(QUANTITY_ISSUED IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN ROUND(QUANTITY_ISSUED
                ,P_QTY_PRECISION);
  END ROUNDED_QTY_ISSUEDFORMULA;

  FUNCTION ROUNDED_QTY_ON_HANDFORMULA(JOIN_ITEM_ID IN NUMBER
                                     ,JOIN_ORGANIZATION_ID IN NUMBER) RETURN NUMBER IS
    QUANTITY_ON_HAND NUMBER;
  BEGIN
    SELECT
      SUM(NVL(QUANTITY
             ,0))
    INTO QUANTITY_ON_HAND
    FROM
      MTL_ITEM_QUANTITIES_VIEW
    WHERE INVENTORY_ITEM_ID = JOIN_ITEM_ID
      AND ORGANIZATION_ID = JOIN_ORGANIZATION_ID;
    RETURN ROUND(QUANTITY_ON_HAND
                ,P_QTY_PRECISION);
  END ROUNDED_QTY_ON_HANDFORMULA;

  FUNCTION ROUNDED_QTY_REQUIREDFORMULA(QUANTITY_REQUIRED IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN ROUND(QUANTITY_REQUIRED
                ,P_QTY_PRECISION);
  END ROUNDED_QTY_REQUIREDFORMULA;

  FUNCTION QUANTITY_SHORTFORMULA(ROUNDED_QTY_REQUIRED IN NUMBER
                                ,ROUNDED_QTY_ISSUED IN NUMBER
                                ,ROUNDED_QTY_ON_HAND IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (((NVL(ROUNDED_QTY_REQUIRED
              ,0) - NVL(ROUNDED_QTY_ISSUED
              ,0)) - NVL(ROUNDED_QTY_ON_HAND
              ,0)));
  END QUANTITY_SHORTFORMULA;

  FUNCTION G_WORK_ORDER_SHORTAGEGROUPFILT(QUANTITY_SHORT IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    IF (QUANTITY_SHORT > 0) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
    RETURN (TRUE);
  END G_WORK_ORDER_SHORTAGEGROUPFILT;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
   QTY_PRECISION := PO_common_xmlp_pkg.get_precision(P_QTY_PRECISION);
    CP_DELIVERY_LOCATION := P_DELIVERY_LOCATION;
    CP_RECEIPT_NUM_FROM := P_RECEIPT_NUM_FROM;
    CP_RECEIPT_NUM_TO := P_RECEIPT_NUM_TO;
    CP_ITEM_FROM := P_ITEM_FROM;
    CP_ITEM_TO := P_ITEM_TO;
    CP_CATEGORY_FROM := P_CATEGORY_FROM;
    CP_CATEGORY_TO := P_CATEGORY_TO;
    CP_SHIP_TO_LOCATION := P_SHIP_TO_LOCATION;
    CP_ORG_DISPLAYED := P_ORG_DISPLAYED;
    CP_TITLE := P_TITLE;
    CP_WIP_STATUS := P_WIP_STATUS;
    CP_OPERATING_UNIT_DISPLAYED := P_OPERATING_UNIT_DISPLAYED;
    P_WHERE_ITEM :=nvl(P_WHERE_ITEM,'1=1');
    P_WHERE_CAT :=nvl(P_WHERE_CAT,'1=1');
    P_WHERE_ITEM :=nvl(P_WHERE_ITEM,'1=1');
    P_WIP_WHERE_DIST := nvl(P_WIP_WHERE_DIST,'and 1=1');
    P_WIP_FROM_DIST  := nvl(P_WIP_FROM_DIST,' ');
    P_WIP_WHERE_DIST := nvl(P_WIP_WHERE_DIST,'and 1=1');
   RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_DO_PRINTFORMULA(COUNT_DISTRIBUTIONS IN NUMBER
                             ,RRP_TRANSACTION_ID IN NUMBER
                             ,RRP_FROM_INTERFACE IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF (COUNT_DISTRIBUTIONS >= 0) THEN
      IF (CHILD_DIRECT_RECEIVING_CHECK(RRP_FROM_INTERFACE
                                  ,RRP_TRANSACTION_ID) = TRUE) THEN
        RETURN 'Y';
      END IF;
    ELSE
      RETURN 'N';
    END IF;
    RETURN ('Y');
  END CF_DO_PRINTFORMULA;

  FUNCTION CF_BLIND_RCVFORMULA(RRP_ORGANIZATION_ID IN NUMBER) RETURN CHAR IS
  BEGIN
    IF (BLIND_RECEIVING_CHECK(RRP_ORGANIZATION_ID) = TRUE) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  END CF_BLIND_RCVFORMULA;

  FUNCTION CF_DIRECT_RCV_DLVFORMULA(RRP_TRANSACTION_ID IN NUMBER
                                   ,RRP_FROM_INTERFACE IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF DIRECT_RECEIVING_CHECK(RRP_FROM_INTERFACE
                          ,RRP_TRANSACTION_ID) AND DELIVERY_CHECK(RRP_FROM_INTERFACE
                  ,RRP_TRANSACTION_ID) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  END CF_DIRECT_RCV_DLVFORMULA;

  FUNCTION CF_SERIAL_NUM_CCFORMULA(SERIAL_NUMBER_CONTROL_COD IN NUMBER) RETURN CHAR IS
  BEGIN
    IF (SERIAL_NUMBER_CONTROL_COD = 2 OR SERIAL_NUMBER_CONTROL_COD = 3 OR SERIAL_NUMBER_CONTROL_COD = 5 OR SERIAL_NUMBER_CONTROL_COD = 6) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  END CF_SERIAL_NUM_CCFORMULA;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION CF_OPERATING_UNITFORMULA(ORG_ID IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF (ORG_ID IS NOT NULL) THEN
      RETURN PO_MOAC_UTILS_PVT.GET_OU_NAME(ORG_ID);
    ELSE
      RETURN NULL;
    END IF;
  END CF_OPERATING_UNITFORMULA;

  FUNCTION CF_RECEIPT_LOCATIONFORMULA(LOCATOR_ID1 IN NUMBER
                                     ,RECEIPT_LOCATION IN VARCHAR2
                                     ,RECEIVING_SUBINVENTORY IN VARCHAR2) RETURN CHAR IS
    L_LOCATION VARCHAR2(300);
    L_LOCATOR MTL_ITEM_LOCATIONS_KFV.CONCATENATED_SEGMENTS%TYPE;
  BEGIN
    BEGIN
      SELECT
        CONCATENATED_SEGMENTS
      INTO L_LOCATOR
      FROM
        MTL_ITEM_LOCATIONS_KFV
      WHERE INVENTORY_LOCATION_ID = LOCATOR_ID1;
    EXCEPTION
      WHEN OTHERS THEN
        L_LOCATOR := NULL;

    END;
    L_LOCATION := RECEIPT_LOCATION;
    IF L_LOCATION IS NOT NULL AND RECEIVING_SUBINVENTORY IS NOT NULL THEN
      L_LOCATION := L_LOCATION || '-' || RECEIVING_SUBINVENTORY;
    ELSIF L_LOCATION IS NULL AND RECEIVING_SUBINVENTORY IS NOT NULL THEN
      L_LOCATION := RECEIVING_SUBINVENTORY;
    END IF;
    IF L_LOCATION IS NOT NULL AND L_LOCATOR IS NOT NULL THEN
      L_LOCATION := L_LOCATION || '-' || L_LOCATOR;
    ELSIF L_LOCATION IS NULL AND L_LOCATOR IS NOT NULL THEN
      L_LOCATION := L_LOCATOR;
    END IF;
    RETURN (L_LOCATION);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);

  END CF_RECEIPT_LOCATIONFORMULA;

  FUNCTION C_NUM_RTS_PRINTED_P RETURN NUMBER IS
  BEGIN
    RETURN C_NUM_RTS_PRINTED;
  END C_NUM_RTS_PRINTED_P;

  FUNCTION CP_DELIVERY_LOCATION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DELIVERY_LOCATION;
  END CP_DELIVERY_LOCATION_P;

  FUNCTION CP_RECEIPT_NUM_FROM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_RECEIPT_NUM_FROM;
  END CP_RECEIPT_NUM_FROM_P;

  FUNCTION CP_RECEIPT_NUM_TO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_RECEIPT_NUM_TO;
  END CP_RECEIPT_NUM_TO_P;

  FUNCTION CP_ITEM_FROM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ITEM_FROM;
  END CP_ITEM_FROM_P;

  FUNCTION CP_ITEM_TO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ITEM_TO;
  END CP_ITEM_TO_P;

  FUNCTION CP_CATEGORY_FROM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CATEGORY_FROM;
  END CP_CATEGORY_FROM_P;

  FUNCTION CP_CATEGORY_TO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CATEGORY_TO;
  END CP_CATEGORY_TO_P;

  FUNCTION CP_SHIP_TO_LOCATION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_TO_LOCATION;
  END CP_SHIP_TO_LOCATION_P;

  FUNCTION CP_ORG_DISPLAYED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ORG_DISPLAYED;
  END CP_ORG_DISPLAYED_P;

  FUNCTION CP_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_TITLE;
  END CP_TITLE_P;

  FUNCTION CP_WIP_STATUS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_WIP_STATUS;
  END CP_WIP_STATUS_P;

  FUNCTION CP_OPERATING_UNIT_DISPLAYED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_OPERATING_UNIT_DISPLAYED;
  END CP_OPERATING_UNIT_DISPLAYED_P;

END PO_POXDLPDT_XMLP_PKG;


/
