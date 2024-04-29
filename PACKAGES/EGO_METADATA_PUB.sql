--------------------------------------------------------
--  DDL for Package EGO_METADATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_METADATA_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOPMDPS.pls 120.0.12010000.1 2010/04/15 12:28:38 kjonnala noship $ */

------------------------------------------------------------------------------------
--  Declaration of collection records and table types used for AG metadata import --
------------------------------------------------------------------------------------

  /*  Associated Table type for Attribute Groups Interface table */
  TYPE ego_attr_groups_tbl
    IS TABLE OF ego_attr_groups_interface%ROWTYPE INDEX BY BINARY_INTEGER;

  /*  Associated Table type for Attribute Group Data Levels Interface table*/
  TYPE ego_attr_groups_dl_tbl
    IS TABLE OF ego_attr_groups_dl_interface%ROWTYPE INDEX BY BINARY_INTEGER;

  /*  Associated Table type for Attribute Groups Columns (i.e.) Attributes  Interface table*/
  TYPE ego_attr_group_cols_tbl
    IS TABLE OF ego_attr_group_cols_intf%ROWTYPE INDEX BY BINARY_INTEGER;


------------------------------------------------------------------------------------
--  Declaration of collection records and table types used for VS metadata import --
------------------------------------------------------------------------------------

  /*  Associated Table type for Value Sets Interface table*/
  TYPE Value_Set_Tbl
    IS TABLE OF EGO_FLEX_VALUE_SET_INTF%ROWTYPE INDEX BY BINARY_INTEGER;

  /*  Associated Table type for Values Interface table*/
  TYPE Value_Set_Value_Tbl
    IS TABLE OF EGO_FLEX_VALUE_INTF%ROWTYPE INDEX BY BINARY_INTEGER;

  /*  Associated Table type for Translatable Values Interface table*/
  TYPE Value_Set_Value_Tl_Tbl
    IS TABLE OF EGO_FLEX_VALUE_Tl_INTF%ROWTYPE INDEX BY BINARY_INTEGER;


------------------------------------------------------------------------------------
-- Declaration of collection records and table types used for ICC metadata import --
------------------------------------------------------------------------------------
  /*  Associated Record type for ICC Interface table*/
  SUBTYPE ego_icc_rec_type
    IS MTL_ITEM_CAT_GRPS_INTERFACE%ROWTYPE;

  /*  Associated Record type for AG associations (to ICC ) Interface table*/
  SUBTYPE ego_ag_assoc_rec_type
    IS EGO_ATTR_GRPS_ASSOC_INTERFACE%ROWTYPE;

  /*  Associated Record type for function parameter mappings ( to ICC ) Interface table*/
  SUBTYPE ego_func_param_map_rec_type
    IS EGO_FUNC_PARAMS_MAP_INTERFACE%ROWTYPE;

   /*  Associated Record type for ICC versions Interface table*/
  SUBTYPE ego_icc_vers_rec_type
    IS EGO_ICC_VERS_INTERFACE%ROWTYPE;


  /*  Associated Table type for ICC Interface table*/
  TYPE ego_icc_tbl_type
    IS TABLE OF MTL_ITEM_CAT_GRPS_INTERFACE%ROWTYPE INDEX BY BINARY_INTEGER;

  /*  Associated Table type for AG associations (to ICC ) Interface table*/
  TYPE ego_ag_assoc_tbl_type
    IS TABLE OF EGO_ATTR_GRPS_ASSOC_INTERFACE%ROWTYPE INDEX BY BINARY_INTEGER;

  /*  Associated Table type for function parameter mappings ( to ICC ) Interface table*/
  TYPE ego_func_param_map_tbl_type
    IS TABLE OF EGO_FUNC_PARAMS_MAP_INTERFACE%ROWTYPE INDEX BY BINARY_INTEGER;

  /*  Associated Table type for ICC versions Interface table*/
  TYPE ego_icc_vers_tbl_type
    IS TABLE OF EGO_ICC_VERS_INTERFACE%ROWTYPE INDEX BY BINARY_INTEGER;

  /*  Associated Table type for Functions Interface table*/
  TYPE ego_function_tbl_type
    IS TABLE OF ego_functions_interface%ROWTYPE INDEX BY BINARY_INTEGER;

  /*  Associated Table type for Function Parameters Interface table*/
  TYPE ego_func_param_tbl_type
    IS TABLE OF ego_func_params_interface%ROWTYPE INDEX BY BINARY_INTEGER;

  /*  Associated Table type for Transaction Attributes Interface table*/
  TYPE TA_Intf_Tbl
    IS TABLE OF ego_trans_attrs_vers_intf%ROWTYPE INDEX BY BINARY_INTEGER;

  /*  Associated Table type for Pages Interface table*/
  TYPE ego_pg_tbl
    IS TABLE OF ego_pages_interface%ROWTYPE INDEX BY BINARY_INTEGER;

  /* Associated Table type for Page Entries Interface table*/
  TYPE ego_ent_tbl
    IS TABLE OF ego_page_entries_interface%ROWTYPE INDEX BY BINARY_INTEGER;

  /* Currently, we are NOT supporting Public bulkload APIs for Metadata.
     Hence commenting the below procedures.
     For single record public APIs for metadata, please refer to EGO_EXT_FWK_PUB and EGO_ITEM_CATALOG_PUB packages.
  */
  /*Public Procedures
  -- Main procedure for API processing. Takes care of AGs and its associated DL Called by Public API.
  PROCEDURE process_attribute_group(
    p_ag_tbl        IN OUT NOCOPY ego_attr_groups_tbl,
    p_agdl_tbl      IN OUT NOCOPY ego_attr_groups_dl_tbl,
    p_commit        IN BOOLEAN DEFAULT false,
    x_return_status OUT VARCHAR2,
    x_return_msg    OUT VARCHAR2);

  --Main procedure for Attributes processing through API
  PROCEDURE process_attribute(
    p_attr_tbl      IN OUT NOCOPY ego_attr_group_cols_tbl,
    p_commit        IN BOOLEAN DEFAULT false,
    x_return_status OUT VARCHAR2,
    x_return_msg    OUT VARCHAR2);

  --Main procedure for API processing. Takes care of Pages and is called by Public API.
  PROCEDURE process_pages(
    p_pg_tbl        IN OUT NOCOPY ego_pg_tbl,
    p_commit        IN BOOLEAN DEFAULT false,
    x_return_status OUT VARCHAR2,
    x_return_msg    OUT VARCHAR2);

  --Main procedure for Page Entries processing through API
  PROCEDURE process_pg_entries(
    p_ent_tbl       IN OUT NOCOPY ego_ent_tbl,
    p_commit        IN BOOLEAN DEFAULT false,
    x_return_status OUT VARCHAR2,
    x_return_msg    OUT VARCHAR2);

*/
END EGO_METADATA_PUB;

/
