--------------------------------------------------------
--  DDL for Package Body MSD_DEM_TIME_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_TIME_DATA" AS
/* $Header: msddemcalb.pls 120.2.12000000.2 2007/09/25 06:07:13 syenamar noship $ $ */

Procedure msd_dem_fix_manufacturing(
                            p_cal_code in varchar2) is

  -- distinct weeks by calendar
  cursor weeks is
   select distinct
    week_start_date sd,
    week_end_date ed,
    week,
    week_description,
    month,
    month_description,
    calendar_code,
    month_start_date,
    month_end_date,
    instance
    from msd_dem_time
    where calendar_type = 2
      and calendar_code = nvl(p_cal_code, calendar_code);

begin

MSD_DEM_COMMON_UTILITIES.LOG_DEBUG('In Procedure: MSD_DEM_FIX_MANUFACTURING');


MSD_DEM_COMMON_UTILITIES.LOG_DEBUG('Start Time: '|| to_char(SYSTIMESTAMP,'DD-MM-YYYY HH24:MI:SS'));

  for week in weeks loop

    -- insert missing days in this week
    insert into msd_dem_time(INSTANCE, CALENDAR_TYPE, CALENDAR_CODE,
                         LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
                         CREATED_BY, LAST_UPDATE_LOGIN,
                         MONTH, MONTH_DESCRIPTION,
                         MONTH_START_DATE, MONTH_END_DATE,
                         WEEK, WEEK_DESCRIPTION,
                         WEEK_START_DATE, WEEK_END_DATE,
                         DAY, DAY_DESCRIPTION)
    select week.instance, 2, week.calendar_code,
           sysdate, fnd_global.user_id, sysdate, fnd_global.user_id, fnd_global.user_id,
           week.month, week.month_description,
           week.month_start_date, week.month_end_date,
           week.week, week.week_description,
           week.sd, week.ed,
           day, to_char(day)
    from
    (
      select week.sd+rownum-1 day
       from msd_dem_time
       where rownum < week.ed-week.sd+2
     MINUS
     select day
     from msd_dem_time
     where calendar_type = 2
       and calendar_code = week.calendar_code
       and week_start_date = week.sd
       and week_end_date = week.ed
    );
  end loop;

MSD_DEM_COMMON_UTILITIES.LOG_DEBUG('End Time: '|| to_char(SYSTIMESTAMP,'DD-MM-YYYY HH24:MI:SS'));

end msd_dem_fix_manufacturing;



--

Procedure collect_time_data(
				errbuf  OUT NOCOPY  VARCHAR2,
                        	retcode OUT NOCOPY  VARCHAR2,
                        	P_AUTO_RUN_DOWNLOAD IN NUMBER )
IS


cursor c_cals is
select mai.instance_id instance, mdc.calendar_type calendar_type, mdc.calendar_code calendar_code
from msd_dem_calendars mdc,
		 msc_apps_instances mai
where mdc.instance = mai.instance_code;

cursor c_fiscal_cal_data(p_instance_id number, P_calendar_code varchar2) is
select
	SR_INSTANCE_ID,
	calendar_code,
	YEAR,
	YEAR_START_DATE,
	YEAR_END_DATE,
	QUARTER,
	QUARTER_START_DATE,
	QUARTER_END_DATE,
	MONTH,
	MONTH_START_DATE,
	MONTH_END_DATE
from 	msc_calendar_months
where 	sr_instance_id = p_instance_id
and   	calendar_code = p_calendar_code;

cursor get_lowest_level is
select msd_dem_common_utilities.dm_time_level
from dual;

v_num_of_days number :=0;

l_instance_code varchar2(30);
l_calendar_code varchar2(30);
l_calendar_type number;

l_lowest_level varchar2(30);

l_stmt varchar2(5000);

g_msd_schema_name  varchar2(50)         := NULL;
x_sql		   VARCHAR2(500)	:= NULL;

BEGIN

MSD_DEM_COMMON_UTILITIES.LOG_DEBUG('In Procedure: COLLECT_TIME_DATA');


if p_auto_run_download <> 1 then

		msd_dem_common_utilities.log_message('Calendars Download Not Selected');
		msd_dem_common_utilities.log_debug('Calendars Download Not Selected');
		retcode := 0;
		return;

