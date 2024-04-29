--------------------------------------------------------
--  DDL for Package ENG_CHANGE_IMPORT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_IMPORT_UTIL" AUTHID CURRENT_USER as
/*$Header: ENGUCMIS.pls 120.16.12010000.3 2010/06/11 22:02:48 ksuleman ship $*/


/********************************************************************
* Constant Variables
*********************************************************************/

  ---------------------------------------
  -- Package Name
  ---------------------------------------
  G_PKG_NAME  CONSTANT VARCHAR2(30):='ENG_CHANGE_IMPORT_UTIL';

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
  G_CM_TO_BE_PROCESSED         NUMBER    := 5;

  --------------------------------------------------------------------------
  -- ProcessStatus : Error
  --------------------------------------------------------------------------
  G_PS_ERROR                   NUMBER    := 3;
  G_PS_IMPORT_FAILURE          NUMBER    := 4;

  --------------------------------------------------------------------------
  -- ProcessStatus : Success
  --------------------------------------------------------------------------
  G_PS_SUCCESS                 NUMBER    := 7;
  G_PS_UDA_SUCCESS             NUMBER    := 4;


  --------------------------------------------------------------------------
  -- ProcessStatus : (INTERNAL) Data Population Phase
  --------------------------------------------------------------------------
  G_CM_DATA_POPULATION         NUMBER    := -5;


  ---------------------------------------------------------------
  -- Interface line Transaction Types.                         --
  ---------------------------------------------------------------
  G_CREATE             CONSTANT VARCHAR2(10) := 'CREATE';
  G_UPDATE             CONSTANT VARCHAR2(10) := 'UPDATE';
  G_DELETE             CONSTANT VARCHAR2(10) := 'DELETE';
  G_SYNC               CONSTANT VARCHAR2(10) := 'SYNC';


  ---------------------------------------------------------------
  -- Change Management ACD TYpe                                --
  ---------------------------------------------------------------
  G_ADD_ACD_TYPE       CONSTANT VARCHAR2(10) := 'ADD';
  G_CHANGE_ACD_TYPE    CONSTANT VARCHAR2(10) := 'CHANGE';
  G_DELETE_ACD_TYPE    CONSTANT VARCHAR2(10) := 'DELETE';

  G_BOM_ADD_ACD_TYPE      CONSTANT NUMBER := 1;
  G_BOM_CHANGE_ACD_TYPE   CONSTANT NUMBER := 2;
  G_BOM_DISABLE_ACD_TYPE  CONSTANT NUMBER := 3;


  --------------------------------------------------------------------------
  -- Caller Identifiers
  --------------------------------------------------------------------------
  G_ITEM                       VARCHAR2(50) := 'ITEM';
  G_BOM                        VARCHAR2(50) := 'BOM';


  --------------------------------------------------------------------
  -- Message Type
  --------------------------------------------------------------------

  -- Specifies an exception of type error.
  ERROR CONSTANT VARCHAR2(30)  := '0';

  -- Specifies an exception of type warning.
  WARNING CONSTANT VARCHAR2(30)  := '1' ;

  -- Specifies an exception of type information.
  INFORMATION CONSTANT VARCHAR2(30)  := '2' ;

  -- Specifies an exception of type confirmation.
  CONFIRMATION CONSTANT VARCHAR2(30)  := '3' ;

  -- Specifies a severe exception.
  SEVERE CONSTANT VARCHAR2(30)  := '4' ;

  --------------------------------------------------------------------
  -- Exception Action Type
  --------------------------------------------------------------------
  -- Specifies no action to be taken when this exception is thrown.
  NO_ACTION CONSTANT VARCHAR2(30)  := '0' ;

  -- Specifies an action to skip the row where this exception was thrown.
  SKIP_CURRENT_ROW CONSTANT VARCHAR2(30)  := '1' ;

  -- Specifies an action to skip the parent of the row where this exception was thrown.
  SKIP_PARENT CONSTANT VARCHAR2(30)  := '2' ;

  -- Specifies an action to skip all ancestors of the row where this exception was thrown.
  SKIP_ANCESTOR CONSTANT VARCHAR2(30)  := '3' ;

  -- Specifies an action to completely stop when this exception is thrown.
  STOP CONSTANT VARCHAR2(30)  := '4' ;

  -- The logging level under which this exception is logged.
  LOG_ERROR CONSTANT VARCHAR2(30)  := '5' ;



  --------------------------------------------------------------------
  -- CM Import Process Entity
  --------------------------------------------------------------------
  G_IMPORT_ALL           CONSTANT VARCHAR2(30)     := 'ALL';

  G_ALL_ITEM_ENTITY      CONSTANT VARCHAR2(30)     := 'ALL_EGO_ITEM';
  G_ITEM_ENTITY          CONSTANT VARCHAR2(30)     := 'EGO_ITEM';
  G_ITEM_REV_ENTITY      CONSTANT VARCHAR2(30)     := 'EGO_ITEM_REVISION';
  G_GDSN_ATTR_ENTITY     CONSTANT VARCHAR2(30)     := 'ITEM_GDSN_ATTR';
  G_USER_ATTR_ENTITY     CONSTANT VARCHAR2(30)     := 'ITEM_USER_ATTR';
  G_MFG_PARTT_NUM_ENTITY CONSTANT VARCHAR2(30)     := 'ITEM_MFG_PART_NUM';

  G_ALL_BOM_ENTITY       CONSTANT VARCHAR2(30)     := 'ALL_BOM';
  G_BOM_ENTITY           CONSTANT VARCHAR2(30)     := 'BOM';
  G_COMP_ENTITY          CONSTANT VARCHAR2(30)     := 'RC';
  G_REF_DESG_ENTITY      CONSTANT VARCHAR2(30)     := 'RD';
  G_SUB_COMP_ENTITY      CONSTANT VARCHAR2(30)     := 'SC';


  --------------------------------------------------------------------
  -- INTERFACE TABLE AND COLUMN NAME
  --------------------------------------------------------------------
  G_ITEM_INTF              CONSTANT VARCHAR2(30)  := 'MTL_SYSTEM_ITEMS_INTERFACE' ;
  G_ITEM_INTF_BACTH_ID     CONSTANT VARCHAR2(30)  := 'SET_PROCESS_ID' ;
  G_ITEM_INTF_PROC_FLAG    CONSTANT VARCHAR2(30)  := 'PROCESS_FLAG' ;
  G_ITEM_INTF_RI_SEQ_ID    CONSTANT VARCHAR2(30)  := 'CHANGE_LINE_ID' ;

  G_ITEM_REV_INTF              CONSTANT VARCHAR2(30)  := 'MTL_ITEM_REVISIONS_INTERFACE' ;
  G_ITEM_REV_INTF_BACTH_ID     CONSTANT VARCHAR2(30)  := 'SET_PROCESS_ID' ;
  G_ITEM_REV_INTF_PROC_FLAG    CONSTANT VARCHAR2(30)  := 'PROCESS_FLAG' ;
  G_ITEM_REV_INTF_RI_SEQ_ID    CONSTANT VARCHAR2(30)  := 'REVISED_ITEM_SEQUENCE_ID' ;

  G_ITEM_USR_ATTR_INTF              CONSTANT VARCHAR2(30)  := 'EGO_ITM_USR_ATTR_INTRFC' ;
  G_ITEM_USR_ATTR_INTF_BACTH_ID     CONSTANT VARCHAR2(30)  := 'DATA_SET_ID' ;
  G_ITEM_USR_ATTR_INTF_PROC_FLAG    CONSTANT VARCHAR2(30)  := 'PROCESS_STATUS' ;
  G_ITEM_USR_ATTR_INTF_RI_SEQ_ID    CONSTANT VARCHAR2(30)  := 'CHANGE_LINE_ID' ;


  G_ITEM_AML_INTF              CONSTANT VARCHAR2(30)  := 'EGO_AML_INTF' ;
  G_ITEM_AML_INTF_BACTH_ID     CONSTANT VARCHAR2(30)  := 'DATA_SET_ID' ;
  G_ITEM_AML_INTF_PROC_FLAG    CONSTANT VARCHAR2(30)  := 'PROCESS_FLAG' ;
  G_ITEM_AML_INTF_RI_SEQ_ID    CONSTANT VARCHAR2(30)  := 'CHANGE_LINE_ID' ;

  G_BOM_INTF              CONSTANT VARCHAR2(30)  := 'BOM_BILL_OF_MTLS_INTERFACE' ;
  G_BOM_INTF_BACTH_ID     CONSTANT VARCHAR2(30)  := 'BATCH_ID' ;
  G_BOM_INTF_PROC_FLAG    CONSTANT VARCHAR2(30)  := 'PROCESS_FLAG' ;
  G_BOM_INTF_CHG_NOTICE    CONSTANT VARCHAR2(30)  := 'PENDING_FROM_ECN' ;

  G_COMP_INTF              CONSTANT VARCHAR2(30)  := 'BOM_INVENTORY_COMPS_INTERFACE' ;
  G_COMP_INTF_BACTH_ID     CONSTANT VARCHAR2(30)  := 'BATCH_ID' ;
  G_COMP_INTF_PROC_FLAG    CONSTANT VARCHAR2(30)  := 'PROCESS_FLAG' ;
  G_COMP_INTF_RI_SEQ_ID    CONSTANT VARCHAR2(30)  := 'REVISED_ITEM_SEQUENCE_ID' ;
  G_COMP_INTF_CHG_NOTICE    CONSTANT VARCHAR2(30)  := 'CHANGE_NOTICE' ;

  G_REF_DESG_INTF              CONSTANT VARCHAR2(30)  := 'BOM_REF_DESGS_INTERFACE' ;
  G_REF_DESG_INTF_BACTH_ID     CONSTANT VARCHAR2(30)  := 'BATCH_ID' ;
  G_REF_DESG_INTF_PROC_FLAG    CONSTANT VARCHAR2(30)  := 'PROCESS_FLAG' ;
  G_REF_DESG_INTF_CHG_NOTICE    CONSTANT VARCHAR2(30)  := 'CHANGE_NOTICE' ;

  G_SUB_COMP_INTF              CONSTANT VARCHAR2(30)  := 'BOM_SUB_COMPS_INTERFACE' ;
  G_SUB_COMP_INTF_BACTH_ID     CONSTANT VARCHAR2(30)  := 'BATCH_ID' ;
  G_SUB_COMP_INTF_PROC_FLAG    CONSTANT VARCHAR2(30)  := 'PROCESS_FLAG' ;
  G_SUB_COMP_INTF_CHG_NOTICE    CONSTANT VARCHAR2(30)  := 'CHANGE_NOTICE' ;



  --------------------------------------------------------------------
  -- ITEM ATTRIBUTE GROUP TYPE NAME
  --------------------------------------------------------------------
  G_EGO_ITEMMGMT_GROUP           CONSTANT VARCHAR2(30)  := 'EGO_ITEMMGMT_GROUP' ;
  G_EGO_ITEM_GTIN_ATTRS          CONSTANT VARCHAR2(30)  := 'EGO_ITEM_GTIN_ATTRS' ;
  G_EGO_ITEM_GTIN_MULTI_ATTRS    CONSTANT VARCHAR2(30)  := 'EGO_ITEM_GTIN_MULTI_ATTRS' ;



  --------------------------------------------------------------------
  -- BATCH TYPE
  --------------------------------------------------------------------
  G_BOM_BATCH           CONSTANT VARCHAR2(30)  := 'BOM_STRUCTURE' ;
  G_ITEM_BATCH          CONSTANT VARCHAR2(30)  := 'EGO_ITEM' ;
  G_NO_BATCH            CONSTANT VARCHAR2(30)  := 'NONE' ;


  --------------------------------------------------------------------
  -- CM IMPORT OPTION
  --------------------------------------------------------------------
  G_CREATE_NEW_CHANGE   CONSTANT VARCHAR2(30)  := 'N' ;
  G_ADD_TO_EXISTING     CONSTANT VARCHAR2(30)  := 'E' ;
  G_NO_CHANGE           CONSTANT VARCHAR2(30)  := 'O' ;



  --------------------------------------------------------------------
  -- BATCH IMPORT OPTION: REVISION IMPORT POLICY
  --------------------------------------------------------------------
  G_REV_IMPT_POLICY_NEW    CONSTANT VARCHAR2(1)  := 'N' ;
  G_REV_IMPT_POLICY_LATEST CONSTANT VARCHAR2(1)  := 'L' ;


 -----------------------------------------------------------------
 -- Check the entity is processed or not                        --
 -----------------------------------------------------------------
