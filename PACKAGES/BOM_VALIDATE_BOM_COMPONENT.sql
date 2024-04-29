--------------------------------------------------------
--  DDL for Package BOM_VALIDATE_BOM_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE_BOM_COMPONENT" AUTHID CURRENT_USER AS
/* $Header: BOMLCMPS.pls 120.2.12010000.2 2009/07/03 09:43:55 rajaiswa ship $ */
/*#
 * This API contains Attribute and Entity level validation for the Bill of Materials Component Records.
 * This contains procedures for
 *	 Checking the existence of the component record in case of create,update or delete.
 *       Checking the acces rights of the user to the Assembly Item's BOM Item Type.
 *	 Checking the validity of all Component Attributes
 * 	 Checking the required fields in the BOM Component Record.
 * 	 Checking the Business Logic validation for the BOM Component Entity.
 *  	 Checking the Delete Constraints for BOM Component.
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Validate Component
 * @rep:compatibility S
 */

/*************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLCMPS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate_Bom_Component
--
--  NOTES
--
--  HISTORY
--
--  11-JUN-99 Rahul Chitko	Initial Creation
--
**************************************************************************/

--  Procedure Entity

	/*#
	 * This is where the whole record is checked. The following are checked
	 *	Non-updatable columns (UPDATEs): Certain columns must not be changed by the user when updating the record
	 *	Cross-attribute checking: The validity of attributes may be checked, based on factors external to it
	 *	Business logic: The record must comply with business logic rules.
	 * It raises
	 *	1 Severe Error IV for Create transaction type.
	 *	2 Standard Error for Update transaction type.
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param p_bom_component_rec IN BOM component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param p_bom_Comp_Unexp_Rec IN BOM Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type}
	 * @param p_old_bom_Component_Rec IN BOM Component Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param p_old_bom_Comp_Unexp_Rec IN BOM Component Old Record Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Check Component Entity
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */

PROCEDURE Check_Entity
( x_return_status		IN OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_bom_component_rec		IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
, p_bom_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
, p_old_bom_Component_Rec	IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
, p_old_bom_Comp_Unexp_Rec	IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
);


/*#
* This procedure will actually check if any component type rule exists
* between the two item types of the item which are to be associated.
* If such any component type  rule exists then the procedure checks
* if these items can be associated according to the rule.If not the
* procedure returns the error staus and error message.If the items
* can be associated then it returns success.
* @param x_return_status IN OUT NOCOPY Return Status
* @param x_error_message OUT  VARCHAR2 Error message
* @param p_init_msg_list IN BOOLEAN := TRUE Flag to initialize
*                                     error handler
* @param p_parent_item_id IN NUMBER parent_item_id
* @param p_child_item_id  IN NUMBER child_item_id is component_item_id
* @param p_organization_id IN NUMBER
* @rep:displayname Check Component Type Rules
* @rep:compatibility S
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/

PROCEDURE Check_Component_Type_Rule
(
  x_return_status    IN OUT NOCOPY VARCHAR2
, x_error_message    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
, p_init_msg_list    IN BOOLEAN := TRUE
, p_parent_item_id   IN NUMBER
, p_child_item_id    IN NUMBER
, p_organization_id  IN NUMBER
);

--  Procedure Attributes
	/*#
	 * This method checks for each of the attribute/field individually for validity.
	 * Examples of these checks are: range checks, checks against lookups etc.It checks
	 * whether user-entered attributes are valid and it also checks each attribute independently of the others
	 * It raises
	 *	1 Severe Error IV in case of Create transaction type
	 *	2 Standard Error in case of other transaction types.
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param p_bom_component_Rec IN BOM Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param p_bom_Comp_Unexp_Rec IN BOM Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	 * @rep:scope private
	 * @rep:displayname Check Component Attributes
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */

PROCEDURE Check_Attributes
( x_return_status		IN OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_bom_component_rec		IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
, p_bom_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
);

--  Procedure Entity_Delete

	/*#
	 * This method checks for the validity of the delete group entity in the BOM Component Record
	 * This checks whether the delete group is valid,whether it is a duplicate delete group and also
	 * whether the delete group is a newly created one.This procedure will be called before submitting
	 * entities in a delete group for deletion.
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param p_bom_component_rec IN BOM Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param p_bom_Comp_Unexp_Rec IN BOM Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Check Component Delete Entity
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */

