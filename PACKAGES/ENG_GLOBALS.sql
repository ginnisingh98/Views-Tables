--------------------------------------------------------
--  DDL for Package ENG_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: ENGSGLBS.pls 120.0.12010000.2 2009/11/12 23:11:03 umajumde ship $ */

--  Product entity constants.

--  START GEN entities
G_ENTITY_ALL                   CONSTANT VARCHAR2(30) := 'ALL';
G_ENTITY_ECO                   CONSTANT VARCHAR2(30) := 'ECO';
G_ENTITY_ECO_REVISION          CONSTANT VARCHAR2(30) := 'ECO_REVISION';
G_ENTITY_REVISED_ITEM          CONSTANT VARCHAR2(30) := 'REVISED_ITEM';
G_ENTITY_REV_COMPONENT         CONSTANT VARCHAR2(30) := 'REV_COMPONENT';
G_ENTITY_REF_DESIGNATOR        CONSTANT VARCHAR2(30) := 'REF_DESIGNATOR';
G_ENTITY_SUB_COMPONENT         CONSTANT VARCHAR2(30) := 'SUB_COMPONENT';
-- Followings are added by MK on 09/15/2000
G_ENTITY_REV_OPERATION         CONSTANT VARCHAR2(30) := 'REV_OPERATION';
G_ENTITY_REV_OP_RESOURCE       CONSTANT VARCHAR2(30) := 'REV_OP_RESOURCE';
G_ENTITY_REV_SUB_RESOURCE      CONSTANT VARCHAR2(30) := 'REV_SUB_RESOURCE';


--  END GEN entities

-- Seeded Change Mgmt Type Code
G_CHANGE_REQUEST    CONSTANT VARCHAR2(30) := 'CHANGE_REQUEST' ; -- Change Request
G_CHANGE_ORDER      CONSTANT VARCHAR2(30) := 'CHANGE_ORDER' ;   -- Change Order

--  Operations.

G_OPR_CREATE	    CONSTANT	VARCHAR2(10) := 'CREATE';
G_OPR_UPDATE	    CONSTANT	VARCHAR2(10) := 'UPDATE';
G_OPR_DELETE	    CONSTANT	VARCHAR2(10) := 'DELETE';
G_OPR_LOCK	    CONSTANT	VARCHAR2(30) := 'LOCK';
G_OPR_NONE	    CONSTANT	VARCHAR2(30) := NULL;
G_OPR_CANCEL	    CONSTANT    VARCHAR2(30) := 'CANCEL';
G_RECORD_FOUND	    CONSTANT	VARCHAR2(1)  := 'F';
G_RECORD_NOT_FOUND  CONSTANT	VARCHAR2(1)  := 'N';
G_MODEL		    CONSTANT	NUMBER	     := 1;
G_OPTION_CLASS	    CONSTANT    NUMBER	     := 2;
G_PLANNING	    CONSTANT	NUMBER	     := 3;
G_STANDARD	    CONSTANT	NUMBER	     := 4;
G_PRODUCT_FAMILY    CONSTANT	NUMBER	     := 5;

--  Max number of defaulting itterations.

G_MAX_DEF_ITTERATIONS         CONSTANT NUMBER:= 5;

--Bug no 2818039
G_ENG_LAUNCH_IMPORT    NUMBER :=0;

--  API Operation control flags.

TYPE Control_Rec_Type IS RECORD
(   controlled_operation          BOOLEAN := FALSE
,   default_attributes            BOOLEAN := TRUE
,   change_attributes             BOOLEAN := TRUE
,   validate_entity               BOOLEAN := TRUE
,   write_to_db                   BOOLEAN := TRUE
,   process                       BOOLEAN := TRUE
,   process_entity                VARCHAR2(30) := G_ENTITY_ALL
,   clear_api_cache               BOOLEAN := TRUE
,   clear_api_requests            BOOLEAN := TRUE
,   request_category              VARCHAR2(30):= NULL
,   request_name                  VARCHAR2(30):= NULL
);

--  Variable representing missing control record.

G_MISS_CONTROL_REC            Control_Rec_Type;

--  API request record type.

