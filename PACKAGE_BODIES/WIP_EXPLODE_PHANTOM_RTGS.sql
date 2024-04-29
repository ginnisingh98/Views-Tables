--------------------------------------------------------
--  DDL for Package Body WIP_EXPLODE_PHANTOM_RTGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_EXPLODE_PHANTOM_RTGS" AS
/* $Header: wiphrtgb.pls 120.3.12010000.2 2009/06/16 01:46:31 ankohli ship $ */

  g_line_code VARCHAR2(10) := NULL ;  -- fow flow schedule

/* *********************************************************************
                        Private functions for flow schedule
***********************************************************************/
function Charge_flow_Resources (p_txn_temp_id   in number,
                           p_comp_txn_id        in number,
                           p_org_id             in number,
                           p_phantom_item_id    in number,
                           p_op_seq_num         in number,
                           p_rtg_rev_date       in varchar2) return number is
l_org_code VARCHAR2(3);

BEGIN
  --bug 5231366
  select mp.organization_code
    into l_org_code
    from mtl_material_transactions_temp mmtt,
         mtl_parameters mp
   where mmtt.transaction_temp_id = p_txn_temp_id
     and mmtt.organization_id = mp.organization_id;

INSERT INTO WIP_COST_TXN_INTERFACE
  (transaction_id,
   last_update_date,
   last_updated_by,
   last_updated_by_name,
   creation_date,
   created_by,
   created_by_name,
   last_update_login,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   group_id,
   source_code,
   source_line_id,
   process_phase,
   process_status,
   transaction_type,
   organization_id,
   organization_code, --bug 5231366
   wip_entity_id,
   entity_type,
   primary_item_id,
   line_id,
   line_code,
   transaction_date,
   acct_period_id,
   operation_seq_num,
   department_id,
   department_code,
   employee_id,
   resource_seq_num,
   resource_id,
   resource_code,
   usage_rate_or_amount,
   basis_type,
   autocharge_type,
   standard_rate_flag,
   transaction_quantity,
   transaction_uom,
   primary_quantity,
   primary_uom,
   actual_resource_rate,
   activity_id,
   reason_id,
   reference,
   completion_transaction_id,
   po_header_id,
   po_line_id,
   repetitive_schedule_id,
   attribute_category,
   attribute1, attribute2, attribute3, attribute4, attribute5,
   attribute6, attribute7, attribute8, attribute9, attribute10,
   attribute11, attribute12,attribute13, attribute14, attribute15,
   project_id,
   task_id,
   phantom_flag
  )
   SELECT
        NULL,
        SYSDATE,
        MMTT.LAST_UPDATED_BY,
        NULL,
        SYSDATE,
        MMTT.CREATED_BY,
        NULL,
        MMTT.LAST_UPDATE_LOGIN,
        MMTT.REQUEST_ID,
        MMTT.PROGRAM_APPLICATION_ID,
        MMTT.PROGRAM_ID,
        NVL(MMTT.PROGRAM_UPDATE_DATE, SYSDATE),
        NULL,
        MMTT.SOURCE_CODE,
        MMTT.SOURCE_LINE_ID,
        2,                              -- Process_Phase
        1,                              -- Process Status
        1,                              -- transaction_type: resource
        MMTT.ORGANIZATION_ID,
        l_org_code, --bug 5231366
        MMTT.TRANSACTION_SOURCE_ID,     -- wip_entity_id
        4,                              -- Wip_Entity_Type
        wfs.primary_item_id,
        MMTT.REPETITIVE_LINE_ID,
        g_line_code,                    -- the global line code variable
        MMTT.TRANSACTION_DATE,
        MMTT.ACCT_PERIOD_ID,
        p_op_seq_num,
        BOS.DEPARTMENT_ID,
        BD.DEPARTMENT_CODE,
        NULL,                           -- employee_id
        BOR.RESOURCE_SEQ_NUM,
        BOR.RESOURCE_ID,
        BR.RESOURCE_CODE,
        BOR.USAGE_RATE_OR_AMOUNT,
        BOR.BASIS_TYPE,
        BOR.AUTOCHARGE_TYPE,
        BOR.STANDARD_RATE_FLAG,
        BOR.USAGE_RATE_OR_AMOUNT * DECODE (BOR.BASIS_TYPE,
                        1, -1*MMTT.PRIMARY_QUANTITY,
                        2, DECODE(wfs.QUANTITY_COMPLETED,
                                            0, 1,
                                            0 ),
                                   0 ),         -- transaction_quantity
        BR.UNIT_OF_MEASURE,
        BOR.USAGE_RATE_OR_AMOUNT * DECODE (BOR.BASIS_TYPE,
                        1, -1*MMTT.PRIMARY_QUANTITY,
                        2, DECODE(wfs.QUANTITY_COMPLETED,
                                            0, 1,
                                            0 ),
                                   0 ),         -- primary_quantity
        BR.UNIT_OF_MEASURE,
        NULL,                                           -- actual resource rate
        NVL(BOR.ACTIVITY_ID,-1),
        MMTT.REASON_ID,
        MMTT.TRANSACTION_REFERENCE,
        MMTT.COMPLETION_TRANSACTION_ID,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL,
        wfs.PROJECT_ID,
        wfs.TASK_ID,
        1                                       -- phantom flag
