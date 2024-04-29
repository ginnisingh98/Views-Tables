--------------------------------------------------------
--  DDL for Package Body WIP_SF_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_SF_STATUS" AS
 /* $Header: wipsfstb.pls 120.2 2006/01/10 18:04:37 kboonyap noship $ */

  PROCEDURE INSERT_STATUS
    (P_wip_entity_id            IN      NUMBER,
     P_organization_id          IN      NUMBER,
     P_line_id                  IN      NUMBER,
     P_operation_seq_num        IN      NUMBER,
     P_intraoperation_step_type IN      NUMBER,
     P_shop_floor_status        IN      VARCHAR2) IS

     X_user_id  NUMBER  := FND_GLOBAL.USER_ID;
     X_login_id NUMBER  := FND_GLOBAL.LOGIN_ID;

   BEGIN

        INSERT INTO WIP_SHOP_FLOOR_STATUSES
          (WIP_ENTITY_ID, ORGANIZATION_ID,
           OPERATION_SEQ_NUM, SHOP_FLOOR_STATUS_CODE,
           LINE_ID, INTRAOPERATION_STEP_TYPE,
           LAST_UPDATE_DATE, LAST_UPDATED_BY,
           CREATION_DATE, CREATED_BY,
           LAST_UPDATE_LOGIN, ATTRIBUTE_CATEGORY,
           ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
           ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
           ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
           ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15)
        SELECT
           P_wip_entity_id, P_organization_id,
           P_operation_seq_num, P_shop_floor_status,
           P_line_id, P_intraoperation_step_type,
           SYSDATE, X_user_id,
           SYSDATE, X_user_id,
           X_login_id, ATTRIBUTE_CATEGORY,
           ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
           ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
           ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
           ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15
        FROM WIP_SHOP_FLOOR_STATUS_CODES
        WHERE ORGANIZATION_ID = P_organization_id
          AND SHOP_FLOOR_STATUS_CODE = P_shop_floor_status
          AND NOT EXISTS
              (SELECT 'testing for duplicates'
               FROM WIP_SHOP_FLOOR_STATUSES
               WHERE WIP_ENTITY_ID = P_wip_entity_id
               AND OPERATION_SEQ_NUM = P_operation_seq_num
               AND SHOP_FLOOR_STATUS_CODE = P_shop_floor_status
               AND ORGANIZATION_ID =  P_organization_id
               AND NVL(LINE_ID, -1) = NVL(P_line_id, -1)
               AND INTRAOPERATION_STEP_TYPE = P_intraoperation_step_type)
          AND (EXISTS(
                SELECT 'job_exists'
                FROM    WIP_DISCRETE_JOBS wdj
                WHERE   wdj.wip_entity_id = P_wip_entity_id
                  AND   wdj.organization_id = P_organization_id)
           OR EXISTS(
                SELECT 'schedule exists'
                  FROM wip_repetitive_schedules wrs
                 WHERE wrs.line_id = P_line_id
                   AND wrs.organization_id = P_organization_id
                   AND wrs.wip_entity_id = P_wip_entity_id));
  END INSERT_STATUS;

  PROCEDURE DELETE_STATUS(
        P_wip_entity_id                 IN NUMBER,
        P_organization_id               IN NUMBER,
        P_line_id                       IN NUMBER,
        P_operation_seq_num             IN NUMBER,
        P_intraoperation_step_type      IN NUMBER,
        P_shop_floor_status             IN VARCHAR2)  IS

  BEGIN

        DELETE FROM WIP_SHOP_FLOOR_STATUSES WSFS
        WHERE
                WSFS.wip_entity_id = P_wip_entity_id
        AND     WSFS.organization_id = P_organization_id
        AND     WSFS.operation_seq_num = P_operation_seq_num
        AND     WSFS.intraoperation_step_type = P_intraoperation_step_type
        AND     NVL(WSFS.line_id, -1)  = NVL(P_line_id, -1)
        AND     WSFS.shop_floor_status_code = P_shop_floor_status;

  END DELETE_STATUS;

  PROCEDURE ATTACH
    (P_wip_entity_id            NUMBER,
     P_organization_id          NUMBER,
     P_line_id                  NUMBER,
     P_operation_seq_num        NUMBER,
     P_intraoperation_step_type NUMBER,
     P_shop_floor_status        VARCHAR2) IS

    X_test_cursor VARCHAR2(30) := '';
    X_return_value BOOLEAN := TRUE;

    CURSOR disc_info IS
    SELECT 'is there a valid job'
      FROM WIP_DISCRETE_JOBS
     WHERE WIP_ENTITY_ID = P_wip_entity_id
       AND ORGANIZATION_ID = P_organization_id
       AND STATUS_TYPE IN (WIP_CONSTANTS.UNRELEASED, WIP_CONSTANTS.RELEASED,
                           WIP_CONSTANTS.COMP_CHRG, WIP_CONSTANTS.HOLD);

    CURSOR rep_info IS
    SELECT 'is there a valid schedule'
      FROM WIP_FIRST_OPEN_SCHEDULE_V
     WHERE ORGANIZATION_ID = P_organization_id
       AND WIP_ENTITY_ID = P_wip_entity_id
       AND LINE_ID = P_line_id;

    CURSOR step_info IS
    SELECT 'is the step enabled'
      FROM wip_valid_intraoperation_steps
     WHERE organization_id = P_organization_id
       AND step_lookup_type = P_intraoperation_step_type
       AND ((P_intraoperation_step_type = WIP_CONSTANTS.TOMOVE AND
             record_creator = 'USER')
             OR
            (P_intraoperation_step_type <> WIP_CONSTANTS.TOMOVE));

    CURSOR status_info IS
    SELECT 'is the status valid'
      FROM WIP_SHOP_FLOOR_STATUS_CODES
     WHERE SHOP_FLOOR_STATUS_CODE = P_shop_floor_status
       AND ORGANIZATION_ID = P_organization_id
       AND NVL(DISABLE_DATE, SYSDATE + 1) > SYSDATE;


  BEGIN
    IF (P_line_id IS NULL) THEN
      OPEN disc_info;
      FETCH disc_info INTO X_test_cursor;
      IF disc_info%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('WIP', 'WIP_QA_ACTION_NO_ASSIGN_JOB');
        X_return_value := FALSE;
        END IF;
      CLOSE disc_info;
    ELSE
      OPEN rep_info;
      FETCH rep_info INTO X_test_cursor;
      IF rep_info%NOTFOUND THEN
        X_return_value := FALSE;
        END IF;
      CLOSE rep_info;
      END IF;
    IF X_return_value THEN
      OPEN step_info;
      FETCH STEP_INFO INTO X_test_cursor;
      IF step_info%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('WIP', 'WIP_QA_ACTION_NO_ASSIGN_STEP');
        X_return_value := FALSE;
        END IF;
      CLOSE step_info;
      END IF;
    IF X_return_value THEN
      OPEN status_info;
      FETCH status_info INTO X_test_cursor;
      IF status_info%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('WIP', 'WIP_QA_ACTION_NO_ASSIGN_SFS');
        X_return_value := FALSE;
        END IF;
      CLOSE status_info;
      END IF;
    IF (X_return_value) THEN
        INSERT_STATUS (
                P_wip_entity_id,
                P_organization_id,
                P_line_id,
                P_operation_seq_num,
                P_intraoperation_step_type,
                P_shop_floor_status);
    END IF;
    IF NOT X_return_value THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
  END ATTACH;

  FUNCTION GetOSPStatus (p_org_id       NUMBER) return VARCHAR2 is
     l_osp_shop_floor_status    VARCHAR2(10);

     cursor get_status (c_org_id number) is
       select osp_shop_floor_status
       from wip_parameters wp
       where wp.organization_id = c_org_id;
  BEGIN
     OPEN get_status (p_org_id);
     FETCH get_status into l_osp_shop_floor_status;

     if (get_status%NOTFOUND) then
        l_osp_shop_floor_status := NULL;
     end if;

     CLOSE get_status;
     return l_osp_shop_floor_status;

  END GetOSPStatus;

  PROCEDURE CREATE_OSP_STATUS(
        p_org_id                in number,
        p_wip_entity_id         in number,
        p_repetitive_sched_id   in number DEFAULT NULL,
        p_operation_seq_num     in number DEFAULT NULL
  ) IS
        l_osp_shop_floor_status VARCHAR2(10);
        l_line_id               NUMBER := NULL;

        CURSOR cwop IS
        SELECT
                wo.operation_seq_num
        FROM    wip_operation_resources wo
        WHERE   wo.wip_entity_id = p_wip_entity_id
          AND   wo.organization_id = p_org_id
          AND   nvl (wo.repetitive_schedule_id, -1) = nvl(p_repetitive_sched_id,-1)
          AND   wo.autocharge_type = WIP_CONSTANTS.PO_MOVE;

  BEGIN
        l_osp_shop_floor_status := GetOSPStatus (p_org_id);
        l_line_id := wip_repetitive_utilities.get_line_id
                                (p_repetitive_sched_id, p_org_id);

        IF p_operation_seq_num is null then
                FOR cwop_rec in cwop LOOP
                    INSERT_STATUS (
                        P_wip_entity_id         => p_wip_entity_id,
                        P_organization_id       => p_org_id,
                        P_line_id               => l_line_id,
                        P_operation_seq_num     => cwop_rec.operation_seq_num,
                        P_intraoperation_step_type => WIP_CONSTANTS.QUEUE,
                        P_shop_floor_status     => l_osp_shop_floor_status);
                END LOOP;
        else
            INSERT_STATUS (
                P_wip_entity_id         => p_wip_entity_id,
                P_organization_id       => p_org_id,
                P_line_id               => l_line_id,
                P_operation_seq_num     => p_operation_seq_num,
                P_intraoperation_step_type => WIP_CONSTANTS.QUEUE,
                P_shop_floor_status     => l_osp_shop_floor_status);

        end if;
  END CREATE_OSP_STATUS;

  PROCEDURE REMOVE_OSP_STATUS(
        p_org_id                in number,
        p_wip_entity_id         in number,
        p_repetitive_sched_id   in number DEFAULT NULL,
        p_operation_seq_num     in number DEFAULT NULL
  ) IS
        l_osp_shop_floor_status VARCHAR2(10);
        l_line_id               NUMBER;

        CURSOR cwop IS
        SELECT
                wo.operation_seq_num
        FROM    wip_operation_resources wo
        WHERE   wo.wip_entity_id = p_wip_entity_id
          AND   wo.organization_id = p_org_id
          AND   nvl (wo.repetitive_schedule_id, -1) = nvl(p_repetitive_sched_id,-1)
          AND   wo.autocharge_type = WIP_CONSTANTS.PO_MOVE;

  BEGIN

        l_osp_shop_floor_status := GetOSPStatus (p_org_id);
        l_line_id := wip_repetitive_utilities.get_line_id
                                (p_repetitive_sched_id, p_org_id);

        if (p_operation_seq_num is NULL) then
                FOR cwop_rec in cwop LOOP
                    DELETE_STATUS (
                        p_wip_entity_id         => p_wip_entity_id,
                        p_organization_id       => p_org_id,
                        p_line_id               => l_line_id,
                        p_operation_seq_num     => cwop_rec.operation_seq_num,
                        p_intraoperation_step_type => WIP_CONSTANTS.QUEUE,
                        p_shop_floor_status     => l_osp_shop_floor_status);
                END LOOP;

        else
                DELETE_STATUS(
                   p_wip_entity_id              => p_wip_entity_id,
                   p_organization_id    => p_org_id,
                   p_line_id            => l_line_id,
                   p_operation_seq_num  => p_operation_seq_num,
                   p_intraoperation_step_type => WIP_CONSTANTS.QUEUE,
                   p_shop_floor_status  => l_osp_shop_floor_status);
        end if;

  END REMOVE_OSP_STATUS;

  function count_no_move_statuses(
    p_org_id   in number,
    p_wip_id   in number,
    p_line_id  in number,
    p_sched_id in number,
    p_fm_op    in number,
    p_fm_step  in number,
    p_to_op    in number,
    p_to_step  in number,
    p_source_code in varchar2 default null) return number is

    x_no_move_count number := 0;

  begin
    SELECT COUNT(1)
    INTO   x_no_move_count
    FROM WIP_OPERATIONS WOP,
         WIP_OPERATION_RESOURCES WOR,
         WIP_PARAMETERS WP,
         WIP_SHOP_FLOOR_STATUS_CODES WSFSC,
         WIP_SHOP_FLOOR_STATUSES WSFS
    WHERE WSFS.INTRAOPERATION_STEP_TYPE IN (1,/* Queue */
                                            2,/* Run */
                                            3 /* To Move */)
    AND   WP.ORGANIZATION_ID = p_org_id
    AND   NVL(WP.MOVES_OVER_NO_MOVE_STATUSES, 1) = 2 /* No */
    /* Fix for bug 2121222 */
    AND  NOT EXISTS
               (Select 'X' from WIP_OPERATION_RESOURCES WOR1
                      WHERE  WOR1.WIP_ENTITY_ID = p_wip_id
                             AND WOR1.ORGANIZATION_ID = p_org_id
                             AND  WOR1.OPERATION_SEQ_NUM = p_fm_op
                             AND  (WOR1.REPETITIVE_SCHEDULE_ID = p_sched_id
                                 OR  (WOR1.REPETITIVE_SCHEDULE_ID IS NULL AND p_sched_id IS NULL))
                             AND  WOR1.AUTOCHARGE_TYPE = 4
                             AND   p_source_code = 'RCV' )
    AND   WSFS.ORGANIZATION_ID = wp.organization_id
    AND   WSFS.WIP_ENTITY_ID = p_wip_id
    AND   (WSFS.LINE_ID = p_line_id
           OR (WSFS.LINE_ID IS NULL AND p_line_id IS NULL))
    AND   WSFSC.ORGANIZATION_ID = WSFS.ORGANIZATION_ID
    AND   WSFSC.SHOP_FLOOR_STATUS_CODE = WSFS.SHOP_FLOOR_STATUS_CODE
    AND   WSFSC.STATUS_MOVE_FLAG = 2 /* No */
    AND   WOP.ORGANIZATION_ID = WSFS.ORGANIZATION_ID
    AND   WOP.WIP_ENTITY_ID = WSFS.WIP_ENTITY_ID
    AND   (WOP.REPETITIVE_SCHEDULE_ID = p_sched_id
           OR (WOP.REPETITIVE_SCHEDULE_ID IS NULL AND p_sched_id IS NULL))
    AND   WOP.OPERATION_SEQ_NUM = WSFS.OPERATION_SEQ_NUM
    AND   WOR.ORGANIZATION_ID (+)= WSFS.ORGANIZATION_ID
    AND   WOR.WIP_ENTITY_ID (+)= WSFS.WIP_ENTITY_ID
    AND   WOR.OPERATION_SEQ_NUM (+)= WSFS.OPERATION_SEQ_NUM

