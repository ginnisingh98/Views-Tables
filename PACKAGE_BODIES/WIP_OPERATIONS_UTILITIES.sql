--------------------------------------------------------
--  DDL for Package Body WIP_OPERATIONS_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_OPERATIONS_UTILITIES" AS
/* $Header: wipoputb.pls 120.2.12010000.2 2008/09/24 16:14:24 tbhande ship $ */

  PROCEDURE Check_Unique(X_Wip_Entity_Id                 NUMBER,
                         X_Organization_Id               NUMBER,
                         X_Operation_Seq_Num             NUMBER,
                         X_Repetitive_Schedule_Id        NUMBER) IS
    ops_count NUMBER := 0;
    cursor discrete_check is
           SELECT count(*)
           FROM   WIP_OPERATIONS
           WHERE  ORGANIZATION_ID = X_Organization_Id
           AND    WIP_ENTITY_ID = X_Wip_Entity_Id
           AND    OPERATION_SEQ_NUM = X_Operation_Seq_Num;
    cursor repetitive_check is
           SELECT count(*)
           FROM   WIP_OPERATIONS
           WHERE  ORGANIZATION_ID = X_Organization_Id
           AND    WIP_ENTITY_ID = X_Wip_Entity_Id
           AND    OPERATION_SEQ_NUM = X_Operation_Seq_Num
           AND    REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id;
  BEGIN
     IF X_Repetitive_Schedule_Id IS NULL then
        open discrete_check;
        fetch discrete_check into ops_count;
        close discrete_check;
     ELSE
        open repetitive_check;
        fetch repetitive_check into ops_count;
        close repetitive_check;
     END IF;
     IF ops_count <> 0 THEN
        FND_MESSAGE.SET_NAME('WIP','WIP_ALREADY_EXISTS');
        FND_MESSAGE.SET_TOKEN('ENTITY1',
                              'operation sequence number-cap', TRUE);
        fnd_message.raise_error;
        app_exception.raise_exception;
     END IF;
  END Check_Unique;

  FUNCTION Pending_Op_Txns(X_Wip_Entity_Id              NUMBER,
                        X_Organization_Id               NUMBER,
                        X_Operation_Seq_Num             NUMBER,
                        X_Repetitive_Schedule_Id        NUMBER,
                        X_Line_Id                       NUMBER)
                return BOOLEAN IS
    X_count NUMBER := 0;
    retval BOOLEAN;
    cursor disc_move_check is
            SELECT 1
              FROM WIP_MOVE_TXN_INTERFACE
             WHERE ORGANIZATION_ID = X_Organization_Id
               AND WIP_ENTITY_ID = X_Wip_Entity_Id
               AND (FM_OPERATION_SEQ_NUM = X_Operation_Seq_Num
                    OR TO_OPERATION_SEQ_NUM = X_Operation_Seq_Num);
    cursor disc_res_check is
            SELECT 1
              FROM WIP_OPERATION_RESOURCES
             WHERE ORGANIZATION_ID = X_Organization_Id
               AND WIP_ENTITY_ID = X_Wip_Entity_Id
               AND OPERATION_SEQ_NUM = X_Operation_Seq_Num
               AND APPLIED_RESOURCE_UNITS <> 0;
    cursor disc_cost_check is
            SELECT 1
              FROM WIP_COST_TXN_INTERFACE
             WHERE ORGANIZATION_ID = X_Organization_Id
               AND WIP_ENTITY_ID = X_Wip_Entity_Id
               AND OPERATION_SEQ_NUM = X_Operation_Seq_Num;
    cursor rep_move_check is
            SELECT 1
              FROM WIP_MOVE_TXN_INTERFACE
             WHERE ORGANIZATION_ID = X_Organization_Id
               AND WIP_ENTITY_ID = X_Wip_Entity_Id
               AND LINE_ID = X_Line_Id
               AND (FM_OPERATION_SEQ_NUM = X_Operation_Seq_Num
                    OR TO_OPERATION_SEQ_NUM = X_Operation_Seq_Num);
    cursor rep_res_check is
            SELECT 1
              FROM WIP_OPERATION_RESOURCES
             WHERE ORGANIZATION_ID = X_Organization_Id
               AND WIP_ENTITY_ID = X_Wip_Entity_Id
               AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
               AND OPERATION_SEQ_NUM = X_Operation_Seq_Num
               AND APPLIED_RESOURCE_UNITS <> 0;
    cursor rep_cost_check is
            SELECT 1
              FROM WIP_COST_TXN_INTERFACE
             WHERE ORGANIZATION_ID = X_Organization_Id
               AND WIP_ENTITY_ID = X_Wip_Entity_Id
               AND LINE_ID = X_Line_Id
               AND OPERATION_SEQ_NUM = X_Operation_Seq_Num;
  BEGIN
    IF X_Repetitive_Schedule_Id IS NULL THEN
      open disc_move_check;
      open disc_res_check;
      open disc_cost_check;
      fetch disc_move_check into X_count;
      fetch disc_res_check into X_count;
      fetch disc_cost_check into X_count;
      retval := (NOT (disc_move_check%NOTFOUND AND disc_res_check%NOTFOUND AND disc_cost_check%NOTFOUND));
      close disc_move_check;
      close disc_res_check;
      close disc_cost_check;
    ELSE
      open rep_move_check;
      open rep_res_check;
      open rep_cost_check;
      fetch rep_move_check into X_count;
      fetch rep_res_check into X_count;
      fetch rep_cost_check into X_count;
      retval := (NOT (rep_move_check%NOTFOUND AND rep_res_check%NOTFOUND AND rep_cost_check%NOTFOUND));
      close rep_move_check;
      close rep_res_check;
      close rep_cost_check;
    END IF;
    return retval;
  END Pending_Op_Txns;


  FUNCTION Get_Previous_Op(X_Wip_Entity_Id                 NUMBER,
                           X_Organization_Id               NUMBER,
                           X_Operation_Seq_Num             NUMBER,
                           X_Repetitive_Schedule_Id        NUMBER)
                return NUMBER IS
    opseq NUMBER;
    cursor disc_op is
        select max(operation_seq_num)
        from   wip_operations
        where  wip_entity_id = X_Wip_Entity_Id
        and    organization_id = X_Organization_Id
        and    operation_seq_num < X_Operation_Seq_Num;
    cursor rep_op is
        select max(operation_seq_num)
        from   wip_operations
        where  wip_entity_id = X_Wip_Entity_Id
        and    organization_id = X_Organization_Id
        and    operation_seq_num < X_Operation_Seq_Num
        and    repetitive_schedule_id = X_Repetitive_Schedule_Id;
  BEGIN
     IF X_Repetitive_Schedule_Id IS NULL THEN
        open disc_op;
        fetch disc_op into opseq;
        close disc_op;
     ELSE
        open rep_op;
        fetch rep_op into opseq;
        close rep_op;
     END IF;
     return opseq;
  END Get_Previous_Op;


  PROCEDURE Get_Prev_Next_Op(X_Wip_Entity_Id                 NUMBER,
                             X_Organization_Id               NUMBER,
                             X_Operation_Seq_Num             NUMBER,
                             X_Repetitive_Schedule_Id        NUMBER,
                             X_Insert_Flag                   BOOLEAN,
                             X_Prev_Op_Seq                   IN OUT NOCOPY NUMBER,
                             X_Next_Op_Seq                   IN OUT NOCOPY NUMBER) IS
  BEGIN
     IF X_Repetitive_Schedule_Id IS NULL THEN
        select max(operation_seq_num)
        into   X_Prev_Op_Seq
        from   wip_operations
        where  wip_entity_id = X_Wip_Entity_Id
        and    organization_id = X_Organization_Id
        and    operation_seq_num < X_Operation_Seq_Num;
        select min(operation_seq_num)
        into   X_Next_Op_Seq
        from   wip_operations
        where  wip_entity_id = X_Wip_Entity_Id
        and    organization_id = X_Organization_Id
        and    operation_seq_num > X_Operation_Seq_Num;
    ELSE
        select max(operation_seq_num)
        into   X_Prev_Op_Seq
        from   wip_operations
        where  wip_entity_id = X_Wip_Entity_Id
        and    organization_id = X_Organization_Id
        and    operation_seq_num < X_Operation_Seq_Num
        and    repetitive_schedule_id = X_Repetitive_Schedule_Id;
        select min(operation_seq_num)
        into   X_Next_Op_Seq
        from   wip_operations
        where  wip_entity_id = X_Wip_Entity_Id
        and    organization_id = X_Organization_Id
        and    operation_seq_num > X_Operation_Seq_Num
        and    repetitive_schedule_id = X_Repetitive_Schedule_Id;
     END IF;
     IF X_Insert_Flag THEN
       IF (X_Prev_Op_Seq IS NOT NULL) THEN
         Set_Next_Op(X_Wip_Entity_Id,
                     X_Organization_Id,
                     X_Prev_Op_Seq,
                     X_Operation_Seq_Num,
                     X_Repetitive_Schedule_Id);
       END IF;
       IF (X_Next_Op_Seq IS NOT NULL) THEN
         Set_Previous_Op(X_Wip_Entity_Id,
                         X_Organization_Id,
                         X_Next_Op_Seq,
                         X_Operation_Seq_Num,
                         X_Repetitive_Schedule_Id);
       END IF;
     ELSE -- Called by pre-delete
       IF (X_Prev_Op_Seq IS NOT NULL) THEN
         Set_Next_Op(X_Wip_Entity_Id,
                     X_Organization_Id,
                     X_Prev_Op_Seq,
                     X_Next_Op_Seq,
                     X_Repetitive_Schedule_Id);
       END IF;
       IF (X_Next_Op_Seq IS NOT NULL) THEN
         Set_Previous_Op(X_Wip_Entity_Id,
                         X_Organization_Id,
                         X_Next_Op_Seq,
                         X_Prev_Op_Seq,
                         X_Repetitive_Schedule_Id);
       END IF;
     END IF;

  END Get_Prev_Next_Op;

  PROCEDURE Set_Previous_Op(X_Wip_Entity_Id             NUMBER,
                            X_Organization_Id           NUMBER,
                            X_Operation_Seq_Num         NUMBER,
                            X_Prev_Op_Seq               NUMBER,
                            X_Repetitive_Schedule_Id    NUMBER) IS
  BEGIN
     IF X_Repetitive_Schedule_Id IS NULL then
        update wip_operations
        set    previous_operation_seq_num = X_Prev_Op_Seq
        where  wip_entity_id = X_Wip_Entity_Id
        and    organization_id = X_Organization_Id
        and    operation_seq_num = X_Operation_Seq_Num;
     ELSE
        update wip_operations
        set    previous_operation_seq_num = X_Prev_Op_Seq
        where  wip_entity_id = X_Wip_Entity_Id
        and    organization_id = X_Organization_Id
        and    repetitive_schedule_id = X_Repetitive_Schedule_Id
        and    operation_seq_num = X_Operation_Seq_Num;
     END IF;
  END Set_Previous_Op;

  PROCEDURE Set_Next_Op(X_Wip_Entity_Id                 NUMBER,
                        X_Organization_Id               NUMBER,
                        X_Operation_Seq_Num             NUMBER,
                        X_Next_Op_Seq                   NUMBER,
                        X_Repetitive_Schedule_Id        NUMBER) IS
  BEGIN
     IF X_Repetitive_Schedule_Id IS NULL then
        update wip_operations
        set    next_operation_seq_num = X_Next_Op_Seq
        where  wip_entity_id = X_Wip_Entity_Id
        and    organization_id = X_Organization_Id
        and    operation_seq_num = X_Operation_Seq_Num;
     ELSE
        update wip_operations
        set    next_operation_seq_num = X_Next_Op_Seq
        where  wip_entity_id = X_Wip_Entity_Id
        and    organization_id = X_Organization_Id
        and    repetitive_schedule_id = X_Repetitive_Schedule_Id
        and    operation_seq_num = X_Operation_Seq_Num;
     END IF;
  END Set_Next_Op;

  PROCEDURE Delete_Resources(X_Wip_Entity_Id                     NUMBER,
                             X_Organization_Id                   NUMBER,
                             X_Operation_Seq_Num                 NUMBER,
                             X_Repetitive_Schedule_Id            NUMBER,
                             x_return_status          OUT NOCOPY VARCHAR2) IS

    -- remove cursors to check po/req exists because these cursors does not
    -- consider canceled po/req. Morever, we already had an API to do this job
    -- , so we will call wip_osp.po_req_exists instead.
    l_propagate_job_change_to_po NUMBER;
    l_entity_type NUMBER;
    l_return_status VARCHAR2(1);
  BEGIN
    IF(X_Operation_Seq_Num IS NULL) THEN
      return;
    END IF;
    x_return_status := fnd_api.g_ret_sts_success;
    IF(x_repetitive_schedule_id IS NULL) THEN
      l_entity_type := WIP_CONSTANTS.DISCRETE;
    ELSE
      l_entity_type := WIP_CONSTANTS.REPETITIVE;
    END IF;
    IF(wip_osp.po_req_exists(
         p_wip_entity_id    => x_wip_entity_id,
         p_rep_sched_id     => x_repetitive_schedule_id,
         p_organization_id  => x_organization_id,
         p_op_seq_num       => x_operation_seq_num,
         p_entity_type      => l_entity_type)) THEN

      IF(po_code_release_grp.Current_Release >=
         po_code_release_grp.PRC_11i_Family_Pack_J) THEN

        SELECT propagate_job_change_to_po
          INTO l_propagate_job_change_to_po
          FROM wip_parameters
         WHERE organization_id = x_organization_id;

        IF(l_propagate_job_change_to_po = WIP_CONSTANTS.YES) THEN
          -- Try to  cancel PO/requisitions
          wip_osp.cancelPOReq(
            p_job_id        => x_wip_entity_id,
            p_repetitive_id => x_repetitive_schedule_id,
            p_org_id        => x_organization_id,
            p_op_seq_num    => x_operation_seq_num,
            x_return_status => l_return_status);

          IF(l_return_status <> fnd_api. g_ret_sts_success) THEN
            -- If we are unable to cancel all PO/requisition associated to
            -- this job/schedule, we will try to cancel as much as we can,
            -- then user need to manually cancel the rest.
            x_return_status := fnd_api.g_ret_sts_error;
          END IF; -- check return status
        ELSE
          -- propagate_job_change_to_po is manual
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name('WIP','WIP_DELETE_OSP_RESOURCE');
          fnd_msg_pub.add;
        END IF;
      ELSE
        -- customer does not have PO patchset J onward
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_message.set_name('WIP','WIP_DELETE_OSP_RESOURCE');
        fnd_msg_pub.add;
      END IF;
    END IF; -- PO/requisition exists
  END Delete_Resources;

  PROCEDURE Insert_Resources(X_Wip_Entity_Id            NUMBER,
                             X_Organization_Id          NUMBER,
                             X_Operation_Seq_Num        NUMBER,
                             X_Standard_Operation_Id    NUMBER,
                             X_Repetitive_Schedule_Id   NUMBER,
                             X_Last_Updated_By          NUMBER,
                             X_Created_By               NUMBER,
                             X_Last_Update_Login        NUMBER,
                             X_Start_Date               DATE,
                             X_Completion_Date          DATE) IS
  /* Added : -- bug 7371859 */
   sub_res_count number;
   l_wsor_max_res_seq_num number :=0;
  /* End : -- bug 7371859  */

  BEGIN
  INSERT INTO WIP_OPERATION_RESOURCES
    (WIP_ENTITY_ID, OPERATION_SEQ_NUM,
     RESOURCE_SEQ_NUM, ORGANIZATION_ID,
     REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
     LAST_UPDATED_BY, CREATION_DATE,
     CREATED_BY, LAST_UPDATE_LOGIN,
     RESOURCE_ID, UOM_CODE,
     BASIS_TYPE, USAGE_RATE_OR_AMOUNT,
     ACTIVITY_ID, SCHEDULED_FLAG,
     ASSIGNED_UNITS, AUTOCHARGE_TYPE,
     STANDARD_RATE_FLAG, APPLIED_RESOURCE_UNITS,
     APPLIED_RESOURCE_VALUE, START_DATE,
     COMPLETION_DATE, ATTRIBUTE_CATEGORY,
     ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
     ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6,
     ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9,
     ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
     ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
     SUBSTITUTE_GROUP_NUM, SCHEDULE_SEQ_NUM,REPLACEMENT_GROUP_NUM) --/* Added : ---- bug 7371859
  SELECT X_Wip_Entity_Id, X_Operation_Seq_Num,
         S.RESOURCE_SEQ_NUM, X_Organization_Id,
         X_Repetitive_Schedule_Id, SYSDATE,
         X_Last_Updated_By, SYSDATE,
         X_Created_By, X_Last_Update_Login,
         S.RESOURCE_ID, R.UNIT_OF_MEASURE,
         S.BASIS_TYPE, S.USAGE_RATE_OR_AMOUNT,
         S.ACTIVITY_ID, S.SCHEDULE_FLAG,
         S.ASSIGNED_UNITS, S.AUTOCHARGE_TYPE,
         S.STANDARD_RATE_FLAG, 0,
         0,
         DECODE(X_Start_Date, NULL, SYSDATE, X_Start_Date),
         DECODE(X_Completion_Date, NULL, SYSDATE, X_Completion_Date),
         S.ATTRIBUTE_CATEGORY,
         S.ATTRIBUTE1, S.ATTRIBUTE2, S.ATTRIBUTE3,
         S.ATTRIBUTE4, S.ATTRIBUTE5, S.ATTRIBUTE6,
         S.ATTRIBUTE7, S.ATTRIBUTE8, S.ATTRIBUTE9,
         S.ATTRIBUTE10, S.ATTRIBUTE11, S.ATTRIBUTE12,
         S.ATTRIBUTE13, S.ATTRIBUTE14, S.ATTRIBUTE15,
         S.SUBSTITUTE_GROUP_NUM, S.RESOURCE_SEQ_NUM ,0  --/* Added :  -- bug 7371859
    FROM BOM_STD_OP_RESOURCES S,
         BOM_RESOURCES R
   WHERE S.STANDARD_OPERATION_ID = X_Standard_Operation_Id
     AND R.RESOURCE_ID = S.RESOURCE_ID
     AND NVL(R.DISABLE_DATE, SYSDATE + 1) > SYSDATE;

 /* Added : - bug 7371859   */
     BEGIN
       SELECT count(*)
        INTO  sub_res_count
        FROM  BOM_STD_SUB_OP_RESOURCES BSSOR
        WHERE BSSOR.STANDARD_OPERATION_ID=X_Standard_Operation_Id;
     EXCEPTION
         WHEN no_data_found THEN
             null;
    END ;

    IF   sub_res_count >0 then

        BEGIN
            SELECT nvl(max(resource_seq_num), 10)
            INTO   l_wsor_max_res_seq_num
            FROM   WIP_SUB_OPERATION_RESOURCES WSOR
            WHERE  wip_entity_id = x_wip_entity_id
            AND    OPERATION_SEQ_NUM = X_Operation_Seq_Num;
        EXCEPTION
            WHEN no_data_found THEN
                null;
        END;

           INSERT INTO WIP_SUB_OPERATION_RESOURCES
                    (wip_entity_id,
                    operation_seq_num,
                    resource_seq_num,
                    organization_id,
                    repetitive_schedule_id,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    resource_id,
                    uom_code,
                    basis_type,
                    usage_rate_or_amount,
                    activity_id,
                    scheduled_flag,
                    assigned_units,
		     maximum_assigned_units,
                    autocharge_type,
                    standard_rate_flag,
                    applied_resource_units,
                    applied_resource_value,
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    completion_date,
                    start_date,
                    schedule_seq_num,
                    substitute_group_num,
                    replacement_group_num,
                    setup_id)
            SELECT  X_Wip_Entity_Id,
                    X_Operation_Seq_Num,
                   (rownum + l_wsor_max_res_seq_num),
                    X_Organization_Id,
                    X_Repetitive_Schedule_Id,
                    SYSDATE ,
                    X_Last_Updated_By,
                    SYSDATE,
                    X_Created_By,
                    X_Last_Update_Login,
                    BSSOR.resource_id,
                    BR.unit_of_measure,
                    BSSOR.basis_type,
                    BSSOR.usage_rate_or_amount,
                    BSSOR.activity_id,
                    BSSOR.schedule_flag,
                    BSSOR.assigned_units,
		    BSSOR.assigned_units,
                    BSSOR.autocharge_type,
                    BSSOR.standard_rate_flag,
                    0, --WCOR.applied_resource_units,
                    0, -- WCOR.applied_resource_value,
                    BSSOR.attribute_category,
                    BSSOR.attribute1,
                    BSSOR.attribute2,
                    BSSOR.attribute3,
                    BSSOR.attribute4,
                    BSSOR.attribute5,
                    BSSOR.attribute6,
                    BSSOR.attribute7,
                    BSSOR.attribute8,
                    BSSOR.attribute9,
                    BSSOR.attribute10,
                    BSSOR.attribute11,
                    BSSOR.attribute12,
                    BSSOR.attribute13,
                    BSSOR.attribute14,
                    BSSOR.attribute15,
                    DECODE(X_Start_Date, NULL, SYSDATE, X_Start_Date),
                    DECODE(X_Completion_Date, NULL, SYSDATE, X_Completion_Date),
                    BSSOR.schedule_seq_num  ,
                    BSSOR.substitute_group_num,
                    BSSOR.replacement_group_num,
                    NULL --setup_id
            FROM    BOM_RESOURCES BR,
                    BOM_STD_SUB_OP_RESOURCES BSSOR
            where   bssor.standard_operation_id=X_Standard_Operation_Id
              and   BSSOR.RESOURCE_ID = BR.RESOURCE_ID;

    End IF;
    /* End : -- bug 7371859   */


  END Insert_Resources;

  -- Counts the number of resources per standard operation --
  FUNCTION Num_Standard_Resources(X_Organization_Id             NUMBER,
                                  X_Standard_Operation_Id       NUMBER)
                RETURN NUMBER IS
    P_Num_Resources NUMBER;
  BEGIN
    SELECT COUNT(R.RESOURCE_ID)
      INTO P_Num_Resources
      FROM BOM_STD_OP_RESOURCES S,
           BOM_RESOURCES R
     WHERE S.STANDARD_OPERATION_ID = X_Standard_Operation_Id
       AND R.ORGANIZATION_ID = X_Organization_Id
       AND R.RESOURCE_ID = S.RESOURCE_ID
       AND NVL(R.DISABLE_DATE, SYSDATE + 1) > SYSDATE;
    RETURN P_Num_Resources;
  END Num_Standard_Resources;

