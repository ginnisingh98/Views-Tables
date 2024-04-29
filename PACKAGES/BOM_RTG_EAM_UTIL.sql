--------------------------------------------------------
--  DDL for Package BOM_RTG_EAM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_EAM_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMREAMS.pls 115.3 2002/11/21 05:52:08 djebar ship $ */
/****************************************************************************
--
--  Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMREAMS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Rtg_Eam_Util : eAM utility for routing  package
--
--  NOTES
--
--  HISTORY
--
--  12-AUG-01 Masanori Kimizuka Initial Creation
--
****************************************************************************/
--
-- eAM Maintenace Routing Network Link Record
--
TYPE Op_Nwk_Link_Rec_Type IS RECORD
   (
     from_op_seq_id       NUMBER
   , from_op_seq_num      NUMBER
   , to_op_seq_id         NUMBER
   , to_op_seq_num        NUMBER
   , transition_type      NUMBER
   , planning_pct         NUMBER
   , network_seq_num      NUMBER
   , process_flag         VARCHAR2(1)
   ) ;

TYPE Op_Nwk_Link_Tbl_Type IS TABLE OF Op_Nwk_Link_Rec_Type
INDEX BY BINARY_INTEGER;

--
-- Missing Records for Op_Nwk_Link_Rec_Type
--
G_MISS_OP_NWK_LINK_REC             Bom_Rtg_Eam_Util.Op_Nwk_Link_Rec_Type ;
G_MISS_OP_NWK_LINK_TBL             Bom_Rtg_Eam_Util.Op_Nwk_Link_Tbl_Type ;

--
-- eAM Maintenace Routing Network Operation Node Record
--
TYPE Op_Node_Rec_Type IS RECORD
   ( Operation_Sequence_Id     NUMBER
   , Operation_Sequence_Number NUMBER
   , X_Coordinate              NUMBER
   , Y_Coordinate              NUMBER
   , Transaction_Type          VARCHAR2(30)
   , Return_Status             VARCHAR2(1)
   );

TYPE Op_Node_Tbl_Type IS TABLE OF Op_Node_Rec_Type
INDEX BY BINARY_INTEGER ;

--
-- Missing Records for Op_Node_Rec_Type
--
G_MISS_OP_NODE_REC             Bom_Rtg_Eam_Util.Op_Node_Rec_Type ;
G_MISS_OP_NODE_TBL             Bom_Rtg_Eam_Util.Op_Node_Tbl_Type ;


TYPE Op_Link_Rec_Type IS RECORD
    (
     Assembly_Item_Name         VARCHAR2(81)
   , Organization_Code          VARCHAR2(3)
   , Alternate_Routing_Code     VARCHAR2(10)
   , Operation_Type             NUMBER
   , From_Op_Seq_Id             NUMBER
   , To_Op_Seq_Id               NUMBER
   , New_From_Op_Seq_Id         NUMBER
   , New_To_Op_Seq_Id           NUMBER
   , Transaction_Type           VARCHAR2(30)
   , Return_Status              VARCHAR2(1)
   ) ;

TYPE Op_Link_Tbl_Type IS TABLE OF Op_Link_Rec_Type
INDEX BY BINARY_INTEGER ;

--
-- Missing Records for Op_Node_Rec_Type
--
G_MISS_OP_NODE_REC             Bom_Rtg_Eam_Util.Op_Link_Rec_Type ;
G_MISS_OP_NODE_TBL             Bom_Rtg_Eam_Util.Op_Link_Rec_Type ;


/*******************************************************************
* Procedure     : Check_Eam_Rtg_Network
* Parameters IN : Routing Sequence Id
* Parameters OUT: Error Message
*                 Return Status
* Purpose       : Procedure will validate for eAM Rtg Network.
*                 This procedure is called by Routing BO and BOMFDONW form
*********************************************************************/
PROCEDURE Check_Eam_Rtg_Network
( p_routing_sequence_id IN  NUMBER
, x_err_msg             IN OUT NOCOPY VARCHAR2
, x_return_status       IN OUT NOCOPY VARCHAR2
 ) ;


