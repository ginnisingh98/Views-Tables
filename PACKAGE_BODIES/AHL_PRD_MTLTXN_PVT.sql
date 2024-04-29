--------------------------------------------------------
--  DDL for Package Body AHL_PRD_MTLTXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_MTLTXN_PVT" AS
/* $Header: AHLVMTXB.pls 120.28.12010000.8 2010/03/15 12:18:05 pdoki ship $ */

G_DEBUG                                 VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;
G_PKG_NAME                  CONSTANT    VARCHAR2(30) := 'AHL_PRD_MTLTXN_PVT';
G_AHL_PRD_RECEPIENT                     VARCHAR2(30) := FND_PROFILE.VALUE('AHL_PRD_MTX_RECEPIENT');

-- pdoki added for Bug 9164678
G_LEVEL_PROCEDURE  CONSTANT NUMBER  := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT  CONSTANT NUMBER  := FND_LOG.LEVEL_STATEMENT;
G_CURRENT_RUNTIME_LEVEL NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

-- Hard coded string used in this proc
-- These are the profile names used to populate service request record default values

C_AHL_DEF_SR_TYPE           CONSTANT    VARCHAR2(30) := 'AHL_DEFAULT_SR_TYPE';
C_AHL_DEF_TASK_EST_DURATION CONSTANT    VARCHAR2(40) := 'AHL_DEFAULT_TASK_EST_DURATION';

--- LOOKUP Tpye for problem code values
C_REQUEST_PROBLEM_CODE      CONSTANT    VARCHAR2(30) := 'REQUEST_PROBLEM_CODE';

--ITEM Params
C_NO_SERIAL_CONTROL         CONSTANT    NUMBER := 1;
C_NO_LOT_CONTROL            CONSTANT    NUMBER := 1;
C_NO_LOCATOR_CONTROL        CONSTANT    NUMBER := 1;
C_SUBINV_LOCATOR            CONSTANT    NUMBER := 4;
C_ITEM_LOCATOR              CONSTANT    NUMBER := 5;
C_JOB_RELEASED              CONSTANT    VARCHAR2(30) := '3';
C_JOB_COMPLETE              CONSTANT    VARCHAR2(30) := '4';
C_JOB_PENDING_QA            CONSTANT    VARCHAR2(30) := '20';
C_JOB_PARTS_HOLD            CONSTANT    VARCHAR2(30) := '19';

-- Declare the private procedures.
FUNCTION IS_ITEM_TRACKABLE(p_Org_Id IN NUMBER, p_Item_Id IN NUMBER) RETURN BOOLEAN;

--PROCEDURE SHOW_MTX_ERRORS;

PROCEDURE Insert_Mtl_Txn_Row
        (
        p_x_ahl_mtltxn_rec              IN  OUT   NOCOPY  Ahl_Mtltxn_Rec_Type,
        p_material_Transaction_Id       IN             NUMBER,
        p_nonroutine_workorder_Id       IN             NUMBER,
        p_prim_uom_qty                  IN         NUMBER:=0,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2,
        x_ahl_mtl_txn_id                OUT NOCOPY     NUMBER
        );

PROCEDURE Insert_Sch_Mtl_Row
        (
        p_mtl_txn_Rec        IN                   Ahl_Mtltxn_Rec_Type,
    x_return_status      OUT NOCOPY           VARCHAR2,
    x_msg_count          OUT NOCOPY           NUMBER,
    x_msg_data           OUT NOCOPY           VARCHAR2,
        x_ahl_sch_mtl_id     OUT NOCOPY           NUMBER
        );
PROCEDURE Populate_Srvc_Rec(
        p_item_instance_id    NUMBER,
        p_srvc_rec OUT NOCOPY AHL_PRD_NONROUTINE_PVT.Sr_task_Rec_type,
        p_x_ahl_mtltxn_rec IN Ahl_Mtltxn_Rec_Type);

-- Added p_eam_item_type_id for FP ER#6310766.
PROCEDURE INSERT_MTL_TXN_INTF
    (
        p_x_ahl_mtl_txn_rec     IN OUT NOCOPY   AHL_MTLTXN_REC_TYPE,
        p_eam_item_type_id      IN              NUMBER,
        p_x_txn_hdr_id          IN  OUT NOCOPY      NUMBER,
        p_x_txn_intf_id         IN  OUT NOCOPY      NUMBER,
        p_reservation_flag      IN                  VARCHAR2,
        x_return_status         OUT NOCOPY      VARCHAR2

    );
procedure dumpInput(p_x_ahl_mtltxn_tbl  IN      AHL_MTLTXN_TBL_TYPE);

-- R12: Serial Reservation enhancements.
-- Added procedure to relieve reservation when user is issuing a reserved serial
-- number against a different workorder.
PROCEDURE Relieve_Serial_Reservation(p_ahl_mtl_txn_rec  IN            AHL_MTLTXN_REC_TYPE,
                                     x_reservation_flag IN OUT NOCOPY VARCHAR2,
                                     x_return_status    IN OUT NOCOPY VARCHAR2
                                    );

-- Added for pre/post user hooks(FP bug# 5903207).
PROCEDURE Perform_MtlTxn_Pre( p_x_ahl_mtltxn_tbl   IN OUT NOCOPY AHL_MTLTXN_TBL_TYPE,
                              x_msg_count          IN OUT NOCOPY NUMBER,
                              x_msg_data           IN OUT NOCOPY VARCHAR2,
                              x_return_status      IN OUT NOCOPY VARCHAR2);


PROCEDURE Perform_MtlTxn_Post( p_ahl_mtltxn_tbl   IN AHL_MTLTXN_TBL_TYPE,
                               x_msg_count        IN OUT NOCOPY NUMBER,
                               x_msg_data         IN OUT NOCOPY VARCHAR2,
                               x_return_status    IN OUT NOCOPY VARCHAR2);

-- Added for FP ER 6447935.
-- breakup input locator concatenated segments to populate MTI.
PROCEDURE Get_MTL_LocatorSegs (p_concat_segs     IN VARCHAR2,
                               p_organization_id IN NUMBER,
                               p_x_mti_seglist   IN OUT NOCOPY fnd_flex_ext.SegmentArray,
                               x_return_status      OUT NOCOPY VARCHAR2);


--Declare any types used by the procedure
TYPE TXN_INTF_ID_TBL    IS TABLE OF NUMBER index by BINARY_INTEGER;
TYPE INSTANCE_ID_TBL    IS TABLE OF NUMBER index by BINARY_INTEGER;
TYPE ITEM_TYPE_TBL      IS TABLE OF NUMBER index by BINARY_INTEGER;
TYPE SR_MTL_ID_MAP_TBL  IS TABLE OF NUMBER index by BINARY_INTEGER;

--------------------------------------------------------------------
-- PROCEDURE
--    Convert_Name_To_Id
--
-- PURPOSE
--    Converts Name to ID
--------------------------------------------------------------------
PROCEDURE Convert_Name_To_Id(
     p_x_ahl_mtltxn_rec         IN OUT NOCOPY       Ahl_Mtltxn_Rec_Type,
     p_module_type                 IN  VARCHAR2 := NULL,
     x_return_status               OUT NOCOPY VARCHAR2)
   IS

-- Query for validating item segments  and  selecting item id
    CURSOR Item_Cur(p_org_id number, p_item_name varchar2) IS
        SELECT Inventory_Item_Id
        FROM MTL_SYSTEM_ITEMS_KFV
        WHERE Concatenated_Segments = p_item_name
        AND Organization_Id = p_org_id
        AND ENABLED_FLAG = 'Y'
        AND ((START_DATE_ACTIVE IS NULL) OR (START_DATE_ACTIVE <= SYSDATE))
        AND ((END_DATE_ACTIVE IS NULL) OR (END_DATE_ACTIVE >= SYSDATE));

    -- Query for validating location segments and selecting location_id
    /*CURSOR Location_Cur(p_org_id number, p_location_name varchar2) IS
        SELECT INVENTORY_LOCATION_ID
        FROM MTL_ITEM_LOCATIONS_KFV
        WHERE ORGANIZATION_ID = p_org_Id
        AND CONCATENATED_SEGMENTS = p_location_name
        AND ((START_DATE_ACTIVE IS NULL) OR (START_DATE_ACTIVE <= SYSDATE))
        AND ((END_DATE_ACTIVE IS NULL) OR (END_DATE_ACTIVE >= SYSDATE));*/
    -- fix for bug number 5903275
    -- modified to retrieve segment19 and 20 from base table to fix bug# 6611033.
    CURSOR Location_Cur(p_org_id number, p_location_name varchar2) IS
        SELECT MIL.INVENTORY_LOCATION_ID, MIL_kfv.CONCATENATED_SEGMENTS
        FROM MTL_ITEM_LOCATIONS_KFV MIL_kfv, MTL_ITEM_LOCATIONS MIL
        WHERE MIL_kfv.INVENTORY_LOCATION_ID = MIL.INVENTORY_LOCATION_ID
        AND MIL.ORGANIZATION_ID = p_org_Id
        AND upper(decode(MIL.segment19, null, MIL_kfv.concatenated_segments,
            INV_PROJECT.GET_LOCSEGS(MIL_kfv.concatenated_segments) || fnd_flex_ext.get_delimiter('INV', 'MTLL',  101)
            || INV_ProjectLocator_PUB.get_project_number(MIL.segment19) || fnd_flex_ext.get_delimiter('INV', 'MTLL',  101)
            || INV_ProjectLocator_PUB.get_task_number(MIL.segment20))) = upper(p_location_name)
        AND ((MIL.START_DATE_ACTIVE IS NULL) OR (MIL.START_DATE_ACTIVE <= SYSDATE))
        AND ((MIL.END_DATE_ACTIVE IS NULL) OR (MIL.END_DATE_ACTIVE >= SYSDATE));

    l_locator_segments 	VARCHAR2(240);

--Query for validating reason name and selecting reason id.
    CURSOR Reason_Cur(p_reason_Name varchar2) IS
        SELECT REASON_ID
        FROM MTL_TRANSACTION_REASONS
        WHERE REASON_NAME = p_reason_Name
        AND (DISABLE_DATE IS NULL OR DISABLE_DATE > SYSDATE);

-- Query for validating Transaction_Type_NAme and selecting Transaction_Type_Id
    CURSOR Transaction_Type_Cur(p_Transaction_Type_name varchar2) IS
        SELECT Transaction_Type_Id
        FROM MTL_TRANSACTION_TYPES
        WHERE TRANSACTION_TYPE_NAME = p_Transaction_Type_Name
        AND (DISABLE_DATE IS NULL OR DISABLE_DATE > SYSDATE);

-- Query for Selcting Problem_Code
    CURSOR Fnd_Lookups_Cur(p_Lookup_Meaning varchar2) IS
        SELECT LOOKUP_CODE
        FROM FND_LOOKUP_VALUES_VL
        WHERE MEANING =  p_Lookup_Meaning
        AND LOOKUP_TYPE = C_REQUEST_PROBLEM_CODE
        AND ENABLED_FLAG = 'Y'
        AND ((START_DATE_ACTIVE IS NULL) OR (START_DATE_ACTIVE <= SYSDATE))
        AND ((END_DATE_ACTIVE IS NULL) OR (END_DATE_ACTIVE >= SYSDATE));
-- Cursor for Selecting UOM from UOM description.
    CURSOR Uom_Cur(p_Uom_Desc varchar2) IS
        SELECT UOM_CODE
        FROM MTL_UNITS_OF_MEASURE
        WHERE UNIT_OF_MEASURE =  p_Uom_Desc;
-- Cursor for Wip job id.
    CURSOR WIP_JOB_ID_CUR(p_wo_id NUMBER) IS
        SELECT A.WIP_ENTITY_ID, C.ORGANIZATION_ID
        FROM AHL_WORKORDERS A, AHL_VISIT_TASKS_B B, AHL_VISITS_B C
        WHERE A.WORKORDER_ID =  p_wo_id
        AND B.VISIT_TASK_ID = A.VISIT_TASK_ID
        AND C.VISIT_ID = B.VISIT_ID;
-- Cursor for Work order operation id.
    CURSOR WO_OP_CUR(p_wo_id NUMBER, p_oper_seq NUMBER) IS
        SELECT WORKORDER_OPERATION_ID
        FROM AHL_WORKORDER_OPERATIONS
        WHERE WORKORDER_ID =  p_wo_id
        AND OPERATION_SEQUENCE_NUM = p_oper_seq;
-- query for converting condition desc
   CURSOR CONDITION_CUR (p_condition_desc VARCHAR2) IS
          SELECT STATUS_ID
          FROM MTL_MATERIAL_STATUSES
          WHERE STATUS_CODE= RTRIM(LTRIM(p_condition_desc))
          AND ENABLED_FLAG = 1;
-- query for converting Employee/Recepient to employee_id
   CURSOR RECEPIENT_CUR (p_recepient_name VARCHAR2) IS
                  SELECT PERSON_ID
                  FROM PER_PEOPLE_F
                  WHERE FULL_NAME = p_recepient_name
                  AND SYSDATE BETWEEN NVL(EFFECTIVE_START_DATE,SYSDATE) AND
                  NVL(EFFECTIVE_END_DATE,SYSDATE);

-- query for converting Employee/Recepient to employee_id
   CURSOR DEFAULT_USER_CUR
   IS
   SELECT  A.employee_id
   FROM FND_USER A
   WHERE USER_ID=FND_GLOBAL.USER_ID;

-- Query for Disposition..

   CURSOR DISPOSITION_CUR(C_WORKORDER_ID NUMBER,C_DISP_ID  NUMBER)
   IS
/* Tamal [R12 APPSPERF fixes]
 * R12 Drop 4 - SQL ID: 14399309
 * Bug #4918991
 */
SELECT DISPOSITION_ID
FROM AHL_PRD_DISPOSITIONS_B A
WHERE
    A.WORKORDER_ID = C_WORKORDER_ID AND
    A.DISPOSITION_ID = C_DISP_ID;

-- Query based on workorder name.
-- Need to strip by OU.
   CURSOR WORKORDER_CUR(C_WORKORDER_NAME IN VARCHAR2)
   IS
/* Tamal [R12 APPSPERF fixes]
 * R12 Drop 4 - SQL ID: 14399329
 * Bug #4918991
 */
SELECT
    A.JOB_NUMBER,
    A.WORKORDER_ID,
    A.ORGANIZATION_ID,
    A.ORGANIZATION_NAME,
    A.JOB_STATUS_CODE,
    A.JOB_STATUS_MEANING,
    A.WIP_ENTITY_ID
FROM
    AHL_SEARCH_WORKORDERS_V A
    --AHL_VISITS_B V,
    --AHL_VISIT_TASKS_B VT,
    --INV_ORGANIZATION_NAME_V ORG,
    --FND_LOOKUP_VALUES WO_STS
WHERE
    A.JOB_NUMBER = C_WORKORDER_NAME
    AND A.JOB_STATUS_CODE NOT IN ('17', '22');
    --AND A.MASTER_WORKORDER_FLAG = 'N'
    --AND A.VISIT_TASK_ID = VT.VISIT_TASK_ID
    --AND VT.VISIT_ID = V.VISIT_ID
    --AND V.ORGANIZATION_ID = ORG.ORGANIZATION_ID
    --AND WO_STS.LOOKUP_TYPE = 'AHL_JOB_STATUS'
    --AND WO_STS.LANGUAGE = USERENV('LANG')
    --AND WO_STS.LOOKUP_CODE = A.STATUS_CODE;

-- Query based on workorder ID.
-- Added for public api support.
   CURSOR WORKORDER_ID_CUR(C_WORKORDER_ID IN VARCHAR2)
   IS
   SELECT A.job_number,
          A.workorder_id,
          A.organization_id,
          A.Organization_name,
          A.JOB_STATUS_CODE,
          A.job_status_meaning,
          A.wip_entity_id
   FROM AHL_SEARCH_WORKORDERS_V A
   WHERE A.workorder_id=C_WORKORDER_ID;

   L_WORKDET_REC    WORKORDER_CUR%ROWTYPE;
   L_WORKDET_ID_REC WORKORDER_ID_CUR%ROWTYPE;

   l_recepient_id NUMBER;
BEGIN

        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Get the vlaues for Entity ID from Workorders table
        -- and workorder operation id from workorder_operations table for the given work
        -- order id and Operation seq number
        -- ?????????

    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Convert_Name_To_Id');
    END IF;

    IF ( (p_x_ahl_mtltxn_rec.Workorder_Id IS NULL
      OR  p_x_ahl_mtltxn_rec.Workorder_Id = FND_API.G_MISS_NUM)) THEN

        IF (p_x_ahl_mtltxn_rec.WORKORDER_NAME IS NOT NULL AND
           p_x_ahl_mtltxn_rec.WORKORDER_NAME <> FND_API.G_MISS_CHAR)
        THEN

          OPEN    WORKORDER_CUR(p_x_ahl_mtltxn_rec.WORKORDER_NAME);
          FETCH   WORKORDER_CUR INTO L_WORKDET_REC;
          IF  WORKORDER_CUR%NOTFOUND
          THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_WORKORDER');
            FND_MESSAGE.Set_Token('WORKORDER',p_x_ahl_mtltxn_rec.Workorder_name);
            FND_MSG_PUB.ADD;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
           -- fix for re-open issue in bug# 6773241
          ELSIF L_WORKDET_REC.JOB_STATUS_CODE<>'3' AND
               --L_WORKDET_REC.JOB_STATUS_CODE<>'19' AND
               L_WORKDET_REC.JOB_STATUS_CODE<>'20' AND
               --L_WORKDET_REC.JOB_STATUS_CODE<>'6' AND
               L_WORKDET_REC.JOB_STATUS_CODE<>'4' THEN
               FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_JOB_STATUS');
               FND_MESSAGE.Set_Token('STATUS',L_WORKDET_REC.job_status_meaning);
               FND_MSG_PUB.ADD;
               x_return_status := Fnd_Api.G_RET_STS_ERROR;
          ELSE
            p_x_ahl_mtltxn_rec.Workorder_Id                     :=L_WORKDET_REC.WORKORDER_ID;
            p_x_ahl_mtltxn_rec.Workorder_Status                 :=L_WORKDET_REC.JOB_STATUS_MEANING;
            p_x_ahl_mtltxn_rec.Workorder_Status_Code            :=L_WORKDET_REC.JOB_STATUS_CODE;
            p_x_ahl_mtltxn_rec.Organization_Id                  :=L_WORKDET_REC.ORGANIZATION_ID;
            p_x_ahl_mtltxn_rec.Wip_Entity_Id                    :=L_WORKDET_REC.WIP_ENTITY_ID;
          END IF; -- WORKORDER_CUR%NOTFOUND
          CLOSE   WORKORDER_CUR;
        ELSE -- both Workorder_Id and WORKORDER_NAME are NULLs
           FND_MESSAGE.Set_Name('AHL','AHL_PRD_NULL_WORKORDER_ID');
           FND_MSG_PUB.ADD;
           x_return_status := Fnd_Api.G_RET_STS_ERROR;
        END IF; -- p_x_ahl_mtltxn_rec.WORKORDER_NAME
    ELSE -- workorderId is not null.
        OPEN WORKORDER_ID_CUR(p_x_ahl_mtltxn_rec.Workorder_Id);
        FETCH WORKORDER_ID_CUR INTO L_WORKDET_ID_REC;
        IF WORKORDER_ID_CUR%NOTFOUND
        THEN
           FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_WORKORDER');
           FND_MESSAGE.Set_Token('WORKORDER',p_x_ahl_mtltxn_rec.Workorder_Id);
           FND_MSG_PUB.ADD;
           x_return_status := Fnd_Api.G_RET_STS_ERROR;
        -- fix for re-open issue in bug# 6773241
        ELSIF L_WORKDET_ID_REC.JOB_STATUS_CODE<>'3' AND  -- Released
              --L_WORKDET_ID_REC.JOB_STATUS_CODE<>'19' AND -- Parts Hold
              L_WORKDET_ID_REC.JOB_STATUS_CODE<>'20' AND -- pending deferral
              --L_WORKDET_ID_REC.JOB_STATUS_CODE<>'6' AND  -- on hold
              L_WORKDET_ID_REC.JOB_STATUS_CODE<>'4'      -- complete
        THEN
           FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_JOB_STATUS');
           FND_MESSAGE.Set_Token('STATUS',L_WORKDET_ID_REC.job_status_meaning);
           FND_MSG_PUB.ADD;
           x_return_status := Fnd_Api.G_RET_STS_ERROR;
        ELSE
           p_x_ahl_mtltxn_rec.Workorder_Id  := L_WORKDET_ID_REC.WORKORDER_ID;
           p_x_ahl_mtltxn_rec.Workorder_Status := L_WORKDET_ID_REC.JOB_STATUS_MEANING;
           p_x_ahl_mtltxn_rec.Workorder_Status_Code := L_WORKDET_ID_REC.JOB_STATUS_CODE;
           p_x_ahl_mtltxn_rec.Organization_Id := L_WORKDET_ID_REC.ORGANIZATION_ID;
           p_x_ahl_mtltxn_rec.Wip_Entity_Id :=L_WORKDET_ID_REC.WIP_ENTITY_ID;
        END IF; -- WORKORDER_ID_CUR%NOTFOUND
        CLOSE   WORKORDER_ID_CUR;
    END IF; -- p_x_ahl_mtltxn_tbl(i).Workorder_Id

    -- Check for operation sequence number.
    IF ( p_x_ahl_mtltxn_rec.Operation_Seq_num IS NULL
         OR  p_x_ahl_mtltxn_rec.Operation_Seq_num = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_PRD_NULL_OPER_SEQ');
          FND_MSG_PUB.ADD;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
    END IF;

    -- Check for errors.
    IF (x_return_status = Fnd_Api.G_RET_STS_ERROR)
    THEN
       RETURN; -- do not proceed for the rest of the validations.
    END IF;

    IF (p_x_ahl_mtltxn_rec.Wip_Entity_Id IS NULL
    OR p_x_ahl_mtltxn_rec.Wip_Entity_Id = FND_API.G_MISS_NUM) THEN
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Getting WipEntity for['||p_x_ahl_mtltxn_rec.Workorder_Id||']');
        END IF;
        OPEN WIP_JOB_ID_CUR(p_x_ahl_mtltxn_rec.Workorder_Id);
        FETCH WIP_JOB_ID_CUR INTO p_x_ahl_mtltxn_rec.Wip_Entity_Id,p_x_ahl_mtltxn_rec.Organization_Id ;
        IF(WIP_JOB_ID_CUR%NOTFOUND) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_WIP_ENTITY_WO');
            FND_MESSAGE.Set_Token('WORKORDER',p_x_ahl_mtltxn_rec.Workorder_Id);
            FND_MSG_PUB.ADD;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
        END IF;
        CLOSE WIP_JOB_ID_CUR;
    END IF;



    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('after the Wip entity select['||p_x_ahl_mtltxn_rec.Wip_Entity_Id||','||p_x_ahl_mtltxn_rec.Organization_Id||']');

    END IF;


    IF (p_x_ahl_mtltxn_rec.Workorder_Operation_Id IS NULL
    OR p_x_ahl_mtltxn_rec.Workorder_Operation_Id = FND_API.G_MISS_NUM) THEN
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('selecting woopid for['||p_x_ahl_mtltxn_rec.Workorder_Id||','||p_x_ahl_mtltxn_rec.Operation_Seq_num||']');

    END IF;
        OPEN WO_OP_CUR(p_x_ahl_mtltxn_rec.Workorder_Id,
                        p_x_ahl_mtltxn_rec.Operation_Seq_num);
        FETCH WO_OP_CUR INTO p_x_ahl_mtltxn_rec.Workorder_Operation_Id ;
        IF(WO_OP_CUR%NOTFOUND) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_WO_OP');
            FND_MESSAGE.Set_Token('WORKORDER',p_x_ahl_mtltxn_rec.Workorder_Id);
            FND_MESSAGE.Set_Token('OP_SEQUENCE',p_x_ahl_mtltxn_rec.Operation_Seq_num);
            FND_MSG_PUB.ADD;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
        END IF;
        CLOSE WO_OP_CUR;
    END IF;
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('after the woop id select');
    END IF;

      --Convert Transaction Type Name into Transaction Type Id
    IF (p_x_ahl_mtltxn_rec.Transaction_Type_Id IS NULL
    OR p_x_ahl_mtltxn_rec.Transaction_Type_Id = FND_API.G_MISS_NUM) THEN
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Converting Txn type name['||p_x_ahl_mtltxn_rec.Transaction_Type_Name||']');
        END IF;
        IF (p_x_ahl_mtltxn_rec.Transaction_Type_Name IS  NULL
           OR p_x_ahl_mtltxn_rec.Transaction_Type_Name = FND_API.G_MISS_CHAR) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_NULL_TXN_TYPE');
            FND_MSG_PUB.ADD;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
        ELSE
            OPEN Transaction_Type_Cur(p_x_ahl_mtltxn_rec.Transaction_Type_Name);
            FETCH Transaction_Type_Cur INTO p_x_ahl_mtltxn_rec.Transaction_Type_Id ;
            IF(Transaction_Type_Cur%NOTFOUND) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_TXN_TYPE');
                FND_MESSAGE.Set_Token('TXN_TYPE',p_x_ahl_mtltxn_rec.Transaction_Type_Name);
                FND_MSG_PUB.ADD;
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
            END IF;
            CLOSE Transaction_Type_Cur;
        END IF;
    END IF;
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('after the txn type select');
    END IF;

      -- Convert item segments into item id
      IF (p_x_ahl_mtltxn_rec.Inventory_Item_Id IS NULL OR p_x_ahl_mtltxn_rec.Inventory_Item_Id = FND_API.G_MISS_NUM) THEN
         IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Converting item for['||to_char(p_x_ahl_mtltxn_rec.Organization_Id)||','||p_x_ahl_mtltxn_rec.Inventory_Item_Segments||']');
        END IF;

        IF (p_x_ahl_mtltxn_rec.Inventory_Item_Segments IS NULL
            OR p_x_ahl_mtltxn_rec.Inventory_Item_Segments = FND_API.G_MISS_CHAR) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_NULL_ITEM');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
         ELSE
            OPEN Item_Cur(p_x_ahl_mtltxn_rec.Organization_Id,
                        p_x_ahl_mtltxn_rec.Inventory_Item_Segments);
            FETCH Item_Cur INTO p_x_ahl_mtltxn_rec.Inventory_Item_Id ;
            IF(Item_Cur%NOTFOUND) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_COM_INVALID_ITEM');
                FND_MESSAGE.Set_Token('FIELD',p_x_ahl_mtltxn_rec.Inventory_Item_Segments);
                FND_MSG_PUB.ADD;
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
            END IF;
            CLOSE Item_Cur;
          END IF;

      END IF;
    IF G_DEBUG='Y'
    THEN
          AHL_DEBUG_PUB.debug('after the item id select:'||to_char(p_x_ahl_mtltxn_rec.Inventory_Item_Id)||'.');
    END IF;

      -- Convert Locator segments into locator id when item is locator controlled.
      IF (p_x_ahl_mtltxn_rec.Locator_Id IS NULL
            OR p_x_ahl_mtltxn_rec.Locator_Id = FND_API.G_MISS_NUM) THEN
         IF (p_x_ahl_mtltxn_rec.Locator_Segments IS NOT NULL
            AND p_x_ahl_mtltxn_rec.Locator_Segments <> FND_API.G_MISS_CHAR) THEN
            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('Converting locator['||to_char(p_x_ahl_mtltxn_rec.Organization_Id)||','||p_x_ahl_mtltxn_rec.Locator_Segments||']');
            END IF;
            OPEN Location_Cur(p_x_ahl_mtltxn_rec.Organization_Id,
                              p_x_ahl_mtltxn_rec.Locator_Segments);
            FETCH Location_Cur INTO p_x_ahl_mtltxn_rec.Locator_Id,l_locator_segments  ;--Fix for bug number 5903275
            -- ER 5854712 (if locator not found, it will be created.)
            /*
            IF(Location_Cur%NOTFOUND)
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_LOCATION');
                FND_MESSAGE.Set_Token('LOCATOR',p_x_ahl_mtltxn_rec.Locator_Segments);
                FND_MSG_PUB.ADD;
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ELSE
            */
            IF (Location_Cur%FOUND) THEN
              p_x_ahl_mtltxn_rec.Locator_Segments := l_locator_segments;--Fix for bug number 5903275
              IF G_DEBUG='Y' THEN
                 AHL_DEBUG_PUB.debug('Converted locator['||to_char(p_x_ahl_mtltxn_rec.Organization_Id)||','||p_x_ahl_mtltxn_rec.Locator_Segments||']');
              END IF;
            END IF;
            CLOSE Location_Cur;
        END IF;

      END IF;
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('after the locator  select');
    END IF;

      -- convert reason name into reason id.
      IF (p_x_ahl_mtltxn_rec.Reason_Id IS NULL OR p_x_ahl_mtltxn_rec.Reason_Id = FND_API.G_MISS_NUM)
      THEN
         IF (p_x_ahl_mtltxn_rec.Reason_Name IS NOT NULL
         AND p_x_ahl_mtltxn_rec.Reason_Name <> FND_API.G_MISS_CHAR)
         THEN
            IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug('Converting reason name'||p_x_ahl_mtltxn_rec.Reason_Name||']');
            END IF;
             OPEN Reason_Cur(p_x_ahl_mtltxn_rec.Reason_Name);
             FETCH Reason_Cur INTO p_x_ahl_mtltxn_rec.Reason_Id ;
             IF(Reason_Cur%NOTFOUND) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_REASON');
                FND_MESSAGE.Set_Token('REASON',p_x_ahl_mtltxn_rec.Reason_Name);
                FND_MSG_PUB.ADD;
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
             END IF;
             CLOSE Reason_Cur;
        END IF;

      END IF;

    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('after the reason name select');
    END IF;


      --Convert Problem_code_Meaning to Problem_code incase of returns

      IF (p_x_ahl_mtltxn_rec.Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE) THEN
        IF (p_x_ahl_mtltxn_rec.Problem_Code IS NULL
                OR p_x_ahl_mtltxn_rec.Problem_Code = FND_API.G_MISS_CHAR) THEN
             IF (p_x_ahl_mtltxn_rec.Problem_Code_Meaning IS NOT NULL
                AND p_x_ahl_mtltxn_rec.Problem_Code_Meaning <> FND_API.G_MISS_CHAR) THEN
                 IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Converting Problem code['||p_x_ahl_mtltxn_rec.Problem_Code_Meaning||']');

    END IF;
                 OPEN Fnd_Lookups_Cur(p_x_ahl_mtltxn_rec.Problem_Code_Meaning);
                 FETCH Fnd_Lookups_Cur INTO p_x_ahl_mtltxn_rec.Problem_Code ;
                 IF(Fnd_Lookups_Cur%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PROBLEM_CODE_INVALID');
                    FND_MESSAGE.Set_Token('CODE',p_x_ahl_mtltxn_rec.Problem_Code_Meaning);
                    FND_MSG_PUB.ADD;
                    x_return_status := Fnd_Api.G_RET_STS_ERROR;
                 END IF;
                 CLOSE Fnd_Lookups_Cur;
            END IF;
        END IF;
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('after problem code select');
        END IF;
        IF (p_x_ahl_mtltxn_rec.Condition_Desc IS NOT NULL
        AND  p_x_ahl_mtltxn_rec.Condition_Desc <> FND_API.G_MISS_CHAR)
        THEN
                IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('Getting Condition for['||p_x_ahl_mtltxn_rec.Condition_Desc||']');
                END IF;
            OPEN CONDITION_CUR(p_x_ahl_mtltxn_rec.Condition_Desc);
            FETCH CONDITION_CUR INTO p_x_ahl_mtltxn_rec.Condition;

            IF(CONDITION_CUR%NOTFOUND) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_COND_INVALID');
                FND_MESSAGE.Set_Token('CODE',p_x_ahl_mtltxn_rec.Condition_Desc);
                FND_MSG_PUB.ADD;
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
            END IF;

            CLOSE CONDITION_CUR;
        END IF;


        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('after the CONDITION select['||p_x_ahl_mtltxn_rec.CONDITION||']');
        END IF;

      END IF;

    IF (p_module_type = 'JSP') THEN

        -- nullify id and retrive id from name entered.
        p_x_ahl_mtltxn_rec.RECEPIENT_ID := NULL;

        IF (p_x_ahl_mtltxn_rec.recepient_name IS NOT NULL AND  p_x_ahl_mtltxn_rec.recepient_name <> FND_API.G_MISS_CHAR)
        THEN
            OPEN RECEPIENT_CUR(p_x_ahl_mtltxn_rec.RECEPIENT_NAME);
            FETCH RECEPIENT_CUR INTO p_x_ahl_mtltxn_rec.RECEPIENT_ID;
            IF(RECEPIENT_CUR%NOTFOUND)
            THEN
                IF (p_x_ahl_mtltxn_rec.Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTX_PERSON_INVALID2');
                ELSE
                    FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTX_PERSON_INVALID');
                END IF;
                FND_MESSAGE.Set_Token('RECEPIENT',p_x_ahl_mtltxn_rec.RECEPIENT_NAME);
                FND_MSG_PUB.ADD;
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
            END IF;
            CLOSE RECEPIENT_CUR;
        END IF;

    ELSE
        --if backend call.
        IF (p_x_ahl_mtltxn_rec.recepient_name IS NOT NULL AND p_x_ahl_mtltxn_rec.recepient_name <> FND_API.G_MISS_CHAR)
        THEN
            -- if name is availave retrive id from name
            OPEN RECEPIENT_CUR(p_x_ahl_mtltxn_rec.RECEPIENT_NAME);
            FETCH RECEPIENT_CUR INTO l_recepient_id;
            IF(RECEPIENT_CUR%NOTFOUND)
            THEN
                IF (p_x_ahl_mtltxn_rec.Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTX_PERSON_INVALID2');
                ELSE
                    FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTX_PERSON_INVALID');
                END IF;
                FND_MESSAGE.Set_Token('RECEPIENT',p_x_ahl_mtltxn_rec.RECEPIENT_NAME);
                FND_MSG_PUB.ADD;
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ELSE
                -- if id is available then see if this id is the same as the one retrived from the name.
                IF(p_x_ahl_mtltxn_rec.recepient_id IS NOT NULL AND p_x_ahl_mtltxn_rec.recepient_id <> FND_API.G_MISS_NUM)
                THEN
                    IF(l_recepient_id <> p_x_ahl_mtltxn_rec.RECEPIENT_ID)
                    THEN
                        IF (p_x_ahl_mtltxn_rec.Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE)
                        THEN
                            FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTX_PERSON_INVALID2');
                        ELSE
                            FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTX_PERSON_INVALID');
                        END IF;
                        FND_MESSAGE.Set_Token('RECEPIENT',p_x_ahl_mtltxn_rec.RECEPIENT_NAME);
                        FND_MSG_PUB.ADD;
                        x_return_status := Fnd_Api.G_RET_STS_ERROR;
                    END IF;
                ELSE
                    -- if id is not available then populate the id with the id retrived.
                    p_x_ahl_mtltxn_rec.recepient_id:=l_recepient_id;
                END IF;
            END IF;
            CLOSE RECEPIENT_CUR;
        END IF;
    END IF;

    IF(p_x_ahl_mtltxn_rec.recepient_id IS NULL OR p_x_ahl_mtltxn_rec.recepient_id = FND_API.G_MISS_NUM)
    THEN
        IF(NVL(FND_PROFILE.VALUE('AHL_PRD_MTX_RECEPIENT'),'N')='Y')
        THEN
            IF (p_x_ahl_mtltxn_rec.Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE)
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTX_PERSON_MANDATORY2');
            ELSE
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTX_PERSON_MANDATORY');
            END IF;
            FND_MSG_PUB.ADD;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
        ELSE
            OPEN  DEFAULT_USER_CUR;
            FETCH DEFAULT_USER_CUR INTO p_x_ahl_mtltxn_rec.RECEPIENT_ID;
            IF DEFAULT_USER_CUR%NOTFOUND
            THEN
                IF (p_x_ahl_mtltxn_rec.Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTX_PERSON_INVALID2');
                ELSE
                    FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTX_PERSON_INVALID');
                END IF;
                FND_MESSAGE.Set_Token('RECEPIENT',p_x_ahl_mtltxn_rec.RECEPIENT_NAME);
                FND_MSG_PUB.ADD;
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
            END IF;
            CLOSE DEFAULT_USER_CUR;
        END IF;
    END IF;

      --Convert UOM DESC into UOM
      IF (p_x_ahl_mtltxn_rec.Uom IS NULL
            OR p_x_ahl_mtltxn_rec.Uom = FND_API.G_MISS_CHAR) THEN
         IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Converting UOM['||p_x_ahl_mtltxn_rec.Uom_Desc||']');

    END IF;
         IF (p_x_ahl_mtltxn_rec.Uom_Desc IS NULL
            OR p_x_ahl_mtltxn_rec.Uom_Desc = FND_API.G_MISS_CHAR) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_NULL_UOM');
                FND_MSG_PUB.ADD;
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
         ELSE
             OPEN Uom_Cur(p_x_ahl_mtltxn_rec.Uom_Desc);
             FETCH Uom_Cur INTO p_x_ahl_mtltxn_rec.Uom ;
             IF(Uom_Cur%NOTFOUND) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_UOM');
                FND_MESSAGE.Set_Token('UOM',p_x_ahl_mtltxn_rec.Uom_Desc);
                FND_MSG_PUB.ADD;
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
             END IF;
             CLOSE Uom_Cur;
        END IF;

      END IF;
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('after UOM select');

    END IF;
EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := Fnd_Api.G_RET_STS_ERROR;

END Convert_Name_To_Id;




/***********************************************************************/


/***********************************************************************/

PROCEDURE PERFORM_MTL_TXN
(
    p_api_version        IN            NUMBER     := 1.0,
    p_init_msg_list      IN            VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_default            IN            VARCHAR2   := FND_API.G_FALSE,
    p_module_type        IN            VARCHAR2   := NULL,
    p_create_sr          IN            VARCHAR2,
    p_x_ahl_mtltxn_tbl   IN OUT NOCOPY Ahl_Mtltxn_Tbl_Type,
    x_return_status      OUT NOCOPY           VARCHAR2,
    x_msg_count          OUT NOCOPY           NUMBER,
    x_msg_data           OUT NOCOPY           VARCHAR2
)
    IS
    l_api_name              CONSTANT VARCHAR2(30) := 'PERFORM_MTL_TXN';
    l_api_version           CONSTANT NUMBER       := 1.0;
    --l_count               NUMBER;
    l_x_Mtl_Txn_id          NUMBER;
    l_sch_Mtl_Id            NUMBER;
    l_Txn_Header_Id         NUMBER;
    l_Txn_tmp_Id            NUMBER;
    l_x_sr_rec_tbl          AHL_PRD_NONROUTINE_PVT.Sr_task_tbl_type;
    l_Txn_Id_Tbl            TXN_INTF_ID_TBL;
    l_instance_id_tbl       INSTANCE_ID_TBL;
    l_eam_item_type_id_tbl  ITEM_TYPE_TBL;
    l_timeout               NUMBER;
    l_outcome               BOOLEAN;
    l_error_msg             varchar2(240);
    l_error_code            varchar2(240);
    l_error                 BOOLEAN;
    l_nonrtn_wo_id          NUMBER;
    l_item_instance_id      NUMBER;
    l_eam_item_type_id      NUMBER;
    j                       INTEGER;

    l_completed_quantity             NUMBER;
    l_object_version_number          NUMBER;
    l_uom_code                       AHL_SCHEDULE_MATERIALS.UOM%TYPE;
    l_quantity                       NUMBER;

    l_concatenated_segments          mtl_system_items_kfv.concatenated_segments%TYPE;
    l_workorder_name                 ahl_workorders.workorder_name%TYPE;

    l_reservation_flag               VARCHAR2(1);
    l_sr_mtl_id_map_tbl              SR_MTL_ID_MAP_TBL;

    --Query to get the error message
    CURSOR Txn_Error_Cur(p_txn_Id NUMBER) IS
        SELECT intf.ERROR_EXPLANATION ,intf.ERROR_CODE, kfv.concatenated_segments,
               WO.workorder_name
        --FROM MTL_MATERIAL_TRANSACTIONS_TEMP
        FROM MTL_TRANSACTIONS_INTERFACE INTF, mtl_system_items_kfv kfv,
                     ahl_workorders WO
        --WHERE TRANSACTION_TEMP_ID = p_txn_Id;
        WHERE TRANSACTION_INTERFACE_ID = p_txn_Id
                  AND intf.inventory_item_id = kfv.inventory_item_id
                  AND intf.organization_id = kfv.organization_id
                  AND WO.wip_entity_id = intf.transaction_source_id;

    -- Query for finding the scheduled materials
    CURSOR Sch_Mtl_Cur(p_org_id NUMBER, p_workorder_Op_id NUMBER,
                       p_item_Id NUMBER) IS
        SELECT COMPLETED_QUANTITY, UOM, object_version_number
        FROM AHL_SCHEDULE_MATERIALS A
        WHERE ORGANIZATION_ID = p_org_id
        AND A.WORKORDER_OPERATION_ID =p_workorder_op_id
        AND A.INVENTORY_ITEM_ID = p_item_Id
        AND A.MATERIAL_REQUEST_TYPE <> 'FORECAST'
        --AND A.status='ACTIVE'
        --Added for FP ER# 6310725.
        AND A.status IN ('ACTIVE','HISTORY', 'IN-SERVICE')
        FOR UPDATE OF COMPLETED_QUANTITY NOWAIT;

    -- Query to check existence of AHL_SCHEDULE_MATERIALS record.
    CURSOR Sch_Mtl_Exists_Cur(p_org_id NUMBER, p_workorder_Op_id NUMBER,
                              p_item_Id NUMBER) IS
        SELECT 'x'
        FROM AHL_SCHEDULE_MATERIALS A
        WHERE ORGANIZATION_ID = p_org_id
        AND A.WORKORDER_OPERATION_ID =p_workorder_op_id
        AND A.INVENTORY_ITEM_ID = p_item_Id
        AND A.MATERIAL_REQUEST_TYPE <> 'FORECAST'
        --AND A.status='ACTIVE';
        --Added for FP ER# 6310725.
        AND A.status IN ('ACTIVE','HISTORY','IN-SERVICE');

    /* commented out as part of FP bug fix 5172147. Instead querying disposition ID in
     * procedure validate_txn_rec.

       -- Cursor to check if disposition exists for the item instance.
       CURSOR ahl_mtl_ret_disp_csr (p_item_instance_id  IN NUMBER,
                                    p_workorder_id  IN NUMBER) IS

        /* Tamal [R12 APPSPERF fixes]
         * R12 Drop 4 - SQL ID: 14399558
         * Bug #4918991
         */
        /*
        SELECT 'x'
        FROM AHL_PRD_DISPOSITIONS_B DISP, AHL_WORKORDERS WO, CSI_ITEM_INSTANCES CSI
        WHERE
            DISP.INSTANCE_ID = CSI.INSTANCE_ID AND
            DISP.WORKORDER_ID = WO.WORKORDER_ID AND
            WO.WIP_ENTITY_ID = CSI.WIP_JOB_ID AND
            CSI.LOCATION_TYPE_CODE NOT IN ('PO', 'IN-TRANSIT', 'PROJECT', 'INVENTORY') AND
            TRUNC(SYSDATE) BETWEEN TRUNC(NVL(CSI.ACTIVE_START_DATE, SYSDATE)) AND TRUNC(NVL(CSI.ACTIVE_END_DATE, SYSDATE)) AND
            DISP.INSTANCE_ID = p_item_instance_id AND
            DISP.WORKORDER_ID = p_workorder_id AND
            CSI.QUANTITY > 0;
       */

       l_junk   VARCHAR2(1);

       -- Added for FP bug# 6086419.
       l_mr_asso_tbl AHL_PRD_NONROUTINE_PVT.MR_Association_tbl_type;

       -- sracha: Added for ER 5854712.
       l_valid_flag  BOOLEAN;


    BEGIN
        -- Standard start of API savepoint
        SAVEPOINT PERFORM_MTL_TXN_PVT;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                           G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- call user hook api.
        -- User Hooks
        IF (JTF_USR_HKS.Ok_to_execute('AHL_PRD_MATERIAL_TXN_CUHK', 'PERFORM_MTLTXN_PRE', 'B', 'C')) THEN
           Perform_MtlTxn_Pre(p_x_ahl_mtltxn_tbl => p_x_ahl_mtltxn_tbl,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              x_return_status => x_return_status);
           IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        dumpInput(p_x_ahl_mtltxn_tbl);


        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;
          AHL_DEBUG_PUB.debug('Entered ahl mtl api');
        END IF;

        IF (p_x_ahl_mtltxn_tbl.COUNT > 0) THEN

            -- Validation LOOP.
            --l_Error := false;
            FOR i IN p_x_ahl_mtltxn_tbl.FIRST..p_x_ahl_mtltxn_tbl.LAST  LOOP

                IF (p_module_type = 'JSP')
                                THEN
                   -- Set all the Ids to null for which there is an LOV.
                   p_x_ahl_mtltxn_tbl(i).Inventory_Item_Id    := FND_API.G_MISS_NUM;
                   p_x_ahl_mtltxn_tbl(i).Locator_Id             := FND_API.G_MISS_NUM;
                   p_x_ahl_mtltxn_tbl(i).Reason_Id              := FND_API.G_MISS_NUM;
                   p_x_ahl_mtltxn_tbl(i).Problem_Code           := FND_API.G_MISS_CHAR;
                   --p_x_ahl_mtltxn_tbl(i).Uom                    := FND_API.G_MISS_CHAR;
                END IF;
                /*Public api changes: Moved to Convert_Name_To_Id api
                --Check the context fields
                IF ( (p_x_ahl_mtltxn_tbl(i).Workorder_Id IS NULL
                 OR  p_x_ahl_mtltxn_tbl(i).Workorder_Id = FND_API.G_MISS_NUM)) THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PRD_NULL_WORKORDER_ID');
                    FND_MSG_PUB.ADD;
                                        l_error := true;
                ELSIF ( p_x_ahl_mtltxn_tbl(i).Operation_Seq_num IS NULL
                 OR  p_x_ahl_mtltxn_tbl(i).Operation_Seq_num = FND_API.G_MISS_NUM) THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PRD_NULL_OPER_SEQ');
                    FND_MSG_PUB.ADD;
                                        l_error := true;
                ELSE
                */
                   IF G_DEBUG='Y' THEN
                       AHL_DEBUG_PUB.debug('calling Convert_Name_To_Id for i=['||i||']');
                   END IF;

                    -- This procedure will convert name parameters into IDs in the input
                    Convert_Name_To_Id(p_x_ahl_mtltxn_rec => p_x_ahl_mtltxn_tbl(i),
                                       p_module_type => p_module_type ,
                                   x_return_status  => x_return_status  );

                   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                     --l_error := true;
                     -- raise error if mandatory paramaters missing or WO-OP
                     -- validation fails.
                     RAISE FND_API.G_EXC_ERROR;

                   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;


                   IF G_DEBUG='Y' THEN
                      AHL_DEBUG_PUB.debug('calling Validate_Txn_rec for i=['||i||']');
                   END IF;

                   --Call  Validate_Txn(Ahl_Mtltxn_rec)  to validate the material txn record.
                   Validate_Txn_rec(p_x_ahl_mtltxn_rec => p_x_ahl_mtltxn_tbl(i),
                           x_item_instance_id   => l_item_instance_id,
                           x_return_status => x_Return_Status,
                           x_msg_data       => x_msg_data,
                           x_msg_count      => x_msg_Count,
                           x_eam_item_type_id => l_eam_item_type_id );

                   IF G_DEBUG='Y' THEN
                       AHL_DEBUG_PUB.debug('After calling Validate_Txn_rec');
                   END IF;

                   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                      l_error := true;

                      IF G_DEBUG='Y' THEN
                          AHL_DEBUG_PUB.debug('Error in Validation');
                      END IF;
                   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                      IF G_DEBUG='Y' THEN
                          AHL_DEBUG_PUB.debug('Unexpected error in Validate_Txn_rec');
                      END IF;
                   ELSE
                      l_instance_id_tbl(i) := l_item_instance_id;
                      l_eam_item_type_id_tbl(i) := l_eam_item_type_id;
                   END IF;
                -- END IF; -- commented out for public api changes.

            END LOOP;
            -- End of Validation LOOP
            IF (l_Error) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- Inteface table insert.
            l_txn_Header_Id := NULL;
            l_Error := false;
            FOR i IN p_x_ahl_mtltxn_tbl.FIRST..p_x_ahl_mtltxn_tbl.LAST  LOOP


                l_reservation_flag := 'N';
                IF (p_x_ahl_mtltxn_tbl(i).serial_number IS NOT NULL) THEN
                    -- Added in R12: Serial Reservation.. (to relieve reservation if serial number
                    -- is reserved against a different demand source)
                    Relieve_Serial_Reservation(p_ahl_mtl_txn_rec  => p_x_ahl_mtltxn_tbl(i),
                                               x_reservation_flag => l_reservation_flag,
                                               x_return_status => x_return_status);
                    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                        l_error := true;
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                        l_error := true;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                END IF;

                -- For an issue transaction and return transaction (bug 5499575)
                -- IF Material requlrements are not existing in the  AHL_SCHEDULE_MATERIALS
                -- then insert into the scheduled materials table with submitted status.
                OPEN Sch_Mtl_Exists_Cur(p_x_ahl_mtltxn_tbl(i).Organization_Id,
                         p_x_ahl_mtltxn_tbl(i).Workorder_operation_Id,
                         p_x_ahl_mtltxn_tbl(i).Inventory_Item_Id);
                FETCH Sch_Mtl_Exists_Cur INTO l_junk;

                If(Sch_Mtl_Exists_Cur%NOTFOUND) THEN

                          --Check if the material exists in the AHL_SCHEDULE_MATERIALS table
                          --for the given work order operation id.
                          --IF (p_x_ahl_mtltxn_tbl(i).Transaction_Type_Id = WIP_CONSTANTS.ISSCOMP_TYPE) THEN

                              Insert_Sch_Mtl_Row( p_mtl_txn_rec    => p_x_ahl_mtltxn_tbl(i),
                                                  x_return_status  => x_Return_Status,
                                                  x_msg_count      => x_Msg_Count,
                                                  x_msg_data       => x_Msg_Data,
                                                  x_ahl_sch_mtl_id => l_sch_Mtl_Id);


                              IF G_DEBUG='Y' THEN
                                  AHL_DEBUG_PUB.debug('after Sch_Mtl insert api');
                              END IF;

                              IF (x_return_status = FND_API.G_RET_STS_ERROR
                                  OR x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                                   CLOSE Sch_Mtl_Exists_Cur;
                                   FND_MESSAGE.Set_Name('AHL','AHL_PRD_SCHMTLAPI_ERROR');
                                   FND_MESSAGE.Set_Token('MSG',x_msg_data);
                                   FND_MSG_PUB.ADD;
                                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                              END IF;
                          --END IF; -- fix for bug# 5499575

                END IF;
                CLOSE Sch_Mtl_Exists_Cur;

                --call Insert_Interface_Temp API to insert data into transaction
                --temp tables. F

                IF G_DEBUG='Y' THEN
                       AHL_DEBUG_PUB.debug('Calling Insert_Txn_Intf...');
                END IF;

                -- Added l_eam_item_type_id_tbl(i) for FP ER# 6310766.
                Insert_Mtl_Txn_Intf(p_x_ahl_mtl_txn_rec  => p_x_ahl_mtltxn_tbl(i),
                        p_eam_item_type_id   => l_eam_item_type_id_tbl(i),
                        p_x_txn_Hdr_Id       => l_txn_Header_Id,
                        p_x_txn_intf_Id      => l_txn_tmp_Id,
                        p_reservation_flag   => l_reservation_flag, -- added for R12.
                        x_return_status      => x_return_status
                        );

                l_txn_Id_Tbl(i) := l_Txn_tmp_Id;
                IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('After Calling Insert_Txn_Intf...ret_status['||x_return_status||']');
                    AHL_DEBUG_PUB.debug('Ahl_mtltxn_id'||p_x_ahl_mtltxn_tbl(i).ahl_mtltxn_id);
                END IF;


                IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                      l_error := true;
                ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                      l_error := true;
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

            END LOOP; -- End of loop for Interface table inserts

            IF(l_error )       THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            -- Now process the interface records
            IF G_DEBUG='Y' THEN
                 AHL_DEBUG_PUB.debug('Before calling wip_mtlInterfaceProc_pub.processInterface....');
            END IF;

            wip_mtlInterfaceProc_pub.processInterface(
                                p_txnHdrId  => l_Txn_Header_Id,
                                x_returnStatus  => x_return_status
                                );

	    --Adithya added the following code to fix bugs 5611465 and 6962468
	      mo_global.init('AHL');

            IF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  ) THEN
              IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('wip_mtlInterfaceProc_pub.processInterface....errored');
                    AHL_DEBUG_PUB.debug('count of error msgs: ' || FND_MSG_PUB.COUNT_MSG);
              END IF;
              --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

        END IF;

        -- Now  Loop thru the transaction Id table, Check Errors and update AHL tables
        IF (l_txn_Id_Tbl.COUNT > 0) THEN

            -- This loop checks for errors. No interface record implies
            -- tha there is no error.
            l_error := false;
            FOR i IN l_txn_Id_Tbl.FIRST..l_txn_Id_Tbl.LAST  LOOP

                OPEN Txn_Error_cur(l_txn_Id_Tbl(i));
                FETCH Txn_Error_cur INTO l_error_msg,l_error_code,
                                       l_concatenated_segments, l_workorder_name;
                IF(Txn_Error_cur%FOUND AND (l_error_code IS NOT NULL
                    OR trim(l_error_code) = '')) THEN

                      IF G_DEBUG='Y' THEN
                         AHL_DEBUG_PUB.debug('Error in transaction['||l_error_msg||']');
                      END IF;

                      FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTLTXN_ERROR');
                      FND_MESSAGE.Set_Token('MSG',l_error_msg);
                      FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
                      FND_MESSAGE.Set_Token('WO_NAME',l_workorder_name);
                      FND_MSG_PUB.ADD;
                      l_error := true;
                END IF;
                CLOSE Txn_Error_cur;
            END LOOP;

            IF(l_error ) THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- No errors returned by  WIP API.Initialize message list to
            -- remove 'Txn success' message.
            IF FND_API.To_Boolean(p_init_msg_list) THEN
               FND_MSG_PUB.Initialize;
            END IF;

            FOR i IN l_txn_Id_Tbl.FIRST..l_txn_Id_Tbl.LAST  LOOP

                -- Tamal: Bug #4095376: Begin
                -- For all cases (i.e. ISSUE / RETURN + whether found in AHL_SCHEDULE_MATERIALS) do the following
                l_quantity :=  p_x_ahl_mtltxn_tbl(i).quantity;

                -- The following depends on the fact that ahl_schedule_materials records all quantities in the primary_uom_code
                -- of the item, which is the case currently as it is a requirement from WIP
                SELECT PRIMARY_UOM_CODE INTO l_uom_code
                FROM MTL_SYSTEM_ITEMS_B
                WHERE INVENTORY_ITEM_ID = p_x_ahl_mtltxn_tbl(i).Inventory_Item_Id
                AND ORGANIZATION_ID = p_x_ahl_mtltxn_tbl(i).Organization_Id;

                IF (l_uom_code <> p_x_ahl_mtltxn_tbl(i).uom)
                THEN
                    l_quantity := inv_convert.inv_um_convert
                    (
                    item_id         => p_x_ahl_mtltxn_tbl(i).Inventory_Item_Id,
                    precision       => null,
                    from_quantity   => p_x_ahl_mtltxn_tbl(i).quantity,
                    from_unit       => p_x_ahl_mtltxn_tbl(i).uom,
                    to_unit         => l_uom_code,
                    from_name       => null,
                    to_name         => null
                    );

                    IF (l_quantity < 0)
                    THEN
                       FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_UOMCONVERT_ERROR');
                       FND_MESSAGE.Set_Token('UOM_FROM', p_x_ahl_mtltxn_tbl(i).uom);
                       FND_MESSAGE.Set_Token('UOM_TO', l_uom_code);
                       FND_MSG_PUB.ADD;
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
                -- Tamal: Bug #4095376: End

                OPEN Sch_Mtl_Cur(p_x_ahl_mtltxn_tbl(i).Organization_Id,
                         p_x_ahl_mtltxn_tbl(i).Workorder_operation_Id,
                         p_x_ahl_mtltxn_tbl(i).Inventory_Item_Id);
                FETCH Sch_Mtl_Cur INTO l_completed_quantity, l_uom_code, l_object_version_number;

                If(Sch_Mtl_Cur%NOTFOUND) THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PRD_SCHMTL_NOTFOUND');
                    FND_MESSAGE.Set_Token('WO_OP',p_x_ahl_mtltxn_tbl(i).Workorder_operation_Id);
                    FND_MESSAGE.Set_Token('INV_ITEM',p_x_ahl_mtltxn_tbl(i).Inventory_Item_Id);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSE

                    IF G_DEBUG='Y' THEN
                       AHL_DEBUG_PUB.debug('l_completed_quantity=['||l_completed_quantity||']');
                    END IF;

                    -- Tamal: Bug #4095376: Begin
                    -- Retrieving quantity, then converting to primary uom, etc have been moved out of this ELSE loop
                    -- to ensure that quantity is not updated to NULL in mtl_txn rows
                    -- Tamal: Bug #4095376: End

                    -- Update Completion quantity for cMRO-APS integration.
                    IF (p_x_ahl_mtltxn_tbl(i).Transaction_Type_Id = WIP_CONSTANTS.ISSCOMP_TYPE) THEN
                    -- Issue Txn.
                        UPDATE AHL_SCHEDULE_MATERIALS
                        SET completed_quantity = nvl(completed_quantity,0) + l_quantity,
                            object_version_number = l_object_version_number + 1
                        WHERE CURRENT OF Sch_Mtl_Cur;
                    -- 11/20: Commented out updation of completed quantity to fix bug# 6598809
                    /*
                    ELSIF (p_x_ahl_mtltxn_tbl(i).Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE) THEN
                    -- Return Txn.
                        UPDATE AHL_SCHEDULE_MATERIALS
                        SET completed_quantity = nvl(completed_quantity,0) -  l_quantity,
                            object_version_number = l_object_version_number + 1
                        WHERE CURRENT OF Sch_Mtl_Cur;
                    */
                    END IF;
                END IF;
                CLOSE Sch_Mtl_Cur;


                --IF( l_x_sr_rec_tbl.COUNT > 0) THEN
                --    l_nonrtn_wo_id := l_x_sr_rec_tbl(i).Nonroutine_wo_id;
                --END IF;

                --Insert a record into the AHL_WORKORDER_MTL_TXNS.
                IF(p_x_ahl_mtltxn_tbl(i).Qa_Collection_Id = FND_API.G_MISS_NUM OR
                   p_x_ahl_mtltxn_tbl(i).disposition_id is NOT NULL) THEN
                    p_x_ahl_mtltxn_tbl(i).Qa_Collection_Id := NULL;
                END IF;
                IF(l_nonrtn_wo_id = FND_API.G_MISS_NUM) THEN
                    l_nonrtn_wo_id := NULL;
                END IF;

                IF(p_x_ahl_mtltxn_tbl(i).Locator_Id = FND_API.G_MISS_NUM) THEN
                    p_x_ahl_mtltxn_tbl(i).Locator_Id := NULL;
                END IF;

                -- In case of dynamic locator creation, retrieve locator ID to populate ahl_workorder_mtl_txns table.
                IF (p_x_ahl_mtltxn_tbl(i).locator_segments IS NOT NULL AND
                    p_x_ahl_mtltxn_tbl(i).locator_id IS NULL) THEN

                   IF G_DEBUG='Y' THEN
                     AHL_DEBUG_PUB.DEBUG('Profile mfg_organization_id:'  || fnd_profile.value('MFG_ORGANIZATION_ID') );
                   END IF;

                   l_valid_flag := fnd_flex_keyval.validate_segs(
                                       operation         => 'FIND_COMBINATION'
                                     , appl_short_name   => 'INV'
                                     , key_flex_code     => 'MTLL'
                                     , structure_number  => 101
                                     , concat_segments   => p_x_ahl_mtltxn_tbl(i).locator_segments
                                     , values_or_ids     => 'V'
                                     , data_set          => p_x_ahl_mtltxn_tbl(i).organization_id
                         );

                   IF (l_valid_flag) THEN
                       p_x_ahl_mtltxn_tbl(i).locator_id := fnd_flex_keyval.combination_id;
                   END IF;

                END IF;

                IF(p_x_ahl_mtltxn_tbl(i).condition = FND_API.G_MISS_NUM) THEN
                    p_x_ahl_mtltxn_tbl(i).condition := NULL;
                END IF;
                IF G_DEBUG='Y' THEN
                          AHL_DEBUG_PUB.debug('RECEPIENT_ID'||p_x_ahl_mtltxn_tbl(i).RECEPIENT_ID);
                END IF;

                Insert_Mtl_Txn_Row(p_x_ahl_mtltxn_rec     => p_x_ahl_mtltxn_tbl(i),
                                p_material_Transaction_Id => NULL,
                                p_nonroutine_workorder_Id => l_nonrtn_wo_id,
                                p_prim_uom_qty      =>L_QUANTITY,
                                x_return_status      => x_Return_Status,
                                x_msg_count          => x_Msg_Count,
                                x_msg_data           => x_Msg_Data,
                                x_ahl_mtl_txn_id     => l_x_Mtl_Txn_Id);


                IF G_DEBUG='Y' THEN
                          AHL_DEBUG_PUB.debug('after mtl_Txn insert api');
                          AHL_DEBUG_PUB.debug('after mtl_Txn insert api call ret status=['||x_return_status||']');
                          AHL_DEBUG_PUB.debug('after mtl_Txn insert api call msg=['||x_msg_data||']');
                END IF;


                IF (x_return_status = FND_API.G_RET_STS_ERROR
                    OR x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_PRD_AHLMTLTXN_ERROR');
                        FND_MESSAGE.Set_Token('MSG',x_msg_data);
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                p_x_ahl_mtltxn_tbl(i).ahl_mtltxn_id :=  l_x_Mtl_Txn_Id;

                   -- For trackable returns, update ahl_parts_change table for return_mtl_txn_id.
                   IF (l_instance_id_tbl(i) IS NOT NULL) AND
                      (p_x_ahl_mtltxn_tbl(i).Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE) THEN
                         AHL_PRD_PARTS_CHANGE_PVT.Update_Material_Return
                                  (
                                     p_return_mtl_txn_id  => l_x_Mtl_Txn_Id,
                                     p_workorder_id     => p_x_ahl_mtltxn_tbl(i).workorder_id,
                                     p_Item_Instance_Id  => l_instance_id_tbl(i),
                                     x_return_status  => x_return_status
                                  );

                         IF G_DEBUG='Y' THEN
                            AHL_DEBUG_PUB.debug('after PartsChange Update api');
                            AHL_DEBUG_PUB.debug('after PartsChange Update api call ret status=['||x_return_status||']');
                         END IF;

                         IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                             RAISE FND_API.G_EXC_ERROR;
                         ELSIF  (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                         END IF;

                   END IF;

            END LOOP;
        END IF;

        -- END of if which checks the count of transactions created

        IF (G_DEBUG='Y') THEN
          AHL_DEBUG_PUB.debug('Unservicable profile value:' || G_AHL_UNSERVICEABLE_CONDITION);
          AHL_DEBUG_PUB.debug('MRB profile value:' || G_AHL_MRB_CONDITION);
        END IF;

        IF (l_txn_Id_Tbl.COUNT > 0) THEN
            -- THis loop is for creating service request. Since
            -- service reques API commits, we need to do this separately.
            BEGIN
                l_error := false;
                --j:=1;
                j := l_txn_Id_Tbl.FIRST;
                FOR i IN l_txn_Id_Tbl.FIRST..l_txn_Id_Tbl.LAST  LOOP
                    IF G_DEBUG='Y' THEN
                      AHL_DEBUG_PUB.debug('Processing SR for item:' || p_x_ahl_mtltxn_tbl(i).inventory_item_id);
                      AHL_DEBUG_PUB.debug('Condition is:' || p_x_ahl_mtltxn_tbl(i).Condition);
                      AHL_DEBUG_PUB.debug('Disposition ID is:' || p_x_ahl_mtltxn_tbl(i).disposition_id);
                      AHL_DEBUG_PUB.debug('Instance ID is:' || l_instance_id_tbl(i));
                      AHL_DEBUG_PUB.debug('Create WO Option is:' || p_x_ahl_mtltxn_tbl(i).create_wo_option);

                    END IF;

                    --If (condition is unserviceable/MRB AND P_create_SR == 'Y' ) then
                    --Select EMP_ID from FND_USERS table for the FND_GLOBAL.USER_ID
                    --Call Service request API to create service request.
                    --( AHL_NONROUTINE_JOB_PVT.process_nonroutine_job)
                    IF ((p_x_ahl_mtltxn_tbl(i).Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE)
                          AND l_eam_item_type_id_tbl(i) = wip_constants.rebuild_item_type
                          AND (p_x_ahl_mtltxn_tbl(i).Condition = G_AHL_UNSERVICEABLE_CONDITION
                          OR p_x_ahl_mtltxn_tbl(i).Condition = G_AHL_MRB_CONDITION)
                          AND (p_create_sr = 'Y')
                          AND (l_instance_id_tbl(i) IS NOT NULL)
                          AND (p_x_ahl_mtltxn_tbl(i).disposition_id IS NULL)
                          -- added for FP bug# 5903318.
                          AND (p_x_ahl_mtltxn_tbl(i).create_wo_option <> 'CREATE_SR_NO')) THEN
                                populate_Srvc_Rec( p_item_instance_id => l_instance_id_tbl(i),
                                                   p_srvc_rec => l_x_sr_rec_tbl(j),
                                                   p_x_ahl_mtltxn_rec => p_x_ahl_mtltxn_tbl(i));
                                -- populate l_sr_mtl_id_map_tbl to link the mtl_txnID with the l_x_sr_rec_tbl
                                -- table index.
                                l_sr_mtl_id_map_tbl(j) := p_x_ahl_mtltxn_tbl(i).ahl_mtltxn_id;

                                j := j+1;
                    END IF;

                END LOOP;
                          -- added for FP bug# 5903318.
                IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('Will call service request API if there are srvc request to be created');
                    AHL_DEBUG_PUB.debug('srvc req rec count=['||to_Char(l_x_sr_rec_tbl.COUNT)||']');
                    AHL_DEBUG_PUB.debug('mr tbl count=['||to_Char(l_mr_asso_tbl.COUNT)||']');
                END IF;


                IF(l_x_sr_rec_tbl.COUNT > 0) THEN
                    AHL_PRD_NONROUTINE_PVT.PROCESS_NONROUTINE_JOB (
                                        p_api_version  => 1.0,
                                        p_commit       => Fnd_Api.g_false,
                                        p_module_type   => NULL,
                                        x_return_status =>x_return_status,
                                        x_msg_count     =>x_msg_count,
                                        x_msg_data      =>x_msg_data,
                                        p_x_sr_task_tbl =>l_x_sr_rec_tbl,
                                        --Parameter added for bug# 6086419.
                                        p_x_mr_asso_tbl => l_mr_asso_tbl);
                    IF G_DEBUG='Y' THEN
                        AHL_DEBUG_PUB.debug('after the srvc req api call ret status=['||x_return_status||']');
                        AHL_DEBUG_PUB.debug('after the srvc req api call x_msg_count=['||x_msg_count||']');
                        AHL_DEBUG_PUB.debug('after the srvc req api call msg=['||x_msg_data||']');
                    END IF;

                    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    -- ANd now update the nonroutine workorder id in the workorder_mtl_Txns table
                    FOR j IN l_x_sr_rec_tbl.FIRST..l_x_sr_rec_tbl.LAST LOOP
                        IF G_DEBUG='Y' THEN
                            AHL_DEBUG_PUB.debug('l_x_sr_rec_tbl.Incident_id[' || j || ']=['||l_x_sr_rec_tbl(j).Incident_id||']');
                            AHL_DEBUG_PUB.debug('l_x_sr_rec_tbl.Visit_task_id[' || j || ']=['||l_x_sr_rec_tbl(j).Visit_task_id||']');
                            AHL_DEBUG_PUB.debug('l_sr_mtl_id_map_tbl[' || j || ']=['|| l_sr_mtl_id_map_tbl(j) ||']');
                        END IF;

                        -- update non-routine workorder id.
                        UPDATE AHL_WORKORDER_MTL_TXNS
                           SET NON_ROUTINE_WORKORDER_ID = l_x_sr_rec_tbl(j).Nonroutine_wo_id,
			-- Adithya added for bug# 6995541
			       CS_INCIDENT_ID           = l_x_sr_rec_tbl(j).Incident_id
                         WHERE WORKORDER_MTL_TXN_ID = l_sr_mtl_id_map_tbl(j);
                    END LOOP; -- l_x_sr_rec_tbl.FIRST
                END IF;
            END; -- begin
        END IF; -- Second if stmt which checks the count of txns created.

        -- Fix for bug# 5501482.
        IF (p_x_ahl_mtltxn_tbl.COUNT > 0) THEN

          FOR i IN p_x_ahl_mtltxn_tbl.FIRST..p_x_ahl_mtltxn_tbl.LAST  LOOP
            IF (p_x_ahl_mtltxn_tbl(i).Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE AND
                p_x_ahl_mtltxn_tbl(i).Condition = G_AHL_MRB_CONDITION AND
                p_x_ahl_mtltxn_tbl(i).disposition_id IS NULL AND
                p_x_ahl_mtltxn_tbl(i).Qa_Collection_Id  IS NOT NULL AND FND_API.to_boolean( p_commit )) THEN
                    QA_SS_RESULTS.wrapper_fire_action
                    (
                      q_collection_id       => p_x_ahl_mtltxn_tbl(i).Qa_Collection_Id,
                      q_return_status       => x_return_status,
                      q_msg_count           => x_msg_count,
                      q_msg_data            => x_msg_data
                    );

                    IF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                       IF ( x_msg_data IS NULL ) THEN
                          FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_QA_ACTION_UNEXP_ERROR' );
                          FND_MSG_PUB.add;
                          RAISE FND_API.G_EXC_ERROR;
                       END IF;
                    ELSIF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
            END IF;
          END LOOP;
        END IF;

        -- Standard check of p_commit
        IF FND_API.To_Boolean(p_commit) THEN
            COMMIT WORK;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        dumpInput(p_x_ahl_mtltxn_tbl);

        -- call user hook api.
        -- User Hooks
        IF (JTF_USR_HKS.Ok_to_execute('AHL_PRD_MATERIAL_TXN_CUHK', 'PERFORM_MTLTXN_POST', 'A', 'C')) THEN
           Perform_MtlTxn_Post( p_ahl_mtltxn_tbl => p_x_ahl_mtltxn_tbl,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                x_return_status => x_return_status);
           IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

--
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            --SHOW_MTX_ERRORS;
            Rollback to PERFORM_MTL_TXN_PVT;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                    p_data  => x_msg_data,
                    p_encoded => fnd_api.g_false);


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            --SHOW_MTX_ERRORS;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to PERFORM_MTL_TXN_PVT;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                    p_data  => x_msg_data,
                    p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            --SHOW_MTX_ERRORS;
            Rollback to PERFORM_MTL_TXN_PVT;
            fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                    p_procedure_name => 'Perform_Mtl_txn',
                    p_error_text     => SQLERRM);
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                    p_data  => x_msg_data,
                    p_encoded => fnd_api.g_false);

END PERFORM_MTL_TXN;

/**********************************************************
This procedure will insert a record in the AHL_WO_MTL_TXNS table.
**********************************************************/

PROCEDURE Insert_Mtl_Txn_Row(
    p_x_ahl_mtltxn_rec          IN OUT NOCOPY Ahl_Mtltxn_Rec_Type,
    p_material_Transaction_Id   IN         NUMBER,
    p_nonroutine_workorder_Id   IN         NUMBER,
    p_prim_uom_qty              IN         NUMBER:=0,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2,
    x_ahl_mtl_txn_id            OUT NOCOPY         NUMBER)
IS
l_x_row_id              VARCHAR2(240);
l_quantity              NUMBER;
BEGIN

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;
          AHL_DEBUG_PUB.debug('Entered Insert_Mtl_Txn_Row, p_x_ahl_mtltxn_rec.Inventory_Item_Id='|| p_x_ahl_mtltxn_rec.Inventory_Item_Id);
          AHL_DEBUG_PUB.debug('Entered Insert_Mtl_Txn_Row, p_x_ahl_mtltxn_rec.Recepient_id='||p_x_ahl_mtltxn_rec.Recepient_id);
        END IF;
        AHL_WORKORDER_MTL_TXNS_PKG.INSERT_ROW(
                        X_ROWID                         => l_x_row_id,
                        X_WORKORDER_MTL_TXN_ID          => x_ahl_mtl_txn_id,
                        X_OBJECT_VERSION_NUMBER         => 1,
                        X_WORKORDER_OPERATION_ID        => p_x_ahl_mtltxn_rec.workorder_Operation_Id,
                        X_MATERIAL_TRANSACTION_ID       => p_material_Transaction_Id,
                        X_COLLECTION_ID                 => p_x_ahl_mtltxn_rec.Qa_Collection_Id,
                        X_STATUS_ID                     => p_x_ahl_mtltxn_rec.Condition,
                        X_NON_ROUTINE_WORKORDER_ID      => p_nonroutine_workorder_Id,
                        X_ORGANIZATION_ID               => p_x_ahl_mtltxn_rec.Organization_Id,
                        X_INVENTORY_ITEM_ID             => p_x_ahl_mtltxn_rec.Inventory_Item_Id,
                        X_REVISION                      => p_x_ahl_mtltxn_rec.Revision,
                        X_LOT_NUMBER                    => p_x_ahl_mtltxn_rec.Lot_Number,
                        X_SERIAL_NUMBER                 => p_x_ahl_mtltxn_rec.Serial_Number,
                        X_LOCATOR_ID                    => p_x_ahl_mtltxn_rec.Locator_Id,
                        X_SUBINVENTORY_CODE             => p_x_ahl_mtltxn_rec.Subinventory_Name,
                        X_QUANTITY                      => p_x_ahl_mtltxn_rec.Quantity,
                        X_TRANSACTION_TYPE_ID           => p_x_ahl_mtltxn_rec.Transaction_Type_Id,
                        X_UOM                           => p_x_ahl_mtltxn_rec.Uom,
                        X_RECEPIENT_ID                  => p_x_ahl_mtltxn_rec.Recepient_id,
                        X_PRIMARY_UOM_QUANTITY          => P_PRIM_UOM_QTY,
                        X_INSTANCE_ID                   => p_x_ahl_mtltxn_rec.Item_Instance_ID,
                        X_TRANSACTION_DATE              => p_x_ahl_mtltxn_rec.transaction_date,
                        X_ATTRIBUTE_CATEGORY            => NULL ,
                        X_ATTRIBUTE1                    => NULL ,
                        X_ATTRIBUTE2                    => NULL ,
                        X_ATTRIBUTE3                    => NULL ,
                        X_ATTRIBUTE4                    => NULL ,
                        X_ATTRIBUTE5                    => NULL ,
                        X_ATTRIBUTE6                    => NULL ,
                        X_ATTRIBUTE7                    => NULL ,
                        X_ATTRIBUTE8                    => NULL ,
                        X_ATTRIBUTE9                    => NULL ,
                        X_ATTRIBUTE10                   => NULL ,
                        X_ATTRIBUTE11                   => NULL ,
                        X_ATTRIBUTE12                   => NULL ,
                        X_ATTRIBUTE13                   => NULL ,
                        X_ATTRIBUTE14                   => NULL ,
                        X_ATTRIBUTE15                   => NULL ,
                        X_CREATION_DATE                 => SYSDATE,
                        X_CREATED_BY                    => FND_GLOBAL.USER_ID,
                        X_LAST_UPDATE_DATE              => SYSDATE,
                        X_LAST_UPDATED_BY               => FND_GLOBAL.USER_ID,
                        X_LAST_UPDATE_LOGIN             => FND_GLOBAL.LOGIN_ID);

            select AHL_WORKORDER_MTL_TXNS_S.currval into p_x_ahl_mtltxn_rec.Ahl_mtltxn_Id  from dual;
--                      p_x_ahl_mtltxn_rec.Ahl_mtltxn_Id:=x_ahl_mtl_txn_id;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Entered p_x_ahl_mtltxn_rec.Ahl_mtltxn_Id='||p_x_ahl_mtltxn_rec.Ahl_mtltxn_Id);
        END IF;

/*

EXCEPTION
WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF G_DEBUG='Y'
        THEN
          AHL_DEBUG_PUB.debug('Exception inserting into mtl_txn' || SQLCODE);
          AHL_DEBUG_PUB.debug('SQLERRM:' || SQLERRM);
        END IF;

*/
END Insert_Mtl_Txn_Row;
/*******************************************************************
This procedure will do all the validations requried for the matrial
transaction record .
*******************************************************************/


PROCEDURE Validate_item_duplic
    (
                p_ahl_mtltxn_rec       IN Ahl_Mtltxn_Rec_Type
    )
IS
CURSOR GET_WO_MTL_TXNS
(C_WRK_ID           IN  NUMBER,
 C_INV_ITEM_ID      IN  NUMBER,
 C_REVISION         IN  VARCHAR2,
 C_SERIAL_NO        IN  VARCHAR2,
 C_WO_MTLTXN_ID     IN  NUMBER
)
IS
SELECT COUNT(A.workorder_mtl_txn_id)
FROM   AHL_WORKORDER_MTL_TXNS A,
       AHL_WORKORDER_OPERATIONS_V B,
       AHL_SCHEDULE_MATERIALS  C
WHERE  B.WORKORDER_ID=C_WRK_ID
AND    B.WORKORDER_OPERATION_ID=A.WORKORDER_OPERATION_ID
AND    B.WORKORDER_OPERATION_ID=C.WORKORDER_OPERATION_ID
AND    A.INVENTORY_ITEM_ID=C.INVENTORY_ITEM_ID
AND    C.STATUS='ACTIVE'
AND    A.INVENTORY_ITEM_ID=C_INV_ITEM_ID
AND    A.SERIAL_NUMBER=C_SERIAL_NO
AND    A.REVISION=C_REVISION
AND    A.workorder_mtl_txn_id<>C_WO_MTLTXN_ID;
L_COUNTER           NUMBER:=0;
BEGIN
    OPEN  GET_WO_MTL_TXNS(p_ahl_mtltxn_rec.WORKORDER_ID,
                          p_ahl_mtltxn_rec.INVENTORY_ITEM_ID,
                          p_ahl_mtltxn_rec.REVISION,
                          p_ahl_mtltxn_rec.SERIAL_NUMBER,
                          p_ahl_mtltxn_rec.AHL_MTLTXN_ID
                          );
    FETCH GET_WO_MTL_TXNS INTO L_COUNTER;
    IF L_COUNTER >0
    THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_DUPLICATE_ITEM');
                        FND_MESSAGE.Set_Token('INV_ITEM',p_ahl_mtltxn_rec.INVENTORY_ITEM_SEGMENTS);
            FND_MSG_PUB.ADD;
    END IF;
    CLOSE GET_WO_MTL_TXNS;
END;




PROCEDURE Validate_Txn_Rec
    (
        p_x_ahl_mtltxn_rec   IN OUT NOCOPY Ahl_Mtltxn_Rec_Type,
        x_item_instance_id   OUT NOCOPY        NUMBER,
        x_eam_item_type_id   OUT NOCOPY        NUMBER,
        x_return_status      OUT NOCOPY           VARCHAR2,
        x_msg_count          OUT NOCOPY           NUMBER,
        x_msg_data           OUT NOCOPY           VARCHAR2
    )
IS
l_Count                 NUMBER;
l_sql                   VARCHAR2(1024);
l_serial_control        NUMBER;
l_revision_control      NUMBER;
l_lot_control           NUMBER;
l_location_control      NUMBER;
--l_wip_location          NUMBER;
l_job_status            VARCHAR2(30);
l_plan_id               NUMBER;
l_return_status         VARCHAR2(10);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);

l_lot_flag              BOOLEAN := FALSE;  -- indicator for lot.
l_revision_flag         BOOLEAN := FALSE;  -- indicator for revision.

--Query to get the Location_id
-- R12: Fix for bug# 5221513
-- IB team have asked us to remove the location validation to fix the issue.
/*
CURSOR CSI_LOCATION_CUR(p_org_id IN NUMBER) IS

    --SELECT WIP_LOCATION_ID
    --FROM CSI_INSTALL_PARAMETERS;

    SELECT location_id
    FROM hr_all_organization_units
    WHERE organization_id = p_org_id;
*/

--Query to validate the instance for the job
-- R12: Fix for bug# 5221513
CURSOR CSI_SER_ITEM_CUR(p_item_id IN NUMBER,
                        p_job_id IN NUMBER,
                        p_serial_num IN VARCHAR2) IS
                        --p_wip_location NUMBER) IS  (fix for bug# 5221513).
    SELECT INSTANCE_ID
    FROM CSI_ITEM_INSTANCES CII
    WHERE INVENTORY_ITEM_ID       = p_item_id
    AND WIP_JOB_ID            = p_job_id
    AND SERIAL_NUMBER         = p_serial_num
    AND ACTIVE_START_DATE     <= SYSDATE
    AND ((ACTIVE_END_DATE IS NULL) OR (ACTIVE_END_DATE > SYSDATE))
    --AND LOCATION_TYPE_CODE = 'WIP'
    --AND LOCATION_ID = p_wip_location
    AND NOT EXISTS (SELECT 'X' FROM CSI_II_RELATIONSHIPS CIR
        WHERE CIR.SUBJECT_ID = CII.INSTANCE_ID
              AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
              --AND SYSDATE BETWEEN NVL(ACTIVE_START_DATE,SYSDATE) AND NVL(ACTIVE_END_DATE,SYSDATE));
                AND NVL(ACTIVE_START_DATE,SYSDATE) <= SYSDATE
                AND SYSDATE < NVL(ACTIVE_END_DATE,SYSDATE+1));

--fix for bug number 4089691 -- inserted by sikumar
--Query to validate the instance for the job during issue if there is a serial number avaialble
CURSOR CSI_ISSUE_SER_ITEM_CUR(p_item_id IN NUMBER,
                        p_serial_num IN VARCHAR2)IS
    SELECT INSTANCE_ID
    FROM CSI_ITEM_INSTANCES CII
    WHERE INVENTORY_ITEM_ID       = p_item_id
    AND SERIAL_NUMBER         = p_serial_num
    AND ACTIVE_START_DATE     <= SYSDATE
    AND ((ACTIVE_END_DATE IS NULL) OR (ACTIVE_END_DATE > SYSDATE))
    AND NOT EXISTS (SELECT 'X' FROM CSI_II_RELATIONSHIPS CIR
        WHERE CIR.SUBJECT_ID = CII.INSTANCE_ID
              AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
              AND SYSDATE BETWEEN NVL(ACTIVE_START_DATE,SYSDATE) AND NVL(ACTIVE_END_DATE,SYSDATE));

--Query to validate workorder operaiton id.
CURSOR AHL_WORKORDER_OPER_CUR (p_wo_id NUMBER,p_op_seq NUMBER, p_woop_id IN NUMBER) IS
     SELECT 1
     FROM AHL_WORKORDER_OPERATIONS
     WHERE WORKORDER_OPERATION_ID =p_woop_id
     AND WORKORDER_ID =p_wo_id
     AND OPERATION_SEQUENCE_NUM = p_op_seq;

-- Query to validate job id
-- Added project and locator for ER# 5854712.
CURSOR AHL_WIPJOB_CUR (p_org_id NUMBER, p_wo_id NUMBER, p_wipjob IN NUMBER) IS
     SELECT A.STATUS_CODE, C.Visit_id, C.Inv_Locator_Id, C.project_id, B.project_task_id,
     LOC.subinventory_code
     FROM AHL_WORKORDERS A, AHL_VISIT_TASKS_B B, AHL_VISITS_B C, MTL_ITEM_LOCATIONS LOC
     WHERE A.WIP_ENTITY_ID = p_wipjob
     AND A.WORKORDER_ID = p_wo_id
     AND B.VISIT_TASK_ID = A.VISIT_TASK_ID
     AND C.VISIT_ID = B.VISIT_ID
     AND C.ORGANIZATION_ID = p_org_id
     AND C.ORGANIZATION_ID = LOC.ORGANIZATION_ID(+)
     AND C.INV_LOCATOR_ID = LOC.INVENTORY_LOCATION_ID(+);

-- Item id validation and selecting serial control code,lot control code values
CURSOR AHL_ITEM_ID_CUR (p_org_id NUMBER, p_item NUMBER) IS
    SELECT SERIAL_NUMBER_CONTROL_CODE, LOT_CONTROL_CODE, REVISION_QTY_CONTROL_CODE,
           LOCATION_CONTROL_CODE,EAM_ITEM_TYPE, primary_uom_code, concatenated_segments
    FROM MTL_SYSTEM_ITEMS_kfv
    WHERE ORGANIZATION_ID = p_org_id
    AND INVENTORY_ITEM_ID = p_item
    AND ENABLED_FLAG = 'Y'
    AND ((START_DATE_ACTIVE IS NULL) OR (START_DATE_ACTIVE <= SYSDATE))
    AND ((END_DATE_ACTIVE IS NULL) OR (END_DATE_ACTIVE >= SYSDATE));

 --Sub inventory Query
CURSOR AHL_SUBINV_CUR (p_org_id NUMBER, p_subinv VARCHAR2) IS
    SELECT 1
    FROM MTL_SECONDARY_INVENTORIES
    WHERE ORGANIZATION_ID = p_org_id
    AND SECONDARY_INVENTORY_NAME  = p_subinv;

-- Locator query
CURSOR AHL_LOCATOR_CUR (p_org_id NUMBER, p_locator_id NUMBER, p_subinv VARCHAR2) IS
    SELECT 1
    FROM MTL_ITEM_LOCATIONS
    WHERE ORGANIZATION_ID = p_org_id
    AND INVENTORY_LOCATION_ID = p_locator_id
    ;--AND SUBINVENTORY_CODE = p_subinv;

-- Revision query
CURSOR AHL_REVISION_CUR (p_org_id NUMBER, p_item NUMBER, p_revision VARCHAR2) IS
    SELECT 1
    FROM MTL_ITEM_REVISIONS
    WHERE ORGANIZATION_ID = p_org_id
    AND INVENTORY_ITEM_ID = p_item
    AND REVISION = p_revision;

-- Reason query
CURSOR AHL_REASON_CUR (p_reason NUMBER) IS
    SELECT 1
    FROM MTL_TRANSACTION_REASONS
    WHERE REASON_ID = p_reason;

-- Condition Validaiton
CURSOR Condition_Cur(p_condition NUMBER) IS
    SELECT STATUS_ID
    FROM MTL_MATERIAL_STATUSES
    WHERE STATUS_ID = p_Condition;

-- Query to Validate Problem Code
CURSOR PROBLEM_CODE_LKUP_CUR (p_problem_code VARCHAR2) IS
/* Tamal [R12 APPSPERF fixes]
 * R12 Drop 4 - SQL ID: 14399922
 * Bug #4918991
 */
SELECT 1
FROM FND_LOOKUP_VALUES FL
WHERE
    FL.LOOKUP_TYPE = 'REQUEST_PROBLEM_CODE' AND
    FL.LOOKUP_CODE = p_problem_code AND
    FL.ENABLED_FLAG = 'Y' AND
    FL.LANGUAGE = USERENV('LANG') AND
    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(FL.START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(FL.END_DATE_ACTIVE,SYSDATE)) AND
    (
        (
            NOT EXISTS
            (
                SELECT 1
                FROM CS_SR_PROB_CODE_MAPPING_DETAIL
                WHERE
                    INCIDENT_TYPE_ID = FND_PROFILE.VALUE('AHL_PRD_SR_TYPE') AND
                    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE))
            )
        )
        OR
        (
            EXISTS
            (
                SELECT 1
                FROM CS_SR_PROB_CODE_MAPPING_DETAIL
                WHERE
                    INCIDENT_TYPE_ID = FND_PROFILE.VALUE('AHL_PRD_SR_TYPE') AND
                    PROBLEM_CODE = p_problem_code AND
                    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE,SYSDATE))
            )
        )
    );

/*
CURSOR TRANSACTION_DATE_CUR(C_WORKORDER_OPERATION_ID NUMBER,C_WORKORDER_ID NUMBER,C_INV_ITEM_ID NUMBER) IS
       SELECT A.scheduled_start_date
       FROM AHL_WORKORDER_OPERATIONS_V A ,AHL_SCHEDULE_MATERIALS B
       WHERE A.WORKORDER_OPERATION_ID=C_WORKORDER_OPERATION_ID
       AND   A.WORKORDER_ID=C_WORKORDER_ID
       AND  A.WORKORDER_OPERATION_ID=B.WORKORDER_OPERATION_ID
       AND  B.INVENTORY_ITEM_ID=C_INV_ITEM_ID
       AND  A.OPERATION_SEQUENCE_NUM=B.OPERATION_SEQUENCE;
*/

CURSOR mtl_srl_num_csr(p_org_id In NUMBER,
                       p_inv_id IN NUMBER,
                       p_serial_number IN VARCHAR2) IS
   SELECT current_subinventory_code, current_locator_id
   FROM mtl_serial_numbers
   WHERE serial_number = p_serial_number
     AND current_organization_id = p_org_id
     AND inventory_item_id = p_inv_id
     AND current_status = 3;

-- Default Subinventory.
CURSOR wip_params_cur (p_org_id IN NUMBER) IS
   SELECT default_pull_supply_subinv, default_pull_supply_locator_id
   FROM wip_parameters
   WHERE organization_id = p_org_id;

 CURSOR workorder_released_date_csr(p_wip_entity_id IN NUMBER) IS
 SELECT DATE_RELEASED FROM WIP_DISCRETE_JOBS
 WHERE WIP_ENTITY_ID = p_wip_entity_id;

-- Lot Number
CURSOR mtl_lot_num_csr (p_org_id In NUMBER,
                        p_inventory_item_id IN NUMBER,
                        p_lot_number        IN VARCHAR2) IS
   SELECT 'x'
   FROM mtl_lot_numbers
   WHERE organization_id = p_org_id
     AND inventory_item_id = p_inventory_item_id
     AND lot_number = p_lot_number
     AND nvl(disable_flag,2) = 2;

-- fix for bug# 5172147.
-- check if disposition exists.
-- commented out org_id to fix bug# 6120115.
CURSOR disposition_cur (p_disposition_id in NUMBER,
                        p_workorder_id in NUMBER,
                        p_inventory_item_id IN NUMBER,
                        --p_org_id IN NUMBER,
                        p_serial_num IN VARCHAR2,
                        p_revision IN VARCHAR2,
                        p_lotNumber IN VARCHAR2) IS

SELECT disposition_id
   FROM AHL_MTL_RET_DISPOSITIONS_V a
   WHERE WORKORDER_ID = p_workorder_id
   AND   a.disposition_id = p_disposition_id
   AND   INVENTORY_ITEM_ID = p_inventory_item_id
   --AND   ORGANIZATION_ID = p_org_id
   AND   nvl(SERIAL_NUMBER,'x')=NVL(p_serial_num,nvl(SERIAL_NUMBER,'x'))
   AND   nvl(LOT_NUMBER,'x')=NVL(p_lotNumber,nvl(lot_number,'x'))
   AND   nvl(ITEM_REVISION,'x')=NVL(p_revision,nvl(ITEM_REVISION,'x'));
   -- commented workorder_operation_id condition.
   -- disposition created against a material issue will not have this value
   -- populated.
   --AND   WORKORDER_OPERATION_ID is not null;

-- Added for FP bug# 5903318.
-- validate create_wo_option.
CURSOR create_wo_cur(p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
   SELECT meaning
   FROM FND_LOOKUP_VALUES_VL
   WHERE lookup_type = p_lookup_type
     AND lookup_code = p_lookup_code
     AND ENABLED_FLAG = 'Y'
     AND ((START_DATE_ACTIVE IS NULL) OR (START_DATE_ACTIVE <= SYSDATE))
     AND ((END_DATE_ACTIVE IS NULL) OR (END_DATE_ACTIVE >= SYSDATE));

 l_curr_subinventory_code       mtl_serial_numbers.current_subinventory_code%TYPE;
 l_curr_locator_id              NUMBER;
 l_primary_uom_code             mtl_system_items.primary_uom_code%TYPE;
 l_quantity                     NUMBER;
 l_concatenated_segments        mtl_system_items_kfv.concatenated_segments%TYPE;
 l_visit_id                     NUMBER;
 l_def_supply_subinv            wip_parameters.default_pull_supply_subinv%TYPE;
 l_def_supply_locator_id        NUMBER;

 L_SCHED_START_DATE             DATE;

 l_workorder_released_date      DATE;

 l_junk                         VARCHAR2(1);
 l_disposition_id               NUMBER;

 -- Added for FP bug# 5903318.
 l_fnd_meaning                  fnd_lookup_values_vl.meaning%TYPE;

 -- Added for ER# 5854712.
 l_inv_locator_id               NUMBER;
 l_project_id                   NUMBER;
 l_project_task_id              NUMBER;
 l_subinventory_code            mtl_item_locations.subinventory_code%TYPE;
 l_project_locator_id           NUMBER;


BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.enable_debug;
          AHL_DEBUG_PUB.debug('Ahl Validating TxnType...['||to_Char(p_x_ahl_mtltxn_rec.Transaction_Type_Id)||']');
        END IF;

        -- Validate transaction type id(should be one of wip conponent issue or return
        IF(p_x_ahl_mtltxn_rec.Transaction_Type_Id <> WIP_CONSTANTS.RETCOMP_TYPE AND
           p_x_ahl_mtltxn_rec.Transaction_Type_Id <> WIP_CONSTANTS.ISSCOMP_TYPE ) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_TXNTYPE');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        -- transaction quantity should be +ve always. Negative quantities are not
        -- supported currently.
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Validating quantity...['||to_Char(p_x_ahl_mtltxn_rec.Quantity)||']');
        END IF;

        IF(nvl(p_x_ahl_mtltxn_rec.Quantity,0) <= 0) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_QTY');
            FND_MESSAGE.Set_Token('QUANTITY',p_x_ahl_mtltxn_rec.Quantity);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Validating Wip_Entity_id['
          ||to_char(p_x_ahl_mtltxn_rec.Organization_ID)||','
          ||to_Char(p_x_ahl_mtltxn_rec.Workorder_ID)
        ||','||to_Char(p_x_ahl_mtltxn_rec.Wip_Entity_Id)||']');


        END IF;

        -- Validate the Wip_job_id and workorder_operation_Id
        OPEN AHL_WIPJOB_CUR(p_x_ahl_mtltxn_rec.Organization_ID, p_x_ahl_mtltxn_rec.Workorder_ID, p_x_ahl_mtltxn_rec.Wip_Entity_Id);
        FETCH AHL_WIPJOB_CUR INTO l_job_status, l_visit_id, l_inv_locator_id,
                                  l_project_id, l_project_task_id, l_subinventory_code;
        IF(AHL_WIPJOB_CUR%NOTFOUND) THEN
            IF G_DEBUG='Y' THEN
                      AHL_DEBUG_PUB.debug('JOB validation failed');
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_WIP_ENTITY');
            if(p_x_ahl_mtltxn_rec.Wip_Entity_Id = FND_API.G_MISS_NUM) THEN
                p_x_ahl_mtltxn_rec.Wip_Entity_Id := NULL;
            END IF;
            FND_MESSAGE.Set_Token('WIP_ENTITY',p_x_ahl_mtltxn_rec.Wip_Entity_Id);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE AHL_WIPJOB_CUR;
            RETURN;
        ELSE
            -- Assign visit ID to mtl_txn_rec.
            -- Added post 11.5.10.
            IF (p_x_ahl_mtltxn_rec.target_visit_id IS NULL OR
                p_x_ahl_mtltxn_rec.target_visit_id = FND_API.G_MISS_NUM) THEN
                  p_x_ahl_mtltxn_rec.target_visit_id := l_visit_id;
            END IF;
                        --

            IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.debug('JOB validation success['||l_job_status||']');
            END IF;
            -- fix for re-open case in bug# 6773241
            IF (p_x_ahl_mtltxn_rec.transaction_type_id = WIP_CONSTANTS.RETCOMP_TYPE) THEN
              IF(l_job_status <> C_JOB_RELEASED
                 AND l_job_status <> C_JOB_PENDING_QA
                 AND l_job_status <> C_JOB_COMPLETE
                 --AND l_job_status <> C_JOB_PARTS_HOLD
                ) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_JOB_STATUS');
                --FND_MESSAGE.Set_Token('STATUS',l_job_status);
                FND_MESSAGE.Set_Token('STATUS', p_x_ahl_mtltxn_rec.Workorder_Status);
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
            ELSE
               -- issue case.
               IF(l_job_status <> C_JOB_RELEASED
                  --AND l_job_status <> C_JOB_PENDING_QA
                  AND l_job_status <> C_JOB_COMPLETE
                  --AND l_job_status <> C_JOB_PARTS_HOLD
                  ) THEN
                  FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_JOB_STATUS');
                  --FND_MESSAGE.Set_Token('STATUS',l_job_status);
                  FND_MESSAGE.Set_Token('STATUS', p_x_ahl_mtltxn_rec.Workorder_Status);
                  FND_MSG_PUB.ADD;
                  x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
            END IF;
        END IF;
        CLOSE AHL_WIPJOB_CUR;

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug('Validating Workorder operation Id ['||to_Char(p_x_ahl_mtltxn_rec.Workorder_ID)||','
            ||to_Char(p_x_ahl_mtltxn_rec.Operation_Seq_Num)||','||to_Char(p_x_ahl_mtltxn_rec.Workorder_Operation_Id)||']');
        END IF;


        -- Validate the Workorder Id and Operation Seq num
        OPEN AHL_WORKORDER_OPER_CUR(p_x_ahl_mtltxn_rec.Workorder_ID,
                            p_x_ahl_mtltxn_rec.Operation_Seq_Num,
                            p_x_ahl_mtltxn_rec.Workorder_Operation_Id);
        FETCH AHL_WORKORDER_OPER_CUR INTO l_Count;
        IF(AHL_WORKORDER_OPER_CUR%NOTFOUND) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_WORKORDER_OP');
            FND_MESSAGE.Set_Token('WO',p_x_ahl_mtltxn_rec.Workorder_Id);
            FND_MESSAGE.Set_Token('SEQ',p_x_ahl_mtltxn_rec.Operation_Seq_Num);
            FND_MESSAGE.Set_Token('OP',p_x_ahl_mtltxn_rec.Workorder_Operation_Id);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE AHL_WORKORDER_OPER_CUR;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Validating item_id['||to_Char(p_x_ahl_mtltxn_rec.Organization_ID)||','||to_Char(p_x_ahl_mtltxn_rec.Inventory_Item_Id)||']');
        END IF;

        If  p_x_ahl_mtltxn_rec.transaction_type_id= WIP_CONSTANTS.RETCOMP_TYPE
        and p_x_ahl_mtltxn_rec.Ahl_mtltxn_Id is null
        then

            Validate_item_duplic
            (
                p_x_ahl_mtltxn_rec
            );

        End if;


       /*
        OPEN TRANSACTION_DATE_CUR(
                            p_x_ahl_mtltxn_rec.Workorder_Operation_Id,
                            p_x_ahl_mtltxn_rec.Workorder_ID,
                            p_x_ahl_mtltxn_rec.INVENTORY_ITEM_ID
                            );
        FETCH TRANSACTION_DATE_CUR INTO L_SCHED_START_DATE;
        IF  TRANSACTION_DATE_CUR%FOUND
        THEN
            IF  L_SCHED_START_DATE > p_x_ahl_mtltxn_rec.TRANSACTION_DATE
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_COM_INVALID_TRANSACTION_DATE');
                --FND_MESSAGE.Set_Token('FIELD',p_x_ahl_mtltxn_rec.Inventory_Item_Id);
                FND_MSG_PUB.ADD;

            END IF;
        END IF;
        CLOSE TRANSACTION_DATE_CUR;
        */


    -- Validate Item id
    OPEN AHL_ITEM_ID_CUR(p_x_ahl_mtltxn_rec.Organization_ID,
                p_x_ahl_mtltxn_rec.Inventory_Item_Id);
    FETCH AHL_ITEM_ID_CUR INTO l_serial_Control, l_lot_control, l_revision_control, l_location_control,
                           x_eam_item_type_id, l_primary_uom_code,
                                   l_concatenated_segments;
    IF(AHL_ITEM_ID_CUR%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_COM_INVALID_ITEM');
        if(p_x_ahl_mtltxn_rec.Inventory_Item_Id = FND_API.G_MISS_NUM) THEN
            p_x_ahl_mtltxn_rec.Inventory_Item_Id := NULL;
        END IF;
        FND_MESSAGE.Set_Token('FIELD',p_x_ahl_mtltxn_rec.Inventory_Item_Id);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        CLOSE AHL_ITEM_ID_CUR;
        -- Skip the rest of the validations.
        RETURN;
    END IF;
    CLOSE AHL_ITEM_ID_CUR;


    -- default project locator if move_to_project flag is checked.(ER 5854712).
    -- For return txns only.
    IF (p_x_ahl_mtltxn_rec.Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE)
        AND (p_x_ahl_mtltxn_rec.move_to_project_flag = 'Y') THEN
             IF (l_inv_locator_id IS NOT NULL) THEN
                 IF G_DEBUG='Y' THEN
                   AHL_DEBUG_PUB.debug('Defaulting from Visit Locator['||l_inv_locator_id||','|| l_project_id ||',' || l_project_task_id || ']');
                 END IF;
                 PJM_PROJECT_LOCATOR.Get_DefaultProjectLocator(
                         p_organization_id => p_x_ahl_mtltxn_rec.organization_id,
                         p_locator_id      => l_inv_locator_id,
                         p_project_id      => l_project_id,
                         p_task_id         => l_project_task_id,
                         p_project_locator_id => l_project_locator_id);
                 IF (l_project_locator_id IS NULL) THEN
                     FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_LOCATOR');
                     FND_MESSAGE.Set_Token('LOC',l_inv_locator_id);
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_ERROR;
                 ELSE
                     p_x_ahl_mtltxn_rec.locator_id := l_project_locator_id;
                     p_x_ahl_mtltxn_rec.subinventory_name := l_subinventory_code;
                 END IF;
             ELSE
               -- move_to_project_flag error.
               FND_MESSAGE.Set_Name('AHL','AHL_PRD_MOVEPRJ_FLAG_INVALID');
               FND_MSG_PUB.ADD;
             END IF;

    END IF; -- p_x_ahl_mtltxn_rec.Locator_Id.move_to_project_flag = 'Y'


    -- Added Post 11.5.10: Default subinventory.
    --
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('Defaulting SubInv/Locator['||p_x_ahl_mtltxn_rec.Subinventory_Name||',' ||
             p_x_ahl_mtltxn_rec.Locator_id || ']');
        END IF;
        OPEN wip_params_cur(p_x_ahl_mtltxn_rec.Organization_ID);
        FETCH wip_params_cur INTO l_def_supply_subinv, l_def_supply_locator_id;
        IF (wip_params_cur%FOUND) THEN
           IF ((p_x_ahl_mtltxn_rec.Subinventory_Name IS NULL OR
               p_x_ahl_mtltxn_rec.Subinventory_Name = FND_API.G_MISS_CHAR) AND
              l_def_supply_subinv IS NOT NULL) THEN
              p_x_ahl_mtltxn_rec.Subinventory_Name := l_def_supply_subinv;
           END IF;

           -- Locator.
           -- Added check for ER 5854712 - support dynamic locator creation.
           -- default only when both locator ID and Segments are null.
           IF ((p_x_ahl_mtltxn_rec.Locator_id IS NULL OR
               p_x_ahl_mtltxn_rec.Locator_id = FND_API.G_MISS_NUM) AND
               (p_x_ahl_mtltxn_rec.Locator_Segments IS NULL OR
                p_x_ahl_mtltxn_rec.Locator_Segments = FND_API.G_MISS_CHAR) AND
               l_def_supply_locator_id IS NOT NULL) THEN
              p_x_ahl_mtltxn_rec.Locator_id := l_def_supply_locator_id;
           END IF;

        END IF;
        CLOSE  wip_params_cur;


    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('Validating serial num(control, srl_num)['||to_Char(l_serial_Control)||','||p_x_ahl_mtltxn_rec.Serial_Number||']');
        END IF;

    -- If the item is of serial controlled check if the serial numebr is null
    IF((p_x_ahl_mtltxn_rec.Serial_Number IS NULL
         OR p_x_ahl_mtltxn_rec.Serial_Number = FND_API.G_MISS_CHAR)
         AND (nvl(l_serial_Control,0) <> nvl(C_NO_SERIAL_CONTROL,0)) ) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_SRLNUM');
        FND_MESSAGE.Set_Token('SER',p_x_ahl_mtltxn_rec.Serial_Number);
        FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF (p_x_ahl_mtltxn_rec.Serial_Number IS NOT NULL AND
         p_x_ahl_mtltxn_rec.Serial_Number <> FND_API.G_MISS_CHAR AND
         nvl(l_serial_Control,1) = 1) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_SRLNUM_NOTMAND');
        FND_MESSAGE.Set_Token('SER',p_x_ahl_mtltxn_rec.Serial_Number);
        FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Added for FP bug# 5903318.
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('Validating Create WO Option['||p_x_ahl_mtltxn_rec.create_wo_option ||']');
    END IF;

    -- Validate Create WO Option lookup code.
    IF (p_x_ahl_mtltxn_rec.Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE) THEN
       IF (p_x_ahl_mtltxn_rec.create_wo_option IS NULL OR
           p_x_ahl_mtltxn_rec.create_wo_option = FND_API.G_MISS_CHAR) THEN
          IF (nvl(l_serial_Control,0) = C_NO_SERIAL_CONTROL) THEN
             p_x_ahl_mtltxn_rec.create_wo_option := 'CREATE_SR_NO';
          ELSE
             -- serialized.
             p_x_ahl_mtltxn_rec.create_wo_option := 'CREATE_WO_NO';
          END IF;
       ELSE
          -- validate lookup code.
          OPEN create_wo_cur(p_x_ahl_mtltxn_rec.create_wo_option, 'AHL_SR_WO_CREATE_OPTIONS');
          FETCH create_wo_cur INTO l_fnd_meaning;
          IF (create_wo_cur%NOTFOUND) THEN
             FND_MESSAGE.Set_Name('AHL','AHL_PRD_INV_LOOKUP');
             FND_MESSAGE.Set_Token('LCODE',p_x_ahl_mtltxn_rec.create_wo_option);
             FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE create_wo_cur;
       END IF;

       IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug('After Defaulting Create WO Option['||p_x_ahl_mtltxn_rec.create_wo_option ||']');
       END IF;

       -- Check if create_wo_option is valid based on l_serial_Control.
       IF (nvl(l_serial_Control,0) = C_NO_SERIAL_CONTROL ) THEN
          -- non-serial.
          IF (p_x_ahl_mtltxn_rec.create_wo_option = 'CREATE_WO_NO') THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_NONSRL_WO_OPT');
            FND_MESSAGE.Set_Token('WO_OPT',l_fnd_meaning);
            FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
       END IF;
    END IF;
    -- End changes for FP bug# 5903318.

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('Validating lot num(control, srl_num)['||to_Char(l_lot_Control)||','||p_x_ahl_mtltxn_rec.serial_Number||']');
    END IF;

        -- If the item is of lot controlled check if the lot number is null
        IF((p_x_ahl_mtltxn_rec.Lot_Number IS NULL
             OR p_x_ahl_mtltxn_rec.Lot_Number = FND_API.G_MISS_CHAR)
             AND (l_lot_Control <> C_NO_LOT_CONTROL) ) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_LOT');
            FND_MESSAGE.Set_Token('LOT',p_x_ahl_mtltxn_rec.Lot_Number);
                        FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
                -- validate lot number.
                IF ((p_x_ahl_mtltxn_rec.Lot_Number IS NOT NULL AND
                     p_x_ahl_mtltxn_rec.Lot_Number <> FND_API.G_MISS_CHAR)
                     AND (l_lot_Control <> C_NO_LOT_CONTROL) ) THEN
                   OPEN mtl_lot_num_csr(p_x_ahl_mtltxn_rec.organization_id,
                        p_x_ahl_mtltxn_rec.inventory_item_id,
                        p_x_ahl_mtltxn_rec.Lot_Number);
                   FETCH mtl_lot_num_csr INTO l_junk;
                   IF (mtl_lot_num_csr%NOTFOUND) THEN
                     FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_LOT');
                     FND_MESSAGE.Set_Token('LOT',p_x_ahl_mtltxn_rec.Lot_Number);
                     FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
                     FND_MSG_PUB.ADD;
                     x_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;
                   CLOSE mtl_lot_num_csr;
                END IF;

                -- raise error if item is not lot controlled.
                IF ((p_x_ahl_mtltxn_rec.Lot_Number IS NOT NULL AND
                     p_x_ahl_mtltxn_rec.Lot_Number <> FND_API.G_MISS_CHAR)
                     AND (l_lot_Control = C_NO_LOT_CONTROL) ) THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_PRD_LOT_NOTNULL');
                        FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

        -- If the locator controlled is true at the item level or sub inventory level
        -- check if the locator id is given or not.
        /****************************************************************
         This vlaidation happens in the MTL API, so we do not need it here

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Validating locator(control, srl_num)['||to_Char(l_location_Control)||','||to_Char(p_x_ahl_mtltxn_rec.Locator_Id)||']');

    END IF;

        IF(p_x_ahl_mtltxn_rec.Locator_Id IS NULL
             OR p_x_ahl_mtltxn_rec.Locator_Id = FND_API.G_MISS_NUM) THEN
            IF (l_location_Control <> C_NO_LOCATOR_CONTROL) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_LOCATOR');
                if(p_x_ahl_mtltxn_rec.Locator_Id = FND_API.G_MISS_NUM) THEN
                    p_x_ahl_mtltxn_rec.Locator_Id := NULL;
                END IF;
                FND_MESSAGE.Set_Token('LOC',p_x_ahl_mtltxn_rec.Locator_Id);
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        ELSE
        ****************************************************************/
                IF (p_x_ahl_mtltxn_rec.Locator_Id IS NOT NULL AND
                    p_x_ahl_mtltxn_rec.Locator_Id <> FND_API.G_MISS_NUM) THEN
            OPEN AHL_LOCATOR_CUR(p_x_ahl_mtltxn_rec.Organization_ID,
                                p_x_ahl_mtltxn_rec.Locator_Id,
                                p_x_ahl_mtltxn_rec.Subinventory_Name);
            FETCH AHL_LOCATOR_CUR INTO l_Count;
            IF(AHL_LOCATOR_CUR%NOTFOUND) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_LOCATOR');
                if(p_x_ahl_mtltxn_rec.Locator_Id = FND_API.G_MISS_NUM) THEN
                    p_x_ahl_mtltxn_rec.Locator_Id := NULL;
                END IF;
                FND_MESSAGE.Set_Token('LOC',p_x_ahl_mtltxn_rec.Locator_Id);
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            CLOSE AHL_LOCATOR_CUR;
        END IF;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Validating revision['||p_x_ahl_mtltxn_rec.Revision||']');
                END IF;

        -- Tamal: Bug #4091154: Begin
        -- If item is revision-controlled, then verify revision is NOT NULL and is valid
        -- If item is not revision-controlled, then verify revision is NULL
        IF (nvl(l_revision_control, -1) = 2)
        THEN
            IF (p_x_ahl_mtltxn_rec.Revision IS NULL OR p_x_ahl_mtltxn_rec.Revision = FND_API.G_MISS_CHAR)
            THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_REVISION');
            FND_MESSAGE.Set_Token('REVISION',p_x_ahl_mtltxn_rec.Revision);
            FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            ELSE
            OPEN AHL_REVISION_CUR
            (
                p_x_ahl_mtltxn_rec.Organization_ID,
                p_x_ahl_mtltxn_rec.Inventory_Item_Id,
                p_x_ahl_mtltxn_rec.Revision
            );
            FETCH AHL_REVISION_CUR INTO l_Count;
            IF (AHL_REVISION_CUR%NOTFOUND)
            THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_REVISION');
                        FND_MESSAGE.Set_Token('REVISION',p_x_ahl_mtltxn_rec.Revision);
                FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            CLOSE AHL_REVISION_CUR;
            END IF;
        ELSE
            IF (p_x_ahl_mtltxn_rec.Revision IS NOT NULL AND p_x_ahl_mtltxn_rec.Revision <> FND_API.G_MISS_CHAR)
            THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_REVNUM_NOTMAND');
            FND_MESSAGE.Set_Token('REV',p_x_ahl_mtltxn_rec.Revision);
            FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
            -- Tamal: Bug #4091154: End

        --Reason should be valid
        IF(p_x_ahl_mtltxn_rec.Reason_Id IS NOT NULL AND
            p_x_ahl_mtltxn_rec.Reason_Id <> FND_API.G_MISS_NUM) THEN
            OPEN AHL_REASON_CUR(p_x_ahl_mtltxn_rec.Reason_Id);
            FETCH AHL_REASON_CUR INTO l_Count;
            IF(AHL_REASON_CUR%NOTFOUND) THEN
               FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVLD_REASON');
               FND_MESSAGE.Set_Token('REASON',p_x_ahl_mtltxn_rec.Revision);
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            CLOSE AHL_REASON_CUR;
        END IF;

        IF (p_x_ahl_mtltxn_rec.Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE) THEN
            --Condition Validation
            OPEN Condition_Cur(p_x_ahl_mtltxn_rec.Condition);
            FETCH Condition_Cur INTO l_Count;
            IF(Condition_Cur%NOTFOUND) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_COND_INVALID');
                if(p_x_ahl_mtltxn_rec.Condition = FND_API.G_MISS_NUM) THEN
                    p_x_ahl_mtltxn_rec.Condition := NULL;
                END IF;
                FND_MESSAGE.Set_Token('CODE',p_x_ahl_mtltxn_rec.Condition);
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            CLOSE Condition_Cur;

            IF G_DEBUG='Y' THEN
                 AHL_DEBUG_PUB.debug('Validating Condition/Subinv['||p_x_ahl_mtltxn_rec.Condition||','||p_x_ahl_mtltxn_rec.Subinventory_Name||']');
                END IF;

            -- Check if the Condition matches the Sub inventory status
            -- in case of unserviceable and MRB
            AHL_PRD_UTIL_PKG.Validate_Material_Status(p_x_ahl_mtltxn_rec.Organization_Id,
                                     p_x_ahl_mtltxn_rec.Subinventory_Name,
                                     p_x_ahl_mtltxn_rec.Condition,
                                     l_return_Status);
                        IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
                          x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;

        ELSE
            IF G_DEBUG='Y' THEN
                   AHL_DEBUG_PUB.debug('Validating Subinv['||p_x_ahl_mtltxn_rec.Subinventory_Name||']');
                    END IF;

            -- Sub inventory  validation
            AHL_PRD_UTIL_PKG.Validate_Material_Status(p_x_ahl_mtltxn_rec.Organization_Id,
                                     p_x_ahl_mtltxn_rec.Subinventory_Name,
                                     NULL,
                                     l_return_Status);
            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('After Validating Subinv['||p_x_ahl_mtltxn_rec.Subinventory_Name||','||x_return_Status || ']');
                        END IF;

                        IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
                          x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
        END IF;

         --If the Transaction_type_id is WIP RETURN
    IF (p_x_ahl_mtltxn_rec.Transaction_Type_Id = WIP_CONSTANTS.RETCOMP_TYPE) THEN


             --If the item is trackkable check if the parent item
             --exists for the item, if exists return error : AHL_MTL_TXN_NOT_ALLOWED

            IF (Is_Item_Trackable(p_x_ahl_mtltxn_rec.Organization_Id,
                                        p_x_ahl_mtltxn_rec.Inventory_Item_Id)) THEN

                    IF G_DEBUG='Y' THEN
                      AHL_DEBUG_PUB.debug('selecting wip location id..');
                    END IF;
                    -- R12: Fix for bug# 5221513
                    -- IB team have asked us to remove the location validation to fix the issue.
                    /*
                    OPEN CSI_LOCATION_CUR(p_x_ahl_mtltxn_rec.Organization_Id);
                    FETCH CSI_LOCATION_CUR INTO l_wip_location;
                    IF(CSI_LOCATION_CUR%NOTFOUND) THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_PRD_CSI_INSTALL_ERROR');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                    END IF;
                    CLOSE CSI_LOCATION_CUR;
                    IF G_DEBUG='Y' THEN
                      AHL_DEBUG_PUB.debug('wip location id['||to_char(l_wip_location)||']');
                    END IF;
                    */

                   IF (p_x_ahl_mtltxn_rec.Serial_Number IS NULL
                        OR p_x_ahl_mtltxn_rec.Serial_Number = FND_API.G_MISS_CHAR) THEN

                           -- Non serialized item:

                           l_sql := 'SELECT INSTANCE_ID FROM CSI_ITEM_INSTANCES CII ';
                           l_sql := l_sql || ' WHERE 1=1';
                           --l_sql := l_Sql || ' AND INV_MASTER_ORGANIZATION_ID=:b1';
                           l_sql := l_sql || ' AND INVENTORY_ITEM_ID =:b2' ;
                           l_sql := l_sql || ' AND WIP_JOB_ID=:b3';
                           --l_sql := l_sql || ' AND INV_SUBINVENTORY_NAME=:b4' ;
                           -- commenting our location check to fix bug# 5221513.
                           --l_sql := l_sql || ' AND LOCATION_TYPE_CODE=''WIP''' ;
                           --l_sql := l_sql || ' AND LOCATION_ID=:b7 ';
                           -- Fix for bug# 4074091. -- ORA-1422 error.
                           l_sql := l_sql || ' AND ROWNUM < 2 ';
                           -- End changes for bug fix.

                           l_sql := l_sql || ' AND ACTIVE_START_DATE <=SYSDATE ';
                           l_sql := l_sql || ' AND ((ACTIVE_END_DATE IS NULL) OR (ACTIVE_END_DATE>SYSDATE))';
                           l_sql := l_sql || ' AND NOT EXISTS (SELECT null FROM CSI_II_RELATIONSHIPS CIR ';
                           l_sql := l_sql || ' WHERE CIR.SUBJECT_ID = CII.INSTANCE_ID ';
                           l_sql := l_sql || ' AND CIR.RELATIONSHIP_TYPE_CODE = ''COMPONENT-OF''';
                           l_sql := l_sql || ' AND ((CIR.ACTIVE_START_DATE IS NULL) OR (CIR.ACTIVE_START_DATE <= SYSDATE))';
                           l_sql := l_sql || ' AND ((CIR.ACTIVE_END_DATE IS NULL) OR (CIR.ACTIVE_END_DATE > SYSDATE)) )';

                           IF(p_x_ahl_mtltxn_rec.Revision IS NOT NULL
                                AND p_x_ahl_mtltxn_rec.Revision <> FND_API.G_MISS_CHAR) THEN
                                  --l_sql := l_sql || ' AND INVENTORY_REVISION='''||p_x_ahl_mtltxn_rec.Revision||'''';
                                  l_sql := l_sql || ' AND INVENTORY_REVISION=:b5';
                                                  l_revision_flag := TRUE;
                           END IF;
                           IF(p_x_ahl_mtltxn_rec.Lot_Number IS NOT NULL
                                AND p_x_ahl_mtltxn_rec.Lot_Number <> FND_API.G_MISS_CHAR) THEN
                                  --l_sql := l_sql || ' AND LOT_NUMBER='''||p_x_ahl_mtltxn_rec.Lot_Number||'''';
                                  l_sql := l_sql || ' AND LOT_NUMBER=:b6';
                                                  l_lot_flag := TRUE;
                           END IF;

                           BEGIN
                            IF G_DEBUG='Y' THEN
                                AHL_DEBUG_PUB.debug('Validating instance:item/wipjob/subinv['
                                       ||to_Char(p_x_ahl_mtltxn_rec.Inventory_Item_Id)||','
                                       ||to_Char(p_x_ahl_mtltxn_rec.Wip_Entity_Id)||']');

                                AHL_DEBUG_PUB.debug('['||p_x_ahl_mtltxn_rec.Subinventory_Name||']');
                                AHL_DEBUG_PUB.debug('[Length of sql string:'||length(l_sql)||']');
                                AHL_DEBUG_PUB.debug('[1:'||substr(l_sql,1,240)||']');
                                AHL_DEBUG_PUB.debug('[2:'||substr(l_sql,241,240)||']');
                                AHL_DEBUG_PUB.debug('[3:'||substr(l_sql,481,240)||']');
                            END IF;
                            -- R12: Fix for bug# 5221513
                            -- remove WIP location validation.
                            IF (l_revision_flag = TRUE) AND (l_lot_flag = TRUE)
                            THEN
                               EXECUTE IMMEDIATE l_sql INTO x_Item_Instance_Id
                                         USING --p_x_ahl_mtltxn_rec.Organization_Id,
                                    p_x_ahl_mtltxn_rec.Inventory_Item_Id,
                                    p_x_ahl_mtltxn_rec.Wip_Entity_Id,
                                    --, p_x_ahl_mtltxn_rec.Subinventory_Name,
                                    --l_wip_location,
                                    p_x_ahl_mtltxn_rec.Revision,
                                    p_x_ahl_mtltxn_rec.Lot_Number;
                            ELSIF (l_revision_flag = TRUE) THEN
                               EXECUTE IMMEDIATE l_sql INTO x_Item_Instance_Id
                                         USING --p_x_ahl_mtltxn_rec.Organization_Id,
                                    p_x_ahl_mtltxn_rec.Inventory_Item_Id,
                                    p_x_ahl_mtltxn_rec.Wip_Entity_Id,
                                    --, p_x_ahl_mtltxn_rec.Subinventory_Name,
                                    --l_wip_location,
                                    p_x_ahl_mtltxn_rec.Revision;
                            ELSIF (l_lot_flag = TRUE) THEN
                               EXECUTE IMMEDIATE l_sql INTO x_Item_Instance_Id
                                         USING --p_x_ahl_mtltxn_rec.Organization_Id,
                                    p_x_ahl_mtltxn_rec.Inventory_Item_Id,
                                    p_x_ahl_mtltxn_rec.Wip_Entity_Id,
                                    --, p_x_ahl_mtltxn_rec.Subinventory_Name,
                                    --l_wip_location,
                                    p_x_ahl_mtltxn_rec.Lot_Number;
                            ELSE
                                 EXECUTE IMMEDIATE l_sql INTO x_Item_Instance_Id
                                 USING --p_x_ahl_mtltxn_rec.Organization_Id,
                                    p_x_ahl_mtltxn_rec.Inventory_Item_Id,
                                    p_x_ahl_mtltxn_rec.Wip_Entity_Id;
                                    --l_wip_location;
                                    --, p_x_ahl_mtltxn_rec.Subinventory_Name;
                               END IF;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTL_TXN_NOT_ALLOWED');
                                FND_MSG_PUB.ADD;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                           END;
      p_x_ahl_mtltxn_rec.Item_Instance_ID := x_Item_Instance_Id;

      ELSE
                           -- Serialized item...

       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Validating instance:item/wipjob/srl['||to_Char(p_x_ahl_mtltxn_rec.Inventory_Item_Id)||','
           ||to_Char(p_x_ahl_mtltxn_rec.Wip_Entity_Id)||','
          ||p_x_ahl_mtltxn_rec.Serial_Number||']');
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)THEN
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.Validate_Txn_Rec',
                'p_x_ahl_mtltxn_rec.Inventory_Item_Id : ' || p_x_ahl_mtltxn_rec.Inventory_Item_Id
         );
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.Validate_Txn_Rec',
                'p_x_ahl_mtltxn_rec.Wip_Entity_Id : ' || p_x_ahl_mtltxn_rec.Wip_Entity_Id
         );
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.Validate_Txn_Rec',
                'p_x_ahl_mtltxn_rec.Serial_Number : ' || p_x_ahl_mtltxn_rec.Serial_Number
         );
         /*
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.Validate_Txn_Rec',
                'l_wip_location : ' || l_wip_location
         );*/
       END IF;

         OPEN CSI_SER_ITEM_CUR( p_x_ahl_mtltxn_rec.Inventory_Item_Id,
                                                  p_x_ahl_mtltxn_rec.Wip_Entity_Id,
                                                  p_x_ahl_mtltxn_rec.Serial_Number);
                                                  --l_wip_location);
       FETCH CSI_SER_ITEM_CUR INTO x_Item_Instance_Id;
       IF(CSI_SER_ITEM_CUR%NOTFOUND) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTL_TXN_NOT_ALLOWED');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
       CLOSE CSI_SER_ITEM_CUR;
         p_x_ahl_mtltxn_rec.Item_Instance_ID := x_Item_Instance_Id;
      END IF;


                --If the 'Condition' is MRB and the QA_COLLECTION_ID is null return
                --the Error AHL_NO_QA_RESULTS
                --only in case the return is not tied to a disposition.

                IF (p_x_ahl_mtltxn_rec.Condition = G_AHL_MRB_CONDITION AND
                    p_x_ahl_mtltxn_rec.disposition_id IS NULL) THEN

                    AHL_QA_RESULTS_PVT.get_qa_plan
                        (
                           p_api_version   => 1.0,
                           p_init_msg_list => FND_API.G_False,
                           p_commit => FND_API.G_FALSE,
                           p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                           p_default => FND_API.G_FALSE,
                           p_module_type => 'JSP',
                           p_organization_id => p_x_ahl_mtltxn_rec.Organization_Id,
                           p_transaction_number => 2004,
                           p_col_trigger_value => fnd_profile.value('AHL_MRB_DISP_PLAN_TYPE'),
                           x_return_status => l_return_status,
                           x_msg_count => l_msg_count,
                           x_msg_data => l_msg_data,
                           x_plan_id  => l_plan_id
                         );
                    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                         l_plan_id := null;
                    END If;

                    IF ((l_plan_id is not null) AND
                        (p_x_ahl_mtltxn_rec.Qa_Collection_Id = FND_API.G_MISS_NUM OR
                          p_x_ahl_mtltxn_rec.Qa_Collection_Id IS NULL)) THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_PRD_NO_QA_RESULTS');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                    END IF;
                END IF;

                IF(p_x_ahl_mtltxn_rec.Problem_Code IS NOT NULL
                   AND p_x_ahl_mtltxn_rec.Problem_Code <> FND_API.G_MISS_CHAR) THEN

                    IF G_DEBUG='Y' THEN
                       AHL_DEBUG_PUB.debug('Validating problem code['||p_x_ahl_mtltxn_rec.Problem_Code||']');
                    END IF;

                    OPEN PROBLEM_CODE_LKUP_CUR(p_x_ahl_mtltxn_rec.Problem_Code) ;
                    FETCH PROBLEM_CODE_LKUP_CUR INTO l_count;
                    IF(PROBLEM_CODE_LKUP_CUR%NOTFOUND) THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_PRD_PROBLEM_CODE_INVALID');
                        FND_MESSAGE.Set_Token('CODE',p_x_ahl_mtltxn_rec.Problem_Code);
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                    END IF;
                    CLOSE PROBLEM_CODE_LKUP_CUR;
                END IF;

            END IF; -- End of If for trackkable item check
    ELSE -- if it is a material issue
        -- find out instance id if possible : here (fix for bug number 4089691)
        -- Added trackable item check to fix bug# 6331012.
        IF (p_x_ahl_mtltxn_rec.Serial_Number IS NOT NULL
            AND p_x_ahl_mtltxn_rec.Serial_Number <> FND_API.G_MISS_CHAR
            AND Is_Item_Trackable(p_x_ahl_mtltxn_rec.Organization_Id,
                                  p_x_ahl_mtltxn_rec.Inventory_Item_Id)) THEN
             OPEN CSI_ISSUE_SER_ITEM_CUR( p_x_ahl_mtltxn_rec.Inventory_Item_Id,p_x_ahl_mtltxn_rec.Serial_Number );
             FETCH CSI_ISSUE_SER_ITEM_CUR INTO  p_x_ahl_mtltxn_rec.Item_Instance_ID;
             IF(CSI_ISSUE_SER_ITEM_CUR%NOTFOUND) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTL_TXN_NOT_ALLOWED');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
             CLOSE CSI_ISSUE_SER_ITEM_CUR;
        END IF;
    END IF; -- End of IF for WIP Return Check.


        --If the serial number is not null and the quantity is <>1  return the
        --Error AHL_INVALID_SRL_QTY

            IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Validating serial num/qty['||p_x_ahl_mtltxn_rec.quantity||']');
                END IF;

        IF ((p_x_ahl_mtltxn_rec.Serial_Number <> FND_API.G_MISS_CHAR) AND
            (p_x_ahl_mtltxn_rec.Serial_Number IS NOT NULL) AND
                     nvl(l_serial_Control,1) <> 1)  THEN
                   IF (p_x_ahl_mtltxn_rec.uom IS NOT NULL AND
                       p_x_ahl_mtltxn_rec.uom <> l_primary_uom_code) THEN
                         -- convert qty to primary quantity.
                         l_quantity := inv_convert.inv_um_convert
                              (item_id        => p_x_ahl_mtltxn_rec.Inventory_Item_Id,
                               precision      => 6,
                               from_quantity  => p_x_ahl_mtltxn_rec.Quantity,
                               from_unit      => p_x_ahl_mtltxn_rec.uom,
                               to_unit        => l_primary_uom_code,
                               from_name      => NULL,
                               to_name        => NULL );

                         IF (l_quantity <> 1) THEN
                            FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_ITEM_QTY');
                            FND_MESSAGE.Set_Token('PRIM_UOM',l_primary_uom_code);
                            FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
                            FND_MSG_PUB.ADD;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                         END IF;
                   ELSE
                     -- qty in primary uom.
             IF (p_x_ahl_mtltxn_rec.Quantity <> 1) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_ITEM_QTY');
                        FND_MESSAGE.Set_Token('PRIM_UOM',l_primary_uom_code);
                        FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
                     END IF;
                   END IF; -- uom code.
        END IF; -- serial num.

            IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Validating serial subinv, loc['||p_x_ahl_mtltxn_rec.Serial_Number||']');
                END IF;

                -- For issue txn with serial number, validate if subinventory and locator match
                -- that from mtl_serial_numbers.
                IF (p_x_ahl_mtltxn_rec.Serial_Number IS NOT NULL) AND
                   (p_x_ahl_mtltxn_rec.Serial_Number <> FND_API.G_MISS_CHAR) AND
                   (nvl(l_serial_Control,0) <> 1) AND
                   (p_x_ahl_mtltxn_rec.Transaction_Type_Id = WIP_CONSTANTS.ISSCOMP_TYPE) THEN
                   OPEN mtl_srl_num_csr(p_x_ahl_mtltxn_rec.Organization_ID,
                                        p_x_ahl_mtltxn_rec.Inventory_Item_id,
                                        p_x_ahl_mtltxn_rec.Serial_Number);
                   FETCH mtl_srl_num_csr INTO l_curr_subinventory_code, l_curr_locator_id;
                   IF (mtl_srl_num_csr%FOUND) THEN

                 IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('Validating serial subinv['||p_x_ahl_mtltxn_rec.subinventory_Name||']');
                     END IF;

                     IF (p_x_ahl_mtltxn_rec.subinventory_Name IS NOT NULL AND
                         p_x_ahl_mtltxn_rec.subinventory_Name <> FND_API.G_MISS_CHAR AND
                         p_x_ahl_mtltxn_rec.subinventory_Name <> l_curr_subinventory_code) THEN
                             FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_SUB_CODE');
                             FND_MESSAGE.Set_Token('CODE',l_curr_subinventory_code);
                             FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
                             FND_MESSAGE.Set_Token('SER',p_x_ahl_mtltxn_rec.Serial_Number);
                             FND_MSG_PUB.ADD;
                             x_return_status := FND_API.G_RET_STS_ERROR;
                     END IF;

                 IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('Validating serial subinv['||p_x_ahl_mtltxn_rec.subinventory_Name||']');
                     END IF;

                     IF (p_x_ahl_mtltxn_rec.locator_id IS NOT NULL AND
                         p_x_ahl_mtltxn_rec.locator_id <> FND_API.G_MISS_NUM AND
                         l_curr_locator_id IS NOT NULL AND
                         p_x_ahl_mtltxn_rec.locator_id <> l_curr_locator_id) THEN
                           FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_LOC_CODE');
                           --FND_MESSAGE.Set_Token('CODE',l_curr_locator_id);
                           FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
                           FND_MESSAGE.Set_Token('SER',p_x_ahl_mtltxn_rec.Serial_Number);
                           FND_MSG_PUB.ADD;
                           x_return_status := FND_API.G_RET_STS_ERROR;
                     END IF;
                   ELSE
                     -- serial number not found.
                     FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_SRLNUM');
                     FND_MESSAGE.Set_Token('ITEM',l_concatenated_segments);
                     FND_MESSAGE.Set_Token('SER',p_x_ahl_mtltxn_rec.Serial_Number);
                     FND_MSG_PUB.ADD;
                     x_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;

                   CLOSE mtl_srl_num_csr;
                END IF;

            IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.debug('Validating transaction date['||p_x_ahl_mtltxn_rec.transaction_date||']');
            END IF;

                -- Validate transaction date.
                IF (p_x_ahl_mtltxn_rec.transaction_date IS NULL OR
                    p_x_ahl_mtltxn_rec.transaction_date = FND_API.G_MISS_DATE) THEN
                   p_x_ahl_mtltxn_rec.transaction_date := SYSDATE;
                /*
                * defaulting the time component to 23:59:59(for past dates) and systime for current date to fix bug#4096941
                */
                ELSIF(trunc(p_x_ahl_mtltxn_rec.transaction_date) = trunc(SYSDATE))THEN
                   p_x_ahl_mtltxn_rec.transaction_date := SYSDATE;
                ELSIF(trunc(p_x_ahl_mtltxn_rec.transaction_date) < trunc(SYSDATE))THEN
                   p_x_ahl_mtltxn_rec.transaction_date := trunc(p_x_ahl_mtltxn_rec.transaction_date) + 86399/86400;
                ELSE
                   IF (p_x_ahl_mtltxn_rec.transaction_date > SYSDATE) THEN

                     IF G_DEBUG='Y' THEN
                      AHL_DEBUG_PUB.debug('Error in txn date');
                     END IF;
                     FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_TXN_DATE');
                     FND_MESSAGE.Set_Token('DATE',p_x_ahl_mtltxn_rec.transaction_date);
                     FND_MSG_PUB.ADD;
                     x_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;

                END IF;
                /*
                * adding release date validation(txns date should be > release date) to fix bug#4096941
                */
                OPEN workorder_released_date_csr(p_x_ahl_mtltxn_rec.Wip_Entity_Id);
                FETCH workorder_released_date_csr INTO l_workorder_released_date;
                IF(workorder_released_date_csr%NOTFOUND)THEN
                  FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_WIP_ENTITY');
                  IF(p_x_ahl_mtltxn_rec.Wip_Entity_Id = FND_API.G_MISS_NUM) THEN
                     p_x_ahl_mtltxn_rec.Wip_Entity_Id := NULL;
                  END IF;
                  FND_MESSAGE.Set_Token('WIP_ENTITY',p_x_ahl_mtltxn_rec.Wip_Entity_Id);
                  FND_MSG_PUB.ADD;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                ELSE
                  IF G_DEBUG='Y' THEN
                       AHL_DEBUG_PUB.debug('transaction date['||to_char(p_x_ahl_mtltxn_rec.transaction_date,'dd-mon-yyyy hh24:mi:ss') ||']');
                       AHL_DEBUG_PUB.debug('workorder release date['||to_char(l_workorder_released_date,'dd-mon-yyyy hh24:mi:ss') ||']');
                   END IF;
                  IF(l_workorder_released_date > p_x_ahl_mtltxn_rec.transaction_date)THEN
                    IF G_DEBUG='Y' THEN
                       AHL_DEBUG_PUB.debug('release date is greater than transaction date');
                     END IF;
                    FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_TXN_REL_DT');
                    FND_MESSAGE.Set_Token('TXNS_DATE',to_char(p_x_ahl_mtltxn_rec.transaction_date,'dd-MON-yyyy hh24:mi:ss'));
                    FND_MESSAGE.Set_Token('REL_DATE',to_char(l_workorder_released_date,'dd-MON-yyyy hh24:mi:ss'));
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
                END IF;
                CLOSE workorder_released_date_csr;

      -- validate disposition ID.
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string
		 (
                   G_LEVEL_STATEMENT,
		   'ahl.plsql.AHL_PRD_MTLTXN_PVT.Validate_Txn_Rec',
		   'Validating disposition ID'
		 );
      END IF;

      -- validate disposition id.
      IF (p_x_ahl_mtltxn_rec.disposition_id IS NOT NULL AND
          p_x_ahl_mtltxn_rec.disposition_id <> FND_API.G_MISS_NUM) THEN

         -- chk if disposition exists.
         OPEN disposition_cur (  p_x_ahl_mtltxn_rec.disposition_id,
                                 p_x_ahl_mtltxn_rec.workorder_id,
                                 p_x_ahl_mtltxn_rec.Inventory_Item_id,
                                 --p_x_ahl_mtltxn_rec.Organization_ID,
                                 p_x_ahl_mtltxn_rec.Serial_Number,
                                 p_x_ahl_mtltxn_rec.Revision,
                                 p_x_ahl_mtltxn_rec.Lot_Number);
         FETCH disposition_cur INTO l_disposition_id;
         IF (disposition_cur%NOTFOUND) THEN
           FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTL_DISP_INVALID');
           FND_MESSAGE.Set_Token('DISP_ID',p_x_ahl_mtltxn_rec.disposition_id);
           FND_MSG_PUB.ADD;
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
         CLOSE disposition_cur;
      END IF; -- -- p_x_ahl_mtltxn_rec.disposition_id

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string
		 (
                   G_LEVEL_STATEMENT,
		   'ahl.plsql.AHL_PRD_MTLTXN_PVT.Validate_Txn_Rec',
		   'Disposition ID:' || p_x_ahl_mtltxn_rec.disposition_id
		 );
      END IF;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('after validations api ret_status['||x_return_status||']');

        END IF;


END VALIDATE_TXN_REC;

/********************************************************************************
This procedure will process the material tranasction record. The records are
inserted into interface tables and the API is called to process the transaction.

********************************************************************************/

/* Tamal [R12 APPSPERF fixes]
 * R12 Drop 4 - SQL ID: 14400039
 * Bug #4918991
 * Since the following procedure has no functional footprint at the moment, commenting out the procedure
 * Additionally marking the SQL ID as Obsolete in sql_repos...
 */

/*
PROCEDURE INSERT_MTL_TXN_TEMP
    (
        p_api_version        IN            NUMBER     := 1.0,
        p_init_msg_list      IN            VARCHAR2   := FND_API.G_FALSE,
        p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
        p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
        p_default            IN            VARCHAR2   := FND_API.G_FALSE,
        p_module_type        IN            VARCHAR2   := NULL,
        p_x_ahl_mtltxn_rec   IN OUT NOCOPY Ahl_Mtltxn_Rec_Type,
        x_txn_Hdr_Id         OUT NOCOPY        NUMBER,
        x_txn_Tmp_id         OUT NOCOPY        NUMBER,
        x_return_status      OUT NOCOPY           VARCHAR2,
        x_msg_count          OUT NOCOPY           NUMBER,
        x_msg_data           OUT NOCOPY           VARCHAR2
    )
IS
l_Process_Flag VARCHAR2(1);
l_Validation_required VARCHAR2(1);
l_txn_action NUMBER;
l_txn_source_type NUMBER;
l_transaction_Mode NUMBER;
l_Srl_Txn_Tmp_Id   NUMBER;
l_mmtt_rec mtl_material_transactions_temp%ROWTYPE;
l_msnt_rec mtl_serial_numbers_temp%ROWTYPE;
l_mtlt_rec mtl_transaction_lots_temp%ROWTYPE;

l_transaction_reference mtl_material_transactions_temp.transaction_reference%TYPE;

CURSOR ACCT_PERIOD_CUR(P_org_Id NUMBER) IS
SELECT ACCT_PERIOD_ID from org_acct_periods
where organization_id = p_org_id and open_flag = 'Y'
AND TRUNC(SYSDATE) BETWEEN TRUNC(PERIOD_START_DATE) AND TRUNC(SCHEDULE_CLOSE_DATE);

CURSOR TRX_ACTION_CUR(p_type_Id NUMBER) IS
SELECT TRANSACTION_ACTION_ID,TRANSACTION_SOURCE_TYPE_ID
from MTL_TRANSACTION_TYPES
where TRANSACTION_TYPE_ID = p_type_Id;

BEGIN
    l_Process_Flag := 'W';
    l_Validation_required  := '1';
    l_transaction_Mode := 2;
    l_txn_action := 1;

    OPEN ACCT_PERIOD_CUR(p_x_ahl_mtltxn_rec.Organization_Id);
    FETCH ACCT_PERIOD_CUR INTO l_mmtt_rec.ACCT_PERIOD_ID;
    IF(ACCT_PERIOD_CUR%NOTFOUND) THEN
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Did not find the account period for org('||p_x_ahl_mtltxn_rec.Organization_Id||')');

    END IF;
        CLOSE ACCT_PERIOD_CUR;
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE ACCT_PERIOD_CUR;

    OPEN TRX_ACTION_CUR(p_x_ahl_mtltxn_rec.Transaction_Type_Id);
    FETCH TRX_ACTION_CUR INTO l_txn_action, l_txn_source_type;
    IF(TRX_ACTION_CUR%NOTFOUND) THEN
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Did not find the Txn Type');

    END IF;
        CLOSE TRX_ACTION_CUR;
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE TRX_ACTION_CUR;

    l_mmtt_rec.SOURCE_CODE := 'AHL' ;
    l_mmtt_rec.SOURCE_LINE_ID := 1;
    l_mmtt_rec.TRANSACTION_MODE := l_transaction_Mode;

        IF (p_x_ahl_mtltxn_rec.transaction_reference = FND_API.G_MISS_CHAR) THEN
           l_transaction_reference := NULL;
        ELSE
           l_transaction_reference := p_x_ahl_mtltxn_rec.transaction_reference;
        END IF;

    l_mmtt_rec.LOCK_FLAG := '';
    l_mmtt_rec.LAST_UPDATE_DATE := SYSDATE;
    l_mmtt_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID; --p_x_ahl_mtltxn_rec.Last_Updated_By;
    l_mmtt_rec.CREATION_DATE := SYSDATE;
    l_mmtt_rec.CREATED_BY := FND_GLOBAL.USER_ID; --p_x_ahl_mtltxn_rec.Last_Updated_By;
    l_mmtt_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID; --p_x_ahl_mtltxn_rec.Last_Update_Login;
    --l_mmtt_rec.PROGRAM_APPLICATION_ID :=
    --l_mmtt_rec.PROGRAM_ID :=
    --l_mmtt_rec.PROGRAM_UPDATE_DATE :=
    l_mmtt_rec.INVENTORY_ITEM_ID := p_x_ahl_mtltxn_rec.Inventory_Item_Id;
    if(p_x_ahl_mtltxn_rec.Revision IS NOT NULL
        AND p_x_ahl_mtltxn_rec.Revision <> FND_API.G_MISS_CHAR) THEN
        l_mmtt_rec.REVISION := p_x_ahl_mtltxn_rec.Revision;
    END IF;
    l_mmtt_rec.ORGANIZATION_ID := p_x_ahl_mtltxn_rec.Organization_Id;
    l_mmtt_rec.SUBINVENTORY_CODE := p_x_ahl_mtltxn_rec.Subinventory_Name;
    IF(p_x_ahl_mtltxn_rec.Locator_Id IS NOT NULL
        AND p_x_ahl_mtltxn_rec.Locator_Id <> FND_API.G_MISS_NUM) THEN
        l_mmtt_rec.LOCATOR_ID := p_x_ahl_mtltxn_rec.Locator_Id;
    END IF;
    if(p_x_ahl_mtltxn_rec.Transaction_Type_Id = WIP_CONSTANTS.ISSCOMP_TYPE) THEN
        l_mmtt_rec.TRANSACTION_QUANTITY := - p_x_ahl_mtltxn_rec.Quantity;
        l_mmtt_rec.PRIMARY_QUANTITY :=  - p_x_ahl_mtltxn_rec.Quantity;
    ELSE
        l_mmtt_rec.TRANSACTION_QUANTITY := p_x_ahl_mtltxn_rec.Quantity;
        l_mmtt_rec.PRIMARY_QUANTITY := p_x_ahl_mtltxn_rec.Quantity;
    END IF;
    l_mmtt_rec.TRANSACTION_UOM := p_x_ahl_mtltxn_rec.Uom;
    l_mmtt_rec.TRANSACTION_TYPE_ID := p_x_ahl_mtltxn_rec.Transaction_Type_Id;
    l_mmtt_rec.TRANSACTION_ACTION_ID :=l_txn_action;
    l_mmtt_rec.TRANSACTION_SOURCE_TYPE_ID := l_txn_source_type;
    l_mmtt_rec.TRANSACTION_DATE := p_x_ahl_mtltxn_rec.Transaction_Date;
    --l_mmtt_rec.ACCT_PERIOD_ID := 2266;
    l_mmtt_rec.TRANSACTION_SOURCE_ID := p_x_ahl_mtltxn_rec.Wip_Entity_Id;
--      l_mmtt_rec.DISTRIBUTION_ACCOUNT_ID :=
    l_mmtt_rec.TRANSACTION_REFERENCE := l_transaction_reference;
--      l_mmtt_rec.REQUISITION_LINE_ID :=
--      l_mmtt_rec.REQUISITION_DISTRIBUTION_ID :=
    IF(p_x_ahl_mtltxn_rec.Reason_Id IS NOT NULL
        AND p_x_ahl_mtltxn_rec.Reason_Id <> FND_API.G_MISS_NUM) THEN
        l_mmtt_rec.REASON_ID :=p_x_ahl_mtltxn_rec.Reason_Id;
    END IF;
    --l_mmtt_rec.LOT_NUMBER := p_lot_number;
    --l_mmtt_rec.LOT_EXPIRATION_DATE :=
    --l_mmtt_rec.SERIAL_NUMBER := p_srl_number;
    l_mmtt_rec.WIP_ENTITY_TYPE := WIP_CONSTANTS.DISCRETE;
    l_mmtt_rec.WIP_SUPPLY_TYPE := 3;
    l_mmtt_rec.OPERATION_SEQ_NUM := p_x_ahl_mtltxn_rec.Operation_Seq_Num;
    --l_mmtt_rec.ITEM_LOCATION_CONTROL_CODE :=
    l_mmtt_rec.PROCESS_FLAG := l_Process_Flag;
    IF(p_x_ahl_mtltxn_rec.ATTRIBUTE_CATEGORY IS NOT NULL
        AND p_x_ahl_mtltxn_rec.ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR) THEN
        l_mmtt_rec.ATTRIBUTE_CATEGORY := p_x_ahl_mtltxn_rec.ATTRIBUTE_CATEGORY;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE1 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE1 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE1         := p_x_ahl_mtltxn_rec.ATTRIBUTE1;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE2 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE2 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE2         := p_x_ahl_mtltxn_rec.ATTRIBUTE2;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE3 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE3 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE3         := p_x_ahl_mtltxn_rec.ATTRIBUTE3;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE4 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE4 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE4         := p_x_ahl_mtltxn_rec.ATTRIBUTE4;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE5 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE5 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE5         := p_x_ahl_mtltxn_rec.ATTRIBUTE5;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE6 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE6 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE6         := p_x_ahl_mtltxn_rec.ATTRIBUTE6;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE7 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE7 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE7         := p_x_ahl_mtltxn_rec.ATTRIBUTE7;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE8 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE8 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE8         := p_x_ahl_mtltxn_rec.ATTRIBUTE8;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE9 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE9 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE9         := p_x_ahl_mtltxn_rec.ATTRIBUTE9;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE10 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE10 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE10        := p_x_ahl_mtltxn_rec.ATTRIBUTE10;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE11 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE11 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE11        := p_x_ahl_mtltxn_rec.ATTRIBUTE11;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE12 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE12 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE12        := p_x_ahl_mtltxn_rec.ATTRIBUTE12;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE13 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE13 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE13        := p_x_ahl_mtltxn_rec.ATTRIBUTE13;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE14 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE14 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE14        := p_x_ahl_mtltxn_rec.ATTRIBUTE14;
        END IF;
        IF(p_x_ahl_mtltxn_rec.ATTRIBUTE15 IS NOT NULL
            AND p_x_ahl_mtltxn_rec.ATTRIBUTE15 <> FND_API.G_MISS_CHAR) THEN
            l_mmtt_rec.ATTRIBUTE15        := p_x_ahl_mtltxn_rec.ATTRIBUTE15;
        END IF;
    END IF;

    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('inserting the mmtt..');
    END IF;

    inv_util.insert_mmtt(p_api_version => 1,
                        p_mmtt_rec =>l_mmtt_rec,
                        x_trx_header_id => x_Txn_hdr_id,
                        x_trx_temp_id => x_Txn_Tmp_Id,
                        x_return_status => x_return_status,
                        x_msg_count =>x_msg_count,
                        x_msg_data => x_msg_data);

    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('inserted in mmtt..ret_status['||x_return_status||']');
    END IF;
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTLTXN_ERROR');
        FND_MESSAGE.Set_Token('MSG',x_msg_data);
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
    END  IF;

    IF(p_x_ahl_mtltxn_rec.Lot_Number <> FND_API.G_MISS_CHAR AND
        p_x_ahl_mtltxn_rec.Lot_Number IS NOT NULL AND
        p_x_ahl_mtltxn_rec.Serial_Number <> FND_API.G_MISS_CHAR AND
        p_x_ahl_mtltxn_rec.Serial_Number IS NOT NULL) THEN

        --Item is under Lot and Serial Control
        --Generate serial transaction Temp id.
        SELECT Mtl_Material_Transactions_S.nextval
        INTO l_Srl_Txn_Tmp_Id
        FROM DUAL;



        l_mtlt_rec.Transaction_Temp_Id  := x_Txn_Tmp_Id;
        l_mtlt_rec.Serial_Transaction_Temp_Id:= l_Srl_Txn_Tmp_Id;
        l_mtlt_rec.Lot_Number                 := p_x_ahl_mtltxn_rec.Lot_Number;

        -- Lot expiration date needs to  be selected.

        --l_mtlt_rec.Lot_Expiration_Date          := p_x_ahl_mtltxn_rec.Lot_Expiration_Date;
        l_mtlt_rec.Transaction_Quantity   := p_x_ahl_mtltxn_rec.Quantity;
        l_mtlt_rec.Primary_Quantity   := p_x_ahl_mtltxn_rec.Quantity;

        l_mtlt_rec.LAST_UPDATE_DATE := SYSDATE;
        l_mtlt_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID; --p_x_ahl_mtltxn_rec.Last_Updated_By;
        l_mtlt_rec.CREATION_DATE := SYSDATE;
        l_mtlt_rec.CREATED_BY := FND_GLOBAL.USER_ID; --p_x_ahl_mtltxn_rec.Last_Updated_By;
        l_mtlt_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID; --p_x_ahl_mtltxn_rec.Last_Update_Login;

        l_msnt_rec.Transaction_Temp_Id := l_Srl_Txn_Tmp_Id;
        l_msnt_rec.Fm_Serial_Number    := p_x_ahl_mtltxn_rec.Serial_Number;
        l_msnt_rec.To_Serial_Number    := p_x_ahl_mtltxn_rec.Serial_Number;
        l_msnt_rec.LAST_UPDATE_DATE := SYSDATE;
        l_msnt_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID; --p_x_ahl_mtltxn_rec.Last_Updated_By;
        l_msnt_rec.CREATION_DATE := SYSDATE;
        l_msnt_rec.CREATED_BY := FND_GLOBAL.USER_ID; --p_x_ahl_mtltxn_rec.Last_Updated_By;
        l_msnt_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID; --p_x_ahl_mtltxn_rec.Last_Update_Login;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('inserting  in mtlt..');
    END IF;

        inv_util.insert_mtlt(p_api_version => 1,
                        p_mtlt_rec =>l_mtlt_rec,
                        x_return_status => x_return_status,
                        x_msg_count =>x_msg_count,
                        x_msg_data => x_msg_data);
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('inserted in mtlt..ret_status['||x_return_status||']');
    END IF;
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTLTXN_ERROR');
            FND_MESSAGE.Set_Token('MSG',x_msg_data);
            FND_MSG_PUB.ADD;
            RAISE  FND_API.G_EXC_ERROR;
        END  IF;
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('inserting  in msnt..');

    END IF;
        inv_util.insert_msnt(p_api_version => 1,
                        p_msnt_rec =>l_msnt_rec,
                        x_return_status => x_return_status,
                        x_msg_count =>x_msg_count,
                        x_msg_data => x_msg_data);

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('inserted in msnt..ret_status['||x_return_status||']');

    END IF;

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTLTXN_ERROR');
            FND_MESSAGE.Set_Token('MSG',x_msg_data);
            FND_MSG_PUB.ADD;
            RAISE  FND_API.G_EXC_ERROR;
        END  IF;

    ELSIF (p_x_ahl_mtltxn_rec.Lot_Number <> FND_API.G_MISS_CHAR AND
       p_x_ahl_mtltxn_rec.Lot_Number IS NOT NULL ) THEN
            --Item is under Lot control
            l_mtlt_rec.Transaction_Temp_Id        := x_Txn_Tmp_Id;
            l_mtlt_rec.Lot_Number                 := p_x_ahl_mtltxn_rec.Lot_Number;
            --l_mtlt_rec.Lot_Expiration_Date          := p_x_ahl_mtltxn_rec.Lot_Expiration_Date;
            l_mtlt_rec.Transaction_Quantity       := p_x_ahl_mtltxn_rec.Quantity;
            l_mtlt_rec.Primary_Quantity       := p_x_ahl_mtltxn_rec.Quantity;
            l_mtlt_rec.LAST_UPDATE_DATE := SYSDATE;
            l_mtlt_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID; --p_x_ahl_mtltxn_rec.Last_Updated_By;
            l_mtlt_rec.CREATION_DATE := SYSDATE;
            l_mtlt_rec.CREATED_BY := FND_GLOBAL.USER_ID; --p_x_ahl_mtltxn_rec.Last_Updated_By;
            l_mtlt_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID; --p_x_ahl_mtltxn_rec.Last_Update_Login;

            IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('inserting  in mtlt..');

    END IF;
            inv_util.insert_mtlt(p_api_version => 1,
                            p_mtlt_rec =>l_mtlt_rec,
                            x_return_status => x_return_status,
                            x_msg_count =>x_msg_count,
                            x_msg_data => x_msg_data);
            IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('inserted in mtlt..ret_status['||x_return_status||']');

    END IF;
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTLTXN_ERROR');
                FND_MESSAGE.Set_Token('MSG',x_msg_data);
                FND_MSG_PUB.ADD;
                RAISE  FND_API.G_EXC_ERROR;
            END  IF;

    ELSIF (p_x_ahl_mtltxn_rec.Serial_Number <> FND_API.G_MISS_CHAR AND
            p_x_ahl_mtltxn_rec.Serial_Number IS NOT NULL) THEN
            -- Item is under serial control
            l_msnt_rec.Transaction_Temp_Id      := x_Txn_Tmp_Id;
            l_msnt_rec.Fm_Serial_Number         := p_x_ahl_mtltxn_rec.Serial_Number;
            l_msnt_rec.To_Serial_Number         := p_x_ahl_mtltxn_rec.Serial_Number;
            l_msnt_rec.LAST_UPDATE_DATE := SYSDATE;
            l_msnt_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID; --p_x_ahl_mtltxn_rec.Last_Updated_By;
            l_msnt_rec.CREATION_DATE := SYSDATE;
            l_msnt_rec.CREATED_BY := FND_GLOBAL.USER_ID; --p_x_ahl_mtltxn_rec.Last_Updated_By;
            l_msnt_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID; --p_x_ahl_mtltxn_rec.Last_Update_Login;

            IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('inserting  in msnt..');

    END IF;

            inv_util.insert_msnt(p_api_version => 1,
                                        p_msnt_rec =>l_msnt_rec,
                                        x_return_status => x_return_status,
                                        x_msg_count =>x_msg_count,
                                        x_msg_data => x_msg_data);
            IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('inserted in msnt..ret_status['||x_return_status||']');

    END IF;

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTLTXN_ERROR');
                FND_MESSAGE.Set_Token('MSG',x_msg_data);
                FND_MSG_PUB.ADD;
                RAISE  FND_API.G_EXC_ERROR;
            END  IF;
    END IF;
END INSERT_MTL_TXN_TEMP;
*/

/*****************************************************************
This function returns true if the item is trackable and false if not.

******************************************************************/
FUNCTION IS_ITEM_TRACKABLE(p_Org_Id IN NUMBER, p_Item_Id IN NUMBER) RETURN BOOLEAN
IS
l_count NUMBER;
ret boolean;
-- Query to check if item is trakkable
CURSOR Item_tr_Cur(p_org_Id NUMBER, p_item_Id NUMBER) IS
    SELECT 1
    FROM MTL_SYSTEM_ITEMS_B
    WHERE INVENTORY_ITEM_ID = p_Item_Id
    AND ORGANIZATION_ID = p_Org_Id
    AND COMMS_NL_TRACKABLE_FLAG = 'Y'
    AND ENABLED_FLAG = 'Y'
    AND ((START_DATE_ACTIVE IS NULL) OR (START_DATE_ACTIVE <= SYSDATE))
    AND ((END_DATE_ACTIVE IS NULL) OR (END_DATE_ACTIVE >= SYSDATE));

BEGIN

    l_Count := 0;
    ret := FALSE;
    OPEN Item_Tr_Cur(p_org_Id, p_item_Id);
    FETCH Item_Tr_Cur into l_Count;
    IF (Item_Tr_Cur%NOTFOUND) THEN
        ret := FALSE;
    ELSE
        ret := TRUE;
    END IF;

    CLOSE Item_Tr_Cur;
    RETURN ret;
END IS_ITEM_TRACKABLE;

/***************************************************
This procedure inserts record in the AHL_SCHEDULE_MATERIALS table
TBD to be corrected.
************************************************/
PROCEDURE Insert_Sch_Mtl_Row(
    p_mtl_txn_Rec        IN            Ahl_Mtltxn_Rec_Type,
    x_return_status      OUT NOCOPY           VARCHAR2,
    x_msg_count          OUT NOCOPY           NUMBER,
    x_msg_data           OUT NOCOPY           VARCHAR2,
    x_ahl_sch_mtl_id     OUT NOCOPY        NUMBER)
IS
Material_Tbl AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type ;
x_tmp VARCHAR2(10);
l_project_id NUMBER;
l_project_Task_id NUMBER ;
l_Visit_Id NUMBER;
l_visit_task_Id NUMBER;
l_Item_Desc VARCHAR2(240);
l_quantity  NUMBER;
l_primary_uom  ahl_schedule_materials.UOM%TYPE;

-- QWuey to select the work order dependent data to be passed to Schedule materials API.
CURSOR Workop_Det_Cur(p_wo_id NUMBER) IS
SELECT B.VISIT_ID,C.VISIT_TASK_ID,B.PROJECT_ID,C.PROJECT_TASK_ID
FROM AHL_WORKORDERS A, AHL_VISITS_B B, AHL_VISIT_TASKS_B C
WHERE A.WORKORDER_ID = p_wo_id
AND A.VISIT_TASK_ID = C.VISIT_TASK_ID
AND C.VISIT_ID = B.VISIT_ID;
--Query to select the item desccription
CURSOR Item_Desc_Cur(p_org_id NUMBER, p_item_id NUMBER) IS
SELECT DESCRIPTION
FROM MTL_SYSTEM_ITEMS_KFV
WHERE ORGANIZATION_ID = p_org_id
AND INVENTORY_ITEM_ID = p_item_id;

BEGIN

    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Entered Insert_Sch_Mtl_Row');

    END IF;
    OPEN Workop_Det_Cur( p_mtl_txn_Rec.Workorder_Id);
    FETCH Workop_Det_Cur INTO l_Visit_Id,l_visit_task_Id,l_project_id,l_project_Task_id;
    IF(Workop_Det_Cur%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_WO_OP');
        FND_MSG_PUB.ADD;
        CLOSE Workop_Det_Cur;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    CLOSE Workop_Det_Cur;
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Selected the work order paramters');
          AHL_DEBUG_PUB.debug('l_Visit_Id['||l_Visit_Id||']');
          AHL_DEBUG_PUB.debug('l_visit_task_Id['||l_visit_task_Id||']');
          AHL_DEBUG_PUB.debug('l_project_id['||l_project_id||']');
          AHL_DEBUG_PUB.debug('l_project_Task_id['||l_project_Task_id||']');
          AHL_DEBUG_PUB.debug('p_mtl_txn_Rec.Workorder_Operation_Id['||p_mtl_txn_Rec.Workorder_Operation_Id||']');

    END IF;

    OPEN Item_Desc_Cur( p_mtl_txn_Rec.Organization_id, p_mtl_txn_Rec.Inventory_Item_Id);
    FETCH Item_Desc_Cur INTO l_Item_Desc;
    IF(Item_Desc_Cur%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_COM_INVALID_ITEM');
        FND_MESSAGE.Set_Token('FIELD',p_mtl_txn_Rec.Inventory_Item_Id);
        FND_MSG_PUB.ADD;
        CLOSE Item_Desc_Cur;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    CLOSE Item_Desc_Cur;
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Selected the Item description');

    END IF;

        -- Get Primary UOM for the item.
        l_primary_uom := AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM(p_inventory_item_id => p_mtl_txn_Rec.Inventory_Item_Id,
                                                     p_inventory_org_id => p_mtl_txn_Rec.Organization_id);

        l_quantity :=  p_mtl_txn_Rec.Quantity;
        -- Convert quantity to primary UOM if p_mtl_txn_Rec.uom is not.
        IF (l_primary_uom <> p_mtl_txn_Rec.uom) THEN
          l_quantity := AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM_Qty(p_mtl_txn_Rec.Inventory_Item_Id,
                                    p_mtl_txn_Rec.uom,
                                p_mtl_txn_Rec.Quantity);
        END IF;

    --Material_Tbl(0).OBJECT_VERSION_NUMBER   := 1;
    Material_Tbl(0).INVENTORY_ITEM_ID       := p_mtl_txn_Rec.Inventory_Item_Id;
    --Material_Tbl(0).SCHEDULE_DESIGNATOR   :=
    Material_Tbl(0).VISIT_ID                := l_Visit_Id;
    --Material_Tbl(0).VISIT_START_DATE      :=
    Material_Tbl(0).VISIT_TASK_ID           := l_visit_task_Id;
    Material_Tbl(0).ORGANIZATION_ID         := p_mtl_txn_Rec.Organization_Id;
    --Material_Tbl(0).SCHEDULED_DATE        :=
    --Material_Tbl(0).REQUEST_ID            :=
    --Material_Tbl(0).PROCESS_STATUS        :=
    --Material_Tbl(0).ERROR_MESSAGE         :=
    --Material_Tbl(0).TRANSACTION_ID        :=
    --Material_Tbl(0).CONCATENATED_SEGMENTS   :=
    --Material_Tbl(0).ITEM_DESCRIPTION      :=
    --Material_Tbl(0).RT_OPER_MATERIAL_ID   :=
    -- Fix bug# 6598809. Pass requested quantity as 0.
    --Material_Tbl(0).REQUESTED_QUANTITY      := l_quantity;
    Material_Tbl(0).REQUESTED_QUANTITY      := 0;
    Material_Tbl(0).REQUESTED_DATE          := SYSDATE;
    Material_Tbl(0).UOM_CODE    := l_primary_Uom;
    --Material_Tbl(0).SCHEDULED_QUANTITY    := ;
    --Material_Tbl(0).JOB_NUMBER            :=
    Material_Tbl(0).WORKORDER_ID            := p_mtl_txn_Rec.Workorder_Id;
    Material_Tbl(0).OPERATION_SEQUENCE      := p_mtl_txn_Rec.Operation_Seq_Num;
    Material_Tbl(0).WORKORDER_OPERATION_ID  := p_mtl_txn_Rec.Workorder_Operation_Id;
    --Material_Tbl(0).ITEM_GROUP_ID         :=
    --Material_Tbl(0).PROGRAM_ID            :=
    --Material_Tbl(0).PROGRAM_UPDATE_DATE   :=
    --Material_Tbl(0).LAST_UPDATED_DATE     := SYSDATE;
    Material_Tbl(0).DESCRIPTION             := l_Item_Desc;
    --Material_Tbl(0).DEPARTMENT_ID         :=
    Material_Tbl(0).PROJECT_TASK_ID         := l_project_Task_id;
    Material_Tbl(0).PROJECT_ID              := l_project_id;
    --Material_Tbl(0).Req_Material_Rec_Type  :=


    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Calling AHL_PP_MATERIALS_PVT.Create_Material_Reqst...');

    END IF;
     AHL_PP_MATERIALS_PVT.Create_Material_Reqst(p_api_version => 1.0,
                                                p_x_req_material_tbl  => Material_Tbl,
                                                --p_interface_flag  => 'N',
                                                p_interface_flag  => NULL,
                                                x_job_return_status => x_tmp,
                                                x_return_status     => x_return_status,
                                                x_msg_count         => x_msg_count,
                                                x_msg_data          => x_msg_data);
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('after the call AHL_PP_MATERIALS_PVT.Create_Material_Reqst');

    END IF;
    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('x_return_status['||x_return_status||']');
          AHL_DEBUG_PUB.debug('x_msg_data['||x_msg_data||']');

    END IF;
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_SCHMTLAPI_ERROR');
        FND_MESSAGE.Set_Token('MSG',x_msg_data);
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_ERROR;
    END  IF;

    /* will be updated after wip api is successful - modified for bug fix 5499575.
        -- Update Completed quantity.
        Update ahl_schedule_materials
        set completed_quantity = l_quantity
        where scheduled_material_id = Material_Tbl(0).schedule_material_id;
    */

END Insert_Sch_Mtl_Row;


/****************************************************
This procedure will create the service API record from the input material txn
record data.
*****************************************************/
PROCEDURE Populate_Srvc_Rec(
        p_item_instance_id  NUMBER,
        p_srvc_rec OUT NOCOPY AHL_PRD_NONROUTINE_PVT.Sr_task_Rec_type,
        p_x_ahl_mtltxn_rec IN Ahl_Mtltxn_Rec_Type)
IS

BEGIN


    --p_srvc_rec.TYPE_ID           := FND_PROFILE.value(C_AHL_DEF_SR_TYPE);
    p_srvc_rec.SUMMARY             := p_x_ahl_mtltxn_rec.SR_SUMMARY;
    --p_srvc_rec.CONTACT_TYPE      := 'EMPLOYEE';
    p_srvc_rec.PROBLEM_CODE    := p_x_ahl_mtltxn_rec.Problem_Code;
    p_srvc_rec.VISIT_ID        := p_x_ahl_mtltxn_rec.Target_Visit_Id;
    --p_srvc_rec.DURATION          := FND_PROFILE.value(C_AHL_DEF_TASK_EST_DURATION);
    p_srvc_rec.INSTANCE_ID      := p_item_instance_id;
    p_srvc_rec.ORIGINATING_WO_ID  := p_x_ahl_mtltxn_rec.Workorder_Id;
    p_srvc_rec.OPERATION_TYPE  := 'CREATE';
    p_srvc_rec.source_program_code  := 'AHL_NONROUTINE';

    -- set create wo option.
    IF (p_x_ahl_mtltxn_rec.create_wo_option = 'CREATE_RELEASE_WO') THEN
        p_srvc_rec.WO_Create_flag := 'Y';
        p_srvc_rec.WO_Release_flag := 'Y';
    ELSIF (p_x_ahl_mtltxn_rec.create_wo_option = 'CREATE_WO') THEN
        p_srvc_rec.WO_Create_flag := 'Y';
        p_srvc_rec.WO_Release_flag := 'N';
    ELSIF (p_x_ahl_mtltxn_rec.create_wo_option = 'CREATE_WO_NO') THEN
        p_srvc_rec.WO_Create_flag := 'N';
        p_srvc_rec.WO_Release_flag := 'N';
    END IF;
    -- End: Added for bug# 5903318.

    -- Added for ER#
    p_srvc_rec.move_qty_to_nr_workorder := 'N';
    p_srvc_rec.instance_quantity := p_x_ahl_mtltxn_rec.quantity;


    IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('p_srvc_rec.SUMMARY['||p_srvc_rec.SUMMARY||']');
          AHL_DEBUG_PUB.debug('PROBLEM_CODE['||p_srvc_rec.PROBLEM_CODE||']');
          AHL_DEBUG_PUB.debug('p_srvc_rec.VISIT_ID['||p_srvc_rec.VISIT_ID||']');
          AHL_DEBUG_PUB.debug('p_srvc_rec.INSTANCE_ID['||p_srvc_rec.INSTANCE_ID||']');
          AHL_DEBUG_PUB.debug('p_srvc_rec.ORIGINATING_WO_ID['||p_srvc_rec.ORIGINATING_WO_ID||']');
          AHL_DEBUG_PUB.debug('p_srvc_rec.WO_Create_flag['||p_srvc_rec.WO_Create_flag||']');
          AHL_DEBUG_PUB.debug('p_srvc_rec.WO_Release_flag['||p_srvc_rec.WO_Release_flag||']');
          AHL_DEBUG_PUB.debug('p_srvc_rec.instance_quantity['||p_srvc_rec.instance_quantity||']');
          AHL_DEBUG_PUB.debug('p_srvc_rec.move_qty_to_nr_workorder['||p_srvc_rec.move_qty_to_nr_workorder||']');

    END IF;


END Populate_Srvc_Rec;

/*********************************************************************
This procedure will insert the interface records.

*********************************************************************/

PROCEDURE INSERT_MTL_TXN_INTF
    (
        p_x_ahl_mtl_txn_rec     IN OUT NOCOPY   AHL_MTLTXN_REC_TYPE,
        p_eam_item_type_id      IN              NUMBER,
        p_x_txn_hdr_id          IN OUT NOCOPY   NUMBER,
        p_x_txn_intf_id         IN OUT NOCOPY   NUMBER,
        p_reservation_flag      IN              VARCHAR2,
        x_return_status            OUT NOCOPY   VARCHAR2
    )
IS
l_Process_Flag          VARCHAR2(1);
l_Validation_required   VARCHAR2(1);
l_transaction_Mode      NUMBER;
l_source_code           VARCHAR2(240);
l_source_line_id        NUMBER;
l_txn_tmp_id            NUMBER;
l_Source_Header_Id      NUMBER;
l_lot_expiration_Date   DATE;
l_txn_action            NUMBER;
l_txn_source_type       NUMBER;
l_qty                   NUMBER;
l_reservation_flag      VARCHAR2(1);

-- added to support dynamic locator creation.
l_mti_seglist           fnd_flex_ext.SegmentArray;

l_loop_count            NUMBER;

CURSOR TRX_ACTION_CUR(p_type_Id NUMBER) IS
SELECT TRANSACTION_ACTION_ID,TRANSACTION_SOURCE_TYPE_ID
from MTL_TRANSACTION_TYPES
where TRANSACTION_TYPE_ID = p_type_Id;

-- Fix for bug# 8607839(FP for Bug # 8575782) -- start
CURSOR get_lot_dff_attrib(p_lot_number IN VARCHAR2) IS
SELECT ATTRIBUTE_CATEGORY,
       ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
       ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
       ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
       C_ATTRIBUTE1, C_ATTRIBUTE2, C_ATTRIBUTE3, C_ATTRIBUTE4, C_ATTRIBUTE5,
       C_ATTRIBUTE6, C_ATTRIBUTE7, C_ATTRIBUTE8, C_ATTRIBUTE9, C_ATTRIBUTE10,
       C_ATTRIBUTE11, C_ATTRIBUTE12, C_ATTRIBUTE13, C_ATTRIBUTE14, C_ATTRIBUTE15,
       C_ATTRIBUTE16, C_ATTRIBUTE17, C_ATTRIBUTE18, C_ATTRIBUTE19, C_ATTRIBUTE20,
       D_ATTRIBUTE1, D_ATTRIBUTE2, D_ATTRIBUTE3, D_ATTRIBUTE4, D_ATTRIBUTE5,
       D_ATTRIBUTE6, D_ATTRIBUTE7, D_ATTRIBUTE8, D_ATTRIBUTE9, D_ATTRIBUTE10,
       N_ATTRIBUTE1, N_ATTRIBUTE2, N_ATTRIBUTE3, N_ATTRIBUTE4, N_ATTRIBUTE5,
       N_ATTRIBUTE6, N_ATTRIBUTE7, N_ATTRIBUTE8, N_ATTRIBUTE9, N_ATTRIBUTE10
FROM mtl_lot_numbers
where lot_number = p_lot_number;

l_lot_dff_rec  get_lot_dff_attrib%ROWTYPE;
-- Fix for bug# 8607839(FP for Bug # 8575782) -- end

-- Fix for bug#	8607839(FP for Bug # 8636342) -- start
CURSOR get_serial_dff_attrib(p_inv_item_id   IN NUMBER,
                             p_serial_number IN VARCHAR2) IS
SELECT ATTRIBUTE_CATEGORY,
       ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
       ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
       ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
       C_ATTRIBUTE1, C_ATTRIBUTE2, C_ATTRIBUTE3, C_ATTRIBUTE4, C_ATTRIBUTE5,
       C_ATTRIBUTE6, C_ATTRIBUTE7, C_ATTRIBUTE8, C_ATTRIBUTE9, C_ATTRIBUTE10,
       C_ATTRIBUTE11, C_ATTRIBUTE12, C_ATTRIBUTE13, C_ATTRIBUTE14, C_ATTRIBUTE15,
       C_ATTRIBUTE16, C_ATTRIBUTE17, C_ATTRIBUTE18, C_ATTRIBUTE19, C_ATTRIBUTE20,
       D_ATTRIBUTE1, D_ATTRIBUTE2, D_ATTRIBUTE3, D_ATTRIBUTE4, D_ATTRIBUTE5,
       D_ATTRIBUTE6, D_ATTRIBUTE7, D_ATTRIBUTE8, D_ATTRIBUTE9, D_ATTRIBUTE10,
       N_ATTRIBUTE1, N_ATTRIBUTE2, N_ATTRIBUTE3, N_ATTRIBUTE4, N_ATTRIBUTE5,
       N_ATTRIBUTE6, N_ATTRIBUTE7, N_ATTRIBUTE8, N_ATTRIBUTE9, N_ATTRIBUTE10
FROM mtl_serial_numbers
where inventory_item_id = p_inv_item_id
  and serial_number = p_serial_number;

l_serial_dff_rec  get_serial_dff_attrib%ROWTYPE;
-- Fix for bug#	8607839(FP for Bug # 8636342) -- end

BEGIN

    l_Process_Flag := '1';
    l_Validation_required  := '1';
    l_transaction_Mode := 2;
    l_source_code := 'AHL';
    l_source_line_id := 1;
    l_Source_Header_Id := 1;


    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN TRX_ACTION_CUR(p_x_ahl_mtl_txn_rec.Transaction_Type_Id);
    FETCH TRX_ACTION_CUR INTO l_txn_action, l_txn_source_type;
    IF(TRX_ACTION_CUR%NOTFOUND) THEN
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Did not find the Txn Type');
        END IF;
        CLOSE TRX_ACTION_CUR;
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE TRX_ACTION_CUR;


    IF(p_x_txn_hdr_id IS NULL) THEN
        SELECT Mtl_Material_Transactions_S.nextval
        INTO p_x_txn_hdr_id
        FROM DUAL;
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Header id created..['||p_x_txn_hdr_id||']');
        END IF;
    END IF;

    l_loop_count := 0;

    WHILE (l_loop_count < p_x_ahl_mtl_txn_rec.Quantity) LOOP

       SELECT Mtl_Material_Transactions_S.nextval
       INTO p_x_txn_intf_id
       FROM DUAL;

       IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.debug('Interface id created..['||p_x_txn_intf_id||']');
       END IF;

       if(p_x_ahl_mtl_txn_rec.Revision = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.Revision := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.Locator_Id = FND_API.G_MISS_NUM) THEN
           p_x_ahl_mtl_txn_rec.Locator_Id := NULL;
       END IF;
       if(p_x_ahl_mtl_txn_rec.Transaction_Type_Id = WIP_CONSTANTS.ISSCOMP_TYPE) THEN
            IF (p_eam_item_type_id = WIP_CONSTANTS.rebuild_item_type AND p_x_ahl_mtl_txn_rec.Quantity > 1) THEN
               l_qty := - 1;
               l_loop_count := l_loop_count + 1;
            ELSE
               l_qty := - p_x_ahl_mtl_txn_rec.Quantity;
               l_loop_count := p_x_ahl_mtl_txn_rec.Quantity + 1;
            END IF;
       ELSE
            IF (p_eam_item_type_id = WIP_CONSTANTS.rebuild_item_type AND p_x_ahl_mtl_txn_rec.Quantity > 1) THEN
               l_qty := 1;
               l_loop_count := l_loop_count + 1;
            ELSE
               l_qty :=  p_x_ahl_mtl_txn_rec.Quantity;
               l_loop_count := p_x_ahl_mtl_txn_rec.Quantity + 1;
            END IF;
       END IF;
       IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug('Loop Count is..['||l_loop_count||']');
           AHL_DEBUG_PUB.debug('l_qty is..['||l_qty||']');
       END IF;

       IF( p_x_ahl_mtl_txn_rec.Reason_Id = FND_API.G_MISS_NUM) THEN
           p_x_ahl_mtl_txn_rec.Reason_Id := NULL;
       END IF;
       IF( p_x_ahl_mtl_txn_rec.Serial_number = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.Serial_number := NULL;
       END IF;
       IF( p_x_ahl_mtl_txn_rec.Lot_number = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.Lot_number := NULL;
       END IF;
       IF (p_x_ahl_mtl_txn_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE_CATEGORY := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE1 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE2 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE3 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE4 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE5 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE6 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE7 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE8 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE9 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE10 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE11 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE12 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE13 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE14 := NULL;
       END IF;
       IF(p_x_ahl_mtl_txn_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.ATTRIBUTE15 := NULL;
       END IF;

       IF(p_x_ahl_mtl_txn_rec.transaction_reference = FND_API.G_MISS_CHAR) THEN
           p_x_ahl_mtl_txn_rec.transaction_reference := NULL;
       END IF;

       IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug('Before dynamic chk:loc segs:ID' || p_x_ahl_mtl_txn_rec.Locator_Segments || ':' ||  p_x_ahl_mtl_txn_rec.Locator_Id);
       END IF;

       -- Added for FP ER 6447935
       -- support dynamic locator creation if allowed.
       -- inv/wip will validate. We will just split and pass the locator segments.

       -- initialze mti locator segment values.
       FOR i IN 1..20 LOOP
          l_mti_seglist(i) := null;
       END LOOP;

       IF (p_x_ahl_mtl_txn_rec.Locator_Id IS NULL AND
           p_x_ahl_mtl_txn_rec.Locator_Segments IS NOT NULL) THEN
            Get_MTL_LocatorSegs (p_concat_segs  => p_x_ahl_mtl_txn_rec.Locator_Segments,
                                 p_organization_id => p_x_ahl_mtl_txn_rec.organization_id,
                                 p_x_mti_seglist  => l_mti_seglist,
                                 x_return_status => x_return_status);

            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

       END IF;

       --If the lot controlled inventory record is not null insert reocrds
       -- into transaction lots interface table.

       IF (p_x_ahl_mtl_txn_rec.Lot_Number IS NOT NULL) THEN

            -- Fix for bug# 8607839(FP for Bug # 8575782) -- start
            -- lot number already validated for existence.
            OPEN get_lot_dff_attrib(p_x_ahl_mtl_txn_rec.Lot_Number);
            FETCH get_lot_dff_attrib INTO l_lot_dff_rec;
            CLOSE get_lot_dff_attrib;
            -- Fix for bug# 8607839(FP for Bug # 8575782) -- end

            IF(p_x_ahl_mtl_txn_rec.Serial_Number IS NOT NULL) THEN
                SELECT Mtl_Material_Transactions_S.nextval
                INTO l_txn_tmp_id
                FROM DUAL;
            ELSE
                l_txn_tmp_id := p_x_txn_intf_id;
            END IF;

            IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug('insertng the lot record,interface id,tempid['
                             ||to_char(p_x_txn_intf_id)||','
                             ||to_char(l_txn_tmp_id)||']');
            END IF;

            -- Fix for bug# 8607839(FP for Bug # 8575782) -- start
            INSERT INTO  MTL_TRANSACTION_LOTS_INTERFACE
                  ( TRANSACTION_INTERFACE_ID ,
                    SOURCE_CODE ,
                    SOURCE_LINE_ID ,
                    LAST_UPDATE_DATE ,
                    LAST_UPDATED_BY ,
                    CREATION_DATE ,
                    CREATED_BY ,
                    LAST_UPDATE_LOGIN ,
                    LOT_NUMBER ,
                    LOT_EXPIRATION_DATE ,
                    TRANSACTION_QUANTITY ,
                    PRIMARY_QUANTITY,
                    SERIAL_TRANSACTION_TEMP_ID,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
                    ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
                    ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
                    ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, C_ATTRIBUTE1,
                    C_ATTRIBUTE2, C_ATTRIBUTE3, C_ATTRIBUTE4, C_ATTRIBUTE5,
                    C_ATTRIBUTE6, C_ATTRIBUTE7, C_ATTRIBUTE8, C_ATTRIBUTE9,
                    C_ATTRIBUTE10, C_ATTRIBUTE11, C_ATTRIBUTE12, C_ATTRIBUTE13,
                    C_ATTRIBUTE14, C_ATTRIBUTE15, C_ATTRIBUTE16, C_ATTRIBUTE17,
                    C_ATTRIBUTE18, C_ATTRIBUTE19, C_ATTRIBUTE20, D_ATTRIBUTE1,
                    D_ATTRIBUTE2, D_ATTRIBUTE3, D_ATTRIBUTE4, D_ATTRIBUTE5,
                    D_ATTRIBUTE6, D_ATTRIBUTE7, D_ATTRIBUTE8, D_ATTRIBUTE9,
                    D_ATTRIBUTE10, N_ATTRIBUTE1, N_ATTRIBUTE2, N_ATTRIBUTE3,
                    N_ATTRIBUTE4, N_ATTRIBUTE5, N_ATTRIBUTE6, N_ATTRIBUTE7,
                    N_ATTRIBUTE8, N_ATTRIBUTE9, N_ATTRIBUTE10
                    )
            VALUES(p_x_txn_intf_id,
                    l_Source_Code,
                    l_Source_Line_Id,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID,
                    p_x_ahl_mtl_txn_rec.Lot_Number,
                    l_lot_expiration_Date,
                    l_qty,
                    l_qty,
                    l_txn_tmp_id,
                    l_lot_dff_rec.ATTRIBUTE_CATEGORY,
                    l_lot_dff_rec.ATTRIBUTE1, l_lot_dff_rec.ATTRIBUTE2, l_lot_dff_rec.ATTRIBUTE3, l_lot_dff_rec.ATTRIBUTE4,
                    l_lot_dff_rec.ATTRIBUTE5, l_lot_dff_rec.ATTRIBUTE6, l_lot_dff_rec.ATTRIBUTE7, l_lot_dff_rec.ATTRIBUTE8,
                    l_lot_dff_rec.ATTRIBUTE9, l_lot_dff_rec.ATTRIBUTE10, l_lot_dff_rec.ATTRIBUTE11, l_lot_dff_rec.ATTRIBUTE12,
                    l_lot_dff_rec.ATTRIBUTE13, l_lot_dff_rec.ATTRIBUTE14, l_lot_dff_rec.ATTRIBUTE15,
                    l_lot_dff_rec.C_ATTRIBUTE1, l_lot_dff_rec.C_ATTRIBUTE2, l_lot_dff_rec.C_ATTRIBUTE3, l_lot_dff_rec.C_ATTRIBUTE4,
                    l_lot_dff_rec.C_ATTRIBUTE5, l_lot_dff_rec.C_ATTRIBUTE6, l_lot_dff_rec.C_ATTRIBUTE7, l_lot_dff_rec.C_ATTRIBUTE8,
                    l_lot_dff_rec.C_ATTRIBUTE9, l_lot_dff_rec.C_ATTRIBUTE10, l_lot_dff_rec.C_ATTRIBUTE11, l_lot_dff_rec.C_ATTRIBUTE12,
                    l_lot_dff_rec.C_ATTRIBUTE13, l_lot_dff_rec.C_ATTRIBUTE14, l_lot_dff_rec.C_ATTRIBUTE15, l_lot_dff_rec.C_ATTRIBUTE16,
                    l_lot_dff_rec.C_ATTRIBUTE17, l_lot_dff_rec.C_ATTRIBUTE18, l_lot_dff_rec.C_ATTRIBUTE19, l_lot_dff_rec.C_ATTRIBUTE20,
                    l_lot_dff_rec.D_ATTRIBUTE1, l_lot_dff_rec.D_ATTRIBUTE2, l_lot_dff_rec.D_ATTRIBUTE3, l_lot_dff_rec.D_ATTRIBUTE4,
                    l_lot_dff_rec.D_ATTRIBUTE5, l_lot_dff_rec.D_ATTRIBUTE6, l_lot_dff_rec.D_ATTRIBUTE7, l_lot_dff_rec.D_ATTRIBUTE8,
                    l_lot_dff_rec.D_ATTRIBUTE9, l_lot_dff_rec.D_ATTRIBUTE10,
                    l_lot_dff_rec.N_ATTRIBUTE1, l_lot_dff_rec.N_ATTRIBUTE2, l_lot_dff_rec.N_ATTRIBUTE3, l_lot_dff_rec.N_ATTRIBUTE4,
                    l_lot_dff_rec.N_ATTRIBUTE5, l_lot_dff_rec.N_ATTRIBUTE6, l_lot_dff_rec.N_ATTRIBUTE7, l_lot_dff_rec.N_ATTRIBUTE8,
                    l_lot_dff_rec.N_ATTRIBUTE9, l_lot_dff_rec.N_ATTRIBUTE10
                    );
             -- Fix for bug# 8607839(FP for Bug # 8575782) -- end
       END IF;

       --If the serial controlled rec is not null then insert records
       -- into the serial numbers interface table
       IF (p_x_ahl_mtl_txn_rec.Serial_Number IS NOT NULL) THEN

           -- Fix for bug # 8607839(FP for Bug # 8636342) -- start
           -- serial number already validated for existence.
           OPEN get_serial_dff_attrib(p_x_ahl_mtl_txn_rec.Inventory_Item_Id, p_x_ahl_mtl_txn_rec.Serial_Number);
           FETCH get_serial_dff_attrib INTO l_serial_dff_rec;
           CLOSE get_serial_dff_attrib;
           -- Fix for bug # 8607839(FP for Bug # 8636342) -- end

           IF (p_x_ahl_mtl_txn_rec.Lot_Number IS NULL) THEN
              l_txn_tmp_id := p_x_txn_intf_id;
           END IF;

           IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.debug('insertng the serial record,interface id['
                                          ||to_char(l_txn_tmp_id)||']');
           END IF;

           -- Fix for bug # 8607839(FP for Bug # 8636342) -- start
           INSERT INTO MTL_SERIAL_NUMBERS_INTERFACE (
               TRANSACTION_INTERFACE_ID, SOURCE_CODE, SOURCE_LINE_ID,
               LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
               CREATED_BY, LAST_UPDATE_LOGIN, FM_SERIAL_NUMBER,
               TO_SERIAL_NUMBER, PROCESS_FLAG,
               ATTRIBUTE_CATEGORY,
               ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
               ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
               ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
               ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, C_ATTRIBUTE1,
               C_ATTRIBUTE2, C_ATTRIBUTE3, C_ATTRIBUTE4, C_ATTRIBUTE5,
               C_ATTRIBUTE6, C_ATTRIBUTE7, C_ATTRIBUTE8, C_ATTRIBUTE9,
               C_ATTRIBUTE10, C_ATTRIBUTE11, C_ATTRIBUTE12, C_ATTRIBUTE13,
               C_ATTRIBUTE14, C_ATTRIBUTE15, C_ATTRIBUTE16, C_ATTRIBUTE17,
               C_ATTRIBUTE18, C_ATTRIBUTE19, C_ATTRIBUTE20, D_ATTRIBUTE1,
               D_ATTRIBUTE2, D_ATTRIBUTE3, D_ATTRIBUTE4, D_ATTRIBUTE5,
               D_ATTRIBUTE6, D_ATTRIBUTE7, D_ATTRIBUTE8, D_ATTRIBUTE9,
               D_ATTRIBUTE10, N_ATTRIBUTE1, N_ATTRIBUTE2, N_ATTRIBUTE3,
               N_ATTRIBUTE4, N_ATTRIBUTE5, N_ATTRIBUTE6, N_ATTRIBUTE7,
               N_ATTRIBUTE8, N_ATTRIBUTE9, N_ATTRIBUTE10
               )
           VALUES ( l_txn_tmp_id,
                    l_source_code,
                    l_source_line_id,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID,
                    p_x_ahl_mtl_txn_rec.Serial_Number,
                    p_x_ahl_mtl_txn_rec.Serial_Number,
                    l_Process_Flag,
                    l_serial_dff_rec.ATTRIBUTE_CATEGORY,
                    l_serial_dff_rec.ATTRIBUTE1, l_serial_dff_rec.ATTRIBUTE2, l_serial_dff_rec.ATTRIBUTE3, l_serial_dff_rec.ATTRIBUTE4,
                    l_serial_dff_rec.ATTRIBUTE5, l_serial_dff_rec.ATTRIBUTE6, l_serial_dff_rec.ATTRIBUTE7, l_serial_dff_rec.ATTRIBUTE8,
                    l_serial_dff_rec.ATTRIBUTE9, l_serial_dff_rec.ATTRIBUTE10, l_serial_dff_rec.ATTRIBUTE11, l_serial_dff_rec.ATTRIBUTE12,
                    l_serial_dff_rec.ATTRIBUTE13, l_serial_dff_rec.ATTRIBUTE14, l_serial_dff_rec.ATTRIBUTE15,
                    l_serial_dff_rec.C_ATTRIBUTE1, l_serial_dff_rec.C_ATTRIBUTE2, l_serial_dff_rec.C_ATTRIBUTE3,
                    l_serial_dff_rec.C_ATTRIBUTE4, l_serial_dff_rec.C_ATTRIBUTE5,
                    l_serial_dff_rec.C_ATTRIBUTE6, l_serial_dff_rec.C_ATTRIBUTE7,
                    l_serial_dff_rec.C_ATTRIBUTE8, l_serial_dff_rec.C_ATTRIBUTE9,
                    l_serial_dff_rec.C_ATTRIBUTE10, l_serial_dff_rec.C_ATTRIBUTE11,
                    l_serial_dff_rec.C_ATTRIBUTE12, l_serial_dff_rec.C_ATTRIBUTE13,
                    l_serial_dff_rec.C_ATTRIBUTE14, l_serial_dff_rec.C_ATTRIBUTE15,
                    l_serial_dff_rec.C_ATTRIBUTE16, l_serial_dff_rec.C_ATTRIBUTE17,
                    l_serial_dff_rec.C_ATTRIBUTE18, l_serial_dff_rec.C_ATTRIBUTE19,
                    l_serial_dff_rec.C_ATTRIBUTE20, l_serial_dff_rec.D_ATTRIBUTE1,
                    l_serial_dff_rec.D_ATTRIBUTE2, l_serial_dff_rec.D_ATTRIBUTE3,
                    l_serial_dff_rec.D_ATTRIBUTE4, l_serial_dff_rec.D_ATTRIBUTE5,
                    l_serial_dff_rec.D_ATTRIBUTE6, l_serial_dff_rec.D_ATTRIBUTE7,
                    l_serial_dff_rec.D_ATTRIBUTE8, l_serial_dff_rec.D_ATTRIBUTE9,
                    l_serial_dff_rec.D_ATTRIBUTE10, l_serial_dff_rec.N_ATTRIBUTE1,
                    l_serial_dff_rec.N_ATTRIBUTE2, l_serial_dff_rec.N_ATTRIBUTE3,
                    l_serial_dff_rec.N_ATTRIBUTE4, l_serial_dff_rec.N_ATTRIBUTE5,
                    l_serial_dff_rec.N_ATTRIBUTE6, l_serial_dff_rec.N_ATTRIBUTE7,
                    l_serial_dff_rec.N_ATTRIBUTE8, l_serial_dff_rec.N_ATTRIBUTE9,
                    l_serial_dff_rec.N_ATTRIBUTE10
                 );
           -- Fix for bug # 8607839(FP for Bug # 8636342) -- end
       END IF;



       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('insertng the txn record,header id,interface id['
                                  ||to_char(p_x_txn_hdr_id)||','
                                  ||to_char(p_x_txn_intf_id)||']');
       END IF;

       INSERT INTO  MTL_TRANSACTIONS_INTERFACE

          ( TRANSACTION_INTERFACE_ID ,           TRANSACTION_HEADER_ID ,
            SOURCE_CODE ,                        SOURCE_LINE_ID ,
            SOURCE_HEADER_ID,                    PROCESS_FLAG ,
            VALIDATION_REQUIRED ,                TRANSACTION_MODE ,
            LAST_UPDATE_DATE ,                   LAST_UPDATED_BY ,
            CREATION_DATE ,                      CREATED_BY ,
            LAST_UPDATE_LOGIN ,                  INVENTORY_ITEM_ID ,
            ORGANIZATION_ID ,                    TRANSACTION_QUANTITY ,
            PRIMARY_QUANTITY ,                   TRANSACTION_UOM ,
            TRANSACTION_DATE ,                   SUBINVENTORY_CODE ,
            LOCATOR_ID ,                         TRANSACTION_TYPE_ID ,
            REVISION ,                           TRANSACTION_REFERENCE ,
            WIP_ENTITY_TYPE ,                    OPERATION_SEQ_NUM,
            TRANSACTION_SOURCE_TYPE_ID,          TRANSACTION_SOURCE_ID,
            TRX_SOURCE_LINE_ID,
            ATTRIBUTE_CATEGORY,                      ATTRIBUTE1,
            ATTRIBUTE2,                              ATTRIBUTE3,
            ATTRIBUTE4,                              ATTRIBUTE5,
            ATTRIBUTE6,                              ATTRIBUTE7,
            ATTRIBUTE8,                              ATTRIBUTE9,
            ATTRIBUTE10,                             ATTRIBUTE11,
            ATTRIBUTE12,                             ATTRIBUTE13,
            ATTRIBUTE14,                             ATTRIBUTE15,
            RELIEVE_RESERVATIONS_FLAG,
            REASON_ID,
            LOC_SEGMENT1,                            LOC_SEGMENT2,
            LOC_SEGMENT3,                            LOC_SEGMENT4,
            LOC_SEGMENT5,                            LOC_SEGMENT6,
            LOC_SEGMENT7,                            LOC_SEGMENT8,
            LOC_SEGMENT9,                            LOC_SEGMENT10,
            LOC_SEGMENT11,                           LOC_SEGMENT12,
            LOC_SEGMENT13,                           LOC_SEGMENT14,
            LOC_SEGMENT15,                           LOC_SEGMENT16,
            LOC_SEGMENT17,                           LOC_SEGMENT18,
            LOC_SEGMENT19,                           LOC_SEGMENT20)
       values  (p_x_txn_intf_id,                        p_x_txn_hdr_id,
         l_Source_Code,                              l_Source_Line_Id,
         l_Source_Header_Id,                         l_Process_Flag,
         l_Validation_required ,                     l_transaction_Mode,
         sysdate,                                    FND_GLOBAL.USER_ID,
         sysdate,                                    FND_GLOBAL.USER_ID,
         FND_GLOBAL.LOGIN_ID,                        p_x_ahl_mtl_txn_rec.Inventory_Item_Id,
         p_x_ahl_mtl_txn_rec.Organization_Id,        l_qty,
         l_qty,                                      p_x_ahl_mtl_txn_rec.Uom,
         p_x_ahl_mtl_txn_rec.Transaction_Date,       p_x_ahl_mtl_txn_rec.Subinventory_Name,
         p_x_ahl_mtl_txn_rec.Locator_Id,             p_x_ahl_mtl_txn_rec.Transaction_Type_Id,
         p_x_ahl_mtl_txn_rec.Revision,               p_x_ahl_mtl_txn_rec.Transaction_Reference,
         WIP_CONSTANTS.DISCRETE,                     p_x_ahl_mtl_txn_rec.Operation_Seq_Num,
         l_txn_source_type,                          p_x_ahl_mtl_txn_rec.Wip_Entity_id,
         p_x_ahl_mtl_txn_rec.Operation_Seq_Num,   -- TRX_SOURCE_LINE_ID (needed for relieving reservations)
         p_x_ahl_mtl_txn_rec.Attribute_Category,     p_x_ahl_mtl_txn_rec.Attribute1,
         p_x_ahl_mtl_txn_rec.Attribute2,             p_x_ahl_mtl_txn_rec.Attribute3,
         p_x_ahl_mtl_txn_rec.Attribute4,             p_x_ahl_mtl_txn_rec.Attribute5,
         p_x_ahl_mtl_txn_rec.Attribute6,             p_x_ahl_mtl_txn_rec.Attribute7,
         p_x_ahl_mtl_txn_rec.Attribute8,             p_x_ahl_mtl_txn_rec.Attribute9,
         p_x_ahl_mtl_txn_rec.Attribute10,            p_x_ahl_mtl_txn_rec.Attribute11,
         p_x_ahl_mtl_txn_rec.Attribute12,            p_x_ahl_mtl_txn_rec.Attribute13,
         p_x_ahl_mtl_txn_rec.Attribute14,            p_x_ahl_mtl_txn_rec.Attribute15,
         p_reservation_flag,  -- relieve reservations flag.
         p_x_ahl_mtl_txn_rec.reason_id,
         l_mti_seglist(1),                               l_mti_seglist(2),
         l_mti_seglist(3),                               l_mti_seglist(4),
         l_mti_seglist(5),                               l_mti_seglist(6),
         l_mti_seglist(7),                               l_mti_seglist(8),
         l_mti_seglist(9),                               l_mti_seglist(10),
         l_mti_seglist(11),                              l_mti_seglist(12),
         l_mti_seglist(13),                              l_mti_seglist(14),
         l_mti_seglist(15),                              l_mti_seglist(16),
         l_mti_seglist(17),                              l_mti_seglist(18),
         l_mti_seglist(19),                              l_mti_seglist(20)
             ) ;
    END LOOP; -- WHILE (l_loop_count


    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug('Transaction_source type['||l_txn_source_type||']');
       AHL_DEBUG_PUB.debug('Transaction_source Id['||p_x_ahl_mtl_txn_rec.Wip_Entity_id||']');
    END IF;

EXCEPTION
         WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
               IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('Exception inserting into mtl_txn interface' || SQLCODE);
              AHL_DEBUG_PUB.debug('SQLERRM:' || SQLERRM);

           END IF;
           FND_MESSAGE.Set_Name('AHL','AHL_PRD_MTLTXN_ERROR');
           FND_MESSAGE.Set_Token('MSG',SQLERRM);
           FND_MESSAGE.Set_Token('ITEM',p_x_ahl_mtl_txn_rec.Inventory_Item_Id);
           FND_MESSAGE.Set_Token('WO_NAME',p_x_ahl_mtl_txn_rec.workorder_id);
           FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;

END INSERT_MTL_TXN_INTF;

/* This is a funciton used by the front queries which
populate the table data. This gets the issued quantity
for rhe given workorder id and item */
Function GET_ISSUED_QTY(P_ORG_ID IN NUMBER, P_ITEM_ID IN NUMBER, P_WORKORDER_OP_ID IN NUMBER) RETURN NUMBER
as
    l_iss_qty NUMBER:=0;
BEGIN

    -- Tamal: Bug #4095376: Begin
    -- The following line will be needed in the case net quantity issued is to be displayed, instead of entire issued quantity
    -- SELECT sum(nvl(decode(TRANSACTION_TYPE_ID, 35, QUANTITY, 43, -QUANTITY, 0), 0))
    SELECT sum(nvl(QUANTITY, 0))
    INTO l_iss_qty
    FROM AHL_WORKORDER_MTL_TXNS
    WHERE ORGANIZATION_ID = P_ORG_ID
    AND INVENTORY_ITEM_ID = P_ITEM_ID
    AND WORKORDER_OPERATION_ID = P_WORKORDER_OP_ID
    -- The following line will NOT be needed in the case net quantity issued is to be displayed
    AND TRANSACTION_TYPE_ID = 35;
    -- Tamal: Bug #4095376: End

    return nvl(l_iss_qty,0);

END GET_ISSUED_QTY;

Function GET_WORKORD_LEVEL_QTY(
             p_wid           IN NUMBER,
             p_item_id       IN NUMBER,
             p_org_id        IN NUMBER,
             p_lotnum        IN VARCHAR2,
             p_rev           IN VARCHAR2,
             p_serial_number IN VARCHAR2
             )
RETURN NUMBER
As
issued NUMBER;
CURSOR CUR_GET_WOID_LEVEL_QTY IS
SELECT SUM(nvl(QUANTITY,0))
FROM AHL_WORKORDER_MTL_TXNS A
,AHL_WORKORDER_OPERATIONS_V B
WHERE A.ORGANIZATION_ID       = p_org_id
AND A.INVENTORY_ITEM_ID       = p_item_id
AND NVL(A.lot_number,'X')=NVL(p_lotnum,NVL(A.lot_number,'X'))
AND NVL(A.revision,'X')=NVL(p_rev,NVL(A.REVISION,'X'))
AND NVL(A.serial_number,'X')=NVL(p_serial_number,NVL(A.SERIAL_NUMBER,'X'))
AND A.TRANSACTION_TYPE_ID=35
AND A.ORGANIZATION_ID = B.organization_id
AND A.workorder_operation_id =B.workorder_operation_id
AND B.workorder_id = p_wid;

BEGIN
    OPEN CUR_GET_WOID_LEVEL_QTY;
    FETCH CUR_GET_WOID_LEVEL_QTY INTO issued;
    IF(CUR_GET_WOID_LEVEL_QTY%NOTFOUND) THEN
        issued := 0;
    END IF;
    CLOSE CUR_GET_WOID_LEVEL_QTY;
    return issued;
END GET_WORKORD_LEVEL_QTY;

-- JKJAIN FP ER # 6436303 - start
-- JKJAIN removed p_lotnum,p_rev,p_serial_number for Bug # 7587902
--------------------------------------------------------------------------------
 	 -- Function for returning net quantity of material available with
 	 -- a workorder.
 	 -- Net Total Quantity = Total Quantity Issued - Total quantity returned
 	 -- Balaji added this function for OGMA ER # 5948868.
 	 --------------------------------------------------------------------------------------

 	 Function GET_WORKORD_NET_QTY(
 	              p_wid           IN NUMBER,
 	              p_item_id       IN NUMBER,
 	              p_org_id        IN NUMBER
 	              )
 	 RETURN NUMBER
 	 As

 	 -- Local variables
 	 l_issue_qty NUMBER;
 	 l_rtn_qty NUMBER;
 	 l_net_qty NUMBER;

 	 -- Cursors
 	 -- cursor for getting total issued quantity
 	 CURSOR CUR_GET_WO_ISSUE_QTY
 	 IS
 	 SELECT  SUM(nvl(QUANTITY,0))
 	 FROM    AHL_WORKORDER_MTL_TXNS A ,
-- 	         AHL_WORKORDER_OPERATIONS_V B
--           JKJAIN BUG # 7587902
			 AHL_WORKORDER_OPERATIONS B
 	 WHERE   A.ORGANIZATION_ID        = p_org_id
 	     AND A.INVENTORY_ITEM_ID      = p_item_id
 	     AND A.TRANSACTION_TYPE_ID    =35
-- 	     AND A.ORGANIZATION_ID        = B.organization_id
 	     AND A.workorder_operation_id =B.workorder_operation_id
 	     AND B.workorder_id           = p_wid;

 	 -- cursor for getting total returned quantity
 	 CURSOR CUR_GET_WO_RET_QTY
 	 IS
 	 SELECT  SUM(nvl(QUANTITY,0))
 	 FROM    AHL_WORKORDER_MTL_TXNS A ,
-- 	         AHL_WORKORDER_OPERATIONS_V B
--           JKJAIN BUG # 7587902
            AHL_WORKORDER_OPERATIONS B
 	 WHERE   A.ORGANIZATION_ID        = p_org_id
 	     AND A.INVENTORY_ITEM_ID      = p_item_id
 	     AND A.TRANSACTION_TYPE_ID    =43
-- 	     AND A.ORGANIZATION_ID        = B.organization_id
 	     AND A.workorder_operation_id =B.workorder_operation_id
 	     AND B.workorder_id           = p_wid;

 	 BEGIN
 	         OPEN CUR_GET_WO_ISSUE_QTY;
 	         FETCH CUR_GET_WO_ISSUE_QTY INTO l_issue_qty;
 	         CLOSE CUR_GET_WO_ISSUE_QTY;

 	         IF l_issue_qty IS NULL
 	         THEN
 	            l_issue_qty := 0;
 	         END IF;

 	         OPEN CUR_GET_WO_RET_QTY;
 	         FETCH CUR_GET_WO_RET_QTY INTO l_rtn_qty;
 	         CLOSE CUR_GET_WO_RET_QTY;

 	         IF l_rtn_qty IS NULL
 	         THEN
 	            l_rtn_qty := 0;
 	         END IF;

 	         l_net_qty := l_issue_qty - l_rtn_qty;

-- JKJAIN BUG # 7587902
-- 	         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)THEN
-- 	              fnd_log.string
-- 	                  (
-- 	                     G_LEVEL_STATEMENT,
-- 	                     'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_WORKORD_NET_QTY',
-- 	                     'l_net_qty -> ' || l_net_qty
-- 	                  );
-- 	         END IF;

 	         return l_net_qty;

 	 END GET_WORKORD_NET_QTY;
 -- JKJAIN FP ER # 6436303 - end

/* this function is used by the front end queries which
populate the table data. This gets the onhand quantity for an
item */

function GET_ONHAND(P_ORG_ID IN NUMBER, P_ITEM_ID IN NUMBER) RETURN NUMBER
IS
onhand NUMBER;
CURSOR Q1(p_org_id NUMBER, p_itme_Id NUMBER) IS
SELECT SUM(TRANSACTION_QUANTITY)
FROM MTL_ONHAND_QUANTITIES
WHERE ORGANIZATION_ID = p_org_id
AND INVENTORY_ITEM_ID = p_item_id;
BEGIN
    OPEN Q1(P_ORG_ID,P_ITEM_ID);
    FETCH Q1 INTO onhand;
    IF(Q1%NOTFOUND) THEN
        onhand := 0;
    END IF;
    CLOSE Q1;
    return onhand;
END GET_ONHAND;

procedure dumpInput(p_x_ahl_mtltxn_tbl  IN      AHL_MTLTXN_TBL_TYPE) IS
BEGIN

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.DEBUG('INPUTS TO THE PROC ARE ...');

    IF (p_x_ahl_mtltxn_tbl.COUNT > 0) THEN
         FOR i IN p_x_ahl_mtltxn_tbl.FIRST..p_x_ahl_mtltxn_tbl.LAST  LOOP

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Ahl_mtltxn_Id:'||p_x_ahl_mtltxn_tbl(i).Ahl_mtltxn_Id);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Workorder_Id:'||p_x_ahl_mtltxn_tbl(i).Workorder_Id);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Inventory_Item_Id:'||p_x_ahl_mtltxn_tbl(i).Inventory_Item_Id);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Inventory_Item_Segments:'||p_x_ahl_mtltxn_tbl(i).Inventory_Item_Segments);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Revision:'||p_x_ahl_mtltxn_tbl(i).Revision);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Organization_Id:'||p_x_ahl_mtltxn_tbl(i).Organization_Id);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Condition:'||p_x_ahl_mtltxn_tbl(i).Condition);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Condition_desc:'||p_x_ahl_mtltxn_tbl(i).Condition_desc);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Subinventory_Name:'||p_x_ahl_mtltxn_tbl(i).Subinventory_Name);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Locator_Id:'||p_x_ahl_mtltxn_tbl(i).Locator_Id);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Locator_Segments:'||p_x_ahl_mtltxn_tbl(i).Locator_Segments);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Quantity:'||p_x_ahl_mtltxn_tbl(i).Quantity);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Uom:'||p_x_ahl_mtltxn_tbl(i).Uom);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Uom_Desc:'||p_x_ahl_mtltxn_tbl(i).Uom_Desc);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Transaction_Type_Id:'||p_x_ahl_mtltxn_tbl(i).Transaction_Type_Id);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Transaction_Type_Name:'||p_x_ahl_mtltxn_tbl(i).Transaction_Type_Name);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Transaction_Reference:'||p_x_ahl_mtltxn_tbl(i).Transaction_Reference);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Wip_Entity_Id:'||p_x_ahl_mtltxn_tbl(i).Wip_Entity_Id);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Operation_Seq_Num:'||p_x_ahl_mtltxn_tbl(i).Operation_Seq_Num);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Serial_Number:'||p_x_ahl_mtltxn_tbl(i).Serial_Number);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Lot_Number:'||p_x_ahl_mtltxn_tbl(i).Lot_Number);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Reason_Id:'||p_x_ahl_mtltxn_tbl(i).Reason_Id);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Reason_Name:'||p_x_ahl_mtltxn_tbl(i).Reason_Name);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Problem_Code:'||p_x_ahl_mtltxn_tbl(i).Problem_Code);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Problem_Code_Meaning:'||p_x_ahl_mtltxn_tbl(i).Problem_Code_Meaning);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Target_Visit_Id:'||p_x_ahl_mtltxn_tbl(i).Target_Visit_Id);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Sr_Summary:'||p_x_ahl_mtltxn_tbl(i).Sr_Summary);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Qa_Collection_Id:'||p_x_ahl_mtltxn_tbl(i).Qa_Collection_Id);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').Workorder_operation_Id:'||p_x_ahl_mtltxn_tbl(i).Workorder_operation_Id);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE_CATEGORY:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE_CATEGORY);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE1:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE1);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE2:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE2);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE3:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE3);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE4:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE4);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE5:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE5);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE6:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE6);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE7:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE7);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE8:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE8);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE9:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE9);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE10:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE10);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE11:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE11);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE12:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE12);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE13:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE13);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE14:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE14);

          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').ATTRIBUTE15:'||p_x_ahl_mtltxn_tbl(i).ATTRIBUTE15);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').transaction_date:'||p_x_ahl_mtltxn_tbl(i).transaction_date);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').recepient_id:'||p_x_ahl_mtltxn_tbl(i).recepient_id);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').recepient_name:'||p_x_ahl_mtltxn_tbl(i).recepient_name);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').disposition_id:'||p_x_ahl_mtltxn_tbl(i).disposition_id);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').disposition_name:'||p_x_ahl_mtltxn_tbl(i).disposition_name);
          AHL_DEBUG_PUB.debug('p_x_ahl_mtltxn_tbl('||i||').move_to_project_flag:'||p_x_ahl_mtltxn_tbl(i).move_to_project_flag);
      END LOOP;
    END IF; -- p_x_ahl_mtltxn_tbl.COUNT
  END IF;
END dumpInput;

Procedure CALCULATE_QTY
(
    p_wo_id     IN NUMBER,
    p_item_id   IN NUMBER,
    p_org_id    IN NUMBER,
    p_lot_num   IN VARCHAR2,
    p_rev_num   IN VARCHAR2,
    p_serial_num    IN VARCHAR2,
    p_wo_op_id  IN NUMBER,
    x_qty           OUT NOCOPY NUMBER
)
IS
    l_rev_flag      VARCHAR2(1) := 'N';
    l_lot_flag      VARCHAR2(1) := 'N';
    l_serial_flag   VARCHAR2(1) := 'N';

    CURSOR  GetItemDet(c_inv_item_id IN NUMBER, c_org_id IN NUMBER)
    IS
    SELECT
        SERIAL_NUMBER_CONTROL_CODE,
        LOT_CONTROL_CODE,
        REVISION_QTY_CONTROL_CODE
    FROM
        MTL_SYSTEM_ITEMS_B
    WHERE
        inventory_item_id=c_inv_item_id
        AND ORGANIZATION_ID=c_org_id;

    l_item_rec      GetItemDet%rowtype;
    l_iss_qty       NUMBER:=0;
    l_rtn_qty       NUMBER:=0;
    l_disp_qty      NUMBER:=0;
    l_net_qty       NUMBER:=0;

BEGIN

    OPEN GetItemDet (p_item_id, p_org_id);
    FETCH GetItemDet into l_item_rec;
    IF GetItemDet%found
    THEN
        IF l_item_rec.LOT_CONTROL_CODE = 2 THEN
            l_lot_flag:='Y';
        END IF;

        IF l_item_rec.REVISION_QTY_CONTROL_CODE = 2 THEN
            l_rev_flag:='Y';
        END IF;

        IF l_item_rec.SERIAL_NUMBER_CONTROL_CODE <> 1 THEN
            l_serial_flag:='Y';
        END IF;
    END IF;
    CLOSE GetItemDet;


    SELECT SUM(NVL(a.primary_uom_qty,0)) INTO l_iss_qty
    FROM
        AHL_WORKORDER_MTL_TXNS a,
        AHL_WORKORDER_OPERATIONS b
    WHERE
        a.workorder_operation_id=b.workorder_operation_id
        AND a.transaction_type_id=35
        AND b.workorder_id=p_wo_id
        AND a.inventory_item_id=p_item_id
        AND a.organization_id=p_org_id
        AND nvl(a.serial_number,'X') = nvl(decode(l_serial_flag, 'Y', p_serial_num, a.serial_number),'X')
        AND nvl(a.lot_number,'X') = nvl(decode(l_lot_flag, 'Y', p_lot_num, a.lot_number),'X')
        AND nvl(a.revision,'X') = nvl(decode(l_rev_flag, 'Y', p_rev_num, a.revision),'X')
        AND a.workorder_operation_id=nvl(p_wo_op_id, a.workorder_operation_id);

    SELECT SUM(NVL(a.primary_uom_qty,0)) INTO l_rtn_qty
    FROM
        AHL_WORKORDER_MTL_TXNS a,
        AHL_WORKORDER_OPERATIONS b
    WHERE
        a.workorder_operation_id=b.workorder_operation_id
        AND a.transaction_type_id=43
        AND b.workorder_id=p_wo_id
        AND a.inventory_item_id=p_item_id
        AND a.organization_id=p_org_id
        AND nvl(a.serial_number,'X') = nvl(decode(l_serial_flag, 'Y', p_serial_num, a.serial_number),'X')
        AND nvl(a.lot_number,'X') = nvl(decode(l_lot_flag, 'Y', p_lot_num, a.lot_number),'X')
        AND nvl(a.revision,'X') = nvl(decode(l_rev_flag, 'Y', p_rev_num, a.revision),'X')
        AND a.workorder_operation_id=nvl(p_wo_op_id, a.workorder_operation_id);

    /* Tamal [R12 APPSPERF fixes]
     * R12 Drop 4 - SQL ID: 14400506
     * Bug #4918991
     */
    SELECT SUM(NVL(a.net_quantity,0)) INTO l_disp_qty
    FROM
        AHL_MTL_RET_DISPOSITIONS_V a,
        AHL_WORKORDERS b
    WHERE
        a.workorder_id=b.workorder_id
        AND b.master_workorder_flag = 'N'
        --AND b.status_code NOT IN ('17' , '22')
        AND b.status_code IN ('3','4','20')
        AND b.workorder_id=p_wo_id
        AND a.inventory_item_id=p_item_id
        --AND a.organization_id=p_org_id
        AND nvl(a.serial_number,'X') = nvl(decode(l_serial_flag, 'Y', p_serial_num, a.serial_number),'X')
        AND nvl(a.lot_number,'X') = nvl(decode(l_lot_flag, 'Y', p_lot_num, a.lot_number),'X')
        AND nvl(a.item_revision,'X') = nvl(decode(l_rev_flag, 'Y', p_rev_num, a.item_revision),'X')
        AND a.workorder_operation_id=nvl(p_wo_op_id, a.workorder_operation_id);

    x_qty := nvl(l_iss_qty, 0) - nvl(l_rtn_qty, 0) - nvl(l_disp_qty, 0);

END CALCULATE_QTY;

PROCEDURE getDispositionReturn
          (
            p_x_ahl_prd_mtl_txn_tbl     IN OUT  NOCOPY Ahl_Mtltxn_Tbl_Type,
            P_prd_Mtltxn_criteria_rec   IN            Prd_Mtltxn_criteria_rec
           )AS

  --pdoki commented for Bug 9164678

   -- pick organization from Visit table. Disp. view returns master org.
  /* CURSOR GetDispDet
          (
             p_job_number   IN VARCHAR2,
             p_visit_number IN NUMBER,
             p_priority     IN NUMBER,
             p_dept_name    IN VARCHAR2,
             p_org_name     IN VARCHAR2,
             p_item         IN VARCHAR2,
             p_incident_number IN VARCHAR2,
             p_disposition_name IN VARCHAR2
           ) IS

/* Tamal [R12 APPSPERF fixes]
 * R12 Drop 4 - SQL ID: 14400778
 * Bug #4918991
 */
/*SELECT
    D.WORKORDER_ID,
    D.WORKORDER_NAME,
    V.ORGANIZATION_ID,
    D.WORKORDER_OPERATION_ID,
    O.OPERATION_SEQUENCE_NUM,
    D.ITEM_NUMBER,
    D.INVENTORY_ITEM_ID,
    D.ITEM_DESC,
    D.IMMEDIATE_DISPOSITION_CODE,
    D.DISPOSITION_ID,
    D.IMMEDIATE_TYPE,
    D.CONDITION_CODE,
    D.CONDITION_ID,
    D.SERIAL_NUMBER,
    D.UOM,
    UOM.UNIT_OF_MEASURE,
    WO_STS.MEANING JOB_STATUS_MEANING,
    D.LOT_NUMBER,
    D.ITEM_REVISION,
    D.COLLECTION_ID,
    D.INSTANCE_ID,
    WIP.DEFAULT_PULL_SUPPLY_SUBINV,
    WIP.DEFAULT_PULL_SUPPLY_LOCATOR_ID,
    L.CONCATENATED_SEGMENTS,
    --SYSDATE,
    D.QUANTITY, --GOES TO THE ISSUE QTY UI
    D.NET_QUANTITY,  --GOES TO THE RETURN QTY
	-- JKJAIN FP ER # 6436303 - start
 	AHL_PRD_MTLTXN_PVT.GET_WORKORD_NET_QTY(D.WORKORDER_ID,D.INVENTORY_ITEM_ID,V.ORGANIZATION_ID) Wo_Net_Total_Qty,
 	-- JKJAIN FP ER # 6436303 - end
   W.wip_entity_id,
    (select inv_locator_id from ahl_visits_b where visit_id = w.visit_id) inv_locator_id
FROM
    AHL_MTL_RET_DISPOSITIONS_V D,
    AHL_WORKORDERS W,
    (SELECT LOOKUP_CODE, MEANING FROM FND_LOOKUP_VALUES WHERE LOOKUP_TYPE = 'AHL_JOB_STATUS' AND LANGUAGE= USERENV('LANG')) WO_STS,
    AHL_VISITS_B V,
    AHL_VISIT_TASKS_B VT,
    CS_INCIDENTS_ALL_B C,
    WIP_DISCRETE_JOBS WDJ,
    (SELECT ORGANIZATION_ID, NAME FROM HR_ALL_ORGANIZATION_UNITS_TL WHERE LANGUAGE = USERENV('LANG')) ORG,
    BOM_DEPARTMENTS B,
    AHL_WORKORDER_OPERATIONS O,
    MTL_UNITS_OF_MEASURE_VL UOM,
    WIP_PARAMETERS WIP,
    MTL_ITEM_LOCATIONS_KFV L
WHERE
    D.WORKORDER_ID = W.WORKORDER_ID AND
    W.MASTER_WORKORDER_FLAG = 'N' AND
    --W.STATUS_CODE NOT IN ('17', '22', '5','7','12') AND
    W.STATUS_CODE IN ('3', '4', '20') AND
    W.STATUS_CODE = WO_STS.LOOKUP_CODE AND
    O.WORKORDER_OPERATION_ID (+) = D.WORKORDER_OPERATION_ID AND
    O.WORKORDER_ID (+) = D.WORKORDER_ID AND
    D.UOM = UOM.UOM_CODE AND
    WIP.ORGANIZATION_ID = L.ORGANIZATION_ID(+) AND
    WIP.DEFAULT_PULL_SUPPLY_LOCATOR_ID = L.INVENTORY_LOCATION_ID(+) AND
    WIP.ORGANIZATION_ID = V.ORGANIZATION_ID AND
    W.VISIT_TASK_ID = VT.VISIT_TASK_ID AND
    V.VISIT_ID = VT.VISIT_ID AND
    V.SERVICE_REQUEST_ID = C.INCIDENT_ID(+) AND
    WDJ.WIP_ENTITY_ID = W.WIP_ENTITY_ID AND
    WDJ.OWNING_DEPARTMENT = B.DEPARTMENT_ID(+) AND
    V.ORGANIZATION_ID = ORG.ORGANIZATION_ID AND
    D.IMMEDIATE_TYPE LIKE NVL(p_disposition_name, D.IMMEDIATE_TYPE) AND
    D.ITEM_NUMBER LIKE NVL(p_item, D.ITEM_NUMBER) AND
    NVL(C.INCIDENT_NUMBER,'X') LIKE NVL(p_incident_number, NVL(C.INCIDENT_NUMBER,'X')) AND
    W.WORKORDER_NAME LIKE NVL(p_job_number, W.WORKORDER_NAME) AND
    UPPER(ORG.NAME) LIKE UPPER(NVL(p_org_name, ORG.NAME)) AND
    NVL(WDJ.PRIORITY,0) = NVL(p_priority, NVL(WDJ.PRIORITY,0)) AND
    V.VISIT_NUMBER = NVL(p_visit_number, V.VISIT_NUMBER) AND
    UPPER(B.DESCRIPTION) LIKE UPPER(NVL(p_dept_name, B.DESCRIPTION)); */

    -- check if issued instance has been installed / validate instance.
    CURSOR chk_inst_relationship_csr (p_INVENTORY_ITEM_ID IN NUMBER,
                                      p_wip_entity_id IN NUMBER,
                                      p_ITEM_Revision IN VARCHAR2,
                                      p_lot_number IN VARCHAR2,
                                      p_Serial_Number IN VARCHAR2) IS
        SELECT 'x'
        FROM  CSI_ITEM_INSTANCES CII
        WHERE CII.inventory_item_id = p_INVENTORY_ITEM_ID
          AND nvl(cii.inventory_revision,'1') = nvl(p_ITEM_Revision, '1')
          AND nvl(cii.lot_number, '1') = nvl(p_lot_number, '1')
          AND nvl(cii.serial_number,'1') = nvl(p_serial_number, '1')
          AND CII.ACTIVE_START_DATE <= SYSDATE
          AND ((CII.ACTIVE_END_DATE IS NULL) OR (CII.ACTIVE_END_DATE > SYSDATE))
          AND CII.QUANTITY > 0
          AND CII.LOCATION_TYPE_CODE = 'WIP'
          AND CII.WIP_JOB_ID = p_wip_entity_id
          AND NOT EXISTS (SELECT 'X' FROM CSI_II_RELATIONSHIPS CIR
                          WHERE CIR.SUBJECT_ID = CII.INSTANCE_ID
                            AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                            AND NVL(CIR.ACTIVE_START_DATE,SYSDATE) <= SYSDATE AND
                            (CIR.ACTIVE_END_DATE IS NULL OR CIR.ACTIVE_END_DATE > SYSDATE));

   l_index      NUMBER;
   l_valid_flag BOOLEAN;
   l_junk       VARCHAR2(1);

   -- sracha: added for bug fix 6328554.
   l_index_start NUMBER;

   --pdoki added for Bug 9164678
   l_bind_value_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
   l_mtl_txns_returns_cur AHL_OSP_UTIL_PKG.ahl_search_csr;
   l_bind_index NUMBER;
   l_mtl_txn_dtls VARCHAR2(10000);
   l_mtl_txn_dtls_where VARCHAR2(10000);

   TYPE l_disp_rec_type IS RECORD (
        workorder_id                    AHL_PRD_DISPOSITIONS_B.WORKORDER_ID%TYPE,
        workorder_name                  AHL_WORKORDERS.WORKORDER_NAME%TYPE,
        organization_id                 AHL_VISITS_B.ORGANIZATION_ID%TYPE,
        workorder_operation_id          AHL_PRD_DISPOSITIONS_B.WO_OPERATION_ID%TYPE,
        operation_sequence_num          AHL_WORKORDER_OPERATIONS.OPERATION_SEQUENCE_NUM%TYPE,
        item_number                     MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE,
        inventory_item_id               CSI_ITEM_INSTANCES.INVENTORY_ITEM_ID%TYPE,
        item_desc                       MTL_SYSTEM_ITEMS_KFV.DESCRIPTION%TYPE,
        immediate_disposition_code      AHL_PRD_DISPOSITIONS_B.IMMEDIATE_DISPOSITION_CODE%TYPE,
        disposition_id                  AHL_PRD_DISPOSITIONS_B.DISPOSITION_ID%TYPE,
	immediate_type                  FND_LOOKUP_VALUES.MEANING%TYPE,
        condition_code                  MTL_MATERIAL_STATUSES_TL.STATUS_CODE%TYPE,
        condition_id                    AHL_PRD_DISPOSITIONS_B.CONDITION_ID%TYPE,
        serial_number                   CSI_ITEM_INSTANCES.SERIAL_NUMBER%TYPE,
        uom                             AHL_PRD_DISPOSITIONS_B.UOM%TYPE,
        unit_of_measure                 MTL_UNITS_OF_MEASURE_VL.UNIT_OF_MEASURE%TYPE,
        job_status_meaning              FND_LOOKUP_VALUES.MEANING%TYPE,
        lot_number                      CSI_ITEM_INSTANCES.LOT_NUMBER%TYPE,
        item_revision                   CSI_ITEM_INSTANCES.INVENTORY_REVISION%TYPE,
        collection_id                   AHL_PRD_DISPOSITIONS_B.COLLECTION_ID%TYPE,
        instance_id                     AHL_PRD_DISPOSITIONS_B.INSTANCE_ID%TYPE,
        default_pull_supply_subinv      WIP_PARAMETERS.DEFAULT_PULL_SUPPLY_SUBINV%TYPE,
        default_pull_supply_locator_id  WIP_PARAMETERS.DEFAULT_PULL_SUPPLY_LOCATOR_ID%TYPE,
        concatenated_segments           MTL_ITEM_LOCATIONS_KFV.CONCATENATED_SEGMENTS%TYPE,
        quantity                        AHL_PRD_DISPOSITIONS_B.QUANTITY%TYPE,
        net_quantity                    CSI_ITEM_INSTANCES.QUANTITY%TYPE,
	Wo_Net_Total_Qty                NUMBER,
        wip_entity_id                   AHL_WORKORDERS.WIP_ENTITY_ID%TYPE,
	inv_locator_id                  AHL_VISITS_B.INV_LOCATOR_ID%TYPE
	);

   l_disp_rec  l_disp_rec_type;

BEGIN
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL)THEN
        fnd_log.string
        (
            G_LEVEL_PROCEDURE,
            'ahl.plsql.AHL_PRD_MTLTXN_PVT.getDispositionReturn.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    --pdoki added for Bug 9164678 start.

    l_mtl_txn_dtls := '
	SELECT
	    D.WORKORDER_ID,
	    D.WORKORDER_NAME,
	    V.ORGANIZATION_ID,
	    D.WORKORDER_OPERATION_ID,
	    O.OPERATION_SEQUENCE_NUM,
	    D.ITEM_NUMBER,
	    D.INVENTORY_ITEM_ID,
	    D.ITEM_DESC,
	    D.IMMEDIATE_DISPOSITION_CODE,
	    D.DISPOSITION_ID,
	    D.IMMEDIATE_TYPE,
	    D.CONDITION_CODE,
	    D.CONDITION_ID,
	    D.SERIAL_NUMBER,
	    D.UOM,
	    UOM.UNIT_OF_MEASURE,
	    WO_STS.MEANING JOB_STATUS_MEANING,
	    D.LOT_NUMBER,
	    D.ITEM_REVISION,
	    D.COLLECTION_ID,
	    D.INSTANCE_ID,
	    WP.DEFAULT_PULL_SUPPLY_SUBINV,
	    WP.DEFAULT_PULL_SUPPLY_LOCATOR_ID,
	    L.CONCATENATED_SEGMENTS,
	    --SYSDATE,
	    D.QUANTITY, --GOES TO THE ISSUE QTY UI
	    D.NET_QUANTITY,  --GOES TO THE RETURN QTY
	    AHL_PRD_MTLTXN_PVT.GET_WORKORD_NET_QTY(D.WORKORDER_ID,D.INVENTORY_ITEM_ID,V.ORGANIZATION_ID) Wo_Net_Total_Qty,
	    W.WIP_ENTITY_ID,
	    V.INV_LOCATOR_ID
	FROM
	    AHL_MTL_RET_DISPOSITIONS_V D,
	    AHL_VISITS_B V,
	    AHL_WORKORDER_OPERATIONS O,
	    MTL_UNITS_OF_MEASURE_VL UOM,
	    (SELECT LOOKUP_CODE, MEANING FROM FND_LOOKUP_VALUES WHERE LOOKUP_TYPE = ''AHL_JOB_STATUS'' AND LANGUAGE= USERENV(''LANG'')) WO_STS,
	    WIP_PARAMETERS WP,
	    MTL_ITEM_LOCATIONS_KFV L,
	    AHL_WORKORDERS W ';


     l_mtl_txn_dtls_where := '
	WHERE  D.WORKORDER_ID = W.WORKORDER_ID
	AND    W.MASTER_WORKORDER_FLAG = ''N''
	AND    W.STATUS_CODE IN (''3'', ''4'', ''20'')
	AND    W.STATUS_CODE = WO_STS.LOOKUP_CODE
	AND    O.WORKORDER_OPERATION_ID (+) = D.WORKORDER_OPERATION_ID
	AND    O.WORKORDER_ID (+) = D.WORKORDER_ID
	AND    D.UOM = UOM.UOM_CODE
	AND    WP.ORGANIZATION_ID = L.ORGANIZATION_ID(+)
	AND    WP.DEFAULT_PULL_SUPPLY_LOCATOR_ID = L.INVENTORY_LOCATION_ID(+)
	AND    WP.ORGANIZATION_ID = V.ORGANIZATION_ID
	AND    W.VISIT_ID = V.VISIT_ID ';

        l_bind_index := 1;

	IF (P_prd_Mtltxn_criteria_rec.DISPOSITION_NAME IS NOT NULL) THEN
	   l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND D.IMMEDIATE_TYPE LIKE :' || l_bind_index;
	   l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.DISPOSITION_NAME;
           l_bind_index := l_bind_index + 1;
	END IF;

	IF (P_prd_Mtltxn_criteria_rec.JOB_NUMBER IS NOT NULL) THEN
	   l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND W.WORKORDER_NAME LIKE :' || l_bind_index;
	   l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.JOB_NUMBER;
           l_bind_index := l_bind_index + 1;
	END IF;

	IF (P_prd_Mtltxn_criteria_rec.ORGANIZATION_NAME IS NOT NULL) THEN
	  l_mtl_txn_dtls := l_mtl_txn_dtls || ', (SELECT ORGANIZATION_ID, NAME FROM HR_ALL_ORGANIZATION_UNITS_TL WHERE LANGUAGE = USERENV(''LANG'')) ORG';
	  l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND V.ORGANIZATION_ID = ORG.ORGANIZATION_ID
	  AND ORG.NAME LIKE :'|| l_bind_index;
	  l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.ORGANIZATION_NAME;
          l_bind_index := l_bind_index + 1;
	END IF;

	IF (P_prd_Mtltxn_criteria_rec.CONCATENATED_SEGMENTS IS NOT NULL) THEN
	    l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND D.ITEM_NUMBER LIKE :' || l_bind_index;
	    l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.CONCATENATED_SEGMENTS;
            l_bind_index := l_bind_index + 1;
	END IF;

	IF (P_prd_Mtltxn_criteria_rec.PRIORITY IS NOT NULL) THEN
	  l_mtl_txn_dtls := l_mtl_txn_dtls || ', WIP_DISCRETE_JOBS WDJ';
	  l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND WDJ.WIP_ENTITY_ID = W.WIP_ENTITY_ID
	  AND WDJ.PRIORITY = :' || l_bind_index;
	  l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.PRIORITY;
          l_bind_index := l_bind_index + 1;
	END IF;

	IF (P_prd_Mtltxn_criteria_rec.VISIT_NUMBER IS NOT NULL) THEN
	 l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND V.VISIT_NUMBER = :'|| l_bind_index;
	 l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.VISIT_NUMBER;
         l_bind_index := l_bind_index + 1;
	END IF;

	IF (P_prd_Mtltxn_criteria_rec.DEPARTMENT_NAME IS NOT NULL) THEN
	  l_mtl_txn_dtls := l_mtl_txn_dtls || ', WIP_DISCRETE_JOBS WDJ,BOM_DEPARTMENTS B';
	  l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND WDJ.WIP_ENTITY_ID = W.WIP_ENTITY_ID
	  AND WDJ.OWNING_DEPARTMENT = B.DEPARTMENT_ID (+)
	  AND B.DESCRIPTION LIKE :'  || l_bind_index;
	  l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.DEPARTMENT_NAME;
          l_bind_index := l_bind_index + 1;
	END IF;

	IF (P_prd_Mtltxn_criteria_rec.INCIDENT_NUMBER IS NOT NULL) THEN
	  l_mtl_txn_dtls := l_mtl_txn_dtls || ', AHL_VISIT_TASKS_B VT,CS_INCIDENTS_ALL_B C';
	  l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND W.VISIT_TASK_ID = VT.VISIT_TASK_ID
	   AND    V.VISIT_ID = VT.VISIT_ID
	   AND VT.SERVICE_REQUEST_ID = C.INCIDENT_ID(+)
	  AND C.INCIDENT_NUMBER LIKE :' || l_bind_index;
	  l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.INCIDENT_NUMBER;
          l_bind_index := l_bind_index + 1;
	END IF;

	l_mtl_txn_dtls := l_mtl_txn_dtls || l_mtl_txn_dtls_where ;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string
           (
             G_LEVEL_STATEMENT,
             'ahl.plsql.AHL_PRD_MTLTXN_PVT.getDispositionReturn',
             'SQL Query String: ' || l_mtl_txn_dtls
           );
        END IF;

        AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR(l_mtl_txns_returns_cur, l_bind_value_tbl, l_mtl_txn_dtls);

        l_index   :=p_x_ahl_prd_mtl_txn_tbl.count;
        l_index_start := l_index;

      LOOP
         FETCH l_mtl_txns_returns_cur INTO l_disp_rec;
         EXIT WHEN l_mtl_txns_returns_cur%NOTFOUND;

	 --pdoki added for Bug 9164678 end.

            l_valid_flag := TRUE;
            IF (Is_Item_Trackable(l_disp_rec.organization_id, l_disp_rec.INVENTORY_ITEM_ID)) THEN
                -- validate instance location.
                OPEN chk_inst_relationship_csr (l_disp_rec.INVENTORY_ITEM_ID,
                                                l_disp_rec.wip_entity_id,
                                                l_disp_rec.ITEM_Revision,
                                                l_disp_rec.lot_number,
                                                l_disp_rec.Serial_Number);
                FETCH chk_inst_relationship_csr INTO l_junk;
                IF (chk_inst_relationship_csr%NOTFOUND) THEN
                     l_valid_flag := FALSE;
                END IF;
                CLOSE chk_inst_relationship_csr;

                -- sracha: Added for bug# 6328554.
                -- Check for duplicate dispositions for the same instance.
                -- Occurs in case of multiple removals in IB tree case.
                IF (l_valid_flag) AND (l_index > l_index_start) THEN
                  FOR i IN l_index_start..p_x_ahl_prd_mtl_txn_tbl.LAST LOOP
                    IF (l_disp_rec.INVENTORY_ITEM_ID = p_x_ahl_prd_mtl_txn_tbl(i).inventory_item_id) AND
                       (nvl(l_disp_rec.Serial_Number,'1') = nvl(p_x_ahl_prd_mtl_txn_tbl(i).Serial_Number,'1') AND
                        nvl(l_disp_rec.ITEM_Revision,'1') = nvl(p_x_ahl_prd_mtl_txn_tbl(i).Revision,'1') AND
                        nvl(l_disp_rec.lot_number,'1') = nvl(p_x_ahl_prd_mtl_txn_tbl(i).lot_number,'1')) THEN
 	               l_valid_flag := FALSE;
 	               EXIT;
                    END IF;
 	          END LOOP;
 	        END IF; -- (l_valid_flag) AND l_index > l_index_start
 	    END IF; -- Is_Item_Trackable

            IF (l_valid_flag) THEN
               p_x_ahl_prd_mtl_txn_tbl(l_index).workorder_id:=l_disp_rec.workorder_id;
               p_x_ahl_prd_mtl_txn_tbl(l_index).workorder_name:=l_disp_rec.workorder_name;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Organization_Id:=l_disp_rec.Organization_Id;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_operation_Id:=l_disp_rec.Workorder_operation_Id;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Inventory_Item_Segments:=l_disp_rec.ITEM_NUMBER;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Inventory_Item_Id:=l_disp_rec.INVENTORY_ITEM_ID;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Inventory_Item_Description:=l_disp_rec.ITEM_DESC;
               p_x_ahl_prd_mtl_txn_tbl(l_index).disposition_name:=l_disp_rec.IMMEDIATE_TYPE;
               p_x_ahl_prd_mtl_txn_tbl(l_index).disposition_id:=l_disp_rec.disposition_id;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Condition:=l_disp_rec.CONDITION_ID;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Condition_desc:=l_disp_rec.CONDITION_CODE;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Serial_Number:=l_disp_rec.Serial_Number;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Quantity:=l_disp_rec.quantity;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Net_Quantity:=l_disp_rec.Net_quantity;
			   -- JKJAIN FP ER # 6436303 - start
			   p_x_ahl_prd_mtl_txn_tbl(l_index).Net_Total_Qty:=l_disp_rec.Wo_Net_Total_Qty;
			   -- JKJAIN FP ER # 6436303 - end
               p_x_ahl_prd_mtl_txn_tbl(l_index).Uom:=l_disp_rec.Uom;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Uom_DESC:=l_disp_rec.UNIT_OF_MEASURE;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Lot_Number:=l_disp_rec.Lot_Number;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Revision:=l_disp_rec.ITEM_Revision;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Qa_Collection_Id:=l_disp_rec.COLLECTION_ID;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Subinventory_Name:=l_disp_rec.DEFAULT_PULL_SUPPLY_SUBINV;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Locator_Id:=l_disp_rec.DEFAULT_PULL_SUPPLY_LOCATOR_ID;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Locator_Segments:=l_disp_rec.concatenated_segments;
               --p_x_ahl_prd_mtl_txn_tbl(l_index).Transaction_Date   :=l_disp_rec.SYSDATE;
               p_x_ahl_prd_mtl_txn_tbl(l_index).Transaction_Date   :=SYSDATE;

               -- ER 5854712- servicable locator.
               IF (l_disp_rec.inv_locator_id IS NULL) THEN
                  p_x_ahl_prd_mtl_txn_tbl(l_index).visit_locator_flag := '0';
               ELSE
                  p_x_ahl_prd_mtl_txn_tbl(l_index).visit_locator_flag := '1';
               END IF;

               l_index:=l_index+1;

               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)THEN
                   fnd_log.string
                   (
                     G_LEVEL_STATEMENT,
                     'ahl.plsql.AHL_PRD_MTLTXN_PVT.getDispositionReturn',
                     'l_disp_rec.workorder_name: ' || l_disp_rec.workorder_name
                   );
                   fnd_log.string
                   (
                     G_LEVEL_STATEMENT,
                     'ahl.plsql.AHL_PRD_MTLTXN_PVT.getDispositionReturn',
                     'l_disp_rec.workorder_id: ' || l_disp_rec.workorder_id
                   );
                   fnd_log.string
                   (
                     G_LEVEL_STATEMENT,
                     'ahl.plsql.AHL_PRD_MTLTXN_PVT.getDispositionReturn',
                     'l_disp_rec.disposition_id: ' || l_disp_rec.disposition_id
                   );
                   fnd_log.string
                   (
                     G_LEVEL_STATEMENT,
                     'ahl.plsql.AHL_PRD_MTLTXN_PVT.getDispositionReturn',
                     'l_disp_rec.ITEM_NUMBER: ' || l_disp_rec.ITEM_NUMBER
                   );
                   fnd_log.string
                   (
                     G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.getDispositionReturn',
                    'l_disp_rec.serial_number: ' || l_disp_rec.serial_number
                   );
                   fnd_log.string
                   (
                     G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.getDispositionReturn',
                    'l_disp_rec.ISSUEQTY: ' || l_disp_rec.quantity
                   );
                   fnd_log.string
                   (
                     G_LEVEL_STATEMENT,
                     'ahl.plsql.AHL_PRD_MTLTXN_PVT.getDispositionReturn',
                     'Net Qty: ' || l_disp_rec.Net_Quantity
                   );
               END IF; -- G_LEVEL_STATEMENT

            END IF;

    END LOOP;
    CLOSE l_mtl_txns_returns_cur;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL)THEN
        fnd_log.string
        (
            G_LEVEL_PROCEDURE,
            'ahl.plsql.AHL_PRD_MTLTXN_PVT.getDispositionReturn.begin',
            'At the start of PLSQL procedure'
        );
    END IF;
END  getDispositionReturn;


PROCEDURE getMtlTxnsReturns(
            p_x_ahl_prd_mtl_txn_tbl  IN OUT  NOCOPY Ahl_Mtltxn_Tbl_Type,
            P_prd_Mtltxn_criteria_rec in Prd_Mtltxn_criteria_rec
            ) AS

-- pdoki commented for Bug 9164678
/*CURSOR getMtlTxnsReturnsCur
           (
             p_job_number   IN VARCHAR2,
             p_visit_number IN NUMBER,
             p_priority     IN NUMBER,
             p_dept_name    IN VARCHAR2,
             p_org_name     IN VARCHAR2,
             p_item         IN VARCHAR2,
             p_incident_number IN VARCHAR2
           ) IS

/* Tamal [R12 APPSPERF fixes]
 * R12 Drop 4 - SQL ID: 14401324
 * Bug #4918991
 */
/*SELECT DISTINCT
    W.WORKORDER_ID,
    T.ORGANIZATION_ID,
    T.INVENTORY_ITEM_ID,
    T.SERIAL_NUMBER,
    T.LOT_NUMBER,
    T.REVISION,
    T.INSTANCE_ID,   -- added to fix FP bug# 5172147.
    W.WIP_ENTITY_ID,  -- added to filter chk_inst_relationship_csr for wip_job_id.
    (select inv_locator_id from ahl_visits_b where visit_id = w.visit_id) inv_locator_id
FROM
    AHL_WORKORDER_MTL_TXNS T,
    MTL_SYSTEM_ITEMS_KFV I,
    AHL_WORKORDERS W,
    AHL_VISITS_B V,
    AHL_VISIT_TASKS_B VT,
    CS_INCIDENTS_ALL_B C,
    WIP_DISCRETE_JOBS WDJ,
    INV_ORGANIZATION_NAME_V ORG,
    BOM_DEPARTMENTS B,
    AHL_WORKORDER_OPERATIONS O
WHERE
    T.ORGANIZATION_ID = V.ORGANIZATION_ID
    AND T.WORKORDER_OPERATION_ID = O.WORKORDER_OPERATION_ID
    AND W.WORKORDER_ID = O.WORKORDER_ID
    AND T.TRANSACTION_TYPE_ID = 35
    AND T.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND T.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND W.VISIT_TASK_ID = VT.VISIT_TASK_ID
    AND VT.VISIT_ID = V.VISIT_ID
    AND V.SERVICE_REQUEST_ID = C.INCIDENT_ID(+)
    AND WDJ.WIP_ENTITY_ID = W.WIP_ENTITY_ID
    AND WDJ.OWNING_DEPARTMENT = B.DEPARTMENT_ID (+)
    AND V.ORGANIZATION_ID = ORG.ORGANIZATION_ID
    --AND W.STATUS_CODE NOT IN ('5','7','12')
    AND W.STATUS_CODE IN ('3', '4', '20')
    AND I.ENABLED_FLAG = 'Y'
    AND ((I.START_DATE_ACTIVE IS NULL) OR (I.START_DATE_ACTIVE <= SYSDATE))
    AND ((I.END_DATE_ACTIVE IS NULL) OR (I.END_DATE_ACTIVE >= SYSDATE))
    AND I.CONCATENATED_SEGMENTS LIKE NVL(p_item,I.CONCATENATED_SEGMENTS)
    AND UPPER(ORG.ORGANIZATION_NAME) LIKE UPPER(NVL(p_org_name,ORG.ORGANIZATION_NAME))
    AND UPPER(B.DESCRIPTION) LIKE UPPER(NVL(p_dept_name,B.DESCRIPTION))
    AND UPPER(NVL(C.INCIDENT_NUMBER,'X')) LIKE UPPER(NVL(p_incident_number,NVL(C.INCIDENT_NUMBER,'X')))
    AND NVL(WDJ.PRIORITY,0) = NVL(p_priority,NVL(WDJ.PRIORITY,0))
    AND V.VISIT_NUMBER = NVL(p_visit_number,V.VISIT_NUMBER)
    AND UPPER(W.WORKORDER_NAME) LIKE UPPER(NVL(p_job_number,W.WORKORDER_NAME)); */

   --Query to validate disp

   CURSOR CHECK_DISPITEM_CUR
         (
              c_wid in number,
              c_itemId NUMBER,
              --c_org_id IN NUMBER,
              c_sno in varchar2,
              c_rev in varchar2,
              c_lotNumber in varchar2
         ) IS
/* Tamal [R12 APPSPERF fixes]
 * R12 Drop 4 - SQL ID: 14401875
 * Bug #4918991
 * BTW there is no code change here, the ahl_mtl_ret_dispositions_v view has been tuned for performance
 */
SELECT 'T'
FROM AHL_MTL_RET_DISPOSITIONS_V A
WHERE
    WORKORDER_ID = c_wid AND
    INVENTORY_ITEM_ID = c_itemId AND
    --ORGANIZATION_ID = c_org_id AND
    NVL(SERIAL_NUMBER, 'X') = NVL(c_sno, NVL(SERIAL_NUMBER, 'X')) AND
    NVL(LOT_NUMBER, 'X') = NVL(c_lotNumber, NVL(LOT_NUMBER, 'X')) AND
    NVL(ITEM_REVISION, 'X') = NVL(c_rev, NVL(ITEM_REVISION, 'X')) AND
    WORKORDER_OPERATION_ID IS NOT NULL;


   CURSOR mtlOpRtns
         (
               c_wid in number,
               --c_wopId  IN NUMBER,
               c_itemId NUMBER,
               c_org_id IN NUMBER,
               c_sno in varchar2,
               c_rev in varchar2,
               c_lotNumber in varchar2
          ) IS
/* Tamal [R12 APPSPERF fixes]
 * R12 Drop 4 - SQL ID: 14401907
 * Bug #4918991
 */
SELECT DISTINCT
    WO.WORKORDER_ID,
    WO.WORKORDER_NAME JOB_NUMBER ,
    VST.ORGANIZATION_ID,
    TXNS.WORKORDER_OPERATION_ID,
    WO_OP.OPERATION_SEQUENCE_NUM,
    MTL.CONCATENATED_SEGMENTS,
    TXNS.INVENTORY_ITEM_ID,
    MTL.DESCRIPTION,
    TXNS.SERIAL_NUMBER ,
    AHL_PRD_MTLTXN_PVT.GET_ISSUED_QTY(TXNS.ORGANIZATION_ID, TXNS.INVENTORY_ITEM_ID,TXNS.WORKORDER_OPERATION_ID) ISSUEQTY,
-- JKJAIN FP ER # 6436303 - start
 	AHL_PP_MATERIALS_PVT.GET_NET_QTY(TXNS.ORGANIZATION_ID, TXNS.INVENTORY_ITEM_ID,TXNS.WORKORDER_OPERATION_ID) Net_Total_Qty,
-- JKJAIN FP ER # 6436303 - end
    TXNS.UOM,
    UOM.UNIT_OF_MEASURE,
    TXNS.RECEPIENT_ID,
    PER.FULL_NAME,
    WO_STS.MEANING JOB_STATUS_MEANING,
    TXNS.LOT_NUMBER,
    TXNS.REVISION,
    WP.DEFAULT_PULL_SUPPLY_SUBINV,
    WP.DEFAULT_PULL_SUPPLY_LOCATOR_ID,
    --MTL_LOC.CONCATENATED_SEGMENTS LOCATOR
    --Fix for bug number 5903275
    inv_project.GET_LOCSEGS(WP.DEFAULT_PULL_SUPPLY_LOCATOR_ID, WP.organization_id) || fnd_flex_ext.get_delimiter('INV', 'MTLL',  101)
	            || INV_ProjectLocator_PUB.get_project_number(MTL_LOC.segment19) || fnd_flex_ext.get_delimiter('INV', 'MTLL',  101)
            || INV_ProjectLocator_PUB.get_task_number(MTL_LOC.segment20) LOCATOR,
    --SYSDATE
    (select inv_locator_id from ahl_visits_b where visit_id = vst.visit_id) inv_locator_id
FROM
    AHL_WORKORDER_MTL_TXNS TXNS,
    AHL_WORKORDERS WO,
    (SELECT LOOKUP_CODE, MEANING FROM FND_LOOKUP_VALUES WHERE LOOKUP_TYPE = 'AHL_JOB_STATUS' AND LANGUAGE= USERENV('LANG')) WO_STS,
    AHL_VISIT_TASKS_B VST_TASK,
    AHL_VISITS_B VST,
    AHL_WORKORDER_OPERATIONS WO_OP,
    MTL_SYSTEM_ITEMS_KFV MTL,
    MTL_UNITS_OF_MEASURE_VL UOM,
    -- modified to retrieve segment19 and 20 from base table to fix bug# 6611033.
    --MTL_ITEM_LOCATIONS_KFV MTL_LOC,
    MTL_ITEM_LOCATIONS MTL_LOC,
    WIP_PARAMETERS WP,
    PER_ALL_PEOPLE_F PER
WHERE
    TXNS.TRANSACTION_TYPE_ID = 35 AND
    TXNS.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID AND
    TXNS.ORGANIZATION_ID = MTL.ORGANIZATION_ID AND
    TXNS.WORKORDER_OPERATION_ID = WO_OP.WORKORDER_OPERATION_ID AND
    WO_OP.WORKORDER_ID = WO.WORKORDER_ID AND
    TXNS.ORGANIZATION_ID = VST.ORGANIZATION_ID AND
    TXNS.UOM = UOM.UOM_CODE AND
    --MTL_LOC setup is optional(bug# 6761128).
    --MTL_LOC.ORGANIZATION_ID = VST.ORGANIZATION_ID AND
    VST.ORGANIZATION_ID = WP.ORGANIZATION_ID AND
    WO.STATUS_CODE = WO_STS.LOOKUP_CODE AND
    WO.VISIT_TASK_ID = VST_TASK.VISIT_TASK_ID AND
    VST.VISIT_ID = VST_TASK.VISIT_ID AND
    WO.MASTER_WORKORDER_FLAG = 'N' AND
    --WO.STATUS_CODE NOT IN ('17', '22') AND
    WO.STATUS_CODE IN ('3', '4', '20') AND
    WP.ORGANIZATION_ID = MTL_LOC.ORGANIZATION_ID (+) AND
    WP.DEFAULT_PULL_SUPPLY_LOCATOR_ID = MTL_LOC.INVENTORY_LOCATION_ID (+) AND
    TXNS.RECEPIENT_ID = PER.PERSON_ID (+) AND

    WO.WORKORDER_ID = c_wid AND
    MTL.INVENTORY_ITEM_ID =c_itemid AND
    NVL(TXNS.SERIAL_NUMBER,'X') = NVL(c_SNO, NVL(TXNS.SERIAL_NUMBER,'X')) AND
    NVL(TXNS.LOT_NUMBER,'X') = NVL(c_lotNumber, NVL(TXNS.LOT_NUMBER,'X')) AND
    NVL(TXNS.REVISION,'X') = NVL(c_rev, NVL(TXNS.REVISION,'X')) AND
    TXNS.ORGANIZATION_ID = c_ORG_ID;

     CURSOR mtlWoRtns
            (
                c_wid in number,
                c_itemId NUMBER,
                c_org_id IN NUMBER,
                c_sno in varchar2,
                c_rev in varchar2,
                c_lotNumber in varchar2
            ) IS
/* Tamal [R12 APPSPERF fixes]
 * R12 Drop 4 - SQL ID: 14402096
 * Bug #4918991
 */
SELECT DISTINCT
    E.WORKORDER_ID,
    E.WORKORDER_NAME JOB_NUMBER,
    V.ORGANIZATION_ID,
    B.CONCATENATED_SEGMENTS ,
    A.INVENTORY_ITEM_ID,
    B.DESCRIPTION,
    A.SERIAL_NUMBER ,
    AHL_PRD_MTLTXN_PVT.GET_WORKORD_LEVEL_QTY(c_wid, c_itemid, c_ORG_ID, c_lotNumber, c_rev, c_SNO) issWoQty,
 -- JKJAIN FP ER # 6436303 - start
 	AHL_PRD_MTLTXN_PVT.GET_WORKORD_NET_QTY(c_wid,c_itemid,c_ORG_ID) Wo_Net_Total_Qty,
-- JKJAIN FP ER # 6436303 - end
    A.UOM ,
    UOM.unit_of_measure,
    WO_STS.MEANING JOB_STATUS_MEANING,
    A.LOT_NUMBER,
    A.REVISION,
    W.DEFAULT_PULL_SUPPLY_SUBINV,
    W.DEFAULT_PULL_SUPPLY_LOCATOR_ID,
    --D.CONCATENATED_SEGMENTS Locator
    -- Fix for bug number 5903275
    inv_project.GET_LOCSEGS(W.DEFAULT_PULL_SUPPLY_LOCATOR_ID, W.organization_id) || fnd_flex_ext.get_delimiter('INV', 'MTLL',  101)
	                || INV_ProjectLocator_PUB.get_project_number(D.segment19) || fnd_flex_ext.get_delimiter('INV', 'MTLL',  101)
            || INV_ProjectLocator_PUB.get_task_number(D.segment20) LOCATOR,
    --SYSDATE
    (select inv_locator_id from ahl_visits_b where visit_id = E.visit_id) inv_locator_id
FROM
    AHL_WORKORDER_MTL_TXNS A,
    MTL_SYSTEM_ITEMS_KFV B,
    MTL_UNITS_OF_MEASURE_VL UOM,
    -- modified to retrieve segment19 and 20 from base table to fix bug# 6611033.
    --MTL_ITEM_LOCATIONS_KFV D,
    MTL_ITEM_LOCATIONS D,
    AHL_WORKORDERS E,
    (SELECT LOOKUP_CODE, MEANING FROM FND_LOOKUP_VALUES WHERE LOOKUP_TYPE = 'AHL_JOB_STATUS' AND LANGUAGE= USERENV('LANG')) WO_STS,
    AHL_VISITS_B V,
    AHL_VISIT_TASKS_B VT,
    AHL_WORKORDER_OPERATIONS F,
    WIP_PARAMETERS W
WHERE
    A.INVENTORY_ITEM_ID=B.INVENTORY_ITEM_ID
    AND A.WORKORDER_OPERATION_ID=F.WORKORDER_OPERATION_ID
    AND A.ORGANIZATION_ID=B.ORGANIZATION_ID
    AND A.ORGANIZATION_ID=V.ORGANIZATION_ID
    AND A.TRANSACTION_TYPE_ID=35
    AND A.uom=UOM.uom_code
    --MTL_LOC setup is optional(bug# 6761128).
    --AND D.organization_id=V.organization_id
    AND F.WORKORDER_ID=E.WORKORDER_ID
    AND E.VISIT_TASK_ID = VT.VISIT_TASK_ID
    AND E.MASTER_WORKORDER_FLAG = 'N'
    --AND E.STATUS_CODE NOT IN ('17', '22')
    AND E.STATUS_CODE IN ('3', '4', '20')
    AND E.STATUS_CODE = WO_STS.LOOKUP_CODE
    AND VT.VISIT_ID = V.VISIT_ID
    AND V.ORGANIZATION_ID=W.ORGANIZATION_ID
    AND W.organization_id = D.organization_id(+)
    AND W.default_pull_supply_locator_id =D.inventory_location_id(+)

    AND E.workorder_id = c_wid
    AND B.INVENTORY_ITEM_ID = c_itemid
    AND NVL(A.SERIAL_NUMBER, 'X') = NVL(c_SNO ,NVL(A.SERIAL_NUMBER, 'X'))
    AND NVL(A.lot_number, 'X') = NVL(c_lotNumber ,NVL(A.LOT_NUMBER, 'X'))
    AND NVL(A.revision, 'X') = NVL(c_rev ,NVL(A.REVISION, 'X'))
    AND A.organization_id = c_ORG_ID;

    -- check if issued instance has been installed / validate instance.
    -- and is located in the wip job.
    CURSOR chk_inst_relationship_csr (p_instance_id IN NUMBER,
                                      p_wip_entity_id IN NUMBER) IS
       SELECT 'x'
       FROM  CSI_ITEM_INSTANCES CII
       WHERE CII.INSTANCE_ID = p_instance_id
         AND CII.ACTIVE_START_DATE <= SYSDATE
         AND ((CII.ACTIVE_END_DATE IS NULL) OR (CII.ACTIVE_END_DATE > SYSDATE))
         AND CII.QUANTITY > 0
         AND CII.LOCATION_TYPE_CODE = 'WIP'
         AND CII.WIP_JOB_ID = p_wip_entity_id
         AND NOT EXISTS (SELECT 'X' FROM CSI_II_RELATIONSHIPS CIR
                         WHERE CIR.SUBJECT_ID = CII.INSTANCE_ID
                           AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                           AND SYSDATE BETWEEN NVL(CIR.ACTIVE_START_DATE,SYSDATE) AND NVL(CIR.ACTIVE_END_DATE,SYSDATE));

      l_index      NUMBER := p_x_ahl_prd_mtl_txn_tbl.count;
      l_qty       NUMBER  := 0;
      l_opseq_flag varchar2(1);
      l_junk       varchar2(1);
      l_valid_flag BOOLEAN;

      -- pdoki added for Bug 9164678
      l_bind_value_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
      l_mtl_txns_returns_cur AHL_OSP_UTIL_PKG.ahl_search_csr;
      l_bind_index NUMBER;
      l_mtl_txn_dtls VARCHAR2(10000);
      l_mtl_txn_dtls_where VARCHAR2(10000);

      TYPE l_mtlTxn_rec_type IS RECORD (
	      workorder_id      AHL_WORKORDERS.WORKORDER_ID%TYPE,
	      organization_id   AHL_WORKORDER_MTL_TXNS.ORGANIZATION_ID%TYPE,
	      inventory_item_id AHL_WORKORDER_MTL_TXNS.INVENTORY_ITEM_ID%TYPE,
              serial_number     AHL_WORKORDER_MTL_TXNS.SERIAL_NUMBER%TYPE,
	      lot_number        AHL_WORKORDER_MTL_TXNS.LOT_NUMBER%TYPE,
	      revision          AHL_WORKORDER_MTL_TXNS.REVISION%TYPE,
	      instance_id       AHL_WORKORDER_MTL_TXNS.INSTANCE_ID%TYPE,
	      wip_entity_id     AHL_WORKORDERS.WIP_ENTITY_ID%TYPE,
	      inv_locator_id    AHL_VISITS_B.INV_LOCATOR_ID%TYPE
	      );
     l_mtlTxn_rec  l_mtlTxn_rec_type;

BEGIN
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL)THEN
        fnd_log.string
        (
            G_LEVEL_PROCEDURE,
            'ahl.plsql.AHL_PRD_MTLTXN_PVT.getMtlTxnsReturns.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    -- pdoki added for Bug 9164678 start.
    l_mtl_txn_dtls := '
	SELECT DISTINCT
	    W.WORKORDER_ID,
	    T.ORGANIZATION_ID,
	    T.INVENTORY_ITEM_ID,
	    T.SERIAL_NUMBER,
	    T.LOT_NUMBER,
	    T.REVISION,
	    T.INSTANCE_ID,
	    W.WIP_ENTITY_ID,
	    V.INV_LOCATOR_ID
	FROM
	    AHL_WORKORDER_MTL_TXNS T,
	    AHL_WORKORDERS W,
	    AHL_WORKORDER_OPERATIONS O,
	    AHL_VISITS_B V ' ;

    l_mtl_txn_dtls_where := '
	   WHERE T.TRANSACTION_TYPE_ID = 35
	   AND   W.STATUS_CODE IN (''3'', ''4'', ''20'')
	   AND   W.VISIT_ID = V.VISIT_ID
	   AND W.WORKORDER_ID = O.WORKORDER_ID
	   AND T.WORKORDER_OPERATION_ID = O.WORKORDER_OPERATION_ID ' ;

   l_bind_index := 1;

IF (P_prd_Mtltxn_criteria_rec.JOB_NUMBER IS NOT NULL) THEN
   l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND W.WORKORDER_NAME LIKE :'||l_bind_index;
   l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.JOB_NUMBER;
   l_bind_index := l_bind_index + 1;
END IF;

IF (P_prd_Mtltxn_criteria_rec.ORGANIZATION_NAME IS NOT NULL) THEN
  l_mtl_txn_dtls := l_mtl_txn_dtls || ', HR_ORGANIZATION_UNITS ORG';
  l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND T.ORGANIZATION_ID = ORG.ORGANIZATION_ID
  AND ORG.NAME LIKE :'||l_bind_index;
  l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.ORGANIZATION_NAME;
  l_bind_index := l_bind_index + 1;
END IF;

IF (P_prd_Mtltxn_criteria_rec.CONCATENATED_SEGMENTS IS NOT NULL) THEN
  l_mtl_txn_dtls := l_mtl_txn_dtls || ', MTL_SYSTEM_ITEMS_KFV I';
  l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND T.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
  AND T.ORGANIZATION_ID = I.ORGANIZATION_ID AND I.ENABLED_FLAG = ''Y''
  AND ((I.START_DATE_ACTIVE IS NULL) OR (I.START_DATE_ACTIVE <= SYSDATE))
  AND ((I.END_DATE_ACTIVE IS NULL) OR (I.END_DATE_ACTIVE >= SYSDATE))
  AND I.CONCATENATED_SEGMENTS LIKE :'||l_bind_index;
  l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.CONCATENATED_SEGMENTS;
  l_bind_index := l_bind_index + 1;

END IF;

IF (P_prd_Mtltxn_criteria_rec.PRIORITY IS NOT NULL) THEN
  l_mtl_txn_dtls := l_mtl_txn_dtls || ', WIP_DISCRETE_JOBS WDJ';
  l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND WDJ.WIP_ENTITY_ID = W.WIP_ENTITY_ID
  AND WDJ.PRIORITY = :'||l_bind_index;
  l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.PRIORITY;
  l_bind_index := l_bind_index + 1;
END IF;

IF (P_prd_Mtltxn_criteria_rec.VISIT_NUMBER IS NOT NULL) THEN
  IF (instr(P_prd_Mtltxn_criteria_rec.VISIT_NUMBER,'%') > 0)  THEN
    l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND V.VISIT_NUMBER LIKE :'||l_bind_index;
  ELSE
   l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND V.VISIT_NUMBER = :'||l_bind_index;
  END IF;

  l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.VISIT_NUMBER;
  l_bind_index := l_bind_index + 1;
END IF;

IF (P_prd_Mtltxn_criteria_rec.DEPARTMENT_NAME IS NOT NULL) THEN
  l_mtl_txn_dtls := l_mtl_txn_dtls || ', WIP_DISCRETE_JOBS WDJ,BOM_DEPARTMENTS B';
  l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND WDJ.WIP_ENTITY_ID = W.WIP_ENTITY_ID
  AND WDJ.OWNING_DEPARTMENT = B.DEPARTMENT_ID (+)
  AND B.DESCRIPTION LIKE :'||l_bind_index;
  l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.DEPARTMENT_NAME;
  l_bind_index := l_bind_index + 1;
END IF;

IF (P_prd_Mtltxn_criteria_rec.INCIDENT_NUMBER IS NOT NULL) THEN
  IF (P_prd_Mtltxn_criteria_rec.VISIT_NUMBER IS NOT NULL) THEN
    l_mtl_txn_dtls := l_mtl_txn_dtls || ',AHL_VISIT_TASKS_B VT,CS_INCIDENTS_ALL_B C';
    l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND W.VISIT_TASK_ID = VT.VISIT_TASK_ID AND VT.SERVICE_REQUEST_ID = C.INCIDENT_ID(+)
                            AND C.INCIDENT_NUMBER LIKE :'||l_bind_index;
    l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.INCIDENT_NUMBER;
    l_bind_index := l_bind_index + 1;
  ELSE
    l_mtl_txn_dtls := l_mtl_txn_dtls || ', AHL_VISITS_B V,AHL_VISIT_TASKS_B VT,CS_INCIDENTS_ALL_B C';
    l_mtl_txn_dtls_where := l_mtl_txn_dtls_where || ' AND W.VISIT_TASK_ID = VT.VISIT_TASK_ID
                            AND VT.VISIT_ID = V.VISIT_ID
                            AND VT.SERVICE_REQUEST_ID = C.INCIDENT_ID(+)
                            AND C.INCIDENT_NUMBER LIKE :'||l_bind_index;
    l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.INCIDENT_NUMBER;
    l_bind_index := l_bind_index + 1;
  END IF;

END IF;

l_mtl_txn_dtls := l_mtl_txn_dtls || l_mtl_txn_dtls_where ;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)THEN
      fnd_log.string
      (
             G_LEVEL_STATEMENT,
             'ahl.plsql.AHL_PRD_MTLTXN_PVT.getMtlTxnsReturns',
             'SQL Query String: ' || l_mtl_txn_dtls
      );
END IF;

AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR(l_mtl_txns_returns_cur, l_bind_value_tbl, l_mtl_txn_dtls);


    LOOP
      FETCH l_mtl_txns_returns_cur INTO l_mtlTxn_rec;
      EXIT WHEN l_mtl_txns_returns_cur%NOTFOUND;
    --pdoki added for Bug 9164678 end.

      l_valid_flag := TRUE;
       -- check if instance id has been installed.
       IF (l_mtlTxn_rec.instance_id IS NOT NULL) THEN
          OPEN chk_inst_relationship_csr (l_mtlTxn_rec.instance_id, l_mtlTxn_rec.wip_entity_id);
          FETCH chk_inst_relationship_csr INTO l_junk;
          IF (chk_inst_relationship_csr%NOTFOUND) THEN
               l_valid_flag := FALSE;
          END IF;
          CLOSE chk_inst_relationship_csr;
       END IF;

       IF (l_valid_flag) THEN
          OPEN CHECK_DISPITEM_CUR(
            c_wid           => l_mtlTxn_rec.Workorder_Id,
            c_itemId        => l_mtlTxn_rec.Inventory_Item_Id,
            --c_org_id        => l_mtlTxn_rec.Organization_Id,
            c_sno           => l_mtlTxn_rec.Serial_Number,
            c_rev           => l_mtlTxn_rec.Revision,
            c_lotNumber     => l_mtlTxn_rec.Lot_Number
          );
          FETCH CHECK_DISPITEM_CUR into l_opseq_flag;
          IF CHECK_DISPITEM_CUR%FOUND THEN
            l_opseq_flag :='T';
          ELSE
            l_opseq_flag :='F';
          END IF;
          CLOSE CHECK_DISPITEM_CUR;

          IF (l_opseq_flag = 'T') THEN -- Fetch material operations returs
            FOR l_mtloprtns_rec IN   mtlOpRtns (
               c_wid           => l_mtlTxn_rec.Workorder_Id,
--             c_wopId         => l_mtlTxn_rec.Workorder_operation_id,
               c_itemId        => l_mtlTxn_rec.Inventory_Item_Id,
               c_org_id        => l_mtlTxn_rec.Organization_Id,
               c_sno           => l_mtlTxn_rec.Serial_Number,
               c_rev           => l_mtlTxn_rec.Revision,
               c_lotNumber     => l_mtlTxn_rec.Lot_Number)
            LOOP
              CALCULATE_QTY(
                  p_wo_id   => l_mtloprtns_rec.Workorder_Id,
                  p_item_id => l_mtloprtns_rec.Inventory_Item_Id,
                  p_org_id  => l_mtloprtns_rec.Organization_Id,
                  p_lot_num => l_mtloprtns_rec.Lot_Number,
                  p_rev_num => l_mtloprtns_rec.Revision,
                  p_serial_num => l_mtloprtns_rec.Serial_Number,
                  x_qty => l_qty,
                  p_wo_op_id    => l_mtloprtns_rec.Workorder_operation_Id
                  );

              IF (l_qty >0) THEN
                p_x_ahl_prd_mtl_txn_tbl(l_index).workorder_id       :=l_mtloprtns_rec.workorder_id;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Organization_Id    :=l_mtloprtns_rec.Organization_Id;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_Name     :=l_mtloprtns_rec.JOB_NUMBER;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Operation_Seq_Num  :=l_mtloprtns_rec.OPERATION_SEQUENCE_NUM;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_operation_Id:=l_mtloprtns_rec.Workorder_operation_Id;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Inventory_Item_Segments:=l_mtloprtns_rec.CONCATENATED_SEGMENTS;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Inventory_Item_Id  :=l_mtloprtns_rec.INVENTORY_ITEM_ID;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Inventory_Item_Description:=l_mtloprtns_rec.DESCRIPTION;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_Status   :=l_mtloprtns_rec.JOB_STATUS_MEANING;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Serial_Number      :=l_mtloprtns_rec.Serial_Number;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Quantity           :=l_mtloprtns_rec.ISSUEQTY;
				-- JKJAIN FP ER # 6436303- start
 	            p_x_ahl_prd_mtl_txn_tbl(l_index).Net_Total_Qty      :=l_mtloprtns_rec.Net_Total_Qty;
 	            -- JKJAIN FP ER # 6436303- end
                p_x_ahl_prd_mtl_txn_tbl(l_index).Uom                :=l_mtloprtns_rec.Uom;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Uom_Desc           :=l_mtloprtns_rec.UNIT_OF_MEASURE;
                p_x_ahl_prd_mtl_txn_tbl(l_index).recepient_name     :=l_mtloprtns_rec.FULL_NAME;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_Status   :=l_mtloprtns_rec.JOB_STATUS_MEANING;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Lot_Number         :=l_mtloprtns_rec.Lot_Number;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Revision           :=l_mtloprtns_rec.Revision;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Subinventory_Name  :=l_mtloprtns_rec.DEFAULT_PULL_SUPPLY_SUBINV;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Locator_Id         :=l_mtloprtns_rec.DEFAULT_PULL_SUPPLY_LOCATOR_ID;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Locator_Segments   :=l_mtloprtns_rec.Locator;
                --p_x_ahl_prd_mtl_txn_tbl(l_index).Transaction_Date   :=l_mtloprtns_rec.SYSDATE;
                p_x_ahl_prd_mtl_txn_tbl(l_index).Transaction_Date   :=SYSDATE;

                --ER 5854712. retrieve visit locator.
                IF (l_mtloprtns_rec.inv_locator_id IS NULL) THEN
                   p_x_ahl_prd_mtl_txn_tbl(l_index).visit_locator_flag := '0';
                ELSE
                   p_x_ahl_prd_mtl_txn_tbl(l_index).visit_locator_flag := '1';
                END IF;

                l_index:=l_index+1;
              END IF;
            END LOOP;
        ELSE -- Fetch material workorder returns

           FOR l_mtlWoRtns_rec IN mtlWoRtns(
            c_wid           => l_mtlTxn_rec.Workorder_Id,
            c_itemId        => l_mtlTxn_rec.Inventory_Item_Id,
            c_org_id        => l_mtlTxn_rec.Organization_Id,
            c_sno           => l_mtlTxn_rec.Serial_Number,
            c_rev           => l_mtlTxn_rec.Revision,
            c_lotNumber     => l_mtlTxn_rec.Lot_Number)
           LOOP
             IF (l_mtlTxn_rec.instance_id IS NULL) THEN
                -- only non-serialized case.
                CALCULATE_QTY(
                  p_wo_id   => l_mtlWoRtns_rec.Workorder_Id,
                  p_item_id => l_mtlWoRtns_rec.Inventory_Item_Id,
                  p_org_id  => l_mtlWoRtns_rec.Organization_Id,
                  p_lot_num => l_mtlWoRtns_rec.Lot_Number,
                  p_rev_num => l_mtlWoRtns_rec.Revision,
                  p_serial_num => l_mtlWoRtns_rec.Serial_Number,
                  x_qty => l_qty,
                  p_wo_op_id    => null
                );
             /* do not process tracked serialized instances. These will be processed by getTrackedWOMtl api.
             ELSE
                -- serialized
                l_qty := 1;
             END IF;
             */

             IF (l_qty > 0) THEN
              p_x_ahl_prd_mtl_txn_tbl(l_index).workorder_id           :=l_mtlWoRtns_rec.workorder_id;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Organization_Id        :=l_mtlWoRtns_rec.Organization_Id;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_Name         :=l_mtlWoRtns_rec.JOB_NUMBER;
              --p_x_ahl_prd_mtl_txn_tbl(l_index).Operation_Seq_Num      :=l_mtlWoRtns_rec.OPERATION_SEQUENCE_NUM;
              --p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_operation_Id :=l_mtlWoRtns_rec.Workorder_operation_Id;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Inventory_Item_Segments:=l_mtlWoRtns_rec.CONCATENATED_SEGMENTS;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Inventory_Item_Id      :=l_mtlWoRtns_rec.INVENTORY_ITEM_ID;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Inventory_Item_Description:=l_mtlWoRtns_rec.DESCRIPTION;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_Status       :=l_mtlWoRtns_rec.JOB_STATUS_MEANING;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Serial_Number          :=l_mtlWoRtns_rec.Serial_Number;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Quantity               :=l_mtlWoRtns_rec.issWoQty;
			  -- JKJAIN FP ER # 6436303- start
 	          p_x_ahl_prd_mtl_txn_tbl(l_index).Net_Total_Qty          :=l_mtlWoRtns_rec.Wo_Net_Total_Qty;
 	          -- JKJAIN FP ER # 6436303- end
              p_x_ahl_prd_mtl_txn_tbl(l_index).Net_Quantity           :=l_qty;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Uom                    :=l_mtlWoRtns_rec.Uom;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Uom_Desc               :=l_mtlWoRtns_rec.UNIT_OF_MEASURE;
              --p_x_ahl_prd_mtl_txn_tbl(l_index).recepient_name       :=l_mtlWoRtns_rec.FULL_NAME;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_Status       :=l_mtlWoRtns_rec.JOB_STATUS_MEANING;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Lot_Number             :=l_mtlWoRtns_rec.Lot_Number;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Revision               :=l_mtlWoRtns_rec.Revision;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Subinventory_Name      :=l_mtlWoRtns_rec.DEFAULT_PULL_SUPPLY_SUBINV;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Locator_Id             :=l_mtlWoRtns_rec.DEFAULT_PULL_SUPPLY_LOCATOR_ID;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Locator_Segments       :=l_mtlWoRtns_rec.Locator;
              --p_x_ahl_prd_mtl_txn_tbl(l_index).Transaction_Date       :=l_mtlWoRtns_rec.SYSDATE;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Transaction_Date       :=SYSDATE;

              -- ER 5854712.
              IF (l_mtlWoRtns_rec.inv_locator_id IS NULL) THEN
                 p_x_ahl_prd_mtl_txn_tbl(l_index).visit_locator_flag := '0';
              ELSE
                 p_x_ahl_prd_mtl_txn_tbl(l_index).visit_locator_flag := '1';
              END IF;

              l_index:=l_index+1;

            END IF; -- l_qty > 0
          END IF; -- l_mtlTxn_rec.instance_id

              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)THEN
                  fnd_log.string
                  (
                    G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.getMtlTxnsReturns',
                    'l_mtlWoRtns_rec.workorder_id: ' || l_mtlWoRtns_rec.workorder_id
                  );
                  fnd_log.string
                  (
                    G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.getMtlTxnsReturns',
                    'l_mtlWoRtns_rec.job_number: ' || l_mtlWoRtns_rec.job_number
                  );
                  fnd_log.string
                  (
                    G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.getMtlTxnsReturns',
                    'l_mtlWoRtns_rec.CONCATENATED_SEGMENTS: ' || l_mtlWoRtns_rec.CONCATENATED_SEGMENTS
                  );
                  fnd_log.string
                  (
                    G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.getMtlTxnsReturns',
                    'l_mtlWoRtns_rec.serial_number: ' || l_mtlWoRtns_rec.serial_number
                  );
                  fnd_log.string
                  (
                    G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.getMtlTxnsReturns',
                    'l_mtlWoRtns_rec.issWoQty: ' || l_mtlWoRtns_rec.issWoQty
                  );
                  fnd_log.string
                  (
                    G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.l_mtlWoRtns_rec',
                    'l_mtlWoRtns_rec.Net_Quantity: ' || l_qty
                  );

              END IF; -- debug messages.

           END LOOP;
         END IF; -- l_opseq_flag = 'T'
       END IF; -- l_valid_flag
    END LOOP;
    CLOSE l_mtl_txns_returns_cur;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL)THEN
        fnd_log.string
        (
            G_LEVEL_PROCEDURE,
            'ahl.plsql.AHL_PRD_MTLTXN_PVT.getMtlTxnsReturns.end',
            'At the end of PLSQL procedure'
        );
    END IF;

END getMtlTxnsReturns;

-- Added for FP bug# 5903256.
-- This procedure will retrieve all trackable parts in the job
-- Fix for bug# 7579641 -- renamed api name to getTrackedWOMtl
-- this API bypasses issued and tracked non-serialized items
PROCEDURE getTrackedWOMtl ( p_x_ahl_prd_mtl_txn_tbl   IN OUT  NOCOPY Ahl_Mtltxn_Tbl_Type,
                            p_prd_Mtltxn_criteria_rec IN Prd_Mtltxn_criteria_rec) IS

   --pdoki commented for Bug 9164678

    -- Added for bug fix 6594140.
    -- get tracked items in a workorder.
  /*  CURSOR get_tracked_inst_csr(
                                p_job_number   IN VARCHAR2,
                                p_visit_number IN NUMBER,
                                p_priority     IN NUMBER,
                                p_dept_name    IN VARCHAR2,
                                p_org_name     IN VARCHAR2,
                                p_item         IN VARCHAR2,
                                p_incident_number IN VARCHAR2) IS

        SELECT  W.WORKORDER_ID,
               W.job_number,
               W.job_status_meaning,
               I.Description,
               W.ORGANIZATION_ID,
               csi.INVENTORY_ITEM_ID,
               I.concatenated_segments,
               csi.SERIAL_NUMBER ,
               csi.LOT_NUMBER,
               csi.INVENTORY_REVISION REVISION,
               csi.INSTANCE_ID,
               W.WIP_ENTITY_ID,
               csi.quantity,
               csi.Unit_Of_measure UOM,
               UOM.unit_of_measure,
               P.DEFAULT_PULL_SUPPLY_SUBINV,
               P.DEFAULT_PULL_SUPPLY_LOCATOR_ID,
               inv_project.GET_LOCSEGS(P.DEFAULT_PULL_SUPPLY_LOCATOR_ID, W.organization_id)|| '.'
               ||
               DECODE(D.segment19,NULL,NULL,inv_project.GET_PROJECT_NUMBER(D.segment19)) || '.'
               ||
               DECODE(D.segment20,NULL,NULL,inv_project.GET_TASK_NUMBER(D.segment20)) Locator,
               (select inv_locator_id from ahl_visits_b where visit_id = w.visit_id) inv_locator_id
       FROM
               CSI_ITEM_INSTANCES CSI,
               MTL_SYSTEM_ITEMS_KFV I,
               AHL_SEARCH_WORKORDERS_v W,
               WIP_PARAMETERS P,
               MTL_UNITS_OF_MEASURE_VL UOM,
               MTL_ITEM_LOCATIONS D,
               MTL_PARAMETERS MP
       WHERE
             csi.inventory_item_id = I.inventory_item_id
       AND   W.organization_id = MP.organization_id
       AND   csi.inv_master_organization_id  = mp.master_organization_id
       AND   MP.organization_id = I.organization_id
       AND   CSI.WIP_JOB_ID = W.WIP_ENTITY_ID
       AND   CSI.LOCATION_TYPE_CODE = 'WIP'
       AND   W.organization_id = P.organization_id
       AND   CSI.Unit_Of_Measure = UOM.UOM_CODE
       AND   P.default_pull_supply_locator_id = D.inventory_location_id(+)
       AND   P.organization_id = D.organization_id(+)
       AND   I.ENABLED_FLAG = 'Y'
       --AND   W.JOB_STATUS_CODE NOT IN ('5','7','12')
       AND   W.JOB_STATUS_CODE IN ('3','4','20')
       AND   ((I.START_DATE_ACTIVE IS NULL) OR (I.START_DATE_ACTIVE <= SYSDATE))
       AND   ((I.END_DATE_ACTIVE IS NULL) OR (I.END_DATE_ACTIVE >= SYSDATE))
       AND   UPPER(I.concatenated_segments) LIKE UPPER(nvl(p_item,I.concatenated_segments))
       AND   UPPER(W.ORGANIZATION_NAME) LIKE UPPER(NVL(p_org_name,W.ORGANIZATION_NAME))
       AND   UPPER(W.DEPARTMENT_NAME) LIKE UPPER(NVL(p_dept_name,W.DEPARTMENT_NAME))
       AND   UPPER(NVL(W.INCIDENT_NUMBER,'x')) LIKE UPPER(NVL(p_incident_number,NVL(W.INCIDENT_NUMBER,'x')))
       AND   NVL(W.PRIORITY,0) = NVL(p_priority,NVL(W.PRIORITY,0))
       AND   W.VISIT_NUMBER = NVL(p_visit_number,W.VISIT_NUMBER)
       AND   UPPER(W.JOB_NUMBER) LIKE UPPER(NVL(p_job_number,W.job_number))
       AND   NOT EXISTS (SELECT 'X' FROM CSI_II_RELATIONSHIPS CIR
                         WHERE CIR.SUBJECT_ID = CSI.INSTANCE_Id
                           AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                           AND SYSDATE BETWEEN NVL(ACTIVE_START_DATE,SYSDATE)
                           AND NVL(ACTIVE_END_DATE,SYSDATE))
       /* fix for bug# 	6310766: extra row being displayed with 0 qty
          -- split this query into two to handle serialized and non-serialized items.
       AND   NOT EXISTS (SELECT 'x'
                         from ahl_workorder_mtl_txns txn, AHL_WORKORDER_OPERATIONS o
                         where txn.workorder_operation_id = o.workorder_operation_id
                           and o.workorder_id = w.workorder_id
                           and txn.instance_id = csi.instance_id
                           and txn.TRANSACTION_TYPE_ID    = 35)
       */
       -- for non-serialized items
    /*   AND   NOT EXISTS (SELECT 'x'
                         from ahl_workorder_mtl_txns txn, AHL_WORKORDER_OPERATIONS o
                         where txn.workorder_operation_id = o.workorder_operation_id
                           and o.workorder_id = w.workorder_id
                           and txn.TRANSACTION_TYPE_ID    = 35
                           and txn.serial_number is null
                           and txn.inventory_item_id = csi.inventory_item_id
                           and nvl(txn.REVISION, 'x') = nvl(csi.inventory_revision,'x')
                           and nvl(txn.lot_number,'x') = nvl(csi.lot_number,'x')
                        )
       AND CSI.ACTIVE_START_DATE     <= SYSDATE
       AND ((CSI.ACTIVE_END_DATE IS NULL) OR (CSI.ACTIVE_END_DATE > SYSDATE))
       AND CSI.quantity > 0; */


       -- Check existence of disposition.
      CURSOR ahl_disp_csr (p_workorder_id IN NUMBER,
                           p_instance_id  IN NUMBER) IS
        SELECT 'X'
        FROM AHL_MTL_RET_DISPOSITIONS_V disp
        WHERE disp.WORKORDER_ID= p_WORKORDER_ID
          AND disp.instance_id = p_instance_id;

      l_index      NUMBER := p_x_ahl_prd_mtl_txn_tbl.count;
      l_junk       varchar2(1);

      --pdoki added for Bug 9164678
      l_bind_value_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
      l_mtl_txns_returns_cur AHL_OSP_UTIL_PKG.ahl_search_csr;
      l_bind_index NUMBER;
      l_mtl_txn_dtls VARCHAR2(10000);
      l_mtl_txn_dtls_where VARCHAR2(10000);

      TYPE l_mtl_txn_rec_type IS RECORD (
	      workorder_id                    AHL_WORKORDERS.WORKORDER_ID%TYPE,
	      job_number                      AHL_WORKORDERS.WORKORDER_NAME%TYPE,
	      job_status_meaning              FND_LOOKUP_VALUES_VL.MEANING%TYPE,
	      description                     MTL_SYSTEM_ITEMS_KFV.DESCRIPTION%TYPE,
              organization_id                 AHL_VISITS_B.ORGANIZATION_ID%TYPE,
              inventory_item_id               CSI_ITEM_INSTANCES.INVENTORY_ITEM_ID%TYPE,
	      concatenated_segments           MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE,
              serial_number                   CSI_ITEM_INSTANCES.SERIAL_NUMBER%TYPE,
	      lot_number                      CSI_ITEM_INSTANCES.LOT_NUMBER%TYPE,
	      revision                        CSI_ITEM_INSTANCES.INVENTORY_REVISION%TYPE,
	      instance_id                     CSI_ITEM_INSTANCES.INSTANCE_ID%TYPE,
              wip_entity_id                   AHL_WORKORDERS.WIP_ENTITY_ID%TYPE,
              quantity                        CSI_ITEM_INSTANCES.QUANTITY%TYPE,
              uom                             CSI_ITEM_INSTANCES.UNIT_OF_MEASURE%TYPE,
              unit_of_measure                 MTL_UNITS_OF_MEASURE_VL.UNIT_OF_MEASURE%TYPE,
              default_pull_supply_subinv      WIP_PARAMETERS.DEFAULT_PULL_SUPPLY_SUBINV%TYPE,
              default_pull_supply_locator_id  WIP_PARAMETERS.DEFAULT_PULL_SUPPLY_LOCATOR_ID%TYPE,
              locator                         VARCHAR2(500),
	      inv_locator_id                  AHL_VISITS_B.INV_LOCATOR_ID%TYPE );

     l_mtl_txn_rec  l_mtl_txn_rec_type;

BEGIN

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL)THEN
                fnd_log.string
                (
                        G_LEVEL_PROCEDURE,
                        'ahl.plsql.AHL_PRD_MTLTXN_PVT.getTrackedWOMtl.Begin',
                        'At the Start of PLSQL procedure'
                );
    END IF;

        --pdoki added for Bug 9164678 start.
        l_mtl_txn_dtls := '
	SELECT    W.WORKORDER_ID,
		  W.WORKORDER_NAME JOB_NUMBER,
		  MLU.MEANING JOB_STATUS_MEANING,
		  I.DESCRIPTION,
		  V.ORGANIZATION_ID,
		  C.INVENTORY_ITEM_ID,
		  I.CONCATENATED_SEGMENTS,
		  C.SERIAL_NUMBER ,
		  C.LOT_NUMBER,
		  C.INVENTORY_REVISION REVISION,
		  C.INSTANCE_ID,
		  W.WIP_ENTITY_ID,
		  C.QUANTITY,
		  C.UNIT_OF_MEASURE UOM,
		  UOM.UNIT_OF_MEASURE,
		  P.DEFAULT_PULL_SUPPLY_SUBINV,
		  P.DEFAULT_PULL_SUPPLY_LOCATOR_ID,
		  INV_PROJECT.GET_LOCSEGS(P.DEFAULT_PULL_SUPPLY_LOCATOR_ID, V.ORGANIZATION_ID)
		  || ''.''
		  || DECODE(D.SEGMENT19,NULL,NULL, INV_PROJECT.GET_PROJECT_NUMBER(D.SEGMENT19))
		  || ''.''
		  || DECODE(D.SEGMENT20, NULL,NULL,INV_PROJECT.GET_TASK_NUMBER(D.SEGMENT20)) LOCATOR,
                  V.INV_LOCATOR_ID
	 FROM     AHL_WORKORDERS W,
	          FND_LOOKUP_VALUES_VL MLU,
		  MTL_SYSTEM_ITEMS_KFV I,
		  AHL_VISITS_B V,
		  CSI_ITEM_INSTANCES C,
		  MTL_UNITS_OF_MEASURE_VL UOM,
		  WIP_PARAMETERS P,
		  MTL_ITEM_LOCATIONS D ';


    l_mtl_txn_dtls_where := '
	        WHERE  V.VISIT_ID                     = W.VISIT_ID
		  AND  C.INVENTORY_ITEM_ID            = I.INVENTORY_ITEM_ID
		  AND  C.INV_MASTER_ORGANIZATION_ID   = I.Organization_id
		  AND  C.WIP_JOB_ID                   = W.WIP_ENTITY_ID
		  AND  C.LOCATION_TYPE_CODE           = ''WIP''
		  AND  V.ORGANIZATION_ID                = P.ORGANIZATION_ID
		  AND  C.UNIT_OF_MEASURE              = UOM.UOM_CODE
		  AND  P.DEFAULT_PULL_SUPPLY_LOCATOR_ID = D.INVENTORY_LOCATION_ID(+)
		  AND  P.ORGANIZATION_ID                = D.ORGANIZATION_ID(+)
		  AND  I.ENABLED_FLAG                   = ''Y''
		  AND  W.STATUS_CODE                   IN (''3'',''4'',''20'')
		  AND  MLU.LOOKUP_TYPE                  =''AHL_JOB_STATUS''
		  AND  MLU.LOOKUP_CODE                  = W.STATUS_CODE
		  AND ( ( I.START_DATE_ACTIVE         IS NULL )
		  OR  ( I.START_DATE_ACTIVE            <= SYSDATE ) )
		  AND ( ( I.END_DATE_ACTIVE           IS NULL )
		  OR  ( I.END_DATE_ACTIVE              >= SYSDATE ) )
		  AND NOT EXISTS
			  (SELECT ''X''
			  FROM CSI_II_RELATIONSHIPS CIR
			  WHERE CIR.SUBJECT_ID           = C.INSTANCE_ID
			  AND CIR.RELATIONSHIP_TYPE_CODE = ''COMPONENT-OF''
			  AND SYSDATE BETWEEN NVL(ACTIVE_START_DATE,SYSDATE) AND NVL(ACTIVE_END_DATE, SYSDATE)
			  )
	          AND NOT EXISTS
			  (SELECT ''x''
			  FROM AHL_WORKORDER_MTL_TXNS TXN,
			       AHL_WORKORDER_OPERATIONS O
			  WHERE TXN.WORKORDER_OPERATION_ID = O.WORKORDER_OPERATION_ID
			  AND   O.WORKORDER_ID               = W.WORKORDER_ID
			  AND   TXN.TRANSACTION_TYPE_ID      = 35
			  AND   TXN.SERIAL_NUMBER           IS NULL
			  AND   TXN.INVENTORY_ITEM_ID        = C.INVENTORY_ITEM_ID
			  AND   NVL(TXN.REVISION,''x'')       = NVL(C.INVENTORY_REVISION,''x'')
			  AND   NVL(TXN.LOT_NUMBER,''x'')      = NVL(C.LOT_NUMBER,''x'')
			  )
		  AND C.ACTIVE_START_DATE   <= SYSDATE
		  AND ( ( C.ACTIVE_END_DATE IS NULL )
		  OR ( C.ACTIVE_END_DATE     > SYSDATE ) )
		  AND C.QUANTITY             > 0 ';

    l_bind_index := 1;

    IF (P_PRD_MTLTXN_CRITERIA_REC.JOB_NUMBER IS NOT NULL) THEN
	   L_MTL_TXN_DTLS_WHERE := L_MTL_TXN_DTLS_WHERE || ' AND W.WORKORDER_NAME LIKE :' || l_bind_index;
	   l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.JOB_NUMBER;
           l_bind_index := l_bind_index + 1;
    END IF;

    IF (P_PRD_MTLTXN_CRITERIA_REC.ORGANIZATION_NAME IS NOT NULL) THEN
	  L_MTL_TXN_DTLS := L_MTL_TXN_DTLS || ', (
		      SELECT
			ORGANIZATION_ID,
			ORGANIZATION_NAME
		      FROM
			ORG_ORGANIZATION_DEFINITIONS
		      WHERE
			NVL (OPERATING_UNIT, MO_GLOBAL.GET_CURRENT_ORG_ID()) =
			MO_GLOBAL.GET_CURRENT_ORG_ID()
		    ) ORG';
	  L_MTL_TXN_DTLS_WHERE := L_MTL_TXN_DTLS_WHERE || ' AND V.ORGANIZATION_ID = ORG.ORGANIZATION_ID
	AND ORG.ORGANIZATION_NAME LIKE :' || l_bind_index;
	l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.ORGANIZATION_NAME;
        l_bind_index := l_bind_index + 1;
    END IF;

    IF (P_PRD_MTLTXN_CRITERIA_REC.CONCATENATED_SEGMENTS IS NOT NULL) THEN
       L_MTL_TXN_DTLS_WHERE := L_MTL_TXN_DTLS_WHERE || ' AND I.CONCATENATED_SEGMENTS LIKE :' || l_bind_index;
       l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.CONCATENATED_SEGMENTS;
       l_bind_index := l_bind_index + 1;
    END IF;

    IF (P_PRD_MTLTXN_CRITERIA_REC.PRIORITY IS NOT NULL) THEN
      L_MTL_TXN_DTLS := L_MTL_TXN_DTLS || ', WIP_DISCRETE_JOBS WDJ';
      L_MTL_TXN_DTLS_WHERE := L_MTL_TXN_DTLS_WHERE || ' AND WDJ.WIP_ENTITY_ID = W.WIP_ENTITY_ID
      AND WDJ.PRIORITY = :' || l_bind_index;
      l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.PRIORITY;
      l_bind_index := l_bind_index + 1;
    END IF;

    IF (P_PRD_MTLTXN_CRITERIA_REC.VISIT_NUMBER IS NOT NULL) THEN
      L_MTL_TXN_DTLS_WHERE := L_MTL_TXN_DTLS_WHERE || ' AND V.VISIT_NUMBER = :' || l_bind_index;
      l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.VISIT_NUMBER;
      l_bind_index := l_bind_index + 1;
    END IF;

   IF (P_PRD_MTLTXN_CRITERIA_REC.DEPARTMENT_NAME IS NOT NULL) THEN
      L_MTL_TXN_DTLS := L_MTL_TXN_DTLS || ', WIP_DISCRETE_JOBS WDJ,BOM_DEPARTMENTS BMD';
      L_MTL_TXN_DTLS_WHERE := L_MTL_TXN_DTLS_WHERE || ' AND WDJ.WIP_ENTITY_ID = W.WIP_ENTITY_ID
      AND WDJ.OWNING_DEPARTMENT = BMD.DEPARTMENT_ID (+)
      AND BMD.DESCRIPTION LIKE :'  || l_bind_index;
      l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.DEPARTMENT_NAME;
      l_bind_index := l_bind_index + 1;
    END IF;

    IF (P_PRD_MTLTXN_CRITERIA_REC.INCIDENT_NUMBER IS NOT NULL) THEN
      L_MTL_TXN_DTLS := L_MTL_TXN_DTLS || ', AHL_VISIT_TASKS_B VTS,CS_INCIDENTS_ALL_B CSIN';
      L_MTL_TXN_DTLS_WHERE := L_MTL_TXN_DTLS_WHERE || ' AND W.VISIT_TASK_ID = VTS.VISIT_TASK_ID
      AND VTS.VISIT_ID = V.VISIT_ID
      AND VTS.SERVICE_REQUEST_ID = CSIN.INCIDENT_ID(+)
      AND CSIN.INCIDENT_NUMBER LIKE :' || l_bind_index;
      l_bind_value_tbl(l_bind_index) := P_prd_Mtltxn_criteria_rec.INCIDENT_NUMBER;
      l_bind_index := l_bind_index + 1;
    END IF;

    l_mtl_txn_dtls := l_mtl_txn_dtls || l_mtl_txn_dtls_where ;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)THEN
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.getTrackedWOMtl',
                'SQL Query String: ' || l_mtl_txn_dtls
         );
    END IF;

    -- execute query
    AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR(l_mtl_txns_returns_cur, l_bind_value_tbl, l_mtl_txn_dtls);

   LOOP
      FETCH l_mtl_txns_returns_cur INTO l_mtl_txn_rec;
      EXIT WHEN l_mtl_txns_returns_cur%NOTFOUND;
    --pdoki added for Bug 9164678 end.

       -- check if disposition exists.
       OPEN ahl_disp_csr(l_mtl_txn_rec.workorder_id, l_mtl_txn_rec.instance_id);
       FETCH ahl_disp_csr INTO l_junk;
       IF (ahl_disp_csr%NOTFOUND) THEN
              -- add instance to search results.
              p_x_ahl_prd_mtl_txn_tbl(l_index).workorder_id :=l_mtl_txn_rec.workorder_id;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Organization_Id :=l_mtl_txn_rec.Organization_Id;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_Name :=l_mtl_txn_rec.JOB_NUMBER;
              --p_x_ahl_prd_mtl_txn_tbl(l_index).Operation_Seq_Num :=l_mtl_txn_rec.OPERATION_SEQUENCE_NUM;
              --p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_operation_Id :=l_mtl_txn_rec.Workorder_operation_Id;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Inventory_Item_Segments:=l_mtl_txn_rec.CONCATENATED_SEGMENTS;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Inventory_Item_Id :=l_mtl_txn_rec.INVENTORY_ITEM_ID;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Inventory_Item_Description:=l_mtl_txn_rec.DESCRIPTION;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_Status :=l_mtl_txn_rec.JOB_STATUS_MEANING;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Serial_Number :=l_mtl_txn_rec.Serial_Number;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Quantity :=0;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Net_Quantity :=l_mtl_txn_rec.Quantity;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Uom :=l_mtl_txn_rec.Uom;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Uom_Desc :=l_mtl_txn_rec.UNIT_OF_MEASURE;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Workorder_Status :=l_mtl_txn_rec.JOB_STATUS_MEANING;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Lot_Number :=l_mtl_txn_rec.Lot_Number;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Revision :=l_mtl_txn_rec.Revision;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Subinventory_Name :=l_mtl_txn_rec.DEFAULT_PULL_SUPPLY_SUBINV;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Locator_Id :=l_mtl_txn_rec.DEFAULT_PULL_SUPPLY_LOCATOR_ID;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Locator_Segments :=l_mtl_txn_rec.Locator;
              p_x_ahl_prd_mtl_txn_tbl(l_index).Transaction_Date :=SYSDATE;
              -- ER 5854712.
              IF (l_mtl_txn_rec.inv_locator_id IS NULL) THEN
                 p_x_ahl_prd_mtl_txn_tbl(l_index).visit_locator_flag := '0';
              ELSE
                 p_x_ahl_prd_mtl_txn_tbl(l_index).visit_locator_flag := '1';
              END IF;

              l_index:=l_index+1;

              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)THEN
                  fnd_log.string
                  (
                    G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.getTrackedWOMtl',
                    'l_mtl_txn_rec.workorder_id: ' || l_mtl_txn_rec.workorder_id
                  );
                  fnd_log.string
                  (
                    G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.getTrackedWOMtl',
                    'l_mtl_txn_rec.job_number: ' || l_mtl_txn_rec.job_number
                  );
                  fnd_log.string
                  (
                    G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.getTrackedWOMtl',
                    'l_mtl_txn_rec.CONCATENATED_SEGMENTS: ' || l_mtl_txn_rec.CONCATENATED_SEGMENTS
                  );
                  fnd_log.string
                  (
                    G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.getTrackedWOMtl',
                    'l_mtl_txn_rec.ISSUEQTY is zero '
                  );
                  fnd_log.string
                  (
                    G_LEVEL_STATEMENT,
                    'ahl.plsql.AHL_PRD_MTLTXN_PVT.getTrackedWOMtl',
                    'l_mtl_txn_rec.Net Qty: ' || l_mtl_txn_rec.Quantity
                  );
              END IF;  -- debug messages.

       END IF;
       CLOSE ahl_disp_csr;

    END LOOP;
    CLOSE l_mtl_txns_returns_cur;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL)THEN
                fnd_log.string
                (
                        G_LEVEL_PROCEDURE,
                        'ahl.plsql.AHL_PRD_MTLTXN_PVT.getTrackedWOMtl.end',
                        'At the end of PLSQL procedure'
                );
    END IF;

END getTrackedWOMtl;

--Material txns search api. Called from Material txn return UI.
PROCEDURE GET_MTL_TRANS_RETURNS(
            p_api_version                   IN            NUMBER     := 1.0,
            p_init_msg_list                 IN            VARCHAR2   := FND_API.G_FALSE,
            p_commit                        IN            VARCHAR2   := FND_API.G_FALSE,
            p_validation_level              IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
            p_default                       IN            VARCHAR2   := FND_API.G_FALSE,
            p_module_type                   IN            VARCHAR2   := NULL,
            x_return_status                 OUT NOCOPY           VARCHAR2,
            x_msg_count                     OUT NOCOPY           NUMBER,
            x_msg_data                      OUT NOCOPY           VARCHAR2,
            P_prd_Mtltxn_criteria_rec       IN            Prd_Mtltxn_criteria_rec,
            x_ahl_mtltxn_tbl                IN OUT NOCOPY Ahl_Mtltxn_Tbl_Type
            )AS

     l_api_name                  CONSTANT VARCHAR2(30) := 'GET_MTL_TRANS_RETURNS';
     l_api_version          CONSTANT NUMBER       := 1.0;
     l_ahl_prd_mtl_txn_tbl       Ahl_Mtltxn_Tbl_Type;

BEGIN
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL)THEN
        fnd_log.string
        (
            G_LEVEL_PROCEDURE,
            'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURN.begin',
            'At the start of PLSQL procedure'
        );
     END IF;
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)THEN
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURNS',
                'P_prd_Mtltxn_criteria_rec.JOB_NUMBER : ' || P_prd_Mtltxn_criteria_rec.JOB_NUMBER
         );
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURNS',
                'P_prd_Mtltxn_criteria_rec.ORGANIZATION_NAME : ' || P_prd_Mtltxn_criteria_rec.ORGANIZATION_NAME
         );
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURNS',
                'P_prd_Mtltxn_criteria_rec.PRIORITY : ' || P_prd_Mtltxn_criteria_rec.PRIORITY
         );
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURNS',
                'P_prd_Mtltxn_criteria_rec.VISIT_NUMBER : ' || P_prd_Mtltxn_criteria_rec.VISIT_NUMBER
         );
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURNS',
                'P_prd_Mtltxn_criteria_rec.DEPARTMENT_NAME : ' || P_prd_Mtltxn_criteria_rec.DEPARTMENT_NAME
         );
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURNS',
                'P_prd_Mtltxn_criteria_rec.CONCATENATED_SEGMENTS : ' || P_prd_Mtltxn_criteria_rec.CONCATENATED_SEGMENTS
         );
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURNS',
                'P_prd_Mtltxn_criteria_rec.DISPOSITION_NAME : ' || P_prd_Mtltxn_criteria_rec.DISPOSITION_NAME
         );
         fnd_log.string
         (
                G_LEVEL_STATEMENT,
                'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURNS',
                'P_prd_Mtltxn_criteria_rec.INCIDENT_NUMBER : ' || P_prd_Mtltxn_criteria_rec.INCIDENT_NUMBER
         );

     END IF;
     -- Standard start of API savepoint
     SAVEPOINT GET_MTL_TRANS_RETURNS_PVT;

     -- Standard call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call
            (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF(P_prd_Mtltxn_criteria_rec.DISPOSITION_NAME IS NULL)THEN
       getMtlTxnsReturns
            (
            p_x_ahl_prd_mtl_txn_tbl   => x_ahl_mtltxn_tbl,
            P_prd_Mtltxn_criteria_rec => p_Prd_Mtltxn_criteria_rec
            );

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)THEN
           fnd_log.string
           (
            G_LEVEL_STATEMENT,
            'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURNS', 'After getMtlTxnsReturns x_ahl_mtltxn_tbl.count : ' || x_ahl_mtltxn_tbl.count
           );
        END IF;

        getDispositionReturn
            (
            p_x_ahl_prd_mtl_txn_tbl   => x_ahl_mtltxn_tbl,
            P_prd_Mtltxn_criteria_rec => p_Prd_Mtltxn_criteria_rec
            );

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)THEN
           fnd_log.string
           (
            G_LEVEL_STATEMENT,
            'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURNS', 'After getDispositionReturn x_ahl_mtltxn_tbl.count : ' || x_ahl_mtltxn_tbl.count
           );
        END IF;

        -- Fix for Bug # 9274691 -- start
        -- getTrackedWOMtl gets records only when disposition is not present for the material.
        -- Hence no need to call this method when disposition search criteria is not entered.

	-- get trackable items that have not been issued and not in the diposition
	-- list. Added for FP Bug# 5925805. It is possible to have tracked items in
	-- a job without a disposition and a material issue.
	-- bug fix# 6594140.

	getTrackedWOMtl
	    (
	    p_x_ahl_prd_mtl_txn_tbl   => x_ahl_mtltxn_tbl,
	    p_prd_Mtltxn_criteria_rec => p_Prd_Mtltxn_criteria_rec
	    );

	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)THEN
	     fnd_log.string
		 (
			    G_LEVEL_STATEMENT,
			    'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURNS',
			    'After getTrackedWOMtl:x_ahl_mtltxn_tbl.count : ' || x_ahl_mtltxn_tbl.count
		 );
	END IF;
	-- Fix for Bug # 9274691 -- end

      ELSE
        getDispositionReturn
            (
            p_x_ahl_prd_mtl_txn_tbl   => x_ahl_mtltxn_tbl,
            P_prd_Mtltxn_criteria_rec => p_Prd_Mtltxn_criteria_rec
            );

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)THEN
           fnd_log.string
           (
            G_LEVEL_STATEMENT,
            'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURNS', 'After getDispositionReturn x_ahl_mtltxn_tbl.count : ' || x_ahl_mtltxn_tbl.count
           );
        END IF;
      END IF;

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL)THEN
        fnd_log.string
        (
            G_LEVEL_PROCEDURE,
            'ahl.plsql.AHL_PRD_MTLTXN_PVT.GET_MTL_TRANS_RETURN.end',
            'At the end of PLSQL procedure'
        );
      END IF;

      --
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Rollback to GET_MTL_TRANS_RETURNS_PVT;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
        p_data  => x_msg_data,
        p_encoded => fnd_api.g_false);


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to GET_MTL_TRANS_RETURNS_PVT;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
        p_data  => x_msg_data,
        p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to GET_MTL_TRANS_RETURNS_PVT;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
        p_procedure_name => 'GET_MTL_TRANS_RETURNS',
        p_error_text     => SQLERRM);
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
        p_data  => x_msg_data,
        p_encoded => fnd_api.g_false);

END GET_MTL_TRANS_RETURNS;

/*
PROCEDURE SHOW_MTX_ERRORS
AS
x_row MTL_TRANSACTIONS_INTERFACE%rowtype;
CURSOR CL
IS
select * into x_row
from MTL_TRANSACTIONS_INTERFACE;
begin
return;
            FOR CLREC IN CL
            LOOP
                IF CLREC.error_code IS NOT NULL
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_COM_GENERIC_ERROR');
                                FND_MESSAGE.Set_Token('MESSAGE',CLREC.error_code);
                    FND_MSG_PUB.ADD;
                END IF;
            END LOOP;
end;
*/


-- R12: Serial Reservation enhancements.
-- Added procedure to relieve reservation when user is issuing a reserved serial
-- number against a different workorder.
PROCEDURE Relieve_Serial_Reservation(p_ahl_mtl_txn_rec  IN            AHL_MTLTXN_REC_TYPE,
                                     x_reservation_flag IN OUT NOCOPY VARCHAR2,
                                     x_return_status    IN OUT NOCOPY VARCHAR2
                                    )
IS
  -- get the demand_source_header_id and demand_source_line_id for the serial number.
  CURSOR get_scheduled_mater_csr (p_serial_number     IN VARCHAR2,
                                  p_inventory_item_id IN NUMBER,
                                  p_organization_id   IN NUMBER) IS
    SELECT rsv.DEMAND_SOURCE_LINE_DETAIL schedule_material_id, rsv.demand_source_header_id,
           rsv.demand_source_line_id, rsv.demand_source_type_id
    FROM  mtl_serial_numbers msn, mtl_reservations rsv
    WHERE msn.reservation_id = rsv.reservation_id
      AND msn.serial_number = p_serial_number
      AND msn.current_organization_id = p_organization_id
      AND msn.inventory_item_id = p_inventory_item_id;

  l_schedule_material_id    NUMBER;
  l_demand_source_header_id NUMBER;
  l_demand_source_line_id   NUMBER;
  l_demand_source_type_id   NUMBER;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);

BEGIN

  -- initialize out parameters.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_reservation_flag := 'N';

  -- check if serial reservation exists against a different workorder.
  OPEN get_scheduled_mater_csr (p_ahl_mtl_txn_rec.serial_number,
                                p_ahl_mtl_txn_rec.inventory_item_id,
                                p_ahl_mtl_txn_rec.organization_id);
  FETCH get_scheduled_mater_csr INTO l_schedule_material_id,
                                     l_demand_source_header_id,
                                     l_demand_source_line_id,
                                     l_demand_source_type_id;
  IF (get_scheduled_mater_csr%FOUND) THEN
     -- match l_demand_source_header_id and l_demand_source_line_id.
     IF (l_demand_source_header_id = p_ahl_mtl_txn_rec.wip_entity_id
         AND l_demand_source_line_id = p_ahl_mtl_txn_rec.operation_seq_num
         AND l_demand_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_WIP) THEN

         -- valid reservation for the workorder.
         x_reservation_flag := 'Y';

     ELSE
        -- relieve reservation against l_demand_source_header_id.

        AHL_RSV_RESERVATIONS_PVT.RELIEVE_RESERVATION(
                    p_api_version           => 1.0,
                    p_init_msg_list         => FND_API.G_FALSE,
                    p_commit                => FND_API.G_FALSE,
                    p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                    p_module_type           => NULL,
                    x_return_status         => x_return_status,
                    x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data,
                    p_scheduled_material_id => l_schedule_material_id,
                    p_serial_number         => p_ahl_mtl_txn_rec.serial_number
                   );

        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

     END IF; -- l_demand_source_header_id <>

  END IF; -- get_scheduled_mater_csr%FOUND
  CLOSE get_scheduled_mater_csr;

END Relieve_Serial_Reservation;

-- Added for pre processing(FP bug# 5903207).
PROCEDURE Perform_MtlTxn_Pre( p_x_ahl_mtltxn_tbl IN OUT NOCOPY AHL_MTLTXN_TBL_TYPE,
                              x_msg_count        IN OUT NOCOPY NUMBER,
                              x_msg_data         IN OUT NOCOPY VARCHAR2,
                              x_return_status    IN OUT NOCOPY VARCHAR2) IS

  l_x_material_txn_tbl  AHL_PRD_MATERIAL_TXN_PUB.Ahl_Material_Txn_Tbl_Type;

BEGIN
   -- copy to l_x_material_txn_tbl record structure.
   IF (p_x_ahl_mtltxn_tbl.COUNT > 0) THEN
     FOR i IN p_x_ahl_mtltxn_tbl.FIRST..p_x_ahl_mtltxn_tbl.LAST LOOP

          l_x_material_txn_tbl(i).Workorder_Id            := p_x_ahl_mtltxn_tbl(i).Workorder_Id;
          l_x_material_txn_tbl(i).Workorder_Name          := p_x_ahl_mtltxn_tbl(i).Workorder_Name;
          l_x_material_txn_tbl(i).Operation_Seq_Num       := p_x_ahl_mtltxn_tbl(i).Operation_Seq_Num;
          l_x_material_txn_tbl(i).Transaction_Type_Id     := p_x_ahl_mtltxn_tbl(i).Transaction_Type_Id;
          l_x_material_txn_tbl(i).Transaction_Type_Name   := p_x_ahl_mtltxn_tbl(i).Transaction_Type_Name;

          l_x_material_txn_tbl(i).Inventory_Item_Id       := p_x_ahl_mtltxn_tbl(i).Inventory_Item_Id;
          l_x_material_txn_tbl(i).Inventory_Item_Segments := p_x_ahl_mtltxn_tbl(i).Inventory_Item_Segments;
          l_x_material_txn_tbl(i).Item_Instance_Number    := p_x_ahl_mtltxn_tbl(i).Item_Instance_Number;
          l_x_material_txn_tbl(i).Item_Instance_ID        := p_x_ahl_mtltxn_tbl(i).Item_Instance_ID;
          l_x_material_txn_tbl(i).Revision                := p_x_ahl_mtltxn_tbl(i).Revision;
          l_x_material_txn_tbl(i).Condition               := p_x_ahl_mtltxn_tbl(i).Condition;
          l_x_material_txn_tbl(i).Condition_desc          := p_x_ahl_mtltxn_tbl(i).Condition_desc;
          l_x_material_txn_tbl(i).Subinventory_Name       := p_x_ahl_mtltxn_tbl(i).Subinventory_Name;
          l_x_material_txn_tbl(i).Locator_Id              := p_x_ahl_mtltxn_tbl(i).Locator_Id;
          l_x_material_txn_tbl(i).Locator_Segments        := p_x_ahl_mtltxn_tbl(i).Locator_Segments;
          l_x_material_txn_tbl(i).Quantity                := p_x_ahl_mtltxn_tbl(i).Quantity;
          l_x_material_txn_tbl(i).Uom_Code                := p_x_ahl_mtltxn_tbl(i).Uom;
          l_x_material_txn_tbl(i).Unit_Of_Measure         := p_x_ahl_mtltxn_tbl(i).Uom_Desc;
          l_x_material_txn_tbl(i).Serial_Number           := p_x_ahl_mtltxn_tbl(i).Serial_Number;
          l_x_material_txn_tbl(i).Lot_Number              := p_x_ahl_mtltxn_tbl(i).Lot_Number;
          l_x_material_txn_tbl(i).Transaction_Date        := p_x_ahl_mtltxn_tbl(i).Transaction_Date;
          l_x_material_txn_tbl(i).Transaction_Reference   := p_x_ahl_mtltxn_tbl(i).Transaction_Reference;
          l_x_material_txn_tbl(i).recepient_id            := p_x_ahl_mtltxn_tbl(i).recepient_id;
          l_x_material_txn_tbl(i).recepient_name          := p_x_ahl_mtltxn_tbl(i).recepient_name;
          l_x_material_txn_tbl(i).disposition_id          := p_x_ahl_mtltxn_tbl(i).disposition_id;

          -- Target visit is currently not used.
          --p_x_material_txn_tbl(i).Target_Visit_Id       := p_x_ahl_mtltxn_tbl(i).Target_Visit_Id;
          --p_x_material_txn_tbl(i).Target_Visit_Num      := p_x_ahl_mtltxn_tbl(i).Target_Visit_Num;

          l_x_material_txn_tbl(i).Reason_Id               := p_x_ahl_mtltxn_tbl(i).Reason_Id;
          l_x_material_txn_tbl(i).Reason_Name             := p_x_ahl_mtltxn_tbl(i).Reason_Name;
          l_x_material_txn_tbl(i).Problem_Code            := p_x_ahl_mtltxn_tbl(i).Problem_Code;
          l_x_material_txn_tbl(i).Problem_Code_Meaning    := p_x_ahl_mtltxn_tbl(i).Problem_Code_Meaning;
          l_x_material_txn_tbl(i).Sr_Summary              := p_x_ahl_mtltxn_tbl(i).Sr_Summary;
          l_x_material_txn_tbl(i).Qa_Collection_Id        := p_x_ahl_mtltxn_tbl(i).Qa_Collection_Id;

          l_x_material_txn_tbl(i).ATTRIBUTE_CATEGORY      := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE_CATEGORY;
          l_x_material_txn_tbl(i).ATTRIBUTE1              := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE1;
          l_x_material_txn_tbl(i).ATTRIBUTE2              := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE2;
          l_x_material_txn_tbl(i).ATTRIBUTE3              := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE3;
          l_x_material_txn_tbl(i).ATTRIBUTE4              := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE4;
          l_x_material_txn_tbl(i).ATTRIBUTE5              := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE5;
          l_x_material_txn_tbl(i).ATTRIBUTE6              := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE6;
          l_x_material_txn_tbl(i).ATTRIBUTE7              := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE7;
          l_x_material_txn_tbl(i).ATTRIBUTE8              := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE8;
          l_x_material_txn_tbl(i).ATTRIBUTE9              := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE9;
          l_x_material_txn_tbl(i).ATTRIBUTE10             := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE10;
          l_x_material_txn_tbl(i).ATTRIBUTE11             := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE11;
          l_x_material_txn_tbl(i).ATTRIBUTE12             := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE12;
          l_x_material_txn_tbl(i).ATTRIBUTE13             := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE13;
          l_x_material_txn_tbl(i).ATTRIBUTE14             := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE14;
          l_x_material_txn_tbl(i).ATTRIBUTE15             := p_x_ahl_mtltxn_tbl(i).ATTRIBUTE15;
     END LOOP;

     -- call user hook api.
     AHL_PRD_MATERIAL_TXN_CUHK.Perform_MtlTxn_Pre(
                      p_x_material_txn_tbl => l_x_material_txn_tbl,
                      x_msg_count => x_msg_count,
                      x_msg_data => x_msg_data,
                      x_return_status => x_return_status);

     IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_x_material_txn_tbl.count > 0) THEN
       FOR i IN l_x_material_txn_tbl.FIRST..l_x_material_txn_tbl.LAST LOOP

          p_x_ahl_mtltxn_tbl(i).Workorder_Id            := l_x_material_txn_tbl(i).Workorder_Id;
          p_x_ahl_mtltxn_tbl(i).Workorder_Name          := l_x_material_txn_tbl(i).Workorder_Name;
          p_x_ahl_mtltxn_tbl(i).Operation_Seq_Num       := l_x_material_txn_tbl(i).Operation_Seq_Num;
          p_x_ahl_mtltxn_tbl(i).Transaction_Type_Id     := l_x_material_txn_tbl(i).Transaction_Type_Id;
          p_x_ahl_mtltxn_tbl(i).Transaction_Type_Name   := l_x_material_txn_tbl(i).Transaction_Type_Name;

          p_x_ahl_mtltxn_tbl(i).Inventory_Item_Id       := l_x_material_txn_tbl(i).Inventory_Item_Id;
          p_x_ahl_mtltxn_tbl(i).Inventory_Item_Segments := l_x_material_txn_tbl(i).Inventory_Item_Segments;
          p_x_ahl_mtltxn_tbl(i).Item_Instance_Number    := l_x_material_txn_tbl(i).Item_Instance_Number;
          p_x_ahl_mtltxn_tbl(i).Item_Instance_ID        := l_x_material_txn_tbl(i).Item_Instance_ID;
          p_x_ahl_mtltxn_tbl(i).Revision                := l_x_material_txn_tbl(i).Revision;
          p_x_ahl_mtltxn_tbl(i).Condition               := l_x_material_txn_tbl(i).Condition;
          p_x_ahl_mtltxn_tbl(i).Condition_desc          := l_x_material_txn_tbl(i).Condition_desc;
          p_x_ahl_mtltxn_tbl(i).Subinventory_Name       := l_x_material_txn_tbl(i).Subinventory_Name;
          p_x_ahl_mtltxn_tbl(i).Locator_Id              := l_x_material_txn_tbl(i).Locator_Id;
          p_x_ahl_mtltxn_tbl(i).Locator_Segments        := l_x_material_txn_tbl(i).Locator_Segments;
          p_x_ahl_mtltxn_tbl(i).Quantity                := l_x_material_txn_tbl(i).Quantity;
          p_x_ahl_mtltxn_tbl(i).Uom                     := l_x_material_txn_tbl(i).Uom_code;
          p_x_ahl_mtltxn_tbl(i).Uom_Desc               := l_x_material_txn_tbl(i).Unit_of_measure;
          p_x_ahl_mtltxn_tbl(i).Serial_Number           := l_x_material_txn_tbl(i).Serial_Number;
          p_x_ahl_mtltxn_tbl(i).Lot_Number              := l_x_material_txn_tbl(i).Lot_Number;
          p_x_ahl_mtltxn_tbl(i).Transaction_Date        := l_x_material_txn_tbl(i).Transaction_Date;
          p_x_ahl_mtltxn_tbl(i).Transaction_Reference   := l_x_material_txn_tbl(i).Transaction_Reference;
          p_x_ahl_mtltxn_tbl(i).recepient_id            := l_x_material_txn_tbl(i).recepient_id;
          p_x_ahl_mtltxn_tbl(i).recepient_name          := l_x_material_txn_tbl(i).recepient_name;
          p_x_ahl_mtltxn_tbl(i).disposition_id          := l_x_material_txn_tbl(i).disposition_id;

          -- Target visit is currently not used.
          --p_x_ahl_mtltxn_tbl(i).Target_Visit_Id       := l_x_material_txn_tbl(i).Target_Visit_Id;
          --p_x_ahl_mtltxn_tbl(i).Target_Visit_Num      := l_x_material_txn_tbl(i).Target_Visit_Num;

          p_x_ahl_mtltxn_tbl(i).Reason_Id               := l_x_material_txn_tbl(i).Reason_Id;
          p_x_ahl_mtltxn_tbl(i).Reason_Name             := l_x_material_txn_tbl(i).Reason_Name;
          p_x_ahl_mtltxn_tbl(i).Problem_Code            := l_x_material_txn_tbl(i).Problem_Code;
          p_x_ahl_mtltxn_tbl(i).Problem_Code_Meaning    := l_x_material_txn_tbl(i).Problem_Code_Meaning;
          p_x_ahl_mtltxn_tbl(i).Sr_Summary              := l_x_material_txn_tbl(i).Sr_Summary;
          p_x_ahl_mtltxn_tbl(i).Qa_Collection_Id        := l_x_material_txn_tbl(i).Qa_Collection_Id;

          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE_CATEGORY      := l_x_material_txn_tbl(i).ATTRIBUTE_CATEGORY;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE1              := l_x_material_txn_tbl(i).ATTRIBUTE1;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE2              := l_x_material_txn_tbl(i).ATTRIBUTE2;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE3              := l_x_material_txn_tbl(i).ATTRIBUTE3;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE4              := l_x_material_txn_tbl(i).ATTRIBUTE4;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE5              := l_x_material_txn_tbl(i).ATTRIBUTE5;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE6              := l_x_material_txn_tbl(i).ATTRIBUTE6;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE7              := l_x_material_txn_tbl(i).ATTRIBUTE7;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE8              := l_x_material_txn_tbl(i).ATTRIBUTE8;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE9              := l_x_material_txn_tbl(i).ATTRIBUTE9;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE10             := l_x_material_txn_tbl(i).ATTRIBUTE10;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE11             := l_x_material_txn_tbl(i).ATTRIBUTE11;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE12             := l_x_material_txn_tbl(i).ATTRIBUTE12;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE13             := l_x_material_txn_tbl(i).ATTRIBUTE13;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE14             := l_x_material_txn_tbl(i).ATTRIBUTE14;
          p_x_ahl_mtltxn_tbl(i).ATTRIBUTE15             := l_x_material_txn_tbl(i).ATTRIBUTE15;
       END LOOP; -- l_x_material_txn_tbl.FIRST
     END IF; -- x_return_status.
   END IF;
END Perform_MtlTxn_Pre;


-- Added for post processing (FP bug# 5903207).
PROCEDURE Perform_MtlTxn_Post( p_ahl_mtltxn_tbl   IN AHL_MTLTXN_TBL_TYPE,
                               x_msg_count        IN OUT NOCOPY NUMBER,
                               x_msg_data         IN OUT NOCOPY VARCHAR2,
                               x_return_status    IN OUT NOCOPY VARCHAR2) IS

  l_material_txn_tbl  AHL_PRD_MATERIAL_TXN_PUB.Ahl_Material_Txn_Tbl_Type;

BEGIN

   -- copy to l_x_material_txn_tbl record structure.
   IF (p_ahl_mtltxn_tbl.COUNT > 0) THEN
     FOR i IN p_ahl_mtltxn_tbl.FIRST..p_ahl_mtltxn_tbl.LAST LOOP

          l_material_txn_tbl(i).Workorder_Id            := p_ahl_mtltxn_tbl(i).Workorder_Id;
          l_material_txn_tbl(i).Workorder_Name          := p_ahl_mtltxn_tbl(i).Workorder_Name;
          l_material_txn_tbl(i).Operation_Seq_Num       := p_ahl_mtltxn_tbl(i).Operation_Seq_Num;
          l_material_txn_tbl(i).Transaction_Type_Id     := p_ahl_mtltxn_tbl(i).Transaction_Type_Id;
          l_material_txn_tbl(i).Transaction_Type_Name   := p_ahl_mtltxn_tbl(i).Transaction_Type_Name;

          l_material_txn_tbl(i).Inventory_Item_Id       := p_ahl_mtltxn_tbl(i).Inventory_Item_Id;
          l_material_txn_tbl(i).Inventory_Item_Segments := p_ahl_mtltxn_tbl(i).Inventory_Item_Segments;
          l_material_txn_tbl(i).Item_Instance_Number    := p_ahl_mtltxn_tbl(i).Item_Instance_Number;
          l_material_txn_tbl(i).Item_Instance_ID        := p_ahl_mtltxn_tbl(i).Item_Instance_ID;
          l_material_txn_tbl(i).Revision                := p_ahl_mtltxn_tbl(i).Revision;
          l_material_txn_tbl(i).Condition               := p_ahl_mtltxn_tbl(i).Condition;
          l_material_txn_tbl(i).Condition_desc          := p_ahl_mtltxn_tbl(i).Condition_desc;
          l_material_txn_tbl(i).Subinventory_Name       := p_ahl_mtltxn_tbl(i).Subinventory_Name;
          l_material_txn_tbl(i).Locator_Id              := p_ahl_mtltxn_tbl(i).Locator_Id;
          l_material_txn_tbl(i).Locator_Segments        := p_ahl_mtltxn_tbl(i).Locator_Segments;
          l_material_txn_tbl(i).Quantity                := p_ahl_mtltxn_tbl(i).Quantity;
          l_material_txn_tbl(i).Uom_Code                := p_ahl_mtltxn_tbl(i).Uom;
          l_material_txn_tbl(i).Unit_Of_Measure         := p_ahl_mtltxn_tbl(i).Uom_Desc;
          l_material_txn_tbl(i).Serial_Number           := p_ahl_mtltxn_tbl(i).Serial_Number;
          l_material_txn_tbl(i).Lot_Number              := p_ahl_mtltxn_tbl(i).Lot_Number;
          l_material_txn_tbl(i).Transaction_Date        := p_ahl_mtltxn_tbl(i).Transaction_Date;
          l_material_txn_tbl(i).Transaction_Reference   := p_ahl_mtltxn_tbl(i).Transaction_Reference;
          l_material_txn_tbl(i).recepient_id            := p_ahl_mtltxn_tbl(i).recepient_id;
          l_material_txn_tbl(i).recepient_name          := p_ahl_mtltxn_tbl(i).recepient_name;
          l_material_txn_tbl(i).disposition_id          := p_ahl_mtltxn_tbl(i).disposition_id;

          -- Target visit is currently not used.
          --p_material_txn_tbl(i).Target_Visit_Id       := p_ahl_mtltxn_tbl(i).Target_Visit_Id;
          --p_material_txn_tbl(i).Target_Visit_Num      := p_ahl_mtltxn_tbl(i).Target_Visit_Num;

          l_material_txn_tbl(i).Reason_Id               := p_ahl_mtltxn_tbl(i).Reason_Id;
          l_material_txn_tbl(i).Reason_Name             := p_ahl_mtltxn_tbl(i).Reason_Name;
          l_material_txn_tbl(i).Problem_Code            := p_ahl_mtltxn_tbl(i).Problem_Code;
          l_material_txn_tbl(i).Problem_Code_Meaning    := p_ahl_mtltxn_tbl(i).Problem_Code_Meaning;
          l_material_txn_tbl(i).Sr_Summary              := p_ahl_mtltxn_tbl(i).Sr_Summary;
          l_material_txn_tbl(i).Qa_Collection_Id        := p_ahl_mtltxn_tbl(i).Qa_Collection_Id;

          l_material_txn_tbl(i).ATTRIBUTE_CATEGORY      := p_ahl_mtltxn_tbl(i).ATTRIBUTE_CATEGORY;
          l_material_txn_tbl(i).ATTRIBUTE1              := p_ahl_mtltxn_tbl(i).ATTRIBUTE1;
          l_material_txn_tbl(i).ATTRIBUTE2              := p_ahl_mtltxn_tbl(i).ATTRIBUTE2;
          l_material_txn_tbl(i).ATTRIBUTE3              := p_ahl_mtltxn_tbl(i).ATTRIBUTE3;
          l_material_txn_tbl(i).ATTRIBUTE4              := p_ahl_mtltxn_tbl(i).ATTRIBUTE4;
          l_material_txn_tbl(i).ATTRIBUTE5              := p_ahl_mtltxn_tbl(i).ATTRIBUTE5;
          l_material_txn_tbl(i).ATTRIBUTE6              := p_ahl_mtltxn_tbl(i).ATTRIBUTE6;
          l_material_txn_tbl(i).ATTRIBUTE7              := p_ahl_mtltxn_tbl(i).ATTRIBUTE7;
          l_material_txn_tbl(i).ATTRIBUTE8              := p_ahl_mtltxn_tbl(i).ATTRIBUTE8;
          l_material_txn_tbl(i).ATTRIBUTE9              := p_ahl_mtltxn_tbl(i).ATTRIBUTE9;
          l_material_txn_tbl(i).ATTRIBUTE10             := p_ahl_mtltxn_tbl(i).ATTRIBUTE10;
          l_material_txn_tbl(i).ATTRIBUTE11             := p_ahl_mtltxn_tbl(i).ATTRIBUTE11;
          l_material_txn_tbl(i).ATTRIBUTE12             := p_ahl_mtltxn_tbl(i).ATTRIBUTE12;
          l_material_txn_tbl(i).ATTRIBUTE13             := p_ahl_mtltxn_tbl(i).ATTRIBUTE13;
          l_material_txn_tbl(i).ATTRIBUTE14             := p_ahl_mtltxn_tbl(i).ATTRIBUTE14;
          l_material_txn_tbl(i).ATTRIBUTE15             := p_ahl_mtltxn_tbl(i).ATTRIBUTE15;

     END LOOP;

     AHL_PRD_MATERIAL_TXN_CUHK.Perform_MtlTxn_Post( p_material_txn_tbl => l_material_txn_tbl,
                                                    x_msg_count => x_msg_count,
                                                    x_msg_data => x_msg_data,
                                                    x_return_status => x_return_status);
   END IF;


END Perform_MtlTxn_Post;


-- Added for FP ER 6447935 - dynamic locator support.
-- breakup input locator concatenated segments to populate MTI.
PROCEDURE Get_MTL_LocatorSegs (p_concat_segs     IN VARCHAR2,
                               p_organization_id IN NUMBER,
                               p_x_mti_seglist   IN OUT NOCOPY fnd_flex_ext.SegmentArray,
                               x_return_status      OUT NOCOPY VARCHAR2)

IS

      l_flex_nseg      NUMBER;
      l_flex_seglist   fnd_flex_key_api.segment_list;
      l_fftype         fnd_flex_key_api.flexfield_type;
      l_ffstru         fnd_flex_key_api.structure_type;
      l_segment_type   fnd_flex_key_api.segment_type;
      l_delim          VARCHAR2(1);

      l_loc_nseg     number;
      l_loc_seglist  fnd_flex_ext.SegmentArray;
      l_mti_seglist  fnd_flex_ext.SegmentArray;
      l_concat_seg_IDs VARCHAR2(4000);

      l_valid_flag    BOOLEAN;

BEGIN

   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.DEBUG('Start Procedure:Splitting locator concatenated segments:' || p_concat_segs, 'Get_MTL_LocatorSegs');
   END IF;

   -- initialize status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- set mfg_organization_id profile - bug# 6010795.
   fnd_profile.put('MFG_ORGANIZATION_ID', p_organization_id);

   l_mti_seglist := p_x_mti_seglist;

   fnd_flex_key_api.set_session_mode('seed_data');

   -- find flex field type
   l_fftype := fnd_flex_key_api.find_flexfield('INV', 'MTLL');

   -- find flex structure type
   l_ffstru := fnd_flex_key_api.find_structure(l_fftype, 101);

   -- find segment list for the key flex field
   fnd_flex_key_api.get_segments(l_fftype, l_ffstru, TRUE, l_flex_nseg, l_flex_seglist);

   -- find segment delimiter
   l_delim := l_ffstru.segment_separator;

   IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.DEBUG('Before Loc Seg validate:Profile mfg_organization_id:'  || fnd_profile.value('MFG_ORGANIZATION_ID') );
   END IF;

   -- validate locator segments.
   l_valid_flag := fnd_flex_keyval.validate_segs(
                           operation                    => 'CHECK_COMBINATION'
                         , appl_short_name              => 'INV'
                         , key_flex_code                => 'MTLL'
                         , structure_number             => 101
                         , concat_segments              => p_concat_segs
                         , values_or_ids                => 'V'
                         , data_set                     => p_organization_id
                   );

   IF NOT(l_valid_flag) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_INPUT_NUM_LOC_SEGS_INVALID');
      FND_MESSAGE.Set_Token('LOC_SEG',p_concat_segs);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   -- get IDs for the concatenated segments as MTI validates IDs.
   l_concat_seg_IDs := fnd_flex_keyval.concatenated_ids;

   -- breakup locator concat IDs into segments.
   l_loc_nseg := fnd_flex_ext.breakup_segments (l_concat_seg_IDs, l_delim, l_loc_seglist);

   /*
   -- validate if enabled segments equal to input locator segments.
   -- if not, raise error and return.
   IF (l_loc_nseg <> l_flex_nseg) THEN
      IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.DEBUG('FND Enabled Segments:' || l_flex_nseg);
         AHL_DEBUG_PUB.DEBUG('FND Enabled Segments:' || l_loc_nseg);
      END IF;

      FND_MESSAGE.Set_Name('AHL','AHL_INPUT_NUM_LOC_SEGS_INVALID');
      FND_MESSAGE.Set_Token('LOC_NUM',l_flex_nseg);
      FND_MESSAGE.Set_Token('LOC_SEG',p_concat_segs);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;
   */

   -- get the corresponding column for all segments
   --
   -- 'To_number(Substr(l_segment_type.column_name, 8))' gives the
   -- number of the segment i.e. 1 - 20 which is used as index to
   -- populate the corresponding columns from segments array.
   --
   FOR l_loop IN 1..l_flex_nseg LOOP

      l_segment_type := fnd_flex_key_api.find_segment(l_fftype, l_ffstru, l_flex_seglist(l_loop));
      --dbms_output.put_line('l_segment_type is : ' || l_segment_type.column_name);

      l_mti_seglist(To_number(Substr(l_segment_type.column_name, 8))) := l_loc_seglist(l_loop);

   END LOOP;

   -- assign out parameter.
   p_x_mti_seglist := l_mti_seglist;

   IF G_DEBUG='Y' THEN
      FOR i IN 1..20 LOOP
        --dbms_output.put_line('Segs final(' || i || ') : ' || l_mti_seglist(i));
        AHL_DEBUG_PUB.DEBUG('Segs final(' || i || ') : ' || p_x_mti_seglist(i), 'Get_MTL_LocatorSegs');
      END LOOP;
      AHL_DEBUG_PUB.DEBUG('End of procedure', 'Get_MTL_LocatorSegs');
   END IF;

END Get_MTL_LocatorSegs;


END AHL_PRD_MTLTXN_PVT ;

/
