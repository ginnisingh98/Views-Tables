--------------------------------------------------------
--  DDL for Package Body WSM_JOBCOPIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_JOBCOPIES_PVT" AS
/* $Header: WSMVCPYB.pls 120.23.12010000.3 2009/07/14 09:48:44 adasa ship $ */

/*-------------------------------------------------------------+
| Name : Get_Job_Curr_Op_Info
---------------------------------------------------------------*/
--OPTII-PERF: Following tables are added to store max res seq num
--for each op seq id.
type t_job_res  is table of NUMBER index by binary_integer;

v_res_seq       t_job_res;
v_op_seq_id     t_job_res;
v_max_res_seq   t_job_res;


PROCEDURE Get_Job_Curr_Op_Info(p_wip_entity_id IN  NUMBER,
                               p_op_seq_num    OUT NOCOPY NUMBER, -- max operation where qty exists
                               p_op_seq_id     OUT NOCOPY NUMBER,
                               p_std_op_id     OUT NOCOPY NUMBER,
                               p_dept_id       OUT NOCOPY NUMBER,
                               p_intra_op      OUT NOCOPY NUMBER, -- intra-op where qty exists
                               p_op_qty        OUT NOCOPY NUMBER, -- qty available to transact
                               p_op_start_date OUT NOCOPY DATE,
                               p_op_comp_date  OUT NOCOPY DATE,
                               x_err_code      OUT NOCOPY NUMBER,
                               x_err_buf       OUT NOCOPY VARCHAR2)
IS
    l_stmt_num  NUMBER;
    l_qty_Q     NUMBER;
    l_qty_RUN   NUMBER;
    l_qty_TM    NUMBER;
    l_qty_SCR   NUMBER;
    l_temp      NUMBER;

BEGIN

    p_op_seq_num    := NULL;
    p_op_seq_id     := NULL;
    p_std_op_id     := NULL;
    p_dept_id       := NULL;
    p_intra_op      := NULL;
    p_op_qty        := NULL;

    l_stmt_num := 10;

    SELECT max(operation_seq_num)
    INTO   p_op_seq_num
    FROM   wip_operations
    WHERE  wip_entity_id = p_wip_entity_id
    AND   ((quantity_in_queue <> 0
            OR quantity_running <> 0
            OR quantity_waiting_to_move <> 0)
          OR (quantity_in_queue = 0
              and quantity_running = 0
              and quantity_waiting_to_move = 0
              and quantity_scrapped = quantity_completed
                    -- this picks up the max op seq, if only scraps at ops
              and quantity_completed > 0));

    l_stmt_num := 20;
    IF (g_debug = 'Y') THEN
        fnd_file.put_line(fnd_file.log, 'At stmt '||l_stmt_num||' p_op_seq_num='||p_op_seq_num);
    END IF;

    IF (p_op_seq_num IS NULL) THEN -- Job creation : No records in WO for this p_wip_entity_id
                                   -- OR
                                   -- Unreleased Job : No qty in any operation
                                   -- OR
                                   -- Completed Job

        -- Start : Additions to fix bug #3677276

        -- Check for Completed Job Condition
        l_stmt_num := 22;

        SELECT  count(*)
        INTO    l_temp
        FROM    wip_operations
        WHERE   wip_entity_id = p_wip_entity_id;

        IF (l_temp > 1) THEN -- Completed Job
            x_err_code := -2;
            IF (g_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'Job is completed');
            END IF;
            return;
        END IF;
        -- End : Additions to fix bug #3677276

        -- Check for Unreleased Job Condition
    l_stmt_num := 25;
        SELECT max(operation_seq_num)
        INTO   p_op_seq_num
        FROM   wip_operations
        WHERE  wip_entity_id = p_wip_entity_id
        AND    quantity_in_queue = 0
        AND    quantity_running = 0
        AND    quantity_waiting_to_move = 0
        AND    quantity_scrapped = 0;

        IF (g_debug = 'Y') THEN
            fnd_file.put_line(fnd_file.log, 'At stmt '||l_stmt_num||' p_op_seq_num='||p_op_seq_num);
        END IF;

        IF (p_op_seq_num IS NULL) THEN -- Job creation : No records in WO for this p_wip_entity_id
            x_err_code := -1;
            x_err_buf := 'WSM_JobCopies_PVT.Get_Job_Curr_Op_Info('||l_stmt_num||'): Warning ! No operations in the job';
            IF (g_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, x_err_buf);
            END IF;
            return;
        END IF;

    END IF;

    l_stmt_num := 30;

    SELECT operation_sequence_id,
           standard_operation_id,
           department_id,
           quantity_in_queue,
           quantity_running,
           quantity_waiting_to_move,
           quantity_scrapped,
           first_unit_start_date,
           last_unit_completion_date
    INTO   p_op_seq_id,
           p_std_op_id,
           p_dept_id,
           l_qty_Q,
           l_qty_RUN,
           l_qty_TM,
           l_qty_SCR,
           p_op_start_date,
           p_op_comp_date
    FROM   wip_operations
    WHERE  wip_entity_id = p_wip_entity_id
    AND    operation_seq_num = p_op_seq_num;

    IF l_qty_Q > 0 THEN
        p_intra_op := 1;
        p_op_qty := l_qty_Q;
    ELSIF l_qty_RUN > 0 THEN
        p_intra_op := 2;
        p_op_qty := l_qty_RUN;
    ELSIF l_qty_TM > 0 THEN
        p_intra_op := 3;
        p_op_qty := l_qty_TM;
    ELSIF l_qty_SCR > 0 THEN
        p_intra_op := 5;
        p_op_qty := l_qty_SCR;
    ELSE    -- Unreleased Job
        p_intra_op := 1;
        p_op_qty := 0;
    END IF;

    l_stmt_num := 40;
    x_err_code := 0;
    x_err_buf := NULL;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := 'WSM_JobCopies_PVT.Get_Job_Curr_Op_Info('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
        fnd_file.put_line(fnd_file.log, x_err_buf);

END Get_Job_Curr_Op_Info;


/*************************
**                      **
**  Create_JobCopies    **
**                      **
**                      **
** x_err_code ->        **
** =0  implies no errors**
** =-1 implies warnings **
** else, error code     **
**                      **
*************************/

PROCEDURE Create_JobCopies  (x_err_buf              OUT NOCOPY VARCHAR2,
                             x_err_code             OUT NOCOPY NUMBER,
                             p_wip_entity_id        IN  NUMBER,
                             p_org_id               IN  NUMBER,
                             p_primary_item_id      IN  NUMBER,

                             p_routing_item_id      IN  NUMBER,
                             p_alt_rtg_desig        IN  VARCHAR2,
                             p_rtg_seq_id           IN  NUMBER,
                                                        -- Will be NULL till reqd for some functionality
                             p_common_rtg_seq_id    IN  NUMBER,
                             p_rtg_rev_date         IN  DATE,

                             p_bill_item_id         IN  NUMBER,
                             p_alt_bom_desig        IN  VARCHAR2,
                             p_bill_seq_id          IN  NUMBER,
                             p_common_bill_seq_id   IN  NUMBER,
                             p_bom_rev_date         IN  DATE,

                             p_wip_supply_type      IN  NUMBER,
                             p_last_update_date     IN  DATE,
                             p_last_updated_by      IN  NUMBER,
                             p_last_update_login    IN  NUMBER,
                             p_creation_date        IN  DATE,
                             p_created_by           IN  NUMBER,
                             p_request_id           IN  NUMBER,
                             p_program_app_id       IN  NUMBER,
                             p_program_id           IN  NUMBER,
                             p_program_update_date  IN  DATE,
                             p_inf_sch_flag         IN  VARCHAR2,   --Y/N
                             p_inf_sch_mode         IN  NUMBER,     --NULL/FORWARDS/BACKWARDS/MIDPOINT_FORWARDS/MIDPOINT_BACKWARDS/CURRENT_OP
                             p_inf_sch_date         IN  DATE ,       --based on mode, this will be start/completion date
                             p_new_job              IN  NUMBER DEFAULT NULL,
                             p_insert_wip           IN  NUMBER DEFAULT NULL,
                             p_phantom_exists       IN  NUMBER DEFAULT NULL,
                             p_charges_exist        IN  NUMBER DEFAULT NULL
                            )
IS

    l_stmt_num                  NUMBER := 0;
    DATETIME_FMT CONSTANT       VARCHAR2(22) := 'YYYY/MM/DD HH24:MI:SS';
    -- Note : Cannot use WSMPCNST.C_DATETIME_FMT since BOM requires date in the above format,
    -- which is different than the one defined in WSMPCNST.

    SORT_WIDTH CONSTANT         NUMBER := 4;/*to be replaced with the bom profile value*/

    -- Setup related variables --
    l_wip_param_def_subinv      VARCHAR2(10);
    l_wip_param_def_locator_id  NUMBER;
    l_use_phantom_routings      NUMBER := 0;
    l_max_bill_levels           NUMBER := 60;
    l_explosion_group_id        NUMBER := NULL;
    l_op_seq_one_exists_in_ntwk NUMBER;
    l_top_level_bill_seq_id     NUMBER;

    -- Current Operation related variables --
    l_curr_op_seq_num           NUMBER;
    l_curr_op_seq_id            NUMBER;
    l_curr_op_std_op_id         NUMBER;
    l_curr_op_dept_id           NUMBER;
    l_curr_op_intra_op          NUMBER;
    l_curr_op_qty               NUMBER;
    l_is_curr_op_reco           VARCHAR2(1);
    l_curr_op_start_date        DATE;
    l_curr_op_compl_date        DATE;
    l_curr_op_first_level_comps NUMBER := 0;
    l_curr_op_total_comps       NUMBER := 0;
    l_curr_op_max_res_seq       NUMBER := 10;-- Seq# to add more resources at curr op
    l_curr_op_is_ntwk_st_end    VARCHAR2(1);
    l_curr_first_op_attach_opseq1 NUMBER;

    -- Phantoms related variables --
    l_phantom_bill_seq_id       NUMBER; -- For the phantom bill exploded
    l_phantom_org_id            NUMBER;
    l_phantom_reqd_qty          NUMBER := 1;
    l_phantom_rtg_seq_id        NUMBER;
    l_phantom_expl_group_id     NUMBER := NULL;

    -- Infinite Scheduler related variables --
    l_inf_sch_flag              VARCHAR2(1);
    l_inf_sch_mode              NUMBER;
    l_inf_sch_start_date        DATE;
    l_inf_sch_comp_date         DATE;
    l_inf_sch_returnStatus      VARCHAR2(1);

    -- Recommended Path related variables --
    l_reco_path_op_seq_num      NUMBER;
    --l_reco_path_level           NUMBER; --OPTII-PERF
    l_reco_path_seq_num           NUMBER; --OPTII-PERF
    l_reco_path_start_op_seq    NUMBER;
    l_reco_path_end_op_seq      NUMBER;     -- Added to fix bug #3343865
    l_network_start_op_seq      NUMBER;     -- Added to fix bug #3400858

    -- Counters for loop --
    l_first_level_comps_ctr     NUMBER := 0; -- Earlier i
    l_all_level_comps_ctr       NUMBER := 0; -- Earlier l
    l_all_level_comps_subctr    NUMBER := 0; -- Earlier m

    -- Others --
    l_be_count                  NUMBER;
    l_err_buf                   VARCHAR2(4000);
    l_err_code                  NUMBER;
    l_network_start             VARCHAR2(1) := 'S'; -- Added to fix bug #3761385
    l_network_end               VARCHAR2(1) := 'E'; -- Added to fix bug #3761385
    l_ato_phantom               VARCHAR2(1) := 'N'; -- added for bug 6495025

    -- Exceptions --
    be_exploder_exception       EXCEPTION;
    loop_in_bom_exception       EXCEPTION;
    e_proc_error                EXCEPTION;
    e_noneff_op                 EXCEPTION; --Bug 4264364:Exception is added.

    l_serial_start_op           NUMBER; --SR12:Serial Support

    CURSOR job_ops IS
    SELECT  operation_seq_num,
            operation_sequence_id,
            network_start_end,
            reco_start_date,
            reco_completion_date,
            department_id
    FROM    wsm_copy_operations
    WHERE   wip_entity_id = p_wip_entity_id
    ORDER BY operation_seq_num;

    -- OptII Perf: New cursors ......
    CURSOR c_job_ops IS
    SELECT  BOS.operation_seq_num operation_seq_num,
            'N' recommended,  --recommended
            null network_start_end,
            null RECO_PATH_SEQ_NUM,
            BOS.operation_sequence_id,
            BOS.routing_sequence_id,
            BOS.standard_operation_id,
            BSO.operation_code Standard_operation_code,
            BOS.department_id,
            BD.department_code,
            BD.scrap_account,
            BD.est_absorption_account,
            BOS.operation_lead_time_percent,
            BOS.minimum_transfer_quantity,
            BOS.count_point_type,
            BOS.operation_description,
            BOS.effectivity_date,
            BOS.disable_date,
            BOS.backflush_flag,
            BOS.option_dependent_flag,
            BOS.operation_type,
            BOS.reference_flag,
            nvl(BOS.yield, 1) yield,  -- CST will consider as 1, if NULL
            BOS.implementation_date,
            BOS.cumulative_yield,
            BOS.reverse_cumulative_yield,
            BOS.labor_time_calc,
            BOS.machine_time_calc,
            BOS.total_time_calc,
            BOS.labor_time_user,
            BOS.machine_time_user,
            BOS.total_time_user,
            BOS.net_planning_percent,
            BOS.x_coordinate,
            BOS.y_coordinate,
            BOS.include_in_rollup,
            BOS.operation_yield_enabled,
            BOS.old_operation_sequence_id,
            BOS.acd_type,
            BOS.revised_item_sequence_id,
            BOS.change_notice,
            BOS.eco_for_production,
            BOS.shutdown_type,
            BOS.actual_ipk,
            BOS.critical_to_quality,
            BOS.value_added,
            p_last_update_date,
            p_last_updated_by,
            p_last_update_login,
            p_creation_date,
            p_created_by,
            p_request_id,
            p_program_app_id,
            p_program_id,
            p_program_update_date,
            BOS.attribute_category,
            BOS.attribute1,
            BOS.attribute2,
            BOS.attribute3,
            BOS.attribute4,
            BOS.attribute5,
            BOS.attribute6,
            BOS.attribute7,
            BOS.attribute8,
            BOS.attribute9,
            BOS.attribute10,
            BOS.attribute11,
            BOS.attribute12,
            BOS.attribute13,
            BOS.attribute14,
            BOS.attribute15,
            BOS.original_system_reference,
            BOS.lowest_acceptable_yield --mes
    FROM    BOM_OPERATION_SEQUENCES BOS,
            BOM_STANDARD_OPERATIONS BSO,
            BOM_DEPARTMENTS BD
    WHERE   BOS.routing_sequence_id = p_common_rtg_seq_id
    AND     p_rtg_rev_date between BOS.effectivity_date and nvl(BOS.disable_date, p_rtg_rev_date+1)
    AND     BOS.standard_operation_id = BSO.standard_operation_id (+)
    AND     BOS.department_id = BD.department_id;

    CURSOR c_job_nw is
    SELECT
            BON.from_op_seq_id,
            BON.to_op_seq_id,
            'N' recommended, -- recommended : Later the contiguous part of primary path will be set to Y
            BON.transition_type,
            BON.planning_pct,
            BON.attribute_category,
            BON.attribute1,
            BON.attribute2,
            BON.attribute3,
            BON.attribute4,
            BON.attribute5,
            BON.attribute6,
            BON.attribute7,
            BON.attribute8,
            BON.attribute9,
            BON.attribute10,
            BON.attribute11,
            BON.attribute12,
            BON.attribute13,
            BON.attribute14,
            BON.attribute15,
            BON.original_system_reference
    FROM    BOM_OPERATION_NETWORKS BON
    WHERE   BON.from_op_seq_id in (select operation_sequence_id  from
            bom_operation_sequences where routing_sequence_id = p_common_rtg_seq_id);

    CURSOR C_eff_opseq_id IS
                select bos1.operation_sequence_id new_op_seq_id,
                       bos2.operation_sequence_id old_op_seq_id
                from    BOM_OPERATION_SEQUENCES BOS1,
                        BOM_OPERATION_SEQUENCES BOS2
                Where   BOS1.routing_sequence_id = p_common_rtg_seq_id
                  AND   BOS2.routing_sequence_id = p_common_rtg_seq_id
                  AND   (p_rtg_rev_date <  BOS2.effectivity_date OR
                         p_rtg_rev_date  >= nvl(BOS2.disable_date, p_rtg_rev_date-1))
                  AND  BOS1.operation_seq_num = BOS2.operation_seq_num
                  AND  p_rtg_rev_date between BOS1.effectivity_date and nvl(BOS1.disable_date, p_rtg_rev_date+1);



    type t_job_ops is table of WSM_COPY_OPERATIONS%rowtype index by binary_integer;
    type t_job_nw  is table of WSM_COPY_OP_NETWORKS%rowtype index by binary_integer;


    v_job_ops   t_job_ops;
    v_job_nw    t_job_nw;
    l_level NUMBER;
    l_counter NUMBER;
    l_valid_start_op NUMBER;
    l_op_seq_num NUMBER;
    -- Construct a table of records....
    -- for a network like 10--> 20 --> 30
    --                    10--> 40 --> 30 (alternate)
    -- we'll store the info as a(10) := 20
    --                         a(20) := 30;
    -- End op seq num will be anyway known...
    -- if a op in this table doesnt exist in the above table constructed for operations
    -- then there is a Exit in the link...


     -- ST performance fix end --

   --To be used only when phantom components exist

    CURSOR reqs is
    -- Primary Components --
    SELECT *    -- Fix for bug #3313480
    FROM        -- Fix for bug #3313480
    (           -- Fix for bug #3313480 -- Start of union of 2 sqls
     SELECT  o.operation_seq_num,
            a.component_item_id     component_item_id,
            a.component_item_id     primary_component_id,
            a.component_sequence_id,
            decode(decode(p_wip_supply_type,
                          7,
                          nvl(a.wip_supply_type, nvl(c.wip_supply_type, 1)),
                          p_wip_supply_type),
                   6,
                   a.component_item_id,
                   -1)  source_phantom_id, --populate only for phantoms, else -1
            'Y'         recommended,
            o.reco_start_date,
            a.bill_sequence_id,
            o.department_id,

            decode(p_wip_supply_type,
                   7,
                   nvl(a.wip_supply_type, nvl(c.wip_supply_type, 1)),
                   p_wip_supply_type) wip_supply_type,
            --Bug 5216333: Suppy type specified at job should be looked at first
            decode (p_org_id,
                    l_phantom_org_id,
                    nvl(a.supply_subinventory,
                        nvl(c.wip_supply_subinventory,
                            decode(decode(p_wip_supply_type,7,nvl(a.wip_supply_type, nvl(c.wip_supply_type, 1)),p_wip_supply_type),
                                   2,
                                   l_wip_param_def_subinv,
                                   3,
                                   l_wip_param_def_subinv,
                                   null
                                  )
                           )
                       ),
                    nvl(c.wip_supply_subinventory,
                        decode(decode(p_wip_supply_type,7,nvl(a.wip_supply_type, nvl(c.wip_supply_type, 1)),p_wip_supply_type),
                               2,
                               l_wip_param_def_subinv,
                               3,
                               l_wip_param_def_subinv,
                               null
                              )
                       )
                   ) supply_subinventory,
            decode (p_org_id,     -- supply locator id begin
                    l_phantom_org_id,
                   --Bug 5216333: Suppy type specified at job should be looked at first
                    decode (a.supply_subinventory,
                            null,
                            decode (c.wip_supply_subinventory,
                                    null,
                                    decode(decode(p_wip_supply_type,7,nvl(a.wip_supply_type,
                                               nvl(c.wip_supply_type,1)),p_wip_supply_type),
                                           2,
                                           --nvl(l_wip_param_def_locator_id,-1),
                                          l_wip_param_def_locator_id,
                                           3,
                                           --nvl(l_wip_param_def_locator_id,-1),
                                           l_wip_param_def_locator_id,
                                           null
                                          ),
                                    c.wip_supply_locator_id
                                   ),
                            a.supply_locator_id
                           ),
                    decode (c.wip_supply_subinventory,
                            null,
                            decode(decode(p_wip_supply_type,7,nvl(a.wip_supply_type, nvl(c.wip_supply_type, 1)),p_wip_supply_type),
                                   2,
                                   nvl(l_wip_param_def_locator_id,-1),
                                   3,
                                   nvl(l_wip_param_def_locator_id,-1),
                                   null
                                  ),
                            c.wip_supply_locator_id
                           )
                   ) supply_locator_id, -- supply locator id end

            a.component_quantity / decode(a.component_yield_factor,
                                          0,
                                          1,
                                          a.component_yield_factor
                                         ) required_quantity,

            a.component_quantity    BILL_QUANTITY_PER_ASSEMBLY,

            a.component_yield_factor,
            a.basis_type,           --LBM enh
            a.effectivity_date      effectivity_date,
            a.disable_date,
            null component_priority, -- bug 7016646
            a.parent_bill_seq_id,

            a.item_num,
            a.component_remarks,
            a.change_notice,
            a.implementation_date,
            a.planning_factor,
            a.quantity_related,
            a.so_basis,
            a.optional,
            a.mutually_exclusive_options,
            a.include_in_cost_rollup,
            a.check_atp,
            a.shipping_allowed,
            a.required_to_ship,
            a.required_for_revenue,
            a.include_on_ship_docs,
            a.low_quantity,
            a.high_quantity,
            a.acd_type,
            a.old_component_sequence_id,
            a.operation_lead_time_percent,
            a.revised_item_sequence_id,
            a.bom_item_type,
            a.from_end_item_unit_number,
            a.to_end_item_unit_number,
            a.eco_for_production,
            a.enforce_int_requirements,
            a.delete_group_name,
            a.dg_description,
            a.optional_on_model,
            a.model_comp_seq_id,
            a.plan_level,
            a.auto_request_material,
            a.component_item_revision_id,
            a.from_bill_revision_id,
            a.to_bill_revision_id,
            a.pick_components,
            a.include_on_bill_docs,
            a.cost_factor,
            a.original_system_reference,
            a.attribute_category,
            a.attribute1,
            a.attribute2,
            a.attribute3,
            a.attribute4,
            a.attribute5,
            a.attribute6,
            a.attribute7,
            a.attribute8,
            a.attribute9,
            a.attribute10,
            a.attribute11,
            a.attribute12,
            a.attribute13,
            a.attribute14,
            a.attribute15
    FROM    WSM_COPY_OPERATIONS O,
            BOM_INVENTORY_COMPONENTS A,
            MTL_SYSTEM_ITEMS C,
            BOM_EXPLOSION_TEMP BE
    WHERE   be.group_id = l_explosion_group_id
    AND     be.top_bill_sequence_id = l_top_level_bill_seq_id
    AND     a.component_sequence_id = be.component_sequence_id
    AND     be.component_item_id = c.inventory_item_id
    AND     c.organization_id = p_org_id
    AND     o.wip_entity_id = p_wip_entity_id
    AND     o.operation_sequence_id = l_curr_op_seq_id
    AND     ((A.operation_seq_num = (SELECT operation_seq_num
                                     FROM   WSM_COPY_OPERATIONS
                                     WHERE  operation_sequence_id =
                                                l_curr_op_seq_id
                                     AND    wip_entity_id = p_wip_entity_id
                                    )
             )
            OR
             (l_curr_first_op_attach_opseq1 = 1 and  a.operation_seq_num = 1)
            )
    AND     p_bom_rev_date between a.effectivity_date and nvl(a.disable_date, p_bom_rev_date+1)
    AND     A.EFFECTIVITY_DATE = (SELECT MAX(EFFECTIVITY_DATE)
                                  FROM   BOM_INVENTORY_COMPONENTS BIC,
                                         ENG_REVISED_ITEMS ERI
                                  WHERE  BIC.BILL_SEQUENCE_ID = A.BILL_SEQUENCE_ID
                                  AND    BIC.COMPONENT_ITEM_ID = A.COMPONENT_ITEM_ID
                                  AND    (decode(BIC.IMPLEMENTATION_DATE,
                                                 NULL,
                                                 BIC.OLD_COMPONENT_SEQUENCE_ID,
                                                 BIC.COMPONENT_SEQUENCE_ID
                                                ) =
                                          decode(A.IMPLEMENTATION_DATE,
                                                 NULL,
                                                 A.OLD_COMPONENT_SEQUENCE_ID,
                                                 A.COMPONENT_SEQUENCE_ID
                                                )
                                         OR
                                          BIC.OPERATION_SEQ_NUM = A.OPERATION_SEQ_NUM
                                         )
                                  AND   BIC.EFFECTIVITY_DATE <= p_bom_rev_date
                                  AND   BIC.REVISED_ITEM_SEQUENCE_ID =
                                            ERI.REVISED_ITEM_SEQUENCE_ID(+)
                                  AND   (nvl(ERI.STATUS_TYPE,6) IN (4,6,7))
                                  AND   NOT EXISTS
                                            (SELECT 'X'
                                             FROM   BOM_INVENTORY_COMPONENTS BICN,
                                                    ENG_REVISED_ITEMS ERI1
                                             WHERE  BICN.BILL_SEQUENCE_ID =
                                                        A.BILL_SEQUENCE_ID
                                             AND    BICN.OLD_COMPONENT_SEQUENCE_ID =
                                                        A.COMPONENT_SEQUENCE_ID
                                             AND    BICN.ACD_TYPE in (2,3)
                                             AND    BICN.DISABLE_DATE <=
                                                        p_bom_rev_date
                                             AND    ERI1.REVISED_ITEM_SEQUENCE_ID =
                                                        BICN.REVISED_ITEM_SEQUENCE_ID
                                             AND    (nvl(ERI1.STATUS_TYPE,6)IN(4,6,7))
                                            )
                                 )

 UNION ALL -- ST : Performance fix : replaced UNION with UNION ALL
    -- Substitute components --
    SELECT  O.OPERATION_SEQ_NUM,
            S.SUBSTITUTE_COMPONENT_ID   COMPONENT_ITEM_ID,
            A.COMPONENT_ITEM_ID         PRIMARY_COMPONENT_ID,
            S.COMPONENT_SEQUENCE_ID,
            decode(decode(p_wip_supply_type,
                          7,
                          nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),
                          p_wip_supply_type),
                   6,
                   S.SUBSTITUTE_COMPONENT_ID,
                   -1)  source_phantom_id, --populate only for phantoms, else -1

            'N'                         recommended,
            o.reco_start_date,
            A.BILL_SEQUENCE_ID,
            o.department_id,

            decode(p_wip_supply_type,
                   7,
                   nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),
                   p_wip_supply_type) wip_supply_type,
            --Bug 5216333: Suppy type specified at job should be looked at first
            decode (p_org_id,
                    l_phantom_org_id,
                    nvl(A.SUPPLY_SUBINVENTORY,
                        nvl(C.WIP_SUPPLY_SUBINVENTORY,
                            decode(decode(p_wip_supply_type,7,nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),p_wip_supply_type),
                                   2,
                                   l_wip_param_def_subinv,
                                   3,
                                   l_wip_param_def_subinv,
                                   NULL
                                  )
                           )
                       ),
                    nvl(C.WIP_SUPPLY_SUBINVENTORY,
                        decode(decode(p_wip_supply_type,7,nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),p_wip_supply_type),
                               2,
                               l_wip_param_def_subinv,
                               3,
                               l_wip_param_def_subinv,
                               NULL
                              )
                       )
                   ) supply_subinventory,
            --Bug 4755122: nvl(l_wip_param_def_locator_id,-1) is replaced with l_wip_param_def_locator_id
            --Bug 5216333: Suppy type specified at job should be looked at first
            decode (p_org_id,     -- Supply locator id begin
                    l_phantom_org_id,
                    decode (A.SUPPLY_SUBINVENTORY,
                            NULL,
                            decode (C.WIP_SUPPLY_SUBINVENTORY,
                                    NULL,
                                    decode(decode(p_wip_supply_type,7,nvl(A.WIP_SUPPLY_TYPE,
                                               nvl(C.WIP_SUPPLY_TYPE,1)),p_wip_supply_type),
                                           2,
                                           --nvl(l_wip_param_def_locator_id,-1),
                                           l_wip_param_def_locator_id,
                                           3,
                                           l_wip_param_def_locator_id,
                                           NULL
                                          ),
                                    C.WIP_SUPPLY_LOCATOR_ID
                                   ),
                            A.SUPPLY_LOCATOR_ID
                           ),
                    decode (C.WIP_SUPPLY_SUBINVENTORY,
                            NULL,
                            decode(decode(p_wip_supply_type,7,nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),p_wip_supply_type),
                                   2,
                                   --nvl(l_wip_param_def_locator_id,-1),
                                   l_wip_param_def_locator_id,
                                   3,
                                   l_wip_param_def_locator_id,
                                   NULL
                                  ),
                            C.WIP_SUPPLY_LOCATOR_ID
                           )
                   ) supply_locator_id, -- Supply locator id end

             S.SUBSTITUTE_ITEM_QUANTITY / decode(A.COMPONENT_YIELD_FACTOR,
                                                 0,
                                                 1,
                                                 A.COMPONENT_YIELD_FACTOR
                                                ) required_quantity,

            S.SUBSTITUTE_ITEM_QUANTITY   BILL_QUANTITY_PER_ASSEMBLY,

            A.COMPONENT_YIELD_FACTOR,
            A.BASIS_TYPE,                   --LBM enh
            A.EFFECTIVITY_DATE,
            A.DISABLE_DATE,
            s.attribute1                COMPONENT_PRIORITY,
            A.PARENT_BILL_SEQ_ID,

            A.ITEM_NUM,
            A.COMPONENT_REMARKS,
            S.CHANGE_NOTICE,
            A.IMPLEMENTATION_DATE,
            A.PLANNING_FACTOR,
            A.QUANTITY_RELATED,
            A.SO_BASIS,
            A.OPTIONAL,
            A.MUTUALLY_EXCLUSIVE_OPTIONS,
            A.INCLUDE_IN_COST_ROLLUP,
            A.CHECK_ATP,
            A.SHIPPING_ALLOWED,
            A.REQUIRED_TO_SHIP,
            A.REQUIRED_FOR_REVENUE,
            A.INCLUDE_ON_SHIP_DOCS,
            A.LOW_QUANTITY,
            A.HIGH_QUANTITY,
            S.ACD_TYPE,
            A.OLD_COMPONENT_SEQUENCE_ID,
            A.OPERATION_LEAD_TIME_PERCENT,
            A.REVISED_ITEM_SEQUENCE_ID,
            A.BOM_ITEM_TYPE,
            A.FROM_END_ITEM_UNIT_NUMBER,
            A.TO_END_ITEM_UNIT_NUMBER,
            A.ECO_FOR_PRODUCTION,
            S.ENFORCE_INT_REQUIREMENTS,
            A.DELETE_GROUP_NAME,
            A.DG_DESCRIPTION,
            A.OPTIONAL_ON_MODEL,
            A.MODEL_COMP_SEQ_ID,
            A.PLAN_LEVEL,
            A.AUTO_REQUEST_MATERIAL,
            A.COMPONENT_ITEM_REVISION_ID,
            A.FROM_BILL_REVISION_ID,
            A.TO_BILL_REVISION_ID,
            A.PICK_COMPONENTS,
            A.INCLUDE_ON_BILL_DOCS,
            A.COST_FACTOR,
            A.ORIGINAL_SYSTEM_REFERENCE,
            s.attribute_category,
            s.attribute1,
            s.attribute2,
            s.attribute3,
            s.attribute4,
            s.attribute5,
            s.attribute6,
            s.attribute7,
            s.attribute8,
            s.attribute9,
            s.attribute10,
            s.attribute11,
            s.attribute12,
            s.attribute13,
            s.attribute14,
            s.attribute15
    FROM    WSM_COPY_OPERATIONS O,
            BOM_INVENTORY_COMPONENTS A,
            BOM_SUBSTITUTE_COMPONENTS S,
            MTL_SYSTEM_ITEMS C,
            BOM_EXPLOSION_TEMP BE
    WHERE   BE.GROUP_ID=l_explosion_group_id
    AND     BE.TOP_BILL_SEQUENCE_ID = l_top_level_bill_seq_id
    AND     A.COMPONENT_SEQUENCE_ID=BE.COMPONENT_SEQUENCE_ID
    AND     S.COMPONENT_SEQUENCE_ID = A.COMPONENT_SEQUENCE_ID
    AND     S.SUBSTITUTE_COMPONENT_ID = C.INVENTORY_ITEM_ID
    AND     NVL(S.ACD_TYPE,1) <> 3 /* Added condition on acd_type for bugfix:8639874 */
    AND     C.ORGANIZATION_ID = p_org_id
    AND     O.wip_entity_id = p_wip_entity_id
    AND     O.operation_sequence_id = l_curr_op_seq_id
    AND     ((A.operation_seq_num = (SELECT operation_seq_num
                                     FROM   WSM_COPY_OPERATIONS
                                     WHERE  operation_sequence_id =
                                                l_curr_op_seq_id
                                     AND    wip_entity_id = p_wip_entity_id
                                    )
             )
            OR
             (l_curr_first_op_attach_opseq1 = 1 AND  A.OPERATION_SEQ_NUM = 1)
            )
    AND     p_bom_rev_date BETWEEN A.EFFECTIVITY_DATE and nvl(A.DISABLE_DATE, p_bom_rev_date+1)
    AND     A.EFFECTIVITY_DATE = (SELECT MAX(EFFECTIVITY_DATE)
                                  FROM   BOM_INVENTORY_COMPONENTS BIC,
                                         ENG_REVISED_ITEMS ERI
                                  WHERE  BIC.BILL_SEQUENCE_ID = A.BILL_SEQUENCE_ID
                                  AND    BIC.COMPONENT_ITEM_ID = A.COMPONENT_ITEM_ID
                                  AND    (decode(BIC.IMPLEMENTATION_DATE,
                                                 NULL,
                                                 BIC.OLD_COMPONENT_SEQUENCE_ID,
                                                 BIC.COMPONENT_SEQUENCE_ID
                                                ) =
                                          decode(A.IMPLEMENTATION_DATE,
                                                 NULL,
                                                 A.OLD_COMPONENT_SEQUENCE_ID,
                                                 A.COMPONENT_SEQUENCE_ID
                                                )
                                         OR
                                          BIC.OPERATION_SEQ_NUM = A.OPERATION_SEQ_NUM
                                         )
                                  AND   BIC.EFFECTIVITY_DATE <= p_bom_rev_date
                                  AND   BIC.REVISED_ITEM_SEQUENCE_ID =
                                            ERI.REVISED_ITEM_SEQUENCE_ID(+)
                                  AND   (nvl(ERI.STATUS_TYPE,6) IN (4,6,7))
                                  AND   NOT EXISTS
                                            (SELECT 'X'
                                             FROM   BOM_INVENTORY_COMPONENTS BICN,
                                                    ENG_REVISED_ITEMS ERI1
                                             WHERE  BICN.BILL_SEQUENCE_ID =
                                                        A.BILL_SEQUENCE_ID
                                             AND    BICN.OLD_COMPONENT_SEQUENCE_ID =
                                                        A.COMPONENT_SEQUENCE_ID
                                             AND    BICN.ACD_TYPE in (2,3)
                                             AND    BICN.DISABLE_DATE <=
                                                        p_bom_rev_date
                                             AND    ERI1.REVISED_ITEM_SEQUENCE_ID =
                                                        BICN.REVISED_ITEM_SEQUENCE_ID
                                             AND    (nvl(ERI1.STATUS_TYPE,6)IN(4,6,7))
                                            )
                                 )
    );           -- Fix for bug #3313480 -- End of union of 2 sqls
    -- ST : Performance fix commenting out order by
    -- ORDER BY COMPONENT_ITEM_ID,WIP_SUPPLY_TYPE,EFFECTIVITY_DATE;

   TYPE table_comp_details is TABLE OF reqs%ROWTYPE INDEX by BINARY_INTEGER;
   t_comp_details table_comp_details;
   TYPE table_opseq is table of number INDEX by BINARY_INTEGER;
   t_eff_opseq_id table_opseq;
   t_eff_opseq_num table_opseq;
   t_eff_opseqid_pos table_opseq;
   -- start bug 4448718
   next_op_prim_path table_opseq;
   disabled_prim_path BOOLEAN;
   v_job_nw_delete table_opseq;
   -- End bug 4448718
   l_end_op_seq_id number;
   l_start_op_seq_id number;
   l_start_op_seq_num NUMBER;
   l_opseq1_exists number;
   l_curr_opseq_id NUMBER;
   l_curr_reco_path_seq_num NUMBER;
   l_index NUMBER;
   i NUMBER;
   j NUMBER;
   l_go_to_next_level BOOLEAN;
   l_from_op_seq_id NUMBER;
   l_to_op_seq_id NUMBER;
   l_from_op_seq_num NUMBER;
   l_to_op_seq_num NUMBER;
   dummy1 NUMBER;
   dummy2 VARCHAR2(1000);
   l_op_seq_incr NUMBER;

   -- ST : MES changes --
   l_curr_job_op_seq_num        NUMBER;
   l_curr_rtg_op_seq_num        NUMBER;
   -- ST : MES changes --

   -- ST : Fix for bug 5171286 --
   l_first_serial_txn_id        NUMBER;