PROCEDURE Check_Entity_Delete
( x_return_status		IN OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_bom_component_rec		IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
, p_bom_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
);


	/*#
	 * This method does the required fields checking for the BOM Component Record.
	 * Some fields are required for an operation to be performed. Without them,
	 * the operation cannot go through. The user must enter values for these fields.
	 * This method checks whether the required field columns are NULL or not.It raises
	 *    1 Severe Error IV for create transaction type
	 *    2 Standard Error for other transaction types.
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param p_bom_component_rec IN BOM Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Check Component Required Fields
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */
PROCEDURE Check_Required
( x_return_status		IN OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_bom_component_rec           IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
);
	/*#
	 * This method checks for the existence of the component record based on the transaction type.
	 * The record being updated or deleted in the database must already exist.
	 * But a record being created must not. Such an error must cause all children
	 * to error out, since they are referencing an invalid parent.This raises a Severe Error III.
	 * It also queries up the database record into the corresponding Old Record.
	 * @param p_bom_component_rec IN BOM Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param p_bom_comp_unexp_rec IN BOM Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
	 * @param x_old_bom_component_rec IN OUT NOCOPY queried BOM Components Old Record Exposed Column Record.
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param x_old_bom_comp_unexp_rec IN OUT NOCOPY queried BOM Components Old Record Unexposed Column Record.
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type}
 	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Check Component Existence
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */
PROCEDURE Check_Existence
(  p_bom_component_rec		IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
 , p_bom_comp_unexp_rec		IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
 , x_old_bom_component_rec	IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
 , x_old_bom_comp_unexp_rec	IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status		IN OUT NOCOPY VARCHAR2
);

	/*#
	 * This method checks whether the linkage of records is correct in the business object.
	 * That is, child records must reference valid parents. A valid parent is one that exists
	 * and is truly the current record's parent in the database.Based on the transaction type
	 * it performs
	 *	1 Create:No check required. (Check to see if parent assembly item exists in bill of
	 *	  materials production table has already been performed)
	 * 	2 Update/Delete: Production table component must reference the same parent item that the business
	 *	  object component does. Compare parent assembly item unique key in current component
	 *	  record against assembly item unique key in assembly item record that has already been queried up
	 * It raises Severe Error III.
	 * @param  p_bom_component_rec IN BOM Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param p_bom_comp_unexp_rec IN BOM Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type}
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_Return_Status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Check Component Lineage
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */
PROCEDURE Check_Lineage
(  p_bom_component_rec          IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
 , p_bom_comp_unexp_rec         IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
);
	/*#
	 * This method checks for the access rights of the user.An assembly item and any of its
	 * components cannot be operated upon if the user does not have access to the assembly item type.
	 * The user should have proper access to
	 * the Assembly Item's BOM Item Type and also to component's BOM_Item_Type.
	 * It looks up STD_Item_Access or MDL_Item_Access or PLN_Item_Access
	 * in the System_Information record, depending on item's BOM Item Type
	 * It also checks whether BOM_Item_Type is not Product Family.If the check fails either
	 * Fatal Error III or Fatal Error II is raised depending on  the affected entity.
	 * @param p_organization_id IN Organiation Id for the item
	 * @param p_component_item_id IN Component Item Id
	 * @param p_component_name IN Component Item Name
	 * @param p_Mesg_Token_Tbl IN Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_Return_Status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Check Component Access
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */
PROCEDURE Check_Access
(  p_organization_id            IN  NUMBER
 , p_component_item_id          IN  NUMBER
 , p_component_name             IN  VARCHAR2
 , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                    Error_Handler.G_MISS_MESG_TOKEN_TBL
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
);

	/*#
	 * This method checks the number of componets under a bill.
 	 * The total number of components under a bill  should not exceed 9999.
	 * When the limit is exceeded it raises proper error messages.
	 * @param p_bom_component_rec IN BOM Component Exposed Column Record
	 * @paraminfo {@rep:innertype  Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param  p_bom_comp_unexp_rec IN BOM Component Unexposed Column Record
	 * @paraminfo {@rep:innertype  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type}
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table
	 * @paramInfo {@rep:innertpye Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_Return_Status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Check Component Count
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */
PROCEDURE Check_ComponentCount
(  p_bom_component_rec         IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
   , p_bom_comp_unexp_rec      IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
   , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_Return_Status           IN OUT NOCOPY VARCHAR2
);

