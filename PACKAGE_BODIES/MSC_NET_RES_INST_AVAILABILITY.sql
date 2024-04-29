--------------------------------------------------------
--  DDL for Package Body MSC_NET_RES_INST_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_NET_RES_INST_AVAILABILITY" AS
/* $Header: MSCNRIAB.pls 120.2 2006/01/12 03:28:15 abhikuma noship $  */


var_gt_user_id  	number;
var_gt_debug    	boolean;
var_gt_date		DATE;
var_gt_request		NUMBER;
var_gt_login		NUMBER;
var_gt_application	NUMBER;
var_gt_conc_program	NUMBER;

FUNCTION check_24(  var_time    in  number) return number is
BEGIN
/*
    if var_gt_debug then
        dbms_output.put_line('In check_24 '|| to_char(var_time));
    end if;
*/

    --dbms_output.put_line('In check_24 '|| to_char(var_time));
    log_message('In check_24 '|| to_char(var_time));

    if var_time > 24*3600 then
        return var_time - 24*3600;
    else
        return var_time;
    end if;
END check_24;


FUNCTION check_start_date(
                          arg_organization_id in number,
                          arg_sr_instance_id  in number) return DATE IS
v_start_date date;

BEGIN

 --v_stmt := 10;
 select TRUNC(MIN(calendar_date))
   into v_start_date
     from   msc_calendar_dates cal
           ,msc_trading_partners tp
     where tp.sr_tp_id = arg_organization_id
     and   tp.sr_instance_id = arg_sr_instance_id
     and   tp.partner_type = 3
     and   cal.calendar_code = tp.calendar_code
     and   cal.sr_instance_id = tp.sr_instance_id
     and   cal.exception_set_id = tp.calendar_exception_set_id
     and   cal.seq_num is not null;

  return v_start_date;

    EXCEPTION
      WHEN no_data_found THEN
        FND_MESSAGE.SET_NAME('MSC', 'MSC_NRA_NO_CALENDAR');
        FND_MESSAGE.SET_TOKEN('ORG_ID', arg_organization_id);
        MSC_UTIL.MSC_DEBUG(FND_MESSAGE.Get);

END check_start_date;

FUNCTION check_cutoff_date(arg_organization_id in number,
                           arg_sr_instance_id  in number) return DATE IS
v_cutoff_date date;

BEGIN

 --v_stmt := 20;
 select TRUNC(MAX(calendar_date))
   into v_cutoff_date
     from   msc_calendar_dates cal
           ,msc_trading_partners tp
     where tp.sr_tp_id = arg_organization_id
     and   tp.sr_instance_id = arg_sr_instance_id
     and   tp.partner_type = 3
     and   cal.calendar_code = tp.calendar_code
     and   cal.sr_instance_id = tp.sr_instance_id
     and   cal.exception_set_id = tp.calendar_exception_set_id
     and   cal.seq_num is not null;

  return v_cutoff_date;

    EXCEPTION
      WHEN no_data_found THEN
        FND_MESSAGE.SET_NAME('MSC', 'MSC_NRA_NO_CALENDAR');
        FND_MESSAGE.SET_TOKEN('ORG_ID', arg_organization_id);
        MSC_UTIL.MSC_DEBUG(FND_MESSAGE.Get);

END check_cutoff_date;

PROCEDURE   update_avail(   var_rowid           in  ROWID,
			    var_date            in  DATE,
                            var_from_time       in  number,
                            var_to_time         in  number) is
var_time1   number;
var_time2   number;
var_date1   DATE;

BEGIN

    --dbms_output.put_line(' rowid: '||var_rowid);
    log_message(' rowid: '||var_rowid);
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

    UPDATE  msc_net_res_inst_avail
    SET     shift_date = var_date1,
            from_time = var_time1,
            to_time = var_time2
    WHERE   rowid = var_rowid;

EXCEPTION
	WHEN OTHERS THEN
		MSC_UTIL.MSC_DEBUG('Error in update_avail:: ' || to_char(sqlcode) || ':' || substr(sqlerrm,1,60));
END update_avail;

PROCEDURE  delete_avail(   var_rowid           in  ROWID) is
BEGIN
/*
    if  var_gt_debug then
        dbms_output.put_line('about to delete');
    end if;
*/
    --dbms_output.put_line('about to delete');
    log_message('about to delete');

    DELETE  from msc_net_res_inst_avail
    WHERE   rowid = var_rowid;
    --dbms_output.put_line('delete row count ' || sql%rowcount);
    log_message('delete row count ' || sql%rowcount);
