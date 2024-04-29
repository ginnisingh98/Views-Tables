--------------------------------------------------------
--  DDL for Package Body PAY_P45_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_P45_PKG" as
/* $Header: payrp45.pkb 120.29.12010000.37 2010/03/31 07:36:21 dwkrishn ship $ */
/*===========================================================================+
|               Copyright (c) 1993 Oracle Corporation                       |
|                  Redwood Shores, California, USA                          |
|                       All rights reserved.                                |
+============================================================================
 Name
    PAY_P45_PKG
  Purpose
    Supports the P45 form (PAYWSR45) called from the form PAYGBTAX.
    This is a UK Specific payroll form/package.
  Notes

  History
  07-AUG-94  P.Shergil        40.0  Date Created.
  29-AUG-94  H.Minton         40.1  Added Function to get the formula id.
  04-OCT-94  R.Fine           40.2  Renamed package to start PAY_
  07-OCT-94  A.Snell          40.3  Fixed cursors c_act and c_query to access
                                    info date effectively
  04-NOV-94  A.Snell          40.4  Fix to problem where leaver had restarted
                                    and hence had 2 periods of service
  24-NOV-94  R.Fine           40.5  Suppressed index on business_group_id
  15-DEC-94  A.Snell          40.6  Fix to Taxable Pay subquery which wasn't
                                    correlated to the assignment_id
  04-JAN-94  A.Snell          40.7  Fix to identify the correct tax details
                                    for the payroll the assignment is on
                                    using the tax reference on the payroll scl
  05-MAY-95  M.Roychowdhury   40.8  Changed to use explicit cursors
                                    and added error message for missing formula
  26-JUL-96  C.Barbieri       40.9  Changed dates definition for Y2000.
  13-NOV-96  T.Inekuku        40.12 Cleared variables to remove previously
                                    assigned value.
  11-DEC-96  C.Barbieri       40.13 Bug: 429163. Changed employer_addr cursor.
                                    The parameter ASSIGNMENT_ID is now
                                    L_ASSIGNMENT_ID
  28-AUG-97  A.Mills          110.1 Altered date format for NLS compliance
  24-SEP-98  A.Parkes         110.2 659488 Changes to get_ff_data: c_ptp now
                                    uses last_standard_process_date in
                                    preference to session_date, and c_act now
                                    searches for PAYE or Taxable Pay balances
  27-APR-98                   115.0 Initial checkin using uppsa from
                                    revision 110.1
  24-SEP-98                   115.1 Changes to get_ff_data : c_ptpt now uses
                                    last_standard_process_date in preference to  session_date, and c_act now searches for
                                    PAYE or Taxable Pay Balances
  08-APR-99  djeng            115.2 Flexi date/multi radix compliance
  08-APR-99  djeng            115.3 Flex date compliance
  13-JUL-99  S.Robinson       115.4 Corrected canonical_to_date references
  08-MAR-2000 J. Moyano       115.5 Function get_student_loan_flag added.
  14-AUG-2000 A.Parkes        115.6 Added P45 Archiver hooks and globals.
                                    Corrected flexdate usage in
                                    get_student_loan_flag function (1531071)
  17-JAN-2001 A.Parkes        115.7 Changed spawn_reports to check for errored
                                    asg actions and to cater for Defer
                                    Printing parameter.
  09-FEB-2001 S.Robinson      115.8 Add pop_term_asg_lvl_from_archive and
                                    pop_term_pact_lvl_from_archive, called
                                    from P45 Form.
  19-FEB-2001 A.Parkes        115.9 Added get_report_request_error func.
  26-FEB-2001 A.Parkes       115.10 Altered EDI validation for pay and tax.
  06-MAR-2001 A.Parkes       115.11 Added missing field EDI validation.
  28-MAR-2001 A.Parkes       115.12 842703 removed restriction with
                                    x_last_process_date in c_act in get_ff_data
  29-MAR-2001 A.Parkes       115.13 842703 added restriction with new param
                                    X_TRANSFER_DATE in c_act in get_ff_data
  26-APR-2001 S.Robinson     115.14 Amendments to pop_term_asg_from_archive
                                    and pop_term_pact_from_archive.
  15-NOV-2001 K.Thampan      115.15 1926604 Added a condition in where clause
                                    of cursor csr_assignments not to pick
                                    any assignment with tax code NI
  02-JAN-2002 S.Robinson     115.18 2149144. Changed EDI validation for
                                    forenames from FULL_EDI to EDI_SURNAME.
  17-FEB-2002 S.Robinson     115.19 2228063. Change to
                                    pop_term_asg_from_archive to populate
                                    pay and tax values correctly.
  26-FEB-2002 K.Thampan      115.20 Bug 2233521 - add X_STUDENT_LOAN_FLAG param
                                    to procedure pop_term_asg_from_archive and
                                    change the format of date_of_leaving_yy to
                                    be 4 chars long.
  01-MAR-2002 S.Robinson     115.21 Change for Positive Offsets, retrieve
                                    period number for archiving to use Payroll
                                    Actions date earned instead of effective
                                    date.
  01-MAR-2002 S.Robinson     115.22 Change for Positive Offsets. Ensure that
                                    assignments are not picked up before
                                    the regular payment date of the last
                                    period.
  14-MAR-2002 S.Robinson     115.23 utf8 change on person_address.
  21-MAR-2002 S.Robinson     115.24 Change floor statements to trunc in
                                    pop_term_asg_from_archive so negative
                                    values retieved from archive correctly.
                                    Bug 2264307.
  19-JUL-2002 R.Makhija      115.25 Changed archive_code procedure to look
                                    at PAYE element run results for
                                    statutory details first
  22-AUG-2002 M.Ahmad        115.26 Concatenated middle_name with 12/26/2007 to
                                    display the middle name with the first name
                                    in the report.Bug 1690902.
  11-SEP-2002 G.Butler       115.27 Bug 2264261 - truncate employer name and
                                     address retrieved from hr_organization_
                                     information in get_employer_address
                                     to maximum limits set on Org Developer DF.
                                     Set employer name and
                                     address to default to null instead of 'B'
                                     if archived name and address are null in
                                     pop_term_pact_from_archive. Added
                                     ORDERED optimiser hint into csr_assignments
                                     in arch_act_creation procedure
  12-Dec-2002 A.Mills       115.28   Added nocopy via utility.
  31-MAR-2003 ASENGAR       115.29   2702298. Changed EDI validation for
                                     Address lines from FULL_EDI to EDI_SURNAME.
  21-JUL-2003 A.Mills       115.30   Aggregated PAYE changes. Rewrite of
                                     arch_act_creation for new design.
  18-SEP-2003 A.Mills       115.31   3147030. Fixed date issues in get_ff
                                     _data and get_data functions.
  14-OCT-2003 A.Mills       115.32   3096225. Do not return assignment end
                                     dates if not terminated (c_query cursor)
  12-DEC-2003 ASENGAR       115.33   BUG 3221422 Changed Query of CURSOR c_act of procedure
                                     get_ff_data for improving performance
  07-JAN-2004 A.Mills       115.34   3324547. Changed the get_ff_data function,
                                     introduced cursors get_latest_id and
                                     taxable_or_paye_exists. Also converted
                                     asg effective end date to canonical.
  27-JAN-2004 A.Mills       115.35   3396687. Added Suspended Assignments to check
                                     of last assignment before termination.
  09-FEB-2004  A.Mills       115.36   3433915. Also added suspended assignments to
                                     future_active_exists to remedy issue.
  17-FEB-2004 A.Mills        115.37  Change to payment_made function. Plus use
                                     fnd_file calls to place non-p45s in log.
                                     3452081.
  03-MAR-2004 A.Mills        115.38  3473274. For 1st period of new starter, the
                                     c_act query raises exception, handle this in
                                     code.
  07-JUN-2004 A.Mills        115.39  Performance enhancements, added range_person_on
                                     and allowed range_code to restrict by payroll.
  01-JUL-2004 K.Thampan      115.40  3681719 - fix cursor csr_transfer
  14-JUL-2004 A.Mills        115.41  3765485. Fix for positive offset payrolls.
  31-DEC-2004 K.Thampan      115.42  4055003. Fix procedure p45_existing_actions.
  14-JAN-2005 K.Thampan      115.43  4120227. Fix function p45_existing_actions.
  22-FEB-2005 A.Tiwari       115.44  4136320. Cursor C_act changed to query only within the TY
                                     And payroll_details are queried for the latest assact
  24-FEB-2005 K.Thampan      115.45  4169681. Performance fix.
  26-APR-2005 K.Thampan      115.46  1934837. Archive COUNTRY
  28-JUL-2005 K.Thampan      115.47  4522272. Change cursor csr_max_run_result to
                                     only query within the TY.
  26-AUG-2005 K.Thampan      115.48  4545963. Amend the archive process to default
                                     the tax details with value from PAYE element
                                     entries before checking/fetching the latest
                                     PAYE run results.
  08-SEP-2005 K.Thampan      115.49  Amended archive process procedure to use the same
                                     procedure as EOY when fetching tax details.  Also
                                     amend procedure get_ff_data to fetch master
                                     assignment_action_id when get_lastest_id return
                                     nothing.
  12-SEP-2005 K.Thampan      115.50  4595939. Change get_tax_details to fetch the
                                     latest paye details.
  16-SEP-2005 K.Thampan      115.51  4553334. Amended cursor agg_latest_action.
  03-OCT-2005 T.Kumar      115.52  GSCC Corrections : Bug 4646368
  14-OCT-2005 npershad       115.53  4428406. Removed reference to redundant index
                                     PAY_ASSIGNMENT_ACTIONS_N1 used in hints.
  23-DEC-2005 K.Thampan      115.54  4904738. Amended cursor csr_run_result not
                                     to multiply prev pay and prev tax by 100.
  30-JAN-2006 K.Thampan      115.55  4774622. Fix performance bug.
  14-MAR-2006 K.Thampan      115.56  5042824. Fix performance bug.
  23-MAY-2006 K.Thampan      115.57  5202965. Fix performance bug.
                             115.58  Amend the action creation cursor.
  30-AUG-2006 K.Thampan      115.59  Amend procedure arch_act_creation to
                                     only check for a final payment for the last
                                     assignment to be ended (aggreated).
  04-SEP-2006 ajeyam         115.61  New proc/functions created to find whether P45
                                     issued (or) not for the given assignment
                                     Bug 5144323
  05-SEP-2006 ajeyam         115.62  Parameters added/changed for new report-
                                     show the p45 issued for act asgs 5144323
  13-OCT-2006 rmakhija       115.63  Bug 5478073, changed get_ff_data to
                                     return dummy last assignment action id if
                                     it is in pervious tax year and added
                                     csr_get_term_period_no to archive
                                     and report termination period no in this
                                     case.
                                     Updated csr_range_format_param to get
                                     value for RANGE_PERSON_ID parameter only.
                                     Changed c_act cursor in get_ff_data to also
                                     fetch payroll actions that are after end of
                                     the tax year in which assignemnt has been
                                     terminated.
                                     Updated get_p45_agg_asg_action_id to add
                                     another check to return only those P45
                                     action which belongs to an assignment that
                                     exists in the aggregation period and is
                                     terminated on same PAYE Ref as the given
                                     assignment.
                                     Updated get_p45_asg_action_id to ignore
                                     transfer P45 actions.
                                     Updated cursor agg_latest_action in
                                     get_ff_data to get aggregated
                                     final action from the aggregation period
                                     only and also added the check to limit
                                     select to aggregated assignments that
                                     share same continuous active period of
                                     employment.
                                     Replaced manual_issue_exists and
                                     p45_existing_action functions with a
                                     call to return_p45_issued_flag function
                                     in arch_act_creation for non-transfer
                                     cases.
                                     Updated csr_person_agg_asg in arcs_act_creation
                                     to fetch only those assignment that share
                                     continuous active period of employment and
                                     exist within the same aggregation period
                                     and  replace check to ensure the assignments
                                     that had been on the same PAYE Ref at some
                                     point in time with a check to ensure the same
                                     at the time of termination.
                                     Updated arch_act_creation to archive ids
                                     of included assignments
                                     Updated archive_code to archive final payment
                                     action id.
                                     Updated archive_code to get balances as at
                                     latest action regardless of LSP or final close.
  06-NOV-2006 rmakhija       115.64  Bug 5144323, Updated get_p45_asg_action_id to
                                     ignore transfer P45 actions
  06-NOV-2006 rmakhija       115.65  Fixed dbdrv line
  07-NOV-2006 rmakhija       115.66  Updated aggregation period check subquery in
                                     csr_person_agg_asg cursor
  21-NOV-2006 ajeyam         115.67  Code added to check all the transfer payroll
                                     actions when we return P45 payroll action.
                                     In get_p45_asg_action_id procedure.
  03-JAN-2007 rmakhija       115.68  Bug 5743581, added to_char to
                                     csr_get_final_payment cursor in
                                     get_p45_agg_asg_action_id
  07-Feb-2007 rmakhija       115.69  Bug 5869769, removed sql to get final
                                     payment date in get_p45_agg_asg_action_id
                                     and updated agg_latest_action cursor to
                                     imrove performance.
  09-Mar-2007 rmakhija       115.69  Bug 5923552, Changed csr_all_assignments
                                     and csr_all_assignments_range to use
                                     assignment's effective end date instead
                                     of actual termination date to ensure
                                     tax ref transfers are handled correctly
  25-Sep-2007 rlingama       115.70  Bug 5671777-2 Update pay_p45_pkg.get_p45_agg_asg_action_id
                                     procedure to first look for a P45 for another assignment
                                     that included the given assignment using
                                     X_P45_INCLUDED_ASSIGNMENT user entity.
                                     Bug 5671777-11 validation added in the p45 process to
                                     ensure it is run for one tax year at a time
  16-Nov-2007 parusia        115.71  Archived 2 additional items - X_DATE_OF_BIRTH
                                     and X_SEX. Changed range_cursor to throw unhandled
                                     exception when TestSubmssion is Yes but TestID
                                     is not provided For P45PT1. Bug 6345375.
 26-Dec-2007 apmishra        115.72 Added the fix for the first name not to appear with a
                                    space concated with the middle name Bug:6710229
				     EOY 07-08 P45 PT1: P45PT1 PROCESS ERRORED OUT IF THE MIDDLE NAME IS PROVIDED.
 4-Jan-2007  parusia         115.73 Archive middle_name separately from first_name.
                                    Bug 6710229
 16-Jan-2007  rlingama       115.75 Modified csr_get_paye_ref to csr_get_p45_another_asg in
                                    get_p45_agg_asg_action_id cursor
 28-Feb-2007  pbalu          115.76 Added to_char in csr_get_p45_another_asg in
				    get_p45_agg_asg_action_id cursor.
 31-Mar-2008  rlingama       115.77 Bug 6900025 Modified max effective end date of cursor csr_paye_details to
                                    final process date in get_tax_details procedure to report correct tax code.
 01-Apr-2008  rlingama       115.78 Bug 6900025 Added final process date check in get_tax_details procedure
 03-Apr-2008  rlingama       115.79 Bug 6900025 Modified pact.effective_date condtion in get_tax_details procedure to
                                    fetch PAYE details from run results instead of element entries.
                                    Reverted the fix did in 115.77 and 78 versions.
 02-May-2008  rlingama       115.80 Bug 6900025 modified to_date function to add_months in get_tax_details procedure
 14-May-2008  rlingama       115.81 Bug 7028893.Added function PAYE_RETURN_P45_ISSUED_FLAG.
 15-Sep-2008  rlingama       115.82 Bug 7410767.Modified the p_eff_date date check in get_tax_detail procedure.
 19-Nov-2008  vijranga       115.88 Incorporated the new parameter EDI_VER to modify the already checked in code for
                                    EDI Validations at the Archival level itself. Added one missed 'Tax code missing'  validation
                                    and changed the parameters for DOB validation call.
 21-Nov-2008  dwkrishn       115.89 Performance fix for Cursor csr_range_assignments.Used Not Exists in place of Outer Join
 26-Nov-2008  vijranga       115.90 Incorporated review comments.
 27-Nov-2008  vijranga       115.91 Bug #7433580. Incorporated INL team review comments for newly added error messages.
 21-OCT-2008  rlingama       115.92 P45 A4 2008-09 Changes.Bug 7261906
 07-Jan-2009  namgoyal       115.93 Bug 7281023: modified cursor csr_get_term_period_no to report
                                    correct period number if P45 balance is zero.
 08-Jan-2009  namgoyal       115.94 Bug 7281023: Added '=' operator in cursor csr_get_term_period_no.
 15-Feb-2009  dwkrishn       115.96 Bug 8254291: Added Procedure populate_run_msg to insert error messages
                                    in pay_message_lines
 19-Feb-2009  dwkrishn       115.97 Bug 8254291: Made the process continue even if the process errors
                                    out noting each error EDI error messages, finally error the process.
 26-Feb-2009  rlingama       115.98 Bug 8275145 : P45 A4 Laser 4 part changes 2008-09
 12-Mar-2009  rlingama       115.99 Bug 8275145 : P45 A4 Continuous report changes 2008-09
 03-Apr-2009  dwkrishn       115.100 Bug 8282187 : Few P45 EDI validations commented as it was they
						   are not to be performed during archive
 04-May-2009 jvaradra        115.101  Bug 7601088 Added function PAYE_SYNC_P45_ISSUED_FLAG
 14-May-2009 dwkrishn        115.102  Bug 8464343 fetch week month type with payroll id if last action is -9999
 08-Jun-2009 dwkrishn        115.103  Bug 8366684 modified agg_latest_action for performance.Removed use_nl
                                      to enable optimizer to choose hash join if needed.
 22-06-2009  dwkrishn        115.104  Bug:8566920 Added hints to cursor csr_range_assignments.Issue occured when
				      DB upgraded from 9i to 10gR2
 30-8-2009   dwkrishn        115.105  Bug:8537504 assignment_number validation handled in edi_movded6_asg
 16-11-2009  jvaradra        115.106  Bug:9071978 End of time needs to be considered when FPD is NULL
 03-11-2009  rlingama        115.107  Bug 9170440 Changed l_printer_style variable declaration.
 08-02-2010  rlingama        115.108  Bug 9347169 Modified the code to ensure, fecth address based on the assignment
                                      end date if address not exists on sysdate.
 23-01-2010  dwkrishn        115.109  update the payroll_id in the pay_payroll_actions table.
 04-03-2010  rlingama        115.110  Bug:8370481 Modifed the Total pay/tax to date and Pay/Tax in this Employment exceeds
                                      999999.99 to 999999999.99.
 25-03-2010  dwkrishn        115.111  Bug 9292092 Modified agg_latest_action. Introduced an inline view instead of a
				      corelated subquery
==============================================================================*/


-- Globals
g_package    CONSTANT VARCHAR2(20):= 'pay_p45_pkg.';
g_asg_creation_cache_populated  BOOLEAN := FALSE;
g_asg_process_cache_populated   BOOLEAN := FALSE;
g_fnd_rep_request_msg  VARCHAR2(2000):=' ';
-- SRS Params
g_payroll_id                    pay_payrolls_f.payroll_id%TYPE;
g_start_date                    DATE;
g_effective_date                DATE;
g_end_date                      DATE;
g_business_group_id             hr_organization_units.business_group_id%TYPE;
g_do_edi_validation             BOOLEAN;
g_tax_ref                       VARCHAR2(20);
g_edi_ver                       VARCHAR2(10);
-- User Entity Ids
g_address_line1_eid             ff_user_entities.user_entity_id%TYPE;
g_address_line2_eid             ff_user_entities.user_entity_id%TYPE;
g_address_line3_eid             ff_user_entities.user_entity_id%TYPE;
g_assignment_number_eid         ff_user_entities.user_entity_id%TYPE;
g_county_eid                    ff_user_entities.user_entity_id%TYPE;
g_deceased_flag_eid             ff_user_entities.user_entity_id%TYPE;
g_first_name_eid                ff_user_entities.user_entity_id%TYPE;
g_middle_name_eid               ff_user_entities.user_entity_id%TYPE; /*Bug 6710229*/
g_issue_date_eid                ff_user_entities.user_entity_id%TYPE;
g_last_name_eid                 ff_user_entities.user_entity_id%TYPE;
g_month_number_eid              ff_user_entities.user_entity_id%TYPE;
g_ni_number_eid                 ff_user_entities.user_entity_id%TYPE;
g_organization_name_eid         ff_user_entities.user_entity_id%TYPE;
g_payroll_id_eid                ff_user_entities.user_entity_id%TYPE;
g_postal_code_eid               ff_user_entities.user_entity_id%TYPE;
g_prev_tax_paid_eid             ff_user_entities.user_entity_id%TYPE;
g_prev_taxable_pay_eid          ff_user_entities.user_entity_id%TYPE;
g_student_loan_flag_eid         ff_user_entities.user_entity_id%TYPE;
g_aggregated_paye_flag_eid      ff_user_entities.user_entity_id%TYPE;
g_period_of_service_eid         ff_user_entities.user_entity_id%TYPE;
g_effective_end_date_eid        ff_user_entities.user_entity_id%TYPE;
g_tax_code_eid                  ff_user_entities.user_entity_id%TYPE;
g_tax_paid_eid                  ff_user_entities.user_entity_id%TYPE;
g_tax_ref_transfer_eid          ff_user_entities.user_entity_id%TYPE;
g_taxable_pay_eid               ff_user_entities.user_entity_id%TYPE;
g_termination_date_eid          ff_user_entities.user_entity_id%TYPE;
g_title_eid                     ff_user_entities.user_entity_id%TYPE;
g_town_or_city_eid              ff_user_entities.user_entity_id%TYPE;
g_w1_m1_indicator_eid           ff_user_entities.user_entity_id%TYPE;
g_week_number_eid               ff_user_entities.user_entity_id%TYPE;
g_country_eid                   ff_user_entities.user_entity_id%TYPE;
g_p45_final_action              ff_user_entities.user_entity_id%TYPE;
g_p45_inc_assignment            ff_user_entities.user_entity_id%TYPE;
-- Added for P45PT1. Bug 6345375
g_date_of_birth_eid             ff_user_entities.user_entity_id%TYPE;
g_sex_eid                       ff_user_entities.user_entity_id%TYPE;
-- Seed data IDs
g_paye_details_id           pay_element_types_f.element_type_id%TYPE;
--
FUNCTION get_report_request_error RETURN VARCHAR2 IS
BEGIN
  RETURN g_fnd_rep_request_msg;
END get_report_request_error;
--
--------------------------------------------------------------------------
-- FUNCTION override_date
-- DESCRIPTION Get the override date if one exists
--------------------------------------------------------------------------
FUNCTION override_date(p_assignment_id in number) RETURN DATE IS
--
  l_override_date date;
  cursor csr_override_date (c_assignment_id in number) is
  select fnd_date.canonical_to_date(aei.aei_information4)
  from per_assignment_extra_info aei
  where aei.assignment_id = c_assignment_id
  and aei.information_type = 'GB_P45';
--
BEGIN
  open csr_override_date(p_assignment_id);
  fetch csr_override_date into l_override_date;
  if csr_override_date%NOTFOUND then
     l_override_date := null;
  end if;
  close csr_override_date;
  --
RETURN l_override_date;
END override_date;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   get_p45_formula_id                                                   --
-- Purpose                                                                 --
--   this function finds the formula id for the validation of the PAYE     --
--   tax_code element entry value.
-----------------------------------------------------------------------------
--
FUNCTION get_p45_formula_id RETURN NUMBER IS

  cursor c_formula is
    select f.FORMULA_ID
    from   ff_formulas_f f,
           ff_formula_types t
    where  t.FORMULA_TYPE_ID   = f.FORMULA_TYPE_ID
      and    f.FORMULA_NAME      = 'P45';
--
  l_formula_id    NUMBER;
--
BEGIN
--
  open c_formula;
  fetch c_formula into l_formula_id;
  if c_formula%notfound then
  --
    close c_formula;
    --
    fnd_message.set_name ('FF', 'FFX03A_FORMULA_NOT_FOUND');
    fnd_message.set_token ('1','P45');
    fnd_message.raise_error;
    --
  end if;
  close c_formula;
  --
  RETURN l_formula_id;
--
END get_p45_formula_id;
--
-----------------------------------------------------------------------------
--
-- Name                                                                    --
--   get_student_loan_flag
-- Purpose                                                                 --
--   this function finds if the employee has a Student Loan effective at   --
--   the time employment ceases. Returns 'Y' if 'End Date' is not prior    --
--   or equal to the termination date.
-----------------------------------------------------------------------------
--
FUNCTION get_student_loan_flag (p_assignment_id    IN NUMBER,
                                p_termination_date IN DATE,
                                p_session_date     IN DATE)
                                RETURN VARCHAR2
IS
  --
  cursor csr_getdate (x_assignment_id       NUMBER,
                      x_termination_date    DATE)    IS
  SELECT peev.screen_entry_value
  FROM pay_element_types_f   pet,
       pay_element_links_f   pel,
       pay_element_entries_f pee,
       pay_input_values_f    piv,
       pay_element_entry_values_f peev
  WHERE pee.assignment_id = x_assignment_id
  AND   upper(pet.element_name) = 'STUDENT LOAN'
  AND   upper(piv.name) = 'END DATE'
  AND   pet.business_group_id IS NULL
  AND   pet.legislation_code = 'GB'
  AND   pet.element_type_id = pel.element_type_id
  AND   pel.element_link_id = pee.element_link_id
  AND   pet.element_type_id = piv.element_type_id
  AND   piv.input_value_id  = peev.input_value_id
  AND   pee.element_entry_id  = peev.element_entry_id
  AND   x_termination_date BETWEEN pet.effective_start_date
                               AND pet.effective_end_date
  AND   x_termination_date BETWEEN pel.effective_start_date
                               AND pel.effective_end_date
  AND   x_termination_date BETWEEN pee.effective_start_date
                               AND pee.effective_end_date
  AND   x_termination_date BETWEEN piv.effective_start_date
                               AND piv.effective_end_date
  AND   x_termination_date BETWEEN peev.effective_start_date
                               AND peev.effective_end_date;
  --
  l_end_date        pay_element_entry_values_f.screen_entry_value%TYPE;
  l_flag            VARCHAR2(1);
  l_term_date       DATE;
  l_found           BOOLEAN;
  --
BEGIN
  --
  --
  l_flag := 'N';
  --
  l_term_date := nvl(p_termination_date,p_session_date);
  OPEN csr_getdate(p_assignment_id, l_term_date);
  FETCH csr_getdate INTO l_end_date;
  l_found := csr_getdate%found;
  CLOSE csr_getdate;
  IF l_found THEN
    IF ((l_end_date IS NULL) OR
        (fnd_date.canonical_to_date(l_end_date) > l_term_date)) THEN
      l_flag := 'Y';
      hr_utility.trace('changing flag to: ' || l_flag);
      hr_utility.trace('end date is <' || l_end_date || '>');
    END IF;
  ELSE
    hr_utility.trace('no data found...');
    NULL;
  END IF;
  hr_utility.trace('leaving function get_student_loan_flag...');
  --
  --
  RETURN l_flag;
--
END get_student_loan_flag;

procedure person_address(X_PERSON_ID            in number,
                         X_SESSION_DATE         in date,
                         X_ADDRESS_LINE1        in out nocopy varchar2,
                         X_ADDRESS_LINE2        in out nocopy varchar2,
                         X_ADDRESS_LINE3        in out nocopy varchar2,
                         X_TOWN_OR_CITY         in out nocopy varchar2,
                         X_REGION_1             in out nocopy varchar2,
                         X_COUNTRY              in out nocopy varchar2,
                         X_POSTAL_CODE          in out nocopy varchar2,
			 X_ASSIGNMENT_END_DATE  in date) is -- added for bug 9347169

-- Bug 9347169 : Modified the cursor to fetch address based on the effective date.
cursor c_addr (p_effective_date in date) is select addr.ADDRESS_LINE1,
                        addr.ADDRESS_LINE2,
                        addr.ADDRESS_LINE3,
                        addr.TOWN_OR_CITY,
                        addr.REGION_1,
                        addr.COUNTRY,
                        addr.POSTAL_CODE
                 from per_addresses addr
                 where addr.PERSON_ID = X_PERSON_ID
                 and   addr.PRIMARY_FLAG = 'Y'
                 and   p_effective_date between
                       addr.DATE_FROM and
                       nvl(addr.DATE_TO,fnd_date.canonical_to_date('4712/12/31'));

cursor get_country(p_code in varchar2) is
select ftv.territory_short_name
from   fnd_territories_vl ftv
where  ftv.territory_code = p_code;

       l_addr c_addr%rowtype;
       l_found boolean;
       l_county per_addresses.region_1%type /*varchar2(30)*/;

begin
           /* Clear the variables, as if no future assignment is made to them,
               they may hold the previous value assigned
           */
     X_ADDRESS_LINE1 := '';
     X_ADDRESS_LINE2 := '';
     X_ADDRESS_LINE3 := '';
     X_TOWN_OR_CITY  := '';
     X_COUNTRY       := '';
     X_POSTAL_CODE   := '';
     X_REGION_1      := '';
     open c_addr (X_SESSION_DATE);
     fetch c_addr into l_addr;
     l_found := c_addr%found;
     close c_addr;
     -- Start bug 9347169
     -- If address not exists on sysdate, fecth address based on assignment end date.
     if not l_found then
        open c_addr(X_ASSIGNMENT_END_DATE);
        fetch c_addr into l_addr;
        l_found := c_addr%found;
        close c_addr;
     end if;
     -- End bug 9347169
     if l_found then
        X_ADDRESS_LINE1 := l_addr.ADDRESS_LINE1;
        X_ADDRESS_LINE2 := l_addr.ADDRESS_LINE2;
        X_ADDRESS_LINE3 := l_addr.ADDRESS_LINE3;
        X_TOWN_OR_CITY  := l_addr.TOWN_OR_CITY;
        -- X_COUNTRY       := l_addr.COUNTRY;
        X_POSTAL_CODE   := l_addr.POSTAL_CODE;
        l_county        := l_addr.REGION_1;
        open get_country(l_addr.COUNTRY);
        fetch get_country into X_COUNTRY;
        close get_country;
        begin
            SELECT substr(hr.meaning,1,30)
            INTO   X_REGION_1
            FROM HR_LOOKUPS hr
            WHERE hr.LOOKUP_CODE = l_county
            AND   hr.LOOKUP_TYPE = 'GB_COUNTY';
            EXCEPTION WHEN NO_DATA_FOUND THEN
                           null;
        END;
     else
        X_ADDRESS_LINE1 := '';
        X_ADDRESS_LINE2 := '';
        X_ADDRESS_LINE3 := '';
        X_TOWN_OR_CITY  := '';
        X_COUNTRY       := '';
        X_POSTAL_CODE   := '';
        X_REGION_1      := '';
     end if;
