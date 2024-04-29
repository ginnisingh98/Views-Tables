--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_CIP_ACCT_OVR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_CIP_ACCT_OVR" AUTHID CURRENT_USER AS
--$Header: PACCXCOS.pls 120.1 2006/07/25 20:42:09 skannoji noship $
/*#
 * This extension enables you to override the CIP account associated with the asset line to specify a different account for
 * posting CIP clearing amounts.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname CIP Account Override Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_CAPITAL_ASSET
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * You can use this procedure to override the CIP account associated with the asset line and specify a different account for
 * posting CIP clearing amounts. Oracle Projects calls this procedure when you submit the PRC: Generate Asset Lines Process.
 * @return Returns the override CIP account code
 * @param p_cdl_cip_ccid  The CIP account defined on the cost distribution line
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_item_id  The identifier of the expenditure item that generated the cost distribution line
 * @rep:paraminfo {@rep:required}
 * @param p_cdl_line_number Cost distribution line number
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname CIP Account Override
 * @rep:compatibility S
*/
FUNCTION CIP_ACCT_OVERRIDE(p_cdl_cip_ccid           IN      NUMBER,
                           p_expenditure_item_id    IN      NUMBER,
                           p_cdl_line_number        IN      NUMBER) RETURN NUMBER;

END;

 

/
