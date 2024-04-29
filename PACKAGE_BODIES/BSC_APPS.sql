--------------------------------------------------------
--  DDL for Package Body BSC_APPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_APPS" AS
/* $Header: BSCAPPSB.pls 120.4 2006/04/18 16:40:35 arsantha noship $ */
/*===========================================================================+
|               Copyright (c) 1999 Oracle Corporation                        |
|                  Redwood Shores, California, USA                           |
|                       All rights reserved                                  |
|============================================================================|
|
|   Name:          BSCAPPSB.pls
|
|   Description:   This package contains procedures to perform APPS
|                  related calls.
|
|   Example:
|
|   Security:
|
|   History:       Created By: Mauricio Eastmond            Date: 04-JAN-00
|
|   Srini Jandyala 27-Feb-02   Added Get_Lookup_Value() procedure for HTML UI
|          27-03-2003  Adeulgao fixed bug#2865694
|                              used alias for view "v$parameter"              |
|          20-Aug-03   Adeulgao fixed bug#3008243 added 2 functions           |
|                      (overloaded) get_user_schema to get the schema name    |
|          22-Aug-03   Adeulgao modified the query to fetch oracle schema name|
|          27-Aug-03   Aditya Removed Hardcoded literals.                     |
|          15-Sep-03   wleung modified index query in Init_Big_In_Cond_Table. |
|          15-DEC-2003 Aditya Rao removed Dynamic SQLs for Bug #3236356       |
|                                                                             |
|          19-APR-2004 PAJOHRI  Bug #3541933, added a overloaded function     |
|                               Do_DDL_AT                                     |
|          18-jul-2005 ashankar Bug#4214158 changed the value of the constant |
|                               c_version to 5.3.0                            |
|          19-AUG-2005 KYADAMAK BUG#4559027 implemented caching for schema names|
|          18-APR-2006 ARSANTHA BUG 5162628 wrt tablespace for old mode       |
+============================================================================*/

--
-- Package constants
--
-- Formats
c_fto_long_date_time CONSTANT VARCHAR2(30) := 'Month DD, YYYY HH24:MI:SS';
c_version CONSTANT VARCHAR2(5) := '5.3.0';

--
-- Package variables
--
g_log_file_dir VARCHAR2(60) := NULL;
g_log_file_name VARCHAR2(2000) := NULL;

-- bsc and apps user schema names
g_bsc_user_schema  CONSTANT VARCHAR2(100) := 'BSC';
g_apps_user_schema CONSTANT VARCHAR2(100) := 'APPS';

--This is for cachin User schema names
TYPE user_schema_table IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(30);
user_schema_tbl  user_schema_table;



/*===========================================================================+
| PROCEDURE Add_Value_Big_In_Cond (Number)
+============================================================================*/

PROCEDURE Add_Value_Big_In_Cond(
    x_variable_id IN NUMBER,
    x_value IN NUMBER
    ) IS

    h_sql VARCHAR2(32700);

BEGIN

    h_sql := 'INSERT INTO BSC_TMP_BIG_IN_COND (SESSION_ID, VARIABLE_ID, VALUE_N, VALUE_V)'||
             ' VALUES (USERENV(''SESSIONID''), :1, :2, NULL)';
    EXECUTE IMMEDIATE h_sql USING x_variable_id, x_value;

END Add_Value_Big_In_Cond;
/*===========================================================================+
| FUNCTION to parse Lookup Types, Codes, Names
+============================================================================*/
--==============================================================
FUNCTION Is_More
(       x_Lookup_Types    IN  OUT     NOCOPY  VARCHAR2
    ,   x_Lookup_Codes    IN  OUT     NOCOPY  VARCHAR2
    ,   x_Token_Names     IN  OUT     NOCOPY  VARCHAR2
    ,   x_Lookup_Type         OUT     NOCOPY  VARCHAR2
    ,   x_Lookup_Code         OUT     NOCOPY  VARCHAR2
    ,   x_Token_Name          OUT     NOCOPY  VARCHAR2
) RETURN BOOLEAN IS
    l_Lookup_Ids         NUMBER;
    l_Lookup_Codes       NUMBER;
    l_Lookup_Names       NUMBER;
BEGIN
    IF (x_Lookup_Types IS NOT NULL) THEN
        l_Lookup_Ids     := INSTR(x_Lookup_Types,  ',');
        l_Lookup_Codes   := INSTR(x_Lookup_Codes,  ',');
        l_Lookup_Names   := INSTR(x_Token_Names,   ',');

        IF (l_Lookup_Ids > 0) THEN
            x_Lookup_Type      :=  TRIM(SUBSTR(x_Lookup_Types,   1,  l_Lookup_Ids   - 1));
            x_Lookup_Code      :=  TRIM(SUBSTR(x_Lookup_Codes,   1,  l_Lookup_Codes - 1));
            x_Token_Name       :=  TRIM(SUBSTR(x_Token_Names,    1,  l_Lookup_Names - 1));

            IF (UPPER(x_Token_Name) = 'NULL') THEN
                x_Token_Name   := NULL;
            END IF;

            x_Lookup_Types     :=  TRIM(SUBSTR(x_Lookup_Types,   l_Lookup_Ids   + 1));
            x_Lookup_Codes     :=  TRIM(SUBSTR(x_Lookup_Codes,   l_Lookup_Codes + 1));
            x_Token_Names      :=  TRIM(SUBSTR(x_Token_Names,    l_Lookup_Names + 1));
        ELSE
            x_Lookup_Type      :=  TRIM(x_Lookup_Types);
            x_Lookup_Code      :=  TRIM(x_Lookup_Codes);
            x_Token_Name       :=  TRIM(x_Token_Names);

            IF (UPPER(x_Token_Name) = 'NULL') THEN
                x_Token_Name   := NULL;
            END IF;

            x_Lookup_Types     :=  NULL;
            x_Token_Names      :=  NULL;
            x_Lookup_Codes     :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;
/*===========================================================================+
| PROCEDURE Add_Value_Big_In_Cond (Varchar2)
+============================================================================*/
PROCEDURE Add_Value_Big_In_Cond(
    x_variable_id IN NUMBER,
    x_value IN VARCHAR2
    ) IS

    h_sql VARCHAR2(32700);

BEGIN

    h_sql := 'INSERT INTO BSC_TMP_BIG_IN_COND (SESSION_ID, VARIABLE_ID, VALUE_N, VALUE_V)'||
             ' VALUES (USERENV(''SESSIONID''), :1, NULL, :2)';
    EXECUTE IMMEDIATE h_sql USING x_variable_id, x_value;

END Add_Value_Big_In_Cond;


/*===========================================================================+
| PROCEDURE Apps_Initilize_VB
+============================================================================*/
PROCEDURE Apps_Initialize_VB(
    x_user_id IN NUMBER,
    x_resp_id IN NUMBER
    ) IS

    h_appl_id NUMBER;

BEGIN

    SELECT application_id INTO h_appl_id
    FROM fnd_responsibility
    WHERE responsibility_id = x_resp_id;

    FND_GLOBAL.Apps_Initialize(user_id => x_user_id,
                               resp_id => x_resp_id,
                               resp_appl_id => h_appl_id);
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_APPS.Apps_Initialize_VB',
                        x_mode => 'I');
        COMMIT;

END Apps_Initialize_VB;


/*===========================================================================+
| FUNCTION CheckError
+============================================================================*/
FUNCTION CheckError(
    x_calling_function IN VARCHAR2
) RETURN BOOLEAN IS

    h_count NUMBER;

BEGIN

    SELECT count(*)
    INTO h_count
    FROM bsc_message_logs
    WHERE type = 0
    AND UPPER(source) = UPPER(x_calling_function)
    AND last_update_login = USERENV('SESSIONID');

    IF h_count > 0 THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;

