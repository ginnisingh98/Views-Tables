--------------------------------------------------------
--  DDL for Package Body WIP_WS_PTPKPI_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WS_PTPKPI_PK" as
/* $Header: WIPWSPPB.pls 120.10.12010000.3 2008/09/03 00:21:35 awongwai ship $ */

/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|
| FILE NAME   : WIPWSPPB.sql
| DESCRIPTION :
|              This package contains specification for all APIs related to
               MES production to Plan module
|
| HISTORY     : created   13-SEP-07
|             Renga Kannan 13-Sep-2007   Creating Initial Version
|

*============================================================================*/

Procedure populate_plan_data(
            p_org_id        in number,
            p_org_ptpkpi_rec IN org_ptpkpi_rec_type,
            x_return_status out nocopy varchar2,
            x_msg_count     out nocopy number,
            x_msg_data      out nocopy varchar2);

Procedure populate_actual_data(
            p_org_id   in Number,
            p_org_ptpkpi_rec IN org_ptpkpi_rec_type,
            x_return_status  out  nocopy Varchar2,
            x_msg_count      out  nocopy number,
            x_msg_data       out  nocopy varchar2);

Procedure wip_ws_PTPKPI_CONC_PROG(
                             errbuf            out nocopy varchar2,
                             retcode           out nocopy varchar2,
                             p_org_id          in  number) is

    l_return_status   varchar2(1);
    l_msg_data        varchar2(1000);
    l_msg_count       number;
    l_lock_status     number;
    l_params wip_logger.param_tbl_t;
    l_pref_exists    varchar2(1);

    l_concurrent_count NUMBER;
    l_conc_status boolean;
    l_org_ptpkpi_rec org_ptpkpi_rec_type;

