--------------------------------------------------------
--  DDL for Package Body MRP_RELEASE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_RELEASE_PK" AS
 /* $Header: MRPARELB.pls 120.3 2006/09/14 06:12:00 arrsubra noship $ */
  WIP_DIS_MASS_LOAD             CONSTANT INTEGER := 1;
  PO_MASS_LOAD                  CONSTANT INTEGER := 8;

  PO_REQUISITION                CONSTANT INTEGER := 2;
  WIP_DISCRETE_JOB              CONSTANT INTEGER := 3;

  MAKE                          CONSTANT INTEGER := 1;
  BUY                           CONSTANT INTEGER := 2;
  PLANNED_ORDER                 CONSTANT INTEGER := 5;
  UNRELEASED_NO_CHARGES         CONSTANT INTEGER := 1;
  STANDARD_ITEM                 CONSTANT INTEGER := 4;
  NO_AUTO_RELEASE               CONSTANT INTEGER := 5;
  NO_KANBAN_RELEASE		CONSTANT INTEGER := 6;

  MRP_PLAN                      CONSTANT INTEGER := 1;
  MPS_PLAN                      CONSTANT INTEGER := 2;
  MRP_PLANNED_ITEM              CONSTANT INTEGER := 3;
  MPS_PLANNED_ITEM              CONSTANT INTEGER := 4;

  NULL_VALUE                    CONSTANT INTEGER := -23453;
  MAGIC_STRING                  CONSTANT VARCHAR2(10) := '734jkhJK24';
  BUFFER_SIZE_LEN		CONSTANT INTEGER := 1000000;

  SYS_YES                       CONSTANT INTEGER := 1;
  SYS_NO                        CONSTANT INTEGER := 2;

-- ========================================================================
--
--  Selects the rows in MRP_RECOMMENDATIONS for all orgs in a given plan
--  that meet the auto-release criteria and release those planned orders.
--
-- ========================================================================

