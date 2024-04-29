--------------------------------------------------------
--  DDL for Package Body PAY_AU_PAYMENT_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_PAYMENT_SUMMARY" as
/* $Header: pyaupsp.pkb 120.44.12010000.24 2010/01/13 09:20:16 pmatamsr ship $*/
/*
*** ------------------------------------------------------------------------+
*** Program:     pay_au_payment_summary (Package Body)
***
*** Change History
***
*** Date       Changed By  Version  Description of Change
*** ---------  ----------  -------  ----------------------------------------+
*** 01 MAR 01  rbsinha     1.0      Initial version
*** 11 MAY 01  rbsinha     1.19     Bug #1768813 - to retrieve the value  of
                                    fringe_benefits calc_all_balances (effective_date,assignment_id,defined_balance_id)
                                    is being used instead of calc_all_balances(assignment_action_id,defined_balance_id)
*** 11 MAY 01  rbsinha     1.19     Bug #1764010 - process_assignment cursor modified
                                    Locked action id for payment summary report changed to
                                    Locking action id
*** 11 MAY 01  rbsinha     1.21     Bug #1763290 -Modified employee_details
                                    cursor to archive current and terminated
                                    employees.Removed sort items from
                                    archive_etp_details.
                                    Bug #1763245 -Modified employer_details
                                    and supplier_details
*** 22 MAY     rbsinha     1.22     Bug No : 17164017 and Bug No : 1789886
                                    Added archive item : X_UNION_NAMES and
                                    X_PAYMENT_SUMMARY_SIGNATORY
*** 17 JUL     rbsinha     1.25     Bug No : 1746093 - Added the fields
                                    X_ETP_EMPLOYEE_PAYMENT_DATE and
                                    X_ETP_ON_TERMINATION_PAID . These fields
                                    are populated in the procedure
*** 15 Sep     apunekar    1.26     Made changes for Bug1956018.
*** 18 Sep     rbsinha     1.27     Made changes for Bug1951539 and Bug1903647.
*** 03 Oct     apunekar    1.28     Made changes  for Bug2021219.
*** 11 Oct     apunekar    1.28     Made changes  for Bug1955993
*** 29 Oct 01  shoskatt    1.39     The archived value of x_post_jun_83_untaxed_asg_ytd
***                                 should not contain lumpsum D Amount(Bug #2075782)
*** 31 Oct 01  shoskatt    1.40     If the Termination Date of the employee is in the
***                                 next financial year, then the employee type should
***                                 be current(Bug# 1973978)
*** 17 Apr 02 srrajago     1.41     Performance Issue (Bug No : 2263587)
*** 17 Apr 02 srrajago     1.42     Included checkfile command
*** 22 Apr 02 srrajago     1.43     In Cursor employee_detail, hr_locations_all has been replaced by hr_locations (Bug No : 2263587).
*** 06 May 02 vgsriniv     1.44     Cursor get_allowance_balances modified Bug 2359428, 2359423
*** 03 Jun 02 Ragovind     1.45     Cursor get_allowance_balances modified for Bug#2398315 to fix the bug 2359428 and to make compatible with both 8i and 9i database versions.
*** 15 Jul 02 shoskatt     1.46     For retrieving the ETP Payment values, get the maximum assignment
***                                 action id for which ETP values have been processed  (Bug #2459527)
*** 16 Jul 02 shoskatt     1.47     Removed some redundant cursors,Introduced date check for
***                                 c_get_max_ass_act_id cursor,Also fixed Bug #2448446
*** 24 Jul 02 shoskatt     1.48     Improved performance by tuning cursors process_assignments,
***                                 c_archive_fbt_info and c_archive_info(Bug #2454595)
*** 08 Aug 02 shoskatt     1.49     Improved performance by tuning cursors process_assignments
***                                 and etp_code (Bug #2501105)
*** 09 Aug 02 Ragovind     1.50     Changed the cursor archive_employee cursor to fetch the data for Terminated-Rehired
***                                 Employees (Bug# 2448441).
*** 16 Aug 02 vgsriniv     1.52     Modified employee_details cursor. Removed to_date for the date parameter
***                                 in the select statement for employee type (Bug #2512431)
*** 26 Sep 02 kaverma      1.53     Modified cursor employer_details and etp_code. Also
***                                 introduced a cursor balance_exists (Bug No 2581436 )
*** 24 Oct 02 srrajago     1.54     Modified the cursor process_assignments (Bug No : 2574186)
*** 28 Oct 02 srrajago     1.55     Included action_type 'I' for 'Balance Initialization' in cursor
***                                 process_assignments (Bug No : 2574186)
*** 01 Nov 02 shoskatt     1.56     Changed the etp_code to check for action type and added the function
***                                 to check for the existence of Lumpsum C value. balance_exists cursor
***                                 has been changed. (Bug #2646912)
*** 18 Nov 02 Ragovind     1.57     Modified the cursor Get_Allowance_Balances for Performance Improvement for Bug#2665475.
*** 01 Dec 02 Apunekar     1.58     Modified cursor employee_details for Bug#2689175
*** 01 Dec 02 Apunekar     1.59     Added nocopy
*** 16 Jan 03 Apunekar     1.61     Modified process_assignments,employee_details cursor and
***                                 archive_etp_payment_details procedure (Bug 2574186)
*** 30 Jan 03 Kaverma      1.62     Modified 'process_assignments' cursor 'not exists' clause (Bug 2777142)
*** 30 Jan 03 Apunekar     1.63     Modified cursors employee_details and  etp_details for bug 2774577
*** 18 Feb 03 Ragvoind     1.64     Add Join for Period of service ID to the Employee_details Cursor. Bug#2786146
*** 25 Feb 03 Ragovind     1.65     Modified the process_assignments cursor to avoid MERGE-JOIN-CARTESIAN Bug#2786835.
*** 04 Mar 03 Kaverma      1.66     Modified procedure 'archive_prepost_details' to use Lump Sum C Payment balance
***                                 to get pre and post 83 values (Bug No : 2826802)
*** 24 Mar 03 Kaverma      1.67     Modified cursor etp_code (Bug No : 2856638)
*** 02 May 03 Nanuradh     1.68     Modified the proceduce assignment_action_code by adding temporay check.
***                                 Excluded processing all the employees, where lump sum E payment exists
***                                 after 01-JUL-2003 (Bug: 2822446)
*** 02 May 03 Nanuradh     1.69     Modified the cursor c_employee_number to improve the performance.(Bug: 2822446)
*** 05 May 03 Nanuradh     1.70     Modified the cursor c_employee_number.
*** 05 May 03 Nanuradh     1.71     Corrected the message to be printed in the out file.
*** 05 May 03 Apunekar     1.72     Bug2855658 - Fixed for Retro Allowances
*** 05 May 03 Apunekar     1.73     Bug2855658 - Fixed for Performance
*** 15 May 03 Ragovind     1.74     Bug2819479 - ETP Pre/Post Enhancement.
*** 21 May 03 Apunekar     1.75     Bug2968127 - Cleared PL/SQL allowances table after processing.
*** 27 May 03 Apunekar     1.76     Bug2977533 - Ordered addresses by date_from.
*** 27-Jun-03 Hnainani     11591.5  Bug#3019374  Removed FBT check from Main Query
*** 28-Jun-03 SRussell     11591.7  Bug#3019374  Replaced process_Assignments
                                    cursor after discussion with core.
*** 28-Jun-03 SRussell     1.83     Copied branched version 11591.7 into main code.
*** 28-Jun-03 SRussell     11592.2  Branched code. Put hints in
                                    process_assignments cursor.
*** 04-Jul-03 Apunekar     11592.3  Added check to get latest person record in financial year in process_assignments
*** 04-Jul-03 Apunekar     115.84   Bug3019374 Changed process_assignments,etp_code,Get_retro_Entry_ids cursors , included branched version changes in mainline code.
*** 16-Jul-03 Apunekar     115.85   Includes fix for 3048724
*** 17-Jul-03 Apunekar     115.86   Bug3019374 Modified Cursor employee_details for performance fix.
*** 23 Jul 03 Nanuradh     115.87   Bug#2984390 - Added an extra parameter to the function call etp_prepost_ratios - ETP Pre/post Enhancement
*** 29 Jul 03 Nanuradh     115.88   Bug#2881272 -  Modified the proceduce assignment_action_code by removing the temporary check.
***                                 Included processing of all the employees, where Lump sum E payment exists after 01-JUL-2003.
*** 28-Jul-03 Apunekar     115.90   Bug3073082 - Cursor employee_details removed date formatting in decode.
*** 29-Jul-03 Nanuradh     115.91   Bug#2881272 - Deleted the commented code in process_assignments function.
*** 28-Jul-03 Apunekar     115.92   Bug#3075153 - Modified employee_details
*** 04-Aug-03 Apunekar     115.93   Bug#3077528 - Backed out previous changes made
*** 06-Aug-03 Apunekar     115.94   Bug#3043049 - Used secured views in range_code and process_assignments for security
*** 06-Aug-03 Apunekar     115.95   Bug#3043049 - Used secured views in process_assignments_only for security
*** 13-AUG-03 Nanuradh     115.96   Bug#3095919 - If single lump sum E payment is less than $400 then the payment is included in gross earnings
***                                 otherwise it is included in Lump sum E payment.
*** 21-AUG-03 punmehta     115.97   Bug#3095919 - Modified the Cursor c_get_pay_earned_date to fetch effective_date instead of date_earned
*** 22-AUG-03 punmehta     115.98   Bug#3095919 - Modified the Cursor name c_get_pay_earned_date
***                                 to c_get_pay_effective_date and variable name of date_earned to effective_date
*** 22-Nov-03 punmehta    115.99    Bug#3263659 - Modified employee_details and archive code to check for the termination date
***                     and added check for 'g_debug' before tracing for performance
*** 11-Dec-03 punmehta    115.100   Bug#3263659 - Archive_code , before calling archive_etp_code put a check for termination date
*** 06-Feb-04 punmehta    115.101   Bug#3245909 - Modified c_get_pay_effective_date cursor to fetch Dates for only master assignment action.
*** 06-Feb-04 punmehta    115.102   Bug#3245909 - Removed unwanted code.
*** 10-Feb-04 punmehta    115.103   Bug#3098353 - Archived a new flag which is false if all the balances are zero.
*** 11-Feb-04 punmehta    115.104   Bug#3098353 - Modified IF caluse for setting employee_end date.
*** 11-Feb-04 punmehta    115.105   Bug#3098353 - Renamed variables
*** 12-Feb-04 punmehta    115.106   Bug#3132178 - New procedure for calling magtape process.
*** 13-Feb-04 punmehta    115.107   Bug#3132178 - Coding Standards, changed SELECT to cursor
*** 18-Feb-04 jkarouza    115.08    Bug#3172963 - Use of BBR to retrieve balances wherever possible.
*** 02-Apr-04 punmehta    115.109   Bug#3549553 - Modified Union cursor and FBT cursor for balances.
*** 24-Apr-04 puchil      115.110   Bug#3586388 - Changed the cursor etp_code and removed gscc warnings.
*** 07-May-04 avenkatk    115.111   Bug#3580487 - Modified Union Cursor,removed call to hr_aubal.calc_all_balances.
*** 28-MAY-04 punmehta    115.112   Bug#3642409 - Added new index INDEX(a per_assignments_f_N12) to cursor process_assignments.
*** 28-MAY-04 punmehta    115.112   Bug#3642409 - Removed Rownum from cursor process_assignments.
*** 03-JUN-04 abhkumar    115.113   Bug#3661230 - Modified the process assignment cursor to take all the employees for archiving purpose.
*** 21-JUN-04 srrajago    115.118   Bug#3701869 - Modified the cursor csr_get_bbr_aseq to fetch max action_sequence instead of
***                                               assignment_action_id. Introduced cursor csr_get_bbr_assignment_action to pass the
***                                               correct assignment_action_id based on action_sequence to pay_balance_pkg.Also handled
***                                               the parameter Last Year Termination value setting if it is not enabled.
*** 21-JUN-04 srrajago    115.119   Bug#3701869 - Modified cursors 'csr_get_bbr_aseq' and 'csr_get_bbr_asg_actions'. Handled the parameter
***                                               Last Year Termination value setting if it is not enabled in another place which was
***                                               missed in the previous fix.
*** 25-JUN-04 srrajago    115.120   Bug#3603495 - Performance Fix - Modified cursors 'c_get_pay_effective_date' and 'etp_BA_or_BI'.
***                                               Introduced per_assignments_f table and its joins.
*** 03-JUL-04 srrajago    115.122   Bug#3743010 - Reverted back the fix in the previous version fixed for Bug: 3728357. This is same as
***                                               the version 115.20
*** 05-JUL-04 srrajago    115.123   Bug#3603495 - Performance Fix - Modified cursor 'c_get_pay_effective_date'.
*** 05-JUL-04 punmehta    115.124   Bug#3744930 - Modified for Re-hire
*** 05-JUL-04 punmehta    115.125   Bug#3755305 - Modified to get the action_id based on max action_squence
*** 09 Aug 04 abhkumar    115.126   Bug2610141  - Legal Employer Enhancement
*** 12 Aug 04 abhkumar    115.127   Bug2610141  - Modified code so that legal employer end date is not archived twice.
*** 06 Oct 04 avenkatk    115.128   Bug#3815301 - Modified cursor process_assignments and process_assignments_only for Payroll Updation.
*** 12 Oct 04 avenkatk    115.129   Bug#3815301 - Modified cursor process_assignments and process_assignments_only for better performance.
*** 09 Dec 04 ksingla     115.130   Bug#3937976 - Archived a new flag which is true if an employee ,current or terminated in the current year,
                                                  has zero balances in the current year.
*** 14 Dec 04 ksingla     115.131   Bug#3937976 - Removed redundant code,defaulted the parameter l_curr_term_0_bal_flag to 'NO'.
*** 15 Dec 04 hnainani    115.132   Bug#4015082 - Changes to archive Workplace Giving Deductions
*** 23 Dec 04 abhkumar    115.133   Bug#4063321 - Fixed issues related to Terminated employees, allowance details and LE dates
*** 24 Dec 04 abhkumar    115.134   Bug#4063321 - Removed GSCC errors
*** 30 Dec 04 ksingla     115.135   Bug#4000955 - Modified subquery of process_assignments and process_assignments_only not to archive employees for
                                                  any legal employer if Manual PS is issued for 'ALL' legal employers or without any legal employer.
*** 30 Dec 04 avenkatk    115.136   Bug#3899641 - Functional Dependancy Comment Added.
*** 07 Feb 05 ksingla     115.137   Bug#4161460   Modified the cursor get_allowance_balances
*** 12 Feb 05 abhargav    115.138   bug#4174037   Modified the cursor get_allowance_balances to avoid the unnecessary get_value() call.
*** 17 Feb 05 abhkumar    115.139   Bug#4161460   Rolled back changes made in 115.137
*** 16 Mar 05 ksingla     115.140   Bug#4177679   Modified the subquery of employee_details to archive correct employee le_start_date
                                                  when legal employer is changed .
*** 17 Mar 05 ksingla     115.141   Bug#4177679   Modified the subquery of employee_details to archive correct employee le_start_date
                                                  when person details are modified .
*** 31 Mar 05 ksingla     115.142   Bug#4177679   Modified the subquery of employee_details to archive correct employee le_end_date
                                                  when "Leave Loading" segment is modified.
*** 11 Apr 05 ksingla     115.143   Bug#4278361   Modified the cursor etp_paid. Added a new table pay_payrolls_f for performance issues.
*** 12 Apr 05 avenkatk    115.144   Bug#4299506   Modified Cursor employee_details - Sub Query modified to archive employee details for employees terminated in previous year.
*** 13 Apr 05 ksingla     115.145   Bug#4278379   Modified the cursor get_retro_entry_ids for performance.
*** 14 Apr 05 ksingla     115.146   Bug#4278379   Rolled back the changes done to cursor get_retro_entry_ids.
*** 18 Apr 05 ksingla     115.147   Bug#4278299   Modified the cursor get_allowance_balances for performance.
*** 19 Apr 05 ksingla     115.148   Bug#4281290   Modified the cursor etp_code for performance.
*** 20 Apr 05 ksingla     115.149   Bug#4177679   Modified for etp employee start date.
*** 25 Apr 05 ksingla     115.150   Bug#4278299   Rolled back the changes done in version 115.147.
*** 05 May 05 abhkumar    115.151   Bug#4377367   Added join in the cursor process_assignments to archive the end-dated employees.
*** 24 May 05 abhargav    115.152   Bug#4363057   Changes due to Retro Tax enhancement.
*** 24 May 05 abhargav    115.152   Bug#4387183   Modified file to to archive employee details for FBT employees.
                                                  Included the fix for Bug# 4375020
                                                  and  included action_type 'V' in cursor csr_get_dates
*** 20 Jul 05 abhkumar    115.153   Bug#4418107   Modified call to pay_au_paye_ff.get_retro_period in adjust_retro_allowances
*** 08-AUG-05 hnainani    115.154   Bug#3660322   Added Quotes around Extra Information Query (-999) to not erro out for Character values
*** 02-OCT-05 abhkumar    115.156   Bug#4653934   Modified assignment action code to pick those employees who do have payroll attached
                                                  at start of the financial year but not at the end of financial year.
*** 15-Nov-05 avenkatk    115.157   Bug#4738470   Change cursor for Maximum assignment_action_id.
*** 02-DEC-05 abhkumar    115.158   Bug#4701566   Modified the cursor get_allowance_balances to get allowance value for end-dated
                                                  employees and also improve the performance of the query.
*** 06-DEC-05 abhkumar    115.159   Bug#4863149   Modified the code to raise error message when there is no defined balance id for the allowance balance.
*** 06-Dec-05 ksingla     115.160   Bug#4866415   Removed round for l_pre01jul1983_value and l_post30jun1983_value
*** 06-DEC095 avenkatk    115.161   Bug#4866934   Initialized balance values to 0 for FBT Employee
*** 04-Jan-06 ksingla     115.162   Bug#4925650   Modified cursor c_get_effective_date to resolve performance issues.
*** 04-Jan-06 ksingla     115.163   Bug#4926521   Modified cursor process_assignments to resolve performance issues.
*** 03-Mar-06 abhkumar    115.164   Bug#5075662   Modified for etp employee start date.
*** 16-Mar-06 ksingla     115.165   Bug#5099419   Modified to round off correctly.
*** 21-Mar-06 ksingla     115.166   Bug#5099419   Removed changes done for bug 4926521
*** 20-Jun-06 ksingla     115.167   Bug#5333143   Add_months included to fetch FBT_RATE and MEDICARE_LEVY
*** 29-Jun-06 avenkatk    115.168   Bug#5364017   Added check for "Generic" Address Style in Employee Address.
*** 03-Jul-06 avenkatk    115.169   Bug#5367061   ETP Start Date with be ETP Service Date entered else Hire Date. Backed out Fix 4177679.
*** 11-Aug-06 hnainani    115.170   Bug#5395393   Modified the v_lst_year_start variable to be assigned to financial year start
***                                               instead of FBT year Start. This was done to keep it consistent with the
***                                               Archive_code procedure and End Of Year Reconciliation Reports.
*** 01-Sep-06 sclarke     115.172   Bug#4925547   Altered archive of allowances and unions to support 2006/2007 layout.
*** 05-Oct-06 priupadh    115.174                 The file is now dual maintained ,R12 version will be in Sync.
*** 06-Oct-06 hnainani    115.179   Bug# 5377624  Modified cursor c_get_pay_Effective_date to link Time Period Id with Date_Earned
***                                               to get the assignment action id
***
*** 10-Oct-06 abhargav    115.180   Bug#4925547   Added bug references for changes done under Bug#4925547.
*** 17-Nov-06 abhargav    115.181   Bug#5591993   Modified cursor CSR_UNIONS_2006 to avoid MJC.
*** 20-Nov-06 sclarke     115.182   Bug#5666937   Enabled the 'order by' of the where clause of get_allowance_balances
***                                               cursor.
*** 28-Nov-06 sclarke     115.183   Bug#5679568   Procedure archive_2006_unions -
***                                               Handled case where both old and new unions exists but number of new unions is < 4
*** 19-Dec-06 ksingla     115.184   Bug#5708255   Added code to get value of global FBT_THRESHOLD
*** 27-Dec-06 ksingla      115.185  Bug#5708255   Added to_number to all occurrences of  g_fbt_threshold
*** 8-Jan-06 ksingla       115.186  Bug#5743196   Added nvl to cursor Get_Retro_allowances
*** 23-Mar-07 ksingla      115.187  Bug#5371102   Modified for performance fixes
*** 26-Apr-07 sbaburao     115.188  Bug#5846278   Modified the function adjust_retro_allowance for Enhanced Retropay
*** 27-Apr-07 sbaburao     115.189  Bug#5846278   Modified the check for cursor get_legislation_rule to default the value of l_adv_retro_flag to 'N'
*** 10-May-07 priupadh     115.190  Bug#5956223   Modified function archive_etp_details added archive items X_TRANSITIONAL_ETP and X_PART_OF_PREVIOUS_ETP
*** 24-May-07 priupadh     115.191  Bug#6069614   Removed the if conditions which checks the death benefit type other then 'Dependent'
*** 01-Jun-07 tbakashi     115.192  Bug#6086060   Added trunc function for union values and allowance values.
*** 09-Jun-07 tbakashi     115.193  Bug#6086060   Added trunc in archive_limited_values and removed in archive_allowance_details
*** 10-Jun-07 priupadh     115.194  Bug#6112527   Added the changes removed in Bug#6069614 , with condition that for death benefit type Dependent
***                                               only archive if Fin Year is 2007/2008 or greater .
*** 14-Jun-07 tbakashi     115.195 Bug#6086060    Removing the trunc's added as they create inconsistency of value in data file.
*** 23-Aug-07 avenkatk     115.196  Bug#5371102   Modified Cursor csr_get_dates for performance.
*** 03-Sep-07 priupadh     115.197 Bug#6192381    For multiple ETP enh ,modified initialization_code,archive_code,archive_prepost_details
***                                               archive_etp_details and added procedure adjust_old_etp_values
*** 06-Sep-07 priupadh     115.198 Bug#6192381    Modified the Balance Names for Invalidity Component,removed commented code from archive_prepost_details
*** 07-Sep-07 priupadh     115.199 Bug#6192381    Removed multiple comments tab in one line to avoid chksql error
*** 07-Jan-08 avenkatk     115.200 Bug#6470581    Added Changes for supporting Amended payment summaries
*** 23-Jan-08 avenkatk     115.201 Bug#6740581    Resolved GSCC Errors
*** 30-May-08 priupadh     115.202 Bug#7135544    Added NVL (N) to variables lv_transitional_flag and lv_part_prev_etp_flag
***                                               if Null values are returned from cursor.
*** 18-Jun-08 avenkatk     115.203 Bug#7138494    Added Changes for RANGE_PERSON_ID
*** 26-Jun-08 priupadh     115.204 Bug#7171534    Added t_allowance_balance.count > 0 in adjust_retro_allowances
*** 07-Jul-08 avenkatk     115.205 Bug#7234263    Modified archive_employee_details for End assignments
*** 16-Jul-08 avenkatk     115.206 Bug#7242551    Modified archive_employee_details for fetching correct TFN
*** 25-Nov-08 skshin       115.207 Bug#7571001    Added changes in archive_allowance_detils and adjust_retro_allowances for Balance Attribute reporting
*** 25-Nov-08 skshin       115.208 Bug#7571001    Modified Cursor Get_retro_Entry_ids and Cursor Get_Retro_allowances to avoid duplcate joins
*** 16-Apr-09 skshin       115.209 Bug#8423565    Modified archive_union_name to display Miscellaneous when 'Balance Initialization 4' is used.
*** 28-Apr-09 pmatamsr     115.210 Bug#8441044    Cursor c_get_pay_effective_date is modified to consider Lump Sum E payments for payment summary gross calculation
***                                               for action types 'B' and 'I'.
*** 13-May-09 pmatamsr     115.211 Bug#8315198    Modified initialization_code,archive_etp_details,archive_employee_details,archive_balance_details and
***                                               archive_code procedures as part of FY2009 Payment Summary changes.
*** 18-May-09 pmatamsr     115.212 Bug#8315198    Modified archive_etp_details,archive_employee_details and archive_code procedures such that the new DB items
***                                               added for FY2009 Payment Summary enhancement are archived only if FY is 2009 or greater.
*** 23-Jun-09 pmatamsr     115.213 Bug#8587013    Modified initialization_code,archive_balance_details and archive_code procedures to remove references to
***                                               Other Income balance.
*** 03-Aug-09 dduvvuri     115.214 Bug#5008855    Modified cursors etp_details and csr_union_fees to add a join on per_periods_of _service
*** 07-Sep-09 pmatamsr     115.215 Bug#8769345    Modified initialization_code and archive_prepost_details such that the new balances addeed are used
**                                                during the pre 83 and post 83 components archival process.
*** 19-Nov-09 skshin       115.218 Bug#8711855    Moved single Lump Sum E adjustment logic to new function get_lumpsumE_value.
***                                               Modifed archive_balance_details procedure to call get_lumpsumE_value function and include additional Lump Sum E balances to existing Lump Sum E calculation.
*** 15-Dec-09 pmatamsr     115.219 Bug#9190980    Modified Lump Sum E adjustment logic for Retro GT12 Pre Tax Deductions in get_lumpsumE_value function.
*** 13-Jan-09 pmatamsr     115.220 Bug#9226023    Added logic to support the calculation of taxable and tax free portions of ETP for the terminated employees processed
***                                               before applying the patch 8769345.
*** -------------------------------------------------------------------------------------------------------+
*/
g_debug             boolean;
g_business_group_id number;
g_package           constant varchar2(30) := 'pay_au_payment_summary';
g_legislation_code  constant varchar2(2)  := 'AU';
g_dimension_id      pay_balance_dimensions.balance_dimension_id%type;
g_balance_type_id   pay_balance_types.balance_type_id%type; /*Bug#5591993*/
g_fbt_threshold ff_globals_f.global_value%TYPE ; /* Bug 5708255 */
g_attribute_id        pay_balance_attributes.attribute_id%type;   -- bug 7571001
g_termination_type  varchar2(4); /*Bug#8315198 - Variable to store the termination type*/
--
/*
** 4177679 this new flag would be Y when the etp employee date has to be archived
** else N if le start date has to be archived for X_ETP_EMPLOYEE_START_DATE
*/
g_le_etp_flag varchar2(10) ;
--
-------------------------------------------------------------------------------------------------------+
-- Define global variable to store defined_balance_id's and the corresponding balance values for BBR.
-------------------------------------------------------------------------------------------------------+
p_balance_value_tab     pay_balance_pkg.t_balance_value_tab;    -- 3172963
p_context_table         pay_balance_pkg.t_context_tab;          -- 2610141
p_result_table          pay_balance_pkg.t_detailed_bal_out_tab; -- 2610141
p_lump_sum_E_ptd_tab    pay_balance_pkg.t_balance_value_tab;    -- 8711855

---------------------------------------------------------------------------------------------------------------------------+
--Bug 6192381
--For ETP Payment Balances define global variable to store defined_balance_id's and the corresponding balance values for BBR.
---------------------------------------------------------------------------------------------------------------------------+

p_etp_balance_value_tab     pay_balance_pkg.t_balance_value_tab;
p_etp_context_table         pay_balance_pkg.t_context_tab;
p_etp_result_table          pay_balance_pkg.t_detailed_bal_out_tab;

/* Bug 6470581 - PL/SQL table to hold Archive Items when submitted for Amended payment summary */
p_all_dbi_tab pay_au_payment_summary_amend.archive_db_tab ;

  --------------------------------------------------------------------+
  -- This procedure returns a sql string to select a range
  -- of assignments eligible for archival.
  --------------------------------------------------------------------+

  procedure range_code
    (p_payroll_action_id   in pay_payroll_actions.payroll_action_id%type,
     p_sql                out nocopy varchar2) is
  begin
      g_debug := hr_utility.debug_enabled;
      IF g_debug THEN
         hr_utility.set_location('Start of range_code',1);
     END if;
/* Bug#3043049*/
    p_sql := ' select distinct p.person_id'                                       ||
             ' from   per_people_f p,'                                        ||
                    ' pay_payroll_actions pa'                                     ||
             ' where  pa.payroll_action_id = :payroll_action_id'                  ||
             ' and    p.business_group_id = pa.business_group_id'                 ||
             ' order by p.person_id';
      IF g_debug THEN
        hr_utility.set_location('End of range_code',2);
      END if;
  end range_code;


  --------------------------------------------------------------------+
  -- This procedure is used to set global contexts
  -- however in current case it is a dummy procedure. In case this
  -- procedure is not present then archiver assumes that no archival is required.
  --------------------------------------------------------------------+


procedure initialization_code (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type) is
  --
  --------------------------------------------------------------------------------------+
  -- Cursor to setup table to hold balance_id's to be retrieved using BBR. (Bug3172963)
  --------------------------------------------------------------------------------------+
  --

/*Bug 6192381 Added New Balances for Multiple ETP Enhancement*/
/*Bug 8315198 Added two new Balances for FY 2009 Payment Summary enhancement */
/*Bug 8587013 Removed 'Other Income' balance and moved 'Exempt Foreign Employment Income' balance to that index position*/
  cursor c_get_defined_balance_id is
  select decode(pbt.balance_name, 'CDEP',1
                                , 'Leave Payments Marginal',2
                                , 'Lump Sum A Deductions',3
                                , 'Lump Sum A Payments',4
                                , 'Lump Sum B Deductions',5
                                , 'Lump Sum B Payments',6
                                , 'Lump Sum C Deductions',7
                                , 'Lump Sum C Payments',8
                                , 'Lump Sum D Payments',9
                                , 'Total_Tax_Deductions',10
                                , 'Termination Deductions',11
                                , 'Exempt Foreign Employment Income',12 /* 8315198, 8587013 */
                                , 'Union Fees',13
                                , 'Invalidity Payments',14
                                , 'Lump Sum E Payments',15
                                , 'Earnings_Total', 16
                                , 'Workplace Giving Deductions' , 17
                                , 'ETP Deductions Transitional Not Part of Prev Term',18  /* Begin 6192381 */
                                , 'ETP Deductions Transitional Part of Prev Term',19
                                , 'ETP Deductions Life Benefit Not Part of Prev Term',20
                                , 'ETP Deductions Life Benefit Part of Prev Term',21
                                , 'Invalidity Payments Life Benefit Not Part of Prev Term',22
                                , 'Invalidity Payments Life Benefit Part of Prev Term',23
                                , 'Invalidity Payments Transitional Not Part of Prev Term',24
                                , 'Invalidity Payments Transitional Part of Prev Term',25 /*4015082 ,6192381 */
                                , 'Reportable Employer Superannuation Contributions',26  /*Bug 8315198 ,8587013 */
                                , 'Retro Earnings Leave Loading GT 12 Mths Amount', 27  -- start 8711855
                                , 'Retro Earnings Spread GT 12 Mths Amount', 28
                                , 'Retro Pre Tax GT 12 Mths Amount', 29) sort_index, -- end 8711855
         pdb.defined_balance_id defined_balance_id
  from   pay_balance_types pbt
  ,      pay_balance_dimensions pbd
  ,      pay_defined_balances pdb
  where  pbt.balance_name in     ( 'CDEP'
                                 , 'Leave Payments Marginal'
                                 , 'Lump Sum A Deductions'
                                 , 'Lump Sum A Payments'
                                 , 'Lump Sum B Deductions'
                                 , 'Lump Sum B Payments'
                                 , 'Lump Sum C Deductions'
                                 , 'Lump Sum C Payments'
                                 , 'Lump Sum D Payments'
                                 , 'Total_Tax_Deductions'
                                 , 'Termination Deductions'
				 , 'Exempt Foreign Employment Income' /* 8315198 ,8587013 */
                                 , 'Union Fees'
                                 , 'Invalidity Payments'
                                 , 'Lump Sum E Payments'
                                 , 'Earnings_Total'
                                 , 'Workplace Giving Deductions'
                                , 'ETP Deductions Transitional Not Part of Prev Term' /* Begin 6192381 */
                                , 'ETP Deductions Transitional Part of Prev Term'
                                , 'ETP Deductions Life Benefit Not Part of Prev Term'
                                , 'ETP Deductions Life Benefit Part of Prev Term'
                                , 'Invalidity Payments Life Benefit Not Part of Prev Term'
                                , 'Invalidity Payments Life Benefit Part of Prev Term'
                                , 'Invalidity Payments Transitional Not Part of Prev Term'
                                , 'Invalidity Payments Transitional Part of Prev Term'  /* 4015082 , End 6192381 */
                                , 'Reportable Employer Superannuation Contributions'  /*Bug 8315198*/
                                , 'Retro Earnings Leave Loading GT 12 Mths Amount' -- start 8711855
                                , 'Retro Earnings Spread GT 12 Mths Amount'
                                , 'Retro Pre Tax GT 12 Mths Amount')  -- end 8711855
  and   pbd.database_item_suffix = '_ASG_LE_YTD' --2610141
  and   pbt.balance_type_id      = pdb.balance_type_id
  and   pbd.balance_dimension_id = pdb.balance_dimension_id
  and   pbt.legislation_code     = 'AU'
  order by sort_index;

