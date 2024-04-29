--------------------------------------------------------
--  DDL for Package Body MSD_COLLECT_FACT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_COLLECT_FACT_DATA" AS
/* $Header: msdcfctb.pls 120.5 2006/02/28 21:38:32 sjagathe noship $ */

   /* Bug# 4747555 */
   C_ALL                 CONSTANT NUMBER := 1;
   C_INCLUDE             CONSTANT NUMBER := 2;
   C_EXCLUDE             CONSTANT NUMBER := 3;

   /* Bug# 4747555 */
   TYPE ORDER_TYPE_TABLE_TYPE    IS TABLE OF VARCHAR2(100);
   TYPE ORDER_TYPE_ID_TABLE_TYPE IS TABLE OF NUMBER;


/* Bug# 4747555
 * This function validates the order types given
 * by the user to the following procedures:
 * 1) collect_shipment_data
 * 2) collect_booking_data
 * This function returns the number of invalid
 * order types found in the user input.
 */
FUNCTION validate_input_parameters (
                        p_dblink                  IN VARCHAR2,
			p_collect_all_order_types IN NUMBER,
			p_include_order_types     IN VARCHAR2,
			p_exclude_order_types     IN VARCHAR2,
			p_order_type_flag         OUT NOCOPY NUMBER,
			p_order_type_ids          OUT NOCOPY VARCHAR2,
			p_retcode                 OUT NOCOPY VARCHAR2)
RETURN NUMBER;

/* This is the wrapper routine for collecting all the fact information
*/
procedure collect_fact_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_from_date         IN  VARCHAR2,
                        p_to_date           IN  VARCHAR2,
                        p_fcst_desg         IN  VARCHAR2,
                        p_price_list        IN  VARCHAR2 ) IS

Begin


	  retcode := 0 ;

         /*----------------------------------------------------------*/
          collect_shipment_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id,
                        p_from_date         => p_from_date,
                        p_to_date           => p_to_date,
                        p_collect_ISO       => SYS_NO ) ;    /* Bug# 4615390 ISO */

          if retcode <> 0 then
             errbuf :=  ' Error In Shipment Data Collection';
             return;
          end if ;
         /*----------------------------------------------------------*/
          collect_booking_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id,
                        p_from_date         => p_from_date,
                        p_to_date           => p_to_date,
                        p_collect_ISO       => SYS_NO ) ;    /* Bug# 4615390 ISO */

          if retcode <> 0 then
             errbuf :=  ' Error In Booking Data Collection';
             return;
          end if ;

         /*----------------------------------------------------------*/
          collect_uom_conversion(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id) ;

          if retcode <> 0 then
             errbuf :=  ' Error In UOM Conversions Data Collection';
             return;
          end if ;

         /*----------------------------------------------------------*/
          collect_currency_conversion(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id,
                        p_from_date         => p_from_date,
                        p_to_date           => p_to_date ) ;

          if retcode <> 0 then
             errbuf :=  ' Error In Currency Conversions Data Collection';
             return;
          end if ;
         /*----------------------------------------------------------*/


          /*collect_opportunities_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id,
                        p_from_date         => p_from_date,
                        p_to_date           => p_to_date ) ;

          collect_sales_forecast(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id,
                        p_from_date         => p_from_date,
                        p_to_date           => p_to_date ) ;*/

         /*----------------------------------------------------------*/
          collect_mfg_forecast(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id,
                        p_fcst_desg         => p_fcst_desg ) ;

          if retcode <> 0 then
             errbuf :=  ' Error In MFG Forecast Data Collection';
             return;
          end if ;

         /*----------------------------------------------------------*/
          collect_pricing_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id,
                        p_price_list        => p_price_list) ;

          if retcode <> 0 then
             errbuf :=  ' Error In Pricing Data Collection';
             return;
          end if ;


exception

          when others then

		errbuf := substr(SQLERRM,1,150);
                fnd_file.put_line(fnd_file.log, 'Errors in collect all fact');
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		retcode := -1 ;


End  collect_fact_data ;



procedure collect_shipment_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_instance_id 	    IN  NUMBER,
                        p_from_date         IN  VARCHAR2,
                        p_to_date           IN  VARCHAR2,
                        p_collect_ISO       IN  NUMBER DEFAULT SYS_NO,             /* Bug# 4615390 ISO, Bug# 4865396 */
                        p_collect_all_order_types IN NUMBER   DEFAULT SYS_YES,     /* Bug# 4747555*/
                        p_include_order_types     IN VARCHAR2 DEFAULT NULL,
                        p_exclude_order_types     IN VARCHAR2 DEFAULT NULL) IS

x_instance_id    varchar2(40);
x_dblink         varchar2(128);
x_retcode	number;
x_direct_load_profile  boolean;
x_source_table	VARCHAR2(50) ;
x_dest_table	varchar2(50) ;
x_sql_stmt       varchar2(4000);
x_from_date     DATE;
x_to_date       DATE;

/* OPM Comment By Rajesh Patangya   */
x_delete_flag   varchar2(1) := 'Y' ;
o_source_table  VARCHAR2(50) ;
o_dblink         varchar2(128);
o_icode          varchar2(128);
o_retcode        number;
o_instance_type  number;
o_dgmt           number;
o_apps_ver       number;

l_new_refresh_num  NUMBER;