END CheckError;


/*===========================================================================+
| PROCEDURE Do_DDL
+============================================================================*/
PROCEDURE Do_DDL(
    x_statement IN VARCHAR2,
        x_statement_type IN INTEGER := 0,
        x_object_name IN VARCHAR2 := NULL
    ) IS

BEGIN

    IF apps_env THEN
    AD_DDL.Do_DDL(fnd_apps_schema,
                      bsc_apps_short_name,
                      x_statement_type,
                      x_statement,
                      x_object_name);
    ELSE
        Execute_DDL(x_statement);
    END IF;

END Do_DDL;


/*===========================================================================+
| PROCEDURE Do_DDL_AT
+============================================================================*/
PROCEDURE Do_DDL_AT(
    x_statement IN VARCHAR2,
    x_statement_type IN INTEGER := 0,
    x_object_name IN VARCHAR2 := NULL,
    x_fnd_apps_schema IN VARCHAR2,
    x_bsc_apps_short_name IN VARCHAR2
    ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    AD_DDL.Do_DDL(x_fnd_apps_schema,
                  x_bsc_apps_short_name,
                  x_statement_type,
                  x_statement,
                  x_object_name);

END Do_DDL_AT;


/*===========================================================================+
| PROCEDURE Do_DDL_VB
+============================================================================*/
PROCEDURE Do_DDL_VB(
    x_statement IN VARCHAR2,
        x_statement_type IN INTEGER := 0,
        x_object_name IN VARCHAR2 := NULL
    ) IS

BEGIN
    Do_DDL(x_statement, x_statement_type, x_object_name);

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_APPS.Do_DDL_VB',
                        x_mode => 'I');
        COMMIT;

END Do_DDL_VB;


/*===========================================================================+
| FUNCTION Get_Lookup_Value
+============================================================================*/
FUNCTION Get_Lookup_Value(
    x_lookup_type IN VARCHAR2,
        x_lookup_code IN VARCHAR2
    ) RETURN VARCHAR2 IS

    CURSOR c_lookup_value IS
        SELECT
            meaning
        FROM
            bsc_lookups
        WHERE
            lookup_type = x_lookup_type AND
            lookup_code = x_lookup_code;

    h_lookup_value VARCHAR2(4000);

BEGIN
    OPEN c_lookup_value;
    FETCH c_lookup_value INTO h_lookup_value;
    IF c_lookup_value%NOTFOUND THEN
        h_lookup_value := NULL;
    END IF;
    CLOSE c_lookup_value;

    RETURN h_lookup_value;

END Get_Lookup_Value;

/*===========================================================================+
| PROCEDURE Get_Lookup_Value
+============================================================================*/
PROCEDURE Get_Lookup_Value(
    x_lookup_type  in  varchar2,
    x_lookup_code  in  varchar2,
    x_meaning      out NOCOPY varchar2

) IS

BEGIN

    x_meaning := Get_Lookup_Value(x_lookup_type, x_lookup_code);

END Get_Lookup_Value;


/*===========================================================================+
| FUNCTION Get_Message
+============================================================================*/
FUNCTION Get_Message(
    x_message_name IN VARCHAR2
    ) RETURN VARCHAR2 IS

    CURSOR c_message IS
        SELECT
            message_text
        FROM
            bsc_messages
        WHERE
            message_name = x_message_name;

    h_message VARCHAR2(4000);

BEGIN
    OPEN c_message;
    FETCH c_message INTO h_message;
    IF c_message%NOTFOUND THEN
        h_message := NULL;
    END IF;
    CLOSE c_message;

    RETURN h_message;

END Get_Message;


/*===========================================================================+
| FUNCTION Get_New_Big_In_Cond_Number
+============================================================================*/
FUNCTION Get_New_Big_In_Cond_Number(
    x_variable_id IN NUMBER,
    x_column_name IN VARCHAR2
    ) RETURN VARCHAR2 IS

    h_sql VARCHAR2(32700);
    h_cond VARCHAR2(2000);

BEGIN

    h_sql := 'DELETE FROM BSC_TMP_BIG_IN_COND'||
             ' WHERE SESSION_ID = USERENV(''SESSIONID'')'||
             ' AND VARIABLE_ID = :1';
    EXECUTE IMMEDIATE h_sql USING x_variable_id;

    h_cond := x_column_name||' IN ('||
              'SELECT VALUE_N FROM BSC_TMP_BIG_IN_COND'||
              ' WHERE SESSION_ID = USERENV(''SESSIONID'')'||
              ' AND VARIABLE_ID = '||x_variable_id||
              ')';

    return h_cond;

END Get_New_Big_In_Cond_Number;


/*===========================================================================+
| FUNCTION Get_New_Big_In_Cond_Varchar2
+============================================================================*/
FUNCTION Get_New_Big_In_Cond_Varchar2(
    x_variable_id IN NUMBER,
    x_column_name IN VARCHAR2
    ) RETURN VARCHAR2 IS

    h_sql VARCHAR2(32700);
    h_cond VARCHAR2(2000);

BEGIN

    h_sql := 'DELETE FROM BSC_TMP_BIG_IN_COND'||
             ' WHERE SESSION_ID = USERENV(''SESSIONID'')'||
             ' AND VARIABLE_ID = :1';
    /*Execute_Immediate(h_sql);*/
    EXECUTE IMMEDIATE h_sql USING x_variable_id;

    h_cond := 'UPPER('||x_column_name||') IN ('||
              'SELECT UPPER(VALUE_V) FROM BSC_TMP_BIG_IN_COND'||
              ' WHERE SESSION_ID = USERENV(''SESSIONID'')'||
              ' AND VARIABLE_ID = '||x_variable_id||
              ')';

    return h_cond;

END Get_New_Big_In_Cond_Varchar2;


-- Add this new function. It does not use UPPER
/*===========================================================================+
| FUNCTION Get_New_Big_In_Cond_Varchar2NU
+============================================================================*/
FUNCTION Get_New_Big_In_Cond_Varchar2NU(
    x_variable_id IN NUMBER,
    x_column_name IN VARCHAR2
    ) RETURN VARCHAR2 IS

    h_sql VARCHAR2(32700);
    h_cond VARCHAR2(2000);

BEGIN

    h_sql := 'DELETE FROM BSC_TMP_BIG_IN_COND'||
             ' WHERE SESSION_ID = USERENV(''SESSIONID'')'||
             ' AND VARIABLE_ID = :1';
    /*Execute_Immediate(h_sql);*/
    EXECUTE IMMEDIATE h_sql USING x_variable_id;

    h_cond := x_column_name||' IN ('||
              'SELECT VALUE_V FROM BSC_TMP_BIG_IN_COND'||
              ' WHERE SESSION_ID = USERENV(''SESSIONID'')'||
              ' AND VARIABLE_ID = '||x_variable_id||
              ')';

    return h_cond;

END Get_New_Big_In_Cond_Varchar2NU;


/*===========================================================================+
| FUNCTION Get_Property_Value
+============================================================================*/
FUNCTION Get_Property_Value(
    p_property_list IN VARCHAR2,
    p_property_name IN VARCHAR2
    ) RETURN VARCHAR2 IS

    l_property_value VARCHAR2(200) := NULL;
    l_property_name VARCHAR2(200);
    l_property_list VARCHAR2(32000);
    l_i NUMBER;
    l_j NUMBER;

