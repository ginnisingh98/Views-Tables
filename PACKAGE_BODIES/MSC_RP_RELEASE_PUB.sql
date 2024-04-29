--------------------------------------------------------
--  DDL for Package Body MSC_RP_RELEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_RP_RELEASE_PUB" AS
-- $Header: MSCRPRLB.pls 120.4.12010000.6 2010/03/17 21:22:41 hulu noship $
PROCEDURE do_release(pid IN Number,psid in number,
                     p_user_id in number,
                     p_resp_id in number,
                     p_appl_id in number) IS

loaded_jobs		MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
loaded_reqs		MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
loaded_scheds		MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
resched_jobs		MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
resched_reqs		MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
wip_group_id    	NUMBER;
wip_req_id      	MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
po_req_load_id      	MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
po_req_resched_id 	MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
release_instance	MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
loaded_lot_jobs		MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
resched_lot_jobs	MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
osfm_req_id		MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
eam_resched_id		MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
eam_req_id		MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
loaded_int_reqs		MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
resched_int_reqs	MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
int_req_load_id      	MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
int_req_resched_id 	MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
loaded_int_repair_orders	MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
int_repair_orders_id		MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
loaded_ext_repair_orders	MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
ext_repair_orders_id		MSC_Rel_Plan_PUB.NumTblTyp := MSC_Rel_Plan_PUB.NumTblTyp(0);
p_po_res_id		msc_rel_wf.numTblTyp:=msc_rel_wf.numTblTyp(0);
p_released_inst		msc_rel_wf.numTblTyp:=msc_rel_wf.numTblTyp(0);
p_po_res_count		msc_rel_wf.numTblTyp:=msc_rel_wf.numTblTyp(0);
p_po_pwb_count		msc_rel_wf.numTblTyp:=msc_rel_wf.numTblTyp(0);
p_so_rel_id		msc_rel_wf.numTblTyp:=msc_rel_wf.numTblTyp(0);
p_so_released_inst	msc_rel_wf.numTblTyp:=msc_rel_wf.numTblTyp(0);
p_so_rel_count		msc_rel_wf.numTblTyp:=msc_rel_wf.numTblTyp(0);
p_so_pwb_count		msc_rel_wf.numTblTyp:=msc_rel_wf.numTblTyp(0);


user_id			NUMBER :=nvl(p_user_id,1);
req_load_group_by 	NUMBER;
req_batch_number   	NUMBER;


i			NUMBER;
v_res_po_count number :=0;
v_rel_so_count number :=0;
v_other_count number :=0;
collection_status NUMBER := 0;


request_id number;


p_doc_num NUMBER := 0;
p_doc_line_num NUMBER := 0;
p_doc_shipment_num NUMBER := 0;
x_return_status varchar2(1) := 'E';
tmpindex NUMBER := 0;
p_ret_msg varchar2(200) := null;
p_release_by_user varchar2(3):=null ;
-- nvl(FND_PROFILE.value('MSC_RELEASED_BY_USER_ONLY'),'N');


p_plan_id number := pid;
p_plan_org_id number;
p_plan_inst_id number;

p_org_id number ;
p_inst_id number;
p_compile_designator varchar2(20);

l_sr_instance_id number;

cursor cur_plan_info is
select organization_id,sr_instance_id,compile_designator
from msc_plans
where plan_id=p_plan_id;

CURSOR cur_supply_order IS
      SELECT sum(decode(ms.load_type,20,0,1)),
             sum(decode(ms.load_type,20,1,0)),
             sum(decode(mai.lrtype, 'I', 0,
                  decode(nvl(mai.st_status,0),3,1,0)))
      FROM msc_supplies ms,
           msc_apps_instances mai
      where ms.plan_id = pid
       and  ms.release_errors is null
       and  ms.load_type is not null
       and  ms.sr_instance_id = mai.instance_id
       and  ms.last_updated_by = decode(p_release_by_user,'Y', user_id,
                ms.last_updated_by)
       and ms.status = 0
       and ms.applied =2;

CURSOR cur_demand_order IS
   --   SELECT 1
   --   FROM msc_demands md
   --   where md.plan_id = p_plan_id
   --    and  md.release_errors is null
   --    and  md.load_type =30
   --    and  MD.ORIGINATION_TYPE = 30
   --    and  md.last_updated_by = decode(p_release_by_user,'Y', user_id,
   --             md.last_updated_by)
   --    and md.status = 0
   --    and md.applied =2;

select 1 from dual
where exists  ( SELECT  /*+ first_rows */ 1
   FROM msc_demands md
      where md.plan_id = p_plan_id
       and  md.release_errors is null
       and  md.load_type =30
       and  MD.ORIGINATION_TYPE = 30
       and  md.last_updated_by = decode(p_release_by_user,'Y', user_id,
                md.last_updated_by)
       and md.status = 0
       and md.applied =2
     );

  CURSOR cur_instance IS
	  SELECT unique sr_instance_id
	  from MSC_PLAN_ORGANIZATIONS
	  where plan_id = p_plan_id;