/* Bug# 4747555 */
l_order_type_ids       VARCHAR2(2000);
l_order_type_flag NUMBER;
l_invalid_count   NUMBER := 0;

Begin


	/**************************************************
	-	1. Get the instance id from MSC_APP_INSTANCE
	-	2. Get the Profile Value for MSD_ONE_STEP_COLLECTION
	-	   to identify whether we need to insert the
	-	   data into the staging tables or the
	-	   fact tables.
	-	3. Check for the Data Duplication, we should
	-	   use the shipped_date for this fact data.
	-	4. Insert the Data accordingly into the
	-	   Staging or the Fact table based on the
	-	   MSD_SR_SHIPMENT_DATA_V.
	-	5. Commit
	****************************************************/

	retcode :=0;

	msd_common_utilities.get_db_link(p_instance_id, x_dblink, x_retcode);
	if (x_retcode = -1) then
		retcode :=-1;
		errbuf := 'Error while getting db_link';
		return;
	end if;

        /* Check and push setup parameters if it is not done so previously */
        MSD_PUSH_SETUP_DATA.chk_push_setup(   errbuf,
                                              retcode,
                                              p_instance_id);
        IF (nvl(retcode, 0) <> 0) THEN
           return;
        END IF;

	/* Bug# 4747555
	 * Validate the input parameters
	 * given by the user
	 */
        l_invalid_count := validate_input_parameters (
					x_dblink,
	        			p_collect_all_order_types,
                			p_include_order_types,
                			p_exclude_order_types,
                			l_order_type_flag,
                			l_order_type_ids,
                			x_retcode);

	if (x_retcode = -1) then
		retcode :=-1;
		return;
	end if;

        /* OPM Comment By Rajesh Patangya   */
        msd_common_utilities.get_inst_info(p_instance_id, o_dblink, o_icode,
                o_apps_ver, o_dgmt, o_instance_type, o_retcode)  ;
        if (o_retcode = -1) then
                retcode :=-1;
                errbuf := 'Error while getting instance_info';
                return;
        end if;


	x_source_table := MSD_COMMON_UTILITIES.SHIPMENT_SOURCE_TABLE || x_dblink ;

        /* OPM Comment By Rajesh Patangya   */
	o_source_table := MSD_COMMON_UTILITIES.OPM_SHIPMENT_SOURCE_TABLE || x_dblink ;

        x_dest_table := MSD_COMMON_UTILITIES.SHIPMENT_STAGING_TABLE ;

        x_from_date := FND_DATE.canonical_to_date(p_from_date);
        x_to_date := FND_DATE.canonical_to_date(p_to_date);


      /* OPM Comment By Rajesh Patangya   */
      /* Bug# 4620927 */
--       if o_instance_type <> 2 then
      /* 11i instance where instance type in not 'PROCESS' OR R12 Instance of any type */
       if o_instance_type <> 2 OR o_apps_ver = 4 then
                MSD_TRANSLATE_FACT_DATA.translate_shipment_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => p_instance_id,
                        p_from_date         => x_from_date,
                        p_to_date           => x_to_date,
                        p_new_refresh_num   => l_new_refresh_num,
                        p_delete_flag       => x_delete_flag,
                        p_collect_ISO       => p_collect_ISO,             /* Bug# 4615390 ISO */
                        p_order_type_flag   => l_order_type_flag,         /* Bug# 4747555*/
                        p_order_type_ids    => l_order_type_ids);

                if retcode <> 0 then
                errbuf :=  ' In MSD Call for shipment';
                return;
                end if ;

       end if ;

      /* OPM Comment By Rajesh Patangya   */
       if (o_instance_type in (2,4) AND o_apps_ver = 3) then

        	if o_instance_type = 4 then
                x_delete_flag   := 'N' ;
        	end if ;

                MSD_TRANSLATE_FACT_DATA.translate_shipment_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => o_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => p_instance_id,
                        p_from_date         => x_from_date,
                        p_to_date           => x_to_date,
                        p_new_refresh_num   => l_new_refresh_num,
                        p_delete_flag       => x_delete_flag,
                        p_collect_ISO       => p_collect_ISO);    /* Bug# 4615390 ISO */

                if retcode <> 0 then
                errbuf :=  ' In OPM Call for shipment';
                return;
                end if ;
       end if ;



       x_direct_load_profile := (fnd_profile.value('MSD_ONE_STEP_COLLECTION')='Y');

       IF (x_direct_load_profile) THEN
          MSD_PULL_FACT_DATA.pull_shipment_data( errbuf,
                                                 retcode);

          /* DWK.  Check return code from mfg_post_process */
          IF  nvl(retcode, 0) <> 0  THEN
            fnd_file.put_line(fnd_file.log, 'Errors in pull_shipment_data');
            fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
            return;
          END IF;
       END IF;

       commit;

       /* Added by esubrama */
       MSD_ANALYZE_TABLES.analyze_table(x_dest_table,null);

       /* Bug# 4747555- Give warning if invalid order types were found */
       IF l_invalid_count > 0 AND retcode = 0 THEN
          retcode := 1;
       END IF;

exception

	  when others then

		errbuf := substr(SQLERRM,1,150);
                fnd_file.put_line(fnd_file.log, 'Errors in collect_shipment_data');
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		retcode := -1 ;
                rollback;