PROCEDURE mrp_auto_release(
                        errbuf			OUT NOCOPY VARCHAR2,  --2663505
		        retcode			OUT NOCOPY NUMBER,    --2663505
                        arg_org_id              IN  NUMBER,
                        arg_plan_name           IN  VARCHAR2,
			arg_use_start_date      IN  VARCHAR2) IS

  VERSION                       CONSTANT CHAR(80) :=
        '$Header: MRPARELB.pls 120.3 2006/09/14 06:12:00 arrsubra noship $';

  counter			NUMBER := 0;

  var_user_id                   NUMBER;
  var_po_group_by               NUMBER;
  var_po_batch_number           NUMBER;
  var_wip_group_id              NUMBER;
  var_loaded_jobs               NUMBER;
  var_loaded_reqs               NUMBER;
  var_loaded_scheds             NUMBER;
  var_resched_jobs              NUMBER;
  var_resched_reqs              NUMBER;
  var_wip_req_id                NUMBER;
  var_req_load_id               NUMBER;
  var_req_resched_id            NUMBER;

  var_rowid                     ROWID;
  var_start_date		DATE;
  var_demand_class              VARCHAR(30);
  var_wip_class_code            VARCHAR(10);
  var_plan_type                 NUMBER;
  var_make_buy_code             NUMBER;
  var_primary_uom_code          VARCHAR(3);
  var_planner_employee_id       NUMBER;
  var_employee_id               NUMBER;
  var_default_job_prefix        VARCHAR(80);
  var_job_prefix                VARCHAR(80);
  var_firm_jobs                 VARCHAR(80) := 'N';
  var_impl_status_code          NUMBER;
  var_location_id               NUMBER;
  var_count                     NUMBER;
  var_org_code                  VARCHAR(3);
  var_org_id                    NUMBER;
  var_prev_org_id               NUMBER := -1;
  var_inventory_item_id         NUMBER;
  var_prev_inventory_item_id    NUMBER := -1;
  var_item                      VARCHAR(50);
  var_new_schedule_date         DATE;
  var_new_order_quantity        NUMBER;
  var_planner_code              VARCHAR(10);
  var_debug                     BOOLEAN := FALSE;
  var_entity                    VARCHAR(30);
  var_buf			VARCHAR2(240);
  var_project_id		NUMBER;
  var_prev_project_id		NUMBER := -1;

  err_msg_1                     VARCHAR2(30);
  err_class_1                   VARCHAR2(10);
  err_msg_2                     VARCHAR2(30);
  err_class_2                   VARCHAR2(10);

  invalid_plan                  EXCEPTION;

  CURSOR job_status IS
    SELECT NVL(mwdo.orders_default_job_status, UNRELEASED_NO_CHARGES),
           NVL(mwdo.job_class_code, var_wip_class_code),
		   NVL(mwdo.orders_firm_jobs, 'N')
    FROM   mrp_workbench_display_options    mwdo,
           fnd_user                         fu
    WHERE  fu.employee_id               = var_planner_employee_id
    AND    fu.start_date               <= sysdate
    AND    NVL(fu.end_date, sysdate)   >= sysdate
    AND    mwdo.user_id                 = fu.user_id;

  --
  -- PLANNING_MAKE_BUY_CODE cannot be used to determine whether an item is
  -- a make or buy item for time-phased make-buy item, instead use
  --
  --       Curr org     Source org     Item type
  --       --------     ----------     ---------
  --          X             X            Make (always populated for Make item)
  --          X             Y            Buy
  --          X             -            Buy (for Vendor)
  --
  -- MRP_PLANNING_CODE cannot be used to determine whether or not an item
  -- should be released based on the plan type (MPS/MRP) for Supply Chain
  -- Planning, instead use
  --
  --       In source plan     Release
  --       --------------     -------
  --           Yes             No          (items from input supply schedules)
  --           No              Yes         (items from input demand schedules)
  --

  CURSOR planned_orders IS
        SELECT mr.rowid, mr.organization_id, mr.inventory_item_id,
               mr.new_schedule_date, mr.new_order_quantity,
               msi.primary_uom_code,
               decode(msi.planner_code,NULL,mplm.employee_id,mpl.employee_id),
               DECODE(mr.source_organization_id, mr.organization_id, MAKE, BUY) ,
	       nvl(mr.implement_project_id,mr.project_id)
        FROM   bom_calendar_dates       cal1,
               bom_calendar_dates       cal2,
               mtl_planners             mplm,
               mtl_planners             mpl,
               mtl_parameters           mparam,
               mtl_system_items         master_msi,
               mtl_system_items         msi,
               mrp_system_items         rsi,
               mrp_recommendations      mr,
               mrp_plan_organizations_v mpo
        WHERE  mpo.organization_id      = arg_org_id
        AND    mpo.compile_designator   = arg_plan_name
        AND    mr.organization_id       = mpo.planned_organization
        AND    mr.compile_designator    = mpo.compile_designator
        AND    mr.order_type            = PLANNED_ORDER
        AND    NVL(mr.schedule_compression_days, 0) = 0
        AND    mr.new_order_placement_date     BETWEEN TRUNC(var_start_date)
                                        AND     cal2.calendar_date
        AND    msi.organization_id      = mr.organization_id
        AND    msi.inventory_item_id    = mr.inventory_item_id
        AND    msi.bom_item_type        = STANDARD_ITEM
        AND    NVL(msi.release_time_fence_code, NO_AUTO_RELEASE) NOT IN
					(NO_AUTO_RELEASE, NO_KANBAN_RELEASE)
        AND    ((msi.build_in_wip_flag        = 'Y'
        AND      NVL(msi.repetitive_planning_flag, 'N') = 'N'
        AND      DECODE(mr.source_organization_id, mr.organization_id, MAKE,
                        BUY)                  = MAKE)
        OR      (msi.purchasing_enabled_flag  = 'Y'
        AND      DECODE(mr.source_organization_id, mr.organization_id, MAKE,
                        BUY)                  = BUY))
        AND    NOT EXISTS ( SELECT 1 FROM bom_operational_routings
                     WHERE assembly_item_id = mr.inventory_item_id
                     AND   organization_id = mr.organization_id
                     AND   nvl(alternate_routing_designator,'-23453') =
                               nvl(mr.alternate_routing_designator,'-23453')
                     AND   cfm_routing_flag = 1)
        AND    rsi.organization_id      = mr.organization_id
        AND    rsi.compile_designator   = mr.compile_designator
        AND    rsi.inventory_item_id    = mr.inventory_item_id
        AND    NVL(rsi.in_source_plan, SYS_NO) <> SYS_YES
        AND    master_msi.organization_id = mparam.master_organization_id
        AND    master_msi.inventory_item_id = msi.inventory_item_id
        AND    mpl.organization_id   (+) = msi.organization_id
        AND    mpl.planner_code      (+) = NVL(msi.planner_code, MAGIC_STRING)
        AND    mplm.organization_id   (+)= master_msi.organization_id
        AND    mplm.planner_code      (+)= NVL(master_msi.planner_code, MAGIC_STRING)
        AND    mparam.organization_id   = mr.organization_id
        AND    cal1.calendar_code       = mparam.calendar_code
        AND    cal1.exception_set_id    = mparam.calendar_exception_set_id
        AND    cal1.calendar_date      	= TRUNC(var_start_date)
        AND    cal2.calendar_code       = cal1.calendar_code
        AND    cal2.exception_set_id    = cal1.exception_set_id
        AND    cal2.seq_num             = cal1.next_seq_num +
                          NVL(DECODE(msi.release_time_fence_code,
                                     1, msi.cumulative_total_lead_time,
                                     2, msi.cum_manufacturing_lead_time,
                                     3, msi.full_lead_time,
                                     4, msi.release_time_fence_days,
                                     0),
                              0)
        ORDER BY 2;

