--------------------------------------------------------
--  DDL for Package PAY_AU_RECON_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_RECON_SUMMARY" AUTHID CURRENT_USER as
/*  $Header: pyauprec.pkh 120.1.12010000.8 2009/11/27 15:55:11 skshin ship $*/

/*
*** ------------------------------------------------------------------------+
*** Program:     pay_au_recon_summary (Package Header)
***
*** Change History
***
*** Date       Changed By  Version  Description of Change
*** ---------  ----------  -------  ----------------------------------------+
*** 07 APR 03  apunekar    1.1      Initial version
*** 18 Jun 03  Ragovind    1.3      Bug#3004966 - Performance Fix
*** 20 Jun 03  Ragovind    1.4      Bug#3004966 - Fix for Performance Improvement
*** 02 Jul 03  JLin        1.5      Bug 3034189 - Added g_fbt_defined_balance_id
*** 20-OCT-03  punmehta    115.6    Bug#3193479 - Implemented Batch Balance Retrieval. for that created new function to populate
***                                 global plsql table and other functions gets the balance value from this function.
*** 21-OCT-03  punmehta    115.7    Bug#3193479 - Modified OUT with OUT NOCOPY
*** 23-OCT-03  punmehta    115.8    Bug#3213539 - Modified get_total_fbt defination
*** 23-OCT-03  punmehta    115.9    Bug#3213539 - Modified comment
*** 27-OCT-03  vgsriniv    115.10   Bug#3215982 - Varible g_index is declared and initialized to zero
*** 22-Nov-03  punmehta    115.11   Bug#3263659 - Removed unused arguments from function declarations.
*** 10-Feb-04  punmehta    115.12   Bug#3098367 - Added check to not report if all balances are zero.
*** 08-Mar-04  srrajago    115.13   Bug#3186840 - Declared PL/SQL tables.In 'populate_bal_ids', included a parameter l_le_level.
***                                 Introduced procedures 'get_group_values_bbr','get_assgt_curr_term_values_bbr',
***                                 'populate_group_def_bal_ids' and 'get_group_assgt_values_bbr'.
*** 29-Mar-04  srrajago    115.14   Bug#3186840 - Removed the procedure 'get_group_assgt_values_bbr'.
*** 11-Jun-04  punmehta    115.18   Bug#3686549 - Added a new parameter and logic to take more then 1 yrs term employees
*** 11-Jun-04  punmehta    115.19   Bug#3686549 - Modified for GSCC warnings
*** 21-Jun-04  punmehta    115.20   Bug#3693034 - Added default null to paramater
*** 07-Jul-04  punmehta    115.21   Bug#3749530 - Added archival model to archive assignment_actions for performance
*** 09-Aug-04  abhkumar    115.22   Bug#2610141 - Legal Employer enhancement changes.
*** 30-Dec-04  avenkatk    115.23   Bug#3899641 - Added Functional Dependancy comment.
*** 18-Jan-05 hnainani     115.23   Bug#4015082 - Workplace Giving Deductions
*** 06-DEC-05 abhkumar     115.25   Bug#4863149   Modified the code to raise error message when there is no defined balance id for the allowance balance.
*** 02-DEC-08  skshin      115.26   Bug#7571001   Added new pl/sql tables and modified function parameters for allowance balance group level reporting
*** 28-JAN-09  skshin      115.28   Bug#7571001   Corrected check_file error of multiple comments on the same line
*** 23-JUN-09  pmatamsr    115.29   Bug#8587013   Added functions 'Total_RESC','Total_Foreign_Income' and removed 'Total_Other_Income'.
*** 07-SEP-09  pmatamsr    115.30   Bug#8769345   Added global variables to hold the values of ETP taxbale and Tax Free payments balances
*** 19-NOV-09  skshin      115.32   Bug#8711855   Added global variables for retro GT12 balances (Lump Sum E)
*/
   /* Bug#3004966 */
   g_ttd_count number :=1;
   g_lump_sum_c_bal_typ_id pay_balance_types.balance_type_id%type;
   g_term_ded_bal_typ_id pay_balance_types.balance_type_id%type;
   g_tot_tax_ded_bal_typ_id pay_balance_types.balance_type_id%type;
   /* End Bug#3004966 */
   g_index number:=0; /* Bug#3215982  */
   /* Bug 3034198 */
   g_fbt_defined_balance_id  pay_defined_balances.defined_balance_id%TYPE :=0;
   /* End bug 3034189 */

   /*------- Bug# 3193479 ---------------------------------------------------------------*/

   g_input_table    pay_balance_pkg.t_balance_value_tab;
   g_result_table   pay_balance_pkg.t_detailed_bal_out_tab;
   g_context_table  pay_balance_pkg.t_context_tab;

   /* Start of Bug : 3186840*/

   g_input_term_details_table    pay_balance_pkg.t_balance_value_tab;
   g_result_term_details_table   pay_balance_pkg.t_detailed_bal_out_tab;

   g_input_group_details_table    pay_balance_pkg.t_balance_value_tab;
   g_result_group_details_table   pay_balance_pkg.t_detailed_bal_out_tab;

   g_input_grp_assgt_dets_table    pay_balance_pkg.t_balance_value_tab;
   g_result_grp_assgt_dets_table   pay_balance_pkg.t_detailed_bal_out_tab;


   g_bal_dim_level    varchar2(1);
   g_dimension_name   pay_balance_dimensions.dimension_name%TYPE;

   /* End of Bug : 3186840 */

   /* start bug 7571001 */
   g_input_alw_table    pay_balance_pkg.t_balance_value_tab;
   g_result_alw_table   pay_balance_pkg.t_detailed_bal_out_tab;

   g_input_group_alw_table  pay_balance_pkg.t_balance_value_tab;
   g_result_group_alw_table pay_balance_pkg.t_detailed_bal_out_tab;
   /* end bug 7571001 */

