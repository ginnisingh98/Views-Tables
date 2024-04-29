--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_COSTING" AUTHID CURRENT_USER as
/* $Header: PAXCCECS.pls 120.3 2007/02/06 09:28:31 rshaik ship $ */
/*#
 * This is a Labor Costing Extension Package Specification template. If you create procedures within the
 * package outside the predefined procedure, you must also modify this file.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Labor Costing.
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_LABOR_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/


/*#
 * This Extension is used to Calculate Raw cost.
 * @param x_transaction_type Transaction type.
 * @rep:paraminfo {@rep:required}
 * @param x_expenditure_item_id The identifier of the expenditure item.
 * @rep:paraminfo {@rep:required}
 * @param x_sys_linkage_function  The expenditure type class of the expenditure item.
 * @rep:paraminfo {@rep:required}
 * @param x_denom_raw_cost Denomination raw cost amount.
 * @rep:paraminfo {@rep:required}
 * @param x_denom_currency_code Denomination currency code.
 * @rep:paraminfo {@rep:required}
 * @param x_status The status of the procedure.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Calculation Raw cost amounts.
 * @rep:compatibility S
*/
  procedure Calc_Raw_Cost(
                           x_transaction_type       in varchar2 default 'ACTUAL',
                           x_expenditure_item_id    in number,
                           x_sys_linkage_function   in varchar2,
			   x_denom_raw_cost	    in out NOCOPY pa_expenditure_items.raw_cost%type, --Changed for Bug#3858467
  			   x_denom_currency_code    in out NOCOPY pa_expenditure_items.denom_currency_code%type, --Added for Bug#5594124
                           x_status                 in out NOCOPY number    );

end PA_Client_Extn_Costing;

/