TYPE Request_Rec_Type IS RECORD
(   entity                        VARCHAR2(30) := NULL
,   step                          VARCHAR2(30) := NULL
,   name                          VARCHAR2(30) := NULL
,   category                      VARCHAR2(30) := NULL
,   processed                     BOOLEAN := FALSE
,   attribute1                    VARCHAR2(240) := NULL
,   attribute2                    VARCHAR2(240) := NULL
,   attribute3                    VARCHAR2(240) := NULL
,   attribute4                    VARCHAR2(240) := NULL
,   attribute5                    VARCHAR2(240) := NULL
);

--  API Request table type.

TYPE Request_Tbl_Type IS TABLE OF Request_Rec_Type
    INDEX BY BINARY_INTEGER;

-- API Request table.

G_REQUEST_TBL		Request_Tbl_Type;

--  API request record key type.

TYPE Request_Key_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240) := NULL
,   attribute2                    VARCHAR2(240) := NULL
,   attribute3                    VARCHAR2(240) := NULL
,   attribute4                    VARCHAR2(240) := NULL
,   attribute5                    VARCHAR2(240) := NULL
);

--  API Request Key table type.

TYPE Request_Key_Tbl_Type IS TABLE OF Request_Key_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Error text

G_ERR_TEXT	VARCHAR2(100) := NULL;

--  API record type containing WHO and other parameters used during defaulting and error reporting.

TYPE WHO_Rec_Type IS RECORD
(   entity                        VARCHAR2(30) := NULL
,   org_id                        NUMBER := NULL
,   user_id                       NUMBER := NULL
,   login_id                      NUMBER := NULL
,   prog_appid                    NUMBER := NULL
,   prog_id	                  NUMBER := NULL
,   req_id	                  NUMBER := NULL
,   TRANSACTION_ID	          NUMBER := NULL
);

TYPE SYSTEM_INFORMATION_REC_TYPE IS RECORD
(  Entity		VARCHAR2(30) 	:= NULL
 , org_id		NUMBER	     	:= NULL
 , Eco_Name		VARCHAR2(10) 	:= NULL
 , User_Id		NUMBER		:= NULL
 , Login_Id		NUMBER		:= NULL
 , Prog_AppId		NUMBER		:= NULL
 , Prog_Id		NUMBER		:= NULL
 , Request_Id		NUMBER		:= NULL
 , ECO_Impl		BOOLEAN		:= NULL
 , ECO_Cancl		BOOLEAN		:= NULL
 , WKFL_Process		BOOLEAN		:= NULL
 , ECO_Access		BOOLEAN		:= NULL
 , RITEM_Impl		BOOLEAN		:= NULL
 , RITEM_Cancl		BOOLEAN		:= NULL
 , RCOMP_Cancl		BOOLEAN		:= NULL
 , ROP_Cancl            BOOLEAN         := NULL -- Added by MK
 , STD_Item_Access	NUMBER		:= NULL
 , MDL_Item_Access	NUMBER 		:= NULL
 , PLN_Item_Access	NUMBER 		:= NULL
 , OC_Item_Access	NUMBER 		:= NULL
 , Bill_Sequence_Id	NUMBER		:= NULL
 , Current_Revision	VARCHAR2(3)	:= NULL
 , BO_Identifier	VARCHAR2(3)	:= 'ECO'
 , Unit_Effectivity	BOOLEAN		:= FALSE
 , Unit_Controlled_Item	BOOLEAN		:= FALSE
 , Unit_Controlled_Component BOOLEAN	:= FALSE
);

-- API WHO record


-- System information is now defined in the body and accessed
-- using Get/Set functions and procedures. Changed 06/23/99 by RC.
--
-- System_Information	System_Information_Rec_Type;
--
G_WHO_REC 		WHO_Rec_Type;

-- Initialize system information record

PROCEDURE Init_System_Info_Rec
(   x_mesg_token_tbl    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status     OUT NOCOPY VARCHAR2
);

-- Check transaction_type validity

PROCEDURE Transaction_Type_Validity
(   p_transaction_type              IN  VARCHAR2
,   p_entity			    IN  VARCHAR2
,   p_entity_id			    IN  VARCHAR2
,   x_valid			    OUT NOCOPY BOOLEAN
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
);

