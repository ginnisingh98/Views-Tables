--------------------------------------------------------
--  DDL for Package Body MSD_COLLECT_TIME_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_COLLECT_TIME_DATA" AS
/* $Header: msdctimb.pls 120.2 2008/03/07 11:34:59 lannapra ship $ */

/*
/* Public Procedures */

procedure collect_time_data(
                     errbuf              OUT NOCOPY VARCHAR2,
                     retcode             OUT NOCOPY VARCHAR2,
                     p_instance_id       IN  NUMBER,
                     p_calendar_type_id      IN  VARCHAR2,
                     p_calendar_code         IN  VARCHAR2,
                     p_from_date             IN  VARCHAR2,
                     p_to_date               IN  VARCHAR2) IS

x_instance_id    varchar2(40);
x_dblink         varchar2(128);
x_retcode       number;
x_direct_load_profile  boolean;
x_source_table  VARCHAR2(50) ;
x_dest_table    varchar2(50) ;
x_sql_stmt       varchar2(4000);
x_from_date     DATE;
x_to_date       DATE;
l_calendar_count number := 0;

/* OPM Comment By Rajesh Patangya   */
o_source_table  VARCHAR2(50) ;
o_dblink         varchar2(128);
o_icode          varchar2(128);
o_retcode        number;
o_instance_type  number;
o_dgmt           number;
o_apps_ver       number;
calendar_code_and_type	varchar2(10);

Begin

        retcode :=0;

        msd_common_utilities.get_db_link(p_instance_id, x_dblink, x_retcode);
        if (x_retcode = -1) and (p_calendar_type_id <> MSD_COMMON_UTILITIES.GREGORIAN_CALENDAR) then
                retcode :=-1;
                errbuf := 'Error while getting db_link';
                return;
        end if;

   /*  OPM Comment By Rajesh Patangya   */
        msd_common_utilities.get_inst_info(p_instance_id, o_dblink, o_icode,
                o_apps_ver, o_dgmt, o_instance_type, o_retcode)  ;
        if (o_retcode = -1) and (p_calendar_type_id <> MSD_COMMON_UTILITIES.GREGORIAN_CALENDAR) then
                retcode :=-1;
                errbuf := 'Error while getting instance_info';
                return;
        end if;

	if (p_calendar_type_id = MSD_COMMON_UTILITIES.GREGORIAN_CALENDAR) then
		x_source_table := null ;
                calendar_code_and_type       := 'DISCRETE' ;
	elsif (p_calendar_type_id = MSD_COMMON_UTILITIES.MANUFACTURING_CALENDAR) then
		x_source_table := MSD_COMMON_UTILITIES.MFG_TIME_SOURCE_TABLE || x_dblink ;

   /*  OPM Comment By Rajesh Patangya   */
		o_source_table := MSD_COMMON_UTILITIES.OPM_MFG_TIME_SOURCE_TABLE || x_dblink ;
	elsif (p_calendar_type_id = MSD_COMMON_UTILITIES.FISCAL_CALENDAR) then
                x_source_table := MSD_COMMON_UTILITIES.FISCAL_TIME_SOURCE_TABLE|| x_dblink ;
                calendar_code_and_type       := 'DISCRETE' ;
	end if ;

--dbms_output.put_line(x_source_table) ;

        x_direct_load_profile := (fnd_profile.value('MSD_ONE_STEP_COLLECTION')='Y');

        if (x_direct_load_profile) then
                x_dest_table := MSD_COMMON_UTILITIES.TIME_FACT_TABLE ;
        else
                x_dest_table := MSD_COMMON_UTILITIES.TIME_STAGING_TABLE ;
        end if;

--dbms_output.put_line(x_dest_table) ;
--dbms_output.put_line(p_from_date) ;
--dbms_output.put_line(p_to_date) ;

        x_from_date := FND_DATE.canonical_to_date(p_from_date);
        x_to_date := FND_DATE.canonical_to_date(p_to_date);

	if (p_calendar_type_id = MSD_COMMON_UTILITIES.GREGORIAN_CALENDAR) then
		if (p_from_date is null) then
			x_from_date := to_date('01/01/1980','DD/MM/RRRR');
		end if;
		if (p_to_date is null) then
			x_to_date := to_date('31/12/2020','DD/MM/RRRR');
		end if;
	end if;