FROM
        BOM_OPERATION_RESOURCES BOR,
        WIP_FLOW_SCHEDULES  wfs,
        BOM_DEPARTMENTS BD,
        BOM_RESOURCES BR,
        CST_ACTIVITIES CA,
        BOM_OPERATION_SEQUENCES BOS,
        BOM_OPERATIONAL_ROUTINGS ROUT,
        mtl_material_transactions_temp MMTT
WHERE
        MMTT.transaction_temp_id = p_txn_temp_id
    AND MMTT.inventory_item_id = p_phantom_item_id
    AND MMTT.organization_id = p_org_id
    AND ROUT.assembly_item_id = p_phantom_item_id
    AND ROUT.organization_id = p_org_id
    AND ROUT.alternate_routing_designator is NULL
    AND ROUT.common_routing_sequence_id = bos.routing_sequence_id
    AND BOS.effectivity_date <= to_date(p_rtg_rev_date,WIP_CONSTANTS.DATETIME_FMT)
    AND NVL(BOS.disable_date, to_date(p_rtg_rev_date,WIP_CONSTANTS.DATETIME_FMT))
               >= to_date(p_rtg_rev_date,WIP_CONSTANTS.DATETIME_FMT)
    AND bos.operation_sequence_id = bor.operation_sequence_id
    AND ROUT.organization_id = bd.organization_id
    AND bos.department_id = bd.department_id
    AND ROUT.organization_id = br.organization_id
    AND bor.resource_id = br.resource_id
    AND wfs.wip_entity_id = MMTT.transaction_source_id
    AND wfs.organization_id = MMTT.organization_id
    AND bor.autocharge_type <> 2        -- not manual
    AND br.cost_element_id in (3, 4)    -- resource/osp
    AND bor.usage_rate_or_amount <> 0
    AND bos.count_point_type in (1, 2)
    AND DECODE (BOR.BASIS_TYPE,
               1, MMTT.TRANSACTION_QUANTITY,
               2, DECODE(wfs.QUANTITY_COMPLETED, 0, 1, 0 ), 0 ) <> 0
    AND bor.activity_id = ca.activity_id (+)
    AND Nvl(bos.operation_type,1) = 1;

        -- Taking care of the Activity update in two stages
        -- as we have an index on completion_txn_id
        UPDATE WIP_COST_TXN_INTERFACE
        SET ACTIVITY_ID = DECODE(ACTIVITY_ID,
                                 -1, NULL,
                                 ACTIVITY_ID)
        WHERE COMPLETION_TRANSACTION_ID = p_comp_txn_id;

        return 1;

exception
when No_Data_Found then
return 1;
when others then
 return 0;

End Charge_flow_Resources ;


function Charge_Item_Overheads(p_txn_temp_id in number,
                           p_org_id             in number,
                           p_phantom_item_id    in number,
                           p_op_seq_num         in number,
                           p_rtg_rev_date in varchar2 ) return number is
l_org_code VARCHAR2(3);
Begin
  --bug 5231366
  select mp.organization_code
    into l_org_code
    from mtl_material_transactions_temp mmtt,
         mtl_parameters mp
   where mmtt.transaction_temp_id = p_txn_temp_id
     and mmtt.organization_id = mp.organization_id;