/* Remove 2 statements below because WOR.REPETITIVE_SCHEDULE_ID can be null
 * even for repetitive because the user do not have to set up resource before
 * do move transaction while p_schedule_id is always not null because it is
 * default to first_schedule_id. So we should compare with first_schedule_id
 * only when this value is not null.
 */
--    AND   (WOR.REPETITIVE_SCHEDULE_ID = p_sched_id
--           OR (WOR.REPETITIVE_SCHEDULE_ID IS NULL AND p_sched_id IS NULL))
    AND   (WOR.REPETITIVE_SCHEDULE_ID IS NULL OR
           WOR.REPETITIVE_SCHEDULE_ID = p_sched_id)
    AND
    ((/* forward move - different operations */
      (p_fm_op < p_to_op)
      AND
      (/* shop floor status is between from and to operations
          and at a count point operation */
       (p_fm_op < WSFS.OPERATION_SEQ_NUM
        AND WSFS.OPERATION_SEQ_NUM < p_to_op
        AND WSFS.OPERATION_SEQ_NUM = WOP.OPERATION_SEQ_NUM
        AND WOP.COUNT_POINT_TYPE IN (1,/* Yes Auto */
                                     2 /* No Auto */))
       OR
       (/* shop floor status is at the same operation as from operation
           but after the from intraoperation step */
        p_fm_op = WSFS.OPERATION_SEQ_NUM
        AND p_fm_step <= WSFS.INTRAOPERATION_STEP_TYPE)
       OR
       (/* shop floor status is at the same operation as to operation
           but before the to intraoperation step */
        p_to_op = WSFS.OPERATION_SEQ_NUM
        AND WSFS.INTRAOPERATION_STEP_TYPE < p_to_step)))
     OR
     (/* forward move - same operation */
      (p_fm_op = p_to_op AND p_fm_step < p_to_step)
      AND
      (/* shop floor status is at same operation as from operation but
          between the from intraoperation step and to intraoperation step */
       p_fm_op = WSFS.OPERATION_SEQ_NUM
       AND p_fm_step <= WSFS.INTRAOPERATION_STEP_TYPE
       AND WSFS.INTRAOPERATION_STEP_TYPE < p_to_step))
     OR
     (/* backward move - different operations */
      (p_fm_op > p_to_op)
      AND
      (/* shop floor status is between to and from operations
          and at a count point operation */
       (p_fm_op > WSFS.OPERATION_SEQ_NUM
        AND WSFS.OPERATION_SEQ_NUM > p_to_op
        AND WSFS.OPERATION_SEQ_NUM = WOP.OPERATION_SEQ_NUM
        AND WOP.COUNT_POINT_TYPE IN (1,/* Yes Auto */
                                     2 /* No Auto */))
       OR
       (/* shop floor status is at the same operation as from operation
           but before the from intraoperation step */
        p_fm_op = WSFS.OPERATION_SEQ_NUM
        AND p_fm_step >= WSFS.INTRAOPERATION_STEP_TYPE)
       OR
       (/* shop floor status is at the same operation as to operation
           but after the to intraoperation step */
        p_to_op = WSFS.OPERATION_SEQ_NUM
        AND WSFS.INTRAOPERATION_STEP_TYPE > p_to_step)))
     OR
     (/* backward move - same operation */
      (p_fm_op = p_to_op AND p_fm_step > p_to_step)
      AND
      (/* shop floor status is at same operation as from operation but
          between the from intraoperation step and to intraoperation step */
       p_fm_op = WSFS.OPERATION_SEQ_NUM
       AND p_fm_step >= WSFS.INTRAOPERATION_STEP_TYPE
       AND WSFS.INTRAOPERATION_STEP_TYPE > p_to_step)));

     return(x_no_move_count);
  end count_no_move_statuses;

  FUNCTION count_no_move_last_step(p_org_id IN NUMBER,
                                   p_wip_id IN NUMBER) RETURN NUMBER IS

  l_params        wip_logger.param_tbl_t;
  l_returnStatus  VARCHAR2(1);
  l_logLevel      NUMBER := fnd_log.g_current_runtime_level;
  l_no_move_count NUMBER := 0;
  BEGIN
     -- write parameter value to log file
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      l_params(1).paramName   := 'p_org_id';
      l_params(1).paramValue  :=  p_org_id;
      l_params(2).paramName   := 'p_wip_id';
      l_params(2).paramValue  :=  p_wip_id;
      wip_logger.entryPoint(p_procName     => 'wip_sf_status.count_no_move_last_step',
                            p_params       => l_params,
                            x_returnStatus => l_returnStatus);
    END IF;

    SELECT count(*)
      INTO l_no_move_count
      FROM wip_shop_floor_status_codes wsc,
           wip_shop_floor_statuses ws,
           wip_operations wo1
     WHERE ws.organization_id = p_org_id
       AND ws.wip_entity_id = p_wip_id
       AND wsc.organization_id = ws.organization_id
       AND wo1.operation_seq_num = ws.operation_seq_num
       AND wo1.organization_id = ws.organization_id
       AND wo1.wip_entity_id = ws.wip_entity_id
       AND wo1.operation_seq_num =
           (SELECT max(wo2.operation_seq_num)
              FROM wip_operations wo2
             WHERE wo2.organization_id = wo1.organization_id
               AND wo2.wip_entity_id = wo1.wip_entity_id)
       AND ws.intraoperation_step_type = WIP_CONSTANTS.TOMOVE
       AND ws.shop_floor_status_code = wsc.shop_floor_status_code
       AND wsc.status_move_flag = WIP_CONSTANTS.NO
       AND NVL(wsc.disable_date, SYSDATE + 1) > SYSDATE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_sf_status.count_no_move_last_step',
                           p_procReturnStatus => fnd_api.g_ret_sts_success,
                           p_msg => 'procedure complete',
                           x_returnStatus => l_returnStatus);
    END IF;
    RETURN l_no_move_count;
  EXCEPTION
    WHEN others THEN
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(p_procName => 'wip_sf_status.count_no_move_last_step',
                             p_procReturnStatus => fnd_api.g_ret_sts_unexp_error,
                             p_msg => 'Unexpected Errors: ' || SQLERRM,
                             x_returnStatus => l_returnStatus);
      END IF;
  END count_no_move_last_step;

END WIP_SF_STATUS;

/