End collect_shipment_data ;

procedure collect_booking_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_instance_id 	    IN  NUMBER,
                        p_from_date         IN  VARCHAR2,
                        p_to_date           IN  VARCHAR2,
                        p_collect_ISO       IN  NUMBER DEFAULT SYS_NO,               /* Bug# 4615390 ISO, Bug# 4865396 */
                        p_collect_all_order_types IN NUMBER   DEFAULT SYS_YES,       /* Bug# 4747555*/
                        p_include_order_types     IN VARCHAR2 DEFAULT NULL,
                        p_exclude_order_types     IN VARCHAR2 DEFAULT NULL) IS

x_instance_id    varchar2(40);
x_dblink         varchar2(128);
x_retcode	number;
x_direct_load_profile  boolean;
x_source_table  VARCHAR2(50) ;
x_dest_table    varchar2(50) ;
x_from_date     DATE;
x_to_date  	DATE;

/* OPM Comment By Rajesh Patangya   */
x_delete_flag   varchar2(1) := 'Y' ;
o_source_table  VARCHAR2(50) ;
o_dblink         varchar2(128);
o_icode          varchar2(128);
o_retcode        number;
o_instance_type  number;
o_dgmt           number;
o_apps_ver       number;

l_new_refresh_num  NUMBER;

/* Bug# 4747555 */
l_order_type_ids       VARCHAR2(2000);
l_order_type_flag NUMBER;
l_invalid_count   NUMBER := 0;

Begin


	/**************************************************
	-	1. Get the instance id from MSC_APP_INSTANCE
	-	2. Get the Profile Value for MSD_ONE_STEP_COLLECTION
	-	   to identify whether we need to insert the
	-	   data into the staging tables or the
	-	   fact tables.
	-	3. Check for the Data Duplication, we should
	-	   use the shipped_date for this fact data.
	-	4. Insert the Data accordingly into the
	-	   Staging or the Fact table based on the
	-	   MSD_SR_BOOKING_DATA_V.
	-	5. Commit
	****************************************************/

	retcode :=0;

        msd_common_utilities.get_db_link(p_instance_id, x_dblink, x_retcode);
        if (x_retcode = -1) then
                retcode :=-1;
                errbuf := 'Error while getting db_link';
                return;
        end if;

	/* Bug# 4747555
	 * Validate the input parameters
	 * given by the user
	 */
        l_invalid_count := validate_input_parameters (
					x_dblink,
	        			p_collect_all_order_types,
                			p_include_order_types,
                			p_exclude_order_types,
                			l_order_type_flag,
                			l_order_type_ids,
                			x_retcode);

	if (x_retcode = -1) then
		retcode :=-1;
		return;
	end if;

        /* Check and push setup parameters if it is not done so previously */
        MSD_PUSH_SETUP_DATA.chk_push_setup(   errbuf,
                                              retcode,
                                              p_instance_id);
        IF (nvl(retcode, 0) <> 0) THEN
           return;
        END IF;

        /* OPM Comment By Rajesh Patangya   */
        msd_common_utilities.get_inst_info(p_instance_id, o_dblink, o_icode,
                o_apps_ver, o_dgmt, o_instance_type, o_retcode)  ;
        if (o_retcode = -1) then
                retcode :=-1;
                errbuf := 'Error while getting instance_info';
                return;
        end if;


        x_source_table := MSD_COMMON_UTILITIES.BOOKING_SOURCE_TABLE || x_dblink ;
        /* OPM Comment By Rajesh Patangya   */
        o_source_table := MSD_COMMON_UTILITIES.OPM_BOOKING_SOURCE_TABLE || x_dblink ;

        x_dest_table := MSD_COMMON_UTILITIES.BOOKING_STAGING_TABLE ;

	x_from_date := FND_DATE.canonical_to_date(p_from_date);
	x_to_date := FND_DATE.canonical_to_date(p_to_date);


      /* OPM Comment By Rajesh Patangya   */
      /* Bug# 4620927 */
--       if o_instance_type <> 2 then
      /* 11i instance where instance type in not 'PROCESS' OR R12 Instance of any type */
       if o_instance_type <> 2 OR o_apps_ver = 4 then
                MSD_TRANSLATE_FACT_DATA.translate_booking_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => p_instance_id,
                        p_from_date         => x_from_date,
                        p_to_date           => x_to_date,
                        p_new_refresh_num   => l_new_refresh_num,
                        p_delete_flag       => x_delete_flag,
                        p_collect_ISO       => p_collect_ISO,              /* Bug# 4615390 ISO */
                        p_order_type_flag   => l_order_type_flag,          /* Bug# 4747555*/
                        p_order_type_ids    => l_order_type_ids);

                if nvl(retcode,0) <> 0 then
                   errbuf :=  ' In MSD Call for Booking';
                   return;
                end if ;
       end if ;


      /* OPM Comment By Rajesh Patangya   */
       if (o_instance_type in (2,4) AND o_apps_ver = 3) then

        	if o_instance_type = 4 then
                   x_delete_flag   := 'N' ;
        	end if ;

                MSD_TRANSLATE_FACT_DATA.translate_booking_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => o_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => p_instance_id,
                        p_from_date         => x_from_date,
                        p_to_date           => x_to_date,
                        p_new_refresh_num   => l_new_refresh_num,
                        p_delete_flag       => x_delete_flag,
                        p_collect_ISO       => p_collect_ISO) ;    /* Bug# 4615390 ISO */

                if nvl(retcode, 0) <> 0 then
                   errbuf :=  ' In OPM Call for Booking ';
                   return;
                end if ;
       end if ;

       x_direct_load_profile := (fnd_profile.value('MSD_ONE_STEP_COLLECTION')='Y');

       IF (x_direct_load_profile) THEN
          MSD_PULL_FACT_DATA.pull_booking_data( errbuf,
                                                retcode);

          /* DWK.  Check return code from mfg_post_process */
          IF  nvl(retcode, 0) <> 0  THEN
            fnd_file.put_line(fnd_file.log, 'Errors in pull_booking_data');
            fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
            return;
          END IF;
       END IF;

       commit;

       /* Added by esubrama */
       MSD_ANALYZE_TABLES.analyze_table(x_dest_table,null);

       /* Bug# 4747555- Give warning if invalid order types were found */
       IF l_invalid_count > 0 AND retcode = 0 THEN
          retcode := 1;
       END IF;

