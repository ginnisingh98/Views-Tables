--------------------------------------------------------
--  DDL for Package PA_INVOICE_DETAIL_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_INVOICE_DETAIL_PROCESS" AUTHID CURRENT_USER as
/* $Header: PAICINDS.pls 120.0 2005/05/30 19:50:48 appldev noship $*/

--
-- Table to store the project type - Cost Accrual/Non Cost Accrual
--
G_project_category             PA_PLSQL_DATATYPES.Char1TabTyp;


/* Cursor to get CC Distribution */
cursor get_cc_dist ( l_exp_item_id    IN  NUMBER )
is
    SELECT  CCDIST.rowid,CCDIST.*
    FROM    PA_CC_DIST_LINES CCDIST
    WHERE   CCDIST.EXPENDITURE_ITEM_ID = l_exp_item_id
    AND     CCDIST.LINE_NUM      = ( SELECT MAX(L.LINE_NUM)
                                     FROM   PA_CC_DIST_LINES L
                                     WHERE  L.EXPENDITURE_ITEM_ID =
                                                  CCDIST.EXPENDITURE_ITEM_ID);

--
-- This package will create invoice details and provider reclass entry
-- Parameter  :
--	 P_Project_Id                 - Project Id
--       P_Draft_Inv_Num              - Draft Invoice Number
--       P_Customer_Id                - Customer Id
--       P_Bill_to_site_use_id        - Bill to site Use id
--       P_Ship_to_site_use_id        - Ship to Site Use id
--       P_Sets_of_books_id           - Sets of Books Id
--       P_User_Id                    - User Id
--       P_Request_id                 - Request Id
--       P_TP_sch_line_id             - Transfer Price Schedule Line Id
--       P_revenue_ccid               - Revenue account ccid
--       P_Cross_charge_code          - Cross Charge Code
--
--
PROCEDURE process_invoice_details
           ( P_Project_Id          IN   number  ,
             P_Customer_Id         IN   number,
             P_Bill_to_site_use_id IN   number,
             P_Ship_to_site_use_id IN   number ,
             P_Set_of_books_id     IN   number ,
             P_Acct_curr_code      IN   varchar2 ,
             P_Expenditure_category IN  PA_PLSQL_DATATYPES.Char30TabTyp,
             P_CC_Project_Id       IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_CC_Tax_task_id      IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_EI_id               IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_AdjEI_id            IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Net_zero_flag       IN   PA_PLSQL_DATATYPES.Char1TabTyp ,
             P_TP_sch_id           IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_revenue_ccid        IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_provider_cr_ccid    IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_provider_dr_ccid    IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Task_id             IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Cross_charge_code   IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Labor_nl_flag       IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Revenue_distributed_flag
                                   IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Expend_type         IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_EI_date             IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Sys_linkage         IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_currency_code IN   PA_PLSQL_DATATYPES.Char15TabTyp  ,
             P_Prj_currency_code   IN   PA_PLSQL_DATATYPES.Char15TabTyp  ,
             P_TP_fixed_date       IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_raw_cost_amt  IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_burdened_cost_amt
                                   IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Raw_revenue_amt     IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Quantity            IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Non_labor_resource  IN   PA_PLSQL_DATATYPES.Char20TabTyp  ,
             P_Prvdr_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Recvr_org_id        IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Recvr_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Expnd_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_NL_resource_organization
                                   IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Incurred_by_person_id
                                   IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Job_id              IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Denom_TP_currency_code
                                   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char15TabTyp ,
             P_Denom_transfer_price
                                   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_rate_type   IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_rate_date   IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_exchange_rate
                                   IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_transfer_price IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_CC_markup_base_code IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_ind_compiled_set_id
                                   IN OUT   NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
             P_TP_bill_rate        IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_base_amt         IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_bill_markup_percentage
                                   IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_schedule_line_percentage
                                   IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_rule_percentage  IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_burden_disp_method  IN       PA_PLSQL_DATATYPES.Char1TabTyp ,
             P_ca_prov_code        IN   Varchar2,
             P_nca_prov_code       IN   Varchar2,
             P_Processed_thru_date IN   Date ,
             P_No_of_records       IN   NUMBER  ,
             P_User_Id             IN   NUMBER  ,
             P_Request_id          IN   NUMBER  ,
             P_Error_Code      IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
             P_tp_job_id       IN OUT  NOCOPY   PA_PLSQL_DATATYPES.IdTabTyp,
             P_prov_proj_bill_job_id
                                IN OUT  NOCOPY   PA_PLSQL_DATATYPES.IdTabTyp,
/*Added for cross proj*/
             P_tp_amt_type_code        IN       PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_currency_code  IN       PA_PLSQL_DATATYPES.Char15TabTyp ,
             P_project_tp_rate_type    IN OUT NOCOPY    PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_project_tp_rate_date    IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_project_tp_exchange_rate    IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_tp_rate_type   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_tp_rate_date   IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_tp_exchange_rate   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_assignment_id           IN       PA_PLSQL_DATATYPES.IdTabTyp,
             P_project_transfer_price   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_transfer_price   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp,
/*End for cross proj*/
/* Bill rate Discount*/
        p_dist_rule                     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_mcb_flag                      IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_bill_rate_multiplier          IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_raw_cost                      IN       PA_PLSQL_DATATYPES.Char30TabTyp,
    /*  p_labor_schdl_discnt            IN       PA_PLSQL_DATATYPES.NumTabTyp, Commented for bug 3252190 */
        p_labor_schdl_discnt            IN       PA_PLSQL_DATATYPES.Char30TabTyp, /* Changed the data type from Num to char for bug3252190 */
        p_labor_schdl_fixed_date        IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_bill_job_grp_id               IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_labor_sch_type                IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_project_org_id                IN       PA_PLSQL_DATATYPES.NumTabTyp ,
        p_project_type                  IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_exp_func_curr_code            IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_incurred_by_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_raw_cost_rate                 IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_override_to_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_emp_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_job_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_exp_raw_cost                  IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_assignment_precedes_task      IN       PA_PLSQL_DATATYPES.Char1TabTyp,

        p_burden_cost                   IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_task_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp,
        p_proj_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp,
        p_task_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_proj_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_nl_sch_type                   IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_nl_task_sch_date              IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_nl_proj_sch_date              IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_nl_task_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_nl_proj_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp,
        /* Added the last two parameters for Doosan Rate api changes */
        p_task_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_proj_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_uom_flag                      IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab
				);

