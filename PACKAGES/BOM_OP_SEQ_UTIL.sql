--------------------------------------------------------
--  DDL for Package BOM_OP_SEQ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_OP_SEQ_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMUOPSS.pls 120.1 2006/01/03 22:17:27 bbpatel noship $ */
/*#
 * This API contains Routing Operation entity utility procedure. Utility procedures
 * include insert, update, query, delete and perform writes (insert/update/delete) for a row.
 *
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Routing Operation Utitlity package
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
--      BOMUOPSS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Op_Seq_UTIL
--
--  NOTES
--
--  HISTORY
--  07-AUG-2000 Masanori Kimizuka    Initial Creation
--
****************************************************************************/


/****************************************************************************
*  QUERY ROW
*****************************************************************************/

/** Routing BO Query_Row **/
/*#
 * Procedure to query a database record and return the populated Exposed and Unexposed
 * Routing Operation record.
 *
 * @param p_operation_sequence_number IN Operation Sequence Number
 * @param p_effectivity_date IN Operation Effectivity Date
 * @param p_routing_sequence_id IN Routing Sequence Id
 * @param p_operation_type IN Operation Type
 * @param p_mesg_token_tbl IN Input Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_operation_rec IN OUT NOCOPY Populated Routing Operation Exposed Record from queried row
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
 * @param x_op_unexp_rec IN OUT NOCOPY Populated Routing Operation Unexposed Record from queried row
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status, Record Found or not Found
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Query a row for Routing Operation record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Query_Row
       ( p_operation_sequence_number IN  NUMBER
       , p_effectivity_date          IN  DATE
       , p_routing_sequence_id       IN  NUMBER
       , p_operation_type            IN  NUMBER
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_operation_rec             IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
       , x_op_unexp_rec              IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       ) ;



/** ECO BO Query_Row **/
/*#
 * Procedure to query a database record and return the populated Exposed and Unexposed
 * Revised Routing Operation record.
 *
 * @param p_operation_sequence_number IN Operation Sequence Number
 * @param p_effectivity_date IN Operation Effectivity Date
 * @param p_routing_sequence_id IN Routing Sequence Id
 * @param p_operation_type IN Operation Type
 * @param p_mesg_token_tbl IN Input Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_rev_operation_rec IN OUT NOCOPY Populated Revised Routing Operation Exposed Record from queried row
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
 * @param x_rev_op_unexp_rec IN OUT NOCOPY Populated Revised Routing Operation Unexposed Record from queried row
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status, Record Found or not Found
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Query a row for Revised Routing Operation record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Query_Row
       ( p_operation_sequence_number IN  NUMBER
       , p_effectivity_date          IN  DATE
       , p_routing_sequence_id       IN  NUMBER
       , p_operation_type            IN  NUMBER
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_rev_operation_rec         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
       , x_rev_op_unexp_rec          IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       ) ;




/** Common Operation Query_Row **/
/*#
 * Procedure to query a database record and return the populated Exposed and Unexposed
 * Common Routing Operation record.
 *
 * @param p_operation_sequence_number IN Operation Sequence Number
 * @param p_effectivity_date IN Operation Effectivity Date
 * @param p_routing_sequence_id IN Routing Sequence Id
 * @param p_operation_type IN Operation Type
 * @param p_mesg_token_tbl IN Input Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_com_operation_rec IN OUT NOCOPY Populated Common Routing Operation Exposed Record from queried row
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param x_com_op_unexp_rec IN OUT NOCOPY Populated Common Routing Operation Unexposed Record from queried row
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status, Record Found or not Found
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Query a row for Common Routing Operation record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Query_Row
       ( p_operation_sequence_number IN  NUMBER
       , p_effectivity_date          IN  DATE
       , p_routing_sequence_id       IN  NUMBER
       , p_operation_type            IN  NUMBER
       , p_mesg_token_tbl            IN  Error_Handler.Mesg_Token_Tbl_Type
       , x_com_operation_rec         IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
       , x_com_op_unexp_rec          IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
       , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status             IN OUT NOCOPY VARCHAR2
       ) ;


/****************************************************************************
*  PERFORM WRITE
*****************************************************************************/

/** Routing BO Perform Writes **/
/*#
 * Procedure to insert/update/delete a database record using Exposed and Unexposed
 * Routing Operation record depending on Transaction Type.
 *
 * @param p_operation_rec IN Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type }
 * @param p_op_unexp_rec  IN Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 * @param x_mesg_token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Insert/Update/Delete a row for Routing Operation record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Perform_Writes
        (  p_operation_rec         IN  Bom_Rtg_Pub.Operation_Rec_Type
         , p_op_unexp_rec          IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;

/** ECO BO Perform Writes **/
/*#
 * Procedure to insert/update/delete a database record using Exposed and Unexposed
 * Revised Routing Operation record depending on Transaction Type.
 *
 * @param p_rev_operation_rec IN Revised Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type }
 * @param p_rev_op_unexp_rec  IN Revised Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 * @param p_control_rec IN Control Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
 * @param x_mesg_token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Insert/Update/Delete a row for Revised Routing Operation record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Perform_Writes
        (  p_rev_operation_rec         IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
         , p_rev_op_unexp_rec          IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
         , p_control_rec               IN  Bom_Rtg_Pub.Control_Rec_Type
         , x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status             IN OUT NOCOPY VARCHAR2
        ) ;

/** Common Operation Perform Writes **/
/*#
 * Procedure to insert/update/delete a database record using Exposed and Unexposed
 * Common Routing Operation record depending on Transaction Type.
 *
 * @param p_com_operation_rec IN Common Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param p_com_op_unexp_rec  IN Common Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param p_control_rec IN Control Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Control_Rec_Type}
 * @param x_mesg_token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Insert/Update/Delete a row for Common Routing Operation record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Perform_Writes
        (  p_com_operation_rec     IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
         , p_com_op_unexp_rec      IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , p_control_rec           IN  Bom_Rtg_Pub.Control_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;

/****************************************************************************
*  OTHERS
*****************************************************************************/

