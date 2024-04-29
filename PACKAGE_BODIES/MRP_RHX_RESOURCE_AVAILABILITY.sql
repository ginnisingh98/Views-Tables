--------------------------------------------------------
--  DDL for Package Body MRP_RHX_RESOURCE_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_RHX_RESOURCE_AVAILABILITY" AS
/* $Header: MRPXNRAB.pls 120.1.12010000.2 2008/09/18 16:38:54 mlouie ship $ */
DELETE_WORKDAY  CONSTANT number := 1;
CHANGE_WORKDAY  CONSTANT number := 2;
ADD_WORKDAY     CONSTANT number := 3;
HOLD_TIME       CONSTANT number := 9999999;
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

PROCEDURE calc_res_avail(   arg_organization_id IN  number,
                            arg_department_id   IN  number,
                            arg_resource_id     IN  number,
                            arg_simulation_set  IN  varchar2,
                            arg_24hr_flag       IN  number,
                            arg_start_date      IN  date default SYSDATE,
                            arg_cutoff_date     IN  date)  is

    cursor changes is
    SELECT  changes.action_type,
            changes.from_time,
            DECODE(LEAST(changes.to_time, changes.from_time),
                changes.to_time, changes.to_time + 24*3600,
                changes.to_time),
            dates.shift_date,
            changes.shift_num,
            changes.capacity_change
    from    bom_shift_dates dates,
            bom_resource_changes changes,
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
    AND     changes.resource_id = arg_resource_id
    AND     changes.department_id = arg_department_id
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
    var_new_cap                 number;
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
    AND     simulation_set = arg_simulation_set
    AND     organization_id = arg_organization_id
    AND     shift_num = var_shift_num
    AND     shift_date = var_shift_date
    UNION ALL
    SELECT  0 capacity_units,
            HOLD_TIME from_time,
            HOLD_TIME to_time,
            rowid
    from    dual
    ORDER BY 2, 3;
