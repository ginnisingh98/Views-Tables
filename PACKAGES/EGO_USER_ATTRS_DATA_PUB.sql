--------------------------------------------------------
--  DDL for Package EGO_USER_ATTRS_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_USER_ATTRS_DATA_PUB" AUTHID DEFINER AS
/* $Header: EGOPEFBS.pls 120.5.12010000.2 2009/12/07 08:39:13 iyin ship $ */
/*#
 * This package provides User-Defined Attributes functionality for
 * various objects--most notably Items, but also any other objects
 * that have enabled the User-Defined Attributes framework (e.g.,
 * Projects, Structures, etc.).
 * This includes DML (insertion, update, and deletion) on User-Defined
 * Attribute data), retrieval of such data, and copying of data from
 * one object to another.  It also includes Change control on data for
 * objects that have enabled Change functionality for the User-Defined
 * Attributes framework (for information about Change functionality,
 * refer to the Change Management documentation).
 *
 *                          ------------------
 *                          -- Object Types --
 *                          ------------------
 *
 * Each of the following data types is defined as an Oracle object type
 * that exists independently in the database.  They are discussed here
 * because all of these types were created for use by this package.
 *
 * ==========================
 * = EGO_USER_ATTR_DATA_OBJ =
 * ==========================
 *
 *<code><pre>
  CREATE EGO_USER_ATTR_DATA_OBJ AS OBJECT
  (
    ROW_IDENTIFIER       NUMBER
   ,ATTR_NAME            VARCHAR2(30)
   ,ATTR_VALUE_STR       VARCHAR2(1000)
   ,ATTR_VALUE_NUM       NUMBER
   ,ATTR_VALUE_DATE      DATE
   ,ATTR_DISP_VALUE      VARCHAR2(1000)
   ,ATTR_UNIT_OF_MEASURE VARCHAR2(3)
   ,USER_ROW_IDENTIFIER  NUMBER
  );
 *</pre></code>
 *
 * EGO_USER_ATTR_DATA_OBJ is an object type that contains data for one
 * attribute in an attribute group row.  ROW_IDENTIFIER is a foreign key
 * that associates each EGO_USER_ATTR_DATA_OBJ to one EGO_USER_ATTR_ROW_OBJ
 * (discussed below).  ATTR_NAME holds the internal name of the attribute.
 * The value being passed for the attribute is stored in ATTR_VALUE_STR if
 * the attribute is a string (translatable or not), in ATTR_VALUE_NUM
 * if the attribute is a number, in ATTR_VALUE_DATE if the attribute is
 * a date or datetime, or in ATTR_DISP_VALUE if the attribute has a value
 * set with distinct internal and display values.  NOTE: the attribute
 * value must be passed in exactly ~one~ of these four fields.
 * If the attribute is a number that has a Unit of Measure class associated
 * with it, ATTR_UNIT_OF_MEASURE stores the UOM Code for the Unit of Measure
 * in which the attribute's value will be displayed; however, the value
 * itself will always be passed in ATTR_VALUE_NUM in the base units for
 * the Unit of Measure class, not in the display units (unless they happen
 * to be the same).  For example, consider an attribute whose Unit of
 * Measure class is Length (a UOM Class whose base unit we will assume for
 * this example to be Centimeters).  If the caller wants data for this
 * attribute to be displayed in Feet (assuming its UOM_CODE is 'FT'),
 * then ATTR_UNIT_OF_MEASURE should be passed with 'FT'; however, no
 * matter in what unit the caller wants to display this attribute, the
 * value in ATTR_VALUE_NUM will always be the attribute's value as
 * expressed in Centimeters.
 * The final field in the object type, USER_ROW_IDENTIFIER, is a numeric
 * value used when reporting errors for this EGO_USER_ATTR_DATA_OBJ.  When
 * the errors are written to the MTL_INTERFACE_ERRORS table, the TRANSACTION_ID
 * column stores the value passed in USER_ROW_IDENTIFIER; thus, to find
 * errors logged for this EGO_USER_ATTR_DATA_OBJ, search for rows in
 * MTL_INTERFACE_ERRORS whose TRANSACTION_ID column values match the
 * passed-in USER_ROW_IDENTIFIER.
 *
 * ============================
 * = EGO_USER_ATTR_DATA_TABLE =
 * ============================
 *
 *<code><pre>
  CREATE EGO_USER_ATTR_DATA_TABLE AS TABLE OF EGO_USER_ATTR_DATA_OBJ;
 *</pre></code>
 *
 * =========================
 * = EGO_USER_ATTR_ROW_OBJ =
 * =========================
 *
 *<code><pre>
  CREATE EGO_USER_ATTR_ROW_OBJ AS OBJECT
  (
    ROW_IDENTIFIER    NUMBER
   ,ATTR_GROUP_ID     NUMBER
   ,ATTR_GROUP_APP_ID NUMBER
   ,ATTR_GROUP_TYPE   VARCHAR2(40)
   ,ATTR_GROUP_NAME   VARCHAR2(30)
   ,DATA_LEVEL_1      VARCHAR2(150)
   ,DATA_LEVEL_2      VARCHAR2(150)
   ,DATA_LEVEL_3      VARCHAR2(150)
   ,TRANSACTION_TYPE  VARCHAR2(10)
  );
 *</pre></code>
 *
 * EGO_USER_ATTR_ROW_OBJ contains row-level data about one attribute group
 * row.  ROW_IDENTIFIER is the unique numeric identifier for this attribute
 * group row within a set of rows to be processed; no two EGO_USER_ATTR_ROW_OBJ
 * elements in any single API call can share the same ROW_IDENTIFIER value.
 * The attribute group whose row-level data this EGO_USER_ATTR_ROW_OBJ
 * contains is identified either by ATTR_GROUP_ID or by the combination
 * of ATTR_GROUP_APP_ID, ATTR_GROUP_TYPE, and ATTR_GROUP_NAME.  (The first
 * field is the numeric key for an attribute group, and the latter three
 * fields form the composite key for an attribute group.)
 * If the attribute group type has data levels defined and the attribute
 * group is associated at a data level other than the highest data level
 * defined for the attribute group type, the data level values are passed
 * in DATA_LEVEL_1, DATA_LEVEL_2, and DATA_LEVEL_3 (as necessary).
 * TRANSACTION_TYPE indicates the mode of DML operation to be performed
 * on this attribute group row; valid values are
 * EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE, EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE,
 * EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE, or, if the caller is uncertain
 * whether this row exists in the database, EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE,
 * which indicates that the API should determine whether to CREATE or
 * UPDATE this attribute group row.
 *
 * ===========================
 * = EGO_USER_ATTR_ROW_TABLE =
 * ===========================
 *
 *<code><pre>
  CREATE EGO_USER_ATTR_ROW_TABLE AS TABLE OF EGO_USER_ATTR_ROW_OBJ;
 *</pre></code>
 *
 * ===============================
 * = EGO_COL_NAME_VALUE_PAIR_OBJ =
 * ===============================
 *
 *<code><pre>
  CREATE EGO_COL_NAME_VALUE_PAIR_OBJ AS OBJECT
  (
    NAME  VARCHAR2(30)
   ,VALUE VARCHAR2(150)
  );
 *</pre></code>
 *
 * EGO_COL_NAME_VALUE_PAIR_OBJ contains the column name and corresponding
 * value for one Primary Key, Classification Code, or other column relevant
 * to the API.
 *
 * =================================
 * = EGO_COL_NAME_VALUE_PAIR_ARRAY =
 * =================================
 *
 *<code><pre>
  CREATE EGO_COL_NAME_VALUE_PAIR_ARRAY AS VARRAY(6) OF EGO_COL_NAME_VALUE_PAIR_OBJ;
 *</pre></code>
 *
 * ============================
 * = EGO_USER_ATTR_CHANGE_OBJ =
 * ============================
 *
 *<code><pre>
  CREATE EGO_USER_ATTR_CHANGE_OBJ AS OBJECT
  (
    ROW_IDENTIFIER NUMBER
   ,CHANGE_ID      NUMBER
   ,CHANGE_LINE_ID NUMBER
   ,ACD_TYPE       VARCHAR2(40))
  );
 *</pre></code>
 *
 * EGO_USER_ATTR_CHANGE_OBJ contains Change data for one attribute group
 * row.  ROW_IDENTIFIER is a foreign key that associates each
 * EGO_USER_ATTR_CHANGE_OBJ to one EGO_USER_ATTR_ROW_OBJ (discussed above).
 * CHANGE_ID and CHANGE_LINE_ID identify the Change Header and Line,
 * respectively, that are applicable to the specified attribute group row.
 * ACD_TYPE indicates whether the Change is of type Add, Change, or Delete
 * (for details, refer to the Change Management documentation).
 *
 * ==============================
 * = EGO_USER_ATTR_CHANGE_TABLE =
 * ==============================
 *
 *<code><pre>
  CREATE EGO_USER_ATTR_CHANGE_TABLE AS TABLE OF EGO_USER_ATTR_CHANGE_OBJ;
 *</pre></code>
 *
 * ==============================
 * = EGO_ATTR_GROUP_REQUEST_OBJ =
 * ==============================
 *
 *<code><pre>
  CREATE EGO_ATTR_GROUP_REQUEST_OBJ AS OBJECT
  (
    ATTR_GROUP_ID   NUMBER
   ,APPLICATION_ID  NUMBER
   ,ATTR_GROUP_TYPE VARCHAR2(40)
   ,ATTR_GROUP_NAME VARCHAR2(30)
   ,DATA_LEVEL_1    VARCHAR2(150)
   ,DATA_LEVEL_2    VARCHAR2(150)
   ,DATA_LEVEL_3    VARCHAR2(150)
   ,ATTR_NAME_LIST  VARCHAR2(3000)
  );
 *</pre></code>
 *
 * EGO_ATTR_GROUP_REQUEST_OBJ represents a request to retrieve data for
 * one attribute group row from the database.  It is very similar in
 * structure to EGO_USER_ATTR_ROW_OBJ (discussed above); the notable
 * difference is the field ATTR_NAME_LIST, which contains a comma-delimited
 * list of attribute internal names specifying the attributes for which to
 * retrieve data.  If the field is empty, data will be fetched for all
 * attributes in the attribute group row.
 *
 * ================================
 * = EGO_ATTR_GROUP_REQUEST_TABLE =
 * ================================
 *
 *<code><pre>
  CREATE EGO_ATTR_GROUP_REQUEST_TABLE AS TABLE OF EGO_ATTR_GROUP_REQUEST_OBJ;
 *</pre></code>
 *
 * ========================
 * = EGO_VARCHAR_TBL_TYPE =
 * ========================
 *
 *<code><pre>
  CREATE EGO_VARCHAR_TBL_TYPE AS TABLE OF VARCHAR2(500);
 *</pre></code>
 *
 * @rep:scope public
 * @rep:product EGO
 * @rep:displayname User-Defined Attributes
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY EGO_USER_DEFINED_ATTR_GROUP
 */



                          ----------------
                          -- Procedures --
                          ----------------