/*Bug 6192381 Added cursor c_get_etp_defined_balance_id for ETP Pay Balances*/
/* Bug 8769345 - Added new ETP Taxable and Tax Free balances to the cursor */
  cursor c_get_etp_defined_balance_id is
  select decode(pbt.balance_name, 'ETP Payments Transitional Not Part of Prev Term',1
                                , 'ETP Payments Transitional Part of Prev Term',2
                                , 'ETP Payments Life Benefit Not Part of Prev Term',3
                                , 'ETP Payments Life Benefit Part of Prev Term',4
				, 'ETP Tax Free Payments Transitional Not Part of Prev Term',5
                                , 'ETP Taxable Payments Transitional Not Part of Prev Term',6
                                , 'ETP Tax Free Payments Transitional Part of Prev Term',7
                                , 'ETP Taxable Payments Transitional Part of Prev Term',8
                                , 'ETP Tax Free Payments Life Benefit Not Part of Prev Term',9
                                , 'ETP Taxable Payments Life Benefit Not Part of Prev Term',10
                                , 'ETP Tax Free Payments Life Benefit Part of Prev Term',11
                                , 'ETP Taxable Payments Life Benefit Part of Prev Term',12
                                , 'Lump Sum C Payments',13) sort_index,
         pdb.defined_balance_id defined_balance_id
  from   pay_balance_types pbt
  ,      pay_balance_dimensions pbd
  ,      pay_defined_balances pdb
  where  pbt.balance_name in     ('ETP Payments Transitional Not Part of Prev Term'
                                 ,'ETP Payments Transitional Part of Prev Term'
                                 ,'ETP Payments Life Benefit Not Part of Prev Term'
                                 ,'ETP Payments Life Benefit Part of Prev Term'
                                 ,'Lump Sum C Payments'
				 ,'ETP Tax Free Payments Transitional Not Part of Prev Term'
                                 ,'ETP Taxable Payments Transitional Not Part of Prev Term'
                                 ,'ETP Tax Free Payments Transitional Part of Prev Term'
                                 ,'ETP Taxable Payments Transitional Part of Prev Term'
                                 ,'ETP Tax Free Payments Life Benefit Not Part of Prev Term'
                                 ,'ETP Taxable Payments Life Benefit Not Part of Prev Term'
                                 ,'ETP Tax Free Payments Life Benefit Part of Prev Term'
                                 ,'ETP Taxable Payments Life Benefit Part of Prev Term')
  and   pbd.database_item_suffix = '_ASG_LE_YTD'
  and   pbt.balance_type_id      = pdb.balance_type_id
  and   pbd.balance_dimension_id = pdb.balance_dimension_id
  and   pbt.legislation_code     = 'AU'
  order by sort_index;

  --
  /*
  ** 4863149 - Introduced a new cursor c_le_ytd_dimension_id
  **           Moved here to avoid having to be executed for each assignment
  */
  cursor c_le_ytd_dimension_id is
  select balance_dimension_id
  from   pay_balance_dimensions pbd
  where  pbd.dimension_name = '_ASG_LE_YTD'
  and    pbd.legislation_code = g_legislation_code;
  /*Bug#5591993*/
  -- Cursor to fetch the balance type id for Seeded balance Union Fees  which will be
  -- used in  Curosr CSR_UNIONS_2006
  CURSOR c_union_balance IS
  SELECT balance_type_id from pay_balance_types
  WHERE balance_name='Union Fees'
  and   legislation_code='AU';


 /* Bug 6470581 - Added the following to initialize the global g_fbt_threshold */
   CURSOR  c_get_fbt_global(c_year_end DATE)
   IS
   SELECT  global_value
   FROM   ff_globals_f
   WHERE  global_name = 'FBT_THRESHOLD'
   AND    legislation_code = 'AU'
   AND    c_year_end BETWEEN effective_start_date
                         AND effective_end_date;

  CURSOR get_params(c_payroll_action_id  per_all_assignments_f.assignment_id%type)
  IS
  SELECT  to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),6,4),'DD-MM-YYYY') Financial_year_end
         ,ppa.business_group_id
  FROM  pay_payroll_actions ppa
  WHERE ppa.payroll_action_id = c_payroll_Action_id;

  /* bug 7571001 - added get_balance_attribute cursor to initialize g_attribute_id*/
  CURSOR get_balance_attribute (c_attribute_name PAY_BAL_ATTRIBUTE_DEFINITIONS.attribute_name%type) IS
      select attribute_id
      from PAY_BAL_ATTRIBUTE_DEFINITIONS
      where attribute_name = c_attribute_name
      ;

   /*bug8711855 - Modified to fetch defined_balance_ids of Lump Sum E balances*/
   CURSOR  c_single_lumpsum_E_payment  IS
   SELECT decode(pbt.balance_name,
                              'Lump Sum E Payments', 1
                             ,'Retro Earnings Leave Loading GT 12 Mths Amount', 2
                             ,'Retro Earnings Spread GT 12 Mths Amount', 3
                             ,'Retro Pre Tax GT 12 Mths Amount', 4) sort_index
               , pdb.defined_balance_id defined_balance_id
   FROM  pay_balance_types      pbt,
         pay_defined_balances   pdb,
         pay_balance_dimensions pbd
   WHERE pbt.legislation_code = 'AU'
   AND  pbt.balance_name in ( 'Lump Sum E Payments'
                             ,'Retro Earnings Leave Loading GT 12 Mths Amount'
                             ,'Retro Earnings Spread GT 12 Mths Amount'
                             ,'Retro Pre Tax GT 12 Mths Amount')
   AND  pbt.balance_type_id = pdb.balance_type_id
   AND  pbd.balance_dimension_id = pdb.balance_dimension_id
   AND  pbd.dimension_name = '_ASG_LE_PTD'
   order by sort_index;

  l_fin_year_date DATE;

/* End Bug 6470581 */

  l_procedure constant varchar2(80) := g_package || '.initialization_code';
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Start of initialization_code',1);
  end if;
  --
  open c_union_balance;
  fetch c_union_balance into g_balance_type_id;
  close c_union_balance;
  --
  --
  open c_le_ytd_dimension_id;
  fetch c_le_ytd_dimension_id into g_dimension_id;
  close c_le_ytd_dimension_id;
  --
  p_balance_value_tab.delete;
  for csr_rec in c_get_defined_balance_id
  loop
     p_balance_value_tab(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;
  end loop;

  if g_debug then
     hr_utility.set_location('Defined Balance Ids for balances are:' , 15);
     hr_utility.trace('--------------------------------------------');
     hr_utility.trace('CDEP                    ===>' || p_balance_value_tab(1).defined_balance_id);
     hr_utility.trace('Leave Payments Marginal ===>' || p_balance_value_tab(2).defined_balance_id);
     hr_utility.trace('Earnings_Total          ===>' || p_balance_value_tab(16).defined_balance_id);
     hr_utility.trace('Workplace Giving        ===>' || p_balance_value_tab(17).defined_balance_id); /*4015082 */
     hr_utility.trace('Lump Sum A Deductions   ===>' || p_balance_value_tab(3).defined_balance_id);
     hr_utility.trace('Lump Sum A Payments     ===>' || p_balance_value_tab(4).defined_balance_id);
     hr_utility.trace('Lump Sum B Deductions   ===>' || p_balance_value_tab(5).defined_balance_id);
     hr_utility.trace('Lump Sum B Payments     ===>' || p_balance_value_tab(6).defined_balance_id);
     hr_utility.trace('Lump Sum C Deductions   ===>' || p_balance_value_tab(7).defined_balance_id);
     hr_utility.trace('Lump Sum C Payments     ===>' || p_balance_value_tab(8).defined_balance_id);
     hr_utility.trace('Lump Sum D Payments     ===>' || p_balance_value_tab(9).defined_balance_id);
     hr_utility.trace('Total_Tax_Deduction     ===>' || p_balance_value_tab(10).defined_balance_id);
     hr_utility.trace('Termination Deductions  ===>' || p_balance_value_tab(11).defined_balance_id);
     hr_utility.trace('Union Fees              ===>' || p_balance_value_tab(13).defined_balance_id);
     hr_utility.trace('Invalidity Payments     ===>' || p_balance_value_tab(14).defined_balance_id);
     hr_utility.trace('Lump Sum E Payments     ===>' || p_balance_value_tab(15).defined_balance_id);
     hr_utility.trace('ETP Deductions Transitional Not Part of Prev Term      ===>' || p_balance_value_tab(18).defined_balance_id);/*Begin  Bug 6192381 */
     hr_utility.trace('ETP Deductions Transitional Part of Prev Term          ===>' || p_balance_value_tab(19).defined_balance_id);
     hr_utility.trace('ETP Deductions Life Benefit Not Part of Prev Term      ===>' || p_balance_value_tab(20).defined_balance_id);
     hr_utility.trace('ETP Deductions Life Benefit Part of Prev Term          ===>' || p_balance_value_tab(21).defined_balance_id);
     hr_utility.trace('Invalidity Payments Life Benefit Not Part of Prev Term  ===>' || p_balance_value_tab(22).defined_balance_id);
     hr_utility.trace('Invalidity Payments Life Benefit Part of Prev Term      ===>' || p_balance_value_tab(23).defined_balance_id);
     hr_utility.trace('Invalidity Payments Transitional Not Part of Prev Term  ===>' || p_balance_value_tab(24).defined_balance_id);
     hr_utility.trace('Invalidity Payments Transitional Part of Prev Term      ===>' || p_balance_value_tab(25).defined_balance_id);/*End  Bug 6192381 */
     hr_utility.trace('Reportable Employer Superannuation Contributions      ===>' || p_balance_value_tab(26).defined_balance_id);/*Begin 8315198*/
     hr_utility.trace('Exempt Foreign Employment Income      ===>' || p_balance_value_tab(12).defined_balance_id);/*End 8315198*/
     hr_utility.trace('Retro Earnings Leave Loading GT 12 Mths Amount     ===>' || p_balance_value_tab(27).defined_balance_id); -- start 8711855
     hr_utility.trace('Retro Earnings Spread GT 12 Mths Amount    ===>' || p_balance_value_tab(28).defined_balance_id);
     hr_utility.trace('Retro Pre Tax GT 12 Mths Amount     ===>' || p_balance_value_tab(29).defined_balance_id); -- end 8711855
  end if;

/*Bug 8711855 For fetching Defined Balance Id's for Lump Sum E Balances_PTD */
  p_lump_sum_E_ptd_tab.delete;
  for csr_rec in c_single_lumpsum_E_payment loop
     p_lump_sum_E_ptd_tab(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;
  end loop;

  if g_debug then
     hr_utility.set_location('Defined Balance Ids for Lump Sume E PTD are:' , 15);
     hr_utility.trace('--------------------------------------------');
     hr_utility.trace('Lump Sum E Payments   ===>' || p_lump_sum_E_ptd_tab(1).defined_balance_id);
     hr_utility.trace('Retro Earnings Leave Loading GT 12 Mths Amount   ===>' || p_lump_sum_E_ptd_tab(2).defined_balance_id);
     hr_utility.trace('Retro Earnings Spread GT 12 Mths Amount   ===>' || p_lump_sum_E_ptd_tab(3).defined_balance_id);
     hr_utility.trace('Retro Pre Tax GT 12 Mths Amount  ===>' || p_lump_sum_E_ptd_tab(4).defined_balance_id);
  end if;

/*Bug 6192381 For fetching Defined Balance Id's for new ETP payment Balances */
  p_etp_balance_value_tab.delete;
  for csr_etp_rec in c_get_etp_defined_balance_id
  loop
     p_etp_balance_value_tab(csr_etp_rec.sort_index).defined_balance_id := csr_etp_rec.defined_balance_id;
  end loop;


  if g_debug then
     hr_utility.set_location('Defined Balance Ids for ETP Payment balances are:' , 15);
     hr_utility.trace('--------------------------------------------');
     hr_utility.trace('ETP Payments Transitional Not Part of Prev Term   ===>' || p_etp_balance_value_tab(1).defined_balance_id);
     hr_utility.trace('ETP Payments Transitional Part of Prev Term       ===>' || p_etp_balance_value_tab(2).defined_balance_id);
     hr_utility.trace('ETP Payments Life Benefit Not Part of Prev Term   ===>' || p_etp_balance_value_tab(3).defined_balance_id);
     hr_utility.trace('ETP Payments Life Benefit Part of Prev Term       ===>' || p_etp_balance_value_tab(4).defined_balance_id);
     hr_utility.trace('Lump Sum C Payments                               ===>' || p_etp_balance_value_tab(13).defined_balance_id);
    /* Start 8769345 */
     hr_utility.trace('ETP Tax Free Payments Transitional Not Part of Prev Term  ===>' || p_etp_balance_value_tab(5).defined_balance_id);
     hr_utility.trace('ETP Taxable Payments Transitional Not Part of Prev Term   ===>' || p_etp_balance_value_tab(6).defined_balance_id);
     hr_utility.trace('ETP Tax Free Payments Transitional Part of Prev Term      ===>' || p_etp_balance_value_tab(7).defined_balance_id);
     hr_utility.trace('ETP Taxable Payments Transitional Part of Prev Term       ===>' || p_etp_balance_value_tab(8).defined_balance_id);
     hr_utility.trace('ETP Tax Free Payments Life Benefit Not Part of Prev Term  ===>' || p_etp_balance_value_tab(9).defined_balance_id);
     hr_utility.trace('ETP Taxable Payments Life Benefit Not Part of Prev Term   ===>' || p_etp_balance_value_tab(10).defined_balance_id);
     hr_utility.trace('ETP Tax Free Payments Life Benefit Part of Prev Term      ===>' || p_etp_balance_value_tab(11).defined_balance_id);
     hr_utility.trace('ETP Taxable Payments Life Benefit Part of Prev Term       ===>' || p_etp_balance_value_tab(12).defined_balance_id);
    /* End 8769345 */
  end if;

  /* Bug 6470581 - Initialize g_payment_summary_type */
        g_payment_summary_type  := 'O';

  /* Bug 6470581 - Added code to initialize g_fbt_threshold */

        OPEN get_params(p_payroll_action_id);
        FETCH get_params INTO l_fin_year_date,g_business_group_id;
        CLOSE get_params;

        OPEN c_get_fbt_global (add_months(l_fin_year_date,-3));  /* Add_months included for bug 5333143 */
        FETCH c_get_fbt_global into g_fbt_threshold;
        CLOSE c_get_fbt_global;

  /* bug 7571001 - initialize g_attribute_id */
  open get_balance_attribute('AU_EOY_ALLOWANCE');
  fetch get_balance_attribute into g_attribute_id;
  close get_balance_attribute;

  if g_debug then
     hr_utility.set_location('g_fbt_threshold           '||g_fbt_threshold,19);
     hr_utility.set_location('End of initialization_code',20);
  end if;
   /* End Changes Bug 6470581 */
exception
  when others then
  if g_debug then
     hr_utility.set_location('Error in initialization_code',100);
  end if;
  raise;

end initialization_code;


/*
    Bug 7138494 - Added Function range_person_on
--------------------------------------------------------------------
    Name  : range_person_on
    Type  : Function
    Access: Private
    Description: Checks if RANGE_PERSON_ID is enabled for
                 Archive process.
  --------------------------------------------------------------------
*/

FUNCTION range_person_on
RETURN BOOLEAN
IS

 CURSOR csr_action_parameter is
  select parameter_value
  from pay_action_parameters
  where parameter_name = 'RANGE_PERSON_ID';

 CURSOR csr_range_format_param is
  select par.parameter_value
  from   pay_report_format_parameters par,
         pay_report_format_mappings_f map
  where  map.report_format_mapping_id = par.report_format_mapping_id
  and    map.report_type = 'AU_PAYMENT_SUMMARY'
  and    map.report_format = 'AU_PAYMENT_SUMMARY'
  and    map.report_qualifier = 'AU'
  and    par.parameter_name = 'RANGE_PERSON_ID'; -- Bug fix 5567246

  l_return boolean;
  l_action_param_val varchar2(30);
  l_report_param_val varchar2(30);

BEGIN

    g_debug := hr_utility.debug_enabled;

    IF g_debug
    THEN
        hr_utility.set_location('range_person_on',10);
    END IF;

  BEGIN

    open csr_action_parameter;
    fetch csr_action_parameter into l_action_param_val;
    close csr_action_parameter;

    IF g_debug
    THEN
        hr_utility.set_location('range_person_on',20);
    END IF;

    open csr_range_format_param;
    fetch csr_range_format_param into l_report_param_val;
    close csr_range_format_param;
    IF g_debug
    THEN
        hr_utility.set_location('range_person_on',30);
    END IF;
  EXCEPTION WHEN NO_DATA_FOUND THEN
     l_return := FALSE;
  END;
  --
    IF g_debug
    THEN
        hr_utility.set_location('range_person_on',40);
    END IF;

  IF l_action_param_val = 'Y' AND l_report_param_val = 'Y' THEN
     l_return := TRUE;

    IF g_debug
    THEN
             hr_utility.trace('Range Person = True');
    END IF;
  ELSE
     l_return := FALSE;
  END IF;
--
 RETURN l_return;
--
END range_person_on;

  --------------------------------------------------------------------+
  -- This procedure further restricts the assignment_id's
  -- returned by range_code
  --------------------------------------------------------------------+

-- this procedure filters the assignments selected by range_code procedure
-- it then calls hr_nonrun.insact to create an assignment  id
-- the cursor to select assignment action selects  three types of employees
-- all current assignments eligible  for archival ,
-- terminated employees eligible for archival
-- and all those assignment ids who have received a Fringe benifit
-- component of more than $1000 for that FBT year
-- and have been terminated during the FBT year

procedure assignment_action_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_start_person_id    in per_all_people_f.person_id%type,
     p_end_person_id      in per_all_people_f.person_id%type,
     p_chunk              in number) is


     v_next_action_id  pay_assignment_actions.assignment_action_id%type;

     v_lst_year_start       date ;
     v_fbt_year_start       date ;
     v_lst_fbt_year_start   date ; --Bug#3661230
     v_fbt_year_end         date ;
     v_fin_year_start       date ;
     v_fin_year_end         date ;
     v_assignment_id        varchar2(50);
     v_registered_employer  varchar2(50);
     v_financial_year       varchar2(50);
     v_payroll_id           varchar2(50);
     v_employee_type        varchar2(1);
     v_asg_id               number;
     v_reg_emp              number;
     l_lst_yr_term          varchar(10); --Bug#3661230

     ----------------------------------------------+
     -- cursor to get the archive parameters
     ----------------------------------------------+
  cursor get_params(c_payroll_action_id  per_all_assignments_f.assignment_id%type)
  is
  select to_date('01-07-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') Financial_year_start
        ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),6,4),'DD-MM-YYYY') Financial_year_end
        ,to_date('01-04-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') FBT_year_start
        ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY') FBT_year_end
        ,decode(pay_core_utils.get_parameter('EMPLOYEE_TYPE',legislative_parameters),'C','Y','T','N','B','%')   Employee_type
        ,pay_core_utils.get_parameter('REGISTERED_EMPLOYER',legislative_parameters)                             Registered_Employer
        ,pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters)                                  Financial_year
        ,decode(pay_core_utils.get_parameter('ASSIGNMENT_ID',legislative_parameters),null,'%',
                pay_core_utils.get_parameter('ASSIGNMENT_ID',legislative_parameters))               Assignment_id
        ,decode(pay_core_utils.get_parameter('PAYROLL',legislative_parameters),null,'%',pay_core_utils.get_parameter('PAYROLL',legislative_parameters)) payroll_id
               ,pay_core_utils.get_parameter('LST_YR_TERM',legislative_parameters)              lst_yr_term    /*3661230*/
        ,pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters)               Business_group_id
  from  pay_payroll_actions
  where payroll_action_id = c_payroll_Action_id;

     ----------------------------------------------+
     -- cursor to restrict assignment ids
     ----------------------------------------------+
/* 4926521 Modified adn put group by in 2 sub queries for performacne */
/* 5099419 Removed fix for bug 4926521 */
  Cursor process_assignments(c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
                           c_start_person_id    in per_all_people_f.person_id%type,
                           c_end_person_id      in per_all_people_f.person_id%type)
      is
 select /*+ INDEX(p per_people_f_pk)
            INDEX(a per_assignments_f_fk1)
            INDEX(a per_assignments_f_N12)
            INDEX(pa pay_payroll_actions_pk)
            INDEX(pps per_periods_of_service_n3)
        */ distinct a.assignment_id
    from  per_people_f      p /*Bug3043049*/
         ,per_assignments_f a /*Bug3043049*/
         ,pay_payroll_actions   pa
         ,per_periods_of_service  pps
   where  pa.payroll_action_id       = c_payroll_action_id
    and   p.person_id                between c_start_person_id and c_end_person_id
    and   p.person_id                = a.person_id
    and   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (v_fin_year_end)),1,'Y','N')) LIKE v_employee_type --Bug#3744930
    and pps.period_of_service_id = a.period_of_service_id
    and   a.business_group_id        = pa.business_group_id
    and   to_char(a.assignment_id)      like v_assignment_id
    and   pps.person_id              = p.person_id
    and   nvl(pps.actual_termination_date, v_lst_year_start) >= v_lst_year_start  -- Bug3661230, Bug3048724 ,Bug 3263659
    and v_fin_year_end between p.effective_start_date and p.effective_end_date
    --  and   least(nvl(pps.actual_termination_date,v_fin_year_end),v_fin_year_end) between a.effective_start_date and a.effective_end_date -- Bug 3815301
    and   a.effective_end_date = (select max(effective_end_date) /* 4377367 */
                              From  per_assignments_f iipaf
                  WHERE iipaf.assignment_id  = a.assignment_id
                    and iipaf.effective_end_date >= v_fbt_year_start
                    and iipaf.effective_start_date <= v_fin_year_end
                AND iipaf.payroll_id IS NOT NULL) /*Bug# 4653934*/
    and   a.payroll_id like v_payroll_id  -- Bug 3815301
    and   exists
         (select  /*+ INDEX(rpac PAY_ASSIGNMENT_ACTIONS_N51)
                      INDEX(rppa PAY_PAYROLL_ACTIONS_N51*/ ''
           from
                 pay_payroll_actions           rppa
                 ,pay_assignment_actions        rpac  /*Bug3048962 */
         ,per_assignments_f             paaf  /*Bug 3815301 */
                 where ( rppa.effective_date between  v_fin_year_start  and v_fin_year_end
                          or ( pps.actual_termination_date between v_lst_fbt_year_start  and v_fbt_year_end /*Bug3263659 */ --Bug#3661230
                  and rppa.effective_date between  v_fbt_year_start  and v_fbt_year_end
                              and pay_balance_pkg.get_value(g_fbt_defined_balance_id,rpac.assignment_action_id
                                                       + decode(rppa.payroll_id, 0, 0, 0),v_reg_emp,null,null,null,null) > to_number(g_fbt_threshold)) /* Bug 5708255 */ --2610141
                      )
                   and  rppa.action_type            in ('R','Q','B','I')
                   and  rpac.tax_unit_id            = v_reg_emp
                   and  rppa.payroll_action_id      = rpac.payroll_action_id
                   and  rpac.action_status='C'
                   and  rpac.assignment_id              = paaf.assignment_id
           and  rppa.payroll_id                 = paaf.payroll_id  /*Bug 3815301 */
           and  paaf.assignment_id      = a.assignment_id
           and  rppa.effective_date between paaf.effective_start_date and paaf.effective_end_date /*Bug 3815301 */
                  )
    and not exists
         (select  distinct paat.assignment_id
                 from  pay_action_interlocks  pail,
                       pay_assignment_actions paat,
                       pay_payroll_actions paas
                 where paat.assignment_id   = a.assignment_id
                   and paas.action_type     ='X'
                   and paas.action_status   ='C'
                   and paas.report_type     ='AU_PAYMENT_SUMMARY_REPORT'
                   and pail.locking_action_id  = paat.assignment_action_id
                   and paat.payroll_action_id = paas.payroll_action_id
                   and pay_core_utils.get_parameter('FINANCIAL_YEAR',paas.legislative_parameters) = v_financial_year
           and pay_core_utils.get_parameter('REGISTERED_EMPLOYER',paas.legislative_parameters) = v_reg_emp
           )
         and not exists ( select  aei_information1
                 from  per_assignment_extra_info,
                       hr_lookups
                where  assignment_id        = a.assignment_id
                  and  aei_information1     is not null
                  and  aei_information1     = lookup_code
          and  nvl(aei_information2,v_reg_emp)     = decode(aei_information2,'-999',aei_information2,v_reg_emp) -- 2610141 and 4000955
                  and lookup_type ='AU_PS_FINANCIAL_YEAR'
                  and meaning = v_financial_year
         );

/*Bug 4000955  Modified subquery of process_assignments not to archive employees for
               any legal employer if Manual PS is issued for 'ALL' legal employers or without any legal employer
           If the Manual PS is issued for 'ALL' the legal employers the aei_information2 would be -999 done
           in the view HR_AU_LEG_EMP_AEI_V */

/* Cursor added for bug3019374 -- Processed when a single assignment is entered*/


  Cursor process_assignments_only(c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
                           c_start_person_id    in per_all_people_f.person_id%type,
                           c_end_person_id      in per_all_people_f.person_id%type)
      is
 select  distinct a.assignment_id
   from  per_people_f      p /*Bug3043049*/
         ,per_assignments_f a /*Bug3043049*/
         ,pay_payroll_actions   pa
         ,per_periods_of_service  pps
   where  pa.payroll_action_id       = c_payroll_action_id
    and   p.person_id                between c_start_person_id and c_end_person_id
    and   p.person_id                = a.person_id
    and decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (v_fin_year_end)),1,'Y','N')) LIKE v_employee_type ----Bug#3744930
    and pps.period_of_service_id = a.period_of_service_id
    and   a.business_group_id        = pa.business_group_id
    and   a.assignment_id      = v_assignment_id
    and   pps.person_id              = p.person_id
    and   nvl(pps.actual_termination_date, v_lst_year_start) >= v_lst_year_start   -- Bug3661230 , Bug3048724, Bug 3263659
    and   v_fin_year_end between p.effective_start_date and p.effective_end_date
--    and   least(nvl(pps.actual_termination_date,v_fin_year_end),v_fin_year_end) between a.effective_start_date and a.effective_end_date -- Bug 3815301
    and   a.effective_end_date = (select max(effective_end_date) /* 4377367 */
                                       From  per_assignments_f iipaf
                                       WHERE iipaf.assignment_id  = a.assignment_id
                                       and iipaf.effective_end_date >= v_fbt_year_start
                                       and iipaf.effective_start_date <= v_fin_year_end
                                  AND iipaf.payroll_id IS NOT NULL) /*Bug# 4653934*/
    and   a.payroll_id like v_payroll_id  -- Bug 3815301
    and   exists
         (select  /*+ INDEX(rpac PAY_ASSIGNMENT_ACTIONS_N51)
                      INDEX(rppa PAY_PAYROLL_ACTIONS_N51 */ ''
          from    pay_payroll_actions           rppa
                 ,pay_assignment_actions        rpac/*Bug3048962 */
         ,per_assignments_f             paaf  /*Bug 3815301 */
                 where ( rppa.effective_date between  v_fin_year_start  and v_fin_year_end
                          or ( pps.actual_termination_date between v_lst_fbt_year_start  and v_fbt_year_end /*Bug3263659 */ --Bug#3661230
                  and  rppa.effective_date between  v_fbt_year_start  and v_fbt_year_end
                              and pay_balance_pkg.get_value(g_fbt_defined_balance_id,rpac.assignment_action_id
                                                       + decode(rppa.payroll_id, 0, 0, 0),v_reg_emp,null,null,null,null) > to_number(g_fbt_threshold)) /* Bug 5708255 */ --2610141
                      )
                   and  rppa.action_type            in ('R','Q','B','I')
                   and  rpac.tax_unit_id            = v_reg_emp
                   and  rppa.payroll_action_id      = rpac.payroll_action_id
                   and  rpac.action_status='C'
                   and  rpac.assignment_id              = paaf.assignment_id
           and  rppa.payroll_id                 = paaf.payroll_id  /*Bug 3815301 */
           and  paaf.assignment_id      = v_assignment_id
           and  rppa.effective_date between paaf.effective_start_date and paaf.effective_end_date /*Bug 3815301 */
                  )
    and not exists
         (select  distinct paat.assignment_id
                 from  pay_action_interlocks  pail,
                       pay_assignment_actions paat,
                       pay_payroll_actions paas
                 where paat.assignment_id   = a.assignment_id
                   and paas.action_type     ='X'
                   and paas.action_status   ='C'
                   and paas.report_type     ='AU_PAYMENT_SUMMARY_REPORT'
                   and pail.locking_action_id  = paat.assignment_action_id
                   and paat.payroll_action_id = paas.payroll_action_id
                   and pay_core_utils.get_parameter('FINANCIAL_YEAR',paas.legislative_parameters) = v_financial_year
           and pay_core_utils.get_parameter('REGISTERED_EMPLOYER',paas.legislative_parameters) = v_reg_emp) --2610141
         and not exists ( select  aei_information1
                 from  per_assignment_extra_info,
                       hr_lookups
                where  assignment_id        = a.assignment_id
                  and  aei_information1     is not null
                  and  aei_information1     = lookup_code
          and  nvl(aei_information2,v_reg_emp)     = decode(aei_information2,'-999',aei_information2,v_reg_emp) -- 2610141 and 4000955
                  and lookup_type ='AU_PS_FINANCIAL_YEAR'
                  and meaning = v_financial_year);


/*Bug 4000955  Modified subquery of process_assignments_only not to archive employees for
               any legal employer if Manual PS is issued for 'ALL' legal employers or without any legal employer
           If the Manual PS is issued for 'ALL' the legal employers the aei_information2 would be -999 done
           in the view HR_AU_LEG_EMP_AEI_V
*/


/*
   Bug 7138494 - Added Cursor for Range Person
               - Uses person_id in pay_population_ranges
  --------------------------------------------------------------------+
  -- Cursor      : range_process_assignments
  -- Description : Fetches assignments For Recconciling Payment Summary
  --               Returns DISTINCT assignment_id
  --               Used when RANGE_PERSON_ID feature is enabled
  --------------------------------------------------------------------+
*/

CURSOR range_process_assignments(c_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE,
                                 c_chunk IN NUMBER)
IS
SELECT /*+ INDEX(pap per_people_f_pk)
             INDEX(rppa pay_payroll_actions_pk)
             INDEX(ppr PAY_POPULATION_RANGES_N4)
             INDEX(paa per_assignments_f_N12)
             INDEX(pps per_periods_of_service_PK)
        */ a.assignment_id
    FROM  per_people_f      p /*Bug3043049*/
         ,per_assignments_f a /*Bug3043049*/
         ,pay_payroll_actions   pa
         ,per_periods_of_service  pps
         ,pay_population_ranges   ppr
   WHERE  pa.payroll_action_id       = c_payroll_action_id
    AND   pa.payroll_action_id       = ppr.payroll_action_id
    AND   ppr.chunk_number           = c_chunk
    AND   p.person_id                = ppr.person_id
    AND   p.person_id                = a.person_id
    AND   decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (v_fin_year_end)),1,'Y','N')) LIKE v_employee_type --Bug#3744930
    AND   pps.period_of_service_id = a.period_of_service_id
    AND   a.business_group_id        = pa.business_group_id
    AND   to_char(a.assignment_id)      LIKE v_assignment_id
    AND   pps.person_id              = p.person_id
    AND   nvl(pps.actual_termination_date, v_lst_year_start) >= v_lst_year_start  -- Bug3661230, Bug3048724 ,Bug 3263659
    AND   v_fin_year_end BETWEEN p.effective_start_date AND p.effective_end_date
    AND   a.effective_end_date = (SELECT MAX(effective_end_date) /* 4377367 */
                                  FROM  per_assignments_f iipaf
                                  WHERE iipaf.assignment_id  = a.assignment_id
                                  AND iipaf.effective_end_date >= v_fbt_year_start
                                  AND iipaf.effective_start_date <= v_fin_year_end
                                  AND iipaf.payroll_id IS NOT NULL) /*Bug# 4653934*/
    AND   a.payroll_id LIKE v_payroll_id  -- Bug 3815301
    AND   EXISTS
         (SELECT  /*+ INDEX(rpac PAY_ASSIGNMENT_ACTIONS_N51)
                      INDEX(rppa PAY_PAYROLL_ACTIONS_N51*/ ''
           FROM
                 pay_payroll_actions           rppa
                 ,pay_assignment_actions        rpac  /*Bug3048962 */
                 ,per_assignments_f             paaf  /*Bug 3815301 */
           WHERE ( rppa.effective_date BETWEEN  v_fin_year_start  AND v_fin_year_end
                          OR ( pps.actual_termination_date BETWEEN v_lst_fbt_year_start  AND v_fbt_year_end /*Bug3263659 */ --Bug#3661230
                               AND rppa.effective_date BETWEEN  v_fbt_year_start  AND v_fbt_year_end
                               AND pay_balance_pkg.get_value(g_fbt_defined_balance_id,rpac.assignment_action_id
                                                       + decode(rppa.payroll_id, 0, 0, 0),v_reg_emp,null,null,null,null) > to_number(g_fbt_threshold)
                             )
                 )
           AND  rppa.action_type             in ('R','Q','B','I')
           AND  rpac.tax_unit_id                = v_reg_emp
           AND  rppa.payroll_action_id          = rpac.payroll_action_id
           AND  rpac.action_status              ='C'
           AND  rpac.assignment_id              = paaf.assignment_id
           AND  rppa.payroll_id                 = paaf.payroll_id  /*Bug 3815301 */
           AND  paaf.assignment_id              = a.assignment_id
           AND  rppa.effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date /*Bug 3815301 */
                  )
    AND NOT EXISTS
         (SELECT  paat.assignment_id
            FROM  pay_action_interlocks  pail,
                 pay_assignment_actions paat,
                 pay_payroll_actions paas
            WHERE paat.assignment_id   = a.assignment_id
            AND paas.action_type     ='X'
            AND paas.action_status   ='C'
            AND paas.report_type     ='AU_PAYMENT_SUMMARY_REPORT'
            AND pail.locking_action_id  = paat.assignment_action_id
            AND paat.payroll_action_id = paas.payroll_action_id
            AND pay_core_utils.get_parameter('FINANCIAL_YEAR',paas.legislative_parameters) = v_financial_year
            AND pay_core_utils.get_parameter('REGISTERED_EMPLOYER',paas.legislative_parameters) = v_reg_emp
           )
    AND NOT EXISTS
         ( SELECT  aei_information1
            FROM  per_assignment_extra_info,
                  hr_lookups
            WHERE  assignment_id        = a.assignment_id
            AND  aei_information1       IS NOT NULL
            AND  aei_information1       = lookup_code
            AND  nvl(aei_information2,v_reg_emp)     = decode(aei_information2,'-999',aei_information2,v_reg_emp) -- 2610141 and 4000955
            AND lookup_type             ='AU_PS_FINANCIAL_YEAR'
            AND meaning                 = v_financial_year
         );


  cursor   next_action_id is
  select   pay_assignment_actions_s.nextval
  from   dual;

/* Bug 5708255 */
  -------------------------------------------
  -- Added cursor to get value of global FBT_THRESHOLD
  --------------------------------------------
CURSOR  c_get_fbt_global(c_year_end DATE)
       IS
   SELECT  global_value
   FROM   ff_globals_f
    WHERE  global_name = 'FBT_THRESHOLD'
    AND    legislation_code = 'AU'
    AND    c_year_end BETWEEN effective_start_date
                          AND effective_end_date ;

--amit

Cursor c_fbt_balance is
  select    pdb.defined_balance_id
  from      pay_balance_types            pbt,
        pay_defined_balances         pdb,
        pay_balance_dimensions       pbd
  where  pbt.balance_name               ='Fringe Benefits'
  and  pbt.balance_type_id            = pdb.balance_type_id
  and  pdb.balance_dimension_id       = pbd.balance_dimension_id /* Bug 2501105 */
  and  pbd.legislation_code           ='AU'
  and  pbd.dimension_name             ='_ASG_LE_FBT_YTD' --2610141
  and  pbd.legislation_code = pbt.legislation_code
  and  pbd.legislation_code = pdb.legislation_code;



