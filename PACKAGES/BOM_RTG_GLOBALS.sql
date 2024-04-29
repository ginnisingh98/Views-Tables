--------------------------------------------------------
--  DDL for Package BOM_RTG_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: BOMRGLBS.pls 120.1 2006/06/14 06:09:28 abbhardw noship $*/
/**************************************************************************
--
--  FILENAME
--
--      BOMRGLBS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_RTG_Globals
--
--  NOTES
--
--  HISTORY
--  02-AUG-2000 Biao Zhang      Initial Creation
--
--
****************************************************************************/
	G_OPR_CREATE        CONSTANT    VARCHAR2(30) := 'CREATE';
	G_OPR_UPDATE        CONSTANT    VARCHAR2(30) := 'UPDATE';
	G_OPR_DELETE        CONSTANT    VARCHAR2(30) := 'DELETE';
	G_OPR_LOCK          CONSTANT    VARCHAR2(30) := 'LOCK';
	G_OPR_NONE          CONSTANT    VARCHAR2(30) := NULL;
	G_OPR_CANCEL        CONSTANT    VARCHAR2(30) := 'CANCEL';
	G_RECORD_FOUND      CONSTANT    VARCHAR2(1)  := 'F';
	G_RECORD_NOT_FOUND  CONSTANT    VARCHAR2(1)  := 'N';
	G_MODEL             CONSTANT    NUMBER       := 1;
	G_OPTION_CLASS      CONSTANT    NUMBER       := 2;
	G_PLANNING          CONSTANT    NUMBER       := 3;
	G_STANDARD          CONSTANT    NUMBER       := 4;
	G_PRODUCT_FAMILY    CONSTANT    NUMBER       := 5;
	G_FLOW_RTG          CONSTANT    NUMBER       := 1;
	G_STD_RTG           CONSTANT    NUMBER       := 2;
	G_LOT_RTG           CONSTANT    NUMBER       := 3;
	G_ECO_BO	    CONSTANT	VARCHAR2(3)  := 'ECO';
	G_BOM_BO	    CONSTANT	VARCHAR2(3)  := 'BOM';
	G_RTG_BO	    CONSTANT	VARCHAR2(3)  := 'RTG';
	G_ASSET_GROUP       CONSTANT    NUMBER       := 1;
	G_ASSET_ACTIVITY    CONSTANT    NUMBER       := 2;
	G_REBUILDABLE       CONSTANT    NUMBER       := 3;
	G_EVENT_OP          CONSTANT    NUMBER       := 1; -- Added for bug 2689249
	G_PROCESS_OP	    CONSTANT    NUMBER       := 2;
	G_LINE_OP	    CONSTANT    NUMBER	     := 3;
	G_Init_Eff_Date_Op_Num_Flag	BOOLEAN	     := FALSE; -- Added for bug 2767019


	TYPE Temp_Op_Rec_Type IS RECORD
	( old_op_seq_num	NUMBER
	, new_op_seq_num	NUMBER
	, old_start_eff_date	DATE
	, new_start_eff_date	DATE
	);

	TYPE Temp_Op_Rec_Tbl_Type IS TABLE OF Temp_Op_Rec_Type
	INDEX BY BINARY_INTEGER;

	TYPE SYSTEM_INFORMATION_REC_TYPE IS RECORD
	(  Entity               VARCHAR2(30)    := NULL
	 , Org_Id               NUMBER          := NULL
	 , Eco_Name             VARCHAR2(10)    := NULL
	 , User_Id              NUMBER          := NULL
	 , Login_Id             NUMBER          := NULL
	 , Prog_AppId           NUMBER          := NULL
	 , Prog_Id              NUMBER          := NULL
	 , Request_Id           NUMBER          := NULL
	 , ECO_Impl             BOOLEAN         := NULL
	 , ECO_Cancl            BOOLEAN         := NULL
	 , WKFL_Process         BOOLEAN         := NULL
	 , ECO_Access           BOOLEAN         := NULL
	 , RITEM_Impl           BOOLEAN         := NULL
	 , RITEM_Cancl          BOOLEAN         := NULL
	 , RCOMP_Cancl          BOOLEAN         := NULL
         , ROP_Cancl            BOOLEAN         := NULL -- Added by MK
	 , STD_Item_Access      NUMBER          := NULL
	 , MDL_Item_Access      NUMBER          := NULL
	 , PLN_Item_Access      NUMBER          := NULL
	 , OC_Item_Access       NUMBER          := NULL
	 , Routing_Sequence_Id  NUMBER          := NULL
	 , Common_Rtg_Seq_Id    NUMBER          := NULL
	 , CFM_Rtg_Flag         NUMBER          := NULL
	 , Current_Revision     VARCHAR2(3)     := NULL
	 , BO_Identifier        VARCHAR2(3)     := 'ECO'
	 , Unit_Effectivity     BOOLEAN         := FALSE
	 , Unit_Controlled_Item BOOLEAN         := FALSE
	 , Unit_Controlled_Component BOOLEAN    := FALSE
	 , Require_Item_Rev	NUMBER		:= NULL  -- based on profile
	 , Debug_Flag		VARCHAR2(1)	:= 'N'
         , Lot_Number           VARCHAR2(30)    := NULL
         , From_Wip_Entity_Id   NUMBER          := NULL
         , To_Wip_Entity_Id     NUMBER          := NULL
         , From_Cum_Qty         NUMBER          := NULL
         , Eco_For_Production   NUMBER          := 2
         , New_Routing_Revision VARCHAR2(30)    := NULL
         , Eam_Item_Type        NUMBER          := NULL  -- Added for eAM enhancement
         , Osfm_NW_Calc_Flag   BOOLEAN          := FALSE -- added for OSFM to check if whole routing calc has been done at the start of the change in routing
         , Osfm_NW_Count       NUMBER           := NULL  -- added for OSFM to check that we have processed all the records so that we can then do post network calcs.
	);

	PROCEDURE Init_System_Info_Rec
	(   x_mesg_token_tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	,   x_return_status     IN OUT NOCOPY VARCHAR2
	);

	FUNCTION Get_System_Information
		RETURN BOM_Rtg_Globals.System_Information_Rec_Type;
	PROCEDURE Set_System_Information
          ( p_system_information_rec    IN
                        BOM_Rtg_Globals.System_Information_Rec_Type);
	PROCEDURE Set_Routing_Sequence_id
          ( p_Routing_sequence_id  IN  NUMBER);
	FUNCTION Get_Routing_Sequence_id RETURN NUMBER;
	PROCEDURE Set_Common_Rtg_Seq_id
          ( p_common_Rtg_seq_id  IN  NUMBER);
	FUNCTION Get_Common_Rtg_Seq_id RETURN NUMBER;
	PROCEDURE Set_Entity
          ( p_entity    IN  VARCHAR2);
	FUNCTION Get_Entity RETURN VARCHAR2;
	PROCEDURE Set_Org_id
          ( p_org_id    IN  NUMBER);
	FUNCTION Get_Org_id RETURN NUMBER;
	PRAGMA RESTRICT_REFERENCES(Get_Org_id, WNDS);
	PROCEDURE Set_Eco_Name
          ( p_eco_name  IN VARCHAR2);
	FUNCTION Get_Eco_Name RETURN VARCHAR2;
	PROCEDURE Set_User_Id
          ( p_user_id   IN  NUMBER);
	FUNCTION Get_User_ID RETURN NUMBER;
	PRAGMA RESTRICT_REFERENCES(Get_User_Id, WNDS);
	PROCEDURE Set_Login_Id
          ( p_login_id  IN NUMBER );
	FUNCTION Get_Login_Id RETURN NUMBER;
	PRAGMA RESTRICT_REFERENCES(Get_Login_Id, WNDS);
	PROCEDURE Set_Prog_AppId
          ( p_prog_Appid        IN  NUMBER );
	FUNCTION Get_Prog_AppId RETURN NUMBER;
	PRAGMA RESTRICT_REFERENCES(Get_Prog_AppId, WNDS);
	PROCEDURE Set_Prog_Id
          ( p_prog_id   IN  NUMBER );
	FUNCTION Get_Prog_Id RETURN NUMBER;
	PRAGMA RESTRICT_REFERENCES(Get_Prog_Id, WNDS);
	PROCEDURE Set_Request_Id
          ( p_request_id        IN  NUMBER );
	FUNCTION Get_Request_id RETURN NUMBER;
	PRAGMA RESTRICT_REFERENCES(Get_Request_Id, WNDS);
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
	PROCEDURE Set_Std_Item_Access
          ( p_std_item_access   IN  NUMBER );
        -- ECO for Routing
        PROCEDURE Set_ROp_Cancl
          ( p_rcomp_cancl        IN  BOOLEAN );
        FUNCTION Is_ROp_Cancl RETURN BOOLEAN;
        -- Added by MK on 09/01/2000
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
	PROCEDURE Set_Unit_Controlled_Item
          ( p_Unit_Controlled_Item IN BOOLEAN);
	PROCEDURE Set_Unit_Controlled_Item
	  ( p_inventory_item_id  IN NUMBER
	  , p_organization_id    IN NUMBER);
	FUNCTION Get_Unit_Controlled_Item RETURN BOOLEAN;
	PROCEDURE Set_Unit_Controlled_Component
          ( p_Unit_Controlled_Component IN BOOLEAN);
        PROCEDURE Set_Unit_Controlled_Component
          ( p_inventory_item_id  IN NUMBER
          , p_organization_id    IN NUMBER);
	FUNCTION Get_Unit_Controlled_Component RETURN BOOLEAN;

	PROCEDURE Set_Unit_Effectivity
          ( p_Unit_Effectivity IN  BOOLEAN );
	FUNCTION Get_Unit_Effectivity RETURN BOOLEAN;

	PROCEDURE Set_Require_Item_Rev
	  ( p_Require_Rev      IN NUMBER );
	FUNCTION Is_Item_Rev_Required RETURN NUMBER;

	PROCEDURE Set_Request_For_Approval
	(   p_change_notice                 IN  VARCHAR2
	,   p_organization_id               IN  NUMBER
	,   x_err_text                      IN OUT NOCOPY VARCHAR2
	);

	PROCEDURE Check_Approved_For_Process
	(   p_change_notice                 IN  VARCHAR2
	,   p_organization_id               IN  NUMBER
	,   x_processed                     IN OUT NOCOPY BOOLEAN
	,   x_err_text                      IN OUT NOCOPY VARCHAR2
	);

        PROCEDURE Set_CFM_Rtg_Flag
        (  p_cfm_rtg_type    IN NUMBER
        );

        FUNCTION Get_CFM_Rtg_Flag
        RETURN NUMBER ;

	FUNCTION Get_Process_Name RETURN VARCHAR2;

	PROCEDURE Init_Process_Name
	(   p_change_order_type_id          IN  NUMBER
	,   p_priority_code                 IN  VARCHAR2
	,   p_organization_id               IN  NUMBER
	);


	PROCEDURE Transaction_Type_Validity
	(   p_transaction_type          IN  VARCHAR2
	,   p_entity                    IN  VARCHAR2
	,   p_entity_id                 IN  VARCHAR2
	,   x_valid                     IN OUT NOCOPY BOOLEAN
	,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	);

	PROCEDURE Set_Debug
	(  p_debug_flag			IN  VARCHAR2
	 );

	FUNCTION Get_Debug RETURN VARCHAR2;

        PROCEDURE Set_Lot_Number
          ( p_lot_number IN  VARCHAR2 );
        FUNCTION Get_Lot_Number RETURN VARCHAR2;

        PROCEDURE Set_From_Wip_Entity_Id
          ( p_from_wip_entity_id IN  NUMBER);
        FUNCTION Get_From_Wip_Entity_Id RETURN NUMBER;

        PROCEDURE Set_To_Wip_Entity_Id
          ( p_to_wip_entity_id IN  NUMBER);
        FUNCTION Get_To_Wip_Entity_Id RETURN NUMBER;

        PROCEDURE Set_From_Cum_Qty
          ( p_from_cum_qty IN  NUMBER);
        FUNCTION Get_From_Cum_Qty RETURN NUMBER;

        PROCEDURE Set_Eco_For_Production
          ( p_eco_for_production IN  NUMBER);
        FUNCTION Get_Eco_For_Production RETURN NUMBER;

        PROCEDURE Set_New_Routing_Revision
          ( p_new_routing_revision IN  VARCHAR2 );
        FUNCTION Get_New_Routing_Revision RETURN VARCHAR2;

        -- Added for eAM enhancement
        PROCEDURE Set_Eam_Item_Type( p_eam_item_type IN NUMBER );

        FUNCTION Get_Eam_Item_Type RETURN NUMBER ;

	PROCEDURE Set_Osfm_NW_Calc_Flag
          ( p_nw_calc_flag IN  BOOLEAN );
	FUNCTION Is_Osfm_NW_Calc_Flag RETURN BOOLEAN;

	PROCEDURE Add_Osfm_NW_Count
          ( p_nw_number IN  NUMBER );
	PROCEDURE Set_Osfm_NW_Count
          ( p_nw_count IN  NUMBER );
	FUNCTION Get_Osfm_NW_Count RETURN NUMBER;

	FUNCTION Get_Temp_Op_Rec
          ( p_op_seq_num  IN NUMBER
	  , p_temp_op_rec IN OUT NOCOPY Temp_Op_Rec_Type
	  ) RETURN BOOLEAN;
	PROCEDURE Set_Temp_Op_Tbl
          ( p_temp_op_rec_tbl IN  Temp_Op_Rec_Tbl_Type);

	FUNCTION Get_Temp_Op_Rec1
          ( p_op_seq_num  IN NUMBER
	  , p_eff_date	  IN DATE
	  , p_temp_op_rec IN OUT NOCOPY Temp_Op_Rec_Type
	  ) RETURN BOOLEAN;

	-- BUG 5330942
	FUNCTION Get_Routing_Header_ECN
	  ( p_routing_seq_id IN NUMBER ) RETURN VARCHAR2;

END BOM_RTG_Globals;

 

/