--  Initialize control record.

FUNCTION Init_Control_Rec
(   p_operation                     IN  VARCHAR2
,   p_control_rec                   IN  Control_Rec_Type
,   x_err_text			    OUT NOCOPY VARCHAR2
)RETURN Control_Rec_Type;


--  Initialize WHO record.

PROCEDURE Init_WHO_Rec
( p_org_id IN NUMBER
, p_user_id IN NUMBER
, p_login_id IN NUMBER
, p_prog_appid IN NUMBER
, p_prog_id IN NUMBER
, p_req_id IN NUMBER
);

-- Load entity and record-specific details into WHO record

PROCEDURE Init_WHO_Rec_Entity_Details
( p_entity IN VARCHAR2
, p_transaction_id IN NUMBER
);

-- Initialize Workflow Process Name for ECO approval

PROCEDURE Init_Process_Name
(   p_change_order_type_id          IN  NUMBER
,   p_priority_code		    IN  VARCHAR2
,   p_organization_id		    IN  NUMBER
);

-- Get Workflow Process Name for ECO approval

FUNCTION Get_Process_Name
RETURN VARCHAR2;

-- Log a request in the Request Table

PROCEDURE Add_Request
(   p_entity 			    IN  VARCHAR2
,   p_step			    IN 	VARCHAR2 := NULL
,   p_name			    IN 	VARCHAR2
,   p_category			    IN 	VARCHAR2 := NULL
,   p_processed		  	    IN 	BOOLEAN := FALSE
,   p_attribute1		    IN 	VARCHAR2 := NULL
,   p_attribute2		    IN 	VARCHAR2 := NULL
,   p_attribute3		    IN 	VARCHAR2 := NULL
,   p_attribute4		    IN 	VARCHAR2 := NULL
,   p_attribute5		    IN 	VARCHAR2 := NULL
);

-- Check if request has been logged. If yes, has it been processed ?
-- Returns TRUE if already processed, or if request not found.
-- Returns FALSE if not processed.

FUNCTION Get_Request_Status
(   p_entity 			    IN  VARCHAR2
,   p_step			    IN 	VARCHAR2 := NULL
,   p_name			    IN 	VARCHAR2
,   p_category			    IN 	VARCHAR2 := NULL
,   p_attribute1		    IN 	VARCHAR2 := NULL
,   p_attribute2		    IN 	VARCHAR2 := NULL
,   p_attribute3		    IN 	VARCHAR2 := NULL
,   p_attribute4		    IN 	VARCHAR2 := NULL
,   p_attribute5		    IN 	VARCHAR2 := NULL
)RETURN BOOLEAN;

-- Checks if there is an unprocessed request that matches the parameters

FUNCTION Get_Unprocessed_Request
(   p_entity 			    IN  VARCHAR2
,   p_step			    IN 	VARCHAR2 := NULL
,   p_name			    IN 	VARCHAR2
,   p_category			    IN 	VARCHAR2 := NULL
,   p_attribute1		    IN 	VARCHAR2 := NULL
,   p_attribute2		    IN 	VARCHAR2 := NULL
,   p_attribute3		    IN 	VARCHAR2 := NULL
,   p_attribute4		    IN 	VARCHAR2 := NULL
,   p_attribute5		    IN 	VARCHAR2 := NULL
)RETURN BOOLEAN;

-- Deletes all rows from Request Table

PROCEDURE Clear_Request_Table;

-- If an approved ECO has a process and any part of the ECO is being modified,
-- set ECO Approval Status to 'Not Submitted for Approval' and
-- set Status Type of any scheduled revised items to 'Open'.
-- Also issue warning.

PROCEDURE Check_Approved_For_Process
(   p_change_notice                 IN  VARCHAR2
,   p_organization_id		    IN  NUMBER
,   x_processed			    OUT NOCOPY BOOLEAN
,   x_err_text			    OUT NOCOPY VARCHAR2
);

-- Sets ECO to 'Not Submitted For Approval' and any
-- "Scheduled" revised items to "Open"

PROCEDURE Set_Request_For_Approval
(   p_change_notice                 IN  VARCHAR2
,   p_organization_id		    IN  NUMBER
,   x_err_text			    OUT NOCOPY VARCHAR2
);