begin
  g_debug := hr_utility.debug_enabled;


  IF g_debug THEN
      hr_utility.set_location('Start of assignment_action_code',1);
  END IF;
  -------------------------------------------------------------
  -- get the paramters for archival process
  -------------------------------------------------------------
   open   get_params(p_payroll_action_id);
   fetch  get_params
    into  v_fin_year_start
         ,v_fin_year_end
         ,v_fbt_year_start
         ,v_fbt_year_end
         ,v_employee_type
         ,v_registered_employer
         ,v_financial_year
         ,v_assignment_id
         ,v_payroll_id
         ,l_lst_yr_term           /*Bug3661230*/
         ,g_business_group_id ;
   close get_params;

   /* The following check is introduced for Bug: 3701869. Parameter Last Year Termination has been introduced through
      Bug: 3263659. If the customer does not have this new functionality enabled, the default should work. Hence the
      check for the parameter if null has been introduced to make sure the correct fbt dates are set. */

   IF (l_lst_yr_term IS NULL) THEN
     l_lst_yr_term := 'Y';
   END IF;

   /**** Bug#3661230  **********/
   IF l_lst_yr_term = 'Y' THEN
     -- v_lst_year_start := ADD_MONTHS(v_fbt_year_start,-12); -- 3263659
     v_lst_year_start := ADD_MONTHS(v_fin_year_start,-12); -- 5395393
     v_lst_fbt_year_start := v_fbt_year_start;
   ELSE
     v_lst_year_start := TO_DATE('01-01-1900','DD-MM-YYYY');
     v_lst_fbt_year_start := TO_DATE('01-01-1900','DD-MM-YYYY');
   END IF;
  /* end of Bug#3661230 **/

---amit
    If g_fbt_defined_balance_id is null OR g_fbt_defined_balance_id =0 Then
       Open  c_fbt_balance;
       Fetch c_fbt_balance into  g_fbt_defined_balance_id;
       Close c_fbt_balance;
   End if;
----amit

        /* Bug 5708255 */
        open c_get_fbt_global (add_months(v_fin_year_end,-3));  /* Add_months included for bug 5333143 */
        fetch c_get_fbt_global into g_fbt_threshold;
        close c_get_fbt_global;

        hr_utility.set_location('Anitha g_fbt_threshold Value in ass_action_code        '||g_fbt_threshold,1000);

  v_reg_emp := to_number(v_registered_employer); /*added-sun*/

if (v_assignment_id <> '%' and v_payroll_id <> '%') then /*Added for bug 3019374*/

  for process_rec in process_assignments_only(p_payroll_action_id,
                                              p_start_person_id,
                                              p_end_person_id)
  Loop     /* Bug: 2881272 - Removed the temporary check which was included during the fix 2822446 */
     open next_action_id;
     fetch next_action_id into v_next_action_id;
     close next_action_id;
     IF g_debug THEN
        hr_utility.set_location('Calling hr_nonrun_asact.insact for assignment id :'||process_rec.assignment_id,2);
     END if;

     hr_nonrun_asact.insact(v_next_action_id,
                            process_rec.assignment_id,
                            p_payroll_action_id,
                            p_chunk,
                            null);
     IF g_debug THEN
        hr_utility.set_location('After calling hr_nonrun_asact.insact',3);
     END if;
  end loop;

else
/* Multiple Assignments */

   /* Bug 7138494 - Added Changes for Range Person
       - Call Cursor using pay_population_ranges if Range Person Enabled
         Else call Old Cursor
   */

IF range_person_on
THEN

    FOR csr_rec IN range_process_assignments(p_payroll_action_id
                                            ,p_chunk)
    LOOP
        OPEN  next_action_id;
        FETCH next_action_id INTO v_next_action_id;
        CLOSE next_action_id;
        IF g_debug THEN
           hr_utility.set_location('Calling hr_nonrun_asact.insact for assignment id :'||csr_rec.assignment_id,2);
        END if;

            hr_nonrun_asact.insact(v_next_action_id,
                                   csr_rec.assignment_id,
                                   p_payroll_action_id,
                                   p_chunk,
                                   null);
            IF g_debug THEN
               hr_utility.set_location('After calling hr_nonrun_asact.insact',3);
            END IF;
    END LOOP;

ELSE /* Retain Old Logic - No Range Person */

  for process_rec in process_assignments (p_payroll_action_id,
                                          p_start_person_id,
                                          p_end_person_id)
   Loop
        open next_action_id;
            fetch next_action_id into v_next_action_id;
            close next_action_id;
        IF g_debug THEN
           hr_utility.set_location('Calling hr_nonrun_asact.insact for assignment id :'||process_rec.assignment_id,2);
        END if;
            hr_nonrun_asact.insact(v_next_action_id,
                           process_rec.assignment_id,
                           p_payroll_action_id,
                           p_chunk,
                           null);
            IF g_debug THEN
           hr_utility.set_location('After calling hr_nonrun_asact.insact',3);
        END if;
  end loop;

END IF; /* End Range Person check */

end if;

  IF g_debug THEN
      hr_utility.set_location('End of assignment_action_code',4);
  END if;


exception
  when others then
    IF g_debug THEN
        hr_utility.set_location('error raised in assignment_action_code procedure ',5);
    END if;
    raise;
end assignment_action_code;


---------------------------------
  --Functions
  function get_max_effective_person_date (p_person_id per_all_people_f .person_id%type)
  return date
  is
l_effective_date date ;
cursor c_effective_date
      is
    select  max(effective_start_date)
    from per_all_people_f  p
    where person_id =p_person_id ;
begin
   open c_effective_date;
   fetch c_effective_date into l_effective_date ;
   close c_effective_date ;
   return l_effective_date ;
end;

  function get_max_effective_asg_date(p_asg_id per_all_assignments_f .assignment_id%type)
  return date
  is
l_effective_date date ;
cursor c_effective_date
      is
select  max(effective_start_date)
      from per_all_assignments_f  p
   where assignment_id =p_asg_id ;
begin
   open c_effective_date;
   fetch c_effective_date into l_effective_date ;
   close c_effective_date ;
   return l_effective_date ;
end;



   ------------------------------------------------------------------------+
    -- Creates the Extract Archive Database Item.
    -- Called from
    -- 1. Archive_supplier_details
    -- 2. Archive_employer_details
    -- 3. Archive_employee_details
    -- 4. Archive_Balance_Details
    ------------------------------------------------------------------------+


procedure create_extract_archive_details
    (p_assignment_action_id  in     pay_assignment_actions.assignment_action_id%type,
     p_user_entity_name      in     ff_user_entities.user_entity_name%type,
     p_value                 in out nocopy ff_archive_items.value%type) is



  cursor  get_user_entity_id(c_user_entity_name in varchar2)
      is
  select  fue.user_entity_id,
          dbi.data_type
    from  ff_user_entities  fue,
          ff_database_items dbi
   where  user_entity_name   =c_user_entity_name
   and    fue.user_entity_id =dbi.user_entity_id;

   v_full_name           per_all_people_f.full_name%type;
   v_user_entity_id      ff_user_entities.user_entity_id%type;
   v_archive_item_id         ff_archive_items.archive_item_id%type;
   v_data_type               ff_database_items.data_type%type;
   v_object_version_number   ff_archive_items.object_version_number%type;
   v_some_warning            boolean;

   i_index      NUMBER;         /* Bug 6470581 */

begin
     g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
      hr_utility.set_location('Start of create_extract_archive_details',15);
      hr_utility.set_location('Assignment action id is :' || p_assignment_action_id,16);
      hr_utility.set_location('Database item name is   :' || p_user_entity_name,16);
      hr_utility.set_location('Value is                :' || p_value,17);
  END if;

    /* Bug 6470581 - Added Changes for Amended Payment Summary Type
       i. If g_payment_summary_type = 'O' (Original) - Archive values in ff_archive_items
      ii. If g_payment_summary_type = 'A' (Amended)  - Add values to PL/SQL Table p_all_dbi_tab
    */

IF g_payment_summary_type = 'O'
THEN

  open get_user_entity_id (p_user_entity_name);
     hr_utility.trace('the value of the user entity is '||p_user_entity_name);
  fetch get_user_entity_id into v_user_Entity_id,
                                v_data_type;

   -----------------------------------------------------------------------------------------------+
  -- if the archive item datatype is date then convert
  -- it into canonical format before archiving
  -- this is required because before inserting into ff_archive_items
  -- ff_archive_api validates the value
   -----------------------------------------------------------------------------------------------+

  if (v_data_type = 'D') then
    p_value:= to_char(to_date(p_value,'DDMMYYYY'),fnd_date.canonical_mask);
  end if;


  if get_user_entity_id%found then

    close get_user_entity_id;
    ff_archive_api.create_archive_item
         (p_validate              => false                    -- boolean  in default
         ,p_archive_item_id       => v_archive_item_id        -- number   out
         ,p_user_entity_id        => v_user_entity_id         -- number   in
         ,p_archive_value         => p_value                  -- varchar2 in
         ,p_archive_type          => 'AAP'                    -- varchar2 in default
         ,p_action_id             => p_assignment_action_id   -- number   in
         ,p_legislation_code      => 'AU'                     -- varchar2 in
         ,p_object_version_number => v_object_version_number  -- number   out
         ,p_context_name1         => 'ASSIGNMENT_ACTION_ID'   -- varchar2 in default
         ,p_context1              => p_assignment_action_id   -- varchar2 in default
         ,p_some_warning          => v_some_warning);         -- boolean  out
  else

    close get_user_entity_id;
     IF g_debug THEN
     hr_utility.set_location('User entity not found :'||p_user_entity_name,20);
     END if;
  end if;

ELSE

          OPEN get_user_entity_id (p_user_entity_name);
          FETCH get_user_entity_id INTO v_user_Entity_id,
                                        v_data_type;
          IF (v_data_type = 'D') THEN
            p_value:= to_char(to_date(p_value,'DDMMYYYY'),fnd_date.canonical_mask);
          END IF;

          IF get_user_entity_id%FOUND
          THEN
                CLOSE get_user_entity_id;
                IF g_debug
                THEN
                        hr_utility.set_location('Amended Payment Summary - Update the archive PL/SQL table',2000);
                        hr_utility.set_location('p_user_entity_name     '||p_user_entity_name,2000);
                END IF;
                i_index := NVL(p_all_dbi_tab.LAST,-1) + 1;
                p_all_dbi_tab(i_index).db_item_name  := p_user_entity_name;
                p_all_dbi_tab(i_index).db_item_value := p_value;

                IF g_debug
                THEN
                        hr_utility.set_location('Updated Index         '||i_index,2010);
                END IF;
        ELSE
                CLOSE get_user_entity_id;
                IF g_debug THEN
                        hr_utility.set_location('User entity not found :'||p_user_entity_name,2020);
                END if;
        END IF;
END IF;

  IF g_debug THEN
     hr_utility.set_location('End of create_extract_archive_detail',18);
  END if;

exception
  when others then
  if get_user_entity_id%isopen then
   close get_user_entity_id;
   IF g_debug THEN
     hr_utility.set_location('closing..',117);
   END if;
  end if;
  IF g_debug THEN
     hr_utility.set_location('Error in create_extract_archive_details',20);
  END if;
  raise;
end create_extract_archive_details;

----------------------------------------------------------------------+
-- procedure to archive balance details
-- Passed Balance name Bug #2454595
----------------------------------------------------------------------+

procedure archive_balance_details
     (p_assignment_action_id    in   pay_assignment_actions.ASSIGNMENT_ACTION_ID%TYPE
     ,p_max_assignment_action_id    in   pay_assignment_actions.ASSIGNMENT_ACTION_ID%TYPE --2610141
     ,p_registered_employer     in   NUMBER
     ,p_database_item_name      in   ff_database_items.user_name%TYPE
     ,p_balance_name            in   pay_balance_types.balance_name%TYPE
     ,p_legislation_code        in   pay_defined_balances.legislation_code%TYPE
     ,p_year_start              in   DATE
     ,p_year_end                in   DATE
     ,p_assignment_id           in   pay_assignment_actions.ASSIGNMENT_ID%type
     ,p_payroll_action_id       in   pay_payroll_actions.payroll_action_id%TYPE
     ,p_bal_value       OUT  NOCOPY varchar2) IS  -- Bug 3098353

      v_bal_value                    varchar2(20);
      v_earnings_ytd                 varchar2(20);
      v_lump_sum_E_ytd               varchar2(20);
      v_adj_lump_sum_E_ptd           number;
      v_adj_lump_sum_pre_tax         number; -- Bug 9190980
      v_effective_date               DATE;

   -------------------------------------------------------------------+
   -- Cursor to calculate balances for a given database item
   -- To calculate balances we require defined balance id and
   -- that can be retrieved only from pay_defined_balances
   -- first cursor is to retrive Fringe Benefits Balance
   -- second cursor is to retrive other Balance values
   -------------------------------------------------------------------+
   -- cursors modified for bug #1768813
   -------------------------------------------------------------------+

   -------------------------------------------------------------------+
   -- cursors  c_archive_fbt_info and c_archive_info
   -- modified to use balance name instead of archive item name
   -- Bug #2454595
   -------------------------------------------------------------------+
   cursor  c_archive_fbt_info(c_balance_name         pay_balance_types.balance_name%type,
                              c_year_end             DATE,
                              c_assignment_id        pay_assignment_actions.assignment_id%type)
   is
   select pay_balance_pkg.get_value(pdb.defined_balance_id,
                                    p_max_assignment_action_id,
                    p_registered_employer,
                    null,null,null,null) --2610141
    from   pay_balance_types      pbt,
           pay_defined_balances   pdb,
           pay_balance_dimensions pbd
    where  pbt.balance_name = c_balance_name
      and  pbt.legislation_code = 'AU'
      and  pbt.balance_type_id = pdb.balance_type_id
      and  pbd.balance_dimension_id = pdb.balance_dimension_id
      and  pbd.dimension_name = '_ASG_LE_FBT_YTD';



   ------------------------------------------------------------
   -- Cursor to calculate tax deduction balance  ( Bug 1903647)
   ------------------------------------------------------------


   CURSOR  c_get_global(c_name     VARCHAR2
                       ,c_year_end DATE)
       IS
   SELECT  global_value
          ,data_type
    FROM   ff_globals_f
    WHERE  global_name = c_name
    AND    legislation_code = 'AU'
    AND    c_year_end BETWEEN effective_start_date
                          AND effective_end_date ;
    /*bug8711855 - Moved c_single_lumpsum_E_payment and c_get_pay_effective_date cursors to
                   get_lumpsumE_value function to handle single Lump Sum E adjustment */

    r_global c_get_global%ROWTYPE;

     sum_various         Number;
     counter             Number;
     l_reporting_amt     Number;
     l_medicare_levy     NUMBER ;
     l_fbt_rate          NUMBER ;
    l_assignment_action_id number; --2610141

     e_bad_global        exception ;

begin
   sum_various := 0;
   counter := 1;

   IF g_debug THEN
      hr_utility.set_location('Start of create_extract_archive_balance',1);
      hr_utility.set_location('Start of p_assg_action_id '|| p_assignment_action_id,2);
      hr_utility.set_location('Start of p_database_item_name '|| p_database_item_name,3);
   END if;

   ------------------------------------------------------------+
   -- get the balance value for the database item
   ------------------------------------------------------------+

   if p_database_item_name = 'X_FRINGE_BENEFITS_ASG_YTD' then
      open c_archive_fbt_info (p_balance_name, -- Bug #2454595
                               p_year_end,
                               p_assignment_id);

      fetch  c_archive_fbt_info
       into  v_bal_value;          -- Bug #2454595

/* Bug 5708255  Changed from 1000 to g_fbt_threshold */

   if c_archive_fbt_info%found AND v_bal_value > to_number(g_fbt_threshold) THEN  --Bug: 3549553- To fetch only ASG_YTD level balances
         close c_archive_fbt_info;
         IF g_debug THEN
        hr_utility.set_location('Calling create_extract_archive_details for item :'|| p_database_item_name,4);
     END if;

         ----------------------------------------------------
         --  get global values for MEDICARE_LEVY and FBT_RATE
         ---------------------------------------------------

         open c_get_global ( 'FBT_RATE',add_months(p_year_end,-3));  /* Add_months included for bug 5333143 */
         fetch c_get_global
          into r_global;

         l_fbt_rate := r_global.global_value ;

         if c_get_global%notfound then
           raise e_bad_global;
         end if;

         close c_get_global ;

         open c_get_global ( 'MEDICARE_LEVY',add_months(p_year_end,-3));  /* Add_months included for bug 5333143 */

         fetch c_get_global
          into r_global;

         l_medicare_levy := r_global.global_value ;

         if c_get_global%notfound then
            raise e_bad_global;
         end if;

         close c_get_global ;

         l_reporting_amt := v_bal_value/(1-(l_fbt_rate+l_medicare_levy));
         l_reporting_amt := round(l_reporting_amt,2);


         create_extract_archive_details(p_assignment_action_id
                                       ,p_database_item_name
                                       ,l_reporting_amt);

      else
         IF g_debug THEN
        hr_utility.set_location('FBT Below Reportable limit for this balance:'||p_database_item_name,5);
     END if;
         v_bal_value := 0;
         close c_archive_fbt_info;
      end if;

   elsif p_database_item_name = 'X_EARNINGS_TOTAL_ASG_YTD' then

      ---------------------------------------
      -- archive earnings_total balance
      ---------------------------------------
      v_lump_sum_E_ytd :=0;
      v_earnings_ytd := 0;

/* Remove as balances now retrieved using BBR - Bug 3172963
      open c_archive_total_earnings_info ( p_year_end,
                                           p_assignment_id);

      fetch  c_archive_total_earnings_info into v_earnings_ytd;

      if c_archive_total_earnings_info%found then
         close c_archive_total_earnings_info;
*/
      /* Bug 3172963 */
      /* v_earnings_total := 'Leave Payments Marginal' + 'Earnings_Total' + 'Workplace Giving 4015082 */
      v_earnings_ytd := p_result_table(2).balance_value + p_result_table(16).balance_value + p_result_table(17).balance_value;


      if (v_earnings_ytd >= 0) then

    /* Remove as balance now retrieved using BBR - Bug 3172963
       open c_archive_info('Lump Sum E Payments',p_year_end,p_assignment_id);
       fetch c_archive_info into v_lump_sum_E_ytd;
       close c_archive_info;
    */

         /*bug8711855 - after fetching and calculating lump_sum_e_ytd,
                        get_lumpsumE_value is called to adjust with less than 400 single lump sum E_ptd*/

         v_lump_sum_E_ytd := p_result_table(15).balance_value + p_result_table(27).balance_value
                             + p_result_table(28).balance_value - p_result_table(29).balance_value;

         /* Bug 9190980 -  Added argument v_adj_lump_sum_pre_tax in the function call for fetching Retro GT12 Pre Tax deduction after Lump Sum Adjestment */
         if v_lump_sum_E_ytd <> 0 then

               v_lump_sum_E_ytd := pay_au_payment_summary.get_lumpsumE_value(p_registered_employer, p_assignment_id, p_year_start,
                                                           p_year_end, p_lump_sum_E_ptd_tab, v_lump_sum_E_ytd, v_adj_lump_sum_E_ptd,v_adj_lump_sum_pre_tax);
         end if;

         /* The following logic makes sure that more than 400 Lump Sum E values are relfected in Lump Sum E archive */
         v_earnings_ytd := v_earnings_ytd - v_lump_sum_E_ytd;

         IF g_debug THEN
            hr_utility.set_location('Calling create_extract_archive_details for item :'|| p_database_item_name,4);
         END if;

         create_extract_archive_details(p_assignment_action_id
                                       ,p_database_item_name
                                       ,v_earnings_ytd);
         create_extract_archive_details(p_assignment_action_id
                                       ,'X_LUMP_SUM_E_PAYMENTS_ASG_YTD'
                                       ,v_lump_sum_E_ytd);
      else
         IF g_debug THEN
            hr_utility.set_location('Balance value not found for this balance:'||p_database_item_name,5);
         END if;
          /* close c_archive_total_earnings_info; */ --Bug 3172963
      end if;

   elsif p_database_item_name = 'X_TOTAL_TAX_DEDUCTIONS_ASG_YTD' then

      ---------------------------------------
      -- archive Total Tax Deductions balance
      ---------------------------------------

/* Remove as balances now retrieved using BBR - Bug 3172963 */
/*   open c_archive_total_tax_info( p_year_end,
                                   p_assignment_id);

    fetch  c_archive_total_tax_info into v_bal_value;

    if c_archive_total_tax_info%found then
       close c_archive_total_tax_info;
*/

      -- v_bal_val := 'Total_Tax_Deductions' + 'Termination Deductions' - 'Lump Sum C Deductions'
      v_bal_value := p_result_table(10).balance_value +  p_result_table(11).balance_value
                                  -  p_result_table(7).balance_value;

      IF g_debug THEN
         hr_utility.set_location('Calling create_extract_archive_details for item :'|| p_database_item_name,4);
      END if;
      create_extract_archive_details(p_assignment_action_id
                                    ,p_database_item_name
                                    ,v_bal_value);

   else /* archive other balances */

/* Remove as balances now retrieved using BBR - Bug 3172963 */
/*   open c_archive_info (p_balance_name, -- Bug#2454595
                       p_year_end,
                       p_assignment_id);

    fetch  c_archive_info into  v_bal_value;  -- Bug #2454595

    if c_archive_info%found then
       close c_archive_info;
*/

/*Bug 6192381 Added New Balances for Multiple ETP Enhancement*/
/*Bug 8587013 - Other Income is removed and 'Exempt Foreign Employment Income' balance is moved from
                index position 27 to 12 */
      if (p_balance_name = 'CDEP') then
         v_bal_value := p_result_table(1).balance_value;
      elsif (p_balance_name = 'Lump Sum A Deductions') then
         v_bal_value := p_result_table(3).balance_value;
      elsif (p_balance_name = 'Lump Sum A Payments') then
         v_bal_value := p_result_table(4).balance_value;
      elsif (p_balance_name = 'Lump Sum B Deductions') then
         v_bal_value := p_result_table(5).balance_value;
      elsif (p_balance_name = 'Lump Sum B Payments') then
         v_bal_value := p_result_table(6).balance_value;
      elsif (p_balance_name = 'Lump Sum D Payments') then
         v_bal_value := p_result_table(9).balance_value;
      elsif (p_balance_name = 'Exempt Foreign Employment Income') then  /*Bug 8587013*/
         v_bal_value := p_result_table(12).balance_value;
      elsif (p_balance_name = 'Union Fees') then
         v_bal_value := p_result_table(13).balance_value;
      elsif (p_balance_name = 'Invalidity Payments') then
         v_bal_value := p_result_table(14).balance_value;
      elsif (p_balance_name = 'Lump Sum C Payments') then
         v_bal_value := p_result_table(8).balance_value;
      elsif (p_balance_name = 'Lump Sum C Deductions') then
         v_bal_value := p_result_table(7).balance_value;
      elsif (p_balance_name = 'Workplace Giving Deductions') then /* 4015082 */
         v_bal_value := p_result_table(17).balance_value;
      elsif (p_balance_name = 'ETP Deductions Transitional Not Part of Prev Term') then /* Begin 6192381 */
         v_bal_value := p_result_table(18).balance_value;
      elsif (p_balance_name = 'ETP Deductions Transitional Part of Prev Term') then
         v_bal_value := p_result_table(19).balance_value;
      elsif (p_balance_name = 'ETP Deductions Life Benefit Not Part of Prev Term') then
         v_bal_value := p_result_table(20).balance_value;
      elsif (p_balance_name = 'ETP Deductions Life Benefit Part of Prev Term') then
         v_bal_value := p_result_table(21).balance_value;
      elsif (p_balance_name = 'Invalidity Payments Life Benefit Not Part of Prev Term') then
         v_bal_value := p_result_table(22).balance_value;
      elsif (p_balance_name = 'Invalidity Payments Life Benefit Part of Prev Term') then
         v_bal_value := p_result_table(23).balance_value;
      elsif (p_balance_name = 'Invalidity Payments Transitional Not Part of Prev Term') then
         v_bal_value := p_result_table(24).balance_value;
      elsif (p_balance_name = 'Invalidity Payments Transitional Part of Prev Term') then
         v_bal_value := p_result_table(25).balance_value; /* End 6192381 */
      elsif (p_balance_name = 'Reportable Employer Superannuation Contributions') then /*Begin 8315198*/
         v_bal_value := p_result_table(26).balance_value;
      end if; /*End 8315198*/

      IF g_debug THEN
         hr_utility.set_location('Calling create_extract_archive_details for item :'|| p_database_item_name,4);
      END if;
      create_extract_archive_details(p_assignment_action_id
                                    ,p_database_item_name
                                    ,v_bal_value);

/*   else
       IF g_debug THEN
       hr_utility.set_location('Balance value not found for this balance:'||p_database_item_name,5);
       END if;
       close c_archive_info;
    end if;
*/

   end if;
   p_bal_value := v_bal_value; --Bug 3098353

exception
  when e_bad_global then
    IF g_debug THEN
    hr_utility.set_location('archive_balance_details : Global value not found  ',15);
    END if;
    close c_get_global;
  when zero_divide then
    IF g_debug THEN
        hr_utility.set_location('archive_balance_details : Division By Zero   ',15);
    END if;
  when others then
    IF g_debug THEN
        hr_utility.set_location('Error in archive_balance_details procedure',15);
    END if;
    raise;

end  archive_balance_details;

-----------------------------------------------------------------------------
     /*Function Introduced for Bug2855658*/

  function adjust_retro_allowances(t_allowance_balance IN OUT NOCOPY tab_allownace_balance
     ,p_year_start              in   DATE
     ,p_year_end                in   DATE
     ,p_assignment_id           in   pay_assignment_actions.ASSIGNMENT_ID%type
     ,p_registered_employer     in   NUMBER --2610141
     )
  return number
  is

/* bug 7571001 - Modified Get_retro_Entry_ids and Get_Retro_allowances cursors
                               to accommodate Balance Attribute reporting
*/
  CURSOR Get_retro_Entry_ids(c_year_start DATE,
                             c_year_end   DATE,
                             c_assignment_id  pay_assignment_actions.assignment_id%type)
  IS
  SELECT  /*+ ORDERED */ pee.element_entry_id element_entry_id,
          ppa.date_earned date_earned,
          pee.assignment_id assignment_id,
          pac.tax_unit_id,  /* Added for bug #5846278 */
          pdb.balance_type_id
FROM    per_all_assignments_f  paa
       ,per_periods_of_service pps
       ,pay_assignment_actions pac
       ,pay_payroll_actions    ppa
       ,pay_element_entries_f pee
       ,pay_run_results        prr
       ,pay_element_types_f    pet
       /* below added for bug 7571001 */
       ,PAY_BAL_ATTRIBUTE_DEFINITIONS pbad
       , PAY_BALANCE_ATTRIBUTES pba
       ,pay_defined_balances pdb
       ,pay_balance_dimensions pbd
       ,PAY_BALANCE_FEEDS_F pbf
       ,pay_input_values_f piv
     WHERE paa.assignment_id        = c_assignment_id
      /* start added for bug 7571001 */
      AND pbad.attribute_name = 'AU_EOY_ALLOWANCE'
     AND pbad.attribute_id = pba.attribute_id
     AND pba.defined_balance_id = pdb.defined_balance_id
     and   pbd.balance_dimension_id = pdb.balance_dimension_id
     and   pbd.dimension_name = '_ASG_LE_YTD'
     and   pbd.legislation_code = 'AU'
     AND pdb.balance_type_id = pbf.balance_type_id
     AND pbf.input_value_id = piv.input_value_id
     AND piv.element_type_id = pet.element_type_id
     /* end added for bug 7571001 */
     AND   pps.PERIOD_OF_SERVICE_ID = paa.PERIOD_OF_SERVICE_ID
     AND   NVL(pps.actual_termination_date,c_year_end)
           BETWEEN paa.effective_start_date AND paa.effective_end_date
     AND   pac.payroll_action_id = ppa.payroll_Action_id
     AND   pac.assignment_id = paa.assignment_id
     AND   pac.tax_unit_id   = p_registered_employer --2610141
     AND   ppa.effective_date BETWEEN c_year_start AND c_year_end /*bug 4063321*/
     AND   pac.assignment_Action_id = prr.assignment_Action_id
     AND   prr.element_type_id=pet.element_type_id
     AND   pee.element_entry_id=prr.source_id
     AND   pee.creator_type in ('EE','RR')
     AND   pee.assignment_id = paa.assignment_id /*Added for bug3019374*/
     AND   ppa.action_status='C'
     AND   pac.action_status='C'
     AND   ppa.date_earned between pee.effective_start_date and pee.effective_end_date
     AND   ppa.date_earned BETWEEN pet.effective_start_date AND  pet.effective_end_date
     AND   ppa.date_earned between pbf.effective_start_date and pbf.effective_end_date
     AND   ppa.date_earned between piv.effective_start_date and piv.effective_end_date
     ;


       Cursor Get_Retro_allowances(c_element_entry_id  pay_element_entries_f.element_entry_id%type,
                                                                c_balance_type_id pay_defined_balances.defined_balance_id%type)
       IS
        select  NVL(pbt.reporting_name,pbt.balance_name)  balance_name  /* Bug 5743196 Added nvl */
                     ,prv.result_value balance_value
        from
        pay_element_entries_f pee,
        pay_run_results prr,
        pay_run_result_values prv,
        pay_element_types_f    pet,
        pay_balance_types      pbt
         /* below added for bug 7571001 */
       ,PAY_BALANCE_FEEDS_F pbf
       ,pay_input_values_f piv
        where
        pee.element_entry_id=c_element_entry_id
        and prv.run_result_id=prr.run_result_id
        AND pee.element_entry_id=prr.source_id
        AND prr.element_type_id=pet.element_type_id
         /* start added for bug 7571001 */
        AND pbt.balance_type_id = c_balance_type_id
        AND pbt.balance_type_id = pbf.balance_type_id
        AND pbf.input_value_id = piv.input_value_id
        AND piv.element_type_id = pet.element_type_id
         /* end added for bug 7571001 */
        AND pee.effective_start_date between pet.effective_start_date and pet.effective_end_date
        AND pee.effective_start_date between pbf.effective_start_date and pbf.effective_end_date
        AND pee.effective_start_date between piv.effective_start_date and piv.effective_end_date
        ;



/* Added to check the legislation rule for bug #5846278 */
        CURSOR get_legislation_rule
        IS
        SELECT plr.rule_mode
        FROM   pay_legislation_rules plr
        WHERE  plr.legislation_code = 'AU'
        AND    plr.rule_type ='ADVANCED_RETRO';

       rec_retro_Allowances Get_retro_Allowances%ROWTYPE;
       TYPE
      r_ret_allowances IS RECORD(balance_name  pay_balance_types.balance_name%TYPE,
                             balance_value Number);
       TYPE
       tab_ret_allowances IS TABLE OF r_ret_allowances INDEX BY BINARY_INTEGER;
       t_ret_allowances tab_ret_allowances;

       rec_ret_entry_ids Get_retro_Entry_ids%ROWTYPE;


     ret_counter Number;
     retro_start date;
     retro_end date;
     x number;
     /* Added for #bug no 5846278 */
     orig_eff_date date;
     retro_eff_date date;
     time_span varchar2(10);
     retro_type varchar2(50);
     l_adv_retro_flag pay_legislation_rules.rule_mode%TYPE;

     Begin
       g_debug := hr_utility.debug_enabled;
       ret_counter := 1;
    /* Bug# 5846278 */
    /* Checked for legislation rule.*/

     OPEN get_legislation_rule;
     FETCH get_legislation_rule INTO l_adv_retro_flag;
     IF  get_legislation_rule%NOTFOUND THEN
        l_adv_retro_flag := 'N';
     END IF;
     CLOSE get_legislation_rule;

     /* Retropay by element - logic for Retropay By Element is used */

    IF l_adv_retro_flag <> 'Y'
    THEN

       OPEN Get_retro_Entry_ids(p_year_start,p_year_end,p_assignment_id);
       LOOP
       FETCH Get_retro_Entry_ids INTO rec_ret_entry_ids;
       IF Get_retro_Entry_ids%NOTFOUND Then
          IF g_debug THEN
          hr_utility.set_location('Get_retro_Entry_Id: not found',1);
      END if;
      Exit;
       End If;
      IF g_debug THEN
        hr_utility.set_location('Calling Get Retro Periods',2);
      END if;

       x:=pay_au_paye_ff.get_retro_period(rec_ret_entry_ids.element_entry_id,
                                          rec_ret_entry_ids.date_earned,
                                          p_registered_employer, /*Bug 4418107*/
                                          retro_start,
                                          retro_end);

      IF g_debug THEN
      hr_utility.set_location('Back from call to Get Retro Periods',3);
      END if;

       IF months_between(rec_ret_entry_ids.date_earned,retro_end) > 12 then
          IF g_debug THEN
                  hr_utility.set_location('Getting Retro Allowance  Greater than 12 months',4);
          END if;

          OPEN  Get_retro_Allowances(rec_ret_entry_ids.element_entry_id, rec_ret_entry_ids.balance_type_id);
          FETCH Get_retro_Allowances INTO rec_retro_Allowances;
          CLOSE Get_retro_Allowances;


           If NVL(rec_retro_Allowances.balance_value,0) > 0 Then

              t_ret_allowances(ret_counter).balance_name   := rec_retro_Allowances.balance_name;
              t_ret_allowances(ret_counter).balance_value  := rec_retro_Allowances.balance_value;
              ret_counter := ret_counter+1;
           End If;

      END IF;
    END LOOP;

    CLOSE Get_retro_Entry_ids;

/*Bug 7171534 Added t_allowance_balance.count > 0 in if clause */
   if t_ret_allowances.count > 0 and t_allowance_balance.count > 0 then
    For i in 1..t_ret_allowances.last
    LOOP
        For j in 1..t_allowance_balance.last
        LOOP
          if t_ret_allowances(i).balance_name = t_allowance_balance(j).balance_name then
          t_allowance_balance(j).balance_value := t_allowance_balance(j).balance_value - t_ret_allowances(i).balance_value;
          exit;
           end if;
        END LOOP;
    END LOOP;
   end if;

  t_ret_allowances.delete;

/*bug #5846278 Enh Retro .
   If Retrospective Payment Greater than 12 months then it is deducted from total allowance*/

 ELSE
 OPEN Get_retro_Entry_ids(p_year_start,p_year_end,p_assignment_id);
     LOOP
     FETCH Get_retro_Entry_ids INTO rec_ret_entry_ids;
      IF Get_retro_Entry_ids%NOTFOUND Then
          IF g_debug THEN
          hr_utility.set_location('Get_retro_Entry_Id: not found',1);
          END if;
       Exit;
      End If;
      IF g_debug THEN
        hr_utility.set_location('Calling Get Retro Time Span',2);
      END if;

       x:= pay_au_paye_ff.get_retro_time_span(rec_ret_entry_ids.element_entry_id,
                                          rec_ret_entry_ids.date_earned,
                                          rec_ret_entry_ids.tax_unit_id,
                                          retro_start,
                                          retro_end,
                                          orig_eff_date,
                                          retro_eff_date,
                                          time_span,
                                          retro_type);
      IF g_debug THEN
      hr_utility.set_location('Back from call to Get Retro Time Span',3);
      END if;
      IF time_span ='GT12' then
          IF g_debug THEN
                  hr_utility.set_location('Getting Retro Allowance  Greater than 12 months',4);
          END if;
          OPEN  Get_retro_Allowances(rec_ret_entry_ids.element_entry_id, rec_ret_entry_ids.balance_type_id);
          FETCH Get_retro_Allowances INTO rec_retro_Allowances;
          CLOSE Get_retro_Allowances;

           If NVL(rec_retro_Allowances.balance_value,0) > 0 Then
              t_ret_allowances(ret_counter).balance_name   := rec_retro_Allowances.balance_name;
              t_ret_allowances(ret_counter).balance_value  := rec_retro_Allowances.balance_value;
              ret_counter := ret_counter+1;

           End If;
      END IF;
    END LOOP;

    CLOSE Get_retro_Entry_ids;