end person_address;

-- Fetch tax details
--
procedure get_tax_details(p_assignment_id   in  number,
                          p_paye_details_id in  number,
                          p_paye_id         in  number,
                          p_eff_date        in  date,
                          p_tax_code        out nocopy varchar2,
                          p_tax_basis       out nocopy varchar2,
                          p_prev_pay        out nocopy varchar2,
                          p_prev_tax        out nocopy varchar2)
is
   l_paye_rr_id   number;
   l_paye_details_rr_id number;
   l_effective_date date; -- Bug 6900025 to store date earned value
   l_start_year date; -- Bug 7410767 to store the start of financial year

   -- Bug 6900025 added l_eff_date parameter to check proper financial year for fecting PAYE details.
   CURSOR csr_max_run_result(l_element_id number,l_eff_date date) IS
   SELECT /*+ ORDERED INDEX (assact2 PAY_ASSIGNMENT_ACTIONS_N51,
                             pact PAY_PAYROLL_ACTIONS_PK,
                             r2 PAY_RUN_RESULTS_N50)
            USE_NL(assact2, pact, r2) */
            to_number(substr(max(lpad(assact2.action_sequence,15,'0')||r2.source_type||
                               r2.run_result_id),17))
   FROM    pay_assignment_actions assact2,
           pay_payroll_actions pact,
           pay_run_results r2
   WHERE   assact2.assignment_id = p_assignment_id
   AND     r2.element_type_id+0 = l_element_id
   AND     r2.assignment_action_id = assact2.assignment_action_id
   AND     r2.status IN ('P', 'PA')
   AND     pact.payroll_action_id = assact2.payroll_action_id
   AND     pact.action_type IN ( 'Q','R','B','I')
   AND     assact2.action_status = 'C'
   AND     pact.effective_date between
   -- Bug 6900025 Modified pact.effective_date condtion to fetch PAYE details from run results instead of element entries.
   --         to_date('06-04-'||to_char(fnd_number.canonical_to_number(to_char(p_eff_date,'YYYY'))),'DD-MM-YYYY')
   --     and to_date('05-04-'||to_char(fnd_number.canonical_to_number(to_char(p_eff_date,'YYYY') + 1)),'DD-MM-YYYY')
              to_date('06-04-'||to_char(fnd_number.canonical_to_number(to_char(l_eff_date,'YYYY'))),'DD-MM-YYYY')
          and to_date('05-04-'||to_char(fnd_number.canonical_to_number(to_char(l_eff_date,'YYYY') + 1)),'DD-MM-YYYY')
   AND NOT EXISTS(
               SELECT '1'
               FROM  pay_action_interlocks pai,
                     pay_assignment_actions assact3,
                     pay_payroll_actions pact3
               WHERE   pai.locked_action_id = assact2.assignment_action_id
               AND     pai.locking_action_id = assact3.assignment_action_id
               AND     pact3.payroll_action_id = assact3.payroll_action_id
               AND     pact3.action_type = 'V'
               AND     assact3.action_status = 'C');

  CURSOR csr_run_result(l_run_result_id number,l_element_type_id number) IS
  SELECT  max(decode(name,'Tax Code',result_value,NULL)) tax_code,
          max(decode(name,'Tax Basis',result_value,NULL)) tax_basis,
          to_number(max(decode(name,'Pay Previous',
                fnd_number.canonical_to_number(result_value),NULL)))
                                                                pay_previous,
          to_number(max(decode(name,'Tax Previous',
                fnd_number.canonical_to_number(result_value),NULL)))
                                                                tax_previous
  FROM pay_input_values_f v,
       pay_run_result_values rrv
  WHERE rrv.run_result_id = l_run_result_id
    AND v.input_value_id = rrv.input_value_id
    AND v.element_type_id = l_element_type_id;

  CURSOR  csr_paye_details(p_assignment_id  NUMBER) IS
  SELECT  max(decode(iv.name,'Tax Code',screen_entry_value))     tax_code,
          max(decode(iv.name,'Tax Basis',screen_entry_value))    tax_basis,
          max(decode(iv.name,'Pay Previous',screen_entry_value)) pay_previous,
          max(decode(iv.name,'Tax Previous',screen_entry_value)) tax_previous
  FROM  pay_element_entries_f e,
        pay_element_entry_values_f v,
        pay_input_values_f iv,
        pay_element_links_f link
  WHERE e.assignment_id = p_assignment_id
  AND   link.element_type_id = g_paye_details_id
  AND   e.element_link_id = link.element_link_id
  AND   e.element_entry_id = v.element_entry_id
  AND   iv.input_value_id = v.input_value_id
  AND   e.effective_end_date BETWEEN link.effective_start_date AND link.effective_end_date
  AND   e.effective_end_date BETWEEN iv.effective_start_date AND iv.effective_end_date
  AND   e.effective_end_date BETWEEN v.effective_start_date AND v.effective_end_date
  AND   e.effective_end_date = (select max(e1.effective_end_date)
                                from   pay_element_entries_f  e1,
                                       pay_element_links_f    link1
                                where  link1.element_type_id = g_paye_details_id
                                and    e1.assignment_id = p_assignment_id
                                and    e1.element_link_id = link1.element_link_id);
begin
    hr_utility.set_location('Entering get_tax_details',1);
    hr_utility.trace('Assignemnt ID   : ' || p_assignment_id);
    hr_utility.trace('PAYE Details ID : ' || p_paye_details_id);
    hr_utility.trace('PAYE ID         : ' || p_paye_id);
    hr_utility.trace('Effective Date  : ' || p_eff_date);


    --Bug 6900025 assigning proper date earned to l_effective_date
    --Bug 7410767 Modified the p_eff_date check

    --if fnd_number.canonical_to_number(to_char(p_eff_date,'DD')) >= 06
     --and fnd_number.canonical_to_number(to_char(p_eff_date,'MM')) >= 04 then
     l_start_year := to_date('06/04/'||to_char(p_eff_date,'YYYY'),'DD/MM/YYYY');
     if to_number(p_eff_date - l_start_year) >= 0 then
      l_effective_date := p_eff_date;
    else
       --l_effective_date := to_date(to_char(p_eff_date,'DD-MM')||to_char(fnd_number.canonical_to_number(to_char(p_eff_date,'YYYY') - 1)),'DD-MM-YYYY');
         l_effective_date := add_months( p_eff_date,-12);
    end if;

    hr_utility.trace('l_effective_date value'||l_effective_date);
    open csr_max_run_result(p_paye_id,l_effective_date);
    fetch csr_max_run_result into l_paye_rr_id;
    close csr_max_run_result;

    open csr_max_run_result(p_paye_details_id,l_effective_date);
    fetch csr_max_run_result into l_paye_details_rr_id;
    close csr_max_run_result;

    hr_utility.trace('Fetching run result 1');
    -- 1. First we try to fetch it from the latest PAYE run results
    open csr_run_result(l_paye_rr_id, p_paye_id);
    fetch csr_run_result into p_tax_code,
                              p_tax_basis,
                              p_prev_pay,
                              p_prev_tax;
    close csr_run_result;
    -- 2. Tax code is not found, fetch from the latest PAYE Details run results
    if p_tax_code is null then
       hr_utility.trace('Fetching run result 2');
       open csr_run_result(l_paye_details_rr_id, p_paye_details_id);
       fetch csr_run_result into p_tax_code,
                                 p_tax_basis,
                                 p_prev_pay,
                                 p_prev_tax;
       close csr_run_result;

       -- 3. Still not found, fetch the value from the PAYE
       if p_tax_code is null then
          hr_utility.trace('Fetching run result 3');
             open csr_paye_details(p_assignment_id);
             fetch csr_paye_details into p_tax_code,
                                         p_tax_basis,
                                         p_prev_pay,
                                         p_prev_tax;
	     close csr_paye_details;
       end if;
    end if;
    hr_utility.set_location('Leaving get_tax_details',999);
end;

procedure get_ff_data(X_SESSION_DATE        in date,
                      X_ASSIGNMENT_ID        in     number,
                      X_ASSIGNMENT_END_DATE  in     date,
                      X_ASSIGNMENT_ACTION_ID in out nocopy number,
                      X_DATE_EARNED          in out nocopy date,
                      X_PAYROLL_ACTION_ID    in out nocopy number,
                      X_TRANSFER_DATE        in     date,
                      X_PERSON_ID            in     number,
                      X_TAX_REFERENCE        in     varchar2 default null) is
--
-- BUG 3221422 Changed Query for improving performance
--     4136320 Querying for actions only in TY of ATD
cursor c_act is select act.assignment_action_id,
                       act.payroll_action_id,
                       pact.effective_date ,
                       pact.payroll_id
                from pay_assignment_actions act,
                     pay_payroll_actions pact
                where act.assignment_id = X_ASSIGNMENT_ID
                and   act.action_status = 'C'
                and   pact.payroll_action_id = act.payroll_action_id
                and act.action_sequence = (
                    select /*+ ORDERED use_nl(a,pact2,t,r,v,f)
                               user_index(v, PAY_RUN_RESULT_VALUES_PK) */
                          max(a.action_sequence)
                    from  pay_assignment_actions a
                         ,pay_payroll_actions pact2
                         ,pay_balance_types t
                         ,pay_balance_feeds_f f
                         ,pay_run_results r
                         ,pay_run_result_values v
                    where t.balance_name in ('Taxable Pay','PAYE')
                    and t.legislation_code = 'GB'
                    and f.balance_type_id = t.balance_type_id
                    and v.input_value_id = f.input_value_id
                    and v.run_result_id = r.run_result_id
                    and r.assignment_action_id = a.assignment_action_id
                    and a.payroll_action_id = pact2.payroll_action_id
                    and a.assignment_id = X_ASSIGNMENT_ID
                    and a.action_status = 'C'
                    and pact2.effective_date <= X_TRANSFER_DATE
                    and pact2.effective_date >=
                             to_date('06-04-'||to_char(fnd_number.canonical_to_number(to_char(x_assignment_end_date,'YYYY'))),'DD-MM-YYYY')
                    and pact2.effective_date between f.effective_start_date and f.effective_end_date);

 cursor c_ptp (taxable_update_payroll number, c_date_paid date) is
 select min(PTP.start_date) start_date
 from per_time_periods PTP
 where PTP.payroll_id = taxable_update_payroll
 and (PTP.REGULAR_PAYMENT_DATE ) >= (/*start of fyear prior to session date*/
   to_date('06-04-'||
    to_char(fnd_number.canonical_to_number(to_char(c_date_paid,'YYYY'))
    +  least(sign(c_date_paid - to_date('06-04-'
    || to_char(c_date_paid,'YYYY'),'DD-MM-YYYY')),0)),'DD-MM-YYYY'));
 --
 cursor agg_latest_action (c_person_id in number,  -- query rewritten for bug 9292092
                           c_effective_end_date in date,
                           c_tax_reference in varchar2,
                           c_agg_active_start in date,
                           c_agg_active_end in date) is
  select /*+ ORDERED index(a PER_ASSIGNMENTS_F_N12) use_nl(paa ppa pay flex) */
           fnd_number.canonical_to_number(substr(max(
           lpad(paa.action_sequence,15,'0')||
           paa.assignment_action_id),16)) assignment_action_id
    from   per_all_assignments_f  a,
           pay_assignment_actions paa,
           pay_payroll_actions    ppa,
           pay_all_payrolls_f     pay,
           hr_soft_coding_keyflex flex
          ,(SELECT a2.assignment_id, max(a2.effective_start_date) max_effective_start_date -- Bug 9292092
            FROM   per_all_assignments_f a2,
                   per_assignment_status_types past
            WHERE  /* a2.assignment_id = a.assignment_id
            AND    */ a2.effective_start_date <= c_agg_active_end
            AND    a2.effective_end_date >= c_agg_active_start
            AND    a2.assignment_status_type_id = past.assignment_status_type_id
            AND    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN') group by a2.assignment_id) b
    where  a.person_id  = c_person_id
and b.assignment_id = a.assignment_id
and a.effective_start_date = b.max_effective_start_date
    and    paa.assignment_id     = a.assignment_id
    and    ppa.payroll_action_id = paa.payroll_action_id
    -- and    pay.payroll_id = a.payroll_id
    and    pay.payroll_id = ppa.payroll_id
    and    flex.soft_coding_keyflex_id = pay.soft_coding_keyflex_id
    and    flex.segment1 = c_tax_reference
    and    (paa.source_action_id is not null
            or ppa.action_type in ('I','V','B'))
    and    ppa.effective_date <= c_effective_end_date
    -- bug 4553334
    -- and  c_effective_end_date between a.effective_start_date and a.effective_end_date
    -- and  c_effective_end_date between pay.effective_start_date and pay.effective_end_date
    -- 5144323: ensure payroll is on the same paye ref at the time of payroll action
    AND    ppa.effective_date between pay.effective_start_date and pay.effective_end_date
    and    ppa.action_type        in ('R', 'Q', 'I', 'V', 'B');
    -- 5144323: Ensure the action belongs to an assignment that shares continuous active
    -- period of employement with the given terminated assignment
--    AND    a.effective_start_date = (SELECT /*+ ORDERED */ max(a2.effective_start_date)
--                                     FROM   per_all_assignments_f a2,
--                                            per_assignment_status_types past
--                                     WHERE  a2.assignment_id = a.assignment_id
--                                     AND    a2.effective_start_date <= to_date(c_agg_active_end, 'MM/DD/YYYY HH24:MI:SS')
--                                     AND    a2.effective_end_date >= to_date(c_agg_active_start, 'MM/DD/YYYY HH24:MI:SS')
--                                     AND    a2.assignment_status_type_id = past.assignment_status_type_id
--                                     AND    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN'))

 --
 cursor get_latest_id (c_assignment_id IN NUMBER,
                       c_effective_date IN DATE) is
    SELECT /*+ USE_NL(paa, ppa) */
         fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
         paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_id = c_assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  (paa.source_action_id is not null
          or ppa.action_type in ('I','V','B'))
    AND  ppa.effective_date <= c_effective_date
    AND  ppa.action_type        in ('R', 'Q', 'I', 'V', 'B');

 -- This cursor will fetch master assignment action id
 -- Added to support upgrade from 11.0 to 11i.
 cursor get_last_action(c_assignment_id  IN NUMBER,
                        c_effective_date IN DATE) is
    SELECT /*+ USE_NL(paa, ppa) */
         fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
         paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_id = c_assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  ppa.effective_date <= c_effective_date
    AND  ppa.action_status = 'C'
    AND  ppa.action_type        in ('R', 'Q', 'I', 'V', 'B');

--
 cursor taxable_or_paye_exists (c_assignment_action_id in number) is
  SELECT 'Y' FROM
  sys.dual target where exists
  (select 1
  from PAY_BALANCE_FEEDS_F FEED
  ,    PAY_BALANCE_TYPES      PBT
  ,    PAY_RUN_RESULT_VALUES  PRRV
  ,    PAY_RUN_RESULTS        PRR
  WHERE  PBT.BALANCE_NAME in ('Taxable Pay', 'PAYE')
  AND    PBT.LEGISLATION_CODE = 'GB'
  AND    PBT.BALANCE_TYPE_ID     = FEED.BALANCE_TYPE_ID
  AND    PRR.RUN_RESULT_ID       = PRRV.RUN_RESULT_ID
  AND    FEED.INPUT_VALUE_ID     = PRRV.INPUT_VALUE_ID
  AND    PRRV.RESULT_VALUE IS NOT NULL
  AND    PRRV.RESULT_VALUE <> '0'
  AND    PRR.ASSIGNMENT_ACTION_ID = c_assignment_action_id);
 --
 cursor payroll_details(c_assignment_action_id in number) is
   select paa.payroll_action_id,
          ppa.effective_date, ppa.payroll_id
   from pay_payroll_actions ppa,
        pay_assignment_actions paa
   where paa.assignment_action_id = c_assignment_action_id
   and ppa.payroll_action_id = paa.payroll_action_id;
 --
 cursor agg_paye(c_person_id in number,
                 c_effective_date in date) is
 select decode(p.per_information10,'Y','Y',NULL) agg_paye_flag
 from per_all_people_f p
 where p.person_id = c_person_id
 and   c_effective_date between
       p.effective_start_date and p.effective_end_date;
 --
 CURSOR csr_get_term_tax_year_start IS
 SELECT to_date('06-04-'||
      to_char(fnd_number.canonical_to_number(to_char(X_ASSIGNMENT_END_DATE,'YYYY'))
       +  least(sign(X_ASSIGNMENT_END_DATE - to_date('06-04-'
       || to_char(X_ASSIGNMENT_END_DATE,'YYYY'),'DD-MM-YYYY')),0)),'DD-MM-YYYY')
 FROM dual;
 --
 CURSOR csr_get_action_tax_year_start (p_asg_action_id NUMBER) IS
 SELECT to_date('06-04-'||
       to_char(fnd_number.canonical_to_number(to_char(ptp.regular_payment_date,'YYYY'))
       +  least(sign(ptp.regular_payment_date - to_date('06-04-'
       || to_char(ptp.regular_payment_date,'YYYY'),'DD-MM-YYYY')),0)),'DD-MM-YYYY')
 FROM per_time_periods ptp, pay_assignment_actions act, pay_payroll_actions pact
 WHERE act.assignment_action_id = p_asg_action_id
 AND   act.payroll_Action_id = pact.payroll_action_id
 AND   pact.time_period_id = ptp.time_period_id;
 --
 -- Cursor to find last date after assignment's termination date until which
 -- aggregation flag has remained Y - assuming flag is Y at the termination date
 CURSOR get_aggregation_end IS
 SELECT nvl((min(effective_start_date)-1), hr_general.end_of_time) agg_end_date
 FROM   per_all_people_f
 WHERE  person_id = X_PERSON_ID
 AND    effective_start_date > X_ASSIGNMENT_END_DATE
 AND    nvl(per_information10, 'N') = 'N';
 --
 l_found boolean := FALSE;
 l_tax_paye_exists varchar2(1);
 l_taxable_update_action number;
 l_taxable_update_date date;
 l_taxable_update_payroll number;
 l_payroll_year_start date;
 l_ptp c_ptp%rowtype;
 l_agg_paye_flag varchar2(1);
 l_asg_action_id number;
 l_latest_asg_action_id number;
 l_effective_date date;
 l_payroll_id number;
 l_payroll_action_id number;
 l_override_date date;
 l_asg_action_exists boolean;
 --
 l_termination_ty_start   date;
 l_latest_action_ty_start date;
 l_aggregation_end        date;
 l_agg_active_start       date;
 l_agg_active_end         date;
begin
  --
    hr_utility.trace('DATE_EARN ' || x_date_earned);
    hr_utility.trace('X_PERSON_ID ' || X_PERSON_ID);
    hr_utility.trace('X_ASSIGNMENT_END_DATE ' || fnd_date.date_to_displaydate(X_ASSIGNMENT_END_DATE));
    hr_utility.trace('X_TRANSFER_DATE ' || fnd_date.date_to_displaydate(X_TRANSFER_DATE));
    l_asg_action_exists := FALSE;
    open agg_paye(X_PERSON_ID, X_ASSIGNMENT_END_DATE);
    fetch agg_paye into l_agg_paye_flag;
    close agg_paye;
    --
    hr_utility.trace('Agg PAYE in ff data:'||l_agg_paye_flag);
    hr_utility.trace(to_char(X_TRANSFER_DATE));
    -- Use the tfr date as includes all processes for the assignment.
    if nvl(l_agg_paye_flag,'X') = 'Y' then
       -- 5144323: get_aggregation end date
       OPEN get_aggregation_end;
       FETCH get_aggregation_end INTO l_aggregation_end;
       CLOSE get_aggregation_end;
       hr_utility.trace('After get_aggregation_end, l_aggregation_end='||fnd_date.date_to_displaydate(l_aggregation_end));
       l_agg_active_start := pay_gb_eoy_archive.get_agg_active_start(X_ASSIGNMENT_ID, X_TAX_REFERENCE, X_ASSIGNMENT_END_DATE);
       l_agg_active_end   := pay_gb_eoy_archive.get_agg_active_end(X_ASSIGNMENT_ID, X_TAX_REFERENCE, X_ASSIGNMENT_END_DATE);
       --
       -- 5144343: Get aggregated action within the aggregation period only
       open agg_latest_action(X_PERSON_ID, least(X_TRANSFER_DATE, l_aggregation_end),
                              X_TAX_REFERENCE,
                              l_agg_active_start,
                              l_agg_active_end);
       fetch agg_latest_action into l_asg_action_id;
       --l_found := agg_latest_action%found;
       close agg_latest_action;
       l_found := FALSE;
       if l_asg_action_id is not null then
          l_found := TRUE;
       end if;
       hr_utility.trace('asg action for agg: '||to_char(l_asg_action_id));
       open payroll_details(l_asg_action_id);
       fetch payroll_details into l_payroll_action_id, l_effective_date,
                                  l_payroll_id;
       close payroll_details;
    hr_utility.trace('asg action: '||to_char(l_asg_action_id));
    --
    else
      -- NOT Aggregated PAYE
      hr_utility.trace('Not aggregated so get latest action of asg');
      --
      open get_latest_id(X_ASSIGNMENT_ID, X_TRANSFER_DATE);
      fetch get_latest_id into l_asg_action_id;
      close get_latest_id;
      --
      if l_asg_action_id is not null then
         hr_utility.trace('single asg action found: '||to_char(l_asg_action_id));
         l_latest_asg_action_id := l_asg_action_id;
         l_asg_action_exists := TRUE;
         open taxable_or_paye_exists(l_asg_action_id);
         fetch taxable_or_paye_exists into l_tax_paye_exists;
         l_found := taxable_or_paye_exists%found;
         IF l_found THEN
           hr_utility.trace(' Non zero results found: TRUE');
         ELSE
           hr_utility.trace(' Non zero results found: FALSE');
         END IF;
         close taxable_or_paye_exists;
      else
          hr_utility.trace('No Master-Child action');
          open get_last_action(X_ASSIGNMENT_ID, X_TRANSFER_DATE);
          fetch get_last_action into l_asg_action_id;
          close get_last_action;

          if l_asg_action_id is not null then
             l_found := TRUE;
          end if;
      end if;
      --
      if l_found then
         -- Above 2 cursors found the last assignment action has
         -- Taxable Pay or PAYE balances, so obtain payroll action details
         hr_utility.trace('Asg action has paye or taxable pay');
         open payroll_details(l_asg_action_id);
         fetch payroll_details into l_payroll_action_id, l_effective_date,
                                    l_payroll_id;
         close payroll_details;

      else
         -- Above cursors did not find asg action that has Taxable
         -- Pay or PAYE balances, so use less efficient cursor
         -- to search for the last action that has PAYE or Taxable
         -- Pay. Do this only if there was any asg action for the assignment.
       hr_utility.trace('Asg action has NO paye or taxable pay');
       IF l_asg_action_exists then
         BEGIN
           hr_utility.trace('Use c_act');
           open c_act;
           fetch c_act into l_asg_action_id, l_payroll_action_id,
                            l_effective_date, l_payroll_id;
           l_found := c_act%found;
           close c_act;
           hr_utility.trace(l_asg_action_id);
           hr_utility.trace(l_payroll_action_id);

           IF NOT(l_found) THEN -- 4136320: No actions with payments, so query the last run details
             open payroll_details( greatest(l_asg_action_id, l_latest_asg_action_id) );
             fetch payroll_details into l_payroll_action_id, l_effective_date,
                                    l_payroll_id;
             l_found := payroll_details%found;
           close payroll_details;
           END IF;

           hr_utility.trace(l_asg_action_id);
           hr_utility.trace(l_payroll_action_id);
           hr_utility.trace(l_effective_date);
           hr_utility.trace(l_payroll_id);
           -- Handle exceptions in c_act, set found = false.
         EXCEPTION WHEN OTHERS THEN
           hr_utility.trace('c_act raised: '|| sqlerrm(sqlcode));
           l_found := FALSE;
         END;
       ELSE
          -- No prior action exists at all, so must set found to false.
          hr_utility.trace('No Asg Action found');
          l_found := FALSE;
       END IF;
      end if; -- use c_act cursor if more performant cursors do not find vals
    end if; -- Aggregated PAYE
    --
    -- The above cursors have set the local vars and if so then the l_found
    -- has been set in one of the above 3 places. Therefore set the out
    -- params as necessary. Otherwise, set the out params to -9999
    --
    if l_found then
       hr_utility.trace('Found');
       l_override_date := override_date(x_assignment_id);
       l_taxable_update_action  := l_asg_action_id;
       l_taxable_update_payroll := l_payroll_id;
       x_payroll_action_id      := l_payroll_action_id;
       --
       -- Bug 5478073: Get tax year start for termination and latest action
       OPEN csr_get_term_tax_year_start;
       FETCH csr_get_term_tax_year_start INTO l_termination_ty_start;
       CLOSE csr_get_term_tax_year_start;
       hr_utility.trace('After csr_get_term_tax_year_start, l_termination_ty_start='||fnd_date.date_to_displaydate(l_termination_ty_start));
       --
       OPEN csr_get_action_tax_year_start(l_asg_action_id);
       FETCH csr_get_action_tax_year_start INTO l_latest_action_ty_start;
       CLOSE csr_get_action_tax_year_start;
       hr_utility.trace('After csr_get_action_tax_year_start, l_latest_action_ty_start='||fnd_date.date_to_displaydate(l_latest_action_ty_start));
       --
       -- Bug 2332796. Use the least of date paid and override
       -- date to get the time period for EOY expiry check.
       --
       l_taxable_update_date :=
          least(l_effective_date,nvl(l_override_date,hr_general.end_of_time));
       open c_ptp(l_taxable_update_payroll,
         nvl(l_taxable_update_date, X_ASSIGNMENT_END_DATE));
       fetch c_ptp into l_ptp;
       l_found := c_ptp%found;
       close c_ptp;

      if l_found then
         l_payroll_year_start := l_ptp.start_date;
         if l_payroll_year_start > l_taxable_update_date then
            x_assignment_action_id := -9999;
            x_date_earned := l_payroll_year_start;
         ------------------------------------------------------
         -- 5478073: above check is insuffucient hence added --
         -- following  condition for tax year check          --
         ------------------------------------------------------
         elsif l_latest_action_ty_start <  l_termination_ty_start THEN
            x_assignment_action_id := -9999; -- to show 0 values on P45
            x_payroll_action_id := -9999; -- to show 0 values on P45
            x_date_earned := X_SESSION_DATE; -- get tax code/basis at issue date
         else
            x_assignment_action_id := l_taxable_update_action;
            x_date_earned := l_taxable_update_date;
         end if;
       else
         x_assignment_action_id := l_taxable_update_action;
         x_date_earned := l_taxable_update_date;
      end if;

    else
       hr_utility.trace('Not found : ' || X_SESSION_DATE);
       l_taxable_update_date := NULL;
       X_DATE_EARNED := X_SESSION_DATE;
       X_ASSIGNMENT_ACTION_ID := -9999;
       x_payroll_action_id    := -9999;
    end if;
--
exception when NO_DATA_FOUND then
       -- Set all variables the same as if l_found not true.
       l_taxable_update_date := NULL;
       X_DATE_EARNED := X_SESSION_DATE;
       X_ASSIGNMENT_ACTION_ID := -9999;
       x_payroll_action_id    := -9999;
end get_ff_data;


procedure get_employer_address(X_ASSIGNMENT_ID in number,
                               X_ASSIGNMENT_END_DATE in     date,
                               X_EMPLOYER_NAME     in out nocopy varchar2,
                               X_EMPLOYER_ADDRESS  in out nocopy varchar2
                               ) is

cursor employer_addr(L_ASSIGNMENT_ID number, c_assignment_end_date date) is
       select oi.ORG_INFORMATION3,
              oi.ORG_INFORMATION4,
              ass.ASSIGNMENT_ID
       from   hr_organization_information oi,
              pay_payrolls_f roll,
              hr_soft_coding_keyflex flex,
              per_assignments_f ass,
              fnd_sessions sess
       where oi.ORG_INFORMATION_CONTEXT = 'Tax Details References'
       and   roll.business_group_id + 0 = oi.organization_id
 /* normally P45 is for leaver so pick up data on the assignment_end_date */
 /* for non leavers eg. tax district change use the session date */
       and   sess.SESSION_ID = userenv('sessionid')
       and   nvl(c_assignment_end_date, sess.effective_date) between
             ass.effective_start_date and ass.effective_end_date
       and   ass.payroll_id = roll.payroll_id
       and   nvl(c_assignment_end_date, sess.effective_date) between
             roll.effective_start_date and roll.effective_end_date
       and   ass.assignment_id = L_ASSIGNMENT_ID
       and   flex.segment1 = oi.org_information1 /* same tax district */
       and   flex.soft_coding_keyflex_id = roll.soft_coding_keyflex_id;

l_found boolean;
l_employer_addr employer_addr%rowtype;

begin

      open employer_addr(X_ASSIGNMENT_ID,X_ASSIGNMENT_END_DATE);
      fetch employer_addr into l_employer_addr;
      l_found := employer_addr%found;
      close employer_addr;

      if l_found then
         -- truncate employer name and address to max limits allowed on Org Developer DF
         X_EMPLOYER_NAME := substr(l_employer_addr.ORG_INFORMATION3,1,36);
         X_EMPLOYER_ADDRESS := substr(l_employer_addr.ORG_INFORMATION4,1,60);
      else
         X_EMPLOYER_NAME := '';
         X_EMPLOYER_ADDRESS := '';
      end if;


end;

procedure get_data(X_PERSON_ID            in number,
                   X_SESSION_DATE         in date,
                   X_ADDRESS_LINE1        in out nocopy varchar2,
                   X_ADDRESS_LINE2        in out nocopy varchar2,
                   X_ADDRESS_LINE3        in out nocopy varchar2,
                   X_TOWN_OR_CITY         in out nocopy varchar2,
                   X_REGION_1             in out nocopy varchar2,
                   X_COUNTRY              in out nocopy varchar2,
                   X_POSTAL_CODE          in out nocopy varchar2,
                   X_ASSIGNMENT_ID        in     number,
                   X_ASSIGNMENT_ACTION_ID in out nocopy number,
                   X_ASSIGNMENT_END_DATE  in     date,
                   X_DATE_EARNED          in out nocopy date,
                   X_PAYROLL_ACTION_ID    in out nocopy number,
                   X_TRANSFER_DATE        in     date)
                                                  is
CURSOR csr_tax_ref (c_assignment_id in number,
                    c_effective_end_date in date) is
  select scl.segment1
   from per_all_assignments_f paf,
        pay_all_payrolls_f ppf,
        hr_soft_coding_keyflex scl
   where paf.assignment_id = c_assignment_id
   and paf.payroll_id = ppf.payroll_id
   and scl.soft_coding_keyflex_id = ppf.soft_coding_keyflex_id
   and c_effective_end_date between
      paf.effective_start_date and paf.effective_end_date
   and c_effective_end_date between
      ppf.effective_start_date and ppf.effective_end_date;
--
  l_tax_reference varchar2(25);
--
begin
--
  open csr_tax_ref(X_ASSIGNMENT_ID,X_ASSIGNMENT_END_DATE);
  fetch csr_tax_ref into l_tax_reference;
  close csr_tax_ref;
--
  hr_utility.trace('Tax Ref: '||l_tax_reference);
--
    person_address(X_PERSON_ID,
                   X_SESSION_DATE,
                   X_ADDRESS_LINE1,
                   X_ADDRESS_LINE2,
                   X_ADDRESS_LINE3,
                   X_TOWN_OR_CITY,
                   X_REGION_1,
                   X_COUNTRY,
                   X_POSTAL_CODE,
		   X_ASSIGNMENT_END_DATE); -- added for bug9347169


    get_ff_data(X_SESSION_DATE,
                X_ASSIGNMENT_ID,
                X_ASSIGNMENT_END_DATE,
                X_ASSIGNMENT_ACTION_ID,
                X_DATE_EARNED,
                X_PAYROLL_ACTION_ID,
                nvl(X_TRANSFER_DATE,hr_general.end_of_time),
                X_PERSON_ID,
                l_tax_reference);

end get_data;

procedure get_data(X_PERSON_ID            in number,
                   X_SESSION_DATE         in date,
                   X_ADDRESS_LINE1        in out nocopy varchar2,
                   X_ADDRESS_LINE2        in out nocopy varchar2,
                   X_ADDRESS_LINE3        in out nocopy varchar2,
                   X_TOWN_OR_CITY         in out nocopy varchar2,
                   X_REGION_1             in out nocopy varchar2,
                   X_COUNTRY              in out nocopy varchar2,
                   X_POSTAL_CODE          in out nocopy varchar2,
                   X_ASSIGNMENT_ID        in     number,
                   X_ASSIGNMENT_ACTION_ID in out nocopy number,
                   X_ASSIGNMENT_END_DATE  in     date,
                   X_DATE_EARNED          in out nocopy date,
                   X_PAYROLL_ACTION_ID    in out nocopy number,
                   X_EMPLOYER_NAME        in out nocopy varchar2,
                   X_EMPLOYER_ADDRESS     in out nocopy varchar2,
                   X_TRANSFER_DATE        in     date)
                                                  is
CURSOR csr_tax_ref (c_assignment_id in number,
                    c_effective_end_date in date) is
  select scl.segment1
   from per_all_assignments_f paf,
        pay_all_payrolls_f ppf,
        hr_soft_coding_keyflex scl
   where paf.assignment_id = c_assignment_id
   and paf.payroll_id = ppf.payroll_id
   and scl.soft_coding_keyflex_id = ppf.soft_coding_keyflex_id
   and c_effective_end_date between
      paf.effective_start_date and paf.effective_end_date
   and c_effective_end_date between
      ppf.effective_start_date and ppf.effective_end_date;
--
  l_tax_reference varchar2(25);
--
begin
--
  open csr_tax_ref(X_ASSIGNMENT_ID,X_ASSIGNMENT_END_DATE);
  fetch csr_tax_ref into l_tax_reference;
  close csr_tax_ref;
  hr_utility.trace('Tax Ref: '||l_tax_reference);
--
    person_address(X_PERSON_ID,
                   X_SESSION_DATE,
                   X_ADDRESS_LINE1,
                   X_ADDRESS_LINE2,
                   X_ADDRESS_LINE3,
                   X_TOWN_OR_CITY,
                   X_REGION_1,
                   X_COUNTRY,
                   X_POSTAL_CODE,
		   X_ASSIGNMENT_END_DATE); -- added for bug9347169


    get_ff_data(X_SESSION_DATE,
                X_ASSIGNMENT_ID,
                X_ASSIGNMENT_END_DATE,
                X_ASSIGNMENT_ACTION_ID,
                X_DATE_EARNED,
                X_PAYROLL_ACTION_ID,
                nvl(X_TRANSFER_DATE,hr_general.end_of_time),
                X_PERSON_ID, l_tax_reference);

    get_employer_address(X_ASSIGNMENT_ID,
                         X_ASSIGNMENT_END_DATE,
                         X_EMPLOYER_NAME,
                         X_EMPLOYER_ADDRESS);

end get_data;

procedure get_form_query_data(X_ASSIGNMENT_ID           in number,
                              X_LAST_NAME               in out nocopy varchar2,
                              X_TITLE                   in out nocopy varchar2,
                              X_FIRST_NAME              in out nocopy varchar2,
                              X_NATIONAL_IDENTIFIER     in out nocopy varchar2,
                              X_PERSON_ID               in out nocopy number,
                              X_ACTUAL_TERMINATION_DATE in out nocopy date,
                              X_DECEASED_FLAG           in out nocopy varchar2,
                              X_ASSIGNMENT_NUMBER       in out nocopy varchar2,
                              X_PAYROLL_ID              in out nocopy number,
                              X_ORGANIZATION_ID         in out nocopy number,
                              X_ORG_NAME                in out nocopy varchar2,
                              X_DATE_OF_BIRTH           in out nocopy date,        /* P45 A4 2008/09 */
                              X_SEX                     in out nocopy varchar2) is /* P45 A4 2008/09 */


cursor c_query (p_assignment_id number) is
select p.last_name
,      p.title
,      p.first_name
,      p.middle_names
,      p.person_id
,      p.national_identifier
,      serv.actual_termination_date
,      decode(serv.leaving_reason,'D','D',NULL) deceased_flag
,      a.assignment_number
,      a.payroll_id
,      org.organization_id
,      org.name org_name
,      p.date_of_birth /* P45 A4 2008/09 */
,      p.sex           /* P45 A4 2008/09 */
from per_all_people_f p
,    per_all_assignments_f a
,    per_periods_of_service serv
,    hr_all_organization_units org
,    fnd_sessions sess
where a.assignment_id = p_assignment_id
and   sess.session_id = userenv('sessionid')
and   sess.effective_date between
                   a.effective_start_date and a.effective_end_date
and   a.person_id = p.person_id
and   sess.effective_date between
                   p.effective_start_date and p.effective_end_date
and   serv.person_id = p.person_id
and   serv.date_start = ( select max(s.date_start) from per_periods_of_service s
                           where s.person_id = p.person_id
                           and   sess.effective_date >= s.date_start )
and a.organization_id = org.organization_id;

--l_query c_query%rowtype;

begin

     for l_query_rec in c_query(X_ASSIGNMENT_ID) loop
         X_LAST_NAME               := l_query_rec.last_name;
         X_TITLE                   := l_query_rec.title;
         X_FIRST_NAME              := SUBSTR(l_query_rec.first_name || ' ' ||
                                      l_query_rec.middle_names, 1, 150);
         X_NATIONAL_IDENTIFIER     := l_query_rec.national_identifier;
         X_PERSON_ID               := l_query_rec.person_id;
         X_ACTUAL_TERMINATION_DATE := l_query_rec.actual_termination_date;
         X_DECEASED_FLAG           := l_query_rec.deceased_flag;
         X_ASSIGNMENT_NUMBER       := l_query_rec.assignment_number;
         X_PAYROLL_ID              := l_query_rec.payroll_id;
         X_ORGANIZATION_ID         := l_query_rec.organization_id;
         X_ORG_NAME                := l_query_rec.org_name;
         X_DATE_OF_BIRTH           := l_query_rec.date_of_birth; /* P45 A4 2008/09 */
         X_SEX                     := l_query_rec.sex;           /* P45 A4 2008/09 */

     end loop;


end;
--
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT NOCOPY VARCHAR2)
IS
  l_proc             CONSTANT VARCHAR2(35):= g_package||'range_cursor';
  l_employers_name_eid             ff_user_entities.user_entity_id%TYPE;
  l_employers_address_line_eid     ff_user_entities.user_entity_id%TYPE;
  l_tax_district_name_eid          ff_user_entities.user_entity_id%TYPE;
  -- vars for returns from the API:
  l_archive_item_id           ff_archive_items.archive_item_id%TYPE;
  l_ovn                       NUMBER;
  l_some_warning              BOOLEAN;
  l_payroll_id                NUMBER;
  l_chk_start_date            DATE; -- BUG 5671777-11 to store start date
  l_chk_end_date              DATE; -- BUG 5671777-11 to store end date
  p45_one_taxyear_error       EXCEPTION; -- raised when P45 process is not fall in the
                                         -- same tax year BUG 5671777-11
  --
  l_test_indicator     varchar2(1);
  l_test_id            varchar2(8);
  l_report_type        varchar2(15);
  l_report_category    varchar2(15);
  test_indicator_error  EXCEPTION;
  --
  cursor csr_user_entity(p_entity_name VARCHAR2) IS
  SELECT user_entity_id
  FROM   ff_user_entities
  WHERE  user_entity_name = p_entity_name
    AND  legislation_code = 'GB'
    AND  business_group_id IS NULL;
  --
  cursor csr_employer_details(p_payroll_action_id NUMBER) IS
  -- Select Employer details from Org DDF for specified Tax Ref, only
  -- if the action is for a P45 archive.
  SELECT
    substr(org.org_information3,1,36)    employers_name,
    substr(org.org_information4,1,60)    employers_address_line,
    substr(org.org_information2 ,1,40)   tax_district_name
  FROM
    pay_payroll_actions ppa,
    hr_organization_information org
  WHERE ppa.payroll_action_id = p_payroll_action_id
  AND   org.org_information_context = 'Tax Details References'
  AND   NVL(org.org_information10,'UK') = 'UK'
  AND   org.organization_id = ppa.business_group_id
  AND   substr(ppa.legislative_parameters,
                instr(ppa.legislative_parameters,'TAX_REF=') + 8,
                    instr(ppa.legislative_parameters||' ',' ',
                          instr(ppa.legislative_parameters,'TAX_REF=')+8)
                - instr(ppa.legislative_parameters,'TAX_REF=') - 8)
             = org.org_information1
  AND   ppa.report_category='P45';
  --
  -- TEST, TEST_ID, report_type and report_category added in cursor select
  -- for P45PT1. Bug 6345375
  cursor csr_get_payroll_param is
  select pay_core_utils.get_parameter('PAYROLL_ID',legislative_parameters) payroll_id,
         substr(pay_core_utils.get_parameter('TEST',legislative_parameters),1,1) test_indicator,
         trim(substr(pay_core_utils.get_parameter('TEST_ID',legislative_parameters),1,8)) test_id,
         report_type,
         report_category
  from pay_payroll_actions ppa
  where ppa.payroll_action_id = pactid;
  --
  -- Start of BUG 5671777-11
  --
  -- fetch start date and end date for the P45 process
  --
  CURSOR csr_get_p45_start_end_date(p_payroll_action_id NUMBER) IS
  SELECT
  start_date,
  fnd_date.canonical_to_date
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                        'DATE_TO')) end_date
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;

  --
  -- fetch start date and end date for the P45 EDI process
  --

  CURSOR csr_get_p45_EDI_start_end_date(p_payroll_action_id NUMBER) IS
  SELECT
  fnd_date.canonical_to_date
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                        'DATE_FROM')) start_date,
  fnd_date.canonical_to_date
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                        'END_DATE')) end_date
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
  -- End of BUG 5671777-11
  --
  rec_employer_details csr_employer_details%ROWTYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,1);
  --
  -- Get the parameter payroll_id, if this has been used.
  --
  -- Added for P45PT1. Bug 6345375
  open csr_get_payroll_param;
  fetch csr_get_payroll_param into l_payroll_id, l_test_indicator,l_test_id,l_report_type,l_report_category;
  if csr_get_payroll_param%NOTFOUND then
     l_payroll_id := null;
  end if;
  close csr_get_payroll_param;
  --
  -- Added for P45PT1. Bug 6345375
  -- Log the error in Log_File if Test_Indicator is Yes, but Test_ID is not provided
  -- and Raise an unhandled exception to fail the process.
  --
  IF l_report_type = 'P45PT1' and l_report_category = 'EDI' THEN
     IF (l_test_indicator = 'Y' AND l_test_id IS NULL) THEN
        fnd_file.put_line (fnd_file.LOG,'Error : Enter the Test ID as the EDI Test Indicator is Yes.');
        RAISE test_indicator_error;
     END IF;
  END IF;
  --
  hr_utility.trace('Payroll_ID: '||to_char(l_payroll_id));
  -- Return Range Cursor
  -- Note: There must be one and only one entry of :payroll_action_id in
  -- the string, and the statement must be ordered by person_id
  --
  -- Start of BUG 5671777-11
  -- fetch start date and end date
  --
  BEGIN

    OPEN csr_get_p45_start_end_date(pactid);
    FETCH csr_get_p45_start_end_date INTO l_chk_start_date,
                                          l_chk_end_date;
    CLOSE csr_get_p45_start_end_date;

    IF l_chk_end_date IS NULL THEN
    OPEN csr_get_p45_EDI_start_end_date(pactid);
    FETCH csr_get_p45_EDI_start_end_date INTO l_chk_start_date,
                                              l_chk_end_date;
    CLOSE csr_get_p45_EDI_start_end_date;

    END IF;


    --
    -- Check whether P45 Prcess to ensure it is run for one tax year at a time or not
    --

    IF  ((l_chk_start_date BETWEEN to_date('06/04/'||to_char(l_chk_start_date,'YYYY'),'dd/mm/yyyy')
        AND to_date('31/12/'||to_char(l_chk_start_date,'YYYY'),'dd/mm/yyyy'))
        AND (l_chk_end_date BETWEEN to_date('06/04/'||to_char(l_chk_start_date,'YYYY'),'dd/mm/yyyy')
        AND to_date('05/04/'||to_char(to_number(to_char(l_chk_start_date,'YYYY'))+1),'dd/mm/yyyy')))
    OR  ((l_chk_start_date BETWEEN to_date('01/01/'||to_char(l_chk_start_date,'YYYY'),'dd/mm/yyyy')
        AND to_date('05/04/'||to_char(l_chk_start_date,'YYYY'),'dd/mm/yyyy'))
        AND (l_chk_end_date BETWEEN to_date('01/01/'||to_char(l_chk_start_date,'YYYY'),'dd/mm/yyyy')
        AND to_date('05/04/'||to_char(l_chk_start_date,'YYYY'),'dd/mm/yyyy')))
    THEN
        hr_utility.set_location('Start Date and End Date are in the same tax year ',6);
    ELSE
        fnd_file.put_line (fnd_file.LOG, 'The Start Date and the End Date must be within the tax year.');
        hr_utility.set_location('The Start Date and the End Date must be within the tax year.',8);
	  RAISE p45_one_taxyear_error;
    END IF;
   END;
    -- End of BUG 5671777-11

  OPEN csr_employer_details(pactid);
  FETCH csr_employer_details INTO rec_employer_details;
  IF csr_employer_details%FOUND THEN
    -- Action is for P45 Archive (not EDI)
    OPEN csr_user_entity('X_EMPLOYERS_ADDRESS_LINE');
    FETCH csr_user_entity INTO l_employers_address_line_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_EMPLOYERS_NAME');
    FETCH csr_user_entity INTO l_employers_name_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_DISTRICT_NAME');
    FETCH csr_user_entity INTO l_tax_district_name_eid;
    CLOSE csr_user_entity;
    -- Archive the employer details
    ff_archive_api.create_archive_item
      (p_archive_item_id  => l_archive_item_id,
       p_user_entity_id   => l_employers_address_line_eid,
       p_archive_value    => rec_employer_details.employers_address_line,
       p_archive_type     => 'PA',
       p_action_id        => pactid,
       p_legislation_code => 'GB',
       p_object_version_number => l_ovn,
       p_context_name1    => 'PAYROLL_ID',
       p_context1         => '0',
       p_some_warning     => l_some_warning);
    ff_archive_api.create_archive_item
      (p_archive_item_id  => l_archive_item_id,
       p_user_entity_id   => l_employers_name_eid,
       p_archive_value    => rec_employer_details.employers_name,
       p_archive_type     => 'PA',
       p_action_id        => pactid,
       p_legislation_code => 'GB',
       p_object_version_number => l_ovn,
       p_context_name1    => 'PAYROLL_ID',
       p_context1         => '0',
       p_some_warning     => l_some_warning);
    ff_archive_api.create_archive_item
      (p_archive_item_id  => l_archive_item_id,
       p_user_entity_id   => l_tax_district_name_eid,
       p_archive_value    => rec_employer_details.tax_district_name,
       p_archive_type     => 'PA',
       p_action_id        => pactid,
       p_legislation_code => 'GB',
       p_object_version_number => l_ovn,
       p_context_name1    => 'PAYROLL_ID',
       p_context1         => '0',
       p_some_warning     => l_some_warning);
    --
  END IF;
  CLOSE csr_employer_details;
  --
  hr_utility.set_location(l_proc,10);
  --
  --
  IF l_payroll_id is not null then
    -- Payroll ID has been used in param, restrict by this.
    hr_utility.set_location(l_proc,20);
    sqlstr := 'select distinct paaf.person_id '||
              'from pay_payroll_actions ppa, '||
              'per_all_assignments_f paaf '||
              'where ppa.payroll_action_id = :payroll_action_id '||
              'and paaf.business_group_id + 0 = ppa.business_group_id '||
              'and paaf.payroll_id = '||to_char(l_payroll_id)||
              ' order by paaf.person_id';
    --
  ELSE
    -- Normal range not restricting by payroll_id.
    hr_utility.set_location(l_proc,30);
    sqlstr := 'select distinct person_id '||
              'from per_people_f ppf, '||
              'pay_payroll_actions ppa '||
              'where ppa.payroll_action_id = :payroll_action_id '||
              'and ppa.business_group_id = ppf.business_group_id '||
              'order by ppf.person_id';
  END IF;
  hr_utility.set_location(' Leaving: '||l_proc,100);
