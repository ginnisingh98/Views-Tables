--------------------------------------------------------
--  DDL for Package BOM_DEFAULT_OP_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEFAULT_OP_RES" AUTHID CURRENT_USER AS
/* $Header: BOMDRESS.pls 120.1.12010000.2 2008/11/14 16:16:29 snandana ship $ */
/*#
 * This API contains methods that will try to copy over values from OLD record for all NULL columns found in
 * business object Operation Resource record.It will also default in values either by retrieving
 * them from the database, or by having the program  assign values.
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Operation Resource Defaulting
 */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMDRESS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Default_Op_Res
--
--  NOTES
--
--  HISTORY
--  18-AUG-2000 Masanori Kimizuka    Initial Creation
--
****************************************************************************/


/****************************************************************************
*  ATTRIBUTE DEFAULTING
*****************************************************************************/
/*#
 * This method as used by routing BO will try to default in values,for all NULL columns found in business object Operation Resource
 * record of type Bom_Rtg_Pub.Op_Resource_Rec_Type either by retrieving them from the database, or by having the program
 * assign values.For CREATEs, there is no OLD record. So the program must default
 * in individual attribute values,independently of each other. This
 * feature enables the user to enter minimal information for the
 * operation to go through
 * @param p_op_resource_rec IN Operation Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type}
 * @param p_op_res_unexp_rec IN Operation Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type}
 * @param x_op_resource_rec IN OUT NOCOPY processed Operation Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type}
 * @param x_op_res_unexp_rec IN OUT NOCOPY processed Operation Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type}
 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 * @rep:scope private
 * @rep:displayname Operation Resource-Attribute Defaulting
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 * @rep:lifecycle active
 */
    --
    -- Attribute Defualting for Rtg Operation Resource Record
    -- used by Rtg BO
    --
    PROCEDURE Attribute_Defaulting
    (  p_op_resource_rec   IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
     , p_op_res_unexp_rec  IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_op_resource_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
     , x_op_res_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status     IN OUT NOCOPY VARCHAR2
    ) ;


    --
    -- Attribute Defaulting for Reviesed Operation Resource Record
    -- used by Eco BO
    --
/*#
 * This method as used by ECO BO will try to default in values,for all NULL columns found in business object Operation Resource
 * record of type Bom_Rtg_Pub.Op_Resource_Rec_Type either by retrieving them from the database, or by having the program
 * assign values.For CREATEs, there is no OLD record. So the program must default
 * in individual attribute values,independently of each other. This
 * feature enables the user to enter minimal information for the
 * operation to go through
 * @param p_rev_op_resource_rec IN Operation Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type}
 * @param p_rev_op_res_unexp_rec IN Operation Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type}
 * @param p_control_Rec IN Control Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
 * @param x_rev_op_resource_rec IN OUT NOCOPY processed Operation Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type}
 * @param x_rev_op_res_unexp_rec IN OUT NOCOPY processed Operation Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type}
 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 * @rep:scope private
 * @rep:displayname Operation Resource-Attribute Defaulting
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 * @rep:lifecycle active
 */

    PROCEDURE Attribute_Defaulting
    (  p_rev_op_resource_rec    IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_rev_op_res_unexp_rec   IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , p_control_Rec            IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_op_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , x_rev_op_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status          IN OUT NOCOPY VARCHAR2
    ) ;


/****************************************************************************
*  POPULATE NULL COLUMNS
*****************************************************************************/
    --
    -- Populate NULL Columns for Rtg Operation Resource Record
    -- used by Rtg BO
    --
/*#
 * This method as used by routing BO will copy over values from OLD record for all NULL columns found in
 * business object Operation Resource record of type Bom_Bo_Pub.Op_Resource_Rec_Type.
 * The user may send in a record with
 * certain values set to NULL. Values for all such columns are copied over
 * from the OLD record. This feature enables the user to enter minimal
 * information for the operation.
 * @param p_op_resource_rec IN Operation Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type}
 * @param p_old_op_resource_rec IN Operation Resource Old Record Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type}
 * @param p_op_res_unexp_rec IN Operation Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Typee}
 * @param p_old_op_res_unexp_rec IN Operation Resource Old Record Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Typee}
 * @param x_op_resource_rec IN OUT NOCOPY processed Operation Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type}
 * @param x_op_res_unexp_rec IN OUT NOCOPY processed Operation Resource Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type}
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Opeartion Resource-Populate NULL Columns
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 * @rep:lifecycle active
 */
    PROCEDURE Populate_Null_Columns
    (  p_op_resource_rec          IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
     , p_op_res_unexp_rec         IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , p_old_op_resource_rec      IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
     , p_old_op_res_unexp_rec     IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_op_resource_rec          IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
     , x_op_res_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
    ) ;

    --
    -- Populate NULL columns for Reviesed Operation Resource Record
    -- used by Eco BO
    --