/*Bug 7171534 Added t_allowance_balance.count > 0 in if clause */
   if t_ret_allowances.count > 0 and t_allowance_balance.count > 0 then
    For i in 1..t_ret_allowances.last
    LOOP
        For j in 1..t_allowance_balance.last
        LOOP

          if t_ret_allowances(i).balance_name = t_allowance_balance(j).balance_name then
          t_allowance_balance(j).balance_value := t_allowance_balance(j).balance_value - t_ret_allowances(i).balance_value;

          exit;
          end if;
        END LOOP;
    END LOOP;
   end if;

  t_ret_allowances.delete;

END IF;  /*bug #5846278 */
   return 1;

   End adjust_retro_allowances;


/* Bug#4925547 */

procedure archive_limited_values
(p_assignment_action_id number
,p_table                in out nocopy tab_allownace_balance
,p_limit                in binary_integer
,p_name_prefix          in varchar2
,p_name_suffix          in varchar2
,p_value_prefix         in varchar2
,p_value_suffix         in varchar2
,p_total_name           in varchar2
) is
  l_total_value number := 0;
  l_procedure   constant varchar2(80) := g_package||'.archive_limited_values';
begin
  --
  -- Do the number of available balance exceed the limit?
  --
  if p_table.count > p_limit then
    --
    -- Sum the number of balances above the limit into a single value
    -- Store the summed value and the name into the index corresponding to the limit.
    --
    for i in p_limit..p_table.count
    loop
      if g_debug then
        hr_utility.set_location(l_procedure,5);
      end if;
      if p_table.exists(i) then
        l_total_value := l_total_value + p_table(i).balance_value;
      end if;
    end loop;
    p_table(p_limit).balance_name  := p_total_name;
    p_table(p_limit).balance_value := l_total_value;
  end if;
  --
  -- Archive the values up to the limit
  --
  for i in 1..(p_limit)
  loop
    if p_table.exists(i) then
      if g_debug then
        hr_utility.set_location(l_procedure||' : archiving',20);
      end if;

      create_extract_archive_details
      (p_assignment_action_id
      ,p_name_prefix || i || p_name_suffix
      , p_table(i).balance_name
      );
      create_extract_archive_details
      (p_assignment_action_id
      ,p_value_prefix || i || p_value_suffix
      ,p_table(i).balance_value
      );
    end if;
  end loop;
end archive_limited_values;
--
----------------------------------------------------------------------------
--* Archive Allowance details
-----------------------------

procedure archive_allowance_details
(p_assignment_action_id     in   pay_assignment_actions.assignment_action_id%type
,p_max_assignment_action_id in   pay_assignment_actions.assignment_action_id%type
,p_registered_employer      in   number
,p_year_start               in   date
,p_year_end                 in   date
,p_assignment_id            in   pay_assignment_actions.assignment_id%type
,p_alw_bal_exist            out  nocopy varchar2                                   -- 3098353
) IS
  l_procedure               constant varchar2(80) := g_package||'.archive_allowance_details';

/* bug 7571001 - Modified get_allowance_balances cursor to return as per balance attribute
*/

CURSOR get_allowance_balances IS
SELECT  pdb.defined_balance_id
       ,NVL(pbt.reporting_name,pbt.balance_name) balance_name
       ,pay_balance_pkg.get_value(pdb.defined_balance_id
                                  ,p_max_assignment_action_id
                                  ,p_registered_employer
                                  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL) balance_value
FROM  pay_balance_attributes pba
     ,pay_defined_balances   pdb
     ,pay_balance_types      pbt
     ,pay_balance_dimensions pbd
WHERE pba.attribute_id         = g_attribute_id
AND   pdb.defined_balance_id   = pba.defined_balance_id
AND   pbt.balance_type_id      = pdb.balance_type_id
AND   pdb.balance_type_id = pbt.balance_type_id
AND pdb.business_group_id = g_business_group_id
and   pbd.balance_dimension_id = pdb.balance_dimension_id
and   pbd.dimension_name = '_ASG_LE_YTD'
ORDER BY 3 DESC
;

  counter           number := 1;
  i                 number;
  t_allowance_2006  tab_allownace_balance;
  --
begin
  if g_debug then
    hr_utility.set_location(l_procedure, 1);
    hr_utility.trace('p_assignment_action_id.....= ' || p_assignment_action_id);
    hr_utility.trace('p_max_assignment_action_id.= ' || p_max_assignment_action_id);
    hr_utility.trace('p_registered_employer......= ' || p_registered_employer);
    hr_utility.trace('p_year_start...............= ' || p_year_start);
    hr_utility.trace('p_year_end.................= ' || p_year_end);
    hr_utility.trace('p_assignment_id............= ' || p_assignment_id);
  end if;
  --
  -----------------------------------------------------------------------------------------
  --  Archive the Allowances
  -----------------------------------------------------------------------------------------
  --
  -- Archive up to 4 allowances , store the value and name of the balance for the employees
  -- If the employee has more than 4 allowances than store name and value of first
  -- 3 allowances based on the value of balance in descending order.
  -- Then calculate the sum of the remaining balances and store name as 'Various'
  -- /* Bug#4925547 */
  -- To support 2006/2007 Payment Summary we need to archive the new 30 allowance names and
  -- values as well as continuing to archive the original 4 items mentioned above
  --
  -----------------------------------------------------------------------------------------
  --
/* start bug 7571001*/
  for rec_allowance_balances in get_allowance_balances loop

      if nvl(rec_allowance_balances.balance_value,0) >0 then
       t_allowance_balance(counter).balance_name  := rec_allowance_balances.balance_name;
       t_allowance_balance(counter).balance_value := rec_allowance_balances.balance_value;

        if g_debug then
          hr_utility.set_location(l_procedure, 3);
          hr_utility.trace('t_allowance_ balance name ('||counter||') = '|| t_allowance_balance(counter).balance_name);
          hr_utility.trace('t_allowance_balance value ('||counter||') = '||t_allowance_balance(counter).balance_value);
        end if;

        counter := counter +1;

      end if;
  end loop;
/* end bug 7571001*/
  --
  -- 2855658
  --
  i := adjust_retro_allowances
       (t_allowance_balance
       ,p_year_start
       ,p_year_end
       ,p_assignment_id
       ,p_registered_employer --2610141
       );
  --
  -- Copy the table as we need to manipulate and archive twice
  -- to support the pre 2006 and post archives.
  --
  t_allowance_2006 := t_allowance_balance;
  --
  -- /* Bug#4925547 */
  -- Always archive the previous method for allowances
  -- as these are used in other processes as well as form
  -- the total value for allowances in the payment summary
  --
  --
  -- If more than 4 allowances exists, calculate sum of all
  -- and assign the sum to 4th balance with name 'Various'
  --
  archive_limited_values
  (p_assignment_action_id   => p_assignment_action_id
  ,p_table                  => t_allowance_balance
  ,p_limit                  => 4
  ,p_name_prefix            => 'X_ALLOWANCE_NAME_'
  ,p_name_suffix            => ''
  ,p_value_prefix           => 'X_ALLOWANCE_'
  ,p_value_suffix           => '_ASG_YTD'
  ,p_total_name             => 'Various'
  );
  --/* Bug#4925547 */
  -- Now if the financial year is 2006/2007 or above
  -- then we perform the additional archive.
  --
  if to_number(to_char(p_year_start,'YYYY')) >= 2006 then
    if g_debug then
      hr_utility.set_location(l_procedure, 30);
    end if;
    --
    archive_limited_values
    (p_assignment_action_id => p_assignment_action_id
    ,p_table                => t_allowance_2006
    ,p_limit                => 30
    ,p_name_prefix          => 'X_ALLOWANCE_'
    ,p_name_suffix          => '_NAME'
    ,p_value_prefix         => 'X_ALLOWANCE_'
    ,p_value_suffix         => '_VALUE'
    ,p_total_name           => 'Miscellaneous'
    );
  end if;
  --
  -- 3098353:- Checks if the Allowance exist in the current year.
  --
  if t_allowance_balance.count > 0 then
    p_alw_bal_exist := 'TRUE';
  else
    p_alw_bal_exist := 'FALSE';
  end if;
  ---------------------------------------------------------
  t_allowance_balance.delete; /* 2968127- cleared PL/SQL table */
  if g_debug then
    hr_utility.set_location(l_procedure,999);
  end if;
exception
  when others then
    if g_debug then
      hr_utility.set_location(l_procedure,000);
    end if;
    raise;
end  archive_allowance_details;
--
-----------------------------------------------------------
-- in case for a terminated employee payroll has been run
-- but prepayments have not been made then this is an exception
-- condition in the validation report. This procedure
-- archives X_ETP_ON_TERMNATION_PAID and
-- X_ETP_EMPLOYEE_PAYMENT_DATE
-----------------------------------------------------------

procedure archive_etp_payment_details
    ( p_assignment_action_id pay_assignment_actions.assignment_action_id%type,
      p_registered_employer  NUMBER, --2610141
      p_assignment_id        per_all_Assignments_f.assignment_id%type ,
      p_year_start           date,
      p_year_end             date ) as


cursor  etp_paid(c_assignment_id per_all_Assignments_f.assignment_id%type,
                 c_year_start    date ,
                 c_year_end      date )  is

select  prv.result_value
       ,ppa.payroll_action_id
       ,pac.assignment_action_id
       ,ppa.effective_date
from    pay_element_types_f    pet
       ,pay_input_values_f     piv
       ,per_all_assignments_f  paa
       ,pay_run_results        prr
       ,pay_run_result_values  prv
       ,pay_assignment_actions pac
       ,pay_payroll_actions    ppa
       ,pay_payrolls_f   papf         /* bug Number 4278361 */
where   pet.element_type_id      = piv.element_type_id
  and   pet.element_name         = 'ETP on Termination'
  and   piv.name                 = 'Pay ETP Components'
  and   paa.assignment_id        = c_assignment_id
  and   prv.input_value_id       = piv.input_value_id
  and   prr.element_type_id      = pet.element_type_id
  and   prr.run_result_id        = prv.run_result_id
  and   prr.assignment_action_id = pac.assignment_action_id
  and   pac.assignment_id        = paa.assignment_id
  and   pac.payroll_action_id    = ppa.payroll_action_id
  and   paa.effective_start_date between pet.effective_start_date
                                     and pet.effective_end_date
  and   paa.effective_start_date between piv.effective_start_date
                                     and piv.effective_end_date
   and papf.payroll_id=paa.payroll_id
   and ppa.payroll_id=papf.payroll_id
   and    ppa.action_type             in ('R','Q','I','B','V')    /* bug Number 4278361 */
  and ppa.effective_date between papf.effective_start_date and papf.effective_end_date
  and   ppa.effective_date       between paa.effective_start_date
                                     and paa.effective_end_date
  and   ppa.effective_date between c_year_start
                               and c_year_end
  and   pac.tax_unit_id = p_registered_employer; --2610141

cursor  etp_prepayment
          (c_assignment_action_id pay_assignment_actions.assignment_action_id%type,
           c_payroll_action_id    pay_payroll_actions.payroll_action_id%type,
           c_year_start           date,
           c_year_end             date )
    is  select  to_char(pppa.effective_date,'DDMMYYYY')
         from   pay_action_interlocks    pai
               ,pay_assignment_actions   pac
               ,pay_payroll_actions      ppa
               ,pay_assignment_actions   ppac
               ,pay_payroll_actions      pppa
        where   pac.payroll_action_id    = ppa.payroll_action_id
          and   pac.assignment_action_id = c_assignment_action_id
          and   pac.assignment_action_id = pai.locked_action_id
          and   ppa.payroll_action_id    = c_payroll_action_id
          and   ppac.assignment_action_id =pai.locking_Action_id
          and   pppa.payroll_Action_id   = ppac.payroll_Action_id
          and   ppa.effective_date      between c_year_start
                                            and c_year_end;
  r_etp_paid etp_paid%rowtype;

-- cursor to get payroll and assignment actions when termination payments are done
-- through balance adjustment/balance initialization(Bug 2574186)

/* Bug No: 3603495 - Performance Fix - Modified the following cursor by introducing per_assignments_f table and its joins */

cursor etp_BA_or_BI
         (c_assignment_id per_all_assignments_f.assignment_id%type,
          c_year_start    date ,
          c_year_end      date )
   is  select  max(ppa.payroll_action_id) payroll_action_id
              ,max(pac.assignment_action_id) assignment_action_id
        from   per_assignments_f      paf
              ,pay_assignment_actions pac
              ,pay_payroll_actions    ppa
       where   pac.assignment_id     = c_assignment_id
         and   pac.tax_unit_id = p_registered_employer --2610141
         and   paf.assignment_id     = pac.assignment_id
         and   ppa.action_type       in ('B','I')
         and   pac.payroll_action_id = ppa.payroll_action_id
         and   pac.action_status     = 'C'
         and   ppa.action_status     = 'C'
         and   ppa.payroll_id = paf.payroll_id /* Added for bug 5371102 for performance*/
         and   ppa.date_earned between paf.effective_start_date and paf.effective_end_date /* Added for bug 5371102 for performance*/
         and  (pay_balance_pkg.get_value(pkg_lump_sum_c_def_bal_id, pac.assignment_action_id,p_registered_employer,null,null,null,null)) > 0 --2610141
         and   ppa.effective_date between c_year_start
                                      and c_year_end ;

  r_etp_ba_or_bi etp_BA_or_BI%rowtype;

  -- Bug No : 2574186 initialize the l_etp_paid as 'N', So that the dbi
  -- X_ETP_ON_TERMINATION_PAID is archived as 'N' incase the Lump C Payemnt
  -- exists and prepayment is not not run
  l_etp_paid        varchar2(1);
  l_etp_paid_date   varchar2(20);

begin

  l_etp_paid := 'N';

  open etp_paid(p_assignment_id,p_year_start,p_year_end);
  fetch etp_paid into r_etp_paid ;

  if (etp_paid%found and r_etp_paid.result_value = 'Y') then
      l_etp_paid := 'Y';

    open etp_prepayment(r_etp_paid.assignment_action_id,r_etp_paid.payroll_action_id,p_year_start,p_year_end);
    fetch etp_prepayment into l_etp_paid_date;

    if (etp_prepayment%notfound) then
      l_etp_paid := 'N';
    end if;

    close etp_prepayment;

  else
    -- Bug 2574186 - Check if the prepayment is run in case of BA/BI
    open etp_BA_or_BI(p_assignment_id,p_year_start,p_year_end);
    fetch etp_BA_or_BI into r_etp_ba_or_bi ;
    if etp_BA_or_BI%found then
       l_etp_paid := 'Y';
       open etp_prepayment(r_etp_ba_or_bi.assignment_action_id,r_etp_ba_or_bi.payroll_action_id,p_year_start,p_year_end);
       fetch etp_prepayment into l_etp_paid_date;
       if (etp_prepayment%notfound) then
         l_etp_paid := 'N';
       end if;
       close etp_prepayment;
    end if;
    close etp_BA_or_BI;
  end if;
  close etp_paid;


  ---------------------------------------
  -- create the archive items
  ---------------------------------------

  create_extract_archive_details(p_assignment_action_id,
                                'X_ETP_ON_TERMINATION_PAID',
                                 l_etp_paid );
  create_extract_archive_details(p_assignment_action_id,
                                'X_ETP_EMPLOYEE_PAYMENT_DATE',
                                 l_etp_paid_date);
exception
  when others then
    IF g_debug THEN
    hr_utility.set_location('Error in archive_etp_payment_details ',99);
    END if;
    Raise;
end archive_etp_payment_details ;
--
-- /* Bug#4925547 */
-- As of 2006/2007 financial year we provide an alternative solution to archiving
-- union fees.
--
-- As of 2006/2007 there is a new method of setting up union fees
--------------------------------------------------------------------
-- This method involves entering an associated balance into a flex
-- segment of the Element Developer DF.
-- The archive must continue to use the old method (mentioned above)
-- and in addition to this, if the financial year is 2006/2007 or
-- above then also archive for the new method.
--------------------------------------------------------------------
--
procedure archive_2006_unions
(p_assignment_id              in  per_all_assignments.assignment_id%type
,p_assignment_action_id       in  pay_assignment_actions.assignment_action_id%type
,p_max_assignment_action_id   in  pay_assignment_actions.assignment_action_id%type
,p_registered_employer        in  number
,p_year_start                 in  date
,p_year_end                   in  date
--,p_alw_bal_exist              out nocopy varchar2
) as

  --
  -- This cursor returns the balance value for union elements.  Element that are identified as a 'Union' fee element
  -- will have segment 1 of the Element Developer flex linking the element to a specific balance
  -- in conjunction with feeding the legislative balance called 'Union Fees'
  --  Bug#5591993 Removed join for table pay_balance_type to avoid MJC
  --              and moved the code to cursor c_union_balance(initliazation code).
  cursor csr_unions_2006 (c_balance_type pay_balance_types.balance_type_id%type) is
  select distinct nvl(pbt.reporting_name, pbt.balance_name) balance_name
  ,      pay_balance_pkg.get_value(pdb.defined_balance_id, p_max_assignment_action_id, p_registered_employer,null,null,null,null)   balance_value
  ,      pdb.defined_balance_id                            def_id
  ,      pbt.balance_type_id                               bal_type_id
  from   pay_element_types_f         pet
  ,      per_all_assignments_f       paa
  ,      pay_balance_types           pbt
  ,      pay_defined_balances        pdb
  ,      pay_payroll_actions         ppa
  ,      pay_assignment_actions      pac
  ,      pay_run_results             prr
  ,      pay_balance_feeds_f         pbf
  ,      pay_input_values_f          piv
  where  pac.assignment_id               = p_assignment_id
  and    pac.tax_unit_id                 = p_registered_employer
  and    paa.assignment_id               = pac.assignment_id
  and    pac.payroll_action_id           = ppa.payroll_Action_id
  and    ppa.effective_date              between p_year_start and p_year_end
  and    ppa.payroll_id                  = paa.payroll_id
  and    ppa.action_type                 in ('Q','R','B','I','V')
  and    pac.assignment_action_id        = prr.assignment_action_id
  and    prr.element_type_id             = pet.element_type_id
  and    pet.element_information_category = 'AU_VOLUNTARY DEDUCTIONS'
  and    pet.element_information1        = pbt.balance_type_id
  and    pbt.balance_type_id             = pdb.balance_type_id(+)
  and    pdb.balance_dimension_id(+)     = g_dimension_id
  and    ppa.effective_date              between paa.effective_start_date and paa.effective_end_date
  and    ppa.date_earned                 between pet.effective_start_date and pet.effective_end_date
  and    pet.element_type_id             = piv.element_type_id
  and    ppa.date_earned                 between piv.effective_start_date and piv.effective_end_date
  and    piv.input_value_id              = pbf.input_value_id
  and    ppa.date_earned                 between pbf.effective_start_date and pbf.effective_end_date
  and    pbf.balance_type_id             = c_balance_type
  order by 2 desc ;
  --
  l_procedure   constant varchar2(80) := g_package || '.archive_2006_unions';
  l_counter     number := 1;
  l_4_value     number;
  l_4_name      pay_balance_types.balance_name%type;
  l_total_value number := 0;
  l_balance_type pay_balance_types.balance_type_id%type;
begin
  g_debug := hr_utility.debug_enabled;
  --
  -- If the financial year permits then perform the union fees archive for 2006/2007.
  --
  if to_number(to_char(p_year_start,'YYYY')) >= 2006 then
    --
    for rec_union in csr_unions_2006(g_balance_type_id) loop

      --
      -- 4863149 - Raise error when there is no defined balance id for allowance balance
      --
      if g_debug then
        hr_utility.set_location(l_procedure, 3);
      end if;
      --
      if rec_union.def_id is null then
        raise_application_error(-20101, 'Balance ID ' || rec_union.bal_type_id || ' not associated with dimension _ASG_LE_YTD');
      end if ;
      --
      -- Store all the values in a table
      --
      if nvl(rec_union.balance_value,0) > 0 then
        if g_debug then
          hr_utility.set_location(l_procedure, 3);
          hr_utility.set_location(l_procedure || ' : balance_name... = '||rec_union.balance_name,3);
          hr_utility.set_location(l_procedure || ' : balance_value.. = '||rec_union.balance_value,3);
        end if;
        t_union_table(l_counter).balance_name  := rec_union.balance_name;
        t_union_table(l_counter).balance_value := rec_union.balance_value;
        l_counter := l_counter + 1;
      end if;
    end loop;
    --
    -- No archive the names, values
    --
    /*
    archive_limited_values
    (p_assignment_action_id => p_assignment_action_id
    ,p_table                => t_union_table
    ,p_limit                => 4
    ,p_name_prefix          => 'X_UNION_'
    ,p_name_suffix          => '_NAME'
    ,p_value_prefix         => 'X_UNION_'
    ,p_value_suffix         => '_VALUE'
    ,p_total_name           => 'Miscellaneous'
    );
    */
    -- Due to the change in display of union fees for the 2006 payment summary layout,
    -- there are now 2 methods of setting up union fee elements.
    -- =====================================================
    -- The first and 'original' method involves users feeding their own elements to the
    -- 'Union Fees' legislative balance.
    -- This is mandatory setup so that all existing functionality is retained.
    --
    -- The 'new' method involves users 'linking' their union elements to an additional balance
    -- they have created.  This enables the identification of values for the individual unions.
    -- The 'linking' involves creating a feed to the new balance and selecting that balance
    -- as the 'Union fees primary balance' in the Element DF.
    -- This setup is not mandatory
    --
    -- Although it is recommended that users setup ALL their union elements using only 1 of the above methods,
    -- it cannot be enforced within the application. Therefore, to handle this case we use the 'Union Fees'
    -- balance as the definitive balance and check this when archiving union elements which adhere to the
    -- 'new' method of setup
    --
    --
    -- Archive the first 3 elements which adhere to the 'new' setup
    --
    for i in 1..3
    loop
      --
      -- Only archive if the values exist
      --
      if t_union_table.exists(i) then
        if g_debug then
          hr_utility.set_location(l_procedure,20);
        end if;
        create_extract_archive_details(p_assignment_action_id,'X_UNION_' || i || '_NAME',t_union_table(i).balance_name);
        create_extract_archive_details(p_assignment_action_id,'X_UNION_' || i || '_VALUE',t_union_table(i).balance_value);
        l_total_value := l_total_value + t_union_table(i).balance_value;
      end if;
    end loop;
    --
    -- We still need to archive the 4th position... if it exists
    --
    if g_debug then
      hr_utility.trace('There are '||t_union_table.count||' union elements');
      hr_utility.trace('Already archived value is '||l_total_value);
    end if;
    --
    -- The definitive figure for Union Fees is stored in the legislative union balance 'Union Fees'.
    -- It is possible that there may be a combination of old and new union elements being used.
    --
    -- A 'misc' figure must be archived if:
    -- 1. There exists more than 4 new union elements.
    -- 2. There is a combination of new and old union elements.
    --    In this case the sum of new unions will not equal the legislative union balance.
    --
    --
    -- 5679568
    --
    if t_union_table.count > 4
    or l_total_value <> p_result_table(13).balance_value then
      --
      -- There are more than 4 union elements with the 'new' setup method
      -- however, it is possible that the remaining union elements are not all using the 'new' method
      -- so we must use the definitive balance to obtain the correct value.  To do this
      -- we subtract the values just archived from the definitive balance.  The remainder must
      -- equal the correct value.
      --
      l_4_name  := 'Miscellaneous';
      l_4_value := p_result_table(13).balance_value - l_total_value;
      create_extract_archive_details(p_assignment_action_id,'X_UNION_4_NAME',l_4_name);
      create_extract_archive_details(p_assignment_action_id,'X_UNION_4_VALUE',l_4_value);
    else
      --
      -- If a 4th union exists then lets archive it
      --
      if t_union_table.exists(4) then
        --
        -- Check if the values added up equal the value stored in the definitive balance.
        --
        if g_debug then
          hr_utility.set_location(l_procedure,35);
        end if;
        --
        if (l_total_value + t_union_table(4).balance_value) = p_result_table(13).balance_value then
          --
          -- All elements have been setup using the new method and therefore the values are correct.
          -- We can store the 4th value in its corresponding position
          --
          if g_debug then
            hr_utility.set_location(l_procedure,40);
          end if;
          --
          l_4_name := t_union_table(4).balance_name;
          l_4_value := t_union_table(4).balance_value;
        else
          --
          -- There is a amalgamation of methods used to setup union elements.
          -- This means that we need to check the definitive balance to obtain correct values.
          -- This additional value must be stored in the 4th position and displayed as 'Miscellaneous'
          --
          l_4_name  := 'Miscellaneous';
          l_4_value := p_result_table(13).balance_value - l_total_value;
        end if;
        create_extract_archive_details(p_assignment_action_id,'X_UNION_4_NAME',l_4_name);
        create_extract_archive_details(p_assignment_action_id,'X_UNION_4_VALUE',l_4_value);
      end if;
    end if;
    --
  end if;
  --
  /*
  if t_union_table.count > 0 then
    p_alw_bal_exist := 'TRUE';
  else
    p_alw_bal_exist := 'FALSE';
  end if;
  */
  ---------------------------------------------------------
  t_union_table.delete;
  --
end archive_2006_unions;
--
----------------------------------------------------------------------+
-- procedure to archive 'X_UNION_NAME' - added for
-- bug no : 1764017
----------------------------------------------------------------------+
--
procedure archive_union_name
  (p_assignment_id              in per_all_assignments.assignment_id%type
  ,p_assignment_action_id       in pay_assignment_actions.assignment_action_id%type
  ,p_max_assignment_action_id   in pay_assignment_actions.assignment_action_id%type
  ,p_registered_employer        number
  ,p_year_start                 in date
  ,p_year_end                   in date
  ) as
  --
  cursor csr_union_fees
  (c_assignment_id per_all_assignments.assignment_id%type
  ,c_year_end      date
  ) is
  select distinct pet.reporting_name
  ,      pet.element_information_category
  ,      pet.element_information1
  from   pay_balance_types      pbt
  ,      pay_balance_feeds_f    pbf
  ,      pay_input_values_f     piv
  ,      pay_element_types_f    pet
  ,      pay_element_entries_f  pee
  ,      pay_element_links_f    pel
  ,      per_all_people_f       pap
  ,      per_periods_of_service pps
  ,      per_all_assignments_f  paa
  where  pet.element_type_id      = piv.element_type_id
  and    pbf.input_value_id       = piv.input_value_id
  and    pbf.balance_type_id      = pbt.balance_type_id
  and    pet.element_type_id      = pel.element_type_id
  and    pel.element_link_id      = pee.element_link_id
  and    pee.assignment_id        = c_assignment_id
  and    pee.assignment_id        = paa.assignment_id
  and    paa.person_id            = pap.person_id
  and    paa.person_id            = pps.person_id
  and    paa.period_of_service_id = pps.period_of_service_id
  and    pbt.balance_name         = 'Union Fees'
  and    pbt.legislation_code     = g_legislation_code
  and    pet.effective_start_date = (select max(et.effective_start_date )
                                     from pay_element_types_f et
                                     where et.element_type_id= pet.element_type_id
                                     and nvl(pps.actual_termination_date,c_year_end)
                                            between pet.effective_Start_date and pet.effective_end_date
                                   );
 --
 -- 2610141 - Removed the cursor for getting union fees
 --
 /*CURSOR  union_def_bal_id
    IS
 SELECT pdb.defined_balance_id
  FROM  pay_balance_types      pbt
       ,pay_defined_balances   pdb
       ,pay_balance_dimensions pbd
 WHERE  pbt.balance_name         = 'Union Fees'
   AND pbt.legislation_code     = 'AU'
   AND pbd.legislation_code     = 'AU'
   AND pbt.balance_type_id      = pdb.balance_type_id
   AND pbd.balance_dimension_id = pdb.balance_dimension_id
   AND pbd.dimension_name       = '_ASG_LE_YTD'; --2610141*/

  l_reporting_name   pay_element_types_f.reporting_name%type;
  l_procedure        constant varchar2(80) := g_package || '.archive_union_name';
  l_element_information_category    pay_element_types_f.element_information_category%type;
  l_element_information1            pay_element_types_f.element_information1%type;
  l_count                           number := 0;
  l_2006_union_setup_found          boolean;
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location(l_procedure,1);
  end if;
  --
  -------------------------------------------
  -- if two or more elements feed the balance
  -- 'Union Fees' then reporting_name = 'MISCELLANEOUS'
  -- else archive the reporting name for the element.
  -- Notice that only the name is considered here, the value
  -- is archived elsewhere.
  --
  --
  -- 4738470 - Included check for balance value
  -- Only a single value needs to be checked, which is already stored in
  -- position 13 of the table.
  --
  if p_result_table(13).balance_value > 0 then
    --
    for rec_union_fees in csr_union_fees(p_assignment_id, p_year_end) loop
      -- /* Bug#4925547 */
      -- Check if any of the elements have had the new union setup entered
      --
      if rec_union_fees.element_information_category = 'AU_VOLUNTARY DEDUCTIONS'
              and rec_union_fees.element_information1 is not null then
        l_2006_union_setup_found := true;
      end if;
      --
      l_reporting_name := rec_union_fees.reporting_name;
      l_count := l_count + 1;
    end loop;
    --
    -- If more than 1 union fees element exists
    -- then the displayed name should be as follows
    --
    if l_count > 1 or l_reporting_name = 'Balance Initialization 4' then /*bug 8423565*/
      l_reporting_name :='MISCELLANEOUS';
    end if;
    --
    if g_debug then
      hr_utility.trace('reporting name : '||l_reporting_name);
    end if;
    --
  end if;
  --
  if l_reporting_name is not null then
    if g_debug then
      hr_utility.set_location(l_procedure, 20);
    end if;
    --
    create_extract_archive_details
    (p_assignment_action_id
    ,'X_UNION_NAMES'
    ,l_reporting_name
    );
  end if;
  --  /* Bug#4925547 */
  -- If the new setup has been performed then archive for this case
  --
  if l_2006_union_setup_found then
    if g_debug then
      hr_utility.set_location(l_procedure, 30);
    end if;
    archive_2006_unions
    (p_assignment_id              => p_assignment_id
    ,p_assignment_action_id       => p_assignment_action_id
    ,p_max_assignment_action_id   => p_max_assignment_action_id
    ,p_registered_employer        => p_registered_employer
    ,p_year_start                 => p_year_start
    ,p_year_end                   => p_year_end
--    ,p_alw_bal_exist              => p_alw_bal_exist
    );
  else
    -- /* Bug#4925547 */
    -- Otherwise we archive the old setup method for unions
    -- into the new archive items, assuming the financial year
    -- is 2006/2007 and above
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 40);
    end if;
    --
    if to_number(to_char(p_year_start,'YYYY')) >= 2006 then
      if g_debug then
        hr_utility.set_location(l_procedure, 50);
        hr_utility.trace('l_reporting_name => '||l_reporting_name);
        hr_utility.trace('l_value_13       => '||p_result_table(13).balance_value);
      end if;
      -- /* Bug#4925547 */
      -- Format the misc name correctly for 2006 layout
      --
      if l_reporting_name = 'MISCELLANEOUS' then
        l_reporting_name := 'Miscellaneous';
      end if;
      create_extract_archive_details(p_assignment_action_id,'X_UNION_1_NAME',l_reporting_name);
      create_extract_archive_details(p_assignment_action_id,'X_UNION_1_VALUE',p_result_table(13).balance_value);
    end if;
  end if;
  --
  if g_debug then
      hr_utility.set_location(l_procedure,999);
  end if;
exception
  when others then
    if g_debug then
      hr_utility.set_location(l_procedure, 000);
    end if;
    raise;
end archive_union_name;