INSERT INTO WIP_COST_TXN_INTERFACE
   (    transaction_id,
        last_update_date,
        last_updated_by,
        last_updated_by_name,
        creation_date,
        created_by,
        created_by_name,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        group_id,
        source_code,
        source_line_id,
        process_phase,
        process_status,
        transaction_type,
        organization_id,
        organization_code,  --bug 5231366
        wip_entity_id,
        entity_type,
        primary_item_id,
        line_id,
        line_code,
        transaction_date,
        acct_period_id,
        operation_seq_num,
        department_id,
        department_code,
        employee_id,
        resource_seq_num,
        resource_id,
        resource_code,
        usage_rate_or_amount,
        basis_type,
        autocharge_type,
        standard_rate_flag,
        transaction_quantity,
        transaction_uom,
        primary_quantity,
        primary_uom,
        actual_resource_rate,
        activity_id,
        reason_id,
        reference,
        completion_transaction_id,
        po_header_id,
        po_line_id,
        repetitive_schedule_id,
        attribute_category,
        attribute1, attribute2, attribute3, attribute4, attribute5,
        attribute6, attribute7, attribute8, attribute9, attribute10,
        attribute11, attribute12, attribute13, attribute14, attribute15,
        project_id,
        task_id,
        phantom_flag)
   SELECT
        NULL,
        SYSDATE,
        MMTT.LAST_UPDATED_BY,
        NULL,
        SYSDATE,
        MMTT.CREATED_BY,
        NULL,
        MMTT.LAST_UPDATE_LOGIN,
        MMTT.REQUEST_ID,
        MMTT.PROGRAM_APPLICATION_ID,
        MMTT.PROGRAM_ID,
        NVL(MMTT.PROGRAM_UPDATE_DATE, SYSDATE),
        NULL,
        MMTT.SOURCE_CODE,
        MMTT.SOURCE_LINE_ID,
        2,
        1,
        2,
        MMTT.ORGANIZATION_ID,
        l_org_code,  --bug 5231366
        MMTT.TRANSACTION_SOURCE_ID,
        4,
        wfs.primary_item_id,
        MMTT.REPETITIVE_LINE_ID,
        g_line_code,                    -- the global line code variable
        MMTT.TRANSACTION_DATE,
        MMTT.ACCT_PERIOD_ID,
        p_op_seq_num,
        BOS.DEPARTMENT_ID,
        BD.DEPARTMENT_CODE,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        1,      -- Per Item
        1,      -- WWIP_MOVE
        NULL,
        -1*NVL(MMTT.transaction_quantity, 0),
        MMTT.TRANSACTION_UOM,
        -1*NVL(MMTT.primary_quantity, 0),
        MMTT.ITEM_PRIMARY_UOM_CODE,
        NULL,
        NULL,
        MMTT.REASON_ID,
        MMTT.TRANSACTION_REFERENCE,
        MMTT.COMPLETION_TRANSACTION_ID,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL,
        wfs.PROJECT_ID,
        wfs.TASK_ID,
        1
    FROM
        BOM_DEPARTMENTS bd,
        BOM_OPERATION_SEQUENCES bos,
        WIP_FLOW_SCHEDULES wfs,
        BOM_OPERATIONAL_ROUTINGS BOR,
        mtl_material_transactions_temp mmtt
    WHERE
        MMTT.transaction_temp_id = p_txn_temp_id
    AND MMTT.transaction_source_id = wfs.wip_entity_id
    AND MMTT.organization_id = wfs.organization_Id
    AND MMTT.inventory_item_id = p_phantom_item_id
    AND MMTT.organization_id = p_org_id
    AND BOR.assembly_item_id = p_phantom_item_id
    AND BOR.organization_id = p_org_id
    AND BOR.alternate_routing_designator is NULL
    AND BOR.common_routing_sequence_id = bos.routing_sequence_id
    AND BOS.effectivity_date <= to_date(p_rtg_rev_date,WIP_CONSTANTS.DATETIME_FMT)
    AND NVL(BOS.disable_date, to_date(p_rtg_rev_date,WIP_CONSTANTS.DATETIME_FMT))
               >= to_date(p_rtg_rev_date,WIP_CONSTANTS.DATETIME_FMT)
    AND bor.organization_id = bd.organization_id
    AND bos.department_id = bd.department_id
    AND bos.count_point_type in (1, 2)  -- ovhd for autocharge operations
    AND Nvl(bos.operation_type,1) = 1;

    return 1;