/*#
 * Processes User-Defined Attribute data for one object instance.
 * Parameters provide identifying data and metadata for an object
 * instance, along with an EGO_USER_ATTR_ROW_TABLE and an accompanying
 * EGO_USER_ATTR_DATA_TABLE (described above).  The procedure organizes
 * the data from the two tables and calls Process_Row for each distinct
 * attribute group row passing all the attribute data for that row.
 * Current version: 1.0
 *
 * @param p_api_version Pass the value listed as 'Current version' above.
 * @param p_object_name The name of the object to which this data applies
 *  (e.g., 'EGO_ITEM', 'PA_PROJECTS', etc.)
 * @param p_attributes_row_table Contains row-level data and metadata
 * about each attribute group being processed.  See above for details
 * about this data type.
 * @param p_attributes_data_table Contains data and metadata about each
 * attribute being processed.  See above for details about this data type.
 * @param p_pk_column_name_value_pairs Contains the Primary Key column
 * names and values that identify the specific object instance to which
 * this data applies.  See above for details about this data type.
 * @param p_class_code_name_value_pairs Contains the Classification Code(s)
 * for the specific object instance to which this data applies.  See
 * above for details about this data type, and see User-Defined Attributes
 * documentation for details about Classification Codes.
 * @param p_user_privileges_on_object Contains the list of privileges
 * granted to the current user on the specific object instance identified
 * by p_pk_column_name_value_pairs.  See above for details about this data
 * type.
 * @param p_entity_id Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_entity_index Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_entity_code Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_debug_level Used in debugging.  Valid values range from 0 (no
 * debugging) to 3 (full debugging).  The debug file is created in the
 * first directory in the list returned by the following query:
 * SELECT VALUE FROM V$PARAMETER WHERE NAME = 'utl_file_dir';
 * @param p_init_error_handler Indicates whether to initialize ERROR_HANDLER
 * message stack (and open debug session, if applicable)
 * @param p_write_to_concurrent_log Indicates whether to log ERROR_HANDLER
 * messages to concurrent log (only applicable when called from concurrent
 * program and when p_log_errors is passed as FND_API.G_TRUE).
 * @param p_init_fnd_msg_list Indicates whether to initialize FND_MSG_PUB
 * message stack.
 * @param p_log_errors Indicates whether to write ERROR_HANDLER message
 * stack to MTL_INTERFACE_ERRORS, the concurrent log (if applicable),
 * and the debug file (if applicable); if FND_API.G_FALSE is passed,
 * messages will still be added to ERROR_HANDLER's message stack, but
 * the message stack will not be written to any destination.
 * @param p_add_errors_to_fnd_stack Indicates whether messages written
 * to ERROR_HANDLER message stack will also be written to FND_MSG_PUB
 * message stack.
 * @param p_commit Indicates whether to commit work for all attribute
 * group rows that are processed successfully; if FND_API.G_FALSE is
 * passed, the API will not commit any work.
 * @param x_failed_row_id_list Returns a comma-delimited list of
 * ROW_IDENTIFIERs (the field in EGO_USER_ATTR_ROW_OBJ, which is
 * discussed above) indicating attribute group rows that failed
 * in processing.  An error will be logged for each failed row.
 * @param x_return_status Returns one of three values indicating the
 * most serious error encountered during processing:
 * FND_API.G_RET_STS_SUCCESS if no errors occurred,
 * FND_API.G_RET_STS_ERROR if at least one row encountered an error, and
 * FND_API.G_RET_STS_UNEXP_ERROR if at least one row encountered an
 * unexpected error.
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count Indicates how many messages exist on ERROR_HANDLER
 * message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on ERROR_HANDLER
 * message stack upon completion of processing, this parameter contains
 * that message.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process User-Defined Attributes Data
 */
