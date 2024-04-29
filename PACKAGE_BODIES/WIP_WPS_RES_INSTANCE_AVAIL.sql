--------------------------------------------------------
--  DDL for Package Body WIP_WPS_RES_INSTANCE_AVAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WPS_RES_INSTANCE_AVAIL" AS
/* $Header: wipzinsb.pls 115.0 2003/09/03 23:03:13 jaliu noship $ */

var_gt_user_id  number;
var_gt_debug    boolean;

function check_24(  var_time    in  number) return number is
begin
/*
    if var_gt_debug then
        dbms_output.put_line('In check_24 '|| to_char(var_time));
    end if;
*/
    if var_time > 24*3600 then
        return var_time - 24*3600;
    else
        return var_time;
    end if;
end check_24;

procedure   update_avail(   var_rowid           in  ROWID,
			    var_date            in  DATE,
                            var_from_time       in  number,
                            var_to_time         in  number) is
var_time1   number;
var_time2   number;
var_date1   DATE;
begin

   -- dbms_output.put_line(' rowid: '||var_rowid);
    var_time1 := check_24(var_from_time);
    var_time2 := check_24(var_to_time);
    /*
    if the start time is in the next, this avail should be on the
      following day
    */

    var_date1 := var_date;
    if var_time1 < var_from_time then
      var_date1 := var_date1 + 1;
    end if;

    UPDATE  mrp_net_resource_avail
    SET     shift_date = var_date1,
            from_time = var_time1,
            to_time = var_time2
    WHERE   rowid = var_rowid;
end update_avail;

procedure   delete_avail(   var_rowid           in  ROWID) is
begin
/*
    if  var_gt_debug then
        dbms_output.put_line('about to delete');
    end if;
*/
    DELETE  from mrp_net_resource_avail
    WHERE   rowid = var_rowid;
end delete_avail;

procedure   insert_avail(   var_date            in  DATE,
                            var_department_id   in  number,
                            var_resource_id     in  number,
			    var_instance_id     in  number,
			    var_serial_num      in  varchar2,
                            var_organization_id in  number,
                            var_shift_num       in  number,
                            var_simulation_set  in  varchar2,
                            var_from_time       in  number,
                            var_to_time         in  number,
                            var_cap_units       in  number) is
var_time1   number;
var_time2   number;
var_date1   DATE;

begin
    var_time1 := check_24(var_from_time);
    var_time2 := check_24(var_to_time);

    /*
    if the start time is in the next, this avail should be on the
      following day
    */

    var_date1 := var_date;
    if var_time1 < var_from_time then
       var_date1 := var_date1 + 1;
    end if;
/*
    if var_gt_debug then
        dbms_output.put_line('Ready to insert' ||
            ' Dept ' || to_char(var_department_id) ||
            ' Res ' || to_char(var_resource_id) ||
            ' shift ' || to_char(var_shift_num) ||
            ' date '|| to_char(var_date) ||
            ' from time '|| to_char(var_from_time/3600)||
            ' to time '|| to_char(var_to_time/3600) ||
            ' units '|| to_char(var_cap_units));
    end if;
*/
    INSERT into mrp_net_resource_avail(
                    department_id,
		    resource_id,
		    instance_id,
		    serial_number,
                    organization_id,
                    shift_num,
                    shift_date,
                    from_time,
                    to_time,
                    capacity_units,
                    simulation_set,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by)
    VALUES(
                    var_department_id,
	            var_resource_id,
	            var_instance_id,
	            var_serial_num,
                    var_organization_id,
                    var_shift_num,
   	            var_date1,
	            var_time1,
	            var_time2,
                    var_cap_units,
                    var_simulation_set,
                    sysdate,
                    var_gt_user_id,
                    sysdate,
                    var_gt_user_id);
end insert_avail;