exception
when No_Data_Found then
return 1;
when others then
 return 0;

end Charge_Item_Overheads;

function Charge_Lot_Overheads(p_txn_temp_id in number,
                           p_org_id             in number,
                           p_phantom_item_id    in number,
                           p_op_seq_num         in number,
                           p_rtg_rev_date in varchar2 ) return number is
l_org_code VARCHAR2(3);
Begin
  --bug 5231366
  select mp.organization_code
    into l_org_code
    from mtl_material_transactions_temp mmtt,
         mtl_parameters mp
   where mmtt.transaction_temp_id = p_txn_temp_id
     and mmtt.organization_id = mp.organization_id;

INSERT INTO WIP_COST_TXN_INTERFACE
   (    transaction_id,
        last_update_date,
        last_updated_by,
        last_updated_by_name,
        creation_date,
        created_by,
        created_by_name,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        group_id,
        source_code,
        source_line_id,
        process_phase,
        process_status,
        transaction_type,
        organization_id,
        organization_code,  --bug 5231366
        wip_entity_id,
        entity_type,
        primary_item_id,
        line_id,
        line_code,
        transaction_date,
        acct_period_id,
        operation_seq_num,
        department_id,
        department_code,
        employee_id,
        resource_seq_num,
        resource_id,
        resource_code,
        usage_rate_or_amount,
        basis_type,
        autocharge_type,
        standard_rate_flag,
        transaction_quantity,
        transaction_uom,
        primary_quantity,
        primary_uom,
        actual_resource_rate,
        activity_id,
        reason_id,
        reference,
        completion_transaction_id,
        po_header_id,
        po_line_id,
        repetitive_schedule_id,
        attribute_category,
        attribute1, attribute2, attribute3, attribute4, attribute5,
        attribute6, attribute7, attribute8, attribute9, attribute10,
        attribute11, attribute12, attribute13, attribute14, attribute15,
        project_id,
        task_id,
        phantom_flag)
   SELECT
        NULL,
        SYSDATE,
        MMTT.LAST_UPDATED_BY,
        NULL,
        SYSDATE,
        MMTT.CREATED_BY,
        NULL,
        MMTT.LAST_UPDATE_LOGIN,
        MMTT.REQUEST_ID,
        MMTT.PROGRAM_APPLICATION_ID,
        MMTT.PROGRAM_ID,
        NVL(MMTT.PROGRAM_UPDATE_DATE, SYSDATE),
        NULL,
        MMTT.SOURCE_CODE,
        MMTT.SOURCE_LINE_ID,
        2,
        1,
        2,
        MMTT.ORGANIZATION_ID,
        l_org_code,  --bug 5231366
        MMTT.TRANSACTION_SOURCE_ID,
        4,
        p_phantom_item_id,
        MMTT.REPETITIVE_LINE_ID,
        g_line_code,                    -- the global line code variable
        MMTT.TRANSACTION_DATE,
        MMTT.ACCT_PERIOD_ID,
        p_op_seq_num,
        BOS.DEPARTMENT_ID,
        BD.DEPARTMENT_CODE,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        2,      -- Per Lot
        1,      -- WWIP_MOVE
        NULL,
        DECODE( NVL(wfs.Quantity_Completed, 0),
                                0, 1,
                                0 ),
        MMTT.TRANSACTION_UOM,
        DECODE( NVL(wfs.Quantity_Completed, 0),
                                0, 1,
                                0 ),
        MMTT.ITEM_PRIMARY_UOM_CODE,
        NULL,
        NULL,
        MMTT.REASON_ID,
        MMTT.TRANSACTION_REFERENCE,
        MMTT.COMPLETION_TRANSACTION_ID,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL,
        wfs.PROJECT_ID,
        wfs.TASK_ID,
        1
    FROM
        BOM_DEPARTMENTS bd,
        BOM_OPERATION_SEQUENCES bos,
        WIP_flow_schedules wfs,
        BOM_OPERATIONAL_ROUTINGS BOR,
        mtl_material_transactions_temp mmtt
    WHERE
        MMTT.transaction_temp_id = p_txn_temp_id
    AND MMTT.transaction_source_id = wfs.wip_entity_id
    AND MMTT.organization_id = wfs.organization_Id
    AND MMTT.inventory_item_id = p_phantom_item_id
    AND BOR.assembly_item_id = p_phantom_item_id
    AND BOR.organization_id = p_org_id
    AND BOR.alternate_routing_designator is NULL
    AND BOR.common_routing_sequence_id = bos.routing_sequence_id
    AND decode( NVL(wfs.Quantity_Completed, 0),
                                0, 1,
                                0 ) <> 0
    AND BOS.effectivity_date <=
        to_date(p_rtg_rev_date,WIP_CONSTANTS.DATETIME_FMT)
    AND NVL(BOS.disable_date,
                  to_date(p_rtg_rev_date,WIP_CONSTANTS.DATETIME_FMT))
               >= to_date(p_rtg_rev_date,WIP_CONSTANTS.DATETIME_FMT)
    AND bor.organization_id = bd.organization_id
    AND bos.department_id = bd.department_id
    AND bos.count_point_type in (1, 2)  -- ovhd for autocharge operations
    AND Nvl(bos.operation_type, 1) = 1;

    return 1;