exception

	  when others then

		errbuf := substr(SQLERRM,1,150);
                fnd_file.put_line(fnd_file.log, 'Errors in collect_booking_data');
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		retcode := -1 ;
                rollback;


End collect_booking_data ;



procedure collect_uom_conversion(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER) IS
x_instance_id    varchar2(40);
x_dblink         varchar2(128);
x_retcode	number;
x_direct_load_profile  boolean;
x_source_table  VARCHAR2(50) ;
x_dest_table    varchar2(50) ;

Begin


        /**************************************************
        -       1. Get the instance id from MSC_APP_INSTANCE
        -       2. Get the Profile Value for MSD_ONE_STEP_COLLECTION
        -          to identify whether we need to insert the
        -          data into the staging tables or the
        -          fact tables.
        -       3. Do a complete refresh for this instance,
        -	   hence delete all the underlying values.
        -       4. Insert the Data accordingly into the
        -          Staging or the Fact table based on the
        -          MSD_SR_UOM_CONVERSION_V
        -       5. Commit
        ****************************************************/

	retcode :=0;

        /* Check and push setup parameters if it is not done so previously */
        MSD_PUSH_SETUP_DATA.chk_push_setup(   errbuf,
                                              retcode,
                                              p_instance_id);
        IF (nvl(retcode, 0) <> 0) THEN
           return;
        END IF;

        msd_common_utilities.get_db_link(p_instance_id, x_dblink, x_retcode);
        if (x_retcode = -1) then
                retcode :=-1;
                errbuf := 'Error while getting db_link';
                return;
        end if;

        x_source_table := MSD_COMMON_UTILITIES.UOM_SOURCE_TABLE || x_dblink ;

        x_direct_load_profile := (fnd_profile.value('MSD_ONE_STEP_COLLECTION')='Y');

        x_dest_table := MSD_COMMON_UTILITIES.UOM_STAGING_TABLE ;


        MSD_TRANSLATE_FACT_DATA.translate_uom_conversion(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => p_instance_id,
                        p_new_refresh_num   => NULL) ;

        if nvl(retcode, 0) <> 0 then
                   errbuf :=  ' In collect uom conversion/translate_uom_conversion';
                   return;
        end if ;


       x_direct_load_profile := (fnd_profile.value('MSD_ONE_STEP_COLLECTION')='Y');

       IF (x_direct_load_profile) THEN
          MSD_PULL_FACT_DATA.pull_uom_conversion( errbuf,
                                                  retcode);

          /* DWK.  Check return code from mfg_post_process */
          IF  nvl(retcode, 0) <> 0  THEN
            fnd_file.put_line(fnd_file.log, 'Errors in pull_uom_conversion');
            fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
            return;
          END IF;
       END IF;


        commit;

        /* Added by esubrama */
        MSD_ANALYZE_TABLES.analyze_table(x_dest_table,null);

exception

	  when others then

		errbuf := substr(SQLERRM,1,150);
                fnd_file.put_line(fnd_file.log, 'Errors in collect_uom_conversion');
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		retcode := -1 ;
                rollback;



End collect_uom_conversion ;

procedure collect_currency_conversion(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
			p_from_date         IN  VARCHAR2,
                        p_to_date           IN  VARCHAR2) IS
x_instance_id    varchar2(40);
x_dblink         varchar2(128);
x_retcode       number;
x_direct_load_profile  boolean;
x_source_table  VARCHAR2(150) ;
x_dest_table    varchar2(150) ;
x_from_date     DATE;
x_to_date       DATE;

