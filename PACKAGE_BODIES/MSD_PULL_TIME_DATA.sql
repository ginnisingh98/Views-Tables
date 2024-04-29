--------------------------------------------------------
--  DDL for Package Body MSD_PULL_TIME_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_PULL_TIME_DATA" AS
/* $Header: msdptimb.pls 115.4 2002/10/28 21:33:54 dkang ship $ */





procedure pull_time_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) IS
x_source_table   VARCHAR2(50) := MSD_COMMON_UTILITIES.TIME_STAGING_TABLE ;
x_dest_table     VARCHAR2(50) := MSD_COMMON_UTILITIES.TIME_FACT_TABLE ;
/*********************************************************************
  Cursor to get distinct Instance, Calendar_Code Max Data and Min Date
*********************************************************************/
/* DWK. Fix Bug 2220983. Do not include instance = '0' in the cursor */
Cursor  Calendar is
select  instance,
	calendar_code,
	calendar_type,
	min(day) min_day,
	max(day) max_day
from    msd_st_time
where   instance <> '0'
group by instance, calendar_code, calendar_type;
Begin


	retcode :=0;

        For Calendar_Rec IN Calendar LOOP


                MSD_TRANSLATE_TIME_DATA.translate_time_data(
                        errbuf              	=> errbuf,
                        retcode             	=> retcode,
                        p_source_table      	=> x_source_table,
                        p_dest_table        	=> x_dest_table,
                        p_instance_id       	=> Calendar_Rec.instance,
                        p_calendar_type_id      => Calendar_Rec.calendar_type,
                        p_calendar_code    	=> Calendar_Rec.calendar_code,
                        p_from_date       	=> Calendar_Rec.min_day,
                        p_to_date   		=> Calendar_Rec.max_day ) ;


		Delete 	from msd_st_time
		where  	instance = Calendar_Rec.instance
		and	calendar_code = Calendar_Rec.calendar_code
		and	calendar_type = Calendar_Rec.calendar_type
		and     day between Calendar_Rec.min_day and Calendar_Rec.max_day ;

		commit ;

	End Loop ;

        /* Added by esubrama */
        MSD_ANALYZE_TABLES.analyze_table('MSD_TIME',null);
        MSD_ANALYZE_TABLES.analyze_table('MSD_ST_TIME',null);

	exception

	  when others then

		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;


End pull_time_data ;


END MSD_PULL_TIME_DATA ;

/
