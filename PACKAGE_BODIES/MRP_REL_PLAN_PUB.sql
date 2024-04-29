--------------------------------------------------------
--  DDL for Package Body MRP_REL_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_REL_PLAN_PUB" AS
/* $Header: MRPPRELB.pls 120.5 2006/09/20 13:11:09 rgurugub noship $ */

--  Start of Comments
--  API name 	MRP_Release_Plan_SC
--  Type 	Public
--  Procedure
--
--  Pre-reqs
--
--  Parameters
--
--  Version 	Current version = 1.0
--  		Initial version = 1.0
--
--  Notes
--
--     OVERVIEW:
--     This procedure populates the WIP and purchasing interface tables with
--     rows for creating and rescheduling jobs, purchase orders, and repetitive
--     schedules
--
--     ARGUMENTS:
--     arg_org_id:         The current organization id
--     arg_compile_desig:  The current plan name
--     arg_user_id:        The user
--     arg_po_group_by:    How to group attributes together for po mass load
--     arg_wip_group_id:   How to group records in wip
--     var_launch_process: Which process to launch
--     var_calendar_code:  Calendar code for current organization
--     var_exception_set_id: Exception set id for current organization
--
--     RETURNS:            Nothing
--
--   Modified by APATANKA. Bug # 371223. A multi-org plan in an org in which
--   it is not defined would generate orders in all orgs.
--
--   Fix includes adding one more parameter -- parameter.org_id which is the
--   log in org and using it when it is not same as mrp_plans.organization_id.
--
--   8/13/96: Changed the name back to MRP_RELEASE_PLAN_SC
--
--   8/26/96: Changing the code.
--

PROCEDURE MRP_RELEASE_PLAN_SC
( arg_log_org_id 		IN 	NUMBER
, arg_org_id 			IN 	NUMBER
, arg_compile_desig 		IN 	VARCHAR2
, arg_user_id 			IN 	NUMBER
, arg_po_group_by 		IN 	NUMBER
, arg_po_batch_number 		IN 	NUMBER
, arg_wip_group_id 		IN 	NUMBER
, arg_loaded_jobs 		IN OUT NOCOPY 	NUMBER
, arg_loaded_reqs 		IN OUT NOCOPY  NUMBER
, arg_loaded_scheds 		IN OUT NOCOPY  NUMBER
, arg_resched_jobs 		IN OUT NOCOPY  NUMBER
, arg_resched_reqs 		IN OUT NOCOPY  NUMBER
, arg_wip_req_id 		IN OUT NOCOPY  NUMBER
, arg_req_load_id 		IN OUT NOCOPY  NUMBER
, arg_req_resched_id 		IN OUT NOCOPY  NUMBER
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER
) IS

    VERSION                 CONSTANT CHAR(80) :=
 '$Header: MRPPRELB.pls 120.5 2006/09/20 13:11:09 rgurugub noship $';
    REQ_GRP_ALL_ON_ONE      CONSTANT INTEGER := 1;  -- PO group by
    REQ_GRP_ITEM            CONSTANT INTEGER := 2;
    REQ_GRP_BUYER           CONSTANT INTEGER := 3;
    REQ_GRP_PLANNER         CONSTANT INTEGER := 4;
    REQ_GRP_VENDOR          CONSTANT INTEGER := 5;
    REQ_GRP_ONE_EACH        CONSTANT INTEGER := 6;
    REQ_GRP_CATEGORY        CONSTANT INTEGER := 7;

    WIP_DIS_MASS_LOAD       CONSTANT INTEGER := 1;
    WIP_REP_MASS_LOAD       CONSTANT INTEGER := 2;
    WIP_DIS_MASS_RESCHEDULE CONSTANT INTEGER := 4;
    PO_MASS_LOAD            CONSTANT INTEGER := 8;
    PO_MASS_RESCHEDULE      CONSTANT INTEGER := 16;

    PURCHASE_ORDER      CONSTANT INTEGER := 1;   -- order type lookup
    PURCH_REQ           CONSTANT INTEGER := 2;
    WORK_ORDER          CONSTANT INTEGER := 3;
    REPETITVE_SCHEDULE  CONSTANT INTEGER := 4;
    PLANNED_ORDER       CONSTANT INTEGER := 5;
    MATERIAL_TRANSFER   CONSTANT INTEGER := 6;
    NONSTD_JOB          CONSTANT INTEGER := 7;
    RECEIPT_PURCH_ORDER CONSTANT INTEGER := 8;
    REQUIREMENT         CONSTANT INTEGER := 9;
    FPO_SUPPLY          CONSTANT INTEGER := 10;

	NOT_UNDER_REV_CONTROL  CONSTANT INTEGER := 1;
	UNDER_REV_CONTROL      CONSTANT INTEGER := 2;

    JOB_CANCELLED          CONSTANT INTEGER := 7;

    PURCHASING_BY_REV      CONSTANT INTEGER := 1;
	NOT_PURCHASING_BY_REV  CONSTANT INTEGER := 2;

    var_launch_process      INTEGER;
	var_handle VARCHAR2(200);
	var_output NUMBER;
	var_purchasing_by_rev   NUMBER;
	var_error_stmt VARCHAR2(2000) := NULL;

    -- parameters used in 'Perform PO reschedule' block
    l_return_code		boolean;
    l_old_need_by_date		date;
    l_new_need_by_date		date;
    l_po_header_id		number;
    l_po_line_id		number;
    l_po_number			varchar2(60);
    lv_result           BOOLEAN;
    var_upd_req_date_rel        varchar2(1);
    var_demand_class              VARCHAR(30);
