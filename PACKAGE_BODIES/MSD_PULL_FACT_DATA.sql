--------------------------------------------------------
--  DDL for Package Body MSD_PULL_FACT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_PULL_FACT_DATA" AS
/* $Header: msdpfctb.pls 120.3 2005/12/07 07:38:58 sjagathe noship $ */


/**** Private Procedures   Definitions ********/
procedure      Clean_Staging_Table(
                        errbuf          OUT NOCOPY VARCHAR2,
                        retcode         OUT NOCOPY VARCHAR2,
                        p_table_name    IN VARCHAR2,
			p_date_column   IN VARCHAR2,
                        p_instance_id   IN NUMBER,
                        p_from_date     IN VARCHAR2,
                        p_to_date       IN VARCHAR2,
                        p_fcst_desg     IN VARCHAR2 );


procedure      Clean_Pricing_Staging_Table(
                        errbuf          OUT NOCOPY VARCHAR2,
                        retcode         OUT NOCOPY VARCHAR2,
                        p_table_name    IN VARCHAR2,
                        p_instance_id   IN NUMBER,
                        p_price_list    IN VARCHAR2);


    C_FROM_DATE          CONSTANT  DATE := to_date('01-01-1000','DD-MM-YYYY');
    C_TO_DATE            CONSTANT  DATE := to_date('01-01-4000','DD-MM-YYYY');



/*********** Public Procedures   ***********/

procedure pull_fact_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) IS

Begin


	  retcode := 0 ;

          pull_shipment_data(
                        errbuf 	=> errbuf,
                        retcode => retcode);

          pull_booking_data(
                        errbuf 	=> errbuf,
                        retcode => retcode);

          pull_uom_conversion(
                        errbuf 	=> errbuf,
                        retcode => retcode ) ;

          pull_currency_conversion(
                        errbuf 	=> errbuf,
                        retcode => retcode ) ;

          /*pull_opportunities_data(
                        errbuf 	=> errbuf,
                        retcode => retcode ) ;

          pull_sales_forecast(
                        errbuf 	=> errbuf,
                        retcode => retcode ) ;*/

          pull_mfg_forecast(
                        errbuf 	=> errbuf,
                        retcode => retcode ) ;

          pull_pricing_data(
                        errbuf  => errbuf,
                        retcode => retcode ) ;



        exception

          when others then

                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;

End pull_fact_data ;



procedure pull_shipment_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2)  IS
x_source_table   VARCHAR2(50) := MSD_COMMON_UTILITIES.SHIPMENT_STAGING_TABLE ;
x_dest_table     VARCHAR2(50) := MSD_COMMON_UTILITIES.SHIPMENT_FACT_TABLE ;
x_delete_flag    VARCHAR2(1) := 'Y' ;
/******************************************************
  Cursor to get distinct Instance, Max Data and Min Date
******************************************************/
/* DWK. Fix Bug 2220983. Do not include instance = '0' in the cursor */
Cursor Shipment is
select 	instance,
	min(shipped_date) min_ship_date,
	max(shipped_date) max_ship_date
from msd_st_shipment_data
where instance <> '0'
group by instance ;

l_new_refresh_num  NUMBER;

Begin


	retcode :=0;

        SELECT msd.msd_last_refresh_number_s.nextval into l_new_refresh_Num from dual;


	For Shipment_Rec IN Shipment LOOP

		MSD_TRANSLATE_FACT_DATA.translate_shipment_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
			p_source_table 	    => x_source_table,
			p_dest_table        => x_dest_table,
			p_instance_id 	    => Shipment_Rec.instance,
                        p_from_date         => Shipment_Rec.min_ship_date,
                        p_to_date           => Shipment_Rec.max_ship_date,
                        p_new_refresh_num   => l_new_refresh_num,
                        p_delete_flag       => x_delete_flag);

		Clean_Staging_Table(
                        errbuf          => errbuf,
                        retcode         => retcode,
                        p_table_name    => x_source_table,
			p_date_column	=> MSD_COMMON_UTILITIES.SHIPMENT_DATE_USED,
                        p_instance_id   => Shipment_Rec.instance,
                        p_from_date     => to_char(Shipment_Rec.min_ship_date, 'dd-mon-rrrr'),
                        p_to_date       => to_char(Shipment_Rec.max_ship_date, 'dd-mon-rrrr'),
                        p_fcst_desg     => null );


	End Loop ;

        /* Delete fact rows that are not used by any demand plans */
        MSD_TRANSLATE_FACT_DATA.clean_fact_data( errbuf,
                                                 retcode,
             	                                 x_dest_table);

        commit;

        /* Added by esubrama */
        MSD_ANALYZE_TABLES.analyze_table('MSD_SHIPMENT_DATA',null);
        MSD_ANALYZE_TABLES.analyze_table('MSD_ST_SHIPMENT_DATA',null);