EXCEPTION
  --
  -- Start of BUG 5671777-11
  --
  WHEN p45_one_taxyear_error THEN
    sqlstr := 'select 1 '||
              '/* ERROR - The Start Date and the End Date must be within the tax year: '||
              sqlerrm(sqlcode)||' */ '||
              'from dual where to_char(:payroll_action_id) = dummy';
    RAISE;
  --
  -- End of BUG 5671777-11
  --
  -- Added for P45PT1. Bug 6345375.
  -- Raise Unhandled exception to fail the process.
  --
  WHEN test_indicator_error THEN
    RAISE;
  --
  --
  WHEN OTHERS THEN
    -- Return cursor that selects no rows
    sqlstr := 'select 1 '||
              '/* ERROR - Employer Details Fetch failed with: '||
              sqlerrm(sqlcode)||' */ '||
              'from dual where to_char(:payroll_action_id) = dummy';
    hr_utility.set_location(' Leaving: '||l_proc,110);
END range_cursor;
---------------------------------------------------------------------------
-- Function: range_person_on.
-- Description: Returns true if the range_person performance enhancement is
--   enabled for the system. Used by arch_act_creation, edi_act_creation.
---------------------------------------------------------------------------
FUNCTION range_person_on (p_report_format in varchar2) RETURN BOOLEAN IS
--
 CURSOR csr_action_parameter is
  select parameter_value
  from pay_action_parameters
  where parameter_name = 'RANGE_PERSON_ID';
--
 CURSOR csr_range_format_param (c_report_format in varchar2) is
  select par.parameter_value
  from   pay_report_format_parameters par,
         pay_report_format_mappings_f map
  where  map.report_format_mapping_id = par.report_format_mapping_id
  and    map.report_type = 'P45'
  and    map.report_format = c_report_format
  and    map.report_qualifier = 'GB'
  and    par.parameter_name = 'RANGE_PERSON_ID';
--
  l_return boolean;
  l_action_param_val varchar2(30);
  l_report_param_val varchar2(30);
--
BEGIN
  hr_utility.set_location('range_person_on',10);
  --
  BEGIN
    open csr_action_parameter;
    fetch csr_action_parameter into l_action_param_val;
    close csr_action_parameter;
    --
    hr_utility.set_location('range_person_on',20);
    open csr_range_format_param(p_report_format);
    fetch csr_range_format_param into l_report_param_val;
    close csr_range_format_param;
  --
    hr_utility.set_location('range_person_on',30);
  EXCEPTION WHEN NO_DATA_FOUND THEN
     l_return := FALSE;
  END;
  --
  hr_utility.set_location('range_person_on',40);
  IF l_action_param_val = 'Y' AND l_report_param_val = 'Y' THEN
     l_return := TRUE;
     hr_utility.trace('Range Person = True');
  ELSE
     l_return := FALSE;
  END IF;
--
 RETURN l_return;
--
END range_person_on;
---------------------------------------------------------------------------
-- FUNCTION: p45_existing_action
-- DESCRIPTION: boolean function for the existence of a leaver or tfr
--              P45 action (archived). NB Mark for print not used.
--------------------------------------------------------------------------
FUNCTION p45_existing_action(p_assignment_id in number,
                             p_period_of_service_id in number,
                             p_mode in varchar2) RETURN BOOLEAN
  IS
--
  l_p45_action_exists boolean := FALSE;
  l_arc_period_of_service_id ff_archive_items.value%TYPE;
  l_arc_tax_ref_transfer ff_archive_items.value%TYPE;
  --
  /*
  cursor csr_check_action(c_assignment_id in number) is
   select
    max(decode(fai.user_entity_id,g_period_of_service_eid,fai.VALUE)) pos
   ,max(decode(fai.user_entity_id,g_tax_ref_transfer_eid,fai.VALUE)) tfr
               from ff_archive_items fai,      -- of P45 report type
                    pay_assignment_actions act,
                    pay_payroll_actions ppa
               where ppa.report_type='P45'
               and   ppa.report_qualifier='GB'
               and   ppa.report_category ='P45'
               and   ppa.action_type = 'X'
               and   ppa.payroll_action_id = act.payroll_action_id
               and   act.assignment_id = c_assignment_id
               and   act.assignment_action_id = fai.context1
               and   fai.user_entity_id in (g_tax_ref_transfer_eid,
                                            g_period_of_service_eid);
  */
   cursor csr_check_action(c_assignment_id in number) is
   select max(decode(fai.user_entity_id,g_period_of_service_eid,fai.VALUE)) pos
         ,max(decode(fai.user_entity_id,g_tax_ref_transfer_eid,fai.VALUE)) tfr
   from   ff_archive_items fai
   where  fai.user_entity_id in (g_tax_ref_transfer_eid,g_period_of_service_eid)
   and    fai.context1 = (select max(act.assignment_action_id)
                           from   pay_payroll_actions ppa,
                                  pay_assignment_actions act
                           where  ppa.report_type='P45'
                           and    ppa.report_qualifier='GB'
                           and    ppa.report_category ='P45'
                           and    ppa.action_type = 'X'
                           and    ppa.payroll_action_id = act.payroll_action_id
                           and    act.assignment_id = c_assignment_id);
--
BEGIN

   open csr_check_action(p_assignment_id);
   fetch csr_check_action into l_arc_period_of_service_id,
                               l_arc_tax_ref_transfer;
   --
   -- Fix bug 4120027
   if l_arc_period_of_service_id is null and csr_check_action%FOUND then
       if p_mode = 'LEAVER' then
          if l_arc_tax_ref_transfer = 'N' then
              l_p45_action_exists := TRUE;
          else
              l_p45_action_exists := FALSE; -- the default
          end if;
       elsif p_mode = 'TRANSFER' then
          if l_arc_tax_ref_transfer = 'Y' then
             l_p45_action_exists := TRUE;
          else
             l_p45_action_exists := FALSE; -- the default
          end if;
       end if;
   else
       if p_mode = 'LEAVER' then
          -- If the archived period of service matches the live, and
          -- the archive action is not a Taxref transfer
          --
          if l_arc_period_of_service_id = p_period_of_service_id
             and l_arc_tax_ref_transfer = 'N' then
             l_p45_action_exists := TRUE;
          else
             l_p45_action_exists := FALSE; -- the default
          end if;
      elsif p_mode = 'TRANSFER' then
          -- If the archived period of service matches the live, and
          -- the archive action IS a transfer.
          if l_arc_period_of_service_id = p_period_of_service_id
             and l_arc_tax_ref_transfer = 'Y' then
             l_p45_action_exists := TRUE;
          else
             l_p45_action_exists := FALSE; -- the default
          end if;
       end if;
   end if;

   close csr_check_action;
   --
   RETURN l_p45_action_exists;

end p45_existing_action;
--------------------------------------------------------------------------
-- FUNCTION future_active_exists
-- Returns TRUE if active or suspended asg exists after the current asg.
--------------------------------------------------------------------------
FUNCTION future_active_exists (p_assignment_id in number,
                               p_effective_end_date in date) RETURN BOOLEAN
IS
--
  l_future_asg boolean  := FALSE;
  l_number     number;
  --
  cursor csr_future_assignment (c_assignment_id in number,
                                c_effective_end_date in date) is
  select 1 from dual where exists
  (select paf.effective_end_date
   from   per_all_assignments_f paf,
          per_assignment_status_types past
   where  past.assignment_status_type_id = paf.assignment_status_type_id
   and    paf.assignment_id = c_assignment_id
   and    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   and    paf.effective_end_date > c_effective_end_date);
--
BEGIN
  --
  open csr_future_assignment(p_assignment_id, p_effective_end_date);
  fetch csr_future_assignment into l_number;
  if csr_future_assignment%FOUND then
       l_future_asg := TRUE;
  else
       l_future_asg := FALSE;
  end if;
  --
  RETURN l_future_asg;
end future_active_exists;
--
--------------------------------------------------------------------------
-- FUNCTION is_transferred
-- DESCRIPTION Check whether an assignment has transferred Tax
--             Districts
--------------------------------------------------------------------------
FUNCTION is_transferred (p_assignment_id in number,
                         p_effective_end_date in date,
                         p_tax_ref in varchar2) RETURN BOOLEAN IS
--
l_exists number;
l_transfer_done boolean := FALSE;
--
cursor csr_transfer (c_assignment_id in number,
                     c_effective_end_date in date,
                     c_tax_ref in varchar2) is
  select 1 from dual where exists
  (select scl.segment1
   from per_all_assignments_f paf,
        pay_all_payrolls_f ppf,
        hr_soft_coding_keyflex scl
   where paf.assignment_id = c_assignment_id
   and paf.payroll_id = ppf.payroll_id
   and scl.soft_coding_keyflex_id = ppf.soft_coding_keyflex_id
   and scl.segment1 <> c_tax_ref
   and paf.effective_start_date between
       ppf.effective_start_date and ppf.effective_end_date
   and paf.effective_end_date > c_effective_end_date);
--
BEGIN
  open csr_transfer(p_assignment_id, p_effective_end_date, p_tax_ref);
  fetch csr_transfer into l_exists;
  if csr_transfer%FOUND then
     l_transfer_done := TRUE;
  else
     l_transfer_done := FALSE;
  end if;
  --
RETURN l_transfer_done;
--
END is_transferred;
--------------------------------------------------------------------------
-- FUNCTION payment_made
-- DESCRIPTION Check whether final payment has been made for an assignment
--             after the end date so that the p45 can be issued. If not,
--             and a Last Standard Process has been set, check that an asg
--             action exists in the period immediately preceding LSP date.
--------------------------------------------------------------------------
--
FUNCTION payment_made (p_assignment_id in number,
                       p_effective_end_date in date,
                       p_period_of_service_id in number) RETURN boolean IS
--
  l_payment_made boolean := FALSE;
  l_number number;
  l_lsp_date date;
--
  cursor csr_payment (c_assignment_id in number,
                      c_effective_end_date in date) is
   select 1 from dual where exists
   (select pa.effective_date
    from pay_payroll_actions pa,
         pay_assignment_actions aa
    where aa.assignment_id = c_assignment_id
    and aa.payroll_action_id = pa.payroll_action_id
    and pa.action_type in ('R','Q','V','I','B')
    and pa.date_earned >= c_effective_end_date);
--
  cursor csr_last_standard_process (c_period_of_service_id in number) is
    select serv.last_standard_process_date
    from per_periods_of_service serv
    where serv.period_of_service_id = c_period_of_service_id;
--
  cursor csr_lsp_payment(c_last_process_date  in date,
                         c_effective_end_date in date,
                         c_assignment_id      in number) is
    select 1 from dual where exists
    (select paa.assignment_action_id
     from pay_assignment_actions paa,
          pay_payroll_actions ppa,
          per_time_periods ptp
     where ptp.time_period_id = ppa.time_period_id
     and   ppa.payroll_action_id = paa.payroll_action_id
     and   paa.assignment_id = c_assignment_id
     and   ppa.action_type in ('R','Q','V','I','B')
     and   ptp.regular_payment_date =
       (select max(ptp.regular_payment_date)
        from per_all_assignments_f paf,
             per_time_periods ptp
        where ptp.regular_payment_date <= c_last_process_date
        and paf.assignment_id = c_assignment_id
        and ptp.payroll_id = paf.payroll_id
        and c_effective_end_date between
             paf.effective_start_date and paf.effective_end_date));