BEGIN

    IF p_property_list IS NOT NULL THEN
        l_property_list := '&'||p_property_list||'&';
        l_property_name := '&'||p_property_name||'=';
        l_i := INSTR(l_property_list, l_property_name);
    IF l_i > 0 THEN
            l_j := l_i + LENGTH(l_property_name);
            l_i := INSTR(l_property_list, '&', l_j);
            l_property_value := RTRIM(LTRIM(SUBSTR(l_property_list, l_j, l_i-l_j)));
        END IF;
    END IF;

    RETURN l_property_value;

END Get_Property_Value;


/*===========================================================================+
| FUNCTION Set_Property_Value
+============================================================================*/
FUNCTION Set_Property_Value(
    p_property_list IN VARCHAR2,
    p_property_name IN VARCHAR2,
    p_property_value IN VARCHAR2
    ) RETURN VARCHAR2 IS

    l_property_value VARCHAR2(200) := NULL;
    l_property_name VARCHAR2(200);
    l_property_list VARCHAR2(32000);
    l_new_property_list VARCHAR2(32000);
    l_i NUMBER;
    l_j NUMBER;

BEGIN

    IF p_property_list IS NULL THEN
    l_new_property_list := p_property_name||'='||p_property_value;
    ELSE
        l_property_list := '&'||p_property_list||'&';
        l_property_name := '&'||p_property_name||'=';
        l_i := INSTR(l_property_list, l_property_name);
    IF l_i > 0 THEN
            -- property already exists
            -- replace the value
            l_j := l_i + LENGTH(l_property_name);
            l_j := INSTR(l_property_list, '&', l_j);

            l_new_property_list := SUBSTR(l_property_list, 1, l_i)||
                                   p_property_name||'='||p_property_value||
                                   SUBSTR(l_property_list, l_j);
            l_new_property_list := LTRIM(RTRIM(l_new_property_list, '&'),'&');
        ELSE
            -- property does not exists
            -- add it
            l_new_property_list := p_property_list||'&'||p_property_name||'='||p_property_value;
        END IF;
    END IF;

    RETURN l_new_property_list;

END Set_Property_Value;


/*===========================================================================+
| PROCEDURE Get_Request_Status_VB
+============================================================================*/
PROCEDURE Get_Request_Status_VB(
    x_request_id IN NUMBER
    ) IS

    h_phase VARCHAR2(2000) := NULL;
    h_status VARCHAR2(2000) := NULL;
    h_dev_phase VARCHAR2(2000) := NULL;
    h_dev_status VARCHAR2(2000) := NULL;
    h_message VARCHAR2(2000) := NULL;
    h_request_id NUMBER;
    h_res BOOLEAN;

BEGIN
    h_request_id := x_request_id;

    IF FND_CONCURRENT.Get_Request_Status(h_request_id,
                             '', '',
                     h_phase,
                         h_status,
                     h_dev_phase,
                     h_dev_status,
                     h_message) THEN
        -- Insert the information in BSC_MESSAGE_LOGS table
        -- type 30 h_phase, type 31 h_status
        -- type 32 h_dev_phase, type 33 h_dev_status, type 34 h_message
        IF h_phase IS NOT NULL THEN
            BSC_MESSAGE.Add(x_message => h_phase,
                            x_source => 'BSC_APPS.Get_Request_Status_VB',
                            x_type => 30,
                            x_mode => 'I');
        END IF;

        IF h_status IS NOT NULL THEN
            BSC_MESSAGE.Add(x_message => h_status,
                            x_source => 'BSC_APPS.Get_Request_Status_VB',
                            x_type => 31,
                            x_mode => 'I');
        END IF;

        IF h_dev_phase IS NOT NULL THEN
            BSC_MESSAGE.Add(x_message => h_dev_phase,
                            x_source => 'BSC_APPS.Get_Request_Status_VB',
                            x_type => 32,
                            x_mode => 'I');
        END IF;

        IF h_dev_status IS NOT NULL THEN
            BSC_MESSAGE.Add(x_message => h_dev_status,
                            x_source => 'BSC_APPS.Get_Request_Status_VB',
                            x_type => 33,
                            x_mode => 'I');
        END IF;

        IF h_message IS NOT NULL THEN
            BSC_MESSAGE.Add(x_message => h_message,
                            x_source => 'BSC_APPS.Get_Request_Status_VB',
                            x_type => 34,
                            x_mode => 'I');
        END IF;

        COMMIT;

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_APPS.Get_Request_Status_VB',
                        x_mode => 'I');
        COMMIT;
END Get_Request_Status_VB;


/*===========================================================================+
| FUNCTION Get_Storage_Clause
+============================================================================*/
FUNCTION Get_Storage_Clause RETURN VARCHAR2 IS
BEGIN
    RETURN bsc_storage_clause;
END Get_Storage_Clause;


/*===========================================================================+
| FUNCTION Get_Tablespace_Clause_Tbl
+============================================================================*/
FUNCTION Get_Tablespace_Clause_Tbl RETURN VARCHAR2 IS
BEGIN
    RETURN bsc_tablespace_clause_tbl;
END Get_Tablespace_Clause_Tbl;


/*===========================================================================+
| FUNCTION Get_Tablespace_Clause_Idx
+============================================================================*/
FUNCTION Get_Tablespace_Clause_Idx RETURN VARCHAR2 IS
BEGIN
    RETURN bsc_tablespace_clause_idx;
END Get_Tablespace_Clause_Idx;


/*===========================================================================+
| FUNCTION Get_Tablespace_Name
+============================================================================*/
FUNCTION Get_Tablespace_Name (
    x_tablespace_type IN VARCHAR2
) RETURN VARCHAR2 IS
    h_ts_exists VARCHAR2(10) := NULL;
    h_tbs_name  VARCHAR2(80) := NULL;

    l_new_tbs_mode VARCHAR2(10) := NULL;
    l_tablespace_type VARCHAR2(100);
