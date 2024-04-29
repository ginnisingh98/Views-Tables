--------------------------------------------------------
--  DDL for Package Body MSD_TRANSLATE_TIME_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_TRANSLATE_TIME_DATA" AS
/* $Header: msdttimb.pls 115.22 2004/08/05 10:46:26 sudekuma ship $ */

/* Private Global Variables **/
g_seq_num NUMBER := 0 ;


-- Public Procedures

procedure translate_time_data(
                        errbuf                  OUT NOCOPY  VARCHAR2,
                        retcode                 OUT NOCOPY  VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id           IN  NUMBER,
                        p_calendar_type_id      IN  NUMBER,
                        p_calendar_code         IN  VARCHAR2,
                        p_from_date             IN  DATE,
                        p_to_date               IN  DATE) IS
v_instance_id    varchar2(40);
v_retcode       number;
v_sql_stmt       varchar2(4000);
x_dblink       varchar2(128);
TYPE Fiscal_Month_Cursor IS REF CURSOR;
TYPE Update_Cursor IS REF CURSOR;
Fiscal_Month_Cur Fiscal_Month_Cursor ;
Update_Cur Update_Cursor ;
x_calendar_code  			   varchar2(15);
x_SEQ_NUM                                  NUMBER;
x_YEAR                                     VARCHAR2(15);
x_YEAR_DESCRIPTION                         VARCHAR2(15);
x_YEAR_START_DATE                          DATE;
x_YEAR_END_DATE                            DATE;
x_QUARTER                                  VARCHAR2(15);
x_QUARTER_DESCRIPTION                      VARCHAR2(15);
x_QUARTER_START_DATE                       DATE;
x_QUARTER_END_DATE                         DATE;
x_MONTH                                    VARCHAR2(15);
x_MONTH_DESCRIPTION                        VARCHAR2(15);
x_MONTH_START_DATE                         DATE;
x_MONTH_END_DATE                           DATE;
x_max_days				   DATE ;

l_calendar_code                            VARCHAR2(20);
v_day_range_stmt                           VARCHAR2(4000);
v_month_range_stmt                           VARCHAR2(4000);

Begin


        /**************************************************
        -       1. Get the instance id from MSC_APP_INSTANCE
        -       2. Get the Profile Value for MSD_DIRECT_LOAD
        -          to identify whether we need to insert the
        -          data into the staging tables or the
        -          fact tables.
        -       3. Check for the Data Duplication, we should
        -          use the forecast_designator for this fact.
        -       4. Insert the Data accordingly into the
        -          Staging or the Fact table based on the
        -          MSD_SR_MFG_FCST_V
        -       5. Commit
        ****************************************************/


        retcode :=0;
        Savepoint Before_Delete ;


        IF (p_calendar_type_id <> MSD_COMMON_UTILITIES.GREGORIAN_CALENDAR ) THEN
           msd_common_utilities.get_db_link(p_instance_id, x_dblink, retcode);
           if (retcode = -1) then
               retcode :=-1;
               return;
           end if;
        END IF;


