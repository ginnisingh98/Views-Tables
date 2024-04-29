--------------------------------------------------------
--  DDL for Package PA_CC_BL_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_BL_PROCESS" AUTHID CURRENT_USER AS
/* $Header: PAXBLPRS.pls 120.1.12010000.3 2008/10/17 05:17:36 abjacob ship $ */


-- Type of information retrieved from pa_cc_dist_lines_all or
-- expenditure item. A record of this type is defined as opposed to
-- defining a %ROWTYPE to take advantage of getting the rowid and
-- other attributes that do not belong to the pa_cc_dist_lines_all
-- table but to the expenditure item table eliminating the need to
-- have them re-read the table. The rowid is stored for better
-- performance and to avoid hitting the index of an already retrieved
-- record (for updates and deletes)

TYPE  CcdRecType is RECORD (
    EIRowId                  rowid,
    CcdRowId                 rowid,
    expenditure_item_id      pa_cc_dist_lines_all.expenditure_item_id%TYPE,
    cc_dist_line_id          pa_cc_dist_lines_all.cc_dist_line_id%TYPE,
    adjusted_exp_item_id     pa_expenditure_items_all.adjusted_expenditure_item_id%TYPE,
    acct_currency_code       pa_cc_dist_lines_all.acct_currency_code%TYPE,
    acct_tp_exchange_rate    pa_cc_dist_lines_all.acct_tp_exchange_rate%TYPE,
    acct_tp_rate_date        pa_cc_dist_lines_all.acct_tp_rate_date%TYPE,
    acct_tp_rate_type        pa_cc_dist_lines_all.acct_tp_rate_type%TYPE,
    amount                   pa_cc_dist_lines_all.amount%TYPE,
    bill_markup_percentage   pa_cc_dist_lines_all.bill_markup_percentage%TYPE,
    bill_rate                pa_cc_dist_lines_all.bill_rate%TYPE,
    cc_rejection_code        pa_expenditure_items_all.cc_rejection_code%TYPE,
    cr_code_combination_id   pa_cc_dist_lines_all.cr_code_combination_id%TYPE,
    cross_charge_code        pa_cc_dist_lines_all.cross_charge_code%TYPE,
    denom_tp_currency_code   pa_cc_dist_lines_all.denom_tp_currency_code%TYPE,
    denom_transfer_price     pa_cc_dist_lines_all.denom_transfer_price%TYPE,
    dist_line_id_reversed    pa_cc_dist_lines_all.dist_line_id_reversed%TYPE,
    dr_code_combination_id   pa_cc_dist_lines_all.dr_code_combination_id%TYPE,
    expenditure_item_date    date,
    ind_compiled_set_id      pa_cc_dist_lines_all.ind_compiled_set_id%TYPE,
    line_num                 pa_cc_dist_lines_all.line_num%TYPE,
    line_num_reversed        pa_cc_dist_lines_all.line_num_reversed%TYPE,
    line_type                pa_cc_dist_lines_all.line_type%TYPE,
    markup_calc_base_code    pa_cc_dist_lines_all.markup_calc_base_code%TYPE,
    pa_date                  pa_cc_dist_lines_all.pa_date%TYPE,
    gl_date                  pa_cc_dist_lines_all.gl_date%TYPE,                         /* EPP */
    pa_period_name           pa_cc_dist_lines_all.pa_period_name%TYPE,                  /* EPP */
    gl_period_name           pa_cc_dist_lines_all.gl_period_name%TYPE,                  /* EPP */
    project_id               pa_cc_dist_lines_all.project_id%TYPE,
    reversed_flag            pa_cc_dist_lines_all.reversed_flag%TYPE,
    rule_percentage          pa_cc_dist_lines_all.rule_percentage%TYPE,
    schedule_line_percentage pa_cc_dist_lines_all.schedule_line_percentage%TYPE,
    task_id                  pa_cc_dist_lines_all.task_id%TYPE,
    tp_base_amount           pa_cc_dist_lines_all.tp_base_amount%TYPE,
    tp_job_id                pa_cc_dist_lines_all.tp_job_id%TYPE,
    upd_type                 VARCHAR2(1),
    reference_1              pa_cc_dist_lines_all.reference_1%TYPE,
    reference_2              pa_cc_dist_lines_all.reference_2%TYPE,
    reference_3              pa_cc_dist_lines_all.reference_3%TYPE,

    /* Added for cross proj*/
    tp_amt_type_code         pa_cc_dist_lines_all.tp_amt_type_code%TYPE ,
    project_tp_rate_type        pa_cc_dist_lines_all.project_tp_rate_type%TYPE,
    project_tp_rate_date        pa_cc_dist_lines_all.project_tp_rate_date%TYPE,
    project_tp_exchange_rate    pa_cc_dist_lines_all.project_tp_exchange_rate%TYPE,
    project_transfer_price      pa_cc_dist_lines_all.project_transfer_price%TYPE,
    projfunc_tp_rate_type    pa_cc_dist_lines_all.projfunc_tp_rate_type%TYPE,
    projfunc_tp_rate_date    pa_cc_dist_lines_all.projfunc_tp_rate_date%TYPE,
    projfunc_tp_exchange_rate pa_cc_dist_lines_all.projfunc_tp_exchange_rate%TYPE,
    projfunc_transfer_price  pa_cc_dist_lines_all.projfunc_transfer_price%TYPE,

    project_tp_currency_code  pa_cc_dist_lines_all.project_tp_currency_code%TYPE,
    projfunc_tp_currency_code pa_cc_dist_lines_all.projfunc_tp_currency_code%TYPE
    /* End for cross proj*/

 );

