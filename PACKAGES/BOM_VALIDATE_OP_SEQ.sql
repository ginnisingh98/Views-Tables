--------------------------------------------------------
--  DDL for Package BOM_VALIDATE_OP_SEQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE_OP_SEQ" AUTHID CURRENT_USER AS
/* $Header: BOMLOPSS.pls 120.1 2006/01/03 22:00:59 bbpatel noship $ */
/*#
 * This API performs Attribute and Entity level validations for Routing Operation.
 * Entity level validations include existence and accessibility check for Routing
 * Operation record. Attribute level validations include check for required attributes and
 * business logic validations.
 *
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Validate Routing Operation
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */

/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLOPSS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate_Op_Seq
--
--  NOTES
--
--  HISTORY
--  07-AUG-2000 Masanori Kimizuka    Initial Creation
--
****************************************************************************/



/****************************************************************************
*  CHECK EXISTENCE
*****************************************************************************/


-- Check_Existence used by RTG BO
/*#
 * Procedure will query the routing operation record and return it in old record variable.
 * If the Transaction Type is Create and the record already exists the return status
 * would be error. If the Transaction Type is Update or Delete and the record does not
 * exist then the return status would be an error as well. Such an error in a record will
 * cause all children to error out, since they are referencing an invalid parent.
 * Mesg_Token_Table will carry the error messsage and the tokens associated with the message.
 *
 * @param p_operation_rec IN Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
 * @param p_op_unexp_rec  IN Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 * @param x_old_operation_rec IN OUT NOCOPY Routing Operation Exposed Record if already exists
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
 * @param x_old_op_unexp_rec IN OUT NOCOPY Routing Operation Unexposed Record if already exists
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Existence for Routing Operation record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Existence
(  p_operation_rec      IN  Bom_Rtg_Pub.Operation_Rec_Type
 , p_op_unexp_rec       IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
 , x_old_operation_rec  IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
 , x_old_op_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
 , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status      IN OUT NOCOPY VARCHAR2
) ;

-- Check_Existence used by ECO BO
/*#
 * Procedure will query the revised routing operation record and return it in old record variable.
 * If the Transaction Type is Create and the record already exists the return status
 * would be error. If the Transaction Type is Update or Delete and the record does not
 * exist then the return status would be an error as well. Such an error in a record will
 * cause all children to error out, since they are referencing an invalid parent.
 * Mesg_Token_Table will carry the error messsage and the tokens associated with the message.
 *
 * @param p_rev_operation_rec IN Revised Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
 * @param p_rev_op_unexp_rec  IN Revised Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 * @param x_old_rev_operation_rec IN OUT NOCOPY Revised Routing Operation Exposed Record if already exists
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
 * @param x_old_rev_op_unexp_rec IN OUT NOCOPY Revised Routing Operation Unexposed Record if already exists
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Existence for Revised Routing Operation record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Existence
(  p_rev_operation_rec        IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
 , p_rev_op_unexp_rec         IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
 , x_old_rev_operation_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
 , x_old_rev_op_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
) ;

-- Check_Existence internally called by RTG BO and ECO BO
/*#
 * Procedure will query the common routing operation record and return it in old record variable.
 * If the Transaction Type is Create and the record already exists the return status
 * would be error. If the Transaction Type is Update or Delete and the record does not
 * exist then the return status would be an error as well. Such an error in a record will
 * cause all children to error out, since they are referencing an invalid parent.
 * Mesg_Token_Table will carry the error messsage and the tokens associated with the message.
 *
 * @param p_com_operation_rec IN Common Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param p_com_op_unexp_rec  IN Common Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_old_com_operation_rec IN OUT NOCOPY Common Routing Operation Exposed Record if already exists
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param x_old_com_op_unexp_rec IN OUT NOCOPY Common Routing Operation Unexposed Record if already exists
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Existence for Common Routing Operation record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Existence
(  p_com_operation_rec        IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
 , p_com_op_unexp_rec         IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
 , x_old_com_operation_rec    IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
 , x_old_com_op_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
) ;



/****************************************************************************
*  CHECK LINEAGE
*****************************************************************************/

