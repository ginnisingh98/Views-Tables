--------------------------------------------------------
--  DDL for Package EC_CDMO_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_CDMO_EXT" AUTHID CURRENT_USER AS
/* $Header: ECCDMOXS.pls 120.1 2005/06/30 11:20:10 appldev noship $      */
/*#
 * This package contains routines to populate additonal columns for
 * 812/CREADV/DEBADV Credit/Debit Memo Outbound (CDMO) flat file.
 * @rep:scope internal
 * @rep:product EC
 * @rep:lifecycle active
 * @rep:displayname Outbound Credit/Debit Memo (CDMO) Extensible Architecture
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY AR_CREDIT_MEMO
 * @rep:category BUSINESS_ENTITY AR_DEBIT_MEMO
 */
/*#
 * This procedure can be used to populate additional data
 * in   level 01.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Credit/Debit Memo (CDMO) Level 01 with Additional Columns
 * @rep:compatibility S
 */

procedure CDMO_Populate_Ext_Lev01;
/*#
 * This procedure can be used to populate additional data
 * in level 02.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Credit/Debit Memo (CDMO) Level 02 with Additional Columns
 * @rep:compatibility S
 */

procedure CDMO_Populate_Ext_Lev02;

/*#
 * This procedure can be used to populate additional data
 * in level 03.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Credit/Debit Memo (CDMO) Level 03 with Additional Columns
 * @rep:compatibility S
 */

procedure CDMO_Populate_Ext_Lev03;

/*#
 * This procedure can be used to populate additional data
 * in level 04.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Credit/Debit Memo (CDMO) Level 04 with Additional Columns
 * @rep:compatibility S
 */

procedure CDMO_Populate_Ext_Lev04;

/*#
 * This procedure can be used to populate additional data
 * in level 05.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Credit/Debit Memo (CDMO) Level 05 with Additional Columns
 * @rep:compatibility S
 */

procedure CDMO_Populate_Ext_Lev05;

/*#
 * This procedure can be used to populate additional data
 * in level 06.This procedure can be modified by the user to utilize
 * the EDI Extension Tables.
 * @rep:lifecycle active
 * @rep:displayname Populate Outbound Credit/Debit Memo (CDMO) Level 06 with Additional Columns
 * @rep:compatibility S
 */

procedure CDMO_Populate_Ext_Lev06;

end EC_CDMO_EXT;

 

/