BEGIN
    -- This is the classification:
    -- Dimension Tables              TRANSACTION_TABLES
    -- Dimension Tables Indexes      TRANSACTION_INDEXES
    -- Input Tables                  INTERFACE
    -- Input Tables Indexes          INTERFACE
    -- Base Tables                   SUMMARY
    -- Base Tables Indexes           SUMMARY
    -- Summary Tables                SUMMARY
    -- Summary Tables Indexes        SUMMARY
    -- Other Tables                  TRANSACTION_TABLES
    -- Other Indexes                 TRANSACTION_INDEXES


    -- P1 5162628 - check tablespace mode
    -- If its old mode,
    -- Summary Tables must be created in the BSCD schema
    -- Got an OK from Pavel that its ok to create MVs in BSCD schema for old
    l_tablespace_type := x_tablespace_type;

    AD_TSPACE_UTIL.is_new_ts_mode(l_new_tbs_mode);
    IF (l_new_tbs_mode = 'Y') THEN -- NEW MODE, no changes
      null;
    ELSE -- OLD MODE
      --See if we need to switch summary tables to Transaction table space
      IF (l_tablespace_type =  base_table_tbs_type    OR
          l_tablespace_type =  base_index_tbs_type    OR
          l_tablespace_type =  summary_table_tbs_type OR
          l_tablespace_type =  summary_index_tbs_type   )
      THEN
        -- Switch summary tables to transaction tables
        l_tablespace_type := other_table_tbs_type;
      END IF;
    END IF;
    IF l_tablespace_type = dimension_table_tbs_type THEN
        IF dimension_table_tbs_name IS NULL THEN
            AD_TSPACE_UTIL.get_tablespace_name(
                x_product_short_name => bsc_apps_short_name,
                x_tablespace_type => 'TRANSACTION_TABLES',
                x_validate_ts_exists => 'N',
                x_ts_exists => h_ts_exists,
                x_tablespace => dimension_table_tbs_name);
        END IF;
        RETURN dimension_table_tbs_name;

    ELSIF l_tablespace_type = dimension_index_tbs_type THEN
        IF dimension_index_tbs_name IS NULL THEN
            AD_TSPACE_UTIL.get_tablespace_name(
                x_product_short_name => bsc_apps_short_name,
                x_tablespace_type => 'TRANSACTION_INDEXES',
                x_validate_ts_exists => 'N',
                x_ts_exists => h_ts_exists,
                x_tablespace => dimension_index_tbs_name);
        END IF;
        RETURN dimension_index_tbs_name;

    ELSIF l_tablespace_type = input_table_tbs_type THEN
        IF input_table_tbs_name IS NULL THEN
            AD_TSPACE_UTIL.get_tablespace_name(
                x_product_short_name => bsc_apps_short_name,
                x_tablespace_type => 'INTERFACE',
                x_validate_ts_exists => 'N',
                x_ts_exists => h_ts_exists,
                x_tablespace => input_table_tbs_name);
        END IF;
        RETURN input_table_tbs_name;

    ELSIF l_tablespace_type = input_index_tbs_type THEN
        IF input_index_tbs_name IS NULL THEN
            AD_TSPACE_UTIL.get_tablespace_name(
                x_product_short_name => bsc_apps_short_name,
                x_tablespace_type => 'INTERFACE',
                x_validate_ts_exists => 'N',
                x_ts_exists => h_ts_exists,
                x_tablespace => input_index_tbs_name);
        END IF;
        RETURN input_index_tbs_name;

    ELSIF l_tablespace_type = base_table_tbs_type THEN
        IF base_table_tbs_name IS NULL THEN
            AD_TSPACE_UTIL.get_tablespace_name(
                x_product_short_name => bsc_apps_short_name,
                x_tablespace_type => 'SUMMARY',
                x_validate_ts_exists => 'N',
                x_ts_exists => h_ts_exists,
                x_tablespace => base_table_tbs_name);
        END IF;
        RETURN base_table_tbs_name;

    ELSIF l_tablespace_type = base_index_tbs_type THEN
        IF base_index_tbs_name IS NULL THEN
            AD_TSPACE_UTIL.get_tablespace_name(
                x_product_short_name => bsc_apps_short_name,
                x_tablespace_type => 'SUMMARY',
                x_validate_ts_exists => 'N',
                x_ts_exists => h_ts_exists,
                x_tablespace => base_index_tbs_name);
        END IF;
        RETURN base_index_tbs_name;

    ELSIF l_tablespace_type = summary_table_tbs_type THEN
        IF summary_table_tbs_name IS NULL THEN
            AD_TSPACE_UTIL.get_tablespace_name(
                x_product_short_name => bsc_apps_short_name,
                x_tablespace_type => 'SUMMARY',
                x_validate_ts_exists => 'N',
                x_ts_exists => h_ts_exists,
                x_tablespace => summary_table_tbs_name);
        END IF;
        RETURN summary_table_tbs_name;

    ELSIF l_tablespace_type = summary_index_tbs_type THEN
        IF summary_index_tbs_name IS NULL THEN
            AD_TSPACE_UTIL.get_tablespace_name(
                x_product_short_name => bsc_apps_short_name,
                x_tablespace_type => 'SUMMARY',
                x_validate_ts_exists => 'N',
                x_ts_exists => h_ts_exists,
                x_tablespace => summary_index_tbs_name);
        END IF;
        RETURN summary_index_tbs_name;

    ELSIF l_tablespace_type = other_table_tbs_type THEN
        IF other_table_tbs_name IS NULL THEN
            AD_TSPACE_UTIL.get_tablespace_name(
                x_product_short_name => bsc_apps_short_name,
                x_tablespace_type => 'TRANSACTION_TABLES',
                x_validate_ts_exists => 'N',
                x_ts_exists => h_ts_exists,
                x_tablespace => other_table_tbs_name);
        END IF;
        RETURN other_table_tbs_name;

    ELSIF l_tablespace_type = other_index_tbs_type THEN
        IF other_index_tbs_name IS NULL THEN
            AD_TSPACE_UTIL.get_tablespace_name(
                x_product_short_name => bsc_apps_short_name,
                x_tablespace_type => 'TRANSACTION_INDEXES',
                x_validate_ts_exists => 'N',
                x_ts_exists => h_ts_exists,
                x_tablespace => other_index_tbs_name);
        END IF;
        RETURN other_index_tbs_name;

    ELSE
        -- use TRANSACTION_TABLES
        AD_TSPACE_UTIL.get_tablespace_name(
            x_product_short_name => bsc_apps_short_name,
            x_tablespace_type => 'TRANSACTION_TABLES',
            x_validate_ts_exists => 'N',
            x_ts_exists => h_ts_exists,
            x_tablespace => h_tbs_name);
        RETURN h_tbs_name;
    END IF;

END Get_Tablespace_Name;


/*===========================================================================+
| PROCEDURE Execute_DDL
+============================================================================*/
PROCEDURE Execute_DDL(
    x_statement IN VARCHAR2
    ) IS

    --h_cursor INTEGER;
    --h_ret INTEGER;

BEGIN
    --h_cursor := DBMS_SQL.OPEN_CURSOR;
    --DBMS_SQL.PARSE(h_cursor, x_statement, DBMS_SQL.NATIVE);
    --h_ret := DBMS_SQL.EXECUTE(h_cursor);
    --DBMS_SQL.CLOSE_CURSOR(h_cursor);

    EXECUTE IMMEDIATE x_statement;

END Execute_DDL;


/*===========================================================================+
| PROCEDURE Execute_DDL_Stmts_AT
+============================================================================*/
PROCEDURE Execute_DDL_Stmts_AT(
    x_array_ddl_stmts IN t_array_ddl_stmts,
    x_num_ddl_stmts IN NUMBER,
    x_fnd_apps_schema IN VARCHAR2,
    x_bsc_apps_short_name IN VARCHAR2
    ) IS

    h_i NUMBER;

BEGIN
    FOR h_i IN 1..x_num_ddl_stmts LOOP
        Do_DDL_AT(x_array_ddl_stmts(h_i).sql_stmt,
                  x_array_ddl_stmts(h_i).stmt_type,
                  x_array_ddl_stmts(h_i).object_name,
                  x_fnd_apps_schema,
                  x_bsc_apps_short_name);
    END LOOP;
END Execute_DDL_Stmts_AT;


/*===========================================================================+
| PROCEDURE Execute_Immediate
+============================================================================*/
PROCEDURE Execute_Immediate(
    x_sql IN VARCHAR2
    ) IS
    --h_cursor INTEGER;
    --h_ret INTEGER;

BEGIN
    --h_cursor := DBMS_SQL.OPEN_CURSOR;
    --DBMS_SQL.PARSE(h_cursor, x_sql, DBMS_SQL.NATIVE);
    --h_ret := DBMS_SQL.EXECUTE(h_cursor);
    --DBMS_SQL.CLOSE_CURSOR(h_cursor);

    EXECUTE IMMEDIATE x_sql;

END Execute_Immediate;



/*===========================================================================+
| PROCEDURE Init_Big_In_Cond_Table
+============================================================================*/
PROCEDURE Init_Big_In_Cond_Table IS

   h_sql VARCHAR2(32700) := NULL;

