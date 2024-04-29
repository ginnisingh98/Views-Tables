--------------------------------------------------------
--  DDL for Package Body MSC_RESOURCE_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_RESOURCE_AVAILABILITY" AS
/* $Header: MSCRAVLB.pls 120.6.12010000.2 2009/02/03 10:16:58 lsindhur ship $  */

DELETE_WORKDAY  CONSTANT number := 1;
CHANGE_WORKDAY  CONSTANT number := 2;
ADD_WORKDAY     CONSTANT number := 3;
HOLD_TIME       CONSTANT number := 9999999;
v_stmt          NUMBER;


--v_current_date         DATE;    -- added for testing the performance
--v_current_user         NUMBER;
v_current_request      NUMBER;
v_current_login        NUMBER;
v_current_application  NUMBER;
v_current_conc_program NUMBER;
v_calendar_code                VARCHAR2(14);
v_calendar_exception_set_id    NUMBER;

/* the following parameters are used for better performance in
   data collection program */
v_old_calendar_code            VARCHAR2(14):='*';
v_old_calendar_ex_set_id       NUMBER:= 0;
v_old_start_date               DATE:= SYSDATE;
v_old_cutoff_date              DATE:= SYSDATE;
v_old_disable_date             DATE:= SYSDATE;
v_old_sr_instance_id           NUMBER:= 0;

/* added this variable to show the warning message -bug 3022523*/
    v_show_warning  number;

TYPE DateTab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
v_workdate        DateTab;
v_workdate_count  NUMBER;

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

FUNCTION check_24(var_time  in  number) return number IS
BEGIN

    IF var_time > 24*3600 then
        return var_time - 24*3600;
    ELSE
        return var_time;
    END if;

END check_24;

FUNCTION check_start_date(
                          arg_organization_id in number,
                          arg_sr_instance_id  in number) return DATE IS
v_start_date date;

BEGIN

 v_stmt := 10;
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
        LOG_MESSAGE(FND_MESSAGE.Get);

END check_start_date;

FUNCTION check_cutoff_date(arg_organization_id in number,
                           arg_sr_instance_id  in number) return DATE IS
v_cutoff_date date;

BEGIN

 v_stmt := 20;
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
        LOG_MESSAGE(FND_MESSAGE.Get);

END check_cutoff_date;

PROCEDURE  update_avail(
			 var_rowid      in  ROWID,
                         var_from_time  in  number,
                         var_to_time    in  number) IS
var_time1   number;
var_time2   number;

BEGIN

  if var_from_time >= 86400 AND var_to_time >= 86400 then
    var_time1 := check_24(var_to_time);
    var_time2 := check_24(var_from_time);
  else
    var_time1 := var_to_time;
    var_time2 := var_from_time;
  end if;

    v_stmt := 30;

    if var_from_time >= 86400 AND var_to_time >= 86400 then

      UPDATE  MSC_net_resource_avail
      SET     to_time = var_time1,
              from_time =var_time2,
              shift_date = shift_date + 1
      WHERE   rowid = var_rowid;

   else

    UPDATE  MSC_net_resource_avail
    SET     to_time = var_time1,
            from_time = var_time2
    WHERE   rowid = var_rowid;

  end if;

  if( v_show_warning is null) then
	 v_show_warning := 0;
  end if;

    EXCEPTION
      WHEN OTHERS THEN
        LOG_MESSAGE('Error::('|| to_char(v_stmt) || ')::' ||
                      to_char(sqlcode) ||':'|| substr(sqlerrm,1,60));

	 v_show_warning :=SQLCODE;



END         update_avail;

PROCEDURE  delete_avail(var_rowid in  ROWID) IS
BEGIN

    v_stmt := 40;
    DELETE  from MSC_net_resource_avail
    WHERE   rowid = var_rowid;

    if( v_show_warning is null) then
	 v_show_warning := 0;
  end if;

    EXCEPTION
      WHEN OTHERS THEN
        LOG_MESSAGE('Error::('|| to_char(v_stmt) || ')::' ||
                      to_char(sqlcode) ||':'|| substr(sqlerrm,1,60));
         v_show_warning :=SQLCODE;

END delete_avail;

PROCEDURE   insert_avail( var_date            in  DATE,
                          var_department_id   in  number,
                          var_resource_id     in  number,
                          var_organization_id in  number,
		          var_sr_instance_id  in  number,
                          var_shift_num       in  number,
                          var_simulation_set  in  varchar2,
                          var_from_time       in  number,
                          var_to_time         in  number,
                          var_cap_units       in  number,
			  var_aggregate_resource_id in number,
                          var_refresh_number  in  number) IS
var_time1   number;
var_time2   number;
var_transaction_id number;

