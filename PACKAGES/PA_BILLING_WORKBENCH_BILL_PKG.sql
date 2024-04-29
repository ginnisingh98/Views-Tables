--------------------------------------------------------
--  DDL for Package PA_BILLING_WORKBENCH_BILL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_WORKBENCH_BILL_PKG" AUTHID CURRENT_USER as
/* $Header: PAXBLWBS.pls 120.3 2006/01/19 03:15:47 bchandra noship $ */

/* Declaring global variable for invoice region VO
 G_system_reference        NUMBER;
 G_ar_amount               NUMBER; */

-- This procedure will get all the parameters for Billing Region for the given project.
-- burdened cost and raw revenue on the basis of passed parameters
-- Input parameters
-- Parameters                      Type           Required      Description
-- p_project_id                   NUMBER           YES          The identifier of the project
--
-- Out parameters
--
-- x_funding_amt                  NUMBER          YES          Total Baselined amount for the given project
-- x_rev_accured                  NUMBER          YES          Total Revenue accrued for the given project
-- x_rev_backlog                  NUMBER          YES          Revenue funding backlog. The diff of above two
-- x_rev_writeoff                 NUMBER          YES          Total accrued revenue writeoff
-- x_ubr                          NUMBER          YES          Total Unbilled receivables for the given project
-- x_uer                          NUMBER          YES          Total Unearned revenue for the given project
-- x_inv_billed                   NUMBER          YES          Total Invoiced amount(including project invoices, credit
--                                                             memos,write-off,cancelling,concession project, and
--                                                             retention invoices
-- x_inv_backlog                  NUMBER          YES          Invoice Funding backlog. The diff of Funding amt and inv_billed
-- x_inv_paid                     NUMBER          YES          Total invoice amount paid by the customers for this project
-- x_inv_due                      NUMBER          YES          Total invoice amount due from customers
-- x_billable_cost                NUMBER          YES          Sum of the burdened cost of all the expenditure items
--                                                             with billable flag as yes and cost distribution as yes
-- x_unbilled_cost                NUMBER          YES          Total burdened cost that is not yet billed, but marked
--                                                             as billable as yes
-- x_unbilled_events              NUMBER          YES          Sum of all invoice events that are not billed to the customers (
--                                                             including partialy billed event amount also
-- x_unbilled_retn                NUMBER          YES          Total withheld amount that is not billed to the customer
-- x_unapproved_inv_amt           NUMBER          YES          Sum of all the unapproved project and retention invoices
--                                                             including credit memosof project invoices, cancelling,
--                                                             writeoff,concession project
--
PROCEDURE Get_Billing_Sum_Region_Amts (
                                            p_project_id                  IN     NUMBER ,
                                            p_project_currency            IN     VARCHAR2 ,
                                            p_projfunc_currency           IN     VARCHAR2 ,
                                            p_ubr                         IN     NUMBER ,
                                            p_uer                         IN     NUMBER ,
                                            x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                            x_msg_count                   OUT    NOCOPY NUMBER  , --File.Sql.39 bug 4440895
                                            x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      );



--
-- Procedure            : Get_Billing_Sum_Region_Amts
-- Purpose              : This procedure will get all the parameters for Billing Region for the given project.
-- Parameters           :
--


-- This procedure will populate the temp table with all the input paramters for billing
-- work bench.
-- Input parameters
-- Parameters                      Type           Required      Description
-- p_project_id                   NUMBER           YES          The identifier of the project
-- p_funding_amt                  NUMBER          YES          Total Baselined amount for the given project
-- p_rev_accured                  NUMBER          YES          Total Revenue accrued for the given project
-- p_rev_backlog                  NUMBER          YES          Revenue funding backlog. The diff of above two
-- p_rev_writeoff                 NUMBER          YES          Total accrued revenue writeoff
-- p_ubr                          NUMBER          YES          Total Unbilled receivables for the given project
-- p_uer                          NUMBER          YES          Total Unearned revenue for the given project
-- p_inv_billed                   NUMBER          YES          Total Invoiced amount(including project invoices, credit
--                                                             memos,write-off,cancelling,concession project, and
--                                                             retention invoices
-- p_inv_backlog                  NUMBER          YES          Invoice Funding backlog. The diff of Funding amt and inv_billed
-- p_inv_paid                     NUMBER          YES          Total invoice amount paid by the customers for this project
-- p_inv_due                      NUMBER          YES          Total invoice amount due from customers
-- p_billable_cost                NUMBER          YES          Sum of the burdened cost of all the expenditure items
--                                                             with billable flag as yes and cost distribution as yes
-- p_unbilled_cost                NUMBER          YES          Total burdened cost that is not yet billed, but marked
--                                                             as billable as yes
-- p_unbilled_events              NUMBER          YES          Sum of all invoice events that are not billed to the customers (
--                                                             including partialy billed event amount also
-- p_unbilled_retn                NUMBER          YES          Total withheld amount that is not billed to the customer
-- p_unapproved_inv_amt           NUMBER          YES          Sum of all the unapproved project and retention invoices
--                                                             including credit memosof project invoices, cancelling,
--                                                             writeoff,concession project
--
-- Out parameters
--

PROCEDURE Populat_Bill_Workbench_Data (
                                            p_project_id                  IN    NUMBER,
                                            p_proj_funding_amt            IN    NUMBER ,
                                            p_proj_rev_accured            IN    NUMBER ,
                                            p_proj_rev_backlog            IN    NUMBER ,
                                            p_proj_rev_writeoff           IN    NUMBER ,
                                            p_proj_ubr                    IN    NUMBER ,
                                            p_proj_uer                    IN    NUMBER ,
                                            p_proj_inv_invoiced           IN    NUMBER ,
                                            p_proj_inv_backlog            IN    NUMBER ,
                                            p_proj_inv_paid               IN    NUMBER ,
                                            p_proj_inv_due                IN    NUMBER ,
                                            p_proj_billable_cost          IN    NUMBER ,
                                            p_proj_unbilled_cost          IN    NUMBER ,
                                            p_proj_unbilled_events        IN    NUMBER ,
                                            p_proj_unbilled_retn          IN    NUMBER ,
                                            p_proj_unapproved_inv_amt     IN    NUMBER ,
                                            p_proj_tax                    IN    NUMBER ,
                                            p_pc_ubr_applicab_flag        IN    VARCHAR2,
                                            p_pc_uer_applicab_flag        IN    VARCHAR2,
                                            p_pc_unbil_eve_applicab_flag  IN    VARCHAR2,
                                            p_projfunc_funding_amt        IN    NUMBER ,
                                            p_projfunc_rev_accured        IN    NUMBER ,
                                            p_projfunc_rev_backlog        IN    NUMBER ,
                                            p_projfunc_rev_writeoff       IN    NUMBER ,
                                            p_projfunc_ubr                IN    NUMBER ,
                                            p_projfunc_uer                IN    NUMBER ,
                                            p_projfunc_inv_invoiced       IN    NUMBER ,
                                            p_projfunc_inv_backlog        IN    NUMBER ,
                                            p_projfunc_inv_paid           IN    NUMBER ,
                                            p_projfunc_inv_due            IN    NUMBER ,
                                            p_projfunc_billable_cost      IN    NUMBER ,
                                            p_projfunc_unbilled_cost      IN    NUMBER ,
                                            p_projfunc_unbilled_events    IN    NUMBER ,
                                            p_projfunc_unbilled_retn      IN    NUMBER ,
                                            p_projfunc_unapprov_inv_amt   IN    NUMBER ,
                                            p_projfunc_tax                IN    NUMBER ,
                                            p_pfc_unbil_eve_applicab_flag IN    VARCHAR2,
                                            p_next_invoice_date           IN    DATE,
                                            p_multi_customer_flag         IN    VARCHAR2,
                                            x_return_status               OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                            x_msg_count                   OUT   NOCOPY NUMBER  , --File.Sql.39 bug 4440895
                                            x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      );



--
-- Procedure            : Populat_Bill_Workbench_Data
-- Purpose              :This procedure will populate the temp table with all the input paramters for billing
--                       work bench.
-- Parameters           :
--






-- This procedure will populate the temp table with all the input paramters for Summary by customer region of invoicing
-- Input parameters
-- Parameters                      Type           Required      Description
-- p_project_id                   NUMBER           YES          The identifier of the project
-- p_inv_filter                   VARCHAR2         YES          Filter to filter invoices based on the user inputs
--
-- Out parameters
--
/* Added 10 parameter  after p_inv_filter for search region i.e. bug 3618704 */

PROCEDURE Populat_Inv_Summ_by_Cust_RN (
                                            p_project_id                  IN    NUMBER,
                                            p_inv_filter                  IN    VARCHAR2,
                                            p_search_flag                 IN    VARCHAR2,
                                            p_agreement_id                IN    NUMBER ,
                                            p_draft_num                   IN    NUMBER,
                                            p_ar_number                   IN    VARCHAR2 ,
                                            p_creation_frm_date           IN    DATE ,
                                            p_creation_to_date            IN    DATE ,
                                            p_invoice_frm_date            IN    DATE ,
                                            p_invoice_to_date             IN    DATE ,
                                            p_gl_frm_date                 IN    DATE ,
                                            p_gl_to_date                  IN    DATE ,
                                            x_return_status               OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                            x_msg_count                   OUT   NOCOPY NUMBER  , --File.Sql.39 bug 4440895
                                            x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      );



--
-- Procedure            : Populat_Inv_Summ_by_Cust_RN
-- Purpose              :This procedure will populate the temp table with all the input paramters for Summary by customer region
--                       of invoicing
-- Parameters           :
--

FUNCTION Get_Due_Amount (
                                            p_project_id                  IN     NUMBER DEFAULT NULL,
                                            p_draft_inv_num               IN     NUMBER DEFAULT NULL,
                                            p_system_reference            IN     NUMBER ,
                                            p_transfer_status_code        IN     VARCHAR2 ,
                                            p_calling_mode                IN     VARCHAR2 ,
                                            p_inv_amount                  IN     NUMBER DEFAULT NULL,
                                            p_proj_bill_amount            IN     NUMBER DEFAULT NULL,
                                            p_projfunc_bill_amount        IN     NUMBER DEFAULT NULL
                                      )  RETURN NUMBER;



--
-- Procedure            : Get_Due_Amount
-- Purpose              : This procedure will get all the parameters for Billing Region for the given project.
-- Parameters           :
--

FUNCTION Get_Tax_Amount (
                                            p_project_id                  IN     NUMBER DEFAULT NULL,
                                            p_draft_inv_num               IN     NUMBER DEFAULT NULL,
                                            p_system_reference            IN     NUMBER ,
                                            p_transfer_status_code        IN     VARCHAR2 ,
                                            p_calling_mode                IN     VARCHAR2 ,
                                            p_inv_amount                  IN     NUMBER DEFAULT NULL,
                                            p_proj_bill_amount            IN     NUMBER DEFAULT NULL,
                                            p_projfunc_bill_amount        IN     NUMBER DEFAULT NULL
                                      )  RETURN NUMBER;

-- Added for bug 4932118
Procedure PROJECT_UBR_UER_CONVERT (
        P_PROJECT_ID            IN              NUMBER,
        X_PROJECT_CURR_UBR      OUT NOCOPY            NUMBER,
        X_PROJECT_CURR_UER      OUT NOCOPY            NUMBER,
        X_RETURN_STATUS         OUT NOCOPY           VARCHAR,
        X_MSG_COUNT             OUT NOCOPY           NUMBER,
        X_MSG_DATA              OUT NOCOPY            VARCHAR );

END PA_BILLING_WORKBENCH_BILL_PKG;


 

/
