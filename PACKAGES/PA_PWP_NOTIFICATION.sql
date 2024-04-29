--------------------------------------------------------
--  DDL for Package PA_PWP_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PWP_NOTIFICATION" AUTHID CURRENT_USER as
/* $Header: PAPWPWFS.pls 120.0.12010000.8 2010/06/17 11:42:26 jjgeorge noship $ */

/* This funtion will get a call from ar bussiness event
(oracle.apps.ar.applications.CashApp.apply) and will then start the Workflow. */
FUNCTION Receive_BE ( p_subscription_guid IN            RAW
                     ,p_event             IN OUT NOCOPY WF_EVENT_T ) RETURN VARCHAR2;


PROCEDURE START_AR_NOTIFY_WF (p_receivable_application_id IN             NUMBER,
                              x_err_stack                 IN OUT NOCOPY VARCHAR2,
                              x_err_stage                 IN OUT NOCOPY VARCHAR2,
                              x_err_code                     OUT NOCOPY NUMBER);

PROCEDURE Select_Project_Manager (itemtype    IN             VARCHAR2,
                                  itemkey     IN             VARCHAR2,
                                  actid       IN             NUMBER,
                                  funcmode    IN             VARCHAR2,
                                  resultout       OUT NOCOPY VARCHAR2    );

/* This will add HTML content to CLOB */
PROCEDURE APPEND_VARCHAR_TO_CLOB(p_varchar IN varchar2
                                ,p_clob    IN OUT NOCOPY CLOB);

/* This Subprogram will Fetch the generated page from pa_page_contents, called from Workflow Message */
PROCEDURE SHOW_PWP_NOTIFY_PREVIEW (document_id      IN VARCHAR2
                                  ,display_type  IN VARCHAR2
                                  ,document      IN OUT NOCOPY CLOB
                                  ,document_type IN OUT NOCOPY VARCHAR2);



CURSOR c_inv_info    ( l_receivable_application_id NUMBER )
IS
    SELECT RA.CASH_RECEIPT_ID                      Receipt_id
          ,to_char(NVL(ra.amount_applied_from,ra.amount_applied),fnd_currency.get_format_mask(rcr.currency_code, 20)) amount_applied
          ,RCR.RECEIPT_NUMBER                     Receipt_number
          ,RCR.RECEIPT_DATE                       Receipt_Date
          ,to_char(NVL(rcr.amount,0),fnd_currency.get_format_mask(rcr.currency_code, 20))  receipt_amount
          ,RCR.CURRENCY_CODE                      Receipt_Currency_Code
          ,RA.receivable_application_id           RA_ID
          ,pdi.ra_invoice_number                  AR_Invoice_No
          ,to_char(NVL(rpsa.amount_due_original, 0), fnd_currency.get_format_mask(rpsa.invoice_currency_code, 20)) ar_invoice_amount
          ,trunc(RPSA.TRX_DATE)                   AR_Invoice_Date
          ,RPSA.INVOICE_CURRENCY_CODE             AR_Invoice_Currency_Code
          ,RCTRX.interface_header_attribute1      Project_Number
          ,trunc(sysdate)                         Date_of_notification
          ,pdi.draft_invoice_num                  draft_invoice_number
          ,RPSA.Status                            Invoice_Status
     FROM  ar_receivable_applications  RA
           ,AR_CASH_RECEIPTS            RCR
          ,ra_customer_trx             RCTRX
          ,ar_payment_schedules        RPSA
          ,pa_draft_invoices           PDI
    WHERE RA.receivable_application_id = l_receivable_application_id and
          RA.STATUS = 'APP' and
          RA.CASH_RECEIPT_ID = RCR.CASH_RECEIPT_ID AND
          RA.applied_customer_trx_id = RCTRX.customer_trx_id and
          RPSA.customer_trx_id = RCTRX.customer_trx_id and
          /*pdi.system_reference = rctrx.customer_trx_id;  commented and added below for bug 8716284 */
          pdi.ra_invoice_number = rctrx.trx_number;

CURSOR c_proj_info    ( p_project_num VARCHAR2 )
IS
    SELECT  project_id                      Project_id
           ,segment1                        Project_Number
           ,name                            Project_Name
           ,start_date                      Start_Date
           ,completion_date                 End_Date
           ,project_type                    Project_Type
           ,carrying_out_organization_id    Organization_Id
           ,project_status_code             Project_Status
        FROM  pa_projects
     WHERE  segment1 = p_project_num;

/* This subprogram will generate the html page for notification message */
PROCEDURE Generate_PWP_Notify_Page (p_item_type     IN  VARCHAR2,
                                    p_item_Key      IN  VARCHAR2,
                                    p_inv_info_rec  IN  c_inv_info%ROWTYPE,
                                    p_proj_info_rec IN  c_proj_info%ROWTYPE,
                                    x_content_id    OUT NOCOPY NUMBER);

/* Declaration of cursors for selecting Project Manager.
Used in Sub Programs : Generate_PWP_Notify_Page
                                        Select_Project_Manager
*/

CURSOR  c_manager( p_manager_id NUMBER )
IS
    SELECT  f.user_id user_id
           ,f.user_name user_name
           ,e.first_name||' '||e.last_name full_name
      FROM  fnd_user f
           ,pa_employees e
     WHERE  f.employee_id = p_manager_id
       AND  f.employee_id = e.person_id;

Cursor c_proj_manager (l_project_id NUMBER)
IS
    SELECT  ppp.resource_source_id manager_employee_id
      FROM  pa_project_parties  ppp
           ,per_all_people_f pe
     WHERE  ppp.project_id = l_project_id
       AND  ppp.project_role_id = 1
       AND  ppp.resource_type_id = 101
       AND  ppp.resource_source_id = pe.person_id
       AND  TRUNC(SYSDATE) BETWEEN pe.effective_start_date AND pe.effective_end_date
       AND  ppp.object_type = 'PA_PROJECTS'
       AND  TRUNC(SYSDATE) BETWEEN ppp.start_date_active AND NVL(ppp.end_date_active,TRUNC(SYSDATE)+1);

END PA_PWP_NOTIFICATION;

/
