--------------------------------------------------------
--  DDL for Package Body WIP_SCHEDULER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_SCHEDULER" AS
/* $Header: wipschdb.pls 115.28 2003/09/05 22:10:30 kbavadek ship $ */

PROCEDURE explode_routing(
        X_Wip_Entity_Id                 NUMBER,
        X_Organization_Id               NUMBER,
        X_Repetitive_Schedule_Id        NUMBER,
        X_Start_Date                    VARCHAR2,
        X_Completion_Date               VARCHAR2,
        X_Routing_Seq                   NUMBER,
        X_Routing_Rev_Date              VARCHAR2,
        X_Quantity                      NUMBER,
        X_Created_By                    NUMBER,
        X_Last_Update_Login             NUMBER) IS


p_req_id NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
p_appl_id NUMBER := FND_GLOBAL.PROG_APPL_ID;
p_prog_id NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
p_curdate DATE := SYSDATE;
p_user_id NUMBER :=  FND_GLOBAL.USER_ID;
p_login_id NUMBER :=  FND_GLOBAL.LOGIN_ID;
max_seq NUMBER;


    CURSOR wip_op_inst IS
    SELECT ops.operation_seq_num,
           ops.operation_sequence_id
      FROM wip_operations ops
     WHERE NVL(ops.repetitive_schedule_id, -1) =
           NVL(X_Repetitive_Schedule_Id, -1)
       AND ops.organization_id = X_Organization_Id
       AND ops.wip_entity_id   = X_Wip_Entity_Id
       AND EXISTS
           (SELECT fnd.pk1_value
              FROM fnd_attached_documents fnd
             WHERE fnd.pk1_value = to_char(ops.operation_sequence_id)
               AND fnd.entity_name = 'BOM_OPERATION_SEQUENCES');
