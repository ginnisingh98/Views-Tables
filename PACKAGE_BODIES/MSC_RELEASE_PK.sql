--------------------------------------------------------
--  DDL for Package Body MSC_RELEASE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_RELEASE_PK" AS
 /* $Header: MSCARELB.pls 120.9.12010000.9 2009/11/02 09:19:16 lsindhur ship $ */
  WIP_DIS_MASS_LOAD             CONSTANT INTEGER := 1;
  PO_MASS_LOAD                  CONSTANT INTEGER := 8;
  PO_REQUISITION                CONSTANT INTEGER := 2;
  WIP_DISCRETE_JOB              CONSTANT INTEGER := 3;
  MAKE                          CONSTANT INTEGER := 1;
  BUY                           CONSTANT INTEGER := 2;
  PLANNED_ORDER                 CONSTANT INTEGER := 5;
  PLANNED_NEW_BUY_ORDER         CONSTANT INTEGER:= 76;
  PLANNED_IRO		                CONSTANT INTEGER:= 77;
  PLANNED_ERO		                CONSTANT INTEGER:= 78;
  PLANNED_TRANSFER              CONSTANT  INTEGER:=51;
  CANCEL                        CONSTANT INTEGER := 2;
  RESCHEDULE                    CONSTANT INTEGER := 2;
  PURCHASE_ORDER                CONSTANT INTEGER := 1;
  UNRELEASED_NO_CHARGES         CONSTANT INTEGER := 1;
  STANDARD_ITEM                 CONSTANT INTEGER := 4;
  NO_AUTO_RELEASE               CONSTANT INTEGER := 5;
  NO_KANBAN_RELEASE		CONSTANT INTEGER := 6;

  MRP_PLAN                      CONSTANT INTEGER := 1;
  MPS_PLAN                      CONSTANT INTEGER := 2;
  MPP_PLAN                      CONSTANT INTEGER := 3;
  DRP_PLAN                      CONSTANT INTEGER := 5;
  SRP_PLAN			                CONSTANT INTEGER:= 8;


  MRP_PLANNED_ITEM              CONSTANT INTEGER := 3;
  MPS_PLANNED_ITEM              CONSTANT INTEGER := 4;
  MPPMRP_PLANNED_ITEM           CONSTANT INTEGER := 7;
  MPPMPS_PLANNED_ITEM           CONSTANT INTEGER := 8;

  NULL_VALUE                    CONSTANT INTEGER := -23453;
  MAGIC_STRING                  CONSTANT VARCHAR2(10) := '734jkhJK24';
  BUFFER_SIZE_LEN		CONSTANT INTEGER := 1000000;
  NULL_DBLINK                   CONSTANT VARCHAR2(1):= ' ';

  SYS_YES                       CONSTANT INTEGER := 1;
  SYS_NO                        CONSTANT INTEGER := 2;

  G_APPS107                    CONSTANT NUMBER := 1;
  G_APPS110                    CONSTANT NUMBER := 2;
  G_APPS115                    CONSTANT NUMBER := 3;

  ERO_LOAD                CONSTANT  NUMBER := 128;
  IRO_LOAD                CONSTANT  NUMBER := 256;
  TRANSFER_LOAD           CONSTANT  NUMBER := 32;
  DRP_REQ_RESCHED         constant integer := 64;  -- drp release


-- ========================================================================

  var_released_instance_count   NUMBER;

  var_loaded_jobs               MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_loaded_reqs               MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_loaded_scheds             MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_resched_jobs              MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_resched_reqs              MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_wip_req_id                MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_req_load_id               MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_req_resched_id            MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_released_instance_id      MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_loaded_lot_jobs           MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_resched_lot_jobs          MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_osfm_req_id               MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_resched_eam_jobs          MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_eam_req_id                MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_loaded_int_reqs           MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_resched_int_reqs          MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_int_req_load_id           MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_int_req_resched_id        MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_loaded_int_repair_orders  MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_int_repair_orders_id      MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_loaded_ext_repair_orders  MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_ext_repair_orders_id      MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_released_instance         msc_rel_wf.NumTblTyp:= msc_rel_wf.NumTblTyp(0);
  var_po_res_id                 msc_rel_wf.NumTblTyp:= msc_rel_wf.NumTblTyp(0);
  var_po_res_count              msc_rel_wf.NumTblTyp:= msc_rel_wf.NumTblTyp(0);
  var_po_pwb_count              msc_rel_wf.NumTblTyp:= msc_rel_wf.NumTblTyp(0);
  var_count_po                  NUMBER := 0;


-- ========================================================================
--
--  Selects the rows in MSC_SUPPLIES for all orgs in a given plan
--  that meet the auto-release criteria and release those planned orders and reschedules
--
-- ========================================================================

PROCEDURE msc_auto_release(
                        errbuf			OUT NOCOPY VARCHAR2,
		        retcode			OUT NOCOPY NUMBER,
                        arg_plan_id             IN  NUMBER,
                        arg_org_id              IN  NUMBER,
                        arg_instance_id         IN  NUMBER,
			arg_use_start_date      IN  VARCHAR2) IS

  VERSION                       CONSTANT CHAR(80) :=
        '$Header: MSCARELB.pls 120.9.12010000.9 2009/11/02 09:19:16 lsindhur ship $';

  counter			NUMBER := 0;

  var_sql_stmt                  VARCHAR2(2000);

  var_allow_release             NUMBER;
  var_instance_code             VARCHAR2(10);

  var_dblink                    VARCHAR2(128);
  var_apps_ver                  NUMBER;
  v_dblink                      VARCHAR2(128);

  var_user_id                   NUMBER;
  var_po_group_by               NUMBER;
  var_po_batch_number           NUMBER;
  var_wip_group_id              NUMBER;
  var_transaction_id            NUMBER;
  var_sr_instance_id            NUMBER;
  var_supplier_id   		NUMBER;
  var_supplier_site_id 		NUMBER;
  var_source_supplier_id   	NUMBER;
  var_source_supplier_site_id 	NUMBER;
  var_plan_id                   NUMBER;
  var_start_date		DATE;
  var_demand_class              VARCHAR(30);
  var_wip_class_code            VARCHAR(10);
  var_wip_job_number            NUMBER;         -- <=== new
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
  var_org_code                  VARCHAR(7);
  var_org_id                    NUMBER;
  var_prev_org_id               NUMBER := -1;
  var_inventory_item_id         NUMBER;
  var_sr_inventory_item_id      NUMBER;
  var_prev_inventory_item_id    NUMBER := -1;
  var_item                      VARCHAR(50);
  var_new_schedule_date         DATE;
  var_new_order_quantity        NUMBER;
  var_order_type                NUMBER;
  var_load_type                 NUMBER;
  var_planner_code              VARCHAR(10);
  var_debug                     BOOLEAN := FALSE;
  var_entity                    VARCHAR(30);
  var_buf			VARCHAR2(2000);
  var_project_id		NUMBER;
  var_sales_order_line_id       NUMBER;

  err_msg_1                     VARCHAR2(30);
  err_class_1                   VARCHAR2(10);
  err_msg_2                     VARCHAR2(30);
  err_class_2                   VARCHAR2(10);

  --Added to fix the bug#2538765
  var_user_name         VARCHAR2(100):= NULL;
  var_resp_name         VARCHAR2(100):= NULL;
  var_application_name  VARCHAR2(240):= NULL;
  --Added to fix the bug#2538765

  -- for 3298070
  lv_plan_name                   VARCHAR2(100):=NULL;

  v_comp_days_tol number := NVL(FND_PROFILE.VALUE('MSC_AUTO_REL_COMP_TOLERANCE'),0);

  v_wip_group_id      NUMBER;
  v_po_batch_number   NUMBER;

  lv_plan_release_profile number;
  invalid_plan                  EXCEPTION;