----------------------------------------------------------------------+
-- procedure to archive terminated employees details
----------------------------------------------------------------------+
Procedure archive_etp_details
      (p_business_group_id    in hr_organization_units.business_group_id%type,
       p_registered_employer  in hr_organization_units.organization_id%type,
       p_payroll_action_id    in pay_payroll_actions.payroll_action_id%type,
       p_assignment_Action_id in pay_assignment_actions.assignment_action_id%type,
       p_assignment_id        in pay_assignment_actions.assignment_id%type,
       p_year_start           in pay_payroll_actions.effective_date%type,
       p_year_end         in pay_payroll_Actions.effective_date%type,
       p_lst_year_start       in pay_payroll_Actions.effective_date%type,/*Bug3661230 Added one extra parameter*/
       p_transitional_flag    out nocopy varchar2, /*Bug 6192381 Added New Parameters p_transitional_flag and p_part_prev_etp_flag */
       p_part_prev_etp_flag   out nocopy varchar2) is


  l_etp_last_name         per_all_people_f.last_name%type;
  l_etp_first_name        per_all_people_f.first_name%type;
  l_etp_middle_name       per_all_people_f.middle_names%type;
  l_etp_address_1             hr_locations.address_line_1%type;
  l_etp_address_2             hr_locations.address_line_2%type;
  l_etp_address_3             hr_locations.address_line_3%type;
  l_etp_suburb                hr_locations.town_or_city%type;
  l_etp_state                 hr_locations.region_1%type;
  l_etp_postcode          hr_locations.postal_code%type;
  l_etp_country               fnd_territories_tl.territory_short_name%type;
  l_etp_employee_number           per_all_people_f.employee_number%type;
  l_etp_date_of_birth             per_all_people_f.date_of_birth%type;
  l_etp_employee_start_date       per_periods_of_service.date_start%type;
  l_etp_death_benefit             per_periods_of_service.leaving_reason%type;
  l_asgmnt_loc                    hr_locations.location_code%type;
  l_emp_no                        per_all_people_f.employee_number%type;
  l_payroll                       pay_all_payrolls_f.payroll_name%type;
  l_emp_type                      per_all_people_f.current_employee_flag%type;
  l_address_date_from date;

  -----------------------------------------------------------------------------------------------+
  -- cursor to fetch terminated employees details
  -----------------------------------------------------------------------------------------------+
  /*Bug 8315198 - Modified cursor to fetch the Tax file number entered in termination form for employees recieving Death Benefit ETP */
  cursor  etp_details( c_business_group_id    in hr_organization_units.business_group_id%type,
                       c_registered_employer  in hr_organization_units.organization_id%type,
                       c_payroll_action_id    in pay_payroll_actions.payroll_action_id%type,
                       c_assignment_id        in pay_assignment_actions.assignment_id%type,
                       c_year_start           in pay_payroll_actions.effective_date%type,
                       c_year_end         in pay_payroll_Actions.effective_date%type)
      is
  select  pev.screen_entry_value                tax_file_number
         ,pap.last_name                         employee_last_name
         ,pap.first_name                        employee_first_name
         ,substr(pap.middle_names, 1, decode(instr(pap.middle_names,' '), 0, 60, instr(pap.middle_names,'',1)-1))                                                                                                 employee_middle_name
         ,pad.address_line1                     employee_address_1
         ,pad.address_line2                     employee_address_2
         ,pad.address_line3                     employee_address_3
         ,pad.town_or_city                      employee_suburb
         ,pad.region_1                          employee_state
         ,pad.postal_code                       employee_postcode
         ,fta.territory_short_name              employee_country
         ,pad.style                             address_style           -- Bug 5364017
         ,pad.country                           address_country         -- Bug 5364017
         ,pap.employee_number                   employee_number
         ,to_char(pap.date_of_birth,'DDMMYYYY') employee_date_of_birth
         ,to_char(pps.date_start,'DDMMYYYY')    employee_start_date
         ,pps.pds_information2                  death_benefit_type
         ,nvl(to_char(pps.actual_termination_date,'DDMMYYYY'),'31124712') employee_termination_date
         ,decode(pps.pds_information1, 'AU_D','Y', 'N') death_benefit/*bug#1955993*/
         ,pad.date_from date_from/*Bug 2977533 */
         ,decode(pps.pds_information1, 'AU_D',nvl(pps.pds_information11,'000 000 000'),pev.screen_entry_value) etp_death_benefit_tfn  /*Bug#8315198*/
   from   hr_organization_information  hoi,
          hr_organization_units        hou,
          hr_soft_coding_keyflex       hsc,
          pay_element_types_f          pet,
          pay_input_values_f           piv,
          pay_element_links_f          pel,
          pay_element_entries_f        pee,
          pay_element_entry_values_f   pev,
          per_all_assignments_f        paa,
          per_all_people_f             pap,
          per_addresses                pad,
          fnd_territories_tl           fta,
          per_periods_of_service       pps,
          pay_payroll_actions          ppa,
          pay_assignment_actions       pac,
          hr_locations_all             hlc   /* Bug No : 2263587 */
   where  hou.business_group_id       = c_business_group_id
     and  hou.organization_id         = c_registered_employer
     and  ppa.action_type             = 'X'
     and  hou.organization_id         = hoi.organization_id
     and  hoi.org_information_context = 'AU_LEGAL_EMPLOYER'
     and  hou.business_group_id       = pap.business_group_id
     and  hsc.soft_coding_keyflex_id  = paa.soft_coding_keyflex_id
     and  pet.element_name            = 'Tax Information'
     and  piv.name                    = 'Tax File Number'
     and  pet.element_type_id         = piv.element_type_id
     and  pet.element_type_id         = pel.element_type_id
     and  pel.element_link_id         = pee.element_link_id
     and  pee.element_entry_id        = pev.element_entry_id
     and  piv.input_value_id          = pev.input_value_id
     and  paa.assignment_id           = pee.assignment_id
     and  pap.person_id               = paa.person_id
     and  pap.person_id               = pad.person_id(+)
     and  pad.primary_flag(+)         = 'Y' /*Added for bug 2774577*/
     and  fta.territory_code(+)       = pad.country
     and  fta.language(+)             = userenv('LANG')
     and  paa.location_id             = hlc.location_id(+)
     and  pap.person_id               = pps.person_id
     and  paa.period_of_service_id    = pps.period_of_service_id
     and  ppa.payroll_action_id       = pac.payroll_action_id
     and  paa.assignment_id           = pac.assignment_id
     and  pac.assignment_id           = c_assignment_id
     and  pac.payroll_action_id       = c_payroll_action_id
     and  hsc.segment1                = c_registered_employer /*Bug 2610141, Bug 4063321*/
     and  pps.actual_termination_date  between  paa.effective_start_date
                                          and  paa.effective_end_date
     and  pps.actual_termination_date  between  pap.effective_start_date
                                          and  pap.effective_end_date
     and  pps.actual_termination_date  between  pel.effective_start_date
                                          and  pel.effective_end_date
     and  pps.actual_termination_date  between  pee.effective_start_date
                                          and  pee.effective_end_date
     and  pps.actual_termination_date  between  pet.effective_start_date
                                          and  pet.effective_end_date
     and  pps.actual_termination_date  between  pev.effective_start_date
                                          and  pev.effective_end_date
     and  pps.actual_termination_date  between  piv.effective_start_date
                                          and  piv.effective_end_date
     and  pps.actual_termination_date between p_lst_year_start /*Bug3661230*/
                                          and  c_year_end
    order by pad.date_from desc;/*Bug 2977533 */

  --------------------------------------------------------------------------------------------------------------------------+
  -- Bug 5956223 cursor to fetch input values Transitional ETP and Part of Previously Paid ETP of Element ETP on Termination
  --------------------------------------------------------------------------------------------------------------------------+
cursor  etp_trans_paid_flags(c_assignment_id per_all_Assignments_f.assignment_id%type,
                               c_year_start    date ,
                               c_year_end      date ) IS
select  prv.result_value INPUT_VALUE,piv.name INPUT_NAME
from    pay_element_types_f    pet
       ,pay_input_values_f     piv
       ,per_all_assignments_f  paa
       ,pay_run_results        prr
       ,pay_run_result_values  prv
       ,pay_assignment_actions pac
       ,pay_payroll_actions    ppa
where   pet.element_type_id      = piv.element_type_id
  and   pet.element_name         = 'ETP on Termination'
  and   piv.name                 in ('Transitional ETP','Part of Previously Paid ETP')
  and   paa.assignment_id        = c_assignment_id
  and   prv.input_value_id       = piv.input_value_id
  and   prr.element_type_id      = pet.element_type_id
  and   prr.run_result_id        = prv.run_result_id
  and   prr.assignment_action_id = pac.assignment_action_id
  and   pac.assignment_id        = paa.assignment_id
  and   pac.payroll_action_id    = ppa.payroll_action_id
  and   paa.effective_start_date between pet.effective_start_date and pet.effective_end_date
  and   paa.effective_start_date between piv.effective_start_date and piv.effective_end_date
   and    ppa.action_type             in ('R','Q','I','B','V')
  and   ppa.effective_date       between paa.effective_start_date and paa.effective_end_date
  and   ppa.effective_date between c_year_start  and c_year_end
 and   pac.tax_unit_id = p_registered_employer
 order by prr.run_result_id;

   l_etp_details  etp_details%rowtype;
   l_country      fnd_territories_tl.territory_short_name%type;

   lv_transitional_flag  VARCHAR2(1);
   lv_part_prev_etp_flag VARCHAR2(1);
Begin
  IF g_debug THEN
      hr_utility.set_location('Start of archive etp details procedure.. ', 1);
      hr_utility.set_location('Assignment action id : '||p_assignment_action_id, 2);
  END if;

   lv_transitional_flag   :='N';
   lv_part_prev_etp_flag  :='N';

  open etp_details(p_business_group_id
                  ,p_registered_employer
                  ,p_payroll_action_id
                  ,p_assignment_id
                  ,p_year_start
                  ,p_year_end);

  fetch etp_details into l_etp_details;

  if etp_details%found then
    close etp_details;
    IF g_debug THEN
        hr_utility.set_location('etp tfn ' || l_etp_details.tax_file_number, 1);
    END if;

    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_TAX_FILE_NUMBER',
                                   l_etp_details.tax_file_number);

    create_extract_archive_details(p_assignment_action_id,
                                   'X_ETP_EMPLOYEE_SURNAME',
                                    l_etp_details.employee_last_name);


    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_EMPLOYEE_FIRST_NAME',
                                   l_etp_details.employee_first_name);

    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_EMPLOYEE_MIDDLE_NAME',
                                   l_etp_details.employee_middle_name);

    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_EMPLOYEE_ADDRESS_1',
                                   l_etp_details.employee_address_1);

    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_EMPLOYEE_ADDRESS_2',
                                   l_etp_details.employee_address_2);

   create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_EMPLOYEE_ADDRESS_3',
                                   l_etp_details.employee_address_3);

    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_EMPLOYEE_SUBURB',
                                   l_etp_details.employee_suburb);

    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_EMPLOYEE_STATE',
                                   l_etp_details.employee_state);

    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_EMPLOYEE_POSTCODE',
                                   l_etp_details.employee_postcode);

    /* Bug 5364017 - Check for Generic Address
       IF Address Style is Generic - then get the country name as entered in Address form
    */
      IF    (l_etp_details.address_style = 'GENERIC')
      THEN
            l_country := l_etp_details.address_country;
      ELSE
            l_country := l_etp_details.employee_country;
      END IF;

    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_EMPLOYEE_COUNTRY',
                                   l_country);

    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_EMPLOYEE_DATE_OF_BIRTH',
                                   l_etp_details.employee_date_of_birth);

    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_DEATH_BENEFIT',
                                   l_etp_details.death_benefit);

    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_DEATH_BENEFIT_TYPE',
                                   l_etp_details.death_benefit_type);

   /*Begin 8315198 - The value of tax file number for death benefit ETP entered in termination form
                     is archived from FY 2009 onwards*/

  if (to_number(to_char(p_year_start,'YYYY')) >= 2009) then
    create_extract_archive_details(p_assignment_action_id,
                                  'X_ETP_DEATH_BENEFIT_TFN',
                                   l_etp_details.etp_death_benefit_tfn);
  end if;
   /*End 8315198*/

  else
    IF g_debug THEN
    hr_utility.set_location('Details for terminated employee not found ', 3);
   END if;
    close etp_details;
  end if;

/*Bug 5956223 Begin*/
for csr_trans in etp_trans_paid_flags(p_assignment_id ,p_year_start,p_year_end )
loop
    if csr_trans.INPUT_NAME = 'Transitional ETP' then
       lv_transitional_flag := csr_trans.INPUT_VALUE;
    end if;

    if csr_trans.INPUT_NAME = 'Part of Previously Paid ETP' then
       lv_part_prev_etp_flag := csr_trans.INPUT_VALUE;
    end if;

end loop;

/*Bug 6192381  assigning values to out variables */
/*Bug 7135544  Added NVL (N) to lv_transitional_flag and lv_part_prev_etp_flag */
         p_transitional_flag  := nvl(lv_transitional_flag,'N');
         p_part_prev_etp_flag := nvl(lv_part_prev_etp_flag,'N');

  create_extract_archive_details(p_assignment_action_id,
                                'X_TRANSITIONAL_ETP',
                                p_transitional_flag);

  create_extract_archive_details(p_assignment_action_id,
                                'X_PART_OF_PREVIOUS_ETP',
                                p_part_prev_etp_flag);

/*Bug 5956223 End*/

  ----------------------------------------------------
  -- Added for Bug 1746093
  -- this subprogram archives X_ETP_ON_TERMINATION_PAID
  -- and  X_ETP_EMPLOYEE_PAYMENT_DATE
  ----------------------------------------------------
   archive_etp_payment_details( p_assignment_action_id ,
                        p_registered_employer, --2610141
                        p_assignment_id ,
                        p_year_start,
                        p_year_end );

  IF g_debug THEN
      hr_utility.set_location('exiting archive etp details procedure ', 3);
  END if;
exception
  when others then
    if etp_details%isopen  then
      close etp_details;
    end if;
    IF g_debug THEN
        hr_utility.set_location('Error in archive etp details.  ', 300);
    END if;
    raise;
End archive_etp_details;

  ----------------------------------------------------------------------+
   -- this procedure creates archive items
    -- X_PRE_JUL_83_COMPONENT_ASG_YTD
    -- X_POST_JUN_83_TAXED_ASG_YTD
    -- X_POST_JUN_83_UNTAXED_ASG_YTD
    -- X_DAYS_PRE_JUL_83
    -- X_DAYS_POST_JUL_83
   -- for terminated employees
  ---------------------------------------------------------------------+


procedure archive_prepost_details
     (p_assignment_action_id    in   pay_assignment_actions.ASSIGNMENT_ACTION_ID%TYPE
     ,p_max_assignment_action_id in  pay_assignment_actions.ASSIGNMENT_ACTION_ID%TYPE --2610141
     ,p_registered_employer     in   pay_assignment_actions.TAX_UNIT_ID%TYPE --2610141
     ,p_legislation_code        in   pay_defined_balances.legislation_code%TYPE
     ,p_assignment_id           in   pay_assignment_actions.ASSIGNMENT_ID%type
     ,p_payroll_action_id       in   pay_payroll_actions.payroll_action_id%TYPE
     ,p_actual_termination_date in   per_periods_of_service.actual_termination_date%TYPE
     ,p_date_start              in   per_periods_of_service.date_start%TYPE
     ,p_year_start              in   pay_payroll_actions.effective_date%type
     ,p_year_end                in   pay_payroll_Actions.effective_date%type
     ,p_transitional_flag       in   varchar2 /*Bug 6192381 Added New Parameters p_transitional_flag and p_part_prev_etp_flag */
     ,p_part_prev_etp_flag      in   varchar2) is


      v_some_warning                 BOOLEAN;
      v_bal_value                    VARCHAR2(20);
      v_user_entity_id               NUMBER;
      v_archive_item_id              ff_archive_items.archive_item_id%TYPE;
      v_object_version_number        NUMBER;
      e_prepost_error                EXCEPTION;
      l_result                       NUMBER;

      l_etp_payment                  NUMBER;
      l_pre01jul1983_days            NUMBER;
      l_post30jun1983_days           NUMBER;
      l_pre01jul1983_ratio           NUMBER;
      l_post30jun1983_ratio          NUMBER;
      l_pre01jul1983_value           NUMBER;
      l_post30jun1983_value          NUMBER;
      l_etp_service_date             date;    /*  Bug# 2984390 */
      v_etp_service_date             VARCHAR2(20);
      l_le_etp_service_date          date; /* Bug 4177679*/
      l_balance_name                 pay_balance_types.balance_name%TYPE;
      l_indx                         NUMBER;
      l_lump_sum_c_pre_83_amt        NUMBER; /* Start 8769345 */
      l_lump_sum_c_post_83_amt       NUMBER; /* End 8769345 */
     TYPE prepost_rec IS RECORD (item_name  varchar2(50),
                                 item_value number );
     TYPE prepost_type IS TABLE OF prepost_rec INDEX BY BINARY_INTEGER;
     tab_prepost_dtls prepost_type;

      l_etp_pay_tran_no_ppetp       NUMBER;
      l_etp_pay_tran_ppetp          NUMBER;
      l_etp_pay_no_tran_no_ppetp    NUMBER;
      l_etp_pay_no_tran_ppetp       NUMBER;
      l_etp_pay_total               NUMBER;

      l_old_etp_pay                 NUMBER;
      l_old_pre01jul1983_value      NUMBER;
      l_old_post30jun1983_value     NUMBER;

      l_item_name_pre               VARCHAR2(50);
      l_item_name_post               VARCHAR2(50);
      l_etp_new_bal_total           NUMBER; /* Bug 9226023 - Variable to store the sum of Taxable and Tax free portions of ETP balances */
      l_etp_pay_value               NUMBER; /* Bug 9226023 - Temporary variable to store the ETP Taxble or Tax Free value */

     /* Bug 2826802 : Cursor to get the Lump Sum C Payment balance value */
     /* Bug 6192381 : Removed cursor get_etp_payment_value as using BBR now*/

  type etp_bal_type is table of varchar2(100) index by binary_integer;
  tab_etp_bal_name etp_bal_type ;

  begin
     IF g_debug THEN
        hr_utility.set_location('Start of archive_prepost_details',15);
        hr_utility.set_location('Start of p_assg_action_id '|| p_assignment_action_id,16);
     END if;

     --------------------------------------------------------------------------------+
     -- if the employee type is not current then archive the following termination details
     -- X_PRE_JUL_83_COMPONENT_ASG_YTD
     -- X_POST_JUN_83_UNTAXED_ASG_YTD
     -- X_POST_JUN_83_TAXED_ASG_YTD
     -- X_DAYS_PRE_JUL_83
     -- X_DAYS_POST_JUL_83

     --   Bug No : 2826802
     --   The value of the Lump Sum C Payment balance will be fetched using
     --   hr_aubal.calc_all_balances. The value will be used as ETP Payment.
     --
     --   This value is multiplied by etp ratio obtained from
     --   pay_au_terminations.etp_prepost_ratios to get
     --   the value for X_PRE_JUL_83_COMPONENT and  X_POST_JUN_83_TAXED.
     --
     --   Value for the other two archive items X_DAYS_PRE_JUL_83
     --   and  X_DAYS_POST_JUL_83 are returned as an out parameter.
     --   The archive item name and archive item value are
     --   populated in a pl/sql table ( which is of record type)
     --
     --   Now we have all the parameters required to call create_extract_archive_details
     --   so we call it for the above archive items.
     --------------------------------------------------------------------------------+

     /* Bug 2826802 : Get the Value of etp payment as value of the Lump Sum C Payment
        Balance and use it to get the pre and post 83 values */

         l_pre01jul1983_value  := 0;
         l_post30jun1983_value := 0;

         l_pre01jul1983_days  := 0;
         l_post30jun1983_days := 0;

      l_etp_pay_tran_no_ppetp       := 0;
      l_etp_pay_tran_ppetp          := 0;
      l_etp_pay_no_tran_no_ppetp    := 0;
      l_etp_pay_no_tran_ppetp       := 0;
      l_etp_pay_total               := 0;

      l_old_etp_pay                 := 0;
      l_old_pre01jul1983_value      := 0;
      l_old_post30jun1983_value     := 0;

     --------------------------------------------------------------------------------+
     -- this procedure gets the ratios to calculate prejul83 balance and postjun83 balance
     --------------------------------------------------------------------------------+
         IF g_debug THEN
            hr_utility.set_location('calling pay_au_terminations.etp_prepost_ratios ',17);
         END if;

          l_result := pay_au_terminations.etp_prepost_ratios(
                     p_assignment_id              -- number                  in
                    ,p_date_start                 -- date                    in
                    ,p_actual_termination_date    -- date                    in
                    ,'N'                          -- Bug#2819479 Flag to check whether this function called by Termination Form.
                    ,l_pre01jul1983_days          -- number                  out
                    ,l_post30jun1983_days         -- number                  out
                    ,l_pre01jul1983_ratio         -- number                  out
                    ,l_post30jun1983_ratio        -- number                  out
                    ,l_etp_service_date           -- date                    out
                    ,l_le_etp_service_date);      -- date                    out  /* Bug 4177679 */

/*Bug 6192381 Introduced call to pay_balance_pkg.get_value to use BBR for ETP Payment Balances
  Removed cursor get_etp_payment_value and its call*/

    p_etp_result_table.delete;

    p_etp_context_table(1).tax_unit_id := p_registered_employer;
    --
    pay_balance_pkg.get_value
    (p_assignment_action_id     => p_max_assignment_action_id
    ,p_defined_balance_lst  => p_etp_balance_value_tab
    ,p_context_lst      => p_etp_context_table
    ,p_output_table         => p_etp_result_table
    );

    if g_debug then
      hr_utility.trace('------------------------------------------------');
      hr_utility.trace('ETP Payments Transitional Not Part of Prev Term   ===>' || p_etp_result_table(1).balance_value);
      hr_utility.trace('ETP Payments Transitional Part of Prev Term       ===>' || p_etp_result_table(2).balance_value);
      hr_utility.trace('ETP Payments Life Benefit Not Part of Prev Term   ===>' || p_etp_result_table(3).balance_value);
      hr_utility.trace('ETP Payments Life Benefit Part of Prev Term       ===>' || p_etp_result_table(4).balance_value);
      hr_utility.trace('Lump Sum C Payments                               ===>' || p_etp_result_table(13).balance_value);
     /* Start 8769345 - Added trace for new ETP balances */
      hr_utility.trace('ETP Tax Free Payments Transitional Not Part of Prev Term ===>' || p_etp_result_table(5).balance_value);
      hr_utility.trace('ETP Taxable Payments Transitional Not Part of Prev Term  ===>' || p_etp_result_table(6).balance_value);
      hr_utility.trace('ETP Tax Free Payments Transitional Part of Prev Term     ===>' || p_etp_result_table(7).balance_value);
      hr_utility.trace('ETP Taxable Payments Transitional Part of Prev Term      ===>' || p_etp_result_table(8).balance_value);
      hr_utility.trace('ETP Tax Free Payments Life Benefit Not Part of Prev Term ===>' || p_etp_result_table(9).balance_value);
      hr_utility.trace('ETP Taxable Payments Life Benefit Not Part of Prev Term  ===>' || p_etp_result_table(10).balance_value);
      hr_utility.trace('ETP Tax Free Payments Life Benefit Part of Prev Term     ===>' || p_etp_result_table(11).balance_value);
      hr_utility.trace('ETP Taxable Payments Life Benefit Part of Prev Term      ===>' || p_etp_result_table(12).balance_value);
     /* End 8769345 */
    end if;

    tab_etp_bal_name(1) := 'ETP Payments Transitional Not Part of Prev Term';
    tab_etp_bal_name(2) := 'ETP Payments Transitional Part of Prev Term';
    tab_etp_bal_name(3) := 'ETP Payments Life Benefit Not Part of Prev Term';
    tab_etp_bal_name(4) := 'ETP Payments Life Benefit Part of Prev Term';
    tab_etp_bal_name(13) := 'Lump Sum C Payments';
 /* Start 8769345 */
    tab_etp_bal_name(5) := 'ETP Tax Free Payments Transitional Not Part of Prev Term';
    tab_etp_bal_name(6) := 'ETP Taxable Payments Transitional Not Part of Prev Term';
    tab_etp_bal_name(7) := 'ETP Tax Free Payments Transitional Part of Prev Term';
    tab_etp_bal_name(8) := 'ETP Taxable Payments Transitional Part of Prev Term';
    tab_etp_bal_name(9) := 'ETP Tax Free Payments Life Benefit Not Part of Prev Term';
    tab_etp_bal_name(10) := 'ETP Taxable Payments Life Benefit Not Part of Prev Term';
    tab_etp_bal_name(11) := 'ETP Tax Free Payments Life Benefit Part of Prev Term';
    tab_etp_bal_name(12) := 'ETP Taxable Payments Life Benefit Part of Prev Term';
 /* End  8769345 */

     l_indx := 1;

     /* Bug 8769345 - Two new local variables are defined which will hold the pre 83 and post 83 components of
	              Lump Sum C Payments */

     l_lump_sum_c_pre_83_amt := 0;
     l_lump_sum_c_post_83_amt := 0;

/* Start 9226023 - The sum of Taxable and Tax free portions of ETP balances introduced as part of bug 8769345
                   are stored in the variable ,which will be used in calculating the ETP Taxable and Tax free amounts of
		   terminated employees processed before applying the patch 8769345*/

     l_etp_new_bal_total := p_etp_result_table(5).balance_value + p_etp_result_table(6).balance_value +
	 	            p_etp_result_table(7).balance_value + p_etp_result_table(8).balance_value +
			    p_etp_result_table(9).balance_value + p_etp_result_table(10).balance_value +
			    p_etp_result_table(11).balance_value + p_etp_result_table(12).balance_value;

/* End 9226023 */

     for etp_pay_rec in 1..tab_etp_bal_name.count
     loop

         if g_debug then
           hr_utility.trace('Balance Name '||tab_etp_bal_name(etp_pay_rec)|| ' Balance Value '||p_etp_result_table(etp_pay_rec).balance_value);
         end if;


          if l_result = 0 then
             raise e_prepost_error;
          else
                 l_etp_pay_value :=0;
        --------------------------------------------------------------------------------+
        --populate a pl/sql table with the details of the archive items
        --------------------------------------------------------------------------------+

  /* Bug 6192381  appending Pre Post values for new balances */

	     if tab_etp_bal_name(etp_pay_rec) = 'ETP Payments Transitional Not Part of Prev Term' then

               l_etp_pay_tran_no_ppetp :=  p_etp_result_table(etp_pay_rec).balance_value;

             elsif tab_etp_bal_name(etp_pay_rec) = 'ETP Payments Transitional Part of Prev Term' then

               l_etp_pay_tran_ppetp :=  p_etp_result_table(etp_pay_rec).balance_value;

             elsif tab_etp_bal_name(etp_pay_rec) = 'ETP Payments Life Benefit Not Part of Prev Term' then

               l_etp_pay_no_tran_no_ppetp :=  p_etp_result_table(etp_pay_rec).balance_value;

	     elsif tab_etp_bal_name(etp_pay_rec) = 'ETP Payments Life Benefit Part of Prev Term' then

               l_etp_pay_no_tran_ppetp :=  p_etp_result_table(etp_pay_rec).balance_value;

             /* Start 8769345 - Code is modified such that pre 83 and post 83 values for different combinations of Transitional and
 	                        Part of Previously Paid ETP are calculated by directly accessing the new ETP tax free and taxable balances. */
	     /* Start 9226023 - Logic modified to support the calculation of Taxable and Tax Free portions of ETP for terminated employees
	                        processed before applying the patch 8769345 */

             elsif tab_etp_bal_name(etp_pay_rec) = 'ETP Tax Free Payments Transitional Not Part of Prev Term' then

	       if (l_etp_new_bal_total > 0) then
	         if (p_etp_result_table(13).balance_value - l_etp_new_bal_total = 0) then
		    l_etp_pay_value :=p_etp_result_table(etp_pay_rec).balance_value;

		 elsif (p_etp_result_table(13).balance_value - l_etp_new_bal_total > 0) then
                    l_etp_pay_value := (p_etp_result_table(1).balance_value - (p_etp_result_table(5).balance_value + p_etp_result_table(6).balance_value))*l_pre01jul1983_ratio +
                                              p_etp_result_table(etp_pay_rec).balance_value;
                 end if;
	       else
		  l_etp_pay_value := p_etp_result_table(1).balance_value*l_pre01jul1983_ratio;
	       end if;

	      tab_prepost_dtls(l_indx).item_name :='X_PRE_JUL_83_COMP_TRANS_NOT_PPTERM_ASG_YTD';
	      tab_prepost_dtls(l_indx).item_value := round(l_etp_pay_value,2) ;
	      l_lump_sum_c_pre_83_amt := l_lump_sum_c_pre_83_amt + tab_prepost_dtls(l_indx).item_value;

	      l_indx := l_indx + 1;
             elsif tab_etp_bal_name(etp_pay_rec) = 'ETP Taxable Payments Transitional Not Part of Prev Term' then

		if (l_etp_new_bal_total > 0) then
		 if (p_etp_result_table(13).balance_value - l_etp_new_bal_total = 0) then
                    l_etp_pay_value :=p_etp_result_table(etp_pay_rec).balance_value;

		 elsif (p_etp_result_table(13).balance_value - l_etp_new_bal_total > 0) then
		    l_etp_pay_value := (p_etp_result_table(1).balance_value - (p_etp_result_table(5).balance_value + p_etp_result_table(6).balance_value))*l_post30jun1983_ratio +
                                              p_etp_result_table(etp_pay_rec).balance_value;
                 end if;
	       else
		   l_etp_pay_value := p_etp_result_table(1).balance_value*l_post30jun1983_ratio;
	       end if;

              tab_prepost_dtls(l_indx).item_name :='X_POST_JUN_83_TAXED_TRANS_NOT_PPTERM_ASG_YTD';
              tab_prepost_dtls(l_indx).item_value := round(l_etp_pay_value,2);
	      l_lump_sum_c_post_83_amt := l_lump_sum_c_post_83_amt + tab_prepost_dtls(l_indx).item_value;

              l_indx := l_indx + 1;

             elsif tab_etp_bal_name(etp_pay_rec) = 'ETP Tax Free Payments Transitional Part of Prev Term' then

      	       if (l_etp_new_bal_total > 0) then
		 if (p_etp_result_table(13).balance_value - l_etp_new_bal_total = 0) then
                    l_etp_pay_value :=p_etp_result_table(etp_pay_rec).balance_value;

                 elsif (p_etp_result_table(13).balance_value - l_etp_new_bal_total > 0) then
                    l_etp_pay_value := (p_etp_result_table(2).balance_value - (p_etp_result_table(7).balance_value + p_etp_result_table(8).balance_value))*l_pre01jul1983_ratio +
                                             p_etp_result_table(etp_pay_rec).balance_value;
                 end if;
	       else
		   l_etp_pay_value := p_etp_result_table(2).balance_value*l_pre01jul1983_ratio;
	       end if;

	      tab_prepost_dtls(l_indx).item_name :='X_PRE_JUL_83_COMP_TRANS_PPTERM_ASG_YTD';
              tab_prepost_dtls(l_indx).item_value := round(l_etp_pay_value,2);
              l_lump_sum_c_pre_83_amt := l_lump_sum_c_pre_83_amt + tab_prepost_dtls(l_indx).item_value;

	      l_indx := l_indx + 1;

             elsif tab_etp_bal_name(etp_pay_rec) = 'ETP Taxable Payments Transitional Part of Prev Term' then

       	       if (l_etp_new_bal_total > 0) then
		 if (p_etp_result_table(13).balance_value - l_etp_new_bal_total = 0) then
                    l_etp_pay_value :=p_etp_result_table(etp_pay_rec).balance_value;

                 elsif (p_etp_result_table(13).balance_value - l_etp_new_bal_total > 0) then
                    l_etp_pay_value := (p_etp_result_table(2).balance_value - (p_etp_result_table(7).balance_value + p_etp_result_table(8).balance_value))*l_post30jun1983_ratio +
                                             p_etp_result_table(etp_pay_rec).balance_value;
                 end if;
	       else
		   l_etp_pay_value := p_etp_result_table(2).balance_value*l_post30jun1983_ratio;
	       end if;

	      tab_prepost_dtls(l_indx).item_name :='X_POST_JUN_83_TAXED_TRANS_PPTERM_ASG_YTD';
              tab_prepost_dtls(l_indx).item_value := round(l_etp_pay_value,2);
	      l_lump_sum_c_post_83_amt := l_lump_sum_c_post_83_amt + tab_prepost_dtls(l_indx).item_value;

	      l_indx := l_indx + 1;

             elsif tab_etp_bal_name(etp_pay_rec) = 'ETP Tax Free Payments Life Benefit Not Part of Prev Term' then

      	       if (l_etp_new_bal_total > 0) then
		 if (p_etp_result_table(13).balance_value - l_etp_new_bal_total = 0) then
                    l_etp_pay_value :=p_etp_result_table(etp_pay_rec).balance_value;

                 elsif (p_etp_result_table(13).balance_value - l_etp_new_bal_total > 0) then
                    l_etp_pay_value := (p_etp_result_table(3).balance_value - (p_etp_result_table(9).balance_value + p_etp_result_table(10).balance_value))*l_pre01jul1983_ratio +
                                             p_etp_result_table(etp_pay_rec).balance_value;
                 end if;
	       else
		   l_etp_pay_value := p_etp_result_table(3).balance_value*l_pre01jul1983_ratio;
	       end if;

              tab_prepost_dtls(l_indx).item_name :='X_PRE_JUL_83_COMP_NOT_TRANS_NOT_PPTERM_ASG_YTD';
              tab_prepost_dtls(l_indx).item_value := round(l_etp_pay_value,2);
	      l_lump_sum_c_pre_83_amt := l_lump_sum_c_pre_83_amt + tab_prepost_dtls(l_indx).item_value;

	      l_indx := l_indx + 1;

             elsif tab_etp_bal_name(etp_pay_rec) = 'ETP Taxable Payments Life Benefit Not Part of Prev Term' then

       	       if (l_etp_new_bal_total > 0) then
		 if (p_etp_result_table(13).balance_value - l_etp_new_bal_total = 0) then
                    l_etp_pay_value :=p_etp_result_table(etp_pay_rec).balance_value;

                 elsif (p_etp_result_table(13).balance_value - l_etp_new_bal_total > 0) then
                    l_etp_pay_value := (p_etp_result_table(3).balance_value - (p_etp_result_table(9).balance_value + p_etp_result_table(10).balance_value))*l_post30jun1983_ratio +
                                             p_etp_result_table(etp_pay_rec).balance_value;
                 end if;
	       else
		   l_etp_pay_value := p_etp_result_table(3).balance_value*l_post30jun1983_ratio;
	       end if;

	      tab_prepost_dtls(l_indx).item_name :='X_POST_JUN_83_TAXED_NOT_TRANS_NOT_PPTERM_ASG_YTD';
              tab_prepost_dtls(l_indx).item_value := round(l_etp_pay_value,2);
	      l_lump_sum_c_post_83_amt := l_lump_sum_c_post_83_amt + tab_prepost_dtls(l_indx).item_value;

	      l_indx := l_indx + 1;

  	     elsif tab_etp_bal_name(etp_pay_rec) = 'ETP Tax Free Payments Life Benefit Part of Prev Term' then

      	       if (l_etp_new_bal_total > 0) then
		 if (p_etp_result_table(13).balance_value - l_etp_new_bal_total = 0) then
                    l_etp_pay_value :=p_etp_result_table(etp_pay_rec).balance_value;

                 elsif (p_etp_result_table(13).balance_value - l_etp_new_bal_total > 0) then
                    l_etp_pay_value := (p_etp_result_table(4).balance_value - (p_etp_result_table(11).balance_value + p_etp_result_table(12).balance_value))*l_pre01jul1983_ratio +
                                             p_etp_result_table(etp_pay_rec).balance_value;
                 end if;
	       else
		   l_etp_pay_value := p_etp_result_table(4).balance_value*l_pre01jul1983_ratio;
	       end if;

              tab_prepost_dtls(l_indx).item_name :='X_PRE_JUL_83_COMP_NOT_TRANS_PPTERM_ASG_YTD';
              tab_prepost_dtls(l_indx).item_value := round(l_etp_pay_value,2) ;
              l_lump_sum_c_pre_83_amt := l_lump_sum_c_pre_83_amt + tab_prepost_dtls(l_indx).item_value;

	      l_indx := l_indx + 1;

  	     elsif tab_etp_bal_name(etp_pay_rec) = 'ETP Taxable Payments Life Benefit Part of Prev Term' then

       	       if (l_etp_new_bal_total > 0) then
		 if (p_etp_result_table(13).balance_value - l_etp_new_bal_total = 0) then
                    l_etp_pay_value := p_etp_result_table(etp_pay_rec).balance_value;

                 elsif (p_etp_result_table(13).balance_value - l_etp_new_bal_total > 0) then
                    l_etp_pay_value := (p_etp_result_table(4).balance_value - (p_etp_result_table(11).balance_value + p_etp_result_table(12).balance_value))*l_post30jun1983_ratio +
                                              p_etp_result_table(etp_pay_rec).balance_value;
                 end if;
	       else
		   l_etp_pay_value := p_etp_result_table(4).balance_value*l_post30jun1983_ratio;
	       end if;

              tab_prepost_dtls(l_indx).item_name :='X_POST_JUN_83_TAXED_NOT_TRANS_PPTERM_ASG_YTD';
              tab_prepost_dtls(l_indx).item_value := round(l_etp_pay_value,2);
	      l_lump_sum_c_post_83_amt := l_lump_sum_c_post_83_amt + tab_prepost_dtls(l_indx).item_value;

	      l_indx := l_indx + 1;

	     /* End 8769345 */
	     /* End 9226023 */
            elsif tab_etp_bal_name(etp_pay_rec) = 'Lump Sum C Payments' then

               l_etp_pay_total :=  p_etp_result_table(etp_pay_rec).balance_value;

               tab_prepost_dtls(l_indx).item_name :='X_PRE_JUL_83_COMPONENT_ASG_YTD';
               tab_prepost_dtls(l_indx).item_value :=l_lump_sum_c_pre_83_amt;

               l_indx := l_indx + 1;

               tab_prepost_dtls(l_indx).item_name :='X_POST_JUN_83_TAXED_ASG_YTD';
               tab_prepost_dtls(l_indx).item_value :=l_lump_sum_c_post_83_amt;

               l_indx := l_indx + 1;

               tab_prepost_dtls(l_indx).item_name :='X_DAYS_PRE_JUL_83';
               tab_prepost_dtls(l_indx).item_value :=l_pre01jul1983_days;

               l_indx := l_indx + 1;

               tab_prepost_dtls(l_indx).item_name :='X_DAYS_POST_JUL_83';
               tab_prepost_dtls(l_indx).item_value :=l_post30jun1983_days;

               l_indx := l_indx + 1;

            end if;

        /*  Bug# 2984390 - If ETP service date is entered then X_ETP_EMPLOYEE_START_DATE consists of ETP service
                           date otherwise Hiredate */
        /* Bug 4177679 - If ETP service date is entered then X_ETP_EMPLOYEE_START_DATE consists of ETP service
                           date otherwise legal employer start date */
       /*  Bug# 5367061 - If ETP service date is entered then X_ETP_EMPLOYEE_START_DATE consists of ETP service
                           date otherwise Hiredate, Fix made in 4177679 backed out. */

            g_le_etp_flag := 'Y' ;

             v_etp_service_date := to_char(l_etp_service_date,'DDMMYYYY');
      --------------------------------------------------------------------------------+
        -- fetch the user_entity_id for all the archive items and call procedure
        -- ff_archive_api.create_archive_item to arhive this value.
        --------------------------------------------------------------------------------+
       end if;
     end loop;

        tab_prepost_dtls(l_indx).item_name :='X_POST_JUN_83_UNTAXED_ASG_YTD';
        tab_prepost_dtls(l_indx).item_value :=0;                                 /* Bug #2075782 */

     create_extract_archive_details(p_assignment_action_id,
                                       'X_ETP_EMPLOYEE_START_DATE',
                                        v_etp_service_date);