--
BEGIN
  --
  -- First check whether there has been any payments made
  -- after asgs end date, as there will be in most cases:
  --
  open csr_payment (p_assignment_id, p_effective_end_date);
  fetch csr_payment into l_number;
  if csr_payment%FOUND then
     l_payment_made := TRUE;
  else
     l_payment_made := FALSE;
  end if;
  close csr_payment;
  --
  IF l_payment_made = FALSE THEN
    --
    -- User may have set Last Standard Process to before default
    -- date or on termination. Check the date
    --
    open csr_last_standard_process (p_period_of_service_id);
    fetch csr_last_standard_process into l_lsp_date;
    close csr_last_standard_process;
    --
    IF l_lsp_date is null then
      -- No Last Standard Process Date and no Payment made.
        l_payment_made := FALSE;
    ELSE
      -- LSP Populated, so check assignment actions for assignment
      -- during the time period whose RPD immediately precedes the LSP
      open csr_lsp_payment(l_lsp_date, p_effective_end_date, p_assignment_id);
      fetch csr_lsp_payment into l_number;
      if csr_lsp_payment%FOUND then
         l_payment_made := TRUE;
      else
         l_payment_made := FALSE;
      end if;
    END IF;
  END IF;
  --
RETURN l_payment_made;
--
end payment_made;
--------------------------------------------------------------------------
-- FUNCTION manual_issue_exists
-- DESCRIPTION Find whether there has been a manual issue date set.
--------------------------------------------------------------------------
FUNCTION manual_issue_exists(p_assignment_id in number) RETURN BOOLEAN IS
--
  l_number number;
  l_manual_issue_exists BOOLEAN;
  --
  cursor csr_manual_date (c_assignment_id in number) is
  select 1 from dual where exists
  (select aei.aei_information3
   from per_assignment_extra_info aei
   where aei.assignment_id = c_assignment_id
   and aei.aei_information3 is not null
   and aei.information_type = 'GB_P45');
--
BEGIN
  open csr_manual_date(p_assignment_id);
  fetch csr_manual_date into l_number;
  if csr_manual_date%NOTFOUND then
     l_manual_issue_exists := FALSE;
  else
     l_manual_issue_exists := TRUE;
  end if;
  close csr_manual_date;
  --
RETURN l_manual_issue_exists;
END manual_issue_exists;
--------------------------------------------------------------------------
-- FUNCTION tax_code_ni
-- DESCRIPTION Check that the final tax code of the assignment is not
-- 'NI', as we should not produce p45 for such asgs
--------------------------------------------------------------------------
FUNCTION tax_code_ni(p_assignment_id in number,
                     p_effective_end_date in date) RETURN BOOLEAN IS
--
  l_tax_code_ni boolean;
  l_number number;
  l_latest_asg_action_id number;
  --
  cursor csr_latest_action (c_assignment_id in number,
                            c_effective_end_date in date) is
  select fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0') ||
         paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_id = c_assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  (paa.source_action_id is not null
          or ppa.action_type in ('I','V','B'))
    AND  ppa.effective_date <= c_effective_end_date
    AND  ppa.action_type        in ('R', 'Q', 'I', 'V', 'B');
  --
  cursor csr_tax_code_ni (c_assignment_action_id in number,
                          c_effective_end_date in date) is
  select 1 from dual where exists
  (select prrv.result_value
   from  pay_input_values_f         inv,
         pay_element_types_f        type,
         pay_run_results            prr,
         pay_run_result_values      prrv
   where prrv.input_value_id = inv.input_value_id
   and inv.name = 'Tax Code'
   and prr.assignment_action_id = c_assignment_action_id
   and c_effective_end_date between
        inv.effective_start_date and inv.effective_end_date
   and c_effective_end_date between
        type.effective_start_date and type.effective_end_date
   and prrv.result_value = 'NI'
   and type.element_name = 'PAYE Details'
   and type.element_type_id = prr.element_type_id
   and prrv.run_result_id = prr.run_result_id);
--
BEGIN
  --
  open csr_latest_action(p_assignment_id,p_effective_end_date);
  fetch csr_latest_action into l_latest_asg_action_id;
  close csr_latest_action;
  --
  open csr_tax_code_ni(l_latest_asg_action_id,p_effective_end_date);
  fetch csr_tax_code_ni into l_number;
  if csr_tax_code_ni%FOUND then
     l_tax_code_ni := TRUE;
  else l_tax_code_ni := FALSE;
  end if;
  --
  RETURN l_tax_code_ni;

END tax_code_ni;
--------------------------------------------------------------------------
-- NEW procedure for dealing with aggregated and non agg assignments
--------------------------------------------------------------------------
PROCEDURE arch_act_creation(pactid IN NUMBER,
                          stperson IN NUMBER,
                          endperson IN NUMBER,
                          chunk IN NUMBER) IS
  --
  TYPE g_type_asg_rec IS RECORD (
    assignment_id        number,
    assignment_number    varchar2(40),
    period_of_service_id number,
    person_id            number,
    agg_paye_flag        char,
    asg_end_date         date,
    regular_payment_date date
  );

  l_proc             CONSTANT VARCHAR2(35):= g_package||'arch_act_creation';
  l_number           number;
  l_actid            pay_assignment_actions.assignment_action_id%TYPE;
  l_non_p45_message  varchar2(50);
  l_transfer_flag    varchar2(1);
  l_override_date    date;
  l_archive          boolean;
  l_check_main_flag  boolean;
  l_range_person_on  varchar2(3);
  rec_asg            g_type_asg_rec;
  --
  -- vars for returns from the API:
  l_archive_item_id    ff_archive_items.archive_item_id%TYPE;
  l_ovn                NUMBER;
  l_some_warning       BOOLEAN;
  -- 5144323: To store ids of assignments included on the P45
  TYPE l_included_asg_tab_type IS TABLE OF NUMBER
    INDEX BY binary_integer;
  --
  l_inc_asg_tab   l_included_asg_tab_type;
  l_empty_asg_tab l_included_asg_tab_type;
  l_inc_asg_index NUMBER;
  --
 cursor csr_parameter_info(p_payroll_action_id NUMBER) IS
 SELECT
    to_number(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                               'PAYROLL_ID')) payroll_id,
    substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'TAX_REF'),1,20) tax_ref,
    start_date,
    effective_date,
    fnd_date.canonical_to_date
      (pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                        'DATE_TO'))  end_date,
    business_group_id
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
  --
  cursor csr_user_entity(p_entity_name VARCHAR2) IS
  SELECT user_entity_id
  FROM   ff_user_entities
  WHERE  user_entity_name = p_entity_name
    AND  legislation_code = 'GB'
    AND  business_group_id IS NULL;
  --
  cursor csr_person_agg_asg (c_person_id in number,
                             c_tax_ref in varchar2,
                             c_assignment_id in number,
                             c_period_of_service_id in number,
                             c_term_date in date,
                             c_agg_start_date in date,
                             c_agg_end_date in date) is