BEGIN

        -- if mode is NULL then it means that this procedure is called from PWB
	-- where we need to do batch processing
	-- If mode is WF, then we need to do this work only for the
        -- transaction_id that is passed in

	dbms_lock.allocate_unique(arg_compile_desig||to_char(arg_org_id),
							  var_handle);

	var_output := dbms_lock.request(var_handle, 6, 32767, TRUE);
        var_upd_req_date_rel := NVL(FND_PROFILE.VALUE('MRP_UPD_REQ_DATE_REL'),'N');
	if(var_output <> 0) then
		FND_MESSAGE.SET_NAME('MRP', 'GEN-LOCK-WARNING');
		FND_MESSAGE.SET_TOKEN('EVENT', 'RELEASE PLANNED ORDERS');

		var_error_stmt := FND_MESSAGE.GET;

		raise_application_error(-20000, var_error_stmt);
	end if;

  SELECT sched.demand_class
  INTO   var_demand_class
  FROM   mrp_plans mp,
         mrp_schedule_designators sched
  WHERE  sched.organization_id     (+)= mp.organization_id
  AND    sched.schedule_designator (+)= mp.compile_designator
  AND    mp.organization_id           = arg_org_id
  AND    mp.compile_designator        = arg_compile_desig;

    -- ------------------------------------------------------------------------
    -- Perform the wip discrete job mass load
    -- ------------------------------------------------------------------------
    INSERT INTO wip_job_schedule_interface
            (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            group_id,
            source_code,
            source_line_id,
            organization_id,
            load_type,
            status_type,
            last_unit_completion_date,
            bom_revision_date,
            routing_revision_date,
            primary_item_id,
            class_code,
            job_name,
            firm_planned_flag,
            start_quantity,
	    net_quantity,
            demand_class,
            project_id,
            task_id,
	    schedule_group_id,
       	    build_sequence,
	    line_id,
	    alternate_bom_designator,
	    alternate_routing_designator,
	    end_item_unit_number,
	    process_phase,
	    process_status)
    SELECT  SYSDATE,
            arg_user_id,
            mr.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            'MRP',
            mr.transaction_id,
            msi.organization_id,
            1,
            mr.implement_status_code,
            mr.implement_date,
            NULL,
            NULL,
            mr.inventory_item_id,
            mr.implement_wip_class_code,
            mr.implement_job_name,
            mr.implement_firm,
            mr.implement_quantity,
			mr.implement_quantity,
            nvl(mr.implement_demand_class,var_demand_class),
            mr.implement_project_id,
            mr.implement_task_id,
			mr.implement_schedule_group_id,
			mr.implement_build_sequence,
			mr.implement_line_id,
			mr.implement_alternate_bom,
			mr.implement_alternate_routing,
 	    mr.implement_end_item_unit_number,
			2,
			1
      FROM  mtl_parameters          param,
            mrp_system_items        msi,
            mrp_recommendations     mr,
            mrp_plan_organizations_v orgs
    WHERE   param.organization_id = msi.organization_id
    AND     msi.inventory_item_id = mr.inventory_item_id
    AND     msi.compile_designator = mr.compile_designator
    AND     msi.organization_id = mr.organization_id
	AND		mr.release_errors is NULL
    AND     mr.implement_quantity > 0
    AND     mr.organization_id = orgs.planned_organization
    AND     mr.compile_designator = orgs.compile_designator
    AND     orgs.compile_designator = arg_compile_desig
    AND     orgs.organization_id = arg_org_id
    AND     orgs.planned_organization = decode(arg_log_org_id,
                    arg_org_id, orgs.planned_organization,
                    arg_log_org_id)