PROCEDURE calc_ins_avail(   arg_organization_id IN  number,
                            arg_department_id   IN  number,
                            arg_resource_id     IN  number,
                            arg_simulation_set  IN  varchar2,
			    arg_instance_id     IN  number,
			    arg_serial_num      IN  varchar2,
                            arg_24hr_flag       IN  number,
                            arg_start_date      IN  date default SYSDATE,
                            arg_cutoff_date     IN  date)  is

    cursor changes is
       SELECT  distinct
	    changes.action_type,
            changes.from_time,
            DECODE(LEAST(changes.to_time, changes.from_time),
                changes.to_time, changes.to_time + 24*3600,
                changes.to_time),
            dates.shift_date,
            changes.shift_num,
            reschanges.capacity_change
    from    bom_shift_dates dates,
            bom_res_instance_changes changes,
            bom_resource_changes reschanges,
            mtl_parameters param
    WHERE   dates.calendar_code = param.calendar_code
    AND     dates.exception_set_id = param.calendar_exception_set_id
    AND     dates.seq_num is not null
    AND     dates.shift_date between changes.from_date AND
                NVL(changes.to_date, changes.from_date)
    AND     dates.shift_num = changes.shift_num
    AND     param.organization_id = arg_organization_id
    AND     changes.to_date >= trunc(arg_start_date)
    AND     changes.from_date <= arg_cutoff_date
    AND     changes.simulation_set = arg_simulation_set
    AND     changes.action_type = CHANGE_WORKDAY
    AND     reschanges.action_type = CHANGE_WORKDAY
    AND     changes.resource_id = arg_resource_id
    AND     changes.instance_id = arg_instance_id
    AND     nvl(changes.serial_number,-1) = nvl(arg_serial_num, -1)
    AND     changes.department_id = arg_department_id
    AND     reschanges.department_id = changes.department_id
    AND     reschanges.resource_id = changes.resource_id
    AND     reschanges.shift_num = changes.shift_num
    AND     reschanges.from_date = changes.from_date
    AND     reschanges.to_date = changes.to_date
    AND     reschanges.simulation_set = changes.simulation_set
    AND     reschanges.action_type = changes.action_type
    AND     reschanges.from_time = changes.from_time
    AND     reschanges.to_time = changes.to_time
    -- Removed for bug #2318675 (24hr changes were ignored)
    --AND NOT (changes.from_time = changes.to_time AND
    --         changes.from_date = changes.to_date)
    ORDER BY dates.shift_date, changes.from_time;


    var_action_type             number;
    var_from_time               number;
    var_to_time                 number;
    var_shift_date              date;
    var_from_shift_time         number;
    var_to_shift_time           number;
    var_orig_cap                number;
    var_shift_num               number;
    var_cap_change              number;
    var_orig_from_time          number;
    var_orig_to_time            number;
    var_next_from_time          number;
    var_rowid                   rowid;
    var_rowcount                number;

    cursor avail is
    SELECT  capacity_units capacity_units,
            from_time from_time,
            DECODE(LEAST(to_time, from_time),
                to_time, to_time + 24*3600,
                to_time) to_time,
            rowid
    FROM    mrp_net_resource_avail
    WHERE   department_id = arg_department_id
    AND     resource_id = arg_resource_id
    AND     instance_id = arg_instance_id
    AND     nvl(serial_number,-1) = nvl(arg_serial_num, -1)
    AND     simulation_set = arg_simulation_set
    AND     organization_id = arg_organization_id
    AND     shift_num = var_shift_num
    AND     shift_date = var_shift_date
    ORDER BY 2, 3;