/* TEST DWK */
        IF (p_calendar_type_id = MSD_COMMON_UTILITIES.GREGORIAN_CALENDAR ) THEN
           l_calendar_code := 'GREGORIAN';
        ELSE
           l_calendar_code := p_calendar_code;
        END IF;

        /* DWK   Delete existing data from MSD_TIME before collection */

        if (l_calendar_code is null) then
          delete from msd_time
          where calendar_type = p_calendar_type_id;
        else
          delete from msd_time
          where calendar_code = l_calendar_code
          and calendar_type = p_calendar_type_id;
        end if;

        v_day_range_stmt := ' and day between :p_from_date AND :p_to_date ';
        v_month_range_stmt := ' and month_end_date between :p_from_date AND :p_to_date ';


	 /* You need to generate all the Gregorian Hierarchy for this
	    Date range mentioned below 	*/
        /* DWK outer IF 1 */
	IF (p_calendar_type_id = MSD_COMMON_UTILITIES.GREGORIAN_CALENDAR ) then

		Generate_Gregorian( errbuf,
                                    retcode,
                                    l_calendar_code,
                                    p_from_date,
                                    p_to_date ) ;

	/* In this section the Hierarchy is already exploded to the Day Level */
        /* ELSIF for outer IF 1 */
	ELSIF (p_calendar_type_id = MSD_COMMON_UTILITIES.MANUFACTURING_CALENDAR) or
	      (  ( (p_calendar_type_id = MSD_COMMON_UTILITIES.FISCAL_CALENDAR)
                     or
                   (p_calendar_type_id = MSD_COMMON_UTILITIES.COMPOSITE_CALENDAR)

)
               and
                 (p_source_table = MSD_COMMON_UTILITIES.TIME_STAGING_TABLE) ) then

              v_sql_stmt :=  'insert into ' || p_dest_table || ' ( ' ||
                        'instance, ' ||
                        'calendar_type, ' ||
                        'calendar_code, ' ||
                        'seq_num, ' ||
                        'YEAR, ' ||
                        'YEAR_DESCRIPTION, ' ||
                        'YEAR_START_DATE, ' ||
                        'YEAR_END_DATE, ' ||
                        'QUARTER, ' ||
                        'QUARTER_DESCRIPTION, ' ||
                        'QUARTER_START_DATE, ' ||
                        'QUARTER_END_DATE, ' ||
                        'MONTH, ' ||
                        'MONTH_DESCRIPTION, ' ||
                        'MONTH_START_DATE, ' ||
                        'MONTH_END_DATE, ' ||
                        'WEEK, ' ||
                        'WEEK_DESCRIPTION, ' ||
                        'WEEK_START_DATE, ' ||
                        'WEEK_END_DATE, ' ||
                        'DAY, ' ||
                        'DAY_DESCRIPTION, ' ||
			'LAST_UPDATE_DATE, ' ||
                        'last_updated_by, ' ||
                        'creation_date, ' ||
                        'created_by, ' ||
                        'LAST_UPDATE_LOGIN )  ' ||
                        'select  ''' ||
                         p_instance_id ||''', ' ||
                         p_calendar_type_id ||
                        ', calendar_code, ' ||
                        'seq_num, ' ||
                        'YEAR, ' ||
                        'YEAR_DESCRIPTION, ' ||
                        'YEAR_START_DATE, ' ||
                        'YEAR_END_DATE, ' ||
                        'QUARTER, ' ||
                        'QUARTER_DESCRIPTION, ' ||
                        'QUARTER_START_DATE, ' ||
                        'QUARTER_END_DATE, ' ||
                        'MONTH, ' ||
                        'MONTH_DESCRIPTION, ' ||
                        'MONTH_START_DATE, ' ||
                        'MONTH_END_DATE, ' ||
                        'WEEK, ' ||
                        'WEEK_DESCRIPTION, ' ||
                        'WEEK_START_DATE, ' ||
                        'WEEK_END_DATE, ' ||
                        'DAY, ' ||
                        'DAY_DESCRIPTION, ' ||
                        'sysdate, ' ||
                        FND_GLOBAL.USER_ID || ', ' ||
                        'sysdate, ' ||
                        FND_GLOBAL.USER_ID || ', ' ||
                        FND_GLOBAL.USER_ID || ' ' ||
                        'from ' ||
                        p_source_table ||
			' where calendar_code = NVL(:l_calendar_code, calendar_code)' ;

	        --  If it is from the staging area then we need to add the
	        --  filter for unique instance id
	        if (p_source_table = MSD_COMMON_UTILITIES.TIME_STAGING_TABLE) then
                   v_sql_stmt := v_sql_stmt || ' and instance = :p_instance_id ';
                end if ;

               if  ((p_calendar_type_id = MSD_COMMON_UTILITIES.MANUFACTURING_CALENDAR)
                  and
                    (p_source_table <> MSD_COMMON_UTILITIES.TIME_STAGING_TABLE)
                  and (l_calendar_code is null)) then
	           v_sql_stmt := v_sql_stmt || ' and calendar_code in (SELECT distinct mod.calendar_code FROM msd_organization_definitions';
                   v_sql_stmt := v_sql_stmt || x_dblink || ' mod' || ', msd_app_instance_orgs' || x_dblink || ' maio' || ' WHERE mod.organization_id = maio.organization_id) ';
                end if;


                /* DWK  Populate dates which falls within day range */
                v_sql_stmt := v_sql_stmt || v_day_range_stmt;


	        if (p_source_table = MSD_COMMON_UTILITIES.TIME_STAGING_TABLE) then
                   EXECUTE IMMEDIATE v_sql_stmt
                               using l_calendar_code,
                                     p_instance_id,
                                     nvl(p_from_date, to_date('01-01-0001', 'DD-MM-RRRR')),
                                     nvl(p_to_date, to_date('01-01-9999', 'DD-MM-RRRR'));
                else

                  EXECUTE IMMEDIATE v_sql_stmt
                              using l_calendar_code,
                                    nvl(p_from_date, to_date('01-01-0001', 'DD-MM-RRRR')),
                                    nvl(p_to_date, to_date('01-01-9999', 'DD-MM-RRRR'));
                end if;

	/* In this range we need to get the information for the Days */
	/* for the Fiscal Calendar from the source views */
        /* DWK  ELSE for outer IF 1 */
	ELSE
	   v_sql_stmt :=   'select  ' ||
                        ' calendar_code, '  ||
                        ' YEAR, ' ||
                        ' YEAR_DESCRIPTION, ' ||
                        ' YEAR_START_DATE, ' ||
                        ' YEAR_END_DATE, ' ||
                        ' QUARTER, ' ||
                        ' QUARTER_DESCRIPTION, ' ||
                        ' QUARTER_START_DATE, ' ||
                        ' QUARTER_END_DATE, ' ||
                        ' MONTH, ' ||
                        ' MONTH_DESCRIPTION, ' ||
                        ' MONTH_START_DATE, ' ||
                        ' MONTH_END_DATE  ' ||
                        ' from ' ||
                        p_source_table ||
                        ' where calendar_code = NVL( :p_calendar_code ' ||
                        ', calendar_code) ' || v_month_range_stmt;


  	   OPEN Fiscal_Month_Cur FOR v_sql_stmt
                               using p_calendar_code,
                                     nvl(p_from_date, to_date('01-01-0001', 'DD-MM-RRRR')),
                                     nvl(p_to_date, to_date('01-01-9999', 'DD-MM-RRRR'));

	   LOOP
  	      FETCH Fiscal_Month_Cur
	      INTO 	x_calendar_code,
				x_YEAR,
				x_YEAR_DESCRIPTION,
				x_YEAR_START_DATE,
				x_YEAR_END_DATE,
				x_QUARTER,
				x_QUARTER_DESCRIPTION,
				x_QUARTER_START_DATE,
				x_QUARTER_END_DATE,
				x_MONTH,
				x_MONTH_DESCRIPTION,
				x_MONTH_START_DATE,
				x_MONTH_END_DATE;

      	      EXIT WHEN Fiscal_Month_Cur%NOTFOUND;

	      Explode_Fiscal_Dates(
                        	errbuf  		=> errbuf,
                        	retcode 		=> retcode,
                        	p_dest_table 		=> p_dest_table,
                        	p_instance_id           => p_instance_id,
                        	p_calendar_type_id      => p_calendar_type_id,
                        	p_calendar_code         => x_calendar_code,
				p_seq_num		=> null,
				p_year			=> x_year,
				p_year_description	=> x_year_description,
				p_year_start_date	=> x_year_start_date,
				p_year_end_date		=> x_year_end_date,
				p_quarter		=> x_quarter,
				p_quarter_description	=> x_quarter_description,
				p_quarter_start_date	=> x_quarter_start_date,
				p_quarter_end_date	=> x_quarter_end_date,
				p_month			=> x_month,
				p_month_description	=> x_month_description,
				p_month_start_date	=> x_month_start_date,
				p_month_end_date	=> x_month_end_date,
                        	p_from_date             => p_from_date,
                        	p_to_date               => p_to_date );

   	   END LOOP;
	   CLOSE Fiscal_Month_Cur;

	END IF;	/* End of outer IF 1 */

        -- fill in missing dates for manufacturing calendar on the fact
        if (p_calendar_type_id = MSD_COMMON_UTILITIES.MANUFACTURING_CALENDAR) and
           (p_dest_table = MSD_COMMON_UTILITIES.TIME_FACT_TABLE) then
              fix_manufacturing(errbuf, retcode, p_calendar_code);
        end if;

        COMMIT;


EXCEPTION

          when others then

                errbuf := substr(SQLERRM,1,150);
                fnd_file.put_line(fnd_file.log, substr(SQLERRM,1,1000));
                retcode := -1 ;
                rollback to Savepoint Before_Delete ;


END translate_time_data ;


/* Even though the Start and End dates are passed we do not use
   them as we do not use them for fiscal calendar
*/
procedure Explode_Fiscal_Dates(
              errbuf                  OUT NOCOPY  VARCHAR2,
              retcode                 OUT NOCOPY  VARCHAR2,
              p_dest_table            IN  VARCHAR2,
              p_instance_id           IN  NUMBER,
              p_calendar_type_id      IN  NUMBER,
              p_calendar_code         IN  VARCHAR2,
              p_seq_num               IN  NUMBER,
              p_year                  IN  VARCHAR2,
              p_year_description      IN  VARCHAR2,
              p_year_start_date       IN  DATE,
              p_year_end_date         IN  DATE,
              p_quarter               IN  VARCHAR2,
              p_quarter_description   IN  VARCHAR2,
              p_quarter_start_date    IN  DATE,
              p_quarter_end_date      IN  DATE,
              p_month                 IN  VARCHAR2,
              p_month_description     IN  VARCHAR2,
              p_month_start_date      IN  DATE,
              p_month_end_date        IN  DATE,
              p_from_date             IN  DATE,
              p_to_date               IN  DATE)  IS

v_num_of_days   NUMBER;
v_current_date DATE ;
x_count         NUMBER;
Begin

	x_count := p_month_end_date - p_month_start_date ;

	if (p_dest_table = MSD_COMMON_UTILITIES.TIME_FACT_TABLE) then

          For v_num_of_days in 0..(p_month_end_date - p_month_start_date) LOOP

	    g_seq_num := g_seq_num + 1 ;

            insert into msd_time  (
                        instance,
                        calendar_type,
                        calendar_code,
                        seq_num,
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
            values(
              		p_instance_id,
              		p_calendar_type_id,
              		p_calendar_code,
              		g_seq_num,
              		p_year,
              		p_year_description,
              		p_year_start_date,
              		p_year_end_date,
              		p_quarter,
              		p_quarter_description,
              		p_quarter_start_date,
              		p_quarter_end_date,
              		p_month,
              		p_month_description,
              		p_month_start_date,
              		p_month_end_date,
			p_month_start_date+v_num_of_days,
			p_month_start_date+v_num_of_days,
			sysdate,
			FND_GLOBAL.USER_ID ,
			sysdate,
			FND_GLOBAL.USER_ID ,
			FND_GLOBAL.USER_ID
		 ) ;


	    End Loop ;

        elsif (p_dest_table = MSD_COMMON_UTILITIES.TIME_STAGING_TABLE) then

          For v_num_of_days in 0..(p_month_end_date - p_month_start_date) LOOP

	    g_seq_num := g_seq_num + 1 ;

            insert into msd_st_time  (
                        instance,
                        calendar_type,
                        calendar_code,
                        seq_num,
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
            values(
                        p_instance_id,
                        p_calendar_type_id,
                        p_calendar_code,
                        g_seq_num,
                        p_year,
                        p_year_description,
                        p_year_start_date,
                        p_year_end_date,
                        p_quarter,
                        p_quarter_description,
                        p_quarter_start_date,
                        p_quarter_end_date,
                        p_month,
                        p_month_description,
                        p_month_start_date,
                        p_month_end_date,
                        p_month_start_date+v_num_of_days,
                        p_month_start_date+v_num_of_days,
                        sysdate,
			FND_GLOBAL.USER_ID ,
			sysdate,
			FND_GLOBAL.USER_ID ,
			FND_GLOBAL.USER_ID
		 ) ;

            End Loop ;

	End if ;


        exception

          when others then
                fnd_file.put_line(fnd_file.log, substr(SQLERRM,1,1000));
                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;


End Explode_Fiscal_Dates ;


procedure    Generate_Gregorian(
                        errbuf          OUT NOCOPY  VARCHAR2,
                        retcode         OUT NOCOPY  VARCHAR2,
                        p_calendar_code IN  VARCHAR2,
                        p_from_date     IN  DATE,
                        p_to_date       IN  DATE ) IS
v_instance_id    varchar2(40);
v_retcode       number;
v_sql_stmt       varchar2(4000);
v_num_of_days    number ;
v_seq		 number ;
x_count          number ;
Begin

	x_count := p_to_date - p_from_date ;

	For v_num_of_days in 0..x_count  LOOP

	v_seq := v_num_of_days + 1 ;

        insert into msd_time  (
                        instance,
                        calendar_type,
                        calendar_code,
                        seq_num,
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
	values (
                -1,
                1,
                p_calendar_code,
                v_seq,
                to_char(p_from_date+v_num_of_days,'YYYY','nls_date_language = AMERICAN'),
                to_char(p_from_date+v_num_of_days,'YYYY','nls_date_language = AMERICAN'),
                fnd_date.string_to_date('01-JAN-'||to_char(p_from_date+v_num_of_days,'YYYY'),
                        'DD-MON-YYYY'),
                fnd_date.string_to_date('31-DEC-'||to_char(p_from_date+v_num_of_days,'YYYY'),
                        'DD-MON-YYYY'),
                decode(to_char(p_from_date+v_num_of_days,'MM','nls_date_language = AMERICAN'),
                        '01', 'Qtr 1',
                        '02', 'Qtr 1',
                        '03', 'Qtr 1',
                        '04', 'Qtr 2',
                        '05', 'Qtr 2',
                        '06', 'Qtr 2',
                        '07', 'Qtr 3',
                        '08', 'Qtr 3',
                        '09', 'Qtr 3',
                        '10', 'Qtr 4',
                        '11', 'Qtr 4',
                        '12', 'Qtr 4') || ' ' || to_char(p_from_date+v_num_of_days,'YYYY','nls_date_language = AMERICAN'),
                decode(to_char(p_from_date+v_num_of_days,'MM','nls_date_language = AMERICAN'),
                        '01', 'Qtr 1',
                        '02', 'Qtr 1',
                        '03', 'Qtr 1',
                        '04', 'Qtr 2',
                        '05', 'Qtr 2',
                        '06', 'Qtr 2',
                        '07', 'Qtr 3',
                        '08', 'Qtr 3',
                        '09', 'Qtr 3',
                        '10', 'Qtr 4',
                        '11', 'Qtr 4',
                        '12', 'Qtr 4') || ' ' || to_char(p_from_date+v_num_of_days,'YYYY','nls_date_language = AMERICAN'),
                fnd_date.string_to_date(decode(to_char(p_from_date+v_num_of_days,'MM','nls_date_language = AMERICAN'),
                        '01', '01-JAN-',
                        '02', '01-JAN-',
                        '03', '01-JAN-',
                        '04', '01-APR-',
                        '05', '01-APR-',
                        '06', '01-APR-',
                        '07', '01-JUL-',
                        '08', '01-JUL-',
                        '09', '01-JUL-',
                        '10', '01-OCT-',
                        '11', '01-OCT-',
                        '12', '01-OCT-')||to_char(p_from_date+v_num_of_days,'YYYY','nls_date_language = AMERICAN'),
                        'DD-MON-YYYY'),
                fnd_date.string_to_date(decode(to_char(p_from_date+v_num_of_days,'MM','nls_date_language = AMERICAN'),
                        '01', '31-MAR-',
                        '02', '31-MAR-',
                        '03', '31-MAR-',
                        '04', '30-JUN-',
                        '05', '30-JUN-',
                        '06', '30-JUN-',
                        '07', '30-SEP-',
                        '08', '30-SEP-',
                        '09', '30-SEP-',
                        '10', '31-DEC-',
                        '11', '31-DEC-',
                        '12', '31-DEC-')||to_char(p_from_date+v_num_of_days,'YYYY','nls_date_language = AMERICAN'),
                        'DD-MON-YYYY'),
                to_char(p_from_date+v_num_of_days,'MON','nls_date_language = AMERICAN')||' '||
                to_char(p_from_date+v_num_of_days,'YYYY','nls_date_language = AMERICAN'),
                to_char(p_from_date+v_num_of_days,'MON','nls_date_language = AMERICAN')||' '||
                to_char(p_from_date+v_num_of_days,'YYYY','nls_date_language = AMERICAN'),
                fnd_date.string_to_date(decode(to_char(p_from_date+v_num_of_days,'MM','nls_date_language = AMERICAN'),
                        '01', '01-JAN-',
                        '02', '01-FEB-',
                        '03', '01-MAR-',
                        '04', '01-APR-',
                        '05', '01-MAY-',
                        '06', '01-JUN-',
                        '07', '01-JUL-',
                        '08', '01-AUG-',
                        '09', '01-SEP-',
                        '10', '01-OCT-',
                        '11', '01-NOV-',
                        '12', '01-DEC-')||to_char(p_from_date+v_num_of_days,'YYYY','nls_date_language = AMERICAN'),
                        'DD-MON-YYYY'),
                fnd_date.string_to_date(decode(to_char(p_from_date+v_num_of_days,'MM','nls_date_language = AMERICAN'),
                        '01', '31-JAN-',
                        '02', decode(mod(to_number(
				     to_char(p_from_date+v_num_of_days,'YYYY','nls_date_language = AMERICAN')),4),
                                  0, '29-FEB-',
                                  '28-FEB-'),
                        '03', '31-MAR-',
                        '04', '30-APR-',
                        '05', '31-MAY-',
                        '06', '30-JUN-',
                        '07', '31-JUL-',
                        '08', '31-AUG-',
                        '09', '30-SEP-',
                        '10', '31-OCT-',
                        '11', '30-NOV-',
                        '12', '31-DEC-')||to_char(p_from_date+v_num_of_days,'YYYY','nls_date_language = AMERICAN'),
                        'DD-MON-YYYY'),
                ((p_from_date)+(v_num_of_days)),
                to_char((p_from_date)+(v_num_of_days), 'DD-MON-YYYY','nls_date_language = AMERICAN'),
                sysdate,
                FND_GLOBAL.USER_ID ,
                sysdate,
                FND_GLOBAL.USER_ID ,
                FND_GLOBAL.USER_ID
                ) ;

	End Loop ;

	return ;

        exception

          when others then
                fnd_file.put_line(fnd_file.log, substr(SQLERRM,1,1000));
                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;

End Generate_Gregorian ;


procedure fix_manufacturing(errbuf out nocopy  varchar2,
                            retcode out nocopy  varchar2,
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
    from msd_time
    where calendar_type = 2
      and calendar_code = nvl(p_cal_code, calendar_code);

begin

  retcode := 0;

  for week in weeks loop

    -- insert missing days in this week
    insert into msd_time(INSTANCE, CALENDAR_TYPE, CALENDAR_CODE, SEQ_NUM,
                         LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
                         CREATED_BY, LAST_UPDATE_LOGIN,
                         MONTH, MONTH_DESCRIPTION,
                         MONTH_START_DATE, MONTH_END_DATE,
                         WEEK, WEEK_DESCRIPTION,
                         WEEK_START_DATE, WEEK_END_DATE,
                         DAY, DAY_DESCRIPTION,
                         WORKING_DAY)
    select week.instance, 2, week.calendar_code, -1,
           sysdate, fnd_global.user_id, sysdate, fnd_global.user_id, fnd_global.user_id,
           week.month, week.month_description,
           week.month_start_date, week.month_end_date,
           week.week, week.week_description,
           week.sd, week.ed,
           day, to_char(day),
           'NO'
    from
    (
      select week.sd+rownum-1 day
       from msd_time
       where rownum < week.ed-week.sd+2
     MINUS
     select day
     from msd_time
     where calendar_type = 2
       and calendar_code = week.calendar_code
       and week_start_date = week.sd
       and week_end_date = week.ed
    );
  end loop;

  exception
    when others then
         fnd_file.put_line(fnd_file.log, substr(SQLERRM,1,1000));
         errbuf := substr(SQLERRM,1,150);
         retcode := -1;

end fix_manufacturing;



END MSD_TRANSLATE_TIME_DATA ;

/