Begin


        /**************************************************
        -       1. Get the instance id from MSC_APP_INSTANCE
        -       2. Get the Profile Value for MSD_ONE_STEP_COLLECTION
        -          to identify whether we need to insert the
        -          data into the staging tables or the
        -          fact tables.
        -       3. Do a complete refresh for this instance,
        -          hence delete all the underlying values.
        -       4. Insert the Data accordingly into the
        -          Staging or the Fact table based on the
        -          MSD_SR_CURRENCY_CONVERSION_V
        -       5. Commit
        ****************************************************/

	retcode :=0;


        /* Check and push setup parameters if it is not done so previously */
        MSD_PUSH_SETUP_DATA.chk_push_setup(   errbuf,
                                              retcode,
                                              p_instance_id);
        IF (nvl(retcode, 0) <> 0) THEN
           return;
        END IF;


        msd_common_utilities.get_db_link(p_instance_id, x_dblink, x_retcode);
        if (x_retcode = -1) then
                retcode :=-1;
                errbuf := 'Error while getting db_link';
                return;
        end if;

        x_source_table := MSD_COMMON_UTILITIES.CURRENCY_SOURCE_TABLE || x_dblink ;

        x_dest_table := MSD_COMMON_UTILITIES.CURRENCY_STAGING_TABLE  ;


        x_from_date := FND_DATE.canonical_to_date(p_from_date);
        x_to_date := FND_DATE.canonical_to_date(p_to_date);


        MSD_TRANSLATE_FACT_DATA.translate_currency_conversion(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => p_instance_id,
                        p_from_date         => x_from_date,
                        p_to_date           => x_to_date) ;

        if nvl(retcode, 0) <> 0 then
                   errbuf :=  ' In collect currency conversion/translate_currency_conversion';
                   return;
        end if ;


        x_direct_load_profile := (fnd_profile.value('MSD_ONE_STEP_COLLECTION')='Y');

        IF (x_direct_load_profile) THEN
           MSD_PULL_FACT_DATA.pull_currency_conversion( errbuf,
                                                        retcode);

           /* DWK.  Check return code from mfg_post_process */
           IF  nvl(retcode, 0) <> 0  THEN
             fnd_file.put_line(fnd_file.log, 'Errors in pull_currency_conversion');
             fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
             return;
           END IF;
        END IF;


        commit;

        /* Added by esubrama */
        MSD_ANALYZE_TABLES.analyze_table(x_dest_table,null);

exception

	  when others then


		errbuf := substr(SQLERRM,1,150);
                fnd_file.put_line(fnd_file.log, 'Errors in collect_currency_conversion');
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		retcode := -1 ;
                rollback;

End collect_currency_conversion ;


procedure collect_mfg_forecast(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_fcst_desg         IN  VARCHAR2) IS
x_instance_id    varchar2(40);
x_dblink         varchar2(128);
x_retcode	number;
x_direct_load_profile  boolean;
x_source_table  VARCHAR2(50) ;
x_dest_table    varchar2(50) ;

/* OPM Comment By Rajesh Patangya   */
x_delete_flag   varchar2(1) := 'Y' ;
o_source_table  VARCHAR2(50) ;
o_dblink         varchar2(128);
o_icode          varchar2(128);
o_retcode        number;
o_instance_type  number;
o_dgmt           number;
o_apps_ver       number;

/* DWK For post process */
b_post_process  BOOLEAN := TRUE;

l_new_refresh_num   NUMBER;

Begin


        /**************************************************
        -       1. Get the instance id from MSC_APP_INSTANCE
        -       2. Get the Profile Value for MSD_ONE_STEP_COLLECTION
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


        /* Check and push setup parameters if it is not done so previously */
        MSD_PUSH_SETUP_DATA.chk_push_setup(   errbuf,
                                              retcode,
                                              p_instance_id);
        IF (nvl(retcode, 0) <> 0) THEN
           return;
        END IF;




       msd_common_utilities.get_db_link(p_instance_id, x_dblink, x_retcode);
       if (x_retcode = -1) then
                retcode :=-1;
                errbuf := 'Error while getting db_link';
                return;
       end if;

       /* OPM Comment By Rajesh Patangya   */
       msd_common_utilities.get_inst_info(p_instance_id, o_dblink, o_icode,
                o_apps_ver, o_dgmt, o_instance_type, o_retcode)  ;
       if (o_retcode = -1) then
                retcode :=-1;
                errbuf := 'Error while getting instance_info';
                return;
       end if;

       x_source_table := MSD_COMMON_UTILITIES.MFG_FCST_SOURCE_TABLE || x_dblink ;
       /* OPM Comment By Rajesh Patangya   */
       o_source_table := MSD_COMMON_UTILITIES.OPM_MFG_FCST_SOURCE_TABLE || x_dblink ;

       x_dest_table := MSD_COMMON_UTILITIES.MFG_FCST_STAGING_TABLE ;

       x_direct_load_profile := (fnd_profile.value('MSD_ONE_STEP_COLLECTION')='Y');

      /* OPM Comment By Rajesh Patangya   */
      /* Bug# 4620927 */