-- Check_Lineage used by ECO BO
/*#
 * Procedure will be used by ECO BO. This procedure will check whether the Operation
 * belongs to right parent Routing and that parent exists. Otherwise error status will be returned.
 * Mesg_Token_Table will carry the error messsage and the tokens associated with the message.
 *
 * @param p_routing_sequence_id IN Routing Sequence Id
 * @param p_operation_sequence_number IN Operation Sequence Number
 * @param p_effectivity_date IN Effectivity Date of the Operation
 * @param p_operation_type IN Operation Type
 * @param p_revised_item_sequence_id IN Revised Item Sequence Id
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Lineage for the Routing Operation
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Lineage
(  p_routing_sequence_id       IN   NUMBER
 , p_operation_sequence_number IN   NUMBER
 , p_effectivity_date          IN   DATE
 , p_operation_type            IN   NUMBER
 , p_revised_item_sequence_id  IN   NUMBER
 , x_mesg_token_tbl            IN OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status             IN OUT NOCOPY  VARCHAR2
 ) ;



/****************************************************************************
*  check common routing
*****************************************************************************/

-- Check_CommonRtg used by ECO BO and RTG BO
/*#
 * Procedure will verify that the parent Routing do not have common Routing.
 * Otherwise error status will be returned. Mesg_Token_Table will carry the
 * error messsage and the tokens associated with the message.
 *
 * @param p_routing_sequence_id IN Routing Sequence Id
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Common Routing
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_CommonRtg
(  p_routing_sequence_id  IN NUMBER
,  x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,  x_return_status        IN OUT NOCOPY VARCHAR2
) ;


/****************************************************************************
*  CHECK REQUIRED
*****************************************************************************/

-- Check_Required used by RTG BO
/*#
 * Procedure to check the required attributes for the Routing Operation record.
 * Some fields are required for an operation to be performed. The user must enter values
 * for these fields. This procedure checks whether the required field columns are not NULL.
 * Otherwise error status will be returned. Mesg_Token_Table will carry the
 * error messsage and the tokens associated with the message.
 *
 * @param p_operation_rec IN Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
 * @param x_return_status IN OUT NOCOPY Return Status
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Routing Operation required attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Required
( p_operation_rec   IN  Bom_Rtg_Pub.Operation_Rec_Type
, x_return_status       IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

-- Check_Required used by ECO BO
/*#
 * Procedure to check the required attributes for the Revised Routing Operation record.
 * Some fields are required for an operation to be performed. The user must enter values
 * for these fields. This procedure checks whether the required field columns are not NULL.
 * Otherwise error status will be returned. Mesg_Token_Table will carry the
 * error messsage and the tokens associated with the message.
 *
 * @param p_rev_operation_rec IN Revised Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
 * @param x_return_status IN OUT NOCOPY Return Status
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Revised Routing Operation required attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Required
( p_rev_operation_rec   IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
, x_return_status       IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;


-- Check_Required internally called by RTG BO and by ECO BO
/*#
 * Procedure to check the required attributes for the Common Routing Operation record.
 * Some fields are required for an operation to be performed. The user must enter values
 * for these fields. This procedure checks whether the required field columns are not NULL.
 * Otherwise error status will be returned. Mesg_Token_Table will carry the
 * error messsage and the tokens associated with the message.
 *
 * @param p_com_operation_rec IN Common Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param x_return_status IN OUT NOCOPY Return Status
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Common Routing Operation required attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Required
(  p_com_operation_rec        IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;


/****************************************************************************
*  CHECK ATTRIBUTES
*****************************************************************************/