/* Begin Bug 6192381  For Termination Payments before Multiple ETP Payment Enhancement the new balances for each combination
does not exist , therefore to find out the values difference of Old balance which has total values and sum of new balances
is taken to archive the old values

This value is then divided in Pre Post ratios and added to corresponding values based on input values Transitional ETP
and Part of Previously Paid ETP .
*/

     l_old_etp_pay  := l_etp_pay_total - ( l_etp_pay_tran_no_ppetp + l_etp_pay_tran_ppetp    +
                                           l_etp_pay_no_tran_no_ppetp + l_etp_pay_no_tran_ppetp );

    If ( l_old_etp_pay > 0 ) then

          l_old_pre01jul1983_value  := round(l_old_etp_pay*l_pre01jul1983_ratio,2);
          l_old_post30jun1983_value := round(l_old_etp_pay*l_post30jun1983_ratio,2);

         If p_transitional_flag ='Y' and p_part_prev_etp_flag = 'N' then
           l_item_name_pre  := 'X_PRE_JUL_83_COMP_TRANS_NOT_PPTERM_ASG_YTD';
           l_item_name_post := 'X_POST_JUN_83_TAXED_TRANS_NOT_PPTERM_ASG_YTD';
         End if;

         If p_transitional_flag ='Y' and p_part_prev_etp_flag = 'Y' then
           l_item_name_pre  := 'X_PRE_JUL_83_COMP_TRANS_PPTERM_ASG_YTD';
           l_item_name_post := 'X_POST_JUN_83_TAXED_TRANS_PPTERM_ASG_YTD';
         End if;

         If p_transitional_flag ='N' and p_part_prev_etp_flag = 'N' then
           l_item_name_pre  := 'X_PRE_JUL_83_COMP_NOT_TRANS_NOT_PPTERM_ASG_YTD';
           l_item_name_post := 'X_POST_JUN_83_TAXED_NOT_TRANS_NOT_PPTERM_ASG_YTD';
         End if;

         If p_transitional_flag ='N' and p_part_prev_etp_flag = 'Y' then
           l_item_name_pre  := 'X_PRE_JUL_83_COMP_NOT_TRANS_PPTERM_ASG_YTD';
           l_item_name_post := 'X_POST_JUN_83_TAXED_NOT_TRANS_PPTERM_ASG_YTD';
         End if;

         for j in 1..tab_prepost_dtls.COUNT
         loop

             if tab_prepost_dtls(j).item_name = l_item_name_pre then
                tab_prepost_dtls(j).item_value := tab_prepost_dtls(j).item_value + l_old_pre01jul1983_value ;
             end if;

             if tab_prepost_dtls(j).item_name = l_item_name_post then
                tab_prepost_dtls(j).item_value := tab_prepost_dtls(j).item_value + l_old_post30jun1983_value ;
             end if;
         end loop;

    End if; /* End Bug 6192381 */

        for cnt in 1..tab_prepost_dtls.COUNT loop
           create_extract_archive_details(p_assignment_action_id,
                                          tab_prepost_dtls(cnt).item_name,
                                          tab_prepost_dtls(cnt).item_value);
        end loop;


     IF g_debug THEN
        hr_utility.set_location('End of archive_prepost_details',18);
     END if;

exception
  when e_prepost_error then
     IF g_debug THEN
        hr_utility.set_location('error from pay_au_terminations.etp_prepost_ratios',20);
     END if;
  when others then
     IF g_debug THEN
        hr_utility.set_location('error in archive_prepost_details',21);
     END if;
  raise;
end  archive_prepost_details;

---------------------------------------------------------------------------------------+
-- this procedure archives all the data related to employer.
---------------------------------------------------------------------------------------+

Procedure archive_employer_details
          (p_business_group_id    in hr_organization_units.business_group_id%type,
           p_max_assignment_action_id  in pay_assignment_actions.assignment_action_id%TYPE, --2610141
           p_registered_employer  in hr_organization_units.organization_id%type,
       p_payroll_action_id    in pay_payroll_actions.payroll_action_id%type,
       p_assignment_action_id in pay_assignment_actions.assignment_action_id%type,
       p_assignment_id        in pay_assignment_actions.assignment_id%type,
       p_year_start           in pay_payroll_actions.effective_date%type,
       p_year_end             in pay_payroll_Actions.effective_date%type) is



  l_group_act_no     hr_organization_information.org_information1%type;
  l_business_name        hr_organization_information.org_information3%type;
  l_trading_name         hr_organization_information.org_information4%type;
  l_abn                  hr_organization_information.org_information12%type;
  l_branch_number        hr_organization_information.org_information13%type;
  l_contact_name         hr_organization_information.org_information7%type;
  l_tel_number           per_addresses.telephone_number_1%type;
  l_address_1            hr_locations.address_line_1%type;
  l_address_2            hr_locations.address_line_2%type;
  l_address_3            hr_locations.address_line_3%type;
  l_suburb               hr_locations.town_or_city%type;
  l_state                hr_locations.region_1%type;
  l_postcode             hr_locations.postal_code%type;
  l_country              fnd_territories_tl.territory_short_name%type;
  l_signatory            hr_organization_information.org_information8%type;
  e_employer_nf          EXCEPTION;


---------------------------------------------------------------------------------+
  --   cursor to get the employer details
  --   changed for bug# 1783245
---------------------------------------------------------------------------------+

  cursor   employer_details
      is
  select  hoi.org_information1      group_act_no
         ,hoi.org_information3      business_name
         ,hoi.org_information4      trading_name
         ,hoi.org_information12     abn
         ,hoi.org_information13     branch_no
         ,papcont.first_name || ' ' || papcont.last_name
                                    contact_name
         ,hoi.org_information14     telephone_number
         ,papsign.first_name || ' ' || papsign.last_name
                                    signatory
         ,hlc.address_line_1        address_1
         ,hlc.address_line_2        address_2
         ,hlc.address_line_3        address_3
         ,hlc.town_or_city          suburb
         ,hlc.region_1              state
         ,hlc.postal_code           postcode
         ,ftl.territory_short_name  country
   from   hr_organization_information hoi
         ,hr_locations            hlc
         ,fnd_territories_tl          ftl
         ,hr_organization_units       hou
         ,per_all_people_f            papcont
         ,per_all_people_f            papsign
   where  hou.business_group_id       = p_business_group_id
     and  hou.organization_id         = p_registered_employer
     and  hou.organization_id         = hoi.organization_id
     and  hoi.org_information_context = 'AU_LEGAL_EMPLOYER'
     and  ftl.territory_code          = hlc.country
     and  ftl.language                = userenv('LANG')
     and  hlc.location_id             = hou.location_id
     and  papcont.person_id           = hoi.org_information7
     and  papcont.effective_start_date    = (select max(effective_start_date)
                                          from  per_all_people_f p
                                         where  papcont.person_id=p.person_id)
     and  papsign.person_id           = hoi.org_information8
     and  papsign.effective_start_date    = (select max(effective_start_date)
                                          from  per_all_people_f p
                                         where  papsign.person_id=p.person_id);


Begin
   IF g_debug THEN
       hr_utility.set_location('Start of archive employer details ..',0);
   END if;
   open employer_details ;
   fetch employer_details into
       l_group_act_no
      ,l_business_name
      ,l_trading_name
      ,l_abn
      ,l_branch_number
      ,l_contact_name
      ,l_tel_number
      ,l_signatory
      ,l_address_1
      ,l_address_2
      ,l_address_3
      ,l_suburb
      ,l_state
      ,l_postcode
      ,l_country ;
  if employer_details%found then
    close employer_details;
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYER_BUSINESS_NAME',1);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYER_BUSINESS_NAME',
                                   l_business_name);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYER_GROUP_ACT_NO',2);
    END if;
        create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYER_GROUP_ACT_NO',
                                    l_group_act_no);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYER_TRADING_NAME',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYER_TRADING_NAME',
                                    l_trading_name);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYER_BRANCH_NUMBER',114);
    END if;
       create_extract_archive_details(p_assignment_action_id,
                                    'X_EMPLOYER_BRANCH_NUMBER',
                                   l_branch_number);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYER_ABN',114);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYER_ABN',
                                   l_abn);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYER_CONTACT_NAME',5);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYER_CONTACT_NAME',
                                    l_contact_name);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYER_CONTACT_TELEPHONE',6);
    END if;
        create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYER_CONTACT_TELEPHONE',
                                   l_tel_number);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYER_ADDRESS_1',7);
    END if;
        create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYER_ADDRESS_1',
                                   l_address_1);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYER_ADDRESS_2',8);
    END if;
        create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYER_ADDRESS_2',
                                   l_address_2);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYER_ADDRESS_3',8);
    END if;
        create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYER_ADDRESS_3',
                                   l_address_3);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYER_SUBURB',9);
    END if;
       create_extract_archive_details(p_assignment_action_id,
                                    'X_EMPLOYER_SUBURB',
                                    l_suburb);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYER_STATE',10);
    END if;
        create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYER_STATE',
                                    l_state);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item X_EMPLOYER_POSTCODE',11);
    END if;
       create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYER_POSTCODE',
                                   l_postcode);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item X_EMPLOYER_COUNTRY',12);
    END if;
       create_extract_archive_details(p_assignment_action_id,
                                    'X_EMPLOYER_COUNTRY',
                                   l_country);
    --------------------------------
    -- Added for Bug No :1789886
    --------------------------------
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item X_PAYMENT_SUMMARY_SIGNATORY',12);
    END if;
        create_extract_archive_details(p_assignment_action_id,
                                   'X_PAYMENT_SUMMARY_SIGNATORY',
                                   l_signatory);

    --------------------------------
    -- Added for Bug No :1764017
    --------------------------------
    archive_union_name
    (p_assignment_id
    ,p_assignment_action_id
    ,p_max_assignment_action_id    --2610141
    ,p_registered_employer         --2610141
    ,p_year_start
    ,p_year_end
    );
  else
   close  employer_details;
    raise e_employer_nf;
  end if;
exception
  when e_employer_nf then
    IF g_debug THEN
        hr_utility.set_location('No employer Details found for the assigment id  ',20);
    END if;
  when others then
    IF g_debug THEN
        hr_utility.set_location('Error in archive_employer_details ',99);
    END if;
    raise;
End archive_employer_details ;

---------------------------------------------------------------------------------------+
-- this procedure archives all the data related to employee.
---------------------------------------------------------------------------------------+

Procedure archive_employee_details
      (p_business_group_id    in hr_organization_units.business_group_id%type,
       p_registered_employer  in hr_organization_units.organization_id%type,
       p_payroll_action_id    in pay_payroll_actions.payroll_action_id%type,
       p_assignment_action_id in pay_assignment_actions.assignment_action_id%type,
       p_assignment_id        in pay_assignment_actions.assignment_id%type,
       p_year_start           in pay_payroll_actions.effective_date%type,
       p_year_end             in pay_payroll_Actions.effective_date%type,
       p_end_date_flag        in varchar2,
       p_fbt_year_start       IN pay_payroll_Actions.effective_date%type) is /*Bug# 4653934*/

  l_tfn_no               pay_element_entry_values_f.screen_entry_value%type;
  l_first_name           per_all_people_f.first_name%type;
  l_middle_name          per_all_people_f.middle_names%type;
  l_surname              per_all_people_f.last_name%type;
  l_address_1            hr_locations.address_line_1%type;
  l_address_2            hr_locations.address_line_2%type;
  l_address_3            hr_locations.address_line_3%type;
  l_suburb               hr_locations.town_or_city%type;
  l_state                hr_locations.region_1%type;
  l_postcode             hr_locations.postal_code%type;
  l_country              fnd_territories_tl.territory_short_name%type;
  l_start_date           VARCHAR2(20);
  l_termination_date     VARCHAR2(20);
  l_dob                  VARCHAR2(20);
  l_asgmnt_loc           hr_locations.location_code%type;
  l_emp_no               per_all_people_f.employee_number%type;
  l_payroll              pay_all_payrolls_f.payroll_name%type;
  l_emp_type             per_all_people_f.current_employee_flag%type;
  l_address_date_from    date;
  l_date_earned          pay_payroll_actions.date_earned%type;
  l_effective_date       date; -- Bug3263659
  l_actual_termination_date per_periods_of_service.actual_termination_date%type;
  l_final_process_date   date; -- Bug3263659
  l_fpd_archive          VARCHAR2(20); -- Bug3098353
  l_le_start_date   VARCHAR2(20);
  l_le_end_date   VARCHAR2(20); -- Bug 2610141
  l_termination_type     VARCHAR2(4); -- Bug 8315198

  l_address_style        per_addresses.style%type;      -- Bug 5364017
  l_add_country          per_addresses.country%type;    -- Bug 5364017

  e_employee_nf          EXCEPTION;

  l_le_etp_service_date varchar2(20); /* Bug 4177679 */
  l_le_etp_start_date varchar2(20); /*Bug 5075662 */

  ---------------------------------------------------------------------------------+
  --      cursor to get the employee details
  ---------------------------------------------------------------------------------+

  /* Bug 1973978 -- If the Termination date of the employee is greater than the last date of the current financial
                    year then the employee should be treated as an Current Employee */
  /* Bug 2512431 -- Removed to_date for p_year_end in the select statement for emp_type  */
  /* Bug 2977533 - When a new address is created thro SS applications ,2 rows are created in
                per_addresses table for the same primary address;the previous address is end dated.
                This can also be simulated thro apps if a primary addresses is end dated and a new
                primary address is created after the end date
                The cursor fetches 2 rows and picks the old address first.To get the latest address
                order by clause has been added to pick the latest row first  */


 /*Bug3019374 - Cursor employee_details broken up into 2 cursor -> cursor  employee_details
 and cursor tfn_number*/

cursor tfn_number(c_assignment_id per_all_assignments.assignment_id%TYPE,
                  c_date_earned pay_payroll_actions.date_earned%TYPE)
is
select pev.screen_entry_value            tfn_no
from
           pay_element_types_f          pet,
           pay_input_values_f           piv,
           pay_element_links_f          pel,
           pay_element_entries_f        pee,
           pay_element_entry_values_f   pev
where      pet.element_name            = 'Tax Information'
      and  piv.name                    = 'Tax File Number'
      and  pet.element_type_id         = piv.element_type_id
      and  pet.element_type_id         = pel.element_type_id
      and  pel.element_link_id         = pee.element_link_id
      and  pee.element_entry_id        = pev.element_entry_id
      and  piv.input_value_id          = pev.input_value_id
      and  pee.assignment_id           = c_assignment_id
      and  c_date_earned between pel.effective_start_date and pel.effective_end_date
      and  c_date_earned between pev.effective_start_date and pev.effective_end_date
      and  c_date_earned between pet.effective_start_date and pet.effective_end_date
      and  c_date_earned between  pee.effective_start_date and pee.effective_end_date
      and  c_date_earned between  piv.effective_start_date and piv.effective_end_date;


 /*Bug3019374 - Cursor broken up into 2 cursor -> cursor  employee_details
 and cursor tfn_number*/
 /* Bug 4299506 - Join in subquery modified for Archiving details of employees
    terminated in previous years */
 /* Bug 7242551 - Modified sub query to fetch date earned based on max(action_sequence)
                  and not max(payroll_action_id)
 */
 /* Bug 8315198 - Modified cursor for fetching the termination type of the employee */
  cursor   employee_details
      is
    select  distinct
          pap.first_name                             first_name
         ,substr(pap.middle_names, 1,
          decode(instr(pap.middle_names,' '),
          0, 60, instr(pap.middle_names,'',1)-1))    middle_name
         ,pap.last_name                              surname
         ,pad.address_line1                          address_1
         ,pad.address_line2                          address_2
         ,pad.address_line3                          address_3
         ,pad.town_or_city                           suburb
         ,pad.region_1                               state
         ,pad.postal_code                            postcode
         ,fta.territory_short_name                   country
         ,pad.style                                  address_style      -- Bug 5364017
         ,pad.country                                address_country    -- Bug 5364017
         ,to_char(pps.date_start,'DDMMYYYY')         start_date
         ,nvl(to_char(pps.actual_termination_date,
                     'DDMMYYYY'),'31124712')        termination_date
         ,pps.final_process_date                    final_process_date -- Bug3263659
         ,to_char(pap.date_of_birth,'DDMMYYYY')     dob
         ,hlc.location_code                         asgmnt_loc
         ,pap.employee_number                       emp_no
         ,decode(pps.actual_termination_date,null,'C',decode(sign(pps.actual_termination_date - p_year_end),1,'C','T')) emp_type         /* Bug #1973978 */
         ,pad.date_from
         ,ppa1.date_earned
         ,ppa1.effective_date               -- Bug3263659
         ,pps.actual_termination_date
         ,to_char(paaf.effective_start_date,'DDMMYYYY')
         ,to_char(paa.effective_end_date,'DDMMYYYY')                               -- Bug 2610141
         ,pps.pds_information1                      termination_type      --Bug 8315198
   from   hr_organization_information  hoi,
          hr_organization_units        hou,
          hr_soft_coding_keyflex       hsc,
          hr_locations                 hlc, /* Bug No : 2263587 */
          per_all_assignments_f        paa,
          per_all_assignments_f        paaf, /* Bug : 2610141 */
          per_all_people_f             pap,
          per_addresses                pad,
          fnd_territories_tl           fta,
          per_periods_of_service       pps,
          pay_payroll_actions          ppa,
          pay_assignment_actions       pac,
          pay_payroll_actions          ppa1, /* Bug# 2448441 */
          pay_assignment_actions       pac1  /* Bug# 2448441 */
   where  hou.business_group_id       = p_business_group_id
     and  hou.organization_id         = p_registered_employer
     and  ppa.action_type             = 'X'
     and  hou.organization_id         = hoi.organization_id
     and  hoi.org_information_context = 'AU_LEGAL_EMPLOYER'
     and  hou.business_group_id       = pap.business_group_id
     and  hsc.soft_coding_keyflex_id  = paa.soft_coding_keyflex_id
     and  paa.location_id             = hlc.location_id(+)
     and  to_char(hou.organization_id)= hsc.segment1
     and  pap.person_id               = paa.person_id
     and  pap.person_id               = pad.person_id(+)
     and  pad.primary_flag(+)         = 'Y' /*Added for bug 2774577*/
     and  fta.territory_code(+)       = pad.country
     and  fta.language(+)             = userenv('LANG')
     and  pap.person_id               = pps.person_id
     and pps.period_of_service_id     = paa.period_of_service_id /* Bug#2786146 */
     and  ppa.payroll_action_id       = pac.payroll_action_id
     and  ppa.payroll_action_id       = p_payroll_action_id
     and  paa.assignment_id           = pac.assignment_id
     and  paa.assignment_id           = p_assignment_id
     and  paaf.assignment_id          = paa.assignment_id -- Bug 2610141
     /* Added for Bug# 2448441 */
     and  paa.assignment_id           = pac1.assignment_id
     and  ppa1.payroll_action_id      = pac1.payroll_action_id
     and  pac1.assignment_action_id   = (select to_number(substr(max(lpad(paa2.action_sequence,15,'0')||paa2.assignment_action_id),16))         /*Bug 7242551 */
                                            from pay_payroll_actions ppa2,
                                                 pay_assignment_actions paa2
                                            where ppa2.action_type in ('R','Q','B','I') --Bug 2574186
                                            and ppa2.payroll_action_id = paa2.payroll_action_id
                                            and paa2.tax_unit_id  = p_registered_employer -- Bug 2610141
                                            and paa2.assignment_id = paa.assignment_id
                                            and ppa2.effective_date between add_months(p_year_start,-3) and p_year_end )/*Bug3048962 */
     /* End of Bug# 2448441 */
      and  (paa.effective_start_date, paaf.effective_start_date)
                                       = (select max(a.effective_Start_date),min(a.effective_start_date) -- Bug 2610141
                                          from per_all_assignments_f a
                                              , hr_soft_coding_keyflex hsc1                  --Added for bug 4177679
                                          where a.assignment_id = paa.assignment_id
                                          and  hsc1.soft_coding_keyflex_id  = a.soft_coding_keyflex_id    --Added for bug 4177679
                                          and  hsc1.segment1= p_registered_employer       --Added for bug 4177679
                                          and nvl(pps.actual_termination_date,p_year_end)
                                                between a.effective_Start_date  and pap.effective_end_date  /*2689175*/
                                          and a.effective_end_date >= least(nvl(pps.actual_termination_date,p_year_start),p_year_start))--Added for bug 4177679,4299506
     and  pap.effective_start_date = (select max(effective_Start_date)
                                      from per_all_people_f p
                                      where p.person_id = pap.person_id
                                      and nvl(pps.actual_termination_date,p_year_end) between p.effective_Start_date and p.effective_end_date)
     ORDER BY pad.date_from DESC;/*Bug2977533*/


/*Bug# 4653934 - Introduced a new cursor to get the payroll name for the employee. This has been done to take care of cases
                    where assignment has payroll attached to it for few months but is not attached at the end of year*/
 CURSOR c_get_payroll_name
 IS
 SELECT pay.payroll_name
 FROM per_all_assignments_f        paaf,
      pay_payrolls_f               pay
 WHERE paaf.assignment_id = p_assignment_id
 and   paaf.effective_end_date = (select max(effective_end_date)
                               From  per_assignments_f iipaf
                                     WHERE iipaf.assignment_id  = p_assignment_id
                                     and iipaf.effective_end_date >= p_fbt_year_start
                                     and iipaf.effective_start_date <= p_year_end
                                 AND iipaf.payroll_id IS NOT NULL)
 AND  pay.payroll_id = paaf.payroll_id
 AND  paaf.effective_end_date BETWEEN pay.effective_start_date AND pay.effective_end_date;


Begin

    IF g_debug THEN
       hr_utility.set_location('Start of archive employee details ..',0);
     END if;
   open employee_details ;
   fetch employee_details into
      l_first_name
     ,l_middle_name
     ,l_surname
     ,l_address_1
     ,l_address_2
     ,l_address_3
     ,l_suburb
     ,l_state
     ,l_postcode
     ,l_country
     ,l_address_style      -- Bug 5364017
     ,l_add_country        -- Bug 5364017
     ,l_start_date
     ,l_termination_date
     ,l_final_process_date -- Bug3263659
     ,l_dob
     ,l_asgmnt_loc
     ,l_emp_no
--     ,l_payroll
     ,l_emp_type
     ,l_address_date_from
     ,l_date_earned
     ,l_effective_date  -- Bug3263659
     ,l_actual_termination_date
     ,l_le_start_date
     ,l_le_end_date -- Bug 2610141
     ,l_termination_type; --Bug 8315198


    OPEN c_get_payroll_name;
    FETCH c_get_payroll_name INTO l_payroll;
    CLOSE c_get_payroll_name;

    IF g_debug THEN
        hr_utility.set_location('In Archive_employee_details    ',1000);
        hr_utility.set_location('l_first_name                   '||l_first_name,1000);
        hr_utility.set_location('l_surname                      '||l_surname,1000);
        hr_utility.set_location('l_address_1                    '||l_address_1,1000);
        hr_utility.set_location('l_address_style                '||l_address_style,1000);
        hr_utility.set_location('l_start_date                   '||l_start_date,1000);
        hr_utility.set_location('l_termination_date             '||l_termination_date,1000);
        hr_utility.set_location('l_final_process_date           '||l_final_process_date,1000);
        hr_utility.set_location('l_emp_no                       '||l_emp_no,1000);
        hr_utility.set_location('l_emp_type                     '||l_emp_type,1000);
        hr_utility.set_location('l_date_earned                  '||l_date_earned,1000);
        hr_utility.set_location('l_effective_date               '||l_effective_date,1000);
        hr_utility.set_location('l_actual_termination_date      '||l_actual_termination_date,1000);
        hr_utility.set_location('l_le_start_date                '||l_le_start_date,1000);
        hr_utility.set_location('l_le_end_date                  '||l_le_end_date,1000);
        hr_utility.set_location('l_termination_type             '||l_termination_type,1000); --Bug 8315198
    END if;

  if employee_details%found then
    close employee_details;

   /* - If the Employee is terminated in the current financial year then get the tax file number
        at the time of termination.

        Else use the date_earned of the last payroll action  to get the tax file number  Bug3019374

  */

    /* Bug3263659  - If termination date is in the last year then use final process date , otherwise current logic */
    /* Bug 7234263 - Added Least for end dated assignments where there may be no assignment record on Act Term Date */

    if l_emp_type = 'T' then
        if l_actual_termination_date < p_year_start AND l_effective_date >= p_year_start
        then
        l_actual_termination_date :=nvl(l_final_process_date,l_effective_date);/* Bug 3098353 To set the End Date as Payment Date if Final_process is null */
        l_termination_date:=  to_char(l_actual_termination_date,'DDMMYYYY');
        end if;
        l_date_earned:=least(l_actual_termination_date,l_date_earned);  /* Bug 7234263*/
    end if;
     /* End of Changes for Bug3263659 */

     /*Begin 8315198 - Removed the code for setting up the contexts,as the terminatin type is fetched from employee_details cursor.
                       The value of termination type is assigned to the package variable */
   g_termination_type := l_termination_type;

   IF g_debug THEN
         hr_utility.set_location('g_termination_type                 '||g_termination_type,1000);
   END IF;

      /*End 8315198 */
   l_le_etp_start_date := l_le_start_date; /*Bug 5075662 - Variable introduced to store the actual le start date which
                                             will be archived as X_ETP_EMPLOYEE_START_DATE if ETP service date is null*/
----------------------------2610141--------------------------------
   IF to_date(l_le_start_date,'DDMMYYYY') < p_year_start then
    l_le_start_date := to_char(p_year_start,'DDMMYYYY');
   ELSE
    l_le_start_date := l_le_start_date;
   END IF;

   IF to_date(l_le_end_date,'DDMMYYYY') > p_year_end THEN /*Bug 4063321*/
    l_le_end_date := to_char(p_year_end,'DDMMYYYY');
   ELSE
    l_le_end_date := l_le_end_date;
   END IF;
----------------------------------------------------------------

    IF g_debug THEN
        hr_utility.set_location('In Archive_employee_details, after adjsutments ',1000);
        hr_utility.set_location('l_termination_date             '||l_termination_date,1000);
        hr_utility.set_location('l_final_process_date           '||l_final_process_date,1000);
        hr_utility.set_location('l_date_earned                  '||l_date_earned,1000);
        hr_utility.set_location('l_effective_date               '||l_effective_date,1000);
        hr_utility.set_location('l_actual_termination_date      '||l_actual_termination_date,1000);
        hr_utility.set_location('l_le_start_date                '||l_le_start_date,1000);
        hr_utility.set_location('l_le_end_date                  '||l_le_end_date,1000);
    END if;


  open tfn_number(p_assignment_id,l_date_earned); /*Bug3019374*/
  fetch tfn_number into l_tfn_no;

  IF g_debug THEN
        hr_utility.set_location('tfn_number                     '||l_tfn_no,1000);
  END IF;


  If tfn_number%FOUND then   /*If Tax File details found then archive employe details*/
  close tfn_number;

    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYEE_TAX_FILE_NUMBER',1);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_TAX_FILE_NUMBER',
                                   l_tfn_no);

    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYEE_FIRST_NAME',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_FIRST_NAME',
                                    l_first_name);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYEE_MIDDLE_NAME',4);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_MIDDLE_NAME',
                                   l_middle_name);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYEE_SURNAME',5);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_SURNAME',
                                    l_surname);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYEE_ADDRESS_1',7);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_ADDRESS_1',
                                   l_address_1);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYEE_ADDRESS_2',8);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_ADDRESS_2',
                                   l_address_2);
    IF g_debug THEN
       hr_utility.set_location('Creating archive Item  X_EMPLOYEE_ADDRESS_3',8);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_ADDRESS_3',
                                   l_address_3);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYEE_SUBURB',9);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_SUBURB',
                                   l_suburb);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_EMPLOYEE_STATE',10);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_STATE',
                                    l_state);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item X_EMPLOYEE_POSTCODE',11);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_POSTCODE',
                                   l_postcode);

    /* Bug 5364017 - Check for Generic Address
       IF Address Style is Generic - then get the country name as entered in Address form
    */
        IF l_address_style = 'GENERIC'
        THEN
              l_country := l_add_country;
        END IF;

    IF g_debug THEN
        hr_utility.set_location('Creating archive Item X_EMPLOYEE_COUNTRY',12);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_COUNTRY',
                                   l_country);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item X_EMPLOYEE_START_DATE',12);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_START_DATE',
                                   l_start_date);

    /* 3098353 Employee End Date Archived in main Archive_Code */

    IF g_debug THEN
        hr_utility.set_location('Creating archive Item X_EMPLOYEE_DATE_OF_BIRTH',12);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_DATE_OF_BIRTH',
                                   l_dob);
   /* bug 3098353 */
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item X_EMPLOYEE_FINAL_PROCESS_DATE',12);
    END if;
    l_fpd_archive := to_char(l_final_process_date,'DDMMYYYY');
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_FINAL_PROCESS_DATE',
                                   l_fpd_archive);
    ---------------------------------------------------------------
    -- archive sort details
    ---------------------------------------------------------------
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item X_SORT_EMPLOYEE_NUMBER',12);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SORT_EMPLOYEE_NUMBER',
                                   l_emp_no );
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item X_SORT_ASSIGNMENT_LOCATION',12);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SORT_ASSIGNMENT_LOCATION',
                                   l_asgmnt_loc );
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item X_SORT_PAYROLL',12);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SORT_PAYROLL',
                                   l_payroll );
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item X_SORT_EMPLOYEE_TYPE',12);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SORT_EMPLOYEE_TYPE',
                                   l_emp_type );
    IF g_debug THEN
         hr_utility.set_location('Creating archive Item  X_SORT_EMPLOYEE_LAST_NAME',5);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SORT_EMPLOYEE_LAST_NAME',
                                    l_surname);


----------------------------2610141--------------------------------
    IF g_debug THEN
         hr_utility.set_location('Creating archive Item  X_EMPLOYEE_LE_START_DATE',5);
    END if;
    l_le_etp_service_date := l_le_etp_start_date; /* Bug 4177679, Bug# 5075662 */

  /*Bug# 4363057 - If condition introduced so that the X_EMPLOYEE_LE_START_DATE gets archived only once.
                     If for submitted legal employer employee is not active in the financial year then
                     X_EMPLOYEE_LE_START_DATE is archived in the archive_code*/

   IF p_end_date_flag <> 'B' THEN
      create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_LE_START_DATE',
                                    l_le_start_date);
    END IF;
   /* Bug 4177679 ETP start date to be archived */
 if g_le_etp_flag ='N' then
        create_extract_archive_details(p_assignment_action_id,
                                       'X_ETP_EMPLOYEE_START_DATE',
                                        l_le_etp_service_date);
   IF g_debug THEN
        hr_utility.set_location('End of archive_prepost_details',18);
   END if;
     g_le_etp_flag := 'Y';
  end if ;


    IF g_debug THEN
         hr_utility.set_location('Creating archive Item  X_EMPLOYEE_LE_END_DATE',5);
    END if;

    IF p_end_date_flag = 'N' THEN
    create_extract_archive_details(p_assignment_action_id,
                                   'X_EMPLOYEE_LE_END_DATE',
                                l_le_end_date);
    END IF;
----------------------------2610141--------------------------------
    end if;

  else
   close  employee_details;
    raise e_employee_nf;
  end if;
exception
  when e_employee_nf then
    IF g_debug THEN
        hr_utility.set_location('No employee Details found for the assigment id  ',20);
    END if;
  when others then
    IF g_debug THEN
        hr_utility.set_location('Error in archive_employee_details ',99);
    END if;
    raise;
End archive_employee_details;


  ------------------------------------------------------------------------+
  -- procedure to archive supplier details
  -- calls create_extract_archive_Details
  ------------------------------------------------------------------------+
