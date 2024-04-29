--------------------------------------------------------
--  DDL for Package Body MSD_TRANSLATE_FACT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_TRANSLATE_FACT_DATA" AS
/* $Header: msdtfctb.pls 120.6 2007/06/11 08:48:06 vrepaka ship $ */

 --Constants
   C_DAILY_BUCKET        CONSTANT VARCHAR2(10) := '9';
   C_WEEKLY_BUCKET       CONSTANT VARCHAR2(10) := '1';
   C_MONTHLY_BUCKET      CONSTANT VARCHAR2(10) := '2';
   C_MONTH_TO_ADD	 CONSTANT NUMBER       :=  4;
   C_FROM_DATE           CONSTANT  DATE := to_date('01-01-1000','DD-MM-YYYY');
   C_TO_DATE             CONSTANT  DATE := to_date('01-01-4000','DD-MM-YYYY');


   /* Bug# 4747555 */
   C_INCLUDE             CONSTANT NUMBER := 2;
   C_EXCLUDE             CONSTANT NUMBER := 3;

PROCEDURE populate_calendar_dates(p_cal_code   VARCHAR2,
				  p_min_date   DATE,
				  p_max_date   DATE,
				  p_dblink     VARCHAR2 );

PROCEDURE populate_cs_data_header(p_instance in number,
                                  p_name IN VARCHAR2,
                                  p_ref_num in number);

procedure translate_shipment_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_from_date         IN  DATE,
                        p_to_date           IN  DATE,
                        p_new_refresh_num   IN  NUMBER,
                        p_delete_flag       IN  VARCHAR2,
                        p_collect_ISO       IN  NUMBER   DEFAULT SYS_NO,             /* Bug# 4615390 ISO, Bug# 4865396 */
                        p_order_type_flag   IN  NUMBER   DEFAULT C_ALL,              /* Bug# 4747555*/
                        p_order_type_ids    IN  VARCHAR2 DEFAULT NULL) IS


v_instance_id    varchar2(40);
v_dblink         varchar2(128);
v_retcode	 number;
v_sql_stmt       varchar2(4000);
v_date_range     varchar2(2000);
v_ref_num        number;

/* Bug# 4615390 ISO , additional filter condition if p_collect_ISO = SYS_NO */
v_exclude_ISO   varchar2(255);

v_order_type_condition  varchar2(2000);      /* Bug# 4747555 */

