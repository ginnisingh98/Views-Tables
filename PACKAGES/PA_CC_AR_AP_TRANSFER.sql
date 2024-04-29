--------------------------------------------------------
--  DDL for Package PA_CC_AR_AP_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_AR_AP_TRANSFER" AUTHID CURRENT_USER AS
/* $Header: PAXARAPS.pls 120.3 2006/03/15 19:19:50 sbsivara noship $ */

    G_created_by         number := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
    G_last_update_login  number := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')), -1);
    G_last_updated_by    number := G_created_by;
    G_creation_date      date := SYSDATE;
    G_last_update_date   date := SYSDATE ;

procedure  Populate_ap_invoices_interface(
                     p_internal_billing_type in varchar2,
                     p_invoice_id in number,
                     p_invoice_number in varchar2,
                     p_invoice_date in date,
                     p_vendor_id in number,
                     p_vendor_site_id in number,
                     p_invoice_amount number,
                     p_invoice_currency_code in varchar2,
                     p_description in varchar2,
                     p_group_id in varchar2,
                     p_workflow_flag in varchar2,
                     p_org_id in number);

procedure      Populate_ap_inv_line_interface(
                   p_invoice_id in number,
                   p_internal_billing_type in varchar2,
                   p_receiver_project_id in number,
                   p_receiver_task_id in number,
                   p_expenditure_type in PA_PLSQL_DATATYPES.Char50TabTyp,
                   p_invoice_date in date ,
                   p_expenditure_organization_id in PA_PLSQL_DATATYPES.NumTabTyp,
                   p_recvr_org_id  in number,
                   p_customer_trx_id in number,
                   p_project_customer_id in number,
                   p_invoice_line_number in PA_PLSQL_DATATYPES.NumTabTyp,
                   p_inv_amount  in PA_PLSQL_DATATYPES.NumTabTyp,
                   p_description  in PA_PLSQL_DATATYPES.Char240TabTyp,
                   p_tax_code in  PA_PLSQL_DATATYPES.Char50TabTyp,
                   p_project_id  in PA_PLSQL_DATATYPES.NumTabTyp,
                   p_task_id in  PA_PLSQL_DATATYPES.NumTabTyp,
                   p_pa_quantity  in PA_PLSQL_DATATYPES.NumTabTyp,
                   p_pa_cc_ar_inv_line_num  in PA_PLSQL_DATATYPES.NumTabTyp,
                   p_sub_array_size in number,
                   p_invoice_type in VARCHAR2, -- added for etax changtes
                   p_cust_trx_line_id in PA_PLSQL_DATATYPES.NumTabTyp -- added for bug 5045406
                   );



Procedure Transfer_ar_ap_invoices_01(
                     p_debug_mode   in varchar2,
                     p_process_mode in varchar2,
                     p_internal_billing_type in PA_PLSQL_DATATYPES.Char20TabTyp,
                     p_project_id in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_draft_invoice_number in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_ra_invoice_number in PA_PLSQL_DATATYPES.Char20TabTyp,
                     p_prvdr_org_id in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_recvr_org_id in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_customer_trx_id in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_project_customer_id in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_invoice_date in PA_PLSQL_DATATYPES.DateTabTyp,
                     p_invoice_comment in PA_PLSQL_DATATYPES.Char240TabTyp,
                     p_inv_currency_code in PA_PLSQL_DATATYPES.Char15TabTyp,
                     p_compute_flag in PA_PLSQL_DATATYPES.Char1TabTyp,
                     p_array_size  in Number,
                     x_transfer_status_code out NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,/*file.sql.39*/
                     x_transfer_error_code out NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,/*file.sql.39*/
                     x_status_code   out NOCOPY varchar2 /*file.sql.39*/);
Procedure Transfer_ar_ap_invoices(
                     p_internal_billing_type in PA_PLSQL_DATATYPES.Char20TabTyp,
                     p_project_id in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_draft_invoice_number in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_ra_invoice_number in PA_PLSQL_DATATYPES.Char20TabTyp,
                     p_prvdr_org_id in PA_PLSQL_DATATYPES.Char30TabTyp,
                     p_recvr_org_id in PA_PLSQL_DATATYPES.Char30TabTyp,
                     p_customer_trx_id in PA_PLSQL_DATATYPES.Char30TabTyp,
                     p_project_customer_id in PA_PLSQL_DATATYPES.Char30TabTyp,
                     p_invoice_date in PA_PLSQL_DATATYPES.Char15TabTyp,
                     p_invoice_comment in PA_PLSQL_DATATYPES.Char240TabTyp,
                     p_inv_currency_code in PA_PLSQL_DATATYPES.Char15TabTyp,
                     p_compute_flag in PA_PLSQL_DATATYPES.Char1TabTyp,
                     p_array_size  in number,
                     x_transfer_status_code out NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp /*file.sql.39*/,
                     x_transfer_error_code out NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp /*file.sql.39*/,
                     x_status_code   out NOCOPY varchar2 /*file.sql.39*/);

end PA_CC_AR_AP_TRANSFER;

 

/