BEGIN
 -- before we have SSO enable, we temp hardcode the user id
 fnd_global.apps_initialize(p_user_id, p_resp_id, p_appl_id);


  -- msc_rel_wf.init_db('OPERATIONS');
-- get plan info
-----------------------------------------------------
 open cur_plan_info;
 fetch cur_plan_info into p_plan_org_id,p_plan_inst_id ,p_compile_designator;
 if cur_plan_info%notfound then
    return;

  end if;
 close cur_plan_info;



  p_release_by_user :=
        nvl(GET_RP_PLAN_PROFILE_VALUE(p_plan_id,'MSC_RELEASED_BY_USER_ONLY'),'N');

  req_load_group_by := to_number(GET_RP_PLAN_PROFILE_VALUE(p_plan_id,'MRP_LOAD_REQ_GROUP_BY'));
  if (req_load_group_by is null) then
	msc_rel_wf.get_profile_value(p_profile_name   => 'MRP_LOAD_REQ_GROUP_BY',
                                  p_instance_id    => p_inst_id,
                                  p_profile_value  => req_load_group_by);

  end if;
   -- print_debug('done getting profile MRP_LOAD_REQ_GROUP_BY='|| req_load_group_by );
  req_load_group_by :=nvl(req_load_group_by,1);
    OPEN cur_supply_order;
    FETCH cur_supply_order INTO
           v_other_count,
           v_res_po_count,
           collection_status;
    CLOSE cur_supply_order;

    OPEN cur_demand_order;
    FETCH cur_demand_order INTO v_rel_so_count;
    CLOSE cur_demand_order;

     v_rel_so_count := nvl(v_rel_so_count,0);   --- rescheduled sales order
     v_other_count := nvl(v_other_count,0);     -- planned order, work order, schedule, po requsition
     v_res_po_count := nvl(v_res_po_count,0);   -- rescheduled/cancel po

  --  print_debug('so=' || v_rel_so_count || ' other=' || v_other_count || ' po=' || v_res_po_count);

    --- we should not release supplies while collection is running
    --- we can check this before we call web service
    --- move this part of code out



-- release planned order, work order,purchasing requision,schedule
-- MSC_Rel_Plan_PUB.msc_release_plan_sc needs to be updated to report
-- cp request id and progress

-- insert into msc_rp_release_status table for pcnt
   insert into msc_rp_release_status (
 		    release_session_id,
		    completion_pcnt,
		    status,
		    last_update_date,
		    last_updated_by,
		    creation_date,
		    created_by,
		    last_update_login)
	    values(
		    psid,
		    0,
                    1, --- releasing
		    sysdate,
		    user_id,
		    sysdate,
		    user_id,
		    1);



/*  defined in MSC_RP_RELEASE_PHASE
		    1, -- load wip work orders
		    2, -- reschedule wip work orders
		    3, -- load lots job
		    4, -- reschedule lots job
		    5, -- load req
		    6, -- reschedule req
		    7, -- load internal req
		    8, -- reschedule  internal req
		    9, -- load schedule
		    10 -- schedule purchasing order
		    11 -- schedule sales order
*/


  OPEN cur_instance;
  LOOP
	  FETCH cur_instance into l_sr_instance_id  ;

	  EXIT WHEN cur_instance%NOTFOUND;
	  FOR i in 1..11 LOOP
	     insert into msc_rp_release_results(
			    release_session_id,
			    instance_id,
			    release_code,
			    release_order_count,
			    release_request_id,
			    last_update_date,
			    last_updated_by,
			    creation_date,
			    created_by,
			    last_update_login)
		    values(
			    psid,
			    l_sr_instance_id ,
			    i,
			    null ,
			    null,
			    sysdate,
			    user_id,
			    sysdate,
			    user_id,
			    1);
	END LOOP; -- end for loop
 END LOOP; -- end instance loop;
  commit;
   -- print_debug('done insert initial status into tables');

   IF v_other_count >0 then
    print_debug('releasing planed orders, etc ...');
    MSC_Rel_Plan_PUB.msc_release_plan_sc
                 (pid,
		  p_plan_org_id,   --- p_org_id,use to release one org only, if it is same as p_plan_org_id, then release all org
                  p_plan_inst_id,  -- release by instance. if it is same as plan instance, then release all
		  p_plan_org_id,
		  p_plan_inst_id,
                  p_compile_designator,
                  user_id,
                  req_load_group_by,
                  req_batch_number,
                  wip_group_id,
                  loaded_jobs,     --- load wip job
		  loaded_reqs,     -- loaded purchasing req count
 		  loaded_scheds,   -- rescheduled purchasing req count
		  resched_jobs,    -- reschedule job
		  resched_reqs,    -- reschedule purchasing req
                  wip_req_id,      -- wip request id
                  po_req_load_id,    -- new purchasing req
		  po_req_resched_id, -- reschedule purchasing req
                  release_instance,  -- instance id
                  null,
                  null,
                  loaded_lot_jobs,  --loaded lots job
                  resched_lot_jobs, -- reschedule lots job
                  osfm_req_id,      -- lots cp id
                  eam_resched_id,
                  eam_req_id,
                  loaded_int_reqs,   --loaded internal req count
                  resched_int_reqs,  --rescheduled internal req count
                  int_req_load_id,    --- new internal requisition
                  int_req_resched_id, --- reschedule interna requision
                  loaded_int_repair_orders, --loaded int repair
                  int_repair_orders_id,    -- int repair cp id
                  loaded_ext_repair_orders,
                  ext_repair_orders_id);


