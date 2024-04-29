--------------------------------------------------------
--  DDL for Package Body MSD_DEM_COLLECT_RETURN_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_COLLECT_RETURN_HISTORY" AS
/* $Header: msddemcrhb.pls 120.9.12010000.7 2010/05/03 10:53:57 nallkuma ship $ */

    /*** PRIVATE PROCEDURES ***/


      /*
       * This procedure given the series id, gets the
       * data from the source instance and upserts into the
       * return history staging table.
       */
      PROCEDURE COLLECT_DATA (
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
      			p_to_date			IN	   DATE)
      IS

         /*** CURSORS ***/

         CURSOR c_get_series_info
         IS
               SELECT
                identifier, MSD_SOURCE_DATE_COL, CUSTOM_VIEW_NAME
               FROM
                  msd_dem_series
               WHERE
                      series_id = p_series_id
                  AND series_type = 1;

         CURSOR c_rma_type
         is
         select rma_types
         from msd_dem_rma_type;

         CURSOR c_accnt_class  --jarora
         is
         select accnt_class_type
         from msd_dem_accnt_classes;


         /*** LOCAL VARIABLES ***/
            x_errbuf		VARCHAR2(200)	:= NULL;
            x_errbuf1		VARCHAR2(200)	:= NULL;
            x_retcode		VARCHAR2(100)	:= NULL;
            x_retcode1		VARCHAR2(100)	:= NULL;
            XDBLINK             VARCHAR2(100)   := NULL;
            x_RMA_type          VARCHAR2(5000);
            x_accnt_class       VARCHAR2(5000);    --jarora
            x_large_sql		VARCHAR2(32000) := NULL;
            x_add_where_clause  VARCHAR2(3000)  := NULL;

            x_dquery_identifier	VARCHAR2(30)	:= NULL;
            x_pquery_identifier	VARCHAR2(30)	:= NULL;

            l_identifier           varchar2(30)    := NULL;
            L_MSD_SOURCE_DATE_COL  VARCHAR2(1000)  := NULL;

            x_key_values	   VARCHAR2(4000)	:= NULL;
            x_is_custom            NUMBER          	:= NULL;
            l_custom_view_name	   VARCHAR2(100)	:= NULL;

      BEGIN

         msd_dem_common_utilities.log_debug ('Entering: msd_dem_collect_return_history.collect_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));



         IF (p_series_id = MSD_DEM_COMMON_UTILITIES.C_SRP_RETURN_HISTORY) --jarora
         THEN

         /* RMA types specified by the user */
         open c_rma_type;
         fetch c_rma_type into x_rma_type;
         close c_rma_type;

         ELSIF ( p_series_id = MSD_DEM_COMMON_UTILITIES.C_SRP_USG_HISTORY_DR)
         THEN

         /* WIP Accounting classes specified by the user */
         open c_accnt_class;
         fetch c_accnt_class into x_accnt_class;
         close c_accnt_class;

         ELSE
             NULL;
         END IF;          --jarora


         OPEN  c_get_series_info;
         FETCH c_get_series_info INTO l_identifier, L_MSD_SOURCE_DATE_COL, l_custom_view_name;
         CLOSE c_get_series_info;


         IF (l_identifier IS NULL)
         THEN
            retcode := -1;
            errbuf  := 'Unable to get the query identifier.';
            msd_dem_common_utilities.log_message ('Error(1): msd_dem_collect_return_history.collect_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
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

         /* For Discrete */
         /* 11i instance where instance type in not 'PROCESS' OR R12 Instance of any type */
         IF (   p_instance_type <> 2
             OR p_apps_ver = 4)
         THEN

           msd_dem_common_utilities.log_debug ('Begin collect discrete history - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS')); --jarora

           IF (p_series_id = MSD_DEM_COMMON_UTILITIES.C_SRP_RETURN_HISTORY) --jarora
           THEN

             If(X_RMA_TYPE <> '''''') then
             	x_add_where_clause := 'OTTL.NAME IN ('|| X_RMA_TYPE ||')';
             else
             	x_add_where_clause := '1=1';
             end if;

           ELSIF (p_series_id = MSD_DEM_COMMON_UTILITIES.C_SRP_USG_HISTORY_DR)
           THEN

             If(X_ACCNT_CLASS <> '''''') then
             	x_add_where_clause := 'WAC.CLASS_CODE IN ('|| X_ACCNT_CLASS ||')';
             else
             	x_add_where_clause := '1=1';
             end if;

           ELSE
               x_add_where_clause := '1=1';
           END IF;                                 --jarora


             IF(p_dm_time_level = 1) then

               x_key_values := '$C_DEST_TABLE#' || p_dest_table
                                  || '$C_SCHEMANAME#' || fnd_profile.value('MSD_DEM_SCHEMA')
                                  || '$C_DEST_DATE_GROUP#' || 'MDBR.SDATE'
                                  || '$C_DEST_DATE#' || 'MDBR.SDATE'
                                  || '$C_SOURCE_DATE#' || ' nvl( ' || substr(l_msd_source_date_col, 0, instr(upper(l_msd_source_date_col), 'SDATE')-1) || ', to_date(''01/01/1000'', ''DD/MM/YYYY'')) ' || ' SDATE'
                                  || '$C_ADD_WHERE_CLAUSE#' || x_add_where_clause
                                  || '$C_SR_INSTANCE_ID#' || to_char(p_sr_instance_id)
                                  || '$C_MASTER_ORG#' || msd_dem_common_utilities.get_parameter_value (p_sr_instance_id, 'MSD_DEM_MASTER_ORG');

               IF (p_collection_method <> 1) THEN
                  x_key_values := x_key_values || '$C_TIME_CLAUSE#' || ' WHERE SDATE BETWEEN '
                                     || 'to_date(''' || to_char(p_from_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                     || ' AND '
                                     || 'to_date(''' || to_char(p_to_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') ';
               ELSE
                  x_key_values := x_key_values || '$C_TIME_CLAUSE#' || '    ';
               END IF;

               x_key_values := x_key_values || '$';

               /* Bug# 6491059 */
               IF (p_series_id IN (MSD_DEM_COMMON_UTILITIES.C_ON_HAND_INVENTORY,
                                   MSD_DEM_COMMON_UTILITIES.C_TOTAL_BACKLOG,
                                   MSD_DEM_COMMON_UTILITIES.C_PAST_DUE_BACKLOG,
                                   MSD_DEM_COMMON_UTILITIES.C_ACTUAL_PRODUCTION,
								   MSD_DEM_COMMON_UTILITIES.C_INSTALL_BASE_HISTORY))
               THEN
                  x_key_values := replace (x_key_values, 'SDATE', 'PDATE');
               END IF;

             ELSE

               x_key_values := '$C_DEST_TABLE#' || p_dest_table
                                  || '$C_SCHEMANAME#' || fnd_profile.value('MSD_DEM_SCHEMA')
                                  || '$C_DEST_DATE_GROUP#' || 'INP.DATET'
                                  || '$C_DEST_DATE#' || 'INP.DATET SDATE'
                                  || '$C_SOURCE_DATE#' || SUBSTR(L_MSD_SOURCE_DATE_COL, 1, instr(L_MSD_SOURCE_DATE_COL, 'SDATE')-1)||' PDATE'
                                  || '$C_ADD_WHERE_CLAUSE#' || x_add_where_clause
                                  || '$C_SR_INSTANCE_ID#' || to_char(p_sr_instance_id)
                                  || '$C_MASTER_ORG#' || msd_dem_common_utilities.get_parameter_value (p_sr_instance_id, 'MSD_DEM_MASTER_ORG');

               IF (p_collection_method <> 1) THEN
                  x_key_values := x_key_values || '$C_TIME_CLAUSE#' || ', msd_dem_dates inp WHERE mdbr.pdate BETWEEN '
                                     || 'to_date(''' || to_char(p_from_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                     || ' AND '
                                     || 'to_date(''' || to_char(p_to_date, 'DD/MM/RRRR') || ''', ''DD/MM/RRRR'') '
                                     || ' AND MDBR.PDATE BETWEEN inp.start_date AND inp.end_date ';
               ELSE
                  x_key_values := x_key_values || '$C_TIME_CLAUSE#' || ', msd_dem_dates inp WHERE mdbr.pdate BETWEEN inp.start_date AND inp.end_date ';
               END IF;

               x_key_values := x_key_values || '$';

               /* Change for streams with LAST aggregation along time */
               IF (p_series_id IN (MSD_DEM_COMMON_UTILITIES.C_ON_HAND_INVENTORY,
                                   MSD_DEM_COMMON_UTILITIES.C_TOTAL_BACKLOG,
                                   MSD_DEM_COMMON_UTILITIES.C_PAST_DUE_BACKLOG))
               THEN
                  l_identifier := l_identifier || '_L';
               END IF;

              END IF;

              /* Get the query */
             msd_dem_query_utilities.get_query2 (
             			x_retcode1,
             			x_large_sql,
             			l_identifier,
             			p_sr_instance_id,
             			x_key_values,
             			x_is_custom,
             			l_custom_view_name);

              IF (   x_retcode1 = '-1'
                 OR x_large_sql IS NULL)
              THEN
                retcode := -1;
                errbuf  := 'Unable to get the query.';
                msd_dem_common_utilities.log_message ('Error(2): msd_dem_collect_return_history.collect_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                msd_dem_common_utilities.log_message (errbuf);
                RETURN;
              END IF;


             msd_dem_common_utilities.log_debug ('Query - ');
             msd_dem_common_utilities.log_debug (x_large_sql);

             msd_dem_common_utilities.log_debug ('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

             BEGIN
                /* insert return history data into return history staging table */
                EXECUTE IMMEDIATE x_large_sql;
             EXCEPTION
                WHEN OTHERS THEN
                   retcode := -1 ;
	           errbuf  := substr(SQLERRM,1,150);
	           msd_dem_common_utilities.log_message ('Exception(1): msd_dem_collect_return_history.collect_data- ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	           msd_dem_common_utilities.log_message (errbuf);
	           msd_dem_common_utilities.log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	           RETURN;
             END;

             msd_dem_common_utilities.log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

             COMMIT;

             /* CTO Change - This update is no longer required from 7.3 onwards,
              * since it uses the new site code format.
              */

             IF (    p_series_id = MSD_DEM_COMMON_UTILITIES.C_RETURN_HISTORY
                 AND msd_dem_common_utilities.is_use_new_site_format = 0)
             THEN

                msd_dem_common_utilities.log_debug ('Start Updating Site codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

                MSD_DEM_UPDATE_LEVEL_CODES.update_code(x_errbuf ,
                      x_retcode,
                      p_SR_instance_id,
                      'SITE',
                      p_dest_table,
                      'LEVEL4',
                      'LEVEL4_SR_PK');

	        msd_dem_common_utilities.log_debug ('End Updating Site codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

             END IF;                 --jarora

             msd_dem_common_utilities.log_debug ('End collect discrete history  - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));  --jarora

         END IF;

      IF (p_series_id = MSD_DEM_COMMON_UTILITIES.C_RETURN_HISTORY)
      THEN
          /* Delete the RMA types stored in the DB table */
          delete from msd_dem_rma_type;
      ELSIF (p_series_id = MSD_DEM_COMMON_UTILITIES.C_SRP_USG_HISTORY_DR)
      THEN
          /* Delete the WIP Accounting classes stored in the DB table */
          delete from msd_dem_accnt_classes;
      ELSE
           NULL;
      END IF;                                             --jarora

        msd_dem_common_utilities.log_debug ('Exiting: msd_dem_collect_return_history.collect_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      EXCEPTION
         WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception(3): msd_dem_collect_return_history.collect_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;

 END COLLECT_DATA;


 PROCEDURE COLLECT_RETURN_HISTORY_DATA (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_sr_instance_id		IN         NUMBER,
      			p_collection_group      	IN         VARCHAR2 DEFAULT '-999', --jarora
      			p_collection_method     	IN         NUMBER,
      			p_date_range_type		IN	   NUMBER,
      			p_collection_window		IN	   NUMBER,
      			p_from_date			IN	   VARCHAR2,
      			p_to_date			IN	   VARCHAR2,
      			p_entity_name                   IN         VARCHAR2 DEFAULT NULL,    --jarora
      			p_truncate                      IN         NUMBER DEFAULT 1 --sopjarora
      			)
      IS

         /*** CURSORS ***/

         CURSOR c_get_table (p_lookup_type	VARCHAR2,
                             p_lookup_code   	VARCHAR2)
         IS
            SELECT meaning                            --jarora
            FROM fnd_lookup_values_vl
            WHERE lookup_type = p_lookup_type
              AND lookup_code = p_lookup_code;

        CURSOR c_get_dm_schema --jarora
         IS
         SELECT owner
         FROM dba_objects
         WHERE  owner = owner
            AND object_type = 'TABLE'
            AND object_name = 'MDP_MATRIX'
         ORDER BY created desc;

        v_applsys_schema    VARCHAR2(32);  --jarora


         /*** LOCAL VARIABLES ****/

            x_errbuf		VARCHAR2(200)	:= NULL;
            x_errbuf1		VARCHAR2(200)	:= NULL;
            x_retcode		VARCHAR2(100)	:= NULL;
            x_retcode1		VARCHAR2(100)	:= NULL;

          --  x_RMA_type          VARCHAR2(5000);
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
            g_dblink            varchar2(30)    := null;
            x_dem_schema	VARCHAR2(50)	:= NULL; --jarora

            lv_retval           BOOLEAN;           --jarora
            lv_dummy1           VARCHAR2(32);
            lv_dummy2           VARCHAR2(32);

            x_series_id         NUMBER         := NULL; --jarora

            l_position          NUMBER         := 0;    --sopjarora
            l_length            NUMBER         := 0;    --sopjarora
            l_table_name       VARCHAR2(100)  := NULL; --sopjarora
            l_series_name       VARCHAR2(100)  := NULL; --sopjarora

      BEGIN

         msd_dem_common_utilities.log_debug ('Entering: msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

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
            msd_dem_common_utilities.log_message ('Error(1): msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN;
         END IF;

         /* Calling procedure to push the profile values, collection enabled orgs and
          * the time data in the source instance, which will be used in the source
          * views.
         */

         MSD_DEM_PUSH_SETUP_PARAMETERS.PUSH_SETUP_PARAMETERS(x_errbuf, x_retcode, p_sr_instance_id, p_collection_group);



         /* VALIDATION OF INPUT PARAMETERS - BEGIN */

         msd_dem_common_utilities.log_debug ('Begin validation of inputs parameters - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));


         /* Show Warning if collection method is Refresh and a date range filter is specified */
         IF (    p_collection_method = 1
             AND (   p_from_date IS NOT NULL
                  OR p_to_date IS NOT NULL
                  OR p_collection_window IS NOT NULL))
         THEN
            x_retcode := 1;
            x_errbuf  := 'Date Range filters are ignored in ''Refresh'' collections';
            msd_dem_common_utilities.log_message ('Warning(1): msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
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
            msd_dem_common_utilities.log_message ('Warning(2): msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (x_errbuf);
         END IF;


         /* Show Warning if collection method is net change, date range type is Absolute and history collection window is specified */
         IF (    p_collection_method = 2
             AND p_date_range_type = 1
             AND p_collection_window IS NOT NULL)
         THEN
            x_retcode := 1;
            x_errbuf  := 'The ''History Collection Window'' field is ignored if ''Absolute'' date range type is selected.';
            msd_dem_common_utilities.log_message ('Warning(3): msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (x_errbuf);
         END IF;


         /* Error if collection method is net change, date range type is Rolling and history collection window is not specified */
         IF (    p_collection_method = 2
             AND p_date_range_type = 2
             AND p_collection_window IS NULL)
         THEN
            retcode := -1;
            errbuf  := 'The ''History Collection Window'' field cannot be NULL, if ''Rolling'' date range type is selected.';
            msd_dem_common_utilities.log_message ('Error(3): msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
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
            msd_dem_common_utilities.log_message ('Error(4): msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
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
                  x_from_date := FND_DATE.canonical_to_date(p_from_date);
               END IF;

               IF (p_to_date IS NULL)
               THEN
                  x_to_date := to_date('31/12/4000', 'DD/MM/YYYY');
               ELSE
                  x_to_date := FND_DATE.canonical_to_date(p_to_date);
               END IF;

               /* Error if p_from_date is greater than p_to_date */
               IF (x_from_date > x_to_date)
               THEN
                  retcode := -1;
                  errbuf  := 'From Date should not be greater than To Date.';
                  msd_dem_common_utilities.log_message ('Error(6): msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                  msd_dem_common_utilities.log_message (errbuf);
                  RETURN;
               END IF;

            ELSE /* Rolling */

               IF (p_collection_window < 0)
               THEN
                  retcode := -1;
                  errbuf  := 'History Collection Window must be a positive number.';
                  msd_dem_common_utilities.log_message ('Error(7): msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
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
            msd_dem_common_utilities.log_message ('Error(8): msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message ('Unable to get instance info.');
            RETURN;
         END IF;

         msd_dem_common_utilities.log_debug ('End get instance info - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         select instr(p_entity_name,':'),length(p_entity_name)  --sopjarora
                INTO l_position,l_length
         FROM DUAL;

         IF l_position <> 0                                  --sopjarora
         THEN
           select substr(p_entity_name,1,l_position - 1),substr(p_entity_name,l_position + 1,l_length)
                INTO l_table_name,l_series_name
           FROM DUAL;
         ELSE
           l_table_name := p_entity_name;
           l_series_name := p_entity_name;
         END IF;

         /* Get the return history staging table name */ --jarora
         OPEN c_get_table ('MSD_DEM_TABLES', l_table_name); --sopjarora
         FETCH c_get_table INTO x_dest_table;
         CLOSE c_get_table;

         OPEN c_get_dm_schema;                       --jarora
         FETCH c_get_dm_schema INTO x_dem_schema;
         CLOSE c_get_dm_schema;

         if (x_dem_schema is not null)
         then
             x_dem_schema := fnd_profile.value('MSD_DEM_SCHEMA');
         end if;

         IF (x_dest_table is NULL)
         THEN
            retcode := -1;
            errbuf  := 'Unable to find the return history staging tables.';
            msd_dem_common_utilities.log_message ('Error(9): msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
         END IF;

         /* Demantra is Installed */
         IF (x_dem_schema IS NOT NULL)
         THEN

		 IF(p_entity_name = 'MSD_DEM_SRP_RETURN_HISTORY' OR
		 p_entity_name = 'MSD_DEM_INS_BASE_HISTORY' OR
		 p_entity_name = 'MSD_DEM_DPT_REP_USG_HISTORY' OR
		 p_entity_name = 'MSD_DEM_FLD_SER_USG_HISTORY')
		 THEN
            lv_retval := fnd_installation.get_app_info('MSD',lv_dummy1,lv_dummy2,v_applsys_schema);
            x_dest_table := v_applsys_schema || '.' || x_dest_table;
         ELSE
            x_dest_table := x_dem_schema || '.' || x_dest_table;
         END IF;

         ELSE
            lv_retval := fnd_installation.get_app_info('MSD',lv_dummy1,lv_dummy2,v_applsys_schema);
            x_dest_table := v_applsys_schema || '.' || x_dest_table;

         END IF; --jarora

         msd_dem_common_utilities.log_message (' Collect History Data - Actions');
         msd_dem_common_utilities.log_message ('--------------------------------');
         msd_dem_common_utilities.log_message (' ');

         msd_dem_common_utilities.log_message ('Date From (DD/MM/RRRR) - ' || to_char(x_from_date, 'DD/MM/RRRR'));
         msd_dem_common_utilities.log_message ('Date To (DD/MM/RRRR)   - ' || to_char(x_to_date, 'DD/MM/RRRR'));

         msd_dem_common_utilities.log_debug ('Begin delete from history staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));         --jarora

         /* bug#9648705 -- nallkuma */
	 IF p_truncate = 1 --sopjarora
         THEN
    	 if p_collection_method = 1 then
                x_sql := 'TRUNCATE TABLE ' || x_dest_table;
    	 else
    	    IF (nvl( fnd_profile.value( 'MSD_DEM_TRUNCATE_STG_TABLE'), 'N') = 'Y')
    	    THEN
    	       x_sql := 'TRUNCATE TABLE ' || x_dest_table;
    	    ELSE
    	       x_sql := 'DELETE FROM '|| x_dest_table || ' where sdate between ''' || x_from_date || ''' AND ''' || x_to_date || '''';

    	    END IF;
    	 end if;
    	  msd_dem_common_utilities.log_debug ('Del/Trn sql - ' || x_sql);
	     EXECUTE IMMEDIATE x_sql;
	  END IF;

	  msd_dem_common_utilities.log_debug ('End delete from history staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));    --jarora


         msd_dem_common_utilities.log_debug ('Begin get dm time level - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Get the lowest time bucket */
         IF (x_dem_schema IS NOT NULL) /* Demantra is Installed */ --jarora
         THEN
           x_dm_time_bucket := msd_dem_common_utilities.dm_time_level;
         ELSE
           x_dm_time_bucket := 'DAY';
         END IF;                            --jarora

         IF (x_dm_time_bucket IS NULL)
         THEN
            retcode := -1;
            errbuf  := 'Unable to get lowest time bucket';
            msd_dem_common_utilities.log_message ('Error(10): msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message (errbuf);
            RETURN;
         ELSIF (upper(x_dm_time_bucket) = 'DAY')
         THEN
            x_dm_time_level := 1;
         ELSE
            x_dm_time_level := 2;
         END IF;

         msd_dem_common_utilities.log_debug ('End get dm time level - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         /* Collect history series */ --jarora
         msd_dem_common_utilities.log_debug ('Begin collect History - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));  --jarora

         IF p_entity_name = 'MSD_DEM_RETURN_HISTORY'
         THEN
           x_series_id := MSD_DEM_COMMON_UTILITIES.C_RETURN_HISTORY;

         ELSIF p_entity_name = 'MSD_DEM_SRP_RETURN_HISTORY'
         THEN
           x_series_id := MSD_DEM_COMMON_UTILITIES.C_SRP_RETURN_HISTORY;

         ELSIF p_entity_name = 'MSD_DEM_DPT_REP_USG_HISTORY'
         THEN
           x_series_id := MSD_DEM_COMMON_UTILITIES.C_SRP_USG_HISTORY_DR;

         ELSIF p_entity_name = 'MSD_DEM_FLD_SER_USG_HISTORY'
         THEN
           x_series_id := MSD_DEM_COMMON_UTILITIES.C_SRP_USG_HISTORY_FS;

         ELSIF p_entity_name = 'MSD_DEM_INS_BASE_HISTORY'
         THEN
           x_series_id := MSD_DEM_COMMON_UTILITIES.C_INSTALL_BASE_HISTORY;

         ELSIF p_entity_name = 'BIIO_SCI_BACKLOG:MSD_TOTAL_BACKLOG' --sopjarora
         THEN
           x_series_id := MSD_DEM_COMMON_UTILITIES.C_TOTAL_BACKLOG;

         ELSIF p_entity_name = 'BIIO_SCI_BACKLOG:MSD_PAST_DUE_BACKLOG'
         THEN
           x_series_id := MSD_DEM_COMMON_UTILITIES.C_PAST_DUE_BACKLOG;

         ELSIF p_entity_name = 'BIIO_SCI:MSD_ON_HAND_INVENTORY'
         THEN
           x_series_id := MSD_DEM_COMMON_UTILITIES.C_ON_HAND_INVENTORY;

         ELSIF p_entity_name = 'BIIO_SCI:MSD_ACTUAL_PRODUCTION'
         THEN
           x_series_id := MSD_DEM_COMMON_UTILITIES.C_ACTUAL_PRODUCTION;

         ELSE
           retcode := -1;
           msd_dem_common_utilities.log_message ('Error(10.1): MSD_DEM_COLLECT_RETURN_HISTORY.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
           msd_dem_common_utilities.log_message ('Error - invalid history series');
           RETURN;

         END IF;                                        --jarora

            collect_data (
           		x_errbuf1,
           		x_retcode1,
           		x_series_id,                     --jarora
           		x_dest_table,
           		x_dm_time_level,
           		p_sr_instance_id,
           		x_apps_ver,
           		x_instance_type,
           		p_collection_group,
           		p_collection_method,
           		x_from_date,
           		x_to_date);

            IF (x_retcode1 = -1)
            THEN
               retcode := -1;
               errbuf  := x_errbuf1;
               msd_dem_common_utilities.log_message ('Error(11): MSD_DEM_COLLECT_RETURN_HISTORY.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_common_utilities.log_message ('Error while collecting History');  --jarora
               RETURN;
            END IF;

         msd_dem_common_utilities.log_debug ('End collect History - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS')); --jarora

         COMMIT;

         msd_dem_common_utilities.log_debug ('Begin Analyze history staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));  --jarora

         msd_dem_collect_history_data.analyze_table (
           		x_errbuf1,
           		x_retcode1,
         	  	x_dest_table);

         msd_dem_common_utilities.log_debug ('End Analyze history staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));  --jarora

         IF (x_retcode1 = -1)
         THEN
            retcode := -1;
            errbuf  := x_errbuf1;
            msd_dem_common_utilities.log_message ('Error(19): msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message ('Error while analyzing history staging table. ');    --jarora
            RETURN;
         END IF;

         retcode := x_retcode;
         errbuf  := x_errbuf;
         msd_dem_common_utilities.log_debug ('Exiting: msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      EXCEPTION
         WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    msd_dem_common_utilities.log_message ('Exception: msd_dem_collect_return_history.collect_return_history_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
	    msd_dem_common_utilities.log_message (errbuf);
	    RETURN;

      END COLLECT_RETURN_HISTORY_DATA;

END MSD_DEM_COLLECT_RETURN_HISTORY;

/