-- Function Get_ECO_Assembly_Type
-- Returns ECO assembly type

FUNCTION Get_ECO_Assembly_Type
( p_change_notice IN VARCHAR2
, p_organization_id IN NUMBER
) RETURN NUMBER;

-- Function ECO_Cannot_Update
-- Checks if the ECO should not be updated

FUNCTION ECO_Cannot_Update
( p_change_notice IN VARCHAR2
, p_organization_id IN NUMBER
)RETURN BOOLEAN;

-- Function Get_PLM_Or_ERP_Change
-- Checks if the ECO is 'PLM' or 'ERP'
-- Added for 3618676

FUNCTION Get_PLM_Or_ERP_Change
( p_change_notice IN VARCHAR2
, p_organization_id IN NUMBER
) RETURN VARCHAR2;

/*** Get and Set procedure and function defintion for the system information
* record.
*
***/

FUNCTION Get_System_Information RETURN Eng_Globals.System_Information_Rec_Type;
PROCEDURE Set_System_Information
          ( p_system_information_rec    IN
                        Eng_Globals.System_Information_Rec_Type);
PROCEDURE Set_Bill_Sequence_id
          ( p_bill_sequence_id  IN  NUMBER);
FUNCTION Get_Bill_Sequence_id RETURN NUMBER;
PROCEDURE Set_Entity
          ( p_entity    IN  VARCHAR2);
FUNCTION Get_Entity RETURN VARCHAR2;
PROCEDURE Set_Org_id
          ( p_org_id    IN  NUMBER);
FUNCTION Get_Org_id RETURN NUMBER;
PROCEDURE Set_Eco_Name
          ( p_eco_name  IN VARCHAR2);
FUNCTION Get_Eco_Name RETURN VARCHAR2;
PROCEDURE Set_User_Id
          ( p_user_id   IN  NUMBER);
FUNCTION Get_User_ID RETURN NUMBER;

PROCEDURE Set_Login_Id
          ( p_login_id  IN NUMBER );
FUNCTION Get_Login_Id RETURN NUMBER;

PROCEDURE Set_Prog_AppId
          ( p_prog_Appid        IN  NUMBER );
FUNCTION Get_Prog_AppId RETURN NUMBER;

PROCEDURE Set_Prog_Id
          ( p_prog_id   IN  NUMBER );
FUNCTION Get_Prog_Id RETURN NUMBER;

PROCEDURE Set_Request_Id
          ( p_request_id        IN  NUMBER );
FUNCTION Get_Request_id RETURN NUMBER;

PROCEDURE Set_Eco_Impl
          ( p_eco_impl  IN  BOOLEAN );
FUNCTION Is_Eco_Impl RETURN BOOLEAN;
PROCEDURE Set_Eco_Cancl
          ( p_eco_cancl IN  BOOLEAN );
FUNCTION Is_Eco_Cancl RETURN BOOLEAN;
PROCEDURE Set_Wkfl_Process
          ( p_wkfl_process      IN  BOOLEAN );
FUNCTION Is_Wkfl_Process RETURN BOOLEAN;
PROCEDURE Set_Eco_Access
          ( p_eco_access        IN  BOOLEAN );
FUNCTION Is_Eco_Access RETURN BOOLEAN;
PROCEDURE Set_RItem_Impl
          ( p_ritem_impl        IN  BOOLEAN );
FUNCTION Is_RItem_Impl RETURN BOOLEAN;
PROCEDURE Set_RItem_Cancl
          ( p_ritem_cancl        IN  BOOLEAN );
FUNCTION Is_RItem_Cancl RETURN BOOLEAN;
PROCEDURE Set_RComp_Cancl
          ( p_rcomp_cancl        IN  BOOLEAN );
FUNCTION Is_RComp_Cancl RETURN BOOLEAN;

-- ECO for Routing
PROCEDURE Set_ROp_Cancl
          ( p_rcomp_cancl        IN  BOOLEAN );
FUNCTION Is_ROp_Cancl RETURN BOOLEAN;
-- Added by MK on 09/01/2000

PROCEDURE Set_Std_Item_Access
          ( p_std_item_access   IN  NUMBER );