-- 	print_debug('Done releasing  planed orders, etc for instance:' || p_plan_inst_id );
   end if;



--- insert result into table so that ws can report progress
------------------------------------------------------------
  --  print_debug('Updating status after releasing planned orders, etc ...'  );

   update  msc_rp_release_status set completion_pcnt=40
   where release_session_id=psid;


   if v_other_count > 0 then
    FOR i in 1..loaded_jobs.COUNT LOOP
	    update msc_rp_release_results
	    set	release_order_count=loaded_jobs(i),
		release_request_id =wip_req_id(i)
	    where  release_session_id=psid
	    and    release_code=1
	    and instance_id = release_instance(i);


	    update msc_rp_release_results
	    set	release_order_count=resched_jobs(i),
		release_request_id =wip_req_id(i)
	    where  release_session_id=psid
	    and    release_code=2
	    and instance_id = release_instance(i);


	    update msc_rp_release_results
	    set	release_order_count=loaded_lot_jobs(i),
		release_request_id =osfm_req_id(i)
	    where  release_session_id=psid
	    and    release_code=3
	    and instance_id = release_instance(i);

	    update msc_rp_release_results
	    set	release_order_count=resched_lot_jobs(i),
		release_request_id =osfm_req_id(i)
	    where  release_session_id=psid
	    and    release_code=4
	    and instance_id = release_instance(i);

            update msc_rp_release_results
	    set	release_order_count=loaded_reqs(i),
		release_request_id =po_req_load_id(i)
	    where  release_session_id=psid
	    and    release_code=5
	    and instance_id = release_instance(i);


            update msc_rp_release_results
	    set	release_order_count=resched_reqs(i),
		release_request_id =po_req_resched_id(i)
	    where  release_session_id=psid
	    and    release_code=6
	    and instance_id = release_instance(i);

            update msc_rp_release_results
	    set	release_order_count=loaded_int_reqs(i),
		release_request_id =int_req_load_id(i)
	    where  release_session_id=psid
	    and    release_code=7
	    and instance_id = release_instance(i);


            update msc_rp_release_results
	    set	release_order_count=resched_int_reqs(i),
		release_request_id =int_req_resched_id(i)
	    where  release_session_id=psid
	    and    release_code=8
	    and instance_id = release_instance(i);

            update msc_rp_release_results
	    set	release_order_count=loaded_scheds(i),
		release_request_id =wip_req_id(i)
	    where  release_session_id=psid
	    and    release_code=9
	    and instance_id = release_instance(i);


   end loop;
 end if;
 commit;
--- release purchasing order, which includes cancel and reschdule po
--- msc_rel_wf.reschedule_purchase_orders needs to be updated to report
--- request id and progress

   if v_res_po_count > 0 then

       print_debug('Releasing  purchasing orders ...');
	     msc_rel_wf.reschedule_purchase_orders(
             p_plan_id,
             p_plan_org_id, -- p_org_id release all org order,
             p_plan_inst_id, --p_inst_id release all instance order,
             p_plan_org_id,
             p_plan_inst_id,
             v_res_po_count,
             p_released_inst,
             p_po_res_id,
             p_po_res_count,
             p_po_pwb_count);

-- 	print_debug('Done releasing  purchasing orders ...');
   end if;



  --  print_debug('Updating release status after releasing  purchasing orders ...');
   update  msc_rp_release_status set completion_pcnt=60
   where release_session_id=psid;

   if v_res_po_count > 0 then
     FOR i in 1..v_res_po_count LOOP

	    update msc_rp_release_results
	    set	release_order_count=p_po_res_count(i),
		release_request_id =p_po_res_id(i)
	    where  release_session_id=psid
	    and    release_code=10
	    and instance_id = p_released_inst(i);


     end loop;
   end if;
  commit;

