--------------------------------------------------------
--  DDL for Package Body WIP_OPERATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_OPERATIONS_PKG" AS
/* $Header: wipoperb.pls 120.0.12010000.6 2010/04/21 09:34:40 sisankar ship $ */

  procedure add(
    p_org_id            in number,
    p_wip_entity_id     in number,
    p_operation_seq_num in number,
    p_operation_id      in number,
    p_department_id     in number) is
    x_prev_op_seq_num   number  := NULL;
    x_next_op_seq_num   number  := NULL;
    x_user_id           number  := FND_GLOBAL.USER_ID;
    x_login_id          number  := FND_GLOBAL.LOGIN_ID;
    x_request_id 	number  := FND_GLOBAL.CONC_REQUEST_ID;
    x_appl_id    	number  := FND_GLOBAL.PROG_APPL_ID;
    x_program_id 	number  := FND_GLOBAL.CONC_PROGRAM_ID;
    adding_standard_op  boolean := (p_operation_id is NOT NULL
                                    or
                                    p_operation_id = -1);
    l_scrap_qty         number  := 0;
    /* Added : -- bug 7371859     */
    -- for validating sub resource exiting or not for std operation
    sub_res_count number;
    l_wsor_max_res_seq_num number :=0;
   /* End : -- bug 7371859 */
  begin
    --  get previous and next operation
    select max(wo1.operation_seq_num),
           min(wo2.operation_seq_num)
    into   x_prev_op_seq_num,
           x_next_op_seq_num
    from   dual sd,
           wip_operations wo1,
           wip_operations wo2
    where  wo1.organization_id(+) = p_org_id
    and    wo1.wip_entity_id(+) = decode(1, 1, p_wip_entity_id, sd.dummy)
    and    wo1.operation_seq_num(+) < p_operation_seq_num
    and    wo2.organization_id(+) = p_org_id
    and    wo2.wip_entity_id(+) = decode(1, 1, p_wip_entity_id, sd.dummy)
    and    wo2.operation_seq_num(+) > p_operation_seq_num;

     /* For Enhancement#2864382. Calculate cumulative_scrap_quantity for this operation */

                SELECT SUM(quantity_scrapped)
                  INTO l_scrap_qty
                  FROM wip_operations
                 WHERE organization_id         =  p_org_id
                   AND wip_entity_id           =  p_wip_entity_id
                   AND operation_seq_num       <  p_operation_seq_num;

                IF (l_scrap_qty IS NULL) THEN
                    l_scrap_qty :=0;
                END IF;

    -- if prev operation exists in routing
    if (x_prev_op_seq_num is NOT NULL) then
      update wip_operations
      set    next_operation_seq_num = p_operation_seq_num
      where  organization_id = p_org_id
      and    wip_entity_id = p_wip_entity_id
      and    operation_seq_num = x_prev_op_seq_num;
    end if;

    -- if next operation exists in routing
    if (x_next_op_seq_num is NOT NULL) then
      update wip_operations
      set    previous_operation_seq_num = p_operation_seq_num
      where  organization_id = p_org_id
      and    wip_entity_id = p_wip_entity_id
      and    operation_seq_num = x_next_op_seq_num;
    end if;

    -- add operation
    begin
      insert into wip_operations(
             wip_entity_id,
             operation_seq_num,
             organization_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             standard_operation_id,
             department_id,
             scheduled_quantity,
             quantity_in_queue,
             quantity_running,
             quantity_waiting_to_move,
             quantity_rejected,
             quantity_scrapped,
             quantity_completed,
             cumulative_scrap_quantity,  /* for enh#2864382*/
             minimum_transfer_quantity,
             first_unit_start_date,
             first_unit_completion_date,
             last_unit_start_date,
             last_unit_completion_date,
             previous_operation_seq_num,
             next_operation_seq_num,
             count_point_type,
             backflush_flag,
             description,
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
													check_skill)
      select p_wip_entity_id,
             p_operation_seq_num,
             p_org_id,
             SYSDATE,
             x_user_id,
             SYSDATE,
             x_user_id,
             x_login_id,
             decode(p_operation_id, -1, NULL, p_operation_id),
             p_department_id,
             WDJ.START_QUANTITY,
             0, -- quantity_in_queue
             0, -- quantity_running
             0, -- quantity_waiting_to_move
             0, -- quantity_rejected
             0, -- quantity_in_scrap
             0, -- quantity_completed
             l_scrap_qty,
             nvl(bso.minimum_transfer_quantity, 0),
             nvl(wo1.first_unit_completion_date, -- first_unit_start_date
                 wdj.scheduled_start_date),
             nvl(wo1.first_unit_completion_date, -- first_unit_completion_date
                 wdj.scheduled_start_date),
             nvl(wo1.last_unit_completion_date,  -- last_unit_start_date
                 wdj.scheduled_start_date),
             nvl(wo1.last_unit_completion_date,  -- last_unit_completion_date
                 wdj.scheduled_start_date),
             x_prev_op_seq_num,
             x_next_op_seq_num,
             WIP_CONSTANTS.YES_AUTO,
             decode(x_next_op_seq_num,
                    NULL, WIP_CONSTANTS.YES, WIP_CONSTANTS.NO),
             bso.operation_description,
             bso.attribute_category,
             bso.attribute1,
             bso.attribute2,
             bso.attribute3,
             bso.attribute4,
             bso.attribute5,
             bso.attribute6,
             bso.attribute7,
             bso.attribute8,
             bso.attribute9,
             bso.attribute10,
             bso.attribute11,
             bso.attribute12,
             bso.attribute13,
             bso.attribute14,
             bso.attribute15,
													bso.check_skill
      from   wip_operations wo1,
             wip_discrete_jobs wdj,
             bom_standard_operations bso
      where  bso.standard_operation_id(+) = p_operation_id
