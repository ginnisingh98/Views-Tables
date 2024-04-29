--------------------------------------------------------
--  DDL for Package Body MSD_DEM_DEMANTRA_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_DEMANTRA_UTILITIES" AS
/* $Header: msddemdub.pls 120.2.12010000.4 2009/04/17 18:48:25 nallkuma ship $ */





   /*** GLOBAL VARIABLE - BEGIN ***/

      g_demantra_schema_name 		VARCHAR2(30)	:= NULL;
      g_is_demantra_schema		BOOLEAN		:= FALSE;

   /*** GLOBAL VARIABLE - END ***/





   /*** PRIVATE FUNCTIONS - BEGIN ***
    * SET_DEMANTRA_SCHEMA
    */



      /*
       * This function sets the global variable g_demantra_schema_name
       * to the Demantra schema name
       * The function returns -
       *   0 : in case of success
       *  -1 : in case of failure
       */
      FUNCTION SET_DEMANTRA_SCHEMA
         RETURN NUMBER

         IS

            x_count		NUMBER		:= 0;
            x_session_user	VARCHAR2(100)	:= 0;
            x_sql		VARCHAR2(4000)	:= 0;

         BEGIN

            EXECUTE IMMEDIATE 'SELECT SYS_CONTEXT (''USERENV'', ''SESSION_USER'') FROM DUAL ' INTO x_session_user;

            EXECUTE IMMEDIATE 'SELECT count(1) FROM ALL_OBJECTS WHERE OWNER = :1 AND OBJECT_TYPE = ''TABLE'' AND OBJECT_NAME = ''MDP_MATRIX'' '
            		INTO x_count
            		USING x_session_user;
            IF (x_count = 1)
            THEN
               g_is_demantra_schema 	:= TRUE;
               g_demantra_schema_name   := x_session_user;
               RETURN 0;
            END IF;

            x_count := 0;
            EXECUTE IMMEDIATE 'SELECT FND_PROFILE.VALUE (''MSD_DEM_SCHEMA'') FROM DUAL ' INTO g_demantra_schema_name;

            IF (g_demantra_schema_name IS NULL)
            THEN
               RETURN -1;
            END IF;

            EXECUTE IMMEDIATE 'SELECT count(1) FROM ' || g_demantra_schema_name || '.MDP_MATRIX WHERE rownum <2'
               INTO x_count;

            log_debug ('msd_dem_demantra_utilities.set_demantra_schema : the demantra schema is ' || g_demantra_schema_name);

            log_debug ('Exiting msd_dem_demantra_utilities.set_demantra_schema ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN 0;

         EXCEPTION
            WHEN OTHERS THEN
               g_demantra_schema_name := NULL;
               RETURN -1;
         END SET_DEMANTRA_SCHEMA;



   /*** PRIVATE FUNCTIONS - END ***/




   /*** PUBLIC PROCEDURES - BEGIN ***
    * LOG_MESSAGE
    * LOG_DEBUG
    */


      /* DUMMY PROCEDURE
       * This procedure logs a given message text in ???
       * param: p_buff - message text to be logged.
       */
      PROCEDURE LOG_MESSAGE ( p_buff           IN  VARCHAR2)
      IS
      BEGIN
         RETURN;
      END LOG_MESSAGE;


      /* DUMMY PROCEDURE
       * This procedure logs a given debug message text in ???
       * only if the profile MSD_DEM_DEBUG is set to 'Yes'.
       * param: p_buff - debug message text to be logged.
       */
      PROCEDURE LOG_DEBUG ( p_buff           IN  VARCHAR2)
      IS
      BEGIN
         RETURN;
      END LOG_DEBUG;



   /*** PUBLIC PROCEDURES - END ***/




   /*** PUBLIC FUNCTIONS - BEGIN ***
    * GET_SEQUENCE_NEXTVAL
    * CREATE_SERIES
    * DELETE_SERIES
    * ADD_SERIES_TO_COMPONENT
    * CREATE_INTEGRATION_INTERFACE
    * DELETE_INTEGRATION_INTERFACE
    * CREATE_DATA_PROFILE
    * ADD_SERIES_TO_PROFILE
    * ADD_LEVEL_TO_PROFILE
    * CREATE_WORKFLOW_SCHEMA
    * DELETE_WORKFLOW_SCHEMA
    * GET_DEMANTRA_SCHEMA
    * CREATE_DEMANTRA_DB_OBJECT
    * DROP_DEMANTRA_DB_OBJECT
    * CREATE_SYNONYM_IN_EBS
    */


      /*
       * This function calls the GET_SEQ_NEXTVAL procedure in the Demantra schema.
       * The function returns -
       *     n : next value for the given sequence
       *    -1 : If table is not present
       *    -2 : If column is not present
       *    -3 : Unable to set demantra schema name
       *    -4 : Any other error
       */
      FUNCTION GET_SEQUENCE_NEXTVAL (
      				p_table_name		IN	VARCHAR2,
      				p_column_name		IN	VARCHAR2,
      				p_seq_name		IN	VARCHAR2)
         RETURN NUMBER
         IS

            x_sequence_nextval		NUMBER		:= NULL;
            x_sql			VARCHAR2(2000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;

            log_debug ('Entering msd_dem_demantra_utilities.get_sequence_nextval ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            IF (g_is_demantra_schema = FALSE)
            THEN
               log_debug ('Alter the schema for the session to ' || g_demantra_schema_name );
               x_sql := 'ALTER SESSION SET CURRENT_SCHEMA = ' || g_demantra_schema_name;
               log_debug (x_sql);
               EXECUTE IMMEDIATE x_sql;
            END IF;

            log_debug ('Calling Demantra procedure GET_SEQ_NEXTVAL');
            x_sql := 'BEGIN ' || g_demantra_schema_name || '.get_seq_nextval ( :1, :2, :3, :4); END;';
            log_debug (x_sql);

            EXECUTE IMMEDIATE x_sql USING p_table_name, p_column_name, p_seq_name, OUT x_sequence_nextval;

            IF (x_sequence_nextval = -1)
            THEN
               log_message ('Error(1) in function msd_dem_demantra_utilities.get_sequence_nextval ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message ('Table ' || p_table_name || 'does not exist.');
               RETURN -1;
            ELSIF (x_sequence_nextval = -1)
            THEN
               log_message ('Error(2) in function msd_dem_demantra_utilities.get_sequence_nextval ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message ('Column ' || p_column_name || 'does not exist in the table ' || p_table_name || '.');
               RETURN -2;
            END IF;

            log_debug ('Table : ' || p_table_name || ', Column Name : ' || p_column_name || ', Sequence Name : ' || p_seq_name);
            log_debug ('The sequence next val is : ' || to_char(x_sequence_nextval));

            IF (g_is_demantra_schema = FALSE)
            THEN
               log_debug ('Alter the schema for the session to APPS' );
               x_sql := 'ALTER SESSION SET CURRENT_SCHEMA = APPS';
               log_debug (x_sql);
               EXECUTE IMMEDIATE x_sql;
            END IF;

            log_debug ('Exiting msd_dem_demantra_utilities.get_sequence_nextval ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN x_sequence_nextval;

         EXCEPTION
            WHEN OTHERS THEN

               IF (g_is_demantra_schema = FALSE)
               THEN
                  log_debug ('Alter the schema for the session to APPS' );
                  x_sql := 'ALTER SESSION SET CURRENT_SCHEMA = APPS';
                  log_debug (x_sql);
                  EXECUTE IMMEDIATE x_sql;
                END IF;

               log_message ('Exception in function msd_dem_demantra_utilities.get_sequence_nextval ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -4;

         END GET_SEQUENCE_NEXTVAL;




      /*
       * This function creates the series given in Demantra schema.
       * The function returns -
       *    n : The series id in case of success
       *   -1 : in case of error
       *   -3 : Unable to set demantra schema name
       *   -4 : Some of the mandatory parameters are NULL.
       *   -5 : Unable to get next sequence value for forecast type id
       *   -6 : Column already present in the table
       */
      FUNCTION CREATE_SERIES (
      		p_computed_name			IN	VARCHAR2,
      		p_exp_template			IN	VARCHAR2,
      		p_computed_title        	IN      VARCHAR2,
      		p_sum_func			IN	VARCHAR2,
      		p_scaleble			IN	NUMBER,
      		p_editable			IN	NUMBER,
      		p_is_proportion			IN	NUMBER,
      		p_dbname			IN	VARCHAR2,
      		p_hint_message			IN	VARCHAR2,
      		p_hist_pred_type		IN	NUMBER,
      		p_data_table_name		IN	VARCHAR2,
      		p_prop_calc_series		IN	NUMBER,
      		p_base_level			IN	NUMBER,
      		p_expression_type		IN	NUMBER,
      		p_int_aggr_func			IN	VARCHAR2,
      		p_aggr_by			IN	NUMBER,
      		p_preservation_type		IN	NUMBER,
      		p_move_preservation_type	IN	NUMBER,
      		p_data_type			IN	NUMBER)
         RETURN NUMBER

         IS

            x_forecast_type_id		NUMBER		:= NULL;
            x_disp_order		NUMBER		:= NULL;
            x_return_value		NUMBER		:= NULL;
            x_sql			VARCHAR2(4000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;


            log_debug ('Entering msd_dem_demantra_utilities.create_series ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Verify that mandatory parameters should be not null');
            IF (   p_computed_name IS NULL
                OR p_exp_template IS NULL
                OR p_computed_title IS NULL
                OR p_sum_func IS NULL
                OR p_scaleble IS NULL
                OR p_editable IS NULL
                OR p_is_proportion IS NULL
                OR p_hist_pred_type IS NULL
                OR p_data_table_name IS NULL
                OR p_base_level IS NULL
                OR p_expression_type IS NULL
                OR p_int_aggr_func IS NULL
                OR p_data_type IS NULL)
            THEN
               log_message ('Error(1) in function msd_dem_demantra_utilities.create_series ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message ('Some of the mandatory parameters are null');
               RETURN -4;
            END IF;


            log_debug ('Get the next sequence value for forecast type id');
            x_forecast_type_id := get_sequence_nextval (
            					'COMPUTED_FIELDS',
            					'FORECAST_TYPE_ID',
            					'COMPUTED_FIELDS_SEQ');
            IF (x_forecast_type_id < 0)
            THEN
               log_message ('Error(2) in function msd_dem_demantra_utilities.create_series ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message ('Unable to get next sequence value for forecast type id');
               RETURN -5;
            END IF;
            log_debug ('Next sequence value for forecast_type_id : ' || to_char(x_forecast_type_id));


            log_debug ('Get the next value for disp order');
            x_sql := 'SELECT max(disp_order) + 1 FROM ' || g_demantra_schema_name || '.COMPUTED_FIELDS ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql INTO x_disp_order;
            log_debug ('Next value for disp_order : ' || to_char(x_disp_order));


            log_debug ('If parameter p_dbname is not null, then create the column in SALES_DATA table');
            IF (p_dbname IS NOT NULL)
            THEN

               log_debug ('First check if the column ' || p_dbname || ' already exists or not.');
               x_sql := 'SELECT count(1) FROM ALL_TAB_COLUMNS WHERE '
                           || '     owner = upper( :1 ) '
                           || ' AND table_name = ''SALES_DATA'' '
                           || ' AND column_name = upper (:2 ) ';
               log_debug (x_sql);
               EXECUTE IMMEDIATE x_sql
                  INTO x_return_value
                  USING g_demantra_schema_name, p_dbname;

               IF (x_return_value = 1)
               THEN
                  log_message ('Error(3) in function msd_dem_demantra_utilities.create_series ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                  log_message ('Column ' || p_dbname || ' already exists in the SALES_DATA table');
                  RETURN -6;
               END IF;

               x_sql := 'ALTER TABLE ' || g_demantra_schema_name || '.SALES_DATA'
                           || ' ADD ( ' || p_dbname || ' NUMBER(20,10)) ';
               log_debug (x_sql);
               EXECUTE IMMEDIATE x_sql;
               log_debug ('Column ' || p_dbname || 'created successfully');

            END IF;

            log_debug ('Build insert statement for creating record for the new series in the computed_fields table');
            x_sql := NULL;

            x_sql := 'INSERT INTO ' || g_demantra_schema_name || '.COMPUTED_FIELDS ( '
                        || 'FORECAST_TYPE_ID, COMPUTED_NAME, EXP_TEMPLATE, DISP_COLOR, DISP_LSTYLE, '
                        || 'DISP_LSYMBOL, PRINT_COLOR, PRINT_LSTYLE, PRINT_LSYMBOL, DISP_ORDER, '
                        || 'INFO_TYPE, TABLE_FORMAT, DO_HAVING, COMPUTED_TITLE, FIELD_TYPE, '
                        || 'SUM_FUNC, SCALEBLE, MODULE_TYPE, EDITABLE, IS_PROPORTION, '
                        || 'NULL_AS_ZERO, DBNAME, IS_DDLB, IS_CHECK, SERIES_WIDTH, '
                        || 'IS_DEFAULT, HINT_MESSAGE, HIST_PRED_TYPE, DATA_TABLE_NAME, LOOKUP_TYPE, '
                        || 'COL_SERIES_WIDTH, PROP_CALC_SERIES, BASE_LEVEL, EXPRESSION_TYPE, INT_AGGR_FUNC, '
                        || 'AGGR_BY, PRESERVATION_TYPE, IS_EDITABLE_SUMMARY, MOVE_PRESERVATION_TYPE, DATA_TYPE, '
                        || 'SAME_VAL_UPDATE )'
                        || ' VALUES ( '
                        || ' :1, :2, :3, 255, 1, '
                        || ' 1, 255, 1, 1, :4, '
                        || ' 1, ''###,###'', 0, :5, 1, '
                        || ' :6, :7, 0, :8, :9, '
                        || ' 0, :10, 0, 0, 250, '
                        || ' 0, :11, :12, :13, 0, '
                        || ' 10, :14, :15, :16, :17, '
                        || ' :18, :19, 0, :20, :21, '
                        || ' 0 )';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING
            			x_forecast_type_id, p_computed_name, p_exp_template,
            			x_disp_order,
            			p_computed_title,
            			p_sum_func, p_scaleble, p_editable, p_is_proportion,
            			p_dbname,
            			p_hint_message, p_hist_pred_type, p_data_table_name,
            			p_prop_calc_series, p_base_level, p_expression_type, p_int_aggr_func,
            			p_aggr_by, p_preservation_type, p_move_preservation_type, p_data_type;
            COMMIT;
            log_debug ('Insert statement executed successfully');

            log_debug ('Exiting msd_dem_demantra_utilities.create_series ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN x_forecast_type_id;

         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.create_series ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END CREATE_SERIES;




      /*
       * This function deletes the series given in Demantra Schema.
       * The function returns -
       *    n : The series id in case of success
       *   -1 : in case of error
       *   -2 : if series is not present
       *   -3 : Unable to set demantra schema name
       */
      FUNCTION DELETE_SERIES ( p_computed_name	IN	VARCHAR2 )
         RETURN NUMBER
         IS

            x_series_id			NUMBER		:= NULL;
            x_dbname			VARCHAR2(30)	:= NULL;
            x_return_value		NUMBER		:= NULL;
            x_sql			VARCHAR2(4000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;


            log_debug ('Entering msd_dem_demantra_utilities.delete_series ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Get series info for ' || p_computed_name);
            x_sql := 'SELECT forecast_type_id, dbname '
                        || ' FROM ' || g_demantra_schema_name || '.COMPUTED_FIELDS '
                        || ' WHERE computed_name = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql
               INTO x_series_id, x_dbname
               USING p_computed_name;

            log_debug ('Deleting all records for series id : ' || to_char(x_series_id));

            log_debug ('Deleting records from series_groups_m table ');
            x_sql := 'DELETE FROM ' || g_demantra_schema_name || '.SERIES_GROUPS_M WHERE series_id = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING x_series_id;

            log_debug ('Deleting records from user_security_series table ');
            x_sql := 'DELETE FROM ' || g_demantra_schema_name || '.USER_SECURITY_SERIES WHERE series_id = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING x_series_id;

            log_debug ('Deleting records from dcm_products_series table ');
            x_sql := 'DELETE FROM ' || g_demantra_schema_name || '.DCM_PRODUCTS_SERIES WHERE series_id = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING x_series_id;

            log_debug ('Deleting records from transfer_query_series table ');
            x_sql := 'DELETE FROM ' || g_demantra_schema_name || '.TRANSFER_QUERY_SERIES WHERE series_id = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING x_series_id;

            log_debug ('Deleting records from computed_fields table ');
            x_sql := 'DELETE FROM ' || g_demantra_schema_name || '.COMPUTED_FIELDS WHERE forecast_type_id = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING x_series_id;

            COMMIT;
            log_debug ('Series deleted successfully');


            log_debug ('Drop the db column for the series if present');
            IF (x_dbname IS NOT NULL)
            THEN

               log_debug ('First check if the column ' || x_dbname || ' exists or not.');
               x_sql := 'SELECT count(1) FROM ALL_TAB_COLUMNS WHERE '
                           || '     owner = upper( :1 ) '
                           || ' AND table_name = ''SALES_DATA'' '
                           || ' AND column_name = upper (:2 ) ';
               log_debug (x_sql);
               EXECUTE IMMEDIATE x_sql
                  INTO x_return_value
                  USING g_demantra_schema_name, x_dbname;

               IF (x_return_value = 0)
               THEN
                  log_message ('Column ' || x_dbname || ' does not exists in the SALES_DATA table');
                  RETURN x_series_id;
               END IF;

               x_sql := 'ALTER TABLE ' || g_demantra_schema_name || '.SALES_DATA'
                           || ' DROP ( ' || x_dbname || ' ) ';
               log_debug (x_sql);
               EXECUTE IMMEDIATE x_sql;
               log_debug ('Column ' || x_dbname || 'dropped successfully');

            END IF;

            log_debug ('Exiting msd_dem_demantra_utilities.delete_series ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN x_series_id;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               log_message ('Exception(1) in function msd_dem_demantra_utilities.delete_series ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               log_message ('Series : ' || p_computed_name || ' is not present. ');
               RETURN -2;
            WHEN OTHERS THEN
               log_message ('Exception(2) in function msd_dem_demantra_utilities.delete_series ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END DELETE_SERIES;




      /*
       * This function adds the given series to the given component and also
       * to the user who owns the component.
       * The function returns -
       *    0 : In case of success
       *   -1 : in case of error
       *   -3 : Unable to set demantra schema name
       */
      FUNCTION ADD_SERIES_TO_COMPONENT (
      				p_series_id		IN	NUMBER,
      				p_component_id		IN	NUMBER)
         RETURN NUMBER
         IS

            x_computed_title		VARCHAR2(100)	:= NULL;
            x_product_name		VARCHAR2(255)	:= NULL;
            x_user_id			NUMBER		:= NULL;
            x_sql			VARCHAR2(4000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;


            log_debug ('Entering msd_dem_demantra_utilities.add_series_to_component ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Check if series with id : ' || to_char(p_series_id) || ' is present or not.');
            x_sql := ' SELECT computed_title FROM ' || g_demantra_schema_name || '.COMPUTED_FIELDS WHERE forecast_type_id = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql
            		INTO x_computed_title
            		USING p_series_id;

            log_debug ('Check if component with id : ' || to_char(p_component_id) || ' is present or not.');
            x_sql := 'SELECT product_name, user_id FROM ' || g_demantra_schema_name || '.DCM_PRODUCTS WHERE dcm_product_id = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql
            		INTO x_product_name,
            		     x_user_id
            		USING p_component_id;

            log_debug ('Deleting series : ' || x_computed_title || ' from the component : ' || x_product_name ||' if it exists');
            x_sql := 'DELETE FROM ' || g_demantra_schema_name || '.DCM_PRODUCTS_SERIES WHERE DCM_PRODUCT_ID = :1 AND SERIES_ID = :2 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING p_component_id, p_series_id;

            log_debug ('Adding series : ' || x_computed_title || ' to the component : ' || x_product_name);
            x_sql := 'INSERT INTO ' || g_demantra_schema_name || '.DCM_PRODUCTS_SERIES ( DCM_PRODUCT_ID, SERIES_ID ) '
                        || ' VALUES ( :1, :2 ) ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING p_component_id, p_series_id;

            log_debug ('Deleting series : ' || x_computed_title || ' from the user with id : ' || to_char(x_user_id)||' if it exists');
            x_sql := 'DELETE FROM ' || g_demantra_schema_name || '.USER_SECURITY_SERIES WHERE USER_ID = :1 AND SERIES_ID= :2 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING x_user_id, p_series_id;

            log_debug ('Adding series : ' || x_computed_title || ' to the user with id : ' || to_char(x_user_id));
            x_sql := 'INSERT INTO ' || g_demantra_schema_name || '.USER_SECURITY_SERIES ( USER_ID, SERIES_ID ) '
                        || ' VALUES ( :1, :2 ) ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING x_user_id, p_series_id;

            COMMIT;
            log_debug ('Series successfully added to the component and its owner.');

            log_debug ('Exiting msd_dem_demantra_utilities.add_series_to_component ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN 0;


         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.add_series_to_component ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END ADD_SERIES_TO_COMPONENT;




      /*
       * This function creates an integration interface given name and description
       * the the owning user.
       * The function returns -
       *    n : integration interface id
       *   -1 : in case of error
       *   -3 : Unable to set demantra schema name
       *   -4 : If an integration interface with the same name already exists
       *   -5 : Unable to get next sequence value for integration interface id
       */
      FUNCTION CREATE_INTEGRATION_INTERFACE (
      				p_name			IN	VARCHAR2,
      				p_description		IN	VARCHAR2,
      				p_user_id		IN	NUMBER)
         RETURN NUMBER
         IS

            x_return_value		NUMBER		:= NULL;
            x_integration_interface_id	NUMBER		:= NULL;
            x_sql			VARCHAR2(4000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;

            log_debug ('Entering msd_dem_demantra_utilities.create_integration_interface ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Check if an integration interface with the same name already exists');
            x_sql := 'SELECT count(1) FROM ' || g_demantra_schema_name || '.TRANSFER_LIST WHERE name = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql
            		INTO x_return_value
            		USING p_name;

            IF (x_return_value = 1)
            THEN
                  log_message ('Error(1) in function msd_dem_demantra_utilities.create_integration_interface ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                  log_message ('Integration interface : ' || p_name || ' already exists.');
                  RETURN -4;
            END IF;


            log_debug ('Get the next sequence value for integration interface id');
            x_integration_interface_id := get_sequence_nextval (
            						'TRANSFER_LIST',
            						'ID',
            						'TRANSFER_ID_SEQ');
            IF (x_integration_interface_id < 0)
            THEN
               log_message ('Error(2) in function msd_dem_demantra_utilities.create_integration_interface ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message ('Unable to get next sequence value for integration interface id');
               RETURN -5;
            END IF;
            log_debug ('Next sequence value for id : ' || to_char(x_integration_interface_id));


            log_debug ('Insert a row into TRANSFER_LIST for the integration interface');
            x_sql := 'INSERT INTO ' || g_demantra_schema_name || '.TRANSFER_LIST '
                        || ' ( ID, NAME, DESCRIPTION, USER_ID, USE_EXTERNAL_SCHEMA ) '
                        || ' VALUES ( '
                        || ' :1, :2, :3, :4, 0 ) ';
            log_debug(x_sql);
            EXECUTE IMMEDIATE x_sql USING x_integration_interface_id, p_name, p_description, p_user_id;

            COMMIT;
            log_debug ('Integration Interface created successfully');

            log_debug ('Exiting msd_dem_demantra_utilities.create_integration_interface ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN x_integration_interface_id;

         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.create_integration_interface ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END CREATE_INTEGRATION_INTERFACE;




      /*
       * This function creates an integration interface given name and description
       * the the owning user.
       * The function returns -
       *    0 : in case of success (includes absence of the given integration interface name)
       *   -1 : in case of error
       *   -3 : Unable to set demantra schema name
       */
      FUNCTION DELETE_INTEGRATION_INTERFACE (p_name	IN	VARCHAR2)
         RETURN NUMBER
         IS

            x_sql			VARCHAR2(4000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;

            log_debug ('Entering msd_dem_demantra_utilities.delete_integration_interface ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Deleting the integration interface '|| p_name || ' all the profiles under it.');
            x_sql := 'DELETE FROM ' || g_demantra_schema_name || '.TRANSFER_LIST WHERE name = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING p_name;

            COMMIT;
            log_debug ('Integration Interface deleted successfully');

            log_debug ('Exiting msd_dem_demantra_utilities.delete_integration_interface ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN 0;

         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.delete_integration_interface ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END DELETE_INTEGRATION_INTERFACE;




      /*
       * This function creates a data profile
       * The function returns -
       *    n : the data profile id
       *   -1 : in case of error
       *   -3 : Unable to set demantra schema name
       *   -4 : Data Profile Name given already exists
       *   -5 : Unable to get next sequence value for data profile id
       */
      FUNCTION CREATE_DATA_PROFILE (
      			p_transfer_id				IN	NUMBER,
      			p_view_name				IN	VARCHAR2,
      			p_table_name				IN 	VARCHAR2,
      			p_view_type				IN	NUMBER,
      			p_use_real_proportion			IN	NUMBER,
      			p_insertnewcombinations			IN	NUMBER,
      			p_insertforecasthorizon			IN	NUMBER,
      			p_query_name				IN	VARCHAR2,
      			p_description				IN	VARCHAR2,
      			p_time_res_id				IN	NUMBER,
      			p_from_date				IN	DATE,
      			p_until_date				IN	DATE,
      			p_relative_date				IN	NUMBER,
      			p_relative_from_date			IN	NUMBER,
      			p_relative_until_date			IN	NUMBER,
      			p_integration_type			IN	NUMBER,
      			p_export_type				IN	NUMBER	)
         RETURN NUMBER
         IS

            x_return_value		NUMBER		:= NULL;
            x_data_profile_id		NUMBER		:= NULL;
            x_sql			VARCHAR2(4000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;

            log_debug ('Entering msd_dem_demantra_utilities.create_data_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Check if a data profile with the same name already exists or not');
            x_sql := 'SELECT count(1) FROM ' || g_demantra_schema_name || '.TRANSFER_QUERY WHERE query_name = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql
            		INTO x_return_value
            		USING p_query_name;

            IF (x_return_value = 1)
            THEN
                  log_message ('Error(1) in function msd_dem_demantra_utilities.create_data_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                  log_message ('Data Profile : ' || p_query_name || ' already exists.');
                  RETURN -4;
            END IF;


            log_debug ('Get the next sequence value for data profile id');
            x_data_profile_id := get_sequence_nextval (
            					'TRANSFER_QUERY',
            					'ID',
            					'TRANSFER_QUERY_SEQ');
            IF (x_data_profile_id < 0)
            THEN
               log_message ('Error(2) in function msd_dem_demantra_utilities.create_data_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message ('Unable to get next sequence value for data profile id');
               RETURN -5;
            END IF;
            log_debug ('Next sequence value for id : ' || to_char(x_data_profile_id));


            log_debug ('Insert a row for the data profile into the table TRANSFER_QUERY');
            x_sql := 'INSERT INTO ' || g_demantra_schema_name || '.TRANSFER_QUERY ( '
                        || ' ID, TRANSFER_ID, PRESENTATION_TYPE, VIEW_NAME, TABLE_NAME, '
                        || ' FILE_NAME, DELIMITER, IS_FIXED_WIDTH, VIEW_TYPE, USE_REAL_PROPORTION, '
                        || ' INSERTNEWCOMBINATIONS, INSERTFORECASTHORIZON, QUERY_NAME, DESCRIPTION, TIME_RES_ID, '
                        || ' FROM_DATE, UNTIL_DATE, RELATIVE_DATE, RELATIVE_FROM_DATE, RELATIVE_UNTIL_DATE, '
                        || ' UNIT_ID, INDEX_ID, DATA_SCALE, DM_ID, SCHEMA_ID, '
                        || ' QUERY_ID, INTEGRATION_TYPE, EXPORT_TYPE, BATCH_FILE, IMPORT_FROM_FILE, '
                        || ' LAST_EXPORT_DATE, FILTER_SD_BY_GL ) '
                        || ' VALUES ( '
                        || ' :1, :2, 1, :3, :4, '
                        || ' null, null, null, :5, :6, '
                        || ' :7, :8, :9, :10, :11, '
                        || ' :12, :13, :14, :15, :16, '
                        || ' 1, null, 1, null, null, '
                        || ' null, :17, :18, null, 0, '
                        || ' null, 0 ) ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql
            		USING x_data_profile_id, p_transfer_id, p_view_name, p_table_name,
            		      p_view_type, p_use_real_proportion,
            		      p_insertnewcombinations, p_insertforecasthorizon, p_query_name, p_description, p_time_res_id,
            		      p_from_date, p_until_date, p_relative_date, p_relative_from_date, p_relative_until_date,
            		      p_integration_type, p_export_type;

            /* -- nallkuma
            log_debug ('Insert a row for the data profile into the table TRANSFER_QUERY_INTERSECTIONS');
            x_sql := 'INSERT INTO ' || g_demantra_schema_name || '.TRANSFER_QUERY_INTERSECTIONS ( '
                        || ' ID, BASE_LEVEL_ID, TYPE ) '
                        || ' VALUES ( '
                        || ' :1, :2, 1 ) ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING x_data_profile_id, p_base_level_id;
            */

            COMMIT;
            log_debug ('Data Profile created successfully.');

            log_debug ('Exiting msd_dem_demantra_utilities.create_data_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN x_data_profile_id;

         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.create_data_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END CREATE_DATA_PROFILE;




      /*
       * This function adds the given series to the data profile.
       * The function returns -
       *     0 : in case of success
       *    -1 : in case of error
       *    -3 : Unable to set demantra schema name
       */
      FUNCTION ADD_SERIES_TO_PROFILE (
      			p_data_profile_id			IN	NUMBER,
      			p_series_id				IN	NUMBER )
         RETURN NUMBER
         IS

            x_sql			VARCHAR2(4000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;

            log_debug ('Entering msd_dem_demantra_utilities.add_series_to_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Adding series : ' || to_char(p_series_id) || ' to the profile : ' || to_char(p_data_profile_id));
            x_sql := 'INSERT INTO ' || g_demantra_schema_name || '.TRANSFER_QUERY_SERIES ( ID, SERIES_ID, LOAD_OPTION, PURGE_OPTION ) '
                        || ' VALUES ( :1, :2, 0, 0 ) ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING p_data_profile_id, p_series_id;

            COMMIT;
            log_debug ('Series added successfully to the data profile');

            log_debug ('Exiting msd_dem_demantra_utilities.add_series_to_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN 0;

         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.add_series_to_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END ADD_SERIES_TO_PROFILE;


      /*
       * This function adds the given level to the data profile.
       * The function returns -
       *     0 : in case of success
       *    -1 : in case of error
       *    -3 : Unable to set demantra schema name
       */
      FUNCTION ADD_LEVEL_TO_PROFILE (
      			p_data_profile_id			IN	NUMBER,
      			p_level_id				IN	NUMBER,
      			p_lorder				IN	NUMBER )
         RETURN NUMBER
         IS

            x_sql			VARCHAR2(4000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;

            log_debug ('Entering msd_dem_demantra_utilities.add_level_to_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Adding level : ' || to_char(p_level_id) || ' to the profile : ' || to_char(p_data_profile_id));
            x_sql := 'INSERT INTO ' || g_demantra_schema_name || '.TRANSFER_QUERY_LEVELS ( ID, LEVEL_ID, LORDER ) '
                        || ' VALUES ( :1, :2, :3 ) ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING p_data_profile_id, p_level_id, p_lorder;

            COMMIT;
            log_debug ('Level added successfully to the data profile');

            log_debug ('Exiting msd_dem_demantra_utilities.add_level_to_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN 0;

         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.add_level_to_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END ADD_LEVEL_TO_PROFILE;





      /*
       * This function creates the given workflow schema.
       * The function returns -
       *    n : the schema id
       *   -1 : in case of error
       *   -3 : Unable to set demantra schema name
       *   -4 : If the given workflow schema name already exists
       *   -5 : Unable to get next sequence value for schema id
       */
      FUNCTION CREATE_WORKFLOW_SCHEMA (
      			p_schema_name				IN	VARCHAR2,
      			p_schema_data				IN	VARCHAR2,
      			p_owner_id				IN	NUMBER,
      			p_creation_date				IN	DATE,
      			p_modified_date				IN	DATE,
      			p_schema_type				IN	NUMBER )
         RETURN NUMBER
         IS

            x_return_value		NUMBER		:= NULL;
            x_schema_id			NUMBER		:= NULL;
            x_sql			VARCHAR2(4000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;

            log_debug ('Entering msd_dem_demantra_utilities.create_workflow_schema ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('First check if the workflow schema : ' || p_schema_name || ' already exists or not. ');
            x_sql := 'SELECT count(1) FROM ' || g_demantra_schema_name || '.WF_SCHEMAS WHERE schema_name = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql
            		INTO x_return_value
            		USING p_schema_name;

            IF (x_return_value <> 0)
            THEN
                  log_message ('Error(1) in function msd_dem_demantra_utilities.create_workflow_schema ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                  log_message ('Workflow Schema : ' || p_schema_name || ' already exists.');
                  RETURN -4;
            END IF;


            log_debug ('Get the next sequence value for schema id');
            x_schema_id := get_sequence_nextval (
            				'WF_SCHEMAS',
            				'SCHEMA_ID',
            				'WF_SCHEMA_ID_SEQ');
            IF (x_schema_id < 0)
            THEN
               log_message ('Error(2) in function msd_dem_demantra_utilities.create_workflow_schema ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message ('Unable to get next sequence value for schema id');
               RETURN -5;
            END IF;
            log_debug ('Next sequence value for id : ' || to_char(x_schema_id));


            log_debug ('Insert a row for the workflow schema into the table WF_SCHEMAS');
            x_sql := 'INSERT INTO ' || g_demantra_schema_name || '.WF_SCHEMAS ( '
                        || ' SCHEMA_ID, SCHEMA_NAME, SCHEMA_DATA, STATUS, OWNER_ID, '
                        || ' CREATION_DATE, MODIFIED_DATE, TEMPORARY, SCHEMA_TYPE ) '
                        || ' VALUES ( '
                        || ' :1, :2, :3, 1, :4, '
                        || ' :5, :6, 0, :7 ) ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql
            		USING x_schema_id, p_schema_name, p_schema_data, p_owner_id,
            		      p_creation_date, p_modified_date, p_schema_type;

            COMMIT;
            log_debug ('Workflow Schema created successfully');

            log_debug ('Exiting msd_dem_demantra_utilities.create_workflow_schema ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN x_schema_id;

         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.create_workflow_schema ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END CREATE_WORKFLOW_SCHEMA;




      /*
       * This function deletes the workflow schema given.
       * The function returns -
       *     0 : in case of success
       *    -1 : in case of error
       *    -3 : Unable to set demantra schema name
       */
      FUNCTION DELETE_WORKFLOW_SCHEMA ( p_schema_name		IN	VARCHAR2 )
         RETURN NUMBER
         IS

            x_sql			VARCHAR2(4000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;

            log_debug ('Entering msd_dem_demantra_utilities.delete_workflow_schema ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Deleting workflow schema : ' || p_schema_name);
            x_sql := 'DELETE FROM ' || g_demantra_schema_name || '.WF_SCHEMAS WHERE schema_name = :1 ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING p_schema_name;

            COMMIT;
            log_debug ('Workflow Schema deleted successfully.');

            log_debug ('Exiting msd_dem_demantra_utilities.delete_workflow_schema ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN 0;

         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.delete_workflow_schema ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END DELETE_WORKFLOW_SCHEMA;




      /*
       * This function gets the demantra schema name.
       *    <demantra schema name> : if demantra is installed.
       *    null                   : if demantra is not installed.
       */
      FUNCTION GET_DEMANTRA_SCHEMA
         RETURN VARCHAR2
         IS
         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN null;
               END IF;
            END IF;

            log_debug ('Exiting msd_dem_demantra_utilities.get_demantra_schema ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN g_demantra_schema_name;

         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.get_demantra_schema ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN null;

         END GET_DEMANTRA_SCHEMA;




      /*
       * This function creates the given db object.
       * The function returns -
       *    0 : in case of success
       *    -1 : in case of error
       *    -3 : Unable to set demantra schema name
       */
      FUNCTION CREATE_DEMANTRA_DB_OBJECT (
      			p_object_type				IN 	VARCHAR2,
      			p_object_name				IN	VARCHAR2,
      			p_create_sql				IN	VARCHAR2)
         RETURN NUMBER
         IS
         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;

            log_debug ('Entering msd_dem_demantra_utilities.create_demantra_db_object ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Demantra object : ' || p_object_name);
            log_debug ('Object Type : ' || p_object_type);

            log_debug ('Creating DB object.');
            log_debug (p_create_sql);
            EXECUTE IMMEDIATE p_create_sql;

            log_debug ('DB Object created successfully.');

            log_debug ('Exiting msd_dem_demantra_utilities.create_demantra_db_object ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN 0;

         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.create_demantra_db_object ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END CREATE_DEMANTRA_DB_OBJECT;




      /*
       * This function drop the given demantra db object.
       * The function returns -
       *    0 : in case of success/object not present
       *    -1 : in case of error
       *    -3 : Unable to set demantra schema name
       */
      FUNCTION DROP_DEMANTRA_DB_OBJECT (
      			p_object_type				IN	VARCHAR2,
      			p_object_name				IN	VARCHAR2 )
         RETURN NUMBER
         IS

            x_return_value		NUMBER		:= NULL;
            x_sql			VARCHAR2(4000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;

            log_debug ('Entering msd_dem_demantra_utilities.drop_demantra_db_object ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Demantra object : ' || p_object_name);
            log_debug ('Object Type : ' || p_object_type);

            log_debug ('First check if the object already exists or not');
            x_sql := 'SELECT 1 FROM all_objects WHERE owner = :1 AND object_type = :2 AND object_name = :3';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql
            		INTO x_return_value
            		USING g_demantra_schema_name, p_object_type, p_object_name;

            log_debug ('Dropping Demantra DB object');
            x_sql := ' DROP ' || p_object_type || ' ' || g_demantra_schema_name || '.' || p_object_name;
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql;

            log_debug ('Demantra Object dropped successfully');

            log_debug ('Exiting msd_dem_demantra_utilities.drop_demantra_db_object ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN 0;

         EXCEPTION

            WHEN NO_DATA_FOUND THEN
               log_message ('Exception(1) in function msd_dem_demantra_utilities.drop_demantra_db_object ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               log_message ('Object to be dropped not found. Ignore this error.');
               RETURN 0;

            WHEN OTHERS THEN
               log_message ('Exception(2) in function msd_dem_demantra_utilities.drop_demantra_db_object ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END DROP_DEMANTRA_DB_OBJECT;




      /*
       * This function work only if Demantra and APS are on the same DB instance.
       * This function creates a synonym in the APPS schema using the given sql
       * script.
       * The function returns -
       *    0 : in case of success
       *    -1 : in case of error
       *    -3 : Unable to set demantra schema name
       */
      FUNCTION CREATE_SYNONYM_IN_EBS (
      			p_object_name				IN	VARCHAR2,
      			p_create_replace_sql			IN	VARCHAR2)
         RETURN NUMBER
         IS
         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;

            log_debug ('Entering msd_dem_demantra_utilities.create_synonym_in_ebs ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Object Name : ' || p_object_name);

            /* First check if Demantra and APS are on the same DB instance */
            IF (g_is_demantra_schema)
            THEN
               log_message ('Note in function msd_dem_demantra_utilities.create_synonym_in_ebs ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message ('Synonym ' || p_object_name || 'not created. Create the synonym manually.');
               RETURN 0;
            END IF;

            log_debug ('Creating Synonym.');
            log_debug (p_create_replace_sql);
            EXECUTE IMMEDIATE p_create_replace_sql;

            log_debug ('Synonym created successfully.');

            log_debug ('Exiting msd_dem_demantra_utilities.create_synonym_in_ebs ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN 0;

         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.create_synonym_in_ebs ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END CREATE_SYNONYM_IN_EBS;



      /*
       * This function will insert base_level_id values
       * into the TRANSFER_QUERY_INTERSECTIONS table against the given data profile.
       * The TYPE column is always defaulted to value "1".
       * The function returns -
       *    0 : in case of success
       *    -1 : in case of error
       *    -3 : Unable to set demantra schema name
       */
      FUNCTION ADD_INTERSECT_TO_PROFILE (
      			p_data_profile_id			IN	NUMBER,
      			p_base_level_id			IN	VARCHAR2)
         RETURN NUMBER
       IS

            x_sql			VARCHAR2(4000)	:= NULL;

         BEGIN

            IF (g_demantra_schema_name IS NULL)
            THEN
               IF (set_demantra_schema = -1)
               THEN
                  RETURN -3;
               END IF;
            END IF;

            log_debug ('Entering msd_dem_demantra_utilities.add_intersect_to_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

            log_debug ('Adding base_level_id : ' || to_char(p_base_level_id) || ' to the profile : ' || to_char(p_data_profile_id));
          x_sql := 'INSERT INTO ' || g_demantra_schema_name || '.TRANSFER_QUERY_INTERSECTIONS ( ID, BASE_LEVEL_ID, TYPE ) '
                        || ' VALUES ( :1, :2, 1 ) ';
            log_debug (x_sql);
            EXECUTE IMMEDIATE x_sql USING p_data_profile_id, p_base_level_id;

            COMMIT;
            log_debug ('Base level id added successfully to the data profile');

            log_debug ('Exiting msd_dem_demantra_utilities.add_intersect_to_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            RETURN 0;

         EXCEPTION
            WHEN OTHERS THEN
               log_message ('Exception in function msd_dem_demantra_utilities.add_intersect_to_profile ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
               log_message (substr(SQLERRM,1,150));
               RETURN -1;

         END ADD_INTERSECT_TO_PROFILE;

   /*** PUBLIC FUNCTIONS - END ***/





END MSD_DEM_DEMANTRA_UTILITIES;

/
