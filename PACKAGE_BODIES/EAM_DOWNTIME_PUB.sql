--------------------------------------------------------
--  DDL for Package Body EAM_DOWNTIME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_DOWNTIME_PUB" as
/* $Header: EAMPEQDB.pls 120.2 2006/01/19 18:48:17 hkarmach noship $ */

G_PKG_NAME   CONSTANT   VARCHAR2(30) := 'EAM_Downtime_PUB';
G_DEBUG VARCHAR2(1) := NVL(fnd_profile.value('EAM_DEBUG'), 'N');
g_reason_code varchar2(80):=null;


PROCEDURE WriteLog (p_api_version       IN   NUMBER,
                    p_msg_count         IN   NUMBER,
                    p_msg_data          IN   VARCHAR2,
                    x_return_status     OUT  NOCOPY VARCHAR2);

PROCEDURE Load_Downtime(
         p_api_version        IN NUMBER,
         x_return_status      OUT NOCOPY VARCHAR2,
         x_msg_count          OUT NOCOPY NUMBER,
         x_msg_data           OUT NOCOPY VARCHAR2,
         p_downtime_group_id  IN NUMBER,
         p_org_id             IN NUMBER,
         p_simulation_set     IN VARCHAR2,
         p_include_unreleased IN NUMBER,
         p_firm_order_only    IN NUMBER,
         p_department_id      IN NUMBER,
         p_resource_id        IN NUMBER,
         p_calendar_code      IN VARCHAR2,
         p_exception_set_id   IN NUMBER,
         p_user_id            IN NUMBER,
         p_request_id         IN NUMBER,
         p_prog_id            IN NUMBER,
         p_prog_app_id        IN NUMBER,
         p_login_id           IN NUMBER);

PROCEDURE Purge_Downtime(
   p_api_version        IN NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_org_id             IN NUMBER,
   p_simulation_set     IN VARCHAR2);
--A global cursor that has one row for a downtime caused by wo or operations

   cursor downtime_csr(p_org_id number,
                       p_department_id number,
                       p_resource_id number,
                       p_include_unreleased number, p_firm_order_only
                       number)
                         is

	 SELECT distinct wdj.organization_id maint_org_id, wdj.wip_entity_id wip_entity_id,
	        cii.inventory_item_id asset_group_id, cii.instance_number asset_number,
 	        decode (wdj.shutdown_type, 2, to_number(NULL), 3, to_number(NULL), wo.operation_seq_num  ) op_seq,
		decode (wdj.shutdown_type, 2, wdj.scheduled_start_date, 3, wdj.scheduled_start_date, wo.first_unit_start_date  ) from_date,
                decode (wdj.shutdown_type, 2, wdj.scheduled_completion_date, 3, wdj.scheduled_completion_date, wo.last_unit_completion_date ) to_date,
		decode (wdj.shutdown_type, 2, wdj.shutdown_type, 3, wdj.shutdown_type, wo.shutdown_type ) shutdown_type,
		wdj.firm_planned_flag, msn.current_organization_id prod_org_id, msn.inventory_item_id equipment_item_id,
 	        msn.serial_number eqp_serial_number, bdri.department_id, bre.resource_id, bre.instance_id,
		1 as downtime_source_code
 	 FROM  wip_discrete_jobs wdj,
 	       wip_entities we,
 	       mtl_serial_numbers msn,
 	       csi_item_instances cii,
 	       mtl_parameters mp,
 	       bom_resource_equipments bre,
 	       bom_dept_res_instances bdri,
	       wip_operations wo
 	 WHERE
 	 ( ( p_resource_id IS NULL)      OR
	   ( p_resource_id IS NOT NULL AND bre.resource_id = p_resource_id) )
 	 AND bre.resource_id = bdri.resource_id
 	 AND (   ( p_department_id IS NULL)     OR
 	         ( p_department_id IS NOT NULL AND bdri.department_id = p_department_id)  )
 	 AND bre.organization_id = msn.current_organization_id
 	 AND cii.network_asset_flag = 'N'
 	 and msn.current_organization_id = p_org_id
 	 and cii.last_vld_organization_id = mp.organization_id
 	 AND bre.inventory_item_id = msn.inventory_item_id
 	 AND bdri.serial_number = msn.serial_number
 	 AND cii.equipment_gen_object_id is not null
 	 AND cii.equipment_gen_object_id = msn.gen_object_id
 	 and wdj.maintenance_object_id = cii.instance_id
 	 AND wdj.maintenance_object_type = 3
 	 AND wdj.organization_id = mp.maint_organization_id
 	 AND we.organization_id = wdj.organization_id
 	 AND we.wip_entity_id = wdj.wip_entity_id
 	 AND we.entity_type = 6
	 AND WDJ.wip_entity_id = WO.wip_entity_id(+)
 	 AND ( (  wdj.shutdown_type in (2,3))
	      OR (NVL(wdj.shutdown_type,0) NOT IN (2,3) AND WO.shutdown_type IN (2,3) AND WDJ.wip_entity_id = WO.wip_entity_id )
	     )
 	 AND ( ( p_include_unreleased = 1  AND wdj.status_type in (1,3))
 	       OR  ( p_include_unreleased <> 1  AND wdj.status_type = 3))
 	 AND ( ( p_firm_order_only = 1  AND wdj.firm_planned_flag = 1)
 	       OR (p_firm_order_only = 2)  )
 	 ORDER BY maint_org_id, asset_group_id,  asset_number, from_date, wip_entity_id, op_seq;


type downtime_tbl_type is table of downtime_csr%rowtype index by binary_integer;


/* ========================================================================== */
-- PROCEDURE
-- Process_Production_Downtime
--
-- Description
-- This procedure is called by the concurrent program Load Production
-- Maintenance Downtime.  The following parameters are passed by the
-- concurrent program:
--    . p_org_id
--         production organization to load maintenance downtime
--    . p_simulation_set
--         simulation set to load capacity reduction caused by downtime
--    . p_run_option
--         1 = load downtime
--         2 = purge all capacity change entries loaded by this process
--    . p_include_unreleased
--         1 (yes) = consider both released and unreleased work orders
--         2 (no)  = consider only released work orders
--    . p_firm_order_only
--         1 = consider only firm work orders
--         2 = consider both firm and non-firm work orders
--    . p_department_id
--         Compute downtime only for equipment instances associated to
--         resources owned by the specified department.
--    . p_resource_id
--         Compute downtime only for equipment instances associated to
--         the specified resource.

/* ========================================================================== */

