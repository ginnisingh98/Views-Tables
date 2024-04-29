--------------------------------------------------------
--  DDL for Package Body EAM_WO_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_PROCESSOR" AS
/* $Header: EAMWOPRB.pls 115.16 2002/11/20 22:30:12 aan ship $ */

  G_DEBUG boolean := FALSE;

  type jobs_t is record (
    wip_entity_id number,
    status_type    number
  );
  type jobs_table is table of jobs_t  index by binary_integer ;


  -- Private Function
  procedure wo_schedule(
              errbuf            out NOCOPY varchar2,
              retcode           out NOCOPY number,
              p_wip_entity_id   in number,
              p_status_type      in number,
              p_org_id          in number);


  procedure  multi_wo_schedule(
              errbuf            out NOCOPY varchar2,
              retcode           out NOCOPY number,
              p_group_id        in number,
              p_org_id          in number);

  function validate(p_wip_entity_id in number,
                           p_org_id        in number,
			   p_status_type    in number) return boolean;
  function finite_scheduler(p_wip_entity_id in number,
                            p_org_id        in number) return number;
  function change_status_type(p_wip_entity_id in number,
                           p_org_id        in number,
			   p_status_type    in number) return boolean;
  procedure error_status(p_wip_entity_id in number,
                            p_org_id        in number);
  procedure wait_conc_program(p_request_id in number,
			   errbuf       out NOCOPY varchar2,
                           retcode      out NOCOPY number);
  function populate_jobs(p_group_id number) return jobs_table;
  function mass_load(p_group_id 	in number,
                     p_org_id        	in number) return number;



  -- The processor handles single and multiple work order processing
  -- 1. Single Work Order processing
  --    Takes argument p_wip_entity_id,p_status_type,p_org_id
  --    It calls WPS engine for finite scheduling and change the job status
  --    from 'Pending Scheduling' to 'Unreleased','Released', or 'Hold'.
  --    The status will be set to 'Not Ready' if the processing fails.
  -- 2. Multiple Work Order processing.
  --    Takes argument p_group_id, p_org_id
  --    p_group_id is the group id to be used for Mass Load to takes
  --    rows for WIP_JOB_SCHEDULE_INTERFACE for processing.
  --    It calls Mass Load for scheduling and change the job status
  --    from 'Pending Scheduling' to 'Unreleased','Released', or 'Hold'.
  --    The status will be set to 'Not Ready' if the processing fails.

  procedure schedule(
              errbuf            out NOCOPY varchar2,
              retcode           out NOCOPY number,
              p_wip_entity_id   in number,
              p_status_type      in number,
              p_group_id        in number,
              p_org_id          in number) is
  begin
    G_DEBUG := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';
    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Setting debug to Y');
    else
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Setting debug to N');
    end if;

    if (p_wip_entity_id <> -1 and p_status_type <> -1) then
      wo_schedule(errbuf,retcode,p_wip_entity_id,p_status_type,p_org_id);
    elsif (p_group_id <> -1) then
      multi_wo_schedule(errbuf,retcode,p_group_id,p_org_id);
    else
      retcode := G_ERROR;
      fnd_message.set_name('EAM','EAM_WO_PROC_VALIDATE');
      errbuf := fnd_message.get;
    end if;
  end;


  -- Procedure to process single work order
  procedure wo_schedule(
              errbuf       	out NOCOPY varchar2,
              retcode      	out NOCOPY number,
              p_wip_entity_id   in number,
              p_status_type      in number,
              p_org_id          in number) is
    l_request_id number;
  begin
    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing for work order : '||p_wip_entity_id);
    end if;

    -- Validate the work order status
    if (not validate(p_wip_entity_id,p_org_id,p_status_type)) then
      retcode := G_ERROR;
      fnd_message.set_name('EAM','EAM_WO_PROC_VALIDATE');
      errbuf := fnd_message.get;
      return;
    end if;
    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Completes Validation');
    end if;

    -- Call WPS engine
    l_request_id := finite_scheduler(p_wip_entity_id,p_org_id);
    if (l_request_id = 0) then
      retcode := G_ERROR;
      fnd_message.set_name('EAM','EAM_WO_PROC_FAIL_WPS');
      errbuf := fnd_message.get;
      return;
    end if;
    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Request ID for WPS : '||l_request_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'committing...');
    end if;




    commit;

    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'committed.');
    end if;

    -- Wait until the WPS conc. program finishes
    wait_conc_program(l_request_id,errbuf,retcode);

    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'concurrent program finished.');
    end if;

    if (retcode = G_ERROR) then
      if G_DEBUG then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'error.');
      end if;
      error_status(p_wip_entity_id,p_org_id);
      errbuf := fnd_message.get;
      commit;
      if G_DEBUG then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'error, committed.');
      end if;
      return;
    end if;
    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'WPS finish up successfully');
    end if;

    -- Changing the job status after scheduling
    if (not change_status_type(p_wip_entity_id,p_org_id,p_status_type)) then
      retcode := G_ERROR;
      fnd_message.set_name('EAM','EAM_WO_PROC_FAIL_STATUS');
      errbuf := fnd_message.get;
      return;
    end if;
    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Processor finishes up successfully');
    end if;

    commit;
  end;

  -- Procedure to process multiple work order
  procedure multi_wo_schedule(
              errbuf       	out NOCOPY varchar2,
              retcode      	out NOCOPY number,
              p_group_id        in number,
              p_org_id          in number) is
    l_jobs jobs_table;
    l_index number;
    l_request_id number;
    l_err_cnt number;
    l_dummy boolean;
  begin
    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing for multi work order with group id : '||p_group_id);
    end if;

    -- Put the job in the table
    l_jobs := populate_jobs(p_group_id);
    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Number of work order to be processed : '||l_jobs.count);
    end if;

    if (l_jobs.count = 0) then
      return;
    end if;

    -- Validate the job
    l_index := l_jobs.first;
    loop
      if G_DEBUG then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Validating work order : '||l_jobs(l_index).wip_entity_id);
      end if;
      if (not validate(l_jobs(l_index).wip_entity_id,p_org_id,l_jobs(l_index).status_type)) then
        retcode := G_ERROR;
        fnd_message.set_name('EAM','EAM_WO_PROC_VALIDATE');
        errbuf := fnd_message.get;
        return;
      end if;
      exit when l_index =  l_jobs.last;
      l_index := l_jobs.next(l_index);
    end loop;
    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Completes validating all work orders');
    end if;


    -- Call WIP mass Load
    l_request_id := mass_load(p_group_id,p_org_id);
    if (l_request_id = 0) then
      retcode := G_ERROR;
      fnd_message.set_name('EAM','EAM_WO_PROC_FAIL_MASS_LOAD');
      errbuf := fnd_message.get;
      return;
    end if;
    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Calling Mass Load with request id : '||l_request_id);
    end if;

    -- Wait until the WIP mass Load conc. program finishes
    wait_conc_program(l_request_id,errbuf,retcode);
    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Concurrent Program returns with status : '||retcode);
    end if;
    if (retcode = G_ERROR) then
      if G_DEBUG then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Mass Load completes with error');
      end if;
      errbuf := fnd_message.get;
      return;
    end if;

    if (retcode = G_SUCCESS) then
      if G_DEBUG then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Mass Load completes successfully');
      end if;
      return;
    end if;


    if G_DEBUG then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Mass Load completes with warning');
    end if;

    -- Setting the error
    l_index := l_jobs.first;
    loop
      select count(*)
      into l_err_cnt
      from wip_job_schedule_interface
      where wip_entity_id = l_jobs(l_index).wip_entity_id
        and group_id = p_group_id
        and process_status <> WIP_CONSTANTS.COMPLETED;

      if (l_err_cnt <> 0) then
        error_status(l_jobs(l_index).wip_entity_id,p_org_id);
        if G_DEBUG then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in work order '||l_jobs(l_index).wip_entity_id);
        end if;
      end if;
      exit when l_index =  l_jobs.last;
      l_index := l_jobs.next(l_index);
    end loop;

    commit;
  end;


  -- Function to validate :
  -- 1. The current job status is 'Pending Scheduling'
  -- 2. The destination status is either
  --    'Unreleased', 'Released', or 'Hold'
  function validate(p_wip_entity_id in number,
                           p_org_id        in number,
                           p_status_type    in number) return boolean is
    l_cnt number;
  begin

    select count(*)
    into l_cnt
    from wip_discrete_jobs
    where wip_entity_id = p_wip_entity_id
      and organization_id = p_org_id
      and status_type = WIP_CONSTANTS.PEND_SCHED;

    if (l_cnt = 0) then
      return false;
    end if;


    if (p_status_type not in (WIP_CONSTANTS.UNRELEASED,WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.HOLD) ) then
      return false;
    end if;

    return true;
  end;

  -- Function to change the work order status and
  -- perform release or hold process.
  function change_status_type(p_wip_entity_id in number,
                         p_org_id        in number,
                         p_status_type    in number) return boolean is
    l_class_code varchar2(10);
    l_routing_exists number;
  begin

    -- Change the status to the UNRELEASED
    update wip_discrete_jobs
    set status_type = WIP_CONSTANTS.UNRELEASED
    where wip_entity_id = p_wip_entity_id
      and organization_id = p_org_id;

    if (p_status_type = WIP_CONSTANTS.RELEASED) then
      select class_code
      into l_class_code
      from wip_discrete_jobs
      where wip_entity_id = p_wip_entity_id
        and organization_id = p_org_id;

      wip_change_status.release(p_wip_entity_id,p_org_id,NULL,NULL,l_class_code,
                                WIP_CONSTANTS.PEND_SCHED,WIP_CONSTANTS.RELEASED,
                                l_routing_exists);
    elsif (p_status_type = WIP_CONSTANTS.HOLD) then
      wip_change_status.put_job_on_hold(p_wip_entity_id,p_org_id);
    end if;

    -- Change the status to the new intended status
    update wip_discrete_jobs
    set status_type = p_status_type
    where wip_entity_id = p_wip_entity_id
      and organization_id = p_org_id;

    return true;
  end;

  -- Procedure to set the Work Order status to 'Not ready'
  procedure error_status(p_wip_entity_id in number,
                            p_org_id        in number) is
  begin
    update wip_discrete_jobs
    set status_type = WIP_CONSTANTS.DRAFT,
	date_released = NULL
    where wip_entity_id = p_wip_entity_id
      and organization_id = p_org_id;