/*
** Procedures used by ECO BO and internally called by BOM BO
*/

	/*#
	 * This method is used by ECO Business Object while keeping track of the revisions and
	 * this is where the whole record is checked. The following are checked
	 *	Cross-attribute checking: The validity of attributes may be checked, based on factors external to it
	 *	Business logic: The record must comply with business logic rules.
	 * It raises Standard Error.
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param p_rev_component_rec IN  Revision Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @param p_Rev_Comp_Unexp_Rec IN Revision Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type}
	 * @param p_Old_Rev_Component_Rec IN Revision Component Old Record Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @param p_Old_Rev_Comp_Unexp_Rec IN Revision Component Old Record Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type}
	 * @param p_control_rec IN Revision Control Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Control_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Check Revision Component Entity
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */
PROCEDURE Check_Entity
( x_return_status         IN OUT NOCOPY  VARCHAR2
, x_Mesg_Token_Tbl        IN OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec      IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec     IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, p_control_rec            IN  BOM_BO_PUB.Control_Rec_Type
			:= BOM_BO_PUB.G_DEFAULT_CONTROL_REC
, p_Old_Rev_Component_Rec  IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Old_Rev_Comp_Unexp_Rec IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
);

	/*#
	 * This method is used by ECO Business Object while keeping track of the revisions and
	 * checks for Each of the attribute/field individually for validity.
	 * Examples of these checks are: range checks, checks against lookups etc.It checks
	 * whether user-entered attributes are valid and it checks each attribute independently of the others
	 * It raises
	 *	1 Severe Error IV in case of Create transaction type
	 *	2 Standard Error in case of other transaction types.
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param p_rev_component_Rec IN Revision Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @param p_Rev_Comp_Unexp_Rec IN Revision Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
	 * @rep:scope private
	 * @rep:displayname Check Revision Component Attributes
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */

PROCEDURE Check_Attributes
( x_return_status               IN OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec           IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec          IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
);

	/*#
	 * This method is used by ECO Business Object while keeping track of the revisions and
	 * checks for the validity of the delete group entity in the BOM Revision Component Record
	 * This checks whether the delete group is valid,whether it is a duplicate delete group and also
	 * whether the delete group is a newly created one.This procedure will be called before submitting
	 * entities in a delete group for deletion.
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param p_rev_component_rec IN Revision Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @param p_Rev_Comp_Unexp_Rec IN Revision Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Check Revision Component Delete Entity
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */

PROCEDURE Check_Entity_Delete
( x_return_status               IN OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec           IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec          IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
);

	/*#
	 * This method is used by ECO Business Object while keeping track of the revisions and
	 * does the required fields checking for the Revision Component Record.
	 * Some fields are required for an operation to be performed. Without them,
	 * the operation cannot go through. The user must enter values for these fields.
	 * This procedure checks whether the required field columns are not NULL.It raises
	 *    1 Severe Error IV for create transaction type
	 *    2 Standard Error for other transaction types.
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param p_rev_component_rec IN Revision Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @rep:scope private
	 * @rep:displayname Check Revision Component Required Fields
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */

PROCEDURE Check_Required
( x_return_status               IN OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec           IN  Bom_Bo_Pub.Rev_Component_Rec_Type
);

	/*#
	 * This procedure is used by ECO Business Object while keeping track of the revisions and
	 * checks for the existence of the revision record based on the transaction type.
	 * The record being updated or deleted in the database must already exist.
	 * But a record being created must not. Such an error in a record must cause all children
	 * to error out, since they are referencing an invalid parent.This raises a Severe Error III.
	 * It also queries up the database record into the corresponding Old Record.
	 * @param p_rev_component_rec IN Revision Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @param p_rev_comp_unexp_rec IN Revision Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type}
	 * @param x_old_rev_component_rec IN OUT NOCOPY queried Revision Components Old Record Exposed Column Record.
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @param x_old_rev_comp_unexp_rec IN OUT NOCOPY queried Revision Components Old Record Unexposed Column Record.
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type}
 	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Check Revision Component Existence
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */

