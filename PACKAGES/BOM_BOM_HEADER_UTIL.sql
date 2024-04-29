--------------------------------------------------------
--  DDL for Package BOM_BOM_HEADER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BOM_HEADER_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMUBOMS.pls 120.0 2005/05/25 05:02:34 appldev noship $ */
/*#
* This API contains entity utility methods for the Bill of Materials header.
* @rep:scope private
* @rep:product BOM
* @rep:displayname BOM Header Util package
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      ENGUBOMS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Bom_Header_Util
--
--  NOTES
--
--  HISTORY
--  02-JUL-1999	Rahul Chitko	Initial Creation
--
****************************************************************************/
/*#
* This method will query the database record, seperate the  values into exposed columns
* and unexposed columns and return with those records
* @param p_assembly_item_id Assembly item id
* @param p_organization_id  Organization Id
* @param p_alternate_bom_code Alternate_Bom_Code
* @param x_bom_header_rec Bom header exposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_head_Rec_Type }
* @param x_bom_head_unexp_rec Bom Header unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_head_unexposed_Rec_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Query Row
*/

PROCEDURE Query_Row
( p_assembly_item_id	IN  NUMBER
, p_organization_id     IN  NUMBER
, p_alternate_bom_code	IN VARCHAR2 := NULL
, x_bom_header_rec	IN OUT NOCOPY Bom_Bo_Pub.Bom_head_Rec_Type
, x_bom_head_unexp_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_head_unexposed_Rec_Type
, x_Return_status       IN OUT NOCOPY VARCHAR2
);

PROCEDURE Query_Table_Row
( p_assembly_item_id	IN  NUMBER
, p_organization_id     IN  NUMBER
, p_alternate_bom_code	IN VARCHAR2 := NULL
, x_bom_header_rec	IN OUT NOCOPY Bom_Bo_Pub.Bom_head_Rec_Type
, x_bom_head_unexp_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_head_unexposed_Rec_Type
, x_Return_status       IN OUT NOCOPY VARCHAR2
);

/*#
* This is the only method that the user will have access to when he/she needs to perform any kind
* of writes to the bom_bill_of_materials table
* @param p_bom_header_rec BOM Header Exposed Column Record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type }
* @param p_bom_head_unexp_rec BOM Header Unexposed column record
* @rep:paraminfo { @rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type }
* @param x_mesg_token_tbl Messgae Token Table
* @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
* @param x_Return_status Return Status
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Perform Writes
*/

PROCEDURE Perform_Writes
( p_bom_header_rec     IN  Bom_Bo_Pub.Bom_Head_Rec_Type
, p_bom_head_unexp_rec IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
, x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status      IN OUT NOCOPY VARCHAR2
);

END Bom_Bom_Header_Util;

 

/