end if;


	open get_lowest_level;
	fetch get_lowest_level into l_lowest_level;
	close get_lowest_level;


	 /* Get the msd schema name */
         x_sql := 'DECLARE x_retval BOOLEAN; x_dummy1 VARCHAR2(50); x_dummy2 VARCHAR2(50); BEGIN x_retval := fnd_installation.get_app_info' || ' ( ''MSD'', x_dummy1, x_dummy2, :x_out1); END;';
         EXECUTE IMMEDIATE x_sql USING OUT g_msd_schema_name;

         msd_dem_common_utilities.log_debug ('MSD Schema: ' || g_msd_schema_name);

		l_stmt := 'truncate table '|| g_msd_schema_name||'.msd_dem_time';

  	        msd_dem_common_utilities.log_debug(l_stmt);
		execute immediate l_stmt ;

	for l_cals in c_cals
	loop

	l_stmt := null;



		msd_dem_common_utilities.log_message('Collecting Calendar: '|| l_cals.Calendar_code);

	    if(l_cals.calendar_type = 'Fiscal') then

	     for l_fiscal_cal_data in c_fiscal_cal_data(l_cals.instance , /*substr(l_cals.calendar_code, instr(l_cals.calendar_code, ':')+1)*/ l_cals.calendar_code)
	     loop

	     		if l_lowest_level = 'Day' then

	        	For v_num_of_days in 0..(l_fiscal_cal_data.month_end_date - l_fiscal_cal_data.month_start_date)
	        	loop

	     				insert into msd_dem_time(instance,
                        							 calendar_type,
                        							 calendar_code,
                        							 YEAR,
                                       YEAR_DESCRIPTION,
                                       YEAR_START_DATE,
                                       YEAR_END_DATE,
                                       QUARTER,
                                       QUARTER_DESCRIPTION,
                                       QUARTER_START_DATE,
                                       QUARTER_END_DATE,
                                       MONTH,
                                       MONTH_DESCRIPTION,
                                       MONTH_START_DATE,
                                       MONTH_END_DATE,
                                       DAY,
                                       DAY_DESCRIPTION,
                                       LAST_UPDATE_DATE,
                                       last_updated_by,
                                       creation_date,
                                       created_by,
                                       LAST_UPDATE_LOGIN )
            			values (l_fiscal_cal_data.sr_instance_id,
                        3,
                        l_fiscal_cal_data.calendar_code,
/* Bug# 5859307
                        l_fiscal_cal_data.YEAR,
*/                      to_char(l_fiscal_cal_data.YEAR_START_DATE, 'YYYY/MM/DD'),
                        l_fiscal_cal_data.YEAR,
                        l_fiscal_cal_data.YEAR_START_DATE,
                        l_fiscal_cal_data.YEAR_END_DATE,
/* Bug# 5859307
                        l_fiscal_cal_data.QUARTER,
*/                      to_char(l_fiscal_cal_data.QUARTER_START_DATE, 'YYYY/MM/DD'),
                        l_fiscal_cal_data.QUARTER,
                        l_fiscal_cal_data.QUARTER_START_DATE,
                        l_fiscal_cal_data.QUARTER_END_DATE,
/* Bug# 5859307
                        l_fiscal_cal_data.MONTH,
*/                      to_char(l_fiscal_cal_data.MONTH_START_DATE, 'YYYY/MM/DD'),
                        l_fiscal_cal_data.MONTH,
                        l_fiscal_cal_data.MONTH_START_DATE,
                        l_fiscal_cal_data.MONTH_END_DATE,
			                  l_fiscal_cal_data.MONTH_START_DATE + v_num_of_days,
			                  l_fiscal_cal_data.MONTH_START_DATE + v_num_of_days,
			                  sysdate,
			                  FND_GLOBAL.USER_ID ,
			                  sysdate,
			                  FND_GLOBAL.USER_ID ,
			                  FND_GLOBAL.USER_ID
		 								) ;
              commit;

	         end loop ;

	      else

	      	insert into msd_dem_time(instance,
                        							 calendar_type,
                        							 calendar_code,
                        							 YEAR,
                                       YEAR_DESCRIPTION,
                                       YEAR_START_DATE,
                                       YEAR_END_DATE,
                                       QUARTER,
                                       QUARTER_DESCRIPTION,
                                       QUARTER_START_DATE,
                                       QUARTER_END_DATE,
                                       MONTH,
                                       MONTH_DESCRIPTION,
                                       MONTH_START_DATE,
                                       MONTH_END_DATE,
                                       LAST_UPDATE_DATE,
                                       last_updated_by,
                                       creation_date,
                                       created_by,
                                       LAST_UPDATE_LOGIN )
            			values (l_fiscal_cal_data.sr_instance_id,
                        3,
                        l_fiscal_cal_data.calendar_code,
/* Bug# 5859307
                        l_fiscal_cal_data.YEAR,
*/                      to_char(l_fiscal_cal_data.YEAR_START_DATE, 'YYYY/MM/DD'),
                        l_fiscal_cal_data.YEAR,
                        l_fiscal_cal_data.YEAR_START_DATE,
                        l_fiscal_cal_data.YEAR_END_DATE,
/* Bug# 5859307
                        l_fiscal_cal_data.QUARTER,
*/                      to_char(l_fiscal_cal_data.QUARTER_START_DATE, 'YYYY/MM/DD'),
                        l_fiscal_cal_data.QUARTER,
                        l_fiscal_cal_data.QUARTER_START_DATE,
                        l_fiscal_cal_data.QUARTER_END_DATE,
/* Bug# 5859307
                        l_fiscal_cal_data.MONTH,
*/                      to_char(l_fiscal_cal_data.MONTH_START_DATE, 'YYYY/MM/DD'),
                        l_fiscal_cal_data.MONTH,
                        l_fiscal_cal_data.MONTH_START_DATE,
                        l_fiscal_cal_data.MONTH_END_DATE,
			                  sysdate,
			                  FND_GLOBAL.USER_ID ,
			                  sysdate,
			                  FND_GLOBAL.USER_ID ,
			                  FND_GLOBAL.USER_ID
		 								) ;
              commit;

	      end if;


	     end loop;

	     elsif (l_cals.calendar_type = 'Manufacturing') then

	       msd_dem_query_utilities.get_query(retcode, l_stmt, 'CAL', null);

	       MSD_DEM_COMMON_UTILITIES.LOG_DEBUG(L_STMT);

	       MSD_DEM_COMMON_UTILITIES.LOG_DEBUG('Instance: '|| l_cals.instance);
	       MSD_DEM_COMMON_UTILITIES.LOG_DEBUG('Calendar Code: '|| l_cals.calendar_CODE);

               MSD_DEM_COMMON_UTILITIES.LOG_DEBUG('Start Time: '|| to_char(SYSTIMESTAMP,'DD-MM-YYYY HH24:MI:SS'));

	       execute immediate l_stmt using l_cals.instance, l_cals.calendar_CODE;

	       MSD_DEM_COMMON_UTILITIES.LOG_DEBUG('End Time: '|| to_char(SYSTIMESTAMP,'DD-MM-YYYY HH24:MI:SS'));


	        if l_lowest_level = 'Day' then
	       	msd_dem_fix_manufacturing(l_cals.calendar_CODE);
	      end if;

	       commit;
	  END IF;
	 end loop;


	 l_stmt := 'alter session set current_schema=' || fnd_profile.value('MSD_DEM_SCHEMA');
	 execute immediate l_stmt;

   l_stmt := 'begin ' || fnd_profile.value('MSD_DEM_SCHEMA') || '.Integration_1_Load_Calendars' ||
             '(''' || fnd_profile.value('MSD_DEM_FISCAL_CALENDAR') || ''')' ||'; end;';


   msd_dem_common_utilities.log_debug(l_stmt);
   execute immediate l_stmt;

   l_stmt := 'alter session set current_schema=APPS';
   execute immediate l_stmt;


retcode := 0;

EXCEPTION

          when others then
          			l_stmt := 'alter session set current_schema=APPS';
   							execute immediate l_stmt;
                MSD_DEM_COMMON_UTILITIES.LOG_MESSAGE( substr(SQLERRM,1,150));
                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;

end  collect_time_data;

END MSD_DEM_TIME_DATA;


/
