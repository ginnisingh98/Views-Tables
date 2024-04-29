--------------------------------------------------------
--  DDL for Package PA_NON_LABOR_BILL_CLT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_NON_LABOR_BILL_CLT_EXTN" AUTHID CURRENT_USER as
/* $Header: PAXINCTS.pls 120.4 2006/07/25 06:37:51 lveerubh noship $ */
/*#
 * This extension contains a function to calculate bill amounts for individual non-labor transactions.Some examples of non-labor billing extensions are : tiered pricing method, external system rate derivation .
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Non-Labor Billing Extensions
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_REVENUE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
/*#
 * This procedure calculates the bill amount.
 * @param X_TRANSACTION_TYPE Identifier of the transaction type.The default value is ACTUAL
 * @rep:paraminfo {@rep:required}
 * @param X_EXPENDITURE_ITEM_ID Identifier of the expenditure item.
 * @rep:paraminfo {@rep:required}
 * @param X_SYS_LINKAGE_FUNCTION The expenditure type class
 * @rep:paraminfo {@rep:required}
 * @param X_AMOUNT The bill amount
 * @rep:paraminfo {@rep:required}
 * @param X_EXPENDITURE_TYPE The expenditure type
 * @rep:paraminfo {@rep:required}
 * @param X_NON_LABOR_RESOURCE Identifier of the non-labor resource
 * @rep:paraminfo {@rep:required}
 * @param X_NON_LABOR_RES_ORG Identifier of the non-labor resource organization
 * @rep:paraminfo {@rep:required}
 * @param X_BILL_RATE_FLAG Flag indicating if the bill rate should be used
 * @rep:paraminfo {@rep:required}
 * @param X_STATUS The status of the procedure
 * @rep:paraminfo {@rep:required}
 * @param X_BILL_TRANS_CURRENCY_CODE The transaction currency used for calculation
 * @rep:paraminfo {@rep:required}
 * @param X_BILL_TXN_BILL_RATE The rate used for calculating the bill amount
 * @rep:paraminfo {@rep:required}
 * @param X_MARKUP_PERCENTAGE The markup percentage used for calculating the bill amount
 * @rep:paraminfo {@rep:required}
 * @param X_RATE_SOURCE_ID Identifier of the source of bill rate or markup
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Calculate Bill Amount
 * @rep:compatibility S
*/
  PROCEDURE Calc_Bill_Amount
                     (
                       x_transaction_type       in varchar2 default 'ACTUAL',
                       x_expenditure_item_id   IN      NUMBER,
                       x_sys_linkage_function  IN      VARCHAR2,
                       x_amount                IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_expenditure_type      IN      VARCHAR2,
                       x_non_labor_resource    IN      VARCHAR2,
                       x_non_labor_res_org     IN      NUMBER,
                       x_bill_rate_flag        IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       x_status                IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_bill_trans_currency_code      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       x_bill_txn_bill_rate    OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_markup_percentage     OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_rate_source_id        OUT     NOCOPY NUMBER); --File.Sql.39 bug 4440895


end PA_NON_LABOR_BILL_CLT_EXTN;

/