/* Note:  This routine is called from two places:
        1) When an Operation is Deleted
        2) When the routing of a job/schedule is updated
 */

  PROCEDURE Check_Requirements(X_Wip_Entity_Id          NUMBER,
                               X_Organization_Id        NUMBER,
                               X_Operation_Seq_Num      NUMBER,
                               X_Repetitive_Schedule_Id NUMBER,
                               X_Entity_Start_Date      DATE) IS
  firstop NUMBER;
  firstdep NUMBER;
  firstdate DATE;
  BEGIN
    firstop := NULL;
    IF X_Repetitive_Schedule_Id IS NULL then
       SELECT nvl(min(operation_seq_num),0)
       INTO   firstop
       FROM   wip_operations
       WHERE  wip_entity_id = X_Wip_Entity_Id
       AND    organization_id = X_Organization_Id;
    ELSE
       SELECT nvl(min(operation_seq_num),0)
       INTO   firstop
       FROM   wip_operations
       WHERE  wip_entity_id = X_Wip_Entity_Id
       AND    organization_id = X_Organization_Id
       AND    repetitive_schedule_id = X_Repetitive_Schedule_Id;
    END IF;

    IF firstop = 0 THEN
       firstop := 1;
       firstdep := NULL;
       firstdate := X_Entity_Start_Date;
    ELSIF X_Repetitive_Schedule_Id IS NULL THEN
       SELECT department_id, first_unit_start_date
       INTO   firstdep, firstdate
       FROM   wip_operations wo
       WHERE  wip_entity_id = X_Wip_Entity_Id
       AND    organization_id = X_Organization_Id
       AND    operation_seq_num = firstop;
    ELSE
       SELECT department_id, first_unit_start_date
       INTO   firstdep, firstdate
       FROM   wip_operations wo
       WHERE  wip_entity_id = X_Wip_Entity_Id
       AND    organization_id = X_Organization_Id
       AND    operation_seq_num = firstop
       AND    repetitive_schedule_id = X_Repetitive_Schedule_Id;
    END IF;

    IF X_Repetitive_Schedule_Id IS NULL THEN

        /* Update the department and date required of requirements to
           those of their new operation */

       UPDATE WIP_REQUIREMENT_OPERATIONS WRO
          SET OPERATION_SEQ_NUM = SIGN(OPERATION_SEQ_NUM) * firstop,
              DEPARTMENT_ID = firstdep,
              DATE_REQUIRED = firstdate
        WHERE ORGANIZATION_ID = X_Organization_Id
          AND WIP_ENTITY_ID = X_Wip_Entity_Id
          AND OPERATION_SEQ_NUM = SIGN(OPERATION_SEQ_NUM) * X_Operation_Seq_Num
          AND NOT EXISTS
              (SELECT 'checking for duplicate requirements'
                 FROM WIP_REQUIREMENT_OPERATIONS
                WHERE ORGANIZATION_ID = X_Organization_Id
                  AND WIP_ENTITY_ID = X_Wip_Entity_Id
                  AND OPERATION_SEQ_NUM = SIGN(WRO.OPERATION_SEQ_NUM) * firstop
                  AND INVENTORY_ITEM_ID = WRO.INVENTORY_ITEM_ID);

        /* If the requirement already existed at this operation, we
           want to increase the quantities instead of adding a new
           requirement.
           We don't want to do this IF the deleted op is Op Seq 1 and
           there are no other ops.
         */

      IF X_Operation_Seq_Num NOT IN (-1, 1) OR firstdep IS NOT NULL THEN
         UPDATE WIP_REQUIREMENT_OPERATIONS WRO
            SET (WIP_SUPPLY_TYPE, REQUIRED_QUANTITY,
                 QUANTITY_ISSUED, QUANTITY_PER_ASSEMBLY) =
                (SELECT LEAST(WRO.WIP_SUPPLY_TYPE, WIP_SUPPLY_TYPE),
                        WRO.REQUIRED_QUANTITY + REQUIRED_QUANTITY,
                        WRO.QUANTITY_ISSUED + QUANTITY_ISSUED,
                        WRO.QUANTITY_PER_ASSEMBLY + QUANTITY_PER_ASSEMBLY
                   FROM WIP_REQUIREMENT_OPERATIONS
                  WHERE ORGANIZATION_ID = X_Organization_Id
                    AND WIP_ENTITY_ID = X_Wip_Entity_Id
                    AND OPERATION_SEQ_NUM = SIGN(WRO.OPERATION_SEQ_NUM) *
                                           X_Operation_Seq_Num
                    AND INVENTORY_ITEM_ID = WRO.INVENTORY_ITEM_ID)
          WHERE ORGANIZATION_ID = X_Organization_Id
            AND WIP_ENTITY_ID = X_Wip_Entity_Id
            AND OPERATION_SEQ_NUM = SIGN(OPERATION_SEQ_NUM) * firstop
            AND EXISTS
                (SELECT 'checking for duplicate requirements'
                   FROM WIP_REQUIREMENT_OPERATIONS
                  WHERE ORGANIZATION_ID = X_Organization_Id
                    AND WIP_ENTITY_ID = X_Wip_Entity_Id
                    AND OPERATION_SEQ_NUM = SIGN(WRO.OPERATION_SEQ_NUM) * X_Operation_Seq_Num
                    AND INVENTORY_ITEM_ID = WRO.INVENTORY_ITEM_ID);

         DELETE FROM WIP_REQUIREMENT_OPERATIONS
          WHERE ORGANIZATION_ID = X_Organization_Id
            AND WIP_ENTITY_ID = X_Wip_Entity_Id
            AND (OPERATION_SEQ_NUM = X_Operation_Seq_Num
                 OR OPERATION_SEQ_NUM = X_Operation_Seq_Num * -1);

      /* If you are deleting an Operation with Op Seq 1,
         the Op Seq will stay 1, but the department and
         Date Required might need to be reset */

      ELSE

         UPDATE WIP_REQUIREMENT_OPERATIONS WRO
            SET OPERATION_SEQ_NUM = SIGN(OPERATION_SEQ_NUM) * firstop,
                DEPARTMENT_ID = firstdep,
                DATE_REQUIRED = firstdate
          WHERE ORGANIZATION_ID = X_Organization_Id
            AND WIP_ENTITY_ID = X_Wip_Entity_Id
            AND OPERATION_SEQ_NUM = SIGN(OPERATION_SEQ_NUM) * X_Operation_Seq_Num;

      END IF;


    /* Repetitive Case */

    ELSE

        /* Update the department and date required of requirements to
           those of their new operation */
       UPDATE WIP_REQUIREMENT_OPERATIONS WRO
          SET OPERATION_SEQ_NUM = SIGN(OPERATION_SEQ_NUM) * firstop,
              DEPARTMENT_ID = firstdep,
              DATE_REQUIRED = firstdate
        WHERE ORGANIZATION_ID = X_Organization_Id
          AND WIP_ENTITY_ID = X_Wip_Entity_Id
          AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
          AND OPERATION_SEQ_NUM = SIGN(OPERATION_SEQ_NUM) * X_Operation_Seq_Num
          AND NOT EXISTS
              (SELECT 'checking for duplicate requirements'
                 FROM WIP_REQUIREMENT_OPERATIONS
                WHERE ORGANIZATION_ID = X_Organization_Id
                  AND WIP_ENTITY_ID = X_Wip_Entity_Id
                  AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
                  AND OPERATION_SEQ_NUM = SIGN(WRO.OPERATION_SEQ_NUM) * firstop
                  AND INVENTORY_ITEM_ID = WRO.INVENTORY_ITEM_ID);

        /* If the requirement already existed at this operation, we
           want to increase the quantities instead of adding a new
           requirement.
           We don't want to do this IF the deleted op is Op Seq 1 and
           there are no other ops.
         */

      IF X_Operation_Seq_Num NOT IN (-1, 1) OR firstdep IS NOT NULL THEN
         UPDATE WIP_REQUIREMENT_OPERATIONS WRO
            SET (WIP_SUPPLY_TYPE, REQUIRED_QUANTITY,
                 QUANTITY_ISSUED, QUANTITY_PER_ASSEMBLY) =
                (SELECT LEAST(WRO.WIP_SUPPLY_TYPE, WIP_SUPPLY_TYPE),
                        WRO.REQUIRED_QUANTITY + REQUIRED_QUANTITY,
                        WRO.QUANTITY_ISSUED + QUANTITY_ISSUED,
                        WRO.QUANTITY_PER_ASSEMBLY + QUANTITY_PER_ASSEMBLY
                   FROM WIP_REQUIREMENT_OPERATIONS
                  WHERE ORGANIZATION_ID = X_Organization_Id
                    AND WIP_ENTITY_ID = X_Wip_Entity_Id
                    AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
                    AND OPERATION_SEQ_NUM = SIGN(WRO.OPERATION_SEQ_NUM) *
                                            X_Operation_Seq_Num
                    AND INVENTORY_ITEM_ID = WRO.INVENTORY_ITEM_ID)
          WHERE ORGANIZATION_ID = X_Organization_Id
            AND WIP_ENTITY_ID = X_Wip_Entity_Id
            AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
            AND OPERATION_SEQ_NUM = SIGN(OPERATION_SEQ_NUM) * firstop
            AND EXISTS
                (SELECT 'checking for duplicate requirements'
                   FROM WIP_REQUIREMENT_OPERATIONS
                  WHERE ORGANIZATION_ID = X_Organization_Id
                    AND WIP_ENTITY_ID = X_Wip_Entity_Id
                    AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
                    AND OPERATION_SEQ_NUM = SIGN(WRO.OPERATION_SEQ_NUM) * X_Operation_Seq_Num
                    AND INVENTORY_ITEM_ID = WRO.INVENTORY_ITEM_ID);

         DELETE FROM WIP_REQUIREMENT_OPERATIONS
          WHERE ORGANIZATION_ID = X_Organization_Id
            AND WIP_ENTITY_ID = X_Wip_Entity_Id
            AND (OPERATION_SEQ_NUM = X_Operation_Seq_Num
                 OR OPERATION_SEQ_NUM = X_Operation_Seq_Num * -1)
            AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id;

      /* If you are deleting an Operation with Op Seq 1,
         the Op Seq will stay 1, but the department and
         Date Required might need to be reset */

      ELSE

         UPDATE WIP_REQUIREMENT_OPERATIONS WRO
            SET OPERATION_SEQ_NUM = SIGN(OPERATION_SEQ_NUM) * firstop,
                DEPARTMENT_ID = firstdep,
                DATE_REQUIRED = firstdate
          WHERE ORGANIZATION_ID = X_Organization_Id
            AND WIP_ENTITY_ID = X_Wip_Entity_Id
            AND OPERATION_SEQ_NUM = SIGN(OPERATION_SEQ_NUM) * X_Operation_Seq_Num
            AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id;

      END IF;

    END IF;

  END Check_Requirements;

  FUNCTION Num_Assembly_Pull(X_Wip_Entity_Id            NUMBER,
                         X_Organization_Id              NUMBER,
                         X_Operation_Seq_Num            NUMBER,
                         X_Repetitive_Schedule_Id       NUMBER)
                return NUMBER is
    opseq NUMBER;
  BEGIN
    IF X_Repetitive_Schedule_Id IS NULL THEN
        SELECT count(*)
        INTO   opseq
        FROM   WIP_REQUIREMENT_OPERATIONS
        WHERE  WIP_ENTITY_ID = X_Wip_Entity_Id
        AND    ORGANIZATION_ID = X_Organization_Id
        AND    OPERATION_SEQ_NUM = X_Operation_Seq_Num
        AND    WIP_SUPPLY_TYPE = 2;
    ELSE
        SELECT count(*)
        INTO   opseq
        FROM   WIP_REQUIREMENT_OPERATIONS
        WHERE  WIP_ENTITY_ID = X_Wip_Entity_Id
        AND    REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
        AND    ORGANIZATION_ID = X_Organization_Id
        AND    OPERATION_SEQ_NUM = X_Operation_Seq_Num
        AND    WIP_SUPPLY_TYPE = 2;
    END IF;
    return opseq;
  END Num_Assembly_Pull;

  FUNCTION Num_Resources(X_Wip_Entity_Id                NUMBER,
                             X_Organization_Id          NUMBER,
                             X_Operation_Seq_Num        NUMBER,
                             X_Repetitive_Schedule_Id   NUMBER)
                return NUMBER is
  resct NUMBER;
  BEGIN
        IF X_Repetitive_Schedule_Id is NULL THEN
            SELECT count(resource_id)
            INTO   resct
            FROM   wip_operation_resources
            WHERE  wip_entity_id = X_Wip_Entity_Id
            AND    organization_id = X_Organization_Id
            AND    operation_seq_num = X_Operation_Seq_Num;
        ELSE
            SELECT count(resource_id)
            INTO   resct
            FROM   wip_operation_resources
            WHERE  wip_entity_id = X_Wip_Entity_Id
            AND    organization_id = X_Organization_Id
            AND    operation_seq_num = X_Operation_Seq_Num
            AND    repetitive_schedule_id = X_Repetitive_Schedule_Id;
        END IF;
  return resct;
  END Num_Resources;

  PROCEDURE Set_Operation_Dates(X_Wip_Entity_Id         NUMBER,
                        X_Organization_Id               NUMBER,
                        X_Operation_Seq_Num             NUMBER,
                        X_Repetitive_Schedule_Id        NUMBER,
                        X_First_Unit_Start_Date         DATE,
                        X_Last_Unit_Completion_Date     DATE,
                        X_Resource_Start_Date           DATE,
                        X_Resource_Completion_Date      DATE) IS
  BEGIN
     IF X_Repetitive_Schedule_Id is NULL THEN
        UPDATE wip_operations
        SET    first_unit_start_date = DECODE(SIGN(X_First_Unit_Start_Date-
                                                   X_Resource_Start_Date),
                                              -1, X_First_Unit_Start_Date,
                                              X_Resource_Start_Date),
               last_unit_completion_date = DECODE(SIGN(X_Last_Unit_Completion_Date-
                                                       X_Resource_Completion_Date),
                                                  -1, X_Resource_Completion_Date,
                                                  X_Last_Unit_Completion_Date)
        WHERE
               wip_entity_id = X_Wip_Entity_Id
        AND    organization_id = X_Organization_Id
        AND    operation_seq_num = X_Operation_Seq_Num;
     ELSE
        UPDATE wip_operations
        SET    first_unit_start_date = DECODE(SIGN(X_First_Unit_Start_Date-
                                                   X_Resource_Start_Date),
                                              -1, X_First_Unit_Start_Date,
                                              X_Resource_Start_Date),
               last_unit_completion_date = DECODE(SIGN(X_Last_Unit_Completion_Date-
                                                       X_Resource_Completion_Date),
                                                  -1, X_Resource_Completion_Date,
                                                  X_Last_Unit_Completion_Date)
        WHERE
               wip_entity_id = X_Wip_Entity_Id
        AND    organization_id = X_Organization_Id
        AND    operation_seq_num = X_Operation_Seq_Num
        AND    repetitive_schedule_id = X_Repetitive_Schedule_Id;
     END IF;
  END Set_Operation_Dates;

  PROCEDURE Set_Entity_Dates(X_Wip_Entity_Id            NUMBER,
                        X_Organization_Id               NUMBER,
                        X_Repetitive_Schedule_Id        NUMBER,
                        X_First_Unit_Start_Date         DATE,
                        X_Last_Unit_Completion_Date     DATE) IS
  BEGIN
     IF X_Repetitive_Schedule_Id is NULL THEN
        UPDATE wip_discrete_jobs
        SET    scheduled_start_date = X_First_Unit_Start_Date,
               scheduled_completion_date = X_Last_Unit_Completion_Date
        WHERE
               wip_entity_id = X_Wip_Entity_Id
        AND    organization_id = X_Organization_Id;
     ELSE
        UPDATE wip_repetitive_schedules
        SET    first_unit_start_date = X_First_Unit_Start_Date,
               last_unit_completion_date = X_Last_Unit_Completion_Date
        WHERE  wip_entity_id = X_Wip_Entity_Id
        AND    organization_id = X_Organization_Id
        AND    repetitive_schedule_id = X_Repetitive_Schedule_Id;
     END IF;
  END Set_Entity_Dates;

  -- Assumes that there were previously no operations. --
  PROCEDURE Update_Operationless_Reqs(X_Wip_Entity_Id           NUMBER,
                                      X_Organization_Id         NUMBER,
                                      X_Operation_Seq_Num       NUMBER,
                                      X_Repetitive_Schedule_Id  NUMBER,
                                      X_Department_Id           NUMBER,
                                      X_First_Unit_Start_Date   DATE) IS
    l_msg_data VARCHAR2(240);
    l_return_status VARCHAR2(1);
    l_serialization_start_op NUMBER;
  BEGIN

  --just ignore the return status.
  --this is status quo for the form (WIPOPMDF) apparently since only db errors will cause exceptions in these
  --procedures.
  wip_picking_pvt.update_allocation_op_seqs(p_wip_entity_id => X_Wip_Entity_Id,
                                            p_operation_seq_num => X_Operation_Seq_Num,
                                            p_repetitive_schedule_id => X_Repetitive_Schedule_Id,
                                            x_msg_data => l_msg_data,
                                            x_return_status => l_return_status);

  IF X_Repetitive_Schedule_Id IS NULL THEN
   update wip_discrete_jobs
      set serialization_start_op = decode(serialization_start_op, 1, X_Operation_Seq_Num, null)
    where wip_entity_id = X_Wip_Entity_Id;

   UPDATE WIP_REQUIREMENT_OPERATIONS
      SET OPERATION_SEQ_NUM = SIGN(OPERATION_SEQ_NUM) *
                              X_Operation_Seq_Num,
          DEPARTMENT_ID = X_Department_Id,
          DATE_REQUIRED = X_First_Unit_Start_Date
    WHERE ORGANIZATION_ID = X_Organization_Id
      AND WIP_ENTITY_ID = X_Wip_Entity_Id
      AND (OPERATION_SEQ_NUM = 1
           OR OPERATION_SEQ_NUM = -1);
  ELSE
   UPDATE WIP_REQUIREMENT_OPERATIONS
      SET OPERATION_SEQ_NUM = SIGN(OPERATION_SEQ_NUM) *
                              X_Operation_Seq_Num,
          DEPARTMENT_ID = X_Department_Id,
          DATE_REQUIRED = X_First_Unit_Start_Date
    WHERE ORGANIZATION_ID = X_Organization_Id
      AND WIP_ENTITY_ID = X_Wip_Entity_Id
      AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
      AND (OPERATION_SEQ_NUM = 1
           OR OPERATION_SEQ_NUM = -1);
  END IF;
  END Update_Operationless_Reqs;

  PROCEDURE Update_Reqs(X_Wip_Entity_Id                 NUMBER,
                        X_Organization_Id               NUMBER,
                        X_Operation_Seq_Num             NUMBER,
                        X_Repetitive_Schedule_Id        NUMBER,
                        X_Department_Id                 NUMBER,
                        X_Start_Date                    DATE) IS
  BEGIN
  	/* Added nvl(X_department_id) for bug 5979782 (base bug 5657251)*/
    IF X_Repetitive_Schedule_Id IS NULL THEN
      UPDATE WIP_REQUIREMENT_OPERATIONS
         SET DEPARTMENT_ID = nvl(X_Department_Id,department_id),
	     --Start : Fix for bug #5177994/5094448 --
             DATE_REQUIRED = trunc(NVL(X_Start_Date,DATE_REQUIRED)),
             MPS_DATE_REQUIRED = trunc(NVL(X_Start_Date,MPS_DATE_REQUIRED))