-- Check_Attributes used by RTG BO
/*#
 * This procedure checks the attributes validity of Routing Operation record. Validations include check for
 * missing attribute values in case of UPDATE, valid attributes values.
 * Otherwise error status will be returned. Mesg_Token_Table will carry the
 * error messsage and the tokens associated with the message.
 *
 * @param p_operation_rec IN Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
 * @param p_op_unexp_rec  IN Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Routing Operation attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Attributes
(  p_operation_rec      IN  Bom_Rtg_Pub.Operation_Rec_Type
 , p_op_unexp_rec       IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
 , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status      IN OUT NOCOPY VARCHAR2
) ;


-- Check_Attributes used by ECO BO
/*#
 * This procedure checks the attributes validity of Revised Routing Operation record.
 * Validations include check for missing attribute values in case of UPDATE,
 * valid attributes values. Otherwise error status will be returned.
 * Mesg_Token_Table will carry the error messsage and the tokens associated
 * with the message.
 *
 * @param p_rev_operation_rec IN Revised Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
 * @param p_rev_op_unexp_rec  IN Revised Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Revised Routing Operation attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Attributes
(  p_rev_operation_rec  IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
 , p_rev_op_unexp_rec   IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
 , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status      IN OUT NOCOPY VARCHAR2
) ;


-- Check_Attributes internally called by RTG BO and ECO BO
/*#
 * This procedure checks the attributes validity of Common Routing Operation record.
 * Validations include check for missing attribute values in case of UPDATE,
 * valid attributes values. Otherwise error status will be returned.
 * Mesg_Token_Table will carry the error messsage and the tokens associated
 * with the message.
 *
 * @param p_com_operation_rec IN Common Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param p_com_op_unexp_rec  IN Common Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Common Routing Operation attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Attributes
(  p_com_operation_rec        IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
 , p_com_op_unexp_rec         IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
) ;


/****************************************************************************
*  CHECK CONDITIONALLY REQUIRED
*****************************************************************************/

-- Check_Conditionally_Required used by RTG BO
/*#
 * This procedure checks the conditionally required attributes for Routing Operation record.
 * Currently there is no code in this procedure as it is moved to Check_Required procedure.
 *
 * @param p_operation_rec IN Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
 * @param p_op_unexp_rec  IN Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Conditionally required Routing Operation attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Conditionally_Required
( p_operation_rec       IN  Bom_Rtg_Pub.Operation_Rec_Type
, p_op_unexp_rec        IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
, x_return_status       IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

-- Check_Conditionally_Required used by ECO BO
/*#
 * This procedure checks the conditionally required attributes for Revised Routing Operation record.
 * Currently there is no code in this procedure as it is moved to Check_Required procedure.
 *
 * @param p_rev_operation_rec IN Revised Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
 * @param p_rev_op_unexp_rec  IN Revised Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Conditionally required Revised Routing Operation attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Conditionally_Required
( p_rev_operation_rec   IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
, p_rev_op_unexp_rec    IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
, x_return_status       IN OUT NOCOPY VARCHAR2
, x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;

-- Check_Conditionally_Required  internally called by RTG BO and ECO BO
/*#
 * This procedure checks the conditionally required attributes for Common Routing Operation record.
 * Currently there is no code in this procedure as it is moved to Check_Required procedure.
 *
 * @param p_com_operation_rec IN Common Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param p_com_op_unexp_rec  IN Common Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Conditionally required Common Routing Operation attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Conditionally_Required
(  p_com_operation_rec        IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
 , p_com_op_unexp_rec         IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;



/****************************************************************************
*  CHECK NONOPERATED ATTRIBUTES
*****************************************************************************/