PROCEDURE Process_Production_Downtime(
        errbuf                     OUT NOCOPY          VARCHAR2,
        retcode                    OUT NOCOPY          NUMBER,
        p_org_id                   IN           NUMBER,
        p_simulation_set           IN           VARCHAR2,
        p_run_option               IN           NUMBER,
        p_include_unreleased       IN           NUMBER,
        p_firm_order_only          IN           NUMBER,
        p_department_id            IN           NUMBER DEFAULT NULL,
        p_resource_id              IN           NUMBER DEFAULT NULL
        )
IS

   l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_msg_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_msg_count                     NUMBER := 0;
   l_msg_data                      VARCHAR2(8000) := '';

   l_err_num                       NUMBER := 0;
   l_err_code                      VARCHAR2(240) := '';
   l_err_msg                       VARCHAR2(240) := '';

   l_stmt_num                      NUMBER := 0;
   l_request_id                    NUMBER := 0;
   l_user_id                       NUMBER := 0;
   l_prog_id                       NUMBER := 0;
   l_prog_app_id                   NUMBER := 0;
   l_login_id                      NUMBER := 0;

   l_conc_program_id               NUMBER := 0;
   conc_status                     BOOLEAN;
   process_error                   EXCEPTION;

   l_downtime_group_id             NUMBER := 0;
   l_exception_set_id              NUMBER;
   l_calendar_code                 VARCHAR2(10);

BEGIN
    -- standard start of API savepoint
    SAVEPOINT ProcessProductionDowntime_PUB;

   ------------------------------------------------------------------
   -- retrieving concurrent program information
   ------------------------------------------------------------------
   l_stmt_num := 5;

   l_request_id       := FND_GLOBAL.conc_request_id;
   l_user_id          := FND_GLOBAL.user_id;
   l_prog_id          := FND_GLOBAL.conc_program_id;
   l_prog_app_id      := FND_GLOBAL.prog_appl_id;
   l_login_id         := FND_GLOBAL.conc_login_id;
   l_conc_program_id  := FND_GLOBAL.conc_program_id;

   l_stmt_num := 10;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'request_id: '
                                   ||to_char(l_request_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'prog_appl_id: '
                                   ||to_char(l_prog_app_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_user_id: '
                                   ||to_char(l_user_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_program_id: '
                                   ||to_char(l_prog_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_login_id: '
                                   ||to_char(l_login_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_conc_program_id: '
                                   ||to_char(l_conc_program_id));


   FND_FILE.PUT_LINE(FND_FILE.LOG, '  ');

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Organization: '
                                   ||TO_CHAR(p_org_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Simulation Set: '
                                   ||p_simulation_set);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Run Option: '
                                   ||TO_CHAR(p_run_option));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Include Unreleased Order: '
                                   ||TO_CHAR(p_include_unreleased));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Firm MaintenanceOder Only: '
                                   ||TO_CHAR(p_firm_order_only));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Department: '
                                   ||TO_CHAR(p_department_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Resource: '
                                   ||TO_CHAR(p_resource_id));



   select calendar_code, calendar_exception_set_id into l_calendar_code, l_exception_set_id
   from mtl_parameters where organization_id=p_org_id;

   l_stmt_num := 15;
   SELECT  bom_resource_downtime_group_s.nextval
      INTO    l_downtime_group_id
      FROM    DUAL;
   if G_DEBUG = 'Y' then
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Downtime Group Id: '
                                   ||TO_CHAR(l_downtime_group_id));
   end if;

   IF p_run_option = 1 THEN
      l_stmt_num := 50;
      Load_Downtime(
         p_api_version        => 1.0,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data           => l_msg_data,
         p_downtime_group_id  => l_downtime_group_id,
         p_org_id             => p_org_id,
         p_simulation_set     => p_simulation_set,
         p_include_unreleased => p_include_unreleased,
         p_firm_order_only    => p_firm_order_only,
         p_department_id      => p_department_id,
         p_resource_id        => p_resource_id,
         p_calendar_code      => l_calendar_code,
         p_exception_set_id   => l_exception_set_id,
         p_user_id            => l_user_id,
         p_request_id         => l_request_id,
         p_prog_id            => l_prog_id,
         p_prog_app_id        => l_prog_app_id,
         p_login_id           => l_login_id
      );
   ELSE
      l_stmt_num := 60;
      Purge_Downtime(
         p_api_version    => 1.0,
         x_return_status  => l_return_status,
         x_msg_count      => l_msg_count,
         x_msg_data       => l_msg_data,
         p_org_id         => p_org_id,
         p_simulation_set => p_simulation_set
         );
   END IF;

   IF l_return_status <> FND_API.g_ret_sts_success THEN
      WriteLog(
               p_api_version   => 1.0,
               p_msg_count     => l_msg_count,
               p_msg_data      => l_msg_data,
               x_return_status => l_msg_return_status);
      IF p_run_option = 1 THEN
         l_err_code := 'Error: EAM_Downtime_Pub.Load_Downtime()';
      ELSE
         l_err_code := 'Error: EAM_Downtime_Pub.Purge_Downtime()';
      END IF;
      RAISE process_error;
   END IF;

EXCEPTION
   WHEN process_error THEN
       ROLLBACK to ProcessProductionDowntime_PUB;
       l_err_msg :='EAM_Downtime_PUB.Process_Production_Downtime ('
                    || TO_CHAR(l_stmt_num)
                    || '):'
                    || l_err_code;
      FND_FILE.put_line(FND_FILE.log,l_err_msg);

      conc_status := FND_CONCURRENT.set_completion_status('ERROR', l_err_msg);

   WHEN OTHERS THEN
      ROLLBACK to ProcessProductionDowntime_PUB;
      l_err_num := SQLCODE;
      l_err_code := NULL;
      l_err_msg := SUBSTR('EAM_Downtime_PUB.Process_Production_Downtime ('
                   || TO_CHAR(l_stmt_num)
                   || '):'
                   || SQLERRM,1,240);
      FND_FILE.put_line(FND_FILE.log,l_err_msg);

      conc_status := FND_CONCURRENT.set_completion_status('ERROR', l_err_msg);

END Process_Production_Downtime;

procedure print_downtime(p_prompt in varchar2,
                    p_downtime in downtime_csr%rowtype) is
begin
   IF G_DEBUG = 'Y' THEN
         fnd_file.put_line(fnd_file.log, p_prompt||p_downtime.maint_org_id
	     || 'wip_entity_id:' ||p_downtime.wip_entity_id
	     || 'asset_group_id:' || p_downtime.asset_group_id
	     ||'asset_number:'||p_downtime.asset_number
	     ||'op_seq:'||p_downtime.op_seq
	     ||'from_date:'||p_downtime.from_date
	     ||'to_date:'||p_downtime.to_date);
    end if;