Begin
    if (g_logLevel <= wip_constants.trace_logging) then

       l_params(1).paramName := 'p_org_id';
       l_params(1).paramValue := p_org_id;

       wip_logger.entryPoint(p_procName => 'WIP_WS_SHORTAGE.get_org_comp_calc_param',
                             p_params => l_params,
                             x_returnStatus => l_return_Status);
       if(l_return_Status <> fnd_api.g_ret_sts_success) then
          raise fnd_api.g_exc_unexpected_error;
       end if;
       wip_logger.log(' Start Time   : = '||to_char(sysdate),l_return_status);

     end if;
     wip_ws_util.trace_log('Org id  = '||to_char(p_org_id));
     wip_ws_util.trace_log('Start time  = '||to_char(sysdate));


     wip_logger.log(' Trying to get lock for this organization ',l_return_status);
     savepoint wip_ws_ptpkpi_calc;

    l_concurrent_count := wip_ws_util.get_no_of_running_concurrent(
    p_program_application_id => fnd_global.prog_appl_id,
    p_concurrent_program_id  => fnd_global.conc_program_id,
    p_org_id                 => p_org_id);

    if l_concurrent_count > 1 then
        wip_ws_util.log_for_duplicate_concurrent (
            p_org_id       => p_org_id,
            p_program_name => 'Production to Plan KPI');
        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'Errors encountered in calculation program, please check the log file.');
        return;
    end if;

    get_org_ptpkpi_param(p_org_id         => p_org_id,
                         x_pref_exists    => l_pref_exists,
                         x_org_ptpkpi_rec => l_org_ptpkpi_rec);


    If l_pref_exists = 'N' then
       wip_ws_util.trace_log(' No Preference exists for this organization');
       fnd_message.set_name('WIP','NO_PTPKPI_PREF_EXISTS');
       raise FND_API.G_EXC_ERROR;
    End if;



    -- Call populate plan data api
    populate_plan_data(p_org_id        => p_org_id,
        p_org_ptpkpi_rec=>  l_org_ptpkpi_rec,
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data);

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	wip_ws_util.trace_log('Unexpected error occured in populate_plan_data API');
	raise FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	wip_ws_util.trace_log('Expected error occurred in populate_plan_data API');
        raise FND_API.G_EXC_ERROR;
   ELSE
	wip_ws_util.trace_log('populate_plan_data_API is successfull');
   END IF;

   -- Call populate actual data api

   populate_actual_data(
      p_org_id        => p_org_id,
      p_org_ptpkpi_rec=>  l_org_ptpkpi_rec,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	wip_ws_util.trace_log('Unexpected error occured in populate_actual_data API');
	raise FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	wip_ws_util.trace_log('Expected error occurred in populate_actual_data API');
        raise FND_API.G_EXC_ERROR;
   ELSE
	wip_ws_util.trace_log('populate_actual_data is successfull');
   END IF;


EXCEPTION
     when FND_API.G_EXC_UNEXPECTED_ERROR then
		wip_ws_util.trace_log('Came to unexpected error in wip_ws_PTPKPI_CONC_PROG');
		rollback to wip_ws_ptpkpi_calc;
		retcode := 2;  -- End with error
     when FND_API.G_EXC_ERROR then
                retcode := 1;
		wip_ws_util.trace_log('Came to expected error in wip_ws_PTPKPI_CONC_PROG');
		rollback to wip_ws_ptpkpi_calc;
     when others then
		wip_ws_util.trace_log('Came to others error in wip_ws_PTPKPI_CONC_PROG');
		rollback to wip_ws_ptpkpi_calc;
		retcode := 2;  -- End with error
End wip_ws_PTPKPI_CONC_PROG;






/**************************************************************************

        Procedure Name  : Populate_Plan_data
        Description     : This procedure will delete the existing rows for
                          the plan table and populate new data. This API
                          will be called from concurrent program API

****************************************************************************/

Procedure populate_plan_data(p_org_id        in number,
            p_org_ptpkpi_rec IN org_ptpkpi_rec_type,
            x_return_status out nocopy varchar2,
            x_msg_count     out nocopy number,
            x_msg_data      out nocopy varchar2) is

   l_sql VARCHAR2(2048) := null;
   l_job_status_clause  varchar2(2048);
   l_job_type_clause    varchar2(2048);
   l_cursor             integer;
   l_dummy              integer;


Begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- Delete the rows that are populated by last concurrent run
   -- for the parameter org

   wip_ws_util.trace_log('Entering Populate_plan_data API');

   delete wip_ws_ptpkpi_plan
   where  organization_id = p_org_id;

   wip_ws_util.trace_log(' Deleted old rows in the table. Rows deleted = '||sql%rowcount);

   -- Populate data from wip data model to
   -- ptp kpi plan table
   l_job_status_clause := ' and wdj.status_type in ('|| get_pref_job_statuses(p_org_ptpkpi_rec) || ')';
   l_job_type_clause := ' and wdj.job_type in ('||get_job_types(p_org_ptpkpi_rec) || ')';
   l_sql :=
   'insert into wip_ws_ptpkpi_plan(
                organization_id,
                department_id,
                wip_entity_id,
                operation_seq_num,
                shift_id,
                planned_qty,
                primary_uom_code,
                op_lead_time,
                concurrent_request_id,
                last_update_date,
                last_update_by,
                creation_date,
                created_by,
		shift_start_time
              )
   select
	  wo.organization_id,
	  wo.department_id,
	  wo.wip_entity_id,
	  wo.operation_seq_num,
	  WIP_WS_PTPKPI_UTIL.get_shift_id_for_date(
	    wo.organization_id, wo.department_id, null, wo.last_unit_completion_date
	  ) ,
	  wo.scheduled_quantity-wo.cumulative_scrap_quantity ,
	  msi.primary_uom_code,
	  WIP_WS_PTPKPI_UTIL.get_operation_lead_time(
	    wo.organization_id, wo.wip_entity_id, wo.operation_seq_num
	  ) ,
	  fnd_global.CONC_REQUEST_ID,
          sysdate,
          :guserid,
          sysdate,
          :guserid,
	  WIP_WS_PTPKPI_UTIL.get_datetime_for_shift(:p_org_id,WIP_WS_PTPKPI_UTIL.get_shift_id_for_date(
	    wo.organization_id, wo.department_id, null, wo.last_unit_completion_date
	  ),1)
    from
	  wip_operations wo,
	  wip_discrete_jobs wdj,
	  mtl_system_items msi
    where wo.organization_id = :p_org_id
	  and wo.repetitive_schedule_id is null
	  and wo.last_unit_completion_date >= trunc(sysdate) - 30
	  and wo.wip_entity_id = wdj.wip_entity_id
	  and wo.organization_id = wdj.organization_id
	  and wdj.primary_item_id = msi.inventory_item_id
	  and wdj.organization_id = msi.organization_id';
   l_sql := l_sql || l_job_status_clause || l_job_type_clause;

   wip_ws_util.trace_log('Constructed sql statement = ');
   wip_ws_util.trace_log(l_sql);
   l_cursor := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
   dbms_sql.bind_variable(l_cursor, ':p_org_id', p_org_id);
   dbms_sql.bind_variable(l_cursor,':guserid',g_user_id);
   l_dummy := dbms_sql.execute(l_cursor);
   wip_ws_util.trace_log(' Number of rows inserted = '||sql%rowcount);
   dbms_sql.close_cursor(l_cursor);

