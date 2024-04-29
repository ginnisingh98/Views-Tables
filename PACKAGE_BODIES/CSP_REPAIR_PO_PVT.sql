--------------------------------------------------------
--  DDL for Package Body CSP_REPAIR_PO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REPAIR_PO_PVT" AS
/* $Header: cspgrexb.pls 120.21.12010000.15 2011/09/30 05:05:09 ajosephg ship $ */

-- Purpose: To create Repair execution
-- Start of Comments
-- Package name     : CSP_REPAIR_PO_PVT
-- Purpose          : This package creates Repair Purchase Order Execution details.
-- History          : 05-July-2005, Arul Joseph.
-- NOTE             :
-- End of Comments

    G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'CSP_REPAIR_PO_PVT';
    G_FILE_NAME CONSTANT    VARCHAR2(30) := 'cspgrexb.pls';

    Procedure Add_Err_Msg Is
        l_msg_index_out     NUMBER;
        x_msg_data_temp     Varchar2(2000);
        x_msg_data          Varchar2(4000);
    Begin
        If fnd_msg_pub.count_msg > 0 Then
            FOR i IN REVERSE 1..fnd_msg_pub.count_msg
            Loop
            fnd_msg_pub.get(p_msg_index => i,
                            p_encoded => 'F',
                            p_data => x_msg_data_temp,
                            p_msg_index_out => l_msg_index_out);
                            x_msg_data := x_msg_data || x_msg_data_temp;
            End Loop;
            FND_FILE.put_line(FND_FILE.log,x_msg_data);
            fnd_msg_pub.delete_msg;
        End if;
    End;

    PROCEDURE RUN_REPAIR_EXECUTION
                (errbuf                 OUT NOCOPY VARCHAR2,
                 retcode                OUT NOCOPY NUMBER,
                 p_Api_Version_Number   IN  NUMBER,
                 p_repair_po_header_id  IN  NUMBER default null
                )
    IS

        CURSOR C_CSP_REPAIR_PO_HEADERS(l_status NUMBER) IS
        SELECT *
        FROM CSP_REPAIR_PO_HEADERS
        WHERE STATUS = l_status
        ORDER BY REPAIR_PO_HEADER_ID
        FOR UPDATE OF STATUS;

        /** Instead of FOR UPDATE selecting rowid which helps to update the current row and do commit inside the loop **/
        CURSOR CSP_REPAIR_PO_HEADERS_ROW(l_status NUMBER) IS
        SELECT rowid, CRPH.*
        FROM CSP_REPAIR_PO_HEADERS CRPH
        WHERE STATUS = l_status
        ORDER BY REPAIR_PO_HEADER_ID;

        CURSOR PO_REQ_INTERFACE_ALL(l_requisition_number NUMBER,l_requisition_line_id NUMBER) IS
        SELECT PRIL.authorization_status, PRIL.req_number_segment1
        FROM PO_REQUISITIONS_INTERFACE_ALL PRIL
        WHERE PRIL.req_number_segment1 = l_requisition_number
        AND PRIL.requisition_line_id = l_requisition_line_id;

        /** Possible to check only in the PO_REQUISITION_HEADERS_ALL table and no need to join with PO_REQUISITION_LINES_ALL table **/
        CURSOR PO_REQ_HEADERS_ALL(l_requisition_number NUMBER, l_requisition_line_id NUMBER) IS
        SELECT PRH.REQUISITION_HEADER_ID,PRH.AUTHORIZATION_STATUS,PRH.segment1
        FROM PO_REQUISITION_HEADERS_ALL PRH, PO_REQUISITION_LINES_ALL PRL
        WHERE PRH.SEGMENT1 = l_requisition_number AND
        PRL.REQUISITION_LINE_ID = l_requisition_line_id AND
        PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID;

        CURSOR PO_HEADERS_ALL(l_requisition_line_id NUMBER) IS
        SELECT POH.po_header_id, POH.segment1, POH.AUTHORIZATION_STATUS, POH.closed_code,
        PLL.line_location_id, PLL.po_line_id
        FROM PO_REQUISITION_LINES_ALL PRL, PO_LINE_LOCATIONS_ALL PLL, PO_HEADERS_ALL POH
        WHERE PRL.REQUISITION_LINE_ID = l_requisition_line_id AND
              PRL.LINE_LOCATION_ID = PLL.LINE_LOCATION_ID AND
              PLL.PO_HEADER_ID = POH.PO_HEADER_ID;

        CURSOR CSP_RESERVED_LINES(L_REPAIR_PO_HEADER_ID NUMBER) IS
        SELECT CRL.*, CRH.dest_organization_id
        FROM CSP_REPAIR_PO_HEADERS CRH, CSP_REPAIR_PO_LINES CRL
        WHERE CRL.REPAIR_PO_HEADER_ID = L_REPAIR_PO_HEADER_ID
        AND CRL.REPAIR_PO_HEADER_ID = CRH.REPAIR_PO_HEADER_ID;

        /*
        CURSOR IO_QTY_RECEIVED_CHECK (L_HEADER_ID NUMBER)IS
        SELECT * FROM OE_ORDER_HEADERS_ALL OEH,
        OE_ORDER_LINES_ALL OEL, PO_REQUISITION_LINES_ALL PRL
        WHERE OEH.HEADER_ID = L_HEADER_ID AND
        OEH.HEADER_ID = OEL.HEADER_ID AND
        OEL.SOURCE_DOCUMENT_ID = PRL.REQUISITION_HEADER_ID AND
        OEL.SOURCE_DOCUMENT_LINE_ID = PRL.REQUISITION_LINE_ID;
        */

        CURSOR IO_QTY_RECEIVED_CHECK (L_HEADER_ID NUMBER)IS
        SELECT PRL.QUANTITY,
               PRL.QUANTITY_RECEIVED,
               PRL.ITEM_ID,
               PRL.DESTINATION_ORGANIZATION_ID,
               PRL.DESTINATION_SUBINVENTORY
         FROM OE_ORDER_HEADERS_ALL OEH,
        PO_REQUISITION_LINES_ALL PRL
        WHERE OEH.HEADER_ID = L_HEADER_ID
        AND OEH.SOURCE_DOCUMENT_ID = PRL.REQUISITION_HEADER_ID;

        /*
         1.PRL.quantity_received is null (and)
           PRL.quantity_delivered shows the PO received qty.

         2.Based on the above scenario, we have to use
           PLL.quantity_received (or) PRL.quantity_delivered
           to select quantity_received so far for this PO.
        */

        CURSOR PO_REQ_RECEIVED_QTY(l_requisition_line_id NUMBER) IS
        SELECT PLL.quantity_received, PRL.closed_code,
               POH.po_header_id, POH.segment1, POH.AUTHORIZATION_STATUS, -- POH.closed_code,
               PLL.line_location_id, PLL.po_line_id
        FROM PO_REQUISITION_LINES_ALL PRL, PO_LINE_LOCATIONS_ALL PLL, PO_HEADERS_ALL POH
        WHERE PRL.REQUISITION_LINE_ID = l_requisition_line_id AND
              PRL.LINE_LOCATION_ID = PLL.LINE_LOCATION_ID AND
              PLL.PO_HEADER_ID = POH.PO_HEADER_ID;

        CURSOR CSP_REPAIR_PO_SCRAP(L_REPAIR_PO_HEADER_ID NUMBER,
                                   L_SCRAP_ITEM_ID NUMBER,
                                   L_QUANTITY NUMBER
                                   ) IS
        SELECT CRPH.repair_po_header_id,
        CRPH.wip_id,
        CRPH.inventory_item_id,
        CRPH.repair_supplier_org_id,
        CRPH.quantity,
        CRPH.received_qty,
        CRPL.inventory_item_id defect_item_id,
        CRPL.defective_organization_id,
        CRPL.quantity defect_qty,
        CRPL.received_qty defect_received_qty,
        CRPL.SCRAP_QTY,
        CRPL.ADJUSTED_QTY
        FROM CSP_REPAIR_PO_HEADERS CRPH, CSP_REPAIR_PO_LINES CRPL
        WHERE CRPH.REPAIR_PO_HEADER_ID = L_REPAIR_PO_HEADER_ID
          AND CRPH.status = 8
          AND CRPH.repair_po_header_id = CRPL.repair_po_header_id
          AND CRPL.inventory_item_id = L_SCRAP_ITEM_ID;


        l_api_version_number     CONSTANT NUMBER        := 1.0;
        l_api_name               CONSTANT VARCHAR2(30)  := 'RUN_REPAIR_EXECUTION';

        l_Init_Msg_List          VARCHAR2(1)            := FND_API.G_TRUE;
        l_commit                 VARCHAR2(1)            := FND_API.G_TRUE;
        l_validation_level       NUMBER                 := FND_API.G_VALID_LEVEL_FULL;

        x_return_status          VARCHAR2(1)            := FND_API.G_RET_STS_SUCCESS;
        x_msg_count              NUMBER;
        x_msg_data               VARCHAR2(2000);

        l_return_status          VARCHAR2(1)            := FND_API.G_RET_STS_SUCCESS;
        l_msg_count              NUMBER;
        l_msg_data               VARCHAR2(2000);

        l_sqlcode		         NUMBER;
        l_sqlerrm                VARCHAR2(2000);
        g_retcode                NUMBER := 0;
        l_Rollback               VARCHAR2(1)            := 'Y';

        l_today                  DATE;
        l_user_id                NUMBER;
        l_login_id               NUMBER;

        EXCP_USER_DEFINED       EXCEPTION;

        x_relieved_quantity     NUMBER;
        l_reservation_rec       CSP_REPAIR_PO_PVT.out_reserve_rec_type;

        x_item_number           VARCHAR2(40);
        x_item_description      VARCHAR2(240);
        l_primary_uom_code      VARCHAR2(3);
        l_org_name              VARCHAR2(240);
        l_sec_inv_name          VARCHAR2(240);
        L_ORGANIZATION_NAME     VARCHAR2(240);

        l_header_rec            csp_parts_requirement.header_rec_type;
        l_line_rec              csp_parts_requirement.line_rec_type;
        l_line_tbl              csp_parts_requirement.line_Tbl_type;
        l_dest_organization_id  NUMBER;
        I                       NUMBER;
        l_ship_to_location_id   NUMBER;

        L_authorization_status  VARCHAR2(240);
        L_req_number_segment1   VARCHAR2(240);
        l_need_by_date          DATE;

        L_CLASS_CODE            VARCHAR2(240);
        l_WIP_BATCH_ID          NUMBER;
        l_WIP_ENTITY_ID         NUMBER;

        px_transaction_header_id  NUMBER;
        t_transaction_id          NUMBER;
        l_RECEIVED_QTY            NUMBER;
        l_wib_issue_qty           NUMBER;
        FINAL_COMPLETION_FLAG     VARCHAR2(1);
        l_usable_subinv           VARCHAR2(240);
        l_defective_subinv        VARCHAR2(240);
        l_total_scrap_adjust_qty  NUMBER;
        l_org_id                  NUMBER;
        l_wip_status_type	    NUMBER;
        l_WIP_ENTITY_ID_INTERFACE NUMBER;

        L_WIP_START_QUANTITY  NUMBER;
        L_WIP_QUANTITY_SCRAPPED NUMBER;
        L_WIP_REMAIN_QTY NUMBER;
        L_WIP_COMPLETE_QTY NUMBER;