END delete_avail;

PROCEDURE   insert_avail(   var_date            in  DATE,
                            var_department_id   in  number,
                            var_resource_id     in  number,
			    var_instance_id     in  number,
			    var_serial_num      in  varchar2,
			    var_equipment_item_id IN Number,
                            var_organization_id in  number,
                            var_sr_instance_id  in  number,
                            var_shift_num       in  number,
                            var_simulation_set  in  varchar2,
                            var_from_time       in  number,
                            var_to_time         in  number,
                            var_refresh_number  in number) is
var_time1   	number;
var_time2   	number;
var_date1   	DATE;


BEGIN
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

    INSERT into msc_net_res_inst_avail(
    		    inst_transaction_id,
    		    plan_id,
                    sr_instance_id,
                    organization_id,
                    department_id,
		    resource_id,
		    res_instance_id,
		    equipment_item_id,
		    parent_id,
		    serial_number,
                    simulation_set,
                    shift_num,
                    shift_date,
                    from_time,
                    to_time,
                    status,
                    applied,
                    updated,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    refresh_number)
    VALUES(	    msc_net_res_inst_avail_s.NEXTVAL,
    		    -1,
    		    var_sr_instance_id,
    		    var_organization_id,
                    var_department_id,
	            var_resource_id,
	            var_instance_id,
	            var_equipment_item_id,
	            null,		--PARENT_ID
	            var_serial_num,
                    var_simulation_set,
                    var_shift_num,
   	            var_date1,
	            var_time1,
	            var_time2,
	            null,		--STATUS
	            null,		--APPLIED
	            2,			--UPDATED
                    sysdate,
                    var_gt_user_id,
                    sysdate,
                    var_gt_user_id,
                    var_gt_login,
                    var_gt_request,
                    var_gt_application,
                    var_gt_conc_program,
                    sysdate,
                    var_refresh_number
                    );
         -- dbms_output.put_line('last insert row count ' || sql%rowcount);

EXCEPTION
	WHEN OTHERS THEN
		MSC_UTIL.MSC_DEBUG('Error in insert_avail:: ' || to_char(sqlcode) || ':' || substr(sqlerrm,1,60));

END insert_avail;


PROCEDURE calc_res_ins_avail(   arg_organization_id IN  number,
			    arg_sr_instance_id  IN  number,
                            arg_department_id   IN  number,
                            arg_resource_id     IN  number,
                            arg_simulation_set  IN  varchar2,
			    arg_instance_id     IN  number,
			    arg_serial_num      IN  varchar2,
			    arg_equipment_item_id IN Number,
                            arg_24hr_flag       IN  number,
                            arg_start_date      IN  date,
                            arg_cutoff_date     IN  date,
                            arg_refresh_number  IN Number)  is

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
    from    msc_shift_dates dates,
            msc_res_instance_changes changes,
            msc_resource_changes reschanges,
            msc_trading_partners param
    WHERE   dates.calendar_code = param.calendar_code
    AND     dates.exception_set_id = param.calendar_exception_set_id
    AND	    dates.sr_instance_id = param.sr_instance_id
    AND	    dates.sr_instance_id = arg_sr_instance_id
    AND     dates.seq_num is not null
    AND     dates.shift_date between changes.from_date AND
                NVL(changes.to_date, changes.from_date)
    AND     dates.shift_num = changes.shift_num
    AND     param.sr_tp_id = arg_organization_id
    AND     changes.to_date >= trunc(arg_start_date)
    AND     changes.from_date <= arg_cutoff_date
    AND     changes.simulation_set = arg_simulation_set
    AND     changes.action_type = CHANGE_WORKDAY
    AND     reschanges.action_type = CHANGE_WORKDAY
    AND     changes.resource_id = arg_resource_id
    AND     changes.res_instance_id = arg_instance_id
    AND     nvl(changes.serial_number,-1) = nvl(arg_serial_num, -1)
    AND     changes.department_id = arg_department_id
    AND     reschanges.department_id = changes.department_id
    AND     reschanges.resource_id = changes.resource_id
    AND	    reschanges.sr_instance_id = changes.sr_instance_id
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
    var_equipment_item_id	number;

    l_count			number := 0;

    cursor avail is
    SELECT  equipment_item_id,
            from_time from_time,
            DECODE(LEAST(to_time, from_time),
                to_time, to_time + 24*3600,
                to_time) to_time,
            rowid
    FROM    msc_net_res_inst_avail
    WHERE   plan_id = -1
    AND     department_id = arg_department_id
    AND     resource_id = arg_resource_id
    AND     res_instance_id = arg_instance_id
    AND     nvl(serial_number,-1) = nvl(arg_serial_num, -1)
    AND     simulation_set = arg_simulation_set
    AND	    sr_instance_id = arg_sr_instance_id
    AND     organization_id = arg_organization_id
    AND     shift_num = var_shift_num
    AND     shift_date = var_shift_date
    ORDER BY 2, 3;