FUNCTION Get_Attr_Group_Type_Condition (p_table_alias     IN  VARCHAR2
                                      , p_attr_group_type IN VARCHAR2
                                        )
RETURN VARCHAR2 ;


/********************************************************************
* API Type      : Error and Message Handling APIs
* Purpose       : Error and Message Handling for Change Import
*********************************************************************/
PROCEDURE WRITE_MSG_TO_INTF_TBL
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_transaction_id    IN  NUMBER
 ,  p_bo_identifier     IN  VARCHAR2  := NULL
 ,  p_error_entity_code IN  VARCHAR2  := NULL
 ,  p_error_table_name  IN  VARCHAR2  := NULL
 ,  p_error_column_name IN  VARCHAR2  := NULL
 ,  p_error_msg         IN  VARCHAR2  := NULL
 ,  p_error_msg_type    IN  VARCHAR2  := NULL
 ,  p_error_msg_name    IN  VARCHAR2  := NULL
 ) ;




/********************************************************************
* API Type      : Validation APIs
* Purpose       : Perform Validation for Change Import
*********************************************************************/
PROCEDURE VALIDATE_RECORDS
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_batch_type        IN  VARCHAR2  := NULL
 ,  p_process_entity    IN  VARCHAR2  := NULL
 ,  p_cm_process_type   IN  VARCHAR2  := NULL
) ;