BEGIN

    g_debug := FND_PROFILE.VALUE('MRP_DEBUG');

    IF (g_debug = 'Y') THEN
        fnd_file.put_line(fnd_file.log, 'Parameters to Create_JobCopies are :');
        fnd_file.put_line(fnd_file.log, '  p_wip_entity_id       ='||p_wip_entity_id       );
        fnd_file.put_line(fnd_file.log, ', p_org_id              ='||p_org_id              );
        fnd_file.put_line(fnd_file.log, ', p_primary_item_id     ='||p_primary_item_id     );
        fnd_file.put_line(fnd_file.log, ', p_routing_item_id     ='||p_routing_item_id     );
        fnd_file.put_line(fnd_file.log, ', p_alt_rtg_desig       ='||p_alt_rtg_desig       );
        fnd_file.put_line(fnd_file.log, ', p_rtg_seq_id          ='||p_rtg_seq_id          );
        fnd_file.put_line(fnd_file.log, ', p_common_rtg_seq_id   ='||p_common_rtg_seq_id   );
        fnd_file.put_line(fnd_file.log, ', p_rtg_rev_date        ='||p_rtg_rev_date        );
        fnd_file.put_line(fnd_file.log, ', p_bill_item_id        ='||p_bill_item_id        );
        fnd_file.put_line(fnd_file.log, ', p_alt_bom_desig       ='||p_alt_bom_desig       );
        fnd_file.put_line(fnd_file.log, ', p_bill_seq_id         ='||p_bill_seq_id         );
        fnd_file.put_line(fnd_file.log, ', p_common_bill_seq_id  ='||p_common_bill_seq_id  );
        fnd_file.put_line(fnd_file.log, ', p_bom_rev_date        ='||p_bom_rev_date        );
        fnd_file.put_line(fnd_file.log, ', p_wip_supply_type     ='||p_wip_supply_type     );
        fnd_file.put_line(fnd_file.log, ', p_last_update_date    ='||p_last_update_date    );
        fnd_file.put_line(fnd_file.log, ', p_last_updated_by     ='||p_last_updated_by     );
        fnd_file.put_line(fnd_file.log, ', p_last_update_login   ='||p_last_update_login   );
        fnd_file.put_line(fnd_file.log, ', p_creation_date       ='||p_creation_date       );
        fnd_file.put_line(fnd_file.log, ', p_created_by          ='||p_created_by          );
        fnd_file.put_line(fnd_file.log, ', p_request_id          ='||p_request_id          );
        fnd_file.put_line(fnd_file.log, ', p_program_app_id      ='||p_program_app_id      );
        fnd_file.put_line(fnd_file.log, ', p_program_id          ='||p_program_id          );
        fnd_file.put_line(fnd_file.log, ', p_program_update_date ='||p_program_update_date );
        fnd_file.put_line(fnd_file.log, ', p_inf_sch_flag        ='||p_inf_sch_flag        );
        fnd_file.put_line(fnd_file.log, ', p_inf_sch_mode        ='||p_inf_sch_mode        );
        fnd_file.put_line(fnd_file.log, ', p_inf_sch_date        ='||p_inf_sch_date        );
    END IF;

    l_stmt_num := 10;

    -- Start : Basic validations for the input parameters --
    IF (nvl(p_primary_item_id, 0) = 0) OR
       (nvl(p_primary_item_id, -1) = -1)
    THEN
        fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'Primary Item ID in Job');
        x_err_buf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||'): '||x_err_buf);
        x_err_code := -2;   -- Error
        return;
    END IF;

    IF (nvl(p_routing_item_id, 0) = 0) OR
       (nvl(p_routing_item_id, -1) = -1)
    THEN
        fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'Routing Item ID in Job');
        x_err_buf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||'): '||x_err_buf);
        x_err_code := -2;   -- Error
        return;
    END IF;

    IF (nvl(p_common_rtg_seq_id, 0) = 0) OR
       (nvl(p_common_rtg_seq_id, -1) = -1)
    THEN
        fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'Common Routing Sequence ID in Job');
        x_err_buf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||'): '||x_err_buf);
        x_err_code := -2;   -- Error
        return;
    END IF;

    IF (p_rtg_rev_date IS NULL)
    THEN
        fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'Routing Revision Date in Job');
        x_err_buf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||'): '||x_err_buf);
        x_err_code := -2;   -- Error
        return;
    END IF;

    IF (nvl(p_wip_supply_type, 0) = 0) OR
       (nvl(p_wip_supply_type, -1) = -1)
    THEN
        fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
        FND_MESSAGE.SET_TOKEN('FLD_NAME', 'Supply Type in Job');
        x_err_buf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||'): '||x_err_buf);
        x_err_code := -2;   -- Error
        return;
    END IF;
    -- End : Basic validations for the input parameters --

    IF (   (p_inf_sch_flag = 'Y')
       AND NOT (p_inf_sch_mode IN (WIP_CONSTANTS.FORWARDS,
                                   WIP_CONSTANTS.MIDPOINT_FORWARDS,
                                   WIP_CONSTANTS.CURRENT_OP,
                                   WIP_CONSTANTS.BACKWARDS,
                                   WIP_CONSTANTS.MIDPOINT_BACKWARDS)
                OR p_inf_sch_mode IS NULL
               )
       )
    THEN
        -- Invalid Infinite Scheduling Mode
        fnd_message.set_name('WSM', 'WSM_INVALID_INFSCH_MODE');
        x_err_buf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||'): '||x_err_buf);
        x_err_code := -2;   -- Error
        return;
    END IF;

    -- Local variable
    l_inf_sch_flag := p_inf_sch_flag;

   if p_insert_wip is NULL or  p_insert_wip <> 1 then
    -- Start : Additions to fix bug #3677276
    BEGIN

        l_stmt_num := 13;

        UPDATE  wip_operations wo
        SET     wo.wsm_op_seq_num    =
                    (SELECT  distinct(bos.operation_seq_num)
                     FROM    wip_operations wo1,
                             bom_operation_sequences bos
                     WHERE   wo1.wip_entity_id = p_wip_entity_id
                     AND     wo1.wsm_op_seq_num IS NULL
                     AND     wo1.operation_sequence_id = bos.operation_sequence_id
                     AND     bos.routing_sequence_id = p_common_rtg_seq_id
                     AND     wo1.operation_seq_num = wo.operation_seq_num)
        WHERE   wip_entity_id     = p_wip_entity_id
        AND     wsm_op_seq_num IS NULL;
    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||
                                '): Cannot upgrade wip_operations.wsm_op_seq_num for wip_entity_id '||p_wip_entity_id);
    END;
    end if;--check on p_insert_wip
    l_stmt_num := 15;

    -- End : Additions to fix bug #3677276

    -- Delete COPY tables --
    --Delete only when l_new_job is false....
    if p_new_job is NULL or p_new_job = 2  then

            DELETE WSM_COPY_OPERATIONS
            WHERE  wip_entity_id = p_wip_entity_id;

            DELETE WSM_COPY_OP_NETWORKS
            WHERE  wip_entity_id = p_wip_entity_id;

            DELETE WSM_COPY_OP_RESOURCES
            WHERE  wip_entity_id = p_wip_entity_id;

            DELETE WSM_COPY_OP_RESOURCE_INSTANCES
            WHERE  wip_entity_id = p_wip_entity_id;

            DELETE WSM_COPY_OP_RESOURCE_USAGE
            WHERE  wip_entity_id = p_wip_entity_id;

            DELETE WSM_COPY_REQUIREMENT_OPS
            WHERE  wip_entity_id = p_wip_entity_id;

    end if; --End of check on p_new_job before deleting the copy tables

    DELETE WSM_LOT_BASED_JOBS
    WHERE  wip_entity_id = p_wip_entity_id
    RETURNING current_job_op_seq_num,current_rtg_op_seq_num,first_serial_txn_id
    INTO l_curr_job_op_seq_num,l_curr_rtg_op_seq_num,l_first_serial_txn_id;
    -- ST : Added first_serial_txn_id in the above statement for bug fix 5171286

    -- *** Start : Set the setup variables *** --
    l_stmt_num := 20;

    SELECT default_pull_supply_subinv,
           default_pull_supply_locator_id
    INTO   l_wip_param_def_subinv,
           l_wip_param_def_locator_id
    FROM   wip_parameters
    WHERE  organization_id = p_org_id;

    --OPTII-PERF:Check on p_phantom_exists is added.
    IF (p_common_bill_seq_id IS NOT NULL) and
    (p_phantom_exists = 1 OR p_phantom_exists IS NULL) THEN
    l_stmt_num := 30;

        BEGIN
            SELECT  nvl(use_phantom_routings, 0),
                    nvl(maximum_bom_level, 60),
                    BOM_EXPLOSION_TEMP_S.nextval    -- Added here for performance improvement
            INTO    l_use_phantom_routings,
                    l_max_bill_levels,
                    l_explosion_group_id
            FROM    BOM_PARAMETERS
            WHERE   ORGANIZATION_ID = p_org_id;

        EXCEPTION
            WHEN no_data_found THEN
                null;
        END;

    END IF;
    -- *** End : Set the setup variables *** --
    l_stmt_num := 50;

    FOR l_opseq_rec in c_eff_opseq_id LOOP
        if l_opseq_rec.new_op_seq_id is not null then
          t_eff_opseq_id(l_opseq_rec.old_op_seq_id) := l_opseq_rec.new_op_seq_id;
        end if;

    END LOOP;

   l_counter :=0;
   l_stmt_num := 60;
   l_opseq1_exists := NULL;
    FOR l_job_op IN c_job_ops LOOP

         l_counter := l_counter + 1;

         v_job_ops(l_counter).WIP_ENTITY_ID                  := p_wip_entity_id;
         v_job_ops(l_counter).OPERATION_SEQ_NUM              := l_job_op.operation_seq_num;
         v_job_ops(l_counter).RECOMMENDED                    := l_job_op.RECOMMENDED;
         v_job_ops(l_counter).RECO_PATH_SEQ_NUM              := l_job_op.RECO_PATH_SEQ_NUM;
         v_job_ops(l_counter).RECO_SCHEDULED_QUANTITY        := null;
         v_job_ops(l_counter).RECO_START_DATE                := null;
         v_job_ops(l_counter).RECO_COMPLETION_DATE           := null;
         v_job_ops(l_counter).NETWORK_START_END              := l_job_op.NETWORK_START_END;
         v_job_ops(l_counter).OPERATION_SEQUENCE_ID          := l_job_op.OPERATION_SEQUENCE_ID;
         v_job_ops(l_counter).ROUTING_SEQUENCE_ID            := l_job_op.ROUTING_SEQUENCE_ID;
         v_job_ops(l_counter).ORGANIZATION_ID                := p_org_id;
         v_job_ops(l_counter).STANDARD_OPERATION_ID          := l_job_op.STANDARD_OPERATION_ID;
         v_job_ops(l_counter).STANDARD_OPERATION_CODE        := l_job_op.STANDARD_OPERATION_CODE;
         v_job_ops(l_counter).DEPARTMENT_ID                  := l_job_op.DEPARTMENT_ID;
         v_job_ops(l_counter).DEPARTMENT_CODE                := l_job_op.DEPARTMENT_CODE;
         v_job_ops(l_counter).SCRAP_ACCOUNT                  := l_job_op.SCRAP_ACCOUNT;
         v_job_ops(l_counter).EST_ABSORPTION_ACCOUNT         := l_job_op.EST_ABSORPTION_ACCOUNT;
         v_job_ops(l_counter).OPERATION_LEAD_TIME_PERCENT    := l_job_op.OPERATION_LEAD_TIME_PERCENT;
         v_job_ops(l_counter).MINIMUM_TRANSFER_QUANTITY      := l_job_op.MINIMUM_TRANSFER_QUANTITY;
         v_job_ops(l_counter).COUNT_POINT_TYPE               := l_job_op.COUNT_POINT_TYPE;
         v_job_ops(l_counter).OPERATION_DESCRIPTION          := l_job_op.OPERATION_DESCRIPTION;
         v_job_ops(l_counter).EFFECTIVITY_DATE               := l_job_op.EFFECTIVITY_DATE;
         v_job_ops(l_counter).DISABLE_DATE                   := l_job_op.DISABLE_DATE;
         v_job_ops(l_counter).BACKFLUSH_FLAG                 := l_job_op.BACKFLUSH_FLAG;
         v_job_ops(l_counter).OPTION_DEPENDENT_FLAG          := l_job_op.OPTION_DEPENDENT_FLAG;
         v_job_ops(l_counter).OPERATION_TYPE                 := l_job_op.OPERATION_TYPE;
         v_job_ops(l_counter).REFERENCE_FLAG                 := l_job_op.REFERENCE_FLAG;
         v_job_ops(l_counter).YIELD                          := l_job_op.YIELD;
         v_job_ops(l_counter).CUMULATIVE_YIELD               := l_job_op.CUMULATIVE_YIELD;
         v_job_ops(l_counter).REVERSE_CUMULATIVE_YIELD       := l_job_op.REVERSE_CUMULATIVE_YIELD;
         v_job_ops(l_counter).LABOR_TIME_CALC                := l_job_op.LABOR_TIME_CALC;
         v_job_ops(l_counter).MACHINE_TIME_CALC              := l_job_op.MACHINE_TIME_CALC;
         v_job_ops(l_counter).TOTAL_TIME_CALC                := l_job_op.TOTAL_TIME_CALC;
         v_job_ops(l_counter).LABOR_TIME_USER                := l_job_op.LABOR_TIME_USER;
         v_job_ops(l_counter).MACHINE_TIME_USER              := l_job_op.MACHINE_TIME_USER;
         v_job_ops(l_counter).TOTAL_TIME_USER                := l_job_op.TOTAL_TIME_USER;
         v_job_ops(l_counter).NET_PLANNING_PERCENT           := l_job_op.NET_PLANNING_PERCENT;
         v_job_ops(l_counter).X_COORDINATE                   := l_job_op.X_COORDINATE;
         v_job_ops(l_counter).Y_COORDINATE                   := l_job_op.Y_COORDINATE;
         v_job_ops(l_counter).INCLUDE_IN_ROLLUP              := l_job_op.INCLUDE_IN_ROLLUP;
         v_job_ops(l_counter).OPERATION_YIELD_ENABLED        := l_job_op.OPERATION_YIELD_ENABLED;
         v_job_ops(l_counter).OLD_OPERATION_SEQUENCE_ID      := l_job_op.OLD_OPERATION_SEQUENCE_ID;
         v_job_ops(l_counter).ACD_TYPE                       := l_job_op.ACD_TYPE;
         v_job_ops(l_counter).REVISED_ITEM_SEQUENCE_ID       := l_job_op.REVISED_ITEM_SEQUENCE_ID;
         v_job_ops(l_counter).CHANGE_NOTICE                  := l_job_op.CHANGE_NOTICE;
         v_job_ops(l_counter).IMPLEMENTATION_DATE            := l_job_op.IMPLEMENTATION_DATE;
         v_job_ops(l_counter).ECO_FOR_PRODUCTION             := l_job_op.ECO_FOR_PRODUCTION;
         v_job_ops(l_counter).SHUTDOWN_TYPE                  := l_job_op.SHUTDOWN_TYPE;
         v_job_ops(l_counter).ACTUAL_IPK                     := l_job_op.ACTUAL_IPK;
         v_job_ops(l_counter).CRITICAL_TO_QUALITY            := l_job_op.CRITICAL_TO_QUALITY;
         v_job_ops(l_counter).VALUE_ADDED                    := l_job_op.VALUE_ADDED;
         -- v_job_ops(l_counter).LONG_DESCRIPTION               := l_job_op.LONG_DESCRIPTION;
         v_job_ops(l_counter).LAST_UPDATE_DATE               := p_last_update_date;
         v_job_ops(l_counter).LAST_UPDATED_BY                := p_last_updated_by;
         v_job_ops(l_counter).LAST_UPDATE_LOGIN              := p_last_update_login;
         v_job_ops(l_counter).CREATION_DATE                  := p_creation_date;
         v_job_ops(l_counter).CREATED_BY                     := p_created_by;
         v_job_ops(l_counter).REQUEST_ID                     := p_request_id;
         v_job_ops(l_counter).PROGRAM_APPLICATION_ID         := p_program_app_id;
         v_job_ops(l_counter).PROGRAM_ID                     := p_program_id;
         v_job_ops(l_counter).PROGRAM_UPDATE_DATE            := p_program_update_date;
         v_job_ops(l_counter).ATTRIBUTE_CATEGORY             := l_job_op.ATTRIBUTE_CATEGORY;
         v_job_ops(l_counter).ATTRIBUTE1                     := l_job_op.ATTRIBUTE1;
         v_job_ops(l_counter).ATTRIBUTE2                     := l_job_op.ATTRIBUTE2;
         v_job_ops(l_counter).ATTRIBUTE3                     := l_job_op.ATTRIBUTE3;
         v_job_ops(l_counter).ATTRIBUTE4                     := l_job_op.ATTRIBUTE4;
         v_job_ops(l_counter).ATTRIBUTE5                     := l_job_op.ATTRIBUTE5;
         v_job_ops(l_counter).ATTRIBUTE6                     := l_job_op.ATTRIBUTE6;
         v_job_ops(l_counter).ATTRIBUTE7                     := l_job_op.ATTRIBUTE7;
         v_job_ops(l_counter).ATTRIBUTE8                     := l_job_op.ATTRIBUTE8;
         v_job_ops(l_counter).ATTRIBUTE9                     := l_job_op.ATTRIBUTE9;
         v_job_ops(l_counter).ATTRIBUTE10                    := l_job_op.ATTRIBUTE10;
         v_job_ops(l_counter).ATTRIBUTE11                    := l_job_op.ATTRIBUTE11;
         v_job_ops(l_counter).ATTRIBUTE12                    := l_job_op.ATTRIBUTE12;
         v_job_ops(l_counter).ATTRIBUTE13                    := l_job_op.ATTRIBUTE13;
         v_job_ops(l_counter).ATTRIBUTE14                    := l_job_op.ATTRIBUTE14;
         v_job_ops(l_counter).ATTRIBUTE15                    := l_job_op.ATTRIBUTE15;
         v_job_ops(l_counter).ORIGINAL_SYSTEM_REFERENCE      := l_job_op.ORIGINAL_SYSTEM_REFERENCE;
         v_job_ops(l_counter).LOWEST_ACCEPTABLE_YIELD        := l_job_op.LOWEST_ACCEPTABLE_YIELD; --mes
         t_eff_opseq_num(l_job_op.operation_sequence_id) := l_job_op.operation_seq_num;
         t_eff_opseqid_pos(l_job_op.operation_sequence_id) := l_counter;

         If l_job_op.operation_seq_num = 1 then
                l_opseq1_exists := 1;
         End if;

    END LOOP;

     IF v_job_ops.count = 0 THEN
        -- No valid operations exist for the job
        fnd_message.set_name('WSM', 'WSM_NO_VALID_OPS');
        x_err_buf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.process_job_op_nw('||l_stmt_num||'): '||x_err_buf);
        x_err_code := -2;   -- Error

        return;
    END IF;

    l_counter :=0;
    l_stmt_num := 20;

    FOR l_job_nw in c_job_nw LOOP

        If T_eff_opseq_id.exists(l_job_nw.from_op_seq_id) THEN
                l_from_op_seq_id:= t_eff_opseq_id(l_job_nw.from_op_seq_id);
        else
                l_from_op_seq_id:= l_job_nw.from_op_seq_id;
        end if;

        If T_eff_opseq_id.exists(l_job_nw.to_op_seq_id) THEN
                l_to_op_seq_id:= t_eff_opseq_id(l_job_nw.to_op_seq_id);
        else
                l_to_op_seq_id:= l_job_nw.to_op_seq_id;
        end if;

        -- start bug 4448718
        IF l_job_nw.TRANSITION_TYPE = 1 THEN
           next_op_prim_path(l_from_op_seq_id) := l_to_op_seq_id;
        END IF;
        -- end bug 4448718

        --Following check is required because cursor c_eff_opseq_id
        --cannot indentify the operations from bon which do not have
        --effective operation in bos.

        -- start bug 4448718
        if  (t_eff_opseq_num.exists(l_from_op_seq_id) and
             t_eff_opseq_num.exists(l_to_op_seq_id)) OR
            (t_eff_opseq_num.exists(l_from_op_seq_id) AND
             l_job_nw.TRANSITION_TYPE = 1)
        then

           l_from_op_seq_num := t_eff_opseq_num(l_from_op_seq_id);

           IF t_eff_opseq_num.exists(l_to_op_seq_id) THEN
                      l_to_op_seq_num   := t_eff_opseq_num(l_to_op_seq_id);
           ELSE
              l_to_op_seq_num := NULL;
              l_to_op_seq_id  := NULL;
              disabled_prim_path := TRUE;
           END IF;

        -- End bug 4448718

           l_counter := l_counter + 1;

           v_job_nw(l_counter).WIP_ENTITY_ID             := p_wip_entity_id;
           v_job_nw(l_counter).FROM_OP_SEQ_ID            := l_from_op_seq_id;
           v_job_nw(l_counter).TO_OP_SEQ_ID              := l_to_op_seq_id;
           v_job_nw(l_counter).FROM_OP_SEQ_NUM           := l_from_op_seq_num;
           v_job_nw(l_counter).TO_OP_SEQ_NUM             := l_to_op_seq_num;
           v_job_nw(l_counter).RECOMMENDED               := l_job_nw.RECOMMENDED;
           v_job_nw(l_counter).ROUTING_SEQUENCE_ID       := p_common_rtg_seq_id;
           v_job_nw(l_counter).TRANSITION_TYPE           := l_job_nw.TRANSITION_TYPE;
           v_job_nw(l_counter).PLANNING_PCT              := l_job_nw.PLANNING_PCT;
           v_job_nw(l_counter).LAST_UPDATE_DATE          := p_last_update_date;
           v_job_nw(l_counter).LAST_UPDATED_BY           := p_last_updated_by;
           v_job_nw(l_counter).LAST_UPDATE_LOGIN         := p_last_update_login;
           v_job_nw(l_counter).CREATION_DATE             := p_creation_date;
           v_job_nw(l_counter).CREATED_BY                := p_created_by;
           v_job_nw(l_counter).REQUEST_ID                := p_request_id;
           v_job_nw(l_counter).PROGRAM_APPLICATION_ID    := p_program_app_id;
           v_job_nw(l_counter).PROGRAM_ID                := p_program_id;
           v_job_nw(l_counter).PROGRAM_UPDATE_DATE       := p_program_update_date;
           v_job_nw(l_counter).ATTRIBUTE_CATEGORY        := l_job_nw.ATTRIBUTE_CATEGORY;
           v_job_nw(l_counter).ATTRIBUTE1                := l_job_nw.ATTRIBUTE1;
           v_job_nw(l_counter).ATTRIBUTE2                := l_job_nw.ATTRIBUTE2;
           v_job_nw(l_counter).ATTRIBUTE3                := l_job_nw.ATTRIBUTE3;
           v_job_nw(l_counter).ATTRIBUTE4                := l_job_nw.ATTRIBUTE4;
           v_job_nw(l_counter).ATTRIBUTE5                := l_job_nw.ATTRIBUTE5;
           v_job_nw(l_counter).ATTRIBUTE6                := l_job_nw.ATTRIBUTE6;
           v_job_nw(l_counter).ATTRIBUTE7                := l_job_nw.ATTRIBUTE7;
           v_job_nw(l_counter).ATTRIBUTE8                := l_job_nw.ATTRIBUTE8;
           v_job_nw(l_counter).ATTRIBUTE9                := l_job_nw.ATTRIBUTE9;
           v_job_nw(l_counter).ATTRIBUTE10               := l_job_nw.ATTRIBUTE10;
           v_job_nw(l_counter).ATTRIBUTE11               := l_job_nw.ATTRIBUTE11;
           v_job_nw(l_counter).ATTRIBUTE12               := l_job_nw.ATTRIBUTE12;
           v_job_nw(l_counter).ATTRIBUTE13               := l_job_nw.ATTRIBUTE13;
           v_job_nw(l_counter).ATTRIBUTE14               := l_job_nw.ATTRIBUTE14;
           v_job_nw(l_counter).ATTRIBUTE15               := l_job_nw.ATTRIBUTE15;
           v_job_nw(l_counter).ORIGINAL_SYSTEM_REFERENCE := l_job_nw.ORIGINAL_SYSTEM_REFERENCE;
        end if;
    END LOOP;

    -- start bug 4448718
    l_stmt_num := 20.1;

    IF disabled_prim_path THEN
        FOR i in 1..v_job_nw.count LOOP
        IF v_job_nw(i).TO_OP_SEQ_ID IS NULL THEN
           l_from_op_seq_id :=  v_job_nw(i).FROM_OP_SEQ_ID;
           WHILE (next_op_prim_path.exists(l_from_op_seq_id)) LOOP
              l_to_op_seq_id := next_op_prim_path(l_from_op_seq_id);
              IF t_eff_opseq_num.exists(l_to_op_seq_id) THEN
                IF T_eff_opseq_id.exists(l_to_op_seq_id) THEN
                    v_job_nw(i).TO_OP_SEQ_ID   := T_eff_opseq_id(l_to_op_seq_id);
                    v_job_nw(i).TO_OP_SEQ_NUM  := t_eff_opseq_num(v_job_nw(i).TO_OP_SEQ_ID);
                --Bug 5371323:Start of changes
                ELSE
                    v_job_nw(i).TO_OP_SEQ_ID   := l_to_op_seq_id;
                    v_job_nw(i).TO_OP_SEQ_NUM  := t_eff_opseq_num(l_to_op_seq_id);
                --Bug 5371323:End of changes
                END IF;
                exit;
              ELSE
                  l_from_op_seq_id := next_op_prim_path(l_from_op_seq_id);
              END IF;
           END LOOP;
       END IF;
       END LOOP;
    END IF;

    next_op_prim_path.delete;

    -- End bug 4448718
     IF (v_job_nw.COUNT = 0) THEN
        -- Eg - Earlier routing was 10 -> 20.
        -- Now a new op is added and network changed to 10->30->20
        -- Refresh is run, But as of the job's rtg rev date, only ops 10 and 20 are effective
        -- In this case, the job has valid ops 10, 20; but no valid network.

        -- No valid network links exist for the job
        fnd_message.set_name('WSM', 'WSM_NO_VALID_NWK_LINKS');
        x_err_buf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.process_job_op_nw('||l_stmt_num||'): '||x_err_buf);
        x_err_code := -2;   -- Error

        return;   -- This should not be commented out, since later it may get overwritten.
                  -- Fixed bug #3465125
     END IF;

    l_end_op_seq_id := 0;
    l_start_op_seq_id := 0;
    l_start_op_seq_num := 0;


    --Get the last operation

    FOR i in 1..v_job_nw.count LOOP
       l_counter := 0;
      --Change for bug 4448718;Added check on transition type.
      -- as if there are operations on alt path without without
      --next operation, such op should not be taken as
      --last operation.
       IF  v_job_nw(i).transition_type = 1 THEN
        For j in 1..v_job_nw.count LOOP
                If  v_job_nw(i).to_op_seq_id = v_job_nw(j).from_op_seq_id then
                 -- To op seq id of i is not last operation.
                   l_counter := -1;
                  exit;
                End if;
        END LOOP;
       ELSE
         l_counter := -1;
       END IF;