BEGIN
    /**
    dbms_output.put_line('sr instance ' || arg_sr_instance_id);
    dbms_output.put_line('instance ' || arg_instance_id);
    dbms_output.put_line('resource ' || arg_resource_id);
    dbms_output.put_line('dept' || arg_department_id);
    dbms_output.put_line('serial ' || arg_serial_num);
    dbms_output.put_line('org ' || arg_organization_id);
    ***/

    log_message('first insert for not 24HR');
    log_message('sr instance ' || arg_sr_instance_id);
    log_message('instance ' || arg_instance_id);
    log_message('resource ' || arg_resource_id);
    log_message('dept' || arg_department_id);
    log_message('serial ' || arg_serial_num);
    log_message('org ' || arg_organization_id);


    -- IF NOT 24HR
    if arg_24hr_flag = 2 THEN

        INSERT into msc_net_res_inst_avail(
        	    inst_transaction_id,
        	    plan_id,
        	    sr_instance_id,
                    organization_id,
                    department_id,
		    resource_id,
		    res_instance_id,
		    equipment_item_id,
		    parent_id,
		    serial_number,
		    simulation_set,
                    shift_num,
                    shift_date,
                    from_time,
                    to_time,
                    status,
                    applied,
                    updated,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    refresh_number)
        select      msc_net_res_inst_avail_s.NEXTVAL,
        	    -1,
        	    arg_sr_instance_id,
        	    arg_organization_id,
                    arg_department_id,
	            arg_resource_id,
	            arg_instance_id,
	            dept_ins.equipment_item_id,
	            null,			--PARENT_ID
	            arg_serial_num,
	            arg_simulation_set,
                    res_shifts.shift_num,
                    dates.shift_date,
                    shifts.from_time,
                    shifts.to_time,
                    null,			--STATUS
                    null,			--APPLIED
                    2,				--UPDATED
                    sysdate,
                    var_gt_user_id,
                    sysdate,
                    var_gt_user_id,
                    var_gt_login,
                    var_gt_request,
                    var_gt_application,
                    var_gt_conc_program,
                    sysdate,
                    arg_refresh_number
        FROM        msc_shift_dates dates,
                    msc_shift_times shifts,
                    msc_resource_shifts res_shifts,
	            msc_department_resources dept_res1,
	            msc_dept_res_instances   dept_ins,
                    msc_trading_partners param
        WHERE       dates.calendar_code = param.calendar_code
        AND         dates.exception_set_id = param.calendar_exception_set_id
        AND	    dates.sr_instance_id = param.sr_instance_id
        AND	    dates.sr_instance_id = arg_sr_instance_id
        AND         param.sr_tp_id = arg_organization_id
        AND         dates.shift_num = shifts.shift_num
        AND         dates.seq_num is not null
        AND         dates.shift_date >= trunc(arg_start_date)
        AND         dates.shift_date <= arg_cutoff_date
        AND         shifts.shift_num = res_shifts.shift_num
        AND         shifts.calendar_code = param.calendar_code
        AND	    shifts.sr_instance_id = arg_sr_instance_id
        AND         res_shifts.department_id = dept_res1.department_id
        AND         res_shifts.resource_id = dept_res1.resource_id
        AND         res_shifts.sr_instance_id = arg_sr_instance_id
        AND	    dept_res1.plan_id = -1
        AND         NVL(dept_res1.available_24_hours_flag, 2) = 2
       -- AND         dept_res1.owning_department_id is null
        AND         dept_res1.resource_id = arg_resource_id
	AND         dept_res1.department_id = arg_department_id
	AND	    dept_res1.organization_id = arg_organization_id
	AND	    dept_res1.sr_instance_id = arg_sr_instance_id
	AND         dept_ins.department_id = arg_department_id
	AND	    dept_ins.organization_id = arg_organization_id
	AND	    dept_ins.sr_instance_id = arg_sr_instance_id
	AND         dept_ins.resource_id = arg_resource_id
        AND         dept_ins.res_instance_id = arg_instance_id
	AND  	    dept_ins.plan_id = -1
        AND         nvl(dept_ins.serial_number,-1) = nvl(arg_serial_num, -1)
        AND         NOT EXISTS
                    (SELECT NULL
                     FROM   msc_resource_changes changes
                     WHERE  changes.sr_instance_id = dept_res1.sr_instance_id
                     AND    changes.department_id = dept_res1.department_id
                     AND    changes.resource_id = dept_res1.resource_id
		     AND    changes.simulation_set = arg_simulation_set
                     AND    changes.shift_num = dates.shift_num
                     AND    changes.from_date = dates.shift_date
                     AND    changes.action_type = DELETE_WORKDAY);


	-- debug
	/*
	select count(*) into var_rowcount
	  FROM  msc_net_res_inst_avail
	  where resource_id = arg_resource_id
	  and   instance_id = arg_instance_id
	  and   department_id = arg_department_id;

	  dbms_output.put_line(' Inserted '|| to_char(var_rowcount)||' avails'); */

    else

        --dbms_output.put_line(' Inserted -- it is a 24 hrs');
        log_message(' Inserted -- it is a 24 hrs');
        insert into msc_net_res_inst_avail(
        		inst_transaction_id,
        		plan_id,
        		sr_instance_id,
                        organization_id,
                        department_id,
			resource_id,
			res_instance_id,
			equipment_item_id,
			parent_id,
			serial_number,
			simulation_set,
                        shift_num,
                        shift_date,
                        from_time,
                        to_time,
                        status,
                        applied,
                        updated,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        refresh_number)
            select      msc_net_res_inst_avail_s.NEXTVAL,
            	        -1,
            	        arg_sr_instance_id,
            	        arg_organization_id,
                        arg_department_id,
	                arg_resource_id,
	                arg_instance_id,
	                dept_ins.equipment_item_id,
	                null,			--PARENT_ID
	                arg_serial_num,
	                arg_simulation_set,
                        0,
                        dates.calendar_date,
                        1,
                        24*60*60 - 1,
                        null,			--STATUS
                        null,			--APPLIED
                        2,			--UPDATED
                        sysdate,
                        var_gt_user_id,
                        sysdate,
                        var_gt_user_id,
                        var_gt_login,
                        var_gt_request,
                        var_gt_application,
                        var_gt_conc_program,
                        sysdate,
                        arg_refresh_number
            FROM        msc_calendar_dates dates,
                        msc_department_resources dept_res1,
	                msc_dept_res_instances   dept_ins,
                        msc_trading_partners param
            WHERE       dates.calendar_code = param.calendar_code
            AND         dates.exception_set_id = param.calendar_exception_set_id
            AND	    	dates.sr_instance_id = param.sr_instance_id
            AND		dates.sr_instance_id = arg_sr_instance_id
            AND         dates.calendar_date <= arg_cutoff_date
            AND         dates.seq_num is not null
            AND         dates.calendar_date >= trunc(arg_start_date)
            AND	   	dept_res1.plan_id = -1
            AND         NVL(dept_res1.available_24_hours_flag, 2) = 1
           -- AND         dept_res1.owning_department_id is null
            AND         dept_res1.resource_id = arg_resource_id
            AND         dept_res1.department_id = arg_department_id
            AND		dept_res1.organization_id = arg_organization_id
            AND		dept_res1.sr_instance_id = arg_sr_instance_id
	    AND         dept_ins.department_id = arg_department_id
	    AND         dept_ins.resource_id = arg_resource_id
	    AND         dept_ins.res_instance_id = arg_instance_id
	    AND		dept_ins.organization_id = arg_organization_id
	    AND		dept_ins.sr_instance_id = arg_sr_instance_id
	    AND         dept_ins.plan_id = -1
	    AND         nvl(dept_ins.serial_number,-1) = nvl(arg_serial_num,-1)
	    AND         param.sr_tp_id = arg_organization_id;

	    --dbms_output.put_line('2nd insert row count ' || sql%rowcount);
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

	    /* dbms_output.put_line('cap_change: '||var_orig_from_time||'-'||
				 var_orig_to_time||' '||var_shift_date||' '||
				 var_cap_change);
             */
   	    log_message('cap_change: '||var_orig_from_time||'-'||
				 var_orig_to_time||' '||var_shift_date||' '||
				 var_cap_change);


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
                        var_equipment_item_id,
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
		      --dbms_output.put_line('update only');
		      update_avail(var_rowid,
                             var_shift_date,
			     var_from_shift_time,
			     var_from_time -1);
		   else
		      --dbms_output.put_line('update and insert');
		      update_avail(var_rowid,
			     var_shift_date,
			     var_from_shift_time,
			     var_from_time -1);
		      insert_avail(var_shift_date,
				   arg_department_id,
				   arg_resource_id,
				   arg_instance_id,
				   arg_serial_num,
				   var_equipment_item_id,
                                   arg_organization_id,
                                   arg_sr_instance_id,
                                   var_shift_num,
                                   arg_simulation_set,
                                   var_to_time+1,
                                   var_to_shift_time,
                                   arg_refresh_number);
		   end if;

		elsif var_from_shift_time >= var_from_time then
		   if var_to_shift_time > var_to_time then
		   --dbms_output.put_line('update row');
			 update_avail(var_rowid,
				      var_shift_date,
				      var_to_time+1,
				      var_to_shift_time);
		   else
		         --dbms_output.put_line('delete row ' || var_rowid);
			 delete_avail(var_rowid);
		   end if;
		end if;

                <<skip>>
                NULL;
            end loop;
            close avail;

	    -- Insert modification

	    if var_cap_change = 1 then
	        --dbms_output.put_line('insert the modification');
		insert_avail(var_shift_date,
                                arg_department_id,
				arg_resource_id,
				arg_instance_id,
				arg_serial_num,
				var_equipment_item_id,
                                arg_organization_id,
                                arg_sr_instance_id,
                                var_shift_num,
                                arg_simulation_set,
                                var_from_time,
                                var_to_time,
                                arg_refresh_number);
	    end if;

        end loop;
        close changes;

	--  Finally add the availability from the add workday type modifications
	--dbms_output.put_line('going to insert added workdays');
	log_message('going to insert added workdays');
        INSERT into msc_net_res_inst_avail(
        	    inst_transaction_id,
        	    plan_id,
        	    sr_instance_id,
                    organization_id,
                    department_id,
		    resource_id,
		    res_instance_id,
		    equipment_item_id,
		    parent_id,
		    serial_number,
		    simulation_set,
                    shift_num,
                    shift_date,
                    from_time,
                    to_time,
                    status,
                    applied,
                    updated,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    refresh_number)
        select      msc_net_res_inst_avail_s.NEXTVAL,
        	    -1,
        	    arg_sr_instance_id,
        	    arg_organization_id,
                    arg_department_id,
	            arg_resource_id,
	            arg_instance_id,
	            var_equipment_item_id,
	            null,			--PARENT_ID
	            arg_serial_num,
	            arg_simulation_set,
                    changes.shift_num,
                    changes.from_date,
                    changes.from_time,
                    changes.to_time,
                    null,			--STATUS
                    null,			--APPLIED
                    2,				--UPDATED
                    sysdate,
                    var_gt_user_id,
                    sysdate,
                    var_gt_user_id,
                    var_gt_login,
                    var_gt_request,
                    var_gt_application,
                    var_gt_conc_program,
                    sysdate,
                    arg_refresh_number
        FROM        msc_res_instance_changes changes
        WHERE       changes.sr_instance_id = arg_sr_instance_id
        AND	    changes.department_id = arg_department_id
	AND         changes.resource_id = arg_resource_id
        and         changes.res_instance_id = arg_instance_id
	and         nvl(changes.serial_number,-1) = nvl(arg_serial_num, -1)
        AND         changes.action_type = ADD_WORKDAY
	AND         changes.simulation_set= arg_simulation_set;


    end if;

