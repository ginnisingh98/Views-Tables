--------------------------------------------------------
--  DDL for Package BOM_DEFAULT_SUB_OP_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEFAULT_SUB_OP_RES" AUTHID CURRENT_USER AS
/* $Header: BOMDSORS.pls 120.1 2006/02/21 03:32:45 grastogi noship $ */
/*#
 * This API contains methods that will try to copy over values from OLD record for all NULL columns found in
 * business object Sub Operation Resource record.It will also default in values either by retrieving
 * them from the database, or by having the program  assign values.
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Sub Operation Resource Defaulting
 */

/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMDSORS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Default_Sub_Op_Res
--
--  NOTES
--
--  HISTORY
--  22-AUG-2000 Masanori Kimizuka    Initial Creation
--
****************************************************************************/


/****************************************************************************
*  ATTRIBUTE DEFAULTING
*****************************************************************************/
/*#
	 * This method as used by routing BO will try to default in values,for all NULL columns found in business object Sub Operation Resource
	 * record of type Bom_Rtg_Pub.Sub_Resource_Rec_Type either by retrieving them from the database, or by having the program
	 * assign values.For CREATEs, there is no OLD record. So the program must default
	 * in individual attribute values,independently of each other. This
	 * feature enables the user to enter minimal information for the
	 * operation to go through
	 * @param p_sub_resource_rec IN Sub Operation Resource Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
	 * @param p_sub_res_unexp_rec IN Sub Operation Resource Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type}
	 * @param x_sub_resource_rec IN OUT NOCOPY processed Sub Operation Resource Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
	 * @param x_sub_res_unexp_rec IN OUT NOCOPY processed Sub Operation Resource Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type}
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Operation Resource-Attribute Defaulting
	 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
	 * @rep:lifecycle active
	 */

    --
    -- Attribute Defualting for Rtg Sub Operation Resource Record
    -- used by Rtg BO
    --
    PROCEDURE Attribute_Defaulting
    (  p_sub_resource_rec    IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , p_sub_res_unexp_rec   IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
     , x_sub_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , x_sub_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status       IN OUT NOCOPY VARCHAR2
    ) ;


    --
    -- Attribute Defaulting for Reviesed Sub Operation Resource Record
    -- used by Eco BO
    --
/*#
	 * This method as used by ECO BO will try to default in values,for all NULL columns found in business object Sub Operation Resource
	 * record of type Bom_Rtg_Pub.Sub_Resource_Rec_Type either by retrieving them from the database, or by having the program
	 * assign values.For CREATEs, there is no OLD record. So the program must default
	 * in individual attribute values,independently of each other. This
	 * feature enables the user to enter minimal information for the
	 * operation to go through
	 * @param p_rev_sub_resource_rec IN Sub Operation Resource Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
	 * @param p_rev_sub_res_unexp_rec IN Sub Operation Resource Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type}
	 * @param p_control_Rec IN Control Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
	 * @param x_rev_sub_resource_rec IN OUT NOCOPY processed Sub Operation Resource Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
	 * @param x_rev_sub_res_unexp_rec IN OUT NOCOPY processed Sub Operation Resource Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type}
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Operation Resource-Attribute Defaulting
	 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
	 * @rep:lifecycle active
	 */

    PROCEDURE Attribute_Defaulting
    (  p_rev_sub_resource_rec   IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
     , p_rev_sub_res_unexp_rec  IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
     , p_control_Rec            IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_sub_resource_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
     , x_rev_sub_res_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status          IN OUT NOCOPY VARCHAR2
    ) ;


/****************************************************************************
*  POPULATE NULL COLUMNS
*****************************************************************************/
/*#
	 * This method as used by Routing BO will copy over values from OLD record for all NULL columns found in
	 * business object Operation Resource record of type Bom_Bo_Pub.Sub_Resource_Rec_Type.
	 * The user may send in a record with certain values set to NULL. Values for all such
	 * columns are copied over from the OLD record. This feature enables the user to enter
	 * minimal information for the operation.
	 * @param p_sub_resource_rec IN Sub Operation Resource Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
	 * @param p_old_sub_resource_rec IN Sub Operation Resource Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
	 * @param p_sub_res_unexp_rec IN Sub Operation Resource Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Typee}
	 * @param p_old_sub_res_unexp_rec IN Sub Operation Resource Old Record Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Typee}
	 * @param x_sub_resource_rec IN OUT NOCOPY processed Sub Operation Resource Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
	 * @param x_sub_res_unexp_rec IN OUT NOCOPY processed Sub Operation Resource Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type}
	 * @rep:scope private
	 * @rep:compatibility S
	 * @rep:displayname Opeartion Resource-Populate NULL Columns
	 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
	 * @rep:lifecycle active
	 */
    --
    -- Populate NULL Columns for Rtg Sub Operation Resource Record
    -- used by Rtg BO
    --
    PROCEDURE Populate_Null_Columns
    (  p_sub_resource_rec          IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , p_sub_res_unexp_rec         IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
     , p_old_sub_resource_rec      IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , p_old_sub_res_unexp_rec     IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
     , x_sub_resource_rec          IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , x_sub_res_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
    ) ;

    --
    -- Populate NULL columns for Reviesed Sub Operation Resource Record
    -- used by Eco BO
    --