------release sales order
---------------------------------------------------------------------
   if v_rel_so_count > 0 then
    -- print_debug('Releasing  sales orders ...');
     msc_rel_wf.release_sales_orders(
             p_plan_id,
             p_plan_org_id,
             p_plan_inst_id,
             p_plan_org_id,
             p_plan_inst_id,
             p_so_released_inst, -- instance count
             p_so_rel_id,        -- request id
             p_so_rel_count,     -- release order count
             p_so_pwb_count);    -- total order which reqire release

     -- print_debug('Done release  sales orders ...');
   end if;


   -- print_debug('Updating release status after releasing  sales orders ...');

  if v_rel_so_count > 0 then
      FOR i in 1..p_so_rel_id.count -1 LOOP

	    update msc_rp_release_results
	    set	release_order_count=p_so_rel_count(i),
		release_request_id =p_so_rel_id(i)
	    where  release_session_id=psid
	    and    release_code=11
	    and instance_id = p_so_released_inst(i);

    END LOOP;
 end if;


   update  msc_rp_release_status set completion_pcnt=100,status=2
   where release_session_id=psid;

   commit;

   -- print_debug('All done ...');
   EXCEPTION
   WHEN OTHERS THEN
   update  msc_rp_release_status set completion_pcnt=100,status=4
   where release_session_id=psid;
   commit;

    fnd_message.set_name('MSC', 'MSC_REL_SETUP_ERR');
    fnd_message.set_token('ERROR_MESSAGE', sqlerrm);
    raise_application_error(-20001,sqlerrm);
   -- commit;
END do_release;




FUNCTION get_instance_release_status(p_sr_instance_id in number) return number IS


 l_allow_release_flag number;
 l_instance_code varchar2(10);
 cursor cur_release_flag is
	select decode(apps_ver,3,nvl(allow_release_flag ,2)
                         ,4,nvl(allow_release_flag ,2)
   		      ,1) allow_release_flag,
	instance_code
	from msc_apps_instances
	where instance_id = nvl(p_sr_instance_id,-1);
 begin
   open cur_release_flag;
   fetch cur_release_flag
   into l_allow_release_flag,l_instance_code;
   if cur_release_flag%notfound then
          l_allow_release_flag := 2;
   end if;
   close cur_release_flag;
   return( l_allow_release_flag) ;
end get_instance_release_status;


FUNCTION get_implement_dock_date(p_plan_id in number,
				  p_inst_id in number,
				  p_org_id in number,
				  p_item_id in number,
				  p_receiving_calendar in varchar2,
				  p_implement_date in date) return date IS
  ln_pp_lead_time  NUMBER;
  lv_date          DATE;
  CURSOR CPPL IS
   SELECT nvl(postprocessing_lead_time, 0)
      FROM  msc_system_items
      WHERE plan_id = p_plan_id
      AND   sr_instance_id = p_inst_id
      AND   ORGANIZATION_ID = p_org_id
      AND   INVENTORY_ITEM_ID = p_item_id;

 BEGIN

    OPEN CPPL;
    FETCH CPPL INTO ln_pp_lead_time;
    CLOSE CPPL;
     -- preserve the time stamps and calculate
     -- the date after offsetting
     -- the lead time from the implement_date
    lv_date  := p_implement_date -
                (trunc(p_implement_Date)-
                       trunc(msc_calendar.date_offset(p_org_id,p_inst_id,1,p_implement_Date,
			-1 * ln_pp_lead_time)));

     --if the Receiving calendar is not null
     --validate the date against the Receiving Calendar
     --else validate the date against the
     -- Org Manufacturing Calendar
    if p_receiving_calendar is not null then
      lv_date := lv_date - (trunc(lv_date) - trunc(msc_calendar.PREV_WORK_DAY(p_receiving_calendar,p_inst_id, trunc(lv_date))));
    else
       lv_date := msc_calendar.PREV_WORK_DAY(p_org_id,p_inst_id,1,trunc(lv_date));
    end if;
    return greatest(trunc(sysdate),lv_date);
 exception when others then
   return null;
END get_implement_dock_date;




