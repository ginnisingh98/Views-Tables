--------------------------------------------------------
--  DDL for Package Body PA_TAX_CLIENT_EXTN_DRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TAX_CLIENT_EXTN_DRV" AS
/* $Header: PAXVDTXB.pls 120.7.12010000.2 2009/07/03 07:24:21 rdegala ship $ */
--   Private procedure for setting invoice distribution warning

/*----------------------------------------------------------------------------+
 | This Private Procedure Insert_Distrbution_Warning Inserts draft Invoice    |
 | distribution warning.                                                      |
 +----------------------------------------------------------------------------*/
  Procedure Insert_Distribution_Warning( P_Project_ID         in  number,
                                         P_User_ID            in  number,
                                         P_Request_ID         in  number,
                                         P_Error_Message_Code in  varchar2) is

    l_error_message   pa_lookups.meaning%TYPE;

  BEGIN

-- If Project id or draft Invoice Number is changed then insert the
-- distribution warning.

  If (pa_tax_client_extn_drv.G_Project_Id <> P_Project_ID or
      pa_tax_client_extn_drv.G_Prv_Draft_Invoice_num
                          <> pa_tax_client_extn_drv.G_Draft_Invoice_num )
  Then
   If pa_tax_client_extn_drv.G_Draft_Invoice_num is not NULL
   Then
    BEGIN
      SELECT Meaning
        INTO l_error_message
        FROM PA_Lookups
       WHERE Lookup_Type = 'OUTPUT TAX'
         AND Lookup_Code = P_Error_Message_Code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_error_message := P_Error_Message_Code;
    END;

    INSERT INTO PA_DISTRIBUTION_WARNINGS
    (
      PROJECT_ID, DRAFT_INVOICE_NUM, LAST_UPDATE_DATE, LAST_UPDATED_BY,
      CREATION_DATE, CREATED_BY, REQUEST_ID, WARNING_MESSAGE
    )
    VALUES
    (
      P_Project_ID, pa_tax_client_extn_drv.G_Draft_Invoice_Num,sysdate,
      P_User_ID,sysdate, P_User_ID, P_Request_ID, l_error_message
    );
   Else

   -- Set the Error Code
    pa_tax_client_extn_drv.G_error_Code            := P_Error_Message_Code;

   End if;

-- Set the Global to avoid unnecessary loop
   pa_tax_client_extn_drv.G_Project_Id            := P_Project_ID;
   pa_tax_client_extn_drv.G_Prv_Draft_Invoice_num := G_Draft_Invoice_num;

  End If;


  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Insert_Distribution_Warning;

-- Public part of the package starts here

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
         X_output_Tax_code         OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS

   --l_vat_tax_id                 Number; --commented by hsiu
   l_tax_code                   Varchar2(30);
   l_dummy                      Varchar2(1);

  BEGIN

    -- Call the Client extension Driver

    pa_client_extn_output_tax.get_tax_code
      ( P_project_id   => P_project_id,
        P_customer_id  => P_customer_id,
        P_bill_to_site_use_id => P_bill_to_site_use_id,
        P_ship_to_site_use_id => P_ship_to_site_use_id,
        P_set_of_books_id     => P_set_of_books_id,
        P_expenditure_item_id => P_expenditure_item_id,
        P_event_id            => P_event_id,
        P_line_type           => P_line_type,
        P_request_id          => P_request_id,
        P_user_id             => P_user_id,
        X_output_Tax_code     => l_tax_code);
--        X_vat_tax_id          => l_vat_tax_id ); --commented by hsiu

--     If l_vat_tax_id IS Not NULL --commented by hsiu
     If l_tax_code IS NOT NULL
     Then
        Begin
          -- Verify the existance of the tax Id

             Select 'x'
             into   l_dummy
             from   pa_output_tax_code_txn_v
             where  tax_code = l_tax_code
	     and org_id in (PA_MOAC_UTILS.GET_CURRENT_ORG_ID, -99)  /*Added condition for Bug 5255736*/
             and G_Invoice_Date between start_date_active and nvl(end_date_active,G_Invoice_Date); /* Added for Bug 6521026, modified sysdate in NVL to G_Invoice_Date */
--             where  vat_tax_id  = l_vat_tax_id;--commented by hsiu

          -- Set the output Tax Id
             x_output_tax_code := l_tax_code;
--             X_vat_tax_id := l_vat_tax_id; --commented by hsiu

        Exception

             When NO_DATA_FOUND
             Then
                  -- If Client Extension returns Invalid Tax Id,
                  -- Set distribution warning and output vat tax id as Null.

                  Insert_Distribution_Warning
                    (P_Project_ID   => P_Project_ID,
                     P_User_ID      => P_User_ID,
                     P_Request_ID   => P_Request_ID,
                     P_Error_Message_Code => 'INVALID_TAX_ID');

--                  X_vat_tax_id := NULL;
                  x_output_tax_code := NULL;
        End;
      End If;

  EXCEPTION

      When Others
      Then
          /* ATG Changes */

           X_output_Tax_code := null;

           Raise;

  END get_tax_code;

END pa_tax_client_extn_drv;

/