PROCEDURE Check_Existence
(  p_rev_component_rec          IN  Bom_Bo_Pub.Rev_Component_Rec_Type
 , p_rev_comp_unexp_rec         IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
 , x_old_rev_component_rec      IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
 , x_old_rev_comp_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status              IN OUT NOCOPY VARCHAR2
);

	/*#
	 * This method is used by ECO Business Object while keeping track of the revisions and
	 * checks whether the linkage of records is correct in the business object.
	 * That is, child records must reference valid parents. A valid parent is one that exists
	 * and is truly the current record's parent in the database.Based on the transaction type
	 * it performs
	 *	1 Create:No check required. (Check to see if parent assembly item exists in bill of
	 *	  materials production table has already been performed)
	 * 	2 Update/Delete: Production table component must reference the same parent item that the business
	 *	  object component does. Compare parent assembly item unique key in current component
	 *	  record against assembly item unique key in assembly item record that has already been queried up
	 * It raises Severe Error III.
	 * @param  p_rev_component_rec IN Revision Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Component_Rec_Type}
	 * @param p_rev_comp_unexp_rec IN Revision Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type}
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_Return_Status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Check Revision Component Lineage
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */
PROCEDURE Check_Lineage
(  p_rev_component_rec          IN  Bom_Bo_Pub.Rev_Component_Rec_Type
 , p_rev_comp_unexp_rec         IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
);

	/*#
	 * This method is used by ECO Business Object while keeping track of the revisions and
	 * checks for the access rights of the user.An assembly item revision and any of its
	 * component revision  cannot be operated upon if the user does not have access to the assembly item type.
	 * The user should have proper access to
	 * the Assembly Item's BOM Item Type.It Compare assembly item BOM_Item_Type against the
	 * assembly item access fields in the System_Information record.If the check fails either
	 * Fatal Error III or Fatal Error II is raised depending on  the affected entity.
	 * @param p_revised_item_name IN Revised Item Name
	 * @param p_revised_item_id IN Revised Item Id
	 * @param p_organization_id IN Organization Id
	 * @param p_change_notice IN Change Notice
	 * @param p_new_item_revision IN New Item Revision
	 * @param p_effectivity_date IN Component Effectvity Date
	 * @param p_new_routing_revsion IN New Routing Revision
	 * @param p_from_end_item_number End Item Number from which it is revised
	 * @param p_component_item_id IN Component Item Id
	 * @param p_operation_seq_num IN Operation Sequence Id for Routing
	 * @param p_bill_sequence_id IN Bill Sequence Id
	 * @param p_component_name IN Component Name
	 * @param p_Mesg_Token_Tbl IN Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param p_entity_processed IN Processed Entity
	 * @param p_rfd_sbc_name IN
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY output Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_Return_Status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:displayname Check Revised Component  Access
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 	 */

PROCEDURE Check_Access
(  p_revised_item_name          IN  VARCHAR2
 , p_revised_item_id            IN  NUMBER
 , p_organization_id            IN  NUMBER
 , p_change_notice              IN  VARCHAR2
 , p_new_item_revision          IN  VARCHAR2
 , p_effectivity_date           IN  DATE
 , p_new_routing_revsion        IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
 , p_from_end_item_number       IN  VARCHAR2 := NULL -- Added by MK on 11/02/00
 , p_component_item_id          IN  NUMBER
 , p_operation_seq_num          IN  NUMBER
 , p_bill_sequence_id           IN  NUMBER
 , p_component_name             IN  VARCHAR2
 , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                    Error_Handler.G_MISS_MESG_TOKEN_TBL
 , p_entity_processed           IN  VARCHAR2 := 'RC'
 , p_rfd_sbc_name               IN  VARCHAR2 := NULL
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
);

	/*#
	 * This method will check if a component record is a direct item component its for EAM BOMs only.
	 * It will also verify that the component has correct values for direct item specific
	 * attributes.For normal item components these attributes should be ignored.
	 * @param p_bom_component_rec IN BOM Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param p_bom_comp_unexp_rec IN BOM Component Unexposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type}
	 * @param x_bom_component_rec IN OUT NOCOPY processed BOM Component Exposed Column Record
	 * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Rec_Type}
	 * @param x_Mesg_Token_Tbl IN OUT NOCOPY Message Token Table
	 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	 * @param x_Return_Status IN OUT NOCOPY Return Status
	 * @rep:scope private
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Check Direct Components
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 */