FUNCTION Get_Std_Item_Access RETURN NUMBER;
PROCEDURE Set_Mdl_Item_Access
          ( p_mdl_item_access   IN  NUMBER );
FUNCTION Get_Mdl_Item_Access RETURN NUMBER;
PROCEDURE Set_Pln_Item_Access
          ( p_Pln_item_access   IN  NUMBER );
FUNCTION Get_Pln_Item_Access RETURN NUMBER;
PROCEDURE Set_OC_Item_Access
          ( p_oc_item_access   IN  NUMBER );
FUNCTION Get_OC_Item_Access RETURN NUMBER;
PROCEDURE Set_Current_Revision
          ( p_current_revision  IN  VARCHAR2 );
FUNCTION Get_Current_Revision RETURN VARCHAR2;
PROCEDURE Set_BO_Identifier
          ( p_bo_identifier     IN  VARCHAR2 );
FUNCTION Get_BO_Identifier RETURN VARCHAR2;
PROCEDURE Set_Unit_Effectivity
          ( p_Unit_Effectivity IN  BOOLEAN );
FUNCTION Get_Unit_Effectivity RETURN BOOLEAN;
PROCEDURE Set_Unit_Controlled_Item
          ( p_Unit_Controlled_Item IN BOOLEAN);
FUNCTION Get_Unit_Controlled_Item RETURN BOOLEAN;
PROCEDURE Set_Unit_Controlled_Component
          ( p_Unit_Controlled_Component IN BOOLEAN);
FUNCTION Get_Unit_Controlled_Component RETURN BOOLEAN;

/* following functions and procedure have been moved here from BOM packages to make
   the RTG object independant of the ENG object */

PROCEDURE Create_New_Routing
            ( p_assembly_item_id            IN NUMBER
            , p_organization_id             IN NUMBER
            , p_alternate_routing_code      IN VARCHAR2 := NULL
            , p_pending_from_ecn            IN VARCHAR2
            , p_routing_sequence_id         IN NUMBER
            , p_common_routing_sequence_id  IN NUMBER
            , p_routing_type                IN NUMBER
            , p_last_update_date            IN DATE
            , p_last_updated_by             IN NUMBER
            , p_creation_date               IN DATE
            , p_created_by                  IN NUMBER
            , p_login_id                    IN NUMBER
            , p_revised_item_sequence_id    IN NUMBER
            , p_original_system_reference   IN VARCHAR2
            , x_mesg_token_tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
            , x_return_status               OUT NOCOPY VARCHAR2
            ) ;

PROCEDURE Perform_Writes_For_Primary_RTG
        (  p_rev_operation_rec         IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
         , p_rev_op_unexp_rec          IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
         , p_control_rec               IN  Bom_Rtg_Pub.Control_Rec_Type
                                         := Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
         , x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status             OUT NOCOPY VARCHAR2
        ) ;

 --added the following function and procedure for Bug 9088260
 	 --begin changes  for Bug 9088260
 	 FUNCTION Compatible_Primary_Rtg_Exists
 	       (  p_revised_item_id    IN NUMBER
 	        , p_change_notice      IN VARCHAR2
 	        , p_organization_id    IN NUMBER
 	  ) RETURN BOOLEAN;


PROCEDURE Perform_Writes_For_Alt_Rtg
 	         (  p_rev_operation_rec         IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
 	          , p_rev_op_unexp_rec          IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
 	          , p_control_rec               IN  Bom_Rtg_Pub.Control_Rec_Type
 	                                          := Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
 	          , x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 	          , x_return_status             OUT NOCOPY VARCHAR2
 	         ) ;

	 --end changes  for Bug 9088260

PROCEDURE Cancel_Operation
( p_operation_sequence_id  IN  NUMBER
, p_cancel_comments        IN  VARCHAR2
, p_op_seq_num             IN  NUMBER
, p_user_id                IN  NUMBER
, p_login_id               IN  NUMBER
, p_prog_id                IN  NUMBER
, p_prog_appid             IN  NUMBER
, x_mesg_token_tbl         OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status          OUT NOCOPY VARCHAR2
) ;


END ENG_Globals;

/
