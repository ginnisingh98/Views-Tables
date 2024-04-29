--------------------------------------------------------
--  DDL for Package EGO_ITEM_USER_ATTRS_CP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_USER_ATTRS_CP_PUB" AUTHID DEFINER AS
/* $Header: EGOCIUAS.pls 120.8.12010000.5 2010/04/28 02:12:15 mshirkol ship $ */



                       ----------------------
                       -- Global Variables --
                       ----------------------

/*
 * PROCESS_STATUS constants
 * ------------------------
 * The following constants are used in the PROCESS_STATUS column of the table
 * EGO_ITEM_USER_ATTRS_INTERFACE to describe the processing status of each row.
 *
 * G_PS_TO_BE_PROCESSED: row should be processed
 * G_PS_IN_PROCESS: row is being processed
 * G_PS_GENERIC_ERROR: some row in the same logical Attribute Group as this row
                       encountered an error (all error statuses described below
 *                     are set to this status at the completion of processing)
 * G_PS_SUCCESS: row processed succcessfully
 *
 * In addition to the four basic error statuses above, there are several internal
 * statuses that may appear in the interface table at times (for instance, while
 * a data set is being processed, or if the process encountered a fatal error)
 *
 * G_PS_BAD_ORG_ID: some row in the same logical Attribute Group as this row
 *                  contains an Org ID that is not a Master Org ID in MTL_PARAMETERS
 * G_PS_BAD_ORG_CODE: some row in the same logical Attribute Group as this row
 *                    contains an Org Code that isn't a Master Org Code in MTL_PARAMETERS
 * G_PS_BAD_ITEM_ID: some row in the same logical Attribute Group as this row
 *                   contains an Item ID that isn't in MTL_SYSTEM_ITEMS_B for the
 *                   passed-in Organization
 * G_PS_BAD_ITEM_NUMBER: some row in the same logical Attribute Group as this row
 *                       contains an Item Number that isn't a valid "concatenated
 *                       segments" value for the passed-in Organization
 * G_PS_BAD_REVISION_ID: some row in the same logical Attribute Group as this row
 *                       contains a revision ID that isn't in MTL_ITEM_REVISIONS
 *                       for the passed-in Item and Organization
 * G_PS_BAD_REVISION_CODE: some row in the same logical Attribute Group as this row
 *                         contains a revision Code that isn't in MTL_ITEM_REVISIONS
 *                         for the passed-in Item and Organization
 * G_PS_BAD_CATALOG_GROUP_ID: some row in the same logical Attribute Group as this row
 *                            contains a catalog group ID that isn't in MTL_SYSTEM_ITEMS_B
 *                            for the passed-in Item and Organization
 * G_PS_ITM_CHANGE_POLICY_EXISTS: the Attribute Group of which this row is a part is under
 *                                Change control for the Catalog Category and Lifecycle Phase
 *                                to which this Item belongs
 * G_PS_REV_CHANGE_POLICY_EXISTS: the Attribute Group of which this row is a part is under
 *                                Change control for the Catalog Category and Lifecycle Phase
 *                                to which this Revision belongs
 */

    G_PS_TO_BE_PROCESSED                     CONSTANT NUMBER := 1;
    G_PS_IN_PROCESS                          CONSTANT NUMBER := 2;
    G_PS_GENERIC_ERROR                       CONSTANT NUMBER := 3;
    G_PS_SUCCESS                             CONSTANT NUMBER := 4;
    G_PS_BAD_ORG_ID                          CONSTANT NUMBER := 15;
    G_PS_BAD_ORG_CODE                        CONSTANT NUMBER := 16;
    G_PS_BAD_ITEM_ID                         CONSTANT NUMBER := 17;
    G_PS_BAD_ITEM_NUMBER                     CONSTANT NUMBER := 18;
    G_PS_BAD_REVISION_ID                     CONSTANT NUMBER := 19;
    G_PS_BAD_REVISION_CODE                   CONSTANT NUMBER := 20;
    G_PS_BAD_CATALOG_GROUP_ID                CONSTANT NUMBER := 21;
-- bug 3762809
-- gave way to G_PS_CHG_POLICY_CO_REQUIRED and G_PS_CHG_POLICY_NOT_ALLOWED
--    G_PS_CHANGE_POLICY_IN_PLACE              CONSTANT NUMBER := 12;
    G_PS_CHG_POLICY_CO_REQUIRED              CONSTANT NUMBER := 5;