select a.assignment_id,
          a.effective_end_date
   from per_all_assignments_f a,
        pay_all_payrolls_f pay,
        hr_soft_coding_keyflex flex,
        per_periods_of_service serv
   where a.person_id = c_person_id
   and flex.segment1 = c_tax_ref
   and pay.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   and a.payroll_id = pay.payroll_id
   and a.effective_end_date between
          pay.effective_start_date and pay.effective_end_date
   and serv.period_of_service_id = a.period_of_service_id
   and a.assignment_id <> c_assignment_id
   and a.period_of_service_id = c_period_of_service_id
   -- 5144323: only last active/suspended dt instances of the
   -- assignemnts are needed
   AND a.effective_end_date = ( SELECT max(effective_end_date)
                                FROM   per_all_assignments_f a1,
                                       per_assignment_status_types past
                                WHERE a.assignment_id = a1.assignment_id
                                AND   a1.assignment_status_type_id = past.assignment_status_type_id
                                AND   past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN'))
   -- 5144323: assignments must exist during the aggregation period
   AND EXISTS (SELECT 1 FROM per_all_assignments_f a2
               WHERE  a.assignment_id = a2.assignment_id
               AND    a2.effective_start_date <= c_agg_end_date
               AND    a2.effective_end_date >= c_agg_start_date)
   -- 5144323: assignments must share continuous period of
   -- employment with the input assignment
   AND EXISTS (SELECT 1
               FROM   per_all_assignments_f a3,
                      per_assignment_status_types past
               WHERE a.assignment_id = a3.assignment_id
               AND   a3.assignment_status_type_id = past.assignment_status_type_id
               AND   past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
               AND   a3.effective_start_date <= pay_gb_eoy_archive.get_agg_active_end(c_assignment_id, c_tax_ref, c_term_date)
               AND   a3.effective_end_date >= pay_gb_eoy_archive.get_agg_active_start(c_assignment_id, c_tax_ref, c_term_date));

--
/* Fix performance bug by split cursor into 2 */
cursor csr_all_assignments is
  SELECT /*+ ORDERED */
         a.assignment_id,
         a.assignment_number,
         a.period_of_service_id,
         p.person_id,
         decode(p.per_information10,'Y','Y',NULL) agg_paye_flag,
         max(a.effective_end_date) asg_end_date,
         ptp.regular_payment_date
  FROM  per_all_people_f p,
        per_all_assignments_f a,
        per_assignment_status_types past,
        pay_all_payrolls_f   ppf,
        per_time_periods ptp,
        per_periods_of_service serv,
        hr_soft_coding_keyflex flex
  WHERE a.person_id BETWEEN stperson AND endperson
    AND a.business_group_id +0 = g_business_group_id
    AND (g_payroll_id is null
          or
         a.payroll_id + 0 = g_payroll_id)
    AND a.effective_end_date BETWEEN g_start_date AND g_end_date
    AND a.payroll_id = ppf.payroll_id
    AND a.period_of_service_id = serv.period_of_service_id
    AND a.effective_end_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
    AND ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
    AND flex.segment1 = g_tax_ref
    AND ppf.payroll_id = ptp.payroll_id
    AND a.effective_end_date BETWEEN ptp.start_date AND ptp.end_date
    AND a.effective_end_date <= g_end_date -- before run end date

    -- AND a.effective_end_date =   -- the latest active or susp asg exclude DT update
    --               (select max(asg2.effective_end_date)
    --                  from per_all_assignments_f asg2,
    --                       per_assignment_status_types past
    --                 where asg2.assignment_id = a.assignment_id
    --                   and asg2.assignment_status_type_id =past.assignment_status_type_id
    --                   and past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
    --                   and asg2.effective_end_date <> hr_general.end_of_time)
    AND a.assignment_status_type_id =past.assignment_status_type_id
    AND past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
    AND a.effective_end_date <> hr_general.end_of_time
    AND a.person_id = p.person_id
    AND a.effective_end_date between p.effective_start_date and p.effective_end_date
    GROUP BY a.assignment_id, a.assignment_number, a.period_of_service_id,
           p.person_id, decode(p.per_information10,'Y','Y',NULL),
           ptp.regular_payment_date;
--
-- The 2nd half of union is a copy of csr_all_assignments, but with a join to
-- pay_population_ranges, for performance improvement if the range_person
-- functionality is enabled. Only 1 half will be used as these are made exclusive
-- by the parameter c_range_person_on.
--
-- UNION ALL
--
cursor csr_all_assignments_range is
  SELECT /*+ ORDERED*/
         a.assignment_id, a.assignment_number,
         a.period_of_service_id,
         p.person_id,
         decode(p.per_information10,'Y','Y',NULL) agg_paye_flag,
         max(a.effective_end_date) asg_end_date,
         ptp.regular_payment_date
    FROM pay_population_ranges  ppr,
         per_all_people_f       p,
         per_all_assignments_f  a,
         per_assignment_status_types past,
         pay_all_payrolls_f     ppf,
         per_time_periods       ptp,
         per_periods_of_service serv,
         hr_soft_coding_keyflex flex
   WHERE p.person_id = ppr.person_id
     AND ppr.chunk_number = chunk
     AND ppr.payroll_action_id = pactid
     AND a.business_group_id +0 = g_business_group_id
     AND a.payroll_id +0 = nvl(g_payroll_id,a.payroll_id)
     AND a.effective_end_date
         BETWEEN g_start_date AND g_end_date
     AND a.payroll_id = ppf.payroll_id
     AND a.period_of_service_id = serv.period_of_service_id
     AND a.effective_end_date
         BETWEEN ppf.effective_start_date AND ppf.effective_end_date
     AND ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
     AND flex.segment1 = g_tax_ref
     AND ppf.payroll_id = ptp.payroll_id
     AND a.effective_end_date
     BETWEEN ptp.start_date AND ptp.end_date
     AND a.effective_end_date <= g_end_date -- before run end date

     --AND a.effective_end_date =   -- the latest active or susp asg exclude DT update
     --              (select max(asg2.effective_end_date)
     --              from per_all_assignments_f asg2,
     --                   per_assignment_status_types past
     --              where asg2.assignment_id = a.assignment_id
     --              and asg2.assignment_status_type_id =
     --                   past.assignment_status_type_id
     --              and past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
     --              and asg2.effective_end_date <> hr_general.end_of_time)
     AND a.assignment_status_type_id =past.assignment_status_type_id
     AND past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
     AND a.effective_end_date <> hr_general.end_of_time
     AND a.person_id = p.person_id
     AND a.effective_end_date between p.effective_start_date and p.effective_end_date
     GROUP BY a.assignment_id, a.assignment_number, a.period_of_service_id,
           p.person_id, decode(p.per_information10,'Y','Y',NULL),
           ptp.regular_payment_date;
-------------------------------------------------------------------------------------
 -- Cursor to find last date after assignment's termination date until which
 -- aggregation flag has remained Y - assuming flag is Y at the termination date
 CURSOR get_agg_end(p_person_id NUMBER, p_term_date DATE)  IS
 SELECT nvl((min(effective_start_date)-1), hr_general.end_of_time) agg_end_date
 FROM   per_all_people_f
 WHERE  person_id = p_person_id
 AND    effective_start_date > p_term_date
 AND    nvl(per_information10, 'N') = 'N';
--
 CURSOR get_agg_start(p_person_id NUMBER, p_term_date DATE)  IS
 SELECT nvl((max(effective_end_date)+1), hr_general.start_of_time) agg_start_date
 FROM   per_all_people_f
 WHERE  person_id = p_person_id
 AND    effective_end_date < p_term_date
 AND    nvl(per_information10, 'N') = 'N';
--
 l_agg_start_date DATE;
 l_agg_end_date   DATE;
BEGIN
  hr_utility.set_location('Entering: '||l_proc,1);
  --
  IF NOT g_asg_creation_cache_populated THEN
    OPEN csr_user_entity('X_TAX_REF_TRANSFER');
    FETCH csr_user_entity INTO g_tax_ref_transfer_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TERMINATION_DATE');
    FETCH csr_user_entity INTO g_termination_date_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PERIOD_OF_SERVICE_ID');
    FETCH csr_user_entity INTO g_period_of_service_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_P45_INCLUDED_ASSIGNMENT');
    FETCH csr_user_entity INTO g_p45_inc_assignment;
    CLOSE csr_user_entity;
    --
    OPEN csr_parameter_info(pactid);
    FETCH csr_parameter_info INTO g_payroll_id,
                                  g_tax_ref,
                                  g_start_date,
                                  g_effective_date,
                                  g_end_date,
                                  g_business_group_id;
    CLOSE csr_parameter_info;
    --
    g_asg_creation_cache_populated := true;
  END IF;
  --
  -- Check whether range_person_functionality is used or not.
  -- convert boolean to varchar for use in cursor.
  --
  IF range_person_on('REPORT') then
     l_range_person_on := 'YES';
     open csr_all_assignments_range;
  ELSE
     l_range_person_on := 'NO';
     open csr_all_assignments;
  END IF;
  hr_utility.trace('Range person on: '||l_range_person_on);
  --
  -- Use First half of cursor where range_person not set,
  -- use second half for range_person on (performance enhancement)
  --
  -- FOR rec_asg IN csr_all_assignments(l_range_person_on) LOOP
  --
  LOOP
     if l_range_person_on = 'YES' then
        fetch csr_all_assignments_range into rec_asg;
        exit when csr_all_assignments_range%notfound;
     else
        fetch csr_all_assignments into rec_asg;
        exit when csr_all_assignments%notfound;
     end if;
  --
  --
   l_archive := TRUE;
     hr_utility.trace(to_char(rec_asg.assignment_id)||
      '    '||rec_asg.agg_paye_flag||'   '||
            to_char(rec_asg.asg_end_date,'dd-mon-yyyy')||':');
     hr_utility.trace('----------------------------');
   --
   -- initialize the included asg table and index
   l_inc_asg_index := 0;
   l_inc_asg_tab := l_empty_asg_tab;
   --
   IF NOT (is_transferred(rec_asg.assignment_id,
                          rec_asg.asg_end_date, g_tax_ref))
   THEN
      --
      l_transfer_flag := 'N';
      -- Is there an assignment with active status existing
      -- with this ID at a later date.
      IF future_active_exists(rec_asg.assignment_id,
                              rec_asg.asg_end_date) then
         l_non_p45_message := 'Future Active asg exists';
         l_archive := FALSE;
         -- This asg is to be excluded
      ELSE
         hr_utility.set_location(l_proc,5);
         IF rec_asg.agg_paye_flag = 'Y' then
            --
            -- Check current asg for existing p45 actions
            IF return_p45_issued_flag(rec_asg.assignment_id) = 'Y' then
               hr_utility.set_location(l_proc,6);
               -- Cannot archive this assignment, set msg.
               l_non_p45_message := 'Agg: P45 exists';
               l_archive := FALSE;
            ELSE
               hr_utility.set_location(l_proc,7);
               -- 5144323: Get aggregation period start and end
               OPEN  get_agg_start(rec_asg.person_id, rec_asg.asg_end_date);
               FETCH get_agg_start INTO l_agg_start_date;
               CLOSE get_agg_start;
               --
               OPEN get_agg_end(rec_asg.person_id, rec_asg.asg_end_date);
               FETCH get_agg_end INTO l_agg_end_date;
               CLOSE get_agg_end;
               --
               hr_utility.trace('l_agg_start_date='||
                                 fnd_date.date_to_displaydate(l_agg_start_date)||
                                ', l_agg_end_date='||
                                 fnd_date.date_to_displaydate(l_agg_end_date));
               --
               -- Loop through all OTHER assignments in this aggregation
               -- for further checks. Set a flag if rec_asg.assignment_id
               -- cannot be archived.
               --
               FOR rec_all_aggs in csr_person_agg_asg(rec_asg.person_id, g_tax_ref,
                   rec_asg.assignment_id, rec_asg.period_of_service_id,
                   rec_asg.asg_end_date, l_agg_start_date, l_agg_end_date) LOOP
                  -- 5144323: keep list of agg assignments, this info shd be archived
                  -- when P45 action is created
                  l_inc_asg_index := l_inc_asg_index + 1;
                  l_inc_asg_tab(l_inc_asg_index) := rec_all_aggs.assignment_id;
                  --
                  hr_utility.set_location(l_proc,10);
                  IF rec_asg.asg_end_date < rec_all_aggs.effective_end_date THEN
                     -- Asg exists that is not ended as of the effective end
                     -- of the current assignment
                     l_non_p45_message := 'Agg: asg exists not ended: '||
                                          to_char(rec_all_aggs.assignment_id);
                     -- Exclude main assignment, exit loop (performance)
                     l_archive := FALSE;
                     EXIT;
                  ELSE
                     hr_utility.set_location(l_proc,20);
                     IF rec_asg.asg_end_date = rec_all_aggs.effective_end_date
                     AND rec_asg.assignment_id > rec_all_aggs.assignment_id THEN
                        -- Other lower Asg ID exists, and ending on the same date.
                        -- Exclude this assignment exit loop
                        l_non_p45_message := 'Agg: Lower asg ID, same end date exists';
                        l_archive := FALSE;
                        EXIT;
                     ELSE
                        hr_utility.set_location(l_proc,30);
                        l_check_main_flag := true;
                        --
                     END IF; -- lower asg id
                  END IF; -- existing later assignments
               END LOOP; -- OTHER agg assignments loop
               -- fix for bug 5380921 --
               IF l_check_main_flag AND l_archive THEN
                  IF NOT payment_made(rec_asg.assignment_id, rec_asg.asg_end_date,rec_asg.period_of_service_id) THEN
                     l_override_date := override_date(rec_asg.assignment_id);
                     IF l_override_date IS NULL THEN
                        l_non_p45_message := 'No Final Payment or Override';
                        l_archive := FALSE;
                     ELSIF l_override_date > g_effective_date THEN
                        l_non_p45_message := 'Override date (' || to_char(l_override_date) ||
                                       ') greater than issue date';
                        l_archive := FALSE;
                     END IF; -- Override date check
                  END IF; -- Payment Made check
               END IF; -- archive flag check
               -- end bug fix for 5380921 --
            END IF; -- for current asg leaver check.
         ELSE -- Non Aggregated PAYE
            hr_utility.set_location(l_proc,35);
            IF return_P45_issued_flag(rec_asg.assignment_id) = 'Y' THEN
               hr_utility.set_location(l_proc,40);
               l_non_p45_message := 'Leaver action exists';
               l_archive := FALSE;
            ELSE
               hr_utility.set_location(l_proc,50);
               IF payment_made(rec_asg.assignment_id, rec_asg.asg_end_date,
                           rec_asg.period_of_service_id) THEN
                  -- Final Payment made.
                  hr_utility.set_location(l_proc,60);
                  l_archive := TRUE;
               ELSE
                  -- Has there been an override that is before the p45
                  -- run date but after the eff end of the asg.
                  l_override_date := override_date(rec_asg.assignment_id);
                  IF l_override_date IS NULL THEN
                     l_non_p45_message := 'No Final Payment or Override';
                     l_archive := FALSE;
                  ELSIF l_override_date <= g_effective_date AND
                         l_override_date >= rec_asg.asg_end_date THEN
                     l_archive := TRUE;
                     hr_utility.set_location(l_proc,65);
                  ELSE
                      l_non_p45_message := to_char(rec_asg.asg_end_date)||':'||
                                     to_char(l_override_date)||':'||
                                     to_char(g_effective_date);
                      l_archive := FALSE;
                  END IF; -- override date
               END IF; -- final payment
            END IF; -- P45 check
         END IF; -- aggregated paye
      END IF; -- future assignment
   --
   ELSE
     ---------------------------------------
     -- Tax Reference transfer
     ---------------------------------------
     hr_utility.set_location(l_proc,70);
     l_transfer_flag := 'Y';
     if p45_existing_action(p_assignment_id => rec_asg.assignment_id,
                     p_period_of_service_id => rec_asg.period_of_service_id,
                                     p_mode => 'TRANSFER')
     then
        l_non_p45_message := 'Transfer action exists';
        l_archive := FALSE;
     else
        IF rec_asg.agg_paye_flag = 'Y' then
          hr_utility.set_location(l_proc,80);
          for rec_all_aggs in csr_person_agg_asg(rec_asg.person_id, g_tax_ref,
                    rec_asg.assignment_id, rec_asg.period_of_service_id,
                    rec_asg.asg_end_date, hr_general.start_of_time,
                    hr_general.end_of_time) loop
            if rec_asg.asg_end_date < rec_all_aggs.effective_end_date then
                -- Asg exists that is not ended as of the effective end
                -- of the current assignment, and is ACTIVE
                l_non_p45_message := 'TFR: Agg: asg exists not ended: '||
                                     to_char(rec_all_aggs.assignment_id);
                -- Exclude main assignment, exit loop (performance)
                l_archive := FALSE;
                exit;
             else
                hr_utility.set_location(l_proc,90);
                if rec_asg.asg_end_date = rec_all_aggs.effective_end_date
                and rec_asg.assignment_id > rec_all_aggs.assignment_id
                       then
                   -- Other lower Asg ID exists, and ending on the same date.
                   -- Exclude this assignment exit loop
                   l_non_p45_message :=
                        'TFR: Agg: Lower asg ID, same end date exists';
                   l_archive := FALSE;
                   exit;
                else
                   -- No reason to exclude this asg.
                   hr_utility.set_location(l_proc,95);
                end if; -- Lower asg id
             end if; -- future active for this agg
          end loop; -- Aggregated loop
        ELSE
          -- Not aggregated and no existing action, so archive.
          hr_utility.set_location(l_proc,105);
          l_archive := TRUE;
        END IF; -- Agg asg
     end if; -- existing tfr action
   END IF; -- TRANSFER
   --------------------------------------------
   -- Archive the assignment if not excluded
   --------------------------------------------
   if l_archive = FALSE then
            hr_utility.trace('No P45 for '||to_char(rec_asg.assignment_id)||
                             '. Reason:');
            hr_utility.trace(l_non_p45_message);
            fnd_file.put_line(fnd_file.log,
                  rec_asg.assignment_number||': '|| l_non_p45_message);
            l_non_p45_message := null;
   else
     hr_utility.set_location(l_proc,107);
     -- Final check for all, has latest asg action got NI Tax code
     -- NB Placing this check here at the end for performance reasons.
     -- Using regular payment date for final payment date.
     if NOT (tax_code_ni(rec_asg.assignment_id,rec_asg.regular_payment_date))
     then
       hr_utility.trace('ARCHIVING FOR '||to_char(rec_asg.assignment_id));
        SELECT pay_assignment_actions_s.nextval
        INTO l_actid
        FROM dual;
       --
       hr_utility.set_location(l_proc,110);
       hr_nonrun_asact.insact(l_actid,rec_asg.assignment_id,
                              pactid,chunk,NULL);
       --
       hr_utility.set_location(l_proc,120);
       -- Archive the tax ref transfer flag and the Asg end date.
       --
       ff_archive_api.create_archive_item
      (p_archive_item_id  => l_archive_item_id,
       p_user_entity_id   => g_tax_ref_transfer_eid,
       p_archive_value    => l_transfer_flag,
       p_archive_type     => 'AAC',
       p_action_id        => l_actid,
       p_legislation_code => 'GB',
       p_object_version_number => l_ovn,
       p_some_warning     => l_some_warning);
       --
      ff_archive_api.create_archive_item
      (p_archive_item_id  => l_archive_item_id,
       p_user_entity_id   => g_termination_date_eid,
       p_archive_value    => fnd_date.date_to_canonical(rec_asg.asg_end_date),
       p_archive_type     => 'AAC',
       p_action_id        => l_actid,
       p_legislation_code => 'GB',
       p_object_version_number => l_ovn,
       p_some_warning     => l_some_warning);
       --
       FOR l_count IN 1..l_inc_asg_index LOOP
         hr_utility.set_location(l_proc,125);
         hr_utility.trace('Including asg id='||l_inc_asg_tab(l_count));
          ff_archive_api.create_archive_item
         (p_archive_item_id  => l_archive_item_id,
          p_user_entity_id   => g_p45_inc_assignment,
          p_archive_value    => l_inc_asg_tab(l_count),
          p_archive_type     => 'AAC',
          p_action_id        => l_actid,
          p_legislation_code => 'GB',
          p_object_version_number => l_ovn,
          p_some_warning     => l_some_warning);
       END LOOP;
     else
       hr_utility.set_location(l_proc,130);
       hr_utility.trace('No P45 for '||to_char(rec_asg.assignment_id)||
                        '. Tax Code = NI');
       fnd_file.put_line(fnd_file.log,
                  rec_asg.assignment_number||': Tax Code = NI');
     end if; --  NI Tax Code
   end if; --  archive FALSE
  END LOOP; -- csr_all_assignments
  IF l_range_person_on = 'YES' then
     if csr_all_assignments_range%isopen then
        close csr_all_assignments_range;
     end if;
  ELSE
     if csr_all_assignments%isopen then
        close csr_all_assignments;
     end if;
  END IF;
  --
  hr_utility.set_location(' Leaving: '||l_proc,999);

END arch_act_creation;
---------------------------------------------------------------------------
PROCEDURE populate_run_msg(
             p45_assignment_action_id IN     NUMBER
            ,p_message_text           IN     varchar2
           )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
hr_utility.set_location(' Entering: populate_run_msg',111);

  INSERT INTO pay_message_lines(line_sequence,
                                payroll_id,
                                message_level,
                                source_id,
                                source_type,
                                line_text)
                         VALUES(
                                pay_message_lines_s.nextval
                               ,null
                               ,'F'
                               ,p45_assignment_action_id
                               ,'A'
                               ,substr(p_message_text,1,240)
                              );

hr_utility.set_location(' Leaving: populate_run_msg',999);
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('Error occured in populate_run_msg');
    RAISE;
END populate_run_msg;
---------------------------------------------------------------------------
PROCEDURE EDI_MOVDED6_ASG ( address_line1   in varchar2,
                                address_line2   in varchar2,
                                address_line3   in varchar2,
                                assignment_number in varchar2,
                                county        in varchar2,
                                first_name    in varchar2,
                                middle_name   in varchar2,
                                last_name     in varchar2,
                                national_insurance_number in varchar2,
                                postal_code   in varchar2,
                                title         in varchar2,
                                town_or_city  in varchar2,
                                effective_date in varchar2,
                                p_assactid     in number,
                                edi_validation_fail out nocopy  varchar2) IS

l_addline1              per_addresses.address_line1%TYPE := address_line1;
l_addline2              per_addresses.address_line2%TYPE:= address_line2;
l_addline3              per_addresses.address_line3%TYPE:=address_line3 ;
l_assignment_number     per_assignments_f.assignment_number%TYPE:=assignment_number ;
l_county                per_addresses.region_1%type:= county;
l_first_name            per_people_f.first_name%TYPE:= first_name;
l_middle_name           per_people_f.middle_names%TYPE:= middle_name;
l_last_name             per_people_f.last_name%TYPE:= last_name;
l_ni_number             per_people_f.national_identifier%TYPE:= national_insurance_number;
l_postal_code           per_addresses.postal_code%TYPE:= postal_code;
l_title                 per_people_f.title%TYPE:= title ;
l_addline4              per_addresses.town_or_city%TYPE := town_or_city; --
l_effective_date        date := effective_date;

BEGIN

if l_addline3 IS NULL then
   l_addline3 := l_addline4;
   l_addline4 := NULL;
end if;
if l_addline2 IS NULL then
   l_addline2 := l_addline3;
   l_addline3 := l_addline4;
   l_addline4 := NULL;
end if;
if LENGTH(TRIM(l_addline4)) > 0 then
     l_addline4 := l_addline4;
else
     l_addline4 := NULL;
end if;

if LENGTH(TRIM(l_addline3)) > 0 then
    l_addline3 := l_addline3;
else
      l_addline3 := l_addline4;
      l_addline4 := NULL;
end if;
if LENGTH(TRIM(l_addline2)) > 0 then
     l_addline2 := l_addline2;
else
   l_addline2 := l_addline3;
   l_addline3 := l_addline4;
   l_addline4 := NULL;
end if;

IF l_ni_number IS NOT NULL and hr_gb_utility.ni_validate(l_ni_number,l_effective_date) <> 0 THEN
    populate_run_msg(p_assactid,'The National Insurance Number of the assignment has invalid character(s)');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The National Insurance Number of the assignment has invalid character(s)');
    edi_validation_fail := 'Y';
END IF;

IF l_addline1 IS NULL THEN
    populate_run_msg(p_assactid,' The Address Line 1 of the assignment is missing.');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Address Line 1 of the assignment is missing.');
    edi_validation_fail := 'Y';
ELSIF pay_gb_eoy_magtape.validate_input(l_addline1, 'P14_FULL_EDI') > 0 THEN
    populate_run_msg(p_assactid,'The Address Line 1 of the assignment has invalid character(s).');
     fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Address Line 1 of the assignment has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;

IF l_addline2 IS NULL THEN
    populate_run_msg(p_assactid,'The Address Line 2 of the assignment is missing.');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Address Line 2 of the assignment is missing.');
    edi_validation_fail := 'Y';
ELSIF pay_gb_eoy_magtape.validate_input(l_addline2, 'P14_FULL_EDI') > 0 THEN
     populate_run_msg(p_assactid,'The Address Line 2 of the assignment has invalid character(s).');
     fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Address Line 2 of the assignment has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;

IF l_addline3 IS NOT NULL AND pay_gb_eoy_magtape.validate_input(l_addline3, 'P14_FULL_EDI') > 0 THEN
    populate_run_msg(p_assactid,'The Address Line 3 of the assignment has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Address Line 3 of the assignment has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;

IF town_or_city IS NOT NULL AND pay_gb_eoy_magtape.validate_input(town_or_city, 'P14_FULL_EDI') > 0 THEN
    populate_run_msg(p_assactid,'The Town or City of the assignment has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Town or City of the assignment has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;

IF assignment_number IS NOT NULL AND pay_gb_eoy_magtape.validate_input(assignment_number, 'P14_FULL_EDI') > 0 THEN
    populate_run_msg(p_assactid,'Assignment number has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : Assignment number has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;

IF l_county IS NOT NULL AND pay_gb_eoy_magtape.validate_input(l_county, 'P14_FULL_EDI') > 0 THEN
    populate_run_msg(p_assactid,'The County of the assignment has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The County of the assignment has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;

IF l_last_name IS NULL THEN
    populate_run_msg(p_assactid,'The Last Name of the assignment is missing.');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Last Name of the assignment is missing');
    edi_validation_fail := 'Y';
ELSIF pay_gb_eoy_magtape.validate_input(l_last_name, 'P45_46_LAST_NAME') > 0 THEN
    populate_run_msg(p_assactid,'The Last Name of the assignment has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Last Name of the assignment has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;

IF l_first_name IS NULL THEN
    populate_run_msg(p_assactid,' The First Name of the assignment is missing');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The First Name of the assignment is missing');
    edi_validation_fail := 'Y';
ELSIF pay_gb_eoy_magtape.validate_input(l_first_name, 'P45_46_FIRST_NAME') > 0 THEN
    populate_run_msg(p_assactid,'The First Name of the assignment has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The First Name of the assignment has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;

IF l_middle_name IS NOT NULL and pay_gb_eoy_magtape.validate_input(l_middle_name, 'P45_46_FIRST_NAME') > 0 THEN
    populate_run_msg(p_assactid,'The Middle Name of the assignment has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Middle Name of the assignment has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;

IF l_title IS NOT NULL and pay_gb_eoy_magtape.validate_input(l_title, 'P45_46_TITLE') > 0 THEN
    populate_run_msg(p_assactid,'The Title of the assignment has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Title of the assignment has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;

IF l_postal_code IS NOT NULL and pay_gb_eoy_magtape.validate_input(l_postal_code, 'P45_46_POSTCODE') > 0 THEN
    populate_run_msg(p_assactid,'The Postal Code of the assignment has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Postal Code of the assignment has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;


END EDI_MOVDED6_ASG;

---------------------------------------------------------------------------
PROCEDURE archinit(p_payroll_action_id IN NUMBER)
IS
  l_proc          CONSTANT VARCHAR2(35):= g_package||'archinit';
  l_do_edi_validation      VARCHAR2(6);
  l_effective_date         DATE;
  l_edi_ver                g_edi_ver%type;
  -- Bug  8815269
  l_ppa_payroll_id pay_payroll_actions.payroll_id%TYPE;
  l_payroll_id pay_payroll_actions.payroll_id%TYPE;
  -- Bug 8815269

  --
  cursor csr_user_entity(p_entity_name VARCHAR2) IS
  SELECT user_entity_id
  FROM   ff_user_entities
  WHERE  user_entity_name = p_entity_name
    AND  legislation_code = 'GB'
    AND  business_group_id IS NULL;
  --
  cursor csr_parameter_info(p_payroll_action_id NUMBER) IS
  SELECT
    to_number(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                               'PAYROLL_ID')) payroll_id,
    decode(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'CHAR_ERROR'),
           'Y','TRUE','N','FALSE') check_chars,
    effective_date
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
  --
  cursor csr_version_info(p_payroll_action_id NUMBER) IS
  SELECT pay_gb_eoy_archive.get_parameter(legislative_parameters,'EDI_VER') edi_ver
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;

BEGIN
  hr_utility.set_location('Entering: '||l_proc,1);
  IF NOT g_asg_process_cache_populated THEN
    -- does session date need to be set?
    --   fnd_sessions used in cursor employer_addr (only when asg terminated
    --      with null last std proc date).
    -- Get required SRS Parameters
    OPEN csr_parameter_info(p_payroll_action_id);
    FETCH csr_parameter_info INTO g_payroll_id,
                                  l_do_edi_validation,
                                  l_effective_date;
    CLOSE csr_parameter_info;
	g_do_edi_validation := hr_general.char_to_bool(l_do_edi_validation);
    OPEN csr_version_info(p_payroll_action_id);
    FETCH csr_version_info INTO l_edi_ver;
    CLOSE csr_version_info;
	g_edi_ver := l_edi_ver;
    -- cache User entity Ids
    OPEN csr_user_entity('X_ADDRESS_LINE1');
    FETCH csr_user_entity INTO g_address_line1_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_ADDRESS_LINE2');
    FETCH csr_user_entity INTO g_address_line2_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_ADDRESS_LINE3');
    FETCH csr_user_entity INTO g_address_line3_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_ASSIGNMENT_NUMBER');
    FETCH csr_user_entity INTO g_assignment_number_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_COUNTY');
    FETCH csr_user_entity INTO g_county_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_DECEASED_FLAG');
    FETCH csr_user_entity INTO g_deceased_flag_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_FIRST_NAME');
    FETCH csr_user_entity INTO g_first_name_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_MIDDLE_NAME'); /*Bug 6710229*/
    FETCH csr_user_entity INTO g_middle_name_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_ISSUE_DATE');
    FETCH csr_user_entity INTO g_issue_date_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_LAST_NAME');
    FETCH csr_user_entity INTO g_last_name_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_MONTH_NUMBER');
    FETCH csr_user_entity INTO g_month_number_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NATIONAL_INSURANCE_NUMBER');
    FETCH csr_user_entity INTO g_ni_number_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_ORGANIZATION_NAME');
    FETCH csr_user_entity INTO g_organization_name_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PAYROLL_ID');
    FETCH csr_user_entity INTO g_payroll_id_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_POSTAL_CODE');
    FETCH csr_user_entity INTO g_postal_code_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PREVIOUS_TAX_PAID');
    FETCH csr_user_entity INTO g_prev_tax_paid_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PREVIOUS_TAXABLE_PAY');
    FETCH csr_user_entity INTO g_prev_taxable_pay_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_STUDENT_LOAN_FLAG');
    FETCH csr_user_entity INTO g_student_loan_flag_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_AGGREGATED_PAYE_FLAG');
    FETCH csr_user_entity INTO g_aggregated_paye_flag_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PERIOD_OF_SERVICE_ID');
    FETCH csr_user_entity INTO g_period_of_service_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_EFFECTIVE_END_DATE');
    FETCH csr_user_entity INTO g_effective_end_date_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_CODE');
    FETCH csr_user_entity INTO g_tax_code_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_PAID');
    FETCH csr_user_entity INTO g_tax_paid_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAXABLE_PAY');
    FETCH csr_user_entity INTO g_taxable_pay_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_REF_TRANSFER');
    FETCH csr_user_entity INTO g_tax_ref_transfer_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TERMINATION_DATE');
    FETCH csr_user_entity INTO g_termination_date_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TITLE');
    FETCH csr_user_entity INTO g_title_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_DATE_OF_BIRTH');
    FETCH csr_user_entity INTO g_date_of_birth_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_SEX');
    FETCH csr_user_entity INTO g_sex_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TOWN_OR_CITY');
    FETCH csr_user_entity INTO g_town_or_city_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_W1_M1_INDICATOR');
    FETCH csr_user_entity INTO g_w1_m1_indicator_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_WEEK_NUMBER');
    FETCH csr_user_entity INTO g_week_number_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_COUNTRY');
    FETCH csr_user_entity INTO g_country_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_P45_FINAL_PAYMENT_ACTION');
    FETCH csr_user_entity INTO g_p45_final_action;
    CLOSE csr_user_entity;

    --
    -- Get IDs for seed data
    SELECT element_type_id
    INTO   g_paye_details_id
    FROM   pay_element_types_f
    WHERE  element_name = 'PAYE Details'
      AND  l_effective_date BETWEEN effective_start_date
                                AND effective_end_date;
    --
    g_asg_process_cache_populated := true;
  END IF; -- NOT g_asg_process_cache_populated


  --------------------------------------------------------------------------
 -- Code to update the payroll_id in the pay_payroll_actions table. -- Bug 8815269
--------------------------------------------------------------------------

   SELECT payroll_id,pay_gb_eoy_archive.get_parameter(legislative_parameters,'PAYROLL_ID')
     INTO l_ppa_payroll_id,l_payroll_id
     FROM pay_payroll_actions
    WHERE payroll_action_id = p_payroll_action_id ;


   -- Update the Payroll Action with the Payroll ID

   IF l_ppa_payroll_id IS NULL and l_payroll_id is not null THEN
      UPDATE pay_payroll_actions
         SET payroll_id = l_payroll_id
       WHERE payroll_action_id = p_payroll_action_id;
   END IF;

 -- end Bug 8815269

  hr_utility.set_location(' Leaving: '||l_proc,999);
END archinit;
--
PROCEDURE archive_code(p_assactid IN NUMBER, p_effective_date IN DATE)
IS
  --
  l_proc             CONSTANT VARCHAR2(35):= g_package||'archive_code';
  -- vars for returns from the API:
  l_archive_item_id           ff_archive_items.archive_item_id%TYPE;
  l_ovn                       NUMBER;
  l_some_warning              BOOLEAN;
  --
  l_assignment_id         per_assignments_f.assignment_id%TYPE;
  l_termination_date      DATE;
  l_tax_ref_transfer      VARCHAR2(1);
  l_transfer_date         DATE:=NULL;
  --
  l_assignment_number        per_assignments_f.assignment_number%TYPE;
  l_person_id                per_people_f.person_id%TYPE;
  l_asg_effective_end_date   DATE;
  l_deceased_flag            VARCHAR2(1);
  l_agg_paye_flag            VARCHAR2(1);
  l_period_of_service_id     NUMBER;
  l_org_name                 HR_ALL_ORGANIZATION_units.name%TYPE;
  l_last_name                per_people_f.last_name%TYPE;
  l_first_name               per_people_f.first_name%TYPE;
  l_middle_name              per_people_f.middle_names%TYPE; /*Bug 6710229*/
  l_title                    per_people_f.title%TYPE;
  l_date_of_birth            per_people_f.date_of_birth%TYPE;
  l_sex                      per_people_f.sex%TYPE;
  l_ni_number                per_people_f.national_identifier%TYPE;
  l_payroll_id               per_assignments_f.payroll_id%TYPE;
  --
  l_address_line1            per_addresses.address_line1%TYPE;
  l_address_line2            per_addresses.address_line2%TYPE;
  l_address_line3            per_addresses.address_line3%TYPE;
  l_town_or_city             per_addresses.town_or_city%TYPE;
  l_county                   per_addresses.region_1%TYPE;
  l_postal_code              per_addresses.postal_code%TYPE;
  l_country                  per_addresses.country%TYPE;
  l_last_asg_action_id       pay_assignment_actions.assignment_action_id%TYPE;
  l_date_earned              DATE;
  l_eff_date                 DATE;
  l_last_pay_action_id       pay_assignment_actions.payroll_action_id%TYPE;
  --
  l_student_loan_flag        VARCHAR2(1);
  --
  l_period_no           per_time_periods.period_num%TYPE;
  l_tax_reference       VARCHAR2(20);
  l_tax_code            pay_element_entry_values_f.screen_entry_value%TYPE;
  l_tax_basis           pay_element_entry_values_f.screen_entry_value%TYPE;
  l_prev_pay_char       pay_element_entry_values_f.screen_entry_value%TYPE;
  l_prev_tax_char       pay_element_entry_values_f.screen_entry_value%TYPE;
  l_tax_code_t          pay_element_entry_values_f.screen_entry_value%TYPE;
  l_tax_basis_t         pay_element_entry_values_f.screen_entry_value%TYPE;
  l_prev_pay_char_t     pay_element_entry_values_f.screen_entry_value%TYPE;
  l_prev_tax_char_t     pay_element_entry_values_f.screen_entry_value%TYPE;
  --
  l_taxable             NUMBER;
  l_paye                NUMBER;
  --
  l_week_or_month       VARCHAR2(1);
  --
  l_paye_element_id      number;
  l_tax_code_ipv_id      number;
  l_tax_basis_ipv_id     number;
  l_pay_previous_ipv_id  number;
  l_tax_previous_ipv_id  number;
  l_max_run_result_id    number;
  l_lsp_date   date;
  l_final_process_date date;
  ---
  l_pay_in_this_emp     varchar2(100);
  l_tax_in_this_emp     varchar2(100);
  less_than_zero_flag   varchar2(100);
  l_total_pay_to_date   varchar2(100);
  l_total_tax_to_date   varchar2(100);
  l_edi_validation_fail varchar2(1);
  l_edi_movded6_asg_flag varchar2(1);
  ---

  --
  cursor csr_asg_act_info(p_asgactid NUMBER) IS
  SELECT act.assignment_id,
    fnd_date.canonical_to_date(pay_gb_eoy_archive.get_arch_str
       (act.assignment_action_id,
        g_termination_date_eid)) term_date,
    pay_gb_eoy_archive.get_arch_str(act.assignment_action_id,
                                    g_tax_ref_transfer_eid) tax_ref_transfer
  FROM  pay_assignment_actions act
  WHERE act.assignment_action_id = p_asgactid;
  --
  cursor csr_basic_asg_info (p_assid NUMBER, p_term_date DATE) IS
  SELECT  ass.assignment_number,
    ass.person_id,
    ass.effective_end_date asg_effective_end_date,
    serv.last_standard_process_date,
    nvl(serv.final_process_date, hr_general.end_of_time),  -- For bug 9071978
    ass.period_of_service_id,
    decode(serv.leaving_reason,'D','D') deceased_flag,
    org.name org_name,
    upper(p.last_name) , p.title ,
    --SUBSTR(upper(p.first_name || ' ' || p.middle_names),1,150),
    --SUBSTR(upper(p.first_name || ',' || p.middle_names),1,150),--replaces space with a "comma" for the P45 EOY changes
    upper(p.first_name), upper(p.middle_names), /*Bug 6710229*/
    p.national_identifier, ass.payroll_id,
    decode(p.per_information10,'Y','Y',NULL) agg_paye_flag,
    p.date_of_birth, p.sex
  FROM
    per_all_people_f p,
    hr_all_organization_units org,
    per_periods_of_service serv,
    per_all_assignments_f        ass
  WHERE ass.assignment_id         = p_assid
    AND serv.period_of_service_id = ass.period_of_service_id
    AND ass.effective_end_date = p_term_date
    AND ass.organization_id = org.organization_id
    AND ass.person_id = p.person_id
    AND ass.effective_end_date BETWEEN p.effective_start_date
                               AND p.effective_end_date;
  --
  cursor csr_week_or_month(p_payroll_action_id NUMBER) IS
  SELECT decode(target.basic_period_type, 'W', 'W', 'M')
  FROM   per_time_period_rules target ,
         per_time_period_types  ptpt ,
         pay_payrolls_f roll,
         pay_payroll_actions pact
  WHERE ptpt.period_type = roll.period_type
  AND   target.number_per_fiscal_year = ptpt.number_per_fiscal_year
  AND   roll.payroll_id = pact.payroll_id
  AND   pact.effective_date BETWEEN roll.effective_start_date
                                AND roll.effective_end_date
  AND   pact.payroll_action_id = p_payroll_action_id;
  --
  -- Bug 8464343 : fetch week month type by payroll_id
  cursor week_month_by_paroll_id (p_payroll_id NUMBER , p_effective_date date) IS
  SELECT decode(target.basic_period_type, 'W', 'W', 'M')
  FROM   per_time_period_rules target ,
         per_time_period_types  ptpt ,
         pay_payrolls_f roll
  WHERE ptpt.period_type = roll.period_type
  AND   target.number_per_fiscal_year = ptpt.number_per_fiscal_year
  AND   roll.payroll_id = p_payroll_id
  AND   p_effective_date BETWEEN roll.effective_start_date
                                AND roll.effective_end_date ;
  -- Bug 5478073: Get period number in which assignment was terminated
  CURSOR csr_get_term_period_no(p_term_date DATE, p_payroll_id NUMBER) IS
  --Bug 7281023: Changed cursor logic
  /*SELECT nvl(max(ptp.period_num),0) -- Max and nvl are added to return 0 if period not found
  FROM   per_time_periods ptp
  WHERE  ptp.payroll_id = p_payroll_id
  AND    p_term_date BETWEEN ptp.start_date AND ptp.end_date;
  --*/
  --will fetch the period num of the first row ordered by regular_payment_date in ascending order
  SELECT distinct first_value(period_num) Over(order by regular_payment_date)
  FROM per_time_periods
  Where payroll_id = p_payroll_id
  AND regular_payment_date >= p_term_date;

  --
  cursor csr_period_number(p_payroll_action_id NUMBER) IS
  SELECT  nvl(max(ptp.period_num),0)  -- Max and nvl are added to return 0 if period not found
  FROM    per_time_periods ptp,
          pay_payroll_actions pact
  WHERE pact.payroll_action_id = p_payroll_action_id
    AND ptp.payroll_id = pact.payroll_id
    AND pact.date_earned BETWEEN ptp.start_date AND ptp.end_date;
  --
  CURSOR csr_paye_element IS
   SELECT element_type_id
   FROM pay_element_types_f
   WHERE element_name = 'PAYE';
  --
  CURSOR csr_input_value(p_ipv_name IN VARCHAR2) IS
   SELECT input_value_id
   FROM   pay_input_values_f
   WHERE  element_type_id = l_paye_element_id
   AND    name = p_ipv_name;
  --
  CURSOR csr_result_value(p_ipv_id IN NUMBER) IS
   SELECT result_value
   FROM   pay_run_result_values
   WHERE  run_result_id = l_max_run_result_id
   AND    input_value_id = p_ipv_id;
  --
  CURSOR csr_max_run_result IS
        SELECT /*+ ORDERED INDEX (assact2 PAY_ASSIGNMENT_ACTIONS_N51,
                           pact PAY_PAYROLL_ACTIONS_PK,
                           r2 PAY_RUN_RESULTS_N50)
            USE_NL(assact2, pact, r2) */
            to_number(substr(max(lpad(assact2.action_sequence,15,'0')||r2.source_type||
                               r2.run_result_id),17))
            FROM    pay_assignment_actions assact2,
                    pay_payroll_actions pact,
                    pay_run_results r2
            WHERE   assact2.assignment_id = l_assignment_id
            AND     r2.element_type_id+0 = l_paye_element_id
            AND     r2.assignment_action_id = assact2.assignment_action_id
            AND     r2.status IN ('P', 'PA')
            AND     pact.payroll_action_id = assact2.payroll_action_id
            AND     pact.action_type IN ( 'Q','R','B','I')
            AND     assact2.action_status = 'C'
            AND     pact.effective_date between
                        to_date('06-04-'||to_char(fnd_number.canonical_to_number(to_char(l_date_earned,'YYYY'))),'DD-MM-YYYY')
                    and to_date('05-04-'||to_char(fnd_number.canonical_to_number(to_char(l_date_earned,'YYYY') + 1)),'DD-MM-YYYY')
            AND NOT EXISTS(
               SELECT '1'
               FROM  pay_action_interlocks pai,
                     pay_assignment_actions assact3,
                     pay_payroll_actions pact3
               WHERE   pai.locked_action_id = assact2.assignment_action_id
               AND     pai.locking_action_id = assact3.assignment_action_id
               AND     pact3.payroll_action_id = assact3.payroll_action_id
               AND     pact3.action_type = 'V'
               AND     assact3.action_status = 'C');
  --
  cursor csr_paye_details(p_assignment_id  NUMBER,
                          p_effective_date DATE) IS
  SELECT  max(decode(iv.name,'Tax Code',screen_entry_value)) tax_code,
          max(decode(iv.name,'Tax Basis',screen_entry_value)) tax_basis,
          max(decode(iv.name,'Pay Previous',screen_entry_value))
                                                                pay_previous,
          max(decode(iv.name,'Tax Previous',screen_entry_value))
                                                                tax_previous
  FROM  pay_element_entries_f e,
        pay_element_entry_values_f v,
        pay_input_values_f iv,
        pay_element_links_f link
  WHERE e.assignment_id = p_assignment_id
  AND   link.element_type_id = g_paye_details_id
  AND   e.element_link_id = link.element_link_id
  AND   e.element_entry_id = v.element_entry_id
  AND   iv.input_value_id = v.input_value_id
  AND   p_effective_date
          BETWEEN link.effective_start_date AND link.effective_end_date
  AND   p_effective_date
          BETWEEN e.effective_start_date AND e.effective_end_date
  AND   p_effective_date
          BETWEEN iv.effective_start_date AND iv.effective_end_date
  AND   p_effective_date
          BETWEEN v.effective_start_date AND v.effective_end_date;
  --
  PROCEDURE archive_asg_info(p_user_entity_id NUMBER,
                             p_value VARCHAR2) IS
    l_proc             CONSTANT VARCHAR2(40):= g_package||'archive_asg_info';
  BEGIN
    IF p_value IS NOT NULL THEN
      hr_utility.set_location(l_proc||' '||p_user_entity_id,10);
      ff_archive_api.create_archive_item
        (p_archive_item_id  => l_archive_item_id,
         p_user_entity_id   => p_user_entity_id,
         p_archive_value    => p_value,
         p_action_id        => p_assactid,
         p_legislation_code => 'GB',
         p_object_version_number => l_ovn,
         p_some_warning     => l_some_warning);
    END IF;
  END archive_asg_info;
  --
BEGIN
  --hr_utility.trace_on(null,'KT');
  hr_utility.set_location('Entering: '||l_proc,1);
  hr_utility.trace('Assact ID : ' || p_assactid);
  -- Get the AAC level info.
  OPEN csr_asg_act_info(p_assactid);
  FETCH csr_asg_act_info INTO l_assignment_id,
                              l_termination_date,
                              l_tax_ref_transfer;
  CLOSE csr_asg_act_info;
  --
  OPEN csr_basic_asg_info(l_assignment_id,l_termination_date);
  FETCH csr_basic_asg_info INTO l_assignment_number,
                                l_person_id,
                                l_asg_effective_end_date, l_lsp_date,
                                l_final_process_date,
                                l_period_of_service_id,
                                l_deceased_flag,
                                l_org_name,
                                l_last_name,
                                l_title,
                                l_first_name,
                                l_middle_name, /*Bug 6710229*/
				                l_ni_number,
                                l_payroll_id,
                                l_agg_paye_flag,
                                l_date_of_birth,
                                l_sex;
  CLOSE csr_basic_asg_info;
  --
  hr_utility.trace('FP Date: '   ||to_char(l_final_process_date));
  hr_utility.trace('Term Date: ' || to_char(l_termination_date));
  hr_utility.trace('LSP Date: '  || to_char(l_lsp_date));
  -- transfer date used in selection of last assignment action
  IF l_tax_ref_transfer = 'Y' then
    l_transfer_date := l_termination_date;
  ELSE
     -- 5144323: for transfer cases actions from old PAYE Ref (before transfer date)
     -- need to be fetched but assignment/employee termination cases there
     -- should be no time limit hence transfer date is set to end of time
     l_transfer_date := hr_general.end_of_time;
  END IF;
  --
  hr_utility.trace(l_last_name||' '||to_char(l_asg_effective_end_date)||
                to_char(l_assignment_id)||' '||to_char(l_termination_date)||
                  '  '||l_tax_ref_transfer||' '||to_char(p_effective_date)||
                  ' '||to_char(l_transfer_date));
  hr_utility.trace('--------------------------------------');
  IF g_do_edi_validation or g_edi_ver = 'V6' THEN
  --Already handled in EDI_MOVDED6_ASG procedure. we dont want to error the process
  --immediately once we hit an error bug 8254291
  /* IF pay_gb_eoy_magtape.validate_input(upper(l_assignment_number),
                                         'FULL_EDI') > 0 THEN
      hr_utility.set_message(801, 'PAY_78037_EDI_ILLEGAL_CHARS');
      hr_utility.set_message_token('ITEM_NAME', 'Assignment Number');
      hr_utility.raise_error;
    END IF;

    IF pay_gb_eoy_magtape.validate_input(l_last_name,
                                         'EDI_SURNAME') > 0 THEN
      hr_utility.set_message(801, 'PAY_78037_EDI_ILLEGAL_CHARS');
      hr_utility.set_message_token('ITEM_NAME', 'Surname');
      hr_utility.raise_error;
    END IF;

    IF pay_gb_eoy_magtape.validate_input(l_first_name,
                                         'EDI_SURNAME') > 0 THEN
      hr_utility.set_message(801, 'PAY_78037_EDI_ILLEGAL_CHARS');
      hr_utility.set_message_token('ITEM_NAME', 'Forename');
      hr_utility.raise_error;
    END IF;

    IF pay_gb_eoy_magtape.validate_input(l_ni_number,
                                         'FULL_EDI') > 0 THEN
      hr_utility.set_message(801, 'PAY_78037_EDI_ILLEGAL_CHARS');
      hr_utility.set_message_token('ITEM_NAME', 'NI Number');
      hr_utility.raise_error;
    END IF;*/

    IF g_edi_ver = 'V6' and l_date_of_birth IS NULL THEN  -- V6 Validation
        populate_run_msg(p_assactid,'Date Of Birth for this assignment is missing.');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : Date Of Birth for this assignment is missing');
        l_edi_validation_fail := 'Y';
    ELSIF  l_date_of_birth IS NOT NULL and PAY_GB_MOVDED_EDI.date_validate(p_assactid,'DOB',l_date_of_birth) = 0 THEN
        populate_run_msg(p_assactid,'The Date of Birth for this assignment must be the current date or an earlier date.');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Date of Birth for this assignment must be the current date or an earlier date.');
        l_edi_validation_fail := 'Y';
    END IF;

    IF g_edi_ver = 'V6' and l_sex IS NULL THEN -- V6 Validation
        populate_run_msg(p_assactid,'The Gender for this assignment is missing.');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Gender for this assignment is missing');
        l_edi_validation_fail := 'Y';
    END IF;

    IF l_sex not in ('M','F') THEN
        populate_run_msg(p_assactid,'The Gender of this assignment has invalid character(s)');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Gender of this assignment has invalid character(s)');
        l_edi_validation_fail := 'Y';
    END IF;

    IF l_termination_date IS NULL THEN
     populate_run_msg(p_assactid,'The Date of Leaving of the assignment is missing.');
     fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Date of Leaving of the assignment is missing');
     l_edi_validation_fail := 'Y';
    ELSIF PAY_GB_MOVDED_EDI.date_validate(p_assactid,'LEFT_DATE_V6',l_termination_date) = 0 THEN
     populate_run_msg(p_assactid,'The Date of Leaving  is invalid.');
     fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Date of Leaving  is invalid.');
     l_edi_validation_fail := 'Y';
    END IF;


  END IF;
  --
  hr_utility.set_location(l_proc,10);
  -- Archive info obtained so far
  archive_asg_info(g_assignment_number_eid, l_assignment_number);
  archive_asg_info(g_deceased_flag_eid, l_deceased_flag);
  archive_asg_info(g_aggregated_paye_flag_eid, l_agg_paye_flag);
  archive_asg_info(g_period_of_service_eid, l_period_of_service_id);
  archive_asg_info(g_effective_end_date_eid, fnd_date.date_to_canonical(l_asg_effective_end_date));
  archive_asg_info(g_organization_name_eid, l_org_name);
  archive_asg_info(g_last_name_eid, l_last_name);
  archive_asg_info(g_title_eid, l_title);
  archive_asg_info(g_first_name_eid, l_first_name);
  archive_asg_info(g_middle_name_eid, l_middle_name); /*Bug 6710229*/
  archive_asg_info(g_ni_number_eid, l_ni_number);
  archive_asg_info(g_date_of_birth_eid, fnd_date.date_to_canonical(l_date_of_birth));
  archive_asg_info(g_sex_eid, l_sex);
  IF g_payroll_id IS NULL THEN
    -- archive not restricted by payroll so stamp asg with payroll id.
    archive_asg_info(g_payroll_id_eid,
                     fnd_number.number_to_canonical(l_payroll_id));
  END IF;
  archive_asg_info(g_issue_date_eid, nvl(fnd_date.date_to_canonical(p_effective_date), fnd_date.date_to_canonical(sysdate)));
  --
  PAY_P45_PKG.get_data
    (X_PERSON_ID            => l_person_id,
     X_SESSION_DATE         => sysdate,
     X_ADDRESS_LINE1        => l_address_line1,
     X_ADDRESS_LINE2        => l_address_line2,
     X_ADDRESS_LINE3        => l_address_line3,
     X_TOWN_OR_CITY         => l_town_or_city,
     X_REGION_1             => l_county,
     X_COUNTRY              => l_country,
     X_POSTAL_CODE          => l_postal_code,
     X_ASSIGNMENT_ID        => l_assignment_id,
     X_ASSIGNMENT_ACTION_ID => l_last_asg_action_id,
     X_ASSIGNMENT_END_DATE  => l_asg_effective_end_date,
     X_DATE_EARNED          => l_date_earned,
     X_PAYROLL_ACTION_ID    => l_last_pay_action_id,
     X_TRANSFER_DATE        => l_transfer_date);
  --
  hr_utility.trace('Last asg action: '||to_char(l_last_asg_action_id));
  hr_utility.trace('Date earned : ' || to_char(l_date_earned));
  --
  IF g_do_edi_validation or g_edi_ver = 'V6' THEN

  EDI_MOVDED6_ASG(address_line1                 => l_address_line1,
                    address_line2               => l_address_line2,
                    address_line3               => l_address_line3,
                    assignment_number           => l_assignment_number,
                    county                      => l_county,
                    first_name                  => l_first_name,
                    middle_name                 => l_middle_name,
                    last_name                   => l_last_name,
                    national_insurance_number   => l_ni_number,
                    postal_code                 => l_postal_code,
                    title                       => l_title,
                    town_or_city                => l_town_or_city,
                    effective_date              => p_effective_date,
                    p_assactid                  => p_assactid,
                    edi_validation_fail         => l_edi_movded6_asg_flag);

    IF l_edi_movded6_asg_flag = 'Y' THEN
            l_edi_validation_fail := 'Y';
    END IF;
    /* All the validations are already done in EDI_MOVDED6_ASG so commenting out
    IF pay_gb_eoy_magtape.validate_input(upper(l_address_line1),
                                         'EDI_SURNAME') > 0 THEN
      hr_utility.set_message(801, 'PAY_78037_EDI_ILLEGAL_CHARS');
      hr_utility.set_message_token('ITEM_NAME', 'Address Line 1');
      hr_utility.raise_error;
    END IF;
    IF pay_gb_eoy_magtape.validate_input(upper(l_address_line2),
                                         'EDI_SURNAME') > 0 THEN
      hr_utility.set_message(801, 'PAY_78037_EDI_ILLEGAL_CHARS');
      hr_utility.set_message_token('ITEM_NAME', 'Address Line 2');
      hr_utility.raise_error;
    END IF;
    IF pay_gb_eoy_magtape.validate_input(upper(l_address_line3),
                                         'EDI_SURNAME') > 0 THEN
      hr_utility.set_message(801, 'PAY_78037_EDI_ILLEGAL_CHARS');
      hr_utility.set_message_token('ITEM_NAME', 'Address Line 3');
      hr_utility.raise_error;
    END IF;
    IF pay_gb_eoy_magtape.validate_input(upper(l_town_or_city),
                                         'FULL_EDI') > 0 THEN
      hr_utility.set_message(801, 'PAY_78037_EDI_ILLEGAL_CHARS');
      hr_utility.set_message_token('ITEM_NAME', 'Town or City');
      hr_utility.raise_error;
    END IF;
    IF pay_gb_eoy_magtape.validate_input(upper(l_county),
                                         'FULL_EDI') > 0 THEN
      hr_utility.set_message(801, 'PAY_78037_EDI_ILLEGAL_CHARS');
      hr_utility.set_message_token('ITEM_NAME', 'County');
      hr_utility.raise_error;
    END IF;
    IF pay_gb_eoy_magtape.validate_input(l_postal_code,
                                         'FULL_EDI') > 0 THEN
      hr_utility.set_message(801, 'PAY_78037_EDI_ILLEGAL_CHARS');
      hr_utility.set_message_token('ITEM_NAME', 'Postcode');
      hr_utility.raise_error;
    END IF;*/
  END IF;
  -- Archive info obtained so far
  archive_asg_info(g_p45_final_action, l_last_asg_action_id);
  archive_asg_info(g_address_line1_eid, l_address_line1);
  archive_asg_info(g_address_line2_eid, l_address_line2);
  archive_asg_info(g_address_line3_eid, l_address_line3);
  archive_asg_info(g_town_or_city_eid, l_town_or_city);
  archive_asg_info(g_county_eid, l_county);
  archive_asg_info(g_postal_code_eid, l_postal_code);
  archive_asg_info(g_country_eid, l_country);
  -- get the student loan flag
  l_student_loan_flag := PAY_P45_PKG.get_student_loan_flag
                           (l_assignment_id,
                            l_termination_date,
                            sysdate);
  -- get_db_and_bal_items
  -- Get database items.
  --
    -- Bug 5478073: If Final Payemnt not found or it is in a previous tax year
     -- then report the period no in which employee has been terminated
  IF l_last_asg_action_id = -9999 THEN
     OPEN csr_get_term_period_no(l_termination_date, l_payroll_id);
     FETCH csr_get_term_period_no INTO l_period_no;
     CLOSE csr_get_term_period_no;

    --Bug 7281023: Added to return 0 if period not found
    IF l_period_no IS NULL
    THEN
         l_period_no :=0;
     END IF;

     hr_utility.trace('After csr_get_term_period_no, l_termination_date='||fnd_date.date_to_displaydate(l_termination_date));
     hr_utility.trace('l_payroll_id='||l_payroll_id);
     hr_utility.trace('l_period_no='||l_period_no);
  ELSE
     OPEN csr_period_number(l_last_pay_action_id);
     FETCH csr_period_number INTO l_period_no;
     CLOSE csr_period_number;
     hr_utility.trace('After csr_period_number, l_last_pay_action_id='||l_last_pay_action_id);
     hr_utility.trace('l_period_no='||l_period_no);
  END IF;
  --
  -- Get element id for PAYE element
  OPEN csr_paye_element;
  FETCH csr_paye_element INTO l_paye_element_id;
  CLOSE csr_paye_element;

  -- BEGIN BUG FIX FOR 4595939 --
  hr_utility.trace('Date earned : ' || l_date_earned);
  hr_utility.trace('Final Process date : ' || l_final_process_date);

  if l_date_earned = sysdate then
     l_eff_date := l_final_process_date;
  else
     l_eff_date := l_date_earned;
  end if;

  get_tax_details(p_assignment_id   => l_assignment_id,
                  p_paye_details_id => g_paye_details_id,
                  p_paye_id         => l_paye_element_id,
                  p_eff_date        => l_eff_date,
                  p_tax_code        => l_tax_code,
                  p_tax_basis       => l_tax_basis,
                  p_prev_pay        => l_prev_pay_char,
                  p_prev_tax        => l_prev_tax_char);
/*
  -- Look into run results of PAYE element for tax details
  -- Get input_value_id for Tax Code input value
  OPEN csr_input_value('Tax Code');
  FETCH csr_input_value INTO l_tax_code_ipv_id;
  CLOSE csr_input_value;
  -- Get input_value_id for Tax Basis input value
  OPEN csr_input_value('Tax Basis');
  FETCH csr_input_value INTO l_tax_basis_ipv_id;
  CLOSE csr_input_value;
  -- Get input_value_id for Pay Previous input value
  OPEN csr_input_value('Pay Previous');
  FETCH csr_input_value INTO l_pay_previous_ipv_id;
  CLOSE csr_input_value;
  -- Get input_value_id for Tax Previous input value
  OPEN csr_input_value('Tax Previous');
  FETCH csr_input_value INTO l_tax_previous_ipv_id;
  CLOSE csr_input_value;
  -- Get tax code from run results of PAYE element
  BEGIN
     -- fix bug 4545963
     -- default the tax details first
     OPEN csr_paye_details(l_assignment_id,l_date_earned);
     FETCH csr_paye_details INTO l_tax_code,
                                 l_tax_basis,
                                 l_prev_pay_char,
                                 l_prev_tax_char;
     CLOSE csr_paye_details;

     -- If run result found, overwrite the value.
     -- Get max run_result_id for PAYE element
     OPEN csr_max_run_result;
     FETCH csr_max_run_result INTO l_max_run_result_id;
     CLOSE csr_max_run_result;
     -- if max run result found then get values from run result values else look at element entries
     IF l_max_run_result_id is not null THEN
        hr_utility.trace('Max run result found : ' || l_max_run_result_id);
        OPEN csr_result_value(l_tax_code_ipv_id);
        FETCH csr_result_value INTO l_tax_code_t;
        CLOSE csr_result_value;
        l_tax_code := nvl(l_tax_code_t, l_tax_code);
        --
        OPEN csr_result_value(l_tax_basis_ipv_id);
        FETCH csr_result_value INTO l_tax_basis_t;
        CLOSE csr_result_value;
        l_tax_basis := nvl(l_tax_basis_t, l_tax_basis);
        --
        OPEN csr_result_value(l_pay_previous_ipv_id);
        FETCH csr_result_value INTO l_prev_pay_char_t;
        CLOSE csr_result_value;
        l_prev_pay_char := nvl(l_prev_pay_char_t,l_prev_pay_char);
        --
        OPEN csr_result_value(l_tax_previous_ipv_id);
        FETCH csr_result_value INTO l_prev_tax_char_t;
        CLOSE csr_result_value;
        l_prev_tax_char := nvl(l_prev_tax_char_t,l_prev_tax_char);
        --
     END IF;
   */
   /*
     ELSE
         hr_utility.trace('Max run resuls not found');
        OPEN csr_paye_details(l_assignment_id,l_date_earned);
        FETCH csr_paye_details INTO l_tax_code,
                                    l_tax_basis,
                                    l_prev_pay_char,
                                    l_prev_tax_char;
        CLOSE csr_paye_details;
     END IF;
    */
  -- END;
  hr_utility.trace('tax code: '||l_tax_code||' '||l_tax_basis);
  --
  -- Get Balance items.
  --   Nb. parameter names of the following procedure are inconsistent with
  --       the actual values returned.
  PAY_P45_PKG2.get_balance_items(
    p_assignment_action_id => l_last_asg_action_id,
    p_gross_pay            => l_taxable,
    p_taxable_pay          => l_paye,
    p_agg_paye_flag        => l_agg_paye_flag);
  --
 -- Shifted Here from below to use it in side this validation
 IF l_tax_basis <> 'N' THEN
  IF   l_last_pay_action_id = -9999 then
	  OPEN week_month_by_paroll_id(l_payroll_id,p_effective_date);
	  FETCH week_month_by_paroll_id INTO l_week_or_month;
	  CLOSE week_month_by_paroll_id;
  ELSE
  	  OPEN csr_week_or_month(l_last_pay_action_id);
	  FETCH csr_week_or_month INTO l_week_or_month;
	  CLOSE csr_week_or_month;
  END IF ;
 END IF;

  IF g_do_edi_validation  or g_edi_ver = 'V6' THEN
    IF l_tax_basis = 'N' THEN
     /*Bug:8370481 Modifed the Total pay/tax to date and Pay/Tax in this Employment values from
       999999.99 to 999999999.99. */
      IF l_taxable > 999999999.99 THEN -- Bug:8370481 changed 999999.99 to 999999999.99
        hr_utility.set_message(801, 'PAY_78034_VALUE_EXCEEDS_MAX');
        hr_utility.set_message_token('ITEM_NAME', 'Pay in this Employment');
        hr_utility.set_message_token('MAX_VALUE', '999999999.99'); -- Bug:8370481 changed 999999.99 to 999999999.99
        hr_utility.raise_error;
      END IF;
      IF l_paye > 999999999.99 THEN -- Bug:8370481 changed 999999.99 to 999999999.99
        hr_utility.set_message(801, 'PAY_78034_VALUE_EXCEEDS_MAX');
        hr_utility.set_message_token('ITEM_NAME', 'Tax in this Employment');
        hr_utility.set_message_token('MAX_VALUE', '999999999.99'); -- Bug:8370481 changed 999999.99 to 999999999.99
        hr_utility.raise_error;
      END IF;
    ELSE
      IF nvl(l_taxable,0) + nvl(to_number(l_prev_pay_char),0) > 999999999.99 -- Bug:8370481 changed 999999.99 to 999999999.99
      THEN
        hr_utility.set_message(801, 'PAY_78034_VALUE_EXCEEDS_MAX');
        hr_utility.set_message_token('ITEM_NAME', 'Total pay to date');
        hr_utility.set_message_token('MAX_VALUE', '999999999.99'); -- Bug:8370481 changed 999999.99 to 999999999.99
        hr_utility.raise_error;
      END IF;
      IF nvl(l_paye,0) + nvl(to_number(l_prev_tax_char),0) > 999999999.99 THEN -- Bug:8370481 changed 999999.99 to 999999999.99
        hr_utility.set_message(801, 'PAY_78034_VALUE_EXCEEDS_MAX');
        hr_utility.set_message_token('ITEM_NAME', 'Total tax to date');
        hr_utility.set_message_token('MAX_VALUE', '999999999.99'); -- Bug:8370481 changed 999999.99 to 999999999.99
        hr_utility.raise_error;
      END IF;
    END IF; -- l_tax_basis = 'N'
    IF l_address_line1 IS NULL THEN
      hr_utility.set_message(801, 'PAY_GB_MISSING_VALUE');
      hr_utility.set_message_token('ITEM_NAME', 'Address');
      hr_utility.raise_error;
    END IF;
    IF l_tax_code IS NULL THEN
      hr_utility.set_message(801, 'PAY_GB_MISSING_VALUE');
      hr_utility.set_message_token('ITEM_NAME', 'Tax Code');
      hr_utility.raise_error;
    ELSIF length(ltrim(l_tax_code,'S')) > 6 THEN
      hr_utility.set_message(801, 'PAY_78034_VALUE_EXCEEDS_MAX');
      hr_utility.set_message_token('ITEM_NAME', 'Tax Code length');
      hr_utility.set_message_token('MAX_VALUE', '6 characters');
      hr_utility.raise_error;
    END IF;

    IF l_tax_basis = 'N' AND l_tax_code IS NULL THEN
        populate_run_msg(p_assactid,'The Tax Code at Leaving of the assignment must be defined if the Week1/Month1 indicator is defined.');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Tax Code at Leaving of the assignment must be defined if the Week1/Month1 indicator is defined.');
        l_edi_validation_fail := 'Y';
    END IF;

    IF l_tax_basis = 'N' AND l_week_or_month IS NOT NULL AND l_tax_code IS NOT NULL THEN
     populate_run_msg(p_assactid,'The Week/Month type of the assignment must not be defined if both the Tax Code at Leaving Date and the Week1/Month1 indicator are defined.');
     fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Week/Month type of the assignment must not be defined if both the Tax Code at Leaving Date and the Week1/Month1 indicator are defined.');
     l_edi_validation_fail := 'Y';
    END IF;

    IF l_tax_basis <> 'N' AND l_week_or_month IS  NULL AND l_tax_code IS NOT NULL THEN
      populate_run_msg(p_assactid,'The Week/Month type of the assignment must be defined if both the Tax Code at Leaving Date and the Week1/Month1 indicator are defined.');
      fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Week/Month type of the assignment must be defined if both the Tax Code at Leaving Date and the Week1/Month1 indicator are defined.');
     l_edi_validation_fail := 'Y';
    END IF;

    IF l_tax_basis <> 'N' AND l_period_no IS NOT NULL AND  l_week_or_month IS NULL THEN
      populate_run_msg(p_assactid,'The Week/Month type of the assignment must be defined if the Week/Month Number is defined.');
      fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Week/Month type of the assignment must be defined if the Week/Month Number is defined.');
     l_edi_validation_fail := 'Y';
    END IF;

    IF nvl(l_taxable,0) <> 0 AND nvl(l_paye,0) <> 0 THEN
	IF ((l_tax_basis ='N') OR (l_tax_basis <> 'N' AND trunc(nvl(to_number(l_prev_pay_char),0) * 100) <> 0 AND trunc(nvl(to_number(l_prev_tax_char),0) * 100) <> 0)) THEN
           l_pay_in_this_emp := to_char(trunc(l_taxable * 100));
      END IF;
    END IF;

    IF nvl(l_taxable,0) <> 0 AND nvl(l_paye,0) <> 0 THEN
      IF ((l_tax_basis ='N') OR (l_tax_basis <> 'N' AND trunc(nvl(to_number(l_prev_pay_char),0) * 100) <> 0 AND trunc(nvl(to_number(l_prev_tax_char),0) * 100) <> 0)) THEN
           IF l_paye >= 0 then
            l_tax_in_this_emp := to_char(trunc(l_paye * 100));
           ELSE
            l_tax_in_this_emp := 0;
            less_than_zero_flag := 'Y';
           END IF;
      END IF;
    END IF;

    IF ( nvl(l_taxable,0) <> 0 OR nvl(to_number(l_prev_pay_char),0) <> 0 ) AND
       ( nvl(l_paye,0) <> 0 OR nvl(to_number(l_prev_tax_char),0) <> 0) THEN
       IF l_tax_basis <> 'N' THEN
          l_total_pay_to_date := to_char(trunc(l_taxable * 100) + trunc(l_prev_pay_char * 100));
       END IF;
    END IF;

    IF ( nvl(l_taxable,0) <> 0 OR nvl(to_number(l_prev_pay_char),0) <> 0 ) AND
       ( nvl(l_paye,0) <> 0 OR nvl(to_number(l_prev_tax_char),0) <> 0 ) THEN
       IF l_tax_basis <> 'N' THEN
          l_total_tax_to_date := to_char(trunc(l_paye * 100) + trunc(l_prev_tax_char * 100));
       END IF;
    END IF;



    /*IF l_tax_basis ='N' AND l_pay_in_this_emp IS NULL THEN
        populate_run_msg(p_assactid,'The Total Pay in this Employment of the assignment must be defined if the Week1/Month1 indicator is defined.');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Total Pay in this Employment of the assignment must be defined if the Week1/Month1 indicator is defined.');
        l_edi_validation_fail := 'Y';
    END IF;

    IF l_tax_basis ='N' AND l_tax_in_this_emp IS NULL THEN
        populate_run_msg(p_assactid,'The Tax Deducted in this Employment of the assignment must be defined if the Week1/Month1 indicator is defined.');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Tax Deducted in this Employment of the assignment must be defined if the Week1/Month1 indicator is defined.');
        l_edi_validation_fail := 'Y';
    END IF;*/
--
    IF l_pay_in_this_emp IS NOT NULL THEN
      /*IF l_tax_in_this_emp IS NULL THEN
           populate_run_msg(p_assactid,'The Total Pay in this Employment of the assignment must be defined if the Tax Deducted in this employment is defined.');
           fnd_file.put_line (fnd_file.LOG,l_assignment_number||' :The Total Pay in this Employment of the assignment must be defined if the Tax Deducted in this employment is defined.');
           l_edi_validation_fail := 'Y';
      END IF;*/  -- Tax can be Zero even if pay is not Zero

      IF pay_gb_eoy_magtape.validate_input(l_pay_in_this_emp,'NUMBER_1') > 0 THEN
          populate_run_msg(p_assactid,'The Total Pay in this Employment of the assignment has invalid character(s).');
          fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Total Pay in this Employment of the assignment has invalid character(s).');
          l_edi_validation_fail := 'Y';
      END IF;

      IF to_number(l_pay_in_this_emp) < 0 THEN
          populate_run_msg(p_assactid,'The Total Pay in this Employment of the assignment is Less Than 0');
          fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Total Pay in this Employment of the assignment is Less Than 0');
          l_edi_validation_fail := 'Y';
      END IF;

      IF l_tax_in_this_emp IS NOT NULL THEN
          IF to_number(l_pay_in_this_emp) < to_number(l_tax_in_this_emp) THEN
              populate_run_msg(p_assactid,'The Tax Deducted in this employment of the assignment must be Less Than or equal to the Total Pay in this employment.');
              fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Tax Deducted in this employment of the assignment must be Less Than or equal to the Total Pay in this employment.');
              l_edi_validation_fail := 'Y';
          END IF;
      END IF;
    END IF;
--
    IF l_tax_in_this_emp IS NOT NULL THEN
        IF l_pay_in_this_emp IS NULL THEN
            populate_run_msg(p_assactid,'The Tax Deducted in this Employment of the assignment must be defined if the Total Pay in this employment is defined.');
            fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Tax Deducted in this Employment of the assignment must be defined if the Total Pay in this employment is defined.');
            l_edi_validation_fail := 'Y';
        END IF;

       IF pay_gb_eoy_magtape.validate_input(l_tax_in_this_emp,'NUMBER_1') > 0 THEN
          populate_run_msg(p_assactid,'The Tax Deducted in this Employment of the assignment has invalid character(s).');
          fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Tax Deducted in this Employment of the assignment has invalid character(s).');
          l_edi_validation_fail := 'Y';
       ELSIF  less_than_zero_flag = 'Y' THEN
          populate_run_msg(p_assactid,'The Tax Deducted in this Employment of the assignment is Less Than 0; printing the amount as Zero.');
          fnd_file.put_line (fnd_file.LOG,'The Tax Deducted in this Employment of the assignment is Less Than 0; printing the amount as Zero.');
      -- Not raising an error as this is a warning
       END IF;
   END IF;

   IF  l_total_pay_to_date IS NOT NULL THEN
     /*IF l_tax_basis = 'N' THEN
        populate_run_msg(p_assactid,'The Total Pay to Date of the assignment must not be defined if the Week1/Month1 indicator is defined.');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Total Pay to Date of the assignment must not be defined if the Week1/Month1 indicator is defined.');
        l_edi_validation_fail := 'Y';
     END IF;*/-- Commenting the code as Total Pay to Date can be Zero and it is legitame to have no pay
              -- This case will be handled at the EDi level

     IF pay_gb_eoy_magtape.validate_input(l_total_pay_to_date,'NUMBER_1') > 0 THEN
        populate_run_msg(p_assactid,'The Total Pay to Date of the assignment has invalid character(s).');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Total Pay to Date of the assignment has invalid character(s).');
        l_edi_validation_fail := 'Y';
     ELSIF to_number(l_total_pay_to_date) < 0 THEN
        populate_run_msg(p_assactid,'The Total Pay to Date of the assignment is Less Than 0.');
        fnd_file.put_line (fnd_file.LOG,'The Total Pay to Date of the assignment is Less Than 0.');
        l_edi_validation_fail := 'Y';
     END IF;

     IF l_total_tax_to_date IS NOT NULL THEN
        IF (to_number(l_total_pay_to_date) < to_number(l_total_tax_to_date)) THEN
        populate_run_msg(p_assactid,'The Total Tax to Date of the assignment must be Less Than or equal to the Total Pay to Date.');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Total Tax to Date of the assignment must be Less Than or equal to the Total Pay to Date.');
        l_edi_validation_fail := 'Y';
        END IF;
     END IF;
   END IF;

   IF  l_total_pay_to_date IS NULL THEN
     IF l_total_tax_to_date IS NOT NULL THEN
       populate_run_msg(p_assactid,'The Total Pay to Date of the assignment  must be defined if the Total Tax to Date is defined.');
       fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Total Pay to Date of the assignment  must be defined if the Total Tax to Date is defined.');
       l_edi_validation_fail := 'Y';
     END IF;

    /* IF l_tax_basis <> 'N' THEN
      populate_run_msg(p_assactid,'The Total Pay to Date of the assignment must be defined if the Week1/Month1 indicator is not defined.');
      fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Total Pay to Date of the assignment must be defined if the Week1/Month1 indicator is not defined.');
      l_edi_validation_fail := 'Y';
     END IF;*/-- Commenting the code as Total Pay to Date can be Zero and it is legitame to have no pay
              -- This case will be handled at the EDi level
   END IF;

   IF  l_total_tax_to_date IS NOT NULL THEN
     /*IF l_tax_basis = 'N' THEN
        populate_run_msg(p_assactid,'The Total Tax to Date of the assignment must not be defined if the Week1/Month1 indicator is defined.');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Total Tax to Date of the assignment must not be defined if the Week1/Month1 indicator is defined.');
        l_edi_validation_fail := 'Y';
     ELSIF */
     IF pay_gb_eoy_magtape.validate_input(l_total_tax_to_date,'NUMBER_1') > 0 THEN
        populate_run_msg(p_assactid,'The Total Tax to Date of the assignment has invalid character(s).');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Total Tax to Date of the assignment has invalid character(s).');
        l_edi_validation_fail := 'Y';
     END IF;

     IF to_number(l_total_tax_to_date) < 0 THEN
        populate_run_msg(p_assactid,'The Total Tax to Date of the assignment is Less Than 0.');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Total Tax to Date of the assignment is Less Than 0.');
        l_edi_validation_fail := 'Y';
     END IF;
   END IF;

  /*IF  l_total_tax_to_date IS  NULL THEN
    IF l_total_pay_to_date IS NOT NULL THEN
      populate_run_msg(p_assactid,'The Total Tax to Date of the assignment must be defined if the Total Pay to Date is defined.');
      fnd_file.put_line (fnd_file.LOG,l_assignment_number||' :The Total Tax to Date of the assignment must be defined if the Total Pay to Date is defined.');
      l_edi_validation_fail := 'Y'; -- Total Tax can be Zero even though the employee has total pay
    ELSIF l_tax_basis <> 'N' THEN
      populate_run_msg(p_assactid,'The Total Tax to Date of the assignment  must be defined if the Week1/Month1 indicator is not defined.');
      fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Total Tax to Date of the assignment  must be defined if the Week1/Month1 indicator is not defined.');
      l_edi_validation_fail := 'Y';
    END IF;
  END IF; */ -- Total Tax zan be Zero if tax basis is not N

  IF l_tax_code IS NULL THEN
      populate_run_msg(p_assactid,'The Tax Code at Leaving Date is missing.');
      fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Tax Code at Leaving Date is missing.');
     l_edi_validation_fail := 'Y';
  ELSIF pay_gb_eoy_magtape.validate_tax_code_yrfil(p_assactid,l_tax_code,p_effective_date) <> ' ' THEN
      populate_run_msg(p_assactid,'The Tax Code at Leaving Date is invalid.');
      fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Tax Code at Leaving Date is invalid.');
      l_edi_validation_fail := 'Y';
  END IF;

  IF l_week_or_month IS NOT NULL THEN
    IF l_week_or_month = 'W' THEN
      IF l_period_no < 1 OR l_period_no = 55 OR l_period_no > 56 THEN
         populate_run_msg(p_assactid,'The Week/Month Number of the assignment must be between 1 to 54 or 56 as the Week/Month Type is Weekly.');
         fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Week/Month Number of the assignment must be between 1 to 54 or 56 as the Week/Month Type is Weekly.');
         l_edi_validation_fail := 'Y';
      END IF;
    ELSIF l_week_or_month = 'M' THEN
      IF l_period_no < 1 OR l_period_no > 12 THEN
        populate_run_msg(p_assactid,'The Week/Month Number of the assignment must be between 1 to 12 as the Week/Month Type is Monthly.');
        fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Week/Month Number of the assignment must be between 1 to 12 as the Week/Month Type is Monthly.');
        l_edi_validation_fail := 'Y';
      END IF;
    END IF;
  END IF;

  IF  l_edi_validation_fail = 'Y' THEN
    raise_application_error (-20001, 'The Process Failed as there were Errors for this assignment' );
  END IF;

  END IF; -- g_do_edi_validation
  -- Check Whether it is Week or Month
  /*OPEN csr_week_or_month(l_last_pay_action_id);
  FETCH csr_week_or_month INTO l_week_or_month;
  CLOSE csr_week_or_month;*/ -- Shifted above g_do_edi_validation
  --
  -- Archive info obtained so far
  archive_asg_info(g_student_loan_flag_eid, l_student_loan_flag);
  IF l_week_or_month = 'W' THEN
    archive_asg_info(g_week_number_eid, l_period_no);
  ELSE
    archive_asg_info(g_month_number_eid, l_period_no);
  END IF;

  archive_asg_info(g_tax_code_eid, l_tax_code);
  IF l_tax_basis = 'N' THEN
    archive_asg_info(g_w1_m1_indicator_eid, 'X');
  END IF;
  archive_asg_info(g_prev_taxable_pay_eid, l_prev_pay_char);
  archive_asg_info(g_prev_tax_paid_eid, l_prev_tax_char);
  archive_asg_info(g_taxable_pay_eid,
                   fnd_number.number_to_canonical(l_taxable));
  archive_asg_info(g_tax_paid_eid,
                   fnd_number.number_to_canonical(l_paye));
  --
  hr_utility.set_location(' Leaving: '||l_proc,999);
  --hr_utility.trace_off;
END archive_code;
--
PROCEDURE spawn_reports
IS
  l_proc             CONSTANT VARCHAR2(35):= g_package||'spawn_reports';
  --
  l_count                NUMBER := 0;
  l_dummy                NUMBER;
  l_print_style          VARCHAR2(2);
  l_report_short_name    VARCHAR2(20);
  l_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
  l_number_of_copies     fnd_concurrent_requests.number_of_copies%TYPE;
  l_request_id           NUMBER:=-1;
  l_formula_id           ff_formulas_f.formula_id%TYPE;
  --
  l_print_together       VARCHAR2(80);
  l_print_return         BOOLEAN;
  l_stationary           VARCHAR2(2); /*P45 A4 2008-09 changes */
  l_defer_print          VARCHAR2(1);
  xml_layout             BOOLEAN ; /*P45 A4 2008-09 changes */
  l_printer_style        fnd_concurrent_requests.print_style%TYPE; --Bug 9170440

  --
  cursor csr_get_formula_id(p_formula_name VARCHAR2) IS
  SELECT a.formula_id
  FROM   ff_formulas_f a,
         ff_formula_types t
  WHERE a.formula_name      = p_formula_name
    AND business_group_id   IS NULL
    AND legislation_code    = 'GB'
    AND a.formula_type_id   = t.formula_type_id
    AND t.formula_type_name = 'Oracle Payroll';
  --
  cursor csr_get_print_options(p_payroll_action_id NUMBER) IS
  SELECT printer,
        print_style,
        decode(save_output_flag, 'Y', 'TRUE', 'N', 'FALSE') save_output
  FROM  pay_payroll_actions pact,
        fnd_concurrent_requests fcr
  WHERE fcr.request_id = pact.request_id
  AND   pact.payroll_action_id = p_payroll_action_id;
  --
  cursor get_errored_actions(c_payroll_action_id number) is
  select 1 from dual where exists
   (select action_status
   from   pay_assignment_actions
   where payroll_action_id = c_payroll_action_id
   and action_status = 'E');
  --
  /*P45 A4 2008-09 changes */
  /*Cursor to fetch stationary type and differ printing option*/
  cursor csr_get_stationary_defer(c_payroll_action_id NUMBER) IS
  select
    pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                               'P45') stationary_type,
    pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'PDEF') defer_print
  from  pay_payroll_actions
  where payroll_action_id = c_payroll_action_id;
 /*P45 A4 2008-09 changes */
 --
  rec_print_options  csr_get_print_options%ROWTYPE;
  --
BEGIN
  hr_utility.set_location('Entering: '||l_proc,1);
  -- get pertinent SRS parameters from the pay_mag_tape tables
  BEGIN
    LOOP
      l_count := l_count + 1;
      IF pay_mag_tape.internal_prm_names(l_count) =
        'TRANSFER_PAYROLL_ACTION_ID'
      THEN
        l_payroll_action_id := to_number(pay_mag_tape.internal_prm_values
                                         (l_count));
      ELSIF pay_mag_tape.internal_prm_names(l_count) = 'P45'
      THEN
        l_print_style := pay_mag_tape.internal_prm_values(l_count);
      ELSIF pay_mag_tape.internal_prm_names(l_count) = 'PDEF'
      THEN
        IF pay_mag_tape.internal_prm_values(l_count) = 'Y' THEN
          -- Defer printing param set to Y
          l_number_of_copies := 0;
        ELSE
          l_number_of_copies := 1;
        END IF;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN no_data_found THEN
      -- Use this exception to exit loop as no. of plsql tab items
      -- is not known beforehand. All values should be assigned.
      NULL;
    WHEN value_error THEN
      NULL;
  END;
  --
  -- Check no assignment actions were errored
  open get_errored_actions(l_payroll_action_id);
  fetch get_errored_actions into l_dummy;
  if get_errored_actions%notfound then
    -- No errors, so set up print options and spawn report.
    IF l_print_style = 'L'
    THEN l_report_short_name := 'PAYGB45L';
    ELSE l_report_short_name := 'PAYRPP45';
    END IF;
    --
    hr_utility.set_location(l_proc,10);
    -- Get printer options from archive request
    OPEN csr_get_print_options(l_payroll_action_id);
    FETCH csr_get_print_options INTO rec_print_options;
    CLOSE csr_get_print_options;
    --
    l_print_together := nvl(fnd_profile.value('CONC_PRINT_TOGETHER'), 'N');
    --

    -- Get the stationary and defer printing options
    OPEN csr_get_stationary_defer(l_payroll_action_id);
    FETCH csr_get_stationary_defer INTO l_stationary,l_defer_print;
    CLOSE csr_get_stationary_defer;

    -- Start of bug 8275145
   IF upper(l_stationary) = 'C3' or upper(l_stationary) = 'C4' then
	l_printer_style := 'P45C';
   else
	l_printer_style := rec_print_options.print_style;
   end if;
    -- Start of bug 8275145

    -- Set printer options
    l_print_return := fnd_request.set_print_options
                        (printer        => rec_print_options.printer,
                         style          => l_printer_style,
                         copies         => l_number_of_copies,
                         save_output    => hr_general.char_to_bool
                                             (rec_print_options.save_output),
                         print_together => l_print_together);
    hr_utility.trace('Print options set call returned: '||
                     hr_general.bool_to_char(l_print_return));

    -- Submit report
   /*P45 A4 2008-09 changes */
    /*l_request_id := fnd_request.submit_request
      (application => 'PAY',
       program     => l_report_short_name,
       argument1  =>  l_payroll_action_id);*/

    -- Submit report
    IF upper(l_defer_print) = 'N' then
        IF upper(l_stationary) = 'C' then
        l_request_id := fnd_request.submit_request
                          (application => 'PAY',
                           program     => 'PAYRPP45',
                           argument1  =>  l_payroll_action_id);
         ELSIF upper(l_stationary) = 'L' then
         l_request_id := fnd_request.submit_request
                          (application => 'PAY',
                           program     => 'PAYGB45L',
                           argument1  =>  l_payroll_action_id);
          -- Start of bug 8275145
         ELSIF upper(l_stationary) = 'C3' then
         l_request_id := fnd_request.submit_request
                          (application => 'PAY',
                           program     => 'PAYRPP45',
                           argument1  =>  l_payroll_action_id,
                           argument2  =>  null,
                           argument3  =>  'Continuous (A4 Sheet 3-Part)');
         ELSIF upper(l_stationary) = 'C4' then
         l_request_id := fnd_request.submit_request
                          (application => 'PAY',
                           program     => 'PAYRPP45',
                           argument1  =>  l_payroll_action_id,
                           argument2  =>  null,
                           argument3  =>  'Continuous (A4 Sheet 4-Part)');
          -- end of bug 8275145
         ELSIF upper(l_stationary) = 'P' then
         xml_layout := FND_REQUEST.ADD_LAYOUT('PAY','PYGBA4P45','en','US','PDF');
            IF xml_layout = true then
                l_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'PAY',
                                                        program => 'PYGBA4P45',
                                                        argument1  =>  l_payroll_action_id);
            END IF;
         ELSIF upper(l_stationary) = 'A' then
         xml_layout := FND_REQUEST.ADD_LAYOUT('PAY','PYGBA4P45LS','en','US','PDF');
            IF xml_layout = true then
                 l_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'PAY',
                                                        program => 'PYGBA4P45',
                                                        argument1  =>  l_payroll_action_id);
            END IF;
          -- Start bug 8275145
          ELSIF upper(l_stationary) = 'A4' then
          xml_layout := FND_REQUEST.ADD_LAYOUT('PAY','PYGBA4P45LS4','en','US','PDF');
            IF xml_layout = true then
                 l_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'PAY',
                                                        program => 'PYGBA4P45',
                                                        argument1  =>  l_payroll_action_id);
            END IF;
          -- ENd bug 8275145
         END IF;
     ELSIF upper(l_defer_print) = 'Y' then
     l_request_id := -2;
     END IF;
     /*P45 A4 2008-09 changes */
    --
    IF l_request_id = 0 THEN
      g_fnd_rep_request_msg := fnd_message.get;
    END IF;    --
  end if;  -- get_errored_actions%notfound
  --
  close get_errored_actions;
  -- Set up formula inputs
  hr_utility.set_location(l_proc,20);
  OPEN csr_get_formula_id('PAY_GB_P45_REPORT_SUBMISSION');
  FETCH csr_get_formula_id INTO l_formula_id;
  CLOSE csr_get_formula_id;
  --
  pay_mag_tape.internal_prm_names(1) := 'NO_OF_PARAMETERS';
  pay_mag_tape.internal_prm_values(1) := '4';
  pay_mag_tape.internal_prm_names(2) := 'NEW_FORMULA_ID';
  pay_mag_tape.internal_prm_values(2) := to_char(l_formula_id);
  pay_mag_tape.internal_prm_names(3) := 'P45_REQUEST_ID';
  pay_mag_tape.internal_prm_values(3) := to_char(l_request_id);
  pay_mag_tape.internal_prm_names(4) := 'PAYROLL_ACTION_ID';
  pay_mag_tape.internal_prm_values(4) := to_char(l_payroll_action_id);
  --
  -- Exit procedure, C code will fire formula
  hr_utility.set_location(' Leaving: '||l_proc,999);
END spawn_reports;
--
PROCEDURE edi_act_creation(pactid IN NUMBER,
                           stperson IN NUMBER,
                           endperson IN NUMBER,
                           chunk IN NUMBER)
IS
  l_proc             CONSTANT VARCHAR2(35):= g_package||'edi_act_creation';
  l_actid            pay_assignment_actions.assignment_action_id%TYPE;
  --
  cursor csr_user_entity(p_entity_name VARCHAR2) IS
  SELECT user_entity_id
  FROM   ff_user_entities
  WHERE  user_entity_name = p_entity_name
    AND  legislation_code = 'GB'
    AND  business_group_id IS NULL;
  --
  cursor csr_parameter_info(p_payroll_action_id NUMBER) IS
  SELECT
    to_number(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                               'PAYROLL_ID')) payroll_id,
    substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'TAX_REF'),1,20) tax_ref,
    fnd_date.canonical_to_date
      (pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                        'DATE_FROM')) start_date,
    effective_date end_date,
    business_group_id
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
  --
  cursor csr_assignments IS
  -- Do not restrict to the last P45 archive action for each employee - get
  -- all that are not interlocked
  -- Restrict on payroll_id legislative parameter as necessary.  If payroll
  -- not specified on Archive submission, token will not appear in the
  -- legislative parameters, so ensure substr returns null by concatenating
  -- the token.
  -- If EDI process is restricted by payroll but archive wasn't, need to
  -- drill down to asg level and restrict on the payroll_id in the archive.
  -- Performance fix bug 5202965
  SELECT /*+ ORDERED */
         DISTINCT
         act.assignment_action_id archive_action,
         act.assignment_id
  FROM   pay_payroll_actions    pact,
         pay_assignment_actions act,
         per_assignments_f      paf,
         pay_action_interlocks  pai,
         ff_archive_items       fai
  WHERE  pact.report_type       ='P45'
  AND    pact.report_qualifier  ='GB'
  AND    pact.report_category   ='P45'
  AND    pact.action_status     = 'C'
  AND    pact.action_type       = 'X'
  AND    pact.business_group_id +0 = g_business_group_id
  AND    pact.effective_date BETWEEN g_start_date AND g_end_date
  AND    substr(pact.legislative_parameters,
                instr(pact.legislative_parameters,'TAX_REF=') + 8,
                    instr(pact.legislative_parameters||' ',' ',
                          instr(pact.legislative_parameters,'TAX_REF=')+8)
                - instr(pact.legislative_parameters,'TAX_REF=') - 8)
         = g_tax_ref
  AND   (g_payroll_id IS NULL
         OR
         nvl(substr(pact.legislative_parameters,
                    instr(pact.legislative_parameters||' PAYROLL_ID='
                         ,'PAYROLL_ID=') + 11,
                    instr(pact.legislative_parameters||' ',' ',
                          instr(pact.legislative_parameters,'PAYROLL_ID=')+11)
                    - instr(pact.legislative_parameters,'PAYROLL_ID=') - 11),
             nvl(to_char(g_payroll_id),'x')) = nvl(to_char(g_payroll_id),'x'))
  /* restrict by payroll_id in archive */
  AND    fai.context1 (+)       = act.assignment_action_id
  AND    fai.user_entity_id (+) = g_payroll_id_eid
  AND    nvl(fai.VALUE,nvl(to_char(g_payroll_id),'x'))
                     = nvl(nvl(to_char(g_payroll_id),fai.VALUE),'x')
  AND    pact.payroll_action_id = act.payroll_action_id
  AND    paf.assignment_id      = act.assignment_id
  AND    paf.person_id BETWEEN stperson AND endperson
  AND    paf.business_group_id +0 = g_business_group_id
  /* restrict to one row per asg.  */
  -- Comment out this code as it will be replace by distinct
  --AND    paf.effective_start_date =
  --                  (SELECT max(paf2.effective_start_date)
  --                   FROM   per_assignments_f paf2
  --                   WHERE  paf2.assignment_id = paf.assignment_id)
  /* commnet out this code and replace by the code below */
  --AND    NOT EXISTS (SELECT 1
  --                   FROM   pay_action_interlocks pai
  --                   WHERE  pai.locked_action_id = act.assignment_action_id);
  AND    pai.locked_action_id(+) = act.assignment_action_id
  AND    decode(pai.locked_action_id,null,1,2) = 1;
  --
  cursor csr_range_assignments is
  --
  -- This is a copy of csr_assignments above except with a join to pay_
  -- population_ranges for performance enhancement.
  --
  -- Used Not Exists instead of using Outer Join : Bug :7442831
 SELECT   /*+ordered
          index(pact PAY_PAYROLL_ACTIONS_N52)
	  index(ppr PAY_POPULATION_RANGES_N4)
          index(act PAY_ASSIGNMENT_ACTIONS_N51)
	  index(fai FF_ARCHIVE_ITEMS_N50)*/
	  DISTINCT
         act.assignment_action_id archive_action,
         act.assignment_id
   from  pay_payroll_actions    pact,
         pay_population_ranges  ppr,
         per_assignments_f      paf,
         pay_assignment_actions act,
         ff_archive_items       fai
  WHERE  pact.report_type       ='P45'
  AND    pact.report_qualifier  ='GB'
  AND    pact.report_category   ='P45'
  AND    pact.action_status     = 'C'
  AND    pact.action_type       = 'X'
  AND    pact.business_group_id +0 = g_business_group_id
  AND    pact.effective_date BETWEEN g_start_date AND g_end_date
  AND    substr(pact.legislative_parameters,
                instr(pact.legislative_parameters,'TAX_REF=') + 8,
                    instr(pact.legislative_parameters||' ',' ',
                          instr(pact.legislative_parameters,'TAX_REF=')+8)
                - instr(pact.legislative_parameters,'TAX_REF=') - 8)
         = g_tax_ref
  AND   (g_payroll_id IS NULL
         OR
         nvl(substr(pact.legislative_parameters,
                    instr(pact.legislative_parameters||' PAYROLL_ID='
                         ,'PAYROLL_ID=') + 11,
                    instr(pact.legislative_parameters||' ',' ',
                          instr(pact.legislative_parameters,'PAYROLL_ID=')+11)
                    - instr(pact.legislative_parameters,'PAYROLL_ID=') - 11),
             nvl(to_char(g_payroll_id),'x')) = nvl(to_char(g_payroll_id),'x'))
  /* restrict by payroll_id in archive */
  AND    fai.context1 (+)       = act.assignment_action_id
  AND    fai.user_entity_id (+) = g_payroll_id_eid
  AND    nvl(fai.VALUE,nvl(to_char(g_payroll_id),'x'))
                                = nvl(nvl(to_char(g_payroll_id),fai.VALUE),'x')
  AND    pact.payroll_action_id = act.payroll_action_id
  AND    paf.assignment_id      = act.assignment_id
  AND    paf.person_id = ppr.person_id
  AND    ppr.chunk_number = chunk
  AND    ppr.payroll_action_id = pactid
  AND    paf.business_group_id +0 = g_business_group_id
  /* restrict to one row per asg.  */
  /* Comment out the code for performance fix */
  --AND    paf.effective_start_date =
  --                  (SELECT max(paf2.effective_start_date)
  --                   FROM   per_assignments_f paf2
  --                   WHERE  paf2.assignment_id = paf.assignment_id)
  AND    NOT EXISTS (SELECT 1
                     FROM   pay_action_interlocks pai
                     WHERE  pai.locked_action_id = act.assignment_action_id);

