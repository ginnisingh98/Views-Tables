--------------------------------------------------------
--  DDL for Package PA_OUTPUT_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_OUTPUT_TAX" AUTHID CURRENT_USER as
/* $Header: PAXOTAXS.pls 120.6 2007/02/08 00:04:36 rmarcel ship $ */

--
-- This package will populate the VAT Tax Id ,Tax Exempt Flag and related
-- attributes of PA_DRAFT_INVOICE_ITEMS.
-- Procedure  : GET_DEFAULT_TAX_INFO
-- Parameter  :
--	 P_Project_Id                 - Project Id
--       P_Draft_Inv_Num              - Draft Invoice Number
--       P_Customer_Id                - Customer Id
--       P_Bill_to_site_use_id        - Bill to site Use id
--       P_Ship_to_site_use_id        - Ship to Site Use id
--       P_Sets_of_books_id           - Sets of Books Id
--       P_Event_id                   - Event Id
--       P_Expenditure_item_id        - Expenditure Item  Id
--       P_User_Id                    - User Id
--       P_Request_id                 - Request Id
--       X_Output_vat_tax_id          - Output Vat Tax Identifier
--       X_Output_tax_exempt_flag     - Output Tax Exemption Flag
--       X_Output_tax_exempt_number   - Output Tax Exemption Number
--       X_Output_exempt_reason_code
--                                    - Output Tax exempt reason code
--       P_invoice_date               - Invoice Date , added for bug 5484859
--
-- Note       :
--   This procedure will call arp_tax package .
--

PROCEDURE GET_DEFAULT_TAX_INFO
           ( P_Project_Id                      IN   NUMBER ,
             P_Draft_Inv_Num                   IN   NUMBER ,
             P_Customer_Id                     IN   NUMBER ,
             P_Bill_to_site_use_id             IN   NUMBER ,
             P_Ship_to_site_use_id             IN   NUMBER ,
             P_Sets_of_books_id                IN   NUMBER ,
             P_Event_id                        IN   NUMBER default NULL,
             P_Expenditure_item_id             IN   NUMBER default NULL,
             P_User_Id                         IN   NUMBER ,
             P_Request_id                      IN   NUMBER ,
             X_Output_tax_exempt_flag         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             X_Output_tax_exempt_number       OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             X_Output_exempt_reason_code      OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             X_Output_tax_code                OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     	     P_invoice_date                    IN   DATE default sysdate); /* bug 5484859 */


PROCEDURE GET_DEFAULT_TAX_INFO
           ( P_Project_Id                      IN   NUMBER ,
             P_Draft_Inv_Num                   IN   NUMBER ,
             P_Customer_Id                     IN   NUMBER ,
             P_Bill_to_site_use_id             IN   NUMBER ,
             P_Ship_to_site_use_id             IN   NUMBER ,
             P_Sets_of_books_id                IN   NUMBER ,
             P_Event_id                        IN   NUMBER default NULL,
             P_Expenditure_item_id             IN   NUMBER default NULL,
             P_User_Id                         IN   NUMBER ,
             P_Request_id                      IN   NUMBER ,
             X_Output_tax_exempt_flag         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             X_Output_tax_exempt_number       OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             X_Output_exempt_reason_code      OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             X_Output_tax_code                OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             Pbill_to_customer_id              IN   NUMBER,
             Pship_to_customer_id              IN   NUMBER,
             P_draft_inv_num_credited          IN   NUMBER DEFAULT NULL,
	     P_invoice_date                    IN   DATE default sysdate); /* bug 5484859 */


