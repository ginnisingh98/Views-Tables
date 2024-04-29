--------------------------------------------------------
--  DDL for Package MSD_DEM_DEMANTRA_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_DEMANTRA_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: msddemdus.pls 120.0.12010000.4 2009/04/17 18:42:01 nallkuma ship $ */



   /*** CONSTANTS - BEGIN ***/

   /*** CONSTANTS - END ***/




   /*** PUBLIC PROCEDURES - BEGIN ***
    * LOG_MESSAGE
    * LOG_DEBUG
    */


      /* DUMMY PROCEDURE
       * This procedure logs a given message text in ???
       * param: p_buff - message text to be logged.
       */
      PROCEDURE LOG_MESSAGE ( p_buff           IN  VARCHAR2);


      /* DUMMY PROCEDURE
       * This procedure logs a given debug message text in ???
       * only if the profile MSD_DEM_DEBUG is set to 'Yes'.
       * param: p_buff - debug message text to be logged.
       */
      PROCEDURE LOG_DEBUG ( p_buff           IN  VARCHAR2);



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
       *    -3 : Any other error
       */
      FUNCTION GET_SEQUENCE_NEXTVAL (
      				p_table_name		IN	VARCHAR2,
      				p_column_name		IN	VARCHAR2,
      				p_seq_name		IN	VARCHAR2)
         RETURN NUMBER;


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
         RETURN NUMBER;


      /*
       * This function deletes the series given in Demantra Schema.
       * The function returns -
       *    n : The series id in case of success
       *   -1 : in case of error
       *   -2 : if series is not present
       *   -3 : Unable to set demantra schema name
       */
      FUNCTION DELETE_SERIES ( p_computed_name	IN	VARCHAR2 )
         RETURN NUMBER;


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
         RETURN NUMBER;


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
         RETURN NUMBER;


      /*
       * This function creates an integration interface given name and description
       * the the owning user.
       * The function returns -
       *    0 : in case of success (includes absence of the given integration interface name)
       *   -1 : in case of error
       *   -3 : Unable to set demantra schema name
       */
      FUNCTION DELETE_INTEGRATION_INTERFACE (p_name	IN	VARCHAR2)
         RETURN NUMBER;


      /*
       * This function creates a data profile
       * The function returns -
       *    n : the data profile id
       *   -1 : in case of error
       *   -3 : Unable to set demantra schema name
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
      			p_export_type				IN	NUMBER
      			)
         RETURN NUMBER;


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
         RETURN NUMBER;


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
         RETURN NUMBER;


      /*
       * This function creates the given workflow schema.
       * The function returns -
       *    n : the schema id
       *   -1 : in case of error
       *   -3 : Unable to set demantra schema name
       */
      FUNCTION CREATE_WORKFLOW_SCHEMA (
      			p_schema_name				IN	VARCHAR2,
      			p_schema_data				IN	VARCHAR2,
      			p_owner_id				IN	NUMBER,
      			p_creation_date				IN	DATE,
      			p_modified_date				IN	DATE,
      			p_schema_type				IN	NUMBER )
         RETURN NUMBER;


      /*
       * This function deletes the workflow schema given.
       * The function returns -
       *     0 : in case of success
       *    -1 : in case of error
       *    -3 : Unable to set demantra schema name
       */
      FUNCTION DELETE_WORKFLOW_SCHEMA ( p_schema_name		IN	VARCHAR2 )
         RETURN NUMBER;


      /*
       * This function gets the demantra schema name.
       * The function returns -
       *    <demantra schema name> : if demantra is installed.
       *    null                   : if demantra is not installed.
       */
      FUNCTION GET_DEMANTRA_SCHEMA
         RETURN VARCHAR2;


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
         RETURN NUMBER;


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
         RETURN NUMBER;


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
         RETURN NUMBER;

      /*
       * This function will insert rows into the TRANSFER_QUERY_INTERSECTIONS table
       * against the given data profiles.
       * The function returns -
       *    0 : in case of success
       *    -1 : in case of error
       *    -3 : Unable to set demantra schema name
       */
      FUNCTION ADD_INTERSECT_TO_PROFILE (
      			p_data_profile_id			IN	NUMBER,
      			p_base_level_id			IN	VARCHAR2)
         RETURN NUMBER;



   /*** PUBLIC FUNCTIONS - END ***/





END MSD_DEM_DEMANTRA_UTILITIES;

/
