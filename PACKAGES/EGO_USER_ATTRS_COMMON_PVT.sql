--------------------------------------------------------
--  DDL for Package EGO_USER_ATTRS_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_USER_ATTRS_COMMON_PVT" AUTHID DEFINER AS
/* $Header: EGOPEFCS.pls 120.5.12010000.2 2011/04/18 04:31:03 jewen ship $ */



--=======================================================================--
--=*********************************************************************=--
--=*===================================================================*=--
--=*=                                                                 =*=--
--=*=  NOTE: This is a PRIVATE package; it is for internal use only,  =*=--
--=*=  and it is not supported for customer use.                      =*=--
--=*=                                                                 =*=--
--=*===================================================================*=--
--=*********************************************************************=--
--=======================================================================--

                       ----------------------
                       -- Global Variables --
                       ----------------------

    -------------------------------------------------------------------------------
    -- The Date Format is chosen to be as close as possible to Timestamp format, --
    -- except that we support dates before zero A.D. (the "S" in the year part). --
    -------------------------------------------------------------------------------
    G_DATE_FORMAT                            CONSTANT VARCHAR2(30) := 'SYYYY-MM-DD HH24:MI:SS';

    --4105841 Business Event Enhancement
    G_SUBSCRIPTION_EXC                       EXCEPTION; --Subscription Exception defined

               --------------------------------------
               -- Caching Procedures and Functions --
               --------------------------------------

PROCEDURE Reset_Cache_And_Globals;




FUNCTION Get_Attr_Group_Metadata (
        p_attr_group_id                 IN   NUMBER     DEFAULT NULL
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_pick_from_cache               IN   BOOLEAN    DEFAULT TRUE
)
RETURN EGO_ATTR_GROUP_METADATA_OBJ;



FUNCTION Get_Ext_Table_Metadata (
        p_object_id                     IN   NUMBER
)
RETURN EGO_EXT_TABLE_METADATA_OBJ;



FUNCTION Find_Metadata_For_Attr (
        p_attr_metadata_table           IN   EGO_ATTR_METADATA_TABLE
       ,p_attr_name                     IN   VARCHAR2   DEFAULT NULL
       ,p_attr_id                       IN   NUMBER     DEFAULT NULL
       ,p_db_column_name                IN   VARCHAR2   DEFAULT NULL
)
RETURN EGO_ATTR_METADATA_OBJ;


        ---------------------------------------------------
        -- Miscellaneous Common Procedures and Functions --
        ---------------------------------------------------

/*
 * Get_List_For_Table_Cols
 * -----------------------
 */
FUNCTION Get_List_For_Table_Cols (
        p_col_metadata_array            IN   EGO_COL_METADATA_ARRAY
       ,p_col_name_value_pairs          IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_mode                          IN   VARCHAR2
       ,p_use_binds                     IN   BOOLEAN    DEFAULT FALSE
       ,p_prefix                        IN   VARCHAR2   DEFAULT NULL
)
RETURN VARCHAR2;



FUNCTION Create_DB_Col_Alias_If_Needed (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
) RETURN VARCHAR2;

/*
* Bug:11854366
* Description:This function return database column alias with the table or view alias
*/
FUNCTION Create_DB_Col_Alias_If_Needed (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
        ,table_view_alias               IN   VARCHAR2
) RETURN VARCHAR2;

/*FUNCTION Is_EGO_Installed (
        p_api_version  IN NUMBER
       ,p_release_version IN VARCHAR2
) RETURN VARCHAR2;*/


/*
 * Method to get sql query (partial) to be used in another sql to get values from a value set
 */
PROCEDURE Build_Sql_Queries_For_Value (
        p_value_set_id                  IN   NUMBER
       ,p_validation_code               IN   VARCHAR2
       ,px_attr_group_metadata_obj      IN OUT NOCOPY EGO_ATTR_GROUP_METADATA_OBJ
       ,px_attr_metadata_obj            IN OUT NOCOPY EGO_ATTR_METADATA_OBJ
);
--bug 5094087
-------------------------------------------------------------------------------------
--  API Name: Get_User_Pref_Date_Time_Val                                          --
--                                                                                 --
--  Description:This Function retruns the Formatted Date or Date Time Value        --
--  depending  on the type of the Attribute Passed in and the Value passed in     --
--  Parameters: The Value of date or DateTime and the Attribute Type with X for   --
--  Date  Type or Y for Date_time Type                                             --
-------------------------------------------------------------------------------------
FUNCTION Get_User_Pref_Date_Time_Val (
                                     p_date           IN DATE
                                    ,p_attr_type      IN VARCHAR2
                                    ,x_return_status  OUT NOCOPY VARCHAR2
                                    ,x_msg_count      OUT NOCOPY NUMBER
                                    ,x_msg_data       OUT NOCOPY VARCHAR2
                                    ) RETURN VARCHAR2;

FUNCTION Get_Data_Levels_For_AGType ( p_application_id   IN  NUMBER
                                     ,p_attr_group_type  IN  VARCHAR2
				    )
  RETURN EGO_DATA_LEVEL_METADATA_TABLE;

FUNCTION Get_Data_Level_Metadata (p_data_level_id IN  NUMBER)
  RETURN EGO_DATA_LEVEL_METADATA_OBJ;

FUNCTION Get_Enabled_Data_Levels_For_AG (p_attr_group_id IN NUMBER)
RETURN EGO_DATA_LEVEL_TABLE;

FUNCTION Get_Data_Level_Col_Array( p_application_id  IN  NUMBER
                                  ,p_attr_group_type IN VARCHAR2)
RETURN EGO_COL_METADATA_ARRAY;

FUNCTION Get_All_Data_Level_PK_Names ( p_application_id  IN  NUMBER
                                      ,p_attr_group_type IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION HAS_COLUMN_IN_TABLE (p_table_name  IN  VARCHAR2
                             ,p_column_name IN  VARCHAR2
                             )
RETURN VARCHAR2;

END EGO_USER_ATTRS_COMMON_PVT;


/