PROCEDURE Process_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
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

/* Overload method with additional parameters x_extension_id, x_mode */

PROCEDURE Process_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
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
       ,x_extension_id                  OUT NOCOPY NUMBER
       ,x_mode                          OUT NOCOPY VARCHAR2
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


/*#
 * Retrieves requested User-Defined Attribute data for one object instance.
 * Parameters provide identifying data and metadata for an object instance,
 * as well as an EGO_ATTR_GROUP_REQUEST_TABLE (described above) specifying
 * the data to fetch.  The procedure fetches the requested data from the
 * database (transforming internal values to display values as necessary)
 * and returns it in the form of two tables: an EGO_USER_ATTR_ROW_TABLE and
 * a corresponding EGO_USER_ATTR_DATA_TABLE (both of which are described
 * above).
 * Current version: 1.0
 *
 * @param p_api_version Pass the value listed as 'Current version' above.
 * @param p_object_name The name of the object to which this data applies
 *  (e.g., 'EGO_ITEM', 'PA_PROJECTS', etc.)
 * @param p_pk_column_name_value_pairs Contains the Primary Key column
 * names and values that identify the specific object instance to which
 * this data applies.  See above for details about this data type.
 * @param p_attr_group_request_table Contains a list of elements, each
 * of which identifies an attribute group whose data to retrieve.  See
 * above for details about this data type.
 * @param p_user_privileges_on_object Contains the list of privileges
 * granted to the current user on the specific object instance identified
 * by p_pk_column_name_value_pairs.  See above for details about this data
 * type.
 * @param p_entity_id Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_entity_index Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_entity_code Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_debug_level Used in debugging.  Valid values range from 0 (no
 * debugging) to 3 (full debugging).  The debug file is created in the
 * first directory in the list returned by the following query:
 * SELECT VALUE FROM V$PARAMETER WHERE NAME = 'utl_file_dir';
 * @param p_init_error_handler Indicates whether to initialize ERROR_HANDLER
 * message stack (and open debug session, if applicable)
 * @param p_init_fnd_msg_list Indicates whether to initialize FND_MSG_PUB
 * message stack.
 * @param p_add_errors_to_fnd_stack Indicates whether messages written
 * to ERROR_HANDLER message stack will also be written to FND_MSG_PUB
 * message stack.
 * @param p_commit Indicates whether to commit work for all processing
 * done by the API (which is currently none, as this API does not alter
 * any database values); if FND_API.G_FALSE is passed, the API will not
 * commit any work.
 * @param x_attributes_row_table Contains row-level data and metadata
 * about each attribute group whose data is being returned.  See above
 * for details about this data type.
 * @param x_attributes_data_table Contains data and metadata about each
 * attribute whose data is being returned.  See above for details about
 * this data type.
 * @param x_return_status Returns one of three values indicating the
 * most serious error encountered during processing:
 * FND_API.G_RET_STS_SUCCESS if no errors occurred,
 * FND_API.G_RET_STS_ERROR if at least one error occurred, and
 * FND_API.G_RET_STS_UNEXP_ERROR if at least one unexpected error occurred.
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count Indicates how many messages exist on ERROR_HANDLER
 * message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on ERROR_HANDLER
 * message stack upon completion of processing, this parameter contains
 * that message.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get User-Defined Attributes Data
 */