cursor plan_type_c(v_plan_id number) is
select curr_plan_type
from msc_plans
where plan_id = v_plan_id;

l_def_pref_id number;
l_plan_type number;
p_where_clause varchar2(3000):= NULL;
p_total_rows  NUMBER;
p_succ_rows  NUMBER;
p_error_rows  NUMBER;


  --
  -- PLANNING_MAKE_BUY_CODE cannot be used to determine whether an item is
  -- a make or buy item for time-phased make-buy item, instead use
  --
  --       Curr org     Source org     Item type
  --       --------     ----------     ---------
  --        A.X           A.X            Make (always populated for Make item) - Same Org in Same Instance
  --        A.X           B.X            Buy ( Same Org-Id across Instances)
  --          X             Y            Buy
  --        A.X           B.Y            Buy ( Diff Org-Id across Instances)
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

           CURSOR planned_orders_and_reschedules IS
           SELECT
	           mr.transaction_id,
                   mr.sr_instance_id,
                   mr.plan_id,
                   mr.organization_id,
                   mr.inventory_item_id,
                   nvl(mr.supplier_id,mt.modeled_supplier_id),
                   nvl(mr.supplier_site_id,mt.modeled_supplier_site_id),
                   nvl(mr.source_supplier_id,mt.modeled_supplier_id),
                   nvl(mr.source_supplier_site_id,mt.modeled_supplier_site_id),
                   mr.new_schedule_date,
                   mr.new_order_quantity,
                   mr.order_type,
 		              decode(mr.order_type,
 		                       PLANNED_ORDER, decode(decode(mr.sr_instance_id,
 		                                    mr.source_sr_instance_id, DECODE(mr.source_organization_id,mr.organization_id,MAKE,BUY),
                                                     BUY),
 					                             MAKE, decode(CFM_ROUTING_FLAG, 3,5,1),
 					                            BUY,  8),
 					                PLANNED_NEW_BUY_ORDER, decode(decode(mr.sr_instance_id,
 		                                    mr.source_sr_instance_id, DECODE(mr.source_organization_id,mr.organization_id,MAKE,BUY),
                                                     BUY),
 					                             MAKE, decode(CFM_ROUTING_FLAG, 3,5,1),
 					                            BUY,  8),
 		                     PO_REQUISITION, 16,
 		                     PURCHASE_ORDER,       20,
 		                     WIP_DISCRETE_JOB,         decode(CFM_ROUTING_FLAG, 3,6,4)),
                   msi.uom_code,
                   mpl.employee_id,
                   decode(mr.sr_instance_id,mr.source_sr_instance_id,
                             DECODE(mr.source_organization_id,mr.organization_id,1,2),
                                  2),
                   msi.sr_inventory_item_id,
		          nvl(mr.implement_project_id,mr.project_id)
              FROM msc_calendar_dates cal1,
                   msc_calendar_dates cal2,
                   msc_planners mpl,
                   msc_trading_partners     mparam,
                   msc_system_items         msi,
                   msc_system_items         rsi,
                   msc_supplies             mr,
                   msc_plan_organizations_v mpo,
                   msc_plans                mps,
                   msc_trading_partners     mt
            WHERE  mpo.organization_id      = arg_org_id
            AND    mpo.plan_id              = arg_plan_id
            AND    mpo.sr_instance_id       = arg_instance_id
            AND    mr.sr_instance_id        = mpo.sr_instance_id
            AND    mr.organization_id       = mpo.planned_organization
            AND    mr.plan_id               = mpo.plan_id
            AND    mr.plan_id               = mps.plan_id
            --for bug#2881012
            AND    (    mr.order_type in (PLANNED_ORDER, PLANNED_NEW_BUY_ORDER)
                      OR (      mr.order_type       IN (PURCHASE_ORDER,PO_REQUISITION,WIP_DISCRETE_JOB)
 		           and mps.release_reschedules = SYS_YES
 		           and (   mr.disposition_status_type = CANCEL -- 2 is cancel
 			        or (    mr.reschedule_flag = RESCHEDULE   -- 2 => reschedule
 				    and mr.new_schedule_date <> mr.old_schedule_date
 				     and (nvl(mr.reschedule_days,0) <> 0)  -- 8726490 , 9064626
 				    )
 			        )
 			)
 		   )
            AND   (NVL(mr.schedule_compress_days, 0) = 0  OR
                     mr.schedule_compress_days <= v_comp_days_tol )
            AND    decode(nvl(mr.reschedule_days,0),0,mr.new_order_placement_date,decode(sign(trunc(mr.new_order_placement_date)-trunc(mr.old_order_placement_date)),1,mr.old_order_placement_date,-1,mr.new_order_placement_date))
                                             <= TRUNC(cal2.calendar_date)    --bug8351869
            AND    msi.organization_id      = mr.organization_id
            AND    msi.sr_instance_id       = mr.sr_instance_id
            AND    msi.inventory_item_id    = mr.inventory_item_id
            AND    msi.plan_id              = -1
            AND    msi.bom_item_type        = 4
            AND    NVL(msi.release_time_fence_code, 5) NOT IN (5,6,7)
            /* for bug#2881012 following is not for reschedules. Hence
 	    reschedules skip these filters with mr.order_type <> PLANNED_ORDER*/
 	    AND
 		   (   mr.order_type  not in (PLANNED_ORDER,PLANNED_NEW_BUY_ORDER)
 		    OR (
 		            (     msi.build_in_wip_flag        = 1
                              AND   msi.repetitive_type = 1  /* 1:NO, 2:YES */
                              AND   decode(mr.sr_instance_id,mr.source_sr_instance_id,
                                        DECODE(mr.source_organization_id, mr.organization_id, 1,2)
                                        ,2)            = 1
                              )
                         OR   (    msi.purchasing_enabled_flag  = 1
                              AND  decode(mr.sr_instance_id,mr.source_sr_instance_id,
                                       DECODE(mr.source_organization_id, mr.organization_id, 1, 2)
                                       ,2)             = 2
                              )
                         )
 		   )
            AND    rsi.organization_id      = mr.organization_id
            AND    rsi.plan_id              = mr.plan_id
            AND    rsi.sr_instance_id       = mr.sr_instance_id
            AND    rsi.inventory_item_id    = mr.inventory_item_id
            AND   ( NVL(rsi.in_source_plan, 2) <> 1
                    OR
                   mr.transaction_id in (
                   select a.transaction_id from msc_supplies a, msc_supplies b,MSC_DESIGNATORS d, msc_system_items e
                   where a.schedule_designator_id is not null
                   and a.schedule_designator_id = b.schedule_designator_id
                   and a.organization_id = mr.organization_id
                   and a.organization_id = b.organization_id
                   and a.transaction_id= b.transaction_id
                   and a.sr_instance_id =b.sr_instance_id
                   and b.plan_id=-1
                   and a.inventory_item_id =e.inventory_item_id
                   and a.plan_id = e.plan_id
                   and a.sr_instance_id = e.sr_instance_id
                   and a.organization_id = e.organization_id
                   and NVL(e.in_source_plan, 2) =1
                   and a.plan_id=mr.plan_id
                   and b.SCHEDULE_ORIGINATION_TYPE =1
                   and a.schedule_designator_id = d.DESIGNATOR_ID
                   and d.designator not in (SELECT DISTINCT compile_designator
                                            FROM MSC_PLANS
                                            where sr_instance_id=a.sr_instance_id  )

                   ))
            AND    decode(mps.curr_plan_type,
                          SRP_PLAN,SYS_YES,
                          DRP_PLAN, SYS_YES,
                          MRP_PLAN, decode(lv_plan_release_profile,
                                           SYS_YES,         SYS_YES,
                                           decode(rsi.mrp_planning_code,
                                                  MRP_PLANNED_ITEM,     SYS_YES,
                                                  MPPMRP_PLANNED_ITEM,  SYS_YES,
                                                  SYS_NO
                                                  )
                                           ),
                          MPS_PLAN, decode(lv_plan_release_profile,
                                           SYS_YES,         decode(rsi.mrp_planning_code,
                                                                   MRP_PLANNED_ITEM,      SYS_NO,
                                                                   SYS_YES
                                                                   ),
                                           decode(rsi.mrp_planning_code,
                                                  MPS_PLANNED_ITEM,   SYS_YES,
                                                  MPPMPS_PLANNED_ITEM,SYS_YES,
                                                  SYS_NO
                                                  )
                                            ),
                         MPP_PLAN, decode(rsi.mrp_planning_code,
                                          MPS_PLANNED_ITEM, SYS_NO,
                                          MRP_PLANNED_ITEM, SYS_NO,
                                          SYS_YES
                                         ),
                         SYS_NO
                         ) = SYS_YES
            AND    mpl.organization_id (+) = msi.organization_id
            AND    mpl.planner_code (+) = NVL(msi.planner_code, MAGIC_STRING)
            AND    mpl.sr_instance_id(+)  = msi.sr_instance_id
            AND    mparam.sr_tp_id   = mr.organization_id
            AND    mparam.sr_instance_id= mr.sr_instance_id
            AND    mparam.partner_type= 3
            AND    cal1.sr_instance_id= mr.sr_instance_id
            AND    cal1.calendar_code       = mparam.calendar_code
            AND    cal1.exception_set_id    = mparam.calendar_exception_set_id
            AND    cal1.calendar_date      = TRUNC(var_start_date)
            AND    cal2.sr_instance_id     = mr.sr_instance_id
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
            -- bug fix for 2261963 to filter planned orders that have already been released --
           AND    NVL(mr.implemented_quantity, 0) + NVL(mr.quantity_in_process, 0)
                                 < mr.new_order_quantity
           AND	  mt.sr_instance_id(+) = mr.source_sr_instance_id
           AND    mt.sr_tp_id(+) = mr.source_organization_id
           AND    mt.partner_type(+) = 3
           AND    (mr.releasable = MSC_Rel_Plan_PUB.RELEASABLE or mr.releasable is null )
           AND    mr.batch_id is NULL
           -- shikyu changes
           AND    not exists (select 1 from msc_system_items msi1 , msc_trading_partners mtp
                      where msi1.inventory_item_id = mr.inventory_item_id
                      and   msi1.organization_id = mr.organization_id
                      and   msi1.plan_id = mr.plan_id
                      AND   msi1.sr_instance_id = mr.sr_instance_id
                      and   nvl(msi1.release_time_fence_code,-1) = 7
                      and   mtp.sr_tp_id = msi1.organization_id
                      and   mtp.sr_instance_id = msi1.sr_instance_id
                      and   mtp.partner_type=3
                      and   (mtp.modeled_supplier_id is not null OR mtp.modeled_supplier_site_id is not null))
           ORDER BY 2;

          cursor ROs_to_release is
          Select
	       	ms.Transaction_id,
	       	ms.order_type,
	       	ms.sr_instance_id ,
	       	ms.plan_id
		  		from
	       	msc_supplies ms,
		      msc_system_items msi,
		      msc_trading_partners mtp,
		      msc_calendar_dates cal1,
		      msc_calendar_dates cal2
	       	where
	       	 ms.plan_id =arg_plan_id
		      and ms.order_type in (PLANNED_IRO,PLANNED_ERO)
	      	and  ms.inventory_item_id = msi.inventory_item_id
	      	and ms.sr_instance_id =msi.sr_instance_id
	      	and  msi.plan_id              = arg_plan_id
          and  msi.bom_item_type        = 4
          and  msi.release_time_fence_code NOT IN (5,6,7)
          and ms.organization_id =msi.organization_id
		      and  mtp.sr_tp_id   = ms.organization_id
          and  mtp.sr_instance_id= ms.sr_instance_id
          and  mtp.partner_type= 3
          and  cal1.sr_instance_id = ms.sr_instance_id
          and  cal1.calendar_code       = mtp.calendar_code
          and  cal1.exception_set_id    = mtp.calendar_exception_set_id
          and cal1.calendar_date      = TRUNC(var_start_date)
          and cal2.sr_instance_id     = ms.sr_instance_id
          and cal2.calendar_code       = cal1.calendar_code
          and cal2.exception_set_id    = cal1.exception_set_id
          and cal2.seq_num             = cal1.next_seq_num +
          NVL(DECODE(msi.release_time_fence_code,
                     1, msi.cumulative_total_lead_time,
                     2, msi.cum_manufacturing_lead_time,
                     3, msi.full_lead_time,
                     4, msi.release_time_fence_days,
                     0),
              0)
          and  nvl(ms.new_order_placement_date, ms.new_schedule_date) BETWEEN TRUNC(var_start_date)
                    and TRUNC(cal2.calendar_date)
          and  (ms.releasable =0 or ms.releasable is null)
		     and ms.batch_id is null;

        cursor transfer_orders_to_release is
          Select
	       	ms.Transaction_id,
	       	ms.order_type,
	       	ms.sr_instance_id ,
	       	ms.plan_id
		  		from
	       	msc_supplies ms,
		      msc_system_items msi,
		      msc_trading_partners mtp,
		      msc_calendar_dates cal1,
		      msc_calendar_dates cal2
	       	where
	       	 ms.plan_id =arg_plan_id
		      and ms.order_type in (PLANNED_TRANSFER)
	      	and  ms.inventory_item_id = msi.inventory_item_id
	      	and ms.sr_instance_id =msi.sr_instance_id
	      	and  msi.plan_id              = arg_plan_id
          and  msi.bom_item_type        = 4
          and  msi.release_time_fence_code NOT IN (5,6,7)
          and ms.organization_id =msi.organization_id
		      and  mtp.sr_tp_id   = ms.organization_id
          and  mtp.sr_instance_id= ms.sr_instance_id
          and  mtp.partner_type= 3
          and  cal1.sr_instance_id = ms.sr_instance_id
          and  cal1.calendar_code       = mtp.calendar_code
          and  cal1.exception_set_id    = mtp.calendar_exception_set_id
          and cal1.calendar_date      = TRUNC(var_start_date)
          and cal2.sr_instance_id     = ms.sr_instance_id
          and cal2.calendar_code       = cal1.calendar_code
          and cal2.exception_set_id    = cal1.exception_set_id
          and cal2.seq_num             = cal1.next_seq_num +
          NVL(DECODE(msi.release_time_fence_code,
                     1, msi.cumulative_total_lead_time,
                     2, msi.cum_manufacturing_lead_time,
                     3, msi.full_lead_time,
                     4, msi.release_time_fence_days,
                     0),
              0)
          and  nvl(ms.new_order_placement_date, ms.new_schedule_date) BETWEEN TRUNC(var_start_date)
                    and TRUNC(cal2.calendar_date)
          and  (ms.releasable =0 or ms.releasable is null)
		     and ms.batch_id is null
         and
          not exists (select 1 from  msc_full_pegging  mfp,
					                             msc_demands md,
					                            msc_supplies ms1
			                 	where mfp.sr_instance_id = ms.sr_instance_id  and
				                      mfp.plan_id = ms.plan_id  and
				                      mfp.transaction_id =ms.transaction_id  and
				                      mfp.demand_id =md.demand_id and
				                      mfp.sr_instance_id = md.sr_instance_id  and
				                      mfp.plan_id = md.plan_id  and
				                      md.origination_type =78	and
				                      md.disposition_id = ms1.transaction_id and
				                      md.sr_instance_id  =ms1.sr_instance_id and
				                      md.plan_id = ms1.plan_id  and
                              ms1.order_type =79 and
				                      rownum <2);