EXCEPTION
     when FND_API.G_EXC_UNEXPECTED_ERROR then
               wip_ws_util.trace_log('Error message = '||sqlerrm);
		wip_ws_util.trace_log('Came to unexpected error in populate_plan_data');
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     when FND_API.G_EXC_ERROR then
		wip_ws_util.trace_log('Came to expected error in populate_plan_data');
		x_return_status := FND_API.G_RET_STS_ERROR;
     when others then
                wip_ws_util.trace_log('Error message = '||sqlerrm);
		wip_ws_util.trace_log('Came to others error in populate_plan_data');
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
End populate_plan_data;


FUNCTION get_pref_job_statuses(
           p_org_ptpkpi_rec IN org_ptpkpi_rec_type) RETURN VARCHAR2 IS
  status_str VARCHAR2(240) := null;
BEGIN
	if(p_org_ptpkpi_rec.inc_released_jobs = WIP_CONSTANTS.YES) then
	  status_str := to_char(wip_constants.RELEASED);
	end if;

	if(p_org_ptpkpi_rec.inc_unreleased_jobs = WIP_CONSTANTS.YES) then
	  if(status_str is not null) then
	    status_str := status_str||',';
	  end if;
	  status_str := status_str || to_char(wip_constants.UNRELEASED);
	end if;

	if(p_org_ptpkpi_rec.inc_onhold_jobs = WIP_CONSTANTS.YES) then
	  if(status_str is not null) then
	    status_str := status_str||',';
	  end if;
	  status_str := status_str || to_char(wip_constants.HOLD);
	end if;

	if (p_org_ptpkpi_rec.inc_completed_jobs = WIP_CONSTANTS.YES) then
           if(status_str is not null) then
	      status_str := status_str||',';
	   end if;
	   status_str := status_str || to_char(wip_constants.COMPLETED);
	end if;
        if status_str is null then
	   status_str := 'null';
	end if;
  return status_str;
END get_pref_job_statuses ;

FUNCTION get_job_types(
            p_org_ptpkpi_rec IN org_ptpkpi_rec_type) RETURN VARCHAR2 IS
  job_type_str VARCHAR2(240) := null;
BEGIN
  wip_ws_util.trace_log('include std jobs = '||p_org_ptpkpi_rec.inc_standard_jobs);
  wip_ws_util.trace_log('include non std jobs = '||p_org_ptpkpi_rec.inc_nonstd_jobs);
  if (p_org_ptpkpi_rec.inc_standard_jobs = WIP_CONSTANTS.YES) then
     job_type_str := to_char(wip_constants.STANDARD);
  end if;
  if (p_org_ptpkpi_rec.inc_nonstd_jobs = WIP_CONSTANTS.YES) then
     if (job_type_str is not null) then
        job_type_str := job_type_str||',';
     end if;
        job_type_str := job_type_str||to_char(wip_constants.NONSTANDARD);
  end if;

  return job_type_str;
END get_job_types;

Procedure get_org_ptpkpi_param(
            p_org_id IN NUMBER,
            x_pref_exists  out nocopy varchar2,
            x_org_ptpkpi_rec OUT NOCOPY org_ptpkpi_rec_type) is
l_row_seq_num    number;
Begin

  l_row_seq_num := WIP_WS_UTIL.get_multival_pref_seq(p_pref_id => g_pref_id_ptp,
    p_level_id        => g_pref_level_id_site,
    p_attribute_name  => g_pref_val_mast_org_att,
    p_attribute_val   => p_org_id);

  wip_ws_util.trace_log('Preferenc row seq num = '||l_row_seq_num);

  If l_row_seq_num is not null then
    x_pref_exists := 'Y';
    x_org_ptpkpi_rec.org_id              := p_org_id;
    x_org_ptpkpi_rec.inc_released_jobs   :=
      WIP_WS_UTIL.get_multival_pref_val_code(g_pref_id_ptp, g_pref_level_id_site, l_row_seq_num, g_pref_val_inc_release_att);
    x_org_ptpkpi_rec.inc_unreleased_jobs :=
      WIP_WS_UTIL.GET_MULTIVAL_PREF_VAL_CODE(g_pref_id_ptp, g_pref_level_id_site, l_row_seq_num, g_pref_val_inc_unreleased_att);
    x_org_ptpkpi_rec.inc_onhold_jobs     :=
      WIP_WS_UTIL.GET_MULTIVAL_PREF_VAL_CODE(g_pref_id_ptp, g_pref_level_id_site, l_row_seq_num, g_pref_val_inc_onhold_att);
    x_org_ptpkpi_rec.inc_completed_jobs  :=
      WIP_WS_UTIL.GET_MULTIVAL_PREF_VAL_CODE(g_pref_id_ptp, g_pref_level_id_site, l_row_seq_num, g_pref_val_inc_completed_att);
    x_org_ptpkpi_rec.inc_standard_jobs   :=
      WIP_WS_UTIL.GET_MULTIVAL_PREF_VAL_CODE(g_pref_id_ptp, g_pref_level_id_site, l_row_seq_num, g_pref_val_inc_standard_att);
    x_org_ptpkpi_rec.inc_nonstd_jobs :=
      WIP_WS_UTIL.GET_MULTIVAL_PREF_VAL_CODE(g_pref_id_ptp, g_pref_level_id_site, l_row_seq_num, g_pref_val_inc_nonstd_att);
  else
    x_pref_exists := 'N';
  end if;