PROCEDURE Get_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
       ,p_entity_id                     IN   VARCHAR2   DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_attributes_row_table          OUT NOCOPY EGO_USER_ATTR_ROW_TABLE
       ,x_attributes_data_table         OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);



/*#
 * Copies all User-Defined Attribute data from one object instance to
 * another object instance of the same type (e.g., from one EGO_ITEM to
 * another or one PA_PROJECTS to another).  Parameters provide
 * identifying data and metadata for a source object instance and
 * a destination object instance (referred to as "old" and "new",
 * respectively); the procedure then copies all attribute group rows
 * from the "old" instance (across all attribute group types) to
 * the "new" instance.
 * Current version: 1.0
 *
 * @param p_api_version Pass the value listed as 'Current version' above.
 * @param p_application_id The application ID of the attribute groups that
 * are to be copied (in other words, the first part of their composite key)
 * @param p_object_id The numeric identifier of the object of which the
 * source and destination object instances are examples (e.g., the numeric
 * ID for EGO_ITEM, PA_PROJECTS, etc.)
 * @param p_object_name The name of the object of which the source and
 * destination object instances are examples (e.g., 'EGO_ITEM',
 * 'PA_PROJECTS', etc.)
 * @param p_old_pk_col_value_pairs Contains the Primary Key column
 * names and values that identify the specific source object instance
 * whose data is to be copied.  See above for details about this data type.
 * @param p_old_data_level_id If the attribute group type supports multiple
 * data levels, pass the id of the data level from which you want to
 * copy information (eg.: If attribute group type is 'EGO_ITEMMGMT_GROUP'
 * and you want to copy values from a item level attribute group, pass 43101.
 * @param p_old_dtlevel_col_value_pairs If the attribute group type has data
 * levels defined and the source object instance contains any attribute
 * groups that are associated at a data level other than the highest level
 * defined for the attribute group type (e.g., if the attribute group type
 * is 'EGO_ITEMMGMT_GROUP' and the EGO_ITEM has at least one attribute
 * group associated at the ITEM_REVISION_LEVEL), then this will contain
 * data level column names and values up to and including those for the
 * lowest data level at which any attribute group is associated.  See above
 * for details about this data type.
 * @param p_new_pk_col_value_pairs As p_old_pk_col_value_pairs, except that
 * these values identify the destination object instance instead of the
 * source object instance.  See above for details about this data type.
 * @param p_new_data_level_id If the attribute group type supports multiple
 * data levels, pass the id of the data level to which you want to
 * copy information (eg.: If attribute group type is 'EGO_ITEMMGMT_GROUP'
 * and you want to copy values to a item revision level attribute group,
 * pass 43106.
 * @param p_new_dtlevel_col_value_pairs As p_old_dtlevel_col_value_pairs,
 * except that these values are for the destination object instance
 * instead of the source object instance.  See above for details about
 * this data type.
 * @p_new_cc_col_value_pairs Contains the Classification Code(s) for the
 * destination object instance.  See above for details about this data
 * type, and see User-Defined Attributes documentation for details about
 * Classification Codes.
 * @param p_init_error_handler Indicates whether to initialize ERROR_HANDLER
 * message stack.
 * @param p_init_fnd_msg_list Indicates whether to initialize FND_MSG_PUB
 * message stack.
 * @param p_add_errors_to_fnd_stack Indicates whether messages written
 * to ERROR_HANDLER message stack will also be written to FND_MSG_PUB
 * message stack.
 * @param p_commit Indicates whether to commit work if all attribute
 * group rows are copied successfully; if FND_API.G_FALSE is passed,
 * the API will not commit any work.
 * @param x_return_status Returns one of three values indicating the
 * most serious error encountered during processing:
 * FND_API.G_RET_STS_SUCCESS if no errors occurred,
 * FND_API.G_RET_STS_ERROR if at least one error occurred, and
 * FND_API.G_RET_STS_UNEXP_ERROR if at least one unexpected error occurred.
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count Indicates how many messages exist on ERROR_HANDLER
 * message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on ERROR_HANDLER
 * message stack upon completion of processing, then this parameter
 * contains that message.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Copy User-Defined Attributes Data
 */