begin
    var_gt_user_id := fnd_global.user_id;
    if arg_24hr_flag = 2 THEN
        insert into mrp_net_resource_avail(
                    organization_id,
                    department_id,
                    resource_id,
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
                    res_shifts.shift_num,
                    dates.shift_date,
                    shifts.from_time,
                    shifts.to_time,
                    nvl(res_shifts.capacity_units,nvl(dept_res1.capacity_units,1)),
                    arg_simulation_set,
                    sysdate,
                    var_gt_user_id,
                    sysdate,
                    var_gt_user_id
        FROM        bom_shift_dates dates,
                    bom_shift_times shifts,
                    bom_resource_shifts res_shifts,
                    bom_department_resources dept_res1,
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
        AND         param.organization_id = arg_organization_id
        AND         NOT EXISTS
                    (SELECT NULL
                     FROM   bom_resource_changes changes
                     WHERE  changes.department_id = dept_res1.department_id
                     AND    changes.resource_id = dept_res1.resource_id
                     AND    changes.shift_num = dates.shift_num
                     AND    changes.from_date = dates.shift_date
                     AND    changes.action_type = DELETE_WORKDAY);
    else
        insert into mrp_net_resource_avail(
                        organization_id,
                        department_id,
                        resource_id,
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
                        0,
                        dates.calendar_date,
                        1,
                        24*60*60 - 1,
                        nvl(dept_res1.capacity_units, 1),
                        arg_simulation_set,
                        sysdate,
                        var_gt_user_id,
                        sysdate,
                        var_gt_user_id
            FROM        bom_calendar_dates dates,
                        bom_department_resources dept_res1,
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
            AND         param.organization_id = arg_organization_id;
    end if;

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
/*
            if var_gt_debug then
                dbms_output.put_line('From time '||
                    to_char(var_orig_from_time/3600) ||
                    ' To Time '|| to_char(var_orig_to_time/3600) ||
                    ' Shift '|| to_char(var_shift_num) ||
                    ' Shift date '|| to_char(var_shift_date));
            end if;
*/

            /*----------------------------------------------------------+
             |  For each modification we get the current resource       |
             |  calendar and process sections of the modification that  |
             |  overlaps with the shift segment                         |
             +----------------------------------------------------------*/
            -- Initialize the variables
            var_from_time := var_orig_from_time;
            var_next_from_time := var_orig_from_time;
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
                var_from_time := var_next_from_time;
                -- Set the to time to the original to time of the modification
                var_to_time := var_orig_to_time;
                -- If you have completely processed the modification you are
                -- done so exit
                if (var_from_time > var_to_time) then
                    EXIT;
                end if;
                var_rowcount := var_rowcount + 1;
                -- If only row is the extra dummy row, you are processing a
                -- modification for a deleted workday... skip the row
                if var_from_shift_time = HOLD_TIME AND var_rowcount = 1 THEN
                    EXIT;
                -- If this is the dummy extra row and you have not completely
                -- processed the modification...that is probably because the
                -- modification does not overlap with the shift..go ahead and
                -- process it that way
                elsif var_from_shift_time = HOLD_TIME
                    AND var_from_time <= var_to_time
                THEN
                    var_from_shift_time := var_from_time - 2;
                    var_to_shift_time := var_from_time - 1;
		 else
		   -- if the shift spans over midnight
		   -- and the shift exception starts on the next day
		   -- then, the shift exception times need to be moved to the next day
		   if var_to_shift_time > 24*60*60 then
		      if var_from_time < var_to_shift_time - 24*60*60 then
			 var_from_time := var_from_time + 24*60*60;
			 var_to_time := var_to_time + 24*60*60;
		      end if;
		    end if;

                    -- If the modification overlaps a shift segment then set
                    -- the end time of the modification to the least of the
                    -- modification end time or shift end time
		    -- the second check (var_to_time > var_from_shift_time)
		    --   checks for the possibility that the exception is
		    --   actually for the following day
                    if (var_from_time < var_to_shift_time
			and var_to_time > var_from_shift_time)  then
                        var_to_time := LEAST(var_to_shift_time, var_to_time);
                        var_next_from_time := var_to_time + 1;
                    else
                    -- Otherwise the modification does not overlap with the
                    -- shift. In that case do not process and leave it for the
                    -- next shift segment
                        goto skip;
                    end if;
                end if;

/*
                if  var_gt_debug then
                    dbms_output.put_line('From Shift time '||
                        to_char(var_from_shift_time/3600) ||
                        ' To Shift Time '|| to_char(var_to_shift_time/3600) ||
                        ' Next shift time '|| to_char(var_next_from_time)/3600);
                end if;
*/
		/*
		If the modification starts before the shift starts and ends on or before the shift starts
		Note that you can only add capacity here since you have none to reduce
		*/
		if var_from_time < var_from_shift_time AND
		   var_to_time <= var_from_shift_time AND
		   var_cap_change > 0 THEN
		   /* you cannot reduce capacity here because you have none to reduce
		      addresses bugfix 3072102 */
	  	   if var_to_time < var_from_shift_time then
		      insert_avail(var_shift_date,
                                   arg_department_id,
                                   arg_resource_id,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_from_time,
			           var_to_time,
                                   var_cap_change);
		   else
		     /* if to time = from shift time, it's ambiguous what the capacity is at from shift time
		        so we will only increase to 1 minute before from shift time */
		      insert_avail(var_shift_date,
                                   arg_department_id,
                                   arg_resource_id,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_from_time,
			           var_from_shift_time - 1,
                                   var_cap_change);
		   end if;
                end if;
                /*
                If the modification starts before the shift starts and
                ends after the shift starts but on or before the shift ends */
                if var_from_time < var_from_shift_time AND
                   var_from_shift_time < var_to_time AND
                   var_to_time <= var_to_shift_time THEN
                   /* bugfix 3072102 If modification starts before shifts, then reduce
                      capacity change does not make sense */
                   if var_cap_change > 0 then
                      insert_avail(var_shift_date,
                                   arg_department_id,
                                   arg_resource_id,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_from_time,
                                   var_from_shift_time - 1,
                                   var_cap_change);
                   end if;
		   if (var_orig_cap + var_cap_change) <= 0 then
                      delete_avail(var_rowid);
		   else
		      if var_to_time < var_to_shift_time then
                         insert_avail(var_shift_date,
                                      arg_department_id,
                                      arg_resource_id,
                                      arg_organization_id,
                                      var_shift_num,
                                      arg_simulation_set,
                                      var_from_shift_time,
                                      var_to_time,
                                      var_orig_cap + var_cap_change);
	                 update_avail(var_rowid,
	       		              var_shift_date,
                                      var_to_time + 1,
                                      var_to_shift_time);
                      /* Otherwise the to time and the shift end time are
                         the same */
                      else
	                 delete_avail(var_rowid);
                         insert_avail(var_shift_date,
                                      arg_department_id,
                                      arg_resource_id,
                                      arg_organization_id,
                                      var_shift_num,
                                      arg_simulation_set,
                                      var_from_shift_time,
			              var_to_shift_time,
                                      var_orig_cap + var_cap_change);
		      end if;
                   end if;
                end if;
                /* If the modification starts before the shift starts and
                ends after the shift ends */
                if var_from_time < var_from_shift_time AND
                   var_to_shift_time < var_to_time THEN
		   if var_cap_change > 0 then
                      insert_avail(var_shift_date,
                                   arg_department_id,
                                   arg_resource_id,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_from_time,
                                   var_from_shift_time - 1,
                                   var_cap_change);
                   end if;
                   delete_avail(var_rowid);
		   if (var_orig_cap + var_cap_change) > 0 then
                      insert_avail(var_shift_date,
                                   arg_department_id,
                                   arg_resource_id,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_from_shift_time,
			           var_to_shift_time,
                                   var_orig_cap + var_cap_change);
		   end if;
		   if var_cap_change > 0 then
                      insert_avail(var_shift_date,
                                   arg_department_id,
                                   arg_resource_id,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_to_shift_time + 1,
                                   var_to_time,
                                   var_cap_change);
		   end if;
		end if;

		/* If the modification starts on or after the shift starts and
                   ends on or before the shift ends */
                if var_from_shift_time <= var_from_time AND
                   var_to_time <= var_to_shift_time THEN
		   if var_from_shift_time < var_from_time then
		      update_avail(var_rowid,
                                   var_shift_date,
				   var_from_shift_time,
                                   var_from_time - 1);
		   end if;
		   if (var_orig_cap + var_cap_change) > 0 then
                      insert_avail(var_shift_date,
                                   arg_department_id,
                                   arg_resource_id,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_from_time,
                                   var_to_time,
                                   var_orig_cap + var_cap_change);
		   end if;
		   if var_to_time < var_to_shift_time then
		      insert_avail(var_shift_date,
                                   arg_department_id,
                                   arg_resource_id,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_to_time + 1,
                                   var_to_shift_time,
                                   var_orig_cap);
		   end if;
		   if var_from_time = var_from_shift_time AND
		      var_to_time = var_to_shift_time THEN
		      delete_avail(var_rowid);
		   end if;
                end if;

                /* If the modification starts on or after the shift starts and ends
                after the shift ends */
		if var_from_shift_time <= var_from_time AND
		   var_to_shift_time >= var_from_time AND
                   var_to_time > var_to_shift_time THEN
		   if var_from_shift_time < var_from_time then
		      update_avail(var_rowid,
                                   var_shift_date,
				   var_from_shift_time,
                                   var_from_time - 1);
		   else
		      delete_avail(var_rowid);
		   end if;
		   if (var_orig_cap + var_cap_change) > 0 then
                      insert_avail(var_shift_date,
                                   arg_department_id,
                                   arg_resource_id,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_from_time,
                                   var_to_shift_time,
                                   var_orig_cap + var_cap_change);
		   end if;
		   if var_cap_change > 0 then
	              insert_avail(var_shift_date,
                                   arg_department_id,
                                   arg_resource_id,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_to_shift_time + 1,
                                   var_to_time,
                                   var_cap_change);
		   end if;
                end if;

                /* If the modification starts on or after the shift ends
		   and you are adding capacity (cannot reduce capacity here)
		*/
                if var_from_time >= var_to_shift_time AND
		   var_cap_change > 0 THEN
	           if var_from_time > var_to_shift_time then
                      insert_avail(var_shift_date,
                                   arg_department_id,
                                   arg_resource_id,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_from_time,
                                   var_to_time,
                                   var_cap_change);
		   else
		      insert_avail(var_shift_date,
                                   arg_department_id,
                                   arg_resource_id,
                                   arg_organization_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_to_shift_time + 1,
                                   var_to_time,
                                   var_cap_change);
		   end if;
                end if;
                <<skip>>
                NULL;
            end loop;
            close avail;
        end loop;
        --  Finally add the availability from the add workday type modifications

        INSERT into mrp_net_resource_avail(
                    organization_id,
                    department_id,
                    resource_id,
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
                    changes.shift_num,
                    changes.from_date,
                    changes.from_time,
                    changes.to_time,
                    changes.capacity_change,
                    arg_simulation_set,
                    sysdate,
                    var_gt_user_id,
                    sysdate,
                    var_gt_user_id
        FROM        bom_resource_changes changes
        WHERE       changes.department_id = arg_department_id
        AND         changes.resource_id = arg_resource_id
        AND         changes.action_type = ADD_WORKDAY
        AND         changes.simulation_set= arg_simulation_set;
    end if;
end calc_res_avail;

procedure populate_avail_resources(arg_simulation_set   in varchar2,
                                    arg_organization_id in number,
                                  arg_start_date      IN  date default SYSDATE,
                                    arg_cutoff_date     in date default NULL) is
    cursor dept_res is
    select  dept_res.department_id,
            dept_res.resource_id,
            NVL(dept_res.available_24_hours_flag, 2)
    from    bom_department_resources dept_res,
            bom_departments dept
    where   dept_res.department_id = dept.department_id
    AND     dept_res.share_from_dept_id is null
    AND     dept.organization_id = arg_organization_id;

    var_department_id   NUMBER;
    var_resource_id     NUMBER;
    var_24hr_flag       NUMBER;
    var_cutoff_date     DATE;
begin
    var_gt_debug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';
    --dbms_output.enable(100000);
    delete  from mrp_net_resource_avail
    where   organization_id = arg_organization_id
    and     (arg_simulation_set is null or simulation_set = arg_simulation_set);

    if arg_cutoff_date is null then
        var_cutoff_date := TRUNC(SYSDATE) + 700;
    else
        var_cutoff_date := arg_cutoff_date;
    end if;
    open dept_res;
    LOOP
        Fetch dept_res into var_department_id,
                            var_resource_id,
                            var_24hr_flag;
        EXIT WHEN dept_res%NOTFOUND;
        calc_res_avail(arg_organization_id,
                        var_department_id,
                        var_resource_id,
                        arg_simulation_set,
                        var_24hr_flag,
                        arg_start_date,
                        var_cutoff_date);
    END LOOP;
    COMMIT;
end populate_avail_resources;
end mrp_rhx_resource_availability;

/
