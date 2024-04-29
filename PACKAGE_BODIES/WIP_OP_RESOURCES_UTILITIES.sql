--------------------------------------------------------
--  DDL for Package Body WIP_OP_RESOURCES_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_OP_RESOURCES_UTILITIES" AS
/* $Header: wiporutb.pls 120.2 2005/11/30 01:17:35 panagara noship $ */

  PROCEDURE Check_Unique(X_Wip_Entity_Id                NUMBER,
                        X_Organization_Id               NUMBER,
                        X_Operation_Seq_Num             NUMBER,
                        X_Resource_Seq_Num              NUMBER,
                        X_Repetitive_Schedule_Id        NUMBER) IS
    res_count NUMBER := 0;
    subres_count NUMBER := 0;
    cursor discrete_check is
          SELECT  count(*)
           FROM   WIP_OPERATION_RESOURCES
           WHERE  ORGANIZATION_ID = X_Organization_Id
           AND    WIP_ENTITY_ID = X_Wip_Entity_Id
           AND    OPERATION_SEQ_NUM = X_Operation_Seq_Num
           AND    RESOURCE_SEQ_NUM = X_Resource_Seq_Num;
    cursor sub_discrete_check is
          SELECT  count(*)
           FROM   WIP_SUB_OPERATION_RESOURCES
           WHERE  ORGANIZATION_ID = X_Organization_Id
           AND    WIP_ENTITY_ID = X_Wip_Entity_Id
           AND    OPERATION_SEQ_NUM = X_Operation_Seq_Num
           AND    RESOURCE_SEQ_NUM = X_Resource_Seq_Num;
    cursor repetitive_check is
          SELECT  count(*)
           FROM   WIP_OPERATION_RESOURCES
           WHERE  ORGANIZATION_ID = X_Organization_Id
           AND    WIP_ENTITY_ID = X_Wip_Entity_Id
           AND    OPERATION_SEQ_NUM = X_Operation_Seq_Num
           AND    RESOURCE_SEQ_NUM = X_Resource_Seq_Num
           AND    REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id;
  BEGIN
     IF X_Repetitive_Schedule_Id IS NULL then
        open discrete_check;
        fetch discrete_check into res_count;
        close discrete_check;
        open sub_discrete_check;
        fetch sub_discrete_check into subres_count;
        close sub_discrete_check;
     ELSE
        open repetitive_check;
        fetch repetitive_check into res_count;
        close repetitive_check;
     END IF;

     IF (res_count <> 0) OR (subres_count <> 0) THEN
        FND_MESSAGE.set_name('WIP', 'WIP_ALREADY_EXISTS');
        FND_MESSAGE.set_token('ENTITY1', 'resource sequence number-cap', TRUE);
        FND_MESSAGE.raise_error;
        APP_EXCEPTION.raise_exception;
     END IF;
  END Check_Unique;

  PROCEDURE Check_One_Pomove(X_Wip_Entity_Id                NUMBER,
                             X_Organization_Id               NUMBER,
                             X_Operation_Seq_Num             NUMBER,
                             X_Resource_Seq_Num              NUMBER,
                             X_Repetitive_Schedule_Id        NUMBER) IS
    res_count NUMBER := 0;
    cursor discrete_check is
            SELECT count(*)
              FROM WIP_OPERATION_RESOURCES
             WHERE ORGANIZATION_ID = X_Organization_Id
               AND WIP_ENTITY_ID = X_Wip_Entity_Id
               AND OPERATION_SEQ_NUM = X_Operation_Seq_Num
               AND RESOURCE_SEQ_NUM <> X_Resource_Seq_Num
               AND AUTOCHARGE_TYPE = 4;
    cursor repetitive_check is
            SELECT count(*)
              FROM WIP_OPERATION_RESOURCES
             WHERE ORGANIZATION_ID = X_Organization_Id
               AND WIP_ENTITY_ID = X_Wip_Entity_Id
               AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
               AND OPERATION_SEQ_NUM = X_Operation_Seq_Num
               AND RESOURCE_SEQ_NUM <> X_Resource_Seq_Num
               AND AUTOCHARGE_TYPE = 4;
  BEGIN
     IF X_Repetitive_Schedule_Id IS NULL then
        open discrete_check;
        fetch discrete_check into res_count;
        close discrete_check;
     ELSE
        open repetitive_check;
        fetch repetitive_check into res_count;
        close repetitive_check;
     END IF;
     IF (res_count <> 0) THEN
        FND_MESSAGE.SET_NAME('WIP','WIP_ONE_POMOVE');
        FND_MESSAGE.raise_error;
        APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
  END Check_One_Pomove;

  PROCEDURE Check_One_Prior(X_Wip_Entity_Id                NUMBER,
                            X_Organization_Id               NUMBER,
                            X_Operation_Seq_Num             NUMBER,
                            X_Resource_Seq_Num              NUMBER,
                            X_Repetitive_Schedule_Id        NUMBER) IS
    res_count NUMBER := 0;
    cursor discrete_check is
            SELECT count(*)
              FROM WIP_OPERATION_RESOURCES
             WHERE ORGANIZATION_ID = X_Organization_Id
               AND WIP_ENTITY_ID = X_Wip_Entity_Id
               AND OPERATION_SEQ_NUM = X_Operation_Seq_Num
               AND RESOURCE_SEQ_NUM <> X_Resource_Seq_Num
               AND SCHEDULED_FLAG = 3;
    cursor repetitive_check is
            SELECT count(*)
              FROM WIP_OPERATION_RESOURCES
             WHERE ORGANIZATION_ID = X_Organization_Id
               AND WIP_ENTITY_ID = X_Wip_Entity_Id
               AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
               AND OPERATION_SEQ_NUM = X_Operation_Seq_Num
               AND RESOURCE_SEQ_NUM <> X_Resource_Seq_Num
               AND SCHEDULED_FLAG = 3;
  BEGIN
     IF X_Repetitive_Schedule_Id IS NULL then
        open discrete_check;
        fetch discrete_check into res_count;
        close discrete_check;
     ELSE
        open repetitive_check;
        fetch repetitive_check into res_count;
        close repetitive_check;
     END IF;
     IF (res_count <> 0) THEN
        FND_MESSAGE.SET_NAME('WIP','WIP_ONE_SCHEDULED_PRIOR');
        FND_MESSAGE.raise_error;
        APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
  END Check_One_Prior;

  PROCEDURE Check_One_Next(X_Wip_Entity_Id                NUMBER,
                           X_Organization_Id               NUMBER,
                           X_Operation_Seq_Num             NUMBER,
                           X_Resource_Seq_Num              NUMBER,
                           X_Repetitive_Schedule_Id        NUMBER) IS
    res_count NUMBER := 0;
    cursor discrete_check is
            SELECT count(*)
              FROM WIP_OPERATION_RESOURCES
             WHERE ORGANIZATION_ID = X_Organization_Id
               AND WIP_ENTITY_ID = X_Wip_Entity_Id
               AND OPERATION_SEQ_NUM = X_Operation_Seq_Num
               AND RESOURCE_SEQ_NUM <> X_Resource_Seq_Num
               AND SCHEDULED_FLAG = 4;
    cursor repetitive_check is
            SELECT count(*)
              FROM WIP_OPERATION_RESOURCES
             WHERE ORGANIZATION_ID = X_Organization_Id
               AND WIP_ENTITY_ID = X_Wip_Entity_Id
               AND REPETITIVE_SCHEDULE_ID = X_Repetitive_Schedule_Id
               AND OPERATION_SEQ_NUM = X_Operation_Seq_Num
               AND RESOURCE_SEQ_NUM <> X_Resource_Seq_Num
               AND SCHEDULED_FLAG = 4;
  BEGIN
     IF X_Repetitive_Schedule_Id IS NULL then
        open discrete_check;
        fetch discrete_check into res_count;
        close discrete_check;
     ELSE
        open repetitive_check;
        fetch repetitive_check into res_count;
        close repetitive_check;
     END IF;
     IF (res_count <> 0) THEN
        FND_MESSAGE.SET_NAME('WIP','WIP_ONE_SCHEDULED_NEXT');
        FND_MESSAGE.raise_error;
        APP_EXCEPTION.raise_exception;
     END IF;
  END Check_One_Next;

  FUNCTION Pending_Transactions(
           X_Wip_Entity_Id                 NUMBER,
           X_Organization_Id               NUMBER,
           X_Operation_Seq_Num             NUMBER,
           X_Resource_Seq_Num              NUMBER,
           X_Line_Id        NUMBER) RETURN BOOLEAN IS
    X_count NUMBER := 0;
    tct BOOLEAN;
    cursor discrete_wcti_check is
        select 1
        from wip_cost_txn_interface
        where organization_id = X_Organization_Id
        and wip_entity_id = X_Wip_Entity_Id
        and operation_seq_num = X_Operation_Seq_Num
        and resource_seq_num = X_Resource_Seq_Num;

    cursor discrete_wt_check is
        select 1
        from wip_transactions
        where organization_id = X_Organization_Id
        and wip_entity_id = X_Wip_Entity_Id
        and operation_seq_num = X_Operation_Seq_Num
        and resource_seq_num = X_Resource_Seq_Num;

    cursor repetitive_wcti_check is
        select 1
        from wip_cost_txn_interface
        where organization_id = X_Organization_Id
        and wip_entity_id = X_Wip_Entity_Id
        and operation_seq_num = X_Operation_Seq_Num
        and resource_seq_num = X_Resource_Seq_Num
        and line_id = X_Line_Id;

    cursor repetitive_wt_check is
        select 1
        from wip_transactions
        where organization_id = X_Organization_Id
        and wip_entity_id = X_Wip_Entity_Id
        and operation_seq_num = X_Operation_Seq_Num
        and resource_seq_num = X_Resource_Seq_Num
        and line_id = X_Line_Id;

  BEGIN
     IF X_Line_Id IS NULL then
        open discrete_wcti_check;
        open discrete_wt_check;
        fetch discrete_wcti_check into X_count;
        fetch discrete_wt_check into X_count;
        tct := (NOT (discrete_wcti_check%NOTFOUND
                AND discrete_wt_check%NOTFOUND));
        close discrete_wcti_check;
        close discrete_wt_check;
     ELSE
        open repetitive_wcti_check;
        open repetitive_wt_check;
        fetch repetitive_wcti_check into X_count;
        fetch repetitive_wt_check into X_count;
        tct := (NOT (repetitive_wcti_check%NOTFOUND
                AND repetitive_wt_check%NOTFOUND));
        close repetitive_wcti_check;
        close repetitive_wt_check;
     END IF;
     return tct;
  END Pending_Transactions;

  PROCEDURE Set_Resource_Dates(X_Wip_Entity_Id          NUMBER,
                        X_Organization_Id               NUMBER,
                        X_Operation_Seq_Num             NUMBER,
                        X_Resource_Seq_Num              NUMBER,
                        X_Repetitive_Schedule_Id        NUMBER,
                        X_First_Unit_Start_Date         DATE,
                        X_Last_Unit_Completion_Date     DATE) IS
  BEGIN
     IF X_Repetitive_Schedule_Id is NULL THEN
        UPDATE wip_operation_resources
        SET    start_date = X_First_Unit_Start_Date,
               completion_date = X_Last_Unit_Completion_Date
        WHERE  wip_entity_id = X_Wip_Entity_Id
        AND    organization_id = X_Organization_Id
        AND    operation_seq_num = X_Operation_Seq_Num
        AND    resource_seq_num = X_Resource_Seq_Num;
     ELSE
        UPDATE wip_operation_resources
        SET    start_date = X_First_Unit_Start_Date,
               completion_date = X_Last_Unit_Completion_Date
        WHERE  wip_entity_id = X_Wip_Entity_Id
        AND    organization_id = X_Organization_Id
        AND    operation_seq_num = X_Operation_Seq_Num
        AND    resource_seq_num = X_Resource_Seq_Num
        AND    repetitive_schedule_id = X_Repetitive_Schedule_Id;
     END IF;
  END Set_Resource_Dates;

  FUNCTION Get_Uom_Class(X_Unit VARCHAR2)
                RETURN VARCHAR2 IS
    dummy VARCHAR2(20);
    cursor get_class is
     SELECT UOM_CLASS
       FROM MTL_UOM_CONVERSIONS CON
      WHERE CON.UOM_CODE = X_Unit
        AND CON.INVENTORY_ITEM_ID = 0;
  BEGIN
    open get_class;
    fetch get_class into dummy;
    close get_class;
    return dummy;
  END Get_Uom_Class;


 Procedure delete_orphaned_alternates (p_wip_entity_id in number,
                                       p_schedule_id in number,
                                       x_return_status out nocopy varchar2) is
  begin
        x_return_status := fnd_api.g_ret_sts_success;

       delete from wip_sub_operation_resources wsor
         where wip_entity_id = p_wip_entity_id
              and nvl(repetitive_schedule_id, -1) = nvl(p_schedule_id, -1)
              and not exists (select 1
                                from wip_operation_resources wor
                               where wor.wip_entity_id = p_wip_entity_id
                                 and nvl(wor.repetitive_schedule_id, -1) = nvl(p_schedule_id, -1)
                                 and wor.operation_seq_num = wsor.operation_seq_num
                                 and wor.substitute_group_num = wsor.substitute_group_num);
  exception
      when others then
            x_return_status := fnd_api.g_ret_sts_unexp_error;
  end delete_orphaned_alternates;

