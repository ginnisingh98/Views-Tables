--------------------------------------------------------
--  DDL for Package PA_CC_AP_INV_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_AP_INV_CLIENT_EXTN" AUTHID CURRENT_USER AS
--  $Header: PACCINPS.pls 120.6 2006/07/25 06:33:50 lveerubh noship $
/*#
 * When using Intercompany or Inter Project Billing, you must define organization controls using the Provider/Receiver Controls window.
 * For each Provider and Receiver pair, you select the expenditure type and expenditure organization to use when creating the internal
 * payables invoices. In order to further classify cost based on additional transaction information, you can use this client extension to override
 * the payables invoice attributes.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Internal Payables Invoice Attributes Override Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_IC_TRANSACTION
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * When using Intercompany or Inter Project Billing, you must define organization controls using the Provider/Receiver Controls window.
 * For each Provider and Receiver pair, you select the expenditure type and expenditure organization to use when creating the internal
 * payables invoices. In order to further classify cost based on additional transaction information, you can use this client extension to override
 * the payables invoice attributes.
 * @param  p_internal_billing_type  Determines if the internal payables invoice is created
 * for intercompany billing invoice or inter project billing
 * invoice. The valid values are:PA_IC_INVOICES (intercompany billing invoice) or
 * PA_IP_INVOICES(inter project billing invoice).
 * @rep:paraminfo {@rep:required}
 * @param p_project_id  Identifier of the provider
 * project of an Inter project billing invoice, or the intercompany billing project for an intercompany billing
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_receiver_project_id  Identifier of the receiver project
 * @rep:paraminfo {@rep:required}
 * @param p_receiver_task_id Identifier of the receiver task for an inter project
 * billing invoice, or the task defined as the intercompany non recoverable tax
 * receiving task for an intercompany billing invoice
 * @rep:paraminfo {@rep:required}
 * @param p_draft_invoice_number Number of the corresponding
 * intercompany invoice for which the internal payables invoice is created
 * @rep:paraminfo {@rep:required}
 * @param p_draft_invoice_line_num  Line number of the corresponding intercompany invoice line for which the
 * internal payables invoice line is created
 * @rep:paraminfo {@rep:required}
 * @param p_invoice_date  Internal payables invoice date
 * @rep:paraminfo {@rep:required}
 * @param p_ra_invoice_number Number of the internal Payables invoice
 * @rep:paraminfo {@rep:required}
 * @param p_provider_org_id Identifier of the provider operating unit
 * @rep:paraminfo {@rep:required}
 * @param p_receiver_org_id Identifier of the receiver operating unit
 * @rep:paraminfo {@rep:required}
 * @param p_cc_ar_invoice_id Identifier of the corresponding invoice created in receivables for the inter company invoice
 * @rep:paraminfo {@rep:required}
 * @param p_cc_ar_invoice_line_num Line number of the corresponding invoice line created in receivables for the intercompany invoice
 * @rep:paraminfo {@rep:required}
 * @param p_project_customer_id Identifier of the provider project customer for an inter project billing invoice
 * or the intercompany billing project customer for an intercompany billing invoice
 * @rep:paraminfo {@rep:required}
 * @param p_vendor_id  Identifier of the supplier of the provider operating unit,based on the user setup for the provider
 * operating unit,in the Receiver controls tab for the Provider/Receiver controls window
 * @rep:paraminfo {@rep:required}
 * @param p_vendor_site_id Identifier of the supplier site of the provider operating unit,based on the user setup for the
 * provider operating unit in the receiver controls tab of the Provider/Receiver Control window
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_type Expenditure type for internal invoice distribution lines(Receiver Controls tab of the Provider/Receiver Controls window)
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_organization_id Identifier of the expenditure organization for internal invoice distribution lines(Receiver Controls tab of the
 * Provider/Receiver Controls window)
 * @rep:paraminfo {@rep:required}
 * @param x_expenditure_type Expenditure type for the
 * internal invoice distribution lines(determined by the client extension)
 * @rep:paraminfo {@rep:required}
 * @param x_expenditure_organization_id Identifier of the expenditure organization
 * for the internal invoice distribution lines(determined by the client extension)
 * @rep:paraminfo {@rep:required}
 * @param x_status  Status indicating whether an error
 * occurred. Valid values are:=0 Success, <0 Oracle Error
 * >0 Application Error
 * @rep:paraminfo {@rep:required}
 * @param x_Error_Stage Error handling stage
 * @rep:paraminfo {@rep:required}
 * @param X_Error_Code Error handling code
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Internal Payables Invoice Attributes Override Extension
 * @rep:compatibility S
*/


PROCEDURE override_exp_type_exp_org (
          p_internal_billing_type         IN  VARCHAR2,
          p_project_id                    IN   NUMBER,
          p_receiver_project_id           IN  NUMBER,
          p_receiver_task_id              IN  NUMBER,
          p_draft_invoice_number          IN  NUMBER,
          p_draft_invoice_line_num        IN  NUMBER,
          p_invoice_date                  IN  DATE,
          p_ra_invoice_number             IN  VARCHAR,
          p_provider_org_id               IN  NUMBER,
          p_receiver_org_id               IN  NUMBER,
          p_cc_ar_invoice_id              IN  NUMBER,
          p_cc_ar_invoice_line_num        IN  NUMBER,
          p_project_customer_id           IN  NUMBER,
          p_vendor_id                     IN  NUMBER,
          p_vendor_site_id                IN  NUMBER,
          p_expenditure_type              IN  VARCHAR2,
          p_expenditure_organization_id   IN  NUMBER,
          x_expenditure_type              OUT NOCOPY VARCHAR2,
          x_expenditure_organization_id   OUT NOCOPY NUMBER,
          x_status                        IN OUT NOCOPY NUMBER,
          x_Error_Stage                   IN OUT NOCOPY VARCHAR2,
          X_Error_Code                    IN OUT NOCOPY NUMBER);


END PA_CC_AP_INV_CLIENT_EXTN;

/