End;

Procedure populate_actual_data(
            p_org_id   in Number,
            p_org_ptpkpi_rec IN org_ptpkpi_rec_type,
            x_return_status  out  nocopy Varchar2,
            x_msg_count      out  nocopy number,
            x_msg_data       out  nocopy varchar2) is
/*
Cursor move_tran_cur(p_org_id number,recentshiftdate date) is
        select
	  wo.organization_id  ,
	  wo.department_id  ,
	  wo.wip_entity_id ,
	  wo.operation_seq_num,
	  wmt1.PRIMARY_QUANTITY,
	  WIP_WS_PTPKPI_UTIL.get_shift_id_for_date(
	          wo.organization_id,
		  wo.department_id,
		  null,
		  wmt1.transaction_date
	           )  shift_id,
	  fm_operation_seq_num  fm_op,
	  FM_INTRAOPERATION_STEP_TYPE fm_step,
	  to_operation_seq_num to_op,
	  TO_INTRAOPERATION_STEP_TYPE  to_step,
	  wmt1.primary_uom primary_uom_code,
	  WIP_WS_PTPKPI_UTIL.get_operation_lead_time(
	           wmt1.organization_id,
		   wmt1.wip_entity_id,
		   wo.operation_seq_num) op_lead_time,
          wo.operation_seq_num op
	from
	  wip_move_transactions wmt1,
	  wip_operations wo,
	  wip_discrete_jobs wdj
	where
	      wo.organization_id = p_org_id
	  and wo.organization_id = wmt1.organization_id
	  and wo.wip_entity_id   = wdj.wip_entity_id
	  and wo.wip_entity_id = wmt1.wip_entity_id
	  and wo.repetitive_schedule_id is null
	  and wmt1.transaction_date >= recentShiftDate
	  and (
	    (
	      wo.operation_seq_num >=
	        wmt1.fm_operation_seq_num +
	        DECODE(SIGN(wmt1.FM_INTRAOPERATION_STEP_TYPE - 2),1,1,0)
	      and wo.operation_seq_num <
	        wmt1.to_operation_seq_num +
	        DECODE(SIGN(wmt1.TO_INTRAOPERATION_STEP_TYPE - 2),1,1,0)
	      and (
	        wmt1.to_operation_seq_num > wmt1.fm_operation_seq_num OR
	        (wmt1.to_operation_seq_num = wmt1.fm_operation_seq_num AND
	         wmt1.FM_INTRAOPERATION_STEP_TYPE <= 2 AND
	         wmt1.TO_INTRAOPERATION_STEP_TYPE > 2)
	      )
	      AND (
	        wo.count_point_type < 3 OR
	        wo.operation_seq_num = wmt1.fm_operation_seq_num OR
	        (wo.operation_seq_num = wmt1.to_operation_seq_num AND
	         wmt1.TO_INTRAOPERATION_STEP_TYPE > 2)
	      )
	    )
	    OR
	    (
	      wo.operation_seq_num <
	        wmt1.fm_operation_seq_num +
	        DECODE(SIGN(wmt1.FM_INTRAOPERATION_STEP_TYPE-2),1,1,0) AND
	      wo.operation_seq_num >=
	        wmt1.to_operation_seq_num +
	        DECODE(SIGN(wmt1.TO_INTRAOPERATION_STEP_TYPE-2),1,1,0) AND
	      (wmt1.fm_operation_seq_num > wmt1.to_operation_seq_num OR
	       (wmt1.fm_operation_seq_num = wmt1.to_operation_seq_num AND
	        wmt1.TO_INTRAOPERATION_STEP_TYPE <= 2 AND
	        wmt1.FM_INTRAOPERATION_STEP_TYPE > 2)
	      ) AND
	      (wo.count_point_type < 3 OR
	       (wo.operation_seq_num = wmt1.to_operation_seq_num AND wo.count_point_type < 3) OR
	       (wo.operation_seq_num = wmt1.fm_operation_seq_num AND wmt1.FM_INTRAOPERATION_STEP_TYPE > 2)
	      )
	    )
	    OR
	    (
	      -- pick up all the returns from scrap/reject for the source operation
	      wmt1.FM_INTRAOPERATION_STEP_TYPE in (4,5) AND
	      wo.operation_seq_num = wmt1.fm_operation_seq_num
	    )
	  );
*/

	l_sql       VARCHAR2(4048);
	move_qty    number;
	scrap_qty   number;
	reject_qty  number;
	RECENTSHIFTID  number;
	RecentShiftStartTime date;

	l_stmt_no   number;
	l_job_status_clause   varchar2(1000);
        l_job_type_clause     varchar2(1000);

	TYPE mov_tran_Curtype IS REF CURSOR;
        move_tran_cur mov_tran_curtype;

        l_operation_seq_num number;
	l_primary_quantity  number;
	l_fm_op             number;
	l_fm_step           number;
	l_to_op             number;
	l_to_step           number;


        l_organization_id number;
	l_department_id   number;
	l_wip_entity_id   number;
	l_op              number;
	l_shift_id        varchar2(100);
        l_primary_uom_code varchar2(100);
	l_op_lead_time     number;
        l_lead_time        number;
	RECENTSHIFTDATE    date;