PROCEDURE Check_Direct_item_comps
(    p_bom_component_rec       IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
   , p_bom_comp_unexp_rec      IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
   , x_bom_component_rec       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
   , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_Return_Status           IN OUT NOCOPY VARCHAR2
);

	/*#
	 * This method sets the global attribute flags.This is called only by
	 * ECO Form.The Open Interfaces will perform this step in the entity validation
	 * procedure
	 * @param p_RI_bom_item_type IN Revised Item BOM Item Type
	 * @param  p_RC_bom_item_type IN Revised COmponent BOM Item Type
	 * @param p_RC_replenish_to_order_flag IN Revsed Component Replenish to Order Flag
	 * @param p_RI_replenish_to_order_flag IN Revsed Item  Replenish to Order Flag
	 * @param p_RC_base_item_id Revised IN Component Base Item Id
	 * @param p_RC_pick_components_flag IN Revised Component Pick To Order Flag
	 * @param p_RI_pick_components_flag IN Revised Item Pick To Order Flag
	 * @param p_RC_ato_forecast_control IN
	 * @param p_RI_base_item_id IN Revised Item Base Item Id
	 * @param p_RC_eng_item_flag IN Revised Component Engineering Item Flag
	 * @param p_RI_eng_item_flag IN Revised Item  Engineering Item Flag
	 * @param p_RC_atp_components_flag IN Revised Component ATP componetns flag
	 * @param p_RI_atp_components_flag IN Revised Item  ATP componetns flag
	 * @param  p_RC_atp_flag IN Revised Component ATP flag
	 * @param p_RC_wip_supply_type IN Revised Component WIP Supply Type
 	 * @param p_RI_wip_supply_type IN Revised Item WIP Supply Type
	 * @param p_RI_bom_enabled_flag IN Revised Item Bom Enabled Flag
	 * @param  p_RC_bom_enabled_flag IN Revised Component Bom Enabled Flag
	 * @rep:scope private
	 * @rep:lifecycle active
	 * @rep:compatibility S
 	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 * @rep:displayname Set Item Attribute
	 */
