--------------------------------------------------------
--  DDL for Package BOM_OP_RES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_OP_RES_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMURESS.pls 120.4 2006/02/28 03:50:39 grastogi noship $ */
/*#
* This API contains entity utility methods for the Bill of Materials Operation Resources
* @rep:scope private
* @rep:product BOM
* @rep:displayname BOM Sub Component Util Package
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
*/
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMURESS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Op_Res_UTIL
--
--  NOTES
--
--  HISTORY
--  18-AUG-2000 Masanori Kimizuka    Initial Creation
--
****************************************************************************/


/****************************************************************************
*  QUERY ROW
*****************************************************************************/
/*#
* This method will query the database record, seperate the  values into exposed columns
* and unexposed columns and return with those records.
* @param p_resource_sequence_number Resource Sequence Number
* @param p_operation_sequence_id Operation Resource sequence id
* @param p_acd_type acd type
* @param p_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_op_resource_Rec Operation Resource Record of exposed colmuns
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param x_op_res_Unexp_Rec Operation Resource record of unexposed columns
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Query Row for Routing BO
*/

/** RTG BO Query Row **/
PROCEDURE Query_Row
       ( p_resource_sequence_number  IN  NUMBER
       , p_operation_sequence_id     IN  NUMBER
       , p_acd_type                  IN  NUMBER
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_op_resource_rec           IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
       , x_op_res_unexp_rec          IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       ) ;

/** ECO BO Query Row **/
/*#
* This method will query the database record, seperate the  values into exposed columns
* and unexposed columns and return with those records.
* @param p_resource_sequence_number Resource Sequence Number
* @param p_operation_sequence_id Operation Resource sequence id
* @param p_acd_type acd type
* @param p_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_rev_op_resource_Rec Operation Resource Record of exposed colmuns
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param x_rev_op_res_Unexp_Rec Operation Resource record of unexposed columns
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Filled with any errors or warnings
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Query Row for ECO BO
*/

PROCEDURE Query_Row
       ( p_resource_sequence_number  IN  NUMBER
       , p_operation_sequence_id     IN  NUMBER
       , p_acd_type                  IN  NUMBER
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_rev_op_resource_rec       IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
       , x_rev_op_res_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       ) ;


/****************************************************************************
*  PERFORM WRITE
*****************************************************************************/
/*#
* Perform Writes is the only exposed method that the user will have access to perform any
* insert/update/deletes to corresponding database tables
* @param p_op_resource_rec Bom Operation Resource Record of exposed colmuns
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_op_res_Unexp_Rec Bom Operation Resource record of unexposed columns
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Perform Writes for Routing BO
*/
/** Routing BO Perform Writes **/
PROCEDURE Perform_Writes
        (  p_op_resource_rec       IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
         , p_op_res_unexp_rec      IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;

/** ECO BO Perform Writes **/
/*#
* Perform Writes is the only exposed method that the user will have access to perform any
* insert/update/deletes to corresponding database tables
* @param p_rev_op_resource_rec Bom Operation Resource Record of exposed colmuns
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type }
* @param p_rev_op_res_Unexp_Rec Bom Operation Resource record of unexposed columns
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type }
* @param p_control_rec Control Record
* @rep:paraminfo { @rep:innertype Bom_Rtg_Pub.Control_Rec_Type }
* @param x_Mesg_Token_Tbl Message token table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Perform Writes for ECO BO
*/

PROCEDURE Perform_Writes
        (  p_rev_op_resource_rec   IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , p_control_rec           IN  Bom_Rtg_Pub.Control_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;


/****************************************************************************
*  OTHERS
*****************************************************************************/

/** Insert  Operation  **/
PROCEDURE Insert_Row
        (  p_rev_op_resource_rec   IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;

/** Update  Operation  **/
PROCEDURE Update_Row
        (  p_rev_op_resource_rec   IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;


/** Delete  Operations  **/
PROCEDURE Delete_Row
        (  p_rev_op_resource_rec   IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;

END BOM_Op_Res_UTIL;

 

/
