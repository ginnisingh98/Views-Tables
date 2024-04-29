--------------------------------------------------------
--  DDL for Package EGO_USER_ATTRS_BULK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_USER_ATTRS_BULK_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVBUAS.pls 120.14.12010000.4 2012/06/01 10:03:53 yifwang ship $ */

                          ----------------
                          -- Data Types --
                          ----------------

    TYPE EGO_USER_ATTRS_BULK_STR_TBL IS TABLE OF VARCHAR2(1000);
    TYPE EGO_USER_ATTRS_BULK_NUM_TBL IS TABLE OF NUMBER;
    TYPE EGO_USER_ATTRS_BULK_DATE_TBL IS TABLE OF DATE;



                       ----------------------
                       -- Global Variables --
                       ----------------------

    G_NULL_TOKEN_NUM                  CONSTANT VARCHAR2(8) := '9.97E125';
    G_NULL_TOKEN_STR                  CONSTANT VARCHAR2(6) := 'CHR(1)';
    G_NULL_TOKEN_DATE                 CONSTANT VARCHAR2(20) := 'TO_DATE(''3'',''J'')';

    G_NULL_NUM_VAL                    CONSTANT  VARCHAR2(8)  := '9.99E125';
    G_NULL_CHAR_VAL                   CONSTANT  VARCHAR2(2)  := '!';
    G_NULL_DATE_VAL                   CONSTANT  VARCHAR2(20) := 'TO_DATE(''1'',''j'')';
    G_NULL_NUM_VAL_STR                CONSTANT  VARCHAR2(130):= '999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';

    G_NULL_TOKEN_NUM_1                CONSTANT VARCHAR2(8) := '9.91E125';
    G_NULL_TOKEN_STR_1                CONSTANT VARCHAR2(6) := 'CHR(2)';
    G_NULL_TOKEN_DATE_1               CONSTANT VARCHAR2(20) := 'TO_DATE(''5'',''J'')';


/*
 * PROCESS_STATUS constants
 * ------------------------
 * The following constants are used in the PROCESS_STATUS column of the table
 *
 * G_PS_TO_BE_PROCESSED: row should be processed
 * G_PS_IN_PROCESS: row is being processed
 * G_PS_GENERIC_ERROR: some row in the same logical Attribute Group as this row
 *                     encountered an error (all error statuses described below
 *                     are set to this status at the completion of processing)
 * G_PS_SUCCESS: row processed succcessfully
 *
 * In addition to the four basic error statuses above, there are several internal
 * statuses that may appear in the interface table at times (for instance, while
 * a data set is being processed, or if the process encountered a fatal error)
 */
       G_PS_TO_BE_PROCESSED             CONSTANT NUMBER := 1;
       G_PS_IN_PROCESS                  CONSTANT NUMBER := 2;
       G_PS_GENERIC_ERROR               CONSTANT NUMBER := 3;
       G_PS_SUCCESS                     CONSTANT NUMBER := 4;