FUNCTION get_implement_ship_date(p_plan_id in number,
				  p_inst_id in number,
				  p_org_id in number,
				  p_order_type in number,
				  p_source_sr_instance_id in number,
				  p_source_org_id in number,
				  p_sourcre_vendor_site_id in number,
				  p_ship_method in varchar2,
				  p_intransit_calendar in varchar2,
				  p_ship_calendar in varchar2,
				  p_implement_dock_date in date,
				  p_source_table in varchar2) return date
				  IS
  ln_intransit_lead_time  NUMBER := 0;
  ln_tp_arranged_by       NUMBER := 1;
  lv_date          DATE;
  x_intransit_lead_time  NUMBER;
  x_return_status         VARCHAR2(30);


  l_session_id NUMBER := 0;
  l_src_org_id NUMBER :=     p_source_org_id;
  l_src_vendor_site_id NUMBER := p_sourcre_vendor_site_id;
  l_src_sr_inst_id NUMBER := p_source_sr_instance_id;
  l_org_id NUMBER := p_org_id;
  l_sr_inst_id NUMBER := p_inst_id;
  l_ship_method varchar2(30) := p_ship_method;

 BEGIN
 IF (p_order_type  in (1,2,5)
     AND p_SOURCE_TABLE = 'MSC_SUPPLIES') THEN

   --- get the unique number identifying the current session
     SELECT MRP.mrp_atp_schedule_temp_s.nextval
      INTO l_session_id
     FROM dual;

    -- Call ATP method to get the intransit lead time value in
    -- the out parameter x_intransit_lead_time
   MSC_ATP_PROC.ATP_Intransit_LT(
	2, l_session_id,
	l_src_org_id,
	null,
	l_src_vendor_site_id,
	l_src_sr_inst_id,
	l_org_id,
	null,
	null,
	l_sr_inst_id,
	l_ship_method,
	x_intransit_lead_time,
	x_return_status);
	-- preserve the time stamps and calculate the date
	-- after offsetting the lead time from the
	--implement_dock_date
    lv_date  := p_implement_Dock_Date-
                      (trunc(p_implement_dock_date)-
		         trunc(msc_calendar.date_offset(p_org_id,p_inst_id,1,
			   p_implement_dock_date,-1 * x_intransit_lead_time)));
    -- if intransit calendar is not null then validate the
    -- date against the intransit calendar
    -- else validate the date against the shipping calendar.
   if p_intransit_calendar is not null then
      lv_date := lv_date - (trunc(lv_date) -
           trunc(msc_calendar.PREV_WORK_DAY(p_intransit_calendar, p_inst_id, trunc(lv_date))));
   else
      lv_date := lv_date - (trunc(lv_date) -
      trunc(msc_calendar.PREV_WORK_DAY(p_ship_calendar, p_inst_id, trunc(lv_date))));
   end if;
   return greatest(trunc(sysdate),lv_date);
 else
   return null;
 END IF;
 exception when others then
  return null;
 END get_implement_ship_date;


FUNCTION GET_WIP_JOB_PREFIX(p_instance_id in number)  return varchar2 is

   l_seq_num number;
   lv_job_prefix varchar2(40);

   begin
      l_seq_num := msc_rel_wf.get_job_seq_from_source(p_instance_id);



      msc_rel_wf.get_profile_value(p_profile_name   => 'WIP_JOB_PREFIX',
                           p_instance_id    =>p_instance_id,
                           p_profile_value  => lv_job_prefix);
      return lv_job_prefix||to_char(l_seq_num);
END GET_WIP_JOB_PREFIX;




Function get_Imp_Employee_id(
   p_plan_id in number,
   p_org_id in number,
   p_inst_id in number,
   p_item_id in number,
   p_planner_code in varchar2) return number is




CURSOR C1 IS
	SELECT employee_id
	FROM msc_planners
	WHERE planner_code = p_planner_code
	AND organization_id = p_org_id
	AND sr_instance_id = p_inst_id
	AND current_employee_flag = 1;

 CURSOR C2 IS
	 SELECT employee_id
	 FROM msc_planners mp,
	 msc_system_items msi
	 WHERE mp.planner_code = msi.planner_code
	 AND mp.organization_id = msi.organization_id
	 AND mp.sr_instance_id = msi.sr_instance_id
	 AND mp.current_employee_flag = 1
	 AND msi.plan_id = p_plan_id
	 AND msi.organization_id = p_org_id
	 AND msi.sr_instance_id = p_inst_id
	 AND msi.inventory_item_id = p_item_id;

 l_employee_id		NUMBER;

 BEGIN
   if  p_planner_code is not null then


	OPEN C1;

	FETCH C1 INTO l_employee_id;
	CLOSE C1;
   else
	OPEN C2;

	FETCH C2 INTO l_employee_id;
	CLOSE C2;

   END IF;
   return l_employee_id;

end get_Imp_Employee_id;



FUNCTION Check_Source_Supp_Org (
     p_inst_id in number,
     p_org_id in number) return Number is

 l_count NUMBER;

 CURSOR C1 IS
	 SELECT count(1)
	 FROM msc_trading_partners
	 WHERE sr_tp_id = p_org_id
	 AND sr_instance_id = p_inst_id
	 AND (modeled_customer_id is not null
	 OR  modeled_supplier_id is not null);

 BEGIN

 OPEN C1;
 FETCH C1 INTO l_count;
 CLOSE C1;

 if (l_count = 0) then

	RETURN 2;  -- false;
 else
	RETURN 1; --- true;
 end if;

 End Check_Source_Supp_Org;


