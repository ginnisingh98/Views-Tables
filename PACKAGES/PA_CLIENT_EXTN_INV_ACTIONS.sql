--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_INV_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_INV_ACTIONS" AUTHID CURRENT_USER as
/* $Header: PAXPIACS.pls 120.5 2006/07/25 06:38:10 lveerubh noship $ */
/*#
 * This extension contains procedures that you can use as the basis for automatic invoice approve
 * or release extension procedures.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Automatic Invoice Approve/Release Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_INVOICE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : Approve_Invoice
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Oracle Projects Billing Client Extension for Approval of
--                 Draft Invoice.
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
--                 P_Project_Amount      IN   Number   Required
--                          Amount on the Draft Invoice in project currency.
--                 P_Project_Currency_Code   IN   Varchar2   Required
--                          project currency code on the draft invoice.
--                 P_Inv_Currency_Code   IN   Varchar2   Required
--                          invoice currency code on the draft invoice.
--                 P_Invoice_Amount      IN   Number   Required
--                          Amount on the Draft Invoice in invoice currency.
-- OUT             X_Approve_Flag        OUT   VARCHAR2  Optional
--                          Invoice Approval Flag. Valid values are
--                            Y             -  Approve Invoice
--                            Other Values  -  Do not Approve Invoice
--                 X_Status              OUT   VARCHAR2  Optional
--                          Return Status of the Procedure. Values are
--                               = 0    - Successfull Execution
--                               < 0    - Oracle Error
--                               > 0    - Application Error
--
-- End of Comments
/*----------------------------------------------------------------------------*/
/*#
 * This procedure is used to approve the invoice extensions.
 * @param P_Project_ID The identifier of the project to which the draft invoice number is attached
 * @rep:paraminfo {@rep:required}
 * @param P_Draft_Invoice_Num The draft invoice number
 * @rep:paraminfo {@rep:required}
 * @param P_Invoice_Class The class of the invoice
 * @rep:paraminfo {@rep:required}
 * @param P_Project_Amount Amount of the invoice in project currency
 * @rep:paraminfo {@rep:required}
 * @param P_Project_Currency_Code The project currency code
 * @rep:paraminfo {@rep:required}
 * @param P_Inv_Currency_Code The invoice currency code
 * @rep:paraminfo {@rep:required}
 * @param P_Invoice_Amount Amount of the invoice in invoice currency
 * @rep:paraminfo {@rep:required}
 * @param X_Approve_Flag Flag indicating the invoice approval. The valid values are: Y = Yes (approve invoice), Any other value = do not approve
 * @rep:paraminfo {@rep:required}
 * @param X_Status Status indicating whether an error occurred. The valid values are =0 (Success), <0 (SQL Error) OR >0 (Application Error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Approve Invoice
 * @rep:compatibility S
*/
  Procedure Approve_Invoice ( P_Project_ID         in  number,
                              P_Draft_Invoice_Num  in  number,
                              P_Invoice_Class      in  varchar2,
                              P_Project_Amount     in  number,
                              P_Project_Currency_Code in  varchar2,
                              P_Inv_Currency_Code  in  varchar2,
                              P_Invoice_Amount     in  number,
                              X_Approve_Flag       out NOCOPY varchar2, --File.Sql.39 bug 4440895
                              X_Status             out NOCOPY number    ); --File.Sql.39 bug 4440895



