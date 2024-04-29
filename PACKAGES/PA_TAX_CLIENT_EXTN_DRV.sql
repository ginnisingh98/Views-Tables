--------------------------------------------------------
--  DDL for Package PA_TAX_CLIENT_EXTN_DRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TAX_CLIENT_EXTN_DRV" AUTHID CURRENT_USER AS
/* $Header: PAXVDTXS.pls 120.5 2007/10/24 15:07:13 arbandyo ship $ */

-- G_Draft_Invoice_Num is used to keep the draft invoice number
-- for invoice distribution warning.

      G_Draft_Invoice_Num               Number;

-- G_Prv_Draft_Invoice_Num and G_Project_Id are used to improve
-- performance of the package and used to store previous value.
      G_Prv_Draft_Invoice_Num           Number;
      G_Project_Id                      Number;

-- Error Code returned from the client extension driver
      G_error_Code                      PA_LOOKUPS.LOOKUP_CODE%TYPE;

/* Added global variable G_Invoice_Date to store invoice date
   Added for Bug 6521026 */
      G_Invoice_Date                    DATE;

-- get_tax_code calls the client extension and validate the value
-- returned by client written code and set the invoice distribution
-- warning if client supplied tax id is invalid.

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
             X_output_Tax_code         OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

end pa_tax_client_extn_drv;

/