/*
	x_from_date := to_date(p_from_date, 'DD-MON-RRRR') ;
	x_to_date := to_date(p_to_date, 'DD-MON-RRRR') ;
*/

--dbms_output.put_line(x_from_date) ;
--dbms_output.put_line(x_to_date) ;

      if ( (p_calendar_type_id = MSD_COMMON_UTILITIES.MANUFACTURING_CALENDAR) or
          (p_calendar_type_id = MSD_COMMON_UTILITIES.FISCAL_CALENDAR)) then

       /* Bug# 4620927 */
--       if o_instance_type = 1 Then  /* DIS instance */
       if o_instance_type = 1 OR o_apps_ver >= 4 Then /* DIS 11i instance OR R12 instance of any type */

 	   -- sudesh Bug # 3899742
            begin
 	     x_sql_stmt := 'select 1 from dual where exists( select null from '||x_source_table||' where calendar_code = nvl(:p_calendar_code, calendar_code)) ';
              EXECUTE IMMEDIATE x_sql_stmt INTO l_calendar_count USING p_calendar_code;
            exception
 	      when no_data_found then
                 l_calendar_count := 0;
 	   end;

-- sudesh Bug #	3899742   x_sql_stmt :=  'select count(1) ' || 'from ' ||  x_source_table ||
-- sudesh Bug # 3899742           ' where calendar_code = nvl(:p_calendar_code, calendar_code) ' ;
-- sudesh Bug # 3899742          EXECUTE IMMEDIATE x_sql_stmt INTO l_calendar_count USING p_calendar_code;

	   calendar_code_and_type	:= 'DISCRETE' ;

        elsif o_apps_ver = 3  AND o_instance_type = 2 then  /* OPM instance */
             if p_calendar_type_id = MSD_COMMON_UTILITIES.FISCAL_CALENDAR then
 	   -- sudesh Bug # 3899742
            begin

	     x_sql_stmt := 'select 1 from dual where exists( select null from '||x_source_table||' where calendar_code = nvl(:p_calendar_code, calendar_code)) ';
              EXECUTE IMMEDIATE x_sql_stmt INTO l_calendar_count USING p_calendar_code;
            exception
 	      when no_data_found then
                 l_calendar_count := 0;
   	    end;

-- sudesh Bug #	3899742                   x_sql_stmt :=  'select count(1) ' || 'from ' ||  x_source_table ||
-- sudesh Bug #	3899742                   ' where calendar_code = nvl(:p_calendar_code, calendar_code) ' ;

	       calendar_code_and_type := 'DISCRETE' ;
             else

 	   -- sudesh Bug # 3899742
            begin

	     x_sql_stmt := 'select 1 from dual where exists( select null from '||o_source_table||' where calendar_code = nvl(:p_calendar_code, calendar_code)) ';
              EXECUTE IMMEDIATE x_sql_stmt INTO l_calendar_count USING p_calendar_code;
            exception
 	      when no_data_found then
                 l_calendar_count := 0;
   	    end;

-- sudesh Bug #	3899742                x_sql_stmt :=  'select count(1) ' || 'from ' ||  o_source_table ||
-- sudesh Bug #	3899742                ' where calendar_code = nvl(:p_calendar_code, calendar_code) ' ;

	       calendar_code_and_type	:= 'PROCESS' ;
             end if ;
-- sudesh Bug #	3899742             EXECUTE IMMEDIATE x_sql_stmt INTO l_calendar_count USING p_calendar_code;

        /* OPM-DIS instance */
        elsif  o_apps_ver = 3  AND o_instance_type = 4 Then

 	   -- sudesh Bug # 3899742
            begin

	     x_sql_stmt := 'select 1 from dual where exists( select null from '||x_source_table||' where calendar_code = nvl(:p_calendar_code, calendar_code)) ';
              EXECUTE IMMEDIATE x_sql_stmt INTO l_calendar_count USING p_calendar_code;
            exception
 	      when no_data_found then
                 l_calendar_count := 0;
   	    end;