--    commit;
  end;

  -- Function to invoke WPS finite scheduler.
  function finite_scheduler(p_wip_entity_id in number,
                            p_org_id        in number) return number is
    l_request_id number := 0;
    l_direction number := NULL;
    l_wip_entity_id number := NULL;
    l_req_start_date date := NULL;
    l_req_due_date date := NULL;
    l_horizon_start date := NULL;
    l_material_constrained number := NULL;
    l_horizon_length number := NULL;
    l_use_finite_scheduler number := NULL;

  begin
    wps_common.GetParameters(P_Org_Id  		    => p_org_id,
			     X_Use_Finite_Scheduler => l_use_finite_scheduler,
			     X_Material_Constrained => l_material_constrained,
			     X_Horizon_Length	    => l_horizon_length);

    select requested_start_date,due_date
    into l_req_start_date,l_req_due_date
    from wip_discrete_jobs
    where wip_entity_id = p_wip_entity_id
      and organization_id = p_org_id;

    if (l_req_start_date is not null) then
      l_horizon_start := l_req_start_date;
      l_direction := WIP_CONSTANTS.WPS_FORWARD_SCHEDULE;
    else
      l_horizon_start := sysdate;
      l_direction := WIP_CONSTANTS.WPS_BACKWARD_SCHEDULE;
    end if;

    l_request_id := FND_REQUEST.SUBMIT_REQUEST('WPS',
                                                 'WPCWFS',
                                                 '',
                                                 '',
                                                 FALSE,
                                                 to_char(p_org_id),
                                                 '1',				-- scheduling mode
                                                 to_char(NVL(p_wip_entity_id,-1)),
                                                 to_char(l_direction),
                                                 '-1',				-- midpoint_op
                                                 Nvl(fnd_number.number_to_canonical(wip_datetimes.dt_to_float(l_req_start_date)),
                                                     '-1'),
                                                 Nvl(fnd_number.number_to_canonical(wip_datetimes.dt_to_float(l_req_due_date)),
                                                     '-1'),
                                                 to_char(Nvl(wip_datetimes.dt_to_float(l_horizon_start),-1)),
                                                 to_char(l_horizon_length),
                                                 '1',				-- res_constrained
                                                 to_char(l_material_constrained),
                                                 '0','','','','','1','-1','-1','6',
                                                 chr(0),
                                                 '','','','','','','','','','','','','','','','',
                                                 '','','','','','','','','','','','','','','','','','','','',
                                                 '','','','','','','','','','','','','','','','','','','','',
                                                 '','','','','','','','','','','','','','','','','','','','',
                                                 '','','');

    return l_request_id;
  end;


  -- Procedure to wait conc. program.
  -- It will return only after the conc. program completes
  procedure wait_conc_program(p_request_id in number,
			   errbuf       out NOCOPY varchar2,
                           retcode      out NOCOPY number) is
    l_call_status      boolean;
    l_phase            varchar2(80);
    l_status           varchar2(80);
    l_dev_phase        varchar2(80);
    l_dev_status       varchar2(80);
    l_message          varchar2(240);

    l_counter	       number := 0;
  begin
    loop
      l_call_status:= FND_CONCURRENT.WAIT_FOR_REQUEST
                    ( p_request_id,
                      10,
                      300,
                      l_phase,
                      l_status,
                      l_dev_phase,
                      l_dev_status,
                      l_message);
      exit when l_call_status=false;

      if (l_dev_phase='COMPLETE') then
        if (l_dev_status = 'NORMAL') then
          retcode := G_SUCCESS;
        elsif (l_dev_status = 'WARNING') then
          retcode := G_WARNING;
        else
          retcode := G_ERROR;
        end if;
        errbuf := l_message;
        return;
      end if;

      l_counter := l_counter + 1;
      exit when l_counter >= 2;

    end loop;

    retcode := G_ERROR;
    return ;
  end;

  -- Fucntion to populate PL/SQL table from WIP_JOB_SCHEDULE_INTERFACE
  function populate_jobs(p_group_id number) return jobs_table is
    l_jobs jobs_table;
    cursor job_cursor is
      select wip_entity_id,status_type
      from wip_job_schedule_interface
      where group_id = p_group_id;
    l_index number := 0;
  begin
    for job_cursor_record in job_cursor loop
      l_index := l_index + 1;
      l_jobs(l_index).wip_entity_id := job_cursor_record.wip_entity_id;
      l_jobs(l_index).status_type := job_cursor_record.status_type;
    end loop;

    return l_jobs;
  end;

  -- Function to invoke Mass Load
  function mass_load(p_group_id 	in number,
                     p_org_id        	in number) return number is
    l_req_id number;
  begin

    l_req_id := fnd_request.submit_request(
        'WIP', 'WICMLP', NULL, NULL, FALSE,
        to_char(p_group_id), '0', '2');
    commit;
    return l_req_id;

  end;

END eam_wo_processor;

/