BEGIN
    IF NOT Table_Exists('BSC_TMP_BIG_IN_COND') THEN
        h_sql := 'CREATE TABLE BSC_TMP_BIG_IN_COND ('||
                 'SESSION_ID NUMBER, VARIABLE_ID NUMBER, VALUE_N NUMBER, VALUE_V VARCHAR2(2000)'||
                 ') TABLESPACE '||Get_Tablespace_Name(other_table_tbs_type)||' '||bsc_storage_clause;
        Do_DDL(h_sql, AD_DDL.CREATE_TABLE, 'BSC_TMP_BIG_IN_COND');
    END IF;

    IF NOT Index_Exists('BSC_TMP_BIG_IN_COND_N1') THEN
         h_sql := 'CREATE INDEX BSC_TMP_BIG_IN_COND_N1'||
                 ' ON BSC_TMP_BIG_IN_COND (SESSION_ID, VARIABLE_ID) '||
                 ' TABLESPACE '||Get_Tablespace_Name(other_index_tbs_type)||' '||bsc_storage_clause;
        Do_DDL(h_sql, AD_DDL.CREATE_INDEX, 'BSC_TMP_BIG_IN_COND_N1');
    END IF;

    h_sql := 'DELETE FROM BSC_TMP_BIG_IN_COND '||
             'WHERE SESSION_ID = USERENV(''SESSIONID'')';
    Execute_Immediate(h_sql);

END Init_Big_In_Cond_Table;


/*===========================================================================+
| PROCEDURE Init_Bsc_Apps
+============================================================================*/
PROCEDURE Init_Bsc_Apps IS

    CURSOR c_apps_table IS
        SELECT
            object_name
        FROM
            user_objects
        WHERE
            object_name = 'FND_USER';

    h_table VARCHAR2(30);
    h_status VARCHAR2(2000);
    h_industry VARCHAR2(2000);
    h_x BOOLEAN;

    h_nextext_propcode  VARCHAR2(30) := 'NEXT_EXTENT';
    h_next_extent VARCHAR2(90);

    TYPE cursorType IS REF CURSOR;
    cv cursorType;

    h_sql VARCHAR2(2000);
    h_tbs_tbl VARCHAR2(30);
    h_tbs_idx VARCHAR2(30);

    h_sum_level VARCHAR2(100);
    h_sum_level_prop_code VARCHAR2(20) := 'ADV_SUM_LEVEL';

BEGIN
    -- Init apps_env global variable
    OPEN c_apps_table;
    FETCH c_apps_table INTO h_table;
    IF c_apps_table%FOUND THEN
        apps_env := TRUE;
    ELSE
        apps_env := FALSE;
    END IF;
    CLOSE c_apps_table;

    --Init bsc_apps_short_name and bsc_apps_schema (Just for APPS environment)
    IF apps_env THEN
        bsc_appl_id := 271;
        bsc_apps_short_name := 'BSC';
        h_x := FND_INSTALLATION.Get_App_Info(bsc_apps_short_name, h_status, h_industry, bsc_apps_schema);

        fnd_apps_short_name := 'FND';
        h_x := FND_INSTALLATION.Get_App_Info(fnd_apps_short_name, h_status, h_industry, fnd_apps_schema);
    END IF;

    -- Init bsc_storage_clause
    h_sql := 'SELECT property_value FROM bsc_sys_init'||
             ' WHERE property_code = :1';
    OPEN cv FOR h_sql USING h_nextext_propcode;
    FETCH cv INTO h_next_extent;
    IF cv%NOTFOUND THEN
        h_next_extent := '1M';
    END IF;
    CLOSE cv;

    bsc_storage_clause := 'STORAGE (INITIAL 4K NEXT '||h_next_extent||
                          ' MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0'||
                          ' FREELIST GROUPS 4 FREELISTS 4)'||
                          ' PCTFREE 10 INITRANS 11 MAXTRANS 255';

    -- Init tablespace clause for tables and indexes
    IF apps_env THEN
        h_sql := 'SELECT tablespace, index_tablespace'||
                 ' FROM fnd_product_installations'||
                 ' WHERE application_id = 271';

        OPEN cv FOR h_sql;
        FETCH cv INTO h_tbs_tbl, h_tbs_idx;
        IF cv%FOUND THEN
            bsc_tablespace_clause_tbl := 'TABLESPACE '||h_tbs_tbl;
            bsc_tablespace_clause_idx := 'TABLESPACE '||h_tbs_idx;
        END IF;
        CLOSE cv;
    END IF;

    -- Init apps_user_id
    IF apps_env THEN
        h_sql := 'SELECT fnd_global.user_id FROM DUAL';
        OPEN cv FOR h_sql;
        FETCH cv INTO apps_user_id;
        IF cv%NOTFOUND THEN
            apps_user_id := -1;
        END IF;
        CLOSE cv;
    ELSE
        -- personal version
        h_sql := 'SELECT user_id FROM bsc_apps_users WHERE user_name = ''BSCADMIN''';
        OPEN cv FOR h_sql;
        FETCH cv INTO apps_user_id;
        IF cv%NOTFOUND THEN
            apps_user_id := -1;
        END IF;
        CLOSE cv;
    END IF;

    -- Init bsc_mv global variable
    -- Read sum level from bsc_sys_init
    h_sql := 'SELECT property_value'||
             ' FROM bsc_sys_init'||
             ' WHERE property_code = :1';
    OPEN cv FOR h_sql USING h_sum_level_prop_code;
    FETCH cv INTO h_sum_level;
    IF cv%NOTFOUND THEN
        bsc_mv := FALSE;
    ELSE
        IF h_sum_level IS NULL THEN
            bsc_mv := FALSE;
        ELSE
            bsc_mv := TRUE;
        END IF;
    END IF;
    CLOSE cv;

END Init_Bsc_Apps;


/*===========================================================================+
| FUNCTION Init_Log_File
+============================================================================*/
FUNCTION Init_Log_File (
    x_log_file_name IN VARCHAR2,
        x_error_msg OUT NOCOPY VARCHAR2
        ) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    e_no_log_file_dir EXCEPTION;

    h_log_file_dir VARCHAR2(60);
    h_log_file_handle UTL_FILE.FILE_TYPE;

    CURSOR c_utl_file_dir IS
        SELECT
            VP.value
        FROM
            v$parameter VP
        WHERE
            UPPER(VP.name) = 'UTL_FILE_DIR';

    h_utl_file_dir VARCHAR2(2000);

