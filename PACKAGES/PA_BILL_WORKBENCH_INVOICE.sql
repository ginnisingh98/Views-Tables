--------------------------------------------------------
--  DDL for Package PA_BILL_WORKBENCH_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILL_WORKBENCH_INVOICE" AUTHID CURRENT_USER AS
/*$Header: PABWINVS.pls 120.1 2005/08/19 16:17:39 mwasowic noship $ */


 PROCEDURE get_inv_global_value(p_project_id                    IN   NUMBER,
                                p_draft_inv_num                 IN   NUMBER,
                                x_mcb_flag                      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_user_id                       OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_login_id                      OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_person_id                     OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_yes_m                         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_no_m                          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_na_m                          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_employee_name                 OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                X_fs_approve                    OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                X_prj_closed_flag               OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_dist_warn_flag                OUT  NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                                x_org_id                        OUT  NOCOPY NUMBER,  --File.Sql.39 bug 4440895
                                x_multi_cust_flag               OUT  NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                                x_return_status                 OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count                     OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data                      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              );


 PROCEDURE Approve_info_commit
                           ( p_project_id            IN   NUMBER,
                             p_draft_invoice_num     IN   NUMBER,
                             P_user_id               IN   NUMBER,
                             p_person_id             IN   NUMBER,
                             p_login_id              IN   NUMBER,
                             x_return_status         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count             OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           );


 PROCEDURE Get_invoice_mode
                           ( p_project_id            IN   NUMBER,
                             p_draft_invoice_num     IN   NUMBER,
                             p_inv_line_num          IN   NUMBER,
                             p_event_task_id         IN   NUMBER,
                             p_event_num             IN   NUMBER,
                             p_retn_inv_flag         IN   VARCHAR2,
                             p_inv_items_line_type   IN   VARCHAR2,
                             x_invoice_mode          OUT  NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                             x_return_status         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count             OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           );

 Procedure Validate_Approval ( P_Project_ID         in  number,
                               P_Draft_Invoice_Num  in  number,
                               P_Validation_Level   in  varchar2,
                               X_Error_Message_Code out NOCOPY varchar2 );  --File.Sql.39 bug 4440895

PROCEDURE validate_multi_Customer ( P_Invoice_Set_ID     in  number,
                                    X_Error_Message_Code out NOCOPY varchar2); --File.Sql.39 bug 4440895

Procedure Validate_multi_invoices ( P_Project_ID         in  number,
                               P_invoice_set_Id  in  number,
                               P_Validation_Level   in  varchar2,
                               X_Error_Message_Code out NOCOPY varchar2 );  --File.Sql.39 bug 4440895

 PROCEDURE Approve_multi_commit
                           ( p_project_id            IN   NUMBER,
                             p_invoice_set_id        IN   NUMBER,
                             P_user_id               IN   NUMBER,
                             p_person_id             IN   NUMBER,
                             p_login_id              IN   NUMBER,
                             x_app_draft_num         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_return_status         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count             OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           );
END pa_bill_workbench_invoice;

 

/