-- Check_NonOperated_Attribute used by RTG BO
/*#
 * This procedure, depending on CFM Routing Flag, checks if Routing Operation's
 * non-operated attribute is null. If so, the procedure sets the value to null and
 * and sets the warning message indicating non-operated attribute is ignored.
 *
 * @param p_operation_rec IN Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
 * @param p_op_unexp_rec  IN Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 * @param x_operation_rec IN OUT NOCOPY Routing Operation Exposed Record after processing
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
 * @param x_op_unexp_rec  IN OUT NOCOPY Routing Operation Unexposed Record after processing
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check non-operated Routing Operation attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_NonOperated_Attribute
(  p_operation_rec        IN  Bom_Rtg_Pub.Operation_Rec_Type
 , p_op_unexp_rec         IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
 , x_operation_rec        IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
 , x_op_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
 , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status        IN OUT NOCOPY VARCHAR2
) ;

-- Check_NonOperated_Attribute used by ECO BO
/*#
 * This procedure, depending on CFM Routing Flag, checks if Revised Routing Operation's
 * non-operated attribute is null. If so, the procedure sets the value to null and
 * and sets the warning message indicating non-operated attribute is ignored.
 *
 * @param p_rev_operation_rec IN Revised Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
 * @param p_rev_op_unexp_rec  IN Revised Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 * @param x_rev_operation_rec IN OUT NOCOPY Revised Routing Operation Exposed Record after processing
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
 * @param x_rev_op_unexp_rec  IN OUT NOCOPY Revised Routing Operation Unexposed Record after processing
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check non-operated Revised Routing Operation attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_NonOperated_Attribute
( p_rev_operation_rec        IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
, p_rev_op_unexp_rec         IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
, x_rev_operation_rec        IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
, x_rev_op_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
, x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status            IN OUT NOCOPY VARCHAR2
)  ;


-- Check_NonOperated_Attribute internally called by RTG BO and ECO BO
/*#
 * This procedure, depending on CFM Routing Flag, checks if Common Routing Operation's
 * non-operated attribute is null. If so, the procedure sets the value to null and
 * and sets the warning message indicating non-operated attribute is ignored.
 *
 * @param p_com_operation_rec IN Common Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param p_com_op_unexp_rec  IN Common Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_com_operation_rec IN OUT NOCOPY Common Routing Operation Exposed Record after processing
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param x_com_op_unexp_rec  IN OUT NOCOPY Common Routing Operation Unexposed Record after processing
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check non-operated Common Routing Operation attributes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_NonOperated_Attribute
(  p_com_operation_rec        IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
 , p_com_op_unexp_rec         IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
 , x_com_operation_rec        IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
 , x_com_op_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
) ;



/****************************************************************************
*  CHECK ENTITY ATTRIBUTES
*****************************************************************************/

-- Check_Entity used by RTG BO
/*#
 * Procedure to validate the Routing Operation entity record.
 * The following are checked:
 *	Non-updateable columns (UPDATEs): Certain columns must not be changed by the user when updating the record.
 *	Cross-attribute checking: The validity of attributes is checked, based on factors external to it.
 *	Business logic: The record must comply with business logic rules.
 *
 * @param p_operation_rec IN Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
 * @param p_op_unexp_rec  IN Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 * @param p_old_operation_rec IN Old Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
 * @param p_old_op_unexp_rec IN Old Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 * @param x_operation_rec IN OUT NOCOPY Routing Operation Exposed Record after processing
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
 * @param x_op_unexp_rec  IN OUT NOCOPY Routing Operation Unexposed Record after processing
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Routing Operation entity
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Entity
(  p_operation_rec      IN  Bom_Rtg_Pub.Operation_Rec_Type
 , p_op_unexp_rec       IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
 , p_old_operation_rec  IN  Bom_Rtg_Pub.Operation_Rec_Type
 , p_old_op_unexp_rec   IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
 , x_operation_rec      IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
 , x_op_unexp_rec       IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
 , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status      IN OUT NOCOPY VARCHAR2
) ;

-- Check_Entity used by ECO BO
/*#
 * Procedure to validate the Revised Routing Operation entity record.
 * The following are checked:
 *	Non-updateable columns (UPDATEs): Certain columns must not be changed by the user when updating the record.
 *	Cross-attribute checking: The validity of attributes is checked, based on factors external to it.
 *	Business logic: The record must comply with business logic rules.
 *
 * @param p_rev_operation_rec IN Revised Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
 * @param p_rev_op_unexp_rec  IN Revised Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 * @param p_old_rev_operation_rec IN Old Revised Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
 * @param p_old_rev_op_unexp_rec IN Old Revised Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 * @param p_control_rec IN Control Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
 * @param x_rev_operation_rec IN OUT NOCOPY Revised Routing Operation Exposed Record after processing
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
 * @param x_rev_op_unexp_rec  IN OUT NOCOPY Revised Routing Operation Unexposed Record after processing
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Revised Routing Operation entity
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Entity
(  p_rev_operation_rec        IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
 , p_rev_op_unexp_rec         IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
 , p_old_rev_operation_rec    IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
 , p_old_rev_op_unexp_rec     IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
 , p_control_rec              IN  Bom_Rtg_Pub.Control_Rec_Type
 , x_rev_operation_rec        IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
 , x_rev_op_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
) ;

-- Check_Entity internally called by RTG BO and by ECO BO
/*#
 * Procedure to validate the Common Routing Operation entity record.
 * The following are checked:
 *	Non-updateable columns (UPDATEs): Certain columns must not be changed by the user when updating the record.
 *	Cross-attribute checking: The validity of attributes is checked, based on factors external to it.
 *	Business logic: The record must comply with business logic rules.
 *
 * @param p_com_operation_rec IN Common Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param p_com_op_unexp_rec  IN Common Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param p_old_com_operation_rec IN Old Common Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param p_old_com_op_unexp_rec IN Old Common Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param p_control_rec IN Control Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
 * @param x_com_operation_rec IN OUT NOCOPY Common Routing Operation Exposed Record after processing
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param x_com_op_unexp_rec  IN OUT NOCOPY Common Routing Operation Unexposed Record after processing
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Common Routing Operation entity
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Entity
(  p_com_operation_rec        IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
 , p_com_op_unexp_rec         IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
 , p_old_com_operation_rec    IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
 , p_old_com_op_unexp_rec     IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
 , p_control_rec              IN  Bom_Rtg_Pub.Control_Rec_Type
 , x_com_operation_rec        IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
 , x_com_op_unexp_rec         IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
 , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status            IN OUT NOCOPY VARCHAR2
) ;

/****************************************************************************
* CHECK_ACCESS
*****************************************************************************/