/** Bug 2190961
    AND     ((arg_mode is null and mr.load_type = WIP_DIS_MASS_LOAD) or
                (arg_mode = 'WF' and mr.transaction_id = arg_transaction_id));
**/
    AND     arg_mode is null
    AND     mr.load_type = WIP_DIS_MASS_LOAD;

    IF SQL%ROWCOUNT > 0
    THEN
        arg_loaded_jobs := SQL%ROWCOUNT;
    ELSE
        arg_loaded_jobs := 0;
    END IF;

    -- ------------------------------------------------------------------------
    -- Perform the wip discrete job mass reschedule
    -- ------------------------------------------------------------------------
    INSERT INTO wip_job_schedule_interface
            (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            group_id,
            organization_id,
            status_type,
            load_type,
            last_unit_completion_date,
            bom_revision_date,
            routing_revision_date,
            job_name,
            firm_planned_flag,
       --     net_quantity,
            start_quantity,
            wip_entity_id,
            demand_class,
            project_id,
            task_id,
			schedule_group_id,
			build_sequence,
			line_id,
			alternate_bom_designator,
			alternate_routing_designator,
	    end_item_unit_number,
			process_phase,
			process_status,
			due_date)
    SELECT  SYSDATE,
            arg_user_id,
            mr.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            msi.organization_id,
            DECODE(NVL(mr.implement_status_code, w.status_code),
                   JOB_CANCELLED,JOB_CANCELLED,NULL), -- 2667045
            3,
            mr.implement_date,
            NULL,
            NULL,
            mr.implement_job_name,
            mr.implement_firm,
            -- mr.implement_quantity,
            DECODE(NVL(mr.implement_status_code, w.status_code),
                          JOB_CANCELLED,TO_NUMBER(NULL),
            DECODE(w.job_quantity, mr.implement_quantity,
                   TO_NUMBER(NULL),
                   ((w.job_quantity + NVL(w.quantity_completed, 0) +
                     NVL(w.quantity_scrapped, 0)) -
                    (w.job_quantity - mr.implement_quantity)))),
            mr.disposition_id,
            nvl(mr.implement_demand_class,var_demand_class),
            mr.implement_project_id,
            mr.implement_task_id,
			mr.implement_schedule_group_id,
			mr.implement_build_sequence,
			mr.implement_line_id,
			mr.implement_alternate_bom,
			mr.implement_alternate_routing,
	    mr.implement_end_item_unit_number,
			2,
			1,
			Decode(var_upd_req_date_rel,'Y',mr.implement_date,NULL)
    FROM    mtl_parameters param,
            mrp_item_wip_entities w,
            mrp_system_items msi,
            mrp_recommendations mr,
            mrp_plan_organizations_v orgs
    WHERE   param.organization_id = msi.organization_id
    AND     msi.inventory_item_id = mr.inventory_item_id
    AND     msi.compile_designator = mr.compile_designator
    AND     msi.organization_id = mr.organization_id
    AND     w.compile_designator = mr.compile_designator
    AND     w.organization_id = mr.organization_id
    AND     w.inventory_item_id = mr.inventory_item_id
    AND     w.wip_entity_id = mr.disposition_id
	AND		mr.release_errors is NULL
    AND     mr.organization_id = orgs.planned_organization
    AND     mr.compile_designator = orgs.compile_designator
    AND     orgs.organization_id = arg_org_id
    AND     orgs.compile_designator = arg_compile_desig
    AND     orgs.planned_organization = decode(arg_log_org_id,
                    arg_org_id, orgs.planned_organization,
                    arg_log_org_id)
    AND     ((arg_mode is null and mr.load_type = WIP_DIS_MASS_RESCHEDULE) or
                (arg_mode = 'WF' and mr.transaction_id = arg_transaction_id));


    IF SQL%ROWCOUNT > 0 THEN
        arg_resched_jobs := SQL%ROWCOUNT;
    ELSE
        arg_resched_jobs := 0;
    END IF;
    -- ------------------------------------------------------------------------
    -- Perform the wip repetitive schedule mass load
    -- ------------------------------------------------------------------------
    INSERT INTO wip_job_schedule_interface
            (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            group_id,
            source_code,
            source_line_id,
            organization_id,
            load_type,
            last_unit_completion_date,
            bom_revision_date,
            routing_revision_date,
            processing_work_days,
            daily_production_rate,
            line_id,
            primary_item_id,
            firm_planned_flag,
            demand_class,
			process_phase,
			process_status)
       SELECT SYSDATE,
			arg_user_id,
            msrs.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            'MRP',
            msrs.transaction_id,
            msi.organization_id,
            2,
            msrs.implement_date,
			NULL,
			NULL,
            msrs.implement_processing_days,
            msrs.implement_daily_rate,
            msrs.implement_line_id,
            msrs.inventory_item_id,
            msrs.implement_firm,
            nvl(msrs.implement_demand_class,var_demand_class),
			2,
			1
    FROM    mtl_parameters param,
            mrp_system_items msi,
            mrp_sugg_rep_schedules msrs,
            mrp_plan_organizations_v orgs
    WHERE   param.organization_id = msi.organization_id
    AND     msi.compile_designator = msrs.compile_designator
    AND     msi.organization_id = msrs.organization_id
    AND     msi.inventory_item_id = msrs.inventory_item_id
	AND		msrs.release_errors is NULL
    AND     msrs.implement_daily_rate > 0
    AND     msrs.organization_id = orgs.planned_organization
    AND     msrs.compile_designator = orgs.compile_designator
    AND     orgs.organization_id = arg_org_id
    AND     orgs.compile_designator = arg_compile_desig
    AND     orgs.planned_organization = decode(arg_log_org_id,
                    arg_org_id, orgs.planned_organization,
                    arg_log_org_id)
    AND     ((arg_mode is null and msrs.load_type = WIP_REP_MASS_LOAD) or
                (arg_mode = 'WF' and msrs.transaction_id = arg_transaction_id));

    IF SQL%ROWCOUNT > 0 THEN
        arg_loaded_scheds := SQL%ROWCOUNT;
    ELSE
        arg_loaded_scheds := 0;
    END IF;


    -- ------------------------------------------------------------------------
    -- Perform the po mass load
    -- ------------------------------------------------------------------------
    --  Check if the profile MRP_PURCHASING_BY_REVISION is set