PROCEDURE Set_Item_Attributes
( p_RI_bom_item_type            NUMBER
, p_RC_bom_item_type            NUMBER
, p_RC_replenish_to_order_flag  CHAR
, p_RI_replenish_to_order_flag  CHAR
, p_RC_pick_components_flag     CHAR
, p_RI_pick_components_flag     CHAR
, p_RC_base_item_id             NUMBER
, p_RC_ato_forecast_control     NUMBER
, p_RI_base_item_id             NUMBER
, p_RC_eng_item_flag            CHAR
, p_RI_eng_item_flag            CHAR
, p_RC_atp_components_flag      CHAR
, p_RI_atp_components_flag      CHAR
, p_RC_atp_flag                 CHAR
, p_RI_wip_supply_type          NUMBER
, p_RC_wip_supply_type          NUMBER
, p_RI_bom_enabled_flag         CHAR
, p_RC_bom_enabled_flag         CHAR
);

	/*#
	 * This method will create Component Record from the attributes given and will
	 * perform Check_Access for both parent and component item.It will also
	 * perform Attribute Validation and Entity Validation for the component
	 * record.
	 * @param p_bo_identifier IN Business Object Identifier
	 * @param p_transaction_type IN Transaction Type
	 * @param p_revised_item_id IN Revised Item Id
	 * @param p_organization_id IN Organization Id
	 * @param p_organization_code IN Organization Code
	 * @param p_alternate_bom_code IN BOM Alternate Designator
	 * @param p_bill_sequence_id IN Bill Sequence Id
	 * @param p_bom_implementation_date IN Implementation Date
	 * @param p_component_sequence_id IN Component Sequence ID
	 * @param p_item_sequence_number IN Item Sequence Number
	 * @param p_operation_sequence_number IN Operation Sequence Number
	 * @param p_new_operation_sequence_num IN New Operation Sequence Number
	 * @param p_component_item_id IN Component Item Id
	 * @param p_from_end_item_unit_number IN From End Item Unit Number
	 * @param p_to_end_item_unit_number IN To End Item Unit Number
	 * @param p_new_from_end_item_unit_num IN New From End Item Unit Number
	 * @param p_start_effective_date IN Effectivity Start Date
	 * @param p_new_effectivity_date IN New Effectivity Date
	 * @param p_disable_date IN Disable Date
	 * @param p_quantity_per_assembly IN Quantity Per Assembly
	 * @param p_projected_yield IN Projected Yield
	 * @param p_planning_percent IN Planning Percent
	 * @param p_quantity_related IN Quantity Related
	 * @param p_include_in_cost_rollup IN Include In Cost Rollup
	 * @param p_check_atp In Check ATP
	 * @param p_acd_type IN ACD Type
	 * @param p_auto_request_material IN Auto Request Material
	 * @param p_wip_supply_type IN WIP Supply Type
	 * @param p_Supply_SubInventory IN Supply Subinventory
	 * @param p_supply_locator_id IN Supply Locator Id
	 * @param p_location_name IN Location Name
	 * @param  p_SO_Basis IN SO Basis
	 * @param p_Optional IN Optional
	 * @param  p_mutually_exclusive IN Mutually Exclusive
	 * @param p_shipping_allowed IN Shipping Allowed
	 * @param p_required_to_ship IN Required TO Ship
	 * @param p_required_for_revenue IN Required For Revenue
	 * @param p_include_on_ship_docs IN Include On Ship Docs
	 * @param p_enforce_int_reqs_code IN Enforce Int Reqs Code
	 * @param p_revised_item_name  IN revised Item Name
	 * @param p_component_item_name IN Component Item Name
	 * @param p_minimum_allowed_quantity IN Minimum Allowed Quantity
	 * @param p_maximum_allowed_quantity IN Maximum Allowed Quanitity
	 * @param p_Delete_Group_Name IN Delete Group Name
	 * @param p_eco_name ECO Name
	 * @param p_comments IN Comments
	 * @param p_pick_components IN Pick Component
	 * @param p_revised_item_sequence_id IN Revised Item Sequence Id
	 * @param p_old_operation_sequence_num IN Old Operation Sequence Number
	 * @param p_old_component_sequence_id IN Old Component Sequence Id
	 * @param p_old_effectivity_date IN Old Effectvity Date
	 * @param p_old_rec_item_sequence_number IN Old Record Item Sequence Number
	 * @param p_Old_Rec_shipping_Allowed IN Old Record Shipping Allowed
	 * @param p_Old_rec_supply_locator_id IN Old Record Supply Locator Id
	 * @param p_Old_rec_supply_subinventory IN Old Record Supply Subinventory
	 * @param p_old_rec_check_atp IN Old Record Check ATP
	 * @param p_old_rec_acd_type IN Old Record acs Type
	 * @param p_old_rec_to_end_item_unit_num IN Old Record To End Item Unit Number
	 * @param p_original_system_reference  IN Old Record Original System reference
	 * @param p_rowid IN Rowid
	 * @param x_return_status IN OUT NOCOPY Return Status
	 * @param x_error_message IN OUT NOCOPY Error Message
	 * @rep:scope private
	 * @rep:compatibility S
	 * @rep:lifecycle active
	 * @rep:displayname Validaet All Attribute
	 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 */