PROCEDURE Validate_Sub_Groups (p_wip_entity_id NUMBER,
                               p_schedule_id NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_data OUT NOCOPY VARCHAR2,
                               x_operation_seq_num OUT NOCOPY NUMBER) IS
    cursor operations (p_wip_entity_id NUMBER, p_schedule_id NUMBER) is
        select operation_seq_num
          from wip_operations
        where wip_entity_id = p_wip_entity_id
             and nvl(repetitive_schedule_id,-1) = nvl(p_schedule_id, -1);

   cursor op_resources (p_wip_entity_id NUMBER,
                        p_schedule_id NUMBER,
                        p_op_seq_num NUMBER) is
        select * from (select resource_seq_num,
                     schedule_seq_num,
                     substitute_group_num,
                     scheduled_flag,
                     parent_resource_seq /* added for bug 4747951 */
          from wip_operation_resources
       where wip_entity_id = p_wip_entity_id
            and nvl(repetitive_schedule_id,-1) = nvl(p_schedule_id,-1)
            and operation_seq_num = p_op_seq_num
         union
         select resource_seq_num,
                     schedule_seq_num,
                     substitute_group_num,
                     scheduled_flag,
                     null parent_resource_seq  /* added for bug 4747951 */
          from wip_sub_operation_resources
       where wip_entity_id = p_wip_entity_id
            and nvl(repetitive_schedule_id,-1) = nvl(p_schedule_id,-1)
            and operation_seq_num = p_op_seq_num
        )
        order by nvl(schedule_seq_num, resource_seq_num);

   last_res_seq NUMBER := 0;
   last_sub_group NUMBER := 0;
   last_sched_seq NUMBER := 0;
   last_scheduled_flag NUMBER := 0;
   last_parent_resource_seq NUMBER := null; /* for bug 4747951 */
   error_exists BOOLEAN := false;