BEGIN

   MSC_UTIL.MSC_DEBUG('Org: ' || to_char(var_organization_id));
   MSC_UTIL.MSC_DEBUG('Instance: ' || to_char(var_sr_instance_id));
   MSC_UTIL.MSC_DEBUG('Sim Set: ' || var_simulation_set);
   MSC_UTIL.MSC_DEBUG('Dept: ' || to_char(var_department_id));
   MSC_UTIL.MSC_DEBUG('Resource: ' || to_char(var_resource_id));

   var_time1 := check_24(var_from_time);
   var_time2 := check_24(var_to_time);

    v_stmt := 50;

    v_stmt := 60;
    INSERT into MSC_net_resource_avail(
		    transaction_id,
                    plan_id,
                    department_id,
                    resource_id,
                    organization_id,
		    sr_instance_id,
                    shift_num,
                    shift_date,
                    from_time,
                    to_time,
                    capacity_units,
                    simulation_set,
                    aggregate_resource_id,
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
             VALUES(
                    msc_net_resource_avail_s.NEXTVAL
                    , -1
                    ,var_department_id
                    ,var_resource_id
                    ,var_organization_id
                    ,var_sr_instance_id
                    ,var_shift_num
                    ,var_date
                    ,var_from_time
                    ,var_to_time
                    ,var_cap_units
                    ,var_simulation_set
                    ,var_aggregate_resource_id
	            ,NULL  /* STATUS */
                    ,NULL  /* APPLIED */
                    ,2     /* UPDATED */
                    ,MSC_CL_COLLECTION.v_current_date
                    ,MSC_CL_COLLECTION.v_current_user
                    ,MSC_CL_COLLECTION.v_current_date
                    ,MSC_CL_COLLECTION.v_current_user
                    ,v_current_login
                    ,v_current_request
                    ,v_current_application
                    ,v_current_conc_program
                    ,MSC_CL_COLLECTION.v_current_date
                    ,var_refresh_number);
    if( v_show_warning is null) then
	 v_show_warning := 0;
  end if;

    EXCEPTION
      WHEN OTHERS THEN
       -- dbms_output.put_line('exception: ' || to_char(v_stmt) || ' - ' ||
       --               to_char(sqlcode) ||':'|| substr(sqlerrm,1,60));
        LOG_MESSAGE('Error::('|| to_char(v_stmt) || ')::' ||
                      to_char(sqlcode) ||':'|| substr(sqlerrm,1,60));

         v_show_warning :=SQLCODE;

END insert_avail;

PROCEDURE calc_res_avail( arg_organization_id IN  number,
                          arg_sr_instance_id  IN  number,
                          arg_department_id   IN  number,
                          arg_resource_id     IN  number,
                          arg_simulation_set  IN  varchar2,
                          arg_24hr_flag       IN  number,
                          arg_start_date      IN  date ,
                          arg_cutoff_date     IN  date,
			  arg_aggregate_resource_id IN NUMBER,
                          arg_refresh_number  IN  number,
                          arg_capacity_units  IN  number,
                          arg_disable_date    IN  DATE) IS

CURSOR changes IS
    SELECT  changes.action_type,
            changes.from_time,
            DECODE(LEAST(changes.to_time, changes.from_time),
                changes.to_time, changes.to_time + 24*3600,
                changes.to_time),
            dates.shift_date,
            changes.shift_num,
            changes.capacity_change
    from    msc_shift_dates dates,
            msc_resource_changes changes
    WHERE   dates.calendar_code = v_calendar_code
    AND     dates.sr_instance_id = arg_sr_instance_id
    AND     dates.exception_set_id = v_calendar_exception_set_id
    AND     dates.seq_num is not null
    AND     dates.shift_date between changes.from_date AND
                NVL(changes.to_date, changes.from_date)
    AND     dates.shift_num = changes.shift_num
    AND     changes.to_date >= trunc(arg_start_date)
    AND     changes.from_date <= arg_cutoff_date
    AND     changes.simulation_set = arg_simulation_set
    AND     changes.action_type = CHANGE_WORKDAY
    AND     changes.resource_id = arg_resource_id
    AND     changes.department_id = arg_department_id
    AND     changes.sr_instance_id = arg_sr_instance_id
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
    var_transaction_id          number;
    var_aggregate_resource_id   number;
    var_calendar_date		date;
    var_capacity		number;

    /* add index hint for better performance */
CURSOR avail IS
    SELECT  /*+ index (nra MSC_NET_RESOURCE_AVAIL_U2 )*/
            capacity_units capacity_units,
            from_time from_time,
            to_time to_time,
            rowid
    FROM    MSC_net_resource_avail nra
    WHERE   plan_id = -1
    AND     sr_instance_id  = arg_sr_instance_id
    AND     organization_id = arg_organization_id
    AND     department_id = arg_department_id
    AND     resource_id = arg_resource_id
    AND     simulation_set = arg_simulation_set
    AND     shift_num = var_shift_num
    AND     shift_date = var_shift_date
    UNION ALL
    SELECT  0 capacity_units,
            HOLD_TIME from_time,
            HOLD_TIME to_time,
            rowid
    from    dual
    ORDER BY 2, 3;

BEGIN

    if arg_24hr_flag = 2 THEN

       v_stmt := 70;

        if (arg_disable_date IS NOT NULL) then

		  INSERT into MSC_net_resource_avail(
	                transaction_id,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    department_id,
                    resource_id,
                    shift_num,
                    shift_date,
                    from_time,
                    to_time,
                    capacity_units,
                    simulation_set,
                    aggregate_resource_id,
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
                    program_update_date)
          SELECT    msc_net_resource_avail_s.NEXTVAL
		    ,-1
                    ,arg_organization_id
                    ,arg_sr_instance_id
                    ,arg_department_id
                    ,arg_resource_id
                    ,res_shifts.shift_num
                    ,arg_disable_date
                    ,0
                    ,0
                    ,0
                    ,arg_simulation_set
                    ,arg_aggregate_resource_id
	            ,NULL  /* STATUS */
                    ,NULL  /* APPLIED */
                    ,2     /* UPDATED */
                    ,MSC_CL_COLLECTION.v_current_date
                    ,MSC_CL_COLLECTION.v_current_user
                    ,MSC_CL_COLLECTION.v_current_date
                    ,MSC_CL_COLLECTION.v_current_user
                    ,v_current_login
                    ,v_current_request
                    ,v_current_application
                    ,v_current_conc_program
                    ,MSC_CL_COLLECTION.v_current_date
			FROM
			msc_resource_shifts res_shifts
			WHERE
			res_shifts.department_id = arg_department_id
			AND  res_shifts.resource_id = arg_resource_id
			AND  res_shifts.sr_instance_id = arg_sr_instance_id;

		  if (arg_disable_date < sysdate) then
			 -- If the disable date is in the past, just return!
			 return;
		  end if;

	   end if;

       INSERT into MSC_net_resource_avail(
	            transaction_id,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    department_id,
                    resource_id,
                    shift_num,
                    shift_date,
                    from_time,
                    to_time,
                    capacity_units,
                    simulation_set,
                    aggregate_resource_id,
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
                    program_update_date)
          SELECT    msc_net_resource_avail_s.NEXTVAL
		    ,-1
                    ,arg_organization_id
                    ,arg_sr_instance_id
                    ,arg_department_id
                    ,arg_resource_id
                    ,res_shifts.shift_num
                    ,dates.shift_date
                    ,shifts.from_time
                    ,decode(least(shifts.from_time,shifts.to_time),shifts.to_time,shifts.to_time+86400,shifts.to_time)
                    ,decode(changes.action_type,DELETE_WORKDAY,0,nvl(res_shifts.capacity_units,arg_capacity_units))
                    ,arg_simulation_set
                    ,arg_aggregate_resource_id
	            ,NULL  /* STATUS */
                    ,NULL  /* APPLIED */
                    ,2     /* UPDATED */
                    ,MSC_CL_COLLECTION.v_current_date
                    ,MSC_CL_COLLECTION.v_current_user
                    ,MSC_CL_COLLECTION.v_current_date
                    ,MSC_CL_COLLECTION.v_current_user
                    ,v_current_login
                    ,v_current_request
                    ,v_current_application
                    ,v_current_conc_program
                    ,MSC_CL_COLLECTION.v_current_date
  FROM    msc_shift_dates dates,
          msc_shift_times shifts,
          msc_resource_shifts res_shifts,
	  (select distinct department_id, resource_id,
                           sr_instance_id, simulation_set,
                           from_date, shift_num,action_type
                           From MSC_RESOURCE_CHANGES
                           where action_type = DELETE_WORKDAY ) changes  --7705958
 WHERE  dates.calendar_code = v_calendar_code
   AND  dates.sr_instance_id = arg_sr_instance_id
   AND  dates.exception_set_id = v_calendar_exception_set_id
   AND  dates.shift_num = shifts.shift_num
   AND  dates.seq_num is not null
   AND  dates.shift_date >= trunc(arg_start_date)
   AND  dates.shift_date <= least(trunc(arg_cutoff_date),
                               trunc(NVL(arg_disable_date-1,arg_cutoff_date)))
   AND  shifts.shift_num = res_shifts.shift_num
   AND  shifts.calendar_code = v_calendar_code
   AND  shifts.sr_instance_id= arg_sr_instance_id
   AND  res_shifts.department_id = arg_department_id
   AND  res_shifts.resource_id = arg_resource_id
   AND  res_shifts.sr_instance_id = arg_sr_instance_id
      /* Bug 6648494 incorporated here */
   AND  changes.department_id (+) = arg_department_id
   AND  changes.resource_id (+) = arg_resource_id
   AND  changes.sr_instance_id (+) = arg_sr_instance_id
   AND  changes.simulation_set (+) = arg_simulation_set
   AND  changes.from_date (+) = dates.shift_date
   AND  changes.shift_num (+) = dates.shift_num;


/* Due to the performace issues, the delete_workday is handled
   by the next UPDATE SQL statements.

   AND ( arg_simulation_set is null
         OR NOT EXISTS
         (SELECT NULL
          FROM  msc_resource_changes changes
          WHERE  changes.department_id = arg_department_id
            AND  changes.resource_id = arg_resource_id
            AND  changes.sr_instance_id = arg_sr_instance_id
            AND  changes.shift_num = dates.shift_num
            AND  changes.from_date = dates.shift_date
            AND  changes.simulation_set= arg_simulation_set
            AND  changes.action_type = DELETE_WORKDAY) );


        IF arg_simulation_set IS NOT NULL THEN

              UPDATE MSC_NET_RESOURCE_AVAIL
                 SET capacity_units= 0
               WHERE ROWID IN
                   ( select /*+ ordered index (nra MSC_NET_RESOURCE_AVAIL_U2 )*/
                           /* nra.ROWID
                       from MSC_RESOURCE_CHANGES changes,
                            MSC_NET_RESOURCE_AVAIL nra
                      WHERE changes.department_id = arg_department_id
                        AND changes.resource_id = arg_resource_id
                        AND changes.sr_instance_id = arg_sr_instance_id
                        AND changes.simulation_set= arg_simulation_set
                        AND changes.action_type = DELETE_WORKDAY
                        AND changes.from_date >= trunc(arg_start_date)
                        AND changes.from_date <= arg_cutoff_date
                        AND nra.plan_id= -1
                        AND nra.sr_instance_id= changes.sr_instance_id
                        AND nra.organization_id= arg_organization_id
                        AND nra.simulation_set= changes.simulation_set
                        AND nra.department_id= changes.department_id
                        AND nra.resource_id= changes.resource_id
                        AND nra.shift_num= changes.shift_num
                        AND nra.shift_date= changes.from_date );

        END IF; /*6648494 */

    ELSE

        if (arg_disable_date IS NOT NULL) then

		  INSERT into MSC_net_resource_avail(
                        transaction_id,
                        plan_id,
                        organization_id,
                        sr_instance_id,
                        department_id,
                        resource_id,
                        shift_num,
                        shift_date,
                        from_time,
                        to_time,
                        capacity_units,
                        simulation_set,
                        aggregate_resource_id,
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
                        program_update_date)
                VALUES( msc_net_resource_avail_s.NEXTVAL
			,-1
			,arg_organization_id
			,arg_sr_instance_id
                        ,arg_department_id
                        ,arg_resource_id
                        ,0
                        ,arg_disable_date
                        ,0
                        ,0
                        ,0
                        ,arg_simulation_set
                        ,arg_aggregate_resource_id
	                ,NULL  /* STATUS */
                        ,NULL  /* APPLIED */
                        ,2     /* UPDATED */
                        ,MSC_CL_COLLECTION.v_current_date
                        ,MSC_CL_COLLECTION.v_current_user
                        ,MSC_CL_COLLECTION.v_current_date
                        ,MSC_CL_COLLECTION.v_current_user
                        ,v_current_login
                        ,v_current_request
                        ,v_current_application
                        ,v_current_conc_program
                        ,MSC_CL_COLLECTION.v_current_date);

		  if (arg_disable_date < sysdate) then
			 -- If the disable date is in the past, just return!
			 return;
		  end if;

	   end if;

       v_stmt := 80;

       IF v_old_calendar_code <> v_calendar_code OR
          v_old_calendar_ex_set_id <> v_calendar_exception_set_id OR
          v_old_start_date <> arg_start_date OR
          v_old_cutoff_date <> arg_cutoff_date OR
          nvl(v_old_disable_date,trunc(sysdate - 1000)) <>
			 nvl(arg_disable_date, trunc(sysdate - 1000)) OR
          v_old_sr_instance_id <> arg_sr_instance_id THEN

          BEGIN
          SELECT dates.calendar_date
            BULK COLLECT
            INTO v_workdate
           FROM  msc_calendar_dates dates
          WHERE  dates.calendar_code = v_calendar_code
            AND  dates.exception_set_id = v_calendar_exception_set_id
            AND  dates.sr_instance_id = arg_sr_instance_id
            AND  dates.calendar_date >= trunc(arg_start_date)
            AND  dates.calendar_date <= least(trunc(arg_cutoff_date),
                               trunc(NVL(arg_disable_date-1,arg_cutoff_date)))
            AND  dates.seq_num is not null;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN NULL;
             WHEN OTHERS THEN RAISE;
          END;
          v_workdate_count:= SQL%ROWCOUNT;

          v_old_calendar_code := v_calendar_code;
          v_old_calendar_ex_set_id := v_calendar_exception_set_id;
          v_old_start_date   := arg_start_date;
          v_old_cutoff_date  := arg_cutoff_date;
          v_old_disable_date := arg_disable_date;
          v_old_sr_instance_id   := arg_sr_instance_id;

       END IF;  -- calendar_code, calendar_exception_set_id

       FORALL j IN 1..v_workdate_count
       INSERT into MSC_net_resource_avail(
                        transaction_id,
                        plan_id,
                        organization_id,
                        sr_instance_id,
                        department_id,
                        resource_id,
                        shift_num,
                        shift_date,
                        from_time,
                        to_time,
                        capacity_units,
                        simulation_set,
                        aggregate_resource_id,
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
                        program_update_date)
                VALUES( msc_net_resource_avail_s.NEXTVAL
			,-1
			,arg_organization_id
			,arg_sr_instance_id
                        ,arg_department_id
                        ,arg_resource_id
                        ,0
                        ,v_workdate(j)
                        ,0
                        ,24*60*60
                        ,arg_capacity_units
                        ,arg_simulation_set
                        ,arg_aggregate_resource_id
	                ,NULL  /* STATUS */
                        ,NULL  /* APPLIED */
                        ,2     /* UPDATED */
                        ,MSC_CL_COLLECTION.v_current_date
                        ,MSC_CL_COLLECTION.v_current_user
                        ,MSC_CL_COLLECTION.v_current_date
                        ,MSC_CL_COLLECTION.v_current_user
                        ,v_current_login
                        ,v_current_request
                        ,v_current_application
                        ,v_current_conc_program
                        ,MSC_CL_COLLECTION.v_current_date);

    END if;  -- arg_24hr_flag


 IF  arg_simulation_set IS NOT NULL THEN

    if arg_24hr_flag = 2 then

        OPEN changes;
        LOOP
            FETCH changes INTO
                    var_action_type,
                    var_orig_from_time,
                    var_orig_to_time,
                    var_shift_date,
                    var_shift_num,
                    var_cap_change;

            EXIT WHEN changes%NOTFOUND;

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
                END if;

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
                    -- If the modification overlaps a shift segment then set
                    -- the END time of the modification to the least of the
                    -- modification END time or shift end time
                    if (var_from_time < var_to_shift_time)  then
                        var_to_time := LEAST(var_to_shift_time, var_to_time);
                        var_next_from_time := var_to_time + 1;
                    else
                    -- Otherwise the modification does not overlap with the
                    -- shift. In that case do not process and leave it for the
                    -- next shift segment
                        goto skip;
                    END if;
                END if;

                /*
                If the modification starts before the shift starts and
                ENDs after the shift starts but on or before the shift ends */
                if var_from_shift_time > var_from_time AND
                        var_from_shift_time <= var_to_time AND
                        var_to_time <= var_to_shift_time THEN

                    if var_to_time < var_to_shift_time then
                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
				     arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_from_time,
                                     var_from_shift_time - 1,
                                     var_cap_change,
				     arg_aggregate_resource_id,
                                     arg_refresh_number);

		     /* Bug 2727286 */
                    if var_to_time = var_from_shift_time then
                      /* Nothing to do */
                      null;

                    else
                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
				     arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_from_shift_time,
                                     var_to_time,
                                     var_orig_cap + var_cap_change,
				     arg_aggregate_resource_id,
                                     arg_refresh_number);

                        update_avail(
					var_rowid,
                                        var_to_time + 1,
                                        var_to_shift_time);

                  end if; /* Bug 2727286 */

                    /* Otherwise the to time and the shift END time are
                    the same */
                    else
                        delete_avail(
					var_rowid);
                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
				     arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_from_time,
                                     var_from_shift_time - 1,
                                     var_cap_change,
				     arg_aggregate_resource_id,
                                     arg_refresh_number);

                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
			             arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_from_shift_time,
                                     var_to_shift_time,
                                     var_orig_cap + var_cap_change,
				     arg_aggregate_resource_id,
                                     arg_refresh_number);
                    END if;
                END if;
                /* If the modification starts before the shift starts and
                ENDs before the shift starts */
                if var_from_shift_time > var_from_time and
                        var_from_shift_time > var_to_time THEN
                    insert_avail(
				    var_shift_date,
                                    arg_department_id,
                                    arg_resource_id,
                                    arg_organization_id,
				    arg_sr_instance_id,
                                    var_shift_num,
                                    arg_simulation_set,
                                    var_from_time,
                                    var_to_time,
                                    var_cap_change,
				    arg_aggregate_resource_id,
                                    arg_refresh_number);
                END if;
                /* If the modification starts after the shift starts but ENDs
                before the shift ENDs */
                if var_from_time >= var_from_shift_time AND
                    var_to_shift_time >= var_to_time THEN
                    /* If the modification times match the shift time
                    exactly */
                    if var_from_time = var_from_shift_time AND
                        var_to_shift_time = var_to_time THEN

                        delete_avail(
					var_rowid);

                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
			             arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_from_time,
                                     var_to_time,
                                     var_orig_cap + var_cap_change,
			             arg_aggregate_resource_id,
                                     arg_refresh_number);
                    elsif var_from_time = var_from_shift_time THEN
                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
				     arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_from_time,
                                     var_to_time,
                                     var_orig_cap + var_cap_change,
			             arg_aggregate_resource_id,
                                     arg_refresh_number);

                        update_avail(
					var_rowid,
                                        var_to_time + 1,
                                        var_to_shift_time);

                    elsif var_to_shift_time = var_to_time THEN
                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
				     arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_from_time,
                                     var_to_time,
                                     var_orig_cap + var_cap_change,
			             arg_aggregate_resource_id,
                                     arg_refresh_number);
                /*6319294 start */
                  if (var_from_shift_time = var_from_time - 1) then
				                  delete_avail(var_rowid);
			            else
	                        update_avail(var_rowid,
                                     var_from_shift_time,
                                     var_from_time - 1);
			           end if;
                /*6319294 end */

                    else
                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
			             arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_from_time,
                                     var_to_time,
                                     var_orig_cap + var_cap_change,
			             arg_aggregate_resource_id,
                                     arg_refresh_number);

                        update_avail(
				     var_rowid,
                                     var_from_shift_time,
                                     var_from_time - 1);

                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
				     arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_to_time + 1,
                                     var_to_shift_time,
                                     var_orig_cap,
			             arg_aggregate_resource_id,
                                     arg_refresh_number);
                    END if;
                END if;

                /* If the modification starts after the shift starts and ENDs
                after the shift ENDs */
                if var_from_shift_time <= var_from_time AND
                        var_to_shift_time >= var_from_time AND
                        var_to_time > var_to_shift_time THEN

                    /* If the shift start and the change start match */
                    if var_from_shift_time = var_from_time then
                        delete_avail(
				     var_rowid);
                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
				     arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_from_time,
                                     var_to_shift_time,
                                     var_orig_cap + var_cap_change,
			             arg_aggregate_resource_id,
                                     arg_refresh_number);

                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
				     arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_to_shift_time + 1,
                                     var_to_time,
                                     var_cap_change,
			             arg_aggregate_resource_id,
                                     arg_refresh_number);
                    else
                        update_avail(
				     var_rowid,
                                     var_from_shift_time,
                                     var_from_time - 1);

                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
				     arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_from_time,
                                     var_to_shift_time,
                                     var_orig_cap + var_cap_change,
			             arg_aggregate_resource_id,
                                     arg_refresh_number);

                        insert_avail(
				     var_shift_date,
                                     arg_department_id,
                                     arg_resource_id,
                                     arg_organization_id,
				     arg_sr_instance_id,
                                     var_shift_num,
                                     arg_simulation_set,
                                     var_to_shift_time + 1,
                                     var_to_time,
                                     var_cap_change,
			             arg_aggregate_resource_id,
                                     arg_refresh_number);
                    END if;
                END if;
                /* If the modification starts after the shift ENDs */
                if var_from_time > var_to_shift_time THEN
                    insert_avail(
				 var_shift_date,
                                 arg_department_id,
                                 arg_resource_id,
                                 arg_organization_id,
		                 arg_sr_instance_id,
                                 var_shift_num,
                                 arg_simulation_set,
                                 var_from_time,
                                 var_to_time,
                                 var_cap_change,
			         arg_aggregate_resource_id,
                                 arg_refresh_number);
                END if;
                <<skip>>
                NULL;
            END loop;
            close avail;
        END loop;

        close changes;

        --  Finally add the availability from the add workday type modifications

          v_stmt := 90;
          INSERT into MSC_net_resource_avail(
                    transaction_id,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    department_id,
                    resource_id,
                    shift_num,
                    shift_date,
                    from_time,
                    to_time,
                    capacity_units,
                    simulation_set,
                    aggregate_resource_id,
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
            SELECT  msc_net_resource_avail_s.NEXTVAL
                    ,-1
		    ,arg_organization_id
                    ,arg_sr_instance_id
                    ,arg_department_id
                    ,arg_resource_id
                    ,changes.shift_num
                    ,changes.from_date
                    ,changes.from_time
                    ,changes.to_time
                    ,changes.capacity_change
                    ,arg_simulation_set
                    ,arg_aggregate_resource_id
                    ,NULL  /* STATUS */
                    ,NULL  /* APPLIED */
                    ,2     /* UPDATED */
                    ,MSC_CL_COLLECTION.v_current_date
                    ,MSC_CL_COLLECTION.v_current_user
                    ,MSC_CL_COLLECTION.v_current_date
                    ,MSC_CL_COLLECTION.v_current_user
                    ,v_current_login
                    ,v_current_request
                    ,v_current_application
                    ,v_current_conc_program
                    ,MSC_CL_COLLECTION.v_current_date
                    ,arg_refresh_number
   FROM   msc_resource_changes changes
   WHERE  changes.department_id = arg_department_id
     AND  changes.resource_id = arg_resource_id
     AND  changes.action_type = ADD_WORKDAY
     AND  changes.simulation_set= arg_simulation_set
     AND  changes.sr_instance_id = arg_sr_instance_id;

    END IF;  -- arg_24hr_flag

  END IF;  -- arg_simulation_set

 if( v_show_warning is null) then
	 v_show_warning := 0;
  end if;

    EXCEPTION
      WHEN OTHERS THEN
        IF changes%isopen   THEN CLOSE changes;   END IF;
        IF avail%isopen     THEN CLOSE avail;     END IF;

   --     dbms_output.put_line('exception: ' || to_char(v_stmt) || ' - ' ||
    --                  to_char(sqlcode) ||':'|| substr(sqlerrm,1,60));
        LOG_MESSAGE('Error::('|| to_char(v_stmt) || ')::' ||
                      to_char(sqlcode) ||':'|| substr(sqlerrm,1,60));

	  v_show_warning := SQLCODE;

END calc_res_avail;

--
-- This procedule is used to populate resource for each simulation set
-- within an organization instance
--

PROCEDURE populate_avail_resources(
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
            NVL(dept_res.available_24_hours_flag, 2),
	    dept_res.aggregate_resource_id,
            NVL(dept_res.capacity_units,1), --**
            dept_res.disable_date, --**
            org.calendar_code, --**
            org.calendar_exception_set_id --**
    FROM    msc_trading_partners org,
            msc_department_resources dept_res
    WHERE   dept_res.owning_department_id = dept_res.department_id
    AND     dept_res.plan_id = -1
    AND     dept_res.resource_id <> -1
    AND     dept_res.aggregate_resource_flag <> 1 -- if it's not aggregate
   -- AND     NVL(dept_res.disable_date,sysdate+1) > sysdate
    AND     dept_res.organization_id = org.sr_tp_id
    AND     dept_res.sr_instance_id = org.sr_instance_id
    AND     org.sr_tp_id= arg_organization_id
    AND     org.sr_instance_id= arg_sr_instance_id
    AND     org.partner_type=3
      ORDER BY
            org.calendar_code,
            org.calendar_exception_set_id;


CURSOR dept_res_change is
    SELECT distinct dept_res.department_id,
            dept_res.resource_id,
            NVL(dept_res.available_24_hours_flag, 2),
	    dept_res.aggregate_resource_id,
            NVL(dept_res.capacity_units,1), --**
            dept_res.disable_date, --**
            org.calendar_code, --**
            org.calendar_exception_set_id --**
    FROM    msc_trading_partners org,
            msc_resource_changes chg,
            msc_department_resources dept_res
    WHERE   chg.department_id = dept_res.department_id
    AND     chg.resource_id = dept_res.resource_id
    AND     chg.sr_instance_id = dept_res.sr_instance_id
    AND     chg.refresh_number = arg_refresh_number
    AND     dept_res.owning_department_id = dept_res.department_id
    AND     dept_res.plan_id = -1
    AND     dept_res.resource_id <> -1
    AND     dept_res.aggregate_resource_flag <> 1 -- if it's not aggregate
    -- AND     NVL(dept_res.disable_date,sysdate+1) > sysdate
    AND     dept_res.organization_id = org.sr_tp_id
    AND     dept_res.sr_instance_id = org.sr_instance_id
    AND     org.sr_tp_id= arg_organization_id
    AND     org.sr_instance_id= arg_sr_instance_id
    AND     org.partner_type=3
      ORDER BY
            org.calendar_code,
            org.calendar_exception_set_id;

    var_department_id   NUMBER;
    var_resource_id     NUMBER;
    var_24hr_flag       NUMBER;
    v_cutoff_date       DATE;
    v_start_date        DATE;
    var_aggregate_resource_id NUMBER;

    var_capacity_units  NUMBER;  -- new variables for calling calc_res_avail
    var_disable_date    DATE;

BEGIN

    MSC_CL_COLLECTION.v_current_date:=    SYSDATE;
    MSC_CL_COLLECTION.v_current_user:=    FND_GLOBAL.USER_ID;
    v_current_login:=   FND_GLOBAL.LOGIN_ID;
    v_current_request:=      FND_GLOBAL.CONC_REQUEST_ID;
    v_current_application:=  FND_GLOBAL.PROG_APPL_ID;
    v_current_conc_program:= FND_GLOBAL.CONC_PROGRAM_ID;

    LOG_MESSAGE('--------------------------------------------------------');
    LOG_MESSAGE(' Populating Available Resources.........................');
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
                            var_24hr_flag,
			    var_aggregate_resource_id,
                            var_capacity_units,
                            var_disable_date,
                            v_calendar_code,
                            v_calendar_exception_set_id;

        EXIT WHEN dept_res%NOTFOUND;

        calc_res_avail(
		       arg_organization_id,
		       arg_sr_instance_id,
                       var_department_id,
                       var_resource_id,
                       arg_simulation_set,
                       var_24hr_flag,
                       v_start_date,
                       v_cutoff_date,
		       var_aggregate_resource_id,
                       arg_refresh_number,
                       var_capacity_units,
                       var_disable_date);
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
                                   var_24hr_flag,
			           var_aggregate_resource_id,
                                   var_capacity_units,
                                   var_disable_date,
                                   v_calendar_code,
                                   v_calendar_exception_set_id;

        EXIT WHEN dept_res_change%NOTFOUND;

        calc_res_avail(
		       arg_organization_id,
		       arg_sr_instance_id,
                       var_department_id,
                       var_resource_id,
                       arg_simulation_set,
                       var_24hr_flag,
                       v_start_date,
                       v_cutoff_date,
		       var_aggregate_resource_id,
                       arg_refresh_number,
                       var_capacity_units,
                       var_disable_date);
       commit;
       SAVEPOINT SP1;
       END LOOP;

       CLOSE dept_res_change;

   end if;

--    retcode := 0;
--    return;

   if( v_show_warning is null) then
	 v_show_warning := 0;
  end if;

    EXCEPTION
      WHEN OTHERS THEN
     --   dbms_output.put_line('exception: ' || to_char(v_stmt) || ' - ' ||
      --                to_char(sqlcode) ||':'|| substr(sqlerrm,1,60));

        LOG_MESSAGE('Error::('|| to_char(v_stmt) || ')::' ||
                      to_char(sqlcode) ||':'|| substr(sqlerrm,1,60));

        IF dept_res%isopen        THEN CLOSE dept_res;        END IF;
        IF dept_res_change%isopen THEN CLOSE dept_res_change; END IF;
 --       retcode := 1;
 --       return;
	 v_show_warning :=SQLCODE;

END populate_avail_resources;

--
-- This procedulre populate all resources for an organization.
--

PROCEDURE populate_org_resources( RETCODE             OUT NOCOPY number,
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
  -- For net change, refresh_flag = 2, delete resourse availability of
  -- all department resources with the new refresh number.

   if arg_refresh_flag = 2 then
     v_stmt := 100;
     delete from msc_net_resource_avail
     where rowid in (select res.rowid
                     from msc_net_resource_avail res,
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
   end if;


    -- Populate resource without simulation set

    var_simulation_set := NULL;

    LOG_MESSAGE(' Populating Org Resources for Null Simulation Set ......');

    populate_avail_resources (
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

        LOG_MESSAGE(' Populating Org Resources for the Simulation Set :'||var_simulation_set);

        populate_avail_resources (
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



     if( v_show_warning is null or  v_show_warning =0) then
	retcode := 0;
     else
	retcode:= v_show_warning;
  end if;
    return;

    EXCEPTION
      WHEN OTHERS THEN
     --   dbms_output.put_line('exception: ' || to_char(v_stmt) || ' - ' ||
      --                to_char(sqlcode) ||':'|| substr(sqlerrm,1,60));

        IF c_simulation_set%isopen THEN
            CLOSE c_simulation_set;
        END IF;

       -- fix for 2393358 --
       IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN

        LOG_MESSAGE('========================================');
        FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', 'POPULATE_ORG_RESOURCES');
        FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_NET_RESOURCE_AVAIL');
        LOG_MESSAGE(FND_MESSAGE.GET);

        LOG_MESSAGE(SQLERRM);


       END IF;
        --retcode := 1;
        retcode :=SQLCODE;
        return;

END populate_org_resources;

--
-- This procedure populate all resource information for
-- all lines of an organization
--
PROCEDURE populate_all_lines (
                               RETCODE             OUT NOCOPY number,
                               arg_refresh_flag    IN number,
                               arg_refresh_number  IN number,
			       arg_organization_id IN number,
			       arg_sr_instance_id  IN number,
			       arg_start_date      IN date,
                               arg_cutoff_date     IN date ) IS

 var_line_id       	NUMBER;
 var_calendar_date 	DATE;
 var_start_time    	NUMBER;
 var_stop_time     	NUMBER;
 var_max_rate	   	NUMBER;
 v_start_date    	DATE;
 v_cutoff_date   	DATE;
 var_transaction_id	NUMBER;

BEGIN

    LOG_MESSAGE('======================================================================');
    LOG_MESSAGE(' Populating Resources of all lines for the Org: '||arg_organization_id);
    LOG_MESSAGE('======================================================================');

    -- Determine the start date and cutoff date
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

    MSC_UTIL.MSC_DEBUG('Creating resource for all lines....');
    MSC_UTIL.MSC_DEBUG('Org Id:' || to_char(arg_organization_id));
    MSC_UTIL.MSC_DEBUG('Instance:' || to_char(arg_sr_instance_id));
    MSC_UTIL.MSC_DEBUG('Start Date:' || to_char(v_start_date,'YYYY/MM/DD HH24:MI:SS'));
    MSC_UTIL.MSC_DEBUG('Cutoff Date:' || to_char(v_cutoff_date,'YYYY/MM/DD HH24:MI:SS'));

   -- For complete refresh, the collection program will handle deleting all
   -- resource avail.
   -- For net change, refresh_flag = 2, delete resourse availability of
   -- lines with the new refresh number.
   if arg_refresh_flag = 2 then
     v_stmt := 110;
     delete from msc_net_resource_avail
     where rowid in (select res.rowid
                     from msc_net_resource_avail res, msc_department_resources line
                     where res.organization_id = line.organization_id
                       and res.sr_instance_id = line.sr_instance_id
                       and res.department_id = line.department_id
                       and res.resource_id = -1
                       and line.line_flag = 1
                       and line.plan_id = -1
                       and line.refresh_number = arg_refresh_number
                       and line.organization_id = arg_organization_id
                       and line.sr_instance_id = arg_sr_instance_id ) ;
   end if;

/* 2201418 - Added hints to improve performance. Also defined a new index
   on msc_department_resources (line_flag, plan_id, sr_instance_id,
   organization_id) */

        INSERT into MSC_net_resource_avail(
                    transaction_id,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    department_id,
                    resource_id,
                    shift_date,
                    from_time,
                    to_time,
                    capacity_units,
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
            SELECT /*+ leading(line) INDEX(LINE) use_nl(dates) */
                    msc_net_resource_avail_s.NEXTVAL
                    ,-1
		    ,arg_organization_id
                    ,arg_sr_instance_id
                    ,line.department_id
                    ,-1
                    ,dates.calendar_date
                    ,line.start_time
                    ,line.stop_time
  		    ,line.max_rate
                    ,NULL  /*STATUS*/
                    ,NULL /*APPLIED*/
                    ,2    /*UPDATED*/
                    ,SYSDATE
                    ,FND_GLOBAL.USER_ID
                    ,SYSDATE
                    ,FND_GLOBAL.USER_ID
                    ,FND_GLOBAL.LOGIN_ID
                    ,FND_GLOBAL.CONC_REQUEST_ID /* REQUEST_ID */
                    ,FND_GLOBAL.PROG_APPL_ID   /*PROGRAM_APPLICATION_ID */
                    ,FND_GLOBAL.CONC_PROGRAM_ID /*PROGRAM_ID */
                    ,SYSDATE  /* PROGRAM_UPDATE_DATE */
                    ,arg_refresh_number
   FROM  msc_calendar_dates dates,
         msc_department_resources line,
         msc_trading_partners org
  WHERE line.organization_id = arg_organization_id
   AND  line.sr_instance_id = arg_sr_instance_id
   AND  line.line_flag = 1
   AND  line.plan_id = -1
   AND  line.refresh_number = arg_refresh_number
   AND  NVL(line.disable_date, sysdate+1) > sysdate
   AND  org.sr_tp_id = line.organization_id
   AND  org.sr_instance_id = line.sr_instance_id
   AND  org.partner_type = 3
   AND  dates.calendar_code = org.calendar_code
   AND  dates.sr_instance_id = arg_sr_instance_id
   AND  dates.exception_set_id = org.calendar_exception_set_id
   AND  dates.calendar_date >= trunc(v_start_date)
   AND  dates.calendar_date <= least(trunc(v_cutoff_date),
                              trunc(nvl(line.disable_date-1, v_cutoff_date)) )
   AND  dates.seq_num is not null;

   INSERT into MSC_net_resource_avail(
                    transaction_id,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    department_id,
                    resource_id,
                    shift_date,
                    from_time,
                    to_time,
                    capacity_units,
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
            SELECT /*+ leading(line) INDEX(LINE) use_nl(dates) */
                    msc_net_resource_avail_s.NEXTVAL
                    ,-1
		    ,arg_organization_id
                    ,arg_sr_instance_id
                    ,line.department_id
                    ,-1
                    ,line.disable_date
                    ,0
                    ,0
  		            ,0
                    ,NULL  /*STATUS*/
                    ,NULL /*APPLIED*/
                    ,2    /*UPDATED*/
                    ,SYSDATE
                    ,FND_GLOBAL.USER_ID
                    ,SYSDATE
                    ,FND_GLOBAL.USER_ID
                    ,FND_GLOBAL.LOGIN_ID
                    ,FND_GLOBAL.CONC_REQUEST_ID /* REQUEST_ID */
                    ,FND_GLOBAL.PROG_APPL_ID   /*PROGRAM_APPLICATION_ID */
                    ,FND_GLOBAL.CONC_PROGRAM_ID /*PROGRAM_ID */
                    ,SYSDATE  /* PROGRAM_UPDATE_DATE */
                    ,arg_refresh_number
   FROM
         msc_department_resources line,
         msc_trading_partners org
  WHERE line.organization_id = arg_organization_id
   AND  line.sr_instance_id = arg_sr_instance_id
   AND  line.line_flag = 1
   AND  line.plan_id = -1
   AND  line.refresh_number = arg_refresh_number
   AND  line.disable_date IS NOT NULL
   AND  org.sr_tp_id = line.organization_id
   AND  org.sr_instance_id = line.sr_instance_id
   AND  org.partner_type = 3;

    --COMMIT;
    retcode := 0;
    return;

    EXCEPTION
      WHEN OTHERS THEN
      --  dbms_output.put_line('exception: ' || to_char(v_stmt) || ' - ' ||
       --               to_char(sqlcode) ||':'|| substr(sqlerrm,1,60));
        LOG_MESSAGE('Error::('|| to_char(v_stmt) || ')::' ||
                      to_char(sqlcode) ||':'|| substr(sqlerrm,1,60));

      -- fix for 2393358 --
      IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN

       LOG_MESSAGE('========================================');
       FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
       FND_MESSAGE.SET_TOKEN('PROCEDURE', 'POPULATE_ALL_LINES');
       FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_NET_RESOURCE_AVAIL');
       LOG_MESSAGE(FND_MESSAGE.GET);

       LOG_MESSAGE(SQLERRM);


      END IF;

        --retcode := 1;
        retcode :=SQLCODE;
        return;

END populate_all_lines;
PROCEDURE  COMPUTE_RES_AVAIL (ERRBUF               OUT NOCOPY VARCHAR2,
                              RETCODE              OUT NOCOPY NUMBER,
                              pINSTANCE_ID         IN  NUMBER,
                              pSTART_DATE          IN  VARCHAR2)
IS
  lv_start_date   DATE := TO_DATE(pSTART_DATE, 'YYYY/MM/DD HH24:MI:SS');
      lv_retval             BOOLEAN;
      lv_dummy1             VARCHAR2(32);
      lv_dummy2             VARCHAR2(32);
      lv_ret_res_ava        number;
      lv_where_clause  	    varchar2(500) := NULL;

BEGIN

    lv_retval := FND_INSTALLATION.GET_APP_INFO(
                   'FND', lv_dummy1,lv_dummy2, MSC_CL_COLLECTION.v_applsys_schema);
       /* initialize the variables  */
      SELECT
             APPS_VER,
             SYSDATE,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             UPPER(INSTANCE_CODE), /* Bug 2129155 */
             INSTANCE_TYPE,            -- OPM
             nvl(LCID,0)
        INTO
             MSC_CL_COLLECTION.v_apps_ver,
             MSC_CL_COLLECTION.START_TIME,
             MSC_CL_COLLECTION.v_current_date,
             MSC_CL_COLLECTION.v_current_user,
             MSC_CL_COLLECTION.v_current_date,
             MSC_CL_COLLECTION.v_current_user,
             MSC_CL_COLLECTION.v_instance_code,
             MSC_CL_COLLECTION.v_instance_type,          -- OPM
             MSC_CL_COLLECTION.v_last_collection_id
        FROM MSC_APPS_INSTANCES
       WHERE INSTANCE_ID= pINSTANCE_ID;

         MSC_CL_COLLECTION.v_is_complete_refresh    := TRUE;
         MSC_CL_COLLECTION.v_is_incremental_refresh := FALSE;
         MSC_CL_COLLECTION.v_is_partial_refresh     := FALSE;

         MSC_CL_COLLECTION.v_instance_id := pINSTANCE_ID;

  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' Start date : '|| lv_start_date);

  lv_where_clause := ' AND ORGANIZATION_ID IN ( SELECT SR_TP_ID FROM MSC_TRADING_PARTNERS WHERE '||
                     ' SR_INSTANCE_ID = '||MSC_CL_COLLECTION.v_instance_id ||
                     ' AND ORGANIZATION_TYPE =1 ) ';

  --        log_debug('before delete of MSC_NET_RESOURCE_AVAIL debug0 ');
   IF  MSC_CL_COLLECTION.v_instance_type = MSC_UTIL.G_INS_DISCRETE OR MSC_CL_COLLECTION.v_instance_type = MSC_UTIL.G_INS_OTHER  THEN
 --         log_debug('before delete of MSC_NET_RESOURCE_AVAIL ');
                  MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL', MSC_CL_COLLECTION.v_instance_id, -1);
		  COMMIT;
                  MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL', MSC_CL_COLLECTION.v_instance_id, -1);
		  COMMIT;

          /* call the function to calc. resource avail */
	 lv_ret_res_ava:=CALC_RESOURCE_AVAILABILITY(lv_start_date-1,MSC_UTIL.G_ALL_ORGANIZATIONS,TRUE);


         IF lv_ret_res_ava = 2 THEN
		 FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_CALC_RES_AVAIL_FAIL');
		 ERRBUF:= FND_MESSAGE.GET;
		 RETCODE:= MSC_UTIL.G_WARNING;
         ELSIF lv_ret_res_ava <> 0 THEN
		 FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_CALC_RES_AVAIL_FAIL');
		 ERRBUF:= FND_MESSAGE.GET;
		 RETCODE:= MSC_UTIL.G_ERROR;

         END IF;

   ELSIF MSC_CL_COLLECTION.v_instance_type = MSC_UTIL.G_INS_MIXED THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'debug-07');
         MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL', MSC_CL_COLLECTION.v_instance_id, -1,lv_where_clause);
         COMMIT;
         MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL', MSC_CL_COLLECTION.v_instance_id, -1,lv_where_clause);
         COMMIT;


         lv_ret_res_ava:=CALC_RESOURCE_AVAILABILITY(lv_start_date-1,MSC_UTIL.G_ALL_ORGANIZATIONS,TRUE);


         IF lv_ret_res_ava = 2 THEN
		 FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_CALC_RES_AVAIL_FAIL');
		 ERRBUF:= FND_MESSAGE.GET;
		 RETCODE:= MSC_UTIL.G_WARNING;
         ELSIF lv_ret_res_ava <> 0 THEN
		 FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_CALC_RES_AVAIL_FAIL');

		 ERRBUF:= FND_MESSAGE.GET;
		 RETCODE:= MSC_UTIL.G_ERROR;
	 END IF;
   ELSE
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'This program can be run only for Instance Type: Discrete.');
         ERRBUF:= FND_MESSAGE.GET;
	 RETCODE:= MSC_UTIL.G_ERROR;

   END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_CALC_RES_AVAIL_FAIL');
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    RETCODE := MSC_UTIL.G_ERROR;

END COMPUTE_RES_AVAIL;

--==============================================================

/*Resource start time changes*/
FUNCTION CALC_RESOURCE_AVAILABILITY (pSTART_TIME IN DATE,
                                     pORG_GROUP IN VARCHAR2,
                                     pSTANDALONE BOOLEAN)
RETURN NUMBER IS

   lv_ret_code     NUMBER;
   lv_refresh_flag NUMBER;
   lv_temp_ret_flag NUMBER;
  /*Resource Start TIme*/
   CURR_DATE DATE;

   lv_task_start_time DATE;
   lv_task_end_time DATE;

   lv_mrp_cutoff_date_offset NUMBER;   -- Months
   ex_calc_res_avail         EXCEPTION; -- fix for 2393358
   lv_res_avail_before_sysdate NUMBER;  -- Days

   CURSOR c1 IS
   SELECT tp.Organization_ID
     FROM MSC_PARAMETERS tp,
          MSC_INSTANCE_ORGS ins_org,
          MSC_TRADING_PARTNERS mtp
    WHERE tp.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
      AND ins_org.SR_INSTANCE_ID=tp.SR_INSTANCE_ID
      AND ins_org.Organization_ID=tp.ORGANIZATION_ID
      AND ins_org.ENABLED_FLAG= MSC_UTIL.SYS_YES
      AND ((pORG_GROUP = MSC_UTIL.G_ALL_ORGANIZATIONS ) OR (ins_org.ORG_GROUP=pORG_GROUP))
      AND mtp.sr_instance_id = MSC_CL_COLLECTION.v_instance_id
      AND mtp.sr_tp_id = tp.organization_id
      AND mtp.partner_type = 3
      AND mtp.organization_type = 1; -- Discrete Mfg.


/************** LEGACY_CHANGE_START*************************/

   CURSOR c2 IS
   SELECT 1
     FROM MSC_ST_RESOURCE_CHANGES
    WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
     AND process_flag = 5;

   lv_changes_exists    NUMBER := 0;
/*****************LEGACY_CHANGE_ENDS************************/

BEGIN
    /* Resource Start Time changes*/
    lv_task_start_time:= pSTART_TIME;
    CURR_DATE:= SYSDATE;

   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'CALC_RESOURCE_AVAILABILITY');
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

   lv_mrp_cutoff_date_offset:= TO_NUMBER(FND_PROFILE.VAlUE('MRP_CUTOFF_DATE_OFFSET'));
   lv_res_avail_before_sysdate := nvl(TO_NUMBER(FND_PROFILE.VAlUE('MSC_RES_AVAIL_BEFORE_SYSDAT')),1);

   IF pSTANDALONE THEN
   	lv_task_end_time := ADD_MONTHS(lv_task_start_time,lv_mrp_cutoff_date_offset);
   ELSE
   	lv_task_end_time := ADD_MONTHS(lv_task_start_time,lv_mrp_cutoff_date_offset) + lv_res_avail_before_sysdate;
   END IF;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_mrp_cutoff_date_offset:'||lv_mrp_cutoff_date_offset);
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_res_avail_before_sysdate:'||lv_res_avail_before_sysdate);
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_task_end_time:'||lv_task_end_time);
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_task_start_time:'  ||lv_task_start_time);
     --- PREPLACE CHANGE START ---
   /*
   IF v_is_complete_refresh THEN
      lv_refresh_flag:= 1;
   ELSE
      lv_refresh_flag:= 2;
   END IF;
   */

   IF MSC_CL_COLLECTION.v_is_complete_refresh THEN
      lv_refresh_flag := 1;
   ELSIF MSC_CL_COLLECTION.v_is_incremental_refresh THEN
      lv_refresh_flag := 2;
   ELSIF MSC_CL_COLLECTION.v_is_partial_refresh THEN
      lv_refresh_flag := 1;    -- Functionality is same as complete_refresh
   END IF;

/************** LEGACY_CHANGE_START*************************/
   -- Calling the program as complete refresh for legacy so that new
   -- records coming in are considered

   IF  MSC_CL_COLLECTION.v_instance_type = MSC_UTIL.G_INS_OTHER THEN
      lv_refresh_flag := 1;
   END IF;
/*****************LEGACY_CHANGE_ENDS************************/

     ---  PREPLACE CHANGE END  ---

   --  USING DEFALUT VALUE FOR START DATE AND CUTOFF DATE

     SAVEPOINT SP1;

     FOR c_rec IN c1 LOOP

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'CALLING POPULATE_ORG_RESOURCES');

         POPULATE_ORG_RESOURCES
              ( lv_ret_code,
                lv_refresh_flag,
                MSC_CL_COLLECTION.v_last_collection_id,
                c_rec.organization_id,
                MSC_CL_COLLECTION.v_instance_id,
                lv_task_start_time,
                lv_task_end_time);

	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'RET_CODE:  ' ||lv_ret_code);

         IF lv_ret_code <> 0 THEN
            ROLLBACK WORK TO SAVEPOINT SP1;
            IF lv_ret_code IN (-01653,-01650,-01562,-01683) THEN
              lv_temp_ret_flag:=1;
	      RAISE ex_calc_res_avail;
	    else
	      lv_temp_ret_flag:=2;
            END IF;
         ELSE
            COMMIT;
            SAVEPOINT SP1;
         END IF;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'CALLING POPULATE_ALL_LINES');

         POPULATE_ALL_LINES
              ( lv_ret_code,
                lv_refresh_flag,
                MSC_CL_COLLECTION.v_last_collection_id,
                c_rec.organization_id,
                MSC_CL_COLLECTION.v_instance_id,
                lv_task_start_time,
                lv_task_end_time);

	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'RET_CODE:  ' ||lv_ret_code);

         IF lv_ret_code <> 0 THEN
            ROLLBACK WORK TO SAVEPOINT SP1;
	    IF lv_ret_code IN (-01653,-01650,-01562,-01683) THEN
              lv_temp_ret_flag:=1;
	      RAISE ex_calc_res_avail;
	    else
	      lv_temp_ret_flag:=2;
            END IF;
         ELSE
            COMMIT;
            SAVEPOINT SP1;
         END IF;

	/* yvon: resource instanc eavail changes start */
        -----------------------------------------------------
        -- populate resource instance availability
        -----------------------------------------------------
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'CALLING POPULATE_ORG_RES_INSTANCES');

         MSC_NET_RES_INST_AVAILABILITY.POPULATE_ORG_RES_INSTANCES
              ( lv_ret_code,
                lv_refresh_flag,
                MSC_CL_COLLECTION.v_last_collection_id,
                c_rec.organization_id,
                MSC_CL_COLLECTION.v_instance_id,
                lv_task_start_time,
                lv_task_end_time);

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'RET_CODE:  ' ||lv_ret_code);

         IF lv_ret_code <> 0 THEN
            ROLLBACK WORK TO SAVEPOINT SP1;
            IF lv_ret_code IN (-01653,-01650,-01562,-01683) THEN
              lv_temp_ret_flag:=1;
              RAISE ex_calc_res_avail;
            else
              lv_temp_ret_flag:=2;
            END IF;
         ELSE
            COMMIT;
            SAVEPOINT SP1;
         END IF;
      /* yvon: resource instanc eavail changes end */

     END LOOP;

