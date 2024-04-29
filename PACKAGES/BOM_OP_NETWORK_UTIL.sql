--------------------------------------------------------
--  DDL for Package BOM_OP_NETWORK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_OP_NETWORK_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMUONWS.pls 120.2 2006/03/09 21:48:44 bbpatel noship $*/
/*#
* This API contains entity utility methods for the Bill of Materials Operation Network
* @rep:scope private
* @rep:product BOM
* @rep:displayname BOM Operation Network Util Package
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
*/
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMUONWS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Op_Network_UTIL
--
--  NOTES
--
--  HISTORY
--  07-AUG-2000 Biao Zhang    Initial Creation
--
****************************************************************************/
/*#
* This method will query the database record, seperate the  values into exposed columns
* and unexposed columns and return with those records.
* @param p_from_op_seq_id Source Operation Sequence Id
* @param p_to_op_seq_id Target Operation Sequence Id
* @param x_op_network_Rec Operation Network Record of exposed colmuns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Op_Network_Rec_Type }
* @param x_op_network_Unexp_Rec Operation Network record of unexposed columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Op_Network_Unexposed_Rec_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Query Row
*/
PROCEDURE Query_Row
( p_from_op_seq_id      IN  NUMBER
, p_to_op_seq_id        IN  NUMBER
, x_Op_Network_rec      IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Rec_Type
, x_Op_Network_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_unexposed_Rec_Type
, x_Return_status       IN OUT NOCOPY VARCHAR2
);

/*#
* Perform Writes is the only exposed method that the user will have access to
* perform any insert/update/deletes to corresponding database tables.
* @param p_op_network_Rec Operation Network Record of exposed colmuns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Op_Network_Rec_Type }
* @param p_op_Network_Unexp_Rec Operation Network record of unexposed columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Perform Writes
*/
PROCEDURE Perform_Writes
( p_Op_Network_rec      IN  Bom_Rtg_Pub.Op_Network_Rec_Type
, p_Op_Network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status       IN OUT NOCOPY VARCHAR2
);

/*#
* Procedure will query start and end operation of the
* entire routing and return those.
* @param p_routing_sequence_id Routing Sequence Id
* @param x_prev_start_id Previous Start Id
* @param x_prev_end_id Previous End Id
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get WSM Network Atttributes
*/
  PROCEDURE Get_WSM_Netowrk_Attribs
  ( p_routing_sequence_id        IN  NUMBER
  , x_prev_start_id              IN OUT NOCOPY NUMBER
  , x_prev_end_id                IN OUT NOCOPY NUMBER
  , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_Return_status              IN OUT NOCOPY VARCHAR2
  );
/*#
* Procedure checks and then sets the sub inventory and
* locator for the OSFM routing.
* @param p_routing_sequence_id Routing Sequence Id
* @param p_end_id End Id
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Set WSM Network Substitute Locator
*/

  PROCEDURE Set_WSM_Network_Sub_Loc
  ( p_routing_sequence_id        IN  NUMBER
  , p_end_id                     IN  NUMBER
  , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_Return_status              IN OUT NOCOPY VARCHAR2
  );

 /*#
  * Procedure to copy the disabled first or last operation of the network.
  * @param p_routing_sequence_id Routing Sequence Id
  * @param x_Mesg_Token_Tbl Message Token Table
  * @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
  * @param x_Return_status Return Status
  * @rep:scope private
  * @rep:lifecycle active
  * @rep:displayname Copy First Last Disabled Operation
  */
  PROCEDURE Copy_First_Last_Dis_Op
  ( p_routing_sequence_id       IN  NUMBER
  , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_return_status             IN OUT NOCOPY VARCHAR2
  );

 /*#
  * Procedure to copy the operation with new effectivity date as (disable date + 1 sec)
  * Also copy resources and alternate resources.
  *
  * @param p_operation_sequence_id Operation Sequence Id
  * @rep:scope private
  * @rep:lifecycle active
  * @rep:displayname Copy Operation
  */
  PROCEDURE Copy_Operation ( p_operation_sequence_id IN NUMBER );

END BOM_Op_Network_UTIL;

 

/