/* !!!!This is overloaded procedure for compilation of pro*c files of Patchset H */
/* !!!!Note: This .pls with overload function should not be sent along with the patch for Patchset H customers */
PROCEDURE process_invoice_details
           ( P_Project_Id          IN   number  ,
             P_Customer_Id         IN   number,
             P_Bill_to_site_use_id IN   number,
             P_Ship_to_site_use_id IN   number ,
             P_Set_of_books_id     IN   number ,
             P_Acct_curr_code      IN   varchar2 ,
             P_Expenditure_category IN  PA_PLSQL_DATATYPES.Char30TabTyp,
             P_CC_Project_Id       IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_CC_Tax_task_id      IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_EI_id               IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_AdjEI_id            IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Net_zero_flag       IN   PA_PLSQL_DATATYPES.Char1TabTyp ,
             P_TP_sch_id           IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_revenue_ccid        IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_provider_cr_ccid    IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_provider_dr_ccid    IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Task_id             IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Cross_charge_code   IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Labor_nl_flag       IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Revenue_distributed_flag
                                   IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Expend_type         IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_EI_date             IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Sys_linkage         IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_currency_code IN   PA_PLSQL_DATATYPES.Char15TabTyp  ,
             P_Prj_currency_code   IN   PA_PLSQL_DATATYPES.Char15TabTyp  ,
             P_TP_fixed_date       IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_raw_cost_amt  IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_burdened_cost_amt
                                   IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Raw_revenue_amt     IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Quantity            IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Non_labor_resource  IN   PA_PLSQL_DATATYPES.Char20TabTyp  ,
             P_Prvdr_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Recvr_org_id        IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Recvr_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Expnd_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_NL_resource_organization
                                   IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Incurred_by_person_id
                                   IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Job_id              IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Denom_TP_currency_code
                                   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char15TabTyp ,
             P_Denom_transfer_price
                                   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_rate_type   IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_rate_date   IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_exchange_rate
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_transfer_price IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_CC_markup_base_code IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_ind_compiled_set_id
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
             P_TP_bill_rate        IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_base_amt         IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_bill_markup_percentage
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_schedule_line_percentage
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_rule_percentage  IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_burden_disp_method  IN        PA_PLSQL_DATATYPES.Char1TabTyp ,
             P_ca_prov_code        IN   Varchar2,
             P_nca_prov_code       IN   Varchar2,
             P_Processed_thru_date IN   Date ,
             P_No_of_records       IN   NUMBER  ,
             P_User_Id             IN   NUMBER  ,
             P_Request_id          IN   NUMBER  ,
             P_Error_Code      IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             P_tp_job_id       IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
             P_prov_proj_bill_job_id
	     IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp);


