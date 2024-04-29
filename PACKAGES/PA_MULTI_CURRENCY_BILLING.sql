--------------------------------------------------------
--  DDL for Package PA_MULTI_CURRENCY_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MULTI_CURRENCY_BILLING" AUTHID CURRENT_USER AS
--$Header: PAXMULTS.pls 120.2 2007/12/28 11:58:33 hkansal ship $


   -- Package Variables.

  TYPE curr_attr IS RECORD (
       conv_between       VARCHAR2(6),
       from_currency      VARCHAR2(30),
       to_currency        VARCHAR2(30),
       numerator          NUMBER,
       denominator        NUMBER,
       conv_date          DATE,        /* Added for bug 5907315 */
       rate               NUMBER);

  TYPE curr_attr_tab is TABLE of curr_attr  INDEX BY BINARY_INTEGER;
  CurrAttrTab    curr_attr_tab;

  TYPE curr_prec IS RECORD (
       curr_code varchar2(30),   -- holds global currency code
       mau       number,         -- holds global minimum accountable unit
       sp        number(1),      -- holds global precision
       ep        number(2));      -- holds global extended precision

  TYPE curr_prec_tab is TABLE of curr_prec  INDEX BY BINARY_INTEGER;
  CurrPrecTab    curr_prec_tab;


   PROCEDURE get_imp_defaults (
            x_multi_currency_billing_flag    OUT NOCOPY     VARCHAR2,
            x_share_bill_rates_across_OU     OUT NOCOPY     VARCHAR2,
            x_allow_funding_across_OU        OUT NOCOPY     VARCHAR2,
            x_default_exchange_rate_type     OUT NOCOPY     VARCHAR2,
            x_functional_currency            OUT NOCOPY     VARCHAR2,
            x_competence_match_wt            OUT NOCOPY     NUMBER,
            x_availability_match_wt          OUT NOCOPY     NUMBER,
            x_job_level_match_wt             OUT NOCOPY     NUMBER,
            x_return_status                  OUT NOCOPY     VARCHAR2,
            x_msg_count                      OUT NOCOPY     NUMBER,
            x_msg_data                       OUT NOCOPY     VARCHAR2);

   PROCEDURE get_project_defaults (
            p_project_id                  IN      NUMBER,
            x_multi_currency_billing_flag OUT NOCOPY     VARCHAR2,
            x_baseline_funding_flag       OUT NOCOPY     VARCHAR2,
            x_revproc_currency_code       OUT NOCOPY     VARCHAR2,
            x_invproc_currency_type       OUT NOCOPY     VARCHAR2,
            x_invproc_currency_code       OUT NOCOPY     VARCHAR2,
            x_project_currency_code       OUT NOCOPY     VARCHAR2,
            x_project_bil_rate_date_code  OUT NOCOPY     VARCHAR2,
            x_project_bil_rate_type       OUT NOCOPY     VARCHAR2,
            x_project_bil_rate_date       OUT NOCOPY     DATE,
            x_project_bil_exchange_rate   OUT NOCOPY     NUMBER,
            x_projfunc_currency_code      OUT NOCOPY     VARCHAR2,
            x_projfunc_bil_rate_date_code OUT NOCOPY     VARCHAR2,
            x_projfunc_bil_rate_type      OUT NOCOPY     VARCHAR2,
            x_projfunc_bil_rate_date      OUT NOCOPY     DATE,
            x_projfunc_bil_exchange_rate  OUT NOCOPY     NUMBER,
            x_funding_rate_date_code      OUT NOCOPY     VARCHAR2,
            x_funding_rate_type           OUT NOCOPY     VARCHAR2,
            x_funding_rate_date           OUT NOCOPY     DATE,
            x_funding_exchange_rate       OUT NOCOPY     NUMBER,
            x_return_status               OUT NOCOPY     VARCHAR2,
            x_msg_count                   OUT NOCOPY     NUMBER,
            x_msg_data                    OUT NOCOPY     VARCHAR2);

   FUNCTION is_project_mcb_enabled ( p_project_id    IN NUMBER)
   RETURN VARCHAR2 ;

   FUNCTION is_OU_mcb_enabled ( p_org_id    IN NUMBER)
   RETURN VARCHAR2;

   FUNCTION is_sharing_bill_rates_allowed ( p_org_id    IN NUMBER)
   RETURN VARCHAR2;

   FUNCTION is_funding_across_ou_allowed
   RETURN VARCHAR2;

   FUNCTION get_invoice_processing_cur ( p_project_id    IN NUMBER)
   RETURN VARCHAR2;

   PROCEDURE convert_amount_bulk (
          p_from_currency_tab         IN       PA_PLSQL_DATATYPES.Char30TabTyp,
          p_to_currency_tab           IN       PA_PLSQL_DATATYPES.Char30TabTyp,
          p_conversion_date_tab       IN OUT NOCOPY    PA_PLSQL_DATATYPES.DateTabTyp ,
          p_conversion_type_tab       IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
          p_amount_tab                IN       PA_PLSQL_DATATYPES.NumTabTyp,
          p_user_validate_flag_tab    IN       PA_PLSQL_DATATYPES.Char30TabTyp ,
          p_converted_amount_tab      IN OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
          p_denominator_tab           IN OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
          p_numerator_tab             IN OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
          p_rate_tab                  IN OUT    NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
          p_conversion_between        IN       VARCHAR2,
          p_cache_flag                IN       VARCHAR2,
          x_status_tab                OUT       NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp);


   PROCEDURE init_cache (p_project_id IN NUMBER);

   PROCEDURE Get_Trans_Currency_Info (
          p_curr_code     IN      VARCHAR2,
          x_mau           OUT NOCOPY      NUMBER,
          x_sp            OUT NOCOPY      NUMBER,
          x_ep            OUT NOCOPY      NUMBER);

   FUNCTION round_trans_currency_amt ( p_amount  IN NUMBER,
                                       p_Curr_Code IN VARCHAR2 ) RETURN NUMBER;


   FUNCTION check_mcb_trans_exist (p_project_id IN NUMBER) RETURN VARCHAR2;

   PROCEDURE get_project_types_dflt(
           p_project_type           IN    VARCHAR2,
           x_baseline_flag          OUT NOCOPY   VARCHAR2,
           x_nl_rt_sch_id           OUT NOCOPY   NUMBER,
           x_nl_rt_sch_name         OUT NOCOPY   VARCHAR2,
           x_rate_sch_currency_code OUT NOCOPY VARCHAR2 );

   FUNCTION check_cross_ou_fund_exist RETURN VARCHAR2;
   FUNCTION check_cross_ou_billrate_exist RETURN VARCHAR2;
   FUNCTION is_baseline_funding_enabled (p_project_id IN NUMBER) return varchar2;
   FUNCTION proj_cust_curr( p_project_id VARCHAR2,
                            p_curr_code VARCHAR2 ) return VARCHAR2 ;