FUNCTION  validate_order_for_release(
p_plan_id			in number,
p_inst_id			in number,
p_org_id			in number,
p_org_code			in varchar2,
p_item_id			in number,
p_vmi				in number,
p_source_Table			in varchar2,
p_transaction_id		in number,
p_order_type			in number,
p_source_org_id			in number,
P_bom_item_type			in number,
p_release_time_fence_code	in number,
p_in_source_plan		in number,
p_build_in_wip_flag		in number,
p_purchasing_enabled_flag	in number,
p_planning_make_buy_code	in number,
p_planner_code			in varchar2,
p_implement_alternate_routing   in varchar2,
p_user_id   in number,
p_resp_id   in number,
p_appl_id   in number
) return varchar2 IS




p_valid number;
p_rel_schd_OK varchar2(3);
p_rel_error varchar2(1024);
l_instance_Code varchar2(10);
l_def_pref_id number;
l_pref_release_vmi varchar2(10);
l_include_so varchar2(10);
l_temp Number;

l_user_id number := nvl(FND_PROFILE.VALUE('USER_ID'),1);
l_plan_type number :=1 ; -- temp set as ASCP plan

CURSOR empl_C IS
      SELECT mp.employee_id
  FROM msc_planners mp
  WHERE mp.planner_code = p_planner_code
  AND mp.organization_id = p_org_id
  AND mp.sr_instance_id = p_inst_id
  AND mp.current_employee_flag = 1;

CURSOR loc_C IS
  select mtps.sr_tp_site_id
  from msc_trading_partners mtp,
         msc_trading_partner_sites mtps
  where mtp.sr_tp_id = p_org_id
  AND mtp.sr_instance_id = p_inst_id
  AND mtp.partner_type =3
  AND mtps.partner_id = mtp.partner_id;



BEGIN
   /* we should not release vmi items*/
    fnd_global.apps_initialize(p_user_id, p_resp_id, p_appl_id);
  --  msc_rel_wf.init_db('OPERATIONS');
  l_def_pref_id := msc_get_name.get_default_pref_id(l_user_id);
  l_pref_release_vmi:= msc_get_name.GET_preference('ORDERS_RELEASE_VMI_ITEMS', l_def_pref_id, l_plan_type);
  -- l_include_so:= msc_get_name.GET_preference('INCLUDE_SO', l_def_pref_id, l_plan_type);
  l_include_so:= 'Y';

  IF l_pref_release_vmi = 'N' and nvl(p_vmi,2) = 1 then
	p_rel_error :='Cannot release this as the preference Release VMI Items is set to No';
        return p_rel_error;
  END IF;



   /* if it is supply and order type not in (1,2,3,5,13) */
    if (p_source_table='MSC_SUPPLIES' AND
        p_order_type NOT IN (1, 2, 3, 5, 13) )then
        p_rel_error :=FND_MESSAGE.GET_STRING('MSC', 'MSC_WB_RELEASE_3');
        return p_rel_error;
    END IF;



  /* if the instance is not release enabled */
  if (get_instance_release_status(p_inst_id) = 2) then
     l_instance_code  := substr(p_org_code,1,instr(p_org_code,':',-1)-1);
     fnd_message.set_name('MSC','MSC_ALLOW_RELEASE_INSTANCE');
     fnd_message.set_token('INSTANCE',l_instance_code);
     p_rel_error :=fnd_message.get;
     return p_rel_error;
  end if;


  /* if source db is not running  */
  if not (msc_rel_wf.is_source_db_up(p_inst_id)) then
    p_rel_error :=FND_MESSAGE.GET_STRING('MSC', 'MSC_SOURCE_IS_INVALID');
    return p_rel_error;
 end if;


   /* if plan option does not allow to release sales order   */
   if (p_order_type=30) and (l_include_so='N') then
	p_rel_error :=FND_MESSAGE.GET_STRING('MSC', 'MSC_WB_RELEASE1');
	return p_rel_error;
   end if;


  /* model/option classes can not be released   */
  if (p_bom_item_type in (1, 2, 3, 5) )then
     p_rel_error := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_MODEL');
     return p_rel_error;
  end if;





  /* Kanban item can not be released  */
  if (p_order_type=5 and p_source_table='MSC_SUPPLIES' and p_release_time_fence_code = 6)  then
      p_rel_error := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_KANBAN');
      return p_rel_error;
  end if;

  /* can not release planned order as flow schedule */
  /* what if it is new planned order where
  /* engine has not set cfm flag yet ??? */
  if ( p_order_type = 5) then

	l_temp := msc_get_name.check_cfm(
                 p_plan_id,
                 p_org_id,
                 p_inst_id,
                 p_item_id,
                 p_transaction_id,
                 p_implement_alternate_routing);
     if  l_temp = 1 then
       p_rel_error := FND_MESSAGE.GET_STRING('MSC', 'MSC_NO_FLOW_SCHEDULE');
       return p_rel_error;
     end if;
  end if;



  /* not able to release sales order */
 if (p_source_table ='MSC_DEMANDS' and p_order_type=30) then
      p_rel_error := msc_rel_wf.verify_so_release(p_plan_id,p_transaction_id,p_inst_id);
      if (p_rel_error is not null)  then
        return p_rel_error;
      end if;

 end if;





  if p_in_source_plan = 1 then
     p_rel_schd_OK := nvl(fnd_profile.value('MSC_DRP_RELEASE_FROM_MRP'),'N');

     if (p_rel_schd_OK = 'N') then

         p_rel_error := FND_MESSAGE.GET_STRING('MRP', 'MSC_IN_SOURCE_PLAN');
	 return p_rel_error;
     end if;
  end if; -- if p_in_source_plan = 1 then





  /* -- 4417550, make planned order can be released only when
     -- child supply are on hand or make planned order
  */

   p_valid := null;
   if (nvl(FND_PROFILE.VALUE('MSC_REL_ONLY_ONHAND_SUPPLY'),'N') =  'Y'
    and p_order_type = 5 and p_org_id = p_source_org_id) then
         p_valid := MSC_SELECT_ALL_FOR_RELEASE_PUB.child_supplies_onhand(
                    p_plan_id, p_transaction_id);
         if p_valid > 0 then
            p_rel_error := FND_MESSAGE.GET_STRING('MSC', 'MSC_REL_ONLY_ONHAND_WARN2');
	    return p_rel_error;
         end if;

   end if;




   return p_rel_error;