var_purchasing_by_rev :=
                    FND_PROFILE.VALUE('MRP_PURCHASING_BY_REVISION');


    --  NOTE: We always pass 'VENDOR' as the group by parameter to the req
    -- import program.  PO will only look at this parameter if it has failed
    -- to find a value in the group code.

/* 1284534 - SVAIDYAN: Insert vendor_site_code only if implement_vendor_id
   is not null. Otherwise, this will insert vendor site code for Internal
   Req. also.
*/

    INSERT INTO po_requisitions_interface_all
            (/*line_type_id, Amount or Quantity based */
			last_updated_by,
            last_update_date,
            last_update_login,
            creation_date,
            created_by,
            item_id,
            quantity,
            need_by_date,
            interface_source_code,
            deliver_to_location_id,
            deliver_to_requestor_id,
            destination_type_code,
            preparer_id,
            source_type_code,
            authorization_status,
            uom_code,
            batch_id,
            charge_account_id,
            group_code,
            item_revision,
            destination_organization_id,
            autosource_flag,
            org_id,
            source_organization_id,
            suggested_vendor_id,
	     suggested_vendor_site_id,
	     suggested_vendor_site,
            project_id,
            task_id,
	    end_item_unit_number,
			project_accounting_context)
    SELECT /*+ INDEX(MSI MRP_SYSTEM_ITEMS_U1)*/ /*2448571*/
		/*	1, Quantity based */
            mr.last_updated_by,
            SYSDATE,
            mr.last_update_login,
            SYSDATE,
            mr.created_by,
            mr.inventory_item_id,
            mr.implement_quantity,
       /*   cal2.calendar_date, */
            get_dock_date(arg_compile_desig,
                          orgs.organization_id,/*2448572*/
                          mp.calendar_exception_set_id,
                          mp.calendar_code,
                          mr.implement_date,
                          nvl(mr.implement_vendor_id, mr.source_vendor_id),
                          nvl(mr.implement_vendor_site_id, mr.source_vendor_site_id),
                          msi.inventory_item_id,
                          NVL(msi.postprocessing_lead_time, 0)),
            'MRP',
            mr.implement_location_id,
         	mr.implement_employee_id,
            'INVENTORY',
            mr.implement_employee_id,
            DECODE(mr.implement_vendor_id,
                NULL, DECODE(mr.implement_source_org_id,
                NULL,NULL,
                'INVENTORY')
                ,'VENDOR'), -- PO wants us to pass null now -- spob
            'APPROVED',
            msi.uom_code, --mr.implement_uom_code,
            arg_po_batch_number,
            nvl(ccga.material_account, decode(mti.inventory_asset_flag,
			   		'Y', mp.material_account,
					 nvl(mti.expense_account, mp.expense_account))),
            decode(arg_po_group_by,
                REQ_GRP_ALL_ON_ONE, 'ALL-ON-ONE',
                REQ_GRP_ITEM, to_char(mr.inventory_item_id),
                REQ_GRP_BUYER, nvl(to_char(msi.buyer_id),NULL),
                REQ_GRP_PLANNER, nvl(msi.planner_code,'PLANNER'),
                REQ_GRP_VENDOR,  NULL,
                REQ_GRP_ONE_EACH,
                to_char(po_requisitions_interface_s.nextval),
                REQ_GRP_CATEGORY,
                nvl(to_char(msi.category_id),NULL),
                NULL),
            DECODE(var_purchasing_by_rev, NULL,
			   DECODE(mti.REVISION_QTY_CONTROL_CODE,
			          NOT_UNDER_REV_CONTROL, NULL, msi.revision),
			          PURCHASING_BY_REV, msi.revision,
	                  NOT_PURCHASING_BY_REV, NULL),
            mr.organization_id,
            'P',
            ood.operating_unit,
            mr.implement_source_org_id,
            nvl(mr.implement_vendor_id,
				mr.source_vendor_id),
            nvl(mr.implement_vendor_site_id,
		mr.source_vendor_site_id),
            decode(mr.implement_vendor_id, NULL, NULL, pos.vendor_site_code),
            mr.implement_project_id,
            mr.implement_task_id,
  	    mr.implement_end_item_unit_number,
			DECODE(mr.implement_project_id, NULL,
				   'N', 'Y')
      FROM  po_vendor_sites_all pos,
            cst_cost_group_accounts ccga,
            mrp_project_parameters mpp,
            org_organization_definitions ood,
            mtl_parameters      mp,
			mtl_system_items mti,
            mrp_system_items    msi,
            mrp_recommendations mr,
            mrp_plan_organizations_v orgs
    WHERE  ccga.cost_group_id (+)= nvl(mpp.costing_group_id, -23453)
      AND  ccga.organization_id(+)= mpp.organization_id
      AND  mpp.organization_id (+)= mr.organization_id
      AND  mpp.project_id (+)= nvl(mr.implement_project_id, -23453)
      AND  pos.vendor_id(+) = nvl(mr.implement_vendor_id,mr.source_vendor_id)
      AND  pos.vendor_site_id(+) = nvl(mr.implement_vendor_site_id,mr.source_vendor_site_id)
    AND     ood.organization_id = msi.organization_id
    AND     mp.organization_id = msi.organization_id
	AND     mti.inventory_item_id = msi.inventory_item_id
	AND     mti.organization_id = msi.organization_id
    AND     msi.inventory_item_id = mr.inventory_item_id
    AND     msi.compile_designator = mr.compile_designator
    AND     msi.organization_id = mr.organization_id
	AND		mr.release_errors is NULL
    AND     mr.implement_quantity > 0
    AND     mr.organization_id = orgs.planned_organization
    AND     mr.compile_designator = orgs.compile_designator
    AND     orgs.organization_id = arg_org_id
    AND     orgs.compile_designator = arg_compile_desig
    AND     orgs.planned_organization = decode(arg_log_org_id,
                    arg_org_id, orgs.planned_organization,
                    arg_log_org_id)