----------------------------------------------------------------------------------
-- Purpose:  This function will return value 'Y' if Project Functional Currency
--           is not the same as that of invoice currency.
--
--  This function will return 'Y' if there exist any record
--  in PA_DRAFT_INVOICES_ALL table for a given Project_ID and
--  Project Functional Currency = inv_Currency_Code
--
-- Inputs: Project_ID and Project_Functional_Currency_Code
--
----------------------------------------------------------------------------------
FUNCTION MCB_Flag_Required (
  P_Project_ID          IN  PA_PROJECTS_ALL.Project_ID%TYPE,
  P_PFC_Currency_Code   IN  PA_PROJECTS_ALL.ProjFunc_Currency_Code%TYPE
)
RETURN VARCHAR2;



FUNCTION get_currency( P_org_id IN pa_implementations_all.org_id%TYPE)
   RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(get_currency, WNDS, WNPS);

G_Curr_Tab pa_utils.Char15TabTyp;

  FUNCTION Check_update_ou_mcb_flag RETURN VARCHAR2;

-- Function:   Check_mcb_setup_exists
-- Purpose :   To check project level and task multicurrency setups such as bill rates
--             and billing assignments.

FUNCTION check_mcb_setup_exists (p_project_id IN NUMBER) RETURN VARCHAR2;

/* Added the given below procedure for Enhancement bug 2520222
   It is being called from customer window of project form.
   This procedure will check if the assigned customer is having valid funding lines and
   user is trying to change existing contribution from non zero to zero then it will give error.*/

   Procedure Check_Cust_Funding_Exists(
         p_proj_customer_id         IN    NUMBER,
         p_project_id               IN    NUMBER,
         p_cust_contribution        IN    NUMBER,
         x_return_status            OUT NOCOPY   VARCHAR2,
         x_msg_data                 OUT NOCOPY   VARCHAR2,
         x_msg_count                OUT NOCOPY   NUMBER
         );

/* till here */

END PA_MULTI_CURRENCY_BILLING;

/
