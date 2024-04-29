--------------------------------------------------------
--  DDL for Package EC_PYO_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_PYO_EXT" AUTHID CURRENT_USER AS
-- $Header: ECEPYOXS.pls 120.2 2006/07/26 10:38:10 arsriniv ship $
 /*#
 * This package contains routines to populate additonal columns for
 * 820/PAYORD  Payment Advice/Remittance Outbound (PYO) flat file.
 * @rep:scope internal
 * @rep:product EC
 * @rep:lifecycle active
 * @rep:displayname Outbound Payment/Remittance Advice (PYO) Extensible Architecture
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY AP_PAYMENT
 */

/*#
 * This procedure can be used to populate additional data
 * in  Payment level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Payment/Remittance Advice(PYO) Payment with Additional Columns
 * @rep:compatibility S
 */

Procedure  pyo_populate_ext_lev01;
/*#
 * This procedure can be used to populate additional data
 * in  Invoice level.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Payment/Remittance Advice(PYO) Invoice with Additional Columns
 * @rep:compatibility S
 */

Procedure  pyo_populate_ext_lev02;

end EC_PYO_EXT;

 

/