exception

	  when others then

		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;
                rollback;

End pull_shipment_data ;

procedure pull_booking_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) IS

x_source_table   VARCHAR2(50) := MSD_COMMON_UTILITIES.BOOKING_STAGING_TABLE ;
x_dest_table     VARCHAR2(50) := MSD_COMMON_UTILITIES.BOOKING_FACT_TABLE ;
x_delete_flag    VARCHAR2(1) := 'Y' ;
/******************************************************
  Cursor to get distinct Instance, Max Data and Min Date
******************************************************/
/* DWK. Fix Bug 2220983. Do not include instance = '0' in the cursor */
Cursor Booking is
select  instance,
        min(booked_date) min_ship_date,
        max(booked_date) max_ship_date
from msd_st_booking_data
where instance <> '0'
group by instance ;

l_new_refresh_num  NUMBER;

Begin


	retcode :=0;

        SELECT msd.msd_last_refresh_number_s.nextval into l_new_refresh_Num from dual;


        For Booking_Rec IN Booking LOOP

                MSD_TRANSLATE_FACT_DATA.translate_booking_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => Booking_Rec.instance,
                        p_from_date         => Booking_Rec.min_ship_date,
                        p_to_date           => Booking_Rec.max_ship_date,
                        p_new_refresh_num   => l_new_refresh_num,
                        p_delete_flag       => x_delete_flag);

                Clean_Staging_Table(
                        errbuf          => errbuf,
                        retcode         => retcode,
                        p_table_name    => x_source_table,
                        p_date_column   => MSD_COMMON_UTILITIES.BOOKING_DATE_USED,
                        p_instance_id   => Booking_Rec.instance,
                        p_from_date     => to_char(Booking_Rec.min_ship_date, 'dd-mon-rrrr'),
                        p_to_date       => to_char(Booking_Rec.max_ship_date, 'dd-mon-rrrr'),
                        p_fcst_desg     => null );


        End Loop ;

        /* Delete fact rows that are not used by any demand plans */
        MSD_TRANSLATE_FACT_DATA.clean_fact_data( errbuf,
                                                 retcode,
             	                                 x_dest_table);


         commit;

        /* Added by esubrama */
        MSD_ANALYZE_TABLES.analyze_table('MSD_BOOKING_DATA',null);
        MSD_ANALYZE_TABLES.analyze_table('MSD_ST_BOOKING_DATA',null);

EXCEPTION

	  when others then

		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;
                rollback;

End pull_booking_data ;



procedure pull_uom_conversion(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) IS
x_source_table   VARCHAR2(50) := MSD_COMMON_UTILITIES.UOM_STAGING_TABLE ;
x_dest_table     VARCHAR2(50) := MSD_COMMON_UTILITIES.UOM_FACT_TABLE ;

/* DWK. Fix Bug 2220983. Do not include instance = '0' in the cursor */
Cursor UOM is
select 	instance
from msd_st_uom_conversions
where instance <> '0'
group by instance;

l_new_refresh_num   NUMBER;

Begin


	retcode := 0;


        SELECT msd.msd_last_refresh_number_s.nextval into l_new_refresh_Num from dual;

	For UOM_Rec IN UOM LOOP

                MSD_TRANSLATE_FACT_DATA.translate_uom_conversion(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => UOM_Rec.instance,
                        p_new_refresh_num   => l_new_refresh_num ) ;


                Clean_Staging_Table(
                        errbuf          => errbuf,
                        retcode         => retcode,
                        p_table_name    => x_source_table,
                        p_date_column   => null,
                        p_instance_id   => UOM_Rec.instance,
                        p_from_date     => null,
                        p_to_date       => null,
                        p_fcst_desg     => null );


	End Loop;


        /* Delete fact rows that are not used by any demand plans */
        /*       Not needed. Records are physically deleted

        MSD_TRANSLATE_FACT_DATA.clean_fact_data( errbuf,
                                                 retcode,
             	                                 x_dest_table);
        */

        commit;

        /* Added by esubrama */
        MSD_ANALYZE_TABLES.analyze_table('MSD_UOM_CONVERSIONS',null);
        MSD_ANALYZE_TABLES.analyze_table('MSD_ST_UOM_CONVERSIONS',null);