--If it comes to this, it means that no from op exists as to op of i. Hence to op of I is last operation.
        if  l_counter <>  -1 then
                 l_end_op_seq_id:= v_job_nw(i).to_op_seq_id;
                 exit;
        end if;

    END LOOP;
    --Get first operation

     For i in 1..v_job_nw.count LOOP
       l_counter := 0;
       IF  v_job_nw(i).transition_type = 1 THEN
        For j in 1..v_job_nw.count LOOP
                If  v_job_nw(i).from_op_seq_id = v_job_nw(j).to_op_seq_id then

                 -- From op seq id of i is not start operation.
                   l_counter := -1;
                  Exit;
                End if;
        END LOOP;
       ELSE
         l_counter := -1;
       END IF;
--If it comes to this, it means that no to op exists as from op of i. Hence from op of I is start operation.
        if  l_counter <> -1 then
            l_start_op_seq_id:= v_job_nw(i).from_op_seq_id;
            exit;
        end if;

    END LOOP;
    --Determine the reco path sequence number
    l_stmt_num := 30;


    If t_eff_opseq_num.exists(l_start_op_seq_id) then
        v_job_ops(t_eff_opseqid_pos(l_start_op_seq_id)).network_start_end := 'S';
        l_start_op_seq_num := t_eff_opseq_num(l_start_op_seq_id);
    else
          fnd_message.set_name('WSM', 'WSM_NET_START_NOT_EFFECTIVE');
          --x_err_buf := fnd_message.get;
           x_err_buf := 'l_count is'||to_char(l_start_op_seq_id);
          fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||'): '||x_err_buf);
          x_err_code := -1;   -- Warning
          --Bug 4264364:Added exception handling
          INSERT into WSM_LOT_BASED_JOBS
              (WIP_ENTITY_ID,
               ORGANIZATION_ID,
               ON_REC_PATH,
               INTERNAL_COPY_TYPE,
               COPY_PARENT_WIP_ENTITY_ID,
               INFINITE_SCHEDULE,
               ROUTING_REFRESH_DATE,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               CREATION_DATE,
               CREATED_BY,
               REQUEST_ID,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_UPDATE_DATE
               )
          VALUES
               (p_wip_entity_id,
                p_org_id,
                'N',
                 3,
                 NULL,
                 NULL,
                 SYSDATE,
                 p_last_update_date,
                 p_last_updated_by,
                 p_last_update_login,
                 p_creation_date,
                 p_created_by,
                 p_request_id,
                 p_program_app_id,
                 p_program_id,
                 p_program_update_date);

          raise e_noneff_op;
    End if;

    l_stmt_num := 40;
    If t_eff_opseq_num.exists(l_end_op_seq_id) then
       v_job_ops(t_eff_opseqid_pos(l_end_op_seq_id)).network_start_end := 'E';
       l_reco_path_seq_num := 1;
       v_job_ops(t_eff_opseqid_pos(l_end_op_seq_id)).reco_path_seq_num := l_reco_path_seq_num;
       v_job_ops(t_eff_opseqid_pos(l_end_op_seq_id)).recommended := 'Y';
    else
           l_reco_path_seq_num := -1;
           fnd_message.set_name('WSM', 'WSM_NET_END_NOT_EFFECTIVE');
           x_err_buf := fnd_message.get;
           fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.process_job_op_nw('||l_stmt_num||'): '||x_err_buf);
           x_err_code := -1;   -- Warning

          --Bug 4264364:Added exception handling
           INSERT into WSM_LOT_BASED_JOBS
              (WIP_ENTITY_ID,
               ORGANIZATION_ID,
               ON_REC_PATH,
               INTERNAL_COPY_TYPE,
               COPY_PARENT_WIP_ENTITY_ID,
               INFINITE_SCHEDULE,
               ROUTING_REFRESH_DATE,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               CREATION_DATE,
               CREATED_BY,
               REQUEST_ID,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_UPDATE_DATE
               )
          VALUES
               (p_wip_entity_id,
                p_org_id,
                'N',
                 3,
                 NULL,
                 NULL,
                 SYSDATE,
                 p_last_update_date,
                 p_last_updated_by,
                 p_last_update_login,
                 p_creation_date,
                 p_created_by,
                 p_request_id,
                 p_program_app_id,
                 p_program_id,
                 p_program_update_date);

          raise e_noneff_op;
    End if;

    if l_reco_path_seq_num = 1 then
            l_curr_opseq_id := l_end_op_seq_id;
            l_go_to_next_level := true;
            While l_go_to_next_level LOOP
                l_go_to_next_level := false;
                For i in 1..v_job_nw.count LOOP
                        If  v_job_nw(i).to_op_seq_id = l_curr_opseq_id
                        and v_job_nw(i).transition_type = 1 then
                        --The below check will always be true as non effective ops
                        --are already filtered in  v_job_nw
                        --and t_eff_opseq_num.exists(v_job_nw(i).from_op_seq_id) then
                                  v_job_ops(t_eff_opseqid_pos(v_job_nw(i).from_op_seq_id)).recommended := 'Y';
                                  l_reco_path_seq_num:=l_reco_path_seq_num+1;
                                  v_job_ops(t_eff_opseqid_pos(v_job_nw(i).from_op_seq_id)).reco_path_seq_num := l_reco_path_seq_num;
                                  l_curr_opseq_id := v_job_nw(i).from_op_seq_id;
                                  l_go_to_next_level := true;
                                  Exit;
                        End if;
                End loop; -- for loop end
            END LOOP; --While loop end

            --Update reco_path_seq_num for all ops starting from
            --l_reco_path_seq_num to net work end operation.
             For i in 1..v_job_ops.count LOOP
                if v_job_ops(i).reco_path_seq_num > 0 then
                 v_job_ops(i).reco_path_seq_num:= l_reco_path_seq_num+1-v_job_ops(i).reco_path_seq_num;
                end if;
             END LOOP;
    end if;  --end of check on l_reco_path_seq_num
    l_stmt_num := 40.1;
   If l_curr_opseq_id <> l_start_op_seq_id or l_reco_path_seq_num = -1 then
           fnd_message.set_name('WSM', 'WSM_DISABLED_PRIMARY_PATH');
           x_err_buf := fnd_message.get;
           fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.process_job_op_nw('||l_stmt_num||'): '||x_err_buf);
           x_err_code := -1;   -- Warning
           l_inf_sch_flag := 'N';  -- Do not infinite schedule this job
   END IF;

    l_stmt_num := 40.2;
  IF l_reco_path_seq_num <> -1 THEN
        --
          for i in 1..v_job_nw.count LOOP
             if v_job_ops(t_eff_opseqid_pos(v_job_nw(i).from_op_seq_id)).recommended = 'Y'
             and v_job_ops(t_eff_opseqid_pos(v_job_nw(i).to_op_seq_id)).recommended = 'Y'
             and v_job_nw(i).transition_type = 1 then --Code review remark
                v_job_nw(i).recommended := 'Y';
             end if;
          end loop;
  END IF;

    -- Insert the records into WCO ---
    forall l_index in v_job_ops.first..v_job_ops.last
            INSERT INTO WSM_COPY_OPERATIONS
            values v_job_ops(l_index);

   --Start changes for 4448718
    -- insert records..
    --Remove any duplicate rows
    IF disabled_prim_path THEN
     disabled_prim_path := FALSE;
     l_stmt_num := 40.2;
     l_counter := 0;
     FOR i in v_job_nw.first..v_job_nw.last  LOOP
             IF  v_job_nw(i).transition_type = 1 THEN
                 l_stmt_num := 40.3;
                 FOR j in v_job_nw.first..v_job_nw.last  LOOP
                     l_stmt_num := 40.4;
                    IF  v_job_nw(j).transition_type <> 1 and
                        v_job_nw(i).TO_OP_SEQ_NUM = v_job_nw(j).TO_OP_SEQ_NUM AND
                        v_job_nw(i).FROM_OP_SEQ_NUM = v_job_nw(j).FROM_OP_SEQ_NUM THEN
                        l_stmt_num := 40.5;
                        l_counter := l_counter+1;
                        v_job_nw_delete(l_counter) := j;
                    END IF;
                 End LOOP;
             END IF;
      END LOOP;
      IF l_counter > 0 THEN
        FOR i in v_job_nw_delete.first..v_job_nw_delete.last LOOP
          v_job_nw.delete(v_job_nw_delete(i));
        END LOOP;
      END IF;

      v_job_nw_delete.delete;
    END IF;
   --End changes for 4448718

    l_stmt_num := 40.6;
   -- Changes for 4448718: Used INDICES of as there can be
   -- null values in the table because of the deletion
   -- in the previous statement.
    --forall l_index in v_job_nw.first..v_job_nw.last
    forall l_index in INDICES OF v_job_nw
        INSERT into WSM_COPY_OP_NETWORKS
        values v_job_nw(l_index);

    --This is not needed when called from wlt code
        l_counter := t_eff_opseqid_pos(l_start_op_seq_id);
    --  free up the used memory !!!
    v_job_ops.delete;
    v_job_nw.delete;


    -- ***** Make a copy of the primary Resources for the job ***** --
    INSERT INTO WSM_COPY_OP_RESOURCES
            (WIP_ENTITY_ID,
             OPERATION_SEQ_NUM,
             RESOURCE_SEQ_NUM,
             ORGANIZATION_ID,
             SUBSTITUTE_GROUP_NUM,
             REPLACEMENT_GROUP_NUM,
             RECOMMENDED,
             RECO_START_DATE,
             RECO_COMPLETION_DATE,
             RESOURCE_ID,
             RESOURCE_CODE,
             DEPARTMENT_ID,
             PHANTOM_FLAG,
             PHANTOM_OP_SEQ_NUM,
             PHANTOM_ITEM_ID,
             ACTIVITY_ID,
             STANDARD_RATE_FLAG,
             ASSIGNED_UNITS,
             -- ST : Detailed Scheduling
             MAX_ASSIGNED_UNITS,
             FIRM_TYPE,
             -- ST : Detailed Scheduling
             USAGE_RATE_OR_AMOUNT,
             USAGE_RATE_OR_AMOUNT_INVERSE,
             UOM_CODE,
             BASIS_TYPE,
             SCHEDULE_FLAG,
             RESOURCE_OFFSET_PERCENT,
             AUTOCHARGE_TYPE,
             SCHEDULE_SEQ_NUM,
             PRINCIPLE_FLAG,
             SETUP_ID,
             CHANGE_NOTICE,
             ACD_TYPE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
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
             ATTRIBUTE15,
             ORIGINAL_SYSTEM_REFERENCE
            )
       SELECT  p_WIP_ENTITY_ID,
            --bos.OPERATION_SEQ_NUM,
            wco.OPERATION_SEQ_NUM,
            bor.RESOURCE_SEQ_NUM,
            p_ORG_ID,
            bor.SUBSTITUTE_GROUP_NUM,
            0,   --REPLACEMENT_GROUP_NUM
            'Y', --RECOMMENDED
            NULL, --RECO_START_DATE
            NULL, --RECO_COMPLETION_DATE
            bor.RESOURCE_ID,
            br.RESOURCE_CODE,
            NULL, --DEPARTMENT_ID - this is NULL for non-phantom component resources
            NULL, --PHANTOM_FLAG
            NULL, --PHANTOM_OP_SEQ_NUM
            NULL, --PHANTOM_ITEM_ID
            bor.ACTIVITY_ID,
            bor.STANDARD_RATE_FLAG,
            bor.ASSIGNED_UNITS,
            -- ST : Detailed Scheduling
            bor.ASSIGNED_UNITS,
            0,   -- None - NOT FIRMED
            -- ST : Detailed Scheduling
            bor.USAGE_RATE_OR_AMOUNT,
            bor.USAGE_RATE_OR_AMOUNT_INVERSE,
            br.UNIT_OF_MEASURE,
            bor.BASIS_TYPE,
            bor.SCHEDULE_FLAG,
            bor.RESOURCE_OFFSET_PERCENT,
            bor.AUTOCHARGE_TYPE,
            bor.SCHEDULE_SEQ_NUM,
            bor.PRINCIPLE_FLAG,
            bor.SETUP_ID,
            bor.CHANGE_NOTICE,
            bor.ACD_TYPE,
            p_last_update_date,
            p_last_updated_by,
            p_last_update_login,
            p_creation_date,
            p_created_by,
            p_request_id,
            p_program_app_id,
            p_program_id,
            p_program_update_date,
            bor.ATTRIBUTE_CATEGORY,
            bor.ATTRIBUTE1,
            bor.ATTRIBUTE2,
            bor.ATTRIBUTE3,
            bor.ATTRIBUTE4,
            bor.ATTRIBUTE5,
            bor.ATTRIBUTE6,
            bor.ATTRIBUTE7,
            bor.ATTRIBUTE8,
            bor.ATTRIBUTE9,
            bor.ATTRIBUTE10,
            bor.ATTRIBUTE11,
            bor.ATTRIBUTE12,
            bor.ATTRIBUTE13,
            bor.ATTRIBUTE14,
            bor.ATTRIBUTE15,
            bor.ORIGINAL_SYSTEM_REFERENCE
    FROM    BOM_RESOURCES br,
            BOM_OPERATION_RESOURCES bor,
            wsm_copy_operations wco
    WHERE   wco.wip_entity_id = p_wip_entity_id
    AND     WCO.OPERATION_SEQUENCE_ID = bor.OPERATION_SEQUENCE_ID
    AND     bor.RESOURCE_ID = br.RESOURCE_ID
    AND     br.ORGANIZATION_ID = p_org_id;

    IF SQL%ROWCOUNT > 0 THEN --Added for 4635447
           IF (g_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'Created '||SQL%ROWCOUNT||' records in WCOR (pri res) for we_id='||p_wip_entity_id);
           END IF;

    --IF SQL%ROWCOUNT > 0 THEN --Bug 4635477
        --Look for substitute resources only when at least one primary resource
        --exists.


            select OPERATION_SEQ_NUM,resource_seq_num
            bulk collect into v_op_seq_id,v_res_seq
            from   WSM_COPY_OP_RESOURCES wcor
            where  wcor.wip_entity_id = p_wip_entity_id;

            FOR i in 1..v_op_seq_id.count LOOP

                IF v_max_res_seq.exists(v_op_seq_id(i)) AND
                   v_max_res_seq(v_op_seq_id(i)) < v_res_seq(i) THEN
                   v_max_res_seq(v_op_seq_id(i)) := v_res_seq(i);
                ELSE
                  v_max_res_seq(v_op_seq_id(i)) := v_res_seq(i);
                END IF;

            end loop;


    l_stmt_num := 140;

    -- ***** Make a copy of the substitute Resources for the job ***** --
            INSERT INTO WSM_COPY_OP_RESOURCES
                    (WIP_ENTITY_ID,
                     OPERATION_SEQ_NUM,
                     RESOURCE_SEQ_NUM,
                     ORGANIZATION_ID,
                     SUBSTITUTE_GROUP_NUM,
                     REPLACEMENT_GROUP_NUM,
                     RECOMMENDED,
                     RECO_START_DATE,
                     RECO_COMPLETION_DATE,
                     RESOURCE_ID,
                     RESOURCE_CODE,
                     ACTIVITY_ID,
                     STANDARD_RATE_FLAG,
                     ASSIGNED_UNITS,
                     -- ST : Detailed Scheduling
                     MAX_ASSIGNED_UNITS,
                     FIRM_TYPE,
                     -- ST : Detailed Scheduling
                     USAGE_RATE_OR_AMOUNT,
                     USAGE_RATE_OR_AMOUNT_INVERSE,
                     UOM_CODE,
                     BASIS_TYPE,
                     SCHEDULE_FLAG,
                     RESOURCE_OFFSET_PERCENT,
                     AUTOCHARGE_TYPE,
                     SCHEDULE_SEQ_NUM,
                     PRINCIPLE_FLAG,
                     SETUP_ID,
                     CHANGE_NOTICE,
                     ACD_TYPE,
                     PHANTOM_FLAG,
                     PHANTOM_OP_SEQ_NUM,
                     PHANTOM_ITEM_ID,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_LOGIN,
                     CREATION_DATE,
                     CREATED_BY,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
                     PROGRAM_UPDATE_DATE,
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
                     ATTRIBUTE15,
                     ORIGINAL_SYSTEM_REFERENCE
                    )
            SELECT  p_WIP_ENTITY_ID,
                    WCO.OPERATION_SEQ_NUM,
                    rownum + max_res_seq(WCO.operation_seq_num),
                    p_org_id,
                    bsor.SUBSTITUTE_GROUP_NUM,
                    bsor.REPLACEMENT_GROUP_NUM,
                    'N', --RECOMMENDED
                    NULL, --RECO_START_DATE
                    NULL, --RECO_COMPLETION_DATE
                    bsor.RESOURCE_ID,
                    br.RESOURCE_CODE,
                    bsor.ACTIVITY_ID,
                    bsor.STANDARD_RATE_FLAG,
                    bsor.ASSIGNED_UNITS,
                    bsor.ASSIGNED_UNITS,
                    0, -- None - NOT FIRMED
                    bsor.USAGE_RATE_OR_AMOUNT,
                    bsor.USAGE_RATE_OR_AMOUNT_INVERSE,
                    br.UNIT_OF_MEASURE,
                    bsor.BASIS_TYPE,
                    bsor.SCHEDULE_FLAG,
                    bsor.RESOURCE_OFFSET_PERCENT,
                    bsor.AUTOCHARGE_TYPE,
                    bsor.SCHEDULE_SEQ_NUM,
                    bsor.PRINCIPLE_FLAG,
                    bsor.SETUP_ID,
                    bsor.CHANGE_NOTICE,
                    bsor.ACD_TYPE,
                    NULL, --PHANTOM_FLAG
                    NULL, --PHANTOM_OP_SEQ_NUM
                    NULL, --PHANTOM_ITEM_ID
                    p_last_update_date,
                    p_last_updated_by,
                    p_last_update_login,
                    p_creation_date,
                    p_created_by,
                    p_request_id,
                    p_program_app_id,
                    p_program_id,
                    p_program_update_date,
                    bsor.ATTRIBUTE_CATEGORY,
                    bsor.ATTRIBUTE1,
                    bsor.ATTRIBUTE2,
                    bsor.ATTRIBUTE3,
                    bsor.ATTRIBUTE4,
                    bsor.ATTRIBUTE5,
                    bsor.ATTRIBUTE6,
                    bsor.ATTRIBUTE7,
                    bsor.ATTRIBUTE8,
                    bsor.ATTRIBUTE9,
                    bsor.ATTRIBUTE10,
                    bsor.ATTRIBUTE11,
                    bsor.ATTRIBUTE12,
             -       bsor.ATTRIBUTE13,
                    bsor.ATTRIBUTE14,
                    bsor.ATTRIBUTE15,
                    bsor.ORIGINAL_SYSTEM_REFERENCE
            FROM    BOM_RESOURCES br,
                    BOM_SUB_OPERATION_RESOURCES bsor,
                    WSM_COPY_OPERATIONS WCO
            WHERE   WCO.wip_entity_id = p_wip_entity_id
            AND     bsor.RESOURCE_ID = br.RESOURCE_ID
            AND     WCO.OPERATION_SEQUENCE_ID = bsor.OPERATION_SEQUENCE_ID;

            IF (g_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'Created '||SQL%ROWCOUNT||' records in WCOR (subs res) for we_id='||p_wip_entity_id);
            END IF;
    END IF;--Check on SQL%ROWCOUNT

    if p_phantom_exists = 2 and p_common_bill_seq_id IS NOT NULL THEN --Code review remark
     l_phantom_org_id := p_org_id; --Added for bug 4515000
     --Populate primary and  substitute components. As no phantom exists
     --no need for calling bom exploder code.
    INSERT INTO WSM_COPY_REQUIREMENT_OPS
        (WIP_ENTITY_ID,
         OPERATION_SEQ_NUM,
         COMPONENT_ITEM_ID,
         PRIMARY_COMPONENT_ID,
         COMPONENT_SEQUENCE_ID,
         SOURCE_PHANTOM_ID,
         RECOMMENDED,
         RECO_DATE_REQUIRED,
         BILL_SEQUENCE_ID,
         DEPARTMENT_ID,
         ORGANIZATION_ID,
         WIP_SUPPLY_TYPE,
         SUPPLY_SUBINVENTORY,
         SUPPLY_LOCATOR_ID,
         QUANTITY_PER_ASSEMBLY,
         BILL_QUANTITY_PER_ASSEMBLY,
         COMPONENT_YIELD_FACTOR,
         BASIS_TYPE,                 --LBM enh
         EFFECTIVITY_DATE,
         DISABLE_DATE,
         COMPONENT_PRIORITY,
         PARENT_BILL_SEQ_ID,
         ITEM_NUM,
         COMPONENT_REMARKS,
         CHANGE_NOTICE,
         IMPLEMENTATION_DATE,
         PLANNING_FACTOR,
         QUANTITY_RELATED,
         SO_BASIS,
         OPTIONAL,
         MUTUALLY_EXCLUSIVE_OPTIONS,
         INCLUDE_IN_COST_ROLLUP,
         CHECK_ATP,
         SHIPPING_ALLOWED,
         REQUIRED_TO_SHIP,
         REQUIRED_FOR_REVENUE,
         INCLUDE_ON_SHIP_DOCS,
         LOW_QUANTITY,
         HIGH_QUANTITY,
         ACD_TYPE,
         OLD_COMPONENT_SEQUENCE_ID,
         OPERATION_LEAD_TIME_PERCENT,
         REVISED_ITEM_SEQUENCE_ID,
         BOM_ITEM_TYPE,
         FROM_END_ITEM_UNIT_NUMBER,
         TO_END_ITEM_UNIT_NUMBER,
         ECO_FOR_PRODUCTION,
         ENFORCE_INT_REQUIREMENTS,
         DELETE_GROUP_NAME,
         DG_DESCRIPTION,
         OPTIONAL_ON_MODEL,
         MODEL_COMP_SEQ_ID,
         PLAN_LEVEL,
         AUTO_REQUEST_MATERIAL,
         COMPONENT_ITEM_REVISION_ID,
         FROM_BILL_REVISION_ID,
         TO_BILL_REVISION_ID,
         PICK_COMPONENTS,
         INCLUDE_ON_BILL_DOCS,
         COST_FACTOR,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CREATION_DATE,
         CREATED_BY,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
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
         ATTRIBUTE15,
         ORIGINAL_SYSTEM_REFERENCE
        )
        select  p_wip_entity_id,
                decode(A.operation_seq_num,1,decode(l_opseq1_exists,1,A.operation_seq_num,l_start_op_seq_num),A.operation_seq_num),
         a.COMPONENT_ITEM_ID,
         a.COMPONENT_ITEM_ID,
         a.COMPONENT_SEQUENCE_ID,
         -1,
         'Y', --Recommended
         null, --RECO_DATE_REQUIRED,
         a.BILL_SEQUENCE_ID,
         bos.DEPARTMENT_ID,
         c.ORGANIZATION_ID,
         decode(p_wip_supply_type,
                   7,
                   nvl(a.wip_supply_type, nvl(c.wip_supply_type, 1)),
                   p_wip_supply_type),
            --Bug 5216333: Suppy type specified at job should be looked at first
         decode (p_org_id,
                    l_phantom_org_id,
                    nvl(a.supply_subinventory,
                        nvl(c.wip_supply_subinventory,
                            decode(decode(p_wip_supply_type,7,nvl(a.wip_supply_type, nvl(c.wip_supply_type, 1)),p_wip_supply_type),
                                   2,
                                   l_wip_param_def_subinv,
                                   3,
                                   l_wip_param_def_subinv,
                                   null
                                  )
                           )
                       ),
                    nvl(c.wip_supply_subinventory,
                        decode(decode(p_wip_supply_type,7,nvl(a.wip_supply_type, nvl(c.wip_supply_type, 1)),p_wip_supply_type),
                               2,
                               l_wip_param_def_subinv,
                               3,
                               l_wip_param_def_subinv,
                               null
                              )
                       )
                   ),--a.SUPPLY_SUBINVENTORY,
            --Bug 5216333: Suppy type specified at job should be looked at first
         decode (p_org_id,     -- supply locator id begin
                    l_phantom_org_id,
                    decode (a.supply_subinventory,
                            null,
                            decode (c.wip_supply_subinventory,
                                    null,
                                    decode(decode(p_wip_supply_type,7,nvl(a.wip_supply_type,
                                               nvl(c.wip_supply_type,1)),p_wip_supply_type),
                                           2,
                                           --nvl(l_wip_param_def_locator_id,-1),
                                           l_wip_param_def_locator_id,
                                           3,
                                           --nvl(l_wip_param_def_locator_id,-1),
                                           l_wip_param_def_locator_id,
                                           null
                                          ),
                                    c.wip_supply_locator_id
                                   ),
                            a.supply_locator_id
                           ),
                    --The org id will always be equal to phantom org id.So the
                    --decode below is redundant.
                    decode (c.wip_supply_subinventory,
                            null,
                            decode(decode(p_wip_supply_type,7,nvl(a.wip_supply_type, nvl(c.wip_supply_type, 1)),p_wip_supply_type),
                                   2,
                                   nvl(l_wip_param_def_locator_id,-1),
                                   3,
                                   nvl(l_wip_param_def_locator_id,-1),
                                   null
                                  ),
                            c.wip_supply_locator_id
                           )
                   ), --c.wip_supply_locator_id,
            a.component_quantity / decode(a.component_yield_factor,
                                          0,
                                          1,
                                          a.component_yield_factor
                                         ), --qty per assembly
          a.component_quantity ,
          a.component_yield_factor,
          a.basis_type,                      --LBM enh
          a.effectivity_date ,
          a.disable_date,
          null, --COMPONENT_PRIORITY, -- modified for bug 7016646
          a.parent_bill_seq_id,
          a.item_num,
          a.component_remarks,
          a.change_notice,
          a.implementation_date,
          a.planning_factor,
          a.quantity_related,
          a.so_basis,
          a.optional,
          a.mutually_exclusive_options,
          a.include_in_cost_rollup,
          a.check_atp,
          a.shipping_allowed,
          a.required_to_ship,
          a.required_for_revenue,
          a.include_on_ship_docs,
          a.low_quantity,
          a.high_quantity,
          a.acd_type,
          a.old_component_sequence_id,
          a.operation_lead_time_percent,
          a.revised_item_sequence_id,
          a.bom_item_type,
          a.from_end_item_unit_number,
          a.to_end_item_unit_number,
          a.eco_for_production,
          a.enforce_int_requirements,
          a.delete_group_name,
          a.dg_description,
          a.optional_on_model,
          a.model_comp_seq_id,
          a.plan_level,
          a.auto_request_material,
          a.component_item_revision_id,
          a.from_bill_revision_id,
          a.to_bill_revision_id,
          a.pick_components,
          a.include_on_bill_docs,
          a.cost_factor,
          p_last_update_date,
          p_last_updated_by,
          p_last_update_login,
          p_creation_date,
          p_created_by,
          p_request_id,
          p_program_app_id,
          p_program_id,
          p_program_update_date,
          a.attribute_category,
          a.attribute1,
          a.attribute2,
          a.attribute3,
          a.attribute4,
          a.attribute5,
          a.attribute6,
          a.attribute7,
          a.attribute8,
          a.attribute9,
          a.attribute10,
          a.attribute11,
          a.attribute12,
          a.attribute13,
          a.attribute14,
          a.attribute15,
          a.original_system_reference
        FROM    BOM_INVENTORY_COMPONENTS A,
                MTL_SYSTEM_ITEMS C,
                BOM_OPERATION_SEQUENCES BOS
        WHERE   a.bill_sequence_id = p_common_bill_seq_id
        AND     a.component_item_id = c.inventory_item_id
        AND     c.organization_id = p_org_id
        AND     BOS.routing_sequence_id = p_common_rtg_seq_id
        AND     BOS.operation_seq_num = decode(A.operation_seq_num,1,decode(l_opseq1_exists,1,A.operation_seq_num,l_start_op_seq_num),A.operation_seq_num)
        AND     p_rtg_rev_date between BOS.effectivity_date and nvl(BOS.disable_date, p_rtg_rev_date+1)
        AND     p_bom_rev_date between a.effectivity_date and nvl(a.disable_date, p_bom_rev_date+1);

           IF SQL%ROWCOUNT > 0 THEN
              IF (g_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, 'Created '||SQL%ROWCOUNT||' records in WCR) (Primary Components) for we_id='||p_wip_entity_id);
              END IF;
         --IF SQL%ROWCOUNT > 0 THEN
           --Insert substitute components only when there are primary components.
           INSERT INTO WSM_COPY_REQUIREMENT_OPS
                (WIP_ENTITY_ID,
                 OPERATION_SEQ_NUM,
                 COMPONENT_ITEM_ID,
                 PRIMARY_COMPONENT_ID,
                 COMPONENT_SEQUENCE_ID,
                 SOURCE_PHANTOM_ID,
                 RECOMMENDED,
                 RECO_DATE_REQUIRED,
                 BILL_SEQUENCE_ID,
                 DEPARTMENT_ID,
                 ORGANIZATION_ID,
                 WIP_SUPPLY_TYPE,
                 SUPPLY_SUBINVENTORY,
                 SUPPLY_LOCATOR_ID,
                 QUANTITY_PER_ASSEMBLY,
                 BILL_QUANTITY_PER_ASSEMBLY,
                 COMPONENT_YIELD_FACTOR,
                 BASIS_TYPE,                 --LBM enh
                 EFFECTIVITY_DATE,
                 DISABLE_DATE,
                 COMPONENT_PRIORITY,
                 PARENT_BILL_SEQ_ID,
                 ITEM_NUM,
                 COMPONENT_REMARKS,
                 CHANGE_NOTICE,
                 IMPLEMENTATION_DATE,
                 PLANNING_FACTOR,
                 QUANTITY_RELATED,
                 SO_BASIS,
                 OPTIONAL,
                 MUTUALLY_EXCLUSIVE_OPTIONS,
                 INCLUDE_IN_COST_ROLLUP,
                 CHECK_ATP,
                 SHIPPING_ALLOWED,
                 REQUIRED_TO_SHIP,
                 REQUIRED_FOR_REVENUE,
                 INCLUDE_ON_SHIP_DOCS,
                 LOW_QUANTITY,
                 HIGH_QUANTITY,
                 ACD_TYPE,
                 OLD_COMPONENT_SEQUENCE_ID,
                 OPERATION_LEAD_TIME_PERCENT,
                 REVISED_ITEM_SEQUENCE_ID,
                 BOM_ITEM_TYPE,
                 FROM_END_ITEM_UNIT_NUMBER,
                 TO_END_ITEM_UNIT_NUMBER,
                 ECO_FOR_PRODUCTION,
                 ENFORCE_INT_REQUIREMENTS,
                 DELETE_GROUP_NAME,
                 DG_DESCRIPTION,
                 OPTIONAL_ON_MODEL,
                 MODEL_COMP_SEQ_ID,
                 PLAN_LEVEL,
                 AUTO_REQUEST_MATERIAL,
                 COMPONENT_ITEM_REVISION_ID,
                 FROM_BILL_REVISION_ID,
                 TO_BILL_REVISION_ID,
                 PICK_COMPONENTS,
                 INCLUDE_ON_BILL_DOCS,
                 COST_FACTOR,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 CREATION_DATE,
                 CREATED_BY,
                 REQUEST_ID,
                 PROGRAM_APPLICATION_ID,
                 PROGRAM_ID,
                 PROGRAM_UPDATE_DATE,
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
                 ATTRIBUTE15,
                 ORIGINAL_SYSTEM_REFERENCE
                )
                 select
                    p_wip_entity_id,
                    wcro.OPERATION_SEQ_NUM,
                    a.SUBSTITUTE_COMPONENT_ID,
                    wcro.COMPONENT_ITEM_ID,
                    a.COMPONENT_SEQUENCE_ID,
                    -1,
                    'N', --Recommended
                    null, --RECO_DATE_REQUIRED,
                    wcro.BILL_SEQUENCE_ID,
                    wcro.DEPARTMENT_ID,
                    c.ORGANIZATION_ID,
                    wcro.WIP_SUPPLY_TYPE,
                    wcro.SUPPLY_SUBINVENTORY,
                    wcro.supply_locator_id,
                    a.substitute_item_quantity / decode(wcro.component_yield_factor,
                                                      0,
                                                      1,
                                                      wcro.component_yield_factor
                                                     ), --qty per assembly
                    a.SUBSTITUTE_ITEM_QUANTITY,
                    wcro.component_yield_factor,
                    wcro.basis_type,                      --LBM enh
                    wcro.effectivity_date ,
                    wcro.disable_date,
                    a.attribute1, --COMPONENT_PRIORITY,
                    wcro.parent_bill_seq_id,
                    wcro.item_num,
                    wcro.component_remarks,
                    a.change_notice,
                    wcro.implementation_date,
                    wcro.planning_factor,
                    wcro.quantity_related,
                    wcro.so_basis,
                    wcro.optional,
                    wcro.mutually_exclusive_options,
                    wcro.include_in_cost_rollup,
                    wcro.check_atp,
                    wcro.shipping_allowed,
                    wcro.required_to_ship,
                    wcro.required_for_revenue,
                    wcro.include_on_ship_docs,
                    wcro.low_quantity,
                    wcro.high_quantity,
                    a.acd_type,
                    wcro.old_component_sequence_id,
                    wcro.operation_lead_time_percent,
                    wcro.revised_item_sequence_id,
                    wcro.bom_item_type,
                    wcro.from_end_item_unit_number,
                    wcro.to_end_item_unit_number,
                    wcro.eco_for_production,
                    a.enforce_int_requirements,
                    wcro.delete_group_name,
                    wcro.dg_description,
                    wcro.optional_on_model,
                    wcro.model_comp_seq_id,
                    wcro.plan_level,
                    wcro.auto_request_material,
                    wcro.component_item_revision_id,
                    wcro.from_bill_revision_id,
                    wcro.to_bill_revision_id,
                    wcro.pick_components,
                    wcro.include_on_bill_docs,
                    wcro.cost_factor,
                    p_last_update_date,
                    p_last_updated_by,
                    p_last_update_login,
                    p_creation_date,
                    p_created_by,
                    p_request_id,
                    p_program_app_id,
                    p_program_id,
                    p_program_update_date,
                    a.attribute_category,
                    a.attribute1,
                    a.attribute2,
                    a.attribute3,
                    a.attribute4,
                    a.attribute5,
                    a.attribute6,
                    a.attribute7,
                    a.attribute8,
                    a.attribute9,
                    a.attribute10,
                    a.attribute11,
                    a.attribute12,
                    a.attribute13,
                    a.attribute14,
                    a.attribute15,
                    wcro.original_system_reference
                FROM  BOM_SUBSTITUTE_COMPONENTS A,
                       MTL_SYSTEM_ITEMS C,
                       WSM_COPY_REQUIREMENT_OPS wcro
                WHERE     wcro.wip_entity_id = p_wip_entity_id
                AND       a.component_sequence_id = wcro.component_sequence_id
                AND       a.SUBSTITUTE_COMPONENT_ID = c.inventory_item_id
                AND       c.organization_id = p_org_id
		AND       nvl(a.acd_type,1) <> 3; /*Bugfix:8639874.Added condition on acd_type */
        END IF; --End of check on wcro sql rowcount.
        goto SKIP_TILL_HERE;
    end if;--Check on p_phantom_exists

        l_stmt_num := 140;
    -- End : Fix for bug #3313480 --


    -- ***** Make a copy of the Bill (primary and substitute components) for the job ***** --

    IF (p_common_bill_seq_id IS NULL) THEN -- No bill attached to the job
        goto SKIP_TILL_HERE;
    END IF;

    l_stmt_num := 150;

    l_top_level_bill_seq_id := p_bill_seq_id; --p_common_bill_seq_id;
    l_phantom_org_id := p_org_id;

    l_stmt_num := 160;

IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'At stmt('||l_stmt_num||'): Parameters to exploder_userexit for 1st level explosion :');
    fnd_file.put_line(fnd_file.log, 'expl_group_id ='||l_explosion_group_id||
                        ', Bill item_id='||p_bill_item_id||
                        ', alt_desg='||p_alt_bom_desig||
                        ', comp_code=NULL');
END IF;

    bompexpl.exploder_userexit(
            verify_flag       => 0,
            org_id            => p_org_id,
            order_by          => 1,
            grp_id            => l_explosion_group_id,
            session_id        => 0,
            levels_to_explode => 1,
            bom_or_eng        => 1,
            impl_flag         => 1,
            plan_factor_flag  => 1,
            explode_option    => 2,
            module            => 5,
            cst_type_id       => 0,
            std_comp_flag     => 0,
            expl_qty          => 1,
            item_id           => p_bill_item_id, --p_primary_item_id, -- Fix for bug #3347947
            alt_desg          => p_alt_bom_desig,
            comp_code         => '',
            rev_date          => to_char(p_bom_rev_date, DATETIME_FMT),
            err_msg           => l_err_buf,
            error_code        => l_err_code);

    IF (l_err_code <> 0) THEN
        x_err_code := l_err_code;
        x_err_buf  := l_err_buf;

        raise be_exploder_exception;
    END IF;

    l_stmt_num := 170;

    l_op_seq_one_exists_in_ntwk := 0;


    BEGIN
        SELECT  1
        INTO    l_op_seq_one_exists_in_ntwk
        FROM    WSM_COPY_OP_NETWORKS
        WHERE   routing_sequence_id = p_common_rtg_seq_id
        AND     wip_entity_id = p_wip_entity_id     -- Added for performance improvement
        AND     1 in (from_op_seq_num, to_op_seq_num);
    EXCEPTION
        WHEN no_data_found THEN
            l_op_seq_one_exists_in_ntwk := 0;
        WHEN too_many_rows THEN
            l_op_seq_one_exists_in_ntwk := 1;
    END;

IF (g_debug = 'Y') THEN
    SELECT  count(*)
    INTO    l_be_count
    FROM    BOM_EXPLOSION_TEMP
    WHERE   group_id = l_explosion_group_id;

    fnd_file.put_line(fnd_file.log, 'At stmt('||l_stmt_num||'): '||
                        '  l_explosion_group_id ='||l_explosion_group_id||
                        ', l_be_count           ='||l_be_count||
                        ', l_op_seq_one_exists_in_ntwk='||l_op_seq_one_exists_in_ntwk);
END IF;

    OPEN job_ops;
    LOOP
    l_stmt_num := 171;
        FETCH   job_ops
        INTO    l_curr_op_seq_num,
                l_curr_op_seq_id,
                l_curr_op_is_ntwk_st_end,
                l_curr_op_start_date,
                l_curr_op_compl_date,
                l_curr_op_dept_id;
        EXIT WHEN job_ops%NOTFOUND;

        l_curr_first_op_attach_opseq1 := 0;
        -- l_curr_first_op_attach_opseq1=1 implies that current op is first op
        -- and there is no op seq 1 in network
        -- Hence attach comps at opseq 1, if any, in BOM to this first op

        IF (l_curr_op_is_ntwk_st_end = l_network_start) --'S'   --Fixed bug #3761385
        THEN
            IF (l_op_seq_one_exists_in_ntwk = 0) THEN
                l_curr_first_op_attach_opseq1 := 1;
            END IF;
        END IF;


-- Moved the comments down and added l_curr_first_op_attach_opseq1
IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'At stmt('||l_stmt_num||'): '||
                        '  l_curr_op_seq_num         ='||l_curr_op_seq_num          ||
                        ', l_curr_op_seq_id          ='||l_curr_op_seq_id           ||
                        ', l_curr_op_is_ntwk_st_end  ='||l_curr_op_is_ntwk_st_end   ||
                        ', l_curr_op_start_date      ='||l_curr_op_start_date       ||
                        ', l_curr_op_compl_date      ='||l_curr_op_compl_date       ||
                        ', l_curr_op_dept_id         ='||l_curr_op_dept_id          ||
                        ', l_curr_first_op_attach_opseq1='||l_curr_first_op_attach_opseq1||
                        ', l_top_level_bill_seq_id   ='||l_top_level_bill_seq_id);
END IF;

        l_curr_op_total_comps := 0;

    l_stmt_num := 172;

        BEGIN
            OPEN reqs;
            LOOP
                FETCH reqs INTO t_comp_details(l_curr_op_total_comps);
                EXIT WHEN reqs%NOTFOUND;
                l_curr_op_total_comps := l_curr_op_total_comps+1;
            END LOOP;
            CLOSE reqs;
        END;


IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'l_curr_op_total_comps at stmt('||l_stmt_num||'): '||l_curr_op_total_comps);
END IF;

        l_curr_op_first_level_comps:=l_curr_op_total_comps;
        l_first_level_comps_ctr:=0;
        LOOP
    l_stmt_num := 173;
            IF (t_comp_details.exists(l_first_level_comps_ctr)) THEN

                IF (t_comp_details(l_first_level_comps_ctr).wip_supply_type=6) THEN
                    BEGIN

                        l_stmt_num := 180;

IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'At stmt('||l_stmt_num||'): '||
                        '  Phantom found at op'||t_comp_details(l_first_level_comps_ctr).operation_seq_num);
END IF;

                        t_comp_details(l_first_level_comps_ctr).operation_seq_num :=-l_curr_op_seq_num;
                        l_phantom_reqd_qty := t_comp_details(l_first_level_comps_ctr).required_quantity;

                        SELECT  B.BILL_SEQUENCE_ID,
                                B.ORGANIZATION_ID
                        INTO    l_phantom_bill_seq_id,
                                l_phantom_org_id
                        FROM    BOM_BILL_OF_MATERIALS B
                        WHERE   B.ASSEMBLY_ITEM_ID = t_comp_details(l_first_level_comps_ctr).component_item_id
                        AND     B.ORGANIZATION_ID  = p_org_id
                        AND     B.ALTERNATE_BOM_DESIGNATOR IS NULL;

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_phantom_bill_seq_id := NULL;
                    END;
                    -- bug 6495025: begin
                    l_stmt_num := 185;
                    begin
                        select  'Y'
                        into    l_ato_phantom
                        from    mtl_system_items msi
                        where   msi.inventory_item_id = t_comp_details(l_first_level_comps_ctr).component_item_id
                        and     msi.organization_id   = p_org_id
                        and     msi.replenish_to_order_flag = 'Y'
                        and     msi.bom_item_type in (1,2);
                    exception
                        when no_data_found then
                             l_ato_phantom := 'N';
                    end;
                    -- bug 6495025: end

                    l_stmt_num := 190;

                    BEGIN
                        SELECT  common_routing_sequence_id
                        INTO    l_phantom_rtg_seq_id
                        FROM    BOM_OPERATIONAL_ROUTINGS
                        WHERE   assembly_item_id = t_comp_details(l_first_level_comps_ctr).component_item_id
                        AND     organization_id = p_org_id
                        AND     alternate_routing_designator is null
                        AND     cfm_routing_flag = 3;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            null;
                    END;


IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'At stmt('||l_stmt_num||'): '||
                        'l_phantom_reqd_qty = '||l_phantom_reqd_qty||
                        ', l_phantom_bill_seq_id = '||l_phantom_bill_seq_id||
                        ', l_phantom_rtg_seq_id= '||l_phantom_rtg_seq_id ||
                        ', l_phantom_org_id    = '||l_phantom_org_id);
END IF;
                       -- bug 6495025: added the condition on l_ato_phantom
                    IF (l_phantom_bill_seq_id is not null and l_ato_phantom = 'N') THEN

                        l_stmt_num := 200;


                        SELECT  BOM_EXPLOSION_TEMP_S.nextval
                        INTO    l_phantom_expl_group_id
                        FROM    DUAL;

                        l_stmt_num := 210;


IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'At stmt('||l_stmt_num||'): Parameters to exploder_userexit for exploding all levels :');
    fnd_file.put_line(fnd_file.log, 'expl_group_id ='||l_phantom_expl_group_id||
                        ', item_id='||t_comp_details(l_first_level_comps_ctr).component_item_id||
                        ', alt_desg=NULL'||
                        ', comp_code='||p_bill_item_id);
END IF;

                        bompexpl.exploder_userexit(
                                verify_flag       => 0,
                                org_id            => p_org_id,
                                order_by          => 1,
                                grp_id            => l_phantom_expl_group_id,
                                session_id        => 0,
                                levels_to_explode => l_max_bill_levels-1,
                                bom_or_eng        => 1,
                                impl_flag         => 1,
                                plan_factor_flag  => 1,
                                explode_option    => 2,
                                module            => 5,
                                cst_type_id       => 0,
                                std_comp_flag     => 0,
                                expl_qty          => 1,
                                item_id           => t_comp_details(l_first_level_comps_ctr).component_item_id,
                                alt_desg          => NULL,
                                comp_code         => to_char(p_bill_item_id), --to_char(p_primary_item_id)-- Fix for bug #3347947
                                rev_date          => to_char(p_bom_rev_date, DATETIME_FMT),
                                err_msg           => l_err_buf,
                                error_code        => l_err_code);

                        IF (l_err_code <> 0) THEN
                            x_err_code := l_err_code;
                            x_err_buf  := l_err_buf;

                            raise be_exploder_exception;
                        END IF;


IF (g_debug = 'Y') THEN
    SELECT  count(*)
    INTO    l_be_count
    FROM    BOM_EXPLOSION_TEMP
    WHERE   group_id = l_phantom_expl_group_id;

    fnd_file.put_line(fnd_file.log, 'At stmt('||l_stmt_num||'): '||
                        '  l_phantom_expl_group_id ='||l_phantom_expl_group_id||
                        ', l_be_count           ='||l_be_count);
END IF;

                    END IF;

                    IF ((l_phantom_rtg_seq_id is not null) AND
                        (l_use_phantom_routings=1) AND
                        (l_phantom_bill_seq_id is not null and l_ato_phantom = 'N')) THEN  --bug 6495025

                        DECLARE
                            l_phantom_bill_levels NUMBER:=0;
                            l_level NUMBER := 1;
                        BEGIN

                            l_stmt_num := 210;

                            SELECT  max(plan_level)
                            INTO    l_phantom_bill_levels
                            FROM    bom_explosion_temp
                            WHERE   top_bill_sequence_id = l_phantom_bill_seq_id;

                            FOR l_level in 1..l_phantom_bill_levels
                            LOOP
                                l_stmt_num := 220;

                                UPDATE  bom_explosion_temp be
                                SET     be.primary_path_flag=1
                                WHERE   be.top_bill_sequence_id=l_phantom_bill_seq_id
                                AND     be.group_id=l_phantom_expl_group_id --l_explosion_group_id
                                AND     ((be.operation_seq_num=1)
                                         OR (exists
                                                (SELECT 1
                                                 FROM   bom_operational_routings bor,
                                                        bom_operation_networks_v bonv,
                                                        bom_operation_sequences bos
                                                 WHERE  bor.assembly_item_id =
                                                            be.assembly_item_id
                                                 AND    bor.alternate_routing_designator
                                                            is null
                                                 AND    bonv.routing_sequence_id =
                                                            bor.common_routing_sequence_id
                                                 AND    be.operation_seq_num =
                                                            bos.operation_seq_num
                                                 AND    bos.routing_sequence_id =
                                                            bor.common_routing_sequence_id
                                                 AND    p_rtg_rev_date BETWEEN
                                                        bos.effectivity_date and
                                                        nvl(bos.disable_date, p_rtg_rev_date+1)
                                                 AND    NVL(BOS.operation_type, 1) = 1
                                                 AND    bonv.transition_type=1
                                                 AND    be.operation_seq_num in
                                                            (bonv.FROM_seq_num,
                                                             bonv.to_seq_num)
                                                )
                                            )
                                        )
                                AND plan_level=l_level
                                AND ((plan_level=1)
                                     OR (exists
                                            (SELECT 'x'
                                             FROM   bom_explosion_temp be1
                                             WHERE  be1.top_bill_sequence_id =
                                                        l_phantom_bill_seq_id
                                             AND    be1.group_id =
                                                        l_phantom_expl_group_id --l_explosion_group_id
                                             AND    be1.component_item_id =
                                                        be.assembly_item_id
                                             AND    SUBSTR(be1.sort_order, 1, l_level*
                                                                (SORT_WIDTH)) =
                                                        SUBSTR(BE.SORT_ORDER, 1, l_level*
                                                                (SORT_WIDTH))
                                             AND    be1.primary_path_flag=1
                                            )
                                        )
                                    );

                            END LOOP;
                        END;
                    ELSE

                        l_stmt_num := 230;
                        UPDATE  bom_explosion_temp be
                        SET     be.primary_path_flag=1
                        WHERE   be.top_bill_sequence_id = l_phantom_bill_seq_id;

                    END IF;


IF (g_debug = 'Y') THEN

    fnd_file.put_line(fnd_file.log, 'Before phan_comp '||
                        '  PRIMARY_COMPONENT_ID  = '||t_comp_details(l_first_level_comps_ctr).PRIMARY_COMPONENT_ID||
                        ', COMPONENT_ITEM_ID     = '||t_comp_details(l_first_level_comps_ctr).COMPONENT_ITEM_ID||
                        ', l_phantom_reqd_qty    = '||l_phantom_reqd_qty||
                        ', l_phantom_bill_seq_id = '||l_phantom_bill_seq_id);
END IF;

                    DECLARE
                        CURSOR phan_comp is
                        SELECT  BE.OPERATION_SEQ_NUM,
                                BE.COMPONENT_ITEM_ID                COMPONENT_ITEM_ID,
                                t_comp_details(l_first_level_comps_ctr).PRIMARY_COMPONENT_ID PRIMARY_COMPONENT_ID,
                                BE.COMPONENT_SEQUENCE_ID,
                                t_comp_details(l_first_level_comps_ctr).COMPONENT_ITEM_ID source_phantom_id,
                                                    --Populate only for phantoms, else -1
                                t_comp_details(l_first_level_comps_ctr).recommended     recommended,
                                l_curr_op_start_date                reco_start_date,
                                A.BILL_SEQUENCE_ID,
                                l_curr_op_dept_id                   department_id,

                                decode(p_wip_supply_type,
                                       7,
                                       nvl(A.WIP_SUPPLY_TYPE, nvl(C.WIP_SUPPLY_TYPE, 1)),
                                       p_wip_supply_type) wip_supply_type,
                                --Bug 5216333: Suppy type specified at job should be looked at first
                                decode (p_org_id,
                                        l_phantom_org_id,
                                        nvl(A.SUPPLY_SUBINVENTORY,
                                            nvl(C.WIP_SUPPLY_SUBINVENTORY,
                                                decode(decode(p_wip_supply_type,7,nvl(A.WIP_SUPPLY_TYPE,
                                                           nvl(C.WIP_SUPPLY_TYPE, 1)),p_wip_supply_type),
                                                       2,
                                                       l_wip_param_def_subinv,
                                                       3,
                                                       l_wip_param_def_subinv,
                                                       NULL
                                                      )
                                               )
                                           ),
                                        nvl(C.WIP_SUPPLY_SUBINVENTORY,
                                            decode(decode(p_wip_supply_type,7,nvl(A.WIP_SUPPLY_TYPE,
                                                       nvl(C.WIP_SUPPLY_TYPE, 1)),p_wip_supply_type),
                                                   2,
                                                   l_wip_param_def_subinv,
                                                   3,
                                                   l_wip_param_def_subinv,
                                                   NULL
                                                  )
                                           )
                                       ) supply_subinventory,
                                --Bug 5216333: Suppy type specified at job should be looked at first
                                decode (p_org_id,     -- Supply locator id begin
                                        l_phantom_org_id,
                                        decode (A.SUPPLY_SUBINVENTORY,
                                                NULL,
                                                decode (C.WIP_SUPPLY_SUBINVENTORY,
                                                        NULL,
                                                        decode(decode(p_wip_supply_type,7,nvl(A.WIP_SUPPLY_TYPE,
                                                                   nvl(C.WIP_SUPPLY_TYPE,
                                                                       1)),p_wip_supply_type),
                                                               2,
                                                               --nvl(l_wip_param_def_locator_id,-1),
                                                               l_wip_param_def_locator_id,
                                                               3,
                                                               l_wip_param_def_locator_id,
                                                               NULL
                                                              ),
                                                        C.WIP_SUPPLY_LOCATOR_ID
                                                       ),
                                                A.SUPPLY_LOCATOR_ID
                                               ),
                                        decode (C.WIP_SUPPLY_SUBINVENTORY,
                                                NULL,
                                                decode(decode(p_wip_supply_type,7,nvl(A.WIP_SUPPLY_TYPE,
                                                           nvl(C.WIP_SUPPLY_TYPE, 1)),p_wip_supply_type),
                                                       2,
                                                       --nvl(l_wip_param_def_locator_id,-1),
                                                       l_wip_param_def_locator_id,
                                                       3,
                                                       --nvl(l_wip_param_def_locator_id,-1),
                                                       l_wip_param_def_locator_id,
                                                       NULL
                                                      ),
                                                C.WIP_SUPPLY_LOCATOR_ID
                                               )
                                       ) supply_locator_id, -- Supply locator id end