BEGIN
  retcode := 0;
  errbuf := NULL;

  var_debug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';

  -- ------------------------------------------------------------------------
  -- Validate the plan
  -- ------------------------------------------------------------------------
  BEGIN
    var_entity := 'Plan Validation';
    mrp_valid_plan_desig_pkg.mrp_valid_plan_designator(
			arg_plan_name, arg_org_id, 'Y', 'Y', 'Y', 'N');

    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('MRP', 'UNSUCCESSFUL PLAN VALIDATION');
        var_buf := fnd_message.get;
        fnd_file.put_line(FND_FILE.LOG, var_buf);

        retcode := 2;
        errbuf := var_buf;
        RETURN;
  END;

  -- ------------------------------------------------------------------------
  -- Setup
  -- ------------------------------------------------------------------------
  var_user_id            := FND_GLOBAL.USER_ID;
  var_default_job_prefix := FND_PROFILE.VALUE('WIP_JOB_PREFIX');
  var_po_group_by        := FND_PROFILE.VALUE('MRP_LOAD_REQ_GROUP_BY');

  var_entity := 'Setup';

  SELECT mp.curr_plan_type,
         wip_job_schedule_interface_s.nextval,
         mrp_workbench_query_s.nextval,
         DECODE(UPPER(arg_use_start_date),
                'Y', mp.plan_start_date, 'N', sysdate, sysdate),
         sched.demand_class
  INTO   var_plan_type,
         var_wip_group_id, var_po_batch_number,
         var_start_date, var_demand_class
  FROM   mrp_plans mp,
         mrp_schedule_designators sched
  WHERE  sched.organization_id     (+)= mp.organization_id
  AND    sched.schedule_designator (+)= mp.compile_designator
  AND    mp.organization_id           = arg_org_id
  AND    mp.compile_designator        = arg_plan_name;

  IF var_debug THEN
    var_buf := '+++++++++++++++++';
    fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'User ID                : '||var_user_id;
    fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'Owning org             : '||arg_org_id;
    fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'Plan                   : '||arg_plan_name;
    fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'Plan type              : '||var_plan_type;
    fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'Use start date         : '||arg_use_start_date;
    fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'Start date             : '||var_start_date;
    fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'WIP default job prefix : '||var_default_job_prefix;
    fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'WIP group ID           : '||var_wip_group_id;
    fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'PO group by            : '||var_po_group_by;
    fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'PO batch number        : '||var_po_batch_number;
    fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'Demand Class           : '||var_demand_class;
    fnd_file.put_line(FND_FILE.LOG, var_buf);
  END IF;

  -- ------------------------------------------------------------------------
  -- Get planned orders that meet the auto-release criteria
  -- ------------------------------------------------------------------------
  var_entity := 'Planned Orders';

  OPEN planned_orders;

  LOOP
    var_entity := 'Fetch Planned Orders';

    FETCH planned_orders INTO var_rowid,
                              var_org_id,
                              var_inventory_item_id,
                              var_new_schedule_date,
                              var_new_order_quantity,
                              var_primary_uom_code,
                              var_planner_employee_id,
                              var_make_buy_code,
			      var_project_id;

    EXIT WHEN planned_orders%NOTFOUND;

    -- ----------------------------------------------------------------------
    -- Get organization dependent info
    -- ----------------------------------------------------------------------
    IF (var_org_id <> var_prev_org_id) THEN
