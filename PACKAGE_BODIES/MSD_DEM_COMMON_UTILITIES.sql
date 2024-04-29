--------------------------------------------------------
--  DDL for Package Body MSD_DEM_COMMON_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_COMMON_UTILITIES" AS
/* $Header: msddemcub.pls 120.11.12010000.32 2010/04/28 11:43:11 nallkuma ship $ */


   LG_VAR_SITE_CODE_FORMAT		NUMBER		:= NULL;



   /*** PRIVATE PROCEDURES ***
    * MSD_UOM_CONVERSION
    */

PROCEDURE msd_uom_conversion (from_unit         varchar2,
                              to_unit           varchar2,
                              item_id           number,
                              uom_rate    OUT NOCOPY    number ) IS

from_class              varchar2(10);
to_class                varchar2(10);

CURSOR standard_conversions IS
select  t.conversion_rate      std_to_rate,
        t.uom_class            std_to_class,
        f.conversion_rate      std_from_rate,
        f.uom_class            std_from_class
from  msc_uom_conversions t,
      msc_uom_conversions f
where t.inventory_item_id in (item_id, 0) and
      t.uom_code = to_unit and
      nvl(t.disable_date, trunc(sysdate) + 1) > trunc(sysdate) and
      f.inventory_item_id in (item_id, 0) and
      f.uom_code = from_unit and
      nvl(f.disable_date, trunc(sysdate) + 1) > trunc(sysdate)
order by t.inventory_item_id desc, f.inventory_item_id desc;


std_rec standard_conversions%rowtype;


CURSOR interclass_conversions(p_from_class VARCHAR2, p_to_class VARCHAR2) IS
select decode(from_uom_class, p_from_class, 1, 2) from_flag,
       decode(to_uom_class, p_to_class, 1, 2) to_flag,
       conversion_rate rate
from   msc_uom_class_conversions
where  inventory_item_id = item_id and
       nvl(disable_date, trunc(sysdate) + 1) > trunc(sysdate) and
       ( (from_uom_class = p_from_class and to_uom_class = p_to_class) or
         (from_uom_class = p_to_class   and to_uom_class = p_from_class) );

class_rec interclass_conversions%rowtype;

invalid_conversion      exception;

type conv_tab is table of number index by binary_integer;
type class_tab is table of varchar2(10) index by binary_integer;

interclass_rate_tab     conv_tab;
from_class_flag_tab     conv_tab;
to_class_flag_tab       conv_tab;
from_rate_tab           conv_tab;
to_rate_tab             conv_tab;
from_class_tab          class_tab;
to_class_tab            class_tab;

std_index               number;
class_index             number;

from_rate               number := 1;
to_rate                 number := 1;
interclass_rate         number := 1;
to_class_rate           number := 1;
from_class_rate         number := 1;
msgbuf                  varchar2(500);

begin

    /*
    ** Conversion between between two UOMS.
    **
    ** 1. The conversion always starts from the conversion defined, if exists,
    **    for an specified item.
    ** 2. If the conversion id not defined for that specific item, then the
    **    standard conversion, which is defined for all items, is used.
    ** 3. When the conversion involves two different classes, then
    **    interclass conversion is activated.
    */

    /* If from and to units are the same, conversion rate is 1.
       Go immediately to the end of the procedure to exit.*/

    if (from_unit = to_unit) then
      uom_rate := 1;
  goto  procedure_end;
    end if;


    /* Get item specific or standard conversions */
    open standard_conversions;
    std_index := 0;
    loop

        std_index := std_index + 1;

        fetch standard_conversions into std_rec;
        exit when standard_conversions%notfound;

        from_rate_tab(std_index) := std_rec.std_from_rate;
        from_class_tab(std_index) := std_rec.std_from_class;
        to_rate_tab(std_index) := std_rec.std_to_rate;
        to_class_tab(std_index) := std_rec.std_to_class;

    end loop;

    close standard_conversions;

    if (std_index = 0) then    /* No conversions defined  */
       msgbuf := msgbuf||'Invalid standard conversion : ';
       msgbuf := msgbuf||'From UOM code: '||from_unit||' ';
       msgbuf := msgbuf||'To UOM code: '||to_unit||' ';
       raise invalid_conversion;

    else
        /* Conversions are ordered.
           Item specific conversions will be returned first. */

        from_class := from_class_tab(1);
        to_class := to_class_tab(1);
        from_rate := from_rate_tab(1);
        to_rate := to_rate_tab(1);

    end if;


    /* Load interclass conversion tables */
    if (from_class <> to_class) then
        class_index := 0;
        open interclass_conversions (from_class, to_class);
        loop

            fetch interclass_conversions into class_rec;
            exit when interclass_conversions%notfound;

            class_index := class_index + 1;

            to_class_flag_tab(class_index) := class_rec.to_flag;
            from_class_flag_tab(class_index) := class_rec.from_flag;
            interclass_rate_tab(class_index) := class_rec.rate;

        end loop;
        close interclass_conversions;

        /* No interclass conversion is defined */
        if (class_index = 0 ) then
            msgbuf := msgbuf||'Invalid Interclass conversion : ';
            msgbuf := msgbuf||'From UOM code: '||from_unit||' ';
            msgbuf := msgbuf||'To UOM code: '||to_unit||' ';
            raise invalid_conversion;
        else
            if ( to_class_flag_tab(1) = 1 and from_class_flag_tab(1) = 1 ) then
               to_class_rate := interclass_rate_tab(1);
               from_class_rate := 1;
            else
               from_class_rate := interclass_rate_tab(1);
               to_class_rate := 1;
            end if;
            interclass_rate := from_class_rate/to_class_rate;
        end if;
    end if;  /* End of from_class <> to_class */

    /*
    ** conversion rates are defaulted to '1' at the start of the procedure
    ** so seperate calculations are not required for standard/interclass
    ** conversions
    */

    if (to_rate <> 0 ) then
       uom_rate := (from_rate * interclass_rate) / to_rate;
    else
       uom_rate := 1;
    end if;


    /* Put a label and a null statement over here so that you can
       the goto statements can branch here */
<<procedure_end>>

    null;

exception

    when others then
         uom_rate := 1;

