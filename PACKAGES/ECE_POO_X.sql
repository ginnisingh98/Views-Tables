--------------------------------------------------------
--  DDL for Package ECE_POO_X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_POO_X" AUTHID CURRENT_USER AS
-- $Header: ECEPOOXS.pls 120.1 2005/06/30 11:22:19 appldev ship $
/*#
 * This package contains routines to populate additonal columns for the
 * 850/ORDERS Purchase Order Outbound (POO) flat file.
 * @rep:scope internal
 * @rep:product EC
 * @rep:lifecycle active
 * @rep:displayname Outbound PO (POO) Extensible Architecture
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PO_STANDARD_PURCHASE_ORDER
 */

/*#
 * This procedure can be used to populate additional data
 * in Purchasing Header level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @param  l_fkey  Transaction Record ID
 * @param  l_plsql_tbl PL/SQL Table
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound PO (POO) Header with Additional Columns
 * @rep:compatibility S
 */

   PROCEDURE populate_ext_header(
      l_fkey      IN NUMBER,
		l_plsql_tbl IN OUT NOCOPY ece_flatfile_pvt.interface_tbl_type);
/*#
 * This procedure can be used to populate additional data
 * in Purchasing Line level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @param  l_fkey  Transaction Record ID
 * @param  l_plsql_tbl PL/SQL Table
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound PO (POO) Line with Additional Columns
 * @rep:compatibility S
 */

   PROCEDURE populate_ext_line(
      l_fkey      IN NUMBER,
		l_plsql_tbl IN OUT NOCOPY ece_flatfile_pvt.interface_tbl_type);
/*#
 * This procedure can be used to populate additional data
 * in Purchasing Shipment level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @param  l_fkey  Transaction Record ID
 * @param  l_plsql_tbl PL/SQL Table
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound PO (POO) Shipment with Additional Columns
 * @rep:compatibility S
 */

   PROCEDURE populate_ext_shipment(
      l_fkey      IN NUMBER,
		l_plsql_tbl IN OUT NOCOPY ece_flatfile_pvt.interface_tbl_type);
/*#
 * This procedure can be used to populate additional data
 * in Purchasing Distribution level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @param  l_fkey  Transaction Record ID
 * @param  l_plsql_tbl PL/SQL Table
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound PO (POO) Distribution with Additional Columns
 * @rep:compatibility S
 */

   PROCEDURE populate_ext_project(
      l_fkey      IN NUMBER,
		l_plsql_tbl IN OUT NOCOPY ece_flatfile_pvt.interface_tbl_type);

END ece_poo_x;


 

/