l_params  wip_logger.param_tbl_t;
l_returnStatus VARCHAR(1);
l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
BEGIN
  if (l_logLevel <= wip_constants.trace_logging) then
    l_params(1).paramName    := 'wip_id';
    l_params(1).paramValue   :=  X_Wip_Entity_Id;
    l_params(2).paramName    := 'orgID';
    l_params(2).paramValue   :=  X_Organization_Id ;
    l_params(3).paramName    := 'start_date';
    l_params(3).paramValue   :=  X_Start_Date;
    l_params(4).paramName    := 'routing_seq';
    l_params(4).paramValue   :=  X_Routing_Seq ;
    l_params(5).paramName    := 'routing_rev_date';
    l_params(5).paramValue   :=  X_Routing_Rev_Date;
     -- write parameter value to log file
    wip_logger.entryPoint(p_procName =>'wip_scheduler.explode_routing',
			  p_params => l_params,
			  x_returnStatus => l_returnStatus);
  end if;

        /* This is all extracted froom wiloer.ppc */

        INSERT INTO WIP_OPERATIONS
                (WIP_ENTITY_ID,
                OPERATION_SEQ_NUM,
                ORGANIZATION_ID,
                REPETITIVE_SCHEDULE_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                OPERATION_SEQUENCE_ID,
                STANDARD_OPERATION_ID,
                DEPARTMENT_ID,
                DESCRIPTION,
                SCHEDULED_QUANTITY,
                QUANTITY_IN_QUEUE,
                QUANTITY_RUNNING,
                QUANTITY_WAITING_TO_MOVE,
                QUANTITY_REJECTED,
                QUANTITY_SCRAPPED,
                QUANTITY_COMPLETED,
                CUMULATIVE_SCRAP_QUANTITY,  /* For enhancement #2864382*/
                FIRST_UNIT_START_DATE,
                FIRST_UNIT_COMPLETION_DATE,
                LAST_UNIT_START_DATE,
                LAST_UNIT_COMPLETION_DATE,
                PREVIOUS_OPERATION_SEQ_NUM,
                NEXT_OPERATION_SEQ_NUM,
                COUNT_POINT_TYPE,
                BACKFLUSH_FLAG,
                MINIMUM_TRANSFER_QUANTITY,
                DATE_LAST_MOVED,
                LONG_DESCRIPTION,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15)
        SELECT  X_Wip_Entity_Id,
                SEQ.OPERATION_SEQ_NUM,
                X_Organization_Id,
                X_Repetitive_Schedule_Id,
                p_curdate,
                X_Created_By,
                p_curdate,
                X_Created_By,
                X_Last_Update_Login,
                DECODE(p_req_id, 0, '', p_req_id),
                DECODE(p_appl_id, 0, '', p_appl_id),
                DECODE(p_prog_id, 0, '', p_prog_id),
                DECODE(p_prog_id, 0, '', p_curdate),
                SEQ.OPERATION_SEQUENCE_ID,
                SEQ.STANDARD_OPERATION_ID,
                SEQ.DEPARTMENT_ID,
                SEQ.OPERATION_DESCRIPTION,
                ROUND(X_Quantity, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                0, 0, 0, 0, 0, 0, 0,
                TO_DATE(X_Start_Date, WIP_CONSTANTS.DT_NOSEC_FMT),
                TO_DATE(X_Completion_Date, WIP_CONSTANTS.DT_NOSEC_FMT),
                TO_DATE(X_Start_Date, WIP_CONSTANTS.DT_NOSEC_FMT),
                TO_DATE(X_Completion_Date, WIP_CONSTANTS.DT_NOSEC_FMT),
                0, 0,
                SEQ.COUNT_POINT_TYPE,
                SEQ.BACKFLUSH_FLAG,
                NVL(SEQ.MINIMUM_TRANSFER_QUANTITY, 0),
                '',
                SEQ.LONG_DESCRIPTION,
                SEQ.ATTRIBUTE_CATEGORY,
                SEQ.ATTRIBUTE1,
                SEQ.ATTRIBUTE2,
                SEQ.ATTRIBUTE3,
                SEQ.ATTRIBUTE4,
                SEQ.ATTRIBUTE5,
                SEQ.ATTRIBUTE6,
                SEQ.ATTRIBUTE7,
                SEQ.ATTRIBUTE8,
                SEQ.ATTRIBUTE9,
                SEQ.ATTRIBUTE10,
                SEQ.ATTRIBUTE11,
                SEQ.ATTRIBUTE12,
                SEQ.ATTRIBUTE13,
                SEQ.ATTRIBUTE14,
                SEQ.ATTRIBUTE15
        FROM    BOM_OPERATION_SEQUENCES SEQ
       WHERE    SEQ.ROUTING_SEQUENCE_ID = X_Routing_Seq
/* %cfm */
         AND    NVL(SEQ.OPERATION_TYPE, 1) = 1
/* %/cfm */
         AND    TO_DATE(TO_CHAR(SEQ.EFFECTIVITY_DATE, WIP_CONSTANTS.DATETIME_FMT),
                        WIP_CONSTANTS.DATETIME_FMT) <=
                TO_DATE(X_Routing_Rev_Date,WIP_CONSTANTS.DATETIME_FMT)
         AND    NVL(TO_DATE(TO_CHAR(SEQ.DISABLE_DATE,
                                    WIP_CONSTANTS.DATETIME_FMT),
                            WIP_CONSTANTS.DATETIME_FMT),
                    TO_DATE(X_Routing_Rev_Date,WIP_CONSTANTS.DATETIME_FMT) + 2) >=
                TO_DATE(X_Routing_Rev_Date,WIP_CONSTANTS.DATETIME_FMT)
         AND    SEQ.IMPLEMENTATION_DATE IS NOT NULL;

        UPDATE  WIP_OPERATIONS WO
        SET     WO.PREVIOUS_OPERATION_SEQ_NUM =
                        (SELECT MAX(OPERATION_SEQ_NUM)
                           FROM WIP_OPERATIONS
                          WHERE WIP_ENTITY_ID = X_Wip_Entity_Id
                            AND ORGANIZATION_ID = X_Organization_Id
                            AND NVL(REPETITIVE_SCHEDULE_ID, -1) =
                                NVL(X_Repetitive_Schedule_Id, -1)
                            AND OPERATION_SEQ_NUM < WO.OPERATION_SEQ_NUM),
                WO.NEXT_OPERATION_SEQ_NUM =
                        (SELECT MIN(OPERATION_SEQ_NUM)
                           FROM WIP_OPERATIONS
                          WHERE WIP_ENTITY_ID = X_Wip_Entity_Id
                            AND ORGANIZATION_ID = X_Organization_Id
                            AND NVL(REPETITIVE_SCHEDULE_ID, -1) =
                                NVL(X_Repetitive_Schedule_Id, -1)
                            AND OPERATION_SEQ_NUM > WO.OPERATION_SEQ_NUM)
        WHERE   WO.WIP_ENTITY_ID = X_Wip_Entity_Id
        AND     WO.ORGANIZATION_ID = X_Organization_Id
        AND     NVL(WO.REPETITIVE_SCHEDULE_ID, -1) =
                NVL(X_Repetitive_Schedule_Id, -1);

        INSERT INTO WIP_OPERATION_RESOURCES
          (WIP_ENTITY_ID, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM,
           ORGANIZATION_ID, REPETITIVE_SCHEDULE_ID,
           LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
           CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
           PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
           RESOURCE_ID, UOM_CODE,
           BASIS_TYPE, USAGE_RATE_OR_AMOUNT, ACTIVITY_ID,
           SCHEDULED_FLAG, ASSIGNED_UNITS, AUTOCHARGE_TYPE,
           STANDARD_RATE_FLAG, APPLIED_RESOURCE_UNITS, APPLIED_RESOURCE_VALUE,
           START_DATE, COMPLETION_DATE,
           ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
           ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
           ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
           ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
           ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
           ATTRIBUTE15, SCHEDULE_SEQ_NUM, SUBSTITUTE_GROUP_NUM,
           REPLACEMENT_GROUP_NUM, PRINCIPLE_FLAG, SETUP_ID)
         SELECT OPS.WIP_ENTITY_ID, OPS.OPERATION_SEQ_NUM, ORS.RESOURCE_SEQ_NUM,
                OPS.ORGANIZATION_ID, OPS.REPETITIVE_SCHEDULE_ID,
                OPS.LAST_UPDATE_DATE, OPS.LAST_UPDATED_BY, OPS.CREATION_DATE,
                OPS.CREATED_BY, OPS.LAST_UPDATE_LOGIN, OPS.REQUEST_ID,
                OPS.PROGRAM_APPLICATION_ID, OPS.PROGRAM_ID,
                OPS.PROGRAM_UPDATE_DATE, ORS.RESOURCE_ID, RSC.UNIT_OF_MEASURE,
                ORS.BASIS_TYPE, ORS.USAGE_RATE_OR_AMOUNT, ORS.ACTIVITY_ID,
                ORS.SCHEDULE_FLAG, ORS.ASSIGNED_UNITS, ORS.AUTOCHARGE_TYPE,
                ORS.STANDARD_RATE_FLAG, 0, 0,
                OPS.FIRST_UNIT_START_DATE, OPS.LAST_UNIT_COMPLETION_DATE,
                ORS.ATTRIBUTE_CATEGORY, ORS.ATTRIBUTE1, ORS.ATTRIBUTE2,
                ORS.ATTRIBUTE3, ORS.ATTRIBUTE4, ORS.ATTRIBUTE5,
                ORS.ATTRIBUTE6, ORS.ATTRIBUTE7, ORS.ATTRIBUTE8,
                ORS.ATTRIBUTE9, ORS.ATTRIBUTE10, ORS.ATTRIBUTE11,
                ORS.ATTRIBUTE12, ORS.ATTRIBUTE13, ORS.ATTRIBUTE14,
                ORS.ATTRIBUTE15, ORS.SCHEDULE_SEQ_NUM,
                ORS.SUBSTITUTE_GROUP_NUM, 0, ORS.PRINCIPLE_FLAG, ORS.SETUP_ID
           FROM BOM_RESOURCES RSC,
                BOM_OPERATION_RESOURCES ORS,
                WIP_OPERATIONS OPS
          WHERE OPS.ORGANIZATION_ID = X_Organization_Id
            AND OPS.WIP_ENTITY_ID = X_Wip_Entity_Id
            AND NVL(OPS.REPETITIVE_SCHEDULE_ID, -1) =
                NVL(X_Repetitive_Schedule_Id, -1)
            AND OPS.OPERATION_SEQUENCE_ID = ORS.OPERATION_SEQUENCE_ID
            AND ORS.RESOURCE_ID = RSC.RESOURCE_ID
            AND RSC.ORGANIZATION_ID = OPS.ORGANIZATION_ID
            AND (ORS.ACD_TYPE IS NULL OR ORS.ACD_TYPE <> 3);

        SELECT MAX(resource_seq_num)
        INTO max_seq
        FROM WIP_OPERATION_RESOURCES
        WHERE organization_id = X_Organization_Id and
              wip_entity_id = X_Wip_Entity_Id;

        INSERT INTO WIP_SUB_OPERATION_RESOURCES
          (WIP_ENTITY_ID, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM,
           ORGANIZATION_ID, REPETITIVE_SCHEDULE_ID,
           LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
           CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
           PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
           RESOURCE_ID, UOM_CODE,
           BASIS_TYPE, USAGE_RATE_OR_AMOUNT, ACTIVITY_ID,
           SCHEDULED_FLAG, ASSIGNED_UNITS, AUTOCHARGE_TYPE,
           STANDARD_RATE_FLAG, APPLIED_RESOURCE_UNITS, APPLIED_RESOURCE_VALUE,
           START_DATE, COMPLETION_DATE,
           ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
           ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
           ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
           ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
           ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
           ATTRIBUTE15, SCHEDULE_SEQ_NUM, SUBSTITUTE_GROUP_NUM,
           REPLACEMENT_GROUP_NUM, PRINCIPLE_FLAG)
         SELECT OPS.WIP_ENTITY_ID, OPS.OPERATION_SEQ_NUM,
                max_seq + ROWNUM,
                OPS.ORGANIZATION_ID, OPS.REPETITIVE_SCHEDULE_ID,
                OPS.LAST_UPDATE_DATE, OPS.LAST_UPDATED_BY, OPS.CREATION_DATE,
                OPS.CREATED_BY, OPS.LAST_UPDATE_LOGIN, OPS.REQUEST_ID,
                OPS.PROGRAM_APPLICATION_ID, OPS.PROGRAM_ID,
                OPS.PROGRAM_UPDATE_DATE, SORS.RESOURCE_ID, RSC.UNIT_OF_MEASURE,
                SORS.BASIS_TYPE, SORS.USAGE_RATE_OR_AMOUNT, SORS.ACTIVITY_ID,
                SORS.SCHEDULE_FLAG, SORS.ASSIGNED_UNITS, SORS.AUTOCHARGE_TYPE,
                SORS.STANDARD_RATE_FLAG, 0, 0,
                OPS.FIRST_UNIT_START_DATE, OPS.LAST_UNIT_COMPLETION_DATE,
                SORS.ATTRIBUTE_CATEGORY, SORS.ATTRIBUTE1, SORS.ATTRIBUTE2,
                SORS.ATTRIBUTE3, SORS.ATTRIBUTE4, SORS.ATTRIBUTE5,
                SORS.ATTRIBUTE6, SORS.ATTRIBUTE7, SORS.ATTRIBUTE8,
                SORS.ATTRIBUTE9, SORS.ATTRIBUTE10, SORS.ATTRIBUTE11,
                SORS.ATTRIBUTE12, SORS.ATTRIBUTE13, SORS.ATTRIBUTE14,
                SORS.ATTRIBUTE15, SORS.SCHEDULE_SEQ_NUM,
                SORS.SUBSTITUTE_GROUP_NUM, SORS.REPLACEMENT_GROUP_NUM,
                SORS.PRINCIPLE_FLAG
           FROM BOM_RESOURCES RSC,
                BOM_SUB_OPERATION_RESOURCES SORS,
                WIP_OPERATIONS OPS
          WHERE OPS.ORGANIZATION_ID = X_Organization_Id
            AND OPS.WIP_ENTITY_ID = X_Wip_Entity_Id
            AND NVL(OPS.REPETITIVE_SCHEDULE_ID, -1) =
                NVL(X_Repetitive_Schedule_Id, -1)
            AND OPS.OPERATION_SEQUENCE_ID = SORS.OPERATION_SEQUENCE_ID
            AND SORS.RESOURCE_ID = RSC.RESOURCE_ID
            AND RSC.ORGANIZATION_ID = OPS.ORGANIZATION_ID
            AND (SORS.ACD_TYPE IS NULL OR SORS.ACD_TYPE <> 3);

    FOR cur_rec IN wip_op_inst LOOP
      IF (X_Repetitive_Schedule_Id IS NULL) THEN
        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
        X_FROM_ENTITY_NAME => 'BOM_OPERATION_SEQUENCES',
        X_FROM_PK1_VALUE   => to_char(cur_rec.operation_sequence_id),
        X_TO_ENTITY_NAME   => 'WIP_DISCRETE_OPERATIONS',
        X_TO_PK1_VALUE   => to_char(X_Wip_Entity_Id),
        X_TO_PK2_VALUE   => to_char(cur_rec.operation_seq_num),
        X_TO_PK3_VALUE   => to_char(X_Organization_Id),
        X_CREATED_BY     => p_user_id,
        X_LAST_UPDATE_LOGIN => p_login_id,
        X_PROGRAM_APPLICATION_ID  => p_appl_id,
        X_PROGRAM_ID    => p_prog_id,
        X_REQUEST_ID    => p_req_id);

      ELSE
        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
        X_FROM_ENTITY_NAME => 'BOM_OPERATION_SEQUENCES',
        X_FROM_PK1_VALUE   => to_char(cur_rec.operation_sequence_id),
        X_TO_ENTITY_NAME   => 'WIP_REPETITIVE_OPERATIONS',
        X_TO_PK1_VALUE   => to_char(X_Wip_Entity_Id),
        X_TO_PK2_VALUE   => to_char(cur_rec.operation_seq_num),
        X_TO_PK3_VALUE   => to_char(X_Organization_Id),
        X_TO_PK4_VALUE   => to_char(X_Repetitive_Schedule_Id),
        X_CREATED_BY     => p_user_id,
        X_LAST_UPDATE_LOGIN => p_login_id,
        X_PROGRAM_APPLICATION_ID  => p_appl_id,
        X_PROGRAM_ID    => p_prog_id,
        X_REQUEST_ID    => p_req_id);

      END IF;
    END LOOP;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_scheduler.explode_routing',
                         p_procReturnStatus => 'S',
                         p_msg => 'procedure complete',
                         x_returnStatus => l_returnStatus);
    end if;
