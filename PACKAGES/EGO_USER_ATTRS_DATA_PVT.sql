--------------------------------------------------------
--  DDL for Package EGO_USER_ATTRS_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_USER_ATTRS_DATA_PVT" AUTHID DEFINER AS
/* $Header: EGOPEFDS.pls 120.15.12010000.3 2010/03/26 07:32:34 geguo ship $ */



--=======================================================================--
--=*********************************************************************=--
--=*===================================================================*=--
--=*=                                                                 =*=--
--=*=  NOTE: This is a PRIVATE package; it is for internal use only,  =*=--
--=*=  and it is not supported for customer use.  For access to this  =*=--
--=*=  functionality, please use EGO_USER_ATTRS_DATA_PUB.             =*=--
--=*=                                                                 =*=--
--=*===================================================================*=--
--=*********************************************************************=--
--=======================================================================--

                       ----------------------
                       -- Global Variables --
                       ----------------------

/*
 * p_mode constants
 * ----------------
 * Possible values for p_mode parameter in Process_Row, Validate_Row,
 * and Perform_DML_On_Row APIs: the value of the p_mode parameter
 * affects how all three of these APIs treat the passed-in data.
 * For example, passing G_CREATE_MODE to Perform_DML_On_Row will
 * cause the API to execute an Insert statement on the extension table.
 * As a more complicated example, consider an Attribute Group called
 * 'Emp Info' with a 'Date Logged' Attribute and a 'Current Status'
 * Attribute.  The 'Date Logged' Attribute might well have a Minimum
 * and Maximum value range of 'SYSDATE'.  Thus, if G_CREATE_MODE were
 * passed to Validate_Row, then the API would need to verify that the
 * value of the 'Date Logged' Attribute was the Date on the day of that
 * insertion.  Say, however, that sometime later the bug status changes,
 * and we want to update the extension table to reflect this.  In this
 * case, we wouldn't want Validate_Row to evaluate the 'Date Logged'
 * Attribute as if it were just being inserted, so we'd pass either
 * G_UPDATE_MODE or G_SYNC_MODE to Validate_Row so it would know the
 * context in which it should apply the validation rules for the row.
 * (G_SYNC_MODE instructs the API to determine for itself whether there
 * exists a row in the extension table for the passed-in data.  If such
 * a row exists, then it is updated; if not, a row is created and the
 * data are inserted into it.)
 * If no value is passed for p_mode, G_SYNC_MODE is assumed.  If an
 * invalid value is passed for p_mode, such as G_DELETE_MODE on a row
 * that doesn't exist, an error occurs.
 */

    G_CREATE_MODE        CONSTANT VARCHAR2(10) := 'CREATE'; --4th
    G_UPDATE_MODE        CONSTANT VARCHAR2(10) := 'UPDATE'; --2nd
    G_DELETE_MODE        CONSTANT VARCHAR2(10) := 'DELETE'; --1st
    G_SYNC_MODE          CONSTANT VARCHAR2(10) := 'SYNC';   --3rd

    -------------------------------------------------------------------------
    -- The Business Object Identifier is used for error-handling purposes. --
    -------------------------------------------------------------------------
    G_BO_IDENTIFIER      CONSTANT VARCHAR2(30) := 'USER_ATTRS_BO';



                          ----------------
                          -- Procedures --
                          ----------------

/*
 * Process_User_Attrs_Data
 * -----------------------
 * Process_User_Attrs_Data processes User Attribute data for one object
 * instance.  In addition to identifying information for the instance,
 * the procedure takes in a table of Attribute Group row objects and an
 * accompanying table of Attribute data objects; it organizes the two
 * sets of tables and calls Process_Row for each Attribute Group row,
 * passing all the Attribute objects for that row.  Process_Row then
 * validates the data for each Attribute Group (in G_CREATE_MODE or
 * G_UPDATE_MODE) and performs the appropriate DML operation on the
 * appropriate extension table. If the passed-in mode is null or
 * G_SYNC_MODE we decide whether the row needs to be inserted or updated.
 */