BEGIN
  retcode := 0;
  errbuf := NULL;

  select decode(FND_PROFILE.VALUE('MSC_DRP_RELEASE_FROM_MRP'),'Y',SYS_YES,SYS_NO)
  into lv_plan_release_profile
  from dual;

  var_debug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';

  SELECT ALLOW_RELEASE_FLAG,
         INSTANCE_CODE,
         APPS_VER,
         DECODE( M2A_DBLINK,
                        NULL, NULL_DBLINK,
                        '@'||M2A_DBLINK)
    INTO var_allow_release,
         var_instance_code,
         var_apps_ver,
         var_dblink
  FROM MSC_APPS_INSTANCES
  WHERE INSTANCE_ID= arg_instance_id;

  if ( var_apps_ver >= 3 ) then

    IF var_allow_release = 2 THEN

      var_sql_stmt:=
         'SELECT mar.A2M_DBLINK '
       ||'  FROM  MRP_AP_APPS_INSTANCES_ALL'||var_dblink||' mar'
       ||'  WHERE mar.ALLOW_RELEASE_FLAG =  1 ';

       EXECUTE IMMEDIATE var_sql_stmt  INTO v_dblink ;

      fnd_message.set_name('MSC', 'MSC_AUTO_RELEASE_WARN');
      fnd_message.set_token('A2M_DBLINK',v_dblink);
      fnd_message.set_token('SOURCE_INSTANCE',var_instance_code);
      var_buf:= fnd_message.get;
      fnd_file.put_line(FND_FILE.LOG, var_buf);


      retcode  := 1;
      errbuf := var_buf;
      RETURN;

    END IF;

   end if;

  -- ------------------------------------------------------------------------
  -- Validate the plan
  -- ------------------------------------------------------------------------
  BEGIN
    var_entity := 'Plan Validation';
    msc_valid_plan_pkg.msc_valid_plan(arg_plan_id, 'Y', 'Y', 'Y', 'N');

    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('MRP', 'UNSUCCESSFUL PLAN VALIDATION');
        var_buf:= fnd_message.get;
        fnd_file.put_line(FND_FILE.LOG, var_buf);

        retcode := 2;
        errbuf := var_buf;
        RETURN;
  END;

  -- ------------------------------------------------------------------------
  -- Setup
  -- ------------------------------------------------------------------------

  SELECT DECODE( M2A_DBLINK, NULL, ' ', '@'||M2A_DBLINK),
         APPS_VER
    INTO var_dblink,
         var_apps_ver
    FROM MSC_APPS_INSTANCES
   WHERE INSTANCE_ID= arg_instance_id;

  --Fix for the bug#2538765. This enables the auto-release to use the user level
  --profile value defined in the source instance.

  SELECT  FND_GLOBAL.USER_NAME,
          FND_GLOBAL.RESP_NAME,
          FND_GLOBAL.APPLICATION_NAME
   INTO   var_user_name,
          var_resp_name,
          var_application_name
   FROM   dual;

  var_sql_stmt:=
   'BEGIN'
   ||'  MRP_AP_REL_PLAN_PUB.INITIALIZE'||var_dblink
                                         ||'( :var_user_name,'
                                         ||'  :var_resp_name,'
                                         ||'  :var_application_name,'
                                         ||'  :v_wip_group_id,'
                                         ||'  :v_po_batch_number);'

   ||'END;';

   EXECUTE IMMEDIATE var_sql_stmt
             USING   var_user_name,
                     var_resp_name,
                     IN var_application_name,
                     OUT v_wip_group_id,
                     OUT v_po_batch_number;


   var_sql_stmt:=
   'SELECT FND_GLOBAL.USER_ID,'
   ||'       FND_PROFILE.VALUE'||var_dblink||'(''WIP_JOB_PREFIX''),'
   ||'       FND_PROFILE.VALUE'||var_dblink||'(''MRP_LOAD_REQ_GROUP_BY'')'
   ||'  FROM DUAL';

  EXECUTE IMMEDIATE var_sql_stmt INTO var_user_id,
                                      var_default_job_prefix,
                                      var_po_group_by;

  var_entity := 'Setup';

      SELECT mp.curr_plan_type,
             DECODE(UPPER(arg_use_start_date),
                'Y', mp.plan_start_date, 'N', sysdate, sysdate),
             sched.demand_class,
             mp.compile_designator
        INTO var_plan_type,
             var_start_date,
             var_demand_class,
             lv_plan_name
      FROM   msc_plans mp,
             msc_designators sched
      WHERE  sched.organization_id(+)= mp.organization_id
      AND    sched.designator(+)     = mp.compile_designator
      AND    sched.sr_instance_id(+) = mp.sr_instance_id
      AND    mp.plan_id              = arg_plan_id;

  IF var_debug THEN
    var_buf := '+++++++++++++++++';
   fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'User ID                : '||var_user_id;
   fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'Owning org             : '||arg_org_id;
   fnd_file.put_line(FND_FILE.LOG, var_buf);
    var_buf := 'Plan Name              : '||lv_plan_name;
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

   begin
       -- populating batch_id from destination side seq.
       Execute immediate 'select  mrp_workbench_query_s.nextval
                         FROM DUAL '
                    into MSC_Rel_Plan_PUB.g_batch_id;
   exception when others then
    fnd_file.put_line(FND_FILE.LOG, sqlerrm);
   end;

   fnd_file.put_line(FND_FILE.LOG, MSC_Rel_Plan_PUB.g_batch_id);
  -- ------------------------------------------------------------------------
  -- Get planned orders and reschedules that meet the auto-release criteria
  -- ------------------------------------------------------------------------
  var_entity := 'Planned Orders';

  OPEN planned_orders_and_reschedules;

  LOOP

    var_entity := 'Fetch Planned Orders';

    FETCH planned_orders_and_reschedules INTO var_transaction_id,
                                              var_sr_instance_id,
                                              var_plan_id,
                                              var_org_id,
                                              var_inventory_item_id,
                                              var_supplier_id,
                                              var_supplier_site_id,
                                              var_source_supplier_id,
                                              var_source_supplier_site_id,
                                              var_new_schedule_date,
                                              var_new_order_quantity,
                                              var_order_type,
 			                                        var_load_type,
                                              var_primary_uom_code,
                                              var_planner_employee_id,
                                              var_make_buy_code,
                                              var_sr_inventory_item_id,
                                              var_project_id;

    EXIT WHEN planned_orders_and_reschedules%NOTFOUND;


    UPDATE msc_supplies
    SET  batch_id                 = MSC_Rel_Plan_PUB.g_batch_id
    WHERE transaction_id = var_transaction_id
    AND sr_instance_id = var_sr_instance_id
    AND plan_id = var_plan_id  ;

    /*VMI Check -- fwd port 3181822 */

    IF (not (((var_order_type = 5) AND (var_make_buy_code = BUY and
    			(MSC_UTIL.get_vmi_flag(var_plan_id,
    			  var_sr_instance_id,
    			  var_org_id,
    			  var_inventory_item_id,
    			  var_source_supplier_id,
    			  var_source_supplier_site_id)= 1)))
    	OR (var_order_type in (1,2) AND (MSC_UTIL.get_vmi_flag(var_plan_id,
    			  var_sr_instance_id,
    			  var_org_id,
    			  var_inventory_item_id,
    			  var_supplier_id,
    			  var_supplier_site_id)= 1)))) THEN


    -- ----------------------------------------------------------------------
    -- Get organization dependent info
    -- ----------------------------------------------------------------------
    IF (var_org_id <> var_prev_org_id) THEN

      var_entity := 'PO Location';

      BEGIN
        SELECT DECODE(tps.sr_tp_site_id, -1, NULL,tps.sr_tp_site_id)
        INTO   var_location_id
        FROM   msc_trading_partner_sites tps
        WHERE  tps.sr_tp_id   = var_org_id
        AND    tps.sr_instance_id= arg_instance_id
        AND    tps.partner_type= 3;

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            var_location_id := NULL;
          WHEN OTHERS THEN
            var_buf := var_entity||': '||sqlerrm;
            fnd_file.put_line(FND_FILE.LOG, var_buf);

            ROLLBACK;

            CLOSE planned_orders_and_reschedules;

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
    IF (var_prev_inventory_item_id <> var_inventory_item_id) THEN

       var_sql_stmt:=
          'BEGIN'
       ||'  :var_wip_class_code := wip_common.default_acc_class'||var_dblink||'('
       ||'                         :var_org_id,'
       ||'                         :var_sr_inventory_item_id,'
       ||'                         1,'
       ||'                         :var_project_id,'
       ||'                         :err_msg_1,'
       ||'                         :err_class_1,'
       ||'                         :err_msg_2,'
       ||'                         :err_class_2);'
       ||' END;';

       EXECUTE IMMEDIATE var_sql_stmt
               USING OUT var_wip_class_code,
                     IN  var_org_id,
                     IN  var_sr_inventory_item_id,
                     IN  var_project_id,
                     OUT err_msg_1,
                     OUT err_class_1,
                     OUT err_msg_2,
                     OUT err_class_2;


      IF (var_wip_class_code is NULL) THEN
       BEGIN

        var_entity := 'WIP Discrete Class';

        var_sql_stmt:=
           'SELECT wp.default_discrete_class'
        ||' FROM   wip_parameters'||var_dblink||' wp'
        ||' WHERE  wp.organization_id = :var_org_id';

        EXECUTE IMMEDIATE var_sql_stmt
                INTO  var_wip_class_code
                USING var_org_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            var_wip_class_code := NULL;
          WHEN OTHERS THEN
            var_buf := var_entity||': '||sqlerrm;
            fnd_file.put_line(FND_FILE.LOG, var_buf);

            ROLLBACK;
            CLOSE planned_orders_and_reschedules;
            retcode := 2;
            errbuf := var_buf;
            RETURN;
       END;
      END IF;
    END IF; /* Item Id */

    IF (var_make_buy_code = MAKE OR var_order_type = WIP_DISCRETE_JOB) THEN

      -- --------------------------------------------------------------------
      -- Get WIP Jobs parameter
      -- --------------------------------------------------------------------
