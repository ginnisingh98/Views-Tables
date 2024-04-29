--------------------------------------------------------
--  DDL for Package BOM_RTG_REVISION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_REVISION_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMURRVS.pls 120.1 2006/01/03 22:24:39 bbpatel noship $ */
/*#
 * This API contains Routing Revision entity utility procedure. Utility procedures
 * include query and perform writes (insert/update/delete) for a row.
 *
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Routing Revision Utitlity package
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
--      BOMURRVS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Rtg_Revision_UTIL
--
--  NOTES
--
--  HISTORY
--  07-AUG-2000 Rahul Chitko    Initial Creation
--
****************************************************************************/
/*#
 * Procedure to query a database record and return the populated Exposed and Unexposed
 * Routing Revision record.
 *
 * @param p_assembly_item_id IN Assembly Item Id
 * @param p_organization_id IN Organization Id in which item is defined
 * @param p_revision IN Routing Revision
 * @param x_rtg_revision_rec IN OUT NOCOPY Populated Routing Revision Exposed Record from queried row
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
 * @param x_rtg_Rev_Unexp_rec IN OUT NOCOPY Populated Routing Revision Unexposed Record from queried row
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
 * @param x_return_status IN OUT NOCOPY Return Status, Record Found or not Found
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Query a row for Routing Revision record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Query_Row
( p_assembly_item_id    IN  NUMBER
, p_organization_id     IN  NUMBER
, p_revision            IN  VARCHAR2
, x_rtg_revision_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rtg_revision_Rec_Type
, x_rtg_rev_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rtg_rev_unexposed_Rec_Type
, x_Return_status       IN OUT NOCOPY VARCHAR2
);

/*#
 * Procedure to insert/update/delete a database record using Exposed and Unexposed
 * Routing Revision record depending on Transaction Type.
 *
 * @param p_rtg_revision_rec IN Routing Revision Exposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Revision_Rec_Type }
 * @param p_rtg_Rev_Unexp_rec  IN Routing Revision Unexposed Record
 * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type}
 * @param x_mesg_token_Tbl IN OUT NOCOPY Message Token Table
 * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
 * @param x_return_status IN OUT NOCOPY Return Status
 *
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Insert/Update/Delete a row for Routing Revision record
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
PROCEDURE Perform_Writes ( p_rtg_revision_rec     IN  Bom_Rtg_Pub.Rtg_revision_Rec_Type
, p_rtg_rev_unexp_rec IN  Bom_Rtg_Pub.Rtg_rev_Unexposed_Rec_Type
, x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status      IN OUT NOCOPY VARCHAR2
);


END BOM_Rtg_Revision_UTIL;

 

/