/*#
 * This procedure will verify that the revised item and the revised operation
 * is accessible to the user.
 *
 * @param p_revised_item_name IN Revised Item Name
 * @param p_revised_item_id IN Revised Item Id
 * @param p_organization_id IN Organization Id
 * @param p_change_notice IN Change Order Name
 * @param p_new_item_revision IN New Item Revision
 * @param p_effectivity_date IN Effectivity Date for the Operation
 * @param p_new_routing_revsion IN New Routing Revision
 * @param p_from_end_item_number IN From End Item Unit Number
 * @param p_operation_seq_num IN Operation Sequence Number
 * @param p_routing_sequence_id IN Routing Sequence Id
 * @param p_operation_type IN Operation Type
 * @param p_Mesg_Token_Tbl IN Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param p_entity_processed IN Entity to be Processed. Valid values 'RES' and 'SR'.
 * @param p_resource_seq_num IN Resource Sequence Number
 * @param p_sub_resource_code IN Substitute Resource Code
 * @param p_sub_group_num IN Substitute Group Number
 * @param x_mesg_token_tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Access for Revised Item and Operation
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Check_Access
(  p_revised_item_name          IN  VARCHAR2
 , p_revised_item_id            IN  NUMBER
 , p_organization_id            IN  NUMBER
 , p_change_notice              IN  VARCHAR2
 , p_new_item_revision          IN  VARCHAR2
 , p_effectivity_date           IN  DATE
 , p_new_routing_revsion        IN  VARCHAR2 -- Added by MK on 11/02/00
 , p_from_end_item_number       IN  VARCHAR2 -- Added by MK on 11/02/00
 , p_operation_seq_num          IN  NUMBER
 , p_routing_sequence_id        IN  NUMBER
 , p_operation_type             IN  NUMBER
 , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type
 , p_entity_processed           IN  VARCHAR2
 , p_resource_seq_num           IN  NUMBER
 , p_sub_resource_code          IN  VARCHAR2
 , p_sub_group_num              IN  NUMBER
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
) ;

END BOM_Validate_Op_Seq ;

 

/
