--------------------------------------------------------
--  DDL for Package BOM_RTG_HEADER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_HEADER_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMURTGS.pls 120.1 2006/01/03 21:56:52 bbpatel noship $*/
/*#
 * This API contains Routing Header entity utility procedure. Utility procedures
 * include query, update and perform writes (insert/update/delete) for a row.
 *
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Routing Header Utitlity package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */

/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMURTGS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Rtg_Header_Util
--
--  NOTES
--
--  HISTORY
--  02-AUG-2000 Biao Zhang      Initial Creation
--
****************************************************************************/

/*#
 * Procedure to query a database record and return the populated Exposed and Unexposed
 * Routing Header record.
 *
 * @param p_assembly_item_id IN Assembly Item Id
 * @param p_organization_id IN Organization Id in which item is defined
 * @param p_alternate_routing_code IN Alternate Routing Code
 * @param x_rtg_header_rec IN OUT NOCOPY Populated Routing Header Exposed Record from queried row
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
 * @param x_rtg_header_unexp_rec  IN  OUT NOCOPY Populated Routing Header Unexposed Record from queried row
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
 * @param x_return_status IN OUT NOCOPY Return Status, Record Found or not Found
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Query a row for Routing Header record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Query_Row
( p_assembly_item_id    IN  NUMBER
, p_organization_id     IN  NUMBER
, p_alternate_routing_code      IN VARCHAR2
, x_rtg_header_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rtg_header_Rec_Type
, x_rtg_header_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rtg_header_unexposed_Rec_Type
, x_Return_status       IN OUT NOCOPY VARCHAR2
);

/*#
 * Procedure to update a database record using Exposed and Unexposed
 * Routing Header record.
 *
 * @param p_rtg_header_rec IN Routing Header Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type}
 * @param p_rtg_header_unexp_rec  IN  Routing Header Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
 * @param x_mesg_token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Update a row for Routing Header record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Update_Row
        (  p_RTG_header_rec     IN  Bom_Rtg_Pub.RTG_Header_Rec_Type
         , p_RTG_header_unexp_rec IN  Bom_Rtg_Pub.RTG_Header_Unexposed_Rec_Type
         , x_mesg_token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_Status      IN OUT NOCOPY VARCHAR2
         );

/*#
 * Procedure to insert/update/delete a database record using Exposed and Unexposed
 * Routing Header record depending on Transaction Type.
 *
 * @param p_rtg_header_rec IN Routing Header Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type}
 * @param p_rtg_header_unexp_rec  IN  Routing Header Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
 * @param x_mesg_token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Insert/Update/Delete a row for Routing Header record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Perform_Writes
( p_rtg_header_rec     IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
, p_rtg_header_unexp_rec IN  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
, x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status      IN OUT NOCOPY VARCHAR2
);

END Bom_Rtg_Header_Util;

 

/