end print_downtime;
function is_overlap(p_from_date in  date,
                p_from_time in number,
                p_to_date in date,
			    p_to_time in number,
			    p_calendar_code in varchar2,
			    p_shift_num in number) return boolean is
    l_count number;
    l_from_time number;
    l_to_time number;
    i number;

begin
	--logic to see if p_from_tim, p_to_time overlaps with bom_shift_times
    /* i := 0;
    for a_shift_time in (select from_time, to_time from bom_shift_times
                       where calendar_code=p_calendar_code and shift_num=p_shift_num) loop
        i := i+1;
        if (i = 1) then
           l_from_time := a_shift_time.from_time;
        end if;
        l_to_time := a_shift_time.to_time;
    end loop; */
    -- a shift could have multiple stretches of time

    select min(from_time), max(to_time) into l_from_time, l_to_time
    from bom_shift_times
    where calendar_code = p_calendar_code and shift_num = p_shift_num;

   IF G_DEBUG = 'Y' THEN
       fnd_file.put_line(fnd_file.log, 'Check if downtime overlaps shifts:p_from_date'||p_from_date||'p_from_time'||p_from_time||
                        'p_to_date:'||p_to_date||'p_to_time:'||p_to_time||'p_shift_num:'||p_shift_num||'l_from_time:'||l_from_time||
                        'lto_time:'||l_to_time);
   end if;

   -- if downtime spans across days
   if p_to_date > p_from_date then
        select count(shift_date) into l_count
        from bom_shift_dates
        where
            trunc(shift_date) > trunc(p_from_date)
            and trunc(shift_date) < trunc(p_to_date)
            and seq_num is not null
            and calendar_code = p_calendar_code and shift_num = p_shift_num;

       -- if there are shifts for sure (more than 24 hr.) in between the down time start and to dates
       if ((l_count > 0) or (p_to_time > p_from_time)) then
            return true;
       else
           --p_to_time := p_to_time+86400; -- add one day to p_to_time

           -- As long as the shift starts or ends in between the downtime
           -- start and to dates, there is overlap.
           if (l_from_time > p_from_time) or (l_from_time < p_to_time) or
              (l_to_time > p_from_time) or (l_to_time < p_to_time) then
              return true;
           end if;
       end if;

  -- if downtime starts and ends on the same day
   elsif p_to_date = p_from_date then

        if (l_to_time < l_from_time) then
            if (l_from_time < p_to_time) or (l_to_time > p_from_time) then
                return true;
            end if;
        else
  	    -- Bug # 4190920 : Need to corret the logic for overlap
            if (p_from_time < l_to_time and l_from_time < p_to_time) then
                return true;
            end if;
        end if;
   end if;

   return false;
end is_overlap;

-- Assume in_table is sorted on from_date, and out_table is empty
procedure merge_table(in_table IN downtime_tbl_type,
                      num_recs IN NUMBER,
                      out_table OUT NOCOPY downtime_tbl_type
) IS
    i	number;
    j   number;
BEGIN
    i := 0;
    j := 0;

	while i < num_recs loop
        -- base case

        if (i = 0) then
            out_table(0) := in_table(0);
        else

            if(in_table(i).from_date > out_table(j).to_date) then
                -- non overlapping interval
                --dbms_output.put_line('new interval');
                j := j+1;
                out_table(j) := in_table(i);
            elsif(in_table(i).to_date > out_table(j).to_date) then
                -- need to stretch the current interval
                -- dbms_output.put_line('stretch');
                out_table(j).op_seq := null;

                -- if the two rows are from different wo
                if in_table(i).wip_entity_id <> out_table(j).wip_entity_id then
                    out_table(j).downtime_source_code := 2;
                -- else if it wasn't already 2, set it to 3
                -- 3 means operations within the same wo
                elsif out_table(j).downtime_source_code <> 2 then
                    out_table(j).downtime_source_code := 3;
                end if;

                out_table(j).to_date := in_table(i).to_date;
            else
                -- new interval contained in the current interval, ignore
        		out_table(j).op_seq := null;

                -- if the two rows are from different wo
                if in_table(i).wip_entity_id <> out_table(j).wip_entity_id then
                    out_table(j).downtime_source_code := 2;
                -- else if it wasn't already 2, set it to 3
                -- 3 means operations within the same wo
                elsif out_table(j).downtime_source_code <> 2 then
                    out_table(j).downtime_source_code := 3;
                end if;
            end if;
        end if;

        i := i+1;
    end loop;
end merge_table;


/* Added for bug 3787120
  -> This procedure is called before inserting into the table BOM_RES_INSTANCE_CHANGES
  -> Check for the date/time range overlap with the existing record in BOM_RES_INSTANCE_CHANGES
  -> If overlapping occurs then TRUE is returned. And if there is need for updating the record
     then parameter p_out_to_update is updated to true.
  -> If no overlapping, then FALSE is returned.
*/

Function check_existence(p_downtime_row        IN downtime_csr%ROWTYPE,
                         p_shift_num           IN number,
                         p_simulation_set      IN varchar2,
                         p_from_date           IN date,
                         p_from_time           IN number,
                         p_to_date             IN date,
                         p_to_time             IN number,
                         p_action_type         IN number,
                         p_out_from_date       OUT NOCOPY date,
                         p_out_from_time       OUT NOCOPY number,
                         p_out_to_date         OUT NOCOPY date,
                         p_out_to_time         OUT NOCOPY number,
                         p_out_from_date_old   OUT NOCOPY date,
                         p_out_from_time_old   OUT NOCOPY number,
                         p_out_to_date_old     OUT NOCOPY date,
                         p_out_to_time_old     OUT NOCOPY number,
                         p_out_to_update       OUT NOCOPY boolean) return boolean is