--      IF var_planner_employee_id IS NULL THEN

 --       var_impl_status_code := UNRELEASED_NO_CHARGES;
--	var_job_prefix       := var_default_job_prefix;

 --     ELSE

        BEGIN
          var_entity := 'WIP Job Status';
          open Plan_type_c(var_plan_id);
          fetch plan_type_c into l_plan_type;
          close plan_type_c;
          l_def_pref_id := msc_get_name.get_default_pref_id(var_user_id);
          var_impl_status_code:= msc_get_name.GET_preference('ORDERS_DEFAULT_JOB_STATUS', l_def_pref_id, l_plan_type);
          var_wip_class_code:= msc_get_name.GET_preference('JOB_CLASS_CODE', l_def_pref_id, l_plan_type);
          var_firm_jobs:= msc_get_name.GET_preference('ORDERS_FIRM_JOBS', l_def_pref_id, l_plan_type);
/*
          OPEN job_status;
          FETCH job_status INTO var_impl_status_code, var_wip_class_code,
                                var_firm_jobs;
*/


          var_job_prefix := var_default_job_prefix; /* Bug 2571601 */

          IF var_impl_status_code is null THEN
            var_impl_status_code := UNRELEASED_NO_CHARGES;
	    var_job_prefix       := var_default_job_prefix;
          END IF;