PROCEDURE Copy_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_old_pk_col_value_pairs        IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_old_data_level_id             IN   NUMBER     DEFAULT NULL --bug 8941665
       ,p_old_dtlevel_col_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_new_pk_col_value_pairs        IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_new_data_level_id             IN   NUMBER     DEFAULT NULL --bug 8941665
       ,p_new_dtlevel_col_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_new_cc_col_value_pairs        IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

/*#
 * Validate_Required_Attrs validates data for one object instance by
 * checking which fields required fields does not have a value.
 * The procedure takes in a primary key object, the object name,
 * class code and data level information, as well as a list of
 * attribute group types on which object data should be
 * validated.
 * The procedure returns a table of user attribute object listing
 * required attributes for which the object does not have a value.
 * Current version: 1.0
 *
 * @param p_api_version Pass the value listed as 'Current version' above.
 * @param p_object_name The name of the object to which this data applies
 *  (e.g., 'EGO_ITEM', 'PA_PROJECTS', etc.)
 * @param p_pk_column_name_value_pairs Contains the Primary Key column
 * names and values that identify the specific object instance to which
 * this data applies.  See above for details about this data type.
 * @param p_class_code_name_value_pairs Contains the Classification Code(s)
 * for the specific object instance to which this data applies.  See
 * above for details about this data type, and see User-Defined Attributes
 * documentation for details about Classification Codes.
 * @param p_data_level_name_value_pairs Contains data level information
 * for the specific object instance to which this data applies.  See
 * above for details about this data type.
 * @param p_attr_group_type_table Contains a list of elements, each
 * of which identifies an attribute group type whose data to retrieve.
 * @param p_entity_id Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_entity_index Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_entity_code Used in error reporting.  See ERROR_HANDLER package
 * for details.
 * @param p_debug_level Used in debugging.  Valid values range from 0 (no
 * debugging) to 3 (full debugging).  The debug file is created in the
 * first directory in the list returned by the following query:
 * SELECT VALUE FROM V$PARAMETER WHERE NAME = 'utl_file_dir';
 * @param p_init_error_handler Indicates whether to initialize ERROR_HANDLER
 * message stack (and open debug session, if applicable)
 * @param p_write_to_concurrent_log Indicates whether to log ERROR_HANDLER
 * messages to concurrent log (only applicable when called from concurrent
 * program and when p_log_errors is passed as FND_API.G_TRUE).
 * @param p_init_fnd_msg_list Indicates whether to initialize FND_MSG_PUB
 * message stack.
 * @param p_log_errors Indicates whether to write ERROR_HANDLER message
 * stack to MTL_INTERFACE_ERRORS, the concurrent log (if applicable),
 * and the debug file (if applicable); if FND_API.G_FALSE is passed,
 * messages will still be added to ERROR_HANDLER's message stack, but
 * the message stack will not be written to any destination.
 * @param p_add_errors_to_fnd_stack Indicates whether messages written
 * to ERROR_HANDLER message stack will also be written to FND_MSG_PUB
 * message stack.
 * @param x_attributes_req_table Returns a table of user attribute
 * object listing required attributes for which the object does not
 *  have a value.
 * @param x_return_status Returns one of three values indicating the
 * most serious error encountered during processing:
 * FND_API.G_RET_STS_SUCCESS if no errors occurred
 * FND_API.G_RET_STS_ERROR if at least one error occurred
 * FND_API.G_RET_STS_UNEXP_ERROR if at least one unexpected error occurred
 * @param x_errorcode Reserved for future use.
 * @param x_msg_count Indicates how many messages exist on ERROR_HANDLER
 * message stack upon completion of processing.
 * @param x_msg_data If exactly one message exists on ERROR_HANDLER
 * message stack upon completion of processing, this parameter contains
 * that message.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Required Attributes
 */

