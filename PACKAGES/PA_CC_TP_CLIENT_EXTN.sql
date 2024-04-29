--------------------------------------------------------
--  DDL for Package PA_CC_TP_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_TP_CLIENT_EXTN" AUTHID CURRENT_USER AS
/*  $Header: PAPTPRCS.pls 120.4 2006/07/25 06:35:27 lveerubh noship $  */
/*#
 * The extension determine_transfer_price specifies a transfer price for the transaction being processed.
 * If this extension returns a valid value for the transfer price, Oracle Projects uses that value as the transfer
 * price instead of computing the transfer price. The Distribute Borrowed and Lent Amounts and the Generate
 * Intercompany Invoice processes call this extension, before calling the standard transfer price determination routine.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Transfer Price Override Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_IC_TRANSACTION
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
-------------------------------------------------------------------------------
  -- Pre-client extension
/*#
 * This extension specifies a transfer price for the transaction being processed.
 * If this extension returns a valid value for the transfer price,
 * Oracle Projects uses that value as the transfer
 * price instead of computing the transfer price.
 * @param p_transaction_type Transaction type
 * @rep:paraminfo {@rep:required}
 * @param p_prvdr_org_id Identifier of the provider operating unit
 * @rep:paraminfo {@rep:required}
 * @param p_prvdr_organization_id Identifier of the provider organization
 * @rep:paraminfo {@rep:required}
 * @param p_recvr_org_id  Identifier of the receiver operating unit
 * @rep:paraminfo {@rep:required}
 * @param p_recvr_organization_id Identifier of the receiver organization
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_organization_id Idnetifier of the expenditure organization
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_item_id   Identifier of the expenditure item
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_item_type Expenditure type
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_type_class Expenditure type class
 * @rep:paraminfo {@rep:required}
 * @param p_task_id Identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param p_project_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_quantity Number of units of work performed
 * @rep:paraminfo {@rep:required}
 * @param p_incurred_by_person_id Identifier of the person who incurred the expenditure
 * @rep:paraminfo {@rep:required}
 * @param x_denom_tp_curr_code Transaction currency code in which transfer price is calculated
 * @rep:paraminfo {@rep:required}
 * @param x_denom_transfer_price Transfer price amount in transaction currency
 * @rep:paraminfo {@rep:required}
 * @param x_tp_bill_rate Bill rate applied to calculate the transfer price
 * @rep:paraminfo {@rep:required}
 * @param x_tp_bill_markup_percentage Percentage used to derive the transfer
 * price if the transfer price was based on a markup
 * @rep:paraminfo {@rep:required}
 * @param x_error_message Error message text
 * @rep:paraminfo {@rep:required}
 * @param x_status  Status indicating whether an error
 * occurred. Valid values are:=0 Success, <0 Oracle Error
 * >0 Application Error.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Determine Transfer Price
 * @rep:compatibility S
 */

PROCEDURE Determine_Transfer_Price(
        p_transaction_type		IN	Varchar2 DEFAULT 'ACTUAL', /** Added for Org Forecasting **/
        p_prvdr_org_id                  IN      Number,
 	p_prvdr_organization_id		IN      Number,
        p_recvr_org_id                  IN      Number,
        p_recvr_organization_id         IN      Number,
        p_expnd_organization_id         IN      Number,
        p_expenditure_item_id           IN      Number,
        p_expenditure_item_type         IN      Varchar2,
        p_expenditure_type_class        IN      Varchar2,
	p_task_id                       IN      Number,
	p_project_id                    IN      Number,
	p_quantity                      IN      Number,
	p_incurred_by_person_id         IN      Number,
	x_denom_tp_curr_code            OUT     NOCOPY Varchar2, --File.Sql.39 bug 4440895
	x_denom_transfer_price          OUT     NOCOPY Number, --File.Sql.39 bug 4440895
	x_tp_bill_rate                  OUT     NOCOPY Number, --File.Sql.39 bug 4440895
	x_tp_bill_markup_percentage     OUT     NOCOPY Number, --File.Sql.39 bug 4440895
	x_error_message                 OUT     NOCOPY Varchar2, --File.Sql.39 bug 4440895
	x_status                        OUT     NOCOPY NUMBER	 --File.Sql.39 bug 4440895
        );