-- Procedure              : MARK_CUST_REV_DIST_LINES
-- Usage                  : This procedure will update the Customer Revenue
--                          distribution lines with Tax info and mark it for
--                          Invoice generation.
-- Parameter
--	 P_Project_Id                 - Project Id
--       P_Draft_Inv_Num              - Draft Invoice Number
--       P_Customer_Id                - Customer Id
--       P_Bill_to_site_use_id        - Bill to site Use id
--       P_Ship_to_site_use_id        - Ship to Site Use id
--       P_Sets_of_books_id           - Sets of Books Id
--       P_Expenditure_item_id        - Expenditure Item  Id (PL/SQL Table)
--       P_Line_num                   - Expenditure Line Number(PL/SQL Table)
--       P_User_Id                    - User Id
--       P_Request_id                 - Request Id
--       P_No_of_rec                  - No of input records
--       X_Rec_upd                    - No of Records Updated
/*Overloaded the procedure for customer account relation enhancement
bug 2760630 */
PROCEDURE MARK_CUST_REV_DIST_LINES (
             P_Project_Id                      IN   NUMBER ,
             P_Draft_Inv_Num                   IN   NUMBER ,
             P_Customer_Id                     IN   NUMBER ,
             p_agreement_id                    IN   NUMBER,
             P_Bill_to_site_use_id             IN   NUMBER ,
             P_Ship_to_site_use_id             IN   NUMBER ,
             P_Sets_of_books_id                IN   NUMBER ,
             P_Expenditure_item_id             IN   PA_PLSQL_DATATYPES.IdTabTyp,
             P_Line_num                        IN   PA_PLSQL_DATATYPES.IdTabTyp,
             P_User_Id                         IN   NUMBER ,
             P_Request_id                      IN   NUMBER ,
             P_No_of_rec                       IN   NUMBER ,
             X_Rec_upd                        OUT   NOCOPY NUMBER , --File.Sql.39 bug 4440895
             P_bill_trans_currency_code        IN   PA_PLSQL_DATATYPES.Char30TabTyp,
             P_bill_trans_invoice_amount       IN   PA_PLSQL_DATATYPES.Char30TabTyp,
             P_bill_trans_bill_amount          IN   PA_PLSQL_DATATYPES.Char30TabTyp,
             P_invproc_invoice_amount          IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             P_invproc_bill_amount             IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             p_retention_percentage            IN   VARCHAR2,
             P_status_code                     IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             p_invoice_date                    IN VARCHAR2,
             x_return_status                   IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             );

PROCEDURE MARK_CUST_REV_DIST_LINES (
             P_Project_Id                      IN   NUMBER ,
             P_Draft_Inv_Num                   IN   NUMBER ,
             P_Customer_Id                     IN   NUMBER ,
	     p_agreement_id		       IN   NUMBER,
             P_Bill_to_site_use_id             IN   NUMBER ,
             P_Ship_to_site_use_id             IN   NUMBER ,
             P_Sets_of_books_id                IN   NUMBER ,
             P_Expenditure_item_id             IN   PA_PLSQL_DATATYPES.IdTabTyp,
             P_Line_num                        IN   PA_PLSQL_DATATYPES.IdTabTyp,
             P_User_Id                         IN   NUMBER ,
             P_Request_id                      IN   NUMBER ,
             P_No_of_rec                       IN   NUMBER ,
             X_Rec_upd                        OUT   NOCOPY NUMBER , --File.Sql.39 bug 4440895
	     P_bill_trans_currency_code        IN   PA_PLSQL_DATATYPES.Char30TabTyp,
     	     P_bill_trans_invoice_amount       IN   PA_PLSQL_DATATYPES.Char30TabTyp,
             P_bill_trans_bill_amount          IN   PA_PLSQL_DATATYPES.Char30TabTyp,
             P_invproc_invoice_amount          IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             P_invproc_bill_amount             IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             p_retention_percentage            IN   VARCHAR2,
             P_status_code                     IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
	     p_invoice_date		       IN VARCHAR2,
             Pbill_to_customer_id              IN NUMBER,
             Pship_to_customer_id              IN NUMBER,
             P_shared_funds_consumption        IN   NUMBER, /* Federal  */
             P_expenditure_item_date            IN  PA_PLSQL_DATATYPES.Char30TabTyp, /* Federal */
             x_return_status                   IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	     );