--             DATE_REQUIRED = X_Start_Date,
--             MPS_DATE_REQUIRED = X_Start_Date
	     --End : Fix for bug #5177994/5094448 --
       WHERE ORGANIZATION_ID = X_Organization_Id
         AND WIP_ENTITY_ID = X_Wip_Entity_Id
         AND (OPERATION_SEQ_NUM = X_Operation_Seq_Num
              OR OPERATION_SEQ_NUM = -1 * X_Operation_Seq_Num);
    ELSE
      UPDATE WIP_REQUIREMENT_OPERATIONS
         SET DEPARTMENT_ID = X_Department_Id,
	     --Start : Fix for bug #5177994/5094448 --
             DATE_REQUIRED = trunc(NVL(X_Start_Date,DATE_REQUIRED)),
             MPS_DATE_REQUIRED = trunc(NVL(X_Start_Date,MPS_DATE_REQUIRED))
--             DATE_REQUIRED = X_Start_Date,
--             MPS_DATE_REQUIRED = X_Start_Date
	     --End : Fix for bug #5177994/5094448 --
       WHERE ORGANIZATION_ID = X_Organization_Id
         AND WIP_ENTITY_ID = X_Wip_Entity_Id
         AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
         AND (OPERATION_SEQ_NUM = X_Operation_Seq_Num
              OR OPERATION_SEQ_NUM = -1 * X_Operation_Seq_Num);
    END IF;
  END Update_Reqs;

  PROCEDURE Get_Prev_Op_Dates(X_Wip_Entity_Id                   NUMBER,
                              X_Organization_Id                 NUMBER,
                              X_Prev_Operation_Seq_Num          NUMBER,
                              X_Repetitive_Schedule_Id          NUMBER,
                              X_First_Unit_Start_Date           OUT NOCOPY DATE,
                              X_Last_Unit_Start_Date            OUT NOCOPY DATE,
                              X_First_Unit_Completion_Date      OUT NOCOPY DATE,
                              X_Last_Unit_Completion_Date       OUT NOCOPY DATE) IS
  BEGIN
     IF X_Repetitive_Schedule_Id IS NULL THEN
        SELECT FIRST_UNIT_COMPLETION_DATE,
               LAST_UNIT_COMPLETION_DATE,
               FIRST_UNIT_COMPLETION_DATE,
               LAST_UNIT_COMPLETION_DATE
          INTO X_First_Unit_Start_Date,
               X_Last_Unit_Start_Date,
               X_First_Unit_Completion_Date,
               X_Last_Unit_Completion_Date
          FROM WIP_OPERATIONS
          WHERE ORGANIZATION_ID = X_Organization_Id
            AND WIP_ENTITY_ID = X_Wip_Entity_Id
            AND OPERATION_SEQ_NUM = X_Prev_Operation_Seq_Num;
     ELSE
        SELECT FIRST_UNIT_COMPLETION_DATE,
               LAST_UNIT_COMPLETION_DATE,
               FIRST_UNIT_COMPLETION_DATE,
               LAST_UNIT_COMPLETION_DATE
          INTO X_First_Unit_Start_Date,
               X_Last_Unit_Start_Date,
               X_First_Unit_Completion_Date,
               X_Last_Unit_Completion_Date
          FROM WIP_OPERATIONS
          WHERE ORGANIZATION_ID = X_Organization_Id
            AND WIP_ENTITY_ID = X_Wip_Entity_Id
            AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
            AND OPERATION_SEQ_NUM = X_Prev_Operation_Seq_Num;
      END IF;
  END Get_Prev_Op_Dates;