exception
when No_Data_Found then
return 1;

when others then
 return 0;

end Charge_Lot_Overheads;

procedure explode_resources(
    p_wip_entity_id     in number,
    p_sched_id          in number,
    p_org_id            in number,
    p_entity_type       in number,
    p_phantom_item_id   in number,
    p_op_seq_num        in number,
    p_rtg_rev_date      in date) IS

    /* local variables */
    x_last_update_date  date;
    x_last_updated_by   number;
    x_creation_date     date;
    x_created_by        number;
    x_last_update_login number;
    x_request_id        number;
    x_program_application_id number;
    x_program_id        number;
    x_program_update_date date;

    x_max_resc_seq_num  number := 0;
    x_uom_code          varchar2(3);
    x_applied_resource_units number := 0;
    x_applied_resource_value number := 0;
    x_start_date        date;
    x_completion_date   date;

    x_comp_qty          number ;
    x_yield_factor      number ;

    /*Fixed Bug# 1818055 */

   /* Fixed Bug 5366856. Added COMPONENT_YIELD_FACTOR in Cursor SQL to consider yield
      while exploding resources for phantom assemblies. */

   CURSOR  phan_comp_qty
   IS
   SELECT WRO.QUANTITY_PER_ASSEMBLY,WRO.COMPONENT_YIELD_FACTOR
   FROM   WIP_REQUIREMENT_OPERATIONS WRO
   WHERE  WRO.WIP_ENTITY_ID = p_wip_entity_id
   AND    WRO.INVENTORY_ITEM_ID = p_phantom_item_id
   AND    WRO.OPERATION_SEQ_NUM = -p_op_seq_num
   AND    WRO.ORGANIZATION_ID   = p_org_id
   AND    ((WRO.REPETITIVE_SCHEDULE_ID = p_sched_id ) or (WRO.REPETITIVE_SCHEDULE_ID is null));



    CURSOR phan_resc_cursor(p_rtg_revision_date date) IS
    SELECT BOR.resource_id ,
           BOR.activity_id ,
           BOR.standard_rate_flag ,
           BOR.assigned_units ,
           BOR.usage_rate_or_amount ,
           BOR.basis_type ,
           BOR.autocharge_type ,
           BOS.operation_seq_num phantom_op_seq_num,
           BOS.department_id
     FROM
           MTL_UOM_CONVERSIONS CON,
           BOM_RESOURCES BR,
           BOM_OPERATION_RESOURCES BOR,
           BOM_DEPARTMENT_RESOURCES BDR1,
           BOM_DEPARTMENT_RESOURCES BDR2,
           BOM_OPERATION_SEQUENCES BOS,
           BOM_OPERATIONAL_ROUTINGS BRTG,
           MTL_SYSTEM_ITEMS msi
    WHERE
           BRTG.organization_id = p_org_id
      and  BRTG.assembly_item_id = p_phantom_item_id
      and  BRTG.organization_id  = msi.organization_id
      and  BRTG.assembly_item_id = msi.inventory_item_id
      and  msi.bom_item_type     not in ( 1, 2) /* Exclude AIO Model and option class */
      and  NVL(BRTG.cfm_routing_flag, 2) = 2      /* not a flow routing */
      and  BRTG.alternate_routing_designator IS NULL    /* primary routing */
      and  BRTG.common_routing_sequence_id = BOS.routing_sequence_id
      and  BOS.effectivity_date  <= p_rtg_revision_date
      and  NVL(operation_type, 1) = 1
      and  NVL(BOS.disable_date, p_rtg_revision_date+ 2) >= p_rtg_revision_date
      and  BOS.department_id = BDR1.department_id
      AND  NVL(BDR1.share_from_dept_id, BDR1.department_id) = BDR2.department_id
      and  BOR.resource_id = BDR1.resource_id
      AND  BOR.resource_id = BDR2.resource_id
      and  BOR.operation_sequence_id = BOS.operation_sequence_id
      AND  BOR.resource_id = BR.resource_id
      AND  CON.UOM_CODE (+) = BR.UNIT_OF_MEASURE
      AND  CON.INVENTORY_ITEM_ID (+) = 0
      AND  NVL(BOR.acd_type,0) <> 3 --bug 7315072 (FP 7272795): inserting resources that are not disabled
    ORDER  BY BOS.operation_seq_num,
              BOR.resource_seq_num ;


  BEGIN


    /* -------------------------------------------------------------*
     * get current max resource_seq_num and who columns information *
     * from resources in main routing, for the operation            *
     * The two select clauses can not be combined into one because  *
     * of the MAX function
     * -------------------------------------------------------------*/
    SELECT max(resource_seq_num)
      INTO x_max_resc_seq_num
      FROM WIP_OPERATION_RESOURCES
     WHERE wip_entity_id = p_wip_entity_id
       and organization_id = p_org_id
       and NVL(repetitive_schedule_id, -1) =
                DECODE(p_entity_type, WIP_CONSTANTS.REPETITIVE, p_sched_id,-1)
       and operation_seq_num = p_op_seq_num;

    if x_max_resc_seq_num is null then
        x_max_resc_seq_num := 0;
    end if;

    begin
    SELECT last_update_date, last_updated_by, creation_date,
           created_by, last_update_login, request_id,
           program_application_id, program_id, program_update_date
      INTO x_last_update_date, x_last_updated_by, x_creation_date,
           x_created_by, x_last_update_login, x_request_id,
           x_program_application_id, x_program_id, x_program_update_date
      FROM WIP_OPERATION_RESOURCES
     WHERE wip_entity_id = p_wip_entity_id
       and organization_id = p_org_id
       and NVL(repetitive_schedule_id, -1) =
                DECODE(p_entity_type, WIP_CONSTANTS.REPETITIVE, p_sched_id,-1)
       and resource_seq_num = x_max_resc_seq_num
       and operation_seq_num = p_op_seq_num;

    exception
        when no_data_found then
             x_last_update_date := SYSDATE;
             x_last_updated_by  := FND_GLOBAL.USER_ID ;
             x_creation_date    := SYSDATE;
             x_created_by       := FND_GLOBAL.USER_ID;
             x_last_update_login := FND_GLOBAL.LOGIN_ID;
             x_request_id       := FND_GLOBAL.CONC_REQUEST_ID;
             x_program_application_id := FND_GLOBAL.PROG_APPL_ID;
             x_program_id       := FND_GLOBAL.CONC_PROGRAM_ID;
             x_program_update_date := SYSDATE;

    end;
    /* --------------------------------------------------------- *
     * get date information from operation                       *
     * ----------------------------------------------------------*/

    SELECT first_unit_start_date, last_unit_completion_date
      INTO x_start_date, x_completion_date
      FROM WIP_OPERATIONS
     WHERE wip_entity_id = p_wip_entity_id
        AND organization_id = p_org_id
       and NVL(repetitive_schedule_id, -1) =
                DECODE(p_entity_type, WIP_CONSTANTS.REPETITIVE, p_sched_id,-1)
       AND operation_seq_num = p_op_seq_num;

    /* --------------------------------------------------------- *
     * GO through the cursor. Populate phantom resources         *
     * information to WIP_OPERATION_RESOURCES                    *
     * ----------------------------------------------------------*/

    FOR cur_resc IN phan_resc_cursor(p_rtg_rev_date) LOOP

        /* set resource_seq_num to be unique */
        x_max_resc_seq_num := x_max_resc_seq_num + 10;

        /* get UOM_code */
        select unit_of_measure
          into x_uom_code
          from BOM_RESOURCES
         where resource_id = cur_resc.resource_id;

       /* Bug 1691488 */

       /* Fixed Bug 5366856. Fetching COMPONENT_YIELD_FACTOR from Cursor to consider yield
          while exploding resources for phantom assemblies. */

        OPEN phan_comp_qty ;
        FETCH phan_comp_qty into x_comp_qty,x_yield_factor ;
        CLOSE phan_comp_qty ;

        /* insert phantom resources */
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
                request_id,
                program_application_id,
                program_id,
                program_update_date,
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
                department_id,
                phantom_flag,
                phantom_op_seq_num,
                phantom_item_id)
        VALUES(
                p_wip_entity_id,
                p_op_seq_num,
                x_max_resc_seq_num,
                p_org_id,
                DECODE(p_sched_id, 0, null, p_sched_id),
                x_last_update_date,
                x_last_updated_by,
                x_creation_date,
                x_created_by,
                x_last_update_login,
                x_request_id,
                x_program_application_id,
                x_program_id,
                x_program_update_date,
                cur_resc.resource_id,
                x_uom_code,
                cur_resc.basis_type,
				/*Fixed Bug 5366856. Modified to consider yield factor for resources.
				  Lot based resources should be independent of Yield and QPA.
				  Item based Phantom resources should consider yield and QPA. */
                decode(cur_resc.basis_type, wip_constants.PER_LOT , cur_resc.usage_rate_or_amount,
                                                                    round((cur_resc.usage_rate_or_amount * nvl(x_comp_qty, 1)/nvl(x_yield_factor,1)),
																	       wip_constants.max_displayed_precision)),/* Bug# 2115415 */
                cur_resc.activity_id,
                2,              /* non-scheduled */
                cur_resc.assigned_units,
                cur_resc.autocharge_type,
                cur_resc.standard_rate_flag,
                x_applied_resource_units,
                x_applied_resource_value,
                x_start_date,
                x_completion_date,
                cur_resc.department_id,
                1,              /* phantom_flag = YES */
                cur_resc.phantom_op_seq_num,
                p_phantom_item_id);

     END LOOP;

