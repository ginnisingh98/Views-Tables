--------------------------------------------------------
--  DDL for Package EGO_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_IMPORT_PVT" AUTHID DEFINER AS
/* $Header: EGOVIMPS.pls 120.42 2007/10/05 15:12:06 dsakalle ship $ */

    SUBTYPE FLAG IS VARCHAR2( 1 );

    G_TEXT_DATA_TYPE          CONSTANT FLAG := 'T';
    G_NUMBER_DATA_TYPE        CONSTANT FLAG := 'N';
    G_DATE_DATA_TYPE          CONSTANT FLAG := 'D';

    G_UNPROC_PROC_STATUS      CONSTANT FLAG := 'U';
    G_READY_PROC_STATUS       CONSTANT FLAG := 'R';
    G_IMPORTED_PROC_STATUS    CONSTANT FLAG := 'I';

    G_PDH_SOURCE_SYSTEM_ID    CONSTANT        NUMBER     := 7;

    G_CONF_XREF               CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'CC';
    G_CONF_XREF_READY         CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'CCR';
    G_CONF_XREF_NOT_READY     CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'CCN';
    G_CONF_XREF_FAKE          CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'CFC';

    G_CONF_MATCH              CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'CM';
    G_CONF_MATCH_READY        CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'CMR';
    G_CONF_MATCH_NOT_READY    CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'CMN';
    G_CONF_MATCH_FAKE         CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'CFM';
    G_FAKE_MATCH_READY        CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'FMR';

    G_CONF_NEW                CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'CN';
    G_CONF_NEW_READY          CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'CNR';
    G_CONF_NEW_NOT_READY      CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'CNN';

    G_UNCONF_NONE_MATCH       CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'UN';
    G_UNCONF_SIGL_MATCH       CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'US';
    G_UNCONF_MULT_MATCH       CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'UM';

    G_UNCONF_NO_MATCH_FAKE     CONSTANT       MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'UFN';
    G_UNCONF_SINGLE_MATCH_FAKE CONSTANT       MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'UFS';
    G_UNCONF_MULTI_MATCH_FAKE  CONSTANT       MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'UFM';
    G_FAKE_CONF_STATUS_FLAG    CONSTANT       MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'FK';

    G_EXCLUDED                CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'EX';
    G_FAKE_EXCLUDED           CONSTANT        MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE := 'FEX';

    G_UNCONF_ACTION           CONSTANT        VARCHAR2(2) := 'UA';
    G_UNEXCLUDE_ACTION        CONSTANT        VARCHAR2(2) := 'UX';


    /*
     * This function returns the next item number for a sequence generated item number
     */
    FUNCTION GET_NEXT_ITEM_NUMBER(p_catalog_group_id NUMBER) RETURN VARCHAR2;

    /*
     ** This procedure Bulk loads the GTIN
     */
    PROCEDURE Process_Gtin_Intf_Rows(ERRBUF  OUT NOCOPY VARCHAR2,
                                     RETCODE OUT NOCOPY VARCHAR2,
                                     p_data_set_id IN  NUMBER);

    /*
     * API to Bulk Load Source system cross references
     */
    PROCEDURE Process_SSXref_Intf_Rows(ERRBUF  OUT NOCOPY VARCHAR2,
                                       RETCODE OUT NOCOPY VARCHAR2,
                                       p_data_set_id IN  NUMBER);
    /*
     * "Phase 2 API
     * This method resolves source system item cross references
     * immediately after MTL_SYSTEM_ITEMS_INTERFACE is populated and
     * tries to detect discrepencies between user entered CONFIRM_STATUS
     * (if any) and other data.
     */
    PROCEDURE Resolve_SSXref_On_Data_load( p_data_set_id  IN  NUMBER
                                         , p_commit       IN  FLAG    DEFAULT FND_API.G_TRUE
                                         );

    /*
     * This method sets the confirm_status for an unprocessed row (process_flag = 0) in the master org
     * for a source system item identified by p_source_system_id and p_source_system_reference.
     * p_status can have the following values:
     * G_CONF_XREF
     * G_CONF_MATCH
     * G_CONF_NEW
     * G_UNCONF_NONE_MATCH
     * G_UNCONF_SIGL_MATCH
     * G_UNCONF_MULT_MATCH
     */
    PROCEDURE Set_Confirm_Status(p_data_set_id IN  NUMBER,
                                 p_source_system_id IN VARCHAR2,
                                 p_source_system_reference IN VARCHAR2,
                                 p_status IN VARCHAR2,
                                 p_inventory_item_id IN NUMBER DEFAULT NULL,
                                 p_organization_id IN NUMBER DEFAULT NULL);


    /* R12C: Introduced
    *  This method calls Get_Confirm_Status and returns String 'ImportReady'
    *  or 'NotImportReady'. This is added fro R12C enhancement where we have
    *  concept of bundles and all items should be ready for import for the bundle
    *  to be ready for import.
    */
    FUNCTION Get_Import_Ready_Status ( p_data_set_id IN NUMBER,
                                       p_source_system_id IN VARCHAR2,
                                       p_source_system_reference IN VARCHAR2,
                                       p_bundle_id IN NUMBER
                                     )
                                     RETURN VARCHAR2;


    /* R12C: Changed signature
     * This method gets the confirm status plus the extra letter to indicate
     * whether an item is ready to be passed on to IOI
     */
    FUNCTION Get_Confirm_Status(p_data_set_id IN NUMBER,
                                p_source_system_id IN VARCHAR2,
                                p_source_system_reference IN VARCHAR2,
                                p_bundle_id IN NUMBER)
                                RETURN VARCHAR2;

    PROCEDURE Get_Item_Num_Desc_Gen_Method(p_item_catalog_group_id IN NUMBER,
                                           x_item_num_gen_method OUT NOCOPY VARCHAR2,
                                           x_item_desc_gen_method OUT NOCOPY VARCHAR2);

    /*
     * This method returns the seeded SOURCE_SYSTEM_ID for PDH
     */
    FUNCTION Get_PDH_Source_System_Id RETURN NUMBER;


    /*
     * "Phase 2 API
     * This method populates the child entities with PK values.
     * This method populates the other interface tables like MTL_ITEM_REVISION_INTERFACE,
     * EGO_ITEM_PEOPLE_INTF, MTL_ITEM_CATEGORIES_INTERFACE, EGO_ITM_USR_ATTR_INTRFC etc.
     * with the inventory item id/number and organization id/code.
     */
    PROCEDURE Resolve_Child_Entities( p_data_set_id  IN  NUMBER
                                    , p_commit       IN  FLAG    DEFAULT FND_API.G_TRUE
                                    );

    PROCEDURE Stamp_RequestId_For_ReImport( p_request_id    IN  MTL_SYSTEM_ITEMS_INTERFACE.REQUEST_ID%TYPE );

    PROCEDURE Stamp_Row_RequestId( p_request_id    IN  MTL_SYSTEM_ITEMS_INTERFACE.REQUEST_ID%TYPE
                                 , p_target_rowid  IN  UROWID
                                 );

    PROCEDURE Log_Error_For_ReImport(p_request_id    IN  MTL_SYSTEM_ITEMS_INTERFACE.REQUEST_ID%TYPE
                                    , p_target_rowid  IN  UROWID
                                    , p_err_msg       IN  VARCHAR2
                                    );

    PROCEDURE Prepare_Row_For_ReImport
        (   p_batch_id          IN          MTL_SYSTEM_ITEMS_INTERFACE.SET_PROCESS_ID%TYPE
        ,   p_organization_id   IN          MTL_SYSTEM_ITEMS_INTERFACE.ORGANIZATION_ID%TYPE
        ,   p_target_rowid      IN          UROWID
        ,   x_return_code       OUT NOCOPY  NUMBER
        ,   x_err_msg           OUT NOCOPY  VARCHAR2
        );

    --=================================================================================================================--
    --------------------------------------- Start of Merging Section ----------------------------------------------------
    --=================================================================================================================--
    /*
     * The procedures in this section, both public and private, relate to the task of identifying the rows in various
     * item interface tables that have the same keys and need to be merged - i.e. collapsed into one row. The result of
     * the merging operation on a subset of the table should be that there is at most one row for any set of keys.
     *
     *
     * All the MERGE_* procedures take the following arguments:
     *  p_batch_id       IN NUMBER                  =>
     *      The batch identifier (MANDATORY).
     *  p_is_pdh_batch   IN FLAG      DEFAULT NULL  =>
     *      Used to determine the set of keys to use for merging.
     *          - Pass FND_API.G_TRUE to indicate that the batch is a PIMDH batch
     *          - Pass FND_API.G_FALSE to indicate that the batch is a non-PIMDH batch
     *          - If not passed, the batch header will be used to determine whether or not
     *              the batch is a PIMDH batch (absence of a header implies that it is).
     *  p_master_org_id  IN NUMBER    DEFAULT NULL =>
     *      The ID of the default batch organization, to be used for rows for which neither
     *          ORGANIZATION_ID nor ORGANIZATION_CODE are provided.
     *      If not passed, the ORGANIZATION_ID in the batch header will be used.
     *
     *  p_commit         IN FLAG      DEFAULT FND_API.G_FALSE =>
     *      Pass FND_API.G_TRUE to have a COMMIT issued at the end of the procedure.
     */


    --------------------------------------------------------------------------------------------
    --  Procedure MERGE_ATTRS
    --      Merges item- and revision-level single row attributes found in the extension
    --      attributes interface table (EGO_ITM_USR_ATTR_INTRFC)
    --------------------------------------------------------------------------------------------
    PROCEDURE merge_attrs   ( p_batch_id       IN NUMBER
                            , p_is_pdh_batch   IN FLAG      DEFAULT NULL
                            , p_ss_id          IN NUMBER    DEFAULT NULL
                            , p_master_org_id  IN NUMBER    DEFAULT NULL
                            , p_commit         IN FLAG      DEFAULT FND_API.G_FALSE
                            );
    --------------------------------------------------------------------------------------------
    --  Procedure MERGE_REVS
    --      Merges unprocessed revisions found in the revisions interface table
    --      (MTL_ITEM_REVISIONS_INTERFACE)
    --------------------------------------------------------------------------------------------
    PROCEDURE merge_revs( p_batch_id       IN NUMBER
                        , p_is_pdh_batch   IN FLAG      DEFAULT NULL
                        , p_ss_id          IN NUMBER    DEFAULT NULL
                        , p_master_org_id  IN NUMBER    DEFAULT NULL
                        , p_commit         IN FLAG      DEFAULT FND_API.G_FALSE
                        );

    --------------------------------------------------------------------------------------------
    --  Procedure MERGE_ITEMS
    --      Merges unprocessed items found in the items interface table
    --      (MTL_SYSTEM_ITEMS_INTERFACE)
    --------------------------------------------------------------------------------------------
    PROCEDURE merge_items   ( p_batch_id       IN NUMBER
                            , p_is_pdh_batch   IN FLAG      DEFAULT NULL
                            , p_ss_id          IN NUMBER    DEFAULT NULL
                            , p_master_org_id  IN NUMBER    DEFAULT NULL
                            , p_commit         IN FLAG      DEFAULT FND_API.G_FALSE
                            );

    --------------------------------------------------------------------------------------------
    --  Procedure MERGE_BATCH
    --      Wrapper procedure that calls the other MERGE_* procedures
    --------------------------------------------------------------------------------------------
    PROCEDURE merge_batch   ( p_batch_id       IN NUMBER
                            , p_is_pdh_batch   IN FLAG      DEFAULT NULL
                            , p_ss_id          IN NUMBER    DEFAULT NULL
                            , p_master_org_id  IN NUMBER    DEFAULT NULL
                            , p_commit         IN FLAG      DEFAULT FND_API.G_FALSE
                            );

    --=================================================================================================================--
    --------------------------------------- End of Merging Section ----------------------------------------------------
    --=================================================================================================================--

  ------------------------------------------------------------------------------------------
  -- This function returns the batch status of a batch                                    --
  ------------------------------------------------------------------------------------------
  FUNCTION GET_BATCH_STATUS(p_batch_id NUMBER) RETURN VARCHAR2;


  --------------------------------------------------------------------------------------------
  --  Function WRAPPED_TO_NUMBER                                                            --
  --      Wraps the to_number built-in to return null in case of conversion failure         --
  --------------------------------------------------------------------------------------------
  FUNCTION WRAPPED_TO_NUMBER( p_val VARCHAR2 )
  RETURN NUMBER
  DETERMINISTIC;

  --------------------------------------------------------------------------------------------
  --  Function WRAPPED_TO_UOM                                                               --
  --      Wraps inv_convert.uom_conversion to return null in case of conversion failure.    --
  --      If both of the from_uom params are null, no attempt to make the conversion is     --
  --        performed.                                                                      --
  --------------------------------------------------------------------------------------------
  FUNCTION WRAPPED_TO_UOM( p_val                  NUMBER
                         , p_to_uom_code          EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE
                         , p_from_uom_code        EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE
                         , p_from_uom_value       EGO_ITM_USR_ATTR_INTRFC.ATTR_UOM_DISP_VALUE%TYPE
                         , p_inventory_item_id    EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE      DEFAULT NULL
                         )
  RETURN NUMBER;

  --------------------------------------------------------------------------------------------
  --  Function WRAPPED_TO_NUMBER                                                            --
  --      Wraps the to_date built-in to return null in case of conversion failure           --
  --------------------------------------------------------------------------------------------
  FUNCTION WRAPPED_TO_DATE( p_val VARCHAR2 )
  RETURN DATE
  DETERMINISTIC;

  --------------------------------------------------------------------------------------------
  --  Function GET_REV_USR_ATTR                                                             --
  --  Returns the display value of the specified revision attribute; if there is no         --
  --      display value, it returns the appropriate value column, based on the              --
  --      p_attr_value_type parameter                                                       --
  --  Used by matching program                                                              --
  --------------------------------------------------------------------------------------------
  FUNCTION GET_REV_USR_ATTR
      (
      p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
      , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_attr_value_type                 IN  FLAG
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_DISP_VALUE%TYPE;

  ----------------------------------------------------------------------------------------------
  --  Function GET_REV_USR_ATTR_DISP
  --  Returns the display value of the specified revision attribute, if the attribute is present
  --  in the interface table, or the internal value, interpreted as a display value.
  --  The assumption is that this will be called from a value set context ...
  ----------------------------------------------------------------------------------------------
  FUNCTION GET_REV_USR_ATTR_SS_DISP
      (
        p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
      , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_attr_type                       IN  FLAG
      , p_from_internal_column            IN  FLAG
      , p_do_processed_rows_flag          IN  FLAG                                    DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_DISP_VALUE%TYPE;

  FUNCTION GET_REV_USR_ATTR_PDH_DISP
      (
        p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
      , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_attr_type                       IN  FLAG
      , p_from_internal_column            IN  FLAG
      , p_do_processed_rows_flag          IN  FLAG                                    DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_DISP_VALUE%TYPE;

  FUNCTION GET_REV_USR_ATTR_TO_CHAR
      (
        p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE           DEFAULT NULL
      , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE    DEFAULT NULL
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_do_processed_rows_flag          IN  FLAG DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE                 DEFAULT NULL
      , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE          DEFAULT NULL
      , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE                DEFAULT NULL
      , p_use_pdh_keys_to_join            IN  BOOLEAN
      , p_get_value_col                   IN  BOOLEAN
      , p_attr_type                       IN  FLAG
      , p_attr_miss_value                 IN  BOOLEAN DEFAULT TRUE
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_DISP_VALUE%TYPE;

  ------------------------------------------------------------------------------------------------
  --  Function GET_REV_USR_ATTR_STR                                                             --
  --  Returns the string value of the specified revision attribute, if the attribute is present --
  --  in the interface table.                                                                   --
  ------------------------------------------------------------------------------------------------
  FUNCTION GET_REV_USR_ATTR_SS_VSTR
      (
      p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
      , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_STR%TYPE;

  FUNCTION GET_REV_USR_ATTR_PDH_VSTR
      (
      p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
      , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_STR%TYPE;

  ------------------------------------------------------------------------------------------------
  --  Function GET_REV_USR_ATTR_DATE                                                            --
  --  Returns the date value of the specified revision attribute, if the attribute is present   --
  --  in the interface table.                                                                   --
  ------------------------------------------------------------------------------------------------
  FUNCTION GET_REV_USR_ATTR_SS_VDATE
      (
      p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
      , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_DATE%TYPE;

  FUNCTION GET_REV_USR_ATTR_PDH_VDATE
      (
      p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
      , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_DATE%TYPE;

  ------------------------------------------------------------------------------------------------
  --  Function GET_REV_USR_ATTR_NUM                                                             --
  --  Returns the number value of the specified revision attribute, if the attribute is present --
  --  in the interface table.                                                                   --
  --      p_output_uom_code parameter is ignored (no uom conversions performed)                 --
  ------------------------------------------------------------------------------------------------
  FUNCTION GET_REV_USR_ATTR_SS_VNUM
      (
        p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
      , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_output_uom_code                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE
      , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_NUM%TYPE;

  FUNCTION GET_REV_USR_ATTR_PDH_VNUM
      (
        p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
      , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_output_uom_code                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE
      , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_NUM%TYPE;

  ------------------------------------------------------------------------------------------------
  --  Function GET_REV_USR_ATTR_DISP_STR                                                        --
  --  Returns the string value of the specified revision attribute, if the attribute is present --
  --  in the interface table, merging in an attempted conversion of the display column content. --
  ------------------------------------------------------------------------------------------------
  FUNCTION GET_REV_USR_ATTR_SS_DSTR
      (
      p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
      , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_STR%TYPE;

  FUNCTION GET_REV_USR_ATTR_PDH_DSTR
      (
      p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
      , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_STR%TYPE;

  ------------------------------------------------------------------------------------------------
  --  Function GET_REV_USR_ATTR_DISP_DATE                                                       --
  --  Returns the date value of the specified revision attribute, if the attribute is present   --
  --  in the interface table, merging in an attempted conversion of the display column content. --
  ------------------------------------------------------------------------------------------------
  FUNCTION GET_REV_USR_ATTR_SS_DDATE
      (
      p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
      , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_DATE%TYPE;

  FUNCTION GET_REV_USR_ATTR_PDH_DDATE
      (
      p_batch_id                          IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
      , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_DATE%TYPE;

  ------------------------------------------------------------------------------------------------
  --  Function GET_REV_USR_ATTR_DISP_NUM                                                        --
  --  Returns the number value of the specified revision attribute, if the attribute is present --
  --  in the interface table, merging in an attempted conversion of the display column content. --
  ------------------------------------------------------------------------------------------------
  FUNCTION GET_REV_USR_ATTR_SS_DNUM
      (
        p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_source_system_id                IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
      , p_source_system_reference         IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_output_uom_code                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE
      , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_NUM%TYPE;

  FUNCTION GET_REV_USR_ATTR_PDH_DNUM
      (
        p_batch_id                        IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
      , p_inventory_item_id               IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
      , p_item_number                     IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
      , p_organization_id                 IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
      , p_revision_code                   IN  EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE
      , p_attr_group_type                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_TYPE%TYPE
      , p_attr_group_name                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_GROUP_INT_NAME%TYPE
      , p_attr_name                       IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_INT_NAME%TYPE
      , p_output_uom_code                 IN  EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE
      , p_do_processed_rows_flag          IN  FLAG                                DEFAULT FND_API.G_FALSE
      , p_request_id                      IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL

      )
  RETURN EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_NUM%TYPE;

  ------------------------------------------------------------------------------------------------
  --  Functions GET_LATEST_EIUAI_REV_[SS/PDH]                                                   --
  --  Returns the the code of the latest LOGICAL revision row loaded for the item into the      --
  --  user defined attribute interface table                                                    --
  --  Note the lack of attribute-specific parameters - this is to ensure that contexts in       --
  --      which this proc gets called will only attempt to go after a single logical revision   --
  --      row, regardless of the possible absence of the required attributes in that row and    --
  --      their possible presence in other logical rows of the interface table                  --
  ------------------------------------------------------------------------------------------------
  FUNCTION GET_LATEST_EIUAI_REV_SS
    (
        p_batch_id                      IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
    ,   p_source_system_id              IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
    ,   p_source_system_reference       IN  EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
    ,   p_organization_id               IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
    ,   p_do_processed_rows_flag        IN  FLAG                    DEFAULT FND_API.G_FALSE
    ,   p_request_id                    IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
    )
  RETURN EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE;

  FUNCTION GET_LATEST_EIUAI_REV_PDH
    (
        p_batch_id                      IN  EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
    ,   p_inventory_item_id             IN  EGO_ITM_USR_ATTR_INTRFC.INVENTORY_ITEM_ID%TYPE
    ,   p_item_number                   IN  EGO_ITM_USR_ATTR_INTRFC.ITEM_NUMBER%TYPE
    ,   p_organization_id               IN  EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
    ,   p_do_processed_rows_flag        IN  FLAG                    DEFAULT FND_API.G_FALSE
    ,   p_request_id                    IN  EGO_ITM_USR_ATTR_INTRFC.REQUEST_ID%TYPE DEFAULT NULL
    )
  RETURN EGO_ITM_USR_ATTR_INTRFC.REVISION%TYPE;

  FUNCTION GET_LATEST_MIRI_REV_SS
    (
        p_batch_id                      IN  MTL_ITEM_REVISIONS_INTERFACE.SET_PROCESS_ID%TYPE
    ,   p_source_system_id              IN  MTL_ITEM_REVISIONS_INTERFACE.SOURCE_SYSTEM_ID%TYPE
    ,   p_source_system_reference       IN  MTL_ITEM_REVISIONS_INTERFACE.SOURCE_SYSTEM_REFERENCE%TYPE
    ,   p_organization_id               IN  MTL_ITEM_REVISIONS_INTERFACE.ORGANIZATION_ID%TYPE
    ,   p_do_processed_rows_flag        IN  FLAG                    DEFAULT FND_API.G_FALSE
    ,   p_request_id                    IN  MTL_ITEM_REVISIONS_INTERFACE.REQUEST_ID%TYPE DEFAULT NULL
    )
  RETURN MTL_ITEM_REVISIONS_INTERFACE.REVISION%TYPE;

  FUNCTION GET_LATEST_MIRI_REV_PDH
    (
        p_batch_id                      IN  MTL_ITEM_REVISIONS_INTERFACE.SET_PROCESS_ID%TYPE
    ,   p_inventory_item_id             IN  MTL_ITEM_REVISIONS_INTERFACE.INVENTORY_ITEM_ID%TYPE
    ,   p_item_number                   IN  MTL_ITEM_REVISIONS_INTERFACE.ITEM_NUMBER%TYPE
    ,   p_organization_id               IN  MTL_ITEM_REVISIONS_INTERFACE.ORGANIZATION_ID%TYPE
    ,   p_do_processed_rows_flag        IN  FLAG                    DEFAULT FND_API.G_FALSE
    ,   p_request_id                    IN  MTL_ITEM_REVISIONS_INTERFACE.REQUEST_ID%TYPE DEFAULT NULL
    )
  RETURN MTL_ITEM_REVISIONS_INTERFACE.REVISION%TYPE;

  -----------------------------------------------------------------------------------------
  -- Get_Tokens                                                                          --
  -- Takes a string and breaks it into tokens, returning them in another space-delimited --
  -- string; the tokens are determined according to the attributes/preferences of the    --
  -- intermedia text index on items, using its stoplist, lexer, etc.                     --
  -----------------------------------------------------------------------------------------
  PROCEDURE GET_TOKENS
  (
    p_string_val                          IN  VARCHAR2
   ,x_tokens                              OUT NOCOPY VARCHAR2
  );

  ------------------------------------------------------------------------------------------
  -- Convert_Org_And_Cat_Grp                                                              --
  -- This procedure converts a specified interface table row's organization code to an ID --
  -- and converts the item catalog category name to its corresponding ID; these           --
  -- conversions only occur if the org code/category name exactly match an existing name  --
  -- in PDH.                                                                              --
  ------------------------------------------------------------------------------------------
  PROCEDURE CONVERT_ORG_AND_CAT_GRP
  (
    p_batch_id           IN        NUMBER
   ,p_src_system_id      IN        NUMBER
   ,p_src_system_ref     IN        VARCHAR2
   ,p_commit             IN        BOOLEAN
  );

  ------------------------------------------------------------------------------------------
  -- Convert_Org_Cat_Grp_For_Batch                                                        --
  -- This is a wrapper procedure for the previous conversion procedure; this one accepts  --
  -- a batch ID and converts all unprocessed rows belonging to that batch.                --
  ------------------------------------------------------------------------------------------
  PROCEDURE CONVERT_ORG_CAT_GRP_FOR_BATCH
  (
    p_batch_id           IN        NUMBER
   ,p_commit             IN        BOOLEAN
  );

  ------------------------------------------------------------------------------------------
  -- Confirm_Matches                                                                      --
  -- This procedure takes care of setting the confirm status for a particular match in    --
  -- the item match table, depending on how many matches were found for a row in the      --
  -- interface table.                                                                     --
  ------------------------------------------------------------------------------------------
  PROCEDURE CONFIRM_MATCHES
  (
    p_batch_id           IN        NUMBER
   ,p_src_system_id      IN        NUMBER
   ,p_src_system_ref     IN        VARCHAR2
   ,p_match_count        IN        NUMBER
   ,p_inventory_item_id  IN        NUMBER
   ,p_organization_id    IN        NUMBER
  );

  ------------------------------------------------------------------------------------------
  -- Get_Latest_Revision_Func                                                             --
  -- This function is a wrapper to Get_Latest_Revision, formed as a function instead of a --
  -- procedure.                                                                           --
  ------------------------------------------------------------------------------------------
  FUNCTION GET_LATEST_REVISION_FUNC
  (
    p_batch_id                        IN      EGO_ITM_USR_ATTR_INTRFC.DATA_SET_ID%TYPE
  , p_source_system_id                IN      EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_ID%TYPE
  , p_source_system_reference         IN      EGO_ITM_USR_ATTR_INTRFC.SOURCE_SYSTEM_REFERENCE%TYPE
  , p_organization_id                 IN      EGO_ITM_USR_ATTR_INTRFC.ORGANIZATION_ID%TYPE
  )
  RETURN VARCHAR2;

  PROCEDURE UPDATE_ITEM_SYNC_RECORDS
   (p_set_id  IN  NUMBER
    ,p_org_id IN NUMBER
   );


  PROCEDURE SET_CONFIRM_STATUS
    (p_batch_id                IN  MTL_SYSTEM_ITEMS_INTERFACE.SET_PROCESS_ID%TYPE
    ,p_source_system_id        IN  MTL_SYSTEM_ITEMS_INTERFACE.SOURCE_SYSTEM_ID%TYPE
    ,p_source_system_reference IN  MTL_SYSTEM_ITEMS_INTERFACE.SOURCE_SYSTEM_REFERENCE%TYPE
    ,p_new_status              IN  MTL_SYSTEM_ITEMS_INTERFACE.CONFIRM_STATUS%TYPE
    ,p_inventory_item_id       IN  MTL_SYSTEM_ITEMS_INTERFACE.INVENTORY_ITEM_ID%TYPE DEFAULT NULL
    ,p_organization_id         IN  MTL_SYSTEM_ITEMS_INTERFACE.ORGANIZATION_ID%TYPE DEFAULT NULL
    ,p_check_matching_table    IN  FLAG  DEFAULT FND_API.G_FALSE
    ,errmsg                    OUT NOCOPY VARCHAR2
    ,retcode                   OUT NOCOPY VARCHAR2
    );

  ------------------------------------------------------------------
  -- Function for returning the change order flag for the batch
  -- Bug#4631349 (RSOUNDAR)
  ------------------------------------------------------------------

  FUNCTION getAddAllToChangeFlag (p_batch_id  IN  NUMBER)
  RETURN VARCHAR2;

  FUNCTION Get_Lookup_Meaning(p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2) RETURN VARCHAR2;

  ------------------------------------------------------------------
   --Function for returning batch details before import
   --Bug.:4933193
  ------------------------------------------------------------------
  FUNCTION GET_IMPORT_DETAILS_DATA
    (     p_set_process_id                NUMBER,
          p_organization_id               NUMBER ,
          p_organization_code             VARCHAR2
    )
  RETURN  SYSTEM.EGO_IMPORT_CNT_TABLE;

  /*
   * This method updates the request_ids to ego_import_batches_b table.
   */
  PROCEDURE Update_Request_Id_To_Batch (
            p_import_request_id  IN NUMBER,
            p_match_request_id   IN NUMBER,
            p_batch_id           IN NUMBER);

  /*
   * This method is called after all the import is completed
   * this will update the process flag of rows with process flag = 111
   */
  PROCEDURE Demerge_Batch_After_Import(
                                         ERRBUF  OUT NOCOPY VARCHAR2
                                       , RETCODE OUT NOCOPY VARCHAR2
                                       , p_batch_id        IN NUMBER
                                      );

  /*
  * This mehtod is for merging the associations.
  * This method also defaults the values for primary_flag and status_code in associations table.
  *              primary_flag null is defaulted with 'N'
  *              status_code null is defaulted with 1
  */
  PROCEDURE merge_associations  ( p_batch_id       IN NUMBER
                                , p_is_pdh_batch   IN FLAG      DEFAULT NULL
                                , p_commit         IN FLAG      DEFAULT FND_API.G_FALSE );


  /*
   * This method cleans up UDA row identifiers, ensuring that all single attr groups
   * are represented by only one row identifier in EGO_ITM_USR_ATTR_INTRFC
   */
  PROCEDURE CLEAN_UP_UDA_ROW_IDENTS( p_batch_id             IN NUMBER,
                                     p_process_status       IN NUMBER,
                                     p_ignore_item_num_upd  IN VARCHAR2, --FND_API.G_TRUE
                                     p_commit               IN VARCHAR2 DEFAULT FND_API.G_TRUE
                                   );

END EGO_IMPORT_PVT;

/