Begin


	/**************************************************
	-	1. Get the instance id from MSC_APP_INSTANCE
	-	2. Get the Profile Value for MSD_DIRECT_LOAD
	-	   to identify whether we need to insert the
	-	   data into the staging tables or the
	-	   fact tables.
	-	3. Check for the Data Duplication, we should
	-	   use the shipped_date for this
 fact data.
	-	4. Insert the Data accordingly into the
	-	   Staging or the Fact table based on the
	-	   MSD_SR_SHIPMENT_DATA_V.
	-	5. Commit
	****************************************************/


        retcode :=0;

         /* Always populate date range even though the range is null
            In case of null, we will use extremely small and large date
            for the from date and to date */

         v_date_range := v_date_range ||
                    ' and trunc(shipped_date) between '||
                    ' to_date(to_char(:p_from_date, ''dd-mon-yyyy''), ''DD-MON-RRRR'') ' ||
                    ' AND to_date(to_char(:p_to_date,''dd-mon-yyyy''),''DD-MON-RRRR'') ' ;

        /* Bug# 4615390 ISO , If p_collect_ISO = SYS_NO, then
         * include an additional condition to filter out Internal Sales Orders
         */
        v_exclude_ISO := v_exclude_ISO ||
                        ' AND nvl(ORDER_SOURCE_ID, 0) <> 10 ';

        /* Check dest_table */
	IF p_dest_table = MSD_COMMON_UTILITIES.SHIPMENT_STAGING_TABLE then

	   /* Physically delete existing data before inserting new rows*/
           v_sql_stmt := 'DELETE FROM msd_st_shipment_data '||
                        ' WHERE  instance = ''' || p_instance_id || '''' ;
           v_sql_stmt := v_sql_stmt || v_date_range;

           if p_delete_flag = 'Y' then
               EXECUTE IMMEDIATE v_sql_stmt
               USING nvl(p_from_date, C_FROM_DATE),
                     nvl(p_to_date, C_TO_DATE);
           end if;

           /* Bug# 4747555 */
           IF p_order_type_flag = C_INCLUDE THEN
              v_order_type_condition := ' AND ORDER_TYPE_ID IN (' || p_order_type_ids || ') ';
           ELSIF p_order_type_flag = C_EXCLUDE THEN
              v_order_type_condition := ' AND ORDER_TYPE_ID NOT IN (' || p_order_type_ids || ') ';
           ELSE
              v_order_type_condition  := NULL;
           END IF;

           /* DWK  Added sr_original_item_pk to insert stmt */
           /* Bug# 4615390 ISO , added ORDER_SOURCE_ID to the insert stmt */
           v_sql_stmt := 'INSERT INTO ' || p_dest_table ||
		' (instance, inv_org, item, customer, sales_channel, '||
		'sales_rep, ship_to_loc, user_defined1, user_defined2, '||
		'sr_inv_org_pk, sr_item_pk, sr_customer_pk, sr_sales_channel_pk, '||
		'sr_sales_rep_pk, sr_ship_to_loc_pk, sr_user_defined1_pk, sr_user_defined2_pk, '||
		'booked_date, requested_date, promised_date, shipped_date, ' ||
		'scheduled_ship_date, scheduled_arrival_date, amount, qty_shipped, creation_date, created_by, ' ||
		'last_update_date, last_updated_by, last_update_login, '||
                'sr_original_item_pk, sr_parent_item_pk, sr_demand_class_pk, ORDER_SOURCE_ID ) '||
	        'SELECT '''||p_instance_id ||
        	''', inv_org, item, customer, sales_channel, sales_rep, '||
        	'ship_to_loc, user_defined1, user_defined2, '||
		'nvl(sr_inv_org_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_item_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_customer_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_sales_channel_pk,  msd_sr_util.get_null_pk), '||
		'nvl(sr_sales_rep_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_ship_to_loc_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_user_defined1_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_user_defined2_pk, msd_sr_util.get_null_pk), '||
		'booked_date,'||
        	'requested_date, promised_date, shipped_date, scheduled_ship_date, scheduled_arrival_date, amount, '||
        	'qty_shipped, sysdate, '|| FND_GLOBAL.USER_ID ||
		', sysdate, '|| FND_GLOBAL.USER_ID ||', '|| FND_GLOBAL.USER_ID ||
                ', to_char(sr_original_item_pk), to_char(sr_parent_item_pk), to_char(sr_demand_class_pk) ' ||
                ', ORDER_SOURCE_ID ' ||
		'FROM ' || p_source_table ||' where 1 = 1';

            v_sql_stmt := v_sql_stmt || v_date_range;

            /* Bug# 4615390 ISO , If p_collect_ISO = SYS_NO, then
             * include an additional condition to filter out Internal Sales Orders
             */
            IF p_collect_ISO = SYS_NO THEN
               v_sql_stmt := v_sql_stmt || v_exclude_ISO;
            END IF;

            /* Bug# 4747555 */
            v_sql_stmt := v_sql_stmt || v_order_type_condition;

       	ELSIF p_dest_table = MSD_COMMON_UTILITIES.SHIPMENT_FACT_TABLE then
           /* Mark delete for overlapping rows and  Update its last_refresh_num */

           v_sql_stmt := ' UPDATE msd_shipment_data ' ||
			 ' SET	last_refresh_num = ' || p_new_refresh_num ||
			 ', Action_code = ' || '''D''' ||
			 ' WHERE Action_code = ''I'' and instance = '||p_instance_id || v_date_range;

            EXECUTE IMMEDIATE v_sql_stmt
            USING nvl(p_from_date, C_FROM_DATE),
                  nvl(p_to_date, C_TO_DATE);


           /* DWK  Added sr_original_item_pk to insert stmt */
           /* Bug# 4615390 ISO , added ORDER_SOURCE_ID to the insert stmt */
           v_sql_stmt := 'INSERT INTO ' || p_dest_table ||
		' (instance, inv_org, item, customer, sales_channel, '||
		'sales_rep, ship_to_loc, user_defined1, user_defined2, '||
		'sr_inv_org_pk, sr_item_pk, sr_customer_pk, sr_sales_channel_pk, '||
		'sr_sales_rep_pk, sr_ship_to_loc_pk, sr_user_defined1_pk, sr_user_defined2_pk, '||
		'booked_date, requested_date, promised_date, shipped_date, ' ||
		'scheduled_ship_date, scheduled_arrival_date, amount, ' ||
                'qty_shipped, creation_date, created_by, ' ||
		'last_update_date, last_updated_by, last_update_login, '||
                'last_refresh_num, created_by_refresh_num, action_code, '||
                'sr_original_item_pk, sr_parent_item_pk, sr_demand_class_pk, ORDER_SOURCE_ID ) '||
	        'SELECT '''||p_instance_id ||
        	''', inv_org, item, customer, sales_channel, sales_rep, '||
        	'ship_to_loc, user_defined1, user_defined2, '||
		'nvl(sr_inv_org_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_item_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_customer_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_sales_channel_pk,  msd_sr_util.get_null_pk), '||
		'nvl(sr_sales_rep_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_ship_to_loc_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_user_defined1_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_user_defined2_pk, msd_sr_util.get_null_pk), '||
		'booked_date,'||
        	'requested_date, promised_date, shipped_date,  ' ||
                'scheduled_ship_date, scheduled_arrival_date, ' ||
        	'amount, qty_shipped, sysdate, '|| FND_GLOBAL.USER_ID ||
		', sysdate, '|| FND_GLOBAL.USER_ID ||', '|| FND_GLOBAL.USER_ID ||
                ', '|| p_new_refresh_num || ', ' || p_new_refresh_num || ', '|| '''I''' ||
                ', to_char(sr_original_item_pk), to_char(sr_parent_item_pk), to_char(sr_demand_class_pk) ' ||
                ', ORDER_SOURCE_ID ' ||
		'FROM ' || p_source_table ||' where 1 = 1';

           v_sql_stmt := v_sql_stmt || v_date_range;


           /* DWK. if the source is from staging table, then we shouldn't insert instance = '0'
              rows into fact table*/
           if (p_source_table = MSD_COMMON_UTILITIES.SHIPMENT_STAGING_TABLE) then
              v_sql_stmt := v_sql_stmt || ' and nvl(instance,''888'') <> '||'''0''';
           end if;

        END IF;

 	EXECUTE IMMEDIATE v_sql_stmt
        USING nvl(p_from_date, C_FROM_DATE),
              nvl(p_to_date, C_TO_DATE);

        IF p_dest_table = MSD_COMMON_UTILITIES.SHIPMENT_FACT_TABLE then

          Begin

            select 1 into v_ref_num
              from msd_cs_data_headers
             where cs_definition_id in (select cs_definition_id
            from msd_cs_definitions
            where name = 'MSD_SHIPMENT_HISTORY');

            update msd_cs_data_headers
            set last_refresh_num = p_new_refresh_num
            where cs_definition_id in (select cs_definition_id
            from msd_cs_definitions
            where name in ('MSD_SHIPMENT_HISTORY','MSD_SHIPMENT_ORIG_HISTORY'));

          Exception When No_Data_Found Then
             populate_cs_data_header(p_instance_id,
                                     'MSD_SHIPMENT_HISTORY',
                                     p_new_refresh_num);

             populate_cs_data_header(p_instance_id,
                                     'MSD_SHIPMENT_ORIG_HISTORY',
                                     p_new_refresh_num);


           END;
	 END IF;


	retcode := 0;

EXCEPTION
   when others then
      fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
      errbuf := substr(SQLERRM,1,150);
      retcode := -1 ;
      raise;

End translate_shipment_data ;


procedure translate_booking_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_from_date         IN  DATE,
                        p_to_date           IN  DATE,
                        p_new_refresh_num   IN  NUMBER,
                        p_delete_flag       IN  VARCHAR2,
                        p_collect_ISO       IN  NUMBER   DEFAULT SYS_NO,             /* Bug# 4615390 ISO, Bug# 4865396 */
                        p_order_type_flag   IN  NUMBER   DEFAULT C_ALL,              /* Bug# 4747555*/
                        p_order_type_ids    IN  VARCHAR2 DEFAULT NULL) IS


v_instance_id    varchar2(40);
v_dblink         varchar2(128);
v_retcode	 number;
v_sql_stmt       varchar2(4000);
v_date_range     varchar2(2000);
v_ref_num        number;

/* Bug# 4615390 ISO , additional filter condition if p_collect_ISO = SYS_NO */
v_exclude_ISO   varchar2(255);

v_order_type_condition  varchar2(2000);      /* Bug# 4747555 */

Begin


	/**************************************************
	-	1. Get the instance id from MSC_APP_INSTANCE
	-	2. Get the Profile Value for MSD_DIRECT_LOAD
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
         /* Always populate date range even though the range is null
            In case of null, we will use extremely small and large date
            for the from date and to date */

         v_date_range := v_date_range ||
                    ' and trunc(booked_date) between '||
                    ' to_date(to_char(:p_from_date, ''dd-mon-yyyy''), ''DD-MON-RRRR'') ' ||
                    ' AND to_date(to_char(:p_to_date, ''dd-mon-yyyy''),''DD-MON-RRRR'') ' ;

        /* Bug# 4615390 ISO , If p_collect_ISO = SYS_NO, then
         * include an additional condition to filter out Internal Sales Orders
         */
        v_exclude_ISO := v_exclude_ISO ||
                        ' AND nvl(ORDER_SOURCE_ID, 0) <> 10 ';

        /* Check dest_table */
	IF p_dest_table = MSD_COMMON_UTILITIES.BOOKING_STAGING_TABLE then

	   /* Physically delete existing data before inserting new rows*/
           v_sql_stmt := 'DELETE FROM msd_st_booking_data '||
                        ' WHERE  instance = ''' || p_instance_id || '''' ;
           v_sql_stmt := v_sql_stmt || v_date_range;

           if p_delete_flag = 'Y' then
               EXECUTE IMMEDIATE v_sql_stmt
               USING nvl(p_from_date, C_FROM_DATE ),
                     nvl(p_to_date, C_TO_DATE );
           end if;

           /* Bug# 4747555 */
           IF p_order_type_flag = C_INCLUDE THEN
              v_order_type_condition := ' AND ORDER_TYPE_ID IN (' || p_order_type_ids || ') ';
           ELSIF p_order_type_flag = C_EXCLUDE THEN
              v_order_type_condition := ' AND ORDER_TYPE_ID NOT IN (' || p_order_type_ids || ') ';
           ELSE
              v_order_type_condition  := NULL;
           END IF;

           /* DWK  Added sr_original_item_pk to insert stmt */
           /* Bug# 4615390 ISO , added ORDER_SOURCE_ID to the insert stmt */
           v_sql_stmt := 'INSERT INTO ' || p_dest_table ||
		' (instance, inv_org, item, customer, sales_channel, '||
		'sales_rep, ship_to_loc, user_defined1, user_defined2, '||
		'sr_inv_org_pk, sr_item_pk, sr_customer_pk, sr_sales_channel_pk, '||
		'sr_sales_rep_pk, sr_ship_to_loc_pk, sr_user_defined1_pk, sr_user_defined2_pk, '||
		'booked_date, requested_date, promised_date, '||
		'scheduled_date, scheduled_arrival_date, ' ||
		'amount, qty_ordered, creation_date, created_by, ' ||
		'last_update_date, last_updated_by, last_update_login, '||
                'sr_original_item_pk, sr_parent_item_pk, sr_demand_class_pk, ORDER_SOURCE_ID) '||
	        'SELECT '''||p_instance_id ||
        	''', inv_org, item, customer, sales_channel, sales_rep, '||
        	'ship_to_loc, user_defined1, user_defined2, '||
                'nvl(sr_inv_org_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_item_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_customer_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_sales_channel_pk,  msd_sr_util.get_null_pk), '||
                'nvl(sr_sales_rep_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_ship_to_loc_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_user_defined1_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_user_defined2_pk, msd_sr_util.get_null_pk), '||
		'booked_date,'||
        	'requested_date, promised_date, scheduled_ship_date, scheduled_arrival_date , '||
        	'amount, qty_ordered, sysdate, '|| FND_GLOBAL.USER_ID ||
		', sysdate, '|| FND_GLOBAL.USER_ID || ', '|| FND_GLOBAL.USER_ID ||
                ', to_char(sr_original_item_pk), ' ||
                '  to_char(sr_parent_item_pk), to_char(sr_demand_class_pk), ORDER_SOURCE_ID ' ||
		'from ' || p_source_table ||' where 1 = 1';

           v_sql_stmt := v_sql_stmt || v_date_range;

            /* Bug# 4615390 ISO , If p_collect_ISO = SYS_NO, then
             * include an additional condition to filter out Internal Sales Orders
             */
            IF p_collect_ISO = SYS_NO THEN
               v_sql_stmt := v_sql_stmt || v_exclude_ISO;
            END IF;

            /* Bug# 4747555 */
            v_sql_stmt := v_sql_stmt || v_order_type_condition;

	ELSIF  p_dest_table = MSD_COMMON_UTILITIES.BOOKING_FACT_TABLE then

           /* Mark delete for overlapping rows and  Update its last_refresh_num */

           v_sql_stmt := ' UPDATE msd_booking_data ' ||
			 ' SET	last_refresh_num = ' || p_new_refresh_num ||
			 ', Action_code = ' || '''D''' ||
			 ' WHERE Action_code = ''I'' and instance = '||p_instance_id || v_date_range;

               EXECUTE IMMEDIATE v_sql_stmt
               USING nvl(p_from_date, C_FROM_DATE ),
                     nvl(p_to_date, C_TO_DATE );

           /* Bug# 4615390 ISO , added ORDER_SOURCE_ID to the insert stmt */
           v_sql_stmt := 'INSERT INTO ' || p_dest_table ||
		' (instance, inv_org, item, customer, sales_channel, '||
		'sales_rep, ship_to_loc, user_defined1, user_defined2, '||
		'sr_inv_org_pk, sr_item_pk, sr_customer_pk, sr_sales_channel_pk, '||
		'sr_sales_rep_pk, sr_ship_to_loc_pk, sr_user_defined1_pk, sr_user_defined2_pk, '||
		'booked_date, requested_date, promised_date, '||
		'scheduled_date, scheduled_arrival_date, ' ||
		'amount, qty_ordered, creation_date, created_by, ' ||
		'last_update_date, last_updated_by, last_update_login, '||
                'last_refresh_num, created_by_refresh_num, action_code, '||
                'sr_original_item_pk, sr_parent_item_pk, sr_demand_class_pk, ORDER_SOURCE_ID ) '||
	        'SELECT '''||p_instance_id ||
        	''', inv_org, item, customer, sales_channel, sales_rep, '||
        	'ship_to_loc, user_defined1, user_defined2, '||
                'nvl(sr_inv_org_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_item_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_customer_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_sales_channel_pk,  msd_sr_util.get_null_pk), '||
                'nvl(sr_sales_rep_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_ship_to_loc_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_user_defined1_pk, msd_sr_util.get_null_pk), ' ||
                'nvl(sr_user_defined2_pk, msd_sr_util.get_null_pk), '||
		'booked_date,'||
        	'requested_date, promised_date, scheduled_date, scheduled_arrival_date, '||
        	'amount, qty_ordered, sysdate, '|| FND_GLOBAL.USER_ID ||
		', sysdate, '|| FND_GLOBAL.USER_ID || ', '|| FND_GLOBAL.USER_ID ||
                ', '|| p_new_refresh_num || ', ' || p_new_refresh_num || ', '|| '''I''' ||
                ', to_char(sr_original_item_pk), to_char(sr_parent_item_pk), to_char(sr_demand_class_pk) ' ||
                ', ORDER_SOURCE_ID ' ||
		'from ' || p_source_table ||' where 1 = 1';

           v_sql_stmt := v_sql_stmt || v_date_range;


           /* DWK. if the source is from staging table, then we shouldn't insert instance = '0'
              rows into fact table*/
           if (p_source_table = MSD_COMMON_UTILITIES.BOOKING_STAGING_TABLE) then
              v_sql_stmt := v_sql_stmt || ' and nvl(instance,''888'') <> '||'''0''';
           end if;

        END IF;

        EXECUTE IMMEDIATE v_sql_stmt
        USING nvl(p_from_date, C_FROM_DATE ),
              nvl(p_to_date, C_TO_DATE );

        IF p_dest_table = MSD_COMMON_UTILITIES.BOOKING_FACT_TABLE then

          Begin

            select 1 into v_ref_num
              from msd_cs_data_headers
             where cs_definition_id in (select cs_definition_id
            from msd_cs_definitions
            where name = 'MSD_BOOKING_HISTORY');

            update msd_cs_data_headers
            set last_refresh_num = p_new_refresh_num
            where cs_definition_id in (select cs_definition_id
            from msd_cs_definitions
            where name in ('MSD_BOOKING_HISTORY','MSD_BOOKING_ORIG_HISTORY'));

          Exception When No_Data_Found Then
             populate_cs_data_header(p_instance_id,
                                     'MSD_BOOKING_HISTORY',
                                     p_new_refresh_num);
             populate_cs_data_header(p_instance_id,
                                     'MSD_BOOKING_ORIG_HISTORY',
                                     p_new_refresh_num);

           END;
	 END IF;

	retcode := 0;

EXCEPTION
   when others then
      fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
      errbuf := substr(SQLERRM,1,150);
      retcode := -1 ;
      raise;

End translate_booking_data ;



procedure translate_uom_conversion(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_new_refresh_num   IN  NUMBER) IS

v_instance_id    varchar2(40);
v_dblink         varchar2(128);
v_retcode	 number;
v_sql_stmt       varchar2(4000);

/* Cursor for delete */
/* Changed for bug # 3752937. Only those records should be deleted which are in staging */
CURSOR c_delete IS
SELECT from_uom_class, to_uom_class,
from_uom_code, to_uom_code,
base_uom_flag, sr_item_pk
FROM msd_uom_conversions
WHERE instance = p_instance_id
INTERSECT
SELECT from_uom_class, to_uom_class,
from_uom_code, to_uom_code,
base_uom_flag, sr_item_pk
FROM msd_st_uom_conversions
WHERE instance = p_instance_id;

/* Cursor for insert */
CURSOR c_insert IS
SELECT from_uom_class, to_uom_class,
from_uom_code, to_uom_code,
base_uom_flag, conversion_rate, sr_item_pk, item
FROM msd_st_uom_conversions
WHERE instance = p_instance_id and
      nvl(instance,-999) <> 0
MINUS
SELECT from_uom_class, to_uom_class,
from_uom_code, to_uom_code,
base_uom_flag, conversion_rate, sr_item_pk, item
FROM msd_uom_conversions
WHERE instance = p_instance_id and
      nvl(instance,-999) <> 0;


TYPE from_uom_class_tab     IS TABLE OF msd_uom_conversions.from_uom_class%TYPE;
TYPE from_uom_code_tab      IS TABLE OF msd_uom_conversions.from_uom_code%TYPE;
TYPE base_uom_flag_tab      IS TABLE OF msd_uom_conversions.base_uom_flag%TYPE;
TYPE conversion_rate_tab    IS TABLE OF msd_uom_conversions.conversion_rate%TYPE;
TYPE sr_item_pk_tab         IS TABLE OF msd_uom_conversions.sr_item_pk%TYPE;
TYPE item_tab               IS TABLE OF msd_uom_conversions.item%TYPE;

a_from_uom_class      from_uom_class_tab;
a_to_uom_class        from_uom_class_tab;
a_from_uom_code       from_uom_code_tab;
a_to_uom_code         from_uom_code_tab;
a_base_uom_flag       base_uom_flag_tab;
a_conversion_rate     conversion_rate_tab;
a_sr_item_pk          sr_item_pk_tab;
a_item                item_tab;

Begin


        /**************************************************
        -       1. Get the instance id from MSC_APP_INSTANCE
        -       2. Get the Profile Value for MSD_DIRECT_LOAD
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

	v_instance_id := p_instance_id;
	retcode :=0;

        IF p_dest_table = MSD_COMMON_UTILITIES.UOM_STAGING_TABLE THEN
             DELETE FROM msd_st_uom_conversions
             WHERE  instance = p_instance_id;

             v_sql_stmt := 'INSERT INTO ' || p_dest_table ||
		  ' ( INSTANCE, SR_ITEM_PK, ITEM, FROM_UOM_CLASS, TO_UOM_CLASS, ' ||
		  '   FROM_UOM_CODE, TO_UOM_CODE, BASE_UOM_FLAG, ' ||
		  '   CONVERSION_RATE, CREATION_DATE, CREATED_BY, ' ||
		  '   LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN )'||
		  ' SELECT  ' || NVL(v_instance_id, 'INSTANCE') || ', ' ||
		  '   decode(SR_ITEM_PK, ''0'', null, SR_ITEM_PK), ITEM, FROM_UOM_CLASS, TO_UOM_CLASS, ' ||
		  '   FROM_UOM_CODE, TO_UOM_CODE, BASE_UOM_FLAG, ' ||
		  '   CONVERSION_RATE, sysdate, '|| FND_GLOBAL.USER_ID ||
                  ', sysdate, '|| FND_GLOBAL.USER_ID ||', '|| FND_GLOBAL.USER_ID ||'  ' ||
		  ' from ' || p_source_table || ' where 1 = 1';
                  --dbms_output.put_line(v_sql_stmt);
              EXECUTE IMMEDIATE v_sql_stmt;
        ELSIF p_dest_table = MSD_COMMON_UTILITIES.UOM_FACT_TABLE THEN
            OPEN c_delete;
            FETCH c_delete BULK COLLECT INTO a_from_uom_class, a_to_uom_class, a_from_uom_code,
                                             a_to_uom_code, a_base_uom_flag, a_sr_item_pk;
            CLOSE c_delete;
            IF (a_from_uom_class.exists(1)) THEN
               FORALL i IN a_from_uom_class.FIRST..a_from_uom_class.LAST
                  DELETE FROM msd_uom_conversions
                  WHERE instance = p_instance_id and
                        nvl(sr_item_pk,'NULL') = nvl(a_sr_item_pk(i), 'NULL') and
                        from_uom_class = a_from_uom_class(i) and
                        to_uom_class   = a_to_uom_class(i) and
                        from_uom_code = a_from_uom_code(i) and
                        to_uom_code = a_to_uom_code(i) and
                        base_uom_flag = a_base_uom_flag(i);
            END IF;

            OPEN c_insert;
            FETCH c_insert BULK COLLECT INTO a_from_uom_class, a_to_uom_class, a_from_uom_code,
                                             a_to_uom_code, a_base_uom_flag, a_conversion_rate,
                                             a_sr_item_pk, a_item;
            CLOSE c_insert;

            IF (a_from_uom_class.exists(1)) THEN
                FORALL i IN a_from_uom_class.FIRST..a_from_uom_class.LAST
                   INSERT INTO msd_uom_conversions(
                              INSTANCE, SR_ITEM_PK, ITEM, FROM_UOM_CLASS, TO_UOM_CLASS,
		              FROM_UOM_CODE, TO_UOM_CODE, BASE_UOM_FLAG,
		              CONVERSION_RATE, CREATION_DATE, CREATED_BY,
		              LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                              last_refresh_num, created_by_refresh_num, action_code)
                   VALUES ( p_instance_id, a_sr_item_pk(i), a_item(i),
                            a_from_uom_class(i), a_to_uom_class(i),
                            a_from_uom_code(i), a_to_uom_code(i), a_base_uom_flag(i),
                            a_conversion_rate(i), sysdate, FND_GLOBAL.USER_ID,
                            sysdate, FND_GLOBAL.USER_ID, FND_GLOBAL.USER_ID,
                            p_new_refresh_num, p_new_refresh_num, 'I');
             END IF;
        END IF; /* End of ELSIF */
        retcode := 0;

exception

        when others then

                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;
                raise;



End translate_uom_conversion ;

procedure translate_currency_conversion(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
			p_from_date         IN  DATE,
                        p_to_date           IN  DATE) IS
v_instance_id    varchar2(40);
v_dblink         varchar2(128);
v_retcode       number;
v_sql_stmt       varchar2(4000);
v_date_range     varchar2(2000);

Begin


        /**************************************************
        -       1. Get the instance id from MSC_APP_INSTANCE
        -       2. Get the Profile Value for MSD_DIRECT_LOAD
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

		v_sql_stmt := 'DELETE FROM ' || p_dest_table ||
				' where 1 = 1';

		/* DWK. If dest_table is staging table, then we shouldn't delete
		   instance = '0' row */
		IF (p_dest_table = MSD_COMMON_UTILITIES.CURRENCY_STAGING_TABLE) THEN
		   v_sql_stmt := v_sql_stmt || ' and nvl(instance, ''888'')  <> '||'''0''';
		END IF;

                v_date_range := v_date_range ||
                    ' and trunc(conversion_date) between '||
                    ' to_date(to_char(:p_from_date, ''dd-mon-yyyy''), ''DD-MON-RRRR'') ' ||
                    ' AND to_date(to_char(:p_to_date, ''dd-mon-yyyy''),''DD-MON-RRRR'') ' ;

                v_sql_stmt := v_sql_stmt || v_date_range;

--  dbms_output.put_line(v_sql_stmt);
--  insert into msd_test values(v_sql_stmt) ;
                EXECUTE IMMEDIATE v_sql_stmt
                USING nvl(p_from_date, C_FROM_DATE ),
                      nvl(p_to_date, C_TO_DATE );


                v_sql_stmt := 'INSERT INTO ' || p_dest_table ||
		  ' ( FROM_CURRENCY, TO_CURRENCY, ' ||
		  '   CONVERSION_DATE, CONVERSION_RATE, ' ||
		  '   CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, ' ||
		  '   LAST_UPDATED_BY, LAST_UPDATE_LOGIN )'||
		  ' SELECT ' ||
		  ' FROM_CURRENCY, TO_CURRENCY, ' ||
		  '   CONVERSION_DATE, CONVERSION_RATE, ' ||
		  '   sysdate, '|| FND_GLOBAL.USER_ID || ', sysdate, ' ||
		  FND_GLOBAL.USER_ID ||', '|| FND_GLOBAL.USER_ID ||'  ' ||
		  'from ' || p_source_table || ' where 1 = 1';

                v_sql_stmt := v_sql_stmt || v_date_range;

  /* VM Staging currency conversion table does not have conversion type column. So following
     where condition should not be included for pull program 07/28/2000
     this statement is added by mostrovs on 02/24/2000 to take into account
     the MSD_CONVERSION_TYPE profile */

  /* DWK. if the source is from staging table, then we shouldn't insert instance = '0'
     rows into fact table*/

	if p_source_table = MSD_COMMON_UTILITIES.CURRENCY_STAGING_TABLE then
		v_sql_stmt := v_sql_stmt || ' and nvl(instance, ''888'') <> '||'''0''';
	else
        	if p_from_date is not null or p_to_date is not null then
			v_sql_stmt := v_sql_stmt ||
				' AND conversion_type = nvl(fnd_profile.value(''MSD_CONVERSION_TYPE''), ''Spot'') ' ;
		else
			v_sql_stmt := v_sql_stmt ||
				' AND conversion_type = nvl(fnd_profile.value(''MSD_CONVERSION_TYPE''), ''Spot'') ' ;
		end if;
	end if;


	--insert into msd_test values(v_sql_stmt) ;
 	EXECUTE IMMEDIATE v_sql_stmt
        USING nvl(p_from_date, C_FROM_DATE ),
              nvl(p_to_date, C_TO_DATE );

	retcode := 0;

	exception

	  when others then

		fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;
                raise;


End translate_currency_conversion ;


procedure translate_opportunities_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
			p_from_date	    IN  DATE,
			p_to_date	    IN  DATE) IS
v_instance_id    varchar2(40);
v_dblink         varchar2(128);
v_retcode	number;
v_sql_stmt       varchar2(4000);
v_date_range     varchar2(2000);

Begin


        /**************************************************
        -       1. Get the instance id from MSC_APP_INSTANCE
        -       2. Get the Profile Value for MSD_DIRECT_LOAD
        -          to identify whether we need to insert the
        -          data into the staging tables or the
        -          fact tables.
        -       3. Check for the Data Duplication, we should
        -          use the ship_date  for this fact.
        -       4. Insert the Data accordingly into the
        -          Staging or the Fact table based on the
        -          MSD_SR_OPPORTUNITIES_DATA_V
        -       5. Commit
        ****************************************************/

		v_sql_stmt := 'DELETE FROM ' || p_dest_table ||
			      ' where instance = ''' || p_instance_id || '''' ;
                v_date_range := v_date_range ||
                    ' and trunc(ship_date) between '||
                    ' to_date(to_char(:p_from_date, ''dd-mon-yyyy''), ''DD-MON-RRRR'') ' ||
                    ' AND to_date(to_char(:p_to_date,''dd-mon-yyyy''),''DD-MON-RRRR'') ' ;

                v_sql_stmt := v_sql_stmt || v_date_range;

--	insert into msd_test values(v_sql_stmt) ;
--	dbms_output.put_line(v_sql_stmt);
                EXECUTE IMMEDIATE v_sql_stmt
                USING nvl(p_from_date, C_FROM_DATE ),
                      nvl(p_to_date, C_TO_DATE );

                v_sql_stmt := 'INSERT INTO ' || p_dest_table ||
		  ' (instance, lead_number, interest_type, primary_interest_code, ' ||
		  '  secondary_interest_code, item, inv_org, quantity, amount, '||
		  '  customer, ship_to_loc, sales_channel, sales_rep, '||
		  '  user_defined1, user_defined2, ship_date, win_probability, '||
		  'sr_inv_org_pk, sr_item_pk, sr_customer_pk, sr_sales_channel_pk, '||
		  'sr_sales_rep_pk, sr_ship_to_loc_pk, sr_user_defined1_pk, sr_user_defined2_pk, '||
		  '  status, creation_date, created_by, last_update_date, '||
		  '  last_updated_by, last_update_login ) '||
	        'select '''||p_instance_id ||
        	  ''', lead_number, interest_type, primary_interest_code, ' ||
		  '  secondary_interest_code, item, inv_org, quantity, amount, '||
		  '  customer, ship_to_loc, sales_channel, sales_rep, '||
		  '  user_defined1, user_defined2, nvl(ship_date, sysdate), win_probability, '||
                  'nvl(sr_inv_org_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_item_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_customer_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_sales_channel_pk,  msd_sr_util.get_null_pk), '||
                  'nvl(sr_sales_rep_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_ship_to_loc_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_user_defined1_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_user_defined2_pk, msd_sr_util.get_null_pk), '||
		  '  status, sysdate, '|| FND_GLOBAL.USER_ID || ', sysdate, ' ||
                  FND_GLOBAL.USER_ID ||', '|| FND_GLOBAL.USER_ID ||'  ' ||
		'from ' || p_source_table || ' where 1 = 1';

         v_sql_stmt := v_sql_stmt || v_date_range;

	 /* DWK. if the source is from staging table, then we shouldn't insert instance = '0'
	rows into fact table*/

	if p_source_table = MSD_COMMON_UTILITIES.OPPORTUNITY_STAGING_TABLE then
		v_sql_stmt := v_sql_stmt || ' and nvl(instance,''888'') <> '||'''0''';
	end if;

--	insert into msd_test values(v_sql_stmt) ;
        EXECUTE IMMEDIATE v_sql_stmt
        USING nvl(p_from_date, C_FROM_DATE ),
              nvl(p_to_date, C_TO_DATE );

	retcode := 0;

	exception

	  when others then

		fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;
                raise;


End translate_opportunities_data ;


/* This is obsoleted procedure */
procedure translate_sales_forecast(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
			p_fcst_desg         IN  VARCHAR2,
		        p_from_date         IN  DATE,
                        p_to_date           IN  DATE) IS
v_instance_id    varchar2(40);
v_dblink         varchar2(128);
v_retcode	number;
v_sql_stmt       varchar2(4000);
Begin


        /**************************************************
        -       1. Get the instance id from MSC_APP_INSTANCE
        -       2. Get the Profile Value for MSD_DIRECT_LOAD
        -          to identify whether we need to insert the
        -          data into the staging tables or the
        -          fact tables.
        -       3. Check for the Data Duplication, we should
        -          use the from_date, to_date and period_name
	-          for this fact.
        -       4. Insert the Data accordingly into the
        -          Staging or the Fact table based on the
        -          MSD_SR_SALES_FCST_V
        -       5. Commit
        ****************************************************/


	retcode :=0;



		v_sql_stmt := 'DELETE FROM ' || p_dest_table ||
		  ' where instance = ''' || p_instance_id ||'''' ;

                 if p_from_date is not null and p_to_date is not null then
                        v_sql_stmt := v_sql_stmt ||
                        'and (     (  to_date(period_start_date,''DD-MON-RRRR'') ' ||
			'             between to_date(''' || to_char(p_from_date, 'dd-mon-yyyy') ||
			'             '',''DD-MON-RRRR'') AND to_date(''' || to_char(p_to_date, 'dd-mon-yyyy') ||
                        '             '',''DD-MON-RRRR'') ' ||
			'          ) ' ||
			'      OR  ( to_date(period_end_date,''DD-MON-RRRR'') ' ||
                        '             between to_date(''' || to_char(p_from_date, 'dd-mon-yyyy') ||
                        '             '',''DD-MON-RRRR'') AND to_date(''' || to_char(p_to_date, 'dd-mon-yyyy') ||
                        '             '',''DD-MON-RRRR'') ' ||
                        '          ) ' ||
			'    ) ' ;

                elsif p_to_date is not null then
                        v_sql_stmt := v_sql_stmt ||
                        'and to_date(period_end_date,''DD-MON-RRRR'') <= to_date(''' ||
                        to_char(p_to_date, 'dd-mon-yyyy') || ''',''DD-MON-RRRR'') ' ;
                elsif p_from_date is not null then
                        v_sql_stmt := v_sql_stmt ||
                        'and to_date(period_start_date,''DD-MON-RRRR'') >= to_date(''' ||
                        to_char(p_from_date, 'dd-mon-yyyy') || ''',''DD-MON-RRRR'') ' ;
                end if ;


		EXECUTE IMMEDIATE v_sql_stmt;

                v_sql_stmt := 'INSERT INTO ' || p_dest_table ||
		  ' (instance, forecast_designator, inv_org, interest_type, ' ||
		  '  PRIMARY_INTEREST_CODE, SECONDARY_INTEREST_CODE, item, ' ||
		  '  CUSTOMER, SALES_CHANNEL, SALES_REP, SALES_GROUP, SHIP_TO_LOC, ' ||
		  '  USER_DEFINED1, USER_DEFINED2, PERIOD_NAME, PERIOD_START_DATE, ' ||
		  '  PERIOD_END_DATE, FORECAST_AMOUNT, UPSIDE_AMOUNT, QUOTA_AMOUNT, ' ||
		  'sr_inv_org_pk, sr_item_pk, sr_customer_pk, sr_sales_channel_pk, '||
		  'sr_sales_rep_pk, sr_ship_to_loc_pk, sr_user_defined1_pk, sr_user_defined2_pk, '||
		  '  creation_date, created_by, last_update_date, '||
		  '  last_updated_by, last_update_login ) '||
	        'select '''||p_instance_id ||
                  ''', NULL, inv_org, interest_type, ' ||
                  '  PRIMARY_INTEREST_CODE, SECONDARY_INTEREST_CODE, item, ' ||
                  '  CUSTOMER, SALES_CHANNEL, SALES_REP, SALES_GROUP, SHIP_TO_LOC, ' ||
                  '  USER_DEFINED1, USER_DEFINED2, PERIOD_NAME, nvl(PERIOD_START_DATE, sysdate), ' ||
                  '  nvl(PERIOD_END_DATE, sysdate), FORECAST_AMOUNT, UPSIDE_AMOUNT, QUOTA_AMOUNT, ' ||
                  'nvl(sr_inv_org_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_item_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_customer_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_sales_channel_pk,  msd_sr_util.get_null_pk), '||
                  'nvl(sr_sales_rep_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_ship_to_loc_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_user_defined1_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_user_defined2_pk, msd_sr_util.get_null_pk), '||
		  '  sysdate, '|| FND_GLOBAL.USER_ID || ', sysdate, ' ||
                  FND_GLOBAL.USER_ID ||', '|| FND_GLOBAL.USER_ID ||'  ' ||
		  ' from ' || p_source_table || ' where 1 = 1';


                 if p_from_date is not null and p_to_date is not null then
                        v_sql_stmt := v_sql_stmt ||
                        ' and (     (  to_date(nvl(period_start_date, trunc(sysdate)),''DD-MON-RRRR'') ' ||
                        '             between to_date(''' || to_char(p_from_date, 'dd-mon-yyyy') ||
                        '             '',''DD-MON-RRRR'') AND to_date(''' || to_char(p_to_date, 'dd-mon-yyyy') ||
                        '             '',''DD-MON-RRRR'') ' ||
                        '          ) ' ||
                        '      OR  ( to_date(nvl(period_end_date, trunc(sysdate)), ''DD-MON-RRRR'') ' ||
                        '             between to_date(''' || to_char(p_from_date, 'dd-mon-yyyy') ||
                        '             '',''DD-MON-RRRR'') AND to_date(''' || to_char(p_to_date, 'dd-mon-yyyy') ||
                        '             '',''DD-MON-RRRR'') ' ||
                        '          ) ' ||
                        '    ) ' ;

                elsif p_to_date is not null then
                        v_sql_stmt := v_sql_stmt ||
                        ' and to_date(nvl(period_end_date, trunc(sysdate)),''DD-MON-RRRR'') <= to_date(''' ||
                        to_char(p_to_date, 'dd-mon-yyyy') || ''',''DD-MON-RRRR'') ' ;
                elsif p_from_date is not null then
                        v_sql_stmt := v_sql_stmt ||
                        ' and to_date(nvl(period_start_date, trunc(sysdate)),''DD-MON-RRRR'') >= to_date(''' ||
                        to_char(p_from_date, 'dd-mon-yyyy') || ''',''DD-MON-RRRR'') ' ;
                end if ;

		 /* DWK. if the source is from staging table, then we shouldn't insert instance = '0'
		rows into fact table*/

		IF p_source_table = MSD_COMMON_UTILITIES.SALES_FCST_STAGING_TABLE then
			v_sql_stmt := v_sql_stmt || ' and nvl(instance,''888'') <> '||'''0''';
		END IF;


--	insert into msd_test values(v_sql_stmt) ;
	EXECUTE IMMEDIATE v_sql_stmt;

	retcode := 0;

	exception

	  when others then

		fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;
                raise;


End translate_sales_forecast ;



procedure translate_mfg_forecast(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_fcst_desg 	    IN  VARCHAR2,
                        p_new_refresh_num   IN  NUMBER,
                        p_delete_flag       IN  VARCHAR2) IS

v_instance_id    varchar2(40);
v_retcode	number;
v_sql_stmt       varchar2(4000);
v_bucket_sql    varchar2(200);
l_num1          number;
x_cs_id         number;

CURSOR get_cs_id(p_cs_name in VARCHAR2) IS
SELECT cs_definition_id
  FROM msd_cs_definitions
 WHERE name = p_cs_name;


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

        open get_cs_id('MSD_MANUFACTURING_FORECAST');
        fetch get_cs_id into x_cs_id;
        close get_cs_id;

        /* Check dest_table */
	IF p_dest_table =  MSD_COMMON_UTILITIES.MFG_FCST_STAGING_TABLE  THEN
            v_sql_stmt := ' DELETE FROM ' || p_dest_table ||
                          ' where instance =  ''' || p_instance_id || '''' ||
                          ' and forecast_designator = nvl(:p_fcst_desg, forecast_designator) ' ;


           /* OPM Comment By Rajesh Patangya   */
           if p_delete_flag = 'Y' then
              EXECUTE IMMEDIATE v_sql_stmt USING p_fcst_desg ;
           end if;


           v_bucket_sql := '  decode(BUCKET_TYPE, 1, 9, 2, 1, 3, 2, null) bucket_type, ';

           v_sql_stmt := 'INSERT INTO ' || p_dest_table ||
		  ' (instance, forecast_designator, prd_level_id, ITEM, INV_ORG, CUSTOMER, ' ||
		  '  SALES_CHANNEL, SHIP_TO_LOC, USER_DEFINED1, USER_DEFINED2, ' ||
		  '   BUCKET_TYPE, FORECAST_DATE, RATE_END_DATE, ' ||
		  '   ORIGINAL_QUANTITY, CURRENT_QUANTITY, ' ||
		  'sr_inv_org_pk, sr_item_pk, sr_customer_pk, sr_sales_channel_pk, '||
		  'sr_ship_to_loc_pk, sr_user_defined1_pk, sr_user_defined2_pk, '||
		  '  creation_date, created_by, last_update_date, '||
		  '  last_updated_by, last_update_login, sr_demand_class_pk ) '||
	          'SELECT '''||p_instance_id ||
                  ''', forecast_designator, prd_level_id, ITEM, INV_ORG, CUSTOMER, ' ||
                  '  SALES_CHANNEL, SHIP_TO_LOC, USER_DEFINED1, USER_DEFINED2, ' ||
                  v_bucket_sql ||
                  '  FORECAST_DATE, RATE_END_DATE, ' ||
                  '   ORIGINAL_QUANTITY, CURRENT_QUANTITY, ' ||
                  'nvl(sr_inv_org_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_item_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_customer_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_sales_channel_pk,  msd_sr_util.get_null_pk), '||
                  'nvl(sr_ship_to_loc_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_user_defined1_pk, msd_sr_util.get_null_pk), ' ||
                  'nvl(sr_user_defined2_pk, msd_sr_util.get_null_pk), '||
		  '  sysdate, '|| FND_GLOBAL.USER_ID || ', sysdate, ' ||
                   FND_GLOBAL.USER_ID ||', '|| FND_GLOBAL.USER_ID ||',  ' ||
                  'to_char(sr_demand_class_pk) ' ||
		  ' FROM ' || p_source_table ||
                  ' WHERE  forecast_designator = nvl(:p_fcst_desg, forecast_designator) ';

	ELSIF  p_dest_table = MSD_COMMON_UTILITIES.MFG_FCST_FACT_TABLE  THEN

           v_sql_stmt := ' UPDATE msd_mfg_forecast ' ||
			 ' SET	last_refresh_num = ' || p_new_refresh_num ||
			 ', Action_code = ' || '''D''' ||
 			 ' WHERE Action_code = ''I'' and instance = ' ||
                            p_instance_id || ' and forecast_designator = ' ||
                          ' nvl(:p_fcst_desg, forecast_designator) ' ;
            EXECUTE IMMEDIATE v_sql_stmt USING p_fcst_desg ;

           /* Delete Cs Data Headers */
           delete from msd_cs_data_headers
           where cs_definition_id = x_cs_id
           and instance = p_instance_id
           and cs_name = p_fcst_desg;


           v_sql_stmt := 'INSERT INTO ' || p_dest_table ||
		  ' ( instance, forecast_designator, prd_level_id, ITEM, INV_ORG, CUSTOMER, ' ||
		  '   SALES_CHANNEL, SHIP_TO_LOC, USER_DEFINED1, USER_DEFINED2, ' ||
		  '   BUCKET_TYPE, FORECAST_DATE, RATE_END_DATE, ' ||
		  '   ORIGINAL_QUANTITY, CURRENT_QUANTITY, ' ||
		  '   sr_inv_org_pk, sr_item_pk, sr_customer_pk, sr_sales_channel_pk, '||
		  '   sr_ship_to_loc_pk, sr_user_defined1_pk, sr_user_defined2_pk, '||
                  '   last_refresh_num, created_by_refresh_num, action_code, '||
		  '   creation_date, created_by, last_update_date, '||
		  '   last_updated_by, last_update_login, sr_demand_class_pk ) '||
	          'SELECT '''||p_instance_id ||
                  ''', forecast_designator, prd_level_id, ITEM, INV_ORG, CUSTOMER, ' ||
                  '  SALES_CHANNEL, SHIP_TO_LOC, USER_DEFINED1, USER_DEFINED2, ' ||
                  '  bucket_type, FORECAST_DATE, RATE_END_DATE, ' ||
                  '  ORIGINAL_QUANTITY, CURRENT_QUANTITY, ' ||
                  '  nvl(sr_inv_org_pk, msd_sr_util.get_null_pk), ' ||
                  '  nvl(sr_item_pk, msd_sr_util.get_null_pk), ' ||
                  '  nvl(sr_customer_pk, msd_sr_util.get_null_pk), ' ||
                  '  nvl(sr_sales_channel_pk,  msd_sr_util.get_null_pk), '||
                  '  nvl(sr_ship_to_loc_pk, msd_sr_util.get_null_pk), ' ||
                  '  nvl(sr_user_defined1_pk, msd_sr_util.get_null_pk), ' ||
                  '  nvl(sr_user_defined2_pk, msd_sr_util.get_null_pk), '||
                     p_new_refresh_num || ', ' || p_new_refresh_num || ', '|| '''I''' ||
		  ', sysdate, '|| FND_GLOBAL.USER_ID || ', sysdate, ' ||
                     FND_GLOBAL.USER_ID ||', '|| FND_GLOBAL.USER_ID ||',  ' ||
                  '  to_char(sr_demand_class_pk) ' ||
		  ' FROM ' || p_source_table ||
		  ' WHERE  forecast_designator = nvl(:p_fcst_desg, forecast_designator) ';

                 /* DWK. if the source is from staging table, then we shouldn't insert instance = '0'
		    rows into fact table*/
                 IF p_source_table = MSD_COMMON_UTILITIES.MFG_FCST_STAGING_TABLE then
                    v_sql_stmt := v_sql_stmt || ' and nvl(instance,''888'') <> '||'''0''';
                 END IF;

        END IF;

        EXECUTE IMMEDIATE v_sql_stmt USING p_fcst_desg ;

        if (p_dest_table = MSD_COMMON_UTILITIES.MFG_FCST_FACT_TABLE) then
         INSERT INTO msd_cs_data_headers (
	   	CS_DATA_HEADER_ID,
         	INSTANCE,
		CS_DEFINITION_ID,
		CS_NAME,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
    		LAST_UPDATE_LOGIN,
                LAST_REFRESH_NUM
	   )
       VALUES (	msd_cs_data_headers_s.nextval,
		p_instance_id,
		x_cs_id,
		p_fcst_desg,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		fnd_global.login_id,
                p_new_refresh_num
     	);
       end if;

        retcode := 0;

EXCEPTION
   when others then
      fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
      errbuf := substr(SQLERRM,1,150);
      retcode := -1 ;
      raise;

End translate_mfg_forecast ;


procedure translate_pricing_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_price_list        IN  VARCHAR2,
                        p_new_refresh_num   IN  NUMBER) IS

v_instance_id    varchar2(40);
v_dblink         varchar2(128);
v_retcode        number;
v_sql_stmt       varchar2(4000);
Begin


        /**************************************************
        -       1. Get the instance id from MSC_APP_INSTANCE
        -       2. Get the Profile Value for MSD_DIRECT_LOAD
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

        /* Check dest_table */
        IF p_dest_table =  MSD_COMMON_UTILITIES.PRICING_STAGING_TABLE  THEN
            v_sql_stmt := 'DELETE FROM ' || p_dest_table  ||
                          ' where  instance = ''' || p_instance_id || '''' ||
                          ' and price_list_name  like nvl(:p_price_list, price_list_name) ';
            EXECUTE IMMEDIATE v_sql_stmt USING p_price_list;

            v_sql_stmt :=
                'INSERT INTO ' || p_dest_table ||
                ' (          INSTANCE,                                 ' ||
                '            ORGANIZATION_LVL_ID, SR_ORGANIZATION_LVL_PK, ' ||
                '            PRODUCT_LVL_ID,      SR_PRODUCT_LVL_PK,      ' ||
                '            SALESCHANNEL_LVL_ID, SR_SALESCHANNEL_LVL_PK, ' ||
                '            SALES_REP_LVL_ID,    SR_SALES_REP_LVL_PK,    ' ||
                '            GEOGRAPHY_LVL_ID,    SR_GEOGRAPHY_LVL_PK,    ' ||
                '            USER_DEFINED1_LVL_ID,SR_USER_DEFINED1_LVL_PK,' ||
                '            USER_DEFINED2_LVL_ID,SR_USER_DEFINED2_LVL_PK,' ||
                '            DEMAND_CLASS_LVL_ID, SR_DEMAND_CLASS_LVL_PK,' ||
                '            PRICE_LIST_NAME, START_DATE, END_DATE,    ' ||
                '            PRICE, PRIORITY,                          ' ||
                '            PRIMARY_UOM_FLAG, PRICE_LIST_UOM,         ' ||
                '            CREATION_DATE, CREATED_BY,                ' ||
                '            LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)  ' ||
                'SELECT ''' || p_instance_id ||
                ''',         nvl(ORGANIZATION_LVL_ID, 29) , nvl(SR_ORGANIZATION_LVL_PK,msd_sr_util.get_all_org_pk), ' ||
                '            nvl(PRODUCT_LVL_ID, 28) ,      nvl(SR_PRODUCT_LVL_PK,msd_sr_util.get_all_prd_pk),      ' ||
                '            nvl(SALESCHANNEL_LVL_ID, 33) ,  nvl(SR_SALESCHANNEL_LVL_PK,msd_sr_util.get_all_scs_pk), ' ||
                '            nvl(SALES_REP_LVL_ID, 32) ,    nvl(SR_SALES_REP_LVL_PK,msd_sr_util.get_all_rep_pk),    ' ||
                '            nvl(GEOGRAPHY_LVL_ID, 30) ,     nvl(SR_GEOGRAPHY_LVL_PK,msd_sr_util.get_all_geo_pk),    ' ||
                '            USER_DEFINED1_LVL_ID,nvl(SR_USER_DEFINED1_LVL_PK,msd_sr_util.get_null_pk),' ||
                '            USER_DEFINED2_LVL_ID,nvl(SR_USER_DEFINED2_LVL_PK,msd_sr_util.get_null_pk),' ||
                '            nvl(DEMAND_CLASS_LVL_ID, 40),  nvl(SR_DEMAND_CLASS_LVL_PK,msd_sr_util.get_null_pk),' ||
                '            PRICE_LIST_NAME, START_DATE, END_DATE,    ' ||
                '            PRICE, PRIORITY,                          ' ||
                '            PRIMARY_UOM_FLAG, PRICE_LIST_UOM,         ' ||
                '            SYSDATE,'|| FND_GLOBAL.USER_ID || ', '      ||
                '            SYSDATE,'|| FND_GLOBAL.USER_ID || ', '|| FND_GLOBAL.USER_ID ||' '||
                'FROM ' || p_source_table || '   ' ||
                'WHERE PRICE_LIST_NAME  like NVL(:p_price_list, PRICE_LIST_NAME) ';

        ELSIF  p_dest_table = MSD_COMMON_UTILITIES.PRICING_FACT_TABLE THEN
            IF (p_price_list is not NULL) THEN
               UPDATE msd_price_list
               SET  Action_code = 'D', last_refresh_num =  p_new_refresh_num
               WHERE Action_code = 'I' and instance = p_instance_id and
                     price_list_name like p_price_list;
            ELSE
               UPDATE msd_price_list
               SET  Action_code = 'D', last_refresh_num =  p_new_refresh_num
               WHERE Action_code = 'I' and instance = p_instance_id;

            END IF;

            v_sql_stmt :=
                'INSERT INTO ' || p_dest_table ||
                ' (          INSTANCE,                                 ' ||
                '            ORGANIZATION_LVL_ID, SR_ORGANIZATION_LVL_PK, ' ||
                '            PRODUCT_LVL_ID,      SR_PRODUCT_LVL_PK,      ' ||
                '            SALESCHANNEL_LVL_ID, SR_SALESCHANNEL_LVL_PK, ' ||
                '            SALES_REP_LVL_ID,    SR_SALES_REP_LVL_PK,    ' ||
                '            GEOGRAPHY_LVL_ID,    SR_GEOGRAPHY_LVL_PK,    ' ||
                '            USER_DEFINED1_LVL_ID,SR_USER_DEFINED1_LVL_PK,' ||
                '            USER_DEFINED2_LVL_ID,SR_USER_DEFINED2_LVL_PK,' ||
                '            DEMAND_CLASS_LVL_ID, SR_DEMAND_CLASS_LVL_PK,' ||
                '            PRICE_LIST_NAME, START_DATE, END_DATE,    ' ||
                '            PRICE, PRIORITY,                          ' ||
                '            last_refresh_num, created_by_refresh_num, action_code, '||
                '            CREATION_DATE, CREATED_BY,                ' ||
                '            LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)  ' ||
                'SELECT ''' || p_instance_id ||
                ''',         nvl(ORGANIZATION_LVL_ID, 29) , nvl(SR_ORGANIZATION_LVL_PK,msd_sr_util.get_all_org_pk), ' ||
                '            nvl(PRODUCT_LVL_ID, 28) ,      nvl(SR_PRODUCT_LVL_PK,msd_sr_util.get_all_prd_pk),      ' ||
                '            nvl(SALESCHANNEL_LVL_ID, 33) , nvl(SR_SALESCHANNEL_LVL_PK,msd_sr_util.get_all_scs_pk), ' ||
                '            nvl(SALES_REP_LVL_ID, 32) ,    nvl(SR_SALES_REP_LVL_PK,msd_sr_util.get_all_rep_pk),    ' ||
                '            nvl(GEOGRAPHY_LVL_ID, 30) ,    nvl(SR_GEOGRAPHY_LVL_PK,msd_sr_util.get_all_geo_pk),    ' ||
                '            USER_DEFINED1_LVL_ID,nvl(SR_USER_DEFINED1_LVL_PK,msd_sr_util.get_null_pk),' ||
                '            USER_DEFINED2_LVL_ID,nvl(SR_USER_DEFINED2_LVL_PK,msd_sr_util.get_null_pk),' ||
                '            nvl(DEMAND_CLASS_LVL_ID, 40) , nvl(SR_DEMAND_CLASS_LVL_PK,msd_sr_util.get_all_geo_pk), ' ||
                '            PRICE_LIST_NAME, START_DATE, END_DATE,    ' ||
                '            PRICE, PRIORITY,                          ' ||
                             p_new_refresh_num || ', ' || p_new_refresh_num || ', '|| '''I''' || ', ' ||
                '            SYSDATE,'|| FND_GLOBAL.USER_ID || ', '      ||
                '            SYSDATE,'|| FND_GLOBAL.USER_ID || ', '|| FND_GLOBAL.USER_ID ||' '||
                'FROM ' || p_source_table || '   ' ||
                'WHERE PRICE_LIST_NAME  like NVL(:p_price_list, PRICE_LIST_NAME) ';
                /* DWK. if the source is from staging table, then we shouldn't insert instance = '0'
		rows into fact table*/
                IF p_source_table = MSD_COMMON_UTILITIES.PRICING_STAGING_TABLE then
                   v_sql_stmt := v_sql_stmt || ' and nvl(instance,''888'') <> '||'''0''';
                END IF;
        END IF;

        EXECUTE IMMEDIATE v_sql_stmt USING p_price_list;

        retcode := 0;

exception

          when others then

		fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;
                raise;

End translate_pricing_data ;



/******************* PROCEDURE *************************************************/
/* The mfg_post_process first populate calendar dates into msd_st_time table with
   given instance.  This populate_calendar_date procedure only populates working
   dates according to the calendar. We split raw entity by inserting all the sub
   entities into msd_mfg_forecast talbe and delete the original raw entity from
   that table.  When we insert sub entities into msd_mfg_forecast table, we join
   this table with msd_st_time table and only select days which is in between
   forecast_date and rate_end_date of individual raw entity.  This INSERT
   statement contains 3 SELECT statement according to raw entities bucket_type.
   We connect the results with UNION.  Only one SELECT statement will be
   executed due to different bucket_type condition.
   Once we insert all sub entity, we delte all raw entities, and delete
   all calendar dates we populated at the beginning.

   1) mfg_post_process will UPDATE the following rows
   -----------------------------------------------------------
   BUCKET_TYPE       ACTION
   -----------------------------------------------------------
   DAY               NONE
   WEEK              YES only if rate_end_date is NULL
   MONTH             YES only if rate_end_date is NULL

   2) mfg_post_process will EXPLODE the following rows
   -----------------------------------------------------------
   BUCKET_TYPE       ACTION
   -----------------------------------------------------------
   DAY               YES only if rate_end_date IS NOT NULL and
                                 rate_end_date <> forecast_date.
   WEEK              YES only if rate_end_date IS NOT NULL.
   MONTH             YES only if rate_end_date IS NOT NULL.

   3) mfg_post_process will DELETE the following rows
   -----------------------------------------------------------
   BUCKET_TYPE       ACTION
   -----------------------------------------------------------
   DAY               YES rate_end_date IS NOT NULL and
                         rate_end_date <> forecast_date
   WEEK              YES rate_end_date IS NOT NULL
   MONTH             YES rate_end_date IS NOT NULL
*/
PROCEDURE mfg_post_process( errbuf              OUT NOCOPY VARCHAR2,
                            retcode             OUT NOCOPY VARCHAR2,
			    p_instance          IN  VARCHAR2,
			    p_designator        IN  VARCHAR2,
                            p_new_refresh_num   IN  NUMBER) IS
   p_min_date    DATE;
   p_max_date    DATE;
   p_org_id      Varchar2(40);
   p_dblink      Varchar2(20);
   p_cal_code    Varchar2(30);
   p_str	 Varchar2(5000);

   l_count       NUMBER := 0;

   l_day_a       NUMBER;
   l_day_b       NUMBER;
   l_week_a      NUMBER;
   l_week_b      NUMBER;
   l_month_a     NUMBER;
   l_month_b     NUMBER;


/* DWK Test */
   a_FORECAST_DESIGNATOR    a_forecast_designator_type;
   a_ITEM                   a_item_type;
   a_INV_ORG                a_inv_org_type;
   a_CUSTOMER               a_customer_type;
   a_SALES_CHANNEL          a_sales_channel_type;
   a_SHIP_TO_LOC            a_ship_to_loc_type;
   a_USER_DEFINED1          a_user_defined1_type;
   a_USER_DEFINED2          a_user_defined2_type;
   a_BUCKET_TYPE            a_bucket_type_type;
   a_FORECAST_DATE          a_forecast_date_type;
   a_RATE_END_DATE          a_rate_end_date_type;
   a_ORIGINAL_QUANTITY      a_original_quantity_type;
   a_CURRENT_QUANTITY       a_current_quantity_type;
   a_sr_inv_org_pk          a_sr_inv_org_pk_type;
   a_sr_item_pk             a_sr_item_pk_type;
   a_sr_customer_pk         a_sr_customer_pk_type;
   a_sr_sales_channel_pk    a_sr_sales_channel_pk_type;
   a_sr_ship_to_loc_pk      a_sr_ship_to_loc_pk_type;
   a_sr_user_defined1_pk    a_sr_user_defined1_pk_type;
   a_sr_user_defined2_pk    a_sr_user_defined2_pk_type;
   a_sr_demand_class_pk     a_sr_user_defined2_pk_type;
   a_prd_level_id           a_prd_level_id_type;



/* DWK For the performance tunning */
   p_temp_start_date  DATE;
   p_temp_end_date    DATE;

   CURSOR c_temp_end_date IS
   select month_end_date from msd_st_time
   where instance = '-999' and day <= p_temp_end_date
   order by day desc;


BEGIN
   /* Select min and max date for the forecast_date
      and rate_end_date. This will reduce the number of
      dates populate_calendar_dates will populate */

   SELECT min(forecast_date), max( nvl(rate_end_date, forecast_date)) INTO p_min_date, p_max_date
   FROM msd_mfg_forecast
   WHERE instance = p_instance AND
         created_by_refresh_num = p_new_refresh_num AND
         forecast_designator = nvl(p_designator,forecast_designator);

/************************** Update forecast_date *********************************/

   /* First, Update forecast_date to bucket_end_date only if, it has NULL
      for rate_end_date.  Since we are not exploding any rows with NULL
      value in rate_end_date, we have to update forecast_date separately */

   /* First check if there is any row to be updated or not */
   select count(*) into l_count
   from msd_mfg_forecast
   where rate_end_date is null and
         bucket_type = '1' and
         instance = p_instance  and
         forecast_designator = nvl(p_designator, forecast_designator) and
         created_by_refresh_num = p_new_refresh_num and
         rownum < 2;


   IF (l_count > 0) THEN
      p_str :=    'UPDATE msd_mfg_forecast f ' ||
 		' SET  forecast_date = ' ||
                 ' nvl((SELECT t.week_end_date FROM msd_st_time t ' ||
                 '      WHERE  f.forecast_date = t.day and t.instance = '||
                 ''''|| -999 ||'''' ||'), f.forecast_date)
		WHERE f.rate_end_date is NULL and
			f.bucket_type = ' || '''' || 1 ||''''|| ' and
                        f.created_by_refresh_num = ' || p_new_refresh_num || ' and
 			f.instance = ' || ''''||p_instance ||'''' ||
                        ' and f.forecast_designator = nvl(:p_designator, f.forecast_designator) ';
       EXECUTE IMMEDIATE p_str USING p_designator ;

   END IF;

   /* First check if there is any row to be updated or not */
   select count(*) into l_count
   from msd_mfg_forecast
   where rate_end_date is null and
         bucket_type = '2' and
         instance = p_instance and
         forecast_designator = nvl(p_designator, forecast_designator) and
         rownum < 2;

   IF (l_count > 0) THEN
      /* Monthly Bucket */
       p_str :=  ' UPDATE msd_mfg_forecast f ' ||
 		' SET  forecast_date = ' ||
                 '       nvl((SELECT t.month_end_date FROM msd_st_time t
 			     WHERE  f.forecast_date = t.day and t.instance = '||
                              '''' || -999 ||'''' ||'), f.forecast_date)
		WHERE f.rate_end_date is NULL and
			f.bucket_type = ' || '''' || 2 ||''''|| ' and
                        f.created_by_refresh_num = ' || p_new_refresh_num || ' and
 			f.instance = ' || ''''||p_instance ||'''' ||
                       ' and f.forecast_designator = nvl(:p_designator,f.forecast_designator) ';

      EXECUTE IMMEDIATE p_str USING p_designator;
   END IF;

/******************************* Insert ****************************************/

   /* Find If there is any row needs to be exploded with Daily bucket.
      If so, delete those rows from fact table and cache them into arrary */

   DELETE FROM msd_mfg_forecast
   WHERE instance = p_instance AND
         forecast_designator = nvl(p_designator,forecast_designator) AND
         bucket_type = C_DAILY_BUCKET AND
         created_by_refresh_num = p_new_refresh_num AND
         forecast_date <> nvl(rate_end_date, forecast_date)
   RETURNING
         FORECAST_DESIGNATOR, PRD_LEVEL_ID, ITEM, INV_ORG, CUSTOMER,
         SALES_CHANNEL, SHIP_TO_LOC, USER_DEFINED1, USER_DEFINED2,
         BUCKET_TYPE, FORECAST_DATE, RATE_END_DATE,
         ORIGINAL_QUANTITY, CURRENT_QUANTITY,
         sr_inv_org_pk, sr_item_pk, sr_customer_pk, sr_sales_channel_pk,
         sr_ship_to_loc_pk, sr_user_defined1_pk, sr_user_defined2_pk,
         sr_demand_class_pk
   BULK COLLECT INTO
         a_FORECAST_DESIGNATOR, a_prd_level_id, a_ITEM, a_INV_ORG, a_CUSTOMER,
         a_SALES_CHANNEL, a_SHIP_TO_LOC, a_USER_DEFINED1, a_USER_DEFINED2,
         a_BUCKET_TYPE, a_FORECAST_DATE, a_RATE_END_DATE,
         a_ORIGINAL_QUANTITY, a_CURRENT_QUANTITY,
         a_sr_inv_org_pk, a_sr_item_pk, a_sr_customer_pk, a_sr_sales_channel_pk,
         a_sr_ship_to_loc_pk, a_sr_user_defined1_pk, a_sr_user_defined2_pk,
         a_sr_demand_class_pk;

   /* Bulk INSERT cached rows with explosion, For Daily Bucket */
   IF (a_sr_item_pk.exists(1)) THEN
      FORALL i IN a_sr_item_pk.FIRST..a_sr_item_pk.LAST
         INSERT INTO msd_mfg_forecast(instance, forecast_designator, bucket_type,
		 	forecast_date, rate_end_date, original_quantity,
			current_quantity, creation_date, created_by,
			last_update_date, last_updated_by, last_update_login,
			sr_inv_org_pk, prd_level_id, sr_item_pk, sr_customer_pk,
			sr_sales_channel_pk, sr_ship_to_loc_pk,
			sr_user_defined1_pk, sr_user_defined2_pk,
                        sr_demand_class_pk,
                        created_by_refresh_num, last_refresh_num, action_code)
         SELECT p_instance, a_forecast_designator(i), a_bucket_type(i),
	        t.day, NULL, a_original_quantity(i),
		a_current_quantity(i), SYSDATE, FND_GLOBAL.USER_ID,
		SYSDATE, FND_GLOBAL.USER_ID, fnd_global.login_id,
		a_sr_inv_org_pk(i), a_prd_level_id(i), a_sr_item_pk(i), a_sr_customer_pk(i),
		a_sr_sales_channel_pk(i), a_sr_ship_to_loc_pk(i),
		a_sr_user_defined1_pk(i), a_sr_user_defined2_pk(i),
                a_sr_demand_class_pk(i),
                p_new_refresh_num, p_new_refresh_num, 'I'
         FROM
                msd_st_time t
         WHERE
                t.day between a_forecast_date(i) and a_rate_end_date(i) and
                t.instance = '-999';

   END IF;



   /* Weekly Bucket */
   /* Find If there is any row needs to be exploded with Weekly bucket.
      If so, delete those rows from fact table and cache them into arrary */
   /* Also, rate_end_date can equal to forecast_date
      since we already update it */
   DELETE FROM msd_mfg_forecast
   WHERE instance = p_instance AND
         forecast_designator = nvl(p_designator,forecast_designator) AND
         bucket_type = C_WEEKLY_BUCKET AND
         created_by_refresh_num = p_new_refresh_num AND
         rate_end_date IS NOT NULL
   RETURNING
         FORECAST_DESIGNATOR, ITEM, INV_ORG, CUSTOMER,
         SALES_CHANNEL, SHIP_TO_LOC, USER_DEFINED1, USER_DEFINED2,
         BUCKET_TYPE, FORECAST_DATE, RATE_END_DATE,
         ORIGINAL_QUANTITY, CURRENT_QUANTITY,
         sr_inv_org_pk, prd_level_id, sr_item_pk, sr_customer_pk, sr_sales_channel_pk,
         sr_ship_to_loc_pk, sr_user_defined1_pk, sr_user_defined2_pk,
         sr_demand_class_pk
   BULK COLLECT INTO
         a_FORECAST_DESIGNATOR, a_ITEM, a_INV_ORG, a_CUSTOMER,
         a_SALES_CHANNEL, a_SHIP_TO_LOC, a_USER_DEFINED1, a_USER_DEFINED2,
         a_BUCKET_TYPE, a_FORECAST_DATE, a_RATE_END_DATE,
         a_ORIGINAL_QUANTITY, a_CURRENT_QUANTITY,
         a_sr_inv_org_pk, a_prd_level_id, a_sr_item_pk, a_sr_customer_pk, a_sr_sales_channel_pk,
         a_sr_ship_to_loc_pk, a_sr_user_defined1_pk, a_sr_user_defined2_pk,
         a_sr_demand_class_pk;

   /* Bulk INSERT cached rows with explosion, For Weekly Bucket */
   IF (a_sr_item_pk.exists(1)) THEN
      FORALL i IN a_sr_item_pk.FIRST..a_sr_item_pk.LAST
         INSERT INTO msd_mfg_forecast(instance, forecast_designator, bucket_type,
		 	forecast_date, rate_end_date, original_quantity,
			current_quantity, creation_date, created_by,
			last_update_date, last_updated_by, last_update_login,
			sr_inv_org_pk, prd_level_id, sr_item_pk, sr_customer_pk,
			sr_sales_channel_pk, sr_ship_to_loc_pk,
			sr_user_defined1_pk, sr_user_defined2_pk,
                        sr_demand_class_pk,
                        created_by_refresh_num, last_refresh_num, action_code)
         SELECT p_instance, a_forecast_designator(i), a_bucket_type(i),
	        t.week_end_date, NULL, a_original_quantity(i),
		a_current_quantity(i), SYSDATE, FND_GLOBAL.USER_ID,
		SYSDATE, FND_GLOBAL.USER_ID, fnd_global.login_id,
		a_sr_inv_org_pk(i), a_prd_level_id(i), a_sr_item_pk(i), a_sr_customer_pk(i),
		a_sr_sales_channel_pk(i), a_sr_ship_to_loc_pk(i),
		a_sr_user_defined1_pk(i), a_sr_user_defined2_pk(i),
                a_sr_demand_class_pk(i),
                p_new_refresh_num, p_new_refresh_num, 'I'
         FROM
  	       (select distinct week_start_date,  week_end_date
                from msd_st_time
	        where instance = '-999') t
         WHERE
                t.week_start_date between a_forecast_date(i) and a_rate_end_date(i) or t.week_end_date between a_forecast_date(i) and a_rate_end_date(i);
   END IF;



   /* Monthly Bucket */
   /* Find If there is any row needs to be exploded with Monthly bucket.
      If so, delete those rows from fact table and cache them into arrary */
   /* Also, rate_end_date can equal to forecast_date
      since we already update it */
   DELETE FROM msd_mfg_forecast
   WHERE instance = p_instance AND
         forecast_designator = nvl(p_designator,forecast_designator) AND
         bucket_type = C_MONTHLY_BUCKET AND
         created_by_refresh_num = p_new_refresh_num AND
         rate_end_date IS NOT NULL
   RETURNING
         FORECAST_DESIGNATOR, ITEM, INV_ORG, CUSTOMER,
         SALES_CHANNEL, SHIP_TO_LOC, USER_DEFINED1, USER_DEFINED2,
         BUCKET_TYPE, FORECAST_DATE, RATE_END_DATE,
         ORIGINAL_QUANTITY, CURRENT_QUANTITY,
         sr_inv_org_pk, prd_level_id, sr_item_pk, sr_customer_pk, sr_sales_channel_pk,
         sr_ship_to_loc_pk, sr_user_defined1_pk, sr_user_defined2_pk,
         sr_demand_class_pk
   BULK COLLECT INTO
         a_FORECAST_DESIGNATOR, a_ITEM, a_INV_ORG, a_CUSTOMER,
         a_SALES_CHANNEL, a_SHIP_TO_LOC, a_USER_DEFINED1, a_USER_DEFINED2,
         a_BUCKET_TYPE, a_FORECAST_DATE, a_RATE_END_DATE,
         a_ORIGINAL_QUANTITY, a_CURRENT_QUANTITY,
         a_sr_inv_org_pk, a_prd_level_id, a_sr_item_pk, a_sr_customer_pk, a_sr_sales_channel_pk,
         a_sr_ship_to_loc_pk, a_sr_user_defined1_pk, a_sr_user_defined2_pk,
         a_sr_demand_class_pk;

   /* Bulk INSERT cached rows with explosion, For Monthly Bucket */
   IF (a_sr_item_pk.exists(1)) THEN
      FORALL i IN a_sr_item_pk.FIRST..a_sr_item_pk.LAST
         INSERT INTO msd_mfg_forecast(instance, forecast_designator, bucket_type,
		 	forecast_date, rate_end_date, original_quantity,
			current_quantity, creation_date, created_by,
			last_update_date, last_updated_by, last_update_login,
			sr_inv_org_pk, prd_level_id, sr_item_pk, sr_customer_pk,
			sr_sales_channel_pk, sr_ship_to_loc_pk,
			sr_user_defined1_pk, sr_user_defined2_pk,
                        sr_demand_class_pk,
                        created_by_refresh_num, last_refresh_num, action_code)
         SELECT p_instance, a_forecast_designator(i), a_bucket_type(i),
	        t.month_end_date, NULL, a_original_quantity(i),
		a_current_quantity(i), SYSDATE, FND_GLOBAL.USER_ID,
		SYSDATE, FND_GLOBAL.USER_ID, fnd_global.login_id,
		a_sr_inv_org_pk(i), a_prd_level_id(i), a_sr_item_pk(i), a_sr_customer_pk(i),
		a_sr_sales_channel_pk(i), a_sr_ship_to_loc_pk(i),
		a_sr_user_defined1_pk(i), a_sr_user_defined2_pk(i),
                a_sr_demand_class_pk(i),
                p_new_refresh_num, p_new_refresh_num, 'I'
         FROM
               (select distinct month_start_date, month_end_date
                from msd_st_time
	        where instance = '-999') t
         WHERE
                t.month_start_date between a_forecast_date(i) and a_rate_end_date(i);
   END IF;

     /* Bug 4729883 - Bring Weekly Manufacturing Forecast as Daily.
      For All rows with Bucket Type = 1 (weekly), set Bucket Type to 9 (daily) */
      update msd_mfg_forecast
      set bucket_type = C_DAILY_BUCKET
      WHERE instance = p_instance AND
      forecast_designator = nvl(p_designator,forecast_designator) AND
      bucket_type = C_WEEKLY_BUCKET AND
      created_by_refresh_num = p_new_refresh_num;

exception

   WHEN others THEN
      fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
      errbuf := substr(SQLERRM,1,150);
      retcode := -1 ;
      raise;

END MFG_POST_PROCESS;


/************************************ PROCEDURE ****************************************/
/* This procedure will populate all the working dates into msd_st_time table.
   From msd_sr_mfg_time_v,
   In WHERE clause, the condition, bcd.seq_num IS NOT NULL, guaranteed the we
   only insert working date into the table, since holiday and weekends will have
   NULL for seq_num.
*/
PROCEDURE populate_calendar_dates(p_cal_code   VARCHAR2,
				  p_min_date   DATE,
				  p_max_date   DATE,
				  p_dblink     VARCHAR2 ) IS

   p_cal_type    NUMBER;
   p_str         VARCHAR2(4000);

BEGIN
   p_cal_type := 10;

   p_str :=    'INSERT INTO msd_st_time(instance, calendar_code,
			calendar_type,seq_num, month_start_date,
			month_end_date, week_start_date,
			week_end_date, day,last_update_date,
			last_updated_by, creation_date, created_by,
			last_update_login)
                SELECT ' || '''-999''' || ', calendar_code, 1,
			seq_num, month_start_date,month_end_date, week_start_date, week_end_date, day,
			SYSDATE, FND_GLOBAL.USER_ID, SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID
                FROM    msd_sr_mfg_time_v' || p_dblink ||
              ' WHERE  seq_num <> -1 and calendar_code = :p_cal_code '||
                        ' AND day BETWEEN :p_min_date AND :p_max_date ';

   EXECUTE IMMEDIATE p_str USING p_cal_code, p_min_date, p_max_date;

exception
   WHEN others THEN
         fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
         raise;

END populate_calendar_dates;



/************************************ Procedure ****************************************/
PROCEDURE populate_calendar(	errbuf              OUT NOCOPY VARCHAR2,
				retcode             OUT NOCOPY VARCHAR2,
				p_instance          IN  VARCHAR2,
                                p_new_refresh_num   IN  NUMBER,
				p_table_name        IN  VARCHAR2) IS

  /* DWK  To Populate calendar */
   l_min_date    DATE;
   l_max_date    DATE;
   l_org_id      Varchar2(40);
   l_dblink      Varchar2(20);
   l_cal_code    Varchar2(30);
   l_str	 Varchar2(5000);

   l_where      NUMBER;


BEGIN

   /* Popoulate Calendar per INSTANCE. This will
   reduce the number of populating calendar for the same
   instance, but different forecast_designator */

   /* Select min and max date for the forecast_date and rate_end_date. */
   l_str := 'SELECT min(forecast_date), max( nvl(rate_end_date, forecast_date))'||
	    ' FROM '||p_table_name|| ' WHERE instance = '||''''||p_instance||'''';

   IF ( p_table_name = MSD_COMMON_UTILITIES.MFG_FCST_FACT_TABLE) THEN
      l_str := l_str || ' and  created_by_refresh_num = ' || p_new_refresh_num;
   END IF;
   EXECUTE IMMEDIATE l_str INTO l_min_date, l_max_date;

--fnd_file.put_line(fnd_file.log, l_min_date || '   ' || l_max_date );

   -- Get Database Link
   msd_common_utilities.get_db_link(p_instance, l_dblink, retcode);

   -- Get Master OrganizationID
   l_str := 'SELECT parameter_value FROM msd_setup_parameters'||
	l_dblink || ' WHERE parameter_name = '|| '''MSD_MASTER_ORG''';
	l_where := 1;
   EXECUTE IMMEDIATE l_str INTO l_org_id;

   -- Get Calendar Code
   l_str := 'SELECT calendar_code FROM mtl_parameters' ||
	l_dblink || ' WHERE organization_id = :l_org_id ';
	l_where := 2;
    EXECUTE IMMEDIATE l_str INTO l_cal_code USING l_org_id;

   /* DWK Delete existing calendar before populating the current one */
   DELETE msd_st_time WHERE instance = '-999';

   /* Populate calendar dates. We will delete all these data
     after we finish exploiting entities */
   populate_calendar_dates(l_cal_code, l_min_date, l_max_date, l_dblink);

EXCEPTION
	   WHEN no_data_found THEN
		IF (l_where = 1 ) THEN
		   fnd_file.put_line(fnd_file.log, 'Master ORG has not been defined for instance_id : '
                                                   || p_instance );
		   errbuf := 'Master ORG has not been defined for instance_id : '|| p_instance;
		ELSIF (l_where = 2) THEN
		   fnd_file.put_line(fnd_file.log, 'A calendar has not been defined ' ||
                               'for master org ' || l_org_id ||' for instance_id : ' || p_instance);
		   errbuf := 'A calendar has not been defined for master org';
		END IF;
		fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                raise;
	   WHEN OTHERS THEN
		fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		errbuf := substr(SQLERRM,1,150);
		retcode := -1;
                raise;

END populate_calendar;

/************************************ FUNCTION ****************************************/
FUNCTION Is_Post_Process_Required(	errbuf              OUT NOCOPY VARCHAR2,
					retcode             OUT NOCOPY VARCHAR2,
					p_instance          IN  VARCHAR2,
					p_designator        IN  VARCHAR2 ) return BOOLEAN Is


CURSOR c_instance_info IS
   SELECT instance_type FROM msc_apps_instances
   WHERE to_char(instance_id) = p_instance;

   l_instance_type      NUMBER(2);
   l_is_required        BOOLEAN := TRUE;
   l_count              NUMBER := 0;

BEGIN

   OPEN c_instance_info;
      FETCH c_instance_info INTO l_instance_type;
      /* IF no instance info is found */
      IF ( (c_instance_info%NOTFOUND) OR (l_instance_type = NULL) ) THEN
         l_is_required := FALSE;
      /* Instance Info is found, but type is OTHERS */
      ELSIF ( l_instance_type = 3 ) THEN
         l_is_required := FALSE;
      END IF;
   CLOSE c_instance_info;

   /* Check whether there is anything to explode or not */
   SELECT count(*) INTO l_count FROM msd_mfg_forecast
   WHERE  instance = p_instance AND
          forecast_designator = nvl(p_designator,forecast_designator) AND
          (bucket_type <> C_DAILY_BUCKET OR
	   forecast_date <> nvl(rate_end_date, forecast_date)) and
-- VM created_by_refresh .....
          rownum < 2;

   IF (l_count = 0) THEN
      l_is_required := FALSE;
   END IF;

   return l_is_required;

EXCEPTION
	when others then
	   fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
	   errbuf := substr(SQLERRM,1,150);
	   retcode := -1;
	   return NULL;
END;


PROCEDURE CLEAN_FACT_DATA(	errbuf              OUT NOCOPY VARCHAR2,
				retcode             OUT NOCOPY VARCHAR2,
		                p_table_name        IN  VARCHAR2) IS


l_least_refresh_num   NUMBER := 0;
l_sql_stmt            varchar2(4000);

BEGIN

   /* Find the least refresh number for existing demand plan */
   SELECT nvl(min(scn_build_refresh_num), 0) INTO l_least_refresh_num
   FROM msd_dp_parameters;


   l_sql_stmt := ' DELETE FROM ' || p_table_name ||
                 ' WHERE ACTION_CODE = ' || '''D''' ||
                 ' and LAST_REFRESH_NUM <= ' || l_least_refresh_num;

   EXECUTE IMMEDIATE l_sql_stmt;


EXCEPTION
	when others then
	   fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
	   errbuf := substr(SQLERRM,1,150);
	   retcode := -1;
           raise;

END CLEAN_FACT_DATA;

PROCEDURE populate_cs_data_header(p_instance in number,
                                  p_name IN VARCHAR2,
                                  p_ref_num in number) is

cursor get_cs_id is
select cs_definition_id
  from msd_cs_definitions
 where name = p_name;

x_cs_id number;

begin

open get_cs_id;
fetch get_cs_id into x_cs_id;
close get_cs_id;

if (x_cs_id is not null) then

  insert into msd_cs_data_headers
	(	cs_data_header_id,
		instance,
		cs_definition_id,
		cs_name,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
                last_refresh_num
	)
         select	msd_cs_data_headers_s.nextval,
		p_instance,
	        x_cs_id,
		'SINGLE_STREAM',
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		fnd_global.login_id,
                p_ref_num from dual;

end if;

end populate_cs_data_header;








END MSD_TRANSLATE_FACT_DATA;

/