/* 3*/ G_PS_BAD_ATTR_OR_AG_METADATA     CONSTANT NUMBER := POWER(2,3);  -- 8
/* 4*/ G_PS_MULTIPLE_ENTRIES            CONSTANT NUMBER := POWER(2,4);  -- 16
/* 5*/ G_PS_MULTIPLE_VALUES             CONSTANT NUMBER := POWER(2,5);  -- 32
/* 6*/ G_PS_NO_PRIVILEGES               CONSTANT NUMBER := POWER(2,6);  -- 64
/* 7*/ G_PS_VALUE_NOT_IN_VS             CONSTANT NUMBER := POWER(2,7);  -- 128
/* 8*/ G_PS_INVALID_NUMBER_DATA         CONSTANT NUMBER := POWER(2,8);  -- 256
/* 9*/ G_PS_INVALID_DATE_DATA           CONSTANT NUMBER := POWER(2,9);  -- 512
/*10*/ G_PS_INVALID_DATE_TIME_DATA      CONSTANT NUMBER := POWER(2,10); -- 1024
/*11*/ G_PS_MAX_LENGTH_VIOLATION        CONSTANT NUMBER := POWER(2,11); -- 2048
/*12*/ G_PS_BAD_TTYPE_UPDATE            CONSTANT NUMBER := POWER(2,12); -- 4096
/*13*/ G_PS_BAD_TTYPE_CREATE            CONSTANT NUMBER := POWER(2,13); -- 8192
/*14*/ G_PS_BAD_TTYPE_DELETE            CONSTANT NUMBER := POWER(2,14); -- 16384
/*15*/ G_PS_REQUIRED_ATTRIBUTE          CONSTANT NUMBER := POWER(2,15); -- 32768
/*16*/ G_PS_AG_NOT_ASSOCIATED           CONSTANT NUMBER := POWER(2,16); -- 65536
/*17*/ G_PS_IDENTICAL_ROWS              CONSTANT NUMBER := POWER(2,17); -- 131072
/*18*/ G_PS_BAD_PK_VAL                  CONSTANT NUMBER := POWER(2,18); -- 262144
/*19*/ G_PS_DATA_IN_WRONG_COL           CONSTANT NUMBER := POWER(2,19); -- 524288
/*20*/ G_PS_BAD_ATTRS_IN_TVS_WHERE      CONSTANT NUMBER := POWER(2,20); -- 1048576
/*21*/ G_PS_VALUE_NOT_IN_TVS            CONSTANT NUMBER := POWER(2,21); -- 2097152
/*22*/ G_PS_BAD_TVS_SETUP               CONSTANT NUMBER := POWER(2,22); -- 4194304
/*23*/ G_PS_MAX_VAL_VIOLATION           CONSTANT NUMBER := POWER(2,23); -- 8388608
/*24*/ G_PS_MIN_VAL_VIOLATION           CONSTANT NUMBER := POWER(2,24); -- 16777216
/*25*/ G_PS_BAD_ATTR_GRP_ID             CONSTANT NUMBER := POWER(2,25); -- 33554432
/*26*/ G_PS_TL_COL_IS_A_UK              CONSTANT NUMBER := POWER(2,26); -- 67108864
/*27*/ G_PS_PRE_EVENT_FAILED            CONSTANT NUMBER := POWER(2,27); -- 134217728
/*28*/ G_PS_INVALID_UOM                 CONSTANT NUMBER := POWER(2,28); -- 268435456
/*29*/ G_PS_VAL_RANGE_VIOLATION         CONSTANT NUMBER := POWER(2,29); -- 536870912
/*30*/ G_PS_INVALID_DATA_LEVEL          CONSTANT NUMBER := POWER(2,30); -- 1073741824
/*
****** THE ERROR STATUS G_PS_OTHER_ATTRS_INVALID SHOULD ALWAYS BE THE LAST ONE ******
*/
/*30*/  G_PS_OTHER_ATTRS_INVALID        CONSTANT NUMBER := POWER(2,31); --
--
-- DO NOT EXCEED THE LIMIT
-- BITAND is failing in error_log for NUMBER > 31
--


                          ----------------
                          -- Procedures --
                          ----------------

------------------------------------------------------------------------------------------
--API Name    : Bulk_Load_User_Attrs_Data
--Description : The api would would do all the validations for the rows in interface table
--              and updloads the valid rows. For bad rows the error is reported and the row
--              is marked as bad.

--Parameteres required :  p_api_version
--                        p_application_id
--                        p_attr_group_type
--                        p_object_name
--                        p_interface_table_name
--                        p_data_set_id

--Return parametere    : x_return_status = 1 if no associations exist
--                                            0 in all other cases
--
------------------------------------------------------------------------------------------

PROCEDURE Bulk_Load_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_object_name                   IN   VARCHAR2
       ,p_hz_party_id                   IN   VARCHAR2
       ,p_interface_table_name          IN   VARCHAR2
       ,p_data_set_id                   IN   NUMBER
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_default_dl_view_priv_list     IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_default_dl_edit_priv_list     IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_default_view_privilege        IN   VARCHAR2   DEFAULT NULL
       ,p_default_edit_privilege        IN   VARCHAR2   DEFAULT NULL
       ,p_privilege_predicate_api_name  IN   VARCHAR2   DEFAULT NULL
       ,p_related_class_codes_query     IN   VARCHAR2   DEFAULT '-100'
       ,p_validate                      IN   BOOLEAN    DEFAULT TRUE
       ,p_do_dml                        IN   BOOLEAN    DEFAULT TRUE
       ,p_do_req_def_valiadtion         IN   BOOLEAN    DEFAULT TRUE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);




------------------------------------------------------------------------------------------
--API Name    : Get_Datatype_Error_Val
--Description : The api would return the error code to be added to process status in case
--              the datatype of the attribute is not same as the data type of the entered
--              data.

--Parameteres required :  p_value_to_convert
--                        p_datatype
------------------------------------------------------------------------------------------
FUNCTION Get_Datatype_Error_Val (
        p_value_to_convert              IN   VARCHAR2
       ,p_datatype                      IN   VARCHAR2
) RETURN NUMBER;