/* %cfm  Ignore cfm ops. */
      and    nvl(bso.operation_type, 1) = 1
      and    bso.line_id is null
/* %/cfm */
      and    bso.organization_id(+) =
               decode(1, 1, p_org_id,wdj.organization_id)
      and    wdj.wip_entity_id = p_wip_entity_id
      and    wdj.organization_id = p_org_id
      and    wo1.wip_entity_id(+) =
               decode(1, 1, p_wip_entity_id, wdj.wip_entity_id)
      and    wo1.organization_id(+) = p_org_id
      and    wo1.operation_seq_num(+) = x_prev_op_seq_num;

    exception
      when DUP_VAL_ON_INDEX then
        fnd_message.set_name(
          application => 'WIP',
          name        => 'WIP_SAME_OP_EXISTS');
        fnd_message.raise_error;
    end;

    -- if standard operation, add resources and instructions
    if (adding_standard_op) then
      insert into wip_operation_resources
            (wip_entity_id,
             operation_seq_num,
             resource_seq_num,
             organization_id,
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
             autocharge_type,
             standard_rate_flag,
             applied_resource_units,
             applied_resource_value,
             start_date,
             completion_date,
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
	     substitute_group_num, -- Added  : ---- bug 7371859
             schedule_seq_num,     -- Added  : ---- bug 7371859
             replacement_group_num) -- Added : ---- bug 7371859
      select p_wip_entity_id,
             p_operation_seq_num,
             bsor.resource_seq_num,
             p_org_id,
             SYSDATE,
             x_user_id,
             SYSDATE,
             x_user_id,
             x_login_id,
             bsor.resource_id,
             br.unit_of_measure,
             bsor.basis_type,
             bsor.usage_rate_or_amount,
             bsor.activity_id,
             bsor.schedule_flag,
             bsor.assigned_units,
             bsor.autocharge_type,
             bsor.standard_rate_flag,
             0, -- applied_resource_units
             0, -- applied_resource_value
             wo.first_unit_start_date,
             wo.last_unit_completion_date,
             bsor.attribute_category,
             bsor.attribute1,
             bsor.attribute2,
             bsor.attribute3,
             bsor.attribute4,
             bsor.attribute5,
             bsor.attribute6,
             bsor.attribute7,
             bsor.attribute8,
             bsor.attribute9,
             bsor.attribute10,
             bsor.attribute11,
             bsor.attribute12,
             bsor.attribute13,
             bsor.attribute14,
             bsor.attribute15,
	     bsor.substitute_group_num,     -- Added :  -- bug 7371859
             bsor.resource_seq_num,         -- Added :  -- bug 7371859(Schedule Seq Num= Resource Seq Num)
             0                              -- Added :  -- bug 7371859
      from   wip_operations wo,
             bom_resources br,
             bom_std_op_resources bsor
      where  bsor.standard_operation_id = p_operation_id
      and    br.resource_id = bsor.resource_id
      and    nvl(br.disable_date, SYSDATE + 1) > SYSDATE
      and    wo.organization_id = p_org_id
      and    wo.wip_entity_id = p_wip_entity_id
      and    wo.operation_seq_num = p_operation_seq_num;

     FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
        X_FROM_ENTITY_NAME => 'BOM_STANDARD_OPERATIONS',
        X_FROM_PK1_VALUE   => to_char(p_operation_id),
        X_TO_ENTITY_NAME   => 'WIP_DISCRETE_OPERATIONS',
        X_TO_PK1_VALUE   => to_char(p_wip_entity_id),
        X_TO_PK2_VALUE   => to_char(p_operation_seq_num),
        X_TO_PK3_VALUE   => to_char(p_org_id),
        X_CREATED_BY     => x_user_id,
        X_LAST_UPDATE_LOGIN => x_login_id,
        X_PROGRAM_APPLICATION_ID  => x_appl_id,
        X_PROGRAM_ID    => x_program_id,
        X_REQUEST_ID    => x_request_id);
 /* Added : -- bug 7371859   */

     /* Added for 12.1.1 Skills Validation project.*/
     INSERT INTO WIP_OPERATION_COMPETENCIES
            ( LEVEL_ID,          ORGANIZATION_ID,
             WIP_ENTITY_ID,           OPERATION_SEQ_NUM, OPERATION_SEQUENCE_ID,
             STANDARD_OPERATION_ID,   COMPETENCE_ID,     RATING_LEVEL_ID,
             QUALIFICATION_TYPE_ID,   LAST_UPDATE_DATE,  LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,       CREATED_BY,        CREATION_DATE)
        SELECT
             3,                    WO.ORGANIZATION_ID,
             WO.WIP_ENTITY_ID,               WO.OPERATION_SEQ_NUM, BOS.OPERATION_SEQUENCE_ID,
             BOS.STANDARD_OPERATION_ID,      BOS.COMPETENCE_ID,    BOS.RATING_LEVEL_ID,
             BOS.QUALIFICATION_TYPE_ID,      WO.LAST_UPDATE_DATE,  WO.LAST_UPDATED_BY,
             WO.LAST_UPDATE_LOGIN,           WO.CREATED_BY,        WO.CREATION_DATE
        FROM BOM_OPERATION_SKILLS BOS,
             WIP_OPERATIONS WO,
             WIP_ENTITIES WE
        WHERE
             WE.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
             AND WO.ORGANIZATION_ID = WO.ORGANIZATION_ID
             AND WE.ENTITY_TYPE = 1
             AND WO.ORGANIZATION_ID = p_org_id
             AND WO.WIP_ENTITY_ID = p_wip_entity_id
             AND WO.OPERATION_SEQ_NUM = p_operation_seq_num
             AND WO.ORGANIZATION_ID = BOS.ORGANIZATION_ID
             AND BOS.STANDARD_OPERATION_ID = p_operation_id
             AND BOS.LEVEL_ID = 1;

     BEGIN
       SELECT count(*)
        INTO  sub_res_count
        FROM  BOM_STD_SUB_OP_RESOURCES BSSOR
        WHERE BSSOR.STANDARD_OPERATION_ID=p_operation_id;
     EXCEPTION
         WHEN no_data_found THEN
             null;
     END ;

     IF   sub_res_count >0 then

        BEGIN
            SELECT nvl(max(resource_seq_num), 10)
            INTO   l_wsor_max_res_seq_num
            FROM   WIP_SUB_OPERATION_RESOURCES WSOR
            WHERE  wip_entity_id = p_wip_entity_id
            AND    OPERATION_SEQ_NUM = p_operation_seq_num;
        EXCEPTION
            WHEN no_data_found THEN
                null;
        END;

           INSERT INTO WIP_SUB_OPERATION_RESOURCES
                    (wip_entity_id,
                    operation_seq_num,
                    resource_seq_num,
                    organization_id,
                    --repetitive_schedule_id,
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
            SELECT  p_wip_entity_id,
                    p_operation_seq_num,
                   (rownum + l_wsor_max_res_seq_num),
                    p_org_id,
                --    X_Repetitive_Schedule_Id,
                    SYSDATE ,
                    x_user_id,
                    SYSDATE,
                    x_user_id,
                    x_login_id,
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
                    sysdate, -- DECODE(X_Start_Date, NULL, SYSDATE, X_Start_Date),
                    sysdate, --DECODE(X_Completion_Date, NULL, SYSDATE, X_Completion_Date),
                    BSSOR.schedule_seq_num  ,
                    BSSOR.substitute_group_num,
                    BSSOR.replacement_group_num,
                    NULL --setup_id
            FROM    BOM_RESOURCES BR,
                    BOM_STD_SUB_OP_RESOURCES BSSOR
            WHERE   bssor.standard_operation_id=p_operation_id
              AND   BSSOR.RESOURCE_ID = BR.RESOURCE_ID;

    End IF;
    /* End : -- bug 7371859   */



    end if;

    return;

  exception
    when others then
      wip_constants.get_ora_error(
        application => 'WIP',
        proc_name   => 'WIP_OPERATIONS_PKG.ADD');
      fnd_message.raise_error;

  end add;


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Repetitive_Schedule_Id         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Operation_Sequence_Id          NUMBER,
                       X_Standard_Operation_Id          NUMBER,
                       X_Department_Id                  NUMBER,
                       X_Description                    VARCHAR2,
                       X_Scheduled_Quantity             NUMBER,
                       X_Quantity_In_Queue              NUMBER,
                       X_Quantity_Running               NUMBER,
                       X_Quantity_Waiting_To_Move       NUMBER,
                       X_Quantity_Rejected              NUMBER,
                       X_Quantity_Scrapped              NUMBER,
                       X_Quantity_Completed             NUMBER,
                       X_First_Unit_Start_Date          DATE,
                       X_First_Unit_Completion_Date     DATE,
                       X_Last_Unit_Start_Date           DATE,
                       X_Last_Unit_Completion_Date      DATE,
                       X_Previous_Operation_Seq_Num     NUMBER,
                       X_Next_Operation_Seq_Num         NUMBER,
                       X_Count_Point_Type               NUMBER,
                       X_Backflush_Flag                 NUMBER,
                       X_Minimum_Transfer_Quantity      NUMBER,
                       X_Date_Last_Moved                DATE,
/*3118918*/            X_Progress_percentage            NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
		                     X_CHECK_SKILL                    NUMBER DEFAULT NULL) IS
     CURSOR C IS SELECT rowid FROM WIP_OPERATIONS
                 WHERE wip_entity_id = X_Wip_Entity_Id
                 AND   operation_seq_num = X_Operation_Seq_Num
                 AND   organization_id = X_Organization_Id
		 AND   (repetitive_Schedule_id = X_Repetitive_Schedule_Id
			OR (repetitive_schedule_id IS NULL
			     AND X_Repetitive_Schedule_Id IS NULL));
     x_user_id		number	:= FND_GLOBAL.USER_ID;
     x_login_id		number	:= FND_GLOBAL.LOGIN_ID;
     x_request_id       number  := FND_GLOBAL.CONC_REQUEST_ID;
     x_appl_id          number  := FND_GLOBAL.PROG_APPL_ID;
     x_program_id       number  := FND_GLOBAL.CONC_PROGRAM_ID;
     x_standard_op	boolean	:= (X_Standard_Operation_Id is NOT NULL);
     l_scrap_qty        number :=0;

    BEGIN