l_from_date_old date;
l_to_date_old date;
l_from_date_new date;
l_to_date_new date;
begin
        IF G_DEBUG = 'Y' THEN
                fnd_file.put_line(fnd_file.log,'In check_existence');
        end if;

        p_out_to_update         := FALSE;

        -- Assign the New Date time range values
	l_from_date_new := trunc(p_from_date) + p_from_time / 86400 ;
	l_to_date_new   := trunc(p_to_date) + p_to_time / 86400;

        --Check if  new record's date/time range clashes with that of the old record
        select from_date, from_time, to_date, to_time
        into p_out_from_date_old, p_out_from_time_old, p_out_to_date_old, p_out_to_time_old
        from bom_res_instance_changes
        where department_id     = p_downtime_row.department_id
        and resource_id         = p_downtime_row.resource_id
        and shift_num           = p_shift_num
        and simulation_set      = p_simulation_set
        and instance_id         = p_downtime_row.instance_id
        and serial_number       = p_downtime_row.eqp_serial_number
        and action_type         = p_action_type
        and ( ( (trunc(from_date)+(from_time/86400))
                between l_from_date_new and l_to_date_new)
              or
              (( trunc(to_date)+(to_time/86400))
                between l_from_date_new and l_to_date_new)
              or
              ( l_from_date_new between
                      (trunc(from_date)+(from_time/86400))
                      and
                      (trunc(to_date)+(to_time/86400)))
              or
              (l_to_date_new between
               (trunc(from_date)+(from_time/86400))
               and
               (trunc(to_date)+(to_time/86400))));

        IF G_DEBUG = 'Y' THEN
                fnd_file.put_line(fnd_file.log,'EXISTS');
        end if;

        p_out_from_date        := p_out_from_date_old;
        p_out_from_time        := p_out_from_time_old;
        p_out_to_date          := p_out_to_date_old;
        p_out_to_time          := p_out_to_time_old;

        -- Assign data time range values as stored in database.
        l_from_date_old := trunc(p_out_from_date_old)+(p_out_from_time_old/86400);
        l_to_date_old   := trunc(p_out_to_date_old)+(p_out_to_time_old/86400);

        -- Check if new date time range is same as that stored in database.
	if (l_from_date_new = l_from_date_old and l_to_date_new = l_to_date_old) then
	        -- Both data time range is same.
		-- hence no update and no insert is required.
                p_out_to_update := FALSE;  --to be skipped
                IF G_DEBUG = 'Y' THEN
                        fnd_file.put_line(fnd_file.log,'to be SKIPPED');
                end if;
                return TRUE;
        end if;

	-- Find new values for time range to be updated in database.

        if ( l_from_date_new < l_from_date_old ) then
                p_out_from_date := p_from_date;
                p_out_from_time := p_from_time;
                p_out_to_update := TRUE;
                IF G_DEBUG = 'Y' THEN
                        fnd_file.put_line(fnd_file.log,'Old from date : '||to_char(l_from_date_old,'DD-MON-YYYY HH24:MI:SS'));
                        fnd_file.put_line(fnd_file.log,'New from date : '||to_char(l_from_date_new,'DD-MON-YYYY HH24:MI:SS'));
                end if;

        end if;
        if ( l_to_date_new > l_to_date_old ) then
                p_out_to_date := p_to_date;
                p_out_to_time := p_to_time;
                p_out_to_update := TRUE;
                IF G_DEBUG = 'Y' THEN
                        fnd_file.put_line(fnd_file.log,'Old to date : '||to_char(l_to_date_old,'DD-MON-YYYY HH24:MI:SS'));
                        fnd_file.put_line(fnd_file.log,'New to date : '||to_char(l_to_date_new,'DD-MON-YYYY HH24:MI:SS'));
                end if;

        end if;
        return TRUE;
exception
        when no_data_found then
        IF G_DEBUG = 'Y' THEN
                fnd_file.put_line(fnd_file.log,'In check_existence : DOES NOT EXIST');
        end if;
        p_out_to_update := FALSE;
        return FALSE;
end check_existence;



/*
 * Added the following procedure as a part of bug#3577299
 * Given a from date/time and a to date/time, this procedure breaks
 * up the interval into start and end times based on shifts for the
 * resource/department and inserts into bom_res_instance_changes
 */
procedure break_and_insert (p_from_date         IN DATE,
                            p_from_time         IN NUMBER,
                            p_to_date           IN DATE,
                            p_to_time           IN NUMBER,
                            p_shift_num         IN NUMBER,
                            p_calendar_code     IN VARCHAR2,
                            p_exception_set_id  IN NUMBER,
                            p_simulation_set    IN VARCHAR2,
                            p_downtime_group_id IN NUMBER,
                            p_downtime_row      IN downtime_csr%ROWTYPE) is

-- Bug # 3787120 Modified cursor query
cursor c_wdays is
select bd.shift_date,bt.from_time,bt.to_time
from bom_shift_dates bd,bom_shift_times bt
where trunc(bd.shift_date) >= trunc(p_from_date)
and trunc(bd.shift_date)  <= trunc(p_to_date)
and bd.calendar_code   = p_calendar_code
and bd.shift_num       = p_shift_num
and bd.exception_set_id= p_exception_set_id
and bd.seq_num         is not null
and bt.calendar_code   = bd.calendar_code
and bt.shift_num       = bd.shift_num
order by bd.shift_date,bt.from_time;

cursor c_prior_date(p_curr_date date) is
select decode(nvl(bd.seq_num,-999),-999,bd.prior_date,bd.shift_date)
from bom_shift_dates bd
where trunc(bd.shift_date) = trunc(p_curr_date)-1
and bd.calendar_code       = p_calendar_code
and bd.shift_num           = p_shift_num
and bd.exception_set_id    = p_exception_set_id;

l_shift_from_date date;
l_shift_to_date date;
l_shift_from_time number;
l_shift_to_time number;
l_from_date date;
l_to_date date;
l_from_time number;
l_to_time number;

-- Bug # 3787120 Added new variables.
l_to_insert boolean;
l_out_to_update boolean;

l_out_from_date date;
l_out_from_time number;
l_out_to_date date;
l_out_to_time number;

l_out_from_date_old date;
l_out_from_time_old number;
l_out_to_date_old date;
l_out_to_time_old number;