------------------------------------------------------------------------------------------
--API Name    : Get_Max_Min_Error_Val
--Description : The api would return the error code to be added to process status in case
--              the value entered for the attribute is not in the limits given in the value
--              set.

--Parameteres required :  p_value_to_check
--                        p_datatype
--                        p_min_value
--                        p_max_value
------------------------------------------------------------------------------------------
FUNCTION Get_Max_Min_Error_Val (
        p_value_to_check                IN   VARCHAR2
       ,p_datatype                      IN   VARCHAR2
       ,p_min_value                     IN   VARCHAR2
       ,p_max_value                     IN   VARCHAR2
) RETURN NUMBER;



------------------------------------------------------------------------------------------
--API Name    : Get_Date
--Description : The api would return the date value of a given string, in case the given
--              string is not in the valid format or is not a valid date it returns a null

--Parameteres required :  p_date
------------------------------------------------------------------------------------------

FUNCTION Get_Date (
        p_date                          IN   VARCHAR2
       ,p_format                        IN   VARCHAR2 DEFAULT NULL
) RETURN DATE;






---------------------------------------------------------------------------------------------------------------------
--API Name    : Apply_Template_On_Intf_Table
--Description : The api would apply the attribute values in the template to the interface
--              table, this api should be called after the rows in the interface table are
--              validated.
--Parameteres required :  p_api_version
--                        p_application_id
--                        p_object_name
--                        p_interface_table_name
--                        p_data_set_id
--                        p_template_id
--                        p_Classification_code
--                        p_attr_group_type
--                        p_target_entity_sql : this parameter should contain a query which would give a list of
--                                              entities on which the template is to be applied and which template
--                                              is to be applied and a rownum column.
--                                              e.g. 'SELECT ROWNUM ENTITYNUMBER,
--                                                           Decode(ROWNUM, 1,256678,2,256679,null) INVENTORY_ITEM_ID,
--                                                           204 ORGANIZATION_ID, 14978 ITEM_CATALOG_GROUP_ID, -
--                                                           1 TEMPLATE_ID
--                                                           FROM ego_itm_usr_Attr_intrfc WHERE ROWNUM<3';
--                       p_class_code_hierarchy_sql : this would take in the comma seperated list or a SQL which returns
--                                                    the class_codes which might have to be considered while applying the
--                                                    template.
--
--                       p_hierarchy_template_tbl_sql: this paramter takes in a wrapper SQL over the template table to tweak
--                                                     the values to be applied bby the template. Items uses it to give in the
--                                                     SQL which returns the attr values for the template even for parent ICC's
--Return parametere    : x_return_status = 1 if no associations exist
--                                            0 in all other cases
--                       x_return_status
--                       x_errorcode
--                       x_msg_count
--                       x_msg_data
--
--
----------------------------------------------------------------------------------------------------------------------



 PROCEDURE Apply_Template_On_Intf_Table(
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_interface_table_name          IN   VARCHAR2
       ,p_data_set_id                   IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_request_id                    IN   NUMBER
       ,p_program_application_id        IN   NUMBER
       ,p_program_id                    IN   NUMBER
       ,p_program_update_date           IN   DATE
       ,p_current_user_party_id         IN   NUMBER
       ,p_target_entity_sql             IN   VARCHAR2
       ,p_process_status                IN   NUMBER    DEFAULT G_PS_IN_PROCESS
       ,p_class_code_hierarchy_sql      IN   VARCHAR2  DEFAULT NULL
       ,p_hierarchy_template_tbl_sql    IN   VARCHAR2  DEFAULT NULL
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);





-------------------------------------------------------------------------------------------------------
--API Name    : Insert_Default_Val_Rows
--Description : This API would insert rows with default values for attributes in attribute
--              groups not present in the interface table. Here only single row attr groups
--              with no required attrs are processed.

--Parameteres :  p_api_version       : Api version
--Parameteres :  p_application_id    : Application Id
--Parameteres :  p_attr_group_type   : The type of attr groups to be processed for the given
--                                     data set id.
--Parameteres :  p_object_name       : Object name.
--Parameteres :  p_interface_table_name : Interface table name for the UDA.
--Parameteres :  p_data_set_id       : Data set to be processed.
--Parameteres :  p_target_entity_sql : This SQL should return all the entities to be processed,
--                                     it should give the pk's, class code and data level of
--                                     the entity. Sample SQL:
--                                     'SELECT INVENTORY_ITEM_ID,
--                                             ORGANIZATION_ID,
--                                             ITEM_CATALOG_GROUP_ID,
--                                             REVISION_ID
--                                             FROM MTL_SYSTEM_ITEMS_INTERFACE
--                                            WHERE SET_PROCESS_ID = 2910
--                                              AND PROCESS_FLAG = 7'