/* !!!!This is overloaded procedure for compilation of pro*c files of Patchset J */
/* !!!!Note: This .pls with overload function should not be sent along with the patch for Patchset J customers */

PROCEDURE process_invoice_details
           ( P_Project_Id          IN   number  ,
             P_Customer_Id         IN   number,
             P_Bill_to_site_use_id IN   number,
             P_Ship_to_site_use_id IN   number ,
             P_Set_of_books_id     IN   number ,
             P_Acct_curr_code      IN   varchar2 ,
             P_Expenditure_category IN  PA_PLSQL_DATATYPES.Char30TabTyp,
             P_CC_Project_Id       IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_CC_Tax_task_id      IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_EI_id               IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_AdjEI_id            IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Net_zero_flag       IN   PA_PLSQL_DATATYPES.Char1TabTyp ,
             P_TP_sch_id           IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_revenue_ccid        IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_provider_cr_ccid    IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_provider_dr_ccid    IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Task_id             IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Cross_charge_code   IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Labor_nl_flag       IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Revenue_distributed_flag
                                   IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Expend_type         IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_EI_date             IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Sys_linkage         IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_currency_code IN   PA_PLSQL_DATATYPES.Char15TabTyp  ,
             P_Prj_currency_code   IN   PA_PLSQL_DATATYPES.Char15TabTyp  ,
             P_TP_fixed_date       IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_raw_cost_amt  IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_burdened_cost_amt
                                   IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Raw_revenue_amt     IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Quantity            IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Non_labor_resource  IN   PA_PLSQL_DATATYPES.Char20TabTyp  ,
             P_Prvdr_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Recvr_org_id        IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Recvr_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Expnd_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_NL_resource_organization
                                   IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Incurred_by_person_id
                                   IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Job_id              IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Denom_TP_currency_code
                                   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char15TabTyp ,
             P_Denom_transfer_price
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_rate_type   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_rate_date   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_exchange_rate
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_transfer_price IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_CC_markup_base_code IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_ind_compiled_set_id
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
             P_TP_bill_rate        IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_base_amt         IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_bill_markup_percentage
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_schedule_line_percentage
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_rule_percentage  IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_burden_disp_method  IN       PA_PLSQL_DATATYPES.Char1TabTyp ,
             P_ca_prov_code        IN   Varchar2,
             P_nca_prov_code       IN   Varchar2,
             P_Processed_thru_date IN   Date ,
             P_No_of_records       IN   NUMBER  ,
             P_User_Id             IN   NUMBER  ,
             P_Request_id          IN   NUMBER  ,
             P_Error_Code      IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp,
             P_tp_job_id       IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
             P_prov_proj_bill_job_id
                                IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
/*Added for cross proj*/
             P_tp_amt_type_code        IN       PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_currency_code  IN       PA_PLSQL_DATATYPES.Char15TabTyp ,
             P_project_tp_rate_type    IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_project_tp_rate_date    IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_project_tp_exchange_rate    IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_tp_rate_type   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_tp_rate_date   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_tp_exchange_rate   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_assignment_id           IN       PA_PLSQL_DATATYPES.IdTabTyp,
             P_project_transfer_price   IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_transfer_price   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
/*End for cross proj*/
                                );
--Procedure to initialize global counter
PROCEDURE init;

--Procedure to add record in update buffer
/* Added the parameter p_adjusted_ei for bug 2770182 */

PROCEDURE reverse_row ( p_inv_rec  IN OUT   NOCOPY pa_draft_invoice_details%rowtype,
                        p_adjusted_ei IN NUMBER DEFAULT NULL );

-- Apply all pending insert changes in Bulk
PROCEDURE apply_ins_changes ;

-- Procedure to reverse crosscharge distribution
PROCEDURE reverse_cc_dist ( P_INV_DET_ID   IN NUMBER,
                            P_EI_DATE      IN DATE,
                            P_Sys_linkage  IN VARCHAR2,  /* Added for 3857986 */
                            P_CC_REC       IN OUT  NOCOPY get_cc_dist%rowtype,
                            P_index        IN number);

-- Procedure to reverse the provider reclass entries
-- from invoice cancellation
--
PROCEDURE reverse_preclass (
  P_inv_detail_id        PA_PLSQL_DATATYPES.IdTabTyp,
  P_new_inv_detail_id    PA_PLSQL_DATATYPES.IdTabTyp,
  P_EI_id                PA_PLSQL_DATATYPES.IdTabTyp,
  P_EI_date              PA_PLSQL_DATATYPES.Char30TabTyp,
  P_Sys_Linkage          PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for 3857986 */
  P_tab_count            NUMBER);

END PA_INVOICE_DETAIL_PROCESS;

 

/
