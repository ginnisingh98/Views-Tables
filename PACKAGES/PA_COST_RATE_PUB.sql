--------------------------------------------------------
--  DDL for Package PA_COST_RATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST_RATE_PUB" AUTHID CURRENT_USER AS
/* $Header: PAXPCRTS.pls 120.0 2005/05/30 19:30:17 appldev noship $*/


          g_func_curr                              gl_sets_of_books.currency_Code%TYPE;
          /*
           * Contains information for OU level Schedule Assignment.
           */
          g_ou_id                                  pa_implementations_all.org_id%TYPE;
          g_ou_org_labor_sch_rule_id               pa_org_labor_sch_rule.org_labor_sch_rule_id%TYPE;
          g_ou_cost_rate_sch_id                    pa_std_bill_rate_schedules.bill_rate_sch_id%TYPE;
          g_ou_labor_costing_rule                  pa_compensation_rule_sets.compensation_rule_set%TYPE;
          g_ou_ot_project_id                       pa_projects_all.project_id%TYPE;
          g_ou_ot_task_id                          pa_tasks.task_id%TYPE;
          g_ou_acct_rate_date_code                 pa_org_labor_sch_rule.acct_rate_date_code%TYPE;
          g_ou_acct_rate_type                      pa_org_labor_sch_rule.acct_rate_type%TYPE;
          g_ou_acct_exch_rate                      pa_org_labor_sch_rule.acct_exchange_rate%TYPE;

          /*
           * Contains information about the last processed record by the api get_labor_rate.
           */
          g_rt_calling_module                      varchar2(50);
          g_rt_organization_id                     pa_expenditures_all.incurred_by_organization_id%TYPE;
          g_rt_cost_rate                           pa_bill_rates_all.rate%TYPE;
          g_rt_start_date_active                   date;
          g_rt_end_date_active                     date;
          g_rt_org_labor_sch_rule_id               pa_org_labor_sch_rule.org_labor_sch_rule_id%TYPE;
          g_rt_costing_rule                        pa_compensation_rule_sets.compensation_rule_set%TYPE;
          g_rt_rate_sch_id                         pa_std_bill_rate_schedules_all.bill_rate_sch_id%TYPE;
          g_rt_cost_rate_curr_code                 pa_bill_rates_all.rate_currency_code%TYPE;
          g_rt_acct_rate_type                      pa_org_labor_sch_rule.acct_rate_type%TYPE;
          g_rt_acct_rate_date_code                 pa_org_labor_sch_rule.acct_rate_date_code%TYPE;
          g_rt_acct_exch_rate                      pa_org_labor_sch_rule.acct_exchange_rate%TYPE;
          g_rt_ot_project_id                       pa_projects_all.project_id%TYPE;
          g_rt_ot_task_id                          pa_tasks.task_id%TYPE;
          g_rt_err_stage                           number;
          g_rt_err_code                            varchar2(50);
          g_rt_person_id                           pa_bill_rates_all.person_id%TYPE;
          g_rt_job_id                              pa_bill_rates_all.job_id%TYPE;
          g_rt_sch_type                            pa_std_bill_rate_schedules_all.schedule_type%TYPE;


-- Start of comments
--	API name 	: get_labor_rate
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Returns Labor Cost Rate for an Employee.
--	Parameters	: Person Id, Transaction Date. Organization Id and Job Id are optional.
--	IN		:	p_person_id           	IN NUMBER        Required
--                                      Id of the person for whom the rate is to be found.
--                              p_txn_date              IN DATE          Required
--                                      The Date on which the rate is required.
--                              x_organization_id       IN NUMBER        Optional
--                                      Organization to which the transaction is charged to.
--                              x_job_id                IN NUMBER        Optional
--                                      Job of the person.
--                              p_org_id                IN NUMBER        Optional
--                                      Expenditure Org Id of the Transaction .
--	Version	: Current version	1.0
--			  Initial version 	1.0
-- End of comments
procedure get_labor_rate ( p_person_id                  IN per_all_people_f.person_id%TYPE
                          ,p_txn_date                   IN date
                          ,p_calling_module             IN varchar2 default 'STAFFED'
                          ,p_org_id                     IN pa_expenditures_all.org_id%TYPE default NULL  /*2879644*/
                          ,x_job_id                     IN OUT NOCOPY pa_expenditure_items_all.job_id%TYPE
                          ,x_organization_id            IN OUT NOCOPY pa_expenditures_all.incurred_by_organization_id%TYPE
                          ,x_cost_rate                  OUT NOCOPY pa_bill_rates_all.rate%TYPE
                          ,x_start_date_active          OUT NOCOPY date
                          ,x_end_date_active            OUT NOCOPY date
                          ,x_org_labor_sch_rule_id      OUT NOCOPY pa_org_labor_sch_rule.org_labor_sch_rule_id%TYPE
                          ,x_costing_rule               OUT NOCOPY pa_compensation_rule_sets.compensation_rule_set%TYPE
                          ,x_rate_sch_id                OUT NOCOPY pa_std_bill_rate_schedules_all.bill_rate_sch_id%TYPE
                          ,x_cost_rate_curr_code        OUT NOCOPY gl_sets_of_books.currency_code%TYPE
                          ,x_acct_rate_type             OUT NOCOPY pa_expenditure_items_all.acct_rate_type%TYPE
                          ,x_acct_rate_date_code        OUT NOCOPY pa_implementations_all.acct_rate_date_code%TYPE
                          ,x_acct_exch_rate             OUT NOCOPY pa_org_labor_sch_rule.acct_exchange_rate%TYPE
                          ,x_ot_project_id              OUT NOCOPY pa_projects_all.project_id%TYPE
                          ,x_ot_task_id                 OUT NOCOPY pa_tasks.task_id%TYPE
                          ,x_err_stage                  OUT NOCOPY number
                          ,x_err_code                   OUT NOCOPY varchar2
                          ,P_Called_From      IN varchar2 DEFAULT 'O'   /* Added for 3405326 */
                         );