--Parameteres :  p_additional_class_Code_query : This sQL should return all the classification
--                                     codes for which attr group associations are to be
--                                     considered, for example this can give all the parent
--                                     class codes for an entity. Sampl SQL:
--                                     SELECT CHILD_CATALOG_GROUP_ID
--                                       FROM EGO_ITEM_CAT_DENORM_HIER
--                                      WHERE PARENT_CATALOG_GROUP_ID = ENTITY.ITEM_CATALOG_GROUP_ID
--Parameteres :  p_extra_column_names: This parapeter can be used to specify the columns whcih the
--                                     defaulting API should populate while creating attr rows.
--                                     It takes in comma seperated column names with no comma at the
--                                     beginning and the end.
--Parameteres :  p_extra_column_values:This parapeter would contain the values for the columns passed
--                                     in the parameter p_extra_column_names.
--                                     It takes in comma seperated values with no comma at the
--                                     beginning and the end.
--                                     p_extra_column_names and p_extra_column_values should co exist.
--Parameteres :  p_commit            : Should the changes made be commited in the API
------------------------------------------------------------------------------------------

PROCEDURE Insert_Default_Val_Rows (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_object_name                   IN   VARCHAR2
       ,p_interface_table_name          IN   VARCHAR2
       ,p_data_set_id                   IN   NUMBER
       ,p_target_entity_sql             IN   VARCHAR2
       ,p_attr_groups_to_exclude        IN   VARCHAR2  DEFAULT NULL
       ,p_additional_class_Code_query   IN   VARCHAR2  DEFAULT NULL
       ,p_extra_column_names            IN   VARCHAr2  DEFAULT NULL
       ,p_extra_column_values           IN   VARCHAR2  DEFAULT NULL
       ,p_commit                        IN   VARCHAR2  DEFAULT FND_API.G_FALSE
       ,p_process_status                IN   NUMBER    DEFAULT G_PS_IN_PROCESS
       ,p_comp_seq_id                   IN   NUMBER DEFAULT NULL
       ,p_bill_seq_id                   IN   NUMBER DEFAULT NULL
       ,p_structure_type_id             IN   NUMBER DEFAULT NULL
       ,p_data_level_column             IN   VARCHAR2 DEFAULT NULL
       ,p_datalevel_id                  IN   NUMBER DEFAULT NULL
       ,p_context_id                    IN   NUMBER DEFAULT NULL
       ,p_transaction_id                IN   NUMBER DEFAULT NULL
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_data                      OUT NOCOPY VARCHAR2
                                  );


-------------------------------------------------------------------------------------------------------
--API Name    : Mark_Unchanged_Attr_Rows
--Description : This API would insert rows with default values for attributes in attribute
--              groups not present in the interface table. Here only single row attr groups
--              with no required attrs are processed.

--Parameteres :  p_api_version       : Api version
--Parameteres :  p_application_id    : Application Id
--Parameteres :  p_attr_group_type   : The type of attr groups to be processed for the given
--                                     data set id.
--Parameteres :  p_object_name       : Object name.
--Parameteres :  p_interface_table_name : Interface table name for the UDA.
--Parameteres :  p_data_set_id       : Data set to be processed.
--Parameteres :  p_commit            : Should the changes made be commited in the API
-------------------------------------------------------------------------------------------------------


PROCEDURE Mark_Unchanged_Attr_Rows (  p_api_version                   IN   NUMBER
                                     ,p_application_id                IN   NUMBER
                                     ,p_attr_group_type               IN   VARCHAR2
                                     ,p_object_name                   IN   VARCHAR2
                                     ,p_interface_table_name          IN   VARCHAR2
                                     ,p_data_set_id                   IN   NUMBER
                                     ,p_new_status                    IN   NUMBER
                                     ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
                                     ,x_return_status                 OUT NOCOPY VARCHAR2
                                     ,x_msg_data                      OUT NOCOPY VARCHAR2
                                   );


-- abedajna Bug 6322809
function get_num_occur (p_string in varchar2, p_char in varchar2) return number;

-- abedajna Bug 6322809
function get_order_by (p_whereclause in varchar2, p_len in number) return number;

-- abedajna Bug 6322809
function process_whereclause (p_whereclausein in varchar2) return varchar2;



END EGO_USER_ATTRS_BULK_PVT;


/