exception
when No_Data_Found then
null;

when others then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END explode_resources;

  /* public function */
function charge_flow_resource_ovhd(
    p_org_id            in number,
    p_phantom_item_id   in number,
    p_op_seq_num        in number,
    p_comp_txn_id       in number,
    p_txn_temp_id       in number,
    p_line_id           in number,
    p_rtg_rev_date      in varchar2) return number IS

  x_success number := 0;

  BEGIN

        begin
         select line_code into g_line_code
         from wip_lines
         where line_id = p_line_id ;

        exception
          when no_data_found then
            g_line_code := null ;
        end ;

        x_success := Charge_flow_Resources(p_txn_temp_id,
                                        p_comp_txn_id,
                                        p_org_id,
                                        p_phantom_item_id,
                                        p_op_seq_num,
                                        p_rtg_rev_date);

        if (x_success<>0) then
                x_success := Charge_Item_Overheads(p_txn_temp_id,
                                        p_org_id,
                                        p_phantom_item_id,
                                        p_op_seq_num,
                                        p_rtg_rev_date );
                if (x_success<>0) then
                   x_success := Charge_Lot_Overheads(p_txn_temp_id,
                                        p_org_id,
                                        p_phantom_item_id,
                                        p_op_seq_num,
                                        p_rtg_rev_date );
                else
                   return x_success ;
                end if;
        else
                return x_success ;
        end if;

     return 1;

     exception
     when No_Data_Found then
        return 1;
     when others then
        return 0;

END charge_flow_resource_ovhd;

END WIP_EXPLODE_PHANTOM_RTGS;

/