BEGIN

    IF apps_env THEN
        -- APPS environment (concurrent program)

        FND_FILE.Put_Line(FND_FILE.LOG, '+---------------------------------------------------------------------------+');
        FND_FILE.Put_Line(FND_FILE.LOG, 'Oracle Balanced Scorecard: Version : '||c_version);
        FND_FILE.Put_Line(FND_FILE.LOG, '');
        FND_FILE.Put_Line(FND_FILE.LOG, 'Copyright (c) Oracle Corporation 1999. All rights reserved.');
        FND_FILE.Put_Line(FND_FILE.LOG, '+---------------------------------------------------------------------------+');
        FND_FILE.Put_Line(FND_FILE.LOG, Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                        Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                        ' '||TO_CHAR(SYSDATE, c_fto_long_date_time));

        FND_FILE.Put_Line(FND_FILE.OUTPUT, '+---------------------------------------------------------------------------+');
        FND_FILE.Put_Line(FND_FILE.OUTPUT, 'Oracle Balanced Scorecard: Version : '||c_version);
        FND_FILE.Put_Line(FND_FILE.OUTPUT, '');
        FND_FILE.Put_Line(FND_FILE.OUTPUT, 'Copyright (c) Oracle Corporation 1999. All rights reserved.');
        FND_FILE.Put_Line(FND_FILE.OUTPUT, '+---------------------------------------------------------------------------+');
        FND_FILE.Put_Line(FND_FILE.OUTPUT, Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                           Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                           ' '||TO_CHAR(SYSDATE, c_fto_long_date_time));

    ELSE
        -- Personal environment

        OPEN c_utl_file_dir;
        FETCH c_utl_file_dir INTO h_utl_file_dir;
        IF c_utl_file_dir%NOTFOUND THEN
            h_log_file_dir := NULL;
        ELSE
            IF h_utl_file_dir IS NULL THEN
                h_log_file_dir := NULL;
            ELSE
                IF INSTR(h_utl_file_dir, ',') > 0 THEN
                    h_log_file_dir := SUBSTR(h_utl_file_dir, 1, INSTR(h_utl_file_dir, ',') - 1);
                ELSE
                    h_log_file_dir := h_utl_file_dir;
                END IF;
            END IF;
        END IF;
        CLOSE c_utl_file_dir;

        IF h_log_file_dir IS NULL THEN
            RAISE e_no_log_file_dir;
        END IF;

        h_log_file_handle := UTL_FILE.FOPEN(h_log_file_dir, x_log_file_name, 'a');
        UTL_FILE.PUT_LINE(h_log_file_handle, '+---------------------------------------------------------------------------+');
        UTL_FILE.PUT_LINE(h_log_file_handle,'Oracle Balanced Scorecard: Version : '||c_version);
        UTL_FILE.PUT_LINE(h_log_file_handle, '');
        UTL_FILE.PUT_LINE(h_log_file_handle, 'Copyright (c) Oracle Corporation 1999. All rights reserved.');
        UTL_FILE.PUT_LINE(h_log_file_handle, '+---------------------------------------------------------------------------+');
        UTL_FILE.PUT_LINE(h_log_file_handle, Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                             Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                             ' '||TO_CHAR(SYSDATE, c_fto_long_date_time));
        UTL_FILE.FCLOSE(h_log_file_handle);

        g_log_file_name := x_log_file_name;
        g_log_file_dir := h_log_file_dir;

    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        x_error_msg := Get_Message('BSC_LOGFILE_CREATION_FAILED');
        RETURN FALSE;

    WHEN e_no_log_file_dir THEN
    x_error_msg := Get_Message('BSC_LOGFILE_DIR_NOT_SPECIFIED');
        RETURN FALSE;

    WHEN UTL_FILE.INVALID_PATH THEN
        x_error_msg := Get_Message('BSC_LOGFILE_PATH_FAILED');
        RETURN FALSE;

    WHEN UTL_FILE.INVALID_MODE THEN
        x_error_msg := Get_Message('BSC_LOGFILE_MODE_FAILED');
        RETURN FALSE;

    WHEN UTL_FILE.INVALID_OPERATION THEN
        x_error_msg := Get_Message('BSC_LOGFILE_OPERATION_FAILED');
        RETURN FALSE;

    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
        x_error_msg := Get_Message('BSC_LOGFILE_HANDLE_FAILED');
        RETURN FALSE;

    WHEN UTL_FILE.WRITE_ERROR THEN
        x_error_msg := Get_Message('BSC_WRITE_LOGFILE_FAILED');
        RETURN FALSE;

    WHEN OTHERS THEN
        x_error_msg := SQLERRM;
        RETURN FALSE;

END Init_Log_File;


/*===========================================================================+
| FUNCTION Log_File_Dir
+============================================================================*/
FUNCTION Log_File_Dir RETURN VARCHAR2 IS
BEGIN
    RETURN g_log_file_dir;

END Log_File_Dir;


/*===========================================================================+
| FUNCTION Log_File_Name
+============================================================================*/
FUNCTION Log_File_Name RETURN VARCHAR2 IS
BEGIN
    RETURN g_log_file_name;

END Log_File_Name;


/*===========================================================================+
| FUNCTION Object_Exists
+============================================================================*/
FUNCTION Object_Exists(
    x_object IN VARCHAR2
    ) RETURN BOOLEAN IS

    CURSOR get_obj IS
    SELECT object_name FROM user_objects
    WHERE object_name = upper(x_object);

    h_object VARCHAR2(130);

BEGIN
    -- This function looks into USER_OBJECTS. for APPS and Personal.
    OPEN get_obj;
    FETCH get_obj INTO h_object;
    IF get_obj%NOTFOUND THEN
    CLOSE get_obj;
    RETURN FALSE;
    END IF;
    CLOSE get_obj;

    RETURN TRUE;
END Object_Exists;


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
    ) RETURN VARCHAR2 IS

    h_message VARCHAR2(4000);

BEGIN
    h_message := REPLACE(x_message, '&'||x_token_name, x_token_value);
    RETURN h_message;
END Replace_Token;


/*===========================================================================+
| PROCEDURE Submit_Request_VB
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
    ) IS

    e_request_error EXCEPTION;
    h_request_id NUMBER;

BEGIN

    h_request_id := 0;

    IF UPPER(x_program) = 'BSCLOADER' THEN
        h_request_id := FND_REQUEST.Submit_Request(application => bsc_apps_short_name,
                            program => x_program,
                            description => NULL,
                            start_time => x_start_time,
                            sub_request => FALSE,
                            argument1 => x_argument1,
                            argument2 => x_argument2,
                                                    argument3 => x_argument3);

    ELSIF UPPER(x_program) = 'BSC_MIGRATION_PROC' THEN
        h_request_id := FND_REQUEST.Submit_Request(application => bsc_apps_short_name,
                            program => x_program,
                            description => NULL,
                            start_time => x_start_time,
                            sub_request => FALSE,
                            argument1 => x_argument1,
                            argument2 => x_argument2,
                            argument3 => x_argument3,
                            argument4 => x_argument4,
                            argument5 => x_argument5);
    END IF;

    IF h_request_id = 0 THEN
        RAISE e_request_error;
    END IF;

    -- Insert the request_id in BSC_MESSAGE_LOGS table (type = 3, information) to VB program
    -- be able to get it.

    BSC_MESSAGE.Add(x_message => h_request_id,
                    x_source => 'BSC_APPS.Submit_Request_VB',
                    x_type => 3,
                    x_mode => 'I');
    COMMIT;

EXCEPTION
    WHEN e_request_error THEN
        BSC_MESSAGE.Add(x_message => Get_Message('BSC_SUBMMITREQ_FAILED'),
                        x_source => 'BSC_APPS.Submit_Request_VB',
                        x_mode => 'I');
        COMMIT;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_APPS.Submit_Request_VB',
                        x_mode => 'I');
        COMMIT;

END Submit_Request_VB;


/*===========================================================================+
| FUNCTION Index_Exists                                                      |
+============================================================================*/
FUNCTION Index_Exists(
    x_index IN VARCHAR2
    ) RETURN BOOLEAN IS

    CURSOR get_index IS
    SELECT index_name FROM USER_INDEXES
    WHERE index_name = upper(x_index);

    CURSOR get_index_apps IS
    SELECT index_name FROM ALL_INDEXES
    WHERE index_name = upper(x_index)
        AND owner = upper(bsc_apps_schema);

    h_idx VARCHAR2(30);

BEGIN
    IF NOT apps_env THEN
        -- Personal
        OPEN get_index;
        FETCH get_index INTO h_idx;
        IF get_index%NOTFOUND THEN
          CLOSE get_index;
          RETURN FALSE;
        END IF;
        CLOSE get_index;
    ELSE
        -- APPS
        OPEN get_index_apps;
        FETCH get_index_apps INTO h_idx;
        IF get_index_apps%NOTFOUND THEN
          CLOSE get_index_apps;
          RETURN FALSE;
        END IF;
        CLOSE get_index_apps;
    END IF;

    RETURN TRUE;
END Index_Exists;


/*===========================================================================+
| FUNCTION Table_Exists                                                      |
+============================================================================*/
FUNCTION Table_Exists(
    x_table IN VARCHAR2
    ) RETURN BOOLEAN IS

    CURSOR get_table IS
    SELECT table_name FROM USER_TABLES
    WHERE table_name = upper(x_table);

    CURSOR get_table_apps IS
    SELECT table_name FROM ALL_TABLES
    WHERE table_name = upper(x_table)
        AND owner = upper(bsc_apps_schema);

    h_tbl VARCHAR2(30);