--      IF o_instance_type <> 2 then
      /* 11i instance where instance type in not 'PROCESS' OR R12 Instance of any type */
       IF o_instance_type <> 2 OR o_apps_ver = 4 then
                MSD_TRANSLATE_FACT_DATA.translate_mfg_forecast(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => p_instance_id,
                        p_fcst_desg         => p_fcst_desg,
                        p_new_refresh_num   => l_new_refresh_num,
                        p_delete_flag       => x_delete_flag );

                if nvl(retcode, 0) <> 0 then
                   errbuf :=  ' In MSD Call for shipment';
                   return;
                end if ;
      end if ;

      /* OPM Comment By Rajesh Patangya   */
      IF  (o_instance_type in (2,4) and o_apps_ver = 3) THEN

         IF o_instance_type = 4 THEN
            x_delete_flag   := 'N' ;
         END IF;

         MSD_TRANSLATE_FACT_DATA.translate_mfg_forecast(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => o_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => p_instance_id,
                        p_fcst_desg         => p_fcst_desg,
                        p_new_refresh_num   => l_new_refresh_num,
                        p_delete_flag       => x_delete_flag );

         IF nvl(retcode, 0) <> 0 then
            errbuf :=  ' In OPM Call for Manufacturing forecast ';
            return;
         END IF;
       END IF;


        x_direct_load_profile := (fnd_profile.value('MSD_ONE_STEP_COLLECTION')='Y');

       /* If 1 step colloction then proceed with PULL */
       IF (x_direct_load_profile) THEN
          MSD_PULL_FACT_DATA.pull_mfg_forecast( errbuf,
                                                retcode);
          /* DWK.  Check return code from mfg_post_process */
          IF (retcode <> 0) THEN
            fnd_file.put_line(fnd_file.log, 'Errors in pull_mfg_forecast');
            fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
            return;
          END IF;
       END IF;

       COMMIT;

       /* Added by esubrama */
       MSD_ANALYZE_TABLES.analyze_table(x_dest_table,null);

EXCEPTION
	  WHEN no_data_found THEN
	                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
                        errbuf := substr(SQLERRM,1,150);
                        retcode := -1;
                        rollback;
	  when others then
		fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;
                rollback;

End collect_mfg_forecast ;


procedure collect_pricing_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_price_list        IN  VARCHAR2) IS

x_instance_id    varchar2(40);
x_dblink         varchar2(128);
x_retcode       number;
x_direct_load_profile  boolean;
x_source_table  VARCHAR2(50) ;
x_dest_table    varchar2(50) ;
x_sql_stmt       varchar2(4000);
Begin


        /**************************************************
        -       1. Get the instance id from MSC_APP_INSTANCE
        -       2. Get the Profile Value for MSD_ONE_STEP_COLLECTION
        -          to identify whether we need to insert the
        -          data into the staging tables or the
        -          fact tables.
        -       3. Check for the Data Duplication, we should
        -          use the shipped_date for this fact data.
        -       4. Insert the Data accordingly into the
        -          Staging or the Fact table based on the
        -          MSD_SR_PRICE_LIST_V.
        -       5. Commit
        ****************************************************/

        retcode :=0;

        /* Check and push setup parameters if it is not done so previously */
        MSD_PUSH_SETUP_DATA.chk_push_setup(   errbuf,
                                              retcode,
                                              p_instance_id);
        IF (nvl(retcode, 0) <> 0) THEN
           return;
        END IF;


        msd_common_utilities.get_db_link(p_instance_id, x_dblink, x_retcode);
        if (x_retcode = -1) then
                retcode :=-1;
                errbuf := 'Error while getting db_link';
                return;
        end if;

        x_source_table := MSD_COMMON_UTILITIES.PRICING_SOURCE_TABLE || x_dblink ;

        x_dest_table := MSD_COMMON_UTILITIES.PRICING_STAGING_TABLE ;


       MSD_TRANSLATE_FACT_DATA.translate_pricing_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_source_table      => x_source_table,
                        p_dest_table        => x_dest_table,
                        p_instance_id       => p_instance_id,
                        p_price_list        => p_price_list,
                        p_new_refresh_num   => NULL) ;


       /* Price List post process to eliminate dublicate price list for the same item, same
          time period */

       msd_price_list_pp.price_list_post_process( errbuf            => errbuf,
                                                  retcode           => retcode,
                                                  p_instance_id     => p_instance_id,
                                                  p_price_list      => p_price_list );



       x_direct_load_profile := (fnd_profile.value('MSD_ONE_STEP_COLLECTION')='Y');

       /* If 1 step colloction then proceed with PULL */
       IF (x_direct_load_profile) THEN
          MSD_PULL_FACT_DATA.pull_pricing_data( errbuf,
                                                retcode);
          /* DWK.  Check return code from mfg_post_process */
          IF (retcode <> 0) THEN
            fnd_file.put_line(fnd_file.log, 'Errors in pull_pricing_data');
            fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
            return;
          END IF;
       END IF;

       IF nvl(retcode, 0) <> 0 then
          errbuf :=  ' In Collect Pricing Data/translate_pricing_data';
          return;
       END IF;

       commit;

       /* Added by esubrama */
       MSD_ANALYZE_TABLES.analyze_table(x_dest_table,null);

exception

          when others then

		errbuf := substr(SQLERRM,1,150);
                fnd_file.put_line(fnd_file.log, 'Errors in collect pricing data');
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		retcode := -1 ;
                rollback;

End collect_pricing_data ;


procedure purge_facts(
                      errbuf              OUT NOCOPY VARCHAR2,
                      retcode             OUT NOCOPY VARCHAR2,
                      p_instance_id       IN  NUMBER) IS