--          CLOSE job_status;
        END;

  --    END IF;

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
        var_buf := 'Order Type          : '||var_order_type;
       fnd_file.put_line(FND_FILE.LOG, var_buf);
      END IF;

      -- --------------------------------------------------------------------
      -- -- Update WIP Jobs planned orders and reschedules
      -- --------------------------------------------------------------------
      var_entity := 'WIP Planned Orders';
      IF(var_order_type=PLANNED_ORDER)
      /*discrete job reschedules don't require new name*/
      THEN
         var_sql_stmt:=
              'SELECT wip_job_number_s.nextval'||var_dblink||' FROM dual';

         EXECUTE IMMEDIATE var_sql_stmt
                      INTO var_wip_job_number;
      END IF;

      UPDATE msc_supplies
      SET    old_order_quantity         = new_order_quantity,
             quantity_in_process        = new_order_quantity,
             implement_date             = new_schedule_date,
	     implement_quantity         = new_order_quantity,
             implement_firm             = DECODE(var_firm_jobs, 'Y', 1, 2),

	     /*for discrete job reschedules existing name is populated  */
             implement_job_name         = decode(var_order_type,PLANNED_ORDER,var_job_prefix||to_char(var_wip_job_number)
                                          ,PLANNED_NEW_BUY_ORDER,var_job_prefix||to_char(var_wip_job_number),3,order_number),

	     /*implement status code must be set to cancel (7) in case of reschedules */
             implement_status_code      = DECODE(disposition_status_type, CANCEL,7, var_impl_status_code),
             load_type                  = var_load_type,

             /*this is 1 for reschedules */
	     reschedule_flag=decode(order_type,PLANNED_ORDER,reschedule_flag,PLANNED_NEW_BUY_ORDER,reschedule_flag,1),

	     /*for reschedules it is 1 */
	     implement_as               = decode(order_type,PLANNED_ORDER,WIP_DISCRETE_JOB,PLANNED_NEW_BUY_ORDER,WIP_DISCRETE_JOB,1),
	     implement_wip_class_code   = var_wip_class_code,
       implement_source_org_id    = NULL,
       implement_supplier_id      = NULL,
       implement_supplier_site_id = NULL,
       implement_project_id       = project_id,
       implement_task_id          = task_id,
       implement_unit_number      = unit_number,
       implement_demand_class     = var_demand_class,
       last_updated_by            = var_user_id
      WHERE  transaction_id = var_transaction_id
             AND sr_instance_id = var_sr_instance_id
             AND plan_id = var_plan_id;

    ELSIF (var_make_buy_code = BUY OR var_order_type IN (PURCHASE_ORDER,PO_REQUISITION)) THEN

	   -- IR/ISO enhancement.
	   -- For DRP/ASCP plan, we need to check if the ISO is present in
	   -- the same plan. If, so, we need to update the load_type to 64

	   IF (var_order_type = PO_REQUISITION) THEN
		  BEGIN
			 var_sales_order_line_id := NULL;
			 SELECT sales_order_line_id
			   INTO var_sales_order_line_id
			 FROM msc_demands
			 WHERE
			   plan_id = var_plan_id
			   AND sr_instance_id = var_sr_instance_id
			   AND disposition_id = var_transaction_id
			   and origination_type = 30
			   and rownum = 1;

		  EXCEPTION
			 WHEN NO_DATA_FOUND THEN
				var_sales_order_line_id := NULL;
		  END;

		  IF (var_sales_order_line_id IS NOT NULL) THEN
			 var_load_type := DRP_REQ_RESCHED;
		  END IF;

	   END IF;

      -- --------------------------------------------------------------------
      -- Verify PO Reqs parameters
      --
      -- If Planner is not an active employee, do not release
      -- --------------------------------------------------------------------
      var_entity := 'Employee';

      SELECT count(*)
        INTO var_count
        FROM msc_planners
       WHERE employee_id = var_planner_employee_id
         AND current_employee_flag= 1;

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
        var_buf := 'Order Type          : '||var_order_type;
       fnd_file.put_line(FND_FILE.LOG, var_buf);
      END IF;

      IF (var_count = 0) THEN

        -- PO Req is not released because Planner is not an active employee

        var_entity := 'Non-released PO Req';

        SELECT param.organization_code,
               msi.item_name,
               msi.planner_code
        INTO   var_org_code, var_item, var_planner_code
        FROM   msc_system_items msi,
               msc_trading_partners   param,
               msc_supplies     mr
        WHERE  mr.transaction_id = var_transaction_id
            AND mr.sr_instance_id = var_sr_instance_id
            AND mr.plan_id = var_plan_id
        AND    msi.organization_id     = mr.organization_id
        AND    msi.inventory_item_id   = mr.inventory_item_id
        AND    msi.sr_instance_id      = mr.sr_instance_id
        AND    msi.plan_id              = -1
        AND    param.sr_tp_id    = mr.organization_id
        AND    param.sr_instance_id     = mr.sr_instance_id
        AND    param.partner_type= 3;

        /* bug 4258346 - set retcode = 1 so that the program will complete in warning
                         if the planner is not an active employee */

        retcode := 1;

        var_buf := '................. ';
        fnd_file.put_line(FND_FILE.LOG, var_buf);

        fnd_message.set_name('MRP', 'MRP_UNRELEASED_ORDER1');
        fnd_file.put_line(FND_FILE.LOG, fnd_message.get);

        fnd_message.set_name('MRP', 'MRP_UNRELEASED_ORDER2');
        fnd_message.set_token('PLANNER_VALUE', var_planner_code);
        fnd_message.set_token('ORG_VALUE', var_org_code);
        fnd_message.set_token('ITEM_VALUE', var_item);
        fnd_message.set_token('DATE_VALUE', to_char(var_new_schedule_date));
        fnd_message.set_token('QTY_VALUE', to_char(var_new_order_quantity));
        fnd_file.put_line(FND_FILE.LOG, fnd_message.get);

      ELSE

        -- ------------------------------------------------------------------
        -- Update PO Reqs planned orders and reschedules
        -- ------------------------------------------------------------------
        var_entity := 'PO Planned Orders';

        UPDATE msc_supplies
        SET    old_order_quantity       = new_order_quantity,
               quantity_in_process      = new_order_quantity,
               implement_date           = new_schedule_date,

	       /*implement quantity is 0 in case of cancels */
               implement_quantity       = decode(disposition_status_type, 2,0,new_order_quantity),
               load_type                = var_load_type,

	       /*this is 1 for reschedules */
               reschedule_flag=decode(order_type,PLANNED_ORDER,reschedule_flag,PLANNED_NEW_BUY_ORDER,reschedule_flag,1),

               /*for reschedules it is 1 */
               implement_as             = decode(order_type,PLANNED_ORDER,PO_REQUISITION,PLANNED_NEW_BUY_ORDER,PO_REQUISITION,1),

               /*implement status code must be set to cancel (7) in case of reschedules */
               implement_status_code = DECODE(disposition_status_type, CANCEL,7, null),

               implement_firm           = firm_planned_type,
               implement_dock_date      = new_dock_date,
               implement_employee_id    = var_planner_employee_id,
               implement_uom_code       = var_primary_uom_code,
               implement_location_id    = var_location_id,
               implement_source_org_id  = source_organization_id,
               implement_supplier_id      = source_supplier_id,
               implement_supplier_site_id = source_supplier_site_id,
               implement_project_id     = project_id,
               implement_task_id        = task_id,
               implement_unit_number        = unit_number,
               implement_demand_class   = NULL,
               last_updated_by          = var_user_id
        WHERE  transaction_id = var_transaction_id
               AND sr_instance_id = var_sr_instance_id
               AND plan_id = var_plan_id;


      END IF;   /* Count */

    END IF;     /* Make Buy code */

    var_prev_org_id := var_org_id;
    var_prev_inventory_item_id := var_inventory_item_id;


    END IF; /*VMI Check -- fwd port 3181822 */

  END LOOP;

  CLOSE planned_orders_and_reschedules;

  COMMIT WORK;

  p_where_clause :=null ;

  If var_plan_type =8 then
    OPEN ROs_to_release;
    LOOP
      var_entity := 'Fetch repair orders ';


      FETCH ROs_to_release INTO var_transaction_id,var_order_type,var_sr_instance_id,var_plan_id ;
      EXIT WHEN ROs_to_release%NOTFOUND;
      p_where_clause := ' transaction_id = ' || var_transaction_id ;


      MSC_SELECT_ALL_FOR_RELEASE_PUB.Update_Implement_Attrib(p_where_clause ,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          p_total_rows ,
                                          p_succ_rows ,
                                          p_error_rows
                                          );


      UPDATE msc_supplies
      SET  batch_id                 = MSC_Rel_Plan_PUB.g_batch_id,
           load_type                =decode(var_order_type,PLANNED_ERO,ERO_LOAD,IRO_LOAD)
      WHERE transaction_id = var_transaction_id
      AND sr_instance_id = var_sr_instance_id
      AND plan_id = var_plan_id  ;

     END LOOP;
    CLOSE ROs_to_release;
  END IF ;

  commit;

  If var_plan_type in (5,8) then
    OPEN transfer_orders_to_release;
    LOOP
      var_entity := 'Fetch transfer  orders ';

      FETCH transfer_orders_to_release INTO var_transaction_id,var_order_type,var_sr_instance_id,
      var_plan_id ;
      EXIT WHEN transfer_orders_to_release%NOTFOUND;
       p_where_clause := ' transaction_id = ' || var_transaction_id ;

      MSC_SELECT_ALL_FOR_RELEASE_PUB.Update_Implement_Attrib(p_where_clause ,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          p_total_rows ,
                                          p_succ_rows ,
                                          p_error_rows
                                          );
      UPDATE msc_supplies
      SET  batch_id                 = MSC_Rel_Plan_PUB.g_batch_id,
           load_type                =TRANSFER_LOAD
      WHERE transaction_id = var_transaction_id
      AND sr_instance_id = var_sr_instance_id
      AND plan_id = var_plan_id  ;

     END LOOP;
    CLOSE transfer_orders_to_release;
  END IF ;
     commit ;
  -- ------------------------------------------------------------------------
  -- Release the planned orders and reschedules
  -- ------------------------------------------------------------------------
  var_entity := 'Release';

   /*purchase order reschedules require separate function call */
     msc_rel_wf.reschedule_purchase_orders
	             (arg_plan_id,arg_org_id,arg_instance_id,arg_org_id,
		      arg_instance_id,var_count_po,var_released_instance,
		      var_po_res_id,var_po_res_count,var_po_pwb_count);

    MSC_Rel_Plan_PUB.msc_release_plan_sc
		     (arg_plan_id, arg_org_id, arg_instance_id,
                      arg_org_id, arg_instance_id, lv_plan_name, var_user_id,
                      var_po_group_by, var_po_batch_number, var_wip_group_id,
                      var_loaded_jobs, var_loaded_reqs, var_loaded_scheds,
                      var_resched_jobs, var_resched_reqs, var_wip_req_id,
                      var_req_load_id, var_req_resched_id, var_released_instance_id, NULL,NULL,
                      var_loaded_lot_jobs, var_resched_lot_jobs,var_osfm_req_id,
                      var_resched_eam_jobs,var_eam_req_id,
                      var_loaded_int_reqs,var_resched_int_reqs,var_int_req_load_id,var_int_req_resched_id,
                      var_loaded_int_repair_orders,var_int_repair_orders_id,var_loaded_ext_repair_orders,
                      var_ext_repair_orders_id);

   UPDATE msc_plans
   SET release_reschedules=2
   WHERE plan_id=arg_plan_id;
   commit;

  var_buf := '+++++++++++++++++ ';
  fnd_file.put_line(FND_FILE.LOG, var_buf);

  var_released_instance_count:= var_released_instance_id.count;

  DECLARE
      i number;
      lv_instance_code  varchar2(3);

  BEGIN

  FOR i IN 1..var_released_instance_id.count LOOP

  select instance_code
    into lv_instance_code
    from msc_apps_instances
   where instance_id= var_released_instance_id(i);

  fnd_message.set_name('MSC', 'MSC_AR_LOADED_INSTANCE');
  fnd_message.set_token('INSTANCE', lv_instance_code);
  fnd_file.put_line(FND_FILE.LOG, fnd_message.get);

  fnd_message.set_name('MRP', 'LOADED_WIP');
  fnd_message.set_token('VALUE', to_char(var_loaded_jobs(i)));
  fnd_file.put_line(FND_FILE.LOG, fnd_message.get);

  fnd_message.set_name('MRP', 'LOADED_WIP');
  fnd_message.set_token('VALUE', to_char(var_loaded_lot_jobs(i))||' lot Jobs');
  fnd_file.put_line(FND_FILE.LOG, fnd_message.get);

  fnd_message.set_name('MRP', 'LOADED_PO');
  fnd_message.set_token('VALUE', to_char(var_loaded_reqs(i)));
  fnd_file.put_line(FND_FILE.LOG, fnd_message.get);

  fnd_message.set_name('MRP', 'LOAD_WIP_REQUEST_ID');
  fnd_message.set_token('VALUE', to_char(var_wip_req_id(i)));
  fnd_file.put_line(FND_FILE.LOG, fnd_message.get);

  fnd_message.set_name('MRP', 'LOAD_WIP_REQUEST_ID');
  fnd_message.set_token('VALUE', to_char(var_osfm_req_id(i))||' OSFM Request Id');
  fnd_file.put_line(FND_FILE.LOG, fnd_message.get);

  fnd_message.set_name('MRP', 'LOAD_PO_REQUEST_ID');
  fnd_message.set_token('VALUE', to_char(var_req_load_id(i)));
  fnd_file.put_line(FND_FILE.LOG, fnd_message.get);

  fnd_message.set_name('MSC', 'LOADED_RESCHEDULED_JOB');
  fnd_message.set_token('VALUE', to_char(var_resched_jobs(i)));
  fnd_file.put_line(FND_FILE.LOG, fnd_message.get);

  fnd_message.set_name('MSC', 'LOADED_RESCHEDULED_REQS');
  fnd_message.set_token('VALUE', to_char(var_resched_reqs(i)));
  fnd_file.put_line(FND_FILE.LOG, fnd_message.get);

  fnd_file.put_line(FND_FILE.LOG, 'Loaded internal repair order :'|| var_loaded_int_repair_orders(i));
  fnd_file.put_line(FND_FILE.LOG, 'Loaded external repair order :'|| var_loaded_ext_repair_orders(i));

                   /* Bug 2595278 - added Null condition */
  IF ((var_loaded_jobs(i) > 0) AND ((var_wip_req_id(i) = 0) OR (var_wip_req_id(i) IS NULL))) THEN
  fnd_file.new_line(FND_FILE.LOG, 1);
    fnd_message.set_name('MRP', 'CANNOT SUBMIT REQUEST-JOBS');
    var_buf := fnd_message.get;
   fnd_file.put_line(FND_FILE.LOG, var_buf);

    retcode := 2;
    errbuf := var_buf;
  END IF;


  IF ((var_loaded_lot_jobs(i) > 0) AND (var_osfm_req_id(i) = 0)) THEN
  fnd_file.new_line(FND_FILE.LOG, 1);
    fnd_message.set_name('MRP', 'CANNOT SUBMIT LOT-JOBS INTERFACE');
    var_buf := fnd_message.get;
   fnd_file.put_line(FND_FILE.LOG, var_buf);

    retcode := 2;
    errbuf := var_buf;
  END IF;

  IF ((var_loaded_reqs(i) > 0) AND (var_req_load_id(i) = 0)) THEN
   fnd_file.new_line(FND_FILE.LOG, 1);
    fnd_message.set_name('MRP', 'CANNOT SUBMIT REQUEST-REQS');
    var_buf := fnd_message.get;
   fnd_file.put_line(FND_FILE.LOG, var_buf);

    retcode := 2;
    errbuf := var_buf;
  END IF;

  IF ((var_loaded_int_repair_orders(i) > 0) AND (var_int_repair_orders_id(i) = 0)) THEN
   var_buf:= 'cannot submit the internal repair order request';
   fnd_file.put_line(FND_FILE.LOG, var_buf);

    retcode := 2;
    errbuf := var_buf;
  END IF;

  IF ((var_loaded_ext_repair_orders(i) > 0) AND (var_ext_repair_orders_id(i) = 0)) THEN
   var_buf:= 'cannot submit the external repair order request';
   fnd_file.put_line(FND_FILE.LOG, var_buf);

    retcode := 2;
    errbuf := var_buf;
  END IF;

  END LOOP;

  var_buf := '++++++++++';
  fnd_file.put_line(FND_FILE.LOG, var_buf);
  var_buf := 'PO reschedules';
  fnd_file.put_line(FND_FILE.LOG, var_buf);

  FOR i IN 1..var_count_po LOOP
  select instance_code
    into lv_instance_code
    from msc_apps_instances
  where instance_id= var_released_instance(i);

  fnd_message.set_name('MSC', 'MSC_AR_LOADED_INSTANCE');
  fnd_message.set_token('INSTANCE', lv_instance_code);
  fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
  fnd_message.set_name('MSC', 'LOADED_RESCHEDULED_PO');
  fnd_message.set_token('VALUE', to_char(var_po_res_count(i)));
  fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
  END LOOP;

  END;
  RETURN;