BEGIN
  hr_utility.set_location('Entering: '||l_proc,1);
  --
  IF NOT g_asg_creation_cache_populated THEN
    OPEN csr_user_entity('X_PAYROLL_ID');
    FETCH csr_user_entity INTO g_payroll_id_eid;
    CLOSE csr_user_entity;
    --
    OPEN csr_parameter_info(pactid);
    FETCH csr_parameter_info INTO g_payroll_id,
                                  g_tax_ref,
                                  g_start_date,
                                  g_end_date,
                                  g_business_group_id;
    CLOSE csr_parameter_info;
    --
    g_asg_creation_cache_populated := true;
  END IF;
  --
  hr_utility.trace('Payroll ID : ' || g_payroll_id);
  hr_utility.trace('Tax Ref    : ' || g_tax_ref);
  hr_utility.trace('Start      : ' || g_start_date);
  hr_utility.trace('End        : ' || g_end_date);
  hr_utility.trace('Bus ID     : ' || g_business_group_id);
  hr_utility.trace('Chunk      : ' || chunk);
  hr_utility.trace('EID        : ' || g_payroll_id_eid);
  IF range_person_on('PAY_GB_P45_EDI') then
    --
    -- Range Person functionality enabled, use new cursor.
    --
    hr_utility.set_location(l_proc,20);
    FOR rec_asg IN csr_range_assignments LOOP
       --
       hr_utility.set_location(l_proc,25);
       SELECT pay_assignment_actions_s.nextval
         INTO l_actid
         FROM dual;
       --
       hr_utility.set_location(l_proc,27);
       hr_nonrun_asact.insact(l_actid,rec_asg.assignment_id,
                              pactid,chunk,NULL);
       -- Interlock the archive action
       hr_utility.set_location(l_proc,29);
       hr_nonrun_asact.insint(l_actid, rec_asg.archive_action);
     END LOOP;
     --
  ELSE
    --
    -- Range Person functionality not enabled, use original cursor
    --
    hr_utility.set_location(l_proc,30);
    FOR rec_asg IN csr_assignments LOOP
       --
       SELECT pay_assignment_actions_s.nextval
         INTO l_actid
         FROM dual;
       --
       hr_nonrun_asact.insact(l_actid,rec_asg.assignment_id,
                              pactid,chunk,NULL);
       -- Interlock the archive action
       hr_nonrun_asact.insint(l_actid, rec_asg.archive_action);
    END LOOP;
  --
  END IF; -- range person check.
  --
  hr_utility.set_location(' Leaving: '||l_proc,999);