exception

	  when others then

		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;
                rollback;

End pull_uom_conversion ;

procedure pull_currency_conversion(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) IS
x_source_table   VARCHAR2(50) := MSD_COMMON_UTILITIES.CURRENCY_STAGING_TABLE ;
x_dest_table     VARCHAR2(50) := MSD_COMMON_UTILITIES.CURRENCY_FACT_TABLE ;
/******************************************************
  Cursor to get Max Data and Min Date
******************************************************/

/* DWK. Fix Bug 2220983. Do not include instance = '0' in the cursor */
Cursor Currency_Conversion is
select
        min(conversion_date) min_ship_date,
        max(conversion_date) max_ship_date
from msd_st_currency_conversions
where nvl(instance, '-888') <> '0';

Begin


	retcode :=0;

        For Curr_Conv_Rec IN Currency_Conversion LOOP

             /* This condition prevent executing PULL when there is no rows in
                staging table, since min always returns a row even there is
                none in the staging table */

             IF Curr_Conv_Rec.min_ship_date is not null THEN

                MSD_TRANSLATE_FACT_DATA.translate_currency_conversion(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => null,
                        p_from_date         => Curr_Conv_Rec.min_ship_date,
                        p_to_date           => Curr_Conv_Rec.max_ship_date ) ;

                Clean_Staging_Table(
                        errbuf          => errbuf,
                        retcode         => retcode,
                        p_table_name    => x_source_table,
                        p_instance_id   => null,
                        p_date_column   => MSD_COMMON_UTILITIES.CURRENCY_DATE_USED,
                        p_from_date     => to_char(Curr_Conv_Rec.min_ship_date, 'dd-mon-rrrr'),
                        p_to_date       => to_char(Curr_Conv_Rec.max_ship_date, 'dd-mon-rrrr'),
                        p_fcst_desg     => null );
             END IF;

	End Loop ;

        commit;

        /* Added by esubrama */
        MSD_ANALYZE_TABLES.analyze_table('MSD_CURRENCY_CONVERSIONS',null);
        MSD_ANALYZE_TABLES.analyze_table('MSD_ST_CURRENCY_CONVERSIONS',null);

exception

	  when others then

		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;
                rollback;


End pull_currency_conversion ;


/* procedure pull_opportunities_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) IS
x_source_table   VARCHAR2(50) := MSD_COMMON_UTILITIES.OPPORTUNITY_STAGING_TABLE ;
x_dest_table     VARCHAR2(50) := MSD_COMMON_UTILITIES.OPPORTUNITY_FACT_TABLE ;*/
/******************************************************
  Cursor to get distinct Instance, Max Data and Min Date
******************************************************/
/* Cursor Opportunity is
select  instance,
        min(ship_date) min_ship_date,
        max(ship_date) max_ship_date
from msd_st_sales_opportunity_data
group by instance ;
Begin


	retcode :=0;

        For Opportunity_Rec IN Opportunity LOOP


                MSD_TRANSLATE_FACT_DATA.translate_opportunities_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => Opportunity_Rec.instance,
                        p_from_date         => Opportunity_Rec.min_ship_date,
                        p_to_date           => Opportunity_Rec.max_ship_date ) ;

                Clean_Staging_Table(
                        errbuf          => errbuf,
                        retcode         => retcode,
                        p_table_name    => x_source_table,
                        p_instance_id   => Opportunity_Rec.instance,
                        p_date_column   => MSD_COMMON_UTILITIES.OPPORTUNITY_DATE_USED,
                        p_from_date     => to_char(Opportunity_Rec.min_ship_date, 'dd-mon-rrrr'),
                        p_to_date       => to_char(Opportunity_Rec.max_ship_date, 'dd-mon-rrrr'),
                        p_fcst_desg     => null );


	End Loop ;

        commit;

        -- Added by esubrama
        MSD_ANALYZE_TABLES.analyze_table('MSD_SALES_OPPORTUNITY_DATA',null);
        MSD_ANALYZE_TABLES.analyze_table('MSD_ST_SALES_OPPORTUNITY_DATA',null);

exception

	  when others then

		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;
                rollback;


End pull_opportunities_data ;

*/