PROCEDURE  MERGE_GDSN_PENDING_CHG_ROWS
( p_inventory_item_id    IN  NUMBER
 ,p_organization_id      IN  NUMBER
 ,p_change_id            IN  NUMBER
 ,p_change_line_id       IN  NUMBER
 ,p_acd_type             IN  VARCHAR2 := NULL
 ,x_single_row_attrs_rec IN OUT NOCOPY  EGO_ITEM_PUB.UCCNET_ATTRS_SINGL_ROW_REC_TYP
 ,x_multi_row_attrs_tbl  IN OUT NOCOPY  EGO_ITEM_PUB.UCCNET_ATTRS_MULTI_ROW_TBL_TYP
 ,x_extra_attrs_rec      IN OUT NOCOPY  EGO_ITEM_PUB.UCCNET_EXTRA_ATTRS_REC_TYP
) ;

PROCEDURE VALIDATE_GDSN_ATTR_CHGS
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_cm_process_type   IN  VARCHAR2  := NULL
) ;



/********************************************************************
* API Type      : Derive and Populate Values APIs
* Purpose       : Perform Deriving and Populating values to Interface table
*********************************************************************/


PROCEDURE POPULATE_EXISTING_CHANGE
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_change_number     IN  VARCHAR2  := NULL
 ,  p_process_entity    IN  VARCHAR2  := NULL
 ,  p_cm_process_type   IN  VARCHAR2  := NULL
 ,  p_item_id           IN  NUMBER    := NULL
 ,  p_org_id            IN  NUMBER    := NULL
 ,  p_create_new_flag   IN  VARCHAR2  := NULL -- N: New, E: Add to Existing
) ;


