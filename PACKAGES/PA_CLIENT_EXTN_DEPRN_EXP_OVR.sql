--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_DEPRN_EXP_OVR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_DEPRN_EXP_OVR" AUTHID CURRENT_USER AS
--$Header: PACCXDES.pls 120.1 2006/07/25 20:42:20 skannoji noship $
/*#
 * This extension enables you to specify logic for deriving the depreciation expense account assigned to a project asset.
 * The extension is called once for every project asset processed.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Depreciation Account Override Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_CAPITAL_ASSET
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This function contains logic for deriving the depreciation expense account assigned to a project asset.
 * The INTERFACE_ASSET_LINES procedure calls this function before it validates the complete asset information expense account.
 * @return Returns the override expense account code
 * @param p_project_asset_id The reference code that uniquely identifies the asset within a project in Oracle Projects
 * @param p_book_type_code The corporate book to which the asset is assigned
 * @rep:paraminfo {@rep:required}
 * @param p_asset_category_id The identifier of the asset category to which the asset is assigned
 * @rep:paraminfo {@rep:required}
 * @param p_date_placed_in_service Date placed in service of the asset
 * @rep:paraminfo {@rep:required}
 * @param p_deprn_expense_acct_ccid The depreciation expense account for the asset
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Depreciation Expense Account Override
 * @rep:compatibility S
*/
FUNCTION DEPRN_EXPENSE_ACCT_OVERRIDE
                           (p_project_asset_id      IN      NUMBER DEFAULT NULL,
                           p_book_type_code         IN      VARCHAR2,
                           p_asset_category_id      IN      NUMBER,
                           p_date_placed_in_service IN      DATE,
                           p_deprn_expense_acct_ccid IN     NUMBER DEFAULT NULL) RETURN NUMBER;

END;

 

/
