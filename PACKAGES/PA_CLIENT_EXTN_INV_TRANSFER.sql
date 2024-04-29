--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_INV_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_INV_TRANSFER" AUTHID CURRENT_USER AS
-- $Header: PAXPTRXS.pls 120.4 2006/07/25 06:38:55 lveerubh noship $
/*#
 * This extension is used for the AR transaction type billing.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname AR Transaction Type Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_INVOICE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : Get_AR_Trx_Type
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Oracle Projects Billing Client Extension for Determining
--                 AR Transaction Type
-- Parameters    :
-- IN              P_Project_ID          IN   NUMBER     Required
--                          Project Identifier. Corresponds to the Column
--                          PROJECT_ID of PA_PROJECTS_ALL Table
--                 P_Draft_Invoice_Num   IN   NUMBER     Required
--                          Draft Invoice Number. Corresponds to the Column
--                          DRAFT_INVOICE_NUM of PA_DRAFT_INVOICES_ALL Table
--                 P_Invoice_Class       IN   VARCHAR2   Required
--                          Class of the Invoice. Valid Values are
--                               INVOICE        - Regular Invoice
--                               CREDIT_MEMO    - Crediting Invoice
--                               WRITE_OFF      - Write-Off Invoice
--                               CANCEL         - Canceling Invoice
--                 P_Invoice_Amount      IN   VARCHAR2   Required
--                          Amount on the Draft Invoice.
--                 P_AR_Trx_Type_ID      IN    Number    Required
--                          Transaction Type ID . Corresponds to the Column
--                          CUST_TRX_TYPE_ID of RA_CUST_TRX_TYPES Table
-- OUT             X_AR_Trx_Type_ID      OUT   Number    Required
--                          Transaction Type ID . Corresponds to the Column
--                          CUST_TRX_TYPE_ID of RA_CUST_TRX_TYPES Table
--                 X_Status              OUT   Number    Required
--                          Return Status of the Procedure. Values are
--                               = 0    - Successfull Execution
--                               < 0    - Oracle Error
--                               > 0    - Application Error
--
-- End of Comments
/*----------------------------------------------------------------------------*/

/*#
 * This procedure is used to obtain the AR transaction type.
 * @param P_Project_ID The identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param P_Draft_Invoice_Num The draft invoice number
 * @rep:paraminfo {@rep:required}
 * @param P_Invoice_Class The class of the invoice
 * @rep:paraminfo {@rep:required}
 * @param P_Project_Amount Amount of the invoice in  project currency
 * @rep:paraminfo {@rep:required}
 * @param P_Project_Currency_Code The project currency code
 * @rep:paraminfo {@rep:required}
 * @param P_Inv_Currency_Code The invoice currency code
 * @rep:paraminfo {@rep:required}
 * @param P_Invoice_Amount Amount of the invoice in  invoice currency
 * @rep:paraminfo {@rep:required}
 * @param P_AR_Trx_Type_ID Identifier for the AR transaction type to be used for the invoice.
 * Oracle Projects uses the  setup tables to determine the default AR transaction type and then passes it to the template.
 * @rep:paraminfo {@rep:required}
 * @param X_AR_Trx_Type_ID Identifier of the AR transaction type determined by the extension.
 * After validation, Oracle Projects uses this transaction type to interface invoices to Oracle Receivables.
 * @rep:paraminfo {@rep:required}
 * @param X_Status  Status indicating whether an error occurred. The valid values are =0 (Success), <0 (SQL Error) OR >0 (Application Error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get AR Transaction Type
 * @rep:compatibility S
*/
Procedure Get_AR_Trx_Type ( 	P_Project_ID		IN	Number,
				P_Draft_Invoice_Num	IN	Number,
				P_Invoice_Class		IN	Varchar2,
                                P_Project_Amount        IN      Number,
                                P_Project_Currency_Code  IN      Varchar2,
                                P_Inv_Currency_Code     IN      Varchar2,
                                P_Invoice_Amount        IN      Number,
				P_AR_Trx_Type_ID	IN	Number,
				X_AR_Trx_Type_ID	OUT	NOCOPY Number,    --File.Sql.39 bug 4440895
				X_Status		OUT	NOCOPY Number ); --File.Sql.39 bug 4440895

END PA_Client_Extn_Inv_Transfer;

/