/*******************************************************************
* Procedure     : Check_Eam_Rtg_Network
* Parameters IN : Operation Network Exposed Record
*                 Operation Network Unexposed Record
*                 Old Operation Network exposed Record
*                 Old Operation Network Unexposed Record
*                 Mesg Token Table
* Parameters OUT: Mesg Token Table
*                 Return Status
* Purpose       : Procedure will validate for eAM Rtg Network.
*                 This procedure is called by Routing BO and BOMFDONW form
*********************************************************************/
PROCEDURE Check_Eam_Rtg_Network
(  p_op_network_rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
 , p_op_network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
 , p_old_op_network_rec   IN  Bom_Rtg_Pub.Op_Network_Rec_Type
 , p_old_op_network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
 , p_mesg_token_tbl       IN  Error_Handler.Mesg_Token_Tbl_Type
 , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status        IN OUT NOCOPY VARCHAR2
 ) ;


/*******************************************************************
* Procedure     : Check_Eam_Nwk_FromOp
* Parameters IN : From Op Seq Num
*                 From Op Seq Id
*                 To Op Seq Num
*                 To Op Seq Id
* Parameters OUT: Error Code
*                 Return Status
* Purpose       : Procedure will validate for from operation in eAM Rtg Network.
*********************************************************************/
PROCEDURE Check_Eam_Nwk_FromOp
( p_from_op_seq_num     IN  NUMBER
, p_from_op_seq_id      IN  NUMBER
, p_to_op_seq_num       IN  NUMBER
, p_to_op_seq_id        IN  NUMBER
, x_err_msg             IN OUT NOCOPY VARCHAR2
, x_return_status       IN OUT NOCOPY VARCHAR2
 ) ;



/*******************************************************************
* Function      : OrgIsEamEnabled
* Parameters IN : Org Id
* Parameters OUT:
* Purpose       : Function will return the value of 'Y' or 'N'
*                 to check if organization is eAM enabled.
********************************************************************/
FUNCTION OrgIsEamEnabled(p_org_id NUMBER) RETURN VARCHAR2 ;

/***************************************************************************
* Function      : CheckShutdownType
* Returns       : BOOLEAN
* Parameters IN : p_shutdown_type
* Parameters OUT: None
* Purpose       : Function will return the value of True or False
*                 to check if ShutdownType is valid.
*****************************************************************************/
FUNCTION CheckShutdownType(p_shutdown_type IN VARCHAR2 ) RETURN BOOLEAN ;


/***************************************************************************
* Function      : Check_UpdateDept
* Returns       : BOOLEAN
* Parameters IN : p_op_seq_id, p_org_id, p_dept_id
* Parameters OUT: None
* Purpose       : Function will return the value of True or False
*                 to check if user can update the department for this operation.
*****************************************************************************/
FUNCTION Check_UpdateDept
( p_op_seq_id     IN   NUMBER
, p_org_id        IN   NUMBER
, p_dept_id       IN   NUMBER
) RETURN BOOLEAN ;


/****************************************************************************
* Procedure : Operation_Nodes
* Parameters IN   : Operation Node Table
* Parameters OUT  : Operatin Node Table and Return Status and Messages
* Purpose   : This procedure will process all the Operation Nodes records.
*
*****************************************************************************/
PROCEDURE Operation_Nodes
(   p_op_node_tbl             IN  Bom_Rtg_Eam_Util.Op_Node_Tbl_Type
,   x_op_node_tbl             IN OUT NOCOPY Bom_Rtg_Eam_Util.Op_Node_Tbl_Type
,   x_return_mesg             IN OUT NOCOPY VARCHAR2
,   x_return_status           IN OUT NOCOPY VARCHAR2
) ;


/****************************************************************************
* Procedure : Operation_Links
* Parameters IN   : Operation Links Table
* Parameters OUT  : Operatin Links Table and Return Status and Messages
* Purpose   : This procedure will process all the Operation Link records
*             using Routing Business Objects.
*****************************************************************************/
PROCEDURE Operation_Links
(   p_op_link_tbl             IN  Bom_Rtg_Eam_Util.Op_Link_Tbl_Type
,   x_op_link_tbl             IN OUT NOCOPY Bom_Rtg_Eam_Util.Op_Link_Tbl_Type
,   x_message_list            IN OUT NOCOPY Error_Handler.Error_Tbl_Type
,   x_return_status           IN OUT NOCOPY VARCHAR2
) ;

END Bom_Rtg_Eam_Util ;

 

/