PROCEDURE POPULATE_EXISTING_REV_ITEMS
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_process_entity    IN  VARCHAR2  := NULL
 ,  p_cm_process_type   IN  VARCHAR2  := NULL
 ,  p_item_id           IN  NUMBER    := NULL
 ,  p_org_id            IN  NUMBER    := NULL
) ;


PROCEDURE UPDATE_PROCESS_STATUS
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_from_status       IN  NUMBER
 ,  p_to_status         IN  NUMBER
 ,  p_process_entity    IN  VARCHAR2  := NULL
 ,  p_item_id           IN  NUMBER    := NULL
 ,  p_org_id            IN  NUMBER    := NULL
 ,  p_transaction_id    IN  NUMBER    := NULL
) ;

FUNCTION get_Rev_item_update_parent ( p_change_id     IN NUMBER
                           , p_organization_id        IN NUMBER
                           , p_revised_item_id        IN NUMBER
                           , p_revision               IN VARCHAR2
                           , p_default_seq_id         IN NUMBER := NULL
                           , p_revision_import_policy IN VARCHAR2 := NULL
                            )
RETURN NUMBER;

FUNCTION FIND_REV_ITEM_REC ( p_change_notice          IN VARCHAR2
                           , p_organization_id        IN NUMBER
                           , p_revised_item_id        IN NUMBER
                           , p_revision_id            IN NUMBER := NULL
                           , p_default_seq_id         IN NUMBER := NULL
                           , p_revision_import_policy IN VARCHAR2 := NULL
                            )
