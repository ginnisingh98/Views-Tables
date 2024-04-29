--------------------------------------------------------
--  DDL for Package BSC_APPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_APPS" AUTHID CURRENT_USER AS
/* $Header: BSCAPPSS.pls 120.1 2006/02/14 13:09:25 meastmon noship $ */
/*===========================================================================+
|               Copyright (c) 1999 Oracle Corporation                        |
|                  Redwood Shores, California, USA                           |
|                       All rights reserved                                  |
|============================================================================|
|
|   Name:          BSCAPPSS.pls
|
|   Description:   This package contains procedures to perform APPS
|                  related calls by all BSC modules.
|
|                  This package have to be installed in both Enterprise and
|                  Personal versions od BSC.
|
|                  For Personal version, this package requires the following
|                  dummy packages:
|                  - FND_INSTALLATION (files: BSCFNDIS.pls and BSCFNDIB.pls)
|                  - AD_DDL (files: BSCADDDS.pls and BSCADDDB.pls)
|
|                  Before you can call any other procedure in this package, you
|                  have to call the procedure INIT_BSC_APPS of this package.
|                  This procedure initializes some global variables for example
|                  one variable that indicates the enviroment on which you are
|                  (APPS or Personal)
|
|   Example:
|
|   Security:
|
|   History:       Created By: Mauricio Eastmond            Date: 04-JAN-00
|
|   Srini Jandyala 27-Feb-02   Added Get_Lookup_Value() procedure for HTML UI
|          20-Aug-03   Adeulgao fixed bug#3008243 added 2 functions
|                      (overloaded) get_user_schema to get the schema name
|
|          19-APR-2004 PAJOHRI  Bug #3541933, added a overloaded function     |
|                               Do_DDL_AT                                     |
+============================================================================*/

TYPE Autonomous_Statements IS Record
(       x_Fnd_Apps_Schema         VARCHAR2(30)
    ,   x_Bsc_Apps_Short_Name     VARCHAR2(30)
    ,   x_Statement               VARCHAR2(8000)
    ,   x_Object_Name             VARCHAR2(100)
    ,   x_Statement_Type          INTEGER
);
--==============================================================
TYPE Autonomous_Statements_Tbl_Type IS TABLE OF Autonomous_Statements INDEX BY BINARY_INTEGER;


-- Global variables
    TYPE t_ddl_stmt_rec IS RECORD (
        sql_stmt VARCHAR2(32700):= NULL,
        stmt_type INTEGER := 0,
        object_name VARCHAR2(100) := NULL
    );

    TYPE t_array_ddl_stmts IS TABLE OF t_ddl_stmt_rec INDEX BY BINARY_INTEGER;

    LOG_FILE    NUMBER := 0;    -- Log file
    OUTPUT_FILE NUMBER := 1;    -- Output file. Only make sense in APPS environment
                        -- In Personal, It always write in the log file.

    apps_env BOOLEAN := FALSE;
    bsc_apps_short_name VARCHAR2(30) := NULL;
    bsc_apps_schema VARCHAR2(30) := NULL;
    fnd_apps_short_name VARCHAR2(30) := NULL;
    fnd_apps_schema VARCHAR2(30) := NULL;
    bsc_appl_id NUMBER;
    apps_user_id NUMBER;
    bsc_mv BOOLEAN := FALSE;

    bsc_storage_clause VARCHAR2(250) := ' '; -- Storage clause used when creating tables and indexes
    bsc_tablespace_clause_tbl VARCHAR2(250) := ' '; -- Tablespace clause used when creating tables
    bsc_tablespace_clause_idx VARCHAR2(250) := ' '; -- Tablespace clause used when creating indexes

    fnd_global_user_id NUMBER := FND_GLOBAL.USER_ID;

    -- Tablespace types
    dimension_table_tbs_type VARCHAR2(20) := 'DIMENSION_TABLE';
    dimension_index_tbs_type VARCHAR2(20) := 'DIMENSION_INDEX';
    input_table_tbs_type     VARCHAR2(20) := 'INPUT_TABLE';
    input_index_tbs_type     VARCHAR2(20) := 'INPUT_INDEX';
    base_table_tbs_type      VARCHAR2(20) := 'BASE_TABLE';
    base_index_tbs_type      VARCHAR2(20) := 'BASE_INDEX';
    summary_table_tbs_type   VARCHAR2(20) := 'SUMMARY_TABLE';
    summary_index_tbs_type   VARCHAR2(20) := 'SUMMARY_INDEX';
    other_table_tbs_type     VARCHAR2(20) := 'OTHER_TABLE';
    other_index_tbs_type     VARCHAR2(20) := 'OTHER_INDEX';

    -- Tablespace names
    dimension_table_tbs_name VARCHAR2(80) := NULL;
    dimension_index_tbs_name VARCHAR2(80) := NULL;
    input_table_tbs_name     VARCHAR2(80) := NULL;
    input_index_tbs_name     VARCHAR2(80) := NULL;
    base_table_tbs_name      VARCHAR2(80) := NULL;
    base_index_tbs_name      VARCHAR2(80) := NULL;
    summary_table_tbs_name   VARCHAR2(80) := NULL;
    summary_index_tbs_name   VARCHAR2(80) := NULL;
    other_table_tbs_name     VARCHAR2(80) := NULL;
    other_index_tbs_name     VARCHAR2(80) := NULL;

