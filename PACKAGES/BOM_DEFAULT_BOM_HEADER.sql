--------------------------------------------------------
--  DDL for Package BOM_DEFAULT_BOM_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEFAULT_BOM_HEADER" AUTHID CURRENT_USER AS
/* $Header: BOMDBOMS.pls 120.0 2005/05/25 04:56:37 appldev noship $ */
/*#
 * This API contains methods that will try to copy over values from OLD record for all NULL columns found in
 * business object Header record and to default in values,either by retrieving them from the database, or by having the program
 * assign values.
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Header NULL Columns Defaulting
 */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDBOMS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Default_Bom_Header
--
--  NOTES
--
--  HISTORY
--  07-JUL-1999 Rahul Chitko    Initial Creation
--
****************************************************************************/
        /*#
	 * This method will try to default in values,for all NULL columns found in business object Header
	 * record either by retrieving them from the database, or by having the program
	 * assign values.For CREATEs, there is no OLD record. So the program must default
	 * in individual attribute values,independently of each other. This
	 * feature enables the user to enter minimal information for the
	 * operation to go through.
	 * @param p_bom_header_rec IN BOM Header Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type }
	 * @param p_bom_head_unexp_rec  IN BOM Header Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type}
	 * @param x_bom_header_rec IN OUT NOCOPY processed Header Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type }
	 * @param x_bom_head_unexp_rec IN OUT NOCOPY processed BOM Header Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type}
	 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status of the Business Object
	 * @rep:scope private
	 * @rep:displayname Header-Attribute Defaulting
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
         */
        PROCEDURE Attribute_Defaulting
        (  p_bom_header_rec	IN  Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_head_unexp_rec	IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , x_bom_header_rec    	IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
         , x_bom_head_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status      IN OUT NOCOPY VARCHAR2
         );
	/*#
	 * This method will copy over values from OLD record for all NULL columns found in
	 * business object Header record.The user may send in a record with
	 * certain values set to NULL. Values for all such columns are copied over
	 * from the OLD record. This feature enables the user to enter minimal
	 * information for the operation.
	 * @param p_bom_header_rec IN BOM Header Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type }
	 * @param p_bom_head_unexp_rec  IN BOM Header Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type}
	 * @param p_old_bom_header_rec BOM Old Header Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	 * @param p_old_bom_head_unexp_rec BOM Old Header Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type}
	 * @param x_bom_header_rec IN OUT NOCOPY processed Header Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type }
	 * @param x_bom_head_unexp_rec IN OUT NOCOPY processed BOM Header Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 * @rep:scope private
	 * @rep:displayname Header-Populate Null Column
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:compatibility S
	 * @rep:lifecycle active
         */
        PROCEDURE Populate_Null_Columns
        (  p_bom_header_rec     IN  Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_head_unexp_rec IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , p_old_bom_header_rec IN  Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_old_bom_head_unexp_rec IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , x_bom_header_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
         , x_bom_head_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
        );

END Bom_Default_Bom_Header;

 

/