begin
   var_gt_user_id := fnd_global.user_id;

    if arg_24hr_flag = 2 THEN
        insert into mrp_net_resource_avail(
                    organization_id,
                    department_id,
		    resource_id,
		    instance_id,
		    serial_number,
                    shift_num,
                    shift_date,
                    from_time,
                    to_time,
                    capacity_units,
                    simulation_set,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by)
        select      arg_organization_id,
                    arg_department_id,
	            arg_resource_id,
	            arg_instance_id,
	            arg_serial_num,
                    res_shifts.shift_num,
                    dates.shift_date,
                    shifts.from_time,
	            shifts.to_time,
	            -- the capacity unit for instance can only be 1.
	            1,
                    arg_simulation_set,
                    sysdate,
                    var_gt_user_id,
                    sysdate,
                    var_gt_user_id
        FROM        bom_shift_dates dates,
                    bom_shift_times shifts,
                    bom_resource_shifts res_shifts,
	            bom_department_resources dept_res1,
	            bom_dept_res_instances   dept_ins,
                    mtl_parameters param
        WHERE       dates.calendar_code = param.calendar_code
        AND         dates.exception_set_id = param.calendar_exception_set_id
        AND         dates.shift_num = shifts.shift_num
        AND         dates.seq_num is not null
        AND         dates.shift_date >= trunc(arg_start_date)
        AND         dates.shift_date <= arg_cutoff_date
        AND         shifts.shift_num = res_shifts.shift_num
        AND         shifts.calendar_code = param.calendar_code
        AND         res_shifts.department_id = dept_res1.department_id
        AND         res_shifts.resource_id = dept_res1.resource_id
        AND         NVL(dept_res1.available_24_hours_flag, 2) = 2
        AND         dept_res1.share_from_dept_id is null
        AND         dept_res1.resource_id = arg_resource_id
	AND         dept_res1.department_id = arg_department_id
	AND         dept_ins.department_id = arg_department_id
	AND         dept_ins.resource_id = arg_resource_id
        AND         dept_ins.instance_id = arg_instance_id
        AND         nvl(dept_ins.serial_number,-1) = nvl(arg_serial_num, -1)
        AND         param.organization_id = arg_organization_id
        AND         NOT EXISTS
                    (SELECT NULL
                     FROM   bom_resource_changes changes
                     WHERE  changes.department_id = dept_res1.department_id
                     AND    changes.resource_id = dept_res1.resource_id
		     AND    changes.simulation_set = arg_simulation_set
                     AND    changes.shift_num = dates.shift_num
                     AND    changes.from_date = dates.shift_date
                     AND    changes.action_type = DELETE_WORKDAY);

	-- debug
	/*
	select count(*) into var_rowcount
	  FROM  mrp_net_resource_avail
	  where resource_id = arg_resource_id
	  and   instance_id = arg_instance_id
	  and   department_id = arg_department_id;

	  dbms_output.put_line(' Inserted '|| to_char(var_rowcount)||' avails'); */


    else
        insert into mrp_net_resource_avail(
                        organization_id,
                        department_id,
			resource_id,
			instance_id,
			serial_number,
                        shift_num,
                        shift_date,
                        from_time,
                        to_time,
                        capacity_units,
                        simulation_set,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by)
            select      arg_organization_id,
                        arg_department_id,
	                arg_resource_id,
	                arg_instance_id,
	                arg_serial_num,
                        0,
                        dates.calendar_date,
                        1,
                        24*60*60 - 1,
                        1,
                        arg_simulation_set,
                        sysdate,
                        var_gt_user_id,
                        sysdate,
                        var_gt_user_id
            FROM        bom_calendar_dates dates,
                        bom_department_resources dept_res1,
	                bom_dept_res_instances   dept_ins,
                        mtl_parameters param
            WHERE       dates.calendar_code = param.calendar_code
            AND         dates.exception_set_id = param.calendar_exception_set_id
            AND         dates.calendar_date <= arg_cutoff_date
            AND         dates.seq_num is not null
            AND         dates.calendar_date >= trunc(arg_start_date)
            AND         NVL(dept_res1.available_24_hours_flag, 2) = 1
            AND         dept_res1.share_from_dept_id is null
            AND         dept_res1.resource_id = arg_resource_id
            AND         dept_res1.department_id = arg_department_id
	    AND         dept_ins.department_id = arg_department_id
	    AND         dept_ins.resource_id = arg_resource_id
	    AND         dept_ins.instance_id = arg_instance_id
	    AND         nvl(dept_ins.serial_number,-1) = nvl(arg_serial_num,-1)
	    AND         param.organization_id = arg_organization_id;
    end if;

   --  return;

    if arg_24hr_flag = 2 then
       OPEN changes;
        loop
            FETCH changes INTO
                    var_action_type,
                    var_orig_from_time,
                    var_orig_to_time,
                    var_shift_date,
                    var_shift_num,
                    var_cap_change;
            EXIT WHEN changes%NOTFOUND;
	    -- since the capacity for instance can be only 1,
	    -- the changes can be only 1 or -1
            if var_cap_change > 0 then
	       var_cap_change := 1;
	    else
	       var_cap_change := -1;
	    end if;

	    --dbms_output.put_line('cap_change: '||var_orig_from_time||'-'||
		--		 var_orig_to_time||' '||var_shift_date||' '||
			--	 var_cap_change);

            /*----------------------------------------------------------+
             |  For each modification we get the current resource       |
             |  calendar and process sections of the modification that  |
             |  overlaps with the shift segment                         |
             +----------------------------------------------------------*/
            -- Initialize the variables
            var_from_time := var_orig_from_time;
            -- var_next_from_time := var_orig_from_time;
            var_to_time := var_orig_to_time;
            var_rowcount := 0;
            OPEN avail;
            LOOP
                FETCH avail INTO
                        var_orig_cap,
                        var_from_shift_time,
                        var_to_shift_time,
                        var_rowid;
                EXIT WHEN avail%NOTFOUND;
                -- Set the from time for the modification to the start of
                -- the unprocessed section
                var_from_time := var_orig_from_time;
                -- Set the to time to the original to time of the modification
                var_to_time := var_orig_to_time;

                -- If you have completely processed the modification you are
                -- done so exit
                if (var_from_time > var_to_time) then
                    EXIT;
                end if;
		-- if the shift spans over midnight
		-- and the shift exception starts on the next day
		-- then, the shift exception times need to be moved to the next day
		if var_to_shift_time > 24*60*60 then
		    if var_from_time < var_to_shift_time - 24*60*60 then
		        var_from_time := var_from_time + 24*60*60;
		        var_to_time := var_to_time + 24*60*60;
		    end if;
		end if;

		-- If the from time or to time is outside of the shift, then
		-- we will just add the entire capacity.. skip partial
		if var_from_time >= var_to_shift_time
		    OR var_to_time <= var_from_shift_time then
                        goto skip;
                end if;

		-- If the shift starts, before the modification
		if var_from_shift_time < var_from_time then
		   -- Then, if the end of the shift is before or equal to the end
		   -- of the modification, update avail from the start of
		   -- the shift to the start of the modification.
		   if var_to_shift_time <= var_to_time then
		      update_avail(var_rowid,
                             var_shift_date,
			     var_from_shift_time,
			     var_from_time -1);
		   else
		      update_avail(var_rowid,
			     var_shift_date,
			     var_from_shift_time,
			     var_from_time -1);
		      insert_avail(var_shift_date,
				   arg_department_id,
				   arg_resource_id,
				   arg_instance_id,
				   arg_serial_num,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_to_time+1,
                                   var_to_shift_time,
                                   var_orig_cap);
		   end if;

		elsif var_from_shift_time >= var_from_time then
		   if var_to_shift_time > var_to_time then
			 update_avail(var_rowid,
				      var_shift_date,
				      var_to_time+1,
				      var_to_shift_time);
		   else
			 delete_avail(var_rowid);
		   end if;
		end if;

                <<skip>>
                NULL;
            end loop;
            close avail;

	    -- Insert modification
	    if var_cap_change = 1 then
		insert_avail(var_shift_date,
                                arg_department_id,
				arg_resource_id,
				arg_instance_id,
				arg_serial_num,
                                arg_organization_id,
                                var_shift_num,
                                arg_simulation_set,
                                var_from_time,
                                var_to_time,
                                var_cap_change);
	    end if;
        end loop;
        close changes;

	--  Finally add the availability from the add workday type modifications
	-- dbms_output.put_line('going to insert added workdays');
        INSERT into mrp_net_resource_avail(
                    organization_id,
                    department_id,
		    resource_id,
		    instance_id,
		    serial_number,
                    shift_num,
                    shift_date,
                    from_time,
                    to_time,
                    capacity_units,
                    simulation_set,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by)
        select      arg_organization_id,
                    arg_department_id,
	            arg_resource_id,
	            arg_instance_id,
	            arg_serial_num,
                    changes.shift_num,
                    changes.from_date,
                    changes.from_time,
                    changes.to_time,
                    1,
                    arg_simulation_set,
                    sysdate,
                    var_gt_user_id,
                    sysdate,
                    var_gt_user_id
        FROM        bom_res_instance_changes changes
        WHERE       changes.department_id = arg_department_id
	AND         changes.resource_id = arg_resource_id
        and         changes.instance_id = arg_instance_id
	and         nvl(changes.serial_number,-1) = nvl(arg_serial_num, -1)
        AND         changes.action_type = ADD_WORKDAY
	AND         changes.simulation_set= arg_simulation_set;

    end if;
end calc_ins_avail;


end WIP_WPS_RES_INSTANCE_AVAIL;

/