/*===========================================================================+
|
|   Name:          Add_Value_Big_In_Cond
|
|   Description:   Insert the given value into the temporary table of big
|                  'in' conditions for the given variable_id.
|
|   Parameters:    x_variable_id  variable id.
|                  x_value        value
|
+============================================================================*/
PROCEDURE Add_Value_Big_In_Cond(
    x_variable_id IN NUMBER,
    x_value IN NUMBER
    );

/*===========================================================================+
|
|   Name:          Add_Value_Big_In_Cond
|
|   Description:   Insert the given value into the temporary table of big
|                  'in' conditions for the given variable_id.
|
|   Parameters:    x_variable_id  variable id.
|                  x_value        value
|
+============================================================================*/
PROCEDURE Add_Value_Big_In_Cond(
    x_variable_id IN NUMBER,
    x_value IN VARCHAR2
    );

/*===========================================================================+
|
|   Name:          Apps_Initialize_VB
|
|   Description:   Based on the responsibility, initialize the application.
|                  This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:    x_user_id      User id.
|                  x_resp_id      Responsibility id
|
+============================================================================*/
PROCEDURE Apps_Initialize_VB(
    x_user_id IN NUMBER,
    x_resp_id IN NUMBER
    );


/*===========================================================================+
|
|   Name:          CheckError
|
|   Description:   Check if there is an error in BSC_MESSAGE_LOGS registered
|                  by the given functoin name.
|
|   Parameters:    x_calling_function     Nae of the function/procedure
|
+============================================================================*/
FUNCTION CheckError (
    x_calling_function IN VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Do_DDL
|
|   Description:   Execute the given DDL statement.
|                  If the environment is APPS it uses AD_DDL.DO_DDL procedure
|                  who execute the statement in the proper schema. Additionally
|                  creates a grant/synonym to APPS schema if it is necessary.
|                  Otherwise the statement is execute in the current schema.
|
|   Parameters:    x_statement      DDL statement. This is the only parameter
|                   for Personal environment.
|                  x_statement_type One of the folowing macros:
|                   ad_ddl.alter_sequence
|                   ad_ddl.alter_table
|                   ad_ddl.alter_trigger
|                                       ad_ddl.alter_view
|                                       ad_ddl.create_index
|                                       ad_ddl.create_sequence
|                                       ad_ddl.create_synonym
|                                       ad_ddl.create_table
|                                       ad_ddl.create_trigger
|                                       ad_ddl.create_view
|                                       ad_ddl.drop_index
|                                       ad_ddl.drop_sequence
|                                       ad_ddl.drop_synonym
|                                       ad_ddl.drop_table
|                                       ad_ddl.drop_trigger
|                                       ad_ddl.drop_view
|                                       ad_ddl.truncate_table
|                  x_object_name    The name of the object you are affecting
|
|   Notes: This procedure propagate any oracle error that is encountered.
|
+============================================================================*/
PROCEDURE Do_DDL(
    x_statement IN VARCHAR2,
        x_statement_type IN INTEGER := 0,
        x_object_name IN VARCHAR2 := NULL
    );


/*===========================================================================+
|
|   Name:          Do_DDL_AT
|
|   Description:   Execute the given DDL statement within an
|                  AUTOMOMOUS TRANSACTION. This means that the implicit
|                  commit executed by the ddl do not commit the
|                  transaction that caller is executing.
+============================================================================*/
PROCEDURE Do_DDL_AT(
    x_statement IN VARCHAR2,
    x_statement_type IN INTEGER := 0,
    x_object_name IN VARCHAR2 := NULL,
    x_fnd_apps_schema IN VARCHAR2,
    x_bsc_apps_short_name IN VARCHAR2
    );


/*===========================================================================+
|
|   Name:          Do_DDL_VB
|
|   Description:   Execute the given DDL statement.
|                  This procedure is for VB clients. It calls DO_DDL procedure
|                  and inserts any error in BSC_MESSAGE_LOGS table.
|
|   Parameters:    x_statement      DDL statement. This is the only parameter
|                   for Personal environment.
|                  x_statement_type One of the folowing macros:
|                   ad_ddl.alter_sequence
|                   ad_ddl.alter_table
|                   ad_ddl.alter_trigger
|                                       ad_ddl.alter_view
|                                       ad_ddl.create_index
|                                       ad_ddl.create_sequence
|                                       ad_ddl.create_synonym
|                                       ad_ddl.create_table
|                                       ad_ddl.create_trigger
|                                       ad_ddl.create_view
|                                       ad_ddl.drop_index
|                                       ad_ddl.drop_sequence
|                                       ad_ddl.drop_synonym
|                                       ad_ddl.drop_table
|                                       ad_ddl.drop_trigger
|                                       ad_ddl.drop_view
|                                       ad_ddl.truncate_table
|                  x_object_name    The name of the object you are affecting
|
+============================================================================*/
PROCEDURE Do_DDL_VB(
    x_statement IN VARCHAR2,
        x_statement_type IN INTEGER := 0,
        x_object_name IN VARCHAR2 := NULL
    );


/*===========================================================================+
|
|   Name:          Execute_DDL
|
|   Description:   Execute the given DDL statement in current squema.
|
|   Parameters:    x_statement      DDL statement.
|
+============================================================================*/
PROCEDURE Execute_DDL(
    x_statement IN VARCHAR2
    );


/*===========================================================================+
|
|   Name:          Execute_DDL_Stmts_AT
|
|   Description:   Execute the given DDL statements. It uses DO_DDL_AT
|                  (autonomous transaction)
|
+============================================================================*/
PROCEDURE Execute_DDL_Stmts_AT(
    x_array_ddl_stmts IN t_array_ddl_stmts,
    x_num_ddl_stmts IN NUMBER,
    x_fnd_apps_schema IN VARCHAR2,
    x_bsc_apps_short_name IN VARCHAR2
    );


/*===========================================================================+
|
|   Name:          Execute_Immediate
|
|   Description:   Execute the given sql statmentent
|
|   Parameters:    x_sql - sql statement
|
|   Notes:
|
+============================================================================*/
PROCEDURE Execute_Immediate(
    x_sql IN VARCHAR2
    );


/*===========================================================================+
|
|   Name:          Get_Lookup_Value
|
|   Description:   This function returns the LOOKUP value of the given
|                  LOOKUP type and LOOKUP code
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Lookup_Value(
    x_lookup_type IN VARCHAR2,
        x_lookup_code IN VARCHAR2
    ) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_Lookup_Value
|
|   Description:   This procedure returns the LOOKUP value of the given
|                  LOOKUP type and LOOKUP code in x_meaning out NOCOPY parameter
|
|   Notes:
|
+============================================================================*/
PROCEDURE Get_Lookup_Value(
    x_lookup_type  in   varchar2,
    x_lookup_code  in   varchar2,
    x_meaning      out NOCOPY  varchar2 );


/*===========================================================================+
|
|   Name:          Get_Message
|
|   Description:   This function returns the translated message
|                  of the given message code
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Message(
    x_message_name IN VARCHAR2
    ) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_New_Big_In_Cond_Number
|
|   Description:   Clean values for the given variable_id and return a 'IN'
|                  condition string.
|
|   Parameters:    x_variable_id  variable id.
|                  x_column_name  column name (left part of the condition)
|
+============================================================================*/
FUNCTION Get_New_Big_In_Cond_Number(
    x_variable_id IN NUMBER,
    x_column_name IN VARCHAR2
    ) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_New_Big_In_Cond_Varchar2
|
|   Description:   Clean values for the given variable_id and return a 'IN'
|                  condition string.
|
|   Parameters:    x_variable_id  variable id.
|                  x_column_name  column name (left part of the condition)
|
+============================================================================*/
FUNCTION Get_New_Big_In_Cond_Varchar2(
    x_variable_id IN NUMBER,
    x_column_name IN VARCHAR2
    ) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_New_Big_In_Cond_Varchar2NU
|
|   Description:   Clean values for the given variable_id and return a 'IN'
|                  condition string.
|
|   Parameters:    x_variable_id  variable id.
|                  x_column_name  column name (left part of the condition)
|
+============================================================================*/
FUNCTION Get_New_Big_In_Cond_Varchar2NU(
    x_variable_id IN NUMBER,
    x_column_name IN VARCHAR2
    ) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_Property_Value
|
|   Description:   Given a list of pairs <property_name>=<property_value>
|                  separated by '&', this function returns the property_value
|                  of the given property_name. If the property does not exists
|                  in the list, it returns NULL.
+============================================================================*/
FUNCTION Get_Property_Value(
    p_property_list IN VARCHAR2,
    p_property_name IN VARCHAR2
    ) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Get_Property_Value, WNDS);