PROCEDURE Validate_Required_Attrs (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
                                                     -- FND_OBJECTS.OBJECT_NAME
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
                                                 -- Attr values to be validated
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name               IN   EGO_DATA_LEVEL_B.DATA_LEVEL_NAME%TYPE := NULL
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_group_type_table         IN   EGO_VARCHAR_TBL_TYPE
                                -- FND_DESCRIPTIVE_FLEXS.APPLICATION_TABLE_NAME
       ,p_entity_id                     IN   NUMBER
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_debug_level                   IN   NUMBER
       ,p_init_error_handler            IN   VARCHAR2
       ,p_write_to_concurrent_log       IN   VARCHAR2
       ,p_init_fnd_msg_list             IN   VARCHAR2
       ,p_log_errors                    IN   VARCHAR2
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2
       ,x_attributes_req_table          OUT NOCOPY EGO_USER_ATTR_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);





/*#
 * Build_Attr_Group_Row_Table builds up the EGO_USER_ATTR_ROW_TABLE.
 * an instance of EGO_USER_ATTR_ROW_OBJ is built using the passed in
 * infomation and appended to the table here.
 * @param p_attr_group_row_table This is the table to which the row
 * object is added.
 * @param p_row_identifier Row identifier of the logical attribute
 * group row.
 * @param p_attr_group_id Attribute group id of the passed in attr group
 * row.
 * @param p_attr_group_app_id Application Id.
 * @param p_attr_group_type Attribute group type of the attr group row
 * being created.
 * @param p_attr_group_name Attribute group internal name.
 * @param p_data_level The data level internal name for which the attribute
 * group data is being processed.
 * @param p_data_level_1 The pk1 column value for the data level.
 * @param p_data_level_2 The pk2 column value for the data level.
 * @param p_data_level_3 The pk3 column value for the data level.
 * @param p_data_level_4 The pk4 column value for the data level.
 * @param p_data_level_5 The pk5 column value for the data level.
 * @param p_transaction_type Transaction type, i.e. 'SYNC'/'CREATE'/'UPDATE'/'DELETE'
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Build attribute group row table.
 */