END validate_order_for_release;


FUNCTION GET_ACTION (arg_source_table IN VARCHAR2,
		arg_plan_id  IN NUMBER ,
		arg_sr_instance_id in number,
		arg_org_id in number,
		arg_item_id in number,
                arg_bom_item_type IN NUMBER ,
                arg_base_item_id IN NUMBER,
                arg_wip_supply_type IN NUMBER ,
                arg_order_type IN NUMBER ,
                arg_rescheduled_flag IN NUMBER,
                arg_disposition_status_type IN NUMBER ,
                arg_new_due_date IN DATE ,
                arg_old_due_date IN DATE ,
                arg_implemented_quantity IN NUMBER ,
                arg_quantity_in_process IN NUMBER ,
                arg_quantity_rate IN NUMBER ,
                arg_release_time_fence_code IN NUMBER ,
                arg_reschedule_days IN NUMBER ,
                arg_firm_quantity IN NUMBER ,
                arg_mrp_planning_code IN NUMBER,
                arg_lots_exist IN NUMBER
                 ) RETURN varchar2 is


cursor crit_component  IS
select critical_component_flag
from msc_system_items
where plan_id  = arg_plan_id
and inventory_item_id = arg_item_id
and organization_id = arg_org_id
and sr_instance_id = arg_sr_instance_id;

l_critical_component number;
l_action VARCHAR2(20);
BEGIN
	open crit_component;
	fetch crit_component into l_critical_component;
	close crit_component;
	l_action := msc_get_name.action(arg_source_table,
					arg_bom_item_type,
					arg_base_item_id,
					arg_wip_supply_type,
					arg_order_type,
					arg_rescheduled_flag,
					arg_disposition_status_type,
					arg_new_due_date,
					arg_old_due_date,
					arg_implemented_quantity,
					arg_quantity_in_process,
					arg_quantity_rate,
					arg_release_time_fence_code,
					arg_reschedule_days,
					arg_firm_quantity,
					arg_plan_id,
					nvl(l_critical_component,2),
					arg_mrp_planning_code,
					arg_lots_exist);
	return l_action;

END GET_ACTION;

FUNCTION get_Implement_Location_Id(p_inst_id in number,
					p_org_id in number) return number is



CURSOR C1 IS
SELECT partner_id
FROM msc_trading_partners
WHERE partner_type = 3
AND sr_tp_id = p_org_id
AND sr_instance_id = p_inst_id;

l_partner_id 	NUMBER;

CURSOR C2 IS
SELECT s.sr_tp_site_id, s.location
FROM msc_trading_partner_sites s
where s.partner_id = l_partner_id;

l_loc_id      NUMBER;
l_loc_code varchar2(80);

BEGIN

 OPEN C1;
 FETCH C1 INTO l_partner_id;
 CLOSE C1;

 OPEN C2;
 FETCH C2 INTO l_loc_id, l_loc_code;

 return   l_loc_id;

END get_Implement_Location_Id;