--                              BE.extended_quantity*l_phantom_reqd_qty required_quantity,
                                BE.extended_quantity *
                                    decode(nvl(A.BASIS_TYPE, 1),
                                           1, l_phantom_reqd_qty,
                                           1) required_quantity, --Fix bug #5034531

                                BE.component_quantity BILL_QUANTITY_PER_ASSEMBLY,

                                A.COMPONENT_YIELD_FACTOR,
                                A.BASIS_TYPE,                         --LBM enh
                                A.EFFECTIVITY_DATE  EFFECTIVITY_DATE,
                                A.DISABLE_DATE,
                                null    COMPONENT_PRIORITY, --bug fix 7016646
                                A.PARENT_BILL_SEQ_ID,

                                A.ITEM_NUM,
                                A.COMPONENT_REMARKS,
                                A.CHANGE_NOTICE,
                                A.IMPLEMENTATION_DATE,
                                A.PLANNING_FACTOR,
                                A.QUANTITY_RELATED,
                                A.SO_BASIS,
                                A.OPTIONAL,
                                A.MUTUALLY_EXCLUSIVE_OPTIONS,
                                A.INCLUDE_IN_COST_ROLLUP,
                                A.CHECK_ATP,
                                A.SHIPPING_ALLOWED,
                                A.REQUIRED_TO_SHIP,
                                A.REQUIRED_FOR_REVENUE,
                                A.INCLUDE_ON_SHIP_DOCS,
                                A.LOW_QUANTITY,
                                A.HIGH_QUANTITY,
                                A.ACD_TYPE,
                                A.OLD_COMPONENT_SEQUENCE_ID,
                                A.OPERATION_LEAD_TIME_PERCENT,
                                A.REVISED_ITEM_SEQUENCE_ID,
                                A.BOM_ITEM_TYPE,
                                A.FROM_END_ITEM_UNIT_NUMBER,
                                A.TO_END_ITEM_UNIT_NUMBER,
                                A.ECO_FOR_PRODUCTION,
                                A.ENFORCE_INT_REQUIREMENTS,
                                A.DELETE_GROUP_NAME,
                                A.DG_DESCRIPTION,
                                A.OPTIONAL_ON_MODEL,
                                A.MODEL_COMP_SEQ_ID,
                                A.PLAN_LEVEL,
                                A.AUTO_REQUEST_MATERIAL,
                                A.COMPONENT_ITEM_REVISION_ID,
                                A.FROM_BILL_REVISION_ID,
                                A.TO_BILL_REVISION_ID,
                                A.PICK_COMPONENTS,
                                A.INCLUDE_ON_BILL_DOCS,
                                A.COST_FACTOR,
                                A.ORIGINAL_SYSTEM_REFERENCE,
                                a.attribute_category,
                                a.attribute1,
                                a.attribute2,
                                a.attribute3,
                                a.attribute4,
                                a.attribute5,
                                a.attribute6,
                                a.attribute7,
                                a.attribute8,
                                a.attribute9,
                                a.attribute10,
                                a.attribute11,
                                a.attribute12,
                                a.attribute13,
                                a.attribute14,
                                a.attribute15
                        FROM    BOM_INVENTORY_COMPONENTS A,
                                MTL_SYSTEM_ITEMS C,
                                BOM_EXPLOSION_TEMP BE
                        WHERE   BE.GROUP_ID = l_phantom_expl_group_id--l_explosion_group_id
                        AND     A.COMPONENT_SEQUENCE_ID = BE.COMPONENT_SEQUENCE_ID
                        AND     C.INVENTORY_ITEM_ID = BE.COMPONENT_ITEM_ID
                        AND     C.ORGANIZATION_ID = p_org_id
                        AND     BE.TOP_BILL_SEQUENCE_ID = l_phantom_bill_seq_id
                        AND     BE.PRIMARY_PATH_FLAG = 1
                        AND     p_bom_rev_date BETWEEN A.EFFECTIVITY_DATE and
                                    nvl(A.DISABLE_DATE, p_bom_rev_date+1)
                        AND     A.EFFECTIVITY_DATE =
                                     (SELECT MAX(EFFECTIVITY_DATE)
                                      FROM   BOM_INVENTORY_COMPONENTS BIC,
                                             ENG_REVISED_ITEMS ERI
                                      WHERE  BIC.BILL_SEQUENCE_ID = A.BILL_SEQUENCE_ID
                                      AND    BIC.COMPONENT_ITEM_ID = A.COMPONENT_ITEM_ID
                                      AND    (decode(BIC.IMPLEMENTATION_DATE,
                                                     NULL,
                                                     BIC.OLD_COMPONENT_SEQUENCE_ID,
                                                     BIC.COMPONENT_SEQUENCE_ID
                                                    ) =
                                              decode(A.IMPLEMENTATION_DATE,
                                                     NULL,
                                                     A.OLD_COMPONENT_SEQUENCE_ID,
                                                     A.COMPONENT_SEQUENCE_ID
                                                    )
                                             OR
                                              BIC.OPERATION_SEQ_NUM = A.OPERATION_SEQ_NUM
                                             )
                                      AND   BIC.EFFECTIVITY_DATE <= p_bom_rev_date
                                      AND   BIC.REVISED_ITEM_SEQUENCE_ID =
                                                ERI.REVISED_ITEM_SEQUENCE_ID(+)
                                      AND   (nvl(ERI.STATUS_TYPE,6) IN (4,6,7))
                                      AND   NOT EXISTS
                                                (SELECT 'X'
                                                 FROM   BOM_INVENTORY_COMPONENTS BICN,
                                                        ENG_REVISED_ITEMS ERI1
                                                 WHERE  BICN.BILL_SEQUENCE_ID =
                                                            A.BILL_SEQUENCE_ID
                                                 AND    BICN.OLD_COMPONENT_SEQUENCE_ID =
                                                            A.COMPONENT_SEQUENCE_ID
                                                 AND    BICN.ACD_TYPE in (2,3)
                                                 AND    BICN.DISABLE_DATE <=
                                                            p_bom_rev_date
                                                 AND    ERI1.REVISED_ITEM_SEQUENCE_ID =
                                                            BICN.REVISED_ITEM_SEQUENCE_ID
                                                 AND    (nvl(ERI1.STATUS_TYPE,6)IN(4,6,7))
                                                )
                                     )
                        ORDER BY A.COMPONENT_ITEM_ID,
                                 nvl(A.WIP_SUPPLY_TYPE, C.WIP_SUPPLY_TYPE),
                                 TO_NUMBER(TO_CHAR(A.EFFECTIVITY_DATE,'SSSS'));

                    BEGIN
                        l_stmt_num := 240;
                        OPEN phan_comp;
                        LOOP
                            l_stmt_num := 250;

                            FETCH phan_comp INTO t_comp_details(l_curr_op_total_comps);
                            EXIT WHEN phan_comp%NOTFOUND;

                            -- Check for BOM Loops
                            l_stmt_num := 255;
                            IF ((t_comp_details(l_curr_op_total_comps).component_item_id =
                                    p_bill_item_id) -- p_primary_item_id) -- Fix for bug #3347947
                                AND
                                (t_comp_details(l_curr_op_total_comps).wip_supply_type=6)) THEN

                                -- A loop has been detected in this Routing Network.
                                fnd_message.set_name('WSM', 'WSM_NTWK_LOOP_EXISTS');
                                x_err_buf := fnd_message.get;
                                x_err_code := -2;   --Error

                                raise loop_in_bom_exception;
                            END IF;

                            -- Set the correct op_seq_num
                            IF (t_comp_details(l_curr_op_total_comps).wip_supply_type=6) THEN
                                t_comp_details(l_curr_op_total_comps).operation_seq_num :=
                                        -l_curr_op_seq_num;
                            ELSE
                                t_comp_details(l_curr_op_total_comps).operation_seq_num :=
                                        l_curr_op_seq_num;
                            END IF;

                            l_curr_op_total_comps := l_curr_op_total_comps+1;
                        END LOOP;
                        CLOSE phan_comp;
                    END;
                END IF; --if (t_comp_details(l_first_level_comps_ctr).wip_supply_type=6)

                ----------END PHANTOMS------------------------------------------

                IF (l_first_level_comps_ctr=(l_curr_op_first_level_comps - 1)) THEN
                    EXIT;
                ELSE
                    l_first_level_comps_ctr := l_first_level_comps_ctr+1;
                END IF;
            ELSE -- IF (t_comp_details.exists(l_first_level_comps_ctr))
                exit;
            END IF;
        END LOOP;


        -- At this point, all the components, primary and phantom exploded,
        -- are in t_comp_details
        -- These will be inserted, one by one, in WCRO

        l_all_level_comps_ctr := 0;

        WHILE (l_all_level_comps_ctr<(t_comp_details.last+1))
        LOOP
            l_all_level_comps_subctr := l_all_level_comps_ctr+1;
            IF (t_comp_details.exists(l_all_level_comps_ctr)) THEN


              ---START : MERGING REQUIREMENTS AT AN OPERATION WITH SAME ---
              ---COMP_ITEM_ID, PRI_COMP_ID, COMP_SEQ_ID and SRC_PHANTOM_ID---
              WHILE (l_all_level_comps_subctr<(t_comp_details.last+1))
              LOOP

                -- Add up the total reqd_qty, by merging all requirments at an op
                -- with same comp_item_id, pri_comp_id, comp_seq_id, src_phantom_id.
                -- Also set the supply type to be = least supply type (as in WIP)

                IF ( (t_comp_details.exists(l_all_level_comps_subctr)) AND
                     (t_comp_details(l_all_level_comps_ctr).source_phantom_id <> -1) AND -- a phantom
                     (t_comp_details(l_all_level_comps_subctr).source_phantom_id <> -1) -- a phantom
                   )
                THEN


IF (g_debug = 'Y') THEN
 fnd_file.put_line(fnd_file.log, '******START**************');
 fnd_file.put_line(fnd_file.log,
    '(l_all_level_comps_ctr).component_item_id='||t_comp_details(l_all_level_comps_ctr).component_item_id||
    ', (l_all_level_comps_subctr).component_item_id='||t_comp_details(l_all_level_comps_subctr).component_item_id);
 fnd_file.put_line(fnd_file.log,
    '(l_all_level_comps_ctr).primary_component_id='||t_comp_details(l_all_level_comps_ctr).primary_component_id||
    ', (l_all_level_comps_subctr).primary_component_id='||t_comp_details(l_all_level_comps_subctr).primary_component_id);
 fnd_file.put_line(fnd_file.log,
    '(l_all_level_comps_ctr).component_sequence_id='||t_comp_details(l_all_level_comps_ctr).component_sequence_id||
    ', (l_all_level_comps_subctr).component_sequence_id='||t_comp_details(l_all_level_comps_subctr).component_sequence_id);
 fnd_file.put_line(fnd_file.log,
    '(l_all_level_comps_ctr).source_phantom_id='||t_comp_details(l_all_level_comps_ctr).source_phantom_id||
    ', (l_all_level_comps_subctr).source_phantom_id='||t_comp_details(l_all_level_comps_subctr).source_phantom_id);
 fnd_file.put_line(fnd_file.log,
    '(l_all_level_comps_ctr).required_quantity='||t_comp_details(l_all_level_comps_ctr).required_quantity||
    ', (l_all_level_comps_subctr).required_quantity='||t_comp_details(l_all_level_comps_subctr).required_quantity);
 fnd_file.put_line(fnd_file.log,
    '(l_all_level_comps_ctr).BILL_QUANTITY_PER_ASSEMBLY='||t_comp_details(l_all_level_comps_ctr).BILL_QUANTITY_PER_ASSEMBLY||
    ', (l_all_level_comps_subctr).BILL_QUANTITY_PER_ASSEMBLY='||t_comp_details(l_all_level_comps_subctr).BILL_QUANTITY_PER_ASSEMBLY);
 fnd_file.put_line(fnd_file.log, '******END**************');
END IF;

                  IF    (t_comp_details(l_all_level_comps_ctr).component_item_id =
                         t_comp_details(l_all_level_comps_subctr).component_item_id)
                    AND (t_comp_details(l_all_level_comps_ctr).primary_component_id =
                         t_comp_details(l_all_level_comps_subctr).primary_component_id)
                    AND (t_comp_details(l_all_level_comps_ctr).component_sequence_id =
                         t_comp_details(l_all_level_comps_subctr).component_sequence_id)
                    AND (t_comp_details(l_all_level_comps_ctr).source_phantom_id =
                         t_comp_details(l_all_level_comps_subctr).source_phantom_id)
                  THEN


IF (g_debug = 'Y') THEN
 fnd_file.put_line(fnd_file.log, 'MATCHING !!!!!!!!!!!!!');
END IF;

                    t_comp_details(l_all_level_comps_ctr).required_quantity :=
                        t_comp_details(l_all_level_comps_ctr).required_quantity +
                        t_comp_details(l_all_level_comps_subctr).required_quantity;

                    IF (t_comp_details(l_all_level_comps_ctr).wip_supply_type >
                        t_comp_details(l_all_level_comps_subctr).wip_supply_type) THEN

                        t_comp_details(l_all_level_comps_ctr).wip_supply_type :=
                            t_comp_details(l_all_level_comps_subctr).wip_supply_type;
                        t_comp_details(l_all_level_comps_ctr).supply_subinventory :=
                            t_comp_details(l_all_level_comps_subctr).supply_subinventory;
                        t_comp_details(l_all_level_comps_ctr).supply_locator_id :=
                            t_comp_details(l_all_level_comps_subctr).supply_locator_id;
                    END IF;

                    t_comp_details.delete(l_all_level_comps_subctr);

                  END IF;
                END IF;
                l_all_level_comps_subctr:=l_all_level_comps_subctr+1;
              END LOOP;
              ---END : MERGING REQUIREMENTS AT AN OPERATION WITH SAME ---
              ---COMP_ITEM_ID, PRI_COMP_ID, COMP_SEQ_ID and SRC_PHANTOM_ID---


              l_stmt_num := 260;
             INSERT INTO WSM_COPY_REQUIREMENT_OPS
                    (WIP_ENTITY_ID,
                     OPERATION_SEQ_NUM,
                     COMPONENT_ITEM_ID,
                     PRIMARY_COMPONENT_ID,
                     COMPONENT_SEQUENCE_ID,
                     SOURCE_PHANTOM_ID,
                     RECOMMENDED,
                     RECO_DATE_REQUIRED,
                     BILL_SEQUENCE_ID,
                     DEPARTMENT_ID,
                     ORGANIZATION_ID,
                     WIP_SUPPLY_TYPE,
                     SUPPLY_SUBINVENTORY,
                     SUPPLY_LOCATOR_ID,
                     QUANTITY_PER_ASSEMBLY,
                     BILL_QUANTITY_PER_ASSEMBLY,
                     COMPONENT_YIELD_FACTOR,
                     BASIS_TYPE,                --LBM enh
                     EFFECTIVITY_DATE,
                     DISABLE_DATE,
                     COMPONENT_PRIORITY,
                     PARENT_BILL_SEQ_ID,
                     ITEM_NUM,
                     COMPONENT_REMARKS,
                     CHANGE_NOTICE,
                     IMPLEMENTATION_DATE,
                     PLANNING_FACTOR,
                     QUANTITY_RELATED,
                     SO_BASIS,
                     OPTIONAL,
                     MUTUALLY_EXCLUSIVE_OPTIONS,
                     INCLUDE_IN_COST_ROLLUP,
                     CHECK_ATP,
                     SHIPPING_ALLOWED,
                     REQUIRED_TO_SHIP,
                     REQUIRED_FOR_REVENUE,
                     INCLUDE_ON_SHIP_DOCS,
                     LOW_QUANTITY,
                     HIGH_QUANTITY,
                     ACD_TYPE,
                     OLD_COMPONENT_SEQUENCE_ID,
                     OPERATION_LEAD_TIME_PERCENT,
                     REVISED_ITEM_SEQUENCE_ID,
                     BOM_ITEM_TYPE,
                     FROM_END_ITEM_UNIT_NUMBER,
                     TO_END_ITEM_UNIT_NUMBER,
                     ECO_FOR_PRODUCTION,
                     ENFORCE_INT_REQUIREMENTS,
                     DELETE_GROUP_NAME,
                     DG_DESCRIPTION,
                     OPTIONAL_ON_MODEL,
                     MODEL_COMP_SEQ_ID,
                     PLAN_LEVEL,
                     AUTO_REQUEST_MATERIAL,
                     COMPONENT_ITEM_REVISION_ID,
                     FROM_BILL_REVISION_ID,
                     TO_BILL_REVISION_ID,
                     PICK_COMPONENTS,
                     INCLUDE_ON_BILL_DOCS,
                     COST_FACTOR,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_LOGIN,
                     CREATION_DATE,
                     CREATED_BY,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
                     PROGRAM_UPDATE_DATE,
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
                     ATTRIBUTE15,
                     ORIGINAL_SYSTEM_REFERENCE
                    )
              VALUES
                   (p_wip_entity_id,
                    t_comp_details(l_all_level_comps_ctr).operation_seq_num,
                    t_comp_details(l_all_level_comps_ctr).component_item_id,
                    t_comp_details(l_all_level_comps_ctr).PRIMARY_COMPONENT_ID,
                    t_comp_details(l_all_level_comps_ctr).component_sequence_id,
                    t_comp_details(l_all_level_comps_ctr).source_phantom_id,
                    t_comp_details(l_all_level_comps_ctr).RECOMMENDED,
                    NULL,--RECO_DATE_REQUIRED
                    t_comp_details(l_all_level_comps_ctr).BILL_SEQUENCE_ID,
                    t_comp_details(l_all_level_comps_ctr).department_id,
                    p_org_id,
                    t_comp_details(l_all_level_comps_ctr).wip_supply_type,
                    t_comp_details(l_all_level_comps_ctr).supply_subinventory,
                    decode(t_comp_details(l_all_level_comps_ctr).supply_locator_id,
                           -1,
                           NULL,
                           t_comp_details(l_all_level_comps_ctr).supply_locator_id),--SUPPLY_LOCATOR_ID
                    t_comp_details(l_all_level_comps_ctr).required_quantity,--QUANTITY_PER_ASSEMBLY
                    t_comp_details(l_all_level_comps_ctr).BILL_QUANTITY_PER_ASSEMBLY,
                    t_comp_details(l_all_level_comps_ctr).COMPONENT_YIELD_FACTOR,
                    t_comp_details(l_all_level_comps_ctr).BASIS_TYPE,             --LBM enh
                    t_comp_details(l_all_level_comps_ctr).EFFECTIVITY_DATE,
                    t_comp_details(l_all_level_comps_ctr).DISABLE_DATE,
                    t_comp_details(l_all_level_comps_ctr).COMPONENT_PRIORITY,
                    t_comp_details(l_all_level_comps_ctr).PARENT_BILL_SEQ_ID,
                    t_comp_details(l_all_level_comps_ctr).ITEM_NUM,
                    t_comp_details(l_all_level_comps_ctr).COMPONENT_REMARKS,
                    t_comp_details(l_all_level_comps_ctr).CHANGE_NOTICE,
                    t_comp_details(l_all_level_comps_ctr).IMPLEMENTATION_DATE,
                    t_comp_details(l_all_level_comps_ctr).PLANNING_FACTOR,
                    t_comp_details(l_all_level_comps_ctr).QUANTITY_RELATED,
                    t_comp_details(l_all_level_comps_ctr).SO_BASIS,
                    t_comp_details(l_all_level_comps_ctr).OPTIONAL,
                    t_comp_details(l_all_level_comps_ctr).MUTUALLY_EXCLUSIVE_OPTIONS,
                    t_comp_details(l_all_level_comps_ctr).INCLUDE_IN_COST_ROLLUP,
                    t_comp_details(l_all_level_comps_ctr).CHECK_ATP,
                    t_comp_details(l_all_level_comps_ctr).SHIPPING_ALLOWED,
                    t_comp_details(l_all_level_comps_ctr).REQUIRED_TO_SHIP,
                    t_comp_details(l_all_level_comps_ctr).REQUIRED_FOR_REVENUE,
                    t_comp_details(l_all_level_comps_ctr).INCLUDE_ON_SHIP_DOCS,
                    t_comp_details(l_all_level_comps_ctr).LOW_QUANTITY,
                    t_comp_details(l_all_level_comps_ctr).HIGH_QUANTITY,
                    t_comp_details(l_all_level_comps_ctr).ACD_TYPE,
                    t_comp_details(l_all_level_comps_ctr).OLD_COMPONENT_SEQUENCE_ID,
                    t_comp_details(l_all_level_comps_ctr).OPERATION_LEAD_TIME_PERCENT,
                    t_comp_details(l_all_level_comps_ctr).REVISED_ITEM_SEQUENCE_ID,
                    t_comp_details(l_all_level_comps_ctr).BOM_ITEM_TYPE,
                    t_comp_details(l_all_level_comps_ctr).FROM_END_ITEM_UNIT_NUMBER,
                    t_comp_details(l_all_level_comps_ctr).TO_END_ITEM_UNIT_NUMBER,
                    t_comp_details(l_all_level_comps_ctr).ECO_FOR_PRODUCTION,
                    t_comp_details(l_all_level_comps_ctr).ENFORCE_INT_REQUIREMENTS,
                    t_comp_details(l_all_level_comps_ctr).DELETE_GROUP_NAME,
                    t_comp_details(l_all_level_comps_ctr).DG_DESCRIPTION,
                    t_comp_details(l_all_level_comps_ctr).OPTIONAL_ON_MODEL,
                    t_comp_details(l_all_level_comps_ctr).MODEL_COMP_SEQ_ID,
                    t_comp_details(l_all_level_comps_ctr).PLAN_LEVEL,
                    t_comp_details(l_all_level_comps_ctr).AUTO_REQUEST_MATERIAL,
                    t_comp_details(l_all_level_comps_ctr).COMPONENT_ITEM_REVISION_ID,
                    t_comp_details(l_all_level_comps_ctr).FROM_BILL_REVISION_ID,
                    t_comp_details(l_all_level_comps_ctr).TO_BILL_REVISION_ID,
                    t_comp_details(l_all_level_comps_ctr).PICK_COMPONENTS,
                    t_comp_details(l_all_level_comps_ctr).INCLUDE_ON_BILL_DOCS,
                    t_comp_details(l_all_level_comps_ctr).COST_FACTOR,
                    p_last_update_date,
                    p_last_updated_by,
                    p_last_update_login,
                    p_creation_date,
                    p_created_by,
                    p_request_id,
                    p_program_app_id,
                    p_program_id,
                    p_program_update_date,
                    t_comp_details(l_all_level_comps_ctr).attribute_category,
                    t_comp_details(l_all_level_comps_ctr).attribute1,
                    t_comp_details(l_all_level_comps_ctr).attribute2,
                    t_comp_details(l_all_level_comps_ctr).attribute3,
                    t_comp_details(l_all_level_comps_ctr).attribute4,
                    t_comp_details(l_all_level_comps_ctr).attribute5,
                    t_comp_details(l_all_level_comps_ctr).attribute6,
                    t_comp_details(l_all_level_comps_ctr).attribute7,
                    t_comp_details(l_all_level_comps_ctr).attribute8,
                    t_comp_details(l_all_level_comps_ctr).attribute9,
                    t_comp_details(l_all_level_comps_ctr).attribute10,
                    t_comp_details(l_all_level_comps_ctr).attribute11,
                    t_comp_details(l_all_level_comps_ctr).attribute12,
                    t_comp_details(l_all_level_comps_ctr).attribute13,
                    t_comp_details(l_all_level_comps_ctr).attribute14,
                    t_comp_details(l_all_level_comps_ctr).attribute15,
                    t_comp_details(l_all_level_comps_ctr).ORIGINAL_SYSTEM_REFERENCE
                   );

IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'Created '||SQL%ROWCOUNT||' records in WCRO for we_id='||p_wip_entity_id);
    fnd_file.put_line(fnd_file.log, 'for component='||t_comp_details(l_all_level_comps_ctr).component_item_id||
                                    ', and qpa = '||t_comp_details(l_all_level_comps_ctr).required_quantity||
                                    ', and bill_qpa = '||t_comp_details(l_all_level_comps_ctr).BILL_QUANTITY_PER_ASSEMBLY);