/************** LEGACY_CHANGE_START*************************/

   -- This is to enable resource changes to be
   -- considered for legacy. Both, the resource information and
   -- resource changes may come in at the same time for legacy.

   IF  MSC_CL_COLLECTION.v_instance_type = MSC_UTIL.G_INS_OTHER THEN

     OPEN C2;
     FETCH C2 INTO lv_changes_exists;
     CLOSE C2;

     IF lv_changes_exists = 1 THEN

       lv_refresh_flag := 2;

   --  USING DEFALUT VALUE FOR START DATE AND CUTOFF DATE

     SAVEPOINT SP1;

     FOR c_rec IN c1 LOOP

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'CALLING POPULATE_ORG_RESOURCES');

	POPULATE_ORG_RESOURCES
              ( lv_ret_code,
                lv_refresh_flag,
                MSC_CL_COLLECTION.v_last_collection_id,
                c_rec.organization_id,
                MSC_CL_COLLECTION.v_instance_id,
                lv_task_start_time,
                lv_task_end_time);

         IF lv_ret_code <> 0 THEN
            ROLLBACK WORK TO SAVEPOINT SP1;
            IF lv_ret_code IN (-01653,-01650,-01562,-01683) THEN
              lv_temp_ret_flag:=1;
	      RAISE ex_calc_res_avail;
	    else
	      lv_temp_ret_flag:=2;
            END IF;
         ELSE
            COMMIT;
            SAVEPOINT SP1;
         END IF;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'CALLING POPULATE_ALL_LINES');

         POPULATE_ALL_LINES
              ( lv_ret_code,
                lv_refresh_flag,
                MSC_CL_COLLECTION.v_last_collection_id,
                c_rec.organization_id,
                MSC_CL_COLLECTION.v_instance_id,
                lv_task_start_time,
                lv_task_end_time);

	 IF lv_ret_code <> 0 THEN
            ROLLBACK WORK TO SAVEPOINT SP1;
            IF lv_ret_code IN (-01653,-01650,-01562,-01683) THEN
              lv_temp_ret_flag:=1;
	      RAISE ex_calc_res_avail;
	    else
	      lv_temp_ret_flag:=2;
            END IF;
         ELSE
            COMMIT;
            SAVEPOINT SP1;
         END IF;

	/* yvon: resource instanc eavail changes start */
        -----------------------------------------------------
        -- populate resource instance availability
        -----------------------------------------------------
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'CALLING POPULATE_ORG_RES_INSTANCES');

         MSC_NET_RES_INST_AVAILABILITY.POPULATE_ORG_RES_INSTANCES
              ( lv_ret_code,
                lv_refresh_flag,
                MSC_CL_COLLECTION.v_last_collection_id,
                c_rec.organization_id,
                MSC_CL_COLLECTION.v_instance_id,
                lv_task_start_time,
                lv_task_end_time);

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'RET_CODE:  ' ||lv_ret_code);

         IF lv_ret_code <> 0 THEN
            ROLLBACK WORK TO SAVEPOINT SP1;
            IF lv_ret_code IN (-01653,-01650,-01562,-01683) THEN
              lv_temp_ret_flag:=1;
              RAISE ex_calc_res_avail;
            else
              lv_temp_ret_flag:=2;
            END IF;
         ELSE
            COMMIT;
            SAVEPOINT SP1;
         END IF;
      /* yvon: resource instanc eavail changes end */

     END LOOP;
     END IF; -- lv_changes_exists
   END IF; -- MSC_UTIL.G_INS_OTHER