-- sudesh Bug #	3899742	   x_sql_stmt :=  'select count(1) ' || 'from ' ||  x_source_table ||
-- sudesh Bug #	3899742            ' where calendar_code = nvl(:p_calendar_code, calendar_code)' ;
-- sudesh Bug #	3899742            EXECUTE IMMEDIATE x_sql_stmt INTO l_calendar_count USING p_calendar_code;

	   calendar_code_and_type := 'DISCRETE' ;


           if ((l_calendar_count = 0) AND (p_calendar_type_id = MSD_COMMON_UTILITIES.MANUFACTURING_CALENDAR)) then
                 x_sql_stmt := NULL ;

 	   -- sudesh Bug # 3899742
            begin

	     x_sql_stmt := 'select 1 from dual where exists( select null from '||o_source_table||' where calendar_code = nvl(:p_calendar_code, calendar_code)) ';
              EXECUTE IMMEDIATE x_sql_stmt INTO l_calendar_count USING p_calendar_code;
            exception
 	      when no_data_found then
                 l_calendar_count := 0;
   	    end;

-- sudesh Bug #	3899742		 x_sql_stmt :=  'select count(1) ' ||
-- sudesh Bug #	3899742                      'from ' ||  o_source_table ||
-- sudesh Bug #	3899742                      ' where calendar_code = nvl(:p_calendar_code, calendar_code)' ;
-- sudesh Bug #	3899742                  EXECUTE IMMEDIATE x_sql_stmt INTO l_calendar_count USING p_calendar_code;

		 calendar_code_and_type	:= 'PROCESS' ;
           end if;

        end if ;

        if (l_calendar_count = 0) then
           retcode :=-1;
           errbuf := 'The specified calendar code is not defined in the source instance or no data was retrieved.';
           return;
        end if;

      end if ;

	/*  OPM Comment By Rajesh Patangya                                  */
        /*  If condition will take care of                                  */
        /*   Grogerian calendar, as calendar_code is null,                  */
        /*   if calendar_code is null, in case of manufacturing or fiscal,  */
        /*   if calendar_code is duplicate in both Discrete and process,    */
        /*   only if condition will be fired                                */

        if (calendar_code_and_type = 'DISCRETE') then
	MSD_TRANSLATE_TIME_DATA.translate_time_data(
                        errbuf                  => errbuf,
                        retcode                 => retcode,
                        p_source_table      	=> x_source_table,
                        p_dest_table        	=> x_dest_table,
                        p_instance_id           => p_instance_id,
                        p_calendar_type_id      => to_number(p_calendar_type_id),
                        p_calendar_code         => replace(p_calendar_code, '''', ''''''),
                        p_from_date             => x_from_date,
                        p_to_date               => x_to_date ) ;

                if retcode <> 0 then
                errbuf :=  ' In MSD Call for Manufacturing/Fiscal Time';
                return;
                end if ;


        /*  else part will take care of                                     */
        /*  if calendar_code is a OPM calendar                              */

        elsif calendar_code_and_type = 'PROCESS'then

	MSD_TRANSLATE_TIME_DATA.translate_time_data(
                        errbuf                  => errbuf,
                        retcode                 => retcode,
                        p_source_table      	=> o_source_table,
                        p_dest_table        	=> x_dest_table,
                        p_instance_id           => p_instance_id,
                        p_calendar_type_id      => to_number(p_calendar_type_id),
                        p_calendar_code         => replace(p_calendar_code, '''', ''''''),
                        p_from_date             => x_from_date,
                        p_to_date               => x_to_date ) ;

                if retcode <> 0 then
                errbuf :=  ' In OPM Call for Manufacturing Time';
                return;
                end if ;
        end if ;

        /* Added by esubrama */
        MSD_ANALYZE_TABLES.analyze_table(x_dest_table,null);

        exception

          when others then

                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;


End collect_time_data ;

END MSD_COLLECT_TIME_DATA ;

/