PROCEDURE get_orgn_level_costing_info(
                    p_org_id                 IN     pa_implementations_all.org_id%TYPE
                   ,p_organization_id        IN     pa_expenditures_all.incurred_by_organization_id%TYPE
                   ,p_person_id              IN     pa_expenditures_all.incurred_by_person_id%TYPE
                   ,p_job_id                 IN     pa_expenditure_items_all.job_id%TYPE
                   ,p_txn_date               IN     pa_expenditure_items_all.expenditure_item_date%TYPE
                   ,p_calling_module         IN     varchar2 default 'STAFFED'
                   ,x_org_labor_sch_rule_id  IN OUT NOCOPY pa_org_labor_sch_rule.org_labor_sch_rule_id%TYPE
                   ,x_costing_rule           IN OUT NOCOPY pa_compensation_rule_sets.compensation_rule_set%TYPE
                   ,x_rate_sch_id            IN OUT NOCOPY pa_std_bill_rate_schedules.bill_rate_sch_id%TYPE
                   ,x_ot_project_id          IN OUT NOCOPY pa_projects_all.project_id%TYPE
                   ,x_ot_task_id             IN OUT NOCOPY pa_tasks.task_id%TYPE
                   ,x_cost_rate_curr_code    IN OUT NOCOPY pa_expenditure_items_all.denom_currency_code%TYPE
                   ,x_acct_rate_type         IN OUT NOCOPY pa_expenditure_items_all.acct_rate_type%TYPE
                   ,x_acct_rate_date_code    IN OUT NOCOPY pa_implementations_all.acct_rate_date_code%TYPE
                   ,x_acct_exch_rate         IN OUT NOCOPY pa_compensation_details_all.acct_exchange_rate%TYPE
                   ,x_err_stage              IN OUT NOCOPY number
                   ,x_err_code               IN OUT NOCOPY varchar2
                   ,P_Called_From      IN varchar2 DEFAULT 'O'   /* Added for 3405326 */
                  );
   -- Labor Cost Rate Reports
     --Globals for the Cache values.
   G_EMP_RATE_RULE             pa_compensation_rule_sets.compensation_rule_set%type;
   G_EMP_COST_RATE             pa_bill_rates_all.rate%type;
   G_EMP_ACCT_COST_RATE        pa_bill_rates_all.rate%type;
   G_EMP_RATE_CURR             pa_expenditure_items_all.acct_currency_code%type;
   G_EMP_RATE_START_DATE       date;
   G_EMP_RATE_END_DATE         date;

     --Globals for the Cache Attributes.
   G_EMP_PERSON_ID           per_all_people_f.person_id%type;
   G_EMP_JOB_ID              per_jobs.job_id%type;
   G_EMP_ORGANIZATION_ID     hr_organization_units.organization_id%type;

	--  Bug 3785956
   G_ORG_ID                  pa_implementations_all.org_id%TYPE;
   G_TXN_DATE                pa_expenditure_items_all.expenditure_item_date%TYPE;
   G_CALLING_MODULE          VARCHAR2(150) := 'STAFFED';


/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API name                      : GetEmpCostRate
-- Type                          : Public Function
-- Pre-reqs                      : None
-- Function                      : To get the emp cost rate.
-- Return Value                  : NUMBER
-- Prameters
-- P_Person_Id            IN    NUMBER  REQUIRED
-- P_Job_Id               IN    NUMBER  OPTIONAL
-- P_Organization_Id      IN    NUMBER  OPTIONAL
-- P_Effective_Date       IN    DATE    OPTIONAL DEFAULT SYSDATE
-- P_Rate_Type            IN    VARCHAR2 REQUIRED
--                              -- FUNC for Rate in Functional Currency
--                              -- DENOM for Rate in Denom Currency
--  History
--  03-OCT-02   Vgade                    -Created
--
/*----------------------------------------------------------------------------*/