begin
  retcode := 0;

  EXECUTE IMMEDIATE get_purge_sql(MSD_COMMON_UTILITIES.SHIPMENT_FACT_TABLE, p_instance_id);
  EXECUTE IMMEDIATE get_purge_sql(MSD_COMMON_UTILITIES.BOOKING_FACT_TABLE, p_instance_id);
  EXECUTE IMMEDIATE get_purge_sql(MSD_COMMON_UTILITIES.SALES_FCST_FACT_TABLE, p_instance_id);
  EXECUTE IMMEDIATE get_purge_sql(MSD_COMMON_UTILITIES.MFG_FCST_FACT_TABLE, p_instance_id);
  EXECUTE IMMEDIATE get_purge_sql(MSD_COMMON_UTILITIES.OPPORTUNITY_FACT_TABLE, p_instance_id);
  /* EXECUTE IMMEDIATE get_purge_sql(MSD_COMMON_UTILITIES.CURRENCY_FACT_TABLE, p_instance_id);*/
  EXECUTE IMMEDIATE get_purge_sql(MSD_COMMON_UTILITIES.UOM_FACT_TABLE, p_instance_id);
  EXECUTE IMMEDIATE get_purge_sql(MSD_COMMON_UTILITIES.LEVEL_VALUES_FACT_TABLE, p_instance_id);
  EXECUTE IMMEDIATE get_purge_sql(MSD_COMMON_UTILITIES.LEVEL_ASSOC_FACT_TABLE, p_instance_id);
  EXECUTE IMMEDIATE get_purge_sql(MSD_COMMON_UTILITIES.ITEM_INFO_FACT_TABLE, p_instance_id);
  EXECUTE IMMEDIATE get_purge_sql(MSD_COMMON_UTILITIES.TIME_FACT_TABLE, p_instance_id);
  EXECUTE IMMEDIATE get_purge_sql(MSD_COMMON_UTILITIES.PRICING_FACT_TABLE, p_instance_id);

  COMMIT;

exception
    when others then
         errbuf := substr(SQLERRM,1,150);
         retcode := -1 ;
         rollback;

end purge_facts;


function get_purge_sql(p_table VARCHAR2, p_instance_id NUMBER) RETURN VARCHAR2 IS
  ret varchar2(100);
begin
  ret := 'delete from ' || p_table;
  if p_instance_id is not null then
    ret := ret || ' where instance = ' || p_instance_id;
  end if;

  return ret;
end get_purge_sql;

/* Bug# 4747555
 * This function validates the order types given
 * by the user to the following procedures:
 * 1) collect_shipment_data
 * 2) collect_booking_data
 * This function returns the number of invalid
 * order types found in the user input.
 * Returns '-1' incase of ERROR.
 */