END msd_uom_conversion;


   /*** PUBLIC PROCEDURES ***
    * LOG_MESSAGE
    * LOG_DEBUG
    * GET_DBLINK
    * GET_INSTANCE_INFO
    */


      /*
       * This procedure logs a given message text in the concurrent request log file.
       * param: p_buff - message text to be logged.
       */
       PROCEDURE LOG_MESSAGE ( p_buff           IN  VARCHAR2)
       IS
       BEGIN
          fnd_file.put_line (fnd_file.log, p_buff);
       END LOG_MESSAGE;


      /*
       * This procedure logs a given debug message text in the concurrent request log file
       * only if the profile MSD_DEM_DEBUG is set to 'Yes'.
       * param: p_buff - debug message text to be logged.
       */
       PROCEDURE LOG_DEBUG ( p_buff           IN  VARCHAR2)
       IS
       BEGIN
          IF (C_MSD_DEM_DEBUG = 'Y') THEN
             fnd_file.put_line (fnd_file.output, p_buff);
          END IF;
       END LOG_DEBUG;


       /*
        * This procedure gets the db link to the given source instance
        */
       PROCEDURE GET_DBLINK (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_sr_instance_id	IN	    NUMBER,
      			p_dblink		OUT  NOCOPY VARCHAR2)
       IS
       BEGIN
          SELECT decode ( m2a_dblink, null, '', '@' || m2a_dblink)
          INTO p_dblink
          FROM msc_apps_instances
          WHERE instance_id = p_sr_instance_id;

       EXCEPTION
          WHEN OTHERS THEN
             retcode := -1 ;
	     errbuf  := substr(SQLERRM,1,150);
	     RETURN;
       END GET_DBLINK;


      /*
       * This procedure gets the instance info given the source instance id
       */
      PROCEDURE GET_INSTANCE_INFO (
      			errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
                        p_instance_code		OUT  NOCOPY VARCHAR2,
                        p_apps_ver		OUT  NOCOPY NUMBER,
                        p_dgmt			OUT  NOCOPY NUMBER,
                        p_instance_type		OUT  NOCOPY NUMBER,
                        p_sr_instance_id	IN	    NUMBER)
      IS
      BEGIN

         SELECT
            instance_code,
            apps_ver,
            gmt_difference/24.0,
            instance_type
            INTO
               p_instance_code,
               p_apps_ver,
               p_dgmt,
               p_instance_type
            FROM msc_apps_instances
            WHERE instance_id= p_sr_instance_id;
      EXCEPTION
         WHEN OTHERS THEN
            retcode := -1 ;
	    errbuf  := substr(SQLERRM,1,150);
	    RETURN;
      END GET_INSTANCE_INFO;


            /*
       * This procedure will refresh Purge Series Data data profile to its defualt value
       * i.e. it will set the data profile option to No Load and No Purge for all series
       * included in the profile.
       */

       PROCEDURE REFRESH_PURGE_SERIES (
                        errbuf         		OUT  NOCOPY VARCHAR2,
      			retcode        		OUT  NOCOPY VARCHAR2,
      			p_profile_id            IN   NUMBER,
      			p_schema		IN   VARCHAR2)
       IS

       TYPE REF_CURSOR_TYPE IS REF CURSOR;

       c_ref_cursor	REF_CURSOR_TYPE;

       x_sql varchar2(500);
       l_sql varchar2(500);
       x_series_id number;

       BEGIN

       x_sql :=  'select series_id from ' ||p_schema ||'.transfer_query_series where id = ' || p_profile_id;

       OPEN c_ref_cursor FOR x_sql;

         LOOP
      		FETCH c_ref_cursor INTO x_series_id;
                EXIT WHEN c_ref_cursor%NOTFOUND;

                l_sql := 'begin ' || p_schema|| '.API_MODIFY_INTEG_SERIES_ATTR('||p_profile_id||', '|| x_series_id||', 2, 0); end;';
               		execute immediate l_sql;
         end loop;

      close c_ref_cursor;

      END;

    /*
    * Update the synonyms MSD_DEM_TRANSFER_LIST and MSD_DEM_TRANSFER_QUERY
    * to point to the Demantra's tables TRANSFER_LIST and TRANSFER_QUERY
    * if Demantra is installed.
    * Sets the profile MSD_DEM_SCHEMA to the Demantra Schema Name
    * The checks if the table MDP_MATRIX exists in the Demantra Schema
    */

    PROCEDURE UPDATE_SYNONYMS (
            errbuf         		OUT  NOCOPY VARCHAR2,
            retcode        		OUT  NOCOPY VARCHAR2,
            p_demantra_schema		IN	    VARCHAR2	DEFAULT NULL)

    IS

        CURSOR c_get_dm_schema
           IS
              SELECT owner
                 FROM dba_objects
                 WHERE  owner = owner
                    AND object_type = 'TABLE'
                    AND object_name = 'MDP_MATRIX'
                 ORDER BY created desc;

        CURSOR c_is_cols_present (p_owner	VARCHAR2,
                                  p_table_name  VARCHAR2,
                                  p_column_name VARCHAR2,
                                  p_data_type   VARCHAR2)
           IS
              SELECT count(1)
                 FROM dba_tab_columns
                 WHERE owner = p_owner
                    AND table_name = p_table_name
                    AND column_name = p_column_name
                    AND data_type = p_data_type;

        CURSOR c_is_table_present (p_owner      VARCHAR2,
                                   p_table_name VARCHAR2)
           IS
              SELECT count(1)
                 FROM dba_tables
                 WHERE owner = p_owner
                    AND table_name = p_table_name;


        x_dem_schema		    VARCHAR2(50)	:= NULL;
        x_create_synonym_sql	VARCHAR2(200)	:= NULL;
        x_grant_execute_sql 	VARCHAR2(200)   := NULL;
		x_get_dem_ver_sql       VARCHAR2(200) 	:= NULL;
        x_dem_version   		VARCHAR2(20) 	:= NULL;
		x_appl_home_page_mode	VARCHAR2(20) 	:= NULL;
        x_appl_home_page_url	VARCHAR2(200) 	:= NULL;
        x_ext_logout_url_sql	VARCHAR2(200) 	:= NULL;
        x_sql					VARCHAR2(1000)	:= NULL;
        x_curr_val				VARCHAR2(50)	:= NULL;
        x_success				BOOLEAN			:= NULL;
        x_count1				NUMBER			:= NULL;
        x_count2				NUMBER			:= NULL;
        x_col_present_flag 		NUMBER			:= NULL;


        BEGIN

            IF (p_demantra_schema IS NULL)
            THEN
               OPEN c_get_dm_schema;
               FETCH c_get_dm_schema INTO x_dem_schema;
               CLOSE c_get_dm_schema;
            ELSE
               x_dem_schema := p_demantra_schema;
            END IF;

            log_message ('The Demantra Schema Name is - ' || x_dem_schema);

            /* Demantra is Installed */
            IF (x_dem_schema IS NOT NULL)
            THEN


                /* Update synonym MSD_DEM_TRANSFER_LIST to point to Demantra table TRANSFER_LIST */
                x_create_synonym_sql := 'CREATE OR REPLACE SYNONYM MSD_DEM_TRANSFER_LIST FOR ' ||
                                                             x_dem_schema || '.TRANSFER_LIST';

                EXECUTE IMMEDIATE x_create_synonym_sql;
                log_message ('Updated synonym MSD_DEM_TRANSFER_LIST');


                /* Update synonym MSD_DEM_TRANSFER_QUERY to point to Demantra table TRANSFER_QUERY */
                x_create_synonym_sql := 'CREATE OR REPLACE SYNONYM MSD_DEM_TRANSFER_QUERY FOR ' ||
                                                                 x_dem_schema || '.TRANSFER_QUERY';

                EXECUTE IMMEDIATE x_create_synonym_sql;
                log_message ('Updated synonym MSD_DEM_TRANSFER_QUERY');


                /* Update synonym MSD_DEM_TRANSFER_QUERY_LEVELS to point to Demantra table TRANSFER_QUERY_LEVELS */
                x_create_synonym_sql := 'CREATE OR REPLACE SYNONYM MSD_DEM_TRANSFER_QUERY_LEVELS FOR ' ||
                                                                 x_dem_schema || '.TRANSFER_QUERY_LEVELS';

                EXECUTE IMMEDIATE x_create_synonym_sql;
                log_message ('Updated synonym MSD_DEM_TRANSFER_QUERY_LEVELS');


                /* Update synonym MSD_DEM_GROUP_TABLES to point to Demantra table GROUP_TABLES */
                x_create_synonym_sql := 'CREATE OR REPLACE SYNONYM MSD_DEM_GROUP_TABLES FOR ' ||
                                                                 x_dem_schema || '.GROUP_TABLES';

                EXECUTE IMMEDIATE x_create_synonym_sql;
                log_message ('Updated synonym MSD_DEM_GROUP_TABLES');


                /* Update synonym T_SRC_SALES_TMPL to point to Demantra table T_SRC_SALES_TMPL */
                x_create_synonym_sql := 'CREATE OR REPLACE SYNONYM T_SRC_SALES_TMPL  FOR '||
                                                                 x_dem_schema || '.T_SRC_SALES_TMPL';

                EXECUTE IMMEDIATE x_create_synonym_sql;
                log_message ('Updated synonym T_SRC_SALES_TMPL');


                /* Update synonym MSD_DEM_RETURN_HISTORY to point to Demantra table MSD_DEM_RETURN_HISTORY */
                x_create_synonym_sql := 'CREATE OR REPLACE SYNONYM MSD_DEM_RETURN_HISTORY FOR ' ||
                                                                 x_dem_schema || '.MSD_DEM_RETURN_HISTORY';

                EXECUTE IMMEDIATE x_create_synonym_sql;
                log_message ('Updated synonym MSD_DEM_RETURN_HISTORY');



                /* Grant execute permissions to Demantra Schema on pakcage MSD_DEM_UPLOAD_FORECAST */
                x_grant_execute_sql := 'GRANT EXECUTE ON MSD_DEM_UPLOAD_FORECAST TO ' || x_dem_schema;
                EXECUTE IMMEDIATE x_grant_execute_sql;
                log_message ('Execute privilege granted on package MSD_DEM_UPLOAD FORECAST to ' || x_dem_schema || ' schema.');



                /* Set the profile MSD_DEM_SCHEMA if not set */
                x_curr_val := fnd_profile.value('MSD_DEM_SCHEMA');

                IF (nvl(x_curr_val, '$$$') <> x_dem_schema)
                    THEN
                     x_success := fnd_profile.save ('MSD_DEM_SCHEMA', x_dem_schema, 'SITE');
                     log_message ('Profile MSD_DEM: Schema has been set to ''' || x_dem_schema || ''' at the SITE level');

                     /*Setting global parameter */
                     C_MSD_DEM_SCHEMA := x_dem_schema ;
                     log_message ('Global Parameter C_MSD_DEM_SCHEMA has been set to ' || x_dem_schema );

                END IF;

				/* Set the profile MSD_DEM_VERSION */ -- nallkuma
                x_get_dem_ver_sql := 'select version from ' || x_dem_schema || '.version_details' ;
                EXECUTE IMMEDIATE x_get_dem_ver_sql into x_dem_version ;

				        x_dem_version := SUBSTR(x_dem_version, 1, INSTR(x_dem_version, '.', 1, 2)-1) ;

                x_success := fnd_profile.save ('MSD_DEM_VERSION', x_dem_version, 'SITE');
				        log_message ('Profile MSD_DEM: Version has been set to ''' || x_dem_version || ''' at the SITE level');

        /* 	Set the ExternalLogoutUrl parameter in demantra schema to the applications home page */ -- nallkuma 16-feb-2009
		/*       1st IF condtion :- This is only for  demantra 7.3.X & above versions */ -- bug#7458724
		/* 	2nd IF condtion :- Sets the ExternalLogoutUrl parameter to appl home page only if the appl home page mode is set "FWD"  or else it will be null */

                IF (TO_NUMBER(x_dem_version) >= 7.3)
				        THEN
					           x_appl_home_page_mode := fnd_profile.value('APPLICATIONS_HOME_PAGE') ;
					           IF (x_appl_home_page_mode = 'FWK' OR x_appl_home_page_mode is null)
	                   THEN
            						x_appl_home_page_url := fnd_profile.value('APPS_FRAMEWORK_AGENT') ;
            	          x_appl_home_page_url := trim(x_appl_home_page_url) || '/OA_HTML/OA.jsp?OAFunc=OAHOMEPAGE';
            						x_ext_logout_url_sql := ' Update '|| x_dem_schema || '.sys_params' ||
                        												' Set pval = ''' || x_appl_home_page_url ||
                        												''' Where pname like ''ExternalLogoutUrl'' ' ;
						            EXECUTE IMMEDIATE x_ext_logout_url_sql ;
						            commit;
						            log_message ('Updated ExternalLogoutUrl parameter in sys_params table to :- ' ||x_appl_home_page_url);
					           END IF;
				        END IF;

                -- BUG#9000156    syenamar
                --Add new plan type lookup for RP in demantra (7.3)
                log_message('Checking for plan type lookup ''Rapid Plan'' in demantra');

                x_sql := 'select count(1) from ' || x_dem_schema || '.plan_type_lookup where type_id = 2';
                execute immediate x_sql into x_count1;

                IF (x_count1 = 0) THEN
                   BEGIN
                       log_message('Adding plan type lookup ''Rapid Plan'' in demantra');
                       x_sql := 'INSERT INTO ' || x_dem_schema || '.plan_type_lookup (type_id, type_desc) values (2, ''Rapid Plan'')';
                       execute immediate x_sql;
                       commit;
                   EXCEPTION
                       WHEN OTHERS THEN
                           log_message('Error when adding plan type lookup ''Rapid Plan'' in demantra - ' || substr(sqlerrm, 1, 150));
                   END;
                END IF;

                x_count1 := NULL;
                --syenamar

               /* In case of Demantra 7.2.X, add the following columns
                 *    Table - T_SRC_SALES_TMPL, Columns to be added - COMPONENT_CODE, EBS_BASE_MODEL_SR_PK, COMPONENT_CODE_LEGACY and EBS_BASE_MODEL_CODE
                 *    Table - T_SRC_SALES_TMPL_ERR, Columns to be added - COMPONENT_CODE, EBS_BASE_MODEL_SR_PK, COMPONENT_CODE_LEGACY and EBS_BASE_MODEL_CODE
                 */
                OPEN c_is_cols_present (x_dem_schema, 'T_SRC_SALES_TMPL', 'COMPONENT_CODE', 'VARCHAR2');
                FETCH c_is_cols_present INTO x_count1;
                CLOSE c_is_cols_present;

                IF (x_count1 = 0)
                THEN

                   /* Start with dropping the standard error columns in the ERR table */
                   x_sql := 'ALTER TABLE ' || x_dem_schema || '.T_SRC_SALES_TMPL_ERR '
                               || ' DROP (ERROR_CODE_RECORD, LOAD_DATE, ERROR_MESSAGE_RECORD) ';
                   EXECUTE IMMEDIATE x_sql;
                   log_message ('Dropping columns ERROR_CODE_RECORD, LOAD_DATE and ERROR_MESSAGE_RECORD from Demantra table T_SRC_SALES_TMPL_ERR');


                   /* Column - COMPONENT_CODE */
                   EXECUTE IMMEDIATE 'ALTER TABLE ' || x_dem_schema || '.T_SRC_SALES_TMPL '
                               || ' ADD (COMPONENT_CODE VARCHAR2(2000)) ';
                   log_message ('Adding column COMPONENT_CODE to T_SRC_SALES_TMPL');

                   EXECUTE IMMEDIATE 'ALTER TABLE ' || x_dem_schema || '.T_SRC_SALES_TMPL_ERR '
                               || ' ADD (COMPONENT_CODE VARCHAR2(2000)) ';
                   log_message ('Adding column COMPONENT_CODE to T_SRC_SALES_TMPL_ERR');


                   /* Column - EBS_BASE_MODEL_SR_PK */
                   OPEN c_is_cols_present (x_dem_schema, 'T_SRC_SALES_TMPL', 'EBS_BASE_MODEL_SR_PK', 'NUMBER');
                   FETCH c_is_cols_present INTO x_count2;
                   CLOSE c_is_cols_present;

                   IF (x_count2 = 0)
                   THEN

                      /* Column - EBS_BASE_MODEL_SR_PK */
                      EXECUTE IMMEDIATE 'ALTER TABLE ' || x_dem_schema || '.T_SRC_SALES_TMPL '
                                  || ' ADD (EBS_BASE_MODEL_SR_PK NUMBER) ';
                      log_message ('Adding column EBS_BASE_MODEL_SR_PK to T_SRC_SALES_TMPL');

                      EXECUTE IMMEDIATE 'ALTER TABLE ' || x_dem_schema || '.T_SRC_SALES_TMPL_ERR '
                                  || ' ADD (EBS_BASE_MODEL_SR_PK NUMBER) ';
                      log_message ('Adding column EBS_BASE_MODEL_SR_PK to T_SRC_SALES_TMPL_ERR');

                   END IF;


                   /* Column - COMPONENT_CODE_LEGACY */
                   OPEN c_is_cols_present (x_dem_schema, 'T_SRC_SALES_TMPL', 'COMPONENT_CODE_LEGACY', 'VARCHAR2');
                   FETCH c_is_cols_present INTO x_count2;
                   CLOSE c_is_cols_present;

                   IF (x_count2 = 0)
                   THEN

                      /* Column - COMPONENT_CODE_LEGACY */
                      EXECUTE IMMEDIATE 'ALTER TABLE ' || x_dem_schema || '.T_SRC_SALES_TMPL '
                                  || ' ADD (COMPONENT_CODE_LEGACY VARCHAR2(4000)) ';
                      log_message ('Adding column COMPONENT_CODE_LEGACY to T_SRC_SALES_TMPL');

                      EXECUTE IMMEDIATE 'ALTER TABLE ' || x_dem_schema || '.T_SRC_SALES_TMPL_ERR '
                                  || ' ADD (COMPONENT_CODE_LEGACY VARCHAR2(4000)) ';
                      log_message ('Adding column COMPONENT_CODE_LEGACY to T_SRC_SALES_TMPL_ERR');

                   END IF;


                   /* Column - EBS_BASE_MODEL_CODE */
                   OPEN c_is_cols_present (x_dem_schema, 'T_SRC_SALES_TMPL', 'EBS_BASE_MODEL_CODE', 'VARCHAR2');
                   FETCH c_is_cols_present INTO x_count2;
                   CLOSE c_is_cols_present;

                   IF (x_count2 = 0)
                   THEN

                      /* Column - EBS_BASE_MODEL_CODE */
                      EXECUTE IMMEDIATE 'ALTER TABLE ' || x_dem_schema || '.T_SRC_SALES_TMPL '
                                  || ' ADD (EBS_BASE_MODEL_CODE VARCHAR2(240)) ';
                      log_message ('Adding column EBS_BASE_MODEL_CODE to T_SRC_SALES_TMPL');

                      EXECUTE IMMEDIATE 'ALTER TABLE ' || x_dem_schema || '.T_SRC_SALES_TMPL_ERR '
                                  || ' ADD (EBS_BASE_MODEL_CODE VARCHAR2(240)) ';
                      log_message ('Adding column EBS_BASE_MODEL_CODE to T_SRC_SALES_TMPL_ERR');

                   END IF;

                   /* Add back the standard error columns in the ERR table */
                   x_sql := 'ALTER TABLE ' || x_dem_schema || '.T_SRC_SALES_TMPL_ERR '
                               || ' ADD (ERROR_CODE_RECORD NUMBER(2), LOAD_DATE DATE, ERROR_MESSAGE_RECORD VARCHAR2(2000)) ';
                   EXECUTE IMMEDIATE x_sql;
                   log_message ('Adding columns ERROR_CODE_RECORD, LOAD_DATE and ERROR_MESSAGE_RECORD to Demantra table T_SRC_SALES_TMPL_ERR');

                END IF;



                log_message ('Check, drop and recreate the table EP_T_SRC_SALES_TMPL_LD - ');
                x_count2 := -1;
                x_sql := 'SELECT COUNT(1) FROM ( SELECT COLUMN_NAME FROM DBA_TAB_COLUMNS WHERE owner = ''' || x_dem_schema || ''' and table_name = ''T_SRC_SALES_TMPL'' '
                                               || ' MINUS '
                                               || ' SELECT COLUMN_NAME FROM DBA_TAB_COLUMNS WHERE owner = ''' || x_dem_schema || ''' and table_name = ''EP_T_SRC_SALES_TMPL_LD'' ) ';
                log_debug (x_sql);
                EXECUTE IMMEDIATE x_sql INTO x_count2;

                IF (x_count2 <> 0)
                THEN

                   log_message ('Dropping table EP_T_SRC_SALES_TMPL_LD');
                   EXECUTE IMMEDIATE 'DROP TABLE ' || x_dem_schema || '.EP_T_SRC_SALES_TMPL_LD';

                   log_message ('Creating table EP_T_SRC_SALES_TMPL_LD');
                   x_sql := 'CREATE TABLE ' || x_dem_schema || '.EP_T_SRC_SALES_TMPL_LD '
                                     || ' AS '
                                     || ' SELECT tsst.*, TRUNC(tsst.sales_date) AGGRE_SD '
                                     || ' FROM ' || x_dem_schema || '.T_SRC_SALES_TMPL tsst '
                                     || ' WHERE 1 = 2 ';
                   log_debug (x_sql);
                   EXECUTE IMMEDIATE x_sql;

                END IF;


			/*  In case of Demantra 7.2.X, add the following column
			 *  Table - T_SRC_LOC_TMPL, Column to be added - T_EP_LR2A_DESC
			 *  Table - T_SRC_LOC_TMPL_ERR, Column to be added - T_EP_LR2A_DESC
			 *  Table - T_SRC_LOC_TMPL_ERR, Columns dropped/added -   ERROR_CODE_RECORD , LOAD_DATE & ERROR_MESSAGE_RECORD
			 *  Bug#8367471 - nallkuma
			 */

			OPEN c_is_cols_present (x_dem_schema, 'T_SRC_LOC_TMPL', 'T_EP_LR2A_DESC', 'VARCHAR2');
            FETCH c_is_cols_present INTO x_col_present_flag;
            CLOSE c_is_cols_present;

			IF( x_col_present_flag = 0 ) THEN

				/* Add T_EP_LR2A_DESC column to  the T_SRC_LOC_TMPL  table*/
				EXECUTE IMMEDIATE 'ALTER TABLE ' || x_dem_schema || '.T_SRC_LOC_TMPL '
				                               || ' ADD (T_EP_LR2A_DESC VARCHAR2(100)) ';
				log_message ('Adding column T_EP_LR2A_DESC to T_SRC_LOC_TMPL');

				/* Dropping the standard error columns in the ERR table */
				x_sql := 'ALTER TABLE ' || x_dem_schema || '.T_SRC_LOC_TMPL_ERR '
				             || ' DROP (ERROR_CODE_RECORD, LOAD_DATE, ERROR_MESSAGE_RECORD) ';
				EXECUTE IMMEDIATE x_sql;
				log_message ('Dropping columns ERROR_CODE_RECORD, LOAD_DATE and ERROR_MESSAGE_RECORD from Demantra table T_SRC_LOC_TMPL_ERR');

				/* Add T_EP_LR2A_DESC column to  the T_SRC_LOC_TMPL _ERR table*/
				EXECUTE IMMEDIATE 'ALTER TABLE ' || x_dem_schema || '.T_SRC_LOC_TMPL_ERR '
				                               || ' ADD (T_EP_LR2A_DESC VARCHAR2(100)) ';
				log_message ('Adding column T_EP_LR2A_DESC to T_SRC_LOC_TMPL_ERR');

				/* Add back the standard error columns in the ERR table */
				x_sql := 'ALTER TABLE ' || x_dem_schema || '.T_SRC_LOC_TMPL_ERR '
				            || ' ADD (ERROR_CODE_RECORD NUMBER(2), LOAD_DATE DATE, ERROR_MESSAGE_RECORD VARCHAR2(2000)) ';
				EXECUTE IMMEDIATE x_sql;
				log_message ('Adding columns ERROR_CODE_RECORD, LOAD_DATE and ERROR_MESSAGE_RECORD to Demantra table T_SRC_LOC_TMPL_ERR');

			END IF;


			    /* In case of Demantra 7.3, create the synonym BIIO_DSR_SALES_DATA in the apps schema */
                x_count1 := 0;
                OPEN c_is_table_present (x_dem_schema, 'BIIO_DSR_SALES_DATA');
                FETCH c_is_table_present INTO x_count1;
                CLOSE c_is_table_present;

                IF (x_count1 <> 0)
                THEN

                   /* Create synonym BIIO_DSR_SALES_DATA to point to Demantra table BIIO_DSR_SALES_DATA */
                   x_create_synonym_sql := 'CREATE OR REPLACE SYNONYM BIIO_DSR_SALES_DATA FOR ' ||
                                                             x_dem_schema || '.BIIO_DSR_SALES_DATA';

                   EXECUTE IMMEDIATE x_create_synonym_sql;
                   log_message ('Created synonym BIIO_DSR_SALES_DATA');

                END IF;


  END IF;

	    update_dem_apcc_synonym(errbuf,retcode);
	    COMMIT;

            EXCEPTION
                WHEN OTHERS THEN
                    msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
                    msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
                    retcode := -1;
        END;

    /* Deletes the msd_dem_entities_inuse table if the new demantra schema is intstalled
    * this will ensure that there will be no mapping between the seeded units in APPS and
    * the (display uints,exchange rate,indexes) in Demantra */
PROCEDURE cleanup_entities_inuse(errbuf out nocopy varchar2, retcode out nocopy varchar2)
    as
    /*Deletes the msd_dem_entities_inuse table */
    BEGIN

    delete msd_dem_entities_inuse;
	commit;
    EXCEPTION
        when others then
            msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
            msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
            retcode := -1;
END;



   /*** PUBLIC FUNCTIONS ***
    * GET_ALL_ORGS
    * DM_TIME_LEVEL
    * GET_PARAMETER_VALUE
    * GET_LOOKUP_VALUE
    * GET_UOM_CODE
    * GET_SR_INSTANCE_ID_FOR_ZONE
    * UOM_CONVERT
    * IS_PF_FCSTABLE_FOR_ITEM
    * IS_PRODUCT_FAMILY_FORECASTABLE
    * GET_SUPPLIER_CALENDAR
    * GET_SAFETY_STOCK_ENDDATE
    * GET_PERIOD_DATE_FOR_DUMMY
    *
    * IS_LAST_DATE_IN_BUCKET
    * GET_SNO_PLAN_CUTOFF_DATE
    * IS_SUPPLIER_CALENDAR_PRESENT
    * UOM_CONV
    * GET_LOOKUP_CODE
    * GET_LEVEL_NAME
    * GET_DEMANTRA_DATE
    * IS_USE_NEW_SITE_FORMAT
    * GET_DEMANTRA_VERSION
    * GET_APP_ID_TEXT
    * UPDATE_DEM_APCC_SYNONYM
    * GET_CTO_EFFECTIVE_DATE
    */

      /*
       * This function returns the comma(,) separated list of demand management enabled orgs
       * belonging to the given org group.
       */
      FUNCTION GET_ALL_ORGS (
      			p_org_group 		IN	VARCHAR2,
      			p_sr_instance_id	IN	NUMBER)
      RETURN VARCHAR2
      IS

         TYPE REF_CURSOR_TYPE IS REF CURSOR;

         c_ref_cursor	REF_CURSOR_TYPE;

         x_errbuf	VARCHAR2(200)	:= NULL;
         x_retcode	VARCHAR2(100)	:= NULL;

         x_dblink	VARCHAR2(50)  	:= NULL;
         x_sql		VARCHAR2(1000)	:= NULL;
         x_org		VARCHAR2(10)	:= NULL;
         x_org_string	VARCHAR2(1000)	:= NULL;

      BEGIN

         /* Get the db link to the source instance */
         msd_dem_common_utilities.get_dblink (
         			x_errbuf,
         			x_retcode,
         			p_sr_instance_id,
         			x_dblink);

         IF (x_retcode = '-1')
         THEN
            RETURN NULL;
         END IF;

         x_sql := 'SELECT mp.organization_code org_code ' ||
                  '   FROM msc_instance_orgs mio, mtl_parameters' || x_dblink || ' mp ' ||
                  '   WHERE mio.organization_id = mp.organization_id ' ||
                  '     AND mio.sr_instance_id  = :b_sr_instance_id ' ||
                  '     AND mio.org_group = :b_org_group ' ||
                  '     AND nvl(mio.dp_enabled_flag, mio.enabled_flag) = 1 ';

         OPEN c_ref_cursor FOR x_sql USING p_sr_instance_id, p_org_group;

         LOOP

            FETCH c_ref_cursor INTO x_org;
            EXIT WHEN c_ref_cursor%NOTFOUND;

            IF (c_ref_cursor%ROWCOUNT = 1)
            THEN
               x_org_string := x_org;
            ELSE
               x_org_string := x_org_string || ',' || x_org;
            END IF;

         END LOOP;

         CLOSE c_ref_cursor;

         RETURN x_org_string;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;

      END GET_ALL_ORGS;


/* This function returns the Active Demantra Data Model time level (Day/Month/week) */

FUNCTION DM_TIME_LEVEL RETURN VARCHAR2 IS

    CURSOR C1 IS
    select MEANING
    from fnd_lookup_values_vl
    where lookup_type = 'MSD_DEM_TABLES'
    AND LOOKUP_CODE = 'DM_WIZ_DM_DEF';



    L_STMT VARCHAR2(10000);

    L_DM VARCHAR2(240);

    L_TIM_LEVEL VARCHAR2(240);


BEGIN

/*
    OPEN C1;
    FETCH C1 INTO L_DM;
    CLOSE C1;
*/

    L_DM := msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'DM_WIZ_DM_DEF');

    L_STMT := 'SELECT TIME_BUCKET FROM '||
               L_DM||
               ' WHERE IS_ACTIVE=1 ';

    EXECUTE IMMEDIATE L_STMT INTO L_TIM_LEVEL;

    RETURN L_TIM_LEVEL;

END DM_TIME_LEVEL;



      /*
       * This function returns the parameter_value in msd_dem_setup_parameters
       * given the parameter_name
       */
      FUNCTION GET_PARAMETER_VALUE (
                        p_sr_instance_id	NUMBER,
      			p_parameter_name	VARCHAR2)
      RETURN VARCHAR2
      IS
         x_errbuf		VARCHAR2(200)	:= NULL;
         x_retcode		VARCHAR2(100)	:= NULL;

         x_dblink		VARCHAR2(50)	:= NULL;
         x_parameter_value	VARCHAR2(255)	:= NULL;

         x_sr_category_set_id	NUMBER		:= NULL;

      BEGIN

         get_dblink (
         	x_errbuf,
         	x_retcode,
         	p_sr_instance_id,
         	x_dblink);

         IF (x_retcode = -1)
         THEN
            RETURN NULL;
         END IF;

         EXECUTE IMMEDIATE 'SELECT parameter_value FROM msd_dem_setup_parameters' || x_dblink ||
                           ' WHERE parameter_name = ''' || p_parameter_name || ''''
            INTO x_parameter_value;

         /* Get the destination category set id for parameter = MSD_DEM_CATEGORY_SET_NAME */
         IF (p_parameter_name = 'MSD_DEM_CATEGORY_SET_NAME')
         THEN
            x_sr_category_set_id := to_number(x_parameter_value);

            SELECT category_set_id
               INTO x_parameter_value
               FROM msc_category_set_id_lid
               WHERE  sr_instance_id = p_sr_instance_id
                  AND sr_category_set_id = x_sr_category_set_id;

         END IF;

         RETURN x_parameter_value;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;

      END GET_PARAMETER_VALUE;



      /*
       * This function returns the lookup_value given the lookup_type
       * and lookup_code
       */
function get_lookup_value(p_lookup_type IN VARCHAR2,
			  p_lookup_code IN VARCHAR2)
return VARCHAR2

as

cursor get_lookup_value is
select meaning
from fnd_lookup_values
where lookup_type = p_lookup_type
and lookup_code = p_lookup_code
and language = 'US';

cursor get_schema_name is
select fnd_profile.value('MSD_DEM_SCHEMA')
from dual;

   CURSOR c_is_mdp_matrix_present (p_schema_name	VARCHAR2)
   IS
      SELECT table_name
         FROM all_tables
         WHERE  owner = upper(p_schema_name)
            AND table_name = 'MDP_MATRIX';

l_lookup_value varchar2(200);
l_schema_name varchar2(200);

   x_retval		BOOLEAN		:= NULL;
   x_table_name		VARCHAR2(50)	:= NULL;
   x_msd_schema_name	VARCHAR2(50)	:= NULL;
   x_dummy1		VARCHAR2(50)	:= NULL;
   x_dummy2		VARCHAR2(50)	:= NULL;

begin

		open get_lookup_value;
		fetch get_lookup_value into l_lookup_value;
		close get_lookup_value;

		if p_lookup_type = 'MSD_DEM_TABLES' then

			open get_schema_name;
			fetch get_schema_name into l_schema_name;
			close get_schema_name;

			if l_schema_name is not null then
				l_lookup_value := l_schema_name || '.' || l_lookup_value;
		        else
		                return null;
			end if;

		end if;

		IF (p_lookup_type = 'MSD_DEM_DM_STAGING_TABLES')
		THEN

	           open get_schema_name;
		   fetch get_schema_name into l_schema_name;
		   close get_schema_name;

		   IF (l_schema_name IS NULL)
		   THEN
		      RETURN NULL;
		   END IF;

		   OPEN c_is_mdp_matrix_present (l_schema_name);
		   FETCH c_is_mdp_matrix_present INTO x_table_name;
		   CLOSE c_is_mdp_matrix_present;

		   IF (x_table_name IS NOT NULL)
		   THEN
		      l_lookup_value := l_schema_name || '.' || l_lookup_value;
		   ELSE
		      x_retval := fnd_installation.get_app_info (
		      					'MSD',
		      					x_dummy1,
		      					x_dummy2,
		      					x_msd_schema_name);

		      l_lookup_value := x_msd_schema_name || '.' || l_lookup_value;
		   END IF;

		END IF;

		return l_lookup_value;

end;


      /*
       * This function returns the UOM code given the display unit id
       */
      FUNCTION GET_UOM_CODE (
      			p_unit_id	IN	NUMBER)
      RETURN VARCHAR2
      IS
         x_uom_code	VARCHAR2(100)	:= NULL;
      BEGIN
         EXECUTE IMMEDIATE 'SELECT display_units FROM ' ||
                              get_lookup_value ('MSD_DEM_TABLES', 'DISPLAY_UNITS') ||
                              ' WHERE display_units_id = ' || p_unit_id
                 INTO x_uom_code;
         RETURN x_uom_code;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END GET_UOM_CODE;


      /*
       * This function returns a sr_instance_id in which the zone is defined
       */
      FUNCTION GET_SR_INSTANCE_ID_FOR_ZONE (
      			p_zone		IN	VARCHAR2)
      RETURN NUMBER
      IS
         x_sr_instance_id 	NUMBER	:= NULL;
      BEGIN
         SELECT sr_instance_id
            INTO x_sr_instance_id
            FROM msc_regions
            WHERE zone = p_zone
               AND rownum < 2;

         RETURN x_sr_instance_id;
      EXCEPTION
          WHEN OTHERS THEN
             RETURN NULL;
      END GET_SR_INSTANCE_ID_FOR_ZONE;


      /*
       * This function returns the conversion rate for the given item, From UOM and To UOM
       */
      FUNCTION UOM_CONVERT (
      			p_inventory_item_id	IN	NUMBER,
      			p_precision		IN 	NUMBER,
      			p_from_unit		IN	VARCHAR2,
      			p_to_unit		IN	VARCHAR2)
      RETURN NUMBER
      IS

         x_uom_rate	NUMBER	:= NULL;

      BEGIN

         IF (   p_from_unit IS NULL
             OR p_to_unit IS NULL)
         THEN
            RETURN 1;
         END IF;

         msd_uom_conversion (
         		p_from_unit,
         		p_to_unit,
         		p_inventory_item_id,
         		x_uom_rate);

         IF (x_uom_rate = -99999)
         THEN
            RETURN 1;
         END IF;

         IF (p_precision IS NULL)
         THEN
            RETURN x_uom_rate;
         ELSE
            RETURN round (x_uom_rate, p_precision);
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN 1;
      END UOM_CONVERT;



      /* This function returns 1 if the product family's forecast control is set
       * for the given item in the master org, else returns 2
       */
      FUNCTION IS_PF_FCSTABLE_FOR_ITEM (
      			p_sr_inventory_item_id	IN	NUMBER,
      			p_sr_instance_id	IN	NUMBER,
      			p_master_org_id		IN	NUMBER)
      RETURN NUMBER
      IS

         x_product_family_id	NUMBER 	:= NULL;
         x_is_fcstable		NUMBER	:= NULL;

      BEGIN

         /* First get the product family id */
         SELECT msi.product_family_id
            INTO x_product_family_id
            FROM msc_system_items msi
            WHERE
                   msi.plan_id = -1
               AND msi.sr_instance_id = p_sr_instance_id
               AND msi.organization_id = p_master_org_id
               AND msi.sr_inventory_item_id = p_sr_inventory_item_id;

         IF (x_product_family_id IS NULL)
         THEN
            RETURN 2;
         END IF;

         SELECT nvl(msi.ato_forecast_control, 3)
            INTO x_is_fcstable
            FROM msc_system_items msi
            WHERE  msi.plan_id = -1
               AND msi.sr_instance_id = p_sr_instance_id
               AND msi.organization_id = p_master_org_id
               AND msi.inventory_item_id = x_product_family_id;

         IF (x_is_fcstable = 3)
         THEN
            RETURN 2;
         END IF;

         RETURN 1;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN 2;
      END IS_PF_FCSTABLE_FOR_ITEM;



      /* This function returns 1 if the product family forecast control flag is set,
       * else returns 2
       */
      FUNCTION IS_PRODUCT_FAMILY_FORECASTABLE (
      			p_inventory_item_id	IN	NUMBER,
      			p_sr_instance_id	IN	NUMBER)
      RETURN NUMBER
      IS

         x_errbuf		VARCHAR2(200)	:= NULL;
         x_retcode		VARCHAR2(100)	:= NULL;

         x_dblink		VARCHAR2(50)	:= NULL;
         x_sql			VARCHAR2(255)	:= NULL;

         x_return_value		NUMBER		:= NULL;
         x_is_fcstable		NUMBER		:= NULL;

	 x_instance_type	NUMBER		:= NULL;

      BEGIN

         get_dblink (
         	x_errbuf,
         	x_retcode,
         	p_sr_instance_id,
         	x_dblink);

         IF (x_retcode = -1)
         THEN
            RETURN 2;
         END IF;

         EXECUTE IMMEDIATE 'select instance_type from msc_apps_instances where instance_id = :1'
	         INTO x_instance_type
	         USING p_sr_instance_id;

         IF (x_instance_type IN (1,2,4))
         THEN

            x_sql := 'BEGIN :x_ou1 := MSD_DEM_SR_UTIL.GET_MASTER_ORGANIZATION' || x_dblink || '; END;';
            EXECUTE IMMEDIATE x_sql USING OUT x_return_value;

	 ELSE

           x_sql := 'SELECT TO_NUMBER(PARAMETER_VALUE) FROM MSD_DEM_SETUP_PARAMETERS WHERE PARAMETER_NAME = ''MSD_DEM_MASTER_ORG''';
           EXECUTE IMMEDIATE x_sql INTO x_return_value;

	 END IF;

         SELECT nvl(msi.ato_forecast_control, 3)
            INTO x_is_fcstable
            FROM msc_system_items msi
            WHERE msi.plan_id = -1
               AND msi.sr_instance_id = p_sr_instance_id
               AND msi.organization_id = x_return_value
               AND msi.inventory_item_id = p_inventory_item_id;

         IF (x_is_fcstable = 3)
         THEN
            RETURN 2;
         END IF;

         RETURN 1;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN 2;
      END IS_PRODUCT_FAMILY_FORECASTABLE;


      /*
       * This function gets the calendar code
       */
      FUNCTION GET_SUPPLIER_CALENDAR (
      			p_plan_id		IN	NUMBER,
      			p_sr_instance_id	IN	NUMBER,
      			p_organization_id	IN	NUMBER,
      			p_inventory_item_id	IN	NUMBER,
      			p_supplier_id		IN	NUMBER,
      			p_supplier_site_id	IN	NUMBER,
      			p_using_organization_id	IN	NUMBER)
      RETURN VARCHAR2
      IS

cursor c1 (p_plan_id in number, p_sr_instance_id IN NUMBER, p_organization_id IN number, p_inventory_item_id IN NUMBER,
           p_supplier_id in number, p_supplier_site_id in number, p_using_organization_id in number) IS
    select DELIVERY_CALENDAR_CODE
    from msc_item_suppliers
    where plan_id = p_plan_id
    and sr_instance_id = p_sr_instance_id
    and organization_id = p_organization_id
    and inventory_item_id = p_inventory_item_id
    and supplier_id = p_supplier_id
    and supplier_site_id = p_supplier_site_id
    and using_organization_id = p_using_organization_id;

cursor c2 (p_sr_instance_id IN NUMBER, p_organization_id IN number) IS
     select calendar_code
     from msc_trading_partners
     where partner_type = 3
     and sr_tp_id = p_organization_id
     and sr_instance_id = p_sr_instance_id;

    l_ret   varchar2(30) := null;
Begin

    open c1 (p_plan_id, p_sr_instance_id, p_organization_id, p_inventory_item_id,
             p_supplier_id, p_supplier_site_id, p_using_organization_id);
    fetch c1 into l_ret;
    close c1;

    if l_ret is null then
       open c2 (p_sr_instance_id, p_organization_id);
       fetch c2 into l_ret;
       close c2;
    end if;

    return l_ret;
    EXCEPTION when others then return NULL;

End get_supplier_calendar;

      /*
       * This function gets the period end date
       */
      FUNCTION GET_SAFETY_STOCK_ENDDATE (
      			p_plan_id		IN	NUMBER,
      			p_sr_instance_id	IN	NUMBER,
      			p_organization_id	IN	NUMBER,
      			p_inventory_item_id	IN	NUMBER,
      			p_period_start_date	IN	DATE)
      RETURN DATE
      IS
cursor c1 (p_plan_id in number, p_sr_instance_id IN NUMBER, p_organization_id IN number,
           p_inventory_item_id IN NUMBER, p_period_start_date IN DATE) IS
    select min(period_start_date) -1 period_end_date
    from msc_safety_stocks
    where plan_id = p_plan_id
    and sr_instance_id = p_sr_instance_id
    and organization_id = p_organization_id
    and inventory_item_id = p_inventory_item_id
    and period_start_date > p_period_start_date;

cursor c2 (p_plan_id in number) IS
     select CURR_CUTOFF_DATE
     from msc_plans
     where plan_id = p_plan_id;

CURSOR c3 (p_date IN DATE) IS
     SELECT end_date
        FROM msd_dem_dates
        WHERE p_date BETWEEN start_date AND end_date;

    l_ret   date := null;
Begin

    open c1 (p_plan_id, p_sr_instance_id, p_organization_id, p_inventory_item_id, p_period_start_date);
    fetch c1 into l_ret;
    close c1;

    if l_ret is null then
       open c2 (p_plan_id);
       fetch c2 into l_ret;
       close c2;

       if (upper(msd_dem_common_utilities.dm_time_level) <> 'DAY') then
          open c3(l_ret);
          fetch c3 into l_ret;
          close c3;
       end if;

    end if;

    return l_ret;
    EXCEPTION when others then return NULL;

End get_safety_stock_enddate;


      /*
       * Returns a valid date from the table INPUTS in Demantra
       */
      FUNCTION GET_PERIOD_DATE_FOR_DUMMY
      RETURN DATE
      IS
         x_dummy_date	DATE	:= NULL;
      BEGIN

         EXECUTE IMMEDIATE 'SELECT datet FROM ( '
                           || ' SELECT datet FROM '
                           || msd_dem_common_utilities.get_lookup_value ('MSD_DEM_TABLES', 'INPUTS')
                           || ' WHERE datet > sysdate '
                           || ' ORDER BY datet ) '
                           || ' WHERE rownum < 2 '
            INTO x_dummy_date;

         RETURN x_dummy_date;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END GET_PERIOD_DATE_FOR_DUMMY;



      /*
       * Given, the instance, customer and/or site, this function returns
       * the site level member name. If only the customer is specified then
       * then any arbit site(which is present in demantra) belonging to the customer is returned.
       */
      FUNCTION GET_SITE_FOR_CSF (
      			p_sr_instance_id	IN	NUMBER,
      			p_customer_id		IN	NUMBER,
      			p_customer_site_id	IN	NUMBER)
      RETURN VARCHAR2
      IS
         x_site		VARCHAR2(255);
         x_dummy_site   VARCHAR2(100) := msd_dem_sr_util.get_null_code;
         l_sql varchar2(1000) := null ;
      BEGIN

         IF (LG_VAR_SITE_CODE_FORMAT IS NULL)
         THEN
            LG_VAR_SITE_CODE_FORMAT := IS_USE_NEW_SITE_FORMAT;
         END IF;

         IF (LG_VAR_SITE_CODE_FORMAT = 0)
         THEN

            IF (p_customer_site_id IS NOT NULL)
            THEN

               SELECT substrb(mtp.partner_name,   1,   50)
                      || ':' || mtil.sr_cust_account_number
                      || ':' || mtps.location
                      || ':' || mtps.operating_unit_name
                  INTO x_site
                  FROM msc_trading_partner_sites mtps,
                       msc_trading_partners mtp,
                       msc_tp_id_lid mtil
                  WHERE
                         mtps.partner_site_id = p_customer_site_id
                     AND mtp.partner_id = mtps.partner_id
                     AND mtil.tp_id = mtp.partner_id
                     AND mtil.sr_instance_id = p_sr_instance_id;

            ELSIF (p_customer_id IS NOT NULL)
            THEN

		/* bug#9444819 -- nalkuma*/
               l_sql := ' select s.site
                      FROM msc_trading_partners mtp,
                       msc_tp_id_lid mtil,
                       msc_trading_partner_sites mtps,
                       msc_tp_site_id_lid mtsil, '
						          || C_MSD_DEM_SCHEMA || '.t_ep_site s
						          WHERE
                         mtp.partner_id = ' || p_customer_id ||
                     ' AND mtil.tp_id = mtp.partner_id
                     AND mtil.sr_instance_id = ' || p_sr_instance_id ||
                     ' AND mtps.partner_id = mtp.partner_id
                     AND mtps.tp_site_code = ''SHIP_TO''
                     AND mtsil.tp_site_id = mtps.partner_site_id
                     AND mtsil.sr_instance_id = ' || p_sr_instance_id ||
                     ' AND lower(s.site) = lower( substrb(mtp.partner_name,   1,   50)
					                      || '':'' || mtil.sr_cust_account_number
					                      || '':'' || mtps.location
					                      || '':'' || mtps.operating_unit_name )
                      AND rownum < 2 ';

					 execute immediate l_sql into x_site ;

            ELSE
               x_site := x_dummy_site;
            END IF;

         ELSE

            IF (p_customer_site_id IS NOT NULL)
            THEN

               SELECT /* INDEX(mtpsil MSC_TP_SITE_ID_LID_N1) */
                  to_char(p_sr_instance_id) || '::' || to_char(mtpsil.sr_tp_site_id)
                  INTO x_site
                  FROM msc_tp_site_id_lid mtpsil
                  WHERE
                         mtpsil.tp_site_id = p_customer_site_id
                     AND mtpsil.sr_instance_id = p_sr_instance_id
                     AND mtpsil.partner_type = 2;

            ELSIF (p_customer_id IS NOT NULL)
            THEN

		/* bug#9444819 -- nalkuma*/
              l_sql :=	' select /* INDEX(mtps MSC_TRADING_PARTNER_SITES_U3) */
							to_char(' || p_sr_instance_id || ') || ''::'' || to_char(mtsil.sr_tp_site_id)
							from
							msc_trading_partner_sites mtps,
							msc_tp_site_id_lid mtsil, '
							|| C_MSD_DEM_SCHEMA || '.t_ep_site s
						  WHERE
								 mtps.partner_id = ' || p_customer_id ||
							' AND mtps.tp_site_code = ''SHIP_TO''
							 AND mtsil.tp_site_id = mtps.partner_site_id
							 AND mtsil.sr_instance_id = ' || p_sr_instance_id ||
							' AND lower(s.site) = to_char(' || p_sr_instance_id || ') || ''::'' || to_char(mtsil.sr_tp_site_id)
							AND rownum < 2 ';

				 execute immediate l_sql into x_site ;

             ELSE
               x_site := x_dummy_site;
            END IF;

         END IF;

         RETURN x_site;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN x_dummy_site;
      END GET_SITE_FOR_CSF;



      /*
       * Given, the instance, calendar_code, calendar_date, this function
       * returns 1 if the date is the last date in its demantra bucket,
       * else returns 2.
       * Note: This function requires the table msd_dem_dates to be
       *       populated.
       */
      FUNCTION IS_LAST_DATE_IN_BUCKET (
      			p_sr_instance_id	IN	NUMBER,
      			p_calendar_code		IN	VARCHAR2,
      			p_calendar_date		IN	DATE)
      RETURN NUMBER
      IS
         x_max_date 	DATE	:= NULL;
      BEGIN

         IF (upper(msd_dem_common_utilities.dm_time_level) = 'DAY')
         THEN
            RETURN 1;
         END IF;

         SELECT max(mcd.calendar_date)
            INTO x_max_date
            FROM msd_dem_dates mdd,
                 msc_calendar_dates mcd
            WHERE
                   p_calendar_date BETWEEN mdd.start_date AND mdd.end_date
               AND mcd.sr_instance_id = p_sr_instance_id
               AND mcd.calendar_code = p_calendar_code
               AND mcd.exception_set_id = -1
               AND mcd.calendar_date BETWEEN mdd.start_date AND mdd.end_date
               AND mcd.seq_num IS NOT NULL;

         IF (p_calendar_date = x_max_date)
         THEN
            RETURN 1;
         END IF;

         RETURN 2;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN 2;
      END IS_LAST_DATE_IN_BUCKET;



      /*
       * Given the plan id of a SNO plan, this function returns
       * the cutoff date for the plan.
       */
      FUNCTION GET_SNO_PLAN_CUTOFF_DATE (
      			p_plan_id		IN	NUMBER)
      RETURN DATE
      IS

         x_plan_cutoff_date	DATE	:= NULL;

         x_sr_instance_id	NUMBER	:= NULL;
         x_organization_id	NUMBER	:= NULL;
         x_curr_start_date	DATE	:= NULL;
         x_planned_bucket	NUMBER	:= NULL;
         x_planned_bucket_type	NUMBER	:= NULL;

         x_calendar_code	VARCHAR2(100)	:= NULL;

      BEGIN

         /* Get Plan Info */
         SELECT
            sr_instance_id,
            organization_id,
            curr_start_date,
            planned_bucket,
            planned_bucket_type
            INTO
               x_sr_instance_id,
               x_organization_id,
               x_curr_start_date,
               x_planned_bucket,
               x_planned_bucket_type
            FROM
               msc_plans
            WHERE
               plan_id = p_plan_id;

         /* Get calendar for the plan owning org */
         SELECT
            calendar_code
            INTO
               x_calendar_code
            FROM
               msc_trading_partners
            WHERE
                   partner_type = 3
               AND sr_tp_id = x_organization_id
               AND sr_instance_id = x_sr_instance_id;

         /* Get cut-off date */
         IF (x_planned_bucket_type = 2) /* WEEK */
         THEN

            SELECT
               max(next_date) - 1
               INTO x_plan_cutoff_date
               FROM
                  ( SELECT
                       next_date
                       FROM
                          msc_cal_week_start_dates
                       WHERE
                              calendar_code = x_calendar_code
                          AND sr_instance_id = x_sr_instance_id
                          AND week_start_date > x_curr_start_date
                       ORDER BY next_date)
               WHERE
                  rownum < x_planned_bucket + 1;

         ELSIF (x_planned_bucket_type = 3) /* PERIOD */
         THEN

            SELECT
               max(next_date) - 1
               INTO x_plan_cutoff_date
               FROM
                  ( SELECT
                       next_date
                       FROM
                          msc_period_start_dates
                       WHERE
                              calendar_code = x_calendar_code
                          AND sr_instance_id = x_sr_instance_id
                          AND period_start_date > x_curr_start_date
                       ORDER BY next_date)
               WHERE
                  rownum < x_planned_bucket + 1;

         ELSE
            RETURN NULL;
         END IF;

         RETURN x_plan_cutoff_date;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END GET_SNO_PLAN_CUTOFF_DATE;



      /*
       * This function returns 1 if a supplier calendar is present else returns 2.
       */
      FUNCTION IS_SUPPLIER_CALENDAR_PRESENT (
      			p_plan_id		IN	NUMBER,
      			p_sr_instance_id	IN	NUMBER,
      			p_organization_id	IN	NUMBER,
      			p_inventory_item_id	IN	NUMBER,
      			p_supplier_id		IN	NUMBER,
      			p_supplier_site_id	IN	NUMBER,
      			p_using_organization_id	IN	NUMBER)
      RETURN NUMBER
      IS

         cursor c1 (p_plan_id in number, p_sr_instance_id IN NUMBER, p_organization_id IN number, p_inventory_item_id IN NUMBER,
                    p_supplier_id in number, p_supplier_site_id in number, p_using_organization_id in number) IS
            select DELIVERY_CALENDAR_CODE
            from msc_item_suppliers
            where plan_id = p_plan_id
              and sr_instance_id = p_sr_instance_id
              and organization_id = p_organization_id
              and inventory_item_id = p_inventory_item_id
              and supplier_id = p_supplier_id
              and supplier_site_id = p_supplier_site_id
              and using_organization_id = p_using_organization_id;

         l_ret   varchar2(30) := null;
         l_ret1  number       := 2;

      BEGIN

         open c1 (p_plan_id, p_sr_instance_id, p_organization_id, p_inventory_item_id,
                  p_supplier_id, p_supplier_site_id, p_using_organization_id);
         fetch c1 into l_ret;
         close c1;

         if l_ret is not null then
            l_ret1 := 1;
         end if;

         RETURN l_ret1;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN 2;

      END IS_SUPPLIER_CALENDAR_PRESENT;



      /*
       * Given the item and the uom code, this function gives the conversion factor
       * to the base uom of the item.
       */
      FUNCTION UOM_CONV (
      		   	p_sr_instance_id	IN	NUMBER,
      		   	p_uom_code 		IN	VARCHAR2,
                        p_inventory_item_id  		IN	NUMBER DEFAULT NULL)
      RETURN NUMBER
      IS

         x_base_uom    		VARCHAR2(3);
         x_conv_rate         	NUMBER		:=1;
         x_master_org         	NUMBER;
         x_master_uom         	VARCHAR2(3);

      BEGIN

         x_master_org := get_parameter_value (p_sr_instance_id, 'MSD_DEM_MASTER_ORG');

         SELECT nvl(uom_code,'Ea')
            INTO x_master_uom
            FROM msc_system_items
            WHERE  plan_id = -1
               AND sr_instance_id = p_sr_instance_id
               AND organization_id = x_master_org
               AND inventory_item_id = p_inventory_item_id;

         /* Convert to Master org primary uom */

         msd_uom_conversion(p_uom_code,
                            x_master_uom,
                            p_inventory_item_id,
                            x_conv_rate);

         RETURN x_conv_rate;

      EXCEPTION
         WHEN OTHERS THEN
          RETURN 1;

      END UOM_CONV;



      /*
       * This function given the Demantra lookup table name and lookup ID
       * returns the lookup Code
       */
      FUNCTION GET_LOOKUP_CODE (
      			p_lookup_table_name	IN	VARCHAR2,
      			p_lookup_id		IN	NUMBER)
      RETURN VARCHAR2
      IS
         x_ret_value 		VARCHAR2(100)	:= NULL;
      BEGIN

         EXECUTE IMMEDIATE 'SELECT ' || p_lookup_table_name || '_code FROM '
                           || C_MSD_DEM_SCHEMA || '.' || p_lookup_table_name
                           || ' where ' || p_lookup_table_name || '_id = ' || to_char(p_lookup_id)
            INTO x_ret_value;

         RETURN x_ret_value;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;

      END GET_LOOKUP_CODE;



      /*
       * This function given the Demantra lookup table name and lookup ID
       * returns the lookup Code
       */
      FUNCTION GET_LEVEL_NAME (
      			p_it_level_code		IN	NUMBER)
      RETURN VARCHAR2
      IS
         x_ret_value 		VARCHAR2(100)	:= NULL;
      BEGIN

         EXECUTE IMMEDIATE 'SELECT table_label FROM ' || C_MSD_DEM_SCHEMA || '.group_tables'
                           || ' WHERE group_table_id = ' || to_char(p_it_level_code)
            INTO x_ret_value;

         RETURN x_ret_value;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;

      END GET_LEVEL_NAME;




      /*
       * Given a date, the function returns the the bucket date to which the date belongs.
       * If p_date is null, p_from is 1, the the function returns
       *     max of (min_sales_date, sysdate - 2 years )
       * If p_date is null, p_from is 2, the the function returns
       *     min of (max_fore_sales_date, sysdate + 2 years )
       */
      FUNCTION GET_DEMANTRA_DATE (
      			p_date			IN	DATE,
      			p_from			IN	NUMBER)
      RETURN DATE
      IS
         x_dem_nls_date_format		VARCHAR2(100)	:= NULL;
         x_dem_min_sales_date		VARCHAR2(100)	:= NULL;
         x_dem_min_sales_date_d		DATE		:= NULL;
         x_dem_max_fore_sales_date	VARCHAR2(100)	:= NULL;
         x_dem_max_fore_sales_date_d	DATE		:= NULL;

         x_date				DATE		:= NULL;
      BEGIN

      IF (p_date IS NULL)
      THEN

         IF (p_from = 1)
         THEN

            IF (C_DEM_MIN_SALES_DATE_D IS NULL)
            THEN

               EXECUTE IMMEDIATE 'SELECT pval FROM ' || C_MSD_DEM_SCHEMA || '.DB_PARAMS'
                                 || ' WHERE lower(pname) = ''nls_date_format'' '
                  INTO x_dem_nls_date_format;

               EXECUTE IMMEDIATE 'SELECT pval FROM ' || C_MSD_DEM_SCHEMA || '.SYS_PARAMS'
                                 || ' WHERE lower(pname) = ''min_sales_date'' '
                  INTO x_dem_min_sales_date;

               IF (x_dem_min_sales_date IS NOT NULL)
               THEN
                  x_dem_min_sales_date_d := to_date(x_dem_min_sales_date, x_dem_nls_date_format);
               ELSE
                  x_dem_min_sales_date_d := sysdate - 365*2;
               END IF;



               SELECT datet
                  INTO C_DEM_MIN_SALES_DATE_D
                  FROM msd_dem_dates
                  WHERE x_dem_min_sales_date_d between start_date and end_date;

            END IF;

            RETURN C_DEM_MIN_SALES_DATE_D;

         ELSE

            IF (C_DEM_MAX_FORE_SALES_DATE_D IS NULL)
            THEN

               EXECUTE IMMEDIATE 'SELECT pval FROM ' || C_MSD_DEM_SCHEMA || '.DB_PARAMS'
                                 || ' WHERE lower(pname) = ''nls_date_format'' '
                  INTO x_dem_nls_date_format;

               EXECUTE IMMEDIATE 'SELECT pval FROM ' || C_MSD_DEM_SCHEMA || '.SYS_PARAMS'
                                 || ' WHERE lower(pname) = ''max_fore_sales_date'' '
                  INTO x_dem_max_fore_sales_date;

               IF (x_dem_max_fore_sales_date IS NOT NULL)
               THEN
                  x_dem_max_fore_sales_date_d := to_date(x_dem_max_fore_sales_date, x_dem_nls_date_format);
               ELSE
                  x_dem_max_fore_sales_date_d := sysdate + 365*2;
               END IF;

               SELECT datet
                  INTO C_DEM_MAX_FORE_SALES_DATE_D
                  FROM msd_dem_dates
                  WHERE x_dem_max_fore_sales_date_d between start_date and end_date;

            END IF;

            RETURN C_DEM_MAX_FORE_SALES_DATE_D;

         END IF;

      ELSE

         SELECT datet
         INTO x_date
         FROM msd_dem_dates
         WHERE p_date between start_date and end_date;

         RETURN x_date;

      END IF;

      RETURN sysdate;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN sysdate;

      END GET_DEMANTRA_DATE;




      /*
       * The function is used to determine whether to use the new site format or not.
       * Returns -
       *    1 - use new site format, from 7.3.x onwards
       *    0 - use old site format, for 7.2.x release
       */
      FUNCTION IS_USE_NEW_SITE_FORMAT
         RETURN NUMBER
      IS

      BEGIN

         IF (LG_VAR_SITE_CODE_FORMAT IS NULL)
         THEN
            IF (nvl(fnd_profile.value('MSD_DEM_SITE_CODE_FORMAT'), 2) = 2)
            THEN
               LG_VAR_SITE_CODE_FORMAT := 0;
            ELSE
               LG_VAR_SITE_CODE_FORMAT := 1;
            END IF;
         END IF;

         RETURN LG_VAR_SITE_CODE_FORMAT;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN -1;

      END IS_USE_NEW_SITE_FORMAT;




      /*
       * The function returns the Demantra release version.
       */
      FUNCTION GET_DEMANTRA_VERSION
         RETURN VARCHAR2
      IS

          x_present		NUMBER	:= NULL;

      BEGIN

         EXECUTE IMMEDIATE 'SELECT count(1) FROM ' || FND_PROFILE.VALUE('MSD_DEM_SCHEMA') ||
                              '.VERSION_DETAILS ' ||
                              ' WHERE version LIKE ''7.2%'''
            INTO x_present;

         IF (x_present = 1)
         THEN
            RETURN '7.2';
         END IF;

         RETURN '7.3';

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;

      END GET_DEMANTRA_VERSION;




      /*
       * The function returns the request Demantra value or the join condition
       * given the lookup code. This function uses APP ID for Demantra 7.3 release
       * and internal ids for Demantra 7.2 release.
       */
      FUNCTION GET_APP_ID_TEXT (
      			p_lookup_type		IN	VARCHAR2,
      			p_lookup_code		IN	VARCHAR2,
      			p_is_select		IN	NUMBER,
      			p_column_name		IN	VARCHAR2)
         RETURN VARCHAR2
      IS

         CURSOR c_get_lookup_value
         IS
            SELECT meaning,
                   attribute1,
                   attribute2,
                   attribute3,
                   attribute4
               FROM fnd_lookup_values_vl
               WHERE  lookup_type = p_lookup_type
                  AND lookup_code = p_lookup_code;

         x_dem_version		VARCHAR2(10)    := GET_DEMANTRA_VERSION;
         x_dem_schema		VARCHAR2(100)	:= fnd_profile.value('MSD_DEM_SCHEMA');
         x_sql			VARCHAR2(2000)	:= NULL;
         x_lk_meaning		VARCHAR2(500)	:= NULL;
         x_lk_attribute1	VARCHAR2(500)	:= NULL;
         x_lk_attribute2	VARCHAR2(500)	:= NULL;
         x_lk_attribute3	VARCHAR2(500)	:= NULL;
         x_lk_attribute4	VARCHAR2(500)	:= NULL;

         x_return_value		VARCHAR2(500)	:= NULL;

      BEGIN

         IF (x_dem_version IS NULL)
         THEN
            RETURN NULL;
         END IF;

         OPEN c_get_lookup_value;
         FETCH c_get_lookup_value INTO x_lk_meaning,
                                       x_lk_attribute1,
                                       x_lk_attribute2,
                                       x_lk_attribute3,
                                       x_lk_attribute4;
         CLOSE c_get_lookup_value;

         IF (x_lk_meaning IS NULL)
         THEN
            RETURN NULL;
         END IF;

         IF (x_dem_version = '7.2')
         THEN

            IF (p_is_select = 1)
            THEN
               x_sql := 'SELECT ' || p_column_name || ' FROM '
                           || x_dem_schema || '.' || x_lk_attribute3
                           || ' WHERE ' || x_lk_attribute4 || ' = ''' || x_lk_attribute2 || '''';
               EXECUTE IMMEDIATE x_sql INTO x_return_value;

            ELSE
               x_return_value := x_lk_attribute4 || ' = ''' || x_lk_attribute2 || '''';
            END IF;

         ELSE

            IF (p_is_select = 1)
            THEN

               x_sql := 'SELECT ' || p_column_name || ' FROM '
                           || x_dem_schema || '.' || x_lk_attribute3
                           || ' WHERE application_id = ''' || x_lk_attribute1 || '''';
               EXECUTE IMMEDIATE x_sql INTO x_return_value;

            ELSE
               x_return_value := 'application_id' || ' = ''' || x_lk_attribute1 || '''';
            END IF;

         END IF;

         RETURN x_return_value;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END GET_APP_ID_TEXT;

/*
        *   Procedure Name - UPDATE_DEM_APCC_SYNONYM
        *   This procedure creates the required dummy objets for APCC
        *     1) Checks if demantra is installed and the mview created
        *     1.1.a) If mview is available, drop it.
        *     1.1.b) Create a new mview with the same name - BIEO_OBI_MV
        *     1.2) If demantra is not installed, and dummy table available
        *     1.2.a) Drop the dummy table
        *     1.2.b) Create the dummy table - MSD_DEM_BIEO_OBI_MV_DUMMY
        *     2) Create synonym MSD_DEM_BIEO_OBI_MV_SYN accordingly.
        *
        */
  PROCEDURE UPDATE_DEM_APCC_SYNONYM(
	    errbuf out NOCOPY varchar2,
    	retcode out NOCOPY varchar2
	   )
	   IS
  CURSOR c_check_expview(schema_owner varchar2) IS
  SELECT object_name
  FROM dba_objects
  WHERE owner = upper(schema_owner)
   AND object_type = 'MATERIALIZED VIEW'
   AND object_name = 'BIEO_OBI_MV'
  ORDER BY created DESC;
  CURSOR c_check_table IS
  SELECT object_name
  FROM dba_objects
  WHERE owner = owner
   AND object_type = 'TABLE'
   AND object_name = 'MSD_DEM_BIEO_OBI_MV_DUMMY'
  ORDER BY created DESC;

  x_dem_schema VARCHAR2(50) := NULL;
  x_expview VARCHAR2(50) := NULL;
  x_table VARCHAR2(50) := NULL;
  x_create_synonym_sql VARCHAR2(200) := NULL;
  x_create_table_sql VARCHAR2(3000) := NULL;
  x_create_view_sql    VARCHAR2(2000) := NULL;
  x_small_sql  VARCHAR2(1000) := NULL;
  x_dmtra_version      VARCHAR2(10)   := '7.2.0';
  x_syn_base VARCHAR2(50) := 'MSD_DEM_BIEO_OBI_MV_DUMMY';

BEGIN

  x_dem_schema :=  msd_dem_demantra_utilities.get_demantra_schema;

  OPEN c_check_expview(x_dem_schema);
  FETCH c_check_expview
  INTO x_expview;
  CLOSE c_check_expview;

  OPEN c_check_table;
  FETCH c_check_table
  INTO x_table;
  CLOSE c_check_table;

  /* Demantra is Installed */


      IF(x_dem_schema IS NOT NULL) THEN
    /* The export profile view created*/
  IF(x_expview IS NOT NULL) THEN
    /*Create a dummy materialized view with the same definition as that of the export profile mview*/
    x_small_sql := 'DROP MATERIALIZED VIEW  '||x_dem_schema||'."BIEO_OBI_MV" ';
    EXECUTE IMMEDIATE x_small_sql;
    END IF;

  x_create_view_sql := 'CREATE MATERIALIZED VIEW '||x_dem_schema||'."BIEO_OBI_MV" build deferred as
  select datet SDATE
     ,1 LEVEL1
     ,1 LEVEL2
     ,1 LEVEL3
     ,1 LEVEL4
     ,1 LEVEL5
     ,1 EBS_BH_BOOK_QTY_BD
     ,1 EBS_SH_SHIP_QTY_SD
     ,1 ACRY_MAPE_PCT_ERR
     ,1 PRTY_DEMAND
     ,1 WEEK4_ABS_PCT_ERR
     ,1 WEEK8_ABS_PCT_ERR
     ,1 WEEK13_ABS_PCT_ERR
     ,1 DKEY_ITEM
     ,1 DKEY_SITE
     ,1 ACTUAL_PROD
     ,1 TOTAL_BACKLOG
     ,1 FCST_CONSENSUS
     ,1 BUDGET
     ,1 SALES_FCST
     ,1 MKTG_FCST
     ,1 FCST_BOOKING
     ,1 FCST_SHIPMENT
     ,1 PROJ_BACKLOG
     ,1 RECORD_TYPE
     ,1 EBS_RETURN_HISTORY
     ,1 FCST_HYP_ANNUAL_PLAN
     ,1 FCST_HYP_FINANCIAL
     ,1 C_PRED
     ,1 ACTUAL_ON_HAND
     ,1 EBS_BH_BOOK_QTY_RD
     from '||x_dem_schema||'.inputs,
     dual';
    x_syn_base := x_dem_schema||'.BIEO_OBI_MV';
   EXECUTE IMMEDIATE x_create_view_sql;

    /* Check the version of demantra installed */
    x_small_sql := 'SELECT VERSION FROM '||x_dem_schema||'.VERSION_DETAILS';
    EXECUTE IMMEDIATE x_small_sql INTO x_dmtra_version;
    /*If Demantra version is 7.2.0.2 create dummy columns*/
    IF (x_dmtra_version  = '7.2.0') THEN
     x_create_view_sql := 'CREATE OR REPLACE VIEW MSD_DEM_BIEO_OBI_MV_V AS
  SELECT SDATE
     ,LEVEL1
	   ,LEVEL2
	   ,LEVEL3
	   ,LEVEL4
	   ,EBS_BH_BOOK_QTY_BD
	   ,EBS_SH_SHIP_QTY_SD
	   ,ACRY_MAPE_PCT_ERR
	   ,PRTY_DEMAND
	   ,WEEK4_ABS_PCT_ERR
	   ,WEEK8_ABS_PCT_ERR
	   ,WEEK13_ABS_PCT_ERR
	   ,DKEY_ITEM
	   ,DKEY_SITE
	   ,ACTUAL_PROD
	   ,TOTAL_BACKLOG
	   ,FCST_CONSENSUS
	   ,BUDGET
	   ,SALES_FCST
	   ,MKTG_FCST
	   ,FCST_BOOKING
	   ,FCST_SHIPMENT
	   ,PROJ_BACKLOG
	   ,RECORD_TYPE
	   ,NULL EBS_RETURN_HISTORY
	   ,NULL FCST_HYP_ANNUAL_PLAN
	   ,NULL FCST_HYP_FINANCIAL
	   ,NULL C_PRED
	   ,NULL ACTUAL_ON_HAND
	   ,NULL EBS_BH_BOOK_QTY_RD
	   FROM '||x_dem_schema||'.BIEO_OBI_MV,DUAL';
      EXECUTE IMMEDIATE x_create_view_sql;
      x_syn_base := 'MSD_DEM_BIEO_OBI_MV_V';
    ELSIF (x_dmtra_version = '7.3.0') THEN
      x_create_view_sql:= 'CREATE OR REPLACE VIEW MSD_DEM_BIEO_OBI_MV_V AS
      SELECT SDATE
     ,LEVEL1
	   ,LEVEL2
	   ,LEVEL3
	   ,LEVEL4
	   ,EBS_BH_BOOK_QTY_BD
	   ,EBS_SH_SHIP_QTY_SD
	   ,ACRY_MAPE_PCT_ERR
	   ,PRTY_DEMAND
	   ,WEEK4_ABS_PCT_ERR
	   ,WEEK8_ABS_PCT_ERR
	   ,WEEK13_ABS_PCT_ERR
	   ,DKEY_ITEM
	   ,DKEY_SITE
	   ,ACTUAL_PROD
	   ,TOTAL_BACKLOG
	   ,FCST_CONSENSUS
	   ,BUDGET
	   ,SALES_FCST
	   ,MKTG_FCST
	   ,FCST_BOOKING
	   ,FCST_SHIPMENT
	   ,PROJ_BACKLOG
	   ,RECORD_TYPE
	   ,EBS_RETURN_HISTORY
	   ,FCST_HYP_ANNUAL_PLAN
	   ,FCST_HYP_FINANCIAL
	   ,C_PRED
	   ,ACTUAL_ON_HAND
	   ,EBS_BH_BOOK_QTY_RD
	   FROM '||x_dem_schema||'.BIEO_OBI_MV,DUAL';
	    EXECUTE IMMEDIATE x_create_view_sql;
        x_syn_base := 'MSD_DEM_BIEO_OBI_MV_V';
      END IF;
ELSE

    IF(x_table IS NOT NULL) THEN
    x_small_sql := 'drop table '||x_table;
    EXECUTE IMMEDIATE x_small_sql;
    END IF;
    /*x_table*/
      x_create_table_sql := 'CREATE TABLE "APPS"."MSD_DEM_BIEO_OBI_MV_DUMMY"
   (	"SDATE" DATE,
	"LEVEL1" VARCHAR2(240),
	"LEVEL2" VARCHAR2(240),
	"LEVEL3" VARCHAR2(240),
	"LEVEL4" VARCHAR2(240),
	"EBS_BH_BOOK_QTY_BD" NUMBER,
	"EBS_SH_SHIP_QTY_SD" NUMBER,
	"ACRY_MAPE_PCT_ERR" NUMBER,
	"PRTY_DEMAND" NUMBER,
	"WEEK4_ABS_PCT_ERR" NUMBER,
	"WEEK8_ABS_PCT_ERR" NUMBER,
	"WEEK13_ABS_PCT_ERR" NUMBER,
	"DKEY_ITEM" NUMBER,
	"DKEY_SITE" NUMBER,
	"ACTUAL_PROD" NUMBER,
	"TOTAL_BACKLOG" NUMBER,
	"FCST_CONSENSUS" NUMBER,
	"BUDGET" NUMBER,
	"SALES_FCST" NUMBER,
	"MKTG_FCST" NUMBER,
	"FCST_BOOKING" NUMBER,
	"FCST_SHIPMENT" NUMBER,
	"PROJ_BACKLOG" NUMBER,
	"RECORD_TYPE" NUMBER,
	"EBS_RETURN_HISTORY" NUMBER,
	"FCST_HYP_ANNUAL_PLAN" NUMBER,
	"FCST_HYP_FINANCIAL" NUMBER,
	"C_PRED" NUMBER,
	"ACTUAL_ON_HAND" NUMBER,
	"EBS_BH_BOOK_QTY_RD" NUMBER
   )';
  EXECUTE IMMEDIATE x_create_table_sql;

    END IF;
  /*schema*/

     /* Update synonym MSD_DEM_BIEO_OBI_MV_SYN to point to dummy table MSD_DEM_BIEO_OBI_MV_DUMMY */
     x_create_synonym_sql := 'CREATE OR REPLACE SYNONYM MSD_DEM_BIEO_OBI_MV_SYN FOR ' || x_syn_base;
    EXECUTE IMMEDIATE x_create_synonym_sql;



  EXCEPTION
  WHEN others THEN
  retcode := -1;
    RAISE;
  END UPDATE_DEM_APCC_SYNONYM;

   /*
    * Use this function to determine start/end date of a CTO item
    * Dates calculated, to be closer to max sales date in demantra, as follows :
    * (If 'max_sales_date' sys_param is used the value will be used, else the max date from sales staging table will be considered)
    * Start date - bom_effective_date or (max_sales_date - cto_history_periods) whichever is higher
    * End date - bom_inactive_date or (max_sales_date + lead) whichever is lower
    *
    * params :
    *          p_bom_date - bom_effective_date or bom_inactive_date
    *          p_min_max - if 1 (date passed is bom_effective_date) else (date passed is  bom_inactive_date)
    */
   FUNCTION GET_CTO_EFFECTIVE_DATE (
               p_bom_date IN DATE,
               p_min_max IN NUMBER DEFAULT 1)
   RETURN DATE
   IS
      x_dem_nls_date_format			VARCHAR2(100)	:= NULL;
      x_dem_max_sales_date			VARCHAR2(100)	:= NULL;
      x_dm_time_level             	VARCHAR2(10)    := NULL;
      x_stg_max_sales_date_d		DATE        	:= NULL;
      x_dem_max_sales_date_d		DATE		    := NULL;
      x_max_sales_date_d	        DATE		    := NULL;
      x_bom_date                  	DATE            := NULL;
      x_num_periods               	NUMBER          := NULL;
   BEGIN

      /* get the max_sales_date param value */
      IF (C_DEM_MAX_SALES_DATE_D IS NULL)
      THEN

         EXECUTE IMMEDIATE 'SELECT pval FROM ' || C_MSD_DEM_SCHEMA || '.DB_PARAMS'
                     || ' WHERE lower(pname) = ''nls_date_format'' '
            INTO x_dem_nls_date_format;

         EXECUTE IMMEDIATE 'SELECT pval FROM ' || C_MSD_DEM_SCHEMA || '.SYS_PARAMS'
                     || ' WHERE lower(pname) = ''max_sales_date'' '
            INTO x_dem_max_sales_date;

         IF (x_dem_max_sales_date IS NOT NULL)
         THEN
            x_dem_max_sales_date_d := to_date(x_dem_max_sales_date, x_dem_nls_date_format);
         ELSE
            x_dem_max_sales_date_d := to_date('01-01-1900 00:00:00', 'mm-dd-yyyy hh24:mi:ss');
         END IF;

         C_DEM_MAX_SALES_DATE_D := x_dem_max_sales_date_d;

      END IF;

      x_dem_max_sales_date_d := C_DEM_MAX_SALES_DATE_D;

      /* get the max sales date from t_src_sales_tmpl table */
      EXECUTE IMMEDIATE 'SELECT max(sales_date) FROM ' || C_MSD_DEM_SCHEMA || '.T_SRC_SALES_TMPL'
         INTO x_stg_max_sales_date_d;

      /* get the greater of max_sales_date param and max sales date in sales staging table */
      IF (x_stg_max_sales_date_d IS NOT NULL)
      THEN
          x_max_sales_date_d := greatest(x_stg_max_sales_date_d, x_dem_max_sales_date_d);
      ELSE
          x_max_sales_date_d := x_dem_max_sales_date_d;
      END IF;


      IF (p_min_max = 1) /* to determine begin date get cto_history_periods param value */
      THEN

         IF (C_DEM_HISTORY_PERIODS IS NULL)
         THEN
            EXECUTE IMMEDIATE 'SELECT pval FROM ' || C_MSD_DEM_SCHEMA || '.SYS_PARAMS'
                         || ' WHERE lower(pname) = ''cto_history_periods'' '
               INTO C_DEM_HISTORY_PERIODS;
         END IF;

         x_num_periods := -C_DEM_HISTORY_PERIODS;

      ELSE /* to determine end date get lead param value */

         IF (C_DEM_LEAD IS NULL)
         THEN
            EXECUTE IMMEDIATE 'SELECT value_float FROM ' || C_MSD_DEM_SCHEMA || '.INIT_PARAMS_0'
                         || ' WHERE lower(pname) = ''lead'' '
               INTO C_DEM_LEAD;
         END IF;

         x_num_periods := C_DEM_LEAD;

      END IF;

      /* check the time bucket used in demantra */
      x_dm_time_level := lower(msd_dem_common_utilities.dm_time_level);
      IF x_dm_time_level = 'day'
      THEN
          x_bom_date := x_max_sales_date_d + x_num_periods;
      ELSIF x_dm_time_level = 'week'
      THEN
          x_bom_date := x_max_sales_date_d + x_num_periods*7;
      ELSE
          x_bom_date := ADD_MONTHS(x_max_sales_date_d, x_num_periods);
      END IF;

      IF (p_bom_date IS NOT NULL)
      THEN
         IF (p_min_max = 1) /* begin date will be greater of p_bom_date and x_bom_date */
         THEN
            x_bom_date := greatest(p_bom_date, x_bom_date);
         ELSE /* end date will be lower of p_bom_date and x_bom_date */
            x_bom_date := least(p_bom_date, x_bom_date);
         END IF;
      END IF;

      /* Convert to the nearest bucket date */
      SELECT datet
         INTO x_bom_date
         FROM msd_dem_dates
         WHERE trunc(x_bom_date) BETWEEN start_date AND end_date;

      RETURN x_bom_date;

   EXCEPTION
      WHEN OTHERS THEN
         RETURN trunc(sysdate);

   END GET_CTO_EFFECTIVE_DATE;


END MSD_DEM_COMMON_UTILITIES;

/