BEGIN

SAVEPOINT RUN_REPAIR_EXECUTION_PVT;

    /** Standard call to check for call compatibility **/
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /** Initialize message list **/
    IF fnd_api.to_boolean(l_Init_Msg_List) THEN
       FND_MSG_PUB.initialize;
    END IF;

    /** Initialize return status **/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /** User and login information **/
    SELECT Sysdate INTO l_today FROM dual;
    l_user_id :=  fnd_global.user_id;
    l_login_id := fnd_global.login_id;

---- Start Step:1 ----

/**
    For all the Repair_po's with status '1'
    i.e In PO_REQUISITIONS_INTERFACE_ALL table AUTHORIZATION_STATUS = 'INCOMPLETE' (or) 'IN PROCESS' (or) 'REJECTED' (or) other.
    Check AUTHORIZATION_STATUS in PO_REQUISITIONS_INTERFACE_ALL is moved to 'APPROVED'
    If that is true or record is moved to PO_REQUISITION_HEADERS_ALL then update the status = 2
    else keep status = 1 as it may be still 'IN PROCESS' (or) 'REJECTED' (or) other status
**/

        FOR CSP_REPAIR_PO_HEADERS_rec IN C_CSP_REPAIR_PO_HEADERS(1)
        LOOP
            OPEN PO_REQ_INTERFACE_ALL(CSP_REPAIR_PO_HEADERS_rec.REQUISITION_NUMBER, CSP_REPAIR_PO_HEADERS_rec.REQUISITION_LINE_ID);
            LOOP
            FETCH PO_REQ_INTERFACE_ALL INTO L_authorization_status, L_req_number_segment1;
                IF (PO_REQ_INTERFACE_ALL%ROWCOUNT = 0) THEN
                    UPDATE CSP_REPAIR_PO_HEADERS SET STATUS = 2
                    WHERE CURRENT OF C_CSP_REPAIR_PO_HEADERS;

                    EXIT;
                ELSIF PO_REQ_INTERFACE_ALL%FOUND and NVL(L_authorization_status,'APPROVED') = 'APPROVED' THEN
                    UPDATE CSP_REPAIR_PO_HEADERS SET STATUS = 2
                    WHERE CURRENT OF C_CSP_REPAIR_PO_HEADERS;

                    EXIT;
                ELSE
                    UPDATE CSP_REPAIR_PO_HEADERS SET STATUS = 1
                    WHERE CURRENT OF C_CSP_REPAIR_PO_HEADERS;

                    EXIT;
                END IF;
            END LOOP;
            CLOSE PO_REQ_INTERFACE_ALL;
        END LOOP;

COMMIT;

---- End Step:1 ----

---- Start Step:2 ----

/**
    For all the Repair_po whose status is '2'
    i.e In PO_REQUISITION_HEADERS_ALL table AUTHORIZATION_STATUS = 'CREATED' or 'IN PROCESS' or other
    check AUTHORIZATION_STATUS in PO_REQUISITION_HEADERS_ALL is moved to 'APPROVED'
    If that is true update the status = 3
    else keep status = 2 as it may be still in 'IN PROCESS' (or) 'REJECTED' (or) other status
**/
SAVEPOINT RUN_REPAIR_EXECUTION_PVT;

        FOR CSP_REPAIR_PO_HEADERS_rec IN C_CSP_REPAIR_PO_HEADERS(2)
        LOOP
            FOR PO_REQ_HEADERS_ALL_rec IN PO_REQ_HEADERS_ALL(CSP_REPAIR_PO_HEADERS_rec.REQUISITION_NUMBER, CSP_REPAIR_PO_HEADERS_rec.REQUISITION_LINE_ID)
            LOOP
                If PO_REQ_HEADERS_ALL_rec.AUTHORIZATION_STATUS = 'APPROVED' then
                    UPDATE CSP_REPAIR_PO_HEADERS SET STATUS = 3,REQUISITION_HEADER_ID = PO_REQ_HEADERS_ALL_rec.REQUISITION_HEADER_ID
                    WHERE CURRENT OF C_CSP_REPAIR_PO_HEADERS;
                End if;
            END LOOP;
        END LOOP;

COMMIT;

---- End Step:2 ----

---- Start Step:3 ----

/** For all the repair_po with status '3'
    If record is created in PO_HEADERS_ALL table
    and CLOSED_CODE (or) AUTHORIZATION_STATUS is not 'APPROVED' then update the status = 4.
    Else if CLOSED_CODE (or) AUTHORIZATION_STATUS = 'APPROVED' then update the status = 5.
**/

SAVEPOINT RUN_REPAIR_EXECUTION_PVT;

        FOR CSP_REPAIR_PO_HEADERS_rec IN C_CSP_REPAIR_PO_HEADERS(3)
        LOOP
            FOR PO_HEADERS_ALL_rec IN PO_HEADERS_ALL(CSP_REPAIR_PO_HEADERS_rec.REQUISITION_LINE_ID)
            LOOP
                If NVL(PO_HEADERS_ALL_rec.CLOSED_CODE,'OPEN') = 'OPEN'
                       OR NVL(PO_HEADERS_ALL_rec.AUTHORIZATION_STATUS,'OPEN') = 'OPEN' then
                   UPDATE CSP_REPAIR_PO_HEADERS
                      SET PURCHASE_ORDER_HEADER_ID = PO_HEADERS_ALL_rec.PO_HEADER_ID,
                          PO_NUMBER = PO_HEADERS_ALL_rec.SEGMENT1, STATUS = 4
                    WHERE CURRENT OF C_CSP_REPAIR_PO_HEADERS;
                Elsif NVL(PO_HEADERS_ALL_rec.CLOSED_CODE,'OPEN') = 'APPROVED'
                          OR NVL(PO_HEADERS_ALL_rec.AUTHORIZATION_STATUS,'OPEN') = 'APPROVED' then
                   UPDATE CSP_REPAIR_PO_HEADERS
                      SET PURCHASE_ORDER_HEADER_ID = PO_HEADERS_ALL_rec.PO_HEADER_ID,
                          PO_NUMBER = PO_HEADERS_ALL_rec.SEGMENT1, STATUS = 5
                    WHERE CURRENT OF C_CSP_REPAIR_PO_HEADERS;
                End if;
            END LOOP;
        END LOOP;

COMMIT;

---- End Step:3 ----

---- Start Step:4 ----

/** For all the repair_po with status '4'
    If record is created in PO_HEADERS_ALL table
    and CLOSED_CODE (or) AUTHORIZATION_STATUS = 'APPROVED' then update the status = 5.
**/

SAVEPOINT RUN_REPAIR_EXECUTION_PVT;

        FOR CSP_REPAIR_PO_HEADERS_rec IN C_CSP_REPAIR_PO_HEADERS(4)
        LOOP
            FOR PO_HEADERS_ALL_rec IN PO_HEADERS_ALL(CSP_REPAIR_PO_HEADERS_rec.REQUISITION_LINE_ID)
            LOOP
                If NVL(PO_HEADERS_ALL_rec.CLOSED_CODE,'OPEN') = 'APPROVED'
                       OR NVL(PO_HEADERS_ALL_rec.AUTHORIZATION_STATUS,'OPEN') = 'APPROVED' then
                   UPDATE CSP_REPAIR_PO_HEADERS
                      SET PURCHASE_ORDER_HEADER_ID = PO_HEADERS_ALL_rec.PO_HEADER_ID,
                          PO_NUMBER = PO_HEADERS_ALL_rec.SEGMENT1, STATUS = 5
                    WHERE CURRENT OF C_CSP_REPAIR_PO_HEADERS;
                End if;
            END LOOP;
        END LOOP;

COMMIT;

---- End Step:4 ----

---- Start Step:5 ----
/** For all the repair_po with status '5'
    i.e Record is created in PO_HEADERS_ALL table and CLOSED_CODE (or) AUTHORIZATION_STATUS = 'APPROVED'
    If no internal order is created and REPAIR_PROGRAM <> 'PRE-POSITIONING' then
    create an internal order and cancel the existing reservation.
**/

/*
    SELECT TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
           SUBSTRB(USERENV('CLIENT_INFO'),1,10)))
      INTO   l_org_id
      FROM   dual;

    po_moac_utils_pvt.set_org_context(l_org_id);

*/

   MO_GLOBAL.init('CSF');

