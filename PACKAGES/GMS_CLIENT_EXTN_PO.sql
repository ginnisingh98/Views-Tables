--------------------------------------------------------
--  DDL for Package GMS_CLIENT_EXTN_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_CLIENT_EXTN_PO" AUTHID CURRENT_USER AS
/* $Header: gmspoces.pls 120.3 2006/07/28 08:10:38 lveerubh noship $ */
/*#
 * This extension is used when you want to support internal requisitions.
 * @rep:scope public
 * @rep:product GMS
 * @rep:lifecycle active
 * @rep:displayname Allow Internal Requisitions
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMS_AWARD
 * @rep:doccd 120gmsug.pdf See the Oracle Oracle Grants Accounting User's Guide
*/
/*#
 * This procedure is used to allow internal requisitions. You need to return the value 'Y' for allowing
 * internal requisitions.
 * @return Returns whether internal requisitions are allowed
 * @rep:paraminfo  {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Allow Internal Requisitions
 * @rep:compatibility S
*/

  function allow_internal_req return varchar2  ;

END gms_client_extn_po;

 

/