Procedure archive_supplier_details
            (p_business_group_id       in hr_organization_units.business_group_id%type,
         p_registered_employer     in hr_organization_units.organization_id%type,
         p_payroll_action_id       in pay_payroll_actions.payroll_action_id%type,
         p_assignment_Action_id    in pay_assignment_actions.assignment_action_id%type,
         p_assignment_id           in pay_assignment_actions.assignment_id%type,
         p_year_start              in pay_payroll_actions.effective_date%type,
         p_year_end            in pay_payroll_Actions.effective_date%type) is


  l_report_end_date             varchar2(20);
  l_supplier_number     hr_organization_information.org_information1%type;
  l_supplier_name               hr_organization_information.org_information3%type;
  l_supplier_abn                hr_organization_information.org_information5%type;
  l_supplier_contact_name       per_all_people_f.full_name%type;
  l_supplier_contact_phone      per_addresses.telephone_number_1%type;
  l_supplier_address_1          hr_locations.address_line_1%type;
  l_supplier_address_2          hr_locations.address_line_2%type;
  l_supplier_address_3          hr_locations.address_line_3%type;
  l_supplier_suburb             hr_locations.town_or_city%type;
  l_supplier_state              hr_locations.region_1%type;
  l_supplier_postcode           hr_locations.postal_code%type;
  l_supplier_country            fnd_territories_tl.territory_short_name%type;

  ------------------------------------------------------------------------------+
  -- cursor to get supplier details
  ------------------------------------------------------------------------------+

   cursor supplier_details
       is
      select  '3006' ||to_char(p_year_end,'YYYY')      report_end_date
              ,hoi.org_information1                   supplier_number
              ,hoi.org_information3                   supplier_name
              ,hoi.org_information12                  supplier_abn
              ,pap.first_name || ' ' || pap.last_name supplier_contact_name
              ,hoi.org_information14                  supplier_contact_phone
              ,hrl.address_line_1                     supplier_address_1
              ,hrl.address_line_2                     supplier_address_2
              ,hrl.address_line_3                     supplier_address_3
              ,hrl.town_or_city                       supplier_suburb
              ,hrl.region_1                           supplier_state
              ,hrl.postal_code                        supplier_postcode
              ,ftl.territory_short_name               supplier_country
              ,pap.email_address                      email_address
       from    hr_organization_information  hoi
              ,hr_organization_units        hou
              ,hr_locations                 hrl
              ,fnd_territories_tl           ftl
              ,per_all_people_f             pap
       where  hou.business_group_id       = p_business_group_id
         and  hou.organization_id         = p_registered_employer
         and  hou.organization_id         = hoi.organization_id
         and  hoi.org_information_context = 'AU_LEGAL_EMPLOYER'
         and  hrl.location_id             = hou.location_id
         and  ftl.territory_code          = hrl.country
         and  ftl.language                = userenv('LANG')
         and  hoi.org_information7       = pap.person_id
         and  pap.effective_start_date    = (select max(effective_start_date)
                                             from  per_all_people_f p
                                            where pap.person_id=p.person_id);

Begin
    IF g_debug THEN
        hr_utility.set_location('Archiving Supplier Details ',1);
        hr_utility.set_location('Assignments action id is  '||p_assignment_action_id,2);
    END if;


  for sd in supplier_details
  loop

    IF g_debug THEN
        hr_utility.set_location('Creating Archive Item  X_REPORT_END_DATE',3);
    END if;
    create_extract_archive_details (p_assignment_action_id
                                    ,'X_REPORT_END_DATE'
                                    ,sd.report_end_date);

    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_SUPPLIER_NUMBER',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_NUMBER',
                                   sd.supplier_number);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_SUPPLIER_NAME',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_NAME',
                                    sd.supplier_name);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_SUPPLIER_ABN',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_ABN',
                                    sd.supplier_abn);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_SUPPLIER_CONTACT_NAME',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_CONTACT_NAME',
                                   sd.supplier_contact_name);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_SUPPLIER_CONTACT_PHONE',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_CONTACT_TELEPHONE',
                                    sd.supplier_contacT_phone);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_SUPPLIER_EMAIL',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_EMAIL',
                                   sd.email_address);
    IF g_debug THEN
       hr_utility.set_location('Creating archive Item  X_SUPPLIER_ADDRESS_1',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_ADDRESS_1',
                                   sd.supplier_address_1);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_SUPPLIER_ADDRESS_2',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_ADDRESS_2',
                                   sd.supplier_address_2);

    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_SUPPLIER_ADDRESS_3',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_ADDRESS_3',
                                   sd.supplier_address_3);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_SUPPLIER_SUBURB',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_SUBURB',
                                   sd.supplier_suburb);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_SUPPLIER_STATE',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_STATE',
                                   sd.supplier_state);
    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_SUPPLIER_POSTCODE',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_POSTCODE',
                                    sd.supplier_postcode);

    IF g_debug THEN
        hr_utility.set_location('Creating archive Item  X_SUPPLIER_COUNTRY',3);
    END if;
    create_extract_archive_details(p_assignment_action_id,
                                   'X_SUPPLIER_COUNTRY',
                                   sd.supplier_country);


  end loop;
    IF g_debug THEN
        hr_utility.set_location('Archived all the supplier details',200);
    END if;
exception
  when others then
    IF g_debug THEN
        hr_utility.set_location('Error in archiving supplier details ',10);
    END if;
    raise;

End archive_supplier_details;

/*-------------------------------------------------------------------------------
Bug 6192381 Procedure to adjust old etp deduction and old Invalidity Payments

-------------------------------------------------------------------------------*/
procedure adjust_old_etp_values
(p_trans_etp_flag               in Varchar2
,p_part_of_prev_etp_flag        in Varchar2
) is

  l_procedure           constant varchar2(80) := g_package || '.adjust_old_etp_values';

  l_old_etp_ded             NUMBER;
  l_old_inv_pay             NUMBER;

Begin
  g_debug :=  hr_utility.debug_enabled;

  if g_debug then
     hr_utility.set_location(l_procedure, 1);
      hr_utility.trace('In p_trans_etp_flag           '||p_trans_etp_flag);
      hr_utility.trace('In p_part_of_prev_etp_flag    '||p_part_of_prev_etp_flag);
      hr_utility.trace('------------------------------------------------');
      hr_utility.trace('Lump Sum C Deductions                                  ===>' || p_result_table(7).balance_value);
      hr_utility.trace('Invalidity Payments                                    ===>' || p_result_table(14).balance_value);
      hr_utility.trace('ETP Deductions Transitional Not Part of Prev Term      ===>' || p_result_table(18).balance_value);
      hr_utility.trace('ETP Deductions Transitional Part of Prev Term          ===>' || p_result_table(19).balance_value);
      hr_utility.trace('ETP Deductions Life Benefit Not Part of Prev Term      ===>' || p_result_table(20).balance_value);
      hr_utility.trace('ETP Deductions Life Benefit Part of Prev Term          ===>' || p_result_table(21).balance_value);
      hr_utility.trace('Invalidity Payments Life Benefit Not Part of Prev Term  ===>' || p_result_table(22).balance_value);
      hr_utility.trace('Invalidity Payments Life Benefit Part of Prev Term      ===>' || p_result_table(23).balance_value);
      hr_utility.trace('Invalidity Payments Transitional Not Part of Prev Term  ===>' || p_result_table(24).balance_value);
      hr_utility.trace('Invalidity Payments Transitional Part of Prev Term      ===>' || p_result_table(25).balance_value);

  end if;

      l_old_etp_ded := 0;
      l_old_inv_pay := 0;

/* Bug 6192381  For Termination Payments before Multiple ETP Payment Enhancement the new balances for each combination
does not exist , therefore to find out the values difference of Old balance which has total values and sum of new balances
is taken to archive the old values . this is done for ETP Deduction and Invalidity Payments

  l_old_etp_ded  :=  Lump Sum C Deductions - ( ETP Deductions Transitional Not Part of Prev Term  +
                                               ETP Deductions Transitional Part of Prev Term      +
                                               ETP Deductions Life Benefit Not Part of Prev Term  +
                                               ETP Deductions Life Benefit Part of Prev Term )

  l_old_inv_pay  :=  Invalidity Payments  -  ( Invalidity Payments Life Benefit Not Part of Prev ETP  +
                                               Invalidity Payments Life Benefit Part of Prev ETP      +
                                               Invalidity Payments Transitional Not Part of Prev ETP  +
                                               Invalidity Payments Transitional Part of Prev ETP )

 If these values are greater then 0 then based on Inputs Transitional ETP and Part of Previously Paid ETP , these values are
 added to corresponding Balances .
*/

      l_old_etp_ded :=  p_result_table(7).balance_value - (p_result_table(18).balance_value + p_result_table(19).balance_value +
                                                            p_result_table(20).balance_value + p_result_table(21).balance_value );

      l_old_inv_pay :=  p_result_table(14).balance_value - (p_result_table(22).balance_value + p_result_table(23).balance_value +
                                                            p_result_table(24).balance_value + p_result_table(25).balance_value );

  if g_debug then
      hr_utility.trace('l_old_etp_ded   ===>' || l_old_etp_ded);
      hr_utility.trace('l_old_inv_pay   ===>' || l_old_inv_pay);
  end if;


      if ( l_old_etp_ded > 0 ) then
               if (p_trans_etp_flag = 'Y' and p_part_of_prev_etp_flag ='N') then
                    p_result_table(18).balance_value := p_result_table(18).balance_value + l_old_etp_ded ;
               end if;

               if (p_trans_etp_flag = 'Y' and p_part_of_prev_etp_flag ='Y') then
                    p_result_table(19).balance_value := p_result_table(19).balance_value + l_old_etp_ded ;
               end if;

               if (p_trans_etp_flag = 'N' and p_part_of_prev_etp_flag ='N') then
                    p_result_table(20).balance_value := p_result_table(20).balance_value + l_old_etp_ded ;
               end if;

               if (p_trans_etp_flag = 'N' and p_part_of_prev_etp_flag ='Y') then
                    p_result_table(21).balance_value := p_result_table(21).balance_value + l_old_etp_ded ;
               end if;

      end if;

      if ( l_old_inv_pay > 0 ) then
               if (p_trans_etp_flag = 'N' and p_part_of_prev_etp_flag ='N') then
                    p_result_table(22).balance_value := p_result_table(22).balance_value + l_old_inv_pay ;
               end if;

               if (p_trans_etp_flag = 'N' and p_part_of_prev_etp_flag ='Y') then
                    p_result_table(23).balance_value := p_result_table(23).balance_value + l_old_inv_pay ;
               end if;

               if (p_trans_etp_flag = 'Y' and p_part_of_prev_etp_flag ='N') then
                    p_result_table(24).balance_value := p_result_table(24).balance_value + l_old_inv_pay ;
               end if;

               if (p_trans_etp_flag = 'Y' and p_part_of_prev_etp_flag ='Y') then
                    p_result_table(25).balance_value := p_result_table(25).balance_value + l_old_inv_pay ;
               end if;

      end if;

exception
  when others then
    IF g_debug THEN
        hr_utility.set_location('Error in adjust_old_etp_values ',10);
    END if;

End adjust_old_etp_values;

 --------------------------------------------------------------------+
  -- This procedure is actually used to archive data . It
  -- internally calls private procedures to archive balances ,
  -- employee details, employer details and supplier details .
  -- Calls the following procedures
  -- 1. archive_balance_details
  -- 2. archive_etp_details
  -- 3. archive_prepost_details
  -- 4. archive_employer_details
  -- 5. archive_supplier_details
  -- 6. archive_employee_details
  --------------------------------------------------------------------+
procedure archive_code
(p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type
,p_effective_date        in date
) is
  --
  l_procedure           constant varchar2(80) := g_package || '.archive_code';
  l_assignment_id               pay_assignment_actions.assignment_id%type;
  l_business_group_id           pay_payroll_actions.business_group_id%type ;
  l_registered_employer         hr_organization_units.organization_id%type;
  l_current_le                  hr_organization_units.organization_id%type;         --4363057
  l_payroll_action_id           pay_payroll_actions.payroll_action_id%type ;
  l_year_start                  pay_payroll_Actions.effective_date%type;
  l_year_end                    pay_payroll_actions.effective_date%type;
  l_employee_type               per_all_people_f.current_Employee_Flag%type;
  l_current_employee_flag       per_all_people_f.current_employee_flag%type  :='Y';
  l_actual_termination_date     per_periods_of_service.actual_termination_date%TYPE;
  l_date_start                  per_periods_of_service.date_start%TYPE;
  l_asg_start                   pay_payroll_actions.effective_date%type;
  l_asg_end                     pay_payroll_actions.effective_date%type;
  l_effective_date              pay_payroll_actions.effective_date%type;
  l_death_benefit_type          varchar2(100);
  l_assignment_action_id        pay_assignment_actions.assignment_action_id%type;
  l_max_assignment_action_id    pay_assignment_actions.assignment_action_id%type;
  l_bbr_assignment_action_id    pay_assignment_actions.assignment_action_id%type;
  l_fbt_assignment_action_id    pay_assignment_actions.assignment_action_id%type;       --2610141
  lump_sum_c_found              boolean := false;
  l_final_process_date          date;                                                   --263659
  l_term_date                   varchar2(10);                                           --3263659
  l_fetched_termination_date    per_periods_of_service.actual_termination_date%TYPE;    --3263659
  l_reporting_flag              varchar2(5) := 'YES';                   --3098353
  l_bal_value                   varchar2(20);                       --3098353
  l_alw_bal_exist               varchar2(20);                       --3098353
  l_lst_yr_term                 varchar2(10);                       --3661230
  v_lst_year_start              date ;                          --3661230
  l_fbt_year_start              date;
  l_net_balance                 number := 0;                        --3098353
  l_fbt_balance                 number := 0;                        --3098353
  l_dummy                       number;                             --4363057
  l_pay_start                   varchar2(10);                       --4363057
  l_pay_end                     varchar2(10);                       --4363057
  l_curr_term_0_bal_flag        varchar2(5) :='NO';                     --3937976
  l_le_end_date_flag        varchar2(5) := 'N';                     --2610141
  l_lump_sum_a_pymt_type        char(1);                            /*Bug#8315198*/
  l_lump_sum_a_value            number := 0;                        /*Bug#8315198*/
  --
  -------------------------------------------------+
  -- Cursor to get details for assignment action id
  -------------------------------------------------+
  --
  cursor c_action(c_assignment_action_id number) is
  select pay_core_utils.get_parameter('BUSINESS_GROUP_ID',ppa.legislative_parameters)
  ,      pay_core_utils.get_parameter('REGISTERED_EMPLOYER',ppa.legislative_parameters)
  ,      pay_core_utils.get_parameter('EMPLOYEE_TYPE',ppa.legislative_parameters)
  ,      ppa.payroll_action_id
  ,      paa.assignment_id
  ,      to_date('01-07-'|| substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa.legislative_parameters),1,4),'DD-MM-YYYY')
  ,      to_date('30-06-'|| substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',ppa.legislative_parameters),6,4),'DD-MM-YYYY')
  ,      pay_core_utils.get_parameter('LST_YR_TERM',ppa.legislative_parameters)                   /*Bug3661230*/
  from   pay_assignment_actions     paa
  ,      pay_payroll_actions        ppa
  where  paa.assignment_action_id   = c_assignment_action_id
  and    ppa.payroll_action_id      = paa.payroll_action_id ;
  --
  -------------------------------------------------+
  -- Cursor to get current employee flag
  -- Bug 2856638 : added parameter c_business_group_id
  -------------------------------------------------+
  --
  cursor etp_code
  (c_assignment_id     in pay_assignment_actions.assignment_id%type
  ,c_lst_year_start    in pay_payroll_actions.effective_date%type                   --3263659
  ,c_year_start        in pay_payroll_actions.effective_date%type
  ,c_year_end          in pay_payroll_actions.effective_date%type
  ,c_def_bal_id        in pay_defined_balances.defined_balance_id%type
  ,c_business_group_id in pay_payroll_actions.business_group_id%type
  ) is
  select distinct nvl(current_employee_flag,'N') current_employee_flag,
         actual_termination_date,
         date_start,
         pps.pds_information2,
         to_number(substr(max(lpad(ppa.action_sequence,15,'0')||ppa.assignment_action_id),16)),         --3755305
         pps.final_process_date                    final_process_date                       --3263659
  from   per_all_people_f          p,
         per_all_assignments_f     a,
         per_periods_of_service    pps,
         pay_all_payrolls_f        papf,                                    --4281290
         pay_payroll_actions       pa,
         pay_assignment_actions ppa
  where  a.person_id            = p.person_id
  and    pps.person_id          = p.person_id
  and    a.assignment_id        = ppa.assignment_id
  and    papf.business_group_id     = p.business_group_id                       --4281290
  and    pa.payroll_id          = papf.payroll_id                           --4281290
  and    pa.effective_date between papf.effective_start_date and papf.effective_end_date        --4281290
  and    pa.payroll_Action_id       = ppa.payroll_Action_id
  and    ppa.tax_unit_id            = l_registered_employer                     --2610141
  and    (
            (pps.actual_termination_date between c_lst_year_start and c_year_end
             and pa.effective_date       between c_year_start and c_year_end                    --3263659
             )
            or
            (pps.actual_termination_date between l_fbt_year_start
                                            and  to_date('30-06-'||to_char(c_year_start,'YYYY'),'DD-MM-YYYY')
             and pa.effective_date       between to_date('01-04-'||to_char(c_year_start,'YYYY'),'DD-MM-YYYY')
                                            and  to_date('30-06-'||to_char(c_year_start,'YYYY'),'DD-MM-YYYY')
            )
         )
  and    a.assignment_id = c_assignment_id
  and    p.effective_start_date = (select max(pp.effective_start_date)
                                   from   per_all_people_f pp
                                   where  p.person_id = pp.person_id
                                   and    p.business_group_id = c_business_group_id
                                   ) -- Bug 2856638
  and    a.effective_start_date = (select  max(aa.effective_start_date)
                                   from  per_all_assignments_f aa
                                   where  aa.assignment_id = c_assignment_id
                                   )                        --4281290
  and    pa.action_type in ('R','Q','I','B','V')                --2646912, 4063321
  and    a.period_of_service_id = pps.period_of_service_id          --3586388
  group by nvl(current_employee_flag,'N')                           --3019374
  ,        actual_termination_date
  ,        date_start
  ,        pps.pds_information2
  ,        pps.final_process_date;                              --3263659
  --
  --3263659
  cursor cr_effective_date (c_assignment_action_id pay_assignment_actions.assignment_action_id%type) IS
  select ppa.effective_date
  from   pay_payroll_actions      ppa,
         pay_assignment_actions   paa
  where  paa.assignment_action_id = c_assignment_action_id
  and    ppa.payroll_action_id    = paa.payroll_action_id;
  --
  -------------------------------------------------+
  -- Cursor to check if 'Lump Sum C Payments' Balance
  -- exists. This is used to decide if archive_etp_Details
  -- is to be called or not(Bug  - 2581436 )
  -------------------------------------------------+
  cursor balance_exists is
  select pdb.defined_balance_id
  from   pay_balance_types            pbt,
         pay_defined_balances         pdb,
         pay_balance_dimensions       pbd
  where  pbt.balance_name             ='Lump Sum C Payments'
  and    pbt.balance_type_id          = pdb.balance_type_id
  and    pdb.balance_dimension_id     = pbd.balance_dimension_id    --2501105
  and    pbd.legislation_code         = g_legislation_code
  and    pdb.legislation_code         = g_legislation_code
  and    pbd.dimension_name           = '_ASG_LE_YTD';          --2610141
  --
  ----------------------------------------------------------------------------------------+
  -- Cursor to get maximum assignment_action_id to use in BBR Call (Bug 4738470)
  ----------------------------------------------------------------------------------------+
  --
  cursor c_max_asg_action_id
  (c_assignment_id      per_all_assignments_f.assignment_id%TYPE
  ,c_business_group_id  hr_all_organization_units.organization_id%TYPE
  ,c_tax_unit_id        hr_all_organization_units.organization_id%TYPE
  ,c_year_start         date
  ,c_year_end           date
  ) is
  select to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) assignment_action_id,
         max(paa.action_sequence)   action_sequence
  from   pay_assignment_actions         paa,
         pay_payroll_actions            ppa,
         per_assignments_f              paf
  where  paa.assignment_id              = paf.assignment_id
  and    paf.assignment_id          = c_assignment_id
  and    ppa.payroll_action_id      = paa.payroll_action_id
  and    ppa.effective_date         between c_year_start and c_year_end
  and    ppa.payroll_id             =  paf.payroll_id
  and    ppa.action_type            in ('R', 'Q', 'I', 'V', 'B')
  and    ppa.effective_date         between paf.effective_start_date and paf.effective_end_date
  and    paa.action_status      = 'C'
  and    paa.tax_unit_id        = c_tax_unit_id;

/*Bug# 4363057 - Three new cursors introduced for the Retro enhancement
   a)   csr_check_eff_le - This cursor will check whether the employee
                         is active in the current financial year for the submitted legal employer
   b)   csr_get_dates - This cursor will get the maximum and minimum payment dates for the employee
                      in the current financial year. This cursor should execute only when the
                      employee is not active in the current financial year for the submitted legal employer.
   c)   csr_get_end_le - This cursor will get the effective legal employer on the last payment date of the employee
                       and it will be passed as an argument to archive_employee_details procedure for archiving
                       employee details. This cursor should also execute only when the employee is not active in the current financial year for the submitted legal employer.
*/
  cursor csr_check_eff_le
  (c_assignment_id per_assignments_f.assignment_id%type
  ,c_legal_employer hr_organization_units.organization_id%type
  ,c_year_start pay_payroll_actions.effective_date%type
  ,c_year_end pay_payroll_actions.effective_date%type
  ) is
  select paaf.assignment_id
  from   per_assignments_f      paaf,
         hr_soft_coding_keyflex     hsck
  where  paaf.assignment_id         = c_assignment_id
  and    paaf.soft_coding_keyflex_id    = hsck.soft_coding_keyflex_id
  and    paaf.effective_start_date  <= c_year_end
  and    paaf.effective_end_date    >= c_year_start
  and    hsck.segment1          = c_legal_employer;
  --

  /* Bug 5371102 - Added joins on Payroll ID for better performance */
  cursor csr_get_dates
  (c_assignment_id per_assignments_f.assignment_id%type
  ,c_year_start pay_payroll_actions.effective_date%type
  ,c_year_end pay_payroll_actions.effective_date%type
  ,c_legal_employer hr_organization_units.organization_id%type
  ) is
  select to_char(min(ppa.effective_date),'DDMMYYYY'), to_char(max(ppa.effective_date),'DDMMYYYY')
  from   pay_assignment_actions     paa,
         pay_payroll_actions        ppa,
         per_assignments_f      paaf
  where  paa.assignment_id      = paaf.assignment_id
  and    paaf.assignment_id         = c_assignment_id
  and    paa.payroll_action_id      = ppa.payroll_action_id
  and    ppa.effective_date         between c_year_start and c_year_end
  and    ppa.payroll_id             = paaf.payroll_id
  and    ppa.effective_date         between paaf.effective_start_date and paaf.effective_end_date
  and    paa.tax_unit_id        = c_legal_employer
  and    paa.action_status      = 'C'
  and    ppa.action_type        in ('R','Q','V'); /*Bug 4387183*/
  --
  -- 4387183 - This cursor has been modified. It will now pick the maximum effective record for the
  --           assignment between FBT year start and financial year end.
  --
  cursor csr_get_end_le
  (c_assignment_id per_assignments_f.assignment_id%type
  ,c_year_end pay_payroll_actions.effective_date%type
  ,c_year_start pay_payroll_actions.effective_date%type
  ) is
  select hsck.segment1
  from   per_assignments_f      paaf,
         hr_soft_coding_keyflex     hsck
  where  paaf.assignment_id         = c_assignment_id
  and    paaf.soft_coding_keyflex_id    = hsck.soft_coding_keyflex_id
  and    paaf.effective_start_date  <= c_year_end
  and    paaf.effective_end_date    >= c_year_start
  order by paaf.effective_start_date desc;
  --
  -- End 4363057
  --
  ---------------------------------------------------------------------------+
  -- This table is used to store all the balance names
  -- for these, archive_balance_details procedure is called to
  -- create respective balance.
  ---------------------------------------------------------------------------+
  --
  type bal_type is table of varchar2(100) index by binary_integer;
  tab_bal_name bal_type ;
  --
  ---------------------------------------------------------------------------+
  --- This table is used to store the actual balance names(Bug #2454595)
  --- If any balances are added further, then corresponding archive item
  --- PL/SQL table should be updated.
  ---------------------------------------------------------------------------+
  --
  type bal_actual_type is table of varchar2(100) index by binary_integer;
  tab_bal_actual_name       bal_actual_type ;
  l_bbr_action_sequence     pay_assignment_actions.action_sequence%type;        --3701869

  lv_trans_etp_flag      varchar2(1);
  lv_part_of_prev_etp_flag varchar2(1);

begin
  g_debug :=  hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location(l_procedure, 1);
     hr_utility.set_location(l_procedure ||' => assignment action:'||p_assignment_action_id,2);
  end if;
  --
  /*Begin 8315198 - Cursor code is moved here so that the new 2009 PS balances are initialized in pl/sql table
                  only if the year start date is FY 2009 or greater*/
  open  c_action(p_assignment_action_id);
  fetch c_action
  into  l_business_group_id
  ,     l_registered_employer
  ,     l_employee_type
  ,     l_payroll_action_id
  ,     l_assignment_id
  ,     l_year_start
  ,     l_year_end
  ,     l_lst_yr_term;              --3661230
  close c_action;
  /*End 8315198*/

  lv_trans_etp_flag        :='N';
  lv_part_of_prev_etp_flag :='N';

  tab_bal_name(1) :='X_FRINGE_BENEFITS_ASG_YTD';
  tab_bal_name(2) :='X_CDEP_ASG_YTD';
  tab_bal_name(3) :='X_EARNINGS_TOTAL_ASG_YTD';
  tab_bal_name(4) :='X_LUMP_SUM_A_DEDUCTIONS_ASG_YTD';
  tab_bal_name(5) :='X_LUMP_SUM_A_PAYMENTS_ASG_YTD';
  tab_bal_name(6) :='X_LUMP_SUM_B_DEDUCTIONS_ASG_YTD';
  tab_bal_name(7) :='X_LUMP_SUM_B_PAYMENTS_ASG_YTD';
  tab_bal_name(8) :='X_LUMP_SUM_D_PAYMENTS_ASG_YTD';
  tab_bal_name(9) :='X_TOTAL_TAX_DEDUCTIONS_ASG_YTD';
  tab_bal_name(10):='X_OTHER_INCOME_ASG_YTD';
  tab_bal_name(11):='X_UNION_FEES_ASG_YTD';
  tab_bal_name(12):='X_INVALIDITY_PAYMENTS_ASG_YTD';
  tab_bal_name(13):='X_LUMP_SUM_C_PAYMENTS_ASG_YTD';
  tab_bal_name(14):='X_LUMP_SUM_C_DEDUCTIONS_ASG_YTD';
  tab_bal_name(15):='X_WORKPLACE_GIVING_DEDUCTIONS_ASG_YTD'; /*4015082 */
/* Begin 6192381 */
  tab_bal_name(16):='X_ETP_DED_TRANS_PPTERM_ASG_YTD';
  tab_bal_name(17):='X_ETP_DED_TRANS_NOT_PPTERM_ASG_YTD';
  tab_bal_name(18):='X_ETP_DED_NOT_TRANS_PPTERM_ASG_YTD';
  tab_bal_name(19):='X_ETP_DED_NOT_TRANS_NOT_PPTERM_ASG_YTD';
  tab_bal_name(20):='X_INV_PAY_NOT_TRANS_NOT_PPTERM_ASG_YTD';
  tab_bal_name(21):='X_INV_PAY_NOT_TRANS_PPTERM_ASG_YTD';
  tab_bal_name(22):='X_INV_PAY_TRANS_NOT_PPTERM_ASG_YTD';
  tab_bal_name(23):='X_INV_PAY_TRANS_PPTERM_ASG_YTD';

/* End 6192381 */

/* Begin 8315198  - Archive the new DB items for new balances from FY 2009 onwards*/
if (to_number(to_char(l_year_start,'YYYY')) >= 2009) then
  tab_bal_name(24):='X_RPT_EMPLOYER_SUPERANN_CONTR_ASG_YTD';
  tab_bal_name(25):='X_EXEMPT_FOREIGN_EMPLOY_INC_ASG_YTD';
end if;

/* End 8315198 */
  --
  ---------------------------------------------------------------------------+
  --- Hard Coded Balance names(Bug #2454595)
  ---------------------------------------------------------------------------+
  tab_bal_actual_name(1) := 'Fringe Benefits';
  tab_bal_actual_name(2) := 'CDEP';
  tab_bal_actual_name(3) := 'Earnings_Total';
  tab_bal_actual_name(4) := 'Lump Sum A Deductions';
  tab_bal_actual_name(5) := 'Lump Sum A Payments';
  tab_bal_actual_name(6) := 'Lump Sum B Deductions';
  tab_bal_actual_name(7) := 'Lump Sum B Payments';
  tab_bal_actual_name(8) := 'Lump Sum D Payments';
  tab_bal_actual_name(9) := 'Total_Tax_Deductions';
  tab_bal_actual_name(10):= 'Other Income';
  tab_bal_actual_name(11):= 'Union Fees';
  tab_bal_actual_name(12):= 'Invalidity Payments';
  tab_bal_actual_name(13):= 'Lump Sum C Payments';
  tab_bal_actual_name(14):= 'Lump Sum C Deductions';
  tab_bal_actual_name(15):= 'Workplace Giving Deductions'; /* 4015082 */

/* Begin 6192381 */
  tab_bal_actual_name(16):= 'ETP Deductions Transitional Part of Prev Term';
  tab_bal_actual_name(17):= 'ETP Deductions Transitional Not Part of Prev Term';
  tab_bal_actual_name(18):= 'ETP Deductions Life Benefit Part of Prev Term';
  tab_bal_actual_name(19):= 'ETP Deductions Life Benefit Not Part of Prev Term';
  tab_bal_actual_name(20):= 'Invalidity Payments Life Benefit Not Part of Prev Term';
  tab_bal_actual_name(21):= 'Invalidity Payments Life Benefit Part of Prev Term';
  tab_bal_actual_name(22):= 'Invalidity Payments Transitional Not Part of Prev Term';
  tab_bal_actual_name(23):= 'Invalidity Payments Transitional Part of Prev Term';

/* End 6192381 */

/* Begin 8315198 - Consider the new balances  for archival from FY 2009 onwards*/
if (to_number(to_char(l_year_start,'YYYY')) >= 2009) then
  tab_bal_actual_name(24):= 'Reportable Employer Superannuation Contributions';
  tab_bal_actual_name(25):= 'Exempt Foreign Employment Income';
end if;
/* End 8315198 */

/* Bug 6470581 - Added Changes for Amended Payment Summary
      i.  Initialized Amended PS PL/SQL table
      ii. Archive Payment Summary Flag DB Items
*/


        p_all_dbi_tab.delete;

IF g_payment_summary_type = 'O'
THEN

        create_extract_archive_details
              (p_assignment_action_id
              ,'X_PAYMENT_SUMMARY_TYPE'
              ,g_payment_summary_type
              );

        create_extract_archive_details
              (p_assignment_action_id
              ,'X_PAYG_PAYMENT_SUMMARY_TYPE'
              ,g_payment_summary_type
              );

        create_extract_archive_details
              (p_assignment_action_id
              ,'X_ETP1_PAYMENT_SUMMARY_TYPE'
              ,g_payment_summary_type
              );

        create_extract_archive_details
              (p_assignment_action_id
              ,'X_ETP2_PAYMENT_SUMMARY_TYPE'
              ,g_payment_summary_type
              );

        create_extract_archive_details
              (p_assignment_action_id
              ,'X_ETP3_PAYMENT_SUMMARY_TYPE'
              ,g_payment_summary_type
              );

        create_extract_archive_details
              (p_assignment_action_id
              ,'X_ETP4_PAYMENT_SUMMARY_TYPE'
              ,g_payment_summary_type
              );

END IF;

/* End changes Bug 6470581 */

  -- 8315198 - Commented and moved the c_acion cursor code before initalization of PS balances in PL/SQL table
/*open  c_action(p_assignment_action_id);
  fetch c_action
  into  l_business_group_id
  ,     l_registered_employer
  ,     l_employee_type
  ,     l_payroll_action_id
  ,     l_assignment_id
  ,     l_year_start
  ,     l_year_end
  ,     l_lst_yr_term;              --3661230
  close c_action;*/
  --
  -- 3701869
  --
  l_lst_yr_term := nvl(l_lst_yr_term,'Y');
  --
  -- 3661230
  --
  if l_lst_yr_term = 'Y' then
    v_lst_year_start := add_months(l_year_start,-12); -- 3263659
    l_fbt_year_start := to_date('01-04-'||to_char(l_year_start,'YYYY'),'DD-MM-YYYY');
  else
    v_lst_year_start := to_date('01-01-1900','DD-MM-YYYY');
    l_fbt_year_start := to_date('01-01-1900','DD-MM-YYYY');
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_procedure ||' => 1 assignment_id :' || l_assignment_id, 2);
  end if;
  --------------------------------------------------------+
  -- archival of data for terminated employees
  --------------------------------------------------------+
  --
  if (l_employee_type <> 'C') then
    --
    -- 2646912
    -- Store the value of defined balance id for using for next assignments
    -- lump_sum_c_found is used to indicate whether Lump Sum C Payment amount exists for the employee
    --
    if pkg_lump_sum_c_def_bal_id is null or pkg_lump_sum_c_def_bal_id = 0 then
      if g_debug then
         hr_utility.set_location(l_procedure ,6 );
      end if;
      --
      open  balance_exists;
      fetch balance_exists
      into  pkg_lump_sum_c_def_bal_id;
      --
      if balance_exists%notfound then
        pkg_lump_sum_c_def_bal_id := -1;
        if g_debug then
          hr_utility.set_location(l_procedure ,7 );
        end if;
      end if;
      close balance_exists;
    end if;
    --
    if pkg_lump_sum_c_def_bal_id <> -1 then
      open etp_code
      (l_assignment_id
      ,v_lst_year_start
      ,l_year_start
      ,l_year_end
      ,pkg_lump_sum_c_def_bal_id
      ,l_business_group_id
      );                    -- 2856638
      fetch etp_code
      into l_current_employee_flag
      ,    l_actual_termination_date
      ,    l_date_start
      ,    l_death_benefit_type
      ,    l_max_assignment_action_id       -- 3019374
      ,    l_final_process_date;            -- 3263659
      --
      if etp_code%found then            -- 3019374
        if (pay_balance_pkg.get_value(pkg_lump_sum_c_def_bal_id, l_max_assignment_action_id, l_registered_employer,null,null,null,null) > 0) then --2610141
          lump_sum_c_found := true;
          if g_debug then
            hr_utility.set_location('Lump Sum C Payment found.' ,9 );
          end if;
        end if;
        --
        -- 3263659
        -- To set the actual termination date so as to archive all balanced in case paid in
        -- this year and terminated in last year
        --
        open  cr_effective_date(l_max_assignment_action_id);
        fetch cr_effective_date
        into  l_effective_date;
        close cr_effective_date;
        --
        l_fetched_termination_date := l_actual_termination_date;  -- Bug3263659 To store actual date for Pre-post calculation
        if (l_actual_termination_date < l_year_start and l_effective_date >= l_year_start ) then
          l_actual_termination_date := nvl(l_final_process_date,l_effective_date);  /* Bug 3098353 To set the End Date as
                                                                                         Payment Date if final_process is null */
        end if;
      end if;
      close etp_code;
    end if;

    if lump_sum_c_found = false then
      if g_debug then
        hr_utility.set_location('Lump Sum C Payment balance does not exists ',101);
      end if;
    end if;
    --
    /* Bug3263659 l_actual_termination_date AND clause added to prevent etp being archive in case its
                   terminated in last year and no runs in current year
    */
    /* Bug 6112527  Added condition to_number(to_char(l_year_start,'YYYY')) >= 2007 for archive death benefit type D only after Fin Year 2007/2008 */

if (((l_death_benefit_type <>'D' or to_number(to_char(l_year_start,'YYYY')) >= 2007)  or l_death_benefit_type is null) and (lump_sum_c_found = true)
      and not (l_actual_termination_date between l_fbt_year_start and to_date('30-06-'||to_char(l_year_start,'YYYY'),'DD-MM-YYYY')) ) then   --Bug#3661230
      --
      -- 2448446 , 2646912
      --
      if g_debug then
        hr_utility.set_location('creating etp details for assignment id: ' ||l_assignment_id, 7);
      end if;
      --
      ------------------------------------------------------+
      -- call procedure to archive details of terminated employees
      -- archive etp details  procedure archives employee related details
      -- archive prespost details archives prejul83 and postjun83 information
      -------------------------------------------------------+
      archive_etp_details
      (l_business_group_id
      ,l_registered_employer
      ,l_payroll_action_id
      ,p_assignment_action_id
      ,l_assignment_id
      ,l_year_start
      ,l_year_end
      ,v_lst_year_start /*Bug3661230 Added one extra parameter*/
      ,lv_trans_etp_flag  /*Bug 6192381 Added New Parameters lv_trans_etp_flag and lv_part_of_prev_etp_flag */
      ,lv_part_of_prev_etp_flag
      );
      --
      l_term_date := to_char(l_actual_termination_date,'DDMMYYYY');       -- Bug3263659 TO Archive modified termination date
      --
      create_extract_archive_details
      (p_assignment_action_id
      ,'X_ETP_EMPLOYEE_END_DATE'
      ,l_term_date
      );
      --
      if g_debug then
        hr_utility.set_location('creating prejul83 and post jun 83 details for assignment id :' ||l_assignment_id, 7);
      end if;
      --
      archive_prepost_details
      (p_assignment_action_id
      ,l_max_assignment_action_id           --2610141
      ,l_registered_employer                --2610141
      ,g_legislation_code
      ,l_assignment_id
      ,l_payroll_action_id
      ,l_fetched_termination_date               --3263659
      ,l_date_start
      ,l_year_start
      ,l_year_end
      ,lv_trans_etp_flag /*Bug 6192381 Added New Parameters lv_trans_etp_flag and lv_part_of_prev_etp_flag */
      ,lv_part_of_prev_etp_flag);
      --
    end if;
  end if;   /*  (l_employee_type <> 'C')  */
  --
  ----------------------------------------------------------------------------
  -- if the employee has been terminated in the FBT year then archive only the
  -- Fringe Benefits balance , other balances should be zero
  -- else archive all balances
  ----------------------------------------------------------------------------
  if (l_actual_termination_date is not null) and
           (l_actual_termination_date between  l_fbt_year_start and to_date('30-06-'||to_char(l_year_start,'YYYY'),'DD-MM-YYYY')) then  --Bug#3661230
    --
    -- 4738470 - Get the Maximum assignment_action_id for FBT employee
    --
    open  c_max_asg_action_id
    (     l_assignment_id
    ,     l_business_group_id
    ,     l_registered_employer
    ,     add_months(l_year_start,-3)
    ,     (l_year_start - 1)
    );
    fetch c_max_asg_action_id
    into  l_fbt_assignment_action_id
    ,     l_bbr_action_sequence;
    close c_max_asg_action_id;
    --
    -- 2610141
    --
    archive_balance_details
    (p_assignment_action_id
    ,l_fbt_assignment_action_id             --2610141
    ,l_registered_employer              --2610141
    ,tab_bal_name(1)                    -- X_FRINGE_BENEFITS_ASG_YTD
    ,tab_bal_actual_name(1)                 -- 2454595
    ,g_legislation_code
    ,l_year_start
    ,l_year_end
    ,l_assignment_id
    ,l_payroll_action_id
    ,l_bal_value
    );                          --3098353
    --
    l_net_balance := l_bal_value;           --2610141
    l_actual_termination_date := l_year_start;      --3098353 - Since in case of only FBT employee,
                                                        -- period dates should be year start date.
    --
    -- 4866934 - Set the Balance Values to 0 for FBT Employee
    --
    p_result_table.delete;
    for i in p_balance_value_tab.first..p_balance_value_tab.last
    loop
      p_result_table(i).balance_value := 0;
    end loop;
    --
  else              -- 3172963
    if g_debug then
      hr_utility.set_location('Get assignment_action_id for BBR call, for assignment id: ' || l_assignment_id, 11);
    end if;
    --
    -- 4738470 - Get the Maximum assignment_action_id
    --
    open c_max_asg_action_id
    (l_assignment_id
    ,l_business_group_id
    ,l_registered_employer
    ,l_year_start
    ,l_year_end
    );
    fetch c_max_asg_action_id
    into  l_bbr_assignment_action_id
    ,     l_bbr_action_sequence;
    close c_max_asg_action_id;
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 12);
      hr_utility.trace('Using ASSIGNMENT_ACTION_ID: ' || l_bbr_assignment_action_id);
    end if;
    --
    -- 4866934 - Flush balance values in PL/SQL table
    --
    p_result_table.delete;
    --
    -- Changes made for bug 2610141 Start here
    --
    p_context_table(1).tax_unit_id := l_registered_employer;
    --
    pay_balance_pkg.get_value
    (p_assignment_action_id     => l_bbr_assignment_action_id
    ,p_defined_balance_lst  => p_balance_value_tab
    ,p_context_lst      => p_context_table
    ,p_output_table         => p_result_table
    );
    --
    -- Changes made for bug 2610141 Ends here
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 13);
      hr_utility.trace('------------------------------------------------');
      hr_utility.trace('CDEP                    ===>' || p_result_table(1).balance_value);
      hr_utility.trace('Leave Payments Marginal ===>' || p_result_table(2).balance_value);
      hr_utility.trace('Lump Sum A Deductions   ===>' || p_result_table(3).balance_value);
      hr_utility.trace('Lump Sum A Payments     ===>' || p_result_table(4).balance_value);
      hr_utility.trace('Lump Sum B Deductions   ===>' || p_result_table(5).balance_value);
      hr_utility.trace('Lump Sum B Payments     ===>' || p_result_table(6).balance_value);
      hr_utility.trace('Lump Sum C Deductions   ===>' || p_result_table(7).balance_value);
      hr_utility.trace('Lump Sum C Payments     ===>' || p_result_table(8).balance_value);
      hr_utility.trace('Lump Sum D Payments     ===>' || p_result_table(9).balance_value);
      hr_utility.trace('Total_Tax_Deduction     ===>' || p_result_table(10).balance_value);
      hr_utility.trace('Termination Deductions  ===>' || p_result_table(11).balance_value);
      hr_utility.trace('Exempt Foreign Employment Income   ===>' || p_result_table(12).balance_value);
      hr_utility.trace('Union Fees              ===>' || p_result_table(13).balance_value);
      hr_utility.trace('Invalidity Payments     ===>' || p_result_table(14).balance_value);
      hr_utility.trace('Lump Sum E Payments     ===>' || p_result_table(15).balance_value);
      hr_utility.trace('Earnings_Total          ===>' || p_result_table(16).balance_value);
      hr_utility.trace('Workplace Giving        ===>' || p_result_table(17).balance_value); /* 4015082 */
      hr_utility.trace('ETP Deductions Transitional Not Part of Prev Term      ===>' || p_result_table(18).balance_value);
      hr_utility.trace('ETP Deductions Transitional Part of Prev Term          ===>' || p_result_table(19).balance_value);
      hr_utility.trace('ETP Deductions Life Benefit Not Part of Prev Term      ===>' || p_result_table(20).balance_value);
      hr_utility.trace('ETP Deductions Life Benefit Part of Prev Term          ===>' || p_result_table(21).balance_value);
      hr_utility.trace('Invalidity Payments Life Benefit Not Part of Prev Term  ===>' || p_result_table(22).balance_value);
      hr_utility.trace('Invalidity Payments Life Benefit Part of Prev Term      ===>' || p_result_table(23).balance_value);
      hr_utility.trace('Invalidity Payments Transitional Not Part of Prev Term  ===>' || p_result_table(24).balance_value);
      hr_utility.trace('Invalidity Payments Transitional Part of Prev Term      ===>' || p_result_table(25).balance_value);
      hr_utility.trace('Reportable Employer Superannuation Contributions  ===>' || p_result_table(26).balance_value);
      hr_utility.trace('Retro Earnings Leave Loading GT 12 Mths Amount     ===>' || p_result_table(27).balance_value); -- start 8711855
      hr_utility.trace('Retro Earnings Spread GT 12 Mths Amount    ===>' || p_result_table(28).balance_value);
      hr_utility.trace('Retro Pre Tax GT 12 Mths Amount     ===>' || p_result_table(29).balance_value);        -- end 8711855
    end if;

      if g_debug then
        hr_utility.set_location('lv_trans_etp_flag :' ||lv_trans_etp_flag, 7);
        hr_utility.set_location('lv_part_of_prev_etp_flag:' ||lv_part_of_prev_etp_flag, 7);
      end if;