EXCEPTION
	WHEN OTHERS THEN
		MSC_UTIL.MSC_DEBUG('Error in calc_ins_avail:: ' || to_char(sqlcode) || ':'
		|| substr(sqlerrm,1,60));
          --dbms_output.put_line('Error in calc_ins_avail ' || sqlerrm);

END calc_res_ins_avail;

-- This procedule is used to populate resource for each simulation set
-- within an organization instance
--

PROCEDURE populate_avail_res_instances(
                                   arg_refresh_number  IN number,
                                   arg_refresh_flag    IN number,
                                   arg_simulation_set  IN varchar2,
                                   arg_organization_id IN number,
				   arg_sr_instance_id  IN number,
				   arg_start_date      IN date,
                                   arg_cutoff_date     IN date) IS

CURSOR dept_res is
    SELECT  dept_res.department_id,
            dept_res.resource_id,
            dept_ins.res_instance_id,
            dept_ins.serial_number,
            dept_ins.equipment_item_id,
            NVL(dept_res.available_24_hours_flag, 2),
	    dept_res.aggregate_resource_id,
            NVL(dept_res.capacity_units,1), --**
            dept_res.disable_date  --, --**
            --org.calendar_code, --**
           -- org.calendar_exception_set_id --**
    FROM    msc_trading_partners org,
            msc_department_resources dept_res,
            msc_dept_res_instances dept_ins
    WHERE   dept_res.owning_department_id = dept_res.department_id
    AND     dept_res.plan_id = -1
    AND     dept_res.resource_id <> -1
    AND     dept_res.aggregate_resource_flag <> 1 -- if it's not aggregate
    AND     NVL(dept_res.disable_date,sysdate+1) > sysdate
    AND     dept_res.organization_id = org.sr_tp_id
    AND     dept_res.sr_instance_id = org.sr_instance_id
    AND     org.sr_tp_id= arg_organization_id
    AND     org.sr_instance_id= arg_sr_instance_id
    AND     org.partner_type=3
    AND	    dept_res.plan_id = dept_ins.plan_id
    AND     dept_res.organization_id = dept_ins.organization_id
    AND	    dept_res.sr_instance_id = dept_ins.sr_instance_id
    AND	    dept_res.department_id = dept_ins.department_id
    AND     dept_res.resource_id = dept_ins.resource_id
    /*
    	adding the following condition that the collection for the resource
    	instances for only there is any resource instance change   */
    AND	 exists (select * from msc_res_instance_changes chg
    		   where dept_ins.department_id = chg.department_id
    		   and   dept_ins.resource_id = chg.resource_id
    		   and   dept_ins.sr_instance_id = chg.sr_instance_id
		   and   dept_ins.res_instance_id = chg.res_instance_id
		   and   dept_ins.serial_number  = chg.serial_number);