FUNCTION Build_Attr_Group_Row_Table(  p_attr_group_row_table IN    EGO_USER_ATTR_ROW_TABLE
                                     ,p_row_identifier       IN    NUMBER
                                     ,p_attr_group_id        IN    NUMBER   DEFAULT NULL
                                     ,p_attr_group_app_id    IN    NUMBER
                                     ,p_attr_group_type      IN    VARCHAR2
                                     ,p_attr_group_name      IN    VARCHAR2
                                     ,p_data_level           IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_1         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_2         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_3         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_4         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_5         IN    VARCHAR2 DEFAULT NULL
                                     ,p_transaction_type     IN    VARCHAR2
                                     )
RETURN EGO_USER_ATTR_ROW_TABLE;

/*#
 * Build_Attr_Group_Row_Object builds and trturns an instance of
 * EGO_USER_ATTR_ROW_OBJ using the passed in infomation.
 * @param p_row_identifier Row identifier of the logical attribute
 * group row.
 * @param p_attr_group_id Attribute group id of the passed in attr group
 * row.
 * @param p_attr_group_app_id Application Id.
 * @param p_attr_group_type Attribute group type of the attr group row
 * being created.
 * @param p_attr_group_name Attribute group internal name.
 * @param p_data_level The data level internal name for which the attribute
 * group data is being processed.
 * @param p_data_level_1 The pk1 column value for the data level.
 * @param p_data_level_2 The pk2 column value for the data level.
 * @param p_data_level_3 The pk3 column value for the data level.
 * @param p_data_level_4 The pk4 column value for the data level.
 * @param p_data_level_5 The pk5 column value for the data level.
 * @param p_transaction_type Transaction type, i.e. 'SYNC'/'CREATE'/'UPDATE'/'DELETE'
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname build attr group row object.
 */