/*procedure pull_sales_forecast(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) IS
x_source_table   VARCHAR2(50) := MSD_COMMON_UTILITIES.SALES_FCST_STAGING_TABLE ;
x_dest_table     VARCHAR2(50) := MSD_COMMON_UTILITIES.SALES_FCST_FACT_TABLE ;*/
/******************************************************
  Cursor to get distinct Instance, Max Data and Min Date
******************************************************/
/*
Cursor Sales_Forecast is
select  instance,
        min(period_start_date) min_ship_date,
        max(period_end_date) max_ship_date
from msd_st_sales_forecast
group by instance ;
Begin


	retcode :=0;

        For Sales_Fcst_Rec IN Sales_Forecast LOOP


                MSD_TRANSLATE_FACT_DATA.translate_sales_forecast(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => Sales_Fcst_Rec.instance,
			p_fcst_desg	    => null,
                        p_from_date         => Sales_Fcst_Rec.min_ship_date,
                        p_to_date           => Sales_Fcst_Rec.max_ship_date ) ;


		Delete from msd_st_sales_forecast
		where instance = Sales_Fcst_Rec.instance
		and (   ( to_date(period_start_date,'DD-MON-RRRR')
		      	  between to_date(Sales_Fcst_Rec.min_ship_date,'DD-MON-RRRR')
		          and to_date(Sales_Fcst_Rec.max_ship_date,'DD-MON-RRRR')
		        )
		     OR ( to_date(period_end_date,'DD-MON-RRRR')
                          between to_date(Sales_Fcst_Rec.min_ship_date,'DD-MON-RRRR')
                          and to_date(Sales_Fcst_Rec.max_ship_date,'DD-MON-RRRR')
                        )
		    );

		commit ;

	End Loop ;

        -- Added by esubrama
        MSD_ANALYZE_TABLES.analyze_table('MSD_SALES_FORECAST',null);
        MSD_ANALYZE_TABLES.analyze_table('MSD_ST_SALES_FORECAST',null);

	exception

	  when others then

		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;


End pull_sales_forecast ;
*/



procedure pull_mfg_forecast(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) IS
x_source_table   VARCHAR2(50) := MSD_COMMON_UTILITIES.MFG_FCST_STAGING_TABLE ;
x_dest_table     VARCHAR2(50) := MSD_COMMON_UTILITIES.MFG_FCST_FACT_TABLE ;
x_delete_flag    VARCHAR2(1) := 'Y' ;

b_has_error         BOOLEAN := FALSE;

/***************************************************
  Cursor to get distinct Instance, Forecast Desg
****************************************************/

/* DWK. Fix Bug 2220983. Do not include instance = '0' in the cursor */
Cursor Mfg_Forecast is
select  instance,
	forecast_designator
from msd_st_mfg_forecast
where instance <> '0'
group by instance, forecast_designator
order by instance;

/* DWK  To Populate calendar */
   l_temp_instance     VARCHAR2(20) := ' ';
   b_post_process  BOOLEAN := TRUE;

l_new_refresh_num   NUMBER;

