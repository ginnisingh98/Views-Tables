--------------------------------------------------------
--  DDL for Package BOM_DEFAULT_OP_SEQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEFAULT_OP_SEQ" AUTHID CURRENT_USER AS
/* $Header: BOMDOPSS.pls 120.1 2006/01/03 21:59:23 bbpatel noship $ */
/*#
 * This API contains procedures that will copy values from Routing Operation record provided by the user.
 * In old record, atrributes having null values or not provided by the user, will be defaulted
 * to appropriate value. In the case of create, attributes will be defaulted to appropriate value.
 *
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Default Routing Operation record attributes
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
--      BOMDOPSS.pls
--
--  DESCRIPTION
--
--      Spec of package   BOM_Default_Op_Seq
--
--  NOTES
--
--  HISTORY
--  07-AUG-2000 Masanori Kimizuka    Initial Creation
--
****************************************************************************/



/****************************************************************************
*  ATTRIBUTE DEFAULTING
*****************************************************************************/

    --
    -- Attribute Defualting for Rtg Operation Sequence Record
    -- used by Rtg BO
    --
    /*#
     * Procedure to default values for exposed Routing Operation record.
     * In old record, atrributes, having null values or not provided by the user, will be defaulted
     * to appropriate value. For CREATEs, there is no OLD record. So procedure will default
     * individual attribute values, independent of each other. This
     * feature enables the user to enter minimal information for the
     * operation to go through.
     *
     * @param p_operation_rec IN Routing Operation Exposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
     * @param p_op_unexp_rec  IN Routing Operation Unexposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
     * @param x_operation_rec IN OUT NOCOPY Routing Operation Exposed Record after defaulting
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
     * @param x_op_unexp_rec IN OUT NOCOPY Routing Operation Unexposed Record after defaulting
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
     * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
     * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
     * @param x_return_status IN OUT NOCOPY Return Status
     *
     * @rep:scope private
     * @rep:lifecycle active
     * @rep:displayname Default Routing Operation record attributes
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
     */
    PROCEDURE Attribute_Defaulting
    (  p_operation_rec     IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_op_unexp_rec      IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_operation_rec     IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
     , x_op_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_mesg_token_tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status     IN OUT NOCOPY VARCHAR2
    ) ;


    --
    -- Attribute Defaulting for Reviesed Operation Sequence Record
    -- used by Eco BO
    --
    /*#
     * Procedure to default values for exposed Revised Routing Operation record.
     * In old record, atrributes, having null values or not provided by the user, will be defaulted
     * to appropriate value. For CREATEs, there is no OLD record. So procedure will default
     * individual attribute values, independent of each other. This
     * feature enables the user to enter minimal information for the
     * operation to go through.
     *
     * @param p_rev_operation_rec IN Revised Routing Operation Exposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
     * @param p_rev_op_unexp_rec  IN Revised Routing Operation Unexposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
     * @param p_control_Rec  IN Control Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
     * @param x_rev_operation_rec IN OUT NOCOPY Revised Routing Operation Exposed Record after defaulting
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
     * @param x_rev_op_unexp_rec IN OUT NOCOPY Revised Routing Operation Unexposed Record after defaulting
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
     * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
     * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
     * @param x_return_status IN OUT NOCOPY Return Status
     *
     * @rep:scope private
     * @rep:lifecycle active
     * @rep:displayname Default Revised Routing Operation record attributes
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
     */
    PROCEDURE Attribute_Defaulting
    (  p_rev_operation_rec    IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_rev_op_unexp_rec     IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , p_control_Rec          IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_operation_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , x_rev_op_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status        IN OUT NOCOPY VARCHAR2
    ) ;

    --
    -- Attribute Defaulting for Common Operation Sequence Record
    --
    /*#
     * Procedure to default values for exposed Common Routing Operation record.
     * In old record, atrributes, having null values or not provided by the user, will be defaulted
     * to appropriate value. For CREATEs, there is no OLD record. So procedure will default
     * individual attribute values, independent of each other. This
     * feature enables the user to enter minimal information for the
     * operation to go through.
     *
     * @param p_com_operation_rec IN Common Routing Operation Exposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
     * @param p_com_op_unexp_rec  IN Common Routing Operation Unexposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
     * @param p_control_Rec  IN Control Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
     * @param x_com_operation_rec IN OUT NOCOPY Common Routing Operation Exposed Record after defaulting
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
     * @param x_com_op_unexp_rec IN OUT NOCOPY Common Routing Operation Unexposed Record after defaulting
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
     * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
     * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
     * @param x_return_status IN OUT NOCOPY Return Status
     *
     * @rep:scope private
     * @rep:lifecycle active
     * @rep:displayname Default Common Routing Operation record attributes
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
     */
    PROCEDURE Attribute_Defaulting
    (  p_com_operation_rec    IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_com_op_unexp_rec     IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , p_control_Rec          IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_com_operation_rec    IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
     , x_com_op_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status        IN OUT NOCOPY VARCHAR2
    ) ;