RETURN NUMBER;

FUNCTION FIND_REV_ITEM_REC ( p_change_id              IN NUMBER
                           , p_organization_id        IN NUMBER
                           , p_revised_item_id        IN NUMBER
                           , p_revision               IN VARCHAR2
                           , p_default_seq_id         IN NUMBER := NULL
                           , p_revision_import_policy IN VARCHAR2 := NULL
                            )
RETURN NUMBER ;


FUNCTION FIND_REV_ITEM_REC ( p_change_id              IN NUMBER
                           , p_organization_id        IN NUMBER
                           , p_revised_item_id        IN NUMBER
                           , p_revision_id            IN NUMBER := NULL
                           , p_default_seq_id         IN NUMBER := NULL
                           , p_revision_import_policy IN VARCHAR2 := NULL
                            )
RETURN NUMBER ;

PROCEDURE PREPROCESS_BOM_INTERFACE_ROWS
(   p_api_version               IN  NUMBER
 ,  p_init_msg_list             IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit                    IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level          IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status             OUT NOCOPY VARCHAR2
 ,  x_msg_count                 OUT NOCOPY NUMBER
 ,  x_msg_data                  OUT NOCOPY VARCHAR2
 ,  p_debug                     IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir                IN  VARCHAR2  := NULL
 ,  p_debug_filename            IN  VARCHAR2  := NULL
 ,  p_change_id                 IN NUMBER
 ,  p_change_notice             IN VARCHAR2
 ,  p_organization_id           IN NUMBER
 ,  p_revised_item_id           IN NUMBER
 ,  p_alternate_bom_designator  IN VARCHAR2
 ,  p_bill_sequence_id          IN NUMBER
 ,  p_effectivity_date          IN DATE     := NULL
 ,  p_from_end_item_unit_number IN VARCHAR2 := NULL
 ,  p_from_end_item_rev_id      IN NUMBER   := NULL
 ,  p_current_date              IN DATE     := NULL
 ,  p_revised_item_sequence_id  IN NUMBER
 ,  p_parent_rev_eff_date       IN DATE     := NULL
 ,  p_parent_revision_id        IN NUMBER   := NULL
 ,  p_batch_id                  IN NUMBER
 ,  p_request_id                IN NUMBER
) ;

PROCEDURE CREATE_ORPHAN_COMPONENT_INTF
(   p_api_version               IN  NUMBER
 ,  p_init_msg_list             IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit                    IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level          IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status             OUT NOCOPY VARCHAR2
 ,  x_msg_count                 OUT NOCOPY NUMBER
 ,  x_msg_data                  OUT NOCOPY VARCHAR2
 ,  p_debug                     IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir                IN  VARCHAR2  := NULL
 ,  p_debug_filename            IN  VARCHAR2  := NULL
 ,  p_organization_id           IN NUMBER
 ,  p_assembly_item_id          IN NUMBER
 ,  p_alternate_bom_designator  IN VARCHAR2
 ,  p_bill_sequence_id          IN NUMBER
 ,  p_component_item_id         IN NUMBER
 ,  p_op_seq_number             IN NUMBER
 ,  p_effectivity_date          IN DATE     := NULL
 ,  p_component_seq_id          IN NUMBER
 ,  p_from_end_item_unit_number IN VARCHAR2 := NULL
 ,  p_from_end_item_rev_id      IN NUMBER   := NULL
 ,  p_batch_id                  IN NUMBER
);

