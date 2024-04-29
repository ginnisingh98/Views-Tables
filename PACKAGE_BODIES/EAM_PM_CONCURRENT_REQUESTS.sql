--------------------------------------------------------
--  DDL for Package Body EAM_PM_CONCURRENT_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PM_CONCURRENT_REQUESTS" AS
/* $Header: EAMPMCRB.pls 120.2 2006/03/16 02:33:03 kmurthy noship $ */

  procedure generate_pm_schedules(
              errbuf           out NOCOPY varchar2,
              retcode          out NOCOPY varchar2,
              p_start_date     in varchar2,
              p_end_date       in varchar2,
              p_org_id         in number,
              p_user_id        in number,
              p_location_id    in number,
              p_category_structure_id    in number,
              p_category_id    in number,
              p_owning_dept_id in number,
              p_item_type_name in varchar2,
              p_item_type in number,
              p_inventory_item_name in varchar2,
              p_asset_group_id in number,
              p_asset_number   in varchar2,
	      p_set_name       in varchar2,
 	      p_set_name_id    in number,
	      p_view_only      in number,
              p_project_number  in varchar2,
              p_project_id      in number,
              p_task_number     in varchar2,
              p_task_id         in number,
              p_parent_wo       in varchar2,
              p_parent_wo_id    in number) is
    x_group_id number;
    x_req_id   number;
    x_count number := null;
    x_return_status varchar2(1);
    x_msg varchar2(3000);
    x_forecast_id number;
    l_project_control_level number;
    proj_val exception;

    cursor sugg_c is
    select pm_forecast_id
    from eam_forecasted_work_orders
    where group_id = x_group_id;

  begin

--Validation for Project

if p_project_id is not null OR 	p_project_number is not null then
	select project_control_level into l_project_control_level
	from pjm_org_parameters where organization_id = p_org_id;

	if l_project_control_level = 2 then
		-- project control is at task level
		-- task is mandatory
		if p_task_number is null AND p_task_id is null then
			--FND_MESSAGE.SET_NAME ('EAM', 'EAM_PROJ_TSK_REQD');
			--FND_MSG_PUB.ADD;
			--RAISE FND_API.G_EXC_ERROR;
			RAISE proj_val;
		end if;
	end if;
end if;


    retcode := '0';

    select wip_job_schedule_interface_s.nextval
      into x_group_id
      from dual;

    eam_pm_engine.run_pm_scheduler(1, -- create mode
                                   'N', -- excludes non scheduled pm
                                   fnd_date.canonical_to_date(p_start_date),
                                   fnd_date.canonical_to_date(p_end_date),
                                   x_group_id,
                                   p_org_id,
                                   p_user_id,
                                   p_location_id,
                                   p_category_id,
                                   p_owning_dept_id,
                                   p_item_type,
                                   p_asset_group_id,
                                   p_asset_number,
				   p_set_name_id );

    --added for p_view_only, if it is yes, then don't perform the real action
    --1 is Yes
    if ( p_view_only = 1) then
       return;
    end if;

    open sugg_c;
    fetch sugg_c into x_forecast_id;
    if ( sugg_c%NOTFOUND ) then
      close sugg_c;
      return;
    end if;

    LOOP
      eam_wb_utils.add_forecast(x_forecast_id);
      fetch sugg_c into x_forecast_id;
      EXIT WHEN ( sugg_c%NOTFOUND );
    END LOOP;
    close sugg_c;


     eam_wb_utils.convert_work_orders2(x_group_id,
                                      p_project_id, p_task_id, p_parent_wo_id,
                                      x_return_status, x_msg);
    commit;

  exception
	when proj_val then
	    retcode := '2';
	    errbuf := 'Specified project has control at task level. The task is required for further processing.';
	    fnd_file.put_line(FND_FILE.LOG, 'Exception: ' || errbuf);
	when others then
	    retcode := '2';
	    errbuf := 'PM Schedule Engine: ORA-' || -sqlcode;
	    fnd_file.put_line(FND_FILE.LOG, 'Exception' || errbuf);
  end generate_pm_schedules;


  procedure convert_forecast_work_orders(
              errbuf           out NOCOPY varchar2,
              retcode          out NOCOPY varchar2,
              p_group_id       in number) is
    x_count number;
    x_req_id number;
  begin
    eam_pm_utils.transfer_to_wdj(p_group_id);

    select count(*) into x_count
      from wip_job_schedule_interface
     where group_id = p_group_id;

    if ( x_count > 0 ) then
      x_req_id := fnd_request.submit_request(
        'WIP', 'WICMLP', NULL, NULL, FALSE,
        to_char(p_group_id), '0', '2');

      commit;

      if ( x_req_id = 0 ) then
        retcode := '2';
        errbuf := 'Unexpected error when submitting wip mass load concurrent request';
      end if;
    end if;
  exception when others then
    retcode := '2';
    errbuf := 'Converting Forecasted Work Orders: ORA-' || -sqlcode;
  end convert_forecast_work_orders;

END eam_pm_concurrent_requests;


/