FUNCTION GET_IMPLEMENT_WIP_CLASS_CODE(
 	p_plan_id in number,
	p_instance_id in number,
	p_org_id in number,
	p_item_id in number,
	p_transaction_id in number,
	p_order_type in number,
	p_project_id in number,
	p_implement_project_id in number,
	p_implement_as in number,
	p_implement_alternate_routing in varchar2) return varchar2 is


l_def_pref_id Number;
l_option_job_code varchar2(20):=null;
v_temp number;
v_sr_item number;
l_wip_class_code varchar2(20);
l_plan_type number:=1;  --- temp set as ASCP plan
v_project_id number;
CURSOR sr_item_cur IS
select sr_inventory_item_id
from msc_system_items
where plan_id = p_plan_id
and organization_id = p_org_id
and sr_instance_id = p_instance_id
and inventory_item_id = p_item_id;

BEGIN


if (p_order_type=5 and p_implement_as=3) then
  -- in rp there is no user preference value
  -- l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id);
  --l_option_job_code:= msc_get_name.GET_preference('ORDERS_JOB_CLASS_CODE', l_def_pref_id, l_plan_type);

  if (l_option_job_code is not null) then
    l_wip_class_code :=l_option_job_code;
  else
    v_temp := msc_get_name.check_cfm(
  		p_plan_id,
		p_org_id,
 		p_instance_id,
		p_item_id,
		p_transaction_id,
 		p_implement_alternate_routing);
    if nvl(v_temp,-1) <> 3 then
	  if p_implement_project_id is  NULL THEN
 		v_project_id := p_project_id;
 	  ELSE
		v_project_id := p_implement_project_id;
	  END IF;

	  OPEN sr_item_cur;
	  FETCH sr_item_cur INTO v_sr_item;
	  CLOSE sr_item_cur;

	  l_wip_class_code := msc_rel_wf.get_acc_class_from_source(
 			p_org_id,
			v_sr_item,
			v_project_id,
			p_instance_id);

    END IF;

   END IF;
END IF;
return l_wip_class_code ;
END GET_IMPLEMENT_WIP_CLASS_CODE;

PROCEDURE PRINT_DEBUG(MSG IN VARCHAR2) IS

BEGIN
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
           'MSC_RP_RELEASE_PUB', MSG);
ELSE
   dbms_output.PUT_LINE(MSG);
   dbms_output.new_line();
END If;

END PRINT_DEBUG;
procedure validate_icx_session(p_icx_cookie in varchar2,p_function in varchar2 DEFAULT NULL)  is
    l_function varchar2(100) :=nvl(p_function,'SIM_WORKBENCH');
     SECURITY_CONTEXT_INVALID exception;

begin
     app_session.validate_icx_session(p_icx_cookie);
     if fnd_function.test(l_function)  then   ---  SIM_WORKBENCH
        return;
    else
       raise SECURITY_CONTEXT_INVALID;
     end if;
   exception
      when others then
        raise SECURITY_CONTEXT_INVALID;
end validate_icx_session;

FUNCTION GET_RP_PLAN_PROFILE_VALUE(P_PLAN_ID IN NUMBER,
                                  P_PROFILE_CODE IN VARCHAR2) RETURN VARCHAR2

IS

cursor cur_plan_profile is
select profile_value
from msc_plan_profiles
where plan_id=p_plan_id
and profile_code=p_profile_code;

x_profile_value varchar2(240):=null;

BEGIN

 open cur_plan_profile;
 fetch cur_plan_profile into x_profile_value;
 if cur_plan_profile%notfound then
    return null;

  end if;
 close cur_plan_profile;
 return x_profile_value;

END GET_RP_PLAN_PROFILE_VALUE;

Function GET_REQUEST_STATUS (
         request_id     IN OUT nocopy number,
         application    IN varchar2 default NULL,
         program        IN varchar2 default NULL,
         phase          OUT nocopy varchar2  ,
         status         OUT nocopy varchar2  ,
         dev_phase      OUT nocopy varchar2,
         dev_status     OUT nocopy varchar2,
         message        OUT nocopy varchar2) return number
IS
l_ret_st Number;
begin
   if (FND_CONCURRENT.GET_REQUEST_STATUS(request_id,
        application	,
         program	,
         phase		,
         status		,
         dev_phase	,
         dev_status	,
         message	) ) then
        return 0;
   else
        return -1;
   end if;
end GET_REQUEST_STATUS;


Function test_permission(pname in varchar2) return number  is
             SECURITY_CONTEXT_INVALID exception;

begin
     if fnd_function.test(pname)  then
       return 1;
    else
       return 2 ;
     end if;
exception
  when others then
   return 2;
end test_permission;



Function save_user_profile(name in varchar2, value in varchar2) return number
is
begin
     if fnd_profile.save_user(name,value)  then
       return 1;
    else
       return 2 ;
     end if;
exception
  when others then
   return 2;
end save_user_profile;

END MSC_RP_RELEASE_PUB;

/