/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : Release_Invoice
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Oracle Projects Billing Client Extension for Release of
--                 Draft Invoice.
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
--                 P_Project_Amount      IN   Number   Required
--                          Amount on the Draft Invoice in project currency.
--                 P_Project_Currency_Code   IN   Varchar2   Required
--                          project currency code on the draft invoice.
--                 P_Inv_Currency_Code   IN   Varchar2   Required
--                          invoice currency code on the draft invoice.
--                 P_Invoice_Amount      IN   Number   Required
--                          Amount on the Draft Invoice in invoice currency.
-- OUT             X_Release_Flag        OUT   VARCHAR2  Optional
--                          Invoice Release Flag. Valid values are
--                            Y             -  Release Invoice
--                            Other Values  -  Do not Release Invoice
--                 X_RA_Invoice_Date     IN   DATE       Required
--                          AR's INvoice Date. Corresponds to the Column
--                          RA_INVOICE_DATE of PA_DRAFT_INVOICES_ALL Table
--                 X_RA_Invoice_Num      IN   VARCHAR2   Optional
--                          AR's Invoice Num. Corresponds to the Column
--                          RA_INVOICE_NUM of PA_DRAFT_INVOICES_ALL Table
--                 X_Status              OUT   VARCHAR2  Optional
--                          Return Status of the Procedure. Values are
--                               = 0    - Successfull Execution
--                               < 0    - Oracle Error
--                               > 0    - Application Error
--                 X_Credit_Memo_Reason_Code      OUT   VARCHAR2   Optional
--                          x_Credit_Memo_Reason_Code. Corresponds to the Column
--                          Credit_Memo_Reason_Code of PA_DRAFT_INVOICES_ALL Table
--
-- End of Comments
/*----------------------------------------------------------------------------*/
/*#
 * This procedure is used to release the invoice extensions.
 * @param P_Project_ID The identifier of the project to which the draft invoice number is attached
 * @rep:paraminfo {@rep:required}
 * @param P_Draft_Invoice_Num The draft invoice number
 * @rep:paraminfo {@rep:required}
 * @param P_Invoice_Class The class of the invoice.
 * @rep:paraminfo {@rep:required}
 * @param P_Project_Amount Amount of the invoice in project currency
 * @rep:paraminfo {@rep:required}
 * @param P_Project_Currency_Code The project currency code
 * @rep:paraminfo {@rep:required}
 * @param P_Inv_Currency_Code The invoice currency code
 * @rep:paraminfo {@rep:required}
 * @param P_Invoice_Amount Amount of the invoice in invoice currency.
 * @rep:paraminfo {@rep:required}
 * @param X_Release_Flag Flag indicating the invoice release status. The valid values are: Y = Yes (release invoice), Any other value = do not release
 * @rep:paraminfo {@rep:required}
 * @param X_RA_Invoice_Date The receivable invoice date. This parameter is validated only when the X_RELEASE_FLAG = Y
 * @rep:paraminfo {@rep:required}
 * @param X_RA_Invoice_Num The receivable invoice number. If the automatic invoice
 * numbering is active, then this parameter is not required. This parameter is validated only when the X_RELEASE_FLAG = Y
 * @rep:paraminfo {@rep:required}
 * @param X_Status Status indicating whether an error occurred. The valid values are =0 (Success), <0 (SQL Error) OR >0 (Application Error)
 * @rep:paraminfo {@rep:required}
 * @param X_Credit_Memo_Reason_Code The credit memo reason
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Release Invoice
 * @rep:compatibility S
*/
  Procedure Release_Invoice ( P_Project_ID              in  number,
                              P_Draft_Invoice_Num       in  number,
                              P_Invoice_Class           in  varchar2,
                              P_Project_Amount          in  number,
                              P_Project_Currency_Code   in  varchar2,
                              P_Inv_Currency_Code       in  varchar2,
                              P_Invoice_Amount          in  number,
                              X_Release_Flag            out NOCOPY varchar2, --File.Sql.39 bug 4440895
                              X_RA_Invoice_Date         out NOCOPY date, --File.Sql.39 bug 4440895
                              X_RA_Invoice_Num          out NOCOPY varchar2, --File.Sql.39 bug 4440895
                              X_Status                  out NOCOPY number, --File.Sql.39 bug 4440895
			      X_Credit_Memo_Reason_Code out  NOCOPY varchar2); --File.Sql.39 bug 4440895

  /* Overloaded Procedure release_invoice for Credit Memo Reason ARU Compatibility*/
/*#
 * This procedure is used to release the invoice extensions.
 * @param P_Project_ID The Identifier of the project to which the draft invoice number is attached
 * @rep:paraminfo {@rep:required}
 * @param P_Draft_Invoice_Num The draft invoice number
 * @rep:paraminfo {@rep:required}
 * @param P_Invoice_Class The class of the invoice
 * @rep:paraminfo {@rep:required}
 * @param P_Project_Amount Amount of the invoice in project currency
 * @rep:paraminfo {@rep:required}
 * @param P_Project_Currency_Code The project currency code
 * @rep:paraminfo {@rep:required}
 * @param P_Inv_Currency_Code The invoice currency code
 * @rep:paraminfo {@rep:required}
 * @param P_Invoice_Amount Amount of the invoice in invoice currency
 * @rep:paraminfo {@rep:required}
 * @param X_Release_Flag Flag indicating the invoice release status. The valid values are: Y = Yes (release invoice), Any other value = do not release
 * @rep:paraminfo {@rep:required}
 * @param X_RA_Invoice_Date The receivable invoice date. This parameter is validated only when the X_RELEASE_FLAG = Y
 * @rep:paraminfo {@rep:required}
 * @param X_RA_Invoice_Num The receivable invoice number. If the automatic invoice
 * numbering is active, then this parameter is not required. This parameter is validated only when the X_RELEASE_FLAG = Y
 * @rep:paraminfo {@rep:required}
 * @param X_Status Status indicating whether an error occurred. The valid values are =0 (Success), <0 (SQL Error) OR >0 (Application Error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Release Invoice
 * @rep:compatibility S
*/
Procedure Release_Invoice ( P_Project_ID              in  number,
                              P_Draft_Invoice_Num       in  number,
                              P_Invoice_Class           in  varchar2,
                              P_Project_Amount          in  number,
                              P_Project_Currency_Code   in  varchar2,
                              P_Inv_Currency_Code       in  varchar2,
                              P_Invoice_Amount          in  number,
                              X_Release_Flag            out NOCOPY varchar2, --File.Sql.39 bug 4440895
                              X_RA_Invoice_Date         out NOCOPY date, --File.Sql.39 bug 4440895
                              X_RA_Invoice_Num          out NOCOPY varchar2, --File.Sql.39 bug 4440895
                              X_Status                  out NOCOPY number); --File.Sql.39 bug 4440895



END PA_Client_Extn_Inv_Actions;

/