/** Insert  Operation  **/
/*#
 * Procedure inserts a database record using Exposed and Unexposed
 * Routing Operation record.
 *
 * @param p_com_operation_rec IN Common Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param p_com_op_unexp_rec  IN Common Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Insert a row for Routing Operation record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Insert_Row
        (  p_com_operation_rec     IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
         , p_com_op_unexp_rec      IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;

/** Update  Operation  **/
/*#
 * Procedure updates a database record using Exposed and Unexposed
 * Routing Operation record.
 *
 * @param p_com_operation_rec IN Common Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param p_com_op_unexp_rec  IN Common Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Update a row for Routing Operation record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Update_Row
        (  p_com_operation_rec     IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
         , p_com_op_unexp_rec      IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;


/** Delete  Operations  **/
/*#
 * Procedure deletes a database record using Exposed and Unexposed
 * Routing Operation record. For ECO BO, revised operation record will be
 * deleted. For Routing BO, a delete group will be created to delete an Operation.
 *
 * @param p_com_operation_rec IN Common Routing Operation Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param p_com_op_unexp_rec  IN Common Routing Operation Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_com_operation_rec IN OUT NOCOPY Common Routing Operation Exposed Record after deletion
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type }
 * @param x_com_op_unexp_rec  IN OUT NOCOPY Common Routing Operation Unexposed Record after deletion
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_mesg_token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Delete a row for Routing Operation record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Delete_Row
        (  p_com_operation_rec     IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
         , p_com_op_unexp_rec      IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_com_operation_rec     IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
         , x_com_op_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        ) ;

/** ECO BO Cancel Revised Operation  **/

/*#
 * This procedure is commented out to remove the dependency of Routing BO code on ENG.
 *
 * @param p_operation_sequence_id IN Operation Sequence Id
 * @param p_cancel_comments IN Cancel Comments
 * @param p_op_seq_num IN Operation Sequence Number
 * @param p_user_id IN User Id
 * @param p_login_id IN Login Id
 * @param p_prog_id IN Program Id
 * @param p_prog_appid IN Program Application Id
 * @param x_mesg_token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Cancel the Revised Operation
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Cancel_Operation
( p_operation_sequence_id  IN  NUMBER
, p_cancel_comments        IN  VARCHAR2
, p_op_seq_num             IN  NUMBER
, p_user_id                IN  NUMBER
, p_login_id               IN  NUMBER
, p_prog_id                IN  NUMBER
, p_prog_appid             IN  NUMBER
, x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status          IN OUT NOCOPY VARCHAR2
) ;



/** ECO BO Create New Routing **/
/*#
 * This procedure is commented out to remove the dependency of Routing BO code on ENG.
 *
 * @param p_assembly_item_id IN Assembly Item Id
 * @param p_organization_id IN Organization Id
 * @param p_alternate_routing_code IN  Alternate Routing Code
 * @param p_pending_from_ecn IN Pending from ECN
 * @param p_routing_sequence_id IN Routing Sequence Id
 * @param p_common_routing_sequence_id IN Common Routing Sequence Id
 * @param p_routing_type IN Routing Type
 * @param p_last_update_date IN Last Update Date
 * @param p_last_updated_by IN Last Update By
 * @param p_creation_date IN Creation Date
 * @param p_created_by IN Created By
 * @param p_login_id IN Login Id
 * @param p_revised_item_sequence_id IN Revised Item Sequence
 * @param p_original_system_reference IN Original System Reference
 * @param x_mesg_token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Create New Routing
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Create_New_Routing
            ( p_assembly_item_id            IN NUMBER
            , p_organization_id             IN NUMBER
            , p_alternate_routing_code      IN VARCHAR2
            , p_pending_from_ecn            IN VARCHAR2
            , p_routing_sequence_id         IN NUMBER
            , p_common_routing_sequence_id  IN NUMBER
            , p_routing_type                IN NUMBER
            , p_last_update_date            IN DATE
            , p_last_updated_by             IN NUMBER
            , p_creation_date               IN DATE
            , p_created_by                  IN NUMBER
            , p_login_id                    IN NUMBER
            , p_revised_item_sequence_id    IN NUMBER
            , p_original_system_reference   IN VARCHAR2
            , x_mesg_token_tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
            , x_return_status               IN OUT NOCOPY VARCHAR2
            ) ;

END BOM_Op_Seq_UTIL;


 

/