END explode_routing;

PROCEDURE update_routing(
        X_Wip_Entity_Id                 NUMBER,
        X_load_type                     NUMBER,
        X_Organization_Id               NUMBER,
        X_Repetitive_Schedule_Id        NUMBER,
        X_Start_Date                    VARCHAR2,
        X_Completion_Date               VARCHAR2,
        X_Old_Status_Type               NUMBER,
        X_Status_Type                   NUMBER,
        X_Old_Quantity                  NUMBER,
        X_Quantity                      NUMBER,
        X_Last_Updated_By               NUMBER,
        X_Last_Update_Login             NUMBER,
        X_Success_Flag   OUT  NOCOPY    NUMBER) IS
p_req_id NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
p_appl_id NUMBER := FND_GLOBAL.PROG_APPL_ID;
p_prog_id NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
x_first_op NUMBER;
x_qty_comp NUMBER;
x_start DATE;
x_comp DATE;
BEGIN

        X_Success_Flag := 1;
        x_start := to_date(X_Start_Date, WIP_CONSTANTS.DT_NOSEC_FMT);
        x_comp := to_date(X_Completion_Date, WIP_CONSTANTS.DT_NOSEC_FMT);

        /* This portion chopped from check_quantity routine in wiloer */


        /* Figure out if there are operations */

        IF X_Old_Status_Type <> 1 AND X_Status_Type <> 1
           AND X_Old_Quantity <> X_Quantity THEN
                SELECT NVL(MIN(OPERATION_SEQ_NUM), -1)
                  INTO x_first_op
                  FROM WIP_OPERATIONS
                 WHERE ORGANIZATION_ID = X_Organization_Id
                   AND WIP_ENTITY_ID = X_Wip_Entity_Id
                   AND NVL(REPETITIVE_SCHEDULE_ID, -1) =
                       NVL(X_Repetitive_Schedule_Id, -1);

        /* If there are operations */

            IF x_first_op <> -1 THEN

        /* Reset the quantity in queue for the first op */

          UPDATE WIP_OPERATIONS
             SET QUANTITY_IN_QUEUE = QUANTITY_IN_QUEUE -
                                     (SCHEDULED_QUANTITY - X_Quantity)
           WHERE ORGANIZATION_ID = X_Organization_id
             AND WIP_ENTITY_ID = X_Wip_Entity_id
             AND NVL(REPETITIVE_SCHEDULE_ID, -1) =
                       NVL(X_Repetitive_Schedule_Id, -1)
             AND OPERATION_SEQ_NUM = x_first_op
             AND SCHEDULED_QUANTITY - X_Quantity <= QUANTITY_IN_QUEUE;

        /* If no rows were updated, that means that the quantity was
           lowered below what was already past queue of the first op.
           This is an error. */

              IF SQL%NOTFOUND THEN
                        x_success_flag := 0;
                        return;
              END IF;

            ELSE

                -- I think this check is duplicated in
                -- Quantity field handler but since this package is generic...

                IF X_Repetitive_Schedule_Id IS NULL THEN
                        SELECT QUANTITY_COMPLETED
                        INTO x_qty_comp
                        FROM   WIP_DISCRETE_JOBS
                        WHERE ORGANIZATION_ID = X_Organization_id
                        AND WIP_ENTITY_ID = X_Wip_Entity_id;
                ELSE
                        SELECT QUANTITY_COMPLETED
                        INTO x_qty_comp
                        FROM   WIP_REPETITIVE_SCHEDULES
                        WHERE ORGANIZATION_ID = X_Organization_id
                        AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_id;
                END IF;

                /* For routingless jobs, you cant lower the quantity below
                   what was already completed.
                 */

                IF X_Quantity < x_qty_comp THEN
                        x_success_flag := 0;
                        return;
                END IF;

            END IF;

        END IF;   /* End of Quantity validation */

        -- Update operation quantities and dates

        UPDATE WIP_OPERATIONS
        SET FIRST_UNIT_START_DATE =  x_start,
            FIRST_UNIT_COMPLETION_DATE = decode(X_load_type, WIP_CONSTANTS.RESCHED_EAM_JOB, x_comp, x_start),
            LAST_UNIT_START_DATE = x_start,
            LAST_UNIT_COMPLETION_DATE = decode(X_load_type, WIP_CONSTANTS.RESCHED_EAM_JOB, x_comp, x_start),
            SCHEDULED_QUANTITY =
                ROUND(X_Quantity, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
            LAST_UPDATED_BY = X_Last_Updated_By,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = X_Last_Update_Login,
            REQUEST_ID = p_req_id,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROGRAM_ID = p_prog_id,
            PROGRAM_APPLICATION_ID = p_appl_id
        WHERE ORGANIZATION_ID = X_Organization_Id
        AND WIP_ENTITY_ID = X_Wip_Entity_Id
        AND NVL(REPETITIVE_SCHEDULE_ID, -1) = NVL(X_Repetitive_Schedule_ID, -1);

        /* Note that WRO quantities are NOT updated here */

        UPDATE WIP_REQUIREMENT_OPERATIONS WRO
           SET WRO.DATE_REQUIRED =
                (SELECT NVL(MIN(FIRST_UNIT_START_DATE), X_Start)
                 FROM   WIP_OPERATIONS
                 WHERE ORGANIZATION_ID = X_Organization_Id
                 AND   WIP_ENTITY_ID = X_Wip_Entity_Id
                 AND NVL(REPETITIVE_SCHEDULE_ID, -1) =
                     NVL(X_Repetitive_Schedule_ID, -1)
                 AND OPERATION_SEQ_NUM = ABS(WRO.OPERATION_SEQ_NUM)),
            LAST_UPDATED_BY = X_Last_Updated_By,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = X_Last_Update_Login,
            REQUEST_ID = p_req_id,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROGRAM_ID = p_prog_id,
            PROGRAM_APPLICATION_ID = p_appl_id
        WHERE ORGANIZATION_ID = X_Organization_Id
        AND WIP_ENTITY_ID = X_Wip_Entity_Id
        AND NVL(REPETITIVE_SCHEDULE_ID, -1) = NVL(X_Repetitive_Schedule_ID, -1);

        UPDATE WIP_OPERATION_RESOURCES
            SET START_DATE = X_Start,
            COMPLETION_DATE = DECODE(X_load_type, WIP_CONSTANTS.RESCHED_EAM_JOB , x_comp, x_start) ,
            LAST_UPDATED_BY = X_Last_Updated_By,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = X_Last_Update_Login,
            REQUEST_ID = p_req_id,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROGRAM_ID = p_prog_id,
            PROGRAM_APPLICATION_ID = p_appl_id
        WHERE ORGANIZATION_ID = X_Organization_Id
        AND WIP_ENTITY_ID = X_Wip_Entity_Id
        AND NVL(REPETITIVE_SCHEDULE_ID, -1) = NVL(X_Repetitive_Schedule_ID, -1);

END update_routing;

END WIP_SCHEDULER;

/
