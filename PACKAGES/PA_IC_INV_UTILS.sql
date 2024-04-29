--------------------------------------------------------
--  DDL for Package PA_IC_INV_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_IC_INV_UTILS" AUTHID CURRENT_USER as
/* $Header: PAICUTLS.pls 120.1 2005/08/19 16:34:45 mwasowic noship $ */

G_LAST_UPDATE_LOGIN      NUMBER;
G_REQUEST_ID	         NUMBER;
G_PROGRAM_APPLICATION_ID NUMBER;
G_PROGRAM_ID	         NUMBER;
G_LAST_UPDATED_BY        NUMBER;
G_CREATED_BY             NUMBER;
G_DEBUG_MODE             VARCHAR2(1);

-- Package specification for utilities to be used in Intercompany
-- Invoice generation process
-- This procedure will initialize the global variables
-- Input paramaters
-- Parameter                Type       Required Description
-- P_LAST_UPDATE_LOGIN      NUMBER     Yes      Standard Who column
-- P_REQUEST_ID             NUMBER     Yes
-- P_PROGRAM_APPLICATION_ID NUMBER     Yes
-- P_PROGRAM_ID             NUMBER     Yes
-- P_LAST_UPDATED_BY        NUMBER     Yes
-- P_CREATED_BY             NUMBER     Yes
-- P_DEBUG_MODE             VARCHAR2   Yes      Debug mode
-- P_SOB                    NUMBER     Yes      Set of books id
-- P_ORG                    NUMBER     Yes      Org Id
-- P_FUNC_CURR              VARCHAR2   Yes      Functional currency code
PROCEDURE Init (
	P_LAST_UPDATE_LOGIN      NUMBER,
	P_REQUEST_ID             NUMBER,
	P_PROGRAM_APPLICATION_ID NUMBER,
	P_PROGRAM_ID             NUMBER,
	P_LAST_UPDATED_BY        NUMBER,
	P_CREATED_BY             NUMBER,
        P_DEBUG_MODE             VARCHAR2,
        P_SOB                    NUMBER,
        P_ORG                    NUMBER,
        P_FUNC_CURR              VARCHAR2
) ;
--
-- This procedure will return the next draft invoice number to be used
-- for creating a new invoice header.
--
-- Input parameters
-- Parameter       Type       Required Description
-- P_PROJECT_ID   NUMBER      Yes      Identifier of the Project
-- P_REQUEST_ID   NUMBER      Yes      The current request id
--
-- Output Parameters
-- Parameter         Type   Description
-- X_NEW_INVOICE_NUM NUMBER Invoice number to be used for the new Invoice
--
PROCEDURE  Get_Next_Draft_Inv_Num
           ( P_project_id      IN  NUMBER,
	     P_request_id      IN  NUMBER,
             X_new_invoice_num OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895
-- This procedure will commit the invoice transaction
--
-- There are no parameters to this procedure
--
PROCEDURE  Commit_Invoice ;

--  This procedure will update the summary project fundings with
--  the invoiced amounts
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_DRAFT_INVOICE_NUM NUMBER      Yes      The draft invoice number
-- P_AGREEMENT_ID      NUMBER      Yes      Identifier of the Agreement
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
-- P_INVOICE_MODE      VARCHAR2    Yes      Identifier of the mode of
--                                          the invoice process
--                                          Values
--                                          'CANCEL','INVOICE','CREDIT_MEMO',
--                                          'DELETE'
PROCEDURE  Update_SPF
	   ( P_DRAFT_INVOICE_NUM IN NUMBER ,
	     P_AGREEMENT_ID      IN NUMBER ,
             P_PROJECT_ID        IN NUMBER ,
             P_INVOICE_MODE      IN VARCHAR2);
--
-- This procedure will mark the generation error on the draft invoice
-- and insert the distribution warnings
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_DRAFT_INVOICE_NUM NUMBER      Yes      The draft invoice number
-- P_REJN_LOOKUP_TYPE  VARCHAR     Yes      The lookup type to be used to
--				            get the rejection reason
-- P_REJN_LOOKUP_CODE  VARCHAR     Yes      The lookup type to be used to
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--				            get the rejection code
PROCEDURE Mark_Inv_Error
	   ( P_DRAFT_INVOICE_NUM   IN  NUMBER,
	     P_REJN_LOOKUP_TYPE    IN  VARCHAR,
	     P_REJN_LOOKUP_CODE    IN  VARCHAR,
	     P_PROJECT_ID	   IN  NUMBER);
--
-- This procedure will mark the expenditure items billed on an invoice as
-- billed.
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_DRAFT_INVOICE_NUM NUMBER      Yes      The draft invoice number
-- P_REQUEST_ID	       NUMBER	   Yes	    The current request id
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--
PROCEDURE Mark_EI_as_Billed
	   ( P_DRAFT_INVOICE_NUM IN NUMBER ,
	     P_REQUEST_ID	 IN NUMBER ,
             P_PROJECT_ID        IN NUMBER);
--
-- This function will set and acquire the user lock
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--
-- Return Values
--  0         Success
-- Other      Unable to acquire lock
--
FUNCTION Set_User_Lock
	   (P_PROJECT_ID   IN  NUMBER) RETURN NUMBER ;
--
-- This procedure will release user lock
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--
-- Return Values
--  0         Success
-- Other      Unable to acquire lock
--
FUNCTION Release_User_Lock
	   (P_PROJECT_ID   IN  NUMBER) RETURN NUMBER ;
--
-- This Function will return 'Y' if unreleased invoices exist for a project
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_BILL_BY_PROJECT   VARCHAR    Yes      The draft invoice number
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--
FUNCTION CHECK_IF_UNRELEASED_INVOICE
	  ( P_BILL_BY_PROJECT     IN  VARCHAR ,
	    P_PROJECT_ID	  IN  NUMBER) RETURN VARCHAR;

--
-- This procedure will update the draft invoice to trigger MRC
--
-- Input parameters
-- Parameter           Type       Required Description
-- P_DRAFT_INVOICE_NUM NUMBER      Yes      The draft invoice number
-- P_REQUEST_ID	       NUMBER	   Yes	    The current request id
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--
PROCEDURE Update_DI_for_MRC
	   ( P_DRAFT_INVOICE_NUM IN NUMBER ,
	     P_REQUEST_ID	 IN NUMBER ,
             P_PROJECT_ID        IN NUMBER);
--
-- This procedure will return active bill_to_site_use_id and
-- ship_to_site_id
-- Input parameters
-- Parameter               Type       Required
-- P_BILL_TO_ADDRESS_ID    NUMBER      Yes
-- P_SHIP_TO_ADDRESS_ID    NUMBER      Yes
-- P_NO_OF_RECORDS         NUMBER      Yes
-- P_CUST_CREDIT_HOLD      VARCHAR2    Yes
-- X_BILL_TO_SITE_USE_ID   NUMBER
-- X_SHIP_TO_SITE_USE_ID   NUMBER
-- X_BILL_TO_SITE_STATUS   VARCHAR2
-- X_SHIP_TO_SITE_STATUS   VARCHAR2
--
PROCEDURE Get_active_sites
           ( P_BILL_TO_ADDRESS_ID         IN PA_PLSQL_DATATYPES.IdTabTyp ,
             P_SHIP_TO_ADDRESS_ID         IN PA_PLSQL_DATATYPES.IdTabTyp ,
             P_NO_OF_RECORDS              IN NUMBER,
             P_CUST_CREDIT_HOLD       IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
             X_BILL_TO_SITE_USE_ID       OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
             X_SHIP_TO_SITE_USE_ID       OUT  NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
             X_BILL_TO_SITE_STATUS       OUT  NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
             X_SHIP_TO_SITE_STATUS       OUT NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp);


-- This procedure will write the message in the PL SQL log file
-- p_log_msg     VARCHAR2      Yes
PROCEDURE log_message (p_log_msg IN VARCHAR2);
--
end PA_IC_INV_UTILS;

 

/