END IF;

            END IF; --if (t_comp_details.exists(l_all_level_comps_ctr))
            l_all_level_comps_ctr:=l_all_level_comps_ctr+1;
        END LOOP;

        l_all_level_comps_ctr := 0;


        ----------START : PHANTOM RESOURCES------------------------
        IF (l_use_phantom_routings = 1) THEN

            DECLARE
                CURSOR phan_resc_cursor IS
                SELECT  BOR.SUBSTITUTE_GROUP_NUM,
                        WCRO.recommended,
                        BOR.resource_id,
                        BR.resource_code,
                        BOS.department_id,
                        -(WCRO.OPERATION_SEQ_NUM) phantom_op_seq_num,
                        WCRO.component_ITEM_ID phantom_item_id,
                        BOR.activity_id,
                        BOR.standard_rate_flag,
                        BOR.assigned_units,
                        decode(BOR.basis_type,
                               wip_constants.PER_LOT,
                               BOR.usage_rate_or_amount,
                               BOR.usage_rate_or_amount * nvl(WCRO.QUANTITY_PER_ASSEMBLY,1)
                              ) usage_rate_or_amount,
                        BOR.USAGE_RATE_OR_AMOUNT_INVERSE,
                        BR.unit_of_measure,
                        BOR.basis_type,
                        2   schedule_flag, --BOR.schedule_flag,
                            -- For phantom resources, always = No.
                        BOR.RESOURCE_OFFSET_PERCENT,
                        BOR.autocharge_type,
                        BOR.SCHEDULE_SEQ_NUM,
                        BOR.PRINCIPLE_FLAG,
                        BOR.SETUP_ID,
                        BOR.CHANGE_NOTICE,
                        BOR.ACD_TYPE,
                        bor.ATTRIBUTE_CATEGORY,
                        bor.ATTRIBUTE1,
                        bor.ATTRIBUTE2,
                        bor.ATTRIBUTE3,
                        bor.ATTRIBUTE4,
                        bor.ATTRIBUTE5,
                        bor.ATTRIBUTE6,
                        bor.ATTRIBUTE7,
                        bor.ATTRIBUTE8,
                        bor.ATTRIBUTE9,
                        bor.ATTRIBUTE10,
                        bor.ATTRIBUTE11,
                        bor.ATTRIBUTE12,
                        bor.ATTRIBUTE13,
                        bor.ATTRIBUTE14,
                        bor.ATTRIBUTE15,
                        bor.ORIGINAL_SYSTEM_REFERENCE
                FROM    --MTL_UOM_CONVERSIONS CON,
                        BOM_RESOURCES BR,
                        BOM_OPERATION_RESOURCES BOR,
                        BOM_DEPARTMENT_RESOURCES BDR1,
                        BOM_OPERATION_SEQUENCES BOS,
                        BOM_OPERATIONAL_ROUTINGS BRTG,
                        WSM_COPY_REQUIREMENT_OPS WCRO,
                        MTL_SYSTEM_ITEMS MSI                 --BUG 6495025
                WHERE   wcro.wip_entity_id=p_wip_entity_id
                AND     wcro.organization_id=p_org_id
                AND     wcro.Operation_seq_num = -l_curr_op_seq_num
                AND     BRTG.assembly_item_id = wcro.component_item_id
                AND     BRTG.organization_id = p_org_id
                AND     MSI.inventory_item_id = wcro.component_item_id      --BUG 6495025
                AND     MSI.organization_id = p_org_id                      --BUG 6495025
                AND     (MSI.bom_item_type not in (1, 2) or MSI.replenish_to_order_flag <> 'Y')   --BUG 6495025
                AND     NVL(BRTG.cfm_routing_flag, 3) = 3
                AND     BRTG.alternate_routing_designator IS NULL
                AND     BRTG.common_routing_sequence_id = BOS.routing_sequence_id
                AND     p_rtg_rev_date BETWEEN BOS.effectivity_date and
                            nvl(BOS.disable_date, p_rtg_rev_date+1)
                AND     NVL(BOS.operation_type, 1) = 1
                AND     (bos.operation_sequence_id in
                            (
                             (SELECT bon.FROM_op_seq_id
                              FROM   BOM_OPERATION_NETWORKS_V BON
                              WHERE  bon.transition_type=1
                              AND    bon.routing_sequence_id=BRTG.common_routing_sequence_id
                             )
                             UNION ALL
                             (SELECT bon.to_op_seq_id
                              FROM   BOM_OPERATION_NETWORKS_V BON
                              WHERE  bon.transition_type=1
                              AND    bon.routing_sequence_id =
                                        BRTG.common_routing_sequence_id
                             )
                            )
                        )
                AND     BOS.operation_sequence_id = BOR.operation_sequence_id
                AND     BOS.department_id = BDR1.department_id
                AND     BOR.resource_id = BDR1.resource_id
                AND     BOR.resource_id = BR.resource_id
                ORDER BY BOS.operation_seq_num;

            BEGIN

                l_stmt_num := 270;

                SELECT  max(resource_seq_num)
                INTO    l_curr_op_max_res_seq
                FROM    WSM_COPY_OP_RESOURCES
                WHERE   wip_entity_id = p_wip_entity_id
                AND     organization_id = p_org_id
                AND     operation_seq_num = l_curr_op_seq_num;

                IF (l_curr_op_max_res_seq is null) THEN
                   l_curr_op_max_res_seq := 0;
                END IF;

                l_stmt_num := 280;
                FOR cur_resc IN phan_resc_cursor
                LOOP
                    -- SET resource_seq_num to be unique
                    l_curr_op_max_res_seq := l_curr_op_max_res_seq + 10;

                    l_stmt_num := 290;

                    -- insert phantom resources
                    INSERT INTO WSM_COPY_OP_RESOURCES
                        (WIP_ENTITY_ID,
                         OPERATION_SEQ_NUM,
                         RESOURCE_SEQ_NUM,
                         ORGANIZATION_ID,
                         SUBSTITUTE_GROUP_NUM,
                         REPLACEMENT_GROUP_NUM,
                         RECOMMENDED,
                         RECO_START_DATE,
                         RECO_COMPLETION_DATE,
                         RESOURCE_ID,
                         RESOURCE_CODE,
                         DEPARTMENT_ID,
                         PHANTOM_FLAG,
                         PHANTOM_OP_SEQ_NUM,
                         PHANTOM_ITEM_ID,
                         ACTIVITY_ID,
                         STANDARD_RATE_FLAG,
                         ASSIGNED_UNITS,
                         -- ST : Detailed Scheduling
                         MAX_ASSIGNED_UNITS,
                         FIRM_TYPE,
                         -- ST :Detailed Scheduling
                         USAGE_RATE_OR_AMOUNT,
                         USAGE_RATE_OR_AMOUNT_INVERSE,
                         UOM_CODE,
                         BASIS_TYPE,
                         SCHEDULE_FLAG,
                         RESOURCE_OFFSET_PERCENT,
                         AUTOCHARGE_TYPE,
                         SCHEDULE_SEQ_NUM,
                         PRINCIPLE_FLAG,
                         SETUP_ID,
                         CHANGE_NOTICE,
                         ACD_TYPE,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_LOGIN,
                         CREATION_DATE,
                         CREATED_BY,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID,
                         PROGRAM_UPDATE_DATE,
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
                         ATTRIBUTE15,
                         ORIGINAL_SYSTEM_REFERENCE
                        )
                    VALUES
                        (p_wip_entity_id,
                         l_curr_op_seq_num,
                         l_curr_op_max_res_seq,
                         p_org_id,
                         cur_resc.substitute_group_num,
                         0, --REPLACEMENT_GROUP_NUM, since only primary resources
                            --from phantom explosion are considered.
                         cur_resc.RECOMMENDED,
                         l_curr_op_start_date,
                         l_curr_op_compl_date,
                         cur_resc.resource_id,
                         cur_resc.RESOURCE_CODE,
                         cur_resc.department_id,
                         1,
                         cur_resc.phantom_op_seq_num,
                         cur_resc.phantom_item_id,
                         cur_resc.activity_id,
                         cur_resc.standard_rate_flag,
                         cur_resc.assigned_units,
                         -- ST : Detailed Scheduling
                         cur_resc.assigned_units,
                         0, -- Not firmed
                         -- ST : Detailed Scheduling
                         cur_resc.usage_rate_or_amount,
                         cur_resc.USAGE_RATE_OR_AMOUNT_INVERSE,
                         cur_resc.unit_of_measure,
                         cur_resc.basis_type,
                         cur_resc.schedule_flag,
                         cur_resc.RESOURCE_OFFSET_PERCENT,
                         cur_resc.autocharge_type,
                         cur_resc.schedule_seq_num,
                         cur_resc.principle_flag,
                         cur_resc.setup_id,
                         cur_resc.CHANGE_NOTICE,
                         cur_resc.ACD_TYPE,
                         p_last_update_date,
                         p_last_updated_by,
                         p_last_update_login,
                         p_creation_date,
                         p_created_by,
                         p_request_id,
                         p_program_app_id,
                         p_program_id,
                         p_program_update_date,
                         cur_resc.ATTRIBUTE_CATEGORY,
                         cur_resc.ATTRIBUTE1,
                         cur_resc.ATTRIBUTE2,
                         cur_resc.ATTRIBUTE3,
                         cur_resc.ATTRIBUTE4,
                         cur_resc.ATTRIBUTE5,
                         cur_resc.ATTRIBUTE6,
                         cur_resc.ATTRIBUTE7,
                         cur_resc.ATTRIBUTE8,
                         cur_resc.ATTRIBUTE9,
                         cur_resc.ATTRIBUTE10,
                         cur_resc.ATTRIBUTE11,
                         cur_resc.ATTRIBUTE12,
                         cur_resc.ATTRIBUTE13,
                         cur_resc.ATTRIBUTE14,
                         cur_resc.ATTRIBUTE15,
                         cur_resc.ORIGINAL_SYSTEM_REFERENCE
                        );

IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'Created '||SQL%ROWCOUNT||' records in WCOR (ph) for we_id='||p_wip_entity_id);
END IF;

                END LOOP;
            END;
        END IF; --if (l_use_phantom_routings = 1)
        ----------END : PHANTOM RESOURCES--------------------------


        t_comp_details.delete;

    END LOOP;
    CLOSE job_ops;

<<SKIP_TILL_HERE>>

    l_stmt_num := 300;

    -- ***** Create a record in wsm_lot_based_jobs ***** --
    Get_Job_Curr_Op_Info(p_wip_entity_id => p_wip_entity_id,
                         p_op_seq_num    => l_curr_op_seq_num,
                         p_op_seq_id     => l_curr_op_seq_id,
                         p_std_op_id     => l_curr_op_std_op_id,
                         p_dept_id       => l_curr_op_dept_id,
                         p_intra_op      => l_curr_op_intra_op,
                         p_op_qty        => l_curr_op_qty,
                         p_op_start_date => l_curr_op_start_date,
                         p_op_comp_date  => l_curr_op_compl_date,
                         x_err_code      => l_err_code,
                         x_err_buf       => l_err_buf);



IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'Get_Job_Curr_Op_Info returned : '||
                        'l_curr_op_seq_num      ='||l_curr_op_seq_num   ||
                        ', l_curr_op_seq_id     ='||l_curr_op_seq_id    ||
                        ', l_curr_op_std_op_id  ='||l_curr_op_std_op_id ||
                        ', l_curr_op_dept_id    ='||l_curr_op_dept_id   ||
                        ', l_curr_op_intra_op   ='||l_curr_op_intra_op  ||
                        ', l_curr_op_qty        ='||l_curr_op_qty||
                        ', l_err_code           ='||l_err_code||
                        ', l_err_buf            ='||l_err_buf);
END IF;

    IF (l_err_code = 0) THEN
        l_stmt_num := 310;

        BEGIN
            -- Start : Changes to fix bug 3452913 --
            SELECT  recommended
            INTO    l_is_curr_op_reco
            FROM    wsm_copy_operations
            WHERE   wip_entity_id = p_wip_entity_id
            AND     operation_sequence_id = WSMPUTIL.replacement_copy_op_seq_id
                                                (l_curr_op_seq_id,
                                                 p_wip_entity_id);

            -- End : Changes to fix bug 3452913 --

        EXCEPTION
            WHEN OTHERS THEN    -- including WHEN NO_DATA_FOUND THEN
                l_is_curr_op_reco := 'N';
        END;


IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'At stmt('||l_stmt_num||') : l_is_curr_op_reco='||l_is_curr_op_reco);
END IF;

    ELSIF (l_err_code = -1) THEN    -- No WO records
                                    -- Scenario : Job creation
        l_is_curr_op_reco := 'Y';

        l_stmt_num := 315;

        SELECT  0-operation_seq_num
        INTO    l_curr_op_seq_num   -- Storing this as -ve, since finally a +ve opseq to be sent
        FROM    wsm_copy_operations
        WHERE   wip_entity_id = p_wip_entity_id
        AND     network_start_end = l_network_start; --'S'; --Fixed bug #3761385


IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'At stmt('||l_stmt_num||') : l_is_curr_op_reco='||l_is_curr_op_reco||
                                    ', and l_curr_op_seq_num='||l_curr_op_seq_num);
END IF;

-- Start : Additions to fix bug #3677276
    ELSIF (l_err_code = -2) THEN    -- Completed Job - where inf sch should not be called
        l_is_curr_op_reco := 'Y';
        l_inf_sch_flag := 'N';
-- End : Additions to fix bug #3677276

    ELSE -- Some other error
        x_err_code := l_err_code;
        x_err_buf := l_err_buf;

        return;
    END IF;

    l_stmt_num := 320;
    --R12:Serial Support:
    select SERIALIZATION_START_OP into l_serial_start_op
    from   BOM_OPERATIONAL_ROUTINGS
    where  ROUTING_SEQUENCE_ID = p_common_rtg_seq_id;

     IF p_insert_wip = 1 THEN
             select nvl(OP_SEQ_NUM_INCREMENT, 10)
             into   l_op_seq_incr
             from   wsm_parameters
             where  ORGANIZATION_ID = p_org_id;
     END IF;

    INSERT into WSM_LOT_BASED_JOBS
        (WIP_ENTITY_ID,
         ORGANIZATION_ID,
         ON_REC_PATH,
         INTERNAL_COPY_TYPE,
         COPY_PARENT_WIP_ENTITY_ID,
         INFINITE_SCHEDULE,
         ROUTING_REFRESH_DATE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CREATION_DATE,
         CREATED_BY,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         SERIALIZATION_START_OP,
         --OPTII-PERF: MES Impact
         CURRENT_JOB_OP_SEQ_NUM,
         CURRENT_RTG_OP_SEQ_NUM,
         first_serial_txn_id    -- ST : Added first_serial_txn_id in the above statement for bug fix 5171286
        )
    VALUES
        (p_wip_entity_id,
         p_org_id,
         l_is_curr_op_reco,   -- ON_REC_PATH **OPEN ISSUE**
         0,
         NULL,  -- COPY_PARENT_WIP_ENTITY_ID
         NULL,  -- INFINITE_SCHEDULE
         SYSDATE, --ROUTING_REFRESH_DATE
         p_last_update_date,
         p_last_updated_by,
         p_last_update_login,
         p_creation_date,
         p_created_by,
         p_request_id,
         p_program_app_id,
         p_program_id,
         p_program_update_date,
         l_serial_start_op,
         --OPTII-PERF: MES Impact
         decode(p_insert_wip,1,l_op_seq_incr,l_curr_job_op_seq_num),
         decode(p_insert_wip,1,-1*l_curr_op_seq_num,l_curr_rtg_op_seq_num),
         l_first_serial_txn_id  -- ST : Added first_serial_txn_id in the above statement for bug fix 5171286
        );

    IF (SQL%ROWCOUNT = 0) THEN
        -- No record created in WSM_LOT_BASED_JOBS
        fnd_message.set_name('WSM', 'WSM_NO_WLBJ_REC');
        x_err_buf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||'): '||x_err_buf);
        x_err_code := -2;   -- Error

        return;
    ELSE
        x_err_code := 0;
        x_err_buf := NULL;
    END IF;


IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'Created '||SQL%ROWCOUNT||' records in WLBJ for we_id='||p_wip_entity_id);
END IF;

    l_stmt_num := 330;

    IF (l_inf_sch_flag = 'Y') THEN

        IF (p_inf_sch_mode IN (WIP_CONSTANTS.FORWARDS,
                               WIP_CONSTANTS.MIDPOINT_FORWARDS,
                               WIP_CONSTANTS.CURRENT_OP)
           )
        THEN
            l_inf_sch_start_date := nvl(p_inf_sch_date, nvl(l_curr_op_start_date, sysdate));
            l_inf_sch_comp_date := NULL;
        ELSIF (p_inf_sch_mode IN (WIP_CONSTANTS.BACKWARDS,
                                  WIP_CONSTANTS.MIDPOINT_BACKWARDS)
              )
        THEN
            l_inf_sch_start_date := NULL;
            l_inf_sch_comp_date := nvl(p_inf_sch_date, nvl(l_curr_op_compl_date, sysdate));
        ELSIF (p_inf_sch_mode IS NULL) THEN

            IF (l_is_curr_op_reco = 'Y') THEN
                -- ST : Fix for bug 5181364 : do forward scheduling instead of midpoints_forward scheduling.
                -- l_inf_sch_mode := WIP_CONSTANTS.MIDPOINT_FORWARDS;
                l_inf_sch_mode := WIP_CONSTANTS.FORWARDS;
            ELSE
                l_inf_sch_mode := WIP_CONSTANTS.CURRENT_OP;
            END IF;

            l_inf_sch_start_date := nvl(p_inf_sch_date, nvl(l_curr_op_start_date, sysdate));
            l_inf_sch_comp_date := NULL;
        END IF;

    l_stmt_num := 340;


        WSM_infinite_scheduler_PVT.schedule
                (
                 p_initMsgList   => FND_API.g_true,
                 p_endDebug      => FND_API.g_true,
                 p_orgID         => p_org_id,
                 p_wipEntityID   => p_wip_entity_id,
                 p_scheduleMode  => nvl(p_inf_sch_mode, l_inf_sch_mode),
                 p_startDate     => l_inf_sch_start_date,
                 p_endDate       => l_inf_sch_comp_date,
                 p_opSeqNum      => 0-l_curr_op_seq_num,
                 p_resSeqNum     => NULL,
                 x_returnStatus  => l_inf_sch_returnStatus,
                 x_errorMsg      => l_err_buf,
                 p_new_job       => p_new_job,
                 p_charges_exist => p_charges_exist
                );

        IF (g_debug = 'Y') THEN
            fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||
                                    '): WSM_infinite_scheduler_PVT.schedule returned '||l_inf_sch_returnStatus);
        END IF;

        -- Start : We do not need to error if Inf Sch fails, since dates will be calculated while moving --
        IF(l_inf_sch_returnStatus <> FND_API.G_RET_STS_SUCCESS) THEN

            fnd_file.put_line(fnd_file.log, 'Warning : Could not infinite schedule the job successfully');
            fnd_file.put_line(fnd_file.log, l_err_buf);
            x_err_code := -1; --Warning
            x_err_buf := l_err_buf;
        END IF;
        -- End : We do not need to error if Inf Sch fails,
        -- since dates will be calculated while moving

    END IF;

    l_stmt_num := 350;
    IF p_insert_wip = 1 THEN
        process_wip_info( p_wip_entity_id       ,
                          p_org_id              ,
                          p_last_update_date    ,
                          p_last_updated_by     ,
                          p_last_update_login   ,
                          p_creation_date       ,
                          p_created_by          ,
                          p_request_id          ,
                          p_program_app_id      ,
                          p_program_id          ,
                          p_program_update_date ,
                          p_phantom_exists,
                          l_curr_op_seq_num,
                          x_err_code,
                          x_err_buf);

     END IF;


EXCEPTION
    WHEN be_exploder_exception THEN
        x_err_buf := 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||') : '||x_err_buf;
        fnd_file.put_line(fnd_file.log, x_err_buf);

    WHEN loop_in_bom_exception THEN
        x_err_buf := 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||') : '||x_err_buf;
        fnd_file.put_line(fnd_file.log, x_err_buf);

    WHEN e_proc_error THEN
        x_err_buf := 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||') : '||x_err_buf;
        fnd_file.put_line(fnd_file.log, x_err_buf);

    --Bug 4264364:Added exception handling
    WHEN e_noneff_op THEN
        x_err_buf := 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||') : '||x_err_buf;
        fnd_file.put_line(fnd_file.log, x_err_buf);

    WHEN others THEN
        x_err_code := SQLCODE;
        x_err_buf := 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
        fnd_file.put_line(fnd_file.log, x_err_buf);

END Create_JobCopies;



/*****************************
**                          **
**  Create_RepJobCopies     **
**                          **
*****************************/


PROCEDURE Create_RepJobCopies (x_err_buf              OUT NOCOPY VARCHAR2,
                               x_err_code             OUT NOCOPY NUMBER,
                               p_rep_wip_entity_id    IN  NUMBER,
                               p_new_wip_entity_id    IN  NUMBER,
                               p_last_update_date     IN  DATE,
                               p_last_updated_by      IN  NUMBER,
                               p_last_update_login    IN  NUMBER,
                               p_creation_date        IN  DATE,
                               p_created_by           IN  NUMBER,
                               p_request_id           IN  NUMBER,
                               p_program_app_id       IN  NUMBER,
                               p_program_id           IN  NUMBER,
                               p_program_update_date  IN  DATE,
                               p_inf_sch_flag         IN  VARCHAR2,--Y/N
                               p_inf_sch_mode         IN  NUMBER,  --NULL/MIDPOINT_FORWARDS/CURRENT_OP
                               p_inf_sch_date         IN  DATE     --based on mode, this will be start/completion date
                              )
IS
    l_stmt_num  NUMBER := 0;

    l_inf_sch_mode              NUMBER;
    l_inf_sch_start_date        DATE;
    l_inf_sch_comp_date         DATE;

    l_on_rec_path               VARCHAR2(1);
    l_org_id                    NUMBER;

    l_curr_op_start_date        DATE;
    l_curr_op_compl_date        DATE;
    l_curr_op_seq_num           NUMBER;
    l_curr_op_seq_id            NUMBER;
    l_curr_op_std_op_id         NUMBER;
    l_curr_op_dept_id           NUMBER;
    l_curr_op_intra_op          NUMBER;
    l_curr_op_qty               NUMBER;

    l_inf_sch_returnStatus              VARCHAR2(1);

    e_proc_error                EXCEPTION;

BEGIN

    g_debug := FND_PROFILE.VALUE('MRP_DEBUG');

    IF (g_debug = 'Y') THEN
        fnd_file.put_line(fnd_file.log, 'Parameters to Create_RepJobCopies are :\\n');
        fnd_file.put_line(fnd_file.log, '  p_rep_wip_entity_id   ='||p_rep_wip_entity_id   );
        fnd_file.put_line(fnd_file.log, ', p_new_wip_entity_id   ='||p_new_wip_entity_id   );
        fnd_file.put_line(fnd_file.log, ', p_last_update_date    ='||p_last_update_date    );
        fnd_file.put_line(fnd_file.log, ', p_last_updated_by     ='||p_last_updated_by     );
        fnd_file.put_line(fnd_file.log, ', p_last_update_login   ='||p_last_update_login   );
        fnd_file.put_line(fnd_file.log, ', p_creation_date       ='||p_creation_date       );
        fnd_file.put_line(fnd_file.log, ', p_created_by          ='||p_created_by          );
        fnd_file.put_line(fnd_file.log, ', p_request_id          ='||p_request_id          );
        fnd_file.put_line(fnd_file.log, ', p_program_app_id      ='||p_program_app_id      );
        fnd_file.put_line(fnd_file.log, ', p_program_id          ='||p_program_id          );
        fnd_file.put_line(fnd_file.log, ', p_program_update_date ='||p_program_update_date );
        fnd_file.put_line(fnd_file.log, ', p_inf_sch_flag        ='||p_inf_sch_flag        );
        fnd_file.put_line(fnd_file.log, ', p_inf_sch_mode        ='||p_inf_sch_mode        );
        fnd_file.put_line(fnd_file.log, ', p_inf_sch_date        ='||p_inf_sch_date        );
    END IF;




IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'In Create_RepJobCopies: Rep. we_id ='||p_rep_wip_entity_id||
                                ', new we_id ='||p_new_wip_entity_id);
END IF;

    l_stmt_num := 10;

    IF (   (p_inf_sch_flag = 'Y')
       AND (p_inf_sch_mode NOT IN (WIP_CONSTANTS.MIDPOINT_FORWARDS,
                                   WIP_CONSTANTS.CURRENT_OP)
            OR p_inf_sch_mode IS NOT NULL
           )
       )
    THEN
        x_err_code := -1;
        x_err_buf := 'WSM_JobCopies_PVT.Create_JobCopies('||l_stmt_num||'): Invalid Infinite Scheduling Mode';
        fnd_file.put_line(fnd_file.log, x_err_buf);
        return;
    END IF;

    -- The following deletes will be needed, in case the API is to be made public
    --OPTII-PERF:Following deletes are not needed as this will be called for
    --only new jobs.
   /*
    DELETE WSM_COPY_OP_NETWORKS
    WHERE  wip_entity_id = p_new_wip_entity_id;

    DELETE WSM_COPY_OPERATIONS
    WHERE  wip_entity_id = p_new_wip_entity_id;

    DELETE WSM_COPY_OP_RESOURCES
    WHERE  wip_entity_id = p_new_wip_entity_id;

    DELETE WSM_COPY_OP_RESOURCE_INSTANCES
    WHERE  wip_entity_id = p_new_wip_entity_id;

    DELETE WSM_COPY_OP_RESOURCE_USAGE
    WHERE  wip_entity_id = p_new_wip_entity_id;

    DELETE WSM_COPY_REQUIREMENT_OPS
    WHERE  wip_entity_id = p_new_wip_entity_id;
    */
    DELETE WSM_LOT_BASED_JOBS
    WHERE  wip_entity_id = p_new_wip_entity_id;

    -- ***** Make a copy of the Network for the job ***** --
    l_stmt_num := 20;
    INSERT into WSM_COPY_OP_NETWORKS
        (WIP_ENTITY_ID,
         FROM_OP_SEQ_NUM,
         TO_OP_SEQ_NUM,
         FROM_OP_SEQ_ID,
         TO_OP_SEQ_ID,
         RECOMMENDED,
         ROUTING_SEQUENCE_ID,
         TRANSITION_TYPE,
         PLANNING_PCT,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CREATION_DATE,
         CREATED_BY,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
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
         ATTRIBUTE15,
         ORIGINAL_SYSTEM_REFERENCE
        )
    SELECT
         p_new_wip_entity_id,
         FROM_OP_SEQ_NUM,
         TO_OP_SEQ_NUM,
         FROM_OP_SEQ_ID,
         TO_OP_SEQ_ID,
         RECOMMENDED,
         ROUTING_SEQUENCE_ID,
         TRANSITION_TYPE,
         PLANNING_PCT,
         p_last_update_date,
         p_last_updated_by,
         p_last_update_login,
         p_creation_date,
         p_created_by,
         p_request_id,
         p_program_app_id,
         p_program_id,
         p_program_update_date,
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
         ATTRIBUTE15,
         ORIGINAL_SYSTEM_REFERENCE
    FROM    WSM_COPY_OP_NETWORKS
    WHERE   wip_entity_id = p_rep_wip_entity_id;



IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'Created '||SQL%ROWCOUNT||' records in WCON for we_id='||p_new_wip_entity_id);
END IF;

    -- ***** Make a copy of the Routing for the job ***** --
    l_stmt_num := 30;
    INSERT INTO WSM_COPY_OPERATIONS
            (WIP_ENTITY_ID,
             OPERATION_SEQ_NUM,
             RECOMMENDED,
             RECO_PATH_SEQ_NUM,
             NETWORK_START_END,
             RECO_SCHEDULED_QUANTITY,
             RECO_START_DATE,
             RECO_COMPLETION_DATE,
             OPERATION_SEQUENCE_ID,
             ROUTING_SEQUENCE_ID,
             ORGANIZATION_ID,
             STANDARD_OPERATION_ID,
             STANDARD_OPERATION_CODE,
             DEPARTMENT_ID,
             DEPARTMENT_CODE,
             SCRAP_ACCOUNT,
             EST_ABSORPTION_ACCOUNT,
             OPERATION_LEAD_TIME_PERCENT,
             MINIMUM_TRANSFER_QUANTITY,
             COUNT_POINT_TYPE,
             OPERATION_DESCRIPTION,
             EFFECTIVITY_DATE,
             DISABLE_DATE,
             BACKFLUSH_FLAG,
             OPTION_DEPENDENT_FLAG,
             OPERATION_TYPE,
             REFERENCE_FLAG,
             YIELD,
             CUMULATIVE_YIELD,
             REVERSE_CUMULATIVE_YIELD,
             LABOR_TIME_CALC,
             MACHINE_TIME_CALC,
             TOTAL_TIME_CALC,
             LABOR_TIME_USER,
             MACHINE_TIME_USER,
             TOTAL_TIME_USER,
             NET_PLANNING_PERCENT,
             X_COORDINATE,
             Y_COORDINATE,
             INCLUDE_IN_ROLLUP,
             OPERATION_YIELD_ENABLED,
             OLD_OPERATION_SEQUENCE_ID,
             ACD_TYPE,
             REVISED_ITEM_SEQUENCE_ID,
             CHANGE_NOTICE,
             ECO_FOR_PRODUCTION,
             SHUTDOWN_TYPE,
             ACTUAL_IPK,
             CRITICAL_TO_QUALITY,
             VALUE_ADDED,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
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
             ATTRIBUTE15,
             ORIGINAL_SYSTEM_REFERENCE,
             LOWEST_ACCEPTABLE_YIELD --mes
            )
    SELECT
             p_new_wip_entity_id,
             OPERATION_SEQ_NUM,
             RECOMMENDED,
             RECO_PATH_SEQ_NUM,
             NETWORK_START_END,
             NULL, --RECO_SCHEDULED_QUANTITY,
             NULL, --RECO_START_DATE,
             NULL, --RECO_COMPLETION_DATE,
             OPERATION_SEQUENCE_ID,
             ROUTING_SEQUENCE_ID,
             ORGANIZATION_ID,
             STANDARD_OPERATION_ID,
             STANDARD_OPERATION_CODE,
             DEPARTMENT_ID,
             DEPARTMENT_CODE,
             SCRAP_ACCOUNT,
             EST_ABSORPTION_ACCOUNT,
             OPERATION_LEAD_TIME_PERCENT,
             MINIMUM_TRANSFER_QUANTITY,
             COUNT_POINT_TYPE,
             OPERATION_DESCRIPTION,
             EFFECTIVITY_DATE,
             DISABLE_DATE,
             BACKFLUSH_FLAG,
             OPTION_DEPENDENT_FLAG,
             OPERATION_TYPE,
             REFERENCE_FLAG,
             YIELD,
             CUMULATIVE_YIELD,
             REVERSE_CUMULATIVE_YIELD,
             LABOR_TIME_CALC,
             MACHINE_TIME_CALC,
             TOTAL_TIME_CALC,
             LABOR_TIME_USER,
             MACHINE_TIME_USER,
             TOTAL_TIME_USER,
             NET_PLANNING_PERCENT,
             X_COORDINATE,
             Y_COORDINATE,
             INCLUDE_IN_ROLLUP,
             OPERATION_YIELD_ENABLED,
             OLD_OPERATION_SEQUENCE_ID,
             ACD_TYPE,
             REVISED_ITEM_SEQUENCE_ID,
             CHANGE_NOTICE,
             ECO_FOR_PRODUCTION,
             SHUTDOWN_TYPE,
             ACTUAL_IPK,
             CRITICAL_TO_QUALITY,
             VALUE_ADDED,
             p_last_update_date,
             p_last_updated_by,
             p_last_update_login,
             p_creation_date,
             p_created_by,
             p_request_id,
             p_program_app_id,
             p_program_id,
             p_program_update_date,
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
             ATTRIBUTE15,
             ORIGINAL_SYSTEM_REFERENCE,
             LOWEST_ACCEPTABLE_YIELD
    FROM    WSM_COPY_OPERATIONS
    WHERE   wip_entity_id = p_rep_wip_entity_id;



IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'Created '||SQL%ROWCOUNT||' records in WCO for we_id='||p_new_wip_entity_id);
END IF;

    -- ***** Make a copy of the primary Resources for the job ***** --
    l_stmt_num := 40;

        /* ST : Detailed Scheduling change for firm_type
        NOT FIRM - 0
        FIRM_START - 1,
        FIRM_END - 2,
        FIRM_RESOURCE ?3 ,
        FIRM_START_END- 4,
        FIRM_START_RESOURCE - 5,
        FIRM_END_RESOURCE - 6,
        FIRM_ALL 7

        Original Firm Flag Value          New Firm Flag Value

        Firm Start                        - Null
        Firm End                          - Null
        Firm Resource .                   - Firm Resource
        Firm Start and End                - Null
        Firm Start and Resource           - Firm Resource
        Firm End and Resource             - Firm Resource
        Firm All                          - Firm Resource
        */

    INSERT INTO WSM_COPY_OP_RESOURCES
            (WIP_ENTITY_ID,
             OPERATION_SEQ_NUM,
             RESOURCE_SEQ_NUM,
             ORGANIZATION_ID,
             SUBSTITUTE_GROUP_NUM,
             REPLACEMENT_GROUP_NUM,
             RECOMMENDED,
             RECO_START_DATE,
             RECO_COMPLETION_DATE,
             RESOURCE_ID,
             RESOURCE_CODE,
             ACTIVITY_ID,
             STANDARD_RATE_FLAG,
             ASSIGNED_UNITS,
             -- ST : Detailed Scheduling
             MAX_ASSIGNED_UNITS,
             firm_type,
             batch_id,
             group_sequence_id,
             group_sequence_num,
             parent_resource_seq_num,
             -- ST : Detailed Scheduling
             USAGE_RATE_OR_AMOUNT,
             USAGE_RATE_OR_AMOUNT_INVERSE,
             UOM_CODE,
             BASIS_TYPE,
             SCHEDULE_FLAG,
             RESOURCE_OFFSET_PERCENT,
             AUTOCHARGE_TYPE,
             SCHEDULE_SEQ_NUM,
             PRINCIPLE_FLAG,
             SETUP_ID,
             CHANGE_NOTICE,
             ACD_TYPE,
             DEPARTMENT_ID,
             PHANTOM_FLAG,
             PHANTOM_OP_SEQ_NUM,
             PHANTOM_ITEM_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             CREATION_DATE,
             CREATED_BY,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
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
             ATTRIBUTE15,
             ORIGINAL_SYSTEM_REFERENCE
            )
    SELECT
             p_new_wip_entity_id,
             OPERATION_SEQ_NUM,
             RESOURCE_SEQ_NUM,
             ORGANIZATION_ID,
             SUBSTITUTE_GROUP_NUM,
             REPLACEMENT_GROUP_NUM,
             RECOMMENDED,
             NULL, --RECO_START_DATE,
             NULL, --RECO_COMPLETION_DATE,
             RESOURCE_ID,
             RESOURCE_CODE,
             ACTIVITY_ID,
             STANDARD_RATE_FLAG,
             ASSIGNED_UNITS,
             -- ST : Detailed Scheduling
             MAX_ASSIGNED_UNITS,
             decode(firm_type
                    ,1, 0
                    ,2, 0
                    ,3, 3
                    ,4, 0
                    ,5, 3
                    ,6, 3
                    ,7, 3
                    ,0),
             batch_id,
             group_sequence_id,
             group_sequence_num,
             parent_resource_seq_num,
             -- ST : Detailed Scheduling
             USAGE_RATE_OR_AMOUNT,
             USAGE_RATE_OR_AMOUNT_INVERSE,
             UOM_CODE,
             BASIS_TYPE,
             SCHEDULE_FLAG,
             RESOURCE_OFFSET_PERCENT,
             AUTOCHARGE_TYPE,
             SCHEDULE_SEQ_NUM,
             PRINCIPLE_FLAG,
             SETUP_ID,
             CHANGE_NOTICE,
             ACD_TYPE,
             DEPARTMENT_ID,
             PHANTOM_FLAG,
             PHANTOM_OP_SEQ_NUM,
             PHANTOM_ITEM_ID,
             p_last_update_date,
             p_last_updated_by,
             p_last_update_login,
             p_creation_date,
             p_created_by,
             p_request_id,
             p_program_app_id,
             p_program_id,
             p_program_update_date,
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
             ATTRIBUTE15,
             ORIGINAL_SYSTEM_REFERENCE
    FROM    WSM_COPY_OP_RESOURCES
    WHERE   wip_entity_id = p_rep_wip_entity_id;



IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'Created '||SQL%ROWCOUNT||' records in WCOR for we_id='||p_new_wip_entity_id);
END IF;

    /* ST : Detailed Scheduling */

    /***** Make a copy of the Instances Resources for the job *****/

    l_stmt_num := 40;
    INSERT INTO WSM_COPY_OP_RESOURCE_INSTANCES
            (WIP_ENTITY_ID,
             OPERATION_SEQ_NUM,
             RESOURCE_SEQ_NUM,
             ORGANIZATION_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY ,
             CREATION_DATE ,
             CREATED_BY ,
             LAST_UPDATE_LOGIN,
             INSTANCE_ID ,
             SERIAL_NUMBER,
             START_DATE ,
             COMPLETION_DATE,
             BATCH_ID
            )
    SELECT
             p_new_wip_entity_id,
             OPERATION_SEQ_NUM,
             RESOURCE_SEQ_NUM,
             ORGANIZATION_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             INSTANCE_ID,
             SERIAL_NUMBER,
             start_date, -- START_DATE
             completion_date, --COMPLETION_DATE
             BATCH_ID
    FROM    WSM_COPY_OP_RESOURCE_INSTANCES
    WHERE   wip_entity_id = p_rep_wip_entity_id;

    IF (g_debug = 'Y') THEN
       fnd_file.put_line(fnd_file.log, 'Created '||SQL%ROWCOUNT||' records in WCORI for we_id='||p_new_wip_entity_id);
    END IF;

    /* ST : Detailed Scheduling end */

    -- ***** Make a copy of the Bill (primary and substitute components) for the job ***** --

    l_stmt_num := 50;

    INSERT INTO WSM_COPY_REQUIREMENT_OPS
        (WIP_ENTITY_ID,
         OPERATION_SEQ_NUM,
         COMPONENT_ITEM_ID,
         PRIMARY_COMPONENT_ID,
         COMPONENT_SEQUENCE_ID,
         SOURCE_PHANTOM_ID,
         RECOMMENDED,
         RECO_DATE_REQUIRED,
         BILL_SEQUENCE_ID,
         DEPARTMENT_ID,
         ORGANIZATION_ID,
         WIP_SUPPLY_TYPE,
         SUPPLY_SUBINVENTORY,
         SUPPLY_LOCATOR_ID,
         QUANTITY_PER_ASSEMBLY,
         BILL_QUANTITY_PER_ASSEMBLY,
         COMPONENT_YIELD_FACTOR,
         BASIS_TYPE,                 --LBM enh
         EFFECTIVITY_DATE,
         DISABLE_DATE,
         COMPONENT_PRIORITY,
         PARENT_BILL_SEQ_ID,
         ITEM_NUM,
         COMPONENT_REMARKS,
         CHANGE_NOTICE,
         IMPLEMENTATION_DATE,
         PLANNING_FACTOR,
         QUANTITY_RELATED,
         SO_BASIS,
         OPTIONAL,
         MUTUALLY_EXCLUSIVE_OPTIONS,
         INCLUDE_IN_COST_ROLLUP,
         CHECK_ATP,
         SHIPPING_ALLOWED,
         REQUIRED_TO_SHIP,
         REQUIRED_FOR_REVENUE,
         INCLUDE_ON_SHIP_DOCS,
         LOW_QUANTITY,
         HIGH_QUANTITY,
         ACD_TYPE,
         OLD_COMPONENT_SEQUENCE_ID,
         OPERATION_LEAD_TIME_PERCENT,
         REVISED_ITEM_SEQUENCE_ID,
         BOM_ITEM_TYPE,
         FROM_END_ITEM_UNIT_NUMBER,
         TO_END_ITEM_UNIT_NUMBER,
         ECO_FOR_PRODUCTION,
         ENFORCE_INT_REQUIREMENTS,
         DELETE_GROUP_NAME,
         DG_DESCRIPTION,
         OPTIONAL_ON_MODEL,
         MODEL_COMP_SEQ_ID,
         PLAN_LEVEL,
         AUTO_REQUEST_MATERIAL,
         COMPONENT_ITEM_REVISION_ID,
         FROM_BILL_REVISION_ID,
         TO_BILL_REVISION_ID,
         PICK_COMPONENTS,
         INCLUDE_ON_BILL_DOCS,
         COST_FACTOR,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CREATION_DATE,
         CREATED_BY,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
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
         ATTRIBUTE15,
         ORIGINAL_SYSTEM_REFERENCE
        )
    SELECT
         p_new_wip_entity_id,
         OPERATION_SEQ_NUM,
         COMPONENT_ITEM_ID,
         PRIMARY_COMPONENT_ID,
         COMPONENT_SEQUENCE_ID,
         SOURCE_PHANTOM_ID,
         RECOMMENDED,
         NULL, --RECO_DATE_REQUIRED,
         BILL_SEQUENCE_ID,
         DEPARTMENT_ID,
         ORGANIZATION_ID,
         WIP_SUPPLY_TYPE,
         SUPPLY_SUBINVENTORY,
         SUPPLY_LOCATOR_ID,
         QUANTITY_PER_ASSEMBLY,
         BILL_QUANTITY_PER_ASSEMBLY,
         COMPONENT_YIELD_FACTOR,
         BASIS_TYPE,           --LBM enh
         EFFECTIVITY_DATE,
         DISABLE_DATE,
         COMPONENT_PRIORITY,
         PARENT_BILL_SEQ_ID,
         ITEM_NUM,
         COMPONENT_REMARKS,
         CHANGE_NOTICE,
         IMPLEMENTATION_DATE,
         PLANNING_FACTOR,
         QUANTITY_RELATED,
         SO_BASIS,
         OPTIONAL,
         MUTUALLY_EXCLUSIVE_OPTIONS,
         INCLUDE_IN_COST_ROLLUP,
         CHECK_ATP,
         SHIPPING_ALLOWED,
         REQUIRED_TO_SHIP,
         REQUIRED_FOR_REVENUE,
         INCLUDE_ON_SHIP_DOCS,
         LOW_QUANTITY,
         HIGH_QUANTITY,
         ACD_TYPE,
         OLD_COMPONENT_SEQUENCE_ID,
         OPERATION_LEAD_TIME_PERCENT,
         REVISED_ITEM_SEQUENCE_ID,
         BOM_ITEM_TYPE,
         FROM_END_ITEM_UNIT_NUMBER,
         TO_END_ITEM_UNIT_NUMBER,
         ECO_FOR_PRODUCTION,
         ENFORCE_INT_REQUIREMENTS,
         DELETE_GROUP_NAME,
         DG_DESCRIPTION,
         OPTIONAL_ON_MODEL,
         MODEL_COMP_SEQ_ID,
         PLAN_LEVEL,
         AUTO_REQUEST_MATERIAL,
         COMPONENT_ITEM_REVISION_ID,
         FROM_BILL_REVISION_ID,
         TO_BILL_REVISION_ID,
         PICK_COMPONENTS,
         INCLUDE_ON_BILL_DOCS,
         COST_FACTOR,
         p_last_update_date,
         p_last_updated_by,
         p_last_update_login,
         p_creation_date,
         p_created_by,
         p_request_id,
         p_program_app_id,
         p_program_id,
         p_program_update_date,
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
         ATTRIBUTE15,
         ORIGINAL_SYSTEM_REFERENCE
    FROM    WSM_COPY_REQUIREMENT_OPS
    WHERE   wip_entity_id = p_rep_wip_entity_id;



IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'Created '||SQL%ROWCOUNT||' records in WCRO for we_id='||p_new_wip_entity_id);
END IF;

    -- Do not need to make copies for Resource Usages and Instances,
    -- since these will be set with planning runs next and picks up this job.
    -- Hence, copying the resource usages from the Rep Job would be incorrect.

    l_stmt_num := 60;

    -- ***** Create a record in wsm_lot_based_jobs ***** --
    INSERT into WSM_LOT_BASED_JOBS
        (WIP_ENTITY_ID,
         ORGANIZATION_ID,
         ON_REC_PATH,
         INTERNAL_COPY_TYPE,
         COPY_PARENT_WIP_ENTITY_ID,
         INFINITE_SCHEDULE,
         ROUTING_REFRESH_DATE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CREATION_DATE,
         CREATED_BY,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         SERIALIZATION_START_OP,
         FIRST_SERIAL_TXN_ID,
         CURRENT_JOB_OP_SEQ_NUM,
         CURRENT_RTG_OP_SEQ_NUM
        )
    SELECT
         p_new_wip_entity_id,
         ORGANIZATION_ID,
         ON_REC_PATH,
         0,    -- INTERNAL_COPY_TYPE,
         COPY_PARENT_WIP_ENTITY_ID,
         NULL, --INFINITE_SCHEDULE
         SYSDATE, --ROUTING_REFRESH_DATE
         p_last_update_date,
         p_last_updated_by,
         p_last_update_login,
         p_creation_date,
         p_created_by,
         p_request_id,
         p_program_app_id,
         p_program_id,
         p_program_update_date,
         SERIALIZATION_START_OP,
         FIRST_SERIAL_TXN_ID, --To avoid joining with the parent job
         CURRENT_JOB_OP_SEQ_NUM,
         CURRENT_RTG_OP_SEQ_NUM
    FROM    WSM_LOT_BASED_JOBS
    WHERE   wip_entity_id = p_rep_wip_entity_id;



IF (g_debug = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'Created '||SQL%ROWCOUNT||' records in WLBJ for we_id='||p_new_wip_entity_id);
END IF;

    IF (p_inf_sch_flag = 'Y') THEN

    l_stmt_num := 70;

        SELECT  ON_REC_PATH,
                organization_id
        INTO    l_on_rec_path,
                l_org_id
        FROM    WSM_LOT_BASED_JOBS
        WHERE   wip_entity_id = p_new_wip_entity_id;

    l_stmt_num := 80;

        Get_Job_Curr_Op_Info(p_wip_entity_id => p_new_wip_entity_id,
                             p_op_seq_num    => l_curr_op_seq_num,
                             p_op_seq_id     => l_curr_op_seq_id,
                             p_std_op_id     => l_curr_op_std_op_id,
                             p_dept_id       => l_curr_op_dept_id,
                             p_intra_op      => l_curr_op_intra_op,
                             p_op_qty        => l_curr_op_qty,
                             p_op_start_date => l_curr_op_start_date,
                             p_op_comp_date  => l_curr_op_compl_date,
                             x_err_code      => x_err_code,
                             x_err_buf       => x_err_buf);

        IF (x_err_code = -1)        -- No WO records
            OR (x_err_code = -2)    -- Invalid job
            OR (x_err_code <> 0)    -- Some other error
        THEN
            fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Create_RepJobCopies('||l_stmt_num||'): '||
                        'Get_Job_Curr_Op_Info returned '||x_err_code);
            fnd_file.put_line(fnd_file.log, 'Get_Job_Curr_Op_Info returned l_curr_op_seq_num='||l_curr_op_seq_num);
            return;
        END IF;

        IF (p_inf_sch_mode IS NULL) THEN

            IF (l_on_rec_path = 'Y') THEN
                -- ST : Fix for bug 5181364 : do forward scheduling instead of midpoints_forward scheduling.
                -- l_inf_sch_mode := WIP_CONSTANTS.MIDPOINT_FORWARDS;
                l_inf_sch_mode := WIP_CONSTANTS.FORWARDS;
            ELSE
                l_inf_sch_mode := WIP_CONSTANTS.CURRENT_OP;
            END IF;

        END IF;

        l_inf_sch_start_date := nvl(p_inf_sch_date, nvl(l_curr_op_start_date, sysdate));
        l_inf_sch_comp_date := NULL;

        l_stmt_num := 90;

        WSM_infinite_scheduler_PVT.schedule
                (
                 p_initMsgList   => FND_API.g_true,
                 p_endDebug      => FND_API.g_true,
                 p_orgID         => l_org_id,
                 p_wipEntityID   => p_new_wip_entity_id,
                 p_scheduleMode  => nvl(p_inf_sch_mode, l_inf_sch_mode),
                 p_startDate     => l_inf_sch_start_date,
                 p_endDate       => l_inf_sch_comp_date,
                 p_opSeqNum      => 0-l_curr_op_seq_num,
                 p_resSeqNum     => NULL,
                 x_returnStatus  => l_inf_sch_returnStatus,
                 x_errorMsg      => x_err_buf
                );


        IF (g_debug = 'Y') THEN
            fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Create_RepJobCopies('||l_stmt_num||
                                    '): WSM_infinite_scheduler_PVT.schedule returned '||l_inf_sch_returnStatus);
        END IF;

        -- Start : We do not need to error if Inf Sch fails, since dates will be calculated while moving --
        IF(l_inf_sch_returnStatus <> FND_API.G_RET_STS_SUCCESS) THEN
            fnd_file.put_line(fnd_file.log, 'Warning : Could not infinite schedule the job successfully');
            fnd_file.put_line(fnd_file.log, x_err_buf);
        END IF;
        x_err_code := 0;
        -- End : We do not need to error if Inf Sch fails, since dates will be calculated while moving --

    END IF;

    l_stmt_num := 100;

EXCEPTION

    WHEN e_proc_error THEN
--        x_err_code := SQLCODE;
        x_err_buf := 'WSM_JobCopies_PVT.Create_RepJobCopies('||l_stmt_num||') : '||x_err_buf;
        fnd_file.put_line(fnd_file.log, x_err_buf);

    WHEN others THEN
        x_err_code := SQLCODE;
        x_err_buf := 'WSM_JobCopies_PVT.Create_RepJobCopies('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
        fnd_file.put_line(fnd_file.log, x_err_buf);

END Create_RepJobCopies;




/*************************
**                      **
**  Upgrade_JobCopies   **
**                      **
**                      **
** x_err_code ->        **
** =0  implies no errors**
** else, error code     **
**                      **
*************************/

PROCEDURE Upgrade_JobCopies (x_err_buf              OUT NOCOPY VARCHAR2,
                             x_err_code             OUT NOCOPY NUMBER
                            )
IS
    -- Miscellaneous variables --
    l_stmt_num          NUMBER := 0;

    l_counter           NUMBER := 0;
    l_jobs_counter      NUMBER := 0;
    l_all_jobs_ctr      NUMBER := 0;
    l_err_ctr           NUMBER := 0;
    l_curr_rows         NUMBER := 0;    -- Number of records fetched in the current bulk fetch
    l_inf_sch_flag      VARCHAR2(1);
    l_ret_val           BOOLEAN;

    -- Variables to be set --
    l_commit_count      NUMBER := 50;   --Commit after every these number of jobs
    l_batch_size        NUMBER := 500;  --Bulk fetch only these number of jobs

    -- Exceptions --
    e_upg_error         EXCEPTION;
    e_profile_error     EXCEPTION;

    -- ==============================================================================================
    -- table types used to bulk bind data from job tables to the PL/SQL tables.
    -- ==============================================================================================
    type t_job_wip_entity_name       is table of wip_entities.wip_entity_name                   %type;
    type t_job_wip_entity_id         is table of wip_discrete_jobs.wip_entity_id                %type;
    type t_job_organization_id       is table of wip_discrete_jobs.organization_id              %type;
    type t_job_status_type           is table of wip_discrete_jobs.status_type                  %type;
    type t_job_primary_item_id       is table of wip_discrete_jobs.primary_item_id              %type;
    type t_job_routing_item_id       is table of wip_discrete_jobs.primary_item_id              %type;
    type t_job_alt_rtg_desig         is table of wip_discrete_jobs.alternate_routing_designator %type;
    type t_job_common_rtg_seq_id     is table of wip_discrete_jobs.common_routing_sequence_id   %type;
    type t_job_routing_revision_date is table of wip_discrete_jobs.routing_revision_date        %type;
    type t_job_bill_item_id          is table of wip_discrete_jobs.primary_item_id              %type;
    type t_job_alt_bom_desig         is table of wip_discrete_jobs.alternate_bom_designator     %type;
    type t_job_bill_sequence_id      is table of wip_discrete_jobs.common_bom_sequence_id       %type;
    type t_job_common_bom_seq_id     is table of wip_discrete_jobs.common_bom_sequence_id       %type;
    type t_job_bom_revision_date     is table of wip_discrete_jobs.bom_revision_date            %type;
    type t_job_wip_supply_type       is table of wip_discrete_jobs.wip_supply_type              %type;
    type t_job_upg_success           is table of number          index by binary_integer;
    type t_job_err_buf               is table of varchar2(2000)  index by binary_integer;

    -- ==============================================================================================
    -- instantiating the tables used to bulk bind data from job tables to the PL/SQL tables.
    -- ==============================================================================================
    v_job_wip_entity_id     t_job_wip_entity_id         := t_job_wip_entity_id();
    v_job_wip_entity_name   t_job_wip_entity_name       := t_job_wip_entity_name();
    v_job_organization_id   t_job_organization_id       := t_job_organization_id();
    v_job_status_type       t_job_status_type           := t_job_status_type();
    v_job_primary_item_id   t_job_primary_item_id       := t_job_primary_item_id();
    v_job_routing_item_id   t_job_routing_item_id       := t_job_routing_item_id();
    v_job_alt_rtg_desig     t_job_alt_rtg_desig         := t_job_alt_rtg_desig();
    v_job_common_rtg_seq_id t_job_common_rtg_seq_id     := t_job_common_rtg_seq_id();
    v_job_rtg_rev_date      t_job_routing_revision_date := t_job_routing_revision_date();
    v_job_bill_item_id      t_job_bill_item_id          := t_job_bill_item_id();
    v_job_alt_bom_desig     t_job_alt_bom_desig         := t_job_alt_bom_desig();
    v_job_bill_sequence_id  t_job_bill_sequence_id      := t_job_bill_sequence_id();
    v_job_common_bom_seq_id t_job_common_bom_seq_id     := t_job_common_bom_seq_id();
    v_job_bom_revision_date t_job_bom_revision_date     := t_job_bom_revision_date();
    v_job_wip_supply_type   t_job_wip_supply_type       := t_job_wip_supply_type();
    v_job_upg_success       t_job_upg_success;        --:= t_job_upg_success();
    v_job_err_buf           t_job_err_buf;            --:= t_job_err_buf();

    CURSOR upgrade_jobs IS
    SELECT  wdj.wip_entity_id,
            we.wip_entity_name,
            wdj.organization_id,
            wdj.status_type,
            wdj.primary_item_id,
            decode(wdj.job_type, 1, wdj.primary_item_id, wdj.routing_reference_id) routing_item_id,
            wdj.alternate_routing_designator alt_rtg_desig,
            wdj.common_routing_sequence_id common_rtg_seq_id,
            nvl(wdj.routing_revision_date, sysdate) routing_revision_date,
            decode(wdj.job_type, 1, wdj.primary_item_id, wdj.bom_reference_id) bill_item_id,
            wdj.alternate_bom_designator alt_bom_desig,
            WSMPUTIL.GET_JOB_BOM_SEQ_ID(wdj.wip_entity_id) bill_sequence_id,
            wdj.common_bom_sequence_id common_bom_seq_id,
            wdj.bom_revision_date,
            wdj.wip_supply_type,
            1 upg_success,   -- Will indicate Upgrade Successful or failure in the PLSQL table t_upgrade_jobs
            '' err_buf     -- Will contain the error message for failed jobs
    FROM    wsm_parameters wp,
            wip_entities we,
            wip_discrete_jobs wdj
    WHERE   we.organization_id = wp.organization_id
    AND     we.entity_type = 5
    AND     wdj.organization_id = we.organization_id
    AND     wdj.wip_entity_id = we.wip_entity_id
    AND     wdj.status_type IN (1, 3, 4, 6)     --Unreleased, Released, Complete, OnHold
    AND     NOT EXISTS (select  1   -- To make sure same set of jobs is not picked up again
                        from    wsm_lot_based_jobs wlbj
                        where   wlbj.wip_entity_id = wdj.wip_entity_id
                       )
    ORDER BY we.wip_entity_id -- Slows down the SQL prepare
    ;

    TYPE table_upgrade_jobs is TABLE OF upgrade_jobs%ROWTYPE INDEX by BINARY_INTEGER;
    t_err_upgrade_jobs  table_upgrade_jobs;

    CURSOR  lot_based_jobs IS
    SELECT  wdj.wip_entity_id,
            wdj.common_routing_sequence_id common_rtg_seq_id
    FROM    wsm_parameters wp,
            wip_entities we,
            wip_discrete_jobs wdj
    WHERE   wdj.organization_id = wp.organization_id
    AND     we.organization_id = wp.organization_id
    AND     wdj.organization_id = we.organization_id
    AND     wdj.wip_entity_id = we.wip_entity_id
    AND     (we.entity_type = 5
            OR we.entity_type = 8);