CURSOR dept_res_change is
    SELECT distinct dept_res.department_id,
            dept_res.resource_id,
            res_ins.res_instance_id,
            res_ins.serial_number,
            NVL(dept_res.available_24_hours_flag, 2),
	    dept_res.aggregate_resource_id,
            NVL(dept_res.capacity_units,1), --**
            dept_res.disable_date  --, --**
            --org.calendar_code, --**
           -- org.calendar_exception_set_id --**
    FROM    msc_trading_partners org,
            msc_resource_changes chg,
            msc_department_resources dept_res,
            msc_res_instance_changes res_ins
    WHERE   chg.department_id = dept_res.department_id
    AND     chg.resource_id = dept_res.resource_id
    AND     chg.sr_instance_id = dept_res.sr_instance_id
    AND     chg.refresh_number = arg_refresh_number
    AND     dept_res.owning_department_id = dept_res.department_id
    AND     dept_res.plan_id = -1
    AND     dept_res.resource_id <> -1
    AND     dept_res.aggregate_resource_flag <> 1 -- if it's not aggregate
    AND     NVL(dept_res.disable_date,sysdate+1) > sysdate
    AND     dept_res.organization_id = org.sr_tp_id
    AND     dept_res.sr_instance_id = org.sr_instance_id
    AND     org.sr_tp_id= arg_organization_id
    AND     org.sr_instance_id= arg_sr_instance_id
    AND     org.partner_type=3
    AND     chg.sr_instance_id = res_ins.sr_instance_id
    AND     chg.department_id = res_ins.department_id
    AND     chg.resource_id = res_ins.resource_id;

    var_department_id   NUMBER;
    var_resource_id     NUMBER;
    var_24hr_flag       NUMBER;
    v_cutoff_date       DATE;
    v_start_date        DATE;
    var_aggregate_resource_id NUMBER;

    var_capacity_units  NUMBER;  -- new variables for calling calc_res_avail
    var_disable_date    DATE;

    var_res_instance_id 	NUMBER;
    var_serial_number		msc_dept_res_instances.serial_number%type;
    var_equipment_item_id		msc_dept_res_instances.equipment_item_id%type;