/*===========================================================================+
|
|   Name:          Set_Property_Value
|
|   Description:   Given a list of pairs <property_name>=<property_value>
|                  separated by '&', this function add/replace the list
|                  with the given <property_name>=<property_value>
+============================================================================*/
FUNCTION Set_Property_Value(
    p_property_list IN VARCHAR2,
    p_property_name IN VARCHAR2,
    p_property_value IN VARCHAR2
    ) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Set_Property_Value, WNDS);


/*===========================================================================+
|
|   Name:          Get_Request_Status_VB
|
|   Description:   This function returns in BSC_MESSAGE_LOGS the status
|                  of the concurrent request to be read by VB Loader
+============================================================================*/
PROCEDURE Get_Request_Status_VB(
    x_request_id IN NUMBER
    );


/*===========================================================================+
|
|   Name:          Get_Storage_Clause
|
|   Description:   This function returns the storage clause that needs
|                  to be used when creating tables or indexes.
+============================================================================*/
FUNCTION Get_Storage_Clause RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Get_Storage_Clause, WNDS);


/*===========================================================================+
|
|   Name:          Get_Tablespace_Clause_Tbl
|
|   Description:   This function returns the tablespace clause that needs
|                  to be used when creating tables.
+============================================================================*/
FUNCTION Get_Tablespace_Clause_Tbl RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Get_Tablespace_Clause_Tbl, WNDS);