--------------------------------------------------------------------------------
-- Post-client extension
/*#
 * This API is used to override the transfer price for a transaction.
 * @param p_transaction_type Transaction type
 * @rep:paraminfo {@rep:required}
 * @param p_prvdr_org_id Identifier of the provider operating unit
 * @rep:paraminfo {@rep:required}
 * @param p_prvdr_organization_id Identifier of the provider organization
 * @rep:paraminfo {@rep:required}
 * @param p_recvr_org_id  Idnetifier of the receiver organization
 * @rep:paraminfo {@rep:required}
 * @param p_recvr_organization_id Identifier of the receiver organization
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_organization_id Identifier of the expenditure organization
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_item_id   Identifier of the expenditure item
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_item_type Expenditure item type
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_type_class Expenditure type class
 * @rep:paraminfo {@rep:required}
 * @param p_task_id Identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param p_project_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_quantity Number of units of work performed
 * @rep:paraminfo {@rep:required}
 * @param p_incurred_by_person_id  Identifier of the person who incurred the expenditure
 * @rep:paraminfo {@rep:required}
 * @param p_base_curr_code Transaction currency code of the base
 * @rep:paraminfo {@rep:required}
 * @param p_base_amount Base amount used to derive the
 * transfer price. It could be either a raw cost, burdened cost, or raw revenue in
 * the transaction currencies
 * @rep:paraminfo {@rep:required}
 * @param p_denom_tp_curr_code Transaction currency code in which
 * transfer price is calculated
 * @rep:paraminfo {@rep:required}
 * @param p_denom_transfer_price Transfer price amount as calculated in
 * the transaction currency
 * @rep:paraminfo {@rep:required}
 * @param x_denom_tp_curr_code Transaction currency code in which transfer price is calculated
 * @rep:paraminfo {@rep:required}
 * @param x_denom_transfer_price Transfer price as calculated in the
 * transaction currency
 * @rep:paraminfo {@rep:required}
 * @param x_tp_bill_rate Bill rate applied to calculate the transfer price
 * @rep:paraminfo {@rep:required}
 * @param x_tp_bill_markup_percentage Percentage used to derive the transfer
 * price if the transfer price was based on a markup
 * @rep:paraminfo {@rep:required}
 * @param x_error_message    Error message text
 * @rep:paraminfo {@rep:required}
 * @param x_status  Status indicating whether an error
 * occurred. Valid values are:=0 Success, <0 Oracle Error
 * >0 Application Error.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Override Transfer Price
 * @rep:compatibility S
*/

PROCEDURE Override_Transfer_Price(
        p_transaction_type		IN	Varchar2 DEFAULT 'ACTUAL', /** Added for Org Forecasting **/
        p_prvdr_org_id                  IN      Number,
 	p_prvdr_organization_id		IN      Number,
        p_recvr_org_id                  IN      Number,
        p_recvr_organization_id         IN      Number,
        p_expnd_organization_id         IN      Number,
        p_expenditure_item_id           IN      Number,
        p_expenditure_item_type         IN      Varchar2,
        p_expenditure_type_class        IN      Varchar2,
	p_task_id                       IN      Number,
	p_project_id                    IN      Number,
	p_quantity                      IN      Number,
	p_incurred_by_person_id         IN      Number,
	p_base_curr_code                IN      Varchar2,
	p_base_amount                   IN      Number,
	p_denom_tp_curr_code            IN      Varchar2,
	p_denom_transfer_price          IN      Number,
	x_denom_tp_curr_code            OUT     NOCOPY Varchar2, --File.Sql.39 bug 4440895
	x_denom_transfer_price          OUT     NOCOPY Number, --File.Sql.39 bug 4440895
	x_tp_bill_rate                  OUT     NOCOPY Number, --File.Sql.39 bug 4440895
	x_tp_bill_markup_percentage     OUT     NOCOPY Number, --File.Sql.39 bug 4440895
	x_error_message                 OUT     NOCOPY Varchar2, --File.Sql.39 bug 4440895
	x_status                        OUT     NOCOPY NUMBER	 --File.Sql.39 bug 4440895
        );

--------------------------------------------------------------------------------

END PA_CC_TP_CLIENT_EXTN;

/