/*** bug 2190961
    AND     ((arg_mode is null and mr.load_type = PO_MASS_LOAD) or
                (arg_mode = 'WF' and mr.transaction_id = arg_transaction_id));
**/
    AND     arg_mode is null and mr.load_type = PO_MASS_LOAD;



    IF SQL%ROWCOUNT > 0 THEN
        arg_loaded_reqs := SQL%ROWCOUNT;
    ELSE
        arg_loaded_reqs := 0;
    END IF;
    -- ------------------------------------------------------------------------
    -- Perform the po mass reschedule
    -- ------------------------------------------------------------------------

    INSERT INTO po_reschedule_interface
            (quantity,
            need_by_date,
            line_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by)
    SELECT  mr.implement_quantity,
         /*   cal2.calendar_date, */
            get_dock_date(arg_compile_desig,
                          orgs.organization_id,/*2448572*/
                          mp.calendar_exception_set_id,
                          mp.calendar_code,
                          mr.implement_date,
                          nvl(mr.implement_vendor_id, mr.source_vendor_id),
                          nvl(mr.implement_vendor_site_id, mr.source_vendor_site_id),
                          msi.inventory_item_id,
                          NVL(msi.postprocessing_lead_time, 0)),
            mipo.line_id,
            SYSDATE,
            arg_user_id,
            SYSDATE,
            arg_user_id
    FROM
            mtl_parameters mp,
            mrp_item_purchase_orders mipo,
            mrp_system_items msi,
            mrp_recommendations mr,
            mrp_plan_organizations_v orgs
    WHERE   mipo.transaction_id = mr.disposition_id
    AND     mipo.line_id IS NOT NULL
    AND     mipo.compile_designator = mr.compile_designator
    AND     mipo.organization_id = mr.organization_id
    AND     mipo.inventory_item_id = mr.inventory_item_id
    AND     mp.organization_id = msi.organization_id
    AND     msi.inventory_item_id = mr.inventory_item_id
    AND     msi.compile_designator = mr.compile_designator
    AND     msi.organization_id = mr.organization_id
	AND		mr.release_errors is NULL
    AND     mr.organization_id = orgs.planned_organization
    AND     mr.compile_designator = orgs.compile_designator
    AND     mr.order_type = PURCH_REQ
    AND     orgs.organization_id = arg_org_id
    AND     orgs.compile_designator = arg_compile_desig
    AND     orgs.planned_organization = decode(arg_log_org_id,
                    arg_org_id, orgs.planned_organization,
                    arg_log_org_id)
    AND     ((arg_mode is null and mr.load_type = PO_MASS_RESCHEDULE) or
                (arg_mode = 'WF' and mr.transaction_id = arg_transaction_id));

    IF SQL%ROWCOUNT > 0  THEN
        arg_resched_reqs := SQL%ROWCOUNT;
    ELSE
        arg_resched_reqs := 0;
    END IF;

    -- ------------------------------------------------------------------------
    -- Perform PO reschedule
    -- ------------------------------------------------------------------------

    IF (arg_mode = 'WF') THEN

      BEGIN

        SELECT  mr.old_schedule_date,
         /*       cal2.calendar_date, */
            get_dock_date(arg_compile_desig,
                          orgs.organization_id,/*2448572*/
                          mp.calendar_exception_set_id,
                          mp.calendar_code,
                          mr.implement_date,
                          nvl(mr.implement_vendor_id, mr.source_vendor_id),
                          nvl(mr.implement_vendor_site_id, mr.source_vendor_site_id),
                          msi.inventory_item_id,
                          NVL(msi.postprocessing_lead_time, 0)) ,
                mipo.purchase_order_id,
                mipo.line_id,
                mipo.po_number
        INTO    l_old_need_by_date,
                l_new_need_by_date,
                l_po_header_id,
                l_po_line_id,
                l_po_number
        FROM
                mtl_parameters mp,
                mrp_item_purchase_orders mipo,
                mrp_system_items msi,
                mrp_recommendations mr,
                mrp_plan_organizations_v orgs
        WHERE   mipo.transaction_id = mr.disposition_id
        AND     mipo.line_id IS NOT NULL
        AND     mipo.compile_designator = mr.compile_designator
        AND     mipo.organization_id = mr.organization_id
        AND     mipo.inventory_item_id = mr.inventory_item_id
        AND     mp.organization_id = msi.organization_id
        AND     msi.inventory_item_id = mr.inventory_item_id
        AND     msi.compile_designator = mr.compile_designator
        AND     msi.organization_id = mr.organization_id
        AND     mr.release_errors is NULL
        AND     mr.order_type = PURCHASE_ORDER
        AND     mr.organization_id = orgs.planned_organization
        AND     mr.compile_designator = orgs.compile_designator
        AND     orgs.organization_id = arg_org_id
        AND     orgs.compile_designator = arg_compile_desig
        AND     orgs.planned_organization = decode(arg_log_org_id,
                        arg_org_id, orgs.planned_organization,
                        arg_log_org_id)
        AND     mr.transaction_id = arg_transaction_id;

        l_return_code := po_reschedule_pkg.reschedule(l_old_need_by_date,
                                                      l_new_need_by_date,
                                                      l_po_header_id,
                                                      l_po_line_id,
                                                      l_po_number);

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          null;

      END;

    END IF;

    IF ((arg_loaded_jobs > 0)  OR
        (arg_resched_jobs > 0) OR
        (arg_loaded_scheds >0)) THEN
        arg_wip_req_id := NULL;
        arg_wip_req_id := FND_REQUEST.SUBMIT_REQUEST(
                                        'WIP',      -- application
                                        'WICMLP',   -- program
                                        NULL,       -- description
                                        NULL,       -- start_time
                                        FALSE,      -- sub_request
                                        arg_wip_group_id, -- group_id
						1,         -- validation_level
						1);          -- print report
    END IF;

    IF arg_loaded_reqs > 0 THEN
      DECLARE po_group_by_name VARCHAR2(10);
      BEGIN
        IF arg_po_group_by = 1 THEN
          po_group_by_name := 'ALL';
        ELSIF arg_po_group_by = 2 THEN
          po_group_by_name := 'ITEM';
        ELSIF arg_po_group_by = 3 THEN
          po_group_by_name := 'BUYER';
        ELSIF arg_po_group_by = 4 THEN
          po_group_by_name := 'PLANNER';
        ELSIF arg_po_group_by = 5 THEN
          po_group_by_name := 'VENDOR';
        ELSIF arg_po_group_by = 6 THEN
          po_group_by_name := 'ONE-EACH';
        ELSIF arg_po_group_by = 7 THEN
          po_group_by_name := 'CATEGORY';
        END IF;

		-- Launching the REQIMPORT in loop for each OU, change for MOAC

		DECLARE

		   CURSOR c1 IS
			  SELECT
				DISTINCT org_id
				FROM PO_REQUISITIONS_INTERFACE_ALL
				WHERE
				batch_id = arg_po_batch_number;
		BEGIN

		   FOR C2 IN C1
			 LOOP

				MO_GLOBAL.INIT ('PO');
				FND_REQUEST.SET_ORG_ID (c2.org_id);

				-- set to trigger mode to bypass the 'SAVEPOINT'
				-- and 'ROLLBACK' command.
				lv_result := FND_REQUEST.SET_MODE(TRUE);


				arg_req_load_id := NULL;

				arg_req_load_id :=
				  FND_REQUEST.SUBMIT_REQUEST(
											 'PO',       -- application
											 'REQIMPORT',-- program
											 NULL,       -- description
											 NULL,       -- start_time
											 FALSE,      -- sub_request
											 'MRP',
											 arg_po_batch_number,
											 po_group_by_name,
											 0);

			 END LOOP;
		END;

      END;
    END IF;

    IF arg_resched_reqs > 0 THEN
	DECLARE
		CURSOR c1 IS
		SELECT DISTINCT prla.org_id
		FROM PO_RESCHEDULE_INTERFACE PRI, PO_REQUISITION_LINES_ALL PRLA
		WHERE pri.line_id = prla.requisition_line_id;

	BEGIN
		FOR C2 IN C1
		LOOP

			MO_GLOBAL.INIT ('PO');
			FND_REQUEST.SET_ORG_ID (c2.org_id);
			-- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
			lv_result := FND_REQUEST.SET_MODE(TRUE);

			arg_req_resched_id := NULL;
			arg_req_resched_id := FND_REQUEST.SUBMIT_REQUEST(
								    'PO',       -- application
								    'POXRSR',   -- program
								    NULL,       -- description
								    NULL,       -- start_time
								    FALSE);      -- sub_request
		END LOOP;
	END;

    END IF;

    IF (arg_loaded_jobs > 0 OR arg_loaded_reqs > 0 OR
            arg_resched_jobs > 0 OR arg_resched_reqs > 0)
    THEN
        UPDATE
                mrp_recommendations
                SET implement_demand_class = NULL,
                implement_date = NULL,
                implement_quantity = NULL,
                implement_firm = NULL,
                implement_wip_class_code = NULL,
                implement_job_name = NULL,
                implement_status_code = NULL,
                implement_location_id = NULL,
                implement_source_org_id = NULL,
                implement_vendor_id = NULL,
                implement_vendor_site_id = NULL,
                implement_project_id = NULL,
                implement_task_id = NULL,
                release_status = NULL,
                number1 = NULL,
                load_type = NULL,
                implement_as = NULL,
                implement_end_item_unit_number = NULL,
				implement_schedule_group_id = NULL,
				implement_build_sequence = NULL,
				implement_line_id = NULL,
				implement_alternate_bom = NULL,
				implement_alternate_routing = NULL
        WHERE   organization_id IN
                    (select planned_organization
                     from mrp_plan_organizations_v
                     where organization_id = arg_org_id
                     and compile_designator = arg_compile_desig
                     AND planned_organization = decode(arg_log_org_id,
                    arg_org_id, planned_organization,
                    arg_log_org_id))
        AND     compile_designator = arg_compile_desig
		AND		release_errors IS NULL
        AND     load_type in (1,2,3,4,5,8,16); /*2448572*/

    END IF;

    IF arg_loaded_scheds > 0
    THEN
        UPDATE  mrp_sugg_rep_schedules
        SET     implement_demand_class = NULL,
                implement_date = NULL,
                implement_daily_rate = NULL,
                implement_firm = NULL,
                implement_processing_days = NULL,
                implement_wip_class_code = NULL,
                implement_line_id = NULL,
                release_status = NULL,
                load_type = NULL,
                status = 3 -- bug2797945
        WHERE   organization_id IN
                    (select planned_organization
                     from mrp_plan_organizations_v
                     where organization_id = arg_org_id
                     and compile_designator = arg_compile_desig
                 AND planned_organization = decode(arg_log_org_id,
                    arg_org_id, planned_organization,
                    arg_log_org_id))
        AND     compile_designator = arg_compile_desig
        AND     load_type = WIP_REP_MASS_LOAD
		AND		release_errors IS NULL;
    END IF;

    COMMIT WORK;


