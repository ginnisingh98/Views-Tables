--------------------------------------------------------
--  DDL for Package ECE_SPSO_X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_SPSO_X" AUTHID CURRENT_USER AS
-- $Header: ECSPSOXS.pls 120.1 2005/06/30 11:24:18 appldev ship $
/*#
 * This package contains routines to populate additonal columns for
 * 830/DELFOR planning schedule and 832/DELJIT shipping schedule flat files.
 * @rep:scope internal
 * @rep:product EC
 * @rep:lifecycle active
 * @rep:displayname Outbound Planning/Shipping Schedule (SPSO/SSSO) Extensible Architecture
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CHV_PLANNING_SCHEDULE
 * @rep:category BUSINESS_ENTITY CHV_SHIPPING_SCHEDULE
 */
/*#
 * This procedure can be used to populate additional data
 * in  Header level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @param  l_fkey  Transaction Record ID
 * @param  l_plsql_tbl PL/SQL Table
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Shipping/Planning Schedule Header with Additional Columns
 * @rep:compatibility S
 */

Procedure populate_extension_headers(l_fkey  	IN NUMBER,
				   l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type);
/*#
 * This procedure can be used to populate additional data
 * in  Item level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @param  l_fkey  Transaction Record ID
 * @param  l_plsql_tbl PL/SQL Table
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Shipping/Planning Schedule Item with Additional Columns
 * @rep:compatibility S
 */

Procedure populate_extension_items(l_fkey  	IN NUMBER,
				   l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type);

/* Bug 1742567
Modified the procedure populate_extension_item_det
to receive correct parameters
*/

/*Procedure populate_extension_item_det(l_fkey  	IN NUMBER,
				   l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type);*/
/*#
 * This procedure can be used to populate additional data
 * in  Item Detail level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @param  transaction_id Transaction ID
 * @param  schedule_id Schedule Id
 * @param schedule_item_id Schedule Item Id
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Shipping/Planning Schedule Item Detail with Additional Columns
 * @rep:compatibility S
 */

Procedure populate_extension_item_det(transaction_id    IN NUMBER,
                                   schedule_id IN NUMBER,
                                   schedule_item_id IN NUMBER);
/*#
 * This procedure can be used to populate additional data
 * in  Shipment Detail level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @param  transaction_id Transaction ID
 * @param  schedule_id Schedule Id
 * @param  schedule_item_id Schedule Item Id
 * @param   schedule_item_detail_sequence Schedule Item Detail Sequence
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Shipping/Planning Schedule Shipment with Additional Columns
 * @rep:compatibility S
 */

Procedure populate_extension_ship_det(transaction_id    IN NUMBER,
                                   schedule_id IN NUMBER,
                                   schedule_item_id IN NUMBER,
                                   schedule_item_detail_sequence IN NUMBER);

end ECE_SPSO_X;

 

/