begin
   IF G_DEBUG = 'Y' THEN
                 fnd_file.put_line(fnd_file.log,'In break_and_insert ');
                 fnd_file.put_line(fnd_file.log,'p_from_date '||p_from_date);
                 fnd_file.put_line(fnd_file.log,'p_from_time '||p_from_time);
                 fnd_file.put_line(fnd_file.log,'p_to_date '||p_to_date);
                 fnd_file.put_line(fnd_file.log,'p_to_time '||p_to_time);
                 fnd_file.put_line(fnd_file.log,'p_shift_num '||p_shift_num);
                 fnd_file.put_line(fnd_file.log,'p_calendar_code '||p_calendar_code);
                 fnd_file.put_line(fnd_file.log,'p_exception_set_id '||p_exception_set_id);
   END IF;

   for wd in c_wdays loop

	-- Bug # 3787120
	if (wd.from_time <=  wd.to_time) then
             l_shift_from_date   := wd.shift_date;
        else
	     -- Shift starts from previous day.
             open c_prior_date(wd.shift_date);
             fetch c_prior_date into l_shift_from_date;
             close c_prior_date;
        end if;

        l_shift_to_date   := wd.shift_date;
        l_shift_from_time := wd.from_time;
        l_shift_to_time   := wd.to_time;

        IF G_DEBUG = 'Y' THEN
             fnd_file.put_line(fnd_file.log,'p_from: '||to_char(p_from_date,'DD-MM-YYYY ')||to_char(to_date(p_from_time,'SSSSS'),'HH24:MI:SS'));
             fnd_file.put_line(fnd_file.log,'l_from: '||to_char(l_shift_from_date,'DD-MM-YYYY ')||to_char(to_date(l_shift_from_time,'SSSSS'),'HH24:MI:SS'));
             fnd_file.put_line(fnd_file.log,'p_to: '||to_char(p_to_date,'DD-MM-YYYY ')||to_char(to_date(p_to_time,'SSSSS'),'HH24:MI:SS'));
             fnd_file.put_line(fnd_file.log,'l_to: '||to_char(l_shift_to_date,'DD-MM-YYYY ')||to_char(to_date(l_shift_to_time,'SSSSS'),'HH24:MI:SS'));
        end if;

	l_to_insert := FALSE;
        l_out_to_update := FALSE;

	-- Check if the date time range is inside the shift of the resource
	if ((to_date(to_char(p_to_date,'DD-MM-YYYY ')||to_char(p_to_time),'DD-MM-YYYY SSSSS') >=
             to_date(to_char(l_shift_from_date,'DD-MM-YYYY ')||to_char(l_shift_from_time),'DD-MM-YYYY SSSSS')) AND
            (to_date(to_char(p_from_date,'DD-MM-YYYY ')||to_char(p_from_time),'DD-MM-YYYY SSSSS') <=
             to_date(to_char(l_shift_to_date,'DD-MM-YYYY ')||to_char(l_shift_to_time),'DD-MM-YYYY SSSSS')))
        then
	    -- Need to insert / update the record

	    -- Update the date time value to fit in the shift timing of the resource
            if (to_date(to_char(p_from_date,'DD-MM-YYYY ')||to_char(p_from_time),'DD-MM-YYYY SSSSS') >
                to_date(to_char(l_shift_from_date,'DD-MM-YYYY ')||to_char(l_shift_from_time),'DD-MM-YYYY SSSSS'))
            then
                 l_from_date := p_from_date;
                 l_from_time := p_from_time;
            else
                 l_from_date := l_shift_from_date;
                 l_from_time := l_shift_from_time;
            end if;

            if (to_date(to_char(p_to_date,'DD-MM-YYYY ')||to_char(p_to_time),'DD-MM-YYYY SSSSS') <
                to_date(to_char(l_shift_to_date,'DD-MM-YYYY ')||to_char(l_shift_to_time),'DD-MM-YYYY SSSSS'))
	    then
                 l_to_date := p_to_date;
                 l_to_time := p_to_time;
            else
                 l_to_date := l_shift_to_date;
                 l_to_time := l_shift_to_time;
            end if;


             -- Bug # 3787120 : Check if the record exists alread
             IF G_DEBUG = 'Y' THEN
                 fnd_file.put_line(fnd_file.log,'Checking existence-'||'dept:'||p_downtime_row.department_id||', resc:'||p_downtime_row.resource_id||
                 ', shift num:'||p_shift_num||', sim set:'||p_simulation_set||', from:'||l_from_date||to_char(to_date(l_from_time,'SSSSS'),' HH24:MI:SS')||
                 ',to '||l_to_date||to_char(to_date(l_to_time,'SSSSS'),' HH24:MI:SS')||', instance id:'||p_downtime_row.instance_id||', serial no:'||p_downtime_row.eqp_serial_number);
             END IF;

	     if ( check_existence(p_downtime_row,
                                  p_shift_num,
                                  p_simulation_set,
                                  l_from_date,
                                  l_from_time,
                                  l_to_date,
                                  l_to_time,
                                  2,
                                  l_out_from_date,
                                  l_out_from_time,
                                  l_out_to_date,
                                  l_out_to_time,
                                  l_out_from_date_old,
                                  l_out_from_time_old,
                                  l_out_to_date_old,
                                  l_out_to_time_old,
                                  l_out_to_update) = TRUE )
	     then
                 l_to_insert := FALSE;
             else
                 -- Record does not exist so insert
		 l_to_insert := TRUE;
             end if;

             if G_DEBUG = 'Y' THEN
                if l_to_insert = TRUE then
                      fnd_file.put_line(fnd_file.log,'To be inserted');
                 end if;
                 if l_out_to_update = TRUE then
                      fnd_file.put_line(fnd_file.log,'To be updated');
                 end if;
             end if;

             if ( l_to_insert = TRUE  and l_out_to_update = FALSE ) then
                if G_DEBUG = 'Y' THEN
                   fnd_file.put_line(fnd_file.log,'Inserting from '||l_from_date||to_char(to_date(l_from_time,'SSSSS'),' HH24:MI:SS')||
                                   ' to '||l_to_date||to_char(to_date(l_to_time,'SSSSS'),' HH24:MI:SS'));
                end if;

                insert into bom_res_instance_changes(
                                  department_id,
                                  resource_id,
                                  shift_num,
                                  simulation_set,
                                  from_date,
                                  from_time,
                                  to_date,
                                  to_time,
                                  instance_id,
                                  serial_number,
                                  action_type,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATED_BY,
                                  CREATION_DATE,
                                  CREATED_BY,
                                  LAST_UPDATE_LOGIN,
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
                                  capacity_change,
                                  reason_code,
                                  downtime_source_code,
                                  maintenance_organization_id,
                                  wip_entity_id,
                                  operation_seq_num,
                                  downtime_group_id,
                                  downtime_negotiable_flag)
                              values(
                                  p_downtime_row.department_id,
                                  p_downtime_row.resource_id,
                                  p_shift_num,
                                  p_simulation_set,
                                  l_from_date,
                                  l_from_time,
                                  l_to_date,
                                  l_to_time,
                                  p_downtime_row.instance_id,
                                  p_downtime_row.eqp_serial_number,
                                  2, --reduce capacity
                                  sysdate,   --standard who
                                  fnd_global.user_id,
                                  sysdate,
                                  fnd_global.user_id,
                                  fnd_global.login_id,
                                  null, null, --descp flex
                                  null, null,
                                  null, null,
                                  null, null,
                                  null, null,
                                  null, null,
                                  null, null,
                                  null, null,
                                  -1, --capacity change
                                  g_reason_code,
                                  p_downtime_row.downtime_source_code,
                                  p_downtime_row.maint_org_id,
                                  p_downtime_row.wip_entity_id,
                                  p_downtime_row.op_seq,
                                  p_downtime_group_id,
                                  p_downtime_row.firm_planned_flag);

             end if;

             if ( l_out_to_update = TRUE and l_to_insert = FALSE ) then
                if G_DEBUG = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,'Updating...');
                end if;

                update bom_res_instance_changes
                                  set from_date    = l_out_from_date,
                                  from_time        = l_out_from_time,
                                  to_date          = l_out_to_date,
                                  to_time          = l_out_to_time
                            where department_id    = p_downtime_row.department_id
                              and resource_id      = p_downtime_row.resource_id
                              and shift_num        = p_shift_num
                              and simulation_set   = p_simulation_set
                              and instance_id      = p_downtime_row.instance_id
                              and serial_number    = p_downtime_row.eqp_serial_number
                              and action_type      = 2
                              and from_date        = l_out_from_date_old
                              and from_time        = l_out_from_time_old
                              and to_date          = l_out_to_date_old
                              and to_time          = l_out_to_time_old;
             end if;

        end if;
   end loop;
