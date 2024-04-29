--------------------------------------------------------
--  DDL for Package Body WIP_OPERATION_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_OPERATION_RESOURCES_PKG" AS
/* $Header: wiporesb.pls 120.1 2005/06/20 14:46:44 appldev ship $ */

  procedure add_resource(
    p_org_id             in  number,
    p_wip_entity_id      in  number,
    p_first_schedule_id  in  number,
    p_operation_seq_num  in  number,
    p_resource_seq_num   in  number,
    p_resource_id        in  number,
    p_uom_code           in  varchar2,
    p_basis_type         in  number,
    p_activity_id        in  number,
    p_standard_rate_flag in  number,
    p_start_date         in  date,
    p_completion_date    in  date) is
    x_user_id       number  := FND_GLOBAL.USER_ID;
    x_login_id      number  := FND_GLOBAL.LOGIN_ID;
    x_check_for_dup boolean := FALSE;
  begin
    -- insert operation resource record
    begin
      insert into wip_operation_resources(
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        organization_id,
        wip_entity_id,
        repetitive_schedule_id,
        operation_seq_num,
        resource_seq_num,
        resource_id,
        uom_code,
        basis_type,
        activity_id,
        standard_rate_flag,
        usage_rate_or_amount,
        scheduled_flag,
        assigned_units,
        autocharge_type,
        applied_resource_units,
        applied_resource_value,
        start_date,
        completion_date
      ) values (
        SYSDATE,
        x_user_id,
        SYSDATE,
        x_user_id,
        x_login_id,
        p_org_id,
        p_wip_entity_id,
        p_first_schedule_id,
        p_operation_seq_num,
        p_resource_seq_num,
        p_resource_id,
        p_uom_code,
        nvl(p_basis_type, WIP_CONSTANTS.PER_LOT),
        p_activity_id,
        p_standard_rate_flag,
        0,                    -- usage_rate_or_amount
        WIP_CONSTANTS.NO,     -- scheduled_flag
        1,                    -- assigned_units
        WIP_CONSTANTS.MANUAL, -- autocharge_type
        0,                    -- applied_resource_units
        0,                    -- applied_resource_value
        p_start_date,
        p_completion_date);

    exception
      when DUP_VAL_ON_INDEX then
        x_check_for_dup := TRUE;
    end;

    if (x_check_for_dup) then
      -- the primary key already exists, so check to see
      -- if the old record matches the new record.
      declare
        cursor get_ident_resource(
          c_org_id            number,
          c_wip_entity_id     number,
          c_operation_seq_num number,
          c_resource_seq_num  number,
          c_first_schedule_id number,
          c_resource_id       number) is
        select 'X'
        from   dual
        where  c_resource_id =
          (select resource_id
           from   wip_operation_resources
           where  organization_id = c_org_id
           and    wip_entity_id = c_wip_entity_id
           and    operation_seq_num = c_operation_seq_num
           and    resource_seq_num = c_resource_seq_num
           and    nvl(repetitive_schedule_id,-1) = nvl(c_first_schedule_id,-1));

        x_dummy varchar2(1);
        x_found boolean;
      begin
        open get_ident_resource(
          c_org_id            => p_org_id,
          c_wip_entity_id     => p_wip_entity_id,
          c_operation_seq_num => p_operation_seq_num,
          c_resource_seq_num  => p_resource_seq_num,
          c_first_schedule_id => p_first_schedule_id,
          c_resource_id       => p_resource_id);
        fetch get_ident_resource into x_dummy;
        x_found := get_ident_resource%FOUND;
        close get_ident_resource;

        if (not x_found) then
          fnd_message.set_name(
            application => 'WIP',
            name        => 'WIP_MISMATCHED_RES');
          fnd_message.raise_error;
        end if;
      end;
    end if;

    return;

  exception
    when OTHERS then
      wip_constants.get_ora_error(
        application => 'WIP',
        proc_name   => 'WIP_OPERATION_RESOURCES_PKG.ADD_RESOURCE');
      fnd_message.raise_error;
  end add_resource;

  procedure check_dup_resources(
    p_group_id          in  number,
    p_operation_seq_num out nocopy number,
    p_resource_seq_num  out nocopy number,
    p_dup_exists        out nocopy boolean) is

  cursor get_dup_res(c_group_id number) is
  select wcti1.operation_seq_num,
         wcti1.resource_seq_num
  from   wip_cost_txn_interface wcti1,
         wip_cost_txn_interface wcti2
  where  wcti1.source_code = 'NEW_RES'
  and    wcti1.group_id = c_group_id
  and    wcti1.source_code = wcti2.source_code
  and    wcti1.group_id = wcti2.group_id
  and    wcti1.wip_entity_id = wcti2.wip_entity_id
  and    wcti1.operation_seq_num = wcti2.operation_seq_num
  and    wcti1.resource_seq_num = wcti2.resource_seq_num
  and    wcti1.organization_id = wcti2.organization_id
  and    nvl(wcti1.repetitive_schedule_id, -1)
           = nvl(wcti2.repetitive_schedule_id, -1)
  and    wcti1.resource_id <> wcti2.resource_id;

  begin
    -- get any added resources that have been duplicated
    open get_dup_res(c_group_id => p_group_id);
    fetch get_dup_res into p_operation_seq_num, p_resource_seq_num;
    p_dup_exists := get_dup_res%FOUND;
    close get_dup_res;
  end check_dup_resources;

  procedure add_resources(p_group_id in number) is
  begin
    -- add resources from interface table
    -- note: if adding op on the fly, then this procedure should only be called
    -- after the new op has been added to wip_operations
    insert into wip_operation_resources(
      organization_id,
      wip_entity_id,
      repetitive_schedule_id,
      operation_seq_num,
      resource_seq_num,
      resource_id,
      uom_code,
      basis_type,
      activity_id,
      standard_rate_flag,
      usage_rate_or_amount,
      scheduled_flag,
      assigned_units,
      autocharge_type,
      applied_resource_units,
      applied_resource_value,
      start_date,
      completion_date,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login)
    select distinct
      wcti.organization_id,
      wcti.wip_entity_id,
      wcti.repetitive_schedule_id,
      wcti.operation_seq_num,
      wcti.resource_seq_num,
      wcti.resource_id,
      wcti.primary_uom,
      nvl(wcti.basis_type, WIP_CONSTANTS.PER_LOT),
      nvl(wcti.activity_id , br.default_activity_id),
      wcti.standard_rate_flag,
      0,                    -- usage_rate_or_amount
      WIP_CONSTANTS.NO,     -- scheduled_flag
      1,                    -- assigned_units
      WIP_CONSTANTS.MANUAL, -- autocharge_type
      0,                    -- applied_resource_units
      0,                    -- applied_resource_value
      wo.first_unit_start_date,
      wo.last_unit_completion_date,
      SYSDATE,
      wcti.last_updated_by,
      SYSDATE,
      wcti.created_by,
      wcti.last_update_login
    from  bom_resources br,
          wip_operations wo,
          wip_cost_txn_interface wcti
    where wcti.source_code = 'NEW_RES'
    and   wcti.group_id = p_group_id
    and   wcti.organization_id = wo.organization_id
    and   wcti.wip_entity_id = wo.wip_entity_id
    and   wcti.operation_seq_num = wo.operation_seq_num
    and   wcti.resource_id = br.resource_id
    and   nvl(wcti.repetitive_schedule_id, -1)
            = nvl(wo.repetitive_schedule_id, -1);

    -- delete txn qty = NULL records that are used for adding resources
    -- changed condition from txn qty = 0 to txn qty is null for bug # 661593
    delete from wip_cost_txn_interface
    where group_id = p_group_id
    and   transaction_quantity is NULL;

    -- clean up interface
    update wip_cost_txn_interface
    set source_code = NULL  -- clear source code to remove NEW_RES message
    where group_id = p_group_id;
  end add_resources;

  FUNCTION CHECK_PO_AND_REQ(
        p_org_id                IN  NUMBER,
        p_wip_entity_id         IN  NUMBER,
        p_operation_seq_num     IN  NUMBER,
        p_resource_seq_num      IN  NUMBER,
        p_rep_sched_id          IN  NUMBER) RETURN BOOLEAN IS

    CURSOR disc_check_po_req_cur IS
        SELECT 'No PO/REQ Linked'
        FROM   DUAL
        WHERE  NOT EXISTS
               (SELECT '1'
                FROM   PO_DISTRIBUTIONS_ALL PD,
                       WIP_OPERATION_RESOURCES WOR
                       /* Fixed bug 3115844 */
                WHERE  pd.po_line_id IS NOT NULL
                  AND  pd.line_location_id IS NOT NULL
                  AND  WOR.WIP_ENTITY_ID = PD.WIP_ENTITY_ID
                  AND  WOR.ORGANIZATION_ID = PD.DESTINATION_ORGANIZATION_ID
                  AND  WOR.OPERATION_SEQ_NUM = PD.WIP_OPERATION_SEQ_NUM
                  AND  WOR.RESOURCE_SEQ_NUM = PD.WIP_RESOURCE_SEQ_NUM
                  AND  WOR.WIP_ENTITY_ID = p_wip_entity_id
                  AND  WOR.ORGANIZATION_ID = p_org_id
                  AND  WOR.OPERATION_SEQ_NUM = p_operation_seq_num
                  AND  WOR.RESOURCE_SEQ_NUM = p_resource_seq_num)
          AND  NOT EXISTS
               (SELECT '1'
                FROM   PO_REQUISITION_LINES_ALL PRL,
                       WIP_OPERATION_RESOURCES WOR
                WHERE  WOR.WIP_ENTITY_ID = PRL.WIP_ENTITY_ID
                  AND  WOR.ORGANIZATION_ID = PRL.DESTINATION_ORGANIZATION_ID
                  AND  WOR.OPERATION_SEQ_NUM = PRL.WIP_OPERATION_SEQ_NUM
                  AND  WOR.RESOURCE_SEQ_NUM = PRL.WIP_RESOURCE_SEQ_NUM
                  AND  WOR.WIP_ENTITY_ID = p_wip_entity_id
                  AND  WOR.ORGANIZATION_ID = p_org_id
                  AND  WOR.OPERATION_SEQ_NUM = p_operation_seq_num
                  AND  WOR.RESOURCE_SEQ_NUM = p_resource_seq_num)
          AND  NOT EXISTS
               (SELECT '1'
                FROM   PO_REQUISITIONS_INTERFACE_ALL PRI,
                       WIP_OPERATION_RESOURCES WOR
                WHERE  WOR.WIP_ENTITY_ID = PRI.WIP_ENTITY_ID
                  AND  WOR.ORGANIZATION_ID = PRI.DESTINATION_ORGANIZATION_ID
                  AND  WOR.OPERATION_SEQ_NUM = PRI.WIP_OPERATION_SEQ_NUM
                  AND  WOR.RESOURCE_SEQ_NUM = PRI.WIP_RESOURCE_SEQ_NUM
                  AND  WOR.WIP_ENTITY_ID = p_wip_entity_id
                  AND  WOR.ORGANIZATION_ID = p_org_id
                  AND  WOR.OPERATION_SEQ_NUM = p_operation_seq_num
                  AND  WOR.RESOURCE_SEQ_NUM = p_resource_seq_num);

    CURSOR rep_check_po_req_cur IS
        SELECT 'No PO/REQ Linked'
        FROM   DUAL
        WHERE  NOT EXISTS
               (SELECT '1'
                FROM   PO_DISTRIBUTIONS_ALL PD,
                       WIP_OPERATION_RESOURCES WOR
                       /* Fixed bug 3115844 */
                WHERE  pd.po_line_id IS NOT NULL
                  AND  pd.line_location_id IS NOT NULL
                  AND  WOR.WIP_ENTITY_ID = PD.WIP_ENTITY_ID
                  AND  WOR.ORGANIZATION_ID = PD.DESTINATION_ORGANIZATION_ID
                  AND  WOR.OPERATION_SEQ_NUM = PD.WIP_OPERATION_SEQ_NUM
                  AND  WOR.RESOURCE_SEQ_NUM = PD.WIP_RESOURCE_SEQ_NUM
                  AND  WOR.REPETITIVE_SCHEDULE_ID =
                       PD.WIP_REPETITIVE_SCHEDULE_ID
                  AND  WOR.WIP_ENTITY_ID = p_wip_entity_id
                  AND  WOR.ORGANIZATION_ID = p_org_id
                  AND  WOR.OPERATION_SEQ_NUM = p_operation_seq_num
                  AND  WOR.RESOURCE_SEQ_NUM = p_resource_seq_num
                  AND  WOR.REPETITIVE_SCHEDULE_ID = p_rep_sched_id)
          AND  NOT EXISTS
               (SELECT '1'
                FROM   PO_REQUISITION_LINES_ALL PRL,
                       WIP_OPERATION_RESOURCES WOR
                WHERE  WOR.WIP_ENTITY_ID = PRL.WIP_ENTITY_ID
                  AND  WOR.ORGANIZATION_ID = PRL.DESTINATION_ORGANIZATION_ID
                  AND  WOR.OPERATION_SEQ_NUM = PRL.WIP_OPERATION_SEQ_NUM
                  AND  WOR.RESOURCE_SEQ_NUM = PRL.WIP_RESOURCE_SEQ_NUM
                  AND  WOR.REPETITIVE_SCHEDULE_ID =
                       PRL.WIP_REPETITIVE_SCHEDULE_ID
                  AND  WOR.WIP_ENTITY_ID = p_wip_entity_id
                  AND  WOR.ORGANIZATION_ID = p_org_id
                  AND  WOR.OPERATION_SEQ_NUM = p_operation_seq_num
                  AND  WOR.RESOURCE_SEQ_NUM = p_resource_seq_num
                  AND  WOR.REPETITIVE_SCHEDULE_ID = p_rep_sched_id)
          AND  NOT EXISTS
               (SELECT '1'
                FROM   PO_REQUISITIONS_INTERFACE_ALL PRI,
                       WIP_OPERATION_RESOURCES WOR
                WHERE  WOR.WIP_ENTITY_ID = PRI.WIP_ENTITY_ID
                  AND  WOR.ORGANIZATION_ID = PRI.DESTINATION_ORGANIZATION_ID
                  AND  WOR.OPERATION_SEQ_NUM = PRI.WIP_OPERATION_SEQ_NUM
                  AND  WOR.RESOURCE_SEQ_NUM = PRI.WIP_RESOURCE_SEQ_NUM
                  AND  WOR.REPETITIVE_SCHEDULE_ID =
                       PRI.WIP_REPETITIVE_SCHEDULE_ID
                  AND  WOR.WIP_ENTITY_ID = p_wip_entity_id
                  AND  WOR.ORGANIZATION_ID = p_org_id
                  AND  WOR.OPERATION_SEQ_NUM = p_operation_seq_num
                  AND  WOR.RESOURCE_SEQ_NUM = p_resource_seq_num
                  AND  WOR.REPETITIVE_SCHEDULE_ID = p_rep_sched_id);

    po_req_exist        VARCHAR2(20);

  BEGIN
    -- Check for POs and REQs linked to resource
    IF p_rep_sched_id IS NULL THEN
      OPEN disc_check_po_req_cur;
      FETCH disc_check_po_req_cur INTO po_req_exist;

      IF (disc_check_po_req_cur%NOTFOUND) THEN
        CLOSE disc_check_po_req_cur;
        RETURN FALSE;
      ELSE
        CLOSE disc_check_po_req_cur;
      END IF;
    ELSE
      OPEN rep_check_po_req_cur;
      FETCH rep_check_po_req_cur INTO po_req_exist;

      IF (rep_check_po_req_cur%NOTFOUND) THEN
        CLOSE rep_check_po_req_cur;
        RETURN FALSE;
      ELSE
        CLOSE rep_check_po_req_cur;
      END IF;
    END IF;

    RETURN TRUE;

  END CHECK_PO_AND_REQ;


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Resource_Seq_Num               NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Repetitive_Schedule_Id         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Resource_Id                    NUMBER,
                       X_Uom_Code                       VARCHAR2,
                       X_Basis_Type                     NUMBER,
                       X_Usage_Rate_Or_Amount           NUMBER,
                       X_Activity_Id                    NUMBER,
                       X_Scheduled_Flag                 NUMBER,
                       X_Assigned_Units                 NUMBER,
                       X_Autocharge_Type                NUMBER,
                       X_Standard_Rate_Flag             NUMBER,
                       X_Applied_Resource_Units         NUMBER,
                       X_Applied_Resource_Value         NUMBER,
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
                       X_Completion_Date                DATE,
                       X_Start_Date                     DATE,
                       X_Schedule_Seq_Num               NUMBER,
                       X_Substitute_Group_Num           NUMBER,
                       X_Replacement_Group_Num          NUMBER,
                       X_Parent_Resource_Seq            NUMBER,
                       X_SetUp_Id                       NUMBER DEFAULT NULL
   ) IS
     CURSOR C IS SELECT rowid FROM WIP_OPERATION_RESOURCES
                 WHERE wip_entity_id = X_Wip_Entity_Id
                 AND   organization_id = X_Organization_Id
                 AND   operation_seq_num = X_Operation_Seq_Num
                 AND   resource_seq_num = X_Resource_Seq_Num
                 AND   (repetitive_Schedule_id = X_Repetitive_Schedule_Id
                        OR (repetitive_schedule_id IS NULL
                             AND X_Repetitive_Schedule_Id IS NULL));

    BEGIN
       INSERT INTO WIP_OPERATION_RESOURCES(
               wip_entity_id,
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
               parent_resource_seq,
               setup_id
             ) VALUES (
               X_Wip_Entity_Id,
               X_Operation_Seq_Num,
               X_Resource_Seq_Num,
               X_Organization_Id,
               X_Repetitive_Schedule_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
               X_Resource_Id,
               X_Uom_Code,
               X_Basis_Type,
               X_Usage_Rate_Or_Amount,
               X_Activity_Id,
               X_Scheduled_Flag,
               X_Assigned_Units,
               X_Autocharge_Type,
               X_Standard_Rate_Flag,
               X_Applied_Resource_Units,
               X_Applied_Resource_Value,
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
               X_Completion_Date,
               X_Start_Date,
               X_Schedule_Seq_Num,
               X_Substitute_Group_Num,
               X_Replacement_Group_Num,
               X_Parent_Resource_Seq,
               X_SetUp_Id
             );

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
                     X_Resource_Seq_Num                 NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Repetitive_Schedule_Id           NUMBER,
                     X_Resource_Id                      NUMBER,
                     X_Uom_Code                         VARCHAR2,
                     X_Basis_Type                       NUMBER,
                     X_Usage_Rate_Or_Amount             NUMBER,
                     X_Activity_Id                      NUMBER,
                     X_Scheduled_Flag                   NUMBER,
                     X_Assigned_Units                   NUMBER,
                     X_Autocharge_Type                  NUMBER,
                     X_Standard_Rate_Flag               NUMBER,
                     X_Applied_Resource_Units           NUMBER,
                     X_Applied_Resource_Value           NUMBER,
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
                     X_Completion_Date                  DATE,
                     X_Start_Date                       DATE,
                     X_Schedule_Seq_Num                 NUMBER,
                     X_Substitute_Group_Num             NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   WIP_OPERATION_RESOURCES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Wip_Entity_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      FND_MESSAGE.raise_error;
      APP_EXCEPTION.raise_exception;
    end if;
    CLOSE C;
    if (

               (Recinfo.wip_entity_id = X_Wip_Entity_Id)
           AND (Recinfo.operation_seq_num = X_Operation_Seq_Num)
           AND (Recinfo.resource_seq_num = X_Resource_Seq_Num)
           AND (Recinfo.organization_id = X_Organization_Id)
           AND (   (Recinfo.repetitive_schedule_id = X_Repetitive_Schedule_Id)
                OR (    (Recinfo.repetitive_schedule_id IS NULL)
                    AND (X_Repetitive_Schedule_Id IS NULL)))
           AND (Recinfo.resource_id = X_Resource_Id)
           AND (   (Recinfo.uom_code = X_Uom_Code)
                OR (    (Recinfo.uom_code IS NULL)
                    AND (X_Uom_Code IS NULL)))
           AND (Recinfo.basis_type = X_Basis_Type)
           AND (ROUND(Recinfo.usage_rate_or_amount, 6) = X_Usage_Rate_Or_Amount)
           AND (   (Recinfo.activity_id = X_Activity_Id)
                OR (    (Recinfo.activity_id IS NULL)
                    AND (X_Activity_Id IS NULL)))
           AND (Recinfo.scheduled_flag = X_Scheduled_Flag)
           AND (   (Recinfo.assigned_units = X_Assigned_Units)
                OR (    (Recinfo.assigned_units IS NULL)
                    AND (X_Assigned_Units IS NULL)))
           AND (Recinfo.autocharge_type = X_Autocharge_Type)
           AND (Recinfo.standard_rate_flag = X_Standard_Rate_Flag)
           AND (Recinfo.applied_resource_units = X_Applied_Resource_Units)
           AND (Recinfo.applied_resource_value = X_Applied_Resource_Value)
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
           AND (   (Recinfo.schedule_seq_num = X_Schedule_Seq_Num)
                OR (    (Recinfo.Schedule_Seq_Num IS NULL)
                    AND (X_Schedule_Seq_Num IS NULL)))
           AND (   (Recinfo.substitute_group_num = X_Substitute_Group_Num)
                OR (    (Recinfo.Substitute_Group_Num IS NULL)
                    AND (X_Substitute_Group_Num IS NULL)))
           AND (Recinfo.completion_date = X_Completion_Date)
           AND (Recinfo.start_date = X_Start_Date)

            ) then
      return;
    else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        FND_MESSAGE.raise_error;
        APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Resource_Seq_Num               NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Repetitive_Schedule_Id         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Resource_Id                    NUMBER,
                       X_Uom_Code                       VARCHAR2,
                       X_Basis_Type                     NUMBER,
                       X_Usage_Rate_Or_Amount           NUMBER,
                       X_Activity_Id                    NUMBER,
                       X_Scheduled_Flag                 NUMBER,
                       X_Assigned_Units                 NUMBER,
                       X_Autocharge_Type                NUMBER,
                       X_Standard_Rate_Flag             NUMBER,
                       X_Applied_Resource_Units         NUMBER,
                       X_Applied_Resource_Value         NUMBER,
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
                       X_Completion_Date                DATE,
                       X_Start_Date                     DATE,
                       X_Schedule_Seq_Num               NUMBER,
                       X_Substitute_Group_Num           NUMBER,
                       X_Replacement_Group_Num          NUMBER,
                       X_Parent_Resource_Seq            NUMBER,
                       X_SetUp_Id                       NUMBER DEFAULT NULL
 ) IS
 BEGIN
   UPDATE WIP_OPERATION_RESOURCES
   SET
     wip_entity_id                     =     X_Wip_Entity_Id,
     operation_seq_num                 =     X_Operation_Seq_Num,
     resource_seq_num                  =     X_Resource_Seq_Num,
     organization_id                   =     X_Organization_Id,
     repetitive_schedule_id            =     X_Repetitive_Schedule_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     resource_id                       =     X_Resource_Id,
     uom_code                          =     X_Uom_Code,
     basis_type                        =     X_Basis_Type,
     usage_rate_or_amount              =     X_Usage_Rate_Or_Amount,
     activity_id                       =     X_Activity_Id,
     scheduled_flag                    =     X_Scheduled_Flag,
     assigned_units                    =     X_Assigned_Units,
     autocharge_type                   =     X_Autocharge_Type,
     standard_rate_flag                =     X_Standard_Rate_Flag,
     applied_resource_units            =     X_Applied_Resource_Units,
     applied_resource_value            =     X_Applied_Resource_Value,
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
     completion_date                   =     X_Completion_Date,
     start_date                        =     X_Start_Date,
     schedule_seq_num                  =     X_Schedule_Seq_Num,
     substitute_group_num              =     X_Substitute_Group_Num,
     replacement_group_num             =     X_Replacement_Group_Num,
     parent_resource_seq               =     X_Parent_Resource_Seq,
     setup_id                          =     X_SetUp_Id
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM WIP_OPERATION_RESOURCES
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END WIP_OPERATION_RESOURCES_PKG;

/
