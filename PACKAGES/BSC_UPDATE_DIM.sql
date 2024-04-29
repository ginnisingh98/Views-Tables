--------------------------------------------------------
--  DDL for Package BSC_UPDATE_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPDATE_DIM" AUTHID CURRENT_USER AS
/* $Header: BSCDDIMS.pls 120.1 2005/12/16 11:03:49 meastmon noship $ */

-- Global constants

DIM_TABLE_TYPE_1N 	CONSTANT NUMBER := 1;
DIM_TABLE_TYPE_MN 	CONSTANT NUMBER := 2;
DIM_TABLE_TYPE_UNKNOWN 	CONSTANT NUMBER := 3;


-- Global array to store information regarding DBI Dimensions Levels
TYPE t_dbi_dim_data IS RECORD (
    short_name        VARCHAR2(30),
    table_name	      VARCHAR2(30),
    from_clause       VARCHAR2(4000),
    where_clause      VARCHAR2(10000),
    recursive_dim     VARCHAR2(20),
    date_tracked_dim  VARCHAR2(20),
    source_object     VARCHAR2(20000),
    source_object_alias     VARCHAR2(30),
    materialized      VARCHAR2(30),--'YES' means create/load table. 'NO' means do not create/load table
    user_code_col     VARCHAR2(30),
    code_col          VARCHAR2(30),
    parent1_col       VARCHAR2(30),
    parent2_col       VARCHAR2(30),
    parent3_col       VARCHAR2(30),
    parent4_col       VARCHAR2(30),
    parent5_col       VARCHAR2(30),
    -------for recursive dims
    child_col VARCHAR2(30), --the name of the child col in denorm table data type is varchar2(400)
    parent_col VARCHAR2(30),--the name of the parent col in denorm table datatype is varchar2(400)
    parent_level_col VARCHAR2(30),  --datatype is varchar2(40)
    denorm_table VARCHAR2(30),--the denorm table that the MV will use
    top_n_levels number,--number of levels from the top to materialize(denormalize)
    top_n_levels_in_mv number,--top n levels that are in the mv
    --
    child_col_src VARCHAR2(30),--the src column for the child col
    parent_col_src VARCHAR2(30),--the src col for the parent col
    parent_level_src_col VARCHAR2(30),--if not null, this col holds the col
                                      --from the src table that contains the parent level info
    denorm_src_object VARCHAR2(30),
    -------------------------
    source_to_check VARCHAR2(4000), -- List of tables (i.e DBIDIM_TABLE1,DBIDIM_TABLE2) to check last_update_date
                                    -- before refreshing base table
    denorm_source_to_check VARCHAR2(4000) -- List of tables (i.e DBIDIM_TABLE1,DBIDIM_TABLE2) to check last_update_date
                                          -- before refreshing denorm table
);

TYPE t_array_dbi_dim_data IS TABLE OF t_dbi_dim_data
    INDEX BY BINARY_INTEGER;

g_dbi_dim_data          t_array_dbi_dim_data;
g_dbi_dim_data_set      BOOLEAN := FALSE;
g_dbi_dim_tables_set    BOOLEAN := FALSE;