/*#
	 * This method as used by ECO BO will copy over values from OLD record for all NULL columns found in
	 * business object Operation Resource record of type Bom_Bo_Pub.Sub_Resource_Rec_Type.
	 * The user may send in a record with certain values set to NULL. Values for all such
	 * columns are copied over from the OLD record. This feature enables the user to enter
	 * minimal information for the operation.
	 * @param p_rev_sub_resource_rec IN Sub Operation Resource Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
	 * @param p_old_rev_sub_resource_rec IN Sub Operation Resource Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
	 * @param p_rev_sub_res_unexp_rec IN Sub Operation Resource Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Typee}
	 * @param p_old_rev_sub_res_unexp_rec IN Sub Operation Resource Old Record Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Typee}
	 * @param x_rev_sub_resource_rec IN OUT NOCOPY processed Sub Operation Resource Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
	 * @param x_rev_sub_res_unexp_rec IN OUT NOCOPY processed Sub Operation Resource Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type}
	 * @rep:scope private
	 * @rep:compatibility S
	 * @rep:displayname Opeartion Resource-Populate NULL Columns
	 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
	 * @rep:lifecycle active
	 */

    PROCEDURE Populate_Null_Columns
    (  p_rev_sub_resource_rec      IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
     , p_rev_sub_res_unexp_rec     IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
     , p_old_rev_sub_resource_rec  IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
     , p_old_rev_sub_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
     , x_rev_sub_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
     , x_rev_sub_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
    ) ;


/****************************************************************************
*  ENTITY LEVEL DEFAULTING
*****************************************************************************/
/*#
 * This method as used by routing BO will perform checks against Sub Opearion Resource record in the order
 * Non-updateable columns (UPDATEs) Certain columns must not be changed by the user when updating the record.
 * Cross-attribute checking: The validity of attributes may be checked, based on factors external to it.
 * Business logic: The record must comply with business logic rules.
 * @param p_sub_resource_rec IN Sub Opearion Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
 * @param p_sub_res_unexp_rec IN Sub Opearion Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type}
 * @param x_sub_resource_rec IN OUT NOCOPY processed Sub Opearion Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
 * @param x_sub_res_unexp_rec IN OUT NOCOPY processed Sub Opearion Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type}
 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Opearion Resource-Entity Defaulting
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 * @rep:lifecycle active
 */
    --
    -- Entity Level Defaulting Rtg Sub Operation Resource Record
    -- used by Rtg BO
    --
    PROCEDURE Entity_Defaulting
    (  p_sub_resource_rec         IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , p_sub_res_unexp_rec        IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
     , x_sub_resource_rec         IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Rec_Type
     , x_sub_res_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status            IN OUT NOCOPY VARCHAR2
    ) ;


    --
    -- Entity Level Defaulting for Reviesed Operation Resource Record
    -- used by Eco BO
    --
/*#
 * This method as used by ECO BO will perform checks against Sub Opearion Resource record in the order
 * Non-updateable columns (UPDATEs) Certain columns must not be changed by the user when updating the record.
 * Cross-attribute checking: The validity of attributes may be checked, based on factors external to it.
 * Business logic: The record must comply with business logic rules.
 * @param p_rev_sub_resource_rec IN Sub Opearion Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
 * @param p_rev_sub_res_unexp_rec IN Sub Opearion Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type}
 * @param p_control_Rec IN Control Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
 * @param x_rev_sub_resource_rec IN OUT NOCOPY processed Sub Opearion Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
 * @param x_rev_sub_res_unexp_rec IN OUT NOCOPY processed Sub Opearion Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type}
 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Opearion Resource-Entity Defaulting
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 * @rep:lifecycle active
 */

    PROCEDURE Entity_Defaulting
    (  p_rev_sub_resource_rec    IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
     , p_rev_sub_res_unexp_rec   IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
     , p_control_Rec             IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_sub_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
     , x_rev_sub_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status           IN OUT NOCOPY VARCHAR2
    ) ;



END BOM_Default_Sub_Op_Res ;

 

/
