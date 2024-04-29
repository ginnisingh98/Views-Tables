--------------------------------------------------------
--  DDL for Package BOM_DEFAULT_SUB_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEFAULT_SUB_COMPONENT" AUTHID CURRENT_USER AS
/* $Header: BOMDSBCS.pls 120.0 2005/05/25 04:11:22 appldev noship $ */
/*#
 * This API contains methods that will try to copy over values from OLD record for all NULL columns found in
 * business object Substitute Component record.It will also default in values either by retrieving
 * them from the database, or by having the program  assign values.
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Substitute Component Defaulting
 */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDSBCS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Default_Sub_Component
--
--  NOTES
--
--  HISTORY
--
-- 17-JUL-1999	Rahul Chitko	Initial Creation
--
****************************************************************************/
--  Procedure Attributes
	/*#
	 * This method will try to default in values,for all NULL columns found in business object Substitute Component
	 * record of type Bom_Bo_Pub.Sub_Component_Rec_Type either by retrieving them from the database, or by having the program
	 * assign values.For CREATEs, there is no OLD record. So the program must default
	 * in individual attribute values,independently of each other. This
	 * feature enables the user to enter minimal information for the
	 * operation to go through
	 * @param p_sub_component_rec IN Substitute Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type}
	 * @param p_Sub_Comp_Unexp_Rec IN Substitute Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type}
	 * @param x_sub_component_rec IN OUT NOCOPY processed Substitute Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type}
	 * @param x_Sub_Comp_Unexp_Rec IN OUT NOCOPY processed Substitute Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type}
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Substitute Component-Attribute Defaulting
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:lifecycle active
	 */
PROCEDURE Attribute_Defaulting
(   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_SUB_COMPONENT_REC
,   p_Sub_Comp_Unexp_Rec	    IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
,   x_sub_component_rec             IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
,   x_Sub_Comp_Unexp_Rec	    IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl		    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status		    IN OUT NOCOPY VARCHAR2
);

	/*#
	 * This method will copy over values from OLD record for all NULL columns found in
	 * business object Substitute Component record of type Bom_Bo_Pub.Sub_Component_Rec_Type.
	 * The user may send in a record with
	 * certain values set to NULL. Values for all such columns are copied over
	 * from the OLD record. This feature enables the user to enter minimal
	 * information for the operation.
	 * @param p_sub_component_rec IN Substitute Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type}
	 * @param p_old_sub_component_rec IN Substitute Component Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type}
	 * @param p_sub_Comp_Unexp_Rec IN Substitute Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type}
	 * @param p_Old_sub_Comp_Unexp_Rec IN Substitute Component Old Record Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type}
	 * @param x_sub_Component_Rec IN OUT NOCOPY processed Substitute Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type}
	 * @param x_sub_Comp_Unexp_Rec IN OUT NOCOPY processed Substitute Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type}
	 * @rep:scope private
	 * @rep:compatibility S
	 * @rep:displayname Substitute Component-Populate NULL Columns
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:lifecycle active
	 */
PROCEDURE Populate_Null_Columns
( p_sub_component_rec           IN  Bom_Bo_Pub.Sub_Component_Rec_Type
, p_old_sub_component_rec       IN  Bom_Bo_Pub.Sub_Component_Rec_Type
, p_sub_Comp_Unexp_Rec          IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
, p_Old_sub_Comp_Unexp_Rec      IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
, x_sub_Component_Rec           IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
, x_sub_Comp_Unexp_Rec          IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
);

	/*#
 	 * This method will perform checks against Substitute Component record in the order
	 *	Non-updateable columns (UPDATEs): Certain columns must not be changed by the user when updating the record.
	 *	Cross-attribute checking: The validity of attributes may be checked, based on factors external to it.
	 *      Business logic: The record must comply with business logic rules.
	 * @param p_sub_component_rec IN Substitute Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type}
	 * @param p_old_sub_component_rec IN Substitute Component Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type}
	 * @param x_sub_component_rec IN OUT NOCOPY processed Substitute Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Sub_Component_Rec_Type}
	 * @rep:scope private
	 * @rep:compatibility S
	 * @rep:displayname Substitute Component-Entity Defaulting
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:lifecycle active
	 */

PROCEDURE Entity_Defaulting
(   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
,   p_old_sub_component_rec         IN  Bom_Bo_Pub.Sub_Component_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_Sub_COMPONENT_REC
,   x_sub_component_rec             IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
);

/*
** Procedures for BOM Business Object
*/
	/*#
	 * This method is the Attribute Defaulting method for BOM Business Object Substitute Component Record.
	 * This will try to default in values,for all NULL columns found in business object BOM Substitute Component
	 * record of type Bom_Bo_Pub.Bom_Sub_Component_Rec_Type either by retrieving them from the database, or by having the program
	 * assign values.For CREATEs, there is no OLD record. So the program must default
	 * in individual attribute values,independently of each other. This
	 * feature enables the user to enter minimal information for the
	 * operation to go through
	 * @param p_bom_sub_component_rec IN BOM Substitute Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type}
	 * @param p_bom_Sub_Comp_Unexp_Rec IN BOM Substitute Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type}
	 * @param x_bom_sub_component_rec IN OUT NOCOPY processed BOM Substitute Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type}
	 * @param x_bom_Sub_Comp_Unexp_Rec IN OUT NOCOPY processed BOM Substitute Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type}
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:compatibility S
	 * @rep:displayname Substitute Component-Atribute Defaulting
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:lifecycle active
	 */

PROCEDURE Attribute_Defaulting
(   p_bom_sub_component_rec       IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type :=
                                  Bom_Bo_Pub.G_MISS_Bom_SUB_COMPONENT_REC
,   p_bom_Sub_Comp_Unexp_Rec      IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
,   x_bom_sub_component_rec       IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
,   x_bom_Sub_Comp_Unexp_Rec      IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
,   x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status               IN OUT NOCOPY VARCHAR2
);

	/*#
	 * This method is the Populate NULL Column procedure for BOM Business Object Substitute Component Record.
	 * This will copy over values from OLD record for all NULL columns found in
	 * business object BOM Substitute Component record of type Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
	 * The user may send in a record with
	 * certain values set to NULL. Values for all such columns are copied over
	 * from the OLD record. This feature enables the user to enter minimal
	 * information for the operation.
	 * @param p_bom_sub_component_rec IN BOM Substitute Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type}
	 * @param p_old_bom_sub_component_rec IN BOM Substitute Component Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type}
	 * @param p_bom_sub_Comp_Unexp_Rec IN BOM Substitute Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type}
	 * @param p_Old_bom_sub_Comp_Unexp_Rec IN BOM Substitute Component Old Record Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type}
	 * @param x_bom_sub_Component_Rec IN OUT NOCOPY processed BOM Substitute Component Exposed Column Record
 	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Rec_Type}
	 * @param x_bom_sub_Comp_Unexp_Rec IN OUT NOCOPY processed BOM Substitute Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type}
	 * @rep:scope private
	 * @rep:compatibility S
	 * @rep:displayname Substitute Component-Populate NULL Columns
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:lifecycle active
	 */
PROCEDURE Populate_Null_Columns
( p_bom_sub_component_rec         IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
, p_old_bom_sub_component_rec     IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
, p_bom_sub_Comp_Unexp_Rec        IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
, p_Old_bom_sub_Comp_Unexp_Rec    IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
, x_bom_sub_Component_Rec         IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
, x_bom_sub_Comp_Unexp_Rec        IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
);

END BOM_Default_Sub_Component;

 

/