-- bug 4679902 (process status for policy "NOT ALLOWED" = 24)
    G_PS_CHG_POLICY_NOT_ALLOWED              CONSTANT NUMBER := 24;
    G_PS_BAD_ATTR_GROUP_ID                   CONSTANT NUMBER := 22;
    G_PS_BAD_ATTR_GROUP_NAME                 CONSTANT NUMBER := 23;
    G_PS_DATA_LEVEL_INCORRECT                CONSTANT NUMBER := 25;

    G_PS_BAD_DATA_LEVEL                      CONSTANT NUMBER := 26;
    G_PS_BAD_SUPPLIER                        CONSTANT NUMBER := 27;
    G_PS_BAD_SUPPLIER_SITE                   CONSTANT NUMBER := 28;
    G_PS_BAD_SUPPLIER_SITE_ORG               CONSTANT NUMBER := 29;

    -- for user defined attributes, all the process statuses are already in use i.e.
    -- 0, 1, 2, 3, 4, 5, 6, and 8 and above are in use
    -- 7 has a conflict with other interface tables, user may think that record is successful
    -- so, the only option left is to use numbers with decimal < 8
    G_PS_STYLE_VARIANT_IN_PROCESS            CONSTANT NUMBER := 3.05;
    G_PS_VAR_VSET_CHG_NOT_ALLOWED            CONSTANT NUMBER := 3.15;
    G_PS_BAD_STYLE_VAR_VALUE_SET             CONSTANT NUMBER := 3.25;
    G_PS_BAD_SKU_VAR_VALUE                   CONSTANT NUMBER := 3.35;
    G_PS_SKU_VAR_VALUE_NOT_UPD               CONSTANT NUMBER := 3.45;
    G_PS_INH_ATTR_FOR_SKU_NOT_UPD            CONSTANT NUMBER := 3.55;

    -- PIM for Telco Validations
    -- G_COM_VALDN_FAIL                         CONSTANT NUMBER := 3.65;

/*
 * RETCODE supplementary constant
 * ------------------------------
 * An additional constant to indicate that the concurrent program completed
 * successfully but that at least one of the rows processed failed validations.
 */

 G_RETCODE_SUCCESS_WITH_WARNING              CONSTANT VARCHAR(1) := 'W';





                          ----------------
                          -- Procedures --
                          ----------------

/*
 * Get_Item_Security_Predicate
 * ---------------------------
 */
PROCEDURE Get_Item_Security_Predicate (
        p_object_name                   IN   VARCHAR2
       ,p_party_id                      IN   VARCHAR2
       ,p_privilege_name                IN   VARCHAR2
       ,p_table_alias                   IN   VARCHAR2
       ,x_security_predicate            OUT NOCOPY VARCHAR2
 );



/*
 * Process_Item_User_Attrs_Data
 * ----------------------------
 * This procedure processes all interface table rows
 * corresponding to the passed-in data set ID.  ERRBUF and RETCODE are standard
 * parameters for concurrent programs, and we ignore them.
 * p_debug_level: number from 0-3, with 0 for no debug
 * information and 3 for exhaustive debugs
 * p_purge_successful_lines: 'T' or 'F', indicating
 * whether or not to delete all rows in this data set
 * that are successfully processed
 * p_initialize_error_handler: flag indicating whether
 * or not we initialize the ERROR_HANDLER package
 */
PROCEDURE Process_Item_User_Attrs_Data
(
        ERRBUF                          OUT NOCOPY VARCHAR2
       ,RETCODE                         OUT NOCOPY VARCHAR2
       ,p_data_set_id                   IN   NUMBER
       ,p_debug_level                   IN   NUMBER   DEFAULT 0
       ,p_purge_successful_lines        IN   VARCHAR2 DEFAULT FND_API.G_FALSE
       ,p_initialize_error_handler      IN   VARCHAR2 DEFAULT FND_API.G_TRUE
       ,p_validate_only                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE
       ,p_ignore_security_for_validate  IN   VARCHAR2 DEFAULT FND_API.G_FALSE
       ,p_commit                        IN  VARCHAR2 DEFAULT   FND_API.G_TRUE   /* Added to fix Bug#7422423*/
       ,p_is_id_validations_reqd        IN  VARCHAR2 DEFAULT  FND_API.G_TRUE  /* Fix for bug#9660659 */
);



/*
 * Get_Related_Class_Codes
 * -----------------------
 * A procedure for INTERNAL USE ONLY;
 * util procedure to get a comma-delimited list of parent
 * Catalog Category IDs for a passed-in Catalog Category ID
 */
PROCEDURE Get_Related_Class_Codes (
        p_classification_code           IN   VARCHAR2
       ,x_related_class_codes_list      OUT NOCOPY VARCHAR2
);



/*
 * Impl_Item_Attr_Change_Line
 * --------------------------
 * A procedure for INTERNAL USE ONLY;
 * wrapper for ENG to implement Change
 * Lines for Items
 */
PROCEDURE Impl_Item_Attr_Change_Line (
        p_api_version                   IN   NUMBER
       ,p_change_id                     IN   NUMBER
       ,p_change_line_id                IN   NUMBER
       ,p_old_revision_id               IN   NUMBER     DEFAULT NULL
       ,p_new_revision_id               IN   NUMBER     DEFAULT NULL
       ,p_init_msg_list                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


  ----------------------------------------------------------------------
  /*
   * Copy_data_to_Intf
   * --------------------------
   * A procedure for ITEMS use
   * which copies data from production/interface table to interface table
   * The inherited attribute groups are filtered at the source sql only.
   *
   */
  PROCEDURE Copy_data_to_Intf
      (
        p_api_version                   IN  NUMBER
       ,p_commit                        IN  VARCHAR2
       ,p_copy_from_intf_table          IN  VARCHAR2  -- T/F
       ,p_source_entity_sql             IN  VARCHAR2
       ,p_source_attr_groups_sql        IN  VARCHAR2
       ,p_dest_process_status           IN  VARCHAR2
       ,p_dest_data_set_id              IN  VARCHAR2
       ,p_dest_transaction_type         IN  VARCHAR2
       ,p_cleanup_row_identifiers       IN  VARCHAR2 DEFAULT FND_API.G_TRUE  -- T/F
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
      );

END EGO_ITEM_USER_ATTRS_CP_PUB;


/
