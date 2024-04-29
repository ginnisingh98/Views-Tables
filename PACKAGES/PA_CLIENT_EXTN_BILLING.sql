--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_BILLING" AUTHID CURRENT_USER as
/* $Header: PAXICTMS.pls 120.5 2006/07/25 06:37:30 lveerubh ship $ */
/*#
 * This package is used as the basis of the labor billing extension procedures.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname   Labor Billing Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_REVENUE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
* This extension is used to calculate the bill amount.
* @param x_transaction_type Transaction type
* @rep:paraminfo {@rep:required}
* @param x_expenditure_item_id The identifier of the expenditure item
* @rep:paraminfo {@rep:required}
* @param x_sys_linkage_function  The expenditure type class of the expenditure item
* @rep:paraminfo {@rep:required}
* @param x_amount  The bill amount
* @rep:paraminfo {@rep:required}
* @param x_bill_rate_flag  Flag indicating if bill rate should be set
* @rep:paraminfo {@rep:required}
* @param x_status  The status of the procedure
* @rep:paraminfo {@rep:required}
* @param x_bill_trans_currency_code Identifier of the billing transaction currency for an expenditure
* item. If the value is null, then the project functional currency is used.
* @rep:paraminfo {@rep:required}
* @param x_bill_txn_bill_rate Bill rate in the billing transaction currency
* @rep:paraminfo {@rep:required}
* @param x_markup_percentage Markup percentage if markup is used to derive the bill amount
* @rep:paraminfo {@rep:required}
* @param x_rate_source_id Identifies the source from which the bill rate was derived. This
* is for audit purposes only.
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Calculate Bill Amount.
* @rep:compatibility S
*/

  procedure Calc_Bill_Amount(

                              x_transaction_type           in varchar2 default 'ACTUAL',
                              x_expenditure_item_id        in number,
                              x_sys_linkage_function       in varchar2,
                              x_amount                     in out NOCOPY number,
                              x_bill_rate_flag             in out NOCOPY varchar2,
                              x_status                     in out NOCOPY number,
                              x_bill_trans_currency_code   out NOCOPY   varchar2,
                              x_bill_txn_bill_rate         out NOCOPY   number,
                              x_markup_percentage          out NOCOPY   number,
                              x_rate_source_id             out NOCOPY   number);

end PA_Client_Extn_Billing;

/