/*===========================================================================+
|
|   Name:          Get_Tablespace_Clause_Idx
|
|   Description:   This function returns the tablespace clause that needs
|                  to be used when creating indexes.
+============================================================================*/
FUNCTION Get_Tablespace_Clause_Idx RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Get_Tablespace_Clause_Idx, WNDS);


/*===========================================================================+
|
|   Name:          Get_Tablespace_Name
|
|   Description:   This function returns the tablespace name according to the
|                  new tablespace clasiffication
|
|   Parameter:
|              x_tablespace_type IN VARCHAR2
|                   Pass one the following values:
|                   - BSC_APPS.dimension_table_tbs_type
|                   - BSC_APPS.dimension_index_tbs_type
|                   - BSC_APPS.input_table_tbs_type
|                   - BSC_APPS.input_index_tbs_type
|                   - BSC_APPS.base_table_tbs_type
|                   - BSC_APPS.base_index_tbs_type
|                   - BSC_APPS.summary_table_tbs_type
|                   - BSC_APPS.summary_index_tbs_type
+============================================================================*/
FUNCTION Get_Tablespace_Name (
    x_tablespace_type IN VARCHAR2
) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Init_Big_In_Cond_Table
|
|   Description:   This function creates temporal table BSC_TMP_BIG_IN_COND
|                  if it does not exist in the database and delete any record
|                  for the current session.
+============================================================================*/
PROCEDURE Init_Big_In_Cond_Table;


/*===========================================================================+
|
|   Name:          Init_Bsc_Apps
|
|   Description:   Initialize global variables:
|                  apps_env     TRUE    The environment is APPS
|               FALSE   The environment is Personal
|          bsc_apps_schema  Name of BSC schema in APPS
|
|
|   Notes: You must call this procedure before call aby other BSC_APPS package
|          procedure.
|
+============================================================================*/
PROCEDURE Init_Bsc_Apps;