EXCEPTION
  WHEN OTHERS THEN

    IF planned_orders_and_reschedules%ISOPEN THEN CLOSE planned_orders_and_reschedules; END IF;

    var_buf := var_entity||': '||sqlerrm;
    fnd_file.put_line(FND_FILE.LOG, var_buf);

    ROLLBACK;
    retcode := 2;
    errbuf := var_buf;
    RETURN;
END msc_auto_release;

PROCEDURE msc_web_service_release (
                pPlan_id 			            Number,
            	Use_Plan_start_date    	        Varchar2,
            	RETCODE		        OUT  NOCOPY Number,
            	ERRMSG		        OUT  NOCOPY Varchar2,
            	REQ_ID		        OUT  NOCOPY ReqTblTyp
                ) IS
v_instance_id     NUMBER;
v_owning_org_id   NUMBER;

i                 number;
j                 number := 1;
lv_instance_code  msc_apps_instances.INSTANCE_CODE%TYPE;

BEGIN
    --get instance_id and org_for the given plan.
    BEGIN
      SELECT mp.sr_instance_id,
             mp.organization_id
        INTO v_instance_id,
             v_owning_org_id
      FROM   msc_plans mp
      WHERE  mp.plan_id = pPlan_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ERRMSG  := 'Not a Valid plan ID';
            RETCODE := MSC_UTIL.G_ERROR;
            RETURN;
        WHEN OTHERS THEN
            ERRMSG  := SQLERRM;
            RETCODE := MSC_UTIL.G_ERROR;
            RETURN;
    END;

    BEGIN
        msc_auto_release(ERRMSG,
                         RETCODE,
                         pPlan_id,
                         v_owning_org_id,
                         v_instance_id,
                         Use_Plan_start_date);


        FOR i IN 1..var_released_instance_id.count LOOP

              select instance_code
                into lv_instance_code
                from msc_apps_instances
               where instance_id= var_released_instance_id(i);

              REQ_ID(j).instanceCode := lv_instance_code;
              REQ_ID(j).ReqID         := var_wip_req_id(i);
              REQ_ID(j).ReqType       := 'Loaded WIP Jobs :' || var_loaded_jobs(i) ;
              j := j + 1;

              REQ_ID(j).instanceCode := lv_instance_code;
              REQ_ID(j).ReqID         := var_osfm_req_id(i);
              REQ_ID(j).ReqType       := 'Loaded Lot Jobs :' || var_loaded_lot_jobs(i) ;
              REQ_ID(j).ReqType       := REQ_ID(j).ReqType  || '   Resched Lot Jobs :' || var_resched_lot_jobs(i) ;
              j := j + 1;


              REQ_ID(j).instanceCode := lv_instance_code;
              REQ_ID(j).ReqID         := var_req_load_id(i);
              REQ_ID(j).ReqType       := 'Loaded PR       :' || var_loaded_reqs(i);
              j := j + 1;

              REQ_ID(j).instanceCode := lv_instance_code;
              REQ_ID(j).ReqID         := var_resched_jobs(i);
              REQ_ID(j).ReqType       := 'Resched PR      :' || var_resched_reqs(i);
              j := j + 1;

              REQ_ID(j).instanceCode := lv_instance_code;
              REQ_ID(j).ReqID         := var_eam_req_id(i);
              REQ_ID(j).ReqType       := 'Resched EAM jobs:' || var_resched_eam_jobs(i);
              j := j + 1;

              REQ_ID(j).instanceCode := lv_instance_code;
              REQ_ID(j).ReqID         := var_int_req_load_id(i);
              REQ_ID(j).ReqType       := 'Loaded Int Reqs:' || var_loaded_int_reqs(i);
              j := j + 1;

              REQ_ID(j).instanceCode := lv_instance_code;
              REQ_ID(j).ReqID         := var_int_req_resched_id(i);
              REQ_ID(j).ReqType       := 'Resched Int Reqs:' || var_resched_int_reqs(i);
              j := j + 1;

              REQ_ID(j).instanceCode := lv_instance_code;
              REQ_ID(j).ReqID         := var_int_repair_orders_id(i);
              REQ_ID(j).ReqType       := 'IROs            :' || var_loaded_int_repair_orders(i);
              j := j + 1;

              REQ_ID(j).instanceCode := lv_instance_code;
              REQ_ID(j).ReqID         := var_ext_repair_orders_id(i);
              REQ_ID(j).ReqType       := 'EROs            :' || var_loaded_ext_repair_orders(i);
              j := j + 1;


                               /* Bug 2595278 - added Null condition */
              IF ((var_loaded_jobs(i) > 0) AND ((var_wip_req_id(i) = 0) OR (var_wip_req_id(i) IS NULL))) THEN
                fnd_file.new_line(FND_FILE.LOG, 1);
                fnd_message.set_name('MRP', 'CANNOT SUBMIT REQUEST-JOBS');
                ERRMSG := ERRMSG || '    ' || fnd_message.get;
                RETCODE := MSC_UTIL.G_ERROR;
              END IF;


              IF ((var_loaded_lot_jobs(i) > 0) AND (var_osfm_req_id(i) = 0)) THEN
                fnd_file.new_line(FND_FILE.LOG, 1);
                fnd_message.set_name('MRP', 'CANNOT SUBMIT LOT-JOBS INTERFACE');
                ERRMSG := ERRMSG || '     ' || fnd_message.get;
                RETCODE := MSC_UTIL.G_ERROR;
              END IF;

              IF ((var_loaded_reqs(i) > 0) AND (var_req_load_id(i) = 0)) THEN
                fnd_file.new_line(FND_FILE.LOG, 1);
                fnd_message.set_name('MRP', 'CANNOT SUBMIT REQUEST-REQS');
                ERRMSG := ERRMSG || '     ' ||fnd_message.get;
                RETCODE := MSC_UTIL.G_ERROR;
              END IF;

                IF ((var_loaded_int_repair_orders(i) > 0) AND (var_int_repair_orders_id(i) = 0)) THEN
                   ERRMSG := ERRMSG || '     ' ||' cannot submit the internal repair order request';
                   RETCODE := MSC_UTIL.G_ERROR;
                  END IF;

                  IF ((var_loaded_ext_repair_orders(i) > 0) AND (var_ext_repair_orders_id(i) = 0)) THEN
                   ERRMSG := ERRMSG || '     ' || 'cannot submit the external repair order request';
                   RETCODE := MSC_UTIL.G_ERROR;
                  END IF;
        END LOOP;


        FOR i IN 1..var_count_po LOOP
              select instance_code
                into lv_instance_code
                from msc_apps_instances
              where instance_id= var_released_instance(i);

              REQ_ID(j).instanceCode := lv_instance_code;
              REQ_ID(j).ReqID         := '';
              REQ_ID(j).ReqType       := 'Resched PO      :' || var_po_res_count(i);
              j := j + 1;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            ERRMSG  := SQLERRM;
            RETCODE := MSC_UTIL.G_ERROR;
    END;

    RETCODE := MSC_UTIL.G_SUCCESS;
EXCEPTION
    WHEN OTHERS THEN
            ERRMSG  := SQLERRM;
            RETCODE := MSC_UTIL.G_ERROR;
END msc_web_service_release;

END msc_release_pk;

/