BEGIN
    for cur_op in operations (p_wip_entity_id, p_schedule_id) loop
        last_res_seq := 0;
        last_sub_group := 0;
        last_sched_seq := 0;
        last_scheduled_flag := 0;
        last_parent_resource_seq := null;

        for cur_opres in op_resources (p_wip_entity_id,
                                       p_schedule_id,
                                       cur_op.operation_seq_num) loop
             if (last_res_seq <> 0) then
                 /* For bug 4747951. Skip below validation for setup resources */
                  if ((nvl(last_sched_seq,last_res_seq) = nvl(cur_opres.schedule_seq_num, cur_opres.resource_seq_num)) and
                      (last_parent_resource_seq is null and cur_opres.parent_resource_seq is null)) then
                     if (nvl(last_sub_group,-1) <> nvl(cur_opres.substitute_group_num,-1)) then
                            FND_MESSAGE.SET_NAME('WIP', 'SIM_RES_SAME_SUB_GROUP');
                            FND_MESSAGE.set_token(  token => 'OP_SEQ',
                              value=> to_char(cur_op.operation_seq_num),
                              translate => FALSE);
                            FND_MESSAGE.set_token(  token => 'RES_SEQ_1',
                              value=> to_char(last_res_seq),
                              translate => FALSE);
                            FND_MESSAGE.set_token(  token => 'RES_SEQ_2',
                              value=> to_char(cur_opres.resource_seq_num),
                              translate => FALSE);
                            error_exists := true;
                     -- simultaneous resources: if one resource is Prior/Next, the others must also have the same
                     -- scheduling flag
                     elsif (last_scheduled_flag <> cur_opres.scheduled_flag) then
                        if ((((cur_opres.scheduled_flag = wip_constants.sched_prior) OR (cur_opres.scheduled_flag = wip_constants.sched_next)) AND (last_scheduled_flag <> wip_constants.sched_no))
                            OR (((last_scheduled_flag = wip_constants.sched_prior) OR (last_scheduled_flag = wip_constants.sched_next)) AND (cur_opres.scheduled_flag <> wip_constants.sched_no))) then
                                  FND_MESSAGE.SET_NAME('WIP', 'SIM_RES_SAME_PRIOR_NEXT');
                               FND_MESSAGE.set_token(  token => 'OP_SEQ',
                              value=> to_char(cur_op.operation_seq_num),
                              translate => FALSE);
                               FND_MESSAGE.set_token(  token => 'RES_SEQ_1',
                              value=> to_char(last_res_seq),
                              translate => FALSE);
                               FND_MESSAGE.set_token(  token => 'RES_SEQ_2',
                              value=> to_char(cur_opres.resource_seq_num),
                              translate => FALSE);
                               error_exists := true;
                         end if;
                     end if;
                   end if;
              end if;

              if (error_exists = true) then
                   x_return_status := fnd_api.g_ret_sts_error;
                   x_msg_data := fnd_message.get;
                   x_operation_seq_num := cur_op.operation_seq_num;
                   return;
              end if;

              last_res_seq := cur_opres.resource_seq_num;
              last_sub_group := cur_opres.substitute_group_num;
              last_sched_seq := cur_opres.schedule_seq_num;
              last_scheduled_flag := cur_opres.scheduled_flag;
              last_parent_resource_seq := cur_opres.parent_resource_seq;
        end loop;
    end loop;

    x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
end validate_sub_groups;

Procedure Update_Resource_Instances(p_wip_entity_id NUMBER,
                                    p_org_id NUMBER) is
  cursor operation_rsc (p_wip_entity_id NUMBER, p_org_id NUMBER) is
        select operation_seq_num,
               resource_seq_num,
               start_date,
               completion_date
          from wip_operation_resources
        where wip_entity_id = p_wip_entity_id
             and organization_id = p_org_id;

Begin
  for cur_rsc in operation_rsc (p_wip_entity_id, p_org_id) loop
    UPDATE wip_op_resource_instances
    SET start_date = cur_rsc.start_date,
        completion_date = cur_rsc.completion_date
    WHERE wip_entity_id = p_wip_entity_id
      and organization_id = p_org_id
      and operation_seq_num = cur_rsc.operation_seq_num
      and resource_seq_num = cur_rsc.resource_seq_num;
  end loop;
End Update_Resource_Instances;

END WIP_OP_RESOURCES_UTILITIES;

/