-- Declare a type for table of above record type
TYPE  CcdTabType IS TABLE OF CcdRecType
                    INDEX BY BINARY_INTEGER;

-- Declare a type for holding information about deleted
-- pa_cc_dist_lines. For deletion of records in the main schema, the
-- only thing required is the rowid. For the MRC schema, the line id
-- is required

TYPE DelRecType  IS RECORD
 (
  CcdRowId           rowid,
  cc_dist_line_id    pa_cc_dist_lines_all.cc_dist_line_id%TYPE
 );

-- Declare a type for the table of delete record type
TYPE DelTabType  IS TABLE OF DelRecType
                    INDEX BY BINARY_INTEGER;


-- Declare INSert, UPDate, DELete record types for pa_cc_dist_lines.
-- The table holding attributes of EIs to be updated also has the same
-- type as the ins/upd for pa_cc_dist_lines because most of the
-- attributes to be updated are the same

  g_ins_rec                 CcdTabType;
  g_upd_rec                 CcdTabType;
  g_del_rec                 DelTabType;
  g_ei_rec                  CcdTabType;

-- Keeps track of updates to global arrays
  g_ucnt                    NUMBER;  -- Update counter
  g_icnt                    NUMBER;  -- Insert counter
  g_dcnt                    NUMBER;  -- Delete counter

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_cc_bl_process.pa_bl_pr
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure is called from the Distribute Borrowed and Lent
--                Amounts process.
--                It accepts a set of Expenditure Items and its attributes from
--                the Pro*C program.  These attributes include the accounting
--                for the items. It then calls the Transfer Price API to
--                determine the Transfer Price where required and then
--                creates distributions for these Items.
--
--                It also calls procedures to create records in the
--                reporting sets of books for the operating unit
--
-- Parameters   : Please see specification below
--
-- Version      : Initial version
--
-- End of comments
----------------------------------------------------------------------------------