TYPE
   g_bal_type_tab IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER; /*Bug#4863149*/

   TYPE bal_type_ids is record
   (balance_value          NUMBER
   );
   type bal_tab is table of bal_type_ids index by binary_integer;
   bal_id bal_tab;

   -- Procedure for Batch Balance Retrieval
   PROCEDURE get_value_bbr(c_year_start           DATE,
              c_year_end             DATE,
                          c_assignment_id        pay_assignment_actions.assignment_id%type,
                          c_fbt_rate         ff_globals_f.global_value%TYPE,
                          c_ml_rate      ff_globals_f.global_value%TYPE,
              p_assignment_action_id pay_assignment_actions.assignment_id%type,
              p_tax_unit_id          hr_all_organization_units.organization_id%TYPE,
              p_termination_date     DATE, --Bug 3098367
              p_display_flag     OUT NOCOPY VARCHAR2, --Bug 3098367
              p_output_tab       OUT NOCOPY bal_tab
   --, p_message OUT NOCOPY VARCHAR2); /* bug 7571001 - removed the parameter */
              );

   -- TO return the value from plsql table populated by BBR
   function get_bal_value_new(p_defined_balance_id     pay_defined_balances.defined_balance_id%TYPE)
        return number;

   g_db_id_fbt  pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_cdep pay_defined_balances.defined_balance_id%TYPE;
  g_db_id_wgd  pay_defined_balances.defined_balance_id%TYPE; /* 4015082 */
   g_db_id_et   pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_lsad pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_lsap pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_lsbp pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_lsbd pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_lsdp pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_lsep pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_lscp pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_lscd pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_ttd  pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_uf   pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_ip   pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_lpm  pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_td   pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_oi pay_defined_balances.defined_balance_id%TYPE;
   /*Begin 8587013 - Added global variables to hold the values of RESC and Exempt Foreign Employment Income balances*/
   g_db_id_resc pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_efei pay_defined_balances.defined_balance_id%TYPE;
   /*End 8587013*/
   /* Start 8769345 */
   g_db_id_tftn pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_tftp pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_tfln pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_tflp pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_ttn pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_ttp pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_tln pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_tlp pay_defined_balances.defined_balance_id%TYPE;
   /* End 8769345 */
   /* Start 8711855 */
   g_db_id_rll pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_res pay_defined_balances.defined_balance_id%TYPE;
   g_db_id_rpt pay_defined_balances.defined_balance_id%TYPE;
   /* End 8711855 */

   /*--------end of Bug# 3193479---------------------------------------------------------------*/


   g_lst_yr_term varchar2(10);--Bug:3686549

   type exclusion_asg is record
             (employee_name          per_all_people_f.full_name%type,
              assignment_number      per_all_assignments_f.assignment_number%type,
              assignment_id          per_all_assignments_f.assignment_id%type,
              reason varchar2(100)
              );

   type exc_table is table of exclusion_asg index by binary_integer;

   exc_tab1 exc_table;

  --Bug#3749530 - Function modified to set globals parmaters
   function populate_bal_ids(p_le_level IN varchar2 DEFAULT NULL,
                         p_business_group_id hr_organization_units.organization_id%type,
                 p_lst_yr_term VARCHAR2 DEFAULT NULL )  return number; -- Bug : 3186840

   Function total_gross  -- Bug 3263659
   return number;

/* bug 7571001 - added for adjusting allowance */
  function adjust_retro_group_allowances(t_allowance_balance IN OUT NOCOPY pay_au_payment_summary.t_allowance_balance%type
     ,p_year_start              in   DATE
     ,p_year_end                in   DATE
     ,p_registered_employer     in   NUMBER
     )
  return number;