END edi_act_creation;

--
-- Populate P45 form with archived information where appropriate
-- archived info exists
--
procedure pop_term_asg_from_archive(X_ASSIGNMENT_ACTION_ID  in number,
                                X_NI1                   in out nocopy varchar2,
                                X_NI2                   in out nocopy varchar2,
                                X_NI3                   in out nocopy varchar2,
                                X_NI4                   in out nocopy varchar2,
                                X_NI5                   in out nocopy varchar2,
                                X_NI6                   in out nocopy varchar2,
                                X_NI7                   in out nocopy varchar2,
                                X_NI8                   in out nocopy varchar2,
                                X_NI9                   in out nocopy varchar2,
                                X_LAST_NAME             in out nocopy varchar2,
                                X_TITLE                 in out nocopy varchar2,
                                X_FIRST_NAME            in out nocopy varchar2,
                                X_DATE_OF_LEAVING_DD    in out nocopy varchar2,
                                X_DATE_OF_LEAVING_MM    in out nocopy varchar2,
                                X_DATE_OF_LEAVING_YY    in out nocopy varchar2,
                                X_TAX_CODE_AT_LEAVING   in out nocopy varchar2,
                                X_WK1_OR_MTH1           in out nocopy varchar2,
                                X_WEEK_NO               in out nocopy varchar2,
                                X_MONTH_NO              in out nocopy varchar2,
                                X_PAY_TD_POUNDS         in out nocopy number,
                                X_PAY_TD_PENCE          in out nocopy number,
                                X_TAX_TD_POUNDS         in out nocopy number,
                                X_TAX_TD_PENCE          in out nocopy number,
                                X_PAY_IN_EMP_POUNDS     in out nocopy number,
                                X_PAY_IN_EMP_PENCE      in out nocopy number,
                                X_TAX_IN_EMP_POUNDS     in out nocopy number,
                                X_TAX_IN_EMP_PENCE      in out nocopy number,
                                X_ASSIGNMENT_NUMBER     in out nocopy varchar2,
                                X_ORG_NAME              in out nocopy varchar2,
                                X_ADDRESS_LINE1         in out nocopy varchar2,
                                X_ADDRESS_LINE2         in out nocopy varchar2,
                                X_ADDRESS_LINE3         in out nocopy varchar2,
                                X_TOWN_OR_CITY          in out nocopy varchar2,
                                X_REGION_1              in out nocopy varchar2,
                                X_POSTAL_CODE           in out nocopy varchar2,
                                X_DECEASED_FLAG         in out nocopy varchar2,
                                X_ISSUE_DATE            in out nocopy varchar2,
                                X_TAX_REF_TRANSFER      in out nocopy varchar2,
                                X_STUDENT_LOAN_FLAG     in out nocopy varchar2,
                                X_COUNTRY               in out nocopy varchar2,
				X_DATE_OF_BIRTH_DD      in out nocopy varchar2,    /*Start P45 A4 2008/09*/
                                X_DATE_OF_BIRTH_MM      in out nocopy varchar2,
                                X_DATE_OF_BIRTH_YY      in out nocopy varchar2,
                                X_SEX_M                 in out nocopy varchar2,
                                X_SEX_F                 in out nocopy varchar2)    /*End P45 A4 2008/09*/
is
 cursor cur_get_asg_archive_items is
 select    nvl(substr(max(decode(fue.user_entity_name,'X_NATIONAL_INSURANCE_NUMBER',fai.VALUE)),1,1),' ') NINO1,
           nvl(substr(max(decode(fue.user_entity_name,'X_NATIONAL_INSURANCE_NUMBER',fai.VALUE)),2,1),' ') NINO2,
           nvl(substr(max(decode(fue.user_entity_name,'X_NATIONAL_INSURANCE_NUMBER',fai.VALUE)),3,1),' ') NINO3,
           nvl(substr(max(decode(fue.user_entity_name,'X_NATIONAL_INSURANCE_NUMBER',fai.VALUE)),4,1),' ') NINO4,
           nvl(substr(max(decode(fue.user_entity_name,'X_NATIONAL_INSURANCE_NUMBER',fai.VALUE)),5,1),' ') NINO5,
           nvl(substr(max(decode(fue.user_entity_name,'X_NATIONAL_INSURANCE_NUMBER',fai.VALUE)),6,1),' ') NINO6,
           nvl(substr(max(decode(fue.user_entity_name,'X_NATIONAL_INSURANCE_NUMBER',fai.VALUE)),7,1),' ') NINO7,
           nvl(substr(max(decode(fue.user_entity_name,'X_NATIONAL_INSURANCE_NUMBER',fai.VALUE)),8,1),' ') NINO8,
           nvl(substr(max(decode(fue.user_entity_name,'X_NATIONAL_INSURANCE_NUMBER',fai.VALUE)),9,1),' ') NINO9,
           nvl(max(decode(fue.user_entity_name,'X_LAST_NAME',fai.VALUE)),' ') LAST_NAME,
           nvl(max(decode(fue.user_entity_name,'X_TITLE',fai.VALUE)),' ') TITLE,
           nvl(max(decode(fue.user_entity_name,'X_FIRST_NAME',fai.VALUE)),' ') FIRST_NAME,
           nvl(substr(to_char(fnd_date.canonical_to_date(max(decode(fue.user_entity_name,'X_TERMINATION_DATE',fai.VALUE))),'DD-MM-YYYY'),1,2),' ') DATE_OF_LEAVING_DD,
           nvl(substr(to_char(fnd_date.canonical_to_date(max(decode(fue.user_entity_name,'X_TERMINATION_DATE',fai.VALUE))),'DD-MM-YYYY'),4,2),' ') DATE_OF_LEAVING_MM,
           nvl(substr(to_char(fnd_date.canonical_to_date(max(decode(fue.user_entity_name,'X_TERMINATION_DATE',fai.VALUE))),'DD-MM-YYYY'),7,4),' ') DATE_OF_LEAVING_YY,
           nvl(max(decode(fue.user_entity_name,'X_TAX_CODE',fai.VALUE)),' ') TAX_CODE,
           nvl(max(decode(fue.user_entity_name,'X_W1_M1_INDICATOR',fai.VALUE)),' ') W1_M1_IND,
           nvl(max(decode(fue.user_entity_name,'X_WEEK_NUMBER',fai.VALUE)),' ') WEEK_NO,
           nvl(max(decode(fue.user_entity_name,'X_MONTH_NUMBER',fai.VALUE)),' ') MONTH_NO,
           trunc(nvl(max(decode(fue.user_entity_name,'X_TAXABLE_PAY',fai.VALUE)),0)) PAY_TD_POUNDS,
           mod(nvl((max(decode(fue.user_entity_name,'X_TAXABLE_PAY',fai.VALUE))*100),0),100) PAY_TD_PENCE,
           trunc(nvl(max(decode(fue.user_entity_name,'X_TAX_PAID',fai.VALUE)),0)) TAX_TD_POUNDS,
           mod(nvl((max(decode(fue.user_entity_name,'X_TAX_PAID',fai.VALUE))*100),0),100) TAX_TD_PENCE,
           trunc(nvl(max(decode(fue.user_entity_name,'X_PREVIOUS_TAXABLE_PAY',fai.value)),0)) PREV_PAY_IN_POUNDS,
           mod(nvl((max(decode(fue.user_entity_name,'X_PREVIOUS_TAXABLE_PAY',fai.value))*100),0),100) PREV_PAY_IN_PENCE,
           trunc(nvl(max(decode(fue.user_entity_name,'X_PREVIOUS_TAX_PAID',fai.value)),0)) PREV_TAX_IN_POUNDS,
           mod(nvl((max(decode(fue.user_entity_name,'X_PREVIOUS_TAX_PAID',fai.value))*100),0),100) PREV_TAX_IN_PENCE,
           upper(nvl(max(decode(fue.user_entity_name,'X_ASSIGNMENT_NUMBER',fai.VALUE)),' ')) ASSIGNMENT_NUMBER,
           upper(nvl(max(decode(fue.user_entity_name,'X_ORGANIZATION_NAME',fai.VALUE)),' ')) ORGANIZATION_NAME,
           upper(nvl(max(decode(fue.user_entity_name,'X_ADDRESS_LINE1',fai.VALUE)),' ')) ADDRESS_LINE1,
           upper(nvl(max(decode(fue.user_entity_name,'X_ADDRESS_LINE2',fai.VALUE)),' ')) ADDRESS_LINE2,
           upper(nvl(max(decode(fue.user_entity_name,'X_ADDRESS_LINE3',fai.VALUE)),' ')) ADDRESS_LINE3,
           upper(nvl(max(decode(fue.user_entity_name,'X_TOWN_OR_CITY',fai.VALUE)),' ')) TOWN_OR_CITY,
           upper(nvl(max(decode(fue.user_entity_name,'X_COUNTY',fai.VALUE)),' ')) COUNTY,
           upper(nvl(max(decode(fue.user_entity_name,'X_POSTAL_CODE',fai.VALUE)),' ')) POSTAL_CODE,
           upper(nvl(max(decode(fue.user_entity_name,'X_DECEASED_FLAG',fai.VALUE)),' ')) DECEASED_FLAG,
           nvl(max(decode(fue.user_entity_name,'X_ISSUE_DATE',fai.VALUE)),' ') ISSUE_DATE,
           upper(nvl(max(decode(fue.user_entity_name,'X_TAX_REF_TRANSFER',fai.VALUE)),' ')) TAX_REF_TRANSFER,
           upper(nvl(max(decode(fue.user_entity_name,'X_STUDENT_LOAN_FLAG',fai.VALUE)),' ')) STUDENT_LOAN_FLAG,
           upper(nvl(max(decode(fue.user_entity_name,'X_COUNTRY',fai.VALUE)),' ')) COUNTRY,
   	   /*P45 A4 2008/09*/
           nvl(substr(to_char(fnd_date.canonical_to_date(max(decode(fue.user_entity_name,'X_DATE_OF_BIRTH',fai.VALUE))),'DD-MM-YYYY'),1,2),' ') DATE_OF_BIRTH_DD,
           nvl(substr(to_char(fnd_date.canonical_to_date(max(decode(fue.user_entity_name,'X_DATE_OF_BIRTH',fai.VALUE))),'DD-MM-YYYY'),4,2),' ') DATE_OF_BIRTH_MM,
           nvl(substr(to_char(fnd_date.canonical_to_date(max(decode(fue.user_entity_name,'X_DATE_OF_BIRTH',fai.VALUE))),'DD-MM-YYYY'),7,4),' ') DATE_OF_BIRTH_YY,
           nvl(max (decode(fue.user_entity_name,'X_SEX', substr(fai.value,1,1))),' ') SEX
           /*P45 A4 2008/09*/
from       ff_archive_items fai,
           ff_user_entities fue