Begin


        SELECT msd.msd_last_refresh_number_s.nextval into l_new_refresh_Num from dual;

        FOR Mfg_Fcst_Rec IN Mfg_Forecast LOOP
	   DECLARE
		e_post_process_err  EXCEPTION;
	   BEGIN

		retcode :=0;

		MSD_TRANSLATE_FACT_DATA.translate_mfg_forecast(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => Mfg_Fcst_Rec.instance,
                        p_fcst_desg	    => Mfg_Fcst_Rec.forecast_designator,
                        p_new_refresh_num   => l_new_refresh_num,
                        p_delete_flag       => x_delete_flag );

		/* DWK Is posst process required */
		b_post_process := MSD_TRANSLATE_FACT_DATA.Is_Post_Process_Required(errbuf,
					retcode, Mfg_Fcst_Rec.instance, Mfg_Fcst_Rec.forecast_designator);

		IF ( b_post_process) THEN
		   IF (Mfg_Fcst_Rec.instance <> l_temp_instance) THEN
		      l_temp_instance := Mfg_Fcst_Rec.instance;
		      MSD_TRANSLATE_FACT_DATA.populate_calendar( errbuf,
                                                                 retcode,
                                                                 Mfg_Fcst_Rec.instance,
                                                                 l_new_refresh_num,
                                                                 MSD_COMMON_UTILITIES.MFG_FCST_STAGING_TABLE);
		   END IF;

  		   /* Proceed post-process */
		   MSD_TRANSLATE_FACT_DATA.mfg_post_process( errbuf,
							     retcode,
							     Mfg_Fcst_Rec.instance,
							     Mfg_Fcst_Rec.forecast_designator,
                                                             l_new_refresh_num);
	           IF (retcode = -1) THEN
		      RAISE e_post_process_err;
		   END IF;
		END IF;  /* End of b_post_process */


                Clean_Staging_Table(
                        errbuf          => errbuf,
                        retcode         => retcode,
                        p_table_name    => x_source_table,
                        p_date_column   => null,
                        p_instance_id   => Mfg_Fcst_Rec.instance,
                        p_from_date     => null,
                        p_to_date       => null,
                        p_fcst_desg     => Mfg_Fcst_Rec.forecast_designator );

                /*
                   DWK If any error exist for the given batch process,
                   then save error status in b_has_error and then proceed next batch
                */
                EXCEPTION
		   WHEN no_data_found THEN
			fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
                        errbuf := substr(SQLERRM,1,150);
			b_has_error := TRUE;
                        raise;
		   WHEN e_post_process_err THEN
			fnd_file.put_line(fnd_file.log, 'Errors in mfg_post_process : Designator '||
						         Mfg_Fcst_Rec.forecast_designator);
			fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
			errbuf := 'Error occured in mfg_post_process';
			b_has_error := TRUE;
                        l_temp_instance := ' ';
                        raise;
		   WHEN others THEN
			fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
			errbuf := substr(SQLERRM,1,150);
			b_has_error := TRUE;
                        raise;
	   END;
	END LOOP;



        /* Delete fact rows that are not used by any demand plans */
        MSD_TRANSLATE_FACT_DATA.clean_fact_data( errbuf,
                                                 retcode,
             	                                 x_dest_table);

	/* DWK Delete existing calendar after post process */
	DELETE msd_st_time WHERE instance = '-999';

	/* DWK  Put recode code back to error status when error exists within loop */
        IF (b_has_error) THEN
          retcode := -1;
        END IF;


	COMMIT;

        /* Added by esubrama */
        MSD_ANALYZE_TABLES.analyze_table('MSD_MFG_FORECAST',null);
        MSD_ANALYZE_TABLES.analyze_table('MSD_ST_MFG_FORECAST',null);

        EXCEPTION
	  when others then
		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;
                rollback;

End pull_mfg_forecast ;


procedure pull_pricing_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2)  IS
x_source_table   VARCHAR2(50) := MSD_COMMON_UTILITIES.PRICING_STAGING_TABLE ;
x_dest_table     VARCHAR2(50) := MSD_COMMON_UTILITIES.PRICING_FACT_TABLE ;

/******************************************************
  Cursor to get distinct Instance
******************************************************/
/* DWK. Fix Bug 2220983. Do not include instance = '0' in the cursor */
Cursor Pricing is
select  distinct instance, price_list_name
from msd_st_price_list
where nvl(instance, '888') <> '0' and price_list_name is not null;


l_new_refresh_num   NUMBER;
Begin


        retcode :=0;

        SELECT msd.msd_last_refresh_number_s.nextval into l_new_refresh_Num from dual;

        For Pricing_Rec IN Pricing LOOP

                MSD_TRANSLATE_FACT_DATA.translate_pricing_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => Pricing_Rec.instance,
                        p_price_list        => Pricing_Rec.price_list_name,
                        p_new_refresh_num   => l_new_refresh_num) ;

                Clean_Pricing_Staging_Table(
                        errbuf          => errbuf,
                        retcode         => retcode,
                        p_table_name    => x_source_table,
                        p_instance_id   => Pricing_Rec.instance,
                        p_price_list   =>  Pricing_Rec.price_list_name);

        End Loop ;


        /* Delete fact rows that are not used by any demand plans */
        MSD_TRANSLATE_FACT_DATA.clean_fact_data( errbuf,
                                                 retcode,
             	                                 x_dest_table);


        commit;

        /* Added by esubrama */
        MSD_ANALYZE_TABLES.analyze_table('MSD_PRICE_LIST',null);
        MSD_ANALYZE_TABLES.analyze_table('MSD_ST_PRICE_LIST',null);

