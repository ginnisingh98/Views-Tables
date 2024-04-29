--------------------------------------------------------
--  DDL for Package Body MSD_DEM_CTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_CTO" AS
/* $Header: msddemctob.pls 120.7.12010000.11 2010/04/30 11:16:28 sjagathe noship $ */


/*** PUBLIC PROCEDURES ***
    *
    * POPULATE_STAGING_TABLE
    * COLLECT_MODEL_BOM_COMPONENTS
    * PURGE_CTO_GL_DATA
    *
    *** PUBLIC PROCEDURES  ***/


   /*
    * Given the entity name, this procedure runs the query for the entity name.
    * Usually this procedure will be used to populate the Demantra CTO staging tables.
    */
   PROCEDURE POPULATE_STAGING_TABLE (
   			errbuf			OUT NOCOPY 	VARCHAR2,
      			retcode			OUT NOCOPY 	VARCHAR2,
      			p_entity_name		IN		VARCHAR2,
      			p_sr_instance_id	IN		NUMBER,
      			p_for_cto		IN		NUMBER DEFAULT 1)
   IS
      x_include_dependent_demand	NUMBER	:= NULL;
      x_is_present			NUMBER	:= NULL;

      x_dem_schema			VARCHAR2(100)	:= NULL;
   BEGIN

      msd_dem_common_utilities.log_debug ('Entering: msd_dem_cto.populate_staging_table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      /* Log the parameters */
      msd_dem_common_utilities.log_debug (' Entity Name - ' || p_entity_name);
      msd_dem_common_utilities.log_debug (' Instance ID - ' || to_char(p_sr_instance_id));
      msd_dem_common_utilities.log_debug (' For CTO - ' || to_char(p_for_cto));

      msd_dem_common_utilities.log_debug('Verify the Entity Name is available in MSD_DEM_ENTITY_QUERIES');
      SELECT 1
         INTO x_is_present
         FROM MSD_DEM_ENTITY_QUERIES
         WHERE entity_name = p_entity_name;


      msd_dem_common_utilities.log_debug('Get the Demantra Schema Name');
      x_dem_schema := fnd_profile.value('MSD_DEM_SCHEMA');
      IF (x_dem_schema IS NULL)
      THEN
         msd_dem_common_utilities.log_message ('Error(1) in msd_dem_cto.populate_staging_table - '
                                                  || 'Unable to get value for Profile MSD_DEM: Schema');
         retcode := -1;
         RETURN;
      END IF;


      IF (p_for_cto = 1)
      THEN

         /* If the query is exclusively meant for CTO, then the query should be run only if
            the profile MSD_DEM: Include Dependent Demand is set to Yes */
         x_include_dependent_demand := fnd_profile.value ('MSD_DEM_INCLUDE_DEPENDENT_DEMAND');

         IF (x_include_dependent_demand = 2) /* Profile is set to No */
         THEN
            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Profile MSD_DEM: Include Dependent Demand is set to No. '
                                                  || 'Hence no action taken. Exiting Normally.');
            retcode := 0;
            RETURN;
         ELSIF (x_include_dependent_demand IS NULL)
         THEN
            msd_dem_common_utilities.log_message ('Error(2) in msd_dem_cto.populate_staging_table - '
                                                  || 'Unable to get value for Profile MSD_DEM: Include Dependent Demand');
            retcode := -1;
            RETURN;
         END IF;


         msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                               || ' Pre-Process - Start ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         IF (p_entity_name = 'EQ_BIIO_CTO_DATA')
         THEN

            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Truncating table BIIO_CTO_DATA_ERR ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || x_dem_schema || '.BIIO_CTO_DATA_ERR';

            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Truncating table BIIO_CTO_DATA ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || x_dem_schema || '.BIIO_CTO_DATA';

            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Truncating table BIIO_CTO_BASE_MODEL_ERR ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || x_dem_schema || '.BIIO_CTO_BASE_MODEL_ERR';

            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Truncating table BIIO_CTO_BASE_MODEL ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || x_dem_schema || '.BIIO_CTO_BASE_MODEL';

            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Truncating table BIIO_CTO_POPULATION_ERR ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || x_dem_schema || '.BIIO_CTO_POPULATION_ERR';

            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Truncating table BIIO_CTO_POPULATION ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || x_dem_schema || '.BIIO_CTO_POPULATION';

            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Truncating table BIIO_CTO_LEVEL_ERR ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || x_dem_schema || '.BIIO_CTO_LEVEL_ERR';

            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Deleting all data from BIIO_CTO_LEVEL ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            EXECUTE IMMEDIATE 'DELETE FROM ' || x_dem_schema  || '.BIIO_CTO_LEVEL';

            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Truncating table BIIO_CTO_CHILD_ERR ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || x_dem_schema || '.BIIO_CTO_CHILD_ERR';

            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Deleting all data from BIIO_CTO_CHILD ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            EXECUTE IMMEDIATE 'DELETE FROM ' || x_dem_schema  || '.BIIO_CTO_CHILD';
            COMMIT;

         ELSE
            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'No Pre-Process Required.');
         END IF;

         msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                               || ' Pre-Process - End ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));


         msd_dem_common_utilities.log_debug('Calling msd_dem_query_utilities.execute_query');
         msd_dem_query_utilities.execute_query (
         				errbuf,
         				retcode,
         				p_entity_name,
         				p_sr_instance_id,
         				NULL );
         IF (retcode = -1)
         THEN
            msd_dem_common_utilities.log_message ('Error(3) in msd_dem_cto.populate_staging_table - '
                                                   || 'Error in call to msd_dem_query_utilities.execute_query');
            msd_dem_common_utilities.log_message(errbuf);
            RETURN;
         ELSE
            msd_dem_common_utilities.log_message ('Query ' || p_entity_name || ' executed successfully.');
         END IF;

         msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                               || ' Post-Process - Start ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         IF (p_entity_name = 'EQ_BIIO_CTO_DATA')
         THEN

            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Deleting Dependent Demand History from T_SRC_SALES_TMPL ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            EXECUTE IMMEDIATE 'DELETE FROM ' || x_dem_schema || '.T_SRC_SALES_TMPL'
                              || ' WHERE ebs_base_model_sr_pk IS NOT NULL '
                              || '    AND to_char(ebs_base_model_sr_pk) <> component_code ';
            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || to_char(SQL%ROWCOUNT) || ' rows deleted from T_SRC_SALES_TMPL');
            COMMIT;

            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Updating item code and site code in T_SRC_SALES_TMPL ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_query_utilities.execute_query (
            					errbuf,
            					retcode,
            					'EQ_SALES_TMPL_ITEM',
            					p_sr_instance_id,
            					null);

            IF (msd_dem_common_utilities.is_use_new_site_format = 0)
            THEN

               msd_dem_common_utilities.log_message ('Update the site codes to descriptive format');

               msd_dem_common_utilities.log_debug ('Start Updating Site codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_update_level_codes.update_code(errbuf ,
                         retcode,
                         p_sr_instance_id,
                         'SITE',
                         msd_dem_common_utilities.get_lookup_value ('MSD_DEM_DM_STAGING_TABLES', 'SALES_STAGING_TABLE'),
                         'DM_SITE_CODE',
                         'EBS_SITE_SR_PK');
               msd_dem_common_utilities.log_debug ('End Updating Site codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            END IF;

         ELSIF (p_entity_name = 'EQ_BIIO_CTO_DATA_EPP')
         THEN

            IF (msd_dem_common_utilities.is_use_new_site_format = 0)
            THEN

               msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                     || 'Updating site codes to descriptive format in BIIO_CTO_DATA ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

               msd_dem_common_utilities.log_debug ('Start Updating Site codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               msd_dem_update_level_codes.convert_site_code(
                         errbuf,
                         retcode,
                         p_sr_instance_id,
                         'SITE',
                         x_dem_schema || '.BIIO_CTO_DATA',
                         'LEVEL5',
                         1);
               msd_dem_common_utilities.log_debug ('End Updating Site codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            END IF;

         ELSE
            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'No Post-Process Required.');
         END IF;

         msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                               || ' Post-Process - End ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      ELSE

         /* If the query is exclusively meant for NON-CTO, then the query should be run only if
            the profile MSD_DEM: Include Dependent Demand is set to No */
         x_include_dependent_demand := fnd_profile.value ('MSD_DEM_INCLUDE_DEPENDENT_DEMAND');

         IF (x_include_dependent_demand = 1) /* Profile is set to Yes */
         THEN
            msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                                  || 'Profile MSD_DEM: Include Dependent Demand is set to Yes. '
                                                  || 'Hence no action taken. Exiting Normally.');
            retcode := 0;
            RETURN;
         ELSIF (x_include_dependent_demand IS NULL)
         THEN
            msd_dem_common_utilities.log_message ('Error(4) in msd_dem_cto.populate_staging_table - '
                                                  || 'Unable to get value for Profile MSD_DEM: Include Dependent Demand');
            retcode := -1;
            RETURN;
         END IF;

         msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                               || ' Pre-Process - Start ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                               || ' Pre-Process - End ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));


         msd_dem_common_utilities.log_debug('Calling msd_dem_query_utilities.execute_query');
         msd_dem_query_utilities.execute_query (
         				errbuf,
         				retcode,
         				p_entity_name,
         				p_sr_instance_id,
         				NULL );
         IF (retcode = -1)
         THEN
            msd_dem_common_utilities.log_message ('Error(5) in msd_dem_cto.populate_staging_table - '
                                                   || 'Error in call to msd_dem_query_utilities.execute_query');
            msd_dem_common_utilities.log_message(errbuf);
            RETURN;
         ELSE
            msd_dem_common_utilities.log_message ('Query ' || p_entity_name || ' executed successfully.');
         END IF;

         msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                               || ' Post-Process - Start ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         IF (    p_entity_name = 'EQ_SALES_TMPL_ITEM'
             AND msd_dem_common_utilities.is_use_new_site_format = 0)
         THEN

            msd_dem_common_utilities.log_message ('Update the site codes to descriptive format');

            msd_dem_common_utilities.log_debug ('Start Updating Site codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_update_level_codes.update_code(errbuf ,
                      retcode,
                      p_sr_instance_id,
                      'SITE',
                      msd_dem_common_utilities.get_lookup_value ('MSD_DEM_DM_STAGING_TABLES', 'SALES_STAGING_TABLE'),
                      'DM_SITE_CODE',
                      'EBS_SITE_SR_PK');
            msd_dem_common_utilities.log_debug ('End Updating Site codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         END IF;

         msd_dem_common_utilities.log_message ('In msd_dem_cto.populate_staging_table - '
                                               || ' Post-Process - End ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      END IF;

      msd_dem_common_utilities.log_debug ('Exiting: msd_dem_cto.populate_staging_table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      retcode := 0;

   EXCEPTION
      WHEN OTHERS THEN
         errbuf := substr(SQLERRM,1,150);
         retcode := -1;

         msd_dem_common_utilities.log_message ('Exception(1): msd_dem_cto.populate_staging_table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         msd_dem_common_utilities.log_message (errbuf);
	 RETURN;

   END POPULATE_STAGING_TABLE;




   /*
    * This procedure populates the table msd_dem_model_bom_components for the base models
    * available in the sales staging table.
    */
   PROCEDURE COLLECT_MODEL_BOM_COMPONENTS (
                        errbuf			OUT NOCOPY 	VARCHAR2,
      			retcode			OUT NOCOPY 	VARCHAR2,
      			p_sr_instance_id	IN		NUMBER,
      			p_flat_file_load	IN		NUMBER DEFAULT 2 )
   IS

      x_is_local		NUMBER		:= to_number(fnd_profile.value('MSD_DEM_EXPLODE_DEMAND_METHOD'));
      x_cpp			NUMBER          := to_number(fnd_profile.value('MSD_DEM_PLANNING_PERCENTAGE'));
      x_dem_schema      	VARCHAR2(100)	:= fnd_profile.value('MSD_DEM_SCHEMA');
      x_curr_user		VARCHAR2(100)	:= NULL;
      x_is_seq_present		NUMBER		:= NULL;
      x_validation_org_id	NUMBER		:= NULL;
      x_sql			VARCHAR2(32000)	:= NULL;
      x_sql1		VARCHAR2(4000)	:= NULL;
      x_sql2		VARCHAR2(4000)	:= NULL;

      x_iterator		NUMBER		:= 1;
      x_num_rows		NUMBER		:= 0;
      x_total_num_rows		NUMBER		:= 0;

   BEGIN

      msd_dem_common_utilities.log_debug ('Entering: msd_dem_cto.collect_model_bom_components - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      /* Log the parameters */
      msd_dem_common_utilities.log_debug (' Instance ID - ' || to_char(p_sr_instance_id));

      /* The procedure should only execute if profile MSD_DEM: Include Dependent Demand is set to yes. */
      IF (fnd_profile.value('MSD_DEM_INCLUDE_DEPENDENT_DEMAND') = 2)
      THEN
         msd_dem_common_utilities.log_message ('In msd_dem_cto.collect_model_bom_components - '
                                                  || 'Profile MSD_DEM: Include Dependent Demand is set to No. '
                                                  || 'Hence no action taken. Exiting Normally.');
         retcode := 0;
         RETURN;
      END IF;

      msd_dem_common_utilities.log_message ('Use Organization Specific BOM - ' || to_char(x_is_local));

      SELECT USER INTO x_curr_user FROM DUAL;
      msd_dem_common_utilities.log_message ('Current User - ' || x_curr_user);

      msd_dem_common_utilities.log_debug ('Truncate table MSD_DEM_MODEL_BOM_COMPONENTS');
      msd_dem_query_utilities.truncate_table (
      					errbuf,
      					retcode,
      					'MSD_DEM_MODEL_BOM_COMPONENTS',
      					2,
      					1);
      IF (retcode = -1)
      THEN
            msd_dem_common_utilities.log_message ('Error(1) in msd_dem_cto.collect_model_bom_components - '
                                                   || 'Error in call to msd_dem_query_utilities.truncate_table');
            msd_dem_common_utilities.log_message(errbuf);
            RETURN;
      END IF;

      msd_dem_common_utilities.log_debug ('Inserting base models in T_SRC_SALES_TMPL to MSD_DEM_MODEL_BOM_COMPONENTS');
      x_sql := 'INSERT /*+ APPEND NOLOGGING */ INTO MSD_DEM_MODEL_BOM_COMPONENTS '
               || ' ( ID, SR_INSTANCE_ID, SR_ORGANIZATION_ID, BASE_MODEL_ID, PARENT_ITEM_ID, COMPONENT_ITEM_ID, IS_BASE_MODEL, OPTIONAL_FLAG, '
               || '   CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, COMPONENT_CODE, PARENT_COMPONENT_CODE ';

      IF (x_cpp = 2)
      THEN
         x_sql := x_sql || ' , IS_IN, EFFECTIVITY_DATE_S, DISABLE_DATE_S, PLNG_PCT_EXISTING_S, PLANNING_FACTOR_S, '
               || '   OPTIONAL_FLAG_S, COMPONENT_CODE_S, PARENT_ITEM_ID_S ';
      END IF;


      /* If flat file load, then populate the column component_code_legacy with concatenated item names */
      IF (p_flat_file_load = 1)
      THEN
         x_sql := x_sql || ' , COMPONENT_CODE_LEGACY ';
      END IF;

      x_sql := x_sql || ' ) SELECT '
               || to_char(x_iterator) || ' , '
               || to_char(p_sr_instance_id) || ' , '
               || ' iv.ebs_org_sr_pk, '
               || ' msi.inventory_item_id, '
               || ' msi.inventory_item_id, '
               || ' msi.inventory_item_id, '
               || ' 1, '
               || ' 2, '
               || 'sysdate, '
               || to_char(fnd_global.user_id) || ' , '
               || 'sysdate, '
               || to_char(fnd_global.user_id) || ' , '
               || to_char(fnd_global.login_id) || ' , '
               || ' msi.sr_inventory_item_id ' || ' , '
               || ' msi.inventory_item_id ';

     IF (x_cpp = 2)
     THEN
         x_sql := x_sql || ' , 1, null, null, null, null, 2, msi.sr_inventory_item_id, msi.inventory_item_id ';
     END IF;

      /* If flat file load, then populate the column component_code_legacy with concatenated item names */
      IF (p_flat_file_load = 1)
      THEN
         x_sql := x_sql || ' , msi.item_name ';
      END IF;

      x_sql := x_sql || ' FROM (SELECT tsst.ebs_org_sr_pk, tsst.ebs_item_sr_pk '
               || '          FROM ' || x_dem_schema || '.T_SRC_SALES_TMPL tsst '
               || '          WHERE tsst.ebs_base_model_sr_pk IS NOT NULL ';

      IF (p_flat_file_load <> 1)
      THEN
         x_sql := x_sql || '             AND to_char(tsst.ebs_base_model_sr_pk) = tsst.component_code  ';
      ELSE
         x_sql := x_sql || '             AND tsst.dm_item_code = tsst.component_code_legacy  ';
      END IF;

      x_sql := x_sql || '          GROUP BY tsst.ebs_org_sr_pk, tsst.ebs_item_sr_pk ) iv, '
               || '    msc_system_items msi '
               || ' WHERE  msi.sr_instance_id = ' || to_char(p_sr_instance_id)
               || '    AND msi.sr_inventory_item_id = iv.ebs_item_sr_pk '
               || '    AND msi.organization_id = iv.ebs_org_sr_pk '
               || '    AND msi.plan_id = -1 '
               || ' UNION '
               || ' SELECT '
               || to_char(x_iterator) || ' , '
               || to_char(p_sr_instance_id) || ' , '
               || ' msi.organization_id, '
               || ' msi.inventory_item_id, '
               || ' msi.inventory_item_id, '
               || ' msi.inventory_item_id, '
               || ' 1, '
               || ' 2, '
               || 'sysdate, '
               || to_char(fnd_global.user_id) || ' , '
               || 'sysdate, '
               || to_char(fnd_global.user_id) || ' , '
               || to_char(fnd_global.login_id) || ' , '
               || ' msi.sr_inventory_item_id ' || ' , '
               || ' msi.inventory_item_id ';

      IF (x_cpp = 2)
      THEN
         x_sql := x_sql || ' , 1, null, null, null, null, 2, msi.sr_inventory_item_id, msi.inventory_item_id ';
      END IF;

      /* If flat file load, then populate the column component_code_legacy with concatenated item names */
      IF (p_flat_file_load = 1)
      THEN
         x_sql := x_sql || ' , msi.item_name ';
      END IF;

      x_sql := x_sql || '          FROM ' || x_dem_schema || '.t_ep_cto tec, '
               || '               ' || x_dem_schema || '.t_ep_cto_base_model tecbm, '
               || '               msc_system_items msi '
               || '          WHERE tec.t_ep_cto_demand_type_id = 1 '
               || '             AND tecbm.t_ep_cto_base_model_id = tec.t_ep_cto_base_model_id '
               || '             AND msi.plan_id = -1 '
               || '             AND msi.sr_instance_id = ' || to_char(p_sr_instance_id)
               || '             AND msi.item_name = tecbm.t_ep_cto_base_model_code '
               || '             AND tec.t_ep_cto_code = ''' || to_char(p_sr_instance_id) || ''' || ''::'' || msi.organization_id '
               || '                                        || ''::'' || msi.sr_inventory_item_id ';

      msd_dem_common_utilities.log_debug ('The query is - ');
      msd_dem_common_utilities.log_debug (x_sql);

      msd_dem_common_utilities.log_debug ('Iterator Value is - ' || to_char(x_iterator));
      msd_dem_common_utilities.log_debug ('Total Number of rows is - ' || to_char(x_total_num_rows));

      msd_dem_common_utilities.log_debug ('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
      EXECUTE IMMEDIATE x_sql;
      x_total_num_rows := x_total_num_rows + SQL%ROWCOUNT;
      msd_dem_common_utilities.log_debug ('Number of rows inserted - ' || to_char(x_total_num_rows));
      msd_dem_common_utilities.log_debug ('Total Number of rows is - ' || to_char(x_total_num_rows));
      COMMIT;
      msd_dem_common_utilities.log_debug ('Query End Time Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));


      msd_dem_common_utilities.log_debug ('Build Query to populate the parent child recursively');
      x_sql := NULL;
      x_sql := 'INSERT /*+ APPEND NOLOGGING */ INTO MSD_DEM_MODEL_BOM_COMPONENTS '
               || ' ( ID, SR_INSTANCE_ID, SR_ORGANIZATION_ID, BASE_MODEL_ID, PARENT_ITEM_ID, COMPONENT_ITEM_ID, IS_BASE_MODEL, '
               || '   EFFECTIVITY_DATE, DISABLE_DATE, PLANNING_FACTOR, PLNG_PCT_EXISTING, OPTIONAL_FLAG, '
               || '   CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, COMPONENT_CODE, PARENT_COMPONENT_CODE ';

      IF (x_cpp = 2)
      THEN
         x_sql := x_sql || ' , IS_IN, EFFECTIVITY_DATE_S, DISABLE_DATE_S, PLNG_PCT_EXISTING_S, PLANNING_FACTOR_S, '
               || '   OPTIONAL_FLAG_S, COMPONENT_CODE_S, PARENT_ITEM_ID_S ';
      END IF;

      /* If flat file load, then populate the column component_code_legacy with concatenated item names */
      IF (p_flat_file_load = 1)
      THEN
         x_sql := x_sql || ' , COMPONENT_CODE_LEGACY ';
      END IF;

      x_sql := x_sql || ' ) SELECT DISTINCT '
               || ' :bvar1, '
               || ' mbc.sr_instance_id, '
               || ' dem.sr_organization_id, '
               || ' dem.base_model_id, '
               || ' mbc.using_assembly_id, '
               || ' mbc.inventory_item_id, '
               || ' decode (citem.bom_item_type, '
               || '         4, '
               || '         decode(citem.pick_components_flag, '
               || '                ''Y'', '
               || '                2, '
               || '                3), '
               || '         2), '
               || ' mbc.effectivity_date, '
               || ' decode (dem.disable_date, null, mbc.disable_date, '
               || '              decode(mbc.disable_date, null, dem.disable_date, least(dem.disable_date, mbc.disable_date))), '
               || ' mbc.planning_factor, '
               || ' decode(mbc.usage_quantity/decode(mbc.usage_quantity, '
               || '                                  null,1, '
               || '                                  0,1, '
               || '                                  abs(mbc.usage_quantity)), '
               || '        1, '
               || '        (mbc.usage_quantity * mbc.Component_Yield_Factor), '
               || '        (mbc.usage_quantity / mbc.Component_Yield_Factor)) '
               || '  * msd_dem_common_utilities.uom_conv(citem.sr_instance_id,citem.uom_code,citem.inventory_item_id), '
               || ' mbc.optional_component, '
               || ' sysdate, '
               ||   to_char(fnd_global.user_id) || ' , '
               || ' sysdate, '
               ||   to_char(fnd_global.user_id) || ' , '
               ||   to_char(fnd_global.login_id) || ' , '
               || ' dem.component_code || ''-'' || citem.sr_inventory_item_id  ';

      IF (x_cpp = 2)
      THEN
        x_sql := x_sql || ' , decode (dem.is_base_model, 1, dem.parent_component_code, decode (dem.is_in, 1, dem.parent_component_code || ''-'' || dem.component_item_id, dem.parent_component_code)) ';
      ELSE
        x_sql := x_sql || ' , decode (dem.is_base_model, 1, dem.parent_component_code, dem.parent_component_code || ''-'' || dem.component_item_id) ';
      END IF;

      IF (x_cpp = 2)
      THEN
         x_sql := x_sql || ' , decode (citem.bom_item_type, 2, 2, 1) '
                        || ' , mbc.effectivity_date '
                        || ' , decode (dem.disable_date_s, null, mbc.disable_date, '
                        || '           decode(mbc.disable_date, null, dem.disable_date_s, least(dem.disable_date_s, mbc.disable_date))) '
                        || ' , decode (pitem.bom_item_type, 2, dem.plng_pct_existing_s, 1) * decode(mbc.usage_quantity/decode(mbc.usage_quantity, '
                        || '              null,1, '
                        || '              0,1, '
                        || '              abs(mbc.usage_quantity)), '
                        || '            1, '
                        || '        (mbc.usage_quantity * mbc.Component_Yield_Factor), '
                        || '        (mbc.usage_quantity / mbc.Component_Yield_Factor)) '
                        || '  * msd_dem_common_utilities.uom_conv(citem.sr_instance_id,citem.uom_code,citem.inventory_item_id) '
                        || ' , decode (pitem.bom_item_type, 2,dem.planning_factor_s /100, 1) * mbc.planning_factor '
                        || ' , decode (mbc.optional_component * dem.optional_flag_s, 4, 2, 1) '
                        || ' , dem.component_code_s || decode (citem.bom_item_type, 2, '''', ''-'' || citem.sr_inventory_item_id) '
                        || ' , decode (pitem.bom_item_type, 2, dem.parent_item_id_s, pitem.inventory_item_id) ';
      END IF;

      /* If flat file load, then populate the column component_code_legacy with concatenated item names */
      IF (p_flat_file_load = 1)
      THEN
         IF (x_cpp = 2)
         THEN
            x_sql := x_sql || ' , dem.component_code_legacy || decode (citem.bom_item_type, 2, '''', ''-'' || citem.item_name) ';
         ELSE
            x_sql := x_sql || ' , dem.component_code_legacy || ''-'' || citem.item_name ';
         END IF;
      END IF;


      x_sql := x_sql || ' FROM msd_dem_model_bom_components dem, '
               || '      msc_boms mb, '
               || '      msc_bom_components mbc, '
               || '      msc_system_items pitem, '
               || '      msc_system_items citem '
               || '  WHERE dem.id = :bvar2 '
               || '     AND mb.plan_id = -1 ';

      IF (x_is_local = 1)
      THEN
         x_sql := x_sql || '     AND mb.organization_id = dem.sr_organization_id ';
      ELSE
         msd_dem_common_utilities.log_debug ('Get the validation org id for the instance');
         SELECT validation_org_id INTO x_validation_org_id
            FROM msc_apps_instances
            WHERE instance_id = p_sr_instance_id;

         IF (x_validation_org_id IS NULL)
         THEN
            retcode := -1;
            msd_dem_common_utilities.log_message ('Error(2): msd_dem_cto.collect_model_bom_components - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            msd_dem_common_utilities.log_message ('Validation Org Id is Null.');
            RETURN;
         END IF;

         x_sql := x_sql || '     AND mb.organization_id =  ' || to_char(x_validation_org_id);

      END IF;

      x_sql := x_sql || '     AND mb.sr_instance_id = ' || to_char(p_sr_instance_id)
               || '     AND mb.assembly_item_id = dem.component_item_id '
               || '     AND mb.alternate_bom_designator IS NULL '
               || '     AND mbc.plan_id = mb.plan_id '
               || '     AND mbc.sr_instance_id = mb.sr_instance_id '
               || '     AND mbc.bill_sequence_id = mb.bill_sequence_id '
               || '     AND mbc.using_assembly_id = mb.assembly_item_id '
               || '     AND nvl(mbc.disable_date, sysdate + 1 ) >= sysdate '
               || '     AND nvl(mbc.effectivity_date, sysdate - 1 ) <= sysdate '
               || '     AND pitem.plan_id = mbc.plan_id '
               || '     AND pitem.sr_instance_id = mbc.sr_instance_id '
               || '     AND pitem.organization_id = mbc.organization_id '
               || '     AND pitem.inventory_item_id = mbc.using_assembly_id '
               || '     AND (pitem.mrp_planning_code <> 6 '
               || '       OR (pitem.mrp_planning_code = 6 '
               || '            AND pitem.pick_components_flag = ''Y'')) '
               || '     AND (pitem.ato_forecast_control <> 3 '
               || '       OR (' || to_char(x_cpp) || ' = 3 '
               || '            AND pitem.bom_item_type = 2)) '
               || '     AND (pitem.bom_item_type <> 4 '
               || '       OR (pitem.bom_item_type = 4 '
               || '          AND pitem.pick_components_flag = ''Y'')) '
               || '     AND citem.plan_id = mbc.plan_id '
               || '     AND citem.sr_instance_id = mbc.sr_instance_id '
               || '     AND citem.organization_id = mbc.organization_id '
               || '     AND citem.inventory_item_id = mbc.inventory_item_id '
               || '     AND (citem.mrp_planning_code <> 6 '
               || '          OR (citem.mrp_planning_code = 6 '
               || '              AND citem.pick_components_flag = ''Y'')) '
               || '     AND (citem.ato_forecast_control = 2 '
               || '           OR (' || to_char(x_cpp) || ' = 3 '
               || '               AND (citem.bom_item_type = 2 '
               || '                    OR mbc.optional_component = 1))) ';

      msd_dem_common_utilities.log_debug('The Query is - ');
      msd_dem_common_utilities.log_debug(x_sql);

      msd_dem_common_utilities.log_debug ('Build Query to mark duplication Option Class as Option');
      x_sql1 := 'UPDATE MSD_DEM_MODEL_BOM_COMPONENTS a'
                || ' SET is_base_model = 3 '
                || ' WHERE EXISTS ( SELECT 1 FROM MSD_DEM_MODEL_BOM_COMPONENTS b '
                || '                WHERE  b.id < :bvar1 '
                || '                   AND b.sr_instance_id = a.sr_instance_id '
                || '                   AND b.sr_organization_id = a.sr_organization_id '
                || '                   AND b.base_model_id = a.base_model_id '
                || '                   AND b.component_item_id = a.component_item_id ) '
                || ' AND a.id = :bvar2 ';

      msd_dem_common_utilities.log_debug('The Query is - ');
      msd_dem_common_utilities.log_debug(x_sql1);

      msd_dem_common_utilities.log_debug ('Build Query to delete duplicate Option Class-Option');
      x_sql2 := 'DELETE FROM MSD_DEM_MODEL_BOM_COMPONENTS a'
                || ' WHERE EXISTS ( SELECT 1 FROM MSD_DEM_MODEL_BOM_COMPONENTS b '
                || '                WHERE  b.id < :bvar1 '
                || '                   AND b.sr_instance_id = a.sr_instance_id '
                || '                   AND b.sr_organization_id = a.sr_organization_id '
                || '                   AND b.base_model_id = a.base_model_id '
                || '                   AND b.parent_item_id = a.parent_item_id '
                || '                   AND b.component_item_id = a.component_item_id ) '
                || ' AND a.id = :bvar2 ';

      msd_dem_common_utilities.log_debug('The Query is - ');
      msd_dem_common_utilities.log_debug(x_sql2);

      msd_dem_common_utilities.log_debug ('Entering Loop');
      LOOP

         x_iterator := x_iterator + 1;

         msd_dem_common_utilities.log_debug ('Iterator Value is - ' || to_char(x_iterator));

         msd_dem_common_utilities.log_debug('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         EXECUTE IMMEDIATE x_sql USING x_iterator, x_iterator - 1;
         x_num_rows := SQL%ROWCOUNT;
         msd_dem_common_utilities.log_debug ('Number of rows inserted - ' || to_char(x_num_rows));
         x_total_num_rows := x_total_num_rows + x_num_rows;
         msd_dem_common_utilities.log_debug ('Total Number of rows is - ' || to_char(x_total_num_rows));
         COMMIT;
         msd_dem_common_utilities.log_debug('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         IF (x_num_rows = 0)
         THEN
            COMMIT;
            msd_dem_common_utilities.log_debug ('Exiting Loop - as reached the bottom of the tree');
            EXIT;
         END IF;

         /*
         msd_dem_common_utilities.log_debug('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         EXECUTE IMMEDIATE x_sql2 USING x_iterator, x_iterator;
         x_num_rows := SQL%ROWCOUNT;
         msd_dem_common_utilities.log_debug ('Number of rows deleted - ' || to_char(x_num_rows));
         COMMIT;
         msd_dem_common_utilities.log_debug('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         msd_dem_common_utilities.log_debug('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         EXECUTE IMMEDIATE x_sql1 USING x_iterator, x_iterator;
         x_num_rows := SQL%ROWCOUNT;
         msd_dem_common_utilities.log_debug ('Number of rows updated - ' || to_char(x_num_rows));
         COMMIT;
         msd_dem_common_utilities.log_debug('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         */

         msd_dem_common_utilities.log_debug(' ');

         IF (x_iterator = 500)
         THEN
            COMMIT;
            msd_dem_common_utilities.log_debug ('Exiting Loop - as reached max iterator');
            EXIT;
         END IF;

      END LOOP;

      x_sql1 := null;

      /* For ERP Collection with profile option Yes, for Consume & Derive Options only */
      IF (p_flat_file_load = 2 AND x_cpp = 2)
      THEN

         /* Update the component_code column in t_src_sales_tmpl with component_code_s */
         x_sql1 := 'UPDATE ' || x_dem_schema || '.T_SRC_SALES_TMPL tsst '
                   || ' SET component_code = (SELECT component_code_s FROM msd_dem_model_bom_components mbc '
                   || '                       WHERE mbc.component_code = tsst.component_code AND rownum < 2 ) ';

      END IF;

      /* For Flat File Collection with profile option Yes, for Consume & Derive Options only */
      IF (p_flat_file_load = 1  AND x_cpp = 2)
      THEN

         /* Update the component_code column in t_src_sales_tmpl with component_code_s */
         x_sql1 := 'UPDATE ' || x_dem_schema || '.T_SRC_SALES_TMPL tsst '
                   || ' SET component_code = (SELECT component_code_s FROM msd_dem_model_bom_components mbc '
                   || '                       WHERE mbc.component_code_legacy = tsst.component_code_legacy AND rownum < 2 ) ';

      END IF;

      /* For Flat File Collection with profile option not set to Yes, for Consume & Derive Options only */
      IF (p_flat_file_load = 1  AND x_cpp <> 2)
      THEN

         /* Update the component_code column in t_src_sales_tmpl with component_code_s */
         x_sql1 := 'UPDATE ' || x_dem_schema || '.T_SRC_SALES_TMPL tsst '
                   || ' SET component_code = (SELECT component_code FROM msd_dem_model_bom_components mbc '
                   || '                       WHERE mbc.component_code_legacy = tsst.component_code_legacy AND rownum < 2 ) ';

      END IF;

      x_num_rows := 0;
      IF (x_sql1 IS NOT NULL)
      THEN

         msd_dem_common_utilities.log_debug('Updating component_code in T_SRC_SALES_TMPL');
         msd_dem_common_utilities.log_debug('The Query is - ');
         msd_dem_common_utilities.log_debug(x_sql1);
         msd_dem_common_utilities.log_debug('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         EXECUTE IMMEDIATE x_sql1;
         x_num_rows := SQL%ROWCOUNT;
         msd_dem_common_utilities.log_debug ('Number of rows updated - ' || to_char(x_num_rows));
         COMMIT;
         msd_dem_common_utilities.log_debug('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      END IF;


      msd_dem_common_utilities.log_debug ('Exiting: msd_dem_cto.collect_model_bom_components - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      retcode := 0;

   EXCEPTION
      WHEN OTHERS THEN
         errbuf := substr(SQLERRM,1,150);
         retcode := -1;

         msd_dem_common_utilities.log_message ('Exception(1): msd_dem_cto.collect_model_bom_components - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         msd_dem_common_utilities.log_message (errbuf);
	 RETURN;

   END COLLECT_MODEL_BOM_COMPONENTS;




   /*
    * This procedure deletes all data from CTO GL Tables. This should only be run by
    * an admin user. The user must make sure that the Demantra AS is down before running
    * the procedure.
    * The procedure is used when the CTO related profile options have been changed which
    * result in changes to the bom structure brought into Demantra.
    *
    * Parameters -
    *    p_complete_refresh - If 1, then all data from CTO GL tables are deleted
    *                       - If 2, do nothing.
    */
   PROCEDURE PURGE_CTO_GL_DATA (
                errbuf              	OUT NOCOPY 	VARCHAR2,
                retcode             	OUT NOCOPY 	VARCHAR2,
                p_complete_refresh	IN		NUMBER )
   IS

      x_schema		VARCHAR2(100) := NULL;
      x_sql		VARCHAR2(500) := NULL;

   BEGIN

      msd_dem_common_utilities.log_debug ('Entering: msd_dem_query_utilities.purge_cto_gl_data  - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      /* Log the parameters */
      msd_dem_common_utilities.log_message ('Table to deleted - T_EP_CTO');
      msd_dem_common_utilities.log_message ('Complete Refresh - ' || to_number(p_complete_refresh));

      IF (p_complete_refresh = 1)
      THEN

         x_schema := fnd_profile.value('MSD_DEM_SCHEMA');
         x_sql := 'DELETE FROM ' || x_schema || '.' || 'T_EP_CTO' || ' WHERE t_ep_cto_id <> 0 ';
         msd_dem_common_utilities.log_message ('The SQL is - ' || x_sql);

         msd_dem_common_utilities.log_message ('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         EXECUTE IMMEDIATE x_sql;
         COMMIT;
         msd_dem_common_utilities.log_message ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

         msd_dem_common_utilities.log_message ('CTO Data deleted successfully.');

      ELSE
         msd_dem_common_utilities.log_message ('Complete Refresh is not set to 1. Hence exiting normally without deleting.');
      END IF;

      msd_dem_common_utilities.log_debug ('Exiting: msd_dem_cto.purge_cto_gl_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      retcode := 0;

   EXCEPTION
      WHEN OTHERS THEN
         errbuf := substr(SQLERRM,1,150);
         retcode := -1;

         msd_dem_common_utilities.log_message ('Exception(1): msd_dem_cto.purge_cto_gl_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         msd_dem_common_utilities.log_message (errbuf);
	 RETURN;

   END PURGE_CTO_GL_DATA;



END MSD_DEM_CTO;

/
