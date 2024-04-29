--------------------------------------------------------
--  DDL for Package Body MSD_DEM_COLLECT_HISTORY_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_COLLECT_HISTORY_DATA" AS
/* $Header: msddemchdb.pls 120.5.12010000.15 2010/02/03 13:16:04 nallkuma ship $ */


   /*** CUSTOM DATA TYPES ***/

      TYPE ORDER_TYPE_TABLE_TYPE    IS TABLE OF VARCHAR2(100);
      TYPE ORDER_TYPE_ID_TABLE_TYPE IS TABLE OF NUMBER;

   /*** CONSTANTS ***/
      C_ALL                 CONSTANT NUMBER := 1;
      C_INCLUDE             CONSTANT NUMBER := 2;
      C_EXCLUDE             CONSTANT NUMBER := 3;

      VS_MSG_SALES_TABLE		CONSTANT VARCHAR2(16)	:= 'LOAD SALES TABLE';
      VS_MSG_ITEMS_TABLE		CONSTANT VARCHAR2(16) := 'LOAD ITEMS TABLE';
      VS_MSG_LOCATION_TABLE	CONSTANT VARCHAR2(19)	:= 'LOAD LOCATION TABLE';

      VS_MSG_LOADING		    CONSTANT VARCHAR2(8) := 'Loading ';
			VS_MSG_LOADED		      CONSTANT VARCHAR2(7) := 'Loaded ';
      VS_MSG_STARTED		    CONSTANT VARCHAR2(7) := 'Started';
		  VS_MSG_SUCCEEDED	    CONSTANT VARCHAR2(9) := 'Succeeded';
		  VS_MSG_LOADE_ERROR	  CONSTANT VARCHAR2(12) := 'Load error: ';
		  VS_MSG_ITEMS          CONSTANT VARCHAR2(12) := 'Items';
		  VS_MSG_LOCATIONS      CONSTANT VARCHAR2(12) := 'Locations';
		  VS_MSG_SALES          CONSTANT VARCHAR2(12) := 'Sales';

   /*** GLOBAL VARIABLES ***/
      g_dblink			VARCHAR2(50)  	:= NULL;
      g_collection_method   	NUMBER		:= NULL;

   /*** PRIVATE FUNCTIONS ***/

      /*
       * This function validates the order types given
       * by the user.
       * This function returns the number of invalid
       * order types found in the user input.
       * Returns '-1' incase of ERROR.
       */
      FUNCTION VALIDATE_ORDER_TYPES (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
			p_order_type_flag         	OUT NOCOPY NUMBER,
			p_order_type_ids          	OUT NOCOPY  VARCHAR2,
			p_collect_all_order_types 	IN 	   NUMBER,
			p_include_order_types     	IN 	   VARCHAR2,
			p_exclude_order_types     	IN 	   VARCHAR2)
      RETURN NUMBER
      IS

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

         /* If collect all order types is yes, then ignore other fields */
         IF (p_collect_all_order_types = G_YES)
         THEN

            IF (   p_include_order_types IS NOT NULL
                OR p_exclude_order_types IS NOT NULL)
            THEN
               retcode := 1;
               errbuf := 'The parameters Include Order Types and Exclude Order Types are ignored, if Collect All Order Types is Yes.';
               msd_dem_common_utilities.log_message ('Warning(1): msd_dem_collect_history_data.validate_order_types - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message (errbuf);
            END IF;

            p_order_type_flag := C_ALL;
            p_order_type_ids := '';
            RETURN 0;

         END IF;


         /* Get all the valid order types from the source*/
         l_sql_stmt := 'SELECT ' ||
                          'B.TRANSACTION_TYPE_ID ORDER_TYPE_ID, ' ||
                          'UPPER(B.ORDER_CATEGORY_CODE) ORDER_CATEGORY_CODE, ' ||
                          'UPPER(T.NAME) NAME ' ||
                       'FROM ' ||
                          'OE_TRANSACTION_TYPES_TL' || g_dblink || ' T, ' ||
                          'OE_TRANSACTION_TYPES_ALL' || g_dblink || ' B '||
                       'WHERE ' ||
                          'B.TRANSACTION_TYPE_ID = T.TRANSACTION_TYPE_ID AND ' ||
                          'B.Transaction_type_code = ''ORDER'' AND ' ||
                          'nvl(B.SALES_DOCUMENT_TYPE_CODE,''O'') <> ''B'' AND ' ||
                          'T.LANGUAGE = userenv(''LANG'') ';

         EXECUTE IMMEDIATE l_sql_stmt
            BULK COLLECT INTO l_order_type_id_table,
                              l_order_category_code_table,
                              l_order_type_table;

         IF (l_order_type_table.COUNT = 0)
         THEN
            retcode := -1;
            errbuf  := 'No order types found in the source';
            msd_dem_common_utilities.log_message ('Error(1): msd_dem_collect_history_data.validate_order_types - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN -1;
         END IF;

         IF (p_collect_all_order_types = G_NO)
         THEN

            IF (    p_include_order_types IS NULL
                AND p_exclude_order_types IS NULL)
            THEN
               retcode := -1;
               errbuf  := 'Exactly one of the parameters Include Order Types or Exclude Order Types must be specified, when Collect All Order Types is No.';
               msd_dem_common_utilities.log_message ('Error(2): msd_dem_collect_history_data.validate_order_types - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message (errbuf);
               RETURN -1;
            ELSIF (    p_include_order_types IS NOT NULL
                   AND p_exclude_order_types IS NOT NULL)
            THEN
               retcode := -1;
               errbuf  := 'Only one of the parameters Include Order Types or Exclude Order Types must be specified, when Collect All Order Types is No.';
               msd_dem_common_utilities.log_message ('Error(3): msd_dem_collect_history_data.validate_order_types - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message (errbuf);
               RETURN -1;
            ELSIF (p_include_order_types IS NOT NULL)
            THEN
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
               IF (l_position <> 0)
               THEN
                  l_token := SUBSTR( l_order_types, l_start, l_position - l_start);
                  l_original_token := SUBSTR( l_original_order_types, l_start, l_position - l_start);
               ELSE
                  l_token := SUBSTR( l_order_types, l_start);
                  l_original_token := SUBSTR( l_original_order_types, l_start);
               END IF;

               /* Validate the order type*/
               l_found := FALSE;
               FOR i IN l_order_type_table.FIRST..l_order_type_table.LAST
               LOOP

                  /* Valid order type */
                  IF (    l_order_category_code_table(i) <> 'RETURN'
                      AND l_token = l_order_type_table(i))
                  THEN

                     l_found := TRUE;
                     l_valid_count := l_valid_count + 1;
                     l_valid_order_type_table.EXTEND;
                     l_valid_order_type_table(l_valid_count) := l_original_token;

                     IF (l_valid_count = 1)
                     THEN
                        l_order_type_ids := l_order_type_ids || to_char(l_order_type_id_table(i));
                     ELSE
                        l_order_type_ids := l_order_type_ids || ',' || to_char(l_order_type_id_table(i));
                     END IF;

                     EXIT;

                  /* Invalid order type since order category code is 'RETURN' */
                  ELSIF (    l_order_category_code_table(i) = 'RETURN'
                         AND l_token = l_order_type_table(i))
                  THEN

                     l_found := TRUE;
                     l_invalid_count := l_invalid_count + 1;
                     l_invalid_order_type_table.EXTEND;
                     l_invalid_order_type_table(l_invalid_count) := l_original_token || '  (Order Type is RETURN)';

                     EXIT;

                  END IF;

               END LOOP;

               /* Invalid order type */
               IF (l_found = FALSE)
               THEN
                  l_invalid_count := l_invalid_count + 1;
                  l_invalid_order_type_table.EXTEND;
                  l_invalid_order_type_table(l_invalid_count) := l_original_token;
               END IF;

               EXIT WHEN l_position = 0;
               l_start := l_position + 1;

            END LOOP;

            msd_dem_common_utilities.log_message ('           Order Types');
            msd_dem_common_utilities.log_message ('          -------------');

            msd_dem_common_utilities.log_message ('         Valid Order Types');
            msd_dem_common_utilities.log_message ('        -------------------');

            IF (l_valid_count <> 0)
            THEN
               FOR i in l_valid_order_type_table.FIRST..l_valid_order_type_table.LAST
               LOOP
                  msd_dem_common_utilities.log_message (to_char(i) || ') ' || l_valid_order_type_table(i));
               END LOOP;
            ELSE
               msd_dem_common_utilities.log_message ('No valid order types found in user input');
            END IF;

            msd_dem_common_utilities.log_message (' ');
            msd_dem_common_utilities.log_message ('        Invalid Order Types');
            msd_dem_common_utilities.log_message ('       ---------------------');

            IF (l_invalid_count <> 0)
            THEN
               FOR i in l_invalid_order_type_table.FIRST..l_invalid_order_type_table.LAST
               LOOP
                  msd_dem_common_utilities.log_message (to_char(i) || ') ' || l_invalid_order_type_table(i));
               END LOOP;
            END IF;

            IF (l_valid_count = 0)
            THEN
               retcode := -1;
               errbuf  := 'No valid order types found in user input';
               msd_dem_common_utilities.log_message ('Error(4): msd_dem_collect_history_data.validate_order_types - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               RETURN -1;
            END IF;

            IF (l_invalid_count <> 0)
            THEN
               retcode := 1;
               errbuf  := 'Invalid order types found in user input';
               msd_dem_common_utilities.log_message ('Warning(1): msd_dem_collect_history_data.validate_order_types - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            END IF;

         END IF;

         p_order_type_flag := l_order_type_flag;
         p_order_type_ids := l_order_type_ids;
         RETURN l_invalid_count;

      END VALIDATE_ORDER_TYPES;



   /*** PRIVATE PROCEDURES ***/

   /* THIS PROCEDURE DELETES THE INTERNAL SALES ODERS IN THE SAME LINE OF BUSINESS */

      PROCEDURE DELETE_INTERNAL_SALES_ORDERS(
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_instance_id             	IN 	   NUMBER )
      IS

      delete_sql varchar2(1000);
      x_dest_table varchar2(300);
      x_dem_schema varchar2(100);

      CURSOR c_get_dm_schema
       IS
       SELECT owner
       FROM dba_objects
       WHERE  owner = owner
        AND object_type = 'TABLE'
        AND object_name = 'MDP_MATRIX'
       ORDER BY created desc;

      BEGIN

      msd_dem_common_utilities.log_debug ('Entering: msd_dem_collect_history_data.delete_internal_sales_orders - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      x_dest_table := msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES',   'SALES_STAGING_TABLE');

      open c_get_dm_schema;
      fetch c_get_dm_schema into x_dem_schema;
      close c_get_dm_schema;

      if( x_dem_schema is not null) then
        x_dem_schema := fnd_profile.value('MSD_DEM_SCHEMA');
      end if;

      if( x_dem_schema is not null) then
          delete_sql := 'DELETE FROM ' || x_dest_table || ' sales '
                 || ' WHERE EXISTS '
                 || '  (SELECT 1 '
                         || '   FROM msc_location_associations mla, '
                         || '     msc_tp_site_id_lid mtsil, '
                         || '     msc_trading_partners orgs, '
                         || x_dem_schema || '.t_ep_organization orgs1, '
                         || x_dem_schema || '.t_ep_organization orgs2 '
                         || '   WHERE sales.ebs_site_sr_pk = mtsil.sr_tp_site_id '
                         || '   AND sales.dm_org_code = orgs1.organization '
                         || '   AND mla.partner_site_id = mtsil.tp_site_id '
                 || '   AND mla.sr_instance_id = :instance_id '
                         || '   AND mla.sr_instance_id = mtsil.sr_instance_id '
                 || '   AND mla.sr_instance_id = orgs.sr_instance_id '
                         || '   AND mla.organization_id = orgs.sr_tp_id '
                 || '   AND orgs.partner_type = 3 '
                 || '   AND orgs.organization_code = orgs2.organization '
                 || '   AND orgs1.t_ep_lob_id = orgs2.t_ep_lob_id '
                         || '   AND orgs1.t_ep_lob_id > 0)';

          msd_dem_common_utilities.log_debug (delete_sql);
          execute immediate delete_sql using p_instance_id;
          commit;
      else
        msd_dem_common_utilities.log_message('Demantra not installed. Not deleting Internal Sales Orders.');
        msd_dem_common_utilities.log_debug('Demantra not installed. Not deleting Internal Sales Orders.');
      end if;

      msd_dem_common_utilities.log_debug ('Exiting: msd_dem_collect_history_data.delete_internal_sales_orders - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      retcode := 1;
      return;

      EXCEPTION
         WHEN OTHERS THEN
      	   		errbuf  := substr(SQLERRM,1,150);
        	        retcode := -1 ;
	    msd_dem_common_utilities.log_debug ('Exception:
	    msd_dem_collect_history_data.delete_internal_sales_orders - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	    msd_dem_common_utilities.log_debug (errbuf);
	    RETURN;


      END DELETE_INTERNAL_SALES_ORDERS;



      /*
       * This procedure given the series id, gets the
       * data from the source instance and upserts into the
       * sales staging table.
       */
      PROCEDURE COLLECT_SERIES_DATA (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_series_id			IN	   NUMBER,
      			p_dest_table			IN	   VARCHAR2,
      			p_dm_time_level			IN	   NUMBER,
      			p_sr_instance_id		IN         NUMBER,
      			p_apps_ver			IN	   NUMBER,
      			p_instance_type			IN	   NUMBER,
      			p_collection_group      	IN         VARCHAR2,
      			p_collection_method     	IN         NUMBER,
      			p_from_date			IN	   DATE,
      			p_to_date			IN	   DATE,
      			p_collect_iso			IN	   NUMBER,
      			p_order_type_flag		IN	   NUMBER,
      			p_order_type_ids		IN	   VARCHAR2)
      IS

         /*** CURSORS ***/

         CURSOR c_get_series_info
         IS
            SELECT
                identifier, STG_SERIES_COL_NAME, MSD_SR_ITEM_PK_COL, MSD_SOURCE_DATE_COL, GMP_SR_ITEM_PK_COL, GMP_SOURCE_DATE_COL, CUSTOM_VIEW_NAME, GMP_CUSTOM_VIEW_NAME
               FROM
                  msd_dem_series
               WHERE
                      series_id = p_series_id
                  AND series_type = 1;

         /*** LOCAL VARIABLES ***/
            x_errbuf		VARCHAR2(200)	:= NULL;
            x_errbuf1		VARCHAR2(200)	:= NULL;
            x_retcode		VARCHAR2(100)	:= NULL;
            x_retcode1		VARCHAR2(100)	:= NULL;
            XDBLINK             VARCHAR2(100)   := NULL;

            x_large_sql		VARCHAR2(32000) := NULL;
            x_add_where_clause  VARCHAR2(3000)  := NULL;
            x_key_values	VARCHAR2(4000)	:= NULL;
            x_is_custom         NUMBER          := NULL;
            x_gmp_is_custom	NUMBER		:= NULL;

            x_dquery_identifier	VARCHAR2(30)	:= NULL;
            x_pquery_identifier	VARCHAR2(30)	:= NULL;

            l_identifier           varchar2(30)    := NULL;
            l_STG_SERIES_COL_NAME  varchar2(100)   := NULL;
            l_MSD_SR_ITEM_PK_COL   varchar2(500)    := NULL;
            l_MSD_SOURCE_DATE_COL  varchar2(500)    := NULL;
            l_GMP_SR_ITEM_PK_COL   varchar2(500)    := NULL;
            l_GMP_SOURCE_DATE_COL  varchar2(500)    := NULL;
            l_custom_view_name	   varchar2(100)    := NULL;
            l_gmp_custom_view_name varchar2(100)    := NULL;

            x_dem_version		VARCHAR2(10)    := msd_dem_common_utilities.get_demantra_version;


      BEGIN

         msd_dem_common_utilities.log_debug ('Entering: msd_dem_collect_history_data.collect_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         OPEN  c_get_series_info;
         FETCH c_get_series_info INTO l_identifier, l_STG_SERIES_COL_NAME, l_MSD_SR_ITEM_PK_COL, l_MSD_SOURCE_DATE_COL,l_GMP_SR_ITEM_PK_COL, l_GMP_SOURCE_DATE_COL, l_custom_view_name, l_gmp_custom_view_name;
         CLOSE c_get_series_info;

         IF (l_identifier IS NULL)
         THEN
            retcode := -1;
            errbuf  := 'Unable to get the query identifier.';
            msd_dem_common_utilities.log_message ('Error(1): msd_dem_collect_history_data.collect_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
         END IF;

         /* Check if custom view for Discrete */
         IF (l_custom_view_name IS NULL)
         THEN
            x_is_custom := 0;
         ELSE
            x_is_custom := 1;
         END IF;

         /* Check if custom view for Process */
         IF (l_gmp_custom_view_name IS NULL)
         THEN
            x_gmp_is_custom := 0;
         ELSE
            x_gmp_is_custom := 1;
         END IF;

         /* For Discrete */
         /* 11i instance where instance type in not 'PROCESS' OR R12 Instance of any type */
         IF (   p_instance_type <> 2
             OR p_apps_ver = 4)
         THEN

             msd_dem_common_utilities.log_debug ('Begin collect discrete sales history - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

             x_add_where_clause := ' 1 = 1 ';

             /* If p_collect_iso = No, then include an additional condition to filter out Internal Sales Orders */
             IF (p_collect_ISO = G_NO)
             THEN
                x_add_where_clause := x_add_where_clause || ' AND nvl(ooha.order_source_id, 0) <> 10 ';
             END IF;

             /* Include an additional condition to filter data based on order types specified by the user */
             IF (p_order_type_flag = C_INCLUDE)
             THEN
                x_add_where_clause := x_add_where_clause || ' AND ooha.order_type_id IN (' || p_order_type_ids || ') ';
             ELSIF (p_order_type_flag = C_EXCLUDE)
             THEN
                x_add_where_clause := x_add_where_clause || ' AND ooha.order_type_id NOT IN (' || p_order_type_ids || ') ';
             END IF;


             IF(p_dm_time_level = 1) then

               x_key_values := '$C_DEST_TABLE#' || p_dest_table
                                  || '$C_SERIES_QTY#' || l_STG_SERIES_COL_NAME
                                  || '$C_DEST_DATE_GROUP#' || 'MDBR.SDATE'
                                  || '$C_DEST_DATE#' || 'MDBR.SDATE'
                                  || '$C_SR_ITEM_PK#' || l_MSD_SR_ITEM_PK_COL
                                  || '$C_SOURCE_DATE#' || nvl(substr(l_msd_source_date_col, 0, instr(upper(l_msd_source_date_col), 'SDATE')-1), to_date('01/01/1000', 'DD/MM/YYYY')) || ' SDATE'
                                  || '$C_ADD_WHERE_CLAUSE#' || x_add_where_clause
                                  || '$C_ITEM_PK_JOIN#' || substr(l_MSD_SR_ITEM_PK_COL, 0, instr(upper(l_MSD_SR_ITEM_PK_COL),  'SR_ITEM_PK')-1)
                                  || '$C_SR_INSTANCE_ID#' || to_char(p_sr_instance_id)
                                  || '$C_MASTER_ORG#' || msd_dem_common_utilities.get_parameter_value (p_sr_instance_id, 'MSD_DEM_MASTER_ORG');

               IF (g_collection_method <> 1) THEN
                  x_key_values := x_key_values || '$C_TIME_CLAUSE#' || ' WHERE SDATE BETWEEN '
                                     || 'to_date(''' || to_char(p_from_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                     || ' AND '
                                     || 'to_date(''' || to_char(p_to_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') ';
               ELSE
                  x_key_values := x_key_values || '$C_TIME_CLAUSE#' || '    ';
               END IF;

               --x_key_values := x_key_values || '$';

             ELSE

               x_key_values := '$C_DEST_TABLE#' || p_dest_table
                                  || '$C_SERIES_QTY#' || l_STG_SERIES_COL_NAME
                                  || '$C_DEST_DATE_GROUP#' || 'INP.DATET'
                                  || '$C_DEST_DATE#' || 'INP.DATET SDATE'
                                  || '$C_SR_ITEM_PK#' || l_MSD_SR_ITEM_PK_COL
                                  || '$C_SOURCE_DATE#' || SUBSTR(L_MSD_SOURCE_DATE_COL, 1, instr(L_MSD_SOURCE_DATE_COL, 'SDATE')-1) ||' PDATE'
                                  || '$C_ADD_WHERE_CLAUSE#' || x_add_where_clause
                                  || '$C_ITEM_PK_JOIN#' || substr(l_MSD_SR_ITEM_PK_COL, 0, instr(upper(l_MSD_SR_ITEM_PK_COL),  'SR_ITEM_PK')-1)
                                  || '$C_SR_INSTANCE_ID#' || to_char(p_sr_instance_id)
                                  || '$C_MASTER_ORG#' || msd_dem_common_utilities.get_parameter_value (p_sr_instance_id, 'MSD_DEM_MASTER_ORG');

               IF (g_collection_method <> 1) THEN
                  x_key_values := x_key_values || '$C_TIME_CLAUSE#' || ', msd_dem_dates inp WHERE mdbr.pdate BETWEEN '
                                     || 'to_date(''' || to_char(p_from_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                     || ' AND '
                                     || 'to_date(''' || to_char(p_to_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                     || ' AND MDBR.PDATE BETWEEN inp.start_date AND inp.end_date ';
               ELSE
                  x_key_values := x_key_values || '$C_TIME_CLAUSE#' || ', msd_dem_dates inp WHERE mdbr.pdate BETWEEN inp.start_date AND inp.end_date ';
               END IF;

               --x_key_values := x_key_values || '$';

             END IF;

             -- syenamar
             /* Bug#7673154
             * In case custom view is used for shipment booking history collection and net change collection method is specified
             * its not possible for the custom view to filter out sales records for unwanted dates, as the existing view is used and not built dynamically.
             * Adding a time clause to the merge query in this case to bring in data for the specified date range.
             */
             if( x_is_custom = 1 and g_collection_method <> 1) then
                x_key_values := x_key_values || '$C_MERGE_TIME_CLAUSE#' || ' AND SDATE BETWEEN '
                                     || 'to_date(''' || to_char(p_from_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                     || ' AND '
                                     || 'to_date(''' || to_char(p_to_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') ';
             else
                x_key_values := x_key_values || '$C_MERGE_TIME_CLAUSE#' || '';
             end if;

             x_key_values := x_key_values || '$';


             IF (x_dem_version = '7.2')
             THEN
                x_dquery_identifier := l_identifier;
             ELSE
                x_dquery_identifier := l_identifier || '_730';
             END IF;

             /* Get the query */
             msd_dem_query_utilities.get_query2 (
             			x_retcode1,
             			x_large_sql,
             			x_dquery_identifier,
             			p_sr_instance_id,
             			x_key_values,
             			x_is_custom,
             			l_custom_view_name);

             IF (   x_retcode1 = '-1'
                 OR x_large_sql IS NULL)
             THEN
                retcode := -1;
                errbuf  := 'Unable to get the query.';
                msd_dem_common_utilities.log_message ('Error(2): msd_dem_collect_history_data.collect_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                msd_dem_common_utilities.log_message (errbuf);
                RETURN;
             END IF;


             msd_dem_common_utilities.log_debug ('Query - ');
             msd_dem_common_utilities.log_debug (x_large_sql);

             msd_dem_common_utilities.log_debug ('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

             BEGIN
                /* Upsert history data into sales staging table */
                EXECUTE IMMEDIATE x_large_sql;
                COMMIT;
             EXCEPTION
                WHEN OTHERS THEN
                   retcode := -1 ;
	           errbuf  := substr(SQLERRM,1,150);
	           msd_dem_common_utilities.log_message ('Exception(1): msd_dem_collect_history_data.collect_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	           msd_dem_common_utilities.log_message (errbuf);
	           msd_dem_common_utilities.log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	           RETURN;
             END;

             msd_dem_common_utilities.log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

             msd_dem_common_utilities.log_debug ('End collect discrete sales history - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         END IF;

         x_large_sql := NULL;
         x_key_values := NULL;

         /* For Process */
         IF (   p_instance_type IN (2, 4)
             AND p_apps_ver = 3)
         THEN

             msd_dem_common_utilities.log_debug ('Begin collect process sales history - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

             x_pquery_identifier := replace(l_identifier , 'MSD','GMP') ;

             x_add_where_clause := ' 1 = 1 ';

             /* If p_collect_iso = No, then include an additional condition to filter out Internal Sales Orders */
             IF (p_collect_ISO = G_NO)
             THEN
                x_add_where_clause := x_add_where_clause || ' AND decode(ool.to_whse, NULL, 10, 0) <> 10 ';
             END IF;

             /*** ORDER TYPES Filters are not supported for process sales data ***/


             IF(p_dm_time_level = 1) then

               x_key_values := '$C_DEST_TABLE#' || p_dest_table
                                  || '$C_SERIES_QTY#' || l_STG_SERIES_COL_NAME
                                  || '$C_DEST_DATE_GROUP#' || 'MDBR.SDATE'
                                  || '$C_DEST_DATE#' || 'MDBR.SDATE'
                                  || '$C_SOURCE_DATE#' || NVL(substr(l_gmp_source_date_col, 0, instr(upper(l_gmp_source_date_col), 'SDATE')-1), TO_DATE('01/01/1000', 'DD/MM/YYYY')) || ' SDATE'
                                  || '$C_ADD_WHERE_CLAUSE#' || x_add_where_clause;

               IF (g_collection_method <> 1) THEN
                  x_key_values := x_key_values || '$C_TIME_CLAUSE#' || ' WHERE SDATE BETWEEN '
                                     || 'to_date(''' || to_char(p_from_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                     || ' AND '
                                     || 'to_date(''' || to_char(p_to_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') ';
               ELSE
                  x_key_values := x_key_values || '$C_TIME_CLAUSE#' || '    ';
               END IF;

               x_key_values := x_key_values || '$';

             ELSE

               x_key_values := '$C_DEST_TABLE#' || p_dest_table
                                  || '$C_SERIES_QTY#' || l_STG_SERIES_COL_NAME
                                  || '$C_DEST_DATE_GROUP#' || 'INP.DATET'
                                  || '$C_DEST_DATE#' || 'INP.DATET SDATE'
                                  || '$C_SOURCE_DATE#' || SUBSTR(L_GMP_SOURCE_DATE_COL, 1, instr(L_GMP_SOURCE_DATE_COL, 'SDATE')-1)||' PDATE'
                                  || '$C_ADD_WHERE_CLAUSE#' || x_add_where_clause;

               IF (g_collection_method <> 1) THEN
                  x_key_values := x_key_values || '$C_TIME_CLAUSE#' || ', msd_dem_dates inp WHERE mdbr.pdate BETWEEN '
                                     || 'to_date(''' || to_char(p_from_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                     || ' AND '
                                     || 'to_date(''' || to_char(p_to_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                     || ' AND MDBR.PDATE BETWEEN inp.start_date AND inp.end_date ';
               ELSE
                  x_key_values := x_key_values || '$C_TIME_CLAUSE#' || ', msd_dem_dates inp WHERE mdbr.pdate BETWEEN inp.start_date AND inp.end_date ';
               END IF;

               x_key_values := x_key_values || '$';

            END IF;

              /* Get the query */
             msd_dem_query_utilities.get_query2 (
             			x_retcode1,
             			x_large_sql,
             			x_pquery_identifier,
             			p_sr_instance_id,
             			x_key_values,
             			x_gmp_is_custom,
             			l_gmp_custom_view_name);

             IF (   x_retcode1 = '-1'
                 OR x_large_sql IS NULL)
             THEN
                retcode := -1;
                errbuf  := 'Unable to get the query.';
                msd_dem_common_utilities.log_message ('Error(3): msd_dem_collect_history_data.collect_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                msd_dem_common_utilities.log_message (errbuf);
                RETURN;
             END IF;


             msd_dem_common_utilities.log_debug ('Query - ');
             msd_dem_common_utilities.log_debug (x_large_sql);

             msd_dem_common_utilities.log_debug ('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

             BEGIN
                /* Upsert history data into sales staging table */
                EXECUTE IMMEDIATE x_large_sql;
                COMMIT;
             EXCEPTION
                WHEN OTHERS THEN
                   retcode := -1 ;
	           errbuf  := substr(SQLERRM,1,150);
	           msd_dem_common_utilities.log_message ('Exception(2): msd_dem_collect_history_data.collect_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	           msd_dem_common_utilities.log_message (errbuf);
	           msd_dem_common_utilities.log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	           RETURN;
             END;

             msd_dem_common_utilities.log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             msd_dem_common_utilities.log_debug ('End collect process sales history - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         END IF;

         msd_dem_common_utilities.log_debug ('Exiting: msd_dem_collect_history_data.collect_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      EXCEPTION
         WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception(3): msd_dem_collect_history_data.collect_series_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;

      END COLLECT_SERIES_DATA;



      /*
       * This procedure inserts dummy rows into the sales staging tables for new items
       */
      PROCEDURE INSERT_DUMMY_ROWS (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_dest_table                    IN	   VARCHAR2,
      			p_sr_instance_id		IN         NUMBER)
      IS

         /*** CURSORS ***/

            CURSOR c_check_new_items
            IS
               SELECT 1
                  FROM dual
                  WHERE EXISTS (SELECT 1
                                   FROM msd_dem_new_items
                                   WHERE  sr_instance_id = p_sr_instance_id
                                      AND process_flag = 2);

         /*** LOCAL VARIABLES ***/
            x_retcode		VARCHAR2(100)	:= NULL;

            x_new_items_present	NUMBER		:= NULL;
            x_sql		VARCHAR2(32000) := NULL;
      BEGIN

         msd_dem_common_utilities.log_debug ('Entering msd_dem_collect_history_data.insert_dummy_rows - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Check if there are any yet to be processed NPIs */
         OPEN c_check_new_items;
         FETCH c_check_new_items INTO x_new_items_present;
         CLOSE c_check_new_items;

         IF (x_new_items_present = 1)
         THEN
            msd_dem_common_utilities.log_message ('Found new items for processing');

            msd_dem_query_utilities.get_query(
            				x_retcode,
            				x_sql,
            				'DUMMY_ROWS_FOR_NEW_ITEMS',
            				p_sr_instance_id,
            				p_dest_table);

            IF (x_retcode = -1)
            THEN
               retcode := 1;
               errbuf := 'Unable to get the query for inserting dummy rows for new items into sales staging table';
               msd_dem_common_utilities.log_message ('Warning(1): msd_dem_collect_history_data.insert_dummy_rows');
               msd_dem_common_utilities.log_message (errbuf);
               RETURN;
            END IF;

            msd_dem_common_utilities.log_debug ('Query - ');
            msd_dem_common_utilities.log_debug ('Bind Variables - ');
            msd_dem_common_utilities.log_debug ('Source Instance Id - ' || to_char(p_sr_instance_id));
            msd_dem_common_utilities.log_debug (x_sql);

            msd_dem_common_utilities.log_debug ('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            EXECUTE IMMEDIATE x_sql USING p_sr_instance_id;
            msd_dem_common_utilities.log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            /* Set the process_flag */
            UPDATE msd_dem_new_items
               SET process_flag = 1
               WHERE  sr_instance_id = p_sr_instance_id
                  AND process_flag = 2;

            COMMIT;

         END IF;

         msd_dem_common_utilities.log_debug ('Exiting msd_dem_collect_history_data.insert_dummy_rows - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      EXCEPTION
         WHEN OTHERS THEN
            retcode := 1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception: msd_dem_collect_history_data.insert_dummy_rows - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;
      END INSERT_DUMMY_ROWS;


      /*
       * This procedure analyzes the given table
       */
      PROCEDURE ANALYZE_TABLE (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_table_name			IN	   VARCHAR2)
      IS

         /*** LOCAL VARIABLES ***/

         x_schema_name		VARCHAR2(30)	:= NULL;
         x_table_name		VARCHAR2(30)	:= NULL;

         x_pos			NUMBER		:= NULL;

      BEGIN

         msd_dem_common_utilities.log_debug ('Entering msd_dem_collect_history_data.analyze_table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         x_pos := instr( p_table_name, '.', 1, 1);

         IF (x_pos = 0)
         THEN
           x_schema_name := 'MSD';
           x_table_name  := p_table_name;
         ELSE
            x_schema_name := substr (p_table_name, 1, x_pos - 1);
            x_table_name  := substr (p_table_name, x_pos +1);
         END IF;

         msd_dem_common_utilities.log_message ('Analyzing Table - ' || x_schema_name || '.' || x_table_name);
         fnd_stats.gather_table_stats(x_schema_name, x_table_name, 10, 4);

         msd_dem_common_utilities.log_debug ('Exiting: msd_dem_collect_history_data.analyze_table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));


      EXCEPTION
         WHEN OTHERS THEN
            retcode := 1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception: msd_dem_collect_history_data.analyze_table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;
      END ANALYZE_TABLE;

   /*** PUBLIC PROCEDURES ***/


      PROCEDURE COLLECT_HISTORY_DATA (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_sr_instance_id		IN         NUMBER,
      			p_collection_group      	IN         VARCHAR2,
      			p_collection_method     	IN         NUMBER,
      			p_hidden_param1			IN	   VARCHAR2,
      			p_date_range_type		IN	   NUMBER,
      			p_collection_window		IN	   NUMBER,
      			p_from_date			IN	   VARCHAR2,
      			p_to_date			IN	   VARCHAR2,
      			p_bh_bi_bd			IN	   NUMBER,
      			p_bh_bi_rd			IN	   NUMBER,
      			p_bh_ri_bd			IN	   NUMBER,
      			p_bh_ri_rd			IN	   NUMBER,
      			p_sh_si_sd			IN	   NUMBER,
      			p_sh_si_rd			IN	   NUMBER,
      			p_sh_ri_sd			IN	   NUMBER,
      			p_sh_ri_rd			IN	   NUMBER,
      			p_collect_iso			IN	   NUMBER   DEFAULT G_NO,
      			p_collect_all_order_types	IN	   NUMBER   DEFAULT G_YES,
      			p_include_order_types		IN	   VARCHAR2 DEFAULT NULL,
      			p_exclude_order_types		IN	   VARCHAR2 DEFAULT NULL,
      			p_auto_run_download     	IN 	   NUMBER )
      IS

         /*** LOCAL VARIABLES ****/

            x_errbuf		VARCHAR2(200)	:= NULL;
            x_errbuf1		VARCHAR2(200)	:= NULL;
            x_retcode		VARCHAR2(100)	:= NULL;
            x_retcode1		VARCHAR2(100)	:= NULL;

            x_order_type_ids    VARCHAR2(2000);
            x_order_type_flag   NUMBER;
            x_invalid_count     NUMBER          := 0;
            x_dest_table	VARCHAR2(100)    := NULL;

            x_sql		VARCHAR2(1000)  := NULL;

            x_from_date		DATE 		:= NULL;
            x_to_date		DATE		:= NULL;

            x_instance_code     VARCHAR2(30)	:= NULL;
            x_apps_ver		NUMBER		:= NULL;
            x_dgmt		NUMBER		:= NULL;
            x_instance_type     NUMBER		:= NULL;
            x_dm_time_level	NUMBER		:= NULL;
            x_dm_time_bucket    VARCHAR2(30)    := NULL;

            g_schema	        VARCHAR2(50)	:= NULL;

            l_sql               VARCHAR2(1000)  := NULL;
	    l_profile_id        NUMBER          := NULL;
	    l_bh_bi_bd_id       NUMBER          := NULL;
	    l_bh_bi_rd_id       NUMBER          := NULL;
	    l_bh_ri_bd_id       NUMBER          := NULL;
	    l_bh_ri_rd_id       NUMBER          := NULL;
	    l_sh_si_sd_id       NUMBER          := NULL;
	    l_sh_si_rd_id       NUMBER          := NULL;
	    l_sh_ri_sd_id       NUMBER          := NULL;
	    l_sh_ri_rd_id       NUMBER          := NULL;

	    l_table_name	varchar2(240)   := NULL;
	    l_start_date		date		:= NULL;
	    l_until_date	date		:= NULL;
      l_schema_name VARCHAR2(100) := NULL;


            CURSOR c_get_dm_schema --jarora
         IS
         SELECT owner
         FROM dba_objects
         WHERE  owner = owner
            AND object_type = 'TABLE'
            AND object_name = 'MDP_MATRIX'
         ORDER BY created desc;

      BEGIN

         msd_dem_common_utilities.log_debug ('Entering: msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Get the db link to the source instance */
         msd_dem_common_utilities.get_dblink (
         			x_errbuf,
         			x_retcode,
         			p_sr_instance_id,
         			g_dblink);

         IF (x_retcode = '-1')
         THEN
            retcode := -1;
            errbuf := x_errbuf;
            msd_dem_common_utilities.log_message ('Error(1): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN;
         END IF;

         g_collection_method := p_collection_method;

         /* VALIDATION OF INPUT PARAMETERS - BEGIN */

         msd_dem_common_utilities.log_debug ('Begin validation of inputs parameters - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Atleast one parameter must be selected */
         IF (    p_bh_bi_bd = G_NO
             AND p_bh_bi_rd = G_NO
             AND p_bh_ri_bd = G_NO
             AND p_bh_ri_rd = G_NO
             AND p_sh_si_sd = G_NO
             AND p_sh_si_rd = G_NO
             AND p_sh_ri_sd = G_NO
             AND p_sh_ri_rd = G_NO)
         THEN
            retcode := -1;
            errbuf  := 'No series selected for collection';
            msd_dem_common_utilities.log_message ('Error(2): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
         END IF;


         /* Show Warning if collection method is Refresh and a date range filter is specified */
         IF (    p_collection_method = 1
             AND (   p_from_date IS NOT NULL
                  OR p_to_date IS NOT NULL
                  OR p_collection_window IS NOT NULL))
         THEN
            x_retcode := 1;
            x_errbuf  := 'Date Range filters are ignored in ''Refresh'' collections';
            msd_dem_common_utilities.log_message ('Warning(1): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (x_errbuf);
         END IF;


         /* Show Warning if collection method is net change, date range type is Rolling and from date and to date are specified */
         IF (    p_collection_method = 2
             AND p_date_range_type = 2
             AND (   p_from_date IS NOT NULL
                  OR p_to_date IS NOT NULL))
         THEN
            x_retcode := 1;
            x_errbuf  := 'The ''Date From'' and ''Date To'' fields are ignored if ''Rolling'' date range type is selected.';
            msd_dem_common_utilities.log_message ('Warning(2): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (x_errbuf);
         END IF;


         /* Show Warning if collection method is net change, date range type is Absolute and history collection window is specified */
         IF (    p_collection_method = 2
             AND p_date_range_type = 1
             AND p_collection_window IS NOT NULL)
         THEN
            x_retcode := 1;
            x_errbuf  := 'The ''History Collection Window'' field is ignored if ''Absolute'' date range type is selected.';
            msd_dem_common_utilities.log_message ('Warning(3): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (x_errbuf);
         END IF;


         /* Error if collection method is net change, date range type is Rolling and history collection window is not specified */
         IF (    p_collection_method = 2
             AND p_date_range_type = 2
             AND p_collection_window IS NULL)
         THEN
            retcode := -1;
            errbuf  := 'The ''History Collection Window'' field cannot be NULL, if ''Rolling'' date range type is selected.';
            msd_dem_common_utilities.log_message ('Error(3): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
         END IF;


         /* Error if collection method is net change, date range type is Absolute and from date and to date are not specified */
         IF (    p_collection_method = 2
             AND p_date_range_type = 1
             AND (   p_from_date IS NULL
                  OR p_to_date IS NULL))
         THEN
            retcode := -1;
            errbuf  := 'The ''Date From'' and ''Date To'' fields cannot be NULL, if ''Absolute'' date range type is selected.';
            msd_dem_common_utilities.log_message ('Error(4): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
         END IF;

         /* Validate the order types specified by the user */
         x_invalid_count := validate_order_types (
                                        x_errbuf1,
					x_retcode1,
                			x_order_type_flag,
                			x_order_type_ids,
	        			p_collect_all_order_types,
                			p_include_order_types,
                			p_exclude_order_types );
         IF (x_retcode1 = -1)
         THEN
            retcode := -1;
            errbuf  := 'No valid order types found';
            msd_dem_common_utilities.log_message ('Error(5): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
         ELSIF (x_invalid_count > 0)
         THEN
            x_retcode := 1;
            x_errbuf  := 'Invalid order types found';
            msd_dem_common_utilities.log_message ('Warning(4): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (x_errbuf);
         ELSIF (x_retcode1 = 1)
         THEN
            x_retcode := 1;
            x_errbuf  := x_errbuf1;
            msd_dem_common_utilities.log_message ('Warning(5): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         END IF;

         msd_dem_common_utilities.log_debug ('End validation of inputs parameters - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* VALIDATION OF INPUT PARAMETERS - END */


         /* Get the start date and end dates for collection */

         msd_dem_common_utilities.log_debug ('Begin get dates - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         IF (p_collection_method = 1) /* Refresh*/
         THEN
            x_from_date := to_date('01/01/1000', 'DD/MM/YYYY');
            x_to_date := to_date('31/12/4000', 'DD/MM/YYYY');
         ELSE /* Net Change */
            IF (p_date_range_type = 1) /* Absolute*/
            THEN

               IF (p_from_date IS NULL)
               THEN
                  x_from_date := to_date('01/01/1000', 'DD/MM/YYYY');
               ELSE
                  x_from_date := fnd_date.canonical_to_date (p_from_date);
               END IF;

               IF (p_to_date IS NULL)
               THEN
                  x_to_date := to_date('31/12/4000', 'DD/MM/YYYY');
               ELSE
                  x_to_date := fnd_date.canonical_to_date (p_to_date);
               END IF;

               /* Error if p_from_date is greater than p_to_date */
               IF (x_from_date > x_to_date)
               THEN
                  retcode := -1;
                  errbuf  := 'From Date should not be greater than To Date.';
                  msd_dem_common_utilities.log_message ('Error(6): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                  msd_dem_common_utilities.log_message (errbuf);
                  RETURN;
               END IF;

            ELSE /* Rolling */

               IF (p_collection_window < 0)
               THEN
                  retcode := -1;
                  errbuf  := 'History Collection Window must be a positive number.';
                  msd_dem_common_utilities.log_message ('Error(7): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                  msd_dem_common_utilities.log_message (errbuf);
                  RETURN;
               ELSE
                  x_to_date   := trunc(sysdate);
                  x_from_date := x_to_date - p_collection_window + 1;
               END IF;
            END IF;
         END IF;

         msd_dem_common_utilities.log_debug ('End get dates - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         msd_dem_common_utilities.log_debug ('Begin get instance info - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Get the instance info */
         msd_dem_common_utilities.get_instance_info (
         			x_errbuf1,
         			x_retcode1,
         			x_instance_code,
         			x_apps_ver,
         			x_dgmt,
         			x_instance_type,
         			p_sr_instance_id);

         IF (x_retcode1 = '-1')
         THEN
            retcode := -1;
            errbuf  := x_errbuf1;
            msd_dem_common_utilities.log_message ('Error(8): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message ('Unable to get instance info.');
            RETURN;
         END IF;

         msd_dem_common_utilities.log_debug ('End get instance info - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Get the sales staging table name */
         x_dest_table := msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','SALES_STAGING_TABLE');

         IF (x_dest_table is NULL)
         THEN
            retcode := -1;
            errbuf  := 'Unable to find the sales staging tables.';
            msd_dem_common_utilities.log_message ('Error(9): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
         END IF;

         msd_dem_common_utilities.log_message (' Collect History Data - Actions');
         msd_dem_common_utilities.log_message ('--------------------------------');
         msd_dem_common_utilities.log_message (' ');

         msd_dem_common_utilities.log_message ('Date From (DD/MM/RRRR) - ' || to_char(x_from_date, 'DD/MM/RRRR'));
         msd_dem_common_utilities.log_message ('Date To (DD/MM/RRRR)   - ' || to_char(x_to_date, 'DD/MM/RRRR'));

         msd_dem_common_utilities.log_debug ('Begin delete from sales staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Truncate the sales staging table */
         msd_dem_common_utilities.log_message ('Deleting data from sales staging table - ' || x_dest_table);

	 if p_collection_method = 1 then
            x_sql := 'TRUNCATE TABLE ' || x_dest_table;
	 else
	    IF (nvl( fnd_profile.value( 'MSD_DEM_TRUNCATE_STG_TABLE'), 'N') = 'Y')
	    THEN
	       x_sql := 'TRUNCATE TABLE ' || x_dest_table;
	    ELSE
	       x_sql := 'DELETE FROM '|| x_dest_table || ' where sales_date between ''' || x_from_date || ''' AND ''' || x_to_date || '''';
	    END IF;
	 end if;

	 EXECUTE IMMEDIATE x_sql;

	 IF (p_collection_method <> 1
	     AND nvl( fnd_profile.value( 'MSD_DEM_TRUNCATE_STG_TABLE'), 'N') <> 'Y')
	 THEN

	    x_sql := 'DELETE FROM ' || x_dest_table || ' t1 '
                        || ' WHERE ebs_parent_item_sr_pk is not null '
                        || ' AND actual_qty = 0 '
                        || ' AND ebs_base_model_sr_pk is not null ';
            EXECUTE IMMEDIATE x_sql;

            x_sql := 'UPDATE ' || x_dest_table || ' t1 '
                        || ' SET ebs_base_model_sr_pk = null '
                        || ' WHERE ebs_base_model_sr_pk is not null ';
            EXECUTE IMMEDIATE x_sql;

	 END IF;

         msd_dem_common_utilities.log_debug ('End delete from sales staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

        -- bug#8721519 nallkuma
        l_schema_name := substr(x_dest_table , 1 ,	instr(x_dest_table, '.')-1) ;
        msd_dem_common_utilities.log_message('Fetched the schema name as : '||l_schema_name);

        IF (l_schema_name <> 'MSD' ) then -- Bug#8721519 -- nallkuma
         msd_dem_common_utilities.log_message ('Begin Delete data from ERR table - ' || x_dest_table ||'_err');
		     msd_dem_common_utilities.log_debug ('Deleting data from ERR table - ' || x_dest_table ||'_err');

          /* Truncate the ERR tables  */    -- Saravan ->  Bug# 6357056
         msd_dem_common_utilities.log_debug ('Deleting data from ERR table - ' || x_dest_table ||'_err');
         x_sql := 'TRUNCATE TABLE ' || x_dest_table ||'_err';
         EXECUTE IMMEDIATE x_sql;
         msd_dem_common_utilities.log_debug ('End delete from ERR table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
        END IF;

         msd_dem_common_utilities.log_debug ('End delete from ERR table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
		                 --saravan
         msd_dem_common_utilities.log_debug ('Begin get dm time level - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         OPEN c_get_dm_schema;                       --jarora
         FETCH c_get_dm_schema INTO g_schema;
         CLOSE c_get_dm_schema;

         /* Get the lowest time bucket */
         /* Demantra is Installed */
         IF (g_schema IS NOT NULL) --jarora
         THEN
           x_dm_time_bucket := msd_dem_common_utilities.dm_time_level;
         ELSE
           x_dm_time_bucket := 'DAY';
         END IF;

         IF (x_dm_time_bucket IS NULL)
         THEN
            retcode := -1;
            errbuf  := 'Unable to get lowest time bucket';
            msd_dem_common_utilities.log_message ('Error(10): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
         ELSIF (upper(x_dm_time_bucket) = 'DAY')
         THEN
            x_dm_time_level := 1;
         ELSE
            x_dm_time_level := 2;
         END IF;

         msd_dem_common_utilities.log_debug ('End get dm time level - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Collect each series selected by the user */

         /* Booking History - Booked Items - Booked Date */
         msd_dem_common_utilities.log_debug ('Begin collect Booking History - Booked Items - Booked Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         IF (p_bh_bi_bd = G_YES)
         THEN
            collect_series_data (
           		x_errbuf1,
           		x_retcode1,
           		MSD_DEM_COMMON_UTILITIES.C_BH_BI_BD,
           		x_dest_table,
           		x_dm_time_level,
           		p_sr_instance_id,
           		x_apps_ver,
           		x_instance_type,
           		p_collection_group,
           		p_collection_method,
           		x_from_date,
           		x_to_date,
           		p_collect_iso,
           		x_order_type_flag,
           		x_order_type_ids);

            IF (x_retcode1 = -1)
            THEN
               retcode := -1;
               errbuf  := x_errbuf1;
               msd_dem_common_utilities.log_message ('Error(11): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message ('Error while collecting Booking History - Booked Items - Booked Date');
               RETURN;
            END IF;
         END IF;
         msd_dem_common_utilities.log_debug ('End collect Booking History - Booked Items - Booked Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));


         /* Booking History - Booked Items - Requested Date */
         msd_dem_common_utilities.log_debug ('Begin collect Booking History - Booked Items - Requested Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         IF (p_bh_bi_rd = G_YES)
         THEN
            collect_series_data (
           		x_errbuf1,
           		x_retcode1,
           		MSD_DEM_COMMON_UTILITIES.C_BH_BI_RD,
           		x_dest_table,
           		x_dm_time_level,
           		p_sr_instance_id,
           		x_apps_ver,
           		x_instance_type,
           		p_collection_group,
           		p_collection_method,
           		x_from_date,
           		x_to_date,
           		p_collect_iso,
           		x_order_type_flag,
           		x_order_type_ids);

            IF (x_retcode1 = -1)
            THEN
               retcode := -1;
               errbuf  := x_errbuf1;
               msd_dem_common_utilities.log_message ('Error(12): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message ('Error while collecting Booking History - Booked Items - Requested Date');
               RETURN;
            END IF;
         END IF;
         msd_dem_common_utilities.log_debug ('End collect Booking History - Booked Items - Requested Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Booking History - Requested Items - Booked Date */
         msd_dem_common_utilities.log_debug ('Begin collect Booking History - Requested Items - Booked Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         IF (p_bh_ri_bd = G_YES)
         THEN
            collect_series_data (
           		x_errbuf1,
           		x_retcode1,
           		MSD_DEM_COMMON_UTILITIES.C_BH_RI_BD,
           		x_dest_table,
           		x_dm_time_level,
           		p_sr_instance_id,
           		x_apps_ver,
           		x_instance_type,
           		p_collection_group,
           		p_collection_method,
           		x_from_date,
           		x_to_date,
           		p_collect_iso,
           		x_order_type_flag,
           		x_order_type_ids);

            IF (x_retcode1 = -1)
            THEN
               retcode := -1;
               errbuf  := x_errbuf1;
               msd_dem_common_utilities.log_message ('Error(13): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message ('Error while collecting Booking History - Requested Items - Booked Date');
               RETURN;
            END IF;
         END IF;
         msd_dem_common_utilities.log_debug ('End collect Booking History - Requested Items - Booked Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Booking History - Requested Items - Requested Date */
         msd_dem_common_utilities.log_debug ('Begin collect Booking History - Requested Items - Requested Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         IF (p_bh_ri_rd = G_YES)
         THEN
            collect_series_data (
           		x_errbuf1,
           		x_retcode1,
           		MSD_DEM_COMMON_UTILITIES.C_BH_RI_RD,
           		x_dest_table,
           		x_dm_time_level,
           		p_sr_instance_id,
           		x_apps_ver,
           		x_instance_type,
           		p_collection_group,
           		p_collection_method,
           		x_from_date,
           		x_to_date,
           		p_collect_iso,
           		x_order_type_flag,
           		x_order_type_ids);

            IF (x_retcode1 = -1)
            THEN
               retcode := -1;
               errbuf  := x_errbuf1;
               msd_dem_common_utilities.log_message ('Error(14): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message ('Error while collecting Booking History - Requested Items - Requested Date');
               RETURN;
            END IF;
         END IF;
         msd_dem_common_utilities.log_debug ('End collect Booking History - Requested Items - Requested Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Shipment History - Shipped Items - Shipped Date */
         msd_dem_common_utilities.log_debug ('Begin collect Shipment History - Shipped Items - Shipped Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         IF (p_sh_si_sd = G_YES)
         THEN
            collect_series_data (
           		x_errbuf1,
           		x_retcode1,
           		MSD_DEM_COMMON_UTILITIES.C_SH_SI_SD,
           		x_dest_table,
           		x_dm_time_level,
           		p_sr_instance_id,
           		x_apps_ver,
           		x_instance_type,
           		p_collection_group,
           		p_collection_method,
           		x_from_date,
           		x_to_date,
           		p_collect_iso,
           		x_order_type_flag,
           		x_order_type_ids);

            IF (x_retcode1 = -1)
            THEN
               retcode := -1;
               errbuf  := x_errbuf1;
               msd_dem_common_utilities.log_message ('Error(15): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message ('Error while collecting Shipment History - Shipped Items - Shipped Date');
               RETURN;
            END IF;
         END IF;
         msd_dem_common_utilities.log_debug ('End collect Shipment History - Shipped Items - Shipped Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Shipment History - Shipped Items - Requested Date */
         msd_dem_common_utilities.log_debug ('Begin collect Shipment History - Shipped Items - Requested Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         IF (p_sh_si_rd = G_YES)
         THEN
            collect_series_data (
           		x_errbuf1,
           		x_retcode1,
           		MSD_DEM_COMMON_UTILITIES.C_SH_SI_RD,
           		x_dest_table,
           		x_dm_time_level,
           		p_sr_instance_id,
           		x_apps_ver,
           		x_instance_type,
           		p_collection_group,
           		p_collection_method,
           		x_from_date,
           		x_to_date,
           		p_collect_iso,
           		x_order_type_flag,
           		x_order_type_ids);

            IF (x_retcode1 = -1)
            THEN
               retcode := -1;
               errbuf  := x_errbuf1;
               msd_dem_common_utilities.log_message ('Error(16): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message ('Error while collecting Shipment History - Shipped Items - Requested Date');
               RETURN;
            END IF;
         END IF;
         msd_dem_common_utilities.log_debug ('End collect Shipment History - Shipped Items - Requested Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Shipment History - Requested Items - Shipped Date */
         msd_dem_common_utilities.log_debug ('Begin collect Shipment History - Requested Items - Shipped Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         IF (p_sh_ri_sd = G_YES)
         THEN
            collect_series_data (
           		x_errbuf1,
           		x_retcode1,
           		MSD_DEM_COMMON_UTILITIES.C_SH_RI_SD,
           		x_dest_table,
           		x_dm_time_level,
           		p_sr_instance_id,
           		x_apps_ver,
           		x_instance_type,
           		p_collection_group,
           		p_collection_method,
           		x_from_date,
           		x_to_date,
           		p_collect_iso,
           		x_order_type_flag,
           		x_order_type_ids);

            IF (x_retcode1 = -1)
            THEN
               retcode := -1;
               errbuf  := x_errbuf1;
               msd_dem_common_utilities.log_message ('Error(17): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message ('Error while collecting Shipment History - Requested Items - Shipped Date');
               RETURN;
            END IF;
         END IF;
         msd_dem_common_utilities.log_debug ('End collect Shipment History - Requested Items - Shipped Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Shipment History - Requested Items - Requested Date */
         msd_dem_common_utilities.log_debug ('Begin collect Shipment History - Requested Items - Requested Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         IF (p_sh_ri_rd = G_YES)
         THEN
            collect_series_data (
           		x_errbuf1,
           		x_retcode1,
           		MSD_DEM_COMMON_UTILITIES.C_SH_RI_RD,
           		x_dest_table,
           		x_dm_time_level,
           		p_sr_instance_id,
           		x_apps_ver,
           		x_instance_type,
           		p_collection_group,
           		p_collection_method,
           		x_from_date,
           		x_to_date,
           		p_collect_iso,
           		x_order_type_flag,
           		x_order_type_ids);



            IF (x_retcode1 = -1)
            THEN
               retcode := -1;
               errbuf  := x_errbuf1;
               msd_dem_common_utilities.log_message ('Error(18): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message ('Error while collecting Shipment History - Requested Items - Requested Date');
               RETURN;
            END IF;
         END IF;
         msd_dem_common_utilities.log_debug ('End collect Shipment History - Requested Items - Requested Date - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Bug# 5869314 - Insert dummy rows in the staging table for new items */
         msd_dem_common_utilities.log_debug ('Begin Insert dummy rows for new items into the staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         insert_dummy_rows (
         		x_errbuf1,
         		x_retcode1,
         		x_dest_table,
         		p_sr_instance_id);

         IF (x_retcode1 = 1)
         THEN
            retcode := 1;
            errbuf  := x_errbuf1;
            msd_dem_common_utilities.log_message ('Warning(6): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message ('Error while inserting dummy rows into the sales staging table for new items. ');
         END IF;
         msd_dem_common_utilities.log_debug ('End Insert dummy rows for new items into the staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         COMMIT;

         /* Delete Internal Sales Orders in the same Line of Business */

        if p_collect_iso = 1 then
            msd_dem_common_utilities.log_debug ('Begin Delete Internal Sales Orders in the same Line of Business - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            delete_internal_sales_orders(x_errbuf1,x_retcode1,p_sr_instance_id);

            IF (x_retcode1 = -1)
            THEN
               retcode := -1;
               errbuf  := x_errbuf1;
               msd_dem_common_utilities.log_message ('Error(19): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message ('Error while deleting Internal Sales Orders in the same Line of Business');
               RETURN;
            END IF;

            msd_dem_common_utilities.log_debug ('End Delete Internal Sales Orders in the same Line of Business - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
        end if;

         /* Call Custom Hook for History */

         msd_dem_common_utilities.log_debug ('Begin Call Custom Hook msd_dem_custom_hooks.history_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         msd_dem_custom_hooks.history_hook (
           		x_errbuf1,
           		x_retcode1);

         msd_dem_common_utilities.log_debug ('End Call Custom Hook msd_dem_custom_hooks.history_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         IF (x_retcode1 = -1)
         THEN
            retcode := -1;
            errbuf  := x_errbuf1;
            msd_dem_common_utilities.log_message ('Error(20): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message ('Error in call to custom hook msd_dem_custom_hooks.history_hook ');
            RETURN;
         END IF;

         /* Analyze Sales Staging Table */

         msd_dem_common_utilities.log_debug ('Begin Analyze sales staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         analyze_table (
           		x_errbuf1,
           		x_retcode1,
         	  	x_dest_table);

         msd_dem_common_utilities.log_debug ('End Analyze sales staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         IF (x_retcode1 = 1)
         THEN
            retcode := 1;
            errbuf  := x_errbuf1;
            msd_dem_common_utilities.log_message ('Warning(7): msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message ('Error while analyzing sales staging table. ');
         END IF;

         /*
          *Order Realignment
          */
         Begin

         if (g_schema is not null) then
            g_schema := fnd_profile.value('MSD_DEM_SCHEMA');
         end if;

         if (g_schema is not null)
         then

                -- Bug#8224935 - APP ID
            l_profile_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                'PROFILE_PURGE_HISTORY_DATA',
                                                                                1,
                                                                                'id'));

	 	    l_sql := 'select table_name, from_date, until_date from '|| g_schema || '.transfer_query where id = ' || l_profile_id;
           	execute immediate l_sql into l_table_name, l_start_date, l_until_date;
            -- syenamar

	 	/* Refreshing the Purge Series Data profile to the default value ie No load and No Purge option */
	 	msd_dem_common_utilities.REFRESH_PURGE_SERIES(x_errbuf1, x_retcode1, l_profile_id, g_schema);

	       IF (x_retcode1 = -1)
               THEN
                  retcode := -1;
                  errbuf  := x_errbuf1;

                  msd_dem_common_utilities.log_message ('Error while refreshing Purge Series Data. ');
               END IF;

         	/* Calling API to modify the data profile to purge selected series */
               msd_dem_common_utilities.log_debug ('Calling API_MODIFY_INTEG_SERIES_ATTR - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));



               if p_bh_bi_bd = G_YES
               then
                        /* Bug#8224935 - APP ID */
           		l_bh_bi_bd_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                'SERIES_EBS_BH_BOOK_QTY_BD',
                                                                                1,
                                                                                'forecast_type_id'));

               		l_sql := 'begin ' || g_schema|| '.API_MODIFY_INTEG_SERIES_ATTR('||l_profile_id||', '|| l_bh_bi_bd_id||', 0, 2); end;';
               		execute immediate l_sql;
              end if;

               if p_bh_bi_rd = G_YES
               then
               		/* Bug#8224935 - APP ID */
           		l_bh_bi_rd_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                'SERIES_EBS_BH_BOOK_QTY_RD',
                                                                                1,
                                                                                'forecast_type_id'));

               		l_sql := 'begin ' || g_schema|| '.API_MODIFY_INTEG_SERIES_ATTR('||l_profile_id||', '|| l_bh_bi_rd_id||', 0, 2); end;';
               		execute immediate l_sql;
               end if;

               if p_bh_ri_bd = G_YES
               then
               		/* Bug#8224935 - APP ID */
           		l_bh_ri_bd_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                'SERIES_EBS_BH_REQ_QTY_BD',
                                                                                1,
                                                                                'forecast_type_id'));

               		l_sql := 'begin ' || g_schema|| '.API_MODIFY_INTEG_SERIES_ATTR('||l_profile_id||', '|| l_bh_ri_bd_id||', 0, 2); end;';
               		execute immediate l_sql;
               end if;

               if p_bh_ri_rd = G_YES
               then
               		/* Bug#8224935 - APP ID */
           		l_bh_ri_rd_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                'SERIES_EBS_BH_REQ_QTY_RD',
                                                                                1,
                                                                                'forecast_type_id'));

               		l_sql := 'begin ' || g_schema|| '.API_MODIFY_INTEG_SERIES_ATTR('||l_profile_id||', '|| l_bh_ri_rd_id||', 0, 2); end;';
               		execute immediate l_sql;
               end if;

               if p_sh_si_sd = G_YES
               then
               		/* Bug#8224935 - APP ID */
           		l_sh_si_sd_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                'SERIES_EBS_SH_SHIP_QTY_SD',
                                                                                1,
                                                                                'forecast_type_id'));

               		l_sql := 'begin ' || g_schema|| '.API_MODIFY_INTEG_SERIES_ATTR('||l_profile_id||', '|| l_sh_si_sd_id||', 0, 2); end;';
               		execute immediate l_sql;
               end if;

               if p_sh_si_rd = G_YES
               then
               		/* Bug#8224935 - APP ID */
           		l_sh_si_rd_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                'SERIES_EBS_SH_SHIP_QTY_RD',
                                                                                1,
                                                                                'forecast_type_id'));

               		l_sql := 'begin ' || g_schema|| '.API_MODIFY_INTEG_SERIES_ATTR('||l_profile_id||', '|| l_sh_si_rd_id||', 0, 2); end;';
               		execute immediate l_sql;
                end if;

               if p_sh_ri_sd = G_YES
               then
               		/* Bug#8224935 - APP ID */
           		l_sh_ri_sd_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                'SERIES_SALES',
                                                                                1,
                                                                                'forecast_type_id'));

               		l_sql := 'begin ' || g_schema|| '.API_MODIFY_INTEG_SERIES_ATTR('||l_profile_id||', '|| l_sh_ri_sd_id||', 0, 2); end;';
               		execute immediate l_sql;
               end if;

               if p_sh_ri_rd = G_YES
               then
               		/* Bug#8224935 - APP ID */
           		l_sh_ri_rd_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                'SERIES_EBS_SH_REQ_QTY_RD',
                                                                                1,
                                                                                'forecast_type_id'));

               		l_sql := 'begin ' || g_schema|| '.API_MODIFY_INTEG_SERIES_ATTR('||l_profile_id||', '|| l_sh_ri_rd_id||', 0, 2); end;';
               		execute immediate l_sql;
                end if;



         	/* Calling API to modify the data profile date range */
         	msd_dem_common_utilities.log_debug ('Calling API_MODIFY_INTEG_SERIES_FDATE - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

                l_sql := 'select datet from '|| g_schema ||'.inputs where datet >= '''||x_from_date||''' and rownum = 1 order by datet asc';
                execute immediate l_sql into x_from_date;

                l_sql := 'select datet from '|| g_schema ||'.inputs where datet <= '''||x_to_date||''' and rownum = 1 order by datet desc';
                 execute immediate l_sql into x_to_date;

                if (x_from_date > x_to_date) then
                     x_to_date := x_from_date;
                end if;

                msd_dem_common_utilities.log_message ('For the selected series, the old data will be purged from ''' || x_from_date ||''' to '''||x_to_date ||'''');

         	l_sql := 'begin ' || g_schema|| '.API_MODIFY_INTEG_SERIES_FDATE('||l_profile_id||', '''|| x_from_date||''' , '''||x_to_date||'''); end;';
               	execute immediate l_sql;


         	/* Calling API to notify the application server to refresh its engine */
         	msd_dem_common_utilities.log_debug ('Calling API_NOTIFY_APS_INTEGRATION - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         	l_sql := 'begin ' || g_schema|| '.API_NOTIFY_APS_INTEGRATION('||l_profile_id ||'); end;';
         	msd_dem_common_utilities.log_debug (l_sql);
             	execute immediate l_sql;

      		l_sql := 'truncate table '|| g_schema ||'.'||l_table_name ;
      		msd_dem_common_utilities.log_debug (l_sql);
         	execute immediate l_sql;

         	l_sql := 'insert into '|| g_schema ||'.'||l_table_name||'(sdate, level1)'||
		 	'select '''||x_from_date||''',  teo.organization from '||g_schema||'.t_ep_organization teo '||
		 	'where teo.organization in
		       	       (SELECT  mtp.organization_code
                   		FROM 	msc_instance_orgs mio,
                       	   		msc_trading_partners mtp
                  		WHERE 	mio.sr_instance_id = '||p_sr_instance_id||
                       		' AND 	nvl(mio.org_group, ''-888'') = decode('''||p_collection_group||''', ''-999'', nvl(mio.org_group, ''-888''), '''||p_collection_group||''')'||
                       		' AND 	nvl(mio.dp_enabled_flag, mio.enabled_flag) = 1 '||
                       		' AND   mtp.sr_instance_id = mio.sr_instance_id ' ||
                       		' AND 	mtp.sr_tp_id = mio.organization_id '||
                       		' AND 	mtp.partner_type = 3) ';

            msd_dem_common_utilities.log_debug (l_sql);

		execute immediate l_sql;

         else
               msd_dem_common_utilities.log_message('Demantra Schema not set');
         end if;
         EXCEPTION
         WHEN OTHERS THEN
            retcode := 1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Warning: can not purge old shipment/booking history data.' );
	    msd_dem_common_utilities.log_debug ('Warning: can not purge old shipment/booking history data.' );
	    msd_dem_common_utilities.log_debug (errbuf);
	    msd_dem_common_utilities.log_debug ('Exiting: msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

	    RETURN;
         End;

         retcode := x_retcode;
         errbuf  := x_errbuf;
         msd_dem_common_utilities.log_debug ('Exiting: msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      EXCEPTION
         WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception: msd_dem_collect_history_data.collect_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;

      END COLLECT_HISTORY_DATA;

        PROCEDURE RUN_LOAD (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_auto_run_download     	IN 	   NUMBER )
      IS

         l_sql varchar2(1000);
         DEM_SCHEMA varchar2(100);
         l_url varchar2(1000);
         l_dummy varchar2(100);
         l_user_id number;
         l_user_name varchar2(30);
         l_password varchar2(30);
         -- Bug#7199587    syenamar
         l_schema_name varchar2(255);
         l_schema_id number;



      BEGIN
         msd_dem_common_utilities.log_debug ('Entering: msd_dem_collect_history_data.run_load - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         DEM_SCHEMA := fnd_profile.value('MSD_DEM_SCHEMA');

         IF (p_auto_run_download = G_YES)
         THEN
            if fnd_profile.value('MSD_DEM_SCHEMA') is not null then



           /*

              l_stmt := 'alter session set current_schema=' || DEM_SCHEMA;
	 							execute immediate l_stmt;

               msd_dem_common_utilities.log_message ('Begin - Call DATA_LOAD procedures - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message ('Please check the *_ERR tables for any errors during Data Load');

               msd_dem_common_utilities.log_message ('Calling DATA_LOAD.EP_PREPARE_DATA - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               l_stmt := 'begin ' || DEM_SCHEMA|| '.DATA_LOAD.EP_PREPARE_DATA; end;';
               execute immediate l_stmt;

               msd_dem_common_utilities.log_message ('Calling DATA_LOAD.EP_LOAD_ITEMS - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               l_stmt := 'begin ' || DEM_SCHEMA || '.DATA_LOAD.EP_LOAD_ITEMS; end;';
               execute immediate l_stmt;

               msd_dem_common_utilities.log_message ('Calling DATA_LOAD.EP_LOAD_LOCATION - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               l_stmt := 'begin ' || DEM_SCHEMA || '.DATA_LOAD.EP_LOAD_LOCATION; end;';
               execute immediate l_stmt;

               msd_dem_common_utilities.log_message ('Calling DATA_LOAD.EP_LOAD_SALES - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               l_stmt := 'begin ' || DEM_SCHEMA || '.DATA_LOAD.EP_LOAD_SALES;  end;';

               execute immediate l_stmt;

               msd_dem_common_utilities.log_message ('End - Call DATA_LOAD procedures - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

               commit;

               l_stmt := 'begin ' || DEM_SCHEMA || '.DATA_LOAD.LOG_EP_LOAD_SUCCESS; end;';
               execute immediate l_stmt;

               l_stmt := 'alter session set current_schema=APPS';
   						 execute immediate l_stmt;

   	       */


	        /* Bug#8224935 - APP ID */
	        l_user_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                'COMP_DM',
                                                                                1,
                                                                                'user_id'));

		IF l_user_id is not null
		then
		    l_sql := 'select user_name, password from '||dem_schema||'.user_id where user_id = '||l_user_id;
			     execute immediate l_sql into l_user_name, l_password;

		ELSE
		      /* Bug#8224935 - APP ID */
	              l_user_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                       'COMP_SOP',
                                                                                       1,
                                                                                       'user_id'));

		      If l_user_id is not null
		      then
		      	   l_sql := 'select user_name, password from '||dem_schema||'.user_id where user_id = '||l_user_id;
			   execute immediate l_sql into l_user_name, l_password;
		      else
		      	   msd_dem_common_utilities.log_message('Component is not found.');
		      end if;
		END IF;


		if l_user_name is not null
		then
			l_url := fnd_profile.value('MSD_DEM_HOST_URL');

            -- Bug#7199587    syenamar
            -- Do not hard-code 'EBS Full Download' workflow name here. Get its ID from lookup, get its name from demantra schema using the ID.

            /* Bug#8224935 - APP ID */
            l_schema_name := msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                       'WF_EBS_FULL_DOWNLOAD',
                                                                       1,
                                                                       'schema_name');

            l_schema_name := trim(l_schema_name);
            l_sql := null;
            l_sql := 'SELECT
			                 utl_http.request('''||l_url||'/WorkflowServer?action=run_proc&user='||l_user_name||'&password='||l_password||'&schema='|| replace(l_schema_name, ' ', '%20') ||'&sync=no'') FROM  dual';

            msd_dem_common_utilities.log_message('Launching download workflow - ' || l_schema_name);
            msd_dem_common_utilities.log_debug (l_sql);
            execute immediate l_sql into l_dummy;
            -- syenamar
		else
		       	 msd_dem_common_utilities.log_message('Error in launching the download workflow.');
		       	 retcode := -1;
		       	 Return;
		end if;

            else
               msd_dem_common_utilities.log_message('Demantra Schema not set');
            end if;
         ELSE
            msd_dem_common_utilities.log_message ('Auto Run Download - No ');
            msd_dem_common_utilities.log_message ('Exiting without launching the download workflow.');
         END IF;

         msd_dem_common_utilities.log_debug ('Exiting: msd_dem_collect_history_data.run_load - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      EXCEPTION
         WHEN OTHERS THEN
         		errbuf  := substr(SQLERRM,1,150);
            retcode := -1 ;
           -- l_stmt := 'begin ' || DEM_SCHEMA || '.DATA_LOAD.LOG_EP_LOAD_FAILURE; end;';
           -- execute immediate l_stmt;
   	   --				l_stmt := 'alter session set current_schema=APPS';
   	   --				execute immediate l_stmt;

	    msd_dem_common_utilities.log_message ('Exception: msd_dem_collect_history_data.run_load - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;

      END RUN_LOAD;

END MSD_DEM_COLLECT_HISTORY_DATA;

/
