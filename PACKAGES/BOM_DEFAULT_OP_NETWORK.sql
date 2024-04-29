--------------------------------------------------------
--  DDL for Package BOM_DEFAULT_OP_NETWORK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEFAULT_OP_NETWORK" AUTHID CURRENT_USER AS
/* $Header: BOMDONWS.pls 120.1 2006/02/21 03:30:20 grastogi noship $*/
/*#
 * This API contains methods that will try to copy over values from OLD record for all NULL columns found in
 * business object Operation Resource record.It will also default in values either by retrieving
 * them from the database, or by having the program  assign values.
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Operation Network Defaulting
 */
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDONWS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Default_Op_Network
--
--  NOTES
--
--  HISTORY
--  07-AUG-2000 Biao Zhang   Initial Creation
--
****************************************************************************/
/*#
 * This method will try to default in values,for all NULL columns found in business object Operation Network
 * record of type Bom_Rtg_Pub.Op_Network_Rec_Type either by retrieving them from the database, or by having the program
 * assign values.For CREATEs, there is no OLD record. So the program must default
 * in individual attribute values,independently of each other. This
 * feature enables the user to enter minimal information for the
 * operation to go through
 * @param p_op_network_rec IN Operation Network Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Rec_Type}
 * @param p_op_network_unexp_rec IN Operation Network Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type}
 * @param x_op_Network_rec IN OUT NOCOPY processed Operation Network Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Rec_Type}
 * @param x_op_Network_unexp_rec IN OUT NOCOPY processed Operation Network Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type}
 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 * @rep:scope private
 * @rep:displayname Operation Network-Attribute Defaulting
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 * @rep:lifecycle active
 */
     PROCEDURE Attribute_Defaulting
        (  p_Op_Network_rec        IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_Op_Network_Unexp_rec  IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_Op_Network_rec        IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Rec_Type
         , x_Op_Network_Unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
         );
/*#
 * This method will perform checks against Opearion Resource record in the order
 * Non-updateable columns (UPDATEs) Certain columns must not be changed by the user when updating the record.
 * Cross-attribute checking: The validity of attributes may be checked, based on factors external to it.
 * Business logic: The record must comply with business logic rules.
 * @param p_op_Network_rec IN Opearion Network Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Rec_Type}
 * @param p_op_Network_unexp_rec IN Opearion Network Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type}
 * @param x_op_Network_rec IN OUT NOCOPY processed Opearion Network Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Rec_Type}
 * @param x_op_Network_unexp_rec IN OUT NOCOPY processed Opearion Network Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type}
 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Opearion Network-Entity Defaulting
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 * @rep:lifecycle active
 */
        PROCEDURE Entity_Attribute_Defaulting
        (  p_Op_Network_rec        IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_Op_Network_Unexp_rec  IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_Op_Network_rec        IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Rec_Type
         , x_Op_Network_Unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
         );
/*#
 * This will copy over values from OLD record for all NULL columns found in
 * business object Operation Resource record of type Bom_Rtg_Pub.Op_Network_Rec_Type.
 * The user may send in a record with
 * certain values set to NULL. Values for all such columns are copied over
 * from the OLD record. This feature enables the user to enter minimal
 * information for the operation.
 * @param p_op_Network_rec IN Operation Network Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Rec_Type}
 * @param p_old_op_Network_rec IN Operation Network Old Record Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Rec_Type}
 * @param p_op_Network_unexp_rec IN Operation Network Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Typee}
 * @param p_old_op_Network_unexp_rec IN Operation Network Old Record Unexposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Typee}
 * @param x_op_Network_rec IN OUT NOCOPY processed Operation Network Exposed Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Rec_Type}
 * @param x_op_Network_unexp_rec IN OUT NOCOPY processed Operation Network Column Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type}
 * @rep:scope private
 * @rep:compatibility S
 * @rep:displayname Opeartion Network-Populate NULL Columns
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 * @rep:lifecycle active
 */

        PROCEDURE Populate_Null_Columns
        (  p_Op_Network_rec        IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_Op_Network_Unexp_rec  IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , p_old_Op_Network_rec    IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_old_Op_Network_Unexp_rec IN Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_Op_Network_rec        IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Rec_Type
         , x_Op_Network_Unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        );

END BOM_Default_Op_Network;

 

/
