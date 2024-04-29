--------------------------------------------------------
--  DDL for Package BOM_SUB_OP_RES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_SUB_OP_RES_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMUSORS.pls 120.5.12010000.2 2011/12/06 10:45:42 rambkond ship $ */
/*#
* This API contains entity utility methods for the Bill of Materials Sub Operation Resource
* @rep:scope private
* @rep:product BOM
* @rep:displayname BOM Sub Operation Resource Util Package
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
--     BOMUSORS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Sub_Op_Res_UTIL
--
--  NOTES
--
--  HISTORY
--  22-AUG-2000 Masanori Kimizuka    Initial Creation
--
****************************************************************************/

/****************************************************************************
*  QUERY ROW
*****************************************************************************/

/** RTG BO Query Row **/
/*#
* This method as used by routing BO will query the database record, seperate the  values into exposed columns
* and unexposed columns and return with those records.
* @param p_resource_id The IN parameters form the Resource Id
* @param p_substitute_group_number Substitute Group Number
* @param p_operation_sequence_id Operation Sequence Id
* @param p_acd_type acd type
* @param p_replacement_group_number Replacement Group Number
* @param p_basis_type Basis Type
* @param p_mesg_token_tbl Message Token Table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Sub_Resource_Rec Substitute Resource Record of exposed colmuns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Resource_Rec_Type }
* @param x_Sub_Res_Unexp_Rec Substitute Resource record of unexposed columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Sub_Res_Unexposed_Rec_Type }
* @param x_mesg_token_tbl Message Token Table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Query Row
*/
PROCEDURE Query_Row
       ( p_resource_id               IN  NUMBER
       , p_substitute_group_number   IN  NUMBER
       , p_operation_sequence_id     IN  NUMBER
       , p_acd_type                  IN  NUMBER
       , p_replacement_group_number  IN  NUMBER  --bug 2489765
       , p_basis_type                IN  NUMBER  --bug 4689856
       , p_schedule_flag             IN  NUMBER  /* Added for bug 13005178 */
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_sub_resource_rec          IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Rec_Type
       , x_sub_res_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       ) ;

/** ECO BO Query Row **/
/*#
* This method as used by ECO BO will query the database record, seperate the  values into exposed columns
* and unexposed columns and return with those records.
* @param p_resource_id The IN parameters form the Resource Id
* @param p_substitute_group_number Substitute Group Number
* @param p_operation_sequence_id Operation Sequence Id
* @param p_acd_type acd type
* @param p_replacement_group_number Replacement Group Number
* @param p_basis_type Basis Type
* @param p_mesg_token_tbl Message Token Table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_rev_Sub_Resource_Rec Substitute Resource Record of exposed colmuns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Rev_Sub_Resource_Rec_Type }
* @param x_rev_Sub_Res_Unexp_Rec Substitute Resource record of unexposed columns
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Rev_Sub_Res_Unexposed_Rec_Type }
* @param x_mesg_token_tbl Message Token Tablel
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_return_status Indicating success or faliure
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Query Row
*/

PROCEDURE Query_Row
       ( p_resource_id               IN  NUMBER
       , p_substitute_group_number   IN  NUMBER
       , p_operation_sequence_id     IN  NUMBER
       , p_acd_type                  IN  NUMBER
       , p_replacement_group_number  IN  NUMBER  --bug 2489765
       , p_basis_type                IN  NUMBER  --bug 4689856
       , p_schedule_flag             IN  NUMBER  /* Added for bug 13005178 */
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_rev_sub_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
       , x_rev_sub_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       ) ;


/****************************************************************************
*  PERFORM WRITE
*****************************************************************************/

/** Routing BO Perform Writes **/
PROCEDURE Perform_Writes
        (  p_sub_resource_rec      IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
         , p_sub_res_unexp_rec     IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;

/** ECO BO Perform Writes **/
PROCEDURE Perform_Writes
        (  p_rev_sub_resource_rec  IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
         , p_rev_sub_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , p_control_rec           IN  Bom_Rtg_Pub.Control_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;


/****************************************************************************
*  OTHERS
*****************************************************************************/

/** Insert  Operation  **/
PROCEDURE Insert_Row
        (  p_rev_sub_resource_rec   IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
         , p_rev_sub_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;

/** Update  Operation  **/
PROCEDURE Update_Row
        (  p_rev_sub_resource_rec   IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
         , p_rev_sub_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;


/** Delete  Operations  **/
PROCEDURE Delete_Row
        (  p_rev_sub_resource_rec   IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
         , p_rev_sub_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;

END BOM_Sub_Op_Res_UTIL;

/
