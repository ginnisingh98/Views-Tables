--------------------------------------------------------
--  DDL for Package ECE_INO_X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_INO_X" AUTHID CURRENT_USER AS
-- $Header: ECEINOXS.pls 120.1 2005/06/30 11:21:28 appldev ship $
/*#
 * This package contains routines to populate additonal columns for
 * 810/Invoic  Invoice Outbound (INO) flat file.
 * @rep:scope internal
 * @rep:product EC
 * @rep:lifecycle active
 * @rep:displayname Outbound Invoice (INO) Extensible Architecture
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY AR_INVOICE
 */
/*#
 * This procedure can be used to populate additional data
 * in  Header level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @param  l_fkey  Transaction Record ID
 * @param  l_plsql_tbl PL/SQL Table
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Invoice (INO) Header with Additional Columns
 * @rep:compatibility S
 */

Procedure populate_extension_header(l_fkey  	IN NUMBER,
				   l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type);
/*#
 * This procedure can be used to populate additional data
 * in  Header 1 level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @param  l_fkey  Transaction record ID
 * @param  l_plsql_tbl PL/SQL Table
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Invoice (INO) Header1 with Additional Columns
 * @rep:compatibility S
 */

Procedure populate_extension_header_1(l_fkey        IN NUMBER,
                                   l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type);
/*#
 * This procedure can be used to populate additional data
 * in  Line level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @param  l_fkey  Transaction Record ID
 * @param  l_plsql_tbl PL/SQL Table
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Invoice (INO) Line with Additional Columns
 * @rep:compatibility S
 */

Procedure populate_extension_line(l_fkey  	IN NUMBER,
				   l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type);
/*#
 * This procedure can be used to populate additional data
 * in  Line Tax level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @param  l_fkey  Transaction Record ID
 * @param  l_plsql_tbl PL/SQL Table
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Invoice (INO) Line Tax with Additional Columns
 * @rep:compatibility S
 */

Procedure populate_extension_line_tax(l_fkey  	IN NUMBER,
				   l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type);


end ECE_INO_X;

 

/