where      x_assignment_action_id = fai.context1
and        fai.archive_type <>'PA'
and        fai.user_entity_id = fue.user_entity_id;
--
l_cur_get_asg_archive_items     cur_get_asg_archive_items%ROWTYPE;
-- Bug 8370481 : remvoed the number precision
l_pay_in_emp       number;
l_tax_in_emp       number;
l_prev_pay         number;
l_prev_tax         number;
l_total_pay_pounds number;
l_total_pay_pence  number;
l_total_tax_pounds number;
l_total_tax_pence  number;
--
BEGIN
  OPEN cur_get_asg_archive_items;
  FETCH cur_get_asg_archive_items into l_cur_get_asg_archive_items;
  IF cur_get_asg_archive_items%NOTFOUND THEN
    null;
  ELSE
    l_pay_in_emp := (l_cur_get_asg_archive_items.pay_td_pounds + (l_cur_get_asg_archive_items.pay_td_pence/100));
    hr_utility.trace('l_pay_in_emp : '||to_char(l_pay_in_emp));
    l_tax_in_emp := (l_cur_get_asg_archive_items.tax_td_pounds + (l_cur_get_asg_archive_items.tax_td_pence/100));
    hr_utility.trace('l_tax_in_emp : '||to_char(l_tax_in_emp));
    l_prev_pay := (l_cur_get_asg_archive_items.prev_pay_in_pounds + (l_cur_get_asg_archive_items.prev_pay_in_pence/100));
    hr_utility.trace('l_prev_pay : '||to_char(l_prev_pay));
    l_prev_tax := (l_cur_get_asg_archive_items.prev_tax_in_pounds + (l_cur_get_asg_archive_items.prev_tax_in_pence/100));
    hr_utility.trace('l_prev_tax : '||to_char(l_prev_tax));
    l_total_pay_pounds := trunc(l_pay_in_emp + l_prev_pay);
    hr_utility.trace('l_total_pay_pounds : '||to_char(l_total_pay_pounds));
    l_total_pay_pence := (mod((l_pay_in_emp + l_prev_pay),1)*100);
    hr_utility.trace('l_total_pay_pence : '||to_char(l_total_pay_pence));
    l_total_tax_pounds := trunc(l_tax_in_emp + l_prev_tax);
    hr_utility.trace('l_total_tax_pounds : '||to_char(l_total_tax_pounds));
    l_total_tax_pence := (mod((l_tax_in_emp + l_prev_tax),1)*100);
    hr_utility.trace('l_total_tax_pence : '||to_char(l_total_tax_pence));
    x_ni1 := l_cur_get_asg_archive_items.nino1;
    x_ni2 := l_cur_get_asg_archive_items.nino2;
    x_ni3 := l_cur_get_asg_archive_items.nino3;
    x_ni4 := l_cur_get_asg_archive_items.nino4;
    x_ni5 := l_cur_get_asg_archive_items.nino5;
    x_ni6 := l_cur_get_asg_archive_items.nino6;
    x_ni7 := l_cur_get_asg_archive_items.nino7;
    x_ni8 := l_cur_get_asg_archive_items.nino8;
    x_ni9 := l_cur_get_asg_archive_items.nino9;
    x_last_name := l_cur_get_asg_archive_items.last_name;
    x_title := l_cur_get_asg_archive_items.title;
    x_first_name  := l_cur_get_asg_archive_items.first_name;
    x_date_of_leaving_dd := l_cur_get_asg_archive_items.date_of_leaving_dd;
    x_date_of_leaving_mm := l_cur_get_asg_archive_items.date_of_leaving_mm;
    x_date_of_leaving_yy := l_cur_get_asg_archive_items.date_of_leaving_yy;
    x_tax_code_at_leaving := l_cur_get_asg_archive_items.tax_code;
    x_wk1_or_mth1 := l_cur_get_asg_archive_items.w1_m1_ind;
    x_week_no := l_cur_get_asg_archive_items.week_no;
    x_month_no := l_cur_get_asg_archive_items.month_no;
    x_pay_td_pounds := l_total_pay_pounds;
    x_pay_td_pence := l_total_pay_pence;
    x_tax_td_pounds := l_total_tax_pounds;
    x_tax_td_pence := l_total_tax_pence;
    x_pay_in_emp_pounds := l_cur_get_asg_archive_items.pay_td_pounds;
    x_pay_in_emp_pence := l_cur_get_asg_archive_items.pay_td_pence;
    x_tax_in_emp_pounds := l_cur_get_asg_archive_items.tax_td_pounds;
    x_tax_in_emp_pence := l_cur_get_asg_archive_items.tax_td_pence;
    x_assignment_number := l_cur_get_asg_archive_items.assignment_number;
    x_org_name := l_cur_get_asg_archive_items.organization_name;
    x_address_line1 := l_cur_get_asg_archive_items.address_line1;
    x_address_line2 := l_cur_get_asg_archive_items.address_line2;
    x_address_line3 := l_cur_get_asg_archive_items.address_line3;
    x_town_or_city := l_cur_get_asg_archive_items.town_or_city;
    x_region_1 := l_cur_get_asg_archive_items.county;
    x_postal_code := l_cur_get_asg_archive_items.postal_code;
    x_deceased_flag := l_cur_get_asg_archive_items.deceased_flag;
    x_issue_date := l_cur_get_asg_archive_items.issue_date;
    x_tax_ref_transfer := l_cur_get_asg_archive_items.tax_ref_transfer;
    x_student_loan_flag := l_cur_get_asg_archive_items.student_loan_flag;
    x_country := l_cur_get_asg_archive_items.country;
    /* Start P45 A4 2008/09*/
    x_date_of_birth_dd := l_cur_get_asg_archive_items.date_of_birth_dd;
    x_date_of_birth_mm := l_cur_get_asg_archive_items.date_of_birth_mm;
    x_date_of_birth_yy := l_cur_get_asg_archive_items.date_of_birth_yy;
    IF UPPER(l_cur_get_asg_archive_items.sex) = 'M' THEN
     x_sex_m := 'X';
     x_sex_f := ' ';
    ELSIF UPPER(l_cur_get_asg_archive_items.sex) = 'F' THEN
     x_sex_f:= 'X';
     x_sex_m:= ' ';
    END IF;
   /*End P45 A4 2008/09*/
  END IF;
 end pop_term_asg_from_archive;

Procedure pop_term_pact_from_archive (X_PAYROLL_ACTION_ID in number,
                                X_EMPLOYER_NAME         in out nocopy varchar2,
                                X_EMPLOYER_ADDRESS      in out nocopy varchar2)
is
 cursor cur_get_pact_archive_items is
    select upper(nvl(max(decode(fue.user_entity_name,'X_EMPLOYERS_NAME',fai.VALUE)),null)) EMPLOYERS_NAME,
    upper(nvl(max(decode(fue.user_entity_name,'X_EMPLOYERS_ADDRESS_LINE',fai.VALUE)),null)) EMPLOYERS_ADDRESS
    from       ff_archive_item_contexts aic,
               ff_archive_items fai,
               ff_user_entities fue
    where      X_PAYROLL_ACTION_ID = fai.context1
    and        fai.user_entity_id = fue.user_entity_id
    and        fai.archive_item_id = aic.archive_item_id
    and        aic.context = '0'
    and        aic.sequence_no = 1;
--
l_cur_get_pact_archive_items     cur_get_pact_archive_items%ROWTYPE;
--
BEGIN
  OPEN cur_get_pact_archive_items;
  FETCH cur_get_pact_archive_items into l_cur_get_pact_archive_items;
  IF cur_get_pact_archive_items%NOTFOUND THEN
    null;
  ELSE
    x_employer_name := l_cur_get_pact_archive_items.employers_name;
    x_employer_address := l_cur_get_pact_archive_items.employers_address;
   END IF;
 END pop_term_pact_from_archive;
--------------------------------------------------------------------------
-- PROCEDURE get_p45_asg_action_id
-- DESCRIPTION Get the P45 Assignment Action id, Issue Date
--------------------------------------------------------------------------
PROCEDURE get_p45_asg_action_id(p_assignment_id        in number,
                                p_assignment_action_id out nocopy number,
                                p_issue_date           out nocopy date,
                                p_action_sequence      out nocopy number
                                ) IS
--
  CURSOR csr_get_p45_action(c_assignment_id NUMBER) IS
    SELECT act.assignment_action_id, pact.effective_date, act.action_sequence
    FROM   pay_assignment_actions act, pay_payroll_actions pact
    WHERE  act.assignment_id     = c_assignment_id
    AND    act.payroll_action_id = pact.payroll_action_id
    AND    pact.REPORT_QUALIFIER = 'GB'
    AND    pact.ACTION_TYPE      = 'X'
    AND    act.action_status     = 'C'
    AND    report_type           = 'P45'
    AND    report_category       = 'P45';

   CURSOR csr_transfer_p45(c_assignment_action_id NUMBER) IS
    SELECT fai.VALUE
    FROM   ff_archive_items fai, ff_user_entities fue
    WHERE  fai.user_entity_id = fue.user_entity_id
    AND    fue.user_entity_name = 'X_TAX_REF_TRANSFER'
    AND    fue.legislation_code = 'GB'
    AND    fue.business_group_id IS NULL
    AND    fai.context1 = c_assignment_action_id ;

   l_transfer_flag ff_archive_items.value%type;
--
BEGIN
  --
  open csr_get_p45_action(p_assignment_id);
  loop
    p_assignment_action_id := null;
    p_issue_date           := null;
    p_action_sequence      := null;

    fetch csr_get_p45_action into p_assignment_action_id, p_issue_date, p_action_sequence;
    exit when csr_get_p45_action%notfound;
    --
    open csr_transfer_p45(p_assignment_action_id);
    fetch csr_transfer_p45 into l_transfer_flag;
    if csr_transfer_p45%notfound or nvl(l_transfer_flag,'N') = 'N' then
       close csr_transfer_p45;
       exit;
    end if;
    close csr_transfer_p45;
    --
  end loop;
  close csr_get_p45_action;
  --

END get_p45_asg_action_id;
--------------------------------------------------------------------------
-- FUNCTION get_p45_eit_manual_issue_dt
-- DESCRIPTION Get the P45 Manual Issue date from Extra Info. table
--------------------------------------------------------------------------
FUNCTION get_p45_eit_manual_issue_dt(p_assignment_id in number) RETURN DATE IS
--
  l_manual_issue_date date;
  CURSOR csr_get_p45_eit_dtls(c_assignment_id NUMBER) IS
    select fnd_date.canonical_to_date(aei_information3)
    from   per_assignment_extra_info
    where  assignment_id    = c_assignment_id
    and    information_type = 'GB_P45';
--
BEGIN
  open csr_get_p45_eit_dtls(p_assignment_id);
  fetch csr_get_p45_eit_dtls into l_manual_issue_date;
  if csr_get_p45_eit_dtls%NOTFOUND then
     l_manual_issue_date := null;
  end if;
  close csr_get_p45_eit_dtls;
  --
  RETURN l_manual_issue_date;
END get_p45_eit_manual_issue_dt;
--------------------------------------------------------------------------
-- PROCEDURE get_p45_agg_asg_action_id
-- DESCRIPTION Get the Aggregated Assignment Id, Assignment Action id,
-- Final Payment Date for which the P45 been issued
--------------------------------------------------------------------------
PROCEDURE get_p45_agg_asg_action_id(p_assignment_id         in number,
                                    p_agg_assignment_id     out nocopy number,
                                    p_final_payment_date    out nocopy date,
                                    p_p45_issue_date        out nocopy date,
                                    p_p45_agg_asg_action_id out nocopy number
                                   ) IS
--
  Cursor csr_get_all_asg(c_assignment_id NUMBER) IS
    select distinct asg1.assignment_id, asg1.person_id
    from   per_all_assignments_f asg1, per_all_assignments_f asg2
    where  asg2.assignment_id  = c_assignment_id
    and    asg2.person_id      = asg1.person_id
    and    asg1.assignment_id <> p_assignment_id;

/*
  Cursor csr_get_final_payment(c_assignment_id NUMBER, c_asg_action_id NUMBER, c_action_sequence NUMBER) IS
    select pact1.payroll_action_id, pact1.effective_date final_payment_date
      from FF_ARCHIVE_ITEMS ai,
           ff_user_entities  ue,
           pay_payroll_actions pact1
    WHERE  ue.user_entity_name in ('X_MONTH_NUMBER', 'X_WEEK_NUMBER') -- for the weekly frequency (and multiples)
      AND  ue.legislation_code = 'GB'
      AND  ue.business_group_id IS NULL
      and  ue.user_entity_id   = ai.user_entity_id
      and  ai.archive_type     = 'AAP'
      and  ai.context1         = c_asg_action_id
      and  pact1.payroll_action_id =
            (
            select to_number(substr(max(lpad(to_char(act.action_sequence), 20, '0')||to_char(pact.payroll_action_id)),21)) -- just to be consistent with rest of the code to get highest action based on the action sequence
            from   pay_assignment_actions act,
                   pay_payroll_actions pact,
                   per_time_periods ptp -- moved to subquery to make sure latest payroll action having period num matching the archive is fetched
            where  pact.payroll_action_id = act.payroll_action_id
            and    pact.action_type in ('Q', 'R', 'B', 'I', 'V')
            and    act.assignment_id    = c_assignment_id
            and    pact.action_sequence < c_action_sequence -- assuming you will write another sql to get p_p45_action_sequence, alternatively another join to pay_assignment_actions can get you this value in this sql
            -- and    act.SOURCE_ACTION_ID is null -- no need to check for source_action_id being null to cover upgrade from R11 cases
            and    ai.value             = to_char(ptp.period_num)
            and    pact.time_period_id  = ptp.time_period_id
            );
*/

  Cursor csr_get_paye_ref(c_assignment_id NUMBER, c_effective_date DATE) IS
    SELECT flex.segment1 paye_ref, paaf.period_of_service_id
    FROM   per_all_assignments_f paaf,
           pay_all_payrolls_f papf,
           hr_soft_coding_keyflex flex
    WHERE  paaf.assignment_id = c_assignment_id
    AND    c_effective_date between paaf.effective_start_date and paaf.effective_end_date
    AND    paaf.payroll_id = papf.payroll_id
    AND    c_effective_date BETWEEN papf.effective_start_date and papf.effective_end_date
    AND    papf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id;

  cursor csr_agg_asg_active_period(c_assignment_id number,
                                   c_agg_assignment_id number,
                                   c_tax_ref in varchar2,
                                   c_effective_date date
                                  ) is
   select 1
   from   per_all_assignments_f a,
          per_assignment_status_types past
   where  a.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   and    a.assignment_id       = c_assignment_id
   and    a.effective_start_date <= pay_gb_eoy_archive.get_agg_active_end(c_agg_assignment_id, c_tax_ref, c_effective_date)
   and    a.effective_end_date   >= pay_gb_eoy_archive.get_agg_active_start(c_agg_assignment_id, c_tax_ref, c_effective_date)
   ;

  cursor csr_aggr_paye_flag (c_person_id number,
                             c_effective_date date) is
   select per_information10
   from   per_all_people_f
   where  person_id = c_person_id
   and    c_effective_date between
          effective_start_date and effective_end_date;
  --
  -- to fetch the last active/susp status date for the given assignment
  --
  cursor  csr_asg_last_active_date(c_assignment_id number) is
   select max(effective_end_date)
   from   per_all_assignments_f a,
          per_assignment_status_types past
   where  a.assignment_id = c_assignment_id
   and    a.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');

  --
  -- to fetch the earliest aggregation start date from the final payment date.
  --
  cursor  csr_latest_aggr_start_date(c_person_id number, c_effective_date date) is
   select max(effective_end_date) + 1
   from   per_all_people_f
   where  person_id = c_person_id
   and    nvl(per_information10,'N') = 'N'
   and    effective_end_date < c_effective_date;

  --
  -- to check whether the given assignment present between
  -- the earliest aggregation start date and final payment date
  --
  cursor  csr_asg_present_status(c_assignment_id number, c_start_date date, c_end_date date) is
   select 1
   from   per_all_assignments_f a
   where  a.assignment_id = c_assignment_id
   and    a.effective_end_date   >= c_start_date
   and    a.effective_start_date <= c_end_date;

  -- Start of BUG 5671777-2
  --
  -- fetch P45 for another assignment that included the given assignment.
  --
  cursor csr_get_p45_another_asg(c_assignment_id number,c_assignment_action_id number) is
    select 1
    from   ff_archive_items fai,
           ff_user_entities fue
    where  fai.user_entity_id = fue.user_entity_id
    and    fue.user_entity_name = 'X_P45_INCLUDED_ASSIGNMENT'
    and    fai.context1 = c_assignment_action_id
    and    fai.value = to_char(c_assignment_id);

  -- End of BUG 5671777-2

  l_latest_aggr_start_date   date;
  l_asg_last_active_date     date;
  l_agg_asg_last_active_date date;
--
  l_assignment_action_id  NUMBER;
  l_issue_date     DATE;
  l_locked_action_id NUMBER;
  l_effective_date DATE;
  l_agg_paye_flag  per_all_people_f.per_information10%type;
  l_found          BOOLEAN;
  l_dummy          NUMBER;

  l_agg_paye_reference       hr_soft_coding_keyflex.segment1%type;
  l_paye_reference           hr_soft_coding_keyflex.segment1%type;
  l_period_of_service_id     number;
  l_agg_period_of_service_id number;
  l_action_sequence          number;

  l_proc           CONSTANT VARCHAR2(100):= g_package||'get_p45_agg_asg_action_id';
BEGIN
  hr_utility.set_location('Entering: '||l_proc,1);
  p_agg_assignment_id     := null;
  p_final_payment_date    := null;
  p_p45_agg_asg_action_id := null;
  p_p45_issue_date        := null;

  hr_utility.trace('g_p45_inc_assignment ' || g_p45_inc_assignment);

  hr_utility.set_location(l_proc,10);
  -- Start of BUG 5671777-2
  --
  -- fetch P45 for another assignment that included the given assignment.
  --
  for r_rec in csr_get_all_asg(p_assignment_id) loop
      l_assignment_action_id := null;
      l_issue_date           := null;
      hr_utility.set_location(l_proc,14);
      --
      -- fetch the p45 issue date and assignment action id
      --
      get_p45_asg_action_id(p_assignment_id        => r_rec.assignment_id,
                            p_assignment_action_id => l_assignment_action_id,
                            p_issue_date           => l_issue_date,
                            p_action_sequence      => l_action_sequence);

      if l_assignment_action_id is not null then
	hr_utility.set_location(l_proc,17);

	open csr_get_p45_another_asg(p_assignment_id,l_assignment_action_id);
	fetch csr_get_p45_another_asg into l_dummy;
	l_found := csr_get_p45_another_asg%found;
	close csr_get_p45_another_asg;

	if l_found then
	  p_agg_assignment_id     := r_rec.assignment_id;
	  p_final_payment_date    := null;
	  p_p45_agg_asg_action_id := l_assignment_action_id;
	  p_p45_issue_date        := l_issue_date;
	  EXIT;
        end if;
       end if;
  end loop;

if not l_found then
-- End of Bug 5617777-2
  for r_rec in csr_get_all_asg(p_assignment_id) loop
      l_assignment_action_id := null;
      l_issue_date           := null;
      hr_utility.set_location(l_proc,20);
      --
      -- fetch the p45 issue date and assignment action id
      --
      get_p45_asg_action_id(p_assignment_id        => r_rec.assignment_id,
                            p_assignment_action_id => l_assignment_action_id,
                            p_issue_date           => l_issue_date,
                            p_action_sequence      => l_action_sequence);
      --

      if l_assignment_action_id is not null then
         hr_utility.set_location(l_proc,30);
	 --
/*
         -- get the final payment date/effective_date
         --
         open csr_get_final_payment(r_rec.assignment_id, l_assignment_action_id, l_action_sequence);
         fetch csr_get_final_payment into l_locked_action_id, l_effective_date;
         l_found := csr_get_final_payment%found;
         close csr_get_final_payment;
         --

         if l_found then
           hr_utility.set_location(l_proc,40);
*/
           --
           -- fetch the last active/susp status of the aggregated assignemnt
           --
           open csr_asg_last_active_date(r_rec.assignment_id);
           fetch csr_asg_last_active_date into l_agg_asg_last_active_date;
           close csr_asg_last_active_date;

           --
           -- getting the PAYE Aggregate flag for the person on last active/susp date of the agg. asg
           --
           open csr_aggr_paye_flag(r_rec.person_id, l_agg_asg_last_active_date);
           fetch csr_aggr_paye_flag into l_agg_paye_flag;
           close csr_aggr_paye_flag;
           --

           if nvl(l_agg_paye_flag, 'X') = 'Y' then
             hr_utility.set_location(l_proc,50);

             --
             -- fetch the Tax reference for the agg. asg. on the last active/susp status date of the asg
             --
             open csr_get_paye_ref(r_rec.assignment_id, l_agg_asg_last_active_date);
             fetch csr_get_paye_ref into l_agg_paye_reference, l_agg_period_of_service_id;
             l_found := csr_get_paye_ref%found;
             close csr_get_paye_ref;
             --

             if l_found then
               hr_utility.set_location(l_proc,60);
               --
               -- fetch the last active/susp status of the given assignemnt
               --
               open csr_asg_last_active_date(p_assignment_id);
               fetch csr_asg_last_active_date into l_asg_last_active_date;
               close csr_asg_last_active_date;

               --
               -- fetch the Tax reference, period of service id for the given asg. on
               -- the last active/susp status of the assignemnt
               --
               open csr_get_paye_ref(p_assignment_id, l_asg_last_active_date);
               fetch csr_get_paye_ref into l_paye_reference, l_period_of_service_id;
               l_found := csr_get_paye_ref%found;
               close csr_get_paye_ref;
               --

               if l_found and l_paye_reference = l_agg_paye_reference and
                              l_period_of_service_id = l_agg_period_of_service_id then

                 hr_utility.set_location(l_proc,70);

                 --
                 -- check for both assignments share aggregated active period of employment or not
                 --
                 open csr_agg_asg_active_period(p_assignment_id, r_rec.assignment_id,
                                                l_agg_paye_reference, l_agg_asg_last_active_date);
                 fetch csr_agg_asg_active_period into l_dummy;
                 l_found := csr_agg_asg_active_period%found;
                 close csr_agg_asg_active_period;
                 --

                 if l_found then
                    hr_utility.set_location(l_proc,80);
                    --
                    -- to fetch the latest aggregation start date near to final payment date.
                    --
                    open csr_latest_aggr_start_date(r_rec.person_id, l_agg_asg_last_active_date);
                    fetch csr_latest_aggr_start_date into l_latest_aggr_start_date;
                    close csr_latest_aggr_start_date;
                    --

                    if l_latest_aggr_start_date is not null then
                       hr_utility.set_location(l_proc,90);
                       --
                       -- to check whther the given assignment present between
                       -- the earliest aggregation start date and final payment date
                       --
                       open csr_asg_present_status(p_assignment_id, l_latest_aggr_start_date, l_agg_asg_last_active_date);
                       fetch csr_asg_present_status into l_dummy;
                       l_found := csr_asg_present_status%found;
                       close csr_asg_present_status;
                    end if;

                    if l_found then
                      hr_utility.set_location(l_proc,100);
                      --
                      -- returning the final payment date, asg. action id and agg.asg. id
                      --
                      p_agg_assignment_id     := r_rec.assignment_id;
                      p_final_payment_date    := null;
                      p_p45_agg_asg_action_id := l_assignment_action_id;
                      p_p45_issue_date        := l_issue_date;
                      --

                      exit; -- exiting the loop
                    end if;
                 end if;
               end if;
             end if;
           end if;
         --end if;
    end if;
  end loop;
 end if;  -- l_found
  hr_utility.set_location('Leaving: '||l_proc,110);
  --
END get_p45_agg_asg_action_id;

-- Bug 7028893.Added function PAYE_RETURN_P45_ISSUED_FLAG.
--------------------------------------------------------------------------
-- FUNCTION paye_return_p45_issued_flag
-- DESCRIPTION return the P45 issued status for the given assignment
--------------------------------------------------------------------------

FUNCTION paye_return_p45_issued_flag(p_assignment_id in number,p_payroll_action_id in number) RETURN VARCHAR2 IS
--

  -- Cursor to fetch effective date (date earned + off set)
  Cursor csr_get_effective_date(c_payroll_action_id number) is
  select effective_date
  from pay_payroll_actions
  where payroll_action_id = c_payroll_action_id;

  l_assignment_action_id   number;
  l_agg_assignment_id      number;
  l_issue_date             date;
  l_final_payment_date     date;
  l_p45_agg_asg_action_id  number;
  l_action_sequence        number;
  l_return_p45_issued_flag VARCHAR2(1);
  l_proc          CONSTANT VARCHAR2(100):= g_package||'paye_return_p45_issued_flag';
  l_effective_date         date;
--
BEGIN
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- check for the p45 issue date and assignment action id through P45 process
  --
  get_p45_asg_action_id(p_assignment_id        => p_assignment_id,
                        p_assignment_action_id => l_assignment_action_id,
                        p_issue_date           => l_issue_date,
                        p_action_sequence      => l_action_sequence);
  --

  hr_utility.set_location(l_proc,20);
  if l_assignment_action_id is null then
    hr_utility.set_location(l_proc,30);

    --
    -- check for the P45 manualy issued or not
    --
    l_issue_date := get_p45_eit_manual_issue_dt(p_assignment_id);
    if l_issue_date is null then
       hr_utility.set_location(l_proc,40);
       --
       -- check for the P45 issued for any of the aggregated assignment
       --
       get_p45_agg_asg_action_id(p_assignment_id         => p_assignment_id,
                                 p_agg_assignment_id     => l_agg_assignment_id,
                                 p_final_payment_date    => l_final_payment_date,
                                 p_p45_issue_date        => l_issue_date,
                                 p_p45_agg_asg_action_id => l_p45_agg_asg_action_id);

       if l_agg_assignment_id is null then
          hr_utility.set_location(l_proc,50);
          l_return_p45_issued_flag := 'N';
       end if;
    end if;
    --

  end if;
  hr_utility.set_location('Leaving: '||l_proc,60);

  -- Fetching effective date for payroll action id
  open csr_get_effective_date(p_payroll_action_id);
  fetch csr_get_effective_date into l_effective_date;
  close csr_get_effective_date;

  -- Comparing P45 issue date with effective date (date earned + off set)
   if l_effective_date >= l_issue_date then
	l_return_p45_issued_flag := 'Y';
   else
	l_return_p45_issued_flag := 'N';
   end if;
  return l_return_p45_issued_flag;

END paye_return_p45_issued_flag;

-- Bug 7601088.Added function PAYE_RETURN_P45_ISSUED_FLAG.
--------------------------------------------------------------------------
-- FUNCTION PAYE_SYNC_P45_ISSUED_FLAG
-- DESCRIPTION return the P45 issued status for the given assignment
--------------------------------------------------------------------------

FUNCTION PAYE_SYNC_P45_ISSUED_FLAG(p_assignment_id in number,p_effective_date in date) RETURN VARCHAR2 IS
--

  -- Cursor to fetch effective date (date earned + off set)
/*  Cursor csr_get_effective_date(c_payroll_action_id number) is
  select effective_date
  from pay_payroll_actions
  where payroll_action_id = c_payroll_action_id; */

  l_assignment_action_id   number;
  l_agg_assignment_id      number;
  l_issue_date             date;
  l_final_payment_date     date;
  l_p45_agg_asg_action_id  number;
  l_action_sequence        number;
  l_return_p45_issued_flag VARCHAR2(1);
  l_proc          CONSTANT VARCHAR2(100):= g_package||'PAYE_SYNC_P45_ISSUED_FLAG';
  l_effective_date         date;
--
BEGIN
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- check for the p45 issue date and assignment action id through P45 process
  --
  get_p45_asg_action_id(p_assignment_id        => p_assignment_id,
                        p_assignment_action_id => l_assignment_action_id,
                        p_issue_date           => l_issue_date,
                        p_action_sequence      => l_action_sequence);
  --

  hr_utility.set_location(l_proc,20);
  if l_assignment_action_id is null then
    hr_utility.set_location(l_proc,30);

    --
    -- check for the P45 manualy issued or not
    --
    l_issue_date := get_p45_eit_manual_issue_dt(p_assignment_id);
    if l_issue_date is null then
       hr_utility.set_location(l_proc,40);
       --
       -- check for the P45 issued for any of the aggregated assignment
       --
       get_p45_agg_asg_action_id(p_assignment_id         => p_assignment_id,
                                 p_agg_assignment_id     => l_agg_assignment_id,
                                 p_final_payment_date    => l_final_payment_date,
                                 p_p45_issue_date        => l_issue_date,
                                 p_p45_agg_asg_action_id => l_p45_agg_asg_action_id);

       if l_agg_assignment_id is null then
          hr_utility.set_location(l_proc,50);
          l_return_p45_issued_flag := 'N';
       end if;
    end if;
    --

  end if;
  hr_utility.set_location('Leaving: '||l_proc,60);

  -- Fetching effective date for payroll action id
 /* open csr_get_effective_date(p_payroll_action_id);
  fetch csr_get_effective_date into l_effective_date;
  close csr_get_effective_date; */

  -- Comparing P45 issue date with effective date (date earned + off set)
   if p_effective_date >= l_issue_date then
	l_return_p45_issued_flag := 'Y';
   else
	l_return_p45_issued_flag := 'N';
   end if;
  return l_return_p45_issued_flag;

END PAYE_SYNC_P45_ISSUED_FLAG;

--------------------------------------------------------------------------
-- FUNCTION return_p45_issued_flag
-- DESCRIPTION return the P45 issued status for the given assignment
--------------------------------------------------------------------------
FUNCTION return_p45_issued_flag(p_assignment_id in number) RETURN VARCHAR2 IS
--
  l_assignment_action_id   number;
  l_agg_assignment_id      number;
  l_issue_date             date;
  l_final_payment_date     date;
  l_p45_agg_asg_action_id  number;
  l_action_sequence        number;
  l_return_p45_issued_flag VARCHAR2(1) := 'Y';
  l_proc          CONSTANT VARCHAR2(100):= g_package||'return_p45_issued_flag';
--
BEGIN
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- check for the p45 issue date and assignment action id through P45 process
  --
  get_p45_asg_action_id(p_assignment_id        => p_assignment_id,
                        p_assignment_action_id => l_assignment_action_id,
                        p_issue_date           => l_issue_date,
                        p_action_sequence      => l_action_sequence);
  --

  hr_utility.set_location(l_proc,20);
  if l_assignment_action_id is null then
    hr_utility.set_location(l_proc,30);

    --
    -- check for the P45 manualy issued or not
    --
    if get_p45_eit_manual_issue_dt(p_assignment_id) is null then
       hr_utility.set_location(l_proc,40);
       --
       -- check for the P45 issued for any of the aggregated assignment
       --
       get_p45_agg_asg_action_id(p_assignment_id         => p_assignment_id,
                                 p_agg_assignment_id     => l_agg_assignment_id,
                                 p_final_payment_date    => l_final_payment_date,
                                 p_p45_issue_date        => l_issue_date,
                                 p_p45_agg_asg_action_id => l_p45_agg_asg_action_id);

       if l_agg_assignment_id is null then
          hr_utility.set_location(l_proc,50);
          l_return_p45_issued_flag := 'N';
       end if;
    end if;
    --

  end if;
  hr_utility.set_location('Leaving: '||l_proc,60);
  return l_return_p45_issued_flag;
  --
END return_p45_issued_flag;

END pay_p45_pkg;

/
