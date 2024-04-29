--------------------------------------------------------
--  DDL for Package PA_INVOICE_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_INVOICE_CURRENCY" AUTHID CURRENT_USER as
/* $Header: PAXICURS.pls 120.1 2005/08/19 17:14:09 mwasowic noship $ */


g_currency_code    VARCHAR2(15);

--
-- This package will populate the invoice currency code,conversion
-- attributes of PA_DRAFT_INVOICES and inv_amount of PA_DRAFT_INVOICE
-- _ITEMS.
-- Procedure  : RECALCULATE
-- Parameter  :
--	 P_Project_Id            - Project Id
--       P_Draft_Inv_Num         - Draft Invoice
--       P_Calling_Module        - Calling Program
--       P_Customer_Id           - Customer Id
--       P_Inv_currency_code     - Invoice Currency Code
--       P_Inv_Rate_Type         - Invoice Rate Type
--       P_Inv_Rate_Date         - Invoice Rate Date
--       P_Inv_Exchange_Rate     - Invoice Exchange Rate
--       P_User_Id               - User Id    ( For Future Enhancement )
--       P_Bill_Thru_Date        - Bill Thru Date
--       X_Status                - Output Status  = NULL - Successful
--                                                = Application Error Code
--                                                  for PAXINRVW
--
-- Note       :
--   This procedure will not lock any table explicitly. For PAXINRVW, PA_DRAFT
--   _INVOICES should be locked for that invoices  by the calling program. For
--   PAIGEN, PA_PROJECTS should be locked by the calling program.
--

---  Function to format currency for Multi Radix changes
---  global currency code is fetched from invoice program (paisql.lpc)

FUNCTION  format_proj_curr_code RETURN VARCHAR2;
   pragma RESTRICT_REFERENCES ( format_proj_curr_code, WNDS );


PROCEDURE RECALCULATE ( P_Project_Id         IN   NUMBER,
                        P_Draft_Inv_Num      IN   NUMBER,
                        P_Calling_Module     IN   VARCHAR2,
                        P_Customer_Id        IN   NUMBER,
                        P_Inv_currency_code  IN   VARCHAR2,
                        P_Inv_Rate_Type      IN   VARCHAR2,
                        P_Inv_Rate_Date      IN   DATE,
                        P_Inv_Exchange_Rate  IN   NUMBER,
                        P_User_Id            IN   NUMBER,
                        P_Bill_Thru_Date     IN   DATE,
                        X_Status            OUT   NOCOPY VARCHAR2 );                        --File.Sql.39 bug 4440895


-- Procedure              : get_inv_curr_info
-- Usage                  : This procedure fetches the invoice currency and currency
--                          attribute for the input Invoice.
-- Parameter              : P_Project_Id          -- Project Id
--                          P_Draft_Inv_Num       -- Draft Invoice Number
--                          X_Inv_curr_code       -- out Invoice Currency Code
--                          X_Inv_rate_type       -- out Invoice Rate Type
--                          X_Inv_rate_date       -- out Invoice Rate date
--                          X_Inv_exchange_rate   -- out Invoice Exchange rate

PROCEDURE get_inv_curr_info ( P_Project_Id          IN NUMBER,
                         P_Draft_Inv_Num       IN NUMBER,
                         X_Inv_curr_code      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         X_Inv_rate_type      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         X_Inv_rate_date      OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                         X_Inv_exchange_rate  OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

/* Bug 3051294 */
-- Procedure              : get_projfunc_inv_curr_info
-- Usage                  : This procedure fetches the currency attributes for the project functional currency
--                          and input  Invoice.
-- Parameter              : P_Project_Id             -- Project Id
--                          P_Draft_Inv_Num          -- Draft Invoice Number
--                          X_Projfunc_Inv_rate_type -- out Project Functional Invoice Rate Type
--                          X_Projfunc_Inv_rate_date -- out Project Functional Invoice Rate date
--                          X_Projfunc_Inv_ex_rate   -- out Project Functional Invoice Exchange rate

PROCEDURE get_projfunc_inv_curr_info ( P_Project_Id              IN NUMBER,
                                       P_Draft_Inv_Num           IN NUMBER,
                                       X_Projfunc_Inv_rate_type OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       X_Projfunc_Inv_rate_date OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                       X_Projfunc_Inv_ex_rate   OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

-- Procedure            : get_proj_curr_info
-- Usage                : This procedure will return the project currency
--                        for the input project.
-- Parameter            : P_Project_Id         -- Project Id
--                        X_Inv_curr_code      -- out Project Currency

PROCEDURE get_proj_curr_info ( P_Project_Id          IN NUMBER,
                               X_Inv_curr_code      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- Procedure            : Update_CRMemo_Invamt
-- Usage                : This procedure will update the credit memo line amt
--                        for Invoicing currency.
-- Parameter            : P_Project_Id                     -- Project Id
--                        P_Draft_Inv_Num                  -- Draft Invoice Number
--                        P_Draft_Inv_Num_Credited         -- Credited Invoice Number
PROCEDURE Update_CRMemo_Invamt ( P_Project_Id                IN NUMBER,
                                 P_Draft_Inv_Num             IN NUMBER,
                                 P_Draft_Inv_Num_Credited    IN NUMBER) ;


-- Procedure            : Recalculate_Driver
-- Usage                : Used to populate the invoice line amount in
--                        invoice currency.
-- Parameters           :
-- IN              P_Request_ID          IN   NUMBER     Required
--                          Request ID of the Generate Draft Invoice Process.
--                          Corresponds to REQUEST_ID of PA_DRAFT_INVOICES_ALL
--                 P_User_ID             IN   NUMBER     Required
--                          Logged in UserId.
--                 P_Project_ID          IN   NUMBER     Optional
--                          Project Identifier. Corresponds to the Column
--                          PROJECT_ID of PA_PROJECTS_ALL Table
--
  Procedure Recalculate_Driver( P_Request_ID         in  number,
                                P_User_ID            in  number,
                                P_Project_ID         in  number,
				P_calling_Process    IN  VARCHAR2 DEFAULT 'PROJECT_INVOICES');


END PA_INVOICE_CURRENCY;
 

/