--SAVEPOINT RUN_REPAIR_EXECUTION_PVT;

        FOR CSP_REPAIR_PO_HEADERS_rec IN CSP_REPAIR_PO_HEADERS_ROW(5)
        LOOP

        SAVEPOINT RUN_REPAIR_EXECUTION_PVT; /* Create this save point if the commit not exits the loop */

        If (CSP_REPAIR_PO_HEADERS_rec.STATUS = 5 AND
            CSP_REPAIR_PO_HEADERS_rec.INTERNAL_ORDER_HEADER_ID IS NULL) Then
            --AND CSP_REPAIR_PO_HEADERS_rec.REPAIR_PROGRAM ='3') Then -- 'Repair Return'

            I := 1;

            FOR CSP_RESERVED_LINES_rec IN CSP_RESERVED_LINES(CSP_REPAIR_PO_HEADERS_rec.REPAIR_PO_HEADER_ID)
            LOOP

                CSP_REPAIR_PO_GRP.GET_ITEM_DETAILS
                (CSP_RESERVED_LINES_rec.defective_organization_id
                ,CSP_RESERVED_LINES_rec.inventory_item_id
                ,x_item_number
                ,x_item_description
                ,l_primary_uom_code
                ,x_return_status
                ,x_msg_data
                ,x_msg_count
                );

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    L_ORG_NAME := CSP_REPAIR_PO_GRP.GET_ORGANIZATION_NAME(CSP_RESERVED_LINES_rec.defective_organization_id);
                    FND_MESSAGE.SET_NAME ('CSP','CSP_NO_DEFECTITEM_AT_DEFECTORG');
                    FND_MESSAGE.SET_TOKEN ('DEFECTIVE_ORG_NAME', L_ORG_NAME,TRUE);
                    FND_MSG_PUB.ADD;
                    Add_Err_Msg;
                    g_retcode := 1;
                END IF;

                l_reservation_rec.item_uom_code := l_primary_uom_code;

                csp_sch_int_pvt.cancel_reservation(p_reserv_id      => CSP_RESERVED_LINES_rec.reservation_id,
                                                   x_return_status  => l_return_status,
                                                   x_msg_data       => l_msg_data,
                                                   x_msg_count      => l_msg_count);
                /*
                csp_sch_int_pvt.DELETE_RESERVATION(p_reservation_id => CSP_RESERVED_LINES_rec.reservation_id
                                                  ,x_return_status => l_return_status
                                                  ,x_msg_data      => l_msg_data );
                */

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   Add_Err_Msg;
                   g_retcode := 1;
                   errbuf := X_Msg_Data;
                   ROLLBACK TO RUN_REPAIR_EXECUTION_PVT;

                Elsif (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                    l_line_rec.line_num                 := I; -- 1;
                    l_line_rec.inventory_item_id        := CSP_RESERVED_LINES_rec.inventory_item_id;
                  --l_line_rec.item_description         := 'Sentinel Standard Desktop';
                    l_line_rec.sourced_from             := 'INVENTORY';
                    l_line_rec.ordered_quantity         := CSP_RESERVED_LINES_rec.quantity;
                    l_line_rec.unit_of_measure          := l_primary_uom_code;
                    l_line_rec.dest_subinventory        := FND_PROFILE.value(NAME => 'CSP_REPAIR_SUP_ORG_DEFECT_SUBINV');
                  --l_line_rec.dest_subinventory        := 'FldSvc';
                    l_line_rec.source_organization_id   := CSP_RESERVED_LINES_rec.defective_organization_id;
                  --l_line_Rec.order_line_id            := 50762;
                  --l_line_rec.source_subinventory      := 'Stores';
                  --l_line_rec.booked_flag              := 'N'; --'Y'

                    l_line_tbl(I)                       := l_line_rec;
                    I                                   := I+1;

                End if;
            END LOOP;

            l_dest_organization_id := CSP_REPAIR_PO_HEADERS_rec.REPAIR_SUPPLIER_ORG_ID;
            l_need_by_date := SYSDATE; /* CSP_REPAIR_PO_HEADERS_rec.need_by_date; */

            /** 1.( Need_by_date of repair-to_item at dest org ) -
                  (Transit time between repair supplier org to dest org)
                  = Completion Date of repair-to_item at repair supplier org.
                2. Completion Date - Repair_Lead_Time = Start date of the wip job
                   Here Internal order Need_by_date should be equal to Start date of the wip job.
            **/

            l_sec_inv_name := FND_PROFILE.value(NAME => 'CSP_REPAIR_SUP_ORG_DEFECT_SUBINV');

            Begin
                SELECT LOCATION_ID
                  INTO l_ship_to_location_id
                  FROM MTL_SECONDARY_INVENTORIES
                 WHERE ORGANIZATION_ID = l_dest_organization_id
                   AND SECONDARY_INVENTORY_NAME = l_sec_inv_name; -- 'FldSvc'
            Exception
                when no_data_found then
                l_ship_to_location_id := Null;
            End;

            If l_ship_to_location_id is null then
                Begin
                    SELECT LOCATION_ID
                    INTO l_ship_to_location_id
                    FROM HR_ORGANIZATION_UNITS
                    WHERE ORGANIZATION_ID = l_dest_organization_id;
                Exception
                    when no_data_found then
                    l_ship_to_location_id := Null;
                End;
            End if;

            If l_ship_to_location_id is null then
                L_ORGANIZATION_NAME := CSP_REPAIR_PO_GRP.GET_ORGANIZATION_NAME(l_dest_organization_id);
                FND_MESSAGE.SET_NAME ('CSP','CSP_NO_SHIPTO_LOCATION_ID');
                FND_MESSAGE.SET_TOKEN ('DESTINATION_ORG', L_ORGANIZATION_NAME, TRUE);
                FND_MSG_PUB.ADD;
                Add_Err_Msg;
                g_retcode := 1;
            End if;

          --l_header_rec.description := 'Test Req';
          --l_header_rec.order_type_id := 1430;
            FND_PROFILE.GET('CSP_ORDER_TYPE', l_header_rec.order_type_id);
            l_header_rec.dest_organization_id := l_dest_organization_id;
            l_header_rec.operation := csp_parts_order.G_OPR_CREATE;
            l_header_rec.ship_to_location_id := l_ship_to_location_id;
            l_header_rec.requisition_number := NULL;
            l_header_rec.order_header_id := NULL;
            l_header_rec.requisition_header_id := NULL;
            l_header_rec.need_by_date := l_need_by_Date;

            csp_parts_order.process_order
            (
              p_api_version             => 1.0
             ,p_Init_Msg_List           => FND_API.G_FALSE
             ,p_commit                  => FND_API.G_FALSE
             ,px_header_rec             => l_header_rec
             ,px_line_table             => l_line_tbl
           --,p_process_type            => 'BOTH'(Default value is 'BOTH')
             ,x_return_status           => x_return_status
             ,x_msg_count               => x_msg_count
             ,x_msg_data                => x_msg_data
            );

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                Add_Err_Msg;
                g_retcode   := 1;
                errbuf      := X_Msg_Data;
                ROLLBACK TO RUN_REPAIR_EXECUTION_PVT;
            Elsif (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            /* STATUS = 6 => INTERNAL_ORDER CREATED  */

            UPDATE CSP_REPAIR_PO_HEADERS
            SET INTERNAL_ORDER_HEADER_ID = l_header_rec.order_header_id,
                STATUS = 6
            -- WHERE CURRENT OF CSP_REPAIR_PO_HEADERS;
            WHERE ROWID = CSP_REPAIR_PO_HEADERS_rec.ROWID;

            COMMIT; /* Do this commit if it is not exits the loop */

            End if;

        End if;
        END LOOP;

--COMMIT;

---- End Step:5 ----

---- Start Step:6 ----
/** Loop through each IO Lines for the Internal_order created and then check QTY_RECEIVED > 0
    Check for existing WIP_JOB in WIP_ENTITIES that wip job is loaded through wip mass load or through API
    if WIP_JOB NOT created already then insert to interface table and do wip issue transaction
    elseif WIP_JOB created already and it is there in WIP_ENTITIES table then do wip issue transaction
**/

--SAVEPOINT RUN_REPAIR_EXECUTION_PVT;

        For I in 6..8 Loop

        FOR CSP_REPAIR_PO_HEADERS_rec IN CSP_REPAIR_PO_HEADERS_ROW(I)
        LOOP
          /**Loop through each IO Lines for the Internal_order created and
            then check QTY_RECEIVED > 0
          **/

            FOR IO_QTY_RECEIVED_CHECK_REC IN IO_QTY_RECEIVED_CHECK(CSP_REPAIR_PO_HEADERS_rec.INTERNAL_ORDER_HEADER_ID)
            LOOP

            SAVEPOINT RUN_REPAIR_EXECUTION_PVT; /* Create this save point if the commit not exits the loop */

            CSP_REPAIR_PO_GRP.GET_ITEM_DETAILS
                    (IO_QTY_RECEIVED_CHECK_REC.DESTINATION_ORGANIZATION_ID
                    ,IO_QTY_RECEIVED_CHECK_REC.item_id
                    ,x_item_number
                    ,x_item_description
                    ,l_primary_uom_code
                    ,x_return_status
                    ,x_msg_data
                    ,x_msg_count
                    );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               L_ORG_NAME := CSP_REPAIR_PO_GRP.GET_ORGANIZATION_NAME(CSP_REPAIR_PO_HEADERS_rec.repair_supplier_org_id);
               FND_MESSAGE.SET_NAME ('CSP','CSP_NO_DEFECTITEM_AT_REPAIRORG');
               FND_MESSAGE.SET_TOKEN ('REPAIR_SUPPLIER_ORG_NAME', L_ORG_NAME,TRUE);
               FND_MSG_PUB.ADD;
               Add_Err_Msg;
               g_retcode := 1;
            END IF;

            If nvl(IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,0) > 0 and
               CSP_REPAIR_PO_HEADERS_rec.WIP_ID IS NULL THEN
               /** Create a WIB_JOB if there is no WIB_JOB created for this INTERNAL_ORDER so far **/

                select WIP_JOB_SCHEDULE_INTERFACE_S.nextval
                into l_WIP_BATCH_ID
                from dual;

                SELECT WIP_ENTITIES_S.NEXTVAL
                INTO l_WIP_ENTITY_ID
				FROM DUAL;

                Begin
                SELECT CLASS_CODE
                  INTO L_CLASS_CODE
                  FROM WIP_NON_STANDARD_CLASSES_VAL_V
                 WHERE ORGANIZATION_ID = CSP_REPAIR_PO_HEADERS_rec.repair_supplier_org_id
                   AND CLASS_TYPE = 4
                   AND CLASS_CODE = 'Expense';
                Exception
                  WHEN NO_DATA_FOUND THEN
                  L_CLASS_CODE := NULL;
                End;

                If L_CLASS_CODE is null then
                    L_ORGANIZATION_NAME := CSP_REPAIR_PO_GRP.GET_ORGANIZATION_NAME(CSP_REPAIR_PO_HEADERS_rec.repair_supplier_org_id);
                    FND_MESSAGE.SET_NAME ('CSP','CSP_NO_WIP_CLASS_CODE');
                    FND_MESSAGE.SET_TOKEN ('REPAIR_SUPPLIER_ORG', L_ORGANIZATION_NAME, TRUE);
                    FND_MSG_PUB.ADD;
                    Add_Err_Msg;
                    g_retcode := 1;
                End if;

                Begin
                INSERT INTO WIP_JOB_SCHEDULE_INTERFACE(
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                GROUP_ID,
                SOURCE_CODE,
                SOURCE_LINE_ID,
                PROCESS_PHASE,
                PROCESS_STATUS,
                ORGANIZATION_ID,
                LOAD_TYPE,
                PRIMARY_ITEM_ID,
                START_QUANTITY,
                STATUS_TYPE,
                FIRST_UNIT_START_DATE,
                FIRST_UNIT_COMPLETION_DATE,
                LAST_UNIT_START_DATE,
                LAST_UNIT_COMPLETION_DATE,
                CLASS_CODE,
                WIP_ENTITY_ID,
                JOB_NAME,
                FIRM_PLANNED_FLAG)
               VALUES(
               sysdate,
               l_user_id,
               sysdate,
               l_user_id,
               l_WIP_BATCH_ID,
               'CSP',
               CSP_REPAIR_PO_HEADERS_rec.INTERNAL_ORDER_HEADER_ID, --> (or) Pass CSP_REPAIR_PO_HEADERS_rec.repair_po_header_id
               2,                                       --> 2 Validation, 4 Completion
               1,                                       --> 1 Pending, 4 Complete
               CSP_REPAIR_PO_HEADERS_rec.repair_supplier_org_id,
               4,                                       --> LOAD_TYPE: 4 Non-standard discrete jobs, 3 update discrete jobs, 1 standard discrete jobs
               CSP_REPAIR_PO_HEADERS_rec.INVENTORY_ITEM_ID,
               nvl(IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,0),--CSP_REPAIR_PO_HEADERS_rec.QUANTITY,
               3,                                       --> Status type: 3 Released, 4 Complete, 12 closed
               SYSDATE,                                 --> FIRST_UNIT_START_DATE
               CSP_REPAIR_PO_HEADERS_rec.NEED_BY_DATE,  --> FIRST_UNIT_COMPLETION_DATE,
               SYSDATE,                                 --> LAST_UNIT_START_DATE
               CSP_REPAIR_PO_HEADERS_rec.NEED_BY_DATE,  --> LAST_UNIT_COMPLETION_DATE
               L_CLASS_CODE,                            --> 'Expense'
               l_WIP_ENTITY_ID,                         --> Pass existing Wip_Entity_Id for update job status to "Complete"
               'REPAIR_EXECUTION'||l_WIP_ENTITY_ID,      --> Pass existing job name(WIP_ENTITY_NAME) for update job status to "Complete"
               1
                );
                Exception
                    When others then
                    l_sqlcode := SQLCODE;
                    l_sqlerrm := SQLERRM;
            	    g_retcode   := 1;
             	    errbuf    := SQLERRM;
            	    fnd_message.set_name ('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                    fnd_message.set_token('ROUTINE', l_api_name, TRUE);
            	    fnd_message.set_token('SQLERRM', l_sqlcode || ': ' || l_sqlerrm, TRUE);
            	    fnd_msg_pub.add;
            	    Add_Err_Msg;
                    Rollback to RUN_REPAIR_EXECUTION_PVT;
                End;

                l_WIP_ENTITY_ID_INTERFACE := l_WIP_ENTITY_ID;

               /**
                 We could use the WIP api to create the WIP_JOB
                 instead of using WIP_MASS_LOAD program through form
               **/

               /** Check if WIP_JOB is created by WIP MASS LOAD PROGRAM **/

                Begin
                Select wip_entity_id
                  into l_wip_entity_id
                  from WIP_ENTITIES
                 Where wip_entity_id = l_WIP_ENTITY_ID;
                 --and wip_entity_name = 'REPAIR_EXECUTION'||l_WIP_ENTITY_ID;
                Exception
                 when no_data_found then
                 l_wip_entity_id := Null;
                End;

                If l_wip_entity_id is not null then

                /** Create Wip component issue transaction to the wip job **/

                csp_transactions_pub.transact_material
                ( p_api_version              => 1.0
                , p_init_msg_list            => FND_API.G_FALSE
                , p_commit                   => FND_API.G_FALSE
                , px_transaction_header_id   => px_transaction_header_id
                , px_transaction_id          => t_transaction_id
                , p_inventory_item_id        => IO_QTY_RECEIVED_CHECK_REC.item_id
                , p_organization_id          => IO_QTY_RECEIVED_CHECK_REC.DESTINATION_ORGANIZATION_ID
                , p_subinventory_code        => IO_QTY_RECEIVED_CHECK_REC.DESTINATION_SUBINVENTORY
                , p_locator_id               => null
                , p_lot_number               => null
                , p_lot_expiration_date      => NULL
                , p_revision                 => null
                , p_serial_number            => null
                , p_to_serial_number         => null
                , p_quantity                 => IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED
                , p_uom                      => l_primary_uom_code
                , p_source_id                => null
                , p_source_line_id           => null
                , p_transaction_type_id      => 35
                , p_account_id               => null
                , p_transfer_to_subinventory => null
                , p_transfer_to_locator      => null
                , p_transfer_to_organization => null
                , p_online_process_flag 	 => TRUE
                , p_transaction_source_id    => l_WIP_ENTITY_ID
                , p_trx_source_line_id       => null
                , p_transaction_source_name	 => CSP_REPAIR_PO_HEADERS_rec.repair_po_header_id ||'REPAIR_PO_WIP_ISSUE'
                , p_waybill_airbill		     => null
                , p_shipment_number          => null
                , p_freight_code		     => null
                , p_reason_id			     => null
                , p_transaction_reference    => CSP_REPAIR_PO_HEADERS_rec.repair_po_header_id
                , p_expected_delivery_date   => null
                , x_return_status            => l_return_status
                , x_msg_count                => l_msg_count
                , x_msg_data                 => l_msg_data
                );

                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    -- Raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    Add_Err_Msg;
                    g_retcode   := 1;
                    errbuf      := l_Msg_Data;
                    ROLLBACK TO RUN_REPAIR_EXECUTION_PVT;
                End if;

                   /* STATUS = 8 => 'WIP_JOB_CREATED' by WIP MASS LOAD PROGRAM */
                    UPDATE CSP_REPAIR_PO_HEADERS
                    SET WIP_ID = l_WIP_ENTITY_ID, STATUS = 8
                    -- WHERE CURRENT OF CSP_REPAIR_PO_HEADERS;
                    WHERE ROWID = CSP_REPAIR_PO_HEADERS_rec.ROWID;

                    UPDATE WIP_REQUIREMENT_OPERATIONS
                       SET QUANTITY_PER_ASSEMBLY = 1
                    WHERE INVENTORY_ITEM_ID =  IO_QTY_RECEIVED_CHECK_REC.item_id
                      AND ORGANIZATION_ID =  IO_QTY_RECEIVED_CHECK_REC.DESTINATION_ORGANIZATION_ID
                      AND WIP_ENTITY_ID  = l_WIP_ENTITY_ID ;

                Else
                   /* STATUS = 7 => Inserted into 'WIP_JOB_SCHEDULE_INTERFACE' */
                   UPDATE CSP_REPAIR_PO_HEADERS
                   SET WIP_ID = l_WIP_ENTITY_ID_INTERFACE, STATUS = 7
                   -- WHERE CURRENT OF CSP_REPAIR_PO_HEADERS;
                   WHERE ROWID = CSP_REPAIR_PO_HEADERS_rec.ROWID;
                End if;

               UPDATE CSP_REPAIR_PO_LINES
               SET RECEIVED_QTY = IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED
               where repair_po_header_id = CSP_REPAIR_PO_HEADERS_rec.repair_po_header_id
               and inventory_item_id = IO_QTY_RECEIVED_CHECK_REC.item_id;

               COMMIT; /* Do this commit if it is not exits the loop */

        /** Elseif WIB_JOB already created **/
        Elsif CSP_REPAIR_PO_HEADERS_rec.WIP_ID IS NOT NULL THEN
               --> Check if more parts are received by the following condition

               Begin
               SELECT RECEIVED_QTY
                 INTO l_RECEIVED_QTY
                 FROM CSP_REPAIR_PO_LINES
                WHERE repair_po_header_id = CSP_REPAIR_PO_HEADERS_rec.repair_po_header_id
                and inventory_item_id = IO_QTY_RECEIVED_CHECK_REC.item_id;
                Exception
                 when no_data_found then
                 l_RECEIVED_QTY := Null;
                End;

                Begin
                Select wip_entity_id
                  into l_wip_entity_id
                  from WIP_ENTITIES
                 Where wip_entity_id = CSP_REPAIR_PO_HEADERS_rec.WIP_ID;
                 --and wip_entity_name = 'REPAIR_EXECUTION'||l_WIP_ENTITY_ID;
                Exception
                 when no_data_found then
                 l_wip_entity_id := Null;
                End;

/*** Added for bug 12621761 ***/
                If nvl(l_RECEIVED_QTY,0) < nvl(IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,0)
                   and CSP_REPAIR_PO_HEADERS_rec.STATUS = 8
                   and l_wip_entity_id is not null then

                   Update WIP_DISCRETE_JOBS
                      set START_QUANTITY = IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,
                        LAST_UPDATE_DATE = SYSDATE
                      Where WIP_ENTITY_ID = CSP_REPAIR_PO_HEADERS_rec.WIP_ID;
                End if;
/*** End for bug 12621761 ***/

            /** 1.Check if
                    (Parts qty issued to WIP_JOB before <
                    Current received qty in the "PO_REQUISITION_LINES_ALL" table for this internal order line)
                2.Check if WIP_JOB is created by WIP MASS LOAD PROGRAM
            */

            If ( nvl(l_RECEIVED_QTY,0) < nvl(IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,0)
                 or
                 (nvl(l_RECEIVED_QTY,0) <= nvl(IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,0)
                  and CSP_REPAIR_PO_HEADERS_rec.STATUS = 7)
               )
               and l_wip_entity_id is not null then

               /** Create Wip component issue transaction to the job
                   and issue parts qty as
                   (current received qty for this part in PO_REQ_LINES -
                   Qty received for this part before in CSP_REPAIR_PO_LINES)
                   to the existing WIP JOB by Calling CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL
               */

                l_wib_issue_qty := 0;

                If CSP_REPAIR_PO_HEADERS_rec.STATUS = 7 then
                    If nvl(IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,0) > nvl(l_RECEIVED_QTY,0) then
                        l_wib_issue_qty := nvl(IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,0);
                    Elsif nvl(IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,0) = nvl(l_RECEIVED_QTY,0) then
                        l_wib_issue_qty := nvl(l_RECEIVED_QTY,0);

                    End if;
                Else
                    l_wib_issue_qty := nvl(IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,0) - nvl(l_RECEIVED_QTY,0);
                End if;

                If nvl(l_wib_issue_qty,0) > 0 then

                csp_transactions_pub.transact_material
                ( p_api_version              => 1.0
                , p_init_msg_list            => FND_API.G_FALSE
                , p_commit                   => FND_API.G_FALSE
                , px_transaction_header_id   => px_transaction_header_id
                , px_transaction_id          => t_transaction_id
                , p_inventory_item_id        => IO_QTY_RECEIVED_CHECK_REC.item_id
                , p_organization_id          => IO_QTY_RECEIVED_CHECK_REC.DESTINATION_ORGANIZATION_ID
                , p_subinventory_code        => IO_QTY_RECEIVED_CHECK_REC.DESTINATION_SUBINVENTORY
                , p_locator_id               => null
                , p_lot_number               => null
                , p_lot_expiration_date      => NULL
                , p_revision                 => null
                , p_serial_number            => null
                , p_to_serial_number         => null
                , p_quantity                 => l_wib_issue_qty
                , p_uom                      => l_primary_uom_code
                , p_source_id                => null
                , p_source_line_id           => null
                , p_transaction_type_id      => 35
                , p_account_id               => null
                , p_transfer_to_subinventory => null
                , p_transfer_to_locator      => null
                , p_transfer_to_organization => null
                , p_online_process_flag 	 => TRUE
                , p_transaction_source_id    => l_WIP_ENTITY_ID
                , p_trx_source_line_id       => null
                , p_transaction_source_name	 => CSP_REPAIR_PO_HEADERS_rec.repair_po_header_id ||'REPAIR_PO_WIP_ISSUE'
                , p_waybill_airbill		     => null
                , p_shipment_number          => null
                , p_freight_code		     => null
                , p_reason_id			     => null
                , p_transaction_reference    => CSP_REPAIR_PO_HEADERS_rec.repair_po_header_id
                , p_expected_delivery_date   => null
                , x_return_status            => l_return_status
                , x_msg_count                => l_msg_count
                , x_msg_data                 => l_msg_data
                );

	                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      	              -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	                    Add_Err_Msg;
	                    g_retcode   := 1;
	                    errbuf      := l_Msg_Data;
	                    ROLLBACK TO RUN_REPAIR_EXECUTION_PVT;
	                End if;

                       UPDATE WIP_REQUIREMENT_OPERATIONS
                       SET QUANTITY_PER_ASSEMBLY = 1
                    WHERE INVENTORY_ITEM_ID =  IO_QTY_RECEIVED_CHECK_REC.item_id
                      AND ORGANIZATION_ID = IO_QTY_RECEIVED_CHECK_REC.DESTINATION_ORGANIZATION_ID
                      AND WIP_ENTITY_ID  = l_WIP_ENTITY_ID ;

                End if;

                If CSP_REPAIR_PO_HEADERS_rec.STATUS = 7 THEN
                    If nvl(IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,0) > nvl(l_RECEIVED_QTY,0) then
                        l_wib_issue_qty := nvl(IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,0) - nvl(l_RECEIVED_QTY,0);
                    Elsif nvl(IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED,0) = nvl(l_RECEIVED_QTY,0) then
                        l_wib_issue_qty := 0;
                    End if;

                    UPDATE CSP_REPAIR_PO_HEADERS
                    SET STATUS = 8
                    --WHERE CURRENT OF CSP_REPAIR_PO_HEADERS;
                    WHERE ROWID = CSP_REPAIR_PO_HEADERS_rec.ROWID;
                End if;

                UPDATE CSP_REPAIR_PO_LINES
                SET RECEIVED_QTY = NVL(RECEIVED_QTY,0) + nvl(l_wib_issue_qty,0)
              --SET RECEIVED_QTY = NVL(RECEIVED_QTY,0) + IO_QTY_RECEIVED_CHECK_REC.QUANTITY_RECEIVED
                where repair_po_header_id = CSP_REPAIR_PO_HEADERS_rec.repair_po_header_id
                and inventory_item_id = IO_QTY_RECEIVED_CHECK_REC.item_id;

                COMMIT; /* Do this commit if it is not exits the loop */

            End if;
        END IF;

        END LOOP;
     END LOOP;

   END LOOP;

-- COMMIT;
---- End Step:6 ----


---- Start Step:7 ----
/** We need to check the PO REQ received qty with the remaining job qty
    IF it is equal then pass 'Y' else pass 'N' for final_completion_flag and do WIP Assembly Completion transaction
    (WIP Assembly Completion: Tansaction_type_id: 44)

    IF the value is 'Y' then it should automatically changes WIP_JOB to "Complete" state STATUS_TYPE 4.
    IF the value is 'N' then WIP_JOB should be in the same "Released" state STATUS_TYPE 3.

    At the end do the Miscellaneous Issue transaction (Miscellaneous Issue: Tansaction_type_id: 32)
**/

--SAVEPOINT RUN_REPAIR_EXECUTION_PVT;

        FOR CSP_REPAIR_PO_HEADERS_rec IN CSP_REPAIR_PO_HEADERS_ROW(8)
        LOOP

            FOR PO_REQ_RECEIVED_QTY_rec IN PO_REQ_RECEIVED_QTY(CSP_REPAIR_PO_HEADERS_rec.REQUISITION_LINE_ID)
            LOOP

                SAVEPOINT RUN_REPAIR_EXECUTION_PVT;

                If (NVL(PO_REQ_RECEIVED_QTY_rec.CLOSED_CODE,'OPEN') = 'APPROVED'
                    OR NVL(PO_REQ_RECEIVED_QTY_rec.AUTHORIZATION_STATUS,'OPEN') = 'APPROVED')
                   AND nvl(PO_REQ_RECEIVED_QTY_rec.quantity_received,0) > 0 then

                   /*
                    Select sum(nvl(scrap_qty,0) + nvl(adjusted_qty,0))
                      into l_total_scrap_adjust_qty
                      from CSP_REPAIR_PO_LINES
                     where REPAIR_PO_HEADER_ID = CSP_REPAIR_PO_HEADERS_rec.REPAIR_PO_HEADER_ID
                   group by REPAIR_PO_HEADER_ID;
                   */

                  SELECT START_QUANTITY,QUANTITY_SCRAPPED
                    INTO L_WIP_START_QUANTITY, L_WIP_QUANTITY_SCRAPPED
                    FROM WIP_DISCRETE_JOBS
                   WHERE CSP_REPAIR_PO_HEADERS_REC.WIP_ID = WIP_ENTITY_ID;

                   L_WIP_REMAIN_QTY := NVL(L_WIP_START_QUANTITY,0) - (NVL(CSP_REPAIR_PO_HEADERS_REC.RECEIVED_QTY,0) + NVL(L_WIP_QUANTITY_SCRAPPED,0));

                   l_usable_subinv := FND_PROFILE.value(NAME => 'CSP_REPAIR_SUP_ORG_USABLE_SUBINV');

              IF ( L_WIP_REMAIN_QTY - (NVL(PO_REQ_RECEIVED_QTY_REC.QUANTITY_RECEIVED,0) - NVL(CSP_REPAIR_PO_HEADERS_REC.RECEIVED_QTY,0)) <= 0 )
                 OR
               ( CSP_REPAIR_PO_HEADERS_rec.quantity - (NVL(PO_REQ_RECEIVED_QTY_REC.QUANTITY_RECEIVED,0) + NVL(L_WIP_QUANTITY_SCRAPPED,0)) <= 0 )
              THEN
                      -- PO_REQ_RECEIVED_QTY_rec.quantity_received >= CSP_REPAIR_PO_HEADERS_rec.quantity - l_total_scrap_adjust_qty then
                      -- nvl(CSP_REPAIR_PO_HEADERS_rec.received_qty,0) = PO_REQ_RECEIVED_QTY_rec.quantity_received

                      FINAL_COMPLETION_FLAG := 'Y';
			    l_wip_status_type := 4;
                   Else
                      FINAL_COMPLETION_FLAG := 'N';
                   End if;

                    CSP_REPAIR_PO_GRP.GET_ITEM_DETAILS
                    (CSP_REPAIR_PO_HEADERS_rec.repair_supplier_org_id
                    ,CSP_REPAIR_PO_HEADERS_rec.INVENTORY_ITEM_ID
                    ,x_item_number
                    ,x_item_description
                    ,l_primary_uom_code
                    ,x_return_status
                    ,x_msg_data
                    ,x_msg_count
                    );

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        L_ORG_NAME := CSP_REPAIR_PO_GRP.GET_ORGANIZATION_NAME(CSP_REPAIR_PO_HEADERS_rec.repair_supplier_org_id);
                        FND_MESSAGE.SET_NAME ('CSP','CSP_NO_REPAIRITEM_AT_REPAIRORG');
                        FND_MESSAGE.SET_TOKEN ('REPAIR_SUPPLIER_ORG_NAME', L_ORG_NAME,TRUE);
                        FND_MSG_PUB.ADD;
                        Add_Err_Msg;
                        g_retcode := 1;
                    END IF;

                    IF (L_WIP_REMAIN_QTY - (NVL(PO_REQ_RECEIVED_QTY_REC.QUANTITY_RECEIVED,0) - NVL(CSP_REPAIR_PO_HEADERS_REC.RECEIVED_QTY,0)) ) > 0 THEN
                        L_WIP_COMPLETE_QTY := NVL(PO_REQ_RECEIVED_QTY_REC.QUANTITY_RECEIVED,0) - NVL(CSP_REPAIR_PO_HEADERS_REC.RECEIVED_QTY,0);

                ELSIF (L_WIP_REMAIN_QTY - (NVL(PO_REQ_RECEIVED_QTY_REC.QUANTITY_RECEIVED,0) - NVL(CSP_REPAIR_PO_HEADERS_REC.RECEIVED_QTY,0)) ) <= 0 THEN
                        L_WIP_COMPLETE_QTY := L_WIP_REMAIN_QTY;

                    END IF;

                    csp_transactions_pub.transact_material
                    ( p_api_version              => 1.0
                    , p_init_msg_list            => FND_API.G_FALSE
                    , p_commit                   => FND_API.G_FALSE
                    , px_transaction_header_id   => px_transaction_header_id
                    , px_transaction_id          => t_transaction_id
                    , p_inventory_item_id        => CSP_REPAIR_PO_HEADERS_rec.INVENTORY_ITEM_ID
                    , p_organization_id          => CSP_REPAIR_PO_HEADERS_rec.repair_supplier_org_id
                    , p_subinventory_code        => l_usable_subinv
                    , p_locator_id               => null
                    , p_lot_number               => null
                    , p_lot_expiration_date      => NULL
                    , p_revision                 => null
                    , p_serial_number            => null
                    , p_to_serial_number         => NULL
                    , p_quantity                 => L_WIP_COMPLETE_QTY
                    , p_uom                      => l_primary_uom_code
                    , p_source_id                => null
                    , p_source_line_id           => null
                    , p_transaction_type_id      => 44
                    , p_account_id               => null
                    , p_transfer_to_subinventory => null
                    , p_transfer_to_locator      => null
                    , p_transfer_to_organization => null
                    , p_online_process_flag 	 => TRUE
                    , p_transaction_source_id    => CSP_REPAIR_PO_HEADERS_rec.wip_id
                    , p_trx_source_line_id       => null
                    , p_transaction_source_name	 => CSP_REPAIR_PO_HEADERS_rec.repair_po_header_id ||'REPAIR_PO_WIP_COMPLETE'
                    , p_waybill_airbill		     => NULL
                    , p_shipment_number          => NULL
                    , p_freight_code		     => NULL
                    , p_reason_id			     => NULL
                    , p_transaction_reference    => CSP_REPAIR_PO_HEADERS_rec.repair_po_header_id
                    , p_expected_delivery_date   => NULL
                    , p_FINAL_COMPLETION_FLAG    => 'N' --FINAL_COMPLETION_FLAG -- May need to add this parameter for wip complete
                    , x_return_status            => l_return_status
                    , x_msg_count                => l_msg_count
                    , x_msg_data                 => l_msg_data
                    );

                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        Add_Err_Msg;
                        g_retcode   := 1;
                        errbuf      := l_msg_Data;
                        ROLLBACK TO RUN_REPAIR_EXECUTION_PVT;
                    End if;

                /** 1.We can do this insert (only) if FINAL_COMPLETION_FLAG = 'Y'
                      i.e PO_REQ_RECEIVED_QTY_rec.quantity_received = CSP_REPAIR_PO_HEADERS_rec.quantity - l_total_scrap_adjust_qty
                      But This Insert may not be needed if FINAL_COMPLETION_FLAG is passed as 'Y' in the above call

                    2.If we do this insert then we could use the WIP api to update the WIP_JOB
                      instead of using WIP_MASS_LOAD program form
                **/

--------------------- Start comment on Nov-29-2005 -----------------
/*

                select WIP_JOB_SCHEDULE_INTERFACE_S.nextval
                into l_WIP_BATCH_ID
                from dual;

                Begin
                INSERT INTO WIP_JOB_SCHEDULE_INTERFACE(
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                GROUP_ID,
                SOURCE_CODE,
                SOURCE_LINE_ID,
                PROCESS_PHASE,
                PROCESS_STATUS,
                ORGANIZATION_ID,
                LOAD_TYPE,
                PRIMARY_ITEM_ID,
                START_QUANTITY,
                STATUS_TYPE,
                --FIRST_UNIT_START_DATE,
                --FIRST_UNIT_COMPLETION_DATE,
                --LAST_UNIT_START_DATE,
                --LAST_UNIT_COMPLETION_DATE,
                CLASS_CODE,
                WIP_ENTITY_ID,
                JOB_NAME
                )
            Select
               SYSDATE,
               l_user_id,
               SYSDATE,
               l_user_id,
               l_WIP_BATCH_ID,
               SOURCE_CODE,
               SOURCE_LINE_ID,
               decode(FINAL_COMPLETION_FLAG,'Y',4,2), --> 2 Validation, 4 Completion
               decode(FINAL_COMPLETION_FLAG,'Y',4,1), --> 1 Pending, 4 Complete
               ORGANIZATION_ID,
               3,                                    --> Load type: 4 Create non-standard wip job, 3 Update non-standard wip job
               PRIMARY_ITEM_ID,
               START_QUANTITY,
               decode(FINAL_COMPLETION_FLAG,'Y',4,3), --> Status type: 3 Released, 4 Complete
               --FIRST_UNIT_START_DATE,
               --FIRST_UNIT_COMPLETION_DATE,
               --LAST_UNIT_START_DATE,
               --LAST_UNIT_COMPLETION_DATE,
               CLASS_CODE,
               CSP_REPAIR_PO_HEADERS_rec.WIP_ID,     --> Pass existing Wip_Entity_Id for update job status to "Complete"
               'REPAIR_EXECUTION'||CSP_REPAIR_PO_HEADERS_rec.WIP_ID --> Pass existing job name(WIP_ENTITY_NAME) for update job status to "Complete"
               FROM WIP_DISCRETE_JOBS
               WHERE WIP_ENTITY_ID = CSP_REPAIR_PO_HEADERS_rec.WIP_ID;

                Exception
                    When others then
                    l_sqlcode := SQLCODE;
                    l_sqlerrm := SQLERRM;
            	    g_retcode   := 1;
             	    errbuf    := SQLERRM;
            	    fnd_message.set_name ('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                    fnd_message.set_token('ROUTINE', l_api_name, TRUE);
            	    fnd_message.set_token('SQLERRM', l_sqlcode || ': ' || l_sqlerrm, TRUE);
            	    fnd_msg_pub.add;
            	    Add_Err_Msg;
                    Rollback to RUN_REPAIR_EXECUTION_PVT;
                End;
--------------------- End comment on Nov-29-2005 -----------------
*/

            /** If possible update WIP_DISCRETE_JOBS directly to update the quantity completed so far.
		    If FINAL_COMPLETION_FLAG = 'Y' and not automatically moved to complet status by mass upload
			 update the STATUS_TYPE = 4(Complete) OR 12(Closed)
		**/

/*
            Update WIP_DISCRETE_JOBS
            set --QUANTITY_COMPLETED = nvl(QUANTITY_COMPLETED,0) + PO_REQ_RECEIVED_QTY_rec.quantity_received,
            LAST_UPDATE_DATE = SYSDATE, STATUS_TYPE = nvl(l_wip_status_type,STATUS_TYPE),
            DATE_COMPLETED = DECODE(FINAL_COMPLETION_FLAG,'Y',SYSDATE,DATE_COMPLETED)
            Where WIP_ENTITY_ID = CSP_REPAIR_PO_HEADERS_rec.WIP_ID;
*/
            /** "MISCELLANEOUS ISSUE" : MATERIAL TRANSACTION : TRANSACTION_TYPE_ID (32): ----
                When PO qty is received and wip job qty is transacted to Usable Subinv through WIP Assembly Completion then
                From Repair Supplier Org's Usable Subinv do this "MISCELLANEOUS_ISSUE" MATERIAL TRANSACTION
            **/

            csp_transactions_pub.transact_material
            ( p_api_version              => 1.0
            , p_init_msg_list            => FND_API.G_FALSE
            , p_commit                   => FND_API.G_FALSE
            , px_transaction_header_id   => px_transaction_header_id
            , px_transaction_id          => t_transaction_id
            , p_inventory_item_id        => CSP_REPAIR_PO_HEADERS_rec.INVENTORY_ITEM_ID
            , p_organization_id          => CSP_REPAIR_PO_HEADERS_rec.repair_supplier_org_id
            , p_subinventory_code        => l_usable_subinv
            , p_locator_id               => null
            , p_lot_number               => null
            , p_lot_expiration_date      => NULL
            , p_revision                 => null
            , p_serial_number            => null
            , p_to_serial_number         => null
            , p_quantity                 => L_WIP_COMPLETE_QTY
            , p_uom                      => l_primary_uom_code
            , p_source_id                => null
            , p_source_line_id           => null
            , p_transaction_type_id      => 32
            , p_account_id               => null
            , p_transfer_to_subinventory => null
            , p_transfer_to_locator      => null
            , p_transfer_to_organization => null
            , p_online_process_flag      => TRUE
            , p_transaction_source_id    => null
            , p_trx_source_line_id       => null
            , p_transaction_source_name  => CSP_REPAIR_PO_HEADERS_rec.repair_po_header_id ||'REPAIR_PO_MISC_ISSUE'
            , p_waybill_airbill  	     => null
            , p_shipment_number          => null
            , p_freight_code		     => null
            , p_reason_id		     => null
            , p_transaction_reference    => CSP_REPAIR_PO_HEADERS_rec.repair_po_header_id
            , p_expected_delivery_date   => null
            , x_return_status            => l_return_status
            , x_msg_count                => l_msg_count
            , x_msg_data                 => l_msg_data
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS and nvl(l_msg_count, 0) > 0 THEN
                -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                Add_Err_Msg;
                g_retcode   := 1;
                errbuf      := l_msg_Data;
                ROLLBACK TO RUN_REPAIR_EXECUTION_PVT;
            End if;

            /** FINAL_COMPLETION_FLAG = 'Y' => Repair PO is Closed, WIP_JOB is Complete and ready to close
                FINAL_COMPLETION_FLAG = 'N' => Repair PO is not Closed, WIP_JOB is still open in released status_type
            **/

            UPDATE CSP_REPAIR_PO_HEADERS
            SET received_qty = nvl(received_qty,0)+L_WIP_COMPLETE_QTY,
            STATUS = decode(FINAL_COMPLETION_FLAG,'Y',9,8)
            WHERE ROWID = CSP_REPAIR_PO_HEADERS_rec.ROWID;
          --WHERE CURRENT OF C_CSP_REPAIR_PO_HEADERS;

            COMMIT; /* Do this commit if it is not exits the loop */
           --End if;

         End if;
       End loop;
    End loop;

--COMMIT;
---- End: Step7 ----

---- Start Scrap/Adjustment ----
/** WIP_ENTITY_TYPE should be '1', If it is '3' then show "WIP_NO_CHARGES_ALLOWED" error
    This transaction is for WIP job qty scrap
    Do "Return Components from WIP" (43) transaction and wip job qty is returned from WIP JOB to Repair Supplier Org's Defect subinv

    Passing 'Y' for FINAL_COMPLETION_FLAG is not completing the WIP JOB automatically,
    So we need to insert record to WIP_JOB_SCHEDULE_INTERFACE with status_type as 'COMPLETE' VALUE 4.
    Then run the WIP_MASS_LOAD Concurrent program to change the JOB status to "COMPLETE".

    Do Miscellaneous transaction or SCRAP/ADJUSTMENT transaction from defective subinv

    Call REP_PO_SCRAP_ADJUST_TRANSACT(); ----> SCRAP/ADJUSTMENT transaction
**/

        IF FND_API.to_Boolean(l_commit) THEN
            COMMIT WORK;
        END IF;

        /** Standard call to get message count and if count is 1, get message info. **/
        FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count,
                                  p_data    =>  x_msg_data
                                  );
        /** Errbuf returns error messages and
            Retcode returns 0 = Success, 1 = Success with warnings, 2 = Error
        **/

        errbuf := X_Msg_Data;
        retcode := g_retcode;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            Add_Err_Msg;
            retcode := 2;
            errbuf := X_Msg_Data;

            JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME           => L_API_NAME
            ,P_PKG_NAME           => G_PKG_NAME
            ,P_EXCEPTION_LEVEL    => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE       => JTF_PLSQL_API.G_PVT
            ,P_ROLLBACK_FLAG      => l_Rollback
            ,X_MSG_COUNT          => X_MSG_COUNT
            ,X_MSG_DATA           => X_MSG_DATA
            ,X_RETURN_STATUS      => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            Add_Err_Msg;
            retcode := 2;
            errbuf := X_Msg_Data;

            JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME         => L_API_NAME
            ,P_PKG_NAME         => G_PKG_NAME
            ,P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE     => JTF_PLSQL_API.G_PUB
      	    ,P_ROLLBACK_FLAG    => l_Rollback
            ,X_MSG_COUNT        => X_MSG_COUNT
            ,X_MSG_DATA         => X_MSG_DATA
            ,X_RETURN_STATUS    => X_RETURN_STATUS);

            Add_Err_Msg;

        WHEN OTHERS THEN
            Rollback to RUN_REPAIR_EXECUTION_PVT;

            l_sqlcode := SQLCODE;
            l_sqlerrm := SQLERRM;
    	    retcode   := 2;
     	    errbuf    := SQLERRM;

    	    fnd_message.set_name ('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            fnd_message.set_token('ROUTINE', l_api_name, TRUE);
    	    fnd_message.set_token('SQLERRM', l_sqlcode || ': ' || l_sqlerrm, TRUE);
    	    fnd_msg_pub.add;
    	    Add_Err_Msg;

            JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME              => L_API_NAME
            ,P_PKG_NAME             => G_PKG_NAME
            ,P_EXCEPTION_LEVEL      => JTF_PLSQL_API.G_EXC_OTHERS
            ,P_PACKAGE_TYPE         => JTF_PLSQL_API.G_PVT
        	,P_SQLCODE		        => l_sqlcode
        	,P_SQLERRM 	            => l_sqlerrm
        	,P_ROLLBACK_FLAG        => l_Rollback
            ,X_MSG_COUNT            => X_MSG_COUNT
            ,X_MSG_DATA             => X_MSG_DATA
            ,X_RETURN_STATUS        => X_RETURN_STATUS);

            errbuf := sqlerrm;
            retcode := 2;
            Add_Err_Msg;
    END RUN_REPAIR_EXECUTION;


/** REPAIR_PO SCRAP/ADJUSTMENT TRANSACTION **/

    PROCEDURE REP_PO_SCRAP_ADJUST_TRANSACT
        (p_Api_Version_Number       IN  NUMBER
        ,p_Init_Msg_List            IN  VARCHAR2     := FND_API.G_FALSE
        ,p_commit                   IN  VARCHAR2     := FND_API.G_FALSE
        ,p_REPAIR_PO_HEADER_ID      IN  NUMBER
        ,p_SCRAP_ADJUST_FLAG        IN  VARCHAR2
    	,p_SCRAP_ADJUST_ITEM_ID     IN  NUMBER
        ,p_SCRAP_ADJUST_QTY         IN  NUMBER
        ,p_SCRAP_ADJUST_DATE        IN  DATE
        ,x_return_status            OUT NOCOPY VARCHAR2
        ,x_msg_count                OUT NOCOPY NUMBER
        ,x_msg_data                 OUT NOCOPY VARCHAR2
        ) IS

        CURSOR CSP_REPAIR_PO_SCRAP(L_REPAIR_PO_HEADER_ID    NUMBER,
                                   L_SCRAP_ADJUST_ITEM_ID          NUMBER,
                                   L_QUANTITY               NUMBER
                                  ) IS
        SELECT  CRPH.repair_po_header_id,
                CRPH.wip_id,
                CRPH.inventory_item_id,
                CRPH.repair_supplier_org_id,
                CRPH.quantity,
                CRPH.received_qty,
                CRPL.inventory_item_id defect_item_id,
                CRPL.defective_organization_id,
                CRPL.quantity defect_qty,
                CRPL.received_qty defect_received_qty,
                CRPL.SCRAP_QTY,
                CRPL.ADJUSTED_QTY
        FROM CSP_REPAIR_PO_HEADERS CRPH, CSP_REPAIR_PO_LINES CRPL
        WHERE CRPH.REPAIR_PO_HEADER_ID  = L_REPAIR_PO_HEADER_ID
          AND CRPH.status               = 8 --> WIP_JOB created in WIP_ENTITIES table
          AND CRPH.repair_po_header_id  = CRPL.repair_po_header_id
          AND CRPL.inventory_item_id    = L_SCRAP_ADJUST_ITEM_ID;

        l_api_version_number    CONSTANT NUMBER         := 1.0;
        l_api_name              CONSTANT VARCHAR2(20)   := 'REPAIR_PO_SCRAP';

        l_return_status         VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_Rollback              VARCHAR2(1)             := 'Y';

        l_today                 DATE;
        l_user_id               NUMBER;
        l_login_id              NUMBER;

        L_REPAIR_PO_HEADER_ID   NUMBER;
        L_SCRAP_ADJUST_FLAG     VARCHAR2(240);
        L_SCRAP_ADJUST_ITEM_ID         NUMBER;
        L_SCRAP_ADJUST_QTY             NUMBER;

        Balance_due_qty         NUMBER;
        Available_scrap_qty     NUMBER;

        x_item_number           VARCHAR2(40);
        x_item_description      VARCHAR2(240);
        l_primary_uom_code      VARCHAR2(3);
        l_org_name              VARCHAR2(240);

        EXCP_USER_DEFINED       EXCEPTION;

        l_WIP_BATCH_ID              NUMBER;
        l_defective_subinv          VARCHAR2(240);
        l_total_scrap_adjust_qty    NUMBER;
        FINAL_COMPLETION_FLAG       VARCHAR2(1);
        l_sqlcode                   NUMBER;
        l_sqlerrm                   VARCHAR2(2000);

        px_transaction_header_id    NUMBER;
        t_transaction_id            NUMBER;
        l_transaction_type_id       NUMBER;
        l_wip_status_type		NUMBER;

    BEGIN
    ---- Start Scrap / Adjustment ----

    /**
    In CSP_TRANSACTIONS_PUB.TRANSACT_MATERIAL procedure,
    Insert into mtl_transactions_interface table's WIP_ENTITY_TYPE column value must be '1',
    if it is '3' then show "WIP_NO_CHARGES_ALLOWED" error.

    This transaction is for WIP_JOB quantity Scrap/Adjustment

    WIP_JOB qty is returned from WIP JOB to Repair Supplier Org's Defect subinv
    by doing material transaction of type "Return Components from WIP" (43)

    Passing 'Y' for FINAL_COMPLETION_FLAG is not completing the WIP JOB automatically,
    So we need to insert record to WIP_JOB_SCHEDULE_INTERFACE with status_type as 'COMPLETE' VALUE 4.
    Then run the WIP_MASS_LOAD Concurrent program to change the JOB status to "COMPLETE".

    Do Miscellaneous issue transaction or SCRAP/ADJUSTMENT transaction from
    Repair Supplier Org's defective subinv for the scrap qty
    **/

    SAVEPOINT REPAIR_PO_SCRAP_PVT;

    /** Standard call to check for call compatibility **/
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /** Initialize message list **/
    IF fnd_api.to_boolean(P_Init_Msg_List) THEN
       FND_MSG_PUB.initialize;
    END IF;

    /** Initialize return status **/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /** User and login information **/
    SELECT Sysdate INTO l_today FROM dual;
    l_user_id   :=  fnd_global.user_id;
    l_login_id  := fnd_global.login_id;

    L_REPAIR_PO_HEADER_ID   := P_REPAIR_PO_HEADER_ID;
    L_SCRAP_ADJUST_ITEM_ID  := P_SCRAP_ADJUST_ITEM_ID;
    L_SCRAP_ADJUST_QTY      := P_SCRAP_ADJUST_QTY;
    L_SCRAP_ADJUST_FLAG     := p_SCRAP_ADJUST_FLAG;

    FOR CSP_REPAIR_PO_SCRAP_rec IN CSP_REPAIR_PO_SCRAP(L_REPAIR_PO_HEADER_ID, L_SCRAP_ADJUST_ITEM_ID, L_SCRAP_ADJUST_QTY)
    LOOP
        Balance_due_qty := nvl(CSP_REPAIR_PO_SCRAP_rec.quantity,0) - nvl(CSP_REPAIR_PO_SCRAP_rec.received_qty,0);
        Available_scrap_qty := nvl(CSP_REPAIR_PO_SCRAP_rec.defect_received_qty,0) -
                                   (nvl(CSP_REPAIR_PO_SCRAP_rec.scrap_qty,0) + nvl(CSP_REPAIR_PO_SCRAP_rec.adjusted_qty,0));

        CSP_REPAIR_PO_GRP.GET_ITEM_DETAILS
                    (CSP_REPAIR_PO_SCRAP_rec.repair_supplier_org_id
                    ,L_SCRAP_ADJUST_ITEM_ID
                    ,x_item_number
                    ,x_item_description
                    ,l_primary_uom_code
                    ,x_return_status
                    ,x_msg_data
                    ,x_msg_count
                    );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            L_ORG_NAME := CSP_REPAIR_PO_GRP.GET_ORGANIZATION_NAME(CSP_REPAIR_PO_SCRAP_rec.repair_supplier_org_id);
            FND_MESSAGE.SET_NAME ('CSP','CSP_NO_DEFECTITEM_AT_REPAIRORG');
            FND_MESSAGE.SET_TOKEN ('REPAIR_SUPPLIER_ORG_NAME', L_ORG_NAME,TRUE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        END IF;

        If nvl(L_SCRAP_ADJUST_QTY,0) > least(Balance_due_qty,Available_scrap_qty) then
            FND_MESSAGE.SET_NAME ('CSP','CSP_NOAVAIL_QTY_TO_SCRAP_ADJUST'); /* Not enough quantity to do scrap or adjustment transaction from WIP job*/
            FND_MESSAGE.SET_TOKEN ('ITEM_NUMBER', X_ITEM_NUMBER,TRUE);
            FND_MSG_PUB.ADD;
            RAISE EXCP_USER_DEFINED;
        Else
            l_defective_subinv := FND_PROFILE.value(NAME => 'CSP_REPAIR_SUP_ORG_DEFECT_SUBINV');

            Select sum(nvl(scrap_qty,0) + nvl(adjusted_qty,0))
            into l_total_scrap_adjust_qty
            from CSP_REPAIR_PO_LINES
            where REPAIR_PO_HEADER_ID = L_REPAIR_PO_HEADER_ID
            group by REPAIR_PO_HEADER_ID;

            If NVL(CSP_REPAIR_PO_SCRAP_rec.received_qty,0) = CSP_REPAIR_PO_SCRAP_rec.quantity - (L_SCRAP_ADJUST_QTY + l_total_scrap_adjust_qty) then
                FINAL_COMPLETION_FLAG := 'Y';
		    l_wip_status_type := 4;
            Else
                FINAL_COMPLETION_FLAG := 'N';
            End if;

            /** Do material transaction of type Return Components from WIP (43)
                i.e WIP_JOB qty is returned from WIP JOB to Repair Supplier Org's Defect subinv
            **/

            csp_transactions_pub.transact_material
                    ( p_api_version              => 1.0
                    , p_init_msg_list            => FND_API.G_FALSE
                    , p_commit                   => FND_API.G_FALSE
                    , px_transaction_header_id   => px_transaction_header_id
                    , px_transaction_id          => t_transaction_id
                    , p_inventory_item_id        => CSP_REPAIR_PO_SCRAP_rec.defect_item_id
                    , p_organization_id          => CSP_REPAIR_PO_SCRAP_rec.repair_supplier_org_id
                    , p_subinventory_code        => l_defective_subinv
                    , p_locator_id               => null
                    , p_lot_number               => null
                    , p_lot_expiration_date      => null
                    , p_revision                 => null
                    , p_serial_number            => null
                    , p_to_serial_number         => null
                    , p_quantity                 => L_SCRAP_ADJUST_QTY
                    , p_uom                      => l_primary_uom_code
                    , p_source_id                => null
                    , p_source_line_id           => null
                    , p_transaction_type_id      => 43
                    , p_account_id               => null
                    , p_transfer_to_subinventory => null
                    , p_transfer_to_locator      => null
                    , p_transfer_to_organization => null
                    , p_online_process_flag 	 => TRUE
                    , p_transaction_source_id    => CSP_REPAIR_PO_SCRAP_rec.wip_id
                    , p_trx_source_line_id       => null
                    , p_transaction_source_name	 => CSP_REPAIR_PO_SCRAP_rec.repair_po_header_id ||'REPAIR_PO_WIP_RETURN'
                    , p_waybill_airbill		     => null
                    , p_shipment_number          => null
                    , p_freight_code		     => null
                    , p_reason_id			     => null
                    , p_transaction_reference    => CSP_REPAIR_PO_SCRAP_rec.repair_po_header_id
                    , p_expected_delivery_date   => null
                    , p_FINAL_COMPLETION_FLAG    => FINAL_COMPLETION_FLAG -- May need to add this parameter for wip return
                    , x_return_status            => l_return_status
                    , x_msg_count                => l_msg_count
                    , x_msg_data                 => l_msg_data
                    );

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS and l_msg_count <> 0 THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    End if;

            /**
            After WIP_JOB qty is returned from WIP JOB to Repair Supplier Org's Defect subinv
            by doing material transaction of type "Return Components from WIP" (43),

            Do "MISCELLANEOUS ISSUE": 32 transaction (or)
            SCRAP transaction (WIP assembly scrap: 90) (or)
            Adjustment transaction : ??????? from
            Repair Supplier Org's defective subinv for the scrap qty
            **/
            If L_SCRAP_ADJUST_FLAG = 'SCRAP' then
               l_transaction_type_id := 32; --90;
            elsif L_SCRAP_ADJUST_FLAG = 'ADJUSTMENT' then
               l_transaction_type_id := 32;
            End if;

            csp_transactions_pub.transact_material
            ( p_api_version              => 1.0
            , p_init_msg_list            => FND_API.G_FALSE
            , p_commit                   => FND_API.G_FALSE
            , px_transaction_header_id   => px_transaction_header_id
            , px_transaction_id          => t_transaction_id
            , p_inventory_item_id        => CSP_REPAIR_PO_SCRAP_rec.defect_item_id
            , p_organization_id          => CSP_REPAIR_PO_SCRAP_rec.repair_supplier_org_id
            , p_subinventory_code        => l_defective_subinv
            , p_locator_id               => null
            , p_lot_number               => null
            , p_lot_expiration_date      => NULL
            , p_revision                 => null
            , p_serial_number            => null
            , p_to_serial_number         => null
            , p_quantity                 => L_SCRAP_ADJUST_QTY
            , p_uom                      => l_primary_uom_code
            , p_source_id                => null
            , p_source_line_id           => null
            , p_transaction_type_id      => l_transaction_type_id
            , p_account_id               => null
            , p_transfer_to_subinventory => null
            , p_transfer_to_locator      => null
            , p_transfer_to_organization => null
            , p_online_process_flag 	 => TRUE
            , p_transaction_source_id    => null
            , p_trx_source_line_id       => null
            , p_transaction_source_name	 => CSP_REPAIR_PO_SCRAP_rec.repair_po_header_id ||'REP_PO_'||L_SCRAP_ADJUST_FLAG||'_MISC'
            , p_waybill_airbill		     => null
            , p_shipment_number          => null
            , p_freight_code		     => null
            , p_reason_id			     => null
            , p_transaction_reference    => CSP_REPAIR_PO_SCRAP_rec.repair_po_header_id
            , p_expected_delivery_date   => null
            , x_return_status            => l_return_status
            , x_msg_count                => l_msg_count
            , x_msg_data                 => l_msg_data
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            End if;

            /** FINAL_COMPLETION_FLAG = 'Y' => Repair PO is Closed, WIP_JOB is Complete and ready to close
                FINAL_COMPLETION_FLAG = 'N' => Repair PO is not Closed, WIP_JOB is still open in released status_type
            **/

            /**
            1.We can do this insert (only) if FINAL_COMPLETION_FLAG= 'Y'
            i.e CSP_REPAIR_PO_SCRAP_rec.received_qty = CSP_REPAIR_PO_HEADERS_rec.quantity - (L_SCRAP_ADJUST_QTY + l_total_scrap_adjust_qty)
            But This Insert may not be needed if FINAL_COMPLETION_FLAG is passed as 'Y' in the above call

            2.If we do this insert then we could use the WIP api to update the WIP_JOB instead of using WIP_MASS_LOAD program form
            3.If possible try to update quantity_scrapped column with l_scrap_quanity value instead of updating QUANTITY_COMPLETED column.
            **/
---------------End comment on NOV-29-2005 --------
/*
            select WIP_JOB_SCHEDULE_INTERFACE_S.nextval
            into l_WIP_BATCH_ID
            from dual;

            Begin
            INSERT INTO WIP_JOB_SCHEDULE_INTERFACE
                (
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                GROUP_ID,
                SOURCE_CODE,
                SOURCE_LINE_ID,
                PROCESS_PHASE,
                PROCESS_STATUS,
                ORGANIZATION_ID,
                LOAD_TYPE,
                PRIMARY_ITEM_ID,
                START_QUANTITY,
                STATUS_TYPE,
                --FIRST_UNIT_START_DATE,
                --FIRST_UNIT_COMPLETION_DATE,
                --LAST_UNIT_START_DATE,
                --LAST_UNIT_COMPLETION_DATE,
                CLASS_CODE,
                WIP_ENTITY_ID,
                JOB_NAME
                )
            SELECT
               SYSDATE,
               l_user_id,
               SYSDATE,
               l_user_id,
               l_WIP_BATCH_ID,
               SOURCE_CODE,
               SOURCE_LINE_ID,
               decode(FINAL_COMPLETION_FLAG,'Y',4,2), --> 2 Validation, 4 Completion
               decode(FINAL_COMPLETION_FLAG,'Y',4,1), --> 1 Pending, 4 Complete
               ORGANIZATION_ID,
               3,                                    --> Load type: 4 Create non-standard wip job, 3 Update non-standard wip job
               PRIMARY_ITEM_ID,
               START_QUANTITY - L_SCRAP_ADJUST_QTY, --> reducing the WIP_JOB qty to (repair_po_qty - scrap or adjustment qty)
               decode(FINAL_COMPLETION_FLAG,'Y',4,3), --> Status type: 3 Released, 4 Complete
               --FIRST_UNIT_START_DATE,
               --FIRST_UNIT_COMPLETION_DATE,
               --LAST_UNIT_START_DATE,
               --LAST_UNIT_COMPLETION_DATE,
               CLASS_CODE,
               CSP_REPAIR_PO_SCRAP_rec.WIP_ID,     --> Pass existing Wip_Entity_Id for update job status to "Complete"
               'REPAIR_EXECUTION'||CSP_REPAIR_PO_SCRAP_rec.WIP_ID --> Pass existing job name(WIP_ENTITY_NAME) for update job status to "Complete"
               FROM WIP_DISCRETE_JOBS
               WHERE WIP_ENTITY_ID = CSP_REPAIR_PO_SCRAP_rec.WIP_ID;
            Exception
                When others then
                /*
                FND_MESSAGE.SET_NAME ('CSP','CSP_INSERT_WIPJOB_ERROR');
                FND_MESSAGE.SET_TOKEN ('WIP_ID',CSP_REPAIR_PO_SCRAP_rec.WIP_ID ,TRUE);
                FND_MSG_PUB.ADD;
                RAISE EXCP_USER_DEFINED;
                */
/*
                l_sqlcode := SQLCODE;
                l_sqlerrm := SQLERRM;
            	fnd_message.set_name ('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
                fnd_message.set_token('ROUTINE', l_api_name, TRUE);
            	fnd_message.set_token('SQLERRM', l_sqlcode || ': ' || l_sqlerrm, TRUE);
            	fnd_msg_pub.add;
                RAISE EXCP_USER_DEFINED;
            End;
---------------End comment on NOV-29-2005 --------
*/

            ------------**  Need to check whether this works or not **-------------

            If L_SCRAP_ADJUST_FLAG = 'SCRAP' then

                /** If possible update WIP_DISCRETE_JOBS directly for scrap transaction**/
                Update WIP_DISCRETE_JOBS
                set QUANTITY_SCRAPPED = nvl(QUANTITY_SCRAPPED,0) + L_SCRAP_ADJUST_QTY,
                LAST_UPDATE_DATE = SYSDATE, STATUS_TYPE = nvl(l_wip_status_type,STATUS_TYPE),
                DATE_COMPLETED = DECODE(FINAL_COMPLETION_FLAG,'Y',SYSDATE,DATE_COMPLETED)
                Where WIP_ENTITY_ID = CSP_REPAIR_PO_SCRAP_rec.WIP_ID;

            Elsif L_SCRAP_ADJUST_FLAG = 'ADJUSTMENT' then

                /** If possible update WIP_DISCRETE_JOBS directly for adjustment transaction**/
                Update WIP_DISCRETE_JOBS
                set QUANTITY_SCRAPPED = nvl(QUANTITY_SCRAPPED,0) + L_SCRAP_ADJUST_QTY,
                    --QUANTITY_COMPLETED = nvl(QUANTITY_COMPLETED,0) + L_SCRAP_ADJUST_QTY,
                LAST_UPDATE_DATE = SYSDATE, STATUS_TYPE = nvl(l_wip_status_type,STATUS_TYPE),
                DATE_COMPLETED = DECODE(FINAL_COMPLETION_FLAG,'Y',SYSDATE,DATE_COMPLETED)
                Where WIP_ENTITY_ID = CSP_REPAIR_PO_SCRAP_rec.WIP_ID;

            End if;
            -------------------------------------------------------------------------

            /** Status 9 = Repair po is closed, 8 = Repair po is not closed and has a open WIP_JOB **/
            UPDATE CSP_REPAIR_PO_HEADERS
            SET STATUS = decode(FINAL_COMPLETION_FLAG,'Y',9,8)
            WHERE REPAIR_PO_HEADER_ID = L_REPAIR_PO_HEADER_ID;

            If L_SCRAP_ADJUST_FLAG = 'SCRAP' then

                UPDATE CSP_REPAIR_PO_LINES
                SET scrap_qty = nvl(scrap_qty,0) + L_SCRAP_ADJUST_QTY
                ,SCRAP_DATE = nvl(p_SCRAP_ADJUST_DATE,sysdate)
                WHERE REPAIR_PO_HEADER_ID = L_REPAIR_PO_HEADER_ID
                AND inventory_item_id = L_SCRAP_ADJUST_ITEM_ID;

            Elsif L_SCRAP_ADJUST_FLAG = 'ADJUSTMENT' then

                UPDATE CSP_REPAIR_PO_LINES
                SET adjusted_qty = nvl(adjusted_qty,0) + L_SCRAP_ADJUST_QTY
                ,ADJUSTMENT_DATE = nvl(p_SCRAP_ADJUST_DATE,sysdate)
                WHERE REPAIR_PO_HEADER_ID = L_REPAIR_PO_HEADER_ID
                AND inventory_item_id = L_SCRAP_ADJUST_ITEM_ID;

            End if;

         End if;
      End loop;

      IF FND_API.to_Boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      x_return_status :=  l_return_status;

      /** Standard call to get message count and if count is 1, get message info */
      FND_MSG_PUB.Count_And_Get
        (p_count    =>  x_msg_count,
        p_data      =>  x_msg_data
        );

        /**
        G_RET_STS_SUCCESS means that the API was successful in performing all the operation requested by its caller.
        G_RET_STS_ERROR means that the API failed to perform one or more of the operations requested by its caller.
        G_RET_STS_UNEXP_ERROR means that the API was not able to perform any of the operations requested by its callers because of an unexpected error.

        G_RET_STS_SUCCESS   	CONSTANT    VARCHAR2(1)	:=  'S';
        G_RET_STS_ERROR	      	CONSTANT    VARCHAR2(1)	:=  'E';
        G_RET_STS_UNEXP_ERROR  	CONSTANT    VARCHAR2(1)	:=  'U';
        **/

    EXCEPTION
        WHEN EXCP_USER_DEFINED THEN
            Rollback to REPAIR_PO_SCRAP_PVT;

            /** This returns 'E' as status **/
            x_return_status := FND_API.G_RET_STS_ERROR;

            fnd_msg_pub.count_and_get
            (p_count => x_msg_count
            ,p_data  => x_msg_data);

        WHEN FND_API.G_EXC_ERROR THEN
            /** This returns 'E' as status **/

            JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME         => L_API_NAME
            ,P_PKG_NAME         => G_PKG_NAME
            ,P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE     => JTF_PLSQL_API.G_PVT
        	,P_ROLLBACK_FLAG    => l_Rollback
            ,X_MSG_COUNT        => X_MSG_COUNT
            ,X_MSG_DATA         => X_MSG_DATA
            ,X_RETURN_STATUS    => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            /** This returns 'U' as status **/

            JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME         => L_API_NAME
            ,P_PKG_NAME         => G_PKG_NAME
            ,P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE     => JTF_PLSQL_API.G_PVT
        	,P_ROLLBACK_FLAG    => l_Rollback
            ,X_MSG_COUNT        => X_MSG_COUNT
            ,X_MSG_DATA         => X_MSG_DATA
            ,X_RETURN_STATUS    => X_RETURN_STATUS);

        WHEN OTHERS THEN
            Rollback to REPAIR_PO_SCRAP_PVT;

            FND_MESSAGE.SET_NAME('CSP', 'CSP_UNEXPECTED_EXEC_ERRORS');
            FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
            FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, l_api_name);

            fnd_msg_pub.count_and_get
            (p_count => x_msg_count
            ,p_data => x_msg_data);

            /** This returns 'U' as status **/
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END REP_PO_SCRAP_ADJUST_TRANSACT;

END CSP_REPAIR_PO_PVT;

/