exception
          when others then

                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;
                rollback;

End pull_pricing_data ;


procedure pull_events(
                        errbuf                  OUT NOCOPY VARCHAR2,
                        retcode                 OUT NOCOPY VARCHAR2) IS

BEGIN
null;
End pull_events;




/**************** Private Procedures  ***************/

procedure      Clean_Staging_Table(
                        errbuf          OUT NOCOPY VARCHAR2,
                        retcode         OUT NOCOPY VARCHAR2,
                        p_table_name    IN VARCHAR2,
                        p_date_column   IN VARCHAR2,
                        p_instance_id   IN NUMBER,
                        p_from_date     IN VARCHAR2,
                        p_to_date       IN VARCHAR2,
                        p_fcst_desg     IN VARCHAR2 ) IS
x_sql_statement VARCHAR2(2000);

Begin
 	/* DWK. Do not delete any rows with instance = '0'
            Attention.  Currency staging won't have any instance id */
         x_sql_statement := 'DELETE FROM ' || p_table_name ||
                            ' where nvl(instance,''-999'') <> ''0'' ' ||
                            ' and nvl(instance,''-999'') = ' ||
                            ' nvl(:p_instance_id, nvl(instance,''-999'')) ';

          IF p_date_column is not NULL THEN
             x_sql_statement := x_sql_statement ||' and ' || p_date_column ||
 	             ' between to_date(:p_from_date, ''DD-MON-RRRR'') AND ' ||
                      ' to_date(:p_to_date, ''DD-MON-RRRR'') ';

             IF p_fcst_desg is not null THEN
                x_sql_statement := x_sql_statement ||
                         ' and forecast_designator = :fcst_desg ';
                EXECUTE IMMEDIATE x_sql_statement
                USING p_instance_id,  nvl(p_from_date, to_char(C_FROM_DATE, 'DD-MON-RRRR')),
                      nvl(p_to_date,to_char(C_TO_DATE, 'DD-MON-RRRR')), p_fcst_desg;
             ELSE
                EXECUTE IMMEDIATE x_sql_statement
                USING p_instance_id, nvl(p_from_date,to_char(C_FROM_DATE, 'DD-MON-RRRR')),
                      nvl(p_to_date,to_char(C_TO_DATE, 'DD-MON-RRRR'));
             END IF;

          ELSE  /* If date column is null */

             IF p_fcst_desg is not null THEN
                x_sql_statement := x_sql_statement ||
                         ' and forecast_designator = :p_fcst_desg ';
                EXECUTE IMMEDIATE x_sql_statement USING p_instance_id, p_fcst_desg;
             ELSE
                EXECUTE IMMEDIATE x_sql_statement USING p_instance_id;
             END IF;
          END IF;

--	insert into msd_test values(x_sql_statement) ;
--      dbms_output.put_line(v_sql_stmt);


exception
          when others then

                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;
                raise;

End Clean_Staging_Table ;


procedure      Clean_Pricing_Staging_Table(
                        errbuf          OUT NOCOPY VARCHAR2,
                        retcode         OUT NOCOPY VARCHAR2,
                        p_table_name    IN VARCHAR2,
                        p_instance_id   IN NUMBER,
                        p_price_list    IN VARCHAR2) IS
x_sql_statement VARCHAR2(2000);
Begin

 /* Using nvl in price list will degrade the performance, no index
    However, dynamic sql complaince need to use nvl in this case */

         x_sql_statement := ' DELETE FROM ' || p_table_name ||
                            ' where instance = nvl(:p_instance_id, instance) '||
                            ' and price_list_name = nvl(:p_price_list, price_list_name)';
         EXECUTE IMMEDIATE x_sql_statement USING p_instance_id, p_price_list;

exception
          when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;
                raise;

End Clean_Pricing_Staging_Table ;


END MSD_PULL_FACT_DATA;

/