/*#
	 * This method as used by ECO BO will copy over values from OLD record for all NULL columns found in
	 * business object Operation Resource record of type Bom_Bo_Pub.Op_Resource_Rec_Type.
	 * The user may send in a record with
	 * certain values set to NULL. Values for all such columns are copied over
	 * from the OLD record. This feature enables the user to enter minimal
	 * information for the operation.
	 * @param p_rev_op_resource_rec IN Operation Resource Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type}
	 * @param p_old_rev_op_resource_rec IN Operation Resource Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type}
	 * @param p_rev_op_res_unexp_rec IN Operation Resource Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Typee}
	 * @param p_old_rev_op_res_unexp_rec IN Operation Resource Old Record Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Typee}
	 * @param x_rev_op_resource_rec IN OUT NOCOPY processed Operation Resource Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type}
	 * @param x_rev_op_res_unexp_rec IN OUT NOCOPY processed Operation Resource Column Record
	 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type}
	 * @rep:scope private
	 * @rep:compatibility S
	 * @rep:displayname Opeartion Resource-Populate NULL Columns
	 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
	 * @rep:lifecycle active
	 */

    PROCEDURE Populate_Null_Columns
    (  p_rev_op_resource_rec      IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_rev_op_res_unexp_rec     IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , p_old_rev_op_resource_rec  IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_old_rev_op_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , x_rev_op_resource_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , x_rev_op_res_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
    ) ;

/*#
 * This method as used by routing BO will perform checks against Opearion Resource record in the order
 * Non-updateable columns (UPDATEs) Certain columns must not be changed by the user when updating the record.
 * Cross-attribute checking: The validity of attributes may be checked, based on factors external to it.
 * Business logic: The record must comply with business logic rules.
 * @param p_op_resource_rec IN Opearion Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type}
 * @param p_op_res_unexp_rec IN Opearion Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type}
 * @param x_op_resource_rec IN OUT NOCOPY processed Opearion Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type}
 * @param x_op_res_unexp_rec IN OUT NOCOPY processed Opearion Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type}
 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Opearion Resource-Entity Defaulting
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 * @rep:lifecycle active
 */

/****************************************************************************
*  ENTITY LEVEL DEFAULTING
*****************************************************************************/
    --
    -- Entity Level Defaulting Rtg Operation Resource Record
    -- used by Rtg BO
    --
    PROCEDURE Entity_Defaulting
    (  p_op_resource_rec          IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
     , p_op_res_unexp_rec         IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_op_resource_rec          IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
     , x_op_res_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status            IN OUT NOCOPY VARCHAR2
    ) ;


    --
    -- Entity Level Defaulting for Reviesed Operation Resource Record
    -- used by Eco BO
    --

/*#
 * This method as used by ECO BO will perform checks against Opearion Resource record in the order
 * Non-updateable columns (UPDATEs) Certain columns must not be changed by the user when updating the record.
 * Cross-attribute checking: The validity of attributes may be checked, based on factors external to it.
 * Business logic: The record must comply with business logic rules.
 * @param p_rev_op_resource_rec IN Opearion Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type}
 * @param p_rev_op_res_unexp_rec IN Opearion Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type}
 * @param p_control_Rec IN Control Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
 * @param x_rev_op_resource_rec IN OUT NOCOPY processed Opearion Resource Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type}
 * @param x_rev_op_res_unexp_rec IN OUT NOCOPY processed Opearion Resource Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type}
 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Opearion Resource-Entity Defaulting
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 * @rep:lifecycle active
 */

    PROCEDURE Entity_Defaulting
    (  p_rev_op_resource_rec    IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , p_rev_op_res_unexp_rec   IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , p_control_Rec            IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_op_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
     , x_rev_op_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
     , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status          IN OUT NOCOPY VARCHAR2
    ) ;

/****************************************************************************
*  OTHERS
*****************************************************************************/

    FUNCTION Get_Assigned_Units
    RETURN NUMBER ;

    FUNCTION Get_Schedule_Flag
    RETURN NUMBER ;


    FUNCTION  Get_Available_24hs_flag ( p_resource_id IN  NUMBER
                                      , p_op_seq_id   IN  NUMBER)
    RETURN NUMBER ;



    -- Get Usage Rate or Amount
    PROCEDURE  Get_Usage_Rate_Or_Amount
             ( p_usage_rate_or_amount         IN  NUMBER
             , p_usage_rate_or_amount_inverse IN  NUMBER
             , x_usage_rate_or_amount         IN OUT NOCOPY NUMBER
             , x_usage_rate_or_amount_inverse IN OUT NOCOPY NUMBER
             ) ;

    -- Get Resource Attributes
    PROCEDURE  Get_Res_Attributes
               (  p_operation_sequence_id  IN  NUMBER
                , p_resource_id            IN  NUMBER
                , p_activity_id            IN  NUMBER
                , p_autocharge_type        IN  NUMBER
                , p_basis_type             IN  NUMBER
                , p_standard_rate_flag     IN  NUMBER
                , p_org_id                 IN  NUMBER
                , x_activity_id            IN OUT NOCOPY NUMBER
                , x_autocharge_type        IN OUT NOCOPY NUMBER
                , x_basis_type             IN OUT NOCOPY NUMBER
                , x_standard_rate_flag     IN OUT NOCOPY NUMBER
               ) ;
    G_round_off_val number :=NVL(FND_PROFILE.VALUE('BOM:ROUND_OFF_VALUE'),6); /* Bug 7322996 */

END BOM_Default_Op_Res ;

/