PROCEDURE pa_bl_pr
        (
         p_module_name                  IN  VARCHAR2
        ,p_debug_mode                   IN  VARCHAR2
        ,p_acct_currency_code           IN  OUT NOCOPY pa_expenditure_items_all.acct_currency_code%TYPE
        ,p_acct_tp_exchange_rate        IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_acct_tp_rate_date            IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_acct_tp_rate_type            IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_acct_transfer_price          IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_adjusted_exp_item_id         IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_array_size                   IN  Number
        ,p_cc_markup_base_code          IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_cc_rejection_code            IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_compute_flag                 IN  PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_cr_code_combination_id       IN  OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
        ,p_cross_charge_code            IN  PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_denom_burdened_cost_amount   IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_denom_currency_code          IN  PA_PLSQL_DATATYPES.Char15TabTyp
        ,p_denom_raw_cost_amount        IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_denom_tp_currency_code       IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char15TabTyp
        ,p_denom_transfer_price         IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_dr_code_combination_id       IN  OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
        ,p_exp_item_rowid               IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_expenditure_category         IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_expenditure_item_date        IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_expenditure_item_id          IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_expenditure_type             IN  PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_expnd_organization_id        IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_incurred_by_person_id        IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_job_id                       IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_labor_non_labor_flag         IN  PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_login_id                     IN  NUMBER
        ,p_net_zero_flag                IN  PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_nl_resource_organization_id  IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_non_labor_resource           IN  PA_PLSQL_DATATYPES.Char20TabTyp
        ,p_pa_date                      IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_gl_date                      IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_pa_period_name               IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_gl_period_name               IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_primary_sob_id               IN  gl_sets_of_books.set_of_books_id%TYPE
        ,p_processed_thru_date          IN  Date
        ,p_program_application_id       IN  NUMBER
        ,p_program_id                   IN  NUMBER
        ,p_project_currency_code        IN  PA_PLSQL_DATATYPES.Char15TabTyp
        ,p_project_id                   IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_prvdr_org_id                 IN  pa_implementations_all.org_id%TYPE
        ,p_prvdr_organization_id        IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_quantity                     IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_raw_revenue_amount           IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_recvr_org_id                 IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_recvr_organization_id        IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_request_id                   IN  NUMBER
        ,p_revenue_distributed_flag     IN  PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_system_linkage_function      IN  PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_task_id                      IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_tp_base_amount               IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_tp_bill_markup_percentage    IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_tp_bill_rate                 IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_tp_fixed_date                IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_tp_ind_compiled_set_id       IN  OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
        ,p_tp_job_id                    IN  OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
        ,p_tp_rule_percentage           IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_tp_schedule_id               IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_tp_schedule_line_percentage  IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_user_id                      IN  NUMBER
/*Added for cross proj*/
        ,p_tp_amt_type_code            IN  PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_assignment_id               IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_projfunc_currency_code      IN  PA_PLSQL_DATATYPES.Char15TabTyp
        ,p_project_tp_rate_type        IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_project_tp_rate_date        IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_project_tp_exchange_rate    IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
    	,p_projfunc_tp_rate_type       IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
    	,p_projfunc_tp_rate_date       IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
    	,p_projfunc_tp_exchange_rate   IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,

/* Bill rate Discount*/
        p_dist_rule                     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_mcb_flag                      IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_bill_rate_multiplier          IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_raw_cost                      IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_labor_schdl_discnt            IN       PA_PLSQL_DATATYPES.Char30TabTyp, /* bug#3221791 */
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
/* Added for UOM enhancement */
        p_uom_flag                      IN       PA_PLSQL_DATATYPES.NumTabTyp
						   DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab
        );

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_cc_bl_process.mass_update
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure is called from the Distribute Borrowed and Lent
--                Amounts package and the InterCompany Invoicing process.
--                The former calls it to update Borrowed and Lent lines in
--                the pa_cc_dist_lines_table while the latter for updating
--                provider reclassification entries.  MRC for both processes
--                is performed through this API.
--
--                The API requires certain variables in the pa_cc_utils
--                package to be set.  The records to be UPDATEd have
--                to be populated in the g_upd_rec table of records.
--
-- Parameters   : Please see specification below
--
-- Version      : Initial version
--
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE mass_update;

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_cc_bl_process.mass_insert
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure is called from the Distribute Borrowed and Lent
--                Amounts package and the InterCompany Invoicing process.
--                The former calls it to insert Borrowed and Lent lines in
--                the pa_cc_dist_lines_table while the latter for creating
--                provider reclassification entries.  MRC for both processes
--                is performed through this API.
--
--                The API requires certain variables in the pa_cc_utils
--                package to be set.  The records to be INSERTed have
--                to be populated in the g_ins_rec table of records.
--
-- Parameters   : Please see specification below
--
-- Version      : Initial version
--
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE mass_insert;

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_cc_bl_process.mass_delete
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure is called from the Distribute Borrowed and Lent
--                Amounts package and the InterCompany Invoicing process.
--                The former calls it to delete Borrowed and Lent lines in
--                the pa_cc_dist_lines_table while the latter for deleting
--                provider reclassification entries.  MRC for both processes
--                is performed through this API (i.e. the corresponding MRC
--                records are deleted).
--
--                The API requires certain variables in the pa_cc_utils
--                package to be set.  The records to be DELETEd have
--                to be populated in the g_del_rec table of records.
--
-- Parameters   :
--              Please see specification below
--
-- Version      : Initial version
--
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE mass_delete;
--

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_cc_bl_process.initialization
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure is called from the Distribute Borrowed and Lent
--                Amounts package and the InterCompany Invoicing process.
--                Both procedures call it prior to performing any functions.
--                The package initializes global variables used by other
--                procedures within this package.  Another function of this
--                package is to determine the reporting sets of books for
--                the current operating unit.
--
-- Parameters   : Please see specification below
--
-- Version      : Initial version
--
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE initialization(
                           p_request_id              IN NUMBER
                          ,p_program_application_id  IN NUMBER
                          ,p_program_id              IN NUMBER
                          ,p_user_id                 IN NUMBER
                          ,p_login_id                IN NUMBER
                          ,p_prvdr_org_id            IN NUMBER
                          ,p_primary_sob_id          IN NUMBER
                       );

END PA_CC_BL_process;

/