/* For Enhancement#2864382. Calculate cumulative_scrap_quantity for this op
eration */

                SELECT SUM(quantity_scrapped)
                  INTO l_scrap_qty
                  FROM wip_operations
                 WHERE organization_id         =  X_Organization_Id
                   AND wip_entity_id           =  X_Wip_Entity_Id
                   AND (repetitive_schedule_id =  X_Repetitive_Schedule_Id   OR
                         (repetitive_schedule_id IS NULL AND X_Repetitive_Schedule_Id IS NULL))
                   AND operation_seq_num       <  X_Operation_Seq_Num;

                IF (l_scrap_qty IS NULL) THEN
                    l_scrap_qty :=0;
                END IF;

       INSERT INTO WIP_OPERATIONS(
               wip_entity_id,
               operation_seq_num,
               organization_id,
               repetitive_schedule_id,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               operation_sequence_id,
               standard_operation_id,
               department_id,
               description,
               scheduled_quantity,
               quantity_in_queue,
               quantity_running,
               quantity_waiting_to_move,
               quantity_rejected,
               quantity_scrapped,
               quantity_completed,
               first_unit_start_date,
               first_unit_completion_date,
               last_unit_start_date,
               last_unit_completion_date,
               previous_operation_seq_num,
               next_operation_seq_num,
               count_point_type,
               backflush_flag,
               minimum_transfer_quantity,
               date_last_moved,
               cumulative_scrap_quantity, /*For Enhancement#2864382*/
               progress_percentage, /*Enhancement 3118918*/
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
															CHECK_SKILL
             ) VALUES (
               X_Wip_Entity_Id,
               X_Operation_Seq_Num,
               X_Organization_Id,
               X_Repetitive_Schedule_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
               X_Operation_Sequence_Id,
               X_Standard_Operation_Id,
               X_Department_Id,
               X_Description,
               X_Scheduled_Quantity,
               X_Quantity_In_Queue,
               X_Quantity_Running,
               X_Quantity_Waiting_To_Move,
               X_Quantity_Rejected,
               X_Quantity_Scrapped,
               X_Quantity_Completed,
               X_First_Unit_Start_Date,
               X_First_Unit_Completion_Date,
               X_Last_Unit_Start_Date,
               X_Last_Unit_Completion_Date,
               X_Previous_Operation_Seq_Num,
               X_Next_Operation_Seq_Num,
               X_Count_Point_Type,
               X_Backflush_Flag,
               X_Minimum_Transfer_Quantity,
               X_Date_Last_Moved,
               l_scrap_qty,
               X_progress_percentage,
               X_Attribute_Category,
               X_Attribute1,
               X_Attribute2,
               X_Attribute3,
               X_Attribute4,
               X_Attribute5,
               X_Attribute6,
               X_Attribute7,
               X_Attribute8,
               X_Attribute9,
               X_Attribute10,
               X_Attribute11,
               X_Attribute12,
               X_Attribute13,
               X_Attribute14,
               X_Attribute15,
															X_CHECK_SKILL
             );


    IF (X_Repetitive_Schedule_Id IS NULL) THEN
      FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
        X_FROM_ENTITY_NAME => 'BOM_STANDARD_OPERATIONS',
        X_FROM_PK1_VALUE   => to_char(X_Standard_Operation_Id),
        X_TO_ENTITY_NAME   => 'WIP_DISCRETE_OPERATIONS',
        X_TO_PK1_VALUE   => to_char(X_Wip_Entity_Id),
        X_TO_PK2_VALUE   => to_char(X_Operation_Seq_Num),
        X_TO_PK3_VALUE   => to_char(X_Organization_Id),
        X_CREATED_BY     => x_user_id,
        X_LAST_UPDATE_LOGIN => x_login_id,
        X_PROGRAM_APPLICATION_ID  => x_appl_id,
        X_PROGRAM_ID    => x_program_id,
        X_REQUEST_ID    => x_request_id);
    ELSE
      FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
        X_FROM_ENTITY_NAME => 'BOM_STANDARD_OPERATIONS',
        X_FROM_PK1_VALUE   => to_char(X_Standard_Operation_Id),
        X_TO_ENTITY_NAME   => 'WIP_REPETITIVE_OPERATIONS',
        X_TO_PK1_VALUE   => to_char(X_Wip_Entity_Id),
        X_TO_PK2_VALUE   => to_char(X_Operation_Seq_Num),
        X_TO_PK3_VALUE   => to_char(X_Organization_Id),
	X_TO_PK4_VALUE   => to_char(X_Repetitive_Schedule_Id),
        X_CREATED_BY     => x_user_id,
        X_LAST_UPDATE_LOGIN => x_login_id,
        X_PROGRAM_APPLICATION_ID  => x_appl_id,
        X_PROGRAM_ID    => x_program_id,
        X_REQUEST_ID    => x_request_id);
    END IF;

				/* Added for 12.1.1 Skills Validation project.*/
     /*INSERT INTO WIP_OPERATION_COMPETENCIES
            ( LEVEL_ID,          ORGANIZATION_ID,
             WIP_ENTITY_ID,           OPERATION_SEQ_NUM, OPERATION_SEQUENCE_ID,
             STANDARD_OPERATION_ID,   COMPETENCE_ID,     RATING_LEVEL_ID,
             QUALIFICATION_TYPE_ID,   LAST_UPDATE_DATE,  LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,       CREATED_BY,        CREATION_DATE)
        SELECT
              3,                    WO.ORGANIZATION_ID,
             WO.WIP_ENTITY_ID,               WO.OPERATION_SEQ_NUM, BOS.OPERATION_SEQUENCE_ID,
             BOS.STANDARD_OPERATION_ID,      BOS.COMPETENCE_ID,    BOS.RATING_LEVEL_ID,
             BOS.QUALIFICATION_TYPE_ID,      WO.LAST_UPDATE_DATE,  WO.LAST_UPDATED_BY,
             WO.LAST_UPDATE_LOGIN,           WO.CREATED_BY,        WO.CREATION_DATE
        FROM BOM_OPERATION_SKILLS BOS,
             WIP_OPERATIONS WO,
             WIP_ENTITIES WE
        WHERE
             WE.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
             AND WO.ORGANIZATION_ID = WO.ORGANIZATION_ID
             AND WE.ENTITY_TYPE = 1
             AND WO.ORGANIZATION_ID = X_Organization_Id
             AND WO.WIP_ENTITY_ID = X_Wip_Entity_Id
             AND WO.OPERATION_SEQ_NUM = X_Operation_Seq_Num
             AND NVL(WO.CHECK_SKILL,2) =1
             AND WO.ORGANIZATION_ID = BOS.ORGANIZATION_ID
             AND BOS.STANDARD_OPERATION_ID = X_Standard_Operation_Id
             AND BOS.LEVEL_ID = 1;*/

	     /* Commented out as the same piece of login is implemented directly in the form*/

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Wip_Entity_Id                    NUMBER,
                     X_Operation_Seq_Num                NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Repetitive_Schedule_Id           NUMBER,
                     X_Operation_Sequence_Id            NUMBER,
                     X_Standard_Operation_Id            NUMBER,
                     X_Department_Id                    NUMBER,
                     X_Description                      VARCHAR2,
                     X_Scheduled_Quantity               NUMBER,
                     X_Quantity_In_Queue                NUMBER,
                     X_Quantity_Running                 NUMBER,
                     X_Quantity_Waiting_To_Move         NUMBER,
                     X_Quantity_Rejected                NUMBER,
                     X_Quantity_Scrapped                NUMBER,
                     X_Quantity_Completed               NUMBER,
                     X_First_Unit_Start_Date            DATE,
                     X_First_Unit_Completion_Date       DATE,
                     X_Last_Unit_Start_Date             DATE,
                     X_Last_Unit_Completion_Date        DATE,
                     X_Count_Point_Type                 NUMBER,
                     X_Backflush_Flag                   NUMBER,
                     X_Minimum_Transfer_Quantity        NUMBER,
                     X_Date_Last_Moved                  DATE,
                     X_progress_percentage              NUMBER,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
																					X_CHECK_SKILL                      NUMBER DEFAULT NULL

  ) IS
    CURSOR C IS
        SELECT *
        FROM   WIP_OPERATIONS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Wip_Entity_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      fnd_message.raise_error;
      app_exception.raise_exception;
    end if;
    CLOSE C;

    if (       (Recinfo.wip_entity_id = X_Wip_Entity_Id)
           AND (Recinfo.operation_seq_num = X_Operation_Seq_Num)
           AND (Recinfo.organization_id = X_Organization_Id)
           AND (   (Recinfo.repetitive_schedule_id = X_Repetitive_Schedule_Id)
                OR (    (Recinfo.repetitive_schedule_id IS NULL)
                    AND (X_Repetitive_Schedule_Id IS NULL)))
           AND (   (Recinfo.operation_sequence_id = X_Operation_Sequence_Id)
                OR (    (Recinfo.operation_sequence_id IS NULL)
                    AND (X_Operation_Sequence_Id IS NULL)))
           AND (   (Recinfo.standard_operation_id = X_Standard_Operation_Id)
                OR (    (Recinfo.standard_operation_id IS NULL)
                    AND (X_Standard_Operation_Id IS NULL)))
           AND (Recinfo.department_id = X_Department_Id)
           AND (   (Recinfo.description = X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (Recinfo.scheduled_quantity = X_Scheduled_Quantity)
           AND (Recinfo.quantity_in_queue = X_Quantity_In_Queue)
           AND (Recinfo.quantity_running = X_Quantity_Running)
           AND (Recinfo.quantity_waiting_to_move = X_Quantity_Waiting_To_Move)
           AND (Recinfo.quantity_rejected = X_Quantity_Rejected)
           AND (Recinfo.quantity_scrapped = X_Quantity_Scrapped)
           AND (Recinfo.quantity_completed = X_Quantity_Completed)
           AND (Recinfo.first_unit_start_date = X_First_Unit_Start_Date)
           AND (Recinfo.first_unit_completion_date = X_First_Unit_Completion_Date)
           AND (Recinfo.last_unit_start_date = X_Last_Unit_Start_Date)
           AND (Recinfo.last_unit_completion_date = X_Last_Unit_Completion_Date)
/*3118918*/AND (  (Recinfo.progress_percentage = X_Progress_percentage)
                  OR (    (Recinfo.progress_percentage IS NULL)
                    AND (X_Progress_percentage IS NULL)))
           AND (Recinfo.count_point_type = X_Count_Point_Type))
        then
             if (
               (Recinfo.backflush_flag = X_Backflush_Flag)
           AND (Recinfo.minimum_transfer_quantity = X_Minimum_Transfer_Quantity)
           AND (   (Recinfo.date_last_moved = X_Date_Last_Moved)
                OR (    (Recinfo.date_last_moved IS NULL)
                    AND (X_Date_Last_Moved IS NULL)))
           AND (   (Recinfo.attribute_category = X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 = X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 = X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 = X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 = X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 = X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 = X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 = X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 = X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 = X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 = X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 = X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 = X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 = X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 = X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 = X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (nvl(Recinfo.CHECK_SKILL,2) = X_CHECK_SKILL)
                OR (    (Recinfo.CHECK_SKILL IS NULL)
                    AND (X_CHECK_SKILL IS NULL)))
           )
then
      return;
    else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        fnd_message.raise_error;

        app_exception.raise_exception;
    end if;
    else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        fnd_message.raise_error;
        app_exception.raise_exception;
    end if;

  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Repetitive_Schedule_Id         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Operation_Sequence_Id          NUMBER,
                       X_Standard_Operation_Id          NUMBER,
                       X_Department_Id                  NUMBER,
                       X_Description                    VARCHAR2,
                       X_Scheduled_Quantity             NUMBER,
                       X_Quantity_In_Queue              NUMBER,
                       X_Quantity_Running               NUMBER,
                       X_Quantity_Waiting_To_Move       NUMBER,
                       X_Quantity_Rejected              NUMBER,
                       X_Quantity_Scrapped              NUMBER,
                       X_Quantity_Completed             NUMBER,
                       X_First_Unit_Start_Date          DATE,
                       X_First_Unit_Completion_Date     DATE,
                       X_Last_Unit_Start_Date           DATE,
                       X_Last_Unit_Completion_Date      DATE,
                       X_Count_Point_Type               NUMBER,
                       X_Backflush_Flag                 NUMBER,
                       X_Minimum_Transfer_Quantity      NUMBER,
                       X_Date_Last_Moved                DATE,
/*3118918*/            X_Progress_percentage            NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
																							X_CHECK_SKILL                    NUMBER DEFAULT NULL

 ) IS
 BEGIN
   UPDATE WIP_OPERATIONS
   SET
     wip_entity_id                     =     X_Wip_Entity_Id,
     operation_seq_num                 =     X_Operation_Seq_Num,
     organization_id                   =     X_Organization_Id,
     repetitive_schedule_id            =     X_Repetitive_Schedule_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     operation_sequence_id             =     X_Operation_Sequence_Id,
     standard_operation_id             =     X_Standard_Operation_Id,
     department_id                     =     X_Department_Id,
     description                       =     X_Description,
     scheduled_quantity                =     X_Scheduled_Quantity,
     quantity_in_queue                 =     X_Quantity_In_Queue,
     quantity_running                  =     X_Quantity_Running,
     quantity_waiting_to_move          =     X_Quantity_Waiting_To_Move,
     quantity_rejected                 =     X_Quantity_Rejected,
     quantity_scrapped                 =     X_Quantity_Scrapped,
     quantity_completed                =     X_Quantity_Completed,
     first_unit_start_date             =     X_First_Unit_Start_Date,
     first_unit_completion_date        =     X_First_Unit_Completion_Date,
     last_unit_start_date              =     X_Last_Unit_Start_Date,
     last_unit_completion_date         =     X_Last_Unit_Completion_Date,
     count_point_type                  =     X_Count_Point_Type,
     backflush_flag                    =     X_Backflush_Flag,
     minimum_transfer_quantity         =     X_Minimum_Transfer_Quantity,
     date_last_moved                   =     X_Date_Last_Moved,
     progress_percentage               =     X_Progress_percentage,/*3118918*/
     attribute_category                =     X_Attribute_Category,
     attribute1                        =     X_Attribute1,
     attribute2                        =     X_Attribute2,
     attribute3                        =     X_Attribute3,
     attribute4                        =     X_Attribute4,
     attribute5                        =     X_Attribute5,
     attribute6                        =     X_Attribute6,
     attribute7                        =     X_Attribute7,
     attribute8                        =     X_Attribute8,
     attribute9                        =     X_Attribute9,
     attribute10                       =     X_Attribute10,
     attribute11                       =     X_Attribute11,
     attribute12                       =     X_Attribute12,
     attribute13                       =     X_Attribute13,
     attribute14                       =     X_Attribute14,
     attribute15                       =     X_Attribute15,
					CHECK_SKILL                       =     X_CHECK_SKILL
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM WIP_OPERATIONS
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Repetitive_Schedule_Id         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Operation_Sequence_Id          NUMBER,
                       X_Standard_Operation_Id          NUMBER,
                       X_Department_Id                  NUMBER,
                       X_Description                    VARCHAR2,
                       X_Scheduled_Quantity             NUMBER,
                       X_Quantity_In_Queue              NUMBER,
                       X_Quantity_Running               NUMBER,
                       X_Quantity_Waiting_To_Move       NUMBER,
                       X_Quantity_Rejected              NUMBER,
                       X_Quantity_Scrapped              NUMBER,
                       X_Quantity_Completed             NUMBER,
                       X_First_Unit_Start_Date          DATE,
                       X_First_Unit_Completion_Date     DATE,
                       X_Last_Unit_Start_Date           DATE,
                       X_Last_Unit_Completion_Date      DATE,
                       X_Previous_Operation_Seq_Num     NUMBER,
                       X_Next_Operation_Seq_Num         NUMBER,
                       X_Count_Point_Type               NUMBER,
                       X_Backflush_Flag                 NUMBER,
                       X_Minimum_Transfer_Quantity      NUMBER,
                       X_Date_Last_Moved                DATE,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
                      ) is
    l_progressPercentage number;
  begin
    Insert_Row(X_Rowid => X_Rowid,
               X_Wip_Entity_Id => X_Wip_Entity_Id,
               X_Operation_Seq_Num => X_Operation_Seq_Num,
               X_Organization_Id => X_Organization_Id,
               X_Repetitive_Schedule_Id => X_Repetitive_Schedule_Id,
               X_Last_Update_Date => X_Last_Update_Date,
               X_Last_Updated_By => X_Last_Updated_By,
               X_Creation_Date => X_Creation_Date,
               X_Created_By => X_Created_By,
               X_Last_Update_Login => X_Last_Update_Login,
               X_Operation_Sequence_Id => X_Operation_Sequence_Id,
               X_Standard_Operation_Id => X_Standard_Operation_Id,
               X_Department_Id => X_Department_Id,
               X_Description => X_Description,
               X_Scheduled_Quantity => X_Scheduled_Quantity,
               X_Quantity_In_Queue => X_Quantity_In_Queue,
               X_Quantity_Running => X_Quantity_Running,
               X_Quantity_Waiting_To_Move => X_Quantity_Waiting_To_Move,
               X_Quantity_Rejected => X_Quantity_Rejected,
               X_Quantity_Scrapped => X_Quantity_Scrapped,
               X_Quantity_Completed => X_Quantity_Completed,
               X_First_Unit_Start_Date => X_First_Unit_Start_Date,
               X_First_Unit_Completion_Date => X_First_Unit_Completion_Date,
               X_Last_Unit_Start_Date => X_Last_Unit_Start_Date,
               X_Last_Unit_Completion_Date => X_Last_Unit_Completion_Date,
               X_Previous_Operation_Seq_Num => X_Previous_Operation_Seq_Num,
               X_Next_Operation_Seq_Num => X_Next_Operation_Seq_Num,
               X_Count_Point_Type => X_Count_Point_Type,
               X_Backflush_Flag => X_Backflush_Flag,
               X_Minimum_Transfer_Quantity => X_Minimum_Transfer_Quantity,
               X_Date_Last_Moved => X_Date_Last_Moved,
               X_Progress_percentage => l_progressPercentage,
               X_Attribute_Category => X_Attribute_Category,
               X_Attribute1 => X_Attribute1,
               X_Attribute2 => X_Attribute2,
               X_Attribute3 => X_Attribute3,
               X_Attribute4 => X_Attribute4,
               X_Attribute5 => X_Attribute5,
               X_Attribute6 => X_Attribute6,
               X_Attribute7 => X_Attribute7,
               X_Attribute8 => X_Attribute8,
               X_Attribute9 => X_Attribute9,
               X_Attribute10 => X_Attribute10,
               X_Attribute11 => X_Attribute11,
               X_Attribute12 => X_Attribute12,
               X_Attribute13 => X_Attribute13,
               X_Attribute14 => X_Attribute14,
               X_Attribute15 => X_Attribute15,
															X_CHECK_SKILL => null);
  end Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Wip_Entity_Id                    NUMBER,
                     X_Operation_Seq_Num                NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Repetitive_Schedule_Id           NUMBER,
                     X_Operation_Sequence_Id            NUMBER,
                     X_Standard_Operation_Id            NUMBER,
                     X_Department_Id                    NUMBER,
                     X_Description                      VARCHAR2,
                     X_Scheduled_Quantity               NUMBER,
                     X_Quantity_In_Queue                NUMBER,
                     X_Quantity_Running                 NUMBER,
                     X_Quantity_Waiting_To_Move         NUMBER,
                     X_Quantity_Rejected                NUMBER,
                     X_Quantity_Scrapped                NUMBER,
                     X_Quantity_Completed               NUMBER,
                     X_First_Unit_Start_Date            DATE,
                     X_First_Unit_Completion_Date       DATE,
                     X_Last_Unit_Start_Date             DATE,
                     X_Last_Unit_Completion_Date        DATE,
                     X_Count_Point_Type                 NUMBER,
                     X_Backflush_Flag                   NUMBER,
                     X_Minimum_Transfer_Quantity        NUMBER,
                     X_Date_Last_Moved                  DATE,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2
                    ) is
    l_progressPercentage number;
  begin
     Lock_Row(X_Rowid => X_Rowid,
               X_Wip_Entity_Id => X_Wip_Entity_Id,
               X_Operation_Seq_Num => X_Operation_Seq_Num,
               X_Organization_Id => X_Organization_Id,
               X_Repetitive_Schedule_Id => X_Repetitive_Schedule_Id,
               X_Operation_Sequence_Id => X_Operation_Sequence_Id,
               X_Standard_Operation_Id => X_Standard_Operation_Id,
               X_Department_Id => X_Department_Id,
               X_Description => X_Description,
               X_Scheduled_Quantity => X_Scheduled_Quantity,
               X_Quantity_In_Queue => X_Quantity_In_Queue,
               X_Quantity_Running => X_Quantity_Running,
               X_Quantity_Waiting_To_Move => X_Quantity_Waiting_To_Move,
               X_Quantity_Rejected => X_Quantity_Rejected,
               X_Quantity_Scrapped => X_Quantity_Scrapped,
               X_Quantity_Completed => X_Quantity_Completed,
               X_First_Unit_Start_Date => X_First_Unit_Start_Date,
               X_First_Unit_Completion_Date => X_First_Unit_Completion_Date,
               X_Last_Unit_Start_Date => X_Last_Unit_Start_Date,
               X_Last_Unit_Completion_Date => X_Last_Unit_Completion_Date,
               X_Count_Point_Type => X_Count_Point_Type,
               X_Backflush_Flag => X_Backflush_Flag,
               X_Minimum_Transfer_Quantity => X_Minimum_Transfer_Quantity,
               X_Date_Last_Moved => X_Date_Last_Moved,
               X_Progress_percentage => l_progressPercentage,
               X_Attribute_Category => X_Attribute_Category,
               X_Attribute1 => X_Attribute1,
               X_Attribute2 => X_Attribute2,
               X_Attribute3 => X_Attribute3,
               X_Attribute4 => X_Attribute4,
               X_Attribute5 => X_Attribute5,
               X_Attribute6 => X_Attribute6,
               X_Attribute7 => X_Attribute7,
               X_Attribute8 => X_Attribute8,
               X_Attribute9 => X_Attribute9,
               X_Attribute10 => X_Attribute10,
               X_Attribute11 => X_Attribute11,
               X_Attribute12 => X_Attribute12,
               X_Attribute13 => X_Attribute13,
               X_Attribute14 => X_Attribute14,
               X_Attribute15 => X_Attribute15,
															X_CHECK_SKILL => null);
  end Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Repetitive_Schedule_Id         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Operation_Sequence_Id          NUMBER,
                       X_Standard_Operation_Id          NUMBER,
                       X_Department_Id                  NUMBER,
                       X_Description                    VARCHAR2,
                       X_Scheduled_Quantity             NUMBER,
                       X_Quantity_In_Queue              NUMBER,
                       X_Quantity_Running               NUMBER,
                       X_Quantity_Waiting_To_Move       NUMBER,
                       X_Quantity_Rejected              NUMBER,
                       X_Quantity_Scrapped              NUMBER,
                       X_Quantity_Completed             NUMBER,
                       X_First_Unit_Start_Date          DATE,
                       X_First_Unit_Completion_Date     DATE,
                       X_Last_Unit_Start_Date           DATE,
                       X_Last_Unit_Completion_Date      DATE,
                       X_Count_Point_Type               NUMBER,
                       X_Backflush_Flag                 NUMBER,
                       X_Minimum_Transfer_Quantity      NUMBER,
                       X_Date_Last_Moved                DATE,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
                      ) is
    l_progressPercentage number;
  begin
    Update_Row(X_Rowid => X_Rowid,
               X_Wip_Entity_Id => X_Wip_Entity_Id,
               X_Operation_Seq_Num => X_Operation_Seq_Num,
               X_Organization_Id => X_Organization_Id,
               X_Repetitive_Schedule_Id => X_Repetitive_Schedule_Id,
               X_Last_Update_Date => X_Last_Update_Date,
               X_Last_Updated_By => X_Last_Updated_By,
               X_Last_Update_Login => X_Last_Update_Login,
               X_Operation_Sequence_Id => X_Operation_Sequence_Id,
               X_Standard_Operation_Id => X_Standard_Operation_Id,
               X_Department_Id => X_Department_Id,
               X_Description => X_Description,
               X_Scheduled_Quantity => X_Scheduled_Quantity,
               X_Quantity_In_Queue => X_Quantity_In_Queue,
               X_Quantity_Running => X_Quantity_Running,
               X_Quantity_Waiting_To_Move => X_Quantity_Waiting_To_Move,
               X_Quantity_Rejected => X_Quantity_Rejected,
               X_Quantity_Scrapped => X_Quantity_Scrapped,
               X_Quantity_Completed => X_Quantity_Completed,
               X_First_Unit_Start_Date => X_First_Unit_Start_Date,
               X_First_Unit_Completion_Date => X_First_Unit_Completion_Date,
               X_Last_Unit_Start_Date => X_Last_Unit_Start_Date,
               X_Last_Unit_Completion_Date => X_Last_Unit_Completion_Date,
               X_Count_Point_Type => X_Count_Point_Type,
               X_Backflush_Flag => X_Backflush_Flag,
               X_Minimum_Transfer_Quantity => X_Minimum_Transfer_Quantity,
               X_Date_Last_Moved => X_Date_Last_Moved,
               X_Progress_percentage => l_progressPercentage,
               X_Attribute_Category => X_Attribute_Category,
               X_Attribute1 => X_Attribute1,
               X_Attribute2 => X_Attribute2,
               X_Attribute3 => X_Attribute3,
               X_Attribute4 => X_Attribute4,
               X_Attribute5 => X_Attribute5,
               X_Attribute6 => X_Attribute6,
               X_Attribute7 => X_Attribute7,
               X_Attribute8 => X_Attribute8,
               X_Attribute9 => X_Attribute9,
               X_Attribute10 => X_Attribute10,
               X_Attribute11 => X_Attribute11,
               X_Attribute12 => X_Attribute12,
               X_Attribute13 => X_Attribute13,
               X_Attribute14 => X_Attribute14,
               X_Attribute15 => X_Attribute15,
															X_CHECK_SKILL => null);
  end Update_Row;

END WIP_OPERATIONS_PKG;

/