end break_and_insert;

procedure process_one_table(p_in_downtime_tbl in downtime_tbl_type,
                          p_in_len in number,
                          p_department_id in number,
                          p_resource_id in number,
                          p_calendar_code in varchar2,
                          p_exception_set_id in number,
                          p_downtime_group_id in  number,
                          p_simulation_set in varchar2) is
    j number;
    l_out_downtime_tbl downtime_tbl_type;
    l_out_len number;
    l_from_date DATE;
    l_to_date DATE;
    l_from_time NUMBER;
    l_to_time NUMBER;

cursor shift_csr(pp_department_id number,
                 pp_resource_id number,
                 pp_from_date date,
                 pp_to_date date) is
        select bsd1.shift_num, bsd1.seq_num start_seq, bsd1.next_date next_date,
               bsd2.seq_num end_seq, bsd2.prior_date prior_date
           from bom_shift_dates bsd1, bom_shift_dates bsd2, bom_resource_shifts brs where
             trunc(bsd1.shift_date) =trunc(pp_from_date)
             and bsd1.calendar_code=p_calendar_code
             and bsd1.exception_set_id=p_exception_set_id
             and bsd1.shift_num=bsd2.shift_num
             and trunc(bsd2.shift_date)=trunc(pp_to_date)
             and bsd2.calendar_code=p_calendar_code
             and bsd2.exception_set_id=p_exception_set_id
             and brs.department_id= pp_department_id
             and brs.resource_id = pp_resource_id
             and brs.shift_num=bsd1.shift_num;

begin

                merge_table(p_in_downtime_tbl, p_in_len, l_out_downtime_tbl);
                --now, processing data
                l_out_len := l_out_downtime_tbl.count;
        IF G_DEBUG = 'Y' THEN
           fnd_file.put_line(fnd_file.log, 'Now:table in_len:'||p_in_len||'table out_len:'||l_out_len);
        end if;
        j := 0;
                while j < l_out_len loop
           print_downtime('out_table row', l_out_downtime_tbl(j));
 IF G_DEBUG = 'Y' THEN
       fnd_file.put_line(fnd_file.log,'p_calendar_code: '||p_calendar_code);
       fnd_file.put_line(fnd_file.log,'p_exception_set_id: '||p_exception_set_id);
       fnd_file.put_line(fnd_file.log,'department_id: '||l_out_downtime_tbl(j).department_id);
       fnd_file.put_line(fnd_file.log,'resource_id: '||l_out_downtime_tbl(j).resource_id);
       fnd_file.put_line(fnd_file.log,'from_date: '||l_out_downtime_tbl(j).from_date);
       fnd_file.put_line(fnd_file.log,'to_date: '||l_out_downtime_tbl(j).to_date);
 end if;
                      for a_shift in shift_csr(l_out_downtime_tbl(j).department_id, l_out_downtime_tbl(j).resource_id,
                                       l_out_downtime_tbl(j).from_date, l_out_downtime_tbl(j).to_date) loop
                 -- start_date
                            -- start_seq is null->off date->move to next date, time=60
                 IF G_DEBUG = 'Y' THEN
                     fnd_file.put_line(fnd_file.log, 'shift_num:'||a_shift.shift_num);
                 end if;
                            if a_shift.start_seq is null then
                       l_from_date := a_shift.next_date;
                       l_from_time := 60;
                              -- on date
                      else
                                    l_from_date := l_out_downtime_tbl(j).from_date;
                                 l_from_time := to_number(to_char(round(l_out_downtime_tbl(j).from_date, 'MI'), 'SSSSS'));
                          end if;
                      -- end_date
                      -- end_seq is null->off date->move to prev date, time=86340
                     if a_shift.end_seq is null then
                             l_to_date := a_shift.prior_date;
                                 l_to_time := 86340;
                             else
                                    l_to_date := l_out_downtime_tbl(j).to_date;
                                   l_to_time := to_number(to_char(round(l_out_downtime_tbl(j).to_date, 'MI'), 'SSSSS'));
                      end if;
                             --Now insert into bric
                  l_from_date := trunc(l_from_date);
                  l_to_date := trunc(l_to_date);
                      if is_overlap(l_from_date,l_from_time, l_to_date, l_to_time, p_calendar_code, a_shift.shift_num)
                      then
                      /* Moved the insert stmt on bom_res_instance_changes
                       * to procedure break_and_insert as part of fix for
                       * bug#3577299
                       */
                              break_and_insert(l_from_date,l_from_time,l_to_date,l_to_time,
                                         a_shift.shift_num,p_calendar_code,
                                         p_exception_set_id,p_simulation_set,
                                         p_downtime_group_id,l_out_downtime_tbl(j));
                              end if; -- if time overlap

                end loop; --cursor shift_csr
                j := j+1;
        end loop; --out table loop
end process_one_table;