/****************************************************************************
*  POPULATE NULL COLUMNS
*****************************************************************************/
    --
    -- Populate NULL Columns for Rtg Operation Sequence Record
    -- used by Rtg BO
    --
    /*#
     * Procedure to copy the existing values from old Routing Operation record, when the user has not
     * given the attribute values. This procedure will not be called in CREATE case.
     *
     * @param p_operation_rec IN Routing Operation Exposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
     * @param p_op_unexp_rec  IN Routing Operation Unexposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
     * @param p_old_operation_rec IN Old Routing Operation Exposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
     * @param p_old_op_unexp_rec  IN Old Routing Operation Unexposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
     * @param x_operation_rec IN OUT NOCOPY Routing Operation Exposed Record after processing
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
     * @param x_op_unexp_rec IN OUT NOCOPY Routing Operation Unexposed Record after processing
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
     *
     * @rep:scope private
     * @rep:lifecycle active
     * @rep:displayname Populate Null Routing Operation attributes
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
     */
    PROCEDURE Populate_Null_Columns
    (  p_operation_rec          IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_op_unexp_rec           IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , p_old_operation_rec      IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_old_op_unexp_rec       IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_operation_rec          IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
     , x_op_unexp_rec           IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
    ) ;

    --
    -- Populate NULL columns for Reviesed Operation Sequence Record
    -- used by Eco BO
    --
    /*#
     * Procedure to copy the existing values from old Revised Routing Operation record, when the user has not
     * given the attribute values. This procedure will not be called in CREATE case.
     *
     * @param p_rev_operation_rec IN Revised Routing Operation Exposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
     * @param p_rev_op_unexp_rec  IN Revised Routing Operation Unexposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
     * @param p_old_rev_operation_rec IN Old Revised Routing Operation Exposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
     * @param p_old_rev_op_unexp_rec  IN Old Revised Routing Operation Unexposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
     * @param x_rev_operation_rec IN OUT NOCOPY Revised Routing Operation Exposed Record after processing
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
     * @param x_rev_op_unexp_rec IN OUT NOCOPY Revised Routing Operation Unexposed Record after processing
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
     *
     * @rep:scope private
     * @rep:lifecycle active
     * @rep:displayname Populate Null Revised Routing Operation attributes
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
     */
    PROCEDURE Populate_Null_Columns
    (  p_rev_operation_rec      IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_rev_op_unexp_rec       IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , p_old_rev_operation_rec  IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_old_rev_op_unexp_rec   IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , x_rev_operation_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , x_rev_op_unexp_rec       IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
    ) ;

    --
    -- Populate NULL columns for Common
    --
    /*#
     * Procedure to copy the existing values from old Common Routing Operation record, when the user has not
     * given the attribute values. This procedure will not be called in CREATE case.
     *
     * @param p_com_operation_rec IN Common Routing Operation Exposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
     * @param p_com_op_unexp_rec  IN Common Routing Operation Unexposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
     * @param p_old_com_operation_rec IN Old Common Routing Operation Exposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
     * @param p_old_com_op_unexp_rec  IN Old Common Routing Operation Unexposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
     * @param x_com_operation_rec IN OUT NOCOPY Common Routing Operation Exposed Record after processing
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
     * @param x_com_op_unexp_rec IN OUT NOCOPY Common Routing Operation Unexposed Record after processing
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
     *
     * @rep:scope private
     * @rep:lifecycle active
     * @rep:displayname Populate Null Common Routing Operation attributes
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
     */
    PROCEDURE Populate_Null_Columns
    (  p_com_operation_rec      IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_com_op_unexp_rec       IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , p_old_com_operation_rec  IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_old_com_op_unexp_rec   IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_com_operation_rec      IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
     , x_com_op_unexp_rec       IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
    ) ;