PROCEDURE Process_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
       ,p_change_info_table             IN   EGO_USER_ATTR_CHANGE_TABLE DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT  NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT  NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT  NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT  NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT  NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT  NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT  0
       ,p_validate_only                 IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_validate_hierarchy            IN   VARCHAR2   DEFAULT  FND_API.G_TRUE
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_raise_business_event          IN   BOOLEAN DEFAULT TRUE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

/*
 * Process_User_Attrs_Data
 * -----------------------
 * Please read the documentation given in the above method.
 * We are having only two additional parameters x_extension_id and x_mode
 * which are output parameters to identify the mode of operation and the
 * record that is updated.
 */

PROCEDURE Process_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
       ,p_change_info_table             IN   EGO_USER_ATTR_CHANGE_TABLE DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT  NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT  NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT  NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT  NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT  NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT  NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT  0
       ,p_validate_only                 IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_validate_hierarchy            IN   VARCHAR2   DEFAULT  FND_API.G_TRUE
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_raise_business_event          IN   BOOLEAN    DEFAULT  TRUE
       ,x_extension_id                  OUT NOCOPY NUMBER
       ,x_mode                          OUT NOCOPY VARCHAR2
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

/*
 * Get_User_Attrs_Data
 * -------------------
 * Get_User_Attrs_Data retrieves a requested subset of the User
 * Attribute data for one object instance.  In addition to identifying
 * information for the instance, the procedure takes in a table of
 * Attribute Group request objects (each of which contains a list of the
 * requested Attribute values within that Attribute Group) and calls
 * a private procedure that gets rows of Attr Group data for each Attribute
 * Group requested.  The procedure then converts those results into two
 * tables: a table of Attribute Group row objects and a table of Attribute
 * Group data objects.  Every row object has a ROW_IDENTIFIER value that is
 * used to find all data objects for that row (they each have ROW_IDENTIFIER
 * values as well, and their values will match that of the row to which they
 * belong).
 */
PROCEDURE Get_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT  NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT  NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT  NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT  0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE
       ,x_attributes_row_table          OUT NOCOPY EGO_USER_ATTR_ROW_TABLE
       ,x_attributes_data_table         OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


/*
 * Process_Row
 * -----------
 * Process_Row is the all-in-one API for handling the insertion, update,
 * or deletion of one row from a User-Defined Attribute extension table.
 * It internally handles validation to ensure that the passed-in data
 * are correct with respect to formatting, data type, etc.  If the data
 * pass this test, Process_Row performs a DML operation on the extension
 * table according to the passed-in p_mode parameter (this will be one of
 * the global variables defined above).
 * This signature takes in the Object Name and Object ID so that the
 * caller may pass either; it also takes in the Attr Group ID and the
 * three Attr Group PKs for the same reason.
 */