/*Bug 6192381 Procedure to adjust old etp deduction and old Invalidity Payments */
      adjust_old_etp_values(lv_trans_etp_flag
                            ,lv_part_of_prev_etp_flag);
    --
    for cnt in 1..tab_bal_name.count
    loop
      if g_debug then
        hr_utility.set_location('creating '||tab_bal_name(cnt)||' balance for ass action id: '|| l_bbr_assignment_action_id,14);
        hr_utility.set_location('Death benefit type:'||l_death_benefit_type,113);
      end if;
      --
      ---------------------------------+
      -- call procedure to archive all balances
      ---------------------------------+
      ---------------------------------
      -- 1956018
      ---------------------------------
      --

    /* Bug 6112527  Modified  condition that for death benefit type archive balances if Fin Year >= 2007/2008
        From 01-Jul-2007 ETP Amount for termination type Death and Benefit type Dependent amount is taxable */
    /* Bug 8315198 - Added condition such that the 'Other Income' balance is not archived from 01-Jul-2009 onwards */
       if (((l_death_benefit_type = 'D' and to_number(to_char(l_year_start,'YYYY')) <= 2006) and (tab_bal_name(cnt) in
                          ('X_LUMP_SUM_C_PAYMENTS_ASG_YTD','X_LUMP_SUM_C_DEDUCTIONS_ASG_YTD'))) or
            ((to_number(to_char(l_year_start,'YYYY')) >= 2009) and (tab_bal_name(cnt) in ('X_OTHER_INCOME_ASG_YTD')))) then
        null;
      else

        if tab_bal_name.exists(cnt) then
          --
          -- 2610141
          --
          if tab_bal_name(cnt) = 'X_FRINGE_BENEFITS_ASG_YTD' then
            --
            -- 4738470 - Get the FBT Maximum assignment_action_id
            --
            open c_max_asg_action_id
            (l_assignment_id
            ,l_business_group_id
            ,l_registered_employer
            ,add_months(l_year_start,-3)
            ,add_months(l_year_end,-3)
            );
            fetch c_max_asg_action_id
            into  l_fbt_assignment_action_id
            ,     l_bbr_action_sequence;
            close c_max_asg_action_id;
            --
            archive_balance_details
            (p_assignment_action_id
            ,l_fbt_assignment_action_id         -- 2610141
            ,l_registered_employer          -- 2610141
            ,tab_bal_name(1)                -- X_FRINGE_BENEFITS_ASG_YTD
            ,tab_bal_actual_name(1)             -- 2454595 Fringe Benefits
            ,g_legislation_code
            ,l_year_start
            ,l_year_end
            ,l_assignment_id
            ,l_payroll_action_id
            ,l_bal_value
            ); --3098353
          else
            --
            -- 2610141
            --
            archive_balance_details
            (p_assignment_action_id
            ,l_bbr_assignment_action_id             -- 2610141
            ,l_registered_employer          -- 2610141
            ,tab_bal_name(cnt)
            ,tab_bal_actual_name(cnt)               -- 2454595
            ,g_legislation_code
            ,l_year_start
            ,l_year_end
            ,l_assignment_id
            ,l_payroll_action_id
            ,l_bal_value
            );                              --3098353
          end if;
          --
          -- 3098353
          --
          if cnt = 1 then                   -- To store FBT balance value
            l_fbt_balance := l_bal_value;
          end if;

          /*Begin 8315198 - Added code to get the value of X_LUMP_SUM_A_PAYMENTS_ASG_YTD balance*/

          if cnt = 5 then
            l_lump_sum_a_value := l_bal_value;
          end if;

          /*End 8315198*/
          --
          -- 3937976
          --
          l_net_balance:= l_net_balance + to_number(nvl(l_bal_value,0));
          --
        end if;
      end if;
    end loop;
    --
    -- By default reporting_flag is 'YES' i.e the employee will be displayed in any of the reports.
    -- The following statement checks that if employee is terminated in last year and the sum of
    -- balances is zero then reporting_flag will be 'NO' i.e. in this case the employee
    -- should not be reported in any of the reports.
    --
    if l_fetched_termination_date < l_year_start and l_net_balance = 0 then
      l_reporting_flag := 'NO';
    end if;
    --
    -- 3937976
    --
    if nvl(l_fetched_termination_date,to_date('31/12/4712','DD/MM/YYYY')) >= l_year_start and l_net_balance = 0 then
      l_curr_term_0_bal_flag:='YES';
    end if;
  end if;
  --
  -----------------------------------------------
  --* Archive Allowance details
  -----------------------------------------------
  archive_allowance_details
  (p_assignment_action_id
  ,l_bbr_assignment_action_id       --2610141
  ,l_registered_employer            --2610141
  ,l_year_start
  ,l_year_end
  ,l_assignment_id
  ,l_alw_bal_exist
  );
  --
  -- Perform archive of 2006 unions setup
  --
  /*
  archive_2006_unions
  (p_assignment_id              => l_assignment_id
  ,p_assignment_action_id       => p_assignment_action_id
  ,p_max_assignment_action_id   => l_bbr_assignment_action_id
  ,p_registered_employer        => l_registered_employer
  ,p_year_start                 => l_year_start
  ,p_year_end                   => l_year_end
  ,p_alw_bal_exist              => l_alw_bal_exist
  );
  */
  --
  -- 3098353
  --
  -- This  flag is sets the reporting_flag if the allowance are paid to employee
  -- in the current year.
  --
  if l_alw_bal_exist = 'TRUE' then
    l_reporting_flag := 'YES';
    l_curr_term_0_bal_flag :='NO';            -- 3937976
  end if;
  --
  -- If only FBT is reported than period end date should be year start date
  --
  if (l_net_balance - l_fbt_balance) = 0 and l_alw_bal_exist = 'FALSE' and l_fbt_balance <> 0 then
    l_actual_termination_date := l_year_start;
    l_term_date := to_char(l_actual_termination_date,'DDMMYYYY');
    if g_debug then
      hr_utility.set_location('Creating archive Item X_EMPLOYEE_END_DATE',12);
    end if;
    --
    -- 2610141
    --
    create_extract_archive_details
    (p_assignment_action_id
    ,'X_EMPLOYEE_LE_END_DATE'
    ,l_term_date
    );
    l_le_end_date_flag := 'Y';
  end if;
  --
  -- 2610141
  --
  if l_actual_termination_date <> l_fetched_termination_date and l_le_end_date_flag = 'N' then
    l_term_date := to_char(l_actual_termination_date,'DDMMYYYY');
    create_extract_archive_details
    (p_assignment_action_id
    ,'X_EMPLOYEE_LE_END_DATE'
    ,l_term_date
    );
    l_le_end_date_flag := 'Y';
  end if;
  --
  -- 2610141
  --
  if g_debug then
    hr_utility.set_location('Creating archive Item X_EMPLOYEE_END_DATE',12);
  end if;
  --
  l_term_date := to_char(l_actual_termination_date,'DDMMYYYY');
  create_extract_archive_details
  (p_assignment_action_id
  ,'X_EMPLOYEE_END_DATE'
  ,l_term_date
  );
  --
  create_extract_archive_details
  (p_assignment_action_id
  ,'X_REPORTING_FLAG'
  ,l_reporting_flag
  );
  --
  --3937976
  --
  create_extract_archive_details
  (p_assignment_action_id
  ,'X_CURR_TERM_0_BAL_FLAG'
  ,l_curr_term_0_bal_flag
  );

  --
  ------------------------------------------------------+
  --call  procedure to archive supplier details
  -------------------------------------------------------+
  archive_supplier_details
  (l_business_group_id
  ,l_registered_employer
  ,l_payroll_action_id
  ,p_assignment_action_id
  ,l_assignment_id
  ,l_year_start
  ,l_year_end
  );
  --
  if g_debug then
    hr_utility.set_location('creating employee details for  assignment id: ' || l_assignment_id, 9);
  end if;
  --
  ------------------------------------------------------+
  --call  procedure to archive employee details
  -------------------------------------------------------+
  /*Bug# 4363057 - This logic is introduced to check if the employee is active for the submitted
                 legal employer in the current financial year.
                 If employee is active for the submitted legal employer then pass the value to
                 archive_employee_details.
                 If employee is not active for the submitted legal employer then get the maximum and
                 minimum payment dates for the legal employer. Get the legal employer effective at the maximum
                 payment date and pass it to archive_employee_details
  */
  /*Bug 4387183 -  Above logic has been modified to take care of terminated employees.
                 - FBT employees terminated in the FBT period will be archived with le start and end dates as
                   financial year start dates.
                 - When Payment Summary is submitted for Employees terminated with final process date as null and
                   for legal employer in which they have recieved retropayments but are not active in the current
                   financial year then the le start date will be set as financial year start, while the le end date
                   will be set as the Retropayment date.
                 - When Payment Summary is submitted for Employees terminated with final process date not null and
                   for legal employer in which they have recieved retropayments but are not active in the current
                   financial year then the le start date will be set as financial year start, while the le end date
                   will be set as the final process date.
  */
  --
  open csr_check_eff_le(l_assignment_id, l_registered_employer, l_year_start, l_year_end);
  fetch csr_check_eff_le into l_dummy;
  if csr_check_eff_le%notfound then
    open csr_get_dates(l_assignment_id, l_year_start,l_year_end,l_registered_employer);
    fetch csr_get_dates into l_pay_start, l_pay_end;
    close csr_get_dates;
    --
    -- 4387183
    -- If the le end date has been archived already, that is for terminated
    -- employees then don't archive the start and end dates here. Le start
    -- date will be archived in archive_employee_detail
    --
    if l_le_end_date_flag = 'N' then
      --
      create_extract_archive_details
      (p_assignment_action_id
      ,'X_EMPLOYEE_LE_START_DATE'
      ,l_pay_start
      );
      create_extract_archive_details
      (p_assignment_action_id
      ,'X_EMPLOYEE_LE_END_DATE'
      ,l_pay_end
      );
      l_le_end_date_flag := 'B';
    end if;
    --
    open csr_get_end_le(l_assignment_id, l_year_end,l_fbt_year_start);
    fetch csr_get_end_le into l_current_le;
    close csr_get_end_le;
    --
    archive_employee_details
    (l_business_group_id
    ,l_current_le
    ,l_payroll_action_id
    ,p_assignment_action_id
    ,l_assignment_id
    ,l_year_start
    ,l_year_end
    ,l_le_end_date_flag
    ,l_fbt_year_start                       -- 4653934
    );
  else
    archive_employee_details
    (l_business_group_id
    ,l_registered_employer                  --2610141
    ,l_payroll_action_id
    ,p_assignment_action_id
    ,l_assignment_id
    ,l_year_start
    ,l_year_end
    ,l_le_end_date_flag
    ,l_fbt_year_start                       -- 4653934
    );
  end if;
  close csr_check_eff_le;
  --
  -- 4363057
  --
  if g_debug then
    hr_utility.set_location('creating employer details for assignment id: ' || l_assignment_id, 10);
  end if;
  --
  ------------------------------------------------------+
  --call  procedure to archive employer details
  -------------------------------------------------------+
  --
  archive_employer_details
  (l_business_group_id
  ,l_bbr_assignment_action_id   --2610141
  ,l_registered_employer        --2610141
  ,l_payroll_action_id
  ,p_assignment_action_id
  ,l_assignment_id
  ,l_year_start
  ,l_year_end
  );

  /*Begin 8315198 - Added code to assign the value of lump sum a payment type depending on termination type
                    and archive the value using the X_LUMP_SUM_A_PAYMENT_TYPE db item from FY 2009 onwards*/

if (to_number(to_char(l_year_start,'YYYY')) >= 2009) then
  IF l_lump_sum_a_value > 0 THEN
      IF g_termination_type = 'AU_B' or g_termination_type = 'AU_I' THEN
        l_lump_sum_a_pymt_type := 'R';
      ELSE
        l_lump_sum_a_pymt_type := 'T';
      END IF;
  END IF;

  create_extract_archive_details(p_assignment_action_id
                                ,'X_LUMP_SUM_A_PAYMENT_TYPE'
                                ,l_lump_sum_a_pymt_type);

  if g_debug then
    hr_utility.set_location('Creating archive Item X_LUMP_SUM_A_PAYMENT_TYPE',12);
  end if;
end if;
 /*End 8315198*/

/* Bug 6470581 -Call Amended Payment Summary manipulation logic
                if this is Amended Payment Summary Run */

IF g_payment_summary_type = 'A'
THEN

    pay_au_payment_summary_amend.modify_and_archive_code
                (p_assignment_action_id   => p_assignment_action_id
                ,p_effective_date         => p_effective_date
                ,p_all_tab_new            => p_all_dbi_tab);

END IF;

  if g_debug then
    hr_utility.set_location('End of archive code', 37);
  end if;

exception
  when others then
  if g_debug then
     hr_utility.set_location('error in archive code - assignment id :' ||l_assignment_id,11);
  end if;
  raise;
end archive_code;

  --------------------------------------------------------------------+
  -- This function is used to get end of year values for archive items
  -- called from validation report and payment summary report
  --------------------------------------------------------------------+


function get_archive_value(p_user_entity_name     in ff_user_entities.user_entity_name%type,
                           p_assignment_action_id in pay_assignment_actions.assignment_action_id%type)
return varchar2 is


  -- cursor to fetch the archive value

  cursor   csr_get_value(p_user_entity_name varchar2,
                         p_assignment_action_id number) is
  select   fai.value
    from   ff_archive_items fai,
           ff_user_entities fue
   where   fai.context1         = p_assignment_action_id
     and   fai.user_entity_id   = fue.user_entity_id
     and   fue.user_entity_name = p_user_entity_name;


  l_value            ff_archive_items.value%type;
  e_no_value_found   exception;


begin

   g_debug := hr_utility.debug_enabled;

   IF g_debug THEN
       hr_utility.set_location('Start of get archive value ',1);
   END if;

  open   csr_get_value(p_user_entity_name,
                       p_assignment_action_id);
  fetch  csr_get_value into l_value;

  if  csr_get_value%notfound then
    l_value := null;
    close csr_get_value;
    raise e_no_value_found;
  else
    close csr_get_value;
  end if;
  return(l_value);
    IF g_debug THEN
      hr_utility.set_location('End of get archive value ',2);
     END if;


exception
  when e_no_value_found then
   IF g_debug THEN
        hr_utility.set_location('error in get archive value  - assignment_action_id:' ||p_assignment_action_id,3);
        hr_utility.set_location('error in get archive value  - user entity name    :' ||p_user_entity_name,3);
    END if;
    return (null);
  when others then
    IF g_debug THEN
        hr_utility.set_location('error in get archive value  - assignment_action_id:' ||p_assignment_action_id,3);
        hr_utility.set_location('error in get archive value  - user entity name    :' ||p_user_entity_name,3);
    END if;
    return (null);
    Raise;
end  get_archive_value;



-- Following Procedure is created as per enhancement - Bug#3132178
-- This procedure checks if TEST_EFILE flag is TRUE then submit a request for Magtape Process

procedure spawn_data_file
(p_payroll_action_id in pay_payroll_actions.payroll_action_id%type)
  is

 ps_request_id          NUMBER;
 l_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
 l_business_group_id    number;
 l_start_date       date;
 l_end_date         date;
 l_effective_date   date;
 l_legal_employer   number;
 l_FINANCIAL_YEAR_code  varchar2(10);
 l_TEST_EFILE       varchar2(10);
 l_FINANCIAL_YEAR   varchar2(10);
 l_legislative_param    varchar2(200);

  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

   CURSOR csr_magtape_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
        SELECT pay_core_utils.get_parameter('TEST_EFILE',legislative_parameters)        TEST_EFILE,
               pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters)        BUSINESS_GROUP_ID,
           pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters)  FINANCIAL_YEAR,
               pay_core_utils.get_parameter('REGISTERED_EMPLOYER',legislative_parameters)    REGISTERED_EMPLOYER,
               to_date(pay_core_utils.get_parameter('START_DATE',legislative_parameters),'YYYY/MM/DD') start_date,
               to_date(pay_core_utils.get_parameter('END_DATE',legislative_parameters),'YYYY/MM/DD')   end_date,
               to_date(pay_core_utils.get_parameter('EFFECTIVE_DATE',legislative_parameters),'YYYY/MM/DD')   EFFECTIVE_DATE
       FROM   pay_payroll_actions ppa
       WHERE ppa.payroll_action_id  =  c_payroll_action_id;


  CURSOR csr_lookup_code (c_financial_year varchar2)
    IS
       SELECT LOOKUP_CODE
       FROM HR_LOOKUPS
       WHERE lookup_type = 'AU_PS_FINANCIAL_YEAR'
       AND enabled_flag = 'Y'
       AND meaning =c_financial_year;

 Begin

   ps_request_id :=-1;
   l_TEST_EFILE :='N';
   g_debug := hr_utility.debug_enabled;

   OPEN  csr_magtape_params(p_payroll_action_id);
   FETCH csr_magtape_params
   INTO  l_TEST_EFILE,
     l_business_group_id,
     l_FINANCIAL_YEAR,
     l_legal_employer,
     l_start_date,
     l_end_date,
     l_EFFECTIVE_DATE;
   CLOSE csr_magtape_params;

   IF l_TEST_EFILE = 'Y' THEN
       OPEN  csr_lookup_code(l_financial_year);
       FETCH csr_lookup_code
       INTO  l_financial_year_code;
       CLOSE csr_lookup_code;

   /* Bug 6470581 - Added the Payment Summary Type parameter for Datafile call */

    l_legislative_param := 'BUSINESS_GROUP_ID='      || l_business_group_id         ||' '
                || 'FINANCIAL_YEAR='         || l_FINANCIAL_YEAR            ||' '
                || 'REGISTERED_EMPLOYER='    || l_legal_employer            ||' '
                || 'IS_TESTING='             || 'Y'                         ||' '
                || 'ARCHIVE_PAYROLL_ACTION=' || to_char(p_payroll_action_id)||' '
                || 'END_DATE='               || to_char(l_end_date,'YYYY/MM/DD HH:MI:SS')||' '
                || 'PAYMENT_SUMMARY_TYPE='   || 'O'; /* Bug 6470581 */

     ps_request_id := fnd_request.submit_request
     ('PAY',
      'PYAUPSDF',
      null,
      null,
      false,
      'ARCHIVE',
      'AU_PS_DATA_FILE_VAL',                 -- Report_format of magtape process
      'AU',
      to_char(l_start_date,'YYYY/MM/DD HH:MI:SS'),
      to_char(l_EFFECTIVE_DATE,'YYYY/MM/DD HH:MI:SS'),
      'REPORT',
      l_business_group_id,
      null,
      null,
      l_legal_employer,
      l_FINANCIAL_YEAR_code,
      'END_DATE='||to_char(l_end_date,'YYYY/MM/DD HH:MI:SS'),
      'Y',                                   -- IS_TESTING Parameter
      'O',                                      /* Bug 6470581 */
      'AU_PAYMENT_SUMMARY',                     /* Bug 6470581 */
      to_number(p_payroll_action_id),        -- Archive_PAyroll_Action
      l_legislative_param                    -- Legislative parameters
     );


    END IF;


end spawn_data_file;

/*bug8711855 - The function adjusts Lump Sum E balance by less than 400 PTD value*/
function get_lumpsumE_value
     (p_registered_employer     in   NUMBER
     ,p_assignment_id           in   pay_assignment_actions.ASSIGNMENT_ID%type
     ,p_year_start              in   DATE
     ,p_year_end                in   DATE
     ,p_lump_sum_E_ptd_tab in pay_balance_pkg.t_balance_value_tab
     ,p_lump_sum_E_ytd in number
     ,p_adj_lump_sum_E_ptd out nocopy number
     ,p_adj_lump_sum_pre_tax out nocopy NUMBER) return number IS

   /* Bug No: 3603495 - Performance Fix in c_get_pay_effective_date - Introduced per_assignments_f and its joins */
   /* Bug 4363057 - Cursor has been modified so that the Lump Sum E Payments given to previous legal employers
                   can be taken into account while calculating payment summary gross.*/
   /*Bug 8441044 - Cursor is modified to include action types 'B' and 'I', so that when Lump Sum E payments are
                   fed through Balance adjustment and Balance initialization processes,Lump Sum E Payments are
                   taken into account for calculating payment summary gross */
   CURSOR c_get_pay_effective_date(c_assignment_id   pay_assignment_actions.assignment_id%type
                                                     ,c_year_start              in   DATE
                                                     ,c_year_end                in   DATE)
   IS
    select /*+ USE_NL(ptp) */      -- Bug 4925650
    max(paa.assignment_action_id) -- Bug: 3095919, Bug 2610141
    from    per_assignments_f   paf,
                pay_payroll_Actions ppa,
            pay_assignment_Actions paa,
        per_time_periods ptp
    where ppa.payroll_Action_id = paa.payroll_Action_id
        and paa.assignment_id = c_assignment_id
                and paf.assignment_id = paa.assignment_id
        and paa.tax_unit_id = p_registered_employer --2610141
        and action_type in ('Q','R','V','B','I')
        AND (paa.source_action_id IS NULL
                     OR (paa.source_action_id IS NOT NULL AND ppa.run_type_id IS NULL)) /*Bug 4363057*/
        and ppa.effective_date between c_year_start and c_year_end /*bug 4063321*/
/* Bug# 5377624 */
--        AND ptp.time_period_id = ppa.time_period_id
          and  ppa.payroll_id       = ptp.payroll_id
          and ppa.payroll_id=paf.payroll_id  /* Added for bug 5371102 , query 1 */
           and ppa.date_earned between ptp.start_date and ptp.end_date
/* Bug# 5377624 */
          and ppa.date_earned between paf.effective_start_date and paf.effective_end_date
        GROUP BY ptp.time_period_id;

  l_procedure           constant varchar2(80) := 'get_lumpsumE_value';
  l_retro_lse_ytd number := 0;
  v_lump_sum_E_ytd number;
  v_lump_sum_E_ptd number;
  l_assignment_action_id pay_assignment_actions.assignment_action_id%type;
  v_adj_lump_sum_E_ptd number := 0;
  v_adj_lump_sum_pre_tax NUMBER := 0;        /* Bug 9190980 */
  p_result_lsE_ptd_table pay_balance_pkg.t_detailed_bal_out_tab;

begin
  g_debug :=  hr_utility.debug_enabled;

  if g_debug then
     hr_utility.set_location('Entering ' || l_procedure, 1);
     hr_utility.trace('p_assignment_id......= ' || p_assignment_id);
     hr_utility.trace('p_lump_sum_E_ytd......= ' || p_lump_sum_E_ytd);

  end if;

  v_lump_sum_E_ytd := p_lump_sum_E_ytd;

               OPEN c_get_pay_effective_date(p_assignment_id, p_year_start, p_year_end) ;
               LOOP
                  fetch  c_get_pay_effective_date into l_assignment_action_id; --2610141
                  EXIT WHEN c_get_pay_effective_date%NOTFOUND;

                   p_result_lsE_ptd_table.delete;
                   v_lump_sum_E_ptd := 0;

                   p_context_table(1).tax_unit_id := p_registered_employer;
                   --
                   pay_balance_pkg.get_value
                   (p_assignment_action_id     => l_assignment_action_id
                   ,p_defined_balance_lst  => p_lump_sum_E_ptd_tab
                   ,p_context_lst      => p_context_table
                   ,p_output_table         => p_result_lsE_ptd_table
                   );


                   v_lump_sum_E_ptd :=  p_result_lsE_ptd_table(1).balance_value
                                      + p_result_lsE_ptd_table(2).balance_value
                                      + p_result_lsE_ptd_table(3).balance_value
                                      - p_result_lsE_ptd_table(4).balance_value;


                  /* Bug: 3095919  If single lump sum E payment is less than $400 then the amount is included in gross earnings.
                           If single lump sum E payment is greater than $400 then it is included in Lump sum E payments.
                     bug8711855 -  v_adj_lump_sum_E_ptd is only used in pay_au_rec_det_paysum_mode.Adjust_lumpsum_E_payments.
		     Bug 9190980 - Added v_adj_lump_sum_pre_tax variable to store the value of Retro GT12 Prepayment < $ 400
		                   and the value will be used in pay_au_rec_det_paysum_mode package.
                  */

                       if v_lump_sum_E_ptd < 400 then
                          v_lump_sum_E_ytd       := v_lump_sum_E_ytd - v_lump_sum_E_ptd;
                          v_adj_lump_sum_E_ptd   := v_adj_lump_sum_E_ptd   + v_lump_sum_E_ptd + p_result_lsE_ptd_table(4).balance_value ; /* Start 9190980 */
                          v_adj_lump_sum_pre_tax := v_adj_lump_sum_pre_tax + p_result_lsE_ptd_table(4).balance_value;   /* End 9190980 */
                      end if;

               END LOOP;
               CLOSE c_get_pay_effective_date;

         p_adj_lump_sum_E_ptd   := v_adj_lump_sum_E_ptd  ;
         p_adj_lump_sum_pre_tax := v_adj_lump_sum_pre_tax;

  if g_debug then
    hr_utility.trace('out v_adj_lump_sum_E_ptd ........ =' || p_adj_lump_sum_E_ptd);
    hr_utility.trace('out v_adj_lump_sum_pre_tax .......=' || p_adj_lump_sum_pre_tax);
    hr_utility.trace('return v_lump_sum_E_ytd ........ =' || v_lump_sum_E_ytd);
    hr_utility.set_location('Leaving  '|| l_procedure,999);
  end if;

     return v_lump_sum_E_ytd;

exception
  when others then
    if g_debug then
      hr_utility.set_location(l_procedure,000);
    end if;
    raise;

end;

end pay_au_payment_summary;

/