/*
      var_entity := 'WIP Discrete Class';

      BEGIN
        SELECT wp.default_discrete_class
        INTO   var_wip_class_code
        FROM   wip_parameters         wp
        WHERE  wp.organization_id     = var_org_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            var_wip_class_code := NULL;
          WHEN OTHERS THEN
            var_buf := var_entity||': '||sqlerrm;
            fnd_file.put_line(FND_FILE.LOG, var_buf);

            ROLLBACK;
            retcode := 2;
            errbuf := var_buf;
            RETURN;
      END;
*/
      var_entity := 'PO Location';

      BEGIN
        SELECT loc.location_id
        INTO   var_location_id
        FROM   hr_locations           loc,
               hr_organization_units  unit
        WHERE  unit.organization_id   = var_org_id
        AND    unit.location_id       = loc.location_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            var_location_id := NULL;
          WHEN OTHERS THEN
            var_buf := var_entity||': '||sqlerrm;
            fnd_file.put_line(FND_FILE.LOG, var_buf);

            ROLLBACK;
            retcode := 2;
            errbuf := var_buf;
            RETURN;
      END;

      IF var_debug THEN
        var_buf := '=================';
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Organization ID        : '||var_org_id;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Location ID            : '||var_location_id;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
      END IF;
    END IF;     /* Org ID */

    -- ----------------------------------------------------------------------
    -- Get item dependent info
    -- ----------------------------------------------------------------------
    IF ( (var_prev_inventory_item_id <> var_inventory_item_id) OR
	 (NVL(var_prev_project_id,-1) <> NVL(var_project_id,-1)) )    THEN

      var_wip_class_code := wip_common.default_acc_class (
                                   var_org_id,
                                   var_inventory_item_id,
                                   1,   -- Entity type for discrete job
-- 5514051                                  NULL,-- Project id
				   var_project_id,
                                   err_msg_1,
                                   err_class_1,
                                   err_msg_2,
                                   err_class_2);

      IF (var_wip_class_code is NULL) THEN
       BEGIN

        var_entity := 'WIP Discrete Class';

        SELECT wp.default_discrete_class
        INTO   var_wip_class_code
        FROM   wip_parameters         wp
        WHERE  wp.organization_id     = var_org_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            var_wip_class_code := NULL;
          WHEN OTHERS THEN
            var_buf := var_entity||': '||sqlerrm;
            fnd_file.put_line(FND_FILE.LOG, var_buf);

            ROLLBACK;
            retcode := 2;
            errbuf := var_buf;
            RETURN;
       END;
      END IF;
    END IF; /* Item Id */

    IF (var_make_buy_code = MAKE) THEN

      -- --------------------------------------------------------------------
      -- Get WIP Jobs parameter
      -- --------------------------------------------------------------------
      IF var_planner_employee_id IS NULL THEN

        var_impl_status_code := UNRELEASED_NO_CHARGES;
	var_job_prefix       := var_default_job_prefix;

      ELSE

        BEGIN
          var_entity := 'WIP Job Status';

          OPEN job_status;
          FETCH job_status INTO var_impl_status_code,var_wip_class_code ,
								var_firm_jobs;
          var_job_prefix  := var_default_job_prefix;

          IF job_status%NOTFOUND THEN
            var_impl_status_code := UNRELEASED_NO_CHARGES;
	    var_job_prefix       := var_default_job_prefix;
          END IF;

          CLOSE job_status;
        END;

      END IF;

      IF var_debug THEN
        var_buf := '----------------- ';
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Item ID                : '||var_inventory_item_id;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Item Make/Buy          : '||var_make_buy_code;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'WIP class code         : '||var_wip_class_code;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Date                   : '||var_new_schedule_date;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Quantity               : '||var_new_order_quantity;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Planner emp ID         : '||var_planner_employee_id;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'WIP job status         : '||var_impl_status_code;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'WIP job prefix         : '||var_job_prefix;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
      END IF;

      -- --------------------------------------------------------------------
      -- Update WIP Jobs planned orders
      -- --------------------------------------------------------------------
      var_entity := 'WIP Planned Orders';

      UPDATE mrp_recommendations
      SET    old_order_quantity       = new_order_quantity,
             quantity_in_process      = new_order_quantity,
             implement_date           = new_schedule_date,
             implement_quantity       = new_order_quantity,
             implement_firm           = DECODE(var_firm_jobs,
												'Y', 1,
											   	2),
             implement_job_name       = var_job_prefix||to_char(wip_job_number_s.nextval),
             implement_status_code    = var_impl_status_code,
             implement_wip_class_code = NVL(var_wip_class_code,var_job_prefix),
             implement_source_org_id  = NULL,
             implement_vendor_id      = NULL,
             implement_vendor_site_id = NULL,
             implement_project_id     = project_id,
             implement_task_id        = task_id,
             implement_demand_class   = var_demand_class,
             load_type                = WIP_DIS_MASS_LOAD,
             implement_as             = WIP_DISCRETE_JOB
      WHERE  rowid                    = var_rowid;

    ELSIF (var_make_buy_code = BUY) THEN

      -- --------------------------------------------------------------------
      -- Verify PO Reqs parameters
      --
      -- If Planner is not an active employee, do not release
      -- --------------------------------------------------------------------
      var_entity := 'Employee';

      SELECT count(*)
      INTO   var_count
      FROM   hr_employees_current_v     emp
      WHERE  emp.employee_id = NVL(var_planner_employee_id, NULL_VALUE);

      IF var_debug THEN
        var_buf := '----------------- ';
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Item ID                : '||var_inventory_item_id;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Item Make/Buy          : '||var_make_buy_code;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Date                   : '||var_new_schedule_date;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Quantity               : '||var_new_order_quantity;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Planner emp ID         : '||var_planner_employee_id;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
        var_buf := 'Active employee        : '||var_count;
        fnd_file.put_line(FND_FILE.LOG, var_buf);
      END IF;

      IF (var_count = 0) THEN

        -- PO Req is not released because Planner is not an active employee

        var_entity := 'Non-released PO Req';

        SELECT param.organization_code, msik.concatenated_segments,
               msik.planner_code
        INTO   var_org_code, var_item, var_planner_code
        FROM   mtl_system_items_kfv     msik,
               mtl_parameters           param,
               mrp_recommendations      mr
        WHERE  mr.rowid                 = var_rowid
        AND    msik.organization_id     = mr.organization_id
        AND    msik.inventory_item_id   = mr.inventory_item_id
        AND    param.organization_id    = mr.organization_id;

        var_buf := '................. ';
        fnd_file.put_line(FND_FILE.LOG, var_buf);

        fnd_message.set_name('MRP', 'MRP_UNRELEASED_ORDER1');
        var_buf := fnd_message.get;
        fnd_file.put_line(FND_FILE.LOG, var_buf);

        fnd_message.set_name('MRP', 'MRP_UNRELEASED_ORDER2');
        fnd_message.set_token('PLANNER_VALUE', var_planner_code);
        fnd_message.set_token('ORG_VALUE', var_org_code);
        fnd_message.set_token('ITEM_VALUE', var_item);
        fnd_message.set_token('DATE_VALUE', to_char(var_new_schedule_date));
        fnd_message.set_token('QTY_VALUE', to_char(var_new_order_quantity));
        var_buf := fnd_message.get;
        fnd_file.put_line(FND_FILE.LOG, var_buf);

      ELSE

        -- ------------------------------------------------------------------
        -- Update PO Reqs planned orders
        -- ------------------------------------------------------------------
        var_entity := 'PO Planned Orders';

        UPDATE mrp_recommendations
        SET    old_order_quantity       = new_order_quantity,
               quantity_in_process      = new_order_quantity,
               implement_date           = new_schedule_date,
               implement_quantity       = new_order_quantity,
               implement_firm           = firm_planned_type,
               implement_dock_date      = new_dock_date,
               implement_employee_id    = var_planner_employee_id,
               implement_uom_code       = var_primary_uom_code,
               implement_location_id    = var_location_id,
               implement_source_org_id  = source_organization_id,
               implement_vendor_id      = source_vendor_id,
               implement_vendor_site_id = source_vendor_site_id,
               implement_project_id     = project_id,
               implement_task_id        = task_id,
               implement_demand_class   = NULL,
               load_type                = PO_MASS_LOAD,
               implement_as             = PO_REQUISITION
        WHERE  rowid                    = var_rowid;

      END IF;   /* Count */

    END IF;     /* Make Buy code */

    var_prev_org_id := var_org_id;
    var_prev_inventory_item_id := var_inventory_item_id;
    var_prev_project_id := var_project_id;

  END LOOP;

  CLOSE planned_orders;

  COMMIT WORK;

  -- ------------------------------------------------------------------------
  -- Release the planned orders
  -- ------------------------------------------------------------------------
  var_entity := 'Release Planned Orders';

  MRP_Rel_Plan_PUB.mrp_release_plan_sc
		     (arg_org_id, arg_org_id, arg_plan_name, var_user_id,
                      var_po_group_by, var_po_batch_number, var_wip_group_id,
                      var_loaded_jobs, var_loaded_reqs, var_loaded_scheds,
                      var_resched_jobs, var_resched_reqs, var_wip_req_id,
                      var_req_load_id, var_req_resched_id);

  var_buf := '+++++++++++++++++ ';
  fnd_file.put_line(FND_FILE.LOG, var_buf);

  fnd_message.set_name('MRP', 'LOADED_WIP');
  fnd_message.set_token('VALUE', to_char(var_loaded_jobs));
  var_buf := fnd_message.get;
  fnd_file.put_line(FND_FILE.LOG, var_buf);

  fnd_message.set_name('MRP', 'LOADED_PO');
  fnd_message.set_token('VALUE', to_char(var_loaded_reqs));
  var_buf := fnd_message.get;
  fnd_file.put_line(FND_FILE.LOG, var_buf);

  fnd_message.set_name('MRP', 'LOAD_WIP_REQUEST_ID');
  fnd_message.set_token('VALUE', to_char(var_wip_req_id));
  var_buf := fnd_message.get;
  fnd_file.put_line(FND_FILE.LOG, var_buf);

  fnd_message.set_name('MRP', 'LOAD_PO_REQUEST_ID');
  fnd_message.set_token('VALUE', to_char(var_req_load_id));
  var_buf := fnd_message.get;
  fnd_file.put_line(FND_FILE.LOG, var_buf);

  IF ((var_loaded_jobs > 0) AND (var_wip_req_id = 0)) THEN
    fnd_file.new_line(FND_FILE.LOG, 1);
    fnd_message.set_name('MRP', 'CANNOT SUBMIT REQUEST-JOBS');
    var_buf := fnd_message.get;
    fnd_file.put_line(FND_FILE.LOG, var_buf);

    retcode := 2;
    errbuf := var_buf;
  END IF;

  IF ((var_loaded_reqs > 0) AND (var_req_load_id = 0)) THEN
    fnd_file.new_line(FND_FILE.LOG, 1);
    fnd_message.set_name('MRP', 'CANNOT SUBMIT REQUEST-REQS');
    var_buf := fnd_message.get;
    fnd_file.put_line(FND_FILE.LOG, var_buf);

    retcode := 2;
    errbuf := var_buf;
  END IF;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    var_buf := var_entity||': '||sqlerrm;
    fnd_file.put_line(FND_FILE.LOG, var_buf);

    ROLLBACK;
    retcode := 2;
    errbuf := var_buf;
    RETURN;
END mrp_auto_release;

END mrp_release_pk;

/