/****************************************************************************
*  ENTITY LEVEL DEFAULTING
*****************************************************************************/
    --
    -- Entity Level Defaulting Rtg Operation Sequence Record
    -- used by Rtg BO
    --
    /*#
     * Procedure to default values for unexposed Routing Operation record.
     * In old record, atrributes, having null values or not provided by the user, will be defaulted
     * to appropriate value. For CREATEs, there is no OLD record. So procedure will default
     * individual attribute values, independent of each other.
     *
     * @param p_operation_rec IN Routing Operation Exposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
     * @param p_op_unexp_rec  IN Routing Operation Unexposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
     * @param x_operation_rec IN OUT NOCOPY Routing Operation Exposed Record after defaulting
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
     * @param x_op_unexp_rec IN OUT NOCOPY Routing Operation Unexposed Record after defaulting
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
     * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
     * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
     * @param x_return_status IN OUT NOCOPY Return Status
     *
     * @rep:scope private
     * @rep:lifecycle active
     * @rep:displayname Default Routing Operation entity attributes
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
     */
    PROCEDURE Entity_Defaulting
    (  p_operation_rec          IN  Bom_Rtg_Pub.Operation_Rec_Type
     , p_op_unexp_rec           IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_operation_rec          IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
     , x_op_unexp_rec           IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
     , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status          IN OUT NOCOPY VARCHAR2
    ) ;


    --
    -- Entity Level Defaulting for Reviesed Operation Sequence Record
    -- used by Eco BO
    --
    /*#
     * Procedure to default values for unexposed Revised Routing Operation record.
     * In old record, atrributes, having null values or not provided by the user, will be defaulted
     * to appropriate value. For CREATEs, there is no OLD record. So procedure will default
     * individual attribute values, independent of each other.
     *
     * @param p_rev_operation_rec IN Revised Routing Operation Exposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
     * @param p_rev_op_unexp_rec  IN Revised Routing Operation Unexposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
     * @param p_control_Rec  IN Control Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
     * @param x_rev_operation_rec IN OUT NOCOPY Revised Routing Operation Exposed Record after defaulting
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
     * @param x_rev_op_unexp_rec IN OUT NOCOPY Revised Routing Operation Unexposed Record after defaulting
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
     * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
     * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
     * @param x_return_status IN OUT NOCOPY Return Status
     *
     * @rep:scope private
     * @rep:lifecycle active
     * @rep:displayname Default Revised Routing Operation entity attributes
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
     */
    PROCEDURE Entity_Defaulting
    (  p_rev_operation_rec    IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , p_rev_op_unexp_rec     IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , p_control_Rec          IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_rev_operation_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
     , x_rev_op_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status        IN OUT NOCOPY VARCHAR2
    ) ;

    --
    -- Entity Level Defaulting for Common
    --
    /*#
     * Procedure to default values for unexposed Common Routing Operation record.
     * In old record, atrributes, having null values or not provided by the user, will be defaulted
     * to appropriate value. For CREATEs, there is no OLD record. So procedure will default
     * individual attribute values, independent of each other.
     *
     * @param p_com_operation_rec IN Common Routing Operation Exposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
     * @param p_com_op_unexp_rec  IN Common Routing Operation Unexposed Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
     * @param p_control_Rec  IN Control Record
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
     * @param x_com_operation_rec IN OUT NOCOPY Common Routing Operation Exposed Record after defaulting
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
     * @param x_com_op_unexp_rec IN OUT NOCOPY Common Routing Operation Unexposed Record after defaulting
     * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
     * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
     * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
     * @param x_return_status IN OUT NOCOPY Return Status
     *
     * @rep:scope private
     * @rep:lifecycle active
     * @rep:displayname Default Common Routing Operation entity attributes
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
     */
    PROCEDURE Entity_Defaulting
    (  p_com_operation_rec    IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
     , p_com_op_unexp_rec     IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , p_control_Rec          IN  Bom_Rtg_Pub.Control_Rec_Type
     , x_com_operation_rec    IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
     , x_com_op_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
     , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status        IN OUT NOCOPY VARCHAR2
    ) ;


END BOM_Default_Op_Seq ;

 

/
