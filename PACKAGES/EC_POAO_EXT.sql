--------------------------------------------------------
--  DDL for Package EC_POAO_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_POAO_EXT" AUTHID CURRENT_USER AS
/* $Header: OEPOAOXS.pls 120.0.12010000.1 2009/08/28 01:02:57 smusanna noship $      */
/*#
* This is a stub API provided as part of the Extensible Architecture feature of the Oracle e-Commerce Gateway and can be used to populate extension columns in the Purchase Order Acknowledgments EDI transaction.
* @rep:scope public
* @rep:metalink 73442.1 EDI White Papers
* @rep:product ONT
* @rep:lifecycle active
* @rep:displayname Purchase Order Acknowledgments Extension Columns API
* @rep:category BUSINESS_ENTITY ONT_SALES_ORDER
*/

/*#
* Use this procedure to populate extension columns at Data Level 1 in the Purchase Order Acknowledgments EDI transaction.  Code should be added in this procedure to move external source data to the desired extension columns.
* @rep:scope public
* @rep:metalink 73442.1 EDI White Papers
* @rep:lifecycle active
* @rep:displayname Populate Purchase Order Acknowledgments Extension Level 1
* @rep:category BUSINESS_ENTITY ONT_SALES_ORDER
*/
procedure POAO_Populate_Ext_Lev01;

/*#
* Use this procedure to populate extension columns at Data Level 2 in the Purchase Order Acknowledgments EDI transaction.  Code should be added in this procedure to move external source data to the desired extension columns.
* @rep:scope public
* @rep:metalink 73442.1 EDI White Papers
* @rep:lifecycle active
* @rep:displayname Populate Purchase Order Acknowledgments Extension Level 2
* @rep:category BUSINESS_ENTITY ONT_SALES_ORDER
*/
procedure POAO_Populate_Ext_Lev02;
end EC_POAO_EXT;

/