/* bug 7571001 - p_meesage introduced by 4863149 is removed */
  Function get_total_allowances ( p_year_start           DATE,
                                                            p_year_end             DATE,
                                                            p_assignment_id        pay_assignment_actions.assignment_id%type,
                                                            p_assignment_action_id pay_assignment_actions.assignment_id%type,
                                                            p_tax_unit_id          hr_all_organization_units.organization_id%type)
    return number;



   Function get_total_fbt(c_year_start             DATE,        --Bug#3213539
                          c_assignment_id        pay_assignment_actions.assignment_id%type,
                  p_tax_unit_id hr_all_organization_units.organization_id%TYPE,
                          c_fbt_rate ff_globals_f.global_value%TYPE,
                          c_ml_rate ff_globals_f.global_value%TYPE,
              p_termination VARCHAR2)
   return number ;


   function get_total_cdep -- Bug 3263659
   return number ;

 function get_total_workplace -- Bug 4015082
   return number ;


   function Total_Lump_Sum_A_Payments    -- Bug 3263659
   return number ;

   function Total_Lump_Sum_B_Payments -- Bug 3263659
   return number ;

   function Total_Lump_Sum_D_Payments  -- Bug 3263659
   return number ;

   function Total_Lump_Sum_E_Payments(c_year_end             DATE,
                                      c_assignment_id        pay_assignment_actions.assignment_id%type,
                                      c_registered_employer  NUMBER) --2610141
   return number ;

   function Total_Union_fees  -- Bug 3263659
   return number ;


   function Total_Tax_deductions  -- Bug 3263659
   return number ;


   function Total_RESC  -- Bug 8587013
   return number ;

   function Total_Foreign_Income  -- Bug 8587013
   return number ;

   function Total_Invalidity_Payments  -- Bug 3263659
   return number ;

   function etp_details
       (p_assignment_id          in   pay_assignment_actions.ASSIGNMENT_ID%type
       ,p_year_start             in   pay_payroll_Actions.effective_date%type
       ,p_year_end               in   pay_payroll_Actions.effective_date%type)
   return number;

   function post30jun1983_value
   return number;

   function etp_gross
   return number;

   function assessable_income
   return number;

   function etp_tax
   return number;

   function get_exclusion_info(flag varchar2 ,p_assignment_id number) return varchar2;

   function get_assignment_id(p_assignment_id number) return number;

   function populate_exclusion_table(p_assignment_id per_all_assignments_f.assignment_id%type,
                                     p_financial_year varchar2,
                                     p_financial_year_end date,
                     p_tax_unit_id number --2610141
                                    )
   return number ;


   /* Start of Bug : 3186840 */

   PROCEDURE populate_group_def_bal_ids (p_dimension_name  IN  pay_balance_dimensions.dimension_name%TYPE
                                                                                   ,p_business_group_id per_business_groups.business_group_id%TYPE);  -- bug 7571001

   PROCEDURE get_group_values_bbr
               (p_year_start           DATE
               ,p_year_end             DATE
               ,p_assignment_action_id  IN  pay_assignment_actions.assignment_action_id%TYPE  DEFAULT NULL
             , p_date_earned           IN  date
             , p_tax_unit_id           IN  pay_assignment_actions.tax_unit_id%TYPE
             , p_group_output_tab      OUT   NOCOPY   bal_tab );

   PROCEDURE get_assgt_curr_term_values_bbr
            ( p_year_start             IN   DATE
            , p_year_end               IN   DATE
            , p_assignment_id          IN   pay_assignment_actions.assignment_id%type
            , p_fbt_rate               IN   ff_globals_f.global_value%TYPE
            , p_ml_rate                IN   ff_globals_f.global_value%TYPE
            , p_assignment_action_id   IN   pay_assignment_actions.assignment_action_id%type
            , p_tax_unit_id            IN   hr_all_organization_units.organization_id%TYPE
            , p_emp_type               IN   varchar2
            , p_term_output_tab        OUT  NOCOPY bal_tab);
            --, p_message OUT NOCOPY VARCHAR2); /* bug 7571001 - removed the parameter */

   /* End of Bug : 3186840 */


 ------------ --Bug#3749530 All the procedures added below are for archival model------

  --------------------------------------------------------------------
  -- These are PUBLIC procedures are required by the Archive process.
  -- There names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
  -- the archive process knows what code to execute for each step of
  -- the archive.
  --------------------------------------------------------------------

  --------------------------------------------------------------------
  -- This procedure returns a sql string to select a range
  -- of assignments eligible for archival.
  --------------------------------------------------------------------

  procedure range_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_sql               out nocopy varchar2);

  --------------------------------------------------------------------
  -- This procedure is used to set global contexts
  -- however in current case it is a dummy procedure. In case this
  -- procedure is not present then archiver assumes that
  -- no archival is required.
  --------------------------------------------------------------------

  procedure initialization_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type);


  --------------------------------------------------------------------
  -- This procedure further restricts the assignment_id's
  -- returned by range_code
  --------------------------------------------------------------------
  procedure assignment_action_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_start_person_id    in per_all_people_f.person_id%type,
     p_end_person_id      in per_all_people_f.person_id%type,
     p_chunk              in number);


  --------------------------------------------------------------------
  -- This procedure is actually used to archive data . It
  -- internally calls private procedures to archive balances ,
  -- employee details, employer details and supplier details .
  --------------------------------------------------------------------
  procedure archive_code
    (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_effective_date        in date);


  procedure spawn_ps_report
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type);


end pay_au_recon_summary;

/