BEGIN

    var_gt_date		:= SYSDATE;
    var_gt_user_id	:= FND_GLOBAL.USER_ID;
    var_gt_login	:= FND_GLOBAL.LOGIN_ID;
    var_gt_request	:= FND_GLOBAL.CONC_REQUEST_ID;
    var_gt_application	:= FND_GLOBAL.PROG_APPL_ID;
    var_gt_conc_program := FND_GLOBAL.CONC_PROGRAM_ID;

    LOG_MESSAGE('--------------------------------------------------------');
    LOG_MESSAGE(' Populating Available Resources Instances...............');
    LOG_MESSAGE('--------------------------------------------------------');




    if arg_start_date is null then
       v_start_date := check_start_date(arg_organization_id, arg_sr_instance_id);
    else
       v_start_date := arg_start_date;
    end if;

    if arg_cutoff_date is null then
        v_cutoff_date := check_cutoff_date(arg_organization_id, arg_sr_instance_id);
    else
        v_cutoff_date := arg_cutoff_date;
    end if;

    if arg_refresh_flag = 1 then
      -- process complete refresh

      OPEN dept_res;
      LOOP
        Fetch dept_res into var_department_id,
                            var_resource_id,
                            var_res_instance_id,
                            var_serial_number,
                            var_equipment_item_id,
                            var_24hr_flag,
			    var_aggregate_resource_id,
                            var_capacity_units,
                            var_disable_date;
                            --v_calendar_code,
                            --v_calendar_exception_set_id;

        EXIT WHEN dept_res%NOTFOUND;
   	--dbms_output.put_line('Process all changed dept resource for complete refresh');
        log_message('Process all changed dept resource for complete refresh');
        calc_res_ins_avail(
		       arg_organization_id,
		       arg_sr_instance_id,
                       var_department_id,
                       var_resource_id,
                       arg_simulation_set,
                       var_res_instance_id,
                       var_serial_number,
                       var_equipment_item_id,
                       var_24hr_flag,
                       v_start_date,
                       v_cutoff_date,
                       arg_refresh_number);
        commit;
         SAVEPOINT SP1;
       END LOOP;

       CLOSE dept_res;

   else
      -- process all changed department resources

      OPEN dept_res_change;
      LOOP
        Fetch dept_res_change into var_department_id,
                                   var_resource_id,
                                   var_res_instance_id,
                                   var_serial_number,
                                   var_24hr_flag,
			           var_aggregate_resource_id,
                                   var_capacity_units,
                                   var_disable_date;
                                   --v_calendar_code,
                                   --v_calendar_exception_set_id;

        EXIT WHEN dept_res_change%NOTFOUND;
   	--dbms_output.put_line('Process all changed dept resource for net change');
   	log_message('Process all changed dept resource for net change');
        calc_res_ins_avail(
		       arg_organization_id,
		       arg_sr_instance_id,
                       var_department_id,
                       var_resource_id,
                       arg_simulation_set,
                       var_res_instance_id,
                       var_serial_number,
                       var_equipment_item_id,
                       var_24hr_flag,
                       v_start_date,
                       v_cutoff_date,
                       arg_refresh_number);
        commit;
         SAVEPOINT SP1;
       END LOOP;

       CLOSE dept_res_change;

   end if;