-- Function               : IS_AR_INSTALLED
-- Usage                  : This function will return Y if AR is installed other
--                          wise return N.
-- Parameter              :
--	 P_Check_prod_installed  -Flag to check only the product installation.
--       P_Check_org_installed   -Flag to check the product installation
--                                in a particular org.

  Function IS_AR_INSTALLED( P_Check_prod_installed  in  varchar2 default 'N',
                            P_Check_org_installed   in  varchar2 default 'N')
  return Varchar2;

-- Function               : GET_DRAFT_INVOICE_TAX_AMT
-- Usage                  : This function will return 0 if invoice is not inter
--                          faced to AR, otherwise return tax amount for that
--                          invoice.
-- Parameter              :
--	 P_Trx_Id                -Customer Transaction Identifier

  Function GET_DRAFT_INVOICE_TAX_AMT( P_Trx_Id  in  NUMBER )
  return Number;

--
-- This procedure will populate the VAT Tax Id ,Tax Exempt Flag and related
-- attributes of Expenditure Items in array.
-- Procedure  : GET_DEFAULT_TAX_INFO
-- Parameter  :
--	 P_Project_Id                 - Project Id
--       P_Customer_Id                - Customer Id
--       P_Bill_to_site_use_id        - Bill to site Use id
--       P_Ship_to_site_use_id        - Ship to Site Use id
--       P_Sets_of_books_id           - Sets of Books Id
--       P_Expenditure_item_id        - Expenditure Item  Id
--       P_User_Id                    - User Id
--       P_Request_id                 - Request Id
--       P_Compute_flag               - Whether Computation is required or not
--       P_Error_code                 - Error Code
--       X_Output_vat_tax_id          - Output Vat Tax Identifier
--       X_Output_tax_exempt_flag     - Output Tax Exemption Flag
--       X_Output_tax_exempt_number   - Output Tax Exemption Number
--       X_Output_exempt_reason_code
--                                    - Output Tax exempt reason code
--
-- Note       :
--   This procedure will call GET_DEFAULT_TAX_INFO procedure.
--
PROCEDURE GET_DEFAULT_TAX_INFO_ARR
           ( P_Project_Id              IN   number ,
             P_Customer_Id             IN   number ,
             P_Bill_to_site_use_id     IN   number ,
             P_Ship_to_site_use_id     IN   number ,
             P_Set_of_books_id         IN   number ,
             P_Expenditure_item_id     IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_User_Id                 IN   NUMBER ,
             P_Request_id              IN   NUMBER ,
             P_No_of_records           IN   NUMBER ,
             P_Compute_flag        IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
             P_Error_Code          IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
             X_Output_tax_code      OUT NOCOPY    PA_PLSQL_DATATYPES.Char30TabTyp,
             X_Output_tax_exempt_flag OUT NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
             X_Output_tax_exempt_number  OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
             X_Output_exempt_reason_code OUT NOCOPY  PA_PLSQL_DATATYPES.Char80TabTyp,
             Pbill_to_customer_id         IN NUMBER DEFAULT NULL,
             Pship_to_customer_id         IN NUMBER DEFAULT NULL);

 FUNCTION TAXID_2_CODE_CONV (p_org_id in number,
                             p_tax_id in number)
        return varchar2;
 pragma RESTRICT_REFERENCES (TAXID_2_CODE_CONV, WNDS);

 procedure  get_legal_entity_id (p_customer_id  IN NUMBER,
                                  p_org_id IN NUMBER,
                                  p_transaction_type_id IN NUMBER,
                                  p_batch_source_id   IN NUMBER,
                                  x_legal_entity_id OUT NOCOPY NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2);

 procedure get_btch_src_trans_type ( p_project_id IN NUMBER,
                                     p_draft_invoice_num IN NUMBER,
                                     p_draft_inv_num_credited IN NUMBER,
                                     x_transaction_type_id out NOCOPY number,
                                     x_batch_source_id out NOCOPY number,
                                     x_return_status OUT NOCOPY varchar2);

END PA_OUTPUT_TAX;

/