Begin

/*
 QUEUE  CONSTANT NUMBER := 1;
  RUN    CONSTANT NUMBER := 2;
  TOMOVE CONSTANT NUMBER := 3;
  REJECT CONSTANT NUMBER := 4;
  SCRAP  CONSTANT NUMBER := 5;
*/

	wip_ws_util.trace_log('Entering populate_actual_data API');
	-- remove old data

        l_stmt_no  := 10;

	delete
	from wip_ws_ptpkpi_actual
	where shift_start_time < trunc(sysdate) - 30
	and organization_id = p_org_id;

	wip_ws_util.trace_log('Deleted old records. Number of records deleted = '||sql%rowcount);

	-- get the most recent shift information from existing aggregated actuals

        l_stmt_no  := 20;
	Begin

	  select shift_id, shift_start_time
	  into   RecentShiftid, RecentShiftStartTime
	  from  wip_ws_ptpkpi_actual
	  where shift_start_time in
		(select max(shift_start_Time)
		 from   wip_ws_ptpkpi_actual)
	  and rownum = 1;

	Exception When no_data_found then

          RecentShiftid := null;
	  RecentShiftStartTime := null;

	End;

	l_stmt_no  := 30;
	wip_ws_util.trace_log(' Most recent shift id = '||to_char(RecentShiftid));
	wip_ws_util.trace_log(' Most recent shift id = '||to_char(RecentShiftStartTime));

	/*
	If RecentShiftid is not null then
	   -- remove possible partial aggregated data for the most recent shift
	   delete from wip_ws_ptpkpi_actual
	   where shift_start_time >= RecentShiftStartTime;
	End if;
	*/

	delete from wip_ws_ptpkpi_actual
	where shift_start_time >= sysdate-7
  and organization_id = p_org_id;
	-- process each row and find out whether the quantity should be
	-- counted as a positive/negative move, scrap, or reject.

        wip_ws_util.trace_log('Before starting For loop');

        l_stmt_no  := 40;
        l_sql := 'select
	  wo.organization_id  ,
	  wo.department_id  ,
	  wo.wip_entity_id ,
	  wo.operation_seq_num,
	  wmt1.PRIMARY_QUANTITY,
	  WIP_WS_PTPKPI_UTIL.get_shift_id_for_date(
	          wo.organization_id,
		  wo.department_id,
		  null,
		  wmt1.transaction_date
	           )  shift_id,
	  fm_operation_seq_num  fm_op,
	  FM_INTRAOPERATION_STEP_TYPE fm_step,
	  to_operation_seq_num to_op,
	  TO_INTRAOPERATION_STEP_TYPE  to_step,
	  wmt1.primary_uom primary_uom_code,
	  WIP_WS_PTPKPI_UTIL.get_operation_lead_time(
	           wdj.organization_id,
		   wdj.wip_entity_id,
		   wo.operation_seq_num) op_lead_time,
          wo.operation_seq_num op
	from
	  wip_move_transactions wmt1,
	  wip_operations wo,
	  wip_discrete_jobs wdj
	where
	      wo.organization_id = :p_org_id
	  and wo.organization_id = wmt1.organization_id
	  and wo.wip_entity_id   = wdj.wip_entity_id
	  and wo.wip_entity_id = wmt1.wip_entity_id
	  and wo.repetitive_schedule_id is null
	  and wmt1.transaction_date >= sysdate-7
	  and (
	    (
	      wo.operation_seq_num >=
	        wmt1.fm_operation_seq_num +
	        DECODE(SIGN(wmt1.FM_INTRAOPERATION_STEP_TYPE - 2),1,1,0)
	      and wo.operation_seq_num <
	        wmt1.to_operation_seq_num +
	        DECODE(SIGN(wmt1.TO_INTRAOPERATION_STEP_TYPE - 2),1,1,0)
	      and (
	        wmt1.to_operation_seq_num > wmt1.fm_operation_seq_num OR
	        (wmt1.to_operation_seq_num = wmt1.fm_operation_seq_num AND
	         wmt1.FM_INTRAOPERATION_STEP_TYPE <= 2 AND
	         wmt1.TO_INTRAOPERATION_STEP_TYPE > 2)
	      )
	      AND (
	        wo.count_point_type < 3 OR
	        wo.operation_seq_num = wmt1.fm_operation_seq_num OR
	        (wo.operation_seq_num = wmt1.to_operation_seq_num AND
	         wmt1.TO_INTRAOPERATION_STEP_TYPE > 2)
	      )
	    )
	    OR
	    (
	      wo.operation_seq_num <
	        wmt1.fm_operation_seq_num +
	        DECODE(SIGN(wmt1.FM_INTRAOPERATION_STEP_TYPE-2),1,1,0) AND
	      wo.operation_seq_num >=
	        wmt1.to_operation_seq_num +
	        DECODE(SIGN(wmt1.TO_INTRAOPERATION_STEP_TYPE-2),1,1,0) AND
	      (wmt1.fm_operation_seq_num > wmt1.to_operation_seq_num OR
	       (wmt1.fm_operation_seq_num = wmt1.to_operation_seq_num AND
	        wmt1.TO_INTRAOPERATION_STEP_TYPE <= 2 AND
	        wmt1.FM_INTRAOPERATION_STEP_TYPE > 2)
	      ) AND
	      (wo.count_point_type < 3 OR
	       (wo.operation_seq_num = wmt1.to_operation_seq_num AND wo.count_point_type < 3) OR
	       (wo.operation_seq_num = wmt1.fm_operation_seq_num AND wmt1.FM_INTRAOPERATION_STEP_TYPE > 2)
	      )
	    )
	    OR
	    (
	      -- pick up all the returns from scrap/reject for the source operation
	      wmt1.FM_INTRAOPERATION_STEP_TYPE in (4,5) AND
	      wo.operation_seq_num = wmt1.fm_operation_seq_num
	    )
	  )';
          l_job_status_clause := ' and wdj.status_type in ('|| get_pref_job_statuses(p_org_ptpkpi_rec) || ')';
          l_job_type_clause := ' and wdj.job_type in ('||get_job_types(p_org_ptpkpi_rec) || ')';

          l_stmt_no := 42;
	  l_sql := l_sql||l_job_status_clause || l_job_type_clause;

	  wip_ws_util.trace_log('Sql Statement');
	  wip_ws_util.trace_log(l_sql);

          l_stmt_no := 45;
	  RECENTSHIFTDATE := nvl(RecentShiftStartTime,sysdate-30);

	  open move_tran_cur  for l_sql using p_org_id;
	  Loop
	     fetch move_tran_cur  into l_organization_id,l_department_id,l_wip_entity_id,
                                      l_operation_seq_num,l_primary_quantity,l_shift_id,
                                      l_fm_op,l_fm_step,l_to_op,l_to_step,l_primary_uom_code,
                                      l_lead_time,l_op;
             wip_ws_util.trace_log(' Inside loop');
	     exit when move_tran_cur%notfound;
	     move_qty := 0;
	     scrap_qty := 0;
	     reject_qty := 0;

	     l_stmt_no  := 50;
	     if (l_to_step in (1, 2)) then
	        l_stmt_no  := 60;
	        if (l_to_op > l_op) then
	           move_qty := l_primary_quantity;
	        elsif (l_to_op < l_op) then
	           move_qty := -1 * l_primary_quantity;
	        elsif (
	             l_to_op <= l_fm_op and
	             l_to_op = l_op and
	             l_FM_step not in (4,5)
		     ) then
	           move_qty := -1 * l_primary_quantity;
	        end if;
	     elsif (l_to_step= 3) then
	        l_stmt_no  := 70;
	        if (l_to_op >= l_op) then
	           move_qty := l_primary_quantity;
	        elsif (
	                 l_to_op < l_op
		     and(   l_FM_step not in (4,5)
		         or l_fm_op <> l_op
			)
	            ) then
	           move_qty := -1 * l_primary_quantity;
	        end if;
	     elsif (l_to_step= 5) then
	        l_stmt_no  := 80;
	        if (l_to_op> l_op) then
	          move_qty := l_primary_quantity ;
	        elsif (l_to_op < l_op) then
	          move_qty := -1 * l_primary_quantity;
	        elsif (l_to_op = l_op) then
	          move_qty := 0;
	          scrap_qty := l_primary_quantity;
	        end if;

	     elsif (l_to_step= 4) Then
	        l_stmt_no  := 90;
	        if (l_to_op > l_op) Then
	           move_qty := l_primary_quantity ;
	        elsif (l_to_op < l_op) then
	           move_qty := -1 * l_primary_quantity;
	        elsif (l_to_op = l_op) then
	           move_qty := 0;
	           reject_qty := l_primary_quantity;
	        end if;
	     End if;
	     l_stmt_no  := 100;
	     if (l_fm_step = 5) then
	       if (    l_fm_op = l_op
	        and l_op >= l_to_op) then
	          scrap_qty := -1 * l_primary_quantity;
	       end if;
	     end if;

	     if (l_fm_step = 4) then
	        if (l_fm_op = l_op and
	         l_op >= l_to_op) then
	           reject_qty := -1 * l_primary_quantity;
	        end if;
	     end if;

	     l_stmt_no  := 110;


             wip_ws_util.trace_log(' Org id = '||to_char(l_organization_id));
	     wip_ws_util.trace_log(' dept   = '||to_char(l_department_id));
	     wip_ws_util.trace_log(' entity id = '||to_char(l_wip_entity_id));
	     wip_ws_util.trace_log(' op  = '||to_char(l_op));
	     wip_ws_util.trace_log(' move qty = '||to_char(move_qty));
	     wip_ws_util.trace_log(' scrap qty = '||to_char(scrap_qty));
	     wip_ws_util.trace_log(' reject qty = '||to_char(reject_qty));
	     wip_ws_util.trace_log(' shift id  = '||l_shift_id);
	     wip_ws_util.trace_log(' uom  = '||l_primary_uom_code);
	     wip_ws_util.trace_log(' Lead time = '||to_char(l_lead_time));

           If move_qty+scrap_qty+reject_qty <> 0 Then
	    insert into wip_ws_ptp_gt
		(organization_id,
		 department_id,
		 wip_entity_id,
		 operation_seq_num,
		 move_qty,
		 scrap_qty,
		 reject_qty,
		 shift_id,
		 primary_uom_code,
		 op_lead_time
		)
            values(
		 l_organization_id,
		 l_department_id,
		 l_wip_entity_id,
		 l_op,
		 move_qty,
		 scrap_qty,
		 reject_qty,
		 l_shift_id,
		 l_primary_uom_code,
		 l_lead_time
		);
	   End if;

       End Loop;

