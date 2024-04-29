--------------------------------------------------------
--  DDL for Package EGO_ITEM_BULKLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_BULKLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: EGOIBLKS.pls 120.2 2007/04/09 13:56:56 gnanda ship $ */


  -- ===============================================
  -- CONSTANTS for concurrent program return values
  -- ===============================================

  ---------------------------------------
  -- Package Name
  ---------------------------------------
  G_PACKAGE_NAME               CONSTANT VARCHAR2(30) := 'EGO_ITEM_BULKLOAD_PKG';

  ------------------------------------------------------------------------------
  --  Return values for RETCODE parameter (standard for concurrent programs)
  ------------------------------------------------------------------------------
  RETCODE_SUCCESS              NUMBER    := 0;
  RETCODE_WARNING              NUMBER    := 1;
  RETCODE_ERROR                NUMBER    := 2;

  ----------------------------------------------------
  --  List of PROCESS_STATUS
  ----------------------------------------------------

  --------------------------------------------------------------------------
  -- ProcessStatus : To Be Processed
  -- the status when the record is loaded into Mtl_System_Items_Interface
  --------------------------------------------------------------------------
  G_PS_TO_BE_PROCESSED         NUMBER    := 1;

  --------------------------------------------------------------------------
  -- ProcessStatus : Error
  --------------------------------------------------------------------------
  G_PS_ERROR                   NUMBER    := 3;
  G_PS_IMPORT_FAILURE          NUMBER    := 4;

  --------------------------------------------------------------------------
  -- ProcessStatus : Success
  --------------------------------------------------------------------------
  G_PS_SUCCESS                 NUMBER    := 7;

  --------------------------------------------------------------------------
  -- Caller Identifiers
  --------------------------------------------------------------------------
  G_ITEM                       VARCHAR2(50) := 'ITEM';
  G_BOM                        VARCHAR2(50) := 'BOM';

-- =========================
-- PROCEDURES AND FUNCTIONS
-- =========================

 -----------------------------------------------------------------------
 -- Fix for Bug# 3970069.
 -- Insert into MTL_INTERFACE_ERRORS through autonomous transaction
 -- commit. Earlier for any exception during Java Conc Program's
 -- AM.commit(), the errors wouldnot get logged. By following Autonomous
 -- Transaction block, that issue gets resolved.
 -----------------------------------------------------------------------
 PROCEDURE Insert_Mtl_Intf_Err(  p_transaction_id       IN  VARCHAR2
			       , p_bo_identifier        IN  VARCHAR2
			       , p_error_entity_code    IN  VARCHAR2
			       , p_error_table_name     IN  VARCHAR2
			       , p_error_msg            IN  VARCHAR2
			       );


 --------------------------------------------------------------------
 -- Fix for Bug# 3864813
 -- Process Net Weight (i.e. Unit Weights) for the Items based on the
 -- Trade Item Descriptor value.
 --
 -- NOTE: Net Weight can only have a value if Trade Item Descriptor
 -- is "Base Unit Or Each", else it will be NULL (i.e. it will be
 -- derived value).
 --------------------------------------------------------------------
PROCEDURE process_netweights
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_commit                IN         VARCHAR2 DEFAULT FND_API.G_TRUE ,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2
                );

 ----------------------------------------------------------
 -- Process Item and Item Revision Interface Lines
 --
 -- Main API called by the Concurrent Program.
 ----------------------------------------------------------
PROCEDURE process_item_interface_lines
  (p_resultfmt_usage_id    IN  NUMBER,
   p_user_id               IN  NUMBER,
   p_conc_request_id       IN  NUMBER,
   p_language_code         IN  VARCHAR2,
   p_caller_identifier     IN  VARCHAR2 DEFAULT EGO_ITEM_BULKLOAD_PKG.G_ITEM,
   p_commit                IN  VARCHAR2 DEFAULT FND_API.G_TRUE ,
   x_errbuff               OUT NOCOPY VARCHAR2,
   x_retcode               OUT NOCOPY VARCHAR2,
   p_start_upload          IN  VARCHAR2 DEFAULT FND_API.G_TRUE ,
   p_data_set_id           IN  NUMBER   DEFAULT NULL
   );
    -- Start OF comments
    -- API name  : Process Item Interfance Lines
    -- TYPE      : Public (called by Concurrent Program Wrapper)
    -- Pre-reqs  : None
    -- FUNCTION  : Process and Load Item interfance lines.
    --             Loads Item Attr Values + Item User-Defined Attr Values
    --             Errors are populated in MTL_INTERFACE_ERRORS
    --
    -- Parameters:
    --     IN    :
    --             p_resultfmt_usage_id        IN      NUMBER
    --               Similar to job number. Maps one-to-one with Data_Set_Id,
    --               i.e. job number.
    --
    --             p_user_id    IN      NUMBER
    --               Used for Security validation and populating Created By.
    --
    --             p_conc_request_id    IN      NUMBER
    --               Concurrent Request ID.
    --
    --             p_language_code    IN      VARCHAR2
    --               Language Code.
    --
    --             p_caller_identifier    IN      VARCHAR2
    --               Can be called from Item -or- BOM code.
    --
    --             p_commit    IN      VARCHAR2
    --               To commit or not to commit.
    --
    --
    --     OUT    :
    --             x_retcode            OUT NOCOPY VARCHAR2,
    --             x_errbuff            OUT NOCOPY VARCHAR2



-- Bug: 3778006
-------------------------------------------------------------------------
-- Function to get description generation method  for catalog category --
-------------------------------------------------------------------------
FUNCTION get_desc_gen_method(p_catalog_group_id NUMBER) RETURN VARCHAR2;

/*
 ** Added by Ssingal - This procedure gets the Trade ItemDescriptor for a given
 **                    Inventory_item_id and organization Id.
 **         Bug Fix  4001661
 */

PROCEDURE get_Trade_Item_Descriptor (
          p_inventory_item_id            IN          VARCHAR2,
          p_organization_id              IN          VARCHAR2,
          x_tradeItemDescriptor          OUT NOCOPY  VARCHAR2
);

/*
 ** Added by Ssingal - For clearing the attribute values for an Item
 **                    taking into consideration the Trade Item Descriptor
 **         Bug Fix  4001661
 */

PROCEDURE Clear_Gtin_Attrs
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_commit                IN         VARCHAR2 DEFAULT FND_API.G_TRUE ,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_ret_code              OUT NOCOPY VARCHAR2
                );


--  ============================================================================
--  API Name    : Populate_Seq_Gen_Item_Nums
--  Description : This procedure will be called from IOI
--                (after org and catalog category details are resolved)
--                to populate the item numbers for all the sequence generated items.
--  ============================================================================

PROCEDURE Populate_Seq_Gen_Item_Nums
          (p_set_id           IN         NUMBER
          ,p_org_id           IN         NUMBER
          ,p_all_org          IN         NUMBER
          ,p_rec_status       IN         NUMBER
          ,x_return_status    OUT NOCOPY VARCHAR2
          ,x_msg_count        OUT NOCOPY NUMBER
          ,x_msg_data         OUT NOCOPY VARCHAR2);


--  ============================================================================
--  API Name    : load_intersections_interface
--  Description : this procedure would look at the bulkload interface table
--                populated by excel and then populate the intersections
--                interface table with supplier/supplier site etc. intersections
--  ============================================================================

PROCEDURE load_intersections_interface
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_set_process_id        IN         NUMBER,
                 x_set_process_id        OUT NOCOPY NUMBER,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2
                );


END EGO_ITEM_BULKLOAD_PKG;

/