FUNCTION validate_input_parameters (
                        p_dblink                  IN VARCHAR2,
			p_collect_all_order_types IN NUMBER,
			p_include_order_types     IN VARCHAR2,
			p_exclude_order_types     IN VARCHAR2,
			p_order_type_flag         OUT NOCOPY NUMBER,
			p_order_type_ids          OUT NOCOPY VARCHAR2,
			p_retcode                 OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

   l_order_type_table           ORDER_TYPE_TABLE_TYPE;
   l_order_category_code_table  ORDER_TYPE_TABLE_TYPE;
   l_order_type_id_table        ORDER_TYPE_ID_TABLE_TYPE;
   l_valid_order_type_table     ORDER_TYPE_TABLE_TYPE;
   l_invalid_order_type_table   ORDER_TYPE_TABLE_TYPE;

   l_sql_stmt             VARCHAR2(2000);
   l_order_types          VARCHAR2(2000);
   l_original_order_types VARCHAR2(2000);
   l_order_type_ids       VARCHAR2(2000);
   l_token                VARCHAR2(100);
   l_original_token       VARCHAR2(100);

   l_order_type_flag NUMBER;
   l_start           NUMBER := 1;
   l_position        NUMBER := -1;
   l_valid_count     NUMBER := 0;
   l_invalid_count   NUMBER := 0;

   l_found           BOOLEAN;

BEGIN

   /* Get all the valid order types from the source*/
   l_sql_stmt := 'SELECT ' ||
                    'B.TRANSACTION_TYPE_ID ORDER_TYPE_ID, ' ||
                    'UPPER(B.ORDER_CATEGORY_CODE) ORDER_CATEGORY_CODE, ' ||
                    'UPPER(T.NAME) NAME ' ||
                 'FROM ' ||
                    'OE_TRANSACTION_TYPES_TL' || p_dblink || ' T, ' ||
                    'OE_TRANSACTION_TYPES_ALL' || p_dblink || ' B '||
                 'WHERE ' ||
                    'B.TRANSACTION_TYPE_ID = T.TRANSACTION_TYPE_ID AND ' ||
                    'B.Transaction_type_code = ''ORDER'' AND ' ||
                    'nvl(B.SALES_DOCUMENT_TYPE_CODE,''O'') <> ''B'' AND ' ||
                    'T.LANGUAGE = userenv(''LANG'') ';

   EXECUTE IMMEDIATE l_sql_stmt
      BULK COLLECT INTO l_order_type_id_table,
                        l_order_category_code_table,
                        l_order_type_table;

   IF l_order_type_table.COUNT = 0 THEN
      p_retcode := -1;
      msd_conc_log_util.display_message('No order types found in the source', msd_conc_log_util.C_ERROR);
      return -1;
   END IF;

   IF p_collect_all_order_types = SYS_NO THEN

      IF p_include_order_types is null AND
         p_exclude_order_types is null THEN
         p_retcode := -1;
         msd_conc_log_util.display_message('Both the parameters include order types and exclude order types are null', msd_conc_log_util.C_ERROR);
         return -1;
      ELSIF p_include_order_types is not null AND
            p_exclude_order_types is not null THEN
         p_retcode := -1;
         msd_conc_log_util.display_message('Both the parameters include order types and exclude order types are not null', msd_conc_log_util.C_ERROR);
         return -1;
      ELSIF p_include_order_types is not null THEN
         l_order_type_flag := C_INCLUDE;
         l_order_types := UPPER(p_include_order_types);
         l_original_order_types := p_include_order_types;
      ELSE
         l_order_type_flag := C_EXCLUDE;
         l_order_types := UPPER(p_exclude_order_types);
         l_original_order_types := p_exclude_order_types;
      END IF;

      l_valid_order_type_table   := ORDER_TYPE_TABLE_TYPE();
      l_invalid_order_type_table := ORDER_TYPE_TABLE_TYPE();

      /* Get the valid and invalid order types given by the user */
      LOOP

         l_position := INSTR( l_order_types, ',', l_start, 1);

         /* Get the token (order type)*/
         IF (l_position <> 0) THEN
            l_token := SUBSTR( l_order_types, l_start, l_position - l_start);
            l_original_token := SUBSTR( l_original_order_types, l_start, l_position - l_start);
         ELSE
            l_token := SUBSTR( l_order_types, l_start);
            l_original_token := SUBSTR( l_original_order_types, l_start);
         END IF;

         /* Validate the order type*/
         l_found := FALSE;
         FOR i in l_order_type_table.FIRST..l_order_type_table.LAST
         LOOP

            /* Valid order type */
            IF l_order_category_code_table(i) <> 'RETURN' AND l_token = l_order_type_table(i) THEN

               l_found := TRUE;
               l_valid_count := l_valid_count + 1;
               l_valid_order_type_table.EXTEND;
               l_valid_order_type_table(l_valid_count) := l_original_token;

               IF (l_valid_count = 1) THEN
                  l_order_type_ids := l_order_type_ids || to_char(l_order_type_id_table(i));
               ELSE
                  l_order_type_ids := l_order_type_ids || ',' || to_char(l_order_type_id_table(i));
               END IF;

               EXIT;

            /* Invalid order type since order category code is 'RETURN' */
            ELSIF l_order_category_code_table(i) = 'RETURN' AND l_token = l_order_type_table(i) THEN

               l_found := TRUE;
               l_invalid_count := l_invalid_count + 1;
               l_invalid_order_type_table.EXTEND;
               l_invalid_order_type_table(l_invalid_count) := l_original_token || '  (Order Type is RETURN)';

               EXIT;

            END IF;

         END LOOP;

         /* Invalid order type */
         IF l_found = FALSE THEN
               l_invalid_count := l_invalid_count + 1;
               l_invalid_order_type_table.EXTEND;
               l_invalid_order_type_table(l_invalid_count) := l_original_token;
         END IF;

         EXIT WHEN l_position = 0;
         l_start := l_position + 1;
      END LOOP;

      msd_conc_log_util.display_message('Demand Plan Order Types', msd_conc_log_util.C_SECTION);
      msd_conc_log_util.display_message(' ', msd_conc_log_util.C_HEADING);

      msd_conc_log_util.display_message('Valid Order Types', msd_conc_log_util.C_HEADING);
      msd_conc_log_util.display_message('------------------------------------------------', msd_conc_log_util.C_HEADING);

      IF l_valid_count <> 0 THEN
         FOR i in l_valid_order_type_table.FIRST..l_valid_order_type_table.LAST
         LOOP
            msd_conc_log_util.display_message(to_char(i) || ') ' || l_valid_order_type_table(i), msd_conc_log_util.C_INFORMATION);
         END LOOP;
      ELSE
         p_retcode := -1;
         msd_conc_log_util.display_message('No valid order types found in user input', msd_conc_log_util.C_ERROR);
      END IF;

      msd_conc_log_util.display_message(' ', msd_conc_log_util.C_HEADING);
      msd_conc_log_util.display_message('Invalid Order Types', msd_conc_log_util.C_HEADING);
      msd_conc_log_util.display_message('------------------------------------------------', msd_conc_log_util.C_HEADING);

      IF l_invalid_count <> 0 THEN
         FOR i in l_invalid_order_type_table.FIRST..l_invalid_order_type_table.LAST
         LOOP
            msd_conc_log_util.display_message(to_char(i) || ') ' || l_invalid_order_type_table(i), msd_conc_log_util.C_WARNING);
         END LOOP;
      END IF;
      msd_conc_log_util.display_message(' ', msd_conc_log_util.C_HEADING);

      IF l_valid_count = 0 THEN
         return -1;
      END IF;

   ELSE /* Collect all order types */

      IF p_include_order_types is not null OR
         p_exclude_order_types is not null THEN

         p_retcode := -1;
         msd_conc_log_util.display_message('Parameter(s) include/exclude order types not null when collect all order types is YES', msd_conc_log_util.C_ERROR);
         return -1;

      ELSE

            l_order_type_flag := C_ALL;
            l_order_type_ids := '';

      END IF;

   END IF;

   p_order_type_flag := l_order_type_flag;
   p_order_type_ids := l_order_type_ids;
   p_retcode := 0;
   RETURN l_invalid_count;

END validate_input_parameters;

END MSD_COLLECT_FACT_DATA;

/