/*
	For move_tran_rec in move_tran_cur(p_org_id,nvl(RecentShiftStartTime,sysdate-30))
	Loop
	wip_ws_util.trace_log('Inside Loop');
	  move_qty := 0;
	  scrap_qty := 0;
	  reject_qty := 0;

	  l_stmt_no  := 50;

	  if (move_tran_rec.to_step in (1, 2)) then
	  l_stmt_no  := 60;
	    if (move_tran_rec.to_op > move_tran_rec.op) then
	      move_qty := move_tran_rec.primary_quantity;
	    elsif (move_tran_rec.to_op < move_tran_rec.op) then
	      move_qty := -1 * move_tran_rec.primary_quantity;
	    elsif (
	             move_tran_rec.to_op <= move_tran_rec.fm_op and
	             move_tran_rec.to_op = move_tran_rec.op and
	             move_tran_rec.FM_step not in (4,5)
		     ) then
	      move_qty := -1 * move_tran_rec.primary_quantity;
	    end if;
	  elsif (move_tran_rec.to_step= 3) then
	  l_stmt_no  := 70;
	    if (move_tran_rec.to_op >= move_tran_rec.op) then
	       move_qty := move_tran_rec.primary_quantity;
	    elsif (
	                 move_tran_rec.to_op < move_tran_rec.op
		     and(   move_tran_rec.FM_step not in (4,5)
		         or move_tran_rec.fm_op <> move_tran_rec.op
			)
	            ) then
	      move_qty := -1 * move_tran_rec.primary_quantity;
	    end if;
	  elsif (move_tran_rec.to_step= 5) then
	  l_stmt_no  := 80;
	       if (move_tran_rec.to_op> move_tran_rec.op) then
	          move_qty := move_tran_rec.primary_quantity ;
	       elsif (move_tran_rec.to_op < move_tran_rec.op) then
	          move_qty := -1 * move_tran_rec.primary_quantity;
	       elsif (move_tran_rec.to_op = move_tran_rec.op) then
	          move_qty := 0;
	          scrap_qty := move_tran_rec.primary_quantity;
	       end if;

	  elsif (move_tran_rec.to_step= 4) Then
	  l_stmt_no  := 90;
	      if (move_tran_rec.to_op > move_tran_rec.op) Then
	         move_qty := move_tran_rec.primary_quantity ;
	      elsif (move_tran_rec.to_op < move_tran_rec.op) then
	         move_qty := -1 * move_tran_rec.primary_quantity;
	      elsif (move_tran_rec.to_op = move_tran_rec.op) then
	         move_qty := 0;
	         reject_qty := move_tran_rec.primary_quantity;
	      end if;
	  End if;
	  l_stmt_no  := 100;
	  if (move_tran_rec.fm_step = 5) then
	    if (    move_tran_rec.fm_op = move_tran_rec.op
	        and move_tran_rec.op >= move_tran_rec.to_op) then
	       scrap_qty := -1 * move_tran_rec.primary_quantity;
	    end if;
	  end if;

	  if (move_tran_rec.fm_step = 4) then
	     if (move_tran_rec.fm_op = move_tran_rec.op and
	         move_tran_rec.op >= move_tran_rec.to_op) then
	       reject_qty := -1 * move_tran_rec.primary_quantity;
	     end if;
	  end if;

	  l_stmt_no  := 110;


          wip_ws_util.trace_log(' Org id = '||to_char(move_tran_rec.organization_id));
	  wip_ws_util.trace_log(' dept   = '||to_char(move_tran_rec.department_id));
	  wip_ws_util.trace_log(' entity id = '||to_char(move_tran_rec.wip_entity_id));
	  wip_ws_util.trace_log(' op  = '||to_char(move_tran_rec.op));
	  wip_ws_util.trace_log(' move qty = '||to_char(move_qty));
	  wip_ws_util.trace_log(' scrap qty = '||to_char(scrap_qty));
	  wip_ws_util.trace_log(' reject qty = '||to_char(reject_qty));
	  wip_ws_util.trace_log(' shift id  = '||move_tran_rec.shift_id);
	  wip_ws_util.trace_log(' uom  = '||move_tran_rec.primary_uom_code);
	  wip_ws_util.trace_log(' Lead time = '||to_char(move_tran_rec.op_lead_time));

	  insert into wip_ws_ptp_gt
		(organization_id,
		 department_id,
		 wip_entity_id,
		 operation_seq_num,
		 move_qty,
		 scrap_qty,
		 reject_qty,
		 shift_id,
		 primary_uom_code,
		 op_lead_time
		)
          values(
		 move_tran_rec.organization_id,
		 move_tran_rec.department_id,
		 move_tran_rec.wip_entity_id,
		 move_tran_rec.op,
		 move_qty,
		 scrap_qty,
		 reject_qty,
		 move_tran_rec.shift_id,
		 move_tran_rec.primary_uom_code,
		 move_tran_rec.op_lead_time
		);


	End loop;
*/
	wip_ws_util.trace_log(' After loop');
	l_stmt_no := 120;

	-- aggregate the temp data and insert to the actual table
	insert into wip_ws_ptpkpi_actual(
		organization_id,
		department_id,
		wip_entity_id,
		shift_id,
		operation_seq_num,
		moved_qty,
		scrapped_qty,
		rejected_qty,
		primary_uom_code,
		op_lead_time,
		shift_start_time,
		concurrent_request_id,
		last_update_date,
		last_update_by,
		creation_date,
		created_by)
	select
	  organization_id,
	  department_id,
	  wip_entity_id,
	  shift_id,
	  operation_seq_num,
	  sum(nvl(move_qty,0)) ,
	  sum(nvl(scrap_qty,0)) ,
	  sum(nvl(reject_qty,0)),
	  t.primary_uom_code,
	  t.op_lead_time,
	  WIP_WS_PTPKPI_UTIL.get_datetime_for_shift(p_org_id,shift_id,1),
	  fnd_global.CONC_REQUEST_ID,
          sysdate,
          g_user_id,
          sysdate,
          g_user_id
	from wip_ws_ptp_gt t
	group by
	  organization_id,department_id,wip_entity_id,operation_seq_num,shift_id,primary_uom_code,
	  op_lead_time;

EXCEPTION
     when FND_API.G_EXC_UNEXPECTED_ERROR then
               wip_ws_util.trace_log('Error message = '||sqlerrm);
	       wip_ws_util.trace_log(' Statement no '||l_stmt_no);
		wip_ws_util.trace_log('Came to unexpected error in populate_actual_data');
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     when FND_API.G_EXC_ERROR then
		wip_ws_util.trace_log('Came to expected error in populate_actual_data');
	       wip_ws_util.trace_log(' Statement no '||l_stmt_no);
		x_return_status := FND_API.G_RET_STS_ERROR;
     when others then
                wip_ws_util.trace_log('Error message = '||sqlerrm);
		wip_ws_util.trace_log('Came to others error in populate_actual_data');
	        wip_ws_util.trace_log(' Statement no '||l_stmt_no);
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
End populate_actual_data;





END WIP_WS_PTPKPI_PK;

/
