--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_OUTPUT_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_OUTPUT_TAX" AUTHID CURRENT_USER AS
/* $Header: PAXPOTXS.pls 120.12 2006/07/25 06:38:32 lveerubh noship $ */
/*#
 *In the Tax Defaults implementation option, you set up a hierarchy for determining default tax codes for invoice lines.
 *One of the sources the system can use to find default tax codes is the Output Tax client extension.
 *Oracle Projects uses the extension during the Generate Draft Invoices process, if it has not yet found the output tax code
 *using the Tax Defaults hierarchy. You can modify the extension to satisfy your business rules for assigning the default output
 *tax code for invoice lines.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Output Tax Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_INVOICE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
* This procedure assigns a tax code to an invoice line.
* @param P_project_id The identifier of the project
* @rep:paraminfo {@rep:required}
* @param P_customer_id The identifier of the customer
* @rep:paraminfo {@rep:required}
* @param P_bill_to_site_use_id   The identifier of the bill-to site
* @rep:paraminfo {@rep:required}
* @param P_ship_to_site_use_id The identifier of the ship-to site
* @rep:paraminfo {@rep:required}
* @param P_set_of_books_id    The identifier of the set of books associated with the project
* @rep:paraminfo {@rep:required}
* @param P_expenditure_item_id  The identifier of the expenditure item
* @rep:paraminfo {@rep:required}
* @param P_event_id  The identifier of the event
* @rep:paraminfo {@rep:required}
* @param P_line_type  The type of invoice line (event, expenditure, or retention)
* @rep:paraminfo {@rep:required}
* @param P_request_id The request identifier of the Generate Draft Invoices process
* @rep:paraminfo {@rep:required}
* @param P_user_id  The identifier of the user who ran the Generate Draft Invoices process
* @rep:paraminfo {@rep:required}
* @param X_output_tax_code   The identifier of the output tax code
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Get Tax Codes
* @rep:compatibility S
*/

      PROCEDURE get_tax_code
          (  P_project_id               IN    NUMBER,
             P_customer_id              IN    NUMBER DEFAULT NULL,
             P_bill_to_site_use_id      IN    NUMBER DEFAULT NULL,
             P_ship_to_site_use_id      IN    NUMBER DEFAULT NULL,
             P_set_of_books_id          IN    NUMBER DEFAULT NULL,
             P_expenditure_item_id      IN    NUMBER DEFAULT NULL,
             P_event_id                 IN    NUMBER DEFAULT NULL,
             P_line_type                IN    VARCHAR2  DEFAULT NULL,
             P_request_id               IN    NUMBER DEFAULT NULL,
             P_user_id                  IN    NUMBER DEFAULT NULL,
             X_output_tax_code          OUT    NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
end pa_client_extn_output_tax;

/