BEGIN
    IF NOT apps_env THEN
        -- Personal
        OPEN get_table;
        FETCH get_table INTO h_tbl;
        IF get_table%NOTFOUND THEN
        CLOSE get_table;
        RETURN FALSE;
        END IF;
        CLOSE get_table;
    ELSE
        -- APPS
        OPEN get_table_apps;
        FETCH get_table_apps INTO h_tbl;
        IF get_table_apps%NOTFOUND THEN
        CLOSE get_table_apps;
        RETURN FALSE;
        END IF;
        CLOSE get_table_apps;
    END IF;

    RETURN TRUE;
END Table_Exists;


/*===========================================================================+
| FUNCTION View_Exists                                                       |
+============================================================================*/
FUNCTION View_Exists(
    x_view  IN VARCHAR2
    ) RETURN BOOLEAN IS

    CURSOR get_view IS
    SELECT view_name FROM user_views
    WHERE view_name = upper(x_view);

    h_view VARCHAR2(30);

BEGIN
    -- In both, APPS and Personal, the view are installed in the current
    -- schema. So we dont need to user all_views table for APPS.

    OPEN get_view;
    FETCH get_view INTO h_view;
    IF get_view%NOTFOUND THEN
    CLOSE get_view;
    RETURN FALSE;
    END IF;
    CLOSE get_view;

    RETURN TRUE;
END View_Exists;


/*===========================================================================+
| PROCEDURE Wait_For_Request_VB
+============================================================================*/
PROCEDURE Wait_For_Request_VB(
    x_request_id IN NUMBER,
        x_interval IN NUMBER,
        x_max_wait IN NUMBER
        ) IS

    e_wait_error EXCEPTION;

    h_phase VARCHAR2(32000) := NULL;
    h_status VARCHAR2(2000) := NULL;
    h_dev_phase VARCHAR2(2000) := NULL;
    h_dev_status VARCHAR2(2000) := NULL;
    h_message VARCHAR2(2000) := NULL;

BEGIN
    IF NOT FND_CONCURRENT.Wait_For_Request(x_request_id,
                    x_interval,
                    x_max_wait,
                    h_phase,
                    h_status,
                    h_dev_phase,
                    h_dev_status,
                    h_message) THEN
        RAISE e_wait_error;
    END IF;

    COMMIT;

EXCEPTION
    WHEN e_wait_error THEN
        BSC_MESSAGE.Add(x_message => Get_Message('BSC_WAITREQ_FAILED'),
                        x_source => 'BSC_APPS.Wait_For_Request_VB',
                        x_mode => 'I');
        COMMIT;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_APPS.Wait_For_Request_VB',
                        x_mode => 'I');
        COMMIT;
END Wait_For_Request_VB;



/*===========================================================================+
| PROCEDURE Write_Errors_To_Log
+============================================================================*/
PROCEDURE Write_Errors_To_Log IS
    CURSOR c_messages IS
        SELECT
            message
        FROM
            bsc_message_logs
        WHERE
            last_update_login = USERENV('SESSIONID')
        ORDER BY
            last_update_date;

    h_message bsc_message_logs.message%TYPE;

BEGIN
        OPEN c_messages;
        FETCH c_messages INTO h_message;

        WHILE c_messages%FOUND LOOP
            Write_Line_Log(h_message, LOG_FILE);
            FETCH c_messages INTO h_message;
        END LOOP;

        CLOSE c_messages;

END Write_Errors_To_Log;


/*===========================================================================+
| PROCEDURE Write_Line_Log
+============================================================================*/
PROCEDURE Write_Line_Log (
    x_line IN VARCHAR2,
        x_which IN NUMBER
    ) IS

    h_log_file_handle UTL_FILE.FILE_TYPE;
    h_which NUMBER;

    h_line VARCHAR2(32700);

BEGIN
    h_line := TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS')||' '||x_line;

    IF apps_env THEN
        -- APPS environment (concurrent program)

        -- Due to some issue, when there is an error in the program
        -- the output file is not saved, i am going to write out NOCOPY put to log
        -- file also.

        IF x_which =  LOG_FILE THEN
            FND_FILE.Put_Line(FND_FILE.LOG, x_line);
        ELSE
            FND_FILE.Put_Line(FND_FILE.OUTPUT, x_line);
            FND_FILE.Put_Line(FND_FILE.LOG, x_line);
        END IF;

    ELSE
        -- Personal environment
        IF g_log_file_name IS NOT NULL THEN
            h_log_file_handle := UTL_FILE.FOPEN(g_log_file_dir, g_log_file_name, 'a');

            UTL_FILE.PUT_LINE(h_log_file_handle, x_line);
            UTL_FILE.FCLOSE(h_log_file_handle);
        END IF;
    END IF;

END Write_Line_Log;
/*===========================================================================+
|   Name:          Is_Bsc_User_Valid
|
|   Description:   This function return 1, if the user_id is a Valid BSc user.
|                  It means that has BSC responsibility and the resp. is between
|                   start and end date
|   Notes:
|                  Rewrote the API using a simple Static SQL for the API for
|                  Performance Bug #3236356
+============================================================================*/
FUNCTION Is_Bsc_User_Valid (
  x_User_Id IN NUMBER
) RETURN NUMBER IS
    l_count NUMBER;
    l_is_Valid_User NUMBER;
BEGIN

    l_is_Valid_User := 0;
    l_count := 0;

    SELECT COUNT(0)
    INTO   l_count
    FROM   FND_USER fu, FND_RESPONSIBILITY fr,FND_USER_RESP_GROUPS fur
    WHERE  fu.User_Id           = x_User_Id
    AND    fu.User_Id           = fur.User_Id
    AND    fr.Responsibility_Id = fur.Responsibility_Id
    AND    fr.Application_Id    = fur.Responsibility_Application_Id
    AND    fr.Application_Id    = 271
    AND    SYSDATE BETWEEN fu.Start_Date AND NVL(fu.End_Date, SYSDATE)
    AND    SYSDATE BETWEEN fr.Start_Date AND NVL(fr.End_Date, SYSDATE);

    IF l_count > 0 THEN
        l_is_Valid_User := 1;
    END IF;

    RETURN l_is_Valid_User;

EXCEPTION
    WHEN OTHERS THEN

      l_is_Valid_User := 0;
      RETURN l_is_Valid_User;

END Is_Bsc_User_Valid;

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
  x_User_Id IN NUMBER
) RETURN NUMBER IS
    l_count NUMBER;
    l_is_Valid_Design_User NUMBER;
BEGIN

    l_is_Valid_Design_User := 0;
    l_count := 0;

    SELECT COUNT(0)
    INTO   l_count
    FROM   FND_USER fu, FND_RESPONSIBILITY fr,FND_USER_RESP_GROUPS fur
    WHERE  fu.User_Id           = x_User_Id
    AND    fu.User_Id           = fur.User_Id
    AND    (fr.responsibility_key = 'BSC_DESIGNER' OR fr.responsibility_key = 'BSC_Manager')
    AND    fr.Responsibility_Id = fur.Responsibility_Id
    AND    fr.Application_Id    = fur.Responsibility_Application_Id
    AND    fr.Application_Id    = 271
    AND    SYSDATE BETWEEN fu.Start_Date AND NVL(fu.End_Date, SYSDATE)
    AND    SYSDATE BETWEEN fr.Start_Date AND NVL(fr.End_Date, SYSDATE)
    AND    SYSDATE BETWEEN fur.Start_Date AND NVL(fur.End_Date, SYSDATE);

    IF l_count > 0 THEN
        l_is_Valid_Design_User := 1;
    END IF;

    RETURN l_is_Valid_Design_User;

