--------------------------------------------------------
--  DDL for Package BOM_DEFAULT_BOM_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEFAULT_BOM_COMPONENT" AUTHID CURRENT_USER AS
/* $Header: BOMDCMPS.pls 120.0.12010000.2 2009/12/16 21:44:37 umajumde ship $ */
 /*#
 * This package contains procedures that will try to copy over values from OLD record for all NULL columns found in
 * business object Component and Revision record and to default in values,for all NULL columns found in business object
 * Component an Revision record either by retrieving them from the database, or by having the program
 * assign values.
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Component and Revision Defaulting
 */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDCMPS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Default_Bom_Component
--
--  NOTES
--
--  HISTORY
--  08-JUL-1999 Rahul Chitko    Initial Creation
--
****************************************************************************/
   --added for bug 9076970
  FUNCTION Check_Routing_Exists
	RETURN BOOLEAN;
	--
	-- Attribute defualting for Bom Component Record
	--
	/*#
	 * This procedure will try to default in values,for all NULL columns found in business object Component
	 * record either by retrieving them from the database, or by having the program
	 * assign values.For CREATEs, there is no OLD record. So the program must default
	 * in individual attribute values,independently of each other. This
	 * feature enables the user to enter minimal information for the
	 * operation to go through
	 * @param p_bom_component_rec IN BOM Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type }
	 * @param p_bom_Comp_unexp_rec  IN BOM Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type}
	 * @param x_bom_Component_rec IN OUT NOCOPY processed Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type }
	 * @param x_bom_Comp_unexp_rec IN OUT NOCOPY processed BOM Components Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type}
	 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status of the Business Object
	 * @rep:scope private
	 * @rep:displayname Component-Attribute Defaulting
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
         */
        PROCEDURE Attribute_Defaulting
        (  p_bom_component_rec	IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_bom_Comp_unexp_rec	IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_bom_Component_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
         , x_bom_Comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status      IN OUT NOCOPY VARCHAR2
         );


	--
	-- Attribute Defaulting for Revised Component Record
	--
	/*#
	 * This procedure will try to default in values,for all NULL columns found in business object Revision Component
	 * record either by retrieving them from the database, or by having the program
	 * assign values.For CREATEs, there is no OLD record. So the program must default
	 * in individual attribute values,independently of each other. This
	 * feature enables the user to enter minimal information for the
	 * operation to go through
	 * @param p_rev_component_rec IN Revision Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type }
	 * @param p_Rev_Comp_Unexp_rec  IN Revision Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type}
	 * @param p_control_Rec IN Control Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Control_Rec_Type}
	 * @param x_rev_component_rec IN OUT NOCOPY processed Revision Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type }
	 * @param x_Rev_Comp_Unexp_Rec IN OUT NOCOPY processed Revision Components Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type}
	 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status of the Business Object
	 * @rep:scope private
	 * @rep:displayname Revision-Attribute Defaulting
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
         */
	PROCEDURE Attribute_Defaulting
	(  p_rev_component_rec	 IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	 , p_Rev_Comp_Unexp_Rec	 IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 , p_control_Rec	 IN  BOM_BO_PUB.Control_Rec_Type
					:= BOM_BO_PUB.G_DEFAULT_CONTROL_REC
	 ,   x_rev_component_rec	 IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
	 ,   x_Rev_Comp_Unexp_Rec IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 ,   x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 ,   x_Return_Status      IN OUT NOCOPY VARCHAR2
	 );

	--
	-- Populate NULL Columns for Bom Component Record
	--
	/*#
	 * This procedure will copy over values from OLD record for all NULL columns found in
	 * business object Component record.The user may send in a record with
	 * certain values set to NULL. Values for all such columns are copied over
	 * from the OLD record. This feature enables the user to enter minimal
	 * information for the operation.
	 * @param p_bom_Component_rec IN BOM Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type }
	 * @param p_bom_Comp_unexp_rec  IN BOM Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type}
	 * @param p_old_bom_Component_rec BOM Old Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param p_old_bom_Comp_unexp_rec BOM Component Old Record Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type}
	 * @param x_bom_Component_rec IN OUT NOCOPY processed Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type }
	 * @param x_bom_Comp_unexp_rec IN OUT NOCOPY processed BOM Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	 * @rep:scope private
	 * @rep:displayname Component-Populate Null Column
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
         */
        PROCEDURE Populate_Null_Columns
        (  p_bom_Component_rec      IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_bom_Comp_unexp_rec     IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , p_old_bom_Component_rec  IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_old_bom_Comp_unexp_rec IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_bom_Component_rec      IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
         , x_bom_Comp_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
        );

	--
	-- Populate NULL columns for Revised Component Record
	--
	/*#
	 * This procedure will copy over values from OLD record for all NULL columns found in
	 * business object Revision Component record.The user may send in a record with
	 * certain values set to NULL. Values for all such columns are copied over
	 * from the OLD record. This feature enables the user to enter minimal
	 * information for the operation.
	 * @param  p_rev_component_rec IN Revision Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @param p_old_rev_component_rec IN  Revision Component Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type }
 	 * @param  p_Rev_Comp_Unexp_Rec IN Revision Component Unexposed Column Record
         * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type}
	 * @param p_Old_Rev_Comp_Unexp_Rec Revision Component Old Record Unexposed Column Record
	 * @paraminfo {@rep:Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type}
	 * @param  x_Rev_Component_Rec IN OUT NOCOPY processed Revision Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @param x_Rev_Comp_Unexp_Rec IN OUT NOCOPY Revision Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Revision-Populate Null Column
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 */
	PROCEDURE Populate_Null_Columns
	(  p_rev_component_rec      IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	 , p_old_rev_component_rec  IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	 , p_Rev_Comp_Unexp_Rec     IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 , p_Old_Rev_Comp_Unexp_Rec IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
 	 , x_Rev_Component_Rec      IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
	 , x_Rev_Comp_Unexp_Rec     IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	);

	--
	-- Entity Level Defaulting for Revised Component
	--

	 /*#
 	 * This procedure will perform checks against Revision Component record in the order
	 *	Non-updateable columns (UPDATEs): Certain columns must not be changed by the user when updating the record.
	 *	Cross-attribute checking: The validity of attributes may be checked, based on factors external to it.
	 *      Business logic: The record must comply with business logic rules.
	 * @param  p_rev_component_rec IN Revision Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @param p_old_rev_component_rec IN Revision Component Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @param  x_rev_component_rec IN OUT NOCOPY processed Revision Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Revision Entity Defaulting
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 */
	PROCEDURE Entity_Defaulting
	(  p_rev_component_rec      IN  Bom_Bo_Pub.Rev_Component_Rec_Type
	 , p_old_rev_component_rec  IN  Bom_Bo_Pub.Rev_Component_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_REV_COMPONENT_REC
	 ,   x_rev_component_rec    IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
	);


	--
	-- Entity Level Defaulting for Bom Inventory Component
	--
	/*#
 	 * This procedure will perform checks against BOM Inventory Component record in the order
	 *	Non-updateable columns (UPDATEs): Certain columns must not be changed by the user when updating the record.
	 *	Cross-attribute checking: The validity of attributes may be checked, based on factors external to it.
	 *      Business logic: The record must comply with business logic rules.
	 * @param p_bom_component_rec IN BOM Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param p_old_bom_component_rec  IN BOM Component Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param x_bom_component_rec IN OUT NOCOPY processed BOM Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Component Entity Defaulting
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 */
        PROCEDURE Entity_Defaulting
        (  p_bom_component_rec     IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_old_bom_component_rec IN  Bom_Bo_Pub.Bom_Comps_Rec_Type :=
                                         Bom_Bo_Pub.G_MISS_BOM_COMPONENT_REC
         , x_bom_component_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
        );


END Bom_Default_Bom_Component;

/