PROCEDURE CREATE_ORPHAN_HEADER_INTF
(   p_api_version               IN  NUMBER
 ,  p_init_msg_list             IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit                    IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level          IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status             OUT NOCOPY VARCHAR2
 ,  x_msg_count                 OUT NOCOPY NUMBER
 ,  x_msg_data                  OUT NOCOPY VARCHAR2
 ,  p_debug                     IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir                IN  VARCHAR2  := NULL
 ,  p_debug_filename            IN  VARCHAR2  := NULL
 ,  p_organization_id           IN NUMBER
 ,  p_assembly_item_id          IN NUMBER
 ,  p_alternate_bom_designator  IN VARCHAR2
 ,  p_bill_sequence_id          IN NUMBER
 ,  p_batch_id                  IN NUMBER
);

PROCEDURE PREPROCESS_COMP_CHILD_ROWS
(   p_api_version               IN  NUMBER
 ,  p_init_msg_list             IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit                    IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level          IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status             OUT NOCOPY VARCHAR2
 ,  x_msg_count                 OUT NOCOPY NUMBER
 ,  x_msg_data                  OUT NOCOPY VARCHAR2
 ,  p_debug                     IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir                IN  VARCHAR2  := NULL
 ,  p_debug_filename            IN  VARCHAR2  := NULL
 ,  p_organization_id           IN NUMBER
 ,  p_assembly_item_id          IN NUMBER
 ,  p_alternate_bom_designator  IN VARCHAR2
 ,  p_bill_sequence_id          IN NUMBER
 ,  p_change_id                 IN NUMBER
 ,  p_change_notice             IN VARCHAR2
 ,  p_batch_id                  IN NUMBER
);
/********************************************************************
* API Type      : Imported Changes Handler and APIs
* Purpose       : Imported Changes Table Handler
*********************************************************************/
PROCEDURE INSERT_IMPORTED_CHANGE_HISTORY
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_change_ids        IN  FND_ARRAY_OF_NUMBER_25
) ;


procedure INSERT_IMPORT_CHANGE_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_BATCH_ID in NUMBER,
  X_CHANGE_ID in NUMBER ,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);


--
-- procedure LOCK_IMPORT_CHANGE_ROW (
--   X_BATCH_ID in NUMBER,
--   X_CHANGE_ID in NUMBER
-- );

--
-- procedure UPDATE_IMPORT_CHANGE_ROW (
--   X_BATCH_ID in NUMBER,
--   X_CHANGE_ID in NUMBER
--   X_LAST_UPDATE_DATE in DATE,
--   X_LAST_UPDATED_BY in NUMBER,
--   X_LAST_UPDATE_LOGIN in NUMBER
-- );


procedure DELETE_IMPORT_CHANGE_ROW (
  X_BATCH_ID in NUMBER,
  X_CHANGE_ID in NUMBER
);

FUNCTION Get_Nulled_out_Value(value IN VARCHAR2)
RETURN VARCHAR2;


FUNCTION Get_Nulled_out_Value(value IN DATE)
RETURN DATE;


FUNCTION Get_Nulled_out_Value(value IN NUMBER)
RETURN NUMBER ;

PROCEDURE Update_Rev_Level_Trans_Type(
     p_api_version                   IN   NUMBER
    ,p_application_id                IN   NUMBER
    ,p_attr_group_type               IN   VARCHAR2
    ,p_object_name                   IN   VARCHAR2
    ,p_data_set_id                   IN   NUMBER
    ,p_entity_id                     IN   NUMBER     DEFAULT NULL
    ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
    ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_data                      OUT NOCOPY VARCHAR2
) ;


PROCEDURE IS_CHANGE_REC_EXIST_FOR_BAT (
  p_batch_id          IN  NUMBER,
  p_batch_type        IN  VARCHAR2  := NULL,
  p_process_entity    IN  VARCHAR2  := NULL,
  p_cm_process_type   IN  VARCHAR2  := NULL,
  x_change_rec_exist  OUT NOCOPY NUMBER  --1=YES, 2=NO
) ;


END ENG_CHANGE_IMPORT_UTIL ;

/