--
-- Procedures and Functions
--
/*===========================================================================+
|
|   Name:          Any_Item_Changed_Any_Relation
|
|   Description:   This function returns TRUE if any item in the dimension
|                  changed any of the relation values.
|                  x_temp_table is the name of a temporal table which contains
|                  the previous dimension items.
|                  x_dimension_table has the current dimensions items.
|
|
|   Notes:
|
+============================================================================*/
FUNCTION Any_Item_Changed_Any_Relation(
	x_dimension_table IN VARCHAR2,
        x_temp_table IN VARCHAR2,
        x_relation_cols IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_relation_cols IN NUMBER
        ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Create_Dbi_Dim_Tables
|
|   Description:   This function creates the tables in BSC for the DBI
|                  dimensions. It creates the mv log too.
|
|   Notes:
|
+============================================================================*/
FUNCTION Create_Dbi_Dim_Tables(
	x_error_msg IN OUT NOCOPY VARCHAR2
        ) RETURN BOOLEAN;


--AW_INTEGRATION: New function
/*===========================================================================+
|
|   Name:          Create_AW_Dim_Temp_Tables
|
|   Description:   This function creates global temporary tables
|                  needed for the AW dimension processing
|                  Returns FALSE in case of error.
|
|   Notes:
|
+============================================================================*/
FUNCTION Create_AW_Dim_Temp_Tables RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Create_AW_Dim_Temp_Tables_AT RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Create_Dbi_Dim_Temp_Tables
|
|   Description:   This function creates global temporary tables
|                  needed for the process of refreshing the dbi dim tables
|                  Returns FALSE in case of error.
|
|   Notes:
|
+============================================================================*/
FUNCTION Create_Dbi_Dim_Temp_Tables RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Delete_Codes_Cascade
|
|   Description:   This function deletes in cascade the codes from the
|                  dimension table
|                  Returns FALSE in case of error.
|
|   Notes:
|
+============================================================================*/
FUNCTION Delete_Codes_Cascade(
	x_dim_table IN VARCHAR2,
	x_deleted_codes IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_deleted_codes IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Delete_Codes_CascadeMN
|
|   Description:   This function deletes in cascade the codes from the
|                  MN dimension table
|                  Returns FALSE in case of error.
|
|   Notes:
|
+============================================================================*/
FUNCTION Delete_Codes_CascadeMN(
	x_dim_table IN VARCHAR2,
	x_key_column1 IN VARCHAR2,
	x_key_column2 IN VARCHAR2,
	x_deleted_codes1 IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_deleted_codes2 IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_deleted_codes IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Delete_Key_Values_In_Tables
|
|   Description:   This function deletes from system tables containig the given
|                  level pk column, the rows for the given condition.
|                  Returns FALSE in case of error.
|
|   Notes:
|
+============================================================================*/
FUNCTION Delete_Key_Values_In_Tables(
	x_level_pk_col IN VARCHAR2,
        x_condition IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Denorm_Eni_Item_Vbh_Cat
|
|   Description:   Refreshes the denormalized table for the dbi recursive
|                  dimension ENI_ITEM_VBH_CAT
|
|   Notes:
|
+============================================================================*/
FUNCTION Denorm_Eni_Item_Vbh_Cat RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Denorm_Eni_Item_Itm_Cat
|
|   Description:   Refreshes the denormalized table for the dbi recursive
|                  dimension ENI_ITEM_ITM_CAT
|
|   Notes:
|
+============================================================================*/
FUNCTION Denorm_Eni_Item_Itm_Cat RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Denorm_Hri_Per_Usrdr_H
|
|   Description:   Refreshes the denormalized table for the dbi recursive
|                  dimension HRI_PER_USRDR_H
|
|   Notes:
|
+============================================================================*/
FUNCTION Denorm_Hri_Per_Usrdr_H RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Denorm_Pji_Organizations
|
|   Description:   Refreshes the denormalized table for the dbi recursive
|                  dimension PJI_ORGANIZATIONS
|
|   Notes:
|
+============================================================================*/
FUNCTION Denorm_Pji_Organizations RETURN BOOLEAN;


--AW_INTEGRATION: New function
/*===========================================================================+
|
|   Name:          Dimension_Used_In_AW_Kpi
|
|   Description:   Return TRUE if the given dimension table is used by any AW
|                  indicator
|
|   Notes:
|
+============================================================================*/
FUNCTION Dimension_Used_In_AW_Kpi(
	x_dim_table IN VARCHAR2
	) RETURN BOOLEAN;


--RECURSIVE_DIMS: New function
/*===========================================================================+
|
|   Name:          Dimension_Used_In_MV_Kpi
|
|   Description:   Return TRUE if the given dimension table is used by any AW
|                  indicator
|
|   Notes:
|
+============================================================================*/
FUNCTION Dimension_Used_In_MV_Kpi(
	x_dim_table IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_All_Dbi_Dim_Data
|
|   Description:   This procedure returns in x_dbi_dim_data the info
|                  of all the dbi dimensions.
|
|   Notes:
|
+============================================================================*/
PROCEDURE Get_All_Dbi_Dim_Data(
    x_dbi_dim_data OUT NOCOPY BSC_UPDATE_DIM.t_array_dbi_dim_data
);


/*===========================================================================+
|
|   Name:          Get_Aux_Fields_Dim_Table
|
|   Description:   This function returns in the array x_aux_fields the aux
|                  fields of the dimension table. Return the number of them.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Aux_Fields_Dim_Table(
	x_dim_table IN VARCHAR2,
        x_aux_fields IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Child_Dimensions
|
|   Description:   This function fill the array x_child_dimensions with the name
|                  of the child dimensions for the given dimension table and return
|                  the number of them.
|
|   Parameters:
|
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Child_Dimensions(
	x_dimension_table IN VARCHAR2,
        x_child_dimensions IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Dbi_Dim_Parent_Columns
|
|   Description:   This function gets into the array x_parent_columns the name
|                  of the key columns of the parents of the given DBI dimension.
|                  It does not consider recursive parents (a dimension parent of itself).
|                  This function returns the number of parents.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Dbi_Dim_Parent_Columns(
        x_dim_short_name IN VARCHAR2,
        x_parent_columns IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_src_parent_columns IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
        ) RETURN NUMBER;


/*===========================================================================+
| FUNCTION Get_Dbi_Dim_View_Name
+============================================================================*/
FUNCTION Get_Dbi_Dim_View_Name(
    x_dim_short_name IN VARCHAR2
) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_Dbi_Dim_Data
|
|   Description:   This function gets into the record x_dbi_dim_data all the
|                  information regarding the dbi dimension.
|
+============================================================================*/
PROCEDURE Get_Dbi_Dim_Data(
        x_dim_short_name IN VARCHAR2,
        x_dbi_dim_data OUT NOCOPY BSC_UPDATE_DIM.t_dbi_dim_data
        );


/*===========================================================================+
|
|   Name:          Get_Dbi_Dims_Kpis
|
|   Description:   This function gets into the array x_dbi_dimensions the
|                  short name of the DBI dimensions used by the
|                  given indicators.
|
+============================================================================*/
FUNCTION Get_Dbi_Dims_Kpis(
	x_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_indicators IN NUMBER,
        x_dbi_dimensions IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_dbi_dimensions IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Deleted_Records
|
|   Description:   This function returns in the array x_deleted_records the codes
|                  of the deleted dimension items.
|                  x_temp_table is the name of a temporal table which contains
|                  the previous dimension items.
|                  x_dimension_table has the current dimensions items.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Deleted_Records(
        x_dimension_table IN VARCHAR2,
        x_temp_table IN VARCHAR2,
        x_deleted_records IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number
        ) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Dim_Table_of_Input_Table
|
|   Description:   This function returns the dimension table corresponding
|                  to the given input table
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Dim_Table_of_Input_Table(
	x_input_table IN VARCHAR2
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_Dim_Table_Type
|
|   Description:   This function returns the dimension type: MN or 1N
|                  of the given dimension table
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Dim_Table_Type(
	x_dim_table IN VARCHAR2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Info_Parents_Dimensions
|
|   Description:   This function returns in the array x_parent_tables the
|                  table name of each parent of the dimension table. Also,
|                  in the array x_parent_keys retunrs the pk column name of
|                  the parents. Return the number of parents.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Info_Parents_Dimensions(
	x_dim_table IN VARCHAR2,
        x_parent_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_parent_keys IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Level_PK_Col
|
|   Description:   This function returns the name of the pk columns for the
|                  given dimension table.
|
|   Parameters:
|
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Level_PK_Col(
        x_dimension_table IN VARCHAR2
        ) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_New_Code
|
|   Description:   This function next available code from the dimension table.
|                  Returns -1 in case of error.
|
|   Parameters:
|
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_New_Code(
	x_dim_table IN VARCHAR2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Parent_Dimensions
|
|   Description:   This function fill the array x_parent_dimensions with the name
|                  of the parent dimensions fo the given dimension table and return
|                  the number of them.
|
|   Parameters:
|
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Parent_Dimensions(
	x_dimension_table IN VARCHAR2,
        x_parent_dimensions IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Relation_Cols
|
|   Description:   This function fill the array x_relation_cols with the name
|                  of the relatin columns for the given dimension table and return
|                  the number of them.
|
|   Parameters:
|
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Relation_Cols(
        x_dimension_table IN VARCHAR2,
        x_relation_cols IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
        ) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Import_Dbi_Plans
|
|   Description:   This functions bring dbi plans into bsc benchhmarks
|                  in a incremental way.
+============================================================================*/
FUNCTION Import_Dbi_Plans(
    x_error_msg IN OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

--LOCKING: New function
FUNCTION Import_Dbi_Plans_AT(
    x_error_msg IN OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Init_Dbi_Dim_Data
|
|   Description:   This procedure initializes the global array
|                  g_dbi_dim_data with the complete list of DBI
|                  dimensions and its properties.
|
|   Parameters:
|
|   Notes:
|
+============================================================================*/
PROCEDURE Init_Dbi_Dim_Data;


/*===========================================================================+
|
|   Name:          Insert_Children_Denorm_Table
|
|   Description:   This procedure inserts into the denorm table
|                  all the children of the ids given in x_ids
|
|   Parameters:
|
|   Notes:
|
+============================================================================*/
FUNCTION Insert_Children_Denorm_Table(
    x_parent_id IN number,
    x_ids IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_ids IN NUMBER,
    x_level IN NUMBER,
    x_denorm_table IN VARCHAR2,
    x_child_col IN VARCHAR2,
    x_parent_col IN VARCHAR2,
    x_parent_level_col IN VARCHAR2,
    x_denorm_src_object IN VARCHAR2,
    x_child_col_src IN VARCHAR2,
    x_parent_col_src IN VARCHAR2,
    x_src_condition IN VARCHAR2
) RETURN BOOLEAN;


--RECURSIVE_DIMS: New function
/*===========================================================================+
| FUNCTION Is_Recursive_Dim
+============================================================================*/
FUNCTION Is_Recursive_Dim(
	x_dim_table IN VARCHAR2
	) RETURN BOOLEAN;


--AW_INTEGRATION: New procedure
/*===========================================================================+
|
|   Name:          Insert_AW_Delete_Value
|
|   Description:   This procedure inserts (x_dim_table, x_delete_value) into
|                 table bsc_aw_dim_delete.
|
|   Parameters:
|
|
|   Notes:
|
+============================================================================*/
PROCEDURE Insert_AW_Delete_Value(
    x_dim_table IN VARCHAR2,
    x_delete_value IN VARCHAR2
);


--LOCKING: new procedure
/*===========================================================================+
| PROCEDURE Load_Dim_Into_AW_AT
+============================================================================*/
PROCEDURE Load_Dim_Into_AW_AT (
    x_dim_table IN VARCHAR2
);


/*===========================================================================+
|
|   Name:          Load_Dim_Table
|
|   Description:   This function load the dimension table fromthe input table
|                  Return FALSE in case of error.
|
|   Parameters:
|
|
|   Notes:
|
+============================================================================*/
FUNCTION Load_Dim_Table(
	x_dim_table IN VARCHAR2,
        x_input_table IN VARCHAR2
	) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Load_Dim_Table_AT(
	x_dim_table IN VARCHAR2,
        x_input_table IN VARCHAR2
	) RETURN BOOLEAN;


--LOCKING: new procedure
/*===========================================================================+
|
|   Name:          Load_Type_Into_AW_AT
|
|   Description:   This function load TYPE dimension into AW.
|                  This is an Autonomous Transaction for Locking
|
+============================================================================*/
PROCEDURE Load_Type_Into_AW_AT;


/*===========================================================================+
|
|   Name:          Need_Refresh_Dbi_Table
|
|   Description:   This function compare the last update date of the table with
|                  maximum last update date of the source objects to decide
|                  if the table needs to be refreshed or not.
|
+============================================================================*/
FUNCTION Need_Refresh_Dbi_Table(
    x_table_name IN VARCHAR2,
    x_source_to_check IN VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Refresh_Dbi_Dimension_Table
|
|   Description:   This function refreshes the table created in BSC to materialize
|                  the view of the given DBI dimension short name.
|
|   Returns:       If some error occurr this function returns FALSE
|
|   Notes:
|
+============================================================================*/
FUNCTION Refresh_Dbi_Dimension_Table(
        x_dim_short_name IN VARCHAR2
) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Refresh_Dbi_Dimension_Table_AT(
        x_dim_short_name IN VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Refresh_Dbi_Dimension
|
|   Description:   This procedure is the executable for the concurrent program
|                  to refresh the table created in BSC to materialize
|                  the view of the given DBI dimension short name.
|
+============================================================================*/
PROCEDURE Refresh_Dbi_Dimension(
    ERRBUF OUT NOCOPY VARCHAR2,
    RETCODE OUT NOCOPY VARCHAR2,
    x_dim_short_name IN VARCHAR2
);


-- RECURSIVE_DIMS: new function
/*===========================================================================+
| FUNCTION Refresh_Denorm_Table
+============================================================================*/
FUNCTION Refresh_Denorm_Table(
    x_level_table_name IN VARCHAR2,
    x_denorm_table_name IN VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Refresh_EDW_Dimension
|
|   Description:   This function refresh the given EDW dimension and its childs
|                  and parents.
|                  For deleted dimension values, it deletes records in B,S tables.
|                  Add to the array x_modified_dimensions the modified dimensions
|                  (items deleted or item whose parent was changed)
|                  Add to the array x_checked_dimensions to avoid refrsh a dimesion
|                  several times.
|
|   Parameters:
|
|   Returns:       If some error occurr this function returns FALSE
|
|   Notes:
|
+============================================================================*/
FUNCTION Refresh_EDW_Dimension(
        x_dimension_table IN VARCHAR2,
	x_mod_dimensions IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_mod_dimensions IN OUT NOCOPY NUMBER,
	x_checked_dimensions IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_checked_dimensions IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Refresh_EDW_Dimensions
|
|   Description:   This function refresh the given EDW dimensions and its childs.
|                  For deleted dimension values, it deletes records in B,S tables.
|                  Check Kpis using any modified dimension to be recalculated.
|                  Also synchronize sec assigments.
|
|   Parameters:
|
|   Returns:       If some error occurr this function returns FALSE
|
|   Notes:
|
+============================================================================*/
FUNCTION Refresh_EDW_Dimensions(
	x_dimension_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_dimension_tables IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Sync_Sec_Assigments
|
|   Description:   Syncronize security assigments
|                  Delete from BSC_USER_LIST_ACCESS the records which dimension
|                  value does not exist in the dimension table.
|
|   Parameters:
|
|   Returns:       If some error occurr this function returns FALSE
|
|   Notes:
|
+============================================================================*/
FUNCTION Sync_Sec_Assigments RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Validate_Input_Table
|
|   Description:   Validate data of the dimension input table.
|                  If there are invalid codes then insert them into
|                  bsc_db_validation table.
|
|   Parameters:	   x_input_table   - input table name
|
|   Returns: 	   TRUE 	- input table doesn't have invalid codes
|                  FALSE	- input table has invalid codes
|		   NULL		- there was some error in the function. In
|                                 this case this function add the error
|                                 message in the error stack.
|
|   Notes:
|
+============================================================================*/
FUNCTION Validate_Input_Table(
	x_input_table IN VARCHAR2,
        x_dim_table IN VARCHAR2
	) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Validate_Input_Table_AT(
	x_input_table IN VARCHAR2,
        x_dim_table IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          WriteRemovedKeyItems
|
|   Description:   Write in the output file the kpis which default key values
|                  were removed from the dimension table.
|                  Return FALSE in case of error.
|
|   Notes:
|
+============================================================================*/
FUNCTION WriteRemovedKeyItems RETURN BOOLEAN;


procedure write_to_log_file(p_message varchar2);
procedure write_to_log_file_n(p_message varchar2);

END BSC_UPDATE_DIM;

 

/