BEGIN

    l_stmt_num := 10;

    -- Fix for bug #3677276 : Moved update wo.wsm_op_seq_num stmt
    -- to inside create_jobcopies.

    l_stmt_num := 40;

    IF (to_number(fnd_profile.value('WSM_CREATE_LBJ_COPY_ROUTING')) = 1) THEN
        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Upgrade_JobCopies('||l_stmt_num||
                                        '): Value of profile "WSM: Create Lot Based Jobs Copy Routing" is YES.');
        fnd_file.put_line(fnd_file.log, 'Oracle Shopfloor Management is already upgraded to create Lot Based Job Copy Routing. Upgrade failed.');
        raise e_upg_error;
    ELSIF (to_number(fnd_profile.value('WSM_CREATE_LBJ_COPY_ROUTING')) = 2) THEN
        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Upgrade_JobCopies('||l_stmt_num||
                                        '): Value of profile "WSM: Create Lot Based Jobs Copy Routing" is NO.');
        fnd_file.put_line(fnd_file.log, 'Upgrading Lot Based Jobs to Use Copy Routings ...');
    ELSE
        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Upgrade_JobCopies('||l_stmt_num||
                                        '): Not able to fetch the value of the profile "WSM: Create Lot Based Jobs Copy Routing".');
        raise e_profile_error;
    END IF;

    fnd_file.put_line(fnd_file.log, '*****Upgrade Start Time : '||to_char(sysdate,'DD-MON-YY HH24:MI:SS')||'*****');

    l_counter := 0;

    BEGIN   -- {

      LOOP    -- {
        l_stmt_num := 50;

        OPEN upgrade_jobs;
        FETCH upgrade_jobs  bulk collect into
                            v_job_wip_entity_id,
                            v_job_wip_entity_name,
                            v_job_organization_id,
                            v_job_status_type,
                            v_job_primary_item_id,
                            v_job_routing_item_id,
                            v_job_alt_rtg_desig,
                            v_job_common_rtg_seq_id,
                            v_job_rtg_rev_date,
                            v_job_bill_item_id,
                            v_job_alt_bom_desig,
                            v_job_bill_sequence_id,
                            v_job_common_bom_seq_id,
                            v_job_bom_revision_date,
                            v_job_wip_supply_type,
                            v_job_upg_success,
                            v_job_err_buf
        LIMIT l_batch_size;

        l_curr_rows := upgrade_jobs%rowcount;
        CLOSE upgrade_jobs;

        fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Upgrade_JobCopies('||l_stmt_num||
                                        '): Number of rows loaded for the current batch: '||l_curr_rows);
        IF (l_curr_rows = 0) THEN
            exit;
        END IF;

        fnd_file.put_line(fnd_file.log, '*****After Bulk fetch : '||to_char(sysdate,'DD-MON-YY HH24:MI:SS')||'*****');

        l_counter := v_job_wip_entity_id.first;
        WHILE l_counter is NOT NULL
        LOOP    --{
           --OPTII-PERF: Open Issue-Do we need to invoke infinite scheduler
           --during upgrade?
            IF (v_job_status_type(l_counter) = 4) THEN -- Complete Jobs
                l_inf_sch_flag := 'N';
            ELSE
                l_inf_sch_flag := 'Y';
            END IF;

            x_err_code := 0;
            x_err_buf := NULL;

            l_stmt_num := 60;

            WSM_JobCopies_PVT.Create_JobCopies  -- Call #1
                (
                 x_err_buf             => x_err_buf,
                 x_err_code            => x_err_code,
                 p_wip_entity_id       => v_job_wip_entity_id    (l_counter),
                 p_org_id              => v_job_organization_id  (l_counter),
                 p_primary_item_id     => v_job_primary_item_id  (l_counter),
                 p_routing_item_id     => v_job_routing_item_id  (l_counter),
                 p_alt_rtg_desig       => v_job_alt_rtg_desig    (l_counter),
                 p_rtg_seq_id          => NULL, -- Will be NULL till reqd for some functionality
                 p_common_rtg_seq_id   => v_job_common_rtg_seq_id(l_counter),
                 p_rtg_rev_date        => v_job_rtg_rev_date     (l_counter),
                 p_bill_item_id        => v_job_bill_item_id     (l_counter),
                 p_alt_bom_desig       => v_job_alt_bom_desig    (l_counter),
                 p_bill_seq_id         => v_job_bill_sequence_id (l_counter),
                 p_common_bill_seq_id  => v_job_common_bom_seq_id(l_counter),
                 p_bom_rev_date        => v_job_bom_revision_date(l_counter),
                 p_wip_supply_type     => v_job_wip_supply_type  (l_counter),

                 p_last_update_date    => sysdate,
                 p_last_updated_by     => fnd_global.user_id,
                 p_last_update_login   => fnd_global.login_id,
                 p_creation_date       => sysdate,
                 p_created_by          => fnd_global.user_id,
                 p_request_id          => fnd_global.conc_request_id,
                 p_program_app_id      => fnd_global.prog_appl_id,
                 p_program_id          => fnd_global.conc_program_id,
                 p_program_update_date => sysdate,

                 p_inf_sch_flag        => l_inf_sch_flag,
                 p_inf_sch_mode        => NULL,
                 p_inf_sch_date        => NULL
                );

            l_stmt_num := 70;
            IF (g_debug = 'Y') THEN
                fnd_file.put_line(fnd_file.log, l_stmt_num ||' x_err_code='||x_err_code);
            END IF;

            IF ((x_err_code = 0) OR (x_err_code IS NULL)) THEN
                l_stmt_num := 71;
                fnd_file.put_line(fnd_file.log,
                            l_all_jobs_ctr+1||' '||
                            'Organization id='||v_job_organization_id(l_counter)||';  '||
                            ' Job: '||v_job_wip_entity_name(l_counter)||
                            ' (id='||v_job_wip_entity_id(l_counter)||') '||
                            to_char(sysdate,'DD-MON-YY HH24:MI:SS'));


            ELSIF (x_err_code = -1) THEN -- Warning
                l_stmt_num := 72;
                fnd_file.put_line(fnd_file.log,
                            l_all_jobs_ctr+1||' '||
                            'Organization id='||v_job_organization_id(l_counter)||';  '||
                            ' Job: '||v_job_wip_entity_name(l_counter)||
                            ' (id='||v_job_wip_entity_id(l_counter)||') '||
                            to_char(sysdate,'DD-MON-YY HH24:MI:SS') ||
                            ' WARNING : '||x_err_buf);

            ELSE -- Error
                l_stmt_num := 73;
                fnd_file.put_line(fnd_file.log,
                            l_all_jobs_ctr+1||' '||
                            'Organization id='||v_job_organization_id(l_counter)||';  '||
                            ' Job: '||v_job_wip_entity_name(l_counter)||
                            ' (id='||v_job_wip_entity_id(l_counter)||') '||
                            to_char(sysdate,'DD-MON-YY HH24:MI:SS') ||
                            ' ERROR : '||x_err_code||' '||x_err_buf);

                l_stmt_num := 80;

                v_job_upg_success(l_counter) := 2;
                v_job_err_buf(l_counter) := x_err_buf;

                t_err_upgrade_jobs(l_err_ctr).wip_entity_id         := v_job_wip_entity_id    (l_counter);
                t_err_upgrade_jobs(l_err_ctr).wip_entity_name       := v_job_wip_entity_name  (l_counter);
                t_err_upgrade_jobs(l_err_ctr).organization_id       := v_job_organization_id  (l_counter);
                t_err_upgrade_jobs(l_err_ctr).status_type           := v_job_status_type      (l_counter);
                t_err_upgrade_jobs(l_err_ctr).primary_item_id       := v_job_primary_item_id  (l_counter);
                t_err_upgrade_jobs(l_err_ctr).routing_item_id       := v_job_routing_item_id  (l_counter);
                t_err_upgrade_jobs(l_err_ctr).alt_rtg_desig         := v_job_alt_rtg_desig    (l_counter);
                t_err_upgrade_jobs(l_err_ctr).common_rtg_seq_id     := v_job_common_rtg_seq_id(l_counter);
                t_err_upgrade_jobs(l_err_ctr).routing_revision_date := v_job_rtg_rev_date     (l_counter);
                t_err_upgrade_jobs(l_err_ctr).bill_item_id          := v_job_bill_item_id     (l_counter);
                t_err_upgrade_jobs(l_err_ctr).alt_bom_desig         := v_job_alt_bom_desig    (l_counter);
                t_err_upgrade_jobs(l_err_ctr).bill_sequence_id      := v_job_bill_sequence_id (l_counter);
                t_err_upgrade_jobs(l_err_ctr).common_bom_seq_id     := v_job_common_bom_seq_id(l_counter);
                t_err_upgrade_jobs(l_err_ctr).bom_revision_date     := v_job_bom_revision_date(l_counter);
                t_err_upgrade_jobs(l_err_ctr).wip_supply_type       := v_job_wip_supply_type  (l_counter);
                t_err_upgrade_jobs(l_err_ctr).upg_success           := v_job_upg_success      (l_counter);
                t_err_upgrade_jobs(l_err_ctr).err_buf               := v_job_err_buf          (l_counter);
                l_err_ctr := l_err_ctr+1;

                l_stmt_num := 90;

                -- Delete COPY tables --
                DELETE WSM_COPY_OPERATIONS
                WHERE  wip_entity_id = v_job_wip_entity_id(l_counter);

                DELETE WSM_COPY_OP_NETWORKS
                WHERE  wip_entity_id = v_job_wip_entity_id(l_counter);

                DELETE WSM_COPY_OP_RESOURCES
                WHERE  wip_entity_id = v_job_wip_entity_id(l_counter);

                DELETE WSM_COPY_OP_RESOURCE_INSTANCES
                WHERE  wip_entity_id = v_job_wip_entity_id(l_counter);

                DELETE WSM_COPY_OP_RESOURCE_USAGE
                WHERE  wip_entity_id = v_job_wip_entity_id(l_counter);

                DELETE WSM_COPY_REQUIREMENT_OPS
                WHERE  wip_entity_id = v_job_wip_entity_id(l_counter);

                DELETE WSM_LOT_BASED_JOBS
                WHERE  wip_entity_id = v_job_wip_entity_id(l_counter);

                l_stmt_num := 100;

                INSERT into WSM_LOT_BASED_JOBS
                    (WIP_ENTITY_ID,
                     ORGANIZATION_ID,
                     ON_REC_PATH,
                     INTERNAL_COPY_TYPE,
                     COPY_PARENT_WIP_ENTITY_ID,
                     INFINITE_SCHEDULE,
                     ROUTING_REFRESH_DATE,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_LOGIN,
                     CREATION_DATE,
                     CREATED_BY,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
                     PROGRAM_UPDATE_DATE
                    )
                VALUES
                    (v_job_wip_entity_id(l_counter),
                     v_job_organization_id(l_counter),
                     'N',     -- ON_REC_PATH
                     3,       -- INTERNAL_COPY_TYPE : Copies incorrect due to Upgrade
                     NULL,    -- COPY_PARENT_WIP_ENTITY_ID
                     NULL,    -- INFINITE_SCHEDULE
                     SYSDATE, -- ROUTING_REFRESH_DATE
                     sysdate,
                     fnd_global.user_id,
                     fnd_global.login_id,
                     sysdate,
                     fnd_global.user_id,
                     fnd_global.conc_request_id,
                     fnd_global.prog_appl_id,
                     fnd_global.conc_program_id,
                     sysdate
                    );

            END IF;


            l_counter := v_job_wip_entity_id.next(l_counter);
            l_all_jobs_ctr := l_all_jobs_ctr + 1;

            l_stmt_num := 110;

            IF (MOD(l_all_jobs_ctr, l_commit_count) = 0) THEN -- Commit after every set of jobs
                COMMIT;
            END IF;

        END LOOP;   -- }    WHILE l_counter is NOT NULL

        l_stmt_num := 120;

        v_job_wip_entity_id.delete;
        v_job_wip_entity_name.delete;
        v_job_organization_id.delete;
        v_job_status_type.delete;
        v_job_primary_item_id.delete;
        v_job_routing_item_id.delete;
        v_job_alt_rtg_desig.delete;
        v_job_common_rtg_seq_id.delete;
        v_job_rtg_rev_date.delete;
        v_job_bill_item_id.delete;
        v_job_alt_bom_desig.delete;
        v_job_bill_sequence_id.delete;
        v_job_common_bom_seq_id.delete;
        v_job_bom_revision_date.delete;
        v_job_wip_supply_type.delete;
        v_job_upg_success.delete;
        v_job_err_buf.delete;

      END LOOP;   -- }      LOOP

    END;    -- } BEGIN block

    l_stmt_num := 130;
    COMMIT;

    fnd_file.put_line(fnd_file.log, '*****Upgrade End Time   : '||to_char(sysdate,'DD-MON-YY HH24:MI:SS')||'*****');
    fnd_file.put_line(fnd_file.log, 'Upgraded '||l_all_jobs_ctr||' jobs in total');

    fnd_file.put_line(fnd_file.log, 'Upgrade failed to create Job Copies for following '||l_err_ctr||' jobs : ');
    l_stmt_num := 140;

    FOR l_jobs_counter in 0..l_err_ctr-1
    LOOP
        l_stmt_num := 141;
        IF (t_err_upgrade_jobs(l_jobs_counter).upg_success = 2) THEN
            l_stmt_num := 142;
            fnd_file.put_line(fnd_file.log,
                          l_jobs_counter+1||' '||
                          'Organization id='||t_err_upgrade_jobs(l_jobs_counter).organization_id||';  '||
                          ' Job: '||t_err_upgrade_jobs(l_jobs_counter).wip_entity_name||
                          ' (id='||t_err_upgrade_jobs(l_jobs_counter).wip_entity_id||') '||
                          ' ERROR : '||t_err_upgrade_jobs(l_jobs_counter).err_buf);
        END IF;
        l_stmt_num := 143;
    END LOOP;

    l_stmt_num := 144;
    t_err_upgrade_jobs.delete;

    fnd_file.put_line(fnd_file.log, 'WSM_JobCopies_PVT.Upgrade_JobCopies('||l_stmt_num||')'||
                                    'Please correct the problem and run Refresh Open Jobs Copies for the above '||l_err_ctr||' jobs. ');

    l_stmt_num := 150;

    l_ret_val := fnd_profile.save('WSM_CREATE_LBJ_COPY_ROUTING', '1', 'SITE');

    fnd_file.put_line(fnd_file.log, 'Set the profile "WSM: Create Lot Based Jobs Copy Routing" to YES. '||
                                    'Upgrade successful. ');

    COMMIT;

    l_stmt_num := 160;

EXCEPTION
    WHEN e_upg_error THEN
        raise_application_error (-20000, 'ERROR at line '||l_stmt_num||': Oracle Shopfloor Management is already upgraded to create Lot Based Job Copy Routing. Upgrade failed.');

    WHEN e_profile_error THEN
        raise_application_error (-20000, 'ERROR at line '||l_stmt_num||': Not able to fetch the value of the profile "WSM: Create Lot Based Jobs Copy Routing"');

    WHEN others THEN
        x_err_code := SQLCODE;
        x_err_buf := 'WSM_JobCopies_PVT.Upgrade_JobCopies('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
        fnd_file.put_line(fnd_file.log, x_err_buf);

END Upgrade_JobCopies;

PROCEDURE process_wip_info(    p_wip_entity_id        IN  NUMBER,
                               p_org_id               IN  NUMBER,
                               p_last_update_date     IN  DATE,
                               p_last_updated_by      IN  NUMBER,
                               p_last_update_login    IN  NUMBER,
                               p_creation_date        IN  DATE,
                               p_created_by           IN  NUMBER,
                               p_request_id           IN  NUMBER,
                               p_program_app_id       IN  NUMBER,
                               p_program_id           IN  NUMBER,
                               p_program_update_date  IN  DATE,
                               p_phantom_exists       IN  NUMBER,
                               p_current_op_seq_num   IN  NUMBER,
                               x_err_buf              OUT NOCOPY VARCHAR2,
                               x_err_code             OUT NOCOPY NUMBER)
AS
    l_op_seq_incr NUMBER;
    l_curr_op_seq_num     NUMBER; --OPTII-PERF
    l_txn_quantity   NUMBER;

    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000) := NULL;
    l_stmt_num      NUMBER;
begin
    IF p_current_op_seq_num IS NULL THEN
        return;
    END IF;
     IF p_current_op_seq_num < 0 THEN
          l_curr_op_seq_num :=  p_current_op_seq_num *-1;
       ELSE
          l_curr_op_seq_num :=  p_current_op_seq_num;
     END IF;

     l_stmt_num := 10;

     select nvl(OP_SEQ_NUM_INCREMENT, 10)
     into   l_op_seq_incr
     from   wsm_parameters
     where  ORGANIZATION_ID = p_org_id;

     l_stmt_num := 20;
     select start_quantity
     into   l_txn_quantity
     from   wip_discrete_jobs
     where  WIP_ENTITY_ID = p_wip_entity_id;

     l_stmt_num := 30;
     INSERT INTO WIP_OPERATIONS
             (WIP_ENTITY_ID,
             OPERATION_SEQ_NUM,
             ORGANIZATION_ID,
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
             ATTRIBUTE15,
             OPERATION_YIELD,
             OPERATION_YIELD_ENABLED,
             RECOMMENDED,
             CUMULATIVE_SCRAP_QUANTITY,
             WSM_OP_SEQ_NUM)
     SELECT     WCO.wip_entity_id,
                l_op_seq_incr,
                p_org_id,
                WCO.LAST_UPDATE_DATE,
                WCO.LAST_UPDATED_BY,
                SYSDATE,
                WCO.CREATED_BY,
                WCO.LAST_UPDATE_LOGIN,
                WCO.REQUEST_ID,
                WCO.PROGRAM_APPLICATION_ID,
                WCO.PROGRAM_ID,
                WCO.PROGRAM_UPDATE_DATE,
                WCO.OPERATION_SEQUENCE_ID,
                WCO.STANDARD_OPERATION_ID,
                WCO.DEPARTMENT_ID,
                WCO.OPERATION_DESCRIPTION,
				-- Bug 5603843. Modified inside nvl clause from 0 to wdj.start_quantity
                ROUND(nvl(WCO.RECO_SCHEDULED_QUANTITY, wdj.start_quantity), WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                (decode(wdj.status_type,3, round(wdj.start_quantity,
                wip_constants.max_displayed_precision), 0)),
                0, 0, 0, 0, 0,
                decode(recommended, 'Y', nvl(RECO_START_DATE, WCO.LAST_UPDATE_DATE), WCO.LAST_UPDATE_DATE),
                decode(recommended, 'Y', nvl(RECO_COMPLETION_DATE, WCO.LAST_UPDATE_DATE), WCO.LAST_UPDATE_DATE),
                decode(recommended, 'Y', nvl(RECO_START_DATE, WCO.LAST_UPDATE_DATE), WCO.LAST_UPDATE_DATE),
                decode(recommended, 'Y', nvl(RECO_COMPLETION_DATE, WCO.LAST_UPDATE_DATE),WCO.LAST_UPDATE_DATE),
                NULL,NULL,--0, 0,
                WCO.COUNT_POINT_TYPE,
                WCO.BACKFLUSH_FLAG,
                NVL(WCO.MINIMUM_TRANSFER_QUANTITY, 0),
                '',
                WCO.ATTRIBUTE_CATEGORY,
                WCO.ATTRIBUTE1,
                WCO.ATTRIBUTE2,
                WCO.ATTRIBUTE3,
                WCO.ATTRIBUTE4,
                WCO.ATTRIBUTE5,
                WCO.ATTRIBUTE6,
                WCO.ATTRIBUTE7,
                WCO.ATTRIBUTE8,
                WCO.ATTRIBUTE9,
                WCO.ATTRIBUTE10,
                WCO.ATTRIBUTE11,
                WCO.ATTRIBUTE12,
                WCO.ATTRIBUTE13,
                WCO.ATTRIBUTE14,
                WCO.ATTRIBUTE15,
                WCO.YIELD,
                to_char(WCO.OPERATION_YIELD_ENABLED),
                nvl(RECOMMENDED, 'N'),
                WDJ.QUANTITY_SCRAPPED,
                WCO.operation_seq_num
     FROM    WSM_COPY_OPERATIONS WCO,
             WIP_DISCRETE_JOBS WDJ
     WHERE   WDJ.wip_entity_id = WCO.wip_entity_id
     AND     WCO.network_start_end = 'S'
     AND     WCO.wip_entity_id = p_wip_entity_id;

     l_stmt_num := 40;
     INSERT INTO WIP_OPERATION_YIELDS (WIP_ENTITY_ID, OPERATION_SEQ_NUM, ORGANIZATION_ID,
                  LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
                  CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
                  PROGRAM_APPLICATION_ID, PROGRAM_ID,PROGRAM_UPDATE_DATE,
                  STATUS, SCRAP_ACCOUNT, EST_SCRAP_ABSORB_ACCOUNT)
          SELECT  WO.WIP_ENTITY_ID, WO.OPERATION_SEQ_NUM, WO.ORGANIZATION_ID,
                  SYSDATE,
                  p_last_updated_by,
                  SYSDATE,
                  p_last_updated_by,
                  p_last_update_login,
                  DECODE(p_request_id, 0, '', p_request_id),
                  DECODE(p_program_app_id, 0, '', p_program_app_id),
                  p_program_id,
                  DECODE(p_program_id, 0, '', SYSDATE),
                  NULL, BD.SCRAP_ACCOUNT, BD.EST_ABSORPTION_ACCOUNT
          FROM    WIP_OPERATIONS WO,
                  BOM_DEPARTMENTS BD
          WHERE   WO.WIP_ENTITY_ID = p_wip_entity_id
          AND     WO.OPERATION_SEQ_NUM = l_op_seq_incr
          AND     WO.DEPARTMENT_ID = BD.DEPARTMENT_ID;

           --First populate wcro for non phantom components
           IF p_phantom_exists = 2 THEN
              l_stmt_num := 50;
                 INSERT INTO WIP_REQUIREMENT_OPERATIONS
                        (inventory_item_id,
                        organization_id,
                        wip_entity_id,
                        operation_seq_num,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        component_sequence_id,
                        wip_supply_type,
                        date_required,
                        basis_type,         --LBM enh
                        required_quantity,
                        quantity_issued,
                        quantity_per_assembly,
                        component_yield_factor, --R12:Comp Shrinkage project
                        supply_subinventory,
                        supply_locator_id,
                        mrp_net_flag,
                        comments,
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
                        segment1,
                        segment2,
                        segment3,
                        segment4,
                        segment5,
                        segment6,
                        segment7,
                        segment8,
                        segment9,
                        segment10,
                        segment11,
                        segment12,
                        segment13,
                        segment14,
                        segment15,
                        segment16,
                        segment17,
                        segment18,
                        segment19,
                        segment20,
                        department_id,
                        released_quantity)
                 SELECT
                        wcro.COMPONENT_ITEM_ID,
                        wcro.organization_id,
                        wcro.wip_entity_id,
                        l_op_seq_incr,
                        wcro.last_update_date,
                        wcro.last_updated_by,
                        wcro.creation_date,
                        wcro.created_by,
                        wcro.last_update_login,
                        wcro.component_sequence_id,
                        wcro.wip_supply_type,
                        Nvl(WCRO.reco_date_required, WCRO.last_update_date),
                        wcro.basis_type,       --LBM enh
                        ROUND(WCRO.quantity_per_assembly* decode(wcro.basis_type, 2, 1, wdj.start_quantity),  WSMPCNST.NUMBER_OF_DECIMALS),    --LBM enh
                        0,
                        WCRO.bill_quantity_per_assembly, --R12:Comp Shrinkage Project:Changed from qpa to bqpa
                        WCRO.component_yield_factor, --R12:Comp Shrinkage Project:Added
                        WCRO.supply_subinventory,
                        WCRO.supply_locator_id,
                        decode(WCRO.wip_supply_type,5, 2,decode(sign(WCRO.quantity_per_assembly),-1, 2,1)),
                        WCRO.component_remarks,
                        WCRO.attribute_category,
                        WCRO.attribute1,
                        WCRO.attribute2,
                        WCRO.attribute3,
                        WCRO.attribute4,
                        WCRO.attribute5,
                        WCRO.attribute6,
                        WCRO.attribute7,
                        WCRO.attribute8,
                        WCRO.attribute9,
                        WCRO.attribute10,
                        WCRO.attribute11,
                        WCRO.attribute12,
                        WCRO.attribute13,
                        WCRO.attribute14,
                        WCRO.attribute15,
                        MSI.segment1,
                        MSI.segment2,
                        MSI.segment3,
                        MSI.segment4,
                        MSI.segment5,
                        MSI.segment6,
                        MSI.segment7,
                        MSI.segment8,
                        MSI.segment9,
                        MSI.segment10,
                        MSI.segment11,
                        MSI.segment12,
                        MSI.segment13,
                        MSI.segment14,
                        MSI.segment15,
                        MSI.segment16,
                        MSI.segment17,
                        MSI.segment18,
                        MSI.segment19,
                        MSI.segment20,
                        WCRO.department_id,
                        ROUND(WDJ.start_quantity*WCRO.quantity_per_assembly, WSMPCNST.NUMBER_OF_DECIMALS)
                FROM    WIP_DISCRETE_JOBS WDJ,
                        WSM_COPY_REQUIREMENT_OPS WCRO,
                        MTL_SYSTEM_ITEMS MSI
                WHERE   WCRO.WIP_ENTITY_ID = p_wip_entity_id
                AND     WCRO.OPERATION_SEQ_NUM = l_curr_op_seq_num
                AND     MSI.inventory_item_id = WCRO.component_item_id
                AND     MSI.organization_id = WCRO.organization_id
                AND     WCRO.RECOMMENDED = 'Y'
                AND     WDJ.wip_entity_id = p_wip_entity_id;
        end if;

        l_stmt_num := 60;
        INSERT INTO WIP_OPERATION_RESOURCES
             (WIP_ENTITY_ID, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM,
             ORGANIZATION_ID, REPETITIVE_SCHEDULE_ID,
             LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
             CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
             PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
             RESOURCE_ID, UOM_CODE,
             BASIS_TYPE, USAGE_RATE_OR_AMOUNT, ACTIVITY_ID,
             SCHEDULED_FLAG, ASSIGNED_UNITS,
            /* ST : Detailed Scheduling */
            maximum_assigned_units,
            batch_id,
            firm_flag,
            group_sequence_id,
            group_sequence_number,
            parent_resource_seq,
            /* ST : Detailed Scheduling */
            AUTOCHARGE_TYPE,
             STANDARD_RATE_FLAG, APPLIED_RESOURCE_UNITS, APPLIED_RESOURCE_VALUE,
             START_DATE, COMPLETION_DATE,
             ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
             ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
             ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
             ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
             ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
             ATTRIBUTE15,
             SCHEDULE_SEQ_NUM,                   --bugfix 2493065
             SUBSTITUTE_GROUP_NUM,
             REPLACEMENT_GROUP_NUM,
             PRINCIPLE_FLAG,
             SETUP_ID,
             DEPARTMENT_ID) --Bug 4522620
      SELECT WCOR.WIP_ENTITY_ID
             , l_op_seq_incr
             , WCOR.RESOURCE_SEQ_NUM
             , WCOR.ORGANIZATION_ID
             , NULL
             , SYSDATE
             , p_last_updated_by
             , SYSDATE
             , p_last_updated_by
             , p_last_update_login
             , DECODE(p_request_id, 0, '', p_request_id)
             , DECODE(p_program_app_id, 0, '', p_program_app_id)
             , p_program_id
             , SYSDATE
             , WCOR.RESOURCE_ID
             , WCOR.UOM_CODE
             , WCOR.BASIS_TYPE
             , WCOR.USAGE_RATE_OR_AMOUNT
             , WCOR.ACTIVITY_ID
             , WCOR.SCHEDULE_FLAG
             , WCOR.ASSIGNED_UNITS
             , WCOR.MAX_ASSIGNED_UNITS
             , WCOR.batch_id
             , WCOR.firm_type
             , WCOR.group_sequence_id
             , WCOR.group_sequence_num
             , WCOR.parent_resource_seq_num
             , WCOR.AUTOCHARGE_TYPE
             , WCOR.STANDARD_RATE_FLAG
             , 0
             , 0
             , decode(recommended, 'Y', nvl(RECO_START_DATE, SYSDATE), SYSDATE)
             , decode(recommended, 'Y', nvl(RECO_COMPLETION_DATE, SYSDATE), SYSDATE)
             , WCOR.ATTRIBUTE_CATEGORY
             , WCOR.ATTRIBUTE1
             , WCOR.ATTRIBUTE2
             , WCOR.ATTRIBUTE3
             , WCOR.ATTRIBUTE4
             , WCOR.ATTRIBUTE5
             , WCOR.ATTRIBUTE6
             , WCOR.ATTRIBUTE7
             , WCOR.ATTRIBUTE8
             , WCOR.ATTRIBUTE9
             , WCOR.ATTRIBUTE10
             , WCOR.ATTRIBUTE11
             , WCOR.ATTRIBUTE12
             , WCOR.ATTRIBUTE13
             , WCOR.ATTRIBUTE14
             , WCOR.ATTRIBUTE15
             , WCOR.SCHEDULE_SEQ_NUM
             , WCOR.SUBSTITUTE_GROUP_NUM
             , WCOR.REPLACEMENT_GROUP_NUM
             , WCOR.PRINCIPLE_FLAG
             , WCOR.SETUP_ID
             , WCOR.DEPARTMENT_ID --Bug 4522620
     FROM    WSM_COPY_OP_RESOURCES WCOR
     WHERE   WCOR.WIP_ENTITY_ID = p_wip_entity_id
     AND     WCOR.OPERATION_SEQ_NUM = l_curr_op_seq_num
     AND     WCOR.recommended='Y';

     IF SQL%ROWCOUNT > 0 THEN
             l_stmt_num := 70;
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
                    maximum_assigned_units, /* ST : Detailed Scheduling */
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
            SELECT  WCOR.wip_entity_id,
                    l_op_seq_incr,
                    WCOR.resource_seq_num,
                    WCOR.organization_id,
                    null,
                    SYSDATE ,
                    p_last_updated_by,
                    SYSDATE,
                    p_last_updated_by,
                    p_last_update_login,
                    WCOR.resource_id,
                    WCOR.uom_code,
                    WCOR.basis_type,
                    WCOR.usage_rate_or_amount,
                    WCOR.activity_id,
                    WCOR.schedule_flag,
                    WCOR.assigned_units,
                    WCOR.max_assigned_units,
                    WCOR.autocharge_type,
                    WCOR.standard_rate_flag,
                    0, --WCOR.applied_resource_units,--move enh?
                    0, -- WCOR.applied_resource_value, --move enh?
                    WCOR.attribute_category,
                    WCOR.attribute1,
                    WCOR.attribute2,
                    WCOR.attribute3,
                    WCOR.attribute4,
                    WCOR.attribute5,
                    WCOR.attribute6,
                    WCOR.attribute7,
                    WCOR.attribute8,
                    WCOR.attribute9,
                    WCOR.attribute10,
                    WCOR.attribute11,
                    WCOR.attribute12,
                    WCOR.attribute13,
                    WCOR.attribute14,
                    WCOR.attribute15,
                    --as per Zhaohui copying the dates from WCOR
                    nvl(WCOR.RECO_START_DATE, SYSDATE),
                    nvl(WCOR.RECO_COMPLETION_DATE, SYSDATE),
                    WCOR.schedule_seq_num,
                    WCOR.substitute_group_num,
                    WCOR.replacement_group_num,
                    WCOR.setup_id
             FROM    WSM_COPY_OP_RESOURCES WCOR
             WHERE   WCOR.WIP_ENTITY_ID = p_wip_entity_id
             AND     WCOR.OPERATION_SEQ_NUM = l_curr_op_seq_num
             AND     WCOR.PHANTOM_ITEM_ID IS NULL
             AND     WCOR.recommended<>'Y';

     l_stmt_num := 80;
     INSERT into wip_operation_resource_usage
                (WIP_ENTITY_ID,
                OPERATION_SEQ_NUM,
                RESOURCE_SEQ_NUM,
                REPETITIVE_SCHEDULE_ID,
                ORGANIZATION_ID,
                START_DATE,
                COMPLETION_DATE,
                ASSIGNED_UNITS,
                --resource_hours, /* ST : Detailed scheduling */
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                INSTANCE_ID,
                SERIAL_NUMBER,
                CUMULATIVE_PROCESSING_TIME)
        SELECT WCORU.WIP_ENTITY_ID,
                l_op_seq_incr,
                WCORU.RESOURCE_SEQ_NUM,
                null,
                WCORU.ORGANIZATION_ID,
                WCORU.START_DATE,
                WCORU.COMPLETION_DATE,
                WCORU.ASSIGNED_UNITS,
                --WCORU.RESOURCE_HOURS, /* ST : Detailed scheduling */
                SYSDATE ,
                p_last_updated_by,
                SYSDATE,
                p_last_updated_by,
                p_last_update_login,
                DECODE(p_request_id, 0, '', p_request_id),
                DECODE(p_program_app_id, 0, '', p_program_app_id),
                p_program_id,
                SYSDATE,
                WCORU.INSTANCE_ID,
                WCORU.SERIAL_NUMBER,
                WCORU.CUMULATIVE_PROCESSING_TIME
        FROM    WIP_OPERATION_RESOURCES WOR,
                WSM_COPY_OP_RESOURCE_USAGE WCORU
        WHERE   WCORU.WIP_ENTITY_ID= p_wip_entity_id
        AND     WCORU.Operation_seq_num = l_curr_op_seq_num
        AND     WOR.WIP_ENTITY_ID= WCORU.WIP_ENTITY_ID
        AND     WOR.Operation_seq_num= WCORU.Operation_seq_num
        AND     WOR.RESOURCE_SEQ_NUM= WCORU.RESOURCE_SEQ_NUM;
     END IF;--End of check on sql%rowcount

     l_stmt_num := 90;

     WSMPOPRN.copy_to_op_mes_info(
            p_wip_entity_id       =>p_wip_entity_id,
            p_to_job_op_seq_num   =>l_op_seq_incr,
            p_to_rtg_op_seq_num   =>l_curr_op_seq_num,
            p_txn_quantity        =>l_txn_quantity,
            p_user                =>p_created_by,
            p_login               =>p_last_update_login,
            x_return_status       =>l_return_status,
            x_msg_count           =>l_msg_count,
            x_msg_data            =>l_msg_data
            );

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
           x_err_code :=1;
           x_err_buf := l_msg_data;
        end if;

     exception
        WHEN others THEN
                x_err_code := SQLCODE;
                x_err_buf := 'WSM_JobCopies_PVT.process_wip_info('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
                fnd_file.put_line(fnd_file.log, x_err_buf);
END process_wip_info;

FUNCTION max_res_seq (p_op_seq_id  NUMBER) return NUMBER
IS

BEGIN
 return(v_max_res_seq(p_op_seq_id));
END max_res_seq;

END WSM_JobCopies_PVT;

/
