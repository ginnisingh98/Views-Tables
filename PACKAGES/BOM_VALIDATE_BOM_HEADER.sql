--------------------------------------------------------
--  DDL for Package BOM_VALIDATE_BOM_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE_BOM_HEADER" AUTHID CURRENT_USER AS
/* $Header: BOMLBOMS.pls 120.0 2005/05/25 05:04:49 appldev noship $ */
/*#
 * This API performs Attribute and Entity level validation for the Bill of Materials header.
 * This contains methods for
 *	 Checking the existence of the header record in case of create,update or delete.
 *       Checking the acces rights of the user to the Assmbly Item's BOM Item Type.
 *	 Checking the validity of all Header Attributes
 * 	 Checking the required fields in the BOM Header.
 * 	 Checking the Business Logic validation for the BOM Header Entity.
 *  	 Checking the Delete Constraints for BOM Header
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Validate Header
 * @rep:compatibility S
 */

/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLBOMS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate_Bom_Header
--
--  NOTES
--
--  HISTORY
--
--  01-JUL-99   Rahul Chitko    Initial Creation
--
****************************************************************************/

	/*#
	 * This method checks for the existence of the record based on the transaction type.
	 * The record being updated or deleted in the database must already exist.
	 * But a record being created must not. Such an error in a record must cause all children
	 * to error out, since they are referencing an invalid parent.This raises a Severe Error III.
	 * It also queries up the database record into the corresponding Old Record.
	 * @param p_bom_header_rec IN BOM Header Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	 * @param p_bom_head_unexp_rec IN BOM Header Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 * @param x_old_bom_header_rec IN OUT NOCOPY queried BOM Header Old Record Exposed Column Record.
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	 * @param x_old_bom_head_unexp_rec IN OUT NOCOPY queried BOM Header Old Record Unexposed Column Record.
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type}
 	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Check Header Existence
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */
	PROCEDURE Check_Existence
	(  p_bom_header_rec	    IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	 , p_bom_head_unexp_rec   IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , x_old_bom_header_rec	    IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
	 , x_old_bom_head_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl	    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_return_status	    IN OUT NOCOPY VARCHAR2
	);

	/*#
	 * This method checks for the access rights of the user.An assembly item and any of its
	 * components cannot be operated upon if the user does not have access to the assembly item type.
	 * The user should have proper access to
	 * the Assembly Item's BOM Item Type.It Compare assembly item BOM_Item_Type against the
	 * assembly item access fields in the System_Information record.If the check fails either
	 * Fatal Error III or Fatal Error II is raised depending on  the affected entity.
	 * @param p_assembly_item_id IN Assembly Item Id of the item.
	 * @param p_alternate_bom_code IN Alternate Bom Code if the bill is an alternate bill
	 * @param p_organization_id IN Organiation Id for the item.
	 * @param p_mesg_token_tbl IN Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_mesg_token_tbl IN OUT NOCOPY output Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Check Header Access
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */
	PROCEDURE Check_Access
        (  p_assembly_item_id      IN  NUMBER
         , p_alternate_bom_code    IN  VARCHAR2
         , p_organization_id       IN  NUMBER
         , p_mesg_token_tbl        IN  Error_Handler.Mesg_Token_Tbl_Type
         				:= Error_Handler.G_MISS_MESG_TOKEN_TBL
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        );

	/*#
	 * This method checks for Each of the attributes/fields individually for validity
	 * Examples of these checks are: range checks, checks against lookups etc.It checks
	 * whether user-entered attributes are valid and it checks each attribute independently of the others
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param p_bom_header_Rec IN BOM Header Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	 * @param p_bom_head_unexp_rec IN BOM Header Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 * @param p_old_bom_header_rec IN BOM Header Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	 * @param p_old_bom_head_unexp_rec IN BOM Header Old Record Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Check Header Attributes
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */

        PROCEDURE Check_Attributes
        (  x_return_status           IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , p_bom_header_Rec          IN  Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_head_unexp_rec      IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , p_old_bom_header_rec      IN  Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_old_bom_head_unexp_rec  IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
        );

	/*#
	 * This method does the required fields checking for the BOM Header Record.
	 * Some fields are required for an operation to be performed. Without them,
	 * the operation cannot go through. The user must enter values for these fields.
	 * This procedure checks whether the required field columns are not NULL.It raises
	 *    1 Severe Error IV for create transaction type
	 *    2 Standard Error for other transaction types.
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param p_bom_header_Rec IN BOM Header Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Check Header Required Fields
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */
	PROCEDURE Check_Required
        (  x_return_status      IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , p_bom_header_Rec     IN  Bom_Bo_Pub.Bom_Head_Rec_Type
         );
	/*#
	 * This is where the whole record is checked. The following are checked
	 *	Non-updateable columns (UPDATEs): Certain columns must not be changed by the user when updating the record
	 *	Cross-attribute checking: The validity of attributes may be checked, based on factors external to it
	 *	Business logic: The record must comply with business logic rules.
	 * It raises
	 *	1 Severe Error IV for Create transaction type.
	 *	2 Standard Error for Update transaction type.
	 * @param p_bom_header_Rec IN BOM Header Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	 * @param p_bom_head_unexp_rec IN BOM Header Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type}
	 * @param p_old_bom_head_rec IN BOM Header Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	 * @param p_old_bom_head_unexp_rec IN BOM Header Old Record Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type}
	 * @param x_mesg_token_tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Check Header Entity
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */
        PROCEDURE Check_Entity
        (  p_bom_header_rec     IN  Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_head_unexp_rec IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , p_old_bom_head_rec   IN  Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_old_bom_head_unexp_rec  IN Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status      IN OUT NOCOPY VARCHAR2
         );

	/*#
	 * This method checks for the validity of the delete group entity in the BOM Header Record
	 * This checks whether the delete group is valid,whether it is a duplicate delete group and also
	 * whether the delete group is a newly created one.This procedure will be called before submitting
	 * entities in a delete group for deletion.
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param p_bom_header_Rec IN BOM Header Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	 * @param p_bom_head_unexp_rec IN BOM Header Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type}
	 * @param  x_bom_head_unexp_rec IN OUT NOCOPY processed BOM Header Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Check Header Delete Entity
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */
	PROCEDURE Check_Entity_Delete
        ( x_return_status 	IN OUT NOCOPY VARCHAR2
        , x_Mesg_Token_Tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        , p_bom_header_rec      IN  Bom_Bo_Pub.Bom_Head_Rec_Type
        , p_bom_head_Unexp_Rec  IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
        , x_bom_head_unexp_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 );

END Bom_Validate_Bom_Header;

 

/