Function GetEmpCostRate( P_Person_Id        IN per_all_people_f.person_id%type
                        ,P_Job_Id           IN pa_expenditure_items_all.job_id%type
                        ,P_Organization_Id  IN pa_expenditures_all.incurred_by_organization_id%type
                        ,P_Effective_Date   IN date default SYSDATE
                        ,P_Rate_Type        IN varchar2
                        ,P_Called_From      IN varchar2 DEFAULT 'O'   /* Added for 3405326 */
                       )
      RETURN pa_bill_rates_all.rate%type;
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API name                      : GetEmpCostRateInfo
-- Type                          : Public Function
-- Pre-reqs                      : None
-- Function                      : To get the emp cost rate attributes; COMPENSATION RULE,CURRENCY
--                                 CODE, RATE EFFECTIVE START DATE, and RATE EFFECTIVE  END DATE.
-- Return Value                  : VARCHAR2
-- Prameters
-- P_Person_Id            IN    NUMBER  REQUIRED
-- P_Job_Id               IN    NUMBER  OPTIONAL
-- P_Organization_Id      IN    NUMBER  OPTIONAL
-- P_Effective_Date       IN    DATE    OPTIONAL DEFAULT SYSDATE
-- P_Rate_Attribute       IN    VARCHAR2 REQUIRED
                                -- Valid Values
                                -- RULE for Employee Compensation Rule
                                -- CURR for Rate Currency Code
                                -- START for Rate Effective Start Date.
                                -- END  for Rate Effective End Date.
--  History
--  03-OCT-02   Vgade                    -Created
--
/*----------------------------------------------------------------------------*/

Function GetEmpCostRateInfo( P_Person_Id        IN per_all_people_f.person_id%type
                            ,P_Job_Id           IN pa_expenditure_items_all.job_id%type
                            ,P_Organization_Id  IN pa_expenditures_all.incurred_by_organization_id%type
                            ,P_Effective_Date   IN date default SYSDATE
                            ,P_Rate_Attribute   IN varchar2
                            ,P_Called_From      IN varchar2 DEFAULT 'O'   /* Added for 3405326 */
                           )
      RETURN VARCHAR2 ;
/*----------------------------------------------------------------------------*/
PROCEDURE get_orgn_lvl_cst_info_set
                     ( p_org_id_tab                 IN            pa_plsql_datatypes.IdTabTyp
                      ,p_organization_id_tab        IN            pa_plsql_datatypes.IdTabTyp
                      ,p_person_id_tab              IN            pa_plsql_datatypes.IdTabTyp
                      ,p_job_id_tab                 IN            pa_plsql_datatypes.IdTabTyp
                      ,p_txn_date_tab               IN            pa_plsql_datatypes.Char30TabTyp
                      ,p_override_type_tab          IN            pa_plsql_datatypes.Char150TabTyp
                      ,p_calling_module             IN            varchar2 default 'STAFFED'
                      ,P_Called_From                IN varchar2 DEFAULT 'O'   /* Added for 3405326 */
                      ,x_org_labor_sch_rule_id_tab  IN OUT NOCOPY pa_plsql_datatypes.IdTabTyp
                      ,x_costing_rule_tab           IN OUT NOCOPY pa_plsql_datatypes.Char150TabTyp
                      ,x_rate_sch_id_tab            IN OUT NOCOPY pa_plsql_datatypes.IdTabTyp
                      ,x_ot_project_id_tab          IN OUT NOCOPY pa_plsql_datatypes.IdTabTyp
                      ,x_ot_task_id_tab             IN OUT NOCOPY pa_plsql_datatypes.IdTabTyp
                      ,x_cost_rate_curr_code_tab    IN OUT NOCOPY pa_plsql_datatypes.Char150TabTyp
                      ,x_acct_rate_type_tab         IN OUT NOCOPY pa_plsql_datatypes.Char150TabTyp
                      ,x_acct_rate_date_code_tab    IN OUT NOCOPY pa_plsql_datatypes.Char150TabTyp
                      ,x_acct_exch_rate_tab         IN OUT NOCOPY pa_plsql_datatypes.Char30TabTyp
                      ,x_err_stage_tab              IN OUT NOCOPY pa_plsql_datatypes.NumTabTyp
                      ,x_err_code_tab               IN OUT NOCOPY pa_plsql_datatypes.Char150TabTyp
                     );
/*----------------------------------------------------------------------------*/
END PA_COST_RATE_PUB;

 

/