FUNCTION Build_Attr_Group_Row_Object( p_row_identifier       IN    NUMBER
                                     ,p_attr_group_id        IN    NUMBER   DEFAULT NULL
                                     ,p_attr_group_app_id    IN    NUMBER
                                     ,p_attr_group_type      IN    VARCHAR2
                                     ,p_attr_group_name      IN    VARCHAR2
                                     ,p_data_level           IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_1         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_2         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_3         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_4         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_5         IN    VARCHAR2 DEFAULT NULL
                                     ,p_transaction_type     IN    VARCHAR2
                                     )
RETURN EGO_USER_ATTR_ROW_OBJ;


/*#
 * Build_Attr_Group_Request_Table builds up the EGO_ATTR_GROUP_REQUEST_TABLE.
 * An instance of EGO_ATTR_GROUP_REQUEST_OBJ is built using the passed in
 * infomation and appended to the table here.
 * @param p_ag_req_table This is the table to which the row object is added.
 * @param p_attr_group_id Attribute group id for which the request object
 * is to be built.
 * @param p_application_id Application Id.
 * @param p_attr_group_type Attribute group type of the attribute group.
 * @param p_attr_group_name Attribute group internal name.
 * @param p_data_level The data level internal name for which the attribute
 * group request object is being built.
 * @param p_data_level_1 The pk1 column value for the data level.
 * @param p_data_level_2 The pk2 column value for the data level.
 * @param p_data_level_3 The pk3 column value for the data level.
 * @param p_data_level_4 The pk4 column value for the data level.
 * @param p_data_level_5 The pk5 column value for the data level.
 * @param p_attr_name_list Attribute name list.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname build attribute group request table.
 */

FUNCTION Build_Attr_Group_Request_Table( p_ag_req_table       IN   EGO_ATTR_GROUP_REQUEST_TABLE
                                        ,p_attr_group_id      IN   NUMBER   DEFAULT NULL
                                        ,p_application_id     IN   NUMBER
                                        ,p_attr_group_type    IN   VARCHAR2
                                        ,p_attr_group_name    IN   VARCHAR2
                                        ,p_data_level         IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_1       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_2       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_3       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_4       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_5       IN   VARCHAR2 DEFAULT NULL
                                        ,p_attr_name_list     IN   VARCHAR2 DEFAULT NULL
                                       )
RETURN EGO_ATTR_GROUP_REQUEST_TABLE;

/*#
 * Build_Attr_Group_Request_Obj creates and returns an instance of
 * EGO_ATTR_GROUP_REQUEST_OBJ using the passed in infomation.
 * @param p_attr_group_id Attribute group id for which the request object
 * is to be built.
 * @param p_application_id Application Id.
 * @param p_attr_group_type Attribute group type of the attribute group.
 * @param p_attr_group_name Attribute group internal name.
 * @param p_data_level The data level internal name for which the attribute
 * group request object is being built.
 * @param p_data_level_1 The pk1 column value for the data level.
 * @param p_data_level_2 The pk2 column value for the data level.
 * @param p_data_level_3 The pk3 column value for the data level.
 * @param p_data_level_4 The pk4 column value for the data level.
 * @param p_data_level_5 The pk5 column value for the data level.
 * @param p_attr_name_list Attribute name list.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname build attribute group request table.
 */
FUNCTION Build_Attr_Group_Request_Obj   (p_attr_group_id      IN   NUMBER   DEFAULT NULL
                                        ,p_application_id     IN   NUMBER
                                        ,p_attr_group_type    IN   VARCHAR2
                                        ,p_attr_group_name    IN   VARCHAR2
                                        ,p_data_level         IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_1       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_2       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_3       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_4       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_5       IN   VARCHAR2 DEFAULT NULL
                                        ,p_attr_name_list     IN   VARCHAR2 DEFAULT NULL
                                       )
RETURN EGO_ATTR_GROUP_REQUEST_OBJ;



END EGO_USER_ATTRS_DATA_PUB;


/