EXCEPTION
    WHEN OTHERS THEN

      l_is_Valid_Design_User := 0;
      RETURN l_is_Valid_Design_User;

END Is_Bsc_Design_User_Valid;

/*===========================================================================+
|   Name:          GET_USER_FULL_NAME
|
|   Description:   This fucntion return teh full name of the user from
|                  per_all_people_f table
|   Notes: Revamped API to call static cursor for Bug 3236356
+============================================================================*/
FUNCTION Get_User_Full_Name (
  x_User_Id in NUMBER
) RETURN VARCHAR2 is
  l_name VARCHAR2(240) := '';

  CURSOR  c_Full_Name IS
  SELECT  P.FULL_NAME
  FROM    PER_ALL_PEOPLE_F P, FND_USER F
  WHERE   P.PERSON_ID  = F.EMPLOYEE_ID
  AND     F.USER_ID    = x_User_Id;

BEGIN

    -- bug 2558075 get full name using empploye id

    OPEN  c_Full_Name;
    FETCH c_Full_Name INTO l_name;
    IF c_Full_Name%NOTFOUND THEN
      l_name := '';
    END IF;
    CLOSE c_Full_Name;


    RETURN l_name;

EXCEPTION
    WHEN OTHERS THEN

      IF c_Full_Name%ISOPEN THEN
         CLOSE c_Full_Name;
      END IF;

      RETURN l_name;

END Get_User_Full_Name;


/*===========================================================================+
|   Name:          get_user_schema
|
|   Description:   The fuction return the BSC schema name
|
|   Notes:
+============================================================================*/

FUNCTION get_user_schema
RETURN VARCHAR2 IS

BEGIN
  -- BSC SCHEMA NAME
  RETURN get_user_schema (g_bsc_user_schema);

END get_user_schema;


/*===========================================================================+
|   Name:          get_user_schema (over loaded)
|
|   Description:   The function return the schema name for the application
|                  short name passed
|   Notes:
+============================================================================*/

FUNCTION get_user_schema ( p_app_short_name IN  varchar2 )
RETURN VARCHAR2 IS

  l_status              varchar2(1);
  l_industry            varchar2(1);
  l_oracle_schema       varchar2(30);
  l_return              boolean;
  l_app_short_name      VARCHAR2(30);

  CURSOR c_get_apps_schema is
    SELECT oracle_username
    FROM fnd_oracle_userid
    WHERE oracle_id between 900 and 999;

  /* In 11i on any env this query will always return
     one row */

BEGIN
    l_return := FALSE;

    BEGIN
      l_oracle_schema := user_schema_tbl(UPPER(p_app_short_name));    --First check if the value is there on cache
      l_return := TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      l_oracle_schema := NULL;
    END;

    --dbms_output.put_line(' GOT l_oracle_schema FROM CACHE:-' || l_oracle_schema);

    IF(l_oracle_schema IS NULL) THEN
      l_app_short_name := UPPER(p_app_short_name);
      IF ( l_app_short_name = g_apps_user_schema ) THEN
        IF ( c_get_apps_schema%ISOPEN ) THEN
          CLOSE c_get_apps_schema;
        END IF;

        OPEN  c_get_apps_schema;
        FETCH c_get_apps_schema into l_oracle_schema;
        CLOSE c_get_apps_schema;
        l_return := TRUE;
      ELSE
        l_return := FND_INSTALLATION.get_app_info
                    ( application_short_name  => l_app_short_name
                    , status                  => l_status
                    , industry                => l_industry
                    , oracle_schema           => l_oracle_schema
                    );
      END IF;
    END IF;

  IF l_return THEN
    user_schema_tbl(UPPER(p_app_short_name)) := l_oracle_schema; --Do  lazy cache
    RETURN l_oracle_schema;
  ELSE
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  RAISE;

END get_user_schema;

/*===========================================================================+
| PROCEDURE Do_DDL_AT, Use to execute multiple statements under single
|                      Autonomous Transaction.
|                      Fixed Bug #3541933
+============================================================================*/
PROCEDURE Do_DDL_AT(
    x_Statements_Tbl   IN   BSC_APPS.Autonomous_Statements_Tbl_Type
) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  FOR i IN 0..(x_Statements_Tbl.COUNT-1) LOOP
    IF ((x_Statements_Tbl(i).x_statement_type IS NULL) OR (x_Statements_Tbl(i).x_Object_Name IS NULL)) THEN
      EXECUTE IMMEDIATE x_Statements_Tbl(i).x_statement;
    ELSE
      AD_DDL.Do_DDL
      (   Applsys_Schema          => NVL(x_Statements_Tbl(i).x_Fnd_Apps_Schema,     BSC_APPS.Fnd_Apps_Schema)
        , Application_Short_Name  => NVL(x_Statements_Tbl(i).x_Bsc_Apps_Short_Name, BSC_APPS.Bsc_Apps_Short_Name)
        , Statement_Type          => x_Statements_Tbl(i).x_Statement_Type
        , Statement               => x_Statements_Tbl(i).x_Statement
        , Object_Name             => x_Statements_Tbl(i).x_Object_Name
      );
    END IF;
  END LOOP;
END Do_DDL_AT;

/*===========================================================================+
| FUNCTION Get_Bsc_Message
+============================================================================*/
FUNCTION Get_Bsc_Message
(   p_Message_Name IN VARCHAR2,
    p_Token_Names  IN VARCHAR2,
    p_Lookup_Codes IN VARCHAR2,
    p_Lookup_Types IN VARCHAR2
) RETURN VARCHAR2
IS
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);

    l_Lookup_Types   VARCHAR2(2000);
    l_Lookup_Codes   VARCHAR2(2000);
    l_Token_Names    VARCHAR2(2000);

    l_Lookup_Type    VARCHAR2(100);
    l_Lookup_Code    VARCHAR2(100);
    l_Token_Name     VARCHAR2(100);
BEGIN
    FND_MSG_PUB.Initialize;
    FND_MESSAGE.SET_NAME('BSC',  p_Message_Name);

    l_Lookup_Types     :=  TRIM(p_Lookup_Types);
    l_Lookup_Codes     :=  TRIM(p_Lookup_Codes);
    l_Token_Names      :=  TRIM(p_Token_Names);
    IF (l_Token_Names IS NOT NULL) THEN
        WHILE (is_more(   x_Lookup_Types    =>  l_Lookup_Types
                        , x_Lookup_Codes    =>  l_Lookup_Codes
                        , x_Token_Names     =>  l_Token_Names
                        , x_Lookup_Type     =>  l_Lookup_Type
                        , x_Lookup_Code     =>  l_Lookup_Code
                        , x_Token_Name      =>  l_Token_Name
         )) LOOP
            IF ((l_Lookup_Type IS NULL) OR (UPPER(l_Lookup_Type) = 'NULL')) THEN
                FND_MESSAGE.SET_TOKEN(l_Token_Name, l_Lookup_Code);
            ELSE
                FND_MESSAGE.SET_TOKEN(l_Token_Name, BSC_APPS.Get_Lookup_Value(l_Lookup_Type, l_Lookup_Code), TRUE);
            END IF;
        END LOOP;
    END IF;

    FND_MSG_PUB.ADD;
    --fetch the message
    FND_MSG_PUB.Count_And_Get
    (      p_encoded   =>  FND_API.G_FALSE
       ,   p_count     =>  l_msg_count
       ,   p_data      =>  l_msg_data
    );
    RETURN l_msg_data;
END Get_Bsc_Message;

END BSC_APPS;

/