EXCEPTION
	WHEN OTHERS THEN
		MSC_UTIL.MSC_DEBUG('Error in populate_avail_res_instances:: ' || to_char(sqlcode) ||
			':' || substr(sqlerrm,1,60));


        IF dept_res%isopen        THEN CLOSE dept_res;        END IF;
        IF dept_res_change%isopen THEN CLOSE dept_res_change; END IF;


END populate_avail_res_instances;

--
-- This procedulre populate all resources for an organization.
--

PROCEDURE populate_org_res_instances( RETCODE             OUT NOCOPY number,
                                  arg_refresh_flag    IN  number,
                                  arg_refresh_number  IN  number,
				  arg_organization_id IN  number,
				  arg_sr_instance_id  IN  number,
				  arg_start_date      IN  date,
                                  arg_cutoff_date     IN  date ) IS

CURSOR c_simulation_set IS
    SELECT simulation_set
    FROM   msc_simulation_sets
    WHERE  organization_id = arg_organization_id
    AND    sr_instance_id = arg_sr_instance_id;

 var_simulation_set  VARCHAR2(10);
 var_return_status   NUMBER;

BEGIN

  LOG_MESSAGE('========================================================');
  LOG_MESSAGE('Populating Org Resources for the Org: '|| arg_organization_id);
  LOG_MESSAGE('========================================================');

  MSC_UTIL.MSC_DEBUG('Creating resource for all simulation set ....');
  MSC_UTIL.MSC_DEBUG('Org Id:' || to_char(arg_organization_id));
  MSC_UTIL.MSC_DEBUG('Instance:' || to_char(arg_sr_instance_id));


  -- For complete refresh, the collection program will handle deleting all
  -- resource avail.
  -- For net change, refresh_flag = 2, delete resourse instance availability of
  -- all department resources with the new refresh number.

   if arg_refresh_flag = 2 then
   --  v_stmt := 100;

     --dbms_output.put_line('Delete msc_net_res_inst_avail');
     log_message('Delete msc_net_res_inst_avail');

     delete from msc_net_res_inst_avail
     where rowid in (select res.rowid
                     from msc_net_res_inst_avail res,
                          msc_resource_changes   chg,
                          msc_department_resources dept
                     where res.organization_id = arg_organization_id
                       and res.sr_instance_id = arg_sr_instance_id
                       and res.plan_id = -1
                       and res.department_id = chg.department_id
                       and res.resource_id = chg.resource_id
                       and chg.sr_instance_id = arg_sr_instance_id
                       and chg.refresh_number = arg_refresh_number
                       and dept.department_id = chg.department_id
                       and dept.resource_id = chg.resource_id
                       and dept.line_flag <> 1
                       and dept.plan_id = -1
                       and dept.organization_id = arg_organization_id
                       and dept.sr_instance_id = arg_sr_instance_id );

     --dbms_output.put_line('Number of row deleted from net change ' || sql%rowcount);
     log_message('Number of row deleted from net change ' || sql%rowcount);
   end if;


    -- Populate resource without simulation set

    var_simulation_set := NULL;

    LOG_MESSAGE(' Populating Org Resources Instances for Null Simulation Set ......');
    --dbms_output.put_line('Populating org res inst for null simulation set');

    populate_avail_res_instances (
                              arg_refresh_number,
                              arg_refresh_flag,
                              var_simulation_set,
		  	      arg_organization_id,
		       	      arg_sr_instance_id,
                       	      arg_start_date,
                       	      arg_cutoff_date);


    -- Populate resource for each simulation set belong to the organization

    OPEN c_simulation_set;
    LOOP
        Fetch c_simulation_set into var_simulation_set;

        EXIT WHEN c_simulation_set%NOTFOUND;

        LOG_MESSAGE(' Populating Org Resources Instances for the Simulation Set :'||var_simulation_set);
        --dbms_output.put_line('Populating org res inst for the simulation set ' || var_simulation_set);
        populate_avail_res_instances (
                                  arg_refresh_number,
                                  arg_refresh_flag,
                                  var_simulation_set,
				  arg_organization_id,
		       	          arg_sr_instance_id,
                       		  arg_start_date,
                       		  arg_cutoff_date );

    END LOOP;

    CLOSE c_simulation_set;
 -- COMMIT;

    retcode := 0 ;
    return;

    EXCEPTION
      WHEN OTHERS THEN
     --   dbms_output.put_line('exception: ' || to_char(v_stmt) || ' - ' ||
      --                to_char(sqlcode) ||':'|| substr(sqlerrm,1,60));

        IF c_simulation_set%isopen THEN
            CLOSE c_simulation_set;
        END IF;


       IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN

        LOG_MESSAGE('========================================');
        FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', 'POPULATE_ORG_RES_INSTANCES');
        FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_NET_RES_INST_AVAIL');
        LOG_MESSAGE(FND_MESSAGE.GET);

        LOG_MESSAGE(SQLERRM);


       END IF;

        --dbms_output.put_line('Error in populate_org_res_instance ' || sqlerrm);
        retcode :=SQLCODE;
        return;

END populate_org_res_instances;

PROCEDURE LOG_MESSAGE( pBUFF                     IN  VARCHAR2)
   IS
   BEGIN

     IF fnd_global.conc_request_id > 0 THEN   -- concurrent program
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
         --DBMS_OUTPUT.PUT_LINE( pBUFF);
       NULL;
     END IF;
END LOG_MESSAGE;


END MSC_NET_RES_INST_AVAILABILITY;

/