PROCEDURE Update_Res_Op_Seq(X_Wip_Entity_Id           NUMBER,
                              X_Organization_Id         NUMBER,
                              X_Old_Operation_Seq_Num   NUMBER,
                              X_New_Operation_Seq_Num   NUMBER,
                              X_Repetitive_Schedule_Id  NUMBER) IS
  BEGIN
    IF X_Repetitive_Schedule_Id IS NULL THEN
      UPDATE WIP_OPERATION_RESOURCES
         SET OPERATION_SEQ_NUM = X_New_Operation_Seq_num
       WHERE ORGANIZATION_ID   = X_Organization_Id
         AND WIP_ENTITY_ID     = X_Wip_Entity_Id
         AND OPERATION_SEQ_NUM = X_Old_Operation_Seq_Num;
    ELSE
      UPDATE WIP_OPERATION_RESOURCES
         SET OPERATION_SEQ_NUM = X_New_Operation_Seq_num
       WHERE ORGANIZATION_ID   = X_Organization_Id
         AND WIP_ENTITY_ID     = X_Wip_Entity_Id
         AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
         AND OPERATION_SEQ_NUM = X_Old_Operation_Seq_Num;
    END IF;
  END Update_Res_Op_Seq;

  FUNCTION Other_Active_Schedules(X_Wip_Entity_Id  NUMBER,
                                  X_Org_Id         NUMBER,
                                  X_Line_Id        NUMBER) RETURN VARCHAR IS
    X_Count NUMBER;
    cursor get_schedules is
        SELECT COUNT(*)
          FROM WIP_REPETITIVE_SCHEDULES
         WHERE WIP_ENTITY_ID = X_Wip_Entity_Id
           AND ORGANIZATION_ID = X_Org_Id
           AND LINE_ID = X_Line_Id
           AND STATUS_TYPE in (3,4,6);
  BEGIN
    open get_schedules;
    fetch get_schedules into X_Count;
    close get_schedules;
    IF (X_Count > 1) THEN
      RETURN 'Y';
    ELSIF (X_Count = 1) THEN
      RETURN 'N';
    ELSE
      -- This should never happen
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Other_Active_Schedules;

  PROCEDURE rollback_database IS
  BEGIN
    ROLLBACK;
  END rollback_database;

END WIP_OPERATIONS_UTILITIES;

/