/************** LEGACY_CHANGE_ENDS*************************/

 /* Bug 3295824 - We need to set the capacity units to 0 of any records
                      having -ve capacity units */

     update MSC_net_resource_avail
     set capacity_units = 0
     where capacity_units < 0
     and plan_id = -1
     AND sr_instance_id  = MSC_CL_COLLECTION.v_instance_id
     AND simulation_set is not null
     and shift_date between trunc(lv_task_start_time) and
     lv_task_end_time;

     COMMIT;

     /* End Bug 3295824 */

     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
                     TO_CHAR(CEIL((SYSDATE- CURR_DATE)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);




    IF (lv_temp_ret_flag=2 ) THEN
	return lv_temp_ret_flag;
    else
	RETURN 0;
    END IF;

EXCEPTION

     WHEN OTHERS THEN

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

        IF (lv_temp_ret_flag=1 ) THEN
		return lv_temp_ret_flag;
	else
		RETURN SQLCODE;
	END IF;

END CALC_RESOURCE_AVAILABILITY;


--==================================================================

--=======================================================================
--The following procedure also include the DS change for the
--MSC_NET_RES_INST_AVAIL
--=======================================================================
PROCEDURE LOAD_NET_RESOURCE_AVAIL IS

-- OPM
-- cursor to select the rows from net_resource_avail. process mfg only
  CURSOR c11 (org_id NUMBER) IS
SELECT
  msnra.organization_id,
  msnra.sr_instance_id,
  msnra.resource_id,
  msnra.department_id,
  msnra.simulation_set,
  msnra.shift_num,
  msnra.shift_date,
  msnra.from_time,
  msnra.to_time,
  msnra.capacity_units
FROM msc_st_net_resource_avail msnra
WHERE msnra.sr_instance_id = MSC_CL_COLLECTION.v_instance_id and
      msnra.organization_id=org_id;


---------------------------------------------------------------------
-- adding the change for the msc_st_net_res_avail for DS
---------------------------------------------------------------------

-- OPM
-- cursor to select the rows from net_res_inst_avail. process mfg only
  CURSOR c_res_inst (org_id NUMBER) IS
SELECT
  msnria.sr_instance_id,
  msnria.res_instance_id,
  msnria.resource_id,
  msnria.department_id,
  msnria.organization_id,
  msnria.serial_number,
  t1.inventory_item_id equipment_item_id,
  msnria.simulation_set,
  msnria.shift_num,
  msnria.shift_date,
  msnria.from_time,
  msnria.to_time
FROM msc_st_net_res_inst_avail msnria,
MSC_ITEM_ID_LID t1
WHERE msnria.sr_instance_id = MSC_CL_COLLECTION.v_instance_id
and t1.sr_instance_id (+) = msnria.sr_instance_id
and t1.sr_inventory_item_id (+) = msnria.equipment_item_id
and msnria.organization_id=org_id;

CURSOR c_org_list IS
select organization_id
from msc_instance_orgs mio,
     msc_trading_partners mtp
where mio.sr_instance_id= MSC_CL_COLLECTION.v_instance_id and
      mio.enabled_flag= 1 and
      ((MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS ) or (mio.org_group = MSC_CL_COLLECTION.v_coll_prec.org_group_flag)) and
      mio.sr_instance_id=mtp.sr_instance_id and
      mio.organization_id=mtp.sr_tp_id and
      mtp.partner_type=3 and
      mtp.organization_type=2;

   c_count NUMBER:= 0;
   lv_res_avail NUMBER := MSC_UTIL.SYS_NO;
   lv_res_inst_avail NUMBER := MSC_UTIL.SYS_NO;
   lv_sql_stmt     VARCHAR2(2048);

   BEGIN

IF MSC_CL_COLLECTION.v_recalc_nra= MSC_UTIL.SYS_YES THEN

/*IF (v_is_complete_refresh OR (v_is_partial_refresh AND MSC_CL_COLLECTION.v_coll_prec.resource_nra_flag = MSC_CL_COLLECTION.SYS_YES)) THEN
         -- We want to delete all NRA related data and get new stuff.

--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL', v_instance_id, -1);
--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL', v_instance_id, -1);

  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_CL_COLLECTION.G_ALL_ORGANIZATIONS THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'debug-00');
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL', v_instance_id, -1);
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL', v_instance_id, -1);
  ELSE
    v_sub_str :=' AND ORGANIZATION_ID '||v_in_org_str;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'debug-01');
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RESOURCE_AVAIL', v_instance_id, -1,v_sub_str);
    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_NET_RES_INST_AVAIL', v_instance_id, -1,v_sub_str);
  END IF;

END IF;*/

-- process mfg only. move the rows for the st table to the msc table
-- for net resource avail
IF MSC_CL_COLLECTION.v_process_flag = MSC_UTIL.SYS_YES THEN

/*
We will do a bulk insert of res avail for OPM orgs. If this fails,
then we will switch to old, row by row processing.

The same applies to collection of net res instance avail data as well.
*/

FOR c_rec1 IN c_org_list LOOP
  BEGIN

     SAVEPOINT LOAD_RES_AVAIL_SP;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Loading res avail for OPM orgs : ' || c_rec1.organization_id);

     lv_sql_stmt:=
     ' INSERT into MSC_net_resource_avail '
     ||' (  transaction_id,'
     ||' plan_id,'
     ||' department_id,'
     ||' resource_id,'
     ||' organization_id,'
     ||' sr_instance_id,'
     ||' shift_num,'
     ||' shift_date,'
     ||' from_time,'
     ||' to_time,'
     ||' capacity_units,'
     ||' simulation_set,'
     ||' status,'
     ||' applied,'
     ||' updated,'
     ||' last_update_date,'
     ||' last_updated_by,'
     ||' creation_date,'
     ||' created_by,'
     ||' refresh_number)'
     ||' SELECT'
     ||' msc_net_resource_avail_s.NEXTVAL,'
     ||' -1,'
     ||' msnra.department_id,'
     ||' msnra.resource_id,'
     ||' msnra.organization_id,'
     ||' msnra.sr_instance_id,'
     ||' msnra.shift_num,'
     ||' msnra.shift_date,'
     ||' msnra.from_time,'
     ||' msnra.to_time,'
     ||' msnra.capacity_units,'
     ||' msnra.simulation_set,'
     ||' NULL,' 	/* STATUS */
     ||' NULL,' 	/* APPLIED */
     ||' 2,' 	/* UPDATED */
     ||' :v_current_date,'
     ||' :v_current_user,'
     ||' :v_current_date,'
     ||' :v_current_user,'
     ||' :v_last_collection_id'
     ||' FROM msc_st_net_resource_avail msnra'
     ||' WHERE msnra.sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
     ||' AND msnra.organization_id = ' ||c_rec1.organization_id;

     EXECUTE IMMEDIATE lv_sql_stmt
     	 USING
     	 MSC_CL_COLLECTION.v_current_date,
     	 MSC_CL_COLLECTION.v_current_user,
     	 MSC_CL_COLLECTION.v_current_date,
     	 MSC_CL_COLLECTION.v_current_user,
     	 MSC_CL_COLLECTION.v_last_collection_id;

     COMMIT;

     lv_res_avail:=MSC_UTIL.SYS_YES;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Loaded res avail for OPM orgs : ' || c_rec1.organization_id);

  EXCEPTION
     WHEN OTHERS THEN

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_NET_RESOURCE_AVAIL>>');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
        ROLLBACK WORK TO SAVEPOINT LOAD_RES_AVAIL_SP;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Switching to Row-By-Row processing for org : ' || c_rec1.organization_id);
  END;

  IF lv_res_avail = MSC_UTIL.SYS_NO THEN
     c_count:= 0;

     FOR c_rec IN c11(c_rec1.organization_id) LOOP

     BEGIN
       INSERT into MSC_net_resource_avail(
         transaction_id,
         plan_id,
         department_id,
         resource_id,
         organization_id,
         sr_instance_id,
         shift_num,
         shift_date,
         from_time,
         to_time,
         capacity_units,
         simulation_set,
         status,
         applied,
         updated,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         refresh_number)
       VALUES(
         msc_net_resource_avail_s.NEXTVAL,
         -1,
         c_rec.department_id,
         c_rec.resource_id,
         c_rec.organization_id,
         c_rec.sr_instance_id,
         c_rec.shift_num,
         c_rec.shift_date,
         c_rec.from_time,
         c_rec.to_time,
         c_rec.capacity_units,
         c_rec.simulation_set,
         NULL,  /* STATUS */
         NULL,  /* APPLIED */
         2,     /* UPDATED */
         MSC_CL_COLLECTION.v_current_date,
         MSC_CL_COLLECTION.v_current_user,
         MSC_CL_COLLECTION.v_current_date,
         MSC_CL_COLLECTION.v_current_user,
         MSC_CL_COLLECTION.v_last_collection_id);

         c_count:= c_count+1;

         IF c_count> MSC_CL_COLLECTION.PBS THEN
            COMMIT;
            c_count:= 0;
         END IF;

     EXCEPTION
       WHEN OTHERS THEN

       IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
         FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
         FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
         FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_NET_RESOURCE_AVAIL');
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
         RAISE;

       ELSE

         MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
         FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
         FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
         FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_NET_RESOURCE_AVAIL');
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

         FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
         FND_MESSAGE.SET_TOKEN('COLUMN', 'RESOURCE_ID');
         FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.RESOURCE_ID));
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

         FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
         FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
         FND_MESSAGE.SET_TOKEN('VALUE',
                               MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
                                                      MSC_CL_COLLECTION.v_instance_id));
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
       END IF;

     END;

     END LOOP;

  END IF; /* If lv_res_avail:=MSC_CL_COLLECTION.SYS_NO */