END MRP_Release_Plan_Sc;

/** Bug1519701 : Added this function to derive the NEED_BY_DATE in
    the PO Interface table by first applying the default calendar and
    the Item Post Processing Lead Time to the Implement date
    and then applying to it the delivery calendar if one exists. The
    dock date is ignored */
FUNCTION GET_DOCK_DATE
( arg_compile_desig         IN  VARCHAR2
, arg_plan_owning_org  IN      NUMBER /*2448572*/
, arg_calendar_exception_set_id	IN 	NUMBER
, arg_calendar_code  IN VARCHAR2
, arg_implement_date IN DATE
, arg_vendor_id IN NUMBER
, arg_vendor_site_id IN NUMBER
, arg_item_id IN NUMBER
, arg_lead_time IN NUMBER
) RETURN DATE IS

source_date date;
dock_date date;

BEGIN

    SELECT  cal2.calendar_date
    INTO    source_date
    FROM    bom_calendar_dates cal1,
            bom_calendar_dates cal2
    WHERE   cal1.calendar_code = arg_calendar_code
    AND     cal1.exception_set_id = arg_calendar_exception_set_id
    AND     cal1.calendar_date = arg_implement_date
    AND     cal2.calendar_code = cal1.calendar_code
    AND     cal2.exception_set_id = cal1.exception_set_id
    AND     cal2.seq_num = GREATEST(1,NVL(cal1.seq_num, cal1.prior_seq_num) -
                NVL(arg_lead_time, 0));

    BEGIN
    SELECT  cal2.calendar_date
    INTO    dock_date
    FROM    bom_calendar_dates cal1,
            bom_calendar_dates cal2,
            mrp_item_suppliers mis
    WHERE   mis.organization_id    = arg_plan_owning_org /*2448572*/
    AND     mis.compile_designator = arg_compile_desig
    AND     mis.supplier_id = arg_vendor_id
    AND     mis.supplier_site_id = arg_vendor_site_id
    AND     mis.inventory_item_id = arg_item_id
	AND     mis.using_organization_id = -1 /* Global ASL */
    AND     cal1.calendar_code = mis.delivery_calendar_code
    AND     cal1.exception_set_id =  arg_calendar_exception_set_id
    AND     cal1.calendar_date = source_date
    AND     cal2.calendar_code = cal1.calendar_code
    AND     cal2.exception_set_id = cal1.exception_set_id
    AND     cal2.seq_num = GREATEST(1,NVL(cal1.seq_num, cal1.prior_seq_num) );
    EXCEPTION WHEN NO_DATA_FOUND THEN /* No Delivery Calendar */
         dock_date := source_date;
    END;

  RETURN(dock_date);

END get_dock_date;

END MRP_Rel_Plan_PUB;

/
