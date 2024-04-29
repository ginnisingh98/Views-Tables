--------------------------------------------------------
--  DDL for Package BOM_VALIDATE_OP_NETWORK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE_OP_NETWORK" AUTHID CURRENT_USER AS
/* $Header: BOMLONWS.pls 120.2 2006/02/21 04:32:38 grastogi noship $*/
/*#
* This API contains the methods to validate Operation Network.
* @rep:scope private
* @rep:product BOM
* @rep:displayname Validate BOM Operation Network Package
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
--      BOMLONWS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate_Op_Network
--
--  NOTES
--
--  HISTORY
--  07-AUG-2000 Biao Zhang   Initial Creation
--
****************************************************************************/
/*#
* Check_Existence will perform a query using the primary key information and will return
* success if the operation is CREATE and the record EXISTS or will return an error if the operation
* is UPDATE and the record DOES NOT EXIST.In case of UPDATE if the record exists then the procedure
* will return the old record in the old entity parameters with a success status.
* @param p_op_network_rec Operation Network Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Network_Rec_Type }
* @param p_op_network_Unexp_Rec Operation Network Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type }
* @param x_old_op_network_rec Old Operation Network exposed column record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Network_Rec_Type }
* @param x_old_op_network_unexp_rec Old Operation Network unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Existence
*/
        PROCEDURE Check_Existence
        (  p_op_network_rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_op_network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_old_Op_Network_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Rec_Type
         , x_old_Op_Network_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status        IN OUT NOCOPY VARCHAR2
        );
/*#
* Check Attributes convert the BOM Record and will validate individual
* attributes .Any errors will be populated in the x_Mesg_Token_Tbl and returned with a x_return_status
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_op_Network_rec Bom Operation Network Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_op_network_unexp_rec Bom Operation Network Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type }
* @param p_old_op_network_rec Bom Old Operation Network Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_old_op_network_unexp_rec Bom Old Operation Network Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Attributes
*/
        PROCEDURE Check_Attributes
        (  x_return_status        IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , p_Op_Network_Rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_Op_Network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , p_old_Op_Network_rec   IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_old_Op_Network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        );
/*#
* This procedure will check if the user has access to
* the operations for Op Network.
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_op_Network_rec Bom Operation Network Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_op_network_unexp_rec Bom Operation Network Record as given by the User
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Access
*/
        PROCEDURE Check_Access
        (  p_op_network_rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_op_network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status        IN OUT NOCOPY VARCHAR2
        ) ;
/*#
* Check Entity will perform the business logic validation for the operation
* network Entity.It will perform any cross entity validations and make sure
* that the user is not entering values which may disturb the integrity of the data.
* @param x_return_status Indicating success or faliure
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param p_op_network_rec Operation Network Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_op_network_unexp_rec Operation Network Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type }
* @param p_old_op_network_rec Old Operation Network Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Network_Rec_Type }
* @param p_old_op_network_unexp_rec Operation Resource Unexposed Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type }
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Entity1
*/

        PROCEDURE Check_Entity1
        (  p_Op_Network_rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_Op_Network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , p_old_Op_Network_rec   IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_old_Op_Network_unexp_rec  IN Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status        IN OUT NOCOPY VARCHAR2
         );

        PROCEDURE Check_Entity2
        (  p_Op_Network_rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_Op_Network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , p_old_Op_Network_rec   IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_old_Op_Network_unexp_rec IN
                                  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status        IN OUT NOCOPY VARCHAR2
         );

/*#
* Procedure will varify that the routing start and
* end are unchanged.
* @param p_routing_sequence_id Routing Sequence Id
* @param p_prev_start_id Previous Start Id
* @param p_prev_end_id Previous End Id
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check WSM Network Atttributes
*/
  PROCEDURE Check_WSM_Netowrk_Attribs
  ( p_routing_sequence_id        IN  NUMBER
  , p_prev_start_id              IN  NUMBER
  , p_prev_end_id                IN NUMBER
  , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_Return_status              IN OUT NOCOPY VARCHAR2
  );

END BOM_Validate_Op_Network;

 

/