PROCEDURE Validate_All_Attributes
(       p_bo_identifier                   IN VARCHAR2 := 'BOM',
        p_transaction_type                IN  VARCHAR2,
        p_revised_item_id                 IN  NUMBER,
        p_organization_id                 IN  NUMBER,
        p_organization_code               IN  VARCHAR2,
        p_alternate_bom_code              IN  VARCHAR2,
        p_bill_sequence_id                IN  NUMBER,
        p_bom_implementation_date         IN  DATE,
        p_component_sequence_id           IN  NUMBER,
        p_item_sequence_number            IN  NUMBER,
        p_operation_sequence_number       IN  NUMBER,
        p_new_operation_sequence_num      IN  NUMBER := NULL,
        p_component_item_id               IN  NUMBER,
        p_from_end_item_unit_number       IN  VARCHAR2 := NULL,
        p_to_end_item_unit_number         IN  VARCHAR2 := NULL,
        p_new_from_end_item_unit_num      IN  VARCHAR2 := NULL,
        p_start_effective_date            IN  DATE,
        p_new_effectivity_date            IN  DATE := NULL,
        p_disable_date                    IN  DATE := NULL,
        p_basis_type			  IN  NUMBER := NULL,
        p_quantity_per_assembly           IN  NUMBER := NULL,
        p_projected_yield                 IN  NUMBER := NULL,
        p_planning_percent                IN  NUMBER := NULL,
        p_quantity_related                IN  NUMBER := NULL,
        p_include_in_cost_rollup          IN  NUMBER := NULL,
        p_check_atp                       IN  NUMBER := NULL,
        p_acd_type                        IN  NUMBER := NULL,
        p_auto_request_material           IN  VARCHAR2 := NULL,
        p_wip_supply_type                 IN  NUMBER := NULL,
        p_Supply_SubInventory             IN  VARCHAR2 := NULL,
        p_supply_locator_id               IN  NUMBER := NULL,
        p_location_name                   IN  VARCHAR2 := NULL,
        p_SO_Basis                        IN  NUMBER := NULL,
        p_Optional                        IN  NUMBER := NULL,
        p_mutually_exclusive              IN  NUMBER := NULL,
        p_shipping_allowed                IN  NUMBER := NULL,
        p_required_to_ship                IN  NUMBER := NULL,
        p_required_for_revenue            IN  NUMBER := NULL,
        p_include_on_ship_docs            IN  NUMBER := NULL,
        p_enforce_int_reqs_code           IN  NUMBER := NULL,
        p_revised_item_name               IN  VARCHAR2 := NULL,
        p_component_item_name             IN  VARCHAR2 := NULL,
        p_minimum_allowed_quantity        IN  NUMBER := NULL,
        p_maximum_allowed_quantity        IN  NUMBER := NULL,
        p_Delete_Group_Name               IN  VARCHAR2 := NULL,
        p_eco_name                        IN  VARCHAR2 := NULL,
        p_comments                        IN  VARCHAR2 := NULL,
        p_pick_components                 IN  NUMBER := NULL,
        p_revised_item_sequence_id        IN  NUMBER := NULL,
        p_old_operation_sequence_num      IN  NUMBER := NULL,
        p_old_component_sequence_id       IN  NUMBER := NULL,
        p_old_effectivity_date            IN  DATE := NULL,
        p_old_rec_item_sequence_number    IN  NUMBER := NULL,
        p_Old_Rec_shipping_Allowed        IN  NUMBER := NULL,
        p_Old_rec_supply_locator_id       IN  NUMBER := NULL,
        p_Old_rec_supply_subinventory     IN  VARCHAR2 := NULL,
        p_old_rec_check_atp               IN  NUMBER := NULL,
        p_old_rec_acd_type                IN  NUMBER := NULL,
        p_old_rec_to_end_item_unit_num    IN  VARCHAR2 := NULL,
        p_original_system_reference       IN  VARCHAR2 := NULL,
        p_rowid                           IN  VARCHAR2 := NULL,
        x_return_status                  IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
        x_error_message                  IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2);


	 /*****************************************************************
	 * Function	: Control
	 * Parameter IN	: Org Level Control
	 *		  Subinventory Level Control
	 *		  Item Level Control
	 * Returns	: Number
	 * Purpose	: Control procedure will take the various level control
	 *		  values and decide if the Locator is controlled at the
         *		  org,subinventory or item level. It will also decide
	 *		  if the locator is pre-specified or dynamic.
	 *******************************************************************/

   FUNCTION CONTROL(org_control      IN    number,
                    sub_control      IN    number,
                    item_control     IN    number default NULL)
                    RETURN NUMBER  ;

   -- add for Bug 8639519
  -- Check if the PTO and ATO flags of Assembly and Component for the
  -- Optional flag to be correct.
  --
    FUNCTION Check_PTOATO_For_Optional(p_assembly_org_id IN NUMBER,
	p_assembly_item_id IN NUMBER,
	p_comp_org_id IN NUMBER,
	p_comp_item_id IN NUMBER)
          RETURN NUMBER;

END BOM_Validate_Bom_Component;

/