END LOOP;

 ------------------------------------------------------------------------
  -- here is the change for msc_net_res_inst_avail (DS change)
  ------------------------------------------------------------------------
FOR c_rec1 IN c_org_list LOOP
  BEGIN

     SAVEPOINT LOAD_RES_INST_AVAIL_SP;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Loading res instance avail for OPM orgs : ' || c_rec1.organization_id);

     lv_sql_stmt:=
     ' INSERT into MSC_net_res_inst_avail '
     ||' (  inst_transaction_id,'
     ||' plan_id,'
     ||' sr_instance_id,'
     ||' organization_id,'
     ||' department_id,'
     ||' resource_id,'
     ||' res_instance_id,'
     ||' equipment_item_id,'
     ||' parent_id,'
     ||' serial_number,'
     ||' simulation_set,'
     ||' shift_num,'
     ||' shift_date,'
     ||' from_time,'
     ||' to_time,'
     ||' status,'
     ||' applied,'
     ||' updated,'
     ||' last_update_date,'
     ||' last_updated_by,'
     ||' creation_date,'
     ||' created_by,'
     ||' refresh_number)'
     ||' SELECT'
     ||' msc_net_res_inst_avail_s.NEXTVAL,'
     ||' -1,'
     ||' msnria.sr_instance_id,'
     ||' msnria.organization_id,'
     ||' msnria.department_id,'
     ||' msnria.resource_id,'
     ||' msnria.res_instance_id,'
     ||' t1.inventory_item_id,'
     ||' NULL,'
     ||' msnria.serial_number,'
     ||' msnria.simulation_set,'
     ||' msnria.shift_num,'
     ||' msnria.shift_date,'
     ||' msnria.from_time,'
     ||' msnria.to_time,'
     ||' NULL,' 	/* STATUS */
     ||' NULL,' 	/* APPLIED */
     ||' 2,' 		/* UPDATED */
     ||' :v_current_date,'
     ||' :v_current_user,'
     ||' :v_current_date,'
     ||' :v_current_user,'
     ||' :v_last_collection_id'
     ||' FROM msc_st_net_res_inst_avail msnria,'
     ||' MSC_ITEM_ID_LID t1'
     ||' WHERE msnria.sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
     ||' and t1.sr_instance_id (+) = msnria.sr_instance_id'
     ||' and t1.sr_inventory_item_id (+) = msnria.equipment_item_id'
     ||' and msnria.organization_id = ' ||c_rec1.organization_id;

     EXECUTE IMMEDIATE lv_sql_stmt
     	 USING
     	 MSC_CL_COLLECTION.v_current_date,
     	 MSC_CL_COLLECTION.v_current_user,
     	 MSC_CL_COLLECTION.v_current_date,
     	 MSC_CL_COLLECTION.v_current_user,
     	 MSC_CL_COLLECTION.v_last_collection_id;

     COMMIT;

     lv_res_inst_avail:=MSC_UTIL.SYS_YES;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Loaded res instance avail for OPM orgs : ' || c_rec1.organization_id);

  EXCEPTION
     WHEN OTHERS THEN

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_NET_RESOURCE_INSTANCE_AVAIL>>');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
        ROLLBACK WORK TO SAVEPOINT LOAD_RES_INST_AVAIL_SP;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Switching to Row-By-Row processing for org ' || c_rec1.organization_id);
  END;

  IF lv_res_inst_avail = MSC_UTIL.SYS_NO THEN

     c_count:= 0;

     FOR c_rec_resinst IN c_res_inst(c_rec1.organization_id) LOOP

     BEGIN

         INSERT into MSC_net_res_inst_avail(
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
           refresh_number)
         VALUES(
           msc_net_res_inst_avail_s.NEXTVAL,
           -1,
           c_rec_resinst.sr_instance_id,
           c_rec_resinst.organization_id,
           c_rec_resinst.department_id,
           c_rec_resinst.resource_id,
           c_rec_resinst.res_instance_id,
           c_rec_resinst.equipment_item_id,
           NULL,
           c_rec_resinst.serial_number,
           c_rec_resinst.simulation_set,
           c_rec_resinst.shift_num,
           c_rec_resinst.shift_date,
           c_rec_resinst.from_time,
           c_rec_resinst.to_time,
           NULL,  /* STATUS */
           NULL,  /* APPLIED */
           2,     /* UPDATED */
           MSC_CL_COLLECTION.v_current_date,
           MSC_CL_COLLECTION.v_current_user,
           MSC_CL_COLLECTION.v_current_date,
           MSC_CL_COLLECTION.v_current_user,
           MSC_CL_COLLECTION.v_last_collection_id);

       c_count:= c_count+1;

       IF c_count> MSC_CL_COLLECTION.PBS THEN
          COMMIT;
          c_count:= 0;
       END IF;

     EXCEPTION
         WHEN OTHERS THEN

         IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
           FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
           FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
           FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_NET_RES_INST_AVAIL');
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
           RAISE;

         ELSE

           MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
           FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
           FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_CALENDAR_DATE');
           FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_NET_RES_INST_AVAIL');
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

           FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
           FND_MESSAGE.SET_TOKEN('COLUMN', 'RESOURCE_ID');
           FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec_resinst.RESOURCE_ID));
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

           FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
           FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
           FND_MESSAGE.SET_TOKEN('VALUE',
                                 MSC_GET_NAME.ORG_CODE( c_rec_resinst.ORGANIZATION_ID,
                                                        MSC_CL_COLLECTION.v_instance_id));
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
         END IF;

     END;

     END LOOP;
  END IF; /* IF lv_res_inst_avail = MSC_CL_COLLECTION.SYS_NO THEN */
END LOOP;

COMMIT;

END IF;

END IF; -- recalc_nra

   END LOAD_NET_RESOURCE_AVAIL;

--===================================================================

END MSC_resource_availability;

/