----------------------------------------------------------------------------
-- PROCEDURE
--   WriteLog
--
-- DESCRIPTION
--   This API retrieves messages from message stack and write them to log file                                                         --
---------------------------------------------------------------------------
PROCEDURE WriteLog (p_api_version       IN   NUMBER,
                    p_msg_count         IN   NUMBER,
                    p_msg_data          IN   VARCHAR2,
                    x_return_status     OUT NOCOPY  VARCHAR2) IS

    l_api_name    CONSTANT       VARCHAR2(30) := 'WriteLog';
    l_api_version CONSTANT       NUMBER       := 1.0;

    l_msg_count   NUMBER :=0;
    l_msg_data    VARCHAR2(8000):= '';

    l_stmt_num    NUMBER := 0;

BEGIN
    -- standard start of API savepoint
    SAVEPOINT WriteLog_PUB;

    -- standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then
         RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- initialize api return status to success
    x_return_status := FND_API.g_ret_sts_success;

    -- assign to local variables
    l_msg_count := p_msg_count;
    l_msg_data := p_msg_data;

    /* obtain messages from the message list */
    l_stmt_num := 5;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => l_msg_count,
            p_data    => l_msg_data
    );

    /* write all messages in the concurrent manager log */
    l_stmt_num := 10;
    IF(l_msg_count > 0) THEN
            FOR i in 1 ..l_msg_count
            LOOP
               l_msg_data := FND_MSG_PUB.get(i, FND_API.g_false);
               FND_FILE.put_line(FND_FILE.log, i ||'-'||l_msg_data);
            END LOOP;
    END IF;

 EXCEPTION
    WHEN FND_API.g_exc_error THEN
       x_return_status := FND_API.g_ret_sts_error;
       FND_FILE.put_line(FND_FILE.log,'EAM_Downtime_PUB.WriteLog('
                         || l_stmt_num
                         || '): '
                         || x_return_status
                         || substr(SQLERRM,1,200));
    WHEN FND_API.g_exc_unexpected_error THEN
       x_return_status := FND_API.g_ret_sts_unexp_error;
       FND_FILE.put_line(FND_FILE.log,'EAM_Downtime_PUB.WriteLog('
                         || l_stmt_num
                         || '): '
                         || x_return_status
                         || substr(SQLERRM,1,200));
    WHEN others THEN
       x_return_status := FND_API.g_ret_sts_unexp_error;
       FND_FILE.put_line(FND_FILE.log,'EAM_Downtime_PUB.WriteLog('
                         || l_stmt_num
                         || '): '
                         || x_return_status
                         || substr(SQLERRM,1,200));

END WriteLog;
---------------------------------------------------------------------------
PROCEDURE Load_Downtime(
         p_api_version        IN NUMBER,
         x_return_status      OUT NOCOPY VARCHAR2,
         x_msg_count          OUT NOCOPY NUMBER,
         x_msg_data           OUT NOCOPY VARCHAR2,
         p_downtime_group_id  IN NUMBER,
         p_org_id             IN NUMBER,
         p_simulation_set     IN VARCHAR2,
         p_include_unreleased IN NUMBER,
         p_firm_order_only    IN NUMBER,
         p_department_id      IN NUMBER,
         p_resource_id        IN NUMBER,
         p_calendar_code      IN VARCHAR2,
         p_exception_set_id   IN NUMBER,
         p_user_id            IN NUMBER,
         p_request_id         IN NUMBER,
         p_prog_id            IN NUMBER,
         p_prog_app_id        IN NUMBER,
         p_login_id           IN NUMBER) IS

    l_api_name    CONSTANT       VARCHAR2(30) := 'LoadDowntime';
    l_api_version CONSTANT       NUMBER       := 1.0;

    l_msg_count   NUMBER :=0;
    l_msg_data    VARCHAR2(8000):= '';

    l_stmt_num    NUMBER := 0;
    l_old_maint_org_id NUMBER;
	l_old_asset_group_id NUMBER;
  	l_old_asset_number varchar2(30);
    i NUMBER;
    j NUMBER;
    l_in_downtime_tbl downtime_tbl_type;

BEGIN
    -- standard start of API savepoint
    SAVEPOINT LoadDowntime_PUB;

    -- standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then
         RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- initialize api return status to success
    x_return_status := FND_API.g_ret_sts_success;

    --API Body
    --Delete BRIC rows
    delete from bom_res_instance_changes
    where
	downtime_group_id is not null
  	and simulation_set=p_simulation_set
	and ((p_department_id is not null and department_id=p_department_id)
        or (p_department_id is null and department_id in
           (select department_id from bom_departments
           where organization_id=p_org_id)))
    and ((p_resource_id is not null and resource_id=p_resource_id)
         or (p_resource_id is null));

    --Delete BRC rows
    delete from bom_resource_changes
    where
	downtime_group_id is not null
    	and simulation_set=p_simulation_set
	and ((p_department_id is not null and department_id=p_department_id)
        or (p_department_id is null and department_id in
           (select department_id from bom_departments
           where organization_id=p_org_id)))
    and ((p_resource_id is not null and resource_id=p_resource_id)
         or (p_resource_id is null));




    i := 0;
    IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(fnd_file.log, 'about to enter, p_department_id:'||p_department_id||'resource_id:'||p_resource_id||'p_group_id:'||p_downtime_group_id
                          ||'calendar_code:'||p_calendar_code||'exception_set_id:'||p_exception_set_id);
        fnd_file.put_line(fnd_file.log, 'organization' ||p_org_id);
    end if;

    for a_downtime in downtime_csr(p_org_id, p_department_id, p_resource_id,
                        p_include_unreleased, p_firm_order_only)  loop

	-- do nothing
	-- Only called the first time entering the loop
    IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'wip_entity_id:' ||a_downtime.wip_entity_id
	     || 'asset_group_id:' || a_downtime.asset_group_id
	     ||'asset_number:'||a_downtime.asset_number
	     ||'op_seq:'||a_downtime.op_seq
	     ||'from_date:'||a_downtime.from_date
	     ||'to_date:'||a_downtime.to_date);