/*===========================================================================+
|
|   Name:          Init_Log_File
|
|   Description:   This function creates the log file. Additionally,
|              write the standard header to the log file.
|
|              The log file directory must be in the variable
|          UTL_FILE_DIR of INIT table.
|
|          Initialize package variables:
|          g_log_file_name  - Log file name
|          g_log_file_dir   - Lof file directory.
|
|   Returns:       If any error ocurrs, this function write the error message
|          in the parameter x_msg_error and return FALSE. Otherwise return
|          TRUE.
|
|   Notes:
|
+============================================================================*/
FUNCTION Init_Log_File (
    x_log_file_name IN VARCHAR2,
        x_error_msg OUT NOCOPY VARCHAR2
        ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Log_File_Dir
|
|   Description:   This function returns the log file directory
|
|   Notes:
|
+============================================================================*/
FUNCTION Log_File_Dir RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Log_File_Name
|
|   Description:   This function returns the log file name
|
|   Notes:
|
+============================================================================*/
FUNCTION Log_File_Name RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Object_Exists
|
|   Description:   Checks whether the specific object exists in the
|          database.
|
|   Parameters:    x_object - object name.
|
|   Returns:       TRUE - Object exists in the database.
|          FALSE - Object does not exist in the database.
|
|   Notes:
|
+============================================================================*/
FUNCTION Object_Exists(
    x_object IN VARCHAR2
    ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Replace_Token
|
|   Description:   This function returns the message replacin the given token.
|
|   Notes:
|
+============================================================================*/
FUNCTION Replace_Token(
    x_message IN VARCHAR2,
    x_token_name IN VARCHAR2,
    x_token_value IN VARCHAR2
    ) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Submit_Request_VB
|
|   Description:   This procedure submits a request for concurrent program.
|                  This procedure is to be called from a VB program.
|                  It inserts the request_id in BSC_MESSAGE_LOGS table
|                  (type = 3, information) to VB program be able to get it.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:    x_program      Name of the concurrent program for which
|                                 the request should be submitted.
|                  x_start_time   Time at which the request should start
|                                 running.
|                  x_argument1
|                  ...
|                  x_argument20
|
+============================================================================*/
PROCEDURE Submit_Request_VB(
    x_program IN VARCHAR2,
    x_start_time IN VARCHAR2 DEFAULT NULL,
    x_argument1 IN VARCHAR2 DEFAULT NULL,
    x_argument2 IN VARCHAR2 DEFAULT NULL,
    x_argument3 IN VARCHAR2 DEFAULT NULL,
    x_argument4 IN VARCHAR2 DEFAULT NULL,
    x_argument5 IN VARCHAR2 DEFAULT NULL,
    x_argument6 IN VARCHAR2 DEFAULT NULL,
    x_argument7 IN VARCHAR2 DEFAULT NULL,
    x_argument8 IN VARCHAR2 DEFAULT NULL,
    x_argument9 IN VARCHAR2 DEFAULT NULL,
    x_argument10 IN VARCHAR2 DEFAULT NULL,
    x_argument11 IN VARCHAR2 DEFAULT NULL,
    x_argument12 IN VARCHAR2 DEFAULT NULL,
    x_argument13 IN VARCHAR2 DEFAULT NULL,
    x_argument14 IN VARCHAR2 DEFAULT NULL,
    x_argument15 IN VARCHAR2 DEFAULT NULL,
    x_argument16 IN VARCHAR2 DEFAULT NULL,
    x_argument17 IN VARCHAR2 DEFAULT NULL,
    x_argument18 IN VARCHAR2 DEFAULT NULL,
    x_argument19 IN VARCHAR2 DEFAULT NULL,
    x_argument20 IN VARCHAR2 DEFAULT NULL
    );


/*===========================================================================+
|
|   Name:          Index_Exists
|
|   Description:   Checks whether the specific index exists in the
|          database.
|
|   Parameters:    x_index - index name.
|
|   Returns:       TRUE - Index exists in the database.
|          FALSE - Index does not exist in the database.
|
|   Notes:
|
+============================================================================*/
FUNCTION Index_Exists(
    x_index IN VARCHAR2
    ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Table_Exists
|
|   Description:   Checks whether the specific table exists in the
|          database.
|
|   Parameters:    x_table - table name.
|
|   Returns:       TRUE - Table exists in the database.
|          FALSE - Table does not exist in the database.
|
|   Notes:
|
+============================================================================*/
FUNCTION Table_Exists(
    x_table IN VARCHAR2
    ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          View_Exists
|
|   Description:   Checks whether the specific view exists in the
|          database.
|
|   Parameters:    x_view - view name.
|
|   Returns:       TRUE - View exists in the database.
|          FALSE - View does not exist in the database.
|
|   Notes:
|
+============================================================================*/
FUNCTION View_Exists(
    x_view  IN VARCHAR2
    ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Wait_For_Request_VB
|
|   Description:   This procedure waits for request completion.
|                  This procedure is to be called from a VB program.
|                  If there is an error, the procedure inserts the error
|                  message in BSC_MESSAGE_LOGS table.
|
|   Parameters:    x_request_id   The request ID of the request to wait on.
|
+============================================================================*/
PROCEDURE Wait_For_Request_VB(
    x_request_id IN NUMBER,
        x_interval IN NUMBER,
        x_max_wait IN NUMBER
    );


/*===========================================================================+
|
|   Name:          Write_Errors_To_Log
|
|   Description:   This procedure writes the messages that are in
|                  BSC_MESSAGE_LOGS table corresponding to the current session
|          id, into the log file.
|
|          If the log file is not initialized then this procedure
|          doesn't do anything. This is not an error.
|
|   Notes:
|
+============================================================================*/
PROCEDURE Write_Errors_To_Log;


/*===========================================================================+
|
|   Name:          Write_Line_Log
|
|   Description:   This procedure write the given string into the log file
|
|          If the log file is not initialized then this procedure
|          doesn't do anything. This is not an error.
|
|   Notes:
|
+============================================================================*/
PROCEDURE Write_Line_Log (
    x_line IN VARCHAR2,
        x_which IN NUMBER
    );
/*===========================================================================+
|   Name:          IS_BSC_USER_VALID
|
|   Description:   This fucntion return 1, if the user_id is a Valid BSc user.
|                  It means that has BSC responsibility and the resp. is between
|                   start and end date
|   Notes:
+============================================================================*/
FUNCTION IS_BSC_USER_VALID(
  X_USER_ID in NUMBER) RETURN NUMBER;

/*===========================================================================+
|   Name:          Is_Bsc_Design_User_Valid
|
|   Description:   This function return 1, if the user_id is a Valid BSC design user.
|                  It means that user has BSC Manager and Performnace Management Designer
|                  and the resp. is between start and end date
|   Notes:
|
+============================================================================*/
FUNCTION Is_Bsc_Design_User_Valid (
  x_User_Id IN NUMBER) RETURN NUMBER;

/*===========================================================================+
|   Name:          GET_USER_FULL_NAME
|
|   Description:   This fucntion return teh full name of the user from
|                  per_all_people_f table
|   Notes:
+============================================================================*/
FUNCTION GET_USER_FULL_NAME(
  X_USER_ID in NUMBER) RETURN VARCHAR2;

/*===========================================================================+
|   Name:          get_user_schema
|
|   Description:   The fuction return the BSC schema name
|
|   Notes:
+============================================================================*/
FUNCTION get_user_schema
RETURN VARCHAR2;

/*===========================================================================+
|   Name:          get_user_schema ( over loaded)
|
|   Description:   The function return the schema name for the application
|                  short name passed
|   Notes:
+============================================================================*/

FUNCTION get_user_schema (p_app_short_name IN  varchar2)
RETURN VARCHAR2;

/*===========================================================================+
| PROCEDURE Do_DDL_AT, use to execute multiple statments under single
|                      Autonomous Transaction.
+============================================================================*/


PROCEDURE Do_DDL_AT(
    x_Statements_Tbl   IN   BSC_APPS.Autonomous_Statements_Tbl_Type
);

/*===========================================================================+
| FUNCTION Get_Bsc_Message
+============================================================================*/
FUNCTION Get_Bsc_Message
(   p_Message_Name IN VARCHAR2,
    p_Token_Names  IN VARCHAR2,
    p_Lookup_Codes IN VARCHAR2,
    p_Lookup_Types IN VARCHAR2
) RETURN VARCHAR2;

END BSC_APPS;

 

/