PROCEDURE Process_Row (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_id                 IN   NUMBER     DEFAULT NULL
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_validate_hierarchy            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER     DEFAULT NULL
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_validate_only                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_language_to_process           IN   VARCHAR2   DEFAULT NULL
       ,p_mode                          IN   VARCHAR2   DEFAULT G_SYNC_MODE
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT NULL
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_raise_business_event                 IN   BOOLEAN DEFAULT TRUE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


 /* Overload method with additional parameters x_extension_id, x_mode */

PROCEDURE Process_Row (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_id                 IN   NUMBER     DEFAULT NULL
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_validate_hierarchy            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER     DEFAULT NULL
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_validate_only                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_language_to_process           IN   VARCHAR2   DEFAULT NULL
       ,p_mode                          IN   VARCHAR2   DEFAULT G_SYNC_MODE
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT NULL
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_raise_business_event          IN   BOOLEAN DEFAULT TRUE
       ,x_extension_id                  OUT NOCOPY NUMBER
       ,x_mode                          OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

/*
 * Validate_Row
 * ------------
 * Validate_Row is the API for checking to ensure that a particular set
 * of User-Defined Attribute data is "valid"--i.e., that its values for
 * each Attribute meet all constraints defined for that Attribute (these
 * constraints may include data type, size, and value range, in addition
 * to many other possible constraints).
 * This signature takes in the Object Name and Object ID so that the
 * caller may pass either; it also takes in the Attr Group ID and the
 * three Attr Group PKs for the same reason.
 */
PROCEDURE Validate_Row (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_id                 IN   NUMBER     DEFAULT NULL
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER     DEFAULT NULL
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_mode                          IN   VARCHAR2   DEFAULT G_SYNC_MODE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);



/*
 * Perform_DML_On_Row
 * ------------------
 * Perform_DML_On_Row is the API that actually inserts a row into, updates
 * a row in, or deletes a row from the extension table.  It performs no
 * validation, which means that undefined behavior may arise if invalid data
 * are passed in.
 * This signature takes in the Object Name and Object ID so that the
 * caller may pass either; it also takes in the Attr Group ID and the
 * three Attr Group PKs for the same reason.
 */
PROCEDURE Perform_DML_On_Row (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_id                 IN   NUMBER     DEFAULT NULL
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER     DEFAULT NULL
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_mode                          IN   VARCHAR2   DEFAULT G_SYNC_MODE
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_use_def_vals_on_insert        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_bulkload_flag                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

/* Overload method with additional parameters x_extension_id, x_mode */

PROCEDURE Perform_DML_On_Row (
        p_api_version                   IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_id                 IN   NUMBER     DEFAULT NULL
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                  IN   NUMBER     DEFAULT NULL
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_mode                          IN   VARCHAR2   DEFAULT G_SYNC_MODE
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT NULL
       ,p_pending_tl_table_name         IN   VARCHAR2   DEFAULT NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_use_def_vals_on_insert        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_bulkload_flag                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       --Added by geguo for 9373845 begin
       ,p_creation_date                 IN   DATE       DEFAULT NULL
       ,p_last_update_date              IN   DATE       DEFAULT NULL
       --Added by geguo for 9373845 end
       ,x_extension_id                  OUT NOCOPY NUMBER
       ,x_mode                          OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);



PROCEDURE Generate_DML_For_Row (
        p_api_version                      IN   NUMBER
       ,p_object_id                        IN   NUMBER     DEFAULT NULL
       ,p_object_name                      IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_id                    IN   NUMBER     DEFAULT NULL
       ,p_application_id                   IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type                  IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name                  IN   VARCHAR2   DEFAULT NULL
       ,p_pk_column_name_value_pairs       IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                       IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_extension_id                     IN   NUMBER     DEFAULT NULL
       ,p_attr_name_value_pairs            IN   EGO_USER_ATTR_DATA_TABLE
       ,p_mode                             IN   VARCHAR2   DEFAULT G_SYNC_MODE
       ,p_extra_pk_col_name_val_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_extra_attr_name_value_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_alternate_ext_b_table_name       IN   VARCHAR2   DEFAULT NULL
       ,p_alternate_ext_tl_table_name      IN   VARCHAR2   DEFAULT NULL
       ,p_alternate_ext_vl_name            IN   VARCHAR2   DEFAULT NULL
       ,p_execute_dml                      IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_entity_id                        IN   NUMBER     DEFAULT NULL
       ,p_entity_index                     IN   NUMBER     DEFAULT NULL
       ,p_entity_code                      IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                      IN   NUMBER     DEFAULT 0
       ,p_use_def_vals_on_insert           IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list                IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_write_to_concurrent_log          IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack          IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                           IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_bulkload_flag                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_raise_business_event             IN   BOOLEAN DEFAULT TRUE
       ,x_return_status                    OUT NOCOPY VARCHAR2
       ,x_errorcode                        OUT NOCOPY NUMBER
       ,x_msg_count                        OUT NOCOPY NUMBER
       ,x_msg_data                         OUT NOCOPY VARCHAR2
       ,x_b_dml_for_ag                     OUT NOCOPY VARCHAR2
       ,x_tl_dml_for_ag                    OUT NOCOPY VARCHAR2
       ,x_b_bind_count                     OUT NOCOPY NUMBER
       ,x_tl_bind_count                    OUT NOCOPY NUMBER
       ,x_b_bind_attr_table                OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_tl_bind_attr_table               OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       );



FUNCTION Get_Extension_Id (
        p_object_name                      IN   VARCHAR2
       ,p_attr_group_id                    IN   NUMBER     DEFAULT NULL
       ,p_application_id                   IN   NUMBER
       ,p_attr_group_type                  IN   VARCHAR2
       ,p_attr_group_name                  IN   VARCHAR2   DEFAULT NULL
       ,p_pk_column_name_value_pairs       IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                       IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_name_value_pairs            IN   EGO_USER_ATTR_DATA_TABLE
       ,p_extra_pk_col_name_val_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_extra_attr_name_value_pairs      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_alternate_ext_b_table_name       IN   VARCHAR2   DEFAULT NULL
       ,p_alternate_ext_tl_table_name      IN   VARCHAR2   DEFAULT NULL
       ,p_alternate_ext_vl_name            IN   VARCHAR2   DEFAULT NULL
       ) RETURN NUMBER ;


/*
 * Perform_DML_From_Template
 * -------------------------
 */
PROCEDURE Perform_DML_From_Template (
        p_api_version                   IN   NUMBER
       ,p_template_id                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2 DEFAULT NULL
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_attr_group_ids_to_exclude     IN   EGO_NUMBER_TBL_TYPE           DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);



/*
 * Copy_User_Attrs_Data
 * --------------------
 *  From PIM for Retail (R12C), when the user is copying data across data levels
 *  user must pass old and new data level
 *
 */
PROCEDURE Copy_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_old_pk_col_value_pairs        IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_old_data_level_id             IN   NUMBER   DEFAULT  NULL
       ,p_old_dtlevel_col_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_new_pk_col_value_pairs        IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_new_data_level_id             IN   NUMBER   DEFAULT  NULL
       ,p_new_dtlevel_col_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_new_cc_col_value_pairs        IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_attr_group_list               IN   VARCHAR2   DEFAULT  NULL
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

/*
 * Implement_Change_Line
 * ---------------------
 */
PROCEDURE Implement_Change_Line (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_production_b_table_name       IN   VARCHAR2
       ,p_production_tl_table_name      IN   VARCHAR2
       ,p_change_b_table_name           IN   VARCHAR2
       ,p_change_tl_table_name          IN   VARCHAR2
       ,p_tables_application_id         IN   NUMBER
       ,p_change_line_id                IN   NUMBER
       ,p_old_data_level_nv_pairs       IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_new_data_level_nv_pairs       IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_related_class_code_function   IN   VARCHAR2
       ,p_init_msg_list                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

/*
 * Get_Ext_Data
 * ---------------------
 */
PROCEDURE Get_Ext_Data (
        p_attr_group_metadata_obj   IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_attr_metadata_obj         IN   EGO_ATTR_METADATA_OBJ
       ,p_pk_col1                   IN   VARCHAR2
       ,p_pk_col2                   IN   VARCHAR2   DEFAULT NULL
       ,p_pk_col3                   IN   VARCHAR2   DEFAULT NULL
       ,p_pk_col4                   IN   VARCHAR2   DEFAULT NULL
       ,p_pk_col5                   IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value1                 IN   VARCHAR2
       ,p_pk_value2                 IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value3                 IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value4                 IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value5                 IN   VARCHAR2   DEFAULT NULL
       ,p_data_level                IN   VARCHAR2   DEFAULT NULL
       ,p_dl_pk_values              IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_dl_metadata_obj           IN   EGO_DATA_LEVEL_METADATA_OBJ   DEFAULT NULL
       ,x_str_val                   OUT  NOCOPY     VARCHAR2
       ,x_num_val                   OUT  NOCOPY     NUMBER
       ,x_date_val                  OUT  NOCOPY     DATE
);



/*
 * Get_User_Attr_Val
 * -----------------
 */
FUNCTION Get_User_Attr_Val (
        p_appl_id           IN   NUMBER
       ,p_attr_grp_type     IN   VARCHAR2
       ,p_attr_grp_name     IN   VARCHAR2
       ,p_attr_name         IN   VARCHAR2
       ,p_object_name       IN   VARCHAR2
       ,p_pk_col1           IN   VARCHAR2
       ,p_pk_col2           IN   VARCHAR2   DEFAULT NULL
       ,p_pk_col3           IN   VARCHAR2   DEFAULT NULL
       ,p_pk_col4           IN   VARCHAR2   DEFAULT NULL
       ,p_pk_col5           IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value1         IN   VARCHAR2
       ,p_pk_value2         IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value3         IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value4         IN   VARCHAR2   DEFAULT NULL
       ,p_pk_value5         IN   VARCHAR2   DEFAULT NULL
       ,p_data_level        IN   VARCHAR2   DEFAULT NULL
       ,p_dl_pk_values      IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
)
RETURN VARCHAR2;


/*
 * Tokenized_Val_Set_Query
 * -----------------------
 */
FUNCTION Tokenized_Val_Set_Query (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_entity_id                     IN   VARCHAR2
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_is_disp_to_int_query          IN   BOOLEAN
       ,p_final_bind_value              IN   VARCHAR2
       ,p_return_bound_sql              IN   BOOLEAN DEFAULT FALSE
)
RETURN VARCHAR2;



/*
 * Get_Int_Val_For_Disp_Val
 * ------------------------
 */
FUNCTION Get_Int_Val_For_Disp_Val (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
       ,p_attr_value_obj                IN   EGO_USER_ATTR_DATA_OBJ
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_entity_id                     IN   VARCHAR2
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
)
RETURN VARCHAR2;



/*
 * Update_Attributes
 * -------------------------
 */
PROCEDURE Update_Attributes
        ( p_pk_column_name_value_pairs    IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_class_code_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_data_level                    IN VARCHAR2  DEFAULT NULL
        , p_data_level_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_attr_diffs                    IN EGO_USER_ATTR_DIFF_TABLE
        , p_transaction_type              IN VARCHAR2
        , p_attr_group_id                 IN NUMBER DEFAULT NULL
        , x_error_message                 OUT NOCOPY VARCHAR2
        );



/*
 * Set_Up_Debug_Session
 * --------------------
 */
PROCEDURE Set_Up_Debug_Session (
        p_entity_id                     IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_debug_level                   IN   NUMBER DEFAULT 0
);



/*
 * Debug_Msg
 * ---------
 */
PROCEDURE Debug_Msg (
        p_message                       IN VARCHAR2
       ,p_level_of_debug                IN NUMBER       DEFAULT 3
);

-- BEGIN AMAY
PROCEDURE Get_Attr_Diffs
        ( p_object_name                   IN VARCHAR2
        , p_pk_column_name_value_pairs    IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_class_code_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
        , p_data_level_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_attr_group_id                 IN NUMBER DEFAULT NULL
        , p_application_id                IN NUMBER DEFAULT NULL
        , p_attr_group_type               IN VARCHAR2 DEFAULT NULL
        , p_attr_group_name               IN VARCHAR2 DEFAULT NULL
        , px_attr_diffs                   IN OUT NOCOPY EGO_USER_ATTR_DIFF_TABLE
        , x_error_message                 OUT NOCOPY VARCHAR2
        );
-- END AMAY

/*
 * Get_Attr_Disp_Val_From_ValueSet
 * -------------------------------
 * Function returns the display value
 * of the attribute for a given internal value.
 */
 --gnanda api created for bug   4038065
FUNCTION Get_Attr_Disp_Val_From_VSet (
         p_application_id               IN   NUMBER
        ,p_attr_internal_date_value     IN   DATE     DEFAULT NULL
        ,p_attr_internal_str_value      IN   VARCHAR2 DEFAULT NULL
        ,p_attr_internal_num_value      IN   NUMBER   DEFAULT NULL
        ,p_attr_internal_name           IN   VARCHAR2
        ,p_attr_group_type              IN   VARCHAR2
        ,p_attr_group_int_name          IN   VARCHAR2
        ,p_attr_id                      IN   NUMBER
        ,p_object_name                  IN   VARCHAR2
        ,p_pk1_column_name              IN   VARCHAR2
        ,p_pk1_value                    IN   VARCHAR2
        ,p_pk2_column_name              IN   VARCHAR2 DEFAULT NULL
        ,p_pk2_value                    IN   VARCHAR2 DEFAULT NULL
        ,p_pk3_column_name              IN   VARCHAR2 DEFAULT NULL
        ,p_pk3_value                    IN   VARCHAR2 DEFAULT NULL
        ,p_pk4_column_name              IN   VARCHAR2 DEFAULT NULL
        ,p_pk4_value                    IN   VARCHAR2 DEFAULT NULL
        ,p_pk5_column_name              IN   VARCHAR2 DEFAULT NULL
        ,p_pk5_value                    IN   VARCHAR2 DEFAULT NULL
        ,p_data_level1_column_name      IN   VARCHAR2 DEFAULT NULL
        ,p_data_level1_value            IN   VARCHAR2 DEFAULT NULL
        ,p_data_level2_column_name      IN   VARCHAR2 DEFAULT NULL
        ,p_data_level2_value            IN   VARCHAR2 DEFAULT NULL
        ,p_data_level3_column_name      IN   VARCHAR2 DEFAULT NULL
        ,p_data_level3_value            IN   VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2;


/*
 * Get_Attr_Int_Val_From_VSet
 * -------------------------------
 * Function returns the internal value for a given display value
 */

FUNCTION Get_Attr_Int_Val_From_VSet (
         p_application_id               IN   NUMBER
        ,p_attr_disp_value              IN   VARCHAR2
        ,p_attr_internal_name           IN   VARCHAR2
        ,p_attr_group_type              IN   VARCHAR2
        ,p_attr_group_int_name          IN   VARCHAR2
        ,p_attr_group_id                IN   NUMBER
        ,p_attr_id                      IN   NUMBER
        ,p_return_intf_col              IN   VARCHAR2
        ,p_object_name                  IN   VARCHAR2
        ,p_ext_table_metadata_obj       IN   EGO_EXT_TABLE_METADATA_OBJ
        ,p_pk1_column_name              IN   VARCHAR2
        ,p_pk1_value                    IN   VARCHAR2
        ,p_pk2_column_name              IN   VARCHAR2
        ,p_pk2_value                    IN   VARCHAR2
        ,p_pk3_column_name              IN   VARCHAR2
        ,p_pk3_value                    IN   VARCHAR2
        ,p_pk4_column_name              IN   VARCHAR2
        ,p_pk4_value                    IN   VARCHAR2
        ,p_pk5_column_name              IN   VARCHAR2
        ,p_pk5_value                    IN   VARCHAR2
        ,p_data_level1_column_name      IN   VARCHAR2
        ,p_data_level1_value            IN   VARCHAR2
        ,p_data_level2_column_name      IN   VARCHAR2
        ,p_data_level2_value            IN   VARCHAR2
        ,p_data_level3_column_name      IN   VARCHAR2
        ,p_data_level3_value            IN   VARCHAR2
        ,p_entity_id                    IN   VARCHAR2
        ,p_entity_index                 IN   NUMBER
        ,p_entity_code                  IN   VARCHAR2
)
RETURN VARCHAR2;


-----------------------------------------------
-- Wrappers for Add_Bind and Init
-----------------------------------------------

PROCEDURE Add_Bind ( p_bind_identifier   IN VARCHAR2 DEFAULT NULL
                    ,p_value             IN VARCHAR2);


PROCEDURE Add_Bind ( p_bind_identifier   IN VARCHAR2 DEFAULT NULL
                    ,p_value             IN DATE);


PROCEDURE Add_Bind ( p_bind_identifier   IN VARCHAR2 DEFAULT NULL
                    ,p_value             IN NUMBER);



PROCEDURE Set_Binds_And_Dml( p_sql IN VARCHAR2
                            ,p_mode IN VARCHAR2);

PROCEDURE Init;
---------------------------------------------------------------




------------------------------------------------------------------
-- Following API's are exposed for CM, they need these API's    --
-- for moving the change line implementation code to CM package --
-- :gnanda                                                      --
------------------------------------------------------------------

FUNCTION Get_Table_Columns_List (
        p_application_id                IN   NUMBER
       ,p_from_table_name               IN   VARCHAR2
       ,p_from_cols_to_exclude_list     IN   VARCHAR2   DEFAULT NULL
       ,p_from_table_alias_prefix       IN   VARCHAR2   DEFAULT NULL
       ,p_to_table_name                 IN   VARCHAR2   DEFAULT NULL
       ,p_to_table_alias_prefix         IN   VARCHAR2   DEFAULT NULL
       ,p_in_line_view_where_clause     IN   VARCHAR2   DEFAULT NULL
       ,p_cast_date_cols_to_char        IN   BOOLEAN    DEFAULT FALSE
)
RETURN VARCHAR2;

FUNCTION Is_Data_Level_Correct (
        p_object_id                     IN   NUMBER
       ,p_attr_group_id                 IN   NUMBER
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_group_disp_name          IN   VARCHAR2
       ,x_err_msg_name                  OUT NOCOPY VARCHAR2
       ,x_token_table                   OUT NOCOPY ERROR_HANDLER.Token_Tbl_Type
)
RETURN BOOLEAN;

FUNCTION Get_Extension_Id_For_Row (
        p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL --R12C
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_name_value_pairs         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_change_obj                    IN   EGO_USER_ATTR_CHANGE_OBJ DEFAULT NULL
       ,p_extra_pk_col_name_val_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_pending_b_table_name          IN   VARCHAR2   DEFAULT NULL
       ,p_pending_vl_name               IN   VARCHAR2   DEFAULT NULL
)
RETURN NUMBER;
------------------------------------------------------------------
-- Above API's are exposed for CM, they need these API's        --
-- for moving the change line implementation code to CM package --
-- :gnanda                                                      --
------------------------------------------------------------------

/*
 * Validate_Required_Attrs
 * -----------------------
 * Validate_Required_Attrs validates data for one object instance by
 * checking which fields required fields does not have a value.
 * The procedure takes in a primary key object, the object name,
 * class code and data level information, as well as a list of
 * attribute group types on which object data should be
 * validated.
 * The procedure returns a table of user attribute object listing
 * required attributes for which the object does not have a value.
 */
PROCEDURE Validate_Required_Attrs (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name               IN   EGO_DATA_LEVEL_B.DATA_LEVEL_NAME%TYPE := NULL
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_group_type_table         IN   EGO_VARCHAR_TBL_TYPE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_attributes_req_table          OUT NOCOPY EGO_USER_ATTR_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);




/*
 * Get_Object_Id_From_Name
 * ------------
 * This API would return the object id for a given object name.
*/

FUNCTION Get_Object_Id_From_Name (
        p_object_name                   IN   VARCHAR2
    )
RETURN NUMBER;



/*
 * Apply_Default_Vals_For_Entity
 * ------------
 * Apply_Default_Vals_For_Entity : This API should be called after the entity creation
 * is successfuly done. This API would set the default values for attributes in the all
 * the single row attribute groups not having a required attribute for the givent entity.
 */


PROCEDURE Apply_Default_Vals_For_Entity (
        p_object_name                   IN   VARCHAR2
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_groups_to_exclude        IN   VARCHAR2   DEFAULT NULL
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level                    IN   VARCHAR2   DEFAULT NULL
       ,p_data_level_values             IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_additional_class_Code_list    IN   VARCHAR2   DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       );

/*
*Bug:9277377
*Add the function to check column for both table and view oject
*/
FUNCTION HAS_COLUMN_IN_TABLE_VIEW (p_object_name  IN  VARCHAR2
                             ,p_column_name IN  VARCHAR2
                             )
RETURN VARCHAR2;

END EGO_USER_ATTRS_DATA_PVT;


/