--	     ||'shutdown_type:'||a_downtime.shutdown_type
--	     ||'prod_org_id:'||a_downtime.prod_org_id
--	     ||'equipment_item_id:'||a_downtime.equipment_item_id
--	     ||'eqp_serial_number:'||a_downtime.eqp_serial_number
--	     ||'department_id:'||a_downtime.department_id
--	     ||'resource_id:'||a_downtime.resource_id
--	     ||'instance_id:'||a_downtime.instance_id);
    end if;
	if i = 0 then
		l_old_maint_org_id := a_downtime.maint_org_id;
		l_old_asset_group_id := a_downtime.asset_group_id;
	  	l_old_asset_number := a_downtime.asset_number;

	elsif a_downtime.maint_org_id <> l_old_maint_org_id
	       or a_downtime.asset_group_id <> l_old_asset_group_id
	       or a_downtime.asset_number <> l_old_asset_number
	then
        process_one_table(l_in_downtime_tbl, i,
                        p_department_id, p_resource_id,
                        p_calendar_code, p_exception_set_id,
                        p_downtime_group_id, p_simulation_set);
		i := 0;
		l_old_maint_org_id := a_downtime.maint_org_id;
		l_old_asset_group_id := a_downtime.asset_group_id;
	  	l_old_asset_number := a_downtime.asset_number;
	end if; -- if condition for chaning asset

    l_in_downtime_tbl(i) := a_downtime;

	i := i+1;

    end loop; --cursor downtime_csr
    --process the last in_date table
    process_one_table(l_in_downtime_tbl, i,
                      p_department_id, p_resource_id,
                      p_calendar_code, p_exception_set_id,
                      p_downtime_group_id, p_simulation_set);

    --Now insert into brc

    insert into bom_resource_changes(
        DEPARTMENT_ID,
        RESOURCE_ID,
        SHIFT_NUM,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        FROM_DATE,
        TO_DATE,
        FROM_TIME,
        TO_TIME,
        CAPACITY_CHANGE,
        SIMULATION_SET,
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
        REQUEST_ID ,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        ACTION_TYPE,
        REASON_CODE,
        downtime_group_id)
        select
        DEPARTMENT_ID,
        RESOURCE_ID,
        SHIFT_NUM,
        sysdate,
        fnd_global.user_id,
    	sysdate,
    	fnd_global.user_id,
    	fnd_global.login_id,
        FROM_DATE,
        TO_DATE,
        FROM_TIME,
        TO_TIME,
        sum(CAPACITY_CHANGE),
        SIMULATION_SET,
        null, null, --descp flex
        null, null,
        null, null,
        null, null,
        null, null,
        null, null,
        null, null,
        null, null,
        p_request_id ,
        p_prog_app_id,
        p_prog_id,
        sysdate,
        ACTION_TYPE,
        g_reason_code,
        p_downtime_group_id
        from bom_res_instance_changes
        where
            downtime_group_id=p_downtime_group_id
        group by DEPARTMENT_ID,
                 RESOURCE_ID,
                 SHIFT_NUM,
                 FROM_DATE,
                 TO_DATE,
                 FROM_TIME,
                 TO_TIME,
                 ACTION_TYPE,
                 SIMULATION_SET;
    commit;
 EXCEPTION
    WHEN FND_API.g_exc_error THEN
       x_return_status := FND_API.g_ret_sts_error;
       FND_FILE.put_line(FND_FILE.log,'EAM_Downtime_PUB.LoadDowntime('
                         || l_stmt_num
                         || '): '
                         || x_return_status
                         || substr(SQLERRM,1,200));
    WHEN FND_API.g_exc_unexpected_error THEN
       Rollback to LoadDowntime_PUB; -- roll back data when unexpected errors happens
       x_return_status := FND_API.g_ret_sts_unexp_error;
       FND_FILE.put_line(FND_FILE.log,'EAM_Downtime_PUB.LoadDowntime('
                         || l_stmt_num
                         || '): '
                         || x_return_status
                         || substr(SQLERRM,1,200));
    WHEN others THEN
       Rollback to LoadDowntime_PUB; -- roll back data when unexpected errors happens
       x_return_status := FND_API.g_ret_sts_unexp_error;
       FND_FILE.put_line(FND_FILE.log,'EAM_Downtime_PUB.LoadDowntime('
--       dbms_output.put_line('EAM_Downtime_PUB.LoadDowntime('
                         || l_stmt_num
                         || '): '
                         || x_return_status
                         || substr(SQLERRM,1,200));

END Load_Downtime;

---------------------------------------------------------------------------
PROCEDURE Purge_Downtime(
         p_api_version        IN NUMBER,
         x_return_status      OUT NOCOPY VARCHAR2,
         x_msg_count          OUT NOCOPY NUMBER,
         x_msg_data           OUT NOCOPY VARCHAR2,
         p_org_id             IN NUMBER,
         p_simulation_set     IN VARCHAR2) IS

    l_api_name    CONSTANT       VARCHAR2(30) := 'PurgeDowntime';
    l_api_version CONSTANT       NUMBER       := 1.0;

    l_msg_count   NUMBER :=0;
    l_msg_data    VARCHAR2(8000):= '';

    l_stmt_num    NUMBER := 0;
    l_old_maint_org_id NUMBER;
	l_old_asset_group_id NUMBER;
  	l_old_asset_number NUMBER;
    i NUMBER;
    j NUMBER;


BEGIN
    -- standard start of API savepoint
    SAVEPOINT PurgeDowntime_PUB;

    -- standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then
         RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- initialize api return status to success
    x_return_status := FND_API.g_ret_sts_success;

    --API Body
    --Delete all previous equipment downtime rows in BRIC and BRC
    delete from bom_res_instance_changes
    where
	downtime_group_id is not null
    	and simulation_set=p_simulation_set
	and department_id in
	(select department_id from bom_departments
	 where
             organization_id=p_org_id);

    delete from bom_resource_changes
    where
	downtime_group_id is not null
    	and simulation_set=p_simulation_set
	and department_id in
	(select department_id from bom_departments
	 where
             organization_id=p_org_id);



 commit;
 EXCEPTION
    WHEN FND_API.g_exc_error THEN
       ROLLBACK to purgedowntime_pub;
       x_return_status := FND_API.g_ret_sts_error;
       FND_FILE.put_line(FND_FILE.log,'EAM_Downtime_PUB.PurgeDowntime('
                         || l_stmt_num
                         || '): '
                         || x_return_status
                         || substr(SQLERRM,1,200));
    WHEN FND_API.g_exc_unexpected_error THEN
       ROLLBACK to purgedowntime_pub;
       x_return_status := FND_API.g_ret_sts_unexp_error;
       FND_FILE.put_line(FND_FILE.log,'EAM_Downtime_PUB.PurgeDowntime('
                         || l_stmt_num
                         || '): '
                         || x_return_status
                         || substr(SQLERRM,1,200));
    WHEN others THEN
       ROLLBACK to purgedowntime_pub;
       x_return_status := FND_API.g_ret_sts_unexp_error;
       FND_FILE.put_line(FND_FILE.log,'EAM_Downtime_PUB.PurgeDowntime('
                         || l_stmt_num
                         || '): '
                         || x_return_status
                         || substr(SQLERRM,1,200));

END Purge_Downtime;

END EAM_Downtime_PUB;

/
